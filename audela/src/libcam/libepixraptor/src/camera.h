/* camera.h
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
		int video; //0 if single exposure mode, 1 if video mode
		int cooler; //0 if TEC off, 1 if TEC on
		double frameRate;
		int gain;
		int dynamicRange; //1 if Dynamic range mode, 0 if normal mode
		int videoMode; // 1 if Fixed Frame Rate, 0 if Integrate then Read
		int cur_buf;
		// manufacturer data
		// ---> the manufacturer data depend are camera-specific 
		//      they must be modified if the camera is changed
		char microVersion[7];
		char fpgaVersion[7];
		int serialNumber;
		char build[14];
		int ADC_0;
		int ADC_40;
		int DAC_0;
		int DAC_40;
		//video mode constraints
		//ROI
		int minx;
		int miny;
		int maxx;
		int maxy;
		int maxw;
		int maxh;
		//binning
		int minbinx;
		int minbiny;
		int maxbinx;
		int maxbiny;
		//other constraints
		int max_buf;
		double max_exposure;
		double min_exp_dyn;
		double max_frameRate;
		int max_gain;
		//configuration file
		char config[256];
		//int has_gps;
		
};

int getData(struct camprop *cam);
int cam_set_roi(struct camprop *cam, int x1, int y1, int x2, int y2);
int cam_set_framerate(struct camprop *cam, double frate);
int cam_set_exposure(struct camprop *cam, double exp);
int cam_set_gain(struct camprop *cam, int gain);
int cam_initialize(struct camprop *cam);

void cam_realign(unsigned short *p, int w, int h);
int cam_get_framebuffer(struct camprop *cam, int fb, unsigned short *p);
int cam_set_framebuffer(struct camprop *cam, int fb, unsigned short *p);
int cam_get_maxfb();
double cam_max_framerate(int nlines);
double cam_max_exposure();
int cam_video_start(struct camprop *cam);
int cam_video_pause(struct camprop *cam);
int cam_get_curbuf();
void cam_set_zero();
int cam_get_bufferts(struct camprop *cam, int fb, char *ts);

int cam_get_acquired();
int cam_get_read();

int cam_live_start(struct camprop *cam);

#endif
