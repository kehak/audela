/* ak_3.h
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

#ifndef __AK_3H__
#define __AK_3H__

/***************************************************************************/
/**        includes valides pour tous les fichiers de type xx_*.c         **/
/***************************************************************************/

#include "libak.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

#include <gsl/gsl_math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_histogram.h>
#include <gsl/gsl_sort.h>
#include <gsl/gsl_sort_vector.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>


/***************************************************************************/
/***************************************************************************/
/**                DEFINITON DES STRUCTURES DE DONNEES                    **/
/***************************************************************************/
/***************************************************************************/

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS                  **/
/***************************************************************************/
/***************************************************************************/

int Cmd_aktcl_minlong(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_periodog(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_entropie_pdm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_somelet(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_entropie_phase(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_entropie_modifiee(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_classification(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_ajustement(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_ajustement2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_cour_final(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_meansigma(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_per_range(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_moy_bars_comp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_aktcl_aliasing(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

int yd_entropie(gsl_matrix *EntMat,int n,int m,double *Entropie);
int yd_moin_carr(gsl_vector *jds, gsl_vector *mags,gsl_vector *bars, double per , int n_arm,int nmes, gsl_vector *coefs, double *residu);
int yd_perchoice(gsl_vector *jds, int nmes, int *temoin, int *indice_prem_date, int *indice_dern_date);
int yd_dichotomie(double per, gsl_vector *badpers, int nbad, int *temoin2, int *k_bad);
int yd_util_pgcd(double *vecteur, int taille, double limit,double tolerance,double *pgcd, int *temoin);

/***************************************************************************/
/***************************************************************************/
/**              DEFINITION DES PROTOTYPES DES FONCTIONS utils GSL        **/
/***************************************************************************/
/***************************************************************************/

int gsltcltcl_getvector(Tcl_Interp *interp, char *list, double **vec, int *n);
int gsltcltcl_setvector(Tcl_Interp *interp, Tcl_DString *dsptr, double *vec, int n);
int gsltcltcl_getmatrix(Tcl_Interp *interp, char *list, double **mat, int *nl, int *nc);
int gsltcltcl_setmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, double *mat, int nl, int nc);
int gsltcltcl_getgslmatrix(Tcl_Interp *interp, char *list, gsl_matrix **gslmat, int *nl, int *nc);
int gsltcltcl_setgslmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_matrix *gslmat, int nl, int nc);
int gsltcltcl_getgslvector(Tcl_Interp *interp, char *list, gsl_vector **gslvec, int *n);
int gsltcltcl_setgslvector(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_vector *vec, int n);
int gsltcl_mcalloc(double **mat,int nlig,int ncol);
int gsltcl_mfree(double **mat);

#endif

