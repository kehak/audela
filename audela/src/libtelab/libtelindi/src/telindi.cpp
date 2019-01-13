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

#include "telindi.h"


//
CLibtelCommon* getTelescopeInstance() {
   return new CTelindi();
}

void CTelindi::init(int argc, const char *argv[])
{  


}

void CTelindi::close()
{
   //TODO close
}


bool CTelindi::connected_get()
{
   //TODO 
   return true;
}



void CTelindi::date_get(IDate* date)
{
   try {
      //TODO 
      // je retourne la date courante 
      date->set("NOW");
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "date_get error=%s", e.what());
   }
}

void CTelindi::date_set(IDate* date)
{
   try {
      //TODO

   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "date_set error=%s", e.what());
   }
}

void CTelindi::home_get(IHome* home)
{
   try {
      //TODO

   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "home_get error=%s", e.what());
   }
}

void CTelindi::home_set(IHome* home)
{
   try {
      //TODO
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "home_set error=%s", e.what());
   }
}

void CTelindi::park()
{
   try {
      //TODO
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "park error=%s", e.what());
   }
}

void CTelindi::radec_coord_get(ICoordinates * radec)
{
   try {
      double ra = 0;
      double dec = 0;
      radec->setRaDec(ra, dec, abmc::Equinox::NOW);
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_coord_get error=%s", e.what());
   }
}

void CTelindi::radec_coord_sync(ICoordinates* radec, abaudela::ITelescope::MountSide)
{
   try {

   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecInit error=%s", e.what());
   }
}

void CTelindi::radec_guide_rate_get(double* raRate, double* decRate)
{
   try {
      *raRate = 10;
      *decRate = 10;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_guide_rate_get error=%s", e.what());
   }
}

void CTelindi::radec_guide_rate_set(double raRate, double decRate)
{
   try {

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
void CTelindi::radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration,
   abaudela::Direction deltaDirection, double deltaDuration)
{
   try {

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
void CTelindi::radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance,
   abaudela::Direction deltaDirection, double deltaDistance)
{
   try {
      if (alphaDistance > 0) {
         // j'envoie la commande à la monture     ( radecPulseRate en arsec/seconde)

      }


      if (deltaDistance > 0) {
         // j'envoie la commande à la monture    
      }

      // j'attends la fin des impulsions ( ne fonctionne pas avec astrooptik)

   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_sendPulseDistance error=%s", e.what());
   }
}

// @TODO
bool CTelindi::radec_guide_pulse_moving_get() {
	return false;
}



bool CTelindi::radec_slewing_get()
{
   try {
      return false;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecSlewing error=%s", e.what());
   }
}

bool CTelindi::radec_tracking_get()
{
   try {
      return false;
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s", e.what());
   }
}


void CTelindi::radec_goto(ICoordinates* radec, bool blocking)
{
   try {

   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecGoto error=%s", e.what());
   }
}

void CTelindi::radec_move_start(abaudela::Direction direction, double rate)
{
   try {
      //TODO move
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecMove error=%s", e.what());
   }

}

void CTelindi::radec_move_stop(abaudela::Direction direction)
{
   try {
      //TODO stop
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_move_stop error=%s", e.what());
   }
}

IIntArray*  CTelindi::radec_rate_list_get(int axis)
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


void CTelindi::radec_tracking_set(bool tracking)
{
   try {
      //TODO set stracking
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s", e.what());
   }
}

bool CTelindi::refraction_correction_get() {
   return false;
}

void CTelindi::unpark()
{
   try {
      //TODO
   }
   catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "unpark error=%s", e.what());
   }
}
