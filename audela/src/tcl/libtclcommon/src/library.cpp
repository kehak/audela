///@file library.cpp
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author : Alain KLOTZ <alain.klotz@free.fr>
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
// $Id:  $

#include <sstream>
#include <memory>      // pour auto_ptr
#include <algorithm>
using namespace ::std;
#include <abcommon.h> // pour CError
using namespace ::abcommon;
#include <tclcommon.h>


auto_ptr<string>  tclcommon::getLibraryPath(Tcl_Interp *interp){
   // je recupere le nom du repertoire des DLL
   std::ostringstream ligne ;
   ligne << "file nativename \"" << Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY) << "\"";
   if ( Tcl_Eval(interp, ligne.str().c_str() ) == TCL_ERROR) {
      throw CError(CError::ErrorInput, "%s command=", Tcl_GetStringResult(interp), ligne.str().c_str());
   }

   return auto_ptr<string>( new string(Tcl_GetStringResult(interp)));
}

/// retourn nom du fichier de la librairie
//
// @param shorname
// @return library file name 
//std::auto_ptr<std::string> tclcommon::getLibraryName(Tcl_Interp *interp, const char* shortName){
//
//   // je constitue le nom de la DLL  "libab<shorName>.dll" 
//   std::ostringstream ligne ;
//   ligne << "set aa \"libab" << shortName << "[info sharedlibextension]\"";
//   if ( Tcl_Eval(interp, ligne.str().c_str() ) == TCL_ERROR) {
//      throw CError(CError::ErrorInput, "%s command=", Tcl_GetStringResult(interp), ligne.str().c_str());
//   }
//   return auto_ptr<string>( new string(Tcl_GetStringResult(interp)));
//}

