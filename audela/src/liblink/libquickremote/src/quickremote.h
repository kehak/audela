// File   :quickremote.h .
// Date   :05/08/2005
// Author :Michel Pujol

#ifndef __QUICKREMOTE__H__
#define __QUICKREMOTE__H__


#ifdef __cplusplus
extern "C" {		
#endif				


int quickremote_open(int numero, int usb_index);
int quickremote_close(int numero);
int quickremote_setChar(int numero, char c);
int quickremote_getChar(int numero, char *c);
int quickremote_setBit(int numero, int numbit, int value);
int quickremote_getBit(int numero, int numbit, int *value);

#ifdef __cplusplus
}			
#endif	


#endif
