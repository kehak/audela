/* ethernaude_user.h
 * 
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 * 
 * Mettre ici le texte de la license.
 *
 */

/***************************************************************************/
/* ethernaude_user.h                                                       */
/***************************************************************************/
/* Header for ethernaude_user.c and C files that use ethernaude driver.    */
/***************************************************************************/

#ifndef __ETHERNAUDE_USER_H__
#define __ETHERNAUDE_USER_H__

#include "ethernaude.h"

/*extern TParamCCD ParamCCDIn, ParamCCDOut;*/

struct new_ethernaude_inp {
    /* --- struture for input parameters of init --- */
    unsigned short ip[4];
    int shutterinvert;		/* normal=0, invert=1 */
    int canspeed;		/* 10us=4, 5us=0 */
};

/* To open and close the ethernaude shared library */
int open_ethernaude(void);
int close_ethernaude(void);

/* To open and initialize the ethernaude shared library */
int new_ethernaude(struct new_ethernaude_inp *inparams, ethernaude_var * ethvar);
int delete_ethernaude(void);

/***************************************************************************/
/* Define the entry point of the ethernaude driver to use it               */
/***************************************************************************/
#if defined(OS_WIN)
/* Windows */
#include <windows.h>
extern HINSTANCE ethernaude;
typedef void __stdcall ETHERNAUDE_CALL(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
extern ETHERNAUDE_CALL *ETHERNAUDE_MAIN;
#define ETHERNAUDE_NAME "CCD_Driver.dll"
#endif

#if defined(OS_UNX) || defined(OS_LIN) || defined(OS_MACOS)
/* Linux */
#include <dlfcn.h>
extern void *ethernaude;
typedef void ETHERNAUDE_CALL(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
extern ETHERNAUDE_CALL *ETHERNAUDE_MAIN;
#define ETHERNAUDE_NAME "CCD_Driver.so"
#endif

/***************************************************************************/
#endif
