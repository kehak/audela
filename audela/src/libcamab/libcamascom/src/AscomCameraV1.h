#pragma once
#include "AscomCamera.h"

// le fichier .tlb est equivalent aux fichiers .h et .lib
#import "file:..\..\..\external\lib\AscomMasterInterfaces.tlb" raw_native_types
// remarque : je ne declare pas ici using pour eviter de l'importer dans tous les sources 
// qui importent ce fichier include.

class AscomCameraV1 : public AscomCamera
{
public:
   static AscomCameraV1 * AscomCameraV1::createInstance(const char* deviceName);
   AscomCameraV1(AscomInterfacesLib::ICameraPtr &cameraPtr);
   ~AscomCameraV1(void);
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

   void startExposure(double exptime, int shutterindex) ;
   void stopExposure();
   void abortExposure();
   void readImage(float *p);
   void setupDialog(void);

private:
   AscomInterfacesLib::ICameraPtr cameraPtr;
   AscomInterfacesLib::IFilterWheelPtr filterWheelPtr;
   int isSimulator;
};
