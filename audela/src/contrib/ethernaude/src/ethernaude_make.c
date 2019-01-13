/*

  ethernaude_make.c

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

/* === OS independant includes files === */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/* === OS dependant includes files === */
#include "sysexp.h"
#include "ethernaude_make.h"

/* === Prototype of the main function called by the entry point  === */
/* === That function should be "your" standard entry point=== */
void ethernaude_main(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);

/* === Prototypes for the unique entry point of the library === */
#ifdef OS_WIN
   /* Windows */
#  include <windows.h>
__declspec(dllexport)
void __stdcall ETHERNAUDE_MAIN(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
#endif
#ifdef OS_LIN
   /* Linux */
extern void ETHERNAUDE_MAIN(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
#endif

/* === Entry point of the library === */
#ifdef OS_WIN
__declspec(dllexport)
void __stdcall ETHERNAUDE_MAIN(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
#endif
#ifdef OS_LIN
extern void ETHERNAUDE_MAIN(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
#endif
{
    ethernaude_main(ParamCCDIn, ParamCCDOut);
    return;
}
