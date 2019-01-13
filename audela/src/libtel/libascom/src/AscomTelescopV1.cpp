#include <exception>
#include <math.h>
#include "AscomTelescopV1.h"

using namespace AscomInterfacesLib;

AscomTelescopV1 * AscomTelescopV1::createInstance(const char* deviceName) {
   ITelescopePtr telescopePtr = NULL;
   HRESULT hr = telescopePtr.CreateInstance((LPCSTR)deviceName);
   if ( SUCCEEDED(hr) ) {
      AscomTelescopV1 * device = new AscomTelescopV1(telescopePtr);
   
      return device;
   } else {
      return (AscomTelescopV1*) NULL;
   }
}

AscomTelescopV1::AscomTelescopV1(ITelescopePtr &telescopePtr)
{
   this->telescopePtr = telescopePtr;
}

AscomTelescopV1::~AscomTelescopV1(void)
{
   
}

void AscomTelescopV1::deleteInstance() {
   try {
      telescopePtr->Release();
      //telescopePtr = NULL;
      // il ne faut pas que telescopePtr=NULL car CoUninitialize() essaie de la supprimer
      CoUninitialize(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }  
}

void AscomTelescopV1::connect(bool state) {
   try {
      telescopePtr->Connected = state;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   } 
}

void AscomTelescopV1::connectedSetupDialog(void) {
   try {
      telescopePtr->SetupDialog(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV1::radecInit(double ra, double dec) {

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

void AscomTelescopV1::radecState(char *result) {
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

void AscomTelescopV1::radecGoto(double ra, double dec, int blocking) {

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

void AscomTelescopV1::radecMove(char *direction, double rate) {

   try {
      if (telescopePtr->CanMoveAxis(AscomInterfacesLib::axisPrimary) == VARIANT_FALSE) {
         throw std::exception("This telescope can not move RA axis");
      }
      if (telescopePtr->CanMoveAxis(AscomInterfacesLib::axisSecondary)  == VARIANT_FALSE) {
         throw std::exception("This telescope can not move DEC axis");
      }
      
      IAxisRates *axisRates = telescopePtr->AxisRates(AscomInterfacesLib::axisPrimary);
      //long nbRate = axisRates->GetCount();
      IRate * itemRate = axisRates->GetItem(1);
      double ascomRate = (itemRate->GetMaximum() - itemRate->GetMinimum())* rate + itemRate->GetMinimum();


      if (strcmp(direction,"N")==0) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,ascomRate);         
      } else if (strcmp(direction,"S")==0) {
         rate *= -1;
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,ascomRate);
      } else if (strcmp(direction,"E")==0) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,ascomRate);
      } else if (strcmp(direction,"W")==0) {
         rate *= -1;
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,ascomRate);
      }
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV1::radecStop(char *direction) {

   try {
     if (strcmp(direction,"N")==0 || strcmp(direction,"S")==0) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,0);
      } else if (strcmp(direction,"E")==0 || strcmp(direction,"W")==0) {
         telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,0);
      } else {
         telescopePtr->AbortSlew();
         //telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,0);
         //telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,0);
         // je restaure la vitesse de suivi
         //telescopePtr->MoveAxis(AscomInterfacesLib::axisPrimary,telescopePtr->TrackingRate);
         //telescopePtr->MoveAxis(AscomInterfacesLib::axisSecondary,telescopePtr->TrackingRate);
      }
       // j'active le suivi sideral
      telescopePtr->Tracking = true;
      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV1::radecMotor(int motor) {

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

double AscomTelescopV1::getRa() {
   try {
      return telescopePtr->RightAscension;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomTelescopV1::getDec() {
   try {
      return telescopePtr->Declination;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomTelescopV1::getUTCDate() {
   try {
      return telescopePtr->UTCDate;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV1::setUTCDate(double date) {
   try {
      telescopePtr->UTCDate = date;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomTelescopV1::getHome(char *ligne) {
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

void AscomTelescopV1::setHome(double longitude,char *ew,double latitude,double altitude) {
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

void AscomTelescopV1::getRateList(char * rateList) {
   try {
        
      strcpy(rateList, "");
      IAxisRates *axisRates = telescopePtr->AxisRates(AscomInterfacesLib::axisPrimary);
      long nbRate = axisRates->GetCount();
      for( long i= 1 ; i<= nbRate; i++ ) {
         char rateString[255];
         IRate * itemRate = axisRates->GetItem(1);
         sprintf( rateString, "RA %d : min=%f  max=%f ", i, itemRate->GetMinimum(), itemRate->GetMaximum());
         strcat(rateList, rateString);
      }

      axisRates = telescopePtr->AxisRates(AscomInterfacesLib::axisSecondary);
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

/**
 *  retourne l'equinoxe des corrdonnées utilisée par la monture
 *  @return "NOW" ou "J2000.0"
 */
char *  AscomTelescopV1::getEquinox() {
   return "NOW";
}
