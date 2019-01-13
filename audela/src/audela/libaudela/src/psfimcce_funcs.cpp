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
// nonlinear least-squares fit, Marquardt's method
#include "psfimcce.h"
#include <math.h>

/*
   #  0    "xsm" 
   #  1    "ysm" 
   #  2    "err_xsm" 
   #  3    "err_ysm" 
   #  4    "fwhmx" 
   #  5    "fwhmy" 
   #  6    "fwhm" 
   #  7    "flux" 
   #  8    "err_flux" 
   #  9    "pixmax"
   #  10   "intensity" 
   #  11   "sky" 
   #  12   "err_sky" 
   #  13   "snint" 
   #  14   "radius" 
   #  15   "rdiff" 
   #  16   "err_psf" 
   #  17   "ra" 
   #  18   "dec"
   #  19   "res_ra" 
   #  20   "res_dec" 
   #  21   "omc_ra" 
   #  22   "omc_dec" 
   #  23   "mag" 
   #  24   "err_mag" 
   #  25   "name" 
   #  26   "flagastrom" 
   #  27   "flagphotom" 
   #  28   "cataastrom"
   #  29   "cataphotom"
*/

void coeff2param (int npt, float **zs, float *a, float *p, float *uncertainties, float **synthetic, float **residus)
{
   float flux, pixmax;
   float *dyda;
   int i, j;

   flux = 0;
   pixmax = zs[1][1];
   dyda = vector(1,MA);

   for(i=0; i<npt; i++) {
      for(j=0; j<npt; j++) {
         /* Gaussienne Synthtetique */
         fgauss1_2d((float)i, (float)j, a, &synthetic[i][j], dyda, MA);
         /* Gaussienne Residuelle */
         residus[i][j] = synthetic[i][j] - zs[i][j];
         /* Calcul du flux integre */
         flux += synthetic[i][j]-a[1];
         /* Calcul du pixmax */
         if (pixmax < zs[i][j]) {
            pixmax = zs[i][j];
         }
      }
   }

   free_vector(dyda,1,MA);

/*
   Parametres au format ASTROID
*/
   //  0    "xsm" 
   p[0] = a[3];

   //  1    "ysm" 
   p[1] = a[4];

   //  2    "err_xsm" 
   p[2] = uncertainties[3];

   //  3    "err_ysm" 
   p[3] = uncertainties[4];

   //  4    "fwhmx" 
   p[4] = (float)(a[5]*2.35482);

   //  5    "fwhmy" 
   p[5] = (float)(a[6]*2.35482);

   //  6    "fwhm" 
   p[6] = (float)(sqrt((p[4]*p[4]+p[5]*p[5])/2.0));

   //  7    "flux" 
   p[7] = (float)(a[2] * 2 * M_PI * a[5] * a[6]);
   
   //  8    "err_flux" 
   p[8] = 0;

   //  9    "pixmax"
   p[9] = pixmax;

   //  10   "intensity" 
   p[10] = a[2];

   //  11   "sky" 
   p[11] = a[1];

   //  12   "err_sky" 
   p[12] = uncertainties[1];

   //  13   "snint" 
   p[13] = p[7] / sqrt( p[7] + npt * a[1] );

   //  14   "radius" 
   p[14] = (float)((int) (npt/2));

   //  16   "err_psf" 
   p[15] = 0;
   if (isnan(p[0]) || isnan(p[1])) p[15] = 2;

}


void fgauss(float x, float a[], float *y, float dyda[], int na)
{
	int i;
	float fac,ex,arg;

	*y = 0.0;
	for (i=1; i<=na-1; i+=3) {
		arg=(x-a[i+1])/a[i+2];
		ex=exp(-arg*arg);
		fac=(float)(a[i]*ex*2.0*arg);
		*y += a[i]*ex;
		dyda[i]=ex;
		dyda[i+1]=fac/a[i+2];
		dyda[i+2]=fac*arg/a[i+2];
	}
}


/*
a[1] = sky
a[2] = intensity
a[3] = x0
a[4] = sigx
*/
void fgauss1(float x, float a[], float *y, float dyda[], int na)
{
	float fac,ex,arg;

	*y=0.0;

   //printf("fgauss1 A : %f %f %f %f \n",a[1],a[2],a[3],a[4]);
	arg=(x-a[3])/a[4];
	ex=exp(-arg*arg);
	fac=(float)(a[2]*ex*2.0*arg);
	*y = a[1]+a[2]*ex;
	dyda[1]=1;
	dyda[2]=ex;
	dyda[3]=fac/a[4];
	dyda[4]=fac*arg/a[4];

}
void fgauss2(float x, float a[], float *y)
{

	float ex,arg;

	*y=0.0;

	arg=(x-a[3])/a[4];
	ex=exp(-arg*arg);
	*y = a[1]+a[2]*ex;

}
void fgauss3(float x, float a[], float *y, float dyda[], int na)
{

	float fac,ex,arg;

	*y=0.0;

	arg=(x-a[2])/a[3];
	ex=exp(-arg*arg);
	fac=(float)(a[1]*ex*2.0*arg);
	*y = a[1]*ex;
	dyda[1]=ex;
	dyda[2]=fac/a[3];
	dyda[3]=fac*arg/a[3];

}




/*
a[1] = sky
a[2] = intensity
a[3] = x0
a[4] = y0
a[5] = sigx
a[6] = sigy
a[7] = theta
*/
void fgauss1_2d(float x1, float x2, float a[], float *y, float dyda[], int na)
{
	float ex;
	float ga,gb,gc;

   //printf("fgauss1_2d A : %f %f %f %f %f %f %f\n",a[1],a[2],a[3],a[4],a[5],a[6],a[7]);

	*y=0.0;

   ga = pow(cos(a[7]), 2) * pow(a[5], -2) / 2 + pow(sin(a[7]), 2) * pow(a[6], -2) / 2;
   gb = -sin(2 * a[7]) * pow(a[5], -2) / 4 + sin(2 * a[7]) * pow(a[6], -2) / 4;
   gc = pow(sin(a[7]), 2) * pow(a[5], -2) / 2 + pow(cos(a[7]), 2) * pow(a[6], -2) / 2;
   ex = exp(- ga * pow(x1 - a[3], 2) - 2 * gb * (x1 - a[3]) * (x2 - a[4]) - gc * pow(x2 - a[4], 2));


   *y = a[1] + a[2] * ex;

   dyda[1] = 1;
   dyda[2] = ex;
   dyda[3] = a[2] * (2 * ga * (x1 - a[3]) + 2 * gb * (x2 - a[4])) * ex;
   dyda[4] = a[2] * (2 * gb * (x1 - a[3]) + 2 * gc * (x2 - a[4])) * ex;
   dyda[5] = a[2] * (pow(cos(a[7]), 2) * pow(x1 - a[3], 2) * pow(a[5], -3) 
             - sin(2 * a[7]) * (x1 - a[3]) * (x2 - a[4]) * pow(a[5], -3) 
             + pow(sin(a[7]), 2) * pow(x2 - a[4], 2) * pow(a[5], -3)) * ex;
   dyda[6] = a[2] * (pow(sin(a[7]), 2) * pow(a[6], -3) * pow(x1 - a[3], 2) 
             + sin(2 * a[7]) * pow(a[6], -3) * (x1 - a[3]) * (x2 - a[4]) 
             + pow(cos(a[7]), 2) * pow(a[6], -3) * pow(x2 - a[4], 2)) * ex;
   dyda[7] = a[2] * (-(-cos(a[7]) * pow(a[5], -2) * sin(a[7]) + sin(a[7]) 
             * pow(a[6], -2) * cos(a[7])) * pow(x1 - a[3], 2) - 2 
             * (-cos(2 * a[7]) * pow(a[5], -2) / 2 + cos(2 * a[7]) 
             * pow(a[6], -2) / 2) * (x1 - a[3]) * (x2 - a[4]) - (cos(a[7]) 
             * pow(a[5], -2) * sin(a[7]) - sin(a[7]) * pow(a[6], -2) * cos(a[7])) 
             * pow(x2 - a[4], 2)) * ex;

}








void myprint (float  **z, int npt) 
{
   int i, j;


   printf("       "); for(i=1;i<=npt;i++) printf("%2d   ",i); printf("\n");

   for(i=0;i<npt;i++) {
      printf("%2d : ",i);
      for(j=0;j<npt;j++) {
         printf("%4.0f ",z[i][j]);
      }
      printf("\n");
   }

}



void minmax (float  **z, float *min, float *max, float *x, float *y, int npt) 
{

   int i, j;

   *min = z[1][1];
   *max = z[1][1];
   for (i=0; i < npt; i++) {
      for (j=0; j < npt; j++) {
         if (*min > z[i][j]) *min = z[i][j];
         if (*max < z[i][j]) {
            *max = z[i][j];
            *x = (float)i;
            *y = (float)j;
         }
      }
   }
}



void fit_gauss2D (int npt, float **zs, float *a, float *uncertainties) 
{
   int i, j, k, itst, n, cpt, log;
   float *dyda;
	float alamda, chisq, ochisq, mean;
	float **covar,**alpha, **z, **residus;
   float  min, max, sky;
	int *ia;
	float **sig;
	float x0,y0;
	float *x,*y;
   
   mrqmin_variable_TS mrqmin_TS = { 0, 0, NULL, NULL, NULL, NULL };
   
   log = 0;

   dyda    = vector(1,MA);
	covar   = matrix(1,MA,1,MA);
	alpha   = matrix(1,MA,1,MA);
	z       = matrix(0,npt-1,0,npt-1);
	residus = matrix(0,npt-1,0,npt-1);
	ia      = ivector(1,MA);
	sig     = matrix(0,npt-1,0,npt-1);
	x       = vector(0,npt-1);
	y       = vector(0,npt-1);


   /* Calcul mini maxi de z */
   minmax (zs,&min,&max, &x0, &y0, npt);
   if (log) printf("min = %f max = %f\n",min,max);

   /*
     Nouvelle forme de la gaussienne a ajuster. on lui retire un fond.
   */
   for (i=0; i < npt; i++) {
      x[i] = (float)i;
      y[i] = (float)i;
      for (j=0; j < npt; j++) {
         z[i][j] = zs[i][j] - min;
         sig[i][j]=(float)0.001;
      }
   }

	for (i=1;i<=MA;i++) {
		ia[i] = 1;
	}

   /*
     Nouvelle forme des parametres a ajuster (on a soustrait le fond)
   */
   a[1] = 0;
   a[2] = max-min;
   a[3] = x0;
   a[4] = y0;
   a[5] = (float)1.1;
   a[6] = 1.0;
   a[7] = 0 * M_PI / (float)180;

   sky = min;

   /*
     Lancement des iterations generales
   */
   cpt=0;
   /* n <= 1 : mode calcul rapide */
   /* n <= 3 : mode high precision */
	for (n=1;n<=3;n++) {

      k = 0;

      /*
        Ajustement Initial
      */
      alamda = -1;
      mrqmin2D_ThreadSafe(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda, &mrqmin_TS);
      //mrqmin2D(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda);
      cpt++;

      /*
        Lancement des iterations pour un sky fixé
      */
      k = 1;
	   itst=0;

	   for (;;) {

         if (log) { 
	         printf("\n%s %2d %17s %10.4f %10s %9.2e\n","Iteration #",k,
	            "chi-squared:",chisq,"alamda:",alamda);
	         for (i=1;i<=MA;i++) printf("  a[%d]  ",i); printf("\n");
	         for (i=1;i<=MA;i++) printf("%9.4f",a[i]);
	         printf("\n");
         }

         k++;
		   ochisq=chisq;

         mrqmin2D_ThreadSafe(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda, &mrqmin_TS);
         //mrqmin2D(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda);
         cpt++;

		   if (chisq > ochisq)
			   itst=0;
		   else if (fabs(ochisq-chisq) < 0.001)
			   itst++;

   /* itst < 3 : mode calcul rapide */
   /* itst < 4 : mode high precision */
		   if (itst < 4 && k < 30) continue;

		   alamda=0.0;
         mrqmin2D_ThreadSafe(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda, &mrqmin_TS);
         //mrqmin2D(x,y,z,sig,npt,a,ia,MA,covar,alpha,&chisq,fgauss1_2d,&alamda);
         cpt++;

         if (log) { 
		      printf("\nUncertainties:\n");
	         for (i=1;i<=MA;i++) printf(" dea[%d] ",i); printf("\n");
		      for (i=1;i<=MA;i++) printf("%9.4f",sqrt(covar[i][i]));
		      printf("\n");
         }

         /*
         printf("press return to continue with constraint\n");
         (void) getchar();
         */

		   break;
      }

      /*
        Calcul du nouveau sky
      */
      mean = 0;
      for(i=0;i<npt;i++) {
         for(j=0;j<npt;j++) {
            fgauss1_2d(x[i], y[j], a, &z[i][j], dyda, MA);
            residus[i][j] = sky + z[i][j] - zs[i][j];
            mean += residus[i][j];
         }
      }
      mean = mean / pow((float)npt,2) ;
      
      if (log) printf("mean = %f a1 = %f\n",mean,a[1]);

      a[1] += mean;
      sky += a[1];
      if (log) printf("sky = %f \n",sky);
      

      /*
        On enleve le sky
      */
      for(i=0;i<npt;i++) {
         for(j=0;j<npt;j++) {
            z[i][j] = zs[i][j] - sky;
         }
      }

      if (fabs(a[1])<0.01) break;
         
      a[1] = 0;
      /*
       printf("press return to continue with constraint\n");
       (void) getchar();
      */
   }
   a[1] = sky;

	for (i=1;i<=MA;i++) uncertainties[i] = sqrt(covar[i][i]);

   if (log) { 
		printf("chisq: %f \n",chisq);
		printf("nb mrqmin: %d \n",cpt);
		printf("nb loop: %d \n",n);
		printf("\nUncertainties:\n");
		for (i=1;i<=MA;i++) printf("      %d   ",ia[i]);  printf("\n");
		for (i=1;i<=MA;i++) printf("    a[%d]  ",i); printf("\n");
		for (i=1;i<=MA;i++) printf("%9.4f ",sqrt(covar[i][i]));
		printf("\n");
	}

	free_matrix(z,0,npt-1,0,npt-1);
	free_matrix(residus,0,npt-1,0,npt-1);
	free_matrix(sig,0,npt-1,0,npt-1);
   free_vector(dyda,1,MA);
	free_matrix(alpha,1,MA,1,MA);
	free_matrix(covar,1,MA,1,MA);
	free_ivector(ia,1,MA);
	free_vector(y,0,npt-1);
	free_vector(x,0,npt-1);
   return;

 }
