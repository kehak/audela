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

#include <exception>
//#include <time.h>               /* time, ftime, strftime, localtime */
//#include <sys/timeb.h>          /* ftime, struct timebuffer */
#include <string>
#include <exception>
#include <cstdlib>         // calloc
#include <cstring>         // strcmp

#include <abcommon2.h>
#include <libcamab/libcam.h>
#include <libcamab/libcamcommon.h>
using namespace abcommon;

#include "camera.h"
#include "IndiCamera.h"


/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CLibcamCommon::CAM_INI[] = {
   {"noname",			/* camera name 70 car maxi*/
     "indicam",     /* camera product */
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


/// @brief  create instance
//
libcam::ILibcam* libcam::createCameraInstance(int argc, const char *argv[]) {
   return CLibcamCommon::createCameraInstance(new CCamera(), argc, argv);
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

void CCamera::cam_init(int argc, const char **argv)
{
   printf("    CCamera::cam_init debut\n");    

   if( argc < 1 || strcmp(argv[0],"")==0  || strcmp(argv[0],"(null)")==0 )  {
      throw CError(CError::ErrorGeneric, "cam_init camera name is empty (example : \"CCD Simulator\") ");
   }
   // nom de la camera       
   ::std::string cameraName = argv[0];
   ::std::string serverAddress = "127.0.0.1";
   int serverPort = 7624;
   m_logger.logInfo("argc=%d cameraName=%s", argc, cameraName.c_str());
   printf("    CCamera::cam_init log OK\n");
   
   
   try {
      this->m_indiCamera = IndiCamera::createInstance( cameraName.c_str(), serverAddress.c_str(), serverPort, &m_logger);
      // je recupere la largeur et la hauteur du CCD en pixels (en pixel sans binning)             
      this->nb_photox  = this->m_indiCamera->getCameraXSize();
      this->nb_photoy  = this->m_indiCamera->getCameraYSize();
       m_logger.logDebug("cam_init nb_photo=%d x %d", this->nb_photox , this->nb_photoy);
      
      // je recupere la taille des pixels (en micron converti en metre)
      this->celldimx   = this->m_indiCamera->getPixelSizeX() * 1e-6;
      this->celldimy   = this->m_indiCamera->getPixelSizeY() * 1e-6;     
       m_logger.logDebug("cam_init celldim=%d x %d", this->celldimx , this->celldimy);
      // je recupere la description en limitant la taille � la taille de la variable destinatrice
      strncpy(CAM_INI[this->index_cam].name, this->m_indiCamera->getCameraName(), 255 ); 
       m_logger.logDebug("cam_init camera name=%s", CAM_INI[this->index_cam].name);
      
   } catch (std::exception &e) {
       throw CError(CError::ErrorGeneric, "cam_init error=%s",e.what());
   } 

   this->x1 = 0;
   this->y1 = 0;
   this->x2 = this->nb_photox - 1;
   this->y2 = this->nb_photoy - 1;
   this->binx = 1;
   this->biny = 1;


   cam_update_window();	// met a jour x1,y1,x2,y2,h,w dans cam
   strcpy(this->date_obs, "2000-01-01T12:00:00");
   strcpy(this->date_end, this->date_obs);
   this->authorized = 1;

    
    m_logger.logDebug("cam_init fin OK");
}

// @TODO
bool CCamera::cam_cooler_get() {
	return false ;

}

// @TODO
void CCamera::cam_cooler_set(bool) {

}


void CCamera::cam_close()
{
   
   try {
       m_logger.logDebug("cam_close debut");
      // je supprime la camera
      if (this->m_indiCamera != NULL ) {
         IndiCamera::releaseInstance ( &this->m_indiCamera );
      }
       m_logger.logDebug("cam_close fin OK");
   } catch(std::exception &ex) {
      throw CError(CError::ErrorGeneric, "cam_close error=%s",ex.what());
   }
   
}

void CCamera::cam_update_window()
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
   
   // je configure la fenetre de la camera.
   // subframe start position for the X axis (0 based) in binned pixels
   this->m_indiCamera->setFrame(x1, y1, this->w, this->h);
}

void CCamera::cam_exposure_start()
{
   if ( this->m_indiCamera == NULL ) {
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
         this->m_indiCamera->startExposure(exptime, this->shutterindex); 
         return;
     } catch( std::exception &e) {
         sprintf(this->msg, "cam_start_exp error=%s",e.what());
          m_logger.logError(this->msg);
         return;
      }
   }
   
}

void CCamera::cam_exposure_stop()
{
    
    m_logger.logDebug("cam_stop_exp debut");
   if ( this->m_indiCamera == NULL ) {
      sprintf(this->msg, "cam_stop_exp camera not initialized");
       m_logger.logError(this->msg);
      return;
   }

   try {
      // j'interromps l'acquisition
      this->m_indiCamera->stopExposure();
       m_logger.logDebug("cam_stop_exp fin OK");
      return;
   } catch( std::exception &e) {
         sprintf(this->msg, "cam_stop_exp error=%s",e.what());
          m_logger.logError(this->msg);
         return;
   }
  
}

void CCamera::cam_exposure_readCCD(float *p)
{
    
    m_logger.logDebug("cam_read_ccd debut");
   if ( this->m_indiCamera == NULL ) {
      sprintf(this->msg, "cam_read_ccd camera not initialized");
       m_logger.logError(this->msg);
      return;
   }
   if (p == NULL) {
       m_logger.logDebug("cam_read_ccd p=NULL");
      return;
   }

   if (this->authorized == 1) {
      try {
          m_logger.logDebug("cam_read_ccd avant readimage");
         this->m_indiCamera->readImage(p);
      } catch( std::exception &e) {
         sprintf(this->msg, "cam_read_ccd  error=%s",e.what());
          m_logger.logError(this->msg);
         return;
      }
   }

}

abcommon::IStringArray*  CCamera::getAvailableCamera() {
   try {
      return  new CStringArray();

   } catch( std::exception &e) {
      return NULL;
   }

}
