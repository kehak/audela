/* 
 * 
 *	pxipl.h 	External	27-Feb-2004 
 * 
 *	Copyright (C)  1988-2004  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI Image Processing & Analysis: All inclusive 
 * 
 *	Functions with _ names are (generally) part of the documented 
 *	library/driver interface; other functions (if any) are (generally) 
 *	for internal support. 
 * 
 */ 
 
 
#if !defined(__EPIX_PXIPL_DEFINED) 
#define __EPIX_PXIPL_DEFINED 
 
#ifdef  __cplusplus 
extern "C" { 
#endif 
 
 
#include "cext.h"      
#include "pximage.h"            
#include "pximages.h"            
#include "pximfile.h"             
#include "pxerrno.h"            
 
#include "cext_hps.h"      
 
/* 
 * Library version IDs 
 */ 
#define XCIPL_IDN	"PIXCI(R) Image Processing & Analysis Library" 
#define XCIPL_IDV	XCLIB_IDV 
#define XCIPL_IDR	"[02.02.20]" 
#define XCIPL_IDNVR	XCIPL_IDN " " XCIPL_IDV " " XCIPL_IDR 
 
 
/* 
 * For image measurement mappings. 
 */ 
struct pxyf 
{ 
    float   xf; 	/* i.e. x */ 
    float   yf; 	/* i.e. y */ 
}; 
typedef struct pxyf pxyf_s; 
typedef struct pxyf pxyfpoint_s; 
struct pxyd 
{ 
    double  xd; 	/* i.e. x */ 
    double  yd; 	/* i.e. y */ 
}; 
typedef struct pxyd pxyd_s; 
typedef struct pxyd pxydpoint_s; 
struct pxydwindow 
{ 
    struct  pxyd    nw;     /* north west corner inclusive	    */ 
    struct  pxyd    se;     /* south east corner, usually exclusive */ 
}; 
typedef struct pxydwindow pxydwindow_s; 
 
/* 
 */ 
#if !defined(__EPIX_PXABORTFUNC_DEFINED) 
typedef int (_cfunfcc pxabortfunc_t)(void*,int,int); 
#define __EPIX_PXABORTFUNC_DEFINED 
#endif 
 
/* 
 * pxi8spo.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixmap   (pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uchar *map); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixmaps  (pxabortfunc_t**,pximage_s *sip,pximage_s *dip,ushort *map); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixmapl  (pxabortfunc_t**,pximage_s *sip,pximage_s *dip,ulong *map); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixmaplut(pxabortfunc_t**,pximage_s *lutip,pximage_s *sip,pximage_s *dip); 
 
/* 
 * pxi8spox.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixshr(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint cnt); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixshl(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint cnt); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixand(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint mask); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixor(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint mask); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixxor(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint mask); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixneg(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixadd(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int constant,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixscale(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint numerator,uint denominator); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixthreshold(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uint lowbound,uint highbound,uint newvalue); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixthreshold2(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uint lowbound,uint highbound,uint newvalue, uint altvalue); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixcontrast(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint lowbound,uint highbound); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixcontrastpivot(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint pivot2, double coef); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixthreshold3(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uint lowbound[], uint highbound[], uint invalue[], uint outvalue[], int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixgamma(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,double gamma); 
_cDcl(_dllpxipl,_cfunfcc,int) pxipf_pixadd(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,double constant,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxipf_pixscale(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,double constant,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixmsb(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixiemin(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixiemax(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixieave(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
 
 
/* 
 * pxi8spoc.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixcontrastperc(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uint lowperc,uint highperc,uint *lowboundp,uint *highboundp); 
 
/* 
 * pxi8set.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixset(pxabortfunc_t**,pximage_s *dip,ulong value); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixset3(pxabortfunc_t**,pximage_s *dip,uint values[]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxipf_pixset3(pxabortfunc_t**,pximage_s *dip,double values[]); 
 
/* 
 * pxi8sim.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_halftsum(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_halftonedot(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int dotsize); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_dither(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint ditherbits); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_dithernormal(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,double variance); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_noiseadd(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int type,ulong seed,double mean, double variance,double parm0,double parm1); 
 
/* 
 * pxi8copy.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copy(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyexchange(pxabortfunc_t**,pximage_s *ip1,pximage_s *ip2); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyreverse(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyshift(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int xshift,int yshift); 
 
/* 
 * pxi8pair.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairadd(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairsub(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairave(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairxor(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairand(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairor(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairinsdiff(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairinsert(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairprod(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip,int mode,int coef[]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairratio(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip,int mode,int coef[]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairmin(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairmax(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairoverlay(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *dip,int mode,uint key[]); 
 
/* 
 * pxi8trip.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pairblend(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,pximage_s *s3p,pximage_s *dip,int mode); 
 
/* 
 * pxi8cmat.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_contrastmatch(pxabortfunc_t**,pximage_s *ip,pximage_s *jp,pximage_s *op); 
 
/* 
 * pxi8drc.c 
 */ 
#if defined(OS_DOS)  | defined(OS_DOS4GW) \ 
   |defined(OS_WIN3X)|defined(OS_WIN3X_DLL) \ 
   |defined(OS_WIN95)|defined(OS_WIN95_DLL) \ 
   |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawchars(pxabortfunc_t**,pximage_s *ip,pxy_s*xyp,char *cp, 
			int cn,int width,int height,int hlead,int vlead, 
			int groundtype,uint background[],uint foreground[],int antialias); 
#endif 
 
/* 
 * pxi8drc3.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawchars3(pxabortfunc_t **abortp,pximage_s *ip,pxy_s*xyp, 
			double angle,char cp[],int cn,int width,int height,int hlead, int vlead, 
			int mode,uint values[],uint backvalues[],pximage_s *bufip,long *cntp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawchars4(pxabortfunc_t **abortp,pximage_s *ip,pxy_s*xyp,double angle, 
			char *charbuf,int width,int height,int baseline,int hlead,int vlead, 
			int mode,uint values[],uint backvalues[],pximage_s *bufip,long *cntp); 
 
/* 
 * pxi8drc4.c 
 */ 
#if  defined(OS_WIN3X)|defined(OS_WIN3X_DLL) \ 
    |defined(OS_WIN95)|defined(OS_WIN95_DLL) \ 
    |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
#include &lt;windows.h> 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawchars5(pxabortfunc_t**,pximage_s *ip,pxy_s *xyp, 
		double angle,HFONT hFont,char cp[],int cn,int awidth,int aheight, 
		int hlead,int vlead,int mode,uint values[],uint backvalues[],pximage_s *bufip,long *cntp); 
#endif 
 
 
/* 
 * pxi8pat.c 
 * Common pattern parameters 
 */ 
struct	pxip8pat 
{ 
    int     xfreq;	/* x frequency					  */ 
    int     yfreq;	/* y frequency					  */ 
    char    xhalf;	/* 0: x is full wave, 1: x is half wave 	  */ 
    char    yhalf;	/* 0: y is full wave, 1: y is half wave 	  */ 
    char    xinvert;	/* 0: x is high/low/high, 1: low/high/low	  */ 
    char    yinvert;	/* 0: y is high/low/high, 1: low/high/low	  */ 
    int     incfc;	/* 1: normal, else 'wallpaper' randomizing factor */ 
    int     mulfc;	/* 1: normal, else 'wallpaper' randomizing factor */ 
    float   x2width;	/* gaussian width  at 50% intensity		  */ 
    float   y2width;	/* gaussian height at 50% intensity		  */ 
}; 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_patterncos(pxabortfunc_t**,pximage_s *ip,struct pxip8pat *p); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_patterngaussian(pxabortfunc_t**,pximage_s *ip,struct pxip8pat *p); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_patternfiducial(pxabortfunc_t**,pximage_s *ip,struct pxip8pat *pp, 
			uint background[],uint foreground[],int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_patterns(pxabortfunc_t**,pximage_s *ip,struct pxip8pat *p,int type); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_patternalign(pxabortfunc_t**,pximage_s *ip,int type); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_testpattern(pxabortfunc_t**,pximage_s *ip,int type,int amplitude); 
 
/* 
 * pxi8squz.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_spatialquantize(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			int xsiz,int ysiz,int shrink); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_normalizeintensity(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			int xgran,int ygran,int mode); 
 
 
/* 
 * pxi(r)8mass.c 
 */ 
#include "pximregn.h" 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_masscenterbin(pxabortfunc_t**,pximregion_s *rp,ulong *area,ulong *xsum, 
			ulong *ysum,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_masscenter(pxabortfunc_t**,pximregion_s *rp,double *mass,double *xcenter, 
			double *ycenter); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_masscenterbin(pxabortfunc_t**,pximage_s *ip,ulong *area,ulong *xsum, 
			ulong *ysum); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_masscenter(pxabortfunc_t**,pximage_s *ip,double *mass,double *xcenter, 
			double *ycenter); 
 
 
/* 
 * pxi8mom.c 
 */ 
#include "pxi8mmnt.h" 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_moments(pxabortfunc_t**,pximage_s *ip,int aoiorigin, 
			pxip8moments_s *momp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_momentsf(pxabortfunc_t**,pximage_s *ip,int aoiorigin, 
			double (_cfunfcc *mapzifunc)(void *,pxyd_s *,double), 
			void (_cfunfcc *mapxyhvfunc)(void *,pxyd_s *,pxyd_s *), 
			void *mapzirefp,void* mapxyhvrefp,pxip8moments_s *momp); 
 
/* 
 * pxr8mom.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_moments(pxabortfunc_t**,pximregion_s *rp,int rsvd, 
			pxip8moments_s *momp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_momentsf(pxabortfunc_t**,pximregion_s *rp,int rsvd, 
			double (_cfunfcc *mapzifunc)(void *,pxyd_s *,double), 
			void (_cfunfcc *mapxyhvfunc)(void *,pxyd_s *,pxyd_s *), 
			void *mapzirefp,void* mapxyhvrefp,pxip8moments_s *momp); 
 
/* 
 * pxi8edge.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3kirsch(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_2x2roberts(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3sobel(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3sobela(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
 
/* 
 * pxi8edgt.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3ksrthin(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
 
/* 
 * pxi8medn.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3median(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
 
/* 
 * pxi8medw.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3medianw(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
 
/* 
 * pxi8medb.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3binmedian(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
 
/* 
 * pxi8medr.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3ranklow(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3rankhigh(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
 
/* 
 * pxi8life.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3life(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
 
/* 
 * pxi8lpas.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3lowpass(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint weight); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3lowpassf(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3sharpenl(pxabortfunc_t**,pximage_s *sip,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3lowpassmear(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,uint threshold); 
 
/* 
 * pxi8nthr.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_NxNdynthreshold(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int N,int low,int high,uint npv); 
 
/* 
 * pxi8coni.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_NxNcontrastinvert(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int N); 
 
/* 
 * pxi8conv.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_NxNconvolve(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int N, 
			int *coef,int offset,int divisor,int mode); 
 
/* 
 * pxi8conf.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_NxNconvolvef(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int N, 
			float *coef,double add,double div,int mode); 
 
/* 
 * pxi8hist.c 
 */ 
#include "pxi8hist.h" 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histab(pxabortfunc_t**,pximage_s *ip,pxip8histab_s *hp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histab2(pxabortfunc_t**,pximage_s *ip,ulong *count,uint ncount); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histabpair(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p,ulong *count,uint ncount,int mode); 
 
/* 
 * pxi8hiss.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histstat(pxip8histab_s *hp,pxip8histstat_s *sp, 
			pxip8histperc_s *pp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histstatf(pxip8histab_s *hp, 
			double (_cfunfcc *mapzifunc)(void *,pxyd_s *,double), 
			void *mapfuncrefp,pxip8histstat_s *sp, 
			pxip8histperc_s *pp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histstat2(pximage_s *ip,ulong *count,uint ncount, 
			pxip8histstat_s *sp,pxip8histperc_s *pp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histstat2f(pximage_s *ip,ulong *count,uint ncount, 
			double (_cfunfcc *mapzifunc)(void *,pxyd_s *,double), 
			void *mapfuncrefp,pxip8histstat_s *sp, 
			pxip8histperc_s *pp); 
 
/* 
 * pxi8drl.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawline(pxabortfunc_t**,pximage_s *ip,pxy_s*sxyp,pxy_s*exyp, 
			int dotspace,int thickness,int mode,uint values[],pximage_s *pixibuf,long *cntp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawbox(pxabortfunc_t**,pximage_s *ip,pxywindow_s *wp, 
			int dotspace,int thickness,int mode,uint values[],pximage_s *pixibuf,long *cntp); 
 
/* 
 * pxi8drli.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawcoord(pxabortfunc_t**,pximage_s *ip,pximage_s *cp, 
			int dotspace,int thickness,int mode,uint values[],pximage_s *pixibuf,long skip,long cnt,int dir); 
 
/* 
 * pxi8dra.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawarrow(pxabortfunc_t**,pximage_s *ip,pxy_s*xyp,double length, 
			double angle,double aspect,int hform,double hlength, 
			double hangle,int tform,double tlength,double tangle, 
			int dotspace,int thickness,int mode,uint values[], 
			pximage_s *pixibuf,long *cntp); 
 
/* 
 * pxi8dre.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawellipse(pxabortfunc_t**,pximage_s *ip,pxy_s*xyp,int xr,int yr, 
			double theta,int dotspace,int thickness,int mode,uint values[], 
			pximage_s *pixibuf,long *cntp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawellipsesect(pxabortfunc_t**,pximage_s *ip,pxy_s*xyp,int xr,int yr, 
			double theta,double starta,double enda,int dotspace,int thickness,int mode,uint values[], 
			pximage_s *pixibuf,long *cntp); 
 
/* 
 * pxi8terp.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyinterpolate(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			double xsupport,double ysupport,int mode); 
 
/* 
 * pxi8bili.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyinterpbilinear(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			int mode, int orient); 
 
/* 
 * pxi8morp.c 
 * 
 * Morphological structuring element (char array) markers. 
 * Use of both MORPFORE & MORPBACK in single char is undefined. 
 * If neither MORPFORE, MORPBACK is used, the element is ignored. 
 * Normally, a unique MORPORIG is present. If no MORPORIG, then 
 * the center is the origin. 
 */ 
#define PXIP8MORPFORE	0x80	/* foreground pixel element */ 
#define PXIP8MORPBACK	0x40	/* background pixel element */ 
#define PXIP8MORPORIG	0x20	/* origin pixel element     */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_morperode(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uchar *msearray,int msearraydim,int rotation, 
			int resultmap,ulong *pixcountp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_morpdilate(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uchar *msearray,int msearraydim,int rotation, 
			int resultmap,ulong *pixcountp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_morpopen(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uchar *msearray,int msearraydim,int rotation, 
			int resultmap,ulong *pixcountp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_morpclose(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uchar *msearray,int msearraydim,int rotation, 
			int resultmap,ulong *pixcountp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_morphitmiss(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uchar *msearray,int msearraydim,int rotation, 
			int resultmap,ulong *pixcountp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_binmaxisthin(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			void *unused0,int unused1,int unused2, 
			int resultmap,ulong *pixcountp); 
 
/* 
 * pxi8lace.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ilacelinetofield(pxabortfunc_t**,pximage_s *ip,pximage_s *op); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ilacefieldtoline(pxabortfunc_t**,pximage_s *ip,pximage_s *op); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ilacepairave(pxabortfunc_t**,pximage_s *ip,pximage_s *op); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ilacemodsingular(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			int mode,int threshold,int midwt,int endwt); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ilacepairswap(pxabortfunc_t**,pximage_s *ip,pximage_s *op,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ilacepairdup(pxabortfunc_t**,pximage_s *ip,pximage_s *op,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ilacelineshift(pxabortfunc_t**,pximage_s *ip,pximage_s *op,int dir, int mode); 
 
/* 
 * pxi8geot.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_geotranrotate(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			double angle,double saspect,double daspect, 
			pxy_s*origin,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_geotranwarp(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			int nfiduc,pxy_s*sfiduc,pxy_s*dfiduc,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_geotranwarp2(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			int nfiduc,pxyd_s*sfiduc,pxyd_s*dfiduc,int mode,int order,int rsvd); 
 
/* 
 * pxi8fft.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_fftsizes(pximage_s *gip,pxy_s*dimp,int *typep); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_fft(pxabortfunc_t**,pximage_s *gip,pximage_s *cip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ffti(pxabortfunc_t**,pximage_s *cip,pximage_s *gip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_fftlogmag(pxabortfunc_t**,pximage_s *cip,pximage_s *gip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_fftlmagscale(pxabortfunc_t**,pximage_s *gip,pximage_s *cip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_fftfilterz(pxabortfunc_t**,pximage_s *gip,pximage_s *cip,int mode,double arg); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_timefreqanalysis(pxabortfunc_t**,pximage3_s *si3p,pximage_s *dip,int mode); 
 
/* 
 * pxipfftd.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_fftcimage(pximage_s *tp,pximage_s *ip,pxy_s*dimp); 
 
/* 
 * pxi8dri.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawiconinit(pximage_s *imp,pxy_s*imxy,uchar *iconbit, 
		    pxy_s*icondim,pxy_s*iconorg,int iconmode, 
		    void **handlepp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawiconhit(pximage_s *imp,void *handlep, 
		    int mode,uint values[],pximage_s *pixibuf); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawiconhitw(pximage_s *imp,void *handlep, 
		    int wait,int mode,pximage_s *pixibuf); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawiconfree(pximage_s *imp,void **handlepp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawicon(pximage_s *imp,pxy_s*imxy,uchar *iconbit, 
		    pxy_s*icondim,pxy_s*iconorg,int iconmode, 
		    int mode,uint values[],pximage_s *pixibuf,long*cntp); 
 
/* 
 * pxi8sig.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_signature(pxabortfunc_t**,pximage_s *ip,ushort *sigp); 
 
/* 
 * pxi8drp.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_paintregion(pxabortfunc_t**,pximregion_s *rp,int pattern,int *patparm, 
			int groundtype,uint background[],uint foreground[],int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_drawboundary(pxabortfunc_t**,pximregion_s *rp,int rsvd,int dotspace,int thickness, 
			int mode,uint values[],pximage_s *pixibuf,long*cntp); 
 
/* 
 * pxi8drbz.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_drawbezier(pxabortfunc_t**,pximage_s *ip,int m,pxy_s*xyp, 
			int dotspace,int thickness,int mode,uint values[],pximage_s *pixibuf,long*cntp); 
 
/* 
 * pxi8skew.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyskewlr(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			int mode,int skewtop,int skewbot); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyskewud(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			int mode,int skewleft,int skewright); 
 
/* 
 * pxrpregn.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_xlatetoscanlist(pxabortfunc_t**,pximregion_s *rp,pximregion_s **npp,int mode); 
 
/* 
 * pxrpreg0.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_xlaterecttopoly(pximregion_s *rp); 
 
/* 
 * pxrpreg3.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_regionbounds(pximregion_s *rp,pxywindow_s *wp,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_regionarea(pximregion_s *rp,ulong *areap,int mode); 
 
/* 
 * pxrpreg2.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_xlatetopath(pxabortfunc_t**,pximregion_s *rp,pximregion_s **npp,int mode); 
 
/* 
 * pxrpreg4.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,void) pxirp_regionfree(pximregion_s **npp); 
 
/* 
 * pxrpreg6.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int)  pxirp_regionexport(pxabortfunc_t**,pximregion_s *srp,char *pathname,char *filemode); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxirp_regionimport(pxabortfunc_t**,pximregion_s **srpp,char *pathname,char *filemode); 
 
/* 
 * pxr8reg0.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_connectregion(pxabortfunc_t**,pximage_s *mip,pxy_s*xyp, 
			uchar *testmap,int testbit,pximregion_s **npp,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_connectregionv(pxabortfunc_t**,pximage_s *mip,pxy_s*xyp, 
			int cond,uint value,pximregion_s **npp,int mode); 
/* 
 * pxr8reg1.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_followregionv(pxabortfunc_t**,pximage_s *ip,pxy_s*,pxy_s*xyp, 
			int cond,uint value,int mode,pximregion_s **npp); 
 
/* 
 * pxr8reg2.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_connectregion2v(pxabortfunc_t**,pximage_s *sip,pxy_s*xyp, 
			int cond,uint value,int clear,int mode,pximregion_s **npp); 
#define PXIP8FORECR2	7   /* foreground value required by above function */ 
 
/* 
 * pxrpregd.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximpxirprectacc(pximage_s *tp,pximregion_s *rp,uint pad); 
 
/* 
 * pxrprege.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximpxirprectacc2(pximage_s *tp,pximregion_s *rp, int mode); 
 
/* 
 * pxr8hist.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_histab(pxabortfunc_t**,pximregion_s *rp,pxip8histab_s *hp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_histab2(pxabortfunc_t**,pximregion_s *rp,ulong *count,uint ncount); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_histabpair(pxabortfunc_t**,pximregion_s *r1p,pximregion_s *r2p,ulong *count,uint ncount,int mode); 
 
/* 
 * pxr8spo.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixmap(pxabortfunc_t**,pximregion_s *srp,pximregion_s *drp,uchar *map); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixmaps(pxabortfunc_t**,pximregion_s *srp,pximregion_s *drp,ushort *map); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixmapl(pxabortfunc_t**,pximregion_s *srp,pximregion_s *drp,ulong *map); 
 
/* 
 * pxi(r)8spox.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixshr(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,uint cnt); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixshl(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,uint cnt); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixand(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,uint mask); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixor(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,uint mask); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixxor(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,uint mask); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixneg(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixadd(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,int constant,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixscale(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip, 
			uint numerator,uint denominator); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixthreshold(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip, 
			uint lowbound,uint highbound,uint newvalue); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixthreshold2(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip, 
			uint lowbound,uint highbound,uint newvalue,uint altvalue); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixcontrast(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip, 
			uint lowbound,uint highbound); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixcontrastpivot(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip, 
			uint pivot2, double coef); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixthreshold3(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip, 
			uint lowbound[], uint highbound[], uint invalue[], uint outvalue[], int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixgamma(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,double gamma); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirpf_pixadd(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,double constant,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirpf_pixscale(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip,double constant,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixmsb(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixiemin(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixiemax(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixieave(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip); 
 
 
/* 
 * pxr8spoc.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixcontrastperc(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip, 
			uint lowperc,uint highperc,uint *lowboundp, 
			uint *highboundp); 
 
/* 
 * pxr8set.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixset(pxabortfunc_t**,pximregion_s *dip,ulong value); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixset3(pxabortfunc_t**,pximregion_s *dip,uint values[]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirpf_pixset3(pxabortfunc_t**,pximregion_s *dip,double values[]); 
 
/* 
 * pxr8copy.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_copy(pxabortfunc_t**,pximregion_s *sip,pximregion_s *dip); 
 
 
/* 
 * pxi8drw.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_drawpath(pxabortfunc_t**,pximregion_s *rp,uint skipN,uint drawN, 
			pxy_s*fxy,pxy_s*exy,int dotspace,int thickness,int mode, 
			uint values[],pximage_s *pixibuf,long*cntp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_pathcreate(pximregion_s **rpp,pxy_s*start); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_pathextend(pximregion_s **rpp,pxy_s*exy); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_pathextend1(pximregion_s **rpp,pxy_s*exy); 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_pathcompress(pximregion_s *rp,pximregion_s **rpp); 
 
/* 
 * pxi8find.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_findpixel(pxabortfunc_t**,pximage_s *ip,pxy_s*xyp, 
			uchar *testmap,int testbit,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_findpixelv(pxabortfunc_t**,pximage_s *ip,pxy_s*xyp, 
			int cond,uint value,int mode); 
 
/* 
 * pxi8hseq.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_histfit(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
			pxip8histab_s *hp,int mode); 
 
/* 
 * pxio8bin.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_binread(pxabortfunc_t**,pximage_s *ip,char *pathname, ulong skip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_binwrite(pxabortfunc_t**,pximage_s *ip,char *pathname); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_bin1read(pxabortfunc_t**,pximage_s *ip,char *pathname,int mode, ulong skip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_bin1write(pxabortfunc_t**,pximage_s *ip,char *pathname,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_binreadseq(pxabortfunc_t**,pximage3_s *ip,char *pathname, int mode, ulong skip1, ulong skip2); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_binwriteseq(pxabortfunc_t**,pximage3_s *ip,char *pathname, int emode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_bin1writeseq(pxabortfunc_t**,pximage3_s *ip,char *pathname,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_bin1readseq(pxabortfunc_t**,pximage3_s *ip,char *pathname,int mode, ulong skip1, ulong skip2); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_binwriteseqinit(pxabortfunc_t**,void **handlep,char *pathname,pximage_s *ip,int mode,int rsvd1,int rsvd2,long nimages); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_binwriteseqadd(pxabortfunc_t**,void **handlep,char *pathname,pximage_s *ip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_binwriteseqdone(pxabortfunc_t**,void **handlep,char *pathname); 
 
 
/* 
 * pxio8hex.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_hexread(pxabortfunc_t**,pximage_s *ip,char *pathname); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_hexwrite(pxabortfunc_t**,pximage_s *ip,char *pathname,char linedelim); 
 
 
/* 
 * pxio8inf.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int)	pxio8_fileinfo(char *pathname,pximfileinfo_s *infop,long subfile,int mode); 
_cDcl(_dllpxipl,_cfunfcc,void)	pxio8_fileinfodone(pximfileinfo_s *infop); 
 
 
/* 
 * pxio8tif.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tifwrite(pxabortfunc_t**,pximage_s*ip,pximage_s *lip, 
				    char*pathname,int bits,int lutbits,long subfile,pximfileinfo_s*parmp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tifread(pxabortfunc_t**,pximage_s*ip,pximage_s *lip, 
				    char*pathname,long subfile,pxywindow_s *windp,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tifwriteseq(pxabortfunc_t**,pximage3_s*ip,pximage_s *lip, 
				    char *pathname,int bits,int lutbits,long subfile,pximfileinfo_s*parmp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tifreadseq(pxabortfunc_t**,pximage3_s*ip,pximage_s *lip, 
				    char*pathname,long subfile,pxywindow_s *windp,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tifwriteseqinit(pxabortfunc_t**,void **handlep,char *pathname,pximage_s *ip, 
				    pximage_s *lutip,int ipbits,int lutbits,pximfileinfo_s *parmp,long nimages); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tifwriteseqadd(pxabortfunc_t**,void **handlep,char *pathname,pximage_s *ip, 
				    pximage_s *lutip,int ipbits,int lutbits,pximfileinfo_s *parmp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tifwriteseqdone(pxabortfunc_t**,void **handlep,char *pathname); 
 
/* 
 * pxio8bmp.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_bmpwrite(pxabortfunc_t**,pximage_s *ip, 
			pximage_s *lip,char *pathname,int bits,pximfileinfo_s *parmp); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_bmpread(pxabortfunc_t**,pximage_s *ip,pximage_s*lip, 
			char *pathname,pxywindow_s *windp,int mode); 
 
/* 
 * pxio8avi.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_aviwriteseq(pxabortfunc_t**,pximage3_s *ip, 
			pximage_s *lip,char *pathname,int bits,pximfileinfo_s *parmp); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_aviwriteseq2(pxabortfunc_t**,pximage3_s *ip, 
			pximage_s *lip,char *pathname,int bits, 
			uint framecnt,uint framesecs,long biXPelsPerMeter,long biYPelsPerMeter, 
			int rsvd1,int rsvd2,int rsvd3,int rsvd4); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_avireadseq(pxabortfunc_t**,pximage3_s *ip,pximage_s*lip, 
			char *pathname,long subfile,pxywindow_s *windp,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_aviwriteseqinit(pxabortfunc_t**,void **handlep,char *pathname, 
			pximage_s *ip,pximage_s *lip,int bits,pximfileinfo_s *parmp,long nimages); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_aviwriteseqadd(pxabortfunc_t**,void **handlep,char *pathname, 
			pximage_s *ip,pximage_s *lip,int bits,pximfileinfo_s *parmp); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_aviwriteseqdone(pxabortfunc_t**,void **handlep,char *pathname); 
 
/* 
 * pxio8pcx.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_pcxwrite(pxabortfunc_t**,pximage_s *ip, 
			pximage_s *lip,char *pathname,int bits,int rsvd); 
 
/* 
 * pxio8fts.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_fitswrite(pxabortfunc_t**,pximage_s *ip, 
			pximage_s *rsvd1,char *pathname,int bits,int rsvd2,long rsvd3,long rsvd4, 
			pximfileinfo_s *parmp); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxio8_fitsread(pxabortfunc_t**,pximage_s *ip,pximage_s*rsvd1, 
			char *pathname,long rsvd2,long rsvd3, pxywindow_s *windp,int mode); 
 
/* 
 * pxio8png.c 
 * 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_pngwrite(pxabortfunc_t**,pximage_s*ip,pximage_s *lip, 
				    char *pathname,int bits,int lutbits,long subfile,pximfileinfo_s*parmp); 
*/ 
 
/* 
 * pxio8tga.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_tgawrite(pxabortfunc_t**,pximage_s *ip, 
			pximage_s *lip,char *pathname,int rsvd2,int rsvd); 
 
/* 
 * pxio8jpg.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_jpegwrite(pxabortfunc_t**,pximage_s*ip, 
			void *rsvd1,char *pathname,int bits,pximfileinfo_s *parmp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_jpegread(pxabortfunc_t**abortp,pximage_s*ip, 
			void *rsvd1,char *pathname,pxywindow_s *windp,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_jpegwrite2(pxabortfunc_t**,pximage_s*ip,void *rsvd,char *pathname, 
			int bits,uint dotsUnits,uint dotsPerHUnit,uint dotsPerVUnit,int quality, 
			int rsvd1,int rsvd2,int rsvd3,int rsvd4,char *comment,char *rsvd5,char *rsvd6); 
 
/* 
 * pxio8asc.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_asciiwrite(pxabortfunc_t**,pximage_s *ip,char *pathname,char coldelim,char linedelim,int maxpixline); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_asciiread(pxabortfunc_t**,pximage_s *ip,char *pathname,char linedelim); 
 
/* 
 * pxi8repl.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyreplic(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			int xsiz,int ysiz,int mode); 
 
/* 
 * pxi8xlac.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_xlaceshuffle(pxabortfunc_t**,pximage_s *ip,pximage_s *op,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_xlaceunshuffle(pxabortfunc_t**,pximage_s *ip,pximage_s *op,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_xlacecolumntohalves(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_xlacehalvestocolumn(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
 
 
/* 
 * pxi8vitc.c 
 */ 
#include "pxi8vitc.h" 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_smptevitcdecode(pxabortfunc_t**,pximage_s *sip,ulong pixfreq, 
			int mode,struct pxip8smptevitc *vitcp); 
 
/* 
 * pxrpregf.c 
 */ 
#include "pximshap.h" 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp_regionshapef(pxabortfunc_t**,pximregion_s *rp, 
			void (_cfunfcc *mapxyhvfunc)(void *,pxyd_s *,pxyd_s *), 
			void (_cfunfcc *maphvxyfunc)(void *,pxyd_s *,pxyd_s *), 
			void *mapfuncrefp,pxirpshape_s *sp); 
 
/* 
 * pxipmapd.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int)  pxip_calibxyhv(int mode,int order,pxyd_s *xy,pxyd_s *hv,void **spp); 
_cDcl(_dllpxipl,_cfunfcc,void) pxip_calibxyhvdone(void **spp); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxip_calibzi(int mode,int order,double *z,double *zi,void **spp); 
_cDcl(_dllpxipl,_cfunfcc,void) pxip_calibzidone(void **spp); 
 
/* 
 * pxipmapf.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,double) pxip_calibzimap(void *vp,pxyd_s *xyp,double z); 
_cDcl(_dllpxipl,_cfunfcc,void)	 pxip_calibxyhvmap(void *vp,pxyd_s *xyp,pxyd_s *hvp); 
_cDcl(_dllpxipl,_cfunfcc,void)	 pxip_calibhvxymap(void *vp,pxyd_s *hvp,pxyd_s *xyp); 
 
/* 
 * pxipmapi.c 
 */ 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,int) 
			pximpxipmapi(pximage_s *tp,pximage_s *fip, 
			double (_cfunfcc *mapzifunc)(void *,pxyd_s *,double),void *mapzirefp, 
			int windpassthru); 
 
/* 
 * pxipmapn.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,void)	 pxip_xxmapxyhvnull(void *refp,pxyd_s *xyp,pxyd_s *hvp); 
_cDcl(_dllpxipl,_cfunfcc,double) pxip_xxmapzinull(void *refp,pxyd_s *xyp,double i); 
 
/* 
 * pxi8neni.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_copyinterpnearest(pxabortfunc_t**,pximage_s *ip,pximage_s *op,int mode, 
			int orient); 
 
/* 
 * pxi8baks.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_normalizebackground(pxabortfunc_t**,pximage_s *sip,pximage_s *sjp, 
			pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_normalizespecklemask(pxabortfunc_t**,pximage_s *sip,pximage_s *sjp, 
			pximage_s *dip,uchar *testmap,int testbit,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_normalizespecklemask2(pxabortfunc_t**,pximage_s *sip,pximage_s *sjp, 
			pximage_s *dip,uint testvalue,int mode); 
 
/* 
 * pxipedgf.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip_fractedges(double pixbuf[],int pixbufsize,int pixregion, 
			int esthreshold,int mode,int edges,double edgepos[],double edgestrength[]); 
_cDcl(_dllpxipl,_cfunfcc,void) pxip_xxfractedges(double *pix, int window, double *posp, double *sdp); 
 
/* 
 * pxipefit.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip_fitconic(pxyd_s points[],int npoints,int mode,double coniccoef[6]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip_fitellipse(pxyd_s points[],int npoints,int mode,pxyd_s ellipse[3],double coniccoef[6]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip_fithyperbola(pxyd_s points[],int npoints,int mode,pxyd_s ellipse[3],double coniccoef[6]); 
 
/* 
 * pxi8cnt.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_pixthresholdcnt(pxabortfunc_t**,pximage_s *ip,uint threshold,int mode,ulong *cntp); 
 
/* 
 * pxr8cnt.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxirp8_pixthresholdcnt(pxabortfunc_t**,pximregion_s *rp,uint threshold,int mode,ulong *cntp); 
 
/* 
 * pxi8mor3.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_morperode3x3(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_morpdilate3x3(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,int mode); 
 
/* 
 * pxi8vei.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_volequintensity(pxabortfunc_t**,pximage_s *ip,int threshold,int mode, 
			double *sump,double *np); 
 
/* 
 * pxio8prn.c 
 */ 
struct	pxio8print 
{ 
    int     hreplic;	    /* h dimension: pixel replication factor	*/ 
    int     vreplic;	    /* v dimension: pixel replication factor	*/ 
    float   hsize;	    /* print h size, centimeters		*/ 
    float   vsize;	    /* print v size, centimeters		*/ 
    float   hmargin;	    /* left print margin, centimeters		*/ 
    float   vmargin;	    /* top print margin, centimeters		*/ 
    int     orient;	    /* 'p': portrait, 'l': landscape		*/ 
    int     sharpen;	    /* preprocess: degree of sharpening, 0:none */ 
    float   gamma;	    /* preprocess: gamma correction, 1.0: none	*/ 
    char    *halftone;	    /* "screen", "dither", "threshold"		*/ 
    float   halfparm;	    /* depends on halftone			*/ 
    char    *printer;	    /* "HPLJ2", "HPLJ3", "HPLJ4", "IBMGP", etc	*/ 
    int     printerres;     /* printer resolution			*/ 
    int     copies;	    /* 0: use front panel selection		*/ 
    int     eject;	    /* laser & similar: efect page after output?*/ 
}; 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_print(pxabortfunc_t**,pximage_s *ip,struct pxio8print *pp, 
		 int (_cfunfcc *printfunc)(void *statep, uchar *datap, uint n), 
		 void *funcstatep); 
 
/* 
 * pxi8norm.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_normalizemeanline(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
		 uint numerator,uint denominator,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_normalizemeancolumn(pxabortfunc_t**,pximage_s *ip,pximage_s *op, 
		 uint numerator,uint denominator,int mode); 
 
/* 
 * pxi8bave.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_averagebufs(pxabortfunc_t**,pximage3_s *si3p,pximage_s *dip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_integratebufs(pxabortfunc_t**,pximage3_s *si3p,pximage_s *dip, 
			ulong divisor,int mode); 
 
/* 
 * pxi8rave.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_recursiveaverage(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
		    pximage_s *dap,int divisor,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_fifoaverage(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
		    pximage_s *djp,pximage_s *dsp,int divisor,int mode); 
 
/* 
 * pxi8mspa.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_multispectralaverage(pxabortfunc_t**, 
		    pximage_s *s1p,pximage_s *s2p,pximage_s *s3p,pximage_s *dip, 
		    uint values1[],uint values2[],uint values3[],int  mode); 
 
/* 
 * pxi8corr.c 
 */ 
struct pxip8corr 
{ 
    struct pxyd xy;	    /* coordinates		*/ 
    double	r;	    /* correlation coefficient	*/ 
}; 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_correlateprof(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p, 
			pximage_s *dip,int xsubsam,int ysubsam,int mode); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_correlatefind(pxabortfunc_t**,pximage_s *s1p,pximage_s *s2p, 
			int xsubsam,int ysubsam,int mode,int nrslt,struct pxip8corr *rsltp); 
 
/* 
 * pxi8blob.c 
 * pxi8blo2.c 
 */ 
struct	pxip8blob 
{ 
    struct pxy	     seed;	     /* start coordinate of search   */ 
    struct pxywindow wind;	     /* bounding rectangle	     */ 
    ulong	     xyarea;	     /* number of pixels	     */ 
    struct pxyd      ucom;	     /* uniform center of mass	     */ 
}; 
struct	pxip8blob3 
{ 
    struct pxyd       seed;	    /* start coordinate of search   */ 
    struct pxydwindow wind;	    /* bounding rectangle	    */ 
    double	      xyarea;	    /* number of pixels 	    */ 
    struct pxyd       ucom;	    /* uniform center of mass	    */ 
}; 
struct	pxip8blob2 
{ 
    struct pxy		    seed;	/* start coordinate of search	*/ 
    struct pxywindow	    wind;	/* bounding rectangle		*/ 
    struct pxip8moments     moments;	/*				*/ 
    struct pxip8histstat    histstat;	/*				*/ 
    struct pxirpshape	    shapestat;	/*				*/ 
}; 
#define PXIP8BLOB_CONNECT4	0x0000 
#define PXIP8BLOB_NOCLEAR	0x0002 
#define PXIP8BLOB_PERIMITER	0x0004 
#define PXIP8BLOB_IGNOREEDGE	0x0008 
#define PXIP8BLOB_CONVEX	0x0100	/* must not be 0x7F */ 
#define PXIP8BLOB_NOHOLE	0x0200	/* must not be 0x7F */ 
 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_bloblist(pxabortfunc_t**,pximage_s*ip,pxy_s*findxyp,int findcond,uint findvalue, 
			int mode,pxywindow_s *bounds,uint clearvalue,struct pxip8blob *proto, 
			uint nblobs,struct pxip8blob results[],ulong *nbadblobs); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_bloblist3(pxabortfunc_t**,pximage_s*ip,pxy_s*findxyp,int findcond,uint findvalue, 
			int mode,pxywindow_s *bounds,uint clearvalue,struct pxip8blob3 *proto, 
			uint nblobs,struct pxip8blob3 results[],ulong *nbadblobs); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_bloblist2(pxabortfunc_t**,pximage_s*ip,pximage_s*gip,pxy_s*findxyp,int findcond,uint findvalue, 
			int mode,pxywindow_s *bounds,uint clearvalue, 
			double (_cfunfcc *mapzifunc)(void *,pxyd_s *,double), 
			void (_cfunfcc *mapxyhvfunc)(void *,pxyd_s *,pxyd_s *), 
			void (_cfunfcc *maphvxyfunc)(void *,pxyd_s *,pxyd_s *), 
			void *mapzirefp,void* mapxyhvrefp,struct pxip8blob2 *proto, 
			uint nblobs,struct pxip8blob2 results[],ulong *nbadblobs); 
 
/* 
 * pxi8tile.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_seqtile(pxabortfunc_t**,pximage3_s *sip,pximage_s *dip, 
			pxcoord_t overlap,pxy_s*framesize,pxy_s*bordersize, 
			uint framevalues[],uint bordervalues[],double aspect,int mode,int zdim); 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_seqtilecoord(pxabortfunc_t**,pximage3_s *sip,pximage_s *dip, 
			pxy_s*framesize,pxy_s*bordersize, 
			double aspect,int zdim,int which,pxywindow_s *windp); 
 
/* 
 * pxi8ckey.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_ckeygraphics(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
			uint ipkey[],int mode,uint opvalues[]); 
 
 
/* 
 * pxippart.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip_particleflow(pxabortfunc_t**,int ant,struct pxip8blob *ablobs[],int anblob[], 
			int firstblob,int results[],int nresults,int *nextblob, 
			double	aminV,double amaxV,double amaxdeltaV, 
			ulong minA,ulong maxA,long deltaA,int trackV,int trackA); 
 
/* 
 * pxi8raen.c 
 */ 
_cDcl(_dllpxipl, _cfunfcc, int) pxip8_radialmass(pxabortfunc_t**p,pximage_s *ip, 
			pxy_s*xyp,double data[],int ndata,double scalex,double scaley); 
_cDcl(_dllpxipl, _cfunfcc, int) pxip8_radialmassf(pxabortfunc_t**p,pximage_s *ip, 
			pxyd_s *xyp,double data[],int ndata, 
			double (_cfunfcc *mapzifunc)(void *,pxyd_s *,double), 
			void (_cfunfcc *mapxyhvfunc)(void *,pxyd_s *,pxyd_s *), 
			void *mapzirefp,void* mapxyhvrefp,double scaled); 
 
/* 
 * pxipparf.c 
 */ 
struct pxipparticleflow2 { 
 
    /* 
     * Parms 
     */ 
    double  vect_minmag;	    // crisp minimum allowable vector magnitude 
    double  vect_maxmag;	    // crisp maximum allowable vector magnitude 
    double  vect_maxmassdif;	    // crisp maximum allowable difference between the two end-blobs' area or mass. 
    double  fuzzy_vectmag;	    // nominal, expected, magnitude of a vector 
    double  fuzzy_magmidscale;	    // midscale value of `mag' fuzzy variable 
    double  fuzzy_deltamidscale;    // midscale value of `delta' fuzzy variable 
    double  fuzzy_magdifmidscale;   // midscale value of `magdif' fuzzy variable 
    double  fuzzy_sepmidscale;	    // midscale value of `sep' fuzzy variable 
    double  fuzzy_areadifmidscale;  // midscale value of `areadif' fuzzy variable 
    double  fuzzy_regionsize;	    // max distance of which two vectors should interact. 
    double  fuzzy_minconf;	    // minimum acceptable confidence 
 
    /* 
     * Stats 
     */ 
    double  delta_min, sep_min, mag_min, magdif_min, areadif_min; 
    double  delta_max, sep_max, mag_max, magdif_max, areadif_max; 
    double  delta_sum, sep_sum, mag_sum, magdif_sum, areadif_sum; 
    double  delta_s2m, sep_s2m, mag_s2m, magdif_s2m, areadif_s2m; 
    long    delta_cnt, sep_cnt, mag_cnt, magdif_cnt, areadif_cnt; 
}; 
_cDcl(_dllpxipl, _cfunfcc, int) pxip_particleflow2(pxabortfunc_t **, 
			struct pxip8blob3 blob0[],struct pxip8blob3 blob1[], 
			int nblob0,int nblob1, struct pxipparticleflow2 *p, int options); 
 
/* 
 * pxio8vga.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_vgadisplay(pxabortfunc_t**,pximage_s *ip, 
			pximage_s *lutip,int bits,int mode, 
			int options,int yignore,pximage_s *vgaip, 
			pxy_s*cursxyp,pximage_s *cursip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_vgacoord(pximage_s *ip,int mode,int yignore, 
			pximage_s *vgaip,pxy_s*cursxyp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_vgacoord1(pximage_s *ip,int mode,int yignore, 
			pximage_s *vgaip,pxy_s*cursxyp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_vgacursor(pxabortfunc_t **,pximage_s *ip, 
			int resizemode,int yignore,pximage_s *vgaip, 
			pxy_s*cursxyp,pximage_s *cursip); 
 
/* 
 * pxio8x11.c 
 */ 
#if defined(OS_LINUX_GNU) 
#include &lt;X11/Xlib.h> 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_X11Display(pxabortfunc_t**,pximage_s *ip,pximage_s *lutip, 
			int palletedbits,int mode,int options,int yignore, 
			Display *display,Drawable drawable,VisualID visualID,Colormap colormapID, 
			pxywindow_s *drawwindp,pxy_s *cursxyp,pximage_s *cursip); 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_X11DisplayCursor(pxabortfunc_t **,pximage_s *ip, 
			int resizemode,int yignore,Display *display,Drawable drawable, 
			VisualID visualID,Colormap colormapID,pxywindow_s *drawwindp, 
			pxy_s *cursxyp,pximage_s *cursip); 
#endif 
 
/* 
 * pxio8win.c 
 */ 
#if  defined(OS_WIN3X)|defined(OS_WIN3X_DLL) \ 
    |defined(OS_WIN95)|defined(OS_WIN95_DLL) \ 
    |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
 
#include &lt;windows.h> 
#include &lt;vfw.h> 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_CopyToDevice(pxabortfunc_t**,pximage_s *ip,void *rsvd,void *rsvd2, 
		 int vgapalettebits,int mode,int options,int yignore,HDC hDC, 
		 WORD nX,WORD nY,WORD nWidth,WORD nHeight,pxy_s*cursp, 
		 COLORREF(_cfunfcc * cursfunc)(void*,int,int,COLORREF), 
		 void *cursfuncrefp); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_CopyToDeviceCoord(pximage_s *ip,int mode, 
		 int yignore,HDC hDC,WORD nX,WORD nY,WORD nWidth, 
		 WORD nHeight, pxy_s*cursxyp); 
 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_GDIDisplay(pxabortfunc_t **,pximage_s *ip, 
		 pximage_s *lutip,int vgapalettebits,int resizemode,int options, 
		 int yignore,HDC hDC,pxywindow_s *hDCwindp, 
		 pxy_s*cursxyp,pximage_s *cursip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_DCIDisplay(pxabortfunc_t **,pximage_s *ip, 
		 pximage_s *lutip,int vgapalettebits,int resizemode,int options, 
		 int yignore,HWND wnd,HDC hDC,pxywindow_s *wndwindp, 
		 pxy_s*cursxyp,pximage_s *cursip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_DirectXDisplay(pxabortfunc_t **,pximage_s *ip, 
		 pximage_s *lutip,int vgapalettebits,int resizemode,int options, 
		 int yignore,void *ddrs,pxywindow_s *wndwindp,HWND wnd,HDC hDC, 
		 pxy_s*cursxyp,pximage_s *cursip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_DrawDibDisplay(pxabortfunc_t **,pximage_s *ip, 
		 pximage_s *lutip,int vgapalettebits,int resizemode,int options, 
		 int yignore,HDRAWDIB hDrawDib,HDC hDC,pxywindow_s *hDCwindp, 
		 pxy_s*cursxyp,pximage_s *cursip); 
 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_GDICursor(pxabortfunc_t **,pximage_s *ip, 
		int resizemode,int yignore,HDC hDC,pxywindow_s *hDCwindp, 
		pxy_s*cursxyp,pximage_s *cursip); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_GDICursor2(pxabortfunc_t **,pximage_s *ip, 
		int resizemode,int yignore,HDC hDC,pxywindow_s *hDCwindp, 
		pxy_s*curs1xyp,pxy_s*curs2xyp,pximage_s *curs1ip,pximage_s *curs2ip); 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_GDICoord(pximage_s *ip,int resizemode, 
		int yignore,HDC hDC,pxywindow_s *hDCwindp, 
		pxy_s*cursxyp); 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_GDICoord1(pximage_s *ip,int resizemode, 
		int yignore,HDC hDC,pxywindow_s *hDCwindp, 
		pxy_s*cursxyp); 
 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_DIBCreate(pximage_s *ip,pximage_s *lutip, 
		int mode,HGLOBAL *handlep); 
_cDcl(_dllpxipl, _cfunfcc, void) pxio8_DIBCreateDone(HGLOBAL *handlep); 
 
#else 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_GDICoord(pximage_s *ip,int resizemode, 
		int yignore,int hDC,pxywindow_s *hDCwindp, pxy_s*cursxyp); 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_GDICoord1(pximage_s *ip,int resizemode, 
		int yignore,int hDC,pxywindow_s *hDCwindp, pxy_s*cursxyp); 
#endif 
 
 
/* 
 * pxi8min.c 
 */ 
_cDcl(_dllpxipl, _cfunfcc, int) pxip8_findpixelmax(pxabortfunc_t**,pximage_s *ip,pxy_s *xyp, 
		uint *valuep,ulong *countp,int mode); 
_cDcl(_dllpxipl, _cfunfcc, int) pxip8_findpixelmin(pxabortfunc_t**,pximage_s *ip,pxy_s *xyp, 
		uint *valuep,ulong *countp,int mode); 
//_cDcl(_dllpxipl, _cfunfcc, int) pxirp8_findpixelmax(pxabortfunc_t**,pximregion_s *rp,pxy_s *xyp, 
//		  uint *valuep,ulong *countp,int mode); 
//_cDcl(_dllpxipl, _cfunfcc, int) pxirp8_findpixelmin(pxabortfunc_t**,pximregion_s *rp,pxy_s *xyp, 
//		  uint *valuep,ulong *countp,int mode); 
 
/* 
 * Pop packing, later stuff does its own. 
 */ 
#include "cext_hpe.h"      
 
/* 
 * Following impure, imaging board dependent, misfits need pxdlib.h 
 */ 
#if !defined(C_TMSC40) 
 
/* 
 * pxio8win.c 
 * pxio8vga.c 
 */ 
_cDcl(_dllpxipl, _cfunfcc, int) pxio8_vgawaterfall(pxabortfunc_t**, 
		ulong (_cfunfcc *vbtimefunc)(void *),void *vbtimefuncrefp, pximage_s *ip, 
		pximage_s *lutip,int vgapalettebits,int mode,int options, 
		int bottomup,pximage_s*vgaip,int scrollfactor,void (_cfunfcc *scrollfunc)(void *sp, pximage_s *vgaip, int bottomup, int scrollfactor), 
		void *scrollstate,ulong results[3]); 
 
#if  defined(OS_WIN3X)|defined(OS_WIN3X_DLL) \ 
    |defined(OS_WIN95)|defined(OS_WIN95_DLL) \ 
    |defined(OS_WINNT)|defined(OS_WINNT_DLL) 
 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_WaterfallToDevice(pxabortfunc_t**, 
		 ulong (_cfunfcc *vbtimefunc)(void *),void *vbtimefuncrefp,pximage_s *ip, 
		 void *rsvd,void*rsvd2,int vgapalettebits,int mode,int options,int bottomup,int scrollfact, 
		 HDC hdc,WORD nX,WORD nY,WORD nWidth,WORD nHeight,ulong results[3]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_GDIWaterfall(pxabortfunc_t **, 
		 ulong (_cfunfcc *vbtimefunc)(void *),void *vbtimefuncrefp,pximage_s *ip, 
		 pximage_s *lutip,int vgapalettebits,int resizemode,int diffuse,int bottomup, 
		 HDC hdc,pxywindow_s *hdcwindp,int scrollfactor,ulong results[3]); 
#else 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_WaterfallToDevice(pxabortfunc_t**, 
		 ulong (_cfunfcc *vbtimefunc)(void *),void *vbtimefuncrefp,pximage_s *ip, 
		 void*rsvd,void*rsvd2,int vgapalettebits,int mode,int options,int bottomup,int scrollfact, 
		 uint hdc,uint nX,uint nY,uint nWidth,uint nHeight,ulong results[3]); 
_cDcl(_dllpxipl,_cfunfcc,int) pxio8_GDIWaterfall(pxabortfunc_t **, 
		 ulong (_cfunfcc *vbtimefunc)(void *),void *vbtimefuncrefp,pximage_s *ip, 
		 pximage_s *lutip,int vgapalettebits,int resizemode,int diffuse,int bottomup, 
		 int hdc,pxywindow_s *hdcwindp,int scrollfactor,ulong results[3]); 
#endif 
#endif 
 
/* 
 * pxi8hsb.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_hsbtweak(pxabortfunc_t**,pximage_s *sip,pximage_s *dip, 
		int huebands,int satbands, int brtbands, 
		float hueoffset[],float satscale[],float brtscale[],float satoffset[],float brtoffset[], 
		float satkill, float rsvd1, float rsvd2, float rsvd3, int mode); 
#define pxip8_hsbtweakindex(Huebands, Satbands, Brtbands, Hueband, Satband, Brtband)	\ 
			    (Hueband+Satband*Huebands+Brtband*Huebands*Satbands) 
 
/* 
 * pxi8dpcx.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pxip8_3x3dpcsi(pxabortfunc_t**,pximage_s *sip,pximage_s *dip,double threshold,int mode); 
 
 
/* 
 * pxi8drhp.c 
 */ 
#include "pxi8pcl.h"		    /* defines its own packing! */ 
 
 
#ifdef  __cplusplus 
} 
#endif 
 
#endif			 /* defined( __EPIX_PXIPL_DEFINED) */ 
