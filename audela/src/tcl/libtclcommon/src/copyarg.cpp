///@file copyarg.h
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
// $Id: $

#include <sstream>
#include <algorithm>
#include <cstring>
#include <abcommon.h>
using namespace ::abcommon;

#include <tclcommon.h>


void ::tclcommon::getCommandUsage(const char *argv[], tclcommon::SCmditem* cmdlist, std::string &message){
      std::ostringstream stream;
      stream << argv[0] << " " << argv[1] << ": sub-command not found among";
      int k = 0;
      while (cmdlist[k].cmd != NULL) {
         stream <<" " << cmdlist[k].cmd;
         k++;
      }
      message = stream.str();
}


//**************************************************************************
// copy argv to double               
//**************************************************************************
double ::tclcommon::copyArgToDouble(Tcl_Interp *interp, const char *argv, const char * paramName) {
   double value;
   if(strlen(argv) == 0 ||Tcl_GetDouble(interp, argv,&value)!=TCL_OK) {
      throw CError( CError::ErrorInput, "%s=%s is not a double", paramName, argv);
   }
   return value;
}

//**************************************************************************
// copy argv to int               
//**************************************************************************
int ::tclcommon::copyArgToInt(Tcl_Interp *interp, const char *argv, const char * paramName) {
   int value;
   if(strlen(argv) == 0  || Tcl_GetInt(interp, argv,&value)!=TCL_OK) {
      throw CError( CError::ErrorInput, "%s=%s is not an integer", paramName, argv);
   }
   return value;
}

//**************************************************************************
// copy argv to bool               
//**************************************************************************
bool ::tclcommon::copyArgToBoolean(Tcl_Interp *interp, const char *argv, const char * paramName) {
   int value;
   if(strlen(argv) == 0  || Tcl_GetBoolean(interp, argv, &value)!=TCL_OK) {
      throw CError( CError::ErrorInput, "%s=%s is not a boolean", paramName, argv);
   }
   return (value == 1);
}
