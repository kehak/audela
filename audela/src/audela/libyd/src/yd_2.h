/* yd_2.h
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

/***************************************************************************/
/* C Functions for photometric parallax computations.                      */
/***************************************************************************/

#ifndef __YD_2H__
#define __YD_2H__

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

/***************************************************************************/
/***************************************************************************/
/**                  DEFINITION OF DATA STRUCTURES                        **/
/***************************************************************************/
/***************************************************************************/

typedef struct {
   float *mat;           /* address of the pointer for the internal image */
   float *matconv;       /* address of the pointer for the internal image which will be convolve by a gaussian */
   int naxis1;
   double crpix1;
   double crval1;
   double cdelt1;
   double sigma1;
   int naxis2;
   double crpix2;
   double crval2;
   double cdelt2;
   double sigma2;
} yd_phot_par_diag;

typedef struct {
   double ra;
   double dec;
   double magb;
   double magv;
   double magr;
   double magi;
   double magj;
   double magh;
   double magk;
   double sigmagb;
   double sigmagv;
   double sigmagr;
   double sigmagi;
   double sigmagj;
   double sigmagh;
   double sigmagk;
} yd_phot_par_mag;

typedef struct {
   int index;
   char htm[20];
} yd_phot_par_htmsort;

typedef struct {
   char htm[20];
   double av1;
   double av;
   double av2;
   double md1;
   double md;
   double md2;
} yd_phot_par_htmav;

typedef struct {
   double naxis1;
   double naxis2;
   double crval1;
   double crval2;
   double cdelt1;
   double cdelt2;
   double crpix1;
   double crpix2;
   double crota2;
   double cd11;
   double cd12;
   double cd21;
   double cd22;
} yd_phot_par_wcs;

#define YD_PI 3.1415926535897

/***************************************************************************/
/***************************************************************************/
/**                 DEFINITION Of FUNCTION PROTOTYPES                     **/
/***************************************************************************/
/***************************************************************************/

char *yd_photometric_parallax(char *path,char *ascii_star,int filetype, int htmlevel, int savetmpfiles, char *ascii_htmav, char *ascii_colcol,char *ascii_colmag,int colcolmagtype);
char *yd_photometric_parallax_avmap(char *path,char *ascii_htmav, char *fitsnameav, char *fitsnamemd,int naxis1,int naxis2);

char *yd_photometric_parallax_convgauss(yd_phot_par_diag *diags,double sigmagx, double sigmagy);
char *yd_photometric_parallax_diagram(char *ascii_diagram,char *tmpfile,double sigmagy, yd_phot_par_diag *diags);
char *yd_photometric_parallax_savefits(float *mat,int naxis1, int naxis2,char *filename,yd_phot_par_wcs *wcs);
char *yd_photometric_parallax_inputs(char *inputfile,int filetype, yd_phot_par_mag **mags,int *n_stars);
char *yd_photometric_parallax_av_extraction(FILE *fout, char *path, yd_phot_par_diag avmdhtms,double *avprofile,double *dmprofile,char *htm0,int n_star0,int savetmpfiles,double *avmaxi,double *mdmaxi);
char *yd_photometric_parallax_read_htmav(char *inputfile,yd_phot_par_htmav **htmavs,int *n_htms);
char *yd_photometric_parallax_loaddiagram(char *bindiag,yd_phot_par_diag *diags);

void yd_photometric_parallax_quicksort_htmsort(yd_phot_par_htmsort *htmsort, int low, int high);
void yd_photometric_parallax_quicksort_double(double *arr, int low, int high);

int yd_photometric_parallax_htm_testin(double *v0, double *v1, double *v2, double *v);
int yd_photometric_parallax_radec2htm(double ra,double dec,int niter,char *htm);
int yd_photometric_parallax_htm2radec(char *htm,double *ra,double *dec,int *niter,double *ra0,double *dec0,double *ra1,double *dec1,double *ra2,double *dec2);

char *yd_photometric_parallax_xy2radec(yd_phot_par_wcs wcs, double x,double y,double *ra,double *dec);
char *yd_photometric_parallax_radec2xy(yd_phot_par_wcs wcs, double ra,double dec,double *x,double *y);

#endif

