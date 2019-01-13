/* libhealpix.c
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
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#define XTERN
#include "libhealpix.h"

/***************************************************************************/
/*                      Point d'entree de la librairie                     */
/***************************************************************************/
#if defined(LIBRARY_DLL)
   extern "C" int __cdecl Healpix_Init(Tcl_Interp *interp)
#endif
#if defined(LIBRARY_SO)
   extern "C" int Healpix_Init(Tcl_Interp *interp)
#endif

{
   char * message;
   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
	   message = strdup( "Tcl Stubs initialization failed in libhealpix." );
      Tcl_SetResult(interp, message, TCL_STATIC);
      free( message );
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"Healpix","1.0");

   Tcl_CreateCommand(interp,"healpix_nside2npix",(Tcl_CmdProc *)Cmd_healpix_nside2npix,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);

	return TCL_OK;
}
