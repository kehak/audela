/* rgbtcl.h
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
#ifndef __RGBTCLH__
#define __RGBTCLH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier librgb.c     */
/***************************************************************************/
/***************************************************************************/

#include "librgb.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions des fichiers rgbtcl_*.c */
/***************************************************************************/
/***************************************************************************/
#ifndef max
#   define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#   define min(a,b) (((a)<(b))?(a):(b))
#endif

/***************************************************************************/
/*      Prototypes des fonctions d'extension C appelables par Tcl          */
/***************************************************************************/
/*--- Les prototypes sont tous les memes */
int Cmd_rgbtcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_rgbtcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_rgbtcl_split(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_rgbtcl_visu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_rgbtcl_save(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_rgbtcl_load(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_rgbtcl_txt2buf(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_rgbtcl_bugbias(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/***************************************************************************/
/*      Prototypes des fonctions utiles qui melangent C et Tcl             */
/***************************************************************************/
int rgbtcl_getinfoimage(Tcl_Interp *interp,int numbuf, rgb_image *image);

#endif

