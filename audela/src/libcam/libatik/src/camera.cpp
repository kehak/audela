/* camera.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain Klotz
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

#include <windows.h>
#include <exception>
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */
#include "ArtemisHSCAPI.h"      /* do not include this in camera.h */
#include "camera.h"

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"noname",			/* camera name 70 car maxi*/
     "atik",     /* camera product */
     "",			      /* ccd name */
     768, 512,			/* maxx maxy */
     14, 14,			/* overscans x */
     4, 4,			   /* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			    /* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			   /* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop * cam);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
//static void cam_ampli_on(struct camprop *cam);
//static void cam_ampli_off(struct camprop *cam);
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
    NULL, //cam_ampli_on,
    NULL, //cam_ampli_off,
    cam_measure_temperature,
    cam_cooler_on,
    cam_cooler_off,
    cam_cooler_check
};

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
{
	ARTEMISPROPERTIES pProp;
	char texte[1024];
	int device=-1;

   // je recupere les parametres optionnels
   if (argc >= 5) {
      for (int kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-device") == 0) {            
            device = atoi(argv[kk + 1]);
         }
      }
   }
	cam->hCam=NULL;

	// Load the Artemis DLL
	// This must be done before calling any of the other Artemis API functions.
	if (!ArtemisLoadDLL(ARTEMISDLLNAME))
	{
	  sprintf(cam->msg, "Cannot load %s Artemis",ARTEMISDLLNAME);
	  return -1;
	}

	// Now connect the device (=-1 for the first available camera)
	cam->hCam=ArtemisConnect(device);
	if (cam->hCam==NULL)
	{
	  sprintf(cam->msg, "No camera available");
	  return -2;
	}
	if (device==-1) {
		device=0;
	}

   // je recupere les parametres optionnels
   if (argc >= 5) {
      for (int kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "") == 0) {            
            //debug_level = atoi(argv[kk + 1]);
         }
      }
   }

	strcpy(CAM_INI[cam->index_cam].name,"");
	if (!ArtemisDeviceName(device,texte)) {
	  strcpy(texte,"Atik");
	}
	strncat(CAM_INI[cam->index_cam].name, texte,sizeof(CAM_INI[cam->index_cam].name) -1 );

   // Fills in pProp with camera properties
   if (ArtemisProperties(cam->hCam,&pProp)==0) {
      // je recupere la largeur et la hauteur du CCD en pixels (en pixel sans binning)
      cam->nb_photox  = pProp.nPixelsX;
      cam->nb_photoy  = pProp.nPixelsY;
      // je recupere la taille des pixels (en micron converti en metre)
      cam->celldimx   = pProp.PixelMicronsX * 1e-6;
      cam->celldimy   = pProp.PixelMicronsY * 1e-6;      
		// je recupere la description
		strcat(CAM_INI[cam->index_cam].name," (");
		strncat(CAM_INI[cam->index_cam].name,pProp.Description,sizeof(CAM_INI[cam->index_cam].name) -1 );
		strcat(CAM_INI[cam->index_cam].name,")");
   }

	if (!ArtemisDeviceSerial(device,texte)) {
	  strcpy(texte,"0");
	}
	strncat(cam->serial_number,texte,sizeof(cam->serial_number) -1 );

	int w,h;
	ArtemisGetSubframe(cam->hCam,&cam->x1,&cam->y1,&w,&h);
   cam->x1 = 0;
   cam->y1 = 0;
   cam->x2 = w - 1;
   cam->y2 = h - 1;
	ArtemisGetBin(cam->hCam,&cam->binx,&cam->biny);
   cam_update_window(cam);	// met a jour x1,y1,x2,y2,h,w dans cam

	/////////////////////////////////////////////////
	// Returns information on the Peltier cooler.
	atik_cooler_informations(cam);
	cam->check_temperature=0;

   strcpy(cam->date_obs, "2000-01-01T12:00:00");
   strcpy(cam->date_end, cam->date_obs);
   cam->authorized = 1;
   return 0;
}

int cam_close(struct camprop * cam)
{
	ArtemisDisconnect(cam->hCam);
	ArtemisUnLoadDLL();
   return 0;
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   int x1, x2, y1, y2; 

   if (cam->x1 > cam->x2) {
      int x0 = cam->x2;
      cam->x2 = cam->x1;
      cam->x1 = x0;
   }
   if (cam->x1 < 0) {
      cam->x1 = 0;
   }
   if (cam->x2 > maxx - 1) {
      cam->x2 = maxx - 1;
   }

   if (cam->y1 > cam->y2) {
      int y0 = cam->y2;
      cam->y2 = cam->y1;
      cam->y1 = y0;
   }
   if (cam->y1 < 0) {
      cam->y1 = 0;
   }

   if (cam->y2 > maxy - 1) {
      cam->y2 = maxy - 1;
   }

   // je prend en compte le binning 
   cam->w = (cam->x2 - cam->x1 +1) / cam->binx ;
   cam->h = (cam->y2 - cam->y1 +1) / cam->biny ;
   x1 = cam->x1  / cam->binx;
   y1 = cam->y1 / cam->biny;
   x2 = x1 + cam->w -1;
   y2 = y1 + cam->h -1;

   // j'applique le miroir aux coordonnes de la sous fenetre
   if ( cam->mirrorv == 1 ) {
      // j'applique un miroir vertical en inversant les ordonnees de la fenetre
      x1 = (maxx / cam->binx ) - x2 -1;
   }
   if ( cam->mirrorh == 1 ) {
      // j'applique un miroir horizontal en inversant les abcisses de la fenetre
      // 0---y1-----y2---------------------(w-1)
      // 0---------------(w-y2)---(w-y1)---(w-1)  
      y1 = (maxy / cam->biny ) - y2 -1;
   }
   
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
	// Don't switch amplifier off for short exposures
	ArtemisSetAmplifierSwitched(cam->hCam, (1000*cam->exptime)>2.5f);

	// window
	int w = cam->x2 - cam->x1 +1;
	int h = cam->y2 - cam->y1 +1;
	ArtemisSubframe(cam->hCam,cam->x1,cam->y1,w,h);

	// binning
	ArtemisBin(cam->hCam,cam->binx,cam->biny);

	// Enable/disable dark mode - ie the shutter is to be kept closed during exposures
	bool bEnable = 0;
	if (cam->shutterindex == 0) {
		/* case : shutter always off (Darks) */
		bEnable = 1;
	}
	ArtemisSetDarkMode(cam->hCam,bEnable);

	// Start the exposure
	ArtemisStartExposure(cam->hCam,cam->exptime);

}

void cam_stop_exp(struct camprop *cam)
{
	if (cam->mode_stop_acq==0) {
		ArtemisStopExposure(cam->hCam);
	} else {
		ArtemisAbortExposure(cam->hCam);
	}
	cam->stop_detected=1;
	return;
}

void cam_read_ccd(struct camprop *cam, float *p)
{

	// Wait until it's ready, 
	while(!ArtemisImageReady(cam->hCam))
	{
		Sleep(100);
	}

	// Get dimensions of image
	//int x,y,wid,hgt,binx,biny;
	//ArtemisGetImageData(cam->hCam, &x, &y, &wid, &hgt, &binx, &biny);

	unsigned short* pimg=(unsigned short*)ArtemisImageBuffer(cam->hCam);

    // je copie l'image dans le buffer
    for( int y=0; y <cam->h; y++) {
       for( int x=0; x <cam->w; x++) {
          p[x+y*cam->w] = (float) pimg[x+y*cam->w];
       }
    }
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
	if (cam->cooler_implemented==1) {
		int temperature;
		ArtemisTemperatureSensorInfo(cam->hCam,1,&temperature);
		cam->temperature = (double)temperature/100.0;
	} else {
		cam->temperature = 0;
	}
	return;
}

void cam_cooler_on(struct camprop *cam)
{
	if (cam->cooler_implemented==1) {
		int setpoint;
		setpoint=(int)(cam->check_temperature*100);
		ArtemisSetCooling(cam->hCam,setpoint);
	}
}

void cam_cooler_off(struct camprop *cam)
{
	if (cam->cooler_implemented==1) {
		ArtemisCoolerWarmUp(cam->hCam);
	}
}

void cam_cooler_check(struct camprop *cam)
{
	if (cam->cooler_implemented==1) {
		int setpoint;
		setpoint=(int)(cam->check_temperature*100);
		ArtemisSetCooling(cam->hCam,setpoint);
	}
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
  cam->binx = binx;
  cam->biny = biny;
}

void atik_cooler_informations(struct camprop *cam)
{
	/////////////////////////////////////////////////
	// Returns information on the Peltier cooler.
	// flags: b0-4 capabilities
	// b0 0 = no cooling 1=cooling
	// b1 0= always on 1= controllable
	// b2 0 = on/off control not available 1= on off cooling control
	// b3 0= no selectable power levels 1= selectable power levels
	// b4 0 = no temperature set point cooling 1= set point cooling
	// b5-7 report what’s actually happening
	// b5 0=normal control 1=warming up
	// b6 0=cooling off 1=cooling on
	// b7 0= no set point control 1=set point control
	// level is the current cooler power level.
	// minlvl is the minimum power level than can be set on order to prevent
	// rapid warming.
	// maxlvl is the maximum power level than can be set or returned, can be
	// used to scale power to a percentage.
	// setpoint is the current temperature setpoint, in degrees Celsius * 100
	// Error code on error
	int err,flags,level, minlvl, maxlvl,setpoint;
	int temperature;
	err=ArtemisCoolingInfo(cam->hCam,&flags,&level,&minlvl,&maxlvl,&setpoint);
	if (err==ARTEMIS_OK) {
		cam->cooler_implemented=1;
	} else {
		cam->cooler_implemented=0;
	}
	cam->b0_cooling=(flags&0x01);
	cam->b1_controllable=(flags&0x02)>>1;
	cam->b2_on_off_cooling_control=(flags&0x04)>>2;
	cam->b3_selectable_power_levels=(flags&0x08)>>3;
	cam->b4_set_point_cooling_available=(flags&0x10)>>4;
	cam->b5_state_warming_up=(flags&0x20)>>5;
	cam->b6_state_cooling_on=(flags&0x40)>>6;
	cam->b7_state_set_point_control=(flags&0x80)>>7;
	cam->cooler_power_level=level;
	cam->minlvl=minlvl;
	cam->maxlvl=maxlvl;
	cam->current_temperature_setpoint=(float)(setpoint/100.);
	ArtemisTemperatureSensorInfo(cam->hCam,1,&temperature);
	cam->temperature = (double)temperature/100.0;
}
