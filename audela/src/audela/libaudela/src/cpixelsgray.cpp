/* cpixelsgray.cpp
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



#include <math.h>   // floor()
#include <stdlib.h>    // malloc, free
#include <string.h>     // memecpy, strcpy

#include "cpixelsgray.h"
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

CPixelsGray::CPixelsGray()
{
   pix = NULL;
   naxis1 = 0;
   naxis2 = 0;


}

CPixelsGray::~CPixelsGray()
{
   if(pix) free(pix);
   pix = NULL;


}

CPixelsGray::CPixelsGray(int width, int height, TYPE_PIXELS *ppix)
{
   int t;

   naxis1 = width;
   naxis2 = height;

   pix = (TYPE_PIXELS*)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS));
   if(pix==NULL) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   t = naxis1 * naxis2;
   while(--t>=0) *(pix+t) = (TYPE_PIXELS)*((ppix+t));

}

CPixelsGray::CPixelsGray(int width, int height, TPixelFormat pixelFormat, void * pixels, int reverseX, int reverseY)
{
   int t, u, x, y;

   naxis1 = width;
   naxis2 = height;

   // je cree le pointeur sur l'image (pix)
   pix = (TYPE_PIXELS*)malloc(naxis1*naxis2 * sizeof(TYPE_PIXELS));
   if(pix==NULL) {
      throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
   }

   t = naxis1 * naxis2;


   if( (void*)pixels != NULL ) {
      switch( pixelFormat ) {
      case FORMAT_BYTE:
         {
            unsigned char * pixelPtr = (unsigned char *) pixels;
            if (reverseY == 0) {
               while(--t>=0) *(pix+t) = (TYPE_PIXELS)*((pixelPtr+t));
            } else {
               for (u=0, y=height-1; y>=0; y--) {
                  t = width*y;
                  for (x=0;x<width;x++) {
                     *(pix+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                  }
               }
            }
         }
         break;

      case FORMAT_SHORT:
         {
            short * pixelPtr = (short *) pixels;
            if (reverseY == 0) {
               while(--t>=0) *(pix+t) = (TYPE_PIXELS)*((pixelPtr+t));
            } else {
               for (u=0, y=height-1; y>=0; y--) {
                  t = width*y;
                  for (x=0;x<width;x++) {
                     *(pix+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                  }
               }
            }
         }
         break;
      case FORMAT_USHORT:
         {
            unsigned short * pixelPtr = (unsigned short *) pixels;
            if (reverseY == 0) {
               while(--t>=0) *(pix+t) = (TYPE_PIXELS)*((pixelPtr+t));
            } else {
               for (u=0, y=height-1; y>=0; y--) {
                  t = width*y;
                  for (x=0;x<width;x++) {
                     *(pix+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                  }
               }
            }
         }
         break;
      case FORMAT_FLOAT:
         {
            float * pixelPtr = (float *) pixels;
            if (reverseY == 0) {
               while(--t>=0) *(pix+t) = (TYPE_PIXELS)*((pixelPtr+t));
            } else {
               for (u=0, y=height-1; y>=0; y--) {
                  t = width*y;
                  for (x=0;x<width;x++) {
                     *(pix+(t++)) = (TYPE_PIXELS)*((pixelPtr+(u++)));
                  }
               }
            }
         }
         break;
      default:
         free(pix);
         throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);
         break;

      }
   } else {
      while(--t>=0) *(pix+t) = 0;
   }

   // j'inverse les pixels si reverseX=1
   if( reverseX == 1 ) {
      MirX();
   }
}

void CPixelsGray::getPix(int *plane, TYPE_PIXELS *val1,TYPE_PIXELS *val2,TYPE_PIXELS *val3,int x, int y)
{

   if((x<0)||(x>=naxis1)) {
      throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   } else if ((y<0)||(y>=naxis2)) {
      throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }
   *plane = 1;
   *val1 = *(pix+x+y*naxis1);
   *val2 = *val1;
   *val3 = *val1;
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
void CPixelsGray::setPix(TColorPlane , TYPE_PIXELS val,int x, int y)
{

   if((x<0)||(x>=naxis1)) {
      throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   } else if ((y<0)||(y>=naxis2)) {
      throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }
   *(pix+x+y*naxis1) = val;
}



TPixelClass CPixelsGray::getPixelClass() {
   return CLASS_GRAY;
}


void CPixelsGray::Add(char *filename, float offset)
{
   int msg;
   int datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"ADD \"file=%s\" offset=%f",filename,offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);

}

void CPixelsGray::Autocut(double *phicut,double *plocut,double *pmode)
{
   int datatype;
   int msg;

   datatype=TFLOAT;

   // Appel a la fonction pointeur de TT
   msg = libtt_main(TT_PTR_CUTSIMA,7, pix,&datatype,&naxis1,&naxis2,plocut,phicut,pmode);
   if(msg) throw CErrorLibtt(msg);

}

void CPixelsGray::BinX(int x1, int x2, int width)
{
   int temp;
   int x, y;
   TYPE_PIXELS value;
   TYPE_PIXELS *out;

   if (width < 0)
   {
         throw CError( ELIBSTD_WIDTH_POSITIVE);
   }

   if ((x1 < 0) || (x2 < 0) || (x1 > naxis1-1) || (x2 > naxis1-1))
   {
         throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   }

   if(x1 > x2)
   {
       temp = x2;
       x2 = x1;
       x1 = temp;
   }

   out = (TYPE_PIXELS*)malloc(width*naxis2 * sizeof(TYPE_PIXELS));
   if( out == NULL ) {
      throw CError( ELIBSTD_NO_MEMORY_FOR_PIXELS );
   }

   // bining
   for(y = 0; y < naxis2;y++)
   {
       value = (float)0;
       for(x=x1;x<=x2;x++)
       {
          value += pix[x+y*naxis1];
       }
       for(x=0;x<width;x++)
       {
          out[x+y*width]=value;
       }
   }

   naxis1 = width;
   naxis2 = naxis2;

   free(pix);
   pix = out;
}

void CPixelsGray::BinY(int y1, int y2, int height)
{
   int temp;
   int x, y;
   TYPE_PIXELS value;
   TYPE_PIXELS *out;

   // verification des donnees
   if (height < 0)
   {
         throw CError( ELIBSTD_HEIGHT_POSITIVE );

   }
   if ((y1 < 0) || (y2 < 0) || (y1 > naxis2-1) || (y2 > naxis2-1))
   {
         throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
   }

   if(y1 > y2)
   {
       temp = y2;
       y2 = y1;
       y1 = temp;
   }

   out = (TYPE_PIXELS*)malloc(naxis1*height * sizeof(TYPE_PIXELS));
   if( out == NULL ) {
      throw CError( ELIBSTD_NO_MEMORY_FOR_PIXELS );
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

   // ne surtout pas oublier de mettre è jour les nouvelles dimensions
   naxis2 = height;

   // je libère l'ancien espace mèmoire
   free(pix);
   // j'affcete le nouvel espce mèmoire
   pix = out;
}


void CPixelsGray::Clipmin(double value)
{
   int nelem,k;

   nelem=naxis1*naxis2;

   for (k=0;k<nelem;k++) {
      if (pix[k]<value) {pix[k]=(float)value;}
   }
}

void CPixelsGray::Clipmax(double value)
{
   int nelem,k;

   nelem=naxis1*naxis2;

   for (k=0;k<nelem;k++) {
      if (pix[k]>value) {pix[k]=(float)value;}
   }
}

void CPixelsGray::Div(char *filename, float constante)
{
   int msg;
   int datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[512];
   sprintf(s,"DIV \"file=%s\" constant=%f",filename,constante);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);

}


int CPixelsGray::getHeight(void) {
   return naxis2;
}


/**
  retourne le pointeur du tableau interne de pixels
  fonction obsolète. Remplace par SetPixels/GetPixels/SetPix/GetPix
*/
void CPixelsGray::GetPixelsPointer(TYPE_PIXELS **pixels) {
   *pixels = pix;
}

/**
  GetPixels
  retourne le tableau de pixels correspondant à la fenetre (x1,y1)-(x2,y2)
  en incluant les valeur limites x=x1, x=x2, y=y1 , y=y2
**/
void CPixelsGray::GetPixels(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane , void* pixels) {
   int width  = x2-x1+1;
   int x, y;

      switch( pixelFormat ) {
      case FORMAT_BYTE:
         {
            unsigned char * outPtr = (unsigned char *) pixels;
            for(y=y1;y<=y2;y++) {
               for(x=x1;x<=x2;x++) {
                  *(outPtr+width*(y-y1)+(x-x1)) = (unsigned char) *(pix+naxis1*y+x);
               }
            }
         }
         break;

      case FORMAT_SHORT:
         {
            short * outPtr = (short *) pixels;
            for(y=y1;y<=y2;y++) {
               for(x=x1;x<=x2;x++) {
                  *(outPtr+width*(y-y1)+(x-x1)) = (short) *(pix+naxis1*y+x);
               }
            }
         }
         break;
      case FORMAT_USHORT:
         {
            unsigned short * outPtr = (unsigned short *) pixels;
            for(y=y1;y<=y2;y++) {
               for(x=x1;x<=x2;x++) {
                  *(outPtr+width*(y-y1)+(x-x1)) = (unsigned short) *(pix+naxis1*y+x);
               }
            }
         }
         break;
      case FORMAT_FLOAT:
         {
            float * outPtr = (float *) pixels;
            for(y=y1;y<=y2;y++) {
               for(x=x1;x<=x2;x++) {
                  *(outPtr+width*(y-y1)+(x-x1)) = (float) *(pix+naxis1*y+x);
               }
            }
         }
         break;
      default:
         throw CError(ELIBSTD_PIXEL_FORMAT_UNKNOWN);
         break;

      }


}

void CPixelsGray::GetPixelsReverse(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, void* pixels) {
   int width  = x2-x1+1;
   int x, y;
   TYPE_PIXELS *ptr, *out;

      switch( pixelFormat ) {
      case FORMAT_BYTE:
         {
            unsigned char * outPtr = (unsigned char *) pixels;
            for(y=y1;y<=y2;y++) {
               for(x=x1;x<=x2;x++) {
                  *(outPtr+width*(y-y1)+(x-x1)) = (unsigned char) *(pix+naxis1*(naxis2-y-1)+x);
               }
            }
         }
         break;

      case FORMAT_SHORT:
         {
            short * outPtr = (short *) pixels;
            for(y=y1;y<=y2;y++) {
               for(x=x1;x<=x2;x++) {
                  *(outPtr+width*(y-y1)+(x-x1)) = (short) *(pix+naxis1*(naxis2-y-1)+x);
               }
            }
         }
         break;
      case FORMAT_USHORT:
         {
            unsigned short * outPtr = (unsigned short *) pixels;
            for(y=y1;y<=y2;y++) {
               for(x=x1;x<=x2;x++) {
                  *(outPtr+width*(y-y1)+(x-x1)) = (unsigned short) *(pix+naxis1*(naxis2-y-1)+x);
               }
            }
         }
         break;
      case FORMAT_FLOAT:
         {
            float * outPtr = (float *) pixels;
            for(y=y1;y<=y2;y++) {
               ptr = pix +(naxis1*(naxis2-y-1)+x1);
               out = outPtr + width*(y-y1);
               for(x=x1;x<=x2;x++) {
                  *(out++) = (float) (*ptr++);
               }
            }
         }
         break;
      default:
         throw CError(ELIBSTD_PIXEL_FORMAT_UNKNOWN);
         break;

      }


}


/**
 * GetPixelsRgb
 * retourne les intensitès de la zone (x1,y1)-(x2,y2)
 * dans le format RGB : 3 octets par pixel ( rouge, vert, bleu)
 * en tenant compte des mirrois X ou Y èventuels, des seuils haut et bas et de la palette de couleurs
 *
 * @param x1       abcisse du coin bas gauche de la zone
 * @param y1       ordonnee du coin bas gauche de la zone
 * @param x2       abcisse du coin haut, doit de la zone
 * @param x2       ordonnèe du coin haut, doit de la zone
 * @param mirrorX  0: pas de miroir horizontal, 1: miroir horizontal
 * @param mirrorY  0: pas de miroir vertical, 1 : miroir vertical
 * @param cuts     tableau des 6 seuils : haut rouge, bas rouge, haut vert bas vert , haut bleu , bas bleu
 * @param palette  palette de couleur (256 valeurs dans un tableau de 256 octets)
 * @param ptr      pointeur de pixels 24 bits sous la forme RGBARGBARGBA...
 *
 * @return void
 */
void CPixelsGray::GetPixelsRgb( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY, float *cuts,
            unsigned char *palette[3], unsigned char *ptr)
{
   int i, j;
   int orgww, orgwh;                // original window width, height
   float dyn;
   float fsh = (float) cuts[0];
   float fsb = (float) cuts[1];
   long base;
   int xdest, ydest;
   unsigned char colorIndex;
   unsigned char (*pdest)[3];
   pdest = (unsigned char (*)[3])ptr;

   orgww = x2 - x1 + 1;  // Largeur de la fenetre au depart
   orgwh = y2 - y1 + 1;  // Hauteur ...

   if(fsh==fsb) {
      fsb -= (float)1e-1;
   }
   dyn = (float)256. / (fsh - fsb);

   for(j=y1;j<=y2;j++) {
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
         base = j*naxis1+i;
         colorIndex = (unsigned char)min(max(((float)pix[base]-fsb)*dyn,0),255);
         pdest[ydest+xdest][0] = palette[0][colorIndex];
         pdest[ydest+xdest][1] = palette[1][colorIndex];
         pdest[ydest+xdest][2] = palette[2][colorIndex];
      }
   }
}

/**
 * getPixelsVisu
 * retourne les intensitès de la zone (x1,y1)-(x2,y2)
 * dans le format compatible avec la visu : 4 octets par pixel ( rouge, vert, bleu, inutilisè)
 * en tenant compte des mirrois X ou Y èventuels, des seuils haut et bas et de la palette de couleurs
 *
 * @param x1       abcisse du coin bas gauche de la zone
 * @param y1       ordonnee du coin bas gauche de la zone
 * @param x2       abcisse du coin haut, doit de la zone
 * @param x2       ordonnèe du coin haut, doit de la zone
 * @param mirrorX  0: pas de miroir horizontal, 1: miroir horizontal
 * @param mirrorY  0: pas de miroir vertical, 1 : miroir vertical
 * @param cuts     tableau des 6 seuils : haut rouge, bas rouge, haut vert bas vert , haut bleu , bas bleu
 * @param palette  palette de couleur (256 valeurs dans un tableau de 256 octets)
 * @param ptr      pointeur de pixels 32 bits sous la forme RGBARGBARGBA...
 *
 * @return void
 */

void CPixelsGray::getPixelsVisu( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY,
            float *cuts,
            unsigned char *palette[3], unsigned char *ptr)
{
   int i, j;
   int orgww, orgwh;                // original window width, height
   float dyn;
   float fsh = (float) cuts[0];
   float fsb = (float) cuts[1];
   long base;
   int xdest, ydest;
   unsigned char colorIndex;
   unsigned int *mypal;  // palette de mots int32
   unsigned int *myptr;  // pointeur courant sur l'image a construire

   myptr = (unsigned int*)ptr;

   orgww = x2 - x1 + 1;  // Largeur de la fenetre au depart
   orgwh = y2 - y1 + 1;  // Hauteur ...

   // Acceleration de la fonction de visualisation: creation d'une image couleur
   // dont chaque pixel fait 32 bits au lieu de 24. Cela permet d'affecter le niveau
   // de couleur en une seule operation 32 bits (au lieu de 3 8 bits). Une palette de
   // valeurs int32 est prealablement calculee a partir des trois palettes.
   // Egalement quelques optimisations pour sortir les calculs fixes des boucles.
   if(fsh==fsb) {
      fsb -= (float)1e-1;
   }
   dyn = (float)256. / (fsh - fsb);

   // Construction de la palette 32 bits
   mypal = (unsigned int*) malloc(256*4);
   for(i=0;i<256;i++) {
      mypal[i] = (palette[2][i]<<16)+(palette[1][i]<<8)+(palette[0][i]<<0);
   }

   for(j=y1;j<=y2;j++) {
      if(mirrorY == 0) {
         ydest = ((y2-y1) - (j -y1) )*orgww ;
      } else {
         ydest = (j - y1)*orgww ;
      }
      base = j*naxis1;
      if(mirrorX == 0) {
         for(i=x1;i<=x2;i++) {
            xdest = i-x1;
            colorIndex = (unsigned char)min(max(((float)pix[base+i]-fsb)*dyn,0),255);
            myptr[ydest+xdest] = mypal[colorIndex];
		 }
      } else {
         for(i=x1;i<=x2;i++) {
			xdest = x2 - i;
            colorIndex = (unsigned char)min(max(((float)pix[base+i]-fsb)*dyn,0),255);
            myptr[ydest+xdest] = mypal[colorIndex];
		 }
      }
   }
   free(mypal);
}


int CPixelsGray::getWidth(void) {
   return naxis1;
}


int CPixelsGray::GetPlanes(void) {
   return 1;
}



//---------------------------------------------------------------------
/**
 * IsPixelsReady
 *    informe si une image est presente dans le buffer
 *
 * Parameters:
 *    none
 * Results:
 *    returns 1 if pixels are ready, otherwise 0.
 * Side effects:
 *    verifie si une image est chargèe c.a.d si la taille est superieure a 1x1
 */
int CPixelsGray::IsPixelsReady(void) {
   if( naxis1 != 0 && naxis2 != 0 ) {
      return 1;
   } else {
      return 0;
   }
}

void CPixelsGray::Log(float coef, float offset)
{
   int msg,datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[128];;
   sprintf(s,"LOG coeff=%f offsetlog=%f",coef,offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}

void CPixelsGray::MergePixels(TColorPlane , int )
{
   throw CError(ELIBSTD_NOT_IMPLEMENTED);
}


void CPixelsGray::MirX()
{
   int msg, datatype;
   char * s;


   datatype = TFLOAT;
   s = new char[32];
   strcpy(s,"INVERT mirror");
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}

/*
void CPixelsGray::MirY()
{
   int msg, datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[32];
   strcpy(s,"INVERT flip");
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}
*/


void CPixelsGray::NGain(float gain)
{
   int msg;
   int datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[128];
   sprintf(s,"NORMGAIN normgain_value=%f",gain);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}

void CPixelsGray::NOffset(float offset)
{
   int msg, datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[128];
   sprintf(s,"NORMOFFSET normoffset_value=%f",offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}

void CPixelsGray::Offset(float offset)
{
   int msg, datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[512];

   sprintf(s,"OFFSET offset=%f",offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);

}

void CPixelsGray::Opt(char *dark, char *offset)
{
   int msg, datatype;
   // "s" doit etre suffisamment grande pour contenir les noms complets des deux fichiers.
   char s[2048];

   datatype = TFLOAT;
   sprintf(s,"OPT \"dark=%s\" \"bias=%s\"",dark,offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   if(msg) throw CErrorLibtt(msg);
}

void CPixelsGray::Rot(float x0, float y0, float angle)
{
   int msg, datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[128];
   sprintf(s,"ROT x0=%f y0=%f angle=%f",x0,y0,angle);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}

void CPixelsGray::Sub(char *filename, float offset)
{
   int msg, datatype;
   char * s;

   datatype = TFLOAT;
   s = new char[1024];;
   sprintf(s,"SUB \"file=%s\" offset=%f",filename,offset);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}

void CPixelsGray::Sub(CPixels * subPixels, float offset) {

   if ( this->getWidth() !=  subPixels->getWidth() && this->getHeight() != subPixels->getHeight() ) {
      throw CError( "Image size (%d,%d) is different from current image size (%d,%d)",
         subPixels->getWidth(), subPixels->getHeight(), this->getWidth(), this->getHeight() );
   }

   if ( subPixels->GetPlanes() != this->GetPlanes() ) {
      throw CError( "Image planes (%d) is different from current image plane(%d)",
         subPixels->GetPlanes(), this->GetPlanes());
   }

   TYPE_PIXELS  * pixPtr = this->pix;
   TYPE_PIXELS  * subPrt = NULL;
   subPixels->GetPixelsPointer(&subPrt);
   for(int k = 0 ; k <this->naxis1*this->naxis2 ; k++ ) {
      *(pixPtr++) += (TYPE_PIXELS)offset - *(subPrt++) ;
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

void CPixelsGray::UnifyBg()
{
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
   int *columns, *lines, colIndex = 0, lineIndex = 0;


   // je calcule la taille des fenetres
   wRect = naxis1 / nbCol;
   if ( wRect < 50 ) wRect = 50;
   hRect = naxis2 / nbLine;
   if ( hRect < 50 ) hRect = 50;

   // je cree la matrice du fond de ciel
   matbg = (double*)malloc(naxis1*naxis2 * sizeof(double));
   if (matbg==NULL) throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);

   // raz matrice
   for(x=0; x < naxis1 ; x++) {
      for(y=0; y < naxis2 ; y++) {
         matbg[y*naxis1+ x] = 0;
      }
   }

   // lines des centres des fenetres
   lines = (int*)malloc(nbLine * sizeof(int));
   if (lines==NULL) throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);

   // columns des centres des fenetres
   columns = (int*)malloc(nbCol * sizeof(int));
   if (columns==NULL) throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);


   // -----------------------------------------------------------
   // je calcule le fond du ciel de chaque fenetre (x,y)(x+wRect,y+hRect)
   // -----------------------------------------------------------
   colIndex=0;
   for(x1=0; x1 < naxis1 ; x1 +=wRect) {
      lineIndex=0;
      for(y1=0; y1 < naxis2 ; y1 +=hRect) {

         // calcul de coordonnèes de la fenetre
         if( x1 + wRect < naxis1) {
            x2 = x1 + wRect;
         } else {
            // cas du dernier rectangle è droite
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
         pixel = (TYPE_PIXELS*)malloc(naxis11*naxis22 * sizeof(TYPE_PIXELS));
         if (pixel==NULL) throw CError(ELIBSTD_NO_MEMORY_FOR_PIXELS);

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
         if(msg) throw CErrorLibtt(msg);

         // je place la valeur du fond du ciel dans le pixel au centre du rectangle
         matbg[yc*naxis1+ xc ] = dbgmean;

         // je cumule les nbgmean pour calculer la moyenne globale plus tard
         sumBgmean +=dbgmean;
         nbBgmean++;

         // je memorise les coordonnèes du centre le fenetre
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
   // je calcule le fond du ciel pour les points intermèdiaires
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
            y1 = 0 ;          // première fenetre en haut
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
            x1 = 0 ;          // première fenetre a gauche
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
   // je soustrait le fond du ciel è l'image originale
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

   free(matbg);

}


void CPixelsGray::Unsmear(float coef)
{
   int msg, datatype;
   char * s;

   datatype = TFLOAT;
   s = new char [128];
   sprintf(s,"UNSMEARING unsmearing=%f",coef);
   msg = libtt_main(TT_PTR_IMASERIES,7,&pix,&datatype,&naxis1,&naxis2,&pix,&datatype,s);
   delete[] s;
   if(msg) throw CErrorLibtt(msg);
}

void CPixelsGray::Window(int x1, int y1, int x2, int y2)
{
   int temp;
   int x, y, diff_x, diff_y;
   TYPE_PIXELS *out;

   // verification des donnees
   if ((x1 < 0) || (x2 < 0) || (x1 > naxis1-1) || (x2 > naxis1-1))
   {
         throw CError( ELIBSTD_X1X2_NOT_IN_1NAXIS1);
   }
   if ((y1 < 0) || (y2 < 0) || (y1 > naxis2-1) || (y2 > naxis2-1))
   {
         throw CError( ELIBSTD_Y1Y2_NOT_IN_1NAXIS2);
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

   /* --- initialisation ---*/
   out = (TYPE_PIXELS*)malloc(diff_x*diff_y * sizeof(TYPE_PIXELS));
   if( out == NULL ) {
      throw CError(  ELIBSTD_NO_MEMORY_FOR_PIXELS);
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
   free(pix);
   pix = out;
}




