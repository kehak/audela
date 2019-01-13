/* quickremote.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

// $Id: cparallel.cpp,v 1.6 2009-05-01 16:11:02 michelpujol Exp $


#include "sysexp.h"

/*
#if defined(OS_WIN)

   // J'active OS_WIN_USE_PARRALLEL_OLD_STYLE car le nouveau style ne fonctionne pas correctement :
   // Le programme fonctionne sans erreur mais les brocches du port ne changent pas d'état.
   // Inconveninent de l'ancien style : il ne fonctionne pas avec les adaptateurs USB->LPT
   #define OS_WIN_USE_PARRALLEL_OLD_STYLE
   #include <windows.h>
   #include <winspool.h>   // for EnumPorts
#endif

#if defined(OS_LIN)
   #define OS_LIN_USE_PARRALLEL_OLD_STYLE
#   include <asm/io.h>     // for inb()
#endif
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "link.h"
#include "util.h"

// =========== local definiton and types ===========

// =========== local functions prototypes ===========

// =========== local variables ===========
#define INCORRECT_BIT         1
#define INCORRECT_VALUE       2
#define HANDLE_ALREADY_OPEN   3


// ============= methodes statiques ====================================

/**
 * available
 *    retourne la liste des ports disponibles sur la machine
 *    attention : c'est une methode statique !
 */

int CParallel::getAvailableLinks(LPDWORD pnumDevices, char **list) {
   int result;

#ifdef OS_WIN
   char ligne[1024];
   DWORD pcbNeeded;
   DWORD pcReturned;
   PORT_INFO_2 * portlist;
   int ready;
   #if !defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)
      void * hDevice;
   #endif

   *pnumDevices = 0;

   EnumPorts( NULL, 2, 0, 0 , &pcbNeeded, &pcReturned );
   if ( pcbNeeded ) {
      portlist = (PORT_INFO_2*) malloc( pcbNeeded);
      if (EnumPorts( NULL, 2, (unsigned char *) portlist, pcbNeeded , &pcbNeeded, &pcReturned ) != 0 ) {
         *list = (char *) malloc(1024 * pcReturned +1);
         strcpy ( *list, "");
         for(unsigned int i=0 ; i< pcReturned; i++ ) {
            if(strncmp(portlist[i].pPortName, "LPT", 3) == 0 ) {
               int index =0;
               sscanf(portlist[i].pPortName,"LPT%d:", &index);
               // je teste l'ouverture du port
               #if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)
               ready = 1;
               #else
               hDevice = CreateFile(portlist[i].pPortName,  GENERIC_WRITE|GENERIC_READ, 0, NULL,
               OPEN_EXISTING, 0, NULL);               
               if (hDevice != INVALID_HANDLE_VALUE) {
                  CloseHandle(hDevice);
                  ready = 1;
               } else {
                   ready = 0;
               }
               #endif
               
               if (ready == 1) {
                  sprintf(ligne, "{ %d \"%s\" } ", index,  portlist[i].pPortName );
                  strcat(*list, ligne);
                  *pnumDevices++;
               }
            }
         } 
         result = LINK_OK;
      } else  {
         result = LINK_ERROR;
      }
   } else  {
      result = LINK_ERROR;
   }
   if( result == LINK_ERROR) {
      // si numDevices = 0, il faut reserver au moins un caractere 
      *list = (char *) malloc(+1);
      strcpy ( *list, "");
   }
   pcbNeeded = pcbNeeded;
   pcReturned = pcReturned;
#endif

#ifdef OS_LIN
  *list = (char *) malloc(1024 * +1);
#if defined (PROCESSOR_INSTRUCTIONS_INTEL)
  sprintf( *list, "{ 0 \"/dev/parport0\" }");
#else
  sprintf( *list, "");
#endif
  result = LINK_OK;
#endif
  
   return result;
}

/**
 * getGenericName
 *    retourne le nom generique de la liaison 
 *    attention : c'est une methode statique !
 */

const char * CParallel::getGenericName() {
#ifdef OS_LIN
#if defined (PROCESSOR_INSTRUCTIONS_INTEL)
   return "/dev/parport";
#else
   return "";
#endif
#else
   return "LPT";
#endif
}


// ============ implementation des methodes de CParallel ==========================

CParallel::CParallel() : CLink()
{

}

/**
* ~CParallel 
*    ferme le port parallele
*    ( le desctruteur de la classe mère ~Clink est appelé implicitement)
*/

CParallel::~CParallel() 
{

}


/**
*  init
*    ouvre le port parallele
*	  active le mode BitBang
*/
int CParallel::openLink(int argc, const char **argv) {
   int result = LINK_OK;


#if defined(OS_LIN)
#if defined (PROCESSOR_INSTRUCTIONS_ARM)
	result = LINK_OK;
   return result;
#endif
#if defined(OS_LIN_USE_PARRALLEL_OLD_STYLE)
   address = 0x378;

#else
   int buffer; /**< buffer mode of parallel port */
   char name[128];

   index = index -1;
   sprintf(name, "/dev/parport%s", index);
   if (-1 == (fileDescriptor = open(name, O_RDWR))) {
      result = LINK_ERROR;
   } else if (ioctl(fileDescriptor, PPCLAIM)) {
      ioctl(fileDescriptor, PPRELEASE);
      close(fileDescriptor);
      fileDescriptor = -1;
      result = LINK_ERROR;
   } else {

      buffer = IEEE1284_MODE_BYTE;

      if (ioctl(fileDescriptor, PPSETMODE, &buffer)) {
         ioctl(fileDescriptor, PPRELEASE);
         close(fileDescriptor);
         fileDescriptor = -1;
         result = LINK_ERROR;
      }
   }
#endif
#endif

#if defined(OS_WIN)
#if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)

   address = 0x378;

#else

   DWORD nNumberOfBytesWritten = 0;
   char name[128];

   sprintf(name, "LPT%d:", index);
   hDevice = CreateFile(name,  GENERIC_WRITE|GENERIC_READ, 0, NULL,
                 OPEN_EXISTING, 0, NULL);
// hDevice =      CreateFile(name, GENERIC_WRITE|GENERIC_READ, FILE_SHARE_READ|FILE_SHARE_WRITE, NULL,
//                 OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_NO_BUFFERING, NULL);
   if (hDevice == INVALID_HANDLE_VALUE) {
      result = LINK_ERROR;
   }
#endif
#endif
   if( result == LINK_OK) {
      // j'initialise la sortie à 0
      //result = setChar((char)0);
   }
   return result;
}

int CParallel::closeLink()
{

#if defined(OS_LIN)
#if defined (PROCESSOR_INSTRUCTIONS_ARM)
   return LINK_OK;
#endif
#if defined(OS_LIN_USE_PARRALLEL_OLD_STYLE)
#else 
   close(fileDescriptor);
#endif
#endif

#if defined(OS_WIN)
#if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)

#else 
   if( hDevice != INVALID_HANDLE_VALUE ) {
      CloseHandle(hDevice);
   }
#endif
#endif
   
   return LINK_OK;
}


/**
* setChar 
*    ecrit un octet 
*/
int CParallel::setChar(char c)
{
   int result = LINK_OK;
   
#if defined(OS_LIN)
#if defined (PROCESSOR_INSTRUCTIONS_INTEL)
#if defined(OS_LIN_USE_PARRALLEL_OLD_STYLE)
   parallel_bloquer();
   parallel_out(address, c);
   parallel_debloquer();
#else
   // Write a byte 
   if (ioctl(fileDescriptor, PPWDATA, &c)) {
      ioctl(fileDescriptor, PPRELEASE);
      close(fileDescriptor);
      fileDescriptor = -1;
      result = LINK_ERROR;
   }
#endif
#endif
#endif

#if defined(OS_WIN)
#if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)
   unsigned short a = this->address;
   // Write a byte 
   _asm {
        mov dx, a 
        mov al, c 
        out dx, al
    }
#else
   DWORD nNumberOfBytesWritten = 0;
   // Write a byte 
   if (!WriteFile (hDevice,  &c, 1, &nNumberOfBytesWritten, NULL)
       || nNumberOfBytesWritten != 1) {
      CloseHandle(hDevice);
      hDevice = INVALID_HANDLE_VALUE;
      result = LINK_ERROR;
   }
#endif
#endif

   if( result == LINK_OK) {
      currentValue = c;
   }
   return result;
}

/**
* getChar 
*    lit un octet 
*/
int CParallel::getChar(char *c) {
   
#if defined(OS_WIN)
#if defined(OS_WIN_USE_PARRALLEL_OLD_STYLE)
   unsigned short a = this->address;
   char c1;
   // Read a byte
   _asm {
        mov dx, a
        in al, dx
        mov c1, al
    }
   *c = c1;
   return LINK_OK;
#else 
   // not implemented
   return LINK_ERROR;
#endif
#elif defined(OS_LIN) 
#if defined (PROCESSOR_INSTRUCTIONS_INTEL)
		// Read a byte
		*c = inb(this->address);
#else
	*c=0;
#endif
    return LINK_OK;
#elif defined(OS_MACOS)
	return LINK_ERROR;
#endif

}

/**
* setBit 
*    modifie un bit et ecrit l'octet 
*/
int CParallel::setBit(int numbit, int value)
{
   char mask; 
   char tempValue;
   int result;
   
   
   if(numbit <0 || numbit >7 ) {
      lastStatus = INCORRECT_BIT;
      return LINK_ERROR;
   }

   mask = 1 << numbit;
   tempValue = currentValue;
   
   if (value == 1 ) {
       tempValue |= mask;
   } else if( value == 0) {
      tempValue &= ~mask;
   } else {
      lastStatus = INCORRECT_VALUE; 
      return LINK_ERROR;
   }

   result = setChar(tempValue);
   if( result == LINK_OK) {
      currentValue = tempValue;
   }
      
   return result;
}


/**
* getBit 
*    lit un octet  et retourne la valeur d'un bit
*/
int CParallel::getBit(int numbit, int *value)
{
   char mask; 
   char tempValue;

   if(numbit <0 || numbit >7 ) {
      return LINK_ERROR;
   }

   mask = 1 << numbit;
   
   tempValue = (int) (currentValue && mask );

   if( tempValue ==0 ) {
      *value = 0;
   } else {
      *value = 1;
   }

   return LINK_OK;
}


void CParallel::getLastError(char *message) {
   
   switch( lastStatus) {
   case  INCORRECT_BIT:
      strcpy(message,"INCORRECT BIT ");
      break;

   case  INCORRECT_VALUE:
      strcpy(message,"INCORRECT VALUE");
      break;

   case  HANDLE_ALREADY_OPEN:
      strcpy(message,"HANDLE ALREADY OPEN");
      break;

          
   }


}


/**
*  getAdress
*    retourne l'adress du port parallele
*/
int CParallel::getAddress( unsigned short *a_address)
{
   *a_address = address;
   return LINK_OK;
}

