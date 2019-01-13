// CCaptureLinux.h: interface for the CCaptureLinux class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __CCAPTURELINUX_H__
#define __CCAPTURELINUX_H__

#include <linux/videodev2.h> // pour video_mbuf
#include "Capture.h"
#include "CaptureListener.h"


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
    unsigned char *bgrBuffer;

/**
 * yuvBufferSize is size in bytes of yuvBuffer.
 */
    int yuvBufferSize;
    unsigned int currentWidth;
    unsigned int currentHeight;

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
    class s_mmap_buffers {
        public :
        void *start;
        size_t length;
    };

    s_mmap_buffers * mmap_buffers;
    unsigned int n_mmap_buffers;

    BOOL capturing;

    long mmap_last_sync_buff;
    int mmap_last_buffer_index;

    void webcam_mmapSync();
    BOOL webcam_mmapCapture();
    void webcam_mmapDelete();
    unsigned char * webcam_mmapLastFrame();

    /* Conversion entre espaces de couleurs */
    void yuv420p_to_bgr24( unsigned char *yuv, unsigned char *rgb, int width, int height );
    /* YUYV -> RVB */
    void yuv422_to_bgr24( unsigned char *yuv, unsigned char *bgr, int width, int height );
    /* UYVY -> RVB */
    void yuv422alt_to_bgr24( unsigned char *yuv, unsigned char *bgr, int width, int height );
    void rgb24_to_bgr24( unsigned char *rgb_s, unsigned char *rgb_d, int width, int height );
    void ng_color_yuv2rgb_init( void );

    static const int IO_METHOD_NIL = 0;
    static const int IO_METHOD_READ = 1;
    static const int IO_METHOD_MMAP = 2;

    int alloc_driver_memory( unsigned int n_buffer );

    /* Format des données issues du pilote */
    inline unsigned int fourcc( unsigned char a, unsigned char b, unsigned char c, unsigned char d )
    {
        return ( (unsigned int) (((d)<<24) | (unsigned int)c<<16 | (unsigned int)b<<8) | (unsigned int)a );
    };

    static const int FORMAT_NIL = 0;
    static const int FORMAT_YUV422 = 1;
    static const int FORMAT_RGB24 = 2;
    static const int FORMAT_YUV420 = 4;
    static const int FORMAT_BAYER_GRBG = 8;
    static const int FORMAT_YUV422_ALT = 16;

    /* Nombre de buffers a allouer en mode mmap */
    static const int INITIAL_MMAPPED_BUFFERS_REQUEST = 4;

    class local_v4l2_control_value {
        public:
        bool enabled;
        int current;
        int minimum;
        int maximum;
        local_v4l2_control_value() {
            enabled = false;
            current = 0;
            minimum = 0;
            maximum = 0;
        };
    };

    class local_v4l2_control_flag {
        public:
        bool enabled;
        bool current;
        local_v4l2_control_flag() {
            enabled = false;
            current = false;
        };
    };

    class v4l2_parameters {
        public :
        int io;
        int data_format;
        v4l2_std_id stdid;
        local_v4l2_control_value brightness;
        local_v4l2_control_value gain;
        local_v4l2_control_flag auto_gain;
        local_v4l2_control_value shutter;
        local_v4l2_control_value sharpness;
        local_v4l2_control_value backlight;
        local_v4l2_control_value contrast;
        local_v4l2_control_value saturation;
        local_v4l2_control_value hue;
    };

    BOOL get_parameters( v4l2_parameters *, char * );
    BOOL select_parameters( v4l2_parameters *, char * );
    BOOL set_parameters( v4l2_parameters *, char * );
    void enumerate_menu( struct v4l2_queryctrl * queryctrl );
    BOOL set_control( int, int, local_v4l2_control_value *, char * );
    BOOL set_control( int, bool, local_v4l2_control_flag *, char * );


    v4l2_parameters * driver_params;

};
#endif // __CCAPTURELINUX_H__
