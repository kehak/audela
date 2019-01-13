
#include <exception>
#include <math.h>

#include "StdString.h" // pour A2COL, OLE2A

#include "AscomTelescopV2.h"
using namespace AscomInterfacesLib;


AscomTelescop * AscomTelescopV2::createInstance(const char* deviceName) {

   ITelescopePtr telescopeV2Ptr;
   HRESULT hr = telescopeV2Ptr.CreateInstance((LPCSTR)deviceName);
   
   if ( SUCCEEDED(hr) ) {
      AscomTelescop * device = new AscomTelescopV2(telescopeV2Ptr);
      return device;
   } else {
      char message[1024];
      strcpy(message, "createInstance");
      FormatWinMessage(message, hr);
      return (AscomTelescop*) NULL;
   }
}

AscomTelescopV2::AscomTelescopV2(ITelescopePtr &telescopeV2Ptr)
{
   this->telescopePtr = telescopeV2Ptr;
}

AscomTelescopV2::~AscomTelescopV2(void)
{
   
}

void AscomTelescopV2::deleteInstance() {
   try {
      // je supprime l'objet COM
      telescopePtr->Release();
      //telescopePtr = NULL;
      // il ne faut pas que telescopePtr soit NULL car CoUninitialize() essaie de supprimer l'objet
      // pointé par cette variable
      CoUninitialize(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV2::connect(bool state) {
   try {
      telescopePtr->Connected = state;
      
      // je fixe la vitesse dde PulseGuide (en degrés par secondes)
      //  10 arsec / seconde =  10 / (3600)
      double raGuideRate =telescopePtr->GuideRateRightAscension ;
      double decGuideRate =telescopePtr->GuideRateDeclination ;
      

     
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV2::connectedSetupDialog(void) {
  try {
      telescopePtr->SetupDialog(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }   
}

void AscomTelescopV2::radecInit(double ra, double dec) {

   try {
      if ( telescopePtr->CanSync == false ) {
         throw std::exception("This telescope can not synchonize");
      }
      HRESULT hr = telescopePtr->SyncToCoordinates(ra,dec);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomTelescopV2::connected() {
   try {
      return telescopePtr->Connected == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomTelescopV2::radecSlewing() {
   try {
      return telescopePtr->Slewing == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomTelescopV2::radecTracking() {
   try {
      return telescopePtr->Tracking == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}


void AscomTelescopV2::radecGoto(double ra, double dec, bool blocking) {

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


void AscomTelescopV2::radecMove(abaudela::Direction direction, double rate) {

   try {      
      if (direction==abaudela::Direction::NORTH) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,rate);         
      } else if (direction==abaudela::Direction::SOUTH) {
         rate *= -1;
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,rate);
      } else if (direction==abaudela::Direction::EAST) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,rate);
      } else if (direction==abaudela::Direction::WEST) {
         rate *= -1;
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,rate);
      }
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV2::radecStop(abaudela::Direction direction) {

   try {
     if (direction==abaudela::Direction::NORTH || direction==abaudela::Direction::SOUTH) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,telescopePtr->TrackingRate);
      } else if (direction==abaudela::Direction::EAST || direction==abaudela::Direction::WEST) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,telescopePtr->TrackingRate);
      } else {
         telescopePtr->AbortSlew();
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,0);
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,0);
         // je restaure la vitesse de suivi
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,telescopePtr->TrackingRate);
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,telescopePtr->TrackingRate);
      }

       // j'active le suivi sideral
      telescopePtr->Tracking = true;
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

/*
 * envoie une impulsion de guidage
 * @param direction N S E W
 * @param duration  durée d'impulasion en millisecondes
*/
void AscomTelescopV2::radecPulseGuide(abaudela::Direction direction, long duration) {

   try {
      GuideDirections ascomDirection;
      switch (direction) {
         case abaudela::Direction::NORTH : 
            ascomDirection = guideNorth;
            break;
         case abaudela::Direction::SOUTH : 
            ascomDirection = guideSouth;
            break;
         case abaudela::Direction::EAST : 
            ascomDirection = guideEast;
            break;
         case abaudela::Direction::WEST : 
            ascomDirection = guideWest;
            break;
         default :
            throw std::exception("unknown direction");
      }

      //telescopePtr->GuideRateRightAscension = 1.0 / (3600.0) ;
      //telescopePtr->GuideRateDeclination = 1.0 / (3600.0);
      
      telescopePtr->PulseGuide(ascomDirection, (long)duration); 
      
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
   
}

void AscomTelescopV2::radecTracking(bool tracking)  {

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

void AscomTelescopV2::getName(char *name) {
   strncpy(name, _com_util::ConvertBSTRToString(telescopePtr->Name),255);
}

double AscomTelescopV2::getRa() {
   try {
      return telescopePtr->RightAscension;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomTelescopV2::getDec() {
   try {
      return telescopePtr->Declination;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomTelescopV2::getUTCDate() {
   try {
      return telescopePtr->UTCDate;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV2::setUTCDate(double date) {
   try {
      telescopePtr->UTCDate = date;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV2::getHome(double* longitude, double* latitude, double* elevation) {
   try {
      *longitude=telescopePtr->SiteLongitude;
      *latitude=telescopePtr->SiteLatitude;
      *elevation=telescopePtr->SiteElevation;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV2::setHome(double longitude, double latitude,double elevation) {
   try {
      telescopePtr->SiteLongitude = longitude;
      telescopePtr->SiteLatitude = latitude;
      telescopePtr->SiteElevation = elevation;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV2::getRateList(char * rateList) {
   try {
        
      strcpy(rateList, "");
      IAxisRates *axisRates = telescopePtr->AxisRates(axisPrimary);
      long nbRate = axisRates->GetCount();
      for( long i= 1 ; i<= nbRate; i++ ) {
         char rateString[255];
         IRate * itemRate = axisRates->GetItem(1);
         sprintf( rateString, "RA %d : min=%f  max=%f ", i, itemRate->GetMinimum(), itemRate->GetMaximum());
         strcat(rateList, rateString);
      }

      axisRates = telescopePtr->AxisRates(axisSecondary);
      nbRate = axisRates->GetCount();
      for( long i= 1 ; i<= nbRate; i++ ) {
         char rateString[255];
         IRate * itemRate = axisRates->GetItem(1);
         sprintf( rateString, "DEC %d : min=%f  max=%f ", i, itemRate->GetMinimum(), itemRate->GetMaximum());
         strcat(rateList, rateString);
      }

   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomTelescopV2::getRaGuideRate() {
   return telescopePtr->GuideRateRightAscension;  
}

double AscomTelescopV2::getDecGuideRate(){
   return telescopePtr->GuideRateDeclination;
}


void AscomTelescopV2::setRaGuideRate(double rate) {
   telescopePtr->GuideRateRightAscension = rate;  
}

void AscomTelescopV2::setDecGuideRate(double rate){
   telescopePtr->GuideRateDeclination = rate;
}


/**
 *  retourne l'equinoxe des coordonnées utilisée par la monture
 *  @return "NOW" ou "J2000.0"
 */
char * AscomTelescopV2::getEquinox() {
   return "NOW";
}

/**
*  retourne true si la monture supprote les impulsions de guidage
*/
bool AscomTelescopV2::canPulseGuide() {
   try {
      return (telescopePtr->CanPulseGuide == VARIANT_TRUE);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

/**
*  retourne true si la monture est en train d'executer une impulsion
* @return IsPulseGuiding
*/
bool AscomTelescopV2::isPulseGuiding() {
   try {
      return (telescopePtr->IsPulseGuiding == VARIANT_TRUE);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}