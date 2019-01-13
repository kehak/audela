#pragma once
#include "Ascomtelescop.h"

// import de Mscorlib.tlb pour ArrayList
// C4278 warning for mscorblib.tlh produced by Visual C++ type 
// library importer . You can safely ignore such warning . 
// You could then restore the default handling 
#pragma warning ( disable : 4278 )
#import  "Mscorlib.tlb"  // pour ArrayList
using namespace mscorlib;
#pragma warning ( default : 4278 )

#import "file:..\..\..\external\lib\ASCOM.DeviceInterfaces.tlb" //raw_native_types

class AscomTelescopV3 : public AscomTelescop
{
public:
   static AscomTelescop * createInstance(const char* deviceName);
   void deleteInstance();

   bool canPulseGuide();
   bool isPulseGuiding();
   void connect(bool state);
   void connectedSetupDialog(void);
   void radecInit(double ra, double dec);
   bool connected();
   bool radecSlewing();
   bool radecTracking();
   void radecGoto(double ra, double dec, bool blocking);
   void radecMove(abaudela::Direction direction, double rate);
   void radecStop(abaudela::Direction direction);
   void radecPulseGuide(abaudela::Direction direction, long alphaDistance);
   void radecTracking(bool tracking);
   void getName(char *name);
   double getRa();
   double getDec();
   double getUTCDate();
   void setUTCDate(double date);
   void getHome(double* longitude, double* latitude, double* elevation);
   void setHome(double longitude, double latitude, double altitude);
   void getRateList(char * rateList);
   char *  getEquinox();

   double   getRaGuideRate(); 
   void     setRaGuideRate(double rate); 
   double   getDecGuideRate();
   void     setDecGuideRate(double rate); 


private:
   ASCOM_DeviceInterfaces::ITelescopeV3Ptr telescopePtr;
   AscomTelescopV3(ASCOM_DeviceInterfaces::ITelescopeV3Ptr &telescopeV3Ptr);
   ~AscomTelescopV3(void);
};
