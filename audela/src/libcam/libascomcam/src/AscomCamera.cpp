
#include "AscomCamera.h"

#include <exception>
#include "AscomCamera.h"
#include "AscomCameraV1.h"
#include "AscomCameraV2.h"

AscomCamera * AscomCamera::createInstance(const char* deviceName) {
   // j'autorise l'access aux objets COM
   //CoInitialize(NULL);
   //HRESULT hr = CoInitializeEx(NULL,COINIT_MULTITHREADED);
   HRESULT hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);   
   if (FAILED(hr)) { 
      char message[1024];
      sprintf(message, "tel_init error CoInitializeEx hr=%X",hr);
      throw std::exception(message);
   }
   
   /*
   if (cam->params->pCam == NULL) { 
      char winErrorMessage[1024];
      FormatWinMessage( winErrorMessage , hr);
      sprintf(cam->msg, "cam_init error CreateInstance hr=%X %s",hr ,winErrorMessage);
      ascomcam_log(LOG_ERROR,cam->msg); 
      return -1;
   }
   */

   try {
      // j'essaie de cree la camera AscomCameraV2
      AscomCamera * ascomCamera = AscomCameraV2::createInstance(deviceName); 
      if (ascomCamera == NULL) {
         // j'essaie de cree la camera AscomCameraV1
         ascomCamera = AscomCameraV1::createInstance(deviceName);
      }
      return ascomCamera;      
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }

}

void AscomCamera::setupDialog(const char* deviceName) {
   HRESULT hr;
   hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);
   if (FAILED(hr)) { 
      char message[1024];
      sprintf(message,  "setupDialog error CoInitializeEx hr=%X",hr);
      throw std::exception(message);
   }

   AscomCamera *ascomCamera = AscomCamera::createInstance(deviceName);
   if ( FAILED(hr) ) {
      char message[1024];
      sprintf(message, "setupDialog error CreateInstance hr=%X",hr);
      throw std::exception(message);
   }

   try {
      ascomCamera->setupDialog();
      ascomCamera->deleteInstance();
      ascomCamera = NULL;
   } catch( _com_error &e ) {
      throw std::exception(_com_util::ConvertBSTRToString(e.Description()));
   }
   CoUninitialize();

}

void FormatWinMessage(char * szPrefix, HRESULT hr)
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
