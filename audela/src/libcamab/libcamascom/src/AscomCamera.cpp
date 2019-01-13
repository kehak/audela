#include <stdexcept>

#include "AscomCamera.h"

#include <stdexcept>
#include "AscomCamera.h"
#include "AscomCameraV1.h"
#include "AscomCameraV2.h"
using namespace ::abcommon;

AscomCamera * AscomCamera::createInstance(const char* deviceName) {
   // j'autorise l'access aux objets COM
   //CoInitialize(NULL);
   //HRESULT hr = CoInitializeEx(NULL,COINIT_MULTITHREADED);
   HRESULT hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);   
   if (FAILED(hr)) { 
      char message[1024];
      sprintf(message, "tel_init error CoInitializeEx hr=%X",hr);
      throw std::runtime_error(message);
   }
   
   /*
   if (cam->pCam == NULL) { 
      char winErrorMessage[1024];
      FormatWinMessage( winErrorMessage , hr);
      sprintf(cam->msg, "cam_init error CreateInstance hr=%X %s",hr ,winErrorMessage);
      m_logger.logError(cam->msg); 
      return -1;
   }
   */

   try {
      // j'essaie de cree la camera AscomCameraV2
      return AscomCameraV2::createInstance(deviceName);
   } catch(std::runtime_error &e2 ) {
      try {
         // j'essaie de cree la camera AscomCameraV1
         return AscomCameraV1::createInstance(deviceName);
      }
      catch (std::runtime_error &e1) {
         std::string message;
         message = e2.what();
         message += ", ";
         message += e1.what();
         throw std::runtime_error(message);
      }
   }

}

void AscomCamera::setupDialog(const char* deviceName) {
   HRESULT hr;
   hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);
   if (FAILED(hr)) { 
      char message[1024];
      sprintf(message,  "setupDialog error CoInitializeEx hr=%X",hr);
      throw std::runtime_error(message);
   }

   AscomCamera *ascomCamera = AscomCamera::createInstance(deviceName);
   if ( FAILED(hr) ) {
      char message[1024];
      sprintf(message, "setupDialog error CreateInstance hr=%X",hr);
      throw std::runtime_error(message);
   }

   try {
      ascomCamera->setupDialog();
      ascomCamera->deleteInstance();
      ascomCamera = NULL;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
   CoUninitialize();

}
/*
void AscomCamera::FormatWinMessage(char * szPrefix, HRESULT hr)
{
    char * lpBuffer = NULL;
    DWORD  dwLen = 0;

    dwLen = FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER
                          | FORMAT_MESSAGE_FROM_SYSTEM,
                          NULL, (DWORD)hr, LANG_NEUTRAL,
                          (LPTSTR)&lpBuffer, 0, NULL);
    if (dwLen < 1) {
        dwLen = FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER
                              | FORMAT_MESSAGE_FROM_STRING
                              | FORMAT_MESSAGE_ARGUMENT_ARRAY,
                              "code 0x%1!08X!%n", 0, LANG_NEUTRAL,
                              (LPTSTR)&lpBuffer, 0, (va_list *)&hr);
    }

    if (dwLen > 0) {
       strncpy(szPrefix,lpBuffer,dwLen-1);
       szPrefix[dwLen-1]=0;
    }
        
    LocalFree((HLOCAL)lpBuffer);
    return;
}
*/
abcommon::CStructArray<abcommon::SAvailable*>*  AscomCamera::getAvailableCamera() {
   return AscomCameraV2::getAvailableCamera();
}

