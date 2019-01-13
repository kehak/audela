/* eteltcltcl.h
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
#ifndef __ETELTCLTCLH__
#define __ETELTCLTCLH__

/****************************************************************************/
/****************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libeteltcl.c */
/****************************************************************************/
/****************************************************************************/

#include "libeteltcl.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/********************************************************************************/
/********************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers eteltcltcl_*.c */
/********************************************************************************/
/********************************************************************************/

#include "eteltcl.h"

/***************************************************************************/
/*      Prototypes des fonctions d'extension C appelables par Tcl          */
/***************************************************************************/
/*--- Les prototypes sont tous les memes */
int Cmd_eteltcltcl_open(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_close(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_status(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_ExecuteCommandXS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_GetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_SetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_dsa_quick_stop_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_open2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_dsa_power_on_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_eteltcltcl_dsa_reset_error_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/***************************************************************************/
/*      Prototypes des fonctions utiles qui melangent C et Tcl             */
/***************************************************************************/

#endif

