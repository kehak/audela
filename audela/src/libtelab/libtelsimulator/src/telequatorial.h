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
 // $Id: telequatorial.h 14291 2017-11-20 12:07:23Z fredvachier $
#pragma once

#include <libtelab/libtelcommon.h>

/*
 * CCamera definition
 */
class CTelEquatorial {

public: 
   CTelEquatorial();
   ~CTelEquatorial();

   bool        connected_get();
   void        date_get(abmc::IDate* date);
   void        date_set(abmc::IDate* date);
   void        home_get(abmc::IHome* home);
   void        home_set(abmc::IHome* home);
   void        park();

   const char* name_get();
   const char* product_get();

   double      getRa();
   double      getDec();
   void        syncRadec(double ra, double dec);
   void        gotoRadec(double ra, double dec, bool blocking);

   void        radec_guide_rate_get(double* raRate, double* decRate);
   void        radec_guide_rate_set(double raRate, double decRate);
   void        radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration, abaudela::Direction deltaDirection, double deltaDuration);
   void        radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance, abaudela::Direction deltaDirection, double deltaDistance);
   bool        radec_guide_pulse_moving_get();
      
   void        radec_move_start(abaudela::Direction direction, double rate);
   void        radec_move_stop(abaudela::Direction direction);
   IIntArray*  radec_rate_list_get(int axis);
   bool        radec_slewing_get();
   bool        radec_tracking_get();
   void        radec_tracking_set(bool tacking);

   bool        refraction_correction_get();

   void        unpark();

 
private:
   double m_ra;
   double m_dec; 
   double m_raRate;
   double m_decRate;
   bool   m_raPulseMoving;
   bool   m_decPulseMoving;
   
   void pulseDurationThread(abaudela::Direction direction, double duration);
   void pulseDistanceThread(abaudela::Direction direction, double distance);




};

