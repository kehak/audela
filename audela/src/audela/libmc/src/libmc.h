/* libmc.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 * 
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
 */

#include "mc.h"

#define LIBMC_MOSAIC_FREE 1
#define LIBMC_MOSAIC_ROLLRIGHT 2
#define LIBMC_MOSAIC_ROLLDIAG 3
#define LIBMC_MOSAIC_NAXIS1 4
#define LIBMC_MOSAIC_NAXIS2 5
#define LIBMC_MOSAIC_RANDOM 6

#ifdef LIBRARY_DLL
# include <windows.h>
#endif

#ifdef OS_WIN_BORL_DLL
# include "tcl.h"
# include "tk.h"
#endif

#ifdef OS_WIN_VCPP_DLL
# include "tcl.h"
# include "tk.h"
#endif

#ifdef LIBRARY_SO
# include <tcl.h>
# include <errno.h>
#endif




/* fonctions mc propres a libmc pour Tcl */
 int mctcl_decode_angle(Tcl_Interp *interp, char *argv0,double *angledeg);
 int mctcl_decode_date(Tcl_Interp *interp, char *argv,double *jj);
 int mctcl_decode_planet(Tcl_Interp *interp, char *argv0,int *planetnum, char *planetname, char *orbitformat, char *orbitstring);
 int mctcl_decode_topo(Tcl_Interp *interp, char *argv0,double *longmpc, double *rhocosphip,double *rhosinphip);
 int mctcl_util_getkey_astrometry(Tcl_Interp *interp,int numbuf,mc_ASTROM *p_ast);
 int mctcl_util_getkey0_astrometry(Tcl_Interp *interp,int numbuf,mc_ASTROM *p_ast,int *valid);
 int mctcl_listfield2mc_astrom(Tcl_Interp *interp, char *listfield, mc_ASTROM *p);
 int mctcl_decode_home(Tcl_Interp *interp, char *argv0,double *longitude ,char *sens, double *latitude, double *altitude, double *longmpc, double *rhocosphip,double *rhosinphip);
 int mctcl_decode_horizon(Tcl_Interp *interp, char *argv_home,char *argv_type,char *argv_coords,mc_HORIZON_LIMITS limits,Tcl_DString *pdsptr,double dh_samp,mc_HORIZON_ALTAZ **phorizon_altaz,mc_HORIZON_HADEC **phorizon_hadec);
 int mctcl_decode_sequences(Tcl_Interp *interp, char *argv[],int *nobjects, mc_OBJECTDESCR **pobjectdescr);
 int mctcl_horizon_init(Tcl_Interp *interp,int argc, char *argv[], mc_HORIZON_LIMITS *limit,char *type_amers, char *list_amers);

 int mctcl_debug(char *filename,char *type,char *string);

/*--- Fonctions appelables depuis un interpreteur TCL */
/*--- Les prototypes sont tous les memes */
 int Cmd_mctcl_angle2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_angle2lx200dec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_angle2lx200ra(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_angle2hms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_angle2dms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_angle2rad(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_angles2nexstar(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_nexstar2angles(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_dms2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_hms2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_deg2dms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_deg2hms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_anglesep(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_sepangle(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_anglescomp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_date2jd(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_date2iso8601(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_date2lst(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_date2listdates(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_date2tt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_tt2bary(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_tt2helio(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_dates_ut2bary(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_date2ttutc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_date2equinox(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_jd2date(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_datescomp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_obsreq(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_scheduler(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_obsconditions(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_home2gps(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_home2mpc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_home2geosys(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_home_cep(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_ephem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_tle2ephem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_earthshadow(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_tle2ephem2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_tle2xyz(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_readcat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_paramastrom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_xy2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_radec2xy(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_radec2altaz(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_hadec2altaz(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_altaz2hadec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_altaz2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_refraction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_refraction_difradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_radec2galactic(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_galactic2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_radec2ecliptic(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_ecliptic2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_radec2altalt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_hadec2altalt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_altalt2hadec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_altalt2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_nutation(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_precessradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_nutationradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_aberrationradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_annualparallaxradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_listradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_menu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_libration(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_baryvel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_rvcor(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_xy2lonlat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_lonlat2xy(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_simurelief(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_simurelief_from_stl(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_simulc_sat_stl(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_simulc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_simulcbin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_simumagbin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_optiparamlc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_lightmap(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_meo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_astrology(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_readhip(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_nearesthip(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_hip2tel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_tel2cat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_listamers(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_horizon(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_compute_matrix_modpoi(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_nextnight(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

 int Cmd_mctcl_cosmology_calculator(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
 int Cmd_mctcl_altitude2tp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/*--- Point d'entree de la DLL */
#ifdef LIBRARY_DLL
   __declspec(dllexport) int __cdecl Mc_Init(Tcl_Interp *interp);
#endif 

#ifdef LIBRARY_SO
   int Mc_Init(Tcl_Interp *interp);
#endif
