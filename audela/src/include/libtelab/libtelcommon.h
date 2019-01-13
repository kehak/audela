/* libtel.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujols
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

/*****************************************************************/
/*             This part is common for all tel drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>        // va_list, va_start, va_arg, va_end 
#include <time.h>          // time, ftime, strftime, localtime 
#include <sys/timeb.h>     // ftime, struct timebuffer 
#include <string>          // std::string
#include <vector>           
#include <utility>         // std::pair
#include "sysexp.h"
#include <libtelab/libtel.h>

#ifdef WIN32
// pour forcer l'export des fonctions de libtelcomm dans les DLL des telescopes
//#pragma comment(linker, "/include:_createInstance")
//#pragma comment(linker, "/include:_deleteInstance")
#endif

struct Capabilities {
   bool expTimeCommand;     // existence de la commande de choix du temps de pose 
   bool expTimeList;        // existence d'une liste predefinie des temps de pose
   bool shutter;           // shutter available 
   bool videoMode;          // existence du mode video
};

//-----------------------------------------------------------------------------
// specific function prototype
//-----------------------------------------------------------------------------
class CLibtelCommon;

typedef int (Spec_CmdProc)(CLibtelCommon* tel, int argc, const char *argv[], std::string &result);
//typedef int (CLibtelCommon::*Spec_CmdProc)(int argc, const char *argv[]);

#define SPEC_OK 0
#define SPEC_ERROR 1

typedef struct {
   const char *cmd;
   Spec_CmdProc *func;
} SpecificCommand;

//extern SpecificCommand specificCommansList[];


//=============================================================================
// CLibtelCommon 
//=============================================================================
class CLibtelCommon : public libtel::ILibtel {

public:
   static libtel::ILibtel* createTelescopeInstance(CLibtelCommon *, int argc, const char *argv[]);
   CLibtelCommon();
   void releaseInstance();
   void init_common(int argc, const char *argv[]);

public:
   // abstract methods
   virtual void init(int argc, const char *argv[])=0;
   virtual void close()=0;

   // default methods
   bool           capability_get(Capability capability);
   IStringArray*  getAvailableDevice();
   const char *   name_get();
   const char *   port_name_get();
   const char *   product_get();

   // specificCommand   
   int specificCommand_execute(int argc, const char *argv[], char** result);
   int specificCommand_execute_tcl(void * interp, int argc, const char *argv[]);
   void specificCommand_freeResult(char* result);
   //void Spec_SetResult(std::string &result);
   //void Spec_SetResult(const char * result);
   static SpecificCommand specificCommansList[];


protected:
   void sleepms(int ms);

protected : 
   char        m_equinox[20];
   CLogger     m_logger;
   std::string m_name;
   std::string m_portName;   
   std::string m_product;
   int         m_radecGuidingState;
   int         m_radecPulseRate;
   int         m_radecPulseMinRadecDelay; 

   double      m_ra0;
   double      m_dec0;
   double      m_radec_goto_rate;
   int         m_radec_goto_blocking;
   double      m_radec_move_rate;
   int         m_radec_motor;
   double      m_focus0;
   int         m_focus_motor;
   double      m_focus_goto_rate;
   int         m_focus_goto_blocking;
   double      m_focus_move_rate;
   bool        m_refractionCorrection;

   char mountside[20];
   
};


