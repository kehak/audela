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
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#define NR_END 1
#define FREE_ARG char*
#include "psfimcce.h"
#include <math.h>

float gasdev(long *idum)
{
	float ran1(long *idum);
	static int iset=0;
	static float gset;
	float fac,rsq,v1,v2;

	if (*idum < 0) iset=0;
	if  (iset == 0) {
		do {
			v1=(float)(2.0*ran1(idum)-1.0);
			v2=(float)(2.0*ran1(idum)-1.0);
			rsq=v1*v1+v2*v2;
		} while (rsq >= 1.0 || rsq == 0.0);
		fac=(float)(sqrt(-2.0*log(rsq)/rsq));
		gset=v1*fac;
		iset=1;
		return v2*fac;
	} else {
		iset=0;
		return gset;
	}
}

#define SWAP(a,b) {swap=(a);(a)=(b);(b)=swap;}
void covsrt(float **covar, int ma, int ia[], int mfit)
{
	int i,j,k;
	float swap;

	for (i=mfit+1;i<=ma;i++)
		for (j=1;j<=i;j++) covar[i][j]=covar[j][i]=0.0;
	k=mfit;
	for (j=ma;j>=1;j--) {
		if (ia[j]) {
			for (i=1;i<=ma;i++) SWAP(covar[i][k],covar[i][j])
			for (i=1;i<=ma;i++) SWAP(covar[k][i],covar[j][i])
			k--;
		}
	}
}
#undef SWAP

#define SWAP(a,b) {temp=(a);(a)=(b);(b)=temp;}
void gaussj(float **a, int n, float **b, int m)
{
	int *indxc,*indxr,*ipiv;
	int i,icol,irow,j,k,l,ll;
	float big,dum,pivinv,temp;
   irow=0;
   icol=0;
	indxc=ivector(1,n);
	indxr=ivector(1,n);
	ipiv=ivector(1,n);
	for (j=1;j<=n;j++) ipiv[j]=0;
	for (i=1;i<=n;i++) {
		big=0.0;
		for (j=1;j<=n;j++)
			if (ipiv[j] != 1)
				for (k=1;k<=n;k++) {
					if (ipiv[k] == 0) {
						if (fabs(a[j][k]) >= big) {
							big=fabs(a[j][k]);
							irow=j;
							icol=k;
						}
					}
				}
		++(ipiv[icol]);
		if (irow != icol) {
			for (l=1;l<=n;l++) SWAP(a[irow][l],a[icol][l])
			for (l=1;l<=m;l++) SWAP(b[irow][l],b[icol][l])
		}
		indxr[i]=irow;
		indxc[i]=icol;
		/*
        subtil non ?
        if (a[icol][icol] == 0.0) nrerror("gaussj: Singular Matrix");
      */
      if (a[icol][icol] == 0.0) pivinv=(float)1.0e-10;
		pivinv=(float)(1.0/a[icol][icol]);
		a[icol][icol]=1.0;
		for (l=1;l<=n;l++) a[icol][l] *= pivinv;
		for (l=1;l<=m;l++) b[icol][l] *= pivinv;
		for (ll=1;ll<=n;ll++)
			if (ll != icol) {
				dum=a[ll][icol];
				a[ll][icol]=0.0;
				for (l=1;l<=n;l++) a[ll][l] -= a[icol][l]*dum;
				for (l=1;l<=m;l++) b[ll][l] -= b[icol][l]*dum;
			}
	}
	for (l=n;l>=1;l--) {
		if (indxr[l] != indxc[l])
			for (k=1;k<=n;k++)
				SWAP(a[k][indxr[l]],a[k][indxc[l]]);
	}
	free_ivector(ipiv,1,n);
	free_ivector(indxr,1,n);
	free_ivector(indxc,1,n);
}
#undef SWAP


void mrqcof(float x[], float y[], float sig[], int ndata, float a[], int ia[],
	int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float [], float *, float [], int))
{
	int i,j,k,l,m,mfit=0;
	float ymod,wt,sig2i,dy,*dyda;

	dyda=vector(1,ma);
	for (j=1;j<=ma;j++)
		if (ia[j]) mfit++;
	for (j=1;j<=mfit;j++) {
		for (k=1;k<=j;k++) alpha[j][k]=0.0;
		beta[j]=0.0;
	}
	*chisq=0.0;
	for (i=1;i<=ndata;i++) {
		(*funcs)(x[i],a,&ymod,dyda,ma);
		sig2i=(float)(1.0/(sig[i]*sig[i]));
		dy=y[i]-ymod;
		for (j=0,l=1;l<=ma;l++) {
			if (ia[l]) {
				wt=dyda[l]*sig2i;
				for (j++,k=0,m=1;m<=l;m++)
					if (ia[m]) alpha[j][++k] += wt*dyda[m];
				beta[j] += dy*wt;
			}
		}
		*chisq += dy*dy*sig2i;
	}
	for (j=2;j<=mfit;j++)
		for (k=1;k<j;k++) alpha[k][j]=alpha[j][k];
	free_vector(dyda,1,ma);
}




void mrqmin(float x[], float y[], float sig[], int ndata, float a[], int ia[],
	int ma, float **covar, float **alpha, float *chisq,
	void (*funcs)(float, float [], float *, float [], int), float *alamda)
{
	void covsrt(float **covar, int ma, int ia[], int mfit);
	void gaussj(float **a, int n, float **b, int m);
	void mrqcof(float x[], float y[], float sig[], int ndata, float a[],
	int ia[], int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float [], float *, float [], int));
	int j,k,l;
   static int mfit;
   static float ochisq,*atry,*beta,*da,**oneda;

	if (*alamda < 0.0) {
		atry=vector(1,ma);
		beta=vector(1,ma);
		da=vector(1,ma);
		for (mfit=0,j=1;j<=ma;j++)
			if (ia[j]) mfit++;
		oneda=matrix(1,mfit,1,1);
		*alamda=(float)0.001;
		mrqcof(x,y,sig,ndata,a,ia,ma,alpha,beta,chisq,funcs);
		ochisq=(*chisq);
		for (j=1;j<=ma;j++) atry[j]=a[j];
	}
	for (j=1;j<=mfit;j++) {
		for (k=1;k<=mfit;k++) covar[j][k]=alpha[j][k];
		covar[j][j]=(float)(alpha[j][j]*(1.0+(*alamda)));
		oneda[j][1]=beta[j];
	}
	gaussj(covar,mfit,oneda,1);
	for (j=1;j<=mfit;j++) da[j]=oneda[j][1];
	if (*alamda == 0.0) {
		covsrt(covar,ma,ia,mfit);
		covsrt(alpha,ma,ia,mfit);
		free_matrix(oneda,1,mfit,1,1);
		free_vector(da,1,ma);
		free_vector(beta,1,ma);
		free_vector(atry,1,ma);
		return;
	}
	for (j=0,l=1;l<=ma;l++)
		if (ia[l]) atry[l]=a[l]+da[++j];
	mrqcof(x,y,sig,ndata,atry,ia,ma,covar,da,chisq,funcs);
	if (*chisq < ochisq) {
		*alamda *= (float)0.1;
		ochisq=(*chisq);
		for (j=1;j<=mfit;j++) {
			for (k=1;k<=mfit;k++) alpha[j][k]=covar[j][k];
			beta[j]=da[j];
		}
		for (l=1;l<=ma;l++) a[l]=atry[l];
	} else {
		*alamda *= 10.0;
		*chisq=ochisq;
	}
}









void mrqcof2D(float x[], float y[], float **z, float **sig, int ndata, float a[], int ia[],
	int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int))
{
	int ix,iy,j,k,l,m,mfit=0;
	float zmod,wt,sig2i,dy,*dyda;

	dyda = vector(1,ma);
	for (j=1;j<=ma;j++)
		if (ia[j]) mfit++;
	for (j=1;j<=mfit;j++) {
		for (k=1;k<=j;k++) alpha[j][k]=0.0;
		beta[j]=0.0;
	}
	*chisq=0.0;
	for (ix=0;ix<ndata;ix++) {

	   for (iy=0;iy<ndata;iy++) {

		   (*funcs)(x[ix],y[iy],a,&zmod,dyda,ma);
		   sig2i=(float)1.0/(sig[ix][iy]*sig[ix][iy]);
		   dy=z[ix][iy]-zmod;
		   for (j=0,l=1;l<=ma;l++) {
			   if (ia[l]) {
				   wt=dyda[l]*sig2i;
				   for (j++,k=0,m=1;m<=l;m++)
					   if (ia[m]) alpha[j][++k] += wt*dyda[m];
				   beta[j] += dy*wt;
			   }
		   }
		   *chisq += dy*dy*sig2i;

	   }

	}

	for (j=2;j<=mfit;j++)
		for (k=1;k<j;k++) alpha[k][j]=alpha[j][k];
	free_vector(dyda,1,ma);
}






void mrqmin2D_ThreadSafe(float x[], float y[], float **z, float **sig, int ndata, float a[], int ia[],
	int ma, float **covar, float **alpha, float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int), float *alamda, mrqmin_variable_TS *mrqmin_TS)
{


	void covsrt(float **covar, int ma, int ia[], int mfit);
	void gaussj(float **a, int n, float **b, int m);
	void mrqcof2D(float x[], float y[], float **z, float **sig, int ndata, float a[],
	int ia[], int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int));
	int j,k,l;

	if (*alamda < 0.0) {
		(mrqmin_TS->atry)=vector(1,ma);
		(mrqmin_TS->beta)=vector(1,ma);
		(mrqmin_TS->da)=vector(1,ma);
		for ((mrqmin_TS->mfit)=0,j=1;j<=ma;j++)
			if (ia[j]) (mrqmin_TS->mfit)++;
		(mrqmin_TS->oneda)=matrix(1,(mrqmin_TS->mfit),1,1);
		*alamda=(float)0.001;
		mrqcof2D(x,y,z,sig,ndata,a,ia,ma,alpha,(mrqmin_TS->beta),chisq,funcs);
		(mrqmin_TS->ochisq)=(*chisq);
		for (j=1;j<=ma;j++) (mrqmin_TS->atry)[j]=a[j];
	}
	for (j=1;j<=(mrqmin_TS->mfit);j++) {
		for (k=1;k<=(mrqmin_TS->mfit);k++) covar[j][k]=alpha[j][k];
		covar[j][j]=(float)(alpha[j][j]*(1.0+(*alamda)));
		(mrqmin_TS->oneda)[j][1]=(mrqmin_TS->beta)[j];
	}

	gaussj(covar,(mrqmin_TS->mfit),(mrqmin_TS->oneda),1);
	for (j=1;j<=(mrqmin_TS->mfit);j++) (mrqmin_TS->da)[j]=(mrqmin_TS->oneda)[j][1];
	if (*alamda == 0.0) {
		covsrt(covar,ma,ia,(mrqmin_TS->mfit));
		covsrt(alpha,ma,ia,(mrqmin_TS->mfit));
		free_matrix((mrqmin_TS->oneda),1,(mrqmin_TS->mfit),1,1);
		free_vector((mrqmin_TS->da),1,ma);
		free_vector((mrqmin_TS->beta),1,ma);
		free_vector((mrqmin_TS->atry),1,ma);
		return;
	}

	for (j=0,l=1;l<=ma;l++)
		if (ia[l]) (mrqmin_TS->atry)[l]=a[l]+(mrqmin_TS->da)[++j];
	mrqcof2D(x,y,z,sig,ndata,(mrqmin_TS->atry),ia,ma,covar,(mrqmin_TS->da),chisq,funcs);
	if (*chisq < (mrqmin_TS->ochisq)) {
		*alamda *= (float)0.1;
		(mrqmin_TS->ochisq)=(*chisq);
		for (j=1;j<=(mrqmin_TS->mfit);j++) {
			for (k=1;k<=(mrqmin_TS->mfit);k++) alpha[j][k]=covar[j][k];
			(mrqmin_TS->beta)[j]=(mrqmin_TS->da)[j];
		}
		for (l=1;l<=ma;l++) a[l]=(mrqmin_TS->atry)[l];
	} else {
		*alamda *= 10.0;
		*chisq=(mrqmin_TS->ochisq);
	}
}





void mrqmin2D(float x[], float y[], float **z, float **sig, int ndata, float a[], int ia[],
	int ma, float **covar, float **alpha, float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int), float *alamda )
{


	void covsrt(float **covar, int ma, int ia[], int mfit);
	void gaussj(float **a, int n, float **b, int m);
	void mrqcof2D(float x[], float y[], float **z, float **sig, int ndata, float a[],
	int ia[], int ma, float **alpha, float beta[], float *chisq,
	void (*funcs)(float, float, float [], float *, float [], int));
	int j,k,l;

	static int mfit;
	static float ochisq,*atry,*beta,*da,**oneda;

	if (*alamda < 0.0) {
		atry=vector(1,ma);
		beta=vector(1,ma);
		da=vector(1,ma);
		for (mfit=0,j=1;j<=ma;j++)
			if (ia[j]) mfit++;
		oneda=matrix(1,mfit,1,1);
		*alamda=(float)0.001;
		mrqcof2D(x,y,z,sig,ndata,a,ia,ma,alpha,beta,chisq,funcs);
		ochisq=(*chisq);
		for (j=1;j<=ma;j++) atry[j]=a[j];
	}
	for (j=1;j<=mfit;j++) {
		for (k=1;k<=mfit;k++) covar[j][k]=alpha[j][k];
		covar[j][j]=(float)(alpha[j][j]*(1.0+(*alamda)));
		oneda[j][1]=beta[j];
	}

	gaussj(covar,mfit,oneda,1);
	for (j=1;j<=mfit;j++) da[j]=oneda[j][1];
	if (*alamda == 0.0) {
		covsrt(covar,ma,ia,mfit);
		covsrt(alpha,ma,ia,mfit);
		free_matrix(oneda,1,mfit,1,1);
		free_vector(da,1,ma);
		free_vector(beta,1,ma);
		free_vector(atry,1,ma);
		return;
	}

	for (j=0,l=1;l<=ma;l++)
		if (ia[l]) atry[l]=a[l]+da[++j];
	mrqcof2D(x,y,z,sig,ndata,atry,ia,ma,covar,da,chisq,funcs);
	if (*chisq < ochisq) {
		*alamda *= (float)0.1;
		ochisq=(*chisq);
		for (j=1;j<=mfit;j++) {
			for (k=1;k<=mfit;k++) alpha[j][k]=covar[j][k];
			beta[j]=da[j];
		}
		for (l=1;l<=ma;l++) a[l]=atry[l];
	} else {
		*alamda *= 10.0;
		*chisq=ochisq;
	}
}



#define IA 16807
#define IM 2147483647
#define AM (1.0/IM)
#define IQ 127773
#define IR 2836
#define NTAB 32
#define NDIV (1+(IM-1)/NTAB)
#define EPS 1.2e-7
#define RNMX (1.0-EPS)

float ran1(long *idum)
{
	int j;
	long k;
	static long iy=0;
	static long iv[NTAB];
	float temp;

	if (*idum <= 0 || !iy) {
		if (-(*idum) < 1) *idum=1;
		else *idum = -(*idum);
		for (j=NTAB+7;j>=0;j--) {
			k=(*idum)/IQ;
			*idum=IA*(*idum-k*IQ)-IR*k;
			if (*idum < 0) *idum += IM;
			if (j < NTAB) iv[j] = *idum;
		}
		iy=iv[0];
	}
	k=(*idum)/IQ;
	*idum=IA*(*idum-k*IQ)-IR*k;
	if (*idum < 0) *idum += IM;
	j=iy/NDIV;
	iy=iv[j];
	iv[j] = *idum;
	if ((temp=(float)(AM*iy)) > RNMX) return (float)RNMX;
	else return temp;
}
#undef IA
#undef IM
#undef AM
#undef IQ
#undef IR
#undef NTAB
#undef NDIV
#undef EPS
#undef RNMX












void nrerror(char error_text[])
/* Numerical Recipes standard error handler */
{
	fprintf(stderr,"Numerical Recipes run-time error...\n");
	fprintf(stderr,"%s\n",error_text);
	fprintf(stderr,"...now exiting to system...\n");
	exit(1);
}

float *vector(long nl, long nh)
/* allocate a float vector with subscript range v[nl..nh] */
{
	float *v;

	v=(float *)malloc((size_t) ((nh-nl+1+NR_END)*sizeof(float)));
	if (!v) nrerror("allocation failure in vector()");
	return v-nl+NR_END;
}

int *ivector(long nl, long nh)
/* allocate an int vector with subscript range v[nl..nh] */
{
	int *v;

	v=(int *)malloc((size_t) ((nh-nl+1+NR_END)*sizeof(int)));
	if (!v) nrerror("allocation failure in ivector()");
	return v-nl+NR_END;
}

void free_vector(float *v, long nl, long nh)
/* free a float vector allocated with vector() */
{
	free((FREE_ARG) (v+nl-NR_END));
}

void free_ivector(int *v, long nl, long nh)
/* free an int vector allocated with ivector() */
{
	free((FREE_ARG) (v+nl-NR_END));
}

void free_matrix(float **m, long nrl, long nrh, long ncl, long nch)
/* free a float matrix allocated by matrix() */
{
	free((FREE_ARG) (m[nrl]+ncl-NR_END));
	free((FREE_ARG) (m+nrl-NR_END));
}

float **matrix(long nrl, long nrh, long ncl, long nch)
/* allocate a float matrix with subscript range m[nrl..nrh][ncl..nch] */
{
	long i, nrow=nrh-nrl+1,ncol=nch-ncl+1;
	float **m;

	/* allocate pointers to rows */
	m=(float **) malloc((size_t)((nrow+NR_END)*sizeof(float*)));
	if (!m) nrerror("allocation failure 1 in matrix()");
	m += NR_END;
	m -= nrl;

	/* allocate rows and set pointers to them */
	m[nrl]=(float *) malloc((size_t)((nrow*ncol+NR_END)*sizeof(float)));
	if (!m[nrl]) nrerror("allocation failure 2 in matrix()");
	m[nrl] += NR_END;
	m[nrl] -= ncl;

	for(i=nrl+1;i<=nrh;i++) m[i]=m[i-1]+ncol;

	/* return pointer to array of pointers to rows */
	return m;
}

