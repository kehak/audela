/* camtcl.c
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
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

extern struct camini CAM_INI[];

char *cam_shuttertypes[] = {
    "audine",
    NULL
};

/*
 * -----------------------------------------------------------------------------
 *  cmdQuickaShutterType()
 *
 * Setect the type of shutter. 1 shutter types are supported :
 *  audine : build by Raymond David (Essentiel Electronic)
 *
 * -----------------------------------------------------------------------------
 */
int cmdQuickaShutterType(ClientData clientData, Tcl_Interp * interp,
			 int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc > 4)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (strcmp(argv[2], "audine") == 0) {
	    cam->shuttertypeindex = 0;
	    cam->shutteraudinereverse = 0;
	    if (argc >= 4) {
		if (strcmp(argv[3], "reverse") == 0) {
		    cam->shutteraudinereverse = 1;
		}
	    }
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s audine ?options?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	if (cam->shuttertypeindex == 0) {
	    if (cam->shutteraudinereverse == 0) {
		sprintf(ligne, "audine");
	    } else {
		sprintf(ligne, "audine reverse");
	    }
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdQuickaAmpli()
 *
 * Setect the synchronisation of the CCD amplifier
 *
 * -----------------------------------------------------------------------------
 */
int cmdQuickaAmpli(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3) && (argc != 4)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (argc == 4) {
	    cam->nbampliclean = (int) abs(atoi(argv[3]));
	}
	if (strcmp(argv[2], "synchro") == 0) {
	    cam->ampliindex = 0;
	    pb = 0;
	} else if (strcmp(argv[2], "on") == 0) {
	    cam->ampliindex = 1;
	    //CAM_DRV.ampli_on(cam);
	    pb = 0;
	} else if (strcmp(argv[2], "off") == 0) {
	    cam->ampliindex = 2;
	    //CAM_DRV.ampli_off(cam);
	    pb = 0;
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s synchro|on|off ?nbcleanings?",
		argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	strcpy(ligne, "");
	if (cam->ampliindex == 0) {
	    sprintf(ligne, "synchro %d", cam->nbampliclean);
	} else if (cam->ampliindex == 1) {
	    sprintf(ligne, "on %d", cam->nbampliclean);
	} else if (cam->ampliindex == 2) {
	    sprintf(ligne, "off %d", cam->nbampliclean);
	}
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdQuickaDelayshutter()
 *
 * Delay between closure of shutter and CCD reading
 *
 * -----------------------------------------------------------------------------
 */
int cmdQuickaDelayshutter(ClientData clientData, Tcl_Interp * interp,
			  int argc, char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (argc == 3) {
	    cam->delayshutter = (int) abs(atoi(argv[2]));
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ?seconds?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	sprintf(ligne, "%f", cam->delayshutter);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdQuickaSpeed()
 *
 * Speed of the USB interface (valid value: 1...15 - standard value=6)
 *
 * -----------------------------------------------------------------------------
 */
int cmdQuickaSpeed(ClientData clientData, Tcl_Interp * interp, int argc,
		   char *argv[])
{
    char ligne[256];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ((argc != 2) && (argc != 3)) {
	pb = 1;
    } else if (argc == 2) {
	pb = 0;
    } else {
	if (argc == 3) {
	    cam->speed = (short) abs(atoi(argv[2]));
	} else {
	    pb = 1;
	}
    }
    if (pb == 1) {
	sprintf(ligne, "Usage: %s %s ?integer?", argv[0], argv[1]);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	result = TCL_ERROR;
    } else {
	sprintf(ligne, "%d", cam->speed);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    }
    return result;
}
