/* libtel.h
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

//=============================================================================
// export directive and import directive
//=============================================================================
#ifdef _WIN32
#if defined(LIBTEL_EXPORTS) // inside DLL
#   define LIBTEL_API   __declspec(dllexport)
#else                       // outside DLL
#   define LIBTEL_API   __declspec(dllimport)
#endif 
#else 
#if defined(LIBTEL_EXPORTS) // inside DLL
#   define LIBTEL_API   __attribute__((visibility ("default")))
#else                       // outside DLL
#   define LIBTEL_API 
#endif 
#endif

//#ifdef _WIN32
////  C4290 : C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
//#pragma warning( disable : 4290 )
//#endif
   
#include <abcommon.h>
#include <abmc.h>
#include <abaudela.h>


namespace libtel {

   //--------------------------------------------------------------------------------------
   // class ILibtel
   //--------------------------------------------------------------------------------------
   class ILibtel {

   public:
      enum AlignmentMode { ALIGNMENT_EQUATORIAL=0  };
      enum Capability { CAN_PARK, CAN_PULSE, CAN_SYNC } ;
      
      virtual void releaseInstance(){};
      virtual ~ILibtel(){};

      //virtual AlignmentMode alignment_mode_get()=0;
      //virtual void         alignment_mode_set(AlignmentMode alignmentMode)=0;
      virtual bool         capability_get(Capability capability)=0;
      virtual bool         connected_get()=0;
      virtual void         date_get(abmc::IDate* date)=0;
      virtual void         date_set(abmc::IDate* date)=0;
      virtual void         home_get(abmc::IHome* home)=0;
      virtual void         home_set(abmc::IHome* home)=0;

      virtual const char * name_get()=0;
      virtual const char * port_name_get()=0;
      virtual const char * product_get()=0;
      virtual void         park()=0;      

      virtual void         radec_coord_get(abmc::ICoordinates * radec)=0;
      virtual void         radec_coord_sync(abmc::ICoordinates* radec, abaudela::ITelescope::MountSide mountside )=0;
      virtual void         radec_goto(abmc::ICoordinates* radec, bool blocking)=0;

      virtual void         radec_guide_rate_get(double* raRate, double* decRate)=0;
      virtual void         radec_guide_rate_set(double raRate, double decRate)=0;
      virtual void         radec_guide_pulse_duration( abaudela::Direction alphaDirection, double alphaDuration, abaudela::Direction deltaDirection, double deltaDuration)=0;
      virtual void         radec_guide_pulse_distance( abaudela::Direction alphaDirection, double alphaDistance, abaudela::Direction deltaDirection, double deltaDistance)=0;
      virtual bool         radec_guide_pulse_moving_get()=0;

      virtual void         radec_move_start(abaudela::Direction direction, double rate)=0;
      virtual void         radec_move_stop(abaudela::Direction direction)=0;
      virtual IIntArray*   radec_rate_list_get(int axis)=0;
      virtual bool         radec_slewing_get()=0;
      virtual bool         radec_tracking_get()=0;
      virtual void         radec_tracking_set(bool tacking)=0;
      
      virtual bool         refraction_correction_get()=0;

      virtual  int         specificCommand_execute(int argc, const char *argv[], char** result)=0;
      virtual  int         specificCommand_execute_tcl(void * interp, int argc, const char *argv[])=0;
      virtual  void        specificCommand_freeResult(char * result)=0;
      

      virtual void         unpark()=0;
      
      
   };


   // fonctions exportee explicitement
   extern "C" LIBTEL_API ILibtel*   createTelescopeInstance(int argc, const char *argv[]);
   //extern "C" LIBTEL_API IStringArray*  getAvailableDevice();

   //typedef IStringArray*  (* getAvailableDeviceFunc)();

} // namespace end

