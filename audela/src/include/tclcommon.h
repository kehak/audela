///@file tclcommon.h
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author Michel Pujol
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
// $Id: tclcommon.h 13202 2016-02-15 20:08:21Z michelpujol $

#pragma once

#include <tcl.h>
#include <string>
#include <memory>

namespace tclcommon {

   typedef struct  {
      const char *cmd;
      Tcl_CmdProc *func;
   } SCmditem;


   // utilitaires de conversion des const char* argv  en variable C
   int      copyArgToInt(Tcl_Interp *interp, const char *argv, const char * paramName);
   double   copyArgToDouble(Tcl_Interp *interp, const char *argv, const char * paramName);
   bool     copyArgToBoolean(Tcl_Interp *interp, const char *argv, const char * paramName);


   void getCommandUsage(const char *argv[], tclcommon::SCmditem* cmdList, std::string &message);

   std::auto_ptr<std::string>  getLibraryPath(Tcl_Interp *interp);
   //std::auto_ptr<std::string>  getLibraryName(Tcl_Interp *interp, const char* shortName);

} // namespace end


