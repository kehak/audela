/* 
 * 
 *	pxlibcam.h	External	28-Feb-2005 
 * 
 *	Copyright (C)  1999-2004  EPIX, Inc.  All rights reserved. 
 * 
 *	Frame Grabber Library: Camera Control Definitions 
 * 
 */ 
 
 
#if !defined(__EPIX_PXLIBCAM_DEFINED) 
#define __EPIX_PXLIBCAM_DEFINED 
#include "cext_hps.h"      
 
#ifdef  __cplusplus 
extern "C" { 
#endif 
 
 
/* 
 * Generic Command Verbs 
 */ 
#define PXCam_MapCameraStateToVideoState	0x0001 
#define PXCam_MapVideoStateToCameraState	0x0002 
#define PXCam_SetDefaultValuesInCameraState	0x0004 
#define PXCam_SetCorrectValuesInCameraState	0x0005 
#define PXCam_SetMinimumValuesInCameraState	0x0006 
#define PXCam_SetMaximumValuesInCameraState	0x0007 
#define PXCam_SetAtomicValuesInCameraState	0x0008 
#define PXCam_InitCameraStateViaHandle		0x0009 
#define PXCam_ResetCameraStateViaHandle 	0x000A 
#define PXCam_UploadCameraStateViaHandle	0x000B 
#define PXCam_UploadCameraStateDeltaViaHandle	0x000C 
#define PXCam_DownloadCameraStateViaHandle	0x000D 
#define PXCam_DownloadCameraIDStateViaHandle	0x000E 
 
/* 
 * Generic Port Selection Verbs 
 */ 
#define PXCam_PortUnused		0x000 
#define PXCam_PortIspxdevservice	0x001 
#define PXCam_PortIsFILE		0x002 
#define PXCam_PortIsHANDLE		0x003 
 
 
/* 
 * SILICON VIDEO 2112 State & Control 
 */ 
struct PXCam_SV2112State { 
    struct  pxddch  ddch; 
 
    int 	id;		    /* as reported		    */ 
    int 	frameMode;	    /* 's': still frame, 'v': video */ 
    int 	aoiLeft;	    /* AOI. these values are ..     */ 
    int 	aoiTop; 	    /* .. always relative to ..     */ 
    int 	aoiWidth;	    /* .. full resolution and ..    */ 
    int 	aoiHeight;	    /* .. independent of decimation */ 
    int 	testRamp;	    /* 0: off, 1: on		    */ 
    int 	pixelRegistration;  /* 0: off, 1: on		    */ 
    int 	scanDirection;	    /* CC('L', 'T'): L-R/T-B	    */ 
				    /* CC('R', 'T'): R-L/T-B	    */ 
				    /* CC('L', 'B'): L-R/B-T	    */ 
				    /* CC('R', 'B'): R-L/B-T	    */ 
    int 	decimation;	    /* 0x0101: none		    */ 
				    /* 0x0202: 2x2		    */ 
				    /* 0x0404: 4x4		    */ 
    double	gain[3];	    /* for R,G&B in db		    */ 
    double	exposure;	    /* in milliseconds		    */ 
    int 	rgbGainLock;	    /* 0: off, 1: on		    */ 
    double	extendedLineTime;   /* in microseconds		    */ 
    double	pixelClkFreq;	    /* in MHz. Info only which must */ 
				    /* be supplied		    */ 
 
    struct { 
				    /* controlled mode: */ 
	int	mode;		    /* 's', 'c' 	*/ 
	double	framerate;	    /* Hz		*/ 
	double	exposure;	    /* millisec 	*/ 
	int	trigger;	    /* 'n', '+', '-'	*/ 
	int	strobe; 	    /* 'n', 'p' 	*/ 
	int	bits;		    /* 8, 10		*/ 
	double	linepulses;	    /* internal use	*/ 
	int	minrnl; 	    /* internal use	*/ 
    } adj; 
}; 
typedef struct PXCam_SV2112State PXCam_SV2112State_s; 
#define PXMOS_CAMSV2112STATE	(PXMOS_DDCH+24) 
 
 
_cDcl(_dllpxlib,_cfunfcc, int) 
PXCam_SILICONVIDEO2112(int cmnd, int rsvd, int unitmap, int porttype, 
		       void *port, PXCam_SV2112State_s *camstatep, 
		       PXCam_SV2112State_s *camstate2p, pxvidstate_s *vidstatep); 
 
 
 
/* 
 * SILICON VIDEO 1310 State & Control 
 */ 
struct PXCam_SV1310State { 
    struct  pxddch  ddch; 
 
    int 	id;		    /* as reported			*/ 
    int 	negADCRef;	    /* mV				*/ 
    int 	posADCRef;	    /* mV				*/ 
    int 	power;		    /* 1 or 0				*/ 
    int 	videoMode;	    /* 'c': free-run, 's': controlled	*/ 
    int 	subsampleMode;	    /* 0: default: 'm': mono, 'b': bayer*/ 
    int 	subsample;	    /* 0x101: none			*/ 
				    /* 0x202: 2x2			*/ 
				    /* 0x404: 4x4			*/ 
				    /* 0x808: 8x8			*/ 
				    /* 0x102: etc			*/ 
				    /* 0x104:				*/ 
				    /* 0x108:				*/ 
				    /* 0x201:				*/ 
				    /* 0x204:				*/ 
				    /* 0x208:				*/ 
				    /* 0x401:				*/ 
				    /* 0x402:				*/ 
				    /* 0x408:				*/ 
				    /* 0x801:				*/ 
				    /* 0x802:				*/ 
				    /* 0x804:				*/ 
    int 	aoiLeft;	    /* AOI. these values are .. 	*/ 
    int 	aoiTop; 	    /* .. always relative to .. 	*/ 
    int 	aoiWidth;	    /* .. full resolution and ..	*/ 
    int 	aoiHeight;	    /* .. independent of decimation	*/ 
    int 	readoutDirection;   /* CC('L', 'T'): L-R/T-B		*/ 
				    /* CC('R', 'T'): R-L/T-B		*/ 
				    /* CC('L', 'B'): L-R/B-T		*/ 
				    /* CC('R', 'B'): R-L/B-T		*/ 
    int 	offsetCorrection[64+1]; /* mV * 10			*/ 
    int 	frameWidth; 
    int 	frameHeight; 
    int 	expGainMode;	    /* 0: raw, 1: lin1, 2: lin2 	*/ 
    int 	clrGainMode;	    /* 0: raw, 1: lin1			*/ 
    int 	analogOffset;	    /* mV				*/ 
    double	colorGain[4]; 
    double	gain; 
    double	exposure;	    /* msec				*/ 
    double	framePeriod;	    /* msec				*/ 
    int 	aoiFramePeriodMin; 
    int 	strobeMode;	    /* 0:  disabled			*/ 
				    /* '1': One Line			*/ 
				    /* 'e': exposure			*/ 
    int 	shA;		    /* see chip specs			*/ 
    int 	shB;		    /* see chip specs			*/ 
    int 	sofDelay;	    /* see chip specs			*/ 
    int 	frameClampHeight;   /* internal use			*/ 
    int 	frameClampTop;	    /* internal use			*/ 
    int 	frameClamp;	    /* 1: auto frame clamp on, 0: off	*/ 
 
    double	pixelClkFreq;	    /* in MHz. Info only which must	*/ 
				    /* be supplied			*/ 
 
    struct { 
				    /* controlled mode:   */ 
	int	mode;		    /* 's', 'c' 	  */ 
	double	framerate;	    /* Hz		  */ 
	double	maxframerate;	    /* internal use	  */ 
	int	trigger;	    /* 'n', '+', '-', 'b' */ 
	int	strobe; 	    /* 'n', 'p' 	  */ 
	int	bits;		    /* 8, 10		  */ 
	double	linepulses;	    /* internal use	  */ 
	int	minrnl; 	    /* internal use	  */ 
    } adj; 
}; 
 
typedef struct PXCam_SV1310State PXCam_SV1310State_s; 
#define PXMOS_CAMSV1310STATE	(PXMOS_DDCH+96+8) 
 
 
_cDcl(_dllpxlib,_cfunfcc, int) 
PXCam_SILICONVIDEO1310(int cmnd, int rsvd, int unitmap, int porttype, 
		       void *port, PXCam_SV1310State_s *camstatep, 
		       PXCam_SV1310State_s *camstate2p, pxvidstate_s *vidstatep); 
 
 
/* 
 * SILICON VIDEO 1281 State & Control 
 */ 
struct PXCam_SV1281State { 
    struct  pxddch  ddch; 
 
    int 	productID1;	    /* as reported			*/ 
    int 	productID2;	    /* as reported			*/ 
    int 	productID3;	    /* as reported			*/ 
    int 	blacklevel;	    /* black level, 0 thru 62		*/ 
    int 	sleep;		    /* sleep mode. 0: off, 1: on	*/ 
    int 	videomode;	    /* CC('v','i'): video mode		*/ 
				    /* CC('s','x'): controlled mode	*/ 
 
    int 	aoiLeft;	    /* capture AOI			*/ 
    int 	aoiTop; 	    /*	..				*/ 
    int 	aoiWidth;	    /*	..				*/ 
    int 	aoiHeight;	    /*	..				*/ 
 
    int 	extendHBlank;	    /* lengthen H blanking		*/ 
    int 	extendVBlank;	    /* lengthen V blanking		*/ 
				    /* (no effect on current chips)	*/ 
 
    double	gain;		    /* dB. log(1.5) thru log(39.375)	*/ 
    double	exposure;	    /* msec				*/ 
    double	frameperiod;	    /* rsvd				*/ 
    double	pixelClkFreq;	    /* in MHz. Info only which must	*/ 
				    /* be supplied			*/ 
 
    /* 
     * Chip tweaks which are almost never changed. 
     */ 
    int 	bandgap;	    /* 0: internal, 1: external. reference  */ 
    int 	clkSchmitt;	    /* Schmitt trigger. 0: off, 1: on	    */ 
    int 	autoblack;	    /* 0: internal, 1: external reference   */ 
    int 	_1stcolamp_rst_cnt; /* see chip specs			    */ 
    int 	_pre_int_rst_cnt;   /* see chip specs			    */ 
    int 	_ds_rst_cnt;	    /* see chip specs			    */ 
    int 	_row_sel_wait_cnt;  /* see chip specs			    */ 
    int 	_feed_thru_cnt;     /* see chip specs			    */ 
    int 	rsvd[8]; 
 
    struct { 
				    /* controlled mode:     */ 
	int	mode;		    /* 's', 'c' 	    */ 
	int	trigger;	    /* 'n', '+', '-', 'b'   */ 
	double	framerate;	    /* Hz		    */ 
	double	exposure;	    /* msec. not used	    */ 
 
	int	minrnl; 	    /* internal use	*/ 
	double	maxframerate;	    /* internal use	*/ 
	double	readout;	    /* internal use	*/ 
	double	linetime;	    /* internal use	*/ 
	double	pixcistep;	    /* internal use	*/ 
	double	rsvd2[4]; 
	int	rsvd1[4]; 
    } adj; 
}; 
 
typedef struct PXCam_SV1281State PXCam_SV1281State_s; 
#define PXMOS_CAMSV1281STATE	(PXMOS_DDCH+24+8+9+4+4) 
 
 
_cDcl(_dllpxlib,_cfunfcc, int) 
PXCam_SILICONVIDEO1281(int cmnd, int rsvd, int unitmap, int porttype, 
		       void *port, PXCam_SV1281State_s *camstatep, 
		       PXCam_SV1281State_s *camstate2p, pxvidstate_s *vidstatep); 
 
 
/* 
 * SILICON VIDEO 9M001 & 9T001 State & Control 
 */ 
struct PXCam_SV9M001State { 
    struct  pxddch  ddch; 
 
    int 	ID;		    /* chip ID as reported		*/ 
    int 	aoiLeft;	    /* capture AOI			*/ 
    int 	aoiTop; 	    /*	..				*/ 
    int 	aoiWidth;	    /*	..				*/ 
    int 	aoiHeight;	    /*	..				*/ 
    int 	subsample;	    /* 0x101: none  0x204: 2x4		*/ 
				    /* 0x202: 2x2   0x208: 2x8		*/ 
				    /* 0x404: 4x4   0x401: 4x1		*/ 
				    /* 0x808: 8x8   0x402: 4x2		*/ 
				    /* 0x102: 1x2   0x408: 4x8		*/ 
				    /* 0x104: 1x4   0x801: 8x1		*/ 
				    /* 0x108: 1x8   0x802: 8x2		*/ 
				    /* 0x201: 2x1   0x804: 8x4		*/ 
    int 	subbinning;	    /* 0: subsample is subsampling	*/ 
				    /* 1: subsample is binning		*/ 
				    /* SV9T001 only			*/ 
    int 	scanDirection;	    /* CC('R','T'): L-R/T-B		*/ 
				    /* CC('R','B'): L-R/B-T		*/ 
				    /* SV9M001 only			*/ 
    int 	testdata;	    /* 1: on, 0: off			*/ 
    int 	chipenable;	    /* 1: on, 0: off			*/ 
    int 	videoMode;	    /* 'c': free-run, 's': controlled	*/ 
    int 	hBlank; 	    /* lengthen H blanking		*/ 
    int 	vBlank; 	    /* lengthen V blanking		*/ 
    int 	blackLevelMode;     /* 'n': auto/ADC, 'c': auto 	*/ 
				    /* 'm': manual, 'd': disabled	*/ 
				    /* 'c' and 'd' are SV9M001 only	*/ 
    int 	strobeMode;	    /*	0: disabled, 'e': exposure,	*/ 
				    /*	'1': one line			*/ 
    int 	microExposure;	    /* 1: allow short exposure less than*/ 
				    /* 1 line, 0: don't                 */ 
				    /* SV9M001 only (SV9T001 future?)	*/ 
    int 	macroExposure;	    /* 1: allow long exposure		*/ 
				    /* 0: don't                         */ 
    int 	blackrgb[4];	    /* rsvd. 0				*/ 
    int 	blacklevel;	    /* black level: SV9T001 only	*/ 
    int 	rsvd1[7]; 
 
    uint16	lastreg[0x80];	    /* internal use			*/ 
 
    double	gainrgb[4];	    /* Gb/B/R/Gr dB			*/ 
    double	exposure;	    /* exposure period, msec		*/ 
    double	shutterDelay;	    /* rsvd				*/ 
    double	framePeriod;	    /* frame period, msec		*/ 
 
    double	pixelClkFreq;	    /* in MHz. Info only which must	*/ 
				    /* be supplied			*/ 
    double	digitalgain;	    /* digital gain: SV9T001 only	*/ 
    double	rsvd2[7]; 
 
    struct { 
				    /* controlled mode:     */ 
	int	mode;		    /* 's', 'c' 	    */ 
	int	trigger;	    /* 'n', '+', '-', 'b'   */ 
	double	framerate;	    /* Hz		    */ 
	double	exposure;	    /* msec. not used	    */ 
	double	maxframerate; 
 
	int	bits;		    /* 8, 10		    */ 
 
	int	rsvd1[4]; 
	double	rsvd2[4]; 
    } adj; 
}; 
 
typedef struct PXCam_SV9M001State PXCam_SV9M001State_s; 
#define PXMOS_CAMSV9M001STATE	 (PXMOS_DDCH+21+8+0x80+8+8+6+4+4) 
 
_cDcl(_dllpxlib,_cfunfcc, int) 
PXCam_SILICONVIDEO9M001(int cmnd, int rsvd, int unitmap, int porttype, 
		       void *port, PXCam_SV9M001State_s *camstatep, 
		       PXCam_SV9M001State_s *camstate2p, pxvidstate_s *vidstatep); 
 
#ifdef  __cplusplus 
} 
#endif 
 
#include "cext_hpe.h"      
#endif				/* !defined(__EPIX_PXLIBCAM_DEFINED) */ 
