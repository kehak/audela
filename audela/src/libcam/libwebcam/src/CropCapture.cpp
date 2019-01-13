// CropCapture.cpp: implementation of the CCropCapture class.
//
//////////////////////////////////////////////////////////////////////

#include "windows.h"
#include <stdio.h>          //sprintf
#include "CropCapture.h"

// macros
#define WIDTHBYTES(bits)        (((bits) + 31) / 32 * 4)

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCropCapture::CCropCapture(CCaptureWinVfw * capture)
{
    
   CCropConfig();
    this->capture = capture;
    
    oldCropPreviewCallback = NULL;

    setMaxWidth(capture->getImageWidth());
    setMaxHeight(capture->getImageHeight());

    
}

CCropCapture::~CCropCapture()
{
   
}

/**
 * startCropCapture
 *   each frame is cropped by cropCallbackOnSequenceProc() 
 *   and save into the AVI file
 *
 * Results:
 *    TRUE or FALSE ( see GetLastError() )
 *
 * Side effects:
 *    prepare the input BITMAPINFOHEADER structure
 *    prepare the output AVISTREAMINFO struture
 *    open ICDecompress  and AVI file
 *    enable  cropCallbackOnSequenceProc()  callback
 *    launch startCaptureNoFile()
 *    disable  cropCallbackOnSequenceProc()  callback
 *    close ICDecompress and  AVI file
 *    display statistics in the status bar
 *
 */
int CCropCapture::startCropCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName ) {
    int             result;
    int             inputFormatSize;
    AVISTREAMINFO   outputAviStreamInfo; 
    char            message[256];
    HDC             hdc;
    unsigned long currentVideoFrame, currentTimeElapsedMS, droppedFrames;


    capture->allocFileSpace();
    ;
    // get video format of capture device
    if ((inputFormatSize = capture->getVideoFormatSize())<=0) {
        return FALSE;
    }

    if (inputFormatSize > sizeof(inputbi)) // Format too large? 
        return FALSE; 


    if (!capture->getVideoFormat(&inputbi, inputFormatSize)){
        return FALSE;
    }

    // open output file
    //capture->getCaptureFileName(fileName, sizeof(fileName));
    result = AVIFileOpen(
        &outputFile,                // returned file pointer
        fileName,                   // file name
        OF_WRITE | OF_CREATE,       // mode to open file with
        NULL);    
    if (result != AVIERR_OK) {
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

    // alloc buffers
    tempBuffer    = (unsigned char *) GlobalAlloc(GMEM_FIXED, tempbi.bmiHeader.biSizeImage ); 

    // prepare tempoprary bitmap 
    hdc = GetDC (NULL);     
    htempBitmap = CreateDIBitmap(hdc, &tempbi.bmiHeader, CBM_INIT, tempBuffer, &tempbi, DIB_RGB_COLORS);

    if (htempBitmap == NULL) {
        result = FALSE;
    }

    // prepare output BITMAPINFOHEADER
    outputbi.bmiHeader.biSize           = sizeof(BITMAPINFOHEADER); 
    outputbi.bmiHeader.biWidth          = getWidth(); 
    outputbi.bmiHeader.biHeight         = getHeight(); 
    outputbi.bmiHeader.biPlanes         = 1; 
    outputbi.bmiHeader.biBitCount       = 24; 
    outputbi.bmiHeader.biCompression    = BI_RGB;        // BI_RGB=0
    outputbi.bmiHeader.biSizeImage      = WIDTHBYTES((DWORD)outputbi.bmiHeader.biWidth * outputbi.bmiHeader.biBitCount) * outputbi.bmiHeader.biHeight; 
    outputbi.bmiHeader.biXPelsPerMeter  = 0; 
    outputbi.bmiHeader.biYPelsPerMeter  = 0; 
    outputbi.bmiHeader.biClrUsed        = 0; 
    outputbi.bmiHeader.biClrImportant   = 0;

    // alloc buffers
    outputBuffer  = (unsigned char *) GlobalAlloc(GMEM_FIXED, outputbi.bmiHeader.biSizeImage); 
    
    //houtputBitmap = CreateDIBitmap( hdc, &outputbi.bmiHeader, CBM_INIT, outputBuffer, &outputbi, DIB_RGB_COLORS );
    
    
    ReleaseDC(NULL, hdc);
    
    // prepare output AVISTREAMINFO
    memset(&outputAviStreamInfo, 0, sizeof(AVISTREAMINFO));
    outputAviStreamInfo.fccType             = streamtypeVIDEO; 
    //outputAviStreamInfo.fccHandler        = mmioFOURCC('I', '4', '2', '0'); // mmioFOURCC('I', '4', '2', '0'); ('D', 'I', 'B', ' ')
    outputAviStreamInfo.fccHandler          = mmioFOURCC('I', '4', '2', '0'); // mmioFOURCC('I', '4', '2', '0'); ('D', 'I', 'B', ' ')
    outputAviStreamInfo.dwFlags             = 0L; 
    outputAviStreamInfo.dwCaps              = 0L; 
    outputAviStreamInfo.wPriority           = 0; 
    outputAviStreamInfo.wLanguage           = 0; 
    outputAviStreamInfo.dwScale             = 1; 
    outputAviStreamInfo.dwRate              = (DWORD) (1000000.0/(-5.0 + capture->getCaptureRate())); 
    outputAviStreamInfo.dwStart             = 0; 
    outputAviStreamInfo.dwLength            = capture->getTimeLimit() * outputAviStreamInfo.dwRate; 
    outputAviStreamInfo.dwInitialFrames     = 0L; 
    outputAviStreamInfo.dwSuggestedBufferSize= outputbi.bmiHeader.biSizeImage; 
    outputAviStreamInfo.dwQuality           = 0xffffffff    ; 
    outputAviStreamInfo.dwSampleSize        = 0; 
    SetRect(&outputAviStreamInfo.rcFrame, 0, 0, (int) outputbi.bmiHeader.biWidth, (int) outputbi.bmiHeader.biHeight); 
    outputAviStreamInfo.dwEditCount         = 0; 
    outputAviStreamInfo.dwFormatChangeCount = 0; 
    strcpy(outputAviStreamInfo.szName , "crop output");
    
    result = AVIFileCreateStream(
        outputFile,                 // file pointer
        &outputps,                  // returned stream pointer
        &outputAviStreamInfo);      // stream header
    if (result != AVIERR_OK) {
        return FALSE;
    }

    result = AVIStreamSetFormat(outputps, 0, &outputbi.bmiHeader, sizeof(outputbi.bmiHeader) );
    if (result != AVIERR_OK) {
        return FALSE ;
    }


    // open decompression I420(YUY2) to DIB(RGB)
    hic = ICDecompressOpen(ICTYPE_VIDEO, 0, &inputbi.bmiHeader, &tempbi.bmiHeader);
    if (!hic) {   // Image dimensions outside of maximum limit
        return FALSE ;
    }

    result = ICDecompressBegin(hic, &inputbi, &tempbi);
    if (result != ICERR_OK) {
        return FALSE;
    }


    nbFrame = 0;
       

    // duree de la capture limitee dans le temps(en seconde)
    capture->setLimitEnabled(TRUE);
    capture->setTimeLimit(exptime);
    // frequence de la capture (millisecondes par frame)
    capture->setCaptureRate( microSecPerFrame);
    // nombre maxi de frames dans le fichier AVI (32000 par defaut)
    capture->setIndexSize (32767);
    // ne pas enregistrer le son
    capture->setCaptureAudio(FALSE);
    // ne pas utiliser le controle de peripheriques  MCI
    //capture->setMCIControl(FALSE);
    

    // capture now
    result = capture->startCaptureNoFile((FARPROC)cropCallbackOnSequenceProc, (long) this );   
        
    // desallocate ressources
    DeleteObject(htempBitmap);
    //DeleteObject(houtputBitmap);

    if ( hic) {
        ICDecompressEnd(hic); 
        ICClose(hic);
        hic = NULL;
    }

    if (outputps != NULL) AVIStreamClose(outputps);
    
    if (outputFile != NULL) AVIFileClose(outputFile);
    
    // desallocate buffers

    if (tempBuffer != NULL) {
        GlobalFree(tempBuffer);
        tempBuffer = NULL;
    }    
    if (outputBuffer != NULL) {
        GlobalFree(outputBuffer);
        outputBuffer = NULL;
    }    

    // display status
    capture->getCurrentStatus(&currentVideoFrame, &currentTimeElapsedMS);
    currentTimeElapsedMS = capture->getTimeLimit() * 1000;
    droppedFrames = (currentTimeElapsedMS + 50) *1000 / capture->getCaptureRate() - currentVideoFrame;
    sprintf(message, "%d trames capturées ( %d ignorées ). %d.%03ds" , 
        currentVideoFrame,
        droppedFrames, 
        currentTimeElapsedMS/1000,
        currentTimeElapsedMS%1000
        );
    
    capture->setStatusMessage( IDS_CAP_END, message );
    return TRUE;
}


/**
 * stopCropCapture
 *
 *
 */
 
int CCropCapture::stopCropCapture() {
    int result = TRUE;

    // disable callback proc
    

    return result;


}



/**
 *  cropCallbackOnSequenceProc
 *  this callback is called after capturing each frame 
 *
 *  hWnd:            Application main window handle
 *  vhdr:            video header
 */
LRESULT CALLBACK  CCropCapture::cropCallbackOnSequenceProc(HWND hWnd, VIDEOHDR *vhdr) {
    int result;
    
    //CCapture * thisPtr = (CCapture *)getCallbackUserData(hwnd, 0);

    CCropCapture  * thisPtr = (CCropCapture *) CCaptureWinVfw::getCallbackUserData(hWnd, 1);
    result = thisPtr->cropFrame( vhdr, hWnd );

    return result;
}



/**
 *  cropFrame
 *  crop a frame and save in AVI file
 *  
 * parameters :
 *   vhdr:            video header
 *   hWnd:            Application main window handle
 * Results:
 *   TRUE if 
 *
 * Side effects:
 *    converts I420 frame to DIB frame with ICDecompress standard function
 *    crops DIB frame 
 *    save the cropped frame into AVI file
 *    display frame count in the status bar with capture->setStatusMessage()
 */
BOOL CCropCapture::cropFrame(VIDEOHDR *vhdr,HWND hWnd ) {
    int         result;
    HDC         hdc;     
    HDC         hMemDCsrc;
    HDC         hMemDCdst;
    HGDIOBJ     oldScrObject, oldDstObject;    
    char        message[256];
    unsigned long currentVideoFrame, currentTimeElapsedMS, droppedFrames;
    BITMAP      bm;     


    // format conversion I420 to DIB
    result = ICDecompress(hic, 0, &inputbi.bmiHeader, vhdr->lpData, &tempbi.bmiHeader, tempBuffer);
    if (result != ICERR_OK) {
        MessageBeep(0);
        return FALSE;
    }
   

    hdc = GetDC (NULL);     

    if (htempBitmap == NULL) {
        MessageBeep(0);
        result = GetLastError();
    }

    // set bitmap bits (return value is the number of scan lines copied)    
    result = SetDIBits(
        hdc,                                // handle to device context
        htempBitmap,                        // handle to bitmap
        0,                                  // starting scan line
        tempbi.bmiHeader.biHeight,          // number of scan lines
        tempBuffer,                         // array of bitmap bits
        &tempbi,                            // address of structure with bitmap data
        DIB_RGB_COLORS                      // type of color indexes to use
        );
    
    hMemDCsrc = CreateCompatibleDC (hdc);     
    hMemDCdst = CreateCompatibleDC (hdc); 
    GetObject(htempBitmap, sizeof(BITMAP), (LPSTR)&bm); 
    
    result = GetDeviceCaps(hdc , BITSPIXEL);
    result = GetDeviceCaps(hdc , HORZRES);
    result = GetDeviceCaps(hMemDCsrc , BITSPIXEL);
    result = GetDeviceCaps(hMemDCdst , BITSPIXEL);
    
    
    houtputBitmap = CreateBitmap(outputbi.bmiHeader.biWidth, outputbi.bmiHeader.biHeight,bm.bmPlanes, bm.bmBitsPixel, NULL);  
    if (houtputBitmap == NULL) {
        MessageBeep(0);
        result = GetLastError();
    }
    
    oldScrObject = SelectObject (hMemDCsrc, htempBitmap);         
    oldDstObject = SelectObject (hMemDCdst, houtputBitmap);          

    // crops bitmap (If the function succeeds, the return value is nonzero)
    result = BitBlt (hMemDCdst, 0, 0, outputbi.bmiHeader.biWidth, outputbi.bmiHeader.biHeight, hMemDCsrc, getLeft(), getTop(), SRCCOPY);
    
    // get bits of output bitmap  (returned value is the number of scan lines )
    result = GetDIBits(
        hdc,                                // handle to device context
        houtputBitmap,                      // handle to bitmap
        0,                                  // first scan line to set in destination bitmap
        outputbi.bmiHeader.biHeight,        // number of scan lines to copy
        outputBuffer,                       // address of array for bitmap bits
        &outputbi,                          // address of structure with bitmap data
        DIB_RGB_COLORS                      // RGB or palette index
        );
    

    // write output bitmap in the avi file (Returns zero if successful)
    result = AVIStreamWrite(
        outputps,                           // output AVI stream, 
        nbFrame++, 
        1, 
        outputBuffer,
        outputbi.bmiHeader.biSizeImage,                 // size of this frame 
        AVIIF_KEYFRAME, 
        NULL, 
        NULL
        ); 
    
    SelectObject (hMemDCsrc, oldScrObject);
    SelectObject (hMemDCdst, oldDstObject);
    //DeleteObject(htempBitmap);
    DeleteObject(houtputBitmap);
    DeleteDC (hMemDCsrc);     
    DeleteDC (hMemDCdst);     
    ReleaseDC (NULL,hdc);         
       
    // display frame count in the status bar
    
    if ( vhdr->dwTimeCaptured - previousTimeCaptured  > 100 ) {
        
        //capture->getCurrentStatus(&currentVideoFrame, &currentTimeElapsedMS);
        currentVideoFrame=nbFrame;
        currentTimeElapsedMS =  vhdr->dwTimeCaptured;
        droppedFrames = (currentTimeElapsedMS +50) *1000 / capture->getCaptureRate() - currentVideoFrame;
        sprintf(message, "%d trames capturées ( %d ignorées ). %d.%03ds" , 
            currentVideoFrame,
            droppedFrames, 
            currentTimeElapsedMS/1000,
            currentTimeElapsedMS%1000
            );
        previousTimeCaptured = vhdr->dwTimeCaptured;
        capture->setStatusMessage( IDS_CAP_STAT_VIDEOCURRENT, message );	
        
    }
    
    if (result != ICERR_OK) {
        MessageBeep(0);
        return FALSE;
    }
    
    
    return TRUE;
}





/***************************************************************************/
//  Preview
/***************************************************************************/

/**
 *----------------------------------------------------------------------
 *
 * startCropPreview --
 *    display a cropping rectangle in the preview window
 *
 * Results:
 *    none
 *
 * Side effects:
 *    changes the preview window callback.
 *
 *----------------------------------------------------------------------
 */
void CCropCapture::startCropPreview(void)
{
    if (oldCropPreviewCallback == NULL ) {
        oldCropPreviewCallback = capture->setPreviewWindowCallbackProc(CCropCapture::previewCropCallbackProc, (long) this);
        hBrushPreview = CreateSolidBrush(0x0000FF);
    }
}

/**
 *----------------------------------------------------------------------
 *
 * stopCropPreview --
 *    stops drawing a cropping rectangle in the preview window
 *
 * Results:
 *    none
 *
 * Side effects:
 *    restores the preview window callback.
 *
 *----------------------------------------------------------------------
 */
void CCropCapture::stopCropPreview()
{
    if (oldCropPreviewCallback != NULL) {
        capture->setPreviewWindowCallbackProc(oldCropPreviewCallback, (long) NULL);
        oldCropPreviewCallback = NULL;
        DeleteObject(hBrushPreview);
    }
}

/**
 *----------------------------------------------------------------------
 *
 * cropPreviewProc --
 *
 *    this callback draws a cropping rectangle on the preview window
 *    (see startCropPreview)
 *
 * Results:
 *    Standard WindowProc return value.
 *
 * Side effects:
 *    May generate events.
 *
 *----------------------------------------------------------------------
 */

LRESULT CALLBACK CCropCapture::previewCropCallbackProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    LRESULT     result;
    HDC         previewDdc;
    RECT        cropRect;
    RECT        windowRect;
    float       zoom;

    // get context object
    CCropCapture * thisPtr = (CCropCapture *) GetWindowLong(hwnd, GWL_USERDATA);

    switch(message) {
     case WM_PAINT:

        // first displays the frame 
        result = CallWindowProc(thisPtr->oldCropPreviewCallback, hwnd, message, wParam, lParam);
        // gets cropping rect coordinates with the origin in upper/left corner.
        

        // get Window rect
        GetClientRect(hwnd, &windowRect);
        
        zoom =  (float) windowRect.right / thisPtr->capture->getImageWidth() ;
        thisPtr->getCropRect(&cropRect);
        
        cropRect.left   = (long) (zoom * cropRect.left) ;
        cropRect.right  = (long) (zoom * cropRect.right);
        cropRect.top    = (long) (zoom * cropRect.top);
        cropRect.bottom = (long) (zoom * cropRect.bottom);

        // draws the cropping rectangle
        previewDdc = GetDC(hwnd);
        FrameRect(previewDdc, &cropRect, thisPtr->hBrushPreview ); 
        ReleaseDC(hwnd, previewDdc);
        break;
   
      default:
        result = CallWindowProc((WNDPROC)thisPtr->oldCropPreviewCallback, hwnd, message, wParam, lParam);
        break;
   }
   
    return result;
}

