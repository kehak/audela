///@file tclLinkCmd.cpp
//
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
// $Id: $

#include <tcl.h>

struct cmditem {
    const char *cmd;
    Tcl_CmdProc *func;
};

static struct cmditem commonCmdList[] = {
   

   /* === Last function terminated by NULL pointers === */
   {NULL, NULL}
};


/**
 *  execute une commande qui peut être 
 *    - une commande generique 
 *    - une commande specifique C
 *    - une commande specifique TCL 
 */ 
int tclLinkCmd(ClientData , Tcl_Interp * interp, int , const char *[])
{
   /*
   char s[1024], ss[50];
   int retour = TCL_OK, k, i;

   if (argc == 1) {
     sprintf(s, "%s choose sub-command among ", argv[0]);
      k = 0;
      while (commonCmdList[k].cmd != NULL) {
         sprintf(ss, " %s", commonCmdList[k].cmd);
         strcat(s, ss);
         k++;
      }
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {

      // je trace les parametres si le niveau debug est active
      if (debug_level > 0) {
         char s1[1024], *s2;
         s2 = s1;
         s2 += sprintf(s2,"Enter cmdTel (argc=%d", argc);
         for (i = 0; i < argc; i++) {
            s2 += sprintf(s2, ",argv[%d]=%s", i, argv[i]);
         }
         s2 += sprintf(s2, ")");
         libcam_log(LOG_INFO, "%s", s1);
      }

      // commande generique 
      struct cmditem *genericCmd;
      for (genericCmd = commonCmdList; genericCmd->cmd != NULL; genericCmd++) {
         if (strcmp(genericCmd->cmd, argv[1]) == 0) {
            retour = (*genericCmd->func) (clientData, interp, argc, argv);
            break;
         }
      }

      // j'execute la  command specifique C
      int specificCommandResult = 1;
      if (genericCmd->cmd == NULL) {
         TclCam * tclcam = ( TclCam*) clientData;
         char * result; 
         specificCommandResult = tclcam->icamera->executeSpecificCommand(&result, argc, argv);
         if (specificCommandResult == 0) {
            Tcl_SetResult(interp, result, TCL_VOLATILE);
            retour = TCL_OK;
            tclcam->icamera->freeSpecificCommandResult();
         } else if( specificCommandResult == 0) {
            Tcl_SetResult(interp, result, TCL_VOLATILE);
            retour = TCL_ERROR;
            tclcam->icamera->freeSpecificCommandResult();
         }
      }

      // j'execute la  command specifique TCL
      int specificTclCommandResult = 1;
      if (genericCmd->cmd == NULL && specificCommandResult== -1) {
         TclCam * tclcam = ( TclCam*) clientData;
         specificTclCommandResult = tclcam->icamera->executeTclSpecificCommand(interp, argc, argv);
         if( specificTclCommandResult == -1 ) {
            retour = TCL_ERROR;
         } else {
            retour = specificTclCommandResult;
         }
      }

      // je trace la fin d'execution de la commande
      if (debug_level > 0) {
         char s1[1024], *s2;
         s2 = s1;
         s2 += sprintf(s2,"EXIT  cmdCam (argc=%d", argc);
         for (i = 0; i < argc; i++) {
            s2 += sprintf(s2, ",argv[%d]=%s", i, argv[i]);
         }
         s2 += sprintf(s2, ")");
         libcam_log(LOG_INFO, "%s", s1);
      }

      // je trace une erreur si la commande n'a pas ete trouvee
      if (genericCmd->cmd == NULL && specificCommandResult == -1 && specificTclCommandResult == -1) {
         sprintf(s, "%s %s : sub-command not found among ", argv[0], argv[1]);
         k = 0;
         while (commonCmdList[k].cmd != NULL) {
            sprintf(ss, " %s", commonCmdList[k].cmd);
            strcat(s, ss);
            k++;
         }
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
   */
   Tcl_SetResult(interp, (char*)"NOT IMPLEMENTED", TCL_VOLATILE);
   return TCL_OK;
}




#include <sstream>  // pour ostringstream
#include <string>
using namespace ::std;
#include <cstring>
#include <tcl.h>
#include <abcommon.h>
using namespace ::abcommon;
#include <tclcommon.h>
using namespace ::tclcommon;
#include <abaudela.h>
using namespace ::abaudela;
#include "tclLink.h" 

///@brief cree une instance Link
//   
// @return retourne linkNo
//
int tclLinkCreate(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 2) {
         throw CError(CError::ErrorInput, "Usage: %s library ", argv[0]);
      } 
     
      // je recupere le nom du repertoire des librairies
      auto_ptr<string> libraryPath = tclcommon::getLibraryPath(interp);
      // je recupere le nom de la librairie
      //auto_ptr<string> libraryFileName = tclcommon::getLibraryName(interp,argv[1]); 
   
      // je cree l'instance C++
      ILink* link = abaudela::ILink::createInstance(libraryPath->c_str(), argv[1], argc, argv);

      int linkNo = link->getNo();
      // je cree la commande TCL
      std::ostringstream instanceName ;
      instanceName << "cam" << linkNo;
      Tcl_CreateCommand(interp, instanceName.str().c_str(), (Tcl_CmdProc *)tclLinkCmd, (ClientData)link,(Tcl_CmdDeleteProc *)NULL);

      // je retourne linkNo
      Tcl_SetObjResult(interp, Tcl_NewIntObj(linkNo));
      result = TCL_OK; 
   } catch(IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

///@brief supprime un link
// 
// @param argc
// @param argv arv[1] contient le numero de l'instance a supprimer
//
int tclLinkDelete(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 2) {
         throw CError(CError::ErrorInput, "Usage: %s linkNo", argv[0]);
      } 
      int linkNo = copyArgToInt(interp, argv[1], "linkNo");
      // je supprime la commande TCL
      std::ostringstream instanceName ;
      instanceName << "link" << linkNo;
      Tcl_DeleteCommand(interp,instanceName.str().c_str());
      // je supprime l'instance C++
      abaudela::ILink* link = abaudela::ILink::getInstance(linkNo);
      abaudela::ILink::deleteInstance(link);
      Tcl_ResetResult(interp);
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}


///@brief liste des linkNo
//   
// @return la liste des linkNo
//
int tclLinkList(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 1) {
         throw CError(CError::ErrorInput, "Usage: %s", argv[0]);
      } 
      abcommon::IIntArray* instanceNoList = abaudela::ILink::getIntanceNoList();
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

int tclLinkAvailableList(ClientData , Tcl_Interp *interp, int argc, char *argv[])
{
   int result;

   try { 
      if(argc != 2) {
         throw CError(CError::ErrorInput, "Usage: %s driver_name ?options?",argv[0]);
      }

      std::string deviceResult="";
      Tcl_SetResult(interp,(char*) deviceResult.c_str(),TCL_VOLATILE);
      result = TCL_OK;
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;		
   }
  
   return result;
}



