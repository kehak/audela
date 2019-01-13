/* tt_user5.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <Myrtille.Laas@oamp.fr>
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
#include <math.h>


/***** prototypes des fonctions internes du user5 ***********/
int tt_ima_stack_5_tutu(TT_IMA_STACK *pstack);
int tt_ima_series_trainee_1(TT_IMA_SERIES *pseries);
int tt_geo_defilant_1(TT_IMA_SERIES *pseries);
int tt_ima_masque_catalogue(TT_IMA_SERIES *pseries);
int tt_ima_rot(TT_IMA_SERIES *pseries);
/* pour l'interpolation */
double interpol2 (TT_IMA_SERIES *pseries,TT_IMA *pin,double old_x,double old_y,int method);

void tt_ima_series_hough_myrtille(TT_IMA* pin,TT_IMA* pout,int naxis1, int naxis2, int threshold , double *eq);
int tt_histocuts_precis(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode,double *minim,double *maxim);
int tt_histocuts_myrtille(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,double *mode,double *mini,double *maxi);

int tt_morphomath_1 (TT_IMA_SERIES *pseries);
void fittrainee (double lt, double fwhm,double x, int sizex, int sizey,double **mat,double *p,double *carac,double exposure);
void fittrainee2 (double seuil,double lt, double fwhm,double xc,double yc,int nb,int sizex, int sizey,double **mat,double *p,double *carac,double exposure);
void fittrainee3 (double seuil,double lt,double xc,double yc,int nb,int sizex, int sizey,double **mat,double *p,double *carac,double exposure);
double erf( double x );

void dilate (TT_IMA* pin,TT_IMA* pout,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2);
void erode (TT_IMA* pin,TT_IMA* pout,int* se,int dim1,int dim2,int sizex,int sizey, int naxis1,int naxis2);
int erosionByAnchor_1D_horizontal_longSE(TT_IMA* pin, TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix);
int erosionByAnchor_1D_horizontal_courSE(TT_IMA* pin, TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix);
int openingByAnchor_1D_horizontal_longSE(TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix);
int openingByAnchor_1D_horizontal_courSE(TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix);

void tt_fitgauss1d(int n,double *y,double *p,double *ecart);

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* ++++++++++++++++++++++++++++    INITIALISATION     +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user5 pour IMA/SERIES                  */
/**************************************************************************/
/**************************************************************************/

int tt_user5_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"TRAINEE")==0) { pseries->numfct=TT_IMASERIES_USER5_TRAINEE; }
   else if (strcmp(keys10,"GEOGTO")==0) { pseries->numfct=TT_IMASERIES_USER5_GEOGTO;}
   else if (strcmp(keys10,"MORPHOMATH")==0) { pseries->numfct=TT_IMASERIES_USER5_MORPHOMATH;}
   else if (strcmp(keys10,"MASQUECATA")==0) { pseries->numfct=TT_IMASERIES_USER5_MASQUECATA;}
   else if (strcmp(keys10,"ROTENTIERE")==0) { pseries->numfct=TT_IMASERIES_USER5_ROT;}
   return(OK_DLL);
}

int tt_user5_ima_series_builder2(TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   options->user5.param1=0.;
   strcpy(options->user5.filename,"./");
   options->user5.x0=0.;
   options->user5.y0=0.;
   options->user5.angle=0;
   return(OK_DLL);
}

int tt_user5_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"TRAINEE")==0) {
	 options->user5.param1=(double)(atof(argu));
   } else if (strcmp(mot,"FILENAME")==0) {   
      strcpy(options->user5.filename,argu);
   } else if (strcmp(mot,"X0")==0) {
      options->user5.x0=(double)(atof(argu));
   } else if (strcmp(mot,"Y0")==0) {
      options->user5.y0=(double)(atof(argu));
   } else if (strcmp(mot,"ANGLE")==0) {
      options->user5.angle=(double)(atof(argu))*TT_PI/180.;
   }
   return(OK_DLL);
}

int tt_user5_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pseries->numfct==TT_IMASERIES_USER5_TRAINEE) {
      *msg=tt_ima_series_trainee_1(pseries);
      *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_MASQUECATA){
	  *msg=tt_ima_masque_catalogue(pseries);
      *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_GEOGTO) {
	   *msg=tt_geo_defilant_1(pseries);
	   *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_MORPHOMATH) {
	   *msg=tt_morphomath_1(pseries);
	   *fct_found=TT_YES;
   } else if (pseries->numfct==TT_IMASERIES_USER5_ROT) {
	   *msg=tt_ima_rot(pseries);
	   *fct_found=TT_YES;
   }
   return(OK_DLL);
}

/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user5 pour IMA/STACK                   */
/**************************************************************************/
/**************************************************************************/

int tt_user5_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"TUTU")==0) { pstack->numfct=TT_IMASTACK_USER5_TUTU; }
   return(OK_DLL);
}

int tt_user5_ima_stack_builder2(TT_IMA_STACK *pstack)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   pstack->user5.param1=0.;
   return(OK_DLL);
}

int tt_user5_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"TUTU_PARAM")==0) {
      pstack->user5.param1=(double)(atof(argu));
   } 
   return(OK_DLL);
}

int tt_user5_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pstack->numfct==TT_IMASTACK_USER5_TUTU) {
      *msg=tt_ima_stack_5_tutu(pstack);
      *fct_found=TT_YES;
   }
   return(OK_DLL);
}


/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* ++++++++++++++++++++++++++++    FONCTIONS     +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**************************************************************************/
/* Fonction Rotation sans perte de données -> en sortie l'image est		  */
/* plus grande                                                            */
/* arguments possibles : x0,y,angle,nullpixel                             */
/**************************************************************************/
//buf1 imaseries "ROTENTIERE X0=1024 Y0=1024 ANGLE=45 nullpixel=0"

int tt_ima_rot(TT_IMA_SERIES *pseries)	
{
   TT_IMA *p_in,*p_out, *p_tmp1;
   int index;

   double x0, y0, x1, y1,theta;
   int w, h;
   int x, y;

   double cos_theta,sin_theta;      /* cos theta,sin theta */
   double old_x,old_y;              /* old point */
   double value;                    /* value of the pixel */
   double a[6];

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   p_tmp1=pseries->p_tmp1;
   index=pseries->index;

   theta=(pseries->user5.angle);
   cos_theta = cos(theta);
   sin_theta = sin(theta);

#ifndef max
#define max(a,b) (a>b?a:b)
#endif

   w = (int)max( fabs(p_in->naxis1*cos_theta - p_in->naxis2*sin_theta) , fabs(p_in->naxis1*cos_theta + p_in->naxis2*sin_theta) );
   h = (int)max( fabs(p_in->naxis1*sin_theta + p_in->naxis2*cos_theta) , fabs(p_in->naxis1*sin_theta - p_in->naxis2*cos_theta) );
   
   /* --- coordonnéees du centre de rotation dans l'image initiale --- */
   x0=pseries->user5.x0;
   y0=pseries->user5.y0;
   /* --- coordonnéees du centre de rotation dans la nouvelle image --- */
   x1=0.5*w;
   y1=0.5*h;

   /* --- initialisation ---*/
   tt_imacreater(p_out,w,h);

   /* --- combinaison translation + rotation de l'image initiale dans la grande image --- */
   for(x = 0;x < w;x++)
   {
      for(y = 0;y < h;y++)
      {
         old_x = x0 + (x-x1) * cos_theta + (y-y1) * sin_theta;
         old_y = y0 - (x-x1) * sin_theta + (y-y1) * cos_theta;
         value = interpol2(pseries,p_in,old_x,old_y,1);
         p_out->p[x+y*w]=(TT_PTYPE)(value);
      } 
   } 
   a[0]=cos_theta;
   a[1]=sin_theta;
   a[2]=x1-x0;
   a[3]=-sin_theta;
   a[4]=cos_theta;
   a[5]=y1-y0;
   tt_util_update_wcs(p_in,p_tmp1,a,2,NULL);

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction Interpol2   (copie de la fonction Interpol dans user3.c       */
/* arguments possibles : image,old_x,old_y,method,nullpixel               */
/**************************************************************************/
double interpol2 (TT_IMA_SERIES *pseries,TT_IMA *pin,double old_x,double old_y,int method)
{
   int x1,y1,x2,y2;
   double value=0.;                    /* value of the pixel */
   double pix1, pix2, pix3, pix4;   /* pixels for the interpolation */
   double alpha, beta;              /* coeffs for the interpolation */
   double nullpixel;
   int w,h;

   w=pin->naxis1;
   h=pin->naxis2;
   nullpixel=pseries->nullpix_value;

    if (method == 1)
    {
    	if ((old_x >= 0) && (old_x < w-1) && (old_y >= 0) && (old_y < h-1))
    	{
            x1 = (int)old_x;
            x2 = x1 + 1;
            y1 = (int)old_y;
            y2 = y1 + 1;
            alpha = old_x - x1;
            beta = old_y - y1;
            // Valeurs des 4 pixels d'interpolation
            pix1 = pin->p[x1+y1*w];
            pix2 = pin->p[x2+y1*w];
            pix3 = pin->p[x1+y2*w];
            pix4 = pin->p[x2+y2*w];
            // Calcul de l'interpolation
            value = (1-alpha)*(1-beta)*pix1 +
                    alpha*(1-beta)*pix2 +
                    (1-alpha)*beta*pix3 +
                    alpha*beta*pix4;
      }
      else  value = nullpixel;
    } /* end of if_statement */
    return value;
}

int tt_ima_masque_catalogue(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* remplace les trainées d'étoiles par le fond de ciel                     */
/***************************************************************************/
{
	TT_IMA *p_in,*p_out;
	double x,y,magn,nb=0;
	int kx,ky;
	long nelem;
    double dvalue,fond;
	int ymax,xmax;
 

	p_in=pseries->p_in;
	p_out=pseries->p_out;
	x=pseries->xcenter;
	y=pseries->ycenter;
	magn=pseries->magrlim;
	nelem=pseries->nelements;
	fond=pseries->threshold;
	ymax=p_in->naxis2;
	xmax=p_in->naxis1;

	if (magn >= 12) {
		nb=4;
	} else if ((magn >= 11)&&(magn <12)) {
		nb=6;
	} else if ((magn >= 10)&&(magn <11)) {
		nb=8;
	} else if ((magn >= 9)&&(magn <10)) {
		nb=10;
	} else if ((magn >= 8)&&(magn <9)) {
		nb=11;
	} else if ((magn >= 7)&&(magn <8)) {
		nb=12;
	} else if (magn<7) {
		nb=15;
	}

	nb=nb/2.;

	/* --- calcul de la fonction ---*/
    tt_imacreater(p_out,xmax,ymax);
    for (kx=0;kx<p_in->naxis1;kx++) {
		for (ky=0;ky<p_in->naxis2;ky++) {
			if ( ( ((kx-1-x)*(kx-1-x)+(ky-y)*(ky-y)) <= (nb+1)*(nb+1) ) || ( ((kx-x-47)*(kx-x-47)+(ky-y)*(ky-y)) <= (nb +1)*(nb+1)) || ( (ky>=(y-nb-1))&&(ky<=(y+nb+1))&&(kx>=x)&&(kx<=(x+47)) ) ){
				if (fond==0) {
					fond = 980;
				}
				p_out->p[ky*ymax+kx]=(TT_PTYPE)(fond);
			} else {
				 dvalue=(double)p_in->p[ky*ymax+kx];
				 p_out->p[ky*ymax+kx]=(TT_PTYPE)(dvalue);	 
			}
		}

     
    }

	return 0;
}


int tt_ima_series_trainee_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* detecte les trainées d'étoiles sur une image trainee                    */
/***************************************************************************/
/*														                   */
/* sortie = fichier														   */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int kkk,index, lt;
   double fwhmsat,seuil,seuila;
   double xc=0,yc=0,radius;
   char filenamesat[FLEN_FILENAME];
   double exposure;	
	double sampling;
  // double mode,mini,maxi;
  
   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   fwhmsat=pseries->fwhmsat;
   radius=pseries->radius;
   exposure=pseries->exposure;

	/* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=(double)p_in->p[kkk];
	  p_out->p[kkk]=(TT_PTYPE)(dvalue);	 
   }
   /* --- raz des variables a calculer ---*/
   //pseries->hicut=1.;
   //pseries->locut=0.;             
   //pseries->cutscontrast=1.0; //pour diminuer le contraste    
   
   /* --- filtre morpho sur l'image pour ne laisser que les étoiles --- */
   //longueur des trainees pour la camera Andor de TAROT
	sampling=9.1441235255136e-4;
   lt=(int)(0.004180983*exposure/(sampling)+2*12);
   if (lt<150) {
		openingByAnchor_1D_horizontal_courSE(p_out,p_out->naxis1,p_out->naxis2, lt,pseries->bitpix);
	} else {
		openingByAnchor_1D_horizontal_longSE(p_out,p_out->naxis1,p_out->naxis2, lt,pseries->bitpix);
	}
	//soustraction image initiale et filtre=> il ne reste plus que les étoiles traînées
	for (kkk=0;kkk<(int)(nelem);kkk++) {
	  p_out->p[kkk]=p_in->p[kkk]-p_out->p[kkk];	 
   }

   //tt_imasaver(p_out,"c:/d/geoflash/pointage5/pout_algo2.fit",16);

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
   tt_util_cuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);

   //seuils prédéfinis
	seuil=1.2*pseries->hicut;
	seuila=pseries->hicut;
	
   if (radius<=0) {
       xc=p_in->naxis1/2;
       yc=p_in->naxis2/2;
       radius=1.1*sqrt(xc*xc+yc*yc);
   }
   if (fwhmsat<=0) {
      fwhmsat=1.;
   }
   
   strcpy(filenamesat,"./catalog.cat");

   /* --- calcul ---*/
   tt_util_chercher_trainee(p_in,p_out,filenamesat,fwhmsat,seuil,seuila,xc,yc,exposure);
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_util_chercher_trainee(TT_IMA *pin,TT_IMA *pout,char *filename,double fwhmsat,double seuil,double seuila, double xc0, double yc0, double exposure)
/***************************************************************************/
/* detecte le début des trainées d'étoiles sur une image trainee           */
/***************************************************************************/
/*														                   */
/* 																		   */
/***************************************************************************/
{	
	int xmax,ymax,ntrainee,sizex,sizey,nb,background,flags;
	double fwhmyh,fwhmyb,posx,posy,posxanc,posyanc,fwhmx,fwhmy,lt,xc,yc,flux,fluxerr,fwhmd,a,b;
	double magnitude, magnitudeerr,theta,classstar;
	int k,k2,y,x,ltt,fwhmybi,fwhmyhi,fwhm,nelem;
	FILE *fic;
	double **mat, *para, *carac;
	double sampling;

	nelem=pin->nelements;
	posxanc=0;
	posyanc=0;
	para = (double*)calloc(6,sizeof(double));
	
	/* --- chercher les dimensions de l'image ---*/
	xmax=pin->naxis1;
	ymax=pin->naxis2;
	
	/* --- ouvre le fichier en ecriture ---*/
	fic=fopen(filename,"wt");

	/* --- longueur des trainees pour la camera Andor de TAROT*/
	sampling=9.1441235255136e-4;
	lt=0.004180983*exposure/(sampling);
	ltt = (int) lt;

	carac = (double*)calloc(5,sizeof(double));
	for (k=0;k<=4;k++) {
		carac[k]=0.0;
	}
	ntrainee=1;

	/* --- grande boucle sur l'image ---*/
	for (y=3;y<ymax-3;y++) {
		if ((y>ymax)||(y<0)) continue; 	
		for (x=3;x<(xmax-ltt-3);x++) {
			if (pout->p[y*ymax+x]<seuil) continue;
			// un pixel est au dessu du seuil
			for (k=0;k<ltt;k++) {
				if (pout->p[y*ymax+x+k]<seuil) break;
			}
			//une ligne de pixels > seuil a été détectée
			fwhmyh=0;
			fwhmyb=0;
			//recherche approximative des paramètres de la trainées
			for (k=0;k<ltt;k++) {
				for (k2=1;k2<40;k2++) {
					if ((k2+y)>= ymax) break;
					if (pout->p[(y+k2)*ymax+x+k]>seuil) {fwhmyh++;}
					else break;
				}
				for (k2=1;k2<40;k2++) {
					if (k2 > y) break;
					if (pout->p[(y-k2)*ymax+x+k]>seuil) {fwhmyb++;}
					else break;
				}
			}
			fwhmyh=fwhmyh/ltt;
			fwhmyb=fwhmyb/ltt;
			fwhmyhi =(int) (1.5*(fwhmyh+1));
			fwhmybi =(int) (1.5*(fwhmyb+1));
			sizex=ltt+fwhmyhi+fwhmybi+10;
			sizey=fwhmybi+fwhmyhi+10;
			fwhm= (int) ((fwhmybi+fwhmyhi)/2);
			if (fwhm == 0) {fwhm=1;}

			fwhmd = ((fwhmybi+fwhmyhi)/2);
			//pour les bords d'image
			if (fwhm>x) fwhm=x;
			if ((fwhm + x) > xmax) fwhm=(xmax-x);
			if ((sizex + x) > xmax) sizex=(xmax-x);
			if ((sizex + x) > xmax) sizex=(xmax-x);
			nb=y-fwhmybi;
			if (nb > 5) nb = 5;
			if ((sizey + y) > ymax) sizey=(ymax-y);

			//fixe la taille de la fenêtre de travail: sizex et sizey
			mat = (double**)calloc(sizex,sizeof(double));
			for(k=0;k<sizex;k++) {
				*(mat+k) = (double*)calloc(sizey,sizeof(double));
			}
			//--- Mise a zero des deux buffers 
			for(k=0;k<sizex;k++) {
			  for(k2=0;k2<sizey;k2++) {
				 mat[k][k2]=(double)0.;
			  }
			}
			for(k2=0;k2<sizey;k2++) {
			  for(k=0;k<sizex;k++) {
				 mat[k][k2] = pin->p[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k];
				 //temp[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k]=-1;// pour ne pas repasser sur la meme etoile
				 if ((y-fwhmybi-nb+k2<ymax-1)&&(x-fwhm-nb+k<xmax-ltt-1)&&(y-fwhmybi-nb+k2>1)&&(x-fwhm-nb+k>1)) {
					//pout->p[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k]=(float)seuila;// pour ne pas repasser sur la meme etoile
					 pout->p[xmax*(y-fwhmybi-nb+k2)+x-fwhm-nb+k]=0;// pour ne pas repasser sur la meme etoile
				 }
			  }
			}
			//recherche de la position du photocentre
			xc=2*(fwhm/1.5)+nb;
			yc=(fwhmybi/1.5)+nb;
			flux=0.0;
			//lt=lt+2*(fwhm+1);
			fittrainee (lt,fwhm, xc, sizex, sizey,mat,para,carac, exposure) ;
			//fittrainee2 (seuila,lt,fwhm,xc,yc,nb,sizex, sizey, mat, para, carac, exposure); 				
			//fittrainee3 (seuila,lt,xc,yc,nb,sizex, sizey, mat, para, carac, exposure); 
			//posx  = para[1]+x-fwhm-nb;
			posx  = para[1]+1.0*x+1.0;
			posy  = para[4]-(fwhmybi/1.5)-1.0*nb+1.0*y;
			
			/* --- pour ne pas avoir des étoiles doubles --- */
			if (((posx-posxanc)<0.05)&&((posy-posyanc)<0.05)) { continue;}

			posxanc=posx;
			posyanc=posy;

			//paramètres calculés rapidement ou pas du tout, pour que le fichier de sortie ressemble à celui de SExtractor
			flux=carac[1];
			fluxerr=0.2*flux;
			if (flux<=50.0) { flux = 50;}
			magnitude = -2.5*log10(flux) + 23.92;
			magnitudeerr = 0.2*magnitude;
			background = 2;
			theta =0.0;
			flags=0;
			classstar=0.90;
			b=2.0*fwhm/1.5;
			a=lt/2+2*fwhm/1.5;

			/*fittrainee (lt,fwhm,x,sizex, sizey, mat, para, carac, exposure); 
			posx  = (para[1]-fwhm-nb+2*x)/2;
			posy  = para[4]-fwhmybi-nb+y;*/

			fwhmx = para[2];						
			fwhmy = para[5];
			//*fondx = para[3];
			//*fondy = para[3];

			/* --- sortie du resultat ---*/
// attention matrice image commence au pixel 1,1 alors que l'analyse se fait avec 0,0 dans cette fonction !!
// catalog.cat: numero flux_best fluxerr_best magn_best magnerr_best background X Y X2 Y2 XY A B theta FWHM flags class_star
			fprintf(fic,"	%-d			%-9.1f		%-9.1f		%-9.1f		%-9.1f	%d	%9f		%9f		%8e	%8e	%8e	%f	%5.3f	%5.3f	%4.1f %d	%4.2f\n",
			ntrainee,flux,fluxerr,magnitude,magnitudeerr,background,posx+1,posy+1,carac[2],carac[3],carac[4],
			a,b,theta,fwhmd,flags, classstar);
			ntrainee++;
			tt_free2((void**)&mat,"mat");
			x=x+ltt;
		
		}
	}
	//tt_imasaver(pout,"c:/d/geoflash/pointage5/pout_algo2.fit",16);
	free(para);
	//free(temp);
	free(carac);	
	fclose(fic);
	return 1;
}


void fittrainee (double lt, double fwhm,double x, int sizex, int sizey,double **mat,double *p,double *carac, double exposure) 
/*********************************************************************************************/
/* fitte les trainées avec une ellipse														 */
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des traînées															 */
/*		fwhm = largeur à mi-hauteur de la fonction d'étalement de l'étoile non trainée		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		x = numero du pixel en x du debut de la zone										 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone à fitter						 */
/*	SORTIES																					 */
/*  p()=tableau des variables:																 */
/*     p[0]=intensite maximum de la gaussienne												 */
/*     p[1]=indice X du maximum de la gaussienne											 */
/*     p[2]=fwhm X																			 */
/*     p[3]=fond																			 */
/*     p[4]=indice Y du maximum de la gaussienne											 */
/*     p[5]=fwhm Y																			 */
/*  carac[0]=ecart-type																		 */
/*  carac[1]=flux																	         */
/*  carac[2]=X2																				 */
/*  carac[3]=Y2																				 */
/*  carac[4]=XY																				 */
/*********************************************************************************************/
{

	double *matx,*maty, intensite,moyy,*addx,matyy,posx,inten,flux,flux2=0.0;
	int jx,jxx,jy,moyjx,ltt,posmaty=0;
	int n23;
	double value,sx,sy,fmoy,fmed,seuilf,f23,a,b,c,xcc=0.0,ycc=0.0;
	double *vec;
	
	ltt = (int) lt;

	matx = (double*)calloc(sizex,sizeof(double));
	maty = (double*)calloc((sizex-ltt+7),sizeof(double));
	addx = (double*)calloc(sizex,sizeof(double));

	for (jx=0;jx<sizex;jx++) {
		matx[jx]=0.;
	}
	for (jy=0;jy<(sizex-ltt+7);jy++) {
		maty[jy]=0.;
	}
	for (jx=0;jx<sizex;jx++) {
		addx[jx]=0.;
	}

	moyy=0;
	inten=0.;
	// recherche du max d'intensité pour chaque colonne et ligne pour avoir une valeur approchée du centre de l'etoile
	for (jx=0;jx<sizex;jx++) {
		intensite=0.;
		for (jy=0;jy<sizey;jy++) {
			if (mat[jx][jy]>intensite) {
				intensite=mat[jx][jy]; matx[jx]=1.*jy; 
				
			}	
			if (intensite>inten) {inten=intensite;}
		}
		moyy+=matx[jx];
		addx[jx]+=mat[jx][jy];
	}
	moyy=moyy/sizex;
	moyjx = (int)moyy;
	if (moyy-moyjx>0.5) {moyjx+=1;}
	matyy=0;
	
	for (jx=0;jx<(sizex-ltt+6);jx++) {
		for (jxx=0;jxx<(ltt-6);jxx++) {
			maty[jx]+=mat[jx+jxx][moyjx];
		}
		if (maty[jx]>matyy) {
			matyy=maty[jx];posmaty=jx;
			 
		}
	}
	//posx et moyy représentent le pixel d'intensité la plus forte sur la ligne définie par y=moyy
	//moyy représente la ligne moyenne d'intensité maximale dans la zone 
	posx=(double)posmaty;
	p[1]=posx;
	p[2]=1;//a calculer
	p[4]=moyy;
	p[5]=1;//a calculer


	vec=NULL;
	vec = (double*)calloc(sizex*sizey,sizeof(double));
	n23=0;
	f23=0.;
	b=2*fwhm;
	a=ltt/2;
	c=1.5*fwhm;

	//definir une ellipse dont un des foyers est def par posmaty et moyx
	for (jy=0;jy<sizey;jy++) {	
		for (jx=0;jx<sizex;jx++) {			
			if (((jx-posx-a)*(jx-posx-a)/(a*a) + (jy-moyy)*(jy-moyy)/(b*b))<=1) {
				vec[n23]=mat[jx][jy];
				f23 += mat[jx][jy];
				n23++;
			}
		}
	}

	tt_util_qsort_double(vec,0,n23,NULL);

	fmoy=vec[0];
	if (n23!=0) {fmoy=f23/n23;}
	/* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
	fmed=(float)vec[(int)(0.5*n23)];
	free(vec);
	seuilf=0.2*(inten-fmed);
	sx=0.;
	sy=0.;
	flux=0.;
	for (jy=0;jy<sizey;jy++) {	
		for (jx=0;jx<sizex;jx++) {					
			value=mat[jx][jy]-fmed;
			if ((((jx-posx-a)*(jx-posx-a)/(a*a) + (jy-moyy)*(jy-moyy)/(c*c))<=1)&&(value>=seuilf)) {
				flux += value;
				sx += (double)(jx * value);
				sy += (double)(jy * value);			
			} 
			if ((((jx-posx)*(jx-posx) + (jy-moyy)*(jy-moyy))<=c*c)&&(value>=seuilf)) {
				flux2 += value;
						
			} 
		}
	}
	if (flux!=0.) {
		xcc = sx / flux -ltt/2;
		ycc = sy / flux ;
	}
	
	p[1]=xcc;
	p[4]=ycc;
	carac[1]= flux2;
	
	free(matx);
	free(maty);
	free(addx);

}


void fittrainee2 (double seuil,double lt, double fwhm,double xc,double yc,int nb, int sizex, int sizey,double **mat,double *p,double *carac,double exposure) 
/*********************************************************************************************/
/* fitte les trainées avec une gaussienne convoluée avec une un trait (= forme d'une trainée)*/
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des traînées															 */
/*		fwhm = largeur à mi-hauteur de la fonction d'étalement de l'étoile non trainée		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone à fitter						 */
/*	SORTIES																					 */
/*  p()=tableau des variables:																 */
/*     p[0]=intensite maximum de la gaussienne												 */
/*     p[1]=indice X du maximum de la gaussienne											 */
/*     p[2]=fwhm X																			 */
/*     p[3]=fond																			 */
/*     p[4]=indice Y du maximum de la gaussienne											 */
/*     p[5]=fwhm Y																			 */
/*  carac[0]=ecart-type																		 */
/*  carac[1]=flux																	         */
/*  carac[2]=X2																				 */
/*  carac[3]=Y2																				 */
/*  carac[4]=XY																				 */
/*********************************************************************************************/
{

   int l,nbmax,m,ltt;
   double l1,l2,a0,f,kk;
   double e,er1,y0;
   double m0,m1;
   double e1[6]; /* ici ajout */
   int i,jx,jy,k;
   double rr2;
   double xx,yy,flux,x2,y2,xy=0,xxx,yyy;
   double *F;

   int n23;
   double value,fmoy,fmed,f23,a,b,c;
   double *vec;

   ltt = (int) lt;
   
   F = (double*)calloc(sizex,sizeof(double));
   

   p[0]=mat[0][0];
   p[1]=xc;
   p[3]=mat[0][0];
   p[4]=yc;

  				
   for (jx=0;jx<sizex;jx++) {
      for (jy=0;jy<sizey;jy++) {
		 if (mat[jx][jy]>p[0]) {p[0]=mat[jx][jy]; }
         if (mat[jx][jy]<p[3]) {p[3]=mat[jx][jy]; }
      }
   }

   p[0]-=p[3];
   p[2]=1.;
   p[5]=1.;
   carac[0]=1.0;
   carac[1]=0.0;

   l=6;               /* nombre d'inconnues */
   //e=(float).005;     /* erreur maxi. */
   e=(float).05;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   //nbmax=250;         /* nombre maximum d'iterations */
   nbmax=50;         /* nombre maximum d'iterations */

   for (i=0;i<l;i++) {
	 e1[i]=er1;
   }

   m=0;
   l1=(double)1e10;

   fitgauss2d_b1:

	for (i=0;i<l;i++) {
		a0=p[i];

		fitgauss2d_b2:

		l2=0;
		for (jx=0;jx<sizex;jx++) {
			F[jx]=0.0;
		}
		

		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			f=0.0;
			for (k=0; k<=ltt; k++) {
				kk=(double)k;
				if (k==0) {
					f=-0.5*exp(-(xx-kk-p[1])*(xx-kk-p[1])/(p[2]*p[5]));
				}
				if (k==ltt) {
					f+=exp(-(xx-kk-p[1])*(xx-kk-p[1])/(p[2]*p[5]));
				}
				if ((k!=0)&&(k!=ltt)) {
					f+=0.5*exp(-(xx-kk-p[1])*(xx-kk-p[1])/(p[2]*p[5]));
				}
			}
			F[jx]=f;
			for (jy=0;jy<sizey;jy++) {
				yy=(double)jy;
				rr2=(yy-p[4])*(yy-p[4]);
				y0=F[jx]*p[0]*exp(-rr2/p[2]/p[5])+p[3];
				l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
			}
		}

		m0=l2;
		p[i]=a0*(1-e1[i]);
		l2=0;

		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			for (jy=0;jy<sizey;jy++) {
				yy=(double)jy;
				rr2=(yy-p[4])*(yy-p[4]);
				y0=F[jx]*p[0]*exp(-rr2/p[2]/p[5])+p[3];
				l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
			}
		}

		carac[0]=sqrt((double)l2/(sizex*sizey-l)); 
		m1=l2;
		if (m1>m0) e1[i]=-e1[i]/2;
		if (m1<m0) e1[i]=(float)1.2*e1[i];
		if (m1>m0) p[i]=a0;
		if (m1>m0) goto fitgauss2d_b2;
	}

	m++;
	if ((m==nbmax)||(l2==0)||(fabs((l1-l2)/l2)<e)) {

		vec=NULL;
		vec = (double*)calloc(sizex*sizey,sizeof(double));
		n23=0;
		f23=0.;
		b=2*(fwhm+1);
		a=ltt/2+2*(fwhm+1);
		c=1.5*(fwhm+1);

		//definir une ellipse dont un des foyers est def par posmaty et moyx
		for (jy=0;jy<sizey;jy++) {	
			for (jx=0;jx<sizex;jx++) {			
				if (((jx-a)*(jx-a)/(a*a) + (jy-p[4])*(jy-p[4])/(b*b))>1) {
					vec[n23]=mat[jx][jy];
					f23 += mat[jx][jy];
					n23++;
				}
			}
		}

		tt_util_qsort_double(vec,0,n23,NULL);

		fmoy=vec[0];
		if (n23!=0) {fmoy=f23/n23;}
		/* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
		fmed=(float)vec[(int)(0.5*n23)];
		free(vec);
		//seuilf=0.2*(p[0]+p[3]-fmed);
		n23=0;xxx=0;yyy=0;
		x2=0.0; y2=0.0;
		flux=0.;
		for (jy=0;jy<sizey;jy++) {	
			for (jx=0;jx<(int)(sizex/3);jx++) {	
				value=mat[jx][jy]-fmed;
				if ((((jx-p[1]-fwhm-nb)*(jx-p[1]-fwhm-nb) + (jy-p[4])*(jy-p[4]))<=c*c)&&(mat[jx][jy]>fmed/2+seuil/2)) {
					flux += mat[jx][jy];
					x2+=value*(jx-p[1])*(jx-p[1]);
					y2+=value*(jy-p[4])*(jy-p[4]);
					xy+=value*(jy-p[4])*(jx-p[1]);
					n23++;
					xxx+=1.0*(jx-p[1]);
					yyy+=1.0*(jy-p[4]);
				} 
			}
		}
		if (flux<=10.0) {
				flux=10.0;
				carac[2]=0.0;
				carac[3]=0.0;
				carac[4]=0.0;
			} else {
				carac[2]=x2/flux-(xxx/n23)*(xxx/n23);
				carac[3]=y2/flux-(yyy/n23)*(yyy/n23);
				carac[4]=xy/flux-(xxx/n23)*(yyy/n23);
			}
		carac[1]= flux;
		if (flux==0.0) {
			for (jy=0;jy<sizey;jy++) {	
				for (jx=0;jx<sizex;jx++) {					
					value=mat[jx][jy]-fmed;
					if ((((jx-p[1]-fwhm-nb)*(jx-p[1]-fwhm-nb) + (jy-p[4])*(jy-p[4]))<=b*b)&&(value>=0)) {
						flux += value;
						x2+=value*(jx-p[1])*(jx-p[1]);
						y2+=value*(jy-p[4])*(jy-p[4]);
						xy+=value*(jy-p[4])*(jx-p[1]);
						n23++;
						xxx+=1.0*(jx-p[1]);
						yyy+=1.0*(jy-p[4]);
					} 
				}
			}
			if (flux<=10.0){
				flux=10.0;
				carac[2]=0.0;
				carac[3]=0.0;
				carac[4]=0.0;
			} else {
				carac[2]=x2/flux-(xxx/n23)*(xxx/n23);
				carac[3]=y2/flux-(yyy/n23)*(yyy/n23);
				carac[4]=xy/flux-(xxx/n23)*(yyy/n23);
			}
			carac[1]= flux;
		}

		p[2]=p[2]/.601;p[5]=p[5]/.601; free(F);return;
	
	} else {

		l1=l2;
		goto fitgauss2d_b1;
	}
}
	

void fittrainee3 (double seuil,double lt,double xc,double yc,int nb,int sizex, int sizey,double **mat,double *p,double *carac,double exposure) 
/*********************************************************************************************/
/* fitte les trainées avec une gaussienne convolué avec une un trait (= forme d'une trainée) */
/*	approximation de la fonction erf													     */
/*********************************************************************************************/
/*	ENTREES													                                 */
/* 		lt = longueur des traînées															 */
/*		fwhm = largeur à mi-hauteur de la fonction d'étalement de l'étoile non trainée		 */
/*		sizex = nombre de points sur cote x de mat											 */
/*		sizey = nombre de points sur cote y de mat											 */
/*		**mat = tableau 2d des valeurs des pixels de la zone à fitter						 */
/*	SORTIES																					 */
/*  p()=tableau des variables:																 */
/*     p[0]=intensite maximum de la gaussienne												 */
/*     p[1]=indice X du maximum de la gaussienne											 */
/*     p[2]=fwhm X																			 */
/*     p[3]=fond																			 */
/*     p[4]=indice Y du maximum de la gaussienne											 */
/*     p[5]=fwhm Y																			 */
/*  ecart=ecart-type																		 */
/*********************************************************************************************/
{
   
   int l,nbmax,m,ltt;
   double l1,l2,a0;
   double e,er1,y0;
   double m0,m1,vs;
   double e1[6]; /* ici ajout */
   int i,jx,jy;
   double rr2;
   double xx,yy;

   //vitesse sidérale
   vs = 0.004180983;
   ltt = (int) lt;

   p[0]=mat[0][0];
   p[1]=xc;
   p[3]=mat[0][0];
   p[4]=yc;

  				
   for (jx=0;jx<sizex;jx++) {
      for (jy=0;jy<sizey;jy++) {
		 if (mat[jx][jy]>p[0]) {p[0]=mat[jx][jy]; }
         if (mat[jx][jy]<p[3]) {p[3]=mat[jx][jy]; }
      }
   }

   p[0]-=p[3];
   p[2]=1.;
   p[5]=1.;
   carac[0]=1.0;
   l=6;               /* nombre d'inconnues */
   e=(float).005;     /* erreur maxi. */
   er1=(float).5;     /* dumping factor */
   nbmax=50;         /* nombre maximum d'iterations */

   for (i=0;i<l;i++) {
	 e1[i]=er1;
   }

   m=0;
   l1=(double)1e10;

   fitgauss2d_b1:

	for (i=0;i<l;i++) {
		a0=p[i];

		fitgauss2d_b2:

		l2=0;
		
		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			if (xx<=xc) {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(-erf((p[1]-jx)/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			} else {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(erf((jx-p[1])/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			}
		}

		m0=l2;
		p[i]=a0*(1-e1[i]);
		l2=0;

		for (jx=0;jx<sizex;jx++) {
			xx=(double)jx;
			if (xx<=xc) {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(-erf((p[1]-jx)/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			} else {
				for (jy=0;jy<sizey;jy++) {
					yy=(double)jy;
					rr2=(yy-p[4])*(yy-p[4]);
					y0=p[0]*exp(-rr2/p[2]/p[5])*(sqrt(p[2]*p[5]*3.1415926535)/2)*(erf((jx-p[1])/(p[2]*p[5]))+erf((lt-jx+p[1])/(p[2]*p[5])))+p[3]*lt;
					l2=l2+(mat[jx][jy]-y0)*(mat[jx][jy]-y0);
				}
			}
		}

		carac[0]=sqrt((double)l2/(sizex*sizey-l)); 
		m1=l2;
		if (m1>m0) e1[i]=-e1[i]/2;
		if (m1<m0) e1[i]=(float)1.2*e1[i];
		if (m1>m0) p[i]=a0;
		if (m1>m0) goto fitgauss2d_b2;
	}
	m++;
	if (m==nbmax) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
	if (l2==0) {p[2]=p[2]/.601;p[5]=p[5]/.601; return; }
	if (fabs((l1-l2)/l2)<e) {p[2]=p[2]/.601;p[5]=p[5]/.601;return; }
	l1=l2;
	goto fitgauss2d_b1;
}

double erf( double x ) {

    double t, z, retval;
    
    z = fabs( x );
    t = 1.0 / ( 1.0 + 0.5 * z );
    retval = t * exp( -z * z - 1.26551223 + t *
		      ( 1.00002368 + t *
			( 0.37409196 + t *
			  ( 0.09678418 + t *
			    ( -0.18628806 + t *
			      ( 0.27886807 + t *
				( -1.13520398 + t *
				  ( 1.48851587 + t *
				    ( -0.82215223 + t *
				      0.1708727 ) ) ) ) ) ) ) ) );
    if( x < 0.0 )
	return retval - 1.0;
    
    return 1.0 - retval;
}

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* ++++++++++++++++++++++++++++    FONCTIONS   MORPHO MATHS  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

int tt_geo_defilant_1(TT_IMA_SERIES *pseries) 
/*********************************************************************************************/
/* Recherche des GEO et des GTO dans les images traînées								     */
/* traitement basé sur le chapeau haut de forme de Morpho Maths							     */
/*********************************************************************************************/
/* Entrées: chemin = repertoire pour suaver les résultats									 */
/*			nom_trait= nom du traitement de morpho maths (choix entre TOPHAT et TOPHATE)	 */
/*					TOPHAT= chapeau haut de forme classique									 */
/*					TOPHATE= chapeau haut étendu (ouverture d'une fermeture)				 */
/*			struct_elem = forme de l'element structurant (RECTANGLE, DAIMOND, CERCLE)		 */
/*			x1 = longueur sur l'axe x de SE													 */
/*			y1 = largeur sur l'axe y de SE													 */
/*	Les résultats sont enregistrés dans deux fichiers textes palcés dans $chemin			 */														 
/*********************************************************************************************/
/*      pour le moment les SE seront de dimensions impaires pour avoir un centre centré!     */
/*********************************************************************************************/

//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//buf1 load "c:/d/geoflash/pointage5/images_pb_detections_a_tester/grosse_tache/IM_20070302_190016827_070228_15083000.fits.gz"
//set chemin "c:/d/geoflash/pointage5/"
//buf1 imaseries "GEOGTO filename=$chemin nom_trait=TOPHATE struct_elem=RECTANGLE x1=15 y1=1"
//buf1 imaseries "GEOGTO filename=$chemin nom_trait=$nom_Trait struct_elem=$struct_Elem x1=$dim1 y1=$dim2"
{
	TT_IMA *p_in,*p_out,*p_tmp1,*p_tmp3,*p_tmp4;
	int kkk,kk,x,y,k1,k2,k3,k5,n2,n1,nbnul,i,x0,y0;
	double xfin,yfin,xdebut,ydebut,l;
	int index,naxis1,naxis2,x1,y1,nb_ss_image1,nb_ss_image2,k,rotation;
	double dvalue,somme_value,somme_x,somme_y;
	char filenamegeo[FLEN_FILENAME], centro[11];
	FILE *fic;
	double *eq;
	int smax=5050;
	double bary_x[5050], bary_y[5050], somme[5050];
	double sommexy,sommex,sommey,sommexx;
	double fwhmx,fwhmy, xcc,fwhmxy,ycc,r1,r2,r3,r11,r22,r33,dx,dy,dx2,dy2,d2,fmoy,fmed,f23,sigma,flux,ra,dec,radebut,rafin,decdebut,decfin;
	int taille,xx1,xx2,yy1,yy2,msg,n23,j,n23d,n23f,nsats,valid_ast;
	double *vec;
	double *pp, *ecart;
	int sizex, sizey,nb,largxx,largx,seuil_nbnul,bordh,bordd,bord;
	TT_ASTROM p_ast;
	TYPE_PIXELS *iX, *iY, pixel;
	double *dX, *dY;
	double sampling;

	/* --- intialisations ---*/
	p_in=pseries->p_in; 
	p_tmp4=pseries->p_tmp4; 
	p_out=pseries->p_out;
	p_tmp1=pseries->p_tmp1;
	p_tmp3=pseries->p_tmp3;
	naxis1=p_in->naxis1;
	naxis2=p_in->naxis2;
	index=pseries->index;
	x1=pseries->x1;
	y1=pseries->y1;

	if (strcmp(pseries->user5.filename,"")!=0) {
		strcpy(filenamegeo,pseries->user5.filename);
		strcat(filenamegeo,"geostat.txt");
	} else {
		strcpy(filenamegeo,"geostat.txt");
	}

	eq = (double*)calloc(3,sizeof(double));
	
	/* --- calcul de la fonction ---*/
	tt_imacreater(p_out,naxis1,naxis2);
	tt_imadestroyer(p_tmp1);
	tt_imabuilder(p_tmp1);
	tt_imacreater(p_tmp1,naxis1,naxis2);

	tt_morphomath_1(pseries);	
	//pour visualiser le tophat 
	//tt_imasaver(p_out,"c:/d/geoflash/pointage5/tophat.fit",16);	

	/* --- lit les parametres astrometriques de l'image ---*/
	valid_ast=1;
	tt_util_getkey0_astrometry(p_in,&p_ast,&valid_ast);
	sampling=9.1441235255136e-4;
	sampling=fabs(p_ast.cdelta1)*180/(TT_PI); // modif AK le 9/10/2011

//////////////////////////////////////////////
/* ----------------------------------------- */
/* --- recherche des traînées dans p_out --- */
/* ----------------------------------------- */
///////////////////////////////////////////////

	//couper l'image en 64 sous-images (imagette) de 256*256 pixels pour les images TAROT
	nb_ss_image1=8;nb_ss_image2=8;
	n2=(int)naxis2/nb_ss_image2;
	n1=(int)naxis1/nb_ss_image1;
	pseries->threshold=1;
	nsats=1;
	//definition de la zone de la sous_image
	p_tmp3->naxis1=n1;
	p_tmp3->naxis2=n2;
	tt_imacreater(p_tmp3,n1,n2);

	/* --- ouvre le fichier en ecriture ---*/
	fic=fopen(filenamegeo,"wt");
	for (kk=0;kk<2;kk++) {//kk=1 pour imagette décalée, c'est le deuxième passage
		k=0;
		k3=0;k5=0;
		for (kkk=0;kkk<(nb_ss_image1-kk)*(nb_ss_image2-kk);kkk++) {	
			//gestion des bord du chapeau haut de forme = fausse détections
			yy1=0, yy2=0, xx1=0, xx2=0, x0=0,y0=0;dvalue=0;
			if (kk==0) {
				if (kkk<nb_ss_image1) {
					yy1=y1+1;
				}
				if (kkk>=nb_ss_image1*(nb_ss_image1-1)) {
					yy2=y1+1;
				}
				if (kkk%nb_ss_image1==0) {
					xx1=x1+1;
				}
				if (kkk%nb_ss_image1==7) {
					xx2=x1+1;
				}
			}
			//première imagette en bas à gauche, dernière en haut à droite
			for (k1=0;k1<n1;k1++) {
				for (k2=0;k2<n2;k2++) {
					if ((k1>=n1-xx2)||(k1<=xx1)||(k2<=yy1)||(k2>=n2-yy2)) {
						p_tmp3->p[n1*k2+k1]=0;
					} else {
						dvalue=(double)p_out->p[naxis1*(k2+k3*n2+kk*n2/2)+k1+k5+kk*n1/2];
						p_tmp3->p[n1*k2+k1]=(TT_PTYPE)(dvalue);
					}
				}
			}
			//tt_imasaver(p_tmp3,"c:/d/geoflash/pointage5/gtopetite.fit",16);
			tt_ima_series_hough_myrtille(p_tmp3,p_tmp4,n1,n2,1,eq);
			
			//recupère les coordonnées de la droite détectée y=a0*x+b0 y=eq[0]*x+eq[1] et eq[2]=0, si la droite est verticale x=eq[2] et eq[0]=eq[1]=0
			if ((eq[0]!=0)||(eq[1]!=0)||(eq[2]!=0)) {									
	/* -------------------------------------------------------------- */
	/* --- recherche du barycentre de la trainee et de sa largeur --- */
	/* -------------------------------------------------------------- */
				rotation=0;
				/* --- imagette avec droites a fortes pentes --- */
				/* --------------------------------------------- */
				if ((eq[0]>1.0)||(eq[0]<-1.0)) {
					for (k1=0;k1<n1;k1++) {
						for (k2=0;k2<n2;k2++) {
							if ((k1<=xx1)||(k1>=n1-xx2)||(k2>=n2-yy2)||(k2<=yy1)) {
								p_tmp3->p[n1*k1+(n2-1)-k2]=0;
							} else {
								dvalue=(double)p_out->p[naxis1*(k2+k3*n2+kk*n2/2)+k1+k5+kk*n1/2];
								p_tmp3->p[n1*k1+(n2-1)-k2]=(TT_PTYPE)(dvalue); //rotation de +90° de l'imagette (sens trigo)
							}
						}
					}
					//tt_imasaver(p_tmp3,"c:/d/geoflash/pointage5/gtopetite_rot.fit",16);
					tt_ima_series_hough_myrtille(p_tmp3,p_tmp4,n1,n2,1,eq);
					rotation=1;
				}

				/* --- recherche des paramètres du défilant --- */
				/* -------------------------------------------- */
				somme_value=0;somme_x=0;somme_y=0;sommex=0;sommey=0;xdebut=0;ydebut=0;xfin=0;yfin=0;largx=0;nb=0;fwhmx=0;fwhmy=0;bordh=0;bordd=0;bord=0;		
				for (k1=0;k1<n1;k1++) {	
					largxx=0;
					for (k2=(int)(eq[0]*k1+eq[1]-8);k2<=(int)(eq[0]*k1+eq[1]+8);k2++) {
						if (k2<0) continue;
						if (k2>=n2-10) {
							if (k2>=n2) break;
							else if (dvalue>0) bordh=1;
						}
						if (k1>=n1-10) {
							if (dvalue>0) bordd=1;
						}
						dvalue=(double)p_tmp3->p[n1*k2+k1];
						somme_value= somme_value+dvalue;
						somme_x=somme_x+k1*dvalue;	
						somme_y=somme_y+k2*dvalue;
						if (dvalue>0)	largxx++;
					}
					if (largxx!=0) {
						largx+=largxx;
						nb++;
					}
				}	
				largxx=1;
				if (nb != 0) {
					largxx= (int) (floor(largx*1.0/nb));
					largx=(int)(floor(largx*1.0/(nb)))+1;
				}
				if (largx<3) { largx=3;}
				if (somme_value!=0) {
					/* --- coordonnées du centre --- */
					somme_x=somme_x*1.0/somme_value;
					somme_y=somme_y*1.0/somme_value;
					if (somme_x<0) somme_x=0;
					if (somme_x>n1) somme_x=n1-1;
					if (somme_y<0) somme_y=0;
					if (somme_y>n2) somme_y=n2-1;
					//cas d'un barycentre pas localisé sur la traînée alors on cherche le maximum
					if (p_tmp3->p[n1*(int)(floor(somme_y))+(int)(floor(somme_x))]<=0.0) {
						somme_value=0;
						for (k1=0;k1<n1;k1++) {								
							for (k2=(int)(eq[0]*k1+eq[1]-8);k2<=(int)(eq[0]*k1+eq[1]+8);k2++) {
								if (k2<0) continue;
								if (k2>=n2) break;
								dvalue=(double)p_tmp3->p[n1*k2+k1];
								if (dvalue>somme_value)	{
									somme_value=dvalue;
									somme_x=k1;
									somme_y=k2;
								}	
							}							
						}		
					}
				}

				/* --- cas des defilants trop pres du bord de la petite imagette --- */
				/* ----------------------------------------------------------------- */
				if (((kk==0)&&(bordd==1)&&(somme_x>=n1-20)&&(kkk%nb_ss_image1!=7))||((kk==0)&&(bordh==1)&&(somme_y>=n2-20)&&(kkk<nb_ss_image1*(nb_ss_image1-1)))) {
					//nouvelle imagette centrée sur somme_x,somme_y
					bord=1;
					sommex=somme_x-n1/2;
					sommey=somme_y-n2/2;
					if (kkk%nb_ss_image1==7) {
						sommex=0;
					} else if (kkk>=nb_ss_image1*(nb_ss_image1-1)) {
						sommey=0;
					} 
					if (sommex<0) sommex=n1/2;
					if (sommex>n1) sommex=n1-1;
					if (sommey<0) sommey=n2/2;
					if (sommey>n2) sommey=n2-1;
					if (rotation==0) {
						for (k1=0;k1<n1;k1++) {
							for (k2=0;k2<n2;k2++) {
								if ((k1>=n1-xx2)||(k1<=xx1)||(k2<=yy1)||(k2>=n2-yy2)) {
									p_tmp3->p[n1*k2+k1]=0;
								} else {
									dvalue=(double)p_out->p[naxis1*(k2+k3*n2+(int)sommey)+k1+k5+(int)sommex];
									p_tmp3->p[n1*k2+k1]=(TT_PTYPE)(dvalue);
								}
							}
						}
					} else {
						for (k1=0;k1<n1;k1++) {
							for (k2=0;k2<n2;k2++) {
								if ((k1>=n1-xx2)||(k1<=xx1)||(k2<=yy1)||(k2>=n2-yy2)) {
									p_tmp3->p[n1*k1+(n2-1)-k2]=0;
								} else {
									dvalue=(double)p_out->p[naxis1*(k2+k3*n2+(int)sommey)+k1+k5+(int)sommex];
									p_tmp3->p[n1*k1+(n2-1)-k2]=(TT_PTYPE)(dvalue); //rotation de +90° de l'imagette (sens trigo)
								}
							}
						}
					}
					//tt_imasaver(p_tmp3,"c:/d/geoflash/pointage5/gtopetite2.fit",16);
					tt_ima_series_hough_myrtille(p_tmp3,p_tmp4,n1,n2,1,eq);

					somme_value=0;somme_x=0;somme_y=0;		
					for (k1=0;k1<n1;k1++) {	
						largxx=0;
						for (k2=(int)(eq[0]*k1+eq[1]-8);k2<=(int)(eq[0]*k1+eq[1]+8);k2++) {
							if (k2<0) continue;
							if (k2>=n2-10) {
								if (k2>=n2) break;
								else if (dvalue>0) bordh=1;
							}
							if (k1>=n1-10) {
								if (dvalue>0) bordd=1;
							}
							dvalue=(double)p_tmp3->p[n1*k2+k1];
							somme_value= somme_value+dvalue;
							somme_x=somme_x+k1*dvalue;	
							somme_y=somme_y+k2*dvalue;
							if (dvalue>0)	largxx++;
						}
						if (largxx!=0) {
							largx+=largxx;
							nb++;
						}
					}
					largxx=1;
					if (nb != 0) {
						largxx= (int) (floor(largx*1.0/nb));
						largx=(int)(floor(largx*1.0/(nb)))+1;
					}
					if (largx<3) { largx=3;}
					if (somme_value!=0) {
						/* --- coordonnées du centre --- */
						somme_x=somme_x*1.0/somme_value;
						somme_y=somme_y*1.0/somme_value;
						if (somme_x<0) somme_x=0;
						if (somme_x>n1) somme_x=n1-1;
						if (somme_y<0) somme_y=0;
						if (somme_y>n2) somme_y=n2-1;
						//cas d'un barycentre pas localisé sur la traînée alors on cherche le maximum
						if (p_tmp3->p[n1*(int)(floor(somme_y))+(int)(floor(somme_x))]<=0.0) {
							somme_value=0;
							for (k1=0;k1<n1;k1++) {								
								for (k2=(int)(eq[0]*k1+eq[1]-8);k2<=(int)(eq[0]*k1+eq[1]+8);k2++) {
									if (k2<0) continue;
									if (k2>=n2) break;
									dvalue=(double)p_tmp3->p[n1*k2+k1];
									if (dvalue>somme_value)	{
										somme_value=dvalue;
										somme_x=k1;
										somme_y=k2;
									}	
								}							
							}		
						}
					} 
				}				
			
				if (somme_value!=0) {
					/* --- changement de repère --- */
					/* ---------------------------- */
					if (rotation==1) {
						//rotation inverse des coefficients: 
						if (eq[0]!=0.0) {
							dvalue=eq[0];
							eq[0]=-1.0/eq[0];
							eq[1]=n2+eq[1]/dvalue;
						} else {
							eq[2]=n2-eq[1];
							eq[0]=eq[1]=0;						
						}
						dvalue=somme_x;
						somme_x=somme_y;
						somme_y=n2-dvalue;	
					}
					if (bord==1) {
						if (rotation==1) {
							dvalue=sommex;
							sommex=sommey;
							sommey=n2-dvalue;
						}
						if (eq[2]==0) {
							eq[1]=eq[1]-(sommex)*eq[0]+sommey;
						} else {
							eq[2]=eq[2]-sommex+k5;
						}
						somme_x=somme_x+sommex;
						somme_y=somme_y+sommey;
					} 
					//changement de repère: petite image -> grande image
					if (eq[2]==0) {
						eq[1]=eq[1]-(k5+kk*n1/2)*eq[0]+(k3)*n2+kk*n2/2;
					} else {
						eq[2]=eq[2]+k5+kk*n1/2;
					}
				
					//changement de repère
					somme_x=somme_x+k5+kk*n1/2;
					if (somme_x>=naxis1) {
						somme_x=naxis1-1;
					}
					if (somme_x<0) {
						somme_x=0;
					}
					somme_y=somme_y+(k3)*n2+kk*n2/2;
					if (somme_y>=naxis2) {
						somme_y=naxis2-1;
					}
					if (somme_y<0) {
						somme_y=0;
					}
					
	/* ----------------------------------------------------- */
	/* --- recherche du debut et de la fin de la trainee --- */
	/* ----------------------------------------------------- */
					xdebut=0;ydebut=0;xfin=0;yfin=0;
					//  seuil pour recherche des extrémitées de la traînées
					/* --- recherche du maximun local --- */
					x=(int)somme_x;
					y=(int)somme_y;
					somme_value=p_in->p[y*naxis1+x];
					while ((x<naxis1)&&(y<naxis2)&&(x>0)&&(y>0)) { 
						i=0;
						for (k1=-1;k1<=2;k1++) {
							for (k2=-1;k2<=2;k2++) {
								if ((y+k1<y1)||(y+k1>=naxis2-y1)||(x+k2<x1)||(x+k2>=naxis1-x1)) continue;
								if (p_in->p[(y+k1)*naxis1+x+k2]>somme_value) {
									somme_value=p_in->p[(y+k1)*naxis1+x+k2];
									x=x+k2;
									y=y+k1;
									i=1;
								}
							}
						}
						if (i==0) break;
					}
					somme_x=x;
					somme_y=y;
					dvalue=p_in->p[naxis1*(int)somme_y+(int)somme_x];
					//if (dvalue>pseries->bgmean+20*pseries->bgsigma) {
					//	seuil_nbnul= 10*(4*largx);
					//} else if (dvalue>pseries->bgmean+15*pseries->bgsigma) {
					if (dvalue>pseries->bgmean+15*pseries->bgsigma) {
						seuil_nbnul= 20*(4*largx);
					} else {
						seuil_nbnul= 35*(4*largx);
					}

					nbnul=0;nb=0;
					if ((eq[0]<=1.0)&&(eq[0]>=-1.0)) {//droites faibles pentes 
						for (k1=(int)(floor(somme_x));k1>=0;k1--) {	// recherche du début					
							for (k2=(int)(eq[0]*k1+eq[1]-2*largx);k2<=(int)(eq[0]*k1+eq[1]+2*largx);k2++) {
								if (k2<0) continue;
								if (k2>=naxis2) break;
								if (nbnul>seuil_nbnul) {
									if ((xdebut==0)&&(ydebut==0)) {
										xdebut=somme_x;
										ydebut=somme_y;
									}
									break;
								}
								dvalue=p_out->p[naxis1*(k2)+k1];
								if (dvalue<=0.0) {
									nbnul++;	
								}
								if (dvalue>0.0) {
									nbnul=(int)(nbnul/(int)(seuil_nbnul/3.));
									nb++;
									if (nbnul<=1) {
										xdebut=k1;
										ydebut=k2;
									} 	
								}		
							}						
						}
						nbnul=0;
						for (k1=(int)(floor(somme_x));k1<naxis1;k1++) {	// recherche de la fin					
							for (k2=(int)(eq[0]*k1+eq[1]-2*largx);k2<=(int)(floor(eq[0]*k1+eq[1]+2*largx));k2++) {
								if (k2<0) continue;
								if (k2>=naxis2) break;
								if (nbnul>seuil_nbnul) {
									if ((xfin==0)&&(yfin==0)) {
										xfin=somme_x;
										yfin=somme_y;
									}
									break;
								}
								dvalue=p_out->p[naxis1*(k2)+k1];
								if (dvalue<=0.0) {
									nbnul++;	
								}
								if (dvalue>0.0) {
									nbnul=(int)(nbnul/(int)(seuil_nbnul/3.));
									nb++;
									if (nbnul<=1) {
										xfin=k1;
										yfin=k2;
									} 
								}		
							}						
						}
					} else if (eq[0]!=0.0) {
						for (k2=(int)(floor(somme_y));k2>=0;k2--) {	// recherche du début					
							for (k1=(int)((k2-eq[1])/eq[0]-2*largx);k1<=(int)(floor((k2-eq[1])/eq[0]+2*largx));k1++) {
								if (k1<0) continue;
								if (k1>=naxis1) break;
								if (nbnul>seuil_nbnul) {
									if ((xdebut==0)&&(ydebut==0)) {
										xdebut=somme_x;
										ydebut=somme_y;
									}
									break;
								}
								dvalue=p_out->p[naxis1*(k2)+k1];
								if (dvalue<=0.0) {
									nbnul++;	
								}
								if (dvalue>0.0) {
									nbnul=(int)(nbnul/(int)(seuil_nbnul/3.));
									nb++;
									if (nbnul<=1) {
										xdebut=k1;
										ydebut=k2;
									} 	
								}		
							}						
						}
						nbnul=0;;
						for (k2=(int)(floor(somme_y));k2<naxis1;k2++) {	// recherche de la fin					
							for (k1=(int)((k2-eq[1])/eq[0]-2*largx);k1<=(int)(floor((k2-eq[1])/eq[0]+2*largx));k1++) {
								if (k1<0) continue;
								if (k1>=naxis1) break;
								if (nbnul>seuil_nbnul) {
									if ((xfin==0)&&(yfin==0)) {
										xfin=somme_x;
										yfin=somme_y;
									}
									break;
								}
								dvalue=p_out->p[naxis1*(k2)+k1];
								if (dvalue<=0.0) {
									nbnul++;	
								}
								if (dvalue>0.0) {
									nbnul=(int)(nbnul/(int)(seuil_nbnul/3.));
									nb++;
									if (nbnul<=1) {
										xfin=k1;
										yfin=k2;
									} 
								}		
							}						
						}
					} else { //droite verticale
						for (k2=(int)(floor(somme_y));k2>=0;k2--) {	// recherche du début					
							for (k1=(int)(eq[2]-2*largx);k1<=(int)(floor(eq[2]+2*largx));k1++) {
								if (k1<0) continue;
								if (k1>=naxis1) break;
								if (nbnul>seuil_nbnul) {
									if ((xdebut==0)&&(ydebut==0)) {
										xdebut=somme_x;
										ydebut=somme_y;
									}
									break;
								}
								dvalue=p_out->p[naxis1*(k2)+k1];
								if (dvalue<=0.0) {
									nbnul++;	
								}
								if (dvalue>0.0) {
									nbnul=(int)(nbnul/(int)(seuil_nbnul/3.));
									nb++;
									if (nbnul<=1) {
										xdebut=k1;
										ydebut=k2;
									} 	
								}		
							}						
						}
						nbnul=0;
						for (k2=(int)(floor(somme_y));k2<naxis1;k2++) {	// recherche de la fin					
							for (k1=(int)(eq[2]-2*largx);k1<=(int)(floor(eq[2]+2*largx));k1++) {
								if (k1<0) continue;
								if (k1>=naxis1) break;
								if (nbnul>seuil_nbnul) {
									if ((xfin==0)&&(yfin==0)) {
										xfin=somme_x;
										yfin=somme_y;
									}
									break;
								}
								dvalue=p_out->p[naxis1*(k2)+k1];
								if (dvalue<=0.0) {
									nbnul++;	
								}
								if (dvalue>0.0) {
									nbnul=(int)(nbnul/(int)(seuil_nbnul/3.));
									nb++;
									if (nbnul<=1) {
										xfin=k1;
										yfin=k2;
									} 
								}		
							}						
						}
					}
				
  					if (xdebut<0) {xdebut=0;}
					if (xfin<0) {xfin=0; xdebut=0;}
					if (ydebut<0) {ydebut=0;}
					if (yfin<0) {yfin=0; ydebut=0;}
					if (xfin>naxis1) {xfin=naxis1-1;}
					if (xdebut>naxis1) {xfin=naxis1-1;xdebut=naxis1-1;}
					if (yfin>naxis2) {yfin=naxis2-1;}
					if (ydebut>naxis2) {yfin=naxis2-1;ydebut=naxis2-1;}

					// arbitrairement point debut a gauche ou en haut pour droite verticale
					if (xdebut>xfin) {
						dvalue=xdebut;
						xdebut=xfin;
						xfin=dvalue;
					}
					if ((eq[0]>0)&&(ydebut>yfin)) {
						dvalue=ydebut;
						ydebut=yfin;
						yfin=dvalue;
					}
					if ((eq[0]<=0)&&(ydebut<yfin)) {
						dvalue=ydebut;
						ydebut=yfin;
						yfin=dvalue;
					}

				} else {
					somme_x=0;xdebut=0;xfin=0;
					somme_y=0;ydebut=0;yfin=0;
				}
								
				if ((somme_x!=0)&&(somme_y!=0)) {					
					/* --- calcul de la longueur de la traînée --- */
					l=sqrt((xdebut-xfin)*(xdebut-xfin)+(ydebut-yfin)*(ydebut-yfin));

					if ((l>=8)&&(l<=25)&&(nb>=l/2)) {
						//fitte une gaussienne pour calculé fwhmx et fwhmy 
						//* ---  discrimination GTO/GEO --- */
						xx1=(int)(xdebut-2*largx);
						xx2=(int)(xfin+2*largx);
						if (ydebut>yfin) {
							yy1=(int)(yfin-2*largx);
							yy2=(int)(ydebut+2*largx);
						} else if (ydebut==yfin){
							yy1=(int)(yfin-3*largx);
							yy2=(int)(ydebut+3*largx);
						} else {
							yy1=(int)(ydebut-2*largx);
							yy2=(int)(yfin+2*largx);
						}
						if (xx1<0) xx1=0;
						if (xx1>=naxis1) xx1=naxis1-1;
						if (xx2<0) xx2=0;
						if (xx2>=naxis1) xx2=naxis1-1;
						if (yy1<0) yy1=0;
						if (yy1>=naxis2) yy1=naxis2-1;
						if (yy2<0) yy2=0;
						if (yy2>=naxis2) yy2=naxis2-1;
  
						pp = (double*)calloc(6,sizeof(double));
						ecart = (double*)calloc(1,sizeof(double));
						sizex=xx2-xx1+1;
						sizey=yy2-yy1+1;

						//--- Mise a zero des deux buffers de binning
						iX = (TYPE_PIXELS*)calloc(sizex,sizeof(TYPE_PIXELS));
						dX = (double*)calloc(sizex,sizeof(double));
						iY = (TYPE_PIXELS*)calloc(sizey,sizeof(TYPE_PIXELS));
						dY = (double*)calloc(sizey,sizeof(double));	
								
						for(i=0;i<sizex;i++) *(iX+i) = (double)0.;
						for(i=0;i<sizey;i++) *(iY+i) = (double)0.;
						// il faut prendre en compte l'orientation si 0.5<eq[0]<1.5 pour améliorer le fit
						if (((eq[0]<1.5)&&(eq[0]>0.5))||((eq[0]>-1.5)&&(eq[0]<-0.5))) { // rotation de 45°
							for(j=0;j<sizey;j++) {
							   for(i=0;i<sizex;i++) {
								   if (j+yy1+i>=naxis2-1) pixel =0;
								   else pixel = p_out->p[naxis1*(j+yy1+i)+i+xx1];
									*(iX+i) += pixel;
									*(iY+j) += pixel;
							   }
							}
						} else {
							for(j=0;j<sizey;j++) {
							   for(i=0;i<sizex;i++) {
									pixel = p_out->p[naxis1*(j+yy1)+i+xx1];
									*(iX+i) += pixel;
									*(iY+j) += pixel;
							   }
							}
						}

						for(i=0;i<sizex;i++) dX[i] = (double)*(iX+i);
						for(i=0;i<sizey;i++) dY[i] = (double)*(iY+i);

						tt_fitgauss1d(sizex,dX,pp,ecart);      
						fwhmx=pp[2];  
						xcc=pp[1]+xx1;  
						tt_fitgauss1d(sizey,dY,pp,ecart); 
						fwhmy=pp[2];
						ycc=pp[1]+yy1; 
						dvalue=pp[0];
						free(pp);
						free(ecart);
						free(iX);
						free(dX);
						free(iY);
						free(dY);
						fwhmxy=(fwhmx>fwhmy)?(fwhmx/fwhmy):(fwhmy/fwhmx);
						// elimine les étoiles :
						j=0;
						for(i=(int)xcc;i<naxis1-x1;i++) {
							if (p_in->p[naxis1*(int)(floor(ycc))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
							else if ((j==0)&&(i-xcc<0.5*0.004180983*pseries->exposure/(sampling))) continue;
							else break;
						}
						for(i=(int)xcc;i>x1;i--) {
							if (p_in->p[naxis1*(int)(floor(ycc))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
							else if ((j==0)&&(xcc-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
							else break;
						}
						if (((floor(ycc-1))>=0)&&(j<(int)(0.65*0.004180983*pseries->exposure/(sampling)))) {
							j=0;
							for(i=(int)xcc;i<naxis1-x1;i++) {
								if (p_in->p[naxis1*(int)(floor(ycc-1))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(i-xcc<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
							for(i=(int)xcc;i>x1;i--) {
								if (p_in->p[naxis1*(int)(floor(ycc-1))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(xcc-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
						}
						if ((j<(int)(0.65*0.004180983*pseries->exposure/(sampling)))&&((floor(ycc+1))<naxis2)) {
							j=0;
							for(i=(int)xcc;i<naxis1-x1;i++) {
								if (p_in->p[naxis1*(int)(floor(ycc+1))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(i-xcc<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
							for(i=(int)xcc;i>x1;i--) {
								if (p_in->p[naxis1*(int)(floor(ycc+1))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(xcc-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
						}
						if ((eq[0]>-0.1)&&(eq[0]<0.1)&&((floor(ycc-2))>=0)&&(j<(int)(0.65*0.004180983*pseries->exposure/(sampling)))) {
							j=0;
							for(i=(int)xcc;i<naxis1-x1;i++) {
								if (p_in->p[naxis1*(int)(floor(ycc-2))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(i-xcc<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
							for(i=(int)xcc;i>x1;i--) {
								if (p_in->p[naxis1*(int)(floor(ycc-2))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(xcc-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
						}
						if ((j<(int)(0.65*0.004180983*pseries->exposure/(sampling)))&&((floor(ycc+2))<naxis2)) {
							j=0;
							for(i=(int)xcc;i<naxis1-x1;i++) {
								if (p_in->p[naxis1*(int)(floor(ycc+2))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(i-xcc<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
							for(i=(int)xcc;i>x1;i--) {
								if (p_in->p[naxis1*(int)(floor(ycc+2))+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
								else if ((j==0)&&(xcc-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
								else break;
							}
						}

					} else {
						fwhmxy=2.0;
						dvalue=1.0;
						j=0;
					}
					
					//longueur de la traînée des étoiles en fonction du temps d'exposition: 0.004180983*pseries->exposure/(sampling)
					if ((l>8)&&(nb>=l/3)&&(fwhmxy>=2)&&(l*1./largxx>=1.5)&&(dvalue>0)&&(j<(int)(0.65*0.004180983*pseries->exposure/(sampling)))) {
						/* --- parametres de mesure precise ---*/
						xcc=somme_x;
						ycc=somme_y;
						fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;
						if (fwhmxy<2.) fwhmxy=2;
						r1=1.2*fwhmxy;
						r2=2.0*fwhmxy;
						r3=2.5*fwhmxy;
						r11=r1*r1;
						r22=r2*r2;
						r33=r3*r3;
						/* --- fond de ciel precis (fmoy,fmed,sigma) ---*/
						if (xdebut<=xfin) {
							xx1=(int)(xdebut-r3);
							xx2=(int)(xfin+r3);
						} else {
							xx1=(int)(xfin-r3);
							xx2=(int)(xdebut+r3);
						}
						if (ydebut<=yfin) {
							yy1=(int)(ydebut-r3);
							yy2=(int)(yfin+r3);
						} else {
							yy1=(int)(yfin-r3);
							yy2=(int)(ydebut+r3);
						}
						if (xx1<0) xx1=0;
						if (xx1>=naxis1) xx1=naxis1-1;
						if (xx2<0) xx2=0;
						if (xx2>=naxis1) xx2=naxis1-1;
						if (yy1<0) yy1=0;
						if (yy1>=naxis2) yy1=naxis2-1;
						if (yy2<0) yy2=0;
						if (yy2>=naxis2) yy2=naxis2-1;
						nb=(xx2-xx1+1)*(yy2-yy1+1);
						taille=sizeof(double);
						vec=NULL;
						if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec,&nb,&taille,"vf"))!=OK_DLL) {
						   fclose(fic);
						   tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_geostat (pointer vec)");
						   fclose(fic);
						   return(TT_ERR_PB_MALLOC);
						}
						n23=0;
						f23=0.;
						for (j=yy1;j<=yy2;j++) {
						   dy=1.*j-ycc;
						   dy2=dy*dy;
						   for (i=xx1;i<=xx2;i++) {
							  dx=1.*i-xcc;
							  dx2=dx*dx;
							  d2=dx2+dy2;
							  if ((d2>=r22)&&(d2<=r33)) {
								  vec[n23]=(double)p_in->p[naxis1*j+i];
								 f23 += (double)p_in->p[naxis1*j+i];
								 n23++;
							  }
						   }
						}
						tt_util_qsort_double(vec,0,n23,NULL);
						fmoy=vec[0];
						if (n23!=0) {fmoy=f23/n23;}
						/* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
						fmed=(float)vec[(int)(0.5*n23)];
						/*  calcul de l'ecart type du fond de ciel*/
						/*  en excluant les extremes a +/- 10 %*/
						sigma=0.;
						n23d=(int)(0.1*(n23-1));
						n23f=(int)(0.9*(n23-1));
						for (i=n23d;i<=n23f;i++) {
						   d2=(vec[i]-fmed);
						   sigma+=(d2*d2);
						}
						if ((n23f-n23d)!=0) {
						   sigma=sqrt(sigma/(n23f-n23d));
						}
						free(vec);
	/* ------------------------------------------ */
	/* --- ajustement par les moindres carrés --- */
	/* ------------------------------------------ */
						for (nb=0;nb<2050;nb++) {
								bary_x[nb]=0;
								bary_y[nb]=0;
								somme[nb]=0;
						}
						/* --- cas des droites faibles pentes ou horizontales --- */
						i=0;j=0; flux=0;
						if ((((eq[0]<=0.8)&&(eq[0]>=-0.8))||(eq[0]==0))&&(eq[2]==0)) {		
							for (k1=(int)xdebut;k1<=(int)xfin;k1++) {										
								for (k2=(int)(eq[0]*k1+eq[1]-largx-3);k2<=(int)(eq[0]*k1+eq[1]+largx+3);k2++) {
									if (k2<0) continue;
									if (k2>=naxis2) break;
									dvalue=(double)p_out->p[naxis1*k2+k1];
									if (i<smax) {
										if (dvalue>0) {
											somme[i]= somme[i]+dvalue;
											bary_y[i]=bary_y[i]+k2*dvalue;
										}
									}
									/* --- photometrie (flux) ---*/	
									dvalue=(double)p_in->p[naxis1*k2+k1]-fmed;
									if (dvalue>0) {
										flux += dvalue;
									}
								}								
								if (i<smax) { i++; }
							}
							sommexy=0;sommex=0;sommey=0;sommexx=0;							
							for (nb=0; nb<i; nb++) {
								if (bary_y[nb]==0) continue;
								if (somme[nb]!=0) {
									bary_y[nb]=bary_y[nb]*1.0/somme[nb];
									sommey=sommey+bary_y[nb];
									sommexy=sommexy+(xdebut+nb)*bary_y[nb];
									sommex=sommex+(xdebut+nb);
									sommexx=sommexx+(xdebut+nb)*(xdebut+nb);
									j++;
								} else {
									bary_y[nb]=0;
								}
							}
						}

						/* --- cas des droites fortes pentes ou verticales --- */
						else { 		
							if (eq[0]>0) { // droite forte pente positive
								for (k2=(int)ydebut;k2<=(int)yfin;k2++) {
									for (k1=(int)((k2-eq[1])/eq[0]-largx-3);k1<=(int)((k2-eq[1])/eq[0]+largx+3);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										dvalue=(double)p_out->p[naxis1*k2+k1];
										if (i<smax) {
											if (dvalue>0) {
												somme[i]= somme[i]+dvalue;
												bary_x[i]=bary_x[i]+k1*dvalue;
											}
										}
										/* --- photometrie (flux) ---*/	
										dvalue=(double)p_in->p[naxis1*k2+k1]-fmed;
										if (dvalue>0) {
											flux += dvalue;
										}
									}									
									if (i<smax) { i++; }
								}
							} else if (eq[0]<0) { // droite forte pente négative
								for (k2=(int)ydebut;k2>=(int)yfin;k2--) {
									for (k1=(int)((k2-eq[1])/eq[0]-largx-3);k1<=(int)((k2-eq[1])/eq[0]+largx+3);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										dvalue=(double)p_out->p[naxis1*k2+k1];
										if (i<smax) {
											if (dvalue>0) {
												somme[i]= somme[i]+dvalue;
												bary_x[i]=bary_x[i]+k1*dvalue;
											}
										}
										/* --- photometrie (flux) ---*/	
										dvalue=(double)p_in->p[naxis1*k2+k1]-fmed;
										if (dvalue>0) {
											flux += dvalue;
										}
									}
									if (i<smax) { i++; }
								}
							} else { //droite vertical
								for (k2=(int)yfin;k2>=(int)ydebut;k2--) {
									for (k1=(int)(eq[2]-largx-3);k1<=(int)(eq[2]+largx+3);k1++) {
										if (k1<0) continue;
										if (k1>=naxis1) break;
										dvalue=(double)p_out->p[naxis1*k2+k1];
										if (i<smax) {
											if (dvalue>0) {
												somme[i]= somme[i]+dvalue;
												bary_x[i]=bary_x[i]+k1*dvalue;
											}
										}
										/* --- photometrie (flux) ---*/	
										dvalue=(double)p_in->p[naxis1*k2+k1]-fmed;
										if (dvalue>0) {
											flux += dvalue;
										}
									}
									if (i<smax) { i++; }
								}									
							}	
							
							sommexy=0;sommex=0;sommey=0;sommexx=0;
							for (nb=0; nb<i; nb++) {
								if (somme[nb]!=0) {
									bary_x[nb]=bary_x[nb]*1.0/somme[nb]*1.0;									
									sommex=sommex+bary_x[nb];									
									sommexx=sommexx+bary_x[nb]*bary_x[nb];
									if (eq[0]<0) {
										sommexy=sommexy+bary_x[nb]*(ydebut-nb);
										sommey=sommey+(ydebut-nb);
									} else {
										sommexy=sommexy+bary_x[nb]*(ydebut+nb);
										sommey=sommey+(ydebut+nb);
									}
									j++;
								} else {
									bary_x[nb]=0;
								}
							}						 
						}
						
						if ((eq[2]==0)&&((sommexx!=0)||(sommex!=0))) {
							if ((j*sommexx-sommex*sommex)!=0) {	
								somme_value=eq[0];
								eq[0]=(j*sommexy-sommex*sommey)/(j*sommexx-sommex*sommex);		
								eq[1]=(sommey*sommexx-sommex*sommexy)/(j*sommexx-sommex*sommex);
							} else {
								eq[2]=sommex/(j);
								eq[0]=eq[1]=0;
								if (ydebut<yfin) {
									dvalue = yfin;
									yfin=ydebut;
									ydebut=dvalue;
								}
							}
						} else if (j>0) {
							eq[2]=sommex/(j);
							somme_value=eq[0]=eq[1]=0;
							if (ydebut<yfin) {
								dvalue = yfin;
								yfin=ydebut;
								ydebut=dvalue;
							}
						} else {
							eq[2]=0;
						}
						if (somme_value*eq[0]<0) { //il y a eu un changement de signe de eq[0]
							dvalue = yfin;
							yfin=ydebut;
							ydebut=dvalue;
						}
						/* --- recherche plus fine des bouts du segment --- */
						if (eq[2]==0) {
							if (eq[0]!=0) { 
								//dvalue=ydebut;
								ydebut=(eq[1]/(eq[0]*eq[0])+ydebut+xdebut/eq[0])/(1+1/(eq[0]*eq[0]));
								xdebut=(ydebut-eq[1])/eq[0];
								//dvalue=yfin;
								yfin=(eq[1]/(eq[0]*eq[0])+yfin+xfin/eq[0])/(1+1/(eq[0]*eq[0]));
								xfin=(yfin-eq[1])/eq[0];
								//gestion des bords d'images !!
							} else {
								ydebut=eq[1];
								yfin=eq[1];
							}
						} else {
							xdebut=eq[2];
							xfin=eq[2];
						}
						if (xdebut<0) {xdebut=0;}
						if (xfin<0) {xfin=0;}
						if (ydebut<0) {ydebut=0;}
						if (yfin<0) {yfin=0;}
						if (xfin>naxis1) {xfin=naxis1-1;}
						if (xdebut>naxis1) {xdebut=naxis1-1;}
						if (yfin>naxis2) {yfin=naxis2-1;}
						if (ydebut>naxis2) {ydebut=naxis2-1;}

						/* --- astrometrie (ra,dec) ---*/
						radebut=0.;rafin=0.;
						decdebut=0.;decfin=0.;
						if (valid_ast==TT_YES) {
						   tt_util_astrom_xy2radec(&p_ast,xdebut,ydebut,&radebut,&decdebut);
						   tt_util_astrom_xy2radec(&p_ast,xfin,yfin,&rafin,&decfin);
						}
						radebut*=180./(TT_PI);
						decdebut*=180./(TT_PI);
						rafin*=180./(TT_PI);
						decfin*=180./(TT_PI);


						/* --- mise a zero pour la détection des geo --- */
						if (eq[0]>0) {
							for (k1=(int)xdebut-largx-2;k1<(int)xfin+largx+2;k1++) {
								if (k1>=naxis1) break;	
								if (k1<0) continue;
								for (k2=(int)ydebut-largx-2;k2<(int)yfin+largx+2;k2++) {
									if (k2<0) continue;
									if (k2>=naxis2) break;
									//mettre a zero les pixels concernés pour ne pour ne pas avoir deux fois la traînées	
									p_out->p[naxis1*(k2)+k1]=0;
								}
							}	
						} else {//ydebut>yfin
							for (k1=(int)xdebut-largx-2;k1<(int)xfin+largx+2;k1++) {
								if (k1>=naxis1) break;
								if (k1<0) continue;
								if (eq[2]!=0) {// cas des droites verticales
									for (k2=(int)yfin-largx-2;k2<(int)ydebut+largx+2;k2++) {
										if (k2<0) continue;
										if (k2>=naxis2) break;
										p_out->p[naxis1*(k2)+k1]=0;
									}
								} else {
									for (k2=(int)yfin-largx-2;k2<(int)ydebut+largx+2;k2++) {
										if (k2<0) continue;		
										if (k2>=naxis2) break;										
										p_out->p[naxis1*(k2)+k1]=0;	
									}
								}		
							}
						}
						if (strcmp(pseries->centroide,"gauss")==0) {
							strcpy(centro,"fittegauss");
						} else {
							strcpy(centro,"barycentre");
						}
						//tt_imasaver(p_out,"c:/d/geoflash/pointage5/gto2.fit",16);
	/* ---------------------------------------------------- */
	/* --- enregistrer l'equation de la droite détectée --- */
	/* ---------------------------------------------------- */					
						fprintf(fic,"%d %f %f %f %f %f %f %f %f %f %f %f %f 2 %10s\n",nsats,xdebut,ydebut,xfin,yfin,flux,fmed,radebut,decdebut,rafin,decfin,fwhmx,fwhmy,centro);
						nsats++;
					}
				}
			}	
			k=k+n1;
			k3=(int)(kkk+1)/(8-kk); 
			k5=k-k3*(naxis1-kk*n1);	
		}
	}
	
/////////////////////////////////////
/* ------------------------------- */
/* --- sortir la liste des geo --- */
/* ------------------------------- */
/////////////////////////////////////
	//il faut eliminer les bords pour une largeur de SE
	//tt_imasaver(p_out,"c:/d/geoflash/pointage5/geo2.fit",16);
	//boucle de recherche sur l'image
	for (y=y1+1;y<naxis2-y1-1;y++) {
		for (x=x1+1;x<naxis1-x1-1;x++) {
			if (p_out->p[y*naxis1+x]<=0) {	continue;}
			x0=x;
			y0=y;
			/* --- recherche du maximun local --- */	
 			somme_value=p_in->p[y*naxis1+x];
			while ((x0<naxis1)&&(y0<naxis2)&&(x0>0)&&(y0>0)) { 
				k=0;
				for (k1=-1;k1<=2;k1++) {
					for (k2=-1;k2<=2;k2++) {
						if ((y0+k1<y1+1)||(y0+k1>=naxis2-y1-1)||(x0+k2<x1+1)||(x0+k2>=naxis1-x1-1)) continue;
						if (p_in->p[(y0+k1)*naxis1+x0+k2]>somme_value) {
							somme_value=p_in->p[(y0+k1)*naxis1+x0+k2];
							x0=x0+k2;
							y0=y0+k1;
							k=1;
						}
					}
				}
				if (k==0) break;
			}
			/* ---  elimine les cosmiques  --- */
			if (((p_in->p[naxis1*(int)y0+(int)x0-1]<=pseries->bgmean+5*pseries->bgsigma)&&(p_in->p[naxis1*(int)y0+(int)x0+1]<=pseries->bgmean+5*pseries->bgsigma))||((p_in->p[naxis1*((int)y0-1)+(int)x0]<=pseries->bgmean+5*pseries->bgsigma)&&(p_in->p[naxis1*((int)y0+1)+(int)x0]<=pseries->bgmean+5*pseries->bgsigma))) {
				if (p_in->p[naxis1*(int)y0+(int)x0]>pseries->bgmean+10*pseries->bgsigma) {	break; 	}
			}

			/* --- elimine les étoiles --- */
			j=0;
			for(i=(int)x0;i<naxis1;i++) {
				if (p_in->p[naxis1*y0+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
				else if ((j==0)&&(i-x0<0.5*0.004180983*pseries->exposure/(sampling))) continue;
				else break;
			}
			for(i=(int)x0;i>=0;i--) {
				if (p_in->p[naxis1*y0+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
				else if ((j==0)&&(x0-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
				else break;
			}
			if (((y0-1)>=0)&&(j<x1)) {
				j=0;
				for(i=(int)x0;i<naxis1;i++) {
					if (p_in->p[naxis1*(y0-1)+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
					else if ((j==0)&&(i-x0<0.5*0.004180983*pseries->exposure/(sampling))) continue;
					else break;
				}
				for(i=(int)x0;i>=0;i--) {
					if (p_in->p[naxis1*(y0-1)+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
					else if ((j==0)&&(x0-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
					else break;
				}
			}
			if ((j<x1)&&((y0+1)<naxis2)) {
					j=0;
				for(i=(int)x0;i<naxis1;i++) {
					if (p_in->p[naxis1*(y0+1)+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
					else if ((j==0)&&(i-x0<0.5*0.004180983*pseries->exposure/(sampling))) continue;
					else break;
				}
				for(i=(int)x0;i>=0;i--) {
					if (p_in->p[naxis1*(y0+1)+i]>=pseries->bgmean+4*pseries->bgsigma) j++;
					else if ((j==0)&&(x0-i<0.5*0.004180983*pseries->exposure/(sampling))) continue;
					else break;
				}
			}
						
			if (j>=x1) break;
			//if (j>x1) break; // modif AK le 9/10/2011 non validee

			/* --- FWHM grossié --- */
			fwhmx=0;
			for (k=x0;k<=(naxis1-y1);k++) {
				if ((p_in->p[naxis1*y0+k]-p_in->p[naxis1*y0+k+1])<=0) break;
				if (p_in->p[naxis1*y0+k+1]<=pseries->bgmean+0.5*pseries->bgsigma) break;
				else fwhmx+=1;
			}		           
			for (k=x0;k>=1+x1;k--) {
				if ((p_in->p[naxis1*y0+k]-p_in->p[naxis1*y0+k-1])<=0) break;
				if (p_in->p[naxis1*y0+k-1]<=pseries->bgmean+0.5*pseries->bgsigma) break;
				else fwhmx+=1;
			}  					
			fwhmy=0;
           	for (k=y0;k<(naxis2-y1);k++) {
				if ((p_in->p[naxis1*k+x0]-p_in->p[naxis1*(k+1)+x0])<=0) break;
				if (p_in->p[naxis1*(k+1)+x0]<=pseries->bgmean+0.5*pseries->bgsigma) break;
				else fwhmy+=1;
			}		         
			for (k=y0;k>=1+y1;k--) {
				if ((p_in->p[naxis1*k+x0]-p_in->p[naxis1*(k-1)+x0])<=0) break;
				if (p_in->p[naxis1*(k-1)+x0]<=pseries->bgmean+0.5*pseries->bgsigma) break;
				else fwhmy+=1;
			}
		
			fwhmx/=2.;
			fwhmy/=2.;
			/* --- parametres de mesure precise ---*/
            xcc=x0;
            ycc=y0;
            fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;
			if (fwhmxy<2.) fwhmxy=2;
            r1=1.2*fwhmxy;
            r2=2.0*fwhmxy;
            r3=2.5*fwhmxy;
            r11=r1*r1;
            r22=r2*r2;
            r33=r3*r3;
            
			if (r1<5) r1=5;
			//fitte une gaussienne pour la recherche du centroide
			xx1=(int)(xcc-r1-10);
            xx2=(int)(xcc+r1+10);
            yy1=(int)(ycc-r1-6);
            yy2=(int)(ycc+r1+6);
            if (xx1<0) xx1=0;
            if (xx1>=naxis1) xx1=naxis1-1;
            if (xx2<0) xx2=0;
            if (xx2>=naxis1) xx2=naxis1-1;
            if (yy1<0) yy1=0;
            if (yy1>=naxis2) yy1=naxis2-1;
            if (yy2<0) yy2=0;
            if (yy2>=naxis2) yy2=naxis2-1;
  
			pp = (double*)calloc(6,sizeof(double));
			ecart = (double*)calloc(1,sizeof(double));
			sizex=xx2-xx1+1;
			sizey=yy2-yy1+1;
			iX = (TYPE_PIXELS*)calloc(sizex,sizeof(TYPE_PIXELS));
			dX = (double*)calloc(sizex,sizeof(double));
			iY = (TYPE_PIXELS*)calloc(sizey,sizeof(TYPE_PIXELS));
			dY = (double*)calloc(sizey,sizeof(double));	
					
			for(i=0;i<sizex;i++) *(iX+i) = (double)0.;
			for(i=0;i<sizey;i++) *(iY+i) = (double)0.;

			for(j=0;j<sizey;j++) {
			   for(i=0;i<sizex;i++) {
					pixel = p_in->p[naxis1*(j+yy1)+i+xx1];
					*(iX+i) += pixel;
					*(iY+j) += pixel;
			   }
			}

			for(i=0;i<sizex;i++) dX[i] = (double)*(iX+i);
			for(i=0;i<sizey;i++) dY[i] = (double)*(iY+i);

			tt_fitgauss1d(sizex,dX,pp,ecart);      
			xcc=pp[1]+xx1;  
			fwhmx=pp[2];
			tt_fitgauss1d(sizey,dY,pp,ecart); 
			ycc=pp[1]+yy1;
			fwhmy=pp[2];
			free(iX);
			free(dX);
			free(iY);
			free(dY);
			free(pp);
			free(ecart);

			fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;
			
			for (k=1; k<4; k++) {
				if ((fabs(xcc-x0)>=1.0*fwhmxy)||(fabs(ycc-y0)>=1.0*fwhmxy)||(ycc>=yy2)||(ycc<=yy1)||(xcc>=xx2)||(xcc<=xx1)) {//la première fenêtre semble trop grande
					xcc=x0;
					ycc=y0;
					xx1=(int)(xcc-1.2*r1/(1.2*k));
					xx2=(int)(xcc+1.2*r1/(1.2*k));
					yy1=(int)(ycc-1.2*r1/(1.2*k));
					yy2=(int)(ycc+1.2*r1/(1.2*k));
					if (xx1<0) xx1=0;
					if (xx1>=naxis1) xx1=naxis1-1;
					if (xx2<0) xx2=0;
					if (xx2>=naxis1) xx2=naxis1-1;
					if (yy1<0) yy1=0;
					if (yy1>=naxis2) yy1=naxis2-1;
					if (yy2<0) yy2=0;
					if (yy2>=naxis2) yy2=naxis2-1;

					pp = (double*)calloc(6,sizeof(double));
					ecart = (double*)calloc(1,sizeof(double));
					sizex=xx2-xx1+1;
					sizey=yy2-yy1+1;

					iX = (TYPE_PIXELS*)calloc(sizex,sizeof(TYPE_PIXELS));
					dX = (double*)calloc(sizex,sizeof(double));
					iY = (TYPE_PIXELS*)calloc(sizey,sizeof(TYPE_PIXELS));
					dY = (double*)calloc(sizey,sizeof(double));	
						
					for(i=0;i<sizex;i++) *(iX+i) = (double)0.;
					for(i=0;i<sizey;i++) *(iY+i) = (double)0.;

					for(j=0;j<sizey;j++) {
					   for(i=0;i<sizex;i++) {
							pixel = p_in->p[naxis1*(j+yy1)+i+xx1];
							*(iX+i) += pixel;
							*(iY+j) += pixel;
					   }
					}

					for(i=0;i<sizex;i++) dX[i] = (double)*(iX+i);
					for(i=0;i<sizey;i++) dY[i] = (double)*(iY+i);

					tt_fitgauss1d(sizex,dX,pp,ecart);      
					xcc=pp[1]+xx1;  
					fwhmx=pp[2];
					tt_fitgauss1d(sizey,dY,pp,ecart); 
					ycc=pp[1]+yy1;
					fwhmy=pp[2];			
					free(iX);
					free(dX);
					free(iY);
					free(dY);
					free(pp);
					free(ecart);
				} else if (((2*r1-fwhmx)<2)||((r1-fwhmy)<2)||(r1<fwhmy)||(2*r1<fwhmx)) { //la première fenêtre semble trop petite
					r1=(fwhmx>fwhmy)?1.2*fwhmx:1.2*fwhmy;
					//if (r1<10) r1=10;
					//re-fitte une gaussienne avec une fenêtre plus grande
					//fitte une gaussienne pour la recherche du centroide			
					xx1=(int)(xcc-r1-10*(1+0.1*k));
					xx2=(int)(xcc+r1+10*(1+0.1*k));
					yy1=(int)(ycc-r1-6*(1+0.1*k));
					yy2=(int)(ycc+r1+6*(1+0.1*k));
					if (xx1<0) xx1=0;
					if (xx1>=naxis1) xx1=naxis1-1;
					if (xx2<0) xx2=0;
					if (xx2>=naxis1) xx2=naxis1-1;
					if (yy1<0) yy1=0;
					if (yy1>=naxis2) yy1=naxis2-1;
					if (yy2<0) yy2=0;
					if (yy2>=naxis2) yy2=naxis2-1;

					pp = (double*)calloc(6,sizeof(double));
					ecart = (double*)calloc(1,sizeof(double));
					sizex=xx2-xx1+1;
					sizey=yy2-yy1+1;

					iX = (TYPE_PIXELS*)calloc(sizex,sizeof(TYPE_PIXELS));
					dX = (double*)calloc(sizex,sizeof(double));
					iY = (TYPE_PIXELS*)calloc(sizey,sizeof(TYPE_PIXELS));
					dY = (double*)calloc(sizey,sizeof(double));	
						
					for(i=0;i<sizex;i++) *(iX+i) = (double)0.;
					for(i=0;i<sizey;i++) *(iY+i) = (double)0.;

					for(j=0;j<sizey;j++) {
					   for(i=0;i<sizex;i++) {
							pixel = p_in->p[naxis1*(j+yy1)+i+xx1];
							*(iX+i) += pixel;
							*(iY+j) += pixel;
					   }
					}

					for(i=0;i<sizex;i++) dX[i] = (double)*(iX+i);
					for(i=0;i<sizey;i++) dY[i] = (double)*(iY+i);

					tt_fitgauss1d(sizex,dX,pp,ecart);      
					xcc=pp[1]+xx1;  
					fwhmx=pp[2];
					tt_fitgauss1d(sizey,dY,pp,ecart); 
					ycc=pp[1]+yy1;
					fwhmy=pp[2];
					free(iX);
					free(dX);
					free(iY);
					free(dY);
					free(pp);
					free(ecart);
				} else break;
			}
				
			/* elimine les bouts d'étoiles  : xcc et ycc eloignés de x et y de plus de r1 */
			if (((fabs(xcc-x0)>1.2*fwhmxy)||(fabs(ycc-y0)>1.2*fwhmxy))&&(fwhmxy>2.5)) break;
			if (((fabs(xcc-x0)>1.5*fwhmxy)||(fabs(ycc-y0)>1.5*fwhmxy))&&(fwhmxy<=2.5)) break;
			/* --- elimine les bouts d'étoiles --- */
			if ((fwhmx>5*fwhmy)&&((fwhmx>0.5)&&(fwhmy>0.5))) break;
			if ((fwhmx>4*fwhmy)&&((fwhmx>1)&&(fwhmy>1))) break;
			if ((fwhmx>3*fwhmy)&&((fwhmx>2)&&(fwhmy>2))) break;
			
			fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;
            r2=2.5*fwhmxy;	
			/* --- fond de ciel precis (fmoy,fmed,sigma) ---*/
            xx1=(int)(xcc-r3);
            xx2=(int)(xcc+r3);
            yy1=(int)(ycc-r3);
            yy2=(int)(ycc+r3);
            if (xx1<0) xx1=0;
            if (xx1>=naxis1) xx1=naxis1-1;
            if (xx2<0) xx2=0;
            if (xx2>=naxis1) xx2=naxis1-1;
            if (yy1<0) yy1=0;
            if (yy1>=naxis2) yy1=naxis2-1;
            if (yy2<0) yy2=0;
            if (yy2>=naxis2) yy2=naxis2-1;
            nb=(xx2-xx1+1)*(yy2-yy1+1);
            taille=sizeof(double);
            vec=NULL;
			if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec,&nb,&taille,"vf"))!=OK_DLL) {
               fclose(fic);
               tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_geostat (pointer vec)");
			   fclose(fic);
               return(TT_ERR_PB_MALLOC);
            }
            n23=0;
            f23=0.;
            for (j=yy1;j<=yy2;j++) {
               dy=1.*j-ycc;
               dy2=dy*dy;
               for (i=xx1;i<=xx2;i++) {
                  dx=1.*i-xcc;
                  dx2=dx*dx;
                  d2=dx2+dy2;
                  if ((d2>=r22)&&(d2<=r33)) {
	                  vec[n23]=(double)p_in->p[naxis1*j+i];
                     f23 += (double)p_in->p[naxis1*j+i];
                     n23++;
                  }
               }
            }
            tt_util_qsort_double(vec,0,n23,NULL);
            fmoy=vec[0];
            if (n23!=0) {fmoy=f23/n23;}
            /* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
            fmed=(float)vec[(int)(0.5*n23)];
            /*  calcul de l'ecart type du fond de ciel*/
            /*  en excluant les extremes a +/- 10 %*/
            sigma=0.;
            n23d=(int)(0.1*(n23-1));
            n23f=(int)(0.9*(n23-1));
            for (i=n23d;i<=n23f;i++) {
               d2=(vec[i]-fmed);
               sigma+=(d2*d2);
            }
            if ((n23f-n23d)!=0) {
               sigma=sqrt(sigma/(n23f-n23d));
            }
            free(vec);
			/* --- photometrie (flux) ---*/
            xx1=(int)(xcc-r2);
            xx2=(int)(xcc+r2);
            yy1=(int)(ycc-r2);
            yy2=(int)(ycc+r2);
            if (xx1<0) xx1=0;
            if (xx1>=naxis1) xx1=naxis1-1;
            if (xx2<0) xx2=0;
            if (xx2>=naxis1) xx2=naxis1-1;
            if (yy1<0) yy1=0;
            if (yy1>=naxis2) yy1=naxis2-1;
            if (yy2<0) yy2=0;
            if (yy2>=naxis2) yy2=naxis2-1;
            flux=0.;
            for (j=yy1;j<=yy2;j++) {
               dy=1.*j-ycc;
               dy2=dy*dy;
               for (i=xx1;i<=xx2;i++) {
                  dx=1.*i-xcc;
                  dx2=dx*dx;
                  d2=dx2+dy2;
                  dvalue=(double)p_in->p[naxis1*j+i]-fmed;
				  // mise a zero de la zone:
				  p_out->p[naxis1*j+i]=0;
                  if ((d2<=r11)) {
                     flux += dvalue;
                  }
               }
            }
            /* --- astrometrie (ra,dec) ---*/
            ra=0.;
            dec=0.;
            if (valid_ast==TT_YES) {
               tt_util_astrom_xy2radec(&p_ast,xcc,ycc,&ra,&dec);
            }
            ra*=180./(TT_PI);
            dec*=180./(TT_PI);
			if (strcmp(pseries->centroide,"gauss")==0) {
				strcpy(centro,"fittegauss");
			} else {
				strcpy(centro,"barycentre");
			}
			/* --- mise a zéro de pout pour éviter les doublons --- */
			for (k1=(int)floor(xcc-fwhmx-3);k1<(int)ceil(xcc+fwhmx+4);k1++) {
					if (k1>=naxis1) break;	
					if (k1<0) continue;
					for (k2=(int)floor(ycc-fwhmy-3);k2<(int)ceil(ycc+fwhmy+4);k2++) {
							if (k2<0) continue;
							if (k2>=naxis2) break;
							p_out->p[naxis1*(k2)+k1]=0;
					}	
			}
            /* --- sortie du resultat ---*/
			//fprintf(fic,"%d %f %f %f %f %f %f %f %f\n",nsats,xcc+1.,ycc+1.,flux,fmed,ra,dec,fwhmx,fwhmy);
			// 1 pour identifier geo par rapport à gto 2
			fprintf(fic,"%d %f %f %f %f	%f %f %f %f %f %f %f %f 1 %10s\n",nsats,xcc+1.,ycc+1.,xcc+1.,ycc+1.,flux,fmed,ra,dec,ra,dec,fwhmx,fwhmy,centro);
			nsats++;
		}
	}
	fclose(fic);

	/* --- calcul des temps ---*/
	pseries->jj_stack=pseries->jj[index-1];
	pseries->exptime_stack=pseries->exptime[index-1];

	return 0 ;
}

int tt_morphomath_1 (TT_IMA_SERIES *pseries)
/*********************************************************************************************/
/* Trait morpho math sur image dans buffer													 */
/*********************************************************************************************/
/* Entrées:												  									 */
/*			nom_trait= nom du traitement de morpho maths (ERODE, DILATE, OPEN, CLOSE,		 */
/*					OUVERTURE, OUVERTURE2, TOPHAT, TOPHATE, GRADIENT, CIEL)					 */
/*					OUVERTURE=ouverture très rapide pour des SE:ligne de longueur>150 pixels */									
/*					OUVERTURE2=ouverture très rapide pour des SE:ligne de longueur<150 pixels*/
/*					TOPHAT= chapeau haut de forme classique									 */
/*					TOPHATE= chapeau haut étendu (ouverture d'une fermeture)				 */
/*					CIEL= sort l'image du fond de ciel										 */
/*			struct_elem = forme de l'element structurant (RECTANGLE, DAIMOND, CERCLE)		 */
/*			x1 = longueur sur l'axe x de SE													 */
/*			y1 = largeur sur l'axe y de SE													 */
/*	Les résultats sont enregistrés dans deux fichiers textes palcés dans $chemin			 */														 
/*********************************************************************************************/
/*      pour le moment les SE seront de dimensions impaires pour avoir un centre centré!     */
/*********************************************************************************************/
/* ATTENTION: si le centre n'est pas centre et le SE n'est pas symmétrique,					 */
/* il faut revoir l'algo de dilation ( il faut utilisé le transposé de SE) !!				 */
/*********************************************************************************************/
//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//buf1 imaseries "MORPHOMATH nom_trait=TOPHAT struct_elem=RECTANGLE x1=10 y1=1"
//buf1 imaseries "MORPHOMATH nom_trait=$nom_Trait struct_elem=$struct_Elem x1=$dim1 y1=$dim2"
//pour le moment les SE seront de dimensions impaires pour avoir un centre centré!
// si le centre n'est pas centre et le SE n'est pas symmétrique, 

{
	TT_IMA *p_tmp1,*p_tmp2, *p_in, *p_out;
	int i,kkk,x,y,j;
	int size, nelem,naxis1,naxis2,sizex,sizey, sizex2,sizey2,size2;
	int *se = NULL,*medindice=NULL,*se2 = NULL;
	double *med =NULL,*med_val =NULL;
	double dvalue;//hicuttemp,locuttemp,sigma;
	double mode1,mini1,maxi1,mode2,mini2,maxi2,seuil;
	char *nom_trait, *struct_elem;
	int x1,y1,x2=0,y2=0,result;
	int cx,cy,xx,yy,nb_test,k_test,taille_carre_med,bitpix;
	double inf,hicut,locut,sb,sh;

	p_in=pseries->p_in; 
	p_out=pseries->p_out;
	p_tmp1=pseries->p_tmp1;
	p_tmp2=pseries->p_tmp2;
	nelem=pseries->nelements;
	x1=pseries->x1;
	y1=pseries->y1;
	nom_trait=pseries->nom_trait;
	struct_elem=pseries->struct_elem;
	
	/* --- intialisations ---*/
	naxis1=p_in->naxis1;
	naxis2=p_in->naxis2;
	nelem=naxis1*naxis2;
	bitpix=pseries->bitpix;

	/* --- calcul de la fonction ---*/
	if (p_out->naxis1==0) {
		tt_imacreater(p_out,naxis1,naxis2);
	}
	if (p_tmp1->naxis1==0) {
		tt_imacreater(p_tmp1,naxis1,naxis2);
	}
	if (p_tmp2->naxis1==0) {
		tt_imacreater(p_tmp2,naxis1,naxis2);
	}
	for (kkk=0;kkk<(int)(nelem);kkk++) {
		dvalue=(double)p_in->p[kkk];
		p_out->p[kkk]=(TT_PTYPE)(dvalue);	
		p_tmp1->p[kkk]=(TT_PTYPE)(dvalue);
		p_tmp2->p[kkk]=(TT_PTYPE)(dvalue);
	}

	if (x1%2 != 1) {
		x1=x1+1;
	}
	if (y1%2 != 1) {
		y1=y1+1;
	}

	/* ------------------------------------------- */
	/* ---- creation de l'élément structurant ---- */
	/* ------------------------------------------- */	
	if (strcmp (struct_elem,"RECTANGLE")==0) {	
		size=x1*y1;
		se=calloc(size,sizeof(int));	
		for (i=0; i<size;i++) {
			se[i]=1;
		}	
		sizex = x1;
		sizey = y1;
		
	} else if (strcmp (struct_elem,"DIAMOND")==0){
		size=x1*y1;
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=0;
		}	
		for (i=0;i<y1;i++) {	
			if (i<y1/2) {
				for (kkk=0;kkk<(2*i+1);kkk++) {
					se[i*(x1-1)+(x1-1)/2+kkk]=1;					
				}
			} else if (i== y1/2) {
				for(kkk=0;kkk<x1;kkk++) {
					se[i*x1-1+kkk]=1;
				}
			} else {
				for (kkk=0;kkk<(2*(y1-i-1)+1);kkk++) {
					se[i*x1+(x1-1)/2+kkk - i+(y1-1)/2]=1;			
				}
			}	
		}		
		sizex = x1;
		sizey = y1;
		
	} else if (strcmp (struct_elem,"CERCLE")==0) {
		// x1 =rayon du cercle
		size=(2*x1+1)*(2*x1+1);
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=0;
		}	
		for (i=0; i<(2*x1+1);i++) {
			for (j=0; j<(2*x1+1);j++) {
				if (((i-x1)*(i-x1)+(j-x1)*(j-x1))<(x1+0.5)*(x1+0.5)) {
						se[j*(2*x1+1)+i]=1;
				}
			}
		}		
		sizex = x1;
		sizey = x1;
		
	} else {
		//forme libre à donner
		//se[0] est en bas à gauche de SE

		x1=13;
		y1=1;
		size=x1*y1;
		se=calloc(size,sizeof(int));
		for (i=0; i<size;i++) {
			se[i]=1;
		}
		sizex = x1;
		sizey = y1;
	}
	
	
	/* --------------------------------------------------------- */
	/* --- appel de la fonction de traitement de morpho_math --- */
	/* --------------------------------------------------------- */
	i=strcmp (nom_trait,"DILATE");

	if (i==0) {
		if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
			if (x1<150) {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp1->p[kkk]=-p_in->p[kkk];
				}
				erosionByAnchor_1D_horizontal_courSE(p_tmp1, p_out,naxis1,naxis2,x1,bitpix);
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_out->p[kkk]=-p_out->p[kkk];
				}
			} else {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp1->p[kkk]=(65517-p_in->p[kkk])/2;
				}
				erosionByAnchor_1D_horizontal_longSE(p_tmp1, p_out,naxis1,naxis2,x1,bitpix);
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_out->p[kkk]=-p_out->p[kkk]*2+65517;
				}
			}
			
		} else {
			dilate (p_in,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);
		}
	} 

	i=strcmp (nom_trait,"ERODE");
	if (i==0) {
		if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
			if (x1<150) {
				erosionByAnchor_1D_horizontal_courSE(p_in, p_out,naxis1,naxis2,x1,bitpix);
			} else {
				erosionByAnchor_1D_horizontal_longSE(p_in, p_out,naxis1,naxis2,x1,bitpix);
			}
		} else {
			erode (p_in,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);
			//tt_imasaver(p_out,"c:/d/geoflash/pointage5/erode.fit",16);
		}
	} 
	
	i=strcmp (nom_trait,"OPEN"); // ouverture basique
	if (i==0) {
		if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
			if (x1<150) {
				openingByAnchor_1D_horizontal_courSE(p_out,naxis1,naxis2, x1,bitpix);
			} else {
				openingByAnchor_1D_horizontal_longSE(p_out,naxis1,naxis2, x1,bitpix);
			}
		} else {
			erode (p_in,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			dilate (p_tmp1,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);
		}
	} 

	i=strcmp (nom_trait,"CLOSE");
	if (i==0) {
		if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
			if (x1<150) {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp2->p[kkk]=-p_in->p[kkk];
				}
				erosionByAnchor_1D_horizontal_courSE(p_tmp2, p_tmp1,naxis1,naxis2,x1,bitpix);
			} else {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp2->p[kkk]=(65517-p_in->p[kkk])/2;
				}
				erosionByAnchor_1D_horizontal_longSE(p_tmp2, p_tmp1,naxis1,naxis2,x1,bitpix);
			}
			
			if (x1<150) {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp1->p[kkk]=-p_tmp1->p[kkk];
				}
				erosionByAnchor_1D_horizontal_courSE(p_tmp1, p_out,naxis1,naxis2,x1,bitpix);
			} else {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp1->p[kkk]=-p_tmp1->p[kkk]*2+65517;
				}
				erosionByAnchor_1D_horizontal_longSE(p_tmp1, p_out,naxis1,naxis2,x1,bitpix);
			}

		} else {
			dilate (p_in,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			erode (p_tmp1,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);
		}
	} 


	i=strcmp (nom_trait,"TOPHAT"); /* --- filtre chapeau de haut forme classique --- */
	if (i==0) {
		//ouverture de l'image initiale
		if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
			if (x1<150) {
				openingByAnchor_1D_horizontal_courSE(p_out,naxis1,naxis2, x1,bitpix);
			} else {
				openingByAnchor_1D_horizontal_longSE(p_out,naxis1,naxis2, x1,bitpix);
			}
		} else {
			erode (p_in,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			dilate (p_tmp1,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);
		}

		//réduction de la dynamique des images et calcul des seuils de visu
		tt_util_histocuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
		hicut=pseries->hicut;
		locut=pseries->locut;
		tt_util_histocuts(p_in,pseries,&(pseries->hicut),&(pseries->locut),&mode1,&mini1,&maxi1);
		tt_util_statima(p_in,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));

		for (y=0;y<naxis2;y++) {
			for (x=0;x<naxis1;x++) {
				p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x])*(float)mode1/(float)mode2;

				if (p_out->p[y*naxis1+x]<mode1-pseries->sigma) {
					p_out->p[y*naxis1+x]=0;
				} else if (p_out->p[y*naxis1+x]>mode1+(pseries->sigma)/2.0) {
					p_out->p[y*naxis1+x]=255;
				} else {
					p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./((float)(3.0/2.0*pseries->sigma));
				}

				
				if (p_in->p[y*naxis1+x]<mode1-pseries->sigma) {					
					p_tmp1->p[y*naxis1+x]=0;	
				} else if (p_in->p[y*naxis1+x]>mode1+(pseries->sigma)/2.0) {
					p_tmp1->p[y*naxis1+x]=255;
				} else {
					p_tmp1->p[y*naxis1+x]=(p_in->p[y*naxis1+x]-(float)(mode1-pseries->sigma))*(float)255./(float)(3.0/2.0*pseries->sigma);
				}
				p_out->p[y*naxis1+x]=p_tmp1->p[y*naxis1+x]-p_out->p[y*naxis1+x];		
			}
		}
	}
	
	i=strcmp (nom_trait,"TOPHATE"); /* --- extension du tophat : ouverture d'une fermeture --- */
	if (i==0) {
		// pour traiter le cas des satellites proches (compromis entre tophat excellent et détection de satellites proches)
		if (strcmp (struct_elem,"RECTANGLE")==0) {
			x2=(int)(x1/3.0);
			y2=(int)(y1/3.0);
			// garde fou sur la valeur minimum
			if (x2<2) {
				x2=2;
			}
			if (x2%2 != 1) {
				x2=x2+1;
			}
			if (y2%2 != 1) {
				y2=y2+1;
			}
			size2=x2*y2;
			if (size2==0) {size2=1;}
			se2=calloc(size2,sizeof(int));	
			for (i=0; i<size2;i++) {
					se2[i]=1;
			}	
			sizex2 = x2;
			sizey2 = y2;
		} else {
			size2=x1*y1;
			se2=calloc(size2,sizeof(int));
			for (i=0; i<size2;i++) {
				se2[i]=se[i];
			}
			sizex2 = x1;
			sizey2 = y1;
		}
		
		if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
			/* --- fermeture  --- */
			if (x1<150) {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp2->p[kkk]=-p_in->p[kkk];
				}
				erosionByAnchor_1D_horizontal_courSE(p_tmp2, p_tmp1,naxis1,naxis2,x1,bitpix);
			} else {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image spéciale pour contrer gestion des histo
					p_tmp2->p[kkk]=(65517-p_in->p[kkk])/2;
				}
				erosionByAnchor_1D_horizontal_longSE(p_tmp2, p_tmp1,naxis1,naxis2,x1,bitpix);
			}			
			if (x1<150) {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp1->p[kkk]=-p_tmp1->p[kkk];
				}
				erosionByAnchor_1D_horizontal_courSE(p_tmp1, p_out,naxis1,naxis2,x1,bitpix);
			} else {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp1->p[kkk]=-p_tmp1->p[kkk]*2+65517;
				}
				erosionByAnchor_1D_horizontal_longSE(p_tmp1, p_out,naxis1,naxis2,x1,bitpix);
			}
			/* --- ouverture --- */
			if (x1<150) {
				openingByAnchor_1D_horizontal_courSE(p_out,naxis1,naxis2, x1,bitpix);
			} else {
				openingByAnchor_1D_horizontal_longSE(p_out,naxis1,naxis2, x1,bitpix);
			}
		} else {
			/* --- fermeture  --- */
			dilate (p_in,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			erode (p_tmp1,p_tmp2,se,x1,y1,sizex,sizey,naxis1,naxis2);
			/* --- ouverture --- */
			erode (p_tmp2,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			dilate (p_tmp1,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);
		}
		
		/* --- Calcul des seuils de visualisation ---*/		
	    // pour l'image du tophat
		tt_util_statima(p_out,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));	
		tt_util_bgk(p_out,&(pseries->bgmean),&(pseries->bgsigma));
		tt_util_cuts(p_out,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);
		hicut=pseries->hicut;
		locut=pseries->locut;
		mode2=pseries->bgmean;
		// pour l'image initiale
		tt_util_statima(p_in,pseries->pixelsat_value,&(pseries->mean),&(pseries->sigma),&(pseries->mini),&(pseries->maxi),&(pseries->nbpixsat));
		tt_util_bgk(p_in,&(pseries->bgmean),&(pseries->bgsigma));
		tt_util_cuts(p_in,pseries,&(pseries->hicut),&(pseries->locut),TT_YES);
		mode1=pseries->bgmean;

		//tt_imasaver(p_out,"c:/d/geoflash/pointage5/ouv_de_ferm.fit",16);
		/* --- detection des geo et des traînées du bruit --- */
		/* --- réduction de la dynamique des images --- */
		if ((4+(pseries->hicut-pseries->locut)/100)<8) {
			seuil=(4+(pseries->hicut-pseries->locut)/100)*pseries->bgsigma;	
		} else {
			seuil=8*pseries->bgsigma;
		}
		sh=8*pseries->bgsigma;
		sb=-pseries->bgsigma;

		for (y=0;y<naxis2;y++) {
			for (x=0;x<naxis1;x++) {
				if (mode1>mode2) p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x])*(float)mode1/(float)mode2;					
				if ((fabs (p_out->p[y*naxis1+x]-p_in->p[y*naxis1+x])<seuil)||(p_out->p[y*naxis1+x]>p_in->p[y*naxis1+x])) {
					p_tmp1->p[y*naxis1+x]=p_out->p[y*naxis1+x];
				} else if (x>naxis1-x1-1) {// gestion du bord droit de l'image après traitement morpho maths
					p_tmp1->p[y*naxis1+x]=p_out->p[y*naxis1+x];
				} else {
					if (p_out->p[y*naxis1+x]<mode1-sb) {
						p_out->p[y*naxis1+x]=0;
					} else if (p_out->p[y*naxis1+x]>mode1+sh) {
						p_out->p[y*naxis1+x]=255;
					} else {
						if (p_out->p[y*naxis1+x]<mode1) {
							if (pseries->locut/locut<1) {
								p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-sb))*(float)255./((float)(sb+sh))*(float)(pseries->locut/locut);
							} else {
								p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-sb))*(float)255./((float)(sb+sh))*(float)(locut/pseries->locut);
							}
						} else if (p_out->p[y*naxis1+x]>mode1) {
							if (pseries->hicut/hicut>1) {
								p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-sb))*(float)255./((float)(sb+sh))*(float)(pseries->hicut/hicut);
							} else {
								p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-sb))*(float)255./((float)(sb+sh))*(float)(hicut/pseries->hicut);
							}
						} else {
							p_out->p[y*naxis1+x]=(p_out->p[y*naxis1+x]-(float)(mode1-sb))*(float)255./((float)(sb+sh));
						}
					}

					if (p_in->p[y*naxis1+x]<mode1-sb) {					
						p_tmp1->p[y*naxis1+x]=0;	
					} else if (p_in->p[y*naxis1+x]>mode1+sh) {
						p_tmp1->p[y*naxis1+x]=255;
					} else {
						p_tmp1->p[y*naxis1+x]=(p_in->p[y*naxis1+x]-(float)(mode1-sb))*(float)255./(float)(sb+sh);
					}
				}
				p_out->p[y*naxis1+x]=p_tmp1->p[y*naxis1+x]-p_out->p[y*naxis1+x];
				if (p_out->p[y*naxis1+x]<0) p_out->p[y*naxis1+x]=0;	
			}
		}
		//tt_imasaver(p_out,"c:/d/geoflash/pointage5/ouv_ferm_seuill.fit",16);
		//tt_imasaver(p_tmp2,"c:/d/geoflash/pointage5/init2.fit",8);
		//tt_imasaver(p_out,"c:/d/geoflash/pointage5/tophat.fit",8);
	} 

	i=strcmp (nom_trait,"GRADIENT");
	if (i==0) {
		if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
			/* --- erosion --- */
			if (x1<150) {
				erosionByAnchor_1D_horizontal_courSE(p_in, p_tmp1,naxis1,naxis2,x1,bitpix);
			} else {
				erosionByAnchor_1D_horizontal_longSE(p_in, p_tmp1,naxis1,naxis2,x1,bitpix);
			}
			/* --- dilation --- */
			if (x1<150) {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp2->p[kkk]=-p_in->p[kkk];
				}
				erosionByAnchor_1D_horizontal_courSE(p_tmp2, p_out,naxis1,naxis2,x1,bitpix);
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_out->p[kkk]=-p_out->p[kkk];
				}
			} else {
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_tmp2->p[kkk]=(65517-p_in->p[kkk])/2;
				}
				erosionByAnchor_1D_horizontal_longSE(p_tmp2, p_out,naxis1,naxis2,x1,bitpix);
				for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
					p_out->p[kkk]=-p_out->p[kkk]*2+65517;
				}
			}
			
		} else {
			erode (p_in,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			dilate (p_in,p_out,se,x1,y1,sizex,sizey,naxis1,naxis2);
		}
		for (y=0;y<naxis2;y++) {
			for (x=0;x<naxis1;x++) {
				p_out->p[y*naxis1+x]=(float)0.5*(p_out->p[y*naxis1+x]-p_tmp1->p[y*naxis1+x]);
			}
		}
	}

	i=strcmp (nom_trait,"CIEL"); /* --- médiane sous condition pour faire une carte du fond de ciel --- */
	if (i==0) {
		//defini le nombre de fois que l'image subit ce traitement
		nb_test=3;
		//calcul du gradient morpho
		for (k_test=1;k_test<=nb_test;k_test++) {
			if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
				/* --- erosion --- */
				if (x1<150) {
					erosionByAnchor_1D_horizontal_courSE(p_in, p_tmp2,naxis1,naxis2,x1,bitpix);
				} else {
					erosionByAnchor_1D_horizontal_longSE(p_in, p_tmp2,naxis1,naxis2,x1,bitpix);
				}
				/* --- dilation --- */	
				if (x1<150) {
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_in->p[kkk]=-p_in->p[kkk];
					}
					erosionByAnchor_1D_horizontal_courSE(p_in, p_tmp1,naxis1,naxis2,x1,bitpix);
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_tmp1->p[kkk]=-p_tmp1->p[kkk];
						p_in->p[kkk]=-p_in->p[kkk];
					}
				} else {
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_in->p[kkk]=(65517-p_in->p[kkk])/2;
					}
					erosionByAnchor_1D_horizontal_longSE(p_in, p_tmp1,naxis1,naxis2,x1,bitpix);
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_tmp1->p[kkk]=-p_tmp1->p[kkk]*2+65517;
						p_in->p[kkk]=-p_in->p[kkk]*2+65517;
					}
				}
				
			} else {
				erode (p_in,p_tmp2,se,x1,y1,sizex,sizey,naxis1,naxis2);
				dilate (p_in,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			}
			for (y=0;y<naxis2;y++) {
				for (x=0;x<naxis1;x++) {
					p_tmp1->p[y*naxis1+x]=(float)0.5*(p_tmp1->p[y*naxis1+x]-p_tmp2->p[y*naxis1+x]);
				}
			}
			tt_util_histocuts(p_tmp1,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
			seuil =(pseries->hicut)*0.4;
			//tt_util_histocuts(p_in,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
			//tt_imasaver(p_tmp1,"c:/d/geoflash/pointage5/gradient.fit",16);	

			//erosion par la médiane si gradient supérieur à seuil
			// définition du centre de l'élément structurant
			// SE est au milieu du rectangle sizex*sizey
			sizex2=3;
			sizey2=90;
			cx=(sizex2-1)/2;
			cy=(sizey2-1)/2;
			size=sizex2*sizey2;
			med=calloc(size,sizeof(double));
			for (i=0; i<size;i++) {
				med[i]=1;
			}
			//on commence par le coin en bas à gauche de l'image p_out [0][0]
			for (y=cy;y<(naxis2-cy-1);y++) {
				for (x=cx;x<(naxis1-cx);x++) {
					if (p_tmp1->p[y*naxis1+x]<seuil) {continue;}
					/* --- boucle dans la boite englobant le SE --- */
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=-cx;xx<(sizex2-cx);xx++) {	
							med[i]=p_in->p[(yy+y)*naxis1+xx+x];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			//pour les pixel a droite de l'image
			for (y=cy;y<(naxis2-cy-1);y++) {
				for (x=naxis1-cx;x<naxis1;x++) {

					if (p_tmp1->p[y*naxis1+x]<seuil*0.4) {continue;}
					/* --- boucle dans la boite englobant le SE --- */
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=(1-sizex2);xx<=0;xx++) {	
							med[i]=p_in->p[(yy+y)*naxis1+xx+x-cx];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			//pour les pixel a gauche de l'image
			for (y=cy;y<(naxis2-cy-1);y++) {
				for (x=0;x<cx;x++) {

					if (p_tmp1->p[y*naxis1+x]<seuil*0.4) {continue;}
					/* --- boucle dans la boite englobant le SE --- */
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=x;xx<x+sizex2;xx++) {	
							med[i]=p_in->p[(yy+y)*naxis1+xx+x+cx];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			//pour les pixel en bas de l'image
			for (y=0;y<cy;y++) {
				for (x=cx;x<(naxis1-cx);x++) {
					if (p_tmp1->p[y*naxis1+x]<seuil*0.4) {continue;}
					/* --- boucle dans la boite englobant le SE --- */
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=(1-sizex2);xx<=0;xx++) {	
							med[i]=p_in->p[(yy+y+cy)*naxis1+xx+x];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			//pour les pixel en haut de l'image
			for (y=(naxis2-cy-1);y<naxis2;y++) {
				for (x=cx;x<(naxis1-cx);x++) {
					if (p_tmp1->p[y*naxis1+x]<seuil*0.4) {continue;}
					/* --- boucle dans la boite englobant le SE --- */
					i=0;
					for (yy=-cy;yy<(sizey2-cy);yy++) {
						for (xx=x;xx<x+sizex2;xx++) {	
							med[i]=p_in->p[(yy+y-cy)*naxis1+xx+x];
							i++;
						}
					}
					tt_util_qsort_double(med,0,i,medindice);
					inf=med[(int)(size/2)];
					p_out->p[y*naxis1+x]=(TT_PTYPE)(inf);
					if (inf<pseries->locut*1.005) {
						p_out->p[y*naxis1+x]=(float)(pseries->locut*1.005);
					}
				}
			}
			
			free(medindice);
			free(med);
			if (nb_test>k_test) {
				for (y=0;y<naxis2;y++) {
					for (x=0;x<naxis1;x++) {
						p_in->p[y*naxis1+x]=p_out->p[y*naxis1+x];
					}	
				}
			}
		}
	}
	i=strcmp (nom_trait,"CIEL2");/* --- médiane sous condition pour faire une carte du fond de ciel --- */
	if (i==0) {
		//defini le nombre de fois que l'image subit ce traitement
		nb_test=1;
		taille_carre_med= 64;	
		/* --- calcul du gradient morpho --- */
		for (k_test=1;k_test<=nb_test;k_test++) {
			if ((strcmp (struct_elem,"RECTANGLE")==0)&&(y1==1)) {
				/* --- erosion --- */
				if (x1<150) {
					erosionByAnchor_1D_horizontal_courSE(p_in, p_tmp2,naxis1,naxis2,x1,bitpix);
				} else {
					erosionByAnchor_1D_horizontal_longSE(p_in, p_tmp2,naxis1,naxis2,x1,bitpix);
				}
				/* --- dilation --- */
				
				if (x1<150) {
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_in->p[kkk]=-p_in->p[kkk];
					}
					erosionByAnchor_1D_horizontal_courSE(p_in, p_tmp1,naxis1,naxis2,x1,bitpix);
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_tmp1->p[kkk]=-p_tmp1->p[kkk];
						p_in->p[kkk]=-p_in->p[kkk];
					}
				} else {
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_in->p[kkk]=(65517-p_in->p[kkk])/2;
					}
					erosionByAnchor_1D_horizontal_longSE(p_in, p_tmp1,naxis1,naxis2,x1,bitpix);
					for (kkk=0;kkk<(int)(nelem);kkk++) {//inversion de l'image
						p_tmp1->p[kkk]=-p_tmp1->p[kkk]*2+65517;
						p_in->p[kkk]=-p_in->p[kkk]*2+65517;
					}
				}	
			} else {
				erode (p_in,p_tmp2,se,x1,y1,sizex,sizey,naxis1,naxis2);
				dilate (p_in,p_tmp1,se,x1,y1,sizex,sizey,naxis1,naxis2);
			}
			for (y=0;y<naxis2;y++) {
				for (x=0;x<naxis1;x++) {
					p_tmp1->p[y*naxis1+x]=(float)0.5*(p_tmp1->p[y*naxis1+x]-p_tmp2->p[y*naxis1+x]);
				}
			}
			tt_util_histocuts(p_tmp1,pseries,&(pseries->hicut),&(pseries->locut),&mode2,&mini2,&maxi2);
			//tt_imasaver(p_tmp1,"c:/d/geoflash/pointage5/gradient.fit",16);	

			seuil =(pseries->hicut+mode2)/2.0;

			/* --- calcul d'une image reduite de valeur de médiane de l'image initiale --- */
			//size=(naxis1/taille_carre_med)*(naxis2/taille_carre_med)+(naxis1/taille_carre_med-1)*(naxis2/taille_carre_med-1);
			size=(naxis1/taille_carre_med)*(naxis2/taille_carre_med);
			med=calloc(size,sizeof(double));
			for (i=0; i<size;i++) {
				med[i]=1;
			}
			med_val=calloc(taille_carre_med*taille_carre_med,sizeof(double));
			for (i=0; i<taille_carre_med*taille_carre_med;i++) {
				med_val[i]=1;
			}
			j=0;
			for (y=0;y<naxis2;y=y+taille_carre_med) {
				for (x=0;x<naxis1;x=x+taille_carre_med) {
					i=0;
					for (yy=0;yy<taille_carre_med;yy++) {
						for (xx=0;xx<taille_carre_med;xx++) {	
							med_val[i++]=p_in->p[(yy+y)*naxis1+xx+x];
						}
					}
					tt_util_qsort_double(med_val,0,i,medindice);
					med[j++]=med_val[(int)(taille_carre_med*taille_carre_med/2.0)];
				}
			}
			
			/* --- boucle sur l'image --- */
			for (y=0;y<naxis2;y++) {
				for (x=0;x<naxis1;x++) {
					if (p_tmp1->p[y*naxis1+x]<seuil) {continue;}
					else {
						kkk=((int)floor(1.*y/taille_carre_med))*naxis1/taille_carre_med+((int)floor(1.*x/taille_carre_med));
						p_out->p[y*naxis1+x]=(float)med[kkk];
					}
				}
			}
			//tt_imasaver(p_out,"c:/d/geoflash/pointage5/ima_morphomaths.fit",16);	
			free(medindice);
			free(med);
			if (nb_test>k_test) {
				for (y=0;y<naxis2;y++) {
					for (x=0;x<naxis1;x++) {
						p_in->p[y*naxis1+x]=p_out->p[y*naxis1+x];
					}	
				}
			}
		}
	}
	//tt_imasaver(p_out,"c:/d/geoflash/pointage5/ima_morphomaths.fit",16);	
	free(se);
	result=0;
	return result;
}


void dilate (TT_IMA* pin,TT_IMA* pout,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2)
/*********************************************************************************************/
/* Trait morpho math : algo de dilation classique: recherche du max dans SE					 */
/*********************************************************************************************/
{	
	int cx,cy,x,y,xx,yy;
	double sup;

	// définition du centre de l'élément structurant
	// SE est au milieu du rectangle sizex*sizey
	cx=(sizex-1)/2;
	cy=(sizey-1)/2;

	//on commence par le coin en bas à gauche de l'image p_out [0][0]
	for (y=cy;y<(naxis2-cy);y++) {
		for (x=cx;x<(naxis1-cx);x++) {
			sup=pin->p[y*naxis1+x];
			/* --- boucle dans la boite englobant le SE --- */
			for (yy=0;yy<sizey;yy++) {
				for (xx=0;xx<sizex;xx++) {					
					if ((se[(yy)*dim1+xx]==1)&&(pin->p[(yy+y-cy)*naxis1+xx+x-cx]>sup)) {// si le pixel appartient a SE
						sup=pin->p[(yy+y-cy)*naxis1+xx+x-cx];
					}
				}
			}
			pout->p[y*naxis1+x]=(TT_PTYPE)(sup);
		}
	}			
}


void erode (TT_IMA* pin,TT_IMA* pout,int* se,int dim1,int dim2,int sizex,int sizey,int naxis1,int naxis2)
/*********************************************************************************************/
/* Trait morpho math : algo d'érosion classique: recherche du min dans SE					 */
/*********************************************************************************************/
{
	int cx,cy,x,y,xx,yy;
	double inf;

	// définition du centre de l'élément structurant
	// SE est au milieu du rectangle sizex*sizey
	cx=(sizex-1)/2;
	cy=(sizey-1)/2;
	
	//on commence par le coin en bas à gauche de l'image p_out [0][0]
	for (y=cy;y<(naxis2-cy);y++) {
		for (x=cx;x<(naxis1-cx);x++) {
			inf=pin->p[y*naxis1+x];
			//boucle dans la boite englobant le SE
			for (yy=0;yy<sizey;yy++) {
				for (xx=0;xx<sizex;xx++) {					
					if ((se[(yy)*dim1+xx]==1)&&(pin->p[(yy+y-cy)*naxis1+xx+x-cx]<inf)) {// si le pixel appartient a SE
						inf=pin->p[(yy+y-cy)*naxis1+xx+x-cx];
					}
				}
			}
			pout->p[y*naxis1+x]=(TT_PTYPE)(inf);
		}
	}
}

int erosionByAnchor_1D_horizontal_courSE(TT_IMA* pin, TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix)
/*********************************************************************************************/
/* Trait morpho math : algo d'erosion optimisé pour SE ligne < 150 pixels					 */
/*********************************************************************************************/
/*     ATTENTION: ALGO VALABLE QUE POUR SE=LIGNE et Images codées en 16 bits				 */
/*********************************************************************************************/
/*						 algo de VAN DROOGENBROECK											 */
/*			réf: Morphological Erosions and Opening: Fast Algorithms Based on Anchors.       */
/*						Journal of Mathematical Imaging and Vision,2005						 */
/*					très rapide pour des petits SE: ligne < 150 pixels					     */
/*********************************************************************************************/

//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//buf1 imaseries "MORPHOMATH nom_trait=ERODE struct_elem=RECTANGLE x1=10 y1=1"
//buf1 save "c:/d/geoflash/pointage5/ouverture2.fit"
{
	long inLeft,inRight,outLeft,outRight,current,sentinel; 
	double min;
	int i,j,imageWidthMinus1,sizeMinus1;
	double *histo;
	int	middle;

	imageWidthMinus1 = imageWidth-1;
	sizeMinus1 = size-1;
	middle = size/2;

	/* Initialisation of the histogram */
	histo=calloc(size,sizeof(double));

	/* Row by row */
	for (j=0; j<imageHeight-1; j++){
		/* Initialisation of both extremities of a line */
		inLeft = (j*imageWidth);
		outLeft = (j*imageWidth);
		inRight = inLeft+imageWidthMinus1;
		outRight = outLeft+imageWidthMinus1;

		/* Handles the left border */ 
		/* First half of the structuring element */
		for (i=0; i<size;i++) {
			histo[i]=0;
		}	
		min = (double)pin->p[inLeft];
		for (i=0; i<middle; i++) {
			inLeft++; 
			histo[i]=(double)(pin->p[inLeft]);
			if (pin->p[inLeft] < min) { min = (double)(pin->p[inLeft]); }
		}
		pout->p[outLeft] =(TT_PTYPE) min;

		/* Second half of the structuring element */
		for (i=middle; i<size; i++) {
			inLeft++; outLeft++;
			histo[i]=(double)(pin->p[inLeft]);
			if (pin->p[inLeft] < min) { min = (double)pin->p[inLeft]; }
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* Use the histogram as long as we have not found a new minimum */
		while ((inLeft<inRight) && (min<=(int)pin->p[inLeft+1])) {
			inLeft++; outLeft++;
			histo[size-1]=(double)(pin->p[inLeft]);
			min = (double)histo[size-1];
			for (i=0; i<size-1; i++) {
				histo[i]=histo[i+1];
				if (histo[i]<min) {// finds and allocates the minimum
					min = histo[i];
				}
			}
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* Enters in the loop */
		min = (int)pin->p[outLeft];

startLine:
		current = inLeft+1;
		while ((current<inRight) && (pin->p[current]<=min)) { 
			min=(double)pin->p[current]; 
			outLeft++; 
			pout->p[outLeft]=(TT_PTYPE)min; 
			current++; 
		}
		inLeft = current-1;
		sentinel = inLeft+size;
		if (sentinel>inRight) { goto finishLine; }
		outLeft++;
		pout->p[outLeft] = (TT_PTYPE)min;

		/* We ran "size" pixels ahead */ 
		current++; 
		while (current<sentinel) {
			if (pin->p[current]<=min) /* We have found a new minimum */
			{
				min = (double)pin->p[current];
				outLeft++; 
				pout->p[outLeft] =(TT_PTYPE) min;
				inLeft = current;
				goto startLine; 
			}
			current++; 
			outLeft++; 
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* We did not find a smaller value in the segment in reach
		* of inLeft; current is the first position outside the 
		* reach of inLeft 
		*/
		if (pin->p[current]<=min) {
			min =(double) pin->p[current];
			outLeft++; 
			pout->p[outLeft] =(TT_PTYPE) min;
			inLeft = current;
			goto startLine; 
		} else	/* We can not avoid computing the histogram */
		{
			//if (inLeft+size>=inRight) { goto finishLine; }

			for (i=0; i<size;i++) {
				histo[i]=0;
			}	
			inLeft++; outLeft++; 
			for (i=0; i<size; i++) { 
				histo[i]=(double)pin->p[inLeft+i]; 
			}
			min = (double)histo[0];
			for (i=0; i<size; i++) {
				if (histo[i]<min) {// finds and allocates the minimum
					min = histo[i];
				}
			}
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* We just follow the pixels, update the histogram and look for
		* the minimum */
		while (current < inRight)  
		{ 
			current++; 
			if (pin->p[current] <= min)
			{
				/* We have found a new mimum */
				min = (double)pin->p[current];
				outLeft++; 
				pout->p[outLeft] =(TT_PTYPE) min;
				inLeft = current;
				goto startLine; 
			} else {
				inLeft++; outLeft++; 
				/* Update the histogram */
				for (i=0; i<size; i++) { 
					histo[i]=(double)pin->p[inLeft+i]; 
				}
				min = (double)histo[0];
				/* Recompute the minimum */
				for (i=0; i<size; i++) {
					if (histo[i]<min) {// finds and allocates the minimum
						min = histo[i];
					}
				}
				pout->p[outLeft]=(TT_PTYPE)min; 
			}
		}

finishLine:
		/* Handles the right border */ 
		/* First half of the structuring element */
		for (i=0; i<size;i++) {
			histo[i]=0;
		}	
		min = (double)pin->p[inRight]; 
		for (i=0; i<middle; i++) {
			inRight--; 
			histo[i]=(double)pin->p[inRight];
			if (pin->p[inRight] < min) { min = (double)pin->p[inRight]; }
		}
		pout->p[outRight] =(TT_PTYPE) min;

		/* Second half of the structuring element */
		for (i=middle; (i<size) && (outLeft<outRight); i++) {
			inRight--; outRight--;
			histo[i]=(double)pin->p[inRight];
			if (pin->p[inRight] < min) { min =(double) pin->p[inRight]; }
			pout->p[outRight] = (TT_PTYPE)min;
		}

		/* Use the histogram as long as we have not found a new minimum */
		while ( outLeft<outRight ) {
			inRight--; outRight--;
			
			if (pin->p[inRight] < min) { min = (double)pin->p[inRight]; }
			min = (double)histo[0];
			for (i=0; i<size; i++) {
				if (histo[i]<min) {// finds and allocates the minimum
					min = histo[i];
				}
			}
			pout->p[outRight] = (TT_PTYPE)min;
		}
    }

  /* Free memory */
  free(histo);

  return 0;
}

int erosionByAnchor_1D_horizontal_longSE(TT_IMA* pin, TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix)
/*********************************************************************************************/
/* Trait morpho math : algo d'erosion optimisé pour SE ligne > 150 pixels					 */
/*********************************************************************************************/
/*     ATTENTION: ALGO VALABLE QUE POUR SE=LIGNE et Images codées en 16 bits				 */
/*********************************************************************************************/
/*						 algo de VAN DROOGENBROECK											 */
/*			réf: Morphological Erosions and Opening: Fast Algorithms Based on Anchors.       */
/*						Journal of Mathematical Imaging and Vision,2005						 */
/*					très rapide pour des très gros SE: ligne > 150 pixels					 */
/*********************************************************************************************/

//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//buf1 imaseries "MORPHOMATH nom_trait=ERODE struct_elem=RECTANGLE x1=160 y1=1"
//buf1 save "c:/d/geoflash/pointage5/ouverture2.fit"
{
	int aux;
	long inLeft,inRight,outLeft,outRight,current,sentinel,nbrBytes; 
	int min;
	int i,j,imageWidthMinus1,sizeMinus1;
	double *histo;
	int	middle;

	imageWidthMinus1 = imageWidth-1;
	sizeMinus1 = size-1;
	middle = size/2;

	/* Initialisation of the histogram */
	if (bitpix==0) {bitpix=16;}
	nbrBytes =(long) pow(2,bitpix)*sizeof(double);
	histo = (double *)malloc(nbrBytes);

	/* Row by row */
	for (j=0; j<imageHeight-1; j++){
		/* Initialisation of both extremities of a line */
		inLeft = (j*imageWidth);
		outLeft = (j*imageWidth);
		inRight = inLeft+imageWidthMinus1;
		outRight = outLeft+imageWidthMinus1;

		/* Handles the left border */ 
		/* First half of the structuring element */
		memset(histo, 0, nbrBytes);
		min = (int)pin->p[inLeft]; histo[min]++;
		for (i=0; i<middle; i++) {
			inLeft++; 
			histo[(int)(pin->p[inLeft])]++;
			if (pin->p[inLeft] < min) { min = (int)(pin->p[inLeft]); }
		}
		pout->p[outLeft] =(TT_PTYPE) min;

		/* Second half of the structuring element */
		for (i=0; i<size-middle-1; i++) {
			inLeft++; outLeft++;
			histo[(int)(pin->p[inLeft])]++;
			if (pin->p[inLeft] < min) { min = (int)pin->p[inLeft]; }
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* Use the histogram as long as we have not found a new minimum */
		while ( (inLeft<inRight) && (min<=(int)pin->p[inLeft+1])) {
			inLeft++; outLeft++;
			histo[(int)(pin->p[inLeft-size])]--;
			histo[(int)(pin->p[inLeft])]++;
			while (histo[min]<=0) { min++; }
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* Enters in the loop */
		min = (int)pin->p[outLeft];

startLine:
		current = inLeft+1;
		while ((current<inRight) && (pin->p[current]<=min)) { 
			min=(int)pin->p[current]; outLeft++; pout->p[outLeft]=(TT_PTYPE)min; current++; 
		}
		inLeft = current-1;
		sentinel = inLeft+size;
		if (sentinel>inRight) { goto finishLine; }
		outLeft++;
		pout->p[outLeft] = (TT_PTYPE)min;

		/* We ran "size" pixels ahead */ 
		current++; 
		while (current<sentinel) {
			if (pin->p[current]<=min) /* We have found a new minimum */
			{
				min = (int)pin->p[current];
				outLeft++; 
				pout->p[outLeft] =(TT_PTYPE) min;
				inLeft = current;
				goto startLine; 
			}
			current++; 
			outLeft++; 
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* We did not find a smaller value in the segment in reach
		* of inLeft; current is the first position outside the 
		* reach of inLeft 
		*/
		if (pin->p[current]<=min) {
			min =(int) pin->p[current];
			outLeft++; 
			pout->p[outLeft] =(TT_PTYPE) min;
			inLeft = current;
			goto startLine; 
		} else	/* We can not avoid computing the histogram */
		{
			memset(histo, 0, nbrBytes);
			inLeft++; outLeft++; 
			for (aux=inLeft; aux<=current; aux++) { histo[(int)pin->p[aux]]++; }
			min++; while (histo[min]<=0) { min++; }
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* We just follow the pixels, update the histogram and look for
		* the minimum */
		while (current < inRight)  
		{ 
			current++; 
			if (pin->p[current] <= min)
			{
				/* We have found a new mimum */
				min = (int)pin->p[current];
				outLeft++; 
				pout->p[outLeft] =(TT_PTYPE) min;
				inLeft = current;
				goto startLine; 
			} else {
				/* Update the histogram */
				histo[(int)pin->p[current]]++;
				histo[(int)pin->p[inLeft]]--;
				/* Recompute the minimum */
				while (histo[min]<=0) { min++; }
				inLeft++; outLeft++; 
				pout->p[outLeft]=(TT_PTYPE)min; 
			}
		}

finishLine:
		/* Handles the right border */ 
		/* First half of the structuring element */
		memset(histo, 0, nbrBytes);
		min = (int)pin->p[inRight]; histo[min]++;
		for (i=0; i<middle; i++) {
			inRight--; 
			histo[(int)pin->p[inRight]]++;
			if (pin->p[inRight] < min) { min = (int)pin->p[inRight]; }
		}
		pout->p[outRight] =(TT_PTYPE) min;

		/* Second half of the structuring element */
		for (i=0; (i<size-middle-1) && (outLeft<outRight); i++) {
			inRight--; outRight--;
			histo[(int)pin->p[inRight]]++;
			if (pin->p[inRight] < min) { min =(int) pin->p[inRight]; }
			pout->p[outRight] = (TT_PTYPE)min;
		}

		/* Use the histogram as long as we have not found a new minimum */
		while ( outLeft<outRight ) {
			inRight--; outRight--;
			histo[(int)pin->p[(inRight+size)]]--;
			histo[(int)pin->p[inRight]]++;
			if (pin->p[inRight] < min) { min = (int)pin->p[inRight]; }
			while (histo[min]<=0) { min++; }
			pout->p[outRight] = (TT_PTYPE)min;
		}
    }

  /* Free memory */
  free(histo);

  return 0;
}


int openingByAnchor_1D_horizontal_courSE(TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix)
/*********************************************************************************************/
/* Trait morpho math : algo d'ouverture optimisé pour SE ligne < 150 pixels					 */
/*********************************************************************************************/
/*     ATTENTION: ALGO VALABLE QUE POUR SE=LIGNE											 */
/*********************************************************************************************/
/*						 algo de VAN DROOGENBROECK											 */
/*			réf: Morphological Erosions and Opening: Fast Algorithms Based on Anchors.       */
/*						Journal of Mathematical Imaging and Vision,2005						 */
/*					très rapide pour des petits SE: ligne < 150 pixels						 */
/*********************************************************************************************/
/*********************************************************************************************/
/*								ATTENTION: IL FAUT POUT=PIN!!								 */
/*********************************************************************************************/
//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//buf1 imaseries "MORPHOMATH nom_trait=OUVERTURE struct_elem=RECTANGLE x1=10 y1=1"
//buf1 save "c:/d/geoflash/pointage5/toqjd.fit"
{
	int i,end;
	long outLeft,outRight,current,sentinel; 
	int min;
	int j,imageWidthMinus1,sizeMinus1;
	double *histo;


	imageWidthMinus1 = imageWidth-1;
	sizeMinus1 = size-1;

	/* Initialisation of the histogram */
	histo=calloc(size,sizeof(double));	

	/* Row by row */
	for (j=0; j<imageHeight-1; j++) {
		/* Initialisation of both extremities of a line */
		outLeft = (j*imageWidth);
		outRight = outLeft+imageWidthMinus1;

		/* Handling of both sides */
		/* Left side */
		while ( (outLeft < outRight) && (pout->p[outLeft] >= pout->p[outLeft+1]) )
		{ outLeft++; }

		/* Right side */
		/*while ( (outLeft < outRight) && (pout->p[outRight-1] <= pout->p[outRight]) )
		{ outRight--; }*/

		/* Enters in the loop */
		startLine:
		min =(int) pout->p[outLeft];
		current = outLeft+1;
		while ((current<outRight) && (pout->p[current]<=min))
		{ min=(int)pout->p[current]; outLeft++; current++; }
		sentinel = outLeft+size;
		if (sentinel>outRight) { goto finishLine; }

		/* We ran "size" pixels ahead */ 
		current++; 
		while (current<sentinel) {
			if (pout->p[current]<=min) { /* We have found a new minimum */
				end = current;
				outLeft++; 
				while (outLeft < end) {pout->p[outLeft]=(TT_PTYPE)min; outLeft++;}
				outLeft = current; 
				goto startLine; 
			}
			current++; 
		}

		/* We did not find a smaller value in the segment in reach
		* of outLeft; current is the first position outside the 
		* reach of outLeft 
		*/
		if (pout->p[current]<=min) {
			end = current;
			outLeft++; 
			while (outLeft < end) { pout->p[outLeft]=(TT_PTYPE)min; outLeft++; }
			outLeft = current;
			goto startLine; 
		} else	/* We can not avoid computing the histogram */
		{
			for (i=0; i<size;i++) {
				histo[i]=0;
			}	
			outLeft++; 
			for (i=0; i<size; i++) { 
				histo[i]=(double)pout->p[outLeft+i]; 
			}
			min = (int)histo[0];
			for (i=0; i<size; i++) {
				if (histo[i]<min) {// finds and allocates the minimum
					min =(int) histo[i];
				}
			}
			pout->p[outLeft] = (TT_PTYPE)min;
		}

		/* We just follow the pixels, update the histogram and look for
		* the minimum */
		while (current < outRight)  { 
			current++; 
			if (pout->p[current] <= min) {
				/* We have found a new mimum */
				end = current;
				outLeft++; 
				while (outLeft < end) { pout->p[outLeft]=(TT_PTYPE)min; outLeft++; 	}
				outLeft = current; 
				goto startLine; 
			} else {
				outLeft++; 
				/* Update the histogram */
				for (i=0; i<size; i++) { 
					histo[i]=(double)pout->p[outLeft+i]; 
				}
				min = (int)histo[0];
				/* Recompute the minimum */
				for (i=0; i<size; i++) {
					if (histo[i]<min) {// finds and allocates the minimum
						min = (int)histo[i];
					}
				}
				pout->p[outLeft]=(TT_PTYPE)min; 
			}
		}

		/* We have to finish the line */
		while (outLeft < outRight) {
			for (i=0; i<size; i++) { 
					histo[i]=(double)pout->p[outLeft+i]; 
			}
			for (i=0; i<size; i++) {
				if (histo[i]<min) {// finds and allocates the minimum
					min =(int) histo[i];
				}
			}
			outLeft++; 		
			pout->p[outLeft]=(TT_PTYPE)min; 
		}

		finishLine:
		while (outLeft < outRight){
			if (pout->p[outLeft]<=pout->p[outRight]) {
				min=(int)pout->p[outRight]; outRight--; 
				if (pout->p[outRight]>min) 	{ pout->p[outRight]=(TT_PTYPE)min;}
			} else {
				min=(int)pout->p[outLeft]; outLeft++; 
			}
		}
	}

	/* Free memory */
	free(histo);
	return 0;
}


int openingByAnchor_1D_horizontal_longSE(TT_IMA* pout, int imageWidth, int imageHeight, int size, int bitpix)
/*********************************************************************************************/
/* Trait morpho math : algo d'ouverture optimisé pour SE ligne > 150 pixels					 */
/*********************************************************************************************/
/*     ATTENTION: ALGO VALABLE QUE POUR SE=LIGNE											 */
/*********************************************************************************************/
/*						 algo de VAN DROOGENBROECK											 */
/*			réf: Morphological Erosions and Opening: Fast Algorithms Based on Anchors.       */
/*						Journal of Mathematical Imaging and Vision,2005						 */
/*					très rapide pour des très gros SE: ligne > 150 pixels					 */
/*********************************************************************************************/
/*********************************************************************************************/
/*								ATTENTION: IL FAUT POUT=PIN!!								 */
/*********************************************************************************************/

//buf1 load "F:/ima_a_tester_algo/IM_20070813_202524142_070813_20055300.fits.gz" 
//buf1 imaseries "MORPHOMATH nom_trait=OUVERTURE struct_elem=RECTANGLE x1=10 y1=1"
//buf1 save "c:/d/geoflash/pointage5/toqjd.fit"
{
	int aux,end;
	long outLeft,outRight,current,sentinel,nbrBytes; 
	int min;
	int j,imageWidthMinus1,sizeMinus1;
	double *histo;


	imageWidthMinus1 = imageWidth-1;
	sizeMinus1 = size-1;

	/* Initialisation of the histogram */
	if (bitpix==0) {bitpix=16;}
	nbrBytes = (long) pow(2,bitpix)*sizeof(double);
	histo = (double *)malloc(nbrBytes);

	/* Row by row */
	for (j=0; j<imageHeight; j++) {
		/* Initialisation of both extremities of a line */
		outLeft = (j*imageWidth);
		outRight = outLeft+imageWidthMinus1;

		/* Handling of both sides */
		/* Left side */
		while ( (outLeft < outRight) && (pout->p[outLeft] >= pout->p[outLeft+1]) )
		{ outLeft++; }

		/* Right side */
		while ( (outLeft < outRight) && (pout->p[outRight-1] <= pout->p[outRight]) )
		{ outRight--; }

		/* Enters in the loop */
		startLine:
		min =(int) pout->p[outLeft];
		current = outLeft+1;
		while ((current<outRight) && (pout->p[current]<=min))
		{ min=(int)pout->p[current]; outLeft++; current++; }
		sentinel = outLeft+size;
		if (sentinel>outRight) { goto finishLine; }

		/* We ran "size" pixels ahead */ 
		current++; 
		while (current<sentinel) {
			if (pout->p[current]<=min) { /* We have found a new minimum */
				end = current;
				outLeft++; 
				while (outLeft < end) {pout->p[outLeft]=(TT_PTYPE)min; outLeft++; }
				outLeft = current; 
				goto startLine; 
			}
			current++; 
		}

		/* We did not find a smaller value in the segment in reach
		* of outLeft; current is the first position outside the 
		* reach of outLeft 
		*/
		if (pout->p[current]<=min) {
			end = current;
			outLeft++; 
			while (outLeft < end) { pout->p[outLeft]=(TT_PTYPE)min; outLeft++; }
			outLeft = current;
			goto startLine; 
		} else	/* We can not avoid computing the histogram */
		{
			memset(histo, 0, nbrBytes);
			outLeft++; 
			for (aux=outLeft; aux<=current; aux++) { histo[(int)pout->p[aux]]++; }
			min++; while (histo[min]<=0) { min++; }
			histo[(int)pout->p[outLeft]]--;
			pout->p[outLeft] = (TT_PTYPE)min;
			histo[min]++;
		}

		/* We just follow the pixels, update the histogram and look for
		* the minimum */
		while (current < outRight)  { 
			current++; 
			if (pout->p[current] <= min) {
				/* We have found a new mimum */
				end = current;
				outLeft++; 
				while (outLeft < end) { pout->p[outLeft]=(TT_PTYPE)min; outLeft++; }
				outLeft = current; 
				goto startLine; 
			} else {
				/* Update the histogram */
				histo[(int)pout->p[current]]++;
				histo[(int)pout->p[outLeft]]--;
				/* Recompute the minimum */
				while (histo[min]<=0) { min++; }
				outLeft++; 
				histo[(int)pout->p[outLeft]]--;
				pout->p[outLeft]=(TT_PTYPE)min; 
				histo[min]++;
			}
		}

		/* We have to finish the line */
		while (outLeft < outRight) {
			histo[(int)pout->p[outLeft]]--;
			while (histo[min]<=0) { min++; }
			outLeft++; 
			histo[(int)pout->p[outLeft]]--;
			pout->p[outLeft]=(TT_PTYPE)min; 
			histo[min]++;
		}

		finishLine:
		while (outLeft < outRight){
			if (pout->p[outLeft]<=pout->p[outRight]) {
				min=(int)pout->p[outRight]; outRight--; 
				if (pout->p[outRight]>min) 	{ pout->p[outRight]=(TT_PTYPE)min; }
			} else {
				min=(int)pout->p[outLeft]; outLeft++; 
				if (pout->p[outLeft]>min) 	{ pout->p[outLeft]=(TT_PTYPE)min; }
			}
		}
	}

	/* Free memory */
	free(histo);
	return 0;
}



int tt_histocuts_myrtille(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,double *mode,double *mini,double *maxi)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/***************************************************************************/
/* Il faut que soient deja calculees les donnees suivantes :               */
/*  pseries->                                                              */
/*                                                                         */
/* pseries->lofrac=0.05 le seuil bas dans l'histogramme                    */
/* pseries->hifrac=0.97 le seuil haut dans l'histogramme                   */
/* pseries->cutscontrast=1.0 pour diminuer le contraste                    */
/***************************************************************************/
{
   double sb,sh,bg,mi,ma;
   int msg;

   if (pseries->lofrac>1.) {pseries->lofrac=1.;}
   if (pseries->lofrac<0.) {pseries->lofrac=0.;}
   if (pseries->hifrac>1.) {pseries->hifrac=1.;}
   if (pseries->hifrac<0.) {pseries->hifrac=0.;}
   if (pseries->lofrac>pseries->hifrac) {
      pseries->lofrac=0.05;
      pseries->hifrac=0.97;
   }
   if ((msg=tt_histocuts_precis(p,pseries,pseries->lofrac,pseries->hifrac,&sb,&sh,&bg,&mi,&ma))!=OK_DLL) {
      return(msg);
   }
   /* --- amplification de constraste ---*/
   sb-=((bg-sb)*pseries->cutscontrast);
   sh-=((bg-sh)*pseries->cutscontrast);
   *hicut=sh;
   *locut=sb;
   *mode=bg;
   *mini=mi;
   *maxi=ma;
   return(OK_DLL);
}

int tt_histocuts_precis(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode,double *minim,double *maxim)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/* Le pendant de la fonction tt_util_cuts2.                                */
/***************************************************************************/
{
   double sb,sh,sb0,sh0,delta;
   int *histo,k,sortie,modemax,taille,msg,nombre;
   int nb,nelem,nelem0=0,nullpix_exist,index_histo,nbtours;
   double mini,maxi,nullpix_value,valeur,*seuil,moyenne,deltam,rapport;

   nelem=(p->naxis1)*(p->naxis2);
   nullpix_exist=pseries->nullpix_exist;
   nullpix_value=pseries->nullpix_value;
   if (nullpix_exist==TT_NO) {
      nullpix_value=TT_MIN_DOUBLE;
   }
   nb=50;
   nombre=nb;
   taille=sizeof(int);
   histo=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&histo,&nombre,&taille,"histo"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_histocuts_precis (pointer histo)");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nb+1;
   taille=sizeof(double);
   seuil=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&seuil,&nombre,&taille,"seuil"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_histocuts_precis (pointer seuil)");
      tt_free(histo,"histo");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- calcul du mini et maxi ---*/
   pseries->maxi=TT_MIN_FLOAT;
   pseries->mini=TT_MAX_FLOAT;
   for (k=0;k<nelem;k++) {
      valeur=(double)(p->p[k]);
      if (valeur!=nullpix_value) {
         if (valeur>pseries->maxi) {pseries->maxi=valeur;}
   	     if (valeur<pseries->mini) {pseries->mini=valeur;}
	  }
   }
   *minim=pseries->mini;
   *maxim=pseries->maxi;
   delta=fabs(pseries->maxi-pseries->mini);
   if ((delta!=0)&&(delta<1e-5)) {
      pseries->maxi=pseries->mini+1e-5;
   }
   sb0=mini=pseries->mini;
   sh0=maxi=pseries->maxi;
   sortie=TT_NO;
   nbtours=0;
   /* --- boucle sur l'histogramme ---*/
   do {
      nbtours++;
      if (mini==maxi) {
	     *hicut=maxi;
	     *locut=mini;
         *mode=(maxi+mini)/2.;
	     tt_free(seuil,"seuil");
	     tt_free(histo,"histo");
	     return(OK_DLL);
      }
      /* --- initialise les seuils ---*/
      sb=mini;
      sh=maxi;
      /* --- remplit l'histogramme ---*/
      for (k=0;k<nb;k++) {
	     histo[k]=0;
      }
      deltam=fabs(maxi-mini);
      if (deltam>1e-10) {
         for (k=0,nelem0=0,moyenne=0.;k<nelem;k++) {
   	        valeur=(double)(p->p[k]);
	        if (valeur!=nullpix_value) {
	           nelem0++;
               deltam=(valeur-mini)/(maxi-mini);
	           index_histo=(int)(fabs(floor(deltam*nb)));
	           if (index_histo>=nb) { index_histo=nb-1; }
	           else if (index_histo<0) { index_histo=0; }
	           histo[index_histo]++;
	           moyenne+=valeur;
	        }
         }
      } else {
         histo[0]=nelem;
	     moyenne=(double)(p->p[0]);
      }
      /* --- calcule la moyenne ---*/
      if (nelem0==0) {
	     *hicut=sh;
	     *locut=sb;
         *mode=(sb+sh)/2.;
	     return(OK_DLL);
      }
      moyenne/=nelem0;
      /* --- remplit les valeurs de seuil inf pour chaque baton ---*/
      for (k=0;k<=nb;k++) {
	     seuil[k]=mini+(maxi-mini)*k/nb;
      }
      /* --- calcule le mode ---*/
      modemax=0;
      for (k=0;k<nb-1;k++) {
   	     if (histo[k]>modemax) {
	        modemax=histo[k];
	        *mode=(seuil[k+1]+seuil[k])/2.;
         }
      }
      /* --- calcule l'histogramme cumule ---*/
      for (k=1;k<nb;k++) {
	     histo[k]+=histo[k-1];
      }
      /* --- calcule des nouveaux seuils plus serres ---*/
      for (k=0;k<nb;k++) {
	     valeur=(double)(histo[k])/(double)(histo[nb-1]);
	     if (valeur<=percent_sb) {sb=seuil[k];}
	     if (valeur>=percent_sh) {sh=seuil[k+1];break;}
      }
      mini=sb-(sh-sb); if (mini<sb0) {mini=sb0;}
      maxi=sh+(sh-sb); if (maxi>sh0) {maxi=sh0;}
      if ((sh-sb)==0) {
	     sortie=TT_YES;
      } else {
         rapport=fabs(1-(sh0-sb0)/(sh-sb));
	     if (rapport<0.1) {
	        sortie=TT_YES;
	     }
      }
      if (nbtours>3) {
         sortie=TT_YES;
      }
      /*printf("seuils histo : sb=%f sh=%f mode=%f\n",sb,sh,mode);getch();*/
      sb0=sb;
      sh0=sh;
   } while (sortie==TT_NO);
   *hicut=sh;
   *locut=sb;
   tt_free(seuil,"seuil");
   tt_free(histo,"histo");
   return(OK_DLL);
}


void tt_ima_series_hough_myrtille(TT_IMA* pin,TT_IMA* pout,int naxis1, int naxis2, int threshold , double *eq)
/***************************************************************************/
/* Transformee de Hough arrangée pour la detection des GTO                 */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   
   long nelem2;
   int msg,k,kkk,x,y,adr;
   double value,*cost,*sint,rho,theta,rho_int;
   int naxis11,naxis12,naxis21,naxis22,nombre,taille,naxis222,naxis122,adr_max;
   double threshold_ligne,seuil_max,somme_value,somme_theta,somme_ro,theta0,ro0;
   int ymax=0, xmax=0,kl,kc;

   /* --- intialisations ---*/
   naxis11=naxis1;
   naxis21=naxis2;
   naxis12=180*2;
   naxis22=(int)ceil(sqrt(naxis11*naxis11+naxis21*naxis21));
   naxis122=2*naxis12;
   naxis222=2*naxis22;
   nelem2=(long)(naxis12*naxis222);
   
   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(pout,naxis12,naxis222);

   /* --- mise a zero de l'image de sortie ---*/
   for (kkk=0;kkk<(int)(nelem2);kkk++) {
      value=0.;
      pout->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- on trace une ligne mediane ---*/
   for(k=0;k<naxis12;k++) {
      rho_int=naxis22;
      adr=(int)(rho_int*naxis12+k);
      pout->p[adr]+=(TT_PTYPE)(1);
   }

   /* --- table de cos, sin ---*/
   nombre=naxis12;
   taille=sizeof(double);
   cost=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cost,&nombre,&taille,"cost"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_myrtille for pointer cost");
   }
   sint=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&sint,&nombre,&taille,"sint"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_hough_myrtille for pointer sint");
      tt_free2((void**)&cost,"cost");
   }
   for(k=0;k<naxis12;k++) {
      //theta=(1.*k-90.)*(TT_PI)/180.;
      theta=(1.*k/2-90.)*(TT_PI)/180.; //pour avoir une résolution 2 fois plus grande
      cost[k]=cos(theta);
      sint[k]=sin(theta);
   }

   
   /* --- balayage ---*/
   for(x=0;x<naxis11;x++) {
      for(y=0;y<naxis21;y++) {
         adr=y*naxis11+x;
         value=pin->p[adr];
         if (value>=threshold) {
            for(k=0;k<naxis12;k++) {
               rho=-x*sint[k]+y*cost[k];
               rho_int=(int)rho;
               rho_int=naxis22+(int)rho;
               if ((rho_int>=0)&&(rho_int<naxis222)) {
                  adr=(int)(rho_int*naxis12+k);
                  //if (pseries->binary_yesno==TT_NO) {
                   //  pout->p[adr]+=(TT_PTYPE)(value);
                  //} else {
                     pout->p[adr]+=(TT_PTYPE)(1.);
                  //}
               }
            }
         }
      }
   }

   /* --- on libere les pointeurs ---*/
   tt_free2((void**)&cost,"cost");
   tt_free2((void**)&sint,"sint");
   
   /* --- calcul du seuil en fonction du maximum de l'image --- */
   seuil_max=0;
   adr_max=0;
	for(x=0;x<naxis12;x++) {
		for(y=0;y<naxis222;y++) {
			adr=y*naxis12+x;
			value=pout->p[adr];
			if (value>seuil_max) {
				seuil_max=value;
				adr_max=adr;
				ymax=y;
				xmax=x;
			}
		}
	 }
	//enregistre l'image de hough
	//tt_imasaver(pout,"c:/d/geoflash/pointage5/hough.fit",16);
	//seuil de détection fixé arbitrairement à 15 points alignés
	if (seuil_max>=10) {
		threshold_ligne=seuil_max/2;
		somme_value=0;
		somme_theta=0;
		somme_ro=0;
		//recherche du barycentre de la traînée détectée
		for (kl=-20; kl<=20;kl++) { //attention à ymax!
			if (ymax+kl<0) continue;
			if (ymax+kl>=naxis222) break;
			for (kc=-20;kc<=20;kc++) { //attention à xmin!
				if (xmax+kc<0) continue;
				if (xmax+kc>=naxis12) break;
				adr=kl*naxis12+adr_max+kc;
				if (pout->p[adr]>threshold_ligne) {
					somme_value=somme_value+pout->p[adr];
					somme_theta=somme_theta+(xmax+kc)*1.0*pout->p[adr];
					somme_ro=somme_ro+(ymax+kl)*1.0*pout->p[adr];
				}
			}
		}
		if (somme_value!=0) {
			theta0=	somme_theta/somme_value;
			ro0= somme_ro/somme_value;
		} else {
			theta0=xmax;
			ro0=ymax;
		}
		
		//coordonnées du point dans le plan de hough
		//theta0=(theta0-naxis12/2.)*(TT_PI)/180.;
		theta0=(theta0/2.0-naxis12/4)*(TT_PI)/180.;
		ro0=ro0-naxis22;
		
		//pour angle différent de 90°
		if ((theta0==(TT_PI)/2.)||(theta0==-(TT_PI)/2.)) {
			eq[0]=0;
			eq[1]=0;
			eq[2]=-ro0;
		} else {
			eq[0]=tan(theta0);
			eq[1]=ro0/(cos(theta0));
			eq[2]=0;
		}
	} else {
		//pas de detection dans le plan de hough
		eq[0]=0;
		eq[1]=0;
		eq[2]=0;
	}


	//equation de la droite sous la forme y=a0*x+b0
	tt_imadestroyer(pout);
	
}



//###############################################################################################################################
//###############################################################################################################################
//											COPIE DE FOCNTIONS UTILENT DANS CPIXELS.CPP
//###############################################################################################################################
//###############################################################################################################################

void tt_fitgauss1d(int n,double *y,double *p,double *ecart) {

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
void tt_fitgauss2d(int sizex, int sizey,double **y,double *p,double *ecart) {

   int l,nbmax,m,mm;
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
   fitgauss2d_b1:

   for (i=0;i<l;i++) {
	   a0=p[i];
		mm=0;
      fitgauss2d_b2:
		mm++;
		if (mm>nbmax) { break; }
	   l2=0;
	   for (jx=0;jx<sizex;jx++) {
	      xx=(double)jx;
	      for (jy=0;jy<sizey;jy++) {
	         yy=(double)jy;
	         rr2=(xx-p[1])*(xx-p[1])+(yy-p[4])*(yy-p[4]);
	         y0=p[0]*exp(-rr2/p[2]/p[5])+p[3];
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






/**************************************************************************/
/**************************************************************************/
/* exemple de la fonction user TUTU implantee dans IMA/STACK              */
/**************************************************************************/
/* Pile d'addition d'image (equivalent a ADD2 de Qmips32).                */
/* Subtil tour de force pour tenir compte des pixels non definis et pour  */
/* calculer l'heure de l'image synthetisee au prorata des images.         */
/**************************************************************************/
int tt_ima_stack_5_tutu(TT_IMA_STACK *pstack)
{
   int kk,kkk;
   double poids_pondere,value;
   int base_adr;
   TT_IMA *p_tmp=pstack->p_tmp;
   TT_IMA *p_out=pstack->p_out;
   long firstelem=pstack->firstelem;
   long nelements=pstack->nelements;
   long nelem=pstack->nelem;
   long nelem0=pstack->nelem0;
   int nbima=pstack->nbima;
   double *poids=pstack->poids;
   double val;
   int *index0,nbima0;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_tutu (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(nbima)/(double)(nelements);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      for (value=0,nbima0=0,kk=0;kk<nbima;kk++) {
         base_adr=(int)(nelem0)*kk;
         val=(double)(p_tmp->p[base_adr+kkk]);
         if (pstack->nullpix_exist==TT_YES) {
            if (val>pstack->nullpix_value) {
               index0[kk]=TT_YES;
               value+=val;
               nbima0++;
            } else {
               index0[kk]=TT_NO;
            }
         } else {
            index0[kk]=TT_YES;
            value+=val;
            nbima0++;
         }
      }
      value=(nbima0==0)?pstack->nullpix_value:value*((double)(nbima)/(double)(nbima0));
      if (nbima0==0) {
         for (kk=0;kk<nbima;kk++) {
            poids[kk]+=(poids_pondere/(double)(nbima));
         }
      } else {
        for (kk=0;kk<nbima;kk++) {
	       if (index0[kk]==TT_YES) {
	          poids[kk]+=(poids_pondere/(double)(nbima0));
           }
        }
     }
     p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(value);
   }
   tt_free(index0,"index0");

   return(OK_DLL);
}
