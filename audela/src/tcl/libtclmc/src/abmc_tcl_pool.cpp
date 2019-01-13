// abmc_tcl_mcpool.cpp : 
// manage mc intances 


#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>

#include <tcl.h>
#include <abcommon.h>
#include "abmc.h"
#include "abmc_tcl_command.h"
#include "abmc_tcl_common.h"

///
//   liste des numeros des instances de Mc
//   @return retourne la liste des mcNo
//
int cmdMcList(ClientData , Tcl_Interp *interp, int argc, const char *[]) {
   int result;
   const char *usage = "Usage: mc::list";
   if(argc < 1) {
      Tcl_SetResult(interp,(char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
 
   try {
      // je recupere la liste des instances
      abcommon::IIntArray* instanceNoList = abmc::IMcPool::getIntanceNoList();

      // je copie la liste des instances dans la variable TCL
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


///
//   supprime un mc
//
int cmdMcDelete(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;
   const char *usage = "Usage: mc::delete mcNo";
   if(argc < 2) {
      Tcl_SetResult(interp,(char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
 
   try {
      int mcNo = copyArgvToInt(interp, argv[1], "mcNo");
      // je supprime la commande TCL
      std::ostringstream instanceName ;
      instanceName << "mc" << mcNo;
      Tcl_DeleteCommand(interp,instanceName.str().c_str());
      // je supprime l'instance
      abmc::IMc* mc = abmc::IMcPool::getInstance(mcNo);
      abmc::IMcPool::deleteInstance(mc);
      Tcl_ResetResult(interp);
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

///
//   creation d'une instance IMc
//   @return retourne le nom de la commande TCL 
//
int cmdMcCreate(ClientData , Tcl_Interp *interp, int argc, const char *[]) {
   int result;
   if(argc < 1) {
      const char *usage = "Usage: mc::create";
      Tcl_SetResult(interp,(char *) usage,TCL_VOLATILE);
      return TCL_ERROR;
   } 
 
   try {
      // je cree l'instance
      abmc::IMc* mc = abmc::IMcPool::createInstance();
      int mcNo = abmc::IMcPool::getInstanceNo(mc);      
      //int mcNo = mc->getNo();

      // je cree la commande TCL
      std::ostringstream instanceName ;
      instanceName << "mc" << mcNo;
      Tcl_CreateCommand(interp, instanceName.str().c_str(), (Tcl_CmdProc *)cmdMcCommand, mc, NULL);

      // je retourne mcNo
      Tcl_SetObjResult(interp, Tcl_NewIntObj(mcNo));
      result = TCL_OK; 

   } catch(std::exception e ) {
      Tcl_SetResult(interp,(char*)e.what(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

