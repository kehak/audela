
/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 * Initial author : Frederic VACHIER <fv@imcce.fr>
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

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <math.h>

#include "camera.h"
#include <libcam/util.h>

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
   {"IKON-L, DZ936N-#BV",       /* camera name */
    "andorusb",                 /* camera product */
    "Marconi 47-41",            /* ccd name */
    2048, 2048,                   /* maxx maxy */
    0, 0,                       /* overscans x */
    0, 0,                       /* overscans y */
    9e-6, 9e-6,                 /* photosite dim (m) */
    65535.,                     /* observed saturation */
    1.,                         /* filling factor */
    11.,                        /* gain (e/adu) */
    11.,                        /* readnoise (e) */
    1, 1,                       /* default bin x,y */
    1.,                         /* default exptime */
    1,                          /* default state of shutter (1=synchro) */
    0,                          /* default port index (0=lpt1) */
    1,                          /* default cooler index (1=on) */
    -20.,                       /* default value for temperature checked */
    1,                          /* default color mask if exists (1=cfa) */
    0,                          /* default overscan taken in acquisition (0=no) */
    1.                          /* default focal lenght of front optic system */
    },
   CAM_INI_NULL
};

static int cam_init(struct camprop *cam, int argc, char **argv);
static int cam_close(struct camprop *cam);
static void cam_start_exp(struct camprop *cam, char *amplionoff);
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
   cam_init,                    /* init */
   cam_close,                   /* close */
   cam_set_binning,             /* set_binning */
   cam_update_window,           /* update_window */
   cam_start_exp,               /* start_exp */
   cam_stop_exp,                /* stop_exp */
   cam_read_ccd,                /* read_ccd */
   cam_shutter_on,              /* shutter_on */
   cam_shutter_off,             /* shutter_off */
   NULL,                        /* ampli_on */
   NULL,                        /* ampli_off */
   cam_measure_temperature,     /* measure_temperature */
   cam_cooler_on,               /* cooler_on */
   cam_cooler_off,              /* cooler_off */
   cam_cooler_check             /* cooler_check */
};

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */

int cam_init(struct camprop *cam, int argc, char **argv)
{
   int width, height;
   unsigned int PCB, Flex, dummy1, dummy2, dummy3, dummy4;
   unsigned int eprom, cofFile, vxdRev, vxdVer, dllRev, dllVer;
   int minTemp, maxTemp, temperature, k;
   char aBuffer[256], model[256];
   float pixsizex, pixsizey;

   strcpy(aBuffer, ".");
   if(argc >= 7)
   {
      strcpy(aBuffer, argv[6]);
   }

   /* --- Open Driver --- */
   cam->drv_status = Initialize(aBuffer);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 3;
   }


   /* --- Get Detector Info --- */
   cam->drv_status = GetDetector(&width, &height);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 4;
   }
   CAM_INI[cam->index_cam].maxx = width;
   CAM_INI[cam->index_cam].maxy = height;

   /* --- Get Hardware Info --- */
   cam->drv_status =
      GetHardwareVersion(&PCB, &Flex, &dummy1, &dummy2, &dummy3, &dummy4);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 5;
   }


   /* --- Get Software Info --- */
   cam->drv_status =
      GetSoftwareVersion(&eprom, &cofFile, &vxdRev, &vxdVer, &dllRev,
                         &dllVer);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 6;
   }

   /* --- Get Head Model --- */
   cam->drv_status = GetHeadModel(model);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 7;
   }
   cam->index_cam = 0;
   strcpy(CAM_INI[cam->index_cam].name, model);
   /* --- headref = 5 first letters of Model --- */
   for(k = 0; k <= 4; k++)
   {
      cam->headref[k] = model[k];
   }
   cam->headref[k] = '\0';
   if(strcmp(cam->headref, "DV436") == 0)
   {
      strcpy(CAM_INI[cam->index_cam].ccd, "Marconi 47-40");
   }
   else if(strcmp(cam->headref, "DU897") == 0)
   {
      strcpy(CAM_INI[cam->index_cam].ccd, "Marconi EMCCD");
   }
   else if(strcmp(cam->headref, "DU888") == 0)
   {
      strcpy(CAM_INI[cam->index_cam].ccd, "Marconi EMCCD");
   }
   else if(strcmp(cam->headref, "DZ936") == 0)
   {
      strcpy(CAM_INI[cam->index_cam].ccd, "Marconi");
   }
   else
   {
      strcpy(CAM_INI[cam->index_cam].ccd, "Unknown");
   }

   /* --- Get Temperature Range Info --- */
   cam->drv_status = GetTemperatureRange(&minTemp, &maxTemp);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 8;
   }
   cam->minTemp = minTemp;
   cam->maxTemp = maxTemp;

   /* --- Get Pixel size Info --- */
   cam->drv_status = GetPixelSize(&pixsizex, &pixsizey);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 8;
   }
   CAM_INI[cam->index_cam].celldimx = (double) (pixsizex) * 1e-6;
   CAM_INI[cam->index_cam].celldimy = (double) (pixsizey) * 1e-6;

   CAM_INI[cam->index_cam].overscanxbeg = 0;
   CAM_INI[cam->index_cam].overscanxend = 0;
   CAM_INI[cam->index_cam].overscanybeg = 0;
   CAM_INI[cam->index_cam].overscanyend = 0;

   /* --- preamp Gain --- */
   if(strcmp(cam->headref, "DV436") == 0)
   {
      CAM_INI[cam->index_cam].gain = (double) (2.0);    // 436
   }
   else if(strcmp(cam->headref, "DU897") == 0)
   {
      CAM_INI[cam->index_cam].gain = (double) (4.8);    // 888
   }
   else if(strcmp(cam->headref, "DU888") == 0)
   {
      CAM_INI[cam->index_cam].gain = (double) (4.8);    // 888
   }
   else if(strcmp(cam->headref, "DZ936") == 0)
   {
      CAM_INI[cam->index_cam].gain = (double) (4.8);    // 888
   }
   else
   {
      CAM_INI[cam->index_cam].gain = (double) (2.0);    // TODO
   }
   
   
   CAM_INI[cam->index_cam].maxconvert = pow(2, (double) 16) - 1.;
   cam->acqmode   = 1;
   cam->nbimages  = 1;
   cam->cycletime = 0.;
   strcpy(cam->spoolname, "andorusb");

   /* --- intialisation of elements of the structure cam === */
   cam->nb_photox = CAM_INI[cam->index_cam].maxx;       /* nombre de photosites sur X */
   cam->nb_photoy = CAM_INI[cam->index_cam].maxy;       /* nombre de photosites sur Y */
   if(cam->overscanindex == 0)
   {
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg;
      cam->nb_deadendphotox   = CAM_INI[cam->index_cam].overscanxend;
      cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg;
      cam->nb_deadendphotoy   = CAM_INI[cam->index_cam].overscanyend;
   }
   else
   {
      cam->nb_photox +=
         (CAM_INI[cam->index_cam].overscanxbeg +
          CAM_INI[cam->index_cam].overscanxend);
      cam->nb_photoy +=
         (CAM_INI[cam->index_cam].overscanybeg +
          CAM_INI[cam->index_cam].overscanyend);
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = 0;
      cam->nb_deadendphotox   = 0;
      cam->nb_deadbeginphotoy = 0;
      cam->nb_deadendphotoy   = 0;
   }

   cam->celldimx = CAM_INI[cam->index_cam].celldimx;    /* taille d'un photosite sur X (en metre) */
   cam->celldimy = CAM_INI[cam->index_cam].celldimy;    /* taille d'un photosite sur Y (en metre) */
   cam->x2 = cam->nb_photox - 1;
   cam->y2 = cam->nb_photoy - 1;
   cam_update_window(cam);      /* met a jour x1,y1,x2,y2,h,w dans cam */

   /* --- Get Temperature --- */
   cam->drv_status = GetTemperature(&temperature);
   cam->temperature = temperature;
   sprintf(cam->msg, "Status %d. %s", cam->drv_status,get_status(cam->drv_status));
   cam->coolerindex = 0;
   cam->check_temperature = temperature;

   /* --- shutter --- */
   cam->shutterindex = 1;
   cam->closingtime = 0;
   cam->openingtime = 30;

   /* --- electronic --- */
   cam->ADChannel   = 0;
   cam->PreAmpGain  = 2;
   cam->VSSpeed     = 0;
   cam->HSSpeed     = 2;
   cam->VSAmplitude = 0;
   cam->HSEMult     = 0;
   cam->EMCCDGain   = 1;


   if(strcmp(cam->headref, "DV436") == 0)
   {
      cam->VSSpeed = 0;         // 0=436
   }
   else if(strcmp(cam->headref, "DU897") == 0)
   {
      cam->VSSpeed = 1;         // 1=888
   }
   else if(strcmp(cam->headref, "DU888") == 0)
   {
      cam->VSSpeed = 1;         // 1=888
   }
   else if(strcmp(cam->headref, "DZ936") == 0)
   {
      cam->VSSpeed = 1;         // 1=888
   }

   /* --- setup electronic parameters --- */
   cam_setup_electronic(cam);
   // printf("cam init\n");

   return 0;
}

int cam_close(struct camprop *cam)
{
   cam->drv_status = ShutDown();
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return 1;
   }
   return 0;
   // printf("cam close\n");
}

void cam_start_exp(struct camprop *cam, char *amplionoff)
{
   float exptime, accumtime, kinetictime;
   int type = 1, mode = 0;
   exptime = cam->exptime;

   /* --- setup electronic parameters --- */
   // cam_setup_electronic(cam);
   /* --- setup exposure parameters --- */
   cam_setup_exposure(cam, &exptime, &accumtime, &kinetictime);
   /* --- shutter --- */
   if(cam->acqmode == 1)
   {
      if(cam->shutterindex == 0)
      {
         mode = 2;
      }
      else if(cam->shutterindex == 1)
      {
         mode = 0;
      }
      else if(cam->shutterindex == 2)
      {
         mode = 1;
      }
   }
   else
   {
      if(cam->shutterindex == 0)
      {
         mode = 2;
      }
      else if(cam->shutterindex == 1)
      {
         mode = 1;
      }
      else if(cam->shutterindex == 2)
      {
         mode = 1;
      }
   }
   cam->drv_status = SetShutter(type, mode, cam->closingtime, cam->openingtime);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }
   /* --- acquisition --- */
   if(cam->acqmode == 3)
   {
      cam->drv_status = SetSpool((int) 1, (int) 0, cam->spoolname, (int) 10);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
   }
   else
   {
      cam->drv_status = SetSpool((int) 0, (int) 0, cam->spoolname, (int) 10);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
   }
   cam->drv_status = StartAcquisition();
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }
   printf("Start exposure : %f sec ",exptime);
}

void cam_stop_exp(struct camprop *cam)
{
   int type = 1, mode = 2;
   AbortAcquisition();
   /* --- shutter --- */
   if(cam->acqmode != 1)
   {
      if(cam->shutterindex == 0)
      {
         mode = 2;
      }
      else if(cam->shutterindex == 1)
      {
         mode = 2;
      }
      else if(cam->shutterindex == 2)
      {
         mode = 1;
      }
   }
   SetShutter(type, mode, cam->closingtime, cam->openingtime);
   // printf("stop expo\n");
   return;
}





void cam_read_ccd(struct camprop *cam, float *p)
{
   int h, w, status, sortie;
   //int type = 1;
   //int mode = 2;
   float *pix;
   unsigned short *pixshort;
   long size;
   int k;

   // printf("CAMREAD CCD\n");

   if(p == NULL)
      return;

   h = cam->h;
   w = cam->w;

   printf("h=%d w=%d\n",h,w);

   pix = (float *) p;

   /* --- boucle d'attente --- */
   sortie = 0;
   do
   {
      GetStatus(&status);
      if(status != DRV_ACQUIRING)
      {
         sortie = 1;
      }
   }
   while(sortie == 0);

   // printf("FIN Acquisition\n");


   /* --- importation de l'image --- */
      size = (long) (w) * (long) (h);
      
      pixshort = (unsigned short *) malloc(size * sizeof(unsigned short));
      
      cam->drv_status = GetAcquiredData16(pixshort, size);
      // printf("GETACQUIREDDATA FINI : drv_status=%d size=%ld\n",cam->drv_status,size);

      for (k = 0; k < size; k++)
      {
         pix[k] = (float) pixshort[k];
      }
      free(pixshort);

      if(cam->drv_status != DRV_SUCCESS)
      {
         if(cam->drv_status == DRV_NO_NEW_DATA)
         {
            printf("DRV_NO_NEW_DATA");
            for(k = 0; k < size; k++)
            {
               pix[k] = 0.0;
            }
         }
         else
         {
            sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                    get_status(cam->drv_status));
            return;
         }
      }

   printf("READacq FINI %d . %s\n", cam->drv_status, get_status(cam->drv_status));
   return;
}

void cam_shutter_on(struct camprop *cam)
{
   // printf("cam_shutter_on : ");
   int type = 1, mode = 1;
   /* --- --- */
   cam->drv_status =
      SetShutter(type, mode, cam->closingtime, cam->openingtime);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      printf("erreur %d. %s\n",cam->drv_status,get_status(cam->drv_status));
      return;
   }
   // printf("ok\n");
   return;
}

void cam_shutter_off(struct camprop *cam)
{
   // printf("cam_shutter_off : ");
   int type = 1, mode = 2;
   /* --- --- */
   cam->drv_status =
      SetShutter(type, mode, cam->closingtime, cam->openingtime);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      printf("erreur %d. %s\n",cam->drv_status,get_status(cam->drv_status));
      return;
   }
   // printf("ok\n");
   return;
}

void cam_measure_temperature(struct camprop *cam)
{
   return;
   int temperature;
   cam->drv_status = GetTemperature(&temperature);
   cam->temperature = temperature;
   sprintf(cam->msg, "Status %d. %s", cam->drv_status,get_status(cam->drv_status));
   printf("cam_measure_temperature %d. %s\n",cam->drv_status,get_status(cam->drv_status));
   return;
}

void cam_cooler_on(struct camprop *cam)
{
   // printf("cam_cooler_on : ");
   cam->drv_status = CoolerON();
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      printf("erreur %d. %s\n",cam->drv_status,get_status(cam->drv_status));
      return;
   }
   // printf("ok\n");
   return;
}

void cam_cooler_off(struct camprop *cam)
{
   // printf("cam_cooler_off : ");
   cam->drv_status = CoolerOFF();
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      printf("erreur %d. %s\n",cam->drv_status,get_status(cam->drv_status));
      return;
   }
   // printf("ok\n");
   return;
}

void cam_cooler_check(struct camprop *cam)
{
   // printf("cam_cooler_check : ");
   /* ---  --- */
   if(cam->check_temperature <= cam->minTemp)
   {
      cam->check_temperature = cam->minTemp;
   }
   if(cam->check_temperature >= cam->maxTemp)
   {
      cam->check_temperature = cam->maxTemp;
   }
   cam->drv_status = SetTemperature((int) cam->check_temperature);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      printf("erreur %d. %s\n",cam->drv_status,get_status(cam->drv_status));
      return;
   }
   // printf("ok\n");
   return;
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
   if(binx < 1)
   {
      binx = 1;
   }
   if(biny < 1)
   {
      biny = 1;
   }
   if(binx > 255)
   {
      binx = 255;
   }
   if(biny > 255)
   {
      biny = 255;
   }
   cam->binx = (int) fabs(binx);
   cam->biny = (int) fabs(biny);
   return;
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   if(cam->x1 > cam->x2)
      libcam_swap(&(cam->x1), &(cam->x2));
   if(cam->x1 < 0)
      cam->x1 = 0;
   if(cam->x2 > maxx - 1)
      cam->x2 = maxx - 1;

   if(cam->y1 > cam->y2)
      libcam_swap(&(cam->y1), &(cam->y2));
   if(cam->y1 < 0)
      cam->y1 = 0;
   if(cam->y2 > maxy - 1)
      cam->y2 = maxy - 1;

   cam->w = (cam->x2 - cam->x1 + 1) / cam->binx;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = (cam->y2 - cam->y1 + 1) / cam->biny;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}

/* ================================================================ */

/* ================================================================ */

/* ===     Fonctions de base pour le pilotage de la camera      === */

/* ================================================================ */

/* ================================================================ */

/* Ces fonctions sont tres specifiques a chaque camera.             */

/* ================================================================ */

void cam_setup_electronic(struct camprop *cam)
{
   SetADChannel(cam->ADChannel);
   SetPreAmpGain(cam->PreAmpGain);
   SetVSSpeed(cam->VSSpeed);
   SetHSSpeed(cam->HSEMult, cam->HSSpeed);
   SetVSAmplitude(cam->VSAmplitude);
   if((cam->EMCCDGain > 1) && (cam->HSEMult == 1))
   {
      SetOutputAmplifier(0);    /* 1=CCD 0=EMCCD */
      SetEMCCDGain(cam->EMCCDGain);
   }
   else
   {
      SetOutputAmplifier(1);    /* 1=CCD 0=EMCCD */
   }
}

void cam_setup_exposure(struct camprop *cam, float *texptime, float *taccumtime, float *tkinetictime)
{
   float exptime, accumtime, kinetictime;
   //int type = 1;
   //int mode = 0;
   int x1, y1, binx, biny, x2, y2;
   exptime = cam->exptime;

   *texptime     = cam->exptime;
   *taccumtime   = cam->cycletime;
   *tkinetictime = cam->cycletime;

   /* --- acquisition mode  --- */
   cam->drv_status = SetAcquisitionMode(cam->acqmode);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }

   /* --- exptime --- */
   exptime = (float) cam->exptime;
   cam->drv_status = SetExposureTime(exptime);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }




   if(cam->acqmode == 2)
   {
      cam->drv_status = SetKineticCycleTime(cam->exptime);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
      cam->drv_status = SetNumberKinetics(1);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
      cam->drv_status = SetAccumulationCycleTime(cam->cycletime);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
      cam->drv_status = SetNumberAccumulations(cam->nbimages);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
   }
   else if(cam->acqmode == 3)
   {
      cam->drv_status = SetKineticCycleTime(cam->cycletime);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
      cam->drv_status = SetNumberKinetics(cam->nbimages);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
      cam->drv_status = SetAccumulationCycleTime(cam->cycletime);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
      cam->drv_status = SetNumberAccumulations(1);
      if(cam->drv_status != DRV_SUCCESS)
      {
         sprintf(cam->msg, "Error %d. %s", cam->drv_status,
                 get_status(cam->drv_status));
         return;
      }
   }
   /* --- read mode  --- */
   cam->drv_status = SetReadMode(4);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }
   /* --- trigger mode  --- */
   cam->drv_status = SetTriggerMode(0);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }
   /* --- binning & window --- */
   x1 = cam->x1 + 1;
   y1 = cam->y1 + 1;
   x2 = cam->x2 + 1;
   y2 = cam->y2 + 1;
   binx = cam->binx;
   biny = cam->biny;
   if(cam->mirrorv == 1)
   {
      int tmp;
      x1 = cam->nb_photox - (x1 - 1);
      tmp = cam->nb_photox - (x2 - 1);
      x2 = x1;
      x1 = tmp;
   }
   if(cam->mirrorh == 1)
   {
      int tmp;
      y1 = cam->nb_photoy - (y1 - 1);
      tmp = cam->nb_photoy - (y2 - 1);
      y2 = y1;
      y1 = tmp;
   }
   cam->drv_status = SetImage(binx, biny, x1, x2, y1, y2);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }
   /* --- verif des temps de pose --- */
   cam->drv_status = GetAcquisitionTimings(&exptime, &accumtime, &kinetictime);
   if(cam->drv_status != DRV_SUCCESS)
   {
      sprintf(cam->msg, "Error %d. %s", cam->drv_status,
              get_status(cam->drv_status));
      return;
   }
   *texptime = exptime;
   *taccumtime = accumtime;
   *tkinetictime = kinetictime;
}

#define MSG_UNKNOWN "Unknown return code."

#define MSG_DRV_ERROR_CODES "20001 : "
#define MSG_DRV_P1INVALID "20066: "
#define MSG_DRV_SUCCESS "SUCCESS"
#define MSG_DRV_P2INVALID "20067: "
#define MSG_DRV_VXDNOTINSTALLED "20003 : "
#define MSG_DRV_P3INVALID "20068: "
#define MSG_DRV_ERROR_SCAN "20004 : "
#define MSG_DRV_P4INVALID "20069: "
#define MSG_DRV_ERROR_CHECK_SUM "20005 : "
#define MSG_DRV_INIERROR "20070: "
#define MSG_DRV_ERROR_FILELOAD "20006 : "
#define MSG_DRV_COFERROR "20071: "
#define MSG_DRV_UNKNOWN_FUNCTION "20007 : "
#define MSG_DRV_ACQUIRING "20072: Acquisition in progress."
#define MSG_DRV_ERROR_VXD_INIT "20008 : "
#define MSG_DRV_IDLE "20073: "
#define MSG_DRV_ERROR_ADDRESS "20009 : "
#define MSG_DRV_TEMPCYCLE "20074: "
#define MSG_DRV_ERROR_PAGELOCK "20010 : "
#define MSG_DRV_NOT_INITIALIZED "20075: System not initialized."
#define MSG_DRV_ERROR_PAGE_UNLOCK "20011 : "
#define MSG_DRV_P5INVALID "20076: "
#define MSG_DRV_ERROR_BOARDTEST "20012 : "
#define MSG_DRV_P6INVALID "20077: "
#define MSG_DRV_ERROR_ACK "20013 : Unable to communicate with card."
#define MSG_DRV_INVALID_MODE "20078: "
#define MSG_DRV_ERROR_UP_FIFO "20014 : "
#define MSG_DRV_INVALID_FILTER "20079: "
#define MSG_DRV_ERROR_PATTERN "20015 : "
#define MSG_DRV_I2CERRORS "20080: "
#define MSG_DRV_ACQUISITION_ERRORS "20017 : "
#define MSG_DRV_DRV_I2CDEVNOTFOUND "20081: "
#define MSG_DRV_ACQ_BUFFER "20018 : "
#define MSG_DRV_I2CTIMEOUT "20082: "
#define MSG_DRV_ACQ_DOWNFIFO_FULL "20019 : "
#define MSG_DRV_P7INVALID "20083: "
#define MSG_DRV_PROC_UNKNOWN_INSTRUCTION "20020 : "
#define MSG_DRV_USBERROR "20089: "
#define MSG_DRV_ILLEGAL_OP_CODE "20021 : "
#define MSG_DRV_IOCERROR "20090: "
#define MSG_DRV_KINETIC_TIME_NOT_MET "20022 : "
#define MSG_DRV_NOT_SUPPORTED "20091: "
#define MSG_DRV_KINETIC_TIME_NOT_MET "20022 : "
#define MSG_DRV_USB_INTERRUPT_ENDPOINT_ERROR "20093: "
#define MSG_DRV_ACCUM_TIME_NOT_MET "20023 : "
#define MSG_DRV_RANDOM_TRACK_ERROR "20094: "
#define MSG_DRV_NO_NEW_DATA "20024 : "
#define MSG_DRV_INVALID_TRIGGER_MODE "20095: "
#define MSG_DRV_SPOOLERROR "20026 : "
#define MSG_DRV_LOAD_FIRMWARE_ERROR "20096: "
#define MSG_DRV_TEMPERATURE_CODES "20033 : "
#define MSG_DRV_DIVIDE_BY_ZERO_ERROR "20097: "
#define MSG_DRV_TEMPERATURE_OFF "20034 : Temperature is OFF."
#define MSG_DRV_INVALID_RINGEXPOSURES "20098: "
#define MSG_DRV_TEMPERATURE_NOT_STABILIZED "20035 : Temperature reached but not stabilized."
#define MSG_DRV_BINNING_ERROR "20099: "
#define MSG_DRV_TEMPERATURE_STABILIZED "20036 : Temperature has stabilized at set point."
#define MSG_DRV_ERROR_NOCAMERA "20990: "
#define MSG_DRV_TEMPERATURE_NOT_REACHED "20037 : Temperature has not reached set point."
//#define MSG_DRV_NOT_SUPPORTED "20991: "
#define MSG_DRV_TEMPERATURE_OUT_RANGE "20038 : "
#define MSG_DRV_NOT_AVAILABLE "20992: "
#define MSG_DRV_TEMPERATURE_NOT_SUPPORTED "20039 : "
#define MSG_DRV_ERROR_MAP "20115: "
#define MSG_DRV_TEMPERATURE_DRIFT "20040 : Temperature had stabilized but has since drifted."
#define MSG_DRV_ERROR_UNMAP "20116: "
#define MSG_DRV_GENERAL_ERRORS "20049 : "
#define MSG_DRV_ERROR_MDL "20117: "
#define MSG_DRV_INVALID_AUX "20050 : "
#define MSG_DRV_ERROR_UNMDL "20118: "
#define MSG_DRV_COF_NOTLOADED "20051 : "
#define MSG_DRV_ERROR_BUFFSIZE "20119: "
#define MSG_DRV_FPGAPROG "20052 : "
#define MSG_DRV_ERROR_NOHANDLE "20121: "
#define MSG_DRV_FLEXERROR "20053 : "
#define MSG_DRV_GATING_NOT_AVAILABLE "20130: "
#define MSG_DRV_GPIBERROR "20054 : "
#define MSG_DRV_FPGA_VOLTAGE_ERROR "20131: "
#define MSG_DRV_DATATYPE "20064 : "
#define MSG_DRV_BINNING_ERROR "20099: "
#define MSG_DRV_DRIVER_ERRORS "20065 : "
#define MSG_DRV_INVALID_AMPLIFIER "20100: Not a valid amplifier."
#define MSG_DRV_TEMP_DRIFT "20XXX: Temperature had stabilized but has since drifted."
#define MSG_DRV_TEMP_NOT_STABILIZED "20035: Temperature reached but not stabilized."

char * get_status(int st)
{
   switch(st)
   {
      case DRV_NOT_INITIALIZED:     return MSG_DRV_NOT_INITIALIZED; break;
      case DRV_ACQUIRING:           return MSG_DRV_ACQUIRING; break;
      case DRV_ERROR_ACK:           return MSG_DRV_ERROR_ACK; break;
      case DRV_TEMP_OFF:            return MSG_DRV_TEMPERATURE_OFF; break;
      case DRV_TEMP_STABILIZED:     return MSG_DRV_TEMPERATURE_STABILIZED; break;
      /*
      On decide que si la temperature n est pas atteinte c est pas grave. on maitrise !
      case DRV_TEMP_NOT_REACHED:    return MSG_DRV_TEMPERATURE_NOT_REACHED; break;
      */
      case DRV_TEMP_NOT_REACHED:    return MSG_DRV_TEMPERATURE_NOT_REACHED; break;
      case DRV_TEMP_DRIFT:          return MSG_DRV_TEMP_DRIFT; break;
      case DRV_TEMP_NOT_STABILIZED: return MSG_DRV_TEMP_NOT_STABILIZED; break;
      case DRV_SUCCESS:             return MSG_DRV_SUCCESS; break;
      case DRV_P1INVALID:           return MSG_DRV_P1INVALID; break;
      case DRV_P2INVALID:           return MSG_DRV_P2INVALID; break;
      case DRV_P3INVALID:           return MSG_DRV_P3INVALID; break;
      case DRV_P4INVALID:           return MSG_DRV_P4INVALID; break;
      default: break;
   }
   
   return MSG_UNKNOWN;
}
