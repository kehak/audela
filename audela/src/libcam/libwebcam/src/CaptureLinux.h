// CCaptureLinux.h: interface for the CCaptureLinux class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __CCAPTURELINUX_H__
#define __CCAPTURELINUX_H__

#include <linux/videodev.h> // pour video_mbuf

#include "Capture.h"
#include "CaptureListener.h"

// defines

// class
class CCaptureLinux : public CCapture {
  public:
    CCaptureLinux(char * portName);
    ~CCaptureLinux();
    BOOL initHardware(UINT uIndex, CCaptureListener * captureListener, char *errorMsg);
    BOOL connect(BOOL longexposure, UINT uIndex, char *errorMsg);
    BOOL disconnect(char *errorMsg);
    BOOL isConnected();


    // status
    BOOL hasDlgVideoFormat();
    BOOL hasDlgVideoSource();
    BOOL hasDlgVideoDisplay();

    BOOL openDlgVideoFormat();
    BOOL openDlgVideoSource();
    BOOL openDlgVideoDisplay();
    BOOL openDlgVideoCompression();

    unsigned int getImageWidth();
    unsigned int getImageHeight();

    // capture parameters
    BOOL isCapturingNow();
    BOOL getCaptureAudio();
    void setCaptureAudio(BOOL value);

    // Preview parameters and commands
    BOOL setPreviewRate(int rate, char* errorMessage);
    BOOL getPreviewRate(int *rate, char* errorMessage);
    void setPreviewScale(BOOL scale);
    BOOL isPreviewEnabled();
    void setPreview(BOOL value,int owner);
    BOOL hasOverlay();
    BOOL getOverlay();
    void setOverlay(BOOL value);
    BOOL setWhiteBalance(char *mode, int red, int blue, char * errorMessage);
    BOOL setVideoParameter(int paramValue, int command, char * errorMessage);
    BOOL getVideoParameter(char *result, int command, char* errorMessage);
    BOOL setVideoFormat(char *formatname, char *errorMessage);

    // single frame capture
    BOOL grabFrameNoStop();
    BOOL grabFrame(char *errorMessage);
    unsigned char * getGrabbedFrame(char *errorMessage);

    // AVI capture command
    BOOL startCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName);
    BOOL abortCapture(void);

    // window position
    void getWindowPosition(int *x1, int *y1,int *x2,int *y2);
    void setWindowPosition(int x1, int y1,int x2,int y2) ;
    void setWindowSize(int width, int height);
    //void setScrollPos(POINT * pt);

private :

   int IsPhilips;
   BOOL longExposure;
/**
 * webcam device (only for Linux). uses pwc and pwcx modules
 * - default: /dev/video0
 */
   char portName[128];

/**
 * Valid image number (used under Linux).
 * Pwc kernel module has some buffers and
 * when you take long exposure you
 * need to find which buffer contains your frame.
 *
 * This parameter says which frame is your valid frame
 * (how many read() calls you need), if is 0
 * auto detection is performed (less then 20 read() calls).
 * - dafault: 3
 */
   int validFrame;

/**
 * cam_fd, webcam device file descriptor.
 */
   int cam_fd;

/**
 * Buffer for yuv frame.
 * Used under Linux for keeping yuv frame
 */
   unsigned char *yuvBuffer;
   unsigned char *rgbBuffer;

/**
 * yuvBufferSize is size in bytes of yuvBuffer.
 */
   int yuvBufferSize;
   int currentWidth;
   int currentHeight;

/**
 * shutterSpeed remember the shutter speed.
 *
 * A negative value sets the shutter speed to automatic
 * (controlled by the camera's firmware).
 * A value of 0..65535 will set manual mode, where the values have
 * been calibrated such that 65535 is the longest possible exposure
 * time that I could find on any camera model. It is not a linear
 * scale, where a value of '1' is 1/65536th of a second, etc.
 *
 * Used under Linux.
 */
   int shutterSpeed;

/******************************************************************/
/*  variable  d'acces direct a la memoire video LINUX (M. Pujol)  */
/*                                                                */
/******************************************************************/
   struct video_mbuf mmap_mbuf ;
   unsigned char * mmap_buffer;
   long mmap_last_sync_buff;
   long mmap_last_capture_buff;

   int  webcam_smmapInit();
   void webcam_mmapSync();
   void webcam_mmapCapture();
   void webcam_mmapDelete();
   unsigned char * webcam_mmapLastFrame();
   void yuv420p_to_rgb24(unsigned char *yuv, unsigned char *rgb, int width, int height);
   void ng_color_yuv2rgb_init(void);


};

#endif

