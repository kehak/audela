/* licatalog.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine DAMERDJI <yassine.damerdji@gmail.com>
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

#ifndef __LIBCATALOGH__
#define __LIBCATALOGH__

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/**    Detect the exploitation system and add the relevant includes       **/
/***************************************************************************/

#include "sysexp.h"

#if defined(LIBRARY_DLL)
#include <windows.h>
#include "tcl.h"
/* Define isinf function for windows */
#include <float.h>
#define isinf(x) (!_finite(x))
#endif

#if defined(LIBRARY_SO)
#include <tcl.h>
#endif


/***************************************************************************/
/*                  Prototypes of C functions called by TCL              */
/***************************************************************************/

/* Yassine : extraction of stars from catalogs : function for Frederic Vachier */
/* TYCHO catalog */
int cmd_tcl_cstycho2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* TYCHO catalog */
int cmd_tcl_cstycho2_fast(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* UCAC2 catalog */
int cmd_tcl_csucac2 (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* UCAC3 catalog */
int cmd_tcl_csucac3 (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* UCAC4 catalog */
int cmd_tcl_csucac4 (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* USNO-A2 catalog */
int cmd_tcl_csusnoa2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* 2MASS catalog */
int cmd_tcl_cs2mass (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* PPMX catalog */
int cmd_tcl_csppmx  (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* PPMXL catalog */
int cmd_tcl_csppmxl (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* NOMAD1 catalog */
int cmd_tcl_csnomad1(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* WFIBC catalog */
int cmd_tcl_cswfibc (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* BMK catalog */
int cmd_tcl_csbmk (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* URAT1 catalog */
int cmd_tcl_csurat1 (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* LONEOS catalog */
int cmd_tcl_csloneos (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* TGAS catalog */
int cmd_tcl_cstgas (ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* Gaia1 catalog */
int cmd_tcl_csgaia1(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* Gaia2 catalog */
int cmd_tcl_csgaia2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#endif /* __LIBCATALOGH__ */

