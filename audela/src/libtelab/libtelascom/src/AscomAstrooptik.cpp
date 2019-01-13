#include <exception>
#include <math.h>
#include <comdef.h>
#include "AscomAstrooptik.h"


using namespace AstrooptikServer;

AscomAstrooptik * AscomAstrooptik::createInstance(const char* deviceName) {
   _TelescopePtr telescopePtr = NULL;
   HRESULT hr = telescopePtr.CreateInstance((LPCSTR)deviceName);
   if ( SUCCEEDED(hr) ) {
      AscomAstrooptik * device = new AscomAstrooptik(telescopePtr);
   
      return device;
   } else {
      return (AscomAstrooptik*) NULL;
   }
}

AscomAstrooptik::AscomAstrooptik(_TelescopePtr &telescopePtr)
{
   this->telescopePtr = telescopePtr;
}

AscomAstrooptik::~AscomAstrooptik(void)
{
   
}

void AscomAstrooptik::deleteInstance() {
   try {
      telescopePtr->Release();
      // il ne faut pas que telescopePtr=NULL car CoUninitialize() essaie de la supprimer
      //telescopePtr = NULL;
      CoUninitialize(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }  
}

void AscomAstrooptik::connect(bool state) {
   try {
      telescopePtr->Connected = state;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   } 
}

void AscomAstrooptik::connectedSetupDialog(void) {
   try {
      telescopePtr->SetupDialog(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::radecInit(double ra, double dec) {

   try {
      if ( telescopePtr->CanSync == false ) {
         throw std::exception("This telescope can not synchonize");
      }
      HRESULT hr = telescopePtr->SyncToCoordinates(ra,dec);
   } catch( _com_error &e ) {
      char message[1024];
      sprintf(message, "mytel_radec_init error=%s",_com_util::ConvertBSTRToString(e.Description()));
      throw std::exception(message);
   }
}

bool AscomAstrooptik::connected() {
   try {
      return telescopePtr->Connected == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomAstrooptik::radecSlewing() {
   try {
      return telescopePtr->Slewing == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomAstrooptik::radecTracking() {
   try {
      return telescopePtr->Tracking == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::radecGoto(double ra, double dec, bool blocking) {

   try {
       if (telescopePtr->CanSlew == VARIANT_FALSE) {
         throw std::exception("This telescope can not slew");
      }
      if (blocking) {
         telescopePtr->SlewToCoordinates(ra, dec);         
      } else {
         telescopePtr->SlewToCoordinatesAsync(ra, dec);  
      }
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::radecMove(abaudela::Direction direction, double rate) {

   try {
      // comme le MoveAxis interromp le suivi, je force un deplacement en ra 
      // pour compenser le suivi pendant le mouvement
      double sideralRate;
      this->trackingBeforeMoveAxis = telescopePtr->Tracking;
      if (trackingBeforeMoveAxis) {
         sideralRate = 0.004178273;  // = 360° / 23h 56 mn
      } else {
         sideralRate = 0;
      }

      double raRate;
      double decRate;
      if (direction==abaudela::Direction::NORTH) {
         raRate = sideralRate;
         decRate = rate * -1;
      } else if (direction==abaudela::Direction::SOUTH) {
         raRate = sideralRate;
         decRate = rate ;
      } else if (direction==abaudela::Direction::EAST) {
         raRate = rate * -1 + sideralRate;
         decRate = 0;
      } else if (direction==abaudela::Direction::WEST) {
         raRate = rate + sideralRate;
         decRate = 0;
      }

      if ( raRate != 0 ) {
         //  raRate en degrés/seconde
         telescopePtr->MoveAxis(axisPrimary,raRate); 
      }
      if ( decRate != 0 ) {
         //  decRate en degrés/seconde
         telescopePtr->MoveAxis(axisSecondary,decRate); 
      }
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
   
}

void AscomAstrooptik::radecStop(abaudela::Direction direction) {

   try {
      // je memoris le suivi
     if (direction==abaudela::Direction::NORTH || direction==abaudela::Direction::SOUTH) {
         telescopePtr->MoveAxis(axisSecondary,0);
         telescopePtr->MoveAxis(axisPrimary,0);
      } else if (direction==abaudela::Direction::EAST || direction==abaudela::Direction::WEST) {
         telescopePtr->MoveAxis(axisPrimary,0);
      } else {
         telescopePtr->AbortSlew();
      }
      // je rétablis dans l'etat intial
      telescopePtr->Tracking = this->trackingBeforeMoveAxis;
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
   
}

/*
 * envoie une impulsion de guidage
 * @param direction N S E W
 * @param duration  durée en milliseconde
 *
 * @return void
*/
void AscomAstrooptik::radecPulseGuide(abaudela::Direction direction, long duration) {
   
   try {
      GuideDirections ascomDirection;
      switch (direction) {
         case abaudela::Direction::NORTH : 
            ascomDirection = (AstrooptikServer::GuideDirections) 0; // GuideDirections::guideNorth;
            break;
         case abaudela::Direction::SOUTH : 
            ascomDirection = (AstrooptikServer::GuideDirections) 1; // GuideDirections::guideSouth;
            break;
         case abaudela::Direction::EAST : 
            ascomDirection = (AstrooptikServer::GuideDirections) 3; // GuideDirections::guideWest;
            break;
         case abaudela::Direction::WEST : 
            ascomDirection =(AstrooptikServer::GuideDirections) 2; //  GuideDirections::guideEast;
            break;
         default :
            throw std::exception("unknown direction");
      }
      // duréee en millisecondes
      telescopePtr->PulseGuide(ascomDirection, duration); 
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
   
}

/*
void AscomAstrooptik::radecPulseGuide(char direction, double distance, double rate) {
   
   try {
      GuideDirections ascomDirection;
      switch (direction) {
         case abaudela::Direction::NORTH : 
            ascomDirection = GuideDirections::guideNorth;
            break;
         case abaudela::Direction::SOUTH : 
            ascomDirection = GuideDirections::guideSouth;
            break;
         case abaudela::Direction::EAST : 
            ascomDirection = GuideDirections::guideEast;
            break;
         case abaudela::Direction::WEST : 
            ascomDirection = GuideDirections::guideWest;
            break;
         default :
            throw std::exception("unknown direction");
      }
      
      // duration(ms) = (distance(arcsec)/1000) / ( pulseRate(deg/s) /3600 
      // GetGuideRateRightAscension() n'est pas implementé
      //double duration = distance * 3.6 / telescopePtr->GetGuideRateRightAscension();

      
      // duration(ms) = (distance(arcsec)) * 1000 /  pulseRate(arsec/s)  
      double duration = distance *1000 / rate ;
      telescopePtr->PulseGuide(ascomDirection, (long) duration); 
           
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
   
}


*/
void AscomAstrooptik::radecTracking(bool tracking) {

   try {
      if (tracking==false) {
         telescopePtr->Tracking = false;
      } else {
         /* start the motor */
         if ( telescopePtr->CanPark == VARIANT_TRUE ) {
            if ( telescopePtr->AtPark  == VARIANT_TRUE ) {
               telescopePtr->Unpark();
            }
         }
         // j'active le suivi sideral
         telescopePtr->Tracking = true;
      }      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::getName(char *name) {
   strncpy(name, _com_util::ConvertBSTRToString(telescopePtr->Name),255);
}

double AscomAstrooptik::getRa() {
   try {
      return telescopePtr->RightAscension;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomAstrooptik::getDec() {
   try {
      return telescopePtr->Declination;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomAstrooptik::getUTCDate() {
   try {
      return telescopePtr->UTCDate;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::setUTCDate(double date) {
   try {
      telescopePtr->UTCDate = date;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::getHome(double* longitude, double* latitude, double* elevation) {
   try {
      *longitude=telescopePtr->SiteLongitude;
      *latitude=telescopePtr->SiteLatitude;
      *elevation=telescopePtr->SiteElevation;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::setHome(double longitude, double latitude,double elevation) {
   try {
      telescopePtr->SiteLongitude = longitude;
      telescopePtr->SiteLatitude = latitude;
      telescopePtr->SiteElevation = elevation;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

/**
*  retoune la liste des vitesses disponibles
*   - vitesse RA
*   - vitesses DEc
*   - vitesses de guidage
*/
void AscomAstrooptik::getRateList(char * rateList) {
   strcpy(rateList, "");
   char rateString[255];
   sprintf( rateString, "RA %d : min=%d  max=%d ", 1, 0, 8);
   strcat(rateList, rateString);
   sprintf( rateString, "DEC %d : min=%d  max=%d ", 1, 0, 8);
   strcat(rateList, rateString);
   /*
   _AxisRatesPtr axisRates = telescopePtr->GetTrackingRates();
   short nbRates = axisRates->Count;
   for( int rateNo = 0 ; rateNo < axisRates->Count ; rateNo++) {
      DriveRates driveRates =  axisRates->GetItem(rateNo);
      driveRates->
   }
   */
}

double AscomAstrooptik::getRaGuideRate() {
   return telescopePtr->GuideRateRightAscension;  
}

double AscomAstrooptik::getDecGuideRate(){
   return telescopePtr->GuideRateDeclination;
}


void AscomAstrooptik::setRaGuideRate(double rate) {
   telescopePtr->GuideRateRightAscension = rate;  
}

void AscomAstrooptik::setDecGuideRate(double rate){
   telescopePtr->GuideRateDeclination = rate;
}

/**
 *  retourne l'equinoxe des corrdonnées utilisée par la monture
 *  @return "NOW" ou "J2000.0"
 */
char *  AscomAstrooptik::getEquinox() {
   return "NOW";
}

/**
*  retourne true si la monture supporte les impulsions de guidage
*/
bool AscomAstrooptik::canPulseGuide() {
   try {
      return (telescopePtr->CanPulseGuide == VARIANT_TRUE);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

/**
*  retourne true si la monture est en train d'executer une impulsion
*  ATTENTION : inutilisable car renvoit toujours VARIANT_FALSE .
*/
bool AscomAstrooptik::isPulseGuiding() {
   try {
      return (telescopePtr->IsPulseGuiding == VARIANT_TRUE);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}