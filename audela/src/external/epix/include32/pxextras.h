/* 
 * 
 *	pxextras.h	External	10-Jan-1997 
 * 
 *	Copyright (C)  1994-1997  EPIX, Inc.  All rights reserved. 
 * 
 *	Includes for 'extras' that may come with 
 *	C libraries, but are not an official part of same. 
 * 
 */ 
 
 
/* 
 * Mouse functions 
 */ 
extern	int  _cfunfcc mouseinit(void); 
extern	void _cfunfcc mousedeinit(void); 
extern	int  _cfunfcc mouseis(void); 
extern	int  _cfunfcc mousegetpress(int button); 
extern	int  _cfunfcc mousegetstatpos(void); 
extern	void _cfunfcc mousemotioncount(int *x,int *y); 
extern	void _cfunfcc mousesetsensitivity(int x,int y,int threshold,int click2time); 
extern	void _cfunfcc mousegetsensitivity(int *xp,int *yp,int *thresholdp,int *click2timep); 
extern	int  _cfunfcc mousehit(void); 
extern	void _cfunfcc mousehide(void); 
extern	void _cfunfcc mouseshow(void); 
extern	int  _cfunfcc mouseshown(void); 
extern	void _cfunfcc mousegetpos(int *xp, int *yp); 
extern	void _cfunfcc mousesetpos(int x, int y); 
 
/* 
 * Mouse buttons 
 */ 
#define MOUSE_LEFT	0x01 
#define MOUSE_RIGHT	0x02 
#define MOUSE_BOTH	0x80	    // click left & right 
 
/* 
 * pxextvga.c 
 */ 
_cDcl(_dllpxobj,_cfunfcc,uint)	vga_open(uint mode, int xres, int yres, int bits,int setlut,struct pximage *vgaip, struct pximage *lutip); 
_cDcl(_dllpxobj,_cfunfcc,void)	vga_close(struct pximage *vgaip, struct pximage *lutip); 
