/***
 * @file : horloge.h
 * @brief : gestion de l'horloge système
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
  *
 * Mise à jour $Id: horloge.h,v 1.4 2010-06-20 12:18:20 jacquesmichelet Exp $
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
#ifndef __LIBJM_HORLOGE_H__
#define __LIBJM_HORLOGE_H__

namespace LibJM {
class Horloge
{
public :
    static int LitHeurePC (int *annee, int *mois, int *jour, int *heure, int *minute, int *seconde, int *milli);
    static int EcritHeurePC (int annee, int mois, int jour, int heure, int minute, int seconde, int milli);
    static int ReglageHeurePC (long *decalage_reel, long decalage);
    static int Magnitude (double flux_etoile, double flux_ref, double mag_ref, double *mag_etoile);

    static int CmdHeurePC(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    static int CmdReglageHeurePC(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
    static int jd( int annee,int mois,double jour,double *jj );
    static int jc (int *annee, int *mois, double *jour, double jj);

};
}

#endif //__LIBJM_HORLOGE_H__
