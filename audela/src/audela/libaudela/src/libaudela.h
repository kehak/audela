/* audela.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#pragma once

#ifdef WIN32
   #ifdef LIBAUDELA_EXPORTS
      #define LIBAUDELA_API __declspec( dllexport )
   #else
      #define LIBAUDELA_API __declspec( dllimport )
   #endif
#else
   #define LIBAUDELA_API
#endif

typedef float TYPE_PIXELS;

typedef enum { CLASS_GRAY, CLASS_RGB, CLASS_3D, CLASS_VIDEO, CLASS_UNKNOWN } TPixelClass;
typedef enum { FORMAT_BYTE, FORMAT_SHORT, FORMAT_USHORT, FORMAT_FLOAT, FORMAT_UNKNOWN } TPixelFormat;
typedef enum { COMPRESS_NONE, COMPRESS_RGB, COMPRESS_I420, COMPRESS_JPEG, COMPRESS_RAW, COMPRESS_UNKNOWN } TPixelCompression;
typedef enum { PLANE_GREY, PLANE_RGB, PLANE_R, PLANE_G, PLANE_B, PLANE_UNKNOWN } TColorPlane;


class IBuffer {
public:
   
   //Reference
   virtual void reference()=0;
   virtual void unreference()=0;
   virtual int getReference()=0;

   // pixels
   virtual int  getWidth()=0;
   virtual int  getHeight()=0;
   virtual int  getNaxis()=0;
   virtual void getPix(int *plane, TYPE_PIXELS *val1,TYPE_PIXELS *val2,TYPE_PIXELS *val3,int x, int y)=0;
   virtual void getPixelsPointer(TYPE_PIXELS **ppixels)=0;
   virtual void getPixelsVisu( int x1,int y1,int x2, int y2,
            int mirrorX, int mirrorY, float *cuts,
            unsigned char *palette[3], unsigned char *ptr)=0;
   virtual void setPix(TColorPlane plane, TYPE_PIXELS,int,int)=0;
   virtual void setPixels(int width, int height, int plane, float * pixels, int reverseX, int reverseY)=0;


   // keywords
   virtual bool hasKeyword(const char *keywordName)=0;
   virtual int          getKeywordDataType(const char *keywordName)=0;
   virtual const char * getKeywordComment(const char *keywordName)=0;
   virtual const char * getKeywordUnit(const char *keywordName)=0;
   virtual const char * getKeywordStringValue(const char *keywordName)=0;
   virtual double       getKeywordDoubleValue(const char *keywordName)=0;
   virtual float        getKeywordFloatValue(const char *keywordName)=0;
   virtual int          getKeywordIntValue(const char *keywordName)=0;
   virtual void setKeyword(const char *nom, double doubleValue, const char *comment, const char *unit)=0;
   virtual void setKeyword(const char *nom, float floatValue, const char *comment, const char *unit)=0;
   virtual void setKeyword(const char *nom, int   intValue, const char *comment, const char *unit)=0;
   virtual void setKeyword(const char *nom, const char *stringValue, const char *comment, const char *unit)=0;
   virtual void deleteKeyword(const char *keywordName)=0;
   virtual void FreeBuffer(int dontKeepKeywords)=0;
   
   //file
   virtual void loadFile(const char *filename, int iaxis3)=0;
   virtual void saveFits(const char *filename, int iaxis3)=0;


};

class IFitsKeywords {

};

///////////////////////////////////////////////////////////////
// point d'entree de la librairie
//
///////////////////////////////////////////////////////////////
class ILibaudela {
public:
   static LIBAUDELA_API IBuffer* findBuffer(int bufNo);
   static LIBAUDELA_API IBuffer* createBuffer();
   static LIBAUDELA_API void     deleteBuffer(IBuffer* buffer);

};

class IError {
public:
   virtual const char * gets(void) const throw()=0;
};


// codes d'erreur
#define ELIBSTD_BUF_EMPTY                  -1
#define ELIBSTD_NO_MEMORY_FOR_PIXELS       -2
#define ELIBSTD_NO_MEMORY_FOR_KWDS         -3
#define ELIBSTD_NO_MEMORY_FOR_ASTROMPARAMS -4
#define ELIBSTD_NO_KWDS                    -5
#define ELIBSTD_NO_NAXIS1_KWD              -6
#define ELIBSTD_NO_NAXIS2_KWD              -7
#define ELIBSTD_DEST_BUF_NOT_FOUND         -8
#define ELIBSTD_NO_ASTROMPARAMS            -9
#define ELIBSTD_NO_MEMORY_FOR_LUT          -10
#define ELIBSTD_CANNOT_CREATE_BUFFER       -11
#define ELIBSTD_CANT_GETORCREATE_TKIMAGE   -12
#define ELIBSTD_NO_ASSOCIATED_BUFFER       -13
#define ELIBSTD_NO_TKPHOTO_HANDLE          -14
#define ELIBSTD_NO_MEMORY_FOR_DISPLAY      -15
#define ELIBSTD_WIDTH_POSITIVE             -16
#define ELIBSTD_X1X2_NOT_IN_1NAXIS1        -17
#define ELIBSTD_HEIGHT_POSITIVE            -18
#define ELIBSTD_Y1Y2_NOT_IN_1NAXIS2        -19
#define ELIBSTD_KWD_NOT_FOUND              -20

#define ELIBSTD_PALETTE_CANT_FIND_FILE     -30
#define ELIBSTD_PALETTE_MALFORMED_FILE     -31
#define ELIBSTD_PALETTE_NOTCOMPLETE        -32
#define ELIBSTD_SUB_WINDOW_ALREADY_EXIST   -33
#define ELIBSTD_PIXEL_FORMAT_UNKNOWN       -34
#define ELIBSTD_CANT_OPEN_FILE				 -35
#define ELIBSTD_NO_NAXIS_KWD               -36

#define ELIBSTD_LIBTT_ERROR    				 -50

#define ELIBSTD_NOT_IMPLEMENTED				 -51

// format des fichiers FITS
#ifndef BYTE_IMG
#define BYTE_IMG      8  /* BITPIX code values for FITS image types */
#define SHORT_IMG    16
#define LONG_IMG     32
#define FLOAT_IMG   -32
#define DOUBLE_IMG  -64
			 /* The following 2 codes are not true FITS         */
			 /* datatypes; these codes are only used internally */
			 /* within cfitsio to make it easier for users      */
			 /* to deal with unsigned integers.                 */
#define USHORT_IMG   20
#define ULONG_IMG    40
#endif