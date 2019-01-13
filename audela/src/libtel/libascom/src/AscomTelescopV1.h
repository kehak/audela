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
   void radecState(char *result);
   void radecGoto(double ra, double dec, int blocking);
   void radecMove(char *direction, double rate);
   void radecStop(char *direction);
   void radecMotor(int motor);
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
   AscomTelescopV1(AscomInterfacesLib::ITelescopePtr &telescopePtr);
   AscomInterfacesLib::ITelescopePtr telescopePtr;
};
