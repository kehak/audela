/* librgb.c
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
/* - le fichier d'include librgb.h specifique pour l'interfacage C/Tcl      */
/* - le point d'entree de la librairie                                     */
/* - l'initialisation la librairie                                         */
/***************************************************************************/
/* Note : Sous Windows, il faut specifier la facon de faire pour charger   */
/*        les fichiers tcl.dll et tk.dll de facon dynamique.               */
/*        Sous Linux, on suppose que Tcl/Tk a ete installe sur le systeme  */
/*        et le lien avec tcl.so et tk.so est simplement indique dans      */
/*        le link des objets de la librairie rgb (-ltcl -ltk).              */
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#define XTERN
#include "librgb.h"


/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#if defined(LIBRARY_DLL)
   int __cdecl Rgb_Init(Tcl_Interp *interp)
#endif
#if defined(LIBRARY_SO)
   int Rgb_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in librgb.",TCL_STATIC);
      return TCL_ERROR;
   }
   if(Tk_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tk Stubs initialization failed in librgb.",TCL_STATIC);
      return TCL_ERROR;
   }

   Tcl_CreateCommand(interp,"rgb_julianday",(Tcl_CmdProc *)Cmd_rgbtcl_julianday,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"rgb_infoimage",(Tcl_CmdProc *)Cmd_rgbtcl_infoimage,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);           
   Tcl_CreateCommand(interp,"rgb_split",(Tcl_CmdProc *)Cmd_rgbtcl_split,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"rgb_visu",(Tcl_CmdProc *)Cmd_rgbtcl_visu,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"rgb_load",(Tcl_CmdProc *)Cmd_rgbtcl_load,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"rgb_save",(Tcl_CmdProc *)Cmd_rgbtcl_save,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"rgb_txt2buf",(Tcl_CmdProc *)Cmd_rgbtcl_txt2buf,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"rgb_bugbias",(Tcl_CmdProc *)Cmd_rgbtcl_bugbias,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   /* ajouter ici les autres fonctions d'extension que vous allez creer */

   return TCL_OK;
}
