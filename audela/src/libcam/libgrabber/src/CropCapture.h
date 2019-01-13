// CropCapture.h: interface for the CCropCapture class.
//
//////////////////////////////////////////////////////////////////////

#ifndef __CROP_CAPTURE_H__
#define __CROP_CAPTURE_H__


#include "CropConfig.h"
#include "CaptureWinVfw.h"

class CCropCapture:public CCropConfig {
  public:
    CCropCapture(CCaptureWinVfw * capture);
    virtual ~ CCropCapture();

    void startCropPreview(void);
    void stopCropPreview(void);
    int startCropCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName);
    int stopCropCapture(void);
    static LRESULT CALLBACK previewCropCallbackProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
    static LRESULT CALLBACK cropCallbackOnSequenceProc(HWND hwnd, VIDEOHDR * vhdr);


     protected: CCaptureWinVfw * capture;

    // crop capture 
    BITMAPINFO inputbi;
    BITMAPINFO tempbi;
    BITMAPINFO outputbi;
    HBITMAP htempBitmap;
    HBITMAP houtputBitmap;

    unsigned char *tempBuffer;
    unsigned char *outputBuffer;
    int nbFrame;
    HIC hic;
    PAVISTREAM outputps;
    PAVIFILE outputFile;
    //RECT *              pCropRect;
    DWORD previousTimeCaptured;
    BOOL cropFrame(VIDEOHDR * vhdr, HWND hWnd);

    // crop preview
    HBRUSH hBrushPreview;
    WNDPROC oldCropPreviewCallback;

};

#endif				// !defined(AFX_CROPCAPTURE_H__8F19E0F0_6A65_4531_97B5_A4FBB1C6BECC__INCLUDED_)
