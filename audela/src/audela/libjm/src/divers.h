/***
 * @file : divers.h
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: divers.h,v 1.3 2010-05-26 12:00:17 jacquesmichelet Exp $
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

#ifndef __LIBJM_DIVERS_H__
#define __LIBJM_DIVERS_H__

namespace LibJM
{

class Divers
{
public :
    static int CmdDms2deg(ClientData clientData,Tcl_Interp *interp, int argc,char *argv[]);

    static std::vector<int> DecodeListeInt( Tcl_Interp *interp, char *list );
    static std::vector<double> DecodeListeDouble(Tcl_Interp *interp, const char *list );
    static int CmdInitTamponImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    static int CmdInfoImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    static int dms2deg(int d,int m,double s,double *angle);
    static int sgn( double x ) { if ( x > 0.0 ) return(1); else return(-1); }
    // 2 * sqrt(ln(2) = 1.665109222
    static double sigma_en_fwhm( double sigma ) { return 1.66510922 * sigma; }
    // 1 / (2 * sqrt(ln(2)) = 0.600561204
    static double fwhm_en_sigma( double fwhm ) { return 0.600561204 * fwhm; }
};

}

#endif //__LIBJM_DIVERS_H__
