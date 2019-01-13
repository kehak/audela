/* 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Frederic Vachier <fv@imcce.fr>
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
#ifndef __PSFIMCCEH__
#define __PSFIMCCEH__

#include <stdio.h>

/* --- definition de l'operating systeme (OS) employe pour compiler    ---*/
#include "sysexp.h"

/* To use defined math.h constants M_* and isnan for Windows with Visual Studio <= VS 2010 */
#ifdef  _WIN32  
#define _USE_MATH_DEFINES     // for  M_PI
#if _MSC_VER <= 1600          // if Visual Studio <= VS 2010
#include <float.h>
#define isnan(x) _isnan(x)
#define isinf(x) (!_finite(x))
#define fpu_error(x) (isinf(x) || isnan(x))
#endif
#endif

#define MA 7
#define NB_PARAM 15

struct mrqmin_variable_TS {
   int mfit;
   float ochisq; 
   float *atry; 
   float *beta;
   float *da;
   float **oneda;
};

typedef struct mrqmin_variable_TS mrqmin_variable_TS;


#define SQR(a) ((sqrarg=(a)) == 0.0 ? 0.0 : sqrarg*sqrarg)

#if defined(__STDC__) || defined(ANSI) || defined(NRANSI) || defined (OS_WIN) /* ANSI */

void nrerror(char error_text[]);
float *vector(long nl, long nh);
int *ivector(long nl, long nh);
void free_vector(float *v, long nl, long nh);
float **matrix(long nrl, long nrh, long ncl, long nch);
void free_matrix(float **m, long nrl, long nrh, long ncl, long nch);
void free_ivector(int *v, long nl, long nh);
void fgauss(float x, float a[], float *y, float dyda[], int na);
void mrqcof(float x[], float y[], float sig[], int ndata, float a[],
	int ia[], int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float [], float *, float [], int));
float gasdev(long *idum);
void covsrt(float **covar, int ma, int ia[], int mfit);

float Fwhm2d_rot(int x, int y, float x0, float y0,
   float sx, float sy,
   float intensity, float sky, float thetadeg);

void fgauss(float x, float a[], float *y, float dyda[], int na);
void fgauss1(float x, float a[], float *y, float dyda[], int);
void fgauss2(float x, float a[], float *y, int);
void fgauss1_2d(float x1, float x2, float a[], float *y, float dyda[], int na);

void mrqmin(float x[], float y[], float sig[], int ndata, float a[],
	int ia[], int ma, float **covar, float **alpha, float *chisq,
	void (*funcs)(float, float [], float *, float [], int), float *alamda);
void mrqcof(float x[], float y[], float sig[], int ndata, float a[],
	int ia[], int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float [], float *, float [], int));

void lfit(float x[], float y[], float sig[], int ndat, float a[], int ia[],
	int ma, float **covar, float *chisq, void (*funcs)(float, float [], int));

void mrqmin2D(float x[], float y[], float **z, float **sig, int ndata, float a[],
	int ia[], int ma, float **covar, float **alpha, float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int), float *alamda);

void mrqmin2D_ThreadSafe(float x[], float y[], float **z, float **sig, int ndata, float a[],
	int ia[], int ma, float **covar, float **alpha, float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int), float *alamda,
   mrqmin_variable_TS *mrqmin_TS
   );

void mrqcof2D(float x[], float y[], float **z, float **sig, int ndata, float a[], int ia[],
	int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int));

void fit_gauss2D(int npt, float **zs, float *a, float *uncertainties); 
void coeff2param(int npt, float **zs, float *a, float *p, float *uncertainties, float **synthetic, float **residus);


#else /* ANSI */
/* traditional - K&R */

void nrerror();
float *vector();
int *ivector();
void free_vector();
float **matrix();
void free_matrix();
void free_ivector();
void fgauss();
void mrqcof();
void mrqmin();
float gasdev();
void fgauss();
void covsrt();
float Fwhm2d_rot();
void lfit();
void fgauss1_2d();


#endif /* ANSI */


#endif // __PSFIMCCEH__
