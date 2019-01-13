/* CTelescope.h
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
 // $Id:  $
#pragma once

#include <string>
#include <atomic>
#include <condition_variable>

#include <abaudela.h>
#include <abmc.h>

#include <libtelab/libtel.h>
#include "CLibraryLoader.h"



typedef struct : abaudela::IEvent {

} CEventGoto; 


class CEventCoord : public abaudela::IEvent {
public: 
   CEventCoord(abmc::ICoordinates * coord);
   ~CEventCoord();
private:
   abmc::ICoordinates * m_coord;
}; 



class CTelescope : public abaudela::ITelescope  {


public:
   CTelescope();
   ~CTelescope();
   void  init(const char* librayPath, const char * libraryFileName, int argc, const char *argv[]);
   int   close();

   abcommon::ILogger*      getLogger();

   void setCallback(abaudela::TelescopeCallbackType telescopeCallback, void *clientData);
   abaudela::TelescopeCallbackType m_telescopeCallback;
   void * m_callbackClientData;

   abaudela::Alignment  alignment_get();
   void                 alignment_set(abaudela::Alignment alignment);
   void                 date_get(abmc::IDate* date);
   void                 date_set(abmc::IDate* date);
   double               foclen_get();
   void                 foclen_set(double foclen);

   void                 home_get(abmc::IHome* home);
   void                 home_set(abmc::IHome* home);
   const char *         home_name_get();
   void                 home_name_set(const char* homeNames);
   const char *         library_name_get();

   const char *         name_get();
   const char *         port_name_get();
   const char *         product_get();

   abmc::ICoordinates*  radec_coord_get();
   bool                 radec_coord_monitor_get();
   void                 radec_coord_monitor_start(abaudela::TelescopeCallbackCoordType callback, void* clientData);
   void                 radec_coord_monitor_stop();
   void                 radec_goto(abmc::ICoordinates*  radec, bool blocking, bool backslash);
   double               radec_goto_rate_get();
   void                 radec_goto_rate_set(double rate);
   bool                 radec_guiding_get();
   void                 radec_guiding_set(bool enabled);
   void                 radec_init(abmc::ICoordinates*  radec, MountSide mountSide);
   bool                 radec_model_enabled_get();
   void                 radec_model_enabled_set(bool enabled);
   void                 radec_move_start(abaudela::Direction direction, double rate);
   void                 radec_move_stop(abaudela::Direction direction);
   void                 radec_guide_rate_get(double* raRate, double* decRate);
   void                 radec_guide_rate_set(double raRate, double decRate);
   void                 radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration, abaudela::Direction deltaDirection, double deltaDuration);
   void                 radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance, abaudela::Direction deltaDirection, double deltaDistance);
   bool                 radec_guide_pulse_moving_get();

   bool                 radec_tracking_get();
   void                 radec_tracking_set(bool tracking);
   bool                 refraction_correction_get();

   int      executeSpecificCommand(int argc, const char *argv[], char** result );
   void     freeSpecificCommandResult(char* result);
   int      executeTclSpecificCommand(void* interp, int argc, const char *argv[]);

      //virtual double       tel_foclen_get()=0;
      //virtual void         tel_foclen_set(double foclen)=0;
      //virtual IDate*       tel_radec_model_date_set(IDate* date)=0;
      //virtual void         tel_radec_model_date_set(IDate* date)=0;
      //virtual bool         tel_radec_model_enabled_get()=0;
      //virtual void         tel_radec_model_enabled_set(bool enabled)=0;
      //virtual double       tel_radec_model_pressure_get()=0;
      //virtual void         tel_radec_model_pressure_set(double pressure)=0;
      //virtual double       tel_radec_model_temperature_get()=0;
      //virtual void         tel_radec_model_temperature_set(double temperature)=0;
      //virtual void         tel_radec_model_coefficients_set(double coefficients)=0;
      //virtual void         tel_radec_model_symbols_set(double symbols)=0;

private:
   libtel::ILibtel*  m_libtel;
   CLogger           m_logger;
   CLibraryLoader<libtel::ILibtel*> m_libraryLoader;
   //CEventQueue<abaudela::IEvent*>  m_queue;

   abaudela::Alignment m_alignment;
   double            m_foclen;
   bool              m_guiding;
   std::string       m_homeName;
   std::atomic<bool> m_radecCoordMonitor;
   bool              m_radecGotoMonitor;
   bool              m_radecModelEnabled;
   double            m_radecGotoRate;
   std::condition_variable m_radecCoordMonitorCv;
   std::mutex m_radecCoordMonitorMutex;
   //double focusspeed;
   //int active_backlash;
   //char radec_model_coefficients[1024];
   //char radec_model_name[255];
   //char radec_model_date[255];
   //int  radec_model_pressure;
   //char radec_model_symbols[255];
   //int  radec_model_temperature;


   // methods
   void monitorCoords(abaudela::TelescopeCallbackCoordType callback, void* clientData);
   
};

