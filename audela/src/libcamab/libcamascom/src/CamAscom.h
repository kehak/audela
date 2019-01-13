/* camera.h
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

#pragma once

#include <libcamab/libcamcommon.h>
#include "AscomCamera.h"

//
// CCamAscom definition
//
class CCamAscom : public CLibcamCommon {

public: 

   void     cam_init( int argc, const char **argv);
	void     cam_close();
	void     cam_update_window();
   
   void     cam_binning_set(int binx, int biny);

   double   cam_cooler_checkTemperature_get();
   void     cam_cooler_checkTemperature_set(double temperature);
   double   cam_cooler_ccdTemperature_get();
   bool     cam_cooler_get();
   void     cam_cooler_set(bool on);

   void     cam_exposure_abort();
	void     cam_exposure_start();
	void     cam_exposure_stop();
	void     cam_exposure_readCCD(float *p);
  
     
   void ascomcamGetTemperatureInfo(double *setTemperature, double *ccdTemperature, 
         double *ambientTemperature, int *regulationEnabled, int *power);
   int cam_connectedSetupDialog( );
   static int ascomcamSetupDialog(const char * ascomDiverName, char * errorMsg);
	int ascomcamSetWheelPosition(CCamAscom *cam, int position);
   int ascomcamGetWheelPosition(CCamAscom *cam, int *position);
   int ascomcamGetWheelNames(CCamAscom *cam, char **names);
   int ascomcamGetMaxBin(CCamAscom *cam,  int * maxBin) ;
	int ascomcamHasShutter(CCamAscom *cam,  int *hasShutter) ;
	int cmdAscomcamProperty(CCamAscom* cam, int argc, const char *argv[]);
	int cmdAscomcamConnectedSetupDialog(CCamAscom* cam, int argc, const char *argv[]);
 
private:
   AscomCamera * ascomCamera;

};

