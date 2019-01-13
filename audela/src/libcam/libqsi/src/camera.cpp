/* camera.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#include <wchar.h>   // pour BSTR
#include <exception>
#include <stdexcept>
#endif

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include "libcam/util.h"
#include "camera.h"

#define _WIN32_DCOM  // CoInitializeEx help : You must include the #define _WIN32_DCOM preprocessor directive at the beginning of your code to be able to use CoInitializeEx.
#import "progid:QSICamera.CCDCamera"

#ifdef __cplusplus
extern "C" {
#endif


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"noname",			/* camera name 70 car maxi*/
     "qsi",       /* camera product */
     "",			   /* ccd name */
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

struct _PrivateParams {
   QSICameraLib::ICameraEx * pCam;                // parametres internes de la camera
   //QSICameraLib::IFilterWheelEx * pFilterWheel;
   int abort;
   int debug;
};

#ifdef __cplusplus
}
#endif

#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */


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

   HRESULT hr;
   cam->params = (PrivateParams*) malloc(sizeof(PrivateParams));
   cam->params->pCam    = NULL;
   
   // aucune trace n'est générée par défaut dans le fichier qsi.log
   debug_level = LOG_ERROR;

   // je recupere les parametres optionnels
   if (argc >= 5) {
      for (int kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-loglevel") == 0) {            
            debug_level = atoi(argv[kk + 1]);
         }
      }
   }

   libcam_log(LOG_DEBUG,"cam_init début. Version du %s", __TIMESTAMP__);
   //Initialize COM.
   //hr = CoInitialize(NULL);
   hr = CoInitializeEx(NULL,COINIT_MULTITHREADED);
   if (FAILED(hr)) { 
      sprintf(cam->msg, "cam_init error CoInitializeEx hr=%X",hr);
      return -1;
   }

   hr = ::CoCreateInstance( __uuidof (QSICameraLib::CCDCamera), NULL, CLSCTX_INPROC_SERVER,
      __uuidof( QSICameraLib::ICameraEx) , (void **) &cam->params->pCam);
   if (FAILED(hr)) { 
      if  ( hr == REGDB_E_CLASSNOTREG ) {
         sprintf(cam->msg, "cam_init error REGDB_E_CLASSNOTREG : QSI Class not registered");
         libcam_log(LOG_ERROR,cam->msg);
         return -1;
      } else {
         sprintf(cam->msg, "cam_init error CoCreateInstance hr=%X",hr);
         libcam_log(LOG_ERROR,cam->msg);
         return -1;
      }
   }

   try
   {
      libcam_log(LOG_DEBUG,"cam_init avant connexion");
      cam->params->pCam->Connected = true;
      cam->params->abort = 0; 
      libcam_log(LOG_DEBUG,"cam_init avant GetCameraXSize");
      // je recupere la largeur et la hauteur du CCD en pixels
      cam->nb_photox  = cam->params->pCam->CameraXSize;
      cam->nb_photoy  = cam->params->pCam->CameraYSize;
      // je recupere la taille des pixels (en micron converti en metre)
      cam->celldimx   = cam->params->pCam->PixelSizeX * 1e-6;
      cam->celldimy   = cam->params->pCam->PixelSizeY * 1e-6;
      // je recupere la description
      strncpy(CAM_INI[cam->index_cam].name, 
         _com_util::ConvertBSTRToString(cam->params->pCam->Description),
         sizeof(CAM_INI[cam->index_cam].name) -1 );

   } catch (_com_error &e) {
      // exception des objets COM
      sprintf(cam->msg, "cam_init error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);      
      return -1;
   } catch (std::exception &e) {
      // exceptions standards du C
      sprintf(cam->msg, "cam_init connection error=%s",e.what());
      libcam_log(LOG_ERROR,cam->msg);      
      return -1;
   } catch (...) {
      // autres exceptions
      sprintf(cam->msg, "cam_init error Connected exception");
      libcam_log(LOG_ERROR,cam->msg);      
      return -1;
   }
   cam->x1 = 0;
   cam->y1 = 0;
   cam->x2 = cam->nb_photox - 1;
   cam->y2 = cam->nb_photoy - 1;
   cam->binx = 1;
   cam->biny = 1;

   cam_update_window(cam);	// met a jour x1,y1,x2,y2,h,w dans cam
   strcpy(cam->date_obs, "2000-01-01T12:00:00");
   strcpy(cam->date_end, cam->date_obs);
   cam->authorized = 1;
   libcam_log(LOG_DEBUG,"cam_init fin OK");
   return 0;
}

int cam_close(struct camprop * cam)
{
   try {
      libcam_log(LOG_DEBUG,"cam_close debut");
      // je deconnecte la camera
      cam->params->pCam->Connected = false;
      // je supprime la camera
      cam->params->pCam->Release();
      cam->params->pCam = NULL;
      CoUninitialize();   // devrait eviter de demarrer dans le thread principal dans libcam.c .. a voir
      if ( cam->params != NULL ) {
         free(cam->params);
         cam->params = NULL;
      }
      libcam_log(LOG_DEBUG,"cam_close fin OK");
      return 0;
   } catch (...) {
      libcam_log(LOG_ERROR,"cam_close error exception");
      sprintf(cam->msg, "cam_close error exception");
      return -1;
   }
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
   cam->w = (cam->x2 - cam->x1 +1) / cam->binx;
   cam->h = (cam->y2 - cam->y1 +1) / cam->biny;
   x1 = cam->x1  / cam->binx;
   x2 = x1 + cam->w -1;
   y1 = cam->y1 / cam->biny;
   y2 = y1 + cam->h -1;

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

   // je configure la camera.
   // ATTENTION : The frame to be captured is defined by four properties, StartX, StartY, which define the upperleft
   // corner of the frame, and NumX and NumY the define the binned size of the frame.
   // If binning is active, value is in binned pixels, start position for the X and Y axis are 0 based.
   //
   // Restrictions on binning are:
   // The properties BinX and BinY specify the number of bits per bin for each axis. 
   // If CanAsymmetricBin is False, BinX must equal BinY.
   // MaxXBin and MaxYBin specify the maximum number of bits per bin allowed by the camera for each axis. 
   // Therefore, BinX <=MaxXBin and BinY <= MaxYBin.
   // The total number of bits in a image frame must not exceed the CCD dimension. Therefore, 
   //    (StartX + NumX) * BinX <= CameraXSize and (StartY + NumY) * BinY <= CameraYSize
   // Attention , il faut d'abord mettre a jour l'origine (StartX,StartY) avant la taille de la nouvelle fenetre
   // car sinon on risque de provoquer une exception si l'ancienne origine hors de la nouvelle fenetre.

   cam->params->pCam->StartX = x1 ;
   cam->params->pCam->StartY = y1 ;
   cam->params->pCam->NumX = cam->w;
   cam->params->pCam->NumY = cam->h;
}


void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
   HRESULT hr;

   if ( cam->params->pCam == NULL ) {
         libcam_log(LOG_ERROR,"cam_start_exp camera not initialized");
         sprintf(cam->msg, "cam_start_exp camera not initialized");
         return;
   }

   if (cam->authorized == 1) {
      try {
         float exptime ;
         if ( cam->exptime <= 0.06f ) {
            exptime = 0.06f;
         } else {
            exptime = cam->exptime ;
         }

         // je lance l'acquisition
         if (cam->shutterindex == 0) {
            // acquisition avec obturateur ferme
            libcam_log(LOG_DEBUG,"cam_start_exp apres StartExposure shutter=closed exptime=%f",cam->exptime);
            hr = cam->params->pCam->StartExposure(exptime, VARIANT_FALSE);
         } else {
            // acquisition avec obturateur ouvert
            libcam_log(LOG_DEBUG,"cam_start_exp apres StartExposure shutter=synchro exptime=%f",cam->exptime);
            hr = cam->params->pCam->StartExposure(exptime, VARIANT_TRUE);
            libcam_log(LOG_DEBUG,"cam_start_exp apres StartExposure");
         }
         if (FAILED(hr)) {  
            sprintf(cam->msg, "cam_start_exp error StartExposure hr=%X",hr);
            libcam_log(LOG_ERROR,cam->msg);
            return;
         }
         cam->params->abort = 0; 

         return;
      } catch (_com_error &e) {
         sprintf(cam->msg, "cam_start_exp error=%s",_com_util::ConvertBSTRToString(e.Description()));
         libcam_log(LOG_ERROR,cam->msg);
         return;
      } catch (...) {
         sprintf(cam->msg, "cam_start_exp error StartExposure exception");
         return;
      }
   }
}

void cam_stop_exp(struct camprop *cam)
{
   HRESULT hr;

   libcam_log(LOG_DEBUG,"cam_stop_exp debut");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"cam_stop_exp camera not initialized");
      sprintf(cam->msg, "cam_stop_exp camera not initialized");
      return;
   }

   try {
      // j'interromps l'acquisition
      hr = cam->params->pCam->AbortExposure();
      if (FAILED(hr)) { 
         sprintf(cam->msg, "cam_stop_exp error StopExposure hr=%X",hr);
         return;
      }
      cam->params->abort = 1;
      return;
   } catch (_com_error &e) {
      sprintf(cam->msg, "cam_stop_exp error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }
}

void cam_read_ccd(struct camprop *cam, float *p)
{
   libcam_log(LOG_DEBUG,"cam_read_ccd debut");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"cam_read_ccd camera not initialized");
      sprintf(cam->msg, "cam_read_ccd camera not initialized");
      return;
   }
   if (p == NULL)
      return;

   if (cam->params->abort ==1 ) {
      cam->params->abort = 0;
      sprintf(cam->msg, "acq stopped by usr");
      return;
   }

   if (cam->authorized == 1 ) {
      try {
         SAFEARRAY *safeValues;

         long * lValues;
         // j'attends que l'image soit prete
         while (cam->params->pCam->ImageReady == VARIANT_FALSE){
            Sleep(100);
         }
         
         // je reccupere le pointeur de l'image
         _variant_t variantValues = cam->params->pCam->ImageArray;
         safeValues = variantValues.parray;
         SafeArrayAccessData(safeValues, (void**)&lValues);      
         
         // je copie l'image dans le buffer
         for( int y=0; y <cam->h; y++) {
            for( int x=0; x <cam->w; x++) {
                p[x+y*cam->w] = (float) lValues[x+y*cam->w];
            }
         }
         SafeArrayUnaccessData(safeValues);
         libcam_log(LOG_DEBUG,"cam_read_ccd OK");      
      } catch (_com_error &e) {
         sprintf(cam->msg, "cam_read_ccd error=%s",_com_util::ConvertBSTRToString(e.Description()));
         libcam_log(LOG_ERROR,cam->msg);
         return;
      }
   }
   libcam_log(LOG_DEBUG,"cam_read_ccd fin OK");

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
   libcam_log(LOG_DEBUG,"cam_measure_temperature début");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"cam_measure_temperature camera not initialized");
      sprintf(cam->msg, "cam_measure_temperature camera not initialized");
      return;
   }
   cam->temperature = 0.;
   try {
      cam->temperature = cam->params->pCam->CCDTemperature;
   } catch (_com_error &e) {
      sprintf(cam->msg, "cam_measure_temperature error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }
   libcam_log(LOG_DEBUG,"cam_measure_temperature fin OK.");
}

void cam_cooler_on(struct camprop *cam)
{
   libcam_log(LOG_DEBUG,"cam_cooler_on debut");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"cam_cooler_on camera not initialized");
      sprintf(cam->msg, "cam_cooler_on camera not initialized");
      return;
   }
   try {
      cam->params->pCam->CoolerOn = VARIANT_TRUE;
      libcam_log(LOG_DEBUG,"cam_cooler_on fin OK");
   } catch (_com_error &e) {
      sprintf(cam->msg, "cam_cooler_on error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }

}

void cam_cooler_off(struct camprop *cam)
{
   libcam_log(LOG_DEBUG,"cam_cooler_off debut");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"cam_cooler_off camera not initialized");
      sprintf(cam->msg, "cam_cooler_off camera not initialized");
      return;
   }
   try {
      cam->params->pCam->CoolerOn = VARIANT_FALSE;
   } catch (_com_error &e) {
      sprintf(cam->msg, "cam_cooler_off error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }
   libcam_log(LOG_DEBUG,"cam_cooler_off fin OK");
}

void cam_cooler_check(struct camprop *cam)
{
   libcam_log(LOG_DEBUG,"cam_cooler_check debut");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"cam_cooler_check camera not initialized");
      sprintf(cam->msg, "cam_cooler_check camera not initialized");
      return;
   }
   try {
      cam->params->pCam->SetCCDTemperature = cam->check_temperature;
   } catch (_com_error &e) {
      sprintf(cam->msg, "cam_cooler_check error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }
   libcam_log(LOG_DEBUG,"cam_cooler_check fin OK");
}

void qsiGetTemperatureInfo(struct camprop *cam, double *setTemperature, double *ccdTemperature, 
                               double *ambientTemperature, int *regulationEnabled, int *power) 
{
   libcam_log(LOG_DEBUG,"cam_get_info_temperature debut");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"qsiGetTemperatureInfo camera not initialized");
      sprintf(cam->msg, "qsiGetTemperatureInfo camera not initialized");
      return;
   }

   try {
      *setTemperature = (float) cam->params->pCam->SetCCDTemperature;
      *ccdTemperature = (float) cam->params->pCam->CCDTemperature;
      *ambientTemperature = 0. ;
      if ( cam->params->pCam->CoolerOn == VARIANT_TRUE) {
         *regulationEnabled = 1;
      } else {
         *regulationEnabled = 0;
      }
      *power = (int)(cam->params->pCam->CoolerPower);
      libcam_log(LOG_DEBUG,"cam_get_info_temperature fin ccdTemperature=%f  setTemperature=%f power=%d", *ccdTemperature, *setTemperature, *power);
   } catch (_com_error &e) {
      sprintf(cam->msg, "qsiGetTemperatureInfo error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }

   libcam_log(LOG_DEBUG,"cam_get_info_temperature fin OK");
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
   int previousBinX;
   int previousBinY;
   libcam_log(LOG_DEBUG,"cam_set_binning debut. binx=%d biny=%d",binx, biny);
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"cam_set_binning camera not initialized");
      sprintf(cam->msg, "cam_set_binning camera not initialized");
      return;
   }
   try {
      previousBinX = cam->binx;
      previousBinY = cam->biny;

      if ( binx > cam->params->pCam->MaxBinX ) {
         libcam_log(LOG_ERROR,"Error: binning X is greater than %d",cam->params->pCam->MaxBinX);
         sprintf(cam->msg, "Error: binning X is greater than %d",cam->params->pCam->MaxBinX);
         return; 
      }

      if ( biny > cam->params->pCam->MaxBinY ) {
         libcam_log(LOG_ERROR,"Error: binning Y is greater than %d",cam->params->pCam->MaxBinY);
         sprintf(cam->msg, "Error: binning Y is greater than %d",cam->params->pCam->MaxBinY);
         return; 
      }
      cam->binx = binx;
      cam->biny = biny;
      cam->w = (cam->x2 - cam->x1 +1) / cam->binx;
      cam->h = (cam->y2 - cam->y1 +1) / cam->biny;
      cam->params->pCam->NumX = cam->w;
      cam->params->pCam->NumY = cam->h;
      cam->params->pCam->BinX = binx;
      cam->params->pCam->BinY = biny;
      libcam_log(LOG_DEBUG,"cam_set_binning apres binx=%d biny=%d",binx, biny);
      libcam_log(LOG_DEBUG,"cam_set_binning fin OK");
   } catch (_com_error &e) {
      sprintf(cam->msg, "cam_set_binning error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   } 
}



// ---------------------------------------------------------------------------
// qsiSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------

void qsiSetupDialog(struct camprop *cam)
{
   libcam_log(LOG_DEBUG,"qsiSetupDialog avant SetupDialog");
   if ( cam->params->pCam == NULL ) {
      sprintf(cam->msg, "qsiSetupDialog camera not initialized");
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }
   try {
      cam->params->pCam->Connected = false;
      cam->params->pCam->SetupDialog();
      cam->params->pCam->Connected = true;
   } catch (_com_error &e) {
      sprintf(cam->msg, "qsiSetupDialog error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return;
   }
}

// ---------------------------------------------------------------------------
// qsiSetWheelPosition 
//    change la position de la roue a filtre
// @ param  pointeur des donnees de la camera
// @ param  position  Position is a  number between 0 and N-1, where N is the number of filter slots (see Filter.Names). 
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiSetWheelPosition(struct camprop *cam, int position)
{
   libcam_log(LOG_DEBUG,"qsiSetWheelPosition debut. Position=%d",position);
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"qsiSetWheelPosition camera not initialized");
      sprintf(cam->msg, "qsiSetWheelPosition camera not initialized");
      return -1;
   }
   try {
      if ( cam->params->pCam->HasFilterWheel) {
         // Position : Starts filter wheel rotation immediately when written. 
         // Reading the property gives current slot number (if wheel stationary) 
         // or -1 if wheel is moving.
         cam->params->pCam->Position = position;
         return 0;
      } else {
         sprintf(cam->msg,"Camera has not filter wheel");
         return -1;
      }
      return 0;
   } catch (_com_error &e) {
      sprintf(cam->msg, "qsiSetWheelPosition error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return -1;
   }
}

// ---------------------------------------------------------------------------
// qsiSetWheelPosition 
//    change la position de la roue a filtre
// return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelPosition(struct camprop *cam, int *position)
{
   libcam_log(LOG_DEBUG,"qsiGetWheelPosition debut");
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"qsiGetWheelPosition camera not initialized");
      sprintf(cam->msg, "qsiGetWheelPosition camera not initialized");
      return -1;
   }
   try {
      VARIANT_BOOL filter = cam->params->pCam->HasFilterWheel;
      if ( filter) {
         *position = cam->params->pCam->Position;
         return 0;
      } else {
         sprintf(cam->msg,"Camera has not filter wheel");
         return -1;
      }
      return 0;
   } catch (_com_error &e) {
      sprintf(cam->msg, "qsiGetWheelPosition error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return -1;
   }
}

// ---------------------------------------------------------------------------
// qsiGetWheelNames 
//    retourne les noms des positions de la roue filtre 
// @param **names  : pointeur de pointeu de chaine de caracteres
// @return 
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetWheelNames(struct camprop *cam, char **names)
{
   libcam_log(LOG_DEBUG,"qsiGetWheelNames debut");      
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"qsiGetWheelNames camera not initialized");
      sprintf(cam->msg, "qsiGetWheelNames camera not initialized");
      return -1;
   }
   try {
      VARIANT_BOOL filter = cam->params->pCam->HasFilterWheel;
      if ( filter ) {
         SAFEARRAY *safeValues;
         libcam_log(LOG_DEBUG,"qsiGetWheelNames avant GetNames filter Wheel");      
         safeValues = cam->params->pCam->Names;
         *names = (char*) calloc(safeValues->cbElements, 256);
         //_bstr_t  *bstrValue ;
         BSTR *bstrArray ;
         libcam_log(LOG_DEBUG,"qsiGetWheelNames avant SafeArrayAccessData");      
         SafeArrayAccessData(safeValues, (void**)&bstrArray); 
         libcam_log(LOG_DEBUG,"qsiGetWheelNames nb filters=%ld",safeValues->cbElements);      
         for (unsigned int i=0; i <= safeValues->cbElements ; i++ ) {
            //SafeArrayAccessData(&safeValues[i], (void**)&bstrValue); 
            strcat(*names, "{ ");
            strcat(*names, _com_util::ConvertBSTRToString(bstrArray[i]));
            strcat(*names, " } ");
            //SafeArrayUnaccessData(&safeValues[i]);
         }
         libcam_log(LOG_DEBUG,"qsiGetWheelNames avant SafeArrayUnaccessData");      
         SafeArrayUnaccessData(safeValues);
         libcam_log(LOG_DEBUG,"qsiGetWheelNames fin. filters=%s",*names);
         return 0;
      } else {
         libcam_log(LOG_DEBUG,"qsiGetWheelNames fin. No filters name");
         *names = (char*) NULL;
         return 0;
      }
      libcam_log(LOG_DEBUG,"qsiGetWheelNames fin OK"); 
      return 0;
   } catch (_com_error &e) {
      sprintf(cam->msg, "qsiGetWheelNames error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return -1;
   }
}

// ---------------------------------------------------------------------------
// qsiGetWheelNames 
//    retourne les noms des positions de la roue filtre 
// @param **names  : pointeur de pointeu de chaine de caracteres
// @return 
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int qsiGetProperty(struct camprop *cam, const char *propertyName, char *propertyValue)
{
   if ( cam->params->pCam == NULL ) {
      libcam_log(LOG_ERROR,"qsiGetWheelNames camera not initialized");
      sprintf(cam->msg, "qsiGetWheelNames camera not initialized");
      return -1;
   }
   try {

      if ( strcmp(propertyName,"MaxBinX") == 0 ) {
         sprintf(propertyValue,"%d",cam->params->pCam->MaxBinX);
      } else if ( strcmp(propertyName,"MaxBinY") == 0 ) {
         sprintf(propertyValue,"%d",cam->params->pCam->MaxBinY);
      }
      return 0;
   } catch (_com_error &e) {
      sprintf(cam->msg, "qsiGetProperty error=%s",_com_util::ConvertBSTRToString(e.Description()));
      libcam_log(LOG_ERROR,cam->msg);
      return -1;
   }
}




