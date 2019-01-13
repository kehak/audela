#pragma once

#include <windows.h>
#include <libtelab/libtel.h>

class AscomTelescop
{
public:
   static AscomTelescop * createInstance(const char* deviceName);
   static void FormatWinMessage(char * szPrefix, HRESULT hr);

   // Methodes virtuelles qui doivent être implémentées par les classes filles
   virtual void deleteInstance()=0;
   virtual bool canPulseGuide()=0;
   virtual bool isPulseGuiding()=0;
   virtual void connect(bool value)=0;
   virtual bool connected()=0;
   virtual void connectedSetupDialog(void)=0;
   virtual void radecInit(double ra, double dec)=0;
   virtual bool radecSlewing()=0;
   virtual bool radecTracking()=0;   
   virtual void radecGoto(double ra, double dec, bool blocking)=0;
   virtual void radecMove(abaudela::Direction direction, double rate)=0;
   virtual void radecStop(abaudela::Direction direction)=0;
   virtual void radecPulseGuide(abaudela::Direction direction, long duration)=0;
   virtual void radecTracking(bool tracking)=0;
   virtual void getName(char *name)=0;
   virtual double getRa()=0;
   virtual double getDec()=0;
   virtual double getUTCDate()=0;
   virtual void setUTCDate(double date)=0;
   virtual void getHome(double* longitude, double* latitude, double* elevation)=0;
   virtual void setHome(double longitude, double latitude, double altitude)=0;
   virtual void getRateList(char * rateList)=0;
   virtual char *  getEquinox()=0;

   virtual double   getRaGuideRate()=0; 
   virtual void     setRaGuideRate(double rate)=0; 
   virtual double   getDecGuideRate()=0;
   virtual void     setDecGuideRate(double rate)=0; 

};
