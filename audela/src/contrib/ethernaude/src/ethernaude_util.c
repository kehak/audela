/*

  ethernaude_util.c

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
#include "ethernaude_util.h"

/***************************************************************************/
/* paramCCD_new :                                                          */
/***************************************************************************/
/* Build and initialize the TParamCCD structure elements.                  */
/* The integer : ParamCCD.NbreParam=0                                      */
/* The 0<=k<MAXCOMMAND string pointers : ParamCCD->Param[k]=NULL;          */
/*                                                                         */
/* Input values :                                                          */
/*                                                                         */
/* Output values :                                                         */
/* ParamCCD : the modified TParamCCD structure.                            */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : all is OK.                                                         */
/***************************************************************************/
int paramCCD_new(TParamCCD * ParamCCD)
{
    int k;
    ParamCCD->NbreParam = 0;
    for (k = 0; k < MAXCOMMAND; k++) {
        ParamCCD->Param[k] = NULL;
    }
    return 0;
}

/***************************************************************************/
/* paramCCD_delete :                                                       */
/***************************************************************************/
/* Delete the TParamCCD structure elements.                                */
/* The integer : ParamCCD.NbreParam=0                                      */
/* The 0<=k<MAXCOMMAND string pointers : ParamCCD->Param[k] are freed (if  */
/*                                       not NULL and forced to be NULL).  */
/*                                                                         */
/* Input values :                                                          */
/*                                                                         */
/* Output values :                                                         */
/* ParamCCD : the modified TParamCCD structure.                            */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : all is OK.                                                         */
/***************************************************************************/
int paramCCD_delete(TParamCCD * ParamCCD)
{
    int k;
    for (k = 0; k < MAXCOMMAND; k++) {
	if (ParamCCD->Param[k] != NULL) {
	    free(ParamCCD->Param[k]);
	    ParamCCD->Param[k] = NULL;
	}
    }
    ParamCCD->NbreParam = 0;
    return 0;
}

/***************************************************************************/
/* paramCCD_clearall :                                                     */
/***************************************************************************/
/* Initialize the TParamCCD structure elements.                            */
/*                                                                         */
/* Input values :                                                          */
/* ParamCCD : the TParamCCD structure to be modified.                      */
/* alloc : =1 if memory allocation must be freed.                          */
/*                                                                         */
/* The integer : ParamCCD.NbreParam=0                                      */
/* The 0<=k<MAXCOMMAND string pointers :                                   */
/*   if (alloc==1)                                                         */
/*      ParamCCD->Param[k] are freed (if not NULL and forced to be NULL).  */
/*   if (alloc==0)                                                         */
/*      ParamCCD->Param[k] are forced to be "".                            */
/*                                                                         */
/* Output values :                                                         */
/* ParamCCD : the modified TParamCCD structure.                            */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : all is OK.                                                         */
/* =1 to MAXCOMMAND : in the case of alloc==0, the kth element is NULL.    */
/***************************************************************************/
int paramCCD_clearall(TParamCCD * ParamCCD, int alloc)
{
    int return_value = 0, k;
    if (alloc == 1) {
	return_value = paramCCD_delete(ParamCCD);
    } else {
        ParamCCD->NbreParam = 0;
        for (k = 0; k < MAXCOMMAND; k++) {
            if (ParamCCD->Param[k] == NULL) {
        	return_value = k + 1;
                break;
            }
            strcpy(ParamCCD->Param[k], "");
        }
    }
    return return_value;
}

/***************************************************************************/
/* paramCCD_put :                                                          */
/***************************************************************************/
/* Put a string at the indexth element in the TParamCCD structure.         */
/*                                                                         */
/* Input values :                                                          */
/* index : the index (>=0 and <MAXCOMMAND) of the string to be put         */
/*         or, if index<0 , compute the index to append at the next        */
/*                          void element. Memory alloc is made if alloc=1. */
/* string : the terminated NULL string of characters to be put.            */
/* ParamCCD : the initial TParamCCD structure.                             */
/* alloc : =1 if memory allocations must be performed.                     */
/*                                                                         */
/* Output values :                                                         */
/* ParamCCD : the modified TParamCCD structure.                            */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : all is OK.                                                         */
/* =1 : error : string allocation cannot be performed.                     */
/* =2 : error : index value is lower than zero.                            */
/* =3 : error : index value is upper or equal than MAXCOMMAND.             */
/***************************************************************************/
int paramCCD_put(int index, char *string, TParamCCD * ParamCCD, int alloc)
{
    int len, return_value = 0, k;
    /* Case of a negative index == -1. Index is going to be for the next NULL element */
    if (index < 0) {
        if (alloc == 1) {
            for (index = 0; index < MAXCOMMAND; index++) {
                if (ParamCCD->Param[index] == NULL) {
                    break;
                }
            }
        } else {
            for (index = 0; index < MAXCOMMAND; index++) {
                if (strcmp(ParamCCD->Param[index], "") == 0) {
                    break;
                }
            }
        }
    }
    /* Verify the index value integrity */
    if (index < 0) {
        return_value = 2;
    }
    if (index >= MAXCOMMAND) {
        return_value = 3;
    }
    if (return_value != 0) {
        return return_value;
    }
    if (alloc == 1) {
        /* Free the indexth Param if not NULL */
        if (ParamCCD->Param[index] != NULL) {
            free(ParamCCD->Param[index]);
            ParamCCD->Param[index] = NULL;
        }
        /* Allocate memory for the indexth Param */
        len = 1 + (int) strlen(string);
        /*len=MAXLENGTH; */
        ParamCCD->Param[index] = (char *) calloc(len, sizeof(char));
        if (ParamCCD->Param[index] == NULL) {
            return_value = 1;
        } else {
            return_value = 0;
            strcpy(ParamCCD->Param[index], string);
        }
        /* Count the elements and update ParamCCD.NbreParam */
        ParamCCD->NbreParam = 0;
        for (k = 0; k < MAXCOMMAND; k++) {
            if (ParamCCD->Param[k] == NULL) {
                break;
            }
            ParamCCD->NbreParam++;
        }
    } else {
        strcpy(ParamCCD->Param[index], string);
        /* Count the elements and update ParamCCD.NbreParam */
        ParamCCD->NbreParam = 0;
        for (k = 0; k < MAXCOMMAND; k++) {
            if (strcmp(ParamCCD->Param[k], "") == 0) {
                break;
            }
            ParamCCD->NbreParam++;
        }
    }
    return return_value;
}

/***************************************************************************/
/* paramCCD_get :                                                          */
/***************************************************************************/
/* Get a string of the indexth element in the TParamCCD structure.         */
/*                                                                         */
/* Input values :                                                          */
/* index : the index (>=0 and <MAXCOMMAND) of the string to be goten.      */
/* string : the terminated NULL string of characters to be goten.          */
/* ParamCCD : the TParamCCD structure.                                     */
/*                                                                         */
/* Output values :                                                         */
/* string : the terminated NULL string of characters.                      */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : all is OK.                                                         */
/* =1 : error : indexth element is NULL. string is filled by ""            */
/* =2 : error : index value is lower than zero.                            */
/* =3 : error : index value is upper or equal than MAXCOMMAND.             */
/***************************************************************************/
int paramCCD_get(int index, char *string, const TParamCCD * ParamCCD)
{
    int return_value = 0;
    /* Verify the index value integrity */
    if (index < 0) {
        return_value = 2;
    }
    if (index >= MAXCOMMAND) {
        return_value = 3;
    }
    if (return_value != 0) {
        return return_value;
    }
    /* Get the value if not NULL */
    if (ParamCCD->Param[index] != NULL) {
        strcpy(string, ParamCCD->Param[index]);
        return 0;
    }
    strcpy(string, "");
    return 1;
}


/***************************************************************************/
/* util_free :                                                             */
/***************************************************************************/
/* Free memory allocated by util_splitline.                                */
/***************************************************************************/
int util_free(void *p)
{
    if (p != NULL) {
        free(p);
        return 0;
    }
    return 1;
}

/***************************************************************************/
/* util_splitline :                                                        */
/***************************************************************************/
/* Returns an array of strings from a string. The entry string is splitted */
/* at each blank space except when the blanck is inside a double quote.    */
/*                                                                         */
/* Example :                                                               */
/*   char **argv=NULL;                                                     */
/*   int argc;                                                             */
/*   util_splitline(ligne,&argc,&argv);                                    */
/*   util_free((char*)argv);                                               */
/*                                                                         */
/* Input values :                                                          */
/* line : the terminated NULL string.                                      */
/*                                                                         */
/* Output values :                                                         */
/* xargc : the number of elements in the array of strings                  */
/* xargv : the array of strings.                                           */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : all is OK.                                                         */
/* =1 : error : input string is NULL or memery allocation error.           */
/***************************************************************************/
int util_splitline(char *ligne, int *xargc, char ***xargv)
{
    int len, klen, k, kdeb, kfin, argc, dquote;
    char **argv = NULL;
    char c0, c1;
    /* --- cas de chaine nulle --- */
    if (ligne == NULL) {
        argc = 1;
        if ((argv = (char **) calloc(argc, sizeof(char *))) == NULL) {
            return 1;
        }
        argv[0] = (char *) &ligne[0];
        *xargc = argc;
        *xargv = argv;
        return 0;
    }
    /* --- cherche la limite la chaine \0 ou \n --- */
    len = (int) strlen(ligne);
    klen = len;
    for (k = 0; k < len; k++) {
        if (ligne[k] == '\n') {
            klen = k;
            break;
        }
    }
    /* --- compte les arguments --- */
    argc = 0;
    kdeb = 0;
    kfin = 0;
    c0 = ' ';
    dquote = 0;
    for (k = 0; k < klen; k++) {
        c1 = ligne[k];
        if (c1 == '\"') {
            dquote++;
            if (dquote == 2) {
                dquote = 0;
                kdeb = k + 1;
                argc++;
            } else {
                kdeb = k + 1;
            }
        } else if (c1 == ' ') {
            if ((dquote == 0) && (c0 != '\"') && (c0 != ' ') && (c0 != '\0')) {
                kdeb = k + 1;
                argc++;
            } else if (dquote == 0) {
                kdeb = k + 1;
            }
        } else if ((k == klen - 1) && (c1 != ' ')) {
            kdeb = k + 1;
            argc++;
        } else if ((c0 == ' ') && (dquote == 0)) {
            kdeb = k;
        }
        c0 = c1;
    }
    /* --- alloue argv --- */
    if ((argv = (char **) calloc(argc, sizeof(char *))) == NULL) {
        return 1;
    }
    /* --- split la ligne de commande en argv --- */
    argc = 0;
    kdeb = 0;
    kfin = 0;
    c0 = ' ';
    dquote = 0;
    for (k = 0; k < klen; k++) {
        c1 = ligne[k];
        if (c1 == '\"') {
            dquote++;
            if (dquote == 2) {
                dquote = 0;
                ligne[k] = '\0';
                argv[argc] = (char *) &ligne[kdeb];
                kdeb = k + 1;
                argc++;
            } else {
                kdeb = k + 1;
            }
        } else if (c1 == ' ') {
            if ((dquote == 0) && (c0 != '\"') && (c0 != ' ') && (c0 != '\0')) {
                ligne[k] = '\0';
                argv[argc] = (char *) &ligne[kdeb];
                kdeb = k + 1;
                argc++;
            } else if (dquote == 0) {
                kdeb = k + 1;
            }
        } else if ((k == klen - 1) && (c1 != ' ')) {
            ligne[k + 1] = '\0';
            argv[argc] = (char *) &ligne[kdeb];
            kdeb = k + 1;
            argc++;
        } else if ((c0 == ' ') && (dquote == 0)) {
            kdeb = k;
        }
        c0 = c1;
    }
    /* --- attribue les valeurs aux pointeurs de sortie --- */
    *xargc = argc;
    *xargv = argv;
    return 0;
}


/***************************************************************************/
/* util_param_search :                                                     */
/***************************************************************************/
/***************************************************************************/
int util_param_search(const TParamCCD * ParamCCD, const char *keyword, char *value, int *paramtype)
{
    char ligne[MAXLENGTH + 1], keywordk[MAXLENGTH + 1], valuek[MAXLENGTH + 1];
    int k, paramtypek;
    int found = 1;
    *paramtype = 0;
    strcpy(value, "");
    for (k = 0; k < ParamCCD->NbreParam; k++) {
        paramCCD_get(k, ligne, ParamCCD);
        util_param_decode(ligne, keywordk, valuek, &paramtypek);
        if (strcmp(keywordk, keyword) == 0) {
            strcpy(value, valuek);
            *paramtype = paramtypek;
            found = 0;
            break;
        }
    }
    if (found == 1) {
        strcpy(value, "");
        *paramtype = 0;
    }
    return found;
}

/***************************************************************************/
/* util_param_decode :                                                     */
/***************************************************************************/
/***************************************************************************/
int util_param_decode(char *ligne, char *keyword, char *value, int *paramtype)
{
    int len, k, kk, kdeb, kfin, posequal;
    char c, dummy[MAXLENGTH + 1];

    /* ========= search position of the first '=' & extract keyword ====== */
    len = strlen(ligne);
    for (k = 0; k < len; k++) {
        c = ligne[k];
        keyword[k] = c;
        if (c == '=') {
            break;
        }
    }
    keyword[k] = '\0';
    posequal = k;
    /* - trim left spaces of the keyword - */
    len = strlen(keyword);
    k = 0;
    kdeb = 0;
    while (keyword[k] == ' ') {
        k++;
    }
    kdeb = k;
    /* - trim right spaces of the keyword - */
    len = strlen(keyword);
    k = len;
    kfin = len;
    while (keyword[k - 1] == ' ') {
        k--;
    }
    kfin = k;
    /* - supress trim spaces of keyword - */
    for (k = 0; k < kfin; k++) {
        keyword[k] = keyword[k + kdeb];
    }
    keyword[k] = '\0';

    /* ========= extract value ====== */
    len = strlen(ligne);
    for (kk = 0, k = posequal + 1; k < len; k++, kk++) {
        c = ligne[k];
        dummy[kk] = c;
    }
    dummy[kk] = '\0';
    /* - trim left spaces of the dummy - */
    len = strlen(dummy);
    k = 0;
    kdeb = 0;
    while (dummy[k] == ' ') {
        k++;
    }
    kdeb = k;
    /* - trim right spaces of the keyword - */
    len = strlen(dummy);
    k = len;
    kfin = len;
    while (dummy[k - 1] == ' ') {
        k--;
    }
    kfin = k;
    /* - supress trim spaces of keyword - */
    for (k = 0; k < kfin; k++) {
        dummy[k] = dummy[k + kdeb];
    }
    dummy[k] = '\0';
    strcpy(value, dummy);
    *paramtype = 0;

    /* ============== case of a value that begins with # ================ */
    if (dummy[0] == '#') {
        len = strlen(dummy);
        kk = 0;
        kdeb = 0;
        kfin = 0;
        for (k = 0; k < len; k++) {
            c = dummy[k];
            if (c == '#') {
                kk++;
                if (kk == 3) {
                    kdeb = k;
                    kfin = k;
                }
                if (kk == 4) {
                    kfin = k;
                }
            }
        }
        for (kk = 0, k = kdeb + 1; k < kfin; k++, kk++) {
            value[kk] = dummy[k];
        }
        value[kk] = '\0';
        /* - trim left spaces of the value - */
        len = strlen(value);
        k = 0;
        kdeb = 0;
        while (value[k] == ' ') {
            k++;
        }
        kdeb = k;
        /* - trim right spaces of the value - */
        len = strlen(value);
        k = len;
        kfin = len;
        while (value[k - 1] == ' ') {
            k--;
        }
        kfin = k;
        /* - supress trim spaces of value - */
        for (k = 0; k < kfin; k++) {
            value[k] = value[k + kdeb];
        }
        value[k] = '\0';
    }
    return 0;
}

int util_log(char *message, int signal)
{
#ifdef ETHERNAUDE_DEBUG
    FILE *f;
    if (signal == 0) {
        f = fopen("ethernaude.txt", "at");
        fprintf(f, "%s\n", message);
        fclo                                                                e(f);
        return (0);
    }
    if (signal == 1) {
        f = fopen("ethernaude.txt", "at");
        fprintf(f, "===== Send following ParamCCDIn to AskForExecuteCCDCommand =====\n");
        fclose(f);
        return (0);
    }
    if (signal == 2) {
        f = fopen("ethernaude.txt", "at");
        fprintf(f, "----- Read following ParamCCDOut -----\n");
               fclose(f);
        return (0);
    }
#endif
    return (1);
}
