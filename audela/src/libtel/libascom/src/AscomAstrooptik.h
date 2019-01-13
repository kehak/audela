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
   void connectedSetupDialog(void);
   void radecInit(double ra, double dec);
   void radecState(char *result);
   void radecGoto(double ra, double dec, int blocking);
   void radecMove(char *direction, double rate);
   void radecStop(char *direction);
   void radecPulseGuide(char direction, long alphaDistance);
   void radecMotor(int motor);
   void getName(char *name);
   double getRa();
   double getDec();
   double getUTCDate();
   void setUTCDate(double date);
   void getHome(char *ligne);
   void setHome(double longitude,char *ew,double latitude,double altitude);
   void getRateList(char * rateList);
   char * getEquinox();
   bool canPulseGuide();
   bool isPulseGuiding();

   double getRaGuideRate(); 
   double getDecGuideRate();
   

private:
   AscomAstrooptik(AstrooptikServer::_TelescopePtr &telescopePtr);
   AstrooptikServer::_TelescopePtr telescopePtr;
   VARIANT_BOOL trackingBeforeMoveAxis;
};
