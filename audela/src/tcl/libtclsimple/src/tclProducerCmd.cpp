///@file tclProducerCmd.h
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
// $Id: tclProducerCmd.cpp 13163 2016-02-13 18:08:50Z michelpujol $

#include <sstream>  // pour ostringstream
#include <string>
using namespace ::std;
#include <stdexcept>
#include <cstring>
#include <tcl.h>
#include <abcommon.h>   // pour CError
#include <tclcommon.h>  // pour copyArg
using namespace ::tclcommon;
#include "absimple.h"


//
// lance une acquisition
//
int cmdProducerAcq(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;
   try {
      if(argc < 2 || argc > 3) {
         throw abcommon::CError( abcommon::CError::ErrorInput, "Usage: %s %s", argv[0], argv[1]);
      } 

      absimple::IProducer* producer = (absimple::IProducer*) clientData;

      if(argc != 3) {
         const char *usage = "Usage: producer1 acq exptime";
         Tcl_SetResult(interp,  (char *)usage, TCL_VOLATILE);
         result= TCL_ERROR;
      } else {
         producer->acq( copyArgToInt(interp,argv[2], "exptime"));  
         Tcl_ResetResult(interp);
         result= TCL_OK;
      }      

   } catch(std::exception &e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}


int cmdProducerWaitMessage(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;
   try {
      if(argc < 2 || argc > 2) {
         throw abcommon::CError( abcommon::CError::ErrorInput, "Usage: %s %s", argv[0], argv[1]);
      } 

      absimple::IProducer* producer = (absimple::IProducer*) clientData;

      int code= producer->waitMessage(); 
      Tcl_SetObjResult(interp, Tcl_NewIntObj(code));
      result= TCL_OK;

   } catch(std::exception &e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}


//=============================================================================
//  liste des commandes
//=============================================================================
static tclcommon::SCmditem cmdlist[] = {
   {"acq", (Tcl_CmdProc *)cmdProducerAcq},
   {"waitMessage", (Tcl_CmdProc *)cmdProducerWaitMessage},
   {"", NULL}
};


//=============================================================================
//  execute la commande TCL contenue dans argv[1]
//
//=============================================================================
int tclProducerCmd(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   
   // je verifie que argv[1] est présent
   if(argc < 2 ) {
      string message;
      getCommandUsage(argv, cmdlist, message);
      Tcl_SetResult(interp, (char *) message.c_str(),TCL_VOLATILE);
      return TCL_ERROR;
   }

   // j'execute la commande contenue dans argv[1]
   int result = TCL_OK;
   tclcommon::SCmditem* cmd;
   for (cmd = cmdlist; cmd->cmd != NULL; cmd++) {
      if (strcmp(cmd->cmd, argv[1]) == 0) {
         result = (*cmd->func) (clientData, interp, argc, argv);
         break;
      }
   }

   // j'affiche un message d'aide si la commande n'est par trouvée
   if (cmd->cmd == NULL) {
      string message;
      getCommandUsage(argv, cmdlist, message);
      Tcl_SetResult(interp, (char *) message.c_str(),TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}
