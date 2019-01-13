/* libgsltcl.h
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
/* Ce fichier d'inclusion contient                                         */
/* - l'interfacage avec Tcl/Tk et initialise                               */
/* - l'initialisation la librairie                                         */
/* - les fonctions d'interfacage entre Tcl et le C                         */
/***************************************************************************/

#ifndef __LIBGSLTCLH__
#define __LIBGSLTCLH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libxx.c     */
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/*               includes specifiques a l'interfacage C/Tcl                */
/***************************************************************************/
#include "gsltcl.h"

#ifdef LIBRARY_DLL
# include <windows.h>
# include "tcl.h"
# include "tk.h"
#endif

#ifdef LIBRARY_SO
# include <tcl.h>
# include <tk.h>
#endif

/*--- Point d'entree de la librairie */
#ifdef LIBRARY_DLL
   __declspec(dllexport) int __cdecl Gsltcl_Init(Tcl_Interp *interp);
#endif 
#ifdef LIBRARY_SO
   extern int Gsltcl_Init(Tcl_Interp *interp);
#endif

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers gsltcltcl_*.c */
/***************************************************************************/
/***************************************************************************/

#include "gsltcltcl.h"

#endif

