/* libak.c
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

/***************************************************************************/
/* Ce fichier contient                                                     */
/* - le fichier d'include libak.h specifique pour l'interfacage C/Tcl      */
/* - le point d'entree de la librairie                                     */
/* - l'initialisation la librairie                                         */
/***************************************************************************/
/* Note : Sous Windows, il faut specifier la facon de faire pour charger   */
/*        les fichiers tcl.dll et tk.dll de facon dynamique.               */
/*        Sous Linux, on suppose que Tcl/Tk a ete installe sur le systeme  */
/*        et le lien avec tcl.so et tk.so est simplement indique dans      */
/*        le link des objets de la librairie ak (-ltcl -ltk).              */
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#define XTERN
#include "libak.h"
#include "ak_3.h"    /* Yassine */
#include "ak_4.h"    /* Yassine */


/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#if defined(LIBRARY_DLL)
   int __cdecl Ak_Init(Tcl_Interp *interp)
#endif
#if defined(LIBRARY_SO)
   int Ak_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libak.",TCL_STATIC);
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"Ak","1.0");

   Tcl_CreateCommand(interp,"ak_julianday",(Tcl_CmdProc *)Cmd_aktcl_julianday,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_infoimage",(Tcl_CmdProc *)Cmd_aktcl_infoimage,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_bugbias",(Tcl_CmdProc *)Cmd_aktcl_bugbias,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /* ajouter ici les autres fonctions d'extension que vous allez creer */
   Tcl_CreateCommand(interp,"ak_radec2healpix",(Tcl_CmdProc *)Cmd_aktcl_radec2healpix,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_healpix2radec",(Tcl_CmdProc *)Cmd_aktcl_healpix2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_sizeofrefzmgmes",(Tcl_CmdProc *)Cmd_aktcl_sizeofrefzmgmes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_radec2htm",(Tcl_CmdProc *)Cmd_aktcl_radec2htm,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_htm2radec",(Tcl_CmdProc *)Cmd_aktcl_htm2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_addcol",(Tcl_CmdProc *)Cmd_aktcl_addcol,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_filehtm2refzmgmes",(Tcl_CmdProc *)Cmd_aktcl_filehtm2refzmgmes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_file2htm",(Tcl_CmdProc *)Cmd_aktcl_file2htm,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_refzmgmes2ascii",(Tcl_CmdProc *)Cmd_aktcl_refzmgmes2ascii,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_sortmes",(Tcl_CmdProc *)Cmd_aktcl_sortmes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_updatezmg",(Tcl_CmdProc *)Cmd_aktcl_updatezmg,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_refzmgmes2vars",(Tcl_CmdProc *)Cmd_aktcl_refzmgmes2vars,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_radecinrefzmgmes",(Tcl_CmdProc *)Cmd_aktcl_radecinrefzmgmes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_photometric_parallax",(Tcl_CmdProc *)Cmd_aktcl_photometric_parallax,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_photometric_parallax_avmap",(Tcl_CmdProc *)Cmd_aktcl_photometric_parallax_avmap,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_reduceusno",(Tcl_CmdProc *)Cmd_aktcl_reduceusno,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_splitcfht",(Tcl_CmdProc *)Cmd_aktcl_splitcfht,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_aster1",(Tcl_CmdProc *)Cmd_aktcl_aster1,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ak_fitspline",(Tcl_CmdProc *)Cmd_aktcl_fitspline,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /* */
   Tcl_CreateCommand(interp,"ak_focas_catastars2pairs",(Tcl_CmdProc *)Cmd_aktcl_focas_catastars2pairs,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	/* */
	Tcl_CreateCommand(interp,"ak_cour_final",(Tcl_CmdProc *)Cmd_aktcl_cour_finalbis,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp,"ak_bayestar2galaxies",(Tcl_CmdProc *)Cmd_aktcl_bayestar2galaxies,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /* fonctions de Yassine ---*/
   Tcl_CreateCommand(interp,"yd_minlong",(Tcl_CmdProc *)Cmd_aktcl_minlong,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_periodog",(Tcl_CmdProc *)Cmd_aktcl_periodog,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_entropie_pdm",(Tcl_CmdProc *)Cmd_aktcl_entropie_pdm,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_entropie_phase",(Tcl_CmdProc *)Cmd_aktcl_entropie_phase,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_entropie_modifiee",(Tcl_CmdProc *)Cmd_aktcl_entropie_modifiee,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_classification",(Tcl_CmdProc *)Cmd_aktcl_classification,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_ajustement",(Tcl_CmdProc *)Cmd_aktcl_ajustement,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_ajustement2",(Tcl_CmdProc *)Cmd_aktcl_ajustement2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_cour_final",(Tcl_CmdProc *)Cmd_aktcl_cour_final,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_meansigma",(Tcl_CmdProc *)Cmd_aktcl_meansigma,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_per_range",(Tcl_CmdProc *)Cmd_aktcl_per_range,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_moy_bars_comp",(Tcl_CmdProc *)Cmd_aktcl_moy_bars_comp,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /*Tcl_CreateCommand(interp,"yd_rectif",(Tcl_CmdProc *)Cmd_aktcl_rectification,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);*/
   Tcl_CreateCommand(interp,"yd_aliasing",(Tcl_CmdProc *)Cmd_aktcl_aliasing,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_starnum",(Tcl_CmdProc *)Cmd_aktcl_starnum,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_statcata",(Tcl_CmdProc *)Cmd_aktcl_statcata,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

	return TCL_OK;
}
