#pragma once
#include "AscomCamera.h"


#import "file:..\..\..\external\lib\ASCOM.DeviceInterfaces.tlb" raw_native_types


class AscomCameraV2 : public AscomCamera
{
public:
   static AscomCameraV2 * AscomCameraV2::createInstance(const char* deviceName) ;
   AscomCameraV2(ASCOM_DeviceInterfaces::ICameraV2Ptr &cameraPtr);
   ~AscomCameraV2(void);
   void deleteInstance();
   void connect(bool state);

   double getCCDTemperature();
   double getSetCCDTemperature();
   void setSetCCDTemperature(double value);
   
   bool getCoolerOn();
   void setCoolerOn(bool value);
   double getCoolerPower();
   
   char * getName();
   char * getDescription();
   int getCameraXSize();
   int getCameraYSize();
   int getMaxBinX();
   int getMaxBinY();
   double getPixelSizeX();
   double getPixelSizeY();
   long getStartX();
   long getStartY();
   long getNumX();
   long getNumY();
   int hasShutter();
   
   void setBinX(short value);
   void setBinY(short value);
   void setStartX(long value);
   void setStartY(long value);
   void setNumX(long value);
   void setNumY(long value);

   void startExposure(double exptime, int shutterindex);
   void stopExposure();
   void abortExposure();
   void readImage(float *p);
   void setupDialog(void);

   static abcommon::CStructArray<abcommon::SAvailable*>* getAvailableCamera();
private:
   ASCOM_DeviceInterfaces::ICameraV2Ptr cameraPtr;
};
