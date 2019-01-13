// CCaptureWinDirectx.h: interface for the CCaptureWinDirectx class.
//
//////////////////////////////////////////////////////////////////////


#ifndef __CAPTURE_WIN_DIRECTX_H__
#define __CAPTURE_WIN_DIRECTX_H__


#include <windows.h>
#pragma warning(disable : 4995) // pour supprimer les warning warning C4995: 'sprintf': name was marked as #pragma deprecated
#include <dshow.h>
#include <d3d9.h>
#include <vmr9.h>
#include <Commctrl.h>
#include <list>
#include <string>

#include "Capture.h"
#include "CaptureListener.h"
#include "SampleGrabber.h"    //ISampleGrabber

// defines
#define FPS_TO_MS(f)             ((DWORD) ((double)1.0e6 / f))

#define DEF_CAPTURE_FPS          15
#define MIN_CAPTURE_FPS          (1.0 / 60)	// one frame per minute
#define MAX_CAPTURE_FPS          100

#define FPS_TO_MS(f)             ((DWORD) ((double)1.0e6 / f))
#define DEF_CAPTURE_RATE         FPS_TO_MS(DEF_CAPTURE_FPS)
#define MIN_CAPTURE_RATE         FPS_TO_MS(MIN_CAPTURE_FPS)
#define MAX_CAPTURE_RATE         FPS_TO_MS(MAX_CAPTURE_FPS)

//standard index size options
#define CAP_LARGE_INDEX          (30 * 60 * 60 * 3)	// 3 hrs @ 30fps
#define CAP_SMALL_INDEX          (30 * 60 * 15)	// 15 minutes @ 30fps

#define ONEMEG                   (1024L * 1024L)

#ifndef AVSTREAMMASTER_AUDIO
#define AVSTREAMMASTER_AUDIO            0	/* Audio master (VFW 1.0, 1.1) */
#endif
#ifndef AVSTREAMMASTER_NONE
#define AVSTREAMMASTER_NONE             1	/* No master */
#endif

// class
class CCaptureWinDirectx : public CCapture {
  public:
     CCaptureWinDirectx();
     virtual ~ CCaptureWinDirectx();

    BOOL initHardware(UINT uIndex, CCaptureListener * captureListener, char *errorMsg);
    BOOL connect(int longexposure, UINT iIndex, char *errorMsg);
    BOOL disconnect(char* errorMessage);
    BOOL isConnected();
    BOOL getDeviceList(::std::list<::std::string> &deviceList, char * errorMessage);

    //BOOL hasAudioHardware();
    BOOL hasDlgVideoFormat();
    BOOL hasDlgVideoSource();
    BOOL hasDlgVideoDisplay();

    BOOL openDlgVideoFormat(char* errorMessage);
    BOOL openDlgVideoSource(char* errorMessage);
    BOOL openDlgVideoDisplay(char* errorMessage);
    BOOL openDlgVideoCompression(char* errorMessage);

    unsigned int getImageWidth();
    unsigned int getImageHeight();
    
    // capture parameters
    //void getCaptureFileName(char *fileName, int maxSize);
    //void setCaptureFileName(char *fileName);
    //long getCaptureFileSize();
    //void setCaptureFileSize(long value);
    //BOOL allocCaptureFileSpace(long fileSize);
    //BOOL allocFileSpace();
    //BOOL getLimitEnabled();
    //void setLimitEnabled(BOOL value);
    int isCapturingNow();
    BOOL getCaptureAudio();
    void setCaptureAudio(BOOL value);
    //BOOL getCaptureToDisk();
    //void setCaptureToDisk(BOOL value);
    //unsigned long getCaptureRate();
    //void setCaptureRate(unsigned long value);
    //unsigned int getTimeLimit();
    //void setTimeLimit(unsigned int value);
    //unsigned int getStepCaptureAverageFrames();
    //void setStepCaptureAverageFrames(unsigned int value);
    //unsigned long getIndexSize();
    //void setIndexSize(unsigned long value);
    //BOOL getStepCaptureAt2x();
    //void setStepCaptureAt2x(BOOL value);
    //void setAudioFormat(LPWAVEFORMATEX value);
    //LPWAVEFORMATEX getAudioFormat();
    //DWORD getAudioFormatSize();
    //unsigned int getAVStreamMaster();
    //void setAVStreamMaster(unsigned int value);

    // Preview parameters and commands
    void setPreview(BOOL value, int owner);
    BOOL setPreviewRate(int rate, char* errorMessage);
    BOOL getPreviewRate(int *rate, char* errorMessage);
    void setPreviewScale(BOOL scale);
    BOOL hasOverlay();
    BOOL getOverlay();
    void setOverlay(BOOL value);
    BOOL isPreviewEnabled();
    BOOL getVideoParameter(char *result, int command, char* errorMessage);
    BOOL setVideoParameter(int paramValue, int command, char * errorMessage);
    BOOL setWhiteBalance(char *mode, int red, int blue, char * errorMessage);
    BOOL setVideoFormat(char *formatname, char *errorMessage);

    // single frame capture
    BOOL grabFrame(char *errorMessage);
    unsigned char * getGrabbedFrame(char *errorMessage);

    // AVI capture command
    BOOL startCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName);
    BOOL startCaptureNoFile(FARPROC callback, long userData);
    BOOL abortCapture(void);


    // window position
    void getWindowPosition(int *x1, int *y1,int *x2,int *y2);
    void setWindowPosition(int x1, int y1,int x2,int y2);
    void setWindowSize(int width, int height);

    // callbacks setters
    WNDPROC setPreviewWindowCallbackProc(WNDPROC callbackProc, long userData);
   LONG              previousOwnerWindowProc;

protected:
   IMoniker				*sourceDeviceList[5]; // liste des device
   
   // filtres du graphe
   IGraphBuilder     *pFilterGraph;
   ICaptureGraphBuilder2 * pCaptureGraphBuilder;
   IMediaControl     *pMediaControl;
   IMediaEventEx     *pMediaEvent;
   IBaseFilter       *pVideoCaptureSource;
   IBaseFilter       *pAudioCaptureSource;
   //IMediaSeeking     *pMediaSeeking;
   //IVideoWindow      *pVideoWindow;
   //IAMVideoControl   *pAMVideoControl;
   IAMStreamConfig   *pVideoStreamConfigure;  
   ISampleGrabber    *pSampleGrabber;
   unsigned char     *grabBuffer;
 
   CCaptureListener *captureListener;
     
   WNDPROC            wndproc;
   HWND               ownerHwnd;

   int               grabBufferWidth;
   int               grabBufferHeight;
   int               grabBufferPixelSize;
   LONG              previousOwnerUserdata;
   
   BOOL              fCaptureGraphBuilt;
   BOOL              fPreviewGraphBuilt;
   BOOL              fGrabFrameGraphBuilt;

   BOOL              fPreviewing;
   BOOL              fCapturing;
   BOOL              fGrabbingFrame;
   BOOL              fCapAudio;
   BOOL              fWantPreview;  // ou gfWantPreview ??
   WCHAR             wszCaptureFile[_MAX_PATH];
   
   BOOL StartGrabFrame(char *errorMessage);
   BOOL StopGrabFrame();
   void StartPreview(char* errorMessage);
   void StopPreview();
   void ResizeWindow(int w, int h);

   void BSTRtoASC (BSTR str, char * &strRet);
   char * Win32Error( char * szPrefix, HRESULT hr);
   

   // graph utilities
   BOOL BuildGrabFrameGraph(char *errorMessage);
   BOOL BuildVideoCaptureGraph(char *errorMessage);
   BOOL BuildPreviewGraph(char* errorMessage);
   void TearDownGraph();
   

   // filter utilities
   void NukeDownstream(IBaseFilter *pf);

   HRESULT ConnectFilters(
                       IGraphBuilder *pGraph, // Filter Graph Manager.
                       IPin *pOut,            // Output pin on the upstream filter.
                       IBaseFilter *pDest);    // Downstream filter.
   HRESULT ConnectFilters(IGraphBuilder *pGraph, IBaseFilter *pSrc, IPin *pIn);
   HRESULT ConnectFilters(IGraphBuilder *pGraph, IBaseFilter *pSrc, IBaseFilter *pDest);
   HRESULT IsPinConnected(IPin *pPin, BOOL *pResult);
   HRESULT IsPinDirection(IPin *pPin, PIN_DIRECTION dir, BOOL *pResult);
   HRESULT MatchPin(IPin *pPin, PIN_DIRECTION direction, BOOL bShouldBeConnected, BOOL *pResult);
   HRESULT FindUnconnectedPin(IBaseFilter *pFilter, PIN_DIRECTION PinDir, IPin **ppPin);   

   void WINAPI DeleteMediaType(__inout_opt AM_MEDIA_TYPE *pmt);
   void WINAPI FreeMediaType(__inout AM_MEDIA_TYPE& mt);

};

#endif		

