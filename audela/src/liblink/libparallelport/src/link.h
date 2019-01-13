/* link.h
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

// $Id: link.h,v 1.4 2009-05-01 16:11:02 michelpujol Exp $

#ifndef __PARELLELPORT_H__
#define __PARELLELPORT_H__

#include "libname.h"
#include <liblink/liblink.h>

#if defined(OS_WIN)
   #include <windows.h>
#else
   typedef unsigned int			DWORD;
   typedef DWORD					*LPDWORD;
#endif

/**
 * If you define OS_WIN_USE_LPT_OLD_STYLE, you will use
 * libcam_out function with your lpt port,
 * this function doesn’t work under WinXP and others
 * WinNT systems.
 *
 * If it is not defined, lpt port will be used like printer port, so you
 * will need "null printer" modified plug.
*/

class CParallel : public CLink {
   
public:
   CParallel();
   virtual ~ CParallel();

   int openLink(int argc, const char **argv);
   int closeLink();
   int setChar(char c);
   int getChar(char *c);
   int setBit(int numbit, int value);
   int getBit(int numbit, int *value);
   void getLastError(char *message);
   int getAddress( unsigned short *a_address);

   static const char * getGenericName();
   static int getAvailableLinks(LPDWORD pnumDevices, char **list);
   
protected :
   unsigned long lastStatus;
   char currentValue;
   unsigned short address;

   void bloquer();
   void debloquer();


#if defined(OS_LIN)
   int fileDescriptor;
#endif   

#if defined(OS_WIN)
   void * hDevice;
#endif
   
};

#endif
