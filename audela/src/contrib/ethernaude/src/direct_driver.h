/*

  direct_driver.h

  This file is part of the Ethernaude Driver.

  Copyright (C)2000-2005, Michel MEUNIER <michel.meunier10@tiscali.fr>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

        Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

        Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials
        provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

*/

/***************************************************************************/
/* Direct access to the Ethernaude functions.                              */
/***************************************************************************/
/*
Exemple of calling :
unsigned char Buffer[2];
direct_main((int)DIRECT_SERVICE_RESET,(int)2,&Buffer[0],&Buffer[1]);
*/
/***************************************************************************/
#include "sysexp.h"

#if defined OS_WIN
#include <windows.h>
__declspec(dllexport)
int __stdcall direct_main(int service, ...);
#else
int direct_main(int service, ...);
#endif

/***************************************************************************/

#define DIRECT_SERVICE_RESET                1
#define DIRECT_SERVICE_IDENTITY             2
#define DIRECT_SERVICE_CLEARCCD             3

/***************************************************************************/

#define DIRECT_OK                           0
#define DIRECT_ERROR_ARGUALLOC              1
#define DIRECT_ERROR_SERVICENOTFOUND        2
#define DIRECT_ERROR_PBRECEIVED             3
#define DIRECT_ERROR_NULLPARAMETER          4
