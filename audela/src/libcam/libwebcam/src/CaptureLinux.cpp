// Capture.cpp: implementation of the CCaptureLinux class.
//
//////////////////////////////////////////////////////////////////////

#include "sysexp.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/videodev.h>
#include <sys/ioctl.h>
#include <linux/ppdev.h>
#include <linux/parport.h>
#include <errno.h>
#include <sys/mman.h>
//extern int errno;

#include "pwc-ioctl.h"
#include <libcam/util.h>  // pour libcam_strupr

#include "CaptureLinux.h"


/**
 * Definitions and global variables for yuv420p_to_rgb24 conversion.
 * Code comes from xawtv.
*/

#define CLIP         320

# define RED_NULL    128
# define BLUE_NULL   128
# define LUN_MUL     256
# define RED_MUL     512
# define BLUE_MUL    512

#define GREEN1_MUL  (-RED_MUL/2)
#define GREEN2_MUL  (-BLUE_MUL/6)
#define RED_ADD     (-RED_NULL  * RED_MUL)
#define BLUE_ADD    (-BLUE_NULL * BLUE_MUL)
#define GREEN1_ADD  (-RED_ADD/2)
#define GREEN2_ADD  (-BLUE_ADD/6)

static unsigned int ng_yuv_gray[256];
static unsigned int ng_yuv_red[256];
static unsigned int ng_yuv_blue[256];
static unsigned int ng_yuv_g1[256];
static unsigned int ng_yuv_g2[256];
static unsigned int ng_clip[256 + 2 * CLIP];

#define GRAY(val)               ng_yuv_gray[val]
#define RED(gray,red)           ng_clip[ CLIP + gray + ng_yuv_red[red] ]
#define GREEN(gray,red,blue)    ng_clip[ CLIP + gray + ng_yuv_g1[red] + \
                                                       ng_yuv_g2[blue] ]
#define BLUE(gray,blue)         ng_clip[ CLIP + gray + ng_yuv_blue[blue] ]

/**
 * Frame with any pixel > REQUIRED_MAX_VALUE is detected
 * as valid frame (used in autodetection mode).
*/
#define REQUIRED_MAX_VALUE 150


/**
 * Default value of cam->validFrame parameter.
*/
#define VALID_FRAME 3

/*
typedef struct {
   char id[2];
   long filesize;
   short reserved[2];
   long headersize;
   long infosize;
   long width;
   long depth;
   short biplanes;
   short bits;
   long bicompression;
   long bisizeimage;
   long bixpelspermeter;
   long biypelspermeter;
   long biclrused;
   long biclrimportant;
} BMPHEAD;
*/


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCaptureLinux::CCaptureLinux(char * portName)
{
   strncpy(this->portName, portName,sizeof(this->portName));
   validFrame = VALID_FRAME;
   yuvBuffer = NULL;
   yuvBufferSize = 0;
   rgbBuffer = NULL;
   cam_fd = -1;
   IsPhilips = 0;
   shutterSpeed = -1;
   longExposure = FALSE;

}

CCaptureLinux::~CCaptureLinux()
{

   if (mmap_buffer) {
      webcam_mmapDelete();
   }
   if (cam_fd >= 0) {
      close(cam_fd);
      cam_fd = -1;
   }

   if (yuvBuffer != NULL) {
      free(yuvBuffer);
      yuvBuffer = NULL;
   }
   yuvBufferSize = 0;


}

/**
*----------------------------------------------------------------------
*
* create an instance of CCaptureLinux
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::initHardware(UINT uIndex, CCaptureListener * captureListener, char *errorMessage) {
   struct video_capability vcap;
   int type;

   /**
   * Window size, this function sets maximal as possible size,
   * usually it is 640 x 480 pixels.
   */
   struct pwc_probe probe;

   ng_color_yuv2rgb_init();
   if (-1 == (cam_fd = open(portName, O_RDONLY))) {
   //if (-1 == (cam_fd = open(portName, O_RDWR))) {
      sprintf(errorMessage, "Can't open %s - %s", portName, strerror(errno));
      return FALSE;
   }
//printf"initHardware %s cam_fd=%d\n",portName,cam_fd);
   /* Get camera capability */
   IsPhilips = 0;
   if (ioctl(cam_fd, VIDIOCGCAP, &vcap)) {
      strcpy(errorMessage, "Can't VIDIOCGCAP");
      close(cam_fd);
      cam_fd = -1;
      return FALSE;
   }
   /* Check if it is Philips compatible webcam,
    * supported by pwc and pwcx modules.
    */

   if (sscanf(vcap.name, "Philips %d webcam", &type) < 1) {
      /* No match yet; try the PROBE */

      if (ioctl(cam_fd, VIDIOCPWCPROBE, &probe)) {
         strcpy(errorMessage, "Can't VIDIOCPWCPROBE");
         close(cam_fd);
         cam_fd = -1;
         return FALSE;
      } else {
         if (strcmp(vcap.name, probe.name) == 0) {
            IsPhilips = 1;
         }
      }
   } else {
      IsPhilips = 1;
   }

   if (IsPhilips == 0) {
      sprintf(errorMessage, "%s - is not Philips compatible webcam", vcap.name);
      close(cam_fd);
      cam_fd = -1;
      return FALSE;
   }


   // VIDEO_PALETTE_GREY      1       /* Linear greyscale */
   // VIDEO_PALETTE_HI240     2       /* High 240 cube (BT848) */
   // VIDEO_PALETTE_RGB565    3       /* 565 16 bit RGB */
   //VIDEO_PALETTE_RGB24     4       /* 24bit RGB */
   //VIDEO_PALETTE_RGB32     5       /* 32bit RGB */
   //VIDEO_PALETTE_RGB555    6       /* 555 15bit RGB */
   //VIDEO_PALETTE_YUV422    7       /* YUV422 capture */
   //VIDEO_PALETTE_YUYV      8
   //VIDEO_PALETTE_UYVY      9       /* The great thing about standards is ... */
   //VIDEO_PALETTE_YUV420    10
   //VIDEO_PALETTE_YUV411    11      /* YUV411 capture */
   //VIDEO_PALETTE_RAW       12      /* RAW capture (BT848) */
   //VIDEO_PALETTE_YUV422P   13      /* YUV 4:2:2 Planar */
   //VIDEO_PALETTE_YUV411P   14      /* YUV 4:1:1 Planar */
   //VIDEO_PALETTE_YUV420P   15      /* YUV 4:2:0 Planar */
   //VIDEO_PALETTE_YUV410P   16      /* YUV 4:1:0 Planar */
   //VIDEO_PALETTE_PLANAR    13      /* start of planar entries */
   //VIDEO_PALETTE_COMPONENT 7       /* start of component entries */

   // j'inialise le mapping memoire du buffer de la camera
   if ( webcam_smmapInit() == 0 ) {
      // je fais une capture de test
      //webcam_mmapCapture();
   } else {
      sprintf(errorMessage, "error webcam_smmapInit");
      close(cam_fd);
      cam_fd = -1;
      return FALSE;
   }

   return TRUE;
}

/**
*----------------------------------------------------------------------
*
* connect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::connect(BOOL longExposure, UINT uIndex, char *errorMsg) {
   BOOL result;

   this->longExposure = longExposure;
   result = TRUE;

   return result;
}


/**
*----------------------------------------------------------------------
*
* disconnect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::disconnect(char *errorMsg) {
   BOOL   result = TRUE;

   return result;
}

/**
*----------------------------------------------------------------------
* isConnected
*  returns connected sate
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::isConnected() {
   BOOL   result = TRUE;
   return result;
}

/**
*----------------------------------------------------------------------
*
* accessors
*
*----------------------------------------------------------------------
*/

unsigned int CCaptureLinux::getImageWidth() {
    return currentWidth;
}

unsigned int CCaptureLinux::getImageHeight() {
    return currentHeight;
}

/*
unsigned long    CCaptureLinux::getVideoFormat(BITMAPINFO * pbi, int size ) {
   return capGetVideoFormat(hwndCap, pbi, size);
}
*/

BOOL CCaptureLinux::setVideoFormat(char *formatname, char *errorMessage)
{
   char ligne[128];
   int imax, jmax, box = 1;
   struct video_window win = { 0, 0, 640, 480, 0, 0, 0x0, 0 };

   //change to upper: void libcam_strupr(char *chainein, char *chaineout)
   libcam_strupr(formatname, ligne);

   imax = 0;
   jmax = 0;
   if (strcmp(ligne, "SAME") == 0) {
      box = 0;
   }
   if (strcmp(ligne, "VGA") == 0) {
      imax = 640;
      jmax = 480;
   } else if (strcmp(ligne, "CIF") == 0) {
      imax = 352;
      jmax = 288;
   } else if (strcmp(ligne, "SIF") == 0) {
      imax = 320;
      jmax = 240;
   } else if (strcmp(ligne, "SSIF") == 0) {
      imax = 240;
      jmax = 176;
   } else if (strcmp(ligne, "QCIF") == 0) {
      imax = 176;
      jmax = 144;
   } else if (strcmp(ligne, "QSIF") == 0) {
      imax = 160;
      jmax = 120;
   } else if (strcmp(ligne, "SQCIF") == 0) {
      imax = 128;
      jmax = 96;
   }
   if (jmax == 0 || imax == 0) {
      sprintf(errorMessage, "Unknown format: %s", formatname);
      return FALSE;
   }

   /* New buffer size */
   win.width = imax;
   win.height = jmax;
   currentWidth = win.width;
   currentHeight= win.height;

   /* Set window size */
   if (ioctl(cam_fd, VIDIOCSWIN, &win) < 0) {
      strcpy(errorMessage, "Can't VIDIOCSWIN");
      return FALSE;
   }

   free(yuvBuffer);
   yuvBuffer = NULL;
   yuvBufferSize = 0;

   if ((yuvBufferSize = (imax * jmax * 12) / 8) < 0) {
      strcpy(errorMessage, "(imax*jmax*12)/8 is < 0");
      close(cam_fd);
      cam_fd = -1;
      yuvBufferSize = 0;
      return FALSE;
   }
   if ((yuvBuffer = (unsigned char *) malloc(yuvBufferSize))
       == NULL) {
      strcpy(errorMessage, "Not enough memory");
      close(cam_fd);
      cam_fd = -1;
      yuvBufferSize = 0;
      return FALSE;
   }

   return TRUE;

}

/**
 * webcam_getVideoParameter - returns asked parameters.
 * command is defined by <i>command</i>,
 * result is copied to <i>result</i> string,
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in errorMessage.
*/
BOOL CCaptureLinux::getVideoParameter(char *result, int command, char* errorMessage)
{
   int ret = TRUE;

   struct video_picture pic;
   struct pwc_whitebalance whiteBalance;
   int param;

   switch (command) {

   case GETVALIDFRAME:
      sprintf(result, "%d",validFrame);
      break;

   case RESTOREUSER:
      if (ioctl(cam_fd, VIDIOCPWCRUSER, NULL)) {
         strcpy(errorMessage, "Can't VIDIOCPWCRUSER");
         ret = FALSE;
      }
      break;

   case GETPICSETTINGS:
      if (ioctl(cam_fd, VIDIOCGPICT, &pic)) {
         strcpy(errorMessage, "Can't VIDIOCGPICT");
         ret = FALSE;
      } else {
         sprintf(result, "%d %d %d %d", pic.brightness, pic.contrast,
                 pic.colour, pic.whiteness);
      }
      break;

   case RESTOREFACTORY:
      if (ioctl(cam_fd, VIDIOCPWCFACTORY, NULL)) {
         strcpy(errorMessage, "Can't VIDIOCPWCFACTORY");
         ret = FALSE;
      }
      break;

   case GETGAIN:
      if (ioctl(cam_fd, VIDIOCPWCGAGC, &param)) {
         strcpy(errorMessage, "Can't VIDIOCPWCGAGC");
         ret = FALSE;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETSHARPNESS:
      if (ioctl(cam_fd, VIDIOCPWCGCONTOUR, &param)) {
         strcpy(errorMessage, "Can't VIDIOCPWCGCONTOUR");
         ret = FALSE;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETSHUTTER:
      sprintf(result, "%d", shutterSpeed);
      break;

   case GETNOISE:
      if (ioctl(cam_fd, VIDIOCPWCGDYNNOISE, &param)) {
         strcpy(errorMessage, "Can't VIDIOCPWCGDYNNOISE");
         ret = FALSE;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETCOMPRESSION:
      if (ioctl(cam_fd, VIDIOCPWCGCQUAL, &param)) {
         strcpy(errorMessage, "Can't VIDIOCPWCGCQUAL");
         ret = FALSE;
      } else {
         sprintf(result, "%d", param);
      }
      break;

   case GETWHITEBALANCE:
      if (ioctl(cam_fd, VIDIOCPWCGAWB, &whiteBalance)) {
         strcpy(errorMessage, "Can't VIDIOCPWCGAWB");
         ret = FALSE;
      } else {
         switch (whiteBalance.mode) {
         case PWC_WB_AUTO:
            sprintf(result, "auto %d %d", whiteBalance.read_red,
                    whiteBalance.read_blue);
            break;
         case PWC_WB_MANUAL:
            sprintf(result, "manual %d %d", whiteBalance.manual_red,
                    whiteBalance.manual_blue);
            break;
         case PWC_WB_INDOOR:
            sprintf(result, "indoor");
            break;
         case PWC_WB_OUTDOOR:
            sprintf(result, "outdoor");
            break;
         case PWC_WB_FL:
            sprintf(result, "fl");
            break;
         default:
            break;
         }
      }
      break;

   case GETBACKLIGHT:
      if (ioctl(cam_fd, VIDIOCPWCGBACKLIGHT, &param)) {
         strcpy(errorMessage, "Can't VIDIOCPWCGBACKLIGHT");
         ret = FALSE;
      } else {
         if (param) {
            sprintf(result, "1");
         } else {
            sprintf(result, "0");
         }
      }
      break;

   case GETFLICKER:
      if (ioctl(cam_fd, VIDIOCPWCGFLICKER, &param)) {
         strcpy(errorMessage, "Can't VIDIOCPWCGFLICKER");
         ret = FALSE;
      } else {
         if (param) {
            sprintf(result, "1");
         } else {
            sprintf(result, "0");
         }
      }
      break;

   default:
      strcpy(errorMessage, "command not found");
      ret = FALSE;
      break;
   }

   return ret;
}

/**
 * webcam_setVideoParameter - sets some video source parameters.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in errorMessage.
 *
 * Function implemented for Linux.
*/
BOOL CCaptureLinux::setVideoParameter(int paramValue, int command, char * errorMessage)
{
   int ret = TRUE;

//printf"setVideoParameter value=%d command=%d \n",paramValue, command);
   switch (command) {

   case SETVALIDFRAME:
      validFrame = paramValue;
      break;

   case SETGAIN:
      if (ioctl(cam_fd, VIDIOCPWCSAGC, &paramValue)) {
         strcpy(errorMessage, "Can't VIDIOCPWCSAGC");
         ret = FALSE;

      }
      break;

   case SETSHARPNESS:
      if (ioctl(cam_fd, VIDIOCPWCSCONTOUR, &paramValue)) {
         strcpy(errorMessage, "Can't VIDIOCPWCSCONTOUR");
         ret = FALSE;
      }
      break;

   case SETSHUTTER:
      if (ioctl(cam_fd, VIDIOCPWCSSHUTTER, &paramValue)) {
         strcpy(errorMessage, "Can't VIDIOCPWCSSHUTTER");
         ret = FALSE;
      }
      shutterSpeed = paramValue;
      break;

   case SETNOISE:
      if (ioctl(cam_fd, VIDIOCPWCSDYNNOISE, &paramValue)) {
         strcpy(errorMessage, "Can't VIDIOCPWCSDYNNOISE");
         ret = FALSE;
      }
      break;

   case SETCOMPRESSION:
      if (ioctl(cam_fd, VIDIOCPWCSCQUAL, &paramValue)) {
         strcpy(errorMessage, "Can't VIDIOCPWCSCQUAL");
         ret = FALSE;
      }
      break;

   case SETBACKLIGHT:
      if (ioctl(cam_fd, VIDIOCPWCSBACKLIGHT, &paramValue)) {
         strcpy(errorMessage, "Can't VIDIOCPWCSBACKLIGHT");
         ret = FALSE;

      }
      break;

   case SETFLICKER:
      if (ioctl(cam_fd, VIDIOCPWCSFLICKER, &paramValue)) {
         strcpy(errorMessage, "Can't VIDIOCPWCSFLICKER");
         ret = FALSE;
      }
      break;

   default:
      strcpy(errorMessage, "command not found");
      ret = FALSE;
      break;
   }

   if (ret == FALSE) {
      printf("setVideoParameter errorMessage=%s\n",errorMessage);
   }
   return ret;
}

/**
 * setWhiteBalance sets White Balance.
 * Arguments:
 * - mode - mode name
 * - red, blue - red and blue levels - valid only when mode is "manual"
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in msg.
 *
 * Function implemented for Linux.
*/
BOOL CCaptureLinux::setWhiteBalance(char *mode, int red, int blue, char * errorMessage)
{
   struct pwc_whitebalance whiteBalance;

   whiteBalance.manual_red = red;
   whiteBalance.manual_blue = blue;

   if (strcmp(mode, "manual") == 0) {
      whiteBalance.mode = PWC_WB_MANUAL;
   } else if (strcmp(mode, "auto") == 0) {
      whiteBalance.mode = PWC_WB_AUTO;
   } else if (strcmp(mode, "indoor") == 0) {
      whiteBalance.mode = PWC_WB_INDOOR;
   } else if (strcmp(mode, "outdoor") == 0) {
      whiteBalance.mode = PWC_WB_OUTDOOR;
   } else if (strcmp(mode, "fl") == 0) {
      whiteBalance.mode = PWC_WB_FL;
   } else {
      sprintf(errorMessage, "%s - unknown whiteBalance mode\n%s", mode,
              "you can use modes: manual, auto, indoor, outdoor, fl");
      return 1;
   }

   if (ioctl(cam_fd, VIDIOCPWCSAWB, &whiteBalance)) {
      strcpy(errorMessage, "Can't VIDIOCPWCSAWB");
      return 1;
   }

   return 0;
}



/**
*----------------------------------------------------------------------
*
* Windows Video capture core fonctions
*
*----------------------------------------------------------------------
*/

BOOL CCaptureLinux::isPreviewEnabled()  {
   return FALSE;
}

void CCaptureLinux::setPreview(BOOL value,int owner) {
}

BOOL CCaptureLinux::getOverlay()  {
   return FALSE;
}
void CCaptureLinux::setOverlay(BOOL value) {
}

BOOL CCaptureLinux::setPreviewRate(int rate, char *errorMessage) {
   struct video_window win;

   ioctl(cam_fd, VIDIOCGWIN, &win);
   win.flags = (win.flags & ~PWC_FPS_MASK) | ((rate << PWC_FPS_SHIFT) & PWC_FPS_FRMASK);
   if (ioctl(cam_fd, VIDIOCSWIN, &win)) {
      sprintf(errorMessage,"webcam_setFrameRate value=%d ioctl error=%d %s", rate, errno, strerror(errno));
      return FALSE;
   } else {
      return TRUE;
   }
}

BOOL CCaptureLinux::getPreviewRate(int *rate, char *errorMessage) {
   struct video_window win;

   if (ioctl(cam_fd, VIDIOCGWIN, &win) == 0 ) {
      *rate = (win.flags & PWC_FPS_FRMASK) >> PWC_FPS_SHIFT;
      return TRUE;
   } else {
      sprintf(errorMessage,"webcam_getFrameRate ioctl error=%d %s", errno, strerror(errno));
      return FALSE;
   }
}



void CCaptureLinux::setPreviewScale(BOOL scale){

}

BOOL            CCaptureLinux::getCaptureAudio() {
   return FALSE;
}

void CCaptureLinux::setCaptureAudio(BOOL value){
}

BOOL    CCaptureLinux::grabFrame(char *errorMessage){
   int readResult;
   int i;

//printf"grabFrame port=%s debut\n", this->portName);
   if (longExposure == 0)  {
      if (mmap_buffer) {
         // j'active l'acces direct a la memoire video
//printf"grabFrame port=%s mmapCapture\n", this->portName);
         webcam_mmapCapture();
//printf"grabFrame port=%s mmapSync\n", this->portName);
         webcam_mmapSync();
//printf"grabFrame port=%s memcpy\n", this->portName);
         memcpy(yuvBuffer,webcam_mmapLastFrame(), yuvBufferSize);
      } else {
         if (cam_fd < 0) {
               strcpy(errorMessage, "cam_fd is < 0");
//printf"grabFrame port=%s error=%s\n", this->portName,errorMessage);
               return FALSE;
            }
         readResult = read(cam_fd, yuvBuffer, yuvBufferSize);
         if (yuvBufferSize != readResult) {
            sprintf(errorMessage, "error while reading frame: read()=%d yuvBufferSize=%d",readResult,yuvBufferSize );
//printf"grabFrame port=%s error=%s\n", this->portName,errorMessage);
            return FALSE;
         }
      }

   } else {
      //  acquisition long pose
      if (mmap_buffer) {
         for (i = 0; i < validFrame; i++) {
            webcam_mmapCapture();
            webcam_mmapSync();
         }
         memcpy(yuvBuffer,webcam_mmapLastFrame(), yuvBufferSize);
      } else {

         if (validFrame > 0) {
            for (i = 0; i < validFrame; i++) {
               readResult = read(cam_fd, yuvBuffer, yuvBufferSize);
               if (yuvBufferSize != readResult) {
                  sprintf(errorMessage, "error while reading frame: read()=%d yuvBufferSize=%d",readResult,yuvBufferSize );
//printf"grabFrame port=%s error=%s\n", this->portName,errorMessage);
                  return FALSE;
               }
            }
         } else if (validFrame == 0) {
            //auto detection, (less then 20 read() calls).
            for (i = 0; i < 20; i++) {
               readResult = read(cam_fd, yuvBuffer, yuvBufferSize);
               if (yuvBufferSize != readResult) {
                  sprintf(errorMessage, "error while reading frame: read()=%d yuvBufferSize=%d",readResult,yuvBufferSize );
//printf"grabFrame port=%s error=%s\n", this->portName,errorMessage);
                  return FALSE;
               }
               yuv420p_to_rgb24(yuvBuffer, rgbBuffer,
                  currentWidth, currentHeight);
               //for (n = 0; n < rgbBufferSize; n++) {
               //   if (rgbBuffer[n] > REQUIRED_MAX_VALUE)
               //      break;
               //}
               //if (rgbBuffer[n] > REQUIRED_MAX_VALUE)
               //   break;
            }
            if (i >= 20) {
               strcpy(errorMessage, "impossible to find valid frame");
//printf"grabFrame port=%s error=%s\n", this->portName,errorMessage);
               return FALSE;
            }
         } else {
            strcpy(errorMessage, "validFrame has invalid value");
//printf"grabFrame port=%s error=%s\n", this->portName,errorMessage);
            return FALSE;
         }
      }
   }

//printf"grabFrame port=%s fin\n", this->portName);

   return TRUE;
}

/**
*----------------------------------------------------------------------
*
* capabilities
*
*----------------------------------------------------------------------
*/

BOOL CCaptureLinux::hasOverlay() {
   return FALSE;
}

BOOL CCaptureLinux::hasDlgVideoFormat() {
   return FALSE;
}

BOOL CCaptureLinux::hasDlgVideoSource() {
   return FALSE;
}

BOOL CCaptureLinux::hasDlgVideoDisplay() {
   return FALSE;
}


/**
*----------------------------------------------------------------------
*
* configuration dialogs
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::openDlgVideoFormat() {
   return FALSE;
}

BOOL CCaptureLinux::openDlgVideoSource() {
   return FALSE;
}

BOOL CCaptureLinux::openDlgVideoDisplay() {
   return FALSE;
}

BOOL CCaptureLinux::openDlgVideoCompression() {
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
BOOL CCaptureLinux::startCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName) {
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
BOOL CCaptureLinux::abortCapture() {
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
BOOL CCaptureLinux::isCapturingNow()
{
   return FALSE;
}


/**
 *----------------------------------------------------------------------
 * readFrame
 *
 *
 * Parameters:
 *    rgbBuffer : must be pre-allocated
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *
 *
 *----------------------------------------------------------------------
 */
unsigned char * CCaptureLinux::getGrabbedFrame(char *errorMessage)
{
//printf("getGrabbedFrame port=%s debut\n", this->portName);

   if (rgbBuffer != NULL) {
      free(rgbBuffer);
   }

   rgbBuffer = (unsigned char *) calloc(currentWidth * currentHeight * 3,1);

   // Convert yuv to rgb
   yuv420p_to_rgb24(yuvBuffer, rgbBuffer, currentWidth, currentHeight);

//printf("getGrabbedFrame port=%s fin\n", this->portName);
   return rgbBuffer;
}

/**
*----------------------------------------------------------------------
*
* window position
*
*----------------------------------------------------------------------
*/

/*
void CCaptureWinVfw::setScrollPos(POINT *pt) {
   if( hwndCap != NULL) {
      capSetScrollPos(hwndCap, pt);
   }
}
*/

void CCaptureLinux::getWindowPosition(int *x1, int *y1,int *x2,int *y2) {
   struct video_window win ;

   ioctl(cam_fd, VIDIOCGWIN, &win);
   *x1 = win.x;
   *y1 = win.y;
   *x2 = win.width - win.x;
   *y2 = win.height - win.y;
}

void CCaptureLinux::setWindowPosition(int x1, int y1,int x2,int y2) {
   struct video_window win ;

   ioctl(cam_fd, VIDIOCGWIN, &win);
   win.width = x2 - x1 +1;
   win.height = y2- y1 +1;
   ioctl(cam_fd, VIDIOCSWIN, &win);
}

void CCaptureLinux::setWindowSize(int width, int height) {
   struct video_window win ;

   ioctl(cam_fd, VIDIOCGWIN, &win);
   win.width = width;
   win.height = height;
   ioctl(cam_fd, VIDIOCSWIN, &win);
}

/******************************************************************/
/*  Fonctions d'acces direct a la memoire video LINUX (M. Pujol)  */
/*                                                                */
/*                                        */
/******************************************************************/


int CCaptureLinux::webcam_smmapInit() {
   mmap_mbuf.size = 0;
   mmap_mbuf.frames = 0;
   mmap_last_sync_buff=-1;
   mmap_last_capture_buff=-1;
   mmap_buffer=NULL;

   if (ioctl(cam_fd, VIDIOCGMBUF, &mmap_mbuf)) {
      // mmap not supported
      return -1;
   }
   mmap_buffer=(unsigned char *)mmap(NULL, mmap_mbuf.size, PROT_READ, MAP_SHARED, cam_fd, 0);
   if (mmap_buffer == MAP_FAILED) {
      mmap_mbuf.size = 0;
      mmap_mbuf.frames = 0;
      mmap_buffer=NULL;
      return -1;
   }
   return 0;
}

void CCaptureLinux::webcam_mmapSync() {
//printf("mmapSync %s cam_fd=%d mmap_last_sync_buff=%ld mmap_mbuf.frames=%d\n",this->portName, cam_fd,mmap_last_sync_buff,mmap_mbuf.frames);
   mmap_last_sync_buff=(mmap_last_sync_buff+1)%mmap_mbuf.frames;
   if (ioctl(cam_fd, VIDIOCSYNC, &mmap_last_sync_buff) < 0) {
      printf("webcam_mmapSync() error\n");
   }
}

unsigned char * CCaptureLinux::webcam_mmapLastFrame() {
   return mmap_buffer + mmap_mbuf.offsets[mmap_last_sync_buff];
}

void CCaptureLinux::webcam_mmapCapture() {
   struct video_mmap vm;
   mmap_last_capture_buff=(mmap_last_capture_buff+1)%mmap_mbuf.frames;
   vm.frame = mmap_last_capture_buff;
   //vm.format = picture_.palette;
   vm.format = VIDEO_PALETTE_YUV420P;
   vm.width = currentWidth ;
   vm.height = currentHeight ;
//printf("mmapCapture %s cam_fd=%d mmap_last_sync_buff=%ld mmap_mbuf.frames=%d,w=%d,h=%d\n",this->portName, cam_fd,mmap_last_capture_buff,mmap_mbuf.frames,vm.width,vm.height);
    if (ioctl(cam_fd, VIDIOCMCAPTURE, &vm) < 0) {
      printf("webcam_mmapCapture error\n");
   }
}

void CCaptureLinux::webcam_mmapDelete() {
   int result;
   result = munmap(mmap_buffer, mmap_mbuf.size);
   if ( result != 0 ) {
      printf(" webcam_mmapDelete result=%d\n",result);
   }
   mmap_buffer = NULL;
}


/******************************************************************/
/*  Fonctions conversion YUV, RGB  */
/*                                                                */
/*                                        */
/******************************************************************/


/**
 * Init Lookup tables for yuv to rgb conversion.
 * Code comes from xawtv.
*/
void CCaptureLinux::ng_color_yuv2rgb_init(void)
{
   int i;

   /* init Lookup tables */
   for (i = 0; i < 256; i++) {
      ng_yuv_gray[i] = i * LUN_MUL >> 8;
      ng_yuv_red[i] = (RED_ADD + i * RED_MUL) >> 8;
      ng_yuv_blue[i] = (BLUE_ADD + i * BLUE_MUL) >> 8;
      ng_yuv_g1[i] = (GREEN1_ADD + i * GREEN1_MUL) >> 8;
      ng_yuv_g2[i] = (GREEN2_ADD + i * GREEN2_MUL) >> 8;
   }
   for (i = 0; i < CLIP; i++)
      ng_clip[i] = 0;
   for (; i < CLIP + 256; i++)
      ng_clip[i] = i - CLIP;
   for (; i < 2 * CLIP + 256; i++)
      ng_clip[i] = 255;
}


/**
 * Convert from yuv to rgb.
 *
 * Code comes from xawtv, actually it converts to bgr
 * and flips vertically.
*/
void CCaptureLinux::yuv420p_to_rgb24(unsigned char *yuv, unsigned char *rgb,
                      int width, int height)
{

   unsigned char *y, *u, *v, *d;
   unsigned char *us, *vs;
   unsigned char *dp;
   int i, j;
   int gray;

   dp = rgb + (height - 1) * width * 3;
   y = yuv;
   u = y + width * height;
   v = u + width * height / 4;

   for (i = 0; i < height; i++) {
      d = dp;
      us = u;
      vs = v;
      for (j = 0; j < width; j += 2) {
         gray = GRAY(*y);
         *(d++) = BLUE(gray, *u);
         *(d++) = GREEN(gray, *v, *u);
         *(d++) = RED(gray, *v);
         y++;
         gray = GRAY(*y);
         *(d++) = BLUE(gray, *u);
         *(d++) = GREEN(gray, *v, *u);
         *(d++) = RED(gray, *v);
         y++;
         u++;
         v++;
      }
      if (0 == (i % 2)) {
         u = us;
         v = vs;
      }
      dp -= width * 3;
   }
}
