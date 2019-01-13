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
// cmdQsiInfotemp
//    recupere les information de temperature
// return:
// OUTPUT
//    double : check temperature (deg. Celcius)
//    double : CCD temperature (deg. Celcius)
//    double : ambient temperature (deg. Celcius)
//    int    : regulation, 1=on, 0=off
//    int    : Peltier power, (0-255=0-100%)
// ---------------------------------------------------------------------------
int cmdQsiInfotemp(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    struct camprop *cam;
    double setpoint, ccd, ambient;
    int reg, power;
    char s[256];
    cam = (struct camprop *) clientData;
    qsiGetTemperatureInfo(cam, &setpoint, &ccd, &ambient, &reg, &power);
    sprintf(s, "%f %f %f %d %d", setpoint, ccd, ambient, reg, power);
    Tcl_SetResult(interp, s, TCL_VOLATILE);
    return TCL_OK;
}

// ---------------------------------------------------------------------------
// cmdQsiSetupDialog
//    affiche la fenetre de configuration fournie par le driver de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int cmdQsiSetupDialog(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    qsiSetupDialog(cam);
    Tcl_SetResult(interp, (char*)"", TCL_VOLATILE);
    return TCL_OK;
}

// ---------------------------------------------------------------------------
// cmdQsiSetupDialog
//    configure la roue a filtre
// return
//    TCL_OK
// ---------------------------------------------------------------------------
#ifndef OS_LIN
/* Windows and MacOS */
int cmdQsiWheel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[1024];
    int result = TCL_OK, pb = 0, k = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ( argc < 3 || argc > 6 ) {
        pb = 1;
    }
    else {
        k = 0;
        pb = 0;
        if ( strcmp(argv[2], "position") == 0 ) {
            if ( argc == 4 ) {
                result = qsiSetWheelPosition(cam,atoi(argv[3]) );
                if ( result == 0 ) {
                    sprintf(ligne, "%d", atoi(argv[3]));
                    result = TCL_OK;
                } else {
                    sprintf(ligne, "%s", cam->msg);
                   result = TCL_ERROR;
                }
            } else {
                int position;
                result = qsiGetWheelPosition(cam,&position);
                if ( result == 0 ) {
                    sprintf(ligne, "%d", position);
                    result = TCL_OK;
                }
                else {
                    sprintf(ligne, "%s", cam->msg);
                    result = TCL_ERROR;
                }
            }
        }
        else if ( strcmp( argv[2], "names" ) == 0 ) {
            char * names = NULL;
            result = qsiGetWheelNames(cam, &names);
            if ( result == 0) {
                if ( names != NULL ) {
                    sprintf(ligne, "%s", names);
                    free(names);
                    result = TCL_OK;
                }
                else {
                    strcpy(ligne, "");
                    result = TCL_OK;
                }
            }
            else {
                sprintf(ligne, "%s",cam->msg);
                result = TCL_ERROR;
            }
        }
        else {
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
#else
/* Linux */
int cmdQsiWheel(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
    char ligne[1024];
    int result = TCL_OK, pb = 0;
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    if ( argc < 3 || argc > 6 ) {
        pb = 1;
    }
    else {
        pb = 0;
        if ( strcmp(argv[2], "position") == 0 ) {
            if ( argc == 4 ) {
                result = qsiSetWheelPosition(cam,atoi(argv[3]) );
                if ( result == 0 ) {
                    sprintf(ligne, "%d", atoi(argv[3]));
                    result = TCL_OK;
                } else {
                    sprintf(ligne, "%s", cam->msg);
                   result = TCL_ERROR;
                }
            } else {
                int position;
                result = qsiGetWheelPosition(cam,&position);
                if ( result == 0 ) {
                    sprintf(ligne, "%d", position);
                    result = TCL_OK;
                }
                else {
                    sprintf(ligne, "%s", cam->msg);
                    result = TCL_ERROR;
                }
            }
        }
        else if ( strcmp( argv[2], "names" ) == 0 ) {
            /* Lecture des noms des filtres */
            char * names = NULL;
            result = qsiGetWheelNames(cam, &names);
            if ( result == 0) {
                if ( names != NULL ) {
                    if ( argc == 3 ) {
                        /* Simple lecture des noms des filtres */
                        sprintf( ligne, "%s", names );
                        result = TCL_OK;
                    }
                    else if ( argc != 5 ) {
                        pb = 1;
                        result = TCL_ERROR;
                    }
                    else {
                        /* Entrée d'un nouveau nom de filtre */
                        int position;
                        if ( Tcl_GetInt( interp, argv[3], &position ) != TCL_OK ) {
                            pb = 1;
                            result = TCL_ERROR;
                        }
                        else {
                            result = qsiPutWheelNames(cam, position, argv[4] );
                            if ( result == 0 ) {
                                /* On refait une lecture de tous les filtres */
                                free( names );
                                names = NULL;
                                result = qsiGetWheelNames(cam, &names);
                                if ( result == 0) {
                                    if ( names != NULL ) {
                                        /* Simple lecture des noms des filtres */
                                        sprintf( ligne, "%s", names );
                                        result = TCL_OK;
                                    }
                                    else {
                                        strcpy(ligne, "");
                                        result = TCL_OK;
                                    }
                                }
                                else {
                                    sprintf(ligne, "%s",cam->msg);
                                    result = TCL_ERROR;
                                }
                            }
                            else {
                                /* Quelque chose s'est mal passé dans qsiPutNames() */
                                sprintf(ligne, "%s",cam->msg);
                                result = TCL_ERROR;
                            }
                        }
                    }
                    free( names );
                }
                else {
                    strcpy(ligne, "");
                    result = TCL_OK;
                }
            }
            else {
                sprintf(ligne, "%s",cam->msg);
                result = TCL_ERROR;
            }
        }
        else {
            pb = 1;
        }
    }
    if ( pb == 1 ) {
        sprintf(ligne, "Usage: %s %s position [value] | names [position, name]", argv[0], argv[1]);
        result = TCL_ERROR;
    }
    Tcl_SetResult( interp, ligne, TCL_VOLATILE );
    return result;
}
#endif

int cmdQsiProperty(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char ligne[1024];
   int result;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ( argc != 3 ) {
      sprintf(ligne, "Usage: %s %s [property name]", argv[0], argv[1]);
      result = TCL_ERROR;
   } else {
      char propertyValue[1024];

      result = qsiGetProperty(cam, argv[2], propertyValue);
      if ( result == 0 ) {
         sprintf(ligne, "%s", propertyValue);
         result = TCL_OK;
      } else {
         sprintf(ligne, "%s", cam->msg);
         result = TCL_ERROR;
      }
   }

   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}


