/* tt_poin2.c
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

int tt_ptr_imaseries(void *args)
/**************************************************************************/
/* Fonction d'interface pour effectuer des calculs de type IMA/SERIES     */
/* sur un pointeur d'image.                                               */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1  : *p_in (void*)                                                  */
/* arg2  : *datatype_in (int*)                                            */
/* arg3  : *naxis1 (int*) prends la valeur en sortie                      */
/* arg4  : *naxis2 (int*) prends la valeur en sortie                      */
/* arg5  : **p_out (void*)                                                */
/* arg6  : *datatype_out (int*)                                           */
/* ------ entrees des arguments de la fonction                            */
/* arg7  : nom de la fonction et liste des arguments (char *)             */
/* ------ entrees/sorties optionnelles (si arg6!=NULL)                    */
/* arg8  : *nbkeys (int*)                                                 */
/* arg9  : **keynames (char**)                                            */
/* arg10 : **values (char**)                                              */
/* arg11 : **comments (char**)                                            */
/* arg12 : **units (char**)                                               */
/* arg13 : *datatype (int*)                                               */
/**************************************************************************/
{
   TT_IMA_SERIES pseries;
   int nbkeys,datatype_in,datatype_out,nombre,taille,len;
   char **keys=NULL;
   char ligne[2048];
   void **argu;
   int msg;
   int naxis1,naxis2,k,naxis=0;
   void **pp_in=NULL,*p_in=NULL,**pp_out=NULL,*p_out=NULL;
   char ***pkeynames=NULL;
   char ***pvalues=NULL;
   char ***pcomments=NULL;
   char ***punits=NULL;
   int **pdatatypes=NULL;
   TT_IMA_SERIES_OPTION options;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   pp_in=(void**)(argu[1]);
   p_in=(void*)*(char**)(pp_in);
   if (argu[2]==NULL) { return(PB_DLL); }
   datatype_in=*(int*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   naxis1=*(int*)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   naxis2=*(int*)(argu[4]);
   if (argu[6]==NULL) { return(PB_DLL); }
   datatype_out=*(int*)(argu[6]);
   if (argu[7]==NULL) { return(PB_DLL); }
   if ((naxis1==0)||(naxis2==0)) {
      return(TT_ERR_NAXIS12_NULL);
   }

   /* --- variable globale pour le nom de fichiers temporaires ---*/   
   strcpy(tt_tmpfile_ext,"");

   /* --- construit un objet de pseries ---*/
   sprintf(ligne,"IMA/SERIES rep_in nom_in ind1 ind2 ext_in rep_out nom_out ind1 ext_out %s",(char*)argu[7]);
   tt_decodekeys(ligne,(void***)&keys,&nbkeys);
   tt_ima_series_builder2(&options);
   tt_ima_series_builder3(nbkeys-11, &(keys[11]), ".", &options);
   //if ((msg=tt_ima_series_builder(keys,1,&pseries))!=OK_DLL) {
   if ((msg=tt_ima_series_builder(keys[10], 1, &options, &pseries))!=OK_DLL) {
      tt_util_free_ptrptr((void**)keys,"keys");
      return(msg);
   }

   /* --- remplit l'image de pseries.p_in avec p_in ---*/
   tt_imacreater(pseries.p_in,naxis1,naxis2);
   pseries.p_in->datatype=datatype_in;
   pseries.p_in->naxis=2;
   pseries.p_in->naxis1=naxis1;
   pseries.p_in->naxis2=naxis2;
   pseries.p_in->firstelem=1;
   pseries.p_in->nelements=naxis1*naxis2;
   pseries.p_in->naxes[0]=naxis1;
   pseries.p_in->naxes[1]=naxis2;
   if ((msg=tt_util_ptr2ttima(p_in,datatype_in,pseries.p_in))!=OK_DLL) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_ima_series_destroyer(&pseries);
      return(msg);
   }

   /* --- remplit le header de p_in avec les mots cle eventuels ---*/
   if ((argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)&&(argu[12]!=NULL)&&(argu[13]!=NULL)) {
      nbkeys=*(int*)(argu[8]);
      pkeynames=(char***)(argu[9]);
      pvalues=(char***)(argu[10]);
      pcomments=(char***)(argu[11]);
      punits=(char***)(argu[12]);
      pdatatypes=(int**)(argu[13]);

      /* --- allocation pour les mots cles a ajouter dans l'image p_in ---*/
      nombre=nbkeys+1;
      len=(int)(FLEN_KEYWORD);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_in->keynames,&nombre,&len,"p->keynames"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_in->keynames");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      len=(int)(FLEN_VALUE);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_in->values,&nombre,&len,"p->values"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_in->values");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_in->comments,&nombre,&len,"p->comments"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_in->comments");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_in->units,&nombre,&len,"p->units"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_in->units");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries.p_in->datatypes,&nombre,&taille,"p->datatypes"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_in->datatypes");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      for (k=0;k<nbkeys;k++) {
         strcpy(pseries.p_in->keynames[k],(char*)*((*pkeynames)+k));
         strcpy(pseries.p_in->values[k],(char*)*((*pvalues)+k));
         strcpy(pseries.p_in->comments[k],(char*)*((*pcomments)+k));
         strcpy(pseries.p_in->units[k],(char*)*((*punits)+k));
         pseries.p_in->datatypes[k]=(int)*((*pdatatypes)+k);
         if (strcmp(pseries.p_in->keynames[k],"NAXIS")==0) {
            naxis=(int)atoi(pseries.p_in->values[k]);
         }
      }
      pseries.p_in->naxis=naxis;
      strcpy(pseries.p_in->keynames[nbkeys],"");
      pseries.p_in->keyused=TT_YES;
      pseries.p_in->nbkeys=nbkeys;

   }

   /* --- appel du dispatcher de fonctions et des calculs ---*/
   pseries.index=1;
   pseries.nelements=pseries.p_in->nelements;
   msg=tt_ima_series_dispatch(keys[10],&pseries);

   /* --- traite les erreurs ---*/
   if (msg!=OK_DLL) {
      tt_util_free_ptrptr2((void***)&keys,"keys");
      tt_ima_series_destroyer(&pseries);
      return(msg);
   }

   /* --- remplit le header de p_out avec les mots cle eventuels ---*/
   if ((argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)&&(argu[12]!=NULL)&&(argu[13]!=NULL)) {

      /* --- allocation pour les mots cles a ajouter dans l'image p_out ---*/
      nombre=nbkeys+1;
      len=(int)(FLEN_KEYWORD);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_out->keynames,&nombre,&len,"p->keynames"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_out->keynames");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      len=(int)(FLEN_VALUE);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_out->values,&nombre,&len,"p->values"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_out->values");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_out->comments,&nombre,&len,"p->comments"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_out->comments");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&pseries.p_out->units,&nombre,&len,"p->units"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_out->units");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      nombre=nbkeys;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&pseries.p_out->datatypes,&nombre,&taille,"p->datatypes"))!=0) {
         tt_errlog(pseries.tmp_dir,TT_ERR_PB_MALLOC,"Pb calloc in tt_imaseries for pointer pseries.p_out->datatypes");
         tt_util_free_ptrptr((void**)keys,"keys");
         tt_ima_series_destroyer(&pseries);
         return(TT_ERR_PB_MALLOC);
      }
      for (k=0;k<nbkeys;k++) {
         strcpy(pseries.p_out->keynames[k],(char*)*((*pkeynames)+k));
         if (strcmp(pseries.p_out->keynames[k],"NAXIS1")==0) {
            sprintf(pseries.p_out->values[k],"%d",pseries.p_out->naxis1);
         } else if (strcmp(pseries.p_out->keynames[k],"NAXIS2")==0) {
            sprintf(pseries.p_out->values[k],"%d",pseries.p_out->naxis2);
         } else {
            strcpy(pseries.p_out->values[k],(char*)*((*pvalues)+k));
         }
         strcpy(pseries.p_out->comments[k],(char*)*((*pcomments)+k));
         strcpy(pseries.p_out->units[k],(char*)*((*punits)+k));
         pseries.p_out->datatypes[k]=(int)*((*pdatatypes)+k);
      }
      strcpy(pseries.p_out->keynames[nbkeys],"");

      pseries.p_out->keyused=TT_YES;
      pseries.p_out->nbkeys=nbkeys;

   }

   /* --- on force le nombre d'axes egal a celui d'entree ---*/
   pseries.p_out->naxis=pseries.p_in->naxis;

   /* --- complete l'entete avec l'historique de ce traitement ---*/
   if ((msg=tt_ima_series_history(keys[10],&pseries))!=OK_DLL) {
      tt_util_free_ptrptr((void**)keys,"keys");
      tt_ima_series_destroyer(&pseries);
      return(msg);
   }

   /* --- remplit les mots cle eventuels avec le header de p_out ---*/
   if ((argu[8]!=NULL)&&(argu[9]!=NULL)&&(argu[10]!=NULL)&&(argu[11]!=NULL)&&(argu[12]!=NULL)&&(argu[13]!=NULL)) {
      /* --- on commence par tuer l'ancienne liste ---*/
      tt_util_free_ptrptr2((void***)pkeynames,"p->keynames");
      tt_util_free_ptrptr2((void***)pvalues,"p->values");
      tt_util_free_ptrptr2((void***)pcomments,"p->comments");
      tt_util_free_ptrptr2((void***)punits,"p->units");
      tt_free2((void**)pdatatypes,"p->datatypes");
      /* --- on va chercher les nouvelles valeurs dans p_out ---*/
      nbkeys=0;
      tt_imalistallkeys(pseries.p_out,&nbkeys,(void***)(pkeynames),(void***)(pvalues),(void***)(pcomments),(void***)(punits),(void**)(pdatatypes));
      /* --- on affecte les valeurs dans les pointeurs ---*/
      /* --- en effet, on rappelle que pkeynames = (char***)(argu[9]) */
      *(int*)argu[8]=nbkeys;
   }

   /* --- remplit p_out avec l'image de pseries.p_out ---*/
   pp_out=(void*)(argu[5]);
   if (pp_out!=NULL) {
      /* --- Le pointeur de pointeur de sortie n'etant pas nul, ---*/
      /* --- ca peut etre le meme ou un autre que celui d'entree ---*/
      p_out=(void*)(*(char**)pp_out);
      if (p_out==p_in) {
         /* --- les pointeurs d'entree et de sortie sont les memes ---*/
         if ((naxis1==pseries.p_out->naxis1)&&(naxis2==pseries.p_out->naxis2)) {
	    /* --- l'image de sortie a les memes dimensions que l'image d'entree ---*/
	    /* --- on vide l'image dans le pointeur ---*/
	    if ((msg=tt_util_ttima2ptr(pseries.p_out,p_out,datatype_out,0))!=OK_DLL) {
	       tt_util_free_ptrptr2((void***)&keys,"keys");
	       tt_ima_series_destroyer(&pseries);
	       return(msg);
	    }
	 } else {
	    /* --- l'image de sortie n'a pas les memes dimensions que l'image d'entree ---*/
	    /* --- On va liberer le pointeur ---*/
	    tt_util_free_ptrptr2((void*)pp_out,"p_out");
	    /* --- On va redimensionner le pointeur ---*/
	    naxis1=pseries.p_out->naxis1;
	    naxis2=pseries.p_out->naxis2;
	    *(char**)pp_out=NULL;
	    nombre=naxis1*naxis2;
	    if ((msg=tt_util_calloc_ptr_datatype(pp_out,&nombre,&datatype_out))!=OK_DLL) {
	       tt_util_free_ptrptr2((void***)&keys,"keys");
	       tt_ima_series_destroyer(&pseries);
	       return(msg);
	    }
            p_out=(void*)*(char**)(pp_out);
	    /* --- On vide l'image dans le pointeur ---*/
	    if ((msg=tt_util_ttima2ptr(pseries.p_out,p_out,datatype_out,0))!=OK_DLL) {
	       tt_util_free_ptrptr2((void***)&keys,"keys");
	       tt_ima_series_destroyer(&pseries);
	       return(msg);
	    }
	 }
      } else {
         /* --- Les pointeurs d'entree et de sortie sont differents non nuls ---*/
	 /* --- On va liberer le pointeur de sortie (a priori deja NULL) ---*/
	 tt_util_free_ptrptr2((void*)pp_out,"p_out");
	 /* --- On va redimensionner le pointeur de sortie ---*/
	 naxis1=pseries.p_out->naxis1;
	 naxis2=pseries.p_out->naxis2;
	 *(char**)pp_out=NULL;
	 nombre=naxis1*naxis2;
	 if ((msg=tt_util_calloc_ptr_datatype(pp_out,&nombre,&datatype_out))!=OK_DLL) {
	    tt_util_free_ptrptr2((void***)&keys,"keys");
	    tt_ima_series_destroyer(&pseries);
	    return(msg);
	 }
         p_out=(void*)*(char**)(pp_out);
	 /* --- On vide l'image dans le pointeur de sortie ---*/
	 if ((msg=tt_util_ttima2ptr(pseries.p_out,p_out,datatype_out,0))!=OK_DLL) {
	    tt_util_free_ptrptr2((void***)&keys,"keys");
	    tt_ima_series_destroyer(&pseries);
	    return(msg);
	 }
      }
   /*} else {*/
      /* --- Le pointeur du pointeur de sortie est nul, ---*/
      /* --- Donc on ne remplit pas l'image de sortie (seuls les mots cle ---*/
      /* --- seront donc modifes. ---*/
   }
   *(int*)argu[3]=naxis1;
   *(int*)argu[4]=naxis2;

   /* --- destruction de l'objet pseries ---*/
   tt_util_free_ptrptr2((void***)&keys,"keys");
   tt_ima_series_destroyer(&pseries);
   return(OK_DLL);
}

int tt_ptr_savetbl(void *args)
/**************************************************************************/
/* Fonction d'interface pour sauver les tables (spectres...)              */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : *fullname (char*)                                               */
/* arg2 : *dtype (char* : datatypes des champs)                           */
/*        short, int, float, double, un nombre de carateres               */
/*        Permet de connaitre aussi le nombre de champs (tfields)         */
/* arg3 : **tunit (char** : unite des champs)                             */
/* arg4 : **ttype (char** : intitule des champs)                          */
/*  A noter que **table, **tunit, **ttype ont ete dimensionnes par        */
/*  tt_ptr_allotbl.                                                       */
/* arg5 : "binary" ou "ascii" en fonction du format de sortie desire.     */
/* ------ entrees facultatives pour l'entete                              */
/* arg6 : *nbkeys (int*)                                                  */
/* arg7 : **keynames (char**)                                             */
/* arg8 : **values (char**)                                               */
/* arg9 : **comments (char**)                                            */
/* arg10 : **units (char**)                                               */
/* arg11 : *datatype (int*)                                               */
/* ------ entrees des donnees des colonnes                                */
/* arg12 *char (char*) chaine de la premiere colonne.                     */
/* arg13 *char (char*) chaine de la deuxieme colonne.                     */
/* ...                                                                    */
/**************************************************************************/
{
   TT_TBL p_out;
   int nbkeys,len,taille;
   void **argu;
   int msg,nbcars;
   int tfields,naxis2,k;
   char *fullname=NULL;
   char **table=NULL;
   char *dtype=NULL;
   int *tbldatatypes=NULL;
   char **tunit=NULL;
   char **ttype=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char *binaryorascii;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   fullname=(char*)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   dtype=(char*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   tunit=(char**)(argu[3]);
   if (argu[4]==NULL) { return(PB_DLL); }
   ttype=(char**)(argu[4]);
   if (argu[5]==NULL) { return(PB_DLL); }
   binaryorascii=(char*)(argu[5]);

   /* --- calcul de transcodage dtype vers tbldatatypes ---*/
   if ((msg=tt_tbl_dtypes2tbldatatypes(dtype,&tfields,&tbldatatypes))!=OK_DLL) {
      tt_free2((void**)&tbldatatypes,"tbldatatypes");
      return(msg);
   }

   /* --- allocation memoire table ---*/
   table=NULL;
   len=tfields;
   taille=(int)(sizeof(int)); /* taille d'une adresse : 4 octets ! */
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,(void**)&table,&len,&taille,"table"))!=OK_DLL) {
      tt_free2((void**)&tbldatatypes,"tbldatatypes");
      return(msg);
   }
   for (k=0;k<tfields;k++) {
      table[k]=argu[12+k];
   }

   /* --- construit et remplit la table p_out ---*/
   if ((msg=tt_tblbuilder(&p_out))!=OK_DLL) {
      tt_free2((void**)&tbldatatypes,"tbldatatypes");
      return(msg);
   }

   /* --- naxis2 est calcule a partir des donnees ---*/
   tt_tbldatainfos(table,tfields,&naxis2,&nbcars);

   /* --- initialise la table p_out ---*/
   if ((msg=tt_tblcreater(&p_out,tfields,naxis2,tbldatatypes))!=OK_DLL) {
      tt_free2((void**)&tbldatatypes,"tbldatatypes");
      return(msg);
   }

   p_out.p=table;
   p_out.tbldatatypes=tbldatatypes;

   /* --- allocation memoire p->tunit et p->ttype ---*/
   p_out.tunit=NULL;
   p_out.ttype=NULL;
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p_out.tunit,&tfields,&len,"tunit"))!=OK_DLL) {
      tt_tbldestroyer(&p_out);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p_out.ttype,&tfields,&len,"ttype"))!=OK_DLL) {
      tt_tbldestroyer(&p_out);
      return(TT_ERR_PB_MALLOC);
   }
   for (k=0;k<tfields;k++) {
      strcpy(p_out.ttype[k],ttype[k]);
      strcpy(p_out.tunit[k],tunit[k]);
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
         tt_tblnewkeychar(&p_out,keynames[k],values[k],datatypes[k],comments[k],units[k]);
      }
   }

   /* --- sauve la table ---*/
   tt_strupr(binaryorascii);
   if (strcmp(binaryorascii,"ASCII")==0) {
      if ((msg=tt_tblsaver(&p_out,fullname,ASCII_TBL))!=0) {
         tt_tbldestroyer(&p_out);
         return(msg);
      }
   } else {
      if ((msg=tt_tblsaver(&p_out,fullname,BINARY_TBL))!=0) {
         tt_tbldestroyer(&p_out);
         return(msg);
      }
   }

   /* --- Destruction du pointeur d'adresses des donnees. ---*/
   /* --- Ruse pour ne pas detruire les donnees de l'utilisateur ---*/
   /* --- lors du passage dans le destroyer. */
   tt_free2((void**)&p_out.p,"p_out.p");
   p_out.p=NULL;
   
   /* --- destruction de l'objet table ---*/
   if ((msg=tt_tbldestroyer(&p_out))!=OK_DLL) {
      return(msg);
   }
   return(OK_DLL);
}

int tt_ptr_allotbl(void *args)
/**************************************************************************/
/* Fonction d'interface pour dimensionner les pointeurs de table          */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *dtypes (char* : "double float 7 int")                          */
/*        determine le nombre de champs et leur taille                    */
/* ------ sorties                                                         */
/* arg2 : *tfields (int * : nombre de champs)                             */
/* arg3 : ***tunit (char***) dimensionne en interne avec malloc           */
/* arg4 : ***ttype (char***) dimensionne en interne avec malloc           */
/**************************************************************************/
/**************************************************************************/
{
   void **argu;
   int msg,len;
   char **tunit=NULL,**ttype=NULL;
   int *tbldatatypes=NULL;
   int tfields,k;
   char *dtypes;

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   dtypes=(char*)(argu[1]);

   /* --- calcul de transcodage dtype vers tbldatatypes ---*/
   if ((msg=tt_tbl_dtypes2tbldatatypes(dtypes,&tfields,&tbldatatypes))!=OK_DLL) {
      tt_free2((void**)&tbldatatypes,"tbldatatypes");
      return(msg);
   }
   tt_free2((void**)&tbldatatypes,"tbldatatypes");

   /* --- allocation memoire tunit et ttype ---*/
   tunit=NULL;
   ttype=NULL;
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&tunit,&tfields,&len,"tunit"))!=OK_DLL) {
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&ttype,&tfields,&len,"ttype"))!=OK_DLL) {
      tt_util_free_ptrptr((void**)ttype,"tunit");
      return(TT_ERR_PB_MALLOC);
   }

   /* --- initialisations ---*/
   for (k=0;k<tfields;k++) {
      strcpy(ttype[k],"");
      strcpy(tunit[k],"");
   }

   /*  -- variables de sortie ---*/
   *(int*)argu[2]=tfields;
   *((char**)argu[3])=(void*)(tunit);
   *((char**)argu[4])=(void*)(ttype);

   return(OK_DLL);
}

int tt_ptr_freetbl(void *args)
/**************************************************************************/
/* Fonction d'interface pour liberer la memoire d'une liste de mots cle   */
/**************************************************************************/
/* ------ entrees obligatoires                                            */
/* arg1 : ***tunit (char***) dimensionne en interne avec malloc           */
/* arg2 : ***ttype (char***) dimensionne en interne avec malloc           */
/**************************************************************************/
{
   void **argu;
   char **tunit=NULL;
   char **ttype=NULL;

   /* --- verification des arguments ---*/
   /* --- et liberation de la memoire ---*/
   argu=(void**)(args);
   if (argu[1]!=NULL) { tunit=*(char***)(argu[1]); tt_util_free_ptrptr2((void***)&tunit,"tunit");}
   if (argu[2]!=NULL) { ttype=*(char***)(argu[2]); tt_util_free_ptrptr2((void***)&ttype,"ttype");}

   return(OK_DLL);
}
