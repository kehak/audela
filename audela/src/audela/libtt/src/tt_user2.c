/* tt_user2.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Benjamin MAUCLAIRE <bmauclaire@underlands.org>
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

/***** prototypes des fonctions internes du user2 ***********/
int tt_ima_stack_2_tutu(TT_IMA_STACK *pstack);

int tt_ima_series_profile2(TT_IMA_SERIES *pseries);
int tt_ima_series_lopt(TT_IMA_SERIES *pseries);
int tt_ima_series_lopt5(TT_IMA_SERIES *pseries);
int tt_ima_series_smoothsg(TT_IMA_SERIES *pseries);
int tt_ima_series_colorspectrum(TT_IMA_SERIES *pseries);


/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user2 pour IMA/SERIES                  */
/**************************************************************************/
/**************************************************************************/

int tt_user2_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"PROFILE2")==0) { pseries->numfct=TT_IMASERIES_USER2_PROFILE2; }
   else if (strcmp(keys10,"LOPT")==0) { pseries->numfct=TT_IMASERIES_USER2_LOPT; }
   else if (strcmp(keys10,"LOPT5")==0) { pseries->numfct=TT_IMASERIES_USER2_LOPT5; }
   else if (strcmp(keys10,"SMOOTHSG")==0) { pseries->numfct=TT_IMASERIES_USER2_SMOOTHSG; }
   else if (strcmp(keys10,"COLORSPECTRUM")==0) { pseries->numfct=TT_IMASERIES_USER2_COLOR_SPECTRUM; }
   return(OK_DLL);
}

int tt_user2_ima_series_builder2(TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   options->user2.y1=1;
   options->user2.y2=1;
   options->user2.height=20;
   strcpy(options->user2.direction,"x");
   strcpy(options->user2.filename,"profil.dat");
   options->user2.nl=16;
   options->user2.nr=16;
   options->user2.ld=0;
   options->user2.m =2;
   options->user2.wavelengthmin=3800;
   options->user2.wavelengthmax=7800;
   options->user2.xmin=-1;
   options->user2.xmax=-1;
   return(OK_DLL);
}

int tt_user2_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"Y1")==0) {
      options->user2.y1=(int)(atof(argu));
   } else if (strcmp(mot,"Y2")==0) {
      options->user2.y2=(int)(atof(argu));
   } else if (strcmp(mot,"HEIGHT")==0) {
      options->user2.height=(int)(atof(argu));
   } else if (strcmp(mot,"DIRECTION")==0) {
      strcpy(options->user2.direction,argu);
   } else if (strcmp(mot,"FILENAME")==0) {
      strcpy(options->user2.filename,argu);
   } else if (strcmp(mot,"NL")==0) {
      options->user2.nl=(int)(atof(argu));
   } else if (strcmp(mot,"NR")==0) {
      options->user2.nr=(int)(atof(argu));
   } else if (strcmp(mot,"LD")==0) {
      options->user2.ld=(int)(atof(argu));
   } else if (strcmp(mot,"M")==0) {
      options->user2.m=(int)(atof(argu));
   } else if (strcmp(mot,"WAVELENGTHMIN")==0) {
      options->user2.wavelengthmin=atof(argu);
   } else if (strcmp(mot,"WAVELENGTHMAX")==0) {
      options->user2.wavelengthmax=atof(argu);
   } else if (strcmp(mot,"XMIN")==0) {
      options->user2.xmin=atoi(argu);
   } else if (strcmp(mot,"XMAX")==0) {
      options->user2.xmax=atoi(argu);
   }
   return(OK_DLL);
}

int tt_user2_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pseries->numfct==TT_IMASERIES_USER2_PROFILE2) {
      *msg=tt_ima_series_profile2(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER2_LOPT) {
      *msg=tt_ima_series_lopt(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER2_LOPT5) {
      *msg=tt_ima_series_lopt5(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER2_SMOOTHSG) {
      *msg=tt_ima_series_smoothsg(pseries);
      *fct_found=TT_YES;
   }
   else if (pseries->numfct==TT_IMASERIES_USER2_COLOR_SPECTRUM) {
      *msg=tt_ima_series_colorspectrum(pseries);
      *fct_found=TT_YES;
   }

   return(OK_DLL);
}

/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user2 pour IMA/STACK                   */
/**************************************************************************/
/**************************************************************************/

int tt_user2_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"TUTU")==0) { pstack->numfct=TT_IMASTACK_USER2_TUTU; }
   return(OK_DLL);
}

int tt_user2_ima_stack_builder2(TT_IMA_STACK *pstack)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   pstack->user2.param1=0.;
   return(OK_DLL);
}

int tt_user2_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   if (strcmp(mot,"TUTU_PARAM")==0) {
      pstack->user2.param1=(double)(atof(argu));
   }
   return(OK_DLL);
}

int tt_user2_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pstack->numfct==TT_IMASTACK_USER2_TUTU) {
      *msg=tt_ima_stack_2_tutu(pstack);
      *fct_found=TT_YES;
   }
   return(OK_DLL);
}

/**************************************************************************/
/**************************************************************************/
/* exemple de la fonction user TUTU implantee dans IMA/STACK              */
/**************************************************************************/
/* Pile d'addition d'image (equivalent a ADD2 de Qmips32).                */
/* Subtil tour de force pour tenir compte des pixels non definis et pour  */
/* calculer l'heure de l'image synthetisee au prorata des images.         */
/**************************************************************************/
int tt_ima_stack_2_tutu(TT_IMA_STACK *pstack)
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


/**************************************************************************/
/* Fonction Profil                                                        */
/* Modifee par Benji                                                      */
/* arguments possibles:direction,nom du fichier,offset                    */
/**************************************************************************/
int tt_ima_series_profile2(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;

   int w, h;
   int i,x,y;              /* loop variable */
   int offset;
   FILE *file;

   char message[TT_MAXLIGNE];


   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   w=p_in->naxis1;
   h=p_in->naxis2;
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for(x = 0; x < w;x++)
   {
       for(y = 0;y < h;y++)
       {
           p_out->p[x + y * w] =  p_in->p[x + y * w];
       } /* end of y-loop */
   } /* end of x-loop */
   index=pseries->index;
   offset=(int)pseries->offset-1;

    /* verification des donnees */
   if((strcmp(pseries->user2.direction,"x")!=0)&&(strcmp(pseries->user2.direction,"y")!=0))
   {
         sprintf(message,"direction must be x or y");
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   }


   if(strcmp(pseries->user2.direction,"x")==0)
   {
   	if (offset < 0)
   	{
         sprintf(message,"offset must be contained between 1 and %d",w);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   	} /* end of if-statement */
   }
   else if (strcmp(pseries->user2.direction,"y")==0)
   	if (offset < 0)
   	{
         sprintf(message,"offset must be contained between 1 and %d",h);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
   	} /* end of if-statement */

   /* write in a file */
   file = fopen(pseries->user2.filename,"wt");
   /*   fprintf(file,"%s"\n","pixel            value of the pixel");*/
   /* Pas de label des colonnes. BM 20/06/2006 */
   /* fprintf(file,"%s\t%s\n","pixel","value of the pixel"); */
   /* fprintf(file,"%d\t%f\n",0,0.0); */
   if(strcmp(pseries->user2.direction,"x")==0)
   {
       for(i = 0;i < w;i++)
       fprintf(file,"%d\t%f\n",(i+1),p_in->p[i + offset * w]);
   }
   else
   {
       for(i = 0;i < h;i++)
       fprintf(file,"%d\t%f\n",(i+1),p_in->p[i * w + offset]);
   }
   fclose(file);


   /* --- calcul des temps (pour l'entete fits) ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}


/**************************************************************************/
/* Fonction lopt                                                          */
/* arguments possibles : y1,y2,height                                     */
/* D'apres la routine de IRIS */
/**************************************************************************/
/******************************* L_OPT **********************************/
/* Calcul la somme normalisee et optimise entre les lignes lmax et lmin */
/* Version simpliflie sans rejection des pixels aberrants               */
/* Variance constante (independante du signal)                          */
/* Dans ce cas                                                          */
/*    F = S(P.(D-ciel)) / S(P . P)                                      */
/*                                                                      */
/* Voir J. G. Robertson, PASP 98, 1220-1231, November 1986              */
/* V5.0 -> calcul d'une fonction de poids locale                        */
/************************************************************************/
int tt_ima_series_lopt(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   int index;
   int imax,jmax,lmin,lmax;
   int hauteur;
   int temp;             /* temporary variable */
   double *f=NULL,*P=NULL;
   int nb;
   int i,j,k;
   double max,somme,norme;
   double v,w,s;
   double vv[50];

   char message[TT_MAXLIGNE];
   int taille,msg;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   imax=p_in->naxis1;
   jmax=p_in->naxis2;

   hauteur=pseries->user2.height; // HEIGHT
   lmin=pseries->user2.y1-1; // Y1
   lmax=pseries->user2.y2-1; // Y2

   /* verification des donnees */
   if (hauteur < 0) {
      sprintf(message,"height must be positive");
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }
   if ((lmin < 2) || (lmax < 2) || (lmin >jmax -2) || (lmax > jmax-2)) {
      sprintf(message,"y1 and y2 must be contained between 3 and %d",jmax-2);
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }
   if(lmin > lmax) {
      temp = lmax;
      lmax = lmin;
      lmin = temp;
   }
   if ((lmax-lmin) < 4) {
      strcpy(message,"y2-y1 must be highter than 4");
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }

   /* Profil spectral monodimentionnel (f)*/
   taille=sizeof(double);
   nb=(int)(imax);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&f,&nb,&taille,"f"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_mediany2 for pointer f");
      return(TT_ERR_PB_MALLOC);
   }

   /* Modele profil spectral colonne (P)*/
   taille=sizeof(double);
   nb=(int)(lmax-lmin+1);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&P,&nb,&taille,"P"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_mediany2 for pointer P");
      tt_free(f,"f");
      return(TT_ERR_PB_MALLOC);
   }

   /* --- initialisation ---*/
   tt_imacreater(p_out,imax,hauteur);

   /*/////////////////////////////////////*/
   /*/ Calcul du profil spectral optimise */
   /*/////////////////////////////////////*/
   max=-1e10;

   /* On gere les 3 premieres colonnes*/
   for (i=0;i<3;i++) {
      somme=0.0;
      k=0;

      /* Calcul de la fonction de poids */
      for (j=lmin-1;j<lmax;j++,k++) {
         P[k]=(double)p_in->p[j*imax+i];
      }

      /* La fonction de poids est rendue strictement positive et normalisee */
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         if (P[k]<0) P[k]=0;
         s=s+P[k];
      }
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         if (s==0) {
            P[k]=0.;
         } else {
            P[k]=P[k]/s;
         }
      }

      /* Calcul de la norme */
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         s=s+P[k]*P[k];
      }
      norme=s;

      /* Calcul du profil optimise */
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         v=(double)p_in->p[j*imax+i];
         w=P[k];
         somme+=w*v;
      }
      if (norme==0) {
         f[i]=0.;
      } else {
         f[i]=somme/norme;
      }
      if (f[i]>max) max=f[i];
   }

   /* On gere les 3 dernieres colonne */
   i=imax-3;
   for (i=imax-3;i<imax;i++) {
      somme=0.0;
      k=0;
      /* Calcul de la fonction de poids*/
      for (j=lmin-1;j<lmax;j++,k++) {
         P[k]=(double)p_in->p[j*imax+i];
      }

      /* La fonction de poids est rendue strictement positive et normalisee*/
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         if (P[k]<0) P[k]=0;
         s=s+P[k];
      }
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         if (s==0) {
            P[k]=0.;
         } else {
            P[k]=P[k]/s;
         }
      }

      /* Calcul de la norme */
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         s=s+P[k]*P[k];
      }
      norme=s;

      /* Calcul du profil optimise */
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         v=(double)p_in->p[j*imax+i];
         w=P[k];
         somme+=w*v;
      }
      if (norme==0) {
         f[i]=0.;
      } else {
         f[i]=somme/norme;
      }
      if (f[i]>max) max=f[i];
   }

   /* On gere le reste du profil... */
   for (i=3;i<imax-3;i++) {
      somme=0.0;
      k=0;
      /* Calcul de la fonction de poids = mediane sur 7 colonnes */
      for (j=lmin-1;j<lmax;j++,k++) {
         vv[0]=(double)p_in->p[j*imax+i-3];
         vv[1]=(double)p_in->p[j*imax+i-2];
         vv[2]=(double)p_in->p[j*imax+i-1];
         vv[3]=(double)p_in->p[j*imax+i];
         vv[4]=(double)p_in->p[j*imax+i+1];
         vv[5]=(double)p_in->p[j*imax+i+2];
         vv[6]=(double)p_in->p[j*imax+i+3];
         tt_util_qsort_double(vv,0,6,NULL);
         P[k]=vv[3];
      }

      /* La fonction de poids est rendue strictement positive et normalisee */
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         if (P[k]<0) P[k]=0;
         s=s+P[k];
      }
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         if (s==0) {
            P[k]=0.;
         } else {
            P[k]=P[k]/s;
         }
      }

      /* Calcul de la norme */
      s=0;
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         s=s+P[k]*P[k];
      }
      norme=s;

      /* Calcul du profil optimise */
      k=0;
      for (j=lmin-1;j<lmax;j++,k++) {
         v=(double)p_in->p[j*imax+i];
         w=P[k];
         somme+=w*v;
      }
      if (norme==0) {
         f[i]=0.;
      } else {
         f[i]=somme/norme;
      }
      if (f[i]>max) max=f[i];
   }

   /* Normalisation du profil a 32767 non faite */
   /*max=32767.0/max;*/
   max=1.;
   for (i=0;i<imax;i++) {
      for (j=0;j<hauteur;j++) {
        if (f[i]>0) {
          p_out->p[j*imax+i]=(TT_PTYPE)(f[i]*max);
        } else {
          /* Les valeurs "nan" sont mises egales a 0 */
          p_out->p[j*imax+i]=(TT_PTYPE)(0);
        }
      }
   }

   tt_free(f,"f");
   tt_free(P,"P");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

/**************************************************************************/
/* Fonction lopt5                                                          */
/* arguments possibles : y1,y2,height                                     */
/* D'apres la routine de IRIS */
/**************************************************************************/
/* Voir J. G. Robertson, PASP 98, 1220-1231, November 1986              */
/************************************************************************/
/************************************************* L_OPT5 ************************************************/
// Implémentation raisonnable de l'algo de HORNES. 
// Le profil spatial du spectre (axe vertical) est obtenu localement par une moyenne médiane.
// On se sert de la somme de toutes les images (produit 0b, décrit par lez paramètre p2) pour calculer la 
// le profil vertical du spectre. La distribution est alors mieux défini. L'image 2à traiter est p 
// (un sous-ensemble de p2).
// Le paramètre COEF est le coefficient de réjection des cosmiques. Une valeur typique est comprise 
// entre 20 et 100. Une valeur inférieure peut conduite à un lissage du spectre perceptible à haut SNR
/********************************************************************************************************/
int tt_ima_series_lopt5(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out,*p_tmp1;
   int index;
   int imax,jmax,lmin,lmax;
   int hauteur;
   int temp;             /* temporary variable */
   double *f=NULL,*P=NULL,*P2=NULL,*V=NULL,*M=NULL;
   int nb;
   int i,j,k;
   double max,somme,norme;
   double v,w,s;
   double vv[50];
   double vv2[50];
	int largeur2 = 2;  // demi-largeur de calcul local de la médiane (médiane sur 2 x 2 + 1 pixels - codé en dur pour le moment)
	long nelem,firstelem,nelem_tmp;
	int kkk;
   char fullname[(FLEN_FILENAME)+5];
   // Bruit caméra caractéristique (Atik314L+) - codé en dur pour le moment, mais caractéristique
   double RON = 4.3; // en e-
   double gain = 0.255; // en e-/ADU
   double E = 0.0,coef;
	int it,m;
	int adr = 0;

   char message[TT_MAXLIGNE];
   int taille,msg;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_tmp1=pseries->p_tmp1;
   p_out=pseries->p_out;
   index=pseries->index;
   imax=p_in->naxis1;
   jmax=p_in->naxis2;
   nelem=pseries->nelements;

	// FILE
   hauteur=pseries->user2.height; // HEIGHT
   lmin=pseries->user2.y1-1; // Y1
   lmax=pseries->user2.y2-1; // Y2
   coef=pseries->cosmicThreshold; // COSMIC_THRESHOLD

   /* verification des donnees */
   if (hauteur < 0) {
      sprintf(message,"height must be positive");
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }
   if ((lmin < 2) || (lmax < 2) || (lmin >jmax -2) || (lmax > jmax-2)) {
      sprintf(message,"y1 and y2 must be contained between 3 and %d",jmax-2);
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }
   if(lmin > lmax) {
      temp = lmax;
      lmax = lmin;
      lmin = temp;
   }
   if ((lmax-lmin) < 4) {
      strcpy(message,"y2-y1 must be highter than 4");
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }

	tt_imacreater(p_tmp1,p_in->naxis1,p_in->naxis2);
	if ((strcmp(pseries->file,"file.fit")==0)||(strcmp(pseries->file,".")==0)) {
	   /* --- in -> tmp1 ---*/
		for (kkk=0;kkk<(int)(nelem);kkk++) {
			p_tmp1->p[kkk]=p_in->p[kkk];
		}
	} else {
	   /* --- charge l'image file dans p_tmp1---*/
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

   /* Profil spectral monodimentionnel (f)*/
   taille=sizeof(double);
   nb=(int)(imax);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&f,&nb,&taille,"f"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_lopt5 for pointer f");
      return(TT_ERR_PB_MALLOC);
   }

   /* Modele profil spectral colonne (P)*/
   taille=sizeof(double);
   nb=(int)(lmax-lmin+1);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&P,&nb,&taille,"P"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_lopt5 for pointer P");
      tt_free(f,"f");
      return(TT_ERR_PB_MALLOC);
   }

   /* Modele profil spectral colonne (P2)*/
   taille=sizeof(double);
   nb=(int)(lmax-lmin+1);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&P2,&nb,&taille,"P2"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_lopt5 for pointer P2");
      tt_free(f,"f");
      tt_free(P,"P");
      return(TT_ERR_PB_MALLOC);
   }

   /* Modele profil spectral colonne (V)*/
   taille=sizeof(double);
   nb=(int)(lmax-lmin+1);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&V,&nb,&taille,"V"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_lopt5 for pointer V");
      tt_free(f,"f");
      tt_free(P,"P");
      tt_free(P2,"P2");
      return(TT_ERR_PB_MALLOC);
   }

   /* Modele profil spectral colonne (M)*/
   taille=sizeof(double);
   nb=(int)(lmax-lmin+1);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&M,&nb,&taille,"M"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_lopt5 for pointer M");
		tt_free(f,"f");
		tt_free(P,"P");
		tt_free(P2,"P2");
		tt_free(V,"V");
      return(TT_ERR_PB_MALLOC);
   }

   /* --- initialisation ---*/
   tt_imacreater(p_out,imax,hauteur);

   // ----------------------------------------------------
   // On gère les largeur2 premières colonnes (peu critique)
   // Algorithme simplifié (pas de détection de cosmique)
   // ----------------------------------------------------
   for (i = 0; i < largeur2; i++)
   {
       k = 0;
       // Calcul de la fonction de poids
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           //P2[k] = (double)p2.pic[j * imax + i];
           P2[k] = (double)p_tmp1->p[j * imax + i];			  
       }

       // La fonction de poids est rendue strictement positive et normalisée
       s = 0;
       k = 0;
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           if (P2[k] < 0) P2[k] = 0;
           s = s + P2[k];
       }
       k = 0;
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           P2[k] = P2[k] / s;
       }

       // Calcul de la norme
       s = 0;
       k = 0;
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           s = s + P2[k] * P2[k];
       }
       norme = s;

       // Calcul du profil optimisé
       somme = 0;
       //if (norme != 0.0 && !double.IsNaN(norme))
       if (norme != 0.0 )
       {
           k = 0;
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               //v = (double)p.pic[j * imax + i];
               v = (double)p_in->p[j * imax + i];
               w = P2[k];
               somme += w * v;
           }
           f[i] = somme / norme;
       }
       else
           f[i] = 0.0;
   }

   // ----------------------------------------------------
   // On gère les largeur2 dernières colonne (peu critique)
   // Algorithme simplifié (pas de détection de cosmique)
   // ----------------------------------------------------
   for (i = imax - largeur2; i < imax; i++)
   {
       k = 0;
       // Calcul de la fonction de poids
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           //P2[k] = (double)p2.pic[j * imax + i];
           P2[k] = (double)p_tmp1->p[j * imax + i];			  
       }

       // La fonction de poids est rendue strictement positive et normalisée
       s = 0;
       k = 0;
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           if (P2[k] < 0) P2[k] = 0;
           s = s + P2[k];
       }
       k = 0;
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           P2[k] = P2[k] / s;
       }

       // Calcul de la norme
       s = 0;
       k = 0;
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           s = s + P2[k] * P2[k];
       }
       norme = s;

       // Calcul du profil optimisé
       somme = 0.0;
       //if (norme != 0.0 && !double.IsNaN(norme))
       if (norme != 0.0 )
       {
           k = 0;
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               //v = (double)p.pic[j * imax + i];
               v = (double)p_in->p[j * imax + i];
               w = P2[k];
               somme += w * v;
           }
           f[i] = somme / norme;
       }
       else
           f[i] = 0.0;
   }

   // ------------------------------------------
   // On gère le reste du profil...
   // Algorithme de K. Horne modifié
   // ------------------------------------------
   for (i = largeur2; i < imax - largeur2; i++)
   {
       // Initialisation de la table de flag des cosmiques
       k = 0;
       for (j = lmin - 1; j < lmax; j++, k++)
       {
           M[k] = 1;
       }
       // On itère 3 x
       for (it = 0; it < 3; it++)
       {
           somme = 0.0;
           k = 0;
           // Calcul de la fonction de poids = médiane sur 2 x largeur2 + 1 colonnes
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               int kk = 0;
               for (m = -largeur2; m <= largeur2; m++, kk++)  // médiane sur +/- largeur2 + 1
               {
                   //vv[kk] = p.pic[j * imax + i + m];    // image à traiter
                   vv[kk] = (double)p_in->p[j * imax + i + m];    // image à traiter						 
                   //vv2[kk] = p2.pic[j * imax + i + m];  // image somme des éventuelles images individuelles (sinon p = p2)
                   vv2[kk] = (double)p_tmp1->p[j * imax + i + m];  // image somme des éventuelles images individuelles (sinon p = p2)
               }
               //P[k] = (double)hmedian(vv);     // mediane du vecteur vv
                 tt_util_qsort_double(vv,0,1+2*largeur2,NULL);
                 P[k] = (double)vv[largeur2];
               //P2[k] = (double)hmedian(vv2);
                 tt_util_qsort_double(vv2,0,1+2*largeur2,NULL);
                 P2[k] = (double)vv2[largeur2];
           }

           // La fonction de poids est rendue strictement positive et normalisée
           s = 0;
           k = 0;
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               if (P2[k] < 0) P2[k] = 0;
               s = s + P2[k];
           }
           k = 0;
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               P2[k] = P2[k] / s;
           }

           // première passe (somme simple)
           if (it == 0)
           {
               k = 0;
               E = 0.0;
               for (j = lmin - 1; j < lmax; j++, k++)
               {
                   //E = E + (double)p.pic[j * imax + i];
                   E = E + (double)p_in->p[j * imax + i];
               }
           }

           // Calcul du bruit colonne
           k = 0;
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               V[k] = fabs(P2[k] * E * gain) + pow(RON, 2.0); // en e-
           }

           // Calcul de la norme
           s = 0;
           k = 0;
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               s = s + P2[k] * P2[k] / V[k];
           }
           norme = s;

           // Calcul du profil optimisé
           somme = 0.0;
           //if (norme != 0.0 && !double.IsNaN(norme))
           if (norme != 0.0 )
           {
               k = 0;
               for (j = lmin - 1; j < lmax; j++, k++)
               {
                   //v = P2[k] * (double)p.pic[j * imax + i] / V[k];
                   v = P2[k] * (double)p_in->p[j * imax + i] / V[k];
                   somme += v;
               }
               f[i] = E = somme / norme;
           }
           else
               f[i] = E = 0.0;

           // Détection des cosmiques (réjection à coef sigma)
           k = 0;
           max = -1e-10;
           adr = 0;
           index = -1;
           for (j = lmin - 1; j < lmax; j++, k++)
           {
               if ((M[k] == 1) && (pow(((double)p_in->p[j * imax + i] - E * P2[k]) * gain, 2.0) > coef * coef * V[k]))
               {
                   // Recherche du point le plus déviant par rapport au modèle (en e-)
                   if (pow(((double)p_in->p[j * imax + i] - E * P2[k]) * gain, 2.0) > max)
                   {
                       max = pow(((double)p_in->p[j * imax + i] - E * P2[k]) * gain, 2.0);
                       adr = j * imax + i;
                       index = k;
                   }
               }
           }
           if (index != -1)
           {
               p_in->p[adr] = (TT_PTYPE)(P[index] + .5);
               M[index] = 0;  // retrait d'un seul cosmique par boucle
           }
       }
   }

   // Profil de sortie
   /* Normalisation du profil a 32767 non faite */
   /*max=32767.0/max;*/
   max=1.;
   for (i=0;i<imax;i++) {
      for (j=0;j<hauteur;j++) {
        if (f[i]>0) {
          p_out->p[j*imax+i]=(TT_PTYPE)(f[i]*max);
        } else {
          /* Les valeurs "nan" sont mises egales a 0 */
          p_out->p[j*imax+i]=(TT_PTYPE)(0);
        }
      }
   }

   tt_free(f,"f");
   tt_free(P,"P");
   tt_free(P2,"P2");
   tt_free(V,"V");
   tt_free(M,"M");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

// declaration des fonctions locales utilisees par savgol
void savgol(double *c, int np, int nl, int nr, int ld, int m);
void ludcmp(double **a, int n, int *indx, double *d);
void lubksb(double **a, int n, int *indx, double b[]);
void nrerror(char error_text[]);
double **matrix(long nrl, long nrh, long ncl, long nch);
void free_matrix(double **m, long nrl, long nrh, long ncl, long nch);
double *vector(long nl, long nh);
void free_vector(double *v, long nl, long nh);
size_t *ivector(long nl, long nh);
int *intvector(long nl, long nh);
void free_intvector(int*v, long nl, long nh);

#define NR_END 1
#define FREE_ARG char*
#define TINY 1.0e-20


/*******************************************************************************/
/* Fonction smoothsg     (smooth Savitzky-Golay)                               */
/* arguments possibles :                                                       */
/*   NL : number of leftward  (past) data points     (default=16)              */
/*   NR : number of rightward (future) data points   (default=16)              */
/*   LD : order of the derivative desired (defaut=0 for smoothed function)     */
/*   M  : order of the smoothing polynomial usual values are m = 2 or m = 4    */
/*  example : buf2 imaseries SMOOTHSG "NR=16 NL=16 LD=0 M=2"                            */
/*******************************************************************************/
int tt_ima_series_smoothsg(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   char message[TT_MAXLIGNE];
   int index;
   int i,j, n, np;
   double *c;
   int *pindex;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   // largeur de l'image
   n=p_in->naxis1;
   //
   np = pseries->user2.nl+ pseries->user2.nr + 1;

   /* verification des donnees */
   if (p_in->naxis2 > 1) {
      sprintf(message,"must be 1D image");
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }

   /* --- initialisation ---*/
   tt_imacreater(p_out,n,1);
   c = vector(1, np);

   //seek shift index for given case nl, nr, m (see savgol).
   pindex = intvector(1, np);
   pindex[1]=0;
   j=3;
   for (i=2; i<=pseries->user2.nl+1; i++)
   {
      // index(2)=-1; index(3)=-2; index(4)=-3; index(5)=-4; index(6)=-5
      pindex[i]=i-j;
      j += 2;
   }
   j=2;
   for (i=pseries->user2.nl+2; i<=np; i++)
   {
      // index(7)= 5; index(8)= 4; index(9)= 3; index(10)=2; index(11)=1
      pindex[i]=i-j;
      j += 2;
   }

   //calculate Savitzky-Golay filter coefficients.
   savgol(c, np, pseries->user2.nl, pseries->user2.nr, pseries->user2.ld, pseries->user2.m);

   for (i=0; i<n; i++) {
      // Apply filter to input data.
      p_out->p[i]=0.0;
      for (j=1; j<=np; j++) {
         int it = i+pindex[j];
         //skip left points that do not exist.
         if (it >=0 && it < n) {
            p_out->p[i] += (float) c[j]*p_in->p[i+pindex[j]];
         }
      }
   }

   free_vector(c,1,np);
   free_intvector(pindex,1,np);

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}







int IMIN(int ia, int ib)
	{
	if (ia<=ib)
		return ia;
	else
		return ib;
	}

void savgol(double *c, int np, int nl, int nr, int ld, int m)  {
/*-------------------------------------------------------------------------------------------
 USES lubksb,ludcmp given below.
 Returns in c(np), in wrap-around order (see reference) consistent with the argument respns
 in routine convlv, a set of Savitzky-Golay filter coefficients. nl is the number of leftward
 (past) data points used, while nr is the number of rightward (future) data points, making
 the total number of data points used nl +nr+1. ld is the order of the derivative desired
 (e.g., ld = 0 for smoothed function). m is the order of the smoothing polynomial, also
 equal to the highest conserved moment; usual values are m = 2 or m = 4.
   -------------------------------------------------------------------------------------------*/
   int imj,ipj,j,k,kk,mm;
   double d,fac,sum,**a,*b;
   int *indx;

   if (np < nl+nr+1 || nl < 0 || nr < 0 || ld > m || nl+nr < m)
      nrerror("bad args in savgol");

   indx= intvector(1,m+1);
   a=matrix(1,m+1,1,m+1);
   b=vector(1,m+1);
   for (ipj=0;ipj<=(m << 1);ipj++)
   {//Set up the normal equations of the desired least-squares fit
      sum=(ipj ? 0.0 : 1.0);
      for (k=1;k<=nr;k++)
         sum += pow((double)k,(double)ipj);
      for (k=1;k<=nl;k++)
         sum += pow((double)-k,(double)ipj);
      mm=IMIN(ipj,2*m-ipj);
      for (imj = -mm;imj<=mm;imj+=2)
         a[1+(ipj+imj)/2][1+(ipj-imj)/2]=sum;
   }

   ludcmp(a,m+1,indx,&d); //Solve them: LU decomposition.

   for (j=1;j<=m+1;j++)
      b[j]=0.0;

   b[ld+1]=1.0; //Right-hand side vector is unit vector, depending on which derivative we want.

   lubksb(a,m+1,indx,b); //Get one row of the inverse matrix.

   for (kk=1;kk<=np;kk++)
      c[kk]=0.0; //Zero the output array (it may be bigger than number of coefficients).

   for (k = -nl;k<=nr;k++)
   {
      sum=b[1];   //Each Savitzky-Golay coefficient is the dot product
      //of powers of an integer with the inverse matrix row.
      fac=1.0;
      for (mm=1;mm<=m;mm++)
         sum += b[mm+1]*(fac *= k);

      kk=((np-k) % np)+1; //Store in wrap-around order.
      c[kk]=sum;
   }

   free_vector(b,1,m+1);
   free_matrix(a,1,m+1,1,m+1);
   free_intvector(indx,1,m+1);
}

/**************************************************************
* Given an N x N matrix A, this routine replaces it by the LU *
* decomposition of a rowwise permutation of itself. A and N   *
* are input. INDX is an output vector which records the row   *
* permutation effected by the partial pivoting; D is output   *
* as -1 or 1, depending on whether the number of row inter-   *
* changes was even or odd, respectively. This routine is used *
* in combination with LUBKSB to solve linear equations or to  *
* invert a matrix. Return code is 1, if matrix is singular.   *
**************************************************************/
void ludcmp(double **a, int n, int *indx, double *d)
{
   int i,imax,j,k;
   double big,dum,sum,temp;
   double *vv=vector(1,n);
   *d=1.0;
   imax = 0;

   for (i=1;i<=n;i++)
   {
      big=0.0;
      for (j=1;j<=n;j++)
         if ((temp=fabs(a[i][j])) > big)
            big=temp;
         if (big == 0.0)
            nrerror("allocation failure 1 in matrix()");
         vv[i]=1.0/big;
   }
   for (j=1;j<=n;j++)
   {
      for (i=1;i<j;i++)
      {
         sum=a[i][j];
         for (k=1;k<i;k++)
            sum -= a[i][k]*a[k][j];
         a[i][j]=sum;
      }
      big=0.0;
      for (i=j;i<=n;i++)
      {
         sum=a[i][j];
         for (k=1;k<j;k++)
            sum -= a[i][k]*a[k][j];
         a[i][j]=sum;
         if ( (dum=vv[i]*fabs(sum)) >= big)
         {
            big=dum;
            imax=i;
         }
      }
      if (j != imax)
      {
         for (k=1;k<=n;k++)
         {
            dum=a[imax][k];
            a[imax][k]=a[j][k];
            a[j][k]=dum;
         }
         *d = -(*d);
         vv[imax]=vv[j];
      }
      indx[j]=imax;
      if (a[j][j] == 0.0)
         a[j][j]=TINY;

      if (j != n)
      {
         dum=1.0/(a[j][j]);
         for (i=j+1;i<=n;i++)
            a[i][j] *= dum;
      }
   }
   free_vector(vv,1,n);
}

/*****************************************************************
* Solves the set of N linear equations A . X = B.  Here A is    *
* input, not as the matrix A but rather as its LU decomposition, *
* determined by the routine LUDCMP. INDX is input as the permuta-*
* tion vector returned by LUDCMP. B is input as the right-hand   *
* side vector B, and returns with the solution vector X. A, N and*
* INDX are not modified by this routine and can be used for suc- *
* cessive calls with different right-hand sides. This routine is *
* also efficient for plain matrix inversion.                     *
*****************************************************************/
void lubksb(double **a, int n, int *indx, double b[])
{
int i,ii=0,ip,j;
double sum;

for (i=1;i<=n;i++)
	{
	ip=indx[i];
	sum=b[ip];
	b[ip]=b[i];
	if (ii)
		for (j=ii;j<=i-1;j++)
			sum -= a[i][j]*b[j];
	else if (sum)
		ii=i;

	b[i]=sum;
	}
for (i=n;i>=1;i--)
	{
	sum=b[i];
	for (j=i+1;j<=n;j++)
		sum -= a[i][j]*b[j];

	b[i]=sum/a[i][i];
	}
}

void nrerror(char error_text[])
{//Numerical Recipes standard error handler
   fprintf(stderr,"Numerical Recipes run-time error...\n");
   fprintf(stderr,"%s\n",error_text);
   fprintf(stderr,"...now exiting to system...\n");
   exit(1);
}

double **matrix(long nrl, long nrh, long ncl, long nch)
{// allocate a double matrix with subscript range m[nrl..nrh][ncl..nch]
   long i, nrow=nrh-nrl+1,ncol=nch-ncl+1;
   double **m;

   //allocate pointers to rows
   m=(double **) malloc((size_t)((nrow+NR_END)*sizeof(double*)));
   if (!m) nrerror("allocation failure 1 in matrix()");
   m += NR_END;
   m -= nrl;

   // allocate rows and set pointers to them
   m[nrl]=(double *) malloc((size_t)((nrow*ncol+NR_END)*sizeof(double)));
   if (!m[nrl]) nrerror("allocation failure 2 in matrix()");
   m[nrl] += NR_END;
   m[nrl] -= ncl;
   for(i=nrl+1;i<=nrh;i++) m[i]=m[i-1]+ncol;

   // return pointer to array of pointers to rows
   return m;
}

void free_matrix(double **m, long nrl, long nrh, long ncl, long nch)
{//free a double matrix allocated by matrix()
   free((FREE_ARG) (m[nrl]+ncl-NR_END));
   free((FREE_ARG) (m+nrl-NR_END));
}

double *vector(long nl, long nh)
{//allocate a double vector with subscript range v[nl..nh]
   double *v;
   v=(double *)malloc((size_t) ((nh-nl+1+NR_END)*sizeof(double)));
   if (!v)
      nrerror("allocation failure in double vector()");
   return v-nl+NR_END;
}

void free_vector(double *v, long nl, long nh)
{// free a double vector allocated with vector()
   free((FREE_ARG) (v+nl-NR_END));
}

size_t *ivector(long nl, long nh)
{
   size_t *v;
   v=(size_t *)malloc((size_t) ((nh-nl+1+NR_END)*sizeof(size_t)));
   if (!v) nrerror("allocation failure in ivector()");
   return v-nl+NR_END;
}

void free_ivector(size_t *v, long nl, long nh)
{
   free((FREE_ARG) (v+nl-NR_END));
}

int *intvector(long nl, long nh)
{
   int *v;
   v=(int *)malloc((size_t) ((nh-nl+1+NR_END)*sizeof(int)));
   if (!v) nrerror("allocation failure in intvector()");
   return v-nl+NR_END;
}

void free_intvector(int*v, long nl, long nh)
{
   free((FREE_ARG) (v+nl-NR_END));
}


/************************************************************************************************/
/* Fonction colorspectrum                                                                       */
/*  colorize a spectrum                                                                         */
/* arguments possibles :                                                                        */
/*   WAVELENGTHMIN : pseudo min wavelength    (default=3800)                                    */
/*   WAVELENGTHMAX : pseudo max wavelength    (default=7800)                                    */
/*   XMIN          : abcissse correspondant a la longueur d'onde WAVELENGTHMIN  (default=1)     */
/*   XMAX          : abcissse correspondant a la longueur d'onde WAVELENGTHMAX  (default=witdh)
 */
/* example :                                                                                    */
/*   buf2 imaseries "COLORSPECTRUM WAVELENGTHMIN=6000 WAVELENGTHMAX=6800 XMIN=1 XMAX=1536"      */
/************************************************************************************************/
int tt_ima_series_colorspectrum(TT_IMA_SERIES *pseries)
{
   TT_IMA *p_in,*p_out;
   char message[TT_MAXLIGNE];
   int msg;
   int index;
   int i, width;
   double colorDepth = 255;
   double gamma = 0.8;
   int elementSize = sizeof(double);
   double *wavelength=NULL;
   double fluxmax, fluxmin;
   double dw;
   float thershold;
   int xmin, xmax, xwidth;

   //--- intialisations
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   index=pseries->index;
   width=p_in->naxis1;


   //--- verification des parametres
   if ( pseries->user2.xmin == -1 ) {
      xmin = 0;
   } else {
      if ( pseries->user2.xmin >= 1 || pseries->user2.xmin <= width ) {
         xmin = pseries->user2.xmin - 1;
      } else {
         sprintf(message,"XMIN must be between  1 and %d", width);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
      }
   }

   if ( pseries->user2.xmax == -1 ) {
      xmax = width -1;
   } else {
      if ( pseries->user2.xmax >= pseries->user2.xmin+1 || pseries->user2.xmax <= width ) {
         xmax = pseries->user2.xmax - 1;
      } else {
         sprintf(message,"XMIN must be between  %d and %d", pseries->user2.xmin +1, width);
         tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
         return(TT_ERR_WRONG_VALUE);
      }
   }

   xwidth = xmax - xmin +1;

   //--- verification des donnees
   if (p_in->naxis2 > 1) {
      sprintf(message,"must be 1D image");
      tt_errlog(pseries->tmp_dir,TT_ERR_WRONG_VALUE,message);
      return(TT_ERR_WRONG_VALUE);
   }

   // je cree le tableau temporairedes longueur d'onde (abscisses)
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&wavelength,&xwidth,&elementSize,"wavelength"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_ima_series_colorspectrum for pointer wavelength");
      return(TT_ERR_PB_MALLOC);
   }

   // je reserve l'espace memoire de sortie (3 valeurs RGB pour chaque pixels)
   tt_imacreater(p_out,xwidth*3,1);

   // je recherche les valuers min et max du flux
   fluxmin= p_in->p[xmin];
   fluxmax= p_in->p[xmin];
   dw= (pseries->user2.wavelengthmax - pseries->user2.wavelengthmin)/((double)(xwidth-1));
   for( i=0 ; i < xwidth ; i++ ) {
      wavelength[i] = pseries->user2.wavelengthmin + dw * ((double) i);
      if( p_in->p[i+xmin] > fluxmax) {
        fluxmax = p_in->p[i+xmin];
      }
      if( p_in->p[i+xmin] < fluxmin) {
        fluxmin = p_in->p[i+xmin];
      }
   }

   // Find color value, icv, of each pixel
   for( i=0 ; i < xwidth ; i++ ) {
      double r, g, b;
      double wl, a;
      double rhi,rlo;

      wl=wavelength[i];

      // get background color
      r = 0.;
      g = 0.;
      b = 0.;
      if((wl >= 3800.) & (wl <= 7800.)) {
         // modification pour eclaircir l'extreme rouge
         rhi=1.2 / (1.+exp(((5400.-wl)/150.)));
         rhi=rhi / (1.+exp(((wl-6700.)/200.)));
         rlo=0.4 / (1.+exp(((wl-4400.)/300.)));
         rlo=rlo / (1.+exp(((3900.-wl)/200.)));
         r=rhi+rlo;
         g=1.0 / (1.+exp(((wl-6000.)/200.)));
         g=g / (1.+exp(((4800.-wl)/150.)));
         g=g * 1.02;
         b=1.0 / (1.+exp(((wl-5000.)/150.)));
         b=b / (1.+exp(((4000.-wl)/200.)));
         b=b * 1.0;
      }

      // get spectrum modulation
      a=(p_in->p[i+xmin] - fluxmin)/(fluxmax-fluxmin);


      // set output RGB values
      p_out->p[i*3+0] = (TT_PTYPE) (colorDepth * pow( a*r , gamma ));
      p_out->p[i*3+1] = (TT_PTYPE) (colorDepth * pow( a*g , gamma ));
      p_out->p[i*3+2] = (TT_PTYPE) (colorDepth * pow( a*b , gamma ));

   }

   // free memory
   tt_free(wavelength,"wavelength");

   p_out->naxis  = 3;
   p_out->naxis1 = xwidth;
   p_out->naxis2 = 1;
   p_out->naxis3 = 3;
   // j'ajoute le mot cle NAXIS
   tt_imanewkey(p_out,"NAXIS",&p_out->naxis,TINT,"","");
   // j'ajoute le mot cle NAXIS1
   tt_imanewkey(p_out,"NAXIS1",&p_out->naxis1,TINT,"","");
   // j'ajoute le mot cle NAXIS2
   tt_imanewkey(p_out,"NAXIS2",&p_out->naxis2,TINT,"","");
   // j'ajoute le mot cle NAXIS3
   tt_imanewkey(p_out,"NAXIS3",&p_out->naxis3,TINT,"","");
   // j'ajoute les seuils par defaut
   thershold = 0.0 ;
   tt_imanewkey(p_out,"MIPS-LO",&thershold,TFLOAT,"","");
   thershold = 255.0 ;
   tt_imanewkey(p_out,"MIPS-HI",&thershold,TFLOAT,"","");


   // je bidouille naxis, naxis1 et naxis2 car libtt ne supporte pas les images 3D
   // Les bonnes valeurs sont dans le tableau des mots cles.
   // L'utilsateur ne doit surtout pas utiliser ces variables au retour de TT_ImaSeries()
   // Il faut utiliser les valeurs des mots cle NAXIS, NAXIS1, NAXIS2 et NAXIS3
   p_out->naxis  = 2;
   p_out->naxis2 = 3;
   p_out->naxis3 = 1 ;

   // --- calcul des temps
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

