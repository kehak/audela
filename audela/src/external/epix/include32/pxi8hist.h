/* 
 * 
 *	pxi(p)8hist.h	External	11-Feb-2001 
 * 
 *	Copyright (C)  1985-2001  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI IP: Interface to Histograms 
 * 
 */ 
 
 
#define PXIP8HISTPERC	101		/* true for all pixel sizes	*/ 
 
 
/* 
 * Histogram record 
 */ 
struct	pxip8histab 
{ 
    int     histpix;		    /* always 256 for 8 bit pixels .. */ 
    ulong   count[256]; 	    /* .. set by pxip8_histab	      */ 
}; 
typedef struct pxip8histab pxip8histab_s; 
 
/* 
 * Percentile record 
 */ 
struct pxip8histperc 
{ 
    uint    value[PXIP8HISTPERC]; 
}; 
typedef struct pxip8histperc pxip8histperc_s; 
 
/* 
 * Histogram statistics 
 */ 
struct pxip8histstat 
{ 
			/*		    Fi is frequency:	    */ 
			/*		    Xi is variate:	    */ 
    ulong   nnn;	/* # of pixels	    sum of Fi		    */ 
    double  sum;	/* sum of pixels    sum of Fi * Xi	    */ 
    double  sum2;	/* sum of pixels^2  sum of Fi * Xi * Xi     */ 
    ulong   maxn;	/* max count	    max Fi		    */ 
    ulong   minn;	/* min count	    min Fi		    */ 
    uint    maxv;	/* pixel of maxn    Xi of maxn's Fi         */ 
    uint    minv;	/* pixel of minn    Xi of minn's Fi         */ 
    uint    low;	/* lowest pixel     lowest Xi w. nonzero Fi */ 
    uint    high;	/* highest pixel    highest Xi w. nonzero Fi*/ 
 
    /* 
     * Derived values 
     */ 
    float   mom1;	/* first moment 			    */ 
    float   var;	/* variance				    */ 
    float   stddev;	/* standard deviation			    */ 
    float   rms;	/* rms value				    */ 
}; 
typedef struct pxip8histstat pxip8histstat_s; 
