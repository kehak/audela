/* fs_macr2.c
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

int macr_read(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8,void *arg9,void *arg10)
/***************************************************************************/
/* Lit une image ou une table dans un fichier Fits                         */
/***************************************************************************/
/* arg1 : Nom du fichier FITS a ouvrir (dossier+nom+ext)                   */
/*        (char)(*nom_fichier).                                            */
/* arg2 : Numero du header dans lequel on veut lire les donnees.           */
/*        Si le numero est trop grand ou trop petit (<=0), la valeur de    */
/*        retour de arg2 vaut le nombre maximum de headers dans le fichier */
/*        et la valeur de retour de la fonction vaut FS_ERR_HDUNUM_OVER.   */
/*        (int)(numhdu).                                                   */
/* arg3 : Type d'entete : IMAGE_HDU ou ASCII_TBL ou BINARY_TBL.            */
/*        Ceci est une valeur d'entree que la fonction compare avec celle  */
/*        associee au header 'numhdu' du fichier FITS. Si elle est         */
/*        differente alors la fonction renvoie dans arg3 la vraie valeur   */
/*        du type de header et s'arrete la et la valeur de retour de la    */
/*        fonction vaut FS_ERR_HDU_NOT_SAME_TYPE.                          */
/*        (int)(typehdu).                                                  */
/* arg4 : Firstelem. C'est l'indice du premier element qui sera retourne   */
/*        dans le 'array'. Si cette valeur est trop grande ou nulle ou     */
/*        negative, alors elle sera prise egale a 1.                       */
/*        (long)(firstelem) dans le cas d'une image.                       */
/*        (long)(firstrow) dans le cas d'une table.                        */
/* arg5 : Nelements. C'est le nombre d'elements qui sera retourne dans le  */
/*        'array' a partir de la position Firstelem dans le fichier.       */
/*        Si nelements=0 alors on retourne le nombre maximal d'elements    */
/*        et cette valeur se retrouve dans arg5 en retour.                 */
/*        (long)(nelements) dans le cas d'une image.                       */
/*        (long)(nelements) dans le cas d'une table.                       */
/*                                                                         */
/* Si le type d'entete est une IMAGE_HDU :                                 */
/*                                                                         */
/* arg6 : Nombre d'axes de l'image.                                        */
/*        (int)(naxis).                                                    */
/* arg7 : Tableau qui donne le nombre de pixels sur chaque axe de l'image. */
/*        Ce tableau est dimensionne par malloc dans la fonction.          */
/*        (int)(**naxes)                                                   */
/* arg8 : Code de bitpix decrivant le format des donnees sur le disque.    */
/*        (int)(bitpix).                                                   */
/* arg9 : Code du type de donnees associees au pointeur image.             */
/*        (int)(datatype).                                                 */
/* arg10: Pointeur image dimensionne par malloc dans la fonction.          */
/*        L'image n'est pas chargee si arg10=NULL (ceci peut permettre de  */
/*        lire les infos de l'image sans la charger).                      */
/*        (void)(**array).                                                 */
/*                                                                         */
/* Si le type d'entete est une ASCII_TBL ou une BINARY_TBL :               */
/*                                                                         */
/* arg6 : Renvoi le nombre de colonnes (=champs) de la table.              */
/*        (int)(tfields).                                                  */
/* arg7 : Renvoi le nombre de lignes de la table.                          */
/*        (int)(nrows).                                                    */
/* arg8 : Pointeur **tform de la table.                                    */
/*        Ce tableau est dimensionne par malloc dans la fonction.          */
/*        Si arg8=NULL, **tform sera pas retourne.                         */
/*        (char)(**tform).                                                 */
/* arg9 : Pointeur **ttype de la table.                                    */
/*        Ce tableau est dimensionne par malloc dans la fonction.          */
/*        Si arg9=NULL, **ttype sera pas retourne.                         */
/*        (char)(**ttype).                                                 */
/* arg10: Pointeur **tunit de la table.                                    */
/*        Ce tableau est dimensionne par malloc dans la fonction.          */
/*        Si arg10=NULL, **tunit sera pas retourne.                        */
/*        (char)(**tunit).                                                 */
/* arg11: Tableau des datatypes associes a chaque colonne.                 */
/*        Ce tableau est dimensionne par malloc dans la fonction.          */
/*        (int)(**datatypes).                                              */
/* arg12: Tableau de donnees de la premiere colonne.                       */
/*        Ce tableau est dimensionne par malloc dans la fonction.          */
/*        Les colonnes ne sont pas chargees si arg12=NULL (ceci peut       */
/*        permettre de lire les infos descolonnes sans les charger).       */
/*        (void)(**col1) pour des donnees **char.                          */
/*        (void)(*col1) pour les autres types.                             */
/* arg13: Tableau de donnees de la deuxieme colonne.                       */
/*        Ce tableau est dimensionne par malloc dans la fonction.          */
/*        (void)(**col2) pour des donnees **char.                          */
/*        (void)(*col2) pour les autres types.                             */
/* arg... ainsi de suite.                                                  */
/*                                                                         */
/***************************************************************************/
{
   int typemode=READONLY,*numhdu,*typehdu;
   int msg,nbhdu,typechdu;
   char *nom_fichier;
   void *fptr;
   int *simple,*naxis=NULL, *bitpix;
   long *naxes=NULL;
   int maxdim;
   int extend;
   long pcount,gcount,rowlen;
   int *tfields=NULL,*nrows=NULL;
   char **tform,**tunit,**ttype; /* *tbcol,*extname; */
   char *tform_data=NULL,*tunit_data=NULL,*ttype_data=NULL;
   char **ptform,**ptunit,**pttype;
   int nbcar,taille;
   int exist_tform=0,exist_ttype=0,exist_tunit=0;
   long nelementsmax;
   int anynul;
   long *nelements,*firstelem;
   int nelements_int;
   long *firstrow_tbl,*nelements_tbl,firstelem_tbl;
   int datatype,*datatypes=NULL;
   void **array;
   char *arraystring,**parray;
   char *car;
   char mot[FLEN_VALUE];
   int k,kk,pos;
   void **argu;
   
   argu=(void**)(arg10);
   nom_fichier=(char*)(arg1);
   numhdu=(int*)(arg2);
   typehdu=(int*)(arg3);
   
   /* --- ouverture en lecture du fichier fits ---*/
   if ((msg=libfiles_main(FS_FITS_OPEN_FILE,3,&fptr,nom_fichier,&typemode))!=0) {
      return(msg);
   }
   /* --- selection du header courant du fichier fits    --- */
   if ((msg=libfiles_main(FS_FITS_GET_NUM_HDUS,2,fptr,&nbhdu))!=0) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(msg);
   }
   if ((*numhdu<=0)||(*numhdu>nbhdu)) {
      *numhdu=nbhdu;
      if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
      return(FS_ERR_HDUNUM_OVER);
   } else {
      if ((msg=libfiles_main(FS_FITS_MOVABS_HDU,3,fptr,numhdu,&typechdu))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      if (typechdu!=*typehdu) {
         *typehdu=typechdu;
         if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
         return(FS_ERR_HDU_NOT_SAME_TYPE);
      }
   }
   
   /* --- lecture de l'entete minimale d'une image ---*/
   if (*typehdu==IMAGE_HDU) {
      naxis=(int*)(arg6);
      bitpix=(int*)(arg8);
      maxdim=100;
      /*
      if((naxes=(long*)calloc(maxdim,sizeof(long)))==NULL) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
	     return(FS_ERR_PB_MALLOC);
        }
      */
      taille=sizeof(long);
      naxes=NULL;
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&naxes,&maxdim,&taille,"p->naxes"))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(FS_ERR_PB_MALLOC);
      }
      /**/
      *(long**)(arg7)=naxes;
      if ((msg=libfiles_main(FS_FITS_READ_IMGHDR,9,fptr,&maxdim,&simple,bitpix,naxis,naxes,&pcount,&gcount,&extend))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      
      /* --- lecture de l'entete minimale d'une table ---*/
   } else if ((*typehdu==BINARY_TBL)||(*typehdu==ASCII_TBL)) {
      tfields=(int*)(arg6);
      nrows=(int*)(arg7);
      maxdim=100;
      ptform=(char**)(arg8);
      pttype=(char**)(arg9);
      ptunit=(char**)(argu[10]);
      exist_tform=(ptform==NULL)?0:1;
      exist_ttype=(pttype==NULL)?0:1;
      exist_tunit=(ptunit==NULL)?0:1;
      tform=NULL;
      ttype=NULL;
      tunit=NULL;
      /*
      printf("adr. *%p *%p *%p\n",*ptform,*pttype,*ptunit);
      printf("adr. %p %p %p\n",ptform,pttype,ptunit);
      printf("exist : tform=%d ttype=%d tunit=%d\n",exist_tform,exist_ttype,exist_tunit);
      */
      if (exist_tform==1) {
         if((tform=(char**)calloc(maxdim,sizeof(void*)))==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            return(FS_ERR_PB_MALLOC);
         }
         nbcar=(FLEN_VALUE)*sizeof(char);
         taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
         tform_data=NULL;
         if((tform_data=(char*)calloc(maxdim,taille))==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            free(tform);
            return(FS_ERR_PB_MALLOC);
         }
         for (k=0;k<=maxdim-1;k++) {
            tform[k]=tform_data+k*taille;
         }
         *ptform=(void*)tform;
      }
      if (exist_ttype==1) {
         if((ttype=(char**)calloc(maxdim,sizeof(void*)))==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==1) { free(tform); free(tform_data); }
            return(FS_ERR_PB_MALLOC);
         }
         nbcar=(FLEN_VALUE)*sizeof(char);
         taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
         ttype_data=NULL;
         if((ttype_data=(char*)calloc(maxdim,taille))==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==1) { free(tform); free(tform_data); }
            free(ttype);
            return(FS_ERR_PB_MALLOC);
         }
         for (k=0;k<=maxdim-1;k++) {
            ttype[k]=ttype_data+k*taille;
         }
         *pttype=(void*)ttype;
      }
      if (exist_tunit==1) {
         if((tunit=(char**)calloc(maxdim,sizeof(void*)))==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==1) { free(tform); free(tform_data); }
            if (exist_ttype==1) { free(tform); free(ttype_data); }
            return(FS_ERR_PB_MALLOC);
         }
         nbcar=(FLEN_VALUE)*sizeof(char);
         taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
         tunit_data=NULL;
         if((tunit_data=(char*)calloc(maxdim,taille))==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==1) { free(tform); free(tform_data); }
            if (exist_ttype==1) { free(tform); free(ttype_data); }
            free(tunit);
            return(FS_ERR_PB_MALLOC);
         }
         for (k=0;k<=maxdim-1;k++) {
            tunit[k]=tunit_data+k*taille;
         }
         *ptunit=(void*)tunit;
      }
      if (*typehdu==ASCII_TBL) {
         if ((msg=libfiles_main(FS_FITS_READ_ATBLHDR,10,fptr,&maxdim,&rowlen,nrows,tfields,ttype,NULL,tform,tunit,NULL))!=0) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==1) { free(tform); free(tform_data); }
            if (exist_ttype==1) { free(tform); free(ttype_data); }
            if (exist_tunit==1) { free(tunit); free(tunit_data); }
            return(msg);
         }
      }
      if (*typehdu==BINARY_TBL) {
         if ((msg=libfiles_main(FS_FITS_READ_BTBLHDR,9,fptr,&maxdim,nrows,tfields,ttype,tform,tunit,NULL,&pcount))!=0) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==1) { free(tform); free(tform_data); }
            if (exist_ttype==1) { free(tform); free(ttype_data); }
            if (exist_tunit==1) { free(tunit); free(tunit_data); }
            return(msg);
         }
      }
      /* --- on remplit datatypes si l'on ne lit pas les colonnes et on sort ---*/
      if ((array=(void**)(argu[12]))==NULL) {
         if((datatypes=(int*)calloc(*tfields,sizeof(int)))==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==1) { free(tform); free(tform_data); }
            if (exist_ttype==1) { free(tform); free(ttype_data); }
            if (exist_tunit==1) { free(tunit); free(tunit_data); }
            return(FS_ERR_PB_MALLOC);
         }
         *(int**)(argu[11])=datatypes;
         if (*typehdu==BINARY_TBL) {
            for (k=0;k<=*tfields-1;k++) {
               if      ((car=strstr(tform[k],"I"))!=NULL) { datatypes[k]=TSHORT; }
               else if ((car=strstr(tform[k],"J"))!=NULL) { datatypes[k]=TINT; }
               else if ((car=strstr(tform[k],"E"))!=NULL) { datatypes[k]=TFLOAT; }
               else if ((car=strstr(tform[k],"D"))!=NULL) { datatypes[k]=TDOUBLE; }
               else if ((car=strstr(tform[k],"A"))!=NULL) {
                  datatypes[k]=TSTRINGS;
                  strcpy(mot,tform[k]);
                  pos=(int)(car-tform[k]+1);
                  mot[pos]='\0';
                  datatypes[k]+=atoi(mot);
               }
            }
         } else if (*typehdu==ASCII_TBL) {
            for (k=0;k<=*tfields-1;k++) {
               if      ((car=strstr(tform[k],"I"))!=NULL) { datatypes[k]=TSHORT; }
               else if ((car=strstr(tform[k],"J"))!=NULL) { datatypes[k]=TINT; }
               else if ((car=strstr(tform[k],"E"))!=NULL) { datatypes[k]=TFLOAT; }
               else if ((car=strstr(tform[k],"D"))!=NULL) { datatypes[k]=TDOUBLE; }
               else if ((car=strstr(tform[k],"A"))!=NULL) {
                  datatypes[k]=TSTRINGS;
                  pos=(int)(car-tform[k]+1);
                  strcpy(mot,tform[k]+pos);
                  datatypes[k]+=atoi(mot);
               }
            }
         }
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(OK_DLL);
      } else {
         datatypes=*(int**)(argu[11]);
      }
   } else {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(FS_ERR_TYPEHDU_NOT_KNOWN);
   }
   
   /* --- lecture d'une image ---*/
   if (*typehdu==IMAGE_HDU) {
      firstelem=(long*)(arg4);
      nelements=(long*)(arg5);
      datatype=*(int*)(arg9);
      for (k=0,nelementsmax=1;k<=*naxis-1;k++) { nelementsmax*=naxes[k]; }
      if ((*firstelem<=0)||(*firstelem>=nelementsmax)) {
         *firstelem=1;
      }
      if (*nelements<=0) {
         *nelements=nelementsmax-(*firstelem)+1;
      } else if (((*nelements)+(*firstelem)-1)>=nelementsmax) {
         *nelements=nelementsmax-(*firstelem)+1;
      }
      array=(void**)(argu[10]);
      if (array==NULL) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(FS_ERR_PTR_NULL);
      }
      nelements_int=(int)(*nelements);
      if ((msg=libfiles_main(FS_UTIL_CALLOC_PTR_DATATYPE,3,array,&nelements_int,&datatype))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      if ((msg=libfiles_main(FS_FITS_READ_IMG,7,fptr,&datatype,firstelem,nelements,NULL,*array,&anynul))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
   }
   /* --- lecture d'une table ---*/
   else if ((*typehdu==BINARY_TBL)||(*typehdu==ASCII_TBL)) {
      for (k=1;k<=*tfields;k++) {
         firstrow_tbl=(long*)(arg4);
         nelements_tbl=(long*)(arg5);
         firstelem_tbl=1;
         datatype=datatypes[k-1];
         if ((*typehdu==ASCII_TBL)||(*typehdu==BINARY_TBL)) {
            nelementsmax=*nrows;
            if ((*firstrow_tbl<=0)||(*firstrow_tbl>=nelementsmax)) {
               *firstrow_tbl=1;
            }
            if (*nelements_tbl<=0) {
               *nelements_tbl=nelementsmax-(*firstrow_tbl)+1;
            } else if (((*nelements_tbl)+(*firstrow_tbl)-1)>=nelementsmax) {
               *nelements_tbl=nelementsmax-(*firstrow_tbl)+1;
            }
         }
         array=(void**)(argu[12+k-1]);
         if (array==NULL) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            return(FS_ERR_PTR_NULL);
         }
         if (datatype<TSTRINGS) {
            if ((msg=libfiles_main(FS_UTIL_CALLOC_PTR_DATATYPE,3,array,nelements_tbl,&datatype))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(msg);
            }
            if ((msg=libfiles_main(FS_FITS_READ_COL,9,fptr,&datatype,&k,firstrow_tbl,&firstelem_tbl,nelements_tbl,NULL,*array,&anynul))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(msg);
            }
         } else {
            if((parray=(char**)calloc(*nelements_tbl,sizeof(void*)))==NULL) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(FS_ERR_PB_MALLOC);
            }
            nbcar=(datatype-TSTRINGS)*sizeof(char);
            datatype=TSTRING;
            taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
            arraystring=NULL;
            if((arraystring=(char*)calloc(*nelements_tbl,taille))==NULL) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(FS_ERR_PB_MALLOC);
            }
            for (kk=0;kk<=*nelements_tbl-1;kk++) {
               parray[kk]=arraystring+kk*taille;
            }
            *(char**)(argu[12+k-1])=(void*)parray;
            if ((msg=libfiles_main(FS_FITS_READ_COL,9,fptr,&datatype,&k,firstrow_tbl,&firstelem_tbl,nelements_tbl,NULL,parray,&anynul))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(msg);
            }
            /*
            for (kk=0;kk<=*nelements_tbl-1;kk++) {
            printf("parray[%d]=<%s>\n",kk,parray[kk]);
            }
            */
         }
      }
   }
   
   /* --- fermeture du fichier ---*/
   if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
   return(OK_DLL);
}

int macr_write_keys(void *arg1)
/***************************************************************************/
/* Ecrit des nouveaux mots cles et leurs attributs ou bien remplace les    */
/* attributs des mots cles existants.                                      */
/***************************************************************************/
/* arg1 : Nom du fichier FITS a ouvrir (dossier+nom+ext)                   */
/*        (char)(*nom_fichier).                                            */
/* arg2 : Numero du header dans lequel on veut inserer les mots cle.       */
/*        (int)(numhdu).                                                   */
/* arg3 : Nombre de mots cles a ecrire.                                    */
/*        (int)(nbkeys).                                                   */
/*                                                                         */
/* Si arg3==-1 :                                                           */
/* arg4 : Nom du mot cle a ecrire.                                         */
/*        (char) (*keyname)                                                */
/* arg5 : Chaine du commentaire associe au mot cle.                        */
/*        (char)(*comment)                                                 */
/* arg6 : Chaine des unites a inserer dans le commentaire.                 */
/*        (char)(*unit)                                                    */
/* arg7 : Datatype associe a la valeur du mot cle.                         */
/*        (int)(datatype)                                                  */
/* arg8 : Valeurs associee au mot cle.                                     */
/*        (int)(values) si datatypes!=TSTRINGS                             */
/*        (int)(*values) si datatypes==TSTRINGS                            */
/*                                                                         */
/* Si arg3>=1 :                                                            */
/* arg4 : Liste de mots cle a ecrire.                                      */
/*        (char) (**keynames)                                              */
/* arg5 : Liste des commentaires associes aux mots cle.                    */
/*        (char)(**comments)                                               */
/* arg6 : Liste des unites a inserer dans les commentaires.                */
/*        (char)(**units)                                                  */
/* arg7 : Liste des datatypes associes aux valeurs des mots cles.          */
/*        (int)(*datatypes)                                                */
/* arg8 : Liste des valeurs associes aux mots cles.                        */
/*        (int)(**values)                                                  */
/***************************************************************************/
{
   int typemode=READWRITE,numhdu,nbkeys,nbhdu,typechdu;
   char *keyname,*comment,*unit;
   int datatype;
   void *value;
   char **keynames,**comments,**units,**values;
   void *val_void;
   int exist_keynames,exist_values,exist_comments,exist_units,k;
   int *datatypes;
   int msg;
   char *nom_fichier;
   void *fptr;
   void **argu;

   argu=(void**)(arg1);
   nom_fichier=(char*)(argu[1]);
   numhdu=*(int*)(argu[2]);
   nbkeys=*(int*)(argu[3]);

   /* --- ouverture en ecriture du fichier fits ---*/
   if ((msg=libfiles_main(FS_FITS_OPEN_FILE,3,&fptr,nom_fichier,&typemode))!=0) {
      return(msg);
   }
   /* --- selection du header courant du fichier fits    --- */
   /* --- dans lequel on inserera les nouveaux mots cle --- */
   if ((msg=libfiles_main(FS_FITS_GET_NUM_HDUS,2,fptr,&nbhdu))!=0) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(msg);
   }
   if ((numhdu<=0)||(numhdu>nbhdu)) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(FS_ERR_HDUNUM_OVER);
   } else {
      if ((msg=libfiles_main(FS_FITS_MOVABS_HDU,3,fptr,&numhdu,&typechdu))!=0) {
	 libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
	 return(msg);
      }
   }

   if (nbkeys==-1) {
      nbkeys=1;
      keyname=(char*)(argu[4]);
      comment=(char*)(argu[5]);
      unit=(char*)(argu[6]);
      datatype=*(int*)(argu[7]);
      value=(void*)(argu[8]);
      if ((msg=libfiles_main(FS_FITS_UPDATE_KEY,5,fptr,&datatype,keyname,value,comment))!=0) {
	 libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
	 return(msg);
      }
      if (unit!=NULL) {
	 if ((msg=libfiles_main(FS_FITS_WRITE_KEY_UNIT,3,fptr,keyname,unit))!=0) {
	    libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
	    return(msg);
	 }
      }
   } else if (nbkeys>=1) {
      exist_keynames=(argu[4]==NULL)?0:1;
      exist_values=(argu[8]==NULL)?0:1;
      exist_comments=(argu[5]==NULL)?0:1;
      exist_units=(argu[6]==NULL)?0:1;
      datatypes=(int*)(argu[7]);
      if ((exist_keynames==0)||(exist_values==0)) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(FS_ERR_BAD_NBKEYS);
      }
      keynames=(char**)(argu[4]);
      values=(char**)(argu[8]);
      if (exist_comments==0) {comments=NULL;} else {comments=(char**)(argu[5]);}
      if (exist_units==0) {units=NULL;} else {units=(char**)(argu[6]);}
      for (k=0;k<nbkeys;k++) {
         datatype=datatypes[k];
         val_void=(void*)(values[k]);
         if (exist_comments==0) {
            if ((msg=libfiles_main(FS_FITS_UPDATE_KEY,5,fptr,&datatype,keynames[k],val_void,NULL))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(msg);
            }
         } else {
            if (strcmp(comments[k],"")!=0) {
               if ((msg=libfiles_main(FS_FITS_UPDATE_KEY,5,fptr,&datatype,keynames[k],val_void,comments[k]))!=0) {
                  libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
                  return(msg);
               }
            } else {
               if ((msg=libfiles_main(FS_FITS_UPDATE_KEY,5,fptr,&datatype,keynames[k],val_void,NULL))!=0) {
                  libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
                  return(msg);
               }
            }
         }
         if (exist_units==1) {
            if (strcmp(units[k],"")!=0) {
               if ((msg=libfiles_main(FS_FITS_WRITE_KEY_UNIT,3,fptr,keynames[k],units[k]))!=0) {
                  libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
                  return(msg);
               }
            }
         }
      }
   } else {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(FS_ERR_BAD_NBKEYS);
   }

   /* --- fermeture du fichier ---*/
   if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
   return(OK_DLL);
}

int macr_read_keys(void *arg1)
/***************************************************************************/
/* Lit les attributs d'un mot cle dans un header Fits selectionne.         */
/***************************************************************************/
/* arg1 : Nom du fichier FITS a ouvrir (dossier+nom+ext)                   */
/*        (char)(*nom_fichier).                                            */
/* arg2 : Numero du header dans lequel on veut lire les mots cle.          */
/*        (int)(numhdu).                                                   */
/* arg3 : Nombre de mots cles a lire.                                      */
/*        (int)(nbkeys).                                                   */
/*                                                                         */
/* Si arg3==1 :                                                            */
/* arg4 : Nom du mot cle a lire.                                           */
/*        (char) (*keyname)                                                */
/* arg5 : Chaine du commentaire associe au mot cle.                        */
/*        (char)(*comment)                                                 */
/* arg6 : Chaine des unites a inserer dans le commentaire.                 */
/*        (char)(*unit)                                                    */
/* arg7 : Valeur de datatype associe a la valeur du mot cle.               */
/*        (int)(*datatype)                                                 */
/* arg8 : Chaine associee a la valeur du mot cle.                          */
/*        (char)(*value)                                                   */
/*                                                                         */
/* Si arg3==0 : on retourne tousles mots cles de l'entete.                 */
/* arg4 : Nom de la liste des mots cle a lire.                             */
/*        (char) (**keynames)                                              */
/* arg5 : Nom de la liste de chaines du commentaire associe au mot cle.    */
/*        (char)(**comments)                                               */
/* arg6 : Nom de la liste de chaines des unites a inserer dans le commentaire.*/
/*        (char)(**units)                                                  */
/* arg7 : Valeur de datatypes associe a la valeur des mots cle.            */
/*        (int)(*datatypes)                                                */
/* arg8 : Nom de la liste de chaines associee a la valeur du mot cle.      */
/*        (char)(**values)                                                 */
/***************************************************************************/
{
   int typemode=READONLY,numhdu,nbkeys,nbhdu,typechdu;
   char *keyname=NULL,*comment=NULL,*unit=NULL;
   char *value=NULL;
   int msg;
   char *nom_fichier;
   char **keynames=NULL,**comments=NULL,**units=NULL,**values=NULL;
   /*char *keynames_data=NULL,*values_data=NULL,*comments_data=NULL,*units_data=NULL;*/
   int exist_keynames,exist_values,exist_comments,exist_units,k,kk;
   /*int exist_datatypes;*/
   char **pkeynames=NULL,**pcomments=NULL,**punits=NULL,**pvalues=NULL;
   /*int nbcar,taille;*/
   int morekeys,lenp;
   void *fptr;
   void **argu;
   int datatype,*datatypes,len;
   char dtype;
   char *chaine;
   char cdigit;
   int ndigit;
   
   argu=(void**)(arg1);
   nom_fichier=(char*)(argu[1]);
   numhdu=*(int*)(argu[2]);
   nbkeys=*(int*)(argu[3]);
   
   /* --- ouverture en ecriture du fichier fits ---*/
   if ((msg=libfiles_main(FS_FITS_OPEN_FILE,3,&fptr,nom_fichier,&typemode))!=0) {
      return(msg);
   }
   /* --- selection du header courant du fichier fits    --- */
   /* --- dans lequel on inserera les nouveaux mots cle --- */
   if ((msg=libfiles_main(FS_FITS_GET_NUM_HDUS,2,fptr,&nbhdu))!=0) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(msg);
   }
   if ((numhdu<=0)||(numhdu>nbhdu)) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(FS_ERR_HDUNUM_OVER);
   } else {
      if ((msg=libfiles_main(FS_FITS_MOVABS_HDU,3,fptr,&numhdu,&typechdu))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
   }
   
   if (nbkeys==1) {
      keyname=(char*)(argu[4]);
      comment=(char*)(argu[5]);
      unit=(char*)(argu[6]);
      datatype=*(int*)(argu[7]);
      value=(char*)(argu[8]);
      if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,keyname,value,comment))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      if ((msg=libfiles_main(FS_FITS_READ_KEY_UNIT,3,fptr,keyname,unit))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      if ((msg=libfiles_main(FS_FITS_GET_KEYTYPE,2,value,&dtype))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      if (&datatype!=NULL) {
         if      (dtype=='C') { datatype=TSTRING; }
         else if (dtype=='L') { datatype=TSTRING; }
         else if (dtype=='I') { datatype=TINT; }
         else if (dtype=='F') { datatype=TFLOAT; }
         else { datatype=TSTRING; }
         if (dtype=='C') {
            chaine=value;
            len=strlen(chaine);
            for (kk=0;kk<(len-1);kk++) {
               chaine[kk]=chaine[kk+1];
            }
            if (len>=2) { chaine[len-2]='\0'; }
         }
      }
   } else if (nbkeys==0) {
      exist_keynames=(argu[4]==NULL)?0:1;
      exist_values=(argu[8]==NULL)?0:1;
      exist_comments=(argu[5]==NULL)?0:1;
      exist_units=(argu[6]==NULL)?0:1;
      /*exist_datatypes=(argu[7]==NULL)?0:1;*/
      pkeynames=(char**)(argu[4]);
      pvalues=(char**)(argu[8]);
      pcomments=(char**)(argu[5]);
      punits=(char**)(argu[6]);
      if ((exist_keynames==0)||(exist_values==0)) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(FS_ERR_BAD_NBKEYS);
      }
      /* --- on calcule le nombre de mots cles dans l'entete ---*/
      if ((msg=libfiles_main(FS_FITS_GET_HDRSPACE,3,fptr,&nbkeys,&morekeys))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      *(int*)(argu[3])=nbkeys;
      /* --- on dimensionne keynames ---*/
      keynames=NULL;
      lenp=(int)(FLEN_KEYWORD);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&keynames,&nbkeys,&lenp,"p->keynames"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in macr_read_keys for pointer keynames");
         return(TT_ERR_PB_MALLOC);
      }
      *pkeynames=(void*)keynames;
      /* --- on dimensionne values ---*/
      values=NULL;
      lenp=(int)(FLEN_VALUE);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&values,&nbkeys,&lenp,"p->values"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in macr_read_keys for pointer values");
         tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
         return(TT_ERR_PB_MALLOC);
      }
      *pvalues=(void*)values;
      /* --- on dimensionne comments ---*/
      if (exist_comments==1) {
         comments=NULL;
         lenp=(int)(FLEN_COMMENT);
         if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&comments,&nbkeys,&lenp,"p->comments"))!=0) {
            tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in macr_read_keys for pointer comments");
            tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
            tt_util_free_ptrptr2((void***)&values,"p->values");
            return(TT_ERR_PB_MALLOC);
         }
         *pcomments=(void*)comments;
      }
      /* --- on dimensionne units ---*/
      if (exist_comments==1) {
         units=NULL;
         lenp=(int)(FLEN_COMMENT);
         if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&units,&nbkeys,&lenp,"p->units"))!=0) {
            tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in macr_read_keys for pointer units");
            tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
            tt_util_free_ptrptr2((void***)&values,"p->values");
            tt_util_free_ptrptr2((void***)&comments,"p->comments");
            return(TT_ERR_PB_MALLOC);
         }
         *punits=(void*)units;
      }
      /* --- on dimensionne datatypes ---*/
      datatypes=NULL;
      lenp=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&datatypes,&nbkeys,&lenp,"p->datatypes"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in macr_read_keys for pointer datatypes");
         tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
         tt_util_free_ptrptr2((void***)&values,"p->values");
         tt_util_free_ptrptr2((void***)&comments,"p->comments");
         tt_util_free_ptrptr2((void***)&units,"p->units");
         return(TT_ERR_PB_MALLOC);
      }
      *(int**)(argu[7])=datatypes;
      /* --- on lit la liste ---*/
      for (k=0,kk=1;k<nbkeys;k++,kk++) {
         if (exist_comments==1) {
            if ((msg=libfiles_main(FS_FITS_READ_KEYN,5,fptr,&kk,keynames[k],values[k],comments[k]))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
               tt_util_free_ptrptr2((void***)&values,"p->values");
               tt_util_free_ptrptr2((void***)&comments,"p->comments");
               if (exist_units==1) {
                  tt_util_free_ptrptr2((void***)&units,"p->units");
               }
               tt_free(&datatypes,"p->datatypes");
               return(msg);
            }
            if ((exist_units==1) && strcmp(keynames[k],"")) {
               if ((msg=libfiles_main(FS_FITS_READ_KEY_UNIT,3,fptr,keynames[k],units[k]))!=0) {
                  libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
                  tt_free(&datatypes,"p->datatypes");
                  tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
                  tt_util_free_ptrptr2((void***)&values,"p->values");
                  tt_util_free_ptrptr2((void***)&comments,"p->comments");
                  tt_util_free_ptrptr2((void***)&units,"p->units");
                  return(msg);
               }
            }
         } else {
            if ((msg=libfiles_main(FS_FITS_READ_KEYN,5,fptr,&kk,keynames[k],values[k],NULL))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
               tt_util_free_ptrptr2((void***)&values,"p->values");
               if (exist_units==1) {
                  tt_util_free_ptrptr2((void***)&units,"p->units");
               }
               tt_free(&datatypes,"p->datatypes");
               return(msg);
            }
         }
      }
      /* --- on decode les datatypes en on enleve les quotes ---*/
      for (k=0;k<nbkeys;k++) {
         /* ajout pour FITS2 en cas de COMMENT */
         if (strcmp(keynames[k],"COMMENT")==0) {
            // le mot cle COMMENT est toujours du type TSTRING
            // il ne faut pas utiliser la FS_FITS_GET_KEYTYPE pour ce mot cle car elle retourne un type errone. 
            datatypes[k]=TSTRING;
            dtype = 'C';
         } else {
            if (strcmp(values[k],"")==0) {
               strcpy(values[k]," ");
            }
            if ((msg=libfiles_main(FS_FITS_GET_KEYTYPE,2,values[k],&dtype))!=0) {
               tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
               tt_util_free_ptrptr2((void***)&values,"p->values");
               if (exist_comments==1) {tt_util_free_ptrptr2((void***)&comments,"p->comments");}
               if (exist_units==1) {tt_util_free_ptrptr2((void***)&units,"p->units");}
               tt_free(&datatypes,"p->datatypes");
               return(msg);
            }
            if      (dtype=='C') { datatypes[k]=TSTRING; }
            else if (dtype=='L') { datatypes[k]=TSTRING; }
            else if (dtype=='I') { datatypes[k]=TINT; }
            else if (dtype=='F') {
               chaine=values[k];
               len=strlen(chaine);
               for (ndigit=0,kk=1;kk<len;kk++) {
                  cdigit=chaine[kk];
                  if ((cdigit=='e')||(cdigit=='E')) {
                     break;
                  }
                  if ((cdigit>='0')||(cdigit<='9')) {
                     ndigit++;
                  }
               }
               if (ndigit<=6) {
                  datatypes[k]=TFLOAT;
               } else {
                  datatypes[k]=TDOUBLE;
               }
            }
            else { datatypes[k]=TSTRING; }
         }
         
         if (dtype=='C') {
            chaine=values[k];
            len=strlen(chaine);
            for (kk=0;kk<(len-1);kk++) {
               chaine[kk]=chaine[kk+1];
            }
            if (len>=2) { chaine[len-2]='\0'; }
         }
         /*printf("k=%d %s=%s |%c|%d|\n",k,keynames[k],values[k],dtype,datatypes[k]);*/
      }
   } else {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(FS_ERR_BAD_NBKEYS);
   }
   
   /* --- fermeture du fichier ---*/
   if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
   return(OK_DLL);
}

int macr_rename_keys(void *arg1)
/***************************************************************************/
/* Modifie le nom de mots cle ou les supprime.                             */
/***************************************************************************/
/* arg1 : Nom du fichier FITS a ouvrir (dossier+nom+ext)                   */
/*        (char)(*nom_fichier).                                            */
/* arg2 : Numero du header dans lequel on veut lire les mots cle.          */
/*        (int)(numhdu).                                                   */
/* arg3 : Nombre de mots cles a renomer.                                   */
/*        (int)(nbkeys). Uniquement =1 pour l'instant                      */
/*                                                                         */
/* Si arg3==1 :                                                            */
/* arg4 : Ancien nom du mot cle a lire.                                    */
/*        (char) (*keyname)                                                */
/* arg5 : Nouveau nom du mot cle a lire.                                   */
/*        La ligne est supprimee si =NULL                                  */
/*        (char) (*keyname)                                                */
/***************************************************************************/
{
   int typemode=READWRITE,numhdu,nbkeys,nbhdu,typechdu;
   char *oldkeyname,*newkeyname;
   int msg;
   char *nom_fichier;
   void *fptr;
   void **argu;

   argu=(void**)(arg1);
   nom_fichier=(char*)(argu[1]);
   numhdu=*(int*)(argu[2]);
   nbkeys=*(int*)(argu[3]);

   /* --- ouverture en ecriture du fichier fits ---*/
   if ((msg=libfiles_main(FS_FITS_OPEN_FILE,3,&fptr,nom_fichier,&typemode))!=0) {
      return(msg);
   }
   /* --- selection du header courant du fichier fits    --- */
   /* --- dans lequel on inserera les nouveaux mots cle --- */
   if ((msg=libfiles_main(FS_FITS_GET_NUM_HDUS,2,fptr,&nbhdu))!=0) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(msg);
   }
   if ((numhdu<=0)||(numhdu>nbhdu)) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(FS_ERR_HDUNUM_OVER);
   } else {
      if ((msg=libfiles_main(FS_FITS_MOVABS_HDU,3,fptr,&numhdu,&typechdu))!=0) {
	 libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
	 return(msg);
      }
   }

   if (nbkeys==1) {
      oldkeyname=(char*)(argu[4]);
      newkeyname=(char*)(argu[5]);
      if (newkeyname==NULL) {
	 if ((msg=libfiles_main(FS_FITS_DELETE_,3,"key",fptr,oldkeyname))!=0) {
	    libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
	    return(msg);
	 }
      } else {
	 if ((msg=libfiles_main(FS_FITS_MODIFY_NAME,3,fptr,oldkeyname,newkeyname))!=0) {
	    libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
	    return(msg);
	 }
      }
   } else if (nbkeys!=1) {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      return(FS_ERR_BAD_NBKEYS);
   }

   /* --- fermeture du fichier ---*/
   if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
   return(OK_DLL);
}

