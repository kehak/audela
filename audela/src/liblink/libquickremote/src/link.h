/* camera.h
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

#ifndef __QUICKREMOTE__H__
#define __QUICKREMOTE__H__

#include "ftd2xx.h"
#include "libname.h"
#include <liblink/liblink.h>

class CQuickremote : public CLink {
   
public:
   CQuickremote();
   virtual ~ CQuickremote();
   
   int openLink(int argc, const char **argv);
   int closeLink();
   int setChar(char c);
   int getChar(char *c);
   int setBit(int numbit, int value);
   int setBit(int numbit, int value, double duration);
   int getBit(int numbit, int *value);
   void getLastError(char *message);

   static const char * getGenericName();
   static int getAvailableLinks(LPDWORD pnumDevices, char **list);
   
protected :
   FT_HANDLE ftHandle ;
   char  currentValue;
   unsigned long lastStatus;
   
   
};


#endif
