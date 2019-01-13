
#include <exception>
#include <math.h>
#include "AscomTelescopVariant.h"


#import "Mscorlib.tlb" 
using namespace mscorlib;
#import "file:..\..\..\external\lib\ascomv6net\ASCOM.DeviceInterfaces.tlb" //raw_native_types
using namespace ASCOM_DeviceInterfaces;

#include "StdString.h" // pour A2COL, OLE2A

AscomTelescop * AscomTelescopVariant::createInstance(const char* deviceName) {

   CLSID CLSID_chooser;
   ITelescopeV3Ptr telescopePtr = NULL;
   
   USES_CONVERSION;     // pour A2COLE, OLE2A
   LPCOLESTR oleDeviceName = A2COLE(deviceName);

   HRESULT hr = NULL ;
   hr = CLSIDFromProgID(oleDeviceName, &CLSID_chooser);
	if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "CLSIDFromProgID");
      FormatWinMessage(message, hr);
		return (AscomTelescop*) NULL;
	}

  hr = CoCreateInstance(CLSID_chooser,NULL,CLSCTX_SERVER,IID_IDispatch,(LPVOID *)&telescopePtr);

	if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "CoCreateInstance");
      FormatWinMessage(message, hr);
		return (AscomTelescop*) NULL;
	}

   //ITelescopeV3Ptr b = dynamic_cast<ITelescopeV3*>(telescopePtr); // $$unbox
   //VARIANT_BOOL park = b->CanPark;

   AscomTelescop * device = new AscomTelescopVariant(telescopePtr);
   return device;
}

AscomTelescopVariant::AscomTelescopVariant(IDispatch *telescopePtr)
{
   this->telescopePtr = telescopePtr;
}

AscomTelescopVariant::~AscomTelescopVariant(void)
{
   
}

void AscomTelescopVariant::deleteInstance() {

      
   //try {
   //   // Dispose the late-bound interface, if needed. 
   //   // Will release it via COM if it is a COM object,
   //   // else if native .NET will just dereference it for GC. 
   //   telescopePtr->Dispose();
   //   //telescopePtr = NULL;
   //   // il ne faut pas que telescopePtr soit NULL car CoUninitialize() essaie de supprimer l'objet
   //   // pointé par cette variable
   //   CoUninitialize(); 
   //} catch( _com_error &e ) {
   //   throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   //}

   //telescopePtr->Release();

   OLECHAR *tmp_name = L"Dispose";
   DISPID dispid;

   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "Dispose" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}

   DISPPARAMS dispParms;
	EXCEPINFO excep;
	VARIANT vRes;
   dispParms.cArgs = 0;
	dispParms.rgvarg = NULL;
   dispParms.cNamedArgs = 0;
	dispParms.rgdispidNamedArgs = NULL;
   
   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_PROPERTYGET,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "Dispose" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}  
}

void AscomTelescopVariant::connect(bool state) {
   OLECHAR *tmp_name = L"Connected";
   DISPID dispid;

   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "connect");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}

   DISPPARAMS dispParms;
	VARIANTARG rgvarg[1];			
   EXCEPINFO excep;
	VARIANT vRes;
   rgvarg[0].vt = VT_BOOL;
   rgvarg[0].boolVal = VARIANT_FALSE;
   dispParms.cArgs = 1;
	dispParms.rgvarg = rgvarg;
	//dispParms.cNamedArgs = 0;
	//dispParms.rgdispidNamedArgs = NULL;
   dispParms.cNamedArgs = 1;
	LONG rgdispidNamedArgs = DISPID_PROPERTYPUT;
   dispParms.rgdispidNamedArgs = &rgdispidNamedArgs;
	if ( state ) {
      rgvarg[0].boolVal = VARIANT_TRUE;
   } else {
      rgvarg[0].boolVal = VARIANT_FALSE;
   }
   
   //hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_METHOD,&dispParms,&vRes,&excep, NULL);
   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_PROPERTYPUT,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "connect");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}  
}

void AscomTelescopVariant::connectedSetupDialog(void) {
  /*try {
      telescopePtr->SetupDialog(); 
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   } */  
}

void AscomTelescopVariant::radecInit(double ra, double dec) {

   /*try {
      if ( telescopePtr->CanSync == false ) {
         throw std::exception("This telescope can not synchonize");
      }
      HRESULT hr = telescopePtr->SyncToCoordinates(ra,dec);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }*/
}

void AscomTelescopVariant::radecState(char *result) {
   /*try {
      int slewing=0,tracking=0,connected=0;
      connected = ( telescopePtr->Connected == VARIANT_TRUE); 
      slewing   = ( telescopePtr->Slewing == VARIANT_TRUE);
      tracking  = ( telescopePtr->Tracking == VARIANT_TRUE);
      sprintf(result,"{connected %d} {slewing %d} {tracking %d}",connected,slewing,tracking);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }*/
}

void AscomTelescopVariant::radecGoto(double ra, double dec, int blocking) {

   /*try {
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
   }*/

   OLECHAR *tmp_name ;
   if (blocking==1) {
      tmp_name = L"SlewToCoordinates";
   } else {
      tmp_name = L"SlewToCoordinatesAsync";
   }

   DISPID dispid;
   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "SlewToCoordinates");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}

   DISPPARAMS dispParms;
	VARIANTARG rgvarg[2];			
   EXCEPINFO excep;
	VARIANT vRes;
   rgvarg[1].vt = VT_R8;
   rgvarg[1].dblVal = ra;
   rgvarg[0].vt = VT_R8;
   rgvarg[0].dblVal = dec;
   dispParms.cArgs = 2;
	dispParms.rgvarg = rgvarg;
	dispParms.cNamedArgs = 0;
	dispParms.rgdispidNamedArgs = NULL;
  
   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_METHOD,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "SlewToCoordinates");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}  
}


void AscomTelescopVariant::radecMove(char *direction, double rate) {

   //try {
   //   if (telescopePtr->CanMoveAxis(TelescopeAxes_axisPrimary) == VARIANT_FALSE) {
   //      throw std::exception("This telescope can not move RA axis");
   //   }
   //   if (telescopePtr->CanMoveAxis(TelescopeAxes_axisSecondary)  == VARIANT_FALSE) {
   //      throw std::exception("This telescope can not move DEC axis");
   //   }
   //   
   //   IAxisRates *axisRates = telescopePtr->AxisRates(TelescopeAxes_axisPrimary);
   //   //long nbRate = axisRates->GetCount();
   //   IRate * itemRate = axisRates->GetItem(1);
   //   double ascomRate = (itemRate->GetMaximum() - itemRate->GetMinimum())* rate + itemRate->GetMinimum();

   //   if (strcmp(direction,"N")==0) {
   //      telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,ascomRate);         
   //   } else if (strcmp(direction,"S")==0) {
   //      rate *= -1;
   //      telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,ascomRate);
   //   } else if (strcmp(direction,"E")==0) {
   //      telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,ascomRate);
   //   } else if (strcmp(direction,"W")==0) {
   //      rate *= -1;
   //      telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,ascomRate);
   //   }
   //   
   //} catch( _com_error &e ) {
   //   throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   //}

   //   100%  => 8 d/s = 28800 arc /s =  1920 fois la vitesse siderale
   //   0,052%  =>  15 arsec/s = 0,00417 d/s
   rate = rate *8;

   double raRate;
   double decRate;
   if (strcmp(direction,"N")==0) {
      raRate = 0.00417;
      decRate = rate * -1;
   } else if (strcmp(direction,"S")==0) {
      raRate = 0.00417;
      decRate = rate ;
   } else if (strcmp(direction,"E")==0) {
      raRate = rate * -1 + 0.00417;
      decRate = 0;
   } else if (strcmp(direction,"W")==0) {
      raRate = rate + 0.00417;
      decRate = 0;
   }

   
   OLECHAR *tmp_name = L"MoveAxis";
   DISPID dispid;
   
   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "MoveAxis");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}

   if ( raRate != 0 ) {
      DISPPARAMS dispParms;
	   VARIANTARG rgvarg[2];			
      EXCEPINFO excep;
	   VARIANT vRes;
      rgvarg[1].vt = VT_I4;
      rgvarg[1].lVal = TelescopeAxes_axisPrimary;
      rgvarg[0].vt = VT_R8;
      rgvarg[0].dblVal = raRate;
      dispParms.cArgs = 2;
	   dispParms.rgvarg = rgvarg;
	   dispParms.cNamedArgs = 0;
	   dispParms.rgdispidNamedArgs = NULL;
     
      hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_METHOD,&dispParms,&vRes,&excep, NULL);
      if(FAILED(hr)) {
         char message[1024];
         strcpy(message, "MoveAxis");
         FormatWinMessage(message, hr);
         throw std::exception(message);
	   }  
   }

    if ( decRate != 0 ) {
      DISPPARAMS dispParms;
	   VARIANTARG rgvarg[2];			
      EXCEPINFO excep;
	   VARIANT vRes;
      rgvarg[1].vt = VT_I4;
      rgvarg[1].lVal =  TelescopeAxes_axisSecondary;
      rgvarg[0].vt = VT_R8;
      rgvarg[0].dblVal = decRate;
      dispParms.cArgs = 2;
	   dispParms.rgvarg = rgvarg;
	   dispParms.cNamedArgs = 0;
	   dispParms.rgdispidNamedArgs = NULL;
     
      hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_METHOD,&dispParms,&vRes,&excep, NULL);
      if(FAILED(hr)) {
         char message[1024];
         strcpy(message, "MoveAxis");
         FormatWinMessage(message, hr);
         throw std::exception(message);
	   }  
   }
}

void AscomTelescopVariant::radecStop(char *direction) {

   //try {
   //  if (strcmp(direction,"N")==0 || strcmp(direction,"S")==0) {
   //      telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,0);
   //   } else if (strcmp(direction,"E")==0 || strcmp(direction,"W")==0) {
   //      telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,0);
   //   } else {
   //      telescopePtr->AbortSlew();
   //      //telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,0);
   //      //telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,0);
   //      // je restaure la vitesse de suivi
   //      //telescopePtr->MoveAxis(TelescopeAxes_axisPrimary,telescopePtr->TrackingRate);
   //      //telescopePtr->MoveAxis(TelescopeAxes_axisSecondary,telescopePtr->TrackingRate);
   //   }
   //    // j'active le suivi sideral
   //   telescopePtr->Tracking = true;
   //   
   //} catch( _com_error &e ) {
   //   throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   //}

   int axis;
   int tracking =0;
   if (strcmp(direction,"N")==0) {
      axis = 1;      
      tracking=1;
   } else if (strcmp(direction,"S")==0) {
      axis = 1;
      tracking=1;
   } else if (strcmp(direction,"E")==0) {
      axis = 0;
      tracking=1;
   } else if (strcmp(direction,"W")==0) {
      axis = 0;
      tracking=1;
   }

   double rate = 0; 

   OLECHAR *tmp_name = L"MoveAxis";
   DISPID dispid;
   
   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "MoveAxis");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}

   DISPPARAMS dispParms;
	VARIANTARG rgvarg[2];			
   EXCEPINFO excep;
	VARIANT vRes;
   rgvarg[1].vt = VT_I4;
   rgvarg[1].lVal = 0;
   rgvarg[0].vt = VT_R8;
   rgvarg[0].dblVal = rate;
   dispParms.cArgs = 2;
	dispParms.rgvarg = rgvarg;
	dispParms.cNamedArgs = 0;
	dispParms.rgdispidNamedArgs = NULL;
  
   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_METHOD,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "MoveAxis");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}  

  
   rgvarg[1].vt = VT_I4;
   rgvarg[1].lVal = 1;
   rgvarg[0].vt = VT_R8;
   rgvarg[0].dblVal = rate;
   dispParms.cArgs = 2;
	dispParms.rgvarg = rgvarg;
	dispParms.cNamedArgs = 0;
	dispParms.rgdispidNamedArgs = NULL;
  
   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_METHOD,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "MoveAxis");
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}  

   
   if (tracking == 1 ) {
      OLECHAR *tmp_name = L"Tracking";
      DISPID dispid;
      
      HRESULT hr = NULL ;
      hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
      if(FAILED(hr)) {
         char message[1024];
         strcpy(message, "Tracking ");
         FormatWinMessage(message, hr);
         throw std::exception(message);
	   }

      DISPPARAMS dispParms;
	   VARIANTARG rgvarg[1];			
      EXCEPINFO excep;
	   VARIANT vRes;
      rgvarg[0].vt = VT_BOOL;
      rgvarg[0].boolVal = VARIANT_TRUE;
      dispParms.cArgs = 1;
	   dispParms.rgvarg = rgvarg;
      dispParms.cNamedArgs = 1;
	   LONG rgdispidNamedArgs = DISPID_PROPERTYPUT;
      dispParms.rgdispidNamedArgs = &rgdispidNamedArgs;
      
      hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_PROPERTYPUT,&dispParms,&vRes,&excep, NULL);
      if(FAILED(hr)) {
         char message[1024];
         strcpy(message, "Tracking ");
         FormatWinMessage(message, hr);
         throw std::exception(message);
	   }  

   }
   
}

void AscomTelescopVariant::radecMotor(int motor) {

   //try {
   //   if (motor==1) {
   //      telescopePtr->Tracking = false;
   //   } else {
   //      /* start the motor */
   //      if ( telescopePtr->CanPark == VARIANT_TRUE ) {
   //         if ( telescopePtr->AtPark  == VARIANT_TRUE ) {
   //            telescopePtr->Unpark();
   //         }
   //      }
   //      // j'active le suivi sideral
   //      telescopePtr->Tracking = true;
   //   }      
   //} catch( _com_error &e ) {
   //   throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   //}
}

double AscomTelescopVariant::getRa() {
   OLECHAR *tmp_name = L"RightAscension";
   DISPID dispid;

   
   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "RightAscension" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}

   DISPPARAMS dispParms;
	EXCEPINFO excep;
	VARIANT vRes;
   dispParms.cArgs = 0;
	dispParms.rgvarg = NULL;
   dispParms.cNamedArgs = 0;
	dispParms.rgdispidNamedArgs = NULL;
   
   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_PROPERTYGET,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "RightAscension" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
	}  
   return vRes.dblVal;
}

double AscomTelescopVariant::getDec() {
   OLECHAR *tmp_name = L"Declination";
   DISPID dispid;


   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "Declination" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
   }

   DISPPARAMS dispParms;
   EXCEPINFO excep;
   VARIANT vRes;
   dispParms.cArgs = 0;
   dispParms.rgvarg = NULL;
   dispParms.cNamedArgs = 0;
   dispParms.rgdispidNamedArgs = NULL;

   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_PROPERTYGET,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "Declination" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
   }  
   return vRes.dblVal;
}

double AscomTelescopVariant::getUTCDate() {
   OLECHAR *tmp_name = L"UTCDate";
   DISPID dispid;


   HRESULT hr = NULL ;
   hr = telescopePtr->GetIDsOfNames(IID_NULL, &tmp_name,1,LOCALE_USER_DEFAULT,&dispid);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "UTCDate" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
   }

   DISPPARAMS dispParms;
   EXCEPINFO excep;
   VARIANT vRes;
   dispParms.cArgs = 0;
   dispParms.rgvarg = NULL;
   dispParms.cNamedArgs = 0;
   dispParms.rgdispidNamedArgs = NULL;

   hr = telescopePtr->Invoke(dispid,IID_NULL,LOCALE_USER_DEFAULT,DISPATCH_PROPERTYGET,&dispParms,&vRes,&excep, NULL);
   if(FAILED(hr)) {
      char message[1024];
      strcpy(message, "UTCDate" );
      FormatWinMessage(message, hr);
      throw std::exception(message);
   }  
   return vRes.dblVal;
}

void AscomTelescopVariant::setUTCDate(double date) {
  /* try {
      telescopePtr->UTCDate = date;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }*/
}

void AscomTelescopVariant::getHome(char *ligne) {
   /*double longitude;
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
   }*/
}

void AscomTelescopVariant::setHome(double longitude,char *ew,double latitude,double altitude) {
   /*try {
      longitude=fabs(longitude);
      if (strcmp(ew,"W")==0) {
         longitude=-longitude;
      }
      telescopePtr->SiteElevation = altitude;
      telescopePtr->SiteLatitude = latitude;
      telescopePtr->SiteLongitude = longitude;

   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }*/
}

void AscomTelescopVariant::getRateList(char * rateList) {
   /*try {
        
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
   }*/

}

/**
 *  retourne l'equinoxe des corrdonnées utilisée par la monture
 *  @return "NOW" ou "J2000.0"
 */
char *  AscomTelescopVariant::getEquinox() {
   return "NOW";
}


//==============================================================================

// Global MBCS-to-UNICODE helper function
	PWSTR  StdA2WHelper(PWSTR pw, PCSTR pa, int nChars)
	{
		if (pa == NULL)
			return NULL;
		ASSERT(pw != NULL);
		pw[0] = '\0';
		VERIFY(MultiByteToWideChar(CP_ACP, 0, pa, -1, pw, nChars));
		return pw;
	}

	// Global UNICODE-to_MBCS helper function
	PSTR  StdW2AHelper(PSTR pa, PCWSTR pw, int nChars)
	{
		if (pw == NULL)
			return NULL;
		ASSERT(pa != NULL);
		pa[0] = '\0';
		VERIFY(WideCharToMultiByte(CP_ACP, 0, pw, -1, pa, nChars, NULL, NULL));
		return pa;
	}

