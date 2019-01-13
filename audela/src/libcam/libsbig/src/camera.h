/* camera.h
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

#ifndef __CAMERA_H__
#define __CAMERA_H__

#ifdef OS_WIN
#define TARGET	 ENV_WIN  // definition de l'OS pour sbigudrv.h
#endif

#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#define ENV_LIN		-1	/* Target for Linux environment */
#define TARGET			ENV_LIN	/* Set for your target */
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

#include <sbigudrv.h>


#undef CST7_DEBUG
#define SBIG_DLL_NAME "SBIGUDrv.dll"

#if defined(OS_LIN) || defined (OS_UNX)
#define MIN_ST7_EXPOSURE 12
#endif

#define ST7_T0         25.0
#define ST7_R0          3.0
#define ST7_MAXAD    4096.0
#define ST7_R_RATIO1  7.791
#define ST7_R_RATIO2   2.57
#define ST7_R_BRIDGE1   3.0
#define ST7_R_BRIDGE2  10.0
#define ST7_DT1        45.0
#define ST7_DT2        25.0

/*enum TObtu {OBTU_SYNCHRO, OBTU_OUVERT, OBTU_FERME};*/

#if defined(OS_WIN)
typedef short __stdcall PARDRVCOMMAND(short command, void *Params,
				      void *Results);
extern HINSTANCE hdll;
extern PARDRVCOMMAND *pardrvcommand;
#endif

#if defined(OS_LIN)
#define INVALID_HANDLE_VALUE 0
typedef short PARDRVCOMMAND(short command, void *Params, void *Results);
extern short SBIGUnivDrvCommand(short command, void *Params,
				void *Results);
extern PARDRVCOMMAND *pardrvcommand;
#endif

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    int drv_status;
    int drv_init;
    char ip[50];
    unsigned short deviceType;
    unsigned short cameraType;
    int opendevice;
    int readoutMode;
    /* --- track --- */
    int bufnotrack;
    struct TimerExpirationStruct *timerExpirationTrack;
    int nb_deadbeginphotoxtrack;
    int nb_deadendphotoxtrack;
    int nb_deadbeginphotoytrack;
    int nb_deadendphotoytrack;
    int nb_photoxtrack;
    int nb_photoytrack;
    double celldimxtrack;
    double celldimytrack;
    int binxtrack, binytrack;
    int x1track, y1track, x2track, y2track;
    int wtrack, htrack;
    int readoutModetrack;
    char date_obstrack[30];
    char date_endtrack[30];
    float exptimetrack;
    int cameraTypetrack;
};


void sbig_get_info_temperatures(struct camprop *cam, double *setpoint,
				double *ccd, double *ambient, int *reg,
				int *power);
char *sbig_get_status(int st);

void sbig_cam_update_windowtrack(struct camprop *cam);
void sbig_cam_start_exptrack(struct camprop *cam, char *amplionoff);
void sbig_cam_stop_exptrack(struct camprop *cam);
void sbig_cam_read_ccdtrack(struct camprop *cam, float *p);
void sbig_cam_set_binningtrack(int binx, int biny, struct camprop *cam);


#endif
