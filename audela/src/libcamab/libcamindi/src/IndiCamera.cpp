
//#include <sys/time.h>   // gettimeofday
#include <unistd.h>   // for usleep

#include <string>
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdexcept>	// pour runtime_error

using namespace std;

#include <fitsio.h>
#include <baseclient.h>
#include <basedevice.h>
//#include <indiproperty.h>
#include <libcamab/libcamcommon.h> //pour libcam_log

#include "IndiCamera.h"
using namespace abcommon;

//#define MYCCD "Simple CCD"
//#define MYCCD "CCD Simulator"
//#define MYCCD "QSI CCD"

//----------------------------------------------------------------------------------
// create camera instance
//----------------------------------------------------------------------------------
IndiCamera* IndiCamera::createInstance(const char* cameraName, const char* serverAddress, int serverPort, ILogger *logger) {
   IndiCamera* indiCamera= NULL;

   
   try {
         
      if( cameraName == NULL || strlen(cameraName)==0 ) {
         throw std::runtime_error("camera name is empty");
      }
      
      indiCamera = new IndiCamera();
      indiCamera->m_logger = logger;

      if (indiCamera == 0) {
         char message[1024];
         sprintf(message, "cannot create new IndiCamera()");
         throw std::runtime_error(message);
      }
      
      indiCamera->setServer(serverAddress, serverPort);
      
      indiCamera->connect(cameraName);
      
      indiCamera->m_logger->logDebug("IndiCamera::createInstance OK");
            
   } catch (std::exception &ex ) {
      if (indiCamera != NULL) { 
         delete indiCamera;  
         indiCamera = NULL;
      }
      char message[1024];
      sprintf(message, "IndiCamera::createInstance %s \"%s\" %s %d", ex.what() , cameraName, serverAddress, serverPort);
      indiCamera->m_logger->logDebug( message );
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
}

//----------------------------------------------------------------------------------
// constructor
//----------------------------------------------------------------------------------
IndiCamera::IndiCamera()
{
   mydevice = NULL;   
   imageBlob = NULL;
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
   m_logger->logDebug("IndiCamera::connect watch device started");
   
   if (this->connectServer() == false) {
      char message[1024];
      sprintf(message, "could not connect to server");
      throw std::runtime_error(message);  
   }
   m_logger->logDebug("IndiCamera::connect server connected");

   //  wait for IndiCamera::newDevice event 
   for(int delay=0;  mydevice == NULL  &&  delay < 120000 ; delay+=100) {
      usleep(100000);  // wait 100 millisecond
      m_logger->logDebug("IndiCamera::connect wait new device \"%s\" delay=%d ms", this->cameraName, delay);
   }
      
   if (mydevice == NULL) {
      char message[1024];
      sprintf(message, "IndiCamera::connect error mydevice == NULL");
      throw std::runtime_error(message);  
   }
   m_logger->logDebug("IndiCamera::connect device found=", mydevice->getDeviceName() );
   
   // connect mydevice
   // ATTENTION : we cannot connect device here. We must wait newProperty CONNECTION
   //this->connectDevice(this->cameraName);
   //m_logger->logDebug("IndiCamera::connect connect device");
   
   // wait newProperty CONNECTION
   for(int delay=0;  !mydevice->isConnected()  &&  delay < 120000 ; delay+=100) {
      usleep(100000);  // wait 100 millisecond
      m_logger->logDebug("IndiCamera::connect wait CONNECTION event delay=%d ms", delay);
   }
   if( !mydevice->isConnected()) {
      char message[1024];
      sprintf(message, "IndiCamera::connect error device is not connected");
      throw std::runtime_error(message);  
   }
   
   setBLOBMode(B_ALSO, this->cameraName, NULL);

   m_logger->logDebug("IndiCamera::connect device is connected");
            
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
   return this->getPropertyNumber("CCD_INFO", "CCD_MAX_X");
}

//----------------------------------------------------------------------------------
// get camera vertical size ( pixels )
//----------------------------------------------------------------------------------
int IndiCamera::getCameraYSize()
{
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
   m_logger->logError("IndiCamera::stopExposure NOT IMPLEMENTED" );
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
   m_logger->logDebug("IndiCamera::setFrame x=%d y=%d width=%d height=%d",
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
      m_logger->logError( message);
      throw std::runtime_error(message);  
   }

   // reset image result
   imageBlob = NULL; 
   
   ccd_exposure->np[0].value = exptime;
   sendNewNumber(ccd_exposure);
   m_logger->logDebug("IndiCamera::startExposure exptime=%f", exptime);

}

//----------------------------------------------------------------------------------
//  stop exposure
//----------------------------------------------------------------------------------
void IndiCamera::stopExposure() 
{
   m_logger->logError("IndiCamera::stopExposure NOT IMPLEMENTED" );
}

//----------------------------------------------------------------------------------
//  abort exposure
//----------------------------------------------------------------------------------
void IndiCamera::abortExposure() 
{
   m_logger->logError("IndiCamera::abortExposure NOT IMPLEMENTED" );
}

//----------------------------------------------------------------------------------
// read image and copy into buffer
// @param pixels  
//----------------------------------------------------------------------------------
void IndiCamera::readImage(float *pixels)
{
   fitsfile *fptr;  // FITS file pointer
   int status = 0;  // CFITSIO status value MUST be initialized to zero!
   
   //  wait 240 000 millisconds for IndiCamera::newBLOB notification 
   for( int delay =0 ; imageBlob == NULL  &&  delay < 240000 ; delay+=100) {
      usleep(100000);  // wait 100 millisecond
      m_logger->logDebug("IndiCamera::readImage wait blob delay=%d ms", delay);
   }
   
   if( imageBlob == NULL ) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage imageBlob=NULL");
      m_logger->logError( message);
      throw std::runtime_error(message);       
   }
   m_logger->logDebug( "IndiCamera::readImage blob ready bloblen=%ld bytes" , imageBlob->bloblen );
   
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
      m_logger->logError( message);
      throw std::runtime_error(message); 
   }   
   m_logger->logDebug( "IndiCamera::readImage fits_open_memfile OK" );
   
   // check HDU type
   int hdutype;
   if (fits_get_hdu_type(fptr, &hdutype, &status) || hdutype != IMAGE_HDU) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_hdu_type error=%d", status);
      m_logger->logError( message);
      throw std::runtime_error(message); 
   }
   m_logger->logDebug( "IndiCamera::readImage fits_get_hdu_type OK" );

   // get HDU size naxis, width, height
   int naxis;
   fits_get_img_dim(fptr, &naxis, &status);
   if ( status != 0 || naxis != 2) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_img_dim naxis=%d status=%d", naxis, status);
      m_logger->logError( message);
      throw std::runtime_error(message); 
   }   
   
   long imageNaxis[2];
   fits_get_img_size(fptr, 2, imageNaxis, &status);
   if ( status != 0) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_img_size status=%d", status);
      m_logger->logError( message);
      throw std::runtime_error(message); 
   } 
   int width, height;
   width = (int) imageNaxis[0];
   height = (int) imageNaxis[1];
   m_logger->logDebug( "IndiCamera::readImage fits_get_img_size width=%d height=%d", width, height );
   
   int nhdus=0;
   fits_get_num_hdus(fptr,&nhdus,&status);
   if ((nhdus != 1) || (naxis != 2)) {
      char message[1024];
      sprintf(message, "IndiCamera::readImage fits_get_num_hdus nhdus=%d ", nhdus);
      m_logger->logError( message);
      throw std::runtime_error(message); 
   }   
   m_logger->logDebug( "IndiCamera::readImage fits_get_num_hdus nhdus=%d", nhdus);
   
  // Read image
  long fpixel[3] = {1,1,1};
  if (fits_read_pix(fptr, TFLOAT, fpixel, width*height, NULL, pixels, NULL, &status) ) { 
	 char message[1024];
	 sprintf(message, "IndiCamera::readImage fits_read_pix error=%d", status);
	 m_logger->logError( message);
	 fits_close_file(fptr, &status);
	 throw std::runtime_error(message); 
  }
  m_logger->logDebug( "IndiCamera::readImage fits_read_pix OK");
  
   fits_close_file(fptr, &status);
   m_logger->logDebug( "IndiCamera::readImage OK" );
}


//----------------------------------------------------------------------------------
//
//
void IndiCamera::setTemperature()
{
   INumberVectorProperty *ccd_temperature = NULL;

   ccd_temperature = mydevice->getNumber("CCD_TEMPERATURE");

   if (ccd_temperature == NULL)
   {
       m_logger->logError("Error: unable to find CCD Simulator CCD_TEMPERATURE property...");
       return;
   }

   ccd_temperature->np[0].value = -20;
   sendNewNumber(ccd_temperature);
}

//----------------------------------------------------------------------------------
// return pixel horizontal size (in micron) 
//----------------------------------------------------------------------------------
void IndiCamera::newDevice(INDI::BaseDevice *dp)
{
   m_logger->logDebug("IndiCamera::newDevice \"%s\" ", dp->getDeviceName());
 
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
      m_logger->logDebug("IndiCamera::newProperty %s connect device \"%s\" is not require device %s ", property->getName(), property->getDeviceName(), this->cameraName);
      return;
   }      
   
    if (!strcmp(property->getName(), "CONNECTION")) {
       connectDevice(this->cameraName);
       m_logger->logDebug("IndiCamera::newProperty %s \"%s\"", property->getName() , property->getDeviceName());
       
    } else if (!strcmp(property->getName(), "CCD_FRAME")) {
      frameProperty = property->getNumber();
      frameX = IUFindNumber(frameProperty,"X");
      frameY = IUFindNumber(frameProperty,"Y");
      frameWidth = IUFindNumber(frameProperty,"WIDTH");
      frameHeight = IUFindNumber(frameProperty,"HEIGHT");
      m_logger->logDebug("IndiCamera::newProperty %s x=%d y=%d width=%d height=%d",
         property->getName(), frameX->value, frameY->value, frameWidth->value, frameHeight->value);
      
    } else if ( !strcmp(property->getName(), "CCD_TEMPERATURE")) {
        if (mydevice->isConnected())
        {
            //sm_logger->logDebug("IndiCamera::newProperty. Setting temperature to -20 C.");
            //setTemperature();
        }
    } else {
       m_logger->logDebug("IndiCamera::newProperty %s", property->getName());
    }
   
}

//----------------------------------------------------------------------------------
// new number callback 
//----------------------------------------------------------------------------------
void IndiCamera::newNumber(INumberVectorProperty *nvp)
{
    m_logger->logDebug("IndiCamera::newNumber %s = %g", nvp->name, nvp->np[0].value);
	
    // Let's check if we get any new values for CCD_TEMPERATURE
    if (!strcmp(nvp->name, "CCD_TEMPERATURE"))
    {
       //m_logger->logError("Receving new CCD Temperature: %g C", nvp->np[0].value);

/*        if (nvp->np[0].value == -20)
 *        {
 *            m_logger->logDebug("CCD temperature reached desired value!");
 *            takeExposure();
 *        }
 */

   }
}

//----------------------------------------------------------------------------------
// new message callback 
//----------------------------------------------------------------------------------
void IndiCamera::newMessage(INDI::BaseDevice *dp, int messageID)
{
     m_logger->logDebug("IndiCamera::newMessage %s", dp->messageQueue(messageID).c_str());
     if (strcmp(dp->getDeviceName(), this->cameraName))
         return;

}

//----------------------------------------------------------------------------------
// new blob callback 
//----------------------------------------------------------------------------------
void IndiCamera::newBLOB(IBLOB *bp)
{
   imageBlob = bp;
   m_logger->logDebug("IndiCamera::newBLOB Received blobName=%s", bp->name);

}

