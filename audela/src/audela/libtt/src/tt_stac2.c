/* tt_stac2.c
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

int tt_ima_stack_moy_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant une moyenne                                       */
/***************************************************************************/
/***************************************************************************/
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
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_moy_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
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
      value=(nbima0==0)?pstack->nullpix_value:value/nbima0;
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

int tt_ima_stack_sig_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant un ecart type                                     */
/***************************************************************************/
/***************************************************************************/
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
   double i=0.,mu_i=0.,mu_ii=0.,sx_i,sx_ii=0.,delta;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_moy_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      i=0.;mu_i=0.;mu_ii=0.;sx_i=0.;sx_ii=0.;
      for (value=0,nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
    	       /* --- algo de la valeur moy et ecart type de Miller ---*/
	       if (nbima0==0) {mu_i=val;}
	       i=(double) (nbima0+1);
	       delta=val-mu_i;
	       mu_ii=mu_i+delta/(i);
	       sx_ii=sx_i+delta*(val-mu_ii);
	       mu_i=mu_ii;
	       sx_i=sx_ii;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
  	    /* --- algo de la valeur moy et ecart type de Miller ---*/
	    if (nbima0==0) {mu_i=val;}
	    i=(double) (nbima0+1);
	    delta=val-mu_i;
	    mu_ii=mu_i+delta/(i);
	    sx_ii=sx_i+delta*(val-mu_ii);
	    mu_i=mu_ii;
	    sx_i=sx_ii;
	    nbima0++;
	 }
      }
      value=0.;
      if (i!=0.) {
         value=sqrt(sx_ii/i);
      }
      value=(nbima0==0)?pstack->nullpix_value:value;
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

int tt_ima_stack_add_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant une somme                                         */
/***************************************************************************/
/***************************************************************************/
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
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_add_1 (pointer index0)");
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

int tt_ima_stack_med_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant une mediane                                       */
/***************************************************************************/
/***************************************************************************/
{
   int kk,kkk,kmedian;
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
   double *piletri,val;
   int *index,ni;
   int *index0,nbima0,k;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_med_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
   nombre=nbima;
   taille=sizeof(double);
   piletri=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&piletri,&nombre,&taille,"piletri"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_med_1 (pointer piletri)");
      tt_free(index0,"index0");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbima;
   taille=sizeof(int);
   index=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index,&nombre,&taille,"index"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_med_1 (pointer index)");
      tt_free(index0,"index0");tt_free(piletri,"piletri");
      return(TT_ERR_PB_MALLOC);
   }
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      for (nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
	       piletri[nbima0]=val;
	       index[nbima0]=kk;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
	    piletri[nbima0]=val;
	    index[nbima0]=kk;
	    nbima0++;
	 }
      }
      if (nbima0==0) {
	 for (kk=0;kk<nbima;kk++) {
	    poids[kk]+=(poids_pondere/(double)(nbima));
	 }
	 value=pstack->nullpix_value;
      } else {
	 kmedian=(int)(floor(50./100.*((double)nbima0+0.5)));
	 tt_util_qsort_double(piletri,0,nbima0,index);
	 for (ni=0,k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {ni++;}
	 }
	 if (ni==0) {ni=1;}
	 for (k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {poids[index[k]]+=(poids_pondere/ni);}
	 }
	 value=piletri[kmedian];
      }
      p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(value);
   }
   tt_free(piletri,"piletri");
   tt_free(index,"index");
   tt_free(index0,"index0");
   return(OK_DLL);
}

int tt_ima_stack_sort_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant un tri                                            */
/***************************************************************************/
/* 1) Les valeurs sont triees dans l'ordre croissant,                      */
/* 2) Le pixel de l'image finale se voit affect‚ la valeur choisie a       */
/*    'percent' pourcent dans les valeurs triees.                          */
/* si percent=0   : l'image finale sera le minimum des pixels.             */
/* si percent=50  : l'image finale sera la mediane des pixels (donc        */
/*                  rigoureusement equivalent a tt_ima_stack_med_1).       */
/* si percent=100 : l'image finale sera le maximum des pixels.             */
/*                                                                         */
/***************************************************************************/
{
   int kk,kkk,kmedian;
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
   double *piletri;
   int *index,ni;
   double val;
   int *index0,nbima0,k;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sort_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
   nombre=nbima;
   taille=sizeof(double);
   piletri=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&piletri,&nombre,&taille,"piletri"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sort_1 (pointer piletri)");
      tt_free(index0,"index0");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbima;
   taille=sizeof(int);
   index=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index,&nombre,&taille,"index"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sort_1 (pointer index)");
      tt_free(index0,"index0");tt_free(piletri,"piletri");
      return(TT_ERR_PB_MALLOC);
   }
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      for (nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
	       piletri[nbima0]=val;
	       index[nbima0]=kk;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
	    piletri[nbima0]=val;
	    index[nbima0]=kk;
	    nbima0++;
	 }
      }
      if (nbima0==0) {
	 for (kk=0;kk<nbima;kk++) {
	    poids[kk]+=(poids_pondere/(double)(nbima));
	 }
	 value=pstack->nullpix_value;
      } else {
	 kmedian=(int)(floor(pstack->percent/100.*((double)nbima0+0.5)));
	 kmedian=(kmedian<0)?0:kmedian;
	 kmedian=(kmedian>=nbima0)?nbima0-1:kmedian;
	 tt_util_qsort_double(piletri,0,nbima0,index);
	 for (ni=0,k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {ni++;}
	 }
	 if (ni==0) {ni=1;}
	 for (k=0;k<nbima0;k++) {
	    if (piletri[k]==piletri[kmedian]) {poids[index[k]]+=(poids_pondere/ni);}
	 }
	 value=piletri[kmedian];
      }
      p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(value);
   }
   tt_free(piletri,"piletri");
   tt_free(index,"index");
   tt_free(index0,"index0");
   return(OK_DLL);
}

int tt_ima_stack_sk_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
/* - mots optionels utilisables et valeur par defaut :                     */
/* kappa = 3                                                               */
/***************************************************************************/

{
   int kk,kkk;
   double poids_pondere,value,val;
   int base_adr;
   TT_IMA *p_tmp=pstack->p_tmp;
   TT_IMA *p_out=pstack->p_out;
   long firstelem=pstack->firstelem;
   long nelements=pstack->nelements;
   long nelem=pstack->nelem;
   long nelem0=pstack->nelem0;
   int nbima=pstack->nbima;
   double *poids=pstack->poids;
   double kappa=pstack->kappa;
   double ks_moyenne,ks_sigma,ks_dif;
   int ks_nbpoints,nbima0;
   int *index0;
   int nombre,taille,msg;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_sk_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
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
      /* --- condition no-filling ---*/
      /*
      for (kk=0;kk<nbima;kk++) {
	 if (index0[kk]==TT_NO) {
	    for (k=0;k<nbima;k++) {
	       index0[k]=TT_NO;
	    }
	    nbima0=0;
	    break;
	 }
      }
      */
      ks_moyenne=(nbima0==0)?pstack->nullpix_value:value/nbima0;
      ks_sigma=0.;
      for (value=0,kk=0;kk<nbima;kk++) {
	 if (index0[kk]==TT_YES) {
	    base_adr=(int)(nelem0)*kk;
	    ks_dif=(ks_moyenne-(double)(p_tmp->p[base_adr+kkk]));
	    value+=(ks_dif*ks_dif);
	 }
      }
      ks_sigma=(nbima0==0)?0.:sqrt(value/(double)nbima0);
      ks_nbpoints=0;
      for (value=0,kk=0;kk<nbima;kk++) {
	 if (index0[kk]==TT_YES) {
	    base_adr=(int)(nelem0)*kk;
	    ks_dif=fabs(ks_moyenne-(double)(p_tmp->p[base_adr+kkk]));
	    if (ks_dif<=(kappa*ks_sigma)) {
	       value+=(double)(p_tmp->p[base_adr+kkk]);
	       ks_nbpoints++;
	    }
	 }
      }
      if (ks_nbpoints==0) {
	 for (kk=0;kk<nbima;kk++) {
	    poids[kk]+=(nbima0==0)?(poids_pondere/(double)(nbima)):(poids_pondere/(double)(nbima0));
	 }
      } else {
	 for (kk=0;kk<nbima;kk++) {
	    if (index0[kk]==TT_YES) {
	       base_adr=(int)(nelem0)*kk;
	       ks_dif=fabs(ks_moyenne-(double)(p_tmp->p[base_adr+kkk]));
	       if (ks_dif<=(kappa*ks_sigma)) {
		  poids[kk]+=(poids_pondere/(double)(ks_nbpoints));
	       }
	    }
	 }
	 ks_moyenne=value/ks_nbpoints;
	 if (nbima0==0) {
	    for (kk=0;kk<nbima;kk++) {
	       poids[kk]+=(poids_pondere/(double)(nbima));
	    }
	 }
      }
      p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(ks_moyenne);
   }
   tt_free(index0,"index0");
   return(OK_DLL);
}

int tt_ima_stack_shutter_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement de flats de temps de pose differents qui retourne le delais  */
/* d'ouverture de l'obturateur                                             */
/***************************************************************************/
/***************************************************************************/
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
   double *piletri,val;
   int *index;
   int *index0,nbima0,k;
   int nombre,taille,msg;
   double *x,*y,a,b;
   double s,sxx,sxy,sx,sy,delta,covb;

   nombre=nbima;
   taille=sizeof(int);
   index0=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index0,&nombre,&taille,"index0"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_shutter_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(1.)/(double)(nelements);
   nombre=nbima;
   taille=sizeof(double);
   piletri=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&piletri,&nombre,&taille,"piletri"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_shutter_1 (pointer piletri)");
      tt_free(index0,"index0");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbima;
   taille=sizeof(int);
   index=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index,&nombre,&taille,"index"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_shutter_1 (pointer index)");
      tt_free(index0,"index0");tt_free(piletri,"piletri");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbima;
   taille=sizeof(double);
   x=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&x,&nombre,&taille,"x"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_shutter_1 (pointer x)");
      tt_free(index0,"index0");tt_free(piletri,"piletri");tt_free(piletri,"index");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbima;
   taille=sizeof(double);
   y=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&y,&nombre,&taille,"y"))!=0) {
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_shutter_1 (pointer y)");
      tt_free(index0,"index0");tt_free(piletri,"piletri");tt_free(piletri,"index");
      tt_free(piletri,"x");
      return(TT_ERR_PB_MALLOC);
   }
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      for (nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
	       piletri[nbima0]=val;
	       index[nbima0]=kk;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
	    piletri[nbima0]=val;
	    index[nbima0]=kk;
            x[nbima0]=pstack->exptimes[kk];
            y[nbima0]=val;
	    nbima0++;
	 }
      }
      if (nbima0==0) {
	 for (kk=0;kk<nbima;kk++) {
	    poids[kk]+=(poids_pondere/(double)(nbima));
	 }
	 value=pstack->nullpix_value;
      } else {
         s=sxx=sxy=sx=sy=delta=0.;
	 for (k=0;k<nbima0;k++) {
            /* calcul de flux=a*exposure+b */
            s+=1.;
            sxx+=x[k]*x[k];
            sxy+=x[k]*y[k];
            sx+=x[k];
            sy+=y[k];
	 }
         delta=s*sxx-sx*sx;
         covb=0.;
         if (fabs(delta)<=TT_EPS_DOUBLE) {
            a=0.;
            b=0.;
         } else {
            b=(sxx*sy-sx*sxy)/delta;
            a=(s*sxy-sx*sy)/delta;
            covb=sqrt(fabs(sxx/delta));
         }
	 /*poids[index[k]]+=(poids_pondere/nbima0);*/
         if (fabs(a)<=TT_EPS_DOUBLE) {
            value=pstack->nullpix_value;
         } else {
            value=-b/a;
         }
      }
      p_out->p[(int)(firstelem)+kkk]=(TT_PTYPE)(value);
   }
   tt_free(piletri,"piletri");
   tt_free(index,"index");
   tt_free(index0,"index0");
   tt_free(x,"x");
   tt_free(y,"y");
   return(OK_DLL);
}

int tt_ima_stack_prod_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant un produit                                        */
/***************************************************************************/
/***************************************************************************/
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
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_add_1 (pointer index0)");
      return(TT_ERR_PB_MALLOC);
   }
   poids_pondere=(double)(nbima)/(double)(nelements);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
       for (value=1,nbima0=0,kk=0;kk<nbima;kk++) {
	 base_adr=(int)(nelem0)*kk;
	 val=(double)(p_tmp->p[base_adr+kkk]);
	 if (pstack->nullpix_exist==TT_YES) {
	    if (val>pstack->nullpix_value) {
	       index0[kk]=TT_YES;
	       value*=val;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
	    value*=val;
	    nbima0++;
	 }
      }
      if (nbima==0) {
          value=pstack->nullpix_value;
      } else {
           if (nbima!=nbima0) {
              if (value>0) {
                 value=pow(value,((double)(nbima0)/(double)(nbima)));
              }
           }
           if (pstack->powernorm==1) {
              if (value<=0) {
                 value=0.;
              } else{
                 value=pow(value,(double)(1./nbima0));
              }
           }
      }
      //value=(nbima0==0)?pstack->nullpix_value:value*((double)(nbima)/(double)(nbima0));
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

int tt_ima_stack_pythagore_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant une formule de Pythagore sqrt(i1^2+i2^2+...)      */
/***************************************************************************/
/***************************************************************************/
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
      tt_errlog(pstack->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_ima_stack_add_1 (pointer index0)");
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
	       value+=val*val;
	       nbima0++;
	    } else {
	       index0[kk]=TT_NO;
	    }
	 } else {
	    index0[kk]=TT_YES;
	    value+=val*val;
	    nbima0++;
	 }
      }
      value=(nbima0==0)?pstack->nullpix_value:sqrt(value)*((double)(nbima)/(double)(nbima0));
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

int tt_ima_stack_drizzlewcs_1(TT_IMA_STACK *pstack)
/***************************************************************************/
/* Empilement en faisant un drizzle WCS                                    */
/***************************************************************************/
/***************************************************************************/
{
   TT_IMA *p_in=pstack->p_in;
   TT_IMA *p_tmp=pstack->p_tmp;
   TT_IMA *p_out=pstack->p_out;
   TT_IMA *p_tmpout=pstack->p_tmpout;
   long firstelem=pstack->firstelem;
   long nelements=pstack->nelements;
   long nelem=pstack->nelem;
   long nelem0=pstack->nelem0;
   int nbima=pstack->nbima;
   double *poids=pstack->poids;
   int adr,adr2;
   double drop_pixsize=pstack->drop_pixsize;
   double oversampling=pstack->oversampling;
   int imax,jmax,imax2,jmax2,ii,jj,i,j,i2,j2,jk,ik;
   int msg,k,kima;
   float x2,y2;
   double resolution,surech,c,wij,sij,v,w,intensite;
   double trans_x,trans_y;
   double xa,xb,ya,yb;
   TT_ASTROM p_ast;
   double x[4],y[4],xp[4],yp[4],ra[4],dec[4],delta;
   double a[6],aa[6];

   imax=p_tmp->naxis1;
   jmax=p_tmp->naxis2;
   imax2=p_out->naxis1;
   jmax2=p_out->naxis2;
   kima=pstack->kima;
   resolution=pstack->oversampling;
   surech=1./pstack->drop_pixsize;
   if (surech<1) { surech = 1; }
   if (surech>2) { surech = 2; }
   c=surech/2;
   wij=1./(surech*surech);

   /* --- WCS ---*/
   msg=tt_util_getkey_astrometry(p_in,&p_ast);
   xp[1]=pstack->p_ast.crpix1;
   yp[1]=pstack->p_ast.crpix2;
   xp[2]=pstack->p_ast.crpix1+0.4*p_tmp->naxis1;
   yp[2]=pstack->p_ast.crpix2;
   xp[3]=pstack->p_ast.crpix1;
   yp[3]=pstack->p_ast.crpix2+0.4*p_tmp->naxis2;
   for (k=1;k<=3;k++) {
      tt_util_astrom_xy2radec(&pstack->p_ast,xp[k],yp[k],&ra[k],&dec[k]);
   }
   for (k=1;k<=3;k++) {
      tt_util_astrom_radec2xy(&p_ast,ra[k],dec[k],&x[k],&y[k]);
   }
   delta = (y[1]-y[2])*(x[3]-x[2]) - (y[3]-y[2])*(x[1]-x[2]);
   a[1] = ( (x[3]-x[2])*(xp[1]-xp[2]) - (x[1]-x[2])*(xp[3]-xp[2]) ) / delta;
   a[0] = ( - (y[3]-y[2])*(xp[1]-xp[2]) + (y[1]-y[2])*(xp[3]-xp[2]) ) / delta;
   a[2] = xp[1] - a[0]*x[1] - a[1]*y[1];
   a[4] = ( (x[3]-x[2])*(yp[1]-yp[2]) - (x[1]-x[2])*(yp[3]-yp[2]) ) / delta;
   a[3] = ( - (y[3]-y[2])*(yp[1]-yp[2]) + (y[1]-y[2])*(yp[3]-yp[2]) ) / delta;
   a[5] = yp[1] - a[3]*x[1] - a[4]*y[1];
   delta=a[1]*a[3]-a[0]*a[4];
   aa[0]=-a[4]/delta;
   aa[1]= a[1]/delta;
   aa[2]=-(a[1]*a[5]-a[2]*a[4])/delta;
   aa[3]= a[3]/delta;
   aa[4]=-a[0]/delta;
   aa[5]=-(a[2]*a[3]-a[0]*a[5])/delta;
   trans_x=-aa[2];
   trans_y=-aa[5];

   for (j=0;j<jmax;j++) {
      adr=(int)j*imax;
      y2=(float)(resolution*(j+trans_y)+.5);
      j2=(int)y2;
      for (i=0;i<imax;i++) {
	 intensite=(double)p_tmp->p[adr+i];
	 if (pstack->nullpix_exist==TT_YES) {
	    if (intensite==pstack->nullpix_value) {
	       continue;
	    }
	 }
	 x2=(float)(resolution*(i+trans_x)+.5);
	 i2=(int)x2;
	 for (jk=-1;jk<=1;jk++) {
	    jj=j2+jk;
	    if (jj<0) { break ; }
	    if (jj>jmax2-1) { break ; }
            adr2=(int)jj*imax2;
	    for (ik=-1;ik<=1;ik++) {
	       ii=i2+ik;
	       if (ii<0) { break ; }
	       if (ii>imax2-1) { break ; }
	       xa=x2-c ; if ((double)ii>xa) { xa=(double)ii; }
	       xb=x2+c ; if ((double)(ii+1)<xb) { xb=(double)(ii+1); }
	       ya=y2-c ; if ((double)ii>ya) { ya=(double)jj; }
	       yb=y2+c ; if ((double)(ii+1)<yb) { yb=(double)(jj+1); }
	       if (xb>xa && yb>ya) {
		  sij=(xb-xa)*(yb-ya)*wij;
		  v=(double)p_out->p[adr2+ii];
		  w=(double)p_tmpout->p[adr2+ii];
		  p_tmpout->p[adr2+ii]=(TT_PTYPE)(w+sij);
		  p_out->p[adr2+ii]=(TT_PTYPE)((v*w+sij*intensite)/(w+sij));
	       }
	    }
	 }
      }
   }

   if (kima==1) {
      a[0]=1./resolution;
      a[1]=0.;
      a[2]=0.;
      a[3]=0.;
      a[4]=1./resolution;
      a[5]=0.;
      /* --- calcule les nouveaux parametres de projection ---*/
      tt_util_update_wcs(p_in,p_out,a,2,NULL);
   }

   return(OK_DLL);
}
