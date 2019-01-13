/* serial_tcl.cpp
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

// $Id: serial_tcl.cpp,v 1.2 2009-05-01 16:11:46 michelpujol Exp $


#include <sysexp.h>
#include <tcl.h>
#include <stdlib.h>
#include <string.h>

#include "link.h"

   
int cmdSerialChar(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   
   int result = TCL_OK;
   char *ligne;
   int c;
   CSerial * serial = (CSerial*)clientData;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?0...255?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      if( serial->getChar((char *)&c) == LINK_OK) {
         sprintf(ligne, "%d", c); 
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_OK;
      } else {
         Tcl_SetResult(interp,serial->getLastMessage(),TCL_VOLATILE);      
         result = TCL_ERROR;
      }
   } else {
      int i;
      if(Tcl_GetInt(interp,argv[2],&i)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?num?\nnum = must be an integer 0 to 255",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if( serial->setChar((char)i) == LINK_OK) {
            sprintf(ligne, "%d", i); 
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_SetResult(interp,serial->getLastMessage(),TCL_VOLATILE);      
            result = TCL_ERROR;
         }
      }
   }
   free(ligne);
   return result;
}
   

int cmdSerialBit(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
   int result = TCL_OK;
   char ligne[1024];
   int bitNum;
   int value;
   CSerial * serial = (CSerial*)clientData;

   if((argc!=3)&&(argc!=4)) {
      sprintf(ligne,"Usage: %s %s bit ?value?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if ( strcmp(argv[2],"DTR") == 0 ) {
         bitNum = SERIAL_DTR_BIT;
      } else if ( strcmp(argv[2],"RTS") == 0 ) {
         bitNum = SERIAL_RTS_BIT;
      } else {
         sprintf(ligne,"invalide bit name %s . Must be DTR or RTS",argv[2]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
      if (result == TCL_OK ) {
         if(argc==3) {
            // get bit 
            if( serial->getBit(bitNum, &value) == LINK_OK) {
               sprintf(ligne, "%d", value); 
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_OK;
            } else {
               Tcl_SetResult(interp,serial->getLastMessage(),TCL_VOLATILE);      
               result = TCL_ERROR;
            }
         } else {
            // set bit 
            if(Tcl_GetInt(interp,argv[3],&value)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s ?value?\nvalue = must be an integer 0 or 1",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               if( serial->setBit(bitNum, value) == LINK_OK) {
                  Tcl_ResetResult(interp);
                  result = TCL_OK;
               } else {
                  Tcl_SetResult(interp,serial->getLastMessage(),TCL_VOLATILE);      
                  result = TCL_ERROR;
               }
            }
         }
      }
   }
   return result;
}
   
   


