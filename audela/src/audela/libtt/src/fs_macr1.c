/* fs_macr1.c
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

int macr_write(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8,void *arg9,void *arg10,void *arg11)
/***************************************************************************/
/* Ecrit une nouvelle image ou une nouvelle table dans un fichier Fits     */
/***************************************************************************/
/* arg1 : Nom du fichier FITS a ouvrir ou a creer (dossier+nom+ext)        */
/*        (char)(*nom_fichier).                                            */
/* arg2 : Numero du header derriere lequel on veut inserer les donnees.    */
/*        Si arg2=NULL alors un nouveau fichier est cree. Attention, il y  */
/*        aura deux header si arg3=*_TBL.                                  */
/*        La valeur arg2=0 est interdite. On commence toujours a inserer   */
/*        apres le premier header.                                         */
/*        (int)(numhdu).                                                   */
/* arg3 : Type d'entete : IMAGE_HDU ou ASCII_TBL ou BINARY_TBL.            */
/*        (int)(typehdu).                                                  */
/* arg4 : Nom du fichier FITS depuis lequel on va recopier les lignes      */
/*        d'entete.                                                        */
/*        On n'utilise pas de tel fichier si arg4=NULL.                    */
/*        (char)(*nom_fichier_ref).                                        */
/* arg5 : Numero du header du fichier de reference (arg4) depuis lequel    */
/*        on va recopier les lignes d'entete.                              */
/*        On n'utilise pas de tel fichier si arg5=NULL.                    */
/*        (int)(numhdu_ref).                                               */
/* arg6 : liste de mots cles reserves que l'on ne veut pas recopier depuis */
/*        l'entete du fichier de reference.                                */
/*        (char**)(liste_ref)                                              */
/*        Un pointeur NULL est ajoute a la fin de la liste pour signaler   */
/*        qu'elle est terminee.                                            */
/*                                                                         */
/* Si le type d'entete est une IMAGE_HDU :                                 */
/*                                                                         */
/* arg7 : Nombre d'axes de l'image.                                        */
/*        (int)(naxis).                                                    */
/* arg8 : Tableau qui donne le nombre de pixels sur chaque axe de l'image. */
/*        (int)(*naxes)                                                    */
/* arg9 : Code de bitpix decrivant le format des donnees sur le disque.    */
/*        (int)(bitpix).                                                   */
/* arg10 : Code du type de donnees associees au pointeur image.             */
/*        (int)(datatype).                                                 */
/* arg11: Pointeur image.                                                  */
/*        (void)(*array).                                                  */
/*                                                                         */
/* Si le type d'entete est une ASCII_TBL ou une BINARY_TBL :               */
/*                                                                         */
/* arg7 : Nombre de colonnes (=champs) de la table.                        */
/*        (int)(tfields).                                                  */
/* arg8 : Nombre de lignes de la table.                                    */
/*        (long)(nrows).                                                   */
/* arg9 : Pointeur **tform de la table.                                    */
/*        Si arg9=NULL, **tform sera calcule automatiquement a partir      */
/*        de la valeur de datatypes.                                       */
/*        (char)(**tform).                                                 */
/* arg10 : Pointeur **ttype de la table.                                    */
/*        Si arg10=NULL, **ttype sera calcule automatiquement.              */
/*        (char)(**ttype).                                                 */
/* arg11: Pointeur **tunit de la table.                                    */
/*        Si arg11=NULL, **tunit sera calcule automatiquement.             */
/*        (char)(**tunit).                                                 */
/* arg12: Tableau des datatypes associes a chaque colonne.                 */
/*        (int)(*datatypes).                                               */
/* arg13: Tableau de donnees de la premiere colonne.                       */
/*        (void)(**col1) pour des donnees **char.                          */
/*        (void)(*col1) pour les autres types.                             */
/* arg14: Tableau de donnees de la deuxieme colonne.                       */
/*        (void)(**col2) pour des donnees **char.                          */
/*        (void)(*col2) pour les autres types.                             */
/* arg... ainsi de suite.                                                  */
/*                                                                         */
/***************************************************************************/
{
   int typemode=READWRITE,numhdu,typehdu,*numhdu_ref,typemode_ref=READONLY;
   FILE *dummy;
   int msg,nbhdu,typehdu_ref,typechdu;
   char *nom_fichier,*fichier_ref;
   void *fptr,*fptr_ref;
   int naxis, bitpix;
   long *naxes=NULL,nrows;
   int tfields;
   char **tform,**tunit,**ttype,*extname=NULL;
   char *tform_data=NULL,*tunit_data=NULL,*ttype_data=NULL;
   int taille,nbcar;
   int datatype,*datatypes=NULL;
   void *array,**arraystring;
   int k;
   long firstelem,nelements,firstrow;
   int new_file=0,ref_file=0;
   int exist_tform=0,exist_ttype=0,exist_tunit=0;
   long pcount,rowlen;
   int nbmotcle,morekeys;
   char keyname[FLEN_KEYWORD];
   char value[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char card[FLEN_CARD];
   int match,nbcards=0,nbexclus;
   char **cards=NULL,*cards_data=NULL,**exclus,*exclu0s;
   void **argu;
   
   argu=(void**)(arg11);
   nom_fichier=(char*)(arg1);
   typehdu=*(int*)(arg3);
   
   /* --- ouverture en lecture du fichier de reference ---*/
   ref_file=(arg4!=NULL)?1:0;
   if (ref_file==1) {
      fichier_ref=(char*)(arg4);
      numhdu_ref=(int*)(arg5);
      if ((msg=libfiles_main(FS_FITS_OPEN_FILE,3,&fptr_ref,fichier_ref,&typemode_ref))!=0) {
         return(msg);
      }
      /* --- selection du header courant du fichier de reference ---*/
      if ((msg=libfiles_main(FS_FITS_GET_NUM_HDUS,2,fptr_ref,&nbhdu))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
         return(msg);
      }
      if ((*numhdu_ref>=1)&&(*numhdu_ref<=nbhdu)) {
         if ((msg=libfiles_main(FS_FITS_MOVABS_HDU,3,fptr_ref,numhdu_ref,&typehdu_ref))!=0) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
            return(msg);
         }
      } else {
         libfiles_main(FS_FITS_CLOSE_FILE,fptr_ref);
         return(FS_ERR_HDUNUM_OVER);
      }
   }
   
   /* --- stockage de l'entete du fichier de reference ---*/
   if (ref_file==1) {
      /*printf("toto 1.5 %p nbmotcle=%d\n",fptr_ref,nbmotcle);*/
      if ((msg=libfiles_main(FS_FITS_GET_HDRSPACE,3,fptr_ref,&nbmotcle,&morekeys))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
         return(msg);
      }
      cards=NULL;
      /*printf("toto 1.6 nbmotcle=%d\n",nbmotcle);*/
      if((cards=(char**)calloc(nbmotcle,sizeof(void*)))==NULL) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
         return(FS_ERR_PB_MALLOC);
      }
      nbcar=(FLEN_CARD)*sizeof(char);
      taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
      cards_data=NULL;
      if((cards_data=(char*)calloc(nbmotcle,taille))==NULL) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
         return(FS_ERR_PB_MALLOC);
      }
      for (k=0;k<=nbmotcle-1;k++) {
         cards[k]=cards_data+k*taille;
      }
      nbcards=0;
      for (k=1;k<=nbmotcle;k++) {
         if ((msg=libfiles_main(FS_FITS_READ_RECORD,3,fptr_ref,&k,card))!=0) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
            return(msg);
         }
         if ((msg=libfiles_main(FS_FITS_READ_KEYN,5,fptr_ref,&k,keyname,value,comment))!=0) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
            return(msg);
         }
         if (arg6!=NULL) {
            exclus=(char**)(arg6);
            nbexclus=0;
            while((exclu0s=exclus[nbexclus++])!=NULL);
            nbexclus--;
         } else {
            nbexclus=0;
            exclus=NULL;
         }
         /*printf("adresse exclus=%p (nbexclus=%d)\n",exclus,nbexclus);*/
         if ((msg=libfiles_main(FS_UTIL_MATCH_RESERVED_KEY,4,keyname,&match,&exclus,&nbexclus))!=0) {
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref);
            return(msg);
         }
         if (match==0) {
            sprintf(cards[nbcards],"%s",card);
            nbcards++;
         }
      }
      if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr_ref))!=0) {
         free(cards);free(cards_data);
         return(msg);
      }
   }
   
   /* --- ouverture en ecriture du fichier fits ---*/
   new_file=(arg2==NULL)?1:0;
   if (new_file==1) {
      if ((dummy=fopen(nom_fichier,"r"))!=NULL) {
         if ((msg=fclose(dummy))!=0) { return(FS_ERR_REMOVE_FILE); }
         if ((msg=remove(nom_fichier))!=0) { return(FS_ERR_REMOVE_FILE); }
      }
      if ((msg=libfiles_main(FS_FITS_CREATE_FILE,2,&fptr,nom_fichier))!=0) {
         if (ref_file==1) {free(cards);free(cards_data);}
         return(msg);
      }

      numhdu=0;
   } else {
      numhdu=*(int*)(arg2);
      if ((msg=libfiles_main(FS_FITS_OPEN_FILE,3,&fptr,nom_fichier,&typemode))!=0) {
         if (ref_file==1) {free(cards);free(cards_data);}
         return(msg);
      }
      /* --- selection du header courant du fichier fits    --- */
      /* --- derriere lequel on inserera la nouvelle entete --- */
      if ((msg=libfiles_main(FS_FITS_GET_NUM_HDUS,2,fptr,&nbhdu))!=0) {
         if (ref_file==1) {free(cards);free(cards_data);}
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      if ((numhdu<0)||(numhdu>nbhdu)) {
         if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
         if (ref_file==1) {free(cards);free(cards_data);}
         return(FS_ERR_HDUNUM_OVER);
      } else /*if (numhdu!=0)*/ {
         if ((msg=libfiles_main(FS_FITS_MOVABS_HDU,3,fptr,&numhdu,&typechdu))!=0) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            return(msg);
         }
      }
   }
   
   /* --- creation de l'entete minimale d'une image ---*/
   if (typehdu==IMAGE_HDU) {
      naxis=*(int*)(arg7);
      naxes=(long*)(arg8);
      bitpix=*(int*)(arg9);
      if ((msg=libfiles_main(FS_FITS_INSERT_IMG,4,fptr,&bitpix,&naxis,naxes))!=0) {
         if (ref_file==1) {free(cards);free(cards_data);}
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
      // suppression des deux mots cles COMMENT inutiles qui sont ajoutes systematiquement par fits_create_file()
      // COMMENT  "FITS (Flexible Image Transport System) format is defined in 'Astronomy "
      // COMMENT   "and Astrophysics', volume 376, page 3"   
      libfiles_main(FS_FITS_DELETE_,3,"key",fptr,"COMMENT");
      libfiles_main(FS_FITS_DELETE_,3,"key",fptr,"COMMENT");
   }
   /* --- creation de l'entete minimale d'une table ---*/
   else if ((typehdu==BINARY_TBL)||(typehdu==ASCII_TBL)) {
      tfields=*(int*)(arg7);
      nrows=*(long*)(arg8);
      exist_tform=(arg9==NULL)?0:1;
      exist_ttype=(arg10==NULL)?0:1;
      exist_tunit=(argu[11]==NULL)?0:1;
      /*
      printf("tfields=%d nrows=%d\n",tfields,nrows);
      printf("exist <tform=%d ttype=%d tunit=%d>\n",exist_tform,exist_ttype,exist_tunit);
      for (k=1;k<=14;k++) {
      printf("adr. arg%d=%d val=%d \n",k,argu[k],*(int*)(argu[k]));
      }
      */
      datatypes=(int*)(argu[12]);
      if (exist_tform==0) {
         tform=NULL;
         if((tform=(char**)calloc(tfields,sizeof(void*)))==NULL) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            return(FS_ERR_PB_MALLOC);
         }
         nbcar=(FLEN_VALUE)*sizeof(char);
         taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
         tform_data=NULL;
         if((tform_data=(char*)calloc(tfields,taille))==NULL) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            free(tform);
            return(FS_ERR_PB_MALLOC);
         }
         for (k=0;k<=tfields-1;k++) {
            tform[k]=tform_data+k*taille;
         }
         for (k=0;k<=tfields-1;k++) {
            if (datatypes[k]<=TSTRINGS) {
               if (typehdu==BINARY_TBL) {
                  if      (datatypes[k]==TSHORT) { sprintf(tform[k],"1I"); }
                  else if (datatypes[k]==TINT) { sprintf(tform[k],"1J"); }
                  else if (datatypes[k]==TLONG) { sprintf(tform[k],"1J"); }
                  else if (datatypes[k]==TFLOAT) { sprintf(tform[k],"1E"); }
                  else if (datatypes[k]==TDOUBLE) { sprintf(tform[k],"1D"); }
                  else { /* datatype non reconnu */ }
               } else if (typehdu==ASCII_TBL) {
                  if      (datatypes[k]==TSHORT) { sprintf(tform[k],"I6"); }
                  else if (datatypes[k]==TINT) { sprintf(tform[k],"I11"); }
                  else if (datatypes[k]==TLONG) { sprintf(tform[k],"I20"); }
                  else if (datatypes[k]==TFLOAT) { sprintf(tform[k],"E15.7"); }
                  else if (datatypes[k]==TDOUBLE) { sprintf(tform[k],"D23.15"); }
                  else { /* datatype non reconnu */ }
               }
            } else {
               /* chaine de caracteres */
               datatypes[k]-=TSTRINGS;
               if (typehdu==BINARY_TBL) {
                  sprintf(tform[k],"%dA",datatypes[k]);
               } else if (typehdu==ASCII_TBL) {
                  sprintf(tform[k],"A%d",datatypes[k]);
               }
               datatypes[k]=TSTRING;
            }
         }
      } else {
         tform=(char**)(argu[9]);
      }
      if (exist_ttype==0) {
         ttype=NULL;
         if((ttype=(char**)calloc(tfields,sizeof(void*)))==NULL) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==0) {free(tform);free(tform_data);}
            return(FS_ERR_PB_MALLOC);
         }
         nbcar=(FLEN_VALUE)*sizeof(char);
         taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
         ttype_data=NULL;
         ttype_data=(char*)calloc(tfields,taille);
         if((ttype_data=(char*)calloc(tfields,taille))==NULL) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            free(ttype);
            if (exist_tform==0) {free(tform);free(tform_data);}
            return(FS_ERR_PB_MALLOC);
         }
         for (k=0;k<=tfields-1;k++) {
            ttype[k]=ttype_data+k*taille;
         }
         for (k=0;k<=tfields-1;k++) {
            sprintf(ttype[k],"col_%d",k+1);
         }
      } else {
         ttype=(char**)(argu[10]);
      }
      if (exist_tunit==0) {
         tunit=NULL;
         if((tunit=(char**)calloc(tfields,sizeof(void*)))==NULL) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==0) {free(tform);free(tform_data);}
            if (exist_ttype==0) {free(ttype);free(ttype_data);}
            return(FS_ERR_PB_MALLOC);
         }
         nbcar=(FLEN_VALUE)*sizeof(char);
         taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
         tunit_data=NULL;
         if((tunit_data=(char*)calloc(tfields,taille))==NULL) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            free(tunit);
            if (exist_tform==0) {free(tform);free(tform_data);}
            if (exist_ttype==0) {free(ttype);free(ttype_data);}
            return(FS_ERR_PB_MALLOC);
         }
         for (k=0;k<=tfields-1;k++) {
            tunit[k]=tunit_data+k*taille;
         }
         for (k=0;k<=tfields-1;k++) {
            sprintf(tunit[k],"undefined");
         }
      } else {
         tunit=(char**)(argu[11]);
      }
      /*
      for (k=0;k<=tfields-1;k++) {
      printf("datatypes[%d]=%d\n",k,datatypes[k]);
      printf("tform='%s'\n",tform[k]);
      printf("ttype='%s'\n",ttype[k]);
      printf("tunit='%s'\n",tunit[k]);
      }
      */
      if (typehdu==BINARY_TBL) {
         pcount=0;
         if ((msg=libfiles_main(FS_FITS_INSERT_,9,&typehdu,fptr,&nrows,&tfields,ttype,tform,tunit,extname,&pcount))!=0) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==0) {free(tform);free(tform_data);}
            if (exist_ttype==0) {free(ttype);free(ttype_data);}
            if (exist_tunit==0) {free(tunit);free(tunit_data);}
            return(msg);
         }
      }
      if (typehdu==ASCII_TBL) {
         rowlen=0;
         if ((msg=libfiles_main(FS_FITS_INSERT_,10,&typehdu,fptr,&rowlen,&nrows,&tfields,ttype,NULL,tform,tunit,extname))!=0) {
            if (ref_file==1) {free(cards);free(cards_data);}
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            if (exist_tform==0) {free(tform);free(tform_data);}
            if (exist_ttype==0) {free(ttype);free(ttype_data);}
            if (exist_tunit==0) {free(tunit);free(tunit_data);}
            return(msg);
         }
      }
      if (exist_tform==0) {free(tform);free(tform_data);}
      if (exist_ttype==0) {free(ttype);free(ttype_data);}
      if (exist_tunit==0) {free(tunit);free(tunit_data);}
   } else {
      libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
      if (ref_file==1) {free(cards);free(cards_data);}
      return(FS_ERR_TYPEHDU_NOT_KNOWN);
   }
      
   /* --- complete l'entete a partir du fichier de reference ---*/
   if (ref_file==1) {
      for (k=0;k<=nbcards-1;k++) {
         if ((msg=libfiles_main(FS_FITS_WRITE_RECORD,2,fptr,cards[k]))!=0) {
            free(cards);free(cards_data);
            libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
            return(msg);
         }
      }
      free(cards);free(cards_data);
   }
   
   /* --- enregistrement d'une image ---*/
   if (typehdu==IMAGE_HDU) {
      datatype=*(int*)(arg10);
      array=argu[11];
      firstelem=1;
      for (k=0,nelements=1;k<=naxis-1;k++) { nelements*=naxes[k]; }
      if ((msg=libfiles_main(FS_FITS_WRITE_IMG,5,fptr,&datatype,&firstelem,&nelements,array))!=0) {
         libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
         return(msg);
      }
   }
   /* --- enregistrement d'une table ---*/
   else if ((typehdu==BINARY_TBL)||(typehdu==ASCII_TBL)) {
      for (k=1;k<=tfields;k++) {
         firstelem=1;
         firstrow=1;
         datatype=datatypes[k-1];
         if (datatype==TSTRING) {
            arraystring=(void**)(argu[13+k-1]);
            if ((msg=libfiles_main(FS_FITS_WRITE_COL,7,fptr,&datatype,&k,&firstrow,&firstelem,&nrows,arraystring))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(msg);
            }
         } else {
            array=argu[13+k-1];
            if ((msg=libfiles_main(FS_FITS_WRITE_COL,7,fptr,&datatype,&k,&firstrow,&firstelem,&nrows,array))!=0) {
               libfiles_main(FS_FITS_CLOSE_FILE,1,fptr);
               return(msg);
            }
         }
      }
   }
   
   /* --- fermeture du fichier ---*/
   if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) { return(msg); }
   return(OK_DLL);

}

int macr_arrays2d2datainfo(void *arg1,void *arg2,void **arg3)
/***************************************************************************/
/* Cree la structure datainfo et l'initialise                              */
/***************************************************************************/
{
   void *images2d;
   datainfo_struct *datainfo;
   int *indice;
   char chaine[80];
   int valeur;
   indice=(int*)(arg2);
   images2d=arg1;
   if ( ( datainfo=(datainfo_struct*)calloc(1,sizeof(datainfo_struct)) )==NULL) {
      return(FS_ERR_PB_MALLOC);
   }
   libfiles_main(FS_UTIL_GET_ARRAYS2D,4, images2d,indice,"indice",chaine);valeur=atoi(chaine);
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"indice",&valeur);
   libfiles_main(FS_UTIL_GET_ARRAYS2D,4, images2d,indice,"hdunum",chaine);valeur=atoi(chaine);
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"hdunum",&valeur);
   valeur=ARRAY_2D;
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"type",&valeur);
   libfiles_main(FS_UTIL_GET_ARRAYS2D,4, images2d,indice,"type",chaine);valeur=atoi(chaine);
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"typematrix",&valeur);
   libfiles_main(FS_UTIL_GET_ARRAYS2D,4, images2d,indice,"bitpix",chaine);valeur=atoi(chaine);
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"bitpix",&valeur);
   libfiles_main(FS_UTIL_BITPIX2DATATYPE,2,&valeur,&valeur);
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"datatype",&valeur);
   libfiles_main(FS_UTIL_GET_ARRAYS2D,4, images2d,indice,"x",chaine);valeur=atoi(chaine);
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"naxis1",&valeur);
   libfiles_main(FS_UTIL_GET_ARRAYS2D,4, images2d,indice,"y",chaine);valeur=atoi(chaine);
   libfiles_main(FS_UTIL_PUT_DATAINFO,3, datainfo,"naxis2",&valeur);
   *arg3=datainfo;
   return(OK_DLL);
}

int macr_arrays_in_file(void *arg1,void *arg2,void **arg3)
/***************************************************************************/
/* Macro fonction qui retourne les informations sur les images presentes   */
/* dans un fichier FITS.                                                   */
/*-------------------------------------------------------------------------*/
/* char *arg1 : le nom du fichier (avec le chemin et l'extension)          */
/* int *arg2  : retourne le nombre d'images 2D dans le fichier             */
/* void **arg3 : malloc + remplissage des infos pour chaque image          */
/***************************************************************************/
{
   static int status=0;
   int choix;
   choix=1;
   if ((status=x_file(arg1,&choix,arg2,NULL,NULL,NULL,NULL))==0) {
      choix=2;
      status=x_file(arg1,&choix,arg2,arg3,NULL,NULL,NULL);
   }
   return(status);
}

int macr_array_read(void *arg1,void *arg2,void **arg3,void **arg4)
/***************************************************************************/
/* Macro fonction qui lit les valeurs des pixels de l'image selectionnee   */
/* par les parametres de datainfo.                                         */
/*-------------------------------------------------------------------------*/
/* char *arg1 : le nom du fichier (avec le chemin et l'extension)          */
/* void *arg2 : datainfo mis a jour                                        */
/* void **arg3 : pointeur sur les valeurs de l'image (malloc inclu)        */
/* void **arg4 : *fptr de Fitsio (malloc inclu)                            */
/***************************************************************************/
{
   static int status;
   int choix=3;
   status=x_file(arg1,&choix,NULL,NULL,arg2,arg3,arg4);
   return(status);
}

int x_file(void *arg1,void *arg2,void *arg3,void **arg4, void *arg5,void **arg6,void **arg7)
/***************************************************************************/
/* Utilitaire de macrofonctions :                                          */
/* Retourne les informations sur les images presentes dans un fichier FITS.*/
/* Lit l'une des images selectionnees.                                     */
/*-------------------------------------------------------------------------*/
/* char *arg1 : le nom du fichier (avec le chemin et l'extension)          */
/* int *arg2 : *mode=1 pour la detection du nombre de arrays               */
/*             *mode=2 pour les informations sur les arrays                */
/*             *mode=3 pour le chargement de l'array choisi                */
/* int *arg3  : retourne le nombre d'images 2D dans le fichier             */
/* void **arg4 : malloc + remplissage des infos pour chaque image          */
/* void *arg5 : datainfo mis a jour                                        */
/* void **arg6 : pointeur sur les valeurs de l'image (malloc inclu)        */
/*               le type vaut bitpix trouve dans datainfo.                 */
/* void **arg7 : *fptr de Fitsio (malloc inclu)                            */
/***************************************************************************/
{
   void *fptr=NULL;
   void *image2d;
   void *datainfo;
   void *p;

   int *mode;
   int nbhdu,typehdu,typemode,maxdim;
   int k00,k,kk,kkk,nbmotcle,nbi,nbitot;
   int msg=0;
   char motcle[FLEN_KEYWORD],chaine[FLEN_VALUE],chaine2[80];
   char *nom_fichier;
   int naxis=0,naxis1=0,naxis2=0,bitpix=0,naxisxxx=0;
   long naxes[3],group;
   int tfields,morekeys;
   int array_ok;
   int *pnbitot;
   int type2d;
   int datatype,firstelem,nelements,indice_choisi=0,nbi0,anynul;
   void *nulval;
   double valeurd;
   datainfo=arg5;

   nom_fichier=(char*)(arg1);
   mode=(int*)(arg2);
   pnbitot=(int*)(arg3);

   if (*mode==2) {
      /* on alloue la place pour la structure 'image2d' qui retourne les infos ---*/
      if ((msg=libfiles_main(FS_UTIL_CALLOC_PTR_IMAGE2D,2,&image2d,&nbitot))!=0) {internal_erreur(msg); return(msg);}
      *arg4=(void*)(image2d);
   }
   if (*mode==3) {
      /* on decode quelques infos de la structure 'datainfo' de l'image a charger ---*/
      /* ici on lit le datatype impose */
      if ((msg=libfiles_main(FS_UTIL_GET_DATAINFO,3,datainfo,"datatype",chaine2))!=0) {internal_erreur(msg); return(msg);} else {
	 datatype=atoi(chaine2);
      }
      /* ici on lit l'indice associe a l'image selectionnee */
      if ((msg=libfiles_main(FS_UTIL_GET_DATAINFO,3,datainfo,"indice",chaine2))!=0) {internal_erreur(msg); return(msg);} else {
	 indice_choisi=atoi(chaine2);
      }
   }
   *pnbitot=nbitot=0;
   typemode=READONLY;
   if ((msg=libfiles_main(FS_FITS_OPEN_FILE,3,&fptr,nom_fichier,&typemode))!=0) {internal_erreur(msg); return(msg);}
   if ((msg=libfiles_main(FS_FITS_GET_NUM_HDUS,2,fptr,&nbhdu))!=0) {internal_erreur(msg); return(msg);}
   for (k=1;k<=nbhdu;k++) {
      if ((msg=libfiles_main(FS_FITS_MOVABS_HDU,3,fptr,&k,&typehdu))!=0) {internal_erreur(msg); return(msg);}
      if ((msg=libfiles_main(FS_FITS_GET_HDRSPACE,3,fptr,&nbmotcle,&morekeys))!=0) {internal_erreur(msg); return(msg);}
      /*printf("HDU(%d)=%d NBMOTCLE=%d (msg=%d)\n",k,typehdu,nbmotcle,msg);*/
      if (typehdu==IMAGE_HDU) {
	 bitpix=0;naxis=0;naxis1=0;naxis2=0;
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"BITPIX",chaine,NULL))!=KEY_NO_EXIST) {
	    bitpix=atoi(chaine);
	    /*printf(" BITPIX=%d (msg%d)\n",bitpix,msg);*/
	 }
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"NAXIS",chaine,NULL))!=KEY_NO_EXIST) {
	    naxis=atoi(chaine);
	    /*printf(" NAXIS=%d (msg%d)\n",naxis,msg);*/
	 }
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"NAXIS1",chaine,NULL))!=KEY_NO_EXIST) {
	    naxis1=atoi(chaine);
	    /*printf(" NAXIS1=%d (msg%d)\n",naxis1,msg);*/
	 }
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"NAXIS2",chaine,NULL))!=KEY_NO_EXIST) {
	    naxis2=atoi(chaine);
	    /*printf(" NAXIS2=%d (msg%d)\n",naxis2,msg);*/
	 }
	 /* --- on calcule nbi=le nombre d'images 2D dans ce CHDU ---*/
	 nbi=0;
	 if (naxis>=2) {
	    nbi=1;
	    for (kk=3;kk<=naxis;kk++) {
	       sprintf(motcle,"NAXIS%d",kk);
	       if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,motcle,chaine,NULL))!=KEY_NO_EXIST) {
		  naxisxxx=atoi(chaine);
		  nbi*=naxisxxx;
		  /*printf(" NAXIS%d=%d (msg%d)\n",kk,naxisxxx,msg);*/
	       } else {
		  break;
	       }
	    }
	 }
	 if ((*mode==2)&&(nbi!=0)) {
	    for (k00=nbitot+1;k00<=nbitot+nbi;k00++) {
	       type2d=FULL_2D;
	       libfiles_main(FS_UTIL_PUT_ARRAYS2D,4,image2d,&k00,"indice",&k00);
	       libfiles_main(FS_UTIL_PUT_ARRAYS2D,4,image2d,&k00,"hdunum",&k);
	       libfiles_main(FS_UTIL_PUT_ARRAYS2D,4,image2d,&k00,"bitpix",&bitpix);
	       libfiles_main(FS_UTIL_PUT_ARRAYS2D,4,image2d,&k00,"type",&type2d);
	       libfiles_main(FS_UTIL_PUT_ARRAYS2D,4,image2d,&k00,"x",&naxis1);
	       libfiles_main(FS_UTIL_PUT_ARRAYS2D,4,image2d,&k00,"y",&naxis2);
	    }
	 }
	 if (*mode==3) {
	    /*printf("nbitot=%d indice_choisi=%d nbi=%d\n",nbitot,indice_choisi,nbi);*/
	    if( ((nbitot+1)<=indice_choisi)&&(indice_choisi<=(nbitot+nbi)) ) {
	       nelements=naxis1*naxis2;
	       nbi0=indice_choisi-(nbitot+1);
	       firstelem=1+nbi0*nelements;
	       /* on alloue la place pour le pointeur de l'image ---*/
	       if ((msg=libfiles_main(FS_UTIL_CALLOC_PTR_DATATYPE,3,&p,&nelements,&datatype))!=0) {internal_erreur(msg); return(msg);}
	       *arg6=(void*)(p);
	       valeurd=0.;
	       util_put_datatype(&datatype,&nulval,&valeurd);
	       anynul=0;
	       group=0;
	       /* lecture de l'image ---*/
	       /*printf("datatype=%d firstelem=%d nelements=%d nulval=%d\n",datatype,firstelem,nelements,*(float*)(nulval));*/
	       if ((msg=libfiles_main(FS_FITS_READ_IMG_,8,&datatype,fptr,&group,&firstelem,&nelements,nulval,p,&anynul))!=0) {internal_erreur(msg); return(msg);}
	       /*printf("anynul=%d\n",anynul);*/
	    }
	 }
	 nbitot+=nbi;
      } /* fin du header IMAGE_HDU */
      if ((typehdu==BINARY_TBL)||(typehdu==ASCII_TBL)) {
	 bitpix=0;naxis=0;naxis1=0;naxis2=0;tfields=0;
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"BITPIX",chaine,NULL))!=KEY_NO_EXIST) {
	    bitpix=atoi(chaine);
	    /*printf(" BITPIX=%d (msg%d)\n",bitpix,msg);*/
	 }
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"NAXIS",chaine,NULL))!=KEY_NO_EXIST) {
	    naxis=atoi(chaine);
	    /*printf(" NAXIS=%d (msg%d)\n",naxis,msg);*/
	 }
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"NAXIS1",chaine,NULL))!=KEY_NO_EXIST) {
	    naxis1=atoi(chaine);
	    /*printf(" NAXIS1=%d (msg%d)\n",naxis1,msg);*/
	 }
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"NAXIS2",chaine,NULL))!=KEY_NO_EXIST) {
	    naxis2=atoi(chaine);
	    /*printf(" NAXIS2=%d (msg%d)\n",naxis2,msg);*/
	 }
	 if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,"TFIELDS",chaine,NULL))!=KEY_NO_EXIST) {
	    tfields=atoi(chaine);
	    /*printf(" TFIELDS=%d (msg%d)\n",tfields,msg);*/
	 }
	 nbi=0;
	 if ((naxis==2)&&(bitpix==8)) { /* toujours vrai pour BINTABLE */
	    array_ok=0;
	    /* --- on repere la presence d'une matrice eventuelle avec TDIM ---*/
	    for (kk=1;kk<=tfields;kk++) {
	       sprintf(motcle,"TDIM%d",kk);
	       if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,motcle,chaine,NULL))!=KEY_NO_EXIST) {
		  for(kkk=0;kkk<3;kkk++) {naxes[kkk]=0;}
		  maxdim=3;
		  if ((msg=libfiles_main(FS_FITS_READ_TDIM,5,fptr,&kk,&maxdim,&naxis,naxes))==0) {
		     /*printf(" TDIM%d=%s (%ld %ld %ld) naxis=%d\n",kk,chaine,naxes[0],naxes[1],naxes[2],naxis);*/
		     if (naxes[2]!=0) {
			nbi=1;
			array_ok=1;
		     }
		     else if (naxes[1]!=0) {
			nbi=1;
			array_ok=1;
		     }
		  } else { internal_erreur(msg); }
	       }
	    }
	    /* --- on repere la presence d'une 'liste de pixels' eventuelle ---*/
	    if (array_ok==0) {
	       for (kk=1;kk<=tfields;kk++) {
		  sprintf(motcle,"TTYPE%d",kk);
		  if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,motcle,chaine,NULL))!=KEY_NO_EXIST) {
		     if (strcmp(chaine,"'X       '")==0) {
			nbi-=1;
			sprintf(motcle,"TLMAX%d",kk);
			if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,motcle,chaine,NULL))!=KEY_NO_EXIST) {
			   naxis1=atoi(chaine);
			}
		     }
		     if (strcmp(chaine,"'Y       '")==0) {
			nbi-=1;
			sprintf(motcle,"TLMAX%d",kk);
			if ((msg=libfiles_main(FS_FITS_READ_KEYWORD,4,fptr,motcle,chaine,NULL))!=KEY_NO_EXIST) {
			   naxis2=atoi(chaine);
			}
		     }
		     if (nbi==-2) {
			nbi=1;
		     }
		  }
	       }
	       if (nbi<=0) {nbi=0;}
	    }
	    nbi*=naxis2;
	    nbitot+=nbi;
	 }
      } /* fin de la condition BINARY_TBL / ASCII_TBL*/
      /*getch();*/
   }
   /*printf("Il y a %d images dans ce fichier FITS\n",nbitot);*/
   if (*mode==1) {
      if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) {internal_erreur(msg); return(msg);}
   } else if (*mode==2) {
      if ((msg=libfiles_main(FS_FITS_CLOSE_FILE,1,fptr))!=0) {internal_erreur(msg); return(msg);}
   } else if (*mode==3) {
      *arg7=fptr;
   }
   *pnbitot=nbitot;
   return(0);
}


