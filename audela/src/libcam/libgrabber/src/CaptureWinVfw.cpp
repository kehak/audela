// Capture.cpp: implementation of the CCaptureWinVfw class.
//
//////////////////////////////////////////////////////////////////////

#include <windows.h>
#include <vfw.h>
#include <stdio.h>

#include "CaptureWinVfw.h"


// macros
#define WIDTHBYTES(bits)        (((bits) + 31) / 32 * 4)

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCaptureWinVfw::CCaptureWinVfw()
{

   lpwfex = NULL;
   hwndCap = NULL;
   grabBuffer = NULL;
   previousOwnerWindowProc = 0;
}

CCaptureWinVfw::~CCaptureWinVfw()
{

   if (lpwfex  != NULL ) {
      //GlobalFree(lpwfex) ;
   }


   //capSetCallbackOnYield(hwndCap, NULL) ;

   // Disconnect the current capture driver
   if( hwndCap != NULL ) {
      capPreview(hwndCap, FALSE);
      capDriverDisconnect (hwndCap);
   }

   DestroyWindow(hwndCap);

}

/**
*----------------------------------------------------------------------
*
* initHardware
*    initialise connection to the camera
*----------------------------------------------------------------------
*/
BOOL CCaptureWinVfw::initHardware(UINT uIndex, CCaptureListener *captureListener, char *errorMsg) {
   BOOL    result;

   HWND hwndParent = GetDesktopWindow();
   this->captureListener = captureListener;
   this->index = uIndex;

   // create a capture window within vidframe.
   hwndCap = capCreateCaptureWindow(
      NULL,
      WS_CHILD | WS_VISIBLE,
      0, 0, 160, 120,
      hwndParent,                 // parent window
      uIndex                      // child window id
      );
   if (hwndCap == NULL) {
      return FALSE;
   }

   // Hides the window. It will be automatically shown when preview will start
   ShowWindow(hwndCap, SW_HIDE);

   // Get the default setup for video capture from the AVICap window
   capCaptureGetSetup(hwndCap, &capParms, sizeof(CAPTUREPARMS)) ;

   // set the context object used by callback functions
   capSetUserData(hwndCap, (long) userDataTablePtr);
   setCallbackUserData(0, (long) this);

   // declare callback functions
   capSetCallbackOnError(hwndCap,  errorCallbackProc) ;
   capSetCallbackOnStatus(hwndCap, statusCallbackProc) ;
   result = TRUE;

   return result;
}

/**
*----------------------------------------------------------------------
*
* connect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinVfw::connect(BOOL longExposure, UINT iIndex, char *errorMsg) {
   BOOL result;

   this->longExposure = longExposure;

   // Try connecting to the capture driver
   if (capDriverConnect(hwndCap, iIndex) == TRUE) {
      // Get the capabilities of the capture driver
      capDriverGetCaps(hwndCap, &capDriverCaps, sizeof(CAPDRIVERCAPS)) ;
      // Get the settings for the capture window
      capGetStatus(hwndCap, &capStatus , sizeof(CAPSTATUS));
      result = TRUE;
   }
   else {
      result = FALSE;
   }

   return result;
}


/**
*----------------------------------------------------------------------
*
* disconnect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinVfw::disconnect(char *errorMsg) {
   BOOL   result = TRUE;

   if( hwndCap != NULL ) {
      capPreview(hwndCap, FALSE);
      capDriverDisconnect (hwndCap);
      // Get the capabilities of the capture driver
      capDriverGetCaps(hwndCap, &capDriverCaps, sizeof(CAPDRIVERCAPS)) ;
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
BOOL CCaptureWinVfw::isConnected() {
   BOOL   result;
   result = capDriverCaps.fCaptureInitialized;
   return result;
}


/**
*----------------------------------------------------------------------
*
* accessors
*
*----------------------------------------------------------------------
*/

unsigned int CCaptureWinVfw::getImageWidth(){

   BITMAPINFO bi;
   int   formatSize;

   formatSize = capGetVideoFormatSize(hwndCap);

   getVideoFormat(&bi, formatSize);
   return bi.bmiHeader.biWidth;
   //return capStatus.uiImageWidth  ;

}

unsigned int     CCaptureWinVfw::getImageHeight() {
   BITMAPINFO bi;
   int   formatSize;

   formatSize = capGetVideoFormatSize(hwndCap);
   getVideoFormat(&bi, formatSize);
   return bi.bmiHeader.biHeight;
   //return capStatus.uiImageHeight ;

}
unsigned long    CCaptureWinVfw::getVideoFormatSize(){
   return capGetVideoFormatSize(hwndCap) ;
}

unsigned long    CCaptureWinVfw::getVideoFormat(BITMAPINFO * pbi, int size ) {
   return capGetVideoFormat(hwndCap, pbi, size);
}


void CCaptureWinVfw::getCurrentStatus(unsigned long * pcurrentVideoFrame, unsigned long * pcurrentTimeElapsedMS ){
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS));
   *pcurrentVideoFrame    =  capStatus.dwCurrentVideoFrame ;
   *pcurrentTimeElapsedMS =  capStatus.dwCurrentTimeElapsedMS;
}


/**
*----------------------------------------------------------------------
*
* Windows Video capture core fonctions
*
*----------------------------------------------------------------------
*/

BOOL    CCaptureWinVfw::hasAudioHardware( ){ return capStatus.fAudioHardware  ; }

BOOL CCaptureWinVfw::isPreviewEnabled()  {
   return capStatus.fLiveWindow;
}

LRESULT APIENTRY CCaptureWinVfwOwnerWindowProc(
    HWND hwnd,
    UINT uMsg,
    WPARAM wParam,
    LPARAM lParam)
{
   CCaptureWinVfw* capture = (CCaptureWinVfw*) GetWindowLong(hwnd, GWL_ID);
   //CCaptureWinVfw* capture = CCaptureWinVfw::userData;
   if ( capture == NULL) {
      return FALSE;
   }
   if (uMsg == WM_USER+1) {
      double zoom;
      if ( HIWORD(lParam) == 1 ) {
         zoom = (double) LOWORD(lParam);
      } else {
         zoom = (double) 1.0 / LOWORD(lParam);
      }
      int width  = capture->getImageWidth();
      int height = capture->getImageHeight();

      capture->setWindowSize((int) (width * zoom),(int)(height *zoom));
      return TRUE;
   } else {
      //return DefWindowProc(hwnd, uMsg, wParam, lParam);
      if ( capture->previousOwnerWindowProc != 0 && capture->previousOwnerWindowProc != (LONG)CCaptureWinVfwOwnerWindowProc) {
         return CallWindowProc((WNDPROC)capture->previousOwnerWindowProc, hwnd, uMsg, wParam, lParam);
      } else {
         //return DefWindowProc(hwnd, uMsg, wParam, lParam);
         return TRUE;
      }
   }
}

void CCaptureWinVfw::setPreview(BOOL value, int owner) {

   capPreview(hwndCap, value) ;
   if( value == TRUE && previousOwnerWindowProc == 0) {
      ownerHwnd = owner;
      previousOwnerUserdata   = SetWindowLong((HWND)owner,GWL_ID,(LONG) this);
      previousOwnerWindowProc = SetWindowLong((HWND)owner, GWL_WNDPROC, (LONG) CCaptureWinVfwOwnerWindowProc);
      SetParent(hwndCap, (HWND) owner);
      ShowWindow(hwndCap, SW_SHOW);
   }

   if( value == FALSE && previousOwnerWindowProc != 0 ) {
      SetParent(hwndCap, (HWND) NULL);
      SetWindowLong((HWND)ownerHwnd, GWL_WNDPROC, previousOwnerWindowProc);
      //SetWindowLong((HWND)ownerHwnd, GWL_USERDATA, previousOwnerUserdata );
      SetWindowLong((HWND)ownerHwnd, GWL_ID, previousOwnerUserdata );
      previousOwnerUserdata   = 0;
      previousOwnerWindowProc = 0;
      ShowWindow(hwndCap, SW_HIDE);
   }

   // update local capStatus
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS));
}

BOOL CCaptureWinVfw::getOverlay()  {
   return capStatus.fOverlayWindow;
}
void CCaptureWinVfw::setOverlay(BOOL value) {
   capOverlay(hwndCap, value) ;
   // update local capStatus
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
}

LPWAVEFORMATEX  CCaptureWinVfw::getAudioFormat() {
   DWORD        dwSize ;
   if ( lpwfex == NULL ) {
      dwSize = capGetAudioFormatSize (hwndCap);
      lpwfex = (LPWAVEFORMATEX) GlobalAlloc(GHND, dwSize) ;
   }
   capGetAudioFormat(hwndCap, lpwfex, (WORD)dwSize) ;
   return lpwfex;
}

void  CCaptureWinVfw::setAudioFormat(LPWAVEFORMATEX value) {
   DWORD       dwSize ;

   dwSize = capGetAudioFormatSize (hwndCap);
   capSetAudioFormat(hwndCap, value, (WORD)dwSize) ;
}

DWORD  CCaptureWinVfw::getAudioFormatSize(){
   return capGetAudioFormatSize (hwndCap);
}

BOOL CCaptureWinVfw::setPreviewRate(int rate, char* errorMessage){
   capPreviewRate(hwndCap, rate);
   return TRUE;
}

BOOL CCaptureWinVfw::getPreviewRate(int *rate, char* errorMessage){
   return FALSE;
}

void CCaptureWinVfw::setPreviewScale(BOOL scale){
   capPreviewScale(hwndCap, scale);
}

void CCaptureWinVfw::getCaptureFileName(char * fileName, int maxSize) {
   capFileGetCaptureFile(hwndCap, fileName, maxSize) ;
}
void CCaptureWinVfw::setCaptureFileName(char * fileName) {
   capFileSetCaptureFile(hwndCap, fileName);
}

BOOL CCaptureWinVfw::allocCaptureFileSpace( long fileSize) {
   return capFileAlloc(hwndCap , (long) fileSize * ONEMEG);
}

unsigned long   CCaptureWinVfw::getCaptureRate(){ return capParms.dwRequestMicroSecPerFrame  ; }
void            CCaptureWinVfw::setCaptureRate(unsigned long value){ capParms.dwRequestMicroSecPerFrame  = value; }

unsigned int    CCaptureWinVfw::getTimeLimit(){ return capParms.wTimeLimit  ; }
void            CCaptureWinVfw::setTimeLimit(unsigned int value){ capParms.wTimeLimit  = value; }

BOOL            CCaptureWinVfw::getLimitEnabled() { return capParms.fLimitEnabled; }
void            CCaptureWinVfw::setLimitEnabled(BOOL value){ capParms.fLimitEnabled = value; }

BOOL            CCaptureWinVfw::getCaptureAudio(){ return capParms.fCaptureAudio; }

void CCaptureWinVfw::setCaptureAudio(BOOL value){
   capParms.fCaptureAudio = value;
   capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms));
}

BOOL            CCaptureWinVfw::getCaptureToDisk(){ return capParms.fUsingDOSMemory  ; }
void            CCaptureWinVfw::setCaptureToDisk(BOOL value){ capParms.fUsingDOSMemory  = value; }

BOOL    CCaptureWinVfw::singleFrameCaptureOpen(){
   return capCaptureSingleFrameOpen(hwndCap);
}

BOOL    CCaptureWinVfw::singleFrameCaptureClose(){
   return capCaptureSingleFrameClose(hwndCap);
}

BOOL    CCaptureWinVfw::singleFrameCapture(){
   return capCaptureSingleFrame(hwndCap);
}

BOOL    CCaptureWinVfw::getDriverName( char * driverName) {
   return capDriverGetName(hwndCap, sizeof(driverName)-1, driverName);
}

BOOL CCaptureWinVfw::saveDIBFile(char * fileName) {
   return capFileSaveDIB(hwndCap, fileName);
}


/**
*----------------------------------------------------------------------
*
* MCI control
*
*----------------------------------------------------------------------
*/
void CCaptureWinVfw::getMCIDeviceName(char * deviceName, int maxSize) {
   capGetMCIDeviceName(hwndCap, deviceName, maxSize) ;
}
void CCaptureWinVfw::setMCIDeviceName(char * deviceName) {
   capSetMCIDeviceName(hwndCap, deviceName);
}

BOOL            CCaptureWinVfw::getMCIControl(){ return capParms.fMCIControl  ; }
void            CCaptureWinVfw::setMCIControl(BOOL value){ capParms.fMCIControl  = value; }

BOOL            CCaptureWinVfw::getStepMCIDevice(){ return capParms.fStepMCIDevice  ; }
void            CCaptureWinVfw::setStepMCIDevice(BOOL value){ capParms.fStepMCIDevice  = value; }

unsigned long   CCaptureWinVfw::getMCIStartTime(){ return capParms.dwMCIStartTime  ; }
void            CCaptureWinVfw::setMCIStartTime(unsigned long value){ capParms.dwMCIStartTime  = value; }

unsigned long   CCaptureWinVfw::getMCIStopTime(){ return capParms.dwMCIStopTime  ; }
void            CCaptureWinVfw::setMCIStopTime(unsigned long value){ capParms.dwMCIStopTime  = value; }


unsigned int    CCaptureWinVfw::getStepCaptureAverageFrames(){ return capParms.wStepCaptureAverageFrames  ; }
void            CCaptureWinVfw::setStepCaptureAverageFrames(unsigned int value){ capParms.wStepCaptureAverageFrames  = value; }

BOOL            CCaptureWinVfw::getStepCaptureAt2x(){ return capParms.fStepCaptureAt2x  ; }
void            CCaptureWinVfw::setStepCaptureAt2x(BOOL value) { capParms.fStepCaptureAt2x  = value; }

unsigned long   CCaptureWinVfw::getIndexSize(){ return capParms.dwIndexSize  ; }
void            CCaptureWinVfw::setIndexSize(unsigned long value){ capParms.dwIndexSize  = value; }

unsigned int    CCaptureWinVfw::getAVStreamMaster(){ return capParms.AVStreamMaster  ; }
void            CCaptureWinVfw::setAVStreamMaster(unsigned int value){ capParms.AVStreamMaster  = value; }



/**
*----------------------------------------------------------------------
*
* palette
*
*----------------------------------------------------------------------
*/
HPALETTE        CCaptureWinVfw::getPalette() { return capStatus.hPalCurrent; }
BOOL            CCaptureWinVfw::isUsingDefaultPalette() { return capStatus.fUsingDefaultPalette;}
BOOL CCaptureWinVfw::openPalette(char * paletteFileName) {
   return capPaletteOpen(hwndCap, paletteFileName);
}

BOOL CCaptureWinVfw::savePalette(char * paletteFileName) {
   return capPaletteSave(hwndCap, paletteFileName);
}

long CCaptureWinVfw::setNewPalette() {
   if (hwndCap != NULL) {
      return SendMessage(hwndCap, WM_QUERYNEWPALETTE, NULL, NULL);
   } else {
      return NULL;
   }
}

void CCaptureWinVfw::setPaletteManual(BOOL fGrab , int iColors) {
   capPaletteManual(hwndCap, fGrab, iColors);
}


/**
*----------------------------------------------------------------------
*
* clipboard
*
*----------------------------------------------------------------------
*/
void CCaptureWinVfw::editCopy() {
   capEditCopy(hwndCap);
}

void CCaptureWinVfw::palettePaste() {
   capPalettePaste(hwndCap);
}


/**
*----------------------------------------------------------------------
*
* capabilities
*
*----------------------------------------------------------------------
*/

BOOL CCaptureWinVfw::hasOverlay() {
   return capDriverCaps.fHasOverlay;
}

BOOL CCaptureWinVfw::hasDlgVideoFormat() {
   return capDriverCaps.fHasDlgVideoFormat;
}

BOOL CCaptureWinVfw::hasDlgVideoSource() {
   return capDriverCaps.fHasDlgVideoSource;
}

BOOL CCaptureWinVfw::suppliesPalette() {
   return capDriverCaps.fDriverSuppliesPalettes;
}

/**
*----------------------------------------------------------------------
*
* window position
*
*----------------------------------------------------------------------
*/

void CCaptureWinVfw::setScrollPos(POINT *pt) {
   if( hwndCap != NULL) {
      capSetScrollPos(hwndCap, pt);
   }
}

void CCaptureWinVfw::getWindowPosition(int *x1, int *y1,int *x2,int *y2) {
   RECT rect;
   GetWindowRect(hwndCap, &rect);
   *x1 = rect.top;
   *y1 = rect.left;
   *x2 = rect.bottom;
   *y2 = rect.right;
}

void CCaptureWinVfw::setWindowPosition(int x1, int y1,int x2,int y2) {
   MoveWindow(
      hwndCap,
      x1,
      y1,
      x2 - x1,
      y2 - y1,
      TRUE
      );
}

void CCaptureWinVfw::setWindowSize(int width, int height) {
   SetWindowPos(
     hwndCap,                // handle to window
     NULL,                    // placement-order handle
     0,                       // horizontal position
     0,                       // vertical position
     width,                   // width
     height,                  // height
     SWP_NOOWNERZORDER |SWP_NOZORDER |SWP_NOMOVE           // window-positioning flags
   );
}


/**
*----------------------------------------------------------------------
*
* configuration dialogs
*
*----------------------------------------------------------------------
*/
BOOL CCaptureWinVfw::openDlgVideoFormat() {
   BOOL result ;

   result = capDlgVideoFormat(hwndCap);
   if (result) {
      // If successful,
      // Get the new image dimension and center capture window
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;
}

BOOL CCaptureWinVfw::openDlgVideoSource() {
   BOOL result ;

   int oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
   result = capDlgVideoSource(hwndCap);
   Tcl_SetServiceMode(oldMode);
   if (result) {
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;
}

BOOL CCaptureWinVfw::hasDlgVideoDisplay() {
   return capDriverCaps.fHasDlgVideoDisplay;
}

BOOL CCaptureWinVfw::openDlgVideoDisplay() {
   BOOL result ;

   result = capDlgVideoDisplay(hwndCap);
   if (result) {
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;
}

BOOL CCaptureWinVfw::openDlgVideoCompression() {
   BOOL result ;

   result = capDlgVideoCompression(hwndCap);
   if (result) {
      capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) ;
   }
   return result;
}


BOOL CCaptureWinVfw::getVideoParameter(char *result, int command, char* errorMessage) {
   return TRUE;
}

BOOL CCaptureWinVfw::setVideoParameter(int paramValue, int command, char * errorMessage) {
   return TRUE;
}

BOOL CCaptureWinVfw::setWhiteBalance(char *mode, int red, int blue, char * errorMessage){
   return TRUE;
}

BOOL CCaptureWinVfw::setVideoFormat(char *formatname, char *errorMessage){
   return TRUE;
}


/**
 * allocFileSpace
 *
 *
 */
BOOL CCaptureWinVfw::allocFileSpace() {
   BOOL                result ;
   long                fileSize;
   int                 formatSize;
   BITMAPINFOHEADER    bih;

   // allocate file space
   // get video format of capture device
   if ((formatSize = capGetVideoFormatSize(hwndCap))<=0) {
      return FALSE;
   }
   if (formatSize > sizeof(bih)) {
      return FALSE;  // Format too large
   }
   if (!capGetVideoFormat(hwndCap, &bih, formatSize)){
      return -1;
   }

   fileSize = capParms.wTimeLimit * (long) ( (1e6 / capParms.dwRequestMicroSecPerFrame) + 0.5) * bih.biSizeImage  ;
   result = capFileAlloc(hwndCap , fileSize );

   return result;
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
BOOL CCaptureWinVfw::startCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName) {
   BOOL result ;


   // duree de la capture limitee dans le temps(en seconde)
   setLimitEnabled(TRUE);
   setTimeLimit(exptime);
   // frequence de la capture (millisecondes par frame)
   setCaptureRate( microSecPerFrame);
   // nombre maxi de frames dans le fichier AVI (32000 par defaut)
   setIndexSize (32767);
   // ne pas enregistrer le son
   setCaptureAudio(FALSE);
   // ne pas utiliser le controle de peripheriques  MCI
   setMCIControl(FALSE);
   // je declare le nom du fichier de capture AVI
   setCaptureFileName(fileName);

   // set the defaults we won't bother the user with
   // Don't ask capture confirmation
   capParms.fMakeUserHitOKToCapture = FALSE;
   capParms.wPercentDropForError = 10;
   // If "CapturingToMemory", get as many buffers as we can.
   //capParms.wNumVideoRequested = capParms.fUsingDOSMemory ? 32 : 1000;
   capParms.wNumVideoRequested = 64;
   // touche pour interrompre la capture
   capParms.vKeyAbort = VK_ESCAPE;
   // interdit l'arret la capture avec le boutton gauche de la souris
   capParms.fAbortLeftMouse = FALSE;
   // interdit l'arret la capture avec le boutton gauche de la souris
   capParms.fAbortRightMouse = FALSE;

   //--- inutilise par Windows
   //captureParams.fUsingDOSMemory;
   //captureParams.fDisableWriteCache;

   //--- parametres pour controle MCI inutilises
   //captureParams.fStepMCIDevice;
   //captureParams.dwMCIStartTime;
   //captureParams.dwMCIStopTime;
   //captureParams.fStepCaptureAt2x;
   //captureParams.wStepCaptureAverageFrames;
   capParms.AVStreamMaster = AVSTREAMMASTER_NONE;
   // Don't abort on the left mouse anymore!
   capParms.fAbortLeftMouse = FALSE;
   capParms.fAbortRightMouse = FALSE;
   // allows 10% dropped frames
   capParms.wPercentDropForError = 10;
   // If wChunkGranularity is zero, the granularity will be set to the
   // disk sector size.(default=0)
   capParms.wChunkGranularity = 0 ;
   // fUsingDefaultPalette will be TRUE even if the
   // current capture format is non-palettised. This is a
   // bizarre decision of Jay's.
   capStatus.fUsingDefaultPalette = TRUE;
   // allocate file space
   allocFileSpace();
   // allow yield
   capParms.fYield = TRUE;   // callbacks won't work if Yield is TRUE
   capSetCallbackOnYield(hwndCap, TRUE);

   // register capture params
   capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms)) ;
   // start capture with saving file
   result = capCaptureSequence(hwndCap);

   return result;
}


/**
 *----------------------------------------------------------------------
 * startCaptureNoFile
 *    starts streaming video capture. Frame are processed by a specific callback
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
BOOL CCaptureWinVfw::startCaptureNoFile(FARPROC  callback, long userData) {
   BOOL                result ;

   // set the defaults we won't bother the user with
   capParms.fMakeUserHitOKToCapture = !capParms.fMCIControl;
   capParms.wPercentDropForError = 10;
   capParms.wNumVideoRequested = 64;

   // Don't abort on the left mouse anymore!
   capParms.fAbortLeftMouse = FALSE;
   capParms.fAbortRightMouse = TRUE;

   // If wChunkGranularity is zero, the granularity will be set to the
   // disk sector size.
   capParms.wChunkGranularity = 32 ;
   capParms.fYield = FALSE;   // callbacks won't work if Yield is TRUE
   capSetCallbackOnYield(hwndCap, NULL);

   // fUsingDefaultPalette will be TRUE even if the
   // current capture format is non-palettised. This is a
   // bizarre decision of Jay's.
   capStatus.fUsingDefaultPalette = TRUE;

   //result = capSetUserData(hwndCap, (long) userData);
   result = setCallbackUserData(1,userData);

   if( result == TRUE ) {
      // set the callback
      result = capSetCallbackOnVideoStream(hwndCap, callback);
      if( result == TRUE ) {
         // register capture params
         capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms)) ;
         // capture now
         result = capCaptureSequenceNoFile(hwndCap);
         capCaptureStop(hwndCap);
      }
   }

   // reset callback
   result = capSetCallbackOnVideoStream(hwndCap, NULL);

   // restore params
   capParms.fYield = TRUE;   // callbacks won't work if Yield is TRUE
   capCaptureSetSetup(hwndCap, &capParms, sizeof(capParms)) ;

   return result;
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
BOOL CCaptureWinVfw::abortCapture() {
   return capCaptureAbort(hwndCap);
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
BOOL CCaptureWinVfw::isCapturingNow()
{
   capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS));
   return capStatus.fCapturingNow;
}


/**
 *----------------------------------------------------------------------
 * grabFrame
 *
 *
 * Parameters:
 *    longExposure :
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    grabs a frame and executes grabFrameCallbackProc
 *
 *----------------------------------------------------------------------
 */
BOOL CCaptureWinVfw::grabFrame(char *errorMessage)
{
   BOOL result = FALSE;

   // enable grab callback
   result = capSetCallbackOnFrame(hwndCap, grabFrameCallbackProc);
   if (result == TRUE)  {
      result = capGrabFrameNoStop(hwndCap);
      //result = capGrabFrame(hwndCap)
      // disable grab callback
      capSetCallbackOnFrame(hwndCap, NULL);
   } else {
      sprintf(errorMessage,"grabFrameCallbackProc error");
   }
   return result;
}

/**
 *  grabFrameCallbackProc
 *  this callback is called when a frame is grabbed
 *
 *  hWnd:            Application main window handle
 *  vhdr:            video header
 * Side effects:
 *    converts I420 frame to DIB frame with ICDecompress standard function
 *    stores capture->grabBuffer
 */
LRESULT CALLBACK  CCaptureWinVfw::grabFrameCallbackProc(HWND hWnd, VIDEOHDR *vhdr) {
    int        result;
    BITMAPINFO inputbi;
    BITMAPINFO tempbi;
    int        inputFormatSize = NULL;
    HIC        hic;
//    HDC        hdc;
//    HBITMAP    htempBitmap;


    CCaptureWinVfw  * capture = (CCaptureWinVfw *) CCaptureWinVfw::getCallbackUserData(hWnd, 0);

    if ((inputFormatSize = capture->getVideoFormatSize())<=0) {
        return FALSE;
    }

    if (inputFormatSize > sizeof(inputbi)) // Format too large?
        return FALSE;


    if (!capture->getVideoFormat(&inputbi, inputFormatSize)){
        return FALSE;
    }

    // prepare temporary BITMAPINFO
    tempbi.bmiHeader.biSize =           sizeof(BITMAPINFOHEADER);
    tempbi.bmiHeader.biWidth =          inputbi.bmiHeader.biWidth;
    tempbi.bmiHeader.biHeight =         inputbi.bmiHeader.biHeight;
    tempbi.bmiHeader.biPlanes =         1;
    tempbi.bmiHeader.biBitCount =       24;
    tempbi.bmiHeader.biCompression =    BI_RGB;        // BI_RGB=0;
    tempbi.bmiHeader.biSizeImage =      WIDTHBYTES((DWORD)tempbi.bmiHeader.biWidth * tempbi.bmiHeader.biBitCount) * tempbi.bmiHeader.biHeight;
    tempbi.bmiHeader.biXPelsPerMeter =  0;
    tempbi.bmiHeader.biYPelsPerMeter =  0;
    tempbi.bmiHeader.biClrImportant =   0;
    tempbi.bmiHeader.biClrUsed =        0;    // no palette

    if (capture->grabBuffer != NULL) {
       free(capture->grabBuffer);
    }
    capture->grabBuffer = (unsigned char *) malloc(tempbi.bmiHeader.biSizeImage);
    if (capture->grabBuffer == NULL) {
       return FALSE;
    }

    // open decompression I420(YUY2) to DIB
    hic = ICDecompressOpen(ICTYPE_VIDEO, 0, &inputbi.bmiHeader, &tempbi.bmiHeader);
    if (!hic) {   // Image dimensions outside of maximum limit
        return FALSE ;
    }

    result = ICDecompressBegin(hic, &inputbi, &tempbi);
    if (result != ICERR_OK) {
        return FALSE;
    }

    // conversion I420 to DIB
    result = ICDecompress(hic, 0, &inputbi.bmiHeader, vhdr->lpData, &tempbi.bmiHeader, capture->grabBuffer);
    if (result != ICERR_OK) {
        MessageBeep(0);
        return FALSE;
    }

    if ( hic) {
        ICDecompressEnd(hic);
        ICClose(hic);
        hic = NULL;
    }

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
unsigned char * CCaptureWinVfw::getGrabbedFrame( char *errorMessage) {
   return grabBuffer;
}


/**
*----------------------------------------------------------------------
*
* setPreviewWindowCallbackProc
*
*  callbackProc:  new callback proc
*  userData:      userdata used by the callback
*----------------------------------------------------------------------
*/

WNDPROC CCaptureWinVfw::setPreviewWindowCallbackProc(WNDPROC callbackProc,long userData){
   SetWindowLong(hwndCap, GWL_USERDATA, userData);
   return (WNDPROC)SetWindowLong(hwndCap, GWL_WNDPROC,(DWORD) callbackProc);
}


/**
*----------------------------------------------------------------------
*
* setCallbackUserData
*
*  callbackProc:  new callback proc
*----------------------------------------------------------------------
*/
int CCaptureWinVfw::setCallbackUserData(int position, long newUserData){

   if( newUserData != NULL ) {
      userDataTablePtr[position] = newUserData;
   } else {
      userDataTablePtr[position] = newUserData;
   }

   return TRUE;
}

/**
*----------------------------------------------------------------------
*
* getCallbackUserData
*
*  callbackProc:  new callback proc
*----------------------------------------------------------------------
*/
long CCaptureWinVfw::getCallbackUserData(HWND hwnd, int position) {
   long * tablePtr =  (long*) capGetUserData(hwnd);
   long ptr = (long) (tablePtr[position]);
   return ptr;
}

/**
 * errorCallbackProc
 *    process error messages
 * Parameters:
 *    hWnd:           Application main window handle
 *    nErrID:         Error code for the encountered error
 *    lpErrorText:    Error text string for the encountered error
 * Results:
 *    TRUE or FALSE
 * Side effects:
 *    call captureListener->onNewError
 */
LRESULT FAR PASCAL CCaptureWinVfw::errorCallbackProc(HWND hWnd, int nErrID, LPSTR lpErrorText)
{
   int result;
   CCaptureWinVfw * thisPtr = (CCaptureWinVfw *) CCaptureWinVfw::getCallbackUserData(hWnd, 0);

   if (thisPtr->captureListener != NULL && nErrID!=0) {
      result = thisPtr->captureListener->onNewError(nErrID, lpErrorText);
   } else {
      result = TRUE;
   }
   return result ;
}


/**
 * statusCallbackProc
 *    process status messages
 *       IDS_CAP_BEGIN
 *       IDS_CAP_STAT_CAP_INIT
 *       IDS_CAP_SEQ_MSGSTOP
 *       IDS_CAP_STAT_VIDEOCURRENT (un message par trame)
 *       IDS_CAP_STAT_CAP_FINI     (un message par trame)
 *       IDS_CAP_STAT_VIDEOONLY
 *       IDS_CAP_END
 * Parameters:
 *    hWnd:           Application main window handle
 *    nID:            Status code for the current status
 *    lpStatusText:   Status text string for the current status
 * Results:
 *    TRUE or FALSE
 * Side effects:
 *    call captureListener->onNewStatus
 */
LRESULT FAR PASCAL CCaptureWinVfw::statusCallbackProc(HWND hWnd, int nID, LPSTR lpStatusText)
{
   int result;
   CCaptureWinVfw * thisPtr = (CCaptureWinVfw *) CCaptureWinVfw::getCallbackUserData(hWnd, 0);

   if (thisPtr->captureListener != NULL ) {
      result = thisPtr->captureListener->onNewStatus(nID, lpStatusText);
   } else {
      result = TRUE;
   }

   return result;
}

/**
 * setStatusMessage
 *    transmit message status
 *    This method is used by specific callback on video stream
 * Parameters:
 *    statusType:    Status code for the current status
 *    message:       Status text string for the current status
 * Results:
 *    TRUE or FALSE
 * Side effects:
 *    call captureListener->onNewStatus
 */

int CCaptureWinVfw::setStatusMessage( int statusType, char * message ) {

   return captureListener->onNewStatus(statusType, message);

}
