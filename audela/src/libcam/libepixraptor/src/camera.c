/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2013 The AudeLA Core Team
 *
 * Initial author : Matteo SCHIAVON <ilmona89@gmail.com>
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

/*#define READSLOW*/
#define READOPTIC

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>

#include "camera.h"
#include <libcam/util.h>

#include "raptor.h"
#include "xcliball.h"
//meinberg
//#include <meinberg.h>

#if defined(OS_LIN)
#include <signal.h>
#endif

// Ajout AK
#if defined(OS_WIN)
#include <signal.h> 
#ifndef _SIG_SIGSET_T_DEFINED
typedef int sigset_t;
#define _SIG_SIGSET_T_DEFINED
int gettimeofday(struct timeval* p, void* tz) {
    ULARGE_INTEGER ul; // As specified on MSDN.
    FILETIME ft;
    // Returns a 64-bit value representing the number of
    // 100-nanosecond intervals since January 1, 1601 (UTC).
    GetSystemTimeAsFileTime(&ft);
    // Fill ULARGE_INTEGER low and high parts.
    ul.LowPart = ft.dwLowDateTime;
    ul.HighPart = ft.dwHighDateTime;
    // Convert to microseconds.
    ul.QuadPart /= 10ULL;
    // Remove Windows to UNIX Epoch delta.
    ul.QuadPart -= 11644473600000000ULL;
    // Modulo to retrieve the microseconds.
    p->tv_usec = (long) (ul.QuadPart % 1000000LL);
    // Divide to retrieve the seconds.
    p->tv_sec = (long) (ul.QuadPart / 1000000LL);
    return 0;
}
#endif
#endif

#include <time.h>

//meinberg
//static int gps;

struct timeval t_acq,t_lect/*,t_acq_gps*/;
static volatile sig_atomic_t usr_interrupt=0;
static sigset_t mask,oldmask;
volatile int buf=0; //global variable containing the current buffer
volatile int maxbuf=0; //global variable containing the maximum buffer
//variables that count the acquired and read buffers
volatile int acqbuf=0;
volatile int readbuf=0;


//structure where to put the different timestamps
struct timeval *ts/*,*t_gps*/;

//handler of SIGUSR1
static void handler_acquisition(int signal) {
	char message[50];
	char error[50];
	acqbuf++;
	gettimeofday (&t_acq, NULL);
}

//handler of SIGUSR2
static void handler_lecture(int signal) {
	char message[50];
	buf++;
  readbuf++;
	gettimeofday (&t_lect, NULL);
	usr_interrupt = 1;
	if ( buf < maxbuf )
		ts[buf] = t_acq;
	else
		ts[maxbuf] = t_acq;
}

	
/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"EPIX + Raptor Photonics OSPREY",			/* camera name */
     "epixraptor",        /* camera product */
     "OS4NPc-CL",			/* ccd name */
     2048, 2048,			/* maxx maxy */
     0, 0,			/* overscans x??? */
     0, 0,			/* overscans y??? */
     5.5e-6, 5.5e-6,		/* photosite dim (m) */
     4095.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu)??? */
     7.,			/* readnoise (e)??? */
     1, 1,			/* default bin x,y */
     0.03,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     5.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, char **argv);
static int cam_close(struct camprop * cam);
static void cam_start_exp(struct camprop *cam, char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, unsigned short *p);
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

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init(struct camprop *cam, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
{
	int ret,kk;
	int x1,y1,x2,y2;
	int binx,biny;
#if defined(OS_WIN)
	HANDLE hwin;
#endif

	memset(cam->config,0,256);

	//decode the options of cam::create
	if (argc >= 5) {
		for (kk = 3; kk < argc - 2; kk++) {
			if (strcmp(argv[kk],"-config") == 0) {
				if ( (kk+7) >= (argc-2) ) {
					sprintf(cam->msg,"usage: -config ?configuration file? ?x1 y1 x2 y2? ?binx biny?");
					return 11;
				} else if (strlen(argv[kk+1]) > 256) {
					sprintf(cam->msg,"config file path too long, using default configuration");
				} else {
					strncpy(cam->config,argv[kk+1],256);
					cam->minx = cam->x1 = atoi(argv[kk+2]);
					cam->miny = cam->y1 = atoi(argv[kk+3]);
					cam->maxx = cam->x2 = atoi(argv[kk+4]);
					cam->maxy = cam->y2 = atoi(argv[kk+5]);
					cam->maxw = cam->w = cam->x2 - cam->x1 + 1;
					cam->maxh = cam->h = cam->y2 - cam->y1 + 1;
					cam->maxbinx = cam->minbinx = cam->binx = atoi(argv[kk+6]);
					cam->maxbiny = cam->minbiny = cam->biny = atoi(argv[kk+7]);
				}
			}
		}
	}
					
	if ( strlen(cam->config) == 0 ) {
		//Default Pixci init
		ret = pxd_PIXCIopen("","Default","");
		if (ret) {
			pxd_mesgFaultText(0x1,cam->msg,2048);
			return 1;
		}

		//default video mode dependent parameters
		// ---> they change according to the camera
		cam->maxw = 2048;
		cam->maxh = 2048;
		cam->minx = 0;
		cam->miny = 0;
		cam->maxx = 2047;
		cam->maxy = 2047;
		cam->minbinx = 1;
		cam->minbiny = 1;
		cam->maxbinx = 1;
		cam->maxbiny = 1;

		//default parameters
		cam->x1=0;
		cam->y1=0;
		cam->x2=2047;
		cam->y2=2047;
		cam->h=2048;
		cam->w=2048;
		cam->binx=1;
		cam->biny=1;
	} else {
		//Pixci init with external config file
		ret = pxd_PIXCIopen("","",cam->config);
		if (ret) {
			pxd_mesgFaultText(0x1,cam->msg,2048);
			return 1;
		}

	}

	//Check if the video format match the entered configuration
	if ( (cam->w/cam->binx) != pxd_imageXdim() ) {
		sprintf(cam->msg,"The video format does not match the current camera configuration:\nwidth = %d\nbinx = %d\nAudela buffer size = %d\nPixci buffer size = %d\n",cam->w,cam->binx,cam->w/cam->binx,pxd_imageXdim());
		return 10;
	}
	if ( (cam->h/cam->biny) != pxd_imageYdim() ) {
		sprintf(cam->msg,"The video format does not match the current camera configuration:\nheight = %d\nbiny = %d\nAudela buffer size = %d\nPixci buffer size = %d\n",cam->h,cam->biny,cam->h/cam->biny,pxd_imageYdim());
		return 11;
	}

	//Serial init
	ret = serialInit();
	if (ret) {
		sprintf(cam->msg,"serialInit returns %d",ret);
		return 2;
	}

	//Serial set status
	ret = setState(ACK_ON|UNHOLD_FPGA);
	if (ret) {
		sprintf(cam->msg,"setState returns %d",ret);
		return 3;
	}

	//Get camera data
	ret = getData(cam);
	if (ret) {
		sprintf(cam->msg,"getData returns %d",ret);
		return 4;
	}

	//constraints (video mode independent)
	// ---> they change according to the camera
	maxbuf = cam->max_buf = cam_get_maxfb();
	cam->max_exposure = cam_max_exposure();
	cam->min_exp_dyn = 0.42;
	cam->max_gain = 128;
	cam->max_frameRate = cam_max_framerate(cam->h);
 
	//initial parameters (video mode independent)
	// ---> they change according to the camera
	cam->exptime=0.001;
	cam->capabilities.videoMode = 1;
	cam->video=0;
	cam->gain=1;
	acqbuf=buf=cam->cur_buf=0;
	cam->frameRate = 37.5;
	cam->videoMode = 1;

	if (cam_initialize(cam) != 0) {
		return 5;
	}

	//default image parameters
	// ---> they can change according to the camera
	strcpy(cam->pixels_classe,"CLASS_GRAY");
	strcpy(cam->pixels_format,"FORMAT_USHORT");
	strcpy(cam->pixels_compression,"COMPRESS_NONE");
	cam->pixels_reverse_x = 0;
	cam->pixels_reverse_y = 0;
	cam->pixel_data = NULL;
	strcpy(cam->msg,"");

	//initializes the timestamp structures
	ts = (struct timeval *)calloc(cam->max_buf+1,sizeof(struct timeval));

	//SIGUSR2 at the end of lecture
#if defined(OS_WIN)
	hwin = pxd_eventCapturedFieldCreate(0x1);
	if (hwin) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return 9;
	}
#else
	ret = pxd_eventCapturedFieldCreate(0x1,SIGUSR2,0);
	if (ret) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return 9;
	}
#endif

	//SIGUSR1 at the end of integration
#if defined(OS_WIN)
	hwin = pxd_eventFieldCreate(0x1);
	if (hwin) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return 10;
	}
#else
	ret = pxd_eventFieldCreate(0x1,SIGUSR1,0);
	if (ret) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return 10;
	}
#endif

	sigemptyset(&mask);
	sigaddset(&mask,SIGUSR2);

	signal(SIGUSR2,handler_lecture);
	signal(SIGUSR1,handler_acquisition);

	return 0;

}

int cam_close(struct camprop * cam)
{
	int ret;

	free(ts);

	ret = pxd_PIXCIclose();
	if (ret) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return 4;
	}

	return 0;

}


void cam_start_exp(struct camprop *cam, char *amplionoff)
{
	int ret;

	cam_update_window(cam);

	//set exposure time
	ret = setExposure(cam->exptime);
	if (ret) {
		sprintf(cam->msg, "setExposure returns %d", ret);
		return;
	}

	cam->video=0;
	readbuf = acqbuf = cam->cur_buf = 0;
	buf = cam->max_buf;
	//snap an image
	ret = pxd_goSnap(0x1,cam->max_buf);
	if (ret) {
		sprintf(cam->msg,"Start exposition failed");
		return;
	}

	usr_interrupt=0;
	//set trigger mode to snapshot (single acquisition via snapshot)
	ret = setTrigger(TRG_SNAP);
	if (ret) {
		sprintf(cam->msg, "setTrigger returns %d", ret);
		return;
	}

}

void cam_stop_exp(struct camprop *cam)
{
	int ret;

	ret = setTrigger(TRG_ABORT);
	if (ret) {
		sprintf(cam->msg,"Trigger abort failed");
		return;
	}

}

void cam_read_ccd(struct camprop *cam, unsigned short *p)
{
	int ret;
	char message[50];
	struct timeval t,texp,tbeg;

	sigprocmask(SIG_BLOCK,&mask,&oldmask);
	while (!usr_interrupt) {
		sigsuspend(&oldmask);
	}
	sigprocmask(SIG_UNBLOCK,&mask,NULL);

	//set the window to the current ROI size
	cam_update_window(cam);

	// save the single mode image in the last buffer
	buf = cam->max_buf;

	//copy the data from the last frame buffer to the buffer p
	ret = pxd_readushort(0x1,cam->max_buf,0,0,-1,-1,p,cam->w*cam->h,"Grey");
	if ( ret<0 ) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return;
	}

	//print the computer date (taken from the pixci driver)
	t = ts[cam->max_buf];
	//end of the obeservation
	strftime(message, 45, "%Y-%m-%dT%H:%M:%S",gmtime ((const time_t*)(&t.tv_sec)));
	sprintf(cam->date_end,"%s.%06d", message, (int)(t.tv_usec));
	//t_begin = t_end - t_exp
	texp.tv_sec=(int)cam->exptime;
	texp.tv_usec=(int)(cam->exptime*1000000)%1000000;
	tbeg.tv_usec = t.tv_usec - texp.tv_usec;
	if (tbeg.tv_usec<0) {
		tbeg.tv_usec += 1000000;
		tbeg.tv_sec = t.tv_sec - texp.tv_sec - 1;
	} else {
		tbeg.tv_sec = t.tv_sec - texp.tv_sec;
	}
	//begin of the observation
	strftime(message, 45, "%Y-%m-%dT%H:%M:%S",gmtime ((const time_t*)(&tbeg.tv_sec)));
	sprintf(cam->date_obs,"%s.%06d", message, (int)(tbeg.tv_usec));

	//reset the buffer count to zero
	acqbuf = readbuf = buf = cam->cur_buf = 0;

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

// get the temperature of the CMOS sensor
void cam_measure_temperature(struct camprop *cam)
{
	int ret;
	int t_ADC;

	ret = getCMOStemp(&t_ADC);
	if (ret) {
		sprintf(cam->msg, "getCMOStemp returns %d\n", ret);
		return;
	}

	cam->temperature = (double)(t_ADC - cam->ADC_0)/(cam->ADC_40 - cam->ADC_0)*40.;
}

void cam_cooler_on(struct camprop *cam)
{
	int ret;

	ret = setTEC(TEC_ON);
	if (ret) {
		sprintf(cam->msg, "setTEC(TEC_ON) returns %d\n", ret);
		return;
	}
}

void cam_cooler_off(struct camprop *cam)
{
	int ret;

	ret = setTEC(TEC_OFF);
	if (ret) {
		sprintf(cam->msg, "setTEC(TEC_OFF) returns %d\n", ret);
		return;
	}
}

void cam_cooler_check(struct camprop *cam)
{
	int ret;
	uchar TECmode;

	ret = getTEC(&TECmode);
	if (ret) {
		sprintf(cam->msg, "getTEC returns %d\n", ret);
		return;
	}

	if (TECmode&0x1)
		cam->cooler = 1;
	else
		cam->cooler = 0;

}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
	int ret;
	uchar mode;

	if (binx == biny) {
		switch (binx) {
			case 1:	mode = BIN_1x1;
							break;
			case 2: mode = BIN_2x2;
							break;
			case 4: mode = BIN_4x4;
							break;
			default:	sprintf(cam->msg, "Possible binning modes: 1x1, 2x2, 4x4");
								return;
		}
		if ( binx < cam->minbinx ) {
			sprintf(cam->msg,"This binning is not available in the current video mode\nYou must change video mode if you want to change binning");
			return;
		}
		if ( binx > cam->maxbinx ) {
			sprintf(cam->msg,"This binning is not available in the current video mode\nYou must change video mode if you want to change binning");
			return;
		}
	}
	else {
		sprintf(cam->msg, "Possible binning modes: 1x1, 2x2, 4x4");
		return;
	}

	ret = setBinning(mode);
	if (ret) {
		sprintf(cam->msg, "setBinning returns %d", ret);
		return;
	}

	cam->binx = binx;
	cam->biny = biny;

}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy;
    maxx = cam->nb_photox;
    maxy = cam->nb_photoy;
    
    if (cam->x1 > cam->x2)
	libcam_swap(&(cam->x1), &(cam->x2));
    if (cam->x1 < 0)
	cam->x1 = 0;
    if (cam->x2 > maxx - 1)
	cam->x2 = maxx - 1;

    if (cam->y1 > cam->y2)
	libcam_swap(&(cam->y1), &(cam->y2));
    if (cam->y1 < 0)
	cam->y1 = 0;
    if (cam->y2 > maxy - 1)
	cam->y2 = maxy - 1;

    cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;

    /*if (cam->x2 > maxx - 1) {
        cam->w = cam->w - 1;
        cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    }

    if (cam->y2 > maxy - 1) {
        cam->h = cam->h - 1;
        cam->y2 = cam->y1 + cam->h * cam->biny - 1;
    }*/

}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

//get all the invariable data (FPGA and micro version, FPGA ROM)
// ---> extremely dependent on the camera used
int getData(struct camprop *cam) {
	int ret;
	uchar data[18];
	
	ret = getMicroVersion(data);
	if (ret)
		return 1;
	sprintf(cam->microVersion,"%d.%d",data[0],data[1]);

	ret = getFPGAversion(data);
	if (ret)
		return 2;
	sprintf(cam->fpgaVersion,"%d.%d",data[0],data[1]);

	ret = getManuData(data);
	if (ret)
		return 3;
	cam->serialNumber = (int)*((uint16 *)(&data[0]));
	sprintf(cam->build,"%02d/%02d/%02d %c%c%c%c%c",data[2],data[3],data[4],data[5],data[6],data[7],data[8],data[9]);
	cam->ADC_0 = (int)*((uint16 *)(&data[10]));
	cam->ADC_40 = (int)*((uint16 *)(&data[12]));
	cam->DAC_0 = (int)*((uint16 *)(&data[14]));
	cam->DAC_40 = (int)*((uint16 *)(&data[16]));

	return 0;
}

// set the ROI
int cam_set_roi(struct camprop *cam, int x1, int y1, int x2, int y2) {
	int w,h;

	w = x2 - x1 + 1;
	h = y2 - y1 + 1;

	if ((x1 != cam->minx) || (y1 != cam->miny) || (w != cam->maxw) || (h != cam->maxh)) {
		sprintf(cam->msg,"You must change viedo mode in order to change ROI");
		return -2;
	}

	if ( (setROIxoffset(x1)==0) && (setROIyoffset(y1)==0) && (setROIxsize(w)==0) && (setROIysize(h)==0) )	{
		cam->x1=x1;
		cam->y1=y1;
		cam->w=w;
		cam->h=h;
		cam->x2=x2;
		cam->y2=y2;
		cam_update_window(cam);
	} else {
		sprintf(cam->msg, "Unable to set ROI");
		return -1;
 }

	cam->max_buf = cam_get_maxfb();

	return 0;
}

//set the frame rate (at most it sets max_frameRate)
int cam_set_framerate(struct camprop *cam, double frate) { 
	double fr;

	fr = (frate > cam->max_frameRate) ? cam->max_frameRate : frate;

	if ( setFrameRate(fr) == 0 ) {
		cam->frameRate = fr;
	}	else {
		sprintf(cam->msg,"Unable to set frame rate");
		return -1;
	}

	return 0;
}

//set the exposure (at most it sets max_exposure)
int cam_set_exposure(struct camprop *cam, double exp) { 
	double e;

	e = (exp > cam->max_exposure) ? cam->max_exposure : exp;
	e = (cam->dynamicRange) ? cam->min_exp_dyn : exp;

	if ( setExposure(e) == 0 ) {
		cam->exptime = e;
	}	else {
		sprintf(cam->msg,"Unable to set exposure");
		return -1;
	}

	return 0;
}

//set the gain (at most it sets max_gain)
int cam_set_gain(struct camprop *cam, int gain) { 
	int g;

	g = (gain > cam->max_gain) ? cam->max_gain : gain;

	if ( setGain(g) == 0 ) {
		cam->gain = g;
	}	else {
		sprintf(cam->msg,"Unable to set gain");
		return -1;
	}

	return 0;
}

//set the dynamic range
int cam_set_dynamic(struct camprop *cam, int dyn) {

	if (dyn) {
		if ( cam->exptime < 0.42 ) {
			if ( cam_set_exposure(cam,0.42) != 0 ) {
				sprintf(cam->msg,"Unable to set exposure");
				return -1;
			}
		}

		if ( setDynamicRange(HIGH_DYNAMIC) == 0 ) {
			cam->dynamicRange=1;
		} else {
			sprintf(cam->msg,"Unable to set high dynamic range");
			return -2;
		}
	} else {
		if ( setDynamicRange(STD_DYNAMIC) == 0 ) {
			cam->dynamicRange=0;
		} else {
			sprintf(cam->msg,"Unable to set standard dynamic range");
			return -3;
		}
	}

	return 0;
}

int cam_initialize(struct camprop *cam) {
	int ret;


	cam_set_binning(cam->binx,cam->biny,cam);
	if ( strlen(cam->msg) != 0 ) {
		sprintf(cam->msg, "cam_set_binning failed: %s\n",cam->msg);
		return -1;
	}

	//set roi
	ret = cam_set_roi(cam,cam->x1,cam->y1,cam->x2,cam->y2);
	if (ret) {
		sprintf(cam->msg, "cam_set_roi failed");
		return -2;
	}

	cam_update_window(cam);

	//set gain
	ret = cam_set_gain(cam,cam->gain);
	if (ret) {
		sprintf(cam->msg, "cam_set_gain failed");
		return -3;
	}

	//set exposure time
	ret = cam_set_exposure(cam,cam->exptime);
	if (ret) {
		sprintf(cam->msg, "cam_set_exposure failed");
		return -4;
	}

	//set frame rate
	ret = cam_set_framerate(cam,cam->frameRate);
	if (ret) {
		sprintf(cam->msg, "cam_set_framerate failed");
		return -5;
	}

	//set standard dynamic
	ret = cam_set_dynamic(cam,0);
	if (ret) {
		sprintf(cam->msg,"cam_set_dynamic failed");
		return -7;
	}

	cam->video = 0;
	//set trigger mode to external (no acquisition)
	ret = setTrigger(0x00);
	if (ret) {
		sprintf(cam->msg, "setTrigger returns %d\n", ret);
		return -6;
	}

	return 0;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage de la camera     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

/*void cam_realign(unsigned short *p, int w, int h) {
	int i,j;
	unsigned short *l;

	l=(unsigned short *)malloc(w*sizeof(short));
	for (i=0; i<h; i++) {
		for (j=0; j<w; j++) {
			l[(i+j)%w] = p[i*w+j];
		}
		for (j=0; j<w; j++) {
			p[i*w+j] = l[j];
		}
	}
	free(l);
}

void cam_unrealign(unsigned short *p, int w, int h) {
	int i,j;
	unsigned short *l;

	l=(unsigned short *)malloc(w*sizeof(short));
	for (i=0; i<h; i++) {
		for (j=0; j<w; j++) {
			l[(w+j-i)%w] = p[i*w+j];
		}
		for (j=0; j<w; j++) {
			p[i*w+j] = l[j];
		}
	}
	free(l);
}*/

int cam_get_framebuffer(struct camprop *cam, int fb, unsigned short *p) {
	int ret;

	//copy the data from the frame buffer #fb to the buffer p
	ret = pxd_readushort(0x1,fb,0,0,-1,-1,p,cam->w*cam->h,"Grey");
	if ( ret<0 ) {
		pxd_mesgFaultText(0x1,cam->msg,2048);		
		return ret;
	}

	cam_update_window(cam);

	return 0;
}

int cam_set_framebuffer(struct camprop *cam, int fb, unsigned short *p) {
	int ret;

	//cam_unrealign(p,w,h);

	//copy the data from the frame buffer #fb to the buffer p
	ret = pxd_writeushort(0x1,fb,0,0,-1,-1,p,cam->w*cam->h,"Grey");
	if ( ret<0 ) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return ret;
	}

	return 0;
}

int cam_get_maxfb() {
	return pxd_imageZdim();
}

//return the maximum frame rate
double cam_max_framerate(int nlines) {
	return 80.e6 / ((double)(nlines*1028+27989));
}

//return the maximum exposure
double cam_max_exposure() {
	unsigned long maxex_cycles = 0xffffffffff;
	return ((double)maxex_cycles)/80.e6;
}

//start a video sequence
int cam_video_start(struct camprop *cam) {
	int ret;
	uchar mode;

	if (cam->video) {
		sprintf(cam->msg, "cam_video_start failed: a video session is already open");
		return 1;
	}

	//set exposure time
	ret = cam_set_exposure(cam,cam->exptime);
	if (ret) {
		sprintf(cam->msg, "cam_set_exposure failed");
		return -4;
	}

	//set frame rate
	ret = cam_set_framerate(cam,cam->frameRate);
	if (ret) {
		sprintf(cam->msg, "cam_set_framerate failed");
		return -5;
	}

	if (cam->videoMode)
		mode = TRG_FFR;
	else
		mode = 0x00;

	ret = setTrigger(mode|TRG_CONT);
	if (ret<0) {
		sprintf(cam->msg,"setTrigger returns %d",ret);
		return -2;
	}

  cam_set_zero();
	buf = cam->cur_buf;
	ret = pxd_goLiveSeq(0x1,cam->cur_buf+1,cam->max_buf-1,1,cam->max_buf-1,1);
	if (ret) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return -1;
	}

	cam->video=1;		

}

//pause a video sequence
int cam_video_pause(struct camprop *cam) {
	int ret;

	ret = pxd_goAbortLive(0x1);
	if (ret) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return -1;
	}

	ret = setTrigger(0x00);
	if (ret<0) {
		sprintf(cam->msg,"setTrigger returns %d",ret);
		return -1;
	}

	cam->video = 0;

}

//get the last acquired frame buffer
int cam_get_curbuf() {
	return pxd_capturedBuffer(0x1);
}

//set the acquired buffers and the read buffers to zero
void cam_set_zero() {
	acqbuf = readbuf = 0;
}

//get the buffer timestamp
int cam_get_bufferts(struct camprop *cam, int fb, char *date) {
	struct timeval tv;
	char s[50];

	tv = ts[fb];

	if ( ! ( tv.tv_sec || tv.tv_usec ) ) {
		sprintf(cam->msg,"Invalid timestamp");
		return -1;
	}

	strftime(s, 45, "%Y-%m-%dT%H:%M:%S",gmtime ((const time_t*)(&tv.tv_sec)));
	sprintf(date,"%s.%06d",s,tv.tv_usec);
	
	return 0;
}

//get the number of acquired images
int cam_get_acquired() {
	return acqbuf;
}

//get the number of read images
int cam_get_read() {
  return readbuf;
}

//start live capture mode (it saves all the video frames in a given framebuffer)
int cam_live_start(struct camprop *cam) {
	int ret;
	uchar mode;

	if (cam->video) {
		sprintf(cam->msg,"cam_live_start failed: a video session is already open");
		return 1;
	}

	//set exposure time
	ret = cam_set_exposure(cam,cam->exptime);
	if (ret) {
		sprintf(cam->msg, "cam_set_exposure failed");
		return -4;
	}

	//set frame rate
	ret = cam_set_framerate(cam,cam->frameRate);
	if (ret) {
		sprintf(cam->msg, "cam_set_framerate failed");
		return -5;
	}

	if (cam->videoMode)
		mode = TRG_FFR;
	else
		mode = 0x00;

	ret = setTrigger(mode|TRG_CONT);
	if (ret<0) {
		sprintf(cam->msg,"setTrigger returns %d",ret);
		return -2;
	}

  cam_set_zero();
	buf = cam->max_buf;
	ret = pxd_goLive(0x1,cam->max_buf);
	if (ret) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return -1;
	}

	cam->video=1;		

}
