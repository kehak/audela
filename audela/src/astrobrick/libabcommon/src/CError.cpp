///@file CError.cpp
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author : Michel PUJOL
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// $Id:$


//=====================================================================
//
//  CError 
//
//=====================================================================

#include <stdarg.h>   // va_list, va_start, va_arg, va_end
#include <stdio.h>    // pour vsnprintf
#include <abcommon.h> // pour CError

/// constructeur par defaut protected (accessible uniquement par les classes filles)
abcommon::CError::CError() {
   errorCode = 0; 
   buf[0] = 0;
}

abcommon::CError::CError(IError::ErrorCode code, const char *f, ...) throw()
{
   errorCode = code;

	va_list val;
	va_start(val, f);
   vsnprintf(buf,2046,f,val);
   va_end(val);
   buf[2047] = 0;
}

abcommon::CError::CError(int code, const char *f, ...) throw ()
{
   errorCode = code;
	va_list val;
	va_start(val, f);
   vsnprintf(buf,2046,f,val);
   va_end(val);
   buf[2047] = 0;

}

abcommon::CError::~CError() throw() {
   
}


const char* abcommon::CError::getMessage() {
   return buf;
}

unsigned long abcommon::CError::getCode(void) {
   return errorCode;
}

// interface C
int  abcommon::lastErrorCode;
std::string abcommon::lastErrorMessage;

const char* abcommon::getLastErrorMessage() {
   //return abcommon::lastErrorMessage.c_str();
   return lastErrorMessage.c_str();
}

int abcommon::getLastErrorCode() {
   return lastErrorCode;
}

void abcommon::setLastError(abcommon::IError &ex) {
   //return abcommon::lastErrorMessage.c_str();
   lastErrorCode = ex.getCode();
   lastErrorMessage = ex.getMessage();
}




