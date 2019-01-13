/* camera.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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

#include <exception>
#include <stdio.h>      // sprintf
//#include <time.h>               /* time, ftime, strftime, localtime */
//#include <sys/timeb.h>          /* ftime, struct timebuffer */
#include <exception>
#include <string>


#include <libcamab/libcam.h>
#include <libcamab/libcamcommon.h>
#include "CamSimu.h"

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CLibcamCommon::CAM_INI[] = {
    {"simulator",		/* camera name 70 car maxi*/
     "camsim",       /* camera product */
     "Kaf400",	      /* ccd name */
     768, 512,			/* maxx maxy */
     14, 14,			/* overscans x */
     4, 4,			   /* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     65535.,			/* observed saturation */
     0.9,   	    /* filling factor */
     11.,			/* gain (e/adu) */
     13.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			   /* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     false,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};


/**
 * Commandes propres a chaque camera
 */ 

//struct cmditemSpec specificCmdList[] = {
//    /* === Specific commands for that camera === */
//    //{"infotemp", (Spec_CmdProc *) cmdAscomcamInfotemp},
//    {"property", (Spec_CmdProc *) cmdAscomcamProperty},
//    {"setup",    (Spec_CmdProc *) cmdAscomcamConnectedSetupDialog},
//    //{"wheel",    (Spec_CmdProc *) cmdAscomcamWheel},
//    /* === Last function terminated by NULL pointers === */
//    {NULL, NULL}
//};


/// @brief  create instance
//
libcam::ILibcam* libcam::createCameraInstance(int argc, const char *argv[]) {
   return CLibcamCommon::createCameraInstance(new CCamSimu(), argc, argv);
};

/// @brief  init instance
//
void CCamSimu::cam_init(int argc, const char **argv) 
{  
   
   m_binMaxX = 4;
   m_binMaxY = 5;

   cam_update_window();	// met a jour x1,y1,x2,y2,h,w dans cam
   
  
   m_logger.logDebug("cam_init fin OK");
}

void CCamSimu::cam_close()
{
   m_logger.logDebug("cam_close debut");
   m_logger.logDebug("cam_close fin OK");
}


void CCamSimu::cam_binning_set(int binx, int biny) {
   this->binx = binx;
   this->biny = biny;
   cam_update_window();
   m_logger.logDebug("cam_set_binning debut. binx=%d biny=%d", binx, biny);
}



void CCamSimu::cam_update_window()
{
   int maxx, maxy;
   maxx = this->nb_photox;
   maxy = this->nb_photoy;
   int x1, x2, y1, y2; 

   if (this->x1 > this->x2) {
      int x0 = this->x2;
      this->x2 = this->x1;
      this->x1 = x0;
   }
   if (this->x1 < 0) {
      this->x1 = 0;
   }
   if (this->x2 > maxx - 1) {
      this->x2 = maxx - 1;
   }

   if (this->y1 > this->y2) {
      int y0 = this->y2;
      this->y2 = this->y1;
      this->y1 = y0;
   }
   if (this->y1 < 0) {
      this->y1 = 0;
   }

   if (this->y2 > maxy - 1) {
      this->y2 = maxy - 1;
   }

   // je prend en compte le binning 
   this->w = (this->x2 - this->x1 +1) / this->binx ;
   this->h = (this->y2 - this->y1 +1) / this->biny ;
   x1 = this->x1  / this->binx;
   y1 = this->y1 / this->biny;
   x2 = x1 + this->w -1;
   y2 = y1 + this->h -1;

   // j'applique le miroir aux coordonnes de la sous fenetre
   if ( this->mirrorv == 1 ) {
      // j'applique un miroir vertical en inversant les ordonnees de la fenetre
      x1 = (maxx / this->binx ) - x2 -1;
   }
   if ( this->mirrorh == 1 ) {
      // j'applique un miroir horizontal en inversant les abcisses de la fenetre
      // 0---y1-----y2---------------------(w-1)
      // 0---------------(w-y2)---(w-y1)---(w-1)  
      y1 = (maxy / this->biny ) - y2 -1;
   }
   
}

void CCamSimu::cam_exposure_abort() {
   m_logger.logDebug("cam_exposure_abort TODO ");
}

void CCamSimu::cam_exposure_start()
{
}

void CCamSimu::cam_exposure_stop()
{
   m_logger.logDebug("cam_stop_exp debut");
      m_logger.logDebug("cam_stop_exp fin OK");
}

void CCamSimu::cam_exposure_readCCD(float *p)
{
   m_logger.logDebug("cam_read_ccd debut");
}

double CCamSimu::cam_cooler_checkTemperature_get()
{
   return m_checkTemperature;
}

void CCamSimu::cam_cooler_checkTemperature_set(double temperature)
{
   m_checkTemperature = temperature;
}

double CCamSimu::cam_cooler_ccdTemperature_get() 
{
   return -20;
}


bool CCamSimu::cam_cooler_get()
{
   return m_coolerOn;
}

void CCamSimu::cam_cooler_set(bool on)
{
   m_coolerOn = on;
}


abcommon::CStructArray<abcommon::SAvailable*>*  libcam::getAvailableCamera( ) {
   abcommon::CStructArray<abcommon::SAvailable*>* available = new abcommon::CStructArray<abcommon::SAvailable*>();
   available->append(new abcommon::SAvailable(std::string("equat"), std::string("Equatorial")));
   available->append(new abcommon::SAvailable(std::string("altaz"), std::string("Altazimutal")));
   return available;
}
