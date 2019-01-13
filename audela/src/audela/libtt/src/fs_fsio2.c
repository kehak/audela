/* fs_fsio2.c
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


int fs_util_free_ptrptr(void **ptr,char *name)
/***************************************************************************/
{
   fs_free(*ptr,name);
   fs_free(ptr,name);
   return(OK_DLL);
}

void fs_free(void *ptr,char *name)
/***************************************************************************/
{
   if (ptr!=NULL) {
      free(ptr);
      ptr=NULL;
   } else {
      /*tt_errlog(TT_ERR_FREE_NULLPTR,name);*/
   }
   return;
}

void *fs_calloc(int nombre,int taille)
/***************************************************************************/
{
   void *ptr;
   if (taille<=0) { return(NULL); }
   if (nombre<=0) { return(NULL); }
   ptr=NULL;
   ptr=(void*)calloc(nombre,taille);
   return(ptr);
}

void *fs_malloc(int taille)
/***************************************************************************/
{
   void *ptr;
   ptr=NULL;
   if (taille<=0) { return(NULL); }
   ptr=(void*)malloc(taille);
   return(ptr);
}

int util_get_datainfo(void *arg1,void *arg2,void *arg3)
/***************************************************************************/
/* arg1 : pointeur sur la structure de datainfo                            */
/* arg2 : nom du champ a lire (voir la structure de datainfo_struct)       */
/* arg3 : valeur du champ a lire -> format char*                           */
/***************************************************************************/
{
   static int status;
   datainfo_struct *datainfo;
   char *champ;
   char *chaine;
   datainfo=(datainfo_struct*)(arg1);
   champ=(char*)(arg2);
   chaine=(char*)(arg3);
   status=0;
   strcpy(chaine,"");
   if (strcmp(champ,"indice")==0)          { sprintf(chaine,"%d",datainfo->indice); }
   else if (strcmp(champ,"hdunum")==0)     { sprintf(chaine,"%d",datainfo->hdunum); }
   else if (strcmp(champ,"type")==0)       { sprintf(chaine,"%d",datainfo->type); }
   else if (strcmp(champ,"date_obs")==0)   { sprintf(chaine,"%s" ,datainfo->date_obs); }
   else if (strcmp(champ,"exptime")==0)    { sprintf(chaine,"%f",(double)datainfo->exptime); }
   else if (strcmp(champ,"typematrix")==0) { sprintf(chaine,"%d",datainfo->typematrix); }
   else if (strcmp(champ,"datatype")==0)   { sprintf(chaine,"%d",datainfo->datatype); }
   else if (strcmp(champ,"bitpix")==0)     { sprintf(chaine,"%d",datainfo->bitpix); }
   else if (strcmp(champ,"naxis1")==0)     { sprintf(chaine,"%d",datainfo->naxis1); }
   else if (strcmp(champ,"naxis2")==0)     { sprintf(chaine,"%d",datainfo->naxis2); }
   else {return(FS_ERR_MEMBER_NOT_FOUND);}
   return(status);
}

int util_put_datainfo(void *arg1,void *arg2,void *arg3)
/***************************************************************************/
/* arg1 : pointeur sur la structure de image2d                             */
/* arg2 : nom du champ a remplir                                           */
/* arg3 : valeur du champ a remplir                                        */
/***************************************************************************/
{
   static int status;
   datainfo_struct *datainfo;
   char *champ;
   datainfo=(datainfo_struct*)(arg1);
   champ=(char*)(arg2);
   status=0;
   if (strcmp(champ,"indice")==0)          { datainfo->indice=*(int*)(arg3); }
   else if (strcmp(champ,"hdunum")==0)     { datainfo->hdunum=*(int*)(arg3); }
   else if (strcmp(champ,"type")==0)       { datainfo->type=*(int*)(arg3); }
   else if (strcmp(champ,"date_obs")==0)   { strcpy(datainfo->date_obs,(char*)(arg3)); }
   else if (strcmp(champ,"exptime")==0)    { datainfo->exptime=*(double*)(arg3); }
   else if (strcmp(champ,"typematrix")==0) { datainfo->typematrix=*(int*)(arg3); }
   else if (strcmp(champ,"datatype")==0)   { datainfo->datatype=*(int*)(arg3); }
   else if (strcmp(champ,"bitpix")==0)     { datainfo->bitpix=*(int*)(arg3); }
   else if (strcmp(champ,"naxis1")==0)     { datainfo->naxis1=*(int*)(arg3); }
   else if (strcmp(champ,"naxis2")==0)     { datainfo->naxis2=*(int*)(arg3); }
   else {return(FS_ERR_MEMBER_NOT_FOUND);}
   return(status);
}

int util_get_arrays2d(void *arg1,void *arg2,void *arg3,void *arg4)
/***************************************************************************/
/* arg1 : pointeur sur la structure de image2d                             */
/* arg2 : numero d'indice de la ligne a lire                               */
/* arg3 : nom du champ a lire (voir la structure de arrays2d_struct)       */
/* arg4 : valeur du champ a lire -> format char*                           */
/***************************************************************************/
{
   static int status;
   arrays2d_struct *image2d;
   char *chaine;
   int indice;
   char *champ;
   image2d=(arrays2d_struct*)(arg1);
   indice=*(int*)(arg2);
   champ=(char*)(arg3);
   chaine=(char*)(arg4);
   status=0;
   strcpy(chaine,"");
   if (strcmp(champ,"indice")==0)      { sprintf(chaine,"%d",image2d[indice].indice); }
   else if (strcmp(champ,"hdunum")==0) { sprintf(chaine,"%d",image2d[indice].hdunum); }
   else if (strcmp(champ,"type")==0)   { sprintf(chaine,"%d",image2d[indice].type); }
   else if (strcmp(champ,"bitpix")==0) { sprintf(chaine,"%d",image2d[indice].bitpix); }
   else if (strcmp(champ,"x")==0)      { sprintf(chaine,"%d",image2d[indice].x); }
   else if (strcmp(champ,"y")==0)      { sprintf(chaine,"%d",image2d[indice].y); }
   else {return(FS_ERR_MEMBER_NOT_FOUND);}
   return(status);
}

int util_put_arrays2d(void *arg1,void *arg2,void *arg3,void *arg4)
/***************************************************************************/
/* arg1 : pointeur sur la structure de image2d                             */
/* arg2 : numero d'indice de la ligne a remplir                            */
/* arg3 : nom du champ a remplir                                           */
/* arg4 : valeur du champ a remplir                                        */
/***************************************************************************/
{
   static int status;
   arrays2d_struct *image2d;
   int indice;
   char *champ;
   image2d=(arrays2d_struct*)(arg1);
   indice=*(int*)(arg2);
   champ=(char*)(arg3);
   status=0;
   if (strcmp(champ,"indice")==0)      { (image2d+indice)->indice=*(int*)(arg4); }
   else if (strcmp(champ,"hdunum")==0) { (image2d+indice)->hdunum=*(int*)(arg4); }
   else if (strcmp(champ,"type")==0)   { (image2d+indice)->type=*(int*)(arg4); }
   else if (strcmp(champ,"bitpix")==0) { (image2d+indice)->bitpix=*(int*)(arg4); }
   else if (strcmp(champ,"x")==0)      { (image2d+indice)->x=*(int*)(arg4); }
   else if (strcmp(champ,"y")==0)      { (image2d+indice)->y=*(int*)(arg4); }
   else {return(FS_ERR_MEMBER_NOT_FOUND);}
   return(status);
}

int util_calloc_ptr_image2d(void **arg1,void *arg2)
{
   int *nbimages;
   nbimages=(int*)(arg2);
   if ((*arg1=(arrays2d_struct*)calloc( ((*nbimages)+1),sizeof(arrays2d_struct) ))==NULL) {
      return(FS_ERR_PB_MALLOC);
   }
   return(OK_DLL);
}

int util_calloc_ptrptr_char(void **arg1,void *arg2,void *arg3)
/***************************************************************************/
/* Initialise le pointeur char **p (arg1) pour pointer sur 'maxdim' (arg2) */
/* chaines de longueur 'len' caracteres (arg3)                             */
/***************************************************************************/
{
   char **p;
   char *p_data;
   char **pp;
   int maxdim,len,nbcar,taille,k,exist_p;

   pp=(char**)(arg1);
   maxdim=*(int*)(arg2);
   len=*(int*)(arg3);
   exist_p=(pp==NULL)?0:1;
   if (exist_p==1) {
      if((p=(char**)calloc(maxdim,sizeof(void*)))==NULL) {
	 return(FS_ERR_PB_MALLOC);
      }
      nbcar=(len)*sizeof(char);
      taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
      p_data=NULL;
      if((p_data=(char*)calloc(maxdim,taille))==NULL) {
	 free(p);
	 return(FS_ERR_PB_MALLOC);
      }
      for (k=0;k<=maxdim-1;k++) {
	 p[k]=p_data+k*taille;
      }
      *pp=(void*)p;
   }
   return(OK_DLL);
}

int util_calloc_ptr_datatype(void **arg1,void *arg2,void *arg3)
/***************************************************************************/
/* dimensionne un pointeur de valeurs de pixels image                      */
/***************************************************************************/
/* void **arg1 : adresse du pointeur a dimensionner                        */
/* void *arg2  : nombre de pixels                                          */
/* void *arg3  : valeur de datatype (Fitsio)                               */
/***************************************************************************/
{
   int *nbelements;
   int datatype;
   static unsigned char* puchar;
   static short *pshort;
   static int *pint;
   static long *plong;
   static float *pfloat;
   static double *pdouble;
   static unsigned short *pushort;
   static unsigned int *puint;
   nbelements=(int*)(arg2);
   datatype=*(int*)(arg3);
   if (datatype==TBYTE) { if ((puchar=(unsigned char*)calloc(*nbelements,sizeof(unsigned char)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=puchar;} }
   else if (datatype==TSHORT) { if ((pshort=(short*)calloc(*nbelements,sizeof(short)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=(void*)(pshort);} }
   else if (datatype==TINT) { if ((pint=(int*)calloc(*nbelements,sizeof(int)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pint;} }
   else if (datatype==TLONG) { if ((plong=(long*)calloc(*nbelements,sizeof(long)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=plong;} }
   else if (datatype==TFLOAT) { if ((pfloat=(float*)calloc(*nbelements,sizeof(float)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pfloat;} }
   else if (datatype==TDOUBLE) { if ((pdouble=(double*)calloc(*nbelements,sizeof(double)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pdouble;} }
   else if (datatype==TUSHORT) { if ((pushort=(unsigned short*)calloc(*nbelements,sizeof(unsigned short)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pushort;} }
   else if (datatype==TULONG) { if ((puint=(unsigned int*)calloc(*nbelements,sizeof(unsigned int)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=puint;} }
   else { return(FS_ERR_BAD_DATATYPE); }
   return(OK_DLL);
}

int util_datatype_bytes(void *arg1, void *arg2)
/***************************************************************************/
/* Calcule le nombre d'octets occupes par un datatype                      */
/***************************************************************************/
/***************************************************************************/
{
   int datatype,*nboctets,nbcar;
   datatype=*(int*)(arg1);
   nboctets=(int*)(arg2);
   if      (datatype==TSHORT) { nbcar=sizeof(short); }
   else if (datatype==TUSHORT) { nbcar=sizeof(unsigned short); }
   else if (datatype==TINT) { nbcar=sizeof(int); }
   else if (datatype==TLONG) { nbcar=sizeof(long); }
   else if (datatype==TULONG) { nbcar=sizeof(unsigned long); }
   else if (datatype==TFLOAT) { nbcar=sizeof(float); }
   else if (datatype==TDOUBLE) { nbcar=sizeof(double); }
   else if (datatype==TLOGICAL) { nbcar=sizeof(int); }
   else if (datatype==TBYTE) { nbcar=sizeof(unsigned char); }
   else if (datatype>TSTRINGS) { nbcar=(datatype-TSTRINGS)*sizeof(char); datatype=TSTRING; }
   else { return(FS_ERR_BAD_DATATYPE); }
   if (datatype==TSTRING) {
      *nboctets=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
   } else {
      *nboctets=nbcar;
   }
   return(OK_DLL);
}

int util_put_datatype(void *arg1,void *arg2,void *arg3)
/***************************************************************************/
/* Ecrit la valeur *arg3 (en double) a l'adresse arg2 en faisant une       */
/* conversion en fonction de *arg1 (datatype)                              */
/***************************************************************************/
/* void *arg1 : adresse la valeur de datatype (int)                        */
/* void *arg2 : adresse de la valeur transtypee                            */
/* void *arg3 : adresse de la valeur a transtyper                          */
/***************************************************************************/
{
   int datatype;
   unsigned char *out1;
   short *out2;
   int *out3;
   float *out4;
   double *out5;
   unsigned int *out6;
   unsigned short *out7;
   datatype=*(int*)(arg1);
   if      (datatype==TBYTE) {out1=(unsigned char*)(arg2); *out1=*(unsigned char *)(arg3); }
   else if (datatype==TSHORT) {out2=(short*)(arg2); *out2=*(short *)(arg3); }
   else if (datatype==TLONG) {out3=(int*)(arg2); *out3=*(int *)(arg3); }
   else if (datatype==TFLOAT) {out4=(float*)(arg2); *out4=*(float *)(arg3); }
   else if (datatype==TDOUBLE) {out5=(double*)(arg2); *out5=*(double *)(arg3); }
   else if (datatype==TULONG) {out6=(unsigned int*)(arg2); *out6=*(unsigned int *)(arg3); }
   else if (datatype==TUSHORT) {out7=(unsigned short*)(arg2); *out7=*(unsigned short *)(arg3); }
   else { return(FS_ERR_BAD_DATATYPE); }
   return(OK_DLL);
}

int util_bitpix2datatype(void *arg1,void *arg2)
/***************************************************************************/
/* Calcule la valeur de datatype (de Fitsio) a partir de la valeur de      */
/* bitpix (Fitsio).                                                        */
/***************************************************************************/
/* void *arg1 : adresse la valeur de bitpix (int)                          */
/* void *arg2 : adresse la valeur de datatype (int)                        */
/***************************************************************************/
{
   int *bitpix;
   int *datatype;
   bitpix=(int*)(arg1);
   datatype=(int*)(arg2);
   if      (*bitpix==BYTE_IMG)   {*datatype=TBYTE;}
   else if (*bitpix==SHORT_IMG)  {*datatype=TSHORT;}
   else if (*bitpix==LONG_IMG)   {*datatype=TLONG;}
   else if (*bitpix==FLOAT_IMG)  {*datatype=TFLOAT;}
   else if (*bitpix==DOUBLE_IMG) {*datatype=TDOUBLE;}
   else if (*bitpix==USHORT_IMG) {*datatype=TUSHORT;}
   else if (*bitpix==ULONG_IMG)  {*datatype=TULONG;}
   else { return(FS_ERR_BAD_BITPIX); }
   return(OK_DLL);
}



int util_free_ptr(void *arg1)
{
   free(arg1);
   arg1=NULL;
   return(OK_DLL);
}


int util_match_reserved_key(void *arg1, void *arg2)
/***************************************************************************/
/* retourne match=1 si le keyword est trouve dans la liste.                */
/***************************************************************************/
/* arg1 : mot cle                                                          */
/* arg2 : match                                                            */
/***************************************************************************/
{
   char **liste;
   char *liste_data;
   int nbdata;
   int len_data;
   int nbcar,k,taille;
   int pos;
   char *car;
   char mot1[FLEN_KEYWORD],mot2[FLEN_KEYWORD],*mot3;
   char *keyword;
   int *match;
   int numeric,kk;

   keyword=(char*)(arg1);
   match=(int*)(arg2);
   *match=0;
   nbdata=26;
   len_data=FLEN_KEYWORD;
   liste=NULL;
   if ((liste=(char**)calloc(nbdata,sizeof(void*)))==NULL) {
      return(FS_ERR_PB_MALLOC);
   }
   nbcar=(len_data)*sizeof(char);
   taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
   liste_data=NULL;
   if ((liste_data=(char*)calloc(nbdata,taille))==NULL) {
      free(liste);
      return(FS_ERR_PB_MALLOC);
   }
   for (k=0;k<=nbdata-1;k++) {
      liste[k]=liste_data+k*taille;
   }
   sprintf(liste[ 0],"SIMPLE");
   sprintf(liste[ 1],"BITPIX");
   sprintf(liste[ 2],"NAXIS");
   sprintf(liste[ 3],"NAXIS*");
   sprintf(liste[ 4],"TFORM*");
   sprintf(liste[ 5],"TTYPE*");
   sprintf(liste[ 6],"TUNIT*");
   sprintf(liste[ 7],"TBCOL*");
   sprintf(liste[ 8],"EXTNAME");
   sprintf(liste[ 9],"EXTEND");
   sprintf(liste[10],"TFORM*");
   sprintf(liste[11],"TNULL*");
   sprintf(liste[12],"TDISP*");
   sprintf(liste[13],"GCOUNT");
   sprintf(liste[14],"PCOUNT");
   sprintf(liste[15],"TFIELDS");
   sprintf(liste[16],"XTENSION");
   sprintf(liste[17],"EXTVER");
   sprintf(liste[18],"EXTLEVEL");
   sprintf(liste[19],"TSCAL*");
   sprintf(liste[20],"TZERO*");
   sprintf(liste[21],"THEAP");
   sprintf(liste[22],"TDIM*");
   sprintf(liste[23],"BSCALE");
   sprintf(liste[24],"BZERO");
   sprintf(liste[25],"END");
   for (k=0;k<nbdata;k++) {
      /* rechercher * dans le mot de la liste */
      strcpy(mot1,liste[k]);
      car=strstr(mot1,"*");
      numeric=0;
      pos=0;
      if (car!=NULL) {
	 pos=(int)(car-mot1);
	 mot1[pos]='\0';
	 numeric=1;
      }
      strcpy(mot2,keyword);
      /*printf("on va comparer le mot cle %s a %s (%d pos=%d)\n",mot2,mot1,numeric,pos);*/
      car=strstr(mot2,mot1);
      if (car!=NULL) {
	 pos=(int)(car-mot2);
	 if (pos==0) {
	   /*printf("mot cle detecte en premiere position\n");*/
	    if ((numeric==0)&&((int)(strlen(keyword))==(int)(strlen(mot1)))) {
		  /*printf("mode numeric non detecte\n");*/
	       *match=1;
	       free(liste);
	       free(liste_data);
	       return(OK_DLL);
	    } else if (numeric==1) {
		  /*printf("mode numeric detecte\n");*/
	       mot3=keyword+(int)(strlen(mot1));
	       /*printf("on va comparer le suffixe %s du mot cle a des nombres\n",mot3);*/
	       for (kk=0;kk<=(int)(strlen(mot3));kk++) {
		  *match=1;
		  if ((mot3[kk]<'0')||(mot3[kk]>'9')) {
		     *match=0;
		  }
		  if (*match==1) {
		     free(liste);
		     free(liste_data);
		     return(OK_DLL);
		  }
	       }
	    }
	 } /* fin de pos==0 */
      }
   }

   *match=0;
   free(liste);
   free(liste_data);
   return(OK_DLL);
}
