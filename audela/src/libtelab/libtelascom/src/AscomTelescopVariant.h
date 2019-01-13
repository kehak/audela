#pragma once
#include "ascomtelescop.h"

class AscomTelescopVariant : public AscomTelescop
{
public:
   static AscomTelescop * createInstance(const char* deviceName);
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
   virtual char *  getEquinox();

private:
   IDispatch *telescopePtr;
   AscomTelescopVariant(IDispatch *telescopePtr);
   //ASCOM_DeviceInterfaces::ITelescopeV3Ptr *telescopePtr;
   //AscomTelescopVariant(ASCOM_DeviceInterfaces::ITelescopeV3Ptr *telescopePtr);
   ~AscomTelescopVariant(void);
};
