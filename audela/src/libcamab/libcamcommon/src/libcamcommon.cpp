/* libcam.h
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

/*****************************************************************/
/*             This part is common for all cam drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>     /* va_list, va_start, va_arg, va_end */
#include <time.h>               // time, ftime, strftime, localtime 
#include <sys/timeb.h>          // ftime, struct timebuffer 

#include <libcamab/libcamcommon.h>
using namespace ::abcommon;
 

/**
* ILibcam factory
*/
libcam::ILibcam* CLibcamCommon::createCameraInstance(CLibcamCommon * cam, int argc, const char *argv[]) {
   try
   {
      // j'initialise l'instance
      cam->cam_init_common(argc, argv);
      cam->cam_init(argc, argv);
      return cam;
   }
   catch (IError &ex) {
      if (cam != NULL) {
         delete cam;
      }
      // je memorise l'erreur
      abcommon::setLastError(ex);
      return NULL;
   }
}

/**
* common contructor
*/ 
CLibcamCommon::CLibcamCommon() {

}

/**
* common destructor
*/ 
void CLibcamCommon::releaseInstance() {
   this->cam_close();
   delete this;
}
   
   
/**
* init 
*/ 
void CLibcamCommon::cam_init_common(int argc, const char *argv[]) {
   
   SpecificResult = NULL;
   strcpy(this->msg,"");
   this->authorized = 1;

   // j'initialise les traces
   m_logger.set("camera.log", argc, argv);

   // --- Decode les options de cam::create en fonction de argv[>=3] --- 
   int k, kk;
   this->index_cam = 0;
   this->mode_stop_acq=1; // 0=read after stop 1=let the previous image without reading
   if (argc >= 1) {
      portname = argv[0];
   }
   //this->acquisitionStatus = AcquisitionStand;
   
   //m_logger.log(CLogger::LOG_DEBUG, " CLibcamCommon::cam_init_common debut\n");
   
   if (argc >= 5) {
      // je copie le nom du port en limitant le nombre de caractères à la taille maximal de this->portname
      for (kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-name") == 0) {
            k = 0;
            while (strcmp(CAM_INI[k].name, "") != 0) {
               if (strcmp(CAM_INI[k].name, argv[kk + 1]) == 0) {
                  this->index_cam = k;
                  break;
               }
               k++;
            }
         }
         if (strcmp(argv[kk], "-ccd") == 0) {
            k = 0;
            while (strcmp(CAM_INI[k].name, "") != 0) {
               if (strcmp(CAM_INI[k].ccd, argv[kk + 1]) == 0) {
                  this->index_cam = k;
                  break;
               }
               k++;
            }
         }
      }
   }
   
   // --- authorize the sti/cli functions ---
   if (this->authorized == 0) {
      this->interrupt = 0;
   } else {
      this->interrupt = 1;
   }
   // --- L'axe X est choisi parallele au registre horizontal. --- 
   this->overscanindex = CAM_INI[this->index_cam].overscanindex;
   
   this->nb_photox = CAM_INI[this->index_cam].maxx;   // nombre de photosites sur X 
   this->nb_photoy = CAM_INI[this->index_cam].maxy;   // nombre de photosites sur Y 
   if (this->overscanindex == false) {
      // nb photosites masques autour du CCD 
      this->nb_deadbeginphotox = CAM_INI[this->index_cam].overscanxbeg;
      this->nb_deadendphotox = CAM_INI[this->index_cam].overscanxend;
      this->nb_deadbeginphotoy = CAM_INI[this->index_cam].overscanybeg;
      this->nb_deadendphotoy = CAM_INI[this->index_cam].overscanyend;
   } else {
      this->nb_photox += (CAM_INI[this->index_cam].overscanxbeg + CAM_INI[this->index_cam].overscanxend);
      this->nb_photoy += (CAM_INI[this->index_cam].overscanybeg + CAM_INI[this->index_cam].overscanyend);
      // nb photosites masques autour du CCD 
      this->nb_deadbeginphotox = 0;
      this->nb_deadendphotox = 0;
      this->nb_deadbeginphotoy = 0;
      this->nb_deadendphotoy = 0;
   }
   this->celldimx = CAM_INI[this->index_cam].celldimx;    // taille d'un photosite sur X (en metre) 
   this->celldimy = CAM_INI[this->index_cam].celldimy;    // taille d'un photosite sur Y (en metre) 
   this->fillfactor = CAM_INI[this->index_cam].fillfactor;    // fraction du photosite sensible a la lumiere 
   this->foclen = CAM_INI[this->index_cam].foclen;
   // --- initialisation de la fenetre par defaut --- 
   this->x1 = 0;
   this->y1 = 0;
   this->x2 = this->nb_photox - 1;
   this->y2 = this->nb_photoy - 1;
   this->plane = 1;
   // --- initialisation du mode de binning par defaut ---
   this->binx = CAM_INI[this->index_cam].binx;
   this->biny = CAM_INI[this->index_cam].biny;
   m_binMaxX = 4;
   m_binMaxY = 4;
   // --- initialisation du temps de pose par defaut --- 
   this->exptime = (float) CAM_INI[this->index_cam].exptime;

   printf(" CLibcamCommon::cam_init_common CAM_INI[this->index_cam].exptime OK\n"); 
   
   // --- initialisation des retournements par defaut --- 
   this->mirrorh = 0;
   this->mirrorv = 0;
   // --- initialisation du numero de port parallele du PC ---
   this->portindex = 0;
   this->port = 0x378;       /* lpt1 par defaut */
   if (argc > 2) {
      if (strcmp(argv[2], "lpt2") == 0) {
         this->portindex = 1;
         this->port = 0x278;
      }
   }
      
   this->check_temperature = CAM_INI[this->index_cam].check_temperature;
   
   //---  valeurs par defaut des capacites offertes par la camera
   this->capabilities.expTimeCommand = true;  // existence  du choix du temps de pose
   this->capabilities.expTimeList    = false;  // existence  de la liste des temps de pose predefini
   this->capabilities.shutter        = true;
   this->capabilities.videoMode      = false;  // existence  du mode video
   this->gps_date = 0;

   //cam->bufno = 0;
   //cam->telno = 0;
   printf(" CLibcamCommon::cam_init_common fin OK\n");  

   m_logger.logDebug( "cmdCamCreate: create camera data at %p\n", this);
}


/**
* get binning
*/
void CLibcamCommon::cam_binning_get(int* binx, int* biny) {
   *binx = this->binx;
   *biny = this->biny;
}

/**
* get binning
*/
void CLibcamCommon::cam_binning_set(int binx, int biny) {
   this->binx = binx;
   this->biny = biny;
   cam_update_window();
}


/**
* get binning
*/ 
void CLibcamCommon::cam_binningMax_get(int* binMaxX, int* binMaxY) {
   *binMaxX = m_binMaxX;
   *binMaxY = m_binMaxY;
}

/**
* get capabilities
*/ 
bool CLibcamCommon::cam_capability_get(Capability capability) {

   switch (capability) {
      case Shutter : 
         return this->capabilities.shutter;
      case ExpTimeCommand : 
         return this->capabilities.expTimeCommand;
      case ExpTimeList : 
         return this->capabilities.expTimeList;
      case VideoMode : 
         return this->capabilities.videoMode;   
      default:
         throw CError(CError::ErrorInput, "unknow capability %d", capability);
   }

}

/**
* get CCD name
*/ 
const char* CLibcamCommon::cam_ccdName_get() {
   return CAM_INI[this->index_cam].ccd;
}

/**
* get CCD cell dimension
*/ 
void CLibcamCommon::cam_cellDim_get(double* celldimx, double* celldimy) {
   *celldimx = this->celldimx;
   *celldimy = this->celldimy;
}

/**
* get cell number
*/
void  CLibcamCommon::cam_cell_nb_get(int* cellx, int* celly) {
   *cellx = this->nb_photox;
   *celly = this->nb_photoy;
}



///**
//* set CCD cell dimension
//*/ 
//void CLibcamCommon::cam_cellDim_set(double celldimx, double celldimy) {
//   this->celldimx = celldimx;
//   this->celldimy = celldimy;
//}


/**
* get debug level ( 0 , 1, 2, 3, 4)
*/ 
int CLibcamCommon::cam_logLevel_get() {
   return m_logger.getLogLevel();
}

/**
* set debug level ( 0 , 1, 2, 3, 4)
*/ 
void CLibcamCommon::cam_logLevel_set(int debug) {
   m_logger.setLogLevel(m_logger.convertToLogLevel(debug));
}

/**
* get exptime (in seconds)
*/ 
double CLibcamCommon::cam_exptime_get() {
   return this->exptime;
}

/**
* set exptime (in seconds)
*/ 
void CLibcamCommon::cam_exptime_set(double exptime) {
   this->exptime = (float) exptime;
}


/**
* get height (in pixel)
*/ 
int CLibcamCommon::cam_exposure_height_get() {
   return this->h;
}

/**
* get plane (1= grey image , 3= RGB image)
*/ 
int CLibcamCommon::cam_exposure_plane_get() {
   return this->plane;
}

/**
* get width (in pixel)
*/ 
int CLibcamCommon::cam_exposure_width_get() {
   return this->w;
}

//void CLibcamCommon::cam_exposure_freePixels(float* pixels) {
//   if(pixels != NULL) {
//      free(pixels);
//      pixels= NULL;
//   }
//}

/**
* get fill factor 
*/ 
double CLibcamCommon::cam_fillFactor_get() {
   return this->fillfactor;
}

/**
* get focal length  (in meter)
*/ 
//double CLibcamCommon::cam_focLen_get() {
//   return this->foclen;
//}

/**
* set focal length  (in meter)
*/ 
//void CLibcamCommon::cam_focLen_set(struct camprop* cam, double focLen) {
//   this->foclen = focLen;
//}

/**
* get gain 
*/ 
double CLibcamCommon::cam_gain_get() {
   return CAM_INI[this->index_cam].gain;
}


/**
* get GPS date (0 or 1)
*/ 
int CLibcamCommon::cam_GPSDate_get() {
   return this->gps_date;
}

/**
* set GPS date (0 or 1)
*/ 
void CLibcamCommon::cam_GPSDate_set(int gpsDate) {
   this->gps_date = gpsDate;
}

/**
* get camera max dynamic
*/ 
double CLibcamCommon::cam_dynamic_get() {
   return CAM_INI[this->index_cam].maxconvert;
}


///**
//* get interrupt (0 or 1)
//*/ 
//int CLibcamCommon::getInterrupt() {
//   return this->interrupt;
//}

///**
//* set interrupt (0 or 1)
//*/ 
//void CLibcamCommon::setInterrupt(int interrupt) {
//   this->interrupt = interrupt;
//   this->authorized = 1;
//}

char* CLibcamCommon::getMessage() {
   return this->msg;
}

/**
* set message
*/ 
void CLibcamCommon::setMessage(char *message) {
   strcpy(this->msg, message);
}



/**
* get mirror H (0 or 1)
*/ 
bool CLibcamCommon::cam_mirrorH_get() {
   return this->mirrorh;
}

/**
* set mirror H (0 or 1)
*/ 
void CLibcamCommon::cam_mirrorH_set(bool mirrorh) {
   this->mirrorh = mirrorh;
   // je met a jour les coordonnees du fenetrage pour prendre en compte le miroir
   cam_update_window();
}

/**
* get mirror V (0 or 1)
*/ 
bool CLibcamCommon::cam_mirrorV_get() {
   return this->mirrorv;
}

/**
* set mirror V (0 or 1)
*/ 
void CLibcamCommon::cam_mirrorV_set(bool mirrorv) {
   this->mirrorv = mirrorv;
   // je met a jour les coordonnees du fenetrage pour prendre en compte le miroir
   cam_update_window();
}

/**
* get camera name
*/ 
const char* CLibcamCommon::cam_cameraName_get() {
   return CAM_INI[this->index_cam].name;
}

/**
* get pix dimension ( in micron)
*/ 
void  CLibcamCommon::cam_pix_dim_get(double* dimx, double* dimy) {
   *dimx = this->celldimx * this->binx;
   *dimy = this->celldimy * this->biny;
}

/**
* get pix number i.e = nb cell / binning
*/ 
void  CLibcamCommon::cam_pix_nb_get(int* pixx, int* pixy) {
   *pixx = this->nb_photox / this->binx;
   *pixy = this->nb_photoy / this->biny;
}

/**
* get overscan (O, 1)
*/ 
bool CLibcamCommon::cam_overScan_get() {
   return this->overscanindex;
}

/**
* set over scan   (O, 1)
*/ 
void CLibcamCommon::cam_overScan_set(bool overScan) {
   this->overscanindex = overScan;
   this->nb_photox = CAM_INI[this->index_cam].maxx;    /* nombre de photosites sur X */
   this->nb_photoy = CAM_INI[this->index_cam].maxy;    /* nombre de photosites sur Y */
   if (this->overscanindex == false) {
      /* nb photosites masques autour du CCD */
      this->nb_deadbeginphotox = CAM_INI[this->index_cam].overscanxbeg;
      this->nb_deadendphotox = CAM_INI[this->index_cam].overscanxend;
      this->nb_deadbeginphotoy = CAM_INI[this->index_cam].overscanybeg;
      this->nb_deadendphotoy = CAM_INI[this->index_cam].overscanyend;
   } else {
      this->nb_photox += (CAM_INI[this->index_cam].overscanxbeg + CAM_INI[this->index_cam].overscanxend);
      this->nb_photoy += (CAM_INI[this->index_cam].overscanybeg + CAM_INI[this->index_cam].overscanyend);
      /* nb photosites masques autour du CCD */
      this->nb_deadbeginphotox = 0;
      this->nb_deadendphotox = 0;
      this->nb_deadbeginphotoy = 0;
      this->nb_deadendphotoy = 0;
   }
   /* --- initialisation de la fenetre par defaut --- */
   this->x1 = 0;
   this->y1 = 0;
   this->x2 = this->nb_photox - 1;
   this->y2 = this->nb_photoy - 1;
}

/**
* get camera port name
*/ 
const char* CLibcamCommon::cam_portName_get() {
   return this->portname.c_str();
}

/**
* get camera product name
*/ 
const char* CLibcamCommon::cam_product_get() {
   return CAM_INI[this->index_cam].product;
}

/**
* get camera read noise
*/ 
double CLibcamCommon::cam_readNoise_get() {
   return CAM_INI[this->index_cam].readnoise;
}

/**
* get camera rgb index 
*/ 
int CLibcamCommon::cam_rgb_get() {
   return this->rgbindex;
}


/**
* get shutter mode (0=closed 1=syncho 2=opened)
*/ 
CLibcamCommon::ShutterMode CLibcamCommon::cam_shutter_get() {
   return this->shutterindex;
}

/**
* set shutter mode (0=closed 1=syncho 2=opened)
*/ 
//void CLibcamCommon::am_shutter_setMode(int state) {
//   this->shutterindex = state;
//}

/**
* close shutter . Shutter will be always cloased
*/ 
void CLibcamCommon::cam_shutter_close() {
   m_logger.logDebug("cam_shutter_close COMMON");
   this->shutterindex = SHUTTER_CLOSED;
}

/**
* open shutter . Shutter will be always opened
*/ 
void CLibcamCommon::cam_shutter_open() {
   m_logger.logDebug("cam_shutter_open COMMON");
   this->shutterindex = SHUTTER_OPEN;
}

/**
* syncho shutter. shutter will be synchonized with exposure
*/ 
void CLibcamCommon::cam_shutter_synchro() {
   m_logger.logDebug("cam_shutter_synchro COMMON");
   this->shutterindex = SHUTTER_SYNCHRO;

}

/**
* get window size (in pixels , 1 based)
*/ 
void CLibcamCommon::cam_window_get(int* x1, int* y1, int* x2, int* y2) {
   *x1 = this->x1 + 1;
   *y1 = this->y1 + 1;
   *x2 = this->x2 + 1;
   *y2 = this->y2 + 1;
}

/**
* set window size (in pixels , 1 based)
*/ 
void CLibcamCommon::cam_window_set(int x1, int y1, int x2, int y2) {
   this->x1 = x1 - 1;
   this->y1 = y1 - 1;
   this->x2 = x2 - 1;
   this->y2 = y2 - 1;

}


/**
* executeSpecificCommand
* @param argv  argv[0]=cam1  argv[1]=command name , argv[2...]= command parameters
* @param specificCommandResult   command result 
*
* @return  0=OK  1=ERROR  -1= command not found
*/ 
int CLibcamCommon::cam_specificCommand_execute(char** specificCommandResult, int argc, const char *argv[]) {
   int retour = -1;
   //*specificCommandResult = NULL;
   //for (struct cmditemSpec* cmd = specificCmdList; cmd->cmd != NULL; cmd++) {
   //   if (strcmp(cmd->cmd, argv[1]) == 0) {
   //      retour = (*cmd->func) (camprop, argc, argv);
   //      // je copie le pointeur du resultat
   //      *specificCommandResult = SpecificResult;
   //      break;
   //   }
   //}

   return retour;
}

int CLibcamCommon::cam_specificCommand_execute_tcl(void * interp, int argc, const char *argv[]) {
   int retour = -1;
   //*specificCommandResult = NULL;
   //for (struct cmditemSpec* cmd = specificCmdList; cmd->cmd != NULL; cmd++) {
   //   if (strcmp(cmd->cmd, argv[1]) == 0) {
   //      retour = (*cmd->func) (camprop, argc, argv);
   //      // je copie le pointeur du resultat
   //      *specificCommandResult = SpecificResult;
   //      break;
   //   }
   //}

   return retour;
}

void CLibcamCommon::cam_specificCommand_freeResult() {
   if(SpecificResult != NULL) {
      free(SpecificResult);
      SpecificResult= NULL;
   }
}



void CLibcamCommon::Spec_SetResult(char * result) {
   // je nettoie 
   if( SpecificResult != NULL) {
      free(SpecificResult);
      SpecificResult = NULL;
   }

   // je copie le resultat dans la variable de retour
   if (result == NULL) {
      SpecificResult = (char*) calloc(1,1);
      strcpy(SpecificResult,"");
   } else {
      int length = strlen(result);
      SpecificResult = (char*) calloc(length + 1, 1);
      memcpy(SpecificResult, result, (unsigned) length+1);
   }
}

//IStringArray*  libcam::getAvailableCamera() {
//   CLibcamCommon* cam = NULL;
//   try {
//      cam = getCameraInstance();
//      IStringArray* available = cam->getAvailableCamera();
//      delete cam;
//      return available;
//   }
//   catch (abcommon::IError &exception) {
//      if (cam != NULL) {
//         delete cam;
//      }
//      // je memorise l'erreur
//      abcommon::setLastError(exception);
//      return NULL;
//   }
//}
