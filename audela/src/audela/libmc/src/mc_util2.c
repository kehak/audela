/* Ray-Triangle Intersection Test Routines          */
/* Different optimizations of my and Ben Trumbore's */
/* code from journals of graphics tools (JGT)       */
/* http://www.acm.org/jgt/                          */
/* by Tomas Moller, May 2000                        */

#include "mc.h"

#define EPSILON 0.000001
#define CROSS(dest,v1,v2) \
          dest[0]=v1[1]*v2[2]-v1[2]*v2[1]; \
          dest[1]=v1[2]*v2[0]-v1[0]*v2[2]; \
          dest[2]=v1[0]*v2[1]-v1[1]*v2[0];
#define DOT(v1,v2) (v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2])
#define SUB(dest,v1,v2) \
          dest[0]=v1[0]-v2[0]; \
          dest[1]=v1[1]-v2[1]; \
          dest[2]=v1[2]-v2[2]; 


/* code rewritten to do tests on the sign of the determinant */
/* the division is before the test of the sign of the det    */
/* and one CROSS has been moved out from the if-else if-else */
int intersect_triangle(double orig[3], double dir[3],
			double vert0[3], double vert1[3], double vert2[3],
			double *t, double *u, double *v)
{
   double edge1[3], edge2[3], tvec[3], pvec[3], qvec[3];
   double det,inv_det;

   /* find vectors for two edges sharing vert0 */
   SUB(edge1, vert1, vert0);
   SUB(edge2, vert2, vert0);

   /* begin calculating determinant - also used to calculate U parameter */
   CROSS(pvec, dir, edge2);

   /* if determinant is near zero, ray lies in plane of triangle */
   det = DOT(edge1, pvec);

   /* calculate distance from vert0 to ray origin */
   SUB(tvec, orig, vert0);
   inv_det = 1.0 / det;
   
   CROSS(qvec, tvec, edge1);
      
   if (det > EPSILON)
   {
      *u = DOT(tvec, pvec);
      if (*u < 0.0 || *u > det)
	 return 0;
            
      /* calculate V parameter and test bounds */
      *v = DOT(dir, qvec);
      if (*v < 0.0 || *u + *v > det)
	 return 0;
      
   }
   else if(det < -EPSILON)
   {
      /* calculate U parameter and test bounds */
      *u = DOT(tvec, pvec);
      if (*u > 0.0 || *u < det)
	 return 0;
      
      /* calculate V parameter and test bounds */
      *v = DOT(dir, qvec) ;
      if (*v > 0.0 || *u + *v < det)
	 return 0;
   }
   else return 0;  /* ray is parallell to the plane of the triangle */

   *t = DOT(edge2, qvec) * inv_det;
   (*u) *= inv_det;
   (*v) *= inv_det;

   return 1;
}

/****************************************************************************************/
int mc_fitspline(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff)
/****************************************************************************************/
/* Fit by splines with smooth                                                           */
/* Entrees :                                                                            */
/*  x[1..n1..n2]                                                                        */
/*  y[1..n1..n2]                                                                        */
/*  dy[1..n1..n2] (ne pas mettre zero !!!)                                              */
/*  s = parametre de lissage >=0 (=0 spline sans lissage)                               */
/*  xx[1..nn] vecteur des points a calculer                                             */
/*            xx[1]>=x[n1+2] et xx[nn]<=x[n2-1]                                         */
/* Sorties :                                                                            */
/*  ff[1..nn] valeurs calculees pour chaque point du vecteur xx                         */
/*                                                                                      */
/* Attention : les indices commencent a 1                                               */
/* x et xx doivent etre pralablement tries en ordre croissants                          */
/*                                                                                      */
/*Christian H. Reinsch, Numerische Mathematik 10, 177-183 (1967)                        */
/****************************************************************************************/
{
	int i,m1,m2,n,ii;
	double e,f,f2,g=0,h,p;
	double *r,*r1,*r2,*t,*t1,*u,*v;
	double *a,*b,*c,*d;

	n=(n2+1)-(n1-1)+2;
	r=(double*)calloc(n,sizeof(double));
	if (r==NULL) { return 1; }
	r1=(double*)calloc(n,sizeof(double));
	if (r1==NULL) { free(r); return 1; }
	r2=(double*)calloc(n,sizeof(double));
	if (r2==NULL) { free(r); free(r1); return 1; }
	t=(double*)calloc(n,sizeof(double));
	if (t==NULL) { free(r); free(r1); free(r2); return 1; }
	t1=(double*)calloc(n,sizeof(double));
	if (t1==NULL) { free(r); free(r1); free(r2); free(t); return 1; }
	u=(double*)calloc(n,sizeof(double));
	if (u==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; return 1; }
	v=(double*)calloc(n,sizeof(double));
	if (v==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); return 1; }
	a=(double*)calloc(n,sizeof(double));
	if (a==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; return 1; }
	b=(double*)calloc(n,sizeof(double));
	if (b==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); return 1; }
	c=(double*)calloc(n,sizeof(double));
	if (c==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); free(b) ; return 1; }
	d=(double*)calloc(n,sizeof(double));
	if (d==NULL) { free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); free(b); free(c) ; return 1; }

	m1=n1-1;
	m2=n2+1;
	r[m1]=r[n1]=r1[n2]=r2[n2]=r2[m2]=u[m1]=u[n1]=u[n2]=u[m2]=p=0;
	m1=n1+1;
	m2=n2-1;
	h=x[m1]-x[n1];
	f=(y[m1]-y[n1])/h;
	for (i=m1;i<=m2;i++) {
		g=h;
		h=x[i+1]-x[i];
		e=f;
		f=(y[i+1]-y[i])/h;
		a[i]=f-e;
		t[i]=2*(g+h)/3;
		t1[i]=h/3;
		r2[i]=dy[i-1]/g;
		r[i]=dy[i+1]/h;
		r1[i]=-dy[i]/g-dy[i]/h;
	}
	for (i=m1;i<=m2;i++) {
		b[i]=r[i]*r[i]+r1[i]*r1[i]+r2[i]*r2[i];
		c[i]=r[i]*r1[i+1]+r1[i]*r2[i+1];
		d[i]=r[i]*r2[i+2];
	}
	f2=-s;
	while (1==1) {
		//:next_interation
		for (i=m1;i<=m2;i++) {
			r1[i-1]=f*r[i-1];
			r2[i-2]=g*r[i-2];
			r[i]=1/(p*b[i]+t[i]-f*r1[i-1]-g*r2[i-2]);
			u[i]=a[i]-r1[i-1]*u[i-1]-r2[i-2]*u[i-2];
			f=p*c[i]+t1[i]-h*r1[i-1];
			g=h;
			h=d[i]*p;
		}
		for (i=m2;i>=m1;i--) {
			u[i]=r[i]*u[i]-r1[i]*u[i+1]-r2[i]*u[i+2];
		}
		e=h=0;
		for (i=n1;i<=m2;i++) {
			g=h;
			h=(u[i+1]-u[i])/(x[i+1]-x[i]);
			v[i]=(h-g)*dy[i]*dy[i];
			e=e+v[i]*(h-g);
		}
		g=v[n2]=-h*dy[n2]*dy[n2];
		e=e-g*h;
		g=f2;
		f2=e*p*p;
		if ((f2>=s)||(f2<=g)) {
			break;
		}
		f=0;
		h=(v[m1]-v[n1])/(x[m1]-x[n1]);
		for (i=m1;i<=m2;i++) {
			g=h;
			h=(v[i+1]-v[i])/(x[i+1]-x[i]);
			g=h-g-r1[i-1]*r[i-1]-r2[i-2]*r[i-2];
			f=f+g*r[i]*g;
			r[i]=g;
		}
		h=e-p*f;
		if (h<=0) {
			break;
		}
		p=p+(s-f2)/((sqrt(s/e)+p)*h);
		//goto next_iteration;
	}
	// use negative branch of square root, if the sequence of absissae x[i] is strictly decreasing
	for (i=n1;i<=n2;i++) {
		a[i]=y[i]-p*v[i];
		c[i]=u[i];
	}
	for (i=n1;i<=m2;i++) {
		h=x[i+1]-x[i];
		d[i]=(c[i+1]-c[i])/(3*h);
		b[i]=(a[i+1]-a[i])/h-(h*d[i]+c[i])*h;
	}
	// --- compute the final vector
	for (ii=1;ii<=nn;ii++) {
		ff[ii]=0;
		for (i=n1;i<n2;i++) {
			if ((xx[ii]>=x[i])&&(xx[ii]<x[i+1])) {
				h=xx[ii]-x[i];
				ff[ii]=((d[i]*h+c[i])*h+b[i])*h+a[i];
				break;
			}
		}
	}
	free(r); free(r1); free(r2); free(t); free(t1) ; free(u); free(v) ; free(a); free(b); free(c) ; free(d);
	return 0;
}

/****************************************************************************************/
int mc_interplin1(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff)
/****************************************************************************************/
/* Interpolation lineaire */
/* Entrees :                                                                            */
/*  x[1..n1..n2]                                                                        */
/*  y[1..n1..n2]                                                                        */
/*  dy[1..n1..n2] (ne pas mettre zero !!!)                                              */
/*  s = parametre de lissage (non utilise)                                              */
/*  xx[1..nn] vecteur des points a calculer                                             */
/*            xx[1]>=x[n1+2] et xx[nn]<=x[n2-1]                                         */
/* Sorties :                                                                            */
/*  ff[1..nn] valeurs calculees pour chaque point du vecteur xx                         */
/*                                                                                      */
/* Attention : les indices commencent a 1                                               */
/* x et xx doivent etre pralablement tries en ordre croissants                          */
/*                                                                                      */
/****************************************************************************************/
{
	int kk,k,nn1;
	double xx0,delta;
	nn1=n1;
	for (kk=1;kk<=nn;kk++) {
		xx0=xx[kk];
		if (xx0<x[n1]) {
			ff[kk]=0;
			continue;
		}
		if (xx0>x[n2]) {
			ff[kk]=0;
			continue;
		}
		for (k=nn1+1;k<=n2;k++) {
			if (xx0<=x[k]) {
				break;
			}
		}
		delta=x[k]-x[k-1];
		if (delta==0) {
			ff[kk]=(y[k-1]+y[k])/2;
		} else {
			ff[kk]=y[k-1]+(xx0-x[k-1])/delta*(y[k]-y[k-1]);
		}
		nn1=k-1;
	}
	return 0;
}

/****************************************************************************************/
int mc_interplin2(int n1,int n2,double *x, double *y, double *dy, double s,int nn, double *xx, double *ff)
/****************************************************************************************/
/* Interpolation lineaire avec des vecteurs a pas constant                              */
/* Entrees :                                                                            */
/*  x[1..n1..n2]                                                                        */
/*  y[1..n1..n2]                                                                        */
/*  dy[1..n1..n2] (ne pas mettre zero !!!)                                              */
/*  s = parametre de lissage (non utilise)                                              */
/*  xx[1..nn] vecteur des points a calculer                                             */
/*            xx[1]>=x[n1+2] et xx[nn]<=x[n2-1]                                         */
/* Sorties :                                                                            */
/*  ff[1..nn] valeurs calculees pour chaque point du vecteur xx                         */
/*                                                                                      */
/* Attention : les indices commencent a 1                                               */
/* x et xx doivent etre pralablement tries en ordre croissants                          */
/*                                                                                      */
/****************************************************************************************/
{
	int kk,k;
	double xx0,cstx,dx;
	dx=x[2]-x[1];
	cstx=(n2-n1)/(x[n2]-x[n1]);
	for (kk=1;kk<=nn;kk++) {
		xx0=xx[kk];
		k=(int)ceil(1+n1+(xx0-x[n1])*cstx);
		if (k<n1) {
			ff[kk]=0;
			continue;
		}
		if (k>n2) {
			ff[kk]=0;
			continue;
		}
		ff[kk]=y[k-1]+(xx0-x[k-1])/dx*(y[k]-y[k-1]);
	}
	return 0;
}

char *mc_d2s(double val)
/***************************************************************************/
/* Double to String conversion with many digits                            */
/***************************************************************************/
/***************************************************************************/
{
   int kk,nn;
   static char s[200];
   sprintf(s,"%13.12g",val);
	nn=(int)strlen(s);
	for (kk=0;kk<nn;kk++) {
		if (s[kk]!=' ') {
			break;
		}
	}		
   return s+kk;
}

int mc_meo_ruban(double az, double montee,double descente,double largmontee,double largdescente,double amplitude,double *daz)
/***************************************************************************/
/* Fonction du ruban cordeur de MEO                                        */
/***************************************************************************/
/***************************************************************************/
{
	double gise,dazmontee,dazdescente;
	gise=az/(DR)-180;
	/*
	montee=-7; // deg
	descente=7; // deg
	larg=2.; // deg
	amplitude=0.; // arcsec
	*/
	dazmontee=1./(1+exp(-(gise-montee)/largmontee));
	dazdescente=1-1./(1+exp(-(gise-descente)/largdescente));
	*daz=amplitude*dazmontee*dazdescente/3600*(DR);
	return 0;
}

