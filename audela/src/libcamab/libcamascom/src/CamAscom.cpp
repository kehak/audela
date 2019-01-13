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
#include <stdio.h>      // sprintf
#include <time.h>       // time, ftime, strftime, localtime
#include <sys/timeb.h>  // ftime, struct timebuffer
#include <exception>
#include <string>

#include <libcamab/libcam.h>
#include <libcamab/libcamcommon.h>
using namespace ::abcommon;

#include "CamAscom.h"
#include "AscomCamera.h"

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CLibcamCommon::CAM_INI[] = {
    {"noname",			/* camera name 70 car maxi*/
     "noproduct",            /* camera product */
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
     false,		   /* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};


/**
 * Commandes propres a chaque camera
 */ 

//struct SpecificCommand specificCommandList[] = {
//    /* === Specific commands for that camera === */
//    //{"infotemp", (Spec_CmdProc *) cmdAscomcamInfotemp},
//    {"property", (Spec_CmdProc *) cmdAscomcamProperty},
//    {"setup",    (Spec_CmdProc *) cmdAscomcamConnectedSetupDialog},
//    //{"wheel",    (Spec_CmdProc *) cmdAscomcamWheel},
//    /* === Last function terminated by NULL pointers === */
//    {NULL, NULL}
//};

struct _PrivateParams {
   AscomCamera * ascomCamera;
   int debug;
};



/// @brief  create instance
//
libcam::ILibcam* libcam::createCameraInstance(int argc, const char *argv[]) {
   return CLibcamCommon::createCameraInstance(new CCamAscom(), argc, argv);
};

/// @brief  init instance
//
void CCamAscom::cam_init(int argc, const char **argv) 
{  
   // je recupere les parametres optionnels
   //if (argc >= 5) {
   //   for (int kk = 3; kk < argc - 1; kk++) {
   //      if (strcmp(argv[kk], "-lxxxxx") == 0) {            
   //         xxxx = atoi(argv[kk + 1]);
   //      }
   //   }
   //}
   
   try {
      this->ascomCamera = AscomCamera::createInstance(argv[0]);
      this->ascomCamera->connect(true);
      // je recupere la largeur et la hauteur du CCD en pixels (en pixel sans binning)
      this->nb_photox  = this->ascomCamera->getCameraXSize();
      this->nb_photoy  = this->ascomCamera->getCameraYSize();
      // je recupere la taille des pixels (en micron converti en metre)
      this->celldimx   = this->ascomCamera->getPixelSizeX() * 1e-6;
      this->celldimy   = this->ascomCamera->getPixelSizeY() * 1e-6;      
      // je recupere la description en limitant la taille à la taille de la variable destinatrice
      strncpy(CAM_INI[this->index_cam].name, this->ascomCamera->getDescription(),
            sizeof(CAM_INI[this->index_cam].name) -1 );      

      this->x1 = 0;
      this->y1 = 0;
      this->x2 = this->nb_photox - 1;
      this->y2 = this->nb_photoy - 1;
      this->binx = 1;
      this->biny = 1;
      this->m_binMaxX = this->ascomCamera->getMaxBinX(); 
      this->m_binMaxY = this->ascomCamera->getMaxBinY(); 

      this->capabilities.expTimeCommand = true;
      this->capabilities.expTimeList = false;
      this->capabilities.shutter = true;
      this->capabilities.videoMode = false;

   } catch( std::exception &e) {
      m_logger.logError("cam_init error=%s", e.what());
      throw CError(CError::ErrorGeneric, "cam_init error=%s", e.what());
   } 

   cam_update_window();	// met a jour x1,y1,x2,y2,h,w dans cam
   strcpy(this->date_obs, "2000-01-01T12:00:00");
   strcpy(this->date_end, this->date_obs);
   this->authorized = 1;
   m_logger.logDebug("cam_init fin OK");
}

void CCamAscom::cam_close()
{
   m_logger.logDebug("cam_close debut");
   // je verifie si la camera n'est pas deja arretee
   this->ascomCamera->connect(false);
   // je supprime la camera
   this->ascomCamera->deleteInstance();
   m_logger.logDebug("cam_close fin OK");
}

void CCamAscom::cam_update_window()
{
   int maxx, maxy;
   maxx = this->nb_photox;
   maxy = this->nb_photoy;
   int x1, x2, y1, y2; 

   if (this->x1 > this->x2) {
      int x0 = this->x2;
      this->x2 = this->x1;
      this->x1 = x0;
   }
   if (this->x1 < 0) {
      this->x1 = 0;
   }
   if (this->x2 > maxx - 1) {
      this->x2 = maxx - 1;
   }

   if (this->y1 > this->y2) {
      int y0 = this->y2;
      this->y2 = this->y1;
      this->y1 = y0;
   }
   if (this->y1 < 0) {
      this->y1 = 0;
   }

   if (this->y2 > maxy - 1) {
      this->y2 = maxy - 1;
   }

   // je prend en compte le binning 
   this->w = (this->x2 - this->x1 +1) / this->binx ;
   this->h = (this->y2 - this->y1 +1) / this->biny ;
   x1 = this->x1  / this->binx;
   y1 = this->y1 / this->biny;
   x2 = x1 + this->w -1;
   y2 = y1 + this->h -1;

   // j'applique le miroir aux coordonnes de la sous fenetre
   if ( this->mirrorv == 1 ) {
      // j'applique un miroir vertical en inversant les ordonnees de la fenetre
      x1 = (maxx / this->binx ) - x2 -1;
   }
   if ( this->mirrorh == 1 ) {
      // j'applique un miroir horizontal en inversant les abcisses de la fenetre
      // 0---y1-----y2---------------------(w-1)
      // 0---------------(w-y2)---(w-y1)---(w-1)  
      y1 = (maxy / this->biny ) - y2 -1;
   }
   
   // je configure la camera.
   // Extrait de la documentation ASCOM :
   // The frame to be captured is defined by four properties, StartX, StartY, which define the upperleft
   // corner of the frame, and NumX and NumY the define the binned size of the frame.
   // If binning is active, value is in binned pixels, start position for the X and Y axis are 0 based.
   // Attention : il faut d'abord mettre a jour l'origine (StartX,StartY) avant la taille de la fenetre
   // car sinon on risque de provoquer une exception (cas de l'ancienne origine hors de la fenetre)

   // subframe start position for the X axis (0 based) in binned pixels
   this->ascomCamera->setStartX(x1) ;
   this->ascomCamera->setStartY(y1) ;
   // subframe width and height in binned pixels
   this->ascomCamera->setNumX(this->w);
   this->ascomCamera->setNumY(this->h);
}

void CCamAscom::cam_exposure_abort() {
   m_logger.logDebug("cam_exposure_abort TODO ");
}

void CCamAscom::cam_exposure_start()
{
   if ( this->ascomCamera == NULL ) {
         sprintf(this->msg, "cam_start_exp camera not initialized");
         m_logger.logError(this->msg);
         return;
   }

   if (this->authorized == 1) {
      try {
         float exptime ;
         if ( this->exptime <= 0.06f ) {
            exptime = 0.06f;
         } else {
            exptime = this->exptime ;
         }

         // je lance l'acquisition
         this->ascomCamera->startExposure(exptime, this->shutterindex); 
         return;
     } catch( std::exception &e) {
         sprintf(this->msg, "cam_start_exp error=%s",e.what());
         m_logger.logError(this->msg);
         return;
      }
   }
}

void CCamAscom::cam_exposure_stop()
{
   m_logger.logDebug("cam_stop_exp debut");
   if ( this->ascomCamera == NULL ) {
      sprintf(this->msg, "cam_stop_exp camera not initialized");
      m_logger.logError(this->msg); 
      return;
   }

   try {
      // j'interromps l'acquisition
      this->ascomCamera->stopExposure();
      m_logger.logDebug("cam_stop_exp fin OK");
      return;
   } catch( std::exception &e) {
         sprintf(this->msg, "cam_stop_exp error=%s",e.what());
         m_logger.logError(this->msg);
         return;
   }
}

void CCamAscom::cam_exposure_readCCD(float *p)
{
   m_logger.logDebug("cam_read_ccd debut");
   if ( this->ascomCamera == NULL ) {
      sprintf(this->msg, "cam_read_ccd camera not initialized");
      m_logger.logError(this->msg); 
      return;
   }
   if (p == NULL)
      return;

   if (this->authorized == 1) {
      try {
         this->ascomCamera->readImage(p);
      } catch( std::exception &e) {
         sprintf(this->msg, "cam_read_ccd  error=%s",e.what());
         m_logger.logError(this->msg);
         return;
      }
   }
}

//void CCamAscom::cam_measure_temperature()
//{
//   m_logger.logDebug("cam_measure_temperature début");
//   if ( this->ascomCamera == NULL ) {
//      sprintf(this->msg, "cam_measure_temperature camera not initialized");
//      m_logger.logError(this->msg);
//      return;
//   }
//   this->temperature = 0.;
//   try {
//      this->temperature = this->ascomCamera->getCCDTemperature();
//   } catch( std::exception &e) {
//      sprintf(this->msg, "cam_measure_temperature  error=%s",e.what());
//      m_logger.logError(this->msg);
//      return;
//   }
//   m_logger.logDebug("cam_measure_temperature fin OK.");
//}

double CCamAscom::cam_cooler_checkTemperature_get()
{
   m_logger.logDebug("cam_cooler_checkTemperature_get debut");
   if ( this->ascomCamera == NULL ) {
      throw CError(CError::ErrorGeneric,"cam_cooler_checkTemperature_get camera not initialized");
   }
   try {
      return this->ascomCamera->getCCDTemperature();
   } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric,"cam_cooler_check  error=%s",e.what());
   }
   m_logger.logDebug("cam_cooler_checkTemperature_get fin OK");
}

void CCamAscom::cam_cooler_checkTemperature_set(double temperature)
{
   m_logger.logDebug("cam_cooler_checkTemperature_set debut");
   if ( this->ascomCamera == NULL ) {
      m_logger.logError("cam_cooler_check cam_cooler_checkTemperature_set not initialized");
      sprintf(this->msg, "cam_cooler_checkTemperature_set camera not initialized");
      return;
   }
   try {
      this->ascomCamera->setSetCCDTemperature(temperature);
   } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric,"cam_cooler_checkTemperature_set  error=%s",e.what());
   }
   m_logger.logDebug("cam_cooler_checkTemperature_set fin OK");
}

double CCamAscom::cam_cooler_ccdTemperature_get() 
{
   m_logger.logDebug("cam_cooler_ccdTemperature_get debut");
   if ( this->ascomCamera == NULL ) {
      throw CError(CError::ErrorGeneric,"cam_cooler_ccdTemperature_get camera not initialized");
   }

   try {
      return this->ascomCamera->getCCDTemperature();
   } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric,"cam_cooler_ccdTemperature_get  error=%s",e.what());
   }

   m_logger.logDebug("cam_cooler_ccdTemperature_get fin OK");
}

bool CCamAscom::cam_cooler_get()
{
   try {
      return ascomCamera->getCoolerOn();
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "cam_cooler_get  error=%s", e.what());
   }
}

void CCamAscom::cam_cooler_set(bool on)
{
   try {
      this->ascomCamera->setCoolerOn(on);
   } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric, "cam_cooler_set  error=%s", e.what());
   }
}

void CCamAscom::ascomcamGetTemperatureInfo(double *setTemperature, double *ccdTemperature, 
                               double *ambientTemperature, int *regulationEnabled, int *power) 
{
   m_logger.logDebug("cam_get_info_temperature debut");
   if ( this->ascomCamera == NULL ) {
      sprintf(this->msg, "ascomcamGetTemperatureInfo camera not initialized");
      m_logger.logError(this->msg);
      return;
   }

   try {
      *setTemperature = (float) this->ascomCamera->getSetCCDTemperature();
      *ccdTemperature = (float) this->ascomCamera->getCCDTemperature();
      *ambientTemperature = 0. ;
      if ( this->ascomCamera->getCoolerOn() == true) {
         *regulationEnabled = 1;
      } else {
         *regulationEnabled = 0;
      }
      *power = (int)this->ascomCamera->getCoolerPower();
      m_logger.logDebug("cam_get_info_temperature fin ccdTemperature=%f  setTemperature=%f power=%d", *ccdTemperature, *setTemperature, *power);
   } catch( std::exception &e) {
      sprintf(this->msg, "ascomcamGetTemperatureInfo  error=%s",e.what());
      m_logger.logError(this->msg);
      return;
   }

   m_logger.logDebug("cam_get_info_temperature fin OK");
}

void CCamAscom::cam_binning_set(int binx, int biny)
{
   m_logger.logDebug("cam_set_binning debut. binx=%d biny=%d",binx, biny);
   if ( this->ascomCamera == NULL ) {
      m_logger.logError("cam_set_binning camera not initialized");
      sprintf(this->msg, "cam_set_binning camera not initialized");
      return;
   }
   try {
      this->ascomCamera->setBinX(binx);
      this->ascomCamera->setBinY(biny);
      m_logger.logDebug("cam_set_binning apres binx=%d biny=%d",binx, biny);
      this->binx = binx;
      this->biny = biny;
      cam_update_window();
      m_logger.logDebug("cam_set_binning fin OK");
   } catch( std::exception &e) {
      sprintf(this->msg, "cam_set_binning  error=%s",e.what());
      m_logger.logError(this->msg);
      return;
   }
}

// ---------------------------------------------------------------------------
// mytel_connectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return 0=OK , 1=error
//    
// ---------------------------------------------------------------------------

int CCamAscom::cam_connectedSetupDialog()
{
   try {
      this->ascomCamera->setupDialog();
   } catch(  std::exception &e) {
      sprintf(this->msg, "cam_connectedSetupDialog error=%s",e.what());
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

int CCamAscom::ascomcamSetupDialog(const char * ascomDiverName, char * errorMsg)
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

int CCamAscom::ascomcamSetWheelPosition(CCamAscom *cam, int position)
{
   m_logger.logDebug("ascomcamSetWheelPosition debut. Position=%d",position);
   if ( cam->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamSetWheelPosition camera not initialized");
      m_logger.logError(cam->msg);
      return -1;
   }
   try {
/*
      if ( cam->pCam->HasFilterWheel) {
         // Position : Starts filter wheel rotation immediately when written. 
         // Reading the property gives current slot number (if wheel stationary) 
         // or -1 if wheel is moving.
         cam->pCam->Position = position;
         return 0;
      } else {
         sprintf(cam->msg,"Camera has not filter wheel");
         return -1;
      }
*/
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamSetWheelPosition  error=%s",e.what());
      m_logger.logError(cam->msg);
      return 1;
   }
   m_logger.logDebug("ascomcamSetWheelPosition fin OK");
}

// ---------------------------------------------------------------------------
// ascomcamSetWheelPosition 
//    change la position de la roue a filtre
// return
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int CCamAscom::ascomcamGetWheelPosition(CCamAscom *cam, int *position)
{
   m_logger.logDebug("ascomcamGetWheelPosition debut");
   if ( cam->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamGetWheelPosition camera not initialized");
      m_logger.logError(cam->msg);
      return -1;
   }
   try {
/*
      if ( cam->pCam->HasFilterWheel) {
         *position = cam->pCam->Position;
         return 0;
      } else {
         sprintf(cam->msg,"Camera has not filter wheel");
         return -1;
      }
*/
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamGetWheelPosition  error=%s",e.what());
      m_logger.logError(cam->msg);
      return 1;
   }
   m_logger.logDebug("ascomcamGetWheelPosition fin OK. Position=%d",*position);
}

// ---------------------------------------------------------------------------
// ascomcamGetWheelNames 
//    retourne les noms des positions de la roue filtre 
// @param **names  : pointeur de pointeu de chaine de caracteres
// @return 
//    0  si pas d'erreur
//    -1 si erreur , le libelle de l'erreur est dans cam->msg
// ---------------------------------------------------------------------------

int CCamAscom::ascomcamGetWheelNames(CCamAscom *cam, char **names)
{
   m_logger.logDebug("ascomcamGetWheelNames debut");      
   if ( cam->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamGetWheelNames camera not initialized");
      m_logger.logError(cam->msg);
      return -1;
   }
   try {
/*
      if ( cam->pCam->HasFilterWheel == VARIANT_TRUE) {
         SAFEARRAY *safeValues;
         m_logger.logDebug("ascomcamGetWheelNames avant GetNames filter Wheel");      
         safeValues = cam->pCam->Names;
         *names = (char*) calloc(safeValues->cbElements, 256);
         //_bstr_t  *bstrValue ;
         BSTR *bstrArray ;
         m_logger.logDebug("ascomcamGetWheelNames avant SafeArrayAccessData");      
         SafeArrayAccessData(safeValues, (void**)&bstrArray); 
         m_logger.logDebug("ascomcamGetWheelNames nb filters=%ld",safeValues->cbElements);      
         for (unsigned int i=0; i <= safeValues->cbElements ; i++ ) {
            //SafeArrayAccessData(&safeValues[i], (void**)&bstrValue); 
            strcat(*names, "{ ");
            strcat(*names, _com_util::ConvertBSTRToString(bstrArray[i]));
            strcat(*names, " } ");
            //SafeArrayUnaccessData(&safeValues[i]);
         }
         m_logger.logDebug("ascomcamGetWheelNames avant SafeArrayUnaccessData");      
         SafeArrayUnaccessData(safeValues);
         m_logger.logDebug("ascomcamGetWheelNames fin. filters=%s",*names);
         return 0;

      } else {
         m_logger.logDebug("ascomcamGetWheelNames fin. No filters name");
         *names = (char*) NULL;
         return 0;
      }
      m_logger.logDebug("ascomcamGetWheelNames fin OK"); 
*/
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamGetWheelNames  error=%s",e.what());
      m_logger.logError(cam->msg);
      return 1;
   }
}

int CCamAscom::ascomcamGetMaxBin(CCamAscom *cam, int * maxBin) 
{
   m_logger.logDebug("ascomcamGetProperty debut");
   if ( cam->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamGetProperty camera not initialized");
      m_logger.logError(cam->msg);
      return -1;
   }

   try {
      *maxBin  = cam->ascomCamera->getMaxBinX();
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamGetMaxBin  error=%s",e.what());
      m_logger.logError(cam->msg);
      return 1;
   }
}

int CCamAscom::ascomcamHasShutter(CCamAscom *cam, int *hasShutter) 
{
   m_logger.logDebug("ascomcamHasShutter debut");
   if ( cam->ascomCamera == NULL ) {
      sprintf(cam->msg, "ascomcamHasShutter camera not initialized");
      m_logger.logError(cam->msg);
      return -1;
   }

   try {
      *hasShutter  = cam->ascomCamera->hasShutter();
      return 0;
   } catch(  std::exception &e) {
      sprintf(cam->msg, "ascomcamHasShutter error=%s",e.what());
      m_logger.logError(cam->msg);
      return 1;
   }
}

int CCamAscom::cmdAscomcamProperty(CCamAscom* cam, int argc, const char *argv[]) {
   char ligne[1024];
   int result = SPEC_OK, pb = 0, k = 0;
   if ((argc < 2) || (argc > 4)) {
      pb = 0;
   } else {
      k = 0;
      pb = 0;
      if (strcmp(argv[2], "maxbin") == 0) {
         int maxBin; 
         result = ascomcamGetMaxBin(cam,&maxBin);
         if ( result == 0 ) {
            sprintf(ligne, "%d", maxBin);
            result = SPEC_OK;
         } else {
            sprintf(ligne, "%s", cam->msg);
            result = SPEC_ERROR;
         }
      } else if (strcmp(argv[2], "hasShutter") == 0) {
         int hasShutter; 
         result = ascomcamHasShutter(cam,&hasShutter);
         if ( result == 0 ) {
            sprintf(ligne, "%d", hasShutter);
            result = SPEC_OK;
         } else {
            sprintf(ligne, "%s", cam->msg);
            result = SPEC_ERROR;
         }
      } else {
         pb = 1;
      }
   }
   if (pb == 1 ) {
         sprintf(ligne, "Usage: %s %s hasShutter|maxbin", argv[0], argv[1]);
         result = SPEC_ERROR;
   }
   Spec_SetResult(ligne);
   return result;
}


// ---------------------------------------------------------------------------
// cmdCamConnectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
//    quand la camera est deja connectee
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int CCamAscom::cmdAscomcamConnectedSetupDialog(CCamAscom* cam, int argc, const char *argv[])
{

   int result = cam->cam_connectedSetupDialog();
   if ( result == 0 ) {
      Spec_SetResult("");
      return SPEC_OK;
   } else {
      Spec_SetResult(cam->msg);
      return SPEC_ERROR;
   }
}


abcommon::CStructArray<abcommon::SAvailable*>*  libcam::getAvailableCamera() {
   try {
      return AscomCamera::getAvailableCamera();

   } catch( std::exception ) {
      //return NULL;
   }

}