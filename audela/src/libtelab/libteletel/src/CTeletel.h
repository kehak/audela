/* CTeletel.h
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
 // $Id:  $
#pragma once

#include <libtelab/libtelcommon.h> //  pour CLibtelCommon
#include <abmc.h>       // pour IHome
#include <etel/dsa40.h> // pour DSA_DRIVE

typedef struct {
   char type_symbol[10];
   int typ;
   int ctype;
   //int *func_get;
   //int *func_set;
} struct_etel_type;

#define NB_TYP 19

#define ETEL_NAXIS_MAXI 10

#define ETEL_VAL_INT32   0
#define ETEL_VAL_INT64   1
#define ETEL_VAL_FLOAT32 2
#define ETEL_VAL_FLOAT64 3

///
// CTeletel definition
//
class CTeletel : public CLibtelCommon {

public:
   enum class AxisState { CLOSED, TO_BE_OPENED, OPENED };

public: 
   void        init(int argc, const char *argv[]);
   void        close();

   bool        connected_get();
   void        date_get(abmc::IDate* date);
   void        date_set(abmc::IDate* date);
   void        home_get(abmc::IHome* home);
   void        home_set(abmc::IHome* home);
   void        park();

   void        radec_coord_get(abmc::ICoordinates * radec);
   void        radec_coord_sync(abmc::ICoordinates* radec, abaudela::ITelescope::MountSide mountside);
   void        radec_goto(abmc::ICoordinates* radec, bool blocking);

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

   //  specificCmd
   int         getRegisterS(int argc, const char *argv[], std::string &result);
   int         setRegisterS(int argc, const char *argv[], std::string &result);


private:
   
   //attributes
   bool m_connected;
   IHome* m_home;
   std::string m_etel_driver;
   std::string m_msg;
   int m_etel_nbaxis;
   AxisState m_axis[ETEL_NAXIS_MAXI];
   int m_axisno[ETEL_NAXIS_MAXI];
   DSA_DRIVE *m_drv[ETEL_NAXIS_MAXI];
   static struct_etel_type m_typs[];

   
   // methodes utilitaires 
   int symbol2type(const char * symbol);
   const char* getError(int axisno, int err, std::string &msg);
   std::string CTeletel::getError(int axisno, int err);

   
};

