/* libtel.h
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
#include <stdarg.h>             /* va_list, va_start, va_arg, va_end */
#include <time.h>               // time, ftime, strftime, localtime 
#include <sys/timeb.h>          // ftime, struct timebuffer 
#include <stdexcept>


#ifndef _WIN32
#include <unistd.h>
#endif


#include <libtelab/libtelcommon.h>

/**
* ILibtel factory
*/
libtel::ILibtel* CLibtelCommon::createTelescopeInstance(CLibtelCommon * tel, int argc, const char *argv[]) {
   try
   {
      // j'initialise l'instance
      tel->init_common(argc, argv);
      tel->init(argc, argv);
      return tel;
   }
   catch (IError &ex) {
      if (tel != NULL) {
         delete tel;
      }
      // je memorise l'erreur
      abcommon::setLastError(ex);
      return NULL;
   }
}

/**
* common default contructor
*/ 
CLibtelCommon::CLibtelCommon() {

}

/**
* common destructor
*/ 
void CLibtelCommon::releaseInstance() {
   this->close();
   delete this;
}
   
   
/**
* init 
*/ 
void CLibtelCommon::init_common(int argc, const char *argv[]) {
   
   //SpecificResult = NULL;
   
   // j'initialise les traces
   m_logger.set("telescope.log", argc, argv);

   if (argc >= 1) {
      m_portName = argv[0];
   }
   
   this->m_refractionCorrection = false ;   // par defaut la monture n'a pas de correction de la refraction
   strcpy(this->m_equinox,"NOW");         // par defaut les montures travaillent avec les coordonnées basées sur l'equinoxe du jour.
   this->m_ra0=0.;                        
   this->m_dec0=0.;
   this->m_radec_goto_rate=0.;
   this->m_radec_goto_blocking=1;
   this->m_radec_move_rate=0.;
   this->m_focus0=0.;
   this->m_focus_goto_rate=0;
   this->m_focus_move_rate=0;
   
   this->m_radecGuidingState = 0;         // etat de la session de guidage par defaut
   this->m_radecPulseRate = 5;             // vitesse de guidage par defaut (arcsec/seconde)
   this->m_radecPulseMinRadecDelay = 0;
   

   
   m_logger.logDebug("init_common: create tel OK portName=%s", m_portName.c_str() );
}


bool CLibtelCommon::capability_get(Capability capability) {
   return false;

}


const char * CLibtelCommon::name_get() {
   return m_name.c_str();
}

const char * CLibtelCommon::port_name_get() {
   return m_portName.c_str();
}


const char * CLibtelCommon::product_get() {
   return m_product.c_str();
}


//=============================================================================
// specific command
//=============================================================================
/**
* executeSpecificCommand
* @param argv  argv[0]=tel1  argv[1]=command name , argv[2...]= command parameters
* @param specificCommandResult   command result 
*
* @return  0=OK  1=ERROR  -1= command not found
*/ 
int CLibtelCommon::specificCommand_execute(int argc, const char *argv[], char** result) {
   int retour = -1;
   *result = NULL;
   int n = sizeof(argv) / sizeof(char*);
   for (SpecificCommand* cmd = specificCommansList; cmd->cmd != NULL; cmd++) {
      if (strcmp(cmd->cmd, argv[0]) == 0) {
         std::string sresult;
         retour = (*cmd->func) (this, argc, argv, sresult);
         // je copie le pointeur du resultat
         *result = (char*)calloc(sresult.size() + 1, 1);
         memcpy(*result, sresult.c_str(), sresult.size() + 1);
         break;
      }
   }

   return retour;
}

int CLibtelCommon::specificCommand_execute_tcl(void * interp, int argc, const char *argv[]) {
   int retour = -1;
   //*specificCommandResult = NULL;
   //for (struct cmditemSpec* cmd = specificCmdList; cmd->cmd != NULL; cmd++) {
   //   if (strcmp(cmd->cmd, argv[1]) == 0) {
   //      retour = (*cmd->func) (telprop, argc, argv);
   //      // je copie le pointeur du resultat
   //      *specificCommandResult = SpecificResult;
   //      break;
   //   }
   //}

   return retour;
}

void CLibtelCommon::specificCommand_freeResult(char * result) {
   if(result != NULL) {
      free(result);
   }
}


//void CLibtelCommon::Spec_SetResult(std::string &result) {
//   Spec_SetResult(result.c_str());
//}

//void CLibtelCommon::Spec_SetResult(const char * result) {
//   // je nettoie 
//   if( SpecificResult != NULL) {
//      free(SpecificResult);
//      SpecificResult = NULL;
//   }
//
//   // je copie le resultat dans la variable de retour
//   if (result == NULL) {
//      SpecificResult = (char*) calloc(1,1);
//      strcpy(SpecificResult,"");
//   } else {
//      int length = strlen(result);
//      SpecificResult = (char*) calloc(length + 1, 1);
//      memcpy(SpecificResult, result, (unsigned) length+1);
//   }
//}

//=============================================================================
// Attente en millisecondes.
//=============================================================================/*
void CLibtelCommon::sleepms(int ms)
{
#if _WIN32
   Sleep(ms);
#else
   usleep(ms*1000);
#endif
}


//=============================================================================
// AvailableDevice
//=============================================================================
IStringArray*  CLibtelCommon::getAvailableDevice() {
      return new CStringArray();

}




