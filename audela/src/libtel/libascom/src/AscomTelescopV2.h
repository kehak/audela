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
   char *  getEquinox();

   double getRaGuideRate(); 
   double getDecGuideRate();


private:
   AscomInterfacesLib::ITelescopePtr telescopePtr;
   AscomTelescopV2(AscomInterfacesLib::ITelescopePtr &telescopeV3Ptr);
   ~AscomTelescopV2(void);
};
