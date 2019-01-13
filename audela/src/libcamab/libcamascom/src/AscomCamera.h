#pragma once

#include <libcamab/libcamcommon.h> // pour IStringArray

class AscomCamera
{
public:
   static void AscomCamera::setupDialog(const char* deviceName);
   static AscomCamera * AscomCamera::createInstance(const char* deviceName);
   virtual void deleteInstance()=0;
   virtual void connect(bool state)=0;

   virtual double getCCDTemperature()=0;
   virtual double getSetCCDTemperature()=0;
   virtual void setSetCCDTemperature(double value)=0;
   
   virtual bool getCoolerOn()=0;
   virtual void setCoolerOn(bool value)=0;
   virtual double getCoolerPower()=0;
   
   virtual char * getName()=0;
   virtual char * getDescription()=0;
   virtual int getCameraXSize()=0;
   virtual int getCameraYSize()=0;
   virtual int getMaxBinX()=0;
   virtual int getMaxBinY()=0;
   virtual double getPixelSizeX()=0;
   virtual double getPixelSizeY()=0;
   virtual long getStartX()=0;
   virtual long getStartY()=0;
   virtual long getNumX()=0;
   virtual long getNumY()=0;
   virtual int hasShutter()=0;

   virtual void setBinX(short value)=0;
   virtual void setBinY(short value)=0;
   virtual void setStartX(long value)=0;
   virtual void setStartY(long value)=0;
   virtual void setNumX(long value)=0;
   virtual void setNumY(long value)=0;

   virtual void startExposure(double exptime, int shutterindex)=0;
   virtual void stopExposure()=0;
   virtual void abortExposure()=0;
   virtual void readImage(float *p)=0;

   virtual void setupDialog(void)=0;

   static abcommon::CStructArray<abcommon::SAvailable*>*  getAvailableCamera();
   //static void FormatWinMessage(char * szPrefix, HRESULT hr);

};
