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

#include <windows.h>
#include <exception>
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */
#include <exception>
#include "libcam/util.h"
#include "camera.h"
#include "AscomCamera.h"

#ifdef __cplusplus
extern "C" {
#endif

//#define LOG_NONE    0
//#define LOG_ERROR   1
//#define LOG_WARNING 2
//#define LOG_INFO    3
//#define LOG_DEBUG   4
//int debug_level = LOG_NONE;


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"noname",			/* camera name 70 car maxi*/
     "ascomcam",     /* camera product */
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

void ascomcam_log(int level, const char *fmt, ...);

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

struct _PrivateParams {
   AscomCamera * ascomCamera;
   int debug;
};

#ifdef __cplusplus
}
#endif


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
   // attention : il faut absolument initialiser a zero la zone 
   // memoire correspondant � cam->params->pCam  
   // car sinon l'objet COM camera.CreateInstance croit qu'il existe un objet � supprimer
   // avant d'affecter un nouveu pointer dans la variable. 
   cam->params = (PrivateParams*) calloc(sizeof(PrivateParams),1);
   
   try {
      cam->params->ascomCamera = AscomCamera::createInstance(argv[2]);
      cam->params->ascomCamera->connect(true);
      // je recupere la largeur et la hauteur du CCD en pixels (en pixel sans binning)
      cam->nb_photox  = cam->params->ascomCamera->getCameraXSize();
      cam->nb_photoy  = cam->params->ascomCamera->getCameraYSize();
      // je recupere la taille des pixels (en micron converti en metre)
      cam->celldimx   = cam->params->ascomCamera->getPixelSizeX() * 1e-6;
      cam->celldimy   = cam->params->ascomCamera->getPixelSizeY() * 1e-6;      
      // je recupere la description en limitant la taille � la taille de la variable destinatrice
      strncpy(CAM_INI[cam->index_cam].name, cam->params->ascomCamera->getName(), 255 );      
   } catch( std::exception &e) {
      sprintf(cam->msg, "cam_init error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
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
   ascomcam_log(LOG_DEBUG,"cam_init fin OK");
   return 0;
}

int cam_close(struct camprop * cam)
{
   try {
      ascomcam_log(LOG_DEBUG,"cam_close debut");
      cam->params->ascomCamera->connect(false);
      // je supprime la camera
      cam->params->ascomCamera->deleteInstance();
      if ( cam->params != NULL ) {
         free(cam->params);
         cam->params = NULL;
      }
      ascomcam_log(LOG_DEBUG,"cam_close fin OK");
      return 0;
   } catch(std::exception &e) {
      sprintf(cam->msg, "cam_close  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
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
   
   // je configure la camera.
   // Extrait de la documentation ASCOM :
   // The frame to be captured is defined by four properties, StartX, StartY, which define the upperleft
   // corner of the frame, and NumX and NumY the define the binned size of the frame.
   // If binning is active, value is in binned pixels, start position for the X and Y axis are 0 based.
   // Attention : il faut d'abord mettre a jour l'origine (StartX,StartY) avant la taille de la fenetre
   // car sinon on risque de provoquer une exception (cas de l'ancienne origine hors de la fenetre)

   // subframe start position for the X axis (0 based) in binned pixels
   cam->params->ascomCamera->setStartX(x1) ;
   cam->params->ascomCamera->setStartY(y1) ;
   // subframe width and height in binned pixels
   cam->params->ascomCamera->setNumX(cam->w);
   cam->params->ascomCamera->setNumY(cam->h);
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
   if ( cam->params->ascomCamera == NULL ) {
         sprintf(cam->msg, "cam_start_exp camera not initialized");
         ascomcam_log(LOG_ERROR,cam->msg);
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
         cam->params->ascomCamera->startExposure(exptime, cam->shutterindex); 
         return;
     } catch( std::exception &e) {
         sprintf(cam->msg, "cam_start_exp error=%s",e.what());
         ascomcam_log(LOG_ERROR,cam->msg);
         return;
      }
   }
}

void cam_stop_exp(struct camprop *cam)
{
   ascomcam_log(LOG_DEBUG,"cam_stop_exp debut");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "cam_stop_exp camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg); 
      return;
   }

   try {
      // j'interromps l'acquisition
      cam->params->ascomCamera->stopExposure();
      ascomcam_log(LOG_DEBUG,"cam_stop_exp fin OK");
      return;
   } catch( std::exception &e) {
         sprintf(cam->msg, "cam_stop_exp error=%s",e.what());
         ascomcam_log(LOG_ERROR,cam->msg);
         return;
   }
}

void cam_read_ccd(struct camprop *cam, float *p)
{
   ascomcam_log(LOG_DEBUG,"cam_read_ccd debut");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "cam_read_ccd camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg); 
      return;
   }
   if (p == NULL)
      return;

   if (cam->authorized == 1) {
      try {
         cam->params->ascomCamera->readImage(p);
      } catch( std::exception &e) {
         sprintf(cam->msg, "cam_read_ccd  error=%s",e.what());
         ascomcam_log(LOG_ERROR,cam->msg);
         return;
      }
   }
}

void cam_shutter_on(struct camprop *cam)
{
}

void cam_shutter_off(struct camprop *cam)
{
}

/*
void cam_ampli_on(struct camprop *cam)
{
}

void cam_ampli_off(struct camprop *cam)
{
}
*/

void cam_measure_temperature(struct camprop *cam)
{
   ascomcam_log(LOG_DEBUG,"cam_measure_temperature d�but");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "cam_measure_temperature camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }
   cam->temperature = 0.;
   try {
      cam->temperature = cam->params->ascomCamera->getCCDTemperature();
   } catch( std::exception &e) {
      sprintf(cam->msg, "cam_measure_temperature  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }
   ascomcam_log(LOG_DEBUG,"cam_measure_temperature fin OK.");
}

void cam_cooler_on(struct camprop *cam)
{
   ascomcam_log(LOG_DEBUG,"cam_cooler_on debut");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "cam_cooler_on camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }
   try {
      cam->params->ascomCamera->setCoolerOn(true);
   } catch( std::exception &e) {
      sprintf(cam->msg, "cam_cooler_on  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }
   ascomcam_log(LOG_DEBUG,"cam_cooler_on fin OK");
}

void cam_cooler_off(struct camprop *cam)
{
   ascomcam_log(LOG_DEBUG,"cam_cooler_off debut");
   if ( cam->params->ascomCamera == NULL ) {
      ascomcam_log(LOG_ERROR,"cam_cooler_off camera not initialized");
      sprintf(cam->msg, "cam_cooler_off camera not initialized");
      return;
   }
   try {
      cam->params->ascomCamera->setCoolerOn(false);
    } catch( std::exception &e) {
       sprintf(cam->msg, "cam_cooler_off  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }
   ascomcam_log(LOG_DEBUG,"cam_cooler_off fin OK");
}

void cam_cooler_check(struct camprop *cam)
{
   ascomcam_log(LOG_DEBUG,"cam_cooler_check debut");
   if ( cam->params->ascomCamera == NULL ) {
      ascomcam_log(LOG_ERROR,"cam_cooler_check camera not initialized");
      sprintf(cam->msg, "cam_cooler_check camera not initialized");
      return;
   }
   try {
      cam->params->ascomCamera->setSetCCDTemperature(cam->check_temperature);
   } catch( std::exception &e) {
      sprintf(cam->msg, "cam_cooler_check  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }
   ascomcam_log(LOG_DEBUG,"cam_cooler_check fin OK");
}

void ascomcamGetTemperatureInfo(struct camprop *cam, double *setTemperature, double *ccdTemperature, 
                               double *ambientTemperature, int *regulationEnabled, int *power) 
{
   ascomcam_log(LOG_DEBUG,"cam_get_info_temperature debut");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamGetTemperatureInfo camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }

   try {
      *setTemperature = (float) cam->params->ascomCamera->getSetCCDTemperature();
      *ccdTemperature = (float) cam->params->ascomCamera->getCCDTemperature();
      *ambientTemperature = 0. ;
      if ( cam->params->ascomCamera->getCoolerOn() == true) {
         *regulationEnabled = 1;
      } else {
         *regulationEnabled = 0;
      }
      *power = (int)cam->params->ascomCamera->getCoolerPower();
      ascomcam_log(LOG_DEBUG,"cam_get_info_temperature fin ccdTemperature=%f  setTemperature=%f power=%d", *ccdTemperature, *setTemperature, *power);
   } catch( std::exception &e) {
      sprintf(cam->msg, "ascomcamGetTemperatureInfo  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }

   ascomcam_log(LOG_DEBUG,"cam_get_info_temperature fin OK");
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
   ascomcam_log(LOG_DEBUG,"cam_set_binning debut. binx=%d biny=%d",binx, biny);
   if ( cam->params->ascomCamera == NULL ) {
      ascomcam_log(LOG_ERROR,"cam_set_binning camera not initialized");
      sprintf(cam->msg, "cam_set_binning camera not initialized");
      return;
   }
   try {
      cam->params->ascomCamera->setBinX(binx);
      cam->params->ascomCamera->setBinY(biny);
      ascomcam_log(LOG_DEBUG,"cam_set_binning apres binx=%d biny=%d",binx, biny);
      cam->binx = binx;
      cam->biny = biny;
      ascomcam_log(LOG_DEBUG,"cam_set_binning fin OK");
   } catch( std::exception &e) {
      sprintf(cam->msg, "cam_set_binning  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return;
   }
}

// ---------------------------------------------------------------------------
// mytel_connectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return 0=OK , 1=error
//    
// ---------------------------------------------------------------------------

int cam_connectedSetupDialog(struct camprop *cam )
{
   try {
      cam->params->ascomCamera->setupDialog();
   } catch(  std::exception &e) {
      sprintf(cam->msg, "cam_connectedSetupDialog error=%s",e.what());
      return -1;
   }
   return 0; 
}


// ---------------------------------------------------------------------------
// ascomcamSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
// 
// @return 0=OK 1=error
// ---------------------------------------------------------------------------

int ascomcamSetupDialog(const char * ascomDiverName, char * errorMsg)
{
   try {
      AscomCamera::setupDialog(ascomDiverName);
   } catch(  std::exception &e) {
      sprintf(errorMsg, "cam_connectedSetupDialog error=%s",e.what());
      return -1;
   }
   return 0; 
}

// ---------------------------------------------------------------------------
// ascomcamSetWheelPosition 
//    change la position de la roue a filtre
// @ param  pointeur des donnees de la camera
// @ param  position  Position is a  number between 0 and N-1, where N is the number of filter slots (see Filter.Names). 
// @return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int ascomcamSetWheelPosition(struct camprop *cam, int position)
{
   ascomcam_log(LOG_DEBUG,"ascomcamSetWheelPosition debut. Position=%d",position);
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamSetWheelPosition camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return -1;
   }
   try {
/*
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
*/
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamSetWheelPosition  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return 1;
   }
   ascomcam_log(LOG_DEBUG,"ascomcamSetWheelPosition fin OK");
}

// ---------------------------------------------------------------------------
// ascomcamSetWheelPosition 
//    change la position de la roue a filtre
// return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int ascomcamGetWheelPosition(struct camprop *cam, int *position)
{
   ascomcam_log(LOG_DEBUG,"ascomcamGetWheelPosition debut");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamGetWheelPosition camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return -1;
   }
   try {
/*
      if ( cam->params->pCam->HasFilterWheel) {
         *position = cam->params->pCam->Position;
         return 0;
      } else {
         sprintf(cam->msg,"Camera has not filter wheel");
         return -1;
      }
*/
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamGetWheelPosition  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return 1;
   }
   ascomcam_log(LOG_DEBUG,"ascomcamGetWheelPosition fin OK. Position=%d",*position);
}

// ---------------------------------------------------------------------------
// ascomcamGetWheelNames 
//    retourne les noms des positions de la roue filtre 
// @param **names  : pointeur de pointeu de chaine de caracteres
// @return 
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int ascomcamGetWheelNames(struct camprop *cam, char **names)
{
   ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames debut");      
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamGetWheelNames camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return -1;
   }
   try {
/*
      if ( cam->params->pCam->HasFilterWheel == VARIANT_TRUE) {
         SAFEARRAY *safeValues;
         ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames avant GetNames filter Wheel");      
         safeValues = cam->params->pCam->Names;
         *names = (char*) calloc(safeValues->cbElements, 256);
         //_bstr_t  *bstrValue ;
         BSTR *bstrArray ;
         ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames avant SafeArrayAccessData");      
         SafeArrayAccessData(safeValues, (void**)&bstrArray); 
         ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames nb filters=%ld",safeValues->cbElements);      
         for (unsigned int i=0; i <= safeValues->cbElements ; i++ ) {
            //SafeArrayAccessData(&safeValues[i], (void**)&bstrValue); 
            strcat(*names, "{ ");
            strcat(*names, _com_util::ConvertBSTRToString(bstrArray[i]));
            strcat(*names, " } ");
            //SafeArrayUnaccessData(&safeValues[i]);
         }
         ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames avant SafeArrayUnaccessData");      
         SafeArrayUnaccessData(safeValues);
         ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames fin. filters=%s",*names);
         return 0;

      } else {
         ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames fin. No filters name");
         *names = (char*) NULL;
         return 0;
      }
      ascomcam_log(LOG_DEBUG,"ascomcamGetWheelNames fin OK"); 
*/
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamGetWheelNames  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return 1;
   }
}

int ascomcamGetMaxBin(struct camprop *cam, int * maxBin) 
{
   ascomcam_log(LOG_DEBUG,"ascomcamGetProperty debut");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamGetProperty camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return -1;
   }

   try {
      *maxBin  = cam->params->ascomCamera->getMaxBinX();
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamGetMaxBin  error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return 1;
   }
}

int ascomcamHasShutter(struct camprop *cam, int *hasShutter) 
{
   ascomcam_log(LOG_DEBUG,"ascomcamHasShutter debut");
   if ( cam->params->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamHasShutter camera not initialized");
      ascomcam_log(LOG_ERROR,cam->msg);
      return -1;
   }

   try {
      *hasShutter  = cam->params->ascomCamera->hasShutter();
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamHasShutter error=%s",e.what());
      ascomcam_log(LOG_ERROR,cam->msg);
      return 1;
   }
}


char *ascomcamGetlogdate(char *buf, size_t size)
{
#if defined(OS_WIN)
  #ifdef _MSC_VER
    /* cas special a Microsoft C++ pour avoir les millisecondes */
    struct _timeb timebuffer;
    time_t ltime;
    _ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
  #else
    struct time t1;
    struct date d1;
    getdate(&d1);
    gettime(&t1);
    sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d.%02d : ", d1.da_year,
	    d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec,
	    t1.ti_hund);
  #endif
#elif defined(OS_LIN)
    struct timeb timebuffer;
    time_t ltime;
    ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
#elif defined(OS_MACOS)
    struct timeval t;
    char message[50];
    char s1[27];
    gettimeofday(&t,NULL);
    strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime((const time_t*)(&t.tv_sec)));
    sprintf(s1,"%s.%02d : ",message,(t.tv_usec)/10000);
#else
    sprintf(s1,"[No time functions available]");
#endif

    return buf;
}
void ascomcam_log(int level, const char *fmt, ...)
{
   if (level <= debug_level) {
      FILE *f;
      char buf[100];

      va_list mkr;
      va_start(mkr, fmt);

      ascomcamGetlogdate(buf,100);
      f = fopen("libascomcam.log","at+");
      switch (level) {
      case LOG_ERROR:
         fprintf(f,"%s - %s(%s) <ERROR> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_WARNING:
         fprintf(f,"%s - %s(%s) <WARNING> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_INFO:
         fprintf(f,"%s - %s(%s) <INFO> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_DEBUG:
         fprintf(f,"%s - %s(%s) <DEBUG> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      }
      vfprintf(f,fmt, mkr);
      fprintf(f,"\n");
      va_end(mkr);
      fclose(f);
   }

}
