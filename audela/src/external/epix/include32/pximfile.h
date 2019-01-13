/* 
 * 
 *	pximfile.h	External	02-Mar-2005 
 * 
 *	Copyright (C)  1996-2002  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI Image Access: Image File Accesses 
 * 
 */ 
 
 
 
#if !defined(__EPIX_PXIMFILE_DEFINED) 
#define __EPIX_PXIMFILE_DEFINED 
#include "cext_hps.h"      
 
#ifdef  __cplusplus 
extern "C" { 
#endif 
 
#if !defined(__EPIX_PXABORTFUNC_DEFINED) 
typedef int (_cfunfcc pxabortfunc_t)(void*,int,int); 
#define __EPIX_PXABORTFUNC_DEFINED 
#endif 
 
/* 
 * Information about image files, 
 * parameters which affect creating image files. 
 */ 
struct pximfileinfo 
{ 
    /* 
     * struct  pxddch  ddch;	    /* future addition? 		    * 
     */ 
 
    /* 
     * Common Info. 
     */ 			    /* cold: only reported as file info     */ 
    pxywindow_s     imdim;	    /* as in a pximage			    */ 
  /*pxyzwindow_s    imdim3;	       as in a pximage3 		    */ 
    pximagedata_s   d;		    /* as in a pximage			    */ 
    pximagehints_s  h;		    /* as in a pximage			    */ 
 
    /* 
     * Format specific info. 
     * Since string info may be malloc'ed, they are 
     * in a seperate union for safety, and should be union'ed 
     * only with other malloc'ed strings. 
     */ 
    char    type[4];		    /* "tif", "bmp", "avi", "jpg", "fts"    */ 
 
    union { 
 
      /* 
       * Info for TIFF files 
       */ 
      struct { 
				    /* hot: values used on file create	    */ 
	int	xresolution[2];     /* x resolution ratio. 0/0 if unused    */ 
	int	yresolution[2];     /* y resolution ratio  0/0 if unused    */ 
	int	resolutionunit;     /* as per defines, iff xres, yres used  */ 
	int	compression;	    /* PXIMTIFF_Compress_NONE, PACKBITS, etc*/ 
	ulong	maxstripsize;	    /* advisory. 0: default		    */ 
				    /* estimated value reported as fileinfo */ 
 
				    /* cold: only reported as file info     */ 
	int	bitspersample[4];   /* as per tiff spec 		    */ 
	int	sampleformat[4];    /* as per tiff spec 		    */ 
	int	palette;	    /* !0: there is a color palette	    */ 
	long	subfiles;	    /* number of images in file 	    */ 
	/*long	subfiles;	     * of which this is # ..		    */ 
      } tiff; 
 
      /* 
       * Info for BMP and AVI files 
       */ 
      struct { 
				    /* hot: values used on file create	    */ 
	uint	framecnt;	    /* frame period is ...		    */ 
	uint	framesecs;	    /* ... framesecs/framecnt (AVI only)    */ 
 
				    /* cold: only reported as file info     */ 
	int	biPlanes;	    /* as per bmp spec			    */ 
	int	biBitCount;	    /* as per bmp spec			    */ 
	int	palette;	    /* !0: pixels are indexes into lut	    */ 
				    /*	1: lut is not grey level	    */ 
				    /*	2: lut is grey level		    */ 
				    /*	0: pixels are RGB data		    */ 
	ulong	compress;	    /*	0: uncompressed 		    */ 
				    /* !0: compressed			    */ 
 
				    /* hot: values used on file create	    */ 
	long	biXPelsPerMeter;    /* x resolution			    */ 
	long	biYPelsPerMeter;    /* y resolution			    */ 
 
				    /* cold: only reported as file info     */ 
	ulong	aviTotalFrames; 
      } bmp; 
 
      /* 
       * Info for JPEG files 
       */ 
      struct { 
				    /* hot: values used on file create		*/ 
	int	quality;	    /* quality, percentage*10. Reported only if */ 
				    /* also written as a comment		*/ 
	uint16	dotsPerHUnit;	    /* x resolution				*/ 
	uint16	dotsPerVUnit;	    /* y resolution				*/ 
	uint16	dotsUnits;	    /* resolution: 0: ratio, 1: inch, 2: cm	*/ 
      } jpeg; 
 
      /* 
       * Info for FITS files 
       */ 
      struct { 
				    /* cold: only reported as file info     */ 
	double	datamin, datamax;   /* no default, NaN if not specified     */ 
	double	bzero, bscale; 
	uint16	naxis[10];	    /* # of dimensions and dimensions	    */ 
	short	bitpix; 
 
				    /* hot: values used on file create		*/ 
	uchar	colorpacked;	    /* color stored packed, else planar 	*/ 
      } fits; 
    } fi; 
 
    /* 
     * Strings 
     */ 
    union { 
 
      struct {			    /* hot: values used on file create	    */ 
	char	*datetime;	    /* date/time, tiff format, or NULL	    */ 
	char	*software;	    /* name of creating pgm, or NULL	    */ 
	char	*description;	    /* description of image, or NULL	    */ 
	char	*copyright;	    /* copyright notice, or NULL	    */ 
      } tiff; 
 
      struct {			    /* hot: values used on file create	    */ 
	char	*comments[3];	    /* comments 			    */ 
      } jpeg; 
 
      struct {			    /* hot: values used on file create	    */ 
	char	*date;		    /* .. or current used if NULL	    */ 
	char	*observer;	    /* .. or NULL			    */ 
	char	*object;	    /* .. or NULL			    */ 
      /*char	*origin;	       .. or NULL			    */ 
      /*char	*date-obs;	       .. or NULL			    */ 
	char	*comment;	    /* .. multiline - with \n's, or NULL    */ 
      /*char	*history;	       .. multiline - with \n's, or NULL    */ 
      } fits;			    /* all w/out enclosing single quotes    */ 
 
    } fs; 
}; 
typedef struct pximfileinfo pximfileinfo_s; 
 
 
/* 
 * TIFF constants 
 * Presence of a constant, such as a compression mode, 
 * doesn't imply support of said mode. 
 * Often identical to TIFF standard constants, but not always. 
 */ 
#define PXIMTIFF_Compress_None	    1	    /* TIFF_Compression tag */ 
#define PXIMTIFF_Compress_G31D	    2	    /* TIFF_Compression tag */ 
#define PXIMTIFF_Compress_CCITTG3   3	    /* TIFF_Compression tag */ 
#define PXIMTIFF_Compress_CCITTG4   4	    /* TIFF_Compression tag */ 
#define PXIMTIFF_Compress_LZW	    5	    /* TIFF_Compression tag */ 
#define PXIMTIFF_Compress_LZW_HP    (5|0x200)/* TIFF_Compression & TIFF_Predictor tag */ 
#define PXIMTIFF_Compress_JPEG	    6	    /* TIFF_Compression tag */ 
#define PXIMTIFF_Compress_PackBits  32773U  /* TIFF_Compression tag */ 
 
#define PXIMTIFF_Compress_EPIX_LsLs 32885U  /* TIFF_Compression tag: EPIX lossless  */ 
 
#define PXIMTIFF_ResUnit_ratio	    1	    /* resolution: aspect ratio */ 
#define PXIMTIFF_ResUnit_in	    2	    /* resolution: inches	*/ 
#define PXIMTIFF_ResUnit_cm	    3	    /* resolution: centimeters	*/ 
 
/* 
 * pximfib.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_file(pximage_s*tp,void **handlep,const char *filename,const char *filemode, 
			const pxy_s *dimp,int pixtype,int bitsused, 
			int pixies,int pixelhint,uint buffersize); 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_filedone(pximage_s*tp,void **handlep); 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_filebufio(pximage_s*tp,void* bufio_statep, 
			const pxy_s *dimp, const pximagedata_s *datap); 
 
 
#ifdef  __cplusplus 
} 
#endif 
 
#include "cext_hpe.h"      
#endif				/* !defined(__EPIX_PXIMFILE_DEFINED) */ 
