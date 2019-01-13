/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ & Philippe AMBERT <alain.klotz@free.fr>
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
#include <libcam/util.h>

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Cagire",			/* camera name */
     "cagire",		/* camera product */
     "Hawaii 2RG",		/* ccd name */
     2048, 2048,		/* maxx maxy */
     0, 0,			/* overscans x */
     0, 0,			/* overscans y */
     18e-6, 18e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -100.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     }
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
    cam_init,			/* init */
    cam_close,			/* close */
    cam_set_binning,		/* set_binning */
    cam_update_window,		/* update_window */
    cam_start_exp,		/* start_exp */
    cam_stop_exp,		/* stop_exp */
    cam_read_ccd,		/* read_ccd */
    cam_shutter_on,		/* shutter_on */
    cam_shutter_off,		/* shutter_off */
    cam_ampli_on,			/* ampli_on */
    cam_ampli_off,			/* ampli_off */
    cam_measure_temperature,	/* measure_temperature */
    cam_cooler_on,		/* cooler_on */
    cam_cooler_off,		/* cooler_off */
    cam_cooler_check		/* cooler_check */
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
   char s[1024];
   int kk;

	/* ::cam::create cagire -ip 127.0.0.1 -port 5000 -impath "c:/data" -simu 0 */
   cam->tempo=200;
	/* --- decode IP  --- */
	strcpy(cam->ip,"127.0.0.1");
	if (argc >= 1) {
		for (kk = 0; kk < argc; kk++) {
			if (strcmp(argv[kk], "-ip") == 0) {
				if ((kk + 1) <= (argc - 1)) {
					strcpy(cam->ip, argv[kk + 1]);
				}
			}
		}
	}
	/* --- decode port  --- */
	cam->port = 5000;
	if (argc >= 1) {
		for (kk = 0; kk < argc; kk++) {
			if (strcmp(argv[kk], "-port") == 0) {
				if ((kk + 1) <= (argc - 1)) {
					cam->port=atoi(argv[kk + 1]);
				}
			}
		}
	}
	/* --- decode image path --- */
	strcpy(cam->pathimraw,".");
	if (argc >= 1) {
		for (kk = 0; kk < argc; kk++) {
			if (strcmp(argv[kk], "-impath") == 0) {
				if ((kk + 1) <= (argc - 1)) {
					strcpy(cam->pathimraw,argv[kk + 1]);
				}
			}
		}
	}
	/* --- decode simulation flag --- */
	cam->simulation=0;
	if (argc >= 1) {
		for (kk = 0; kk < argc; kk++) {
			if (strcmp(argv[kk], "-simu") == 0) {
				if ((kk + 1) <= (argc - 1)) {
					cam->simulation=atoi(argv[kk + 1]);
				}
			}
		}
	}
	/* --- open the port and record the channel name ---*/
	strcpy(cam->channel,"");
	if (cam->simulation==0) {
		sprintf(s,"socket \"%s\" \"%d\"",cam->ip,cam->port);
		if (mycam_tcleval(cam,s)==1) {
			strcpy(cam->msg,Tcl_GetStringResult(cam->interp));
			return 1;
		}
		strcpy(cam->channel,Tcl_GetStringResult(cam->interp));
		/* --- configuration of the TCP socket ---*/
		//sprintf(s,"fconfigure %s -blocking 0 -buffering none -translation binary -encoding binary",cam->channel); mycam_tcleval(cam,s);
		sprintf(s,"fconfigure %s -blocking 0 -buffering line",cam->channel); mycam_tcleval(cam,s);
		sprintf(s,"after %d",cam->tempo); mycam_tcleval(cam,s);
	}

	//cagire_initialize(cam);
   /* --- Get CCD Infos (to update the CAM_INI struct with the linked camera) --- */

   /* --- Conversion of Cagire parameters to AudeLA CAM_INI structure --- */
   cam->index_cam = 0;

   return 0;
}


int cam_close(struct camprop *cam)
{
   char s[1024];
   // --- close the device
	sprintf(s,"close %s",cam->channel); mycam_tcleval(cam,s);
   return 0;
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
	int res;
	char ligne[1000];
	cam_update_window(cam);
	res=cagire_put(cam,"AcquireSingleFrame");
	res=cagire_read(cam,ligne);
	strcpy(cam->msg,"");
}

void cam_stop_exp(struct camprop *cam)
{
	int res;
	char ligne[1000];
	res=cagire_put(cam,"STOPACQUISITION");
	res=cagire_read(cam,ligne);
	strcpy(cam->msg,ligne);
}

void cam_read_ccd(struct camprop *cam, float *p)
{
	int res;
	char ligne[1000],s[2048],im[2048];
   int h,w,sortie;
   short *pix;
   long size;
   int k;
	long clk_tck = CLOCKS_PER_SEC;
   clock_t clock0;
	double dt;
   float *pp,val;

   if(p==NULL) return ;

   h=cam->h;
   w=cam->w;
   pix=(short*)p;

   /* --- boucle d'attente ---*/
	clock0 = clock();
   sortie=0;
   do {
		res=cagire_put(cam,"PING");
		res=cagire_read(cam,ligne);
		if ((ligne[0]=='0')&&(ligne[1]==':')) {
			 sortie=1;
      }
		dt=(double)(clock()-clock0)/(double)clk_tck;
		if (dt>30) {
			sortie=2; // timeout
		}
   } while (sortie==0);
   /* --- importation de l'image --- */
	if (sortie==1) {
		cagire_lastimage(cam,im);
		if (strcmp(im,"")==0) {
			size=(long)(w)*(long)(h);
			for (k=0;k<size;k++) { pix[k]=(short)2; }
		} else {
			sprintf(s,"buf%d load \"%s\"",cam->bufno,im);
			if (mycam_tcleval(cam,s)==0) {
				/* Recupere l'adresse du pointeur buffer */ 
				sprintf(s,"buf%d getpixelswidth",cam->bufno);
				mycam_tcleval(cam,s);
				w=atoi(Tcl_GetStringResult(cam->interp));
			   cam->w=w;
				sprintf(s,"buf%d getpixelsheight",cam->bufno);
				mycam_tcleval(cam,s);
				h=atoi(Tcl_GetStringResult(cam->interp));
				cam->h=h;
				sprintf(s,"buf%d pointer",cam->bufno);
				mycam_tcleval(cam,s);
				pp = (float *) atoi(Tcl_GetStringResult(cam->interp));
				size=(long)(w)*(long)(h);
				/* Transfere l'image */
				for (k=0;k<size;k++) { 
					val=pp[k];
					pix[k]=(unsigned short)val;
					//*(pix+k)=(unsigned short)*((float*)(pp+k));
				}
				sprintf(s,"catch {file delete \"%s\"}",im);
				mycam_tcleval(cam,s);
			} else {
				size=(long)(w)*(long)(h);
				for (k=0;k<size;k++) { pix[k]=(short)3; }
			}
		}
	} else {
		size=(long)(w)*(long)(h);
		for (k=0;k<size;k++) { pix[k]=(short)1; }
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
    //cam->temperature = (double) ccd;
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
    if (binx < 1) {
        binx = 1;
    }
    if (biny < 1) {
        biny = 1;
    }
    if (binx > 1) {
        binx = 1;
    }
    if (biny > 1) {
        biny = 1;
    }
    return;
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

    cam->w = (cam->x2 - cam->x1 + 1) / cam->binx;
    cam->x2 = cam->x1 + cam->w * cam->binx - 1;
    cam->h = (cam->y2 - cam->y1 + 1) / cam->biny;
    cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */

int mycam_tcleval(struct camprop *cam,char *ligne)
{
	/*
   FILE *f;
   f=fopen("mouchard_deltatau.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   fclose(f);
	*/
   if (Tcl_Eval(cam->interp,ligne)!=TCL_OK) {
		/*
      f=fopen("mouchard_deltatau.txt","at");
      fprintf(f,"RESU-PB <%s>\n",Tcl_GetStringResult(cam->interp));
      fclose(f);
		*/
      return 1;
   }
	/*
   f=fopen("mouchard_deltatau.txt","at");
   fprintf(f,"RESU-OK <%s>\n",Tcl_GetStringResult(cam->interp));
   fclose(f);
	*/
   return 0;
}

int cagire_put(struct camprop *cam, const char *cmd)
{
   char s[1024],ss[1024];
	if (cam->simulation==0) {
		strcpy(ss,cmd);
		sprintf(s,"puts -nonewline %s \"%s\\n\"",cam->channel,ss);
		if (mycam_tcleval(cam,s)==1) {
			strcpy(cam->msg,Tcl_GetStringResult(cam->interp));
			return 1;
		}
	}
   return 0;
}

int cagire_read(struct camprop *cam,char *res)
{
   char s[2048];
	long clk_tck = CLOCKS_PER_SEC;
   clock_t clock0;
	double dt = 0;
	if (cam->simulation==0) {
		strcpy(res,"");
		clock0 = clock();
		while (dt<30) {
			sprintf(s,"read -nonewline %s",cam->channel);
			if (mycam_tcleval(cam,s)==1) {
				strcpy(cam->msg,Tcl_GetStringResult(cam->interp));
				return 1;
			}
			if (strcmp(Tcl_GetStringResult(cam->interp),"")==0) {
				libcam_sleep(200);
			} else {
				break;
			}
			dt=(double)(clock()-clock0)/(double)clk_tck;
		}
		strcpy(res,Tcl_GetStringResult(cam->interp));
	} else {
		strcpy(res,"0:succeeded");
	}
   return 0;
}

int cagire_initialize(struct camprop *cam)
{
	char ligne[1000];
	int res;
	//
	res=cagire_put(cam,"Initialize2");
	res=cagire_read(cam,ligne);
	if ((ligne[0]!='0')||(ligne[1]!=':')) {
		strcpy(cam->msg,ligne);
		return 1;
	}
	//
	res=cagire_put(cam,"ResetASIC");
	res=cagire_read(cam,ligne);
	if ((ligne[0]!='0')||(ligne[1]!=':')) {
		strcpy(cam->msg,ligne);
		return 1;
	}
	//
	res=cagire_put(cam,"DownloadMCD");
	res=cagire_read(cam,ligne);
	if ((ligne[0]!='0')||(ligne[1]!=':')) {
		strcpy(cam->msg,ligne);
		return 1;
	}
	//
	strcpy(cam->msg,"Done: Initialize2 ResetASIC DownloadMCD");
	return 0;

}

int cagire_lastimage(struct camprop *cam, char *lastimage)
{
   char s[2048];
	/* --- search for the most recent FITS file ---*/
	strcpy(s,"\
	proc cagire_analdir { base {filefilter *} } {\
		global libgagire_listdatefiles;\
		set listfiles \"\";\
		set a [catch {set listfiles [glob -nocomplain ${base}/${filefilter}]} msg];\
		if {$a==0} {\
			foreach thisfile $listfiles {\
				set extension [file extension $thisfile];\
				if {([file isfile $thisfile]==1)&&($extension==\".fits\")} { lappend libgagire_listdatefiles [list [file mtime $thisfile] $thisfile] }\
			};\
			foreach thisfile $listfiles {\
				if {[file isdirectory $thisfile]==1} { cagire_analdir $thisfile $filefilter}\
			};\
		};\
	};\
	proc cagire_files_in_dir { base {filefilter *} } {\
		global libgagire_listdatefiles;\
		set libgagire_listdatefiles \"\";\
		cagire_analdir $base $filefilter;\
		if {$libgagire_listdatefiles!=\"\"} {\
			set libgagire_listdatefiles [lsort -decreasing $libgagire_listdatefiles];\
		};\
		return [lindex [lindex $libgagire_listdatefiles 0] 1];\
	}\
	");
	mycam_tcleval(cam,s);
	sprintf(s,"cagire_files_in_dir \"%s\"",cam->pathimraw);
	mycam_tcleval(cam,s);
	strcpy(lastimage,Tcl_GetStringResult(cam->interp));
   return 0;
}
