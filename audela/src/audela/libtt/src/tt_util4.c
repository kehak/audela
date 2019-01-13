/* tt_util4.c
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

#include "tt.h"

// defintion de min() et max() qui n'existent pas par defaut sous Linux
#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

#define X0Y3  0
#define X0Y4  1
#define X0Y5  2
#define X0Y6  3
#define X1Y2  4
#define X1Y3  5
#define X1Y4  6
#define X1Y5  7
#define X2Y1  8
#define X2Y2  9
#define X2Y3 10
#define X2Y4 11
#define X3Y0 12
#define X3Y1 13
#define X3Y2 14
#define X3Y3 15
#define X4Y0 16
#define X4Y1 17
#define X4Y2 18
#define X5Y0 19
#define X5Y1 20
#define X6Y0 21
#define A1   22
#define B1   23
#define A2   24
#define B2   25
#define A3   26
#define B3   27
#define A4   28
#define B4   29
#define A5   30
#define B5   31
#define A6   32
#define B6   33

#define NO_MEMORY 0

void tt_laps_ellip(TT_LAPS *isoph, int nisoph, double forme);
void tt_laps_calc1(int ima, TT_LAPS *isoph);
void tt_laps_calc2(double xj,double yi, TT_LAPS *isoph,int nn);
void tt_laps_calc3(int ima, TT_LAPS *isoph);
void tt_laps_modelise(TT_IMA *p_out, int nisoph, TT_LAPS *isoph,
		   double xc,double yc,double ciel,double cmag,
		   double scale,double forme,int ordre,
		   double pgposang,int imax,int jmax);
void tt_laps_print_err(int errno);
void tt_laps_reportpb(int errno);
void tt_laps_parami(int nisoph, TT_LAPS *isoph,double *radius_max_analyse, double *radius_coeur,double *radius_effective,double *magnitude_totale,double *magnitude_asymptotique,double *brillance_effective,double *brillance_centrale);


void tt_laps_print_err(int errno)
{
}

void tt_laps_reportpb(int errno)
{
}

/************************ tt_laps_ANALYSE **************************/
/*            Calcul des parametres de chaque isophote          */
/*                 et modelisation d'une image                  */
/****************************************************************/
/* adaptation C: A.Klotz                 Algorithme: P.Prugniel */
/*                   -  version du 04/8/92  -                   */
/*--------------------------------------------------------------*/
/* definition des parametres d'entree associes a l'image:       */
/*                                                              */
/*   *NOM_IN        : nom de l'image a analyser                 */
/*   *NOM_OUT       : nom de l'image modelisee                  */
/*   (XC,YC)        : centre approximatif de la galaxie avec    */
/*                    les valeurs entieres au centre des pixels */
/*                    Il faut se placer sur le pixel max de la  */
/*                    galaxie.                                  */
/*   CIEL           : valeur correcte du fond de ciel.          */
/*   CMAG           : constante des magnitudes en mg/arcsec2.   */
/*                    Parametre facultatif (=25 par defaut).    */
/*   SCALE          : echelle sur X en arcsec/pixel             */
/*                    Parametre facultatif (=1 par defaut).     */
/*   FORME          : rapport Y/X des pixels                    */
/*                    Parametre facultatif (=1 par defaut).     */
/*   ORDRE 3        : !=0 si l'on veut calculer les defauts     */
/*                    d'ordre 3 (coefs a et b de fourier)       */
/*                    Parametre facultatif (=0 par defaut).     */
/*   ORDRE 4        : !=0 si l'on veut calculer les defauts     */
/*                    d'ordre 4 (coefs a et b de fourier)       */
/*                    Parametre facultatif (=0 par defaut).     */
/*   ORDRE 5        : !=0 si l'on veut calculer les defauts     */
/*                    d'ordre 5 (coefs a et b de fourier)       */
/*                    Parametre facultatif (=0 par defaut).     */
/*   ORDRE 6        : !=0 si l'on veut calculer les defauts     */
/*                    d'ordre 6 (coefs a et b de fourier)       */
/*                    Parametre facultatif (=0 par defaut).     */
/*   PGPOSANG       : angle de position de l'axe E-W par rapport*/
/*                    a l'axe des X, avec le signe positif dans */
/*                    le sens trigonometrique.                  */
/*                    Parametre facultatif (=0 par defaut).     */
/*   (XD,YD)-(YD,YF): fenetre d'analyse dans l'image. Si tous   */
/*                    les parametres sont nuls alors la fenetre */
/*                    aura les dimensions de l'image a analyser */
/*                                                              */
/*--------------------------------------------------------------*/
/* Variables de LAPS definissant les isophotes :                */
/*                                                              */
/* surmag;  flux moyen de l'isophote                            */
/* r25;     rayon equivalent de l'isophote                      */
/* xce;     centre de l'isophote elliptique sur l'axe X         */
/* yce;     centre de l'isophote elliptique sur l'axe Y         */
/* csa;     rapport b/a (applatissement) de l'isophote          */
/* angp;    angle de position de l'axe de l'ellipse             */
/* nisoph;  Nombre d'isophotes valides pour le profil traite    */
/****************************************************************/
int tt_laps_analyse(TT_IMA *p_in,TT_IMA *p_out,double xc,double yc,
		  double ciel,
        double cmag,double scale,double forme,
        int ordre3,int ordre4,int ordre5,int ordre6,double pgposang,
		  int xd,int xf,
		  int yd,int yf,double saturation, char *file_out,double *radius_max_analyse, double *radius_coeur,double *radius_effective,double *magnitude_totale,double *magnitude_asymptotique,double *brillance_effective,double *brillance_centrale)
{
FILE *hand;
int imax,jmax;
char message_err[TT_MAXLIGNE];
double smo, rsta, cielut, tampon1;
double xj, xj2, yi, yi2, r2, n, yci, xcj, alo32;
double ct2, del1, dist=0., glup, sup, pi, ixj, iyi, dmax2, di2;
int iimax, iva, nl1, nl2, npl1, npl2, rfe, i, j, k, k1, kk, nn, ima;
long npel, rfe2;
int nelli, nellii, nisoph, ordre;
char nom[TT_MAXLIGNE],buffer[2048];
TT_LAPS *isoph=NULL;
int msg,nombre,taille;
double val_pixel;

imax=p_in->naxis1;
jmax=p_in->naxis2;

pi=TT_PI;
alo32=(double)log10(saturation);
iimax=200;
nisoph=200;

nombre=nisoph+1;
taille=sizeof(TT_LAPS);
if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&isoph,&nombre,&taille,"isoph"))!=0) {
   tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_laps_analyse for pointer isoph");
   return(TT_ERR_PB_MALLOC);
}


if ((xd==0) && (yd==0) && (xf==0) && (yf==0))
   {
   nl1=0;      /* cadre de la zone d'exploration */
   nl2=jmax-1;
   npl1=0;
   npl2=imax-1;
   }
else
   {
   nl1=yd-1;      /* cadre de la zone d'exploration */
   nl2=yf-1;
   npl1=xd-1;
   npl2=xf-1;
   }

if (xc==0 && yc==0)
   {
   xc=(npl2-npl1)/2;
   yc=(nl2-nl1)/2;
   }
xc+=0.5;
yc+=0.5;
if (scale==0) {scale=1;}
if (scale<0) {scale*=-1;}
if (ciel<0) {ciel=0;}
cielut=ciel-10;
if (forme==0) {forme=1;}
rfe=( ( i=nl2-nl1 )>=( j=npl2-npl1 ) )? j/2: i/2;
rfe2=(long)rfe*(long)rfe;
ordre3= (ordre3!=0) ? 1 : 0;
ordre4= (ordre4!=0) ? 1 : 0;
ordre5= (ordre5!=0) ? 1 : 0;
ordre6= (ordre6!=0) ? 1 : 0;
ordre=ordre3+ordre4*2+ordre5*4+ordre6*8;

for (i=nl1;i<=nl2;i++)
   {
   yi=(i-yc)*forme;
   yi2=yi*yi;
   for (j=npl1;j<=npl2;j++)
      {
      xj=j-xc;
      xj2=xj*xj;
      r2=xj2+yi2;
      /*
      read_cache(j,i,&cache[1]);
      val_pixel=*((int *)POINTEUR(cache[1]));
      */
      val_pixel=(double)p_in->p[j*imax+i];
      if ((val_pixel>cielut)&&(r2<=rfe2))
	 {
	 n=(alo32-log10(val_pixel-cielut))*iimax/4.+1;
    if (n<0) {
       n=0;
    }
	 nn=(int)n;
	 if (nn<=iimax)
	    {
	    isoph[nn].ncount+=1;
	    isoph[nn].xmn   +=val_pixel;
	    isoph[nn].xce1  +=xj;
	    isoph[nn].yce1  +=yi;
	    isoph[nn].x2    +=xj2;
	    isoph[nn].y2    +=yi2;
	    isoph[nn].xy    +=xj*yi;
	    }
	 }
      }
   }
smo=ciel;
for (i=0;i<=iimax;i++) {
   isoph[i].surmag = ((isoph[i].ncount!=0)&&(isoph[i].xmn>0)) ? (isoph[i].xmn/isoph[i].ncount) : isoph[i].surmag ;
}
tt_laps_ellip(isoph,nisoph,forme);
isoph[1].isoph=1;
j=(isoph[1].ncount==0) ? 1: 2;
ima=iimax;
for(i=2;i<=ima;i++)
   {
   isoph[i].isoph=j;
   if (isoph[i].ncount!=0)
      {
      if ( (isoph[i].ncount<(long)(4.0*(isoph[i].a))) && (i<ima) && (isoph[i].a>(double)4.0) )
	 {
	 isoph[i+1].surmag=isoph[i].surmag*isoph[i].ncount+isoph[i+1].surmag*isoph[i+1].ncount;
	 isoph[i+1].ncount+=isoph[i].ncount;
	 isoph[i+1].surmag/=isoph[i+1].ncount;
	 }
      else
	 {
	 isoph[j].xce=isoph[i].xce;
	 isoph[j].yce=isoph[i].yce;
	 isoph[j].ncount=isoph[i].ncount;
	 isoph[j].surmag=isoph[i].surmag;
	 isoph[j].a=isoph[i].a;
	 isoph[j].angp=isoph[i].angp;
	 isoph[j].ap2=isoph[i].ap2;
	 isoph[j].ag2=isoph[i].ag2;
	 j++;
	 }
      }
   }
ima=--j;
/// if (ima==0) exit(1);
npel=0;
for (iva=1;iva<=2;iva++)
   {
   for (k=1;k<=ima;k++)
      {
      rsta=(double)pow((isoph[k].ap2*isoph[k].ag2),0.25);
      isoph[k].al=(double)4.0*(pow(isoph[k].a,4)*(isoph[k].ap2)/(isoph[k].ag2)/pow(rsta,3)-rsta);
      isoph[k].al=((k>=2)&&(k<=(ima-1))) ? max(isoph[k].al,isoph[k+1].a-(isoph[k-1].a)): isoph[k].al;
      isoph[k].al=(isoph[k].al>(rsta/2)) ? rsta/2: isoph[k].al;
      isoph[k].al=max(isoph[k].al,1);
      isoph[k].ag2+=(isoph[k].al * sqrt(isoph[k].ag2));
      isoph[k].ap2+=(isoph[k].al * sqrt(isoph[k].ap2));
      }
   for (k=2;k<=ima;k++)
      {
      isoph[k].xce=(double)(fabs (isoph[k].xce-(isoph[k-1].xce)) < ((double)0.5*(isoph[k].al)) ) ? (double)0.5*(isoph[k].xce+(isoph[k-1].xce)): isoph[k].xce;
      isoph[k].yce=(double)(fabs (isoph[k].yce-(isoph[k-1].yce)) < ((double)0.5*(isoph[k].al)) ) ? (double)0.5*(isoph[k].yce+(isoph[k-1].yce)): isoph[k].yce;
      }
   for (k=1;k<=iimax;k++)
      {
      isoph[k].xce1=isoph[k].yce1=isoph[k].x2=isoph[k].y2=isoph[k].xmn=isoph[k].xmn2=isoph[k].xy=0;
      isoph[k].ncount=0;
      }
   for (i=nl1;i<=nl2;i++)
      {
      yi=(i-yc)*forme;
      yi2=yi*yi;
      for (j=npl1;j<=npl2;j++)
	 {
	 xj=j-xc;
	 xj2=xj*xj;
	 r2=xj2+yi2;
    /*
	 read_cache(j,i,&cache[1]);
	 val_pixel=*((int *)POINTEUR(cache[1]));
    */
    val_pixel=(double)p_in->p[j*imax+i];
	 if ((val_pixel>cielut)&&(r2<=rfe2))
	    {
	    n=(alo32-log10(val_pixel-cielut))*iimax/4.+1;
	    nn=(int)n;
	    if ((nn<=iimax)&&(n>=1))
	       {
	       nn=isoph[nn].isoph;
	       if (nn<=ima)
		  {
		  /* calcul de itest et correction sur val_pixel */
		  /* itest%(yi,xj,n%)                            */
		  k=nn;
		  ixj=xj-(isoph[k].xce);
		  iyi=yi-(isoph[k].yce);
		  ct2=(double)cos( (yi==0) ? (pi/(double)2.0-(isoph[k].angp)): ((double)atan(-ixj/iyi)-(isoph[k].angp)) );
		  ct2=ct2*ct2;
		  dmax2=1/( ct2/(isoph[k].ag2)+(1-ct2)/(isoph[k].ap2) );
		  di2=(ixj*ixj+iyi*iyi);
		  if (!(di2<=dmax2))       /* cas ou itest%<>1 */
		     {
		     npel+=1;
		     /* n%=nelli%(yi,xj,n%+2,ima%,i%,j%,xc,yc) */
		     k=nn+2;
		     nelli=k;
		     nellii=k;
		     if (nellii>ima)
			{
			nelli=0;
			}
		     else
			{
			ixj=xj-(isoph[nellii].xce);
			iyi=yi-(isoph[nellii].yce);
			ct2=(double)cos( (iyi==0)? (pi/(double)2.0-(isoph[nellii].angp)): ((double)atan(-ixj/iyi)-(isoph[nellii].angp)) );
			ct2=ct2*ct2;
			del1=(ixj*ixj+iyi*iyi)*(ct2/(isoph[nellii].ag2)+(1-ct2)/(isoph[nellii].ap2))-1;
			tampon1=0;
			while (tampon1==0)
			   {
			   k1=nellii;
			   nellii+=(del1>0) ? 1: -1;
			   if (nellii>ima)
			      {
			      nelli=ima;
			      tampon1=1;  /* on sort... */
			      break;
			      }
			   if (nellii<1)
			      {
			      nelli=1;
			      tampon1=1; /* on sort...  */
			      break;
			      }
			   ixj=j-(isoph[nellii].xce)-xc;
			   iyi=i-(isoph[nellii].yce)-yc;
			   ct2=(double)cos( (iyi==0)? (pi/(double)2.0-(isoph[nellii].angp)): ((double)atan(-ixj/iyi)-(isoph[nellii].angp)) );
			   ct2=ct2*ct2;
			   del1=(ixj*ixj+iyi*iyi)*(ct2/(isoph[nellii].ag2)+(1-ct2)/(isoph[nellii].ap2))-1;
			   if ((dist*del1)<=0) /// dist non initialisee
			      {
			      nelli=min(k1,nellii);
			      tampon1=1; /* on sort... */
			      break;
			      }
			   }
			}
		     nn=nelli;
		     val_pixel=(int)(isoph[nn].surmag);
		     /* copy val_pixel au pixel (j,i) de l'image */
		     /*write_cache(j,i,(int *)&val_pixel, &cache[1]);*/
            p_out->p[j*imax+i]=(TT_PTYPE)(val_pixel);
		     }
		  isoph[nn].ncount+=1;
		  isoph[nn].xmn   +=val_pixel;
		  isoph[nn].xmn2  +=val_pixel*val_pixel;
		  isoph[nn].xce1  +=xj;
		  isoph[nn].yce1  +=yi;
		  isoph[nn].x2    +=xj2;
		  isoph[nn].y2    +=yi2;
		  isoph[nn].xy    +=xj*yi;
		  if ((iva==2) && (ordre>0))
		     {
		     tt_laps_calc2(xj,yi,isoph,nn);
		     }
		  }
	       }
	    }
	 }
      }
   }
   for (i=0;i<=iimax;i++) {
      isoph[i].surmag= ((isoph[i].ncount!=0)&&(isoph[i].xmn>0)) ? (isoph[i].xmn/(isoph[i].ncount)) : isoph[i].surmag ;
   }
 tt_laps_ellip(isoph,nisoph,forme);
if (ordre>0)
   {
   tt_laps_calc1(ima,isoph);
   }
for (k=1;k<=ima;k++) isoph[k].x2=isoph[k].y2=0;
k=ima;
for (i=nl1;i<=nl2;i++)
   {
   yci=(i-yc)*forme;
   for (j=npl1;j<=npl2;j++)
      {
      /*
      read_cache(j,i,&cache[1]);
      val_pixel=*((int *)POINTEUR(cache[1]));
      */
      val_pixel=(double)p_out->p[j*imax+i];
      xcj=j-xc;
      xj=xcj-(isoph[k].xce);
      yi=yci-(isoph[k].yce);
      ct2=(double)cos( (yi==0) ? pi/(double)2.0-(isoph[k].angp): (double)atan(-xj/yi)-(isoph[k].angp) );
      ct2=ct2*ct2;
      del1=(xj*xj+yi*yi)*(ct2/(isoph[k].ag2)+(1-ct2)/(isoph[k].ap2))-1;
      tampon1=0;
      while (tampon1==0)
	 {
	 k1=k;
	 k+=(del1>0) ? 1: -1;
	 if ((k>ima)||(k<1)) break;
	 xj=xcj-(isoph[k].xce);
	 yi=yci-(isoph[k].yce);
	 ct2=(double)cos( (yi==0) ? pi/(double)2.0-(isoph[k].angp) : (double)atan(-xj/yi)-(isoph[k].angp) );
	 ct2=ct2*ct2;
	 dist=(xj*xj+yi*yi)*(ct2/(isoph[k].ag2)+(1-ct2)/(isoph[k].ap2))-1;
	 if((dist*del1)<=0)
	    {
	    k1=max(k1,k);
	    isoph[k1].x2+=val_pixel;
	    isoph[k1].y2+=1;
	    tampon1=1;
	    break;
	    }
	 else
	    {
	    del1=dist;
	    }
	 }
      if (k>ima) k=ima;
      if (k<1)   k=1;
      }
   }
for (k=1;k<=ima;k++)
   {
   if (isoph[k].a<3)
      {
      if (isoph[k].surmag>0)
	 {
	 isoph[k].surmag=(double)-2.5*log10(isoph[k].surmag-smo)+cmag;
	 }
      else
	 {
	 isoph[k].surmag=50;
	 }
      }
   else
      {
      if (isoph[k].y2<1)
	 {
	 isoph[k].surmag=50;
	 isoph[k].a=1;
	 }
      else
	 {
	 glup=isoph[k].x2-smo*(isoph[k].y2);
	 if (glup<=0)
	    {
	    isoph[k].surmag=51;
	    if (!(k==iimax))
	       {
	       isoph[k+1].x2+=isoph[k].x2;
	       isoph[k+1].y2+=isoph[k].y2;
	       }
	    }
	 else
	    {
	    isoph[k].surmag=(double)-2.5*log10(isoph[k].x2/(isoph[k].y2)-smo)+cmag;
	    }
	 }
      }
   }
for (k=1; k<=ima;k++)
   {
   isoph[k].csa=(double)sqrt(isoph[k].ap2/(isoph[k].ag2));
   isoph[k].r25=(double)pow((sqrt(isoph[k].ag2*(isoph[k].csa))*scale),0.25);
   isoph[k].angp=isoph[k].angp*180/pi+pgposang;
   isoph[k].angp=(double)fmod(isoph[k].angp,180);
   isoph[k].xce*=scale;
   isoph[k].yce*=scale/forme;
   isoph[k].a*=scale;
   }
for (k=ima;k>=1;k--)
   {
   if (!((isoph[k].a<scale)||(k<=1)))
      {
      isoph[k].a=(double)pow( ((pow(isoph[k].a,0.25)+pow(isoph[k-1].a,0.25))/2) ,4);
      isoph[k].r25=(double)0.5*(isoph[k].r25+(isoph[k-1].r25));
      }
   }
sup=0;
for (k=1; k<=ima;k++)
   {
   if ((isoph[k].surmag==50)||(isoph[k].surmag==51))
      {
      sup++;
      for (kk=k;(kk<=(ima-1));kk++)
	 {
	 isoph[kk].csa=isoph[kk+1].csa;
	 isoph[kk].r25=isoph[kk+1].r25;
	 isoph[kk].angp=isoph[kk+1].angp;
	 isoph[kk].xce=isoph[kk+1].xce;
	 isoph[kk].yce=isoph[kk+1].yce;
	 isoph[kk].a=isoph[kk+1].a;
	 isoph[kk].surmag=isoph[kk+1].surmag;
	 isoph[kk].base[A1]=isoph[kk+1].base[A1];
	 isoph[kk].base[B1]=isoph[kk+1].base[B1];
	 isoph[kk].base[A2]=isoph[kk+1].base[A2];
	 isoph[kk].base[B2]=isoph[kk+1].base[B2];
	 isoph[kk].base[A3]=isoph[kk+1].base[A3];
	 isoph[kk].base[B3]=isoph[kk+1].base[B3];
	 isoph[kk].base[A4]=isoph[kk+1].base[A4];
	 isoph[kk].base[B4]=isoph[kk+1].base[B4];
	 isoph[kk].base[A5]=isoph[kk+1].base[A5];
	 isoph[kk].base[B5]=isoph[kk+1].base[B5];
	 isoph[kk].base[A6]=isoph[kk+1].base[A6];
	 isoph[kk].base[B6]=isoph[kk+1].base[B6];
	 }
      }
   }
ima-=(int)sup; /// conversion double->int
nisoph=ima;
if (ordre!=0)
   {
   tt_laps_calc3(ima, isoph);
   }

/*------------------------------------------*/
/*   sortie des parametres des ellipses     */
/*------------------------------------------*/
if ((hand=fopen(file_out,"wt"))==NULL)
   {
   tt_free2((void**)&isoph,"isoph");
   msg=TT_ERR_FILE_CANNOT_BE_WRITED;
   sprintf(message_err,"Writing error for file %s in tt_laps_analyse",nom);
   tt_errlog("",msg,message_err);
   return(msg);
   return(TT_ERR_PB_MALLOC);
   }
else
   {
   for (k=1;k<=ima;k++)
      {
      /*               k r25    surmag xce    yce    csa    angl   a3    b3    a4    b4    a5     b5   a6    b6    */
      sprintf(buffer,"%d\t%2.2f\t%3.2f\t%2.3f\t%2.3f\t%1.3f\t%3.2f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n",
      k,isoph[k].r25,isoph[k].surmag,isoph[k].xce,isoph[k].yce,isoph[k].csa,isoph[k].angp,
      isoph[k].base[A3],isoph[k].base[B3],isoph[k].base[A4],isoph[k].base[B4],
      isoph[k].base[A5],isoph[k].base[B5],isoph[k].base[A6],isoph[k].base[B6]);
      fwrite(buffer,strlen(buffer),1,hand);
      }
   fclose(hand);
   }

tt_laps_modelise(p_out, nisoph, isoph,xc, yc, ciel, cmag, scale, forme, ordre, pgposang, imax, jmax);

tt_laps_parami(nisoph,isoph,radius_max_analyse,radius_coeur,radius_effective,magnitude_totale,magnitude_asymptotique,brillance_effective,brillance_centrale);

tt_free2((void**)&isoph,"isoph");
return 0;
}

/*******************************/
/*---- FONCTION tt_laps_ellip ----*/
/*******************************/
void tt_laps_ellip(TT_LAPS *isoph, int nisoph, double forme)
{
double s1, del, ap, ag, rstar, csa2, ofx, ofy, ofp, of, of2, dsss, drsr, pi, ofg;
int k,im;
double areat;
pi=TT_PI;
im=nisoph;
of=0;
for (k=2;k<=im;k++)
   {
   isoph[k].xce1+=isoph[k-1].xce1;
   isoph[k].yce1+=isoph[k-1].yce1;
   isoph[k].x2+=isoph[k-1].x2;
   isoph[k].y2+=isoph[k-1].y2;
   isoph[k].xy+=isoph[k-1].xy;
   }
areat=(double)0.00001;
for(k=1;k<=im;k++)
   {
   areat+=isoph[k].ncount;
   ofx=isoph[k].xce=isoph[k].xce1/areat;
   ofy=isoph[k].yce=isoph[k].yce1/areat;
   isoph[k].x2=isoph[k].x2/areat-ofx*ofx;
   isoph[k].y2=isoph[k].y2/areat-ofy*ofy;
   ofp=isoph[k].xy=isoph[k].xy/areat-ofx*ofy;
   s1=isoph[k].x2+(isoph[k].y2);
   del=isoph[k].x2-(isoph[k].y2);
   del=del*del+4*ofp*ofp;
   del=(del<=(double)0.0) ? (double)1.0 : del ;
   ap=(s1+sqrt(del))/2;
   ag=(s1-sqrt(del))/2;
   ag=(ag<=0) ? ap : ag ;
   rstar=areat/pi*forme;
   csa2=ag/ap;
   isoph[k].ag2=rstar/sqrt(csa2);
   isoph[k].ap2=isoph[k].ag2*csa2;
   if (2*(isoph[k].xy/sqrt(del))>(double).9999)
      isoph[k].angp=(double)-45.0;
   else if (2*(isoph[k].xy/(double)sqrt(del))<(double)-.9999)
      isoph[k].angp=(double)45.0;
   else
      isoph[k].angp=(double)-0.5*asin(2*(isoph[k].xy/sqrt(del)))*180.0/pi;
   isoph[k].angp=(isoph[k].x2>=isoph[k].y2) ? (double)90.0-(isoph[k].angp): isoph[k].angp ;
   isoph[k].angp=(isoph[k].angp<(double)0.0) ? isoph[k].angp+(double)180.0: isoph[k].angp ;
   isoph[k].angp/=(180.0/pi);
   isoph[k].a=(double)sqrt(4*ap);
   }
for(k=4;k<=im;k++)
   {
   if ((isoph[k].ncount!=0)&&(isoph[k-1].ncount!=0))
      {
      ofx=isoph[k-1].xce-(isoph[k].xce);
      ofy=isoph[k-1].yce-(isoph[k].yce);
      ofp=(double)fabs(ofx*cos(isoph[k].angp)+ofy*sin(isoph[k].angp));
      if (sqrt(isoph[k].ap2)<(ofp+sqrt(isoph[k-1].ap2)))
	 {
	 isoph[k].xce=isoph[k-1].xce;
	 isoph[k].yce=isoph[k-1].yce;
	 of=0;
	 if (sqrt(isoph[k].ap2)<(of+sqrt(isoph[k-1].ap2)))
	    {
	    ap=((double)sqrt(isoph[k-1].ap2)+of);
	    ap*=ap;
	    of2=ofx*ofx+ofy*ofy;
	    dsss=0;
	    if (!(of2<(double)0.05))
	       {
	       dsss=(double)pow(isoph[k].a,4)/(isoph[k].ag2)/(isoph[k].ag2)-1;
	       dsss=(double)max(dsss,(double)0.05);
	       dsss=of2/dsss;
	       dsss=(double)min(dsss,(double)0.5);
	       }
	    of2=0;
	    drsr=1-dsss;
	    isoph[k].ag2*=(isoph[k].ap2/ap*drsr);
	    isoph[k].ap2=ap*drsr;
	    isoph[k].a*=drsr*drsr;
	    }
	 }
      ofx=isoph[k-1].xce-(isoph[k].xce);
      ofy=isoph[k-1].yce-(isoph[k].yce);
      ofg=(double)fabs(-ofx*sin(isoph[k].angp)+ofy*cos(isoph[k].angp));
      if (sqrt(isoph[k].ag2)<(ofg+sqrt(isoph[k-1].ag2)))
	 {
	 ag=(double)sqrt(isoph[k].ag2)-of;
	 ag*=ag;
	 isoph[k-1].ap2*=isoph[k-1].ag2/ag;
	 isoph[k-1].ag2=ag;
	 }
      }
   }
}

/*******************************/
/*---- FONCTION tt_laps_calc1 ----*/
/*******************************/
void tt_laps_calc1(int ima, TT_LAPS *isoph)
{
int k;
double areat,rotyi,rotxj,tampon1,tampon2;
for (k=2;k<=ima;k++)
   {
   isoph[k].base[X0Y3] +=isoph[k-1].base[X0Y3];
   isoph[k].base[X0Y4] +=isoph[k-1].base[X0Y4];
   isoph[k].base[X0Y5] +=isoph[k-1].base[X0Y5];
   isoph[k].base[X0Y6] +=isoph[k-1].base[X0Y6];
   isoph[k].base[X1Y2] +=isoph[k-1].base[X1Y2];
   isoph[k].base[X1Y3] +=isoph[k-1].base[X1Y3];
   isoph[k].base[X1Y4] +=isoph[k-1].base[X1Y4];
   isoph[k].base[X1Y5] +=isoph[k-1].base[X1Y5];
   isoph[k].base[X2Y1] +=isoph[k-1].base[X2Y1];
   isoph[k].base[X2Y2] +=isoph[k-1].base[X2Y2];
   isoph[k].base[X2Y3] +=isoph[k-1].base[X2Y3];
   isoph[k].base[X2Y4] +=isoph[k-1].base[X2Y4];
   isoph[k].base[X3Y0] +=isoph[k-1].base[X3Y0];
   isoph[k].base[X3Y1] +=isoph[k-1].base[X3Y1];
   isoph[k].base[X3Y2] +=isoph[k-1].base[X3Y2];
   isoph[k].base[X3Y3] +=isoph[k-1].base[X3Y3];
   isoph[k].base[X4Y0] +=isoph[k-1].base[X4Y0];
   isoph[k].base[X4Y1] +=isoph[k-1].base[X4Y1];
   isoph[k].base[X4Y2] +=isoph[k-1].base[X4Y2];
   isoph[k].base[X5Y0] +=isoph[k-1].base[X5Y0];
   isoph[k].base[X5Y1] +=isoph[k-1].base[X5Y1];
   isoph[k].base[X6Y0] +=isoph[k-1].base[X6Y0];
   }
areat=(double)0.00001;
for (k=2;k<=ima;k++)
   {
   areat+=isoph[k].ncount;
   rotyi=(double)sqrt(isoph[k].ap2);
   rotxj=(double)sqrt(isoph[k].ag2);
   tampon2=rotyi*rotyi;
   isoph[k].base[X1Y2] /=(areat*rotxj*tampon2);
   isoph[k].base[X2Y2] /=tampon2;
   isoph[k].base[X3Y2] /=tampon2;
   isoph[k].base[X4Y2] /=tampon2;
   tampon2*=rotyi;
   isoph[k].base[X0Y3] /=(areat*tampon2);
   isoph[k].base[X1Y3] /=(areat*rotxj*tampon2);
   isoph[k].base[X2Y3] /=tampon2;
   isoph[k].base[X3Y3] /=tampon2;
   tampon2*=rotyi;
   isoph[k].base[X0Y4] /=(areat*tampon2);
   isoph[k].base[X1Y4] /=(areat*rotxj*tampon2);
   isoph[k].base[X2Y4] /=tampon2;
   tampon2*=rotyi;
   isoph[k].base[X0Y5] /=(areat*tampon2);
   isoph[k].base[X1Y5] /=(areat*rotxj*tampon2);
   tampon2*=rotyi;
   isoph[k].base[X0Y6] /=(areat*tampon2);
   tampon1=rotxj*rotxj*areat;
   isoph[k].base[X2Y1] /=(tampon1*rotyi);
   isoph[k].base[X2Y2] /=(tampon1);
   isoph[k].base[X2Y3] /=(tampon1);
   isoph[k].base[X2Y4] /=(tampon1);
   tampon1*=rotxj;
   isoph[k].base[X3Y0] /=(tampon1);
   isoph[k].base[X3Y1] /=(tampon1*rotyi);
   isoph[k].base[X3Y2] /=(tampon1);
   isoph[k].base[X3Y3] /=(tampon1);
   tampon1*=rotxj;
   isoph[k].base[X4Y0] /=(tampon1);
   isoph[k].base[X4Y1] /=(tampon1*rotyi);
   isoph[k].base[X4Y2] /=(tampon1);
   tampon1*=rotxj;
   isoph[k].base[X5Y0] /=(tampon1);
   isoph[k].base[X5Y1] /=(tampon1*rotyi);
   tampon1*=rotxj;
   isoph[k].base[X6Y0] /=(tampon1);
   isoph[k].base[A1]= isoph[k].base[X3Y0] + isoph[k].base[X1Y2] ;
   isoph[k].base[B1]= (isoph[k].base[X2Y1] + isoph[k].base[X0Y3])*2./3. ;
   isoph[k].base[A2]= isoph[k].base[X4Y0] - isoph[k].base[X0Y4] ;
   isoph[k].base[B2]= (isoph[k].base[X3Y1] *2 - isoph[k].base[X1Y3]) *8./3. ;
   isoph[k].base[A3]= isoph[k].base[X3Y0] - isoph[k].base[X1Y2] *3 ;
   isoph[k].base[B3]= (isoph[k].base[X2Y1] - isoph[k].base[X0Y3]) *2. ;
   isoph[k].base[A4]=4*( isoph[k].base[X4Y0] + (isoph[k].base[X0Y4]) ) -1;
   isoph[k].base[B4]=4*( isoph[k].base[X3Y1] );
   isoph[k].base[A5]= isoph[k].base[X5Y0] - isoph[k].base[X3Y2] * 10 + isoph[k].base[X1Y4] * 5 ;
   isoph[k].base[B5]= (isoph[k].base[X4Y1] * 5 - isoph[k].base[X2Y3] * 10 + isoph[k].base[X0Y5] * 3 ) *8./9.;
   isoph[k].base[A6]= isoph[k].base[X6Y0] - isoph[k].base[X0Y6] + ( isoph[k].base[X2Y4] - isoph[k].base[X4Y2] ) * 15 ;
   isoph[k].base[B6]= isoph[k].base[X5Y1] + ( isoph[k].base[X1Y5] - isoph[k].base[X3Y3] ) * 15;
   }
}

/*******************************/
/*---- FONCTION tt_laps_calc2 ----*/
/*******************************/
void tt_laps_calc2(double xj,double yi, TT_LAPS *isoph,int nn)
{
double pi=(double)3.1415926;
double xjcentre,yicentre,gument;
double cosal,sinal;
double rotxj,rotyi,tampon1,tampon2;

xjcentre=xj-(isoph[nn].xce);
yicentre=yi-(isoph[nn].yce);
gument=(isoph[nn].angp)+pi/2;
cosal=(double)cos(gument);
sinal=(double)sin(gument);
rotxj=xjcentre*cosal+yicentre*sinal;
rotyi=-xjcentre*sinal+yicentre*cosal;
tampon2=rotyi*rotyi;
isoph[nn].base[X1Y2] +=(rotxj*tampon2);
tampon1=rotxj*rotxj;
isoph[nn].base[X2Y2] +=(tampon1*tampon2);
tampon1*=rotxj;
isoph[nn].base[X3Y2] +=(tampon1*tampon2);
tampon1*=rotxj;
isoph[nn].base[X4Y2] +=(tampon1*tampon2);
tampon2*=rotyi;
isoph[nn].base[X0Y3] +=tampon2;
isoph[nn].base[X1Y3] +=(rotxj*tampon2);
tampon1/=rotxj;
isoph[nn].base[X3Y3] +=(tampon1*tampon2);
tampon1/=rotxj;
isoph[nn].base[X2Y3] +=(tampon1*tampon2);
tampon2*=rotyi;
isoph[nn].base[X0Y4] +=tampon2;
isoph[nn].base[X1Y4] +=(rotxj*tampon2);
isoph[nn].base[X2Y4] +=(tampon1*tampon2);
tampon2*=rotyi;
isoph[nn].base[X0Y5] +=tampon2;
isoph[nn].base[X1Y5] +=(rotxj*tampon2);
tampon2*=rotyi;
isoph[nn].base[X0Y6] +=tampon2;
isoph[nn].base[X2Y1] +=(tampon1*rotyi);
tampon1*=rotxj;
isoph[nn].base[X3Y0] +=tampon1;
isoph[nn].base[X3Y1] +=(tampon1*rotyi);
tampon1*=rotxj;
isoph[nn].base[X4Y0] +=tampon1;
isoph[nn].base[X4Y1] +=(tampon1*rotyi);
tampon1*=rotxj;
isoph[nn].base[X5Y0] +=tampon1;
isoph[nn].base[X5Y1] +=(tampon1*rotyi);
tampon1*=rotxj;
isoph[nn].base[X6Y0] +=tampon1;
}

/*******************************/
/*---- FONCTION tt_laps_calc3 ----*/
/*******************************/
void tt_laps_calc3(int ima, TT_LAPS *isoph)
{
int k,premier_valide, dernier_valide, ecart,deb,fin,kk,kkk;
double coef,limite,maxilim;

maxilim=(double)0.15;
for (k=1;k<=ima;k++)
   {
   isoph[k].base[A3]= ((isoph[k].base[A3])>maxilim) ? maxilim : isoph[k].base[A3] ;
   isoph[k].base[B3]= ((isoph[k].base[B3])>maxilim) ? maxilim : isoph[k].base[B3] ;
   isoph[k].base[A4]= ((isoph[k].base[A4])>maxilim) ? maxilim : isoph[k].base[A4] ;
   isoph[k].base[B4]= ((isoph[k].base[B4])>maxilim) ? maxilim : isoph[k].base[B4] ;
   isoph[k].base[A5]= ((isoph[k].base[A5])>maxilim) ? maxilim : isoph[k].base[A5] ;
   isoph[k].base[B5]= ((isoph[k].base[B5])>maxilim) ? maxilim : isoph[k].base[B5] ;
   isoph[k].base[A6]= ((isoph[k].base[A6])>maxilim) ? maxilim : isoph[k].base[A6] ;
   isoph[k].base[B6]= ((isoph[k].base[B6])>maxilim) ? maxilim : isoph[k].base[B6] ;
   isoph[k].base[A3]= ((isoph[k].base[A3])<-maxilim) ? -maxilim : isoph[k].base[A3] ;
   isoph[k].base[B3]= ((isoph[k].base[B3])<-maxilim) ? -maxilim : isoph[k].base[B3] ;
   isoph[k].base[A4]= ((isoph[k].base[A4])<-maxilim) ? -maxilim : isoph[k].base[A4] ;
   isoph[k].base[B4]= ((isoph[k].base[B4])<-maxilim) ? -maxilim : isoph[k].base[B4] ;
   isoph[k].base[A5]= ((isoph[k].base[A5])<-maxilim) ? -maxilim : isoph[k].base[A5] ;
   isoph[k].base[B5]= ((isoph[k].base[B5])<-maxilim) ? -maxilim : isoph[k].base[B5] ;
   isoph[k].base[A6]= ((isoph[k].base[A6])<-maxilim) ? -maxilim : isoph[k].base[A6] ;
   isoph[k].base[B6]= ((isoph[k].base[B6])<-maxilim) ? -maxilim : isoph[k].base[B6] ;
   }
limite=(double)0.015;
for (k=1;k<=ima;k++)
   {
   isoph[k].base[A1] = ( (fabs(isoph[k].base[A1])>limite) || (fabs(isoph[k].base[A1])>limite) || (fabs(isoph[k].base[A1])>limite) || (fabs(isoph[k].base[A1])>limite) ) ? 0 : 1 ;
   }
premier_valide=0;
dernier_valide=0;
for (k=1;k<=ima;k++)
   {
   if (isoph[k].base[A1]==1)
      {
      if (premier_valide==0)
	 {
	 premier_valide=k;
	 }
      else
	 {
	 dernier_valide=k;
	 }
      }
   }
if (premier_valide==0)
   {
   /* aucun des coefs est valide */
   }
else
   {
   for (k=1;k<=premier_valide;k++)
      {
      isoph[k].base[A3]= isoph[premier_valide].base[A3] ;
      isoph[k].base[B3]= isoph[premier_valide].base[B3] ;
      isoph[k].base[A4]= isoph[premier_valide].base[A4] ;
      isoph[k].base[B4]= isoph[premier_valide].base[B4] ;
      isoph[k].base[A5]= isoph[premier_valide].base[A5] ;
      isoph[k].base[B5]= isoph[premier_valide].base[B5] ;
      isoph[k].base[A6]= isoph[premier_valide].base[A6] ;
      isoph[k].base[B6]= isoph[premier_valide].base[B6] ;
      }
   for (k=dernier_valide;k<=ima;k++)
      {
      isoph[k].base[A3]= isoph[dernier_valide].base[A3] ;
      isoph[k].base[B3]= isoph[dernier_valide].base[B3] ;
      isoph[k].base[A4]= isoph[dernier_valide].base[A4] ;
      isoph[k].base[B4]= isoph[dernier_valide].base[B4] ;
      isoph[k].base[A5]= isoph[dernier_valide].base[A5] ;
      isoph[k].base[B5]= isoph[dernier_valide].base[B5] ;
      isoph[k].base[A6]= isoph[dernier_valide].base[A6] ;
      isoph[k].base[B6]= isoph[dernier_valide].base[B6] ;
      }
   deb=premier_valide;
   for (k=premier_valide+1;k<=dernier_valide-1;k++)
      {
      if ((isoph[k].base[A1]==1) && (isoph[k-1].base[A1]==1))
	 {
	 deb=k;
	 }
      else
	 {
	 if ((isoph[k].base[A1]==1) && (isoph[k-1].base[A1]==0))
	    {
	    fin=k;
	    ecart=fin-deb;
	    for (kk=deb+1;kk<fin;kk++)
	       {
	       /*approx lineaire entre deb et fin qui sont tous les 2 valides*/
	       coef=(kk-deb)/(ecart*(double)1.0);
	       isoph[kk].base[A3]= isoph[deb].base[A3] + coef * ( isoph[fin].base[A3] - isoph[deb].base[A3] ) ;
	       isoph[kk].base[B3]= isoph[deb].base[B3] + coef * ( isoph[fin].base[B3] - isoph[deb].base[B3] ) ;
	       isoph[kk].base[A4]= isoph[deb].base[A4] + coef * ( isoph[fin].base[A4] - isoph[deb].base[A4] ) ;
	       isoph[kk].base[B4]= isoph[deb].base[B4] + coef * ( isoph[fin].base[B4] - isoph[deb].base[B4] ) ;
	       isoph[kk].base[A5]= isoph[deb].base[A5] + coef * ( isoph[fin].base[A5] - isoph[deb].base[A5] ) ;
	       isoph[kk].base[B5]= isoph[deb].base[B5] + coef * ( isoph[fin].base[B5] - isoph[deb].base[B5] ) ;
	       isoph[kk].base[A6]= isoph[deb].base[A6] + coef * ( isoph[fin].base[A6] - isoph[deb].base[A6] ) ;
	       isoph[kk].base[B6]= isoph[deb].base[B6] + coef * ( isoph[fin].base[B6] - isoph[deb].base[B6] ) ;
	       }
	    deb=fin;
	    }
	 }
      }
   }
if (ima>6)
   {
   for (ecart=A3;ecart<=B6;ecart+=(B3-A3))
      {
      for (k=3;k<=ima-5;k++)
	 {
	 for (kk=k;kk<=k+4;kk++) { isoph[kk-k].base[A2]= isoph[kk].base[ecart]; } /// ???
	 for (kk=0;kk<=2;kk++)
	    {
	    for (kkk=kk+1;kkk<=4;kkk++)
	       {
	       if (isoph[kkk].base[A2]<isoph[kk].base[A2])
		  {
		  coef=isoph[kkk].base[A2];
		  isoph[kkk].base[A2]=isoph[kk].base[A2];
		  isoph[kk].base[A2]=coef;
		  }
	       }
	    }
	 isoph[k].base[B1]=isoph[2].base[A2];
	 }
      for (k=3;k<=ima-5;k++) { isoph[k].base[ecart]=isoph[k].base[B1]; } /// ???
      }
   }
}

/**********************************/
/*---- FONCTION tt_laps_modelise ----*/
/**********************************/
void tt_laps_modelise(TT_IMA *p_out, int nisoph, TT_LAPS *isoph,
		   double xc,double yc,double ciel,double cmag,
		   double scale,double forme,int ordre,
		   double pgposang,int imax,int jmax)
{
int k,i,j,yyi,val,ordre3,ordre4,ordre5,ordre6,reste;
double pi=TT_PI;
double xj,yi,ct2,del1,dist,xjn,yin,teta,terma4,r2,po1,val_pixel,tt,cosang,sinang,tampon1;

for (k=1;k<=nisoph;k++)
   {
   isoph[k].poww=(double)pow(10, ((cmag-(isoph[k].surmag))/2.5) );
   isoph[k].ag2=(double)pow(isoph[k].r25,4)/(scale);
   isoph[k].ag2=(isoph[k].ag2*(isoph[k].ag2))/(isoph[k].csa);
   isoph[k].ag2= (isoph[k].ag2==0) ? (double)0.01 : isoph[k].ag2 ;
   isoph[k].ap2= (isoph[k].csa*(isoph[k].csa)*(isoph[k].ag2));
   isoph[k].xce=(isoph[k].xce/scale+xc);
   isoph[k].yce=(isoph[k].yce/scale/forme+yc);
   isoph[k].yce= (isoph[k].yce==0) ? (double)0.01 : isoph[k].yce ;
   isoph[k].angp=(isoph[k].angp-pgposang)*pi/180;
   }
k=nisoph;
ordre6=(int)floor((double)ordre/8.0);
reste=ordre-8*ordre6;
ordre5=(int)floor((double)reste/4.0);
reste=reste-4*ordre5;
ordre4=(int)floor((double)reste/2);
reste=reste-2*ordre4;
ordre3=(int)floor((double)reste);
for (i=0;i<=(jmax-1);i++)
   {
   /* calcul de galmo(nisoph%=n0%, i%=ili%, k%=k%) */
   yyi=i;
   for (j=0;j<=(imax-1);j++)
      {
      xj=j-(isoph[k].xce);
      yi=(yyi-(isoph[k].yce))*forme;
      if (ordre==0)
	 {
	 yi= (yi==0) ? (double)0.1 : yi ;
	 ct2=(double)cos( (yi==0) ? pi/2-(isoph[k].angp): (double)atan(-xj/yi)-(isoph[k].angp) );
	 ct2=ct2*ct2;
	 del1=(xj*xj+yi*yi)*(ct2/(isoph[k].ag2)+(1-ct2)/(isoph[k].ap2))-1;
	 }
      else
	 {
	 cosang=(double)-sin(isoph[k].angp);
	 sinang=(double)cos(isoph[k].angp);
	 xjn=xj*cosang+yi*sinang;
	 yin=-xj*sinang+yi*cosang;
	 teta= (xjn==0) ? pi/2: (double)atan(sqrt( (isoph[k].ag2)/(isoph[k].ap2) )*yin/xjn);
	 teta= (xjn<0 && yin>0) ? teta+pi: teta;
	 teta= (xjn<0 && yin>0) ? teta+pi: teta;
	 cosang=(double)cos(teta);
	 sinang=(double)sin(teta);
	 terma4=1;
	 terma4+= (ordre3 * ( isoph[k].base[A3]*cos(3*teta) + isoph[k].base[B3]*sin(3*teta) ) );
	 terma4+= (ordre4 * ( isoph[k].base[A4]*cos(4*teta) + isoph[k].base[B4]*sin(4*teta) ) );
	 terma4+= (ordre5 * ( isoph[k].base[A5]*cos(5*teta) + isoph[k].base[B5]*sin(5*teta) ) );
	 terma4+= (ordre6 * ( isoph[k].base[A6]*cos(6*teta) + isoph[k].base[B6]*sin(6*teta) ) );
	 r2=( isoph[k].ag2 * cosang * cosang + isoph[k].ap2 * sinang * sinang ) * terma4;
	 del1=(xj*xj+yi*yi)/r2-1;
	 }
      po1=(isoph[k].poww);
      k+=(del1>0) ? 1: -1;
      if (k>nisoph)
	 {
	 val_pixel=0;
	 k=nisoph;
	 }
      else
	 {
	 if (k<1)
	    {
	    val_pixel=isoph[1].poww;
	    k=1;
	    }
	 else
	    {
	    tt=0;
	    tampon1=0;
	    while (tampon1==0)
	       {
	       xj=j-(isoph[k].xce);
	       yi=(yyi-(isoph[k].yce))*forme;
	       if (ordre==0)
		  {
		  yi=(yi==0) ? (double)0.1 : yi ;
		  ct2=(double)cos( (yi==0) ? pi/2-(isoph[k].angp): (double)atan(-xj/yi)-(isoph[k].angp) );
		  ct2=ct2*ct2;
		  dist=(xj*xj+yi*yi)*(ct2/(isoph[k].ag2)+(1-ct2)/(isoph[k].ap2))-1;
		  dist=(dist==0) ? (double)0.1 : dist ;
		  }
	       else
		  {
		  cosang=(double)-sin(isoph[k].angp);
		  sinang=(double)cos(isoph[k].angp);
		  xjn=xj*cosang+yi*sinang;
		  yin=-xj*sinang+yi*cosang;
		  teta= (xjn==0) ? pi/2: (double)atan(sqrt( (isoph[k].ag2)/(isoph[k].ap2) )*yin/xjn);
		  teta= (xjn<0 && yin>0) ? teta+pi: teta;
		  teta= (xjn<0 && yin>0) ? teta+pi: teta;
		  cosang=(double)cos(teta);
		  sinang=(double)sin(teta);
		  terma4=1;
		  terma4+= (ordre3 * ( isoph[k].base[A3]*cos(3*teta) + isoph[k].base[B3]*sin(3*teta) ) );
		  terma4+= (ordre4 * ( isoph[k].base[A4]*cos(4*teta) + isoph[k].base[B4]*sin(4*teta) ) );
		  terma4+= (ordre5 * ( isoph[k].base[A5]*cos(5*teta) + isoph[k].base[B5]*sin(5*teta) ) );
		  terma4+= (ordre6 * ( isoph[k].base[A6]*cos(6*teta) + isoph[k].base[B6]*sin(6*teta) ) );
		  r2=( isoph[k].ag2 * cosang * cosang + isoph[k].ap2 * sinang * sinang ) * terma4;
		  dist=(xj*xj+yi*yi)/r2-1;
		  }
	       tt++;
	       if (tt>nisoph) break;
	       if ((dist*del1)<=0)
		  {
		  val_pixel=(po1*dist-(isoph[k].poww)*del1) / (dist-del1);
		  }
	       else
		  {
		  po1=isoph[k].poww;
		  del1=dist;
		  k+=(dist>0) ? 1: -1;
		  if ((k>=1)&&(k<=nisoph)) continue;
		  if (k>nisoph)
		     {
		     val_pixel=0;
		     k=nisoph;
		     }
		  if (k<1)
		     {
		     val_pixel=isoph[1].poww;
		     k=1;
		     }
		  }
	       tampon1=1;
	       } /* fin du while */
	    }
	 }
      val=(int)(val_pixel+ciel);
      /* copy val_pixel au pixel (j,i) de l'image */
      /*write_cache(j,i,(int *)&val, nom);*/
      p_out->p[j*p_out->naxis1+i]=(TT_PTYPE)(val);
      }
   }
}

void tt_laps_parami(int nisoph, TT_LAPS *isoph,double *radius_max_analyse, double *radius_coeur,double *radius_effective,double *magnitude_totale,double *magnitude_asymptotique,double *brillance_effective,double *brillance_centrale)
{
double s1,sm,sr,sr2,smr,moyy,temp;
int k,kc,j;
double ama,det,p,amamax,ak,pot,su,su1,btot,pui;
double ray2,rayon2,basy,poef,ref,pot0,pot1,r;
double ame,amagcent,amagcoeur,cnit,rcoeur,rma;

s1 = 0;
sm = 0;
sr = 0;
sr2 = 0;
smr = 0;
moyy = 0;

for (k=1;k<=nisoph;k++) {
   moyy = moyy + isoph[k].surmag;
}
moyy = moyy / nisoph;

for (j=1;j<=nisoph;j++) {
   if (((isoph[nisoph].surmag-isoph[j].surmag)>2)&&((nisoph-j)>10)) {
      continue;
   }
   ama = isoph[j].surmag - moyy;
   s1 = s1 + 1;
   sr = sr + isoph[j].r25;
   sm = sm + ama;
   sr2 = sr2 + isoph[j].r25*isoph[j].r25;
   smr = smr + isoph[j].r25 * ama;
}

det = s1 * sr2 - sr * sr;
p = (s1 * smr - sm * sr) / det;
amamax = isoph[nisoph].surmag;
ak = (sm * sr2 - sr * smr) / det;
ak = ak + moyy;

for (j=1;j<=nisoph;j++) {
   isoph[j].al=pow(10,(isoph[j].surmag-moyy)/-2.5);
   isoph[j].r25=pow(isoph[j].r25,4);
}

pot = 0;
su = 0;

for (j=1;j<=nisoph;j++) {
   su1 = TT_PI * isoph[j].r25 * isoph[j].r25;
   ama = isoph[j].al;
   if (j>1) {
      ama = (ama + isoph[j-1].al)/2.;
   }
   pot = pot + (su1 - su) * ama;
   su = su1;
}

btot = -2.5 * log10(pot) + moyy;
pui = 0;
ray2 = pow(((amamax - ak) / p),8);

for (ama=amamax+0.1;ama<=50;ama+=0.1) {
   rayon2 = pow(((ama - ak) / p),8);
   pui = pui + (rayon2 - ray2) * pow(10,((ama - .05 - moyy) / -2.5));
   ray2 = rayon2;
}

pui = TT_PI * pui;
basy = -2.5 * log10(pui + pot) + moyy;
pot = pot + pui;
poef = pot / 2;
ref = isoph[nisoph].r25;
pot0 = 0;
pot1 = 0;
su = 0;

for (j=1;j<=nisoph;j++) {
   su1 = TT_PI * isoph[j].r25 * isoph[j].r25;
   ama = isoph[j].al;
   if (j>1) {
      ama = (ama + isoph[j-1].al)/2.;
   }
   pot1 = pot1 + (su1 - su) * ama;
   if (pot1>=poef) {
      r = (pot1 - poef) / (pot1 - pot0);
      ref = isoph[j].r25 * (1 - r) + isoph[j-1].r25 * r;
      break;
   }
   su = su1;
   pot0 = pot1;
}

ame = -2.5 * log10(poef / (TT_PI * ref * ref )) + moyy;
amagcent = isoph[1].surmag;
amagcoeur = amagcent + .7526;
kc = 1;

temp=isoph[kc].surmag;
while ( (temp<amagcoeur) && (kc<nisoph) ) {
   kc=kc+1;
	temp=isoph[kc].surmag;
}

cnit = (amagcoeur - isoph[kc-1].surmag) / (isoph[kc].surmag - isoph[kc-1].surmag);

for (j=1;j<=nisoph;j++) {
   isoph[j].r25=pow(isoph[j].r25,0.25);
}

rcoeur = pow((isoph[kc-1].r25 + (isoph[kc].r25 - isoph[kc-1].r25 * cnit)),4);

rma = pow(isoph[nisoph].r25,4);

*radius_max_analyse=rma; 
*radius_coeur=rcoeur;
*radius_effective=ref;
*magnitude_totale=btot;
*magnitude_asymptotique=basy;
*brillance_effective=ame;
*brillance_centrale=amagcent;

/*
VIEW PRINT 1 TO 24
LOCATE 1, 1
PRINT SPACE$(80); : PRINT SPACE$(80); : PRINT SPACE$(80); : PRINT SPACE$(80); : LOCATE 1, 1
PRINT USING "\                                     \"; mouch$(3);
PRINT "Rayon maximum d'analyse: "; USING "###.#"; rma; : PRINT " arcsec"
PRINT "Rayon de coeur  : "; USING "###.#"; rcoeur; : PRINT " arcsec         ";
PRINT "Rayon effectif         : "; USING "###.#"; ref; : PRINT " arcsec"
PRINT "Magnitude totale: "; USING "##.##"; btot; : PRINT "                ";
PRINT "Magnitude asympotique: "; USING "##.##"; basy
PRINT "Brillance de surface effective: "; USING "##.##"; ame; : PRINT "  ";
PRINT "Brillance centrale   : "; USING "##.##"; amagcent;
}
*/
}
