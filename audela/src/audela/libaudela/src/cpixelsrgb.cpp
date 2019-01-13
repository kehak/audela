/* cpixelsrgb.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

#include <math.h>
#include <stdlib.h>     // malloc, free
#include <string.h>     // memecpy, strcpy

#include "cpixelsrgb.h"
#include "libtt.h"            // for TFLOAT, LONG_IMG, TT_PTR_...
#include "cerror.h"

#ifndef max
#define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#define min(a,b) (((a)<(b))?(a):(b))
#endif


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CPixelsRgb::CPixelsRgb()
{
   pix = NULL;
   naxis1 = 0;
   naxis2 = 0;
   naxis  = 2;
}

CPixelsRgb::~CPixelsRgb()
{
   if(pix) free(pix);
   pix = NULL;


}

/**
 *----------------------------------------------------------------------
 * CPixelsRgb::CPixelsRgb
 * Cree un objet de la classe CPixelsRgb et l'initalise avec les donnees
 * pointee par le parametre "pixels".
 * Les donnes "pixels" doivent contenir width*height*3 elements.
 * et doivent etre dans l'ordre :
 *  R(0,0)G(0,0)B(0,0) R(1,0)G(1.0)B(1,0) R(2,0) ...
 * Si pixels est nul, l'objet est cree mais les donnees ne sont pas initialisees.
 *
 * Parameters:
 *    width       : Largeur en pixels
 *    height      : Hauteur en pixels
 *    pixelFormat : Format des donnees FORMAT_BYTE ou FORMAT_SHORT ou FORMAT_USHORT ou FORMAT_FLOAT
 *    pixels      : pointeur des donnees. Si pixels vaut 0, l'objet CPixelsRgb est cree
 *                  mais les donnees ne sont pas initialisees
 *    reverseX    : vaut 0 ou 1. Si reverseX=1, les valeurs sur l'axe x sont inversees (= miroir vertical)
 *    reverseY    : vaut 0 ou 1. Si reverseY=1, les valeurs sur l'axe y sont inversees (= miroir horizontal)
 * Results:
 *    Genere une exception CError en cas d'erreur.
 * Side effects:
 *    creation d'un objet de la classe CPixelsRgb
 *----------------------------------------------------------------------
 */

CPixelsRgb::CPixelsRgb(int width, int height, TPixelFormat pixelFormat, void * pixels, int reverseX, int reverseY)
{
   long size;
   long t, x, y;
   naxis  = 3;
   naxis1 = width;
   naxis2 = height;

   size = naxis1*naxis2*naxis;
   pix = (TYPE_PIXELS_RGB*)malloc(size * sizeof(TYPE_PIXELS_RGB));
   if(pix==0) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   if( pixels != 0 ) {
      t = size;

      switch( pixelFormat ) {
      case FORMAT_BYTE:
         {
            unsigned char * pixelPtr = (unsigned char *) pixels;
            TYPE_PIXELS_RGB * pixCur = pix;
            if (reverseY == 0) {
               while(--t>=0) *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
            } else {
               for (y=height-1; y>=0; y--) {
                  t = width*y*naxis;
                  for (x=0;x<width*naxis;x++) {
                     *(pixCur+(t++)) = (TYPE_PIXELS_RGB)*(pixelPtr++);
                  }
               }
            }
         }
         break;

      case FORMAT_SHORT:
         {
            short * pixelPtr = (short *) pixels;
            TYPE_PIXELS_RGB * pixCur = pix;
            if (reverseY == 0) {
               while(--t>=0) {
                  *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
               }
            } else {
               for (y=height-1; y>=0; y--) {
                  t = width*y*naxis;
                  for (x=0;x<width*naxis;x++) {
                     *(pixCur+(t++)) = (TYPE_PIXELS_RGB)*(pixelPtr++);
                  }
               }
            }
         }
         break;
      case FORMAT_USHORT:
         {
            unsigned short * pixelPtr = (unsigned short *) pixels;
            TYPE_PIXELS_RGB * pixCur = pix;
            if (reverseY == 0) {
               while(--t>=0) {
                  *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
               }
            } else {
               for (y=height-1; y>=0; y--) {
                  t = width*y*naxis;
                  for (x=0;x<width*naxis;x++) {
                     *(pixCur+(t++)) = (TYPE_PIXELS_RGB)*(pixelPtr++);
                  }
               }
            }
         }
         break;
      case FORMAT_FLOAT:
         {
            float     * pixelPtr = (float *) pixels;
            TYPE_PIXELS_RGB * pixCur = pix;
            if (reverseY == 0) {
               while(--t>=0) *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
            } else {
               for (y=height-1; y>=0; y--) {
                  t = width*y*naxis;
                  for (x=0;x<width*naxis;x++) {
                     *(pixCur+(t++)) = (TYPE_PIXELS_RGB)*(pixelPtr++);
                  }
               }
            }
         }
         break;
      default :
         free(pix);
         throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
         break;
      }
   }
   // j'inverse les pixels si reverseX=1
   if( reverseX == 1 ) {
      MirX();
   }
}

/**
 *----------------------------------------------------------------------
 * CPixelsRgb::CPixelsRgb
 * Cree un objet de la classe CPixelsRgb et l'initalise avec les donnees
 * pointee par le parametre "pixels" (voir Tk
 * Les donnes "pixels" width*height*3 elements dasn l'ordre suivant :
 *  R(0,0)G(0,0)B(0,0) R(1,0)G(1.0)B(1,0) R(2,0) ...
 *
 * Parameters:
 *    width       : Largeur en pixels
 *    height      : Hauteur en pixels
 *    pixelSize   : Nombre de couleurs (3 ou 4)
 *    offset      : offset des couleurs
 *                   offset[0] offet du rouge
 *                   offset[1] offet du vert
 *                   offset[2] offet du bleu
 *                   offset[3] offet du alpha
 *    pitch       : non utilise
 *    pixels      : pointeur des donnees FORMAT_BYTE (un octet par couleur).
 * Results:
 *    Genere une exception CError en cas d'erreur.
 * Side effects:
 *    creation d'un objet de la classe CPixelsRgb
 *----------------------------------------------------------------------
 */

CPixelsRgb::CPixelsRgb(int width, int height, int pixelSize, int offset[4], int pitch, unsigned char * pixels)
{
   long size;
   long base;
   long reverse = 1;


   if (height<0) {
      height = -height;
      reverse = 1;
   }

   naxis  = 3;
   naxis1 = width;
   naxis2 = height;

   size = naxis1*naxis2*naxis;
   pix = (TYPE_PIXELS_RGB*)malloc(size * sizeof(TYPE_PIXELS_RGB));
   if(pix==NULL) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   if( pixels != NULL ) {
      if( pixelSize == 3 && offset[0] == 0 &&  offset[1] == 1 && offset[2] == 2 ) {
         // si les octets sont d�j� ordonn�s , je copie le buffer
         memcpy(pix, pixels, size );
      } else if ( pixelSize == 3 || pixelSize == 4 ) {
         int x, y;
         TYPE_PIXELS_RGB *pix2 = pix;

         if (reverse == 0) {
            for(y=0;y<naxis2;y++) {
               for(x=0;x<naxis1;x++) {
                  //base=pixelSize*((naxis2-y-1)*naxis1+x);
                  base=(y*naxis1+x)*pixelSize;
                  *(pix2++) =pixels[base+offset[0]];
                  *(pix2++) =pixels[base+offset[1]];
                  *(pix2++) =pixels[base+offset[2]];
               }
            }
         } else {
            for(y=0;y<naxis2;y++) {
               for(x=0;x<naxis1;x++) {
                  base=pixelSize*((naxis2-y-1)*naxis1+x);
                  //base=(y*naxis1+x)*pixelSize;
                  *(pix2++) =pixels[base+offset[0]];
                  *(pix2++) =pixels[base+offset[1]];
                  *(pix2++) =pixels[base+offset[2]];
               }
            }
         }

      } else {
         // non implemente pour 2 couleurs
         free(pix);
         throw CError(ELIBSTD_NOT_IMPLEMENTED);
      }
   } else {
      // si les valeurs de pixels ne sont pas fournies , je mets tout � zero
      int t = size;
      while(--t>0) *(pix+t) = 0;
   }

}


/**
 *----------------------------------------------------------------------
 * CPixelsRgb::CPixelsRgb
 * Cree un objet de la classe CPixelsRgb et l'initalise avec les donnees
 * pointee par le parametre "pixelsR" "pixelsG" "pixelsB".
 * Les donnes "pixelsR" "pixelsG" "pixelsB" doivent contenir chacun width*height elements.
 *
 * Parameters:
 *    width       : Largeur en pixels
 *    height      : Hauteur en pixels
 *    pixelFormat : Format des donnees FORMAT_BYTE ou FORMAT_SHORT ou FORMAT_USHORT ou FORMAT_FLOAT
 *    pixelsR     : pointeur des donnees rouge.
 *    pixelsG     : pointeur des donnees vert.
 *    pixelsB     : pointeur des donnees bleu.
 * Results:
 *    Genere une exception CError en cas d'erreur.
 * Side effects:
 *    creation d'un objet de la classe CPixelsRgb
 *----------------------------------------------------------------------
 */

CPixelsRgb::CPixelsRgb(int width, int height, TPixelFormat pixelFormat, void *pixelsR, void *pixelsG, void *pixelsB) {
   TYPE_PIXELS_RGB *pixCur;
   long size;
   long t;

   if( pixelsR == NULL || pixelsG==NULL || pixelsB == NULL ) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   naxis  = 3;
   naxis1 = width;
   naxis2 = height;

   size = naxis1*naxis2*naxis;
   pix = (TYPE_PIXELS_RGB*)malloc(size * sizeof(TYPE_PIXELS_RGB));
   if(pix==NULL) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   pixCur = pix;

   t =  naxis1*naxis2;
   switch( pixelFormat ) {
       case FORMAT_BYTE:
          {
               unsigned char * pixCurR = (unsigned char *) pixelsR;
               unsigned char * pixCurG = (unsigned char *) pixelsG;
               unsigned char * pixCurB = (unsigned char *) pixelsB;

               while(--t>=0) {
                  *(pixCur++) = (TYPE_PIXELS_RGB) *(pixCurR++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurG++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurB++);
               }
           break;
          }
       case FORMAT_SHORT:
          {
               short * pixCurR = (short *) pixelsR;
               short * pixCurG = (short *) pixelsG;
               short * pixCurB = (short *) pixelsB;

               while(--t>=0) {
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurR++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurG++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurB++);
               }
           break;
          }
       case FORMAT_USHORT:
          {
               unsigned short * pixCurR = (unsigned short *) pixelsR;
               unsigned short * pixCurG = (unsigned short *) pixelsG;
               unsigned short * pixCurB = (unsigned short *) pixelsB;

               while(--t>=0) {
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurR++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurG++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurB++);
               }
           break;
          }
       case FORMAT_FLOAT:
          {
               float * pixCurR = (float *) pixelsR;
               float * pixCurG = (float *) pixelsG;
               float * pixCurB = (float *) pixelsB;

               while(--t>=0) {
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurR++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurG++);
                  *(pixCur++) = (TYPE_PIXELS_RGB)*(pixCurB++);
               }
               break;
          }
       case FORMAT_UNKNOWN:
         throw CError("undefined pixel format");
         break;
   }
}

void CPixelsRgb::Add(char *filename, float offset)
{
   int msg;
   int datatype;
   char s[512];
   int t;

   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;

   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));

      // je recupere l'image a traiter en s�parant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB);

      //datatype = TFLOAT;
      datatype = TSHORT;
      sprintf(s,"ADD \"file=%s\" offset=%f",filename,offset);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);

      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);
   } catch (const CError& e) {
      // je libere la memoire reservee avant l'arriv�e de l'erreur
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      throw e;
   }
}

/**
 *  Autocut
 *
 *  retourne les seuils par d�faut d'un image couleur
 *    valeur fixe en premi�re approximation.
 */
void CPixelsRgb::Autocut(double *phicut,double *plocut,double *pmode)
{
   *plocut =-1;
   *phicut =256;
   *pmode =0;
}

void CPixelsRgb::BinX(int x1, int x2, int width)
{

   throw CError(ELIBSTD_NOT_IMPLEMENTED);
 }

void CPixelsRgb::BinY(int y1, int y2, int height)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);

   /*
   int temp;
   int x, y;
   TYPE_PIXELS value;
   TYPE_PIXELS *out;

   if (height < 0)
   {
         return ELIBSTD_HEIGHT_POSITIVE;

   }
   if ((y1 < 0) || (y2 < 0) || (y1 > naxis2-1) || (y2 > naxis2-1))
   {
         return ELIBSTD_Y1Y2_NOT_IN_1NAXIS2;
   }

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   }

   out = (TYPE_PIXELS*)calloc(naxis1*height,sizeof(TYPE_PIXELS));
   if( out == NULL ) {
      return ELIBSTD_NO_MEMORY_FOR_PIXELS;
   }

   // bining
   for(x = 0; x < naxis1;x++)
   {
       value = (float)0;
       for(y=y1;y<=y2;y++)
       {
          value += pix[x+y*naxis1];
       }
       for(y=0;y<height;y++)
       {
          out[x+y*naxis1]=value;
       }
   }


   naxis1 = naxis1;
   naxis2 = height;

   //CreateBuffer(w,height);
   //memcpy(pix,out,w*height*sizeof(TYPE_PIXELS));
   //result = SetPixels( naxis1, height, FORMAT_FLOAT, COMPRESS_NONE, (int) out);
   free(pix);
   pix = out;
   return 0;
   */
}


void CPixelsRgb::Clipmin(double value)
{
   int nelem,k;
   unsigned char value2;

   value2 = (unsigned char) value;

   nelem=naxis1*naxis2*naxis;

   for (k=0;k<nelem;k++) {
      if( pix[k]<value) {
         pix[k]= (unsigned char) value;
      }
   }
}

void CPixelsRgb::Clipmax(double value)
{
   int nelem,k;
   unsigned char value2;

   value2 = (unsigned char) value;
   nelem=naxis1*naxis2*naxis;

   for (k=0;k<nelem;k++) {
      if (pix[k]>value) {
         pix[k]=(unsigned char) value;
      }
   }
}

void CPixelsRgb::Div(char *filename, float constante)
{
   int msg;
   int datatype;
   char s[512];
   int t;

   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;

   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));

      // je recupere l'image a traiter en s�parant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB);

      //datatype = TFLOAT;
      datatype = TSHORT;
      sprintf(s,"DIV \"file=%s\" constant=%f",filename,constante);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);

      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);
   } catch (const CError& e) {
      // je libere cla memoire attribu�e avant l'arriv�e de l'erreur
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      throw e;
   }
}


TPixelClass CPixelsRgb::getPixelClass() {
   return CLASS_RGB;
}

int CPixelsRgb::getHeight(void) {
   return naxis2;
}

//void CPixelsRgb::GetPixels(TYPE_PIXELS **pixels) {
//   throw CError(ELIBSTD_NOT_IMPLEMENTED);
//
//}

void CPixelsRgb::GetPixels(int x1, int y1, int x2, int y2 , TPixelFormat pixelFormat, TColorPlane plane, void* pixels) {
   int x, y;
   int width  = x2-x1+1;
   TYPE_PIXELS_RGB  *ptr;

   switch( pixelFormat ) {
   case FORMAT_BYTE:
      {
         unsigned char * out = (unsigned char *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (unsigned char)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         default :
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      }
      break;
   case FORMAT_SHORT:
      {
         short * out = (short *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (short) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (short) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  ptr++;   // skip G
                  *(out++) = (short) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (short)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (short *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (short) *(ptr++);
                  *(out++) = (short) *(ptr++);
                  *(out++) = (short) *(ptr++);
               }
            }
            break;
         default :
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      }
      break;
   case FORMAT_USHORT:
      {
         unsigned short * out = (unsigned short *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  ptr++;   // skip G
                  *(out++) = (unsigned short) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (unsigned short)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
               }
            }
            break;
         default :
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      }
      break;
   case FORMAT_FLOAT:
      {
         float * out = (float *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (float) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (float)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*y+x1) * naxis;
               out = (float *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         default :
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      break;
      }
   default :
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
      break;

   }
}

void CPixelsRgb::GetPixelsReverse(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, void* pixels) {
   int x, y;
   int width  = x2-x1+1;
   TYPE_PIXELS_RGB  *ptr;

   switch( pixelFormat ) {
   case FORMAT_BYTE:
      {
         unsigned char * out = (unsigned char *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned char) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (unsigned char)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned char *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
                  *(out++) = (unsigned char) *(ptr++);
               }
            }
            break;
         default:
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      }
      break;
   case FORMAT_SHORT:
      {
         short * out = (short *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (short) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (short) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  ptr++;   // skip G
                  *(out++) = (short) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (short)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (short *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (short) *(ptr++);
                  *(out++) = (short) *(ptr++);
                  *(out++) = (short) *(ptr++);
               }
            }
            break;
         default:
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      }
      break;
   case FORMAT_USHORT:
      {
         unsigned short * out = (unsigned short *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (unsigned short) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  ptr++;   // skip G
                  *(out++) = (short) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (unsigned short)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (unsigned short *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
                  *(out++) = (unsigned short) *(ptr++);
               }
            }
            break;
         default:
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      }
      break;
   case FORMAT_FLOAT:
      {
         float * out = (float *) pixels;
         switch( plane ) {
         case PLANE_R:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  ptr++;  // skip G
                  ptr++;  // skip B
               }
            }
            break;
         case PLANE_G:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;   // skip R
                  *(out++) = (float) *(ptr++);
                  ptr++;   // skip B
               }
            }
            break;
         case PLANE_B:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  ptr++;    // skip R
                  ptr++;    // skip G
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         case PLANE_GREY:
            for(y=y1;y<=y2;y++) {
               float val;
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  val = (float)*(ptr++);
                  val += (float)*(ptr++);
                  val += (float)*(ptr++);
                  *(out++) = (float)(val/naxis);
               }
            }
            break;
         case PLANE_RGB:
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1) * naxis;
               out = (float *) pixels + width*(y-y1)*naxis;
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
                  *(out++) = (float) *(ptr++);
               }
            }
            break;
         default:
            throw CError(ELIBSTD_NOT_IMPLEMENTED);
            break;
         }
      break;
      }
   default:
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
      break;

   }
}


void CPixelsRgb::GetPixels(TYPE_PIXELS_RGB *pixelsR, TYPE_PIXELS_RGB *pixelsG, TYPE_PIXELS_RGB *pixelsB) {
   TYPE_PIXELS_RGB *pixCurR = NULL, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   long t;

   // copie les 3 plans dans trois tableaux
   pixCurR = pixelsR;
   pixCurG = pixelsG;
   pixCurB = pixelsB;
   pixCur = pix;
   t =  naxis1*naxis2;
   while(--t>0) {
      *(pixCurR++) = *(pixCur++);
      *(pixCurG++) = *(pixCur++);
      *(pixCurB++) = *(pixCur++);
   }
}

/*
 * GetPixGray
 * retourne la somme des 3 couleurs du pixel
 */

void CPixelsRgb::getPix(int *plane, TYPE_PIXELS *val1,TYPE_PIXELS *val2,TYPE_PIXELS *val3,int x, int y)
{
   TYPE_PIXELS_RGB * ptr;

   if((x<0)||(x>=naxis1)) {
      throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   } else if ((y<0)||(y>=naxis2)) {
      throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }
   //  position des couleur du pixel (x,y): ptr = (y*naxis1+x)*3 + offset
   ptr = pix + (y*naxis1+x)*naxis;
   *plane = 3;
   *val1 = (float) *(ptr + 0);
   *val2 = (float) *(ptr + 1);
   *val3 = (float) *(ptr + 2);
}

/**
  retourne le pointeur du tableau interne de pixels
  Non implemente pour les pixelzs RGB
*/
void CPixelsRgb::GetPixelsPointer(TYPE_PIXELS **pixels) {
      throw CError(ELIBSTD_NOT_IMPLEMENTED);
}

/**
 * GetPixelsRgb
 * retourne les intensit�s de la zone (x1,y1)-(x2,y2)
 * dans le format RGB : 3 octets par pixel ( rouge, vert, bleu)
 * en tenant compte des mirrois X ou Y �ventuels, des seuils haut et bas et de la palette de couleurs
 *
 * @param x1       abcisse du coin bas gauche de la zone
 * @param y1       ordonnee du coin bas gauche de la zone
 * @param x2       abcisse du coin haut, doit de la zone
 * @param x2       ordonn�e du coin haut, doit de la zone
 * @param mirrorX  0: pas de miroir horizontal, 1: miroir horizontal
 * @param mirrorY  0: pas de miroir vertical, 1 : miroir vertical
 * @param cuts     tableau des 6 seuils : haut rouge, bas rouge, haut vert bas vert , haut bleu , bas bleu
 * @param palette  palette de couleur (256 valeurs dans un tableau de 256 octets)
 * @param ptr      pointeur de pixels 24 bits sous la forme RGBARGBARGBA...
 *
 * @return void
 */

void CPixelsRgb::GetPixelsRgb( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY, float *cuts,
             unsigned char *palette[3], unsigned char *ptr)
{
   int i, j;
   int orgww, orgwh;        // original window width, height
   float dynRed, dynGreen, dynBlue;
   float fshRed = (float)cuts[0];
   float fsbRed = (float)cuts[1];
   float fshGreen = (float)cuts[2];
   float fsbGreen = (float)cuts[3];
   float fshBlue = (float)cuts[4];
   float fsbBlue = (float)cuts[5];
   long base;
   int xdest, ydest;
   unsigned char (*pdest)[3];
   pdest = (unsigned char (*)[3])ptr;

   orgww = x2 - x1 + 1; // Largeur de la fenetre au depart
   orgwh = y2 - y1 + 1; // Hauteur ...

   if(fshRed==fsbRed) {
      fsbRed -= (float)1e-1;
   }
   dynRed = (float)256. / (fshRed - fsbRed);

   if(fshGreen==fsbGreen) {
      fsbGreen -= (float)1e-1;
   }
   dynGreen = (float)256. / (fshGreen - fsbGreen);

   if(fshBlue==fsbBlue) {
      fsbBlue -= (float)1e-1;
   }
   dynBlue = (float)256. / (fshBlue - fsbBlue);


   for(j=y1;j<=y2; j++) {
      if(mirrorY == 0) {
         ydest = ((y2-y1) - (j -y1) )*orgww ;
      } else {
         ydest = (j - y1)*orgww ;
      }

      for(i=x1;i<=x2;i++) {
         if(mirrorX == 0) {
            xdest = i-x1;
         } else {
            xdest = (x2-x1) - (i-x1) ;
         }
         base = (j*naxis1+i)*naxis;
         pdest[ydest+xdest][0] = palette[0][(unsigned char)min(max(((float)pix[base+0]-fsbRed)  *dynRed,0),255)];
         pdest[ydest+xdest][1] = palette[1][(unsigned char)min(max(((float)pix[base+1]-fsbGreen)*dynGreen,0),255)];
         pdest[ydest+xdest][2] = palette[2][(unsigned char)min(max(((float)pix[base+2]-fsbBlue) *dynBlue,0),255)];
      }
   }
}


/**
 * getPixelsVisu
 * retourne les intensit�s de la zone (x1,y1)-(x2,y2)
 * dans le format compatible avec la visu : 4 octets par pixel ( rouge, vert, bleu, inutilis�)
 * en tenant compte des mirrois X ou Y �ventuels, des seuils haut et bas et de la palette de couleurs
 *
 * @param x1       abcisse du coin bas gauche de la zone
 * @param y1       ordonnee du coin bas gauche de la zone
 * @param x2       abcisse du coin haut, doit de la zone
 * @param x2       ordonnee du coin haut, doit de la zone
 * @param mirrorX  0: pas de miroir horizontal, 1: miroir horizontal
 * @param mirrorY  0: pas de miroir vertical, 1 : miroir vertical
 * @param cuts     tableau des 6 seuils : haut rouge, bas rouge, haut vert bas vert , haut bleu , bas bleu
 * @param palette  palette de couleur (256 valeurs dans un tableau de 256 octets)
 * @param ptr      pointeur de pixels 32 bits sous la forme RGBARGBARGBA...
 *
 * @return void
 */

void CPixelsRgb::getPixelsVisu( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY,
                  //double hicutRed,   double locutRed,
                  //double hicutGreen, double locutGreen,
                  //double hicutBlue,  double locutBlue,
                  float *cuts,
                  unsigned char *palette[3], unsigned char *ptr)
{
   int i, j;
   int orgww, orgwh;        // original window width, height
   float dynRed, dynGreen, dynBlue;
//   float fshRed = (float)hicutRed;
//   float fsbRed = (float)locutRed;
//   float fshGreen = (float)hicutGreen;
//   float fsbGreen = (float)locutGreen;
//   float fshBlue = (float)hicutBlue;
//   float fsbBlue = (float)locutBlue;
   float fshRed = (float)cuts[0];
   float fsbRed = (float)cuts[1];
   float fshGreen = (float)cuts[2];
   float fsbGreen = (float)cuts[3];
   float fshBlue = (float)cuts[4];
   float fsbBlue = (float)cuts[5];
   long base;
   int xdest, ydest;
   unsigned char (*pdest)[4];
   pdest = (unsigned char (*)[4])ptr;

   orgww = x2 - x1 + 1; // Largeur de la fenetre au depart
   orgwh = y2 - y1 + 1; // Hauteur ...

   if(fshRed==fsbRed) {
      fsbRed -= (float)1e-1;
   }
   dynRed = (float)256. / (fshRed - fsbRed);

   if(fshGreen==fsbGreen) {
      fsbGreen -= (float)1e-1;
   }
   dynGreen = (float)256. / (fshGreen - fsbGreen);

   if(fshBlue==fsbBlue) {
      fsbBlue -= (float)1e-1;
   }
   dynBlue = (float)256. / (fshBlue - fsbBlue);


   for(j=y1;j<=y2; j++) {
      if(mirrorY == 0) {
         ydest = ((y2-y1) - (j -y1) )*orgww ;
      } else {
         ydest = (j - y1)*orgww ;
      }

      for(i=x1;i<=x2;i++) {
         if(mirrorX == 0) {
            xdest = i-x1;
         } else {
            xdest = (x2-x1) - (i-x1) ;
         }
         base = (j*naxis1+i)*naxis;
         pdest[ydest+xdest][0] = palette[0][(unsigned char)min(max(((float)pix[base+0]-fsbRed)  *dynRed,0),255)];
         pdest[ydest+xdest][1] = palette[1][(unsigned char)min(max(((float)pix[base+1]-fsbGreen)*dynGreen,0),255)];
         pdest[ydest+xdest][2] = palette[2][(unsigned char)min(max(((float)pix[base+2]-fsbBlue) *dynBlue,0),255)];
         pdest[ydest+xdest][3] = 0;
      }
   }
}

int CPixelsRgb::getWidth(void) {
   return naxis1;
}

int CPixelsRgb::GetPlanes(void) {
   return naxis;
}



/**
 *----------------------------------------------------------------------
 * IsPixelsReady
 *    informe si une image est presente dans le buffer
 *
 * Parameters:
 *    none
 * Results:
 *    returns 1 if pixels are ready, otherwise 0.
 * Side effects:
 *    verifie si une image est charg�e c.a.d si la taille est superieure a 1x1
 *----------------------------------------------------------------------
 */
int CPixelsRgb::IsPixelsReady(void) {
   if( naxis1 != 0 && naxis2 != 0) {
      return 1;
   } else {
      return 0;
   }
}


void CPixelsRgb::Log(float coef, float offset)
{
   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   int msg, datatype;
   char s[512];
   int t;


    try {
      pixelsR = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));

      // je recupere l'image a traiter en s�parant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB);

      //datatype = TFLOAT;
      datatype = TSHORT;
      sprintf(s,"LOG coeff=%f offsetlog=%f",coef,offset);

      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);

      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);

   } catch (const CError& e) {
      // je libere la m�moire
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      // je transmets l'exception
      throw e;
   }

}

void CPixelsRgb::MergePixels(TColorPlane plane, int pixels)
{
   long t;

   t = naxis1*naxis2;

   switch (plane) {

      case PLANE_R :
      {
         TYPE_PIXELS     * pixelPtr = (float *) pixels;
         TYPE_PIXELS_RGB * pixCur = pix;
         while(--t>=0) {
            *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
            pixCur++; // skip green element of pixel
            pixCur++; // skip blue  element of pixel
         }

      }
      break;

      case PLANE_G :
      {
         TYPE_PIXELS     * pixelPtr = (float *) pixels;
         TYPE_PIXELS_RGB * pixCur = pix;
         while(--t>=0) {
            pixCur++; // skip red
            *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
            pixCur++; // skip blue
         }
         break;
      }
      break;

      case PLANE_B :
      {
         TYPE_PIXELS     * pixelPtr = (float *) pixels;
         TYPE_PIXELS_RGB * pixCur = pix;
         while(--t>=0) {
            pixCur++; // skip red
            pixCur++; // skip green
            *(pixCur++) = (TYPE_PIXELS_RGB) *(pixelPtr++);
         }
      }
      break;


      default :
      {
         throw CError(ELIBSTD_NOT_IMPLEMENTED);
      }
      break;
   }
}


void CPixelsRgb::MirX()
{
   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   int msg, datatype;
   char s[32];
   int t;

   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));

      // je recupere l'image a traiter en s�parant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB);

      // mirroir
      //datatype = TFLOAT;
      datatype = TSHORT;

      strcpy(s,"INVERT mirror");
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);

      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }

      free(pixelsR);
      free(pixelsG);
      free(pixelsB);

   } catch (const CError& e) {
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      throw e;
   }
}


/*
void CPixelsRgb::MirY()
{
   TYPE_PIXELS_RGB *pixelsR = NULL;
   TYPE_PIXELS_RGB *pixelsG = NULL;
   TYPE_PIXELS_RGB *pixelsB = NULL;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   int msg, datatype;
   char s[32];
   int t;

   try {
      pixelsR = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS_RGB));

      // je recupere l'image a traiter en s�parant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB);

      // mirroir
      //datatype = TFLOAT;
      datatype = TSHORT;

      strcpy(s,"INVERT flip");
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);

      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);

   } catch (const CError& e) {
      // je libere la m�moire
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      // je transmets l'exception
      throw e;
   }

}
*/

void CPixelsRgb::NGain(float gain)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg;
   char *s;
   int datatype;

   //datatype = TFLOAT;
   datatype = TSHORT;

   s = new char[512];
   sprintf(s,"NORMGAIN normgain_value=%f",gain);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::NOffset(float offset)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, naxis1, naxis2, datatype;
   char *s;

   //datatype = TFLOAT;
   datatype = TSHORT;

   s = new char[512];
   sprintf(s,"NORMOFFSET normoffset_value=%f",offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::Offset(float offset)
{

   throw CError(ELIBSTD_NOT_IMPLEMENTED);

   /*
   datatype = TSHORT;

   s = new char[512];
   sprintf(s,"OFFSET offset=%f",offset);

   delete s;
   */
}

void CPixelsRgb::Opt(char *dark, char *offset)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[256];
   sprintf(s,"OPT dark=%s bias=%s",dark,offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::Rot(float x0, float y0, float angle)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"ROT x0=%f y0=%f angle=%f",x0,y0,angle);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

/*
 * SetPix
 *  Affecte la valeur du pixel aux coordonnees passes en parametres.
 *  Les valeurs des coordonnees vont de (0,0) a (NAXIS1-1,NAXIS2-1).
 *  La valeur de retour est :
 *    - '1'  si pas de pixels (pix=NULL)
 *    - '-1' si pas de mots-cles
 *    - '-2' si pas de mot-cle 'NAXIS1'
 *
 */
void CPixelsRgb::setPix(TColorPlane plane, TYPE_PIXELS val,int x, int y)
{

   if((x<0)||(x>=naxis1)) {
      throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   } else if ((y<0)||(y>=naxis2)) {
      throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }
   switch ( plane ) {
   case PLANE_R :
      *(pix+(y*naxis1+x)*naxis+0) = (unsigned char)  val;
      break;
   case PLANE_G :
      *(pix+(y*naxis1+x)*naxis+1) = (unsigned char)  val;
      break;
   case PLANE_B :
      *(pix+(y*naxis1+x)*naxis+2) = (unsigned char)  val;
      break;
   case PLANE_GREY :
      *(pix+(y*naxis1+x)*naxis+0) = (unsigned char)  val;
      *(pix+(y*naxis1+x)*naxis+1) = (unsigned char)  val;
      *(pix+(y*naxis1+x)*naxis+2) = (unsigned char)  val;
      break;
   default:
      throw CError("plane not authorized");
   }

}

void CPixelsRgb::Sub(char *filename, float offset)
{

   TYPE_PIXELS_RGB *pixelsR, *pixelsG, *pixelsB;
   TYPE_PIXELS_RGB *pixCurR, *pixCurG, *pixCurB;
   TYPE_PIXELS_RGB *pixCur;
   int msg, datatype;
   char s[512];
   int t;


    try {
      pixelsR = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));
      pixelsG = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));
      pixelsB = (TYPE_PIXELS_RGB *)calloc(naxis1*naxis2,sizeof(TYPE_PIXELS_RGB));

      // je recupere l'image a traiter en s�parant les 3 plans
      GetPixels( pixelsR, pixelsG, pixelsB);

      //datatype = TFLOAT;
      datatype = TSHORT;
      sprintf(s,"SUB \"file=%s\" offset=%f",filename,offset);

      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsR,&datatype,&naxis1,&naxis2,&pixelsR,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsG,&datatype,&naxis1,&naxis2,&pixelsG,&datatype,s);
      if(msg) throw CErrorLibtt(msg);
      msg = libtt_main(TT_PTR_IMASERIES,7,&pixelsB,&datatype,&naxis1,&naxis2,&pixelsB,&datatype,s);
      if(msg) throw CErrorLibtt(msg);

      // j'enregistre la nouvelle image
      pixCurR = pixelsR;
      pixCurG = pixelsG;
      pixCurB = pixelsB;
      pixCur = pix;
      t =  naxis1*naxis2;
      while(--t>0) {
         *(pixCur++) = *(pixCurR++);
         *(pixCur++) = *(pixCurG++);
         *(pixCur++) = *(pixCurB++);
      }
      free(pixelsR);
      free(pixelsG);
      free(pixelsB);

   } catch (const CError& e) {
      // je libere la m�moire
      if(pixelsR) free(pixelsR);
      if(pixelsG) free(pixelsG);
      if(pixelsB) free(pixelsB);
      // je transmets l'exception
      throw e;
   }
}

void CPixelsRgb::Sub(CPixels * subPixels, float offset) {

   if ( this->getWidth() !=  subPixels->getWidth() && this->getHeight() != subPixels->getHeight() ) {
      throw CError( "Image size (%d,%d) is different from current image size (%d,%d)",
         subPixels->getWidth(), subPixels->getHeight(), this->getWidth(), this->getHeight() );
   }

   if ( subPixels->GetPlanes() != this->GetPlanes() ) {
      throw CError( "Image planes (%d) is different from current image plane(%d)",
         subPixels->GetPlanes(), this->GetPlanes());
   }

   TYPE_PIXELS_RGB  * pixPtr = this->pix;
   TYPE_PIXELS_RGB  * subPrt = NULL;
   subPixels->GetPixelsPointer((TYPE_PIXELS**)&subPrt);
   for(int k = 0 ; k <this->naxis1*this->naxis2*this->GetPlanes() ; k++ ) {
      *(pixPtr++) += (TYPE_PIXELS_RGB)offset - *(subPrt++) ;
   }
}


//***************************************************
// unifybg
//
// - decoupe l'image en fentres
// - calcule le fond de ciel pour chaque fenetre
// - construit une matrice du fond du ciel pour chaque pixel
//   par interpolation entre les centres des rectangles
//
//***************************************************

void  CPixelsRgb::UnifyBg()
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg;                         // Code erreur de libtt
   int i, j, x, y, x1, y1, x2, y2, xc, xc1, xc2, yc, yc1, yc2;
   TYPE_PIXELS  *pixel, val;
   int wRect, hRect, naxis11, naxis22;
   int datatype;
   int nbCol = 10;   // nombre de rectanglex horizontaux
   int nbLine = 10;   // nombre de rectangles verticaux

   double *matbg, a ,b , v1, v2;
   double dlocut, dhicut, dmaxi, dmini, dmean, dsigma, dbgmean,dbgsigma,dcontrast;
   double sumBgmean=0;
   double nbBgmean=0;
   double meanBgmean;
   int *columns, *lines, colIndex, lineIndex;


   // je calcule la taille des fenetres
   wRect = naxis1 / nbCol;
   if ( wRect < 50 ) wRect = 50;
   hRect = naxis2 / nbLine;
   if ( hRect < 50 ) hRect = 50;

   // je cree la matrice du fond de ciel
   matbg = (double*)calloc(naxis1*naxis2,sizeof(double));
   // raz matrice
   for(x=0; x < naxis1 ; x++) {
      for(y=0; y < naxis2 ; y++) {
         matbg[y*naxis1+ x] = 0;
      }
   }

   // lines des centres des fenetres
   lines = (int*)calloc(nbLine,sizeof(int));

   // columns des centres des fenetres
   columns = (int*)calloc(nbCol,sizeof(int));


   // -----------------------------------------------------------
   // je calcule le fond du ciel de chaque fenetre (x,y)(x+wRect,y+hRect)
   // -----------------------------------------------------------
   colIndex=0;
   for(x1=0; x1 < naxis1 ; x1 +=wRect) {
      lineIndex=0;
      for(y1=0; y1 < naxis2 ; y1 +=hRect) {

         // calcul de coordonn�es de la fenetre
         if( x1 + wRect < naxis1) {
            x2 = x1 + wRect;
         } else {
            // cas du dernier rectangle � droite
            x2 = naxis1-1;
         }
         if( y1 + hRect < naxis2) {
            y2 = y1 + hRect;
         } else {
            // cas du dernier rectangle en bas
            y2 = naxis2-1;
         }

         // calcul des coord. du centre de la fenetre
         xc = (x2-x1)/2 +x1;
         yc = (y2-y1)/2 +y1;

         // je copie les pixels de la fenetre
         naxis11 = x2-x1+1;
         naxis22 = y2-y1+1;
         pixel = (TYPE_PIXELS*)calloc(naxis11*naxis22,sizeof(TYPE_PIXELS));
         for(j=y1;j<=y2;j++) {
            for(i=x1;i<=x2;i++) {
               *(pixel+naxis11*(j-y1)+(i-x1)) = *(pix+naxis1*j+i);
            }
         }
         // je calcule le fond du ciel
         datatype = TFLOAT;
         msg = libtt_main(TT_PTR_STATIMA,13,pixel,&datatype,&naxis11,&naxis22,
                  &dlocut,&dhicut,&dmaxi,&dmini,&dmean,&dsigma,&dbgmean,&dbgsigma,&dcontrast);
         free(pixel);
         if(msg) {
            return msg;
         }

         // je place la valeur du fond du ciel dans le pixel au centre du rectangle
         matbg[yc*naxis1+ xc ] = dbgmean;

         // je cumule les nbgmean pour calculer la moyenne globale plus tard
         sumBgmean +=dbgmean;
         nbBgmean++;

         // je memorise les coordonn�es du centre le fenetre
         columns[colIndex]= xc;
         lines[lineIndex] = yc;

         lineIndex++;

         //logInfo("1 x1=%d y1=%d x2=%d y2=%d bg=%f", x1, y1, x2, y2, dbgmean);

      }

      colIndex++;
   }

   nbCol = colIndex;
   nbLine = lineIndex;
   //logInfo("nbCol=%d nbLine=%d", nbCol, nbLine);

   // -----------------------------------------------------------
   // je calcule le fond du ciel pour les points interm�diaires
   // -----------------------------------------------------------

   // calcul des columns
   for(colIndex=0; colIndex<nbCol; colIndex++) {
      xc = columns[colIndex];
      for(lineIndex=0; lineIndex<nbLine-1; lineIndex++ ) {

         // je recupere les coordonness des deux points pour calculer la droite
         yc1 = lines[lineIndex];
         yc2 = lines[lineIndex+1];

         // je calcule les coefs de la droite de regression v = ay +b
         // la doite passe par les 2 points (yc1,v1) et (yc2, v2)
         v1 = matbg[yc1*naxis1+ xc ];
         v2 = matbg[yc2*naxis1+ xc ];
         a = (v2 - v1)/(yc2 - yc1);
         b = v1 - a * yc1;

         // je calcule les bornes de la droite de regression  y1, y2
         if(lineIndex == 0 ) {
            y1 = 0 ;          // premi�re fenetre en haut
         } else {
            y1 = yc1;
         }
         if(lineIndex >= nbLine - 2 ) {
            y2 = naxis2 ;   // deniere fenetre en bas
         } else {
            y2 = yc2;
         }

         // je calcule les points entre les deux bornes
         for( y = y1; y < y2 ; y++) {
            matbg[y*naxis1+ xc ]  = a * y + b;
         }

         //logInfo("col xc=%d yc1=%d yc2=%d y1=%d y2=%d", xc, yc1, yc2, y1, y2);
      }
   }


   //  calcul des lignes
   for(yc=0; yc<naxis2; yc++ ) {
      for(colIndex=0; colIndex<nbCol-1; colIndex++) {

         // je recupere les coordonness des deux points pour calculer la droite
         xc1 = columns[colIndex];
         xc2 = columns[colIndex+1];

         // je calcule les coefs de la droite de regression v = ax +b
         // la doite passe par les 2 points (xc1,v1) et (xc2, v2)
         v1 = matbg[yc*naxis1+ xc1 ];
         v2 = matbg[yc*naxis1+ xc2 ];
         a = (v2 - v1)/(xc2 - xc1);
         b = v1 - a*xc1;

         // je calcule les bornes de la droite de regression  x1, x2
         if(colIndex == 0 ) {
            x1 = 0 ;          // premi�re fenetre a gauche
         } else {
            x1 = xc1;
         }
         if(colIndex == nbCol -2 ) {
            x2 = naxis1;   // deniere fenetre a droite
         } else {
            x2 = xc2;
         }

         for( x = x1; x < x2 ; x++) {
            matbg[yc*naxis1+ x ]  = a * x + b;
         }
         //logInfo("line yc=%d xc1=%d xc2=%d x1=%d x2=%d v1=%f v2=%f", yc, xc1, xc2, x1, x2, v1, v2);
      }
   }

   // je calcule la moyenne globale du fond du ciel
   meanBgmean = sumBgmean / nbBgmean;

   // -----------------------------------------------------------
   // je soustrait le fond du ciel � l'image originale
   // -----------------------------------------------------------
   for(x=0; x < naxis1 ; x++) {
      for(y=0; y < naxis2 ; y++) {
         float ppix, pbg;
         ppix = *(pix+naxis1*y+x);
         pbg = (float) matbg[y*naxis1+ x];
         val = (float) ( ppix - pbg + meanBgmean) ;
         if ( val<0 ) val = 0;
         *(pix+naxis1*y+x) = val;
      }
   }

   return 0;
   */
}


void CPixelsRgb::Unsmear(float coef)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int msg, datatype;
   char *s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"UNSMEARING unsmearing=%f",coef);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);

   delete s;
   return msg;
   */
}

void CPixelsRgb::Window(int x1, int y1, int x2, int y2)
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
   /*
   int temp;
   int x, y, diff_x, diff_y;
   TYPE_PIXELS *out;

   if ((x1 < 0) || (x2 < 0) || (x1 > naxis1-1) || (x2 > naxis1-1))
   {
         return ELIBSTD_X1X2_NOT_IN_1NAXIS1;
   }
   if ((y1 < 0) || (y2 < 0) || (y1 > naxis2-1) || (y2 > naxis2-1))
   {
         return ELIBSTD_Y1Y2_NOT_IN_1NAXIS2;
   }

   if(x1 > x2)
   {
       temp = x1;
       x1 = x2;
       x2 = temp;
   }

   if(y1 > y2)
   {
       temp = y1;
       y1 = y2;
       y2 = temp;
   }

   diff_x = x2 - x1 + 1;
   diff_y = y2 - y1 + 1;

   // --- initialisation ---
   out = (TYPE_PIXELS*)calloc(diff_x*diff_y,sizeof(TYPE_PIXELS));
   if( out == NULL ) {
      return ELIBSTD_NO_MEMORY_FOR_PIXELS;
   }

   // window
   for(x = 0; x < diff_x;x++)
   {
       for(y = 0;y < diff_y;y++)
       {
         out[x + y * diff_x] =  pix[(x1 + x) + (y1 + y) * naxis1];
       }
   }

   naxis1 = diff_x;
   naxis2 = diff_y;
   //memcpy(pix,out,diff_x*diff_y*sizeof(TYPE_PIXELS));
   free(pix);
   pix = out;
   return 0;
   */
}


