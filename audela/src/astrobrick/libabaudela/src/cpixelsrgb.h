/* cpixelsrgb.h
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

#ifndef __CPIXELSRBGH__
#define __CPIXELSRGBH__

#include "cpixels.h"

typedef  short TYPE_PIXELS_RGB;


class CPixelsRgb : public CPixels
{
public:
   CPixelsRgb(int width, int height, TPixelFormat pixelFormat, void * pixels, int reverseX, int reverseY);
   CPixelsRgb(int width, int height, TPixelFormat pixelFormat, void *pixelsR, void *pixelsG, void *pixelsB);
   CPixelsRgb(int naxis1, int naxis2, int pixelSize, int offset[4], int pitch, unsigned char * pixels);
	virtual ~CPixelsRgb();

   void Add(char *filename, float offset);
   void Autocut(double *phicut,double *plocut,double *pmode);
   void BinX(int x1, int x2, int width);
   void BinY(int y1, int y2, int height);
   void Clipmax(double value);
   void Clipmin(double value);
   void Div(char *filename, float constante);
   int  getHeight(void);
   int  GetPlanes(void);
   int  getWidth(void);
   void getPix(int *plane, TYPE_PIXELS *val1,TYPE_PIXELS *val2,TYPE_PIXELS *val3,int x, int y);
   void getPixelsPointer(TYPE_PIXELS **pixels);
   void getPixels(TYPE_PIXELS_RGB *pixelsR, TYPE_PIXELS_RGB *pixelsG, TYPE_PIXELS_RGB *pixelsB);
   // Yassine
   // void getPixels(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, int pixels);
   // void getPixelsReverse(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, int pixels);
   void getPixels(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, void* pixels);
   void getPixelsReverse(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, void* pixels);
   void getPixelsRgb( int x1,int y1,int x2, int y2,
                  int mirrorX, int mirrorY, float *cuts,
                  unsigned char *palette[3], unsigned char *ptr);
   void getPixelsVisu( int x1,int y1,int x2, int y2,
                  int mirrorX, int mirrorY, float *cuts,
                  unsigned char *palette[3], unsigned char *ptr);   
   bool isPixelsReady(void);
   void Log(float coef, float offset);
   void mergePixels(TColorPlane plane, int pixels);
   void MirX();
   /*void MirY();*/
   void NGain(float gain);
   void NOffset(float offset);
   void Offset(float offset);
   void Opt(char *dark, char *offset);
   void Rot(float x0, float y0, float angle);
   void setPix(TColorPlane plane,TYPE_PIXELS val,int x, int y);
   void Sub(char *filename, float offset);
   void Sub(CPixels * subPixels, float offset);
   void Unsmear(float coef);
   void Window(int x1, int y1, int x2, int y2);
   void UnifyBg();

   TPixelClass getPixelClass() ;

protected:
	CPixelsRgb();
private:
   TYPE_PIXELS_RGB *pix;
   int naxis1;
   int naxis2;
   int naxis;

};

#endif // __CPIXELSRGBH__
