/*

  direct_driver.c

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
#include <stdarg.h>

/* === OS dependant includes files === */
#include "sysexp.h"
#include "etherlinkudp.h"
#include "direct_driver.h"

/* === Ethernaude Dialog functions === */
int direct_ethernaude_0x00(void *args);
int direct_ethernaude_0x01(void *args);
int direct_ethernaude_0x03(void *args);

#if defined OS_WIN
__declspec(dllexport)
int __stdcall direct_main(int service, ...)
#else
int direct_main(int service, ...)
#endif
/* ========================================================*/
/* = This function begins each CCD_Driver call.            */
/* ========================================================*/
/* It sends to the corresponding function.                 */
/* ========================================================*/
{
    static int status;
    va_list marqueur;
    void *pointeur;
    void **argu = NULL;
    int k, nb_argumin = 50, nb_argus, nb_argu;

    /* === analyse et decodage des arguments variables === */

    va_start(marqueur, service);

    nb_argu = va_arg(marqueur, int);
    if (nb_argu < nb_argumin) {
        nb_argus = nb_argumin;
    }
    else {
        nb_argus = nb_argu;
    }
    argu = NULL;
    if ((argu = (void **)
        calloc(nb_argus + 1, sizeof(void *))) == NULL) {
        return (DIRECT_ERROR_ARGUALLOC);
    }
    for (k = 1; k <= nb_argu; k++) {
        pointeur = va_arg(marqueur, void *);
        argu[k] = (void *) pointeur;
    }
    va_end(marqueur);

    /* === appels aux differentes fonctions === */
    status = 0;

    /* --- macro fonctions --- */
    if (service == DIRECT_SERVICE_RESET) {
        status = direct_ethernaude_0x00(argu);
    }
    else if (service == DIRECT_SERVICE_CLEARCCD) {
        status = direct_ethernaude_0x01(argu);
    }
    else if (service == DIRECT_SERVICE_IDENTITY) {
        status = direct_ethernaude_0x03(argu);
    }

    /* --- fonction non reconnue --- */
    else {
        status = DIRECT_ERROR_SERVICENOTFOUND;
    }
    free(argu);
    LOG_DEBUG( "status = %d\n", status );
    return (status);

}

int direct_ethernaude_0x00(void *args)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Reset and returns EthIO version infos.                  */
/* ========================================================*/
/* ------ inputs                                           */
/* none                                                    */
/* ------ outputs                                          */
/* arg1 : (unsigned char*) x                               */
/* arg2 : (unsigned char*) y                               */
/* ------ comments                                         */
/* x.y is the current SX52 soft version.                   */
/* ========================================================*/
{
    unsigned char message[65536];
    int k;
    void **argu;
    argu = (void **) (args);
    /* --- init outputs args --- */
    for (k = 1; k <= 2; k++) {
    *(unsigned char *) argu[k] = (unsigned char) 0;
    }
    /* --- Ask Ethernaude to Reset --- */
    if (EthernaudeReset(message)) {
    /* --- Receive Reset informations --- */
    while (Info_Received() == 0);
    } else {
    return DIRECT_ERROR_PBRECEIVED;
    }
    /* --- outputs args --- */
    for (k = 1; k <= 2; k++) {
    *(unsigned char *) argu[k] = (unsigned char) message[k - 1];
    }
    return DIRECT_OK;
}

int direct_ethernaude_0x01(void *args)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Clear the CCD.                                          */
/* ========================================================*/
/* ------ inputs                                           */
/* arg1  : (unsigned char*) nb wipe                        */
/* ------ outputs                                          */
/* none                                                    */
/* ------ comments                                         */
/* ========================================================*/
{
    unsigned char message[65536], nbwipe;
    void **argu;
    argu = (void **) (args);
    /* --- init outputs args --- */
    if (argu[1] == NULL) {
    return DIRECT_ERROR_NULLPARAMETER;
    }
    nbwipe = *(unsigned char *) (argu[1]);
    /* --- Ask Ethernaude to Reset --- */
    if (ClearCCD(message, nbwipe)) {
    /* --- Receive Reset informations --- */
    while (Info_Received() == 0);
    } else {
    return DIRECT_ERROR_PBRECEIVED;
    }
    return DIRECT_OK;
}

int direct_ethernaude_0x03(void *args)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Identity of the CCD.                                    */
/* ========================================================*/
/* ------ inputs                                           */
/* none                                                    */
/* ------ outputs                                          */
/* arg1  : (unsigned char*) aa                             */
/* ...                                                     */
/* arg28 : (unsigned char*) BB                             */
/* ------ comments                                         */
/* ========================================================*/
{
    unsigned char message[65536];
    int k;
    void **argu;
    argu = (void **) (args);
    /* --- init outputs args --- */
    for (k = 1; k <= 28; k++) {
    *(unsigned char *) argu[k] = (unsigned char) 0;
    }
    /* --- Ask Ethernaude to Reset --- */
    if (Identity(message)) {
    /* --- Receive Reset informations --- */
    while (Info_Received() == 0);
    } else {
    return DIRECT_ERROR_PBRECEIVED;
    }
    /* --- outputs args --- */
    for (k = 1; k <= 28; k++) {
    *(unsigned char *) argu[k] = (unsigned char) message[k - 1];
    }
    return DIRECT_OK;
}
