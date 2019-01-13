/* libstruc.h
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

/*
 * $Id: libstruc.h,v 1.17 2010-07-14 14:36:05 michelpujol Exp $
 */

#ifndef __LIBSTRUC_H__
#define __LIBSTRUC_H__

/*****************************************************************/
/*             This part is common for all cam drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Structure interne pour la gestion du temps de pose.
 * Ne pas modifier.
 */
struct TimerExpirationStruct {
    ClientData clientData;
    Tcl_Interp *interp;
    Tcl_TimerToken TimerToken;
};


struct Capabilities {
   int expTimeCommand;     // existence de la commande de choix du temps de pose 
   int expTimeList;        // existence d'une liste pr�definie des temps de pose
   int videoMode;          // existence du mode video
};



#define COMMON_CAMSTRUCT \
   char msg[2048];\
   int authorized;\
   double foclen;\
   float exptime;\
   float exptimeTimer;\
   int binx, biny;\
   int x1, y1, x2, y2;\
   int w, h;\
   int mirrorh;\
   int mirrorv;\
   int bufno;\
   int camno;\
   int telno;\
   int radecFromTel;\
   unsigned short port;\
   int portindex;\
   char portname[80];\
   char headerproc[1024];\
   int shutterindex;\
   int coolerindex;\
   int index_cam;\
   double celldimx;\
   double celldimy;\
   double fillfactor;\
   double temperature;\
   double check_temperature;\
   int rgbindex;\
   int overscanindex;\
   int nb_deadbeginphotox;\
   int nb_deadendphotox;\
   int nb_deadbeginphotoy;\
   int nb_deadendphotoy;\
   int nb_photox;\
   int nb_photoy;\
   int interrupt;\
   char date_obs[30];\
   char date_end[30];\
   int  gps_date;\
   unsigned long clockbegin;\
   Tcl_Interp *interp;\
   char mainThreadId[20]; \
   char camThreadId[20]; \
   char telThreadId[20]; \
   struct TimerExpirationStruct *timerExpiration;\
   char pixels_classe[60]; \
   char pixels_format[60]; \
   char pixels_compression[60]; \
   float *pixel_data; \
   unsigned long pixel_size; \
   struct Capabilities capabilities; \
   int  blockingAcquisition; \
   int  acquisitionInProgress; \
	int mode_stop_acq; \
	int stop_detected; \
   int darkBufNo; \
   char *darkFileName; \
   char rawFilter[70]; \
   char rawColor[70]; \
   char rawBlack[70]; \
   char rawMaxi[70]; \
   struct camprop *next


extern const char *cam_shutters[];
extern const char *cam_rgbs[];
extern const char *cam_coolers[];
extern const char *cam_ports[];
extern const char *cam_overscans[];

/* --- structure qui accueille les initialisations des parametres---*/
/* Ne pas modifier. */
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
    char overscanindex;
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

extern struct camini CAM_INI[];

struct camprop;

struct cam_drv_t {
    int (*init) (struct camprop * cam, int argc, const char **argv);
    int (*close) (struct camprop * cam);
    void (*set_binning) (int binx, int biny, struct camprop * cam);
    void (*update_window) (struct camprop * cam);
    void (*start_exp) (struct camprop * cam, const char *amplionoff);
    void (*stop_exp) (struct camprop * cam);
    void (*read_ccd) (struct camprop * cam, float *p);
    void (*shutter_on) (struct camprop * cam);
    void (*shutter_off) (struct camprop * cam);
    void (*ampli_on) (struct camprop * cam);
    void (*ampli_off) (struct camprop * cam);
    void (*measure_temperature) (struct camprop * cam);
    void (*cooler_on) (struct camprop * cam);
    void (*cooler_off) (struct camprop * cam);
    void (*cooler_check) (struct camprop * cam);
};

extern struct cam_drv_t CAM_DRV;

#ifdef __cplusplus
}
#endif

#endif
