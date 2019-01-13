/* 
 * 
 *	pxi(p)8pcl.h	External	30-Jul-1996 
 * 
 *	Copyright (C)  1991-1996  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI IP: Interface to PCL format character draw routines 
 * 
 */ 
 
 
/* 
 * NEVER pad these structures; layout must conform 
 * to the HP specification. 
 */ 
#include "cext_hp1.h"      
 
 
/* 
 * Font descriptor structure. 
 * As defined by HP-PCL, but with all 
 * quarter dot fields converted to dots. 
 */ 
struct	pxip8pclfont 
{ 
    ushort  fontdescripsize;	/* must be 64			    */ 
    uchar   rsvd1; 
    uchar   fonttype;		/* 0: 7 bit, chars 32-127	    */ 
				/* 1: 8 bit, chars 32-127, 160-255  */ 
				/* 2: 8 bit, 0-255 except 0,7-15,27 */ 
    ushort  rsvd2; 
    ushort  baselinedistance; 
    ushort  cellwidth; 
    ushort  cellheight; 
    uchar   orientation; 
    uchar   spacing;		/* 0: fixed, 1: proportional	    */ 
    ushort  symbolset; 
    ushort  pitch;		/* default HMI. dots, not 1/4 dots  */ 
    ushort  height;		/* dots, not 1/4 dots		    */ 
    ushort  xheight;		/* dots, not 1/4 dots		    */ 
    schar   widthtype; 
    uchar   style; 
    schar   strokeweight; 
    uchar   typeface; 
    uchar   rsvd3; 
    uchar   serifstyle; 
    ushort  rsvd4; 
    schar   underlinedistance; 
    uchar   underlineheight; 
    ushort  textheight; 	/* dots, not 1/4 dots		    */ 
    ushort  textwidth;		/* dots, not 1/4 dots		    */ 
    ushort  rsvd5[2]; 
    uchar   pitchextended; 
    uchar   heightextended; 
    ushort  rsvd6[3]; 
    char    fontname[16]; 
}; 
 
/* 
 * Character descriptor structure. 
 * As defined by HP-PCL, but with all 
 * quarter dot fields converted to dots. 
 */ 
struct pxip8pclchar 
{ 
    uchar   format;		/* must be 4			    */ 
    uchar   continuation;	/* 0: normal, 1: continuation	    */ 
    uchar   descriptorsize;	/* must be 14			    */ 
    uchar   pclclass;		/* must be 1			    */ 
    uchar   orientation;	/* 0: portrait, 1: landscape	    */ 
    uchar   rsvd; 
    short   leftoffset; 
    short   topoffset; 
    ushort  charwidth; 
    ushort  charheight; 
    short   deltax;		/* dots, not 1/4 dots!		    */ 
}; 
 
 
/* 
 * pxi8drhp.c 
 */ 
_cDcl(_dllpxipl,_cfunfcc,int)  pxip8_pclfontload(char *filename,void _far16p **fonthandlep); 
_cDcl(_dllpxipl,_cfunfcc,int)  pxip8_pclfontdraw(pxabortfunc_t**,pximage_s *ip,void _far16p *fonthandle, 
			pxy_s *xy,char *cp,int cn,int xscale,int yscale, 
			int hlead,int vlead,int groundtype,uint background[],uint foreground[]); 
_cDcl(_dllpxipl,_cfunfcc,struct pxip8pclfont _far16p *) 
			pxip8_pclfontinfo(void _far16p *fonthandle); 
_cDcl(_dllpxipl,_cfunfcc,struct pxip8pclchar _far16p *) 
			pxip8_pclfontcinfo(void _far16p *fonthandle,int c); 
_cDcl(_dllpxipl,_cfunfcc,void) pxip8_pclfontunload(void _far16p **fonthandlep); 
 
 
#include "cext_hpe.h"     
