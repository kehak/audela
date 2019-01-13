/*

  ethernaude_util.h

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
int paramCCD_get(int index, char *string, const TParamCCD * ParamCCD);
int paramCCD_clearall(TParamCCD * ParamCCD, int alloc);

/* To manage strings */
int util_splitline(char *ligne, int *xargc, char ***xargv);
int util_param_search(const TParamCCD * ParamCCD, const char *keyword, char *value, int *paramtype);
int util_param_decode(char *ligne, char *keyword, char *value, int *paramtype);
int util_free(void *p);

int util_log(char *message, int signal);

#endif
