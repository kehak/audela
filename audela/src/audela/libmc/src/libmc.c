/* libmc.c
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

#include "libmc.h"

#ifdef LIBRARY_DLL
   int __cdecl Mc_Init(Tcl_Interp *interp)
#endif

#ifdef LIBRARY_SO
   int Mc_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      return TCL_ERROR;
   }

   /*--- Si les deux dlls ont bien ete chargees, alors on enregistre un */
   /*--- ensemble de fonctions qui seront disponibles depuis l'interpreteur */
   /*--- TCL, de la meme maniere que toutes les autres fonctions TCL. */
   Tcl_CreateCommand(interp,"mc_angle2deg",(Tcl_CmdProc *)Cmd_mctcl_angle2deg,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_angle2rad",(Tcl_CmdProc *)Cmd_mctcl_angle2rad,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_angle2dms",(Tcl_CmdProc *)Cmd_mctcl_angle2dms,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_angle2hms",(Tcl_CmdProc *)Cmd_mctcl_angle2hms,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_angle2lx200ra",(Tcl_CmdProc *)Cmd_mctcl_angle2lx200ra,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_angle2lx200dec",(Tcl_CmdProc *)Cmd_mctcl_angle2lx200dec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_angles2nexstar",(Tcl_CmdProc *)Cmd_mctcl_angles2nexstar,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_nexstar2angles",(Tcl_CmdProc *)Cmd_mctcl_nexstar2angles,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_anglescomp",(Tcl_CmdProc *)Cmd_mctcl_anglescomp,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_anglesep",(Tcl_CmdProc *)Cmd_mctcl_anglesep,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_date2jd",(Tcl_CmdProc *)Cmd_mctcl_date2jd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_date2iso8601",(Tcl_CmdProc *)Cmd_mctcl_date2iso8601,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_date2ymdhms",(Tcl_CmdProc *)Cmd_mctcl_jd2date,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_date2lst",(Tcl_CmdProc *)Cmd_mctcl_date2lst,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_datescomp",(Tcl_CmdProc *)Cmd_mctcl_datescomp,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_dms2deg",(Tcl_CmdProc *)Cmd_mctcl_dms2deg,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_hms2deg",(Tcl_CmdProc *)Cmd_mctcl_hms2deg,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_deg2dms",(Tcl_CmdProc *)Cmd_mctcl_deg2dms,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_deg2hms",(Tcl_CmdProc *)Cmd_mctcl_deg2hms,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_date2listdates",(Tcl_CmdProc *)Cmd_mctcl_date2listdates,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_ephem",(Tcl_CmdProc *)Cmd_mctcl_ephem,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_readcat",(Tcl_CmdProc *)Cmd_mctcl_readcat,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_buf2field",(Tcl_CmdProc *)Cmd_mctcl_paramastrom,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_xy2radec",(Tcl_CmdProc *)Cmd_mctcl_xy2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_radec2xy",(Tcl_CmdProc *)Cmd_mctcl_radec2xy,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_listradec",(Tcl_CmdProc *)Cmd_mctcl_listradec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_sepangle",(Tcl_CmdProc *)Cmd_mctcl_sepangle,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_radec2altaz",(Tcl_CmdProc *)Cmd_mctcl_radec2altaz,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_hadec2altaz",(Tcl_CmdProc *)Cmd_mctcl_hadec2altaz,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_altaz2hadec",(Tcl_CmdProc *)Cmd_mctcl_altaz2hadec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_altaz2radec",(Tcl_CmdProc *)Cmd_mctcl_altaz2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_radec2altalt",(Tcl_CmdProc *)Cmd_mctcl_radec2altalt,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_hadec2altalt",(Tcl_CmdProc *)Cmd_mctcl_hadec2altalt,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_altalt2hadec",(Tcl_CmdProc *)Cmd_mctcl_altalt2hadec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_altalt2radec",(Tcl_CmdProc *)Cmd_mctcl_altalt2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_refraction",(Tcl_CmdProc *)Cmd_mctcl_refraction,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_refraction_difradec",(Tcl_CmdProc *)Cmd_mctcl_refraction_difradec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_precessradec",(Tcl_CmdProc *)Cmd_mctcl_precessradec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);	 
   Tcl_CreateCommand(interp,"mc_nutationradec",(Tcl_CmdProc *)Cmd_mctcl_nutationradec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);	 
   Tcl_CreateCommand(interp,"mc_aberrationradec",(Tcl_CmdProc *)Cmd_mctcl_aberrationradec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);	 
   Tcl_CreateCommand(interp,"mc_parallaxradec",(Tcl_CmdProc *)Cmd_mctcl_annualparallaxradec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);	 
   Tcl_CreateCommand(interp,"mc_home2gps",(Tcl_CmdProc *)Cmd_mctcl_home2gps,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_home2mpc",(Tcl_CmdProc *)Cmd_mctcl_home2mpc,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_home2geosys",(Tcl_CmdProc *)Cmd_mctcl_home2geosys,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_homecep",(Tcl_CmdProc *)Cmd_mctcl_home_cep,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_menu",(Tcl_CmdProc *)Cmd_mctcl_menu,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_libration",(Tcl_CmdProc *)Cmd_mctcl_libration,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_baryvel",(Tcl_CmdProc *)Cmd_mctcl_baryvel,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_rvcor",(Tcl_CmdProc *)Cmd_mctcl_rvcor,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"mc_radec2galactic",(Tcl_CmdProc *)Cmd_mctcl_radec2galactic,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_galactic2radec",(Tcl_CmdProc *)Cmd_mctcl_galactic2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_radec2ecliptic",(Tcl_CmdProc *)Cmd_mctcl_radec2ecliptic,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_ecliptic2radec",(Tcl_CmdProc *)Cmd_mctcl_ecliptic2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_xy2lonlat",(Tcl_CmdProc *)Cmd_mctcl_xy2lonlat,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_lonlat2xy",(Tcl_CmdProc *)Cmd_mctcl_lonlat2xy,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_date2tt",(Tcl_CmdProc *)Cmd_mctcl_date2tt,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_tle2ephem",(Tcl_CmdProc *)Cmd_mctcl_tle2ephem,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_earthshadow",(Tcl_CmdProc *)Cmd_mctcl_earthshadow,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_tle2ephem2",(Tcl_CmdProc *)Cmd_mctcl_tle2ephem2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_tle2xyz",(Tcl_CmdProc *)Cmd_mctcl_tle2xyz,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_tt2bary",(Tcl_CmdProc *)Cmd_mctcl_tt2bary,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_tt2helio",(Tcl_CmdProc *)Cmd_mctcl_tt2helio,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_dates_ut2bary",(Tcl_CmdProc *)Cmd_mctcl_dates_ut2bary,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_simurelief",(Tcl_CmdProc *)Cmd_mctcl_simurelief,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_simurelieffromstl",(Tcl_CmdProc *)Cmd_mctcl_simurelief_from_stl,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_simulc",(Tcl_CmdProc *)Cmd_mctcl_simulc,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_simulcbin",(Tcl_CmdProc *)Cmd_mctcl_simulcbin,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_simulc_sat_stl",(Tcl_CmdProc *)Cmd_mctcl_simulc_sat_stl,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_simumagbin",(Tcl_CmdProc *)Cmd_mctcl_simumagbin,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_optiparamlc",(Tcl_CmdProc *)Cmd_mctcl_optiparamlc,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_lightmap",(Tcl_CmdProc *)Cmd_mctcl_lightmap,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_meo",(Tcl_CmdProc *)Cmd_mctcl_meo,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_date2ttutc",(Tcl_CmdProc *)Cmd_mctcl_date2ttutc,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_astrology",(Tcl_CmdProc *)Cmd_mctcl_astrology,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_scheduler",(Tcl_CmdProc *)Cmd_mctcl_scheduler,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_obsconditions",(Tcl_CmdProc *)Cmd_mctcl_obsconditions,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_readhip",(Tcl_CmdProc *)Cmd_mctcl_readhip,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_nearesthip",(Tcl_CmdProc *)Cmd_mctcl_nearesthip,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_hip2tel",(Tcl_CmdProc *)Cmd_mctcl_hip2tel,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_tel2cat",(Tcl_CmdProc *)Cmd_mctcl_tel2cat,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_listamers",(Tcl_CmdProc *)Cmd_mctcl_listamers,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_horizon",(Tcl_CmdProc *)Cmd_mctcl_horizon,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_compute_matrix_modpoi",(Tcl_CmdProc *)Cmd_mctcl_compute_matrix_modpoi,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_nextnight",(Tcl_CmdProc *)Cmd_mctcl_nextnight,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_nutation",(Tcl_CmdProc *)Cmd_mctcl_nutation,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_cosmology_calculator",(Tcl_CmdProc *)Cmd_mctcl_cosmology_calculator,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_date2equinox",(Tcl_CmdProc *)Cmd_mctcl_date2equinox,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"mc_altitude2tp",(Tcl_CmdProc *)Cmd_mctcl_altitude2tp,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

   Tcl_PkgProvide(interp,"libmc","1.0");

   /*--- La fonction Mc_Init renvoie soir TCL_OK, soit TCL_ERROR. */
   /*--- donc on stoque un message d'erreur dans le resultat de l'*/
   /*--- interpreteur.											  */

   return TCL_OK;
}
