/* tt_fsio2.c
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

int tt_util_free_ptrptr(void **ptr,char *name)
/***************************************************************************/
{
   char message[TT_MAXLIGNE];
   sprintf(message,"%s.data",name);
   tt_free2(ptr,message); /* NULL ? */
   tt_free2((void*)&ptr,name);
   return(OK_DLL);
}

int tt_util_free_ptrptr2(void ***ptr,char *name)
/***************************************************************************/
{
   char message[TT_MAXLIGNE];
   sprintf(message,"%s.data",name);
   tt_free2(*ptr,message); /* NULL ? */
   tt_free2((void**)ptr,name);
   return(OK_DLL);
}

void tt_free2(void **ptr,char *name)
/***************************************************************************/
{
   /*printf("2.1 %p %p\n",ptr,*ptr);*/
   /*printf("deb  free %s\n",name);*/
   if (ptr!=NULL) {
      if (*ptr!=NULL) {
	 free(*ptr);
#ifdef TT_MOUCHARDPTR
   /* --- debug ---*/
   tt_util_mouchard(name,-1,(int)*ptr);
#endif
	 *ptr=NULL;
      } else {
	 /*tt_errlog(TT_WAR_FREE_NULLPTR,name);*/
      }
      /*tt_errlog(TT_WAR_FREE_NULLPTR,name);*/
   }
   /*printf("2.2 %p %p\n",ptr,*ptr);*/
   /*printf(" fin free %s\n",name);*/
   return;
}

void tt_free(void *ptr,char *name)
/***************************************************************************/
{
   if (ptr!=NULL) {
      free(ptr);
#ifdef TT_MOUCHARDPTR
   /* --- debug ---*/
   tt_util_mouchard(name,-1,(int)ptr);
#endif
      ptr=NULL;
   } else {
      /*tt_errlog(TT_WAR_FREE_NULLPTR,name);*/
   }
   return;
}

int tt_util_mouchard(char *nomptr,int increment,unsigned int address)
/***************************************************************************/
{
#ifdef TT_MOUCHARDPTR
   char ligne[51],texte[51];
   FILE *f=NULL;
   TT_MOUCHARD *mouchardptr;
   int nblig=0,k,existe=0;
   strcpy(texte,"");
   strcpy(ligne,"");
   /*
   if (increment==-1) {
      return(OK_DLL);
   }
   */
   if (nomptr==NULL) {
      return(OK_DLL);
   }
   if (strcmp(nomptr,"p")==0) {
	   increment+=0;
   }
   f=fopen("mouchard.txt","r");
   if (f==NULL) {
      f=fopen("mouchard.txt","w");
      fprintf(f,"1 \n");
      fprintf(f,"%d %s:%u %u\n",increment,nomptr,address,address);
      fclose(f);
   } else {
      nblig=0;
      /* --- on compte d'abord le nombre de lignes ---*/
      fgets(ligne,50,f);
      do {
         if (fgets(ligne,50,f)!=NULL) {
   	    strcpy(texte,"");
	    sscanf(ligne,"%s",texte);
	    if ( (strcmp(texte,"")!=0) ) {
               nblig++;
            }
	 }
      } while (feof(f)==0);
      fclose(f);
      /* --- on alloue la memoire du mouchard ---*/
      mouchardptr=(TT_MOUCHARD*)calloc(nblig+1,sizeof(TT_MOUCHARD));
      /* --- lit les elements du mouchard ---*/
      f=fopen("mouchard.txt","r");
      k=0;
      fgets(ligne,50,f);
      do {
         if (fgets(ligne,50,f)!=NULL) {
   	    strcpy(texte,"");
	    sscanf(ligne,"%s",texte);
	    if ( (strcmp(texte,"")!=0) ) {
	       sscanf(ligne,"%d %s %u",&((mouchardptr+k)->nballoc),(mouchardptr+k)->varname,&(mouchardptr+k)->address);
               k++;
            }
	 }
      } while (feof(f)==0);
      fclose(f);
      /* --- on recherche si le nom existe ---*/
      existe=0;
      sprintf(ligne,"%s:%u",nomptr,address);
      for (k=0;k<nblig;k++) {
         if (strcmp((mouchardptr+k)->varname,ligne)==0) {
            ((mouchardptr+k)->nballoc)+=increment;
            existe=1;
            break;
         }
      }
      /* --- on ajoute le nom a la liste s'il n'existe pas ---*/
      if (existe==0) {
         sprintf((mouchardptr+nblig)->varname,"%s:%u",nomptr,address);
         ((mouchardptr+nblig)->nballoc)=increment;
         ((mouchardptr+nblig)->address)=address;
         nblig++;
      }
      /* --- on ecrit le fichier de sortie ---*/
      f=fopen("mouchard.txt","w");
      fprintf(f,"%d \n",nblig);
      for (k=0;k<nblig;k++) {
         fprintf(f,"%d %s %u\n",(mouchardptr+k)->nballoc,(mouchardptr+k)->varname,(mouchardptr+k)->address);
      }
      fclose(f);
      free(mouchardptr);
   }
#endif
   return(OK_DLL);
}

void *tt_calloc(int nombre,int taille)
/***************************************************************************/
{
   static void *ptr;
   if (taille<=0) {
      tt_errlog("",TT_ERR_ALLOC_SIZE_ZERO,NULL);
      return(NULL);
   }
   if (nombre<=0) {
      tt_errlog("",TT_ERR_ALLOC_NUMBER_ZERO,NULL);
      return(NULL);
   }
   ptr=NULL;
   ptr=(void*)calloc(nombre,taille);
   return(ptr);
}

void *tt_malloc(int taille)
/***************************************************************************/
{
   void *ptr;
   ptr=NULL;
   if (taille<=0) { return(NULL); }
   ptr=(void*)malloc(taille);
   return(ptr);
}

int tt_util_calloc_ptr2(void **args)
/**************************************************************************/
/* Fonction pour allouer de la memoire a un pointeur.                     */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : *pointeur (char*) pointeur a initialiser                        */
/* arg2 : *nombre (int*)                                                  */
/* arg2 : *taille (int*)                                                  */
/* ------ entrees optionnelles                                            */
/* arg4 : (char*) nom du pointeur                                         */
/**************************************************************************/
/**************************************************************************/
{
   void **argu;
   void *p,**pp;
   int nombre;
   int taille;
   char message[TT_MAXLIGNE];

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   /*printf("deb  allocation %s\n",(char*)argu[4]);*/
   if (argu[1]==NULL) { return(PB_DLL); }
   pp=(void**)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   nombre=*(int*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   taille=*(int*)(argu[3]);
   /* --- cas du pointeur non nul et parametres optionnels ---*/
   if (*(char**)pp!=NULL) {
      if (argu[4]!=NULL) {
	 sprintf(message,"[tt_util_calloc_ptr2] Problem with the not NULL pointer %s",(char*)argu[4]);
      } else {
	 sprintf(message,"[tt_util_calloc_ptr2] Problem with a not NULL pointer");
      }
      tt_errlog("",TT_WAR_ALLOC_NOTNULLPTR,message);
      return(TT_WAR_ALLOC_NOTNULLPTR);
   }
   /* --- cas du pointeur nul et allocation ---*/
   p=NULL;
   if((p=tt_calloc(nombre,taille))==NULL) {
      return(TT_ERR_PB_MALLOC);
   }
   *pp=(void*)p;
   /*printf(" fin allocation %s\n",(char*)argu[4]);*/
#ifdef TT_MOUCHARDPTR
   /* --- debug ---*/
   tt_util_mouchard((char*)argu[4],1,(int)p);
#endif

   return(OK_DLL);
}

int tt_util_calloc_ptrptr_char2(void **args)
/**************************************************************************/
/* Fonction pour allouer de la memoire a une liste de chaine.             */
/**************************************************************************/
/* ------ entrees                                                         */
/* arg1 : **pointeur (char**) pointeur a initialiser                      */
/* arg2 : *maxdim (int*) nombre de chaines dans la liste                  */
/* arg3 : *len (int*) longueur de chaque chaine                           */
/* ------ entrees optionnelles                                            */
/* arg4 : (char*) nom du pointeur                                         */
/**************************************************************************/
/**************************************************************************/
{
   void **argu;
   char **p;
   char *p_data;
   char **pp;
   int maxdim,len,nbcar,taille,k;
   char message[TT_MAXLIGNE];

   /* --- verification des arguments ---*/
   argu=(void**)(args);
   if (argu[1]==NULL) { return(PB_DLL); }
   pp=(char**)(argu[1]);
   if (argu[2]==NULL) { return(PB_DLL); }
   maxdim=*(int*)(argu[2]);
   if (argu[3]==NULL) { return(PB_DLL); }
   len=*(int*)(argu[3]);

   /* --- cas du pointeur non nul et parametres optionnels ---*/
   if (*pp!=NULL) {
      if (argu[4]!=NULL) {
	 sprintf(message,"[tt_util_calloc_ptrptr_char2] Problem with the not NULL pointer %s",(char*)argu[4]);
      } else {
	 sprintf(message,"Problem with a not NULL pointer");
      }
      tt_errlog("",TT_WAR_ALLOC_NOTNULLPTR,message);
      return(TT_WAR_ALLOC_NOTNULLPTR);
   }
   /* --- cas du pointeur nul et allocation ---*/
   p=NULL;
   p_data=NULL;
   if((p=(char**)tt_calloc(maxdim,sizeof(void*)))==NULL) {
      return(TT_ERR_PB_MALLOC);
   }
   nbcar=(len)*sizeof(char);
   taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
   if((p_data=(char*)tt_calloc(maxdim,taille))==NULL) {
      tt_free(&p,NULL);
      return(FS_ERR_PB_MALLOC);
   }
   for (k=0;k<=maxdim-1;k++) {
      p[k]=p_data+k*taille;
   }
   *pp=(void*)p;
#ifdef TT_MOUCHARDPTR
   /* --- debug ---*/
   tt_util_mouchard((char*)argu[4],1,(int)p);
   sprintf(message,"%s.data",(char*)argu[4]);
   tt_util_mouchard(message,1,(int)p_data);
#endif
   return(OK_DLL);
}

int tt_util_calloc_ptrptr_char(void **arg1,void *arg2,void *arg3)
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
   p=NULL;
   p_data=NULL;
   if (exist_p==1) {
      if((p=(char**)tt_calloc(maxdim,sizeof(void*)))==NULL) {
	 return(TT_ERR_PB_MALLOC);
      }
      nbcar=(len)*sizeof(char);
      taille=(nbcar+sizeof(void*)-nbcar%sizeof(void*))*sizeof(char);
      if((p_data=(char*)tt_calloc(maxdim,taille))==NULL) {
	 tt_free(&p,NULL);
	 return(FS_ERR_PB_MALLOC);
      }
      for (k=0;k<=maxdim-1;k++) {
	 p[k]=p_data+k*taille;
      }
      *pp=(void*)p;
   } else {
      tt_errlog("",TT_WAR_ALLOC_NOTNULLPTR,"Problem in tt_util_calloc_ptrptr_char");
      return(TT_WAR_ALLOC_NOTNULLPTR);
   }
   return(OK_DLL);
}

int tt_util_calloc_ptr_datatype(void **arg1,void *arg2,void *arg3)
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
   if (datatype==TBYTE) { if ((puchar=(unsigned char*)tt_calloc(*nbelements,sizeof(unsigned char)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=puchar;} }
   else if (datatype==TSHORT) { if ((pshort=(short*)tt_calloc(*nbelements,sizeof(short)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=(void*)(pshort);} }
   else if (datatype==TINT) { if ((pint=(int*)tt_calloc(*nbelements,sizeof(int)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pint;} }
   else if (datatype==TLONG) { if ((plong=(long*)tt_calloc(*nbelements,sizeof(long)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=plong;} }
   else if (datatype==TFLOAT) { if ((pfloat=(float*)tt_calloc(*nbelements,sizeof(float)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pfloat;} }
   else if (datatype==TDOUBLE) { if ((pdouble=(double*)tt_calloc(*nbelements,sizeof(double)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pdouble;} }
   else if (datatype==TUSHORT) { if ((pushort=(unsigned short*)tt_calloc(*nbelements,sizeof(unsigned short)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=pushort;} }
   else if (datatype==TULONG) { if ((puint=(unsigned int*)tt_calloc(*nbelements,sizeof(unsigned int)))==NULL) {return(FS_ERR_PB_MALLOC);} else {*arg1=puint;} }
   else { return(FS_ERR_BAD_DATATYPE); }
   return(OK_DLL);
}

int tt_util_ttima2ptr(TT_IMA *p_in,void *array,int datatype,int iaxis3)
/***************************************************************************/
/* Copie une image ou une partie d'image TT_IMA vers un pointeur.          */
/***************************************************************************/
/* iaxis3 dans le cas de NAXIS=3.                                          */
/***************************************************************************/
{
   int k,off;
	long nelements; 
   nelements=p_in->naxis1*p_in->naxis2;
   off=0;
   if (p_in->naxis3>1) {
      if (iaxis3>p_in->naxis3) {
         iaxis3=p_in->naxis3;
      }
      if (iaxis3<0) {
         iaxis3=0;
      }
      off=nelements*(iaxis3-1);
   }
   if (nelements==0) { return(PB_DLL); }
   if (datatype==TBYTE) {for (k=0;k<nelements;k++) { *((unsigned char*)(array)+k)=(unsigned char)(p_in->p[k+off]); } }
   else if (datatype==TSHORT) {for (k=0;k<nelements;k++) { *((short*)(array)+k)=(short)(p_in->p[k+off]); } }
   else if (datatype==TINT) {for (k=0;k<nelements;k++) { *((int*)(array)+k)=(int)(p_in->p[k+off]); } }
   else if (datatype==TLONG) {for (k=0;k<nelements;k++) { *((long*)(array)+k)=(long)(p_in->p[k+off]); } }
   else if (datatype==TFLOAT) {for (k=0;k<nelements;k++) { *((float*)(array)+k)=(float)(p_in->p[k+off]); } }
   else if (datatype==TDOUBLE) {for (k=0;k<nelements;k++) { *((double*)(array)+k)=(double)(p_in->p[k+off]); } }
   else if (datatype==TUSHORT) {for (k=0;k<nelements;k++) { *((unsigned short*)(array)+k)=(unsigned short)(p_in->p[k+off]); } }
   else if (datatype==TULONG) {for (k=0;k<nelements;k++) { *((unsigned int*)(array)+k)=(unsigned int)(p_in->p[k+off]); } }
   else { return(FS_ERR_BAD_DATATYPE); }
   return(OK_DLL);
}

int tt_util_ptr2ttima(void *array,int datatype,TT_IMA *p_out)
/***************************************************************************/
/* Copie un pointeur vers une image TT_IMA.                                */
/***************************************************************************/
/* il faut d'abord construire le p_out.                                    */
/***************************************************************************/
{
   int nelements,k;
   nelements=p_out->naxis1*p_out->naxis2*p_out->naxis3;
   if (nelements==0) { return(PB_DLL); }
   if (datatype==TBYTE) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((unsigned char*)(array))+k)); } }
   else if (datatype==TSHORT) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((short*)(array))+k)); } }
   else if (datatype==TINT) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((int*)(array))+k)); } }
   else if (datatype==TLONG) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((long*)(array))+k)); } }
   else if (datatype==TFLOAT) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((float*)(array))+k)); } }
   else if (datatype==TDOUBLE) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((double*)(array))+k)); } }
   else if (datatype==TUSHORT) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((unsigned short*)(array))+k)); } }
   else if (datatype==TULONG) {for (k=0;k<nelements;k++) { p_out->p[k]=(TT_PTYPE)(*(((unsigned int*)(array))+k)); } }
   else { return(FS_ERR_BAD_DATATYPE); }
   return(OK_DLL);
}

int tt_util_datatype_bytes(void *arg1, void *arg2)
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

int tt_util_put_datatype(void *arg1,void *arg2,void *arg3)
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

int tt_util_bitpix2datatype(void *arg1,void *arg2)
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



int tt_util_free_ptr(void *arg1)
{
   free(arg1);
   arg1=NULL;
   return(OK_DLL);
}

