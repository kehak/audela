/* CCamera.h
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
#pragma once

#include <string>
#include <condition_variable>
#include <mutex>

#include <abaudela.h>


#include "libcamab/libcam.h" // pour ILibcam
#include "CLibraryLoader.h"

class CCamera : public ICamera {

public:
   CCamera();
   ~CCamera();
   void     init(const char* librayPath, const char * libraryFileName, int argc, const char *argv[])  throw (abcommon::IError);
   void     acq();
   void     getBinning(int* binx, int* bin); 
   void     setBinning(int binx, int biny);
   void     getBinningMax(int* binMaxX, int* binMaxY);
   IBuffer* getBuffer();
   void     setBuffer(IBuffer* buffer);
   bool     getCapability(Capability capability);
   int      getCamNo();
   const char* getCcd();
   void     getCellDim(double* celldimx, double* celldimy);
   void     getCellNb(int* cellx, int* celly);
   bool     getCooler();
   void     setCooler(bool on);
   double   getCoolerCheckTemperature();
   void     setCoolerCheckTemperature(double temperature);
   double   getCoolerCcdTemperature();
   int      getDebug();
   void     setDebug(int debug);
   const char* getDriverName();

   int      executeSpecificCommand(char** result, int argc, const char *argv[]);
   void     freeSpecificCommandResult();
   int      executeTclSpecificCommand(void* interp, int argc, const char *argv[]);
   double   getExptime(); 
   void     setExptime(double exptime);
   double   getFillFactor();
   //double   getFocLen(); 
   //void     setFocLen(double focLen);
   double   getGain();

   const char* getLibraryName(void);
   double      getMaxDyn();
   bool        getMirrorH();
   void        setMirrorH(bool mirror);
   bool        getMirrorV();
   void        setMirrorV(bool mirror);
   const char* getCameraName();
   void        getPixNb(int* pixx, int* pixy); 
   bool        getOverScan();
   void        setOverScan(bool overScan);
   void        getPixDim(double* dimx, double* dimy);
   const char* getPortName();
   const char* getProduct();
   bool        getRadecFromTel();
   void        setRadecFromTel(bool radecFromTel);
   double      getReadNoise();
   int         getRgb();
   ShutterMode getShutterMode(); 
   //void     setShutterMode(ShutterMode mode);
   void        setShutterClosed();
   void        setShutterOpened();
   void        setShutterSyncho();
   bool         getStopMode();
   void        setStopMode(bool stopMode);
   void        stopExposure();
   ITelescope*  getTelescope();
   void        setTelescope(ITelescope* telescope);
   int         getTimer(bool countDown);
   void        getWindow(int* x1, int* y1, int* x2, int* y2);
   void        setWindow(int x1, int y1, int x2, int y2);
   
   //static void callback(int camno, int code, double value1, double value2, char * message);
   void     setSatusCallback(void *clientData, CameraStatusCallbackType cameraCallback);
   void *   callbackClientData;
   
   static abcommon::CStructArray<abcommon::SAvailable*>*  getAvailableCamera(const char* librayPath, const char * libraryFileName);

   
private:
   //std::string libraryName;
   //lt_dlhandle lh;
   //libcam::DeleteCameraFunc Libcam_deleteCamera;
   std::condition_variable m_acqCv;
   std::mutex              m_acqMutex;
   AcquisitionStatus       m_acquisitionStatus;
   libcam::ILibcam*        m_libcam;
   CLibraryLoader<libcam::ILibcam*> m_libraryLoader;
   CLogger                 m_log;
   CameraStatusCallbackType m_statusCallback;

   
   int      m_mode_stop_acq; 
   char     m_date_obs[30];
   char     m_date_end[30];
   //char pixels_classe[60]; 
   //char pixels_format[60]; 
   //char pixels_compression[60]; 
   int         m_gps_date;
   bool        m_radecFromTel;
   IBuffer*    m_buffer;
   ITelescope* m_telescope;


   // acquisition timer
   void acqReadThread();
   void readCCD();
   void libcam_GetCurrentFITSDate(char *s);

   double         m_exptimeTimer; 
   unsigned long  m_clockbegin;
   bool            m_stopMode;  // false= ne pas lire le CCD (abort exposure)  , true lire le CCD 

   void setCameraStatus(AcquisitionStatus acquisitionStatus);
         
};

