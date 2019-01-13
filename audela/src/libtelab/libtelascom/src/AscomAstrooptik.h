#pragma once
#include "ascomtelescop.h"

#import "file:..\..\..\external\lib\AstrooptikServer5116.tlb"
//#import "file:..\..\..\external\lib\astroslew\AutoslewVB8.tlb"


class AscomAstrooptik : public AscomTelescop
{
public:
   static AscomAstrooptik * createInstance(const char* deviceName);
   ~AscomAstrooptik(void);
   void deleteInstance();

   void connect(bool state);
   bool connected();
   void connectedSetupDialog(void);
   void radecInit(double ra, double dec);
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
   void setHome(double longitude, double latitude, double elevation);
   void getRateList(char * rateList);
   char * getEquinox();
   bool canPulseGuide();
   bool isPulseGuiding();

   double   getRaGuideRate(); 
   void     setRaGuideRate(double rate); 
   double   getDecGuideRate();
   void     setDecGuideRate(double rate); 
   

private:
   AscomAstrooptik(AstrooptikServer::_TelescopePtr &telescopePtr);
   AstrooptikServer::_TelescopePtr telescopePtr;
   VARIANT_BOOL trackingBeforeMoveAxis;
};
