/* direct_driver.h
 * 
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 * 
 * Mettre ici le texte de la license.
 *
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
#ifndef __DIRECT_DRIVER_H__
#define __DIRECT_DRIVER_H__

#include "sysexp.h"

#define ETHERNAUDE_DIRECTMAIN direct_main
#define ETHERNAUDE_DIRECTMAINQ "direct_main"

/***************************************************************************/
/* Define the entry point of the ethernaude driver to use it               */
/***************************************************************************/
#if defined(OS_WIN)
/* Windows */
#include <windows.h>
typedef int __stdcall ETHERNAUDE_DIRECTCALL(int service, ...);
#endif

#if defined(OS_UNX) || defined(OS_LIN) || defined(OS_MACOS)
/* Linux */
#include <dlfcn.h>
typedef int ETHERNAUDE_DIRECTCALL(int service, ...);
#endif

extern ETHERNAUDE_DIRECTCALL *ETHERNAUDE_DIRECTMAIN;


/*
#if defined OS_WIN
#include <windows.h>
   __declspec(dllexport) int __stdcall direct_main(int service,...);
#else
   int direct_main(int service, ...);
#endif
*/


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

#endif
