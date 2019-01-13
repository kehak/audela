#pragma once

#include <windows.h>

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
   virtual void connectedSetupDialog(void)=0;
   virtual void radecInit(double ra, double dec)=0;
   virtual void radecState(char *result)=0;
   virtual void radecGoto(double ra, double dec, int blocking)=0;
   virtual void radecMove(char *direction, double rate)=0;
   virtual void radecStop(char *direction)=0;
   virtual void radecPulseGuide(char direction, long duration)=0;
   virtual void radecMotor(int motor)=0;
   virtual void getName(char *name)=0;
   virtual double getRa()=0;
   virtual double getDec()=0;
   virtual double getUTCDate()=0;
   virtual void setUTCDate(double date)=0;
   virtual void getHome(char *ligne)=0;
   virtual void setHome(double longitude,char *ew,double latitude,double altitude)=0;
   virtual void getRateList(char * rateList)=0;
   virtual char *  getEquinox()=0;

   virtual double getRaGuideRate()=0; 
   virtual double getDecGuideRate()=0;


};
