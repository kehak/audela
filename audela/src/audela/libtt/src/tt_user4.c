/* tt_user4.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Carole THIEBAULT <carole.thiebaut@cnes.fr>
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
#include "focas.h"

/***** prototypes des fonctions internes du user4 ***********/
int tt_ima_series_astrometry2(TT_IMA_SERIES *pseries);
/* pour la methode FOCAS */
int tt_util_focas2(TT_IMA *p_in,double epsilon, double delta, double threshold, double *a,double *b,int *nb,double *cmag0,double *d_cmag0);
int focas_main2(char *nom_fichier1,int type_fichier1,
		 char *nom_fichier2,int type_fichier2,
		 int flag_focas,
		 int flag_sature1,
		 int flag_sature2,
		 char *nom_fichier_com,char *nom_fichier_dif,
		 int *nbcom,
		 double *transf_1vers2,double *transf_2vers1,
               double epsilon, double delta, double seuil_poids);
int focas_liste_commune2(char *nom_fichier_com,char *nom_fichier_dif,
			struct focas_tableau_entree *data_tab10,int nb1tot,
			struct focas_tableau_entree *data_tab20,int nb2tot,
			double *transf12,double *transf21,int nb_coef_a,
			double delta,
			int *total,
			struct focas_tableau_corresp *corresp,
			struct focas_tableau_corresp *differe,
			int flag_corresp);
int focas_transmoy2(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1);
int focas_register2(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1);

int tt_user4_ima_series_builder1(char *keys10,TT_IMA_SERIES *pseries)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   if (strcmp(keys10,"ASTROMETRY2")==0) { pseries->numfct=TT_IMASERIES_USER4_ASTROMETRY2; }
   return(OK_DLL);
}

int tt_user4_ima_series_builder2(TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   return(OK_DLL);
}

int tt_user4_ima_series_builder3(char *mot,char *argu,TT_IMA_SERIES_OPTION* options)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   return(OK_DLL);
}

int tt_user4_ima_series_dispatch1(TT_IMA_SERIES *pseries,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   if (pseries->numfct==TT_IMASERIES_USER4_ASTROMETRY2) {
      *msg=tt_ima_series_astrometry2(pseries);
      *fct_found=TT_YES;
   }
   return(OK_DLL); 
}

/**************************************************************************/
/**************************************************************************/
/* Initialisation des fonctions de user4 pour IMA/STACK                   */
/**************************************************************************/
/**************************************************************************/

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user4_ima_stack_builder1(char *keys10,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Definition du nom externe de la fonction et son lien interne a libtt.  */
/**************************************************************************/
{
   return(OK_DLL);
}

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user4_ima_stack_builder2(TT_IMA_STACK *pstack)
/**************************************************************************/
/* Valeurs par defaut des parametres de la ligne de commande.             */
/**************************************************************************/
{
   return(OK_DLL);
}

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user4_ima_stack_builder3(char *mot,char *argu,TT_IMA_STACK *pstack)
/**************************************************************************/
/* Decodage de la valeur des parametres de la ligne de commande.          */
/**************************************************************************/
{
   return(OK_DLL);
}

/* #pragma argsused : qu'est-ce que c'est ? */
int tt_user4_ima_stack_dispatch1(TT_IMA_STACK *pstack,int *fct_found, int *msg)
/*****************************************************************************/
/* Appel aux fonctions C qui vont effectuer le calcul des fonctions externes */
/*****************************************************************************/
{
   return(OK_DLL);
}

int focas_register2(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1)
/*************************************************************************/
/* FOCAS_REGISTER                                                        */
/* But : calcule les coefficients de transformation de listes d'etoiles  */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* .)  A employer apres FOCAS_MATCH et apres une 1ere calibration lineaire.*/
/* 1)  On calcule la matrice de transformation des coordonnees des       */
/*     etoiles de la liste 1 dans le repere des coordonnees de la liste  */
/*     2 et vice versa.                                                  */
/*                                                                       */
/* ENTREES :                                                             */
/* *corresp   : tableau des correspondances                              */
/* nbcorresp  : nombre de correspondances                                */
/*                                                                       */
/* SORTIES :                                                             */
/* *transf_1vers2 : tableau des 12 coefs de transformation pour une     */
/*                  etoile de la liste 1 dans le repere de la liste 2.   */
/* *transf_2vers1 : tableau des 12 coefs de transformation pour une     */
/*                  etoile de la liste 2 dans le repere de la liste 1.   */
/*                                                                       */
/*************************************************************************/
{
   int nbc;
   int nb_coef_a,lig,col,j;
   double *xx=NULL,*xy=NULL,*a=NULL,*vec_p=NULL,*val_p=NULL;
   int nombre,taille,msg;

   nbc=nbcorresp;
   nb_coef_a=6;

   if (nbc>=3) {
      nombre=(nb_coef_a+1)*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&xx,&nombre,&taille,"xx"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer xx");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=3*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&xy,&nombre,&taille,"xy"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer xy");
	 tt_free2((void**)&xx,"xx");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=3*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&a,&nombre,&taille,"a"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer a");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=(nb_coef_a+1)*(nb_coef_a+1);
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec_p,&nombre,&taille,"vec_p"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer vec_p");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 return(TT_ERR_PB_MALLOC);
      }
      nombre=nb_coef_a+1;
      taille=sizeof(double);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&val_p,&nombre,&taille,"val_p"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_register for pointer val_p");
	 tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	 tt_free2((void**)&a,"a");
	 tt_free2((void**)&vec_p,"vec_p");
	 return(TT_ERR_PB_MALLOC);
      }

      /***************************************************/
      /* ====== x1 = A*x2 + B*y2 + C + D*x2*y2 + E*x2*x2 + F*y2*y2 (idem pur y1) ======*/
      /* --- a1 = A  et  x1j = x2                    --- */
      /* --- a2 = B  et  x2j = y2                    --- */
      /* --- a3 = C  et  x3j = 1                     --- */
	/* --- a4 = D  et  x4j = x2*y2                 --- */
	/* --- a5 = E  et  x5j = x2*x2                 --- */
	/* --- a6 = F  et  x6j = y2*y2                 --- */
      /***************************************************/
      /* === calcule les elements de matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 for (col=1;col<=nb_coef_a;col++) {
	    xx[lig+nb_coef_a*col]=0;
	    if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2); } }
	    if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2); } }
	    if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2              ); } }
	    if ((lig==1)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2);}}
	    if ((lig==1)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	    if ((lig==1)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }	    
	    if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].x2); } }
	    if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2); } }
	    if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2              ); } }
	    if ((lig==2)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].x2); } }
	    if ((lig==2)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	    if ((lig==2)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2); } }	    
	    if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].x2); } }
	    if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].y2); } }
	    if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(            1.000          ); } }
	    if ((lig==3)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2); } }
	    if ((lig==3)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2); } }
	    if ((lig==3)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2); } }
	    if ((lig==4)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	    if ((lig==4)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==4)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2); } }
	    if ((lig==4)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==4)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	    if ((lig==4)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==5)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	    if ((lig==5)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	    if ((lig==5)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2); } }
          if ((lig==5)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].y2); } }
	    if ((lig==5)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].x2*corresp[j].x2); } }
	    if ((lig==5)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==6)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==6)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==6)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2); } }
	    if ((lig==6)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==6)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x2*corresp[j].x2*corresp[j].y2*corresp[j].y2); } }
	    if ((lig==6)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y2*corresp[j].y2*corresp[j].y2*corresp[j].y2); } }

	 }
      }
      focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
      /* === inverse les valeurs propres de la matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 if (*(val_p+lig)!=0) { *(val_p+lig)=1/ *(val_p+lig); } else {
	    msg=TT_ERR_NULL_EIGENVALUE;
	    tt_errlog("",msg,"irregular first transformation in focas_register ");
	    tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	    tt_free2((void**)&a,"a");
	    tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
	    return(msg);
	 }
      }
      /* === calcul de la matrice XX-1 ===*/
      focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
      /* === calcule les elements de matrice XY pour x1 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 xy[lig+1]=0;
	 if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2); } }
	 if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].y2); } }
	 if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1              ); } }
	 if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2*corresp[j].y2); } }
	 if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].x2*corresp[j].x2); } }
	 if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x1*corresp[j].y2*corresp[j].y2); } }
      }
      /* === calcule les coefficients de transformation pour x1 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
	 transf_2vers1[1*nb_coef_a+col]=a[1*1+col];
      }
      /* === calcule les elements de matrice XY pour y1 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 xy[lig+1]=0;
	 if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2); } }
	 if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].y2); } }
	 if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1              ); } }
	 if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2*corresp[j].y2); } }
	 if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].x2*corresp[j].x2); } }
	 if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y1*corresp[j].y2*corresp[j].y2); } }
      }
      /* === calcule les coefficients de transformation pour y1 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
	 transf_2vers1[2*nb_coef_a+col]=a[1*1+col];
      }

      /***************************************************/
      /* ====== x2 = A*x1 + B*y1 + C + D*x1*y1 + E*x1*x1 + F*y1*y1 (idem pour y2) ======*/
      /* --- a1 = A  et  x1j = x1                    --- */
      /* --- a2 = B  et  x2j = y1                    --- */
      /* --- a3 = C  et  x3j = 1                     --- */
	/* --- a4 = D  et  x4j = x1*y1                 --- */
	/* --- a5 = E  et  x5j = x1*x1                 --- */
	/* --- a6 = F  et  x6j = y1*y1                 --- */
      /***************************************************/
      /* === calcule les elements de matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 for (col=1;col<=nb_coef_a;col++) {
	    xx[lig+nb_coef_a*col]=0;
	    if ((lig==1)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1); } }
	    if ((lig==1)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1); } }
	    if ((lig==1)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1              ); } }
	    if ((lig==1)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1);}}
	    if ((lig==1)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	    if ((lig==1)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }	    
	    if ((lig==2)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].x1); } }
	    if ((lig==2)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1); } }
	    if ((lig==2)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1              ); } }
	    if ((lig==2)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].x1); } }
	    if ((lig==2)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	    if ((lig==2)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1); } }	    
	    if ((lig==3)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].x1); } }
	    if ((lig==3)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(              corresp[j].y1); } }
	    if ((lig==3)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(            1.000          ); } }
	    if ((lig==3)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1); } }
	    if ((lig==3)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1); } }
	    if ((lig==3)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1); } }
	    if ((lig==4)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	    if ((lig==4)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==4)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1); } }
	    if ((lig==4)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==4)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	    if ((lig==4)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==5)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	    if ((lig==5)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	    if ((lig==5)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1); } }
            if ((lig==5)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].y1); } }
	    if ((lig==5)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].x1*corresp[j].x1); } }
	    if ((lig==5)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==6)&&(col==1)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==6)&&(col==2)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==6)&&(col==3)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1); } }
	    if ((lig==6)&&(col==4)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==6)&&(col==5)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].x1*corresp[j].x1*corresp[j].y1*corresp[j].y1); } }
	    if ((lig==6)&&(col==6)) { for (j=1;j<=nbc;j++) { xx[lig+nb_coef_a*col]+=(corresp[j].y1*corresp[j].y1*corresp[j].y1*corresp[j].y1); } }
	 }
      }
      focas_mat_givens(xx,val_p,vec_p,nb_coef_a);
      /* === inverse les valeurs propres de la matrice XX ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 if (*(val_p+lig)!=0) { *(val_p+lig)=1/ *(val_p+lig); } else {
	    msg=TT_ERR_NULL_EIGENVALUE;
	    tt_errlog("",msg,"irregular second transformation in focas_register ");
	    tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
	    tt_free2((void**)&a,"a");
	    tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
	    return(msg);
	 }
      }
      /* === calcul de la matrice XX-1 ===*/
      focas_mat_vdtv(xx,val_p,vec_p,nb_coef_a);
      /* === calcule les elements de matrice XY pour x2 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 xy[lig+1]=0;
	 if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1); } }
	 if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].y1); } }
	 if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2              ); } }
	 if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1*corresp[j].y1); } }
	 if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].x1*corresp[j].x1); } }
	 if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].x2*corresp[j].y1*corresp[j].y1); } }
      }
      /* === calcule les coefficients de transformation pour x2 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
	 transf_1vers2[1*nb_coef_a+col]=a[1*1+col];
      }
      /* === calcule les elements de matrice XY pour y2 ===*/
      for (lig=1;lig<=nb_coef_a;lig++) {
	 xy[lig+1]=0;
	 if (lig==1) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1); } }
	 if (lig==2) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].y1); } }
	 if (lig==3) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2              ); } }
	 if (lig==4) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1*corresp[j].y1); } }
	 if (lig==5) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].x1*corresp[j].x1); } }
	 if (lig==6) { for (j=1;j<=nbc;j++) { xy[lig+1]+=(corresp[j].y2*corresp[j].y1*corresp[j].y1); } }
      }
      /* === calcule les coefficients de transformation pour y2 ===*/
      focas_mat_mult(xx,xy,a,nb_coef_a,nb_coef_a,1);
      for (col=1;col<=nb_coef_a;col++) {
	 transf_1vers2[2*nb_coef_a+col]=a[1*1+col];
      }
      tt_free2((void**)&xx,"xx");tt_free2((void**)&xy,"xy");
      tt_free2((void**)&a,"a");
      tt_free2((void**)&vec_p,"vec_p");tt_free2((void**)&val_p,"val_p");
   } else if ((nbc<=2)&&(nbc>=1)) {
      transf_1vers2[1*nb_coef_a+1]=1.0;
      transf_1vers2[1*nb_coef_a+2]=0.0;
      transf_1vers2[1*nb_coef_a+3]=corresp[1].x2-corresp[1].x1;
	transf_1vers2[1*nb_coef_a+4]=0.0;
      transf_1vers2[1*nb_coef_a+5]=0.0;
      transf_1vers2[1*nb_coef_a+6]=0.0;      
	transf_1vers2[2*nb_coef_a+1]=0.0;
      transf_1vers2[2*nb_coef_a+2]=1.0;
      transf_1vers2[2*nb_coef_a+3]=corresp[1].y2-corresp[1].y1;
	transf_1vers2[2*nb_coef_a+4]=0.0;
      transf_1vers2[2*nb_coef_a+5]=0.0;
      transf_1vers2[2*nb_coef_a+6]=0.0;
      transf_2vers1[1*nb_coef_a+1]=1.0;
      transf_2vers1[1*nb_coef_a+2]=0.0;
      transf_2vers1[1*nb_coef_a+3]=corresp[1].x1-corresp[1].x2;
	transf_2vers1[1*nb_coef_a+4]=0.0;
      transf_2vers1[1*nb_coef_a+5]=0.0;
      transf_2vers1[1*nb_coef_a+6]=0.0;      
	transf_2vers1[2*nb_coef_a+1]=0.0;
      transf_2vers1[2*nb_coef_a+2]=1.0;
      transf_2vers1[2*nb_coef_a+3]=corresp[1].y1-corresp[1].y2;
	transf_2vers1[2*nb_coef_a+4]=0.0;
      transf_2vers1[2*nb_coef_a+5]=0.0;
      transf_2vers1[2*nb_coef_a+6]=0.0;
   }
   return(OK);
}

int tt_util_focas2(TT_IMA *p_in,double epsilon, double delta, double threshold, double *a,double *b,int *nb,double *cmag0,double *d_cmag0)
/*************************************************************************/
/* Interface de tt avec focas pour des listes objet - catalogue          */
/*************************************************************************/
/* *nb est le nombre d'objets apparies.                                  */
/*************************************************************************/
{
   int nombre,taille;
   int k,kk,nbcom1;
   FILE *fichier,*feq;
   char message_err[TT_MAXLIGNE];
   char texte[TT_MAXLIGNE],ligne[TT_MAXLIGNE];
   double transf_1vers2[40],transf_2vers1[40],*cmag;
   int nbcom=0,msg;
   double x1,y1,mag1,x2,y2,mag2,rien,ra,dec,cste,d_cste;

   a[0]=1.;a[1]=0.;a[2]=0.;a[3]=0.;a[4]=1.;a[5]=0.;a[6]=0.;a[7]=0.;a[8]=0.;a[9]=0.;a[10]=0.;a[11]=0.;
   b[0]=1.;b[1]=0.;b[2]=0.;b[3]=0.;b[4]=1.;b[5]=0.;b[6]=0.;b[7]=0.;b[8]=0.;b[9]=0.;b[10]=0.;b[11]=0.;
   /* --- fichier obs.lst de type 1 ---*/
   if ((fichier=fopen("obs.lst", "wt") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file obs.lst in tt_util_focas0");
      tt_errlog("",msg,message_err);
      return(msg);
   }
   for (k=0,kk=0;k<p_in->objelist->nrows;k++) {
      if (p_in->objelist->ident[k]==TT_STAR) {
	 kk++;
	 sprintf(texte,"%f %f %f 0 0 0 %f 1 0\n",p_in->objelist->x[k],p_in->objelist->y[k],p_in->objelist->mag[k],p_in->objelist->mag[k]);
	 fwrite(texte,strlen(texte),1,fichier);
      }
   }
   fclose(fichier);
   /* --- fichier usno.lst de type 3 ---*/
   if ((fichier=fopen("usno.lst", "wt") ) == NULL) {
      msg=TT_ERR_FILE_CANNOT_BE_WRITED;
      sprintf(message_err,"Writing error for file usno.lst in tt_util_focas0");
      tt_errlog("",msg,message_err);
      return(msg);
   }
   for (k=0,kk=0;k<p_in->catalist->nrows;k++) {
      if (p_in->catalist->ident[k]==TT_STAR) {
	 kk++;
	 sprintf(texte,"%d %f %f %f %f %f %f 1 2 1\n",kk,
	 p_in->catalist->x[k],p_in->catalist->y[k],p_in->catalist->magr[k],
	 p_in->catalist->ra[k],p_in->catalist->dec[k],p_in->catalist->magr[k]);
	 fwrite(texte,strlen(texte),1,fichier);
      }
   }
   fclose(fichier);
   /*-- appel a focas ---*/
   if ((msg=focas_main2("obs.lst",1,"usno.lst",3,0,1,0,"com.lst","dif.lst",&nbcom,transf_1vers2,transf_2vers1,epsilon,delta,threshold))!=OK) {
      return(PB_DLL);
   }

   *nb=nbcom;
   *cmag0=0.;
   *d_cmag0=0.;
   if (nbcom<=0) {
      return(OK_DLL);
   }
   /* --- conversion de fichier vers les variables de tt ---*/
   for (k=0;k<12;k++) {
      a[k]=transf_1vers2[k+7];
      b[k]=transf_2vers1[k+7];
   }
   nombre=nbcom;
   taille=sizeof(double);
   cmag=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&cmag,&nombre,&taille,"cmag"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_focas0 for pointer cmag");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- scanne les fichiers com.lst eq.lst ---*/
   if ((fichier=fopen("com.lst", "rt") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      tt_errlog("",msg,"File com.lst not found in tt_util_focas0");
      tt_free2((void**)&cmag,"cmag");
      return(msg);
   }
   if ((feq=fopen("eq.lst", "rt") ) == NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      tt_errlog("",msg,"File eq.lst not found in tt_util_focas0");
      tt_free2((void**)&cmag,"cmag");
      return(msg);
   }
   kk=0;
   do {
      if (fgets(ligne,TT_MAXLIGNE,fichier)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    /* X Y mag x y magr r r r*/
	    sscanf(ligne,"%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf",&x1,&y1,&mag1,&x2,&y2,&mag2,&rien,&rien,&rien);
	 }
      }
      if (fgets(ligne,TT_MAXLIGNE,feq)!=NULL) {
	 strcpy(texte,"");
	 sscanf(ligne,"%s",texte);
	 if ( (strcmp(texte,"")!=0) ) {
	    /* ra dec mag*/
	    sscanf(ligne,"%lf %lf %lf",&ra,&dec,&rien);
	 }
	 for (k=0;k<p_in->objelist->nrows;k++) {
	    if (p_in->objelist->ident[k]==TT_STAR) {
	       if ((fabs(p_in->objelist->x[k]-x1)<1)&&(fabs(p_in->objelist->y[k]-y1)<1)) {
		  cmag[kk]=mag2-mag1;kk++;
                /*
		  newx1=b[0]*x2+b[1]*y2+b[2]+b[3]*x2*y2+b[4]*x2*x2+b[5]*y2*y2;
		  newy1=b[6]*x2+b[7]*y2+b[8]+b[9]*x2*y2+b[10]*x2*x2+b[11]*y2*y2;
                */
		  break;
	       }
	    }
	 }
      }
   } while (feof(fichier)==0);
   fclose(fichier);
   fclose(feq);
   if (tt_util_qsort_double(cmag,0,nbcom,NULL)!=OK_DLL) {
      tt_free2((void**)&cmag,"cmag");
      return(TT_ERR_PB_MALLOC);
   }
   k=(int)(floor((double)nbcom/2.));
   cste=cmag[k];
   d_cste=TT_MAGNULL;
   if (cste!=TT_MAGNULL) {
      rien=0.;
      for (k=0,nbcom1=0;k<nbcom;k++) {
	 if (cmag[k]!=TT_MAGNULL) {
	    mag1=(cste-cmag[k]);
	    rien+=(mag1*mag1);
	    nbcom1++;
	 }
      }
      if (nbcom1!=0) {
	 d_cste=sqrt(rien/nbcom1);
      }
   }
   tt_free2((void**)&cmag,"cmag");
   *cmag0=cste;
   *d_cmag0=d_cste;
   return(OK_DLL);
}

int focas_main2(char *nom_fichier1,int type_fichier1,
		 char *nom_fichier2,int type_fichier2,
		 int flag_focas,
		 int flag_sature1,
		 int flag_sature2,
		 char *nom_fichier_com,char *nom_fichier_dif,
		 int *nbcom,
		 double *transf_1vers2,double *transf_2vers1,
               double epsilon, double delta, double seuil_poids)
/*************************************************************************/
/* FOCAS_MAIN                                                            */
/* But : appariement de deux listes d'etoiles sorties de KAOPHOT         */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* 1) Charge les deux listes en memoire. La liste cible est NOM_FICHIER1 */
/*    et la liste de reference est NOM_FICHIER2.                         */
/* 2) Trie chaque liste selon les magnitudes croissantes.                */
/* 3) Extrait un lot des NOBJ premieres etoiles de chaque liste.         */
/* 4) Appel a FOCAS_MATCH. Cree une liste de correspondances.            */
/* 5) Si le nombre de meilleures correspondances est superieur ou        */
/*    egal a 4 alors on a trouve le bon l'appariement. Sinon, on         */
/*    revient au point 3) en prenant les NOBJ etoiles suivantes.         */
/* 6) On calcule la matrice de transformation des coordonnees des        */
/*    etoiles de la liste 1 dans le repere des coordonnees de la liste   */
/*    2. (appel a FOCAS_REGISTER).                                       */
/* 7) On effectue l'appariement des deux listes completes d'etoiles.     */
/*    L'appariement est bon lorsque la distance entre les deux etoiles   */
/*    est inferieure a 1 pixel.                                          */
/* 8) On sauvegarde la liste commune des etoiles appariees dans le       */
/*    fichier NOM_FICHIER0.                                              */
/*                                                                       */
/* Parametres d'entree :                                                 */
/*   NOM_FICHIER1  : fichier d'etoiles (champ de reference).             */
/*   TYPE_FICHIER1 : flag indiquant le type de NOM_FICHIER1              */
/*                   =0 pour un ordre des colonnes type KAOPHOT 1        */
/*                      indice X Y fwhmx fwhmy I mag fond qualite        */
/*                   =1 pour un ordre des colonnes type NOM_FICHIER_COM: */
/*                      X1 Y1 mag1 X2 Y2 mag2 mag1-2 qualite1 qualite2   */
/*                      (lit l'indice 1)                                 */
/*                   =2 pour un ordre des colonnes type NOM_FICHIER_COM: */
/*                      X1 Y1 mag1 X2 Y2 mag2 mag1-2 qualite1 qualite2   */
/*                      (lit l'indice 2)                                 */
/*                   =3 pour un ordre des colonnes type KAOPHOT 2        */
/*                      indice X Y mag_relative AD DEC mag qualite fwhm  */
/*                      sharp                                            */
/*   NOM_FICHIER2  : fichier d'etoiles (champ a apparier).               */
/*   TYPE_FICHIER2 : flag indiquant le type de NOM_FICHIER2              */
/*   FLAG_FOCAS    : flag interne permettant de choisir des options :    */
/*    =0 : pour effectuer un appariement simple (FOCAS)                  */
/*    =1 : pour contraindre des translations (AUTOTRANS)                 */
/*    =2 : effectue l'appariement avec les coefs de *transf_1vers2 et    */
/*         *transf_2vers1 sans passer par FOCAS.                         */
/*   FLAG_SATURE1  : flag interne permettant de choisir des options :    */
/*    =0 : pour exclure les etoiles qui saturent dans le matching        */
/*    =1 : pour inclure les etoiles qui saturent dans le matching        */
/*   FLAG_SATURE2  : flag interne permettant de choisir des options :    */
/*    =0 : pour inclure les etoiles qui saturent dans les fichiers       */
/*         de sortie.                                                    */
/*    =1 : pour exclure les etoiles qui saturent dans les fichiers       */
/*         de sortie.                                                    */
/*                                                                       */
/* Parametres de sortie :                                                */
/* *NOM_FICHIER_COM : nom de fichier qui contiendra la liste des etoiles */
/*                    communes aux deux tableaux d'entree.               */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/* *NOM_FICHIER_DIF : nom de fichier qui contiendra la liste des etoiles */
/*                    differentes aux deux tableaux d'entree.            */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x2/1 y2/1 mag2/2 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/*                     (x1,y1) coordonnees (x2,y2) dans le repere 1      */
/*   *NBCOM         : nombre d'etoiles communes aux deux fichiers        */
/*   *TRANSF_1VERS2 : coefficients de transfert liste 1 vers la liste 2  */
/*     ce tableau comporte 12 elements references ainsi :    */
/*     x1/2 = [1*6+1] * x1/1 + [1*6+2] * y1/1 + [1*6+3] + [1*6+4]*x1/1*y1/1 + [1*6+5]*x1/1*x1/1 + [1*6+6]*y1/1*y1/1   */
/*     y1/2 = [2*6+1] * x1/1 + [2*6+2] * y1/1 + [2*6+3] + [2*6+4]*x1/1*y1/1 + [2*6+5]*x1/1*x1/1 + [2*6+6]*y1/1*y1/1   */
/*   *TRANSF_2VERS1 : coefficients de transfert liste 2 vers la liste 1  */
/*     ce tableau comporte 12 elements references ainsi :    */
/*     x2/1 = [1*6+1] * x2/2 + [1*6+2] * y2/2 + [1*6+3] + [1*6+4]*x2/2*y2/2 + [1*6+5]*x2/2*x2/2 + [1*6+6]*y2/2*y2/2    */
/*     y2/1 = [2*6+1] * x2/2 + [2*6+2] * y2/2 + [2*6+3] + [1*6+4]*x2/2*y2/2 + [1*6+5]*x2/2*x2/2 + [1*6+6]*y2/2*y2/2    */
/*                                                                       */
/*************************************************************************/
{
   int n1,nb1deb,nb1fin,n2,nb2deb,nb2fin,sortie0=0;
   int nb1,nb1tot;
   struct focas_tableau_entree *data_tab10=NULL;
   struct focas_tableau_entree *data_tab1=NULL;
   int nb2,nb2tot;
   struct focas_tableau_entree *data_tab20=NULL;
   struct focas_tableau_entree *data_tab2=NULL;
   struct focas_tableau_corresp *corresp=NULL;
   struct focas_tableau_corresp *differe=NULL;
   int nb,nbc=0,indice_cut1=0,indice_cut2=0,nobj;
   /*
   double epsilon,delta=1.0;
   */
   int poids_max;
   int nb_coef_a=6,total=0,nbcmax,flag_corresp,flag_tri,nbmax;
   int nombre,taille,msg;

   *nbcom=0;

   /*============================================================*/
   /*= lit les donnees completes des deux tables ASCII           */
   /*============================================================*/

   /*--- lecture des donnees dans le fichier #1.lst de autophot ---*/
   if ((msg=focas_compte_lignes(nom_fichier1,&nb1tot))!=OK) {
      return(msg);
   }
   nombre=nb1tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab10,&nombre,&taille,"data_tab10"))!=OK) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab10");
      return(PB);
   }
   if (focas_get_tab(nom_fichier1,type_fichier1,&nb1tot,data_tab10,flag_sature1)!=OK) {tt_free(data_tab10,"data_tab10");return(PB); }
   /*--- lecture des donnees dans le fichier #2.lst de autophot ---*/
   if ((msg=focas_compte_lignes(nom_fichier2,&nb2tot))!=OK) {
      tt_free(data_tab10,"data_tab10");
      return(msg);
   }
   nombre=nb2tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab20,&nombre,&taille,"data_tab20"))!=OK) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab20");
      tt_free2((void**)&data_tab10,"data_tab10");
      return(PB);
   }
   if (focas_get_tab(nom_fichier2,type_fichier2,&nb2tot,data_tab20,flag_sature1)!=OK) { tt_free(data_tab10,"data_tab10");tt_free(data_tab20,"data_tab20");return(PB); }
   /*
   printf("1. La liste %s comporte %d etoiles.\n",nom_fichier1,nb1tot);
   printf("2. La liste %s comporte %d etoiles.\n",nom_fichier2,nb2tot);
   */

   /* ============================================== */
   /* === effectue l'appariement des deux listes === */
   /* ============================================== */
   nbmax=(nb2tot>nb1tot)?nb2tot:nb1tot;
   if ((flag_focas==0)||(flag_focas==1)) {
      if ((nb1tot==0)||(nb2tot==0)) {
	 /* - cas : il n'y a pas d'etoiles dans les listes -*/
	 nbc=0;
	 sortie0=1;
	 nb1=nb2=1;
	 /* - allocation de corresp -*/
	 nombre=(nb1+1)*nb2+1;
	 taille=sizeof(struct focas_tableau_corresp);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&corresp,&nombre,&taille,"corresp"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer corresp");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    return(PB);
	 }
      } else {
	 sortie0=0;
      }
      /*============================================================*/
      /*= identifie l'accord entre des parties des deux listes      */
      /*============================================================*/
      nobj=FOCAS_NOBJINI;
      if (epsilon==0.) {
         epsilon=FOCAS_EPSIINI;
      }
      if (seuil_poids==0.) {
         seuil_poids=1./3.;
      }
      if (delta==0.) {
         delta=1.0;
      }
      /*nb_essais=1; ?*/
      while (sortie0==0) {
	 nb1deb=1;
	 nb2deb=1;
	 nb1=nb1fin= (nb1tot>nobj) ? nobj : nb1tot ;
	 nb2=nb2fin= (nb2tot>nobj) ? nobj : nb2tot ;

	 /*--- dimensionne les tableaux de pointeurs ---*/
	 nombre=nb1fin+2;
	 taille=sizeof(struct focas_tableau_entree);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab1,&nombre,&taille,"data_tab1"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab1");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    return(PB);
	 }
	 nombre=nb2fin+2;
	 taille=sizeof(struct focas_tableau_entree);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab2,&nombre,&taille,"data_tab2"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer data_tab2");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&data_tab1,"data_tab1");
	    return(PB);
	 }
	 nombre=nbmax+1;
	 taille=sizeof(struct focas_tableau_corresp);
	 if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&corresp,&nombre,&taille,"corresp"))!=0) {
	    tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer corresp");
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&data_tab1,"data_tab1");tt_free2((void**)&data_tab2,"data_tab2");
	    return(PB);
	 }
	 n1=nb1deb;

	 /* --- extrait le lot LISTE 1 d'etoiles de #1.lst ---*/
	 do {
	    data_tab1[n1-nb1deb+1].x      =data_tab10[n1].x;
	    data_tab1[n1-nb1deb+1].y      =data_tab10[n1].y;
	    data_tab1[n1-nb1deb+1].mag    =data_tab10[n1].mag;
	    data_tab1[n1-nb1deb+1].qualite=data_tab10[n1].qualite;
	    data_tab1[n1-nb1deb+1].ad     =data_tab10[n1].ad;
	    data_tab1[n1-nb1deb+1].dec    =data_tab10[n1].dec;
	    data_tab1[n1-nb1deb+1].mag_gsc=data_tab10[n1].mag_gsc;
	    data_tab1[n1-nb1deb+1].type   =data_tab10[n1].type;
	    /*
	    // Ecrire une procedure qui recherche XXmin1,xxmax1,yymin1,yymax1
	    // en scannant *data_tab10
	    // if ((data_tab10[n1].x>=xxmin1)&&(data_tab10[n1].x<=xxmax1)&&
	    //     (data_tab10[n1].y>=yymin1)&&(data_tab10[n1].y<=yymax1) ) {
	    */
	    n1++;
	    /*// }*/
	 } while (n1<=nb1fin) ; /* revoir cette condition de sortie ##*/
	 n2=nb2deb;

	 /* --- extrait le lot LISTE 2 d'etoiles de #2.lst ---*/
	 do {
	    data_tab2[n2-nb2deb+1].x      =data_tab20[n2].x;
	    data_tab2[n2-nb2deb+1].y      =data_tab20[n2].y;
	    data_tab2[n2-nb2deb+1].mag    =data_tab20[n2].mag;
	    data_tab2[n2-nb2deb+1].qualite=data_tab20[n2].qualite;
	    data_tab2[n2-nb2deb+1].ad     =data_tab20[n2].ad;
	    data_tab2[n2-nb2deb+1].dec    =data_tab20[n2].dec;
	    data_tab2[n2-nb2deb+1].mag_gsc=data_tab20[n2].mag_gsc;
	    data_tab2[n2-nb2deb+1].type   =data_tab20[n2].type;
	    /*
	    // if ((data_tab20[n2].x>=xxmin2)&&(data_tab20[n2].x<=xxmax2)&&
	    //     (data_tab20[n2].y>=yymin2)&&(data_tab20[n2].y<=yymax2) ) {
	    */
	    n2++;
	    /*// }*/
	 } while (n2<=nb2fin) ;

	 /* --- On rentre ici dans le coeur de l'algo Focas ! ---*/
	 if (focas_match(data_tab1,nb1,data_tab2,nb2,epsilon,seuil_poids,corresp,&nbc,&poids_max,&indice_cut1,&indice_cut2)!=OK) {
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&data_tab1,"data_tab1");tt_free2((void**)&data_tab2,"data_tab2");
	    tt_free2((void**)&corresp,"corresp");
	    return(PB);
	 }
	 tt_free2((void**)&data_tab1,"data_tab1");
	 tt_free2((void**)&data_tab2,"data_tab2");

	 /*--- conditions de sortie ---*/
	 nb=(nb1<nb2) ? nb1 : nb2;
	 /*pmax=(nb*nb-3*nb+2)/2;*/
	 nb=(nb <4  ) ? nb  : 4  ;
	 if (nbc>=nb) {
	    /* - calcule les matrices de transformation -*/
	    if (focas_register2(corresp,nbc,transf_1vers2,transf_2vers1)!=OK) {
	       tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	       tt_free2((void**)&corresp,"corresp");
	       return(PB);
	    }
	    /*
	    printf("%f %f : %f\n",transf_1vers2[1*6+1],transf_1vers2[1*6+2],transf_1vers2[1*6+3],transf_1vers2[1*6+4],transf_1vers2[1*6+5],transf_1vers2[1*6+6]);
	    printf("%f %f : %f\n",transf_1vers2[2*6+1],transf_1vers2[2*6+2],transf_1vers2[2*6+3],transf_1vers2[2*6+4],transf_1vers2[2*6+5],transf_1vers2[2*6+6]);
	    */
	    /* - calcul le nombre total d'appariements -*/
	    if (focas_liste_commune2("","",data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,delta,&total,corresp,corresp,0)!=OK) {
	       tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	       tt_free2((void**)&corresp,"corresp");
	       return(PB);
	    }
	 }
	 /*if ((nbc>=nb)&&(total>=nbc)) { sortie0=1; }*/
	 if (nbc>=nb) { sortie0=1; }
     else {sortie0=1; nbc=0;}
	 if (flag_focas==1) {
	    /* - cas : contraintes en translations -*/
	    if ((fabs(transf_2vers1[1*nb_coef_a+1]-1.0)>2e-2)||
		(fabs(transf_2vers1[1*nb_coef_a+2]    )>2e-2)||
		(fabs(transf_2vers1[2*nb_coef_a+1]    )>2e-2)||
		(fabs(transf_2vers1[2*nb_coef_a+2]-1.0)>2e-2)  ) {
	       sortie0=0;
	    }
	 }
     /*
	 if (poids_max>pmax)  { sortie0=0; epsilon/=2; boucle=-1; }
	 else                 {            epsilon*=2; boucle= 1; }
	 if ((boucle-boucle_old)>= 2) {epsilon=5e-5;}
	 if ((boucle-boucle_old)<=-2) {epsilon=5e-1;}
	 if (nb_essais>0) {
	    nb_essais++;
	    nb=(nb1>nb2) ? nb1 : nb2;
	    nb20=(nb>FOCAS_NOBJINI) ? FOCAS_NOBJINI : nb ;
	    if (epsilon>1e-1)       { nobj+=10;  epsilon=FOCAS_EPSIINI; boucle=0; }
	    if (nobj>nb)            { nb_essais=-1; nobj=nb20; epsilon=FOCAS_EPSIINI; boucle=0; }
	    if (epsilon<1e-4)       { nb_essais=-1; nobj=nb20; epsilon=FOCAS_EPSIINI; boucle=0; }
	    if (nobj>FOCAS_NOBJMAX) { nb_essais=-1; nobj=nb20; epsilon=FOCAS_EPSIINI; boucle=0; }
	 }
	 if (nb_essais<0) {
	    nb_essais--;
	    if (epsilon>1e-1) { nobj--; epsilon=FOCAS_EPSIINI; boucle=0; }
	    if (epsilon<1e-4) { nobj--; epsilon=FOCAS_EPSIINI; boucle=0; }
	    if (nobj<1)       { nbc=0; sortie0=1; boucle=0; }
	 }
	 if (fabs(nb_essais)>10) { nbc=0; sortie0=1; }
     */
	 if (sortie0==0) {
	    tt_free2((void**)&corresp,"corresp");
	    /*boucle_old=boucle;*/
	 }
	 /*
	 printf(" ======= nb_essais=%d sortie0=%d nbc=%d eps=%f nobj=%d\n",nb_essais,sortie0,nbc,epsilon,nobj);
	 scanf("%d",&riena);
	 */
      }
      /* - Cas de non correspondance. On apparie alors les deux -*/
      /* - etoiles les plus brillantes. -*/
      if (nbc==0) {
	 corresp[1].indice1=0;
	 corresp[1].x1     =data_tab10[0].x;
	 corresp[1].y1     =data_tab10[0].y;
	 corresp[1].indice2=0;
	 corresp[1].x2     =data_tab20[0].x;
	 corresp[1].y2     =data_tab20[0].y;
	 if (focas_register2(corresp,1,transf_1vers2,transf_2vers1)!=OK) {
	    tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	    tt_free2((void**)&corresp,"corresp");
	    return(PB);
	 }
      }
      tt_free2((void**)&corresp,"corresp");
   }

   /* =============================================================== */
   /* = Les matrices de tranformation sont deja calculees et on va  = */
   /* = maintenant etablir les tableaux de correspondance entre les = */
   /* = deux listes.                                                = */
   /* =============================================================== */
   nbcmax=(nb1tot>nb2tot)?nb1tot:nb2tot;

   /* --- on dimensionne les listes de correspondance et de differences ---*/
   nombre=nbcmax+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&corresp,&nombre,&taille,"corresp"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer corresp");
      tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
   return(PB);
   }
   nombre=nbcmax+1;
   taille=sizeof(struct focas_tableau_corresp);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&differe,&nombre,&taille,"differe"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_main for pointer differe");
      tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
      tt_free2((void**)&corresp,"corresp");
   return(PB);
   }

   /* --- On remplit les tableaux de correspondance et de difference   ---*/
   /* --- et l'on calcule une matrice de passage entre les deux listes ---*/
   flag_corresp=(flag_sature2==0)?1:2;
   if ((nbc!=0)&&((flag_focas==0)||(flag_focas==1))) {
      if (focas_liste_commune2("","",data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,delta,&nbc,corresp,differe,1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
      /* - on calcule la matrice de passage d'une liste a l'autre  -*/
      if (focas_register2(corresp,nbc,transf_1vers2,transf_2vers1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
   }

   flag_tri=1; /* a faire rentrer comme parametre de focas main...*/
   /* --- ? ---*/
   if (flag_tri==0) {
      if (focas_get_tab(nom_fichier1,type_fichier1,&nb1tot,data_tab10,flag_sature1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
      if (focas_get_tab(nom_fichier2,type_fichier2,&nb2tot,data_tab20,flag_sature1)!=OK) {
	 tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
	 tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
	 return(PB);
      }
      flag_corresp+=10;
   }

   /* --- On remplit les tableaux de correspondance et de difference   ---*/
   /* --- et l'on calcule une matrice de passage entre les deux listes ---*/
   if (focas_liste_commune2(nom_fichier_com,nom_fichier_dif,data_tab10,nb1tot,data_tab20,nb2tot,transf_1vers2,transf_2vers1,nb_coef_a,delta,&nbc,corresp,differe,flag_corresp)!=OK) {
      tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
      tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
      return(PB);
   }

   /* --- Cas de translations contraintes ---*/
   if ((nbc!=0)&&(flag_focas==1)&&((flag_focas==0)||(flag_focas==1))) {
      focas_transmoy2(corresp,nbc,transf_1vers2,transf_2vers1);
   }

   tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
   tt_free2((void**)&corresp,"corresp");tt_free2((void**)&differe,"differe");
   tt_free2((void**)&data_tab10,"data_tab10");tt_free2((void**)&data_tab20,"data_tab20");
   *nbcom=nbc;

   return(OK);
}

int focas_liste_commune2(char *nom_fichier_com,char *nom_fichier_dif,
			struct focas_tableau_entree *data_tab10,int nb1tot,
			struct focas_tableau_entree *data_tab20,int nb2tot,
			double *transf12,double *transf21,int nb_coef_a,
			double delta,
			int *total,
			struct focas_tableau_corresp *corresp,
			struct focas_tableau_corresp *differe,
			int flag_corresp)
/*************************************************************************/
/* FOCAS_LISTE_COMMUNE                                                   */
/* But : cree une liste de correspondance entre 2 listes *data_tab       */
/* D'apres : Faint-Object Classification and Analysis System             */
/*           F.G. Valdes et el. 1995, PASP 107, 1119-1128.               */
/*                                                                       */
/* 1) Compte (et eventuellement assigne dans le tableau *corresp si      */
/*    flag_corresp==1) les correspondances entre les deux tableaux       */
/*    d'entrees en connaissant les coefficients de transformation.       */
/* Si flag_corresp==1 alors on peut avoir 2 :                            */
/* 2) Compte et Assigne la liste des etoiles qui different dans la zone  */
/*    commune aux deux images (tableau *differe).                        */
/* Si flag_corresp==1 et *nom_fichier_com!="" alors on peut avoir 3 :    */
/* 3) Trie le tableau *corresp dans l'ordre des plus grands vers les     */
/*    plus petits ecarts par rapport a la moyenne des ecarts en          */
/*    magnitude. Puis, ecrit la liste dans le fichier *nom_fichier_com.  */
/* Si flag_corresp==1 et *nom_fichier_dif!="" alors on peut avoir 4 :    */
/* 4) Trie le tableau *differe dans l'ordre des plus grandes vers les    */
/*    plus petites brillances d'etoiles.                                 */
/*    Puis, ecrit la liste dans le fichier *nom_fichier_dif.             */
/*                                                                       */
/* ENTREES :                                                             */
/* *NOM_FICHIER_COM : nom de fichier qui contiendra la liste des etoiles */
/*                    communes aux deux tableaux d'entree.               */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x1/1 y1/1 mag1/1 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/* *NOM_FICHIER_DIF : nom de fichier qui contiendra la liste des etoiles */
/*                    differentes aux deux tableaux d'entree.            */
/*                    ="" ne genere pas de fichier (voir flag_corresp=0).*/
/*                    L'odre des colonnes est :                          */
/*                     x2/1 y2/1 mag2/2 x2/2 y2/2 mag2/2                 */
/*                     mag1-2 qualite1 qualite2                          */
/*                     (qualite=-1 si sature sinon =1)                   */
/*                     (x1,y1) coordonnees (x2,y2) dans le repere 1      */
/* *data_tab10 : tableau des entrees 1.                                  */
/* nb1tot      : nombre d'entrees dans le tableau 1.                     */
/* *data_tab20 : tableau des entrees 2.                                  */
/* nb2tot      : nombre d'entrees dans le tableau 2.                     */
/* *transf12   : coefficients de transformation 1 vers 2.                */
/* *transf21   : coefficients de transformation 2 vers 1.                */
/* nb_coef_a   : dimension des tableaux des coefficients de              */
/*               transformation (=6).                                    */
/* delta       : dimension, en pixels, du cote du carre d'incertitude    */
/*               pour l'appariement de deux etoiles (=1.0).              */
/* flag_corresp: =0 compte uniquement le nombre d'etoiles en commun.     */
/*                  Ne modifie pas les tableaux *corresp et *differe.    */
/*                  A employer ave les noms de fichiers = "".            */
/*               =1 modifie les tableaux *corresp et *differe et inclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et trie les listes en magnitudes.                    */
/*               =2 modifie les tableaux *corresp et *differe et exclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et trie les listes en magnitudes.                    */
/*              =11 modifie les tableaux *corresp et *differe et inclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et ne trie pas les listes en magnitudes.             */
/*              =12 modifie les tableaux *corresp et *differe et exclut  */
/*                  les etoiles qui saturent dans les fichiers de sortie */
/*                  et ne trie pas les listes en magnitudes.             */
/*                                                                       */
/* SORTIES :                                                             */
/* *total   : nombre total d'etoiles en correspondance.                  */
/* *corresp : tableau des correspondances entre les deux listes.         */
/*            non affecte si flag_corresp==0.                            */
/* *differe : tableau des differences entre les deux listes.             */
/*            non affecte si flag_corresp==0.                            */
/*************************************************************************/
{
   int fichier_com;
   FILE *hand_com;
   int fichier_dif;
   FILE *hand_dif;
   int i,totall_cor=0,totall_dif=0,accord;
   int i1,i2,nbdmin,flag_tri;
   double x1,x2,y1,y2;
   double x,y,poids,delta2,dist2,*dmin,m;
   double xmin,xmax,ymin,ymax,bordure;
   char ligne[255];
   struct focas_tableau_entree *data_tab100;
   struct focas_tableau_entree *data_tab200;
   int *deja_pris;
   int nombre,taille,msg;
   char message_err[TT_MAXLIGNE];

   flag_tri=1;
   if (flag_corresp==11) {flag_corresp=1; flag_tri=0;}
   if (flag_corresp==12) {flag_corresp=2; flag_tri=0;}

   /* --- initialisation des listes d'etoiles et des tableaux ---*/
   data_tab100=NULL;
   data_tab200=NULL;
   deja_pris=NULL;
   dmin=NULL;
   nombre=nb1tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab100,&nombre,&taille,"data_tab100"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer data_tab100");
      return(PB);
   }
   nombre=nb2tot+1;
   taille=sizeof(struct focas_tableau_entree);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&data_tab200,&nombre,&taille,"data_tab200"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer data_tab200");
      tt_free2((void**)&data_tab100,"data_tab100");
      return(PB);
   }
   nombre=nb1tot+1;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&deja_pris,&nombre,&taille,"deja_pris"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer deja_pris");
      tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
      return(PB);
   }
   for (i=0;i<nombre;i++) { deja_pris[i]=0; }
   nbdmin=(nb1tot>nb2tot)?nb1tot:nb2tot;
   nombre=nbdmin+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&dmin,&nombre,&taille,"dmin"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_liste_commune for pointer deja_pris");
      tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
      tt_free2((void**)&deja_pris,"deja_pris");
      return(PB);
   }

   if (strcmp(nom_fichier_com,"")==0) {fichier_com=0;} else {fichier_com=1;}
   if (strcmp(nom_fichier_dif,"")==0) {fichier_dif=0;} else {fichier_dif=1;}

   /* --- On remplit les listes d'etoiles ---*/
   for (i=1;i<=nb1tot;i++) {
      data_tab100[i].x=data_tab10[i].x;
      data_tab100[i].y=data_tab10[i].y;
      data_tab100[i].mag=data_tab10[i].mag;
      data_tab100[i].ad=data_tab10[i].ad;
      data_tab100[i].dec=data_tab10[i].dec;
      data_tab100[i].mag_gsc=data_tab10[i].mag_gsc;
      data_tab100[i].type=data_tab10[i].type;
   }
   for (i=1;i<=nb2tot;i++) {
      x=data_tab20[i].x;
      y=data_tab20[i].y;
      data_tab200[i].x=transf21[1*nb_coef_a+1]*x+transf21[1*nb_coef_a+2]*y+transf21[1*nb_coef_a+3]+transf21[1*nb_coef_a+4]*x*y+transf21[1*nb_coef_a+5]*x*x+transf21[1*nb_coef_a+6]*y*y;
      data_tab200[i].y=transf21[2*nb_coef_a+1]*x+transf21[2*nb_coef_a+2]*y+transf21[2*nb_coef_a+3]+transf21[2*nb_coef_a+4]*x*y+transf21[2*nb_coef_a+5]*x*x+transf21[2*nb_coef_a+6]*y*y;
      data_tab200[i].mag=data_tab20[i].mag;
      data_tab200[i].ad=data_tab20[i].ad;
      data_tab200[i].dec=data_tab20[i].dec;
      data_tab200[i].mag_gsc=data_tab20[i].mag_gsc;
      data_tab200[i].type=data_tab20[i].type;
   }

   if (delta<=0) {delta=1;}
   delta2=delta*delta;
   bordure=3; /* pixels*/
   ymin=1e9;
   ymax=0;
   xmin=1e9;
   xmax=0;
   /* boucle de recherche des bornes de l'image commune */
   for (i1=1;i1<=nb1tot;i1++) {
      x1=data_tab100[i1].x;
      y1=data_tab100[i1].y;
      dmin[i1]=1e9;
      if (x1<xmin) {xmin=x1;}
      if (x1>xmax) {xmax=x1;}
      if (y1<ymin) {ymin=y1;}
      if (y1>ymax) {ymax=y1;}
   }
   xmin+=bordure;
   ymin+=bordure;
   xmax-=bordure;
   ymax-=bordure;
   /* Calcul des distances minimales*/
   for (i2=1;i2<=nb2tot;i2++) {
      x2=data_tab200[i2].x;
      y2=data_tab200[i2].y;
      dmin[i2]=1e9;
      for (i1=1;i1<=nb1tot;i1++) {
	 x1=data_tab100[i1].x;
	 y1=data_tab100[i1].y;
	 dist2=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
	 if (dist2<dmin[i2]) {
	    dmin[i2]=dist2;
	    /*if (i2==2) {printf("i1=%d dist2=%f\n",i1,dist2);}*/
	 }
      }
   }

   /* grande boucle des assignations pbtt */
   totall_cor=0;
   totall_dif=0;
   for (i2=1;i2<=nb2tot;i2++) {
      x2=data_tab200[i2].x;
      y2=data_tab200[i2].y;
      accord=0;
      for (i1=1;i1<=nb1tot;i1++) {
	 x1=data_tab100[i1].x;
	 y1=data_tab100[i1].y;
	 dist2=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
	 if ((dist2==dmin[i2])&&(deja_pris[i1]==(int)(0))&&(dist2<=delta2)) {
	    totall_cor++;accord=1;
	    deja_pris[i1]=(int)(1);
	    if ((data_tab100[i1].type==-1)&&(flag_corresp==2)) {
	       totall_cor--;
	    } else {
	       /*
	       if (totall_cor>nbdmin) {
		  totall_cor=nbdmin;
	       }
	       */
	       corresp[totall_cor].indice1=i1;
	       corresp[totall_cor].x1=x1;
	       corresp[totall_cor].y1=y1;
	       corresp[totall_cor].mag1=data_tab100[i1].mag;
	       x=data_tab200[i2].x;
	       y=data_tab200[i2].y;
	       corresp[totall_cor].indice2=i2;
	       corresp[totall_cor].x2=transf12[1*nb_coef_a+1]*x+transf12[1*nb_coef_a+2]*y+transf12[1*nb_coef_a+3]+transf12[1*nb_coef_a+4]*x*y+transf12[1*nb_coef_a+5]*x*x+transf12[1*nb_coef_a+6]*y*y;
	       corresp[totall_cor].y2=transf12[2*nb_coef_a+1]*x+transf12[2*nb_coef_a+2]*y+transf12[2*nb_coef_a+3]+transf12[2*nb_coef_a+4]*x*y+transf12[2*nb_coef_a+5]*x*x+transf12[2*nb_coef_a+6]*y*y;
	       corresp[totall_cor].mag2=data_tab200[i2].mag;
	       x-=x1;
	       y-=y1;
	       poids=1-(x*x+y*y)/(2*delta2);
	       corresp[totall_cor].poids=poids;
	       corresp[totall_cor].ad=data_tab200[i2].ad;
	       corresp[totall_cor].dec=data_tab200[i2].dec;
	       corresp[totall_cor].mag_gsc=data_tab200[i2].mag_gsc;
	       corresp[totall_cor].type1=data_tab100[i1].type;
	       corresp[totall_cor].type2=data_tab200[i2].type;
	    }
	 }
      }
      if (accord==0) {
	 if (flag_corresp>=1) {
	    if ((x2>xmin)&&(x2<xmax)&&(y2>ymin)&&(y2<ymax)) {
	       totall_dif++;
	       /*
	       if (totall_dif>nbdmin) {
		  totall_dif=nbdmin;
	       }
	       */
	       differe[totall_dif].indice2=i2;
	       differe[totall_dif].x1=x2;
	       differe[totall_dif].y1=y2;
	       differe[totall_dif].mag1=data_tab200[i2].mag;
	       differe[totall_dif].x2=transf12[1*nb_coef_a+1]*x2+transf12[1*nb_coef_a+2]*y2+transf12[1*nb_coef_a+3]+transf12[1*nb_coef_a+4]*x2*y2+transf12[1*nb_coef_a+5]*x2*x2+transf12[1*nb_coef_a+6]*y2*y2;
	       differe[totall_dif].y2=transf12[2*nb_coef_a+1]*x2+transf12[2*nb_coef_a+2]*y2+transf12[2*nb_coef_a+3]+transf12[2*nb_coef_a+4]*x2*y2+transf12[2*nb_coef_a+5]*x2*x2+transf12[2*nb_coef_a+6]*y2*y2;
	       differe[totall_dif].mag2=data_tab200[i2].mag;
	       differe[totall_dif].ad=data_tab200[i2].ad;
	       differe[totall_dif].dec=data_tab200[i2].dec;
	       differe[totall_dif].mag_gsc=data_tab200[i2].mag_gsc;
	       differe[totall_dif].type1=data_tab200[i2].type;
	       differe[totall_dif].type2=data_tab200[i2].type;
	    }
	 }
      }
   }

   /* --- ecrit les fichiers de correspondance ---*/
   if ((fichier_com==1)&&(flag_corresp>=1)) {
      if (flag_tri==1) {
	 /* trie dans l'ordre des x decroissant*/
	 for (i=1;i<=totall_cor;i++) {
	    poids=corresp[i].x1;
	    corresp[i].poids=poids;
	 }
	 if (focas_tri_corresp(corresp,totall_cor)!=OK) {
	    tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	    tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
	    return(PB);
	 }
	 /* retrie dans l'ordre des brillances decroissantes (mag croissantes)*/
	 for (i=1;i<=totall_cor;i++) {
	    poids=corresp[i].mag1;
	    corresp[i].poids=poids;
	 }
	 if (focas_tri_corresp(corresp,totall_cor)!=OK) {
	    tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	    tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
	    return(PB);
	 }
      }
      /* sortie dans le fichier commun*/
      if ((hand_com=fopen(nom_fichier_com,"wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file %s in focas_liste_commune",nom_fichier_com);
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
	 return(PB);
      }
      for (i=1;i<=totall_cor;i++) {
	 sprintf(ligne,"%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\n",
	  corresp[i].x1,corresp[i].y1,corresp[i].mag1,
	  corresp[i].x2,corresp[i].y2,corresp[i].mag2,
	  corresp[i].mag1-corresp[i].mag2,
	  corresp[i].type1,corresp[i].type2);
	 fwrite(ligne,strlen(ligne),1,hand_com);
      }
      fclose(hand_com);
      /* sortie dans le fichier commun XY.LST*/
      if ((hand_com=fopen("xy.lst","wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file xy.lst in focas_liste_commune");
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
	 return(PB);
      }
      for (i=1;i<=totall_cor;i++) {
	 /* if (corresp[i].type1>0) {   // ### */
	    m=pow(10.0,(-corresp[i].mag1/2.5));
	    sprintf(ligne,"%f\t%f\t%f\n",corresp[i].x1,corresp[i].y1,m);
	    fwrite(ligne,strlen(ligne),1,hand_com);
	 /* }*/
      }
      fclose(hand_com);
      /* sortie dans le fichier commun EQ.LST */
      if ((hand_com=fopen("eq.lst","wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file eq.lst in focas_liste_commune");
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
	 return(PB);
      }
      for (i=1;i<=totall_cor;i++) {
	 /* if (corresp[i].type1>0) {   // ###*/
	    sprintf(ligne,"%f\t%f\t%f\n",corresp[i].ad,corresp[i].dec,corresp[i].mag_gsc);
	    fwrite(ligne,strlen(ligne),1,hand_com);
	 /* }*/
      }
      fclose(hand_com);
   }

   /* --- ecrit le fichier des differences ---*/
   if ((fichier_dif==1)&&(flag_corresp>=1)) {
      if (flag_tri==1) {
	 /* trie dans l'ordre des brillances decroissantes (mag croissantes)*/
	 for (i=1;i<=totall_dif;i++) {
	    poids=differe[i].mag2;
	    differe[i].poids=poids;
	 }
	 if (focas_tri_corresp(differe,totall_dif)!=OK) {
	    tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	    tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
	    return(PB);
	 }
      }
      /* sortie dans le fichier differe*/
      if ((hand_dif=fopen(nom_fichier_dif,"wt"))==NULL) {
	 msg=TT_ERR_FILE_CANNOT_BE_WRITED;
	 sprintf(message_err,"Writing error for file %s in focas_liste_commune",nom_fichier_dif);
	 tt_errlog("",msg,message_err);
	 tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
	 tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
	 return(PB);
      }
      for (i=1;i<=totall_dif;i++) {
	 sprintf(ligne,"%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\n",
	  differe[i].x1,differe[i].y1,differe[i].mag2,
	  differe[i].x2,differe[i].y2,differe[i].mag2,
	  differe[i].mag1-differe[i].mag2,
	  differe[i].type1,differe[i].type2);
	  fwrite(ligne,strlen(ligne),1,hand_dif);
      }
      fclose(hand_dif);
   }
   *total=totall_cor;
   tt_free2((void**)&data_tab100,"data_tab100");tt_free2((void**)&data_tab200,"data_tab200");
   tt_free2((void**)&deja_pris,"deja_pris");tt_free2((void**)&dmin,"dmin");
   return(OK);
}
int focas_transmoy2(struct focas_tableau_corresp *corresp,int nbcorresp,double *transf_1vers2,double *transf_2vers1)
/*************************************************************************/
/* FOCAS_TRANSMOY                                                        */
/*                                                                       */
/* Calcule la moyenne des translations entre les correspondances.        */
/* On elimine les translations en dehors de 1.5 fois l'ecart type.       */
/*************************************************************************/
{
   double stx,sty,etx,ety,seuil;
   int nb_coef_a,k,nbc;
   double *tx=NULL,*ty=NULL;
   int msg,taille,nombre;

   nb_coef_a=6;
   nombre=nbcorresp+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&tx,&nombre,&taille,"tx"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_transmoy for pointer tx");
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ty,&nombre,&taille,"ty"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in focas_transmoy for pointer ty");
      tt_free2((void**)&tx,"tx");
      return(TT_ERR_PB_MALLOC);
   }
   stx=0;
   sty=0;
   for (k=1;k<=nbcorresp;k++) {
      tx[k]=corresp[k].x2-corresp[k].x1;
      ty[k]=corresp[k].y2-corresp[k].y1;
      stx+=tx[k];
      sty+=ty[k];
   }
   tx[0]=stx/nbcorresp;
   ty[0]=sty/nbcorresp;
   etx=0;
   ety=0;
   for (k=1;k<=nbcorresp;k++) {
      etx+=((tx[0]-tx[k])*(tx[0]-tx[k]));
      ety+=((ty[0]-ty[k])*(ty[0]-ty[k]));
   }
   etx=sqrt(etx/nbcorresp);
   ety=sqrt(ety/nbcorresp);
   stx=0;
   sty=0;
   seuil=1.5;
   for (nbc=0,k=1;k<=nbcorresp;k++) {
      if ((tx[k]>(tx[0]-seuil*etx))&&(tx[k]<(tx[0]+seuil*etx))&&(ty[k]>(ty[0]-seuil*ety))&&(ty[k]<(ty[0]+seuil*ety))) {
	 stx+=tx[k];
	 sty+=ty[k];
	 nbc++;
      }
   }
   if (nbc>=1) {
      tx[0]=stx/nbc;
      ty[0]=sty/nbc;
   }
   /* sprintf(texte,"dx=%f dy=%f",tx[0],ty[0]);*/
   transf_1vers2[1*nb_coef_a+1]=1.0;
   transf_1vers2[1*nb_coef_a+2]=0.0;
   transf_1vers2[1*nb_coef_a+3]=tx[0];
   transf_1vers2[1*nb_coef_a+4]=0.0;
   transf_1vers2[1*nb_coef_a+5]=0.0;
   transf_1vers2[1*nb_coef_a+6]=0.0;
   transf_1vers2[2*nb_coef_a+1]=0.0;
   transf_1vers2[2*nb_coef_a+2]=1.0;
   transf_1vers2[2*nb_coef_a+3]=ty[0];
   transf_1vers2[2*nb_coef_a+4]=0.0;
   transf_1vers2[2*nb_coef_a+5]=0.0;
   transf_1vers2[2*nb_coef_a+6]=0.0;
   transf_2vers1[1*nb_coef_a+1]=1.0;
   transf_2vers1[1*nb_coef_a+2]=0.0;
   transf_2vers1[1*nb_coef_a+3]=-tx[0];
   transf_2vers1[1*nb_coef_a+4]=0.0;
   transf_2vers1[1*nb_coef_a+5]=0.0;
   transf_2vers1[1*nb_coef_a+6]=0.0;
   transf_2vers1[2*nb_coef_a+1]=0.0;
   transf_2vers1[2*nb_coef_a+2]=1.0;
   transf_2vers1[2*nb_coef_a+3]=-ty[0];
   transf_2vers1[2*nb_coef_a+4]=0.0;
   transf_2vers1[2*nb_coef_a+5]=0.0;
   transf_2vers1[2*nb_coef_a+6]=0.0;
   tt_free2((void**)&tx,"tx");
   tt_free2((void**)&ty,"ty");
   return(OK);
}

int tt_ima_series_astrometry2(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Calcul des parametres astrometriques d'une image                        */
/***************************************************************************/
/* le tableau a[6] contient la transformation :                            */
/*  x_cat = a[0]*x_obj + a[1]*y_obj + a[2] + a[3]*x_obj*y_obj + a[4]*x_obj*x_obj + a[5]*y_obj*y_obj */
/*  y_cat = a[6]*x_obj + a[7]*y_obj + a[8] + a[9]*x_obj*y_obj + a[10]*x_obj*x_obj + a[11]*y_obj*y_obj */
/* le tableau b[6] contient la transformation inverse :                    */
/*                                                                         */
/* - mots optionels utilisables et valeur par defaut :                     */
/***************************************************************************/
{
   TT_IMA *p_in,*p_out;
   char message[TT_MAXLIGNE];
   long nelem;
   int msg,index,k,kkk,nb;
   double flux,mag,a[12],b[12],dvalue,cmag,d_cmag;
   double cdp11,cdp12,cdp21,cdp22,valp1,valp2,cdp1,cdp2,crotap2,det;
   double x2,y2,x1,y1;
   double epsilon,delta,threshold;
   double vald;
   /*double rap_pixel,rap_cdelt,t1,t2;*/
   TT_ASTROM p;

   /* --- intialisations ---*/
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nelem=pseries->nelements;
   index=pseries->index;
   epsilon=pseries->epsilon;
   delta=pseries->delta;
   threshold=pseries->threshold;

   /* --- charge la liste d'objets associee ---*/
   if ((msg=tt_tblobjloader(p_in,p_in->load_fullname))!=0) {
      sprintf(message,"Pb from tt_tblobjloader in tt_ima_series_astrometry_1");
      tt_errlog(pseries->tmp_dir,msg,message);
      return(msg);
   }
   /* --- calcule une magnitude relative ---*/
   for (k=0;k<p_in->objelist->nrows;k++) {
      flux=p_in->objelist->flux[k];
      mag=(flux>0)?-2.5*log(flux)/(TT_LN10):(double)(TT_MAGNULL);
      p_in->objelist->mag[k]=mag;
   }
   /* --- charge la liste de catalogue associee ---*/
   if ((msg=tt_tblcatloader(p_in,p_in->load_fullname))!=0) {
      sprintf(message,"Pb from tt_tblcatloader in tt_ima_series_astrometry_1");
      tt_errlog(pseries->tmp_dir,msg,message);
      return(msg);
   }
   /* --- appel a focas ---*/
   if ((msg=tt_util_focas2(p_in,epsilon,delta,threshold,a,b,&nb,&cmag,&d_cmag))!=OK_DLL) {
      return(msg);
   }

   /* --- calcul de la fonction ---*/
   /*tt_imabuilder(p_out);*/
   tt_imacreater(p_out,p_in->naxis1,p_in->naxis2);
   for (kkk=0;kkk<(int)(nelem);kkk++) {
      dvalue=p_in->p[kkk];
      p_out->p[kkk]=(TT_PTYPE)(dvalue);
   }

   /* --- recherche des parametres de la projection dans l'entete ---*/
   tt_util_getkey_astrometry(p_in,&p);

   /* --- on complete ou modifie l'entete ---*/
   tt_imanewkey(p_out,"CATASTAR",&(nb),TINT,"Number stars matched from catalog","");
   if (nb>0) {
      tt_imanewkey(p_out,"CMAGR",&(cmag),TDOUBLE,"m=CMAG-2.5*log(Flux)","magR");
      tt_imanewkey(p_out,"D_CMAGR",&(d_cmag),TDOUBLE,"rms error for CMAGR","magR");
   }

   /* --- calcule les nouveaux parametres de projection ---*/
   x1=p.crpix1;y1=p.crpix2;
   x2=a[0]*x1+a[1]*y1+a[2]+a[3]*x1*y1+a[4]*x1*x1+a[5]*y1*y1;
   y2=a[6]*x1+a[7]*y1+a[8]+a[9]*x1*y1+a[10]*x1*x1+a[11]*y1*y1;
   tt_util_astrom_xy2radec(&p,x2,y2,&valp1,&valp2);
   cdp11=p.cd11*a[0]+p.cd12*a[3];
   cdp12=p.cd11*a[1]+p.cd12*a[4];
   cdp21=p.cd21*a[0]+p.cd22*a[3];
   cdp22=p.cd21*a[1]+p.cd22*a[4];

   /* --- calcule les parametres ancienne convention ---*/
   crotap2=tt_atan2((cdp12-cdp21),(cdp11+cdp22));
   cdp1=sqrt(cdp11*cdp11+cdp21*cdp21);
   det=cdp11*cos(crotap2);
   if (det<0) {cdp1*=-1.;}
   cdp2=sqrt(cdp12*cdp12+cdp22*cdp22);
   det=cdp22*cos(crotap2);
   if (det<0) {cdp2*=-1.;}

   /* -- tres vieille convention obsolete ? ---*/
   /*
   det=(cdp1*cdp2)/fabs(cdp1*cdp2);
   if (det<0) {cdp1*=-1.;}
   det=cdp11*cdp22-cdp21*cdp12;
   t1=atan2(cdp12*det,cdp22);
   t2=atan2(-cdp21*det,cdp11);
   rap_pixel=1.;
   rap_cdelt=1.;
   if ((p.px!=0)&&(p.py!=0)) {
      rap_pixel=p.px/p.py;
      rap_cdelt=(cdp2==0)?0.:(cdp1/cdp2);
   }
   if ((nb>3)&&(rap_cdelt>(0.95*rap_pixel))&&(rap_cdelt<(1.05*rap_pixel))) {
      p.crval1=valp1;
      p.crval2=valp2;
      p.cdelta1=cdp1;
      p.cdelta2=cdp2;
      p.crota2=crotap2;
   }
   */
   p.cd11=cdp11;
   p.cd12=cdp12;
   p.cd21=cdp21;
   p.cd22=cdp22;
   p.crval1=valp1;
   p.crval2=valp2;
   p.cdelta1=cdp1;
   p.cdelta2=cdp2;
   p.crota2=crotap2;
   tt_util_putnewkey_astrometry(p_out,&p);
   vald=a[2];
   tt_imanewkey(p_out,"PV1_0",&(vald),TDOUBLE,"Distortion constante","");
   vald=a[0];
   tt_imanewkey(p_out,"PV1_1",&(vald),TDOUBLE,"Distortion x","");
   vald=a[1];
   tt_imanewkey(p_out,"PV1_2",&(vald),TDOUBLE,"Distortion y","");
   vald=0.;
   tt_imanewkey(p_out,"PV1_3",&(vald),TDOUBLE,"Distortion r","");
   vald=a[4];
   tt_imanewkey(p_out,"PV1_4",&(vald),TDOUBLE,"Distortion x2","");
   vald=a[3];
   tt_imanewkey(p_out,"PV1_5",&(vald),TDOUBLE,"Distortion xy","");
   vald=a[5];
   tt_imanewkey(p_out,"PV1_6",&(vald),TDOUBLE,"Distortion y2","");
   vald=a[8];
   tt_imanewkey(p_out,"PV2_0",&(vald),TDOUBLE,"Distortion constante","");
   vald=a[7];
   tt_imanewkey(p_out,"PV2_1",&(vald),TDOUBLE,"Distortion y","");
   vald=a[6];
   tt_imanewkey(p_out,"PV2_2",&(vald),TDOUBLE,"Distortion x","");
   vald=0.;
   tt_imanewkey(p_out,"PV2_3",&(vald),TDOUBLE,"Distortion r","");
   vald=a[11];
   tt_imanewkey(p_out,"PV2_4",&(vald),TDOUBLE,"Distortion y2","");
   vald=a[9];
   tt_imanewkey(p_out,"PV2_5",&(vald),TDOUBLE,"Distortion yx","");
   vald=a[10];
   tt_imanewkey(p_out,"PV2_6",&(vald),TDOUBLE,"Distortion x2","");

   /* --- calcul des temps ---*/
   pseries->jj_stack=pseries->jj[index-1];
   pseries->exptime_stack=pseries->exptime[index-1];

   return(OK_DLL);
}

