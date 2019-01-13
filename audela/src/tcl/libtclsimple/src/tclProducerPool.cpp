///@file tclProducerPool.h
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
// $Id: tclProducerPool.cpp 13163 2016-02-13 18:08:50Z michelpujol $

#include <sstream>  // pour ostringstream
#include <string>
#include <cstring>
#include <tcl.h>
#include <abcommon.h>
using namespace ::abcommon;
#include <tclcommon.h>
using namespace ::tclcommon;
#include <absimple.h>
#include "tclProducerPool.h" 
#include "tclProducerCmd.h"   

///@brief cree une instance Producer
//   
// @return retourne producerNo
//
int tclProducerCreate(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 1) {
         throw CError(CError::ErrorInput, "Usage: %s", argv[0]);
      } 
      // je cree l'instance C++
      absimple::IProducer* producer = absimple::IProducerPool::createInstance();
      int producerNo = producer->getNo();
      // je cree la commande TCL
      std::ostringstream instanceName ;
      instanceName << "producer" << producerNo;
      Tcl_CreateCommand(interp, instanceName.str().c_str(), (Tcl_CmdProc *)tclProducerCmd, (ClientData)producer,(Tcl_CmdDeleteProc *)NULL);

      // je retourne producerNo
      Tcl_SetObjResult(interp, Tcl_NewIntObj(producerNo));
      result = TCL_OK; 
   } catch(std::exception e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

///@brief supprime un producer
// 
// @param argc
// @param argv arv[1] contient le numero de l'instance a supprimer
//
int tclProducerDelete(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 2) {
         throw CError(CError::ErrorInput, "Usage: %s producerNo", argv[0]);
      } 
      int producerNo = copyArgToInt(interp, argv[1], "producerNo");
      // je supprime la commande TCL
      std::ostringstream instanceName ;
      instanceName << "producer" << producerNo;
      Tcl_DeleteCommand(interp,instanceName.str().c_str());
      // je supprime l'instance C++
      absimple::IProducer* producer = absimple::IProducerPool::getInstance(producerNo);
      absimple::IProducerPool::deleteInstance(producer);
      Tcl_ResetResult(interp);
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}


///@brief liste des producerNo
//   
// @return la liste des producerNo
//
int tclProducerList(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 1) {
         throw CError(CError::ErrorInput, "Usage: %s", argv[0]);
      } 
      abcommon::IIntArray* instanceNoList = absimple::IProducerPool::getIntanceNoList();
      Tcl_Obj *  listObj = Tcl_NewListObj( 0, NULL );
      for(int i=0; i< instanceNoList->size(); i++ ) {
         Tcl_ListObjAppendList(interp, listObj, Tcl_NewIntObj(instanceNoList->at(i)) );
      }
      Tcl_SetObjResult(interp, listObj );
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}



