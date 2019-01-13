/* CLink.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>     // pour timeval
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>    // va_start
#include <string>
#include <cstring>
#include <sstream>  // pour ostringstream

#include <ltdl.h>

//#if defined(WIN32)
//void  gettimeofday ( struct timeval * timeval, struct timezone * );
//#else 
//#include <sys/time.h>   // gettimeofday()
//#endif

#include <abcommon.h>
using namespace abcommon;
#include "CLink.h"


CLink::CLink() {
   
}

CLink::~CLink() {
   //this->close();
}

void CLink::init(const char* , const char * libraryFileName, int , const char * []) {

   this->libraryName = libraryFileName;
}

const char * CLink::getLibraryName() {
   return libraryName.c_str();
}
