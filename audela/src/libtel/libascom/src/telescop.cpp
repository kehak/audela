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
#include "telescop.h"
#include <exception>
#include <libtel/util.h>
#include <AscomTelescop.h>

#ifdef __cplusplus
extern "C" {
#endif


extern void logConsole(struct telprop *tel, char *messageFormat, ...);
 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"ASCOM",    /* telescope name */
    "Ascom",    /* protocol name */
    "ascom",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

struct _PrivateParams {
   AscomTelescop * ascomTelescop;
   int debug;
};


#ifdef __cplusplus
}
#endif


// commande àa lancer pour les tests unitaires.
// load $audela_start_dir/libascom.dll
// ascom select ""

int tel_select(char * productName)
{
   /*
   //CoInitialize(NULL);
   CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);
   
   IChooserPtr chooser = NULL;		
   chooser.CreateInstance(__uuidof(ASCOM_Utilities::Chooser));						   

	if(chooser == NULL)	{
      strcpy(productName, "Error open DriverHelper.Chooser");    
      return -1;
   }

   chooser->put_DeviceType(_com_util::ConvertStringToBSTR("Telescope"));
	_bstr_t  drvrId ;
   drvrId = chooser->Choose(_com_util::ConvertStringToBSTR(productName));
   chooser.Release();	
   CoUninitialize();
   
   if ( drvrId.length() == 0 ) {
      strcpy(productName, "No telescop selected");    
      return 1;
   } else {
      strcpy(productName, drvrId);
      return 0;
   }
   

   //IProfilePtr profile = NULL;		
   //profile.CreateInstance(__uuidof(ASCOM_Utilities::Profile));		
   //struct _ArrayList* deviceList = profile->RegisteredDevices(_com_util::ConvertStringToBSTR("Telescope"));
   //ArrayList^ list = static_cast<ArrayList>( deviceList);
   */
   return 0;
   
}

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage du telescope      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque telescope.   */
/* et sont appelees par libtel.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{
   
   // je cree les variables 
   tel->params = (PrivateParams*) calloc(sizeof(PrivateParams), 1);   
   try {
   
      tel->params->ascomTelescop = AscomTelescop::createInstance(argv[2]); 
      if (tel->params->ascomTelescop == NULL) {
      return 1;
   }

      // je connecte le telescope
      tel->params->ascomTelescop->connect(TRUE);
      //tel->rateunity=0.1;           //  deg/s when rate=1   
      tel->rateunity=1;     // vitesse siderale = 15 arsec/sec = 0.004166667 deg/sec           
      long nbRates = 0;

      tel->params->ascomTelescop->getName(tel_ini[tel->index_tel].name);
      // j'initialise l'equinoxe des coordonnées en fonction du type de télescope.
      strcpy(tel->equinox,tel->params->ascomTelescop->getEquinox());  
      //T->TrackingRates->get_Count( &nbRates);

      //je choisi la methode de guidage
      // si le telescope gere les impulsions guidage, je choisis la fonction mytel_pulse
      // sinon je laisse la methode par defaut default_tel_pulse() qui utilise mytel_move()
      if ( tel->params->ascomTelescop->canPulseGuide() ) {
         TEL_DRV.tel_sendPulseDuration = mytel_radec_sendPulseDuration;
         TEL_DRV.tel_sendPulseDistance = mytel_radec_sendPulseDistance;
      }


      tel_home_get(tel,tel->homePosition);
      return 0;
   } catch( std::exception &e) {
      sprintf(tel->msg, "tel_init error=%s",e.what());
      return 1;
   }
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   return 0;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{

   try {
      // je deconnecte le telescope
      tel->params->ascomTelescop->connect(FALSE);
      tel->params->ascomTelescop->deleteInstance();
      // je supprime l'objet
      delete tel->params->ascomTelescop;
      // je supprime les variables créées par Audela
      if ( tel->params != NULL ) {
         free(tel->params);
         tel->params = NULL;
      }
      return 0;
   } catch(std::exception &e) {
      sprintf(tel->msg, "tel_close error=%s",e.what());
      return -1;
   }
   return 0;
}

// ---------------------------------------------------------------------------
// mytel_connectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return void
//    
// ---------------------------------------------------------------------------

int mytel_connectedSetupDialog(struct telprop *tel )
{
   try {
      tel->params->ascomTelescop->connectedSetupDialog();
   } catch(  std::exception &e) {
      sprintf(tel->msg, "mytel_connectedSetupDialog error=%s",e.what());
      return -1;
   }
   return 0; 
}


// ---------------------------------------------------------------------------
// mytel_setupDialog 
//    affiche la fenetre de configuration fournie par le driver de la monture
// @return 0=OK 1=error
//    
// ---------------------------------------------------------------------------
int mytel_setupDialog(const char * ascomDiverName, char * errorMsg )
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
      sprintf(errorMsg, "mytel_connectedSetupDialog error=%s",e.what());
      return -1;
}
   }


int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return mytel_radec_init(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return mytel_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   return mytel_radec_state(tel,result);
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
   return mytel_radec_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
   return mytel_radec_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
   return mytel_radec_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return mytel_radec_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return mytel_focus_init(tel);
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return mytel_focus_coord(tel,result);
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return mytel_focus_goto(tel);
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return mytel_focus_move(tel,direction);
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
   return mytel_focus_stop(tel,direction);
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return mytel_focus_motor(tel);
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   return mytel_date_get(tel,ligne);
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return mytel_date_set(tel,y,m,d,h,min,s);
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   return mytel_home_get(tel,ligne);
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {PGS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   return mytel_home_set(tel,longitude,ew,latitude,altitude);
}

int tel_get_position_tube(struct telprop *tel)
/* ---------------------------------------------------- */
/* --- called by : tel1 position_tube               --- */
/* ---------------------------------------------------- */
{
	return PT_UNKNOWN;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_radec_init(struct telprop *tel)
{
   try {
      tel->params->ascomTelescop->radecInit(tel->ra0/15,tel->dec0);
   } catch( std::exception &e) {
      sprintf(tel->msg, "mytel_radec_init error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int slewing=0,tracking=0,connected=0;
   try {
      tel->params->ascomTelescop->radecState(result);
  } catch( std::exception &e) {
      sprintf(tel->msg, "mytel_radec_init error=%s",e.what());
      return -1;
   }
   return 0;

}

int mytel_radec_goto(struct telprop *tel)
{
   try {
      // je convertis RA en de
      tel->params->ascomTelescop->radecGoto(tel->ra0/15, tel->dec0, tel->radec_goto_blocking);
   } catch (std::exception &e) {
      sprintf(tel->msg, "mytel_radec_init error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];


   //	 Sideral  arcs/sec      deg/s
   //    1	     15	      0.004166667
   //   100	   1500	      0.416666667
   //   200	   3000	      0.833333333
   //   800	   12000	      3.333333333

   //long rate = (long) tel->radec_move_rate ;
   double rate=tel->rateunity*tel->radec_move_rate;
   //rate = 2;
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));


   try {    
      tel->params->ascomTelescop->radecMove(direc, rate);
      return 0;
   } catch (std::exception &e) {
      sprintf(tel->msg, "mytel_radec_move error=%s",e.what());
      return 1;
   }

   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   if ( direction[0] != 0 ) {
      sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
      strcpy(direc,Tcl_GetStringResult(tel->interp));
   }
   try {
      tel->params->ascomTelescop->radecStop(direc);
   } catch(std::exception &e) {
      sprintf(tel->msg, "mytel_radec_stop error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   try {

      tel->params->ascomTelescop->radecMotor(tel->radec_motor);
   } catch(std::exception &e) {
      sprintf(tel->msg, "mytel_radec_motor error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   char s[1024];
   char ss[1024];

   try {
      sprintf(s,"mc_angle2hms {%f } 360 zero 2 auto string",tel->params->ascomTelescop->getRa() * 15 ); 
      mytel_tcleval(tel,s);
      strcpy(ss,Tcl_GetStringResult(tel->interp));
      sprintf(s,"mc_angle2dms %f 90 zero 1 + string",tel->params->ascomTelescop->getDec()); 
      mytel_tcleval(tel,s);
      sprintf(result,"%s %s",ss,Tcl_GetStringResult(tel->interp));
   } catch(std::exception &e) {
      sprintf(tel->msg, "mytel_radec_coord error=%s",e.what());
      return -1;
   }

   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   char s[1024];
   
   try {
      sprintf(s,"mc_date2ymdhms [expr [mc_date2jd 1899-12-30T00:00:00]+%f]",tel->params->ascomTelescop->getUTCDate()); 
      mytel_tcleval(tel,s);
      sprintf(ligne,"%s",Tcl_GetStringResult(tel->interp));
   } catch(std::exception &e) {
      sprintf(tel->msg, "mytel_date_get error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   char ss[1024];
   try {
      sprintf(ss,"$telcmd UTCDate [expr [mc_date2jd [list %d %d %d %d %d %f]]-[mc_date2jd 1899-12-30T00:00:00]]",
         y,m,d,h,min,s); 
      mytel_tcleval(tel,ss);
      tel->params->ascomTelescop->setUTCDate(atof(Tcl_GetStringResult(tel->interp)));
   } catch(std::exception &e) {
      sprintf(tel->msg, "mytel_date_set error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{

   try {
      tel->params->ascomTelescop->getHome(ligne);
   } catch(std::exception &e) {
      sprintf(tel->msg, "mytel_home_get error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   try {      
      tel->params->ascomTelescop->setHome(longitude, ew, latitude, altitude);
   } catch(std::exception &e ) {
      sprintf(tel->msg, "mytel_home_set error=%s",e.what());
      return -1;
   }
   return 0;
}

int mytel_getRateListe(struct telprop *tel,char *ligne)
{
   
   try {
      tel->params->ascomTelescop->getRateList(ligne);
   } catch(std::exception &e) {
      sprintf(tel->msg, "ratelist error=%s",e.what());
      return -1;
   }
   return 0;
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
int mytel_radec_sendPulseDuration(struct telprop *tel, char alphaDirection, double alphaDuration,
                      char deltaDirection, double deltaDuration)
{
   try {
      if ( alphaDuration > 0 ) { 
         // j'envoie la commande à la monture     
         tel->params->ascomTelescop->radecPulseGuide(alphaDirection, (long) alphaDuration);     
      }

      if ( deltaDuration > 0 ) { 
         // j'envoie la commande à la monture     
         tel->params->ascomTelescop->radecPulseGuide(deltaDirection, (long) deltaDuration);  
      }          

      // j'attends la fin des impulsions ( ne fonctionne pas avec astrooptik)
      while( tel->params->ascomTelescop->isPulseGuiding() == true) {
         libtel_sleep(500);
      }

   } catch(std::exception &e) {
      sprintf(tel->msg, "correct error=%s",e.what());
      return -1;
   }
      
   return 0;
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
int mytel_radec_sendPulseDistance(struct telprop *tel, char alphaDirection, double alphaDistance,
                      char deltaDirection, double deltaDistance)
{
   try {
      if ( alphaDistance > 0 ) { 
         // j'envoie la commande à la monture     ( radecPulseRate en arsec/seconde)
         double raGuideRate = tel->params->ascomTelescop->getRaGuideRate();
         tel->params->ascomTelescop->radecPulseGuide(alphaDirection, (long) (alphaDistance * 1000 / (raGuideRate*3600)));     
      } 


      if ( deltaDistance > 0 ) { 
         // j'envoie la commande à la monture    
         double decGuideRate = tel->params->ascomTelescop->getDecGuideRate();
         tel->params->ascomTelescop->radecPulseGuide(deltaDirection, (long) (deltaDistance * 1000 / (decGuideRate *3600)));  
      }          

      // j'attends la fin des impulsions ( ne fonctionne pas avec astrooptik)
      while( tel->params->ascomTelescop->isPulseGuiding() == true) {
         libtel_sleep(500);
      }

   } catch(std::exception &e) {
      sprintf(tel->msg, "correct error=%s",e.what());
      return -1;
   }
      
   return 0;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_ascom.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD)
   fprintf(f,"# [%d] = %s\n", result, Tcl_GetStringResult(tel->interp));
   fclose(f);
#endif
   return result;
}

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout)
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
