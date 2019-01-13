// File   :quickremote.cpp .
// Date   :05/08/2005
// Author :Michel Pujol
// Description : simple API for FTDI library

#ifdef WIN32
#include <windows.h>
#endif

#include <stdio.h>

#include "cquickremote.h"


// =========== local definiton and types ===========

// =========== local functions prototypes ===========

// =========== local variables ===========
/**
*  init
*    ouvre le port FTDI
*	  active le mode BitBang
*/
int quickremote_open(int numero, int usb_index)
{

   CQuickremote *quickremote = (CQuickremote *)pool->Chercher(numero);
   if(quickremote) {
      return quickremote->open(usb_index);
   } else {
      return QUICKREMOTE_ERROR;
   }
}

int quickremote_close(int numero)
{
   CQuickremote *quickremote = (CQuickremote *)pool->Chercher(numero);
   if(quickremote) {
      return quickremote->close();
   } else {
      return QUICKREMOTE_ERROR;
   }
}


/**
* ftdipapi_write 
*    ecrit un octet 
*/
int quickremote_setChar(int numero, char c)
{
   CQuickremote *quickremote = (CQuickremote *)pool->Chercher(numero);
   if(quickremote) {
      return quickremote->setChar(c);
   } else {
      return QUICKREMOTE_ERROR;
   }
}

/**
* ftdipapi_write 
*    ecrit un octet 
*/
int quickremote_getChar(int numero, char *c) {
   CQuickremote *quickremote = (CQuickremote *)pool->Chercher(numero);
   if(quickremote) {
      return quickremote->getChar(c);
   } else {
      return QUICKREMOTE_ERROR;
   }
}

/**
* ftdipapi_write 
*    ecrit un octet 
*/
int quickremote_setBit(int numero, int numbit, int value)
{
   CQuickremote *quickremote = (CQuickremote *)pool->Chercher(numero);
   if(quickremote) {
      return quickremote->setBit(numbit, value);
   } else {
      return QUICKREMOTE_ERROR;
   }
}


/**
* ftdipapi_write 
*    ecrit un octet 
*/
int quickremote_getBit(int numero, int numbit, int *pvalue)
{
   CQuickremote *quickremote = (CQuickremote *)pool->Chercher(numero);
   if(quickremote) {
      return quickremote->getBit(numbit, pvalue);
   } else {
      return QUICKREMOTE_ERROR;
   }
}




