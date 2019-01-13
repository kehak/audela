/* camera.h
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#ifdef OS_LIN
//#define __KERNEL__
//#   include <sys/io.h>
#define ENV_LIN		-1				/* Target for Linux environment */
#define TARGET			ENV_LIN			/* Set for your target */
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

#include "Atmcd32d.h"

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
   /* --- parametres standards, ne pas changer ---*/
  COMMON_CAMSTRUCT;
   /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */   
   int drv_status;
   int minTemp;
   int maxTemp;
   int HSSpeed;
   int VSSpeed;
   int ADChannel;
   int PreAmpGain;
	int VSAmplitude;
	int EMCCDGain;
   int openingtime;
   int closingtime;
   int HSEMult;
	char headref[10];
	int acqmode;
	int nbimages;
	float cycletime;
	char spoolname[2048];
	AndorCapabilities caps;
};

void cam_setup_electronic(struct camprop *cam);
void cam_setup_exposure(struct camprop *cam,float *texptime,float *taccumtime,float *tkinetictime);
/*
int cam_init(struct camprop *cam, int argc, char **argv);
void cam_update_window(struct camprop *cam);
void cam_start_exp(struct camprop *cam,char *amplionoff);
void cam_stop_exp(struct camprop *cam);
void cam_read_ccd(struct camprop *cam, unsigned short *p);
void cam_shutter_on(struct camprop *cam);
void cam_shutter_off(struct camprop *cam);
void cam_ampli_on(struct camprop *cam);
void cam_ampli_off(struct camprop *cam);
void cam_measure_temperature(struct camprop *cam);
void cam_cooler_on(struct camprop *cam);
void cam_cooler_off(struct camprop *cam);
void cam_cooler_check(struct camprop *cam);
void cam_set_binning(int binx, int biny,struct camprop *cam);

int cam_close(struct camprop *cam);
*/

char* get_status(int st);

#endif
