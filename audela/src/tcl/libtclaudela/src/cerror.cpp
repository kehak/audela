/* cerrors.cpp
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

//=====================================================================
//
//  CError , CErrorLibtt
//
//=====================================================================

#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include "tclaudela.h"
#include "cerror.h"
#include "libtt.h"            // for TFLOAT, LONG_IMG, TT_PTR_...

#ifdef WIN32
#define strdup _strdup
#endif


//------------------------------------------------------------------------------
// Messages d'erreur.
//
const char* message(int error)
{
   switch(error) {
      case ELIBSTD_BUF_EMPTY :
         return (char*)"buffer is empty";
      case ELIBSTD_NO_MEMORY_FOR_PIXELS :
         return (char*)"not enough memory for pixel allocation";
      case ELIBSTD_NO_MEMORY_FOR_KWDS :
         return (char*)"not enough memory for keywords allocation";
      case ELIBSTD_NO_MEMORY_FOR_ASTROMPARAMS :
         return (char*)"not enough memory for astrometric parameters allocation";
      case ELIBSTD_NO_NAXIS_KWD :
         return (char*)"image does not have mandatory FITS NAXIS1 keyword";
      case ELIBSTD_NO_NAXIS1_KWD :
         return (char*)"image does not have mandatory FITS NAXIS1 keyword";
      case ELIBSTD_NO_NAXIS2_KWD :
         return (char*)"image does not have mandatory FITS NAXIS2 keyword";
      case ELIBSTD_DEST_BUF_NOT_FOUND :
         return (char*)"destination buffer does not exist";
      case ELIBSTD_NO_ASTROMPARAMS :
         return (char*)"can not find astrometric parameters";
      case ELIBSTD_NO_MEMORY_FOR_LUT :
         return (char*)"not enough memory for LUT allocation";
      case ELIBSTD_CANNOT_CREATE_BUFFER :
         return (char*)"visu can not create buffer";
      case ELIBSTD_CANT_GETORCREATE_TKIMAGE :
         return (char*)"visu can not get or create TkImage";
      case ELIBSTD_NO_ASSOCIATED_BUFFER :
         return (char*)"visu has no associated buffer";
      case ELIBSTD_NO_TKPHOTO_HANDLE :
         return (char*)"can not find TkPhotoHandle";
      case ELIBSTD_NO_MEMORY_FOR_DISPLAY :
         return (char*)"not enough memory for image transformation";
      case ELIBSTD_WIDTH_POSITIVE :
         return (char*)"width must be positive";
      case ELIBSTD_X1X2_NOT_IN_1NAXIS1 :
         return (char*)"x1 and x2 must be contained between 1 and naxis1";
      case ELIBSTD_HEIGHT_POSITIVE :
         return (char*)"height must be positive";
      case ELIBSTD_Y1Y2_NOT_IN_1NAXIS2 :
         return (char*)"y1 and y2 must be contained between 1 and naxis2";
      case ELIBSTD_PALETTE_CANT_FIND_FILE:
         return (char*)"can't find palette file";
      case ELIBSTD_PALETTE_MALFORMED_FILE:
         return (char*)"the palette file doesn't contain 3 numbers per line";
      case ELIBSTD_PALETTE_NOTCOMPLETE:
         return (char*)"the palette file doesn't contain 256 entries";
      case ELIBSTD_NO_KWDS:
         return (char*)"image does not contain any keyword";
      case ELIBSTD_KWD_NOT_FOUND:
         return (char*)"keyword not found";
      case ELIBSTD_CANT_OPEN_FILE:
	   	return (char*)"can't open file";
      case ELIBSTD_NOT_IMPLEMENTED:
	   	return (char*)"not implemented";
      case EFITSKW_NO_SUCH_KWD:
	   	return (char*)"no such keyword";
      default :
         return (char*)"unknown error code";
   }
}

//=====================================================================
//
//  class CError
//
//=====================================================================

CErrorAudela::CErrorAudela(const int errnum) throw(){
   strcpy(buf, message(errnum));
}


//=====================================================================
//
//  class CErrorLibtt
//
//=====================================================================

CErrorLibtt::CErrorLibtt(const int errorNum) throw(){
   char errorName[1024];
   char errorDetail[1024];
   //libtt_main(TT_ERROR_MESSAGE,2,&errorNum,errorName);
   //libtt_main(TT_LAST_ERROR_MESSAGE,1,errorDetail); 
   sprintf(buf,"Libtt error #%d:%s Detail=%s",errorNum, errorName,errorDetail); 
}
