/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>

#if defined(OS_WIN)
#include <windows.h>
#include <tchar.h>
#include "CaptureWinVfw.h"
#include "CropCapture.h"
#ifdef LIBWEBCAM_WITH_DIRECTX
#include "CaptureWinDirectx.h"
#endif // LIBWEBCAM_WITH_DIRECTX
#endif // OS_WIN

#if defined(OS_LIN)
#include "CaptureLinux.h"
#endif // OS_LIN

#include <libcam/util.h>
#include <libcam/libcam.h>
#include "camera.h"

// definition STRNCPY : copie de chaine avec protection contre les debordements
#define STRNCPY(_d,_s)  strncpy(_d,_s,sizeof _d) ; _d[sizeof _d-1] = 0

/**
 * Definition of different cameras supported by this driver
 * (see declaration in libstruc.h)
 */
#ifdef __cplusplus
extern "C" {
#endif

struct camini CAM_INI[] = {
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX098BQ-A",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    5.6e-6, 5.6e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX098BL-6",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    5.6e-6, 5.6e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX424AL-6",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    7.4e-6, 7.4e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
   {"WEBCAM",        /* camera name */
    "webcam",        /* camera product */
    "ICX414AL-6",        /* ccd name */
    640, 480,        /* maxx maxy */
    0, 0,            /* overscans x */
    0, 0,            /* overscans y*/
    9.9e-6, 9.9e-6,        /* photosite dim (m) */
    255.,            /* observed saturation */
    1.,              /* filling factor */
    250.,            /* gain (e/adu) */
    250.,            /* readnoise (e) */
    1, 1,            /* default bin x,y */
    1.,              /* default exptime */
    1,               /* default state of shutter (1=synchro) */
    0,               /* default port index (0=lpt1) */
    1,               /* default cooler index (1=on) */
    -15.,            /* default value for temperature checked */
    5,               /* default color mask if exists (1=cfa 2=rgb) */
    0,               /* default overscan taken in acquisition (0=no) */
    1.               /* default focal lenght of front optic system */
    },
     CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop *cam);
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
   CCapture *capture;
   CCaptureListener *captureListener;
#if defined(OS_WIN)
   CCropCapture     *cropCapture;
#endif //OS_WIN

};

#ifdef __cplusplus
}
#endif

#if defined(OS_WIN)
#pragma pack (1)
#endif //OS_WIN

// Fonctions de trace

#define LOG_NONE    0
#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4
int webcam_debug_level = LOG_INFO;

#include <time.h>
#include <sys/timeb.h>          /* ftime, struct timebuffer */

extern char *getlogdate(char *buf, size_t size);

#define DEFAULT_LOG_FILE "/tmp/libgrabber.log"
char log_file[2048];

void webcam_log(int level, const char *fmt, ...)
{
   FILE *f;
   char buf[100];

   va_list mkr;
   va_start(mkr, fmt);

   if (level <= webcam_debug_level) {
      getlogdate(buf,100);
      f = fopen( log_file, "a+" );
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
      fflush( f );
      vfprintf(f,fmt, mkr);
      fprintf(f,"\n");
      va_end(mkr);
      fclose(f);
   }

}

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

/*
 *  Usage acquisition :
 *  - cam::create webcam usb -channel 0...10  -format  large ou small
 *  - cam1 adjust
 *  - cam1 snap
 *  - cam::delete 1
*/

/**
 * cam_init
 * - cam_init permet d'initialiser les variables de la
 * - structure 'camprop'
 * - specifiques a cette camera.
 *
 * cam_init
 *  - cam_init initialize variables of structure "camprop" specified
 *  for this camera.
 * - under Linux it opens webcam and parallel port
 * - sets image format on 640 x 480 (max for this camera).
 *
*/
int cam_init(struct camprop *cam, int argc, const char **argv)
{
    char formatname[128];
    int  validFrame = -1;
    char videomode [128];
    int kk;

    // j'active les traces de libcam

    strcpy( log_file, DEFAULT_LOG_FILE );
    webcam_log( LOG_INFO, "Libgrabber library compiled on %s at %s", __DATE__, __TIME__ );
    webcam_log( LOG_DEBUG,"cam_init begin ===============");

    strcpy(videomode, "vfw");
    strcpy(formatname, "SIF");
    strcpy(formatname, "VGA");
    cam->longuepose = 0;
    cam->longueposelinkno = 0;
    strcpy(cam->longueposelinkbit,"");
    cam->longueposestart = 0;
    cam->sensorColor = 1;
    cam->videoStatusVarNamePtr[0] = 0;
    cam->videoEndCaptureCommandPtr[0] = 0;
    cam->capabilities.videoMode = 1;
    cam->params = (PrivateParams*)malloc(sizeof(PrivateParams));


    // je decode les options de cam::create
    if (argc >= 5) {
        for (kk = 3; kk < argc - 1; kk++) {
            if (strcmp(argv[kk], "-channel") == 0) {
                cam->driver = atoi(argv[kk + 1]);
            }
            if (strcmp(argv[kk], "-format") == 0) {
                strcpy(formatname, argv[kk + 1]);
            }
            if ( strcmp( argv[kk], "-debug_directory" ) == 0 ) {
                sprintf( log_file, "%s/libgrabber.log", argv[kk + 1] );
                rename(DEFAULT_LOG_FILE, log_file);
                webcam_log( LOG_INFO, "%s : %s", argv[kk], argv[kk + 1] );
            }
            if (strcmp(argv[kk], "-videomode") == 0) {
                strcpy(videomode, argv[kk + 1]);
            }
            if (strcmp(argv[kk], "-longuepose") == 0) {
                cam->longuepose = atoi(argv[kk + 1]);
            }
            if (strcmp(argv[kk], "-longueposelinkno") == 0) {
                cam->longueposelinkno = atoi(argv[kk + 1]);
            }
            if (strcmp(argv[kk], "-longueposelinkbit") == 0) {
                STRNCPY(cam->longueposelinkbit, argv[kk + 1]);
            }
            if (strcmp(argv[kk], "-longueposestart") == 0) {
                cam->longueposestart = atoi(argv[kk + 1]);
            }
            if (strcmp(argv[kk], "-validframe") == 0) {
                validFrame = atoi(argv[kk + 1]);
                if (validFrame < 0) {
                    sprintf(cam->msg,                      "-validFrame=%d invalid parameter, must be integer >= 0", validFrame);
                    webcam_log(LOG_DEBUG,"cam_init error: %s",cam->msg);
                    return 1;
                }
            }
            if (strcmp(argv[kk], "-sensorcolor") == 0) {
                if ( strcmp(argv[kk + 1],"0")==0 || strcmp(argv[kk + 1],"1")==0 ) {
                    cam->sensorColor = atoi(argv[kk + 1]);
                } else {
                    //--- je renseigne le message d'erreur
                    strcpy(cam->msg, "-sensorcolor invalide parameter, must be : 1=color or 0=black and white");
                    webcam_log(LOG_DEBUG,"cam_init error: %s",cam->msg);
                    return 1;
                }
            }
        }
    }

   // je charge le driver
#if defined(OS_WIN)
   // WINDOWS :
    if ( strcmp(videomode,"vfw") == 0 ) {
        cam->params->capture = new CCaptureWinVfw();
        cam->params->cropCapture = NULL;
    } else {
#ifdef LIBWEBCAM_WITH_DIRECTX
        cam->params->capture = new CCaptureWinDirectx();
        std::list<std::string> deviceList;
        std::list<std::string>::iterator iterator;
        BOOL result = ((CCaptureWinDirectx*) cam->params->capture)->getDeviceList(&deviceList, cam->msg);
        if ( result == TRUE ) {
            sprintf(cam->msg, "{ " );
            for ( iterator =  deviceList.begin(); iterator != deviceList.end(); ++iterator ) {
                char camName[256];
                sprintf( camName, "{%s}", iterator->c_str() );
                strcat( cam->msg, camName );
            }
            strcat( cam->msg, " }" );
            deviceList.clear();
            return 1;
        } else {
            return 1;
        }
#else // LIBWEBCAM_WITH_DIRECTX
        strcpy(cam->msg, "directx is not available.");
        webcam_log(LOG_DEBUG,"cam_init error: %s",cam->msg);
        return 1;
#endif // OS_WIN
    }
#else
   // LINUX
    cam->params->capture = new CCaptureLinux(cam->portname);
#endif // ! OS_WIN

   if (cam->params->capture == NULL) {
      strcpy(cam->msg, "capture is a null pointer. Video not initialized.");
      webcam_log( LOG_DEBUG,"cam_init error: %s",cam->msg );
      return 3;
   }

   // j'active le driver
   cam->params->captureListener = new CCaptureListener(cam->interp, cam->camno);
   if ( cam->params->capture->initHardware( cam->driver, cam->params->captureListener, cam->msg ) == FALSE ) {
      webcam_log(LOG_DEBUG,"cam_init initHardware error:  %s",cam->msg);
      cam_close(cam);
      return 4;
   }
   // je connecte le stream video
   if (cam->params->capture->connect(cam->longuepose, cam->driver,cam->msg) == FALSE) {
      webcam_log(LOG_DEBUG,"cam_init connect error:  %s",cam->msg);
      cam_close(cam);
      return 4;
   }

   // j'applique le format video
   if ( cam->params->capture->setVideoFormat(formatname, cam->msg) == FALSE ) {
      webcam_log(LOG_DEBUG,"cam_init setVideoFormat error:  %s",cam->msg);
      cam_close(cam);
      return 5;
   }

   cam->nb_photox = (int) cam->params->capture->getImageWidth();
   cam->nb_photoy = (int) cam->params->capture->getImageHeight();
   cam->binx = 1;
   cam->biny = 1;
   cam->imax = cam->nb_photox / cam->binx;
   cam->jmax = cam->nb_photoy / cam->biny;
    strcpy(cam->convertbw,"none");

   // je descative la capture audio
   cam->params->capture->setCaptureAudio(FALSE);

   if ( validFrame != -1 ) {
      if ( cam->params->capture->setVideoParameter(validFrame, SETVALIDFRAME, cam->msg) == FALSE ) {
         webcam_log(LOG_DEBUG,"cam_init error: %s",cam->msg);
         cam_close(cam);
         return 6;
      }
   }

   cam_update_window(cam);

   if (strlen(cam->msg) == 0) {
      webcam_log(LOG_DEBUG,"cam_init end OK");
   } else {
      webcam_log(LOG_DEBUG,"cam_init error: %s",cam->msg);
   }

   return 0;
}



/**
 *----------------------------------------------------------------------
 * cam_close
 *   ferme la camera
 *
 * Parameters:
 *    cam       : Largeur en pixels
 * Results:
 *    TCL_OK.
 * Side effects:
 *    libere les ressources de la camera
 *----------------------------------------------------------------------
 */

int cam_close(struct camprop *cam)
{
    webcam_log(LOG_DEBUG,"cam_close begin");
    if ( cam->params->capture != 0 ) {
        delete cam->params->capture;
        cam->params->capture = 0;
    }

    if ( cam->params->captureListener != 0 ) {
        delete cam->params->captureListener;
        cam->params->captureListener = 0;
    }


    if( cam->params != 0 ) {
        free( cam->params );
        cam->params = 0;
    }

    webcam_log(LOG_DEBUG,"cam_close end OK");
    return TCL_OK;
}


/**
 *----------------------------------------------------------------------
 * webcam_setConnectionState
 *   ouvre ou ferme le flux video
 *
 * Parameters:
 *    cam       : camera
 *    state     : TRUE=connecter , FALSE=deconnecter
 * Results:
 *    TCL_OK.
 * Side effects:
 *    ouvre ou ferme le flux video
 *----------------------------------------------------------------------
 */

int webcam_setConnectionState(struct camprop *cam, BOOL state) {
   int result;

   if (cam->params->capture != NULL) {
      if ( state == TRUE ) {
         result = cam->params->capture->connect(cam->longuepose, cam->driver,cam->msg);
      } else {
         result = cam->params->capture->disconnect(cam->msg);
      }
   } else {
      result = TRUE;
   }

   if ( result == TRUE ) {
      return TCL_OK;
   } else {
      return TCL_ERROR;
   }
}

/**
 *----------------------------------------------------------------------
 * webcam_getConnectionState
 *   retourne l'etat de la connexion
 *
 * Parameters:
 *    cam       : camera
 *    state     : TRUE=connecter , FALSE=deconnecter
 * Results:
 *    TCL_OK.
 * Side effects:
 *    ouvre ou ferme le flux video
 *----------------------------------------------------------------------
 */

int webcam_getConnectionState(struct camprop *cam, BOOL *pstate) {
    int result;

    if (cam->params->capture != NULL) {
        *pstate = cam->params->capture->isConnected();
        result = TCL_OK;
    }
    else {
        result = TCL_ERROR;
    }
    return result;
}


/**
 * Function cam_start_exp - starts the exposure.
 * Called by command "acq" (function: cmdCamAcq),
 * after <b>exptime</b> TCL calls cam_read_ccd (function: AcqRead).
 *
 * "acq" -> cmdCamAcq -> cam_start_exp ...
 *
 * -> AcqRead -> cam_read_ccd
 *
 * or
 *
 * "stop" -> cmdCamStop -> AcqRead -> cam_read_ccd.
 *
 * should return a value???
*/
void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
    webcam_log(LOG_DEBUG,"cam_start_exp begin exptime=%d", cam->exptime);
    /*
    if ( cam->exptime == 0 ) {
        libcam_sleep(50);
    }
    */
    if (cam->longuepose == 1) {
        //long exposure
        if (webcam_setLongExposureDevice(cam, cam->longueposestart)) {
         //error description in cam->msg
            webcam_log(LOG_DEBUG,"cam_start_exp %s",cam->msg);
            return;
        }
    }
    webcam_log(LOG_DEBUG,"cam_start_exp end OK");
}

void cam_stop_exp(struct camprop *cam)
{
    webcam_log( LOG_DEBUG,"cam_stop_exp begin" );
    if (cam->longuepose == 1) {
        //long exposure
        int stop;
        if ( cam->longueposestart == 0 ) {
            stop = 1;
        }
        else {
            stop = 0;
        }
        if (webcam_setLongExposureDevice(cam, stop)) {
            //error description in cam->msg
            return;
        }
        cam->params->capture->grabFrame(cam->msg);
    }
#if defined(OS_LIN)
    else {
        cam->params->capture->abortCapture();
    }
#endif // OS_LIN
    webcam_log( LOG_DEBUG,"cam_stop_exp end OK" );
}

/**
 * cam_read_ccd - reads a frame.
 * This function store the frame in (unsigned short *)p buffer.
 *
 * Calling diagram:
 * "acq" -> cmdCamAcq -> cam_start_exp ...
 * -> AcqRead -> cam_read_ccd
 *
 * or
 *
 * "stop" -> cmdCamStop -> AcqRead -> cam_read_ccd.
 *
 * should return a value???
*/
void cam_read_ccd(struct camprop *cam, float *p)
{
    unsigned char *frameBuffer;
    BOOL result ;

    if ( ( cam->params == 0 ) || ( cam->params->capture == 0 ) ) {
        return;
    }

    webcam_log( LOG_DEBUG,"cam_read_ccd begin" );
    if ( cam->longuepose == 1 ) {
        //long exposure
        int stop;
        if ( cam->longueposestart == 0 )
            stop = 1;
        else
            stop = 0;

        if (webcam_setLongExposureDevice(cam, stop)) {
         //error description in cam->msg
            return;
        }
    }

    result = cam->params->capture->grabFrame(cam->msg);
    if ( result == FALSE ) {
        webcam_log( LOG_ERROR, "cam_read_ccd error: %s", cam->msg );
        return;
    }

    cam_update_window(cam);

    if ( cam->sensorColor == 1 ) {
        // Charge l'image 24 bits
        if ((strcmp(cam->convertbw,"cols")==0)||(strcmp(cam->convertbw,"cfa")==0)) {
            strcpy(cam->pixels_classe, "CLASS_GRAY");
        } else {
            strcpy(cam->pixels_classe, "CLASS_RGB");
        }
        strcpy(cam->pixels_format, "FORMAT_BYTE");
        strcpy(cam->pixels_compression, "COMPRESS_NONE");
        if (strcmp(cam->convertbw,"cfa")==0) {
            cam->pixel_data = (float*)malloc(cam->w * cam->h * sizeof(float)) ;
        }
        else if (strcmp(cam->convertbw,"cols") == 0) {
            cam->pixel_data = (float*)malloc(cam->w * cam->h * sizeof(float));
        }
        else {
            cam->pixel_data = (float*)malloc(cam->w * cam->h * 3 * sizeof(float));
        }

        if( cam->pixel_data != NULL) {
            // copy rgbBuffer into cam->pixel_data and convert color order BGR -> RGB
            frameBuffer = cam->params->capture->getGrabbedFrame( cam->msg );
            if( frameBuffer != NULL ) {
                float *pOut = (float *) cam->pixel_data  ;
                // j'applique le fenetrage
                if (strcmp(cam->convertbw,"cols")==0) {
                    for(int y = cam->y1; y >= cam->y2; y++ ) {
                        unsigned char *pIn = frameBuffer + y * cam->imax *3 ;
                        for(int x= cam->x1; x <= cam->x2; x++) {
                            *(pOut++)= *(pIn + x*3 +2);
                            *(pOut++)= *(pIn + x*3 +1);
                            *(pOut++)= *(pIn + x*3 +0);
                        }
                    }
                }
                else if (strcmp(cam->convertbw,"cfa")==0) {
                    for(int y = cam->y1; y >= cam->y2; y++ ) {
                        unsigned char *pIn = frameBuffer + y * cam->imax *3 ;
                        for(int x= cam->x1; x <= cam->x2; x++) {
                            *(pOut+ (2*(cam->y2-y)  ) * cam->w + 2 * (x-cam->x1) + 0)= *(pIn + x*3 +2);
                            *(pOut+ (2*(cam->y2-y)  ) * cam->w + 2 * (x-cam->x1) + 1)= *(pIn + x*3 +1);
                            *(pOut+ (2*(cam->y2-y)+1) * cam->w + 2 * (x-cam->x1) + 0)= *(pIn + x*3 +1);
                            *(pOut+ (2*(cam->y2-y)+1) * cam->w + 2 * (x-cam->x1) + 1)= *(pIn + x*3 +0);
                        }
                    }
                }
                else {
                    for(int y = cam->y1; y >= cam->y2; y++ ) {
                        unsigned char *pIn = frameBuffer + y * cam->imax *3 ;
                        for(int x= cam->x1; x <= cam->x2; x++) {
                            *(pOut++)= *(pIn + x*3 +2);
                            *(pOut++)= *(pIn + x*3 +1);
                            *(pOut++)= *(pIn + x*3 +0);
                        }
                    }
                }
            }
            else {
                // je retourne un message d'erreur
                sprintf(cam->msg, "cam_read_ccd: frameBuffer is empty");
            }
        }
        else {
            // je retourne un message d'erreur
            sprintf(cam->msg, "cam_read_ccd: Not enough memory");
        }

    }
    else {
        // Charge l'image 8 bits et la convertit en flottant
        strcpy(cam->pixels_classe, "CLASS_GRAY");
        strcpy(cam->pixels_format, "FORMAT_BYTE");
        strcpy(cam->pixels_compression, "COMPRESS_NONE");
        cam->pixel_data = (float*)malloc(cam->w * cam->h * sizeof(float));
        if( cam->pixel_data != NULL) {
            // copy rgbBuffer into cam->pixel_data   convert color order  BGR -> RGB
            frameBuffer = cam->params->capture->getGrabbedFrame(cam->msg);
            if( frameBuffer != NULL ) {
                float *pOut = (float *) cam->pixel_data;
                for(int y = cam->y1; y <= cam->y2; y++ ) {
                    unsigned char * pIn = frameBuffer + y * cam->imax *3 ;
                    for(int x= cam->x1; x <= cam->x2; x++) {
                        *(pOut++)= *(pIn + x*3 );
                    }
                }
            }
            else {
                // je retourne un message d'erreur
                sprintf(cam->msg, "cam_read_ccd: frameBuffer is empty");
            }
        }
        else {
            // je retourne un message d'erreur
            sprintf(cam->msg, "cam_read_ccd: Not enough memory");
        }
    }
    if (strlen(cam->msg) == 0) {
        webcam_log(LOG_DEBUG,"cam_read_ccd end OK");
    }
    else {
        webcam_log( LOG_ERROR, "cam_read_ccd error: %s", cam->msg );
    }
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
   cam->temperature = 0.;
}

void cam_cooler_on(struct camprop *cam)
{
}

void cam_cooler_off(struct camprop *cam)
{
}

void cam_cooler_check(struct camprop *cam)
{
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
}

void cam_update_window(struct camprop *cam)
{

   int maxx, maxy;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;

   webcam_log( LOG_DEBUG, "cam_update_window maxx = %d  maxy = %d", maxx, maxy );
   //  je laisse les coor
   //cam->x1 = 0;
   //cam->x2 = maxx - 1;
   //cam->y1 = 0;
   //cam->y2 = maxy - 1;

    if (cam->x1 < 0)
       cam->x1 = 0;
    if (cam->x2 > maxx - 1)
    cam->x2 = maxx - 1;
    if (cam->x1 > cam->x2)
       libcam_swap(&(cam->x1), &(cam->x2));
    if (cam->y1 < 0)
       cam->y1 = 0;
    if (cam->y2 > maxy - 1)
       cam->y2 = maxy - 1;
    if (cam->y1 > cam->y2)
       libcam_swap(&(cam->y1), &(cam->y2));


   cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;
   webcam_log( LOG_DEBUG, "cam_update_window x1 = %d  y1 = %d  x2 = %d  y2 = %d", cam->x1, cam->y1, cam->x2, cam->y2 );

    if (strcmp(cam->convertbw,"cols")==0) {
        cam->w*=3;
    }
    if (strcmp(cam->convertbw,"cfa")==0) {
        cam->w*=2;
        cam->h*=2;
    }
   webcam_log( LOG_DEBUG, "cam_update_window w = %d  h = %d" , cam->w, cam->h );

}

/**
 * webcam_getVideoFormat -
 *
 * Returns value:
 * - 0 when success.
*/
int webcam_getVideoFormat(struct camprop *cam, char *formatname) {
      if (cam->imax == 640 && cam->jmax == 480)
         strcpy(formatname, "VGA");
      else if (cam->imax == 352 && cam->jmax == 288)
         strcpy(formatname, "CIF");
      else if (cam->imax == 320 && cam->jmax == 240)
         strcpy(formatname, "SIF");
      else if (cam->imax == 240 && cam->jmax == 176)
         strcpy(formatname, "SSIF");
      else if (cam->imax == 176 && cam->jmax == 144)
         strcpy(formatname, "QCIF");
      else if (cam->imax == 160 && cam->jmax == 120)
         strcpy(formatname, "QSIF");
      else if (cam->imax == 128 && cam->jmax == 96)
         strcpy(formatname, "SQCIF");
      else if (cam->imax == 720 && cam->jmax == 576)
         strcpy(formatname, "720x576");
      else
         strcpy(formatname, "");
   return 0;
}

/**
 * webcam_setVideoFormat - sets video format.
 * Possible format names:
 * - VGA - 640 x 480
 * - CIF - 352 x 288
 * - SIF - 320 x 240
 * - SSIF - 240 x 176
 * - QCIF - 176 x 144
 * - QSIF - 160 x 120
 * - SQCIF - 128 x 96.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/


int webcam_setVideoFormat(struct camprop *cam, char *formatname)
{

   webcam_log( LOG_DEBUG,"webcam_setVideoFormat begin format=%s", formatname );

#if defined(OS_WIN)
   if (cam->params->capture == NULL) {
      sprintf(cam->msg, "Camera not ready (capture=NULL)");
      return 1;
   }
   if (cam->params->capture->hasDlgVideoFormat()) {
      // j'ouvre la fenetre de configuration du driver de la camera
      //BringWindowToTop(cam->g_hWndC);
      //SetForegroundWindow(cam->g_hWndC);
      cam->params->capture->openDlgVideoFormat();
      // apres la fermeture de la fenetre , je recupere le nouveau format de l'image video
      cam->nb_photox = (int) cam->params->capture->getImageWidth();
      cam->nb_photoy = (int) cam->params->capture->getImageHeight();
      cam->binx = 1;
      cam->biny = 1;
      cam->imax = cam->nb_photox / cam->binx;
      cam->jmax = cam->nb_photoy / cam->biny;
   } else {
      sprintf(cam->msg, "Format dialog not available");
      return 1;
   }

#endif //OS_WIN

#if defined(OS_LIN)
   if ( cam->params->capture->setVideoFormat(formatname, cam->msg) == FALSE ) {
      return 1;
   }

   cam->nb_photox = (int) cam->params->capture->getImageWidth();
   cam->nb_photoy = (int) cam->params->capture->getImageHeight();
   cam->binx = 1;
   cam->biny = 1;
   cam->imax = cam->nb_photox / cam->binx;      /* valeurs par defauts */
   cam->jmax = cam->nb_photoy / cam->biny;
   //cam->celldimx = 5080. / cam->nb_photox;
   //cam->celldimy = 3810. / cam->nb_photoy;

#endif //OS_LIN

   cam->x1 = 0;
   cam->x2 = cam->nb_photox - 1;
   cam->y1 = 0;
   cam->y2 = cam->nb_photoy - 1;
   cam_update_window(cam);
   webcam_log(LOG_DEBUG,"webcam_setVideoFormat end OK");

   return 0;
}



/**
 * webcam_setFrameRate -
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/

int webcam_setFrameRate(struct camprop *cam, int value) {
   if (cam->params->capture->setPreviewRate(value,cam->msg)==FALSE) {
      return -1;
   }
   return 0;
}

int webcam_getFrameRate(struct camprop *cam, int *pValue) {
   if (cam->params->capture->getPreviewRate(pValue,cam->msg)==FALSE) {
      return -1;
   }
   return 0;
}



/**
 * webcam_setLongExposureDevice - writes <i>value</i>
 * to the parallel port.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/


int webcam_setLongExposureDevice(struct camprop *cam, unsigned char value)
{
   int result = 0;
   char ligne[256];

   sprintf(ligne, "link%d bit %s %d", cam->longueposelinkno, cam->longueposelinkbit, value);

   if( Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
      result = 1;
   } else {
      result = 0;
   }
   webcam_log(LOG_DEBUG,"webcam_setLongExposureDevice %s result=%d",ligne,result);
   return result;
}

/**
 * webcam_getVideoParameter - returns asked parameters.
 * command is defined by <i>command</i>,
 * result is copied to <i>result</i> string,
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
*/
int webcam_getVideoParameter( struct camprop *cam, char *result, int command )
{
    webcam_log( LOG_DEBUG, "webcam_getVideoParameter command = %d", command );
    if ( cam->params->capture->getVideoParameter( result, command, cam->msg ) == TRUE )
        return 0;
    else
        return 1;
}

/**
 * webcam_setVideoParameter - sets some video source parameters.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_setVideoParameter( struct camprop *cam, int paramValue, int command )
{
    if ( cam->params->capture->setVideoParameter( paramValue, command, cam->msg ) == FALSE )
        return 1;
    else
        return 0;
}


/**
 * webcam_saveUser.
 * This function will write the current brightness, contrast,
 * colour and whiteness (gamma) settings into
 * the camera's internal EEPROM.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_saveUser(struct camprop *cam)
{

#if defined(OS_LIN)
   /*
   if (ioctl(cam->cam_fd, VIDIOCPWCSUSER, NULL)) {
      strcpy(cam->msg, "Can't VIDIOCPWCSUSER");
      return 1;
   }
   */
#endif
   return 0;
}

/**
 * webcam_setPicSettings - sets brightness, contrast,
 * colour and whiteness (gamma).
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_setPicSettings(struct camprop *cam, int brightness, int contrast,
                   int colour, int whiteness)
{

#if defined(OS_LIN)
   /*
   struct video_picture pic;

   if (ioctl(cam->cam_fd, VIDIOCGPICT, &pic)) {
      strcpy(cam->msg, "Can't VIDIOCGPICT");
      return 1;
   }

   pic.brightness = brightness;
   pic.contrast = contrast;
   pic.colour = colour;
   pic.whiteness = whiteness;
   //pic.palette = VIDEO_PALETTE_YUV420P;

   //printf("webcam_setPicSettings palette=%d brightness=%d contrast=%d colour=%d whiteness=%d\n",
   //pic.palette , pic.brightness, pic.contrast, pic.colour, pic.whiteness);
   if (ioctl(cam->cam_fd, VIDIOCSPICT, &pic)) {
      strcpy(cam->msg, "Can't VIDIOCSPICT");
      return 1;
   }
   */
   return 1;
#endif
   return 0;
}


/**
 * setWhiteBalance sets White Balance.
 * Arguments:
 * - mode - mode name
 * - red, blue - red and blue levels - valid only when mode is "manual"
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in cam->msg.
 *
 * Function implemented for Linux.
*/
int webcam_setWhiteBalance(struct camprop *cam, char *mode, int red, int blue)
{

  if (cam->params->capture->setWhiteBalance(mode, red, blue, cam->msg)==FALSE) {
      return 0;
   } else {
      return 1;
   }
   return 0;
}


/**
 * webcam_openDlgVideoSource -
 *
 * Returns value:
*/
void webcam_openDlgVideoSource(struct camprop *cam) {
   cam->params->capture->openDlgVideoSource();
}

/**
 * webcam_setTclStatusVariable -
 *
 * Returns value:
*/
void webcam_setTclStatusVariable(struct camprop *cam, char* statusVariable) {
   cam->params->captureListener->setTclStatusVariable(statusVariable);
}



/******************************************************************/
/*  Fonctions d'affichage et de capture video (M. Pujol)          */
/*                                                                */
/*  Pour Windows uniquement                                       */
/******************************************************************/
#if defined(OS_WIN)

/**
 * startVideoPreview
 *    starts video preview
 *
 * Parameters:
 *    cam : camera struct
 *    previewRate : expoure time (frame/seconds)
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    show the preview window
 */
int startVideoPreview(struct camprop *cam, int owner, int previewRate) {

   if( cam->params->capture->isPreviewEnabled() == 1 ) {
      sprintf(cam->msg, "preview already in use");
      return FALSE;
   }

   // je fixe la frequence de images
   cam->params->capture->setPreviewRate(previewRate,cam->msg);
   // j'autorise les changements d'echelle
   cam->params->capture->setPreviewScale(TRUE);
   // je desactive le mode overlay, au cas ou il serait actif
   cam->params->capture->setOverlay(FALSE);
   // j'adapte la taille de la fenetre
   //cam->params->capture->setWindowSize(cam->params->capture->getImageWidth(), cam->params->capture->getImageHeight() );
   // j'active la previsualisation
   cam->params->capture->setPreview(TRUE,owner);
   return TRUE;
}

/**
 * stopVideoPreview
 *    stops video preview
 *
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    hide the preview window
 */
int stopVideoPreview(struct camprop *cam) {
   //int result;

   // j'arrete la previsualisation
   cam->params->capture->setPreview(FALSE,0);

   return TRUE;
}



/**
 * startVideoCapture
 *    starts video capture
 *
 * Parameters:
 *    cam : camera struct
 *    extime : exposure time (seconds)
 *    microSecPerFrame : rate (milliseconds per frame)
 *    fileName  : output film name (AVI)
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int startVideoCapture(struct camprop *cam, unsigned short exptime, unsigned long microSecPerFrame, char * fileName) {
    int result;

    webcam_log( LOG_DEBUG, "startVideoCapture" );
   if( cam->params->capture->isCapturingNow() == 1 ) {
      sprintf(cam->msg, "capture already in use");
      return FALSE;
   }

   // je lance la capture
   if( cam->params->cropCapture == NULL ) {
     result =  cam->params->capture->startCapture(exptime, microSecPerFrame, fileName);
   } else {
     result =  cam->params->cropCapture->startCropCapture(exptime, microSecPerFrame, fileName);
   }

   return result;

}

/**
 * stopVideoCapture
 *    stops video capture
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    disable the callback  and stop capture
 */
int stopVideoCapture(struct camprop *cam) {
   if( cam->params->capture->isCapturingNow() == 0 ) {
      // rien a faire la capture est deja arretee
      return TRUE;
   }

   return cam->params->capture->abortCapture();
}

/**
 * startVideoCrop
 *    start cropped mode
 *    the crop rectangle is specified with setVideoCropRect()
 *    before starting or when video is running
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int startVideoCrop(struct camprop *cam) {

   if( cam->params->cropCapture != NULL ) {
      sprintf(cam->msg, "cropped preview already enable");
      return FALSE;
   }

   cam->params->cropCapture= new CCropCapture((CCaptureWinVfw *)cam->params->capture);
   cam->params->cropCapture->startCropPreview();

   return TRUE;

}

/**
 * stopVideoCrop
 *    stop cropped mode
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    disable the callback  and stop video
 */
int stopVideoCrop(struct camprop *cam) {
   if( cam->params->cropCapture == NULL ) {
      sprintf(cam->msg, "cropped preview already disabled");
      return FALSE;
   }


   cam->params->cropCapture->stopCropPreview();
   delete cam->params->cropCapture;
   cam->params->cropCapture = NULL;

   return TRUE;
}

/**
 * setVideoCropRect
 *    modifies the size of the crop rectangle
 * Parameters:
 *    cam : camera struct
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 * Side effects:
 *    declare  a callback  and launch startCaptureNoFile
 *    The end will be notify by StatusCallbackProc
 */
int setVideoCropRect(struct camprop *cam, long x1, long y1, long x2, long y2) {

   if( cam->params->cropCapture == NULL ) {
      sprintf(cam->msg, "cropped mode is disabled");
      return FALSE;
   }
   cam->params->cropCapture->setX1(x1);
   cam->params->cropCapture->setY1(y1);
   cam->params->cropCapture->setX2(x2);
   cam->params->cropCapture->setY2(y2);

   return TRUE;

}



#endif

