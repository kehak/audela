/* 
 * 
 *	pxi(p)8vitc.h	External	04-Mar-1992 
 * 
 *	Copyright (C)  1992  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI IP: Interface to Time Code Decoding Operations. 
 * 
 */ 
 
struct	pxip8smptevitc 
{ 
    int     frames;	    /* frame count				*/ 
    int     seconds;	    /* seconds					*/ 
    int     minutes;	    /* minutes					*/ 
    int     hours;	    /* hours					*/ 
    uchar   fieldmark;	    /* field mark				*/ 
    uchar   dropmark;	    /* drop frame mark				*/ 
    uchar   colormark;	    /* color frame mark 			*/ 
    uchar   bingroupflag;   /* low two bits are Bit 55, 75 respectively */ 
    uchar   bingroups[8];   /* binary groups, low 4 bits per char	*/ 
}; 
