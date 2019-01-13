/* libcam.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujols
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
#include <string>                 // std::string
#include <vector>           
#include <utility>            // std::pair
#include "sysexp.h"
#include <libcamab/libcam.h>

#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4

struct Capabilities {
   bool expTimeCommand;     // existence de la commande de choix du temps de pose 
   bool expTimeList;        // existence d'une liste predefinie des temps de pose
   bool shutter;           // shutter available 
   bool videoMode;          // existence du mode video
};

struct camini {
    /* --- variables communes privees constantes --- */
    char name[256];
    char product[256];
    char ccd[256];
    int maxx;
    int maxy;
    int overscanxbeg;
    int overscanxend;
    int overscanybeg;
    int overscanyend;
    double celldimx;
    double celldimy;
    double maxconvert;
    double fillfactor;
    /* --- variables communes publiques parametrables depuis Tcl --- */
    double gain;
    double readnoise;
    int binx;
    int biny;
    double exptime;
    int shutterindex;
    int portindex;
    int coolerindex;
    double check_temperature;
    char rgbindex;
    bool overscanindex;
    double foclen;
};

#define CAM_INI_NULL \
   {"",          /* camera name */ \
    "",          /* camera model */ \
    "",          /* ccd name */ \
    1536,1024,   /* maxx maxy */ \
    14,14,       /* overscans x */ \
    4,4,         /* overscans y*/ \
    9e-6,9e-6,   /* photosite dim (m) */ \
    32767.,      /* observed saturation */ \
    1.,          /* filling factor */ \
    11.,         /* gain (e/adu) */ \
    11.,         /* readnoise (e) */ \
    1,1,         /* default bin x,y */ \
    1.,          /* default exptime */ \
    1,           /* default state of shutter (1=synchro) */ \
    0,           /* default port index (0=lpt1) */ \
    1,           /* default cooler index (1=on) */ \
    -15.,        /* default value for temperature checked */ \
    1,           /* default color mask if exists (1=cfa) */ \
    0,           /* default overscan taken in acquisition (0=no) */ \
    1.           /* default focal lenght of front optic system */ \
   }


//-----------------------------------------------------------------------------
// CLibcamCommon declaration
//-----------------------------------------------------------------------------
class CLibcamCommon : public libcam::ILibcam {

public:
   static ILibcam* createCameraInstance(CLibcamCommon *, int argc, const char *argv[]);
   virtual void cam_init(int argc, const char **argv)=0;
   virtual void cam_close()=0;
   virtual void cam_update_window()=0;

   void cam_exposure_abort() {
      throw abcommon::CError(abcommon::CError::ErrorGeneric, "cam_exposure_abort not implemented");
   }
   
   virtual void cam_exposure_start()=0;
   virtual void cam_exposure_stop()=0;
   virtual void cam_exposure_readCCD(float *p)=0;

   /**
   * common contructor
   */ 
   CLibcamCommon();

   /// common destructor 
   // 
   void releaseInstance();
   
   // common virtual destructor (require by linux
   virtual ~CLibcamCommon(){};
   
   static const char *cam_shutters[];

   void cam_init_common(int argc, const char *argv[]);

   void cam_binning_get(int* binx, int* biny);
   void cam_binning_set(int binx, int biny);
   /**
   * get max binning 
   */ 
   void cam_binningMax_get(int* binMaxX, int* binMaxY);

   /**
   * get capabilities
   */ 
   bool cam_capability_get(Capability capability);

   /**
   * get CCD name
   */ 
   const char* cam_ccdName_get();
   /**
   * get CCD cell dimension
   */ 
   void cam_cellDim_get(double* celldimx, double* celldimy);

   ///**
   //* set CCD cell dimension
   //*/ 
   //void cam_cellDim_set(double celldimx, double celldimy);



   /**
   * get cooler check temperature (in C°)
   */ 
   double   cam_cooler_checkTemperature_get() {
   	return 0;
   }

   /**
   * set cooler check temperature (in C°)
   */ 
   void     cam_cooler_checkTemperature_set(double temperature) {
   
   }

   /**
   * get cooler Ccd temperature (in C°)
   */ 
   double   cam_cooler_ccdTemperature_get() {
   	return 0;
   }

   virtual bool     cam_cooler_get() = 0;
   virtual void     cam_cooler_set(bool on) = 0;


   /**
   * get debug level ( 0 , 1, 2, 3, 4)
   */ 
   int cam_logLevel_get();
   
   /**
   * set debug level ( 0 , 1, 2, 3, 4)
   */ 
   void cam_logLevel_set(int debug);

   /**
   * get exptime (in seconds)
   */ 
   double cam_exptime_get();

   /**
   * set exptime (in seconds)
   */ 
   void cam_exptime_set(double exptime);

   
   /**
   * get height (in pixel)
   */ 
   int cam_exposure_height_get();

   /**
   * get plane (1= grey image , 3= RGB image)
   */ 
   int cam_exposure_plane_get();

   /**
   * get width (in pixel)
   */ 
   int cam_exposure_width_get();

   /**
   * get fill factor 
   */ 
   double cam_fillFactor_get();

  
   /**
   * get gain 
   */ 
   double cam_gain_get();


   /**
   * get GPS date (0 or 1)
   */ 
   int cam_GPSDate_get();

   /**
   * set GPS date (0 or 1)
   */ 
   void cam_GPSDate_set(int gpsDate);

   /**
   * get camera max dynamic
   */ 
   double cam_dynamic_get();


   ///**
   //* get interrupt (0 or 1)
   //*/ 
   //int getInterrupt();

   ///**
   //* set interrupt (0 or 1)
   //*/ 
   //void setInterrupt(int interrupt);

   char* getMessage();

   /**
   * set message
   */ 
   void setMessage(char *message);

   /**
   * get mirror H (0 or 1)
   */ 
   bool cam_mirrorH_get();

   /**
   * set mirror H (0 or 1)
   */ 
   void cam_mirrorH_set(bool mirrorh);

   /**
   * get mirror V (0 or 1)
   */ 
   bool cam_mirrorV_get();

   /**
   * set mirror V (0 or 1)
   */ 
   void cam_mirrorV_set(bool mirrorv);

   /**
   * get camera name
   */ 
   const char* cam_cameraName_get();

   /**
   * get call number 
   */ 
   void  cam_cell_nb_get(int* cellx, int* celly);
   
   /**
   * get pix dimension ( in micron)
   */ 
   void  cam_pix_dim_get(double* dimx, double* dimy);

   /**
   * get pix number i.e = nb cell / binning
   */ 
   void  cam_pix_nb_get(int* pixx, int* pixy);

   /**
   * get overscan (O, 1)
   */ 
   bool cam_overScan_get();

   /**
   * set over scan   (O, 1)
   */ 
   void cam_overScan_set(bool overScan);

   /**
   * get camera port name
   */ 
   const char* cam_portName_get();

   /**
   * get camera product name
   */ 
   const char* cam_product_get();

   /**
   * get camera read noise
   */ 
   double cam_readNoise_get();

   /**
   * get camera rgb index 
   */ 
   int cam_rgb_get();


   /**
   * get shutter mode (0=closed 1=syncho 2=opened)
   */ 
   ShutterMode cam_shutter_get();

   ///**
   //* set shutter state (0=closed 1=syncho 2=opened)
   //*/ 
   //void cam_shutter_setMode(int state);

   /**
   * close shutter . Shutter will be always cloased
   */ 
   void cam_shutter_close();

   /**
   * open shutter . Shutter will be always opened
   */ 
   void cam_shutter_open();

   /**
   * syncho shutter. shutter will be synchonized with exposure
   */ 
   void cam_shutter_synchro();

   /**
   * get window size (in pixels , 1 based)
   */ 
   void cam_window_get(int* x1, int* y1, int* x2, int* y2);

   /**
   * set window size (in pixels , 1 based)
   */ 
   void cam_window_set(int x1, int y1, int x2, int y2);


   /**
   * executeSpecificCommand
   * @param argv  argv[0]=cam1  argv[1]=command name , argv[2...]= command parameters
   * @param specificCommandResult   command result 
   *
   * @return  0=OK  1=ERROR  -1= command not found
   */ 
   int cam_specificCommand_execute(char** specificCommandResult, int argc, const char *argv[]);
   int cam_specificCommand_execute_tcl(void * interp, int argc, const char *argv[]);
   void cam_specificCommand_freeResult();
   void Spec_SetResult(char * result);
   
   // log  declaration 
   char msg[4096];

protected : 
   static struct camini CAM_INI[];
   int authorized;
   double foclen;
   float exptime;
   float exptimeTimer;
   int binx, biny;
   int m_binMaxX, m_binMaxY;
   int x1, y1, x2, y2;
   int w, h;
   int plane;
   bool mirrorh;
   bool mirrorv;
   unsigned short port;
   int portindex;
   std::string portname;
   //char headerproc[1024];
   ShutterMode shutterindex;
   int coolerindex;
   int index_cam;
   double celldimx;
   double celldimy;
   double fillfactor;
   double temperature;
   double check_temperature;
   int rgbindex;
   bool overscanindex;
   int nb_deadbeginphotox;
   int nb_deadendphotox;
   int nb_deadbeginphotoy;
   int nb_deadendphotoy;
   int nb_photox;
   int nb_photoy;
   int interrupt;
   char date_obs[30];
   char date_end[30];
   int  gps_date;
   unsigned long clockbegin;
   unsigned long pixel_size; 
   struct Capabilities capabilities; 
   int mode_stop_acq; 

   //-----------------------------------------------------------------------------
   //  specific command
   //-----------------------------------------------------------------------------
   char * SpecificResult;


   abcommon::CLogger m_logger;

};


//-----------------------------------------------------------------------------
// specific function prototype
//-----------------------------------------------------------------------------
typedef int (Spec_CmdProc) (CLibcamCommon* cam, int argc, const char *argv[]);

extern struct cmditemSpec specificCmdList[];

struct cmditemSpec {
    const char *cmd;
    Spec_CmdProc *func;
};

#define SPEC_OK 0
#define SPEC_ERROR 1
void Spec_SetResult(char * result);




