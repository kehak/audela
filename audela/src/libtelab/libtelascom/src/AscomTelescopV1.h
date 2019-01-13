#pragma once
#include "ascomtelescop.h"

#import "file:..\..\..\external\lib\AscomMasterInterfaces.tlb" raw_native_types


class AscomTelescopV1 : public AscomTelescop
{
public:
   static AscomTelescopV1 * createInstance(const char* deviceName);
   ~AscomTelescopV1(void);
   void deleteInstance();

   void connect(bool state);
   void connectedSetupDialog(void);
   void radecInit(double ra, double dec);
   bool connected();
   bool radecSlewing();
   bool radecTracking();
   void radecGoto(double ra, double dec, bool blocking);
   void radecMove(abaudela::Direction direction, double rate);
   void radecStop(abaudela::Direction direction);
   void radecTracking(bool tracking);
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
   AscomTelescopV1(AscomInterfacesLib::ITelescopePtr &telescopePtr);
   AscomInterfacesLib::ITelescopePtr telescopePtr;
};
