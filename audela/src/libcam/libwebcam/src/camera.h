/* camera.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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

#include <tcl.h>
#include "libname.h"
#include <libcam/libstruc.h>

#if defined(OS_LIN)
#if !defined(BOOL)
#define BOOL  unsigned short
#endif
#endif


#ifdef __cplusplus
extern "C" {         /* Assume C declarations for C++ */
#endif            /* __cplusplus */

/**
 * If you define OS_WIN_USE_LPT_OLD_STYLE, you will use
 * libcam_out function with your lpt port,
 * this function doesn�t work under WinXP and others
 * WinNT systems.
 *
 * If it is not defined, lpt port will be used like printer port, so you
 * will need "null printer" modified plug.
*/
#define OS_WIN_USE_LPT_OLD_STYLE


/**
 * Type of pixels variables.
 * Should be the same as in cbuffer.h (libaudela).
*/
    typedef float TYPE_PIXELS;

/*
 * Donnees propres a chaque camera.
 *
 * Add specific properties for the camera.
 */

/*
 *   structure pour les fonctions de la librairie digicam
 */
typedef struct _PrivateParams PrivateParams;


/**
 * structure qui accueille les parametres.
 *
 * Structure which contains camera's parameters.
 * - COMMON_CAMSTRUCT - standard parameters, don't change.
*/
 struct camprop {

/*
 * parametres standards, ne pas changer.
 *
 * standard parameters, don't change.
*/
   COMMON_CAMSTRUCT;
/*
 *  Ajoutez ici les variables necessaires a votre camera
 *  (mode d'obturateur, etc).
 *  pour Webcam
 *
 *  Add here necessary variables for your camera (Webcam).
*/
   PrivateParams *params;

   int imax;
   int jmax;
   int driver;
   int longuepose;
   int longueposelinkno;
   char longueposelinkbit[9]; // nom du bit de commande de longue pose : 0, 1, ..,DTR, RTS ..
   char longueposestart;      // valeur demarrage : 0 ou 1
   //char longueposestop;


/**
 * sensorColor : color=1 , black and white= 0
 */
   int sensorColor;
	char convertbw[10];

/**
 * Buffer for rgb frame.
 * Used under Linux for keeping rgb frame
 *
 * In cam_init memory
 * is allocated and dislocated
 * in cmdCamClose, also video format functions
 * change buffers sizes and allocates new memory
 * for them.
 */
   //unsigned char *rgbBuffer;

/**
 * rgbBufferSize is size in bytes of rgbBuffer.
 */
   //int rgbBufferSize;

   int videonum;      // numero de l'image video
   char videoStatusVarNamePtr[256];   // variable pour transmettre l'etat de la camera
   char videoEndCaptureCommandPtr[256];   // command a executer en fin de capture
   // remarque : ces deux variables ne sont pas allouees dynamiquement a cause d'une erreur de heap
   // quand je libere la memoire avec free()

/*****************************************************************/

};  // end of  struct camprop


int webcam_setConnectionState(struct camprop *cam, BOOL state);
int webcam_getConnectionState(struct camprop *cam, BOOL *state);
int webcam_initLongExposureDevice(struct camprop *cam);
int webcam_setLongExposureDevice(struct camprop *cam, unsigned char value);
int webcam_saveUser(struct camprop *cam);
int webcam_setPicSettings(struct camprop *cam, int brightness, int contrast, int colour, int whiteness);
int webcam_getVideoFormat(struct camprop *cam, char *formatname);
int webcam_setVideoFormat(struct camprop *cam, char *formatname);
void webcam_openDlgVideoSource(struct camprop *cam);
void webcam_setTclStatusVariable(struct camprop *cam, char* statusVariable);


#if defined(OS_WIN)
   int startVideoPreview(struct camprop *cam, int owner, int previewRate);
   int stopVideoPreview(struct camprop *cam);
   int startVideoCapture(struct camprop *cam, unsigned short exptime, unsigned long microSecPerFrame, char *fileName);
   int stopVideoCapture(struct camprop *cam);
   int startVideoCrop(struct camprop *cam);
   int stopVideoCrop(struct camprop *cam);
   int setVideoCropRect(struct camprop *cam, long x1, long y1, long x2, long y2);

#endif            //defined(OS_WIN)

#if defined(OS_LIN)
   int webcam_getFrameRate(struct camprop *cam, int *value);
   int webcam_setFrameRate(struct camprop *cam, int value);
   int webcam_getVideoParameter(struct camprop *cam, char *result, int command);
   int webcam_setVideoParameter(struct camprop *cam, int paramValue, int command);
   int webcam_setWhiteBalance(struct camprop *cam, char *mode, int red, int blue);
#endif

#ifdef __cplusplus
}            /* End of extern "C" */
#endif

#endif
