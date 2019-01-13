/***
 * @file : calaphot_tcl.cpp
 * @brief : interface TCL pour les routines de photométrie et de modélisation
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: calaphot_tcl.cpp,v 1.7 2011-01-23 16:36:18 jacquesmichelet Exp $
 *
 * <pre>
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * </pre>
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <algorithm>

#include <string.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

#include <libaudela.h>
#include "libjm.h"
#include "divers.h"
#include "calaphot.h"

using namespace std;

namespace LibJM {

int Photom::CmdNiveauTraces( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
{
    if ( argc < 2 )
    {
        std::ostringstream oss;
        oss << "Usage: " << argv[0] << "  (0=very verbose, ..., 9=dumb)";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
    Photom::instance()->niveau_traces( atoi( argv[1] ) );
    return TCL_OK;
}

int Photom::CmdModeLecturePixels( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
{
    photom_info1 ( "argc = " << argc );
    for ( int arg = 0; arg < argc; arg++ )
        photom_info1 ( "argv[" << arg << "] = " << argv[arg] );

    if ( argc < 2 )
    {
        std::ostringstream oss;
        oss << "Usage: " << argv[0] << " normal|bilin";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
    if ( strcmp( argv[1], "normal") == 0 )
        photom_mode = Photom::NORMAL;
    else if ( strcmp( argv[1], "bilin") == 0 )
        photom_mode = Photom::BILINEAIRE;
    else
    {
        std::ostringstream oss;
        oss << "Illegal parameter : should be \"normal\" or \"bilin\" ";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
    return TCL_OK;
}

 int Photom::CmdMinMax( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
{
    std::ostringstream oss;

    photom_info1 ( "argc = " << argc );
    for ( int arg = 0; arg < argc; arg++ )
        photom_info1 ( "argv[" << arg << "] = " << argv[arg] );

    if ( argc != 2 )
    {
        std::ostringstream oss;
        oss << "Usage: " << argv[0] << "  { minimum value, maximum value }";
        Tcl_SetResult( interp, const_cast<char*>( oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
    std::vector<double> extrema = Divers::DecodeListeDouble( interp, argv[1] );
    if ( extrema.size() != 2 ) {
        oss << "Usage: " << argv[0] << " Missing values";
        Tcl_SetResult( interp, const_cast<char*>( oss.str().c_str() ), TCL_VOLATILE );
        return TCL_ERROR;
    }
    Photom::instance()->minmax->minimum( min( (TYPE_PIXELS)extrema[0], (TYPE_PIXELS)extrema[1] ) );
    Photom::instance()->minmax->maximum( max( (TYPE_PIXELS)extrema[0], (TYPE_PIXELS)extrema[1] ) );
    return TCL_OK;
}

/******************************************/
/* Calcul du flux dans une ellipse        */
/******************************************/
int Photom::CmdFluxEllipse(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    std::ostringstream oss;
    int retour, tampon;

    photom_info1 ( "argc = " << argc );
    for ( int arg = 0; arg < argc; arg++ )
        photom_info1 ( "argv[" << arg << "] = " << argv[arg] );

    if ( ( argc == 9 ) || ( argc == 10 ) )
    {
        /* La facteur de rotation doit impérativement être de module inférieur à 1 */
        if ( fabs( atof( argv[6] ) ) >= 1.0 )
        {
            oss << "Le facteur de rotation doit avoir un module inférieur à 1.0";
            Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
            return TCL_ERROR;
        }

        /* Validité du paramètre de buffer */
        retour = Tcl_GetInt(interp, argv[1], &tampon);
        if (retour != TCL_OK)
            return retour;

        /* Récupération des infos sur l'image */
        if (Photom::instance()->set_buffer (tampon) == 0)
        {
            oss << "Pas de buffer nr " << tampon;
            Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
            return TCL_ERROR;
        }

        ouverture ouv;
        ouv.centre.x = atof( argv[2] );
        ouv.centre.y = atof( argv[3] );
        ouv.rayon_1 = sqrt( atof( argv[4] ) * atof( argv[5] ) );
        ouv.rayon_2 = atof( argv[7] );
        ouv.rayon_3 = atof( argv[8] );
        ouv.facteur_ro = atof( argv[6] );
        ouv.rapport_yx = atof( argv[5] ) / atof( argv[4] );

        flux_ouverture fouv;

        if (argc == 9)
        {
            try
            {
                Photom::instance()->FluxEllipse ( &ouv, 16, &fouv );
            }
            catch ( const IError& e )
            {
                Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
                return TCL_ERROR;
            }
        }
        if (argc == 10)
        {
            try
            {
                Photom::instance()->FluxEllipse( &ouv, atol( argv[9] ), &fouv );
            }
            catch ( const IError& e )
            {
                photom_error( e.gets() );
                Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
                return TCL_ERROR;
            }
        }
        int p = oss.precision();
        oss << std::setprecision( 10 ) << fouv.flux_etoile;
        oss << " " << fouv.nb_pixels_etoile;
        oss << " " << fouv.intensite_fond_ciel;
        oss << " " << fouv.nb_pixels_fond_ciel;
        oss << " " << " " << fouv.bruit_fond_ciel;
        oss.precision( p );
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );

        photom_info1 ( "retour = " << oss.str().c_str() );

        return TCL_OK;
    }
    else
    {
        oss << "Usage: " << argv[0] << " numero_buffer x_ellipse y_ellipse gd_axe pt axe allongement couronne1 couronne2 [sur_echantillonage]";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
}

/***************************/
/* Magnitude etoile        */
/***************************/
int Photom::CmdMagnitude(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    char s[256];
    double magnitude;
    int tampon = 0;  // En fait ce code n'est pas opérationnel. A reprendre...

    photom_debug ("argc = " << argc);
    
    if (argc == 5)
    {
        if (Photom::instance()->set_buffer (tampon) == 0)
        {
            sprintf (s, "Pas de buffer nr %d", tampon);
            Tcl_SetResult (interp, s, TCL_VOLATILE);
            return TCL_ERROR;
        }
    
        if (Photom::instance()->Magnitude(atof(argv[1]), atof(argv[2]), atof(argv[3]), &magnitude) == Generique::PB)
        {
            strcpy(s,"Erreur dans la fonction Magnitude");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
        }
        sprintf(s,"%7.4f", magnitude);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_OK;
    }
    else
    {
        sprintf(s, "Usage: %s flux_etoile flux_etoile_reference magnitude_etoile_reference", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    }
}


/***************************************************************/
/* Ajustement d'un morceau d'image (etoile) par une gaussienne */
/***************************************************************/
int Photom::CmdAjustementGaussien (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
    std::ostringstream oss;
    int tampon;
    double reliquat;
    int iterations;
    int retour;
    Astre astre;

    photom_info1 ( "argc = " << argc );
    for ( int arg = 0; arg < argc; arg++ )
        photom_info1( "argv[" << arg << "] = " << argv[arg] );

    if ( ( argc < 3 ) || ( argc > 4 ) )
    {
        oss << "Usage: " << argv[0] << " Numero_Buffer Coordonnees_Carre ?-sub?";
        Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
        return TCL_ERROR;
    }
    else
    {
        /* Validite du paramètre de buffer */
        retour = Tcl_GetInt( interp, argv[1], &tampon );
        if ( retour != TCL_OK )
            return retour;

        /* Validité de la liste des coordonnées */
        std::vector<int> zone_ecran = Divers::DecodeListeInt( interp, argv[2] );
        if ( zone_ecran.size() != 4 )
        {
            oss << "Usage: " << argv[0] << " Mauvaises coordonnees";
            Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
            return TCL_ERROR;
        }

        if ( argc == 4 )
        {
            if (strncmp(argv[3], "-sub", 4) != 0) {
                oss << "Usage: " << argv[0] << " Numero_Buffer Coordonnees_Carre ?-sub?";
                Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
                return TCL_ERROR;
            }
        }

        /* Récupération des infos sur l'image */
        if ( Photom::instance()->set_buffer (tampon) == 0 )
        {
            oss << "Pas de buffer nr " << tampon;
            Tcl_SetResult( interp, const_cast<char*>(oss.str().c_str()), TCL_VOLATILE );
            return TCL_ERROR;
        }

        try
        {
            /* Appel à bufn fitgauss pour récupérer les valeurs caractéristiques du rectangle */
            /* Formation de la chaine et appel */
            char s[256];
            sprintf( s, "buf%d fitgauss {%s}", tampon, argv[2] );
            Tcl_Eval( interp, s );
            /* Lecture des resultats */
            std::vector<double> fgauss = Divers::DecodeListeDouble( interp, Tcl_GetStringResult(interp) );

            /* Appel à bufn stat pour récupérer les valeurs caractéristiques du rectangle */
            /* Formation de la chaine et appel */
            sprintf( s, "buf%d stat {%s}", tampon, argv[2] );
            Tcl_Eval (interp, s);
            /* Lecture des resultats */
            std::vector<double> stat = Divers::DecodeListeDouble( interp, Tcl_GetStringResult(interp) );

            astre.init_rectangle( zone_ecran );

            /* A partir des valeurs approximatives donnees par bufn stat, calcul d'un profil gaussien plausible */
            iterations = Photom::instance()->AjustementGaussien( astre, fgauss, stat, &reliquat );

            /* Soustraction du modèle à l'image originale */
            if ( ( argc == 4 ) && ( iterations != 0 ) )
                Photom::instance()->SoustractionGaussienne( astre );
        }
        catch (const IError& e)
        {
            photom_error( e.gets () );
            for( int arg = 0; arg < argc; arg++ )
                photom_error( "\t argv[" << arg << "] = " << argv[arg] );
            Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
            return TCL_ERROR;
        }

        Modele * valeurs = astre.modele();
        Modele * incertitudes = astre.incert();

        int p = oss.precision();
        oss << std::setprecision( 10 ) << reliquat;
        oss << " " << iterations;
        oss << " " << valeurs->X0;
        oss << " " << valeurs->Y0;
        oss << " " << valeurs->Signal;
        oss << " " << valeurs->Fond;
        oss << " " << Divers::sigma_en_fwhm( valeurs->Sigma_X );
        oss << " " << Divers::sigma_en_fwhm( valeurs->Sigma_Y );
        oss << " " << valeurs->Ro;
        oss << " " << valeurs->Alpha;
        oss << " " << Divers::sigma_en_fwhm( valeurs->Sigma_1 );
        oss << " " << Divers::sigma_en_fwhm( valeurs->Sigma_2 );
        oss << " " << valeurs->Flux;
        oss << " " << incertitudes->X0;
        oss << " " << incertitudes->Y0;
        oss << " " << incertitudes->Signal;
        oss << " " << incertitudes->Fond;
        oss << " " << Divers::sigma_en_fwhm( incertitudes->Sigma_X );
        oss << " " << Divers::sigma_en_fwhm( incertitudes->Sigma_Y );
        oss << " " << incertitudes->Ro;
        oss << " " << incertitudes->Alpha;
        oss << " " << Divers::sigma_en_fwhm( incertitudes->Sigma_1 );
        oss << " " << Divers::sigma_en_fwhm( incertitudes->Sigma_2 );
        oss << " " << incertitudes->Flux;
        oss.precision( p );

        Tcl_SetResult( interp, const_cast<char*>( oss.str().c_str() ), TCL_VOLATILE );

        photom_info1 ( "retour = " << oss.str().c_str() );

        return TCL_OK;
    }
}


/***************************/
/* Version de la librairie */
/***************************/




}
