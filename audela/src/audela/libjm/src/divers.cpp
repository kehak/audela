/***
 * @file : divers.cpp
 * @brief : routines d'usage général
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: divers.cpp,v 1.3 2010-05-26 12:00:17 jacquesmichelet Exp $
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

#include <vector>

#include <sysexp.h>
#include <stdlib.h>

#include "libjm.h"
#include "divers.h"

namespace LibJM {
/* ***************** dms2deg *******************
 * dms2deg
 * Convertie un angle en degrés/minutes/secondes
 * en degrés décimaux
 * *********************************************/
int Divers::dms2deg(int d,int m,double s,double *angle)
{
    *angle=((s/60.0+(double)m)/60)+(double)d;
    return Generique::OK;
}

std::vector<double> Divers::DecodeListeDouble( Tcl_Interp *interp, const char *list )
{
    const char **argv;
    int argc, k;

    argv = NULL;
    Tcl_SplitList(interp, list, &argc, &argv);
    std::vector<double> v( argc, 0.0 );
    for ( k = 0; k < argc; ++k )
        v[k] = atof( argv[k] );
    return v;
}

std::vector<int> Divers::DecodeListeInt( Tcl_Interp *interp, char *list )
{
    const char **argv;
    int argc, k;

    argv = NULL;
    Tcl_SplitList( interp, list, &argc, &argv );
    std::vector<int> v( argc, 0 );
    for ( k = 0; k < argc; ++k )
        v[k] = atoi( argv[k] );
    return v;
}


}





