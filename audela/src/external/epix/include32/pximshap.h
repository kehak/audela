/* 
 * 
 *	pximshap.h	External	12-Mar-1992 
 * 
 *	Copyright (C)  1992  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI IP: Interface to Region Shape Analysis 
 * 
 */ 
 
 
struct pxirpshape 
{ 
    double	n;		    /* number of pixels 		    */ 
    double	area;		    /* area				    */ 
 
    pxy_s	majaxis[2];	    /* coordinates of major axis endpoints  */ 
    pxy_s	minaxis[2];	    /* 2 pixels farthest from major axis,   */ 
				    /* each side. Line between these is NOT */ 
				    /* orthogonal to major axis.	    */ 
    double	majaxislength;	    /* length of major axis		    */ 
    double	majaxisangle;	    /* angle of major axis		    */ 
    double	minaxiswidth[2];    /* distance of minaxis[] from major axis*/ 
    double	circumference;	    /* circumference			    */ 
 
    pxyd_s	cm_hv;		    /* center of uniform mass, h, v	    */ 
    double	cm_minradius;	    /* minimum radius from center of mass   */ 
    double	cm_maxradius;	    /* maximum radius from center of mass   */ 
    double	cm_almoia;	    /* angle of least moment of inertia axis*/ 
    pxy_s	cm_minradxy;	    /* pixel at min radius from c.o.m.	    */ 
    pxy_s	cm_maxradxy;	    /* pixel at max radius from c.o.m.	    */ 
 
    pxy_s	haxismin;	    /* pixel with/at minimum H coordinate   */ 
    pxy_s	haxismax;	    /* pixel with/at maximum H coordinate   */ 
    pxy_s	vaxismin;	    /* pixel with/at minimum V coordinate   */ 
    pxy_s	vaxismax;	    /* pixel with/at maximum V coordinate   */ 
    double	haxiswidth;	    /* width as projected on H axis	    */ 
    double	vaxisheight;	    /* height as projected on H axis	    */ 
}; 
typedef struct pxirpshape pxirpshape_s; 
