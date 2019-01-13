/* 
 * 
 *	pxi(p)8regn.h	External	18-Jan-2003 
 * 
 *	Copyright (C)  1990-2003  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI IP: Image region description structure 
 * 
 */ 
 
#if !defined(__EPIX_PXIMREGN_DEFINED) 
#define __EPIX_PXIMREGN_DEFINED 
 
 
/* 
 * Types of region descriptions 
 */ 
#define PXIMREGWIND	    0	    /* use pximage.wind 			*/ 
#define PXIMREGELLIPSE	    1	    /* ellipse, rotated 			*/ 
#define PXIMREGRECTANGLE    2	    /* rectangle, rotated			*/ 
#define PXIMREGPOLYGON	    3	    /* polygon					*/ 
#define PXIMREGPOLYGONX     4	    /* polygon, assumed convex			*/ 
#define PXIMREGSCANLIST     5	    /* scan list				*/ 
#define PXIMREGPATH	    6	    /* pixel path list				*/ 
#define PXIMREGSCANLISTB    7	    /* bounded scan list			*/ 
#define PXIMREGPOLYLINE     8	    /* not fully supported			*/ 
#define PXIMREGANNULUS	    9	    /* annulus, rotated 			*/ 
#define PXIMREGANNULUSARC   10	    /* annulus arc section			*/ 
#define PXIMREGFRAME	    11	    /* frame, rotated				*/ 
#define PXIMREGWINDOW	    12	    /* window (rectangle not rotated)		*/ 
#define PXIMREGELLIPSEF     13	    /* ellipse, rotated, w. float parameters	*/ 
#define PXIMREGRECTANGLEF   14	    /* rectangle, rotated, w. float parameters	*/ 
//efine PXIMREGPOLYGONF     15	    /* polygon, w. float parameters		*/ 
//efine PXIMREGPOLYGONXF    16	    /* polygon, convex, w. float parameters	*/ 
#define PXIMREGANNULUSF     17	    /* annulus, rotated, w. float parameters	*/ 
#define PXIMREGANNULUSARCF  18	    /* annulus arc section, w. float parameters */ 
#define PXIMREGFRAMEF	    19	    /* frame, rotated, w. float parameters	*/ 
#define PXIMREGNEGATIVE     0x100   /* adjective: complement of region within	*/ 
				    /* .. window. Not for PXIMREGSCANLIST(B)	*/ 
				    /* .. or PXIMREGWIND or PXIMREGPOLYLINE	*/ 
 
 
struct pximregion 
{ 
    pximage_s	image;		/* image buffer, opt. clipping window	    */ 
    int 	regiontype;	/* as per PXIMREG* codes		    */ 
    uint	length; 	/* byte length of this variable len struct  */ 
 
    pxy_s	origin; 	/* origin/offset of regions. not used ..    */ 
				/* .. for PXIMREGWIND, PXIMREGSCANLIST(B)   */ 
 
    union pximregiondesc { 
 
	/* 
	 * Window, defined by upper-left origin, width, height. 
	 * The origin or any part of the rectangle may 
	 * extend beyond the image.wind. 
	 */ 
	struct	pximregwindow 
	{ 
	    int     width; 
	    int     height; 
	} window; 
 
	/* 
	 * Rectangle, defined by center/origin, width, height, 
	 * rotation. The origin or any part of the rectangle may 
	 * extend beyond the image.wind. 
	 */ 
	struct	pximregrectangle 
	{ 
	    int     width; 
	    int     height; 
	    float   angle; 
	} rectangle; 
 
	struct	pximregrectanglef { 
	    pxyf_s  originf;	    /* added to integer origin	*/ 
	    float   width; 
	    float   height; 
	    float   angle; 
	} rectanglef; 
 
	/* 
	 * Ellipse defined by center/origin, width, height, 
	 * rotation. The origin or any part of the ellipse may 
	 * extend beyond the image.wind. Code may assume that 
	 * this and pximregrectangle are identical. 
	 */ 
	struct	pximregellipse 
	{ 
	    int     width; 
	    int     height; 
	    float   angle; 
	} ellipse; 
	struct	pximregellipsef { 
	    pxyf_s  originf;	    /* added to integer origin	*/ 
	    float   width; 
	    float   height; 
	    float   angle; 
	} ellipsef; 
 
	/* 
	 * Frame defined by intersection of two rectangles, 
	 * each with width, height, rotation. 
	 * The origin or any part of the rectangle may 
	 * extend beyond the image.wind. 
	 */ 
	struct	pximregframe 
	{ 
	    int     outerwidth; 
	    int     outerheight; 
	    float   outerangle; 
	    int     innerwidth; 
	    int     innerheight; 
	    float   innerangle; 
	} frame; 
	struct	pximregframef 
	{ 
	    pxyf_s  originf;	    /* added to integer origin	*/ 
	    float   outerwidth; 
	    float   outerheight; 
	    float   outerangle; 
	    float   innerwidth; 
	    float   innerheight; 
	    float   innerangle; 
	} framef; 
 
	/* 
	 * Generalized annulus defined by intersection of two ellipses, 
	 * each with width, height, rotation. 
	 * The origin or any part of the ellipses may 
	 * extend beyond the image.wind. Code may assume that 
	 * this and pximregframe are identical. 
	 */ 
	struct	pximregannulus 
	{ 
	    int     outerwidth; 
	    int     outerheight; 
	    float   outerangle; 
	    int     innerwidth; 
	    int     innerheight; 
	    float   innerangle; 
	} annulus; 
	struct	pximregannulusf 
	{ 
	    pxyf_s  originf;	    /* added to integer origin	*/ 
	    float   outerwidth; 
	    float   outerheight; 
	    float   outerangle; 
	    float   innerwidth; 
	    float   innerheight; 
	    float   innerangle; 
	} annulusf; 
 
	/* 
	 * Arc of annulus defined by intersection of two ellipses, 
	 * each with width, height, rotation. 
	 * The origin or any part of the ellipses may 
	 * extend beyond the image.wind. 
	 */ 
	struct	pximregannulusarc 
	{ 
	    int     outerwidth; 
	    int     outerheight; 
	    float   outerangle; 
	    int     innerwidth; 
	    int     innerheight; 
	    float   innerangle; 
	    float   starta; 
	    float   enda; 
	} annulusarc; 
	struct	pximregannulusarcf 
	{ 
	    pxyf_s  originf;	    /* added to integer origin	*/ 
	    float   outerwidth; 
	    float   outerheight; 
	    float   outerangle; 
	    float   innerwidth; 
	    float   innerheight; 
	    float   innerangle; 
	    float   starta; 
	    float   enda; 
	} annulusarcf; 
 
	/* 
	 * Polygon, defined as N vertices. 
	 * Any part of the polygon may extend beyond the image.wind. 
	 * The vertex[4] definition allows room for a PXIMREGRECTANGLE 
	 * to be easily translated to a 4'th order polygon. 
	 * Each vertex is relative to the origin. 
	 */ 
	struct pximpolygon 
	{ 
	    int     N;		    /* number of vertices		*/ 
	    pxy_s   vertex[4];	    /* actually N			*/ 
	} polygon; 
	struct pximpolygonf 
	{ 
	    pxyf_s  originf;	    /* added to origin			*/ 
	    int     N;		    /* number of vertices		*/ 
	    pxyf_s  vertex[4];	    /* actually N			*/ 
	} polygonf; 
 
	/* 
	 * Scan list, defined as pixel runs at x, y coordinates. 
	 * Coordinates & runs don't extend beyond image.wind. 
	 * The origin is reserved, and should be 0. 
	 * 
	 * Also, the bounded scan list; offset by the origin, 
	 * and bounded by the image.wind. 
	 */ 
	struct	pximregscanlist 
	{ 
	    int     N;		    /* number of scans			*/ 
	    struct  pximregscanlists 
	    { 
		pxy_s	    coord;  /* in order, y, y+1, y+2!		*/ 
		pxcoord_t   len;    /* pixel length across x		*/ 
	    } scanlists[1];	    /* actually N			*/ 
	} scanlist; 
 
	/* 
	 * Pixel path list. 
	 * Directions are nibble encoded (low then high) as ->	3  2  1 
	 * If nibble's high bit set, low 3 bits are             4  *  0 
	 * direction and following nibble is replication	5  6  7 
	 * factor-2. The origin is the start pixel. The origin or 
	 * any part of the path may extend beyond the image.wind. 
	 * Directions are absolute, not relative to the last direction 
	 * of travel; i.e. a direction of 0 is always x+1,y+0. 
	 * On machines with more than 8 bits per uchar, all nibbles 
	 * of each uchar are encoded, lowest nibble to highest. 
	 */ 
	struct	pximregpath 
	{ 
	    int     N;		    /* # of nibbles used		*/ 
	    pxy_s   txy;	    /* unused, handy for applic. pgms	*/ 
	    uchar   pathlist[1];    /* direction nibbles		*/ 
	} path; 
 
    } region; 
}; 
typedef struct pximregion pximregion_s; 
typedef struct pximregscanlists pximregscanlists_s; 
 
 
#endif		    /* !defined(__EPIX_PXIMREGN_DEFINED) */ 
