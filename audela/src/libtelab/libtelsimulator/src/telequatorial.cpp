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
#include <thread>
#include <chrono>
#include <condition_variable>

#include <libtelab/libtel.h>
#include <libtelab/libtelcommon.h>
using namespace ::abaudela;
#include <abmc.h>
using namespace abmc;

#include "telequatorial.h"

CTelEquatorial::CTelEquatorial()
{  
   m_ra = 0;
   m_dec = 0;
   m_raRate = 10;
   m_decRate = 10;
   m_raPulseMoving = false;
   m_decPulseMoving = false;
}

CTelEquatorial::~CTelEquatorial()
{
}


bool CTelEquatorial::connected_get()
{
     return true;
}



void CTelEquatorial::date_get(IDate* date)
{
      date->set("NOW");
}

void CTelEquatorial::date_set(IDate* date)
{

   if (date->get_jd(Frame::TR) <= 0) {
      throw CError(CError::ErrorInput, "jd null");
   }

}

void CTelEquatorial::home_get(IHome* home)
{
   home->set(0.1423, Sense::EAST, 42.936639237, 2890.5);
}

void CTelEquatorial::home_set(IHome* home)
{
   try {
      //TODO
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "home_set error=%s", e.what());
   }
}

const char* CTelEquatorial::name_get() {
   return "simu bleu";
}

const char* CTelEquatorial::product_get() {
   return "simu product";
}

void CTelEquatorial::park()
{
   try {
      //TODO
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "park error=%s", e.what());
   }
}

double CTelEquatorial::getRa()
{
   return m_ra;
}

double CTelEquatorial::getDec()
{
   return m_dec;
}

void CTelEquatorial::syncRadec(double ra, double dec )
{
   try {
      m_ra = ra;
      m_dec = dec;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecInit error=%s", e.what());
   }
}


void CTelEquatorial::radec_guide_rate_get(double* raRate, double* decRate)
{
   try {
      *raRate = m_raRate;
      *decRate = m_decRate;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_guide_rate_get error=%s", e.what());
   }
}

void CTelEquatorial::radec_guide_rate_set(double raRate, double decRate)
{
   try {
      m_raRate = raRate;
      m_decRate = decRate;

   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_guide_rate_get error=%s", e.what());
   }
}


// simule une pulse en dur�e
void CTelEquatorial::pulseDurationThread(abaudela::Direction direction, double duration) {
   std::this_thread::sleep_for(std::chrono::milliseconds((long)duration));
   switch (direction) {
   case Direction::NORTH:
      m_ra += (duration * m_raRate) / ( 15 *3600 );  // heures =    arsc / (3600  /15 )
      m_raPulseMoving = false;
      break;
   case Direction::SOUTH:
      m_ra -= (duration * m_raRate) / (15 * 3600);  // heures =    arsc / (3600  /15 )
      m_raPulseMoving = false;
      break;
   case Direction::EAST:
      m_dec += (duration * m_decRate) / 3600;  // degres =    arsc / 3600
      m_decPulseMoving = false;
      break;
   case Direction::WEST:
   default:
      m_dec -= (duration * m_decRate) / 3600;  // heures =    arsc / 3600 
      m_decPulseMoving = false;
      break;
   }
}

// simule une pulse en distance
void CTelEquatorial::pulseDistanceThread(abaudela::Direction direction, double distance) {
   switch (direction) {
   case Direction::NORTH:
      std::this_thread::sleep_for(std::chrono::milliseconds((long)(distance/ m_raRate)));
      m_ra += distance / (15 * 3600);  // heures =    arsc / (3600  /15 )
      m_raPulseMoving = false;
      break;
   case Direction::SOUTH:
      std::this_thread::sleep_for(std::chrono::milliseconds((long)(distance / m_raRate)));
      m_ra -= distance / (15 * 3600);  // heures =    arsc / (3600  /15 )
      m_raPulseMoving = false;
      break;
   case Direction::EAST:
      std::this_thread::sleep_for(std::chrono::milliseconds((long)(distance / m_decRate)));
      m_dec += distance / 3600;  // degres =    arsc / 3600
      m_decPulseMoving = false;
      break;
   case Direction::WEST:
   default:
      std::this_thread::sleep_for(std::chrono::milliseconds((long)(distance / m_decRate)));
      m_dec -= distance / 3600;  // heures =    arsc / 3600 
      m_decPulseMoving = false;
      break;
   }
}

//-------------------------------------------------------------
// envoie une impulsion en ascension droite et en declinaison
// avec une duree donne en millisecondes  
//
// @param tel   pointeur structure telprop
// @param alphaDuration   direction de l'impulsion sur l'axe alpha E, W  
// @param alphaDirection  dur�e de l'impulsion sur l'axe alpha en milliseconde  
// @param deltaDirection  direction de l'impulsion sur l'axe delta N ,S  
// @param deltaDuration   dur�e de l'impulsion sur l'axe delta en milliseconde  
// @return  0 = ,  -1= erreur
//-------------------------------------------------------------
void CTelEquatorial::radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration,
   abaudela::Direction deltaDirection, double deltaDuration)
{
   m_raPulseMoving = true;
   m_decPulseMoving = true;
   std::thread(&CTelEquatorial::pulseDurationThread, this, alphaDirection, alphaDuration).detach();
   std::thread(&CTelEquatorial::pulseDurationThread, this, deltaDirection, deltaDuration).detach();

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
void CTelEquatorial::radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance,
   abaudela::Direction deltaDirection, double deltaDistance)
{
   m_raPulseMoving = true;
   m_decPulseMoving = true;
   std::thread(&CTelEquatorial::pulseDistanceThread, this, alphaDirection, alphaDistance).detach();
   std::thread(&CTelEquatorial::pulseDistanceThread, this, deltaDirection, deltaDistance).detach();
}

bool CTelEquatorial::radec_guide_pulse_moving_get() {
   return m_raPulseMoving || m_decPulseMoving;
}


bool CTelEquatorial::radec_slewing_get()
{
   try {
      return false;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecSlewing error=%s", e.what());
   }
}

bool CTelEquatorial::radec_tracking_get()
{
   try {
      return false;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s", e.what());
   }
}


void CTelEquatorial::gotoRadec(double ra, double dec,  bool blocking)
{
   try {
      m_ra = ra;
      m_dec = dec;

   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecGoto error=%s", e.what());
   }
}

void CTelEquatorial::radec_move_start(abaudela::Direction direction, double rate)
{
   try {
      //TODO move
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecMove error=%s", e.what());
   }

}

void CTelEquatorial::radec_move_stop(abaudela::Direction direction)
{
   try {
      //TODO stop
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_move_stop error=%s", e.what());
   }
}

IIntArray*  CTelEquatorial::radec_rate_list_get(int axis)
{
   try {
      CIntArray* rateList = new CIntArray();
      //TODO
      return rateList;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_rate_list_get error=%s", e.what());
   }
}


void CTelEquatorial::radec_tracking_set(bool tracking)
{
   try {
      //TODO set stracking
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s", e.what());
   }
}

bool CTelEquatorial::refraction_correction_get() {
   return false;
}

void CTelEquatorial::unpark()
{
   try {
      //TODO
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "unpark error=%s", e.what());
   }
}
