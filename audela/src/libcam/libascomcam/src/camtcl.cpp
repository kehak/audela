/* camtcl.c
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

/*
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
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


//void AcqRead(ClientData clientData);
extern struct camini CAM_INI[];

// ---------------------------------------------------------------------------
// cmdAscomcamInfotemp 
//    recupere les information de temperature
// return:
// OUTPUT                                                              
//    double : check temperature (deg. Celcius)                            
//    double : CCD temperature (deg. Celcius)                              
//    double : ambient temperature (deg. Celcius)                          
//    int    : regulation, 1=on, 0=off                                     
//    int    : Peltier power, (0-255=0-100%)                               
// ---------------------------------------------------------------------------
int cmdAscomcamInfotemp(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    struct camprop *cam;
    double setpoint, ccd, ambient;
    int reg, power;
    char s[256];
    cam = (struct camprop *) clientData;
    ascomcamGetTemperatureInfo(cam, &setpoint, &ccd, &ambient, &reg, &power);
    sprintf(s, "%f %f %f %d %d", setpoint, ccd, ambient, reg, power);
    Tcl_SetResult(interp, s, TCL_VOLATILE);
    return TCL_OK;
}

// ---------------------------------------------------------------------------
// cmdCamConnectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
//    quand la camera est deja connectee
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int cmdAscomcamConnectedSetupDialog(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   struct camprop *cam = (struct camprop *) clientData;
   int result = cam_connectedSetupDialog(cam);
   if ( result == 0 ) {
      Tcl_SetResult(interp, (char*)"", TCL_VOLATILE);
      return TCL_OK;
   } else {
      Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
      return TCL_ERROR;
   }
}
// ---------------------------------------------------------------------------
// cmdAscomcamSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
//    quand la camera n'est pas connectee
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int cmdAscomcamSetupDialog(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char errorMsg[1024]; 
   int result = ascomcamSetupDialog(argv[2], errorMsg);
   if ( result == 0 ) {
      Tcl_SetResult(interp, (char*)"", TCL_VOLATILE);
      return TCL_OK;
   } else {
      Tcl_SetResult(interp, errorMsg, TCL_VOLATILE);
      return TCL_ERROR;
   }
}


// ---------------------------------------------------------------------------
// cmdAscomcamWheel 
//    configure la roue a filtre
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int cmdAscomcamWheel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[1024];
   int result = TCL_OK, pb = 0, k = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 0;
   } else {
      k = 0;
      pb = 0;
      if (strcmp(argv[2], "position") == 0) {
         if ( argc == 4 ) {
            result = ascomcamSetWheelPosition(cam,atoi(argv[3]) );
            if ( result == 0 ) {
               sprintf(ligne, "%d", atoi(argv[3]));
               result = TCL_OK;
            } else {
               sprintf(ligne, "%s", cam->msg);
               result = TCL_ERROR;
            }
         } else {
            int position; 
            result = ascomcamGetWheelPosition(cam,&position);
            if ( result == 0 ) {
               sprintf(ligne, "%d", position);
               result = TCL_OK;
            } else {
               sprintf(ligne, "%s", cam->msg);
               result = TCL_ERROR;
            }
         }
      } else if (strcmp(argv[2], "names")==0) {
         char * names = NULL;
         result = ascomcamGetWheelNames(cam, &names);
         if ( result == 0) {
            if ( names != NULL ) {
               sprintf(ligne, "%s", names);         
               free(names);
               result = TCL_OK;
            } else {
               strcpy(ligne, "");         
               result = TCL_OK;
            }
         } else {
            sprintf(ligne, "%s",cam->msg);         
            result = TCL_ERROR;
         }
      } else {
         pb = 1;
      }
   }
   if (pb == 1 ) {
         sprintf(ligne, "Usage: %s %s position [value] | names", argv[0], argv[1]);
         result = TCL_ERROR;
   }
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}

// ---------------------------------------------------------------------------
// cmdAscomcamProperty 
//    retourne une propriete de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int cmdAscomcamProperty(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[1024];
   int result = TCL_OK, pb = 0, k = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 0;
   } else {
      k = 0;
      pb = 0;
      if (strcmp(argv[2], "maxbin") == 0) {
         int maxBin; 
         result = ascomcamGetMaxBin(cam,&maxBin);
         if ( result == 0 ) {
            sprintf(ligne, "%d", maxBin);
            result = TCL_OK;
         } else {
            sprintf(ligne, "%s", cam->msg);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2], "hasShutter") == 0) {
         int hasShutter; 
         result = ascomcamHasShutter(cam,&hasShutter);
         if ( result == 0 ) {
            sprintf(ligne, "%d", hasShutter);
            result = TCL_OK;
         } else {
            sprintf(ligne, "%s", cam->msg);
            result = TCL_ERROR;
         }
      } else {
         pb = 1;
      }
   }
   if (pb == 1 ) {
         sprintf(ligne, "Usage: %s %s hasShutter|maxbin", argv[0], argv[1]);
         result = TCL_ERROR;
   }
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}



