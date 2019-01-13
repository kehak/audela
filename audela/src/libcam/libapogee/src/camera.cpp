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
#include "camera.h"
#include "camera_plusplus.h"
#include "camtcl.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"noname",			/* camera name 70 car maxi*/
     "apogee",     /* camera product */
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

struct camprop_plusplus cam_plusplus;

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
	//char texte[1024];
	int device=-1;
	ICamera2Ptr ApogeeCamera; // Camera interface 

   // je recupere les parametres optionnels
   if (argc >= 5) {
      for (int kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-device") == 0) {            
            device = atoi(argv[kk + 1]);
         }
      }
   }

   HRESULT hr; // Return code 
	
	// Initialize COM library
	CoInitialize( NULL );
   
   // Create the ICamera2 object 
   hr = ApogeeCamera.CreateInstance( __uuidof( Camera2 ) );
   if ( !SUCCEEDED(hr) ) { 
      strcpy(cam->msg,"Failed to create the ICamera2 object");
      CoUninitialize(); // Close the COM library 
      return(1);
   } 
	// store Apogee pointer in the cam_plusplus structure
	cam_plusplus.ApogeeCamera = ApogeeCamera; // Camera interface of type *ICamera2Ptr
	
	// Create the ICamDiscover object
	ICamDiscoverPtr Discover; // Discovery interface 
   hr = Discover.CreateInstance( __uuidof( CamDiscover ) ); 
   if ( !SUCCEEDED(hr) ) { 
      strcpy(cam->msg,"Failed to create the ICamDiscover object");
      ApogeeCamera = NULL; // Release ICamera2 COM object 
      CoUninitialize(); // Close the COM library 
      return(2); 
   } 

	if (1==1) {
		// No interface for USB
		Apn_Interface Interface = Apn_Interface_USB ;
		long CamIdOne=0;
		long CamIdTwo=0x0;
		long Option=0x0;
		hr=ApogeeCamera->Init(Interface,CamIdOne,CamIdTwo,Option);
		strcpy(cam->portname,"USB");
	} else {
		// Show interface for choosing camera
		// Set the checkboxes to default to searching both USB and 
		// ethernet interfaces for all types of Alta/Ascent cameras
		Discover->DlgCheckEthernet = true; 
		Discover->DlgCheckUsb = true; 
	   
		// Display the dialog box for finding a camera 
		Discover->ShowDialog( true ); 
	   
		// If a camera was not selected, then release objects and exit 
		if ( !Discover->ValidSelection ) { 
			strcpy(cam->msg,"No valid camera selection made");
			Discover = NULL; // Release ICamDiscover COM object 
			ApogeeCamera = NULL; // Release ICamera2 COM object 
			CoUninitialize(); // Close the COM library 
			return(3); 
		}
		// Initialize camera using the ICamDiscover properties 
		hr = ApogeeCamera->Init( Discover->SelectedInterface, Discover->SelectedCamIdOne, Discover->SelectedCamIdTwo, 0x0 );
		if (Discover->SelectedInterface==Apn_Interface_USB) {
			strcpy(cam->portname,"USB");
		} else {
			strcpy(cam->portname,"Ethernet");
		}
	}
   Discover = NULL; // Release ICamDiscover COM object 
   if ( !SUCCEEDED(hr) ) { 
      strcpy(cam->msg,"Failed to connect to camera");
      Discover = NULL; // Release Discover COM object 
      ApogeeCamera = NULL; // Release ICamera2 COM object 
      CoUninitialize(); // Close the COM library 
      return(4); 
   } 
   
   // === Fills with camera properties

   // je recupere la description
   strcpy(CAM_INI[cam->index_cam].name,ApogeeCamera->CameraModel);
   strcpy(CAM_INI[cam->index_cam].product,"Apogee");
   strcpy(CAM_INI[cam->index_cam].ccd,ApogeeCamera->Sensor);
   //strcat(CAM_INI[cam->index_cam].name," ");
   //strncat(CAM_INI[cam->index_cam].name,ApogeeCamera->DriverVersion,sizeof(ApogeeCamera->DriverVersion) -1 );
   //strcat(CAM_INI[cam->index_cam].name," ");
   //strncat(CAM_INI[cam->index_cam].name,ApogeeCamera->SystemDriverVersion ,sizeof(ApogeeCamera->SystemDriverVersion ) -1 ); // Version information for AltaUsb.sys	
   //strcat(CAM_INI[cam->index_cam].name," ");
   //LONG strncat(CAM_INI[cam->index_cam].name,ApogeeCamera->FirmwareVersion,sizeof(ApogeeCamera->FirmwareVersion) -1 );
   //strcat(CAM_INI[cam->index_cam].name," ");
   //strncat(CAM_INI[cam->index_cam].name,ApogeeCamera->PlatformType,sizeof(ApogeeCamera->PlatformType) -1 );
   //strcat(CAM_INI[cam->index_cam].name," ");
   //VARIANT_BOOL strncat(CAM_INI[cam->index_cam].name,ApogeeCamera->SensorTypeCCD,sizeof(ApogeeCamera->SensorTypeCCD) -1 ) ; 
	//strcat(CAM_INI[cam->index_cam].name,")");

	//GetAdGain; // Returns the analog to digital converter’s gain value
	//GetAdOffset ; //Returns the analog to digital converter’s offset value
	cam->MaxBinningH = ApogeeCamera->MaxBinningH; //Maximum horizontal binning supported by the camera
	cam->MaxBinningV = ApogeeCamera->MaxBinningV; //Maximum vertical binning supported by the camera
	cam->MaxExposure = ApogeeCamera->MaxExposure; //Maximum duration of a single exposure
	cam->MinExposure = ApogeeCamera->MinExposure; //Minimum duration of a single exposure
	cam->NumAds = ApogeeCamera->NumAds; // Number of analog to digital (AD) converts on the camera
	cam->NumAdChannels = ApogeeCamera->NumAdChannels; // Number channels available on the AD converts

   // je recupere la largeur et la hauteur du CCD en pixels (en pixel sans binning)
   cam->nb_photox = ApogeeCamera->ImagingColumns; 
   cam->nb_photoy = ApogeeCamera->ImagingRows;
	CAM_INI[cam->index_cam].maxx=cam->nb_photox;
	CAM_INI[cam->index_cam].maxy=cam->nb_photoy;

   // je recupere la taille des pixels (en micron converti en metre)
   cam->celldimx   = ApogeeCamera->PixelSizeX * 1e-6;
   cam->celldimy   = ApogeeCamera->PixelSizeX * 1e-6;      

	// overscan
	ApogeeCamera->DigitizeOverscan = false;
	CAM_INI[cam->index_cam].overscanindex=0;
   CAM_INI[cam->index_cam].overscanxbeg=0;
   CAM_INI[cam->index_cam].overscanxend=(int)ApogeeCamera->OverscanColumns;
   CAM_INI[cam->index_cam].overscanybeg=0;
   CAM_INI[cam->index_cam].overscanyend=0;

	// fenetrage (= ROI = Region Of Interest)
   cam->x1 = 0;
   cam->y1 = 0;
   cam->x2 = cam->nb_photox - 1;
   cam->y2 = cam->nb_photoy - 1;

	// binning
	cam_set_binning(1,1,cam);
   cam_update_window(cam);	// met a jour x1,y1,x2,y2,h,w dans cam
	ApogeeCamera->RoiBinningH = (long)cam->binx;
	ApogeeCamera->RoiBinningV = (long)cam->biny;

	// cooler
	if (ApogeeCamera->CoolerControl==VARIANT_TRUE) {
		cam->cooler_implemented=1;
	} else {
		cam->cooler_implemented=0;
	}
	cam->cooler_implemented=1;

   // Show how to configure the I/O Port registers 
   
   // Default setting is for the I/O Port to be completely user defined. 
   // Setting the IoPortAssignment to 0x2 will then select only Pin 2 
   // (Bit 1) to be configured for the pre-defined Shutter Output state 
   // (note that Bit 0 corresponds to Pin 1) 
   ApogeeCamera->IoPortAssignment = 0x2; 
   
   // We want Pins 4 and 5 to be configured as outputs, so this requires 
   // us to set Bits 3 and 4 of the IoPortDirection variable (note that 
   // Bit 0 corresponds to Pin 1) 
   ApogeeCamera->IoPortDirection = 0x18;
   
   // je recupere les parametres optionnels
   if (argc >= 5) {
      for (int kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "") == 0) {            
            //debug_level = atoi(argv[kk + 1]);
         }
      }
   }

	cam->check_temperature=0;

   strcpy(cam->date_obs, "2000-01-01T12:00:00");
   strcpy(cam->date_end, cam->date_obs);
   cam->authorized = 1;
   return 0;
}

int cam_close(struct camprop * cam)
{
   // The I/O Port is now configured for the application to use. 
   // Release our allocated objects. Alternatively, we could call the 
   // ApogeeCamera->Close() method, but that isn't necessary 
   // in C++, as setting the object to NULL will close down the object. 
   cam_plusplus.ApogeeCamera = NULL; // Release ICamera2 COM object 
   CoUninitialize(); // Close the COM library
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
   HRESULT hr; // Return code 
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;

	// window
	int w = cam->x2 - cam->x1 +1;
	int h = cam->y2 - cam->y1 +1;
	ApogeeCamera->RoiStartX = (long)(cam->x1);
	ApogeeCamera->RoiPixelsH = (long)(cam->w);
	ApogeeCamera->RoiStartY = (long)(cam->y1);
	ApogeeCamera->RoiPixelsV = (long)(cam->h);
	
	// binning
	ApogeeCamera->RoiBinningH = (long) cam->binx;
	ApogeeCamera->RoiBinningV = (long) cam->biny;

	// Enable/disable dark mode - ie the shutter is to be kept closed during exposures
	bool bEnable = true;
	if (cam->shutterindex == 0) {
		// case : shutter always off (Darks)
		// ApogeeCamera->DisableShutter = VARIANT_FALSE;
		bEnable = false ;
	}

	// Start the exposure
	double exptime;
	exptime = cam->exptime;
	if (exptime < cam->MinExposure ) {
		exptime = cam->MinExposure ;
	}
	if (exptime > cam->MaxExposure ) {
		exptime = cam->MaxExposure ;
	}
   hr = ApogeeCamera->Expose( exptime, bEnable ); 
   if ( !SUCCEEDED(hr) ) { 
      return; 
   } 

}

void cam_stop_exp(struct camprop *cam)
{
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;
	if (cam->mode_stop_acq==0) {
		ApogeeCamera->StopExposure(VARIANT_TRUE);
	} else {
		ApogeeCamera->StopExposure(VARIANT_FALSE);
	}
	cam->stop_detected=1;
	return;
}

void cam_read_ccd(struct camprop *cam, float *p)
{
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;
	
   // Check camera status to make sure image data is ready 
	while ( ApogeeCamera->ImagingStatus != Apn_Status_ImageReady ) {
		Sleep(100);
	}

   // Query the image size
   long ImgXSize = cam->w; 
   long ImgYSize = cam->h;
   
   // Allocate memory 
   unsigned short *pBuffer = new unsigned short[ ImgXSize * ImgYSize ]; 
   
	// Get the image data from the camera 
   ApogeeCamera->GetImage( (long)pBuffer ); 

    // je copie l'image dans le buffer
	cam->pixel_data = NULL ;
	for( int y=0; y <cam->h; y++) {
       for( int x=0; x <cam->w; x++) {
          p[x+y*cam->w] = (float)pBuffer[x+y*cam->w];
       }
    }

   // Delete the memory buffer for storing the image 
   delete [] pBuffer; 
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
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;
	if (cam->cooler_implemented==1) {
		cam->temperature = ApogeeCamera->TempCCD ;
	} else {
		cam->temperature = 0;
	}
	return;
}

void cam_cooler_on(struct camprop *cam)
{
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;
	if (cam->cooler_implemented==1) {
		ApogeeCamera->CoolerEnable = VARIANT_TRUE;
		ApogeeCamera->CoolerSetPoint = (double)cam->check_temperature; 
	}
}

void cam_cooler_off(struct camprop *cam)
{
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;
	if (cam->cooler_implemented==1) {
		ApogeeCamera->CoolerEnable = VARIANT_FALSE;
	}
}

void cam_cooler_check(struct camprop *cam)
{
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;
	if (cam->cooler_implemented==1) {
		ApogeeCamera->CoolerSetPoint = (double)cam->check_temperature; 
	}
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
  if (binx > cam->MaxBinningH) {
	  binx = cam->MaxBinningH;
  }
  if (biny > cam->MaxBinningV) {
	  biny = cam->MaxBinningV;
  }
  cam->binx = binx;
  cam->biny = biny;
}

int cmdApogeeCoolerInformations(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    struct camprop *cam;
   ICamera2Ptr ApogeeCamera;
	ApogeeCamera = cam_plusplus.ApogeeCamera;
	/////////////////////////////////////////////////
	// Returns information on the Peltier cooler.
	char list[12048],elem[1024];
	int b;
	cam = (struct camprop *) clientData;
	strcpy(list,"");
	if (ApogeeCamera->CoolerControl==VARIANT_TRUE) {
		b=1;
	} else {
		b=0;
	}
	sprintf(elem,"{cooling %d {0 = no cooling 1=cooling}} ",b);
	strcat(list,elem);
	if (ApogeeCamera->CoolerRegulated==VARIANT_TRUE) {
		b=1;
	} else {
		b=0;
	}
	sprintf(elem,"{controllable %d {0= always on 1= controllable}} ",b);
	strcat(list,elem);
	Tcl_SetResult(interp,list,TCL_VOLATILE);
   return TCL_OK;
}

/***********************************************************************/
/*                                                                     */
/* INPUTS                                                              */
/* none                                                                */
/*                                                                     */
/* OUTPUT                                                              */
/* float : check temperature (deg. Celcius)                            */
/* float : CCD temperature (deg. Celcius)                              */
/* float : ambient temperature (deg. Celcius)                          */
/* int   : regulation, 1=on, 0=off                                     */
/* int   : Peltier power, (0-255=0-100%)                               */
/***********************************************************************/
int cmdApogeeInfotemp(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
	/*
	// setpoint = température de consigne
	// ccd = température du ccd
	// ambient = température ambiante
	// reg = régulation ?
	// power = puissance du peltier (0-255=0-100%)
	*/
	Tcl_SetResult(interp, "", TCL_VOLATILE);
	return TCL_OK;
}

#ifdef __cplusplus
}
#endif
