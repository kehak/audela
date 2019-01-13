/* autoguider_tcl.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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

#include <tcl.h>

#include <string>
#include <stdexcept>
#include <cstring>
#include <sstream>  // pour ostringstream
using namespace ::std;

#include <abaudela.h>
using namespace abaudela;
#include <abcommon.h>
using namespace abcommon;
#include <tclcommon.h>
using namespace tclcommon;
#include "utf2Unicode_tcl.h"

int CmdGuideStart(ClientData , Tcl_Interp *interp, int argc, const char *argv[]);
int CmdGuideStop(ClientData , Tcl_Interp *interp, int argc, const char *argv[]);
void guideCallback(AutoguiderCallbackData*  autoguiderCallbackData);


int executeTclCallback(ClientData clientData, Tcl_Interp *interp, int code);
Tcl_AsyncHandler autoguiderAsyncHandle= NULL;
AutoguiderCallbackData  autoguiderCallbackData;
Tcl_Interp* autoguiderInterp;

//-------------------------------------------------------------------------
// CmdGuide --
// sesion de guidage
//
//-------------------------------------------------------------------------
int CmdGuide(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[])
{
   if ((argc<=1)) {
      char* usage = "Usage: guide start|stop";
      Tcl_SetResult(interp, usage, TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      if (strcmp(argv[1],"start")==0) {
         return CmdGuideStart(clientData , interp, argc, argv);
      } if (strcmp(argv[1],"stop")==0) {
         return CmdGuideStop(clientData , interp, argc, argv);
      } else {
         char* usage = "Usage: guide start|stop";
         Tcl_SetResult(interp, usage, TCL_VOLATILE);
         return TCL_ERROR;
      }

   }

}


//-------------------------------------------------------------------------
// CmdGuideStart --
// start guiding session
//
//-------------------------------------------------------------------------
int CmdGuideStart(ClientData , Tcl_Interp *interp, int argc, const char *argv[])
{
   if ((argc!=23)) {
      char* usage = "Usage: guide start camNo exptime, detection, originX,  originY,  targetX,  targetY,  angle, targetBoxSize, mountEnabled,  alphaSpeed,  deltaSpeed,  alphaReverse,  deltaReverse,  declinaisonEnabled, seuilX,  seuilY, slitWidth,  slitRatio, intervalle";
      Tcl_SetResult(interp, usage, TCL_VOLATILE);
      return TCL_ERROR;
   } else {

      if ( autoguiderAsyncHandle == NULL) {
         autoguiderAsyncHandle = Tcl_AsyncCreate(executeTclCallback, (ClientData)&autoguiderCallbackData);
         autoguiderInterp = interp; 
      }

      try {
            int camNo = copyArgToInt(interp,argv[2],"camNo");
            double exptime = copyArgToDouble(interp,argv[3],"exptime");
            AutoguiderDetectionType detection;
            const char* detectionString = argv[4];
            if ( strcmp(detectionString,"PSF")==0 ) {
               detection = DetectionPSF;
            } else if ( strcmp(detectionString,"SLIT")==0 ) {
               detection = DetectionSLIT;
            } else {
               ostringstream message;
               message << "detection" << "=" << detectionString << " is not PSF or SLIT";
               throw CError( CError::ErrorGeneric, message.str().c_str());
            }
            double originX = copyArgToDouble(interp,argv[5],"originX");
            double originY = copyArgToDouble(interp,argv[6],"originY");
            double targetX = copyArgToDouble(interp,argv[7],"targetX");
            double targetY = copyArgToDouble(interp,argv[8],"targetY");
            double angle    = copyArgToDouble(interp,argv[9],"angle");
            double targetBoxSize  = copyArgToDouble(interp,argv[10],"targetBoxSize");
            int telNo = copyArgToInt(interp,argv[11],"telNo");
            bool mountEnabled = copyArgToBoolean(interp,argv[12],"mountEnabled");
            double alphaSpeed = copyArgToDouble(interp,argv[13],"alphaSpeed");
            double deltaSpeed = copyArgToDouble(interp,argv[14],"deltaSpeed");
            bool alphaReverse = copyArgToBoolean(interp,argv[15],"alphaReverse");
            bool deltaReverse = copyArgToBoolean(interp,argv[16],"deltaReverse");
            bool declinaisonEnabled = copyArgToBoolean(interp,argv[17],"declinaisonEnabled");
            double seuilX  = copyArgToDouble(interp,argv[18],"seuilX");
            double seuilY  = copyArgToDouble(interp,argv[19],"seuilY"); 
            double slitWidth = copyArgToDouble(interp,argv[20],"slitWidth");
            double slitRatio = copyArgToDouble(interp,argv[21],"slitRatio");
            double intervalle = copyArgToDouble(interp,argv[22],"intervalle");
         
            abaudela::ILibaudela::guideStart( camNo, exptime,  detection, 
                         originX,  originY,  targetX,  targetY,  angle,
                         targetBoxSize, 
                         telNo, mountEnabled,  alphaSpeed,  deltaSpeed,  alphaReverse,  deltaReverse,  declinaisonEnabled,
                         seuilX,  seuilY, 
                         slitWidth,  slitRatio, 
                         intervalle, 
                         guideCallback);

         //Tcl_ResetResult(interp);
         //return TCL_OK;
         Tcl_SetResult(interp,"NOT IMPEMENTED",TCL_VOLATILE);
         return TCL_ERROR;
      
      } catch(abcommon::IError& e) {
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;
      }
   }
}



//-------------------------------------------------------------------------
// CmdGuideStop
// stop guiding session
//
//-------------------------------------------------------------------------
int CmdGuideStop(ClientData , Tcl_Interp *interp, int argc, const char *[])
{
   if ((argc!=2)) {
      char* usage = "Usage: guide stop";
      Tcl_SetResult(interp, usage, TCL_VOLATILE);
      return TCL_ERROR;
   } else {

      try {
         abaudela::ILibaudela::guideStop();
         Tcl_ResetResult(interp);
         return TCL_OK;
         
      } catch(abcommon::IError& e) {
         Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
         return TCL_ERROR;
      }
   }
}


//-------------------------------------------------------------------------
// guideCallback
// send a message to TCL main thread
//
//-------------------------------------------------------------------------
void guideCallback(AutoguiderCallbackData* data) {

   autoguiderCallbackData.code = data->code;
   autoguiderCallbackData.code = (int) data->value1;
   autoguiderCallbackData.code = (int) data->value2;
   autoguiderCallbackData.message = data->message;

   Tcl_AsyncMark(autoguiderAsyncHandle);
   // j'execute la procedure executeTclCallback()  pointee par le handle autoguiderAsyncHandle 
   Tcl_AsyncInvoke(autoguiderInterp, TCL_OK);
}

//-------------------------------------------------------------------------
// executeTclCallback
// send a message to TCL main thread
//-------------------------------------------------------------------------
int executeTclCallback(ClientData , Tcl_Interp *interp, int code)
{
   char s[1024];
  
   sprintf(s, "console::disp \"autoguiderCallback code=%d, message=%s\n\"", autoguiderCallbackData.code, autoguiderCallbackData.message);
   Tcl_Eval(interp, s);
   return code;
}



