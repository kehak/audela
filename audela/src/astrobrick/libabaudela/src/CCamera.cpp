/* CCamera.cpp
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
#include <windows.h>     // pour timeval
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>    // va_start
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */

#include <string>
#include <cstring>
#include <sstream>  // pour ostringstream
#include <mutex>    // pour mutex
#include <thread>
using namespace ::std;

#include <abcommon.h>
using namespace abcommon;
#include "CCamera.h"

CCamera::CCamera() {
   m_buffer = NULL;
   m_statusCallback = NULL;
   m_acquisitionStatus = AcquisitionStand;
   m_mode_stop_acq=1;  // 0=read after stop 1=let the previous image without reading
   m_libcam = NULL;
   m_log.setLogLevel(ILogger::LOG_ERROR);
   m_log.setLogFileName(std::string("camera.log"));
   m_radecFromTel = true;
   m_telescope = NULL;
   m_stopMode = 1;
}

CCamera::~CCamera() {
   if( m_libcam != NULL) {
      try {
         m_libcam->releaseInstance();
         //Libcam_deleteCamera(libcam);
         m_libcam = NULL;
      } catch (...) {

      }
   }
}

void CCamera::init(const char* librayPath, const char * libraryFileName, int argc, const char *argv[]) throw (IError) {
   m_log.set("camera.log",argc, argv);
   m_libcam = m_libraryLoader.load(librayPath, "cam" , libraryFileName, "createCameraInstance", argc, argv);
   setCameraStatus(AcquisitionStand);
}

void CCamera::setSatusCallback(void *clientData, CameraStatusCallbackType statusCallback) {
   this->m_statusCallback = statusCallback;
   this->callbackClientData = clientData;
}

const char * CCamera::getLibraryName() {
   return m_libraryLoader.getLibraryName();
}

/**
 * start acquisition
 */
void CCamera::acq() {
   if (m_acquisitionStatus == AcquisitionStand) {         
      m_exptimeTimer = m_libcam->cam_exptime_get();
      libcam_GetCurrentFITSDate(m_date_obs);
      
      m_libcam->cam_exposure_start();
      if(strcmp(m_libcam->getMessage(),"")!= 0 ) {
         throw CError(CError::ErrorGeneric, m_libcam->getMessage());
      } else {
         // je change le status de la camera
         setCameraStatus(AcquisitionExp);
         
         // je recupere l'heure de debut du timer
         struct timeval nowTimeVal;
         gettimeofday(&nowTimeVal, NULL);
         m_clockbegin = nowTimeVal.tv_sec;            

         // je lance le thread d'acquisition 
         thread(&CCamera::acqReadThread, this).detach();

      }
   } else {
       throw CError(CError::ErrorGeneric, "Camera already in use");
   }
}


///@brief thread de surveillance des coordonnées
//
void CCamera::acqReadThread() 
{
   m_log.logDebug("acqReadThread begin");
   std::unique_lock<std::mutex> lk(m_acqMutex);
   long exptimeInMs = long(m_libcam->cam_exptime_get() * 1000);
   try {
      std::cv_status  status = m_acqCv.wait_for(lk, std::chrono::milliseconds(exptimeInMs));
      if (status == std::cv_status::timeout) {
         // fin normale du timer : je lis l'image
         m_log.logDebug("acqReadThread fin timer");
         readCCD();
      } else{
         // interruption du timer
         m_log.logDebug("acqReadThread interruption");
         if (m_mode_stop_acq == 0) {
            readCCD();
         }
      }
   }
   catch (CError &ex) {
      m_log.logError("acqReadThread %s", ex.getMessage());
   }

   m_clockbegin = 0;
   // status = AcquisitionStand
   setCameraStatus(AcquisitionStand);

   lk.unlock();
   m_acqCv.notify_all();
   m_log.logDebug("acqReadThread end");
}

/*
 * AcqRead
 * lecture du CCD dans un thread dedié
 */
/*
void* CCamera::acqReadThread(void * clientData )
{
   //char errorMessage[1024];

   CCamera*cam = (CCamera *) clientData;   
   cam->m_log.logDebug("acqRead debut");

   //strcpy(errorMessage,"");

   // j'intialise le timer
   struct timeval timerBegin;
   struct timespec timerEnd;
   long exptimeInMs = long(cam->m_libcam->cam_exptime_get() *1000);
   //pthread_cond_t condition  = PTHREAD_COND_INITIALIZER;
   pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
   
   cam->m_condition = PTHREAD_COND_INITIALIZER;
   pthread_mutex_lock(&mutex);

   // je recupere l'heure de debut du timer
   gettimeofday(&timerBegin, NULL);

   // je calcule l'heure de fin du timer
   timerEnd.tv_sec = timerBegin.tv_sec + exptimeInMs / 1000;
   timerEnd.tv_nsec = timerBegin.tv_usec * 1000 + 1000 * 1000 * (exptimeInMs % 1000);
   timerEnd.tv_sec += timerEnd.tv_nsec / (1000 * 1000 * 1000);
   timerEnd.tv_nsec %= (1000 * 1000 * 1000);
   
   // je lance le timer et je bloque jusqu'a la fin du timer ou jusqu'a reception d'une interruption 
   int timedwaitResult = pthread_cond_timedwait(&cam->m_condition, &mutex, &timerEnd);
   if (timedwaitResult == 0) {
      // interruption du timer
      cam->m_log.logDebug("acqReadThread interruption");
      if (cam->m_mode_stop_acq == 0 ) {
          readCCD( cam);
      }
   } else if (timedwaitResult == ETIMEDOUT || timedwaitResult==10060) {
      // fin normale du timer
      cam->m_log.logDebug("acqReadThread fin timer");
      // je lis l'image
      readCCD(cam);
   } else {
      // erreur 
      cam->m_log.logDebug("acqReadThread erreur");
   }

   pthread_mutex_unlock(&mutex);

   cam->m_clockbegin = 0;

   // status = AcquisitionStand
   setCameraStatusAsync(cam , AcquisitionStand);

   cam->m_log.logDebug("acqRead fin");
   pthread_exit(NULL);
   return NULL;
}
*/

void CCamera::readCCD() {
   float *p;       

   m_log.logDebug("readCCD debut");

   // petit raccourci bien utile
   libcam::ILibcam* libcam = m_libcam;

   libcam_GetCurrentFITSDate(m_date_end);

   // Information par defaut concernant l'image
   libcam->setMessage((char*)"");
   libcam->cam_GPSDate_set(0);    // mis a 1 par CAM_DRV.read_ccd si la camera a une datation avec GPS   
   
   
   // allocation par defaut du m_buffer
   int width = libcam->cam_exposure_width_get();
   int height = libcam->cam_exposure_height_get();
   int plane = libcam->cam_exposure_plane_get();
   p = (float *) calloc(width * height * plane, sizeof(float));
   
   // je change le status de la camera status=AcquisitionRead
   setCameraStatus(AcquisitionRead);

   //  je lis le CCD
   libcam->cam_exposure_readCCD(p);

   // je verfie l'existance du m_buffer associé à la caméra
   IBuffer* buffer = m_buffer;
   if (buffer == NULL) {
      free( p);
      m_log.logDebug("readCCD buffer is null");
      return;
   }
          
   // je copie les pixels et les mots cle dans dans le m_buffer       
   if (strlen(libcam->getMessage()) == 0) {
      m_log.logDebug("acqRead setPixels");
      // je nettoie le m_buffer
      buffer->freeBuffer(IBuffer::DONT_KEEP_KEYWORDS);
      // je copie les pixels dans dans le m_buffer 
      buffer->setPixels(width, height, plane, p, libcam->cam_mirrorV_get() , libcam->cam_mirrorH_get());
      if ( plane == 1) {
         buffer->setKeyword("NAXIS", 2, "", "");
         buffer->setKeyword("NAXIS1", width, "", "");
         buffer->setKeyword("NAXIS2", height, "", "");
      } else {
         buffer->setPixels(width, height, plane, p, libcam->cam_mirrorV_get() , libcam->cam_mirrorH_get());
         buffer->setKeyword("NAXIS", 3, "", "");
         buffer->setKeyword("NAXIS1", width, "", "");
         buffer->setKeyword("NAXIS2", height, "", "");
         buffer->setKeyword("NAXIS3", plane, "", "");
      }
      m_log.logDebug("acqRead setKeyword");

      int binx, biny; 
      libcam->cam_binning_get(&binx, &biny);
      buffer->setKeyword("BIN1", binx, "", "");
      buffer->setKeyword("BIN2", biny, "", "");
      buffer->setKeyword("DATE-OBS", m_date_obs, "", "");
      buffer->setKeyword("DATE-END", m_date_end, "", "");
      buffer->setKeyword("EXPOSURE", m_libcam->cam_exptime_get(), "", "");
      
      if (libcam->cam_GPSDate_get() == 1) {
         buffer->setKeyword("GPS-DATE", 1, "if datation is derived from GPS, else 0", "");
         char cameraName[1024];
         sprintf(cameraName, "%s+GPS %s %s", libcam->cam_cameraName_get(), libcam->cam_ccdName_get(), getLibraryName());
         buffer->setKeyword("CAMERA", cameraName, "", "");
      } else {
         buffer->setKeyword("GPS-DATE", 0, "if datation is derived from GPS, else 0", "");
         char cameraName[1024];
         sprintf(cameraName, "%s %s %s", libcam->cam_cameraName_get(), libcam->cam_ccdName_get(), getLibraryName() );
         buffer->setKeyword("CAMERA", cameraName, "", "");
      }



      //if ( m_radecFromTel  == 1 ) {
      //   double ra, dec;
      //   int status;
      //   libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
      //   //printf("libcam.c: libcam_get_tel_coord:status=%d\n", status);
      //   if (status == 0) {
      //      // Add FITS keywords
      //      sprintf(s, "buf%d setkwd {RA %7.3f float \"Right ascension m_telescope encoder\" \"\"}", bufno, ra);
      //      libcam_log(LOG_DEBUG, s);
      //      Tcl_Eval(interp, s);
      //      sprintf(s, "buf%d setkwd {DEC %7.3f float \"Declination m_telescope encoder\" \"\"}", bufno, dec);
      //      libcam_log(LOG_DEBUG, s);
      //      Tcl_Eval(interp, s);
      //   }
      //}
   } else {
      // erreur d'acquisition, on enregistre une image vide
      buffer->freeBuffer(IBuffer::DONT_KEEP_KEYWORDS);
      m_log.logDebug(libcam->getMessage() );
   }

   free(p);
   m_log.logDebug("readCCD fin");

}



//-----------------------------------------------------------------------------
// library wrapper function 
//-----------------------------------------------------------------------------

void CCamera::getBinning(int* binx, int* biny) {
   m_libcam->cam_binning_get(binx, biny);
}
 
void CCamera::setBinning(int binx, int biny) {
   m_libcam->cam_binning_set(binx, biny);
}

void CCamera::getBinningMax(int* binMaxX, int* binMaxY) {
   m_libcam->cam_binningMax_get(binMaxX, binMaxY);
}

IBuffer* CCamera::getBuffer() {
   return this->m_buffer;
}

void CCamera::setBuffer(IBuffer* buffer) {
   this->m_buffer = buffer;
}

bool CCamera::getCapability(Capability capability) {
   return m_libcam->cam_capability_get((libcam::ILibcam::Capability)capability);
}

const char* CCamera::getCcd() {
   return m_libcam->cam_ccdName_get();
}

void CCamera::getCellDim(double* celldimx, double* celldimy) {
   m_libcam->cam_cellDim_get(celldimx, celldimy);
}

//void CCamera::setCellDim(double celldimx, double celldimy) {
//   libcam->cam_cellDim_set(celldimx, celldimy);
//}
//

void CCamera::getCellNb(int* cellx, int* celly) {
   m_libcam->cam_cell_nb_get(cellx, celly);
}

bool CCamera::getCooler(){
   return m_libcam->cam_cooler_get();
}

void CCamera::setCooler(bool on){
   m_libcam->cam_cooler_set(on);
}

double CCamera::getCoolerCheckTemperature(){
   return m_libcam->cam_cooler_checkTemperature_get();
}

void CCamera::setCoolerCheckTemperature(double temperature){
   m_libcam->cam_cooler_checkTemperature_set(temperature);
}

double CCamera::getCoolerCcdTemperature(){
   return m_libcam->cam_cooler_ccdTemperature_get();
}

int CCamera::getDebug() {
   return m_libcam->cam_logLevel_get();
}

void CCamera::setDebug(int debug) {
   m_libcam->cam_logLevel_set(debug);
}


const char* CCamera::getDriverName() {
   return this->m_libraryLoader.getLibraryName();
}

double CCamera::getExptime() {
   return m_libcam->cam_exptime_get();
}

void CCamera::setExptime(double exptime) {
   m_libcam->cam_exptime_set(exptime);
}

double CCamera::getFillFactor() {
   return m_libcam->cam_fillFactor_get();
}

//double CCamera::getFocLen() {
//   return libcam->cam_fillFactor_get();
//}

//void CCamera::setFocLen(double focLen) {
//   libcam->setFocLen(focLen);
//}


double CCamera::getGain() {
   return m_libcam->cam_gain_get();
}

//int CCamera::getInterrupt() {
//   return libcam->getInterrupt();
//}

//void CCamera::setInterrupt(int interrupt) {
//   libcam->setInterrupt(interrupt);
//}

int CCamera::executeSpecificCommand(char** specificCommandResult, int argc, const char *argv[]) {
   return m_libcam->cam_specificCommand_execute(specificCommandResult, argc, argv );
}

int CCamera::executeTclSpecificCommand(void * interp, int argc, const char *argv[]) {
   return m_libcam->cam_specificCommand_execute_tcl(interp, argc, argv );
}

void CCamera::freeSpecificCommandResult() {
   m_libcam->cam_specificCommand_freeResult();
}

double CCamera::getMaxDyn() {
   return m_libcam->cam_dynamic_get();
}

bool CCamera::getMirrorH() {
   return m_libcam->cam_mirrorH_get();
}

void CCamera::setMirrorH(bool mirror) {
   m_libcam->cam_mirrorH_set(mirror);
}

bool CCamera::getMirrorV() {
   return m_libcam->cam_mirrorV_get();
}

void CCamera::setMirrorV(bool mirror) {
   m_libcam->cam_mirrorV_set(mirror);
}

const char* CCamera::getCameraName() {
   return m_libcam->cam_cameraName_get();
}

void CCamera::getPixDim(double* dimx, double* dimy) {
   m_libcam->cam_pix_dim_get(dimx, dimy);
}

void CCamera::getPixNb(int* pixx, int* pixy) {
   m_libcam->cam_pix_nb_get(pixx, pixy);
}

bool  CCamera::getOverScan() {
   return m_libcam->cam_overScan_get();
}
   
void CCamera::setOverScan(bool overScan) {
   m_libcam->cam_overScan_set(overScan);
}

const char* CCamera::getPortName() {
   return m_libcam->cam_portName_get();
}

const char* CCamera::getProduct() {
   return m_libcam->cam_product_get();
}

bool CCamera::getRadecFromTel() {
   return this->m_radecFromTel;
}

void CCamera::setRadecFromTel(bool radecFromTel) {
   this->m_radecFromTel = radecFromTel;
}

double CCamera::getReadNoise() {
   return m_libcam->cam_readNoise_get();
}

int CCamera::getRgb() {
   return m_libcam->cam_rgb_get();
}

CCamera::ShutterMode CCamera::getShutterMode() {
   return (CCamera::ShutterMode) m_libcam->cam_shutter_get();
}

//void CCamera::setShutterMode(CCamera::ShutterMode state) {
//   libcam->cam_shutter_setMode(state);
//   if( state == ICamera::ShutterOpened) {
//      libcam->cam_shutter_off();
//   } else {
//      libcam->cam_shutter_on();
//   }
//}

void CCamera::setShutterClosed() {
   m_libcam->cam_shutter_close();
}

void CCamera::setShutterOpened() {
   m_libcam->cam_shutter_open();
}

void CCamera::setShutterSyncho() {
   m_libcam->cam_shutter_synchro();
}


bool CCamera::getStopMode() {
   return m_stopMode;
}

/** configure le mode d'acquisition apres une commande stop 
* 0= ne pas lire le CCD (abort exposure) 
* 1= lire le CCD
*/
void CCamera::setStopMode(bool stopMode) {
   this->m_stopMode = stopMode;
}

void CCamera::stopExposure() {
   // j'envoie la commande d'arret à la camera
   if (m_stopMode == 0 ) {
      m_libcam->cam_exposure_abort();
   } else {
      m_libcam->cam_exposure_stop();
   }
   // j'envoie le signal d'arret au thread d'acquisition
   m_acqCv.notify_all();
}

ITelescope* CCamera::getTelescope() {
   return m_telescope;
}
   
void CCamera::setTelescope(ITelescope* telescope) {
   this->m_telescope = telescope;
}

/**
 * get acquistion Timer ellaspe (in seconds)
 * return -1 if thre is no acquisition. 
 */ 
int CCamera::getTimer(bool countDown) {
   if (m_acquisitionStatus == AcquisitionExp) {
      struct timeval nowTimeVal;    
      gettimeofday(&nowTimeVal, NULL);
      int sec = nowTimeVal.tv_sec - this->m_clockbegin;
      if (countDown == true) {
         sec = (int) (m_libcam->cam_exptime_get() ) - sec;
      }
      return sec;
   } else {
      return -1;
   }
}

/**
 * get window size (in pixels , 1 based)
 */ 
void CCamera::getWindow(int* x1, int* y1, int* x2, int* y2) {
   m_libcam->cam_window_get(x1, y1, x2, y2);
}

/**
 * set window size (in pixels , 1 based)
 */ 
void CCamera::setWindow(int x1, int y1, int x2, int y2) {
   m_libcam->cam_window_set(x1, y1, x2, y2);
   m_libcam->cam_update_window();
}

//-----------------------------------------------------------------------------
// private 
//-----------------------------------------------------------------------------

void CCamera::setCameraStatus(AcquisitionStatus acquisitionStatus) {
   if (m_statusCallback != NULL) {
      m_statusCallback(callbackClientData, acquisitionStatus);
   }
}

//-----------------------------------------------------------------------------
// getAvailableCamera 
//-----------------------------------------------------------------------------
abcommon::CStructArray<abcommon::SAvailable*>*  CCamera::getAvailableCamera(const char* librayPath, const char * libraryFileName) {
      
   // je charge la librairie
   std::string fullFileName;
   fullFileName.append(librayPath).append(PATH_SEPARATOR).append(libraryFileName);
   lt_dlinit();
   lt_dlhandle lh = lt_dlopenext (fullFileName.c_str() );
   if( lh == NULL) {
      lt_dlexit ();
      throw CError(CError::ErrorGeneric, "CCamera::getAvailableCamera error : %s not found . lt_dlopenext error=%s", fullFileName.c_str(), lt_dlerror());
   };
   
   // je recupere le pointeurs des fonctions
   libcam::getAvailableDeviceFunc getAvailableDevice = (libcam::getAvailableDeviceFunc) lt_dlsym (lh, "getAvailableCamera");
   if( getAvailableDevice == NULL ) {
      lt_dlclose (lh);
      lt_dlexit ();
      throw CError(CError::ErrorGeneric, "CCamera::getAvailableCamera error : getAvailableCamera not found in %s . lt_dlsym error=%s", fullFileName.c_str(), lt_dlerror());
   }; 
      
   // je recupere les noms des cameras disponibles
   abcommon::CStructArray<abcommon::SAvailable*>* availableList = new CStructArray<abcommon::SAvailable*>();
   try {
      abcommon::CStructArray<abcommon::SAvailable*>* camLib = getAvailableDevice();
      // je copie camLib dans cameras
      for (int i = 0; i < camLib->size(); i++) {
         availableList->append(new SAvailable(camLib->atType(i)->getId(), camLib->atType(i)->getName()));
      }
      IArray_deleteInstance(camLib);
            
   } catch (IError& error) {
      lt_dlclose (lh);
      lt_dlexit ();
      throw CError(CError::ErrorGeneric, error.getMessage());  
   }

   lt_dlclose (lh);
   lt_dlexit ();

   return availableList;
}

/*
 * libcam_GetCurrentFITSDate(char s[23])
 *  retourne la date TU avec le 1/1000 de seconde
 *
 */
void CCamera::libcam_GetCurrentFITSDate(char *s)
{
    char message[50];
    struct timeval currentTime;
    gettimeofday (&currentTime, NULL);  // retourne la date GMT
    time_t seconds = currentTime.tv_sec;
    strftime (message, sizeof(message)-1, "%Y-%m-%dT%H:%M:%S", gmtime(&seconds));
    sprintf (s, "%s.%03d", message, (int)(currentTime.tv_usec/1000));
}


// cameras Pool 
abcommon::CPool  cameraPool;

// factory & pool management
abaudela::ICamera*  abaudela::ICamera::createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]) throw(abcommon::IError) {
   CCamera* camera = new CCamera();
   camera->init(libraryPath, libraryFileName, argc , argv ); 
   cameraPool.add(camera);
   return camera;
}

void abaudela::ICamera::deleteInstance(abaudela::ICamera* camera) {
   cameraPool.remove(camera);
   delete camera;
}

abaudela::ICamera* abaudela::ICamera::getInstance(int cameraNo) {
   return (abaudela::ICamera*) cameraPool.getInstance(cameraNo);
}

int abaudela::ICamera::getInstanceNo(abaudela::ICamera* camera) {
   return cameraPool.getInstanceNo(camera);
}

abcommon::IIntArray* abaudela::ICamera::getIntanceNoList() {
   return cameraPool.getIntanceNoList();
}

abcommon::IStructArray* abaudela::ICamera::getAvailableCamera(const char* librayPath, const char * libraryFileName) {
   return CCamera::getAvailableCamera(librayPath, libraryFileName);
}
