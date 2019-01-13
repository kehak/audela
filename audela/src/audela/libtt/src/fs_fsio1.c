/* fs_fsio1.c
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

/***************************************************************************/
/****                      fonctions du groupe 5.1                         */
/***************************************************************************/

int fts_get_errstatus(void *arg1,void *arg2)
/* -1--------------------------------------------------------------------- */
{
   int status;
   char *err_text;
   status=*(int*)(arg1);
   err_text=(char*)(arg2);
   fits_get_errstatus(status,err_text);
   return(OK_DLL);
}

/***************************************************************************/
/****                      fonctions du groupe 5.2                         */
/***************************************************************************/

int fts_open_file(void *arg1,void *arg2,void *arg3)
/* -1--------------------------------------------------------------------- */
{
   static int status;
   char *nom_fichier;
   int *mode;
   fitsfile **fptr;
   fptr=(fitsfile**)(arg1);
   nom_fichier=(char*)(arg2);
   mode=(int*)(arg3);
   status=0;
   fits_open_file(fptr,nom_fichier,*mode,&status);
   return(status);
}

int fts_create_file(void *arg1,void *arg2)
/* -2--------------------------------------------------------------------- */
{
   static int status;
   char *nom_fichier;
   fitsfile **fptr;
   fptr=(fitsfile**)(arg1);
   nom_fichier=(char*)(arg2);
   status=0;
   fits_create_file(fptr,nom_fichier,&status);
   return(status);
}

int fts_close_file(void *arg1)
/* -4--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   fptr=(fitsfile*)(arg1);
   status=0;
   fits_close_file(fptr,&status);
   return(status);
}

/***************************************************************************/
/****                      fonctions du groupe 5.3                         */
/***************************************************************************/

int fts_movabs_hdu(void *arg1,void *arg2,void *arg3)
/* -1--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int *numhdu,*typehdu;
   fptr=(fitsfile*)(arg1);
   numhdu=(int*)(arg2);
   typehdu=(int*)(arg3);
   status=0;
   fits_movabs_hdu(fptr,*numhdu,typehdu,&status);
   return(status);
}

int fts_get_num_hdus(void *arg1,void *arg2)
/* -6--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int *nbhdus;
   fptr=(fitsfile*)(arg1);
   nbhdus=(int*)(arg2);
   status=0;
   fits_get_num_hdus(fptr,nbhdus,&status);
   return(status);
}

int fts_create_img(void *arg1,void *arg2,void *arg3,void *arg4)
/* -7-------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int bitpix;
   int naxis;
   long *naxes;
   fptr=(fitsfile*)(arg1);
   bitpix=*(int*)(arg2);
   naxis=*(int*)(arg3);
   naxes=(long*)(arg4);
   status=0;
   fits_create_img(fptr,bitpix,naxis,naxes,&status);
   return(status);
}

int fts_create_tbl(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8)
/* -8-------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int tbltype;
   long naxis2;
   int tfields;
   char **ttype;
   char **tform;
   char **tunit;
   char *extname;
   fptr=(fitsfile*)(arg1);
   tbltype=*(int*)(arg2);
   naxis2=*(long*)(arg3);
   tfields=*(int*)(arg4);
   ttype=(char**)(arg5);
   tform=(char**)(arg6);
   tunit=(char**)(arg7);
   extname=(char*)(arg8);
   status=0;
   fits_create_tbl(fptr,tbltype,naxis2,tfields,ttype,tform,tunit,extname,&status);
   return(status);
}

/***************************************************************************/
/****                      fonctions du groupe 5.4                         */
/***************************************************************************/

int fts_get_hdrspace(void *arg1,void *arg2,void *arg3)
/* -1--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int *keysexist;
   int *morekeys;
   fptr=(fitsfile*)(arg1);
   keysexist=(int*)(arg2);
   morekeys=(int*)(arg3);
   status=0;
   /*printf("A %p %p %p %d\n",fptr,keysexist,morekeys,*keysexist);*/
   fits_get_hdrspace(fptr,keysexist,morekeys,&status);
   /*printf("P %p %p %p %d\n",fptr,keysexist,morekeys,*keysexist);*/
   return(status);
}


int fts_update_key(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5)
/* -2--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int datatype;
   char *keyname;
   void *value;
   char *comment;
   fptr=(fitsfile*)(arg1);
   datatype=*(int*)(arg2);
   keyname=(char*)(arg3);
   value=arg4;
   comment=(char*)(arg5);
   status=0;
   if ( strcmp(keyname,"COMMENT") == 0) {
      if ( comment != NULL) {
         // mot cle au format COMMENT : "keyname comment"
         // Le standard FITS impose un format particulier pour le mot cle COMMENT
         //  Il contient seulement le nom du mot cle et le commentaire
         //  Il ne contient pas de signe egale ni de valeur.
         fits_write_comment(fptr,comment,&status);
      }
   } else {
      // mot cle au format : "keyname = value / [unit] comment"
      fits_update_key(fptr,datatype,keyname,value,comment,&status);
   }

   return(status);
}

int fts_write_record(void *arg1,void *arg2)
/* -7--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   char *card;
   fptr=(fitsfile*)(arg1);
   card=(char*)(arg2);
   status=0;
   fits_write_record(fptr,card,&status);
   return(status);
}

int fts_write_key_unit(void *arg1,void *arg2,void *arg3)
/* -8--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   char *keyname;
   char *unit;
   fptr=(fitsfile*)(arg1);
   keyname=(char*)(arg2);
   unit=(char*)(arg3);
   status=0;
   fits_write_key_unit(fptr,keyname,unit,&status);
   return(status);
}

int fts_modify_name(void *arg1,void *arg2,void *arg3)
/* -9--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   char *oldkeyname;
   char *newkeyname;
   fptr=(fitsfile*)(arg1);
   oldkeyname=(char*)(arg2);
   newkeyname=(char*)(arg3);
   status=0;
   fits_modify_name(fptr,oldkeyname,newkeyname,&status);
   return(status);
}

int fts_read_record(void *arg1,void *arg2,void *arg3)
/* -11--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int keynum;
   char *card;
   fptr=(fitsfile*)(arg1);
   keynum=*(int*)(arg2);
   card=(char*)(arg3);
   status=0;
   fits_read_record(fptr,keynum,card,&status);
   return(status);
}

int fts_read_key_unit(void *arg1,void *arg2,void *arg3)
/* -14--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   char *keyname;
   char *unit;
   fptr=(fitsfile*)(arg1);
   keyname=(char*)(arg2);
   unit=(char*)(arg3);
   status=0;
   fits_read_key_unit(fptr,keyname,unit,&status);
   return(status);
}

int fts_delete_(void *arg1,void *arg2,void *arg3)
/* -15-------------------------------------------------------------------- */
{
   static int status;
   char *choix;
   fitsfile *fptr;
   char *keyname;
   int keynum;
   choix=(char*)(arg1);
   fptr=(fitsfile*)(arg2);
   status=0;
   if (strcmp(choix,"record")==0) {
      keynum=*(int*)(arg3);
      fits_delete_record(fptr,keynum,&status);
   } else {
      keyname=(char*)(arg3);
      fits_delete_key(fptr,keyname,&status);
   }
   return(status);
}

/***************************************************************************/
/****                      fonctions du groupe 5.6                         */
/***************************************************************************/

int fts_write_img(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5)
/* -1--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int datatype;
   long firstelem;
   long nelements;
   void *array;
   fptr=(fitsfile*)(arg1);
   datatype=*(int*)(arg2);
   firstelem=*(long*)(arg3);
   nelements=*(long*)(arg4);
   array=arg5;
   status=0;
   fits_write_img(fptr,datatype,firstelem,nelements,array,&status);
   return(status);
}

int fts_read_img(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7)
/* -4--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int datatype;
   long firstelem;
   long nelements;
   void *nulval;
   void *array;
   int *anynul;
   fptr=(fitsfile*)(arg1);
   datatype=*(int*)(arg2);
   firstelem=*(long*)(arg3);
   nelements=*(long*)(arg4);
   nulval=arg5;
   array=arg6;
   anynul=(int*)(arg7);
   status=0;
   fits_read_img(fptr,datatype,firstelem,nelements,nulval,array,anynul,&status);
   return(status);
}

/***************************************************************************/
/****                      fonctions du groupe 5.7.3                       */
/***************************************************************************/

int fts_write_col(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7)
/* -1--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int datatype;
   int colnum;
   long firstrow;
   long firstelem;
   long nelements;
   void *array;
   fptr=(fitsfile*)(arg1);
   datatype=*(int*)(arg2);
   colnum=*(int*)(arg3);
   firstrow=*(long*)(arg4);
   firstelem=*(long*)(arg5);
   nelements=*(long*)(arg6);
   array=arg7;
   status=0;
   fits_write_col(fptr,datatype,colnum,firstrow,firstelem,nelements,array,&status);
   return(status);
}

int fts_read_col(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7,void *arg8,void *arg9)
/* -4--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int datatype;
   int colnum;
   long firstrow;
   long firstelem;
   long nelements;
   void *nulval;
   void *array;
   int *anynul;
   fptr=(fitsfile*)(arg1);
   datatype=*(int*)(arg2);
   colnum=*(int*)(arg3);
   firstrow=*(long*)(arg4);
   firstelem=*(long*)(arg5);
   nelements=*(long*)(arg6);
   nulval=arg7;
   array=arg8;
   anynul=(int*)(arg9);
   status=0;
   fits_read_col(fptr,datatype,colnum,firstrow,firstelem,nelements,nulval,array,anynul,&status);
   return(status);
}

/***************************************************************************/
/****                      fonctions du groupe 6.2                         */
/***************************************************************************/

int fts_create_hdu(void *arg1)
/* -2--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   fptr=(fitsfile*)(arg1);
   status=0;
   fits_create_hdu(fptr,&status);
   return(status);
}

int fts_insert_img(void *arg1,void *arg2,void *arg3,void *arg4)
/* -3--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int bitpix;
   int naxis;
   long *naxes;
   fptr=(fitsfile*)(arg1);
   bitpix=*(int*)(arg2);
   naxis=*(int*)(arg3);
   naxes=(long*)(arg4);
   status=0;
   fits_insert_img(fptr,bitpix,naxis,naxes,&status);
   return(status);
}

int fts_insert_(void **argu)
/* -4--------------------------------------------------------------------- */
{
   static int status;
   int hdutype,tfields;
   fitsfile *fptr;
   long nrows;
   char **ttype,**tform,**tunit;
   long *tbcol;
   char *extname;
   long pcount,rowlen;
   hdutype=*(int*)(argu[1]);
   fptr=(fitsfile*)(argu[2]);
   status=0;
   if (hdutype==ASCII_TBL) {
      rowlen=*(long*)(argu[3]);
      nrows=*(long*)(argu[4]);
      tfields=*(int*)(argu[5]);
      ttype=(char**)(argu[6]);
      tbcol=(long*)(argu[7]);
      tform=(char**)(argu[8]);
      tunit=(char**)(argu[9]);
      extname=(char*)(argu[10]);
      fits_insert_atbl(fptr,rowlen,nrows,tfields,ttype,tbcol,tform,tunit,extname,&status);
   } else if (hdutype==BINARY_TBL) {
      nrows=*(long*)(argu[3]);
      tfields=*(int*)(argu[4]);
      ttype=(char**)(argu[5]);
      tform=(char**)(argu[6]);
      tunit=(char**)(argu[7]);
      extname=(char*)(argu[8]);
      pcount=*(long*)(argu[9]);
      fits_insert_btbl(fptr,nrows,tfields,ttype,tform,tunit,extname,pcount,&status);
   } else {
      return(FS_ERR_TYPEHDU_NOT_KNOWN);
   }
   return(status);
}

int fts_resize_img(void *arg1,void *arg2,void *arg3,void *arg4)
/* -5--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int bitpix;
   int naxis;
   long *naxes;
   fptr=(fitsfile*)(arg1);
   bitpix=*(int*)(arg2);
   naxis=*(int*)(arg3);
   naxes=(long*)(arg4);
   status=0;
   fits_resize_img(fptr,bitpix,naxis,naxes,&status);
   return(status);
}

int fts_copy_header(void *arg1,void *arg2)
/* -6--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *infptr;
   fitsfile *outfptr;
   infptr=(fitsfile*)(arg1);
   outfptr=(fitsfile*)(arg2);
   status=0;
   fits_copy_header(infptr,outfptr,&status);
   return(status);
}

/***************************************************************************/
/****                    fonctions du groupe 6.3.2                         */
/***************************************************************************/

int fts_read_imghdr(void **argu)
/* -4--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int maxdim;
   int *simple,*bitpix,*naxis,*extend;
   long *naxes;
   long *pcount,*gcount;
   fptr=(fitsfile*)(argu[1]);
   maxdim=*(int*)(argu[2]);
   simple=(int*)(argu[3]);
   bitpix=(int*)(argu[4]);
   naxis=(int*)(argu[5]);
   naxes=(long*)(argu[6]);
   pcount=(long*)(argu[7]);
   gcount=(long*)(argu[8]);
   extend=(int*)(argu[9]);
   status=0;
   fits_read_imghdr(fptr,maxdim,simple,bitpix,naxis,naxes,pcount,gcount,extend,&status);
   return(status);
}

int fts_read_atblhdr(void **argu)
/* -5--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int maxdim;
   long *rowlen,*nrows,*tbcol;
   int *tfields;
   char **ttype,**tform,**tunit,*extname;
   fptr=(fitsfile*)(argu[1]);
   maxdim=*(int*)(argu[2]);
   rowlen=(long*)(argu[3]);
   nrows=(long*)(argu[4]);
   tfields=(int*)(argu[5]);
   ttype=(char**)(argu[6]);
   tbcol=(long*)(argu[7]);
   tform=(char**)(argu[8]);
   tunit=(char**)(argu[9]);
   extname=(char*)(argu[10]);
   status=0;
   fits_read_atblhdr(fptr,maxdim,rowlen,nrows,tfields,ttype,tbcol,tform,tunit,extname,&status);
   return(status);
}

int fts_read_btblhdr(void **argu)
/* -6--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int maxdim;
   long *nrows,*pcount;
   int *tfields;
   char **ttype,**tform,**tunit,*extname;
   fptr=(fitsfile*)(argu[1]);
   maxdim=*(int*)(argu[2]);
   nrows=(long*)(argu[3]);
   tfields=(int*)(argu[4]);
   ttype=(char**)(argu[5]);
   tform=(char**)(argu[6]);
   tunit=(char**)(argu[7]);
   extname=(char*)(argu[8]);
   pcount=(long*)(argu[9]);
   status=0;
   fits_read_btblhdr(fptr,maxdim,nrows,tfields,ttype,tform,tunit,extname,pcount,&status);
   return(status);
}

/***************************************************************************/
/****                    fonctions du groupe 6.3.5                         */
/***************************************************************************/

int fts_read_keyn(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5)
/* -1--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int keynum;
   char *motcle;
   char *valeur;
   char *comment;
   fptr=(fitsfile*)(arg1);
   keynum=*(int*)(arg2);
   motcle=(char*)(arg3);
   valeur=(char*)(arg4);
   comment=(char*)(arg5);
   status=0;
   fits_read_keyn(fptr,keynum,motcle,valeur,comment,&status);
   return(status);
}

int fts_find_nextkey(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6)
/* -2--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   char **inclist;
   int ninc;
   char **exclist;
   int nexc;
   char *card;
   fptr=(fitsfile*)(arg1);
   inclist=(char**)(arg2);
   ninc=*(int*)(arg3);
   exclist=(char**)(arg4);
   nexc=*(int*)(arg5);
   card=(char*)(arg6);
   status=0;
   fits_find_nextkey(fptr,inclist,ninc,exclist,nexc,card,&status);
   return(status);
}

int fts_read_keyword(void *arg1,void *arg2,void *arg3,void *arg4)
/* -3--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   char *motcle;
   char *valeur;
   char *comment;
   fptr=(fitsfile*)(arg1);
   motcle=(char*)(arg2);
   valeur=(char*)(arg3);
   comment=(char*)(arg4);
   status=0;
   fits_read_keyword(fptr,motcle,valeur,comment,&status);
   return(status);
}

int fts_read_key_(void *arg0,void *arg1,void *arg2,void *arg3,void *arg4)
/* -4--------------------------------------------------------------------- */
{
   static int status;
   int datatype;
   fitsfile *fptr;
   char *motcle;
   void *valeur;
   char *comment;
   datatype=*(int*)(arg0);
   fptr=(fitsfile*)(arg1);
   motcle=(char*)(arg2);
   valeur=arg3;
   comment=(char*)(arg4);
   status=0;
   /* on ne traite pas ici le cas _longstr _cmp _dblcmp */
   if (datatype==TSTRING) {fits_read_key_str(fptr,motcle,(char*)valeur,comment,&status);}
   if (datatype==TLOGICAL) {fits_read_key_log(fptr,motcle,(int*)valeur,comment,&status);}
   if (datatype==TLONG) {fits_read_key_lng(fptr,motcle,(long*)valeur,comment,&status);}
   if (datatype==TFLOAT) {fits_read_key_flt(fptr,motcle,(float*)valeur,comment,&status);}
   if (datatype==TDOUBLE) {fits_read_key_dbl(fptr,motcle,(double*)valeur,comment,&status);}
   return(status);
}

int fts_read_keys_(void *arg0,void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6)
/* -5--------------------------------------------------------------------- */
{
   static int status;
   int datatype;
   fitsfile *fptr;
   char *motcle;
   int nstart;
   int nkeys;
   char **valeurc;
   void *valeur;
   int *nfound;
   datatype=*(int*)(arg0);
   fptr=(fitsfile*)(arg1);
   motcle=(char*)(arg2);
   nstart=*(int*)(arg3);
   nkeys=*(int*)(arg4);
   nfound=(int*)(arg6);
   status=0;
   if (datatype==TSTRING) {valeurc=(char**)(arg5); fits_read_keys_str(fptr,motcle,nstart,nkeys,valeurc,nfound,&status);}
   if (datatype==TLOGICAL) {valeur=arg5; fits_read_keys_log(fptr,motcle,nstart,nkeys,valeur,nfound,&status);}
   if (datatype==TLONG) {valeur=arg5; fits_read_keys_lng(fptr,motcle,nstart,nkeys,valeur,nfound,&status);}
   if (datatype==TFLOAT) {valeur=arg5; fits_read_keys_flt(fptr,motcle,nstart,nkeys,valeur,nfound,&status);}
   if (datatype==TDOUBLE) {valeur=arg5; fits_read_keys_dbl(fptr,motcle,nstart,nkeys,valeur,nfound,&status);}
   /*printf("xttype[0]=%s\n",*(char**)(valeurc));*/
   return(status);
}

/***************************************************************************/
/****                      fonctions du groupe 6.5                         */
/***************************************************************************/

int fts_read_img_(void *arg0,void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7)
/* -9--------------------------------------------------------------------- */
{
   static int status;
   int datatype;
   fitsfile *fptr;
   long group;
   long firstelem;
   long nelements;
   void *nulval;
   void *p;
   int *anynul;
   datatype=*(int*)(arg0);
   fptr=(fitsfile*)(arg1);
   group=*(long*)(arg2);
   firstelem=*(long*)(arg3);
   nelements=*(long*)(arg4);
   nulval=arg5;
   p=arg6;
   anynul=(int*)(arg7);
   status=0;
   if (datatype==TBYTE) {fits_read_img_byt(fptr,group,firstelem,nelements,*(unsigned char*)nulval,p,anynul,&status);}
   if (datatype==TSHORT) {fits_read_img_sht(fptr,group,firstelem,nelements,*(short*)nulval,p,anynul,&status);}
   if (datatype==TUSHORT) {fits_read_img_usht(fptr,group,firstelem,nelements,*(unsigned short*)nulval,p,anynul,&status);}
   if (datatype==TLONG) {fits_read_img_lng(fptr,group,firstelem,nelements,*(int*)nulval,p,anynul,&status);}
   if (datatype==TULONG) {fits_read_img_ulng(fptr,group,firstelem,nelements,*(unsigned int*)nulval,p,anynul,&status);}
   if (datatype==TINT) {fits_read_img_int(fptr,group,firstelem,nelements,*(int*)nulval,p,anynul,&status);}
   if (datatype==TFLOAT) {fits_read_img_flt(fptr,group,firstelem,nelements,*(float*)nulval,p,anynul,&status);}
   if (datatype==TDOUBLE) {fits_read_img_dbl(fptr,group,firstelem,nelements,*(double*)nulval,p,anynul,&status);}
   return(status);
}


/***************************************************************************/
/****                      fonctions du groupe 6.6                         */
/***************************************************************************/

int fts_read_tdim(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5)
/* -4--------------------------------------------------------------------- */
{
   static int status;
   fitsfile *fptr;
   int colnum;
   int maxdim;
   int *naxis;
   long *naxes;
   fptr=(fitsfile*)(arg1);
   colnum=*(int*)(arg2);
   maxdim=*(int*)(arg3);
   naxis=(int*)(arg4);
   naxes=(long*)(arg5);
   status=0;
   fits_read_tdim(fptr,colnum,maxdim,naxis,naxes,&status);
   return(status);
}

/***************************************************************************/
/****                      fonctions du groupe 6.9                         */
/***************************************************************************/

int fts_get_keytype(void *arg1,void *arg2)
/* -11-------------------------------------------------------------------- */
{
   static int status;
   char *value;
   char *dtype;
   value=(char*)(arg1);
   dtype=(char*)(arg2);
   status=0;
   fits_get_keytype(value,dtype,&status);
   return(status);
}

