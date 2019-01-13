///@file argto.cpp
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

#include <string>
#include <cstring>
#include <stdexcept>
#include "abcommon.h"
using namespace abcommon;

///@brief  convert argv to boolean ( "1" , "0" , "true" , "false" )
//
bool abcommon::argumentToBool(const char *argv, const char * paramName) {
   if (strlen(argv) == 0) {
      throw CError(CError::ErrorInput, "%s is empty", paramName);
   }

   if (strcmp(argv, "1") == 0 || strcmp(argv, "true") == 0) {
      return true;
   } else if (strcmp(argv, "0") == 0 || strcmp(argv, "false") == 0) {
      return false;
   } else {
      throw CError(CError::ErrorInput, "%s=%s is not boolean", paramName, argv);
   }
}

// convert argv to double
//
double abcommon::argumentToDouble(const char *argv, const char * paramName) {
   if (strlen(argv) == 0) {
      throw CError(IError::ErrorInput, "%s is empty", paramName);
   }

   try {
      return std::stod(argv);
   } catch (std::invalid_argument &ex) {
      //throw std::invalid_argument(abcommon::utils_format(""));
      throw CError(CError::ErrorInput, "%s=%s is not a double. error=%s", paramName, argv, ex.what());
   }
}

// convert argv to float 
//
float abcommon::argumentToFloat(const char *argv, const char * paramName) {
   if (strlen(argv) == 0) {
      throw CError(IError::ErrorInput, "%s is empty", paramName);
   }

   try {
      return std::stof(argv);
   }
   catch (std::invalid_argument &ex) {
      throw CError(CError::ErrorInput, "%s=%s is not a float. error=%s", paramName, argv, ex.what());
   }
}

///@brief  convert argv to integer 
//
int abcommon::argumentToInt(const char *argv, const char * paramName) {
   if (strlen(argv) == 0) {
      throw CError(CError::ErrorInput, "%s is empty", paramName);
   }

   try {
      return std::stoi(argv);
   } catch (std::invalid_argument &ex) {
      throw CError(CError::ErrorInput, "%s=%s is not integer. error=%s", paramName, argv, ex.what());
   }
}

///@brief  convert argv to long  
//
long abcommon::argumentToLong(const char *argv, const char * paramName) {
   if (strlen(argv) == 0) {
      throw CError(CError::ErrorInput, "%s is empty", paramName);
   }

   try {
      return std::stol(argv);
   }
   catch (std::invalid_argument &ex) {
      throw CError(CError::ErrorInput, "%s=%s is not long. error=%s", paramName, argv, ex.what());
   }
}

///@brief  convert argv to long double   
//
long double abcommon::argumentToLongDouble(const char *argv, const char * paramName) {
   if (strlen(argv) == 0) {
      throw CError(CError::ErrorInput, "%s is empty", paramName);
   }

   try {
      return std::stold(argv);
   }
   catch (std::invalid_argument &ex) {
      throw CError(CError::ErrorInput, "%s=%s is not longdouble. error=%s", paramName, argv, ex.what());
   }
}

///@brief  convert argv to long double     
//
long long abcommon::argumentToLongLong(const char *argv, const char * paramName) {
   if (strlen(argv) == 0) {
      throw CError(CError::ErrorInput, "%s is empty", paramName);
   }

   try {
      return std::stoll(argv);
   }
   catch (std::invalid_argument &ex) {
      throw CError(CError::ErrorInput, "%s=%s is not longlong. error=%s", paramName, argv, ex.what());
   }
}



