/* tt_seri6.c
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

int tt_ima_series_fitellip_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Ajustement d'ellipses                                                   */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* path_astromcatalog :                                                    */
/* astromcatalog : "USNO.RA" pour designer le USNO reduit                  */
/* objefile= nom du fichier fits qui enregistre la liste des objets.       */
/***************************************************************************/
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
/****************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double dvalue;
   int index,msg;
   int naxis1,naxis2,kkk;
   double xc,yc,ciel;
   double cmag,scale,forme;
   int ordre3,ordre4,ordre5,ordre6;
   double pgposang;
   int xd,xf,yd,yf,tempi;
   char file_out[TT_MAXLIGNE];
   TT_ASTROM p;
   double threshsub,saturation;
   double radius_max_analyse;
   double radius_coeur;
   double radius_effective;
   double magnitude_totale;
   double magnitude_asymptotique;
   double brillance_effective;
   double brillance_centrale;
   char keyname[FLEN_KEYWORD];
   char value_char[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];
   int datatype,i,j;
   double bgmean,bgsigma;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;

   /* --- parametres par defaut ---*/
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;

   /* --- recherche des parametres de la projection dans l'entete ---*/
   tt_util_getkey_astrometry(p_in,&p);

   /* --- echelle et applatissement des pixels ---*/
   /* entete FITS : CDELT1, CDELT2, CROTA2 */
   if ((p.cdelta1!=0)&&(p.cdelta2!=0)) {
      scale=fabs(p.cdelta1)*3600.;
      forme=fabs(p.cdelta2/p.cdelta1);
      pgposang=p.crota2*180/TT_PI;
   } else {
      scale=1.;
      forme=1;
      pgposang=0.;
   }

   /* --- Cadre d'analyse ---*/
   /* option=default : X1=1 X2=1 Y1=1 Y2=1 */
   if ((pseries->x1==pseries->x2)&&(pseries->y1==pseries->y2)) {
      xd=1;
      yd=1;
      xf=p_in->naxis1;
      yf=p_in->naxis2;
   } else {
      xd=pseries->x1;
      yd=pseries->y1;
      xf=pseries->x2;
      yf=pseries->y2;
   }
   if (xd>xf) {
      tempi=xd;
      xd=xf;
      xf=tempi;
   }
   if (yd>yf) {
      tempi=yd;
      yd=yf;
      yf=tempi;
   }
   if (xd<1) { xd=1; }
   if (xf>naxis1) { xf=naxis1; }
   if (yd<1) { yd=1; }
   if (yf>naxis2) { yf=naxis2; }

   /*--- Parametre de point zero de la photometrie ---*/
   /* entete FITS : CMAGR */
   cmag=25.;
   strcpy(keyname,"CMAGR");
   if ((msg=tt_imareturnkeyvalue(p_in,keyname,value_char,&datatype,comment,unit))==0) {
      if (datatype!=0) {
         cmag=atof(value_char);
      }
   }

   /* --- Initialisation de l'image et recherche du maximum ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=(double)p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- Recherche de la saturation et du centre le plus brillant ---*/
   saturation=TT_MIN_DOUBLE;
   xc=(xf+xd)/2.;
   yc=(yf+yd)/2.;
   for (i=xd-1;i<=xf-1;i++) {
      for (j=yd-1;j<=yf-1;j++) {
         dvalue=(double)p_in->p[j*naxis1+i];
         if (dvalue>saturation) {
            saturation=dvalue;
            xc=i;
            yc=j;
         }
      }
   }
   if (saturation<32000.) {
      saturation=32000.;
   }

   /* --- Recherche du centre approximatif ---*/
   /* option=default : XCENTER=0 YCENTER=0 */
   if ((pseries->xcenter!=0)&&(pseries->ycenter!=0)) {
      xc=pseries->xcenter;
      yc=pseries->ycenter;
   }

   /* --- Fond de ciel ---*/
   /* option=default : BACKGROUND=0 */
   if (pseries->background==0) {
      tt_util_bgk(p_in,&bgmean,&bgsigma);
      ciel=bgmean;
   } else {
      ciel=pseries->background;
   }

   /* --- Ordre du developpement de Fourier ---*/
   /* option=default : FITORDER6543=0000 */
   ordre3=0;
   ordre4=0;
   ordre5=0;
   ordre6=0;
   tempi=pseries->fitorder6543;
   ordre6=(int)(tempi/1000);
   tempi=tempi-ordre6*1000;
   ordre5=(int)(tempi/100);
   tempi=tempi-ordre5*100;
   ordre4=(int)(tempi/10);
   tempi=tempi-ordre6*10;
   ordre3=(int)(tempi);

   /* --- fichier de sortie des elements du profil ---*/
   /* option=default : FILE_ASCII=fitellip.txt */
   if (strcmp(pseries->file_ascii,"")==0) {
      strcpy(file_out,"fitellip.txt");
   } else {
      strcpy(file_out,pseries->file_ascii);
   }

   /* --- CALCUL : ajustement d'ellipses par la methode des moments d'inertie ---*/
   msg=tt_laps_analyse(p_in,p_out,xc,yc,ciel,cmag,scale,forme,ordre3,ordre4,ordre5,ordre6,pgposang,xd,xf,yd,yf,saturation,file_out,&radius_max_analyse,&radius_coeur,&radius_effective,&magnitude_totale,&magnitude_asymptotique,&brillance_effective,&brillance_centrale);
   if (msg!=0) {
      return(msg);
   }

   /* --- complete l'entete de l'image avec les resultats de photometrie ---*/
   tt_imanewkey(p_out,"LAPSRMAX",&radius_max_analyse,TDOUBLE,"LAPS Maximum radius analysis","arcsec");
   tt_imanewkey(p_out,"LAPSRCOR",&radius_coeur,TDOUBLE,"LAPS Core radius","arcsec");
   tt_imanewkey(p_out,"LAPSREFF",&radius_effective,TDOUBLE,"LAPS Effective radius","arcsec");
   tt_imanewkey(p_out,"LAPSMAGT",&magnitude_totale,TDOUBLE,"LAPS Total magnitude","mag");
   tt_imanewkey(p_out,"LAPSMAGA",&magnitude_asymptotique,TDOUBLE,"LAPS Asymptotic magnitude","mag");
   tt_imanewkey(p_out,"LAPSBEFF",&brillance_effective,TDOUBLE,"LAPS Effective brightness","mag/arcsec2");
   tt_imanewkey(p_out,"LAPSBCEN",&brillance_centrale,TDOUBLE,"LAPS Central brightness","mag/arcsec2");

   /* --- Eventuellement: soustraction des etoiles plus brillantes qu'un certain seuil ---*/
   /* option=default : THRESHOLD=0 */
   threshsub=pseries->threshold;
   if (threshsub>0) {
      for (kkk=0;kkk<(int)(nelem);kkk++) {
         if (p_out->p[kkk]==0) {
            p_out->p[kkk]=p_in->p[kkk];
            continue;
         }
         dvalue=(double)(p_in->p[kkk]-p_out->p[kkk]);
         if (dvalue<=threshsub) {
            p_out->p[kkk]=p_in->p[kkk];
         }
      }
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_ima_series_hotpixel_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* suppression des pixels chauds ou des colonnes ou des lignes defectueuses*/
/***************************************************************************/
// Parametres :
//  int *hotPixelList : tableau de d'entiers contenant les pixels chauds ou les 
//                    lignes defectueuses ou les colonnes defecteuse 
//      Exemple : 2 pixels chauds, une colonne defecteuse , une ligne defectueuse
//      iHotPixels[] = ['P' 232 183 'P' 456 198 'C' 400 'L' 200 0]
//      equivalent a 
//      iHotPixels[] = [50 232 183 50 456 198 43 400 4C 200 0]
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   int index;
   int result;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;

   /* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   // je copie l'image dans p_out
   memcpy(p_out->p,p_in->p,nelem*sizeof(TT_PTYPE));
   // je retire les pixels chauds de p_out
   result = tt_repairHotPixel(pseries->hotPixelList,p_out);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(result);
}

int tt_ima_series_cosmic_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* suppression des cosmiques                                               */
/***************************************************************************/
/* parametres :                                                            */
/* cosmicThreshold= 400 par défaut (valeur conseillees 100 à 500)          */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   int index;
   int result;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;

   /* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   // je copie l'image dans p_out
   memcpy(p_out->p,p_in->p,nelem*sizeof(TT_PTYPE));
   // je retire les cosmiques de p_out
   result = tt_repairCosmic(pseries->cosmicThreshold,p_out);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(result);
}



