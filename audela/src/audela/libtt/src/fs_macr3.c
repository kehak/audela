/* fs_macr3.c
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

#define BITS    12
#define HSIZE  5003

int n_bits;
int maxbitss;
int maxcode;
int maxmaxcode;

#define MAXCODE(n_bits) (((int) 1 << (n_bits)) - 1)

long htab[HSIZE];

unsigned short codetab[HSIZE];
#define HashTabOf(i)  htab[i]
#define CodeTabOf(i)  codetab[i]

int free_ent;

int clear_flg;

int g_init_bits;
FILE *g_outfile;

int ClearCode;
int EOFCode;

unsigned long cur_accum;
int cur_bits;
int Width, Height;
int curx, cury;
long CountDown;
int Pass;
int Interlace;

int a_count;
char accum[256];

int Red[256];
int Green[256];
int Blue[256];

unsigned long masks[] = { 0x0000, 0x0001, 0x0003, 0x0007, 0x000F,
			  0x001F, 0x003F, 0x007F, 0x00FF,
			  0x01FF, 0x03FF, 0x07FF, 0x0FFF,
			  0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF };

int macr_fits2gif(void *arg1,void *arg2,void *arg3,void *arg4,void *arg5,void *arg6,void *arg7)
/***************************************************************************/
/* Lit une image Fits et sauve l'image en GIF                              */
/***************************************************************************/
/* arg1 : nom (dossier+nom+ext) du fichier Fits en entree                  */
/* arg2 : nom (dossier+nom+ext) du fichier Gif en sortie                   */
/* arg3 : =0 si l'on veut lire les arguments de mots cles dans l'entete.   */
/*        =1 si l'on passe des seuils numeriques                           */
/* arg4 : seuil bas (numerique ou mot cle)                                 */
/* arg5 : seuil haut (numerique ou mot cle)                                */
/* arg6 : valeur retournee du nombre de points sur x                       */
/* arg7 : valeur retournee du nombre de points sur y                       */
/***************************************************************************/
/* Exemple d'appel a ce concertisseur :                                    */
/* int msg=0;                                                              */
/* int choix,x,y;                                                          */
/* double sb,sh;                                                           */
/* choix=1;                                                                */
/* sb=2000;                                                                */
/* sh=2300;                                                                */
/* msg=libfiles_main(FS_MACR_FITS2GIF,"i.fit","i.gif",&choix,&sb,&sh,&x,&y);*/
/***************************************************************************/
{
   FILE *out;
   int i,j;
   int imax,jmax;
   int interlace;
   int BitsPerPixel;
   short *buf;

   int naxis,datatype,msg;
   long *naxes;
   float *p;
   char *nom_fichier_fits,*nom_fichier_gif,*keyname,charvalue[FLEN_VALUE];
   int bitpix,typehdu,numhdu;
	long firstelem,nelements;
   int type_seuil,nbkeys,k,kk;
   double seuil_bas,seuil_haut,delta_seuil;

   /* --- chargement de l'image ---*/
   nom_fichier_fits=(char*)(arg1);
   datatype=TFLOAT;
   typehdu=IMAGE_HDU;
   numhdu=1;
   firstelem=1;
   nelements=0;
   if ((msg=libfiles_main(FS_MACR_READ,10,nom_fichier_fits,&numhdu,&typehdu,&firstelem,&nelements,&naxis,&naxes,&bitpix,&datatype,&p))!=0) {
      return(msg);
   }
   if (naxis>=2) {
      imax=naxes[naxis-2];
      jmax=naxes[naxis-1];
      *(int*)(arg6)=imax;
      *(int*)(arg7)=jmax;
      nelements=imax*jmax;
   } else {
      free(p);
      free(naxes);
      return(PB_DLL);
   }
   free(naxes);

   /* --- chargement des seuils ---*/
   type_seuil=*(int*)(arg3);
   if (type_seuil==1) {
      seuil_bas=*(double*)(arg4);
      seuil_haut=*(double*)(arg5);
   } else {
      nbkeys=1;
      keyname=(char*)(arg4);
      /*found=1;*/
      if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,nom_fichier_fits,&numhdu,&nbkeys,keyname,NULL,NULL,NULL,charvalue))!=0) {
	 if (msg==202) {
	    /*found=0;*/
	    seuil_bas=0;
	 } else {
	    free(p);
	    return(msg);
	 }
      } else {
	 seuil_bas=atof(charvalue);
      }
      keyname=(char*)(arg5);
      /*found=1;*/
      if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,nom_fichier_fits,&numhdu,&nbkeys,keyname,NULL,NULL,NULL,charvalue))!=0) {
	 if (msg==202) {
	    /*found=0;*/
	    seuil_haut=1;
	 } else {
	    free(p);
	    return(msg);
	 }
      } else {
	 seuil_haut=atof(charvalue);
      }
   }
   /*
   printf("seuil bas=%f   seuil haut=%f\n",seuil_bas,seuil_haut);
   printf("imax=%d    jmax=%d\n",imax,jmax);
   */

   /* --- transformation de l'image sur 256 niveaux ---*/
   if ((buf=(short *)calloc(nelements,sizeof(short)))==NULL) {
      return(FS_ERR_PB_MALLOC);
   }
   delta_seuil=seuil_haut-seuil_bas;
   if (delta_seuil==0) delta_seuil=1;
   for (i=0;i<imax;i++) {
      for (j=0;j<jmax;j++) {
	 /*
	 k=jmax*i+j;
	 kk=jmax*(imax-1-i)+j;
	 */
	 k=imax*j+i;
	 kk=imax*(jmax-1-j)+i;
	 if      (p[k]>=(float)(seuil_haut)) {buf[kk]=255;}
	 else if (p[k]<=(float)(seuil_bas))  {buf[kk]=0;}
	 else {
	    buf[kk]=(short)(256*(p[k]-seuil_bas)/delta_seuil);
	 }
      }
   }

   /* --- image GIF ---*/
   nom_fichier_gif=(char*)(arg2);
   if ((out=fopen(nom_fichier_gif,"wb")) == NULL) {
      return(FS_ERR_PTR_NULL);
   }

   /* Contantes du GIF */
   interlace=0;
   BitsPerPixel=8;

   /* Palette du GIF (niveaux de gris) */
   for (i=0;i<256;i++) {
      Red[i]=i;
      Green[i]=i;
      Blue[i]=i;
   }

   /* Ecriture du fichier GIF */
   GIFEncode(out,imax,jmax,interlace,0,BitsPerPixel,Red,Green,Blue,buf);

   /* Fermeture du fichier GIF */
   fclose(out);

   free(buf);
   free(p);
   return(OK_DLL);
}

/********* GIF : GIFGETPIXEL ********/
int GIFGetPixel(int x,int y,short imax,short *buf)
{
int color;
int adr;

adr=(int)x+(int)y*imax;
color=(int)buf[adr];
return color;
}

/************* GIF : GIFBUMPPIXEL ******************/
void GIFBumpPixel()
{
++curx;
if (curx==Width)
   {
   curx=0;
   if (!Interlace)
      ++cury;
   else
      {
      switch (Pass)
	 {
	 case 0:
	    cury+=8;
	    if (cury>=Height)
	       {
	       ++Pass;
	       cury=4;
	       }
	    break;
	 case 1:
	    cury+=8;
	    if (cury>=Height)
	       {
	       ++Pass;
	       cury=2;
	       }
	    break;
	 case 2:
	    cury+=4;
	    if (cury>=Height)
	       {
	       ++Pass;
	       cury=1;
	       }
	    break;
	 case 3:
	    cury+=2;
	    break;
	 }
      }
   }
}

/*********** GIF : GIFNEXTPIXEL ***************/
int GIFNextPixel(short imax,short *buf)
{
int r;

if (CountDown==0) return EOF;
--CountDown;

r=GIFGetPixel(curx,cury,imax,buf);

GIFBumpPixel();

return r;
}

/************* GIF : GIFEENCODE **************/
void GIFEncode(FILE *fp,int GWidth,int GHeight,int GInterlace,
	       int Background,int BitsPerPixel,
	       int *Red,int *Green,int *Blue,short *buf)
{
int B;
int RWidth,RHeight;
int LeftOfs, TopOfs;
int Resolution;
int ColorMapSize;
int InitCodeSize;
int i;
short imax;

cur_accum=0;
cur_bits=0;
free_ent=0;
clear_flg=0;
Pass=0;
maxbitss=BITS;
maxmaxcode=(int)1 << BITS;

Interlace=GInterlace;

ColorMapSize = 1 << BitsPerPixel;

RWidth=Width=GWidth;
RHeight=Height=GHeight;
LeftOfs=TopOfs=0;
imax=(short)GWidth;

Resolution=BitsPerPixel;
CountDown=(long)Width * (long)Height;
Pass=0;

if (BitsPerPixel<=1)
   InitCodeSize=2;
else
   InitCodeSize=BitsPerPixel;

curx=cury=0;

fwrite("GIF87a",1,6,fp);
GIFPutword(RWidth,fp);
GIFPutword(RHeight,fp);

B=0x80;
B |= (Resolution - 1) << 5;
B |= (BitsPerPixel - 1);
fputc(B,fp);

fputc(Background,fp);
fputc(0,fp);

for (i=0;i<ColorMapSize;++i)
   {
   fputc(Red[i],fp);
   fputc(Green[i],fp);
   fputc(Blue[i],fp);
   }

fputc(',',fp);

GIFPutword(LeftOfs,fp);
GIFPutword(TopOfs,fp);
GIFPutword(Width,fp);
GIFPutword(Height,fp);

if (Interlace)
   fputc(0x40,fp);
else
   fputc(0x00,fp);

fputc(InitCodeSize,fp);

GIFCompress(InitCodeSize+1,fp,imax,buf);

fputc( 0, fp );
fputc( ';', fp );
}

/************ GIF : GIFPUTWORD *************/
void GIFPutword(int w,FILE *fp)
{
fputc( w & 0xff, fp );
fputc( (w / 256) & 0xff, fp );
}

/****************** GIF : GIFCOMPRESS *******************/
void GIFCompress(int init_bits,FILE *outfile,short imax,short *buf)
{
long fcode;
int i=0;
int c;
int ent;
int disp;
int hshift;

g_init_bits=init_bits;
g_outfile=outfile;
clear_flg=0;
maxcode= MAXCODE(n_bits=g_init_bits);

ClearCode=(1 << (init_bits - 1));
EOFCode=ClearCode+1;
free_ent=ClearCode+2;
GIFChar_init();
ent=GIFNextPixel(imax,buf);
hshift=0;

for (fcode=(long)HSIZE;fcode<65536L;fcode*= 2L) ++hshift;

hshift=8-hshift;
GIFCl_hash((long)HSIZE);

GIFOutput((int)ClearCode);

while ((c=GIFNextPixel(imax,buf))!=EOF)
   {
   fcode=(long)(((long)c<<maxbitss)+ ent);
   i=(((int)c<<hshift)^ent);
   if (HashTabOf(i)==fcode)
      {
      ent=CodeTabOf(i);
      continue;
      }
   else if ((long)HashTabOf(i)<0)
      goto nomatch;

   disp=HSIZE-i;
   if (i==0)
   disp=1;
probe:
   if ((i-=disp)<0)
   i+=HSIZE;

   if (HashTabOf(i)==fcode)
      {
      ent=CodeTabOf(i);
      continue;
      }
   if ((long)HashTabOf(i)>0) goto probe;
nomatch:
   GIFOutput((int)ent);
   ent=c;
   if (free_ent<maxmaxcode)
      {
      CodeTabOf(i)=free_ent++;
      HashTabOf(i)=fcode;
      }
   else
      GIFCl_block();
   }
GIFOutput((int)ent);
GIFOutput((int)EOFCode);
}

/************** GIF : GIFOUTPUT ****************/
void GIFOutput(int code)
{
cur_accum&=masks[cur_bits];

if (cur_bits>0)
   cur_accum |= ((long)code << cur_bits);
else
   cur_accum=code;

cur_bits+=n_bits;

while (cur_bits >= 8)
   {
   GIFChar_out((unsigned int)(cur_accum & 0xff));
   cur_accum>>=8;
   cur_bits-=8;
   }

if (free_ent>maxcode || clear_flg)
   {
   if (clear_flg)
      {
      maxcode=MAXCODE(n_bits=g_init_bits);
      clear_flg=0;
      }
   else
      {
      ++n_bits;
      if (n_bits==maxbitss)
	 maxcode=maxmaxcode;
      else
	 maxcode=MAXCODE(n_bits);
      }
   }

if (code==EOFCode)
   {
   while (cur_bits>0)
      {
      GIFChar_out((unsigned int)(cur_accum & 0xff));
      cur_accum>>=8;
      cur_bits-=8;
      }
   GIFFlush_char();
   fflush(g_outfile);
   }
}

/************ GIF : GIFCl_block ************/
void GIFCl_block ()
{
GIFCl_hash((long) HSIZE);
free_ent=ClearCode+2;
clear_flg=1;
GIFOutput((int)ClearCode);
}

/************* GIF : GIFCL_HASH ************/
void GIFCl_hash(long hsize)
{
long *htab_p=htab+hsize;
long i;
long m1=-1;

i=hsize-16;
do
   {
   *(htab_p-16)=m1;
   *(htab_p-15)=m1;
   *(htab_p-14)=m1;
   *(htab_p-13)=m1;
   *(htab_p-12)=m1;
   *(htab_p-11)=m1;
   *(htab_p-10)=m1;
   *(htab_p-9)=m1;
   *(htab_p-8)=m1;
   *(htab_p-7)=m1;
   *(htab_p-6)=m1;
   *(htab_p-5)=m1;
   *(htab_p-4)=m1;
   *(htab_p-3)=m1;
   *(htab_p-2)=m1;
   *(htab_p-1)=m1;
   htab_p-=16;
   } while ((i-=16)>=0);

for (i+=16;i>0;--i) *--htab_p=m1;
}

/********** GIF : GIFCHAR_INIT **********/
void GIFChar_init()
{
a_count=0;
}

/******** GIF : GIFCHAR_OUT ***********/
void GIFChar_out(int c )
{
accum[a_count++]=c;
if (a_count>=254) GIFFlush_char();
}

/******** GIF : GIFFlush_char ***********/
void GIFFlush_char()
{
if (a_count>0)
   {
   fputc(a_count,g_outfile);
   fwrite(accum,1,a_count,g_outfile);
   a_count=0;
   }
}

