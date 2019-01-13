///@file absimple_tcl.cpp
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

#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>

#ifdef WIN32 
#define sscanf sscanf_s
#endif

#include <tcl.h>
#include <abcommon.h>
#include <tclcommon.h>
using namespace ::tclcommon;
#include "absimple_tcl.h"
#include "absimple.h"
#include "tclProducerPool.h"


// variable locale au fichier
absimple::ICalculator* simple;
std::string simpleName;

/**
   additionne deux nombres 
   @return retourne le resultat de l'addition
*/
int cmdSimpleProcessAdd(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   const char *usage = "Usage: Ilibsimple_processAdd a b";
   if(argc != 3) {
      Tcl_SetResult(interp,(char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
   int toto = 0;
   Tcl_GetBoolean(interp,"0",&toto);
   int tclResult;
   try {
      int result = absimple::absimple_processAdd(copyArgToInt(interp, argv[1], "a"), copyArgToInt(interp, argv[2], "b") );
      Tcl_SetObjResult(interp, Tcl_NewIntObj(result));
      tclResult = TCL_OK;       
   } catch(std::exception e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      tclResult = TCL_ERROR;
   }
  
   return tclResult;
}

/**
   soustrait deux nombres 
   @return retourne le resultat de la sosutraction
*/
int cmdSimpleProcessSub(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   const char *usage = "Usage: Ilibsimple_processAdd a b";
   if(argc != 3) {
      Tcl_SetResult(interp,(char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
 
   int tclResult;
   try {
      int result = ::absimple::absimple_processSub(copyArgToInt(interp, argv[1], "a"), copyArgToInt(interp, argv[2], "b") );
      Tcl_SetObjResult(interp, Tcl_NewIntObj(result));
      tclResult = TCL_OK;       
   } catch(std::exception e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      tclResult = TCL_ERROR;
   }
  
   return tclResult;
}

int cmdSimpleCommand(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;
   const char *usage = "Usage: simple add | remove | list ";
   if(argc < 2) {
      Tcl_SetResult(interp, (char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   }

   // absimple::ICalculator* simple = (absimple::ICalculator*)clientData;

   try {
      if ( strcmp(argv[1], "add") == 0) {
         //result = simple
         result=TCL_OK;

      } else  if ( strcmp(argv[1], "remove") == 0) {
         const char *usageRemove = "Usage: bePilot agenda | backlog | next | nextbe";
         if(argc < 2) {
            Tcl_SetObjResult(interp, Tcl_NewIntObj(0));
            result= TCL_OK;
         } else {
            Tcl_SetResult(interp,  (char *)usageRemove, TCL_VOLATILE);
            result= TCL_ERROR;
         }

      } else  if ( strcmp(argv[1], "nextbe") == 0) {
         const char *usageNextbe = "Usage: bePilot agenda | backlog | next | nextbe";
         if(argc < 2) {
            Tcl_SetObjResult(interp, Tcl_NewIntObj(0));
            result= TCL_OK;            
         } else {
            Tcl_SetResult(interp,  (char *)usageNextbe, TCL_VOLATILE);
            result= TCL_ERROR;
         }
      } else {
         Tcl_SetResult(interp,  (char *)usage, TCL_VOLATILE);
         result= TCL_ERROR;
      }

     
   } catch(std::exception &e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}


/**
   creation du nouveau pilotbe  
   @return retourne le nom de la commande TCL pour utiliser ce scheduler
*/
int cmdSimpleCreate(ClientData , Tcl_Interp *interp, int argc, const char *[]) {
   int result;
   const char *usage = "Usage: simple::create";
   if(argc < 1) {
      Tcl_SetResult(interp,(char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
 
   try {
      if ( simple == NULL) {
         simpleName = "simple1";
         simple = absimple::ICalculator_createInstance(NULL);
         
         // j'ajoute l'instance dans la liste scheduler dans la liste
         Tcl_CreateCommand(interp,simpleName.c_str(),(Tcl_CmdProc *)cmdSimpleCommand,(ClientData)simple,(Tcl_CmdDeleteProc *)NULL);
         Tcl_SetResult(interp, (char *)simpleName.c_str() ,TCL_VOLATILE);
         result = TCL_OK; 
      } else {
         throw std::runtime_error("simple1 already exists. Only one simple may exists.");
      }
      
   } catch(std::exception e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

/**
   destuction du pilote
   @return  ""
*/
int cmdSimpleDelete(ClientData , Tcl_Interp *interp, int argc, const char *[]) {
   int result;
   const char *usage = "Usage: simple::delete";
   if(argc < 2) {
      Tcl_SetResult(interp,(char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
 
   try {
         Tcl_DeleteCommand(interp, simpleName.c_str());
         simple->Release();
         simple = NULL;
         simpleName =""; 
         Tcl_ResetResult(interp);
         result = TCL_OK;     

   } catch(std::exception e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}

//**************************************************************************
//                                     
//**************************************************************************

/***************************************************************************/
/*                      Point d'entree de la librairie TCL                 */
/***************************************************************************/
int Tclsimple_Init(Tcl_Interp *interp)
{
   if(Tcl_InitStubs(interp,"8.6",0)==NULL) {
      Tcl_SetResult(interp, (char *) "Tcl Stubs initialization",TCL_STATIC);
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"absimple","1.0");
   // standalone commands
   Tcl_CreateCommand(interp,"simple_processAdd",(Tcl_CmdProc *)cmdSimpleProcessAdd,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp,"simple_processSub",(Tcl_CmdProc *)cmdSimpleProcessSub,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);   

   // ProducerPool commands
   Tcl_CreateCommand(interp,"producer::create",(Tcl_CmdProc *)tclProducerCreate,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);   
   Tcl_CreateCommand(interp,"producer::delete",(Tcl_CmdProc *)tclProducerDelete,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);   
   Tcl_CreateCommand(interp,"producer::list",(Tcl_CmdProc *)tclProducerList,(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);   
   return TCL_OK;
}
