/* libgsltcl.c
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
/* - le fichier d'include libgsltcl.h specifique pour l'interfacage C/Tcl      */
/* - le point d'entree de la librairie                                     */
/* - l'initialisation la librairie                                         */
/***************************************************************************/
/* Note : Sous Windows, il faut specifier la facon de faire pour charger   */
/*        les fichiers tcl.dll et tk.dll de facon dynamique.               */
/*        Sous Linux, on suppose que Tcl/Tk a ete installe sur le systeme  */
/*        et le lien avec tcl.so et tk.so est simplement indique dans      */
/*        le link des objets de la librairie gsltcl (-ltcl -ltk).              */
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#define XTERN
#include "libgsltcl.h"

/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#ifdef LIBRARY_DLL
   int __cdecl Gsltcl_Init(Tcl_Interp *interp)
#endif
#ifdef LIBRARY_SO
   int Gsltcl_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libgsl.",TCL_STATIC);
      return TCL_ERROR;
   }

   /* ajouter ici les autres fonctions d'extension que vous allez creer */
   Tcl_CreateCommand(interp,"gsl_mindex",(Tcl_CmdProc *)Cmd_gsltcltcl_mindex,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_mreplace",(Tcl_CmdProc *)Cmd_gsltcltcl_mreplace,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_mlength",(Tcl_CmdProc *)Cmd_gsltcltcl_mlength,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_mtranspose",(Tcl_CmdProc *)Cmd_gsltcltcl_mtranspose,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_mmult",(Tcl_CmdProc *)Cmd_gsltcltcl_mmult,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_madd",(Tcl_CmdProc *)Cmd_gsltcltcl_madd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_msub",(Tcl_CmdProc *)Cmd_gsltcltcl_msub,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_meigsym",(Tcl_CmdProc *)Cmd_gsltcltcl_meigsym,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_minv",(Tcl_CmdProc *)Cmd_gsltcltcl_minv,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_mdet",(Tcl_CmdProc *)Cmd_gsltcltcl_mdet,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_msolvelin",(Tcl_CmdProc *)Cmd_gsltcltcl_msolvelin,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_mfitmultilin",(Tcl_CmdProc *)Cmd_gsltcltcl_mfitmultilin,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_fft",(Tcl_CmdProc *)Cmd_gsltcltcl_fft,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_ifft",(Tcl_CmdProc *)Cmd_gsltcltcl_ifft,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_chisq_Q",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_chisq_Q,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_chisq_P",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_chisq_P,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_chisq_Qinv",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_chisq_Qinv,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_chisq_Pinv",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_chisq_Pinv,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_ugaussian_Q",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_ugaussian_Q,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_ugaussian_Qinv",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_ugaussian_Qinv,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_ugaussian_P",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_ugaussian_P,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_cdf_ugaussian_Pinv",(Tcl_CmdProc *)Cmd_gsltcltcl_cdf_ugaussian_Pinv,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"gsl_multimin_fminimizer_nmsimplex",(Tcl_CmdProc *)Cmd_gsltcltcl_multimin_fminimizer_nmsimplex,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

   /* Dev by Harald Rischbieter ( har.risch@gmx.de ) */
   Tcl_CreateCommand(interp,"gsl_sphharm",(Tcl_CmdProc *)Cmd_gsltcltcl_msphharm,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

   #define DEMO_VERSION 0 
   Tcl_SetVar((Tcl_Interp*) interp, "libgsltcl_version", 
               DEMO_VERSION, TCL_GLOBAL_ONLY);


   return TCL_OK;
}
