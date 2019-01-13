// Capture.cpp: implementation of the CCaptureWinDirectx class.
//
//////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <windows.h>
#include <dshow.h>
#include <assert.h>

#pragma comment(lib, "strmiids") // pour _CLSID_VideoInputDeviceCategory

// {C1F400A0-3F08-11D3-9F0B-006008039E37}
DEFINE_GUID(CLSID_SampleGrabber,
0xC1F400A0, 0x3F08, 0x11D3, 0x9F, 0x0B, 0x00, 0x60, 0x08, 0x03, 0x9E, 0x37); //qedit.dll
static const CLSID CLSID_NullRenderer = { 0xC1F400A4, 0x3F08, 0x11d3, { 0x9F, 0x0B, 0x00, 0x60, 0x08, 0x03, 0x9E, 0x37 } };

#include "CaptureWinDirectx.h"

#ifndef NUMELMS
   #define NUMELMS(aa) (sizeof(aa)/sizeof((aa)[0]))
#endif

#ifndef SAFE_RELEASE
#define SAFE_RELEASE(x) { if (x) x->Release(); x = NULL; }
#endif

template <class T> void SafeRelease(T **ppT)
{
    if (*ppT)
    {
        (*ppT)->Release();
        *ppT = NULL;
    }
}

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCaptureWinDirectx::CCaptureWinDirectx()
{

   pFilterGraph = NULL;
   pCaptureGraphBuilder = NULL;
   pMediaControl= NULL;
   pMediaEvent= NULL;
   pVideoCaptureSource=NULL;
   pAudioCaptureSource=NULL;
   //pMediaSeeking= NULL;
   //pVideoWindow= NULL;
   //pAMVideoControl= NULL;
   pVideoStreamConfigure = NULL;
   pSampleGrabber = NULL;

   ZeroMemory(sourceDeviceList, sizeof(sourceDeviceList));
   grabBuffer = NULL;

   fCaptureGraphBuilt = FALSE;
   fPreviewGraphBuilt = FALSE;
   fGrabFrameGraphBuilt = FALSE;

   fCapturing = FALSE;
   fPreviewing = FALSE;
   fGrabbingFrame = FALSE; 
   fWantPreview = FALSE;
   fCapAudio = FALSE;
   wszCaptureFile[0]= 0;

   wndproc= NULL;
   ownerHwnd = 0;

   grabBufferWidth = 0;
   grabBufferHeight = 0;

   
}

CCaptureWinDirectx::~CCaptureWinDirectx()
{

   StopPreview();
   //StopVCapture();
   StopGrabFrame();
   TearDownGraph();

   if ( grabBuffer != NULL) {
      free(grabBuffer);
   }
   ZeroMemory(sourceDeviceList, sizeof(sourceDeviceList));

   if (pFilterGraph) {
       pFilterGraph->Abort();
   }

   SAFE_RELEASE(pSampleGrabber);
   SAFE_RELEASE(pVideoStreamConfigure);
   SAFE_RELEASE(pAudioCaptureSource);
   SAFE_RELEASE(pVideoCaptureSource);
   SAFE_RELEASE(pMediaEvent);
   SAFE_RELEASE(pMediaControl);
   SAFE_RELEASE(pCaptureGraphBuilder);
   SAFE_RELEASE(pFilterGraph); 
}

/**
*----------------------------------------------------------------------
*
* initHardware
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinDirectx::initHardware(UINT uIndex, CCaptureListener *captureListener, char *errorMessage) {
   BOOL   result;
   
   HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);

   // Create the filter graph
    hr = CoCreateInstance (CLSID_FilterGraph, NULL, CLSCTX_INPROC,
                           IID_IGraphBuilder, (void **) &pFilterGraph);
    if (FAILED(hr)) {
       sprintf(errorMessage, "Error Creating FilterGrap hr=0x%x", hr);
       return FALSE;
    }
 
    // Create the capture graph builder
    hr = CoCreateInstance (CLSID_CaptureGraphBuilder2 , NULL, CLSCTX_INPROC,
                           IID_ICaptureGraphBuilder2, (void **) &pCaptureGraphBuilder);
    if (FAILED(hr)) {
       sprintf(errorMessage, "Error Creating CaptureGraphBuilder hr=0x%x", hr);
       return FALSE;
    }
    
    // Obtain interfaces for media control and Video Window - ???????? ?????????? ??? ?????????? ????? ? ????? ?????
    hr = pFilterGraph->QueryInterface(IID_IMediaControl,(LPVOID *) &pMediaControl);
    if (FAILED(hr)){
       sprintf(errorMessage, "Error Creating MediaControl hr=0x%x", hr);
       return FALSE;
    }
 
    ITypeInfo *type_info;
    hr = pMediaControl->GetTypeInfo(0,0,&type_info);
 
    //hr = pFilterGraph->QueryInterface(IID_IVideoWindow, (LPVOID *) &pVideoWindow);
    //if (FAILED(hr))
    //    return hr;
 
    hr = pFilterGraph->QueryInterface(IID_IMediaEventEx, (LPVOID *) &pMediaEvent);
    if (FAILED(hr)){
       sprintf(errorMessage, "Error Creating MediaEvent hr=0x%x", hr);
       return FALSE;
    }
 
    // Set the window handle used to process graph events
    //hr = pMediaEvent->SetNotifyWindow((OAHWND)ghApp, WM_GRAPHNOTIFY, 0);

     // Attach the filter graph to the capture graph - ?????????? ?????? ??? ???????
    hr = pCaptureGraphBuilder->SetFiltergraph(pFilterGraph);
    if (FAILED(hr)){
       sprintf(errorMessage, "Error SetFiltergraph hr=0x%x", hr);
       return FALSE;
    }

   // je recherche la liste des webcam
   std::list<std::string> deviceList;
   std::list<std::string>::iterator iterator;
   result = getDeviceList(deviceList, errorMessage);
   if (result == TRUE) {
      sprintf(errorMessage, "{ " );
      for (iterator =  deviceList.begin(); iterator != deviceList.end(); ++iterator) {
         char camName[256]; 
         sprintf(camName, "{%s}", iterator->c_str());
         strcat(errorMessage, camName);
      }
      strcat(errorMessage, " }");
      deviceList.clear();
   } else {
      return FALSE;
   }

   return result;
}

BOOL CCaptureWinDirectx::getDeviceList(::std::list<::std::string> &deviceList, char * errorMessage)
{
   HRESULT hr = TRUE;
   for(int i = 0; i < NUMELMS(sourceDeviceList); i++) {
      SAFE_RELEASE(sourceDeviceList[i]);
   }

   hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
   ICreateDevEnum *pDevEnum=0;
   hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER,IID_ICreateDevEnum, (void**)&pDevEnum);
   if(hr != NOERROR)
   {
      sprintf(errorMessage, "Error creating camera Enumerator hr=0x%x", hr);
      return FALSE;
   }

   IEnumMoniker *pEnum=0;
   hr = pDevEnum->CreateClassEnumerator(CLSID_VideoInputDeviceCategory, &pEnum, 0);
   if(hr != NOERROR)
   {
      sprintf(errorMessage, "No camera found hr=0x%x", hr);
      pDevEnum->Release();
      return FALSE;
   }

   pEnum->Reset();
   ULONG cFetched;
   IMoniker *pM;
   UINT    uIndex = 0;

   while(1) {
      hr = pEnum->Next(1, &pM, &cFetched);
      if(hr != S_OK) {
         // il n'y a pas d'autre device
         pDevEnum->Release();
         return TRUE;
      }

      IPropertyBag *pBag=0;

      hr = pM->BindToStorage(0, 0, IID_IPropertyBag, (void **)&pBag);
      if(SUCCEEDED(hr))
      {
         VARIANT var;
         var.vt = VT_BSTR;
         hr = pBag->Read(L"FriendlyName", &var, NULL);
         if(hr == NOERROR)
         {
            char *bstrVal;
            BSTRtoASC(var.bstrVal, bstrVal);
            deviceList.push_back(bstrVal);            
            SysFreeString(var.bstrVal);
            assert(sourceDeviceList[uIndex] == 0);
            sourceDeviceList[uIndex]        = pM;
            pM->AddRef();
         }
         pBag->Release();
      }
      pM->Release();
      uIndex++;
   }

   pEnum->Release();
   return TRUE;
}

/**
*----------------------------------------------------------------------
*
* connect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinDirectx::connect(BOOL longExposure, UINT iIndex, char *errorMessage) {
   BOOL result; 
   IMoniker *pMoniker = sourceDeviceList[iIndex];

   // Bind Moniker to a filter object
   HRESULT hr = pMoniker->BindToObject(0,0,IID_IBaseFilter, (void**)&pVideoCaptureSource);
   if (FAILED(hr)) {
      sprintf(errorMessage, "Couldn't bind moniker to filter object hr=0x%x", hr);
      return FALSE;
   }
   result = BuildGrabFrameGraph(errorMessage);
   if (result == FALSE) {
      return FALSE;       
   } 
   result = StartGrabFrame(errorMessage);

   return result;
}


/**
*----------------------------------------------------------------------
*
* disconnect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinDirectx::disconnect(char *errorMessage) {
   BOOL   result = TRUE;

   HRESULT hr = pMediaControl->Stop();
   if (FAILED(hr))
   {
      sprintf(errorMessage, "Error MediaControl stop hr=0x%x", hr);
      return FALSE;
   }

   return result;
}

/**
*----------------------------------------------------------------------
* isConnected
*  returns connected sate
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinDirectx::isConnected() {
   BOOL   result;
   
   OAFilterState state;
   HRESULT hr = pMediaControl->GetState(INFINITE, &state);
   result = (state == State_Running) ;
   return result;
}

/**
*----------------------------------------------------------------------
*
* accessors
*
*----------------------------------------------------------------------
*/

unsigned int     CCaptureWinDirectx::getImageWidth(){
   return grabBufferWidth;
}

unsigned int     CCaptureWinDirectx::getImageHeight() {
   return grabBufferHeight;
}




/**
*----------------------------------------------------------------------
*
* Windows Video capture core fonctions
*
*----------------------------------------------------------------------
*/

 void CCaptureWinDirectx::ResizeWindow(int w, int h)
{
   //RECT rcW, rcC;
   //int xExtra, yExtra;
   //int cyBorder = GetSystemMetrics(SM_CYBORDER);

   //gnRecurse++;

   //GetWindowRect(ghwndApp, &rcW);
   //GetClientRect(ghwndApp, &rcC);
   //xExtra = rcW.right - rcW.left - rcC.right;
   //yExtra = rcW.bottom - rcW.top - rcC.bottom + cyBorder + statusGetHeight();

   //rcC.right = w;
   //rcC.bottom = h;
   //SetWindowPos(ghwndApp, NULL, 0, 0, rcC.right + xExtra,
   //   rcC.bottom + yExtra, SWP_NOZORDER | SWP_NOMOVE);

   //// we may need to recurse once.  But more than that means the window cannot
   //// be made the size we want, trying will just stack fault.
   ////
   //if(gnRecurse == 1 && ((rcC.right + xExtra != rcW.right - rcW.left && w > GetSystemMetrics(SM_CXMIN)) ||
   //   (rcC.bottom + yExtra != rcW.bottom - rcW.top)))
   //   ResizeWindow(w,h);

   //gnRecurse--;
}

//void CCaptureWinDirectx::ResizeVideoWindow(void)
//{
  //  // Resize the video preview window to match owner window size
  //  if (g_pWc/*pVideoWindow*/)
  //  {
  ////      RECT rc;
  ////      
  ////      // Make the preview video fill our window
  ////      GetClientRect(ghApp, &rc);
 
  ////      pVideoWindow->SetWindowPosition(0, 0, rc.right, rc.bottom);
 
  //      long lWidth, lHeight; 
  //      g_pWc->GetNativeVideoSize(&lWidth, &lHeight, NULL, NULL); 
 
  //      RECT rcSrc, rcDest;
  //      SetRect(&rcSrc, 0, 0, lWidth, lHeight); 
  //  
  //      GetClientRect(ghApp, &rcDest); 
  //      SetRect(&rcDest, 0, 0, rcDest.right, rcDest.bottom); 
  //  
  //      g_pWc->SetVideoPosition(&rcSrc, &rcDest); 
  //  }
//}

BOOL CCaptureWinDirectx::isPreviewEnabled()  {
   //long visible = NULL;
   //if (pVideoWindow) { 
   //   HRESULT hr = pVideoWindow->get_Visible(&visible);
   //   if (SUCCEEDED(hr)) {
   //      if ( visible == OATRUE ) {
   //         return TRUE;
   //      } else {
   //         return FALSE;
   //      }
   //   } else { 
   //      return FALSE;
   //   }
   //} else {
   //   return FALSE;
   //}
   return FALSE;
}

/**
*----------------------------------------------------------------------
*
* CCaptureWinDirectxOwnerWindowProc
*    process  WM_USER+1 message (change zoom)
*----------------------------------------------------------------------
*/
LRESULT APIENTRY CCaptureWinDirectxOwnerWindowProc(
    HWND hwnd, 
    UINT uMsg, 
    WPARAM wParam, 
    LPARAM lParam) 
{ 
   //CCaptureWinDirectx* capture = (CCaptureWinDirectx*) GetWindowLong(hwnd, GWL_ID);
   //if (uMsg == WM_USER+1) {
   //   double zoom;
   //   if ( HIWORD(lParam) == 1 ) {
   //      zoom = (double) LOWORD(lParam);
   //   } else {
   //      zoom = (double) 1.0 / LOWORD(lParam);
   //   }
   //   int width  = capture->getImageWidth();
   //   int height = capture->getImageHeight();

   //   capture->setWindowSize((int) (width * zoom),(int)(height *zoom));
   //   return TRUE; 
   //} else {
   //   //return DefWindowProc(hwnd, uMsg, wParam, lParam);
   //   if ( capture->previousOwnerWindowProc != 0 && capture->previousOwnerWindowProc != (LONG)CCaptureWinDirectxOwnerWindowProc) {
   //      return CallWindowProc((WNDPROC)capture->previousOwnerWindowProc, hwnd, uMsg, wParam, lParam);
   //   } else {
   //      //return DefWindowProc(hwnd, uMsg, wParam, lParam);
   //      return TRUE;
   //   }
   //}
   return TRUE;
} 

/**
*----------------------------------------------------------------------
*
* setPreview
*    enable/disable preview
*----------------------------------------------------------------------
*/
void CCaptureWinDirectx::setPreview(BOOL value,int owner) {
   //HWND hwnd = NULL;
   ////CComPtr<IVideoWindow> pVideoWindow;
   //HRESULT hr = S_OK;


   ////hr = pFilterGraph->QueryInterface(&pVideoWindow);

   //if ( value == TRUE ) {
   //   if (SUCCEEDED(hr)) {
   //      long visible = NULL;
   //      hr = pVideoWindow->get_Visible(&visible);
   //      if ( visible == OATRUE ) {
   //         // preview is already set
   //         return;
   //      }
   //   }
   //   if (SUCCEEDED(hr))
   //      hr = pVideoWindow->put_Owner((OAHWND)owner);
   //   if (SUCCEEDED(hr))
   //      hr = pVideoWindow->put_WindowStyle(WS_CHILD | WS_CLIPCHILDREN);
   //   //if (SUCCEEDED(hr))
   //   //   hr = pVideoWindow.CopyTo(ppVideoWindow);

   //   if (SUCCEEDED(hr)) {
   //      ownerHwnd = owner;
   //      previousOwnerUserdata   = SetWindowLong((HWND)owner, GWL_ID,(LONG) this);
   //      previousOwnerWindowProc = SetWindowLong((HWND)owner, GWL_WNDPROC,(LONG) CCaptureWinDirectxOwnerWindowProc); 
   //   }
   //   if (SUCCEEDED(hr)) {
   //      hr = pVideoWindow->SetWindowPosition(0, 0, getImageWidth(), getImageHeight());
   //   }
   //   if (SUCCEEDED(hr))
   //      hr = pVideoWindow->put_Visible(OATRUE);
   //   if (SUCCEEDED(hr) && pMediaControl)
   //     hr = pMediaControl->Run();

   //} else {
   //   if (SUCCEEDED(hr)) {
   //      long visible = NULL;
   //      hr = pVideoWindow->get_Visible(&visible);
   //      if ( visible == OAFALSE ) {
   //         // preview is already disabled
   //         return;
   //      }
   //   }
   //   if (SUCCEEDED(hr) && pMediaControl)
   //     hr = pMediaControl->Stop();
   //   if (SUCCEEDED(hr))
   //      hr = pVideoWindow->put_Owner((OAHWND)NULL);
   //   if (SUCCEEDED(hr))
   //      hr = pVideoWindow->put_Visible(OAFALSE);
   //   if (SUCCEEDED(hr)) {
   //      SetWindowLong((HWND)ownerHwnd, GWL_ID, previousOwnerUserdata );
   //      SetWindowLong((HWND)ownerHwnd, GWL_WNDPROC, previousOwnerWindowProc);
   //      previousOwnerUserdata = 0;
   //      previousOwnerWindowProc = 0;
   //   }
   //}
}

BOOL CCaptureWinDirectx::getOverlay()  {
   return FALSE;
}
void CCaptureWinDirectx::setOverlay(BOOL value) {
}

BOOL CCaptureWinDirectx::getPreviewRate(int *rate, char* errorMessage){
   return FALSE;
}

BOOL CCaptureWinDirectx::setPreviewRate(int rate, char* errorMessage){
   return FALSE;
}

void CCaptureWinDirectx::setPreviewScale(BOOL scale){
}

BOOL CCaptureWinDirectx::getCaptureAudio(){ 
   return FALSE; 
}

void CCaptureWinDirectx::setCaptureAudio(BOOL value){
}

BOOL CCaptureWinDirectx::getVideoParameter(char *result, int command, char* errorMessage) {
   return FALSE  ; 
}

BOOL CCaptureWinDirectx::setVideoParameter(int paramValue, int command, char * errorMessage) {
   return TRUE;
}

BOOL CCaptureWinDirectx::setWhiteBalance(char *mode, int red, int blue, char * errorMessage){
   return TRUE;
}

BOOL CCaptureWinDirectx::setVideoFormat(char *formatname, char *errorMessage){
   BOOL result;
   HRESULT hr = S_OK;
   //CComPtr<IBaseFilter> pFilter;
   //int width, height;

   //if (strcmp(formatname, "VGA") == 0) {
   //   width = 640;
   //   height = 480;
   //} else if (strcmp(formatname, "CIF") == 0) {
   //   width = 352;
   //   height = 288;
   //} else if (strcmp(formatname, "SIF") == 0) {
   //   width = 320;
   //   height = 240;
   //} else if (strcmp(formatname, "SSIF") == 0) {
   //   width = 240;
   //   height = 176;
   //} else if (strcmp(formatname, "QCIF") == 0) {
   //   width = 176;
   //   height = 144;
   //} else if (strcmp(formatname, "QSIF") == 0) {
   //   width = 160;
   //   height = 120;
   //} else if (strcmp(formatname, "SQCIF") == 0) {
   //   width = 128;
   //   height = 96;
   //} else {
   //   sprintf(errorMessage, "Unknown format: %s", formatname);
   //   return FALSE;
   //}

   //if (pFilterGraph == NULL) {
   //   sprintf(errorMessage,"error: no video source initialized"); 
   //   return FALSE;
   //}

   //hr = pFilterGraph->FindFilterByName(CAPTURE_FILTER_NAME, &pFilter);
   //if (SUCCEEDED(hr)) {
   //   CComPtr<IPin> pCapturePin;
   //   hr = FindPinByCategory(pFilter, PIN_CATEGORY_CAPTURE, &pCapturePin);
   //   if (SUCCEEDED(hr) && pCapturePin) {
   //      CComPtr<IAMStreamConfig> pStreamConfig;
   //      hr = pCapturePin.QueryInterface(&pStreamConfig);
   //      if (SUCCEEDED(hr)) {
   //         AM_MEDIA_TYPE *pmt = 0;
   //         hr = pStreamConfig->GetFormat(&pmt);
   //         if (SUCCEEDED(hr)) {
   //            if (pmt->formattype == FORMAT_VideoInfo) {
   //               VIDEOINFOHEADER *pvih = reinterpret_cast<VIDEOINFOHEADER *>(pmt->pbFormat);
   //               pvih->bmiHeader.biWidth = width;
   //               pvih->bmiHeader.biHeight = height;
   //               hr = pStreamConfig->SetFormat(pmt);
   //               if (hr == VFW_E_NOT_STOPPED || hr == VFW_E_WRONG_STATE)
   //               {
   //                  VideoStop();
   //                  DisconnectFilterGraph(pFilterGraph);
   //                  hr = pStreamConfig->SetFormat(pmt);
   //                  ConnectFilterGraph(&spec,pFilterGraph);
   //                  //if (SUCCEEDED(hr))
   //                  //   hr = pVideoWindow->put_Owner((OAHWND)NULL);
   //                  VideoStart();

   //               }
   //            }
   //            FreeMediaType(pmt);
   //         }
   //      }
   //   }
   //}

   //if (SUCCEEDED(hr)) {
   //   long cbData = 0;
   //   AM_MEDIA_TYPE mt;
   //   ZeroMemory(&mt, sizeof(AM_MEDIA_TYPE));

   //   if (SUCCEEDED(hr))
   //      hr = pSampleGrabber->GetConnectedMediaType(&mt);

   //   // Copy the bitmap info from the media type structure
   //   VIDEOINFOHEADER *pvih = reinterpret_cast<VIDEOINFOHEADER *>(mt.pbFormat);
   //   BITMAPINFOHEADER bih;
   //   if (SUCCEEDED(hr))
   //   {
   //      ZeroMemory(&bih, sizeof(BITMAPINFOHEADER));
   //      CopyMemory(&bih, &pvih->bmiHeader, sizeof(BITMAPINFOHEADER));
   //      if (mt.cbFormat > 0)
   //         CoTaskMemFree(mt.pbFormat);
   //   }

   //   // Get the image data - first finding out how much space to allocate.
   //   // Copy the image into the buffer.
   //   //if (SUCCEEDED(hr)) {
   //   //   hr = pSampleGrabber->GetCurrentBuffer(&cbData, NULL);
   //   //}      
   //   grabBufferWidth = bih.biWidth;
   //   grabBufferHeight = bih.biHeight;
   //   grabBufferPixelSize = bih.biBitCount / 8;
   //}
   //if (FAILED(hr)) {
   //   char temp[1024];
   //   sprintf(errorMessage,"Error setVideoFormat =%s", Win32Error(temp,hr));
   //   result = FALSE;
   //} else {
   //   result = TRUE;
   //}

result = TRUE;
   return result;
}




/**
*----------------------------------------------------------------------
*
* capabilities
*
*----------------------------------------------------------------------
*/

BOOL CCaptureWinDirectx::hasOverlay() {
   return FALSE;
}

BOOL CCaptureWinDirectx::hasDlgVideoFormat() {
   BOOL result = FALSE;
   ISpecifyPropertyPages *pSpec;
   CAUUID cauuid;

   // Check video capture capture pin
   IAMStreamConfig *pSC;

   HRESULT hr = pCaptureGraphBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
      &MEDIATYPE_Interleaved,
      pVideoCaptureSource, IID_IAMStreamConfig, (void **)&pSC);
   if(FAILED(hr))
      hr = pCaptureGraphBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
      &MEDIATYPE_Video, pVideoCaptureSource,
      IID_IAMStreamConfig, (void **)&pSC);

   if(SUCCEEDED(hr))
   {
      hr = pSC->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec);
      if(SUCCEEDED(hr))
      {
         hr = pSpec->GetPages(&cauuid);
         if(SUCCEEDED(hr) && cauuid.cElems > 0)
         {
            result = TRUE;
         }
         pSpec->Release();
      }
      pSC->Release();
   }

   return result;
}

BOOL CCaptureWinDirectx::hasDlgVideoSource() {
   BOOL result = FALSE;
   ISpecifyPropertyPages *pSpec;
   CAUUID cauuid;

   // Check the video capture filter itself
   HRESULT hr = pVideoCaptureSource->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec);
   if(SUCCEEDED(hr))
   {
      hr = pSpec->GetPages(&cauuid);
      if(SUCCEEDED(hr) && cauuid.cElems > 0)
      {
         result = TRUE;
      }
      pSpec->Release();
   }

   return result;
}

BOOL CCaptureWinDirectx::hasDlgVideoDisplay() {
   return FALSE;
}



/**
*----------------------------------------------------------------------
*
* window position
*
*----------------------------------------------------------------------
*/

void CCaptureWinDirectx::getWindowPosition(int *x1, int *y1,int *x2,int *y2) {
}

void CCaptureWinDirectx::setWindowPosition(int x1, int y1,int x2,int y2) {
}

void CCaptureWinDirectx::setWindowSize(int width, int height) {

   //if ( pVideoWindow) {
   //   pVideoWindow->put_Width((long) width ); 
   //   pVideoWindow->put_Height((long) height ); 
   //}
};


/**
*----------------------------------------------------------------------
*
* configuration dialogs
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinDirectx::openDlgVideoFormat(char* errorMessage) {
   
   // You can change this pin's output format in these dialogs.
   // If the capture pin is already connected to somebody who's
   // fussy about the connection type, that may prevent using
   // this dialog(!) because the filter it's connected to might not
   // allow reconnecting to a new format. (EG: you switch from RGB
   // to some compressed type, and need to pull in a decoder)
   // I need to tear down the graph downstream of the
   // capture filter before bringing up these dialogs.
   // In any case, the graph must be STOPPED when calling them.
   if(fWantPreview) {
      StopPreview();  // make sure graph is stopped
   } else {
      StopGrabFrame();
   }

   // The capture pin that we are trying to set the format on is connected if
   // one of these variable is set to TRUE. The pin should be disconnected for
   // the dialog to work properly.
   if(fCaptureGraphBuilt || fPreviewGraphBuilt || fGrabFrameGraphBuilt)
   {
      TearDownGraph();    // graph could prevent dialog working
   }

   IAMStreamConfig *pSC;
   HRESULT hr = pCaptureGraphBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
      &MEDIATYPE_Interleaved, pVideoCaptureSource,
      IID_IAMStreamConfig, (void **)&pSC);

   if(hr != NOERROR)
      hr = pCaptureGraphBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
      &MEDIATYPE_Video, pVideoCaptureSource,
      IID_IAMStreamConfig, (void **)&pSC);

   ISpecifyPropertyPages *pSpec;
   CAUUID cauuid;

   hr = pSC->QueryInterface(IID_ISpecifyPropertyPages,
      (void **)&pSpec);

   if(hr == S_OK)
   {
      hr = pSpec->GetPages(&cauuid);
      hr = OleCreatePropertyFrame(ownerHwnd, 30, 30, NULL, 1,
         (IUnknown **)&pSC, cauuid.cElems,
         (GUID *)cauuid.pElems, 0, 0, NULL);

      // !!! What if changing output formats couldn't reconnect
      // and the graph is broken?  Shouldn't be possible...

      if(pVideoStreamConfigure)
      {
         AM_MEDIA_TYPE *pmt;
         // get format being used NOW
         hr = pVideoStreamConfigure->GetFormat(&pmt);

         // DV capture does not use a VIDEOINFOHEADER
         if(hr == NOERROR)
         {
            if(pmt->formattype == FORMAT_VideoInfo)
            {
               // resize our window to the new capture size
               ResizeWindow(HEADER(pmt->pbFormat)->biWidth,
                  abs(HEADER(pmt->pbFormat)->biHeight));
            }
            DeleteMediaType(pmt);
         }
      }

      CoTaskMemFree(cauuid.pElems);
      pSpec->Release();
   }

   pSC->Release();
   if(fWantPreview)
   {
      BuildPreviewGraph(errorMessage);
      StartPreview(errorMessage);
   } else  {
      BuildGrabFrameGraph(errorMessage);
      StartGrabFrame(errorMessage);
   }



   return TRUE;
}

/**
*----------------------------------------------------------------------
*
* open video source dialog box 
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinDirectx::openDlgVideoSource(char* errorMessage) {
   BOOL result;
   pMediaControl->Stop(); // Stop the graph.

   // Query the capture filter for the IAMVfwCaptureDialogs interface.
   IAMVfwCaptureDialogs *pVfw = 0;
   HRESULT hr = pVideoCaptureSource->QueryInterface(IID_IAMVfwCaptureDialogs, (void**)&pVfw);

 

     //hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
     //                                 &MEDIATYPE_Video, gcap.pVCap,
     //                                 IID_IAMVfwCaptureDialogs, (void **)&gcap.pDlg);
     //graphBuilder2_->FindInterface( pCategory, pType, pf, riid, ppint );

   //HRESULT hr = pCaptureGraphBuilder->FindInterface(&PIN_CATEGORY_CAPTURE, &MEDIATYPE_Video, pVideoCaptureSource, IID_IAMVfwCaptureDialogs, (void**) &pVfw);



   if (SUCCEEDED(hr))
   {
      // Check if the device supports VWF dialog box.
      if (S_OK == pVfw->HasDialog(VfwCaptureDialog_Source))
      {
         // Show the dialog box.
         HWND hwndParent = 0; // fenetre du bureau par defaut
         hr = pVfw->ShowDialog(VfwCaptureDialog_Source, hwndParent);
         result = TRUE; 
      } else {
         sprintf(errorMessage, "Error camera dont have video source configuration dialog");
         result = FALSE; 
      }
   } else {
      // Check if the device supports SpecifyPropertyPages dialog box.
      ISpecifyPropertyPages *pSpec;
      CAUUID cauuid;

      hr = pVideoCaptureSource->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec);
      if(hr == S_OK) {
         hr = pSpec->GetPages(&cauuid);
         HWND hwndParent = 0; 
         hr = OleCreatePropertyFrame(hwndParent, 30, 30, NULL, 1,
            (IUnknown **)&pVideoCaptureSource, cauuid.cElems,
            (GUID *)cauuid.pElems, 0, 0, NULL);

         CoTaskMemFree(cauuid.pElems);
         pSpec->Release();
         result = TRUE;
      } else {
         sprintf(errorMessage, "Error queryinterface VfwCaptureDialogs hr=0x%x", hr);
         result = FALSE;
      }
   }
   pMediaControl->Run();

   return result;
}

BOOL CCaptureWinDirectx::openDlgVideoDisplay(char* errorMessage) {
   return FALSE;
}

BOOL CCaptureWinDirectx::openDlgVideoCompression(char* errorMessage) {
   return FALSE;
}




/**
 *----------------------------------------------------------------------
 * startCapture
 *    starts streaming video capture with default saving method
 *    !!file space allocation must be done before calling startCaptureNoFile
 *
 * Parameters:
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    allocate file space
 *    starts the capture sequence with saving file
 *----------------------------------------------------------------------
 */
BOOL CCaptureWinDirectx::startCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName) {
   BOOL result ;
   result = TRUE;

   return result;
}


/**
 *----------------------------------------------------------------------
 * startCaptureNoFile
 *    starts streaming video capture. Frame are processed by a specific callback
 *    !!file space allocation must be done before calling startCaptureNoFile
 *
 * Parameters:
 *    callback : specific callback  (see capSetCallbackOnVideoStream documentation)
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    declare the specific callback on video stream
 *    starts the capture sequence with no file
 *----------------------------------------------------------------------
 */
BOOL CCaptureWinDirectx::startCaptureNoFile(FARPROC  callback, long userData) {
   return FALSE;
}

/**
 *----------------------------------------------------------------------
 * abortCapture
 *    abort the current capture
 *
 * Parameters:
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    halt step capture at the current position
 *----------------------------------------------------------------------
 */
BOOL CCaptureWinDirectx::abortCapture() {
   return FALSE;
}

/**
 *----------------------------------------------------------------------
 * isCapturingNow
 *    return TRUE if capture is running
 *
 * Parameters:
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    refresh capStatus structure
 *
 *----------------------------------------------------------------------
 */
int CCaptureWinDirectx::isCapturingNow()
{
   return FALSE;
}


/**
*----------------------------------------------------------------------
* grabFrame
*  grab a frame from the video stream
*
* Parameters:
*    
* Results:
*    TRUE or FALSE.
* Side effects:
*
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinDirectx::grabFrame(char *errorMessage)
{
   // l'image est capturée par getGrabbedFrame()
   return TRUE;
}


/**
 *----------------------------------------------------------------------
 * getGrabbedFrame
 *    returns grabbeb frame
 *
 * Parameters:
 *    longExposure : 
 * Results:
 *    frame buffer , or NULL.
 * Side effects:
 *    
 *
 *----------------------------------------------------------------------
 */
unsigned char * CCaptureWinDirectx::getGrabbedFrame( char *errorMessage) {
   long evCode;
   long size;
   pMediaEvent->WaitForCompletion(2000, &evCode);
   pSampleGrabber->GetCurrentBuffer(&size, NULL);
   if( grabBuffer != NULL) {
         free(grabBuffer);
   }   
   grabBuffer = (unsigned char *) calloc(size, 1); 
   pSampleGrabber->GetCurrentBuffer(&size, (long*) grabBuffer);
   
   return grabBuffer;
}



void CCaptureWinDirectx::BSTRtoASC (BSTR str, char * &strRet) 
{ 
  if ( str != NULL ) 
  { 
  unsigned long length = WideCharToMultiByte (CP_ACP, 0, str, SysStringLen(str), 
  NULL, 0, NULL, NULL); 
  strRet = new char[length]; 
  length = WideCharToMultiByte (CP_ACP, 0, str, SysStringLen(str),  
  reinterpret_cast <char *>(strRet), length, NULL, NULL); 
  strRet[length] = '\0'; 
  } 
} 

char * CCaptureWinDirectx::Win32Error(char * szPrefix, HRESULT hr)
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
    return szPrefix;
}

//=========================================================================


BOOL CCaptureWinDirectx::StartGrabFrame(char *errorMessage) {
   if(fGrabbingFrame) {
      return TRUE;
   }

   if(!fGrabFrameGraphBuilt) {
      return FALSE;
   }

   // run the graph

   HRESULT hr = pMediaControl->Run();
   if (FAILED(hr))
   {
      pMediaControl->Stop();
      sprintf(errorMessage, "Error MediaControl run hr=0x%x", hr);
      return FALSE;
   }

   fGrabbingFrame = TRUE;
   return TRUE;

}

// stop the capture graph
//
BOOL CCaptureWinDirectx::StopGrabFrame()
{
   // way ahead of you
   if(!fGrabbingFrame)
   {
      return FALSE;
   }

   // stop the graph
   IMediaControl *pMC = NULL;
   HRESULT hr = pFilterGraph->QueryInterface(IID_IMediaControl, (void **)&pMC);
   if(SUCCEEDED(hr))
   {
      hr = pMC->Stop();
      pMC->Release();
   }
   if(FAILED(hr))
   {
      fGrabbingFrame = FALSE;
      //sprintf(errorMessage, "Error queryinterface VfwCaptureDialogs hr=0x%x", hr);
      return FALSE;
   }

   fGrabbingFrame = FALSE;
   return TRUE;
}

void CCaptureWinDirectx::StartPreview(char* errorMessage) {

}


void CCaptureWinDirectx::StopPreview() {

}


//=========================================================================
// Graph utilities
//=========================================================================



BOOL CCaptureWinDirectx::BuildGrabFrameGraph(char *errorMessage) {
   HRESULT hr;
   AM_MEDIA_TYPE *pmt=0;

   // we have one already
   if(fGrabFrameGraphBuilt)
      return TRUE;

   // No rebuilding while we're running
   if(fCapturing || fPreviewing || fGrabbingFrame)
      return FALSE;

   // We don't have the necessary capture filters
   if(pVideoCaptureSource == NULL)
      return FALSE;
   if(pAudioCaptureSource == NULL && fCapAudio)
      return FALSE;

   // we already have another graph built... tear down the old one
   if(fPreviewGraphBuilt || fCaptureGraphBuilt) {
      TearDownGraph();
   }

   pVideoCaptureSource->AddRef();

   // Add SampleGrabber filter to the graph.
   hr = pFilterGraph->AddFilter(pVideoCaptureSource, L"Source Device");
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error Add filter pVideoCaptureSource hr=0x%x", hr);
      TearDownGraph();
      return FALSE;
   }

   // Create the Sample Grabber filter.
   IBaseFilter *pSampleGrabberFilter = NULL;
   hr = CoCreateInstance(CLSID_SampleGrabber, NULL, CLSCTX_INPROC_SERVER,
      IID_PPV_ARGS(&pSampleGrabberFilter));
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error create SampleGrabber hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }

   // Add SampleGrabber filter to the graph.
   hr = pFilterGraph->AddFilter(pSampleGrabberFilter, L"Sample Grabber");
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error addFilter SampleGrabber hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }

   // connect sourceFilter to SampleGrabberFilter
   IEnumPins *pEnum = NULL;
   IPin *pPin = NULL;
   hr = pVideoCaptureSource->EnumPins(&pEnum);
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error SourceDevice EnumPins hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }
   while (S_OK == pEnum->Next(1, &pPin, NULL))
   {
      hr = ConnectFilters(pFilterGraph, pPin, pSampleGrabberFilter);
      SafeRelease(&pPin);
      if (SUCCEEDED(hr))
      {
         break;
      }
   }
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error ConnectFilters FilterGraph to SampleGrabberFilter hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }

   // configure SampleGrabber
   hr = pSampleGrabberFilter->QueryInterface(IID_PPV_ARGS(&pSampleGrabber));
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error QueryInterface pSampleGrabber hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }
   AM_MEDIA_TYPE mt;
   ZeroMemory(&mt, sizeof(mt));
   mt.majortype = MEDIATYPE_Video;
   mt.subtype = MEDIASUBTYPE_RGB24;

   hr = pSampleGrabber->SetMediaType(&mt);
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error SetMediaType hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }

   pSampleGrabber->SetOneShot(TRUE);
   pSampleGrabber->SetBufferSamples(TRUE);

   // set null filter output renderer
   IBaseFilter *pNullFilter = NULL;
   hr = CoCreateInstance(CLSID_NullRenderer, NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&pNullFilter));
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error Create pNullFilter hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }
   hr = pFilterGraph->AddFilter(pNullFilter, L"Null Filter");
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error AddFilter pNullFilter hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }
   hr = ConnectFilters(pFilterGraph, pSampleGrabberFilter, pNullFilter);
   if (FAILED(hr)) {
      sprintf(errorMessage, "Error ConnectFilters SampleGrabberFilter to NullFilter hr=0x%x", hr);
      pVideoCaptureSource->Release();
      TearDownGraph();
      return FALSE;
   }

   //// Add Capture filter to the graph.
   //hr = pFilterGraph->AddFilter(pVideoCaptureSource, L"Video Capture");
   //if (FAILED(hr)) {
   //   sprintf(errorMessage, "Error AddFilter Video Capture hr=0x%x", hr);
   //   pVideoCaptureSource->Release();
   //   return FALSE;
   //}

   //pVideoCaptureSource->Release();

   //OAFilterState state;
   //hr = pMediaControl->GetState(INFINITE, &state);

   //AM_MEDIA_TYPE mt;
   ZeroMemory(&mt, sizeof(AM_MEDIA_TYPE));

   hr = pSampleGrabber->GetConnectedMediaType(&mt);
   if (hr != S_OK) {
      sprintf(errorMessage, "Error GetConnectedMediaType hr=0x%x", hr);
      return FALSE;
   }

   VIDEOINFOHEADER *pvih = reinterpret_cast<VIDEOINFOHEADER *>(mt.pbFormat);
   grabBufferWidth = pvih->bmiHeader.biWidth;
   grabBufferHeight = pvih->bmiHeader.biHeight;
   grabBufferPixelSize = pvih->bmiHeader.biBitCount / 8;

   DeleteMediaType(&mt);
   // All done.
   fGrabFrameGraphBuilt = TRUE;
   return TRUE;

}

BOOL CCaptureWinDirectx::BuildVideoCaptureGraph(char *errorMessage) {
    //int cy, cyBorder;
    //HRESULT hr;
    //BOOL f;
    AM_MEDIA_TYPE *pmt=0;

    // we have one already
    if(fCaptureGraphBuilt)
        return TRUE;

    // No rebuilding while we're running
    if(fCapturing || fPreviewing || fGrabbingFrame)
        return FALSE;

    // We don't have the necessary capture filters
    if(pVideoCaptureSource == NULL)
        return FALSE;
    if(pAudioCaptureSource == NULL && fCapAudio)
        return FALSE;

    // no capture file name yet... we need one first
    //if(wszCaptureFile[0] == 0)
    //{
    //    f = SetCaptureFile(ghwndApp);
    //    if(!f)
    //        return f;
    //}

    // we already have another graph built... tear down the old one
    if(fPreviewGraphBuilt || fGrabFrameGraphBuilt)
        TearDownGraph();

    //
    // We need a rendering section that will write the capture file out in AVI
    // file format
    //

    //GUID guid;
    //if( gcap.fMPEG2 )
    //{
    //    guid = MEDIASUBTYPE_Mpeg2;
    //}
    //else
    //{
    //    guid = MEDIASUBTYPE_Avi;
    //}

    //hr = gcap.pBuilder->SetOutputFileName(&guid, gcap.wszCaptureFile,
    //                                      &gcap.pRender, &gcap.pSink);
    //if(hr != NOERROR)
    //{
    //    ErrMsg(TEXT("Cannot set output file"));
    //    goto SetupCaptureFail;
    //}

    // Now tell the AVIMUX to write out AVI files that old apps can read properly.
    // If we don't, most apps won't be able to tell where the keyframes are,
    // slowing down editing considerably
    // Doing this will cause one seek (over the area the index will go) when
    // you capture past 1 Gig, but that's no big deal.
    // NOTE: This is on by default, so it's not necessary to turn it on

    // Also, set the proper MASTER STREAM

    //if( !gcap.fMPEG2 )
    //{
    //    hr = gcap.pRender->QueryInterface(IID_IConfigAviMux, (void **)&gcap.pConfigAviMux);
    //    if(hr == NOERROR && gcap.pConfigAviMux)
    //    {
    //        gcap.pConfigAviMux->SetOutputCompatibilityIndex(TRUE);
    //        if(gcap.fCapAudio)
    //        {
    //            hr = gcap.pConfigAviMux->SetMasterStream(gcap.iMasterStream);
    //            if(hr != NOERROR)
    //                ErrMsg(TEXT("SetMasterStream failed!"));
    //        }
    //    }
    //}

    //
    // Render the video capture and preview pins - even if the capture filter only
    // has a capture pin (and no preview pin) this should work... because the
    // capture graph builder will use a smart tee filter to provide both capture
    // and preview.  We don't have to worry.  It will just work.
    //

    // NOTE that we try to render the interleaved pin before the video pin, because
    // if BOTH exist, it's a DV filter and the only way to get the audio is to use
    // the interleaved pin.  Using the Video pin on a DV filter is only useful if
    // you don't want the audio.

    //if( !gcap.fMPEG2 )
    //{
    //    hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_CAPTURE,
    //                                     &MEDIATYPE_Interleaved,
    //                                     gcap.pVCap, NULL, gcap.pRender);
    //    if(hr != NOERROR)
    //    {
    //        hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_CAPTURE,
    //                                         &MEDIATYPE_Video,
    //                                         gcap.pVCap, NULL, gcap.pRender);
    //        if(hr != NOERROR)
    //        {
    //            ErrMsg(TEXT("Cannot render video capture stream"));
    //            goto SetupCaptureFail;
    //        }
    //    }

    //    if(gcap.fWantPreview)
    //    {
    //        hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_PREVIEW, &MEDIATYPE_Interleaved,
    //                                        gcap.pVCap, NULL, NULL);
    //        if(hr == VFW_S_NOPREVIEWPIN)
    //        {
    //            // preview was faked up for us using the (only) capture pin
    //            gcap.fPreviewFaked = TRUE;
    //        }
    //        else if(hr != S_OK)
    //        {
    //            hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_PREVIEW, &MEDIATYPE_Video,
    //                                             gcap.pVCap, NULL, NULL);
    //            if(hr == VFW_S_NOPREVIEWPIN)
    //            {
    //                // preview was faked up for us using the (only) capture pin
    //                gcap.fPreviewFaked = TRUE;
    //            }
    //            else if(hr != S_OK)
    //            {
    //                ErrMsg(TEXT("Cannot render video preview stream"));
    //                goto SetupCaptureFail;
    //            }
    //        }
    //    }
    //}
    //else
    //{
    //    SmartPtr< IBaseFilter > sink;
    //    if( &gcap.pSink )
    //    {
    //        gcap.pSink->QueryInterface( IID_IBaseFilter, reinterpret_cast<void **>( &sink ) );
    //    }

    //    hr = gcap.pBuilder->RenderStream(NULL,
    //                                     &MEDIATYPE_Stream,
    //                                     gcap.pVCap, NULL, sink);
    //}

    ////
    //// Render the audio capture pin?
    ////

    //if(!gcap.fMPEG2 && gcap.fCapAudio)
    //{
    //    hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_CAPTURE, &MEDIATYPE_Audio,
    //                                     gcap.pACap, NULL, gcap.pRender);
    //    if(hr != NOERROR)
    //    {
    //        ErrMsg(TEXT("Cannot render audio capture stream"));
    //        goto SetupCaptureFail;
    //    }
    //}

    ////
    //// Render the closed captioning pin? It could be a CC or a VBI category pin,
    //// depending on the capture driver
    ////

    //if(!gcap.fMPEG2  && gcap.fCapCC)
    //{
    //    hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_CC, NULL,
    //                                     gcap.pVCap, NULL, gcap.pRender);
    //    if(hr != NOERROR)
    //    {
    //        hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_VBI, NULL,
    //                                         gcap.pVCap, NULL, gcap.pRender);
    //        if(hr != NOERROR)
    //        {
    //            ErrMsg(TEXT("Cannot render closed captioning"));
    //            // so what? goto SetupCaptureFail;
    //        }
    //    }
    //    // To preview and capture VBI at the same time, we can call this twice
    //    if(gcap.fWantPreview)
    //    {
    //        hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_VBI, NULL,
    //                                         gcap.pVCap, NULL, NULL);
    //    }
    //}

    ////
    //// Get the preview window to be a child of our app's window
    ////

    //// This will find the IVideoWindow interface on the renderer.  It is
    //// important to ask the filtergraph for this interface... do NOT use
    //// ICaptureGraphBuilder2::FindInterface, because the filtergraph needs to
    //// know we own the window so it can give us display changed messages, etc.

    //if(!gcap.fMPEG2 && gcap.fWantPreview)
    //{
    //    hr = gcap.pFg->QueryInterface(IID_IVideoWindow, (void **)&gcap.pVW);
    //    if(hr != NOERROR && gcap.fWantPreview)
    //    {
    //        ErrMsg(TEXT("This graph cannot preview"));
    //    }
    //    else if(hr == NOERROR)
    //    {
    //        RECT rc;
    //        gcap.pVW->put_Owner((OAHWND)ghwndApp);    // We own the window now
    //        gcap.pVW->put_WindowStyle(WS_CHILD);    // you are now a child

    //        // give the preview window all our space but where the status bar is
    //        GetClientRect(ghwndApp, &rc);
    //        cyBorder = GetSystemMetrics(SM_CYBORDER);
    //        cy = statusGetHeight() + cyBorder;
    //        rc.bottom -= cy;

    //        gcap.pVW->SetWindowPosition(0, 0, rc.right, rc.bottom); // be this big
    //        gcap.pVW->put_Visible(OATRUE);
    //    }
    //}

    //// now tell it what frame rate to capture at.  Just find the format it
    //// is capturing with, and leave everything alone but change the frame rate
    //if( !gcap.fMPEG2 )
    //{
    //    hr = gcap.fUseFrameRate ? E_FAIL : NOERROR;
    //    if(gcap.pVSC && gcap.fUseFrameRate)
    //    {
    //        hr = gcap.pVSC->GetFormat(&pmt);

    //        // DV capture does not use a VIDEOINFOHEADER
    //        if(hr == NOERROR)
    //        {
    //            if(pmt->formattype == FORMAT_VideoInfo)
    //            {
    //                VIDEOINFOHEADER *pvi = (VIDEOINFOHEADER *)pmt->pbFormat;
    //                pvi->AvgTimePerFrame = (LONGLONG)(10000000 / gcap.FrameRate);
    //                hr = gcap.pVSC->SetFormat(pmt);
    //            }
    //            DeleteMediaType(pmt);
    //        }
    //    }
    //    if(hr != NOERROR)
    //        ErrMsg(TEXT("Cannot set frame rate for capture"));
    //}

    //// now ask the filtergraph to tell us when something is completed or aborted
    //// (EC_COMPLETE, EC_USERABORT, EC_ERRORABORT).  This is how we will find out
    //// if the disk gets full while capturing
    //hr = gcap.pFg->QueryInterface(IID_IMediaEventEx, (void **)&gcap.pME);
    //if(hr == NOERROR)
    //{
    //    gcap.pME->SetNotifyWindow((OAHWND)ghwndApp, WM_FGNOTIFY, 0);
    //}

    //// potential debug output - what the graph looks like
    //// DumpGraph(gcap.pFg, 1);

    //// Add our graph to the running object table, which will allow
    //// the GraphEdit application to "spy" on our graph


    //// All done.
    //gcap.fCaptureGraphBuilt = TRUE;
    //return TRUE;

//SetupCaptureFail:
//    TearDownGraph();
   return FALSE;
}

BOOL CCaptureWinDirectx::BuildPreviewGraph(char* errorMessage) {


   return FALSE;
}


void CCaptureWinDirectx::TearDownGraph()
{
    //SAFE_RELEASE(gcap.pSink);
    //SAFE_RELEASE(gcap.pConfigAviMux);
    //SAFE_RELEASE(gcap.pRender);
    //SAFE_RELEASE(gcap.pME);
    //SAFE_RELEASE(gcap.pDF);

    //if(gcap.pVW)
    //{
    //    // stop drawing in our window, or we may get wierd repaint effects
    //    gcap.pVW->put_Owner(NULL);
    //    gcap.pVW->put_Visible(OAFALSE);
    //    gcap.pVW->Release();
    //    gcap.pVW = NULL;
    //}

    // destroy the graph downstream of our capture filters
    if(pVideoCaptureSource)
        NukeDownstream(pVideoCaptureSource);
    //if(gcap.pACap)
    //    NukeDownstream(gcap.pACap);
    //if(pVideoCaptureSource)
    //    gcap.pBuilder->ReleaseFilters();

    fCaptureGraphBuilt = FALSE;
    fPreviewGraphBuilt = FALSE;
    fGrabFrameGraphBuilt = FALSE;
    //fPreviewFaked = FALSE;
}



//=========================================================================
// Filter utilities
//=========================================================================


// Tear down everything downstream of a given filter
void CCaptureWinDirectx::NukeDownstream(IBaseFilter *pf)
{
    IPin *pP=0, *pTo=0;
    ULONG u;
    IEnumPins *pins = NULL;
    PIN_INFO pininfo;

    if (!pf)
        return;

    HRESULT hr = pf->EnumPins(&pins);
    pins->Reset();

    while(hr == NOERROR)
    {
        hr = pins->Next(1, &pP, &u);
        if(hr == S_OK && pP)
        {
            pP->ConnectedTo(&pTo);
            if(pTo)
            {
                hr = pTo->QueryPinInfo(&pininfo);
                if(hr == NOERROR)
                {
                    if(pininfo.dir == PINDIR_INPUT)
                    {
                        NukeDownstream(pininfo.pFilter);
                        pFilterGraph->Disconnect(pTo);
                        pFilterGraph->Disconnect(pP);
                        pFilterGraph->RemoveFilter(pininfo.pFilter);
                    }
                    pininfo.pFilter->Release();
                }
                pTo->Release();
            }
            pP->Release();
        }
    }

    if(pins)
        pins->Release();
}


// Connect output pin to filter.
HRESULT CCaptureWinDirectx::ConnectFilters(
                       IGraphBuilder *pGraph, // Filter Graph Manager.
                       IPin *pOut,            // Output pin on the upstream filter.
                       IBaseFilter *pDest)    // Downstream filter.
{
   IPin *pIn = NULL;

   // Find an input pin on the downstream filter.
   HRESULT hr = FindUnconnectedPin(pDest, PINDIR_INPUT, &pIn);
   if (SUCCEEDED(hr))
   {
      // Try to connect them.
      hr = pGraph->Connect(pOut, pIn);
      pIn->Release();
   }
   return hr;
}

// Connect filter to input pin.
HRESULT CCaptureWinDirectx::ConnectFilters(IGraphBuilder *pGraph, IBaseFilter *pSrc, IPin *pIn)
{
   IPin *pOut = NULL;

   // Find an output pin on the upstream filter.
   HRESULT hr = FindUnconnectedPin(pSrc, PINDIR_OUTPUT, &pOut);
   if (SUCCEEDED(hr))
   {
      // Try to connect them.
      hr = pGraph->Connect(pOut, pIn);
      pOut->Release();
   }
   return hr;
}

// Connect filter to filter
HRESULT CCaptureWinDirectx::ConnectFilters(IGraphBuilder *pGraph, IBaseFilter *pSrc, IBaseFilter *pDest)
{
   IPin *pOut = NULL;

   // Find an output pin on the first filter.
   HRESULT hr = FindUnconnectedPin(pSrc, PINDIR_OUTPUT, &pOut);
   if (SUCCEEDED(hr))
   {
      hr = ConnectFilters(pGraph, pOut, pDest);
      pOut->Release();
   }
   return hr;
}

// Query whether a pin is connected to another pin.
//
// Note: This function does not return a pointer to the connected pin.

HRESULT CCaptureWinDirectx::IsPinConnected(IPin *pPin, BOOL *pResult)
{
    IPin *pTmp = NULL;
    HRESULT hr = pPin->ConnectedTo(&pTmp);
    if (SUCCEEDED(hr))
    {
        *pResult = TRUE;
    }
    else if (hr == VFW_E_NOT_CONNECTED)
    {
        // The pin is not connected. This is not an error for our purposes.
        *pResult = FALSE;
        hr = S_OK;
    }

    SafeRelease(&pTmp);
    return hr;
}


// Query whether a pin has a specified direction (input / output)
HRESULT CCaptureWinDirectx::IsPinDirection(IPin *pPin, PIN_DIRECTION dir, BOOL *pResult)
{
    PIN_DIRECTION pinDir;
    HRESULT hr = pPin->QueryDirection(&pinDir);
    if (SUCCEEDED(hr))
    {
        *pResult = (pinDir == dir);
    }
    return hr;
}

// Match a pin by pin direction and connection state.
HRESULT CCaptureWinDirectx::MatchPin(IPin *pPin, PIN_DIRECTION direction, BOOL bShouldBeConnected, BOOL *pResult)
{
    assert(pResult != NULL);

    BOOL bMatch = FALSE;
    BOOL bIsConnected = FALSE;

    HRESULT hr = IsPinConnected(pPin, &bIsConnected);
    if (SUCCEEDED(hr))
    {
        if (bIsConnected == bShouldBeConnected)
        {
            hr = IsPinDirection(pPin, direction, &bMatch);
        }
    }

    if (SUCCEEDED(hr))
    {
        *pResult = bMatch;
    }
    return hr;
}

// Return the first unconnected input pin or output pin.
HRESULT CCaptureWinDirectx::FindUnconnectedPin(IBaseFilter *pFilter, PIN_DIRECTION PinDir, IPin **ppPin)
{
    IEnumPins *pEnum = NULL;
    IPin *pPin = NULL;
    BOOL bFound = FALSE;

    HRESULT hr = pFilter->EnumPins(&pEnum);
    if (FAILED(hr))
    {
        goto done;
    }

    while (S_OK == pEnum->Next(1, &pPin, NULL))
    {
        hr = MatchPin(pPin, PinDir, FALSE, &bFound);
        if (FAILED(hr))
        {
            goto done;
        }
        if (bFound)
        {
            *ppPin = pPin;
            (*ppPin)->AddRef();
            break;
        }
        SafeRelease(&pPin);
    }

    if (!bFound)
    {
        hr = VFW_E_NOT_FOUND;
    }

done:
    SafeRelease(&pPin);
    SafeRelease(&pEnum);
    return hr;
}

void WINAPI CCaptureWinDirectx::DeleteMediaType(__inout_opt AM_MEDIA_TYPE *pmt)
{
    // allow NULL pointers for coding simplicity

    if (pmt == NULL) {
        return;
    }

    FreeMediaType(*pmt);
    CoTaskMemFree((PVOID)pmt);
}

void WINAPI CCaptureWinDirectx::FreeMediaType(__inout AM_MEDIA_TYPE& mt)
{
    if (mt.cbFormat != 0) {
        CoTaskMemFree((PVOID)mt.pbFormat);

        // Strictly unnecessary but tidier
        mt.cbFormat = 0;
        mt.pbFormat = NULL;
    }
    if (mt.pUnk != NULL) {
        mt.pUnk->Release();
        mt.pUnk = NULL;
    }
}
