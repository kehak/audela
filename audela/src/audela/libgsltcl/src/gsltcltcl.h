/* gsltcltcl.h
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
#ifndef __GSLTCLTCLH__
#define __GSLTCLTCLH__

/***************************************************************************/
/***************************************************************************/
/* Les prototypes suivants concernent les fonctions du fichier libgsltcl.c */
/***************************************************************************/
/***************************************************************************/

#include "libgsltcl.h"
#ifdef LIBRARY_DLL
#define GSL_DLL
#endif

#include <gsl/gsl_matrix.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_eigen.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_fit.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_sf_legendre.h>
#include <gsl/gsl_fft_complex.h>
#include <gsl/gsl_cdf.h>
#include <gsl/gsl_sf_gamma.h>
#include <gsl/gsl_multimin.h>

#define REAL(z,i) ((z)[2*(i)])
#define IMAG(z,i) ((z)[2*(i)+1])

typedef struct {
	Tcl_Interp *interp;
	char proc[200];
} struct_my_f;

/***************************************************************************/
/*      Prototypes des fonctions d'extension C appelables par Tcl          */
/***************************************************************************/
/*--- Les prototypes sont tous les memes */
int Cmd_gsltcltcl_mindex(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_mreplace(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_mlength(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_mtranspose(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_mmult(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_madd(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_msub(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_meigsym(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_minv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_mdet(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_msolvelin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_mfitmultilin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_fft(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_ifft(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_chisq_Q(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_chisq_P(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_chisq_Qinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_chisq_Pinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_ugaussian_Q(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_ugaussian_Qinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_ugaussian_P(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_cdf_ugaussian_Pinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_gsltcltcl_multimin_fminimizer_nmsimplex(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
/* Dev by Harald Rischbieter ( har.risch@gmx.de ) */
int Cmd_gsltcltcl_msphharm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);


/***************************************************************************/
/*      Prototypes des fonctions utiles qui melangent C et Tcl             */
/***************************************************************************/
int gsltcltcl_getvector(Tcl_Interp *interp, char *list, double **vec, int *n);
int gsltcltcl_setvector(Tcl_Interp *interp, Tcl_DString *dsptr, double *vec, int n);
int gsltcltcl_getmatrix(Tcl_Interp *interp, char *list, double **mat, int *nl, int *nc);
int gsltcltcl_setmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, double *mat, int nl, int nc);
int gsltcltcl_getgslmatrix(Tcl_Interp *interp, char *list, gsl_matrix **gslmat, int *nl, int *nc);
int gsltcltcl_setgslmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_matrix *gslmat, int nl, int nc);
int gsltcltcl_getgslvector(Tcl_Interp *interp, char *list, gsl_vector **gslvec, int *n);
int gsltcltcl_setgslvector(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_vector *vec, int n);

/*int gsltcltcl_setgslmatrix(Tcl_Interp *interp, Tcl_DString dsptr, gsl_matrix *gslmat, int nl, int nc);*/

#endif

