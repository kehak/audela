#pragma once
#include "ascomtelescop.h"


// import des header"C" ASCOM
#import "file:..\..\..\external\lib\AscomMasterInterfaces.tlb"


class AscomTelescopV2 : public AscomTelescop
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
   AscomInterfacesLib::ITelescopePtr telescopePtr;
   AscomTelescopV2(AscomInterfacesLib::ITelescopePtr &telescopeV3Ptr);
   ~AscomTelescopV2(void);
};
