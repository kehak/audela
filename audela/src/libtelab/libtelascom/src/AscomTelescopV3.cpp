
#include <exception>
#include <math.h>
//#include "StdString.h" // pour A2COL, OLE2A
#include "AscomTelescopV3.h"
using namespace ASCOM_DeviceInterfaces;


AscomTelescop * AscomTelescopV3::createInstance(const char* deviceName) {

   /*
   CLSID CLSID_chooser;
   IDispatch *pChooserDisplay = NULL;
   // Find the ASCOM Chooser
	// First, go into the registry and get the CLSID of it based on the name
	if(FAILED(CLSIDFromProgID(L"AstrooptikServer.Telescope", &CLSID_chooser))) {
		return (AscomTelescop*) NULL;
	}
	// Next, create an instance of it and get another needed ID (dispid)
	if(FAILED(CoCreateInstance(CLSID_chooser,NULL,CLSCTX_SERVER,IID_IDispatch,(LPVOID *)&pChooserDisplay))) {
		return (AscomTelescop*) NULL;
	}
   */

   /*
   USES_CONVERSION;     // pour A2COLE, OLE2A
   LPCOLESTR oleDeviceName = A2COLE(deviceName);
   CLSID CLSID_chooser;

   HRESULT hr = NULL ;
   hr = CLSIDFromProgID(oleDeviceName, &CLSID_chooser);
	if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "CLSIDFromProgID");
      FormatWinMessage(message, hr);
		return (AscomTelescop*) NULL;
	}
   ITelescopeV3Ptr telescopeV3Ptr;
   hr = CoCreateInstance(CLSID_chooser,NULL,CLSCTX_SERVER,IID_IDispatch,(LPVOID*)&telescopeV3Ptr);
   */

   
   ITelescopeV3Ptr telescopeV3Ptr;
   HRESULT hr = telescopeV3Ptr.CreateInstance((LPCSTR)deviceName);
   
   if ( SUCCEEDED(hr) ) {
      AscomTelescop * device = new AscomTelescopV3(telescopeV3Ptr);
      return device;
   } else {
      char message[1024];
      strcpy(message, "createInstance");
      FormatWinMessage(message, hr);
      return (AscomTelescop*) NULL;
   }
}

AscomTelescopV3::AscomTelescopV3(ITelescopeV3Ptr &telescopeV3Ptr)
{
   this->telescopePtr = telescopeV3Ptr;
}

AscomTelescopV3::~AscomTelescopV3(void)
{
   
}

void AscomTelescopV3::deleteInstance() {
   try {
      telescopePtr->Connected = false;
      // Dispose the late-bound interface, if needed. 
      // Will release it via COM if it is a COM object,
      // else if native .NET will just dereference it for GC. 
      telescopePtr->Dispose();
      //telescopePtr = NULL;
      // il ne faut pas que telescopePtr soit NULL car CoUninitialize() essaie de supprimer l'objet
      // pointé par cette variable
      CoUninitialize(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::connect(bool state) {
   try {
      telescopePtr->Connected = state;
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::connectedSetupDialog(void) {
  try {
      telescopePtr->SetupDialog(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }   
}

void AscomTelescopV3::radecInit(double ra, double dec) {

   try {
      if ( telescopePtr->CanSync == false ) {
         throw std::exception("This telescope can not synchonize");
      }
      HRESULT hr = telescopePtr->SyncToCoordinates(ra,dec);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomTelescopV3::connected() {
   try {
      return telescopePtr->Connected == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomTelescopV3::radecSlewing() {
   try {
      return telescopePtr->Slewing == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomTelescopV3::radecTracking() {
   try {
      return telescopePtr->Tracking == VARIANT_TRUE;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::radecGoto(double ra, double dec, bool blocking) {

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


void AscomTelescopV3::radecMove(abaudela::Direction direction, double rate) {

   try {
      if (telescopePtr->CanMoveAxis(TelescopeAxes_axisPrimary) == VARIANT_FALSE) {
         throw std::exception("This telescope can not move RA axis");
      }
      if (telescopePtr->CanMoveAxis(TelescopeAxes_axisSecondary)  == VARIANT_FALSE) {
         throw std::exception("This telescope can not move DEC axis");
      }
      
      IAxisRatesPtr axisRates = telescopePtr->AxisRates(TelescopeAxes_axisPrimary);
      long nbRate = axisRates->GetCount();
      IRatePtr itemRate = axisRates->GetItem(1);
      double ascomRate = (itemRate->GetMaximum() - itemRate->GetMinimum())* rate + itemRate->GetMinimum();

      if (direction==abaudela::Direction::NORTH) {
         telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,ascomRate);         
      } else if (direction==abaudela::Direction::SOUTH) {
         rate *= -1;
         telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,ascomRate);
      } else if (direction==abaudela::Direction::EAST) {
         telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,ascomRate);
      } else if (direction==abaudela::Direction::WEST) {
         rate *= -1;
         telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,ascomRate);
      }
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::radecStop(abaudela::Direction direction) {

   try {
     if (direction==abaudela::Direction::NORTH || direction==abaudela::Direction::SOUTH) {
         telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,0);
      } else if (direction==abaudela::Direction::EAST || direction==abaudela::Direction::WEST) {
         telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,0);
      } else {
         telescopePtr->AbortSlew();
         //telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,0);
         //telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,0);
         // je restaure la vitesse de suivi
         //telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,telescopePtr->TrackingRate);
         //telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,telescopePtr->TrackingRate);
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
void AscomTelescopV3::radecPulseGuide(abaudela::Direction direction, long duration) {

   try {
      GuideDirections ascomDirection;
      switch (direction) {
         case abaudela::Direction::NORTH : 
            ascomDirection = GuideDirections_guideNorth;
            break;
         case abaudela::Direction::SOUTH : 
            ascomDirection = GuideDirections_guideSouth;
            break;
         case abaudela::Direction::EAST : 
            ascomDirection = GuideDirections_guideEast;
            break;
         case abaudela::Direction::WEST : 
            ascomDirection = GuideDirections_guideWest;
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

void AscomTelescopV3::radecTracking(bool tracking) {

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

void AscomTelescopV3::getName(char *name) {
   strncpy(name, _com_util::ConvertBSTRToString(telescopePtr->Name),255);
}

double AscomTelescopV3::getRa() {
   try {
      return telescopePtr->RightAscension;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomTelescopV3::getDec() {
   try {
      return telescopePtr->Declination;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomTelescopV3::getUTCDate() {
   try {
      return telescopePtr->UTCDate;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::setUTCDate(double date) {
   try {
      telescopePtr->UTCDate = date;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::getHome(double* longitude, double* latitude, double* elevation) {
   try {
      *longitude=telescopePtr->SiteLongitude;
      *latitude=telescopePtr->SiteLatitude;
      *elevation=telescopePtr->SiteElevation;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::setHome(double longitude, double latitude,double elevation) {
   try {
      telescopePtr->SiteLongitude = longitude;
      telescopePtr->SiteLatitude = latitude;
      telescopePtr->SiteElevation = elevation;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV3::getRateList(char * rateList) {
   try {
        
      strcpy(rateList, "");
      IAxisRates *axisRates = telescopePtr->AxisRates(TelescopeAxes_axisPrimary);
      long nbRate = axisRates->GetCount();
      for( long i= 1 ; i<= nbRate; i++ ) {
         char rateString[255];
         IRate * itemRate = axisRates->GetItem(1);
         sprintf( rateString, "RA %d : min=%f  max=%f ", i, itemRate->GetMinimum(), itemRate->GetMaximum());
         strcat(rateList, rateString);
      }

      axisRates = telescopePtr->AxisRates(TelescopeAxes_axisSecondary);
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

double AscomTelescopV3::getRaGuideRate() {
   return telescopePtr->GuideRateRightAscension;  
}

double AscomTelescopV3::getDecGuideRate(){
   return telescopePtr->GuideRateDeclination;
}


void AscomTelescopV3::setRaGuideRate(double rate) {
   telescopePtr->GuideRateRightAscension = rate;  
}

void AscomTelescopV3::setDecGuideRate(double rate){
   telescopePtr->GuideRateDeclination = rate;
}



/**
 *  retourne l'equinoxe des coordonnées utilisée par la monture
 *  @return "NOW" ou "J2000.0"
 */
char * AscomTelescopV3::getEquinox() {
   return "NOW";
}

/**
*  retourne true si la monture supprote les impulsions de guidage
*/
bool AscomTelescopV3::canPulseGuide() {
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
bool AscomTelescopV3::isPulseGuiding() {
   try {
      return (telescopePtr->IsPulseGuiding == VARIANT_TRUE);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}