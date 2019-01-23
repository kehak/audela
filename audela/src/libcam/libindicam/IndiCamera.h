#pragma once

//#include <indidevapi.h>
//#include <indicom.h>
#include <baseclient.h>
//#include <basedevice.h>

class IndiCamera : public INDI::BaseClient
{
public:
   static IndiCamera * createInstance(const char* deviceName, const char* serverAddress, int serverPort);
   static void releaseInstance(IndiCamera** indiCamera);
   
   IndiCamera();
   ~IndiCamera();

   void connect(const char* cameraName);
   void disconnect();
   
   // camera properties
   const char * getCameraName();
   int getCameraXSize();
   int getCameraYSize();
   int getPixelSizeX();
   int getPixelSizeY();

   void setBinning(int binx, int biny);
   void setFrame(int x, int y , int width, int height);

   void startExposure(double exptime, int shutterindex);
   void stopExposure();
   void abortExposure();
   void readImage(float *p);
   
   void setTemperature();


protected:

   virtual void newDevice(INDI::BaseDevice *dp);
   virtual void removeDevice(INDI::BaseDevice *dp) {}
   virtual void newProperty(INDI::Property *property);
   virtual void removeProperty(INDI::Property *property) {}
   virtual void newBLOB(IBLOB *bp);
   virtual void newSwitch(ISwitchVectorProperty *svp) {}
   virtual void newNumber(INumberVectorProperty *nvp);
   virtual void newMessage(INDI::BaseDevice *dp, int messageID);
   virtual void newText(ITextVectorProperty *tvp) {}
   virtual void newLight(ILightVectorProperty *lvp) {}
   virtual void serverConnected() {}
   virtual void serverDisconnected(int exit_code) {}

private:
   INDI::BaseDevice * mydevice;
   //bool  deviceConnected;
   char cameraName[MAXINDINAME];
   

   INumberVectorProperty* frameProperty;
   INumber* frameX;
   INumber* frameY;
   INumber* frameWidth;
   INumber* frameHeight;
   IBLOB*    imageBlob;

   int getPropertyNumber(const char * vectorName, const char* propertyName);

   //const char *getDefaultName();
   //bool initProperties();
   //bool updateProperties();

   //virtual double getCCDTemperature()=0;
   //virtual double getSetCCDTemperature()=0;
   //virtual void setSetCCDTemperature(double value)=0;
   
   //virtual bool getCoolerOn()=0;
   //virtual void setCoolerOn(bool value)=0;
   //virtual double getCoolerPower()=0;
   
   //virtual char * getName()=0;
   //virtual char * getDescription()=0;
   //virtual int getCameraXSize()=0;
   //virtual int getCameraYSize()=0;
   //virtual int getMaxBinX()=0;
   //virtual int getMaxBinY()=0;
   //virtual double getPixelSizeX()=0;
   //virtual double getPixelSizeY()=0;
   //virtual long getStartX()=0;
   //virtual long getStartY()=0;
   //virtual long getNumX()=0;
   //virtual long getNumY()=0;
   //virtual int hasShutter()=0;

   //virtual void setBinX(short value)=0;
   //virtual void setBinY(short value)=0;
   //virtual void setStartX(long value)=0;
   //virtual void setStartY(long value)=0;
   //virtual void setNumX(long value)=0;
   //virtual void setNumY(long value)=0;

};
