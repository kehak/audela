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

void AscomAstrooptik::radecState(char *result) {
   try {
      int slewing=0,tracking=0,connected=0;
      connected = ( telescopePtr->Connected == VARIANT_TRUE); 
      slewing   = ( telescopePtr->Slewing == VARIANT_TRUE);
      tracking  = ( telescopePtr->Tracking == VARIANT_TRUE);
      sprintf(result,"{connected %d} {slewing %d} {tracking %d}",connected,slewing,tracking);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::radecGoto(double ra, double dec, int blocking) {

   try {
       if (telescopePtr->CanSlew == VARIANT_FALSE) {
         throw std::exception("This telescope can not slew");
      }
      if (blocking==1) {
         telescopePtr->SlewToCoordinates(ra, dec);         
      } else {
         telescopePtr->SlewToCoordinatesAsync(ra, dec);  
      }
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::radecMove(char *direction, double rate) {

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
      if (strcmp(direction,"N")==0) {
         raRate = sideralRate;
         decRate = rate * -1;
      } else if (strcmp(direction,"S")==0) {
         raRate = sideralRate;
         decRate = rate ;
      } else if (strcmp(direction,"E")==0) {
         raRate = rate * -1 + sideralRate;
         decRate = 0;
      } else if (strcmp(direction,"W")==0) {
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

void AscomAstrooptik::radecStop(char *direction) {

   try {
      // je memoris le suivi
     if (strcmp(direction,"N")==0 || strcmp(direction,"S")==0) {
         telescopePtr->MoveAxis(axisSecondary,0);
         telescopePtr->MoveAxis(axisPrimary,0);
      } else if (strcmp(direction,"E")==0 || strcmp(direction,"W")==0) {
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
void AscomAstrooptik::radecPulseGuide(char direction, long duration) {
   
   try {
      GuideDirections ascomDirection;
      switch (direction) {
         case 'N' : 
            ascomDirection = (AstrooptikServer::GuideDirections) 0; // GuideDirections::guideNorth;
            break;
         case 'S' : 
            ascomDirection = (AstrooptikServer::GuideDirections) 1; // GuideDirections::guideSouth;
            break;
         case 'E' : 
            ascomDirection = (AstrooptikServer::GuideDirections) 3; // GuideDirections::guideWest;
            break;
         case 'W' : 
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
         case 'N' : 
            ascomDirection = GuideDirections::guideNorth;
            break;
         case 'S' : 
            ascomDirection = GuideDirections::guideSouth;
            break;
         case 'E' : 
            ascomDirection = GuideDirections::guideEast;
            break;
         case 'W' : 
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
void AscomAstrooptik::radecMotor(int motor) {

   try {
      if (motor==1) {
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

void AscomAstrooptik::getHome(char *ligne) {
   double longitude;
   char ew;
   double latitude;
   double altitude;
   try {
      altitude=telescopePtr->SiteElevation;
      latitude=telescopePtr->SiteLatitude;
      longitude=telescopePtr->SiteLongitude;
      if (longitude>0) {
         ew = 'E';
      } else {
         ew = 'W';
      }
      longitude=fabs(longitude);
      sprintf(ligne,"GPS %f %c %f %f",longitude,ew,latitude,altitude); 
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomAstrooptik::setHome(double longitude,char *ew,double latitude,double altitude) {
   try {
      longitude=fabs(longitude);
      if (strcmp(ew,"W")==0) {
         longitude=-longitude;
      }
      telescopePtr->SiteElevation = altitude;
      telescopePtr->SiteLatitude = latitude;
      telescopePtr->SiteLongitude = longitude;

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
   sprintf( rateString, "RA %d : min=%f  max=%f ", 1, 0, 8);
   strcat(rateList, rateString);
   sprintf( rateString, "DEC %d : min=%f  max=%f ", 1, 0, 8);
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