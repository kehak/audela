/* eteltcl.h
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
/* - les includes communs a tous les fichiers xx_*.c                       */
/* - le include de la definition de l'operating system                     */
/* - les prototype des fonctions C pures (sans Tcl) de la librairie.       */
/***************************************************************************/

#ifndef __ETELTCLH__
#define __ETELTCLH__

/***************************************************************************/
/**        includes valides pour tous les fichiers de type xx_*.c         **/
/***************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/**             include qui permet de connaitre l'OS utilise              **/
/***************************************************************************/

#include "sysexp.h"

/***************************************************************************/
/**                  defines qui dependent de l'OS utilise                **/
/***************************************************************************/

#if defined(OS_WIN_VCPP_DLL)
#define FILE_DOS
#define LIBRARY_DLL
#endif

#if defined(OS_LINUX_GCC_SO)
#define FILE_UNIX
#define LIBRARY_SO
#endif

/***************************************************************************/
/***************************************************************************/
/**                DEFINITON DES STRUCTURES DE DONNEES                    **/
/***************************************************************************/
/***************************************************************************/

//#define MOUCHARD

#include <libtel/libstruc.h>

//#include "dsa20.h"
//#include "etb10.h"
//#include <dmd10.h>

#include "dsa40.h"
#include "etb40.h"
#include "dmd40.h"

#define ETEL_NAXIS_MAXI 10
int etel_nbaxis;

typedef struct {
	char etel_driver[50];
	char msg [200];
	int axis[ETEL_NAXIS_MAXI];
	int axisno[ETEL_NAXIS_MAXI];
   DSA_DRIVE *drv[ETEL_NAXIS_MAXI];
} struct_etel ;

struct_etel etel;

typedef struct {
	char type_symbol[10];
	int typ;
	int ctype;
	int *func_get;
	int *func_set;
} struct_etel_type ;

#define NB_TYP 19
struct_etel_type typs[NB_TYP];
#define ETEL_VAL_INT32   0
#define ETEL_VAL_INT64   1
#define ETEL_VAL_FLOAT32 2
#define ETEL_VAL_FLOAT64 3

#define AXIS_STATE_CLOSED       0
#define AXIS_STATE_TO_BE_OPENED 1
#define AXIS_STATE_OPENED       2

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/
void etel_error(int axisno, int err);
int etel_symbol2type(char *symbol);

#ifndef uint64_t
typedef unsigned __int64     uint64_t;
#endif
uint64_t atoi64(const char *str,int radix);

#endif

