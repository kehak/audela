/* libml.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <Myrtille.Laas@oamp.fr>
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
/* - le fichier d'include libml.h specifique pour l'interfacage C/Tcl      */
/* - le point d'entree de la librairie                                     */
/* - l'initialisation la librairie                                         */
/***************************************************************************/
/* Note : Sous Windows, il faut specifier la facon de faire pour charger   */
/*        les fichiers tcl.dll et tk.dll de facon dynamique.               */
/*        Sous Linux, on suppose que Tcl/Tk a ete installe sur le systeme  */
/*        et le lien avec tcl.so et tk.so est simplement indique dans      */
/*        le link des objets de la librairie ml (-ltcl -ltk).              */
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#define XTERN
#include "libml.h"

/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#if defined(LIBRARY_DLL)
   int __cdecl Ml_Init(Tcl_Interp *interp)
#endif
#if defined(LIBRARY_SO)
   int Ml_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libml.",TCL_STATIC);
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"Ml","1.4");
   Tcl_CreateCommand(interp,"ml_geostatident",(Tcl_CmdProc *)Cmd_mltcl_geostatident,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ml_residutycho2usno",(Tcl_CmdProc *)Cmd_mltcl_residutycho2usno,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ml_julianday",(Tcl_CmdProc *)Cmd_mltcl_julianday,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ml_infoimage",(Tcl_CmdProc *)Cmd_mltcl_infoimage,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ml_geostatreduc",(Tcl_CmdProc *)Cmd_mltcl_geostatreduc,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

   Tcl_CreateCommand(interp,"ml_geostatreduc2",(Tcl_CmdProc *)Cmd_mltcl_geostatreduc2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ml_geostatident2",(Tcl_CmdProc *)Cmd_mltcl_geostatident2,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"ml_geostatreduc3",(Tcl_CmdProc *)Cmd_mltcl_geostatreduc3,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL); 
   Tcl_CreateCommand(interp,"ml_fitquadratique",(Tcl_CmdProc *)Cmd_mltcl_fitquadratique,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

 
   /* ajouter ici les autres fonctions d'extension que vous allez creer */

   return TCL_OK;
}
