/* camtcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

int cmdAndorClosingtime(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Get|Set Closing time of the shuffetof the Andor camera                                                  */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
   if (argc>=3) {
      cam->closingtime=(int)abs(atoi(argv[2]));
   }
   sprintf(ligne,"%d",cam->closingtime);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdAndorOpeningtime(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Get|Set Opening time of the shuffetof the Andor camera                                                  */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
   if (argc>=3) {
      cam->openingtime=(int)abs(atoi(argv[2]));
   }
   sprintf(ligne,"%d",cam->openingtime);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdAndorNative(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* appel direct aux fonctions natives du driver Andor */
/***************************************************************************************/
   char ligne[1024];
   int result = TCL_OK,found,res;
   struct camprop *cam;
	int param_int[10];
   unsigned int param_uint[10];
   long param_long[10];
	unsigned long param_ulong[10];
	float param_float[10];
	DWORD param_DWORD[10];
	/*unsigned short param_ushort[10];*/
	ColorDemosaicInfo param_cdemo[10];
	WORD param_WORD[10];
	BYTE param_BYTE[10];
	WhiteBalanceInfo param_wbal[10];
	AndorCapabilities param_acap[10];
	char param_char[10][100];
	double param_double[10];
	SYSTEMTIME param_stime[10];
	unsigned char param_uchar[10][100];
	short param_short[10];
   cam = (struct camprop *)clientData;
   Tcl_SetResult(interp,"",TCL_VOLATILE);


   found=1;
   if (argc>2) {
      if (strcmp(argv[2],"AbortAcquisition")==0) {
         AbortAcquisition();
      } else if (strcmp(argv[2],"CancelWait")==0) {
         CancelWait();
      } else if (strcmp(argv[2],"CoolerOFF")==0) {
         CoolerOFF();
      } else if (strcmp(argv[2],"CoolerON")==0) {
         CoolerON();
      } else if (strcmp(argv[2],"DemosaicImage")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=DemosaicImage(&param_WORD[0],&param_WORD[1],&param_WORD[2],&param_WORD[3],&param_cdemo[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %p ",param_WORD[0],param_WORD[1],param_WORD[2],param_WORD[3],&param_cdemo[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"EnableKeepCleans")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=EnableKeepCleans(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"FreeInternalMemory")==0) {
         FreeInternalMemory();
      } else if (strcmp(argv[2],"GetAcquiredData")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetAcquiredData(&param_long[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAcquiredData16")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetAcquiredData16(&param_WORD[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld ",param_WORD[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAcquiredFloatData")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetAcquiredFloatData(&param_float[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %ld ",param_float[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAcquisitionProgress")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetAcquisitionProgress(&param_long[0],&param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAcquisitionTimings")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetAcquisitionTimings(&param_float[0],&param_float[1],&param_float[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f %f ",param_float[0],param_float[1],param_float[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAdjustedRingExposureTimes")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetAdjustedRingExposureTimes(param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAllDMAData")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetAllDMAData(&param_long[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAmpDesc")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            strcpy(param_char[1],argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=GetAmpDesc(param_int[0],param_char[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %s %d ",param_int[0],param_char[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAmpMaxSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetAmpMaxSpeed(param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetAvailableCameras")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetAvailableCameras(&param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetBackground")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetBackground(&param_long[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetBaselineClamp")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetBaselineClamp(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetBitDepth")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetBitDepth(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCameraEventStatus")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetCameraEventStatus(&param_DWORD[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_DWORD[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCameraHandle")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            res=GetCameraHandle(param_long[0],&param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCameraInformation")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetCameraInformation(param_int[0],&param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld ",param_int[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCameraSerialNumber")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetCameraSerialNumber(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCapabilities")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetCapabilities(&param_acap[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%p ",&param_acap[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetControllerCardModel")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=GetControllerCardModel(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCountConvertWavelengthRange")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetCountConvertWavelengthRange(&param_float[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f ",param_float[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCurrentCamera")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetCurrentCamera(&param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetCYMGShift")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetCYMGShift(&param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGExternalOutputEnabled")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=GetDDGExternalOutputEnabled(param_ulong[0],&param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGExternalOutputPolarity")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=GetDDGExternalOutputPolarity(param_ulong[0],&param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGExternalOutputStepEnabled")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=GetDDGExternalOutputStepEnabled(param_ulong[0],&param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGExternalOutputTime")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=GetDDGExternalOutputTime(param_ulong[0],(unsigned __int64 *)&param_int[1],(unsigned __int64 *)&param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %d %d ",param_ulong[0],param_int[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGTTLGateWidth")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetDDGTTLGateWidth(param_int[0],(unsigned __int64 *)&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGGateTime")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGGateTime((unsigned __int64 *)&param_int[0],(unsigned __int64 *)&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGInsertionDelay")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGInsertionDelay(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIntelligate")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIntelligate(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIOC")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOC(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIOCFrequency")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOCFrequency(&param_double[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%lf ",param_double[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIOCNumber")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOCNumber(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIOCNumberRequested")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOCNumberRequested(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIOCPeriod")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOCPeriod((unsigned __int64 *)&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIOCPulses")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOCPulses(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGIOCTrigger")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGIOCTrigger(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGOpticalWidthEnabled")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGOpticalWidthEnabled(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGLiteGlobalControlByte")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGLiteGlobalControlByte(param_uchar[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_uchar[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGLiteControlByte")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetDDGLiteControlByte((AT_DDGLiteChannelId)param_int[0],param_uchar[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %s ",param_int[0],param_uchar[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGLiteInitialDelay")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetDDGLiteInitialDelay((AT_DDGLiteChannelId)param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGLitePulseWidth")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetDDGLitePulseWidth((AT_DDGLiteChannelId)param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGLiteInterPulseDelay")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetDDGLiteInterPulseDelay((AT_DDGLiteChannelId)param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGLitePulsesPerExposure")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetDDGLitePulsesPerExposure((AT_DDGLiteChannelId)param_int[0],&param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld ",param_int[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGPulse")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s double double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_double[0]=(double)atof(argv[3]);
            param_double[1]=(double)atof(argv[4]);
            res=GetDDGPulse(param_double[0],param_double[1],&param_double[2],&param_double[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%lf %lf %lf %lf ",param_double[0],param_double[1],param_double[2],param_double[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGStepCoefficients")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=GetDDGStepCoefficients(param_ulong[0],&param_double[1],&param_double[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %lf %lf ",param_ulong[0],param_double[1],param_double[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGWidthStepCoefficients")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=GetDDGWidthStepCoefficients(param_ulong[0],&param_double[1],&param_double[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %lf %lf ",param_ulong[0],param_double[1],param_double[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGStepMode")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGStepMode(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDDGWidthStepMode")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDDGWidthStepMode(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDetector")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDetector(&param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDICameraInfo")==0) {
      } else if (strcmp(argv[2],"GetEMAdvanced")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetEMAdvanced(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetEMCCDGain")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetEMCCDGain(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetEMGainRange")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetEMGainRange(&param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetExternalTriggerTermination")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetExternalTriggerTermination(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetFastestRecommendedVSSpeed")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFastestRecommendedVSSpeed(&param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetFIFOUsage")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFIFOUsage(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetFilterMode")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFilterMode(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetFKExposureTime")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFKExposureTime(&param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetFKVShiftSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetFKVShiftSpeed(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetFKVShiftSpeedF")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetFKVShiftSpeedF(param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetFrontEndStatus")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetFrontEndStatus(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetGateMode")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetGateMode(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetHardwareVersion")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetHardwareVersion((unsigned int *)&param_int[0],(unsigned int *)&param_int[1],(unsigned int *)&param_int[2],(unsigned int *)&param_int[3],(unsigned int *)&param_int[4],(unsigned int *)&param_int[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4],param_int[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetHeadModel")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=GetHeadModel(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetHorizontalSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetHorizontalSpeed(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetHSSpeed")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=GetHSSpeed(param_int[0],param_int[1],param_int[2],&param_float[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %f ",param_int[0],param_int[1],param_int[2],param_float[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetHVflag")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetHVflag(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetID")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetID(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetImageFlip")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetImageFlip(&param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetImageRotate")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetImageRotate(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetImages")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s long long unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            param_long[1]=(long)atol(argv[4]);
            param_ulong[3]=(unsigned long)atol(argv[5]);
            res=GetImages(param_long[0],param_long[1],&param_long[2],param_ulong[3],&param_long[4],&param_long[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %ld %ld %ld %ld ",param_long[0],param_long[1],param_long[2],param_ulong[3],param_long[4],param_long[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetImages16")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s long long unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            param_long[1]=(long)atol(argv[4]);
            param_ulong[3]=(unsigned long)atol(argv[5]);
            res=GetImages16(param_long[0],param_long[1],&param_WORD[2],param_ulong[3],&param_long[4],&param_long[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %d %ld %ld %ld ",param_long[0],param_long[1],param_WORD[2],param_ulong[3],param_long[4],param_long[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetImagesPerDMA")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetImagesPerDMA(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetIRQ")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetIRQ(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetKeepCleanTime")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetKeepCleanTime(&param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMaximumBinning")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=GetMaximumBinning(param_int[0],param_int[1],&param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_int[0],param_int[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMaximumExposure")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetMaximumExposure(&param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMaximumNumberRingExposureTimes")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetMaximumNumberRingExposureTimes(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMCPGain")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetMCPGain(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMCPGainRange")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetMCPGainRange(&param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMCPGainTable")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetMCPGainTable(param_int[0],&param_int[1],&param_float[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %f ",param_int[0],param_int[1],param_float[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMCPVoltage")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetMCPVoltage(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMinimumImageLength")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetMinimumImageLength(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMinimumNumberInSeries")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetMinimumNumberInSeries(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMostRecentColorImage16")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s unsigned long int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=GetMostRecentColorImage16(param_ulong[0],param_int[1],&param_WORD[2],&param_WORD[3],&param_WORD[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %d %d %d %d ",param_ulong[0],param_int[1],param_WORD[2],param_WORD[3],param_WORD[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMostRecentImage")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetMostRecentImage(&param_long[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMostRecentImage16")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetMostRecentImage16(&param_WORD[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld ",param_WORD[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMSTimingsData")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[2]=(int)atoi(argv[3]);
            res=GetMSTimingsData(&param_stime[0],&param_float[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%p %f %d ",&param_stime[0],param_float[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMetaDataInfo")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[2]=(int)atoi(argv[3]);
            res=GetMetaDataInfo(&param_stime[0],&param_float[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%p %f %d ",&param_stime[0],param_float[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetMSTimingsEnabled")==0) {
         GetMSTimingsEnabled();
      } else if (strcmp(argv[2],"GetRelativeImageTimes")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s unsigned int unsigned int unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[3]=(int)atoi(argv[5]);
            res=GetRelativeImageTimes(param_int[0],param_int[1],(unsigned __int64 *)&param_int[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNewData")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetNewData(&param_long[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNewData16")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetNewData16(&param_WORD[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld ",param_WORD[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNewData8")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetNewData8(param_uchar[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %ld ",param_uchar[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNewFloatData")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetNewFloatData(&param_float[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %ld ",param_float[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberADChannels")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberADChannels(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberAmp")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberAmp(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberAvailableImages")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberAvailableImages(&param_long[0],&param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberDDGExternalOutputs")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberDDGExternalOutputs(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberDevices")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberDevices(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberFKVShiftSpeeds")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberFKVShiftSpeeds(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberHorizontalSpeeds")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberHorizontalSpeeds(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberHSSpeeds")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=GetNumberHSSpeeds(param_int[0],param_int[1],&param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_int[0],param_int[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberNewImages")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberNewImages(&param_long[0],&param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberPhotonCountingDivisions")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberPhotonCountingDivisions(&param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberPreAmpGains")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberPreAmpGains(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberRingExposureTimes")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberRingExposureTimes(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberIO")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberIO(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }
      else if (strcmp(argv[2], "GetNumberVerticalSpeeds") == 0) {
         if (argc < 3) {
            sprintf(ligne, "Usage: %s %s %s ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else {
            strcpy(ligne, "");
            res = GetNumberVerticalSpeeds(&param_int[0]);
            if (res != DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else {
               ;
               sprintf(ligne, "%d ", param_int[0]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }


      if (strcmp(argv[2],"GetNumberVSAmplitudes")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberVSAmplitudes(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetNumberVSSpeeds")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetNumberVSSpeeds(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetOldestImage")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetOldestImage(&param_long[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetOldestImage16")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=GetOldestImage16(&param_WORD[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld ",param_WORD[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetPhosphorStatus")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetPhosphorStatus(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetPhysicalDMAAddress")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetPhysicalDMAAddress(&param_ulong[0],&param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetPixelSize")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetPixelSize(&param_float[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f ",param_float[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetPreAmpGain")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetPreAmpGain(param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetPreAmpGainText")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            strcpy(param_char[1],argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=GetPreAmpGainText(param_int[0],param_char[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %s %d ",param_int[0],param_char[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetDualExposureTimes")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetDualExposureTimes(&param_float[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f ",param_float[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetQE")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s char* float unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            param_float[1]=(float)atof(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=GetQE(param_char[0],param_float[1],param_int[2],&param_float[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %f %d %f ",param_char[0],param_float[1],param_int[2],param_float[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetReadOutTime")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetReadOutTime(&param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetRegisterDump")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetRegisterDump(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetRingExposureRange")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetRingExposureRange(&param_float[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f ",param_float[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetSDK3Handle")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSDK3Handle(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetSensitivity")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            res=GetSensitivity(param_int[0],param_int[1],param_int[2],param_int[3],&param_float[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %f ",param_int[0],param_int[1],param_int[2],param_int[3],param_float[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetShutterMinTimes")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetShutterMinTimes(&param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetSizeOfCircularBuffer")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSizeOfCircularBuffer(&param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetSlotBusDeviceFunction")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSlotBusDeviceFunction(&param_DWORD[0],&param_DWORD[1],&param_DWORD[2],&param_DWORD[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d ",param_DWORD[0],param_DWORD[1],param_DWORD[2],param_DWORD[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetSoftwareVersion")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSoftwareVersion(&param_uint[0],&param_uint[1],&param_uint[2],&param_uint[3],&param_uint[4],&param_uint[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d %d ", param_uint[0], param_uint[1], param_uint[2], param_uint[3], param_uint[4], param_uint[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetSpoolProgress")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetSpoolProgress(&param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetStartUpTime")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetStartUpTime(&param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetStatus")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetStatus(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetTECStatus")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTECStatus(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetTemperature")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperature(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetTemperatureF")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperatureF(&param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetTemperatureRange")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperatureRange(&param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetTemperatureStatus")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTemperatureStatus(&param_float[0],&param_float[1],&param_float[2],&param_float[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f %f %f ",param_float[0],param_float[1],param_float[2],param_float[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetTotalNumberImagesAcquired")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTotalNumberImagesAcquired(&param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetIODirection")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetIODirection(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetIOLevel")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetIOLevel(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetVersionInfo")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s AT_VersionInfoId char* unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            AT_VersionInfoId versionInfoId =(AT_VersionInfoId)atoi(argv[3]);
            strcpy(param_char[1],argv[4]);
            param_ulong[2]=(unsigned long)atol(argv[5]);
            res=GetVersionInfo(versionInfoId,param_char[1],param_ulong[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %s %ld ",param_int[0],param_char[1],param_ulong[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetVerticalSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetVerticalSpeed(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetVirtualDMAAddress")==0) {
      } else if (strcmp(argv[2],"GetVSAmplitudeString")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            strcpy(param_char[1],argv[4]);
            res=GetVSAmplitudeString(param_int[0],param_char[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %s ",param_int[0],param_char[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetVSAmplitudeFromString")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=GetVSAmplitudeFromString(param_char[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ",param_char[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetVSAmplitudeValue")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetVSAmplitudeValue(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetVSSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=GetVSSpeed(param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GPIBReceive")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int short char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_short[1]=(short)atoi(argv[4]);
            strcpy(param_char[2],argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            res=GPIBReceive(param_int[0],param_short[1],param_char[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %s %d ",param_int[0],param_short[1],param_char[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GPIBSend")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int short char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_short[1]=(short)atoi(argv[4]);
            strcpy(param_char[2],argv[5]);
            res=GPIBSend(param_int[0],param_short[1],param_char[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %s ",param_int[0],param_short[1],param_char[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"I2CBurstRead")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s BYTE long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_BYTE[0]=(BYTE)atoi(argv[3]);
            param_long[1]=(long)atol(argv[4]);
            res=I2CBurstRead(param_BYTE[0],param_long[1],&param_BYTE[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld %d ",param_BYTE[0],param_long[1],param_BYTE[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"I2CBurstWrite")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s BYTE long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_BYTE[0]=(BYTE)atoi(argv[3]);
            param_long[1]=(long)atol(argv[4]);
            res=I2CBurstWrite(param_BYTE[0],param_long[1],&param_BYTE[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld %d ",param_BYTE[0],param_long[1],param_BYTE[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"I2CRead")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s BYTE BYTE ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_BYTE[0]=(BYTE)atoi(argv[3]);
            param_BYTE[1]=(BYTE)atoi(argv[4]);
            res=I2CRead(param_BYTE[0],param_BYTE[1],&param_BYTE[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_BYTE[0],param_BYTE[1],param_BYTE[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"I2CReset")==0) {
         I2CReset();
      } else if (strcmp(argv[2],"I2CWrite")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s BYTE BYTE BYTE ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_BYTE[0]=(BYTE)atoi(argv[3]);
            param_BYTE[1]=(BYTE)atoi(argv[4]);
            param_BYTE[2]=(BYTE)atoi(argv[5]);
            res=I2CWrite(param_BYTE[0],param_BYTE[1],param_BYTE[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_BYTE[0],param_BYTE[1],param_BYTE[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"IdAndorDll")==0) {
         IdAndorDll();
      } else if (strcmp(argv[2],"InAuxPort")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=InAuxPort(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Initialize")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=Initialize(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"InitializeDevice")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=InitializeDevice(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"IsAmplifierAvailable")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=IsAmplifierAvailable(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"IsCoolerOn")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=IsCoolerOn(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"IsCountConvertModeAvailable")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=IsCountConvertModeAvailable(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"IsInternalMechanicalShutter")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=IsInternalMechanicalShutter(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"IsPreAmpGainAvailable")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            res=IsPreAmpGainAvailable(param_int[0],param_int[1],param_int[2],param_int[3],&param_int[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"IsTriggerModeAvailable")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=IsTriggerModeAvailable(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Merge")==0) {
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s long long long long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[1]=(long)atol(argv[3]);
            param_long[2]=(long)atol(argv[4]);
            param_long[3]=(long)atol(argv[5]);
            param_long[5]=(long)atol(argv[6]);
            param_long[6]=(long)atol(argv[7]);
            res=Merge(&param_long[0],param_long[1],param_long[2],param_long[3],&param_float[4],param_long[5],param_long[6],&param_long[7],&param_float[8],&param_float[9]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %ld %ld %f %ld %ld %ld %f %f ", param_long[0],param_long[1],param_long[2],param_long[3],param_float[4],param_long[5],param_long[6],param_long[7],param_float[8],param_float[9]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OutAuxPort")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=OutAuxPort(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"PrepareAcquisition")==0) {
         PrepareAcquisition();
      } else if (strcmp(argv[2],"SaveAsBmp")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0], "path");
            strcpy(param_char[1], "palette");
            param_long[2]=(long)atol(argv[3]);
            param_long[3]=(long)atol(argv[4]);
            res=SaveAsBmp(param_char[0],param_char[1],param_long[2],param_long[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %s %ld %ld ", param_char[0], param_char[1],param_long[2],param_long[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsCommentedSif")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            strcpy(param_char[1],argv[4]);
            res=SaveAsCommentedSif(param_char[0],param_char[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %s ",param_char[0],param_char[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsEDF")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SaveAsEDF(param_char[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ",param_char[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsFITS")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SaveAsFITS(param_char[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ",param_char[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsRaw")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SaveAsRaw(param_char[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ",param_char[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsSif")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=SaveAsSif(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsSPC")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=SaveAsSPC(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsTiff")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s char* char* int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            strcpy(param_char[1],argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            res=SaveAsTiff(param_char[0],param_char[1],param_int[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %s %d %d ",param_char[0],param_char[1],param_int[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveAsTiffEx")==0) {
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s char* char* int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            strcpy(param_char[1],argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            res=SaveAsTiffEx(param_char[0],param_char[1],param_int[2],param_int[3],param_int[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %s %d %d %d ",param_char[0],param_char[1],param_int[2],param_int[3],param_int[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveEEPROMToFile")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=SaveEEPROMToFile(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SaveToClipBoard")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=SaveToClipBoard(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SelectDevice")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SelectDevice(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SendSoftwareTrigger")==0) {
         SendSoftwareTrigger();
      } else if (strcmp(argv[2],"SetAccumulationCycleTime")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            res=SetAccumulationCycleTime(param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetAcqStatusEvent")==0) {
      } else if (strcmp(argv[2],"SetAcquisitionMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetAcquisitionMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetAcquisitionType")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetAcquisitionType(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetADChannel")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetADChannel(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetAdvancedTriggerModeState")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetAdvancedTriggerModeState(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetBackground")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[1]=(unsigned long)atol(argv[3]);
            res=SetBackground(&param_long[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetBaselineClamp")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetBaselineClamp(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetBaselineOffset")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetBaselineOffset(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCameraLinkMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetCameraLinkMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCameraStatusEnable")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s DWORD ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_DWORD[0]=(DWORD)atoi(argv[3]);
            res=SetCameraStatusEnable(param_DWORD[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_DWORD[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetChargeShifting")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s unsigned int unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetChargeShifting(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetComplexImage")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetComplexImage(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCoolerMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetCoolerMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCountConvertMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetCountConvertMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCountConvertWavelength")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            res=SetCountConvertWavelength(param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCropMode")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=SetCropMode(param_int[0],param_int[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_int[0],param_int[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCurrentCamera")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            res=SetCurrentCamera(param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetCustomTrackHBin")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetCustomTrackHBin(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDataType")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDataType(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDACOutput")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=SetDACOutput(param_int[0],param_int[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_int[0],param_int[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDACOutputScale")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDACOutputScale(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGAddress")==0) {
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s BYTE BYTE BYTE BYTE BYTE ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_BYTE[0]=(BYTE)atoi(argv[3]);
            param_BYTE[1]=(BYTE)atoi(argv[4]);
            param_BYTE[2]=(BYTE)atoi(argv[5]);
            param_BYTE[3]=(BYTE)atoi(argv[6]);
            param_BYTE[4]=(BYTE)atoi(argv[7]);
            res=SetDDGAddress(param_BYTE[0],param_BYTE[1],param_BYTE[2],param_BYTE[3],param_BYTE[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d ",param_BYTE[0],param_BYTE[1],param_BYTE[2],param_BYTE[3],param_BYTE[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGExternalOutputEnabled")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s unsigned long unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            param_ulong[1]=(unsigned long)atol(argv[4]);
            res=SetDDGExternalOutputEnabled(param_ulong[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGExternalOutputPolarity")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s unsigned long unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            param_ulong[1]=(unsigned long)atol(argv[4]);
            res=SetDDGExternalOutputPolarity(param_ulong[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGExternalOutputStepEnabled")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s unsigned long unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            param_ulong[1]=(unsigned long)atol(argv[4]);
            res=SetDDGExternalOutputStepEnabled(param_ulong[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGExternalOutputTime")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s unsigned long unsigned long long unsigned long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=SetDDGExternalOutputTime(param_ulong[0],param_int[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %d %d ",param_ulong[0],param_int[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGGain")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDDGGain(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGGateStep")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_double[0]=(double)atof(argv[3]);
            res=SetDDGGateStep(param_double[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%lf ",param_double[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGGateTime")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s unsigned long long unsigned long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetDDGGateTime(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGInsertionDelay")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDDGInsertionDelay(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGIntelligate")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDDGIntelligate(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGIOC")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDDGIOC(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGIOCFrequency")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_double[0]=(double)atof(argv[3]);
            res=SetDDGIOCFrequency(param_double[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%lf ",param_double[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGIOCNumber")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=SetDDGIOCNumber(param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGIOCPeriod")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDDGIOCPeriod(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGIOCTrigger")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=SetDDGIOCTrigger(param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGOpticalWidthEnabled")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=SetDDGOpticalWidthEnabled(param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGLiteGlobalControlByte")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned char ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_uchar[0][0] = argv[3][0];
            res=SetDDGLiteGlobalControlByte(param_uchar[0][0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_uchar[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGLiteControlByte")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId unsigned char ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            AT_DDGLiteChannelId DDGLiteChannelId =(AT_DDGLiteChannelId)atoi(argv[3]);
            param_uchar[1][0] = argv[4][0];
            res=SetDDGLiteControlByte(DDGLiteChannelId,param_char[1][0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %s ",param_int[0],param_uchar[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGLiteInitialDelay")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_float[1]=(float)atof(argv[4]);
            res=SetDDGLiteInitialDelay((AT_DDGLiteChannelId) param_int[0],param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGLitePulseWidth")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_float[1]=(float)atof(argv[4]);
            res=SetDDGLitePulseWidth((AT_DDGLiteChannelId)param_int[0],param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGLiteInterPulseDelay")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_float[1]=(float)atof(argv[4]);
            res=SetDDGLiteInterPulseDelay((AT_DDGLiteChannelId)param_int[0],param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGLitePulsesPerExposure")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s AT_DDGLiteChannelId unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_ulong[1]=(unsigned long)atol(argv[4]);
            res=SetDDGLitePulsesPerExposure((AT_DDGLiteChannelId)param_int[0],param_ulong[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %ld ",param_int[0],param_ulong[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGStepCoefficients")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s unsigned long double double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            param_double[1]=(double)atof(argv[4]);
            param_double[2]=(double)atof(argv[5]);
            res=SetDDGStepCoefficients(param_ulong[0],param_double[1],param_double[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %lf %lf ",param_ulong[0],param_double[1],param_double[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGWidthStepCoefficients")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s unsigned long double double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            param_double[1]=(double)atof(argv[4]);
            param_double[2]=(double)atof(argv[5]);
            res=SetDDGWidthStepCoefficients(param_ulong[0],param_double[1],param_double[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %lf %lf ",param_ulong[0],param_double[1],param_double[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }
      else if (strcmp(argv[2], "SetDDGStepMode") == 0) {
         if (argc < 4) {
            sprintf(ligne, "Usage: %s %s %s unsigned long ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else {
            strcpy(ligne, "");
            param_ulong[0] = (unsigned long)atol(argv[3]);
            res = SetDDGStepMode(param_ulong[0]);
            if (res != DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else {
               ;
               sprintf(ligne, "%ld ", param_ulong[0]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }

      if (strcmp(argv[2],"SetDDGWidthStepMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=SetDDGWidthStepMode(param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDDGTimes")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s double double double ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_double[0]=(double)atof(argv[3]);
            param_double[1]=(double)atof(argv[4]);
            param_double[2]=(double)atof(argv[5]);
            res=SetDDGTimes(param_double[0],param_double[1],param_double[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%lf %lf %lf ",param_double[0],param_double[1],param_double[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }
      else if (strcmp(argv[2], "SetDDGTriggerMode") == 0) {
         if (argc < 4) {
            sprintf(ligne, "Usage: %s %s %s int ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else {
            strcpy(ligne, "");
            param_int[0] = (int)atoi(argv[3]);
            res = SetDDGTriggerMode(param_int[0]);
            if (res != DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else {
               ;
               sprintf(ligne, "%d ", param_int[0]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2], "SetDDGVariableGateStep") == 0) {
         if (argc < 6) {
            sprintf(ligne, "Usage: %s %s %s int double double ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else {
            strcpy(ligne, "");
            param_int[0] = (int)atoi(argv[3]);
            param_double[1] = (double)atof(argv[4]);
            param_double[2] = (double)atof(argv[5]);
            res = SetDDGVariableGateStep(param_int[0], param_double[1], param_double[2]);
            if (res != DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else {
               ;
               sprintf(ligne, "%d %lf %lf ", param_int[0], param_double[1], param_double[2]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }

      
      if (strcmp(argv[2],"SetDelayGenerator")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int short int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_short[1]=(short)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=SetDelayGenerator(param_int[0],param_short[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_int[0],param_short[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDMAParameters")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_float[1]=(float)atof(argv[4]);
            res=SetDMAParameters(param_int[0],param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDriverEvent")==0) {
      } else if (strcmp(argv[2],"SetEMAdvanced")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetEMAdvanced(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetEMCCDGain")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetEMCCDGain(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetEMClockCompensation")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetEMClockCompensation(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetEMGainMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetEMGainMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetExposureTime")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            res=SetExposureTime(param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetExternalTriggerTermination")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=SetExternalTriggerTermination(param_ulong[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_ulong[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFanMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetFanMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFastExtTrigger")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetFastExtTrigger(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFastKinetics")==0) {
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int int float int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_float[2]=(float)atof(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            param_int[5]=(int)atoi(argv[8]);
            res=SetFastKinetics(param_int[0],param_int[1],param_float[2],param_int[3],param_int[4],param_int[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %f %d %d %d ",param_int[0],param_int[1],param_float[2],param_int[3],param_int[4],param_int[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFastKineticsEx")==0) {
         if (argc<10) {
            sprintf(ligne,"Usage: %s %s %s int int float int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_float[2]=(float)atof(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            param_int[5]=(int)atoi(argv[8]);
            param_int[6]=(int)atoi(argv[9]);
            res=SetFastKineticsEx(param_int[0],param_int[1],param_float[2],param_int[3],param_int[4],param_int[5],param_int[6]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %f %d %d %d %d ",param_int[0],param_int[1],param_float[2],param_int[3],param_int[4],param_int[5],param_int[6]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFilterMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetFilterMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFilterParameters")==0) {
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int float int float int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_float[1]=(float)atof(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_float[3]=(float)atof(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            param_int[5]=(int)atoi(argv[8]);
            res=SetFilterParameters(param_int[0],param_float[1],param_int[2],param_float[3],param_int[4],param_int[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f %d %f %d %d ",param_int[0],param_float[1],param_int[2],param_float[3],param_int[4],param_int[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFKVShiftSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetFKVShiftSpeed(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFPDP")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetFPDP(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFrameTransferMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetFrameTransferMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFrontEndEvent")==0) {
      } else if (strcmp(argv[2],"SetFullImage")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetFullImage(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetFVBHBin")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetFVBHBin(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetGain")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetGain(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetGate")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s float float float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            param_float[1]=(float)atof(argv[4]);
            param_float[2]=(float)atof(argv[5]);
            res=SetGate(param_float[0],param_float[1],param_float[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f %f ",param_float[0],param_float[1],param_float[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetGateMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetGateMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetHighCapacity")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetHighCapacity(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetHorizontalSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetHorizontalSpeed(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetHSSpeed")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetHSSpeed(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetImage")==0) {
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            param_int[5]=(int)atoi(argv[8]);
            res=SetImage(param_int[0],param_int[1],param_int[2],param_int[3],param_int[4],param_int[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4],param_int[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetImageFlip")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetImageFlip(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetImageRotate")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetImageRotate(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetIsolatedCropMode")==0) {
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            res=SetIsolatedCropMode(param_int[0],param_int[1],param_int[2],param_int[3],param_int[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetKineticCycleTime")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            res=SetKineticCycleTime(param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetMCPGain")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetMCPGain(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetMCPGating")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetMCPGating(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetMessageWindow")==0) {
      } else if (strcmp(argv[2],"SetMetaData")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetMetaData(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetMultiTrack")==0) {
         if (argc<6) {
            sprintf(ligne,"Usage: %s %s %s int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            res=SetMultiTrack(param_int[0],param_int[1],param_int[2],&param_int[3],&param_int[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetMultiTrackHBin")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetMultiTrackHBin(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetMultiTrackHRange")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetMultiTrackHRange(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetMultiTrackScan")==0) {
         if (argc<13) {
            sprintf(ligne,"Usage: %s %s %s int int int int int int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            param_int[5]=(int)atoi(argv[8]);
            param_int[6]=(int)atoi(argv[9]);
            param_int[7]=(int)atoi(argv[10]);
            param_int[8]=(int)atoi(argv[11]);
            param_int[9]=(int)atoi(argv[12]);
            res=SetMultiTrackScan(param_int[0],param_int[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_int[7],param_int[8],param_int[9]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d %d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_int[7],param_int[8],param_int[9]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetNextAddress")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s long long long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[1]=(long)atol(argv[3]);
            param_long[2]=(long)atol(argv[4]);
            param_long[3]=(long)atol(argv[5]);
            param_long[4]=(long)atol(argv[6]);
            res=SetNextAddress(&param_long[0],param_long[1],param_long[2],param_long[3],param_long[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %ld %ld %ld ",param_long[0],param_long[1],param_long[2],param_long[3],param_long[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetNextAddress16")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s long long long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[1]=(long)atol(argv[3]);
            param_long[2]=(long)atol(argv[4]);
            param_long[3]=(long)atol(argv[5]);
            param_long[4]=(long)atol(argv[6]);
            res=SetNextAddress16(&param_long[0],param_long[1],param_long[2],param_long[3],param_long[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %ld %ld %ld ",param_long[0],param_long[1],param_long[2],param_long[3],param_long[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetNumberAccumulations")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetNumberAccumulations(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetNumberKinetics")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetNumberKinetics(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetNumberPrescans")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetNumberPrescans(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetOutputAmplifier")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetOutputAmplifier(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetOverlapMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetOverlapMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetPCIMode")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetPCIMode(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetPhotonCounting")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetPhotonCounting(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetPhotonCountingThreshold")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            param_long[1]=(long)atol(argv[4]);
            res=SetPhotonCountingThreshold(param_long[0],param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetPhosphorEvent")==0) {
      } else if (strcmp(argv[2],"SetPhotonCountingDivisions")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_ulong[0]=(unsigned long)atol(argv[3]);
            res=SetPhotonCountingDivisions(param_ulong[0],&param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_ulong[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetPixelMode")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetPixelMode(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetPreAmpGain")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetPreAmpGain(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDualExposureTimes")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s float float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            param_float[1]=(float)atof(argv[4]);
            res=SetDualExposureTimes(param_float[0],param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f ",param_float[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetDualExposureMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetDualExposureMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetRandomTracks")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetRandomTracks(param_int[0],&param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetReadMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetReadMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetReadoutRegisterPacking")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetReadoutRegisterPacking(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetRegisterDump")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetRegisterDump(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetRingExposureTimes")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetRingExposureTimes(param_int[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %f ",param_int[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetSaturationEvent")==0) {
      } else if (strcmp(argv[2],"SetShutter")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            res=SetShutter(param_int[0],param_int[1],param_int[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetShutterEx")==0) {
         if (argc<8) {
            sprintf(ligne,"Usage: %s %s %s int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            res=SetShutterEx(param_int[0],param_int[1],param_int[2],param_int[3],param_int[4]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetShutters")==0) {
         if (argc<11) {
            sprintf(ligne,"Usage: %s %s %s int int int int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            param_int[2]=(int)atoi(argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            param_int[4]=(int)atoi(argv[7]);
            param_int[5]=(int)atoi(argv[8]);
            param_int[6]=(int)atoi(argv[9]);
            param_int[7]=(int)atoi(argv[10]);
            res=SetShutters(param_int[0],param_int[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_int[7]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %d %d %d %d %d ",param_int[0],param_int[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_int[7]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetSifComment")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=SetSifComment(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetSingleTrack")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetSingleTrack(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetSingleTrackHBin")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetSingleTrackHBin(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetSpool")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s int int char* int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            strcpy(param_char[2],argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            res=SetSpool(param_int[0],param_int[1],param_char[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %s %d ",param_int[0],param_int[1],param_char[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetSpoolThreadCount")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetSpoolThreadCount(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetStorageMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            res=SetStorageMode(param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetTECEvent")==0) {
      } else if (strcmp(argv[2],"SetTemperature")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetTemperature(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetTemperatureEvent")==0) {
      } else if (strcmp(argv[2],"SetTriggerMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetTriggerMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetTriggerInvert")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetTriggerInvert(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"GetTriggerLevelRange")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=GetTriggerLevelRange(&param_float[0],&param_float[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f %f ",param_float[0],param_float[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetTriggerLevel")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            res=SetTriggerLevel(param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetIODirection")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetIODirection(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetIOLevel")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=SetIOLevel(param_int[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d ",param_int[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetUserEvent")==0) {
      } else if (strcmp(argv[2],"SetUSGenomics")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s long long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            param_long[1]=(long)atol(argv[4]);
            res=SetUSGenomics(param_long[0],param_long[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld ",param_long[0],param_long[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetVerticalRowBuffer")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetVerticalRowBuffer(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetVerticalSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetVerticalSpeed(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetVirtualChip")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetVirtualChip(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetVSAmplitude")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetVSAmplitude(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"SetVSSpeed")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=SetVSSpeed(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"ShutDown")==0) {
         ShutDown();
      } else if (strcmp(argv[2],"StartAcquisition")==0) {
         StartAcquisition();
      } else if (strcmp(argv[2],"UnMapPhysicalAddress")==0) {
         UnMapPhysicalAddress();
      } else if (strcmp(argv[2],"WaitForAcquisition")==0) {
         WaitForAcquisition();
      } else if (strcmp(argv[2],"WaitForAcquisitionByHandle")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s long ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            res=WaitForAcquisitionByHandle(param_long[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld ",param_long[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"WaitForAcquisitionByHandleTimeOut")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s long int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_long[0]=(long)atol(argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            res=WaitForAcquisitionByHandleTimeOut(param_long[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %d ",param_long[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"WaitForAcquisitionTimeOut")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=WaitForAcquisitionTimeOut(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"WhiteBalance")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=WhiteBalance(&param_WORD[0],&param_WORD[1],&param_WORD[2],&param_float[3],&param_float[4],&param_wbal[5]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d %f %f %p ",param_WORD[0],param_WORD[1],param_WORD[2],param_float[3],param_float[4],&param_wbal[5]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_Initialize")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0], "pcFilename");
            param_int[1]=(int)atoi(argv[3]);
            res=OA_Initialize(param_char[0],param_int[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ",param_char[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_EnableMode")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0], "pcModeName");
            res=OA_EnableMode(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ", param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetModeAcqParams")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0], "pcModeName");
            strcpy(param_char[1], "pcListOfParams");
            res=OA_GetModeAcqParams(param_char[0],param_char[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %s ", param_char[0], param_char[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetUserModeNames")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=OA_GetUserModeNames(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetPreSetModeNames")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s char* ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            res=OA_GetPreSetModeNames(param_char[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s ",param_char[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetNumberOfUserModes")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=OA_GetNumberOfUserModes(&param_uint[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_uint[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetNumberOfPreSetModes")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=OA_GetNumberOfPreSetModes(&param_uint[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_uint[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetNumberOfAcqParams")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,""); 
            strcpy(param_char[0], "pcModeName");
            param_uint[1] = 0;
            res=OA_GetNumberOfAcqParams(param_char[0], &param_uint[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ", param_char[0], param_uint[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_AddMode")==0) {
         if (argc<7) {
            sprintf(ligne,"Usage: %s %s %s char* unsigned int char* unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0],argv[3]);
            param_int[1]=(int)atoi(argv[4]);
            strcpy(param_char[2],argv[5]);
            param_int[3]=(int)atoi(argv[6]);
            res=OA_AddMode(param_char[0],param_int[1],param_char[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d %s %d ",param_char[0],param_int[1],param_char[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_WriteToFile")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0], "fileName");
            param_uint[1]=(int)atoi(argv[3]);
            res=OA_WriteToFile(param_char[0],param_uint[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ", param_char[0],param_int[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_DeleteMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0], "pcModeName"); 
            param_uint[1]=(int)atoi(argv[3]);
            res=OA_DeleteMode(param_char[0], param_uint[1]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %d ", param_char[0], param_uint[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_SetInt")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s const int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");  
            strcpy(param_char[0], "pcModeName");
            strcpy(param_char[1], "pcModeParam");
            param_int[2]=(int)atoi(argv[3]);
            res=OA_SetInt(param_char[0], param_char[1],param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %s %d ", param_char[0], param_char[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_SetFloat")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s const float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[0], "pcModeName");
            strcpy(param_char[1], "pcModeParam");
            float fvalue=(float)atoi(argv[3]);
            res=OA_SetFloat(param_char[0], param_char[1], fvalue);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%s %s %f ", param_char[0], param_char[1], fvalue);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_SetString")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* const unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");  //OA_SetString(const char * const pcModeName, const char * pcModeParam, char * pcStringValue, const unsigned int uiStringLen);
            strcpy(param_char[2],argv[3]);
            param_int[3]=(int)atoi(argv[4]);
            res=OA_SetString((const char*)&param_int[0], (const char*)&param_int[1],param_char[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %s %d ",param_int[0],param_int[1],param_char[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetInt")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=OA_GetInt((const char*)&param_int[0], (const char*) &param_int[1],&param_int[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %d ",param_int[0],param_int[1],param_int[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetFloat")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=OA_GetFloat((const char*)&param_int[0], (const char*)&param_int[1],&param_float[2]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %f ",param_int[0],param_int[1],param_float[2]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"OA_GetString")==0) {
         if (argc<5) {
            sprintf(ligne,"Usage: %s %s %s char* const unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            strcpy(param_char[2],argv[3]);
            param_int[3]=(int)atoi(argv[4]);
            res=OA_GetString((const char*)&param_int[0], (const char*)&param_int[1],param_char[2],param_int[3]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d %d %s %d ",param_int[0],param_int[1],param_char[2],param_int[3]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_SetMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s unsigned int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=Filter_SetMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_GetMode")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=Filter_GetMode(&param_uint[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_uint[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_SetThreshold")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s float ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_float[0]=(float)atof(argv[3]);
            res=Filter_SetThreshold(param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_GetThreshold")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=Filter_GetThreshold(&param_float[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%f ",param_float[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_SetDataAveragingMode")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=Filter_SetDataAveragingMode(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }
      else if (strcmp(argv[2], "Filter_GetDataAveragingMode") == 0) {
         if (argc < 3) {
            sprintf(ligne, "Usage: %s %s %s ", argv[0], argv[1], argv[2]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
         else {
            strcpy(ligne, "");
            res = Filter_GetDataAveragingMode(&param_int[0]);
            if (res != DRV_SUCCESS) {
               sprintf(ligne, "Error %d. %s", res, get_status(res));
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_ERROR;
            }
            else {
               ;
               sprintf(ligne, "%d ", param_int[0]);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               return TCL_OK;
            };
         }
      }
      
      
      
      if (strcmp(argv[2],"Filter_SetAveragingFrameCount")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=Filter_SetAveragingFrameCount(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_GetAveragingFrameCount")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=Filter_GetAveragingFrameCount(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_SetAveragingFactor")==0) {
         if (argc<4) {
            sprintf(ligne,"Usage: %s %s %s int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[0]=(int)atoi(argv[3]);
            res=Filter_SetAveragingFactor(param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"Filter_GetAveragingFactor")==0) {
         if (argc<3) {
            sprintf(ligne,"Usage: %s %s %s ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            res=Filter_GetAveragingFactor(&param_int[0]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%d ",param_int[0]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"PostProcessNoiseFilter")==0) {
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int int int float int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[2]=(int)atoi(argv[3]);
            param_int[3]=(int)atoi(argv[4]);
            param_int[4]=(int)atoi(argv[5]);
            param_float[5]=(float)atof(argv[6]);
            param_int[6]=(int)atoi(argv[7]);
            param_int[7]=(int)atoi(argv[8]);
            res=PostProcessNoiseFilter(&param_long[0],&param_long[1],param_int[2],param_int[3],param_int[4],param_float[5],param_int[6],param_int[7]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %d %d %d %f %d %d ",param_long[0],param_long[1],param_int[2],param_int[3],param_int[4],param_float[5],param_int[6],param_int[7]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"PostProcessCountConvert")==0) {
         if (argc<12) {
            sprintf(ligne,"Usage: %s %s %s int int int int int float float int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[2]=(int)atoi(argv[3]);
            param_int[3]=(int)atoi(argv[4]);
            param_int[4]=(int)atoi(argv[5]);
            param_int[5]=(int)atoi(argv[6]);
            param_int[6]=(int)atoi(argv[7]);
            param_float[7]=(float)atof(argv[8]);
            param_float[8]=(float)atof(argv[9]);
            param_int[9]=(int)atoi(argv[10]);
            param_int[10]=(int)atoi(argv[11]);
            res=PostProcessCountConvert(&param_long[0],&param_long[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_float[7],param_float[8],param_int[9],param_int[10]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %d %d %d %d %d %f %f %d %d ",param_long[0],param_long[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_float[7],param_float[8],param_int[9],param_int[10]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"PostProcessPhotonCounting")==0) {
         if (argc<9) {
            sprintf(ligne,"Usage: %s %s %s int int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[2]=(int)atoi(argv[3]);
            param_int[3]=(int)atoi(argv[4]);
            param_int[4]=(int)atoi(argv[5]);
            param_int[5]=(int)atoi(argv[6]);
            param_int[7]=(int)atoi(argv[7]);
            param_int[8]=(int)atoi(argv[8]);
            res=PostProcessPhotonCounting(&param_long[0],&param_long[1],param_int[2],param_int[3],param_int[4],param_int[5],&param_float[6],param_int[7],param_int[8]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %d %d %d %d %f %d %d ",param_long[0],param_long[1],param_int[2],param_int[3],param_int[4],param_int[5],param_float[6],param_int[7],param_int[8]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
      } else if (strcmp(argv[2],"PostProcessDataAveraging")==0) {
         if (argc<10) {
            sprintf(ligne,"Usage: %s %s %s int int int int int int int ",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         } else {
            strcpy(ligne,"");
            param_int[2]=(int)atoi(argv[3]);
            param_int[3]=(int)atoi(argv[4]);
            param_int[4]=(int)atoi(argv[5]);
            param_int[5]=(int)atoi(argv[6]);
            param_int[6]=(int)atoi(argv[7]);
            param_int[7]=(int)atoi(argv[8]);
            param_int[8]=(int)atoi(argv[9]);
            res=PostProcessDataAveraging(&param_long[0],&param_long[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_int[7],param_int[8]);
            if (res!=DRV_SUCCESS) {
               sprintf(ligne,"Error %d. %s",res,get_status(res));
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_ERROR;
            } else {;
               sprintf(ligne,"%ld %ld %d %d %d %d %d %d %d ",param_long[0],param_long[1],param_int[2],param_int[3],param_int[4],param_int[5],param_int[6],param_int[7],param_int[8]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               return TCL_OK;
            };
         }
         
      } else {
         found=0;
      }
   } else {
      found=0;
   }
   if (found==0) {
      Tcl_SetResult(interp,"Available functions are: ",TCL_VOLATILE);
      Tcl_AppendResult(interp,"AbortAcquisition ",NULL);
      Tcl_AppendResult(interp,"CancelWait ",NULL);
      Tcl_AppendResult(interp,"CoolerOFF ",NULL);
      Tcl_AppendResult(interp,"CoolerON ",NULL);
      Tcl_AppendResult(interp,"DemosaicImage ",NULL);
      Tcl_AppendResult(interp,"EnableKeepCleans ",NULL);
      Tcl_AppendResult(interp,"FreeInternalMemory ",NULL);
      Tcl_AppendResult(interp,"GetAcquiredData ",NULL);
      Tcl_AppendResult(interp,"GetAcquiredData16 ",NULL);
      Tcl_AppendResult(interp,"GetAcquiredFloatData ",NULL);
      Tcl_AppendResult(interp,"GetAcquisitionProgress ",NULL);
      Tcl_AppendResult(interp,"GetAcquisitionTimings ",NULL);
      Tcl_AppendResult(interp,"GetAdjustedRingExposureTimes ",NULL);
      Tcl_AppendResult(interp,"GetAllDMAData ",NULL);
      Tcl_AppendResult(interp,"GetAmpDesc ",NULL);
      Tcl_AppendResult(interp,"GetAmpMaxSpeed ",NULL);
      Tcl_AppendResult(interp,"GetAvailableCameras ",NULL);
      Tcl_AppendResult(interp,"GetBackground ",NULL);
      Tcl_AppendResult(interp,"GetBaselineClamp ",NULL);
      Tcl_AppendResult(interp,"GetBitDepth ",NULL);
      Tcl_AppendResult(interp,"GetCameraEventStatus ",NULL);
      Tcl_AppendResult(interp,"GetCameraHandle ",NULL);
      Tcl_AppendResult(interp,"GetCameraInformation ",NULL);
      Tcl_AppendResult(interp,"GetCameraSerialNumber ",NULL);
      Tcl_AppendResult(interp,"GetCapabilities ",NULL);
      Tcl_AppendResult(interp,"GetControllerCardModel ",NULL);
      Tcl_AppendResult(interp,"GetCountConvertWavelengthRange ",NULL);
      Tcl_AppendResult(interp,"GetCurrentCamera ",NULL);
      Tcl_AppendResult(interp,"GetCYMGShift ",NULL);
      Tcl_AppendResult(interp,"GetDDGExternalOutputEnabled ",NULL);
      Tcl_AppendResult(interp,"GetDDGExternalOutputPolarity ",NULL);
      Tcl_AppendResult(interp,"GetDDGExternalOutputStepEnabled ",NULL);
      Tcl_AppendResult(interp,"GetDDGExternalOutputTime ",NULL);
      Tcl_AppendResult(interp,"GetDDGTTLGateWidth ",NULL);
      Tcl_AppendResult(interp,"GetDDGGateTime ",NULL);
      Tcl_AppendResult(interp,"GetDDGInsertionDelay ",NULL);
      Tcl_AppendResult(interp,"GetDDGIntelligate ",NULL);
      Tcl_AppendResult(interp,"GetDDGIOC ",NULL);
      Tcl_AppendResult(interp,"GetDDGIOCFrequency ",NULL);
      Tcl_AppendResult(interp,"GetDDGIOCNumber ",NULL);
      Tcl_AppendResult(interp,"GetDDGIOCNumberRequested ",NULL);
      Tcl_AppendResult(interp,"GetDDGIOCPeriod ",NULL);
      Tcl_AppendResult(interp,"GetDDGIOCPulses ",NULL);
      Tcl_AppendResult(interp,"GetDDGIOCTrigger ",NULL);
      Tcl_AppendResult(interp,"GetDDGOpticalWidthEnabled ",NULL);
      Tcl_AppendResult(interp,"GetDDGLiteGlobalControlByte ",NULL);
      Tcl_AppendResult(interp,"GetDDGLiteControlByte ",NULL);
      Tcl_AppendResult(interp,"GetDDGLiteInitialDelay ",NULL);
      Tcl_AppendResult(interp,"GetDDGLitePulseWidth ",NULL);
      Tcl_AppendResult(interp,"GetDDGLiteInterPulseDelay ",NULL);
      Tcl_AppendResult(interp,"GetDDGLitePulsesPerExposure ",NULL);
      Tcl_AppendResult(interp,"GetDDGPulse ",NULL);
      Tcl_AppendResult(interp,"GetDDGStepCoefficients ",NULL);
      Tcl_AppendResult(interp,"GetDDGWidthStepCoefficients ",NULL);
      Tcl_AppendResult(interp,"GetDDGStepMode ",NULL);
      Tcl_AppendResult(interp,"GetDDGWidthStepMode ",NULL);
      Tcl_AppendResult(interp,"GetDetector ",NULL);
      Tcl_AppendResult(interp,"GetEMAdvanced ",NULL);
      Tcl_AppendResult(interp,"GetEMCCDGain ",NULL);
      Tcl_AppendResult(interp,"GetEMGainRange ",NULL);
      Tcl_AppendResult(interp,"GetExternalTriggerTermination ",NULL);
      Tcl_AppendResult(interp,"GetFastestRecommendedVSSpeed ",NULL);
      Tcl_AppendResult(interp,"GetFIFOUsage ",NULL);
      Tcl_AppendResult(interp,"GetFilterMode ",NULL);
      Tcl_AppendResult(interp,"GetFKExposureTime ",NULL);
      Tcl_AppendResult(interp,"GetFKVShiftSpeed ",NULL);
      Tcl_AppendResult(interp,"GetFKVShiftSpeedF ",NULL);
      Tcl_AppendResult(interp,"GetFrontEndStatus ",NULL);
      Tcl_AppendResult(interp,"GetGateMode ",NULL);
      Tcl_AppendResult(interp,"GetHardwareVersion ",NULL);
      Tcl_AppendResult(interp,"GetHeadModel ",NULL);
      Tcl_AppendResult(interp,"GetHorizontalSpeed ",NULL);
      Tcl_AppendResult(interp,"GetHSSpeed ",NULL);
      Tcl_AppendResult(interp,"GetHVflag ",NULL);
      Tcl_AppendResult(interp,"GetID ",NULL);
      Tcl_AppendResult(interp,"GetImageFlip ",NULL);
      Tcl_AppendResult(interp,"GetImageRotate ",NULL);
      Tcl_AppendResult(interp,"GetImages ",NULL);
      Tcl_AppendResult(interp,"GetImages16 ",NULL);
      Tcl_AppendResult(interp,"GetImagesPerDMA ",NULL);
      Tcl_AppendResult(interp,"GetIRQ ",NULL);
      Tcl_AppendResult(interp,"GetKeepCleanTime ",NULL);
      Tcl_AppendResult(interp,"GetMaximumBinning ",NULL);
      Tcl_AppendResult(interp,"GetMaximumExposure ",NULL);
      Tcl_AppendResult(interp,"GetMaximumNumberRingExposureTimes ",NULL);
      Tcl_AppendResult(interp,"GetMCPGain ",NULL);
      Tcl_AppendResult(interp,"GetMCPGainRange ",NULL);
      Tcl_AppendResult(interp,"GetMCPGainTable ",NULL);
      Tcl_AppendResult(interp,"GetMCPVoltage ",NULL);
      Tcl_AppendResult(interp,"GetMinimumImageLength ",NULL);
      Tcl_AppendResult(interp,"GetMinimumNumberInSeries ",NULL);
      Tcl_AppendResult(interp,"GetMostRecentColorImage16 ",NULL);
      Tcl_AppendResult(interp,"GetMostRecentImage ",NULL);
      Tcl_AppendResult(interp,"GetMostRecentImage16 ",NULL);
      Tcl_AppendResult(interp,"GetMSTimingsData ",NULL);
      Tcl_AppendResult(interp,"GetMetaDataInfo ",NULL);
      Tcl_AppendResult(interp,"GetMSTimingsEnabled ",NULL);
      Tcl_AppendResult(interp,"GetRelativeImageTimes ",NULL);
      Tcl_AppendResult(interp,"GetNewData ",NULL);
      Tcl_AppendResult(interp,"GetNewData16 ",NULL);
      Tcl_AppendResult(interp,"GetNewData8 ",NULL);
      Tcl_AppendResult(interp,"GetNewFloatData ",NULL);
      Tcl_AppendResult(interp,"GetNumberADChannels ",NULL);
      Tcl_AppendResult(interp,"GetNumberAmp ",NULL);
      Tcl_AppendResult(interp,"GetNumberAvailableImages ",NULL);
      Tcl_AppendResult(interp,"GetNumberDDGExternalOutputs ",NULL);
      Tcl_AppendResult(interp,"GetNumberDevices ",NULL);
      Tcl_AppendResult(interp,"GetNumberFKVShiftSpeeds ",NULL);
      Tcl_AppendResult(interp,"GetNumberHorizontalSpeeds ",NULL);
      Tcl_AppendResult(interp,"GetNumberHSSpeeds ",NULL);
      Tcl_AppendResult(interp,"GetNumberNewImages ",NULL);
      Tcl_AppendResult(interp,"GetNumberPhotonCountingDivisions ",NULL);
      Tcl_AppendResult(interp,"GetNumberPreAmpGains ",NULL);
      Tcl_AppendResult(interp,"GetNumberRingExposureTimes ",NULL);
      Tcl_AppendResult(interp,"GetNumberIO ",NULL);
      Tcl_AppendResult(interp,"GetNumberVerticalSpeeds ",NULL);
      Tcl_AppendResult(interp,"GetNumberVSAmplitudes ",NULL);
      Tcl_AppendResult(interp,"GetNumberVSSpeeds ",NULL);
      Tcl_AppendResult(interp,"GetOldestImage ",NULL);
      Tcl_AppendResult(interp,"GetOldestImage16 ",NULL);
      Tcl_AppendResult(interp,"GetPhosphorStatus ",NULL);
      Tcl_AppendResult(interp,"GetPhysicalDMAAddress ",NULL);
      Tcl_AppendResult(interp,"GetPixelSize ",NULL);
      Tcl_AppendResult(interp,"GetPreAmpGain ",NULL);
      Tcl_AppendResult(interp,"GetPreAmpGainText ",NULL);
      Tcl_AppendResult(interp,"GetDualExposureTimes ",NULL);
      Tcl_AppendResult(interp,"GetQE ",NULL);
      Tcl_AppendResult(interp,"GetReadOutTime ",NULL);
      Tcl_AppendResult(interp,"GetRegisterDump ",NULL);
      Tcl_AppendResult(interp,"GetRingExposureRange ",NULL);
      Tcl_AppendResult(interp,"GetSDK3Handle ",NULL);
      Tcl_AppendResult(interp,"GetSensitivity ",NULL);
      Tcl_AppendResult(interp,"GetShutterMinTimes ",NULL);
      Tcl_AppendResult(interp,"GetSizeOfCircularBuffer ",NULL);
      Tcl_AppendResult(interp,"GetSlotBusDeviceFunction ",NULL);
      Tcl_AppendResult(interp,"GetSoftwareVersion ",NULL);
      Tcl_AppendResult(interp,"GetSpoolProgress ",NULL);
      Tcl_AppendResult(interp,"GetStartUpTime ",NULL);
      Tcl_AppendResult(interp,"GetStatus ",NULL);
      Tcl_AppendResult(interp,"GetTECStatus ",NULL);
      Tcl_AppendResult(interp,"GetTemperature ",NULL);
      Tcl_AppendResult(interp,"GetTemperatureF ",NULL);
      Tcl_AppendResult(interp,"GetTemperatureRange ",NULL);
      Tcl_AppendResult(interp,"GetTemperatureStatus ",NULL);
      Tcl_AppendResult(interp,"GetTotalNumberImagesAcquired ",NULL);
      Tcl_AppendResult(interp,"GetIODirection ",NULL);
      Tcl_AppendResult(interp,"GetIOLevel ",NULL);
      Tcl_AppendResult(interp,"GetVersionInfo ",NULL);
      Tcl_AppendResult(interp,"GetVerticalSpeed ",NULL);
      Tcl_AppendResult(interp,"GetVSAmplitudeString ",NULL);
      Tcl_AppendResult(interp,"GetVSAmplitudeFromString ",NULL);
      Tcl_AppendResult(interp,"GetVSAmplitudeValue ",NULL);
      Tcl_AppendResult(interp,"GetVSSpeed ",NULL);
      Tcl_AppendResult(interp,"GPIBReceive ",NULL);
      Tcl_AppendResult(interp,"GPIBSend ",NULL);
      Tcl_AppendResult(interp,"I2CBurstRead ",NULL);
      Tcl_AppendResult(interp,"I2CBurstWrite ",NULL);
      Tcl_AppendResult(interp,"I2CRead ",NULL);
      Tcl_AppendResult(interp,"I2CReset ",NULL);
      Tcl_AppendResult(interp,"I2CWrite ",NULL);
      Tcl_AppendResult(interp,"IdAndorDll ",NULL);
      Tcl_AppendResult(interp,"InAuxPort ",NULL);
      Tcl_AppendResult(interp,"Initialize ",NULL);
      Tcl_AppendResult(interp,"InitializeDevice ",NULL);
      Tcl_AppendResult(interp,"IsAmplifierAvailable ",NULL);
      Tcl_AppendResult(interp,"IsCoolerOn ",NULL);
      Tcl_AppendResult(interp,"IsCountConvertModeAvailable ",NULL);
      Tcl_AppendResult(interp,"IsInternalMechanicalShutter ",NULL);
      Tcl_AppendResult(interp,"IsPreAmpGainAvailable ",NULL);
      Tcl_AppendResult(interp,"IsTriggerModeAvailable ",NULL);
      Tcl_AppendResult(interp,"Merge ",NULL);
      Tcl_AppendResult(interp,"OutAuxPort ",NULL);
      Tcl_AppendResult(interp,"PrepareAcquisition ",NULL);
      Tcl_AppendResult(interp,"SaveAsBmp ",NULL);
      Tcl_AppendResult(interp,"SaveAsCommentedSif ",NULL);
      Tcl_AppendResult(interp,"SaveAsEDF ",NULL);
      Tcl_AppendResult(interp,"SaveAsFITS ",NULL);
      Tcl_AppendResult(interp,"SaveAsRaw ",NULL);
      Tcl_AppendResult(interp,"SaveAsSif ",NULL);
      Tcl_AppendResult(interp,"SaveAsSPC ",NULL);
      Tcl_AppendResult(interp,"SaveAsTiff ",NULL);
      Tcl_AppendResult(interp,"SaveAsTiffEx ",NULL);
      Tcl_AppendResult(interp,"SaveEEPROMToFile ",NULL);
      Tcl_AppendResult(interp,"SaveToClipBoard ",NULL);
      Tcl_AppendResult(interp,"SelectDevice ",NULL);
      Tcl_AppendResult(interp,"SendSoftwareTrigger ",NULL);
      Tcl_AppendResult(interp,"SetAccumulationCycleTime ",NULL);
      Tcl_AppendResult(interp,"SetAcquisitionMode ",NULL);
      Tcl_AppendResult(interp,"SetAcquisitionType ",NULL);
      Tcl_AppendResult(interp,"SetADChannel ",NULL);
      Tcl_AppendResult(interp,"SetAdvancedTriggerModeState ",NULL);
      Tcl_AppendResult(interp,"SetBackground ",NULL);
      Tcl_AppendResult(interp,"SetBaselineClamp ",NULL);
      Tcl_AppendResult(interp,"SetBaselineOffset ",NULL);
      Tcl_AppendResult(interp,"SetCameraLinkMode ",NULL);
      Tcl_AppendResult(interp,"SetCameraStatusEnable ",NULL);
      Tcl_AppendResult(interp,"SetChargeShifting ",NULL);
      Tcl_AppendResult(interp,"SetComplexImage ",NULL);
      Tcl_AppendResult(interp,"SetCoolerMode ",NULL);
      Tcl_AppendResult(interp,"SetCountConvertMode ",NULL);
      Tcl_AppendResult(interp,"SetCountConvertWavelength ",NULL);
      Tcl_AppendResult(interp,"SetCropMode ",NULL);
      Tcl_AppendResult(interp,"SetCurrentCamera ",NULL);
      Tcl_AppendResult(interp,"SetCustomTrackHBin ",NULL);
      Tcl_AppendResult(interp,"SetDataType ",NULL);
      Tcl_AppendResult(interp,"SetDACOutput ",NULL);
      Tcl_AppendResult(interp,"SetDACOutputScale ",NULL);
      Tcl_AppendResult(interp,"SetDDGAddress ",NULL);
      Tcl_AppendResult(interp,"SetDDGExternalOutputEnabled ",NULL);
      Tcl_AppendResult(interp,"SetDDGExternalOutputPolarity ",NULL);
      Tcl_AppendResult(interp,"SetDDGExternalOutputStepEnabled ",NULL);
      Tcl_AppendResult(interp,"SetDDGExternalOutputTime ",NULL);
      Tcl_AppendResult(interp,"SetDDGGain ",NULL);
      Tcl_AppendResult(interp,"SetDDGGateStep ",NULL);
      Tcl_AppendResult(interp,"SetDDGGateTime ",NULL);
      Tcl_AppendResult(interp,"SetDDGInsertionDelay ",NULL);
      Tcl_AppendResult(interp,"SetDDGIntelligate ",NULL);
      Tcl_AppendResult(interp,"SetDDGIOC ",NULL);
      Tcl_AppendResult(interp,"SetDDGIOCFrequency ",NULL);
      Tcl_AppendResult(interp,"SetDDGIOCNumber ",NULL);
      Tcl_AppendResult(interp,"SetDDGIOCPeriod ",NULL);
      Tcl_AppendResult(interp,"SetDDGIOCTrigger ",NULL);
      Tcl_AppendResult(interp,"SetDDGOpticalWidthEnabled ",NULL);
      Tcl_AppendResult(interp,"SetDDGLiteGlobalControlByte ",NULL);
      Tcl_AppendResult(interp,"SetDDGLiteControlByte ",NULL);
      Tcl_AppendResult(interp,"SetDDGLiteInitialDelay ",NULL);
      Tcl_AppendResult(interp,"SetDDGLitePulseWidth ",NULL);
      Tcl_AppendResult(interp,"SetDDGLiteInterPulseDelay ",NULL);
      Tcl_AppendResult(interp,"SetDDGLitePulsesPerExposure ",NULL);
      Tcl_AppendResult(interp,"SetDDGStepCoefficients ",NULL);
      Tcl_AppendResult(interp,"SetDDGWidthStepCoefficients ",NULL);
      Tcl_AppendResult(interp,"SetDDGStepMode ",NULL);
      Tcl_AppendResult(interp,"SetDDGWidthStepMode ",NULL);
      Tcl_AppendResult(interp,"SetDDGTimes ",NULL);
      Tcl_AppendResult(interp,"SetDDGTriggerMode ",NULL);
      Tcl_AppendResult(interp,"SetDDGVariableGateStep ",NULL);
      Tcl_AppendResult(interp,"SetDelayGenerator ",NULL);
      Tcl_AppendResult(interp,"SetDMAParameters ",NULL);
      Tcl_AppendResult(interp,"SetEMAdvanced ",NULL);
      Tcl_AppendResult(interp,"SetEMCCDGain ",NULL);
      Tcl_AppendResult(interp,"SetEMClockCompensation ",NULL);
      Tcl_AppendResult(interp,"SetEMGainMode ",NULL);
      Tcl_AppendResult(interp,"SetExposureTime ",NULL);
      Tcl_AppendResult(interp,"SetExternalTriggerTermination ",NULL);
      Tcl_AppendResult(interp,"SetFanMode ",NULL);
      Tcl_AppendResult(interp,"SetFastExtTrigger ",NULL);
      Tcl_AppendResult(interp,"SetFastKinetics ",NULL);
      Tcl_AppendResult(interp,"SetFastKineticsEx ",NULL);
      Tcl_AppendResult(interp,"SetFilterMode ",NULL);
      Tcl_AppendResult(interp,"SetFilterParameters ",NULL);
      Tcl_AppendResult(interp,"SetFKVShiftSpeed ",NULL);
      Tcl_AppendResult(interp,"SetFPDP ",NULL);
      Tcl_AppendResult(interp,"SetFrameTransferMode ",NULL);
      Tcl_AppendResult(interp,"SetFullImage ",NULL);
      Tcl_AppendResult(interp,"SetFVBHBin ",NULL);
      Tcl_AppendResult(interp,"SetGain ",NULL);
      Tcl_AppendResult(interp,"SetGate ",NULL);
      Tcl_AppendResult(interp,"SetGateMode ",NULL);
      Tcl_AppendResult(interp,"SetHighCapacity ",NULL);
      Tcl_AppendResult(interp,"SetHorizontalSpeed ",NULL);
      Tcl_AppendResult(interp,"SetHSSpeed ",NULL);
      Tcl_AppendResult(interp,"SetImage ",NULL);
      Tcl_AppendResult(interp,"SetImageFlip ",NULL);
      Tcl_AppendResult(interp,"SetImageRotate ",NULL);
      Tcl_AppendResult(interp,"SetIsolatedCropMode ",NULL);
      Tcl_AppendResult(interp,"SetKineticCycleTime ",NULL);
      Tcl_AppendResult(interp,"SetMCPGain ",NULL);
      Tcl_AppendResult(interp,"SetMCPGating ",NULL);
      Tcl_AppendResult(interp,"SetMetaData ",NULL);
      Tcl_AppendResult(interp,"SetMultiTrack ",NULL);
      Tcl_AppendResult(interp,"SetMultiTrackHBin ",NULL);
      Tcl_AppendResult(interp,"SetMultiTrackHRange ",NULL);
      Tcl_AppendResult(interp,"SetMultiTrackScan ",NULL);
      Tcl_AppendResult(interp,"SetNextAddress ",NULL);
      Tcl_AppendResult(interp,"SetNextAddress16 ",NULL);
      Tcl_AppendResult(interp,"SetNumberAccumulations ",NULL);
      Tcl_AppendResult(interp,"SetNumberKinetics ",NULL);
      Tcl_AppendResult(interp,"SetNumberPrescans ",NULL);
      Tcl_AppendResult(interp,"SetOutputAmplifier ",NULL);
      Tcl_AppendResult(interp,"SetOverlapMode ",NULL);
      Tcl_AppendResult(interp,"SetPCIMode ",NULL);
      Tcl_AppendResult(interp,"SetPhotonCounting ",NULL);
      Tcl_AppendResult(interp,"SetPhotonCountingThreshold ",NULL);
      Tcl_AppendResult(interp,"SetPhotonCountingDivisions ",NULL);
      Tcl_AppendResult(interp,"SetPixelMode ",NULL);
      Tcl_AppendResult(interp,"SetPreAmpGain ",NULL);
      Tcl_AppendResult(interp,"SetDualExposureTimes ",NULL);
      Tcl_AppendResult(interp,"SetDualExposureMode ",NULL);
      Tcl_AppendResult(interp,"SetRandomTracks ",NULL);
      Tcl_AppendResult(interp,"SetReadMode ",NULL);
      Tcl_AppendResult(interp,"SetReadoutRegisterPacking ",NULL);
      Tcl_AppendResult(interp,"SetRegisterDump ",NULL);
      Tcl_AppendResult(interp,"SetRingExposureTimes ",NULL);
      Tcl_AppendResult(interp,"SetShutter ",NULL);
      Tcl_AppendResult(interp,"SetShutterEx ",NULL);
      Tcl_AppendResult(interp,"SetShutters ",NULL);
      Tcl_AppendResult(interp,"SetSifComment ",NULL);
      Tcl_AppendResult(interp,"SetSingleTrack ",NULL);
      Tcl_AppendResult(interp,"SetSingleTrackHBin ",NULL);
      Tcl_AppendResult(interp,"SetSpool ",NULL);
      Tcl_AppendResult(interp,"SetSpoolThreadCount ",NULL);
      Tcl_AppendResult(interp,"SetStorageMode ",NULL);
      Tcl_AppendResult(interp,"SetTemperature ",NULL);
      Tcl_AppendResult(interp,"SetTriggerMode ",NULL);
      Tcl_AppendResult(interp,"SetTriggerInvert ",NULL);
      Tcl_AppendResult(interp,"GetTriggerLevelRange ",NULL);
      Tcl_AppendResult(interp,"SetTriggerLevel ",NULL);
      Tcl_AppendResult(interp,"SetIODirection ",NULL);
      Tcl_AppendResult(interp,"SetIOLevel ",NULL);
      Tcl_AppendResult(interp,"SetUSGenomics ",NULL);
      Tcl_AppendResult(interp,"SetVerticalRowBuffer ",NULL);
      Tcl_AppendResult(interp,"SetVerticalSpeed ",NULL);
      Tcl_AppendResult(interp,"SetVirtualChip ",NULL);
      Tcl_AppendResult(interp,"SetVSAmplitude ",NULL);
      Tcl_AppendResult(interp,"SetVSSpeed ",NULL);
      Tcl_AppendResult(interp,"ShutDown ",NULL);
      Tcl_AppendResult(interp,"StartAcquisition ",NULL);
      Tcl_AppendResult(interp,"UnMapPhysicalAddress ",NULL);
      Tcl_AppendResult(interp,"WaitForAcquisition ",NULL);
      Tcl_AppendResult(interp,"WaitForAcquisitionByHandle ",NULL);
      Tcl_AppendResult(interp,"WaitForAcquisitionByHandleTimeOut ",NULL);
      Tcl_AppendResult(interp,"WaitForAcquisitionTimeOut ",NULL);
      Tcl_AppendResult(interp,"WhiteBalance ",NULL);
      Tcl_AppendResult(interp,"OA_Initialize ",NULL);
      Tcl_AppendResult(interp,"OA_EnableMode ",NULL);
      Tcl_AppendResult(interp,"OA_GetModeAcqParams ",NULL);
      Tcl_AppendResult(interp,"OA_GetUserModeNames ",NULL);
      Tcl_AppendResult(interp,"OA_GetPreSetModeNames ",NULL);
      Tcl_AppendResult(interp,"OA_GetNumberOfUserModes ",NULL);
      Tcl_AppendResult(interp,"OA_GetNumberOfPreSetModes ",NULL);
      Tcl_AppendResult(interp,"OA_GetNumberOfAcqParams ",NULL);
      Tcl_AppendResult(interp,"OA_AddMode ",NULL);
      Tcl_AppendResult(interp,"OA_WriteToFile ",NULL);
      Tcl_AppendResult(interp,"OA_DeleteMode ",NULL);
      Tcl_AppendResult(interp,"OA_SetInt ",NULL);
      Tcl_AppendResult(interp,"OA_SetFloat ",NULL);
      Tcl_AppendResult(interp,"OA_SetString ",NULL);
      Tcl_AppendResult(interp,"OA_GetInt ",NULL);
      Tcl_AppendResult(interp,"OA_GetFloat ",NULL);
      Tcl_AppendResult(interp,"OA_GetString ",NULL);
      Tcl_AppendResult(interp,"Filter_SetMode ",NULL);
      Tcl_AppendResult(interp,"Filter_GetMode ",NULL);
      Tcl_AppendResult(interp,"Filter_SetThreshold ",NULL);
      Tcl_AppendResult(interp,"Filter_GetThreshold ",NULL);
      Tcl_AppendResult(interp,"Filter_SetDataAveragingMode ",NULL);
      Tcl_AppendResult(interp,"Filter_GetDataAveragingMode ",NULL);
      Tcl_AppendResult(interp,"Filter_SetAveragingFrameCount ",NULL);
      Tcl_AppendResult(interp,"Filter_GetAveragingFrameCount ",NULL);
      Tcl_AppendResult(interp,"Filter_SetAveragingFactor ",NULL);
      Tcl_AppendResult(interp,"Filter_GetAveragingFactor ",NULL);
      Tcl_AppendResult(interp,"PostProcessNoiseFilter ",NULL);
      Tcl_AppendResult(interp,"PostProcessCountConvert ",NULL);
      Tcl_AppendResult(interp,"PostProcessPhotonCounting ",NULL);
      Tcl_AppendResult(interp,"PostProcessDataAveraging ",NULL);
      return TCL_ERROR;
   }

   return result;
}

int cmdAndorAcqmode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Choix du mode d'acquisition: series|accumulate */
	/* on n'active pas le mode accumulated Kinetic series */
/***************************************************************************************/
   char ligne[256],s[256];
   int result = TCL_OK,nbimages;
   struct camprop *cam;
	float cycletime;
	char ss[]="Usage: %s %s series|accumulate nbimages cycletime ?spoolfilename?";
   float exptime,accumtime,kinetictime;
   cam = (struct camprop *)clientData;

   if (argc>4) {
		if (strcmp(argv[2],"accumulate")==0) {
			cam->acqmode=2;
		} else if (strcmp(argv[2],"series")==0) {
			cam->acqmode=1;
		} else {
	      sprintf(ligne,ss,argv[0],argv[1]);
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			return TCL_ERROR;
		}
		strcpy(s,argv[2]);
		nbimages=(int)atoi(argv[3]);
		if (nbimages<1) {
			nbimages=1;
		} else if (nbimages>30000) {
			nbimages=30000;
		}
		if ((cam->acqmode==1)&&(nbimages>1)) {
			cam->acqmode=3;
		}
		cam->nbimages=nbimages;
		cycletime=(float)atof(argv[4]);
		if (cycletime<(float)(0)) {
			cycletime=(float)0;
		}
		cam->cycletime=cycletime;
		strcpy(cam->spoolname,"andor");
		if (argc>5) {
			strcpy(cam->spoolname,argv[5]);
		}
	} else if (argc>2) {
      sprintf(ligne,ss,argv[0],argv[1]);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (cam->acqmode==2) {
		strcpy(s,"accumulate");
	} else if ((cam->acqmode==1)||(cam->acqmode==3)) {
		strcpy(s,"series");
	} else {
		strcpy(s,"unknown");
	}
   /* --- setup electronic parameters --- */
	cam_setup_electronic(cam);
   /* --- setup exposure parameters --- */
	cam_setup_exposure(cam,&exptime,&accumtime,&kinetictime);
	if ((cam->acqmode==1)||(cam->acqmode==3)) {
		cam->cycletime=kinetictime;
	} else {
		cam->cycletime=accumtime;
	}
   sprintf(ligne,"%s %d %f \"%s\"",s,cam->nbimages,cam->cycletime,cam->spoolname);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdAndorElectronic(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Get|Set SSpeed of the Andor camera                                                  */
/* Returned parameters are :                                                           */
/*  {index_VSSpeed mus_VSSpeed indexmax_VSSpeed} {index_HSSpeed mus_HSSpeed indexmax_HSSpeed} */
/***************************************************************************************/
   char ligne[256];
   int result = TCL_OK,pb=0;
   int hi,vi,nhi,nvi,k,nadc,nag,namp,nvsa,n;
   float v;
	int ampligain,emccdgain=0,adchannel,vsamplitude;
	int index;
	int low,high;
   struct camprop *cam;
   cam = (struct camprop *)clientData;
	if (argc==2) {
		pb=0;
	} else if (argc<8) {
		pb=1;
	} else {
		/* ============= */
      adchannel=(int)fabs(atof(argv[2]));
      ampligain=(int)fabs(atof(argv[3]));
      vi=(int)fabs(atof(argv[4]));
      hi=(int)fabs(atof(argv[5]));
      vsamplitude=(int)fabs(atof(argv[6]));
      emccdgain=(int)fabs(atof(argv[7]));
		/* ============= */
      GetNumberADChannels(&nadc);
		if (adchannel<0) { adchannel=0; }
		if (adchannel>nadc-1) { adchannel=nadc-1; }
		/* */
		GetNumberPreAmpGains(&nag);
      if (ampligain<0) {ampligain=0;}
      if (ampligain>=nag) {ampligain=nag-1;}
		index=ampligain;
		/* */
      GetNumberVSSpeeds(&nvi);
      if (vi<0) {vi=0;}
      if (vi>=nvi) {vi=nvi-1;}
		/* */
		GetNumberVSAmplitudes(&nvsa);
		if (vsamplitude<0) { vsamplitude=0; }
		if (vsamplitude>=nvsa) { vsamplitude=nvsa-1; }
		/* */
		GetNumberAmp(&namp);
		if ((namp>1)&&(emccdgain>1)) {
			cam->HSEMult=1;
			GetEMGainRange(&low,&high);
	      if (emccdgain<low) {emccdgain=low;}
			if (emccdgain>=high) {emccdgain=high;}
		} else {
			emccdgain=1;
			cam->HSEMult=0;
		}
		/* */
      GetNumberHSSpeeds(adchannel,cam->HSEMult,&nhi);
      if (hi<0) {hi=0;}
      if (hi>=nhi) {hi=nhi-1;}
		/* ============= */
      cam->ADChannel=adchannel;
      cam->PreAmpGain=ampligain;
      cam->VSSpeed=vi;
      cam->HSSpeed=hi;
      cam->VSAmplitude=vsamplitude;
      cam->EMCCDGain=emccdgain;
		/* ============= */
		cam_setup_electronic(cam);
		/* */
      pb=0;
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?Index_ADChannel Index_AmpliGain Index_VSSpeed Index_HSSpeed Index_VSAmplitude EMCCDGain?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		/* ============= */
      strcpy(ligne,"");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		/* ============= */
      GetNumberADChannels(&n);
      sprintf(ligne,"{Index_ADChannel %d {0 to %d}} ",cam->ADChannel,n-1);
		Tcl_AppendResult(interp,ligne,NULL);
		/* */
		GetNumberPreAmpGains(&n);
      sprintf(ligne,"{Index_AmpliGain %d {",cam->PreAmpGain);
		Tcl_AppendResult(interp,ligne,NULL);
		for (k=0;k<n;k++) {
			GetPreAmpGain(k,&v);
	      sprintf(ligne,"%f ",v);
			Tcl_AppendResult(interp,ligne,NULL);
		}
		Tcl_AppendResult(interp,"} } ",NULL);
		/* */
      GetNumberVSSpeeds(&n);
      sprintf(ligne,"{Index_VSSpeed %d {",cam->VSSpeed);
		Tcl_AppendResult(interp,ligne,NULL);
		for (k=0;k<n;k++) {
			GetVSSpeed(k,&v);
	      sprintf(ligne,"%f ",v);
			Tcl_AppendResult(interp,ligne,NULL);
		}
		Tcl_AppendResult(interp,"} } ",NULL);
		/* */
      GetNumberHSSpeeds(cam->ADChannel,cam->HSEMult,&n);
      sprintf(ligne,"{Index_HSSpeed %d {",cam->HSSpeed);
		Tcl_AppendResult(interp,ligne,NULL);
		for (k=0;k<n;k++) {
			GetHSSpeed(cam->ADChannel,cam->HSEMult,k,&v);
	      sprintf(ligne,"%f ",v);
			Tcl_AppendResult(interp,ligne,NULL);
		}
		Tcl_AppendResult(interp,"} } ",NULL);
		/* */
      GetNumberVSAmplitudes(&n);
      sprintf(ligne,"{Index_VSAmplitude %d {0 to %d}} ",cam->VSAmplitude,n-1);
		Tcl_AppendResult(interp,ligne,NULL);
		/* */
		emccdgain=1;
		low=1;
		high=1;
		if (namp>1) {
			if (cam->HSEMult==1) {
				GetEMCCDGain(&emccdgain);
			}
			GetEMGainRange(&low,&high);
		}
      sprintf(ligne,"{EMCCDGain %d {1 or %d to %d}} ",emccdgain,low,high);
		Tcl_AppendResult(interp,ligne,NULL);
		/* */
   }
   return result;
}

