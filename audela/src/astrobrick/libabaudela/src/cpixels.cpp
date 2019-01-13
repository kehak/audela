/* cpixels.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

#include <math.h>   // floor()
#include <stdlib.h>    // atoi, calloc, free, putenv, getenv
#include <string.h>

#include <abcommon.h>
using namespace abcommon;
#include "cpixels.h"
#include "cerrorlibtt.h"



const char  *  CPixels::PixelClassName  []= {"CLASS_GRAY", "CLASS_RGB"} ;
const char  *  CPixels::PixelFormatName []= {"FORMAT_BYTE", "FORMAT_SHORT", "FORMAT_USHORT", "FORMAT_FLOAT"} ;
const char  *  CPixels::CompressionName []= {"COMPRESS_NONE", "COMPRESS_RGB", "COMPRESS_I420", "COMPRESS_JPEG", "COMPRESS_RAW", "COMPRESS_UNKNOWN"} ;
const char  *  CPixels::ColorPlaneName  []= {"PLANE_GRAY", "PLANE_RGB", "PLANE_RED", "PLANE_GREEN","PLANE_BLUE", "PLANE_UNKNOWN"} ;


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////


CPixels::~CPixels()
{
}

void CPixels::AstroBaricenter(int x1, int y1, int x2, int y2, double *xc, double *yc) {
   int i, j;                          // Index de parcours de l'image
   double flux_pix,flux,sx,sy;
   TYPE_PIXELS *offset;
   TYPE_PIXELS *pixTemp;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   naxis1 = x2-x1+1;
   naxis2 = y2-y1+1;
   pixTemp = (TYPE_PIXELS *) malloc(naxis1 * naxis2 * sizeof(float));
   getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void*) pixTemp);

   *yc=0.;
   *xc=0.;
   flux = (float)0;
   sx = (float)0;
   sy = (float)0;
   for(j=0;j<naxis2;j++) {
      offset = pixTemp + j * naxis1;
      for(i=0;i<naxis1;i++) {
         flux_pix = (double)*(offset+i);
         flux += flux_pix;
         sx += i * flux_pix;
         sy += j * flux_pix;
      }
   }
   if (flux!=0.) {
      *xc = sx / flux ;
      *yc = sy / flux ;
   }
   free(pixTemp);
}



void CPixels::AstroCentro(int x1, int y1, int x2, int y2, int xmax, int ymax,
                                TYPE_PIXELS seuil, float* somx, float* somy, float* somr) {
   int i, j;                          // Index de parcours de l'image
   TYPE_PIXELS flux = (TYPE_PIXELS)0;
   TYPE_PIXELS *offset;
   TYPE_PIXELS flux_pix;
   float sx = (float)0.;              // Somme ponderee des pixels en x
   float sy = (float)0.;              // Somme ponderee des pixels en y
   float r=   (float)0.;
   TYPE_PIXELS *pixTemp;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   naxis1 = x2-x1+1;
   naxis2 = y2-y1+1;
   pixTemp = (TYPE_PIXELS *) malloc(naxis1 * naxis2 * sizeof(float));
   getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void*) pixTemp);

   //changement de coordonnees  (image entiere -> fenetre)
   xmax -= x1;
   ymax -= y1;

   for(j=0;j<naxis2;j++) {
      offset = pixTemp + j * naxis1;
      for(i=0;i<naxis1;i++) {
         flux_pix = *(offset+i);
         if(flux_pix>seuil) {
            flux += flux_pix;
            sx += i * flux_pix;
            sy += j * flux_pix;
         }
      }
   }
   if (flux==0.) {
      sx=(float)xmax;
      sy=(float)ymax;
   } else {
      sx = sx / flux ;
      sy = sy / flux ;
   }
   r=(float)sqrt((sx-xmax)*(sx-xmax)+(sy-ymax)*(sy-ymax));
   sx+=(float)1. + x1;
   sy+=(float)1. + y1;
   *somx = sx;
   *somy =sy;
   *somr = r;
   free(pixTemp);
}

void CPixels::AstroFlux(int x1, int y1, int x2, int y2,
                        TYPE_PIXELS* flux, TYPE_PIXELS* maxi,
                        int *xmax, int* ymax, TYPE_PIXELS *moy,
                        TYPE_PIXELS *seuil, int *nbpix) {
   int i, j;                          // Index de parcours de l'image
   TYPE_PIXELS *offset;
   TYPE_PIXELS fond;
   double *vec;
   TYPE_PIXELS *pixTemp;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   naxis1 = x2-x1+1;
   naxis2 = y2-y1+1;
   pixTemp = (TYPE_PIXELS *) malloc(naxis1 * naxis2 * sizeof(float));
   getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void*) pixTemp);

   *nbpix=naxis1 * naxis2;

   // Vecteur pour le calcul de l'histogramme du fond
   if ( (vec=(double*)calloc((*nbpix)+1,sizeof(double)))==NULL) {
      throw CErrorAudela( ELIBSTD_NO_MEMORY_FOR_PIXELS);;
   }

   *maxi=*(pixTemp);
   *flux=(float)0.;
   *nbpix=0;
   for(j=0;j<naxis2;j++) {
      offset = pixTemp + j * naxis1;
      for(i=0;i<naxis1;i++) {
         *flux += *(offset+i);
         (*nbpix)++;
         vec[*nbpix]=*(offset+i);
         if (*(offset+i)>=*maxi) {
            *maxi=*(offset+i);
            *xmax=i;
            *ymax=j;
         }
      }
   }

   util_qsort_double(vec,0,*nbpix-2,NULL);
   // calcule la valeur du fond pour 20 pourcent de l'histogramme
   fond=(float)vec[(int)(0.2*(*nbpix-1))];
   // calcule la valeur du fond photometrique a 60 pourcent de l'histogramme
   *moy=(float)vec[(int)(0.6*(*nbpix-1))];
   // calcule le seuil de coupure pour le centroide et le phot
   *seuil=fond+(TYPE_PIXELS)0.7*(*maxi-fond);

   // changement de coordonnees (fenetre -> image entiere)
   *xmax += x1;
   *ymax += y1;

   free(vec);
   free(pixTemp);
}


void CPixels::AstroPhoto(int x1, int y1, int x2, int y2, int xmax, int ymax,
                               TYPE_PIXELS moy, double *dFlux, int* ntot) {
   int i, j;                          // Index de parcours de l'image
   TYPE_PIXELS flux = (TYPE_PIXELS)0;
   TYPE_PIXELS flux_pix;
   int xx1, yy1, xx2, yy2, sortie, rr;
   int nneg,npos;
   TYPE_PIXELS *pixTemp;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   naxis1 = x2-x1+1;
   naxis2 = y2-y1+1;
   pixTemp = (TYPE_PIXELS *) malloc(naxis1 * naxis2 * sizeof(float));
   getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void*) pixTemp);

   //changement de coordonnees  (image entiere -> fenetre)
   xmax -= x1;
   ymax -= y1;

   *dFlux=*(pixTemp+ymax*naxis1+xmax)-moy;
   flux=(float)0;
   rr=0;
   sortie=0;
   *ntot=1;
   while (sortie==0) {
      // on tourne en carr�s concentriques
      rr++;
      xx1=xmax-rr;
      xx2=xmax+rr;
      yy1=ymax-rr;
      yy2=ymax+rr;
      if (xx1<0) { sortie=1; break; }
      if (xx2>=naxis1) { sortie=1; break; }
      if (yy1<0) { sortie=1; break; }
      if (yy2>=naxis2) { sortie=1; break; }
      nneg=0;
      npos=0;
      flux=(float)0.;
      for (i=xx1;i<xx2;i++) {
         j=yy1;
         flux_pix=*(pixTemp+j*naxis1+i)-moy;
         flux+=flux_pix;
         if (flux_pix>=0) { npos++; } else { nneg++; }
      }
      for (i=xx1+1;i<=xx2;i++) {
         j=yy2;
         flux_pix=*(pixTemp+j*naxis1+i)-moy;
         if (flux_pix>=0) { npos++; } else { nneg++; }
         flux+=flux_pix;
      }
      for (j=yy1+1;j<=yy2;j++) {
         i=xx1;
         flux_pix=*(pixTemp+j*naxis1+i)-moy;
         if (flux_pix>=0) { npos++; } else { nneg++; }
         flux+=flux_pix;
      }
      for (j=yy1;j<=yy2+1;j++) {
         i=xx2;
         flux_pix=*(pixTemp+j*naxis1+i)-moy;
         if (flux_pix>=0) { npos++; } else { nneg++; }
         flux+=flux_pix;
      }
      if (npos>nneg) {
         (*dFlux)+=flux;
         (*ntot)+=(npos+nneg);
      } else {
         sortie=1; break;
      }
   }
   if ((*dFlux)<=0.) {(*dFlux)=1.;}
   free(pixTemp);
}


void CPixels::AstroPhotometry(int x1, int y1, int x2, int y2,
                                int method, double r1, double r2,double r3,
                                double *flux, double* f23, double* fmoy,
                                double* sigma, int *n1) {

   int i, j;                          // Index de parcours de l'image
   TYPE_PIXELS *offset;
   int n23, xx1,xx2,yy1,yy2,n,xxx1,xxx2,yyy1,yyy2,n23d,n23f;
   double r11,r22,r33;
   double xc=0.,yc=0.,mini,maxi,flux_pix,sx,sy,*vec,f1;
   double dx,dy,dx2,dy2,d2;
   TYPE_PIXELS *pixTemp;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   naxis1 = x2-x1+1;
   naxis2 = y2-y1+1;
   pixTemp = (TYPE_PIXELS *) malloc(naxis1 * naxis2 * sizeof(float));
   getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void*) pixTemp);

   if (method==0) {
      r1/=2;
      r2/=2;
      r3/=2;
   }
   r11=r1*r1;
   r22=r2*r2;
   r33=r3*r3;
   // --- photocentre approximatif avec changement de coordonnees (image entiere -> fenetre)
   xx1=(int)(x1 -x1);
   xx2=(int)(x2 -x1);
   yy1=(int)(y1 -y1);
   yy2=(int)(y2 -y1);
   mini=1e20;
   maxi=-1e20;
   for (j=yy1;j<=yy2;j++) {
      offset = pixTemp + j * naxis1;
      for (i=xx1;i<=xx2;i++) {
         flux_pix = (double)*(offset+i);
         if (flux_pix<mini) { mini=flux_pix; }
         if (flux_pix>maxi) { maxi=flux_pix; xc=(double)i; yc=(double)j; }
      }
   }
   *flux = (float)0;
   sx = (float)0;
   sy = (float)0;
   for(j=yy1;j<yy2;j++) {
      offset = pixTemp + j * naxis1;
      for(i=xx1;i<xx2;i++) {
         flux_pix = (double)*(offset+i)-mini;
         *flux += flux_pix;
         sx += i * flux_pix;
         sy += j * flux_pix;
      }
   }
   if (*flux!=0.) {
      xc = sx / *flux ;
      yc = sy / *flux ;
   }
   // --- mesure flux integre dans le carre central
   xx1=(int)(xc-r1);
   xx2=(int)(xc+r1);
   yy1=(int)(yc-r1);
   yy2=(int)(yc+r1);
   if (xx1<0) xx1=0;
   if (xx1>naxis1) xx1=naxis1-1;
   if (xx2<0) xx2=0;
   if (xx2>naxis1) xx2=naxis1-1;
   if (yy1<0) yy1=0;
   if (yy1>naxis2) yy1=naxis2-1;
   if (yy2<0) yy2=0;
   if (yy2>naxis2) yy2=naxis2-1;
   *n1=0;
   f1=0.;
   if (method==0) {
      for (j=yy1;j<=yy2;j++) {
         offset = pixTemp + j * naxis1;
         for (i=xx1;i<=xx2;i++) {
            f1 += (double)*(offset+i);
            (*n1)++;
         }
      }
   }
   if (method==1) {
      for (j=yy1;j<=yy2;j++) {
         offset = pixTemp + j * naxis1;
         dy=1.*j-yc;
         dy2=dy*dy;
         for (i=xx1;i<=xx2;i++) {
            dx=1.*i-xc;
            dx2=dx*dx;
            if ((dx2+dy2)<=r11) {
               f1 += (double)*(offset+i);
               (*n1)++;
            }
         }
      }
   }
   // --- mesure flux median dans la courone
   xx1=(int)(xc-r3);
   xx2=(int)(xc+r3);
   yy1=(int)(yc-r3);
   yy2=(int)(yc+r3);
   if (xx1<0) xx1=0;
   if (xx1>naxis1) xx1=naxis1-1;
   if (xx2<0) xx2=0;
   if (xx2>naxis1) xx2=naxis1-1;
   if (yy1<0) yy1=0;
   if (yy1>naxis2) yy1=naxis2-1;
   if (yy2<0) yy2=0;
   if (yy2>naxis2) yy2=naxis2-1;
   xxx1=(int)(xc-r2);
   xxx2=(int)(xc+r2);
   yyy1=(int)(yc-r2);
   yyy2=(int)(yc+r2);
   if (xxx1<0) xxx1=0;
   if (xxx1>naxis1) xxx1=naxis1-1;
   if (xxx2<0) xxx2=0;
   if (xxx2>naxis1) xxx2=naxis1-1;
   if (yyy1<0) yyy1=0;
   if (yyy1>naxis2) yyy1=naxis2-1;
   if (yyy2<0) yyy2=0;
   if (yyy2>naxis2) yyy2=naxis2-1;
   n=(xx2-xx1+1)*(yy2-yy1+1)+1;
   if ((vec=(double*)calloc(n,sizeof(double)))==NULL) {
      throw CErrorAudela( ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }
   n23=0;
   *f23=0.;
   if (method==0) {
      for (j=yy1;j<=yyy1;j++) {
         offset = pixTemp + j * naxis1;
         for (i=xx1;i<=xx2;i++) {
            vec[n23] = (double)(*(offset+i));
            *f23 += vec[n23];
            n23++;
         }
      }
      for (j=yyy2;j<=yy1;j++) {
         offset = pixTemp + j * naxis1;
         for (i=xx1;i<=xx2;i++) {
            vec[n23] = (double)(*(offset+i));
            *f23 += vec[n23];
            n23++;
         }
      }
      for (j=yyy1+1;j<=yyy2-1;j++) {
         offset = pixTemp + j * naxis1;
         for (i=xx1;i<=xxx1;i++) {
            vec[n23] = (double)(*(offset+i));
            *f23 += vec[n23];
            n23++;
         }
      }
      for (j=yyy1+1;j<=yyy2-1;j++) {
         offset = pixTemp + j * naxis1;
         for (i=xxx2;i<=xx2;i++) {
            vec[n23] = (double)(*(offset+i));
            *f23 += vec[n23];
            n23++;
         }
      }
   }
   if (method==1) {
      for (j=yy1;j<=yy2;j++) {
         offset = pixTemp + j * naxis1;
         dy=1.*j-yc;
         dy2=dy*dy;
         for (i=xx1;i<=xx2;i++) {
            dx=1.*i-xc;
            dx2=dx*dx;
            d2=dx2+dy2;
            if ((d2>=r22)&&(d2<=r33)) {
               vec[n23] = (double)(*(offset+i));
               *f23 += (double)*(offset+i);
               n23++;
            }
         }
      }
   }
   util_qsort_double(vec,0,n23,NULL);
   *fmoy=vec[0];
   if (n23!=0) {*fmoy=*f23/n23;}
   // calcule la valeur du fond pour 50 pourcent de l'histogramme
   *f23=(float)vec[(int)(0.5*n23)];
   // --- calcul du flux dans l'etoile seule
   *flux=f1-*f23*(*n1);
   // --- calcul de l'ecart type du fond de ciel
   // --- en excluant les extremes a +/- 10 %
   *sigma=0.;
   n23d=(int)(0.1*(n23-1));
   n23f=(int)(0.9*(n23-1));
   for (i=n23d;i<=n23f;i++) {
      d2=(vec[i]-(*f23));
      *sigma+=(d2*d2);
   }
   if ((n23f-n23d)!=0) {
      *sigma=sqrt(*sigma/(n23f-n23d));
   }

   free(vec);
   free(pixTemp);
}


void CPixels::fitgauss1d(int n,double *y,double *p,double *ecart)
/***************************************************/
/* Ajuste une gaussienne :                         */
/* ENTREES :                                       */
/*  y()=tableau des points                         */
/*  n=nombre de points dans le tableau y           */
/* SORTIES                                         */
/*  p()=tableau des variables:                     */
/*     p[0]=intensite maximum de la gaussienne     */
/*     p[1]=indice du maximum de la gaussienne     */
/*     p[2]=fwhm                                   */
/*     p[3]=fond                                   */
/*  ecart=ecart-type                               */
/***************************************************/
{
   int l,nbmax,m;
   double l1,l2=0.,a0;
   double e,er1,x,y0;
   double m0,m1;
   double e1[4];
   int i,j;

   p[0]=y[0];
   p[1]=0.;
   p[3]=1e9;
   for (i=1;i<n;i++) {
      if (y[i]>p[0]) {p[0]=y[i]; p[1]=1.*i; }
      if (y[i]<p[3]) {p[3]=y[i]; }
   }
   p[0]-=p[3];
   if (p[0]<=0.) {p[0]=10.;}
   p[2]=2.;
   *ecart=1.0;
   l=4;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=250;         /* nombre maximum d'iterations */
   for (i=0;i<l;i++) {
      e1[i]=er1;
   }
   m=0;
   l1=(double)1e10;
fitgauss1d_b1:
   for (i=0;i<l;i++) {
      a0=p[i];
      fitgauss1d_b2:
      l2=0;
      for (j=0;j<n;j++) {
         x=(double)j;
         if(fabs(p[2])>1e-3) {
            y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
         } else {
            y0=1e10;
         }
         l2=l2+(y[j]-y0)*(y[j]-y0);
      }
      m0=l2;
      p[i]=a0*(1-e1[i]);
      l2=0;
      for (j=0;j<n;j++) {
         x=(float)j;
         if(fabs(p[2])>1e-3) {
            y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
         } else {
            y0=1e10;
         }
         l2=l2+(y[j]-y0)*(y[j]-y0);
      }
      *ecart=sqrt((double)l2/(n-l));
      m1=l2;
      if (m1>m0) e1[i]=-e1[i]/2;
      if (m1<m0) e1[i]=(float)1.2*e1[i];
      if (m1>m0) p[i]=a0;
      if (m1>(m0*(1.+1e-15)) ) goto fitgauss1d_b2;
   }
   m++;
   if (m==nbmax) {p[2]=sqrt(p[2])/.601; return; }
   if (l2==0) {p[2]=sqrt(p[2])/.601; return; }
   if (fabs((l1-l2)/l2)<e) {p[2]=sqrt(p[2])/.601; return; }
   l1=l2;
   goto fitgauss1d_b1;
}

void CPixels::fitgauss1d_a(int n,double *y,double *p,double *ecart)
/***************************************************/
/* Ajuste une gaussienne :                         */
/* ENTREES :                                       */
/*  y()=tableau des points                         */
/*  n=nombre de points dans le tableau y           */
/* SORTIES                                         */
/*  p()=tableau des variables:                     */
/*     p[0]=intensite maximum de la gaussienne     */
/*     p[1]=indice du maximum de la gaussienne     */
/*     p[2]=fwhm (n'est pas ajustee)               */
/*     p[3]=fond                                   */
/*  ecart=ecart-type                               */
/***************************************************/
{
   int l,nbmax,m;
   double l1,l2=0.,a0;
   double e,er1,x,y0;
   double m0,m1;
   double e1[4];
   int i,j;
//   double maxi;
   p[0]=y[0];
   p[1]=0.;
   p[3]=1e9;
   for (i=1;i<n;i++) {
      if (y[i]>p[0]) {p[0]=y[i]; p[1]=1.*i; }
      if (y[i]<p[3]) {p[3]=y[i]; }
   }
   p[0]-=p[3];
   if (p[0]<=0.) {p[0]=10.;}
   p[2]=p[2]*p[2]*.601*.601;
   *ecart=1.0;
   l=4;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=250;         /* nombre maximum d'iterations */
   for (i=0;i<l;i++) {
      e1[i]=er1;
   }
   e1[2]=(float)0.;
   m=0;
   l1=(double)1e10;
fitgauss1d_a_b1:
   for (i=0;i<l;i++) {
	  if (i==2) continue;
      a0=p[i];
      fitgauss1d_a_b2:
      l2=0;
      for (j=0;j<n;j++) {
         x=(double)j;
         if(fabs(p[2])>1e-3) {
            y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
         } else {
            y0=1e10;
         }
         l2=l2+(y[j]-y0)*(y[j]-y0);
      }
      m0=l2;
      p[i]=a0*(1-e1[i]);
      l2=0;
      for (j=0;j<n;j++) {
         x=(float)j;
         if(fabs(p[2])>1e-3) {
            y0=p[0]*exp(-(x-p[1])*(x-p[1])/p[2])+p[3];
         } else {
            y0=1e10;
         }
         l2=l2+(y[j]-y0)*(y[j]-y0);
      }
      *ecart=sqrt((double)l2/(n-l));
      m1=l2;
      if (m1>m0) e1[i]=-e1[i]/2;
      if (m1<m0) e1[i]=(float)1.2*e1[i];
      if (m1>m0) p[i]=a0;
      if (m1>m0) goto fitgauss1d_a_b2;
   }
   m++;
   if (m==nbmax) {p[2]=sqrt(p[2])/.601; return; }
   if (l2==0) {p[2]=sqrt(p[2])/.601; return; }
   if (fabs((l1-l2)/l2)<e) {p[2]=sqrt(p[2])/.601; return; }
   l1=l2;
   goto fitgauss1d_a_b1;
}

/***************************************************/
/* Ajuste une gaussienne 2d:                       */
/* ENTREES :                                       */
/*  **y=matrice des points                         */
/*  sizex=nombre de points sur cote 1 de y         */
/*  sizey=nombre de points sur cote 2 de y         */
/* SORTIES                                         */
/*  p()=tableau des variables:                     */
/*     p[0]=intensite maximum de la gaussienne     */
/*     p[1]=indice X du maximum de la gaussienne   */
/*     p[2]=fwhm X                                 */
/*     p[3]=fond                                   */
/*     p[4]=indice Y du maximum de la gaussienne   */
/*     p[5]=fwhm Y                                 */
/*  ecart=ecart-type                               */
/***************************************************/
void CPixels::fitgauss2d(int sizex, int sizey,double **y,double *p,double *ecart) {

   int l,nbmax,m;
   double l1,l2,a0;
   double e,er1,y0;
   double m0,m1;
   double e1[6]; /* ici ajout */
   int i,jx,jy;
   double rr2;
   double xx,yy;
   p[0]=y[0][0];
   p[1]=0.;
   p[3]=y[0][0];
   p[4]=0.;

   for (jx=0;jx<sizex;jx++) {
      for (jy=0;jy<sizey;jy++) {
	      if (y[jx][jy]>p[0]) {p[0]=y[jx][jy]; p[1]=1.*jx; p[4]=1.*jy; }
         if (y[jx][jy]<p[3]) {p[3]=y[jx][jy]; }
      }
   }

   p[0]-=p[3];
   p[2]=1.;
   p[5]=1.;
   *ecart=1.0;
   l=6;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=250;         /* nombre maximum d'iterations */

   for (i=0;i<l;i++) {
	 e1[i]=er1;
   }

   m=0;
   l1=(double)1e10;
   l2=0;
   fitgauss2d_b1:

   for (i=0;i<l;i++) {
	   a0=p[i];
      fitgauss2d_b2:
	   l2=0;
	   for (jx=0;jx<sizex;jx++) {
	      xx=(double)jx;
	      for (jy=0;jy<sizey;jy++) {
	         yy=(double)jy;
	         rr2=(xx-p[1])*(xx-p[1])+(yy-p[4])*(yy-p[4]);
	         y0=p[0]*exp(-rr2/p[2]/p[5])+p[3];
//	         y0=y0*Mask[jx][jy];
	         l2=l2+(y[jx][jy]-y0)*(y[jx][jy]-y0);
         }
	   }

      m0=l2;
      p[i]=a0*(1-e1[i]);
      l2=0;

	   for (jx=0;jx<sizex;jx++) {
	      xx=(double)jx;
	      for (jy=0;jy<sizey;jy++) {
	         yy=(double)jy;
	         rr2=(xx-p[1])*(xx-p[1])+(yy-p[4])*(yy-p[4]);
	         y0=p[0]*exp(-rr2/p[2]/p[5])+p[3];
//	         y0=y0*Mask[jx][jy];
	         l2=l2+(y[jx][jy]-y0)*(y[jx][jy]-y0);
         }
	   }

      *ecart=sqrt((double)l2/(sizex*sizey-l)); /* ici ajout */
      m1=l2;
      if (m1>m0) e1[i]=-e1[i]/2;
      if (m1<m0) e1[i]=(float)1.2*e1[i];
      if (m1>m0) p[i]=a0;
      if (m1>m0) goto fitgauss2d_b2;
   }
   m++;
   if (m==nbmax) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
   if (l2==0) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
   if (fabs((l1-l2)/l2)<e) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
   l1=l2;
   goto fitgauss2d_b1;
}

void CPixels::Fwhm(int x1, int y1, int x2, int y2,
                   double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
                   double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
				       double fwhmx0, double fwhmy0)
{
   TYPE_PIXELS *iX, *iY;
   int i, j;
   double *dX, *dY;
   double px[4], py[4];
   TYPE_PIXELS pixel;
   int width, height;
   TYPE_PIXELS *ppixels;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   if((x1<0)||(x2<0)||(x1>naxis1-1)||(x2>naxis1-1)) {
      throw CErrorAudela( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   }
   if((y1<0)||(y2<0)||(y1>naxis2-1)||(y2>naxis2-1)) {
      throw CErrorAudela( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }

   if(x1>x2) {i = x2; x2 = x1; x1 = i;}
   if(y1>y2) {i = y2; y2 = y1; y1 = i;}

   width = x2-x1+1;
   height = y2-y1+1;
   ppixels = (TYPE_PIXELS *) malloc(width * height * sizeof(TYPE_PIXELS));
   getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void*) ppixels);

   iX = (TYPE_PIXELS*)calloc(width,sizeof(TYPE_PIXELS));
   dX = (double*)calloc(width,sizeof(double));
   iY = (TYPE_PIXELS*)calloc(height,sizeof(TYPE_PIXELS));
   dY = (double*)calloc(height,sizeof(double));

   //--- Mise a zero des deux buffers de binning
   for(i=0;i<width;i++) *(iX+i) = (float)0.;
   for(i=0;i<height;i++) *(iY+i) = (float)0.;

   for(j=0;j<height;j++) {
      for(i=0;i<width;i++) {
         pixel = *(ppixels+width*j+i);
         *(iX+i) += pixel;
         *(iY+j) += pixel;
      }
   }

   for(i=0;i<width;i++) *(dX+i) = (double)*(iX+i);
   for(i=0;i<height;i++) *(dY+i) = (double)*(iY+i);

   if (fwhmx0==0.) {
      fitgauss1d(width,dX,px,errx);
   } else {
      px[2]=fwhmx0;
      fitgauss1d_a(width,dX,px,errx);
      px[2]=fwhmx0;
   }
   if (fwhmy0==0.) {
      fitgauss1d(height,dY,py,erry);
   } else {
      py[2]=fwhmy0;
      fitgauss1d_a(height,dY,py,erry);
      py[2]=fwhmy0;
   }

   *maxx  = px[0];
   *posx  = px[1];
   *fwhmx = px[2];
   *fondx = px[3];

   *maxy  = py[0];
   *posy  = py[1];
   *fwhmy = py[2];
   *fondy = py[3];

   free(iX);
   free(dX);
   free(iY);
   free(dY);
   free(ppixels);

}

void CPixels::Fwhm2d(int x1, int y1, int x2, int y2,
                  double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
                  double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
                  double , double )
{
   double **iXY;
   int i, j;
   double pxy[6];
   TYPE_PIXELS pixel;
   TYPE_PIXELS *ppixels;
   int width, height;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
   if((x1<0)||(x2<0)||(x1>naxis1-1)||(x2>naxis1-1)) {
      throw CErrorAudela( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   }
   if((y1<0)||(y2<0)||(y1>naxis2-1)||(y2>naxis2-1)) {
      throw CErrorAudela( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }

   if(x1>x2) {i = x2; x2 = x1; x1 = i;}
   if(y1>y2) {i = y2; y2 = y1; y1 = i;}

   width = x2-x1+1;
   height = y2-y1+1;
   ppixels = (TYPE_PIXELS *) malloc(width * height * sizeof(TYPE_PIXELS));
   // Yassine
   //getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (int) ppixels);
   getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void *) ppixels);
   iXY = (double**)calloc(width,sizeof(double));
   for(i=0;i<width;i++) {
      *(iXY+i) = (double*)calloc(height,sizeof(double));
   }

   //--- Mise a zero des deux buffers de binning
   for(i=0;i<width;i++) {
      for(j=0;j<height;j++) {
         iXY[i][j]=(double)0.;
      }
   }
   for(j=0;j<height;j++) {
      for(i=0;i<width;i++) {
         pixel = *(ppixels+width*j+i);
         iXY[i][j] += (double)pixel;
      }
   }

   fitgauss2d(width,height,iXY,pxy,errx);
   erry=errx;

   *maxy  = pxy[0];
   *maxx  = pxy[0];
   *posx  = pxy[1] + x1;
   *fwhmx = pxy[2];
   *fondx = pxy[3];
   *fondy = pxy[3];
   *posy  = pxy[4] + y1;
   *fwhmy = pxy[5];

   for(i=0;i<width;i++) {
      free(*(iXY+i));
   }
   free(iXY);
   free(ppixels);
}


/*******************************************************************
 * Ajustement complet d'une gaussienne 2d avec prise en compte de  
 * l'orientation
 * 
 * ENTREES :
 *  x1,y1,x2,y2 : coordonnees en pixel de la zone d'ajustement (entre 0 et naxis-1)
 * 
 * SORTIES
 *   xsm = position y du maximum de la gaussienne
 *   ysm = position y du maximum de la gaussienne
 *   err_xsm = erreur sur la position x du maximum de la gaussienne
 *   err_ysm = erreur sur la position y du maximum de la gaussienne
 *   fwhmx = FWHM x
 *   fwhmy = FWHM y
 *   fwhm = FWHM moyenne
 *   flux = flux de la source
 *   err_flux = erreur sur le flux de la source
 *   pixmax = pixel d'intensite maximum
 *   intensity = intensite maximum de la gaussienne
 *   sky = intensite du fond de ciel
 *   err_sky = erreur sur l'intensite du fond de ciel
 *   snint = 
 *   radius = rayon d'ouverture de la zone mesuree
 *   err_psf = different de zero si la mesure de PSF n'est pas correcte
 *   residus = buffer image des residus apres mesure de la PSF
 *   synthetic = buffer image de la PSF ajsute
 *
 * Remarque: si la zone d'analyse depasse les limites physiques de l'image
 * (e.g. <0 ou >naxis-1) alors la fonction renvoie le code err_psf=1
 *
 * Codes d'erreur err_psf:
 *   0: no error
 *   1: source trop proche du bord de l'image
 *   2: x ou y NaN
 *   3: x ou y en dehors de l'image
 *   
 * Usage test: buf1 psfimcce {426 863 477 903}
 ********************************************************************/
void CPixels::psfimcce(int x1, int y1, int x2, int y2,
                       double *xsm, double *ysm, double *err_xsm, double *err_ysm,
                       double *fwhmx, double *fwhmy, double *fwhm, double *flux,
                       double *err_flux, double *pixmax, double *intensity, double *sky,
                       double *err_sky, double *snint, int *radius, int *err_psf,
                       float **residus, float **synthetic)
{

   int i, j, itemp;
   double pxy[17];
   TYPE_PIXELS pixel;
   TYPE_PIXELS *ppixels;
   int width, height, lradius;
   int naxis1, naxis2;
   int ssquare, x1n, y1n, x2n, y2n;
   double **iXY;

   // Redefinie la zone tq x1<x2 et y1<y2
   if (x1>x2) {itemp = x2; x2 = x1; x1 = itemp;}
   if (y1>y2) {itemp = y2; y2 = y1; y1 = itemp;}

   // Verifie que la zone est comprise entre 0 et naxis-1
   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
/*
   if (x1<0) {x1=0;}
   if (x2<0) {x2=0;}
   if (y1<0) {y1=0;}
   if (y2<0) {y2=0;}
   if (x1>naxis1-1) {x1=naxis1-1;}
   if (x2>naxis1-1) {x2=naxis1-1;}
   if (y1>naxis2-1) {y1=naxis2-1;}
   if (y2>naxis2-1) {y2=naxis2-1;}
*/
   // Reduit la zone selectionnee au carre de plus petite dimension
   ssquare = x2-x1;
   if (ssquare > y2-y1) { ssquare = y2-y1; }
   // Coordonnees de la zone carree qui a ete selectionnee
   x1n = x1 + (x2-x1-ssquare)/2;
   y1n = y1 + (y2-y1-ssquare)/2;
   x2n = x1 + (x2-x1+ssquare)/2;
   y2n = y1 + (y2-y1+ssquare)/2;
   x1 = x1n;
   y1 = y1n;
   x2 = x2n;
   y2 = y2n;

   // Dimensions (carre) de la zone d'analyse
   width = x2-x1+1;
   height = y2-y1+1;
   lradius = width/2;
   if (height < width) { lradius = height/2; }
   //printf("w,h = %d x %d -> %d %d %d %d -> %d\n",width,height,x1,y1,x2,y2,lradius);

   if (x1 < 0 || x2 > naxis1-1 || y1 < 0 || y2 > naxis2-1) {

      *xsm       =  0.0;
      *ysm       =  0.0;
      *err_xsm   =  0.0;
      *err_ysm   =  0.0;
      *fwhmx     =  0.0;
      *fwhmy     =  0.0;
      *fwhm      =  0.0;
      *flux      =  0.0;
      *err_flux  =  0.0;
      *pixmax    =  0.0;
      *intensity =  0.0;
      *sky       =  0.0;
      *err_sky   =  0.0;
      *snint     =  0.0;
      *radius    =  lradius;
      *err_psf   =  1;

   } else {
   
      // Recupere la zone de l'image a analyser
      ppixels = (TYPE_PIXELS *) malloc(width * height * sizeof(TYPE_PIXELS));
      getPixels(x1, y1, x2, y2, FORMAT_FLOAT, PLANE_GREY, (void*) ppixels);
   
      // Allocation du buffer contenant l'image a analyser
      iXY = (double**) calloc(width,sizeof(double));
      for(i=0;i<width;i++) {
         *(iXY+i) = (double*) calloc(height,sizeof(double));
      }
      // Affectation du buffer image
      for(j=0;j<height;j++) {
         for(i=0;i<width;i++) {
            pixel = *(ppixels+width*j+i);
            iXY[i][j] = (double) pixel;
         }
      }
   
      //-- DEBUG ------
/*
      printf("Source analysee:\n");
      printf("       ");
      for(i=0;i<width;i++) printf("%2d   ",i);
      printf("\n");
      FILE *file;
      file = fopen("/usr/local/src/audela/bin/img.dat","w");
      for(i=0;i<width;i++) {
         printf("%2d : ",i);
         for(j=0;j<height;j++) {
            fprintf(file,"img[%d][%d] = %4.0f ;\n",i,j,iXY[i][j]);
            fwrite(&iXY[i][j],sizeof(double),1,file); 
         }
         printf("\n");
      }
      fclose(file);
*/
      //---------------
   
      // Appel de la methode d'ajustement
      psfimcce_compute(width, iXY, pxy, residus, synthetic);
   
      // Results from psfimcce_compute :
      *xsm       =  pxy[0] + x1 + 1;
      *ysm       =  pxy[1] + y1 + 1;
      *err_xsm   =  pxy[2];
      *err_ysm   =  pxy[3];
      *fwhmx     =  pxy[4];
      *fwhmy     =  pxy[5];
      *fwhm      =  pxy[6];
      *flux      =  pxy[7];
      *err_flux  =  pxy[8];
      *pixmax    =  pxy[9];
      *intensity =  pxy[10];
      *sky       =  pxy[11];
      *err_sky   =  pxy[12];
      *snint     =  pxy[13];
      *radius    =  (int) pxy[14];
      *err_psf   =  (int) pxy[15];
      if (*xsm < 0 || *xsm > naxis1-1) { *err_psf = 3; }
      if (*ysm < 0 || *ysm > naxis2-1) { *err_psf = 3; }

      // Clean memory
      for(i=0;i<width;i++) {
         free(*(iXY+i));
      }
      free(iXY);
      free(ppixels);
   }

}


TPixelClass CPixels::getPixelClass() {
   return CLASS_GRAY;
}



TPixelClass CPixels::getPixelClass(const char * className) {
   TPixelClass result = CLASS_UNKNOWN;

   if (className != NULL ) {
      for(int i=0; i < CLASS_UNKNOWN; i++) {
         if( strcmp(className, PixelClassName[i] ) == 0 ) {
            result = (TPixelClass)i;
         }
      }
   }

   return result;
}

char * CPixels::getPixelClassName(TPixelClass value) {
   return (char*) PixelClassName[value];
}


//---------------------------------------------------------------------
/**
 * getPixelCompression
 *   retourne l'identifiant de la methode de compression
 *
 * Parameters:
 *    value  : name
 * Results:
 *    returns  ident or FORMAT_UNKNOWN if name is not found
 * Side effects:
 *    none
 */
TPixelFormat CPixels::getPixelFormat(const char * formatName) {
   TPixelFormat result = FORMAT_UNKNOWN;

   if (formatName != NULL ) {
      for(int i=0; i < FORMAT_UNKNOWN; i++) {
         if( strcmp(formatName, PixelFormatName[i] ) == 0 ) {
            result = (TPixelFormat)i;
         }
      }
   }
   return result;
}

//---------------------------------------------------------------------
/**
 * getPixelFormatName
 *   retourne le nom du format des pixels (byte, ushort, ...)
 *
 * Parameters:
 *    value  : identifiant
 * Results:
 *    returns  name
 * Side effects:
 *    none
 */
char * CPixels::getPixelFormatName(TPixelFormat value) {
   return (char*) PixelFormatName[value];
}

//---------------------------------------------------------------------
/**
 * getPixelCompression
 *   retourne l'identifiant de la methode de compression
 *
 * Parameters:
 *    value  : name
 * Results:
 *    returns  ident or COMPRESS_UNKNOWN if name is not found
 * Side effects:
 *    none
 */
TPixelCompression CPixels::getPixelCompression(const char * compressionName) {
   TPixelCompression result= COMPRESS_UNKNOWN;

   if (compressionName != NULL ) {
      for(int i=0; i < COMPRESS_UNKNOWN; i++) {
         if( strcmp(compressionName, CompressionName[i] ) == 0 ) {
            result = (TPixelCompression)i;
         }
      }
   }
   return result;
}

//---------------------------------------------------------------------
/**
 * getPixelCompressionName
 *   retourne le nom de la methode de compression
 *
 * Parameters:
 *    value  : identifiant
 * Results:
 *    returns  name
 * Side effects:
 *    none
 */
char * CPixels::getPixelCompressionName(TPixelCompression value) {
   return (char*) CompressionName[value];
}


//---------------------------------------------------------------------
/**
 * getColorPlane
 *   retourne l'identifiant du plan
 *
 * Parameters:
 *    value  : name
 * Results:
 *    returns  ident or PLANE_UNKNOWN if name is not found
 * Side effects:
 *    none
 */
TColorPlane CPixels::getColorPlane(const char * planeName) {
   TColorPlane result = PLANE_UNKNOWN;

   if (planeName != NULL ) {
      for(int i=0; i < PLANE_UNKNOWN; i++) {
         if( strcmp(planeName, ColorPlaneName[i] ) == 0 ) {
            result = (TColorPlane)i;
            break;
         }
      }
   }
   return result;
}


//---------------------------------------------------------------------
/**
 * Histogram
 *   calcule l'histogramme de l'image
 *
 * Parameters:
 *    none
 * Results:
 *    returns 1 if pixels are ready, otherwise 0.
 * Side effects:
 *    verifie si une image est charg�e c.a.d si la taille est superieure a 1x1
 */
void CPixels::Histogram(int n, float *adus, float *meanadus, long *histo,
                       int ismini,float mini,int ismaxi,float maxi)
{


   int nelem,k,kk;
   double delta;
   TYPE_PIXELS *pixTemp;
   int naxis1, naxis2;

   naxis1 = this->getWidth();
   naxis2 = this->getHeight();
   pixTemp = (TYPE_PIXELS *) malloc(naxis1 * naxis2 * sizeof(float));
   getPixels(0, 0, naxis1-1, naxis2-1, FORMAT_FLOAT, PLANE_GREY, (void *) pixTemp);
   nelem=naxis1*naxis2;

#ifndef FLT_MAX
#define FLT_MAX 3.402823466e+38F
#endif

#ifndef FLT_MIN
#define FLT_MIN -1.175494351e38F
#endif


   if (ismini==0) {
      mini=FLT_MAX;
      for (k=0;k<nelem;k++) {
         if (pixTemp[k]<mini) {mini=pixTemp[k];}
      }
   }
   if (ismaxi==0) {
      maxi=FLT_MIN;
      for (k=0;k<nelem;k++) {
         if (pixTemp[k]>maxi) {maxi=pixTemp[k];}
      }
   }
   if (mini>=maxi) {
      maxi=mini+1.0f;
   }
   if (n<=0) {n=1;}
   delta=(double)(maxi-mini)/(double)n;
   for (k=0;k<=n;k++) {
      adus[k]=mini+(float)(delta*k);
   }
   for (k=0;k<n;k++) {
      histo[k]=(long)0;
      meanadus[k]=(float)((adus[k]+adus[k+1])/2.0);
   }
   for (k=0;k<nelem;k++) {
      kk=(int)floor((double)(pixTemp[k]-mini)/delta);
      if ((kk>=0)&&(kk<n)) {
         histo[kk]++;
      }
   }
   free(pixTemp);
}



int CPixels::util_qsort_double(double *x,int kdeb,int n,int *index)
/***************************************************************************/
/* Quick sort pour un tableau de double                                    */
/***************************************************************************/
/* x est le tableau qui commence a l'indice 1                              */
/* kdeb la valeur de l'indice a partir duquel il faut trier                */
/* n est le nombre d'elements                                              */
/* index est le tableau des indices une fois le tri effectue (=NULL si on  */
/*  ne veut pas l'utiliser).                                               */
/***************************************************************************/
{
   double qsort_r[50],qsort_l[50];
   int s,l,r,i,j,kfin;
   double v,w;
   int wi;
   int kt1,kt2,kp;
   double m,a;
   int mi,ai;
   kfin=n+kdeb-1;
   /* --- retour immediat si n==1 ---*/
   if (n==1) { return(0); }
   if (index!=NULL) {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
         for (kt1=kdeb;kt1<kfin;kt1++) {
            m=x[kt1];
            mi=index[kt1];
            kp=kt1;
            for (kt2=kt1+1;kt2<=kfin;kt2++) {
               if (x[kt2]<m) {
                  m=x[kt2];
                  mi=index[kt2];
                  kp=kt2;
               }
            }
            a=x[kt1];x[kt1]=m;x[kp]=a;
            ai=index[kt1];index[kt1]=mi;index[kp]=ai;
         }
         return(0);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[kdeb]=kdeb; qsort_r[kdeb]=kfin;
      do {
         l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
         s=s-1;
         do {
            i=l; j=r;
            v=x[(int) (floor((double)(l+r)/(double)2))];
            do {
               while (x[i]<v) {i++;}
               while (v<x[j]) {j--;}
               if (i<=j) {
                  w=x[i];x[i]=x[j];x[j]=w;
                  wi=index[i];index[i]=index[j];index[j]=wi;
                  i++; j--;
               }
            } while (i<=j);
            if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
         } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(0);
   } else {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
         for (kt1=kdeb;kt1<kfin;kt1++) {
            m=x[kt1];
            kp=kt1;
            for (kt2=kt1+1;kt2<=kfin;kt2++) {
               if (x[kt2]<m) {
                  m=x[kt2];
                  kp=kt2;
               }
            }
            a=x[kt1];x[kt1]=m;x[kp]=a;
         }
         return(0);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[kdeb]=kdeb; qsort_r[kdeb]=kfin;
      do {
         l=(int)(qsort_l[s]); r=(int)(qsort_r[s]);
         s=s-1;
         do {
            i=l; j=r;
            v=x[(int) (floor((double)(l+r)/(double)2))];
            do {
               while (x[i]<v) {i++;}
               while (v<x[j]) {j--;}
               if (i<=j) {
                  w=x[i];x[i]=x[j];x[j]=w;
                  i++; j--;
               }
            } while (i<=j);
            if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[s]=i ; qsort_r[s]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[s]=l ; qsort_r[s]=j;} l=i; }
         } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(0);
   }
}
