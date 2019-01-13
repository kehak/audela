/* libcam.c
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
 * $Id: libcam.c,v 1.44 2010-09-22 16:51:11 michelpujol Exp $
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */

#include <string>
#include <sstream>  // pour ostringstream

using namespace ::std;

#if defined(OS_LIN)
#include <sys/time.h>           /* gettimeofday */
#endif

#include "camera.h"
#include "camtcl.h"

#include <libcam/libcam.h>
#include <libcam/libstruc.h>
#include <libcam/util.h>      // pour libcam_log
#include <libaudela.h>

extern struct cam_drv_t CAM_DRV;


/* valeurs des structures cam_* privees */
const char *cam_shutters[] = {
    "closed",
    "synchro",
    "opened",
    NULL
};

const char *cam_rgbs[] = {
    "none",
    "cfa",
    "rgb",
    "gbr",
    "brg",
    NULL
};

const char *cam_coolers[] = {
    "off",
    "on",
    "check",
    NULL
};

const char *cam_ports[] = {
    "lpt1",
    "lpt2",
    NULL
};

const char *cam_overscans[] = {
    "off",
    "on",
    NULL
};

extern struct camini CAM_INI[];

#if !defined(OS_WIN)
#define MB_OK 1
void MessageBox(void *handle, char *msg, char *title, int bof)
{
    fprintf(stderr, "%s: %s\n", title, msg);
}
#endif

#define BP(i) MessageBox(NULL,#i,"Libcam",MB_OK)


/*
 * Prototypes des differentes fonctions d'interface Tcl/Driver. Ajoutez les
 * votres ici.
 */
/* === Common commands for all cameras ===*/
static int cmdCamCreate(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCam(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamAvailable(struct camprop *cam, Tcl_Interp * interp, int argc, const char *argv[]);

/* --- Information commands ---*/
static int cmdCamDrivername(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamNbcells(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamNbpix(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamCelldim(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamPixdim(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamMaxdyn(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamFillfactor(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamRgb(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamInfo(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamPort(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamTimer(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamGain(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamReadnoise(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamTemperature(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamMirrorH(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamMirrorV(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamCapabilities(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamLastError(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamThreadId(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);


/* --- Action commands ---*/
static int cmdCamName(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamProduct(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamCcd(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamBin(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamDark(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamExptime(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamBuf(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamWindow(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamAcq(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamTel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamRadecFromTel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamStop(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamShutter(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamCooler(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamFoclen(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamOverscan(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamInterrupt(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamLogLevel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamLogFile(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);
static int cmdCamHeaderProc(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
static int cmdCamStopMode(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[]);

static int cam_init_common(struct camprop *cam, int argc, const char **argv);


static struct cmditem cmdlist[] = {
    /* === Common commands for all cameras === */
    COMMON_CMDLIST
    /* === Specific commands for that camera === */
    SPECIFIC_CMDLIST
    /* === Last function terminated by NULL pointers === */
    {NULL, NULL}
};

static struct camprop *camprops = NULL;




/*
 * Point d'entree de la librairie, appelle lors de la commande Tcl load.
 */
#if defined(OS_WIN)
int __cdecl CAM_ENTRYPOINT(Tcl_Interp * interp)
#else
extern "C" int CAM_ENTRYPOINT(Tcl_Interp * interp)
#endif
{
    char s[256];
    struct cmditem *cmd;
    int i;

    libcam_log(LOG_INFO, "Calling entrypoint for driver %s", CAM_DRIVNAME);

    if (Tcl_InitStubs(interp, "8.3", 0) == NULL) {
    Tcl_SetResult(interp, (char*) "Tcl Stubs initialization failed in " CAM_LIBNAME " (" CAM_LIBVER ").", TCL_VOLATILE);
    libcam_log(LOG_ERROR, "Tcl Stubs initialization failed.");
    return TCL_ERROR;
    }

    libcam_log(LOG_DEBUG, "cmdCamCreate = %p", cmdCamCreate);
    libcam_log(LOG_DEBUG, "cmdCam = %p", cmdCam);

    Tcl_CreateCommand(interp, CAM_DRIVNAME, (Tcl_CmdProc *) cmdCamCreate, NULL, NULL);
    Tcl_PkgProvide(interp, CAM_LIBNAME, CAM_LIBVER);

    for (i = 0, cmd = cmdlist; cmd->cmd != NULL; cmd++, i++);

#if defined(__BORLANDC__)
    sprintf(s, "Borland C (%s) ...nb commandes = %d", __DATE__, i);
#elif defined(OS_LIN)
    sprintf(s, "Linux (%s) ...nb commandes = %d", __DATE__, i);
#else
    sprintf(s, "VisualC (%s) ...nb commandes = %d", __DATE__, i);
#endif

    libcam_log(LOG_INFO, "Driver provides %d functions.", i);

    Tcl_SetResult(interp, s, TCL_VOLATILE);

    //HRESULT hr = CoInitializeEx(NULL,COINIT_MULTITHREADED );
    //HRESULT hr = CoInitialize(NULL);

    return TCL_OK;
}

static int cmdCamCreate(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char s[1024];
   int camno, err, i;
   struct camprop *cam, *camm;

   if (argc < 3) {
      if ( argc ==2 && strcmp(argv[1],"available") == 0) {
         return cmdCamAvailable((struct camprop *)clientData, interp, argc, argv);
      } else {
         sprintf(s, "%s driver port ?options?", argv[0]);
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
   } else {
      

#ifdef CMD_CAM_SETUP
      if (argc == 3 && strcmp(argv[1],"setup") == 0) {
         return cmdAscomcamSetupDialog(clientData, interp, argc, argv);
      }
#endif
      // verify the platform
      const char *platform;
      if((platform=Tcl_GetVar(interp,"tcl_platform(platform)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdCamCreate: Global variable tcl_platform(os) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      const char *threaded;
      if((threaded=Tcl_GetVar(interp,"tcl_platform(threaded)",TCL_GLOBAL_ONLY))==NULL) {
         sprintf(s, "cmdCamCreate: Global variable tcl_platform(threaded) not found");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      if ( strcmp(threaded,"1")!= 0 ) {
         sprintf(s, "cmdCamCreate: tcl_platform(threaded)=%s . must be 1",threaded );
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }

      cam = (struct camprop*)calloc(1,sizeof(struct camprop));
      strcpy(cam->msg,"");
      cam->interp = interp;
      
      // je recupere l'identifiant du thread principal qui est dans le dernier argument
      strcpy(cam->mainThreadId, argv[argc-1]);
      // je recupere l'identitifiant du thread de la camera
      Tcl_Eval(interp, "thread::id");
      strcpy(cam->camThreadId, Tcl_GetStringResult(interp));

              
      // On initialise la camera sur le port. S'il y a une erreur, alors on
      // renvoie le message qui va bien, en supprimant la structure cree.
      // Si OK, la commande TCL est creee d'apres l'argv[1], et on garde
      // trace de la structure creee.

      fprintf(stderr, "%s(%s): CamCreate(argc=%d", CAM_LIBNAME, CAM_LIBVER, argc);
      for (i = 0; i < argc; i++) {
         fprintf(stderr, ",argv[%d]=%s", i, argv[i]);
      }
      fprintf(stderr, ")\n");

      // Je ne sais pas a quoi sert ce test (Michel)
      // Est-ce pour inhiber les cameras sous Windows et Mac ?
      if ( strcmp(platform, "unix") == 0) {
         cam->authorized = 1;
      } else {
         // je n'autorise pas les interuptions usr Windows et sur Mac
         cam->authorized = 0;
      }

      sscanf(argv[1], "cam%d", &camno);
      cam->camno = camno;
      strcpy(cam->msg, "");
      if ((err = cam_init_common(cam, argc, argv)) != 0) {
         Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
         free(cam);
         return TCL_ERROR;
      }
      if ((err = CAM_DRV.init(cam, argc, argv)) != 0) {
         Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
         free(cam);
         return TCL_ERROR;
      }

      cam->bufno = 0;
      cam->telno = 0;
      cam->timerExpiration = NULL;
      camm = camprops;
      if (camm == NULL) {
         camprops = cam;
      } else {
         while (camm->next != NULL)
            camm = camm->next;
         camm->next = cam;
      }

      // Cree la nouvelle commande par le biais de l'unique
      // commande exportee de la librairie libcam.
      Tcl_CreateCommand(interp, argv[1], (Tcl_CmdProc *) cmdCam, (ClientData) cam, NULL);

      // set TCL global status_camNo
      setCameraStatus(cam,"stand");

      libcam_log(LOG_DEBUG, "cmdCamCreate: create camera data at %p\n", cam);
   }
   return TCL_OK;
}

static int cmdCam(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char s[1024], ss[50];
   int retour = TCL_OK, k, i;
   struct cmditem *cmd;

   if (argc == 1) {
     sprintf(s, "%s choose sub-command among ", argv[0]);
      k = 0;
      while (cmdlist[k].cmd != NULL) {
         sprintf(ss, " %s", cmdlist[k].cmd);
         strcat(s, ss);
         k++;
      }
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {

      // je trace les parametres si le niveau de ebug est active
      if (debug_level > 0) {
         char s1[256], *s2;
         s2 = s1;
         s2 += sprintf(s2,"Enter cmdCam (argc=%d", argc);
         for (i = 0; i < argc; i++) {
            s2 += sprintf(s2, ",argv[%d]=%s", i, argv[i]);
         }
         s2 += sprintf(s2, ")");
         libcam_log(LOG_INFO, "%s", s1);
      }

      for (cmd = cmdlist; cmd->cmd != NULL; cmd++) {
         if (strcmp(cmd->cmd, argv[1]) == 0) {
            retour = (*cmd->func) (clientData, interp, argc, argv);
            break;
         }
      }
      if (cmd->cmd == NULL) {
         sprintf(s, "%s %s : sub-command not found among ", argv[0], argv[1]);
         k = 0;
         while (cmdlist[k].cmd != NULL) {
            sprintf(ss, " %s", cmdlist[k].cmd);
            strcat(s, ss);
            k++;
         }
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
}




int libcam_threadAliasCommand(ClientData deviceThreadId, Tcl_Interp *interp, int argc, char *argv[]) {
   string ligne ;
   ligne.append("thread::send ").append((char*)deviceThreadId).append(" {");
   for (int i=0;i<argc;i++) {
      ligne.append(" {").append( argv[i]).append("}");
   }
   ligne.append(" }");
   return Tcl_Eval(interp, ligne.c_str());
}


/*
 * libcam_GetCurrentFITSDate(char s[23])
 *  retourne la date TU avec le 1/1000 de seconde
 *
 */
void libcam_GetCurrentFITSDate(Tcl_Interp * interp, char *s)
{
   int clock = 0;
   char ligne[256];
#if defined(OS_WIN)
#if defined(_Windows)
   /* cas special a Borland Builder pour avoir les millisecondes */
   struct time t1;
   struct date d1;
   clock = 1;
   getdate(&d1);
   gettime(&t1);
   sprintf(s, "%04d-%02d-%02dT%02d:%02d:%02d.%03d", d1.da_year, d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec, t1.ti_hund);
#endif
#if defined(_MSC_VER)
   /* cas special a Microsoft C++ pour avoir les millisecondes */

   struct _timeb timebuffer;
   char message[50];
   time_t ltime;
   clock = 1;
   _ftime(&timebuffer);   // retourne la date GMT
   time(&ltime);          // retourne la date GMT
   strftime(message, 45, "%Y-%m-%dT%H:%M:%S", gmtime(&ltime));
   sprintf(s, "%s.%03d", message, (int) timebuffer.millitm );


   /*
   struct _SYSTEMTIME temps_pc;
   clock = 1;
    GetSystemTime(&temps_pc);
   sprintf(s, "%04d-%02d-%02dT%02d:%02d:%02d.%03d",
      temps_pc.wYear, temps_pc.wMonth, temps_pc.wDay,
      temps_pc.wHour, temps_pc.wMinute, temps_pc.wSecond,
      temps_pc.wMilliseconds);
   */
#endif
#elif defined(OS_LIN)
    char message[50];
    struct timeval t;
    gettimeofday (&t, NULL);  // retourne la date GMT
    strftime (message, 45, "%Y-%m-%dT%H:%M:%S",gmtime ((const time_t*)(&t.tv_sec)));
    //sprintf (s, "%s.%03d : ", message, (int)(t.tv_usec/1000));
    sprintf (s, "%s.%03d", message, (int)(t.tv_usec/1000));
    clock = 1;
#endif
   if (clock == 0) {
      strcpy(ligne, "clock format [clock seconds] -format \"%Y-%m-%dT%H:%M:%S.000\"");
      Tcl_Eval(interp, ligne);
      strcpy(s, Tcl_GetStringResult(interp));
   }


}
/*
 * libcam_get_tel_coord : lecture des coordonnes du telescope associe
 *
 * status=0 : les coordonnees on ete lues avec succes
 * status=1 : les coordonnees on ete lues avec erreur
 */
void libcam_get_tel_coord(Tcl_Interp * interp, double *ra, double *dec, struct camprop *cam, int *status)
{
   char s[500];
   *ra = 0.;
   *dec = 0.;
   *status = 1;
   if ( cam->telno != 0 ) {
      sprintf(s,"tel%d coord", cam->telno );
      if ( Tcl_Eval(interp, s) == TCL_OK ) {
         int argcc;
         const char **argvv = NULL;

         if (Tcl_SplitList(interp, Tcl_GetStringResult(interp), &argcc, &argvv) == TCL_OK) {
            if (argcc >= 2) {
               sprintf(s,"mc_angle2deg %s", argvv[0]);
               if ( Tcl_Eval(interp, s) == TCL_OK) {
                  *ra = (double) atof(Tcl_GetStringResult(interp));
                  sprintf(s,"mc_angle2deg %s 90", argvv[1]);
                  if ( Tcl_Eval(interp, s) == TCL_OK) {
                     *dec = (double) atof(Tcl_GetStringResult(interp));
                     *status = 0;
                  }
               }
            }
         }
      }
   }
}


static int cmdCamBin(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   const char **listArgv;
   int listArgc;
   int i_binx, i_biny, result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?{binx biny}?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d %d", cam->binx, cam->biny);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
         sprintf(ligne, "Binning struct not valid: must be {binx biny}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else if (listArgc != 2) {
         sprintf(ligne, "Binning struct not valid: must be {binx biny}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if (Tcl_GetInt(interp, listArgv[0], &i_binx) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {binx biny}\nbinx : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else if (Tcl_GetInt(interp, listArgv[1], &i_biny) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {binx biny}\nbiny : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            cam = (struct camprop *) clientData;
            cam->msg[0]=0;
            CAM_DRV.set_binning(i_binx, i_biny, cam);
            if ( cam->msg[0] == 0 ) {
               // je met a jour les coordonnees du fenetrage pour prendre en compte le binning
               CAM_DRV.update_window(cam);
               sprintf(ligne, "%d %d", cam->binx, cam->biny);
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            } else {
               Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
               result = TCL_ERROR;
            }
         }
         Tcl_Free((char *) listArgv);
      }
   }
   return result;
}

static int cmdCamExptime(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int retour = TCL_OK;
   char ligne[256];
   double d_exptime;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?exptime?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      if( cam->exptime > 0.1 ) {
         sprintf(ligne, "%.2f", cam->exptime);
      } else {
         sprintf(ligne, "%f", cam->exptime);
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_GetDouble(interp, argv[2], &d_exptime) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?num?\nnum = must be a float > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_ERROR;
      } else {
         cam = (struct camprop *) clientData;
         cam->exptime = (float) d_exptime;
         if( cam->exptime > 0.1 ) {
            sprintf(ligne, "%.2f", cam->exptime);
         } else {
            sprintf(ligne, "%f", cam->exptime);
         }
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      }
   }
   return retour;
}

static int cmdCamWindow(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   const char **listArgv;
   int listArgc;
   int i_x1, i_y1, i_x2, i_y2;
   int result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?{x1 y1 x2 y2}?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d %d %d %d", cam->x1 + 1, cam->y1 + 1, cam->x2 + 1, cam->y2 + 1);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_SplitList(interp, argv[2], &listArgc, &listArgv) != TCL_OK) {
         sprintf(ligne, "Window struct not valid: must be {x1 y1 x2 y2}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else if (listArgc != 4) {
         sprintf(ligne, "Window struct not valid: must be {x1 y1 x2 y2}");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if (Tcl_GetInt(interp, listArgv[0], &i_x1) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\nx1 : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else if (Tcl_GetInt(interp, listArgv[1], &i_y1) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\ny1 : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else if (Tcl_GetInt(interp, listArgv[2], &i_x2) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\nx2 : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else if (Tcl_GetInt(interp, listArgv[3], &i_y2) != TCL_OK) {
            sprintf(ligne, "Usage: %s %s {x1 y1 x2 y2}\ny2 : must be an integer", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            cam = (struct camprop *) clientData;
            cam->x1 = i_x1 - 1;
            cam->y1 = i_y1 - 1;
            cam->x2 = i_x2 - 1;
            cam->y2 = i_y2 - 1;
            CAM_DRV.update_window(cam);
            sprintf(ligne, "%d %d %d %d", cam->x1 + 1, cam->y1 + 1, cam->x2 + 1, cam->y2 + 1);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         }
         Tcl_Free((char *) listArgv);
      }
   }
   return result;
}


/*
 * cmdCamBuf
 * Lecture/ecriture du numero de buffer associe a la camera.
 */
static int cmdCamBuf(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int i_bufno, result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?bufno?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->bufno);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_GetInt(interp, argv[2], &i_bufno) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?bufno?\nbufno : must be an integer > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         cam = (struct camprop *) clientData;
         cam->bufno = i_bufno;

         // je cree la command buf$bufNo qui renvoit dans le thread principal
         sprintf(ligne, "buf%d",i_bufno); 
         Tcl_DeleteCommand(interp, ligne);
         Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)libcam_threadAliasCommand,(ClientData)cam->mainThreadId,NULL);

         sprintf(ligne, "%d", cam->bufno);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      }
   }
   return result;
}


/*
 * cmdCamTel
 * Lecture/ecriture du numero de telescope associe a la camera.
 */
static int cmdCamTel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int i_telno, result = TCL_OK;
   struct camprop *cam;

   if ( argc < 2 || argc > 4) {
      sprintf(ligne, "Usage: %s %s ?telno? ?telThreadId?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->telno);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_GetInt(interp, argv[2], &i_telno) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?telno?\ntelno : must be an integer > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         cam = (struct camprop *) clientData;
         cam->telno = i_telno;
         if ( argc >= 4 &&  cam->camThreadId[0] != 0 ) {
            strcpy(cam->telThreadId, argv[3]);
            // je cree la command tel$telNo qui appelle la commande tel$telNo dans le thread du telescope            
            sprintf(ligne, "tel%d",i_telno); 
            Tcl_DeleteCommand(interp, ligne);
            Tcl_CreateCommand(interp,ligne,(Tcl_CmdProc *)libcam_threadAliasCommand,(ClientData)cam->telThreadId,NULL);

         }
         if (result == TCL_OK) {
            //--- je retourne le numero du telescope
            sprintf(ligne, "%d", cam->telno);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         }
      }
   }
   return result;
}

static int cmdCamHeaderProc(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?kwd_header_proc? ",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      cam = (struct camprop*)clientData;
        if(argc!=2) {
          sprintf(cam->headerproc,"%s",argv[2]);
        }
      sprintf(ligne,"%s",cam->headerproc);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/*
 * cmdCamTel
 * Lecture/ecriture de l'incateur pour recuperer ou non les coordonnee du telescope
 */
static int cmdCamRadecFromTel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int value, result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->radecFromTel);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      if (Tcl_GetInt(interp, argv[2], &value) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be an integer 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if ( value !=0 && value != 1 ) {
            sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be an integer 0 or 1", argv[0], argv[1]);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            cam = (struct camprop *) clientData;
            cam->radecFromTel = value;
            sprintf(ligne, "%d", cam->radecFromTel);
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         }
      }
   }
   return result;
}

static int cmdCamThreadId(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", cam->camThreadId);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/*
 * AcqRead
 * Commande de lecture du CCD.
 */
static void AcqRead(ClientData clientData )
{
   char errorMessage[1024];
   char s[30000];
   float *p;       

   struct camprop *cam = (struct camprop *) clientData;
   setCameraStatus(cam,"read");
   strcpy(errorMessage,"");

	// cam->mode_stop_acq, 0=read after stop 1=let the previous image without reading (abort acquisition)
	if ((cam->mode_stop_acq==1)&&(cam->stop_detected==1)) {
		if (cam->timerExpiration != NULL) {
			setCameraStatus(cam,"stand");
		}
		cam->clockbegin = 0;

		if (cam->timerExpiration != NULL) {
			Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
			free(cam->timerExpiration);
			cam->timerExpiration = NULL;
		}

		if ( cam->blockingAcquisition == 1 ) {
			// je prepare le message d'erreur qui sera retourne par cmdCamAcq
			strcpy(cam->msg,errorMessage);
		}
		// je signale a cmdCamAcq que l'acquisition est terminée
		cam->acquisitionInProgress = 0;
		return;
	}

   // Information par defaut concernant l'image
   // ATTENTION : la camera peut mettre a jour ces valeurs pendant l'execution de read_ccd()
   strcpy(cam->pixels_classe, "CLASS_GRAY");
   strcpy(cam->pixels_format, "FORMAT_USHORT");
   strcpy(cam->pixels_compression, "COMPRESS_NONE");
   cam->pixel_data = NULL;
   strcpy(cam->msg,"");
   cam->gps_date = 0;    // mis a 1 par CAM_DRV.read_ccd si la camera a une datation avec GPS
   strcpy(cam->rawFilter,"");
   // allocation par defaut du buffer
   p = (float *) calloc(cam->w * cam->h, sizeof(float));

   libcam_GetCurrentFITSDate(cam->interp, cam->date_end);


   //  capture
   // TODO 2 : une autre solution serait de passer l'adresse de p  comme ceci :
   // CAM_DRV.read_ccd(cam, (unsigned short **)&p);
   // mais il faut modifier toutes les camera !! ( michel pujol)
   CAM_DRV.read_ccd(cam, p);


   // si cam->pixel_data n'est pas nul, la camera a mis les pixels dans cam->pixel_data
   if (cam->pixel_data != NULL) {
      if (cam->pixel_data != (void *)-1) {
         // je supprime le buffer par defaut pointe par "p"
         free( p);
         // je fais pointer "p" sur le buffer cree par la camera
         // ATTENTION : le format des donnees est indique dans cam->pixels_classe, cam->pixels_format et cam->pixels_compression
         p =  cam->pixel_data;
      }
   }

   if (strlen(cam->msg) == 0) {      
      IBuffer* buffer = ILibaudela::findBuffer(cam->bufno);
      // je supprime les mots cles et l'image pprecedente du buffer
      buffer->FreeBuffer(1);
      if ( strcmp(cam->pixels_classe, "CLASS_GRAY")==0) {
         buffer->setPixels(cam->w, cam->h, 1, p, cam->mirrorv , cam->mirrorh);
         buffer->setKeyword("NAXIS", 2, "", "");
         buffer->setKeyword("NAXIS1", cam->w, "", "");
         buffer->setKeyword("NAXIS2", cam->h, "", "");
      } else {
         buffer->setPixels(cam->w, cam->h, 3, p,  cam->mirrorv , cam->mirrorh);
         buffer->setKeyword("NAXIS", 3, "", "");
         buffer->setKeyword("NAXIS1", cam->w, "", "");
         buffer->setKeyword("NAXIS2", cam->h, "", "");
         buffer->setKeyword("NAXIS3", 3, "", "");
      }

      buffer->setKeyword("BIN1", cam->binx, "", "");
      buffer->setKeyword("BIN2", cam->biny, "", "");
      buffer->setKeyword("DATE-OBS", cam->date_obs, "", "");
      buffer->setKeyword("DATE-END", cam->date_end, "", "");
      buffer->setKeyword("EXPOSURE", cam->exptime, "", "");
      if (cam->timerExpiration != NULL) {
         buffer->setKeyword("EXPOSURE", cam->exptime, "", "");
      } else {
         sprintf(s, "expr (([mc_date2jd %s]-[mc_date2jd %s])*86400.)", cam->date_end, cam->date_obs);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(cam->interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, Tcl_GetStringResult(cam->interp));
         }
         float exptime = (float) atof(Tcl_GetStringResult(cam->interp));
         buffer->setKeyword("EXPOSURE", exptime, "", "");
      }

      if (cam->gps_date == 1) {
         buffer->setKeyword("GPS-DATE", 1, "if datation is derived from GPS, else 0", "");
         char cameraName[1024];
         sprintf(cameraName, "%s+GPS %s %s", CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
         buffer->setKeyword("CAMERA", cameraName, "", "");
      } else {
         buffer->setKeyword("GPS-DATE", 0, "if datation is derived from GPS, else 0", "");
         char cameraName[1024];
         sprintf(cameraName, "%s %s %s", CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
         buffer->setKeyword("CAMERA", cameraName, "", "");
      }

      // j'ajoute les mots cles specifique a une image RAW
      if( strcmp(cam->rawFilter,"") != 0) {
         buffer->setKeyword("RAWFILTE", cam->rawFilter, "Raw bayer matrix keys", "" );
         buffer->setKeyword("RAWCOLOR", cam->rawColor,  "Raw color plane number", "" );
         buffer->setKeyword("RAWBLACK", cam->rawBlack,  "Raw low cut", "" );
         buffer->setKeyword("RAWMAXI",  cam->rawMaxi,   "Raw hight cut", "" );
      }

      // je soustrais le dark
      if ( cam->darkBufNo != 0 ) {
         sprintf(s, "buf%d sub %d", cam->bufno, cam->darkBufNo );
         if (Tcl_Eval(cam->interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, Tcl_GetStringResult(cam->interp));
            sprintf(errorMessage,"Error substract dark: %s", Tcl_GetStringResult(cam->interp));
         }
      }



      //- call the header proc to add additional informations
      if ( cam->headerproc[0] != 0 ) {
         sprintf(s,"set libcam(header) [%s]",cam->headerproc);
         libcam_log(LOG_DEBUG, s);
         if (Tcl_Eval(cam->interp, s) == TCL_ERROR) {
            libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, Tcl_GetStringResult(cam->interp));
         }
         if (atoi(Tcl_GetStringResult(cam->interp))==0) {
            sprintf(s, "foreach header $libcam(header) { buf%d setkwd $header }", cam->bufno);
            libcam_log(LOG_DEBUG, s);
            if (Tcl_Eval(cam->interp, s) == TCL_ERROR) {
               libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, Tcl_GetStringResult(cam->interp));
            }
         }
      }


      if ( cam->radecFromTel  == 1 ) {
         double ra, dec;
         int status;
         libcam_get_tel_coord(cam->interp, &ra, &dec, cam, &status);
         //printf("libcam.c: libcam_get_tel_coord:status=%d\n", status);
         if (status == 0) {
            // Add FITS keywords
            sprintf(s, "buf%d setkwd {RA %7.3f float \"Right ascension telescope encoder\" \"\"}", cam->bufno, ra);
            libcam_log(LOG_DEBUG, s);
            Tcl_Eval(cam->interp, s);
            sprintf(s, "buf%d setkwd {DEC %7.3f float \"Declination telescope encoder\" \"\"}", cam->bufno, dec);
            libcam_log(LOG_DEBUG, s);
            Tcl_Eval(cam->interp, s);
         }
      }
   } else {
      // erreur d'acquisition, on enregistre une image vide
      sprintf(s, "buf%d clear", cam->bufno );
      libcam_log(LOG_DEBUG, s);
      if (Tcl_Eval(cam->interp, s) == TCL_ERROR) {
         libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, Tcl_GetStringResult(cam->interp));
      }
   }

   free(p);

   cam->clockbegin = 0;

   if (cam->timerExpiration != NULL) {
      Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
      free(cam->timerExpiration);
      cam->timerExpiration = NULL;
   }

   if ( cam->blockingAcquisition == 1 ) {
      // je prepare le message d'erreur qui sera retourne par cmdCamAcq
      strcpy(cam->msg,errorMessage);
   }
   // je signale a cmdCamAcq que l'acquisition est terminée
   cam->acquisitionInProgress = 0;
   
   setCameraStatus(cam,"stand");
}

/*
 * cmdCamAcq()
 * Commande de demarrage d'une acquisition.
 */
static int cmdCamAcq(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[100];
   int i;
   struct camprop *cam;
   int result = TCL_OK;

   if (argc != 2 && argc != 3) {
      sprintf(ligne, "Usage: %s %s ?-blocking?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      cam = (struct camprop *) clientData;
      if ( argc == 3 ) {
         cam->blockingAcquisition = 1;
      } else {
         cam->blockingAcquisition = 0;
      }

      if (cam->timerExpiration == NULL) {         
         cam->exptimeTimer = cam->exptime;
         cam->timerExpiration = (struct TimerExpirationStruct *) calloc(1, sizeof(struct TimerExpirationStruct));
         cam->timerExpiration->clientData = clientData;
         cam->timerExpiration->interp = interp;
         strcpy(cam->msg,"");

         Tcl_Eval(interp, "clock seconds");
         cam->clockbegin = (unsigned long) atoi(Tcl_GetStringResult(interp));

			cam->stop_detected=0;
         CAM_DRV.start_exp(cam, "amplioff");

         if(strcmp(cam->msg,"")!= 0 ) {
            // erreur pendant start_exp
            if (cam->timerExpiration != NULL) {
               Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
               free(cam->timerExpiration);
               cam->timerExpiration = NULL;
            }
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            // je teste cam->timerExpiration car il peut etre nul si cmdCamStop a ete appele entre temps
            if( cam->timerExpiration != NULL ) {
               libcam_GetCurrentFITSDate(cam->interp, cam->date_obs);
               /* Creation du timer pour realiser le temps de pose. */
               i = (int) (1000 * cam->exptimeTimer);
               cam->timerExpiration->TimerToken = Tcl_CreateTimerHandler(i, AcqRead, (ClientData) cam);
               // j'indique que la pose est en cours
               setCameraStatus(cam,"exp");

            } else {
               Tcl_SetResult(interp, (char*) "", TCL_VOLATILE);
               result = TCL_OK;
            }

            if(cam->blockingAcquisition == 1 ) {
               // j'attend la fin de l'acquisition
               int foundEvent = 1;
               cam->acquisitionInProgress = 1;
               while (cam->acquisitionInProgress != 0 && foundEvent) {
                  foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
                  //if (Tcl_LimitExceeded(interp)) {
                  //   break;
                  //}
               }
               if( cam->timerExpiration != NULL ) {
                  Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
                  if (cam->timerExpiration != NULL) {
                     free(cam->timerExpiration);
                     cam->timerExpiration = NULL;
                  }
               }
               if ( cam->msg[0] != 0 ) {
                  // je transmet le message d'erreure au scipt TCL
                  Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
                  result = TCL_ERROR;
               } else {
                  Tcl_SetResult(interp, (char*) "", TCL_VOLATILE);
                  result = TCL_OK;
               }
            }
         }
      } else {
         sprintf(ligne, "Camera already in use");
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}


/*
 * cmdCamStop()
 * Commande d'arret d'une acquisition.
 */
static int cmdCamStop(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    struct camprop *cam;
    int retour = TCL_OK;

    cam = (struct camprop *) clientData;
    cam->acquisitionInProgress = 2;

    if (cam->timerExpiration != NULL ) {
        Tcl_DeleteTimerHandler(cam->timerExpiration->TimerToken);
        if (cam->timerExpiration != NULL) {
            free(cam->timerExpiration);
            cam->timerExpiration = NULL;
        }
        CAM_DRV.stop_exp(cam);
        AcqRead((ClientData) cam);
    }
    else if ( cam->capabilities.videoMode == 1 ) {
        CAM_DRV.stop_exp(cam);
    }
    else {
        setCameraStatus(cam,"stand");
    }

    return retour;
}

static int cmdCamCapabilities(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "expTimeCommand %d expTimeList %d videoMode %d",
      cam->capabilities.expTimeCommand,
      cam->capabilities.expTimeList,
      cam->capabilities.videoMode
      );
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}


static int cmdCamDrivername(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   sprintf(ligne, "%s {%s}", CAM_LIBNAME, __DATE__);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}


static int cmdCamName(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", CAM_INI[cam->index_cam].name);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamProduct(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", CAM_INI[cam->index_cam].product);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}


static int cmdCamCcd(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", CAM_INI[cam->index_cam].ccd);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamNbcells(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%d %d", cam->nb_photox, cam->nb_photoy);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamNbpix(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%d %d", cam->nb_photox / cam->binx, cam->nb_photoy / cam->biny);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamCelldim(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int retour;
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if ((argc != 2) && (argc != 4)) {
      sprintf(ligne, "Usage: %s %s ?celldimx? ?celldimy?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else if (argc == 2) {
      sprintf(ligne, "%g %g", cam->celldimx, cam->celldimy);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_OK;
   } else {
      double celldimx, celldimy;
      if (Tcl_GetDouble(interp, argv[2], &celldimx) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?num?\ncelldimx must be a float > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_ERROR;
      } else if (Tcl_GetDouble(interp, argv[3], &celldimy) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?num?\ncelldimy must be a float > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_ERROR;
      } else {
         cam->celldimx = celldimx;
         cam->celldimy = celldimy;
         sprintf(ligne, "%g %g", cam->celldimx, cam->celldimy);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         retour = TCL_OK;
      }
   }
   return retour;


   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamPixdim(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%g %g", cam->celldimx * cam->binx, cam->celldimy * cam->biny);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamMaxdyn(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%f", CAM_INI[cam->index_cam].maxconvert);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamFillfactor(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%f", cam->fillfactor);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamInfo(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s %s %s", CAM_LIBNAME, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamPort(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", cam->portname);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamTimer(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   /* --- renvoie le nombre de secondes ecoulees depuis le debut de pose --- */
   char ligne[256];
   struct camprop *cam;
   int sec, count;
   cam = (struct camprop *) clientData;
   count = 1;
   if (argc >= 3) {
      if (strcmp(argv[2], "-countdown") == 0) {
         count = -1;
      }
      if (strcmp(argv[2], "-1") == 0) {
         count = -1;
      }
   }
   if (cam->clockbegin != 0) {
      /*if(cam->timerExpiration!=NULL) { */
      Tcl_Eval(interp, "clock seconds");
      sec = (int) ((unsigned long) atol(Tcl_GetStringResult(interp)) - cam->clockbegin);
      if (count == -1) {
         sec = (int) (cam->exptime) - sec;
      }
      sprintf(ligne, "%d", sec);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      strcpy(ligne, "-1");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return TCL_OK;
}

static int cmdCamGain(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%f", CAM_INI[cam->index_cam].gain);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamReadnoise(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%f", CAM_INI[cam->index_cam].readnoise);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamTemperature(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   CAM_DRV.measure_temperature(cam);
   sprintf(ligne, "%f", cam->temperature);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamRgb(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   sprintf(ligne, "%s", cam_rgbs[cam->rgbindex]);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

/* --- Action commands ---*/

static int cmdCamShutter(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256], ligne2[50];
   int result = TCL_OK, pb = 0, k = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc != 2) && (argc != 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      k = 0;
      pb = 1;
      while (cam_shutters[k] != NULL) {
         if (strcmp(argv[2], cam_shutters[k]) == 0) {
            cam->shutterindex = k;
            pb = 0;
            break;
         }
         k++;
      }
      if ((cam->shutterindex == 0) || (cam->shutterindex == 1)) {
         CAM_DRV.shutter_off(cam);
      }
      if (cam->shutterindex == 2) {
         CAM_DRV.shutter_on(cam);
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      k = 0;
      while (cam_shutters[k] != NULL) {
         sprintf(ligne2, "%s", cam_shutters[k]);
         strcat(ligne, ligne2);
         if (cam_shutters[++k] != NULL) {
            strcat(ligne, "|");
         }
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne, "%s", cam_shutters[cam->shutterindex]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

static int cmdCamCooler(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256], ligne2[50];
   int result = TCL_OK, pb = 0, k = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      k = 0;
      pb = 1;
      while (cam_coolers[k] != NULL) {
         if (strcmp(argv[2], cam_coolers[k]) == 0) {
            cam->coolerindex = k;
            pb = 0;
            break;
         }
         k++;
      }
      if (argc == 4) {
         cam->check_temperature = atof(argv[3]);
      }
      if (cam->coolerindex == 0) {
         CAM_DRV.cooler_off(cam);
      }
      if (cam->coolerindex == 1) {
         CAM_DRV.cooler_on(cam);
      }
      if (cam->coolerindex == 2) {
         CAM_DRV.cooler_check(cam);
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      k = 0;
      while (cam_coolers[k] != NULL) {
         sprintf(ligne2, "%s", cam_coolers[k]);
         strcat(ligne, ligne2);
         if (cam_coolers[++k] != NULL) {
            strcat(ligne, "|");
         }
         strcat(ligne, " ?temperature?");
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%s", cam_coolers[cam->coolerindex]);
      if (strcmp(cam_coolers[cam->coolerindex], "check") == 0) {
         sprintf(ligne2, " %f", cam->check_temperature);
         strcat(ligne, ligne2);
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

static int cmdCamInterrupt(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0, choix = 1;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      pb = 1;
      choix = atoi(argv[2]);
      if (choix == 0) {
         cam->interrupt = 0;
         pb = 0;
         cam->authorized = 1;
      }
      if (choix == 1) {
         cam->interrupt = 1;
         pb = 0;
         cam->authorized = 1;
      }
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      strcat(ligne, " 0|1");
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne, "%d", cam->interrupt);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

static int cmdCamOverscan(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256], ligne2[50];
   int result = TCL_OK, pb = 0, k = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc < 2) || (argc > 4)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      k = 0;
      pb = 1;
      while (cam_overscans[k] != NULL) {
         if (strcmp(argv[2], cam_overscans[k]) == 0) {
            cam->overscanindex = k;
            pb = 0;
            break;
         }
         k++;
      }
      cam->nb_photox = CAM_INI[cam->index_cam].maxx;    /* nombre de photosites sur X */
      cam->nb_photoy = CAM_INI[cam->index_cam].maxy;    /* nombre de photosites sur Y */
      if (cam->overscanindex == 0) {
         /* nb photosites masques autour du CCD */
         cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg;
         cam->nb_deadendphotox = CAM_INI[cam->index_cam].overscanxend;
         cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg;
         cam->nb_deadendphotoy = CAM_INI[cam->index_cam].overscanyend;
      } else {
         cam->nb_photox += (CAM_INI[cam->index_cam].overscanxbeg + CAM_INI[cam->index_cam].overscanxend);
         cam->nb_photoy += (CAM_INI[cam->index_cam].overscanybeg + CAM_INI[cam->index_cam].overscanyend);
         /* nb photosites masques autour du CCD */
         cam->nb_deadbeginphotox = 0;
         cam->nb_deadendphotox = 0;
         cam->nb_deadbeginphotoy = 0;
         cam->nb_deadendphotoy = 0;
      }
      /* --- initialisation de la fenetre par defaut --- */
      cam->x1 = 0;
      cam->y1 = 0;
      cam->x2 = cam->nb_photox - 1;
      cam->y2 = cam->nb_photoy - 1;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ", argv[0], argv[1]);
      k = 0;
      while (cam_overscans[k] != NULL) {
         sprintf(ligne2, "%s", cam_overscans[k]);
         strcat(ligne, ligne2);
         if (cam_overscans[++k] != NULL) {
            strcat(ligne, "|");
         }
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%s", cam_overscans[cam->overscanindex]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

static int cmdCamFoclen(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK, pb = 0;
   struct camprop *cam;
   double d;
   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?focal_length_(meters)?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%f", cam->foclen);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   } else {
      pb = 0;
      if (Tcl_GetDouble(interp, argv[2], &d) != TCL_OK) {
         pb = 1;
      }
      if (pb == 0) {
         if (d <= 0.0) {
            pb = 1;
         }
      }
      if (pb == 1) {
         sprintf(ligne, "Usage: %s %s ?focal_length_(meters)?\nfocal_length : must be an float > 0", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         cam = (struct camprop *) clientData;
         cam->foclen = d;
         sprintf(ligne, "%f", cam->foclen);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      }
   }
   return result;
}

static int cmdCamMirrorH(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->mirrorh);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      cam = (struct camprop *) clientData;
      if (Tcl_GetInt(interp, argv[2], &cam->mirrorh) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         // je met a jour les coordonnees du fenetrage pour prendre en compte le miroir
         CAM_DRV.update_window(cam);
         Tcl_SetResult(interp, (char*) "", TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}

static int cmdCamMirrorV(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct camprop *cam;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%d", cam->mirrorv);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      cam = (struct camprop *) clientData;
      if (Tcl_GetInt(interp, argv[2], &cam->mirrorv) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1?\n   Value must be 0 or 1", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         // je met a jour les coordonnees du fenetrage pour prendre en compte le miroir
         CAM_DRV.update_window(cam);
         Tcl_SetResult(interp, (char*) "", TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}

static int cmdCamStopMode(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc >= 3)) {
		cam->mode_stop_acq=atoi(argv[2]);
		if (cam->mode_stop_acq<1) {
			cam->mode_stop_acq=0;
		} else {
			cam->mode_stop_acq=1;
		}
	}
   sprintf(ligne, "%d", cam->mode_stop_acq);
   Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   return TCL_OK;
}

static int cmdCamClose(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   struct camprop *cam;
   char s[256];

   cam = (struct camprop *) clientData;
   if (CAM_DRV.close != NULL) {
      CAM_DRV.close(cam);
   }

   // je supprime la variable globale contenant le status de la camera
   unsetCameraStatus(cam); 

   // je supprime le buffer du dark
   if ( cam->darkBufNo != 0 ) {
       sprintf(s, "buf::delete %d", cam->darkBufNo);
       Tcl_Eval(interp, s);
   }

   // je supprime le nom du fichier du dark
   if ( cam->darkFileName != NULL ) {
      free(cam->darkFileName);
      cam->darkFileName = NULL;
   }
   Tcl_ResetResult(interp);
   return TCL_OK;
}

/*
 * -----------------------------------------------------------------------------
 *  cmdCamLastError()
 *
 *  retourne le dernier message d'erreur de la camera
 *
 *  cette commande est particulierement utile pour savoir s'il y eu une erreur
 *  pendant une acquisition car la commande "cam1 ne retourne pas d'exception
 *  pour signaler d'eventuelle erreur
 *
 *  param
 *     pas de parametre
 *  return
 *     retourn le dernier message d'erreur, ou une chaine vide s'il n'y a pas d'erreur
 * -----------------------------------------------------------------------------
 */
static int cmdCamLastError(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int retour = TCL_OK;
   char ligne[1024];
   struct camprop *cam;

   if (argc != 2) {
      sprintf(ligne, "Usage: %s %s", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      cam = (struct camprop *) clientData;
      sprintf(ligne, "%s", cam->msg);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return retour;
}

static int cam_init_common(struct camprop *cam, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --------------------------------------------------------- */
/* argv[2] : symbole du port (lpt1,etc.)                     */
/* argv[>=3] : optionnels : -ccd -num -name                  */
/* --------------------------------------------------------- */
{
   int k, kk;

   /* --- Decode les options de cam::create en fonction de argv[>=3] --- */
   cam->index_cam = 0;
	cam->mode_stop_acq=1; // 0=read after stop 1=let the previous image without reading
	cam->stop_detected=0;
   strcpy(cam->portname,"unknown");
   sprintf(logFileName, "%s_%d.log", argv[1], cam->camno);
   if (argc >= 5) {
      // je copie le nom du port en limitant le nombre de caractères à la taille maximal de cam->portname
      strncpy(cam->portname,argv[2], sizeof(cam->portname) -1);
      for (kk = 3; kk < argc - 1; kk++) {
         if (strcmp(argv[kk], "-name") == 0) {
            k = 0;
            while (strcmp(CAM_INI[k].name, "") != 0) {
               if (strcmp(CAM_INI[k].name, argv[kk + 1]) == 0) {
                  cam->index_cam = k;
                  break;
               }
               k++;
            }
         }
         if (strcmp(argv[kk], "-ccd") == 0) {
            k = 0;
            while (strcmp(CAM_INI[k].name, "") != 0) {
               if (strcmp(CAM_INI[k].ccd, argv[kk + 1]) == 0) {
                  cam->index_cam = k;
                  break;
               }
               k++;
            }
         }

         
         if (strcmp(argv[kk], "-debug_directory") == 0) {
            if ( kk +1 <  argc ) {
               char fileTempName[1024];
               // je conserve le nom du fichier de log
               strcpy(fileTempName,logFileName);
               // je recupere le repertoire du fichier de traces
	            strcpy(logFileName, argv[kk + 1]);
               // je concatene un "/" a la fin du repertoire s'il n'y est pas deja
               if ( logFileName[strlen(logFileName)-1]!= '\\' && logFileName[strlen(logFileName)-1]!= '/' && strlen(logFileName)!=0 ) {
                  strcat(logFileName,"/");
               }
               // je concatene le nom du fichier de trace 
               strcat(logFileName, fileTempName);
#ifdef WIN32
               {
                  unsigned int c;
                  for(c=0; c<strlen(logFileName); c++ ) {
                     if( logFileName[c] == '/' ) {
                        logFileName[c] = '\\';
                     }
                  }
               }
#endif
            }
	      }

         if (strcmp(argv[kk], "-log_level") == 0) {
            if ( kk +1 <  argc ) {
               debug_level = atoi(argv[kk + 1]);
            }            
         }

         if (strcmp(argv[kk], "-log_file") == 0) {
            if ( kk +1 <  argc ) {
	            strcpy(logFileName, argv[kk + 1]);
#ifdef WIN32
               {
                  unsigned int c;
                  for(c=0; c<strlen(logFileName); c++ ) {
                     if( logFileName[c] == '/' ) {
                        logFileName[c] = '\\';
                     }
                  }
               }
#endif
            }

         }
      }
   }
   /* --- authorize the sti/cli functions --- */
   if (cam->authorized == 0) {
      cam->interrupt = 0;
   } else {
      cam->interrupt = 1;
   }
   /* --- L'axe X est choisi parallele au registre horizontal. --- */
   cam->overscanindex = CAM_INI[cam->index_cam].overscanindex;
   cam->nb_photox = CAM_INI[cam->index_cam].maxx;   /* nombre de photosites sur X */
   cam->nb_photoy = CAM_INI[cam->index_cam].maxy;   /* nombre de photosites sur Y */
   if (cam->overscanindex == 0) {
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg;
      cam->nb_deadendphotox = CAM_INI[cam->index_cam].overscanxend;
      cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg;
      cam->nb_deadendphotoy = CAM_INI[cam->index_cam].overscanyend;
   } else {
      cam->nb_photox += (CAM_INI[cam->index_cam].overscanxbeg + CAM_INI[cam->index_cam].overscanxend);
      cam->nb_photoy += (CAM_INI[cam->index_cam].overscanybeg + CAM_INI[cam->index_cam].overscanyend);
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = 0;
      cam->nb_deadendphotox = 0;
      cam->nb_deadbeginphotoy = 0;
      cam->nb_deadendphotoy = 0;
   }
   cam->celldimx = CAM_INI[cam->index_cam].celldimx;    /* taille d'un photosite sur X (en metre) */
   cam->celldimy = CAM_INI[cam->index_cam].celldimy;    /* taille d'un photosite sur Y (en metre) */
   cam->fillfactor = CAM_INI[cam->index_cam].fillfactor;    /* fraction du photosite sensible a la lumiere */
   cam->foclen = CAM_INI[cam->index_cam].foclen;
   /* --- initialisation de la fenetre par defaut --- */
   cam->x1 = 0;
   cam->y1 = 0;
   cam->x2 = cam->nb_photox - 1;
   cam->y2 = cam->nb_photoy - 1;
   /* --- initialisation du mode de binning par defaut --- */
   cam->binx = CAM_INI[cam->index_cam].binx;
   cam->biny = CAM_INI[cam->index_cam].biny;
   /* --- initialisation du temps de pose par defaut --- */
   cam->exptime = (float) CAM_INI[cam->index_cam].exptime;

   /* --- initialisation des retournements par defaut --- */
   cam->mirrorh = 0;
   cam->mirrorv = 0;
   /* --- initialisation du numero de port parallele du PC --- */
   cam->portindex = 0;
   cam->port = 0x378;       /* lpt1 par defaut */
   if (argc >= 2) {
      if (strcmp(argv[2], cam_ports[1]) == 0) {
         cam->portindex = 1;
         cam->port = 0x278;
      }
   }
   cam->check_temperature = CAM_INI[cam->index_cam].check_temperature;
   cam->timerExpiration = NULL;
   cam->radecFromTel = 1;
   strcpy(cam->headerproc,"");
   cam->blockingAcquisition = 0;
   //---  valeurs par defaut des capacites offertes par la camera
   cam->capabilities.expTimeCommand = 1;  // existence  du choix du temps de pose
   cam->capabilities.expTimeList    = 0;  // existence  de la liste des temps de pose predefini
   cam->capabilities.videoMode      = 0;  // existence  du mode video
   cam->acquisitionInProgress = 0;
   cam->gps_date = 0;
   cam->darkBufNo = 0;                // buffer contenant l'image du dark a soustraire apres chaque acquisition
   cam->darkFileName = NULL;
   strcpy(cam->rawFilter,"");
   return 0;
}

static int cmdCamLogLevel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?0|1|2|3|4?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      sprintf(ligne, "%d", debug_level);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_OK;
   } else {
      if (Tcl_GetInt(interp, argv[2], &debug_level) != TCL_OK) {
         sprintf(ligne, "Usage: %s %s ?0|1|2|3|4?\n   Value must be 0 to 4", argv[0], argv[1]);
         Tcl_SetResult(interp, ligne, TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp, (char*) "", TCL_VOLATILE);
         result = TCL_OK;
      }
   }
   return result;
}

static int cmdCamLogFile(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   int result = TCL_OK;

   if (argc != 2) {
      sprintf(ligne, "Usage: %s %s", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      Tcl_SetResult(interp, (char*) logFileName, TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}




void setCameraStatus(struct camprop *cam, const char * status)
{
   char s[256];
   // je change l'etat de la variable dans la thread principale
   sprintf(s, "set ::status_cam%d {%s}", cam->camno, status);
   MainThreadEval(cam, s);
   Tcl_Eval(cam->interp, s);
}

void unsetCameraStatus(struct camprop *cam)
{
   char s[256];
   // je supprime la variable dans la thread principale
   sprintf(s, "unset ::status_cam%d", cam->camno);
   MainThreadEval(cam, s);
   Tcl_Eval(cam->interp, s);
}

void setScanResult(struct camprop *cam, const char * status)
{
   char s[256];
   sprintf(s, "set ::scan_result%d {%s}", cam->camno, status);
   MainThreadEval(cam, s);
}

void MainThreadEval(struct camprop *cam, const char * command) {
   std::ostringstream procedure;
   procedure << "thread::send -async " << cam->mainThreadId << " { " << command << " }"; 
   Tcl_Eval(cam->interp, procedure.str().c_str());
}

static int cmdCamDark(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[1024];
   int result = TCL_OK;

   if ((argc != 2) && (argc != 3)) {
      sprintf(ligne, "Usage: %s %s ?filename? ", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else if (argc == 2) {
      // je retourne le nom du fichier
      struct camprop *cam = (struct camprop *) clientData;
      if ( cam->darkFileName == NULL) {
         Tcl_SetResult(interp, (char*)"", TCL_VOLATILE);;
      } else {
         Tcl_SetResult(interp, cam->darkFileName, TCL_VOLATILE);
      }
      result = TCL_OK;
   } else {
      struct camprop *cam = (struct camprop *) clientData;

      // je supprime le buffer
      if ( cam->darkBufNo != 0 ) {
          sprintf(ligne, "buf::delete %d", cam->darkBufNo);
          if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
            sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], Tcl_GetStringResult(interp) );
            Tcl_SetResult(interp, ligne, TCL_VOLATILE);
            result = TCL_ERROR;
         } else {
            cam->darkBufNo = 0;
            Tcl_SetResult(interp, (char*) "", TCL_VOLATILE);
            result = TCL_OK;
         }
      }
      // je supprime le nom du fichier
      if ( cam->darkFileName != NULL ) {
         free(cam->darkFileName);
         cam->darkFileName = NULL;
      }

      if ( strcmp(argv[2],"") != 0) {
         // je cree le buffer
         if ( cam->darkBufNo == 0 ) {
            sprintf(ligne, "buf::create");
            if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
               sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], Tcl_GetStringResult(interp) );
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               cam->darkBufNo = atoi(Tcl_GetStringResult(interp));
            }
         }
         // je charge l'image
         if ( result==TCL_OK) {
            sprintf(ligne, "buf%d load {%s}", cam->darkBufNo,argv[2]);
            if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
               sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], Tcl_GetStringResult(interp) );
               Tcl_SetResult(interp, ligne, TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               // je verifie que le dark a les memes dimensions que le capteur de la camera
               sprintf(ligne, "buf%d getpixelswidth", cam->darkBufNo);
               if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
                  sprintf(ligne, "%s %s %s : %s", argv[0], argv[1], argv[2], Tcl_GetStringResult(interp) );
                  Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                  result = TCL_ERROR;
               } else {
                  int darkWidth = atoi(Tcl_GetStringResult(interp));
                  if ( darkWidth != cam->nb_photox / cam->binx ) {
                     sprintf(ligne, "%s %s %s \nError : dark width (%d) is different from camera width (%d)",
                        argv[0], argv[1], argv[2], darkWidth, cam->nb_photox / cam->binx);
                     Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                     result = TCL_ERROR;
                  }
               }
               if ( result == TCL_OK) {
                  sprintf(ligne, "buf%d getpixelsheight", cam->darkBufNo);
                  if (Tcl_Eval(interp, ligne) == TCL_ERROR) {
                     sprintf(ligne, "%s %s %s \nError :%s", argv[0], argv[1], argv[2], Tcl_GetStringResult(interp) );
                     Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                     result = TCL_ERROR;
                  } else {
                     int darkHeight = atoi(Tcl_GetStringResult(interp));
                     if ( darkHeight != cam->nb_photoy / cam->biny ) {
                        sprintf(ligne, "%s %s %s : dark width (%d) is different from camera width (%d) ",
                           argv[0], argv[1], argv[2], darkHeight, cam->nb_photoy / cam->biny);
                        Tcl_SetResult(interp, ligne, TCL_VOLATILE);
                        result = TCL_ERROR;
                     }
                  }
               }
               if ( result == TCL_OK) {
                  // je memorise le nom du fichier
                  if ( cam->darkFileName != NULL ) {
                     free(cam->darkFileName);
                     cam->darkFileName = NULL;
                  }
                  cam->darkFileName = (char*) malloc(strlen(argv[2])+1);
                  strcpy(cam->darkFileName, argv[2]);
                  Tcl_SetResult(interp, (char*) "", TCL_VOLATILE);
               } else {
                  // je supprime le buffer
                  if ( cam->darkBufNo != 0 ) {
                     sprintf(ligne, "buf::delete %d", cam->darkBufNo);
                     Tcl_Eval(interp, ligne);
                     cam->darkBufNo = 0;
                  }
                  // je supprime le nom du fichier
                  if ( cam->darkFileName != NULL ) {
                     free(cam->darkFileName);
                     cam->darkFileName = NULL;
                  }

               }
            }
         }
      }
   }
   return result;
}

int cmdCamAvailable(struct camprop *cam, Tcl_Interp * interp, int argc, const char *argv[])
{
#ifdef CMD_CAM_AVAILABLE
   int result;
   // cette commande n'est utilisable que par les cameras qui
   // sont compilés avec l'option CMD_CAM_AVAILABLE
   char * ligne = NULL;
   // ligne is allocated by cam_getAvailableCameraList()
  if( webcam_getAvailableCameraList(&ligne) == 0 ) {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_OK;
   } else {
      // la variable "ligne" contient le message d'erreur
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }
   free(ligne);
   return result;
#else
   Tcl_SetResult(interp, (char*) "command \"available\" not implemented for this camera", TCL_VOLATILE);
   return TCL_ERROR;
#endif
}

