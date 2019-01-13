/* yd_4.h
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

#ifndef __YD_4H__
#define __YD_4H__

/***************************************************************************/
/**        includes valides pour tous les fichiers de type xx_*.c         **/
/***************************************************************************/

#include "libyd.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>


/***************************************************************************/
/***************************************************************************/
/**                DEFINITON DES STRUCTURES DE DONNEES                    **/
/***************************************************************************/
/***************************************************************************/
typedef struct {
   int indexref;
   int nbmes;
   double ra;
   double dec;
   unsigned char codecat[4];
   unsigned char codefiltre[4];
   float mag[4];
} struct_htmref_old ;

typedef struct {
   int indexzmg;
   double jd;
   /*rajout Yassine : ca peut etre util*/
   unsigned char codecam;
   /*fin*/
   unsigned char codefiltre;
   float cmag;
   float exposure;
   float airmass;
} struct_htmzmg_old ;

typedef struct {
   int indexref;
   int indexzmg;
   double jd;
   unsigned char codecam;
   unsigned char codefiltre;
   float maginst;
   float magcali;
   /* rajout Yassine*/
   float dmag;
   unsigned char flag;
   /*fin*/
} struct_htmmes_old ;

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/

int Cmd_ydtcl_starnum(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_statcata(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_ydtcl_reecriture(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS utils GSL        **/
/***************************************************************************/
/***************************************************************************/

#endif

