/* camera.c
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
#define strdup _strdup
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <stdio.h>
#include "math.h"

#include "camera.h"
#include <libcam/util.h>


/* ATTENTION : Seul le binning numerique est applique */

/*
*  Definition of different cameras supported by this driver
*  (see declaration in libstruc.h)
*/

struct camini CAM_INI[] = {
   {
      "CM2-1",		/* camera name */
         "fingerlakes",	/* camera product */
         "Marconi 47-10",		/* ccd name */
         1056, 1027,		/* maxx maxy */// 1056 x 1027 !! l'overscan est integre ici
         8, 0,			/* overscans x */
         0, 0,			/* overscans y */
         13e-6, 13e-6,		/* photosite dim (m) */
         65535,			/* observed saturation */
         1.,			/* filling factor */
         11.,			/* gain (e/adu) */
         11.,			/* readnoise (e) */
         1, 1,			/* default bin x,y */
         1.,			/* default exptime */
         1,				/* default state of shutter (1=synchro) */
         0,				/* default port index (0=lpt1) */
         1,				/* default cooler index (1=on) */
         -15.,			/* default value for temperature checked */
         1,				/* default color mask if exists (1=cfa) */
         0,				/* default overscan taken in acquisition (0=no) */
         1.				/* default focal lenght of front optic system */
   },
   {
         "MicroLine 1603",		/* camera name */
            "fingerlakes",	/* camera product */
            "KAF-1603",		/* ccd name */
            1536, 1024,		/* maxx maxy */// 1056 x 1027 !! l'overscan est integre ici
            14, 0,			/* overscans x */
            4, 0,			/* overscans y */
            9e-6, 9e-6,		/* photosite dim (m) */
            32767,			/* observed saturation */
            1.,			/* filling factor */
            11.,			/* gain (e/adu) */
            11.,			/* readnoise (e) */
            1, 1,			/* default bin x,y */
            1.,			/* default exptime */
            1,				/* default state of f (1=synchro) */
            0,				/* default port index (0=lpt1) */
            1,				/* default cooler index (1=on) */
            -15.,			/* default value for temperature checked */
            1,				/* default color mask if exists (1=cfa) */
            0,				/* default overscan taken in acquisition (0=no) */
            1.				/* default focal lenght of front optic system */
      },
	  {
         "CCD 42-40",		/* camera name */
            "fingerlakes",	/* camera product */
            "Marconi 42-40",	/* ccd name */
            2097, 2047,		/* maxx maxy */// 1056 x 1027 !! l'overscan est integre ici
            2, 0,			/* overscans x */
            2, 0,			/* overscans y */
            9e-6, 9e-6,		/* photosite dim (m) */
            52685,			/* observed saturation */
            1.,			/* filling factor */
            2.69,			/* gain (e/adu) */
            14.74,			/* readnoise (e) */
            1, 1,			/* default bin x,y */
            1.,			/* default exptime */
            1,				/* default state of f (1=synchro) */
            0,				/* default port index (0=lpt1) */
            1,				/* default cooler index (1=on) */
            -20.,			/* default value for temperature checked */
            1,				/* default color mask if exists (1=cfa) */
            0,				/* default overscan taken in acquisition (0=no) */
            1.				/* default focal lenght of front optic system */
      }
};

static int cam_init(struct camprop *cam, int argc, const char **argv);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
   cam_init,
      NULL,
      cam_set_binning,
      cam_update_window,
      cam_start_exp,
      cam_stop_exp,
      cam_read_ccd,
      cam_shutter_on,
      cam_shutter_off,
      NULL,
      NULL,
      cam_measure_temperature,
      cam_cooler_on,
      cam_cooler_off,
      cam_cooler_check
};

/*
*  Definition a structure specific for this driver 
*  (see declaration in camera.h)
*/

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int flilogactivated = 0; // initial value was 0

flidebug_t flidebuglevel = FLIDEBUG_NONE; // initial value was FLIDEBUG_NONE

static void logfile(char *s)
{
   FILE *f;
   if ( ! flilogactivated )
      return;
   f = fopen("fingerlakes.txt", "at");
   fprintf(f, "%s", s);
   printf("%s",s);
   fclose(f);
}

int cam_init(struct camprop *cam, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
{
   int err, i, k;
   char **camlist, *fliname, *semicolon;
   char s[100], t[100], headref[6];
   long hwrev, fwrev;
   double pixsizex, pixsizey;
   long a, b, c, d;
   long aa, bb, cc, dd;
   
   
   for (i = 0 ; i < argc ; i++ ) {
      if ( ! strcmp(argv[i], "-flidebug" ) ) {
         if ( ! strcmp(argv[i+1], "none") ) {
            flidebuglevel = FLIDEBUG_NONE;
            flilogactivated = 0;
         } else if ( ! strcmp(argv[i+1], "info") ) {
            flidebuglevel = FLIDEBUG_INFO;
            flilogactivated = 1;
         } else if ( ! strcmp(argv[i+1], "warn") ) {
            flidebuglevel = FLIDEBUG_WARN;
            flilogactivated = 1;
         } else if ( ! strcmp(argv[i+1], "fail") ) {
            flidebuglevel = FLIDEBUG_FAIL;
            flilogactivated = 1;
         } else if ( ! strcmp(argv[i+1], "all") ) {
            flidebuglevel = FLIDEBUG_ALL;
            flilogactivated = 1;
         }
         if ( ( err = FLISetDebugLevel(NULL,flidebuglevel) ) ) {
            sprintf(s,"cam_init: can't set debug mode to %s, %s\n",argv[i+1],strerror((int)-err));
            logfile(s);
            return -1;
         }
      }
   }
   
   flilogactivated = 0;
   //flidebuglevel = FLIDEBUG_INFO;
   
   logfile("***\n");
   logfile("CAM_INIT: entree\n");
   for(i=0;i<argc;i++) {
      sprintf(s,"cam_init: argv[%d]=%s\n", i, argv[i]);
      logfile(s);
   }
   
   // Version du driver FLI
   if ((err = FLIGetLibVersion(t, 100))) {
      logfile("cam_init: erreur dans FLIGetLibVersion\n");
      return -1;
   }
   sprintf(s, "cam_init: driver FLI \"%s\"\n", t);
   logfile(s);
   
   sprintf(s, "camlist=%p\t, &camlist=%p\n",camlist,&camlist);
   logfile(s);
   camlist = NULL;
   
   // Recupere la liste des cameras disponibles sur le systeme
   if ((err = FLIList(FLIDOMAIN_USB | FLIDEVICE_CAMERA, &camlist))) {
      logfile("cam_init: erreur dans FLIList\n");
      return -1;
   }
   
   sprintf(s, "cam_init: camlist = %p\n", camlist);
   logfile(s);
   cam->simulation = 1; 
   
   // Extraction du nom de la premiere camera
   if (!camlist || !camlist[0]) {
      logfile("cam_init: pas de camera disponible\n");
	  /* modif pour simuler la camera. Remove du return error.
      return -1;
	  Now, insert by hand all values */

      cam->device=NULL;
	  cam->simulation=0;
	  // Modele de camera
      strcpy(t,"Simucam");
      strcpy(CAM_INI[cam->index_cam].name,"Simucam");
      strcpy(CAM_INI[cam->index_cam].ccd,"Unknown");
   
       // taille des pixels
       pixsizex=9;
	   pixsizey=9;
	   CAM_INI[cam->index_cam].celldimx=(double)(pixsizex)*1e-6;
       CAM_INI[cam->index_cam].celldimy=(double)(pixsizey)*1e-6;
       cam->celldimx = CAM_INI[cam->index_cam].celldimx;    // taille d'un photosite sur X (en metre) 
       cam->celldimy = CAM_INI[cam->index_cam].celldimy;    // taille d'un photosite sur Y (en metre) 
   
       hwrev=0;
       fwrev=0;
   
    // Recuperation de la taille de la matrice
       a=0;
	   b=0;
	   c=2096;
	   d=2048;
   
   // Recuperation de la partie sensible de la matrice
       aa=50;
	   bb=0;
	   cc=2046;
	   dd=2048;
      
   } else {
   for (i = 0; camlist[i] != NULL; i++) {
      sprintf(s, "cam_init: camlist[%d] = %p = \"%s\"\n", i, camlist[i],
         camlist[i] == NULL ? "" : camlist[i]);
      logfile(s);
   }
   fliname = strdup(camlist[0]);
   semicolon = strchr(fliname, ';');
   if (semicolon) {
      *semicolon = '\0';
   }
   if ((err = FLIFreeList(camlist))) {
      logfile
         ("cam_init: impossible de liberer camlist par FLIFreeList\n");
      return -1;
   }
   // Ouverture de la camera
   if ((err =
      FLIOpen(&cam->device, fliname,
      FLIDOMAIN_USB | FLIDEVICE_CAMERA))) {
      logfile
         ("cam_init: impossible de se connecter a la camera par FLIOpen\n");
      return -1;
   }
   // Modele de camera
   if ((err = FLIGetModel(cam->device, t, 100))) {
      logfile("cam_init: erreur dans FLIGetModel\n");
      return -1;
   }
   sprintf(s, "cam_init: model = \"%s\"\n", t);
   logfile(s);
   
   /* rajout Myrtille pour faire marcher la FLI MicroLine 1603 */
   
   strcpy(CAM_INI[cam->index_cam].name,t);
   for (k=0;k<=4;k++) {
      headref[k]=CAM_INI[cam->index_cam].name[k];
   }
   headref[k]='\0';
   if (strcmp(headref,"Micro")==0) {
      strcpy(CAM_INI[cam->index_cam].ccd,"KAF-1603");
   } else if (strcmp(headref,"MC2-1")==0) {
      strcpy(CAM_INI[cam->index_cam].ccd,"Marconi 47-10");
   } else {
      strcpy(CAM_INI[cam->index_cam].ccd,"Unknown");
   }
   
   // taille des pixels
   pixsizex=pixsizey=0;
   if ((err = FLIGetPixelSize(cam->device, &pixsizex, &pixsizey))) {
      logfile("cam_init: erreur dans FLIGetPixelSize\n");
      return -1;
   }
   CAM_INI[cam->index_cam].celldimx=(double)(pixsizex);
   CAM_INI[cam->index_cam].celldimy=(double)(pixsizey);
   cam->celldimx = CAM_INI[cam->index_cam].celldimx;    // taille d'un photosite sur X (en metre) 
   cam->celldimy = CAM_INI[cam->index_cam].celldimy;    // taille d'un photosite sur Y (en metre) 
   /* fin rajout Myrtille */
   
   // Version du Hardware
   if ((err = FLIGetHWRevision(cam->device, &hwrev))) {
      logfile("cam_init: erreur dans FLIGetHWRevision\n");
      return -1;
   }
   sprintf(s, "cam_init: hwrev = \"%ld\"\n", hwrev);
   logfile(s);
   
   // Version du Firmware
   if ((err = FLIGetFWRevision(cam->device, &fwrev))) {
      logfile("cam_init: erreur dans FLIGetFWRevision\n");
      return -1;
   }
   sprintf(s, "cam_init: fwrev = \"%ld\"\n", fwrev);
   logfile(s);
   
   // Fermeture de l'obturateur
   if ((err = FLIControlShutter(cam->device, FLI_SHUTTER_CLOSE))) {
      logfile("cam_init: erreur a la fermeture du shutter\n");
      return -1;
   }
   logfile("cam_init: shutter ferme\n");
   
   // Recuperation de la taille de la matrice
   if ((err = FLIGetArrayArea(cam->device, &a, &b, &c, &d))) {
      logfile("cam_init: impossible de recuperer la array area\n");
      return -1;
   }
   sprintf(s, "cam_init: ArrayArea=(%ld,%ld)-(%ld,%ld)\n", a, b, c, d);
   logfile(s);
   
   // Recuperation de la partie sensible de la matrice
   if ((err = FLIGetVisibleArea(cam->device, &aa, &bb, &cc, &dd))) {
      logfile("cam_init: impossible de recuperer la visible area\n");
      return -1;
   }
   sprintf(s, "cam_init: VisibleArea=(%ld,%ld)-(%ld,%ld)\n", aa, bb, cc, dd);
   logfile(s);
   
   for(i=0;i<5;i++) { 
      if ((err = FLIGetCameraModeString(cam->device,i,s,100))) {
         sprintf(s,"cam_init: impossible de recuperer le mode %d\n",i);
         logfile(s);
         continue;
      } else {
         sprintf(t,"mode %d: %s\n",i,s);
         logfile(t);
      }
   }
   } // this end is for the simulation part 
   
   cam->overscanindex = 0; // Par defaut on n'acquiert pas les overscan
   cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg = aa - a;
   cam->nb_deadendphotox   = CAM_INI[cam->index_cam].overscanxend = c - cc;
   cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg = bb - b;
   cam->nb_deadendphotoy   = CAM_INI[cam->index_cam].overscanyend = d - dd;
   cam->nb_photox          = CAM_INI[cam->index_cam].maxx = cc - aa;
   cam->nb_photoy          = CAM_INI[cam->index_cam].maxy = dd - bb;
   sprintf(s,"cam_init: oxbeg=%d, oybeg=%d, oxend=%d, oyend=%d\n",
      CAM_INI[cam->index_cam].overscanxbeg, CAM_INI[cam->index_cam].overscanybeg,
      CAM_INI[cam->index_cam].overscanxend, CAM_INI[cam->index_cam].overscanyend);
   logfile(s);
   sprintf(s,"cam_init: maxx=%d, maxy=%d\n",
      CAM_INI[cam->index_cam].maxx, CAM_INI[cam->index_cam].maxy);
   logfile(s);	
   
   // Nombre de vidages de la matrice avant exposition
   fingerlakes_nbflushes(cam, 5);
   
   cam->x1 = 0;
   cam->y1 = 0;
   cam->x2 = CAM_INI[cam->index_cam].maxx - 1;
   cam->y2 = CAM_INI[cam->index_cam].maxy - 1;
   cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
   
   cam->interrupt = 0;
   
   cam->authorized = 1;
   cam->pendingStop = 0;
   
   return 0;
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy;
   int x1, y1, x2, y2;
   int x1Mir, y1Mir, x2Mir, y2Mir;
   int err;
   char s[100];
   
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   
   if (cam->x1 > cam->x2)
      libcam_swap(&(cam->x1), &(cam->x2));
   if (cam->x1 < 0)
      cam->x1 = 0;
   if (cam->x2 > maxx - 1)
      cam->x2 = maxx - 1;
   
   if (cam->y1 > cam->y2)
      libcam_swap(&(cam->y1), &(cam->y2));
   if (cam->y1 < 0)
      cam->y1 = 0;
   if (cam->y2 > maxy - 1)
      cam->y2 = maxy - 1;
   
   sprintf(s, "CAM_UPDATE_WINDOW: requested window = (%d,%d)-(%d,%d)\n", cam->x1,
      cam->y1, cam->x2, cam->y2);
   logfile(s);
   
   cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;
   
   sprintf(s, "cam_update_window: (%d,%d)-(%d,%d) / size=(%d,%d)\n", cam->x1,
      cam->y1, cam->x2, cam->y2, cam->w, cam->h);
   logfile(s);
   

   if ( cam->mirrorv == 1 ) {
      // j'applique un miroir vertical en inversant les ordonnees de la fenetre
      x1Mir = maxx -1 - cam->x2; 
      x2Mir = maxx -1 - cam->x1; 
   } else {
      x1Mir = cam->x1; 
      x2Mir = cam->x2; 
   }

   if ( cam->mirrorh == 1 ) {
      // j'applique un miroir horizontal en inversant les abcisses de la fenetre
      // 0---y1-----y2---------------------(maxy/biny)
      // 0---------------(w-y2)---(w-y1)---(maxy/biny)  
      y1Mir = maxy -1 - cam->y2;
      y2Mir = maxy -1 - cam->y1;
   } else {
      y1Mir = cam->y1; 
      y2Mir = cam->y2; 
   }

   // On ajoute cam->overscanxbeg pour les coordonnees en x car le
   // driver FLI n'accepte pas de coordonnees hors de la zone "visible area"
   x1 = cam->nb_deadbeginphotox + x1Mir;
   y1 = cam->nb_deadbeginphotoy + y1Mir;
   x2 = cam->nb_deadbeginphotox + x1Mir + cam->w;
   y2 = cam->nb_deadbeginphotoy + y1Mir + cam->h;
   

   sprintf(s,
      "cam_update_window: configuration avec (%d,%d)-(%d,%d) -> (%d,%d)-(%d,%d)\n",
      cam->x1, cam->y1, cam->x2, cam->y2, x1, y1, x2, y2);
   logfile(s);
   if ((err = FLISetImageArea(cam->device, x1, y1, x2, y2))) {
      logfile("cam_update_window: impossible de configurer la zone image\n");
      return;
   }
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
   char s[100];
   int err;
   int time;

   // je re-initilise l'indicateur de demande d'arret  qui sera utilisé dans cam_read_ccd
   cam->pendingStop = 0;
   
   if (cam->authorized == 1) {
   /*
   if ((err = FLIControlShutter(cam->device, FLI_SHUTTER_CLOSE))) {
   logfile("cam_start_exp: erreur a la fermeture du shutter\n");
   return;
   }
   logfile("cam_start_exp: shutter ferme\n");
      */
      time = (int) (1000 * cam->exptime);
      if ((err = FLISetExposureTime(cam->device, time))) {
         logfile
            ("cam_start_exp: impossible de programmer le temps d'exposition\n");
         if (cam->simulation) return;
      }
      sprintf(s,
         "cam_start_exp: programmation du temps d'integration (%d ms)\n",
         time);
      logfile(s);
      
      //if (err=FLIFlushRow(cam->device,CAM_INI[cam->index_cam].maxy,1)) {
      //   logfile("cam_start_exp: impossible de declencher le vidage\n");
      //   return;
      //}
      //logfile("cam_start_exp: ccd nettoye\n");
      
      if ((err = FLIExposeFrame(cam->device))) {
         logfile("cam_start_exp: refus de demarrer la pose\n");
         if (cam->simulation) return;
      }
      logfile("cam_start_exp: demarrage de la pose\n");
   }
}

void cam_stop_exp(struct camprop *cam)
{
   int err;

   // je positionne l'indicateur de demande d'arret qui sera utilisé dans cam_read_ccd
   cam->pendingStop = 1;

   if (cam->authorized == 1) {
      // ca fait planter la lecture
      if ((err = FLICancelExposure(cam->device))) {
         logfile("cam_stop_exp: refus d'arreter la pose\n");
         if (cam->simulation) return;
      }
      logfile("cam_stop_exp: pose arretee\n");
   }
}

void cam_read_ccd(struct camprop *cam, float *p)
{
   long timeleft;
 
   
   if (p == NULL)
      return;
   if (cam->authorized == 1) {
      
      if (cam->pendingStop == 0 ) {
         // Si l'acquisition n'est pas interrompue par l'utilsateur 
         // je verifie la synchronisation avec l'obturateur
         timeleft = 100;
         while (timeleft !=  0) {
            FLIGetExposureStatus(cam->device, &timeleft);
            if (!cam->simulation) timeleft = 0;
            logfile("cam_read_ccd: attente de synchro obturateur\n");
         }
      } else {
         // Si l'acquisition est interrompue par l'utilsateur
         // je ne verifie pas la synchonisation avec l'obturateur
         // et je lis immediatement l'image

         // reinitilisation de l'indicateur d'interruption
         cam->pendingStop = 0;
      }
      
      /* Lecture de l'image */
      unsigned short *rowBuf = (unsigned short*) malloc( cam->w * sizeof(unsigned short));
      if ( rowBuf == NULL) {
         sprintf(cam->msg,"cam_read_ccd rowBuf=NULL");
         return;
      }

      for (int row = 0; row < cam->h; row++) {
         if (cam->simulation) FLIGrabRow(cam->device, rowBuf, cam->w);
		 else for (int pixel = 0; pixel < cam->w; pixel++) rowBuf[pixel] = 10;
		 //FLIGrabRow(cam->device, &p[row*cam->w], cam->w);
         // je copie la ligne dans le buffer de sortie
         for(int col = 0 ; col < cam->w; col++) {
            p[row * cam->w +col] = (float) rowBuf[col];
         }
      }
      logfile("cam_read_ccd: fin de lecture du ccd\n");
      
      /* Remise a l'heure de l'horloge de Windows */
      if (cam->interrupt == 1) {
         update_clock();
         logfile("cam_read_ccd: update_clock\n");
      }
   }
}

void cam_shutter_on(struct camprop *cam)
{
   int err;
   
   if ((err = FLIControlShutter(cam->device, FLI_SHUTTER_OPEN))) {
      logfile("cam_shutter_on: erreur a la configuration\n");
      if (cam->simulation) return;
   }
   logfile("cam_shutter_on: shutter en mode ON\n");
}

void cam_shutter_off(struct camprop *cam)
{
   int err;
   
   if ((err = FLIControlShutter(cam->device, FLI_SHUTTER_CLOSE))) {
      logfile("cam_shutter_off: erreur a la fermeture du shutter\n");
      if (cam->simulation) return;
   }
   logfile("cam_shutter_off: shutter ferme\n");
   
   if (cam->shutterindex == 1) {
      // Mode synchro
      if ((err = FLISetFrameType(cam->device, FLI_FRAME_TYPE_NORMAL))) {
         logfile
            ("cam_shutter_off: erreur a la configuration de frame type (synchro)\n");
         if (cam->simulation) return;
      }
      logfile("cam_shutter_off: shutter bascule en mode synchro\n");
   } else {
      if ((err = FLISetFrameType(cam->device, FLI_FRAME_TYPE_DARK))) {
         logfile
            ("cam_shutter_off: erreur a la configuration de frame type (closed)\n");
         if (cam->simulation) return;
      }
      logfile("cam_shutter_off: shutter bascule en mode closed\n");
   }
   logfile("cam_shutter_off: fin configuration shutter\n");
   
}

void cam_measure_temperature(struct camprop *cam)
{
   double temp;
   char s[100];
   int err;
   
   if ((err = FLIGetTemperature(cam->device, &temp))) {
      logfile
         ("cam_measure_temperature: impossible de lire la temperature\n");
      if (cam->simulation) return;
   }
   cam->temperature = temp;
   sprintf(s, "cam_measure_temperature: temperature lue (%f)\n", temp);
   logfile(s);
}

#ifndef min
#define min(a,b) (((a)<(b))?(a):(b))
#endif

#ifndef max
#define max(a,b) (((a)>(b))?(a):(b))
#endif

void cam_cooler_on(struct camprop *cam)
{
   double temp;
   char s[100];
   int err;
   
   temp = min(max(cam->check_temperature, -55.0), 45.0);
   if ((err = FLISetTemperature(cam->device, temp))) {
      sprintf(s,
         "cam_cooler_on: impossible de programmer la temperature %f\n",
         temp);
      logfile(s);
      return;
   }
}

void cam_cooler_off(struct camprop *cam)
{
}

void cam_cooler_check(struct camprop *cam)
{
   double temp;
   char s[100];
   int err;
   
   temp = min(max(cam->check_temperature, -55.0), 45.0);
   if ((err = FLISetTemperature(cam->device, temp))) {
      sprintf(s,
         "cam_cooler_on: impossible de programmer la temperature %f\n",
         temp);
      logfile(s);
      return;
   }
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
   char s[100];
   int err;
   
   if (binx <= 1) {
      binx = 1;
   }
   if (binx >= 16) {
      binx = 16;
   }
   if (biny <= 1) {
      biny = 1;
   }
   if (biny >= 16) {
      biny = 16;
   }
   cam->binx = binx;
   cam->biny = biny;
   
   if ((err = FLISetHBin(cam->device, binx))) {
      logfile
         ("cam_set_binning: impossible de configurer le binning horizontal\n");
      return;
   }
   sprintf(s, "cam_set_binning: hbin <= %d\n", binx);
   logfile(s);
   
   if ((err = FLISetVBin(cam->device, biny))) {
      logfile
         ("cam_set_binning: impossible de configurer le binning vertical\n");
      return;
   }
   sprintf(s, "cam_set_binning: vbin <= %d\n", biny);
   logfile(s);
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */


/*
CAudine::read_line(int width, int offset, int bin, short *buf) --
Lecture d'une ligne du CCD en mode drift scan avec un positionnement
possible en abscisse.
- width : largeur de la bande
- offset : position du premier pixel en x (commence a 1)
- bin : facteur de binning (identique en x et y)
- buf : buffer de stockage de la ligne
*/
int
fingerlakes_read_line(struct camprop *cam, int width, int offset, int bin,
                      unsigned short *buf)
{
   int err;
   
   if ((err = FLIGrabRow(cam->device, buf, cam->w))) {
      logfile("read_line: impossible de lire la ligne\n");
   }
   
   return 0;
}


int fingerlakes_nbflushes(struct camprop *cam, int nb)
// Nombre de vidages de la matrice avant exposition
{
   char s[100];
   int err;
   
   // nb sera limite etre 0 et 10
   nb = max(min(nb, 10), 0);
   cam->nb_flushes = nb;
   
   if ((err = FLISetNFlushes(cam->device, nb))) {
      sprintf(s,
         "nbflushes: erreur pour la programmation de %d vidages avant exposition\n",
         nb);
      logfile(s);
      return -1;
   }
   sprintf(s, "nbflushes: %d vidages avant exposition\n", nb);
   logfile(s);
   
   return 0;
}
int fingerlakes_cooler_power(struct camprop *cam, double *power)
{
   char s[100];
   int err;
   
   if ((err=FLIGetCoolerPower(cam->device,power))) {
      logfile("coolerpower: error");
      return -1;
   }
   sprintf(s,"coolerpower: %lf\n",*power);
   
   return 0;
}

//----------------------------------------------------------------------------
// retourne la temperature de la face froide du peltier (interne), de la face chaude du peltier (externe) 
//  et la puissance du peltier en pourcent
//
// @return 0=OK , 1=error
//----------------------------------------------------------------------------
int fingerlakes_getTempPower(struct camprop *cam, double *internalTemp, double *externalTemp, double *coolerPower)
{
   char s[1024];
   int err;
   
   if ((err = FLIReadTemperature(cam->device, FLI_TEMPERATURE_INTERNAL, internalTemp))) {
      sprintf(cam->msg,"cam_measure_temperature: erreur FLIReadTemperature INTERNAL");
      logfile
         ("cam_measure_temperature: erreur FLIReadTemperature INTERNAL\n");
      return 1;
   }
   if ((err = FLIReadTemperature(cam->device, FLI_TEMPERATURE_EXTERNAL, externalTemp))) {
      sprintf(cam->msg,"cam_measure_temperature: erreur FLIReadTemperature EXTERNAL");
      logfile("cam_measure_temperature: erreur FLIReadTemperature EXTERNAL\n");
      return 1;
   }
   
   if ((err = FLIGetCoolerPower(cam->device, coolerPower))) {
      sprintf(cam->msg,"cam_measure_temperature: erreur FLIGetCoolerPower EXTERNAL");
      logfile
         ("cam_measure_temperature: erreur FLIGetCoolerPower EXTERNAL\n");
      return 1;
   }
   sprintf(s, "fingerlakes_getTempPower: temperature lue Tint=(%f) / Text(%f) p=(%f)\n", *internalTemp, *externalTemp, *coolerPower);
   logfile(s);
   return 0;
}




