/* 
 * 
 *	pxi(p)8mmnt.h	External	11-Feb-2001 
 * 
 *	Copyright (C)  1990-2001  EPIX, Inc.  All rights reserved. 
 * 
 *	DVI IP: Interface to Moment of Inertia 
 * 
 */ 
 
 
/* 
 * NB: Some code may access this (set all to 0) as an array of doubles 
 */ 
struct pxip8moments 
{ 
	double	n;		/* number of points		*/ 
	double	nz;		/* number of points not zero	*/ 
 
	/* 
	 * Center of mass 
	 */ 
	double	cmass_x; 
	double	cmass_y; 
 
	/* 
	 * Moments, in form of array[x][y]. 
	 * Up to third order is supported: 
	 *	[0][0], [0][1], [0][2], [0][3], 
	 *	[1][0], [1][1], [1][2], 
	 *	[2][0], [2][1], 
	 *	[3][0]. 
	 * Fourth and higher order moments such as [2][2], [2][3], 
	 * are always set to 0. 
	 */ 
	double	mom[4][4];	/* raw moments about origin		*/ 
	double	cmom[4][4];	/* central moments, unnormalized	*/ 
	double	cnormmom[4][4]; /* central moments, scale normalized	*/ 
 
	double	hu_mom[7];	/* invariant moments, as per Hu 	*/ 
}; 
typedef struct pxip8moments pxip8moments_s; 
