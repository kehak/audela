#include <stdexcept>
#include "AscomTelescop.h"
#include "AscomTelescopVariant.h"
#include "AscomTelescopV2.h"
#include "AscomTelescopV3.h"
#include "AscomAstrooptik.h"

AscomTelescop * AscomTelescop::createInstance(const char* deviceName) {
   // j'autorise l'access aux objets COM
   //HRESULT hr = CoInitialize(NULL);
   HRESULT hr = CoInitializeEx(NULL,COINIT_MULTITHREADED);
   //HRESULT hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);   
   if (FAILED(hr)  &&  hr != 0x80010106) {
      char message[1024];
      sprintf(message, "AscomTelescop::createInstance CoInitializeEx error hr=%X",hr);
      throw std::runtime_error(message);
   }
   
   try {
      AscomTelescop * ascomTelescop = AscomTelescopV3::createInstance(deviceName); 
      if (ascomTelescop == NULL) {
         ascomTelescop = AscomTelescopV2::createInstance(deviceName); 
         if (ascomTelescop == NULL) {
            ascomTelescop = AscomAstrooptik::createInstance(deviceName);  
            if (ascomTelescop == NULL) {
               //ascomTelescop = AscomTelescopV1::createInstance(deviceName);
               if (ascomTelescop == NULL) {
                  //ascomTelescop = AscomTelescopVariant::createInstance(deviceName);         
               
               }
            }
         }
      }
      return ascomTelescop;      
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }

}

/**
*  Recherche le libellé d'erreur système associé à la valeur de HRESULT
*   Si le libellé est trouvé , le libellé est ajouté à la fin de szPrefix
*   Si le libellé n'est pas trouvé , le numéro de l'erreur ajouté à la fin de szPrefix
*  @param   szPrefix (output) chaine de caractere contenant le  libelle d'erreur du systeme
*  @param   hr        code d'erreur du systeme
*  @return  void
*/
void AscomTelescop::FormatWinMessage(char * szPrefix, HRESULT hr)
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

