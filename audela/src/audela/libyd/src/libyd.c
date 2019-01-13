/* libyd.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine DAMERDJI <damerdji@obs-hp.fr>
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
/* - le fichier d'include libyd.h specifique pour l'interfacage C/Tcl      */
/* - le point d'entree de la librairie                                     */
/* - l'initialisation la librairie                                         */
/***************************************************************************/
/* Note : Sous Windows, il faut specifier la facon de faire pour charger   */
/*        les fichiers tcl.dll et tk.dll de facon dynamique.               */
/*        Sous Linux, on suppose que Tcl/Tk a ete installe sur le systeme  */
/*        et le lien avec tcl.so et tk.so est simplement indique dans      */
/*        le link des objets de la librairie yd (-ltcl -ltk).              */
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#define XTERN
#include "libyd.h"
#include "yd.h"    /* Yassine */

#include "yd_3.h"    /* Yassine */
#include "yd_4.h"    /* Yassine */


/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#if defined(LIBRARY_DLL)
   int __cdecl Yd_Init(Tcl_Interp *interp)
#endif
#if defined(LIBRARY_SO)
   int Yd_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libyd.",TCL_STATIC);
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"Yd","1.0");

   Tcl_CreateCommand(interp,"yd_julianday",(Tcl_CmdProc *)Cmd_ydtcl_julianday,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_infoimage",(Tcl_CmdProc *)Cmd_ydtcl_infoimage,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_bugbias",(Tcl_CmdProc *)Cmd_ydtcl_bugbias,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /* ajouter ici les autres fonctions d'extension que vous allez creer */
   Tcl_CreateCommand(interp,"yd_radec2htm",(Tcl_CmdProc *)Cmd_ydtcl_radec2htm,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_htm2radec",(Tcl_CmdProc *)Cmd_ydtcl_htm2radec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_addcol",(Tcl_CmdProc *)Cmd_ydtcl_addcol,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_filehtm2refzmgmes",(Tcl_CmdProc *)Cmd_ydtcl_filehtm2refzmgmes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_file2htm",(Tcl_CmdProc *)Cmd_ydtcl_file2htm,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_refzmgmes2ascii",(Tcl_CmdProc *)Cmd_ydtcl_refzmgmes2ascii,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /*Modif Yassine : Plus besoinde sortmes
   Tcl_CreateCommand(interp,"yd_sortmes",(Tcl_CmdProc *)Cmd_ydtcl_sortmes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);*/
   Tcl_CreateCommand(interp,"yd_updatezmg",(Tcl_CmdProc *)Cmd_ydtcl_updatezmg,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_refzmgmes2vars",(Tcl_CmdProc *)Cmd_ydtcl_refzmgmes2vars,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_radecinrefzmgmes",(Tcl_CmdProc *)Cmd_ydtcl_radecinrefzmgmes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_reduceusno",(Tcl_CmdProc *)Cmd_ydtcl_reduceusno,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_ref2field",(Tcl_CmdProc *)Cmd_ydtcl_ref2field,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_cal2ref",(Tcl_CmdProc *)Cmd_ydtcl_cal2ref,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_mes2mes",(Tcl_CmdProc *)Cmd_ydtcl_mes2mes,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

   /* */
   Tcl_CreateCommand(interp,"yd_minlong",(Tcl_CmdProc *)Cmd_ydtcl_minlong,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_periodog",(Tcl_CmdProc *)Cmd_ydtcl_periodog,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_entropie_pdm",(Tcl_CmdProc *)Cmd_ydtcl_entropie_pdm,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_classification",(Tcl_CmdProc *)Cmd_ydtcl_classification,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_ajustement",(Tcl_CmdProc *)Cmd_ydtcl_ajustement,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_cour_final",(Tcl_CmdProc *)Cmd_ydtcl_cour_final,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_meansigma",(Tcl_CmdProc *)Cmd_ydtcl_meansigma,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_per_range",(Tcl_CmdProc *)Cmd_ydtcl_per_range,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_moy_bars_comp",(Tcl_CmdProc *)Cmd_ydtcl_moy_bars_comp,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_starnum",(Tcl_CmdProc *)Cmd_ydtcl_starnum,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_statcata",(Tcl_CmdProc *)Cmd_ydtcl_statcata,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /*Tcl_CreateCommand(interp,"yd_reecriture",(Tcl_CmdProc *)Cmd_ydtcl_reecriture,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);*/
   Tcl_CreateCommand(interp,"yd_poids",(Tcl_CmdProc *)Cmd_ydtcl_poids,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_shortorlong",(Tcl_CmdProc *)Cmd_ydtcl_shortorlong,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_refzmgmes2vars_stetson",(Tcl_CmdProc *)Cmd_ydtcl_refzmgmes2vars_stetson,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_ajustement_spec",(Tcl_CmdProc *)Cmd_ydtcl_ajustement_spec,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_coefs_rucinski",(Tcl_CmdProc *)Cmd_ydtcl_coefs_rucinski,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_detect_multiple_per",(Tcl_CmdProc *)Cmd_ydtcl_detect_multiple_per,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_phase_multiple_per",(Tcl_CmdProc *)Cmd_ydtcl_phase_multiple_per,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_reduit_nombre_digit",(Tcl_CmdProc *)Cmd_ydtcl_util_reduit_nombre_digit,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_pasfreq",(Tcl_CmdProc *)Cmd_ydtcl_pasfreq,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_lireusno",(Tcl_CmdProc *)Cmd_ydtcl_lireusno,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_lire2mass",(Tcl_CmdProc *)Cmd_ydtcl_lire2mass,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"yd_requete_table",(Tcl_CmdProc *)Cmd_ydtcl_requete_table,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   return TCL_OK;
}
