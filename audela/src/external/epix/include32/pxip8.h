/* 
 * 
 *	pxip8.h 	External	28-Sep-1996 
 * 
 *	Copyright (C)  1988-1996 EPIX, Inc.  All rights reserved. 
 * 
 *	DVI IP & DVI Misc: Old name, old function prototypes 
 * 
 */ 
 
#if !defined(__EPIX_PXIP8_DEFINED) 
#define __EPIX_PXIP8_DEFINED 
 
#include    "pxipl.h" 
 
/* 
 * pxi8ffto.c 
 * Old style calls 
 */ 
_cDcl(_dllpxipl,_cfunfcc,ulong) pxip8_fftsize_old(struct pximage *ip); 
_cDcl(_dllpxipl,_cfunfcc,int)	pxip8_fft_old(struct pximage *ip,ulong imadrs); 
_cDcl(_dllpxipl,_cfunfcc,int)	pxip8_ffti_old(struct pximage *ip,ulong imadrs,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int)	pxip8_fftlogmag_old(struct pximage *ip,ulong imadrs); 
_cDcl(_dllpxipl,_cfunfcc,int)	pxip8_fftlmagscale_old(struct pximage *ip,ulong imadrs); 
_cDcl(_dllpxipl,_cfunfcc,int)	pxip8_fftfilterz_old(struct pximage *ip,ulong imadrs,int mode,double arg); 
 
/* 
 * pxi8drxo.c 
 * Old style calls 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawline_old(struct pximage *ip,struct pxy *sxyp,struct pxy *exyp, 
			int dotspace,int mode,uint value,uchar *vbuffer); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawbox_old(struct pximage *ip,struct pxywindow *wp, 
			int dotspace,int mode,uint value,uchar *vbuffer); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawarrow_old(struct pximage *ip,struct pxy *xyp,double length, 
			double angle,double aspect,int hform,double hlength, 
			double hangle,int tform,double tlength,double tangle, 
			int dotspace,int mode,uint value,uchar *pixbuf); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawellipse_old(struct pximage *ip,struct pxy *xyp,int xr,int yr, 
			double theta,int dotspace,int mode,uint value,uchar *pixbuf); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawbezier_old(struct pximage *ip,int m,struct pxy *xyp, 
			int dotspace,int mode,uint value,uchar *pixbuf); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_drawboundary_old(struct pximregion *rp,int rsvd,int dotspace, 
			int mode,uint value, uchar *pixbuf); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_drawpath_old(struct pximregion *rp,uint skipN,uint drawN, 
			struct pxy *fxy,struct pxy *exy, 
			int dotspace,int mode,uint value,uchar *pixbuf); 
 
/* 
 * pxio8tig.c 
 * Old style calls 
 */ 
#define PXIP8TIFF_NONE	     1	    /* TIFF_Compression tag		    */ 
#define PXIP8TIFF_PACKBITS   32773U /* TIFF_Compression tag		    */ 
#define PXIP8TIFF_EEPIXLSLS  32885U /* TIFF_Compression tag: EPIX lossless  */ 
struct	pxio8tiffparm 
{ 
    int     xdim;		/* width in tiff terminology		*/ 
    int     ydim;		/* height in tiff terminology		*/ 
    int     bits;		/* number of bits per pixie		*/ 
    int     palette;		/* !0: there is a color palette 	*/ 
    int     compress;		/* PXIP8TIFF_NONE, PACKBITS, etc	*/ 
    char    *datetime;		/* optional: date/time, tiff format	*/ 
    char    *software;		/* optional: name of creating pgm	*/ 
    char    *description;	/* optional: description of image	*/ 
    char    *copyright; 	/* optional: copyright notice		*/ 
    long    subfiles;		/* number of images in file		*/ 
}; 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_tiffwrite_old(pxabortfunc_t**,struct pximage *ip,char *name,long subfile, 
				   uchar *lut,struct pxio8tiffparm *parmp,ulong maxstripsize); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_tiffread_old(pxabortfunc_t**,struct pximage *ip,char *name,long subfile,uchar *lut); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_tiffparm_old(char *name,long subfile,struct pxio8tiffparm *parmp); 
_cDcl(_dllpxipl,_cfunfcc,void) pxio8_tiffparmr_old(struct pxio8tiffparm *parmp); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_tiffreadrsz_old(pxabortfunc_t**,struct pximage *ip,char *name,long subfile, 
				    uchar *lut, int mode); 
 
/* 
 * Following imaging board dependent functions need ... 
 */ 
#if defined(C_MSC16)|defined(C_BOR16)|defined(C_WAT16)|defined(C_MSC32) 
 
#include "pxdlib.h"           
#include "pxdipl.h"           
 
/* 
 * pxi8bavo.c 
 * Old style calls 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_averagebufs_old(pxabortfunc_t**,struct pximage *pximp,pxbuffer_t buf,pxbuffer_t bufe); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_integratebufs_old(pxabortfunc_t**,struct pximage *pximp,pxbuffer_t buf,pxbuffer_t bufe, 
				    ulong divisor,int mode); 
 
#endif 
 
 
#endif			 /* defined( __EPIX_PXIP8_DEFINED) */ 
