#include <exception>

#include "AscomCameraV1.h"
using namespace AscomInterfacesLib;

/**
   Factory d'instance
*/
AscomCameraV1 * AscomCameraV1::createInstance(const char* deviceName) {
   ICameraPtr cameraPtr = NULL;
   HRESULT hr = cameraPtr.CreateInstance((LPCSTR)deviceName);
   if ( SUCCEEDED(hr) ) {
      AscomCameraV1 * device = new AscomCameraV1(cameraPtr);        
      return device;
   } else {
      return (AscomCameraV1*) NULL;
   }
}

/**
Constructeur
*/
AscomCameraV1::AscomCameraV1( ICameraPtr &cameraPtr)
{
   this->cameraPtr = cameraPtr;   
   /*
   if (strcmp(argv[2],"CCDSimulator.Camera")== 0 ) {
      // bidouille pour contourner un bug du la fonction GetImageReady() du simulateur 
       cam->params->isSimulator = 1;
   } else {
       cam->params->isSimulator = 0;
   }
   */


}

AscomCameraV1::~AscomCameraV1(void)
{
}

void AscomCameraV1::connect(bool state) {
   try {
      cameraPtr->Connected = true;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::deleteInstance() {
   try {
      cameraPtr->Connected = false;
      cameraPtr->Release();
      //cameraPtr = NULL;
      CoUninitialize();
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
  
}


double AscomCameraV1::getCCDTemperature() {
 try {
      return cameraPtr->CCDTemperature;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV1::getSetCCDTemperature() {
 try {
      return cameraPtr->SetCCDTemperature;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::setSetCCDTemperature(double value) {
try {
      cameraPtr->SetCCDTemperature = value;      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomCameraV1::getCoolerOn() {
   try {
      if (cameraPtr->CoolerOn == VARIANT_TRUE ) {
         return true;
      } else {
         return false;
      }
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::setCoolerOn(bool value) {
   try {
      if (value == true) {
         cameraPtr->CoolerOn = VARIANT_TRUE;
      } else {
         cameraPtr->CoolerOn = VARIANT_FALSE;
      }
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV1::getCoolerPower() {
   try {
      return cameraPtr->CoolerPower;      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

char * AscomCameraV1::getName() {
   // j'utilise getDescription() parce que cameraPtr.Name n'existe pas . 
   return getDescription();
}

char * AscomCameraV1::getDescription() {
   try {
      return _com_util::ConvertBSTRToString(cameraPtr->Description);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}


int AscomCameraV1::getCameraXSize() {
   try {
      return cameraPtr->CameraXSize;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
int AscomCameraV1::getCameraYSize() {
   try {
      return cameraPtr->CameraYSize;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV1::getMaxBinX() {
   try {
      return cameraPtr->MaxBinX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
int AscomCameraV1::getMaxBinY() {
   try {
      return cameraPtr->MaxBinY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV1::getPixelSizeX() {
   try {
      return cameraPtr->PixelSizeX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
double AscomCameraV1::getPixelSizeY() {
   try {
      return cameraPtr->PixelSizeY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

long AscomCameraV1::getStartX() {
   try {
      return cameraPtr->StartX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
long AscomCameraV1::getStartY() {
   try {
      return cameraPtr->StartY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

long AscomCameraV1::getNumX() {
   try {
      return cameraPtr->NumX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
long AscomCameraV1::getNumY() {
   try {
      return cameraPtr->NumY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV1::hasShutter() {
   try {
      return cameraPtr->HasShutter;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::setBinX(short value) {
   try {
      cameraPtr->BinX = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV1::setBinY(short value) {
   try {
      cameraPtr->BinY = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}


void AscomCameraV1::setStartX(long value) {
   try {
      cameraPtr->StartX = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV1::setStartY(long value) {
   try {
      cameraPtr->StartY = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::setNumX(long value) {
   try {
      cameraPtr->NumX = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV1::setNumY(long value) {
   try {
      cameraPtr->NumY = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::startExposure(double exptime, int shutterindex) {
   HRESULT hr;
   if (shutterindex == 0) {
      // acquisition avec obturateur ferme
      hr = cameraPtr->StartExposure(exptime, VARIANT_FALSE);
   } else {
      // acquisition avec obturateur ouvert
      hr = cameraPtr->StartExposure(exptime, VARIANT_TRUE);
   }
   if (FAILED(hr)) {
      char message[1024];
      sprintf(message, "error StartExposure hr=%X",hr);
      throw std::exception(message);
   }
}

void AscomCameraV1::stopExposure() {
   try {
      cameraPtr->StopExposure();
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}



void AscomCameraV1::abortExposure() {
   try {
      cameraPtr->AbortExposure();
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::readImage(float *p) {
   long * lValues;
   VARIANT_BOOL imageReady = VARIANT_TRUE;
   try {
      // j'attends que l'image soit prete
      int nbLoop = 0;
      while (cameraPtr->ImageReady == VARIANT_FALSE && nbLoop < 100){
         Sleep(10);
         nbLoop ++; 
      }    
      imageReady = cameraPtr->ImageReady ;
      if ( imageReady == VARIANT_TRUE ) {
         SAFEARRAY *safeValues;
         // je reccupere le pointeur de l'image
         safeValues = cameraPtr->ImageArray.parray;            
         SafeArrayAccessData(safeValues, (void**)&lValues);      
         int width = cameraPtr->NumX;
         int height = cameraPtr->NumY;
         // je copie l'image dans le buffer
         for( int y=0; y <height; y++) {
            long offsetSrc = (height-y-1)*width;
            long offset = y*width;
            for( int x=0; x <width ; x++) {
               // copie les lignes en inversant l'ordre des lignes (inversion verticale)
               p[x+offset] = (float) lValues[x+offsetSrc];
            }
         }
         SafeArrayUnaccessData(safeValues);
         SafeArrayDestroy(safeValues);
         SafeArrayDestroyDescriptor(safeValues);
         safeValues = NULL;
         VariantClear(&cameraPtr->ImageArray);
      } else {
         throw std::exception("cam_read_ccd image not ready");
      }
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV1::setupDialog(void) {
   try {
      cameraPtr->SetupDialog();
  } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

