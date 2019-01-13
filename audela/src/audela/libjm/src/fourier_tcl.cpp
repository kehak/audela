/***
 * @file : fourier_tcl.cpp
 * @brief : interface TCL<->C pour les transformations d'images basées sur la TFD
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: fourier_tcl.cpp,v 1.5 2010-07-22 18:54:35 jacquesmichelet Exp $
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
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_fft.h>

#include <libaudela.h>
#include "libjm.h"
#include "fourier.h"

namespace LibJM {


int Fourier::CmdNiveauTraces( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
{
    char s[200];
    if (argc < 2)
    {
        sprintf( s, "Usage: %s niveau (0=deaf, ..., 9=very verbose)", argv[0] );
        Tcl_SetResult( interp, s, TCL_VOLATILE );
        return TCL_ERROR;
    }
    Fourier::instance()->niveau_traces( atoi( argv[1] ) );
    return TCL_OK;
}


int Fourier::CmdFourierDirect( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
/************************************************************/
/* Calcul de la transformée de Fourier discrète d'une image */
/************************************************************/
{
    char s[200];
    Fourier::format fourier_format = Fourier::POLAR;
    Fourier::Ordre fourier_ordre = Fourier::CENTERED;

    for ( int i = 0; i < argc; i++ )
        fourier_notice( "argv[" << i << "]=" << argv[i]);

    if (argc < 4)
    {
        sprintf( s, "Usage: %s image out_spectrum out_phase ?[polar|cartesian]? ?[regular|centered]?", argv[0] );
        Tcl_SetResult( interp, s, TCL_VOLATILE );
        return TCL_ERROR;
    }

    if ( argc >= 5 )
    {
        if ( strcmp( argv[4], "polar") == 0 )
            fourier_format = Fourier::POLAR;
        else if ( strcmp( argv[4], "cartesian") == 0 )
            fourier_format = Fourier::CARTESIAN;
        else
        {
            sprintf( s, "Illegal parameter : should be \"cartesian\" or \"polar\" ");
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
   }

    if ( argc >= 6 )
    {
        if ( strcmp( argv[5], "centered") == 0 )
            fourier_ordre = Fourier::CENTERED;
        else if ( strcmp( argv[5], "regular") == 0 )
            fourier_ordre = Fourier::REGULAR;
        else
        {
            sprintf( s, "Illegal parameter : should be \"centered\" or \"regular\" ");
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
    }

    try
    {
        Fourier::instance()->tfd_directe_image( argv[1], argv[2], argv[3], fourier_format, fourier_ordre );
    }
    catch( const IError& e )
    {
        Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
        return TCL_ERROR;
    }
    catch(...)
    {

#ifndef __FUNCTION__
#define __FUNCTION__ "unknown"
#endif
         sprintf(s, "Non catched exception in file %s, function %s at line %d", __FILE__, __FUNCTION__, __LINE__);
        Tcl_SetResult(interp, s, TCL_VOLATILE);
        return TCL_ERROR;
    }

    return TCL_OK;
}

/********************************************************************/
/* Calcul de la transformée de Fourier discrète inverse d'une image */
/********************************************************************/
int Fourier::CmdFourierInverse( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
{
    char s[200];

    if ( argc < 4 ) {
        sprintf( s, "Usage: %s in_spectrum in_phase out_image", argv[0] );
        Tcl_SetResult( interp, s, TCL_VOLATILE );
        return TCL_ERROR;
    }

    try
    {
        Fourier::instance()->tfd_inverse_image( argv[1], argv[2], argv[3] );
    }
    catch ( const IError& e )
    {
        Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
        return TCL_ERROR;
    }
    catch(...)
    {
        sprintf(s, "Non catched exception in file %s, function %s at line %d", __FILE__, __FUNCTION__, __LINE__);
        Tcl_SetResult(interp, s, TCL_VOLATILE);
        return TCL_ERROR;
    }

    return TCL_OK;
}


int Fourier::CmdAutoCorrelation( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
/********************************************************************************/
/* Calcul de l'autocorrelation d'une image par le théorème de Wiener-Khintchine */
/********************************************************************************/
{
    char s[200];
    Fourier::Ordre fourier_ordre = Fourier::CENTERED;
    bool normalisation = true;

    for ( int i = 0; i < argc; i++ )
        fourier_notice( "argv[" << i << "]=" << argv[i]);

    if ( argc < 3 )
    {
        sprintf( s, "Usage: %s in_image out_image [centered | regular [norm | denorm]]", argv[0] );
        Tcl_SetResult( interp, s, TCL_VOLATILE );
        return TCL_ERROR;
    }

    if ( argc >= 4 )
    {
        if ( strcmp( argv[3], "centered") == 0 )
            fourier_ordre = Fourier::CENTERED;
        else if ( strcmp( argv[3], "regular") == 0 )
            fourier_ordre = Fourier::REGULAR;
        else
        {
            sprintf( s, "Illegal parameter : should be \"centered\" or \"regular\" ");
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
    }

    if ( argc >= 5 )
    {
        if ( strcmp( argv[4], "denorm") == 0 )
            normalisation = false;
        else if ( strcmp( argv[4], "norm") == 0 )
            normalisation = true;
        else
        {
            sprintf( s, "Illegal parameter : should be \"norm\" or \"denorm\" ");
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
    }

    try
    {
        Fourier::instance()->correl_convol_image( argv[1], 0, argv[2], Fourier::CORRELATION, fourier_ordre, normalisation);
    }
    catch ( const IError& e )
    {
        Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
        return TCL_ERROR;
    }
    catch(...)
    {
        sprintf(s, "Non catched exception in file %s, function %s at line %d", __FILE__, __FUNCTION__, __LINE__);
        Tcl_SetResult(interp, s, TCL_VOLATILE);
        return TCL_ERROR;
    }

    return TCL_OK;
}

/******************************************************************************/
/* Calcul de l'intercorrelation de 2 images par le produit conjugué des 2 TFD */
/******************************************************************************/
int Fourier::CmdInterCorrelation( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
{
    char s[200];
    Fourier::Ordre fourier_ordre = Fourier::CENTERED;
    bool normalisation = true;

    for ( int i = 0; i < argc; i++ )
        fourier_notice( "argv[" << i << "]=" << argv[i]);

    if ( argc < 4 )
    {
        sprintf( s, "Usage: %s in_image_1 in_image_2 out_image [centered | regular [norm | denorm]]", argv[0] );
        Tcl_SetResult( interp, s, TCL_VOLATILE );
        return TCL_ERROR;
    }

    if ( argc >= 5 )
    {
        if ( strcmp( argv[4], "centered") == 0 )
            fourier_ordre = Fourier::CENTERED;
        else if ( strcmp( argv[4], "regular") == 0 )
            fourier_ordre = Fourier::REGULAR;
        else
        {
            sprintf( s, "Illegal parameter : should be \"centered\" or \"regular\" ");
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
    }

    if ( argc >= 6 )
    {
        if ( strcmp( argv[5], "denorm") == 0 )
            normalisation = false;
        else if ( strcmp( argv[5], "norm") == 0 )
            normalisation = true;
        else
        {
            sprintf( s, "Illegal parameter : should be \"norm\" or \"denorm\" ");
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
    }

    try
    {
        Fourier::instance()->correl_convol_image( argv[1], argv[2], argv[3], Fourier::CORRELATION, fourier_ordre, normalisation);
    }
    catch ( const IError& e )
    {
        Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
        return TCL_ERROR;
    }
    catch(...)
    {
        sprintf(s, "Non catched exception in file %s, function %s at line %d", __FILE__, __FUNCTION__, __LINE__);
        Tcl_SetResult(interp, s, TCL_VOLATILE);
        return TCL_ERROR;
    }

    return TCL_OK;
}

int Fourier::CmdConvolution( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] )
/***************************************************************/
/* Calcul de la convolution de 2 images par le produit des TFD */
/***************************************************************/
{
    char s[200];
    bool normalisation = true;

    for ( int i = 0; i < argc; i++ )
        fourier_notice( "argv[" << i << "]=" << argv[i]);

    if (argc < 4) {
        sprintf( s, "Usage: %s in_image1 in_image2 out_image [norm | denorm]", argv[0] );
        Tcl_SetResult( interp, s, TCL_VOLATILE );
        return TCL_ERROR;
    }

    if ( argc >= 5 )
    {
        if ( strcmp( argv[4], "denorm") == 0 )
            normalisation = false;
        else if ( strcmp( argv[4], "norm") == 0 )
            normalisation = true;
        else
        {
            sprintf( s, "Illegal parameter : should be \"norm\" or \"denorm\" ");
            Tcl_SetResult( interp, s, TCL_VOLATILE );
            return TCL_ERROR;
        }
    }

    try
    {
        Fourier::instance()->correl_convol_image( argv[1], argv[2], argv[3], Fourier::CONVOLUTION, Fourier::REGULAR, normalisation );
    }
    catch ( const IError& e )
    {
        Tcl_SetResult( interp, (char*)e.gets(), TCL_VOLATILE );
        return TCL_ERROR;
    }
    catch(...)
    {
        sprintf(s, "Non catched exception in file %s, function %s at line %d", __FILE__, __FUNCTION__, __LINE__);
        Tcl_SetResult(interp, s, TCL_VOLATILE);
        return TCL_ERROR;
    }

    return TCL_OK;
}

}
