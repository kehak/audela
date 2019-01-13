/* tt_seri3.c
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

int tt_ima_series_sub_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Soustraction de deux images                                             */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* offset=0                                                                */
/* file="file.fit"                                                         */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_out;
   char fullname[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   long nelem,firstelem,nelem_tmp;
   double value,offset;
   int msg,kkk,index;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   offset=pseries->offset;
   index=pseries->index;

   /* --- charge l'image file dans p_tmp1---*/
   if (index==1) {
      /*tt_imabuilder(p_tmp1);*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->file);
      if ((msg=tt_imaloader(p_tmp1,fullname,firstelem,nelem_tmp))!=0) {
         sprintf(message,"Problem concerning file %s",fullname);
         tt_errlog(pseries->tmp_dir,msg,message);
         return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
         sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
         tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
         return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=offset+p_in->p[kkk]-p_tmp1->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(value);
   }
   if (pseries->hotPixelList!= NULL) {
      // je retire les pixels chauds dans p_out
      tt_repairHotPixel (pseries->hotPixelList, pseries->p_out);
   }
   if (pseries->cosmicThreshold!= 0.) {
      // je retire les cosmiques dans p_out
      tt_repairCosmic(pseries->cosmicThreshold, pseries->p_out);
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_ima_series_add_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Addition de deux images                                                 */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* offset=0                                                                */
/* file="file.fit"                                                         */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_out;
   char fullname[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   long nelem,firstelem,nelem_tmp;
   double value,offset;
   int msg,kkk,index;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   offset=pseries->offset;
   index=pseries->index;

   /* --- charge l'image file dans p_tmp1---*/
   if (index==1) {
      /*tt_imabuilder(p_tmp1);*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->file);
      if ((msg=tt_imaloader(p_tmp1,fullname,firstelem,nelem_tmp))!=0) {
         sprintf(message,"Problem concerning file %s",fullname);
         tt_errlog(pseries->tmp_dir,msg,message);
         return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
         sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
         tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
         return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=offset+p_in->p[kkk]+p_tmp1->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_copy_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* copie d'une serie d'images                                              */
/***************************************************************************/
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double value;
   int kkk,index,i,j;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- calcul de l'indice realtif de sortie dans le cas ou nbsubseries!=1 ---*/
   if (pseries->nbsubseries>1) {
	   /* index :    (1 2 3) (4 5 6) (7 8 9) (10 11 12)*/
	   /* index_out :(1 4 7 10) (2 5 8 11) (3 6 9 12)*/
	   i=(int)fmod((double)(index-1),(double)(pseries->nbsubseries-1));
	   /*i : (0 1 2) (0 1 2) (0 1 2) (0 1 2)*/
	   j=1+index/pseries->nbsubseries;
	   /*j : (1 1 1) (2 2 2) (3 3 3) (4 4 4)*/
	   pseries->index_out=i*pseries->nbsubseries+j;
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_offset_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* offset d'une serie d'images                                             */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* offset=0                                                                */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double value,offset;
   int kkk,index;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   offset=pseries->offset;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk]+offset;
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_mult_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* multiplication d'une serie d'images par une constante                   */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* constant=1                                                              */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double value,constant;
   int kkk,index;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   constant=pseries->constant;

   /* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk]*constant;
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_div_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Division de deux images                                                 */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* constant=1                                                              */
/* file="file.fit"                                                         */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_out;
   char fullname[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   long nelem,firstelem,nelem_tmp;
   double value,constant;
   int msg,kkk,index;
   int bitpix,adu_tot;

   /* --- initialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   constant=pseries->constant;
   index=pseries->index;
   bitpix=pseries->bitpix;
   //attention a la valeur par défaut!
   adu_tot=(int)pow(2,(double)bitpix)-1;

   /* --- charge l'image file dans p_tmp1---*/
   if (index==1) {
      /*tt_imabuilder(p_tmp1);*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->file);
      if ((msg=tt_imaloader(p_tmp1,fullname,firstelem,nelem_tmp))!=0) {
         sprintf(message,"Problem concerning file %s",fullname);
         tt_errlog(pseries->tmp_dir,msg,message);
         return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
         sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
         tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
         return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   if (adu_tot>0) {
      for (kkk=0;kkk<(int)(nelem);kkk++) {
         if ((p_tmp1->p[kkk]==0)||(p_in->p[kkk]>=adu_tot)) {
            value=p_in->p[kkk];
         } else {
            value=p_in->p[kkk]/p_tmp1->p[kkk]*constant;
         }
         p_out->p[kkk]=(TT_PTYPE)(value);
      }
   } else {
      for (kkk=0;kkk<(int)(nelem);kkk++) {
         if (p_tmp1->p[kkk]==0) {
            value=p_in->p[kkk];
         } else {
            value=p_in->p[kkk]/p_tmp1->p[kkk]*constant;
         }
         p_out->p[kkk]=(TT_PTYPE)(value);
      }
   }
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_prod_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Produit de deux images                                                  */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* constant=1                                                              */
/* file="file.fit"                                                         */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_out;
   char fullname[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   long nelem,firstelem,nelem_tmp;
   double value,constant;
   int msg,kkk,index;

   /* --- initialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   constant=pseries->constant;
   index=pseries->index;

   /* --- charge l'image file dans p_tmp1---*/
   if (index==1) {
      /*tt_imabuilder(p_tmp1);*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->file);
      if ((msg=tt_imaloader(p_tmp1,fullname,firstelem,nelem_tmp))!=0) {
         sprintf(message,"Problem concerning file %s",fullname);
         tt_errlog(pseries->tmp_dir,msg,message);
         return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
         sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
         tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
         return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      if (constant==0) {
         value=p_in->p[kkk];
      } else {
         value=p_in->p[kkk]*p_tmp1->p[kkk]/constant;
      }
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_filter_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Filtre kernel d'une serie d'images                                      */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* threshold : seuil du filtre (0)                                         */
/* type_threshold : condition sur le seuil pour appliquer le filtre (0)    */
/*                  -1 : pour appliquer le filtre a des valeurs <= seuil   */
/*                   0 : pour appliquer le filtre a des toutes les valeurs */
/*                  +1 : pour appliquer le filtre a des valeurs >= seuil   */
/* kernel_width : largeur du motif kernel (3)                              */
/* kernel_type : fh, fb, med, min, max, mean                               */
/*                0  (1)   2    3    4     5                               */
/* kernel_coef : coefficient ponderateur du filtre (0=efficace 1=inefficac)*/
/*               (0)                                                       */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   double value=0,kernel_coef=0,clipmin=0;
   int kkk,index;
   int k,bordure,bordurex,bordurey;
   int nb,kx,ky,x,y,imax,jmax;
   double val0,threshold,*val,*valtri,val1,val2,*kpatern;
   int type_threshold,kernel_type,kernel_width,kernel_widthx,kernel_widthy;
   int taille,nombre,msg;

   /* --- initialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   threshold=pseries->threshold;
   type_threshold=pseries->type_threshold;
   kernel_width=pseries->kernel_width;
   kernel_type=pseries->kernel_type;
   kernel_coef=pseries->kernel_coef;
   imax=p_in->naxis1;
   jmax=p_in->naxis2;

   /* --- initialisation de l'image ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(value);
   }
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   /* --- conditions d'utilisation du filtre par rapport a la forme de l'image ---*/
   kernel_widthx=kernel_widthy=kernel_width;
   if (kernel_width>imax) {
      kernel_widthx=1;
   }
   if (kernel_width>jmax) {
      kernel_widthy=1;
   }
   if ((kernel_widthx==1)&&(kernel_widthy==1)) {
      return(OK_DLL);
   }

   /* --- mise en place du kernel ---*/
   bordure=(kernel_width-1)/2; /* 1 pour 3 et 2 pour 5 ... */
   bordurex=(kernel_widthx-1)/2; /* 1 pour 3 et 2 pour 5 ... */
   bordurey=(kernel_widthy-1)/2; /* 1 pour 3 et 2 pour 5 ... */
   nb=kernel_widthx*kernel_widthy;
   val=NULL;
   nombre=nb+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&val,&nombre,&taille,"val"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_filter_1 (pointer val)");
      return(TT_ERR_PB_MALLOC);
   }
   valtri=NULL;
   nombre=nb+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&valtri,&nombre,&taille,"valtri"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_filter_1 (pointer valtri)");
      tt_free(val,"val");
      return(TT_ERR_PB_MALLOC);
   }
   kpatern=NULL;
   nombre=nb+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&kpatern,&nombre,&taille,"kpatern"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_filter_1 (pointer kpatern)");
      tt_free(val,"val");tt_free(valtri,"valtri");
      return(TT_ERR_PB_MALLOC);
   }
   /* - kpatern est normalise a 1 -*/
   if (kernel_type==TT_KERNELTYPE_FH) {
      for (val0=0,ky=0;ky<=2*bordure;ky++) {
	 val1=(ky-bordure);
	 for (kx=0;kx<=2*bordure;kx++) {
	    val2=(kx-bordure);
	    val2=val2*val2+val1*val1;
	    if (val2<1) {
	       continue;
	    }
	    value=-exp(-val2/bordure*2);
	    k=(kx+1)+(ky)*kernel_width;
	    kpatern[k]=value;
	    val0+=value;
	 }
      }
      /* pixel du milieu positif */
      kx=bordure;
      ky=bordure;
      value=1-val0; /* sum = 1 */
      k=(kx+1)+(ky)*kernel_width;
      kpatern[k]=value;
   } else if (kernel_type==TT_KERNELTYPE_FB) {
      for (val0=0,ky=0;ky<=2*bordurey;ky++) {
         val1=(ky-bordurey);
	 for (kx=0;kx<=2*bordurex;kx++) {
	    val2=(kx-bordurex);
	    val2=val2*val2+val1*val1;
	    value=exp(-val2/bordure*2);
	    k=(kx+1)+(ky)*kernel_widthx;
	    kpatern[k]=value;
	    val0+=value;
         }
      }
      for (k=1;k<=nb;k++) {
	 kpatern[k]/=val0;
      }
   } else if (kernel_type==TT_KERNELTYPE_GRAD_LEFT) {
      for (val0=0,ky=0;ky<=2*bordure;ky++) {
	 val1=(ky-bordure);
	 for (kx=0;kx<=2*bordure;kx++) {
	    val2=(kx-bordure);
	    value=atan(3.*val2/bordure);
	    k=(kx+1)+(ky)*kernel_width;
	    kpatern[k]=value;
	    val0+=value;
	 }
      }
      for (k=1;k<=nb;k++) {
	 kpatern[k]-=(val0/(double)nb);
      }
   } else if (kernel_type==TT_KERNELTYPE_GRAD_RIGHT) {
      for (val0=0,ky=0;ky<=2*bordure;ky++) {
	 val1=(ky-bordure);
	 for (kx=0;kx<=2*bordure;kx++) {
	    val2=(kx-bordure);
	    value=atan(3.*val2/bordure);
	    k=(kx+1)+(ky)*kernel_width;
	    kpatern[k]=-value;
	    val0+=value;
	 }
      }
      for (k=1;k<=nb;k++) {
	 kpatern[k]-=(val0/(double)nb);
      }
   } else if (kernel_type==TT_KERNELTYPE_GRAD_UP) {
      for (val0=0,kx=0;kx<=2*bordure;kx++) {
	 val1=(kx-bordure);
	 for (ky=0;ky<=2*bordure;ky++) {
	    val2=(ky-bordure);
	    value=atan(3.*val2/bordure);
	    k=(kx+1)+(ky)*kernel_width;
	    kpatern[k]=-value;
	    val0+=value;
	 }
      }
      for (k=1;k<=nb;k++) {
	 kpatern[k]-=(val0/(double)nb);
      }
   } else if (kernel_type==TT_KERNELTYPE_GRAD_DOWN) {
      for (val0=0,kx=0;kx<=2*bordure;kx++) {
	 val1=(kx-bordure);
	 for (ky=0;ky<=2*bordure;ky++) {
	    val2=(ky-bordure);
	    value=atan(3.*val2/bordure);
	    k=(kx+1)+(ky)*kernel_width;
	    kpatern[k]=value;
	    val0+=value;
	 }
      }
      for (k=1;k<=nb;k++) {
	 kpatern[k]-=(val0/(double)nb);
      }
   } else {
      for (k=1;k<=nb;k++) {
	 kpatern[k]=1./nb;
      }
   }

   /* - boucle du grand balayage en y -*/
   x=bordure;
   for (y=0;y<jmax;y++) {
      if (jmax>=kernel_width) {
         if (y>=jmax-bordure) { continue; }
         if (y<bordure) { continue; }
      }
      k=0;
      /* - 1ere demi boucle de balayage kernel en x -*/
      for (ky=y-bordurey;ky<=y+bordurey;ky++) {
	 for (kx=x-bordurex;kx<=x+bordurex-1;kx++) {
	    k=(kx-(x-bordurex)+1)+(ky-(y-bordurey))*kernel_widthx;
	    kkk=(int)((ky)*imax)+(kx);
            if (kkk>=0) {
               val[k]=p_in->p[kkk];
            } else {
               val[k]=0.;
            }
	 }
      }
      /* -  boucle du grand balayage en x -*/
      for (x=0;x<imax;x++) {
         if (imax>=kernel_width) {
            if (x>=imax-bordure) { continue; }
            if (x<bordure) { continue; }
         }
         /* - 2eme demi boucle de balayage kernel en x -*/
         for (kkk=1,kx=x+bordurex,ky=y-bordurey;ky<=y+bordurey;ky++,kkk++) {
	    k=kkk*kernel_widthx;
            if (kkk>=0) {
               val[k]=p_in->p[(int)((ky)*imax)+(kx)];
            } else {
               val[k]=0.;
            }
         }
         for (kkk=1;kkk<=nb;kkk++) {
	    valtri[kkk]=val[kkk];
         }
         /* - val0 est la valeur du pixel central -*/
         val0=valtri[(int)((nb+1)/2)];
         /* - condition pour effectuer le calcul -*/
         if ((type_threshold== 0)||
	    ((type_threshold==-1)&&(val0<=threshold))||
	    ((type_threshold== 1)&&(val0>=threshold))) {
	    if ((kernel_type==TT_KERNELTYPE_MED)||
	        (kernel_type==TT_KERNELTYPE_MIN)||
	        (kernel_type==TT_KERNELTYPE_MAX)) {
	       /* - cas ou il faut trier les valeurs -*/
	       tt_util_qsort_double(valtri,1,nb,NULL);
	       if (kernel_type==TT_KERNELTYPE_MED) { value=valtri[(int)((nb+1)/2)]; }
	       if (kernel_type==TT_KERNELTYPE_MIN) { value=valtri[(int)(1)]; }
	       if (kernel_type==TT_KERNELTYPE_MAX) { value=valtri[(int)(nb)]; }
	       val1=fabs((double)(val0-value));
	       val2=kernel_coef*fabs(valtri[nb-1]-valtri[2]);
	       if (val1<val2) {
	          value=val0;
	       }
	    } else if ((kernel_type==TT_KERNELTYPE_FH)||
  		       (kernel_type==TT_KERNELTYPE_FB)||
		       (kernel_type==TT_KERNELTYPE_GRAD_LEFT)||
		       (kernel_type==TT_KERNELTYPE_GRAD_RIGHT)||
		       (kernel_type==TT_KERNELTYPE_GRAD_UP)||
		       (kernel_type==TT_KERNELTYPE_GRAD_DOWN)||
		       (kernel_type==TT_KERNELTYPE_MEAN)) {
	       /* cas ou l'on applique le kernel predefini -*/
	       for (value=0.,k=1;k<=nb;k++) {
	          value+=(kpatern[k]*val[k]);
	       }
	    }
	    /* - on effectue la nouvelle valeur du pixel -*/
	    p_out->p[(int)((y)*imax)+(x)]=(TT_PTYPE)(value);
         }
         /* - on deplace les valeurs dans le kernel -*/
         for (kx=1;kx<=kernel_widthx-1;kx++) {
	    for (ky=1;ky<=kernel_widthy;ky++) {
	       k=kx+(ky-1)*kernel_widthx;
	       val[k]=val[k+1];
	    }
	 }
      } /* - boucle du grand balayage en x -*/
   } /* - boucle du grand balayage en y -*/

   tt_free(val,"val");tt_free(valtri,"valtri");tt_free(kpatern,"kpatern");

   // --- extra filtering for super uncosmic (kernel = median)
    if ((type_threshold== 0)&&(threshold>0)) {
      for (kkk=0;kkk<(int)(nelem);kkk++) {
         value = p_in->p[kkk] - p_out->p[kkk]; // adu of the cosmic only
	// kepp initial value for the lowest hot pixels (because they are noise)
	 if (value<threshold) {
            p_out->p[kkk] = p_in->p[kkk];
	 }
      }
   }

   return(OK_DLL);
}

int tt_ima_series_opt_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Optimisation du noir sur l'image entiere (methode Buil et Pelle)        */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* dark="dark.fit"                                                         */
/* bias="bias.fit"                                                         */
/* therm_kappa : le pixel du therm est considere dans le calcul si sa      */
/*              valeur est superieure ou egale a moyenne+sigma*therm_kappa.*/
/*              la valeur par defaut est 0.25 mais on peut prendre aussi   */
/*              valeurs negatives.                                         */
/* coef_unsmearing : valeur du coefficient de deconvflat.                  */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_tmp2,*p_out;
   char fullname[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   long nelem,firstelem,nelem_tmp;
   double value,therm_kappa;
   int msg,kkk,index;
   double v,v2,ma,mb,ecart,esperance,xb,somme,*pp,coef,vf;
   int n,ii,jj,imax,jmax,adr,k,nombre,taille;
   double valeur,i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta,therm_mean,therm_sigma;
   double *valtri;
   int bordi=0,bordj=0,kkkk;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_tmp2=pseries->p_tmp2;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   therm_kappa=pseries->therm_kappa;
   index=pseries->index;
   therm_mean=pseries->therm_mean;
   therm_sigma=pseries->therm_sigma;
   imax=p_in->naxis1;
   jmax=p_in->naxis2;
   /* ---- on ne selectionne qu'un cadre centré pour éliminer les pixels de bords ---*/
   bordi=(int)floor(imax*0.1);
   bordj=(int)floor(jmax*0.1);

   /* --- charge les images bias et dark dans p_tmp1 et p_tmp2 ---*/
   if (index==1) {
      /* --- charge le bias ---*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->bias);
      if ((msg=tt_imaloader(p_tmp1,fullname,firstelem,nelem_tmp))!=0) {
	 sprintf(message,"Problem concerning file %s",fullname);
	 tt_errlog(pseries->tmp_dir,msg,message);
	 return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
	 sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
	 tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
	 return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
      /* --- charge le dark ---*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->dark);
      if ((msg=tt_imaloader(p_tmp2,fullname,firstelem,nelem_tmp))!=0) {
	 sprintf(message,"Problem concerning file %s",fullname);
	 tt_errlog(pseries->tmp_dir,msg,message);
	 return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp2->naxis1!=p_in->naxis1)||(p_tmp2->naxis2!=p_in->naxis2)) {
	 sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp2->naxis1,p_tmp2->naxis2,p_tmp2->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
	 tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
	 return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
      /* --- transforme le dark en therm ---*/
      for (kkk=0;kkk<(int)(nelem);kkk++) {
	 p_tmp2->p[kkk]-=p_tmp1->p[kkk];
      }
      /* --- calcule les stat ---*/
      sx_i=0;
      kkkk=0;
      for(ii=bordi;ii<imax-1-bordi;ii++) {
         for(jj=bordj;jj<jmax-1-bordj;jj++) {
            kkk=jj*imax+ii;
	    /* --- algo de la valeur moy et ecart type de Miller ---*/
	    valeur=p_tmp2->p[kkk];
	    if (kkkk==0) {mu_i=valeur;}
	    i=(double) (kkkk+1);
	    delta=valeur-mu_i;
	    mu_ii=mu_i+delta/(i);
	    sx_ii=sx_i+delta*(valeur-mu_ii);
	    mu_i=mu_ii;
	    sx_i=sx_ii;
	    kkkk++;
	 }
      }
      therm_mean=mu_ii;
      therm_sigma=0.;
      if (i!=0.) {
         therm_sigma=sqrt(sx_ii/i);
      }
      pseries->therm_mean=therm_mean;
      pseries->therm_sigma=therm_sigma;
   }

   /* --- calcul de la fonction ---*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   ma=0;mb=0;ecart=0;esperance=0;n=0;
   /*
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      if ((double)(p_tmp2->p[kkk])>=(therm_mean+therm_sigma*therm_kappa)) {
	 v=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	 v2=(double)(p_tmp2->p[kkk]);
	 ma+=v;
	 mb+=v2;
	 ecart+=v2*v2;
	 esperance+=v*v2;
	 n++;
      }
   }
   if (n==0) {
      xb=0;
   } else {
      ma=ma/n;
      mb=mb/n;
      ecart=ecart/n-mb*mb;
      esperance=esperance/n-ma*mb;
      xb=0.;
      if (ecart!=0.) {
         xb=esperance/ecart;
      }
   }
   n=0; esperance=0;
   */
   for(ii=bordi;ii<imax-1-bordi;ii++) {
      for(jj=bordj;jj<jmax-1-bordj;jj++) {
         kkk=jj*imax+ii;
         if ((double)(p_tmp2->p[kkk])>=(therm_mean+therm_sigma*therm_kappa)) {
   	    v=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
   	    v2=(double)(p_tmp2->p[kkk]);
	    vf=0.;
	    kkkk=0;
	    if ((jj-2)>=0) {
	       kkk=(jj-2)*imax+ii;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       kkkk++;
	    }
	    if ((jj+2)<jmax) {
	       kkk=(jj+2)*imax+ii;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       kkkk++;
	    }
	    if ((ii-2)>=0) {
	       kkk=jj*imax+ii-2;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       kkkk++;
	    }
	    if ((ii+2)<imax) {
	       kkk=jj*imax+ii+2;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       kkkk++;
	    }
	    if (kkkk>0) {
               vf/=kkkk;
	    }
	    v-=vf;
	    if (v2!=0) {
	       esperance+=v/v2;
  	       n++;
	    }
	 }
      }
   }
   if (n>0) {
      valtri=NULL;
      nombre=n+1;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&valtri,&nombre,&taille,"valtri"))!=0) {
         tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_series_opt_1 (pointer valtri)");
         return(TT_ERR_PB_MALLOC);
      }
      n=0; esperance=0;
      for(ii=bordi;ii<imax-1-bordi;ii++) {
         for(jj=bordj;jj<jmax-1-bordj;jj++) {
            kkk=jj*imax+ii;
            if ((double)(p_tmp2->p[kkk])>=(therm_mean+therm_sigma*therm_kappa)) {
   	       v=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
   	       v2=(double)(p_tmp2->p[kkk]);
	       vf=0.;
	       kkk=(jj-2)*imax+ii;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       kkk=(jj+2)*imax+ii;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       kkk=jj*imax+ii-2;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       kkk=jj*imax+ii+2;
   	       vf+=(double)(p_in->p[kkk]-p_tmp1->p[kkk]);
	       vf/=4;
	       v-=vf;
	       if (v2!=0) {
   	          valtri[n]=v/v2;
  	          n++;
	       }
	    }
	 }
      }
      /* - il faut trier les valeurs -*/
      tt_util_qsort_double(valtri,0,n-1,NULL);
      /* - on prend la mediane -*/
      xb=valtri[(int)floor(n/2)];
      tt_free(valtri,"valtri");
   } else {
      xb=0;
   }
   pseries->coef_therm=xb;
   pseries->nbpix_therm=n;
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=(p_in->p[kkk])- xb*(p_tmp2->p[kkk]) - (p_tmp1->p[kkk]) ;
      p_out->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- calcul du de-smearing (deconvflat) ---*/
   if (pseries->coef_unsmearing>0.) {
      coef=pseries->coef_unsmearing;
      pp=NULL;
      nombre=jmax;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pp,&nombre,&taille,"pp"))!=0) {
         tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_opt_1 for pointer pp");
         return(TT_ERR_PB_MALLOC);
      }
      for(ii=0;ii<imax;ii++) {
        for(jj=0;jj<jmax;jj++) {
            adr=jj*imax+ii;
            pp[jj]=p_out->p[adr];
        }
        for(jj=0;jj<jmax;jj++) {
            somme=0.0;
            adr=jj*imax+ii;
            for(k=0;k<jj;k++) somme+=coef*pp[k];
            pp[jj]=p_out->p[adr]-(somme+.5);
        }
        for(jj=0;jj<jmax;jj++) {
            adr = jj*imax+ii;
            p_out->p[adr]=(TT_PTYPE)(pp[jj]);
        }
      }
      tt_free2((void**)&pp,"pp");
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_unsmearing_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Correction de trainee pour images realisees sans obturateur (deconvflat)*/
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* coef_unsmearing : valeur du coefficient de deconvflat.                  */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   int msg,index;
   double somme,*pp,coef,value;
   int ii,jj,imax,jmax,adr,k,nombre,taille,kkk;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   /* --- calcul du de-smearing (deconvflat) ---*/
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk] ;
      p_out->p[kkk]=(TT_PTYPE)(value);
   }
   if (pseries->coef_unsmearing>0.) {
      coef=pseries->coef_unsmearing;
      imax=p_in->naxis1;
      jmax=p_in->naxis2;
      pp=NULL;
      nombre=jmax;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pp,&nombre,&taille,"pp"))!=0) {
         tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_unsmearing_1 for pointer pp");
	      return(msg);
      }
      for(ii=0;ii<imax;ii++) {
	      for(jj=0;jj<jmax;jj++) {
	         adr=jj*imax+ii;
	         pp[jj]=p_out->p[adr];
	      }
	      for(jj=0;jj<jmax;jj++) {
	         somme=0.0;
	         adr=jj*imax+ii;
	         for(k=0;k<jj;k++) somme+=coef*pp[k];
	         pp[jj]=p_out->p[adr]-(somme+.5);
	      }
	      for(jj=0;jj<jmax;jj++) {
	         adr = jj*imax+ii;
	         p_out->p[adr]=(TT_PTYPE)(pp[jj]);
	      }
      }
      tt_free2((void**)&pp,"pp");
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


int tt_ima_series_untrail_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Correction de trainee pour images realisees sans moteur                 */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* length : .                                                              */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   long nelem;
   int msg,index;
   double *pp,value,medlevel;
   int ii,jj,n,imax,jmax,adr,nombre,taille,kkk;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   /* --- calcul du de-smearing (deconvflat) ---*/
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk] ;
      /*
      if (value<2191) {
         value=0;
      } else {
         value=1;
      }
      */
      p_out->p[kkk]=(TT_PTYPE)(value);
   }
   if (pseries->length>0) {
      n=pseries->length;
      imax=p_in->naxis1;
      jmax=p_in->naxis2;
      pp=NULL;
      nombre=imax;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pp,&nombre,&taille,"pp"))!=0) {
         tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_unsmearing_1 for pointer pp");
	      return(msg);
      }
      for(jj=0;jj<jmax;jj++) {
	      for(ii=0;ii<imax;ii++) {
	         adr=jj*imax+ii;
	         pp[ii]=(double)p_out->p[adr];
	      }
         tt_util_qsort_double(pp,0,imax,NULL);
         medlevel=pp[(int)(imax/2)];
	      for(ii=0;ii<imax;ii++) {
	         pp[ii]=medlevel;
	      }
	      for(ii=0;ii<imax;ii++) {
            /* --- calcule value=p[i+1]-p[i] ---*/
	         adr=jj*imax+ii;
            if (ii<(imax-1)) {
  	            value=p_out->p[(int)(jj*imax+ii+1)]-p_out->p[adr];
            } else {
  	            value=medlevel-p_out->p[adr];
            }
            /* --- calcule q[i+1]-q[i-n]=value --- */
            if (ii<n) {
               pp[ii]=medlevel+value;
            } else {
               pp[ii]=pp[ii-n]+value;
            }
	      }
	      for(ii=0;ii<imax;ii++) {
	         adr = jj*imax+ii;
	         p_out->p[adr]=(TT_PTYPE)(pp[ii]);
	      }
      }
      tt_free2((void**)&pp,"pp");
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_trans_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Translation constante d'une serie d'images.                             */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* trans_x=0                                                               */
/* trans_y=0                                                               */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   double trans_x,trans_y,a[6];
   int index;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   trans_x=pseries->trans_x;
   trans_y=pseries->trans_y;

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   tt_util_transima1(pseries,trans_x,trans_y);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   /* --- calcule les nouveaux parametres de projection ---*/
   a[0]=1.;
   a[1]=0.;
   a[2]=-trans_x;
   a[3]=0.;
   a[4]=1.;
   a[5]=-trans_y;
   tt_util_update_wcs(p_in,p_out,a,2,NULL);

   return(OK_DLL);

}


int tt_ima_series_invert_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* inversions d'une serie d'images                                         */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* flip : pour effectuer une inversion haut-bas.                           */
/* mirror : pour effectuer une inversion droite-gauche.                    */
/* xy : pour inverser les axes xy.                                         */
/* Il est possible de combiner les trois inversions (ordre flip,mirror,xx) */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out,*p_tmp1;
   long nelem;
   double value,vald1,vald2;
   int kkk,index,naxis1,naxis2,x,y;
   double n,a[6];

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   p_tmp1=pseries->p_tmp1;
   nelem=pseries->nelements;
   index=pseries->index;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;

   /* --- in -> tmp1 ---*/
   tt_imacreater(p_tmp1,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk];
      p_tmp1->p[kkk]=(TT_PTYPE)(value);
   }

   /* --- flip ---*/
   if (pseries->invert_flip==TT_YES) {
      for (y=0;y<(int)(floor(.5*naxis2));y++) {
         for (x=0;x<naxis1;x++) {
            vald1=p_tmp1->p[y*naxis1+x];
            vald2=p_tmp1->p[(naxis2-1-y)*naxis1+x];
            p_tmp1->p[y*naxis1+x]=(TT_PTYPE)(vald2);
            p_tmp1->p[(naxis2-1-y)*naxis1+x]=(TT_PTYPE)(vald1);
         }
      }
      a[0]=1.;
      a[1]=0.;
      a[2]=0.;
      a[3]=0.;
      a[4]=-1.;
      a[5]=(double)(naxis2-1);
   }

   /* --- mirror ---*/
   else if (pseries->invert_mirror==TT_YES) {
      for (x=0;x<(int)(floor(.5*naxis1));x++) {
         for (y=0;y<naxis2;y++) {
            vald1=p_tmp1->p[y*naxis1+x];
            vald2=p_tmp1->p[y*naxis1+(naxis1-1-x)];
            p_tmp1->p[y*naxis1+x]=(TT_PTYPE)(vald2);
            p_tmp1->p[y*naxis1+(naxis1-1-x)]=(TT_PTYPE)(vald1);
         }
      }
      a[0]=-1.;
      a[1]=0.;
      a[2]=(double)(naxis1-1);
      a[3]=0.;
      a[4]=1.;
      a[5]=0.;
   }

   /* --- xy ---*/
   else if (pseries->invert_xy==TT_YES) {
      /*tt_imabuilder(p_out);*/
      tt_imacreater(p_out,p_in->naxis2,p_in->naxis1);
      for (x=0;x<naxis1;x++) {
         for (y=0;y<naxis2;y++) {
            p_out->p[x*naxis2+y]=p_tmp1->p[y*naxis1+x];
         }
      }
      if (naxis1<naxis2) {
         n=naxis1/2.;
      } else {
         n=naxis2/2.;
      }
      a[0]=0.;
      a[1]=-1.;
      a[2]=(double)naxis2-n;
      a[3]=-1.;
      a[4]=0.;
      a[5]=n;
   } else {
      /*tt_imabuilder(p_out);*/
      tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
      for (kkk=0;kkk<(int)(nelem);kkk++) {
         value=p_tmp1->p[kkk];
         p_out->p[kkk]=(TT_PTYPE)(value);
      }
      a[0]=1.;
      a[1]=0.;
      a[2]=0.;
      a[3]=0.;
      a[4]=1.;
      a[5]=0.;
   }

   /* --- calcule les nouveaux parametres de projection ---*/
   tt_util_update_wcs(p_in,p_out,a,2,NULL);

   /* --- on reinitialise l'image temporaire ---*/
   tt_imadestroyer(pseries->p_tmp1);
   tt_imabuilder(pseries->p_tmp1);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_invert_2(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* inversions d'une serie d'images                                         */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* flip : pour effectuer une inversion haut-bas.                           */
/* mirror : pour effectuer une inversion droite-gauche.                    */
/* xy : pour inverser les axes xy.                                         */
/* Il est possible de combiner les trois inversions (ordre flip,mirror,xx) */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int k,naxis1,naxis2,index;
   double n,a[6];
   TT_COEFA *p_dum;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;

   /* --- flip ---*/
   if (pseries->invert_flip==TT_YES) {
      a[0]=1.;
      a[1]=0.;
      a[2]=0.;
      a[3]=0.;
      a[4]=-1.;
      a[5]=(double)(naxis2-1);
      p_dum=&(pseries->coefa[index-1]);
      for (k=0;k<6;k++) {
         p_dum->a[k]=a[k];
      }
      tt_imacreater(p_out,naxis1,naxis2);
      tt_util_regima1(pseries);
      /* --- calcule les nouveaux parametres de projection ---*/
      tt_util_update_wcs(p_in,p_out,a,2,NULL);
   }

   /* --- mirror ---*/
   else if (pseries->invert_mirror==TT_YES) {
      a[0]=-1.;
      a[1]=0.;
      a[2]=(double)(naxis1-1);
      a[3]=0.;
      a[4]=1.;
      a[5]=0.;
      p_dum=&(pseries->coefa[index-1]);
      for (k=0;k<6;k++) {
         p_dum->a[k]=a[k];
      }
      tt_imacreater(p_out,naxis1,naxis2);
      tt_util_regima1(pseries);
      /* --- calcule les nouveaux parametres de projection ---*/
      tt_util_update_wcs(p_in,p_out,a,2,NULL);
   }

   /* --- xy ---*/
   else if (pseries->invert_xy==TT_YES) {
      if (naxis1<naxis2) {
         n=naxis1/2.;
      } else {
         n=naxis2/2.;
      }
      a[0]=0.;
      a[1]=1.;
      a[2]=0;
      a[3]=1.;
      a[4]=0.;
      a[5]=0.;
      p_dum=&(pseries->coefa[index-1]);
      for (k=0;k<6;k++) {
         p_dum->a[k]=a[k];
      }
      tt_imacreater(p_out,naxis2,naxis1);
      tt_util_regima1(pseries);
      /* --- calcule les nouveaux parametres de projection ---*/
      /*tt_util_matrice_inverse_bilinaire(a,b); */
      tt_util_update_wcs(p_in,p_out,a,2,NULL);
   } else {
      a[0]=1.;
      a[1]=0.;
      a[2]=0.;
      a[3]=0.;
      a[4]=1.;
      a[5]=0.;
      p_dum=&(pseries->coefa[index-1]);
      for (k=0;k<6;k++) {
         p_dum->a[k]=a[k];
      }
      tt_imacreater(p_out,naxis1,naxis2);
      tt_util_regima1(pseries);
      /* --- calcule les nouveaux parametres de projection ---*/
      tt_util_update_wcs(p_in,p_out,a,2,NULL);
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_conv_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Filtrage direct par une convolution spatiale.                           */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out,*p_tmp1;
   double val;
   int index,adr2,imax,jmax,i1,j1,adr,k,kkk;
   long nelem;
   double somme;
   int largeur,largeur2;
   double *filtre;
   double reste,ilarg,sigma,sigma2;
   int kernel_type,taille,i,j;
   char value_char[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];
   int datatype,msg;
   double value=0;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   p_tmp1=pseries->p_tmp1;
   index=pseries->index;
   imax=p_in->naxis1;
   jmax=p_in->naxis2;
   kernel_type=pseries->kernel_type;
   nelem=pseries->nelements;

   /* === decode la largeur du filtre ===*/
   sigma=pseries->sigma_value;
   if (pseries->sigma_given==TT_NO) {
      /* --- on lit la valeur de fwhm dans l'entete ---*/
      if ((msg=tt_imareturnkeyvalue(p_in,"FWHM",value_char,&datatype,comment,unit))!=0) {
         return(msg);
      }
      if (datatype!=0) {
         sigma=atof(value_char)*.601;
      }
   }
   sigma=fabs(sigma);
   if (sigma<=TT_EPS_DOUBLE) { sigma=1.; }
   sigma2=sigma*sigma;

   /* ==== cree les images de calcul===*/
   tt_imacreater(p_tmp1,p_in->naxis1,p_in->naxis2);
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      value=p_in->p[kkk];
      p_tmp1->p[kkk]=(TT_PTYPE)(value);
      p_out->p[kkk]=(TT_PTYPE)(value);
   }
   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   /*==== preparation du Filtre ====*/
   largeur=(short)((float)5.*sigma+(float)1.);
   if (largeur<3) largeur=3;
   reste=fmod((double)largeur,2.);
   if (reste==(double)0.) largeur = largeur + 1;
   largeur2=(largeur-1)/2;     /* fixe le contour de l'image */

   /*=== calcul du filtre ===*/
   filtre=NULL;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&filtre,&largeur,&taille,"filtre"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_conv_1 for pointer filtre");
      return(msg);
   }
   somme=(double)0.;
   if (kernel_type==TT_KERNELTYPE_GAUSSIAN) {
      for (i=0;i<largeur;i++) {
         ilarg=(float)(i-largeur2);
         filtre[i]=exp(-ilarg*ilarg/2./sigma2);
         somme=somme+filtre[i];
      }
      for (i=0;i<largeur;i++) filtre[i]=filtre[i]/somme;
   } else if (kernel_type==TT_KERNELTYPE_MEXICAN) {
      for (i=0;i<largeur;i++) {
         ilarg=(float)(i-largeur2);
         filtre[i]=(2-ilarg*ilarg/sigma2)*exp(-ilarg*ilarg/2./sigma2);
      }
   } else if (kernel_type==TT_KERNELTYPE_MORLET) {
      for (i=0;i<largeur;i++) {
         ilarg=(float)(i-largeur2);
         filtre[i]=2/sigma2*(exp(-ilarg*ilarg/sigma2)-0.5*exp(-ilarg*ilarg/2./sigma2));
      }
   }

   /*==== balayage X ====*/
   for (j=0;j<jmax;j++) {
      adr=(int)j*imax;
      for (i=0;i<imax;i++) {
         val=0.;
         for (k=0;k<largeur;k++) {
            i1=i+k-largeur2;
            if (i1<0) i1=0;
            if (i1>imax-1) i1=imax-1;
            adr2=adr+(int)i1;
            val+=filtre[k]*(double)p_in->p[adr2];
         }
         p_tmp1->p[adr+(int)i]=(TT_PTYPE)val;
      }
   }

   /*==== balayage Y ====*/
   for (i=0;i<imax;i++) {
      for (j=0;j<jmax;j++) {
         val=0.;
         adr=(int)j*imax+(int)i;
         for (k=0;k<largeur;k++) {
            j1=j+k-largeur2;
            if (j1<0) j1=0;
            if (j1>jmax-1) j1=jmax-1;
            adr2=(int)j1*imax+(int)i;
            val+=filtre[k]*(double)p_tmp1->p[adr2];
         }
         p_out->p[adr]=(TT_PTYPE)val;
      }
   }

   /* --- on reinitialise l'image temporaire ---*/
   tt_imadestroyer(pseries->p_tmp1);
   tt_imabuilder(pseries->p_tmp1);
   tt_free(filtre,"filtre");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);

}


int tt_ima_series_subdark_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Soustraction du noir par equilibrage du temps de pose.                  */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* dark="dark.fit"                                                         */
/* bias="bias.fit"                                                         */
/* exptime="EXPTIME" temps d'integration sur l'image a corriger.           */
/* dexptime="DEXPTIME" temps d'integration sur le dark.                    */
/* coef_unsmearing : valeur du coefficient de deconvflat.                  */
/***************************************************************************/
{
   TT_IMA *p_in,*p_tmp1,*p_tmp2,*p_out;
   char fullname[(FLEN_FILENAME)+5];
   char message[TT_MAXLIGNE];
   long nelem,firstelem,nelem_tmp;
   double value;
   int msg,kkk,index;
   double xb,somme,*pp,coef;
   int ii,jj,imax,jmax,adr,k,nombre,taille;
   char keyname[FLEN_KEYWORD];
   char value_char[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];
   int datatype;
   int bitpix,adu_tot;
   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_tmp2=pseries->p_tmp2;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   bitpix=pseries->bitpix;

   //attention a la valeur de bitpix par défaut!
   adu_tot=(int)pow(2,(double)bitpix)-1;

   /* --- charge les images bias et dark dans p_tmp1 et p_tmp2 ---*/
   if (index==1) {
      /* --- charge le bias ---*/
      /*tt_imabuilder(p_tmp1);*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->bias);
      if ((msg=tt_imaloader(p_tmp1,fullname,firstelem,nelem_tmp))!=0) {
         sprintf(message,"Problem concerning file %s",fullname);
         tt_errlog(pseries->tmp_dir,msg,message);
         return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp1->naxis1!=p_in->naxis1)||(p_tmp1->naxis2!=p_in->naxis2)) {
         sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp1->naxis1,p_tmp1->naxis2,p_tmp1->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
         tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
         return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
      /* --- charge le dark ---*/
      /*tt_imabuilder(p_tmp2);*/
      firstelem=(long)(1);
      nelem_tmp=(long)(0);
      strcpy(fullname,pseries->dark);
      if ((msg=tt_imaloader(p_tmp2,fullname,firstelem,nelem_tmp))!=0) {
         sprintf(message,"Problem concerning file %s",fullname);
         tt_errlog(pseries->tmp_dir,msg,message);
         return(msg);
      }
      /* --- verification des dimensions ---*/
      if ((p_tmp2->naxis1!=p_in->naxis1)||(p_tmp2->naxis2!=p_in->naxis2)) {
         sprintf(message,"(%d,%d) of %s must be equal to (%d,%d) of %s",p_tmp2->naxis1,p_tmp2->naxis2,p_tmp2->load_fullname,p_in->naxis1,p_in->naxis2,p_in->load_fullname);
         tt_errlog(pseries->tmp_dir,TT_ERR_IMAGES_NOT_SAME_SIZE,message);
         return(TT_ERR_IMAGES_NOT_SAME_SIZE);
      }
      /* --- transforme le dark en therm et recherche exptime ---*/
      for (kkk=0;kkk<(int)(nelem);kkk++) {
         p_tmp2->p[kkk]-=p_tmp1->p[kkk];
      }
      /* -- recherche des mots cles 'EXPTIME' dans l'entete FITS du dark --*/
      strcpy(keyname,pseries->key_dexptime);
      if ((msg=tt_imareturnkeyvalue(p_tmp2,keyname,value_char,&datatype,comment,unit))!=0) {
         return(msg);
      }
      if (datatype==0) {
      } else {
         pseries->val_dexptime=atof(value_char);
      }
   }

   /* -- recherche des mots cles 'EXPTIME' dans l'entete FITS de l'image --*/
   strcpy(keyname,pseries->key_dexptime);
   if ((msg=tt_imareturnkeyvalue(p_in,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      pseries->val_exptime=atof(value_char);
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   if (fabs(pseries->val_dexptime)<1e-5) {
      xb=0.;
   } else {
      xb=pseries->val_exptime/pseries->val_dexptime;
   }
   if (adu_tot>0) {
	   for (kkk=0;kkk<(int)(nelem);kkk++) {
		   if (p_in->p[kkk]>=adu_tot) {
		   		value=(p_in->p[kkk]);
		   } else {
				value=(p_in->p[kkk])- xb*(p_tmp2->p[kkk]) - (p_tmp1->p[kkk]) ;
		   }
		  p_out->p[kkk]=(TT_PTYPE)(value);
	   }
   } else {
	   for (kkk=0;kkk<(int)(nelem);kkk++) {
		  value=(p_in->p[kkk])- xb*(p_tmp2->p[kkk]) - (p_tmp1->p[kkk]) ;
		  p_out->p[kkk]=(TT_PTYPE)(value);
	   }
   }

   /* --- suppression des points chauds, des colonnes defectueuses et des lignes defectueuses ---*/
   if (pseries->hotPixelList!= NULL) {
      // je retire les pixels chauds dans p_out
      tt_repairHotPixel (pseries->hotPixelList, pseries->p_out);
   }
   if (pseries->cosmicThreshold != 0.) {
      // je retire les cosmiques dans p_out
      tt_repairCosmic(pseries->cosmicThreshold , pseries->p_out);
   }

   /* --- calcul du de-smearing (deconvflat) ---*/
   if (pseries->coef_unsmearing>0.) {
      coef=pseries->coef_unsmearing;
      imax=p_in->naxis1;
      jmax=p_in->naxis2;
      pp=NULL;
      nombre=jmax;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pp,&nombre,&taille,"pp"))!=0) {
         tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_subdark_1 for pointer pp");
         return(TT_ERR_PB_MALLOC);
      }
      for(ii=0;ii<imax;ii++) {
         for(jj=0;jj<jmax;jj++) {
            adr=jj*imax+ii;
            pp[jj]=p_out->p[adr];
         }
         for(jj=0;jj<jmax;jj++) {
            somme=0.0;
            adr=jj*imax+ii;
            for(k=0;k<jj;k++) somme+=coef*pp[k];
            pp[jj]=p_out->p[adr]-(somme+.5);
         }
         for(jj=0;jj<jmax;jj++) {
            adr = jj*imax+ii;
            p_out->p[adr]=(TT_PTYPE)(pp[jj]);
         }
      }
      tt_free2((void**)&pp,"pp");
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_rgradient_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Gradient rotationnel sur une serie d'images                             */
/***************************************************************************/
/* Realise une gradient radial et circulaire                               */
/* En coordonnees polaires :                                               */
/*   x'(r,a) = (x(r,a) - x(r-dr,a-da)) + (x(r,a) - x(x-dr,a+da))           */
/* (voir Astron. J. 89 (4) P571 1984)                                      */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* radius=0                                                                */
/* angle=0                                                                 */
/* xcenter=0                                                               */
/* ycenter=0                                                               */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int index,naxis1,naxis2;
   int i,j,imax,jmax;
   int ii,jj;
   double v,v1,v2,v3,v4;
   double ic,jc,pir,x1,y1,k1,si,x,y,aa,bb,r,fr,fx,fy,val1,val2;
   double dr,ang;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;

   /* --- in -> out ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   /* --- algo de Qm32 ---*/
   imax=naxis1;
   jmax=naxis2;
   ic=pseries->xcenter-1;
   jc=pseries->ycenter-1;
   dr=pseries->radius;
   ang=pseries->angle;

   pir=(double)(3.1415926/180.0);
   si=(double)-sin(ang*pir);
   for (j=0;j<jmax;j++) {
      y1=(double)(j-jc);
      k1=y1*y1;
      for (i=0;i<imax;i++) {
         x1=(double)(i-ic);
         r=(double)sqrt(k1+x1*x1);
         if (r > (double)fabs(dr)) {
            fr=(double)1.0-dr/r;
            fx=x1*si;
            fy=y1*si;
            x=(double)ic+x1*fr-fy;
            y=(double)jc+y1*fr+fx;
            ii=(int)floor(x);
            jj=(int)floor(y);
            if ((jj >= 0) && (jj < jmax-1) && (ii >= 0) && (ii < imax-1)) {
               aa=x-(double)ii;
               bb=y-(double)jj;
               v1=p_in->p[(int)ii+(int)jj*imax];
               v2=p_in->p[(int)ii+(int)(jj+1)*imax];
               v3=p_in->p[(int)ii+(int)jj*imax+1];
               v4=p_in->p[(int)ii+(int)(jj+1)*imax+1];
               val1=((double)1.0-aa)*((double)1.0-bb)*(double)v1
                +((double)1.0-aa)*bb*(double)v2
                +aa*((double)1.0-bb)*(double)v3
                +aa*bb*(double)v4;
            } else {
               val1=0.;
            }
            x=(double)ic+x1*fr+fy;
            y=(double)jc+y1*fr-fx;
            ii=(int)floor(x);
            jj=(int)floor(y);
            if ((jj >= 0) && (jj < jmax-1) && (ii >= 0) && (ii < imax-1)) {
               aa=x-(double)ii;
               bb=y-(double)jj;
               v1=*(p_in->p+(int)ii+(int)jj*imax);
               v2=*(p_in->p+(int)ii+(int)(jj+1)*imax);
               v3=*(p_in->p+(int)ii+(int)jj*imax+1);
               v4=*(p_in->p+(int)ii+(int)(jj+1)*imax+1);
               val2=((double)1.0-aa)*((double)1.0-bb)*(double)v1
                +((double)1.0-aa)*bb*(double)v2
                +aa*((double)1.0-bb)*(double)v3
                +aa*bb*(double)v4;
            } else {
               val2=0.;
            }
            v1=*(p_in->p+((int)i+(int)j*imax));
            v=2*v1-(double)(val1+val2);
            *(p_out->p+((int)i+(int)j*imax))=(TT_PTYPE)v;
         } else {
            *(p_out->p+((int)i+(int)j*imax))=(TT_PTYPE)pseries->nullpix_value;
         }
      }
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_radial_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Gradient radial lorentzien                                              */
/***************************************************************************/
/* Realise une gradient radial et circulaire                               */
/* En coordonnees polaires :                                               */
/*   x'(r,a) = (x(r,a) - x(r-dr,a-da)) + (x(r,a) - x(x-dr,a+da))           */
/* (voir Astron. J. 89 (4) P571 1984)                                      */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* radius=0                                                                */
/* sigma=10                                                                */
/* power=2                                                                */
/* xcenter=0                                                               */
/* ycenter=0                                                               */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   int index,naxis1,naxis2;
   int i,j,imax,jmax;
   double v,v1;
   double x1,y1,k1,r,ic,jc;
   double radius;
   double sigma,power;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;

   /* --- in -> out ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);

   /* --- algo de Qm32 ---*/
   imax=naxis1;
   jmax=naxis2;
   ic=pseries->xcenter-1;
   jc=pseries->ycenter-1;
   radius=pseries->radius;
   power=pseries->power;
   sigma=pseries->sigma_value;

   for (j=0;j<jmax;j++) {
      y1=(double)(j-jc);
      k1=y1*y1;
      for (i=0;i<imax;i++) {
         x1=(double)(i-ic);
         r=(double)sqrt(k1+x1*x1);
         v1=p_in->p[(int)i+(int)j*imax];
         if (r > radius) {
            v=v1*(1-1/(1+pow(r/sigma,power)));
         } else {
            v=0.;
         }
         *(p_out->p+((int)i+(int)j*imax))=(TT_PTYPE)v;
      }
   }

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

int tt_ima_series_back_1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Modelisation du fond d'une image                                        */
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* radius=0                                                                */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out,*p_tmp1;
   int index,naxis1,naxis2,naxis11,naxis22;
   int dr,nombre,taille,msg,dr2;
   int x_tmp,y_tmp,x_in1,x_in2,y_in1,y_in2,x,y,k,kfond;
   double *v,nulval,val;
   double a[7],ftotal,fmean,threshold;
   int jjmax,iimax,x2,y2,y1,x1,ka,kb,kc,kd,imax,jmax,k2,adr;
   double va,vb,vc,vd,alpha,beta,coef_a,coef_b,coef_c,coef_d,value,yc1,xc1;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   p_tmp1=pseries->p_tmp1;
   index=pseries->index;
   naxis1=p_in->naxis1;
   naxis2=p_in->naxis2;
   nulval=pseries->nullpix_value;
   threshold=pseries->back_threshold;

   /* --- dr est la dimension du cote du pave ---*/
   dr=(int)(fabs(pseries->back_kernel));
   if (dr==0) { dr=(naxis1<naxis2)?naxis1/20:naxis2/20; }
   if (dr<1) { dr=1; }
   dr2=dr/2;
   dr=dr2*2;

   /* --- in -> tmp ---*/
   naxis11=(int)ceil(1.*naxis1/dr)+1;
   naxis22=(int)ceil(1.*naxis2/dr)+1;
   tt_imacreater(p_tmp1,naxis11,naxis22);
   /*
   f=fopen("toto.txt","wt");
   fprintf(f,"naxis11=%d naxis22=%d\n",naxis11,naxis22);
   */
   for (x_tmp=0;x_tmp<naxis11;x_tmp++) {
      x_in1=x_tmp*dr+dr2-dr;
      x_in2=x_tmp*dr+dr2-1;
      if (x_in1<0) { x_in1=0; }
      if (x_in1>=naxis1) { x_in1=naxis1; }
      if (x_in2>=naxis1) { x_in2=naxis1; }
      for (y_tmp=0;y_tmp<naxis22;y_tmp++) {
         y_in1=y_tmp*dr+dr2-dr;
         y_in2=y_tmp*dr+dr2-1;
         if (y_in1<0) { y_in1=0; }
         if (y_in1>=naxis2) { y_in1=naxis2; }
         if (y_in2>=naxis2) { y_in2=naxis2; }
         nombre=(x_in2-x_in1)*(y_in2-y_in1)+1;
         kfond=(int)(threshold*nombre);
         v=NULL;
         taille=sizeof(double);
         if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&v,&nombre,&taille,"v"))!=0) {
            tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_back_1 for pointer v");
            return(TT_ERR_PB_MALLOC);
         }
         k=0;
         for (x=x_in1;x<x_in2;x++) {
            for (y=y_in1;y<y_in2;y++) {
               val=(double)p_in->p[x+y*naxis1];
               if (val!=nulval) {
                  v[k++]=val;
               }
            }
         }
         if (k>0) {
            tt_util_qsort_double(v,0,k,NULL);
            val=v[kfond];
         } else {
            val=nulval;
            adr=x_tmp+(y_tmp-1)*naxis11;
            if (adr>=0) { val=p_tmp1->p[adr]; }
            if (val==nulval) {
               adr=x_tmp-1+y_tmp*naxis11;
               if (adr>=0) { val=p_tmp1->p[adr]; }
            }
         }
         /*fprintf(f,"x_tmp=%2d y_tmp=%2d x_in1=%3d x_in2=%3d y_in1=%3d y_in2=%3d nombre=%3d kfond=%d val=%f\n",x_tmp,y_tmp,x_in1,x_in2,y_in1,y_in2,nombre,kfond,val);*/
         p_tmp1->p[x_tmp+y_tmp*naxis11]=(TT_PTYPE)(val);
         tt_free2((void**)&v,"v");
      }
   }
   /*fclose(f);*/

   /*
   tt_imacreater(p_out,naxis11,naxis22);
   for (x_tmp=0;x_tmp<naxis11;x_tmp++) {
      for (y_tmp=0;y_tmp<naxis22;y_tmp++) {
         p_out->p[x_tmp+y_tmp*naxis11]=(TT_PTYPE)p_tmp1->p[x_tmp+y_tmp*naxis11];
      }
   }
   */

   /* --- tmp -> out ---*/
   /* --- synthese du fond ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   iimax=naxis1;
   jjmax=naxis2;
   imax=naxis11;
   jmax=naxis22;
   a[0]=1./dr;
   a[1]=0;
   a[2]=0;
   a[3]=0;
   a[4]=1./dr;
   a[5]=0;
   k=0;
   ftotal=0.;
   /* - boucle du grand balayage en y -*/
   for (y2=0;y2<jjmax;y2++) {
      /* -  boucle du grand balayage en x -*/
      for (x2=0;x2<iimax;x2++) {
	 xc1=a[0]*x2+a[1]*y2+a[2];
	 yc1=a[3]*x2+a[4]*y2+a[5];
	 y1=(int)floor(yc1);
	 x1=(int)floor(xc1);
	 /*if ((y2==0)&&(x2==0)) {*/
	    alpha=xc1-(double)x1;
	    beta=yc1-(double)y1;
	    coef_a=(1-alpha)*(1-beta);
	    coef_b=(1-alpha)*beta;
	    coef_c=alpha*(1-beta);
	    coef_d=alpha*beta;
	 /*}*/
	 value=nulval;
	 if ((x1>=0)&&(x1<=(imax-1))&&(y1>=0)&&(y1<=(jmax-1))) {
	    ka=x1+y1*imax;
	    kb=x1+(y1+1)*imax;
	    kc=x1+1+y1*imax;
	    kd=x1+1+(y1+1)*imax;
	    va=p_tmp1->p[ka];
	    vb=p_tmp1->p[kb];
	    vc=p_tmp1->p[kc];
	    vd=p_tmp1->p[kd];
	    if ((va!=nulval)&&(vb!=nulval)&&(vc!=nulval)&&(vd!=nulval)) {
	       value=(coef_a*va+coef_b*vb+coef_c*vc+coef_d*vd);
	    }
	 }
	 k2=x2+y2*iimax;
         if (p_in->p[k2]!=nulval) {
   	    p_out->p[k2]=(TT_PTYPE)(value);
            ftotal+=value;
            k++;
         } else {
   	    p_out->p[k2]=(TT_PTYPE)(nulval);
         }
      }
   }

   /* --- Cas : soustraction du fond a l'image originale ---*/
   if (pseries->sub_yesno==TT_YES) {
      fmean=0.;
      if (k>0) { fmean=ftotal/k; }
      for (k=0;k<(naxis1*naxis2);k++) {
         if (p_in->p[k]!=nulval) {
            p_out->p[k]=(TT_PTYPE)(fmean+p_in->p[k]-p_out->p[k]);
         }
      }
   }

   /* --- Cas : soustraction du fond a l'image originale ---*/
   if ((pseries->div_yesno==TT_YES)&&(pseries->sub_yesno==TT_NO)) {
      fmean=0.;
      if (k>0) { fmean=ftotal/k; }
      if (fmean!=0.) {
         for (k=0;k<(naxis1*naxis2);k++) {
            if ((p_in->p[k]!=nulval)&&(p_out->p[k]!=0.)) {
               p_out->p[k]=(TT_PTYPE)(fmean/p_out->p[k]*p_in->p[k]);
            } else {
               p_out->p[k]=(TT_PTYPE)nulval;
            }
         }
      }
   }

   /* --- on reinitialise l'image temporaire ---*/
   tt_imadestroyer(pseries->p_tmp1);
   tt_imabuilder(pseries->p_tmp1);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


/**************************************************************************/
/* Fonction SortX                                                      */
/* arguments possibles : x1,x2,width,percent                                      */
/**************************************************************************/
int tt_ima_series_sortx_1(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int width;
   int x1,x2;
   int x,y;              /* loop variable */
   int temp;             /* temporary variable */
   int diff_x, diff_x_2;
   double *tab=NULL;
   double value;

   char message[TT_MAXLIGNE];
   double percent;
   int taille,msg;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   percent=pseries->percent/100;
   if (percent<0.) {percent=0.;}
   if (percent>1.) {percent=1.;}

   w=p_in->naxis1;
   h=p_in->naxis2;
   width=pseries->width;
   x1=pseries->x1-1;
   x2=pseries->x2-1;


   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,width,p_in->naxis2);


   /* verification des donnees */
   if (width < 0)
   {
         sprintf(message,"width must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if ((x1 < 0) || (x2 < 0) || (x1 >w -1) || (x2 > w-1))
   {
         sprintf(message,"x1 and x2 must be contained between 1 and %d",w);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(x1 > x2)
   {
       temp = x2;
       x2 = x1;
       x1 = temp;
   } /* end of if-statement */

   diff_x = (x2 - x1) + 1;
   diff_x_2 = (int) ((double)diff_x *percent);
	if (diff_x_2>=diff_x) {
		diff_x_2=diff_x-1;
	}

   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tab,&diff_x,&taille,"tab"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_sortx_1 for pointer tab");
      return(TT_ERR_PB_MALLOC);
   }

   /* medianx */
   for(y = 0; y < h;y++)
   {
       for(x = 0;x < diff_x;x++)
       {
           *(tab + x) =
            p_in->p[(x1 + x) + (y * w)];
       } /* end of x-loop */
       tt_util_qsort_double(tab,0,diff_x,NULL);
           value = *(tab + diff_x_2);
       for(x = 0; x < width;x++)
       {
           p_out->p[x + y * width] = (TT_PTYPE)value;
       } /* end of x-loop */
   } /* end of y-loop */

   tt_free(tab,"tab");

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


/**************************************************************************/
/* Fonction SortY                                                      */
/* arguments possibles : y1,y2,height,percent                                     */
/**************************************************************************/
int tt_ima_series_sorty_1(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int height;
   int y1,y2;
   int x,y;              /* loop variable */
   double value;          /* temporary variable */
   int temp;             /* temporary variable */
   int diff_y,diff_y_2;
   double *tab=NULL;

   char message[TT_MAXLIGNE];
   double percent;
   int taille,msg;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   percent=pseries->percent/100;
   if (percent<0.) {percent=0.;}
   if (percent>1.) {percent=1.;}

   w=p_in->naxis1;
   h=p_in->naxis2;
   height=pseries->height;
   y1=pseries->y1-1;
   y2=pseries->y2-1;

   /* --- initialisation ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,height);


   /* verification des donnees */
   if (height < 0)
   {
         sprintf(message,"height must be positive");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if ((y1 < 0) || (y2 < 0) || (y1 >h -1) || (y2 > h-1))
   {
         sprintf(message,"y1 and y2 must be contained between 1 and %d",h);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   } /* end of if-statement */

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   } /* end of if-statement */


   /* mediany */
   diff_y = (y2 - y1) + 1;
   diff_y_2 = (int) ((double)diff_y *percent);
	if (diff_y_2>=diff_y) {
		diff_y_2=diff_y-1;
	}
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tab,&diff_y,&taille,"tab"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_sorty_1 for pointer tab");
      return(TT_ERR_PB_MALLOC);
   }

   for(x = 0; x < w;x++)
   {
       for(y = 0;y < diff_y;y++)
       {
           *(tab + y) = p_in->p[x + ((y + y1) * w)];
       } /* end of x-loop */
       tt_util_qsort_double(tab,0,diff_y,NULL);
           value = *(tab + diff_y_2);
       for(y = 0; y < height;y++)
       {
           p_out->p[x + y * w] = (TT_PTYPE)value;
       } /* end of x-loop */
   } /* end of y-loop */

   tt_free(tab,"tab");

   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}
