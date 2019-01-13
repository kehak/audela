/***
 * @file : calaphot.cpp
 * @brief : routines de photométrie et de modélisation
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: calaphot.cpp,v 1.6 2010-06-19 16:58:42 jacquesmichelet Exp $
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
#include <algorithm>
#include <vector>

#include <string.h>
#include <stdexcept>  // pour std::runtime_error
#include <cmath>
#include <cstring>    // pour memcpy
#include <gsl/gsl_math.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_multifit_nlin.h>
#include <gsl/gsl_histogram.h>
#include <gsl/gsl_statistics_double.h>
#include <gsl/gsl_sort_double.h>

#include <libaudela.h>
#include "libjm.h"
#include "erreur.h"
#include "divers.h"
#include "calaphot.h"

using namespace std;

#if defined(WIN32) && defined(_MSC_VER) &&( _MSC_VER < 1500)
#define min(a, b) (((a) < (b)) ? (a) : (b))
#define max(a, b) (((a) > (b)) ? (a) : (b))
#endif

namespace LibJM {

    Photom * Photom::_unique_instance = 0;
    int Photom::_log_verbosity = Photom::Notice_Level;
    std::ofstream Photom::log_stream;
    std::string Photom::photom_log_file_name("libjm_photom.log");
    Photom::Limites * Photom::minmax = new Limites( 0.0, 32760.0 );
    int Photom::photom_mode = Photom::NORMAL;


/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
    Photom::Photom()
    {
        std::string nom_fichier_log;
        if ( LibJM::Generique::repertoire_log.size() > 0 )
        {
            nom_fichier_log = LibJM::Generique::repertoire_log;
#if defined(WIN32)
            nom_fichier_log = nom_fichier_log + "\\";
#else
            nom_fichier_log = nom_fichier_log + "/";
#endif
        }
        nom_fichier_log = nom_fichier_log + photom_log_file_name;

        log_stream.open( nom_fichier_log.c_str(), std::ios::trunc );
        if( !log_stream )
        {
            std::cerr << "Error opening the log file " << nom_fichier_log << std::endl;
        }
    }

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
    Photom::~Photom()
    {
        log_stream.close();
    }

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
    Photom * Photom::instance ()
    {
        if ( _unique_instance == 0 )
            _unique_instance = new Photom();
        return _unique_instance;
    }

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
    void Photom::niveau_traces( int niveau )
    {
        _log_verbosity = niveau;
    }


    /*** Pour la mise au point de la modélisation
    #define TRACE_FONCTION
    #define TRACE_JACOBIEN
    #define TRACE_AJUSTEMENT
     */

#define NB_PARAM_GAUSS 7
#define CONDITION_ARRET_NORME 1e-12
#define NOMBRE_MAX_ITERATION 500



    /* Utilisation des routines spécifiques GSL non linéaires */
    /* En fait, ça ne marche pas (message d'erreur cryptique, pas d'information claire dans la doc */
    /*
#define GSL_NON_LINEAIRE
     */

/***************************************************************************************/
/***************************************************************************************/
/***************************************************************************************/
    IBuffer * Photom::set_buffer (int tampon)
    {
        _buffer = ILibaudela::findBuffer(tampon);
        photom_info2 ("tampon = "<< tampon << " buffer = "<< (void*) _buffer);
        if (_buffer)
            return _buffer;
        else
            return 0;
    }


    /*
     ***************** LecturePixel ************
     *
     * Retourne la valeur d'un pixel
     *******************************************
*/
    TYPE_PIXELS Photom::LecturePixel( double x, double y )
    {
        TYPE_PIXELS intensite;
        int plan = 0;

        photom_trace( "x=" << x << " / y=" << y );

        if ( Photom::photom_mode == Photom::NORMAL ) {
            int xi = (int)( x + 0.5 );
            int yi = (int)( y + 0.5 );
            try
            {
                /* x et y sont données en coordonnées Audace, cad de 1 à naxisN */
                /* GetPix prend des valeurs de 0 à (naxisN - 1) */
                /* Donc on enlève 1 à xi et yi au moment de l'appel à GetPix */
                _buffer->getPix( &plan, &intensite, &intensite, &intensite, ( xi - 1 ) , ( yi - 1 ) );
                if ( ( intensite < minmax->minimum() ) || ( intensite > minmax->maximum() ) ) {
                    photom_debug( "y=" << y << "  / yi=" << yi << " / x=" << y << "  / xi=" << yi << " / i(x,y)=" << intensite );
                    std::ostringstream oss;
                    oss << "The pixel (" << xi << "," << yi << ") has a value(" << intensite << ") that is out of the range [" << minmax->minimum() << "," << minmax->maximum() << "]";
                    throw LibJM::Erreur( oss.str().c_str() );
                }
            }
            catch ( const IError& e )
            {
                photom_error ( e.gets() << " x=" << x << " y=" << y );
                intensite = 0;
                throw;
            }
            photom_trace( "x=" << x << " / y=" << y << "/ i=" << intensite );
        }

        if ( Photom::photom_mode == Photom::BILINEAIRE ) {
            int x00, x10, x01, x11;
            int y00, y10, y01, y11;
            TYPE_PIXELS i00, i10, i01, i11;

            // La fonction round() n'existe pas VC++ !!!
            double dx = x - int( x + 0.5 );
            double dy = y - int( y + 0.5 );

            /* x et y sont données en coordonnées Audace, cad de 1 à naxisN */
            /* GetPix prend des valeurs de 0 à (naxisN - 1) */
            /* Donc on enlève 1 à x et y au moment de l'appel à GetPix */
            x00 = int( x + 0.5 - 1 );
            y00 = int( y + 0.5 - 1 );
            x01 = x00;
            y01 = y00 + Divers::sgn( dy );
            x10 = x00 + Divers::sgn( dx );
            y10 = y00;
            x11 = x10;
            y11 = y01;

            dx = (TYPE_PIXELS)fabs( dx );
            dy = (TYPE_PIXELS)fabs( dy );

            try {
//                photom_trace( "dx=" << dx << " / dy=" << dy );

                _buffer->getPix ( &plan, &i00, &i00, &i00, x00, y00 );
                _buffer->getPix ( &plan, &i10, &i10, &i10, x10, y10 );
                _buffer->getPix ( &plan, &i01, &i01, &i01, x01, y01 );
                _buffer->getPix ( &plan, &i11, &i11, &i11, x11, y11 );

                if ( ( i00 < minmax->minimum() ) || ( i00 > minmax->maximum() )
                || ( i10 < minmax->minimum() ) || ( i10 > minmax->maximum() )
                || ( i01 < minmax->minimum() ) || ( i01 > minmax->maximum() )
                || ( i11 < minmax->minimum() ) || ( i11 > minmax->maximum() ) )
                {
                    std::ostringstream oss;
                    oss << "The pixel (" << int( x + 0.5 ) << "," << int( y + 0.5 ) << ") has a value(" << intensite << ") that is out of the range [" << minmax->minimum() << "," << minmax->maximum() << "]";
                    throw LibJM::Erreur( oss.str().c_str() );
                }

//                photom_trace( "x00=" << x00 << " / y00=" << y00 << " / i00=" << i00 );
//                photom_trace( "x01=" << x01 << " / y01=" << y01 << " / i01=" << i01 );
//                photom_trace( "x10=" << x10 << " / y10=" << y10 << " / i10=" << i10 );
//                photom_trace( "x11=" << x11 << " / y11=" << y11 << " / i11=" << i11 );

                intensite = (TYPE_PIXELS)( ( 1.0 - dx ) * ( 1.0 - dy ) * i00
                + ( 1.0 - dx ) * dy * i01
                + dx * ( 1.0 - dy ) * i10
                + dx * dy * i11);

//                photom_trace( "1-dx=" << 1 - dx << " / 1-dy=" << 1 - dy << " / i=" << intensite );
            }
            catch ( const IError& e ) {
                photom_error ( e.gets() );
                photom_error ( "x=" << x << " y=" << y );
                intensite = 0;
                throw;
            }
        }

        return intensite;
    }

/*
     ***************** EcriturePixel ************
     *
     * Ecrit la valeur d'un pixel
     ********************************************
*/
    int Photom::EcriturePixel( double x, double y, TYPE_PIXELS pixel )
    {
        /* x et y sont données en coordonnées Audace, cad de 1 à naxisN */
        /* GetPix prend des valeurs de 0 à (naxisN - 1) */
        /* Donc on enlève 1 à xi et yi au moment de l'appel à GetPix */
        int xi = (int)( x + 0.5 );
        int yi = (int)( y + 0.5 );
        _buffer->setPix( static_cast<TColorPlane>(0), pixel, ( xi - 1 ), ( yi - 1 ) );
        return 0;
    }

/*
     ***************** FluxEllipse ****************
     *
     * Calcule le flux dans une ellipse
     **********************************************
*/
    void Photom::FluxEllipse( Photom::ouverture * ouv, int c, Photom::flux_ouverture * fouv )
    {
        double flux_etoile, cinv, cinv2;
        TYPE_PIXELS intensite;

        photom_info2 ( " x0=" << ouv->centre.x << " y0=" << ouv->centre.y
            << " ro=" << ouv->facteur_ro << " r1=" << ouv->rayon_1
            << " r2=" << ouv->rayon_2 << " r3="<< ouv->rayon_3
            << " ryx=" << ouv->rapport_yx << " c=" << c );

        /* Initialisations */
        fouv->nb_pixels_fond_ciel = 0.0;
        flux_etoile = 0.0;
        fouv->nb_pixels_etoile = 0.0;
        cinv = 1.0 / (double)c;
        cinv2 = cinv * cinv;


        /**************************************************************
         * Calcul du flux dans la couronne et dans la partie centrale *
         * ************************************************************/

        /* Simplification des écritures */
        double x0 = ouv->centre.x;
        double y0 = ouv->centre.y;
        double ro = ouv->facteur_ro;

        /* Calcul des valeurs des rayons de la couronne */
        double sryx = sqrt( ouv->rapport_yx );
        double r1y = ouv->rayon_1 * sryx;
        double r1x = ouv->rayon_1 / sryx;
        double r2y = ouv->rayon_2 * sryx;
        double r2x = ouv->rayon_2 / sryx;
        double r3y = ouv->rayon_3 * sryx;
        double r3x = ouv->rayon_3 / sryx;

        photom_info2( "r1x=" << r1x << " / r1y=" << r1y );
        photom_info2( "r2x=" << r2x << " / r2y=" << r2y );
        photom_info2( "r3x=" << r3x << " / r3y=" << r3y );

        /* Calcul des valeurs max sur les axes x et y en fonctions des paramètres de l'ellipse */
        double delta_y3 = ceil( r3y / sqrt( 1 - ouv->facteur_ro * ouv->facteur_ro) );
        double delta_x3 = ceil( r3x / sqrt( 1 - ouv->facteur_ro * ouv->facteur_ro) );

        /* Allocation d'un tableau représentant les sous-pixels du fond de ciel */
        size_t n3 = (size_t)( 4 * delta_y3 * delta_x3 * c * c );
        gsl_vector * ciel = gsl_vector_alloc( n3 );
        size_t index_fond = 0;

        for ( double yy = ( y0 - delta_y3 ); yy <= ( y0 + delta_y3 ); yy += cinv )
        {
            for ( double xx = ( x0 - delta_x3 ); xx <= ( x0 + delta_x3 ); xx += cinv )
            {
                double t3 = ( ( xx - x0 ) * ( xx - x0 ) ) / ( r3x * r3x )
                    + ( ( yy - y0 ) * ( yy - y0 ) ) / ( r3y * r3y )
                    - 2.0 * ro * ( xx - x0 ) * ( yy - y0 ) / ( r3x * r3y )
                    - 1.0;
                double t2 = ( ( xx - x0 ) * ( xx - x0 ) ) / ( r2x * r2x )
                    + ( ( yy - y0 ) * ( yy - y0 ) ) / ( r2y * r2y )
                    - 2.0 * ro * ( xx - x0 ) * ( yy - y0 ) / ( r2x * r2y )
                    - 1.0;
                double t1 = ( ( xx - x0 ) * ( xx - x0 ) ) / ( r1x * r1x )
                    + ( ( yy - y0 ) * ( yy - y0 ) ) / ( r1y * r1y )
                    - 2.0 * ro * ( xx - x0 ) * ( yy - y0 ) / ( r1x * r1y )
                    - 1.0;

                if ( ( t3 <= 0.0 ) && ( t2 >= 0.0 ) )
                {
                    photom_debug( "Couronne xx=" << xx << " / yy=" << yy );
                    /* Le point (xx,yy) est dans la couronne */
                    try
                    {
                        intensite = LecturePixel( xx, yy );
                    }
                    catch ( const IError& e )
                    {
                        photom_error (e.gets());
                        photom_error ("x0=" << ouv->centre.x << " y0=" << ouv->centre.y
                        << " ro=" << ouv->facteur_ro << " r1=" << ouv->rayon_1
                        << " r2=" << ouv->rayon_2 << " r3="<< ouv->rayon_3
                        << " ryx=" << ouv->rapport_yx << " c=" << c);
                        gsl_vector_free( ciel );
                        throw;
                    }
                    /* On range la valeur du pixel dans le tableau */
                    gsl_vector_set( ciel, index_fond, intensite );
                    index_fond ++;
                    fouv->nb_pixels_fond_ciel += cinv2;
                }

                if ( t1 <= 0.0 )
                {
                    photom_debug( "Centre xx=" << xx << " / yy=" << yy );
                    /* Le point (xx,yy) est dans l'ellipse centrale */
                    try
                    {
                        intensite = LecturePixel( xx, yy );
                    }
                    catch ( const IError& e )
                    {
                        photom_error (e.gets());
                        photom_error ("x0=" << ouv->centre.x << " y0=" << ouv->centre.y
                        << " ro=" << ouv->facteur_ro << " r1=" << ouv->rayon_1
                        << " r2=" << ouv->rayon_2 << " r3="<< ouv->rayon_3
                        << " ryx=" << ouv->rapport_yx << " c=" << c);
                        gsl_vector_free( ciel );
                        throw;
                    }
                    flux_etoile += intensite * cinv2;
                    fouv->nb_pixels_etoile += cinv2;
                }
            }
        }

        double * data_ciel = gsl_vector_ptr ( ciel, 0 );

        /* La valeur du flux de fond est la moyenne de toutes les valeurs lues dans la couronne. */

        int longueur = index_fond;
        int total_exclu = 0;
        int exclu = longueur;
        double moyenne = 0.0, ecart_type = 0.0;

        while ( exclu != 0 ) {
            moyenne = gsl_stats_mean( data_ciel, 1, longueur );
            ecart_type = gsl_stats_sd_with_fixed_mean( data_ciel, 1, longueur, moyenne );
            int j = 0;
            for ( int i = 0; i < longueur; i++ ) {
                double val = gsl_vector_get( ciel, i );
                if ( fabs( val - moyenne ) <= ( 2.0 * ecart_type ) ) {
                    gsl_vector_set( ciel, j , val );
                    j++;
                }
            }
            exclu = longueur - j;
            photom_trace( "moyenne=" << moyenne << " / sigma=" << ecart_type << " / longueur=" << longueur << " / rejeté=" << exclu );
            total_exclu += exclu;
            longueur = j;
        }
        photom_debug( "Fraction éliminée = " << (double)total_exclu / double( index_fond ) );

//            double moyenne = gsl_stats_mean( data_ciel, 1, longueur );
//            double ecart_type = gsl_stats_sd_with_fixed_mean( data_ciel, 1, longueur, moyenne );

        /* Tri des valeurs par ordre croissant */
        //gsl_sort( data_ciel, 1, index_fond);

        /* Calcul de la médiane */
        // double mediane = gsl_stats_median_from_sorted_data ( data_ciel, 1, index_fond);
        // double ecart_type_mediane = gsl_stats_sd_with_fixed_mean( data_ciel, 1, index_fond, mediane );

        /* Calcul type daophot */
        // double daophot = 3.0 * mediane - 2.0 * *fond;
        // double ecart_type_daophot = gsl_stats_sd_with_fixed_mean( data_ciel, 1, index_fond, daophot );

        /* Calcul de la moyenne en rejetant les 20% des valeurs extrêmes */
        //size_t taille_reduite = ( index_fond * 8 + 5 ) / 10;
        //size_t indice_reduit = ( index_fond + 5 ) / 10;
        //double moyenne_reduite = gsl_stats_mean( &data_ciel[indice_reduit], 1, taille_reduite );
        //double ecart_type_reduit = gsl_stats_sd_with_fixed_mean( &data_ciel[indice_reduit], 1, taille_reduite, moyenne_reduite );

        /* Calcul du flux de l'étoile */
        double flux_moyenne = flux_etoile -  fouv->nb_pixels_etoile * moyenne;
        // double flux_mediane = flux_etoile - (double)(*nb_pixel) * mediane;
        // double flux_daophot = flux_etoile - (double)(*nb_pixel) * daophot;
        // double flux_reduit = flux_etoile - fouv->nb_pixels_etoile * moyenne_reduite;

        photom_debug( "nb_fond=" << fouv->nb_pixels_fond_ciel << " / moyenne=" << moyenne << " / sigma=" << ecart_type );
        // photom_debug( "nb_fond=" << *nb_pixel_fond << " / mediane=" << mediane << " / sigma_mediane=" << ecart_type_mediane );
        // photom_debug( "nb_fond=" << *nb_pixel_fond << " / daophot=" << daophot << " / sigma_daophot=" << ecart_type_daophot );
        // photom_debug( "nb_fond=" << fouv->nb_pixels_fond_ciel << " / reduit=" << moyenne_reduite << " / sigma_reduit=" << ecart_type_reduit );
        // photom_debug( "nb_pixel=" << *nb_pixel << " / flux_etoile=" << flux_etoile << " / flux=" << *flux );
        // photom_debug( "nb_pixel=" << *nb_pixel << " / flux_etoile=" << flux_etoile << " / flux_mediane=" << flux_mediane );
        // photom_debug( "nb_pixel=" << *nb_pixel << " / flux_etoile=" << flux_etoile << " / flux_daophot=" << flux_daophot );
        // photom_debug( "nb_pixel=" << fouv->nb_pixels_etoile << " / flux_etoile=" << flux_etoile << " / flux_reduit=" << flux_reduit );

        fouv->flux_etoile = flux_moyenne;
        fouv->intensite_fond_ciel = moyenne;
        fouv->bruit_fond_ciel = ecart_type;

        gsl_vector_free( ciel );
    }

int Photom::Magnitude(double flux_etoile, double flux_ref, double mag_ref, double *mag_etoile)
{
    if ((flux_etoile > 0.0) && (flux_ref > 0.0))
        *mag_etoile = mag_ref - 2.5 * log10(flux_etoile / flux_ref);
    else
        *mag_etoile = 99.99;

    return 0;
}

int Photom::Incertitude (double flux_etoile, double flux_fond, double nb_pixel, double nb_pixel_fond, double gain, double sigma, double *signal_bruit, double *incertitude, double *bruit_flux)
{
    double q1, q2, q3;

    q1 = (flux_fond + sigma * sigma) / flux_etoile;
    q2 = 1.0 + 1.0 / nb_pixel_fond;
    q3 = (nb_pixel * q1 * q2) + (1.0 / gain);
    *signal_bruit = flux_etoile / q3;
    *incertitude = 1.085 / *signal_bruit;
    *bruit_flux = flux_etoile / *signal_bruit;

    return 0;
}


int Photom::Rectangle::lecture_rectangle( gsl_vector * vect_s )
{
    TYPE_PIXELS valeur_pixel;
    int i = 0;
    int x, y;

    try {
        for ( y = ymin; y <= ymax; y++ )
        {
            for ( x = xmin; x <= xmax; x++ )
            {
                valeur_pixel = Photom::instance()->LecturePixel( x, y );
                gsl_vector_set( vect_s, i++, (double)valeur_pixel );
            }
        }
    }
    catch (const IError& e)
    {
        photom_error( e.gets() );
        photom_error( "x=" << x << " y=" << y << " xmin=" << xmin << " ymin=" << ymin << " xmax=" << xmax << " ymax=" << ymax );
        throw;
    }
    return Generique::OK;
}

#ifdef GSL_NON_LINEAIRE
/* voir commentaire en tête de fichier */
int fonction_minimale (const gsl_vector * param_gauss, void * data, gsl_vector * f) {
    int x1, y1, x2, y2, nxy;
    double * pixels;
    double x0, y0;
    double sx, sy;
    double signal, fond;
    double ro;
    int x, y, i;
    double dy, dy2, gy, dx, dx2, gx, hxy, fxy;

#ifdef TRACE_FONCTION
    FILE * trace;
    trace = fopen("trace_fonction2.txt", "a");
    fprintf (trace, "------------------------------------\n");
#endif

    nxy = ((struct data *)data)->nxy;
    x1 = ((struct data *)data)->x1;
    y1 = ((struct data *)data)->y1;
    x2 = ((struct data *)data)->x2;
    y2 = ((struct data *)data)->y2;
    pixels = ((struct data *)data)->pixels;

    x0 = gsl_vector_get (param_gauss, 0);
    y0 = gsl_vector_get (param_gauss, 1);
    signal = gsl_vector_get (param_gauss, 2);
    fond = gsl_vector_get (param_gauss, 3);
    sx = gsl_vector_get (param_gauss, 4);
    sy = gsl_vector_get (param_gauss, 5);
    ro = gsl_vector_get (param_gauss, 6);

#ifdef TRACE_FONCTION
    fprintf (trace, "X0=%g|Y0=%g|S=%g|B=%g|Sx=%g|Sy=%g|Ro=%g\n", x0, y0, signal, fond, sx, sy, ro);
#endif

    i = 0;
    for (y = y1; y <= y2; y++) {
        dy = ((double)y - y0) / sy;
        dy2 = dy * dy;
        gy = exp (-dy2);
#ifdef TRACE_FONCTION
        fprintf (trace, "y=%d   ", y);
#endif
        for (x = x1; x <= x2; x++) {
            dx = ((double)x - x0) / sx;
            dx2 = dx * dx;
            gx = exp (-dx2);
            hxy = exp (2.0 * ro * dx * dy);
            fxy = gx * gy * hxy;
            /* Vecteur à minimiser */
            gsl_vector_set (f, i, (pixels[i] - (signal * fxy + fond)));
#ifdef TRACE_FONCTION
            fprintf (trace, "%f / %f / %f   ", pixels[i], signal * fxy + fond, (pixels[i] - (signal * fxy + fond)));
#endif
            i++;
        }
        fprintf (trace, "\n");
    }
#ifdef TRACE_FONCTION
    fclose (trace);
#endif
    return GSL_SUCCESS;
}

int jacobien (const gsl_vector * param_gauss, void  * data, gsl_matrix * J) {
    int x1, y1, x2, y2, nxy;
    double x0, y0;
    double sx, sy;
    double signal, fond;
    double ro;
    int x, y, i;
    double dy, dy2, gy, dx, dx2, gx, hxy, fxy;

#ifdef TRACE_JACOBIEN
    FILE * trace;
    int j;
    trace = fopen("trace_jacobien2.txt", "a");
    fprintf (trace, "------------------------------------\n");
#endif

    nxy = ((struct data *)data)->nxy;
    x1 = ((struct data *)data)->x1;
    y1 = ((struct data *)data)->y1;
    x2 = ((struct data *)data)->x2;
    y2 = ((struct data *)data)->y2;

    x0 = gsl_vector_get (param_gauss, 0);
    y0 = gsl_vector_get (param_gauss, 1);
    signal = gsl_vector_get (param_gauss, 2);
    fond = gsl_vector_get (param_gauss, 3);
    sx = gsl_vector_get (param_gauss, 4);
    sy = gsl_vector_get (param_gauss, 5);
    ro = gsl_vector_get (param_gauss, 6);

    i = 0;
    for (y = y1; y <= y2; y++) {
        dy = ((double)y - y0) / sy;
        dy2 = dy * dy;
        gy = exp (-dy2);
        for (x = x1; x <= x2; x++) {
            dx = ((double)x - x0) / sx;
            dx2 = dx * dx;
            gx = exp (-dx2);
            hxy = exp (2.0 * ro * dx * dy);
            fxy = gx * gy * hxy;

            /* dF/dX0 */
            gsl_matrix_set (J, i, 0, (2.0 * signal * fxy * ((dx - ro * dy) / sx)));
            /* dF/dY0 */
            gsl_matrix_set (J, i, 1, (2.0 * signal * fxy * ((dy - ro * dx) / sy)));
            /* dF/dS0 */
            gsl_matrix_set (J, i, 2, fxy);
            /* dF/dB */
            gsl_matrix_set (J, i, 3, 1.0);
            /* dF/dFwhmX */
            gsl_matrix_set (J, i, 4, (2.0 * signal * fxy * ((dx2 / sx) - (ro * dx * dy / sx))));
            /* dF/dFwhmY */
            gsl_matrix_set (J, i, 5, (2.0 * signal * fxy * ((dy2 / sy) - (ro * dx * dy / sy))));
            /* dF/dRo */
            gsl_matrix_set (J, i, 6, (2.0 * signal * fxy * dx * dy));

#ifdef TRACE_JACOBIEN
            fprintf (trace, "y=%d x=%d ", y, x);
            for (j=0; j<NB_PARAM_GAUSS; j++) {
                fprintf (trace, "%f ", gsl_matrix_get (J, i, j));
            }
            fprintf (trace, "\n");
#endif
            i++;
        }
    }
#ifdef TRACE_JACOBIEN
    fclose (trace);
#endif
    return GSL_SUCCESS;
}

int nappe_gaussienne (const gsl_vector * param_gauss, void * data, gsl_vector * f, gsl_matrix * J) {
    fonction_minimale (param_gauss, data, f);
    jacobien (param_gauss, data, J);

    return GSL_SUCCESS;
}

void print_state (FILE *trace, int iter, gsl_multifit_fdfsolver * s) {
    fprintf(trace, "iter=%d X0=%f|Y0=%f|S=%f|B=%f|Sx=%f|Sy=%f|Ro=%f|chi2=%f\n",
        iter,
        gsl_vector_get (s->x, 0),
        gsl_vector_get (s->x, 1),
        gsl_vector_get (s->x, 2),
        gsl_vector_get (s->x, 3),
        gsl_vector_get (s->x, 4),
        gsl_vector_get (s->x, 5),
        gsl_vector_get (s->x, 6),
        gsl_blas_dnrm2 (s->f)
        );
    fprintf(trace, "iter=%d dX0=%f|dY0=%f|dS=%f|dB=%f|dSx=%f|dSy=%f|dRo=%f|chi2=%f\n",
        iter,
        gsl_vector_get (s->dx, 0),
        gsl_vector_get (s->dx, 1),
        gsl_vector_get (s->dx, 2),
        gsl_vector_get (s->dx, 3),
        gsl_vector_get (s->dx, 4),
        gsl_vector_get (s->dx, 5),
        gsl_vector_get (s->dx, 6),
        gsl_blas_dnrm2 (s->f));
}

/* Algorithme de modelisation par        */
/* S(x,y) = S0 * f(x,y) + B0, où         */
/* f(x,y) = exp(-X^2 - Y^2 + 2*Ro*X*Y) */
/* avec X = (x-x0)/sx                                */
/*          Y = (y-y0)/sy                                */
/*          (x0,y0) centroide                        */
/*          sx et sy ecart-types                    */
/*          |Ro| < 1                                            */
void Gauss2(int x1, int y1, int x2, int y2, gsl_vector *vect_s, gsl_vector *vect_w, gsl_matrix *mat_x, gsl_vector *vect_c, gsl_matrix *covar, double *chi2, double *me1, struct ajustement *p, struct ajustement *incert, int *iter, int *convergence)
{
    const gsl_multifit_fdfsolver_type *T;
    gsl_multifit_fdfsolver *s;
    int nxy;
    gsl_multifit_function_fdf f;
    gsl_vector *param_gauss;
    struct data d;
    int status;

#ifdef TRACE_FONCTION
    FILE * trace_fonction;
    trace_fonction = fopen("trace_fonction2.txt", "w");
    fclose (trace_fonction);
#endif

#ifdef TRACE_JACOBIEN
    FILE * trace_jacobien;
    trace_jacobien = fopen("trace_jacobien2.txt", "w");
    fclose (trace_jacobien);
#endif

    param_gauss = gsl_vector_alloc(NB_PARAM_GAUSS);
    gsl_vector_set (param_gauss, 0, p->X0);
    gsl_vector_set (param_gauss, 1, p->Y0);
    gsl_vector_set (param_gauss, 2, p->Signal);
    gsl_vector_set (param_gauss, 3, p->Fond);
    gsl_vector_set (param_gauss, 4, p->Sigma_X);
    gsl_vector_set (param_gauss, 5, p->Sigma_Y);
    gsl_vector_set (param_gauss, 6, p->Ro);

    fprintf (trace, "---------param_gauss :---------\n");
    gsl_vector_fprintf (trace, param_gauss, "%f");

    nxy = (size_t)(x2 - x1 + 1) * (size_t)(y2 - y1 + 1);
    d.nxy = nxy;
    d.x1 = x1;
    d.x2 = x2;
    d.y1 = y1;
    d.y2 = y2;
    d.pixels = vect_s->data;

    f.f = &fonction_minimale;
    f.df = &jacobien;
    f.fdf = &nappe_gaussienne;
    f.n = nxy;
    f.p = NB_PARAM_GAUSS;
    f.params = &d;

    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, nxy, NB_PARAM_GAUSS);
    if (s == 0) {
        fprintf (trace, "Mauvaise alloc\n");
        return;
    }
    status = gsl_multifit_fdfsolver_set (s, &f, param_gauss);
    fprintf (trace, "status=%d : %s\n", status, gsl_strerror (status));
    fprintf (trace, "s est un resolveur de type %s\n", gsl_multifit_fdfsolver_name (s));

    *iter = 0;
    print_state (trace, *iter, s);

    do {
        (*iter) ++;

        status = gsl_multifit_fdfsolver_iterate (s);
        fprintf (trace, "status=%d : %s\n", status, gsl_strerror (status));

        print_state (trace, (*iter), s);
        if (status) {
            break;
        }

        status = gsl_multifit_test_delta (s->dx, s->x, 0.0, 1e-6);

    } while (status == GSL_CONTINUE && (*iter) < 50);

    gsl_multifit_covar (s->J, 0.0, covar);

    gsl_multifit_fdfsolver_free (s);

    fclose(trace);
}

#endif /* GSL_NON_LINEAIRE */


/* Algorithme de modelisation par        */
/* S(x,y) = S0 * f(x,y) + B0, ou         */
/* f(x,y) = exp(-X^2 - Y^2 + 2*Ro*X*Y)   */
/* avec X = (x-x0)/sx                    */
/*          Y = (y-y0)/sy                */
/*          (x0,y0) centroide            */
/*          sx et sy ecart-types         */
/*          |Ro| < 1                     */
int Photom::Gauss( Astre & astre, gsl_vector *vect_s, gsl_vector *vect_w, gsl_matrix *mat_cov, double *me1 )
{
    Rectangle * rect = astre.rect();
    Modele * p = astre.modele();
    Modele * incert = astre.incert();

    int x = 0, y = 0;
    double dy, dy2, gy, dx, dx2, gx, hxy, fxy, pxy;
    double norme = 0;
    double chi2 = 0;
    size_t i;
    Modele t;
    int erreur;
    double ancienne_norme = 1e9;
    int convergence, iterations;
    gsl_vector *vect_y;
    gsl_vector *vect_c;
    gsl_multifit_linear_workspace *bac;
    gsl_matrix *temp_cov;
    gsl_matrix *mat_x;
    size_t nxy;

    nxy = rect->nxy;

    vect_y = gsl_vector_alloc( nxy );
    bac = gsl_multifit_linear_alloc( nxy, 7 );
    temp_cov = gsl_matrix_alloc( 7, 7 );
    mat_x = gsl_matrix_alloc( nxy, 7 );
    vect_c = gsl_vector_alloc( 7 );


    convergence = -1;
    iterations = 0;
    while ( convergence < 0 )
    {
        i = 0;
        iterations ++;
        x = rect->xmin;   /* suppression d'alerte gcc */
        for ( y = rect->ymin; y <= rect->ymax; y++ )
        {
            dy = ((double)y - p->Y0) / p->Sigma_Y;
            dy2 = dy * dy;
            gy = exp( -dy2 );
            for ( x = rect->xmin; x <= rect->xmax; x++ )
            {
                dx = ((double)x - p->X0) / p->Sigma_X;
                dx2 = dx * dx;
                gx = exp( -dx2 );
                pxy = exp( p->Ro * dx * dy );
                if ( pxy > 1e+130 )
                {
                    /* risque de dépassement de hxy (+inf) */
                    convergence = 0; /* pour bloquer la boucle */
                    iterations = Photom::ERR_DIVERGENCE; /* signale une erreur */
                    goto sortie;
                    photom_trace( "y=" << y << " / x=" << x << " / pxy=" << pxy );
                }
                hxy = pxy * pxy; /* c.a.d. hxy = exp(2.0 * p->Ro * dx * dy) */
                fxy = gx * gy * hxy;

                //photom_trace( "y=" << y << " / x=" << x << " / fonction=" << p->Signal * fxy + p->Fond << " / i=" << i << " / image=" << gsl_vector_get( vect_s, i ) );

                /* Matrice des points à faire correspondre */
                gsl_vector_set( vect_y, i, ( gsl_vector_get( vect_s, i ) - ( p->Signal * fxy + p->Fond ) ) );

                /* Matrice du modele (Jacobien) */
                /* dF/dX0 */
                gsl_matrix_set( mat_x, i, 0, ( 2.0 * p->Signal * fxy * ( ( dx - p->Ro * dy ) / p->Sigma_X ) ) );
                /* dF/dY0 */
                gsl_matrix_set( mat_x, i, 1, ( 2.0 * p->Signal * fxy * ( ( dy - p->Ro * dx ) / p->Sigma_Y ) ) );
                /* dF/dS0 */
                gsl_matrix_set( mat_x, i, 2, fxy );
                /* dF/dB */
                gsl_matrix_set( mat_x, i, 3, 1.0 );
                /* dF/dFwhmX */
                gsl_matrix_set( mat_x, i, 4, ( 2.0 * p->Signal * fxy * ( ( dx2 / p->Sigma_X ) - ( p->Ro * dx * dy / p->Sigma_X ) ) ) );
                /* dF/dFwhmY */
                gsl_matrix_set( mat_x, i, 5, ( 2.0 * p->Signal * fxy * ( ( dy2 / p->Sigma_Y ) - ( p->Ro * dx * dy / p->Sigma_Y ) ) ) );
                /* dF/dRo */
                gsl_matrix_set( mat_x, i, 6, ( 2.0 * p->Signal * fxy * dx * dy ) );

                i++;

            }
        }
        erreur = gsl_multifit_wlinear(mat_x, vect_w, vect_y, vect_c, temp_cov, &chi2, bac);
        if ( erreur)
        {
            photom_trace( "y=" << y << " / x=" << x << " / erreur=" << erreur );
            convergence = 0; /* pour bloquer la boucle */
            iterations = Photom::ERR_AJUSTEMENT; /* signale une erreur */
            goto sortie;
        }

        /*
         * Le fait de n'additionner qu'une fraction de l'erreur de modélisation retarde la convergence
         * mais assure une convergence plus monotone (moins d'oscillations sur la valeur de la norme)
         */
        t.X0 = p->X0 + gsl_vector_get( vect_c, 0 ) / 1.5;
        t.Y0 = p->Y0 + gsl_vector_get( vect_c, 1 ) / 1.5;
        t.Signal = p->Signal + gsl_vector_get( vect_c, 2 ) / 1.5;
        t.Fond = p->Fond + gsl_vector_get(  vect_c, 3 ) / 1.5;
        t.Sigma_X = p->Sigma_X + gsl_vector_get( vect_c, 4 ) / 1.5;
        t.Sigma_Y = p->Sigma_Y + gsl_vector_get( vect_c, 5 ) / 1.5;
        if ( fabs( t.Ro ) > .9 )
            t.Ro = p->Ro + ( gsl_vector_get( vect_c, 6 ) / 10.0 );
        else
            t.Ro = p->Ro + gsl_vector_get( vect_c ,6 ) / 1.5;

        norme = gsl_blas_dnrm2( vect_y );

        // photom_trace( "cX0=" << gsl_vector_get(vect_c,0) / 1.5 << " / cY0=" << gsl_vector_get(vect_c,1) / 1.5 );
        // photom_trace( "tX0=" << t.X0 << " / tY0=" << t.Y0 );

        /* Detection des cas d'arret */
        if ( (norme > ancienne_norme) || (fabs(norme - ancienne_norme) < CONDITION_ARRET_NORME) )
            convergence = 1;
        else {
            ancienne_norme = norme;

            if ((t.X0 < rect->xmin )                /* la modélisation sort du cadre entourant l'image */
                    || (t.X0 > rect->xmax )
                    || (t.Y0 < rect->ymin )
                    || (t.Y0 > rect->ymax )
                    || (t.Sigma_X < 0.25)       /* l'écart-type ne peut pas être trop petit (et encore moins negatif) */
                    || (t.Sigma_Y < 0.25)
                    || (fabs(t.Ro) > 0.985)     /* |ro| est forcément < 1 */
                    || (iterations > NOMBRE_MAX_ITERATION)            /* Convergence qui prendrait un temps "infini" */
                    || ((t.Sigma_X / t.Sigma_Y) >= 50.0)
                    || ((t.Sigma_Y / t.Sigma_X) >= 50.0))
            {
                photom_trace( "y=" << y << " / x=" << x );
                photom_trace( "t.Y0=" << t.Y0 << " / t.X0=" << t.X0 );
                photom_trace( "t.SY=" << t.Sigma_Y << " / t.SX=" << t.Sigma_X );
                photom_trace( "t.Ro=" << t.Ro << " / iterations=" << iterations );
                convergence = 1;
                iterations = Photom::ERR_DIVERGENCE;
            } else {
                p->X0 = t.X0;
                p->Y0 = t.Y0;
                p->Signal = t.Signal;
                p->Fond = t.Fond;
                p->Sigma_X = t.Sigma_X;
                p->Sigma_Y = t.Sigma_Y;
                p->Ro = t.Ro;

                gsl_matrix_memcpy( mat_cov, temp_cov );
            }
        }
    }

    *me1 = sqrt( chi2 / ( nxy - 7 ) );

    incert->X0 = *me1 * sqrt( gsl_matrix_get( mat_cov, 0, 0 ) );
    incert->Y0 = *me1 * sqrt( gsl_matrix_get( mat_cov, 1, 1 ) );
    incert->Signal = *me1 * sqrt( gsl_matrix_get( mat_cov, 2, 2 ) );
    incert->Fond = *me1 * sqrt( gsl_matrix_get( mat_cov, 3, 3 ) );
    incert->Sigma_X = *me1 * sqrt( gsl_matrix_get( mat_cov, 4, 4 ) );
    incert->Sigma_Y = *me1 * sqrt( gsl_matrix_get( mat_cov, 5, 5 ) );
    incert->Ro = *me1 * sqrt( gsl_matrix_get( mat_cov, 6, 6 ) );

sortie :
    gsl_multifit_linear_free( bac);
    gsl_vector_free( vect_y );
    gsl_matrix_free( temp_cov );
    gsl_matrix_free( mat_x );
    gsl_vector_free( vect_c );

    return iterations;
}

void Photom::Rectangle::Init( const std::vector<int> &zone ) {

    photom_info3( "zone[0]=" << zone[0] <<  " / zone[1]=" << zone[1] << " / zone[2]=" << zone[2] <<  " / zone[3]=" << zone[3] );

    /* Tri des x1, x2 et y1, y2 */
    /* Notation bizarre, car windows.h redéfinit min et max en macros */
    /* et ça plante VC++ */
    xmin = min( zone[0], zone[2] );
    xmax = max( zone[0], zone[2] );
    ymin = min( zone[1], zone[3] );
    ymax = max( zone[1], zone[3] );

    /* Quelques valeurs annexes */
    nx = xmax - xmin + 1;
    ny = ymax - ymin + 1;
    nxy = (size_t) ( nx * ny );

    photom_info3( "xmin=" << xmin <<  " / ymin=" << ymin << " / xmax=" << xmax <<  " / ymin=" << ymin );
 }

/**************************************************************/
/* Ajustement d'un morceau d'image par une surface gaussienne */
/* Calcul du flux donne par le modèle                         */
/**************************************************************/
int Photom::AjustementGaussien( Astre & astre, std::vector<double> fgauss, std::vector<double> stat, double *erreur )
{
    Rectangle * rect = astre.rect();
    Modele * modele = astre.modele();
    Modele * incertitudes = astre.incert();

    double sx, sx2, sy, sy2, alpha2, alpha, p, q, sxp, syp, ro;
    double dro, dsx, dsy, a, b, c, da, db, dc, temp_a, dalpha_da, dalpha_db, dalpha_dc, dalpha;
    gsl_vector *vect_w, *vect_s;
    gsl_matrix *mat_cov;
    int iterations;

    if ( rect->nxy <= 7 )
    {
        /*
        Par définition, le nombre d'échantillons doit être au moins égal au nombre de paramètres du modèle (7 en l'occurence)
         */
        iterations = Photom::ERR_FATALE;
        throw LibJM::Erreur( "Not enough pixels for fitting (8 is the minimum)" );
    }

    /* Creation des objets gsl */
    vect_w = gsl_vector_alloc( rect->nxy );
    vect_s = gsl_vector_alloc( rect->nxy );
    mat_cov = gsl_matrix_alloc( 7, 7 );


    /* Valeurs pour l'initialisation de la boucle de calcul */
    /* Fond = fond */
    modele->Fond = ( fgauss[3] + fgauss[7] ) / 2.0;
    /* Signal = max - fond */
    modele->Signal = (double)( fgauss[0] + fgauss[4] ) / 2.0;


    /* Centre potentiel */
    /*
    * Si fitgauss retourne un centroide trop desaxé par rapport à la fenêtre
    * (dans le 1er ou le dernier quart), la valeur de départ sera le bête centre de la fenêtre
    */
    if ( ( fgauss[1] < ( 3 * rect->xmin + rect->xmax ) / 4 ) || ( fgauss[1] > ( rect->xmin + 3 * rect->xmax ) / 4 ) ) {
        modele->X0 = ( rect->xmin + rect->xmax ) / 2;
    }
    else {
        modele->X0 = fgauss[1];
    }

    if ( ( fgauss[5] < ( 3 * rect->ymin + rect->ymax ) / 4 ) || ( fgauss[5] > ( rect->ymin + 3 * rect->ymax ) / 4 ) ) {
        modele->Y0 = ( rect->ymin + rect->ymax ) / 2;
    }
    else {
        modele->Y0 = fgauss[5];
    }

    /* Les FWHM doivent être convertis en sigma*/
    modele->Sigma_X = Divers::fwhm_en_sigma( fgauss[2] );
    modele->Sigma_Y = Divers::fwhm_en_sigma( fgauss[6] );

    /* Lecture du rectangle et */
    /* stockage des valeurs des pixels dans le vecteur s */
    try
    {
        rect->lecture_rectangle( vect_s );
    }
    catch ( const IError& e )
    {
        photom_error( e.gets() );
        iterations = Photom::ERR_FATALE;
        gsl_matrix_free( mat_cov );
        gsl_vector_free( vect_s );
        gsl_vector_free( vect_w );
        throw;
    }

    /* Au hasard */
    modele->Ro = 0.0;

    photom_debug( "Avant : X0=" << modele->X0 << " / Y0=" << modele->Y0 );
    photom_debug( "Avant : Sx=" << modele->Sigma_X << " / Sy=" << modele->Sigma_Y << " / Ro=" << modele->Ro );
    photom_debug( "Avant : Signal=" << modele->Signal << " / Fond=" << modele->Fond );
    photom_debug( "Avant : Pondération=" << 1.0 / stat[7] / stat[7] );

    /* Initialisations du vecteur de pondération */
    if ( stat[7] != 0.0 )
        gsl_vector_set_all( vect_w, 1.0 / stat[7] / stat[7] );
    else
        gsl_vector_set_all( vect_w, 1.0 );

    /* Cas d'une image constante : on sort tout de suite, la modélisation n'a pas de sens */
    if ( modele->Signal == 0 ) {
        iterations = Photom::ERR_FATALE;
        gsl_matrix_free( mat_cov );
        gsl_vector_free( vect_s );
        gsl_vector_free( vect_w );
        throw LibJM::Erreur("No star can be detected");
    }

    /* Modélisation */
    iterations = Gauss( astre, vect_s, vect_w, mat_cov, erreur );
    if ( iterations < 0 ) {
        iterations = Photom::ERR_MODELISATION;
        gsl_matrix_free( mat_cov );
        gsl_vector_free( vect_s );
        gsl_vector_free( vect_w );
        throw LibJM::Erreur("Fitting error");
    }

    photom_debug( "Après : X0=" << modele->X0 << " / Y0=" << modele->Y0 );
    photom_debug( "Après : Sx=" << modele->Sigma_X << " / Sy=" << modele->Sigma_Y << " / Ro=" << modele->Ro );
    photom_debug( "Après : Signal=" << modele->Signal << " / Fond=" << modele->Fond );
    photom_debug( "Après : Pondération=" << 1.0 / stat[7] / stat[7] );

    /* Calcul du flux */
    modele->Flux = M_PI * modele->Signal * modele->Sigma_X * modele->Sigma_Y / sqrt( 1.0 - ( modele->Ro * modele->Ro ) );
    photom_debug( "Flux=" << modele->Flux );

    /* Manips pour simplifier l'écriture des calculs */
    sx = modele->Sigma_X;
    sy = modele->Sigma_Y;
    ro = modele->Ro;
    sx2 = sx * sx;
    sy2 = sy * sy;
    a = 1.0 / sx2;
    c = 1.0 / sy2;
    b = -ro / sx / sy;
    dsx = incertitudes->Sigma_X;
    dsy = incertitudes->Sigma_Y;
    dro = incertitudes->Ro;
    da = fabs( -2.0 * dsx / sx / sx / sx );
    dc = fabs( -2.0 * dsy / sy / sy / sy );
    db = fabs( ( - dro / sx / sy )
        + ( dsx * ro / sx2 / sy )
        + ( dsy * ro / sx / sy2 ) );

    /* Calcul des valeurs principales et de leur incertitudes*/
    if ( sx != sy ) {
        alpha2 = atan2( ( 2.0 * ro * sx * sy ), ( sx2 - sy2 ) );
        p = a + c;
        q = ( a - c ) * cos( alpha2 ) + ( 2.0 * b * sin( alpha2 ) );
        /* Valeur principale */
        alpha = alpha2 / 2.0;
        sxp = 1.0 / sqrt( ( p + q ) / 2.0 );
        syp = 1.0 / sqrt( ( p - q ) / 2.0 );
        /* Pour alpha */
        temp_a = ( a - c ) * ( a - c ) + ( 4 * b * b );
        dalpha_da = fabs( -b / temp_a );
        dalpha_dc = dalpha_da;
        dalpha_db = fabs( ( a - c ) / temp_a );
        dalpha = ( dalpha_da * da )
            + ( dalpha_dc * dc )
            + ( dalpha_db * db );
    }
    else {
        /* Valeur principale */
        alpha = 0; /* en fait alpha n'a pas de sens, puisqu'il s'agit d'un cercle parfait */
        sxp = sx;
        syp = sy;
        /* Pour alpha */
        dalpha = 0;
    }
    /* Pour le flux */
    incertitudes->Flux = ( modele->Flux / modele->Signal ) * incertitudes->Signal +
    ( modele->Flux / modele->Sigma_X ) * incertitudes->Sigma_X +
    ( modele->Flux / modele->Sigma_Y ) * incertitudes->Sigma_Y +
    ( modele->Flux * modele->Ro / ( 1.0 - modele->Ro * modele->Ro ) ) * incertitudes->Ro;
    modele->Sigma_1 = sxp;
    modele->Sigma_2 = syp;
    incertitudes->Sigma_1 = incertitudes->Sigma_X * modele->Sigma_1 / modele->Sigma_X;
    incertitudes->Sigma_2 = incertitudes->Sigma_Y * modele->Sigma_2 / modele->Sigma_Y;

    /* Conversion en degres */
    modele->Alpha = 57.29578 * alpha;
    incertitudes->Alpha = 57.29578 * dalpha;

    gsl_matrix_free( mat_cov );
    gsl_vector_free( vect_s );
    gsl_vector_free( vect_w );

    return iterations;
}


int Photom::SoustractionGaussienne( Astre & astre )
{
    TYPE_PIXELS valeur_pixel;
    Rectangle *r = astre.rect();
    Modele * p = astre.modele();

    try
    {
        for ( int y = r->ymin; y <= r->ymax; y++) {
            double dy = ((double)y - p->Y0) / p->Sigma_Y;
            double dy2 = dy * dy;
            double gy = exp( -dy2 );
            for (int x = r->xmin; x <= r->xmax; x++)
            {
                double dx = ((double)x - p->X0) / p->Sigma_X;
                double dx2 = dx * dx;
                double gx = exp( -dx2 );
                double hxy = exp( 2.0 * p->Ro * dx * dy );
                double fxy = gx * gy * hxy;
                /* On calcule la gaussienne, mais on ne tient pas compte du fond de ciel ! */
                int gaussienne = (int)( p->Signal * fxy + 0.5 ); // Arrondi

                valeur_pixel = LecturePixel( x, y );
                valeur_pixel -= gaussienne;
                if ( valeur_pixel < 0 )
                    valeur_pixel = 0;
                EcriturePixel( x, y, valeur_pixel );
            }
        }
    }
    catch ( const IError& e )
    {
        photom_error( e.gets() );
        photom_error( "xmin=" << r->xmin << " ymin=" << r->ymin << " xmax=" << r->xmax << " ymax=" << r->ymax );
        throw;
    }
    return 0;
}

}
