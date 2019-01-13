
#include <stdexcept>
#include <string>
//  pour  _ArrayListPtr  IID_IList
#import "file:..\..\..\external\ascom\ascom6\lib\mscorlib.tlb" no_namespace named_guids  //raw_native_types
//  pour  IProfilePtr
#import "file:..\..\..\external\ascom\ascom6\lib\ASCOM.Utilities-v6.2.tlb" //raw_native_types
#include "AscomCameraV2.h"

using namespace ASCOM_DeviceInterfaces;
using namespace ASCOM_Utilities;
using namespace ::abcommon;

/**
   Factory d'instance
*/
AscomCameraV2 * AscomCameraV2::createInstance(const char* deviceName) {

   //CLSID CLSID_chooser;
   //IDispatch *pChooserDisplay = NULL;
   //// Find the ASCOM Chooser
   //// First, go into the registry and get the CLSID of it based on the name
   //if (FAILED(CLSIDFromProgID(L"ASCOM.Simulator.Camera", &CLSID_chooser))) {
   //   return NULL;
   //}

   //if (FAILED(CoCreateInstance(CLSID_chooser, NULL, CLSCTX_SERVER, IID_IDispatch, (LPVOID *)&pChooserDisplay))) {
   //   return NULL;
   //}


   ICameraV2Ptr cameraPtr;
   HRESULT hr = cameraPtr.CreateInstance((LPCSTR)deviceName);
   //HRESULT hr = cameraPtr.CreateInstance((LPCSTR)L"ASCOM.Simulator.Camera");
   //HRESULT hr = cameraPtr.CreateInstance(CLSID_chooser);
   if ( SUCCEEDED(hr) ) {
      AscomCameraV2 * device = new AscomCameraV2(cameraPtr);   
      return device;
   } else {
      char message[1024];
      strcpy(message, "AscomCameraV2::createInstance");
      //FormatWinMessage(message, hr);
      throw std::runtime_error(message);
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
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}


void AscomCameraV2::deleteInstance() {
   try {
      cameraPtr->Connected = false;
      cameraPtr->Release();
      //cameraPtr = NULL;
      CoUninitialize();
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}


double AscomCameraV2::getCCDTemperature() {
   try {
      return cameraPtr->CCDTemperature;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV2::getSetCCDTemperature() {
   try {
      return cameraPtr->SetCCDTemperature;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::setSetCCDTemperature(double value) {
   try {
      cameraPtr->SetCCDTemperature = value;      
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
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
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
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
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV2::getCoolerPower() {
   try {
      return cameraPtr->CoolerPower;      
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}


char * AscomCameraV2::getName() {
   try {
      return _com_util::ConvertBSTRToString(cameraPtr->Name);
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

char * AscomCameraV2::getDescription() {
   try {
      return _com_util::ConvertBSTRToString(cameraPtr->Description);
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV2::getCameraXSize() {
   try {
      return cameraPtr->CameraXSize;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
int AscomCameraV2::getCameraYSize() {
   try {
      return cameraPtr->CameraYSize;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV2::getMaxBinX() {
   try {
      return cameraPtr->MaxBinX;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
int AscomCameraV2::getMaxBinY() {
   try {
      return cameraPtr->MaxBinY;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

double AscomCameraV2::getPixelSizeX() {
   try {
      return cameraPtr->PixelSizeX;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
double AscomCameraV2::getPixelSizeY() {
   try {
      return cameraPtr->PixelSizeY;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

int AscomCameraV2::hasShutter() {
   try {
      return cameraPtr->HasShutter;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}




void AscomCameraV2::setBinX(short value) {
   try {
      cameraPtr->BinX = value;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV2::setBinY(short value) {
   try {
      cameraPtr->BinY = value;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

long AscomCameraV2::getStartX() {
   try {
      return cameraPtr->StartX;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
long AscomCameraV2::getStartY() {
   try {
      return cameraPtr->StartY;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

long AscomCameraV2::getNumX() {
   try {
      return cameraPtr->NumX;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
long AscomCameraV2::getNumY() {
   try {
      return cameraPtr->NumY;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::setStartX(long value) {
   try {
      cameraPtr->StartX = value;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV2::setStartY(long value) {
   try {
      cameraPtr->StartY = value;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::setNumX(long value) {
   try {
      cameraPtr->NumX = value;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}
void AscomCameraV2::setNumY(long value) {
   try {
      cameraPtr->NumY = value;
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
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
      throw std::runtime_error(message);
   }
}

void AscomCameraV2::stopExposure() {
   try {
      cameraPtr->StopExposure();
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::abortExposure() {
   try {
      cameraPtr->AbortExposure();
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
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
            throw std::runtime_error("cam_read_ccd camera not connected");
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
         //SafeArrayDestroyDescriptor(safeValues); //inutil car descriptor est detruit par SafeArrayDestroy
         safeValues = NULL;
         VariantClear(&cameraPtr->ImageArray);
      } else {
         throw std::runtime_error("cam_read_ccd image not ready");
      }
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}

void AscomCameraV2::setupDialog(void) {
   try {
      cameraPtr->SetupDialog();
   } catch( _com_error &e ) {
      throw std::runtime_error(_com_util::ConvertBSTRToString(e.Description()));
   }
}


//char * profileClsid = "43325B3A-8B34-48DB-8028-9D8CED9FA9E2";  // ASCOM.Utilities.ASCOMProfile
//char * profileClsid = "880840E2-76E6-4036-AD8F-60A326D7F9DA";  // ASCOM.Utilities.Profile
//char * profileClsid = "8828511a-05c1-43c7-8970-00d23595930a";  // IProfile UUID

HRESULT ResolveVariant(VARIANT* pVarIn, VARIANT* pVarOut)
{
   VARIANT* tmpVarIn = pVarIn;
   ULONG ByRef = 0;

   while(tmpVarIn->vt == (VT_BYREF | VT_VARIANT) )
      tmpVarIn = tmpVarIn->pvarVal;

   if(tmpVarIn->vt & VT_BYREF)
      ByRef = VT_BYREF;


   switch(tmpVarIn->vt)
   {
   case (VT_I2): case (VT_BYREF|VT_I2):
      if(ByRef)
      {
         if(!tmpVarIn->piVal) return E_POINTER;
         pVarOut->iVal = *(tmpVarIn->piVal);
      }
      break;

   case (VT_I4): case (VT_BYREF|VT_I4):
      if(ByRef)
      {
         if(!tmpVarIn->plVal) return E_POINTER;
         pVarOut->lVal = *(tmpVarIn->plVal);
      }
      break;

   case (VT_BSTR): case (VT_BYREF|VT_BSTR):
      if(ByRef)
      {
         if(!tmpVarIn->pbstrVal) return E_POINTER;
         if(!*(tmpVarIn->pbstrVal) ) return E_POINTER;
         pVarOut->bstrVal = *(tmpVarIn->pbstrVal);
      }
      break;

   case (VT_DISPATCH): case (VT_BYREF|VT_DISPATCH):
      if(ByRef)
      {
         if(!tmpVarIn->ppdispVal) return E_POINTER;
         if(!*(tmpVarIn->ppdispVal) ) return E_POINTER;
         pVarOut->pdispVal = *(tmpVarIn->ppdispVal);
      }
      break;


   default:
      return DISP_E_TYPEMISMATCH;
   }

   if(ByRef)
      pVarOut->vt = (VARTYPE)(tmpVarIn->vt - ByRef);
   else
      *pVarOut = *tmpVarIn;

   if (pVarOut->vt == VT_DISPATCH)
   {
      VARIANT varResolved;
      DISPPARAMS  dispParamsNoArgs = {NULL, NULL, 0, 0};

      VariantInit(&varResolved);

      if ( SUCCEEDED(
         pVarOut->pdispVal->Invoke(DISPID_VALUE, IID_NULL, LOCALE_SYSTEM_DEFAULT,
         DISPATCH_PROPERTYGET | DISPATCH_METHOD,
         &dispParamsNoArgs, &varResolved, NULL, NULL) ) )
      {
         ResolveVariant(&varResolved, pVarOut);
      }
      else
         return E_FAIL;

      VariantClear(&varResolved);
      return S_OK;
   }
   else
   {
      HRESULT hr;
      VARIANT retVar;
      VariantInit(&retVar);
      hr = VariantCopy(&retVar, pVarOut);
      *pVarOut = retVar;
      return hr;
   }
}

/*
abcommon::IStringArray*  AscomCameraV2::getAvailableCamera() {
   try {
      CStringArray* available = new CStringArray();
            
      HRESULT hr = CoInitializeEx(NULL,COINIT_APARTMENTTHREADED);   
      if (FAILED(hr)) { 
         throw CError(CError::ErrorGeneric, "error CoInitializeEx hr=%X",hr);
      }

      ASCOM_Utilities::IProfilePtr profilePtr = NULL;
      hr = profilePtr.CreateInstance("ASCOM.Utilities.Profile");
      if ( FAILED(hr) ) {
         throw CError(CError::ErrorGeneric, "error profilePtr.CreateInstance hr=%X",hr);
      }

      _ArrayListPtr registeredDevices =profilePtr->RegisteredDevices(_com_util::ConvertStringToBSTR("Camera"));
      
      // Get the IList interface
      IList* pList = NULL;
      hr = registeredDevices->QueryInterface(IID_IList, (void**)&pList);
      if ( FAILED(hr) ) {
         registeredDevices->Release();
         throw CError(CError::ErrorGeneric, "error pregisteredDevices->QueryInterface hr=%X",hr);
      }
      bool found = true; 
      VARIANT varOut;
      VariantInit(&varOut);
      int i = 0;
      while ( found) {
         try {         
            VARIANT item = pList->GetItem(i++);
            hr = ResolveVariant(&item, &varOut);
            const char * data = _com_util::ConvertBSTRToString(varOut.bstrVal);
            std::string data2 = data;
            available->append(data2);
            found = true;
         } catch( _com_error ) {
            found = false; 
         }
      }
      VariantClear(&varOut);
      registeredDevices->Release();
      CoUninitialize();  
      return available;
   } catch( _com_error &e ) {
      CoUninitialize();
      if( _com_util::ConvertBSTRToString(e.Description()) != (char*)NULL ) {
         throw CError(CError::ErrorGeneric,_com_util::ConvertBSTRToString(e.Description()));
      } else {
         throw CError(CError::ErrorGeneric, "AscomCameraV2::getAvailableCamera()");
      }
   }
}
*/

#include <stdio.h>
#include <tchar.h>

#define MAX_KEY_LENGTH 255
#define MAX_VALUE_NAME 16383

void QueryKey(HKEY hKey)
{

   
}

abcommon::CStructArray<abcommon::SAvailable*>* AscomCameraV2::getAvailableCamera() {
   try {
      
      abcommon::CStructArray<abcommon::SAvailable*>* cameras = new CStructArray<abcommon::SAvailable*>();

      HKEY hKey;
      // HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Camera Drivers"
      if (RegOpenKeyEx(HKEY_LOCAL_MACHINE,
         TEXT("Software\\ASCOM\\Camera Drivers"),
         0,
         KEY_READ,
         &hKey) == ERROR_SUCCESS
         )
      {

         TCHAR    achKey[MAX_KEY_LENGTH];   // buffer for subkey name
         DWORD    cbName;                   // size of name string 
         TCHAR    achClass[MAX_PATH] = TEXT("");  // buffer for class name 
         DWORD    cchClassName = MAX_PATH;  // size of class string 
         DWORD    cSubKeys = 0;               // number of subkeys 
         DWORD    cbMaxSubKey;              // longest subkey size 
         DWORD    cchMaxClass;              // longest class string 
         DWORD    cValues;              // number of values for key 
         DWORD    cchMaxValue;          // longest value name 
         DWORD    cbMaxValueData;       // longest value data 
         DWORD    cbSecurityDescriptor; // size of security descriptor 
         FILETIME ftLastWriteTime;      // last write time 

         DWORD retCode;

         //TCHAR  achValue[MAX_VALUE_NAME];
         //DWORD cchValue = MAX_VALUE_NAME;

         // Get the class name and the value count. 
         retCode = RegQueryInfoKey(
            hKey,                    // key handle 
            achClass,                // buffer for class name 
            &cchClassName,           // size of class string 
            NULL,                    // reserved 
            &cSubKeys,               // number of subkeys 
            &cbMaxSubKey,            // longest subkey size 
            &cchMaxClass,            // longest class string 
            &cValues,                // number of values for this key 
            &cchMaxValue,            // longest value name 
            &cbMaxValueData,         // longest value data 
            &cbSecurityDescriptor,   // security descriptor 
            &ftLastWriteTime);       // last write time 

                                     // Enumerate the subkeys, until RegEnumKeyEx fails.

         if (cSubKeys)
         {
            
            for (DWORD i = 0; i < cSubKeys; i++)
            {
               cbName = MAX_KEY_LENGTH;
               retCode = RegEnumKeyEx(hKey, i,
                  achKey,
                  &cbName,
                  NULL,
                  NULL,
                  NULL,
                  &ftLastWriteTime);
               if (retCode == ERROR_SUCCESS)
               {
                  _tprintf(TEXT("(%d) %s\n"), i + 1, achKey);
                  const int MAX_VER = 255;
                  DWORD dwSize = 1024;
                  DWORD dwType;
                  char buffer[1024];
                  retCode = RegGetValue(hKey, achKey, "", RRF_RT_ANY, &dwType, &buffer, &dwSize);
                  if (retCode == ERROR_SUCCESS) {
                     cameras->append(new abcommon::SAvailable(std::basic_string<TCHAR>(achKey), std::string(buffer) ) );
                     _tprintf(TEXT("(%d) %s\n"), i + 1, buffer);
                  }
               }
            }
         }


         RegCloseKey(hKey);
      }
      return cameras;
   }
   catch (_com_error &e) {
      if (_com_util::ConvertBSTRToString(e.Description()) != (char*)NULL) {
         throw CError(CError::ErrorGeneric, _com_util::ConvertBSTRToString(e.Description()));
      } else {
         throw CError(CError::ErrorGeneric, "AscomCameraV2::getAvailableCamera()");
      }
   }
}

/*
void getVersion(char* o_version) {
   const int MAX_VER = 40; 
   HKEY hKey; 
   DWORD dwSize; 
   DWORD dwType; 
   wchar_t version[MAX_VER] = { 0 };
   if (RegOpenKeyEx(HKEY_CLASSES_ROOT, REG_KEY, 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
      dwSize = MAX_VER; 
      RegQueryValueEx(hKey, NULL, NULL, &dwType, (LPBYTE)&version, &dwSize);
      //(default) 
      RegCloseKey(hKey);
   } 
   size_t converted = 0;
   char nstring[50];
   wcstombs_s(&converted, nstring, version, 50);
   strcpy(o_version, nstring);
}
*/

