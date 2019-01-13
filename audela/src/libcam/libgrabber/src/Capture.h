// Capture.h: interface for the CCapture class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __CCAPTURE_H__
#define __CCAPTURE_H__

#if defined(OS_LIN)
#define BOOL  unsigned short
#define UINT  unsigned int
#define TRUE  1
#define FALSE 0
#endif

#include "CaptureListener.h"


/**
 * Some definitions for video source functions under Linux.
*/
#define RESTOREUSER 1
#define GETPICSETTINGS 2
#define RESTOREFACTORY 3
#define GETGAIN 4
#define GETSHARPNESS 5
#define GETSHUTTER 6
#define GETNOISE 7
#define GETCOMPRESSION 8
#define GETWHITEBALANCE 9
#define GETBACKLIGHT 10
#define GETFLICKER 11

#define SETGAIN 12
#define SETSHARPNESS 13
#define SETSHUTTER 14
#define SETNOISE 15
#define SETCOMPRESSION 16
#define SETBACKLIGHT 17
#define SETFLICKER 18

#define SETVALIDFRAME 40
#define GETVALIDFRAME 41

// class
class CCapture {

  public:
    virtual ~CCapture();
    virtual BOOL initHardware(UINT uIndex, CCaptureListener * captureListener, char *errorMsg)=0;
    virtual BOOL connect(BOOL longexposure, UINT uIndex,char *errorMsg)=0;
    virtual BOOL disconnect(char *errorMsg)=0;
    virtual BOOL isConnected()=0;

    virtual BOOL hasDlgVideoFormat()=0;
    virtual BOOL hasDlgVideoSource()=0;
    virtual BOOL hasDlgVideoDisplay()=0;

    virtual BOOL openDlgVideoFormat()=0;
    virtual BOOL openDlgVideoSource()=0;
    virtual BOOL openDlgVideoDisplay()=0;
    virtual BOOL openDlgVideoCompression()=0;

    // Preview parameters and commands
    virtual void setPreview(BOOL value,int owner)=0;
    virtual BOOL setPreviewRate(int rate, char* errorMessage)=0;
    virtual BOOL getPreviewRate(int *rate, char* errorMessage)=0;
    virtual void setPreviewScale(BOOL scale)=0;
    virtual void setOverlay(BOOL value)=0;
    virtual BOOL isPreviewEnabled()=0;
    virtual BOOL hasOverlay()=0;
    virtual BOOL getOverlay()=0;
    virtual BOOL getVideoParameter(char *result, int command, char* errorMessage)=0;
    virtual BOOL setVideoParameter(int paramValue, int command, char * errorMessage)=0;
    virtual BOOL setWhiteBalance(char *mode, int red, int blue, char * errorMessage)=0;
    virtual BOOL setVideoFormat(char *formatname, char *errorMessage)=0;
    //BOOL hasAudioHardware();
    virtual BOOL getCaptureAudio()=0;
    virtual void setCaptureAudio(BOOL value)=0;
    virtual unsigned int getImageWidth()=0;
    virtual unsigned int getImageHeight()=0;

    // single frame capture
    virtual BOOL grabFrame(char *errorMessage)=0;
    virtual unsigned char * getGrabbedFrame(char *errorMessage)=0;

    // AVI file capture command
    virtual BOOL startCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName)=0;
    virtual BOOL abortCapture(void)=0;
    virtual BOOL isCapturingNow()=0;

    // window position
    virtual void getWindowPosition(int *x1, int *y1,int *x2,int *y2)=0;
    virtual void setWindowPosition(int x1, int y1,int x2,int y2)=0;
    virtual void setWindowSize(int width, int height)=0;

};

#endif
