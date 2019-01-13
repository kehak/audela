/* telescop.c
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
 
 // $Id: CTelAscom.cpp 14291 2017-11-20 12:07:23Z fredvachier $

 /* test
load $::audela_start_dir/libascom.dll
ascom select
*/ 
#include "sysexp.h"

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <stdio.h>
#include <exception>
#include <abcommon.h>
#include <libtelab\libtelcommon.h>
#include "CTelAscom.h"
#include <abmc.h>
using namespace abmc;

/// @ brief  create instance
//
libtel::ILibtel* libtel::createTelescopeInstance(int argc, const char *argv[]) {
   return CLibtelCommon::createTelescopeInstance(new CTelAscom(), argc, argv);
};

void CTelAscom::init(int argc, const char *argv[]) {
  
   try {
      this->m_ascomTelescop = AscomTelescop::createInstance(argv[0]); 
      if (this->m_ascomTelescop == NULL) {
         throw CError(CError::ErrorGeneric, "AscomTelescop::createInstance return NULL");
      }

      // je connecte le telescope
      this->m_ascomTelescop->connect(TRUE);
      //tel->m_rateunity=0.1;           //  deg/s when rate=1   
      this->m_rateunity=1;     // vitesse siderale = 15 arsec/sec = 0.004166667 deg/sec           
      long nbRates = 0;
      
      // je memorise le nom de la camera
      m_name = argv[0];
      // je memorise le nom du produit 
      char product[255];
      m_ascomTelescop->getName(product);
      m_product = product;
      // j'initialise l'equinoxe des coordonnées en fonction du type de télescope.
      strcpy(this->m_equinox,this->m_ascomTelescop->getEquinox());  
      //T->TrackingRates->get_Count( &nbRates);

      m_canPulseGuide = m_ascomTelescop->canPulseGuide() ;

      //je choisi la methode de guidage
      // si le telescope gere les impulsions guidage, je choisis la fonction pulse
      // sinon je laisse la methode par defaut default_pulse() qui utilise move()
      //if ( this->m_ascomTelescop->canPulseGuide() ) {
      //   DRV.sendPulseDuration = radec_sendPulseDuration;
      //   DRV.sendPulseDistance = radec_sendPulseDistance;
      //}

      //home_get(homePosition);

   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "CTelAscom::init: %s",e.what() );
   }

}

void CTelAscom::close() {

   try {
      // je deconnecte le telescope
      this->m_ascomTelescop->connect(FALSE);
      this->m_ascomTelescop->deleteInstance();
      // je supprime l'objet
      delete this->m_ascomTelescop;
   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "close error=%s",e.what() );
   }
}

// ---------------------------------------------------------------------------
// connectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return void
//    
// ---------------------------------------------------------------------------

void CTelAscom::connectedSetupDialog( )
{
   try {
      this->m_ascomTelescop->connectedSetupDialog();
   } catch(  std::exception &e) {
      throw CError(CError::ErrorGeneric, "connectedSetupDialog error=%s",e.what() );
   }
}


// ---------------------------------------------------------------------------
// setupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return 0=OK 1=error
//    
// ---------------------------------------------------------------------------
int CTelAscom::setupDialog(const char * ascomDiverName, char * errorMsg )
{
   HRESULT hr;
   hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);
   if (FAILED(hr)) { 
      sprintf(errorMsg, "Mount %s not found: setupDialog error CoInitializeEx hr=0x%X",ascomDiverName,hr);
      return 1;
   }
   try {
      AscomTelescop * ascomTelescop = AscomTelescop::createInstance(ascomDiverName); 

      if ( ascomTelescop != NULL) {
         ascomTelescop->connectedSetupDialog();
         CoUninitialize();
         return 0; 
      } else {
         sprintf(errorMsg, "setupDialog error CreateInstance hr=%X",hr);
         CoUninitialize();
         return 1;    
      } 
   } catch(  std::exception &e) {
      sprintf(errorMsg, "connectedSetupDialog error=%s",e.what());
      return -1;
   }
}



/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */


bool CTelAscom::connected_get()
{
   try {
      return m_ascomTelescop->connected();
  } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric, "connected error=%s",e.what() );
   }
}

void CTelAscom::radec_coord_get(ICoordinates * radec)
{
   try {
      double ra =  m_ascomTelescop->getRa() * 15;
      double dec = m_ascomTelescop->getDec();
      radec->setRaDec(ra, dec, abmc::Equinox::NOW);
   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_coord_get error=%s",e.what() );
   }
}

void CTelAscom::radec_coord_sync(ICoordinates* radec, abaudela::ITelescope::MountSide MountSide)
{
   try {
      this->m_ascomTelescop->radecInit(radec->getRa(Equinox::NOW) /15, radec->getDec(Equinox::NOW));
   } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecInit error=%s",e.what() );
   }
}

void CTelAscom::radec_guide_rate_get(double* raRate, double* decRate)
{
   try {
      *raRate  = m_ascomTelescop->getRaGuideRate();
      *decRate = m_ascomTelescop->getDecGuideRate();      
   } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_guide_rate_get error=%s",e.what() );
   }
}

void CTelAscom::radec_guide_rate_set(double raRate, double decRate)
{
   try {
      m_ascomTelescop->setRaGuideRate(raRate);
      m_ascomTelescop->setDecGuideRate(decRate);      
   } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_guide_rate_get error=%s",e.what() );
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
void CTelAscom::radec_guide_pulse_duration( abaudela::Direction alphaDirection, double alphaDuration,
                      abaudela::Direction deltaDirection, double deltaDuration)
{
   try {
      if ( alphaDuration > 0 ) { 
         // j'envoie la commande à la monture     
         this->m_ascomTelescop->radecPulseGuide(alphaDirection, (long) alphaDuration);     
      }

      if ( deltaDuration > 0 ) { 
         // j'envoie la commande à la monture     
         this->m_ascomTelescop->radecPulseGuide(deltaDirection, (long) deltaDuration);  
      }          

      // j'attends la fin des impulsions ( ne fonctionne pas avec astrooptik)
      while( this->m_ascomTelescop->isPulseGuiding() == true) {
         sleepms(500);
      }

   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_sendPulseDuration error=%s",e.what() );
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
void CTelAscom::radec_guide_pulse_distance( abaudela::Direction alphaDirection, double alphaDistance,
                      abaudela::Direction deltaDirection, double deltaDistance)
{
   try {
      if ( alphaDistance > 0 ) { 
         // j'envoie la commande à la monture     ( radecPulseRate en arsec/seconde)
         double raGuideRate = this->m_ascomTelescop->getRaGuideRate();
         this->m_ascomTelescop->radecPulseGuide(alphaDirection, (long) (alphaDistance * 1000 / (raGuideRate*3600)));     
      } 


      if ( deltaDistance > 0 ) { 
         // j'envoie la commande à la monture    
         double decGuideRate = this->m_ascomTelescop->getDecGuideRate();
         this->m_ascomTelescop->radecPulseGuide(deltaDirection, (long) (deltaDistance * 1000 / (decGuideRate *3600)));  
      }          

   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_sendPulseDistance error=%s",e.what() );
   }
}


bool CTelAscom::radec_guide_pulse_moving_get() {
   //  ( ne fonctionne pas avec astrooptik)
   return m_ascomTelescop->isPulseGuiding();
}


bool CTelAscom::radec_slewing_get()
{
   try {
      return m_ascomTelescop->radecSlewing();
  } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecSlewing error=%s",e.what() );
   }
}

bool CTelAscom::radec_tracking_get()
{
   try {
      return m_ascomTelescop->radecTracking();
  } catch( std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s",e.what() );
   }
}


void CTelAscom::radec_goto(ICoordinates* radec, bool blocking)
{
   try {
      // je convertis RA en de
      this->m_ascomTelescop->radecGoto(radec->getRa(Equinox::NOW) /15, radec->getDec(Equinox::NOW), blocking);
   } catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecGoto error=%s",e.what() );
   }
}

void CTelAscom::radec_move_start(abaudela::Direction direction, double rate )
{

   //	 Sideral  arcs/sec      deg/s
   //    1	     15	      0.004166667
   //   100	   1500	      0.416666667
   //   200	   3000	      0.833333333
   //   800	   12000	      3.333333333

   //long rate = (long) tel->radec_move_rate ;
   //double rate=this->m_rateunity*this->radec_move_rate;
   //rate = 2;

   try {    
      this->m_ascomTelescop->radecMove(direction, rate);
   } catch (std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecMove error=%s",e.what() );
   }

}

void CTelAscom::radec_move_stop(abaudela::Direction direction)
{
   try {
      this->m_ascomTelescop->radecStop(direction);
   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecStop error=%s",e.what() );
   }
}

void CTelAscom::radec_tracking_set(bool tracking)
{
   try {
      this->m_ascomTelescop->radecTracking(tracking);
   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "radecTracking error=%s",e.what() );
   }
}



int CTelAscom::focus_init()
{
   return 0;
}

int CTelAscom::focus_goto()
{
   return 0;
}

int CTelAscom::focus_move(char *direction)
{
   return 0;
}

int CTelAscom::focus_stop(char *direction)
{
   return 0;
}

int CTelAscom::focus_motor()
{
   return 0;
}

int focus_coord(char *result)
{
   return 0;
}

void CTelAscom::date_get(IDate* date)
{
   IDate* date1900 = NULL; 
   try {
      // sprintf(s,"mc_date2ymdhms [expr [mc_date2jd 1899-12-30T00:00:00]+%f]",tel->params->m_ascomTelescop->getUTCDate()); s
      date1900 = abmc::IDate_createInstance_from_string("1899-12-30T00:00:00");
      double jd = date1900->get_jd(Frame::TR) + m_ascomTelescop->getUTCDate();
      date->set(jd); 
   } catch(std::exception &e) {
      abmc::IDate_deleteInstance(date1900);
      throw CError(CError::ErrorGeneric, "getUTCDate error=%s",e.what() );
   }
}

void CTelAscom::date_set(IDate* date)
{
   IDate* date1900 = NULL; 
   try {
      //sprintf(ss,"$telcmd UTCDate [expr [mc_date2jd [list %d %d %d %d %d %f]]-[mc_date2jd 1899-12-30T00:00:00]]", y,m,d,h,min,s); 
      //m_ascomTelescop->setUTCDate( date->getUTC() );
      IDate* date1900 = abmc::IDate_createInstance_from_string("1899-12-30T00:00:00");
      double utcDate = date->get_jd(Frame::TR) - date1900->get_jd(Frame::TR);
      abmc::IDate_deleteInstance(date1900);

   } catch(std::exception &e) {
      if( date1900 != NULL) {
         abmc::IDate_deleteInstance(date1900);
      }

      throw CError(CError::ErrorGeneric, "setUTCDate error=%s",e.what() );
   }
}

void CTelAscom::home_get(IHome* home)
{
   try {
      double longitude;
      double latitude;
      double elevation;
      m_ascomTelescop->getHome(&longitude, &latitude, &elevation);
      Sense ew = Sense::EAST;
      if (longitude>0) {
         ew = Sense::EAST;
      } else {
         ew = Sense::WEST;
      }
      longitude=fabs(longitude);
      home->set(longitude, ew, latitude, elevation);
   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "getHome error=%s",e.what() );
   }
}

void CTelAscom::home_set(IHome* home)
{
   try {      
      double longitude=fabs(home->get_longitude(Frame::TR) );
      if (home->get_sense(Frame::TR)==Sense::WEST) {
         longitude=-longitude;
      }
      this->m_ascomTelescop->setHome(longitude, home->get_latitude(Frame::TR) , home->get_altitude(Frame::TR) );
   } catch(std::exception &e ) {
      throw CError(CError::ErrorGeneric, "getHome error=%s",e.what() );
   }
}

void CTelAscom::park( ) {
   try {      
      throw CError(CError::ErrorGeneric, "NOT IMPLEMENTED" );
   } catch(std::exception &e ) {
      throw CError(CError::ErrorGeneric, "park error=%s",e.what() );
   }

}

IIntArray*  CTelAscom::radec_rate_list_get(int axis)
{
   try {
      CIntArray* rateList = new CIntArray();
      return rateList;
      //this->m_ascomTelescop->getRateList(ligne);
   } catch(std::exception &e) {
      throw CError(CError::ErrorGeneric, "radec_rate_list_get error=%s",e.what() );
   }
}

bool CTelAscom::refraction_correction_get() {
   return false;
}

void CTelAscom::unpark( ) {
   try {      
      throw CError(CError::ErrorGeneric, "NOT IMPLEMENTED" );
   } catch(std::exception &e ) {
      throw CError(CError::ErrorGeneric, "unpark error=%s",e.what() );
   }

}


// ---------------------------------------------------------------------------
///@brief affiche la fenetre de configuration fournie par le driver de la camera
//
// @return SPEC_OK
//
int cmdTelConnectedSetupDialog(CTelAscom* tel, int argc, const char *argv[])
{
   const char* ascomDiverName = argv[2];
   HRESULT hr;
   hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);
   if (FAILED(hr)) { 
      throw CError(CError::ErrorGeneric, "cmdTelConnectedSetupDialog error CoInitializeEx hr=0x%X",ascomDiverName,hr);
   }

   AscomTelescop * ascomTelescop = AscomTelescop::createInstance(ascomDiverName); 
   if ( ascomTelescop == NULL) {
      CoUninitialize();
      throw CError(CError::ErrorGeneric, "Mount %s not found: setupDialog error createInstance hr=0x%X",ascomDiverName,hr);
   } 

   // j'affiche la fenetre Setup
   ascomTelescop->connectedSetupDialog();
   CoUninitialize();
   return SPEC_OK;
}


///@brief specific commands for that telescope
//
SpecificCommand CLibtelCommon::specificCommansList[] = {
    {"setup",  (Spec_CmdProc *)  cmdTelConnectedSetupDialog},
    {NULL, NULL}
};


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

/*
void decimalsymbol(char *strin, char decin, char decout, char *strout)
{
   int len,k;
   char car;
   len=(int)strlen(strin);
   if (len==0) {
      strout[0]='\0';
      return;
   }
   for (k=0;k<len;k++) {
      car=strin[k];
      if (car==decin) {
         car=decout;
      }
      strout[k]=car;
   }
   strout[k]='\0';
}
*/
