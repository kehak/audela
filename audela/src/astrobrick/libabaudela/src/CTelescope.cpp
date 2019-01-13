/* CTelescope.cpp
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>     // pour timeval
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <thread>
#include <chrono>
#include <condition_variable>


#include <string>
#include <sstream>  // pour ostringstream
#include <ltdl.h>

#include <abcommon.h>
using namespace abcommon;
#include <abmc.h>
using namespace abmc;
#include <abaudela.h>
using namespace abaudela;
#include "CTelescope.h"


CTelescope::CTelescope() {

   m_alignment = Alignment::EQUATORIAL;
   m_foclen = 0;
   m_guiding = false;
   m_homeName = "";
   m_logger.setLogLevel(CLogger::LOG_ERROR);
   m_logger.setLogFileName(std::string("telescope.log"));
   m_radecCoordMonitor = false;    // la surveillance des coordonnées est arretée par defaut
   m_radecGotoMonitor = false;
   m_radecModelEnabled = false;    // p as de modele de pointage par defaut

   m_telescopeCallback = NULL;
   
   //this->radec_model_temperature = 290;  // temperature par defaut 
   //this->radec_model_pressure = 101325;  // pression par defaut
   //strcpy(this->radec_model_name,""); 
   //strcpy(this->radec_model_symbols,""); 
   //strcpy(this->radec_model_coefficients,"");
  
}

CTelescope::~CTelescope() {
   m_logger.logDebug("CTelescope::~CTelescope begin");
   // j'arrete la suveillance des coordonnees
   radec_coord_monitor_stop();

   //this->close();
   m_libtel->releaseInstance();
   m_logger.logDebug("CTelescope::~CTelescope end");
}

void CTelescope::init(const char* librayPath, const char * libraryFileName, int argc, const char *argv[]) {
   m_logger.set("telescope.log", argc, argv);
   m_libtel = m_libraryLoader.load(librayPath, "tel", libraryFileName, "createTelescopeInstance", argc, argv);
}

int CTelescope::close() {


   return 0;
}


void CTelescope::setCallback(TelescopeCallbackType telescopeCallback, void *clientData) {
   this->m_telescopeCallback = telescopeCallback;
   this->m_callbackClientData = clientData;
}

abcommon::ILogger*  CTelescope::getLogger() {
   return &m_logger;
} 

Alignment CTelescope::alignment_get() {
   return m_alignment;
}
void CTelescope::alignment_set(Alignment alignment) {
   m_alignment = alignment;
}

void CTelescope::date_get(IDate* date) {
   m_libtel->date_get(date);
}

void CTelescope::date_set(IDate* date) {
   m_libtel->date_set( date);
}

const char*  CTelescope::library_name_get() {
   return m_libraryLoader.getLibraryName();
}



double CTelescope::foclen_get() {
   return m_foclen;
}

void CTelescope::foclen_set(double foclen) {
   m_foclen = foclen;
}

void CTelescope::home_get(IHome* home) {
   m_libtel->home_get(home);
}

void CTelescope::home_set(IHome* home) {
   m_libtel->home_set(home);
}

const char * CTelescope::home_name_get() {
   return m_homeName.c_str();
}

void CTelescope::home_name_set(const char* homeName) {
   m_homeName = homeName;
}



int CTelescope::executeSpecificCommand(int argc, const char *argv[], char** result) {
   return m_libtel->specificCommand_execute(argc, argv, result );
}

int CTelescope::executeTclSpecificCommand(void * interp, int argc, const char *argv[]) {
   return m_libtel->specificCommand_execute_tcl(interp, argc, argv );
}

void CTelescope::freeSpecificCommandResult(char * result) {
   m_libtel->specificCommand_freeResult(result);
}

const char*  CTelescope::name_get() {
   return m_libtel->name_get();
}

const char*  CTelescope::port_name_get() {
   return m_libtel->port_name_get();
}

const char*  CTelescope::product_get() {
   return m_libtel->product_get();
}



ICoordinates* CTelescope::radec_coord_get() {
   ICoordinates* coords = getMc()->createCoordinates_from_string("", abmc::Equinox::NOW);
   m_libtel->radec_coord_get(coords);
   return coords;
}


bool CTelescope::radec_guiding_get() {
   return m_guiding;
}

void CTelescope::radec_guiding_set(bool guiding) {
   m_guiding = guiding;
}

void CTelescope::radec_init(abmc::ICoordinates*  radec, MountSide mountSide) {
   m_libtel->radec_coord_sync(radec, mountSide);
}

//-------------------------------------------------------------
// radec_model
//-------------------------------------------------------------

bool CTelescope::radec_model_enabled_get() {
   return m_radecModelEnabled;
}

void CTelescope::radec_model_enabled_set(bool enabled) {
   m_radecModelEnabled = enabled;
}

//-------------------------------------------------------------
// radec_move
//-------------------------------------------------------------

/////@brief thread de surveillance du goto
////
//void* CTelescope::CThreadRadecGotoMonitor::run() {
//
//   ICoordinates* coords = ICoordinates_createInstance();
//   m_tel->m_libtel->radec_coord_get(coords);
//   //double ra =  coords->getRa(Equinox::NOW);
//   //double dec = coords->getDec(Equinox::NOW);
//   if( m_tel->m_radecGotoMonitor == true) {
//
//   }
//   
//   ICoordinates_deleteInstance(coords);
//   return NULL;
//}


/////@brief start goto
////
//void CTelescope::radec_goto(abmc::ICoordinates*  radec, bool blocking){
//   m_libtel->radec_goto(radec, blocking);
//   m_radecGotoMonitor = true;
//
//   // je lance de suivi du GOTO
//   if ( blocking == false ) {
//
//      // je lance le thread de suveillandedu goto qui enverra un message a la fin du goto
//      //libtel_log(LOG_DEBUG,"cmdCamAcq pthread_create");
//      CThreadRadecGotoMonitor threadRadecGotoMonitor(this, radec);
//      threadRadecGotoMonitor.start();
//   }
//}


void CTelescope::radec_move_start(Direction direction, double rate){
   m_libtel->radec_move_start(direction, rate);
}


void CTelescope::radec_move_stop(Direction direction) {
   // TODO  :j'arrete le timer utilise par default_tel_sendPulse 

   m_libtel->radec_move_stop(direction);
}


//-------------------------------------------------------------
// radec_coord_monitor
//-------------------------------------------------------------
///@brief coordinates monitor state 
// @return true if coordinates monitor is activated
bool CTelescope::radec_coord_monitor_get(){
   return m_radecCoordMonitor;
}

///@brief thread de surveillance des coordonnées
//
void CTelescope::monitorCoords(TelescopeCallbackCoordType callback, void* clientData) {
   unsigned int interval = 1000;

   std::unique_lock<std::mutex> lk(m_radecCoordMonitorMutex);
   ICoordinates* coordinates = getMc()->createCoordinates();
   m_logger.log(CLogger::LOG_DEBUG, "monitorCoords begin");
   while (m_radecCoordMonitor)
   {
      try {
         //bool timeout = cv.wait_for(lk, std::chrono::milliseconds(interval), [this]() { return !radec_coord_monitor_get(); });
         std::cv_status  status = m_radecCoordMonitorCv.wait_for(lk, std::chrono::milliseconds(interval));
         if (status == std::cv_status::timeout) {
            if (radec_coord_monitor_get() == true) {
               m_logger.log(CLogger::LOG_DEBUG, "monitorCoords loop");
               m_libtel->radec_coord_get(coordinates);
               if (callback != NULL) {
                  callback(clientData, coordinates);
               } 
            }
         }
      }
      catch (CError &ex) {
         m_logger.log(CLogger::LOG_ERROR, "monitorCoords %s", ex.getMessage());
      }

   }
   abmc::ICoordinates_deleteInstance(coordinates);
   lk.unlock();
   m_logger.log(CLogger::LOG_DEBUG, "monitorCoords end");
   m_radecCoordMonitorCv.notify_all();
}

///@brief  start radec coord monitor
void CTelescope::radec_coord_monitor_start(TelescopeCallbackCoordType callback, void* clientData) {
	if (m_radecCoordMonitor == false) {
		m_radecCoordMonitor = true;
		//je lance la surveillance des coordonnées
		std::thread(&CTelescope::monitorCoords, this, callback, clientData).detach();
	}
}

///@brief  stop radec coord monitor
void CTelescope::radec_coord_monitor_stop() {
   m_logger.logDebug("radec_coord_monitor_stop begin");
   if (m_radecCoordMonitor == true) {
      // j'arrete la surveillance des coordonnées
      m_radecCoordMonitor = false;
      // je notifie les threads qui surveillent cette condition.
      m_radecCoordMonitorCv.notify_all();
      // j'attends que les threads aient traité la notification 
      // (important si on supprime le tescope juste apres) 
      std::unique_lock<std::mutex> lk(m_radecCoordMonitorMutex);
      m_logger.logDebug("radec_coord_monitor_stop wait begin");
      m_radecCoordMonitorCv.wait(lk);
      m_logger.logDebug("radec_coord_monitor_stop wait end");
   }
   m_logger.logDebug("radec_coord_monitor_stop end");

}


CEventCoord::CEventCoord(abmc::ICoordinates * coord) {
   m_coord = getMc()->createCoordinates_from_coord(*coord);
}

CEventCoord::~CEventCoord() {
   if(m_coord != NULL) {
      ICoordinates_deleteInstance(m_coord);
   }
}


//-------------------------------------------------------------
// radec goto methods
//-------------------------------------------------------------

void CTelescope::radec_goto(abmc::ICoordinates*  coords, bool blocking, bool ) {
   m_libtel->radec_goto(coords, blocking);
}

double CTelescope::radec_goto_rate_get() {
   return m_radecGotoRate;
}

void CTelescope::radec_goto_rate_set(double rate) {
   m_radecGotoRate = rate;
}

//-------------------------------------------------------------
// radec pulse methods
//-------------------------------------------------------------

void CTelescope::radec_guide_rate_get(double* raRate, double* decRate) {
   m_libtel->radec_guide_rate_get(raRate, decRate);
}

void CTelescope::radec_guide_rate_set(double raRate, double decRate) {
   m_libtel->radec_guide_rate_set(raRate, decRate);

}

void CTelescope::radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration, abaudela::Direction deltaDirection, double deltaDuration) {
   m_libtel->radec_guide_pulse_duration(alphaDirection, alphaDuration, deltaDirection, deltaDuration);
}

void CTelescope::radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance, abaudela::Direction deltaDirection, double deltaDistance) {
   m_libtel->radec_guide_pulse_distance(alphaDirection, alphaDistance, deltaDirection, deltaDistance);
}

bool CTelescope::radec_guide_pulse_moving_get() {
   return m_libtel->radec_guide_pulse_moving_get();
}



bool CTelescope::radec_tracking_get() {
   return m_libtel->radec_tracking_get();
}

void CTelescope::radec_tracking_set(bool tracking) {
   m_libtel->radec_tracking_set(tracking);
}

bool CTelescope::refraction_correction_get() {
   return m_libtel->refraction_correction_get();
}



