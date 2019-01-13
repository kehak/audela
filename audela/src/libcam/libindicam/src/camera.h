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

#pragma once

// The following macros define the minimum required platform.  The minimum required platform
// is the earliest version of Windows, Internet Explorer etc. that has the necessary features to run 
// your application.  The macros work by enabling all features available on platform versions up to and 
// including the version specified.

// Modify the following defines if you have to target a platform prior to the ones specified below.
// Refer to MSDN for the latest info on corresponding values for different platforms.
#ifndef _WIN32_WINNT            // Specifies that the minimum required platform is Windows Vista.
#define _WIN32_WINNT 0x0600     // Change this to the appropriate value to target other versions of Windows.
#endif


#ifdef OS_LIN
#define __KERNEL__
#   include <sys/io.h>
#endif

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

#ifdef __cplusplus
extern "C" {         /* Assume C declarations for C++ */
#endif            /* __cplusplus */

typedef struct _PrivateParams PrivateParams;

/*
 * Donnees propres a chaque camera.
 */
/* --- structure qui accueille les parametres---*/
struct camprop {
    /* --- parametres standards, ne pas changer --- */
    COMMON_CAMSTRUCT;
    /* Ajoutez ici les variables necessaires a votre camera (mode d'obturateur, etc). */
    PrivateParams *params;          // parametres prives de la camera

};

int cam_select(char * productName);
int cam_connectedSetupDialog(struct camprop *cam );

int ascomcamGetMaxBin(struct camprop *cam, int *maxBin);
int ascomcamHasShutter(struct camprop *cam, int *hasShutter);
void ascomcamGetTemperatureInfo(struct camprop *cam, double *setTemperature, double *ccdTemperature, 
                               double *ambientTemperature, int *regulationEnabled, int *power);
int ascomcamSetupDialog(const char * ascomDiverName, char * errorMsg);

int ascomcamSetWheelPosition(struct camprop *cam, int position);
int ascomcamGetWheelPosition(struct camprop *cam, int *position);
int ascomcamGetWheelNames(struct camprop *cam, char **names);
#ifdef __cplusplus
}            /* End of extern "C" */
#endif

#endif
