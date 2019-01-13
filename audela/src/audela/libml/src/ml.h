/* ml.h
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
/* Ce fichier d'inclusion contient                                         */
/* - les includes communs a tous les fichiers xx_*.c                       */
/* - le include de la definition de l'operating system                     */
/* - les prototype des fonctions C pures (sans Tcl) de la librairie.       */
/***************************************************************************/

#ifndef __MLH__
#define __MLH__

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

typedef struct {
   float *ptr;           /* adresse du pointeur de l'image en interne */
   float *ptr_audela;    /* adresse du pointeur de l'image dans AudeLA */
   int naxis1;           /* nombre de pixels sur l'axe x */
   int naxis2;           /* nombre de pixels sur l'axe y */
   char dateobs[30];     /* date du debut de pose au format Fits */
} ml_image;

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/

void ml_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle);
void ml_date2jd(double annee, double mois, double jour, double heure, double minute, double seconde, double *jj);
int ml_differencejour (int jour1, int mois1, int annee1, int jour2, int mois2, int annee2);
int ml_bissextile (int annee);
int ml_nbjours (int jour, int mois, int annee);
int ml_file_copy (const char *source, const char *dest);
double ml_GetUsnoBleueMagnitude(int magL);
double ml_GetUsnoRedMagnitude(int magL);



#endif

