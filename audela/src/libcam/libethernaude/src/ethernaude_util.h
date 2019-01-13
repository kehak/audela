/* ethernaude_util.h
 * 
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 * 
 * Mettre ici le texte de la license.
 *
 */

/***************************************************************************/
/* ethernaude_util.h                                                       */
/***************************************************************************/
/* Header for ethernaude_util.c and C files that use ethernaude driver.    */
/***************************************************************************/

#ifndef __ETHERNAUDE_UTIL_H__
#define __ETHERNAUDE_UTIL_H__

#include "ethernaude.h"

/***************************************************************************/
/* Utility functions for using the ethernaude driver                       */
/***************************************************************************/

/* To open manage the TParamCCD structure */
int paramCCD_new(TParamCCD * ParamCCD);
int paramCCD_delete(TParamCCD * ParamCCD);
int paramCCD_put(int index, char *string, TParamCCD * ParamCCD, int alloc);
int paramCCD_get(int index, char *string, TParamCCD * ParamCCD);
int paramCCD_clearall(TParamCCD * ParamCCD, int alloc);

/* To manage strings */
int util_splitline(char *ligne, int *xargc, const char ***xargv);
int util_param_search(TParamCCD * ParamCCD, char *keyword, char *value, int *paramtype);
int util_param_decode(char *ligne, char *keyword, char *value, int *paramtype);
int util_free(void *p);

int util_log(char *message, int signal);

#endif
