#include <exception>
#include "AscomCameraV2.h"
using namespace ASCOM_DeviceInterfaces;


/**
   Factory d'instance
*/
AscomCameraV2 * AscomCameraV2::createInstance(const char* deviceName) {
   ICameraV2Ptr cameraPtr = NULL;
   HRESULT hr = cameraPtr.CreateInstance((LPCSTR)deviceName);
   if ( SUCCEEDED(hr) ) {
      AscomCameraV2 * device = new AscomCameraV2(cameraPtr);   
      return device;
   } else {
      return (AscomCameraV2*) NULL;
   }
}


AscomCameraV2::AscomCameraV2(ICameraV2Ptr &cameraPtr)
{
   this->cameraPtr = cameraPtr;
}

AscomCameraV2::~AscomCameraV2(void)
{
}

void AscomCameraV2::connect(bool state) {
   try {
      cameraPtr->Connected = true;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}


void AscomCameraV2::deleteInstance() {
   try {
      cameraPtr->Connected = false;
      cameraPtr->Release();
      //cameraPtr = NULL;
      CoUninitialize();
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}


double AscomCameraV2::getCCDTemperature() {
   try {
      return cameraPtr->CCDTemperature;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV2::getSetCCDTemperature() {
   try {
      return cameraPtr->SetCCDTemperature;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::setSetCCDTemperature(double value) {
   try {
      cameraPtr->SetCCDTemperature = value;      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

bool AscomCameraV2::getCoolerOn() {
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

void AscomCameraV2::setCoolerOn(bool value) {
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

double AscomCameraV2::getCoolerPower() {
   try {
      return cameraPtr->CoolerPower;      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}


char * AscomCameraV2::getName() {
   try {
      return _com_util::ConvertBSTRToString(cameraPtr->Name);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

char * AscomCameraV2::getDescription() {
   try {
      return _com_util::ConvertBSTRToString(cameraPtr->Description);
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV2::getCameraXSize() {
   try {
      return cameraPtr->CameraXSize;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
int AscomCameraV2::getCameraYSize() {
   try {
      return cameraPtr->CameraYSize;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV2::getMaxBinX() {
   try {
      return cameraPtr->MaxBinX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
int AscomCameraV2::getMaxBinY() {
   try {
      return cameraPtr->MaxBinY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV2::getPixelSizeX() {
   try {
      return cameraPtr->PixelSizeX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
double AscomCameraV2::getPixelSizeY() {
   try {
      return cameraPtr->PixelSizeY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV2::hasShutter() {
   try {
      return cameraPtr->HasShutter;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}




void AscomCameraV2::setBinX(short value) {
   try {
      cameraPtr->BinX = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV2::setBinY(short value) {
   try {
      cameraPtr->BinY = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

long AscomCameraV2::getStartX() {
   try {
      return cameraPtr->StartX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
long AscomCameraV2::getStartY() {
   try {
      return cameraPtr->StartY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

long AscomCameraV2::getNumX() {
   try {
      return cameraPtr->NumX;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
long AscomCameraV2::getNumY() {
   try {
      return cameraPtr->NumY;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::setStartX(long value) {
   try {
      cameraPtr->StartX = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV2::setStartY(long value) {
   try {
      cameraPtr->StartY = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::setNumX(long value) {
   try {
      cameraPtr->NumX = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV2::setNumY(long value) {
   try {
      cameraPtr->NumY = value;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::startExposure(double exptime, int shutterindex) {
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

void AscomCameraV2::stopExposure() {
   try {
      cameraPtr->StopExposure();
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::abortExposure() {
   try {
      cameraPtr->AbortExposure();
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::readImage(float *p) {
   long * lValues;
   VARIANT_BOOL imageReady = VARIANT_TRUE;

   
   try {
      // j'attends que l'image soit prete
      int nbLoop = 0;
      while (cameraPtr->ImageReady == VARIANT_FALSE && nbLoop < 30000){
         Sleep(10);
         if ( cameraPtr->Connected == VARIANT_FALSE ) {
            throw std::exception("cam_read_ccd camera not connected");
         }
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
            //long offset = (height-y-1)*width;
            long offset = y*width;
            for( int x=0; x <width ; x++) {
               // copie les lignes en inversant l'ordre des lignes (inversion verticale)
               p[x+offset] = (unsigned short) lValues[x+offset];
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

void AscomCameraV2::setupDialog(void) {
   try {
      cameraPtr->SetupDialog();
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
}

