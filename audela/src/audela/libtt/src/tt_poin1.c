/* tt_poin1.c
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

int tt_ptr_loadima(void *args)
/**************************************************************************/
/* Fonction d'interface pour charger les images                           */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *datatype (int*)                                                */
/* ------ sorties                                                         */
/* arg3 : *p (void*) dimensionne en interne avec malloc                   */
/* arg4 : *naxis1 (int*)                                                  */
/* arg5 : *naxis2 (int*)                                                  */
/* ------ sorties optionnelles (si arg6!=NULL)                            */
/* arg6 : *nbkeys (int*)                                                  */
/* arg7 : **keynames (char**) dimensionne en interne avec malloc          */
/* arg8 : **values (char**) dimensionne en interne avec malloc            */
/* arg9 : **comments (char**) dimensionne en interne avec malloc          */
/* arg10 : **units (char**) dimensionne en interne avec malloc            */
/* arg11 : *datatype (int*) dimensionne en interne avec malloc            */
/**************************************************************************/
/**************************************************************************/
{
   void **argu;
   int msg,k;
   char *fullname;
   int datatype;
   TT_IMA p_in;
   long firstelem,nelem;
   void **array=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[2]);

   /* --- construit un objet image ---*/
   if ((msg=tt_imabuilder(&p_in))!=0) {
      return(msg);
   }

   /* --- charge l'image ---*/
   firstelem=(long)(1);
   nelem=(long)(0);
   strcpy(p_in.load_fullname,fullname);
   if ((msg=tt_imaloader(&p_in,fullname,firstelem,nelem))!=0) {
      return(msg);
   }

   /* --- remplit les arguments de retour ---*/
   p_in.naxis3=0;
   if (p_in.naxis2==0) {
      p_in.naxis2=1;
   }
   nelem=(int)(p_in.naxis1*p_in.naxis2);
   array=(void**)(argu[3]);
   if ((msg=tt_util_calloc_ptr_datatype(array,&nelem,&datatype))!=OK_DLL) {
      return(msg);
   }
   if ((msg=tt_util_ttima2ptr(&p_in,*array,datatype,0))!=OK_DLL) {
      return(msg);
   }
   if (argu[4]!=NULL) { *(int*)(argu[4])=p_in.naxis1; }
   if (argu[5]!=NULL) { *(int*)(argu[5])=p_in.naxis2; }

   if (argu[6]!=NULL) {
      if ((msg=libtt_main0(TT_PTR_ALLOKEYS,6,&p_in.nbkeys,&keynames,&values,
       &comments,&units,&datatypes))!=0) {
	 tt_imadestroyer(&p_in);
	 return(msg);
      }
      for (k=0;k<p_in.nbkeys;k++) {
	 strcpy(keynames[k],p_in.keynames[k]);
	 strcpy(values[k],p_in.values[k]);
	 strcpy(comments[k],p_in.comments[k]);
	 strcpy(units[k],p_in.units[k]);
	 datatypes[k]=p_in.datatypes[k];
      }
      *(int*)argu[6]=p_in.nbkeys;
      *((char**)argu[7])=(void*)(keynames);
      *((char**)argu[8])=(void*)(values);
      *((char**)argu[9])=(void*)(comments);
      *((char**)argu[10])=(void*)(units);
      *(int**)(argu[11])=(datatypes);
   }

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p_in))!=OK_DLL) {
      return(msg);
   }

   return(OK_DLL);
}

int tt_ptr_loadkeys(void *args)
/**************************************************************************/
/* Fonction d'interface pour charger les mots cle                         */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *fullname (char*)                                               */
/* ------ sorties                                                         */
/* arg2 : *nbkeys (int*)                                                  */
/* arg3 : **keynames (char**) dimensionne en interne avec malloc          */
/* arg4 : **values (char**) dimensionne en interne avec malloc            */
/* arg5 : **comments (char**) dimensionne en interne avec malloc          */
/* arg6 : **units (char**) dimensionne en interne avec malloc             */
/* arg7 : *datatype (int*) dimensionne en interne avec malloc             */
/**************************************************************************/
{
   void **argu;
   TT_IMA p;
   int msg,k;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }

   /* --- construit un objet image ---*/
   if ((msg=tt_imabuilder(&p))!=0) {
      return(msg);
   }

   /* --- assigne le nom du fichier a l'objet image ---*/
   strcpy(p.load_fullname,argu[1]);
   if ((msg=tt_imafilenamespliter(p.load_fullname,p.load_path,p.load_name,p.load_suffix,&p.load_hdunum))!=0) { return(msg); }
   if (p.load_hdunum==0) {
      p.load_hdunum=1;
   }

   /* --- charge la liste de mots cle ---*/
   p.nbkeys=0;
   /* Le fait de placer un nbkeys==0 indique a la fonction de */
   /* retourner l'ensemble des mots cles et leur valeurs.     */
   /* En retour, la fonction indique le veritable nbkeys,     */
   /* effectue des 'calloc' sur **keynames, *keynames, etc... */
   /* et remplit leurs valeurs.                               */
   if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,p.load_fullname,&p.load_hdunum,&p.nbkeys,
    &p.keynames,&p.comments,&p.units,&p.datatypes,&p.values))!=0) {
       return(msg);
   }
   p.keyused=TT_YES;
   if ((msg=libtt_main0(TT_PTR_ALLOKEYS,6,&p.nbkeys,&keynames,&values,
    &comments,&units,&datatypes))!=0) {
      tt_imadestroyer(&p);
      return(msg);
   }
   for (k=0;k<p.nbkeys;k++) {
      strcpy(keynames[k],p.keynames[k]);
      strcpy(values[k],p.values[k]);
      strcpy(comments[k],p.comments[k]);
      strcpy(units[k],p.units[k]);
      datatypes[k]=p.datatypes[k];
   }
   *(int*)argu[2]=p.nbkeys;
   *((char**)argu[3])=(void*)(keynames);
   *((char**)argu[4])=(void*)(values);
   *((char**)argu[5])=(void*)(comments);
   *((char**)argu[6])=(void*)(units);
   *(int**)(argu[7])=(datatypes);

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p))!=OK_DLL) {
      return(msg);
   }

   return(OK_DLL);
}

int tt_ptr_allokeys(void *args)
/**************************************************************************/
/* Fonction d'interface pour dimensionner une liste de mots cle           */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *nbkeys (int*)                                                  */
/* ------ sorties                                                         */
/* arg2 : **keynames (char**) dimensionne en interne avec malloc          */
/* arg3 : **values (char**) dimensionne en interne avec malloc            */
/* arg4 : **comments (char**) dimensionne en interne avec malloc          */
/* arg5 : **units (char**) dimensionne en interne avec malloc             */
/* arg6 : *datatype (int*) dimensionne en interne avec malloc             */
/**************************************************************************/
{
   void **argu;
   int msg,len,nbkeys;
   char **keynames=NULL,**values=NULL,**comments=NULL,**units=NULL;
   int *datatypes=NULL,nombre,taille;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   nbkeys=*(int*)(argu[1]);

   /* --- allocation memoire des nouveaux mots cles ---*/
   keynames=NULL;
   values=NULL;
   comments=NULL;
   units=NULL;
   datatypes=NULL;
   len=(int)(FLEN_KEYWORD);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&keynames,&nbkeys,&len,"p->keynames"))!=OK_DLL) {
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&values,&nbkeys,&len,"p->values"))!=OK_DLL) {
      tt_util_free_ptrptr((void**)keynames,"p->keynames");
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_COMMENT);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&comments,&nbkeys,&len,"p->comments"))!=OK_DLL) {
      tt_util_free_ptrptr((void**)keynames,"p->keynames");
      tt_util_free_ptrptr((void**)values,"p->values");
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_COMMENT);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&units,&nbkeys,&len,"p->units"))!=OK_DLL) {
      tt_util_free_ptrptr((void**)keynames,"p->keynames");
      tt_util_free_ptrptr((void**)values,"p->values");
      tt_util_free_ptrptr((void**)comments,"p->comments");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nbkeys;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&datatypes,&nombre,&taille,"p->datatypes"))!=0) {
      tt_util_free_ptrptr((void**)keynames,"p->keynames");
      tt_util_free_ptrptr((void**)values,"p->values");
      tt_util_free_ptrptr((void**)comments,"p->comments");
      tt_util_free_ptrptr((void**)units,"p->units");
      return(TT_ERR_PB_MALLOC);
   }
   *((char**)argu[2])=(void*)(keynames);
   *((char**)argu[3])=(void*)(values);
   *((char**)argu[4])=(void*)(comments);
   *((char**)argu[5])=(void*)(units);
   *((int**)argu[6])=datatypes;
   return(OK_DLL);
}

int tt_ptr_statima(void *args)
/**************************************************************************/
/* Fonction d'interface pour calculer les statistiques                    */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *p (void*)                                                      */
/* arg2 : *datatype (int*)                                                */
/* arg3 : *naxis1 (int*)                                                  */
/* arg4 : *naxis2 (int*)                                                  */
/* ------ sorties                                                         */
/* arg5 : locut (double *)                                                */
/* arg6 : hicut (double *)                                                */
/* arg7 : maxi (double *)                                                 */
/* arg8 : mini (double *)                                                 */
/* arg9 : mean (double *)                                                 */
/* arg10 : sigma (double *)                                               */
/* arg11 : bgmean (double *)                                              */
/* arg12 : bgsigma (double *)                                             */
/* arg13 : contrast (double *)                                            */
/**************************************************************************/
{
   TT_IMA_SERIES pseries;
   int nbkeys,datatype;
   char **keys=NULL;
   void **argu;
   int msg;
   int naxis1,naxis2;
   void *p=NULL;
   double pixelsat_value=TT_MAX_DOUBLE;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   p=(void*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   naxis2=*(int*)(argu[4]);

   /* --- construit un objet de pseries ---*/
   tt_decodekeys("IMA/SERIES rep_in nom_in ind1 ind2 ext_in rep_out nom_out ind1 ext_out STAT",(void***)&keys,&nbkeys);
   //pseries.nbkeys=nbkeys;
   //if ((msg=tt_ima_series_builder(keys,1,&pseries))!=OK_DLL) {
   if ((msg=tt_ima_series_builder("STAT", 1, (TT_IMA_SERIES_OPTION*) NULL, &pseries))!=OK_DLL) {
      return(msg);
   }

   /* --- construit et remplit l'image p_out dans pseries ---*/
   /*tt_imabuilder(pseries.p_out);*/
   tt_imacreater(pseries.p_out,naxis1,naxis2);
   if ((msg=tt_util_ptr2ttima(p,datatype,(pseries.p_out)))!=OK_DLL) {
      return(msg);
   }

   /* --- raz des variables a calculer ---*/
   pseries.mean=0.;
   pseries.sigma=0.;
   pseries.mini=0.;
   pseries.maxi=0.;
   pseries.nbpixsat=0;
   pseries.bgmean=0.;
   pseries.bgsigma=0.;
   pseries.hicut=1.;
   pseries.locut=0.;
   pseries.contrast=0.;

   /* --- calcul des mini maxi mea sigma et nbpixsat ---*/
   tt_util_statima((pseries.p_out),pixelsat_value,&(pseries.mean),&(pseries.sigma),&(pseries.mini),&(pseries.maxi),&(pseries.nbpixsat));

   /* --- Calcul des parametres de fond de ciel ---*/
   tt_util_bgk((pseries.p_out),&(pseries.bgmean),&(pseries.bgsigma));

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_cuts((pseries.p_out),&pseries,&(pseries.hicut),&(pseries.locut),TT_YES);

   /* --- Calcul du critere de qualite planetaire ---*/
   tt_util_contrast((pseries.p_out),&(pseries.contrast));

   if (argu[5]!=NULL) { *(double*)(argu[5])=pseries.locut; }
   if (argu[6]!=NULL) { *(double*)(argu[6])=pseries.hicut; }
   if (argu[7]!=NULL) { *(double*)(argu[7])=pseries.maxi; }
   if (argu[8]!=NULL) { *(double*)(argu[8])=pseries.mini; }
   if (argu[9]!=NULL) { *(double*)(argu[9])=pseries.mean; }
   if (argu[10]!=NULL) { *(double*)(argu[10])=pseries.sigma; }
   if (argu[11]!=NULL) { *(double*)(argu[11])=pseries.bgmean; }
   if (argu[12]!=NULL) { *(double*)(argu[12])=pseries.bgsigma; }
   if (argu[13]!=NULL) { *(double*)(argu[13])=pseries.contrast; }

   /* --- destruction de l'objet pseries ---*/
   tt_util_free_ptrptr((void**)keys,"keys");
   tt_ima_series_destroyer(&pseries);
   return(OK_DLL);
}

int tt_ptr_cutsima(void *args)
/**************************************************************************/
/* Fonction d'interface pour calculer les seuils de visu                  */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *p (void*)                                                      */
/* arg2 : *datatype (int*)                                                */
/* arg3 : *naxis1 (int*)                                                  */
/* arg4 : *naxis2 (int*)                                                  */
/* ------ sorties                                                         */
/* arg5 : locut (double *)                                                */
/* arg6 : hicut (double *)                                                */
/* arg7 : mode (double *)                                                 */
/**************************************************************************/
{
   TT_IMA_SERIES pseries;
   //int nbkeys;
   int datatype;
   char **keys=NULL;
   void **argu;
   int msg;
   int naxis1,naxis2;
   void *p=NULL;
   double /*pixelsat_value=TT_MAX_DOUBLE,*/mode=0.,maxi=0.,mini=0.;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   p=(void*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   naxis2=*(int*)(argu[4]);

   /* --- construit un objet de pseries ---*/
   //tt_decodekeys("IMA/SERIES rep_in nom_in ind1 ind2 ext_in rep_out nom_out ind1 ext_out CUTS",(void***)&keys,&nbkeys);
   //pseries.nbkeys=nbkeys;
   //if ((msg=tt_ima_series_builder(keys,1,&pseries))!=OK_DLL) {
   if ((msg=tt_ima_series_builder("CUTS", 1, (TT_IMA_SERIES_OPTION*)NULL, &pseries))!=OK_DLL) {
      return(msg);
   }

   /* --- construit et remplit l'image p_out dans pseries ---*/
   /*tt_imabuilder(pseries.p_out);*/
   tt_imacreater(pseries.p_out,naxis1,naxis2);
   if ((msg=tt_util_ptr2ttima(p,datatype,(pseries.p_out)))!=OK_DLL) {
      return(msg);
   }

   /* --- raz des variables a calculer ---*/
   pseries.hicut=1.;
   pseries.locut=0.;

   /* --- initialisation du parametre de constraste et des bornes de l'histogramme ---*/
   pseries.cutscontrast=1.;
   pseries.hifrac=0.97;
   pseries.lofrac=0.05;

   /* --- Calcul des seuils de visualisation ---*/
   tt_util_histocuts((pseries.p_out),&pseries,&(pseries.hicut),&(pseries.locut),&mode,&maxi,&mini);

   if (argu[5]!=NULL) { *(double*)(argu[5])=pseries.locut; }
   if (argu[6]!=NULL) { *(double*)(argu[6])=pseries.hicut; }
   if (argu[7]!=NULL) { *(double*)(argu[7])=mode; }

   /* --- destruction de l'objet pseries ---*/
   tt_util_free_ptrptr((void**)keys,"keys");
   tt_ima_series_destroyer(&pseries);
   return(OK_DLL);
}

int tt_ptr_saveima(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les images                            */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *p (void*)                                                      */
/* arg3 : *datatype (int*)                                                */
/* arg4 : *naxis1 (int*)                                                  */
/* arg5 : *naxis2 (int*)                                                  */
/* arg6 : *bitpix (int*)                                                  */
/* ------ entrees facultatives                                            */
/* arg7 : *nbkeys (int*)                                                  */
/* arg8 : **keynames (char**)                                             */
/* arg9 : **values (char**)                                               */
/* arg10 : **comments (char**)                                            */
/* arg11 : **units (char**)                                               */
/* arg12 : *datatype (int*)                                               */
/**************************************************************************/
{
   TT_IMA p_out;
   int nbkeys=0,datatype;
   void **argu;
   int msg;
   int naxis1,naxis2,bitpix,k,naxis=2;
   void *p=NULL;
   char *fullname=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   p=(void*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[4]);
   if (argu[5]==NULL) { return(PB_DLL); }
   naxis2=*(int*)(argu[5]);
   if (argu[6]==NULL) { return(PB_DLL); }
   bitpix=*(int*)(argu[6]);

   /* --- verifie le nombre d'axes de l'image  ---*/
   if ((argu[7]!=NULL)&&(argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)&&(argu[12]!=NULL)) {
      nbkeys=*(int*)(argu[7]);
      keynames=(char**)(argu[8]);
      values=(char**)(argu[9]);
      comments=(char**)(argu[10]);
      units=(char**)(argu[11]);
      datatypes=(int*)(argu[12]);
      for (k=0;k<nbkeys;k++) {
         if (strcmp(keynames[k],"NAXIS")==0) {
            naxis=atoi(values[k]);
         }
         if ((naxis<1)||(naxis>2)) {
            naxis=2;
         }
      }
   }

   /* --- construit et remplit l'image p_out ---*/
   if ((msg=tt_imabuilder(&p_out))!=OK_DLL) {
      return(msg);
   }
   if (naxis==1) {
      if ((msg=tt_imacreater1d(&p_out,naxis1))!=OK_DLL) {
         return(msg);
      }
   } else {
      if ((msg=tt_imacreater(&p_out,naxis1,naxis2))!=OK_DLL) {
         return(msg);
      }
   }
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      return(msg);
   }

   /* --- remplit le header avec les nouveaux mots cle eventuels ---*/
   if ((argu[7]!=NULL)&&(argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)&&(argu[12]!=NULL)) {
      for (k=0;k<nbkeys;k++) {
	 tt_imanewkeychar(&p_out,keynames[k],values[k],datatypes[k],comments[k],units[k]);
      }
   }

   /* --- sauve l'image ---*/
   if ((msg=tt_imasaver(&p_out,fullname,bitpix))!=0) {
      return(msg);
   }

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p_out))!=OK_DLL) {
      return(msg);
   }
   return(OK_DLL);
}

int tt_ptr_savekeys(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les images                            */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *nbkeys (int*)                                                  */
/* arg3 : **keynames (char**)                                             */
/* arg4 : **values (char**)                                               */
/* arg5 : **comments (char**)                                             */
/* arg6 : **units (char**)                                                */
/* arg7 : *datatype (int*)                                                */
/**************************************************************************/
{
   void **argu;
   int msg,nbkeys,hdunum_keys;
   char fullname[FLEN_FILENAME];
   char path[FLEN_FILENAME];
   char name[FLEN_FILENAME];
   char suffix[FLEN_FILENAME];
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   if ((argu[2]==NULL)||(argu[3]==NULL)||(argu[4]==NULL)||(argu[5]==NULL)||(argu[6]!=NULL)||(argu[7]==NULL)) {
      return(PB_DLL);
   }

   /* --- assigne le nom du fichier a l'objet image ---*/
   strcpy(fullname,argu[1]);
   if ((msg=tt_imafilenamespliter(fullname,path,name,suffix,&hdunum_keys))!=0) { return(msg); }
   if (hdunum_keys==0) {
      hdunum_keys=1;
   }

   /* --- remplit les pointeurs avec les nouveaux mots cle eventuels ---*/
   nbkeys=*(int*)(argu[2]);
   keynames=(char**)(argu[3]);
   values=(char**)(argu[4]);
   comments=(char**)(argu[5]);
   units=(char**)(argu[6]);
   datatypes=(int*)(argu[7]);

   /* --- sauvegarde de la nouvelle liste de mots cle ---*/
   if (nbkeys!=0) {
      if ((msg=libfiles_main(FS_MACR_WRITE_KEYS,8,fullname,&hdunum_keys,&nbkeys,
       keynames,comments,units,datatypes,values))!=0) {
	 return(msg);
       }
   }
   return(OK_DLL);
}

int tt_ptr_savejpg(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les images en jpeg                    */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *p (void*)                                                      */
/* arg3 : *datatype (int*)                                                */
/* arg4 : *naxis1 (int*)                                                  */
/* arg5 : *naxis2 (int*)                                                  */
/* arg6 : *sb (double*)                                                   */
/* arg7 : *sh (double*)                                                   */
/* ------ entrees facultatives                                            */
/* arg8 : *qualite (int*)                                                 */
/**************************************************************************/
{
   void **argu;
   int msg;
   int naxis1,naxis2,datatype;
   void *p;
   char *fullname=NULL;
   double value;
   int qualite,color_space,kk0,kk1,x,y;
   unsigned char *pjpeg=NULL;
   double r,v,b,sb,sh,delta;
   TT_IMA p_out;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   p=(void*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[4]);
   if (argu[5]==NULL) { return(PB_DLL); }
   naxis2=*(int*)(argu[5]);
   if (argu[6]==NULL) { return(PB_DLL); }
   sb=*(double*)(argu[6]);
   if (argu[7]==NULL) { return(PB_DLL); }
   sh=*(double*)(argu[7]);

   /* --- construit et remplit l'image p_out dans pseries ---*/
   tt_imabuilder(&p_out);
   tt_imacreater(&p_out,naxis1,naxis2);
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      return(msg);
   }

   /* --- image jpeg ---*/
   color_space=JCS_RGB;
   if (argu[8]==NULL) { qualite=75; }
   else { qualite=*(int*)(argu[8]); if (qualite<1) {qualite=1;} ; if (qualite>100) {qualite=100;} }
   if ((pjpeg=(unsigned char*)tt_calloc(3*naxis1*naxis2,sizeof(unsigned char)))==NULL) {
      tt_imadestroyer(&p_out);      
	  return(TT_ERR_PB_MALLOC);
   }
   delta=sh-sb;
   if (delta==0.) {delta=1.;}
   for (kk0=0;kk0<naxis1;kk0++) {
      for (kk1=0;kk1<naxis2;kk1++) {
	 x=kk0;
	 y=naxis2-1-kk1;
	 value=(double)(p_out.p[naxis1*y+x]);
	 r=(value-sb)/delta*255;
	 if (r<0) {r=0;}
	 if (r>255) {r=255;}
	 b=v=r;
	 pjpeg[3*(naxis1*kk1+kk0)+0]=(unsigned char)(r); /* rouge */
	 pjpeg[3*(naxis1*kk1+kk0)+1]=(unsigned char)(v); /* vert */
	 pjpeg[3*(naxis1*kk1+kk0)+2]=(unsigned char)(b); /* bleu */
      }
   }
   /* --- enregistrement de l'image RGB en format JPEG --- */
   if ((msg=libfiles_main(FS_MACR_WRITE_JPG,6,fullname,&color_space,pjpeg,&naxis1,&naxis2,&qualite))!=0) {
      tt_imadestroyer(&p_out);
	  tt_free2((void**)&pjpeg,NULL);
      return(msg);
   }

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p_out))!=OK_DLL) {
	  tt_free2((void**)&pjpeg,NULL);
      return(msg);
   }
   tt_free2((void**)&pjpeg,NULL);
   return(OK_DLL);
}

int tt_ptr_savejpgcolor(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les images en jpeg couleur            */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1  : *fullname (char*)                                              */
/* arg2  : *pr (void*)                                                    */
/* arg3  : *pv (void*)                                                    */
/* arg4  : *pb (void*)                                                    */
/* arg5  : *datatype (int*)                                               */
/* arg6  : *naxis1 (int*)                                                 */
/* arg7  : *naxis2 (int*)                                                 */
/* arg8  : *sbr (double*)                                                 */
/* arg9  : *shr (double*)                                                 */
/* arg10 : *sbv (double*)                                                 */
/* arg11 : *shv (double*)                                                 */
/* arg12 : *sbb (double*)                                                 */
/* arg13 : *shb (double*)                                                 */
/* ------ entrees facultatives                                            */
/* arg14 : *qualite (int*)                                                */
/**************************************************************************/
{
   void **argu;
   int msg;
   int naxis1,naxis2,datatype;
   void *pr,*pv,*pb,*p;
   char *fullname=NULL;
   double value;
   int qualite,color_space,kk0,kk1,x,y;
   unsigned char *pjpeg=NULL;
   double sb,sh,delta;
   double sbr,shr,sbv,shv,sbb,shb,val;
   TT_IMA p_out;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   pr=(void*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   pv=(void*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   pb=(void*)(argu[4]);   
   if (argu[5]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[5]);
   if (argu[6]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[6]);
   if (argu[7]==NULL) { return(PB_DLL); }
   naxis2=*(int*)(argu[7]);
   if (argu[8]==NULL) { return(PB_DLL); }
   sbr=*(double*)(argu[8]);
   if (argu[9]==NULL) { return(PB_DLL); }
   shr=*(double*)(argu[9]);
   if (argu[10]==NULL) { return(PB_DLL); }
   sbv=*(double*)(argu[10]);
   if (argu[11]==NULL) { return(PB_DLL); }
   shv=*(double*)(argu[11]);
   if (argu[12]==NULL) { return(PB_DLL); }
   sbb=*(double*)(argu[12]);
   if (argu[13]==NULL) { return(PB_DLL); }
   shb=*(double*)(argu[13]);

    /* --- construit l'espace memoire pour l'image jpeg ---*/
   color_space=JCS_RGB;
   if (argu[14]==NULL) { qualite=75; }
   else { qualite=*(int*)(argu[14]); if (qualite<1) {qualite=1;} ; if (qualite>100) {qualite=100;} }
   if ((pjpeg=(unsigned char*)tt_calloc(3*naxis1*naxis2,sizeof(unsigned char)))==NULL) {
      return(TT_ERR_PB_MALLOC);
   }

   /* --- image rouge ---*/   
   p=pr;
   sb=sbr;
   sh=shr;
   tt_imabuilder(&p_out);
   tt_imacreater(&p_out,naxis1,naxis2);
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      tt_imadestroyer(&p_out);
	  tt_free2((void**)&pjpeg,NULL);
      return(msg);
   }
   delta=sh-sb;
   if (delta==0.) {delta=1.;}
   for (kk0=0;kk0<naxis1;kk0++) {
      for (kk1=0;kk1<naxis2;kk1++) {
	     x=kk0;
	     y=naxis2-1-kk1;
	     value=(double)(p_out.p[naxis1*y+x]);
	     val=(value-sb)/delta*255;
	     if (val<0) {val=0;}
	     if (val>255) {val=255;}
	     pjpeg[3*(naxis1*kk1+kk0)+0]=(unsigned char)(val); /* rouge */
      }
   }
   tt_imadestroyer(&p_out);
   /* --- image verte ---*/   
   p=pv;
   sb=sbv;
   sh=shv;
   tt_imacreater(&p_out,naxis1,naxis2);
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      tt_imadestroyer(&p_out);
	  tt_free2((void**)&pjpeg,NULL);
      return(msg);
   }
   delta=sh-sb;
   if (delta==0.) {delta=1.;}
   for (kk0=0;kk0<naxis1;kk0++) {
      for (kk1=0;kk1<naxis2;kk1++) {
	     x=kk0;
	     y=naxis2-1-kk1;
	     value=(double)(p_out.p[naxis1*y+x]);
	     val=(value-sb)/delta*255;
	     if (val<0) {val=0;}
	     if (val>255) {val=255;}
	     pjpeg[3*(naxis1*kk1+kk0)+1]=(unsigned char)(val); /* vert */
      }
   }
   tt_imadestroyer(&p_out);
   /* --- image bleue ---*/   
   p=pb;
   sb=sbb;
   sh=shb;
   tt_imacreater(&p_out,naxis1,naxis2);
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      tt_imadestroyer(&p_out);
	  tt_free2((void**)&pjpeg,NULL);
      return(msg);
   }
   delta=sh-sb;
   if (delta==0.) {delta=1.;}
   for (kk0=0;kk0<naxis1;kk0++) {
      for (kk1=0;kk1<naxis2;kk1++) {
	     x=kk0;
	     y=naxis2-1-kk1;
	     value=(double)(p_out.p[naxis1*y+x]);
	     val=(value-sb)/delta*255;
	     if (val<0) {val=0;}
	     if (val>255) {val=255;}
	     pjpeg[3*(naxis1*kk1+kk0)+2]=(unsigned char)(val); /* bleu */
      }
   }
   tt_imadestroyer(&p_out);

   /* --- enregistrement de l'image RGB en format JPEG --- */
   if ((msg=libfiles_main(FS_MACR_WRITE_JPG,6,fullname,&color_space,pjpeg,&naxis1,&naxis2,&qualite))!=0) {
      tt_imadestroyer(&p_out);
	  tt_free2((void**)&pjpeg,NULL);
      return(msg);
   }

   /* --- destruction de la memoire de l'image jpeg ---*/
   tt_free2((void**)&pjpeg,NULL);
   return(OK_DLL);
}

int tt_ptr_freeptr(void *args)
/**************************************************************************/
/* Fonction d'interface pour liberer la memoire d'un pointeur             */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : **p (void**)                                                    */
/**************************************************************************/
{
   void **argu;
   void *p=NULL;

   /* --- verification des arguments ---*/
   /* --- liberation memoire ---*/
   argu=(void**)(args);
   if (argu[1]!=NULL) { p=*(void**)(argu[1]); tt_free2((void**)&p,NULL); }
   return(OK_DLL);
}

int tt_ptr_freekeys(void *args)
/**************************************************************************/
/* Fonction d'interface pour liberer la memoire d'une liste de mots cle   */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : ***keynames (char***)                                           */
/* arg2 : ***values (char***)                                             */
/* arg3 : ***comments (char***)                                           */
/* arg4 : ***units (char***)                                              */
/* arg5 : **datatype (int**)                                              */
/**************************************************************************/
{
   void **argu;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- verification des arguments ---*/
   /* --- et liberation de la memoire ---*/
   argu=(void**)(args);
   if (argu[1]!=NULL) { keynames=*(char***)(argu[1]); tt_util_free_ptrptr2((void***)&keynames,"p->keynames");}
   if (argu[2]!=NULL) { values=*(char***)(argu[2]); tt_util_free_ptrptr2((void***)&values,"p->values"); }
   if (argu[3]!=NULL) { comments=*(char***)(argu[3]); tt_util_free_ptrptr2((void***)&comments,"p->comments");}
   if (argu[4]!=NULL) { units=*(char***)(argu[4]); tt_util_free_ptrptr2((void***)&units,"p->units");}
   if (argu[5]!=NULL) { datatypes=*(int**)(argu[5]); tt_free2((void**)&datatypes,"p->datatypes");}

   return(OK_DLL);
}

int tt_ptr_saveima3d(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les cubes d'images (naxis=3)          */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *p (void*)                                                      */
/* arg3 : *datatype (int*)                                                */
/* arg4 : *naxis1 (int*)                                                  */
/* arg5 : *naxis2 (int*)                                                  */
/* arg6 : *naxis3 (int*)                                                  */
/* arg7 : *bitpix (int*)                                                  */
/* ------ entrees facultatives                                            */
/* arg8 : *nbkeys (int*)                                                  */
/* arg9 : **keynames (char**)                                             */
/* arg10 : **values (char**)                                              */
/* arg11 : **comments (char**)                                            */
/* arg12 : **units (char**)                                               */
/* arg13 : *datatype (int*)                                               */
/**************************************************************************/
{
   TT_IMA p_out;
   int nbkeys,datatype;
   void **argu;
   int msg;
   int naxis1,naxis2,naxis3,bitpix,k,naxis=3;
   void *p=NULL;
   char *fullname=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   p=(void*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[4]);
   if (argu[5]==NULL) { return(PB_DLL); }
   naxis2=*(int*)(argu[5]);
   if (argu[6]==NULL) { return(PB_DLL); }
   naxis3=*(int*)(argu[6]);
   if (argu[6]==NULL) { return(PB_DLL); }
   bitpix=*(int*)(argu[7]);

   if ((argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)&&(argu[12]!=NULL)&&(argu[13]!=NULL)) {
      nbkeys=*(int*)(argu[8]);
      keynames=(char**)(argu[9]);
      values=(char**)(argu[10]);
      comments=(char**)(argu[11]);
      units=(char**)(argu[12]);
      datatypes=(int*)(argu[13]);
      for (k=0;k<nbkeys;k++) {
         if (strcmp(keynames[k],"NAXIS")==0) {
            naxis=atoi(values[k]);
         }
         if ((naxis<1)||(naxis>3)) {
            naxis=3;
         }
      }
   }

   /* --- construit et remplit l'image p_out ---*/
   if ((msg=tt_imabuilder(&p_out))!=OK_DLL) {
      return(msg);
   }
   if (naxis==1) {
      if ((msg=tt_imacreater1d(&p_out,naxis1))!=OK_DLL) {
         return(msg);
      }
   } else if (naxis==2) {
      if ((msg=tt_imacreater(&p_out,naxis1,naxis2))!=OK_DLL) {
         return(msg);
      }
   } else {
      if ((msg=tt_imacreater3d(&p_out,naxis1,naxis2,naxis3))!=OK_DLL) {
         return(msg);
      }
   }
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      return(msg);
   }

   /* --- remplit le header avec les nouveaux mots cle eventuels ---*/
   if ((argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)&&(argu[12]!=NULL)&&(argu[13]!=NULL)) {
      nbkeys=*(int*)(argu[8]);
      keynames=(char**)(argu[9]);
      values=(char**)(argu[10]);
      comments=(char**)(argu[11]);
      units=(char**)(argu[12]);
      datatypes=(int*)(argu[13]);
      for (k=0;k<nbkeys;k++) {
	 tt_imanewkeychar(&p_out,keynames[k],values[k],datatypes[k],comments[k],units[k]);
      }
   }

   /* --- sauve l'image ---*/
   if ((msg=tt_imasaver(&p_out,fullname,bitpix))!=0) {
      return(msg);
   }

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p_out))!=OK_DLL) {
      return(msg);
   }
   return(OK_DLL);
}

int tt_ptr_loadima3d(void *args)
/**************************************************************************/
/* Fonction d'interface pour charger les images                           */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *datatype (int*)                                                */
/* arg3 : *iaxis3 (int*) index du plan a extraire sur naxis3              */
/* ------ sorties                                                         */
/* arg4 : *p (void*) dimensionne en interne avec malloc                   */
/* arg5 : *naxis1 (int*)                                                  */
/* arg6 : *naxis2 (int*)                                                  */
/* arg7 : *naxis3 (int*)                                                  */
/* ------ sorties optionnelles (si arg6!=NULL)                            */
/* arg8 : *nbkeys (int*)                                                  */
/* arg9 : **keynames (char**) dimensionne en interne avec malloc          */
/* arg10 : **values (char**) dimensionne en interne avec malloc           */
/* arg11 : **comments (char**) dimensionne en interne avec malloc         */
/* arg12 : **units (char**) dimensionne en interne avec malloc            */
/* arg13 : *datatype (int*) dimensionne en interne avec malloc            */
/**************************************************************************/
/**************************************************************************/
{
   void **argu;
   int msg,k;
   char *fullname;
   int datatype,iaxis3;
   TT_IMA p_in;
   long firstelem,nelem;
   void **array=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   int nbkeys,kk,all=0;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   iaxis3=*(int*)(argu[3]);

   /* --- construit un objet image ---*/
   if ((msg=tt_imabuilder(&p_in))!=0) {
      return(msg);
   }

   /* --- charge l'image entierement ---*/
   firstelem=(long)(1);
   nelem=(long)(0);
   strcpy(p_in.load_fullname,fullname);
   if ((msg=tt_imaloader(&p_in,fullname,firstelem,nelem))!=0) {
      return(msg);
   }
   if (p_in.naxis3==0) { p_in.naxis3=1; }
   if (p_in.naxis2==0) { p_in.naxis2=1; }

   /* --- remplit les arguments de retour  ---*/
   if (iaxis3>p_in.naxis3) {
      iaxis3=p_in.naxis3;
   }
   if (iaxis3==0) {
      all=1;
      iaxis3=1;
      p_in.naxis2*=p_in.naxis3;
      p_in.naxis3=1;
   }
   if (iaxis3<1) {
      iaxis3=1;
   }
   nelem=(int)(p_in.naxis1*p_in.naxis2);
   array=(void**)(argu[4]);
   if ((msg=tt_util_calloc_ptr_datatype(array,&nelem,&datatype))!=OK_DLL) {
      return(msg);
   }
   if ((msg=tt_util_ttima2ptr(&p_in,*array,datatype,iaxis3))!=OK_DLL) {
      return(msg);
   }
   if (argu[5]!=NULL) { *(int*)(argu[5])=p_in.naxis1; }
   if (argu[6]!=NULL) { *(int*)(argu[6])=p_in.naxis2; }
   if (argu[7]!=NULL) { *(int*)(argu[7])=p_in.naxis3; }

   if (argu[8]!=NULL) {
      nbkeys=p_in.nbkeys;
      for (k=0,kk=0;k<p_in.nbkeys;k++) {
         if (strcmp(p_in.keynames[k],"NAXIS3")==0) {
            nbkeys--;
         }
         if ((strcmp(p_in.keynames[k],"NAXIS2")==0)&&(all==1)) {
            sprintf(p_in.values[k],"%d",p_in.naxis2);
         }
      }
      if ((msg=libtt_main0(TT_PTR_ALLOKEYS,6,&nbkeys,&keynames,&values,
       &comments,&units,&datatypes))!=0) {
	      tt_imadestroyer(&p_in);
	      return(msg);
      }
      for (k=0,kk=0;k<p_in.nbkeys;k++) {
         if (strcmp(p_in.keynames[k],"NAXIS3")!=0) {
   	      strcpy(keynames[kk],p_in.keynames[k]);
	         strcpy(values[kk],p_in.values[k]);
	         strcpy(comments[kk],p_in.comments[k]);
	         strcpy(units[kk],p_in.units[k]);
	         datatypes[kk]=p_in.datatypes[k];
            kk++;
         }
      }
      *(int*)argu[8]=nbkeys;
      *((char**)argu[9])=(void*)(keynames);
      *((char**)argu[10])=(void*)(values);
      *((char**)argu[11])=(void*)(comments);
      *((char**)argu[12])=(void*)(units);
      *(int**)(argu[13])=(datatypes);
   }

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p_in))!=OK_DLL) {
      return(msg);
   }

   return(OK_DLL);
}

int tt_ptr_saveima1d(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les vecteurs images (naxis=1)         */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *p (void*)                                                      */
/* arg3 : *datatype (int*)                                                */
/* arg4 : *naxis1 (int*)                                                  */
/* arg5 : *bitpix (int*)                                                  */
/* ------ entrees facultatives                                            */
/* arg6 : *nbkeys (int*)                                                  */
/* arg7 : **keynames (char**)                                             */
/* arg8  : **values (char**)                                              */
/* arg9  : **comments (char**)                                            */
/* arg10 : **units (char**)                                               */
/* arg11 : *datatype (int*)                                               */
/**************************************************************************/
{
   TT_IMA p_out;
   int nbkeys,datatype;
   void **argu;
   int msg;
   int naxis1,bitpix,k;
   void *p=NULL;
   char *fullname=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   p=(void*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[4]);
   if (argu[5]==NULL) { return(PB_DLL); }
   bitpix=*(int*)(argu[5]);

   /* --- construit et remplit l'image p_out ---*/
   if ((msg=tt_imabuilder(&p_out))!=OK_DLL) {
      return(msg);
   }
   if ((msg=tt_imacreater1d(&p_out,naxis1))!=OK_DLL) {
      return(msg);
   }
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      return(msg);
   }

   /* --- remplit le header avec les nouveaux mots cle eventuels ---*/
   if ((argu[6]!=NULL)&&(argu[7]!=NULL)&&(argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)) {
      nbkeys=*(int*)(argu[6]);
      keynames=(char**)(argu[7]);
      values=(char**)(argu[8]);
      comments=(char**)(argu[9]);
      units=(char**)(argu[10]);
      datatypes=(int*)(argu[11]);
      for (k=0;k<nbkeys;k++) {
	 tt_imanewkeychar(&p_out,keynames[k],values[k],datatypes[k],comments[k],units[k]);
      }
   }

   /* --- sauve l'image ---*/
   if ((msg=tt_imasaver(&p_out,fullname,bitpix))!=0) {
      return(msg);
   }

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p_out))!=OK_DLL) {
      return(msg);
   }
   return(OK_DLL);
}

int tt_ptr_saveimakeydim(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les images en fonction des mots cle   */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *p (void*)                                                      */
/* arg3 : *datatype (int*)                                                */
/* arg4 : *nbkeys (int*)                                                  */
/* arg5 : **keynames (char**)                                             */
/* arg6 : **values (char**)                                               */
/* arg7 : **comments (char**)                                             */
/* arg8 : **units (char**)                                                */
/* arg9 : *datatype (int*)                                                */
/**************************************************************************/
{
   TT_IMA p_out;
   int nbkeys,datatype;
   void **argu;
   int msg;
   int naxis1,naxis2,naxis3,bitpix=FLOAT_IMG,k,naxis;
   double bzero=0.,bscale=1.;
   void *p=NULL;
   char *fullname=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   int valid=0;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   p=(void*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   datatype=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   nbkeys=*(int*)(argu[4]);
   if (argu[5]==NULL) { return(PB_DLL); }
   keynames=(char**)(argu[5]);
   if (argu[6]==NULL) { return(PB_DLL); }
   values=(char**)(argu[6]);
   if (argu[7]==NULL) { return(PB_DLL); }
   comments=(char**)(argu[7]);
   if (argu[8]==NULL) { return(PB_DLL); }
   units=(char**)(argu[8]);
   if (argu[9]==NULL) { return(PB_DLL); }
   datatypes=(int*)(argu[9]);

   /* --- construit l'image p_out ---*/
   if ((msg=tt_imabuilder(&p_out))!=OK_DLL) {
      return(msg);
   }

   /* --- remplit le header avec les nouveaux mots cle ---*/
   naxis=0;
   naxis1=0;
   naxis2=0;
   naxis3=0;
   for (k=0;k<nbkeys;k++) {
      if (strcmp(keynames[k],"NAXIS")==0) { naxis=atoi(values[k]); }
      if (strcmp(keynames[k],"NAXIS1")==0) { naxis1=atoi(values[k]); }
      if (strcmp(keynames[k],"NAXIS2")==0) { naxis2=atoi(values[k]); }
      if (strcmp(keynames[k],"NAXIS3")==0) { naxis3=atoi(values[k]); }
      if (strcmp(keynames[k],"BITPIX")==0) { bitpix=atoi(values[k]); }
      if (strcmp(keynames[k],"BZERO")==0) { bzero=atof(values[k]); }
      if (strcmp(keynames[k],"BSCALE")==0) { bscale=atof(values[k]); }
   }
   for (k=0;k<nbkeys;k++) {
      tt_imanewkeychar(&p_out,keynames[k],values[k],datatypes[k],comments[k],units[k]);
   }
   if ((bitpix==BYTE_IMG)||(bitpix==SHORT_IMG)||(bitpix==LONG_IMG)||(bitpix==FLOAT_IMG)||(bitpix==DOUBLE_IMG)||(bitpix==USHORT_IMG)||(bitpix==ULONG_IMG)) {
      valid=1;
   }
   if (valid==0) {
      msg=TT_ERR_BITPIX_NULL;
      return(msg);
   }
   if ((bitpix==SHORT_IMG)&&(bzero==32768.)&&(bscale==1.)) {
      bitpix=USHORT_IMG;
   }
   if ((bitpix==LONG_IMG)&&(bzero==-(2^31))&&(bscale==1.)) {
      bitpix=ULONG_IMG;
   }

   /* --- remplit l'image p_out ---*/
   if (naxis==0) {
      msg=TT_ERR_NAXIS_NULL;
      return(msg);
   } else if (naxis==1) {
      if (naxis1==0) {
         msg=TT_ERR_NAXISN_NULL;
         return(msg);
      }
      if ((msg=tt_imacreater1d(&p_out,naxis1))!=OK_DLL) {
         return(msg);
      }
   } else if (naxis==2) {
      if ((naxis1==0)||(naxis2==0)) {
         msg=TT_ERR_NAXISN_NULL;
         return(msg);
      }
      if ((msg=tt_imacreater(&p_out,naxis1,naxis2))!=OK_DLL) {
         return(msg);
      }
   } else {
      if ((naxis1==0)||(naxis2==0)||(naxis3==0)) {
         msg=TT_ERR_NAXISN_NULL;
         return(msg);
      }
      if ((msg=tt_imacreater3d(&p_out,naxis1,naxis2,naxis3))!=OK_DLL) {
         return(msg);
      }
   }
   if ((msg=tt_util_ptr2ttima(p,datatype,&p_out))!=OK_DLL) {
      return(msg);
   }

   /* --- sauve l'image ---*/
   if ((msg=tt_imasaver(&p_out,fullname,bitpix))!=0) {
      return(msg);
   }

   /* --- destruction de l'objet image ---*/
   if ((msg=tt_imadestroyer(&p_out))!=OK_DLL) {
      return(msg);
   }
   return(OK_DLL);
}
