/* 
 * 
 *	xclibsc.h	External	29-Oct-2004 
 * 
 *	Copyright (C)  1999-2003  EPIX, Inc.  All rights reserved. 
 * 
 *	Frame Grabber Library: Simple, 'C' function oriented, interface. 
 * 
 */ 
 
 
#if !defined(__EPIX_XCLIBSC_DEFINED) 
#define __EPIX_XCLIBSC_DEFINED 
#include "cext_hps.h" 
 
#ifdef  __cplusplus 
extern "C" { 
#endif 
 
/* 
 * Open/close/faults 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_PIXCIopen(char *driverparms, char *formatname, char *formatfile); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_PIXCIclose(); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_mesgFault(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,char*)     pxd_mesgErrorCode(int err); 
#if defined(CTOBAS)  // alternate declaration for VB/CTOBAS - must preceed others! 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_mesgFaultText(int unitmap, char buf[], int bufsize); 
#endif 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_mesgFaultText(int unitmap, char *buf, int bufsize); 
 
/* 
 * Board/library/driver info 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_infoModel(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_infoSubmodel(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,ulong)     pxd_infoMemsize(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_infoUnits(); 
_cDcl(_dllpxlib,_cfunfcc,char*)     pxd_infoDriverId(); 
_cDcl(_dllpxlib,_cfunfcc,char*)     pxd_infoLibraryId(); 
#define 			    pxd_infoIncludeId() XCLIB_IDNVR 
 
/* 
 * Image info 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_imageXdim(); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_imageYdim(); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_imageCdim(); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_imageBdim(); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_imageZdim(); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_imageIdim(); 
_cDcl(_dllpxlib,_cfunfcc,double)    pxd_imageAspectRatio(); 
 
/* 
 * Image read/write 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_readuchar  (int unitmap,pxbuffer_t framebuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,uchar *membuf,int cnt,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_writeuchar (int unitmap,pxbuffer_t framebuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,uchar *membuf,int cnt,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_readushort (int unitmap,pxbuffer_t framebuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,ushort *membuf,int cnt,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_writeushort(int unitmap,pxbuffer_t framebuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,ushort *membuf,int cnt,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,pximage_s*)	pxd_defineImage   (int unitmap,pxbuffer_t framebuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,pximage3_s*)	pxd_defineImage3  (int unitmap,pxbuffer_t startbuf,pxbuffer_t endbuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,pximage_s*)	pxd_definePximage (int unitmap,pxbuffer_t framebuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,pximage3_s*)	pxd_definePximage3(int unitmap,pxbuffer_t startbuf,pxbuffer_t endbuf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,char *colorspace); 
_cDcl(_dllpxlib,_cfunfcc,void)		pxd_definePximageFree (pximage_s*); 
_cDcl(_dllpxlib,_cfunfcc,void)		pxd_definePximage3Free(pximage3_s*); 
 
 
/* 
 * Video capture 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_doSnap(int unitmap, pxbuffer_t buffer, ulong timeout); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goSnap(int unitmap, pxbuffer_t buffer); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goSnapPair(int unitmap, pxbuffer_t buffer1, pxbuffer_t buffer2); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goLive(int unitmap, pxbuffer_t buffer); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goUnLive(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goAbortLive(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goLivePair(int unitmap, pxbuffer_t buffer1, pxbuffer_t buffer2); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goLiveSeq(int unitmap, pxbuffer_t startbuf,pxbuffer_t endbuf,pxbuffer_t incbuf,pxbuffer_t numbuf,int period); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goLiveTrig(int unitmap, pxbuffer_t buffer,uint gpin10mask,uint gpout20value,uint gpout20mask,uint gpout20when, 
						       uint gpin30wait,uint gpin30mask,uint gpout40value,uint gpout40mask,uint option50,uint field50, 
						       uint gpout50value,uint gpout50mask,uint delay60,uint gpout60value,uint gpout60mask,uint delay70, 
						       uint field70,uint capture70,uint gpin80mask,uint gpout80value,uint gpout80mask); 
 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goLiveSeqTrig(int unitmap, pxbuffer_t startbuf,pxbuffer_t endbuf,pxbuffer_t incbuf,pxbuffer_t numbuf,int period, 
						       uint rsvd1,uint rsvd2,uint trig20wait,uint trig20slct,pxvbtime_t trig20delay,uint rsvd3,uint rsvd4, 
						       uint rsvd5,uint rsvd6,pxvbtime_t rsvd7,uint rsvd8,uint rsvd9,uint trig40wait,uint trig40slct, 
						       pxvbtime_t trig40delay,uint rsvd10,uint rsvd11,uint rsvd12,uint rsvd13,uint rsvd14,uint rsvd15); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_goneLive(int unitmap, int rsvd); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_videoFieldsPerFrame(void); 
_cDcl(_dllpxlib,_cfunfcc,ulong) 	pxd_videoFieldCount(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,ulong) 	pxd_getFieldCount(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,pxbuffer_t)	pxd_capturedBuffer(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,uint32)	pxd_capturedSysTicks(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,pxvbtime_t)	pxd_capturedFieldCount(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,pxvbtime_t)	pxd_buffersFieldCount(int unitmap, pxbuffer_t buffer); 
_cDcl(_dllpxlib,_cfunfcc,uint32)	pxd_buffersSysTicks(int unitmap, pxbuffer_t buffer); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_buffersGPIn(int unitmap, pxbuffer_t buffer); 
 
/* 
 * SV2/SV3/SV4/SV5 Video adjust 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_setVidMux(int unitmap, int inmux); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_getVidMux(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_setContrastBrightness(int unitmap, double contrast, double brightness); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_setHueSaturation(int unitmap, double hue, double Ugain, double Vgain); 
_cDcl(_dllpxlib,_cfunfcc,double)    pxd_getContrast(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double)    pxd_getBrightness(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double)    pxd_getHue(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double)    pxd_getUGain(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double)    pxd_getVGain(int unitmap); 
 
/* 
 * D/D24/D32/A/D2X/D3X/CL1/CL2/CL3SD/SI Video adjust. 
 * 
 * Use of pxd_setExsyncPrincMode() should be avoided in preference 
 * to loading an appropriate video setup file! If used, it must 
 * not change resolution, trigger mode, etc! 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setExsyncPrin(int unitmap, uint exsync, uint prin); 
_cDcl(_dllpxlib,_cfunfcc,uint)	pxd_getExsync(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,uint)	pxd_getPrin(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setExsyncPrincMode(int unitmap, uint exsyncbits, uint princbits); 
_cDcl(_dllpxlib,_cfunfcc,uint)	pxd_getExsyncMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,uint)	pxd_getPrincMode(int unitmap); 
 
/* 
 * G.P. In/Out 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_getGPIn(int unitmap, int data); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setGPIn(int unitmap, int data); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setGPOut(int unitmap, int data); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_getGPOut(int unitmap, int data); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_getGPTrigger(int unitmap, int which); 
 
/* 
 * Display. 
 */ 
#if  defined(OS_WIN95)|defined(OS_WIN95_DLL) \
    |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
_cDcl(_dllpxlib,_cfunfcc,HGLOBAL)   pxd_renderDIBCreate(int unitmap, pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry, int mode, int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_renderDIBFree(HGLOBAL hDIB); 
_cDcl(_dllpxlib,_cfunfcc,int)	    pxd_renderStretchDIBits(int unitmap,pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,int options, 
						HDC hDC,uint nX,uint nY,uint nWidth,uint nHeight,int winoptions); 
#endif 
 
/* 
 * Load/Save. 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_saveBmp(int unitmap, char *pathname,pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,int savemode,int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_loadBmp(int unitmap, char *pathname,pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,int loadmode,int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_saveTga(int unitmap, char *pathname,pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,int savemode,int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_savePcx(int unitmap, char *pathname,pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,int savemode,int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_saveTiff(int unitmap, char *pathname,pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,int savemode,int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_loadTiff(int unitmap, char *pathname,pxbuffer_t buf,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry,int loadmode,int options); 
#if defined(CTOBAS)  // alternate declaration for VB/CTOBAS - must preceed others! 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_saveRawBuffers(int unitmap,char *pathname, pxbuffer_t startbuf, pxbuffer_t endbuf, int filehandle, pxbuffer_t fileoffset, uint32 alignment,int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_loadRawBuffers(int unitmap,char *pathname, pxbuffer_t startbuf, pxbuffer_t endbuf, int filehandle, pxbuffer_t fileoffset, uint32 alignment,int options); 
#else 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_saveRawBuffers(int unitmap,char *pathname, pxbuffer_t startbuf, pxbuffer_t endbuf, void *filehandle, pxbuffer_t fileoffset, uint32 alignment,int options); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_loadRawBuffers(int unitmap,char *pathname, pxbuffer_t startbuf, pxbuffer_t endbuf, void *filehandle, pxbuffer_t fileoffset, uint32 alignment,int options); 
#endif 
 
/* 
 * Display w. S/VGA support. 
 */ 
#if  defined(OS_WIN95)|defined(OS_WIN95_DLL) \
    |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_renderDirectVideoUnLive(int unitmap, HWND hWnd); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_renderDirectVideoLive(int unitmap, HWND hWnd, uint nX, uint nY, 
					    uint nWidth,uint nHeight,COLORREF ClrKey1,COLORREF ClrKey2); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_renderDirectVideoDone(int unitmap, HWND hWnd); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_renderDirectVideoInit(int unitmap, HWND hWnd); 
#endif 
 
/* 
 * Events. 
 */ 
#if  defined(OS_WIN95)|defined(OS_WIN95_DLL) \
    |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
_cDcl(_dllpxlib,_cfunfcc,HANDLE) pxd_eventFieldCreate(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc, void)  pxd_eventFieldClose(int unitmap, HANDLE hEvent); 
_cDcl(_dllpxlib,_cfunfcc,HANDLE) pxd_eventCapturedFieldCreate(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc, void)  pxd_eventCapturedFieldClose(int unitmap, HANDLE hEvent); 
_cDcl(_dllpxlib,_cfunfcc,HANDLE) pxd_eventGPTriggerCreate(int unitmap, int which, int rsvd); 
_cDcl(_dllpxlib,_cfunfcc, void)  pxd_eventGPTriggerClose(int unitmap, int which, int rsvd, HANDLE hEvent); 
#endif 
#if defined(OS_DOS4GW) 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventFieldCreate(int unitmap, pxasyncfunc_t *irqfunc, void *statep); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventFieldClose(int unitmap, pxasyncfunc_t *irqfunc); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventCapturedFieldCreate(int unitmap, pxasyncfunc_t *irqfunc, void *statep); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventCapturedFieldClose(int unitmap, pxasyncfunc_t *irqfunc); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventGPTriggerCreate(int unitmap, int which, int rsvd, pxasyncfunc_t *irqfunc, void *statep); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventGPTriggerClose(int unitmap, int which, int rsvd, pxasyncfunc_t *irqfunc); 
#endif 
#if defined(OS_LINUX_GNU) 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventFieldCreate(int unitmap, int sig, void *rsvd); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventFieldClose(int unitmap, int sig); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventCapturedFieldCreate(int unitmap, int sig, void *rsvd); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventCapturedFieldClose(int unitmap, int sig); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventGPTriggerCreate(int unitmap, int which, int rsvd, int sig, void *rvsd2); 
_cDcl(_dllpxlib,_cfunfcc, int)	pxd_eventGPTriggerClose(int unitmap, int which, int rsvd, int sig); 
#endif 
 
/* 
 * Image corrections 
 */ 
#if defined(CTOBAS)  // alternate declaration for VB/CTOBAS - must preceed others! 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setImageDarkBalance(int unitmap, uint referenceRGB[], uint targetRGB[], double gamma); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setImageBrightBalance(int unitmap, uint referenceRGB[], uint targetRGB[], double gamma); 
#endif
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setImageDarkBalance(int unitmap, uint referenceRGB[3], uint targetRGB[3], double gamma); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_setImageBrightBalance(int unitmap, uint referenceRGB[3], uint targetRGB[3], double gamma); 
 
/* 
 * Serial port 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_serialConfigure(int unitmap, int rsvd0, double baud, int bits, int parity, int stopbits, int rsvd1, int rsvd2, int rsvd3); 
#if defined(CTOBAS)  // alternate declaration for VB/CTOBAS - must preceed others! 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_serialRead(int unitmap, int rsvd0, uchar *buf, int cnt); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_serialWrite(int unitmap, int rsvd0, uchar *buf, int cnt); 
#endif 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_serialRead(int unitmap, int rsvd0, char buf[], int cnt); 
_cDcl(_dllpxlib,_cfunfcc,int)	pxd_serialWrite(int unitmap, int rsvd0, char buf[], int cnt); 
 
 
/* 
 * Serial port, CameraLink standard API. 
 * (N.B. The clSerial() functions in XCLIB only work 
 * with the library already opened. A seperate clserPIXCI.dll 
 * is available for stand-alone use w/out XCLIB). 
 */ 
#if  defined(OS_WIN95)|defined(OS_WIN95_DLL) \
    |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
_cDcl(_dllpxlib,__cdecl,int)	clSerialInit(ulong serialIndex, void **serialRefPtr); 
_cDcl(_dllpxlib,__cdecl,int)	clSerialClose(void *serialRefPtr); 
_cDcl(_dllpxlib,__cdecl,int)	clSerialRead(void *serialRefPtr, char *buffer, ulong *bufferSize, ulong serialTimeout); 
_cDcl(_dllpxlib,__cdecl,int)	clSerialWrite(void *serialRefPtr, char *buffer, ulong *bufferSize, ulong serialTimeout); 
#endif 
 
 
/* 
 * Camera specific 
 */ 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_setExposureAndGain(int unitmap, int rsvd, double exposure, double redgain, double grngain, double blugain); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_setResolutionAndTiming(int unitmap, int rsvd, int decimation, int aoileft, int aoitop, int aoiwidth, int aoiheight, 
								  int scandirection, double pixelClkFreq, double rsvd2, int rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_setVideoAndTriggerMode(int unitmap, int rsvd, int videomode, int controlledvideomode, int controlledtrigger); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_setCtrlExposureAndRate(int unitmap, int rsvd, double exposure, double framerate); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV2112_getExposure(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV2112_getGain(int unitmap, int color); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_getDecimation(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_getAoiTop(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_getAoiLeft(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV2112_getPixelClock(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_getScanDirection(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_getVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_getCtrlVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV2112_getCtrlTriggerMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV2112_getCtrlFrameRate(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV2112_getCtrlExposure(int unitmap); 
 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_setExposureGainOffset(int unitmap, int rsvd, double exposure, double gain, double offset, double rsvd2, double rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_setColorGain(int unitmap, int rsvd, double greenR, double red, double blue, double greenB); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_setResolutionAndTiming(int unitmap, int rsvd, int subsample, int aoileft, int aoitop, int aoiwidth, int aoiheight, 
								   int readoutdirection, double pixelClkFreq, double framePeriod, double rsvd2); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_setVideoAndTriggerMode(int unitmap, int rsvd, int videomode, int controlledmode, int controlledtrigger, int strobemode, int rsvd2, int rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_setCtrlRate(int unitmap, int rsvd, double rsvd2, double framerate, double rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1310_getExposure(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1310_getGain(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1310_getOffset(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getSubsample(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getAoiTop(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getAoiLeft(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getReadoutDirection(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1310_getPixelClock(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1310_getFramePeriod(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1310_getCtrlFrameRate(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getCtrlVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getCtrlTriggerMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1310_getStrobeMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1310_getColorGain(int unitmap, int color); 
 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_setExposureGainOffset(int unitmap, int rsvd, double exposure, 
						double gain, double offset, double rsvd2, double rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_setResolutionAndTiming(int unitmap, int rsvd, int rsvd1, 
						int aoileft, int aoitop, int aoiwidth, int aoiheight, 
						int rsvd4, double pixelClkFreq, double rsvd2, double rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_setVideoAndTriggerMode(int unitmap, int rsvd, int videomode, int controlledvideomode, int controlledtrigger, int rsvd1, int rsvd2, int rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_setCtrlRate(int unitmap, int rsvd, double rsvd2, double framerate, double rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1281_getExposure(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1281_getGain(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1281_getOffset(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_getAoiTop(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_getAoiLeft(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1281_getPixelClock(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_getVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_getCtrlVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV1281_getCtrlTriggerMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV1281_getCtrlFrameRate(int unitmap); 
 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_setExposureAndGain(int unitmap, int rsvd, double exposure, double redgain, double grnrgain, double bluegain, double grnbgain); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_setResolutionAndTiming(int unitmap, int rsvd, int subsample, int aoileft, int aoitop, int aoiwidth, int aoiheight, int scandirection, double pixelClkFreq, double framePeriod, double rsvd2); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_setVideoAndTriggerMode(int unitmap, int rsvd, int videomode, int controlledmode, int controlledtrigger, int rsvd4, int rsvd2, int rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_setCtrlRate(int unitmap, int rsvd, double rsvd2, double framerate, double rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_setExposureAndDigitalGain(int unitmap, int rsvd, double exposure, double digitalgain, double rsvd2, double rsvd3, double rsvd4); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV9M001_getExposure(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_getAoiTop(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_getAoiLeft(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV9M001_getGain(int unitmap, int color); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV9M001_getPixelClock(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV9M001_getFramePeriod(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_getVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV9M001_getCtrlFrameRate(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_getCtrlVideoMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_getCtrlTriggerMode(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_getSubsample(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,int)	 pxd_SV9M001_getScanDirection(int unitmap); 
_cDcl(_dllpxlib,_cfunfcc,double) pxd_SV9M001_getDigitalGain(int unitmap); 
 
/* 
 * Escape to Structured Interface services. 
 * The pxd_xclibEscaped should be called to 'release' 
 * the access obtained via pxd_xclibEscape; it causes an update 
 * of cached information maintained by the SCF functions and resets 
 * the video engine, leaving the state similar to that after a pxd_PIXCIopen. 
 */ 
_cDcl(_dllpxlib,_cfunfcc,xclibs_s *)	pxd_xclibEscape(int rsvd1, int rsvd2, int rsvd3); 
_cDcl(_dllpxlib,_cfunfcc,int)		pxd_xclibEscaped(int rsvd1, int rsvd2, int rsvd3); 
 
/* 
 * Allow compiling a video format configuration 
 * into the application, and loading as desired. 
 * Use as 
 *  { 
 *     #include "newformat.fmt" 
 *     pxd_videoFormatAsIncluded(0); 
 *  } 
 * The suggested braces allow multiple uses by limiting the 'C' 
 * scope of the names declared within the included file. 
 * 
 * 
 */ 
static	struct pxvidstate   pxd_videoFormatAsIncluded_vidstate;     /* internal use */ 
static	int		    pxd_videoFormatAsIncluded_r1;	    /* internal use */ 
static	int		    pxd_videoFormatAsIncluded_r2;	    /* internal use */ 
#define pxd_videoFormatAsIncluded(rsvd) \
     (memset(&pxd_videoFormatAsIncluded_vidstate, 0, sizeof(pxd_videoFormatAsIncluded_vidstate)), \
     (pxd_videoFormatAsIncluded_vidstate.ddch.len    = sizeof(pxd_videoFormatAsIncluded_vidstate)),\
     (pxd_videoFormatAsIncluded_vidstate.ddch.mos    = PXMOS_VIDSTATE),\
     (pxd_videoFormatAsIncluded_vidstate.vidformat   = &pxvidformat_561_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.vidres      = &pxvidres_125_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.vidmode     = &pxvidmode_79_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.vidphys     = &pxvidphys_118_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.vidimage    = &pxvidimage_251_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.vidopt      = &pxvidopt_19_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.vidmem      = &pxvidmem_72_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.camcntl     = &pxcamcntl_264_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.xc.sv2format= &xcsv2format_32_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.xc.sv2mode  = &xcsv2mode_21_id31232),\
     (pxd_videoFormatAsIncluded_vidstate.xc.dxxformat= &xcdxxformat_45_id31232),\
     pxd_goAbortLive((1&lt;&lt;pxd_infoUnits())-1),\
     (pxd_videoFormatAsIncluded_r1 = pxd_xclibEscape(0,0,0)->pxlib.defineState(&pxd_xclibEscape(0,0,0)->pxlib, 0, PXMODE_DIGI, &pxd_videoFormatAsIncluded_vidstate)),\
     (pxd_videoFormatAsIncluded_r2 = pxd_xclibEscaped(0,0,0)), \
     ((pxd_videoFormatAsIncluded_r1 &lt; pxd_videoFormatAsIncluded_r2) ? pxd_videoFormatAsIncluded_r1 : pxd_videoFormatAsIncluded_r2)) 
 
 
 
/* 
 * Helpful conversion macros for programs using the XCOBJ API. 
 * Assumes one imaging board is in use. Not a complete set of 
 * conversions, but will handle the needs of most applications. 
 * 
 * Most conversions, below, are straightfoward, and can be read 
 * as an aid to understanding the differences between XCOBJ and 
 * XCLIB. Other conversions are easy in principle, but the macros 
 * become complex due to having to convert parameters from one 
 * format to another.  Use of pxd_ioc, in particular, is very easy 
 * to convert manually, but because XCOBJ used one function to 
 * specify an AOI and a second to actually transfer, the macros 
 * must save information from one macro invocation to the next. 
 * Also, the pxd_ioc conversion only supports the most common modes, 
 * of reading or writing pixels left to right and top to bottom. 
 * 
 * Note that while a different function is used to obtain a struct 
 * pximage (for an alternate to using pxd_io frame buffer access); once 
 * obtained the struct pximage operates in the same manner as in XCOBJ. 
 */ 
#if defined(XCOBJ_TO_XCLIB_MACROS) 
#include &lt;string.h>	    /* for pxd_xcopen */ 
#define pxd_close()	    pxd_PIXCIclose() 
#define pxd_xcopen(F,P)     pxd_PIXCIopen(P, \
				 (F&&!( stricmp(F,"RS-170") &stricmp(F,"NTSC") \
				       &stricmp(F,"NTSC/YC")&stricmp(F,"CCIR") \
				       &stricmp(F,"PAL")    &stricmp(F,"PAL/YC") \
				       &stricmp(F,"PAL(M)") &stricmp(F,"PAL(M)/YC") \
				       &stricmp(F,"PAL(N)") &stricmp(F,"PAL(N)/YC") \
				       &stricmp(F,"SECAM")  &stricmp(F,"SECAM/YC")))?F: (F?NULL:"Default"), \
				 (F&&!( stricmp(F,"RS-170") &stricmp(F,"NTSC") \
				       &stricmp(F,"NTSC/YC")&stricmp(F,"CCIR") \
				       &stricmp(F,"PAL")    &stricmp(F,"PAL/YC") \
				       &stricmp(F,"PAL(M)") &stricmp(F,"PAL(M)/YC") \
				       &stricmp(F,"PAL(N)") &stricmp(F,"PAL(N)/YC") \
				       &stricmp(F,"SECAM")  &stricmp(F,"SECAM/YC")))?NULL:F); 
 
#define pxvid_xbuf(S)			    (pxd_capturedBuffer(1)>0?pxd_capturedBuffer(1):1) 
#define pxd_xcmodel()			    pxd_infoModel(1) 
#define pxd_xcmodelcamera()		    pxd_infoSubmodel(1) 
#define pxd_udim()			    pxd_infoUnits() 
#define pxd_xdim()			    pxd_imageXdim() 
#define pxd_ydim()			    (pxd_imageYdim()/(pxd_imageIdim()==0?1:pxd_imageIdim())) 
#define pxd_cdim()			    pxd_imageCdim() 
#define pxd_bdim()			    (pxd_imageCdim()*pxd_imageBdim()) 
#define pxd_ylace()			    (pxd_imageIdim()-1) 
#define pxd_vidmux(m)			    pxd_setVidMux(1,m+1) 
#define pxd_imbufs()			    pxd_imageZdim() 
#define pxd_imsize()			    (pxd_infoMemsize(1)/1024) 
#define pxd_chkfault(R) 		    pxd_mesgFault(1) 
#define pxd_chkstack(R) 
#define pxerrnomesg(M)			    pxd_mesgErrorCode(M) 
#define pxd_defimage(Z,A,B,C,D) 	    pxd_defineImage(1,Z>0?Z:pxvid_xbuf(0),A,B,C,D, pxd_imageCdim()>1?"RGB":"Grey") 
#define pxd_defimage3(Y,Z,A,B,C,D)	    pxd_defineImage3(1,Y,Z,A,B,C,D, pxd_imageCdim()>1?"RGB":"Grey") 
#define pxd_defimagecolor(Z,A,B,C,D,G)	    pxd_defineImage(1,Z>0?Z:pxvid_xbuf(0),A,B,C,D,G) 
#define pxd_defimage3color(Y,Z,A,B,C,D,G)   pxd_defineImage3(1,Y,Z,A,B,C,D,G) 
#define pxd_vidtime()			    pxd_getFieldCount(1) 
#define pxd_StretchDIBits(A,B,C,D,E,F,G, H,I,J,K,L,M) \
					    pxd_renderStretchDIBits(1,A>0?A:pxvid_xbuf(0),B,C,D,E,0, H,I,J,K,L,0) 
#define pxd_snap(A,B,C,D,E)		    pxd_doSnap(1, B>0?B:pxvid_xbuf(0), C) 
#define pxd_video(A,B)			    (A=='z'? pxd_goLive(1,B>0?B:pxvid_xbuf(0)): pxd_goUnLive(1)) 
 
int	pxd_io1[8][6];	    /* must save pxd_iopen's state for later pxd_ioc! */ 
char	pxd_io2[8][32];     /* must save pxd_iopen's state for later pxd_ioc! */ 
#define pxd_iopen(H,B,ULX,ULY,LRX,LRY,MODE) \
		    (((H)&lt;0||(H)>=8||!((MODE)==('r'^'x')||(MODE)==('w'^'x')))? PXERROR: \
			((pxd_io1[H][0]=B,pxd_io1[H][1]=ULX, \
			  pxd_io1[H][2]=ULY,pxd_io1[H][3]=LRX, \
			  pxd_io1[H][4]=LRY,pxd_io1[H][5]=MODE,strncpy(pxd_io2[H],"Grey",32)), 1)) 
 
#define pxd_io(h,b,n)	pxd_ioc(h,b,n) 
#define pxd_ioc(H,B,N)	(((H)&lt;0||(H)>=8)? PXERROR: \
			pxd_io1[H][5]==('r'^'x') ? pxd_readuchar(1, pxd_io1[H][0], pxd_io1[H][1], pxd_io1[H][2], \
								  pxd_io1[H][3], pxd_io1[H][4], B, N, pxd_io2[H]) : \
			pxd_io1[H][5]==('w'^'x') ? pxd_writeuchar(1, pxd_io1[H][0], pxd_io1[H][1], pxd_io1[H][2], \
								  pxd_io1[H][3], pxd_io1[H][4], B, N, pxd_io2[H]) : \
			PXERROR) 
#define pxd_ios(H,B,N)	(((H)&lt;0||(H)>=8)? PXERROR: \
			pxd_io1[H][5]==('r'^'x') ? pxd_readushort(1, pxd_io1[H][0], pxd_io1[H][1], pxd_io1[H][2], \
								  pxd_io1[H][3], pxd_io1[H][4], B, N, pxd_io2[H]) : \
			pxd_io1[H][5]==('w'^'x') ? pxd_writeushort(1, pxd_io1[H][0], pxd_io1[H][1], pxd_io1[H][2], \
								  pxd_io1[H][3], pxd_io1[H][4], B, N, pxd_io2[H]) : \
			PXERROR) 
 
#define pxd_setDalsa01(p,e)	{ pxd_setExsyncPrin(1,e>>16,p>>16); pxd_setExsyncPrincMode(1,e&0xFFFF,p&0xFFFF); } 
#define pxd_setKodak01(p,e)	pxd_setDalsa01(p,e) 
#define pxd_setHitachi01(p,e)	pxd_setDalsa01(p,e) 
#define pxd_setBasler01(p,e)	pxd_setDalsa01(p,e) 
 
#define pxd_extin(w)		pxd_getGPIn(1,0) 
#define pxd_extinreset(v,w)	pxd_setGPIn(1,v) 
#define pxd_extout(v,w) 	pxd_setGPOut(1,v) 
 
#endif	    /* defined(XCOBJ_TO_XCLIB_MACROS) */ 
 
#ifdef  __cplusplus 
} 
#endif 
 
#include "cext_hpe.h" 
#endif	    /* !defined(__EPIX_XCLIBSC_DEFINED) */ 
