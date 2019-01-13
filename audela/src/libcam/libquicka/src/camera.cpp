/* camera.c
 * 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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
#include <windows.h>
#endif

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <math.h>

#include "camera.h"
#include "ftd2xx.h"

//#define LIBQUICKA_LOGFILE

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Audine",			/* camera name */
     "audine",			/* camera product */
     "kaf401",			/* ccd name */
     768, 512,			/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Audine",			/* camera name */
     "audine",			/* camera product */
     "kaf1602",			/* ccd name */
     1536, 1024,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Audine",			/* camera name */
     "audine",			/* camera product */
     "kaf3200",			/* ccd name */
     2184, 1472,		/* maxx maxy 2175, 1442 */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     6.8e-6, 6.8e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
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

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop *cam);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
    cam_init,			/* init */
    cam_close,			/* close */
    cam_set_binning,		/* set_binning */
    cam_update_window,		/* update_window */
    cam_start_exp,		/* start_exp */
    cam_stop_exp,		/* stop_exp */
    cam_read_ccd,		/* read_ccd */
    cam_shutter_on,		/* shutter_on */
    cam_shutter_off,		/* shutter_off */
    NULL,			/* ampli_on */
    NULL,			/* ampli_off */
    cam_measure_temperature,	/* measure_temperature */
    cam_cooler_on,		/* cooler_on */
    cam_cooler_off,		/* cooler_off */
    cam_cooler_check		/* cooler_check */
};

static int quicka_start(struct camprop *cam);
static int quicka_read(struct camprop *cam, float *p);
short usb_start(short KAF,short x1,short y1,short x2,short y2,
                                              short bin_x,short bin_y,short shutter,
                                              short shutter_mode,short ampli_mode,
                                              short acq_mode,short d1,short d2,short speed,
                                              short *imax,short *jmax);
short usb_readaudine(short imax,short jmax, float *p);
short usb_write(short v);

void libcam_sleep(int ms);
void libcam_swap(int *a, int *b);

FT_HANDLE ftHandle ;
unsigned long lastStatus;
   
/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

//#define QUICKA_DEBUG

int cam_init(struct camprop *cam, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
/* cam::create quicka usb */
{
   FT_STATUS status;
   int index;
	char s[2048];
#ifdef QUICKA_DEBUG
   FT_STATUS ftStatus;
   int i;
	char ss[256];
   #ifdef __linux__
		DWORD pdwVID,pdwPID;
   #endif
	DWORD lpdwNumDevs,numDevs;
	FT_DEVICE_LIST_INFO_NODE *devInfo;
	FT_HANDLE ftHandleTemp; 
	DWORD Flags; 
	DWORD ID; 
	DWORD Type; 
	DWORD LocId; 
	char SerialNumber[16]; 
	char Description[64];
#endif

   // je recupere l'index de la quickaudine
   sscanf(cam->portname,"quickaudine%d",&index);
	strcpy(s,"");
#ifdef QUICKA_DEBUG
printf("ETAPE 1\n");
   #ifdef __linux__
		status=FT_GetVIDPID(&pdwVID,&pdwPID);
		sprintf(ss,"{FT_GetVIDPID: status=%d pdwVID=%d pdwPID=%d} ",status,pdwVID,pdwPID);
		strcat(s,ss); printf("%s",ss);
   #endif
	status=FT_CreateDeviceInfoList(&lpdwNumDevs);
	sprintf(ss,"{FT_CreateDeviceInfoList: status=%d lpdwNumDevs=%d} ",status,lpdwNumDevs);
	strcat(s,ss); printf("%s\n",ss);
	//status=FT_GetDeviceInfoList(&pDest,&lpdwNumDevs);
	//sprintf(ss,"{FT_GetDeviceInfoList: status=%p lpdwNumDevs=%d} ",&pDest,lpdwNumDevs);
	//strcat(s,ss);
	numDevs=lpdwNumDevs;
	if (numDevs > 0) { 
		// allocate storage for list based on numDevs 
		devInfo = (FT_DEVICE_LIST_INFO_NODE*)malloc(sizeof(FT_DEVICE_LIST_INFO_NODE)*numDevs); 
		// get the device information list 
		ftStatus = FT_GetDeviceInfoList(devInfo,&numDevs); 
		sprintf(ss,"{FT_GetDeviceInfoList: status=%d numDevs=%d  ",ftStatus,numDevs);
		strcat(s,ss); printf("%s\n",ss);
		if (ftStatus == FT_OK) { 
			for (i = 0; i < (int)numDevs; i++) { 
				sprintf(ss," {Dev=%d ",i); 
				strcat(s,ss); printf("%s\n",ss);
				sprintf(ss," Flags=0x%x ",devInfo[i].Flags); 
				strcat(s,ss); printf("%s\n",ss);
				sprintf(ss," Type=0x%x ",devInfo[i].Type); 
				strcat(s,ss); printf("%s\n",ss);
				sprintf(ss," ID=0x%x ",devInfo[i].ID); 
				strcat(s,ss); printf("%s\n",ss);
				sprintf(ss," LocId=0x%x ",devInfo[i].LocId); 
				strcat(s,ss); printf("%s\n",ss);
				sprintf(ss," SerialNumber=%s ",devInfo[i].SerialNumber); 
				strcat(s,ss); printf("%s\n",ss);
				sprintf(ss," Description=%s ",devInfo[i].Description); 
				strcat(s,ss); printf("%s\n",ss);
				sprintf(ss," ftHandle=0x%x} ",devInfo[i].ftHandle); 
				strcat(s,ss); printf("%s\n",ss);
			} 
		} 
		sprintf(ss,"} ");
		strcat(s,ss); printf("%s\n",ss);
		free(devInfo);
	}
	if (numDevs > 0) { 
		// get information for device 0 
		ftStatus = FT_GetDeviceInfoDetail(0, &Flags, &Type, &ID, &LocId, SerialNumber, Description, &ftHandleTemp); 
		sprintf(ss,"{FT_GetDeviceInfoDetail: ");
		strcat(s,ss); printf("%s\n",ss);
		if (ftStatus == FT_OK) { 
			sprintf(ss," {Dev=0:"); 
			strcat(s,ss); printf("%s\n",ss);
			sprintf(ss," Flags=0x%x",Flags); 
			strcat(s,ss); printf("%s\n",ss);
			sprintf(ss," Type=0x%x",Type);
			strcat(s,ss); printf("%s\n",ss);
			sprintf(ss," ID=0x%x",ID); 
			strcat(s,ss); printf("%s\n",ss);
			sprintf(ss," LocId=0x%x",LocId); 
			strcat(s,ss); printf("%s\n",ss);
			sprintf(ss," SerialNumber=%s",SerialNumber); 
			strcat(s,ss); printf("%s\n",ss);
			sprintf(ss," Description=%s",Description); 
			strcat(s,ss); printf("%s\n",ss);
			sprintf(ss," ftHandle=0x%x} ",ftHandleTemp); 
			strcat(s,ss); printf("%s\n",ss);
		} 
		sprintf(ss,"} "); printf("%s\n",ss);
		strcat(s,ss);
	}
printf("ETAPE 10\n");
#endif

   status = FT_Open(index,&ftHandle);
   if (status != FT_OK) {
      sprintf(cam->msg, "Can't open FTDI device %s on port index=%d : Error number %ld. %s", cam->portname, index, status,s);
      return -1;
   }

   /*cam->delayshutter = 1.2; */
   cam->delayshutter = 0.0;
   cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
   cam->authorized = 1;
   cam->speed = (short) 2;
   return 0;
}

int cam_close(struct camprop *cam)
{
   FT_STATUS status;

   if( ftHandle != NULL ) {
      status = FT_Close(ftHandle);
      if (status != FT_OK) {
         return -1;
      }
   }
   return 0;
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
    if (cam->authorized == 1) {
	quicka_start(cam);
    }
}

void cam_stop_exp(struct camprop *cam)
{
}

void cam_read_ccd(struct camprop *cam, float *p)
{
    short r;
	 int rr;
    if (p == NULL)
	return;
    if (cam->authorized == 1) {
	r = usb_write(255);	/*' CCD amplifier on */
	libcam_sleep(100);	/*' small delay */
	/* shutter always off for synchro and closed mode */
	if (cam->shutterindex <= 1) {
	    r = usb_write(255);	/*' Close the shutter */
   } else {
	    r = usb_write(255);	 // obligé d'envoyer 255, car ça plante si on envoie une autre valeur ou si on n'envoie rien
   }
	rr=quicka_read(cam, p);
	if (rr!=0) {
		/* traiter le cas d'un blocage de la liaison USB */
	}
    }
}

void cam_shutter_on(struct camprop *cam)
{
}

void cam_shutter_off(struct camprop *cam)
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
    if (binx <= 0)
	binx = 1;
    if (binx == 2)
	binx = 2;
    if (binx == 3)
	binx = 3;
    if (binx >= 4)
	binx = 4;
    if (biny <= 0)
	biny = 1;
    if (biny == 2)
	biny = 2;
    if (biny == 3)
	biny = 3;
    if (biny >= 4)
	biny = 4;
    cam->binx = binx;
    cam->biny = biny;
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy, iswap;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   if (cam->x1 > cam->x2) {
      iswap= cam->x1;
      cam->x1 = cam->x2;
      cam->x2 = iswap;
   }
   if (cam->x1 < 0) {
      cam->x1 = 0;
   }
   if (cam->x2 > maxx - 1) {
      cam->x2 = maxx - 1;
   }
   
   if (cam->y1 > cam->y2) {
      iswap= cam->y1;
      cam->y1 = cam->y2;
      cam->y2 = iswap;
   }
   if (cam->y1 < 0) {
      cam->y1 = 0;
   }
   if (cam->y2 > maxy - 1) {
      cam->y2 = maxy - 1;
   }
   cam->w = ( cam->x2 - cam->x1) / cam->binx + 1;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = ( cam->y2 - cam->y1) / cam->biny + 1;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;

   if (cam->x2 > maxx - 1) {
      cam->w = cam->w - 1;
      cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   }
   
   if (cam->y2 > maxy - 1) {
      cam->h = cam->h - 1;
      cam->y2 = cam->y1 + cam->h * cam->biny - 1;
   }

}

void cam_ampli_on(struct camprop *cam)
{
}

void cam_ampli_off(struct camprop *cam)
{
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

int quicka_start(struct camprop *cam)
{
    short r;
    short KAF, x1, y1, x2, y2, bin_x, bin_y, shutter, shutter_mode,
	ampli_mode, program, d1, d2, speed, imax, jmax;
    double delay;
#if defined(LIBQUICKA_LOGFILE)
    FILE * f;
    f = fopen("quicka.txt", "at");
    fprintf(f, "========================================\n");
    fclose(f);
#endif
    KAF = (short) (1 + cam->index_cam);
    bin_x = cam->binx;
    bin_y = cam->biny;

    // Calcul des abscisses de la fenetre
    x1 = (short) (1 + 1. * cam->x1 / bin_x);
    x2 = (short) (1 + 1. * cam->x2 / bin_x);
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    fprintf(f,"<LIBQUICKA/quicka_start:%d> cam->mirrorv=%d",__LINE__,cam->mirrorv);
    fprintf(f,"<LIBQUICKA/quicka_start:%d>   x1=%d, x2=%d",__LINE__,x1,x2);
    fclose(f);
#endif
    if (cam->mirrorv == 1) {
	int tmp;
	x1 = cam->nb_photox / bin_x - ( x1 - 1 );
	tmp = cam->nb_photox / bin_x - ( x2 - 1 );
	x2 = x1;
	x1 = tmp;
    }
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    sprintf(f,"<LIBQUICKA/quicka_start:%d>   -> x1=%d, x2=%d",__LINE__,x1,x2);
    fclose(f);
#endif

    // Calcul des ordonnees de la fenetre
    y1 = (short) (1 + 1. * cam->y1 / bin_y);
    y2 = (short) (1 + 1. * cam->y2 / bin_y);
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    fprintf(f,"<LIBQUICKA/quicka_start:%d> cam->mirrorh=%d",__LINE__,cam->mirrorh);
    fprintf(f,"<LIBQUICKA/quicka_start:%d>   y1=%d, y2=%d",__LINE__,y1,y2);
    fclose(f);
#endif
    if (cam->mirrorh == 1) {
	int tmp;
	y1 = cam->nb_photoy / bin_y - ( y1 - 1 );
	tmp = cam->nb_photoy / bin_y - ( y2 - 1 );
	y2 = y1;
	y1 = tmp;
    }
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    sprintf(f,"<LIBQUICKA/quicka_start:%d>   -> y1=%d, y2=%d",__LINE__,y1,y2);
    fclose(f);
#endif

    if (cam->shutterindex == 0) {
	shutter = 0;
    } else {
	shutter = 1;
    }
    if (cam->shutteraudinereverse == 0) {
	shutter_mode = 0;
    } else {
	shutter_mode = 1;
    }
    if ((cam->ampliindex == 0) || (cam->ampliindex == 2)) {
	ampli_mode = 1;
    } else {
	ampli_mode = 0;
    }
    program = 1;		/* version of the QuickA internal program version */
    delay = cam->delayshutter;	/*delay in seconds between shutter close and effective reading of the images */
    if (delay > 2.4) {
	/*2.4 seconds is the max. value */
	d1 = (short) 0;
	d2 = (short) 15;
    } else {
	d1 = (short) 0;
	d2 = (short) (6.25 * delay);
    }
    speed = cam->speed;
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    fprintf(f, "Parametres passés à usb_start :\n");
    fprintf(f,
	    " KAF=%d fen=(%d %d %d %d) bin=(%d %d) shutter=(%d %d) ampli=%d program=%d d=(%d %d) speed=%d\n",
	    KAF, x1, y1, x2, y2, bin_x, bin_y, shutter, shutter_mode,
	    ampli_mode, program, d1, d2, speed);
    fclose(f);
#endif
	r =
	usb_start(KAF, x1, y1, x2, y2, bin_x, bin_y, shutter, shutter_mode,
		  ampli_mode, program, d1, d2, speed, &imax, &jmax);
#if defined(LIBQUICKA_LOGFILE)
    f = fopen("quicka.txt", "at");
    fprintf(f, "Sortie de usb_start :\n");
    fprintf(f, " (%d %d)\n", imax, jmax);
    fprintf(f, " r=%d\n", r);
    fclose(f);
#endif
    if (imax != (short) cam->w) {
	cam->w = (int) imax;
	cam->x2 = cam->x1 + cam->w;
    }
    if (jmax != (short) cam->h) {
	cam->h = (int) jmax;
	cam->y2 = cam->y1 + cam->h;
    }
    if (r == 12) {
	sprintf(cam->msg,
		"QuickAudine USB interface USB not ready : Error number %d",
		r);
	return r;
    }
    if (r == 16) {
	sprintf(cam->msg,
		"Dialog problem with the QuickAudine USB interface : Error number %d",
		r);
//  michel : a faire
	//usb_init();
	return r;
    }
    if (r == 17) {
	sprintf(cam->msg,
		"Error: USB data transmission error : Error number %d", r);
	return r;
    }
    return 0;
}

int quicka_read(struct camprop *cam, float *p)
{
    short r;
    short imax, jmax;
    imax = (short) cam->w;
    jmax = (short) cam->h;
    r = usb_readaudine(imax, jmax,  p);
    return r;
}


/************************* USB_START ******************************/
/* Initiate image parameters, clear CCD and start exposure        */
/* KAF=1 : KAF0400 CCD - KAF=2 : KAF1600 CCD                      */
/* KAF=3 : KAF3200 CCD                                            */
/* (x1,y1)-(x2,y2) : subframe coordinates                         */
/* (bin_x, bin_y) : binning factors                               */
/* shutter=0 : shutter always closed - shutter=1 : synchro        */
/* shutter_mode=0 : no inverted - shutter_mode=1 : inverted       */
/* ampli_mode=0 : amplifier on during exposure                    */
/* ampli_mode=1 : amplifier off during exposure                   */
/* acq_mode=1 (default mode)                                      */
/* (d1, d2) : delay between shutter activation and image reading  */
/*            duration = (d1+16.d2)*10 ms                         */
/* speed=6 : speed of the interface (between 1...15)              */ 
/* (imax, jmax) : pointers to calculated image format             */ 
/* Note: overscan mode -> negative value for x1                   */
/*                     -> y2>nx                                   */
/******************************************************************/
short usb_start(short KAF,short x1,short y1,short x2,short y2,
                                              short bin_x,short bin_y,short shutter,
                                              short shutter_mode,short ampli_mode,
                                              short acq_mode,short d1,short d2,short speed,
                                              short *imax,short *jmax)
{
   FT_STATUS status;
   short nb_fastclear,tmp,k;
   short X1_H_1,X1_L_2,X1_L_1;
   short X2_H_1,X2_L_2,X2_L_1;
   short Y1_H_1,Y1_L_2,Y1_L_1;
   short Y2_H_1,Y2_L_2,Y2_L_1;
   unsigned char tx[2],rx[2];
   DWORD Nb_RxOctets;
   short nx=0;
   
   if (KAF==4) 
      {
      // Error: CCD not supported
      return 13;
      }
   
   nb_fastclear=2;  // number of clear CCD cycle - max. value: 15
   
   if (x1>x2)  // Protect bad entry
      {
      tmp=x1;
      x1=x2;
      x2=tmp;
      }  
   
   if (y1>y2)  // Protect bad entry
      {
      tmp=y1;
      y1=y2;
      y2=tmp;
      }  
   
   
   if (KAF==1) nx=768; 
   if (KAF==2) nx=1536; 
   if (KAF==3) nx=2184; 
   if (x2>nx) return 14; // Error: Bad image format  
   if (y1<=0) return 14; 
   if (speed>15) speed=15;
   if (speed<1) speed=1;
   
   tmp=nx/bin_x-x2+1;  // Invert x1 & x2
   x2=nx/bin_x-x1+1;
   x1=tmp;
   
   *imax=x2-x1+1; // Actual size of the image
   *jmax=y2-y1+1;
   
   // y2++; // first line purge procedure (add internaly one line)
      
   X1_H_1 = x1 / 256;
   X1_L_2 = (x1 - X1_H_1 * 256) / 16;
   X1_L_1 = x1-X1_H_1 * 256 - X1_L_2 * 16;
   
   X2_H_1 = x2 / 256;
   X2_L_2 = (x2 - X2_H_1 * 256) / 16;
   X2_L_1 = x2 - X2_H_1 * 256 - X2_L_2 * 16;
   
   Y1_H_1 = y1 / 256;
   Y1_L_2 = (y1 - Y1_H_1 * 256) / 16;
   Y1_L_1 = y1-Y1_H_1 * 256 - Y1_L_2 * 16;
   
   Y2_H_1 = y2 / 256;
   Y2_L_2 = (y2 - Y2_H_1 * 256) / 16;
   Y2_L_1 = y2 - Y2_H_1 * 256 - Y2_L_2 * 16;
   
   tx[0]=0;
   tx[1]=acq_mode * 16;
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=KAF * 16;
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=bin_x * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=bin_y * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=X1_L_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=X1_L_2 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=X1_H_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=X2_L_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=X2_L_2 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=X2_H_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=Y1_L_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=Y1_L_2 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=Y1_H_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=Y2_L_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=Y2_L_2 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=Y2_H_1 * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=nb_fastclear * 16;      
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=shutter * 16;             
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=shutter_mode * 16;             
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=d1 * 16;         
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=d2 * 16;       
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=ampli_mode * 16;             
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=speed * 16;           
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=0 * 16;    // Reserved         
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=0 * 16;    // Reserved         
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   tx[0]=0;
   tx[1]=0 * 16;   // Reserved                    
   FT_Write(ftHandle,tx,2,&Nb_RxOctets);
   
   // Data ready ?
   k=0;
   FT_GetQueueStatus(ftHandle,&Nb_RxOctets);
   while (Nb_RxOctets==0) 
      {
      FT_GetQueueStatus(ftHandle,&Nb_RxOctets);
   #ifdef _WINDOWS
      Sleep(10); // TimeOut
   #endif
   #ifdef __linux__
      usleep(10000);
   #endif
      k++;
      if (k==2000) /* 200 changed by 2000 by A. Klotz on Jul. 2003 18th (k=308) */ 
         {
         // Error: Dialog problem with the USB interface
         return 16;  
         }
      }
   status = FT_Read(ftHandle,rx,1,&Nb_RxOctets); // CheckSum
   if ( status != FT_OK ||  (rx[0] & 240) / 16 != 11)
      {
      // Error: Data transmission error
      return 17;
      }

   return 0;
}


/************* USB_READAUDINE *************/
/* Transfer the image to the computer     */
/* (imax, jmax) : image format            */
/* p : pointer to the image               */
/******************************************/
short usb_readaudine(short imax,short jmax, float *p)
{
   int j=0;
   int v1,v2,v3,v4,v;
   int nb_pixel;
   int longueur_buffer=1024,deltat;  
   char ReadBuffer[1024];
   DWORD Nb_RxOctets;
   unsigned long i;
   time_t ltime0,ltime;
   long x = imax-1;
   long y = 0;
   long k = 0; 

   nb_pixel=(unsigned long)imax*jmax;

   while (j<=4*nb_pixel-longueur_buffer)  {
      FT_GetQueueStatus(ftHandle, &Nb_RxOctets);

      time( &ltime0 );
      while((int)Nb_RxOctets<longueur_buffer) {
         FT_GetQueueStatus(ftHandle, &Nb_RxOctets);
         time( &ltime );
         deltat=(int)(ltime-ltime0);
         if (deltat>10) { return 1; }
      }

      FT_Read(ftHandle,ReadBuffer,longueur_buffer,&Nb_RxOctets);

      for (i=0;i<Nb_RxOctets;i+=4)
      { 
         v1=(int)ReadBuffer[i] & 15;
         v2=(int)ReadBuffer[i+1] & 15;
         v3=(int)ReadBuffer[i+2] & 15;
         v4=(int)ReadBuffer[i+3] & 15;
         v=v1+16*v2+256*v3+4096*v4;
         long k = y * imax + x; 
         if (v>32767)
            p[k]=32767;
         else
            p[k]=(float)v;

         k++;
         
         if (x > 0) {
            x--;
         } else {
            x = imax -1;
            y++;
         }
      }
      j=j+longueur_buffer;
   } 

   if (j!=4*nb_pixel) {
      FT_GetQueueStatus(ftHandle, &Nb_RxOctets);
      time( &ltime0 );
      while ((int)Nb_RxOctets<4*nb_pixel-j) {
         FT_GetQueueStatus(ftHandle,&Nb_RxOctets);
         time( &ltime );
         deltat=(int)(ltime-ltime0);
         if (deltat>10) { return 2; }
      }

      FT_Read(ftHandle,ReadBuffer,4*nb_pixel-j,&Nb_RxOctets);

      for (i=0;i<Nb_RxOctets;i+=4)
      { 
         v1=(int)ReadBuffer[i] & 15;
         v2=(int)ReadBuffer[i+1] & 15;
         v3=(int)ReadBuffer[i+2] & 15;
         v4=(int)ReadBuffer[i+3] & 15;
         v=v1+16*v2+256*v3+4096*v4;
         long k = y * imax + x; 
         if (v>32767)
            p[k]=32767;
         else
            p[k]=(float)v;

         k++;
         
         if (x > 0) {
            x--;
         } else {
            x = imax-1;
            y++;
         }
      }
   }
   return 0;
}

/********** USB_WRITE *************/
/* Write onto USB interface       */
/**********************************/
short usb_write(short v) {
   unsigned char tx[2];
   DWORD Nb_RxOctets;
   FT_STATUS status;
 
   tx[0]=0;
   tx[1]=(unsigned char)v;  
   status = FT_Write(ftHandle, tx, 2, &Nb_RxOctets);
   if (lastStatus != FT_OK || Nb_RxOctets !=2 ) {
      return -1;
   }
   return 0;
}

/*
 * Attente en millisecondes.
 */
void libcam_sleep(int ms)
{
#if defined(OS_LIN)
    usleep(ms * 1000);
#elif defined(OS_WIN)
    Sleep(ms);
#elif defined(OS_MACOS)
    usleep(ms * 1000);
#endif
}

/*
 * Echange deux entiers pointes par a et b.
 */
void libcam_swap(int *a, int *b)
{
    register int t;
    t = *a;
    *a = *b;
    *b = t;
}

/***************************************************************************/



