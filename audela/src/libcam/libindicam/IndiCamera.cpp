
#include <string>
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdexcept>
#include <sys/time.h>   // gettimeofday 
#include <unistd.h>   // for usleep

using namespace std;

#include <fitsio.h>
#include <baseclient.h>
#include <basedevice.h>
//#include <indiproperty.h> 

#include "IndiCamera.h"
#include "libcam/util.h"

//#define MYCCD "Simple CCD"
//#define MYCCD "CCD Simulator"
//#define MYCCD "QSI CCD"

//----------------------------------------------------------------------------------
// create camera instance
//----------------------------------------------------------------------------------
IndiCamera* IndiCamera::createInstance(const char* cameraName, const char* serverAddress, int serverPort) {
   IndiCamera* indiCamera= NULL;
   
   
   try {
         
      if( cameraName == NULL || strlen(cameraName)==0 ) {
         throw std::runtime_error("camera name is empty");
      }
      
      indiCamera = new IndiCamera();
      if (indiCamera == 0) {
         char message[1024];
         sprintf(message, "cannot create new IndiCamera()");
         throw std::runtime_error(message);
      }
      
      indiCamera->setServer(serverAddress, serverPort);
      
      indiCamera->connect(cameraName);
      
      libcam_log(LOG_DEBUG,"IndiCamera::createInstance OK");
            
   } catch (std::exception &ex ) {
      if (indiCamera != NULL) { 
         delete indiCamera;  
         indiCamera = NULL;
      }
      char message[1024];
      sprintf(message, "IndiCamera::createInstance %s \"%s\" %s %d", ex.what() , cameraName, serverAddress, serverPort);
      libcam_log(LOG_DEBUG, message );
      throw std::runtime_error(message);
   }

   return indiCamera;
}

//----------------------------------------------------------------------------------
// release camera instance
//----------------------------------------------------------------------------------
void IndiCamera::releaseInstance(IndiCamera** indiCamera) {
   
   (*indiCamera)->disconnect();
   delete( *indiCamera );
   *indiCamera = NULL;
   libcam_log(LOG_DEBUG,"IndiCamera::releaseInstance OK");
   
}

//----------------------------------------------------------------------------------
// constructor
//----------------------------------------------------------------------------------
IndiCamera::IndiCamera()
{
   mydevice = NULL;   
   imageBlob = NULL;
   readImageDisable = false;
}

//----------------------------------------------------------------------------------
// destructor
//----------------------------------------------------------------------------------
IndiCamera::~IndiCamera()
{

}



//----------------------------------------------------------------------------------
// connect to the server and connect device
//----------------------------------------------------------------------------------
void IndiCamera::connect(const char* cameraName)
{
  
   strncpy(this->cameraName, cameraName, MAXINDINAME);
   
   this->watchDevice(this->cameraName);
   libcam_log(LOG_DEBUG,"IndiCamera::connect watch device started");
   
   if (this->connectServer() == false) {
      char message[1024];
      sprintf(message, "could not connect to server");
      throw std::runtime_error(message);  
   }
   libcam_log(LOG_DEBUG,"IndiCamera::connect server connected");

   //  wait for IndiCamera::newDevice event 
   for(int delay=0;  mydevice == NULL  &&  delay < 120000 ; delay+=100) {
      usleep(100000);  // wait 100 millisecond
      libcam_log(LOG_DEBUG,"IndiCamera::connect wait new device \"%s\" delay=%d ms", this->cameraName, delay);
   }
      
   if (mydevice == NULL) {
      char message[1024];
      sprintf(message, "IndiCamera::connect error mydevice == NULL");
      throw std::runtime_error(message);  
   }
   libcam_log(LOG_DEBUG,"IndiCamera::connect device found=", mydevice->getDeviceName() );
   
   // connect mydevice
   // ATTENTION : we cannot connect device here. We must wait newProperty CONNECTION
   //this->connectDevice(this->cameraName);
   //libcam_log(LOG_DEBUG,"IndiCamera::connect connect device");
   
   // wait newProperty CONNECTION
   for(int delay=0;  !mydevice->isConnected()  &&  delay < 120000 ; delay+=500) {
      usleep(500000);  // wait 500 millisecond
      libcam_log(LOG_DEBUG,"IndiCamera::connect wait CONNECTION event delay=%d ms", delay);
   }
   if( !mydevice->isConnected()) {
      char message[1024];
      sprintf(message, "IndiCamera::connect error device is not connected");
      throw std::runtime_error(message);  
   }
   
   // wait newProperty CCD_FRAME
   for(int delay=0;  !mydevice->getNumber("CCD_FRAME")  &&  delay < 120000 ; delay+=500) {
      usleep(500000);  // wait 500 millisecond
      libcam_log(LOG_DEBUG,"IndiCamera::connect wait CCD_FRAME event delay=%d ms", delay);
   }

   // wait newProperty CCD_INFO
   for(int delay=0;  !mydevice->getNumber("CCD_INFO")  &&  delay < 120000 ; delay+=500) {
      usleep(500000);  // wait 500 millisecond
      libcam_log(LOG_DEBUG,"IndiCamera::connect wait CCD_INFO event delay=%d ms", delay);
   }


   setBLOBMode(B_ALSO, this->cameraName, NULL);

   libcam_log(LOG_DEBUG,"IndiCamera::connect device is connected");
            
}

//----------------------------------------------------------------------------------
// disconnect device and disconnect server
//----------------------------------------------------------------------------------
void IndiCamera::disconnect()
{
   if (mydevice != NULL) {
      this->disconnectDevice(this->cameraName);
   }
   
   this->disconnectServer();
   
}

//----------------------------------------------------------------------------------
// get camera name
//----------------------------------------------------------------------------------
const char * IndiCamera::getCameraName()
{
   return mydevice->getDeviceName();
}


//----------------------------------------------------------------------------------
// get camera horizontal size ( pixels )
//----------------------------------------------------------------------------------
int IndiCamera::getCameraXSize()
{
 //  return this->getPropertyNumber("CCD_FRAME", "WIDTH");
   return this->getPropertyNumber("CCD_INFO", "CCD_MAX_X");
}

//----------------------------------------------------------------------------------
// get camera vertical size ( pixels )
//----------------------------------------------------------------------------------
int IndiCamera::getCameraYSize()
{
//   return this->getPropertyNumber("CCD_FRAME", "HEIGHT");
   return this->getPropertyNumber("CCD_INFO", "CCD_MAX_Y");
}


//----------------------------------------------------------------------------------
// return pixel horizontal size (in micron) 
//----------------------------------------------------------------------------------
int IndiCamera::getPixelSizeX()
{
   return this->getPropertyNumber("CCD_INFO", "CCD_PIXEL_SIZE_X");
}

//----------------------------------------------------------------------------------
// return pixel vertical size (in micron) 
//----------------------------------------------------------------------------------
int IndiCamera::getPixelSizeY()
{
   return this->getPropertyNumber("CCD_INFO", "CCD_PIXEL_SIZE_Y");
}

//----------------------------------------------------------------------------------
// return temperature 
//----------------------------------------------------------------------------------
int IndiCamera::getCCDTemperature()
{
   return this->getPropertyNumber("CCD_TEMPERATURE","CCD_TEMPERATURE_VALUE");
}

//----------------------------------------------------------------------------------
// get number value
//----------------------------------------------------------------------------------
int IndiCamera::getPropertyNumber(const char * vectorName, const char* propertyName)
{
/*    if( mydevice == NULL ) {
 *       char message[1024];
 *       sprintf(message, "IndiCamera::getCameraXSize mydevice=NULL");
 *       throw std::runtime_error(message);  
 *    }
 */
   
   INumberVectorProperty * nvp = mydevice->getNumber(vectorName);
   
   if( nvp != NULL) {
      return IUFindNumber(nvp,propertyName)->value;
   } else {
      char message[1024];
      sprintf(message, "IndiCamera::getPropertyNumber property %s.%s not found", vectorName, propertyName);
      throw std::runtime_error(message);  
   }
}

//----------------------------------------------------------------------------------
// set binning
//----------------------------------------------------------------------------------
void IndiCamera::setBinning(int binx, int biny) 
{
   INumberVectorProperty *binning_number = NULL;

   binning_number = mydevice->getNumber("CCD_BINNING");
   if (binning_number == NULL)  {
      char message[1024];
      sprintf(message, "IndiCamera::setBinning unable to find CCD_BINNING property");
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message);  
   }

   binning_number->np[0].value = binx;
   binning_number->np[1].value = binx;

   sendNewNumber(binning_number);
   libcam_log(LOG_DEBUG,"IndiCamera::setBinning binx=%d biny=%d",binx,biny);
}


//----------------------------------------------------------------------------------
// set frame position and size  (0 based , in binned pixels)
//----------------------------------------------------------------------------------
void IndiCamera::setFrame(int x, int y , int width, int height)
{
   frameX->value = x;
   frameY->value = y;
   frameWidth->value = width;
   frameHeight->value = height;
   sendNewNumber(frameProperty);
   libcam_log(LOG_DEBUG,"IndiCamera::setFrame x=%f y=%f width=%f height=%f", 
      frameX->value, frameY->value, frameWidth->value, frameHeight->value);
}

//----------------------------------------------------------------------------------
//  start exposure
//  @param exptime  in seconds
//----------------------------------------------------------------------------------
void IndiCamera::startExposure(double exptime, int shutterindex) 
{
   INumberVectorProperty *ccd_exposure = NULL;
   ccd_exposure = mydevice->getNumber("CCD_EXPOSURE");

   if (ccd_exposure == NULL)  {
      char message[1024];
      sprintf(message, "IndiCamera::startExposure unable to find CCD_EXPOSURE property");
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message);  
   }

   // reset image result
   imageBlob = NULL; 
   readImageDisable = false;
   
   ccd_exposure->np[0].value = exptime;
   sendNewNumber(ccd_exposure);
   libcam_log(LOG_DEBUG,"IndiCamera::startExposure exptime=%f", exptime);

}

//----------------------------------------------------------------------------------
//  stop exposure
//----------------------------------------------------------------------------------
void IndiCamera::stopExposure() 
{
   ISwitchVectorProperty *switchAbort = NULL;
   switchAbort = mydevice->getSwitch("CCD_ABORT_EXPOSURE");
   if (switchAbort == NULL)  {
      char message[1024];
      sprintf(message, "IndiCamera::stopExposure unable to find CCD_ABORT_EXPOSURE Switch");
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message);  
   }
   
   sendNewSwitch(switchAbort);
   readImageDisable = true;
   libcam_log(LOG_ERROR,"IndiCamera::stopExposure OK" );
}

//----------------------------------------------------------------------------------
//  abort exposure
//----------------------------------------------------------------------------------
void IndiCamera::abortExposure() 
{

   ISwitchVectorProperty *switchAbort = NULL;
   switchAbort = mydevice->getSwitch("CCD_ABORT_EXPOSURE");

   if (switchAbort == NULL)  {
      char message[1024];
      sprintf(message, "IndiCamera::abortExposure unable to find CCD_ABORT_EXPOSURE Switch");
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message);  
   }
   else
   
   sendNewSwitch(switchAbort);
   readImageDisable = true;
   libcam_log(LOG_ERROR,"IndiCamera::abortExposure OK" );
}

//----------------------------------------------------------------------------------
// read image and copy into buffer
// @param pixels  
//----------------------------------------------------------------------------------
void IndiCamera::readImage(float *pixels)
{
   fitsfile *fptr;  // FITS file pointer
   int status = 0;  // CFITSIO status value MUST be initialized to zero!
   
   if (readImageDisable) {
      libcam_log(LOG_DEBUG,"IndiCamera::readImage disable by stopExposure");
      return;
   }

   //  wait 240 000 millisconds for IndiCamera::newBLOB notification 
   for( int delay =0 ; imageBlob == NULL  &&  delay < 240000 ; delay+=100) {
      usleep(100000);  // wait 100 millisecond
      libcam_log(LOG_DEBUG,"IndiCamera::readImage wait blob delay=%d ms", delay);
   }
   
   if( imageBlob == NULL ) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage imageBlob=NULL");
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message);       
   }
   libcam_log(LOG_DEBUG, "IndiCamera::readImage blob ready name=%s label=%s format=%s bloblen=%ld bytes size=%ld" , 
                   imageBlob->name, imageBlob->label, imageBlob->format, imageBlob->bloblen, imageBlob->size );
   
   // open fits reader  
   size_t blobSize = (size_t) imageBlob->bloblen;
   if (fits_open_memfile(&fptr,
            "",
            READONLY,
            &(imageBlob->blob),
            &blobSize,
            0,
            NULL,
            &status) )
   {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_open_memfile error=%d", status);
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message); 
   }   
   libcam_log(LOG_DEBUG, "IndiCamera::readImage fits_open_memfile OK" );
   
   // check HDU type
   int hdutype;
   if (fits_get_hdu_type(fptr, &hdutype, &status) || hdutype != IMAGE_HDU) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_hdu_type error=%d", status);
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message); 
   }
   libcam_log(LOG_DEBUG, "IndiCamera::readImage fits_get_hdu_type OK" );

   // get HDU size naxis, width, height
   int naxis;
   fits_get_img_dim(fptr, &naxis, &status);
   if ( status != 0 || naxis != 2) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_img_dim naxis=%d status=%d", naxis, status);
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message); 
   }   
   
   long imageNaxis[2];
   fits_get_img_size(fptr, 2, imageNaxis, &status);
   if ( status != 0) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_img_size status=%d", status);
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message); 
   } 
   int width, height;
   width = (int) imageNaxis[0];
   height = (int) imageNaxis[1];
   libcam_log(LOG_DEBUG, "IndiCamera::readImage fits_get_img_size width=%d height=%d", width, height );  
   
   int nhdus=0;
   fits_get_num_hdus(fptr,&nhdus,&status);
   if ((nhdus != 1) || (naxis != 2)) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_num_hdus nhdus=%d ", nhdus);
      libcam_log(LOG_ERROR, message);
      throw std::runtime_error(message); 
   }   
   libcam_log(LOG_DEBUG, "IndiCamera::readImage fits_get_num_hdus nhdus=%d", nhdus); 
   
  // Read image
  long fpixel[3] = {1,1,1};
  if (fits_read_pix(fptr, TFLOAT, fpixel, width*height, NULL, pixels, NULL, &status) ) { 
	 char message[1024];
	 sprintf(message, "IndiCamera::readImage fits_read_pix error=%d", status);
	 libcam_log(LOG_ERROR, message);
	 fits_close_file(fptr, &status);
	 throw std::runtime_error(message); 
  }
  libcam_log(LOG_DEBUG, "IndiCamera::readImage fits_read_pix OK");
  
   fits_close_file(fptr, &status);
   libcam_log(LOG_DEBUG, "IndiCamera::readImage OK" );
}


//----------------------------------------------------------------------------------
//
//
void IndiCamera::setCCDTemperature(float desired_temperature)
{
   INumberVectorProperty *ccd_temperature = NULL;

   ccd_temperature = mydevice->getNumber("CCD_TEMPERATURE");

   if (ccd_temperature == NULL)
   {
       libcam_log(LOG_ERROR,"Error: unable to find CCD Simulator CCD_TEMPERATURE property...");
       return;
   }

   ccd_temperature->np[0].value = desired_temperature;
   sendNewNumber(ccd_temperature);
}

//----------------------------------------------------------------------------------
// return pixel horizontal size (in micron) 
//----------------------------------------------------------------------------------
void IndiCamera::newDevice(INDI::BaseDevice *dp)
{
   libcam_log(LOG_DEBUG,"IndiCamera::newDevice \"%s\" ", dp->getDeviceName());
 
   if (!strcmp(dp->getDeviceName(), this->cameraName)) {
       mydevice = dp;
   }
}

//----------------------------------------------------------------------------------
// new property callback 
//----------------------------------------------------------------------------------
void IndiCamera::newProperty(INDI::Property *property)
{
   
   if (strcmp(property->getDeviceName(), this->cameraName) != 0 ) {
      libcam_log(LOG_DEBUG,"IndiCamera::newProperty %s connect device \"%s\" is not require device %s ", property->getName(), property->getDeviceName(), this->cameraName);
      return;
   }      
   
    if (!strcmp(property->getName(), "CONNECTION")) {
       connectDevice(this->cameraName);
       libcam_log(LOG_DEBUG,"IndiCamera::newProperty %s \"%s\"", property->getName() , property->getDeviceName());
       
    } else if (!strcmp(property->getName(), "CCD_FRAME")) {
      frameProperty = property->getNumber();
      frameX = IUFindNumber(frameProperty,"X");
      frameY = IUFindNumber(frameProperty,"Y");
      frameWidth = IUFindNumber(frameProperty,"WIDTH");
      frameHeight = IUFindNumber(frameProperty,"HEIGHT");
      libcam_log(LOG_DEBUG,"IndiCamera::newProperty %s x=%f y=%f width=%f height=%f", 
         property->getName(), frameX->value, frameY->value, frameWidth->value, frameHeight->value);
      
    } else if ( !strcmp(property->getName(), "CCD_TEMPERATURE")) {
      libcam_log(LOG_DEBUG,"IndiCamera::newProperty. CCD_TEMPERATURE");

    } else {
      libcam_log(LOG_DEBUG,"IndiCamera::newProperty %s", property->getName());
    }
   
}

//----------------------------------------------------------------------------------
// new number callback 
//----------------------------------------------------------------------------------
void IndiCamera::newNumber(INumberVectorProperty *nvp)
{
   if (strcmp(nvp->device,this->mydevice->getDeviceName())!=0) {
      return;
   }

   libcam_log(LOG_DEBUG,"IndiCamera::newNumber %s dim=%d", nvp->name, nvp->nnp);
   for (int i=0;i<nvp->nnp;i++) {
         libcam_log(LOG_DEBUG,"IndiCamera::newNumber         %s = %f", nvp->np[i].name, nvp->np[i].value);
   }
	
   // Let's check if we get any new values for CCD_TEMPERATURE
   if (!strcmp(nvp->name, "CCD_TEMPERATURE"))
   {
       libcam_log(LOG_DEBUG,"IndiCamera:newNumber Get CCD Temperature");
   } 
   else if (!strcmp(nvp->name, "CCD_EXPOSURE")) 
   {
       libcam_log(LOG_DEBUG,"IndiCamera:newNumber Get CCD Exposure");
   }
   else if (!strcmp(nvp->name, "CCD_FRAME")) 
   {
       libcam_log(LOG_DEBUG,"IndiCamera:newNumber Get CCD FRAME %f %f %f %f",nvp->np[0].value,nvp->np[1].value,nvp->np[2].value,nvp->np[3].value);
   }

}

//----------------------------------------------------------------------------------
// new message callback 
//----------------------------------------------------------------------------------
void IndiCamera::newMessage(INDI::BaseDevice *dp, int messageID)
{
     libcam_log(LOG_DEBUG,"IndiCamera::newMessage %s", dp->messageQueue(messageID).c_str());
     if (strcmp(dp->getDeviceName(), this->cameraName))
         return;

}

//----------------------------------------------------------------------------------
// new blob callback 
//----------------------------------------------------------------------------------
void IndiCamera::newBLOB(IBLOB *bp)
{
   // check if that is our image, and not one from another camera
   if (strcmp(bp->bvp->device,this->mydevice->getDeviceName())) {
	   return;
   }
   imageBlob = bp;
   libcam_log(LOG_DEBUG,"IndiCamera::newBLOB Received blobName=%s", bp->name);

}
