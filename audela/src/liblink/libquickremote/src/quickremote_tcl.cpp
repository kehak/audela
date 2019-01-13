/* quickremote_tcl.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

// $Id: quickremote_tcl.cpp,v 1.5 2009-10-30 10:18:53 jacquesmichelet Exp $

#ifdef WIN32
#include <windows.h>
#endif

#include <sysexp.h>
#include <tcl.h>
#include <stdlib.h>
#include "link.h"

int cmdQuickremoteChar(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   
   int result = TCL_OK;
   char *ligne;
   char c;
   CQuickremote * quickremote = (CQuickremote*)clientData;
   
   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?0...255?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      if( quickremote->getChar(&c) == LINK_OK) {
         sprintf(ligne, "%d", c); 
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_OK;
      } else {
         quickremote->getLastError(ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
         result = TCL_ERROR;
      }
   } else {
      int i;
      if(Tcl_GetInt(interp,argv[2],&i)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?num?\nnum = must be an integer 0 to 255",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if( quickremote->setChar((char)i) == LINK_OK) {
            sprintf(ligne, "%d", i); 
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            quickremote->getLastError(ligne);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
            result = TCL_ERROR;
         }
      }
   }
   free(ligne);
   return result;
}


int cmdQuickremoteBit(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   int result = TCL_OK;
   char *ligne;
   int bit;
   int value;
   double duration;
   CQuickremote * quickremote = (CQuickremote*)clientData;
   
   ligne = (char*)calloc(200,sizeof(char));
   if((argc<3)) {
      sprintf(ligne,"Usage: %s %s bit ?value (0|1)? ?duration (second)",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if(Tcl_GetInt(interp,argv[2],&bit)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?bit?\nbit = must be an integer 0 to 7",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {         
         if(argc==3) {
            if( quickremote->getBit(bit, &value) == LINK_OK) {
               sprintf(ligne, "%d", value); 
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_OK;
            } else {
               quickremote->getLastError(ligne);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
               result = TCL_ERROR;
            }
         } else {
            if(Tcl_GetInt(interp,argv[3],&value)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s ?value?\nvalue = must be an integer 0 or 1",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               if(argc==4) {
                  if( quickremote->setBit(bit, value) == LINK_OK) {
							ligne[0] = 0;
                     Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                     result = TCL_OK;
                  } else {
                     quickremote->getLastError(ligne);
                     Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
                     result = TCL_ERROR;
                  }
               } else {
                  if(Tcl_GetDouble(interp,argv[4],&duration)!=TCL_OK) {
                     sprintf(ligne,"duration must be a double");
                     Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                     result = TCL_ERROR;
                  } else {
                     if( quickremote->setBit(bit, value, duration) == LINK_OK) {
								ligne[0] = 0;
                        Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                        result = TCL_OK;
                     } else {
                        quickremote->getLastError(ligne);
                        Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
                        result = TCL_ERROR;
                     }

                  }
               }
            }
         }
      }
   }
   free(ligne);
   return result;
}




