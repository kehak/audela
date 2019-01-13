/* 
 * 
 *	pximages.h	External	11-Jun-2004 
 * 
 *	Copyright (C)  1995-2003  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI Image Access: Image Accesses 
 * 
 */ 
 
 
 
#if !defined(__EPIX_PXIMAGES_DEFINED) 
#define __EPIX_PXIMAGES_DEFINED 
#include "cext_hps.h"      
 
#ifdef  __cplusplus 
extern "C" { 
#endif 
 
 
/* 
 * pximmem.c 
 */ 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_memory(pximage_s *tp,void _far16p *imagep,const pxy_s *dimp, 
				  uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_memory2(pximage_s *tp,void _far16p *imagep,const pxy_s *dimp, 
				  uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates, 
				  float pixelwidth,float pixelheight,int pixelwhunits); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_memd(pximage_s *tp, void _far16p *imagep, 
				  const pxy_s *dimp,uint ypitch,const pximagedata_s *datap, 
				  const pximagehints_s *hintp,int waitstates); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_memmalloc(pximage_s *tp,void _far16p*_far16p*bufpp, 
				  const pxy_s *dimp,int pixtype,int bitsused,int pixies,int pixelhint); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_memfree(pximage_s *tp,void _far16p*_far16p*bufpp); 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,pximage_s *) pximage_memmalloc2(void _far16p *bufp, 
				  int pixtype,int bitsused,int pixies,int pixelhint, 
				  pxcoord_t xdim,pxcoord_t ydim,float pixelwidth,float pixelheight,int pixelwhunits); 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,int) pximage_memfree2(pximage_s *tp,void _far16p *bufp); 
 
/* 
 * pximmfm.c 
 */ 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_fmemory(pximage_s *tp,void _farphy *imagep,const pxy_s *dimp, 
				  uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_fmemory2(pximage_s *tp,void _farphy *imagep,const pxy_s *dimp, 
				  uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates, 
				  float pixelwidth,float pixelheight,int pixelwhunits); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage_fmemd(pximage_s *tp, void _farphy *imagep, 
				  const pxy_s *dimp,uint ypitch,const pximagedata_s *datap, 
				  const pximagehints_s *hintp,int waitstates); 
 
/* 
 * pximmem3.c 
 */ 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage3_memory(pximage3_s *tp,void _far16p *imagep,const pxyz_s *dimp, 
			uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage3_memory2(pximage3_s *tp,void _far16p *imagep,const pxyz_s *dimp, 
			uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates, 
			float pixelwidth,float pixelheight,int pixelwhunits,float pixeldepth,int pixelzunits); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage3_memd(pximage3_s *tp, void _far16p *imagep, 
			const pxyz_s *dimp,uint ypitch,ulong zpitch,const pximagedata_s *datap, 
			const pximagehints_s *hintp,int waitstates); 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,int) pximage3_memmalloc(pximage3_s *tp,void _far16p *_far16p *bufpp, 
			const pxyz_s *dimp,int pixtype,int bitsused,int pixies,int pixelhint); 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,int) pximage3_memfree(pximage3_s *tp,void _far16p *_far16p *bufpp); 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,pximage3_s *) pximage3_memmalloc2(void _far16p *bufp, 
				  int pixtype,int bitsused,int pixies,int pixelhint, 
				  pxcoord_t xdim,pxcoord_t ydim,float pixelwidth,float pixelheight,int pixelwhunits, 
				  pxcoord_t zdim,float pixeldepth,int pixeldunits); 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,int) pximage3_memfree2(pximage3_s *tp,void _far16p *bufp); 
 
 
 
/* 
 * pximmfm3.c 
 */ 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage3_fmemory(pximage3_s *tp,void _farphy *imagep,const pxyz_s *dimp, 
			uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage3_fmemory2(pximage3_s *tp,void _farphy *imagep,const pxyz_s *dimp, 
			uint ypitch,int pixtype,int bitsused,int pixies,int pixelhint,int waitstates, 
			float pixelwidth,float pixelheight,int pixelwhunits,float pixeldepth,int pixelzunits); 
_cDcl(_dllpxobj _dllpxipl,_cfunfcc,int) pximage3_fmemd(pximage3_s *tp, void _farphy *imagep, 
			const pxyz_s *dimp,uint ypitch,ulong zpitch,const pximagedata_s *datap, 
			const pximagehints_s *hintp,int waitstates); 
 
/* 
 * pximconv.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_converter(pximage_s *tp,pximage_s *up, 
			pximagedata_s*dp,int windpassthru,int forcedirtyread, 
			int forcebitsused); 
/* 
 * pximcon3.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage3_converter(pximage3_s *tp,pximage3_s *up, 
			pximagedata_s*dp,int windpassthru,int forcedirtyread, 
			int forcebitsused); 
/* 
 * pximnull.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,void)	 pximage_defnull(pximage_s *tp); 
_cDcl(_dllpxipl,_cfunfcc,int)	 pximage_defnop(pximage_s *tp, const pxy_s *dimp, 
					const pximagedata_s *datap, const pximagehints_s *hintp); 
 
 
/* 
 * pximnul3.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,void) pximage3_defnull(pximage3_s *tp); 
 
/* 
 * pxim2to3.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_def3from2(pximage3_s *ip3,pximage_s *ip2,int windpassthru); 
 
/* 
 * pxim3to2.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_def2from3(pximage_s *ip2,pximage3_s *ip3, 
			int xaxis,int yaxis,pxcoord_t slice,int windpassthru); 
 
 
/* 
 * pxim3to3.c 
 */ 
_cDcl(_dllpxipl, _cfunfcc, int) pximage3_def3from3(pximage3_s *tp,pximage3_s *fip,int coefa, int coefb, int coefc, int windpassthru); 
 
 
 
/* 
 * pximclrs.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_colorslice(pximage_s *ip3,pximage_s *ip2,int windpassthru,uint colormap,int rsvd); 
_cDcl(_dllpxipl,_cfunfcc,int) pximage3_colorslice(pximage3_s *ip3,pximage3_s *ip2,int windpassthru,uint colormap,int rsvd); 
 
/* 
 * pximclr.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage_colorconverter(pximage_s *tp,pximage_s *up,int newhint,int windpassthru); 
 
/* 
 * pximclr3.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int) pximage3_colorconverter(pximage3_s *tp,pximage3_s *up,int newhint,int windpassthru); 
 
/* 
 * pximscf.c 
 */ 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,int) pximage_setwind(pximage_s *ip,pxcoord_t ulx,pxcoord_t uly,pxcoord_t lrx,pxcoord_t lry); 
_cDcl(_dllpxipl _dllpxobj,_cfunfcc,int) pximage3_setwind(pximage3_s *ip,pxcoord_t ulx,pxcoord_t uly,pxcoord_t ulz,pxcoord_t lrx,pxcoord_t lry,pxcoord_t lrz); 
 
 
#ifdef  __cplusplus 
} 
#endif 
 
#include "cext_hpe.h"      
#endif				/* !defined(__EPIX_PXIMAGES_DEFINED) */ 
