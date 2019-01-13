/* cquickremote.cpp
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

// $Id: cquickremote.cpp,v 1.10 2009-10-30 10:18:53 jacquesmichelet Exp $

#include "sysexp.h" //

#if defined(OS_WIN)
#include <windows.h>
#endif

#if defined(OS_LIN)
#include <unistd.h> // pour usleep()
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>    /* pour strcat, strcpy */

#include "link.h"
#include "ftd2xx.h"



// =========== local definiton and types ===========

// =========== local functions prototypes ===========

// =========== local variables ===========
#define INCORRECT_BIT  FT_OTHER_ERROR +1
#define INCORRECT_VALUE  FT_OTHER_ERROR +2
#define HANDLE_ALREADY_OPEN  FT_OTHER_ERROR +3

// ============= methodes statiques ====================================
//  appel au construteur local
int CQuickremote::getAvailableLinks(LPDWORD pnumDevices, char **list) {
   FT_HANDLE ftHandleTemp;
   DWORD Flags;
   DWORD ID;
   DWORD Type;
   DWORD LocId;
   FT_STATUS ftStatus ;
   char ligne[1024];
   int result = LINK_OK;
   
   
   char SerialNumber[16];
   char Description[64];
   
   int i;

   ftStatus = FT_CreateDeviceInfoList(pnumDevices);
   if (ftStatus != FT_OK) {
      return LINK_ERROR;
   }

   // si *pnumDevices = 0, il faut reserver au moins un caractere 
   *list = (char *) malloc(1024 * *pnumDevices +1);
   strcpy ( *list, "");
   
   for( i=0; i< (int) *pnumDevices; i++ ) {
      ftStatus = FT_GetDeviceInfoDetail(i, &Flags, &Type, &ID, &LocId, SerialNumber, Description, &ftHandleTemp);
      if (ftStatus == FT_OK) {         
         sprintf(ligne, "{ %d %d %d %d \"%s\" \"%s\" } ", i, Type, ID, LocId, SerialNumber, Description );
         strcat(*list, ligne);
      } else  {
         result = LINK_ERROR;
         break;
      }
   }
   
   return result;
}

/**
 * getGenericName
 *    retourne le nom generique de la liaison 
 *    attention : c'est une methode statique !
 */

const char * CQuickremote::getGenericName() {
   return "quickremote";
}

// ============ implementation des methodes de CQuickremote ==========================

CQuickremote::CQuickremote() : CLink()
{
   ftHandle = NULL;
   strcpy(name,"");
}

CQuickremote::~CQuickremote()
{
   ftHandle = NULL;
   
}

/**
*  init
*    ouvre le port FTDI
*	  active le mode BitBang
*/
int CQuickremote::openLink(int argc, const char **argv) 
{
 
   if( ftHandle != NULL ) {
      sprintf(this->msg, "link handle is not NULL");
      return  LINK_ERROR;
   }

   if( strlen(name) == 0) {
      sprintf(this->msg, "link name is empty");
      return LINK_ERROR;
   }
   
   if( strlen(name) < strlen(getGenericName()) +1 ) {
      sprintf(this->msg, "link name is too short");
      return LINK_ERROR;
   }
   
   
   // j'extrait le numéro du nom du device, c'est le numero qui sui le nom generique
   char index[10] ;
   strcpy(index, name+strlen(getGenericName()) );
   int deviceNumber = atoi(index);

   lastStatus = FT_Open(deviceNumber,&ftHandle);
   if (lastStatus != FT_OK) {
      char ftdiError[1024];      
      getLastError(ftdiError);
      sprintf(this->msg, "Can't open FTDI device name=%s deviceNumber=%d : %s", name, deviceNumber, ftdiError);
      return  LINK_ERROR;
   }
   
   // j'active le mode BitBang avec tous les bits en OUTPUT
   lastStatus = FT_SetBitMode(ftHandle, 0xff, 1);
   if (lastStatus != FT_OK) {
      return LINK_ERROR;
   }

   
   // j'initialise les sorties a 0
   setChar((char)0);
   return LINK_OK;
}

int CQuickremote::closeLink()
{
   if( ftHandle != NULL ) {
      lastStatus = FT_Close(ftHandle);
      ftHandle = NULL;
      if (lastStatus != FT_OK) {
         return LINK_ERROR;
      }
   }
   return LINK_OK;
}


/**
* ftdipapi_write 
*    ecrit un octet 
*/
int CQuickremote::setChar(char c)
{
   DWORD bytesWritten = 0;
   
   lastStatus = FT_Write(ftHandle, &c, 1, &bytesWritten);
   if (lastStatus != FT_OK && bytesWritten !=1 ) {
      return LINK_ERROR;
   }
   currentValue = c;
   
   return LINK_OK;
   
   
}

/**
 * getChar 
 *    retourne la valeur courante du port 
 */
int CQuickremote::getChar(char *c) {
   *c = currentValue;
   return LINK_OK;
   
}

/**
 * setBit
 *    change la valeur d'un bit
 */
int CQuickremote::setBit(int numbit, int value)
{
   DWORD bytesWritten = 0;
   char mask; 
   char tempValue;
   
   
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
   
   
   lastStatus = FT_Write(ftHandle, &tempValue, 1, &bytesWritten);
   if (lastStatus != FT_OK && bytesWritten !=1 ) {
      return LINK_ERROR;
   }
   currentValue = tempValue;
   
   return LINK_OK;
}


/**
 * setBit
 *    change la valeur d'un bit pendant une duree imposee
 * @param numbit  numero du bit (0 a 7)
 * @param value   valeur 0 ou 1
 * @param duration  duree du changement en seconde
 */
int CQuickremote::setBit(int numbit, int value, double duration)
{
   DWORD bytesWritten = 0;
   char mask; 
   char tempValue, previousValue;
   
   
   if(numbit <0 || numbit >7 ) {
      lastStatus = INCORRECT_BIT;
      return LINK_ERROR;
   }
   
   mask = 1 << numbit;
   previousValue  = currentValue;
   tempValue = currentValue;
   
   if (value == 1 ) {
      tempValue |= mask;
   } else if( value == 0) {
      tempValue &= ~mask;
   } else {
      lastStatus = INCORRECT_VALUE; 
      return LINK_ERROR;
   }
   
   // je met le bit a la valeur demandee
   lastStatus = FT_Write(ftHandle, &tempValue, 1, &bytesWritten);
   if (lastStatus != FT_OK && bytesWritten !=1 ) {
      return LINK_ERROR;
   } 
   // j'attend la duree imposee
   int milliseconds = int(duration * 1000);
   #if defined(OS_LIN)
      usleep(milliseconds * 1000);
   #elif defined(OS_WIN)
     Sleep(milliseconds);
   #elif defined(OS_MACOS)
     usleep(milliseconds * 1000);
   #endif

   // je remet le bit a l'ancienne valeur
   lastStatus = FT_Write(ftHandle, &previousValue, 1, &bytesWritten);
   if (lastStatus != FT_OK && bytesWritten !=1 ) {
      return LINK_ERROR;
   } 
      
   return LINK_OK;
}


/**
 * getBit 
 *    retourne la valeur d'un bit
 */
int CQuickremote::getBit(int numbit, int *value)
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


/**
 * getBit 
 *    retourne le libelle d'une erreur FTDI
 */
void CQuickremote::getLastError(char *message) {
   
   switch( lastStatus) {
   case FT_OK:
      strcpy(message,"FT_OK");
      break;
   case  FT_INVALID_HANDLE:
      strcpy(message,"FT_INVALID_HANDLE");
      break;
   case  FT_DEVICE_NOT_FOUND:
      strcpy(message,"FT_DEVICE_NOT_FOUND");
      break;
   case  FT_DEVICE_NOT_OPENED:
      strcpy(message,"FT_DEVICE_NOT_OPENED");
      break;
   case  FT_IO_ERROR:
      strcpy(message,"FT_IO_ERROR");
      break;
   case  FT_INSUFFICIENT_RESOURCES:
      strcpy(message,"FT_INSUFFICIENT_RESOURCES");
      break;
   case  FT_INVALID_PARAMETER:
      strcpy(message,"FT_INVALID_PARAMETER");
      break;
   case  FT_INVALID_BAUD_RATE:
      strcpy(message,"FT_INVALID_BAUD_RATE");
      break;
   case  FT_DEVICE_NOT_OPENED_FOR_ERASE:
      strcpy(message,"FT_DEVICE_NOT_OPENED_FOR_ERASE");
      break;
   case  FT_DEVICE_NOT_OPENED_FOR_WRITE:
      strcpy(message,"FT_DEVICE_NOT_OPENED_FOR_WRITE");
      break;
   case  FT_FAILED_TO_WRITE_DEVICE:
      strcpy(message,"FT_FAILED_TO_WRITE_DEVICE");
      break;
   case  FT_EEPROM_READ_FAILED:
      strcpy(message,"FT_EEPROM_READ_FAILED");
      break;
   case  FT_EEPROM_WRITE_FAILED:
      strcpy(message,"FT_EEPROM_WRITE_FAILED");
      break;
   case  FT_EEPROM_ERASE_FAILED:
      strcpy(message,"FT_EEPROM_ERASE_FAILED");
      break;
   case  FT_EEPROM_NOT_PRESENT:
      strcpy(message,"FT_EEPROM_NOT_PRESENT");
      break;
   case  FT_EEPROM_NOT_PROGRAMMED:
      strcpy(message,"FT_EEPROM_NOT_PROGRAMMED");
      break;
   case  FT_INVALID_ARGS:
      strcpy(message,"FT_INVALID_ARGS");
      break;
   case  FT_NOT_SUPPORTED:
      strcpy(message,"FT_NOT_SUPPORTED");
      break;
   case  FT_OTHER_ERROR:
      strcpy(message,"FT_OTHER_ERROR");
      break;
      
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


