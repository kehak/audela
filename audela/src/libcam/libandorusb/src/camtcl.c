
/* camtcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 * Initial author : Frederic VACHIER <fv@imcce.fr>
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
 
#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>


extern struct camini CAM_INI[];

int cmdAndorClosingtime(ClientData clientData, Tcl_Interp * interp, int argc,
                        char *argv[])
{
/***************************************************************************************/

/* Get|Set Closing time of the shuffetof the Andor camera                                                  */

/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if(argc >= 3)
   {
      cam->closingtime = (int) fabs(atoi(argv[2]));
   }
   sprintf(ligne, "%d", cam->closingtime);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}














int cmdAndorOpeningtime(ClientData clientData, Tcl_Interp * interp, int argc,
                        char *argv[])
{
/***************************************************************************************/

/* Get|Set Opening time of the shuffetof the Andor camera                                                  */

/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if(argc >= 3)
   {
      cam->openingtime = (int) fabs(atoi(argv[2]));
   }
   sprintf(ligne, "%d", cam->openingtime);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}










int cmdAndorNative(ClientData clientData, Tcl_Interp * interp, int argc,
                   char *argv[])
{
/***************************************************************************************/

/* appel direct aux fonctions natives du driver Andor */

/***************************************************************************************/
   char ligne[1024];
   int res;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   Tcl_SetResult(interp, "", TCL_VOLATILE);

   if(argc > 2)
   {

// -------------------------------------------------------------------

      if(strcmp(argv[2], "AbortAcquisition") == 0)
      {
         res = AbortAcquisition();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: AbortAcquisition()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "CancelWait") == 0)
      {
         res = CancelWait();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: CancelWait()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "CoolerOFF") == 0)
      {
         res = CoolerOFF();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: CoolerOFF()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "CoolerON") == 0)
      {
         res = CoolerON();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: CoolerON()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "DemosaicImage") == 0)
      {
         sprintf(ligne, "Info: DemosaicImage() not implemented. For colour sensors only.");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_OK;   
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "FreeInternalMemory") == 0)
      {
         res = FreeInternalMemory();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: FreeInternalMemory()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAcquiredData") == 0){
         at_32  arr;
         at_u32 size;
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s unsigned long ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            size = (at_u32) atol(argv[3]);
            res = GetAcquiredData((at_32 *) &arr, size);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "%d %d ", arr, size);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }


      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAcquiredData16") == 0){
         unsigned short arr;
         at_u32 size;
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s unsigned long ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            size = (unsigned long) atol(argv[3]);
            res  = GetAcquiredData16(&arr, size);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "%d %d ", arr, size);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }     
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAcquiredFloatData") == 0){
         float arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (unsigned long) atol(argv[3]);
            res  = GetAcquiredFloatData(&arr,size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %d ",arr,size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAcquisitionProgress") == 0){
         at_32 acc ;
         at_32 series ;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetAcquisitionProgress(&acc,&series);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",acc,series);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAcquisitionTimings") == 0){
         float exposure;
         float accumulate;
         float kinetic;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetAcquisitionTimings(&exposure,&accumulate,&kinetic);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %f %f ",exposure,accumulate,kinetic);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAdjustedRingExposureTimes") == 0){
         int inumTimes;
         float fptimes;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            inumTimes = (int) atoi(argv[3]);
            res=GetAdjustedRingExposureTimes(inumTimes,&fptimes);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne, "%d %f ", inumTimes, fptimes);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAllDMAData") == 0){
         at_32  arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (unsigned long)atol(argv[3]);
            res=GetAllDMAData(&arr,size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",arr,size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAmpDesc") == 0){
         int  index;
         char * name= "";
         int  length;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int) atoi(argv[3]);
            strcpy(name, argv[4]);
            length = (int)atoi(argv[5]);
            res = GetAmpDesc( index, name, length );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %s %d ", index, name, length);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAmpMaxSpeed") == 0){
         int index;
         float speed;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int) atoi(argv[3]);
            res = GetAmpMaxSpeed( index, &speed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f ", index, speed);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetAvailableCameras") == 0){
         at_32 totalCameras;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetAvailableCameras( &totalCameras );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ", totalCameras);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetBackground") == 0){
         at_32  arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (at_u32) atol(argv[3]);
            res  = GetBackground( &arr, size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",arr,size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetBitDepth") == 0){
         int channel;
         int depth;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            channel = (int) atoi(argv[3]);
            res=GetBitDepth(channel,&depth);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", channel, depth);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetCameraEventStatus") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetCameraHandle") == 0){
         at_32 cameraIndex;
         at_32 cameraHandle;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            cameraIndex = (at_32) atol(argv[3]);
            res = GetCameraHandle(cameraIndex,&cameraHandle);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", cameraIndex, cameraHandle);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetCameraInformation") == 0){
         int index;
         at_32 information;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int) atoi(argv[3]);
            res = GetCameraInformation( index, &information );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", index, information);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetCameraSerialNumber") == 0){
         int number;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetCameraSerialNumber(&number);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",number);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetCapabilities") == 0){
         AndorCapabilities caps;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetCapabilities(&caps);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne, "%p ", caps);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetControllerCardModel") == 0){
         char * controllerCardModel = "";
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(controllerCardModel,argv[3]);
            res = GetControllerCardModel(controllerCardModel);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s ",controllerCardModel);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetCurrentCamera") == 0){
         at_32 cameraHandle;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetCurrentCamera(&cameraHandle);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",cameraHandle);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetCYMGShift") == 0){
         int iXshift;
         int iYShift;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetCYMGShift( &iXshift, &iYShift );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", iXshift, iYShift );
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetDDGIOCFrequency") == 0){
         double frequency;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOCFrequency(&frequency);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%lf ",frequency);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetDDGIOCNumber") == 0){
         unsigned long numberPulses;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetDDGIOCNumber(&numberPulses);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%ld ",numberPulses);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetDDGIOCPulses") == 0){
         int pulses;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetDDGIOCPulses(&pulses);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",pulses);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      } 
      
// -------------------------------------------------------------------

      else if (strcmp(argv[2],"GetDDGPulse")==0) {
         double wid;
         double resolution;
         double Delay;
         double Width;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s double double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            wid = (double) atof(argv[3]);
            resolution = (double) atof(argv[4]);
            res=GetDDGPulse(wid, resolution, &Delay, &Width);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%lf %lf %lf %lf ", wid, resolution, Delay, Width);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetDetector") == 0){
         int width;
         int height;
         res = GetDetector( &width, &height);
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: GetDetector(width=%d, height=%d);", width, height);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetDICameraInfo") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetEMCCDGain") == 0){
         int gain;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetEMCCDGain( &gain );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne, "%d ", gain );
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetEMGainRange") == 0){
         int low;
         int high;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetEMGainRange(&low,&high);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne, "%d %d ", low, high);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetFastestRecommendedVSSpeed") == 0){
         int index;
         float speed;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFastestRecommendedVSSpeed( &index, &speed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f ", index, speed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetFIFOUsage") == 0){
         int FIFOusage;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFIFOUsage(&FIFOusage);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",FIFOusage);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetFilterMode") == 0){
         int mode;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFilterMode(&mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetFKExposureTime") == 0){
         float time;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetFKExposureTime(&time);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f ",time);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
       }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetFKVShiftSpeed") == 0){
         int index;
         int speed;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int) atoi(argv[3]);
            res=GetFKVShiftSpeed( index , &speed );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", index , speed );
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetFKVShiftSpeedF") == 0){
         int index;
         float speed;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int) atoi(argv[3]);
            res=GetFKVShiftSpeedF(index , &speed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f ",index , speed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetHardwareVersion") == 0){
         unsigned int PCB;
         unsigned int Decode;
         unsigned int dummy1;
         unsigned int dummy2;
         unsigned int CameraFirmwareVersion;
         unsigned int CameraFirmwareBuild;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res= GetHardwareVersion(&PCB, &Decode, &dummy1, &dummy2, &CameraFirmwareVersion, &CameraFirmwareBuild);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d %d ", PCB, Decode, dummy1, dummy2, CameraFirmwareVersion, CameraFirmwareBuild);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetHeadModel") == 0){
         char * name = "";
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(name, argv[3]);
            res = GetHeadModel(name);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s ", name);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetHorizontalSpeed") == 0){
         int index;
         int speed;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int) atoi(argv[3]);
            res   = GetHorizontalSpeed(index,&speed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", index, speed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetHSSpeed") == 0){
         int channel;
         int typ;
         int index;
         float speed;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            channel = (int) atoi(argv[3]);
            typ     = (int) atoi(argv[4]);
            index   = (int) atoi(argv[5]);
            res     = GetHSSpeed( channel, typ, index, &speed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %f ",channel, typ, index, speed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetHVflag") == 0){
         int bFlag;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetHVflag(&bFlag);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",bFlag);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetID") == 0){
         int devNum;
         int id;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            devNum = (int) atoi(argv[3]);
            res    = GetID(devNum, &id);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", devNum, id);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetImages ") == 0){
         at_32 first;
         at_32 last;
         at_32 arr;
         at_u32 size;
         at_32 validfirst;
         at_32 validlast;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s long long unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            first = (at_32) atol(argv[3]);
            last  = (at_32) atol(argv[4]);
            size  = (at_u32) atol(argv[5]);
            res=GetImages (first, last, &arr, size, &validfirst, &validlast);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d %d ", first, last, arr, size, validfirst, validlast);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetImages16 ") == 0){
         at_32 first;
         at_32 last;
         unsigned short arr;
         at_u32 size;
         at_32 validfirst;
         at_32 validlast;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s long long unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            first = (at_32) atol(argv[3]);
            last  = (at_32) atol(argv[4]);
            size  = (at_u32) atol(argv[5]);
            res   = GetImages16 (first, last, &arr, size, &validfirst, &validlast);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d %d ", first, last, arr, size, validfirst, validlast);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetImagesPerDMA") == 0){
         at_u32 images;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetImagesPerDMA( &images );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ", images);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetIRQ") == 0){
         int IRQ;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetIRQ( &IRQ );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ", IRQ);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetKeepCleanTime") == 0){
         }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMaximumBinning") == 0){
         int ReadMode;
         int HorzVert;
         int MaxBinning;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            ReadMode = (int) atoi(argv[3]);
            HorzVert = (int) atoi(argv[4]);
            res      = GetMaximumBinning(ReadMode, HorzVert, &MaxBinning);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d ", ReadMode, HorzVert, MaxBinning);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMaximumExposure") == 0){
         float MaxExp;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetMaximumExposure( &MaxExp );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f " , MaxExp );
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// ------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMCPGain") == 0){
         int piGain;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res    = GetMCPGain( &piGain );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ", piGain);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMCPGainRange") == 0){
         }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMCPVoltage") == 0){
         int iVoltage;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetMCPVoltage(&iVoltage);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",iVoltage );
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMetaDataInfo") == 0){
         }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMinimumImageLength") == 0){
         int MinImageLength;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetMinimumImageLength(&MinImageLength);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",MinImageLength);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMostRecentColorImage16 ") == 0){
         at_u32 size;
         int algorithm;
         unsigned short red;
         unsigned short green;
         unsigned short blue;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s unsigned long int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size      = (at_u32) atol(argv[3]);
            algorithm = (int) atoi(argv[4]);
            res       = GetMostRecentColorImage16 ( size, algorithm, &red, &green, &blue);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ", size, algorithm, red, green, blue);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMostRecentImage ") == 0){
         at_32  arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (at_u32) atol(argv[3]);
            res  = GetMostRecentImage (&arr, size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ", arr, size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetMostRecentImage16 ") == 0){
         unsigned short arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (at_u32) atol(argv[3]);
            res  = GetMostRecentImage16 (&arr, size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ", arr, size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNewData") == 0){
         at_32  arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (unsigned long)atol(argv[3]);
            res  = GetNewData( &arr, size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ", arr, size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNewData16") == 0){
         unsigned short arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (at_u32) atol(argv[3]);
            res  = GetNewData16( &arr, size );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", arr, size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNewData8") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNewFloatData") == 0){
         float arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (at_u32) atol(argv[3]);
            res  = GetNewFloatData(&arr, size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %d ", arr, size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberADChannels") == 0){
         int channels;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberADChannels(&channels);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",channels);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberAmp") == 0){
         int amp;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberAmp(&amp);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",amp);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberAvailableImages ") == 0){
         at_32 first;
         at_32 last;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberAvailableImages (&first,&last);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",first,last);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberDevices") == 0){
         int numDevs;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberDevices(&numDevs);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",numDevs);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberFKVShiftSpeeds") == 0){
         int number;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberFKVShiftSpeeds(&number);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",number);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberHorizontalSpeeds") == 0){
         int number;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberHorizontalSpeeds(&number);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ", number);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberHSSpeeds") == 0){
         int channel;
         int typ;
         int speeds;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            channel = (int) atoi(argv[3]);
            typ     = (int) atoi(argv[4]);
            res     = GetNumberHSSpeeds(channel, typ, &speeds);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d ",channel, typ, speeds);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberNewImages ") == 0){
         at_32 first;
         at_32 last;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberNewImages ( &first, &last);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ", first, last);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberPreAmpGains") == 0){
         int noGains;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberPreAmpGains(&noGains);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",noGains);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberRingExposureTimes") == 0){
         int ipnumTimes;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberRingExposureTimes(&ipnumTimes);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",ipnumTimes);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberIO") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberVerticalSpeeds") == 0){
         int number;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetNumberVerticalSpeeds(&number);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",number);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            } 
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberVSAmplitudes") == 0){
         int number;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberVSAmplitudes(&number);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",number);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetNumberVSSpeeds") == 0){
         int speeds;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberVSSpeeds(&speeds);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",speeds);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetOldestImage ") == 0){
         at_32  arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size = (at_u32)atol(argv[3]);
            res=GetOldestImage (&arr,size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",arr,size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetOldestImage16 ") == 0){
         unsigned short arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size=(unsigned long)atol(argv[3]);
            res=GetOldestImage16 (&arr,size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",arr,size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetPhysicalDMAAddress") == 0){
         at_u32 Address1;
         at_u32 Address2;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetPhysicalDMAAddress(&Address1,&Address2);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",Address1,Address2);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetPixelSize") == 0){
         float xSize;
         float ySize;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetPixelSize(&xSize,&ySize);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %f ",xSize,ySize);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetPreAmpGain") == 0){
         int index;
         float gain;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index=(int)atoi(argv[3]);
            res=GetPreAmpGain(index,&gain);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",index,gain);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetReadOutTime") == 0){
         float ReadOutTime;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res = GetReadOutTime(&ReadOutTime);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f ",ReadOutTime);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
       }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetRegisterDump") == 0){
         int mode;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetRegisterDump(&mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetRingExposureRange") == 0){
         float fpMin;
         float fpMax;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetRingExposureRange(&fpMin,&fpMax);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %f ",fpMin,fpMax);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetSizeOfCircularBuffer ") == 0){
         at_32 index;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSizeOfCircularBuffer (&index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetSlotBusDeviceFunction") == 0){
         at_u32 dwslot;
         at_u32 dwBus;
         at_u32 dwDevice;
         at_u32 dwFunction;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSlotBusDeviceFunction(&dwslot,&dwBus,&dwDevice,&dwFunction);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d ",dwslot,dwBus,dwDevice,dwFunction);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetSoftwareVersion") == 0){
         unsigned int eprom;
         unsigned int coffile;
         unsigned int vxdrev;
         unsigned int vxdver;
         unsigned int dllrev;
         unsigned int dllver;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSoftwareVersion(&eprom,&coffile,&vxdrev,&vxdver,&dllrev,&dllver);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d %d ",eprom,coffile,vxdrev,vxdver,dllrev,dllver);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetSpoolProgress") == 0){
         at_32 index;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSpoolProgress(&index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetStatus") == 0){
         int status;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetStatus(&status);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",status);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetTemperature") == 0){
         int temperature;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperature(&temperature);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",temperature);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetTemperatureF") == 0){
         float temperatureF;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperatureF(&temperatureF);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f ",temperatureF);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetTemperatureRange") == 0){
         int mintemp;
         int maxtemp;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperatureRange(&mintemp,&maxtemp);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",mintemp,maxtemp);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetTemperatureStatus") == 0){
         float SensorTemp;
         float TargetTemp;
         float AmbientTemp;
         float CoolerVolts;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperatureStatus(&SensorTemp,&TargetTemp,&AmbientTemp,&CoolerVolts);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %f %f %f ",SensorTemp,TargetTemp,AmbientTemp,CoolerVolts);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetTotalNumberImagesAcquired") == 0){
         at_32 index;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTotalNumberImagesAcquired (&index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetIODirection") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetIOLevel") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetVersionInfo") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetVerticalSpeed") == 0){         
         int index;
         int speed;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int)atoi(argv[3]);
            res = GetVerticalSpeed(index,&speed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",index,speed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetVirtualDMAAdress") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GetVSSpeed") == 0){
         int index;
         float speed;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index=(int)atoi(argv[3]);
            res=GetVSSpeed(index,&speed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f ",index,speed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GPIBReceive") == 0){
         int id;
         short address;
         char * text = "";
         int size;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int short char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            id=(int)atoi(argv[3]);
            address=(short)atoi(argv[4]);
            strcpy(text,argv[5]);
            size=(int)atoi(argv[6]);
            res=GPIBReceive(id,address,text,size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %s %d ",id,address,text,size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "GPIBSend") == 0){
         int id;
         short address;
         char * text = "";
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int short char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            id=(int)atoi(argv[3]);
            address=(short)atoi(argv[4]);
            strcpy(text,argv[5]);
            res=GPIBSend(id,address,text);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %s ",id,address,text);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "I2CBurstRead") == 0){
         unsigned char i2cAddress ;
         at_32 nBytes;
         unsigned char data;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s BYTE long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            i2cAddress=(unsigned char)atoi(argv[3]);
            nBytes=(at_32)atol(argv[4]);
            res=I2CBurstRead(i2cAddress,nBytes,&data);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d ",i2cAddress,nBytes,data);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "I2CBurstWrite") == 0){
         unsigned char i2cAddress ;
         at_32 nBytes;
         unsigned char data;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s BYTE long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            i2cAddress=(unsigned char)atoi(argv[3]);
            nBytes=(at_32)atol(argv[4]);
            res=I2CBurstWrite(i2cAddress,nBytes,&data);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d ",i2cAddress,nBytes,data);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "I2CRead") == 0){
         unsigned char deviceID;
         unsigned char intAddress;
         unsigned char pdata;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s BYTE BYTE ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            deviceID=(unsigned char)atoi(argv[3]);
            intAddress=(unsigned char)atoi(argv[4]);
            res=I2CRead(deviceID,intAddress,&pdata);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else { 
               sprintf(ligne,"%d %d %d ",deviceID,intAddress,pdata);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "I2CReset") == 0){
         I2CReset();
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "I2CWrite") == 0){
         unsigned char deviceID;
         unsigned char intAddress;
         unsigned char data;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s BYTE BYTE BYTE ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            deviceID  =(unsigned char)atoi(argv[3]);
            intAddress=(unsigned char)atoi(argv[4]);
            data      =(unsigned char)atoi(argv[5]);
            res=I2CWrite(deviceID,intAddress,data);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d ",deviceID,intAddress,data);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "IdAndorDll") == 0){
         IdAndorDll();
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "InAuxPort") == 0){
         int port;
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            port = (int)atoi(argv[3]);
            res  = InAuxPort(port,&state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",port,state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "Initialize") == 0){
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s path", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            char * path = argv[3];
            sprintf(ligne, "Info: begin Initialize (%s)", path);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            res = Initialize(path);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error(%d)", res);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "Info: Initialize(%s)", path);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "InitializeDevice") == 0){
         char * dir = "";
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(dir,argv[3]);
            res=InitializeDevice(dir);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s ",dir);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "IsCoolerON") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "IsInternalMechanicalShutter") == 0){
         int InternalShutter;
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=IsInternalMechanicalShutter(&InternalShutter);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",InternalShutter);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "IsAmplifierAvailable") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "IsPreAmpGainAvailable") == 0){
         int channel;
         int amplifier;
         int index;
         int pa;
         int status;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            channel   =(int)atoi(argv[3]);
            amplifier =(int)atoi(argv[4]);
            index     =(int)atoi(argv[5]);
            pa        =(int)atoi(argv[6]);
            res=IsPreAmpGainAvailable(channel,amplifier,index,pa,&status);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ",channel,amplifier,index,pa,status);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "IsTriggerModeAvailable") == 0){
         int iTriggerMode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            iTriggerMode=(int)atoi(argv[3]);
            res=IsTriggerModeAvailable(iTriggerMode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",iTriggerMode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "Merge") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "OutAuxPort") == 0){
         int port;
         int state;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            port=(int)atoi(argv[3]);
            state=(int)atoi(argv[4]);
            res=OutAuxPort(port,state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",port,state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "PrepareAcquisition") == 0){
         PrepareAcquisition();
      } 
      
// -------------------------------------------------------------------

      else if (strcmp(argv[2],"SaveAsBmp")==0) {
         char * path = "";
         char * palette = "";
         at_32 ymin;
         at_32 ymax;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s char* char* long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(path,argv[3]);
            strcpy(palette,argv[4]);
            ymin=(long)atol(argv[5]);
            ymax=(long)atol(argv[6]);
            res=SaveAsBmp(path,palette,ymin,ymax);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s %s %d %d ",path,palette,ymin,ymax);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveAsCommentedSif") == 0){
         char * path = "";
         char * comment = "";
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(path,argv[3]);
            strcpy(comment,argv[4]);
            res=SaveAsCommentedSif(path,comment);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s %s ",path,comment);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveAsEDF") == 0){
         char * szPath = "";
         int iMode;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(szPath,argv[3]);
            iMode=(int)atoi(argv[4]);
            res=SaveAsEDF(szPath,iMode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s %d ",szPath,iMode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveAsFITS") == 0){
         char * szFileTitle = "";
         int typ;
         if(argc < 5)
         {
            sprintf(ligne, "Usage: %s %s %s char* int ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            strcpy(szFileTitle, argv[0]);
            typ = (int) atoi(argv[1]);
            res = SaveAsFITS(szFileTitle, typ);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "%s %d ", szFileTitle, typ);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }      
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveAsRaw") == 0){
         char * szFileTitle = "";
         int typ;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(szFileTitle,argv[3]);
            typ = (int)atoi(argv[4]);
            res = SaveAsRaw(szFileTitle,typ);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s %d ",szFileTitle,typ);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveAsSif") == 0){
         char * path = "";
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(path,argv[3]);
            res=SaveAsSif(path);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s ",path);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveAsTiff") == 0){
         char * path = "";
         char * palette = "";
         int position;
         int typ;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s char* char* int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(path,argv[3]);
            strcpy(palette,argv[4]);
            position=(int)atoi(argv[5]);
            typ=(int)atoi(argv[6]);
            res=SaveAsTiff(path,palette,position,typ);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s %s %d %d ",path,palette,position,typ);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveAsTiffEx") == 0){
         char * path = "";
         char * palette = "";
         int position;
         int typ;
         int mode;
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s char* char* int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(path,argv[3]);
            strcpy(palette,argv[4]);
            position=(int)atoi(argv[5]);
            typ=(int)atoi(argv[6]);
            mode=(int)atoi(argv[7]);
            res=SaveAsTiffEx(path,palette,position,typ,mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s %s %d %d %d ",path,palette,position,typ,mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveEEPROMToFile") == 0){
         char * cFileName = "";
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(cFileName,argv[3]);
            res=SaveEEPROMToFile(cFileName);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s ",cFileName);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SaveToClipBoard") == 0){
         char * palette = "";
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(palette,argv[3]);
            res=SaveToClipBoard(palette);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s ",palette);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SelectDevice") == 0){
         int devNum;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            devNum=(int)atoi(argv[3]);
            res=SelectDevice(devNum);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",devNum);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SendSoftwareTrigger") == 0){
         SendSoftwareTrigger();
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetAccumulationCycleTime") == 0){
         float time;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            time = (float)atof(argv[3]);
            res  = SetAccumulationCycleTime(time);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f ",time);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetAcquisitionMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode = (int)atoi(argv[3]);
            res  = SetAcquisitionMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// ------------------------------------------------------------------

      else if(strcmp(argv[2], "SetAcquisitionType") == 0){
         int typ;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            typ=(int)atoi(argv[3]);
            res=SetAcquisitionType(typ);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",typ);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetADChannel") == 0){
         int channel;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            channel=(int)atoi(argv[3]);
            res=SetADChannel(channel);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",channel);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetAdvancedTriggerModeState") == 0){
         int iState;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            iState=(int)atoi(argv[3]);
            res=SetAdvancedTriggerModeState(iState);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",iState);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetBackground") == 0){
         at_32  arr;
         at_u32 size;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            size=(unsigned long)atol(argv[3]);
            res=SetBackground(&arr,size);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",arr,size);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetBaselineClamp") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state=(int)atoi(argv[3]);
            res=SetBaselineClamp(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetBaselineOffset") == 0){
         int offset;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            offset=(int)atoi(argv[3]);
            res=SetBaselineOffset(offset);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",offset);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetCameraStatusEnable") == 0){
         unsigned long Enable;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s DWORD ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            Enable=(unsigned long)atoi(argv[3]);
            res=SetCameraStatusEnable(Enable);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%ld ",Enable);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetComplexImage") == 0){
         int numAreas;
         int areas;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            numAreas = (int)atoi(argv[3]);
            res=SetComplexImage(numAreas,&areas);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",numAreas,areas);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetCoolerMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode=(int)atoi(argv[3]);
            res=SetCoolerMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetCropMode") == 0){
         int active;
         int cropHeight;
         int reserved;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            active=(int)atoi(argv[3]);
            cropHeight=(int)atoi(argv[4]);
            reserved=(int)atoi(argv[5]);
            res=SetCropMode(active, cropHeight, reserved);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d ",active, cropHeight, reserved);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetCurrentCamera") == 0){
         at_32 cameraHandle;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            cameraHandle=(at_32)atol(argv[3]);
            res=SetCurrentCamera(cameraHandle);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",cameraHandle);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetCustomTrackHBin") == 0){
         int bin;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            bin=(int)atoi(argv[3]);
            res=SetCustomTrackHBin(bin);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",bin);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDACOutputScale") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDACOutput") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDataType") == 0){
         int typ;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            typ=(int)atoi(argv[3]);
            res=SetDataType(typ);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",typ);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGAddress") == 0){
         unsigned char t0;
         unsigned char t1;
         unsigned char t2;
         unsigned char t3;
         unsigned char address;
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s BYTE BYTE BYTE BYTE BYTE ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            t0=(unsigned char)atoi(argv[3]);
            t1=(unsigned char)atoi(argv[4]);
            t2=(unsigned char)atoi(argv[5]);
            t3=(unsigned char)atoi(argv[6]);
            address=(unsigned char)atoi(argv[7]);
            res=SetDDGAddress(t0,t1,t2,t3,address);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ",t0,t1,t2,t3,address);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGGain") == 0){
         int gain;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            gain=(int)atoi(argv[3]);
            res=SetDDGGain(gain);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",gain);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGGateStep") == 0){
         double step_Renamed;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            step_Renamed=(double)atof(argv[3]);
            res=SetDDGGateStep(step_Renamed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%lf ",step_Renamed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGInsertionDelay") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state=(int)atoi(argv[3]);
            res=SetDDGInsertionDelay(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGIntelligate") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state = (int)atoi(argv[3]);
            res   = SetDDGIntelligate(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGIOC") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state = (int)atoi(argv[3]);
            res   = SetDDGIOC(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGIOCFrequency") == 0){
         double frequency;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            frequency = (double)atof(argv[3]);
            res       = SetDDGIOCFrequency(frequency);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f ",frequency);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGIOCNumber") == 0){
         unsigned long numberPulses;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            numberPulses = (unsigned long)atol(argv[3]);
            res = SetDDGIOCNumber(numberPulses);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%ld ",numberPulses);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGTimes") == 0){
         double t0;
         double t1;
         double t2;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s double double double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            t0  = (double)atof(argv[3]);
            t1  = (double)atof(argv[4]);
            t2  = (double)atof(argv[5]);
            res = SetDDGTimes(t0, t1, t2);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %f %f ",t0, t1, t2);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGTriggerMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode = (int)atoi(argv[3]);
            res  = SetDDGTriggerMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDDGVariableGateStep") == 0){
         int mode;
         double p1;
         double p2;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int double double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode = (int)atoi(argv[3]);
            p1   = (double)atof(argv[4]);
            p2   = (double)atof(argv[5]);
            res=SetDDGVariableGateStep(mode,p1,p2);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f %f ",mode,p1,p2);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDelayGenerator") == 0){
         int board;
         short address;
         int typ;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int short int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            board   = (int)atoi(argv[3]);
            address = (short)atoi(argv[4]);
            typ     = (int)atoi(argv[5]);
            res=SetDelayGenerator(board,address,typ);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d ",board,address,typ);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetDMAParameters") == 0){
         int MaxImagesPerDMA;
         float SecondsPerDMA;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            MaxImagesPerDMA = (int)atoi(argv[3]);
            SecondsPerDMA   = (float)atof(argv[4]);
            res=SetDMAParameters(MaxImagesPerDMA,SecondsPerDMA);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f ",MaxImagesPerDMA,SecondsPerDMA);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetEMAdvanced") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state = (int)atoi(argv[3]);
            res   = SetEMAdvanced(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetEMCCDGain") == 0){
         int gain;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            gain = (int)atoi(argv[3]);
            res  = SetEMCCDGain(gain);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",gain);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetEMClockCompensation") == 0){
         int EMClockCompensationFlag;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            EMClockCompensationFlag = (int)atoi(argv[3]);
            res = SetEMClockCompensation(EMClockCompensationFlag);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",EMClockCompensationFlag);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetEMGainMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode = (int)atoi(argv[3]);
            res  = SetEMGainMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetExposureTime") == 0){
         float time;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            time = (float)atof(argv[3]);
            res  = SetExposureTime(time);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f ",time);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFanMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode = (int)atoi(argv[3]);
            res  = SetFanMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFastKinetics") == 0){
         int   exposedRows;
         int   seriesLength;
         float time;
         int   mode;
         int   hbin;
         int   vbin;
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int int float int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            exposedRows  = (int)atoi(argv[3]);
            seriesLength = (int)atoi(argv[4]);
            time         = (float)atof(argv[5]);
            mode         = (int)atoi(argv[6]);
            hbin         = (int)atoi(argv[7]);
            vbin         = (int)atoi(argv[8]);
            res=SetFastKinetics(exposedRows, seriesLength, time, mode, hbin, vbin);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %f %d %d %d ",exposedRows, seriesLength, time, mode, hbin, vbin);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFastKineticsEx") == 0){
         int   exposedRows;
         int   seriesLength;
         float time;
         int   mode;
         int   hbin;
         int   vbin;
         int   offset;
         if (argc<10) {
            sprintf(ligne,"Usage: %s %s %s int int float int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            exposedRows  = (int)atoi(argv[3]);
            seriesLength = (int)atoi(argv[4]);
            time         = (float)atof(argv[5]);
            mode         = (int)atoi(argv[6]);
            hbin         = (int)atoi(argv[7]);
            vbin         = (int)atoi(argv[8]);
            offset       = (int)atoi(argv[9]);
            res          = SetFastKineticsEx(exposedRows, seriesLength, time, mode, hbin, vbin, offset);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %f %d %d %d %d ",exposedRows, seriesLength, time, mode, hbin, vbin, offset);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFilterMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode = (int)atoi(argv[3]);
            res  = SetFilterMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFilterParameters") == 0){
         int width;
         float sensitivity;
         int range;
         float accept;
         int smooth;
         int noise;
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int float int float int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            width       = (int)  atoi(argv[3]);
            sensitivity = (float)atof(argv[4]);
            range       = (int)  atoi(argv[5]);
            accept      = (float)atof(argv[6]);
            smooth      = (int)  atoi(argv[7]);
            noise       = (int)  atoi(argv[8]);
            res         = SetFilterParameters(width,sensitivity,range,accept,smooth,noise);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f %d %f %d %d ",width,sensitivity,range,accept,smooth,noise);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFKVShiftSpeed") == 0){
         int index;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index=(int)atoi(argv[3]);
            res=SetFKVShiftSpeed(index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFPDP") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state=(int)atoi(argv[3]);
            res=SetFPDP(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFrameTransferMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode=(int)atoi(argv[3]);
            res=SetFrameTransferMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFullImage") == 0){
         int hbin;
         int vbin;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            hbin=(int)atoi(argv[3]);
            vbin=(int)atoi(argv[4]);
            res=SetFullImage(hbin,vbin);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",hbin,vbin);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetFVBHBin") == 0){
         int bin;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            bin=(int)atoi(argv[3]);
            res=SetFVBHBin(bin);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",bin);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetGain") == 0){
         int gain;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            gain=(int)atoi(argv[3]);
            res=SetGain(gain);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",gain);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetGate") == 0){
         float delay;
         float width;
         float stepRenamed;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s float float float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            delay=(float)atof(argv[3]);
            width=(float)atof(argv[4]);
            stepRenamed=(float)atof(argv[5]);
            res=SetGate(delay,width,stepRenamed);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f %f %f ",delay,width,stepRenamed);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetGateMode") == 0){
         int gatemode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            gatemode=(int)atoi(argv[3]);
            res=SetGateMode(gatemode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",gatemode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetHighCapacity") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state = (int)atoi(argv[3]);
            res   = SetHighCapacity(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetHorizontalSpeed") == 0){
         int index;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int)atoi(argv[3]);
            res   = SetHorizontalSpeed(index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetHSSpeed") == 0){
         int typ;
         int index;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            typ   = (int)atoi(argv[3]);
            index = (int)atoi(argv[4]);
            res=SetHSSpeed(typ, index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",typ,index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetImage") == 0){
         int hbin;
         int vbin;
         int hstart;
         int hend;
         int vstart;
         int vend;
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            hbin  = (int)atoi(argv[3]);
            vbin  = (int)atoi(argv[4]);
            hstart= (int)atoi(argv[5]);
            hend  = (int)atoi(argv[6]);
            vstart= (int)atoi(argv[7]);
            vend  = (int)atoi(argv[8]);
            res   = SetImage(hbin, vbin, hstart, hend, vstart, vend);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d %d ",hbin, vbin, hstart, hend, vstart, vend);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetImageFlip") == 0){
         int iHFlip;
         int iVFlip;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            iHFlip=(int)atoi(argv[3]);
            iVFlip=(int)atoi(argv[4]);
            res=SetImageFlip(iHFlip,iVFlip);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",iHFlip,iVFlip);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetImageRotate") == 0){
         int iRotate;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            iRotate = (int)atoi(argv[3]);
            res     = SetImageRotate(iRotate);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",iRotate);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetIsolatedCropMode ") == 0){
         int active;
         int cropheight;
         int cropwidth;
         int vbin;
         int hbin;
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            active    =(int)atoi(argv[3]);
            cropheight=(int)atoi(argv[4]);
            cropwidth =(int)atoi(argv[5]);
            vbin      =(int)atoi(argv[6]);
            hbin      =(int)atoi(argv[7]);
            res=SetIsolatedCropMode (active,cropheight,cropwidth,vbin,hbin);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ",active,cropheight,cropwidth,vbin,hbin);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetKineticCycleTime") == 0){
         float time;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            time=(float)atof(argv[3]);
            res=SetKineticCycleTime(time);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%f ",time);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetMCPGain") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetMCPGating") == 0){
         int gating;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            gating=(int)atoi(argv[3]);
            res=SetMCPGating(gating);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",gating);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetMessageWindow") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetMetaData") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetMultiTrack") == 0){
         int number;
         int height;
         int offset;
         int bottom;
         int gap;
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            number=(int)atoi(argv[3]);
            height=(int)atoi(argv[4]);
            offset=(int)atoi(argv[5]);
            res=SetMultiTrack(number,height,offset,&bottom,&gap);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ", number, height, offset, bottom, gap);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetMultiTrackHBin") == 0){
         int bin;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            bin=(int)atoi(argv[3]);
            res=SetMultiTrackHBin(bin);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",bin);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetMultiTrackHRange") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetNextAddress") == 0){
         at_32 data;
         at_32 lowAdd;
         at_32 highAdd;
         at_32 length;
         at_32 physical;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s long long long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            lowAdd  =(at_32)atol(argv[3]);
            highAdd =(at_32)atol(argv[4]);
            length  =(at_32)atol(argv[5]);
            physical=(at_32)atol(argv[6]);
            res=SetNextAddress(&data,lowAdd,highAdd,length,physical);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ",data,lowAdd,highAdd,length,physical);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

              /* Fait Planter Audela */
/*
      else if(strcmp(argv[2], "SetNextAddress16") == 0){
         at_32 data;
         at_32 lowAdd;
         at_32 highAdd;
         at_32 length;
         at_32 physical;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s long long long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            lowAdd   = (at_32)atol(argv[3]);
            highAdd  = (at_32)atol(argv[4]);
            length   = (at_32)atol(argv[5]);
            physical = (at_32)atol(argv[6]);
            res=SetNextAddress16(&data,lowAdd,highAdd,length,physical);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ",data,lowAdd,highAdd,length,physical);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }
*/
// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetNumberAccumulations") == 0){
         int number;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            number=(int)atoi(argv[3]);
            res=SetNumberAccumulations(number);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",number);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetNumberKinetics") == 0){
         int number;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            number = (int)atoi(argv[3]);
            res    = SetNumberKinetics(number);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",number);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetNumberPrescans") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetOutputAmplifier") == 0){
         int typ;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            typ = (int)atoi(argv[3]);
            res = SetOutputAmplifier(typ);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",typ);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetOverlapMode") == 0){}


// -------------------------------------------------------------------

              /* Fait Planter Audela */

/*
      else if(strcmp(argv[2], "SetPCIMode") == 0){
         int mode;
         int value;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode=(int)atoi(argv[3]);
            value=(int)atoi(argv[4]);
            res=SetPCIMode(mode,value);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",mode,value);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }
*/
// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetPhotonCounting") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state=(int)atoi(argv[3]);
            res=SetPhotonCounting(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetPhotonCountingThreshold") == 0){
         at_32 min;
         at_32 max;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            min=(at_32)atol(argv[3]);
            max=(at_32)atol(argv[4]);
            res=SetPhotonCountingThreshold(min,max);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",min,max);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      /* THIS FUNCTION IS RESERVED */

      else if(strcmp(argv[2], "SetPixelMode") == 0){
         int bitdepth;
         int colormode;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            bitdepth=(int)atoi(argv[3]);
            colormode=(int)atoi(argv[4]);
            res=SetPixelMode(bitdepth,colormode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",bitdepth,colormode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetPreAmpGain") == 0){
         int index;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index = (int)atoi(argv[3]);
            res   = SetPreAmpGain(index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetRandomTracks") == 0){
         int numTracks;
         int areas;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            numTracks=(int)atoi(argv[3]);
            res=SetRandomTracks(numTracks,&areas);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",numTracks,areas);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetReadMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode=(int)atoi(argv[3]);
            res=SetReadMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetRegisterDump") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode=(int)atoi(argv[3]);
            res=SetRegisterDump(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetRingExposureTimes") == 0){
         int numTimes;
         float times;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            numTimes=(int)atoi(argv[3]);
            res=SetRingExposureTimes(numTimes,&times);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %f ",numTimes,times);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetSaturationEvent") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetShutter") == 0){
         int typ;
         int mode;
         int closingtime;
         int openingtime;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            typ        =(int)atoi(argv[3]);
            mode       =(int)atoi(argv[4]);
            closingtime=(int)atoi(argv[5]);
            openingtime=(int)atoi(argv[6]);
            res=SetShutter(typ ,mode ,closingtime ,openingtime );
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d ",typ ,mode ,closingtime ,openingtime );
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetShutterEx") == 0){
         int typ; 
         int mode;
         int closingtime;
         int openingtime;
         int extmode;
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            typ        =(int)atoi(argv[3]);
            mode       =(int)atoi(argv[4]);
            closingtime=(int)atoi(argv[5]);
            openingtime=(int)atoi(argv[6]);
            extmode    =(int)atoi(argv[7]);
            res=SetShutterEx(typ, mode, closingtime, openingtime, extmode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d ",typ, mode, closingtime, openingtime, extmode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetShutters") == 0){
         int typ;  
         int mode;
         int closingtime;
         int openingtime;
         int exttype;
         int extmode;
         int dummy1;
         int dummy2;
         if (argc<11) {
            sprintf(ligne,"Usage: %s %s %s int int int int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            typ        =(int)atoi(argv[3]);
            mode       =(int)atoi(argv[4]);
            closingtime=(int)atoi(argv[5]);
            openingtime=(int)atoi(argv[6]);
            exttype    =(int)atoi(argv[7]);
            extmode    =(int)atoi(argv[8]);
            dummy1     =(int)atoi(argv[9]);
            dummy2     =(int)atoi(argv[10]);
            res=SetShutters(typ, mode, closingtime, openingtime, exttype, extmode, dummy1, dummy2);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %d %d %d %d %d %d ",typ, mode, closingtime, openingtime, exttype, extmode, dummy1, dummy2);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetSifComment") == 0){
         char * comment = "";
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(comment,argv[3]);
            res=SetSifComment(comment);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%s ",comment);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetSingleTrack") == 0){
         int centre;
         int height;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            centre=(int)atoi(argv[3]);
            height=(int)atoi(argv[4]);
            res=SetSingleTrack(centre,height);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",centre,height);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetSingleTrackHBin") == 0){
         int bin;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            bin=(int)atoi(argv[3]);
            res=SetSingleTrackHBin(bin);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",bin);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetSpool") == 0){
         int active;
         int method;
         char * path = "";
         int framebuffersize;
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int int char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            active=(int)atoi(argv[3]);
            method=(int)atoi(argv[4]);
            strcpy(path,argv[5]);
            framebuffersize=(int)atoi(argv[6]);
            res=SetSpool(active,method,path,framebuffersize);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d %s %d ",active,method,path,framebuffersize);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetStorageMode") == 0){
         at_32 mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode=(at_32)atol(argv[3]);
            res=SetStorageMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetTemperature") == 0){
         int temperature;
         if(argc < 4)
         {
            sprintf(ligne, "Usage: %s %s %s int ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            strcpy(ligne, "");
            temperature = (int) atoi(argv[3]);
            res = SetTemperature(temperature);
            if(res != DRV_SUCCESS)
            {
               sprintf(ligne, "Error(%d) %d", res,temperature);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else
            {
               sprintf(ligne, "Info: SetTemperature fixed to %d °C (%d);",temperature,res);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetTriggerInvert") == 0){}


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetTriggerMode") == 0){
         int mode;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            mode=(int)atoi(argv[3]);
            res=SetTriggerMode(mode);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",mode);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetIODirection") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetIOLevel") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetUSEvent") == 0){}

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetUSGenomics") == 0){
         at_32 width;
         at_32 height;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            width =(at_32)atol(argv[3]);
            height=(at_32)atol(argv[4]);
            res=SetUSGenomics(width,height);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d %d ",width,height);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetVerticalRowBuffer") == 0){
         int rows;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            rows=(int)atoi(argv[3]);
            res=SetVerticalRowBuffer(rows);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",rows);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetVerticalSpeed") == 0){
         int index;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index=(int)atoi(argv[3]);
            res=SetVerticalSpeed(index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetVirtualChip") == 0){
         int state;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            state=(int)atoi(argv[3]);
            res=SetVirtualChip(state);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",state);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetVSAmplitude") == 0){
         int index;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index=(int)atoi(argv[3]);
            res=SetVSAmplitude(index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "SetVSSpeed") == 0){
         int index;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            index=(int)atoi(argv[3]);
            res=SetVSSpeed(index);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",index);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "ShutDown") == 0)
      {
         res = ShutDown();
         if(res != DRV_SUCCESS)
         {
            sprintf(ligne, "Error(%d)", res);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else
         {
            sprintf(ligne, "Info: ShutDown()");
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_OK;
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "StartAcquisition") == 0){
         StartAcquisition();
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "UnMapPhysicalAddress") == 0){
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "WaitForAcquisition") == 0){
         WaitForAcquisition();
      }


// -------------------------------------------------------------------

      else if(strcmp(argv[2], "WaitForAcquisitionByHandle") == 0){
         at_32 cameraHandle;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            cameraHandle=(at_32)atol(argv[3]);
            res=WaitForAcquisitionByHandle(cameraHandle);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",cameraHandle);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "WaitForAcquisitionByHandleTimeOut") == 0){
         long cameraHandle;
         int iTimeOutMs;
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s long int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            cameraHandle = (long)atol(argv[3]);
            iTimeOutMs   = (int)atoi(argv[4]);
            res=WaitForAcquisitionByHandleTimeOut(cameraHandle,iTimeOutMs);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%ld %d ",cameraHandle,iTimeOutMs);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "WaitForAcquisitionTimeOut") == 0){
         int iTimeOutMs;
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            iTimeOutMs=(int)atoi(argv[3]);
            res=WaitForAcquisitionTimeOut(iTimeOutMs);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {
               sprintf(ligne,"%d ",iTimeOutMs);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

// -------------------------------------------------------------------

      else if(strcmp(argv[2], "WhiteBalance") == 0){}

// -------------------------------------------------------------------
// -------------------------------------------------------------------
// -------------------------------------------------------------------



   }
   else
   {
      // SDK version 2.84.30003.0
      
      Tcl_SetResult(interp, "Available functions are: ", TCL_VOLATILE);
      Tcl_AppendResult(interp, "AbortAcquisition ", NULL);
      Tcl_AppendResult(interp, "CancelWait ", NULL);
      Tcl_AppendResult(interp, "CoolerOFF ", NULL);
      Tcl_AppendResult(interp, "CoolerON ", NULL);
      Tcl_AppendResult(interp, "DemosaicImage ", NULL);
      Tcl_AppendResult(interp, "FreeInternalMemory ", NULL);
      Tcl_AppendResult(interp, "GetAcquiredData ", NULL);
      Tcl_AppendResult(interp, "GetAcquiredData16 ", NULL);
      Tcl_AppendResult(interp, "GetAcquiredFloatData ", NULL);
      Tcl_AppendResult(interp, "GetAcquisitionProgress ", NULL);
      Tcl_AppendResult(interp, "GetAcquisitionTimings ", NULL);
      Tcl_AppendResult(interp, "GetAdjustedRingExposureTimes ", NULL);
      Tcl_AppendResult(interp, "GetAllDMAData ", NULL);
      Tcl_AppendResult(interp, "GetAmpDesc ", NULL);
      Tcl_AppendResult(interp, "GetAmpMaxSpeed ", NULL);
      Tcl_AppendResult(interp, "GetAvailableCameras ", NULL);
      Tcl_AppendResult(interp, "GetBackground ", NULL);
      Tcl_AppendResult(interp, "GetBitDepth ", NULL);
      Tcl_AppendResult(interp, "GetCameraEventStatus ", NULL);
      Tcl_AppendResult(interp, "GetCameraHandle ", NULL);
      Tcl_AppendResult(interp, "GetCameraInformation ", NULL);
      Tcl_AppendResult(interp, "GetCameraSerialNumber ", NULL);
      Tcl_AppendResult(interp, "GetCapabilities ", NULL);
      Tcl_AppendResult(interp, "GetControllerCardModel ", NULL);
      Tcl_AppendResult(interp, "GetCurrentCamera ", NULL);
      Tcl_AppendResult(interp, "GetDDGPulse ", NULL);
      Tcl_AppendResult(interp, "GetDDGIOCFrequency ", NULL);
      Tcl_AppendResult(interp, "GetDDGIOCNumber ", NULL);
      Tcl_AppendResult(interp, "GetDDGIOCPulses ", NULL);
      Tcl_AppendResult(interp, "GetDetector ", NULL);
      Tcl_AppendResult(interp, "GetDICameraInfo", NULL);
      Tcl_AppendResult(interp, "GetEMCCDGain ", NULL);
      Tcl_AppendResult(interp, "GetEMGainRange ", NULL);
      Tcl_AppendResult(interp, "GetFastestRecommendedVSSpeed ", NULL);
      Tcl_AppendResult(interp, "GetFIFOUsage ", NULL);
      Tcl_AppendResult(interp, "GetFilterMode ", NULL);
      Tcl_AppendResult(interp, "GetFKExposureTime ", NULL);
      Tcl_AppendResult(interp, "GetFKVShiftSpeed ", NULL);
      Tcl_AppendResult(interp, "GetFKVShiftSpeedF ", NULL);
      Tcl_AppendResult(interp, "GetHardwareVersion ", NULL);
      Tcl_AppendResult(interp, "GetHeadModel ", NULL);
      Tcl_AppendResult(interp, "GetHorizontalSpeed ", NULL);
      Tcl_AppendResult(interp, "GetHSSpeed ", NULL);
      Tcl_AppendResult(interp, "GetHVflag ", NULL);
      Tcl_AppendResult(interp, "GetID ", NULL);
      Tcl_AppendResult(interp, "GetImages  ", NULL);
      Tcl_AppendResult(interp, "GetImages16  ", NULL);
      Tcl_AppendResult(interp, "GetImagesPerDMA ", NULL);
      Tcl_AppendResult(interp, "GetIRQ ", NULL);
      Tcl_AppendResult(interp, "GetKeepCleanTime ", NULL);
      Tcl_AppendResult(interp, "GetMaximumBinning ", NULL);
      Tcl_AppendResult(interp, "GetMaximumExposure ", NULL);
      Tcl_AppendResult(interp, "GetMCPGain ", NULL);
      Tcl_AppendResult(interp, "GetMCPGainRange ", NULL);
      Tcl_AppendResult(interp, "GetMCPVoltage ", NULL);
      Tcl_AppendResult(interp, "GetMetaDataInfo ", NULL);
      Tcl_AppendResult(interp, "GetMinimumImageLength ", NULL);
      Tcl_AppendResult(interp, "GetMostRecentColorImage16  ", NULL);
      Tcl_AppendResult(interp, "GetMostRecentImage  ", NULL);
      Tcl_AppendResult(interp, "GetMostRecentImage16  ", NULL);
      Tcl_AppendResult(interp, "GetMSTimingsData ", NULL);
      Tcl_AppendResult(interp, "GetMSTimingsEnabled ", NULL);
      Tcl_AppendResult(interp, "GetNewData ", NULL);
      Tcl_AppendResult(interp, "GetNewData16 ", NULL);
      Tcl_AppendResult(interp, "GetNewData8 ", NULL);
      Tcl_AppendResult(interp, "GetNewFloatData ", NULL);
      Tcl_AppendResult(interp, "GetNumberADChannels ", NULL);
      Tcl_AppendResult(interp, "GetNumberAmp ", NULL);
      Tcl_AppendResult(interp, "GetNumberAvailableImages  ", NULL);
      Tcl_AppendResult(interp, "GetNumberDevices ", NULL);
      Tcl_AppendResult(interp, "GetNumberFKVShiftSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberHorizontalSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberHSSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberNewImages  ", NULL);
      Tcl_AppendResult(interp, "GetNumberPreAmpGains ", NULL);
      Tcl_AppendResult(interp, "GetNumberRingExposureTimes ", NULL);
      Tcl_AppendResult(interp, "GetNumberIO ", NULL);
      Tcl_AppendResult(interp, "GetNumberVerticalSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetNumberVSAmplitudes ", NULL);
      Tcl_AppendResult(interp, "GetNumberVSSpeeds ", NULL);
      Tcl_AppendResult(interp, "GetOldestImage  ", NULL);
      Tcl_AppendResult(interp, "GetOldestImage16  ", NULL);
      Tcl_AppendResult(interp, "GetPhysicalDMAAddress ", NULL);
      Tcl_AppendResult(interp, "GetPixelSize ", NULL);
      Tcl_AppendResult(interp, "GetPreAmpGain ", NULL);
      Tcl_AppendResult(interp, "GetReadOutTime ", NULL);
      Tcl_AppendResult(interp, "GetRegisterDump ", NULL);
      Tcl_AppendResult(interp, "GetRingExposureRange ", NULL);
      Tcl_AppendResult(interp, "GetSizeOfCircularBuffer  ", NULL);
      Tcl_AppendResult(interp, "GetSlotBusDeviceFunction ", NULL);
      Tcl_AppendResult(interp, "GetSoftwareVersion ", NULL);
      Tcl_AppendResult(interp, "GetSpoolProgress ", NULL);
      Tcl_AppendResult(interp, "GetStatus ", NULL);
      Tcl_AppendResult(interp, "GetTemperature ", NULL);
      Tcl_AppendResult(interp, "GetTemperatureF ", NULL);
      Tcl_AppendResult(interp, "GetTemperatureRange ", NULL);
      Tcl_AppendResult(interp, "GetTemperatureStatus ", NULL);
      Tcl_AppendResult(interp, "GetTotalNumberImagesAcquired  ", NULL);
      Tcl_AppendResult(interp, "GetIODirection ", NULL);
      Tcl_AppendResult(interp, "GetIOLevel ", NULL);
      Tcl_AppendResult(interp, "GetVersionInfo ", NULL);
      Tcl_AppendResult(interp, "GetVerticalSpeed ", NULL);
      Tcl_AppendResult(interp, "GetVirtualDMAAdress ", NULL);
      Tcl_AppendResult(interp, "GetVSSpeed ", NULL);
      Tcl_AppendResult(interp, "GPIBReceive ", NULL);
      Tcl_AppendResult(interp, "GPIBSend ", NULL);
      Tcl_AppendResult(interp, "I2CBurstRead ", NULL);
      Tcl_AppendResult(interp, "I2CBurstWrite ", NULL);
      Tcl_AppendResult(interp, "I2CRead ", NULL);
      Tcl_AppendResult(interp, "I2CReset ", NULL);
      Tcl_AppendResult(interp, "I2CWrite ", NULL);
      Tcl_AppendResult(interp, "IdAndorDll ", NULL);
      Tcl_AppendResult(interp, "InAuxPort ", NULL);
      Tcl_AppendResult(interp, "Initialize ", NULL);
      Tcl_AppendResult(interp, "InitializeDevice ", NULL);
      Tcl_AppendResult(interp, "IsInternalMechanicalShutter ", NULL);
      Tcl_AppendResult(interp, "IsAmplifierAvailable ", NULL);
      Tcl_AppendResult(interp, "IsPreAmpGainAvailable ", NULL);
      Tcl_AppendResult(interp, "IsTriggerModeAvailable ", NULL);
      Tcl_AppendResult(interp, "Merge ", NULL);
      Tcl_AppendResult(interp, "OutAuxPort ", NULL);
      Tcl_AppendResult(interp, "PrepareAcquisition ", NULL);
      Tcl_AppendResult(interp, "SaveAsBmp ", NULL);
      Tcl_AppendResult(interp, "SaveAsCommentedSif ", NULL);
      Tcl_AppendResult(interp, "SaveAsEDF ", NULL);
      Tcl_AppendResult(interp, "SaveAsFITS ", NULL);
      Tcl_AppendResult(interp, "SaveAsRaw ", NULL);
      Tcl_AppendResult(interp, "SaveAsSif ", NULL);
      Tcl_AppendResult(interp, "SaveAsSPC ", NULL);
      Tcl_AppendResult(interp, "SaveAsTiff ", NULL);
      Tcl_AppendResult(interp, "SaveAsTiffEx ", NULL);
      Tcl_AppendResult(interp, "SaveEEPROMToFile ", NULL);
      Tcl_AppendResult(interp, "SaveToClipBoard ", NULL);
      Tcl_AppendResult(interp, "SelectDevice ", NULL);
      Tcl_AppendResult(interp, "SendSoftwareTrigger ", NULL);
      Tcl_AppendResult(interp, "SetAccumulationCycleTime ", NULL);
      Tcl_AppendResult(interp, "SetAcqStatusEvent ", NULL);
      Tcl_AppendResult(interp, "SetAcquisitionMode ", NULL);
      Tcl_AppendResult(interp, "SetAcquisitionType ", NULL);
      Tcl_AppendResult(interp, "SetADChannel ", NULL);
      Tcl_AppendResult(interp, "SetAdvancedTriggerModeState ", NULL);
      Tcl_AppendResult(interp, "SetBackground ", NULL);
      Tcl_AppendResult(interp, "SetBaselineClamp ", NULL);
      Tcl_AppendResult(interp, "SetBaselineOffset ", NULL);
      Tcl_AppendResult(interp, "SetCameraStatusEnable ", NULL);
      Tcl_AppendResult(interp, "SetComplexImage ", NULL);
      Tcl_AppendResult(interp, "SetCoolerMode ", NULL);
      Tcl_AppendResult(interp, "SetCropMode ", NULL);
      Tcl_AppendResult(interp, "SetCurrentCamera ", NULL);
      Tcl_AppendResult(interp, "SetCustomTrackHBin ", NULL);
      Tcl_AppendResult(interp, "SetDACOutputScale ", NULL);
      Tcl_AppendResult(interp, "SetDACOutput ", NULL);
      Tcl_AppendResult(interp, "SetDataType ", NULL);
      Tcl_AppendResult(interp, "SetDDGAddress ", NULL);
      Tcl_AppendResult(interp, "SetDDGGain ", NULL);
      Tcl_AppendResult(interp, "SetDDGGateStep ", NULL);
      Tcl_AppendResult(interp, "SetDDGInsertionDelay ", NULL);
      Tcl_AppendResult(interp, "SetDDGIntelligate ", NULL);
      Tcl_AppendResult(interp, "SetDDGIOC ", NULL);
      Tcl_AppendResult(interp, "SetDDGIOCFrequency ", NULL);
      Tcl_AppendResult(interp, "SetDDGIOCNumber ", NULL);
      Tcl_AppendResult(interp, "SetDDGTimes ", NULL);
      Tcl_AppendResult(interp, "SetDDGTriggerMode ", NULL);
      Tcl_AppendResult(interp, "SetDDGVariableGateStep ", NULL);
      Tcl_AppendResult(interp, "SetDelayGenerator ", NULL);
      Tcl_AppendResult(interp, "SetDMAParameters ", NULL);
      Tcl_AppendResult(interp, "SetDriverEvent ", NULL);
      Tcl_AppendResult(interp, "SetEMAdvanced ", NULL);
      Tcl_AppendResult(interp, "SetEMCCDGain ", NULL);
      Tcl_AppendResult(interp, "SetEMClockCompensation ", NULL);
      Tcl_AppendResult(interp, "SetEMGainMode ", NULL);
      Tcl_AppendResult(interp, "SetExposureTime ", NULL);
      Tcl_AppendResult(interp, "SetFanMode ", NULL);
      Tcl_AppendResult(interp, "SetFastKinetics ", NULL);
      Tcl_AppendResult(interp, "SetFastKineticsEx ", NULL);
      Tcl_AppendResult(interp, "SetFilterMode ", NULL);
      Tcl_AppendResult(interp, "SetFilterParameters ", NULL);
      Tcl_AppendResult(interp, "SetFKVShiftSpeed ", NULL);
      Tcl_AppendResult(interp, "SetFPDP ", NULL);
      Tcl_AppendResult(interp, "SetFrameTransferMode ", NULL);
      Tcl_AppendResult(interp, "SetFullImage ", NULL);
      Tcl_AppendResult(interp, "SetFVBHBin ", NULL);
      Tcl_AppendResult(interp, "SetGain ", NULL);
      Tcl_AppendResult(interp, "SetGate ", NULL);
      Tcl_AppendResult(interp, "SetGateMode ", NULL);
      Tcl_AppendResult(interp, "SetHighCapacity ", NULL);
      Tcl_AppendResult(interp, "SetHorizontalSpeed ", NULL);
      Tcl_AppendResult(interp, "SetHSSpeed ", NULL);
      Tcl_AppendResult(interp, "SetImage ", NULL);
      Tcl_AppendResult(interp, "SetImageFlip ", NULL);
      Tcl_AppendResult(interp, "SetImageRotate ", NULL);
      Tcl_AppendResult(interp, "SetIsolatedCropMode  ", NULL);
      Tcl_AppendResult(interp, "SetKineticCycleTime ", NULL);
      Tcl_AppendResult(interp, "SetMCPGain ", NULL);
      Tcl_AppendResult(interp, "SetMCPGating ", NULL);
      Tcl_AppendResult(interp, "SetMessageWindow ", NULL);
      Tcl_AppendResult(interp, "SetMetaData ", NULL);
      Tcl_AppendResult(interp, "SetMultiTrack ", NULL);
      Tcl_AppendResult(interp, "SetMultiTrackHBin ", NULL);
      Tcl_AppendResult(interp, "SetMultiTrackHRange ", NULL);
      Tcl_AppendResult(interp, "SetNextAddress ", NULL);
      Tcl_AppendResult(interp, "SetNextAddress16 ", NULL);
      Tcl_AppendResult(interp, "SetNumberAccumulations ", NULL);
      Tcl_AppendResult(interp, "SetNumberKinetics ", NULL);
      Tcl_AppendResult(interp, "SetNumberPrescans ", NULL);
      Tcl_AppendResult(interp, "SetOutputAmplifier ", NULL);
      Tcl_AppendResult(interp, "SetOverlapMode ", NULL);
      Tcl_AppendResult(interp, "SetPCIMode ", NULL);
      Tcl_AppendResult(interp, "SetPhotonCounting ", NULL);
      Tcl_AppendResult(interp, "SetPhotonCountingThreshold ", NULL);
      Tcl_AppendResult(interp, "SetPixelMode ", NULL);
      Tcl_AppendResult(interp, "SetPreAmpGain ", NULL);
      Tcl_AppendResult(interp, "SetRandomTracks ", NULL);
      Tcl_AppendResult(interp, "SetReadMode ", NULL);
      Tcl_AppendResult(interp, "SetRegisterDump ", NULL);
      Tcl_AppendResult(interp, "SetRingExposureTimes ", NULL);
      Tcl_AppendResult(interp, "SetSaturationEvent ", NULL);
      Tcl_AppendResult(interp, "SetShutter ", NULL);
      Tcl_AppendResult(interp, "SetShutterEx ", NULL);
      Tcl_AppendResult(interp, "SetShutters ", NULL);
      Tcl_AppendResult(interp, "SetSifComment ", NULL);
      Tcl_AppendResult(interp, "SetSingleTrack ", NULL);
      Tcl_AppendResult(interp, "SetSingleTrackHBin ", NULL);
      Tcl_AppendResult(interp, "SetSpool ", NULL);
      Tcl_AppendResult(interp, "SetStorageMode ", NULL);
      Tcl_AppendResult(interp, "SetTemperature ", NULL);
      Tcl_AppendResult(interp, "SetTriggerInvert ", NULL);
      Tcl_AppendResult(interp, "SetTriggerMode ", NULL);
      Tcl_AppendResult(interp, "SetIODirection ", NULL);
      Tcl_AppendResult(interp, "SetIOLevel ", NULL);
      Tcl_AppendResult(interp, "SetUSEvent ", NULL);
      Tcl_AppendResult(interp, "SetUSGenomics ", NULL);
      Tcl_AppendResult(interp, "SetVerticalRowBuffer ", NULL);
      Tcl_AppendResult(interp, "SetVerticalSpeed ", NULL);
      Tcl_AppendResult(interp, "SetVirtualChip ", NULL);
      Tcl_AppendResult(interp, "SetVSAmplitude ", NULL);
      Tcl_AppendResult(interp, "SetVSSpeed ", NULL);
      Tcl_AppendResult(interp, "ShutDown ", NULL);
      Tcl_AppendResult(interp, "StartAcquisition ", NULL);
      Tcl_AppendResult(interp, "UnMapPhysicalAddress ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisition ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisitionByHandle ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisitionByHandleTimeOut ", NULL);
      Tcl_AppendResult(interp, "WaitForAcquisitionTimeOut ", NULL);
      Tcl_AppendResult(interp, "WhiteBalance ", NULL);
      
      return TCL_ERROR;
   }
   
   return TCL_OK;
}

int cmdAndorAcqmode(ClientData clientData, Tcl_Interp * interp, int argc,
                    char *argv[])
{
   return 0;
}

int cmdAndorElectronic(ClientData clientData, Tcl_Interp * interp, int argc,
                       char *argv[])
{
   return 0;
}
