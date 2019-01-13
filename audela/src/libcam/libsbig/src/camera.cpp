/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <math.h>

#include "camera.h"
#include <libcam/util.h>

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"ST7",			/* camera name */
     "sbig",		/* camera product */
     "kaf400",		/* ccd name */
     768, 512,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"ST8",			/* camera name */
     "sbig",		/* camera product */
     "kaf1600",			/* ccd name */
     1536, 1024,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"OTHER",	   /* camera name */
     "sbig",		/* camera product */
     "",			   /* ccd name */
     1536, 1024,		/* maxx maxy */
     14, 14,			/* overscans x */
     4, 4,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/*illing factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -20.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     }
};

static char *cam_extports[] = {
#if defined(OS_LIN)
    "/dev/parport0",
    "/dev/parport1",
    "/dev/parport2",
#else
    "LPT1:",
    "LPT2:",
    "LPT3:",
#endif
    "USB",
    "Ethernet",
    NULL
};

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop *cam);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_ampli_on(struct camprop *cam);
static void cam_ampli_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
    cam_init,
    cam_close,
    cam_set_binning,
    cam_update_window,
    cam_start_exp,
    cam_stop_exp,
    cam_read_ccd,
    cam_shutter_on,
    cam_shutter_off,
    cam_ampli_on,
    cam_ampli_off,
    cam_measure_temperature,
    cam_cooler_on,
    cam_cooler_off,
    cam_cooler_check
};

static float setpoint2ambienttemp(int setpoint);
static float setpoint2ccdtemp(int setpoint);
static int temp2setpoint(float temp);
static int gettemp(struct camprop *cam, float *setpoint, float *ccd,
		   float *ambient, int *reg, int *power);
static int settemp(struct camprop *cam, float temp);
static int regulation_off(struct camprop *cam);
static int regulation_freeze(struct camprop *cam);
static int regulation_unfreeze(struct camprop *cam);
double bcdTodouble(unsigned long bcd);

PARDRVCOMMAND *pardrvcommand;

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init(struct camprop *cam, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
{
   double temp_setpoint, temp_ccd, temp_ambient;
   int temp_reg, temp_power;
   OpenDeviceParams odp;
   short h1 = (short) INVALID_HANDLE_VALUE;
   //EstablishLinkParams elp;
   EstablishLinkResults elr;
   GetDriverInfoParams gdip;
   GetDriverInfoResults0 gdir;
   EndExposureParams eep;
   //EndReadoutParams erp;
   StartExposureParams2 params;
   GetCCDInfoParams gcip;
   GetCCDInfoResults0 gcir0;
   int k, kk, kip, len;
   char text[256], car;
   unsigned long ipAddress, ip[50];
   QueryCommandStatusParams qcsp;
   QueryCommandStatusResults qcsr;
   ReadoutLineParams rlp;
   ipAddress = 0;
	QueryEthernetResults qer;

   /* --- init variables --- */
   cam->drv_status = CE_NO_ERROR;
   cam->opendevice = 0;
   cam->shutterindex = 1;
   cam->drv_init = 0;
   /* --- Decode the link type with argv[2] --- */
   cam->deviceType = (unsigned short) 0;
   cam->port = (unsigned short) 0;
   if (argc >= 2) {
      if (strcmp(argv[2], cam_extports[0]) == 0) {
         cam->deviceType = (unsigned short) DEV_LPT1;
         cam->port = (unsigned short) 0x378;
      }
      if (strcmp(argv[2], cam_extports[1]) == 0) {
         cam->deviceType = (unsigned short) DEV_LPT2;
         cam->port = (unsigned short) 0x278;
      }
      if (strcmp(argv[2], cam_extports[2]) == 0) {
         cam->deviceType = (unsigned short) DEV_LPT3;
         cam->port = (unsigned short) 0x178;
      }
      if (strcmp(argv[2], cam_extports[3]) == 0) {
         cam->deviceType = (unsigned short) DEV_USB;
      }
      if (strcmp(argv[2], cam_extports[4]) == 0) {
         cam->deviceType = (unsigned short) DEV_ETH;
         // set default address
         strcpy(cam->ip, "192.168.0.2");
      }
   }

   if ( cam->deviceType == 0 ) {
      sprintf(cam->msg, "Error incorrect port name %s. Must be %s or %s or %s or %s or %s",
         cam->portname, cam_extports[0], cam_extports[1], cam_extports[2], cam_extports[3], cam_extports[4] );
       return 1;
   }

   /* --- Decode options of cam::create in argv[>=3] --- */
   if (argc >= 2) {
      for (kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-ip") == 0) {
            if (kk + 1 < argc) {
               // je copie l'adresse (en controlant de ne pas depasser la taille de cam->ip)
               strncpy(cam->ip, argv[kk + 1],sizeof(cam->ip)-1);
            }
         }
         if (strcmp(argv[kk], "-lptaddress") == 0) {
            if (kk + 1 < argc) {
               if ( strcmp(argv[kk + 1],"") != 0 && cam->deviceType <= DEV_LPT3 ) {
                  sscanf(argv[kk + 1],"%hx", &cam->port);
               }
            }
         }
      }
   }

   if ( cam->deviceType == DEV_ETH) {
      //* --- transcode the ip number in an integer
      for (k = 0; k < 5; k++) {
         ip[k] = (unsigned long) 0;
      }
      len = (int) strlen(cam->ip);
      strcpy(text, "");
      for (kip = 0, kk = 0, k = 0; k < len; k++) {
         car = cam->ip[k];
         if (car == '.') {
            ip[kip++] = (unsigned long) atoi(text);
            text[0] = '\0';
            kk = 0;
         } else {
            text[kk] = car;
            text[kk + 1] = '\0';
            kk++;
         }
      }
      // je copie le dernier digit
      ip[kip] = (unsigned long) atoi(text);

      
      ipAddress = (unsigned long) ip[3];
      ipAddress += (unsigned long) (ip[2] * 256);
      ipAddress += (unsigned long) (ip[1] * 256 * 256);
      ipAddress += (unsigned long) (ip[0] * 256 * 256 * 256);
   }

   /* --- import the Entry point of the Sbig library Udrv4.0.a --- */
   pardrvcommand = SBIGUnivDrvCommand;

   /* --- Open Driver --- */
   cam->drv_status = pardrvcommand(CC_OPEN_DRIVER, NULL, NULL);
   if (cam->drv_status) {
      sprintf(cam->msg, "Error %d at line %d. sbig_status=%s",cam->drv_status, __LINE__,
         sbig_get_status(cam->drv_status));
      return 3;
   }

   /* --- Open Device (= open the communication port) --- */
   switch ( cam->deviceType ) {
      case DEV_LPT1:
         odp.deviceType = cam->deviceType;
   	   odp.lptBaseAddress = cam->port;
         break;
      case DEV_LPT2:
         odp.deviceType = cam->deviceType;
   	   odp.lptBaseAddress = cam->port;
         break;
      case DEV_LPT3:
         odp.deviceType = cam->deviceType;
   	   odp.lptBaseAddress = cam->port;
         break;
      case DEV_USB:
         odp.deviceType = cam->deviceType;
         break;
      case DEV_ETH:
         odp.deviceType = cam->deviceType;
			if (ipAddress==0) {
				cam->drv_status = pardrvcommand(CC_QUERY_ETHERNET, NULL, &qer);
				if (qer.camerasFound>0) {
					ipAddress = qer.ethernetInfo[0].ipAddress;
				}
			}
         odp.ipAddress = ipAddress;
         break;
      default:
         sprintf(cam->msg, "Error incorrect port name %s. Must be %s or %s or %s or %s or %s",
         cam->portname, cam_extports[0], cam_extports[1], cam_extports[2], cam_extports[3], cam_extports[4] );
         return 4;
   }

   cam->drv_status = pardrvcommand(CC_OPEN_DEVICE, &odp, NULL);
   if (cam->drv_status) {
      sprintf(cam->msg, "Error status=%d at line %d. sbig_status=%s deviceType=%d",
         cam->drv_status, __LINE__, sbig_get_status(cam->drv_status), odp.deviceType);
      cam_close(cam);
      return 5;
   } else {
       cam->opendevice = 1;
   }

   /* --- Get Driver Info --- */
   gdip.request = DRIVER_STD;
   cam->drv_status = pardrvcommand(CC_GET_DRIVER_INFO, &gdip, &gdir);
   if (cam->drv_status) {
      sprintf(cam->msg, "Error CC_GET_DRIVER_INFO sbig_status=%s", sbig_get_status(cam->drv_status));
      cam_close(cam);
      return 6;
   }


   /* --- Establish Link (= The communication is done with the camera) --- */
   //elp.sbigUseOnly = (unsigned short) 0;
   cam->drv_status = pardrvcommand(CC_ESTABLISH_LINK, NULL, &elr);
   if (cam->drv_status) {
      switch ( odp.deviceType) {
         case DEV_LPT1:
         case DEV_LPT2:
         case DEV_LPT3:
            sprintf(cam->msg, "Error %d at line %d CC_ESTABLISH_LINK sbig_status=%s LPT address=%X",
               cam->drv_status,  __LINE__, sbig_get_status(cam->drv_status),odp.lptBaseAddress);
            break;
         case DEV_USB:
            sprintf(cam->msg, "Error %d at line %d CC_ESTABLISH_LINK sbig_status=%s",
               cam->drv_status,  __LINE__, sbig_get_status(cam->drv_status));
            break;
         case DEV_ETH:
            sprintf(cam->msg, "Error %d at line %d CC_ESTABLISH_LINK sbig_status=%s IP address=%s",
               cam->drv_status,  __LINE__, sbig_get_status(cam->drv_status),cam->ip);
            break;

      }
      cam_close(cam);
      return 6;
   }

   /* --- Get Driver Handle (use in case of multi links. Not our case) --- */
   cam->drv_status = pardrvcommand(CC_GET_DRIVER_HANDLE, NULL, &h1);
   if (cam->drv_status) {
      sprintf(cam->msg, "Error %d at line %d. sbig_status=%s", cam->drv_status, __LINE__,
         sbig_get_status(cam->drv_status));
      cam_close(cam);
      return 7;
   }


   /* --- Get CCD Infos (to update the CAM_INI struct with the linked camera) --- */
   gcip.request = CCD_INFO_IMAGING;
   cam->drv_status = pardrvcommand(CC_GET_CCD_INFO, &gcip, &gcir0);
   if (cam->drv_status) {
      sprintf(cam->msg, "Error %d at line %d. sbig_status=%s", cam->drv_status,__LINE__,
         sbig_get_status(cam->drv_status));
      cam_close(cam);
      return 8;
   }


   /* --- Conversion of Sbig parameters to AudeLA CAM_INI structure --- */
   cam->index_cam = 0;
   strcpy(CAM_INI[cam->index_cam].name, gcir0.name);
   cam->cameraType = gcir0.cameraType;
   if (gcir0.cameraType == ST7_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kaf400");
   } else if (gcir0.cameraType == ST8_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kaf1600");
   } else if (gcir0.cameraType == ST5C_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "ST5C_CAMERA");
   } else if (gcir0.cameraType == TCE_CONTROLLER) {
      // Systeme de controle video pour les montures //
      strcpy(CAM_INI[cam->index_cam].ccd, "TCE_CONTROLLER");
   } else if (gcir0.cameraType == ST237_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "TC237");
   } else if (gcir0.cameraType == STK_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "STK_CAMERA");
   } else if (gcir0.cameraType == ST9_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kaf0261");
   } else if (gcir0.cameraType == STV_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "TC237");
   } else if (gcir0.cameraType == ST10_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kaf3200");
   } else if (gcir0.cameraType == ST1K_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kaf1001");
   } else if (gcir0.cameraType == ST2K_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kai4021");
   } else if (gcir0.cameraType == STL_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kai11000");
   } else if (gcir0.cameraType == ST402_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "Kaf402");
   } else if (gcir0.cameraType == STX_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "KAF-16803");
   } else if (gcir0.cameraType == ST4K_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "KAI-4022CM");
   } else if (gcir0.cameraType == STT_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "KAF-8300M");
   } else if (gcir0.cameraType == STI_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "KAI-0340");
   } else if (gcir0.cameraType == STF_CAMERA) {
      strcpy(CAM_INI[cam->index_cam].ccd, "KAF-8300M");
   } else if (gcir0.cameraType == NEXT_CAMERA) {
      // Unknown device, is it rally a camera? //
      strcpy(CAM_INI[cam->index_cam].ccd, "NEXT_CAMERA");
   } else {
      strcpy(CAM_INI[cam->index_cam].ccd, "unknown");
   }

   CAM_INI[cam->index_cam].maxx = gcir0.readoutInfo[0].width;
   CAM_INI[cam->index_cam].maxy = gcir0.readoutInfo[0].height;
   CAM_INI[cam->index_cam].overscanxbeg = 0;
   CAM_INI[cam->index_cam].overscanxend = 0;
   CAM_INI[cam->index_cam].overscanybeg = 0;
   CAM_INI[cam->index_cam].overscanyend = 0;
   CAM_INI[cam->index_cam].celldimx = bcdTodouble(gcir0.readoutInfo[0].pixelWidth);
   CAM_INI[cam->index_cam].celldimy = bcdTodouble(gcir0.readoutInfo[0].pixelHeight);
   CAM_INI[cam->index_cam].gain = (double) (gcir0.readoutInfo[0].gain/100.); /* e/ADU */
   CAM_INI[cam->index_cam].maxconvert = pow(2, (double) 16) - 1.;

   /* --- initialisation of elements of the structure cam === */
   cam->nb_photox = CAM_INI[cam->index_cam].maxx;	/* nombre de photosites sur X */
   cam->nb_photoy = CAM_INI[cam->index_cam].maxy;	/* nombre de photosites sur Y */
   if (cam->overscanindex == 0) {
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg;
      cam->nb_deadendphotox = CAM_INI[cam->index_cam].overscanxend;
      cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg;
      cam->nb_deadendphotoy = CAM_INI[cam->index_cam].overscanyend;
   } else {
      cam->nb_photox +=
         (CAM_INI[cam->index_cam].overscanxbeg +
         CAM_INI[cam->index_cam].overscanxend);
      cam->nb_photoy +=
         (CAM_INI[cam->index_cam].overscanybeg +
         CAM_INI[cam->index_cam].overscanyend);
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = 0;
      cam->nb_deadendphotox = 0;
      cam->nb_deadbeginphotoy = 0;
      cam->nb_deadendphotoy = 0;
   }

   cam->celldimx = CAM_INI[cam->index_cam].celldimx;	
   cam->celldimy = CAM_INI[cam->index_cam].celldimy;	
   // je calcule la taille de l'image en fonction du binning (Binning=1 par defaut)
   cam->x2 = cam->nb_photox - 1;
   cam->y2 = cam->nb_photoy - 1;
   cam_set_binning(1, 1, cam);
   // je mets a jour x1,y1,x2,y2,h,w dans cam 
   cam_update_window(cam);	
   // je recupere les informations des temperature
   sbig_get_info_temperatures(cam, &temp_setpoint, &temp_ccd, &temp_ambient, &temp_reg, &temp_power);
   cam->coolerindex = temp_reg;
   cam->temperature = temp_ccd;
   cam->check_temperature = temp_setpoint;


   /* --- Get track CCD Infos  --- */
   gcip.request = CCD_INFO_TRACKING;
   cam->drv_status = pardrvcommand(CC_GET_CCD_INFO, &gcip, &gcir0);
   // 0=CCD tracking, 6=pas de CCD tracking, autre=erreur //
   if (cam->drv_status!=6 && cam->drv_status!=0) {
      sprintf(cam->msg, "Error %d CCD_INFO_TRACKING. sbig_status=%s NEXT_CAMERA=%d", cam->drv_status,
      sbig_get_status(cam->drv_status), NEXT_CAMERA);
      cam_close(cam);
      return 9;
   } else if (cam->drv_status==0) {
      cam->cameraTypetrack = gcir0.cameraType;	/* name of the main CCD, not the tracking */
      cam->nb_photoxtrack = gcir0.readoutInfo[0].width;
      cam->nb_photoytrack = gcir0.readoutInfo[0].height;
      cam->nb_deadbeginphotoxtrack = 0;
      cam->nb_deadendphotoxtrack = 0;
      cam->nb_deadbeginphotoytrack = 0;
      cam->nb_deadendphotoytrack = 0;
      cam->celldimxtrack = bcdTodouble(gcir0.readoutInfo[0].pixelWidth);
      cam->celldimytrack = bcdTodouble(gcir0.readoutInfo[0].pixelHeight);
      cam->x1track = 0;
      cam->y1track = 0;
      cam->x2track = cam->nb_photoxtrack - 1;
      cam->y2track = cam->nb_photoytrack - 1;
      sbig_cam_set_binningtrack(1, 1, cam);
      sbig_cam_update_windowtrack(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
      cam->bufnotrack = 1;
      cam->exptimetrack = (float) 1.;
   }

   /* --- Start a dummy Exposure (=test of communication) --- */
   params.ccd = CCD_IMAGING;
   params.exposureTime = (unsigned long) (100. * cam->exptime);
   params.abgState = ABG_LOW7;
   params.openShutter = TRUE;
   params.readoutMode = 0;
   params.top = cam->nb_deadbeginphotoy;
   params.left = cam->nb_deadbeginphotox;
   params.height = cam->h;
   params.width = cam->w;
   cam->drv_status = pardrvcommand(CC_START_EXPOSURE2, &params, NULL);
   if (cam->drv_status != CE_NO_ERROR) {
      sprintf(cam->msg, "Error %d CC_START_EXPOSURE2 at line %d. sbig_status=%s", cam->drv_status,__LINE__,
         sbig_get_status(cam->drv_status));
      cam_close(cam);
      return 10;
   }


   // --- Wait end exposure
   qcsp.command = CC_START_EXPOSURE2;
   do {
   	cam->drv_status = SBIGUnivDrvCommand(CC_QUERY_COMMAND_STATUS, &qcsp, &qcsr);
      if(cam->drv_status != CE_NO_ERROR){
         printf(cam->msg, "Error %d CC_QUERY_COMMAND_STATUS at line %d. sbig_status=%s", cam->drv_status,__LINE__,
         sbig_get_status(cam->drv_status));
         return 10;
      }
   } while(qcsr.status != CS_INTEGRATION_COMPLETE);



   // --- End the dummy Exposure (=test of communication)
   eep.ccd = CCD_IMAGING;
   cam->drv_status = pardrvcommand(CC_END_EXPOSURE, &eep, NULL);
   if (cam->drv_status != CE_NO_ERROR ) {
      sprintf(cam->msg, "Error %d at line %d. sbig_status=%s", cam->drv_status, __LINE__,
         sbig_get_status(cam->drv_status));
      cam_close(cam);
      return 11;
   }


   // --- End the Readout (=test of communication)
    rlp.ccd = CCD_IMAGING;
    rlp.readoutMode = 0;
    rlp.pixelStart  = 0;
    rlp.pixelLength = 765;

   cam->drv_status = pardrvcommand(CC_END_READOUT, &rlp, NULL);
   if (cam->drv_status != CE_NO_ERROR ) {
      sprintf(cam->msg, "Error %d at line %d. sbig_status=%s", cam->drv_status, __LINE__,
         sbig_get_status(cam->drv_status));
      cam_close(cam);
      return 12;
   }

   pardrvcommand(CC_UPDATE_CLOCK, NULL, NULL);

   return 0;
}


int cam_close(struct camprop *cam)
{
   // --- close the device
   if (cam->opendevice == 1) {
      pardrvcommand(CC_CLOSE_DEVICE, NULL, NULL);
      cam->opendevice = 0;
   }

   // --- close the device
   pardrvcommand(CC_CLOSE_DRIVER, NULL, NULL);

   return 0;
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
    StartExposureParams2 params;
    double exptime;

    exptime =
	cam->exptime <
	((float) MIN_ST7_EXPOSURE) / 100. ? ((double) MIN_ST7_EXPOSURE) /
	100. : cam->exptime;

    params.ccd = (unsigned short) CCD_IMAGING;
    params.exposureTime = (unsigned long) (100. * exptime);
    params.abgState = (unsigned short) ABG_LOW7;
    if (cam->shutterindex == 0) {
        params.openShutter = (unsigned short) SC_CLOSE_SHUTTER;
    } else {
        params.openShutter = (unsigned short) SC_OPEN_SHUTTER;
    }
    params.readoutMode = cam->readoutMode;
    params.top = cam->x1;
    params.left = cam->y1;
    params.height = cam->h;
    params.width = cam->w;
    cam->drv_status = pardrvcommand(CC_START_EXPOSURE2, &params, NULL);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error status=%d at line %d. CC_START_EXPOSURE2 status=%s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return;
    }
    cam->drv_status = pardrvcommand(CC_UPDATE_CLOCK, NULL, NULL);
}

void cam_stop_exp(struct camprop *cam)
{
    EndExposureParams eep;
    eep.ccd = CCD_IMAGING;
    cam->drv_status = pardrvcommand(CC_END_EXPOSURE, &eep, NULL);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return;
    }
}

void cam_read_ccd(struct camprop *cam, float *p)
{
   EndReadoutParams erp;
   ReadoutLineParams rlp;
   DumpLinesParams dlp;
   EndExposureParams eep;
   int i;
   int x1, y1, binx, biny, h, w;
   
   if (p == NULL)
      return;

   x1 = cam->x1;
   y1 = cam->y1;
   binx = cam->binx;
   biny = cam->biny;
   h = cam->h;
   w = cam->w;
   
   /*
   // Pour tester la disponibilite de la fonction :
   // en envoyant un parametre NULL, elle retourne :
   // 0 si la commande est supportee,
   // -1 si la fonction est non supportee.
   */

   cam_stop_exp(cam);

   eep.ccd = CCD_IMAGING;
   cam->drv_status = pardrvcommand(CC_END_EXPOSURE, &eep, NULL);
   if (cam->drv_status) {
      sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
         sbig_get_status(cam->drv_status));
      return;
   }

   if (y1 > 1) {
      dlp.ccd = CCD_IMAGING;
      dlp.readoutMode = (unsigned short) (binx - 1);
      dlp.lineLength = (unsigned short) (y1 / biny);
      cam->drv_status = pardrvcommand(CC_DUMP_LINES, &dlp, NULL);
      if (cam->drv_status) {
         sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
         return;
      }
   }

   rlp.ccd = (unsigned short) CCD_IMAGING;
   rlp.readoutMode = (unsigned short) (binx - 1);
   rlp.pixelStart = (unsigned short) (x1 / binx);	// Les pixels commencent � 0
   rlp.pixelLength = (unsigned short) w;

   unsigned short * pushort = (unsigned short*) malloc(w*sizeof(unsigned short));
   if( pushort == NULL) {
      sprintf(cam->msg, "Error cam_read_ccd pushort=NULL ");
      return;
   }

   regulation_freeze(cam);
   for (i = h-1; i >= 0; i--) {
      cam->drv_status =
         pardrvcommand(CC_READOUT_LINE, &rlp, (void *) (pushort));
      if (cam->drv_status) {
         sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
         free(pushort);
         return;
      }
      for(int col=0 ; col < w ; col++) {          
         *(p + i * w + col) = (float) *(pushort+ col);
      }

   }
   regulation_unfreeze(cam);

   free(pushort);
   erp.ccd = CCD_IMAGING;
   cam->drv_status = pardrvcommand(CC_END_READOUT, &erp, NULL);
   if (cam->drv_status) {
      sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
         sbig_get_status(cam->drv_status));
      return;
   }
   cam->drv_status = pardrvcommand(CC_UPDATE_CLOCK, NULL, NULL);
}

void cam_shutter_on(struct camprop *cam)
{
}

void cam_shutter_off(struct camprop *cam)
{
}

void cam_ampli_on(struct camprop *cam)
{
}

void cam_ampli_off(struct camprop *cam)
{
}

void cam_measure_temperature(struct camprop *cam)
{
    float setpoint, ccd, ambient;
    int reg, power;
    cam->temperature = 0.;
    /*
       // setpoint = temperature de consigne
       // ccd = temperature du ccd
       // ambient = temperature ambiante
       // reg = regulation ?
       // power = puissance du peltier (0-255=0-100%)
     */
    gettemp(cam, &setpoint, &ccd, &ambient, &reg, &power);
    cam->temperature = (double) ccd;
}

void cam_cooler_on(struct camprop *cam)
{
    settemp(cam, (float) cam->check_temperature);
}

void cam_cooler_off(struct camprop *cam)
{
    regulation_off(cam);
}

void cam_cooler_check(struct camprop *cam)
{
    settemp(cam, (float) cam->check_temperature);
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
	int camstetc=0;
	if ((cam->cameraType == ST7_CAMERA)
	    || (cam->cameraType == ST8_CAMERA)
		|| (cam->cameraType == ST5C_CAMERA)
		|| (cam->cameraType == ST237_CAMERA)
		|| (cam->cameraType == STK_CAMERA)
		|| (cam->cameraType == ST9_CAMERA)
		|| (cam->cameraType == STV_CAMERA)
		|| (cam->cameraType == ST10_CAMERA)
		|| (cam->cameraType == ST1K_CAMERA)
		|| (cam->cameraType == ST2K_CAMERA)
		|| (cam->cameraType == STL_CAMERA)
		|| (cam->cameraType == ST402_CAMERA)
		|| (cam->cameraType == STX_CAMERA)
	    || (cam->cameraType == ST4K_CAMERA)) {
			camstetc=1;
	}

    if (binx < 1) {
        binx = 1;
    }
    if (biny < 1) {
        biny = 1;
    }
    if (binx > 255) {
        binx = 255;
    }
    if (biny > 255) {
        biny = 255;
    }
    /* readout Mode = 0 */
    if ((binx == 1) && (biny == 1)) {
        cam->readoutMode = 0;
        cam->binx = cam->biny = 1;
        return;
    }
    /* readout Mode = 1 */
    if ((binx == 2) && (biny == 2)) {
        cam->readoutMode = 1;
        cam->binx = cam->biny = 2;
        return;
    }
    /* readout Mode = 2 */
    if ((binx == 3) && (biny == 3)) {
	if (camstetc==1) {
	    cam->readoutMode = 2;
	    cam->binx = cam->biny = 3;
	    return;
	}
    }
    /* readout Mode = 0xNN03 0xNN04 0xNN05 */
    if (binx <= 3) {
	if (camstetc==1) {
	    cam->readoutMode = biny * 256 + binx;
	    cam->binx = binx;
	    cam->biny = biny;
	    return;
	}
    }
    /* readout Mode = 9 */
    if ((binx == 9) && (biny == 9)) {
	if (camstetc==1) {
	    cam->readoutMode = 9;
	    cam->binx = cam->biny = 3; // deduit d'une STL 11K
	    return;
	}
    }
    /* binning out of Sbig specifications */
    cam->readoutMode = 0;
    cam->binx = cam->biny = 1;
    if ((binx > 3) || (biny > 3)) {
	if (camstetc==1) {
	    cam->readoutMode = 2;
	    cam->binx = cam->biny = 3;
	} else {
	    cam->readoutMode = 1;
	    cam->binx = cam->biny = 2;
	}
    }
    return;
}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy;
    maxx = cam->nb_photox;
    maxy = cam->nb_photoy;
    if (cam->x1 > cam->x2)
        libcam_swap(&(cam->x1), &(cam->x2));
    if (cam->x1 < 0)
        cam->x1 = 0;
    if (cam->x2 > maxx - 1)
        cam->x2 = maxx - 1;

    if (cam->y1 > cam->y2)
        libcam_swap(&(cam->y1), &(cam->y2));
    if (cam->y1 < 0)
        cam->y1 = 0;
    if (cam->y2 > maxy - 1)
        cam->y2 = maxy - 1;

    cam->w = (cam->x2 - cam->x1 + 1) / cam->binx;
    //cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1 + 1) / cam->biny;
    //cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}

void sbig_cam_update_windowtrack(struct camprop *cam)
{
    int maxx, maxy;
    maxx = cam->nb_photoxtrack;
    maxy = cam->nb_photoytrack;
    if (cam->x1track > cam->x2track)
        libcam_swap(&(cam->x1track), &(cam->x2track));
    if (cam->x1track < 0)
        cam->x1track = 0;
    if (cam->x2track > maxx - 1)
        cam->x2track = maxx - 1;

    if (cam->y1track > cam->y2track)
        libcam_swap(&(cam->y1track), &(cam->y2track));
    if (cam->y1track < 0)
        cam->y1track = 0;
    if (cam->y2track > maxy - 1)
        cam->y2track = maxy - 1;

    cam->wtrack = (cam->x2track - cam->x1track + 1) / cam->binxtrack;
    //cam->x2track = cam->x1track + cam->wtrack * cam->binxtrack - 1;
    cam->htrack = (cam->y2track - cam->y1track + 1) / cam->binytrack;
    //cam->y2track = cam->y1track + cam->htrack * cam->binytrack - 1;
}

void sbig_cam_start_exptrack(struct camprop *cam, char *amplionoff)
{
    StartExposureParams params;
    double exptime;

    exptime =
	cam->exptimetrack <
	((float) MIN_ST7_EXPOSURE) / 100. ? ((double) MIN_ST7_EXPOSURE) /
	100. : cam->exptime;

    params.ccd = (unsigned short) CCD_TRACKING;
    params.exposureTime = (unsigned long) (100. * exptime);
    params.abgState = (unsigned short) ABG_LOW7;
    params.openShutter = (unsigned short) SC_LEAVE_SHUTTER;
    cam->drv_status = pardrvcommand(CC_START_EXPOSURE, &params, NULL);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return;
    }
    cam->drv_status = pardrvcommand(CC_UPDATE_CLOCK, NULL, NULL);
}

void sbig_cam_stop_exptrack(struct camprop *cam)
{
    EndExposureParams eep;
    eep.ccd = CCD_TRACKING;
    cam->drv_status = pardrvcommand(CC_END_EXPOSURE, &eep, NULL);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return;
    }
}

void sbig_cam_read_ccdtrack(struct camprop *cam, float *p)
{
    EndReadoutParams erp;
    ReadoutLineParams rlp;
    DumpLinesParams dlp;
    EndExposureParams eep;
    int i;
    int x1, y1, binx, biny, h, w;

    if (p == NULL)
        return;

    x1 = cam->x1track;
    y1 = cam->y1track;
    binx = cam->binxtrack;
    biny = cam->binytrack;
    h = cam->htrack;
    w = cam->wtrack;

    /*
       // Pour tester la disponibilite de la fonction :
       // en envoyant un parametre NULL, elle retourne :
       // 0 si la commande est supportee,
       // -1 si la fonction est non supportee.
     */

    sbig_cam_stop_exptrack(cam);

    eep.ccd = CCD_TRACKING;
    cam->drv_status = pardrvcommand(CC_END_EXPOSURE, &eep, NULL);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return;
    }

    if (y1 > 1) {
        dlp.ccd = CCD_TRACKING;
        dlp.readoutMode = (unsigned short) (binx - 1);
        dlp.lineLength = (unsigned short) (y1 / biny);
        cam->drv_status = pardrvcommand(CC_DUMP_LINES, &dlp, NULL);
        if (cam->drv_status) {
            sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
                sbig_get_status(cam->drv_status));
            return;
        }
    }

    rlp.ccd = (unsigned short) CCD_TRACKING;
    rlp.readoutMode = (unsigned short) (binx - 1);
    rlp.pixelStart = (unsigned short) (x1 / binx);	// Les pixels commencent � 0
    rlp.pixelLength = (unsigned short) w;

    unsigned short * pushort = (unsigned short*) malloc(w*sizeof(unsigned short));
    if( pushort == NULL) {
       sprintf(cam->msg, "Error sbig_cam_read_ccdtrack pushort=NULL ");
       return;
    }
    for (i = 0; i < h; i++) {
       cam->drv_status = pardrvcommand(CC_READOUT_LINE, &rlp, (void *) (pushort));
       if (cam->drv_status) {
          sprintf(cam->msg, "Error %d. %s", cam->drv_status,
             sbig_get_status(cam->drv_status));
          free(pushort);
          return;
       }
       for(int col=0 ; col < w ; col++) {          
          *(p + i * w + col) = (float) *(pushort + col);
       }
    }

    free(pushort);

    erp.ccd = CCD_TRACKING;
    cam->drv_status = pardrvcommand(CC_END_READOUT, &erp, NULL);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return;
    }
    cam->drv_status = pardrvcommand(CC_UPDATE_CLOCK, NULL, NULL);

}

void sbig_cam_set_binningtrack(int binx, int biny, struct camprop *cam)
{
    if (binx < 1) {
        binx = 1;
    }
    if (biny < 1) {
        biny = 1;
    }
    if (binx > 255) {
        binx = 255;
    }
    if (biny > 255) {
        biny = 255;
    }
    /* readout Mode = 0 */
    if ((binx == 1) && (biny == 1)) {
        cam->readoutModetrack = 0;
        cam->binxtrack = cam->binytrack = 1;
        return;
    }
    /* readout Mode = 1 */
    if ((binx == 2) && (biny == 2)) {
        cam->readoutModetrack = 1;
        cam->binxtrack = cam->binytrack = 2;
        return;
    }
    /* readout Mode = 2 */
    if ((binx == 3) && (biny == 3)) {
	if ((cam->cameraType == ST7_CAMERA)
	    || (cam->cameraType == ST8_CAMERA)
	    || (cam->cameraType == ST237_CAMERA)) {
	    cam->readoutModetrack = 2;
	    cam->binxtrack = cam->binytrack = 3;
	    return;
	}
    }
    /* readout Mode = 0xNN03 0xNN04 0xNN05 */
    if (binx <= 3) {
	if ((cam->cameraType == ST7_CAMERA)
	    || (cam->cameraType == ST8_CAMERA)) {
	    cam->readoutModetrack = biny * 256 + binx;
	    cam->binxtrack = binx;
	    cam->binytrack = biny;
	    return;
	}
    }
    /* readout Mode = 9 */
    if ((binx == 9) && (biny == 9)) {
	if ((cam->cameraType == ST7_CAMERA)
	    || (cam->cameraType == ST8_CAMERA)) {
	    cam->readoutModetrack = 9;
	    cam->binxtrack = cam->binytrack = 9;
	    return;
	}
    }
    /* binning out of Sbig specifications */
    cam->readoutModetrack = 0;
    cam->binxtrack = cam->binytrack = 1;
    if ((binx > 3) || (biny > 3)) {
	if ((cam->cameraType == ST7_CAMERA)
	    || (cam->cameraType == ST8_CAMERA)
	    || (cam->cameraType == ST237_CAMERA)) {
	    cam->readoutModetrack = 2;
	    cam->binxtrack = cam->binytrack = 3;
	} else {
	    cam->readoutModetrack = 1;
	    cam->binxtrack = cam->binytrack = 2;
	}
    }
    return;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

char *sbig_get_status(int st)
{
    static char msg[256];
    GetErrorStringParams gesp;
    GetErrorStringResults gesr;
    gesp.errorNo = (unsigned short) st;
    if (pardrvcommand(CC_GET_ERROR_STRING, &st, &gesr.errorString) == 0) {
        strcpy(msg, gesr.errorString);
    } else {
        sprintf(msg, "Sorry, no text description for this error %d",st);
    }
    return msg;
}

float setpoint2ambienttemp(int setpoint)
{
    double r, t;
    r = ST7_R_BRIDGE1 / (ST7_MAXAD / ((double) (setpoint)) - 1.0f);
    t = ST7_T0 - ST7_DT1 * log(r / ST7_R0) / log(ST7_R_RATIO1);
    return (float) t;
}

float setpoint2ccdtemp(int setpoint)
{
    double r, t;

    r = ST7_R_BRIDGE2 / (ST7_MAXAD / ((double) (setpoint)) - 1.0f);
    t = ST7_T0 - ST7_DT2 * log(r / ST7_R0) / log(ST7_R_RATIO2);
    return (float) t;
}

int temp2setpoint(float temp)
{
    double r;
    int setpoint;

    r = ST7_R0 * exp(log(ST7_R_RATIO2) * (ST7_T0 - temp) / ST7_DT2);
    setpoint = (int) (ST7_MAXAD / (1.0f + ST7_R_BRIDGE2 / r));
    return setpoint;
}

/*
// setpoint = temp�rature de consigne
// ccd = temp�rature du ccd
// ambient = temp�rature ambiante
// reg = r�gulation ?
// power = puissance du peltier (0-255=0-100%)
*/
int gettemp(struct camprop *cam, float *setpoint, float *ccd,
	    float *ambient, int *reg, int *power)
{
    QueryTemperatureStatusResults qtsr;
    cam->drv_status =
	pardrvcommand(CC_QUERY_TEMPERATURE_STATUS, NULL, &qtsr);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return 3;
    }
    if (setpoint) {
        if (qtsr.enabled == 1)
            *setpoint = (float) setpoint2ccdtemp(qtsr.ccdSetpoint);
        else
            *setpoint = -1.0f;
    }
    if (ccd) {
        *ccd = (float) setpoint2ccdtemp((int) qtsr.ccdThermistor);
    }
    if (ambient) {
        *ambient =
            (float) setpoint2ambienttemp((int) qtsr.ambientThermistor);
    }
    if (reg) {
        *reg = (int) qtsr.enabled;
    }
    if (power) {
        *power = (int) qtsr.power;
    }
    return 0;
}

int settemp(struct camprop *cam, float temp)
{
    QueryTemperatureStatusResults qtsr;
    SetTemperatureRegulationParams strp;
    cam->drv_status =
        pardrvcommand(CC_QUERY_TEMPERATURE_STATUS, NULL, &qtsr);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return 1;
    }
    strp.regulation = REGULATION_ON;
    strp.ccdSetpoint = (unsigned short) temp2setpoint(temp);
    cam->drv_status =
        pardrvcommand(CC_SET_TEMPERATURE_REGULATION, &strp, NULL);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return 2;
    }
    return 0;
}

int regulation_off(struct camprop *cam)
{
    QueryTemperatureStatusResults qtsr;
    SetTemperatureRegulationParams strp;
    cam->drv_status =
        pardrvcommand(CC_QUERY_TEMPERATURE_STATUS, NULL, &qtsr);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return 2;
    }
    if (qtsr.enabled != 0) {
        strp.regulation = REGULATION_OFF;
        strp.ccdSetpoint = 0;
        cam->drv_status =
            pardrvcommand(CC_SET_TEMPERATURE_REGULATION, &strp, NULL);
        if (cam->drv_status) {
            sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                sbig_get_status(cam->drv_status));
            return 3;
        }
    }
    return 0;
}

int regulation_freeze(struct camprop *cam)
{
    QueryTemperatureStatusResults qtsr;
    SetTemperatureRegulationParams strp;
    cam->drv_status =
        pardrvcommand(CC_QUERY_TEMPERATURE_STATUS, NULL, &qtsr);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return 2;
    }
    if (qtsr.enabled != 0) {
        strp.regulation = REGULATION_FREEZE;
        strp.ccdSetpoint = 0;
        cam->drv_status =
            pardrvcommand(CC_SET_TEMPERATURE_REGULATION, &strp, NULL);
        if (cam->drv_status) {
            sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                sbig_get_status(cam->drv_status));
            return 3;
        }
    }
    return 0;
}

int regulation_unfreeze(struct camprop *cam)
{
    QueryTemperatureStatusResults qtsr;
    SetTemperatureRegulationParams strp;
    cam->drv_status =
        pardrvcommand(CC_QUERY_TEMPERATURE_STATUS, NULL, &qtsr);
    if (cam->drv_status) {
        sprintf(cam->msg, "Error %d at line %d. %s", __LINE__, cam->drv_status,
            sbig_get_status(cam->drv_status));
        return 2;
    }
    if (qtsr.enabled != 0) {
        strp.regulation = REGULATION_UNFREEZE;
        strp.ccdSetpoint = 0;
        cam->drv_status =
            pardrvcommand(CC_SET_TEMPERATURE_REGULATION, &strp, NULL);
        if (cam->drv_status) {
            sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                sbig_get_status(cam->drv_status));
            return 3;
        }
    }
    return 0;
}

void sbig_get_info_temperatures(struct camprop *cam, double *setpoint,
				double *ccd, double *ambient, int *reg,
				int *power)
{
    
    // setpoint = temperature de consigne
    // ccd = temperature du ccd
    // ambient = temprature ambiante
    // reg = regulation ?
    // power = puissance du peltier (0-255=0-100%)
 
    float fsetpoint, fccd, fambient;
    gettemp(cam, &fsetpoint, &fccd, &fambient, reg, power);
    *setpoint = (double) fsetpoint;
    *ccd = (double) fccd;
    *ambient = (double) fambient;
}

// convertis une valeur BCD en double  
// et multiplie par 1e-6
double bcdTodouble(unsigned long bcd)
{
   double value = 0.0;
   double digit = 0.01;
   int i; 
   for(i = 0; i < 8; i++) {
      value += (bcd & 0x0F) * digit;
      digit *= 10.0;
      bcd  >>= 4;
   } 
   // je convertis en metre 
   value *= 1e-6;
   return value;
}
