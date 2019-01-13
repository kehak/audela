/* gsltcl.h
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
/* - les includes communs a tous les fichiers gsltcl_*.c                   */
/* - le include de la definition de l'operating system                     */
/* - les prototype des fonctions C pures (sans Tcl) de la librairie.       */
/***************************************************************************/

#ifndef __GSLTCLH__
#define __GSLTCLH__

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

#ifdef OS_WIN_VCPP_DLL
#  define FILE_DOS
#  define LIBRARY_DLL
#endif

#ifdef OS_LINUX_GCC_SO
#  define FILE_UNIX
#  define LIBRARY_SO
#endif

/***************************************************************************/
/***************************************************************************/
/**                DEFINITON DES STRUCTURES DE DONNEES                    **/
/***************************************************************************/
/***************************************************************************/

typedef struct {
   float *ptr;           /* adresse du pointeur de l'image en interne */
   float *ptr_audela;    /* adresse du pointeur de l'image dans AudeLA */
   int naxis1;           /* nombre de pixels sur l'axe x */
   int naxis2;           /* nombre de pixels sur l'axe y */
   char dateobs[30];     /* date du debut de pose au format Fits */
} gsltcl_image;

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/

int gsltcl_mcalloc(double **mat,int nlig,int ncol);
int gsltcl_mfree(double **mat);
char *gsltcl_d2s(double val);

#endif

