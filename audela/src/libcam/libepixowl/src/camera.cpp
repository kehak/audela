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

#include "owl.h"
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

#if defined (OS_LIN)
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
	//char message[50];
	//char error[50];
	acqbuf++;
	gettimeofday (&t_acq, NULL);
}

//handler of SIGUSR2
static void handler_lecture(int signal) {
	//char message[50];
	buf++;
  readbuf++;
	gettimeofday (&t_lect, NULL);
	usr_interrupt = 1;
	if ( buf < maxbuf )
		ts[buf] = t_acq;
	else
		ts[maxbuf] = t_acq;
}
#endif
	
/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"EPIX + Raptor Photonics OWL",			/* camera name */
     "epixowl",        /* camera product */
     "Raptor OWL 1.7-CL-320",			/* ccd name */
     640, 512,			/* maxx maxy */
     0, 0,			/* overscans x??? */
     0, 0,			/* overscans y??? */
     15e-6, 15e-6,		/* photosite dim (m) */
     16384.0,			/* observed saturation */
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

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop * cam);
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

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init(struct camprop *cam, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
{
	int ret,kk;
	double d;
	char texte[256];
	char file_fmt[1024];
#if defined(OS_WIN)
	HANDLE hwin;
#endif

	memset(cam->config,0,256);
	cam->raptor_model = RAPTOR_UNKNOWN ;
	strcpy(file_fmt,"");

	//decode the options of cam::create
	if (argc >= 5) {
		for (kk = 3; kk < argc - 2; kk++) {
			if (strcmp(argv[kk],"-config") == 0) {
				if ( (kk+7) >= (argc-2) ) {
					sprintf(cam->msg,"usage: -config ?configuration_file? ?x1 y1 x2 y2? ?binx biny?");
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
		for (kk = 3; kk < argc - 2; kk++) {
			if (strcmp(argv[kk],"-model") == 0) {
				strncpy(texte,argv[kk+1],256);
				if (strcmp(texte,"eagle")==0) {
					cam->raptor_model = RAPTOR_EAGLE ;
				} else if (strcmp(texte,"ninox")==0) {
					cam->raptor_model = RAPTOR_NINOX ;
				} else if (strcmp(texte,"kingfisher")==0) {
					cam->raptor_model = RAPTOR_KINGFISHER ;
				} else if (strcmp(texte,"kite")==0) {
					cam->raptor_model = RAPTOR_KITE ;
				} else if (strcmp(texte,"osprey")==0) {
					cam->raptor_model = RAPTOR_OSPREY ;
				} else if (strcmp(texte,"owl320")==0) {
					cam->raptor_model = RAPTOR_OWL320 ;
				} else if (strcmp(texte,"owl640")==0) {
					cam->raptor_model = RAPTOR_OWL640 ;
				}
			}
			if (strcmp(argv[kk],"-fmt") == 0) {
				strncpy(file_fmt,argv[kk+1],256);
			}
		}
	}

	/* --- camera model and GPS datation ---*/
	if (cam->raptor_model == RAPTOR_UNKNOWN) {
		//cam->raptor_model = RAPTOR_KINGFISHER ; // read camera.h to know the supported models
		cam->raptor_model = RAPTOR_NINOX ; // read camera.h to know the supported models
	}
	if (strcmp(file_fmt,"")==0) {
		if (cam->raptor_model == RAPTOR_NINOX ) {
			//strcpy(cam->config,"C:/Users/klotz/Documents/audela/raptor_ninox.fmt");
			strcpy(cam->config,"C:/Users/ninox/Documents/audela/Ninox_de_Guillaume_32_bit.fmt");
		}
		if (cam->raptor_model == RAPTOR_EAGLE ) {
			strcpy(cam->config,"C:/Users/Public/Documents/EPIX/XCAP/data/eagle1.fmt");
		}
		if (cam->raptor_model == RAPTOR_KINGFISHER ) {
			strcpy(cam->config,"C:/audela/kingfischer_cemes.fmt");
		}
	} else {
		strcpy(cam->config,file_fmt);
	}
	cam->gps_model = GPS_NONE ;

	/* --- camera configuration ---*/
	if ( strlen(cam->config) == 0 ) {
		//Default Pixci init
		ret = pxd_PIXCIopen("","","");
		if (ret) {
			sprintf(texte," (error code = %d)",ret);
			pxd_mesgFaultText(0x1,cam->msg,2048);
			strcat(cam->msg,texte);
			return 1;
		}

		//default video mode dependent parameters
		// ---> they change according to the camera
		cam->maxw = pxd_imageXdim();
		cam->maxh = pxd_imageYdim();
		cam->minx = 0;
		cam->miny = 0;
		cam->maxx = cam->maxw-1;
		cam->maxy = cam->maxh-1;
		/**/
		cam->minbinx = 1;
		cam->minbiny = 1;
		cam->maxbinx = 1;
		cam->maxbiny = 1;

		//default parameters
		cam->x1=0;
		cam->y1=0;
		cam->x2=cam->maxx;
		cam->y2=cam->maxy;
		cam->h=cam->maxh;
		cam->w=cam->maxw;
		cam->binx=1;
		cam->biny=1;
	} else {
		//Pixci init with external config file
		ret = pxd_PIXCIopen("","",cam->config);
		if (ret) {
			sprintf(texte," (error code = %d)",ret);
			pxd_mesgFaultText(0x1,cam->msg,2048);
			strcat(cam->msg,texte);
			return 1;
		}
		cam->maxw = pxd_imageXdim();
		cam->maxh = pxd_imageYdim();
		cam->minx = 0;
		cam->miny = 0;
		cam->maxx = cam->maxw-1;
		cam->maxy = cam->maxh-1;
		cam->minbinx = 1;
		cam->minbiny = 1;
		cam->maxbinx = 1;
		cam->maxbiny = 1;
		cam->x1=0;
		cam->y1=0;
		cam->x2=cam->maxx;
		cam->y2=cam->maxy;
		cam->h=cam->maxh;
		cam->w=cam->maxw;
		cam->binx=1;
		cam->biny=1;

	}
	cam->nb_photox=cam->maxw;
	cam->nb_photoy=cam->maxh;

	kk=pxd_imageXdim();
	kk=pxd_imageYdim();
	kk=pxd_imageZdim();
	d=pxd_imageAspectRatio();

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

	// --- Get camera manufacturers data
	ret = cam_read_initialization(cam);
	if (ret) {
		sprintf(texte,"cam_read_initialization returns %d. %s",ret,cam->msg);
		strcpy(cam->msg,texte);
		return 4;
	}

	// --- Set camera manufacturers data
	ret = cam_set_initialization(cam);
	if (ret) {
		sprintf(texte,"cam_set_initialization returns %d. %s",ret,cam->msg);
		strcpy(cam->msg,texte);
		return 5;
	}


	//default image parameters
	// ---> they can change according to the camera
	strcpy(cam->pixels_classe,"CLASS_GRAY");
	strcpy(cam->pixels_format,"FORMAT_USHORT");
	strcpy(cam->pixels_compression,"COMPRESS_NONE");
	cam->pixel_data = NULL;
	strcpy(cam->msg,"");

	if (cam->gps_model == GPS_SCHIAVON) {
#if defined (OS_LIN)
		//initializes the timestamp structures
		ts = (struct timeval *)calloc(cam->max_buf+1,sizeof(struct timeval));
#endif

		//SIGUSR2 at the end of lecture
#if defined(OS_WIN)
		cam->hEvent = pxd_eventCapturedFieldCreate(0x1);
		if (cam->hEvent==NULL) {
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
		if (hwin==NULL) {
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

#if defined (OS_LIN)
		sigemptyset(&mask);
		sigaddset(&mask,SIGUSR2);
		signal(SIGUSR2,handler_lecture);
		signal(SIGUSR1,handler_acquisition);
#endif
	}

	return 0;

}

int cam_close(struct camprop * cam)
{
	int ret;

#if defined (OS_LIN)
	free(ts);
#endif

	ret = pxd_PIXCIclose();
	if (ret) {
		pxd_mesgFaultText(0x1,cam->msg,2048);
		return 4;
	}

	return 0;

}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
	int ret;
	int mode=0;
	double exptime,frame_periode,frq,delay;

	// --- set pixel readout clock ---
	if (cam->raptor_model == RAPTOR_EAGLE ) {
		mode=0; // 2 MHz
		setPixelReadoutClock(cam->raptor_model,&mode);
	}

   // --- set shutter ---
	if (cam->shutterindex == 0) {
		mode=0x00; // closed
	} else if (cam->shutterindex == 1) {
		mode=0x02; // synchro
	} else {
		mode=0x01; // always opened
	}
	setShutterControlSatus(cam->raptor_model,&mode);

	// --- set binning
	setXBinning(cam->raptor_model,&cam->binx);
	setYBinning(cam->raptor_model,&cam->biny);
	cam_update_window(cam);

	// --- set exposure time and frame rate
	ret = getExposure(cam->raptor_model,&exptime);
	ret = getFrameRate(cam->raptor_model,&frq);
	frame_periode = 1./frq;
	delay = 10e-3;
	if (cam->exptime > frame_periode) {
		frame_periode = cam->exptime + delay;
		cam->frameRate = 1./frame_periode;
		ret = cam_set_framerate(cam,cam->frameRate);
		ret = setExposure(cam->raptor_model,cam->exptime);
	} else {
		ret = setExposure(cam->raptor_model,cam->exptime);
		frame_periode = cam->exptime + delay;
		cam->frameRate = 1./frame_periode;
		ret = cam_set_framerate(cam,cam->frameRate);
	}

	// --- start exposure
	ret = pxd_goUnLive(0x1); // evite camera in use lors de goSnap suivant
	if (ret) {
		sprintf(cam->msg,"Start exposition failed a tpxd_goAbortLive: %s",pxd_mesgErrorCode(ret));
		return;
	}
	libcam_sleep(50);
	ret = pxd_goSnap(0x1,1);
	if (ret) {
		sprintf(cam->msg,"Start exposition failed at pxd_goSnap: %s",pxd_mesgErrorCode(ret));
		return;
	}

	if (cam->gps_model == GPS_SCHIAVON) {
#if defined (OS_LIN)
		usr_interrupt=0;
#endif
		//set trigger mode to snapshot (single acquisition via snapshot)
		ret = setTrigger(cam->raptor_model,TRG_INT);
		if (ret) {
			sprintf(cam->msg, "setTrigger returns %d", ret);
			return;
		}
	}

}

void cam_stop_exp(struct camprop *cam)
{
	int ret;

	if (cam->gps_model == GPS_SCHIAVON) {
		//ret = setTrigger(TRG_ABORT);
		ret = setTrigger(cam->raptor_model,TRG_INT);
		if (ret) {
			sprintf(cam->msg,"Trigger abort failed");
			return;
		}
	}

}

void cam_read_ccd(struct camprop *cam, float *p)
{
	int ret=0,k;
	//int first,last;
	int x1,x2,y1,y2;

	if (cam->gps_model == GPS_SCHIAVON) {
#if defined (OS_LIN)
		struct timeval t,texp,tbeg;

		sigprocmask(SIG_BLOCK,&mask,&oldmask);
		while (!usr_interrupt) {
			sigsuspend(&oldmask);
		}
		sigprocmask(SIG_UNBLOCK,&mask,NULL);
#endif
#if defined(OS_WIN)
		WaitForSingleObject(cam->hEvent, INFINITE);
#endif
	}

//	ret = pxd_goAbortLive(0x1); // evite camera in use lors de goSnap suivant
	/*
	first = pxd_goneLive(0x1, 0);
	k=0;
	do {
		libcam_sleep(50); // ms
		last = pxd_goneLive(0x1, 0);
		k+=50;
	} while(last!=0);
	*/
	libcam_sleep(200); // ms

	//copy the data from the last frame buffer to the buffer p
	//int pixelNb = pxd_imageXdim()*pxd_imageYdim();
	int pixelNb = cam->h*cam->w;
	x1 = (int)(cam->x1 / cam->binx);
	y1 = (int)(cam->y1 / cam->biny);
	x2 = x1+ cam->w -1 ;
	y2 = y1+ cam->h -1 ;

	cam->frameno = pxd_capturedBuffer(0x01);

   unsigned short * pushort = (unsigned short*) malloc(pixelNb*sizeof(unsigned short));
	ret = pxd_readushort(0x1,cam->frameno,x1,y1,x2+1,y2+1,pushort,pixelNb,"Grey"); // Eagle Ninox
	//ret = pxd_readushort(0x1,1,cam->x1,cam->y1,cam->x2+1,cam->y2+1,pushort,pixelNb,"Grey");
	if ( ret<0 ) {
		strcpy(cam->msg,pxd_mesgErrorCode(ret));
      free(pushort);
		return;
	}
	
	k=0;
   while(pixelNb--) {
		p[k] = (float)pushort[k]; k++ ;
   }
   
   free(pushort);

	if (cam->gps_model == GPS_SCHIAVON) {
#if defined (OS_LIN)
		//print the computer date (taken from the pixci driver)
		t = ts[cam->max_buf];
		//end of the obeservation
			  char message[50];
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
#endif
	}

}

void cam_shutter_on(struct camprop *cam)
{
	int mode=0;
	if (cam->shutterindex == 1) {
		mode=0x02; // synchro
	} else {
		mode=0x01; // opened
	}
	setShutterControlSatus(cam->raptor_model,&mode);
}

void cam_shutter_off(struct camprop *cam)
{
	int mode=0;
	setShutterControlSatus(cam->raptor_model,&mode);
	cam->shutterindex=0;
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
	double t_celcius=0;

	ret = getSensorTemp(cam->raptor_model,&t_ADC,cam->ADC_0,cam->ADC_40,&t_celcius);
	if (ret) {
		sprintf(cam->msg, "getSensorTemp returns %d\n", ret);
		return;
	}
	cam->temperature = t_celcius;
}

void cam_cooler_on(struct camprop *cam)
{
	int ret;
	int status[8];
	ret = getFPGACTRLreg(cam->raptor_model,status);
	status[ENABLE_TEC]=1; // TEC ok		
	status[ENABLE_FAN]=1; // Fan ok			
	ret = setFPGACTRLreg(cam->raptor_model,status);
	if (ret) {
		sprintf(cam->msg, "setTEC(TEC_ON) returns %d\n", ret);
		return;
	}
	ret = setTECsetpoint(cam->raptor_model,cam->check_temperature,cam->DAC_0,cam->DAC_40);
	if (ret) {
		sprintf(cam->msg, "setTEC(TEC_ON) returns %d\n", ret);
		return;
	}
	cam->cooler = 1;
}

void cam_cooler_off(struct camprop *cam)
{
	int ret;
	int status[8];
	ret = getFPGACTRLreg(cam->raptor_model,status);
	status[ENABLE_TEC]=0; // TEC off		
	ret = setFPGACTRLreg(cam->raptor_model,status);
	if (ret) {
		sprintf(cam->msg, "setTEC(TEC_ON) returns %d\n", ret);
		return;
	}
	cam->cooler = 0;
}

void cam_cooler_check(struct camprop *cam)
{
	int ret,t_adu;
	double t_celcius;
	ret = getTECtemp(cam->raptor_model, &t_adu, cam->DAC_0, cam->DAC_40, &t_celcius);
	ret = setTECsetpoint(cam->raptor_model,cam->check_temperature,cam->DAC_0,cam->DAC_40);
	if (ret) {
		sprintf(cam->msg, "setTECsetpoint returns %d\n", ret);
		return;
	}
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
	setXBinning(cam->raptor_model,&binx);
	setYBinning(cam->raptor_model,&biny);
	cam->binx = binx;
	cam->biny = biny;
}

void cam_update_window(struct camprop *cam)
{
    int maxx, maxy,size;
	 int x1,y1,x2,y2;

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

	x1 = (int)(cam->x1 / cam->binx);
	y1 = (int)(cam->y1 / cam->biny);
	x2 = x1+ cam->w;
	y2 = y1+ cam->h;
   
	setROIxsize(cam->raptor_model,x2-x1+1);
	setROIxoffset(cam->raptor_model,x1);
	setROIysize(cam->raptor_model,y2-y1+1);
	setROIyoffset(cam->raptor_model,y1);
	getROIxoffset(cam->raptor_model,&x1);
	getROIyoffset(cam->raptor_model,&y1);
	getROIxsize(cam->raptor_model,&size);
	x2 = x1 + size -1;
	getROIysize(cam->raptor_model,&size);
	y2 = y1 + size -1;

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
// OK for RAPTOR_OWL320 RAPTOR_EAGLE
int cam_read_initialization(struct camprop *cam) {
	int ret,k;
	uchar data[18];
	char texte[256];
	int status[8];
	int raptor_model=cam->raptor_model;
	double exp,frq;

	strcpy(cam->microVersion,"");
	strcpy(cam->fpgaVersion,"");
	for (k=0;k<18;k++) { data[k]=0; }
	cam->serialNumber=0;
	strcpy(cam->build,"");
	cam->ADC_0 = 0;
	cam->ADC_40 = 1;
	cam->DAC_0 = 0;
	cam->DAC_40 = 1;

	if ( (cam->raptor_model == RAPTOR_OWL320) || (raptor_model == RAPTOR_OWL640) ||  (raptor_model == RAPTOR_NINOX) || (raptor_model == RAPTOR_EAGLE ) || (raptor_model == RAPTOR_KINGFISHER ) ) {

		// System state must enable ACK 
		ret = getSystemState(cam->raptor_model,status);
		status[ENABLE_COMMAND_ACK]=1;
		ret = setSystemState(cam->raptor_model,status);
		libcam_sleep(50); // Attente pour Ninox (Eagle n'en n'a pas besoin)

		// Get Micro Version
		ret = getMicroVersion(cam->raptor_model,data);
		if (ret) {
			sprintf(texte," (error code = %d)",ret);
			strcpy(cam->msg,pxd_mesgErrorCode(ret));
			strcat(cam->msg,texte);
			return 1;
		}
		sprintf(cam->microVersion,"%d.%d",data[0],data[1]);

		// Get FPGA Version
		ret = getFPGAversion(cam->raptor_model,data);
		if (ret) {
			return 2;
		}
		sprintf(cam->fpgaVersion,"%d.%d",data[0],data[1]);

		// System state must have bit 0 set = 1 to enable comms to FPGA
		ret = getSystemState(cam->raptor_model,status);
		status[ENABLE_COMMS_TO_FPGA]=1;
		ret = setSystemState(cam->raptor_model,status);

		// then we can communicate with FPGA
		ret = getManuData(cam->raptor_model,data);
		if (ret) {
			sprintf(texte," (error code = %d)",ret);
			strcpy(cam->msg,pxd_mesgErrorCode(ret));
			strcat(cam->msg,texte);
			return 3;
		}
		cam->serialNumber = (int)*((uint16 *)(&data[0]));
		sprintf(cam->build,"%02d/%02d/%02d %c%c%c%c%c",data[2],data[3],data[4],data[5],data[6],data[7],data[8],data[9]);
		cam->ADC_0 = (int)*((uint16 *)(&data[10]));
		cam->ADC_40 = (int)*((uint16 *)(&data[12]));
		cam->DAC_0 = (int)*((uint16 *)(&data[14]));
		cam->DAC_40 = (int)*((uint16 *)(&data[16]));

		// Not enable comms to FPGA (only for Eagle ?)
		ret = getSystemState(cam->raptor_model,status);
		status[ENABLE_COMMS_TO_FPGA]=0;
		ret = setSystemState(cam->raptor_model,status);

		//constraints (video mode independent)
		// ---> they change according to the camera
		cam->max_buf = get_max_frame_buffer_size(cam->raptor_model);

		cam->min_exposure = get_min_exposure(cam->raptor_model);
		cam->max_exposure = get_max_exposure(cam->raptor_model);
		getExposure(raptor_model,&exp);
		cam->exptime=(float)exp;
		cam->max_frameRate = get_max_frame_rate(cam->raptor_model,0);
		getFrameRate(raptor_model,&frq);
		cam->frameRate=frq;

		getXBinning(cam->raptor_model,&cam->binx);
		getYBinning(cam->raptor_model,&cam->biny);

		ret=get_digital_video_gain(cam->raptor_model,&cam->digital_gain);
	}
	// TODO other cameras

	return 0;
}

int cam_set_initialization(struct camprop *cam) {
	int ret,val;
	int raptor_model=cam->raptor_model;
	//uchar system_status;
	int status[8];
	double digital_gain=1;

	cam->frameno=1;
	if ( raptor_model == RAPTOR_OWL320 ) {
		cam->max_digital_gain=256;
		// --- Set System state
		ret = setState(cam->raptor_model,ACK_ON|UNHOLD_FPGA);
		if (ret) {
			sprintf(cam->msg,"setState returns %d",ret);
			return 3;
		}
		//set gain
		ret = cam_set_digital_video_gain(cam,cam->digital_gain);
		if (ret) {
			sprintf(cam->msg, "cam_set_digital_video_gain failed");
			return -3;
		}
		cam->exptime=(float)0.01;
		// thermoelectric cooler = on
		// autoexposure = off
		ret = setTEC_AEXP(cam->raptor_model,TEC_ON|AEXP_OFF);
		if (ret) {
			sprintf(cam->msg, "setTEC_AEXP returns %d\n", ret);
			return -8;
		}
		// nuc (no correction)
		ret = setNUCstate(cam->raptor_model,NUC_NORMAL);
		if (ret) {
			sprintf(cam->msg, "setNUC returns %d\n", ret);
			return -9;
		}
		//set standard dynamic => 0 = high gain (1= low gain)
		ret = cam_set_dynamic(cam,0);
		if (ret) {
			sprintf(cam->msg,"cam_set_dynamic failed");
			return -7;
		}

		cam->video = 0;
		//set trigger mode to external (no acquisition)
		ret = setTrigger(cam->raptor_model,0x00);
		if (ret) {
			sprintf(cam->msg, "setTrigger returns %d\n", ret);
			return -6;
		}
	}	else if ( (raptor_model == RAPTOR_OWL640) ||  (raptor_model == RAPTOR_NINOX) ) {
		int default_auto_exp=0; // no ALC
		cam->max_digital_gain=256;
		ret = getFPGACTRLreg(cam->raptor_model,status);
		status[ENABLE_TEC]=1; // TEC ok		
		status[ENABLE_FAN]=1; // fan ok		
		status[ENABLE_AUTO_EXP]=default_auto_exp; // no ALC
		ret = setFPGACTRLreg(cam->raptor_model,status);
		libcam_sleep(50);
		ret = getTrigMode(cam->raptor_model,status);
		status[SELECT_HIGH_GAIN]=0; // =1 high gain
		//status[SELECT_HG_TRIG_MODE2]=1;
		status[ENABLE_EXTERNAL_TRIGGER]=0; // =0 no external trigger
		ret = setTrigMode(cam->raptor_model,status);
		if (default_auto_exp==0) {
			ret = setNUCstate(cam->raptor_model,NUC_NORMAL); // exp manual
		} else {
			ret = setNUCstate(cam->raptor_model,NUC_OFFSET_GAIN_DARK); // no ALC
		}
		libcam_sleep(50);
		cam->digital_gain=1;
		ret=set_digital_video_gain(cam->raptor_model,cam->digital_gain);
		libcam_sleep(50);
		ret=get_digital_video_gain(cam->raptor_model,&digital_gain); // pour verifier
		//
		// --- set exposure time
		cam->exptime=(float)0.1; // default value
		ret = setExposure(cam->raptor_model,cam->exptime);
		//set frame rate (a tester)
		cam->frameRate=1./(cam->exptime+10e-3);
		ret = cam_set_framerate(cam,cam->frameRate);
	}	else if ( (raptor_model == RAPTOR_EAGLE ) ) {
		// --- EAGLE inits
		val=0x01; // normal readout
		ret = setReadoutMode(cam->raptor_model,&val); 
		ret = getFPGACTRLreg(cam->raptor_model,status);
		status[ENABLE_TEC]=0; // no TEC enable
		ret = setFPGACTRLreg(cam->raptor_model,status);
		ret = getTrigMode(cam->raptor_model,status);
		status[SELECT_SNAPSHOT_VIDEO]=1; // =1 select snapshot
		status[SELECT_FRAME_RATE_FIXED_CONT]=0; // =0 fixed rate
		status[START_CONT_SEQUENCE]=1; // =1 no continuous sequence
		status[ENABLE_EXTERNAL_TRIGGER]=0; // =0 no external trigger
		ret = setTrigMode(cam->raptor_model,status);
		val=0; // 2MHz reading
		ret = setPixelReadoutClock(cam->raptor_model,&val);
		cam->exptime=1;
	}	else if ( (raptor_model == RAPTOR_KINGFISHER ) ) {
		// --- KINGFISHER inits
		ret = getFPGACTRLreg(cam->raptor_model,status);
		status[ENABLE_TEC]=0; // no TEC enable
		ret = setFPGACTRLreg(cam->raptor_model,status);
		setReadoutMode(cam->raptor_model,0x00); // snapshot
		cam->exptime=1;
	}

	//set binning
	cam->binx=1;
	cam->biny=1;
	cam_set_binning(cam->binx,cam->biny,cam);
	if ( strlen(cam->msg) != 0 ) {
		sprintf(cam->msg, "cam_set_binning failed: %s\n",cam->msg);
		return -1;
	}

	//set window
	cam->x1=0;
	cam->y1=0;
	cam->x2=cam->w-1;
	cam->y2=cam->h-1;
	cam_update_window(cam);

	ret = pxd_goAbortLive(0x1); // evite camera in use lors de goSnap suivant
	if (ret) {
		sprintf(cam->msg,"Failed at pxd_goAbortLive: %s",pxd_mesgErrorCode(ret));
		return -2;
	}

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

	if ( (setROIxoffset(cam->raptor_model,x1)==0) && (setROIyoffset(cam->raptor_model,y1)==0) && (setROIxsize(cam->raptor_model,w)==0) && (setROIysize(cam->raptor_model,h)==0) )	{
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

	cam->max_buf = get_max_frame_buffer_size(cam->raptor_model);

	return 0;
}

//set the frame rate (at most it sets max_frameRate)
int cam_set_framerate(struct camprop *cam, double frate) { 
	double fr;
	fr = (frate > cam->max_frameRate) ? cam->max_frameRate : frate;
	if ( setFrameRate(cam->raptor_model,fr) == 0 ) {
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
	e = (exp < cam->min_exposure) ? cam->min_exposure : exp;
	//e=exp;
	if ( setExposure(cam->raptor_model,e) == 0 ) {
		cam->exptime = (float)e;
	}	else {
		sprintf(cam->msg,"Unable to set exposure");
		return -1;
	}
	return 0;
}

//set the gain (at most it sets max_gain)
int cam_set_digital_video_gain(struct camprop *cam, double gain) { 
	double g;

	g = (gain > cam->max_digital_gain) ? cam->max_digital_gain : gain;

	if ( set_digital_video_gain(cam->raptor_model,g) == 0 ) {
		cam->digital_gain = g;
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

		if ( setDynamicRange(cam->raptor_model,HIGH_DYNAMIC) == 0 ) {
			cam->dynamicRange=1;
		} else {
			sprintf(cam->msg,"Unable to set high dynamic range");
			return -2;
		}
	} else {
		if ( setDynamicRange(cam->raptor_model,STD_DYNAMIC) == 0 ) {
			cam->dynamicRange=0;
		} else {
			sprintf(cam->msg,"Unable to set standard dynamic range");
			return -3;
		}
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
		strcpy(cam->msg,pxd_mesgErrorCode(ret));
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
		strcpy(cam->msg,pxd_mesgErrorCode(ret));
		return ret;
	}

	return 0;
}


//start a video sequence
/*
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
*/

#if defined (OS_LIN)
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
#endif
