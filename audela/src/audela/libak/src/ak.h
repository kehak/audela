/* ak.h
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

#ifndef __AKH__
#define __AKH__

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

#include "ak_2.h"

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
} ak_image;

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/

double ak_GetUsnoBleueMagnitude(int magL);
double ak_GetUsnoRedMagnitude(int magL);
int ak_radec2htm(double ra,double dec,int niter,char *htm);
int ak_htm2radec(char *htm,double *ra,double *dec,int *niter,double *ra0,double *dec0,double *ra1,double *dec1,double *ra2,double *dec2);
void ak_date2jd(double annee, double mois, double jour, double heure, double minute, double seconde, double *jj);
int ak_util_qsort_double(double *x,int kdeb,int n,int *index);
int ak_util_qsort_verif(int index);
int ak_util_meansigma(double *x,int kdeb,int n,double *mean,double *sigma);
/*int Cmd_aktcl_photometric_parallax_avmap(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);*/
int ak_fitspline(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *fxx);
int bayestar2galaxies(FILE *fid_bayestar_fits, FILE *fid_glade_txt, FILE *fid_glade_out);

#endif

