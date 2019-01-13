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
 
 // $Id:  $
 
#include "sysexp.h"

#include <exception>
#include <stdio.h>      // sprintf
#include <exception>
#include <string>


#include <libtelab/libtel.h>
#include <libtelab/libtelcommon.h>
#include <abmc.h>
using namespace abmc;

#include "telsimu.h"
#include "telequatorial.h"


/// @ brief  create instance
//
libtel::ILibtel* libtel::createTelescopeInstance(int argc, const char *argv[])  {
   return CLibtelCommon::createTelescopeInstance (new CTelsimu(), argc, argv);
};

/// @ brief  init instance
//
void CTelsimu::init(int argc, const char *argv[])
{  
   if (m_portName.compare("equat") == 0) {
      mytel = new  CTelEquatorial();
   } else {
      throw CError(CError::ErrorInput, " %s unexpected value. Must be equat|altaz", m_portName.c_str());
   }
     
   m_name = mytel->name_get();  
   m_product = mytel->product_get();
   m_refractionCorrection = mytel->refraction_correction_get();

}

void CTelsimu::close()
{
   delete mytel;
}


bool CTelsimu::connected_get()
{
   //TODO 
   return mytel->connected_get();
}



void CTelsimu::date_get(IDate* date)
{
   mytel->date_get(date);
}

void CTelsimu::date_set(IDate* date)
{
   mytel->date_set(date);
}

void CTelsimu::home_get(IHome* home)
{
   mytel->home_get(home);
}

void CTelsimu::home_set(IHome* home)
{
   try {
      mytel->home_set(home);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "home_set error=%s", e.what());
   }
}

void CTelsimu::park()
{
   try {
      mytel->park();
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "park error=%s", e.what());
   }
}

void CTelsimu::radec_coord_get(ICoordinates * radec)
{
   try {
      // je retourne des coordonnées courantes
      radec->setRaDec(mytel->getRa(), mytel->getDec(), abmc::Equinox::NOW);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_coord_get error=%s", e.what());
   }
}

void CTelsimu::radec_coord_sync(ICoordinates* radec, abaudela::ITelescope::MountSide MountSide)
{
   try {
      mytel->syncRadec(radec->getRa(Equinox::NOW), radec->getDec(Equinox::NOW));
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecInit error=%s", e.what());
   }
}

void CTelsimu::radec_guide_rate_get(double* raRate, double* decRate)
{
   try {
      mytel->radec_guide_rate_get(raRate, decRate);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_guide_rate_get error=%s", e.what());
   }
}

void CTelsimu::radec_guide_rate_set(double raRate, double decRate)
{
   try {
      mytel->radec_guide_rate_set(raRate, decRate);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_guide_rate_get error=%s", e.what());
   }
}


//-------------------------------------------------------------
// envoie une impulsion en ascension droite et en declinaison
// avec une duree donne en millisecondes  
//
// @param tel   pointeur structure telprop
// @param alphaDuration   direction de l'impulsion sur l'axe alpha E, W  
// @param alphaDirection  durée de l'impulsion sur l'axe alpha en milliseconde  
// @param deltaDirection  direction de l'impulsion sur l'axe delta N ,S  
// @param deltaDuration   durée de l'impulsion sur l'axe delta en milliseconde  
// @return  0 = ,  -1= erreur
//-------------------------------------------------------------
void CTelsimu::radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration,
   abaudela::Direction deltaDirection, double deltaDuration)
{
   try {
      mytel->radec_guide_pulse_duration(alphaDirection, alphaDuration, deltaDirection, deltaDuration);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_sendPulseDuration error=%s", e.what());
   }
}

//-------------------------------------------------------------
// envoie une impulsion en ascension droite et en declinaison
// avec une distance donnee en arcseconde   
//
// @param tel   pointeur structure telprop
// @param alphaDirection direction de l'impulsion sur l'axe alpha E, W  
// @param alphaDistance  distance de l'impulsion sur l'axe alpha en arcsec
// @param deltaDirection direction de l'impulsion sur l'axe delta N ,S  
// @param deltaDuration  distance de l'impulsion sur l'axe delta en arcsec
// @return  0 = ,  -1= erreur
//-------------------------------------------------------------
void CTelsimu::radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance,
   abaudela::Direction deltaDirection, double deltaDistance)
{
   try {
      mytel->radec_guide_pulse_distance(alphaDirection, alphaDistance, deltaDirection, deltaDistance);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_sendPulseDistance error=%s", e.what());
   }
}

bool CTelsimu::radec_guide_pulse_moving_get() {
   return mytel->radec_guide_pulse_moving_get();
}


bool CTelsimu::radec_slewing_get()
{
   try {
      return mytel->radec_slewing_get();
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecSlewing error=%s", e.what());
   }
}

bool CTelsimu::radec_tracking_get()
{
   try {
      return mytel->radec_tracking_get();
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s", e.what());
   }
}


void CTelsimu::radec_goto(ICoordinates* radec, bool blocking)
{
   try {
      mytel->gotoRadec(radec->getRa(Equinox::NOW), radec->getDec(Equinox::NOW), blocking);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecGoto error=%s", e.what());
   }
}

void CTelsimu::radec_move_start(abaudela::Direction direction, double rate)
{
   try {
      mytel->radec_move_start(direction, rate);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecMove error=%s", e.what());
   }

}

void CTelsimu::radec_move_stop(abaudela::Direction direction)
{
   try {
      mytel->radec_move_stop(direction);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_move_stop error=%s", e.what());
   }
}

IIntArray*  CTelsimu::radec_rate_list_get(int axis)
{
   try {
      return mytel->radec_rate_list_get(axis);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_rate_list_get error=%s", e.what());
   }
}


void CTelsimu::radec_tracking_set(bool tracking)
{
   try {
      mytel->radec_tracking_set(tracking);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s", e.what());
   }
}

bool CTelsimu::refraction_correction_get() {
   return mytel->refraction_correction_get();
}

void CTelsimu::unpark()
{
   try {
      mytel->unpark();
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "unpark error=%s", e.what());
   }
}

//=============================================================================
//  get device name list
//=============================================================================

//IStringArray*  libtel::getAvailableDevice() {
//   CLibtelCommon* tel= NULL;
//   try 
//   {
//      tel = getTelescopeInstance();
//      IStringArray* available = tel->getAvailableDevice();
//      delete tel;
//      return available;
//   }
//   catch (abcommon::IError &exception) 
//   {
//      if (tel != NULL) {
//         delete tel;
//      }
//      // je memorise l'erreur
//      abcommon::setLastError(exception);
//      return NULL;
//   }
//}

SpecificCommand CLibtelCommon::specificCommansList[] = {
   // === Specific commands for that telescope === 
   //{ "get", (Spec_CmdProc *)cmdGetRegisterS },
   //{ "get", dynamic_cast<Spec_CmdProc>(&CTeletel::getRegisterS) },

   //{"set", (Spec_CmdProc *)&CTeletel::cmdAscomcamConnectedSetupDialog},
   /* === Last function terminated by NULL pointers === */
   { NULL, NULL }
};

