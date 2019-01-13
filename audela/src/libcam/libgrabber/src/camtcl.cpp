/** @file camtcl.c
 *
 * Functions C-Tcl specifics for this camera.
 *
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 *
*/

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#if defined(OS_LIN)
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>
#endif


#include "camtcl.h"
#include "camera.h"
#include "Capture.h"
#include <libcam/libcam.h>
#include <libcam/util.h>


/**
 *  cmdCamConvertbw
 *  converti l'image couleur en image 2 axes noir et blanc.
 *  Utile pour les TP de master
 *
 *  Parametres :
 *
 */
int cmdCamConvertbw(ClientData clientData, Tcl_Interp * interp,
                int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_ERROR;
   struct camprop *cam;
   const char *usage = "Usage: %s %s none|cols|cfa";

   cam = (struct camprop *) clientData;
    if (argc<=2) {
        Tcl_SetResult(interp, cam->convertbw, TCL_VOLATILE);
        result = TCL_OK;
    } else {
        if ((strcmp(argv[2],"none")==0)||(strcmp(argv[2],"cols")==0)||(strcmp(argv[2],"cfa")==0)) {
            strcpy(cam->convertbw,argv[2]);
            Tcl_SetResult(interp, cam->convertbw, TCL_VOLATILE);
            result = TCL_OK;
        } else {
          sprintf(ligne, usage, argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
        }
    }
   return result;
}

/**
 * cmdCamLonguePose - Reglage du mode longue pose.
 *
 * Declare if use long or normal exposure,
 * with no parameters returns actual setting.
*/
int cmdCamConnect(ClientData clientData, Tcl_Interp * interp, int argc,char *argv[])
{
   char ligne[256];
   int result;
   struct camprop *cam;
   const char *usage = "Usage: %s %s 0|1";

   cam = (struct camprop *) clientData;
   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, usage, argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      BOOL state;
      result = webcam_getConnectionState(cam, &state);
      if ( result == TCL_OK ) {
         sprintf(ligne,"%d",state);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      } else {
         Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
      }
   } else {
      if (strcmp(argv[2], "0") == 0) {
         result = webcam_setConnectionState(cam, FALSE);
         if ( result == TCL_ERROR ) {
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
         }
      } else if (strcmp(argv[2], "1") == 0) {
         result = webcam_setConnectionState(cam, TRUE);
         if ( result == TCL_ERROR ) {
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
         }
      } else {
         sprintf(ligne, usage, argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/**
 * cmdCamWidget -
 * Sets image format, argument must be format name (one of):
*/
int cmdCamWidget(ClientData clientData, Tcl_Interp * interp,
                         int argc, Tcl_Obj *CONST objv[])
{
   int result = TCL_OK;
   //struct camprop *cam;

   //result = VideoObjCmd(clientData, interp, argc, objv);

   return result;
}
/**
 * cmdCamVideoFormat -
 * Sets image format, argument must be format name (one of):
 * - SQCIF - 128x96
 * - QSIF - 160x120
 * - QCIF - 176x144
 * - SSIF  - 240x176
 * - SIF - 320x240
 * - CIF - 352x288
 * - VGA - 640x480.
*/
int cmdCamVideoFormat(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{
   int result = TCL_OK;
   char ligne[128];
   struct camprop *cam;
   char format[32];

   cam = (struct camprop *) clientData;

   if (argc == 2) {
      webcam_getVideoFormat(cam, format);
      Tcl_SetResult(interp, format, TCL_VOLATILE);
   } else if (argc == 3) {
      if (webcam_setVideoFormat(cam, argv[2])) {
         //--- je copie le message d'erreur dans la variable TCL
         Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   } else {
      sprintf(ligne, "Usage: %s %s ?VGA|CIF|SIF|SSIF|QCIF|QSIF|SQCIF|720x576?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}

/**
 * cmdCamLonguePose - Reglage du mode longue pose.
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
   if ((argc != 2) ) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      if (strcmp(argv[2], "0") == 0) {
         cam->longuepose = 0;
         pb = 0;
      } else if (strcmp(argv[2], "1") == 0) {
         cam->longuepose = 1;
         pb = 0;
      } else {
         pb = 1;
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s 0|1", argv[0], argv[1]);
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
 * Changes or returns the long exposure port number.
*/

int cmdCamLonguePoseLinkno(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if (argc != 2 ) {
      sprintf(ligne, "Usage: %s %s ?linkno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else  if (argc == 2 ) {
      // je retourne le numero du link
      sprintf(ligne,"%d",cam->longueposelinkno);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   } else {
      // je memorise le numero du link
      if(Tcl_GetInt(interp,argv[2],&cam->longueposelinkno)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s linkno\n linkno = must be an integer > 0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/******************************************************************/
/*  Fonctions d'affichage et de capture video LINUX (M. Pujol)    */
/*                                                                */
/*  Pour LINUX uniquement                                       */
/******************************************************************/


#if defined(OS_LIN)
/**
 * cmdCamGetVideoParameter - returns specified camera settings.
 * Implemented for Linux, use with many options.
*/
int cmdCamGetVideoParameter(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{
    struct camprop *cam;
    int result = TCL_OK;

    char returnValue[512], *curValue;
    int i, n;
    char commands[] =
        "-restoreUser -restoreFactory -picSettings -gain -sharpness -shutter -noise -compression -whiteBalance -backlight -flicker";

    cam = (struct camprop *) clientData;

    memset( returnValue, 0, sizeof( returnValue ) );
    curValue = returnValue;

    for ( i = 2; i < argc; i++ ) {
        if ( ( n = strlen( returnValue ) ) > 0 ) {
            curValue = returnValue + n;
            sprintf(curValue, " ");
            curValue++;
        }
        if (strcmp(argv[i], "-restoreUser") == 0) {
            if (webcam_getVideoParameter(cam, curValue, RESTOREUSER)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-picSettings") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETPICSETTINGS)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-restoreFactory") == 0) {
            if (webcam_getVideoParameter(cam, curValue, RESTOREFACTORY)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if ( strcmp( argv[i], "-gain" ) == 0 ) {
            if ( webcam_getVideoParameter( cam, curValue, GETGAIN ) ) {
                strcpy( returnValue, cam->msg );
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-sharpness") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETSHARPNESS)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-shutter") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETSHUTTER)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-noise") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETNOISE)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-compression") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETCOMPRESSION)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-whiteBalance") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETWHITEBALANCE)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-backlight") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETBACKLIGHT)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }
        if (strcmp(argv[i], "-flicker") == 0) {
            if (webcam_getVideoParameter(cam, curValue, GETFLICKER)) {
                strcpy(returnValue, cam->msg);
                result = TCL_ERROR;
                break;
            }
            continue;
        }

        sprintf( returnValue, "%s - command unknown. Possible commands: %s", argv[i], commands );
        result = TCL_ERROR;
        break;
    }

    if ( argc <= 2 ) {
        sprintf(returnValue, "%s - possible commands: %s", argv[1], commands);
        result = TCL_ERROR;
    }

    Tcl_SetResult( interp, returnValue, TCL_VOLATILE );
    return result;
}


/**
 * cmdCamSetVideoParameter - sets specified camera settings.
 * Implemented for Linux, use with many options.
*/
int cmdCamSetVideoParameter(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{
   struct camprop *cam;
   int result = TCL_OK;

   char ligne[512], mode[64];
   int i;
   int brightness = 0, contrast = 0, colour = 0, whiteness = 0, param =
      0, red = 0, blue = 0;
   char commands[] =
      "-saveUser -picSettings -gain -sharpness -shutter -noise -compression -whiteBalance -backlight -flicker";

   cam = (struct camprop *) clientData;

   strcpy(ligne, "");

   /* decode the options */
   for (i = 2; i < argc; i++) {
      if (strcmp(argv[i], "-saveUser") == 0) {
         if (webcam_saveUser(cam)) {
            strcpy(ligne, cam->msg);
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-picSettings") == 0) {
         if (argc > (i + 4)) {
            brightness = atoi(argv[++i]);
            contrast = atoi(argv[++i]);
            colour = atoi(argv[++i]);
            whiteness = atoi(argv[++i]);
            if (brightness >= 0 && brightness <= 65535
                && contrast >= 0 && contrast <= 65535
                && colour >= 0 && colour <= 65535
                && whiteness >= 0 && whiteness <= 65535) {
               if (webcam_setPicSettings
                   (cam, brightness, contrast, colour, whiteness)) {
                  strcpy(ligne, cam->msg);
                  result = TCL_ERROR;
                  break;
               }
            } else {
               strcpy(ligne,
                      "-picSettings - bad arguments, must be numbers");
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-picSettings - not enough arguments\n%s",
                    "Usage: -picSettings brightness contrast colour whiteness");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-gain") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoParameter(cam, param, SETGAIN)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-gain - not enough arguments\n%s",
                    "Usage: -gain gainValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-sharpness") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoParameter(cam, param, SETSHARPNESS)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-sharpness - not enough arguments\n%s",
                    "Usage: -sharpness sharpnessValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-shutter") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoParameter(cam, param, SETSHUTTER)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-shutter - not enough arguments\n%s",
                    "Usage: -shutter shutterValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-noise") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoParameter(cam, param, SETNOISE)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-noise - not enough arguments\n%s",
                    "Usage: -noise noiseValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-compression") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoParameter(cam, param, SETCOMPRESSION)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-compression - not enough arguments\n%s",
                    "Usage: -compression compressionValue");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-whiteBalance") == 0) {
         if (argc > (i + 1)) {
            i++;
            strcpy(mode, argv[i]);
            if (strcmp(mode, "manual") == 0) {
               if (argc > (i + 2)) {
                  red = atoi(argv[++i]);
                  blue = atoi(argv[++i]);
                  if (!(red >= 0 && red <= 65535
                        && blue >= 0 && blue <= 65535)) {
                     strcpy(ligne,
                            "-whiteBalance manual - arguments must be numbers");
                     result = TCL_ERROR;
                     break;
                  }
               } else {
                  sprintf(ligne,
                          "-whiteBalance manual - not enough arguments\n%s",
                          "Usage: -whiteBalance manual redLevel blueLevel");
                  result = TCL_ERROR;
                  break;
               }
            }
            if (webcam_setWhiteBalance(cam, mode, red, blue)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-whiteBalance - not enough arguments\n%s%s",
                    "Usage: -whiteBalance whiteMode ?params?\n",
                    "you can use modes: manual, auto, indoor, outdoor, fl");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-backlight") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoParameter(cam, param, SETBACKLIGHT)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-backlight - not enough arguments\n%s",
                    "Usage: -backlight 0|1");
            result = TCL_ERROR;
            break;
         }
         continue;
      }
      if (strcmp(argv[i], "-flicker") == 0) {
         if (argc > (i + 1)) {
            param = atoi(argv[++i]);
            if (webcam_setVideoParameter(cam, param, SETFLICKER)) {
               strcpy(ligne, cam->msg);
               result = TCL_ERROR;
               break;
            }
         } else {
            sprintf(ligne, "-flicker - not enough arguments\n%s",
                    "Usage: -flicker 0|1");
            result = TCL_ERROR;
            break;
         }
         continue;
      }

      sprintf(ligne, "%s - command unknown. Possible commands: %s",
              argv[i], commands);
      result = TCL_ERROR;
      break;
   }

   if (argc <= 2) {
      sprintf(ligne, "%s - possible commands: %s", argv[1], commands);
      result = TCL_ERROR;
   }

   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}

#endif  // OS_LIN



#if defined(OS_LIN)

/**
 * cmdCamFrameRate -
 * Sets frame rate capture:
 *
*/
int cmdCamFrameRate(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{
   int result = TCL_OK;
   char ligne[1024];
   struct camprop *cam;
   int frameRate;

   cam = (struct camprop *) clientData;


   if (argc == 2) {
      if ( webcam_getFrameRate(cam, &frameRate) == 0 ) {
         sprintf(ligne,"%d",frameRate);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_OK;
      } else {
         Tcl_SetResult(interp, (char*)"", TCL_VOLATILE);
         result = TCL_ERROR;
      }
   } else if (argc == 3) {
      if(Tcl_GetInt(interp,argv[2],&frameRate)==TCL_OK) {
         if (webcam_setFrameRate(cam, frameRate) == 0 ) {
            sprintf(ligne,"%d",frameRate);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_OK;
         } else {
            //--- je copie le message d'erreur dans la varable TCL
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else {
         sprintf(ligne, "Usage: %s %s ?frame rate? \n error frame rate=%s ,must be integer", argv[0], argv[1], argv[2]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   } else {
      sprintf(ligne, "Usage: %s %s ?frame rate?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}

/**
 * cmdCamValidFrame - set valid frame number.
 * Possible arguments:
 * - no argument - returns actual setting,
 * - number > 0 - set valid frame on number,
 * - number = 0 - set auto detection mode.
*/
int cmdCamValidFrame(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   int result = TCL_OK;
   char ligne[256];
   int  value;
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if ((argc < 2) || (argc > 3)) {
      sprintf(ligne, "Usage: %s %s ?nb valid frame?", argv[0], argv[1]);
      result = TCL_ERROR;
   } else if (argc == 2) {
      if ( webcam_getVideoParameter(cam, ligne, GETVALIDFRAME)==0) {
         result = TCL_OK;
      } else {
         strcpy(ligne, cam->msg);
         result = TCL_ERROR;
      }
   } else {
      if ((value = atoi(argv[2])) < 0) {
         sprintf(ligne, "error: %s is negative", argv[2]);
         result = TCL_ERROR;
      } else {
         if ( webcam_setVideoParameter(cam, value, SETVALIDFRAME)==0 ) {
            sprintf(ligne, "%d", value);
            result = TCL_OK;
         } else {
            strcpy(ligne, cam->msg);
            result = TCL_ERROR;
         }
      }
   }

   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return result;
}

#endif



/******************************************************************/
/*  Fonctions d'affichage et de capture video WINDOWS (M. Pujol)  */
/*                                                                */
/*  Pour WINDOWS uniquement                                       */
/******************************************************************/

#if defined(OS_WIN)

/**
 * cmdCamVideoSource.
 * Reglage des parametres de la camera
 *
 * and shows VideoSource window dialog.
*/
int cmdCamVideoSource(ClientData clientData, Tcl_Interp * interp, int argc,
                      char *argv[])
{
   int result;
   struct camprop *cam = (struct camprop *) clientData;

   webcam_openDlgVideoSource(cam);
   result = TCL_OK;
   return TCL_OK;
}



/******************************************************************/

/**
 *  cmdCamStartVideoView
 *  active l'affichage de la video (preview)
 *
 *  Parametres :
 *    imgno : numero de l'image de type "video" dans laquelle est affichee la video
 */
int cmdCamStartVideoView(ClientData clientData, Tcl_Interp * interp,
                         int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   int imgno;
   WORD previewRate = 33;
   int owner ;

   cam = (struct camprop *) clientData;

   if ( argc != 4) {
      sprintf(ligne, "Usage: %s %s ?imgno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   } else {

      // je recupere le numero de l'image dans laquelle va etre affichee la video
      imgno = (int) atoi(argv[2]);
      /*
      // je verifie que l'image est du type "video"
      sprintf(ligne, "image type imagevisu%d", imgno);
      if( Tcl_Eval(interp, ligne) == TCL_ERROR) {
         // l'image n'existe pas
         sprintf(ligne, "Error connect webcam to imagevisu%d : %s", imgno, Tcl_GetStringResult(interp) );
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         if ( strcmp(Tcl_GetStringResult(interp), "video") != 0 ) {
            // l'image n'est du type video
            sprintf(ligne, "Error connect webcam to imagevisu%d : %s wrong image type, must be video", imgno, Tcl_GetStringResult(interp) );
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
      */
   }

   /*
   // je recupere le handle de la fenetre d'afficher de la video
   sprintf(ligne, "imagevisu%d cget -owner", imgno);
   if( Tcl_Eval(interp, ligne) == TCL_ERROR) {
      // je retourne le message d'erreur fourni par l'interpreteur
      sprintf(ligne, "Error imagevisu%d cget -owner: %s", imgno, Tcl_GetStringResult(interp) );
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      int owner ;
      if(Tcl_GetInt(interp,Tcl_GetStringResult(interp),&owner)!=TCL_OK) {
         sprintf(ligne, "Error imagevisu%d cget -owner: %s", imgno, Tcl_GetStringResult(interp) );
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         if ( startVideoPreview(cam, owner, previewRate) == TRUE ) {
            cam->videonum = imgno;
            return TCL_OK;
         } else {
            sprintf(ligne, "Error startVideoPreview: %s", cam->msg );
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
   }
   */

      if(Tcl_GetInt(interp,argv[3],&owner)!=TCL_OK) {
         sprintf(ligne, "Error imagevisu%d cget -owner: %s", imgno, argv[2] );
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      } else {
         if ( startVideoPreview(cam, owner, previewRate) == TRUE ) {
            cam->videonum = imgno;
            return TCL_OK;
         } else {
            sprintf(ligne, "Error startVideoPreview: %s", cam->msg );
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            return TCL_ERROR;
         }
      }

}

/**
 *  cmdCamStopVideoView
 *  arrete l'affichage de la video (preview)
 *
 *  Parametres :
 *    aucun
 */
int cmdCamStopVideoView(ClientData clientData, Tcl_Interp * interp, int argc,
                char *argv[])
{
   struct camprop *cam;
   char ligne[256];

   cam = (struct camprop *) clientData;

   stopVideoPreview(cam);
   // je deconnecte la fenetre de visualisation de l'image TK
   sprintf(ligne, "imagevisu%d configure -source %ld", cam->videonum, 0);
   Tcl_Eval(interp, ligne);
   return TCL_OK;
}




/**
 *  cmdCamStartVideoCapture
 *  demarre une aquisition video avec enregistrement dans un fichier AVI
 *
 *  Parametres :
 *    filename :  nom du fichier AVI (chemin complet avec l'extension)
 *    exptime  :  duree de la capture en secondes
 *    framerate:  frequence des images en image/seconde
 *    preallocdisk : pre-allouer le fichier sur disque (1=oui, 0=non)
 *
 */
int cmdCamStartVideoCapture(ClientData clientData, Tcl_Interp * interp,
                int argc, char *argv[])
{
   char ligne[256];
   struct camprop *cam;

   unsigned long microSecPerFrame;
   double frameRate;
   unsigned short exptime;
   int result;
   char fileName [_MAX_PATH];
   int  bPreallocDisk;
   //unsigned long  fileSize;

   cam = (struct camprop *) clientData;

   if ( argc != 6) {
      sprintf(ligne, "Usage: %s %s ?filename? ?exptime? ?framerate? ?preallocdisk?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      // je recupere le nom du fichier
      strcpy(fileName, argv[2]);

      // je recupere la duree de la capture (en secondes)
      exptime =  atoi(argv[3]);
      if( exptime == 0 ) {
         sprintf(ligne, "exptime=\"%s\"  is null or invalid ", argv[3]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      }

      // je recupere la freqence des images (en image par seconde)
      frameRate = (double) (1. * atoi(argv[4]));

      if( frameRate == 0. ) {
         sprintf(ligne, "Error : frameRate is null or invalid");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         return TCL_ERROR;
      }

      // je transforme la frequence en periode ( en micro-seconde par image)
      if (frameRate < 0.0001) {
           microSecPerFrame = 0L;
       } else {
           microSecPerFrame = (DWORD) /*floor*/((1e6 / frameRate) + 0.5);
      }

      // je recupere le flag de preallocation de l'espace disque
      if ( strcmp(argv[5], "1") == 0 ) {
         bPreallocDisk = 1;
      } else  {
         bPreallocDisk = 0;
      }
   }

   result = startVideoCapture(cam, exptime, microSecPerFrame, fileName);

   if(result == TRUE ) {
         result = TCL_OK;
   } else {
      result = TCL_ERROR;
   }

   return result;
}

/**
 *  cmdCamStopVideoCapture
 *  arrete une aquisition video dans un fichier AVI
 *
 *  Parametres :
 *    aucun
 */
int cmdCamStopVideoCapture(ClientData clientData, Tcl_Interp * interp,
                int argc, char *argv[])
{
   struct camprop *cam;
   int result;

   cam = (struct camprop *) clientData;

   // j'arrete la capture
   stopVideoCapture(cam);
   result = TCL_OK;
    return result;
}

/**
 * cmdCamSetVideoSatusVariable.
 * declare la variable TCL
 *
 *  Parametres :
 *    variable : nom de la variable TCL qui reeoit le status pendant la capture
 */
int cmdCamSetVideoSatusVariable(ClientData clientData, Tcl_Interp * interp,
                               int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   cam = (struct camprop *) clientData;
   if (argc != 3) {
      sprintf(ligne, "Usage: %s %s variable ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      // store the TCL variable name
      webcam_setTclStatusVariable(cam,argv[2]);
      result = TCL_OK;
   }
   return result;
}


/**
 *  cmdCamStartVideoCrop
 *  demarre le mode d'acquisition video fenetree
 *
 *  Parametres :
 *
 */
int cmdCamStartVideoCrop(ClientData clientData, Tcl_Interp * interp,
                int argc, char *argv[])
{
   int result = TCL_ERROR;
   struct camprop *cam;

   cam = (struct camprop *) clientData;
   result = startVideoCrop(cam);
   if(result == TRUE ) {
      result = TCL_OK;
   } else {
      Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}

/**
 *  cmdCamStopVideoCrop
 *  arrete le mode d'acquisition video fenetree
 *
 *  Parametres :
 *
 */
int cmdCamStopVideoCrop(ClientData clientData, Tcl_Interp * interp,
                int argc, char *argv[])
{
   int result = TCL_ERROR;
   struct camprop *cam;

   cam = (struct camprop *) clientData;
   result = stopVideoCrop(cam);
   result = TCL_OK;
   return result;
}



/**
 *  cmdCamSetVideoCropRect
 *  change la taille de la fenetre d'acquisition video fenetree
 *
 *  Parametres :
 *
 */
int cmdCamSetVideoCropRect(ClientData clientData, Tcl_Interp * interp,
                int argc, char *argv[])
{
    int result = TCL_ERROR;
  char ligne[256];
   struct camprop *cam;
   long     x1, y1, x2, y2;

   cam = (struct camprop *) clientData;
   if ( argc != 6) {
      sprintf(ligne, "Usage: %s %s x1 y1 x2 y2 ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }

   x1    =  atol(argv[2]);
   y1    =  atol(argv[3]);
   x2    =  atol(argv[4]);
   y2    =  atol(argv[5]);

   result = setVideoCropRect(cam, x1, y1, x2, y2);

   if(result == TRUE ) {
      result = TCL_OK;
   } else {
      Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
      result = TCL_ERROR;
   }
   return result;
}




/*****************************************************************/
#endif  //defined(OS_WIN)
/*****************************************************************/


