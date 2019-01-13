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

// $Id: camtcl.c,v 1.11 2010-02-06 11:25:17 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <string.h>
#include <stdlib.h> // for atoi()

#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"

// definition STRNCPY : copie de chaine avec protection contre les debordements
#define STRNCPY(_d,_s)  strncpy(_d,_s,sizeof _d) ; _d[sizeof _d-1] = 0

extern struct camini CAM_INI[];

/*
 * -----------------------------------------------------------------------------
 *  cmdCamAutoLoadFlag()
 *
 * Change or returns autoLoadFlag value
 *   if autoLoadFlag = 0  , cam_read_ccd doesn't download image after acquisition with CF
 *   if autoLoadFlag = 1  , cam_read_ccd loads image after acquisition with CF
 * -----------------------------------------------------------------------------
 */
int cmdCamAutoLoadFlag(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getAutoLoadFlag(cam) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         cam_setAutoLoadFlag(cam, atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1?\n Invalid value. Must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamAutoDeleteFlag()
 *
 * Change or returns autoDeleteFlag value
 *   if autoDeleteFlag = 0  , cam_read_ccd doesn't delete image after acquisition with CF
 *   if autoDeleteFlag = 1  , cam_read_ccd deletes image after acquisition with CF
 * -----------------------------------------------------------------------------
 */
int cmdCamAutoDeleteFlag(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getAutoDeleteFlag(cam)  );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         cam_setAutoDeleteFlag(cam, atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1?\n Invalid value. Must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamDriveMode()
 *
 * Change or returns drive mode
 *    driveMode = 0   : single shoot
 *    driveMode = 1   : continuous
 *    driveMode = 2   : self timer 
 * -----------------------------------------------------------------------------
 */
int cmdCamDriveMode(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1|2?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getDriveMode(cam) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' || argv[2][0] == '2') {
         cam_setDriveMode(cam,atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1|2?\n Invalid value. Must be in  0,1 or 2", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamQuality()
 *
 * 
 *  cam1 quality
 *    returns current quality
 *
 *  cam1 quality value 
 *    change current quality 
 * 
 *  cam1 quality list
 *    return quality list
 *    example : {"CRW" "Large:Fine" "Large:Normal" "Middle:Fine" "Middle:Normal" }
 * -----------------------------------------------------------------------------
 */
int cmdCamQuality(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?quality?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      char quality[DIGICAM_QUALITY_LENGTH];
      result = cam_getQuality(cam , quality);
      if( result == 0 ) {
         Tcl_SetResult(interp, quality, TCL_VOLATILE);
         result = TCL_OK;
      } else {
         Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   } else {
      if ( strcmp(argv[2],"list") ==0 ) {
         char list[1024];
         result = cam_getQualityList(cam,  list );
         if( result == 0 ) {
            Tcl_SetResult(interp, list, TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else { 
         result = cam_setQuality(cam , argv[2]);
         if( result == 0 ) {
            Tcl_SetResult(interp, argv[2], TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
            result = TCL_ERROR;
         }
      }
   }
   return result;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamSystemService()
 *
 *  start or stop  hotplug service
 *        Windows : WIA ( Windows Image Acquisition)
 *        Linux   : ???
 *   
 * -----------------------------------------------------------------------------
 */
int cmdCamSystemService(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]) {
    char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam_getSystemServiceState(cam) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if(argv[2][0] == '0' || argv[2][0] == '1' ) {
         cam_setSystemServiceState(cam, atoi(argv[2]));
         result = TCL_OK;
      } else {
         sprintf(ligne, "Usage: %s %s ?0|1?\n Invalid value. Must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/**
 * cmdCamLonguePose - Réglage du mode longue pose.
 *
 * Declare if use long or normal exposure,
 * with no parameters returns actual setting.
*/
int cmdCamLonguePose(ClientData clientData, Tcl_Interp * interp, int argc,
                     char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      int value;
      if(Tcl_GetInt(interp,argv[2],&value)==TCL_OK) {
         pb = cam_setLonguePose(cam, value);
      } else {
         pb= 1;
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s 0|1|2", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam->longuepose);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

/**
 * cmdCamLonguePoseLinkno
 * Change or returns the long exposure port name (long exposure device).
*/
int cmdCamLonguePoseLinkno(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;


   if (argc < 2  && argc > 3) {
      sprintf(ligne, "Usage: %s %s ?linkno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if ( argc == 2 ) {
         sprintf(ligne, "%d", cam->longueposelinkno);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } else {
      // je memorise le numero du link
      if(Tcl_GetInt(interp,argv[2],&cam->longueposelinkno)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s linkno\n linkno = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
         } else {
            result = TCL_OK;
         }
      } 
   }
   return result;
}

/**
 * cmdCamLonguePoseLinkbit
 * Change the bit number 
*/
int cmdCamLonguePoseLinkbit(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if (argc < 2  && argc > 3) {
      sprintf(ligne, "Usage: %s %s ?numbit", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if ( argc == 2 ) {
         strcpy(ligne, cam->longueposelinkbit);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } else {
         // je memorise le numero du bit
         STRNCPY(cam->longueposelinkbit, argv[2] );
         Tcl_SetResult(interp, cam->longueposelinkbit, TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}

/**
 * cmdCamLonguePoseStartValue - définition du caractere de debut de pose.
*/
int cmdCamLonguePoseStartValue(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      cam->longueposestart = (int) atoi(argv[2]);
      pb = 0;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ?decimal_number?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam->longueposestart);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

/**
 * cmdCamLonguePoseStopValue - définition du caracter de fin de pose.
*/
int cmdCamLonguePoseStopValue(ClientData clientData, Tcl_Interp * interp,
                              int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   cam->interp = interp;

   if ((argc != 2) && (argc != 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      cam->longueposestop = (int) atoi(argv[2]);
      pb = 0;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ?decimal_number?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne, "");
      sprintf(ligne, "%d", cam->longueposestop);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}
