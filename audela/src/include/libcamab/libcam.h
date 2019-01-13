/* libcam.h
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

//=============================================================================
// export directive and import directive
//=============================================================================
#ifdef _WIN32
#if defined(LIBCAM_EXPORTS) // inside DLL
#   define LIBCAM_API   __declspec(dllexport)
#else                       // outside DLL
#   define LIBCAM_API   __declspec(dllimport)
#endif 

#else 

#if defined(LIBCAM_EXPORTS) // inside DLL
#   define LIBCAM_API   __attribute__((visibility ("default")))
#else                       // outside DLL
#   define LIBCAM_API 
#endif 

#endif

#include <abcommon.h>

//#ifdef _WIN32
////  C4290 : C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
//#pragma warning( disable : 4290 )
//#endif

namespace libcam {

   //--------------------------------------------------------------------------------------
   // class ILibcam
   //--------------------------------------------------------------------------------------
   class ILibcam {

   public:
      enum ShutterMode { SHUTTER_CLOSED, SHUTTER_OPEN, SHUTTER_SYNCHRO };
      enum Capability { Shutter, ExpTimeCommand, ExpTimeList, VideoMode } ;
      
      virtual void releaseInstance(){};
      virtual ~ILibcam(){};

      virtual void         cam_binning_get(int* binx, int* biny)=0;
      virtual void         cam_binning_set(int binx, int biny)=0;
      virtual void         cam_binningMax_get(int* binx, int* biny)=0;
   	
      virtual  const char* cam_cameraName_get()=0;
      virtual  bool        cam_capability_get(Capability capability)=0;
      virtual  const char* cam_ccdName_get()=0;
      virtual  void        cam_cellDim_get(double* celldimx, double* celldimy)=0; 
      //virtual  void      cam_cellDim_set(double celldimx, double celldimy)=0;
      virtual  double      cam_cooler_checkTemperature_get()=0;
      virtual  void        cam_cooler_checkTemperature_set(double temperature)=0;
      virtual  double      cam_cooler_ccdTemperature_get()=0;
	   virtual  bool        cam_cooler_get()=0;
	   virtual  void        cam_cooler_set(bool on)=0;
	   //virtual  void      cam_cooler_check()=0;
      //virtual void       cam_temperature_measure()=0;

      virtual void         cam_exposure_abort()=0;
	   //virtual int       cam_exposure_stopMode_get()=0;
      //virtual void      cam_exposure_stopMode_set(int stopMode)=0; 
      //virtual void      cam_exposure_freePixels(float* pixels)=0;
      virtual void         cam_exposure_start()=0;
	   virtual void         cam_exposure_stop()=0;
	   virtual void         cam_exposure_readCCD(float *p)=0;

      virtual  int         cam_exposure_height_get()=0;
      virtual  int         cam_exposure_width_get()=0;
      virtual  int         cam_exposure_plane_get()=0;
      
      
      virtual  double      cam_exptime_get()=0;
      virtual  void        cam_exptime_set(double exptime)=0;
      
      virtual  int         cam_specificCommand_execute(char** specificCommandResult, int argc, const char *argv[])=0;
      virtual  int         cam_specificCommand_execute_tcl(void * interp, int argc, const char *argv[])=0;
      virtual  void        cam_specificCommand_freeResult()=0;
      
      virtual  double      cam_fillFactor_get()=0;
      //virtual  double    cam_focLen_get()=0;
      //virtual  void      cam_focLen_set(double focLen)=0;
      virtual  double      cam_gain_get()=0;
      virtual  int         cam_GPSDate_get()=0;
      virtual  void        cam_GPSDate_set(int gpsDate)=0;

      virtual  double      cam_dynamic_get()=0;
      //virtual  int      getInterrupt()=0;
      //virtual  void     setInterrupt(int interrupt)=0;

      virtual  int         cam_logLevel_get()=0;
      virtual  void        cam_logLevel_set(int debug)=0;

      virtual  bool        cam_mirrorH_get()=0;
      virtual  void        cam_mirrorH_set(bool mirrorh)=0;
      virtual  bool        cam_mirrorV_get()=0;
      virtual  void        cam_mirrorV_set(bool mirrorv)=0;

      virtual  void        cam_cell_nb_get(int* cellx, int* celly)=0; 
      virtual  void        cam_pix_dim_get(double* dimx, double* dimy)=0;
      virtual  void        cam_pix_nb_get(int* pixx, int* pixy)=0; 
      virtual  bool        cam_overScan_get()=0;
      virtual  void        cam_overScan_set(bool overScan)=0;
      virtual  const char* cam_portName_get()=0;
      virtual  const char* cam_product_get()=0;
      virtual  double      cam_readNoise_get()=0;
      virtual  int         cam_rgb_get()=0;
      
      virtual  ShutterMode cam_shutter_get()=0;
      //virtual  void      cam_shutter_setMode(int mode)=0; 
      virtual void         cam_shutter_close()=0;
	   virtual void         cam_shutter_open()=0;
      virtual void         cam_shutter_synchro()=0;
      	
      //virtual  int       getStopExposureMode()=0;
      //virtual  void      setStopExposureMode(int mode)=0;

      virtual  void        cam_window_get(int* x1, int* y1, int* x2, int* y2)=0;
      virtual  void        cam_window_set(int x1, int y1, int x2, int y2)=0;
      virtual  void        cam_update_window()=0;
      // error message
      virtual  char*       getMessage()=0;
      virtual  void        setMessage(char *message)=0;

   };

   //--------------------------------------------------------------------------------------
   // external and internal definitions for camera library 
   //--------------------------------------------------------------------------------------

   // unique fonction exportee explicitement
   extern "C" LIBCAM_API ILibcam*   createCameraInstance(int argc, const char *argv[]);
   extern "C" LIBCAM_API abcommon::CStructArray<abcommon::SAvailable*>* getAvailableCamera();

   // declarations pour le chargement dynamique de la librairie
   //typedef ILibcam*  (* CreateCameraFunc)(int argc, const char *argv[]);
   typedef abcommon::CStructArray<abcommon::SAvailable*>* (* getAvailableDeviceFunc)();

} // end namespace
