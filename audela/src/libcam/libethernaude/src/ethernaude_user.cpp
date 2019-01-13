/* ethernaude_user.c
 *
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier10@tiscali.fr>
 *
 * Mettre ici le texte de la license.
 *
 */

/* === OS independant includes files === */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/* === OS dependant includes files === */
#if defined __linux__
#include <unistd.h>
#endif

#include "sysexp.h"
#include "ethernaude_user.h"
#include "ethernaude_util.h"

#if defined(OS_WIN)
HINSTANCE ethernaude;
#endif
#if defined __linux__ || defined(OS_MACOS)
void *ethernaude;
#endif
ETHERNAUDE_CALL *ETHERNAUDE_MAIN;
TParamCCD ParamCCDIn, ParamCCDOut;

/***************************************************************************/
/* open_ethernaude                                                         */
/***************************************************************************/
/* Load the Ethernaude Driver (which is a shared, dynamic library) and     */
/* import the entrypoint function.                                         */
/* Becareful, ethernet connexion is not performed at this step !           */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : library and import function are well loaded.                       */
/* =1 : error : did not find the library file.                             */
/*              causes can be an invalid pathname or a LD_LIBRARY_PATH not */
/*              initialized in the Unix environnements.                    */
/* =2 : error : libray file is well loaded but not the import function.    */
/*              see the ethernaude.h file and verify the value of the      */
/*              ETHERNAUDE_MAIN definition.                                */
/***************************************************************************/
int open_ethernaude(void)
{
#if defined(OS_WIN)
    ethernaude = LoadLibrary( ETHERNAUDE_NAME );
    if ( ( ethernaude != NULL ) ) {
        ETHERNAUDE_MAIN = (ETHERNAUDE_CALL *) GetProcAddress( ethernaude, ETHERNAUDE_MAINQ );
        if ( ETHERNAUDE_MAIN == NULL ) {
            close_ethernaude();
            return (2);
        }
    }
    else {
        return (1);
    }
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
    char s[1000];
//    char ss[1000];

    getcwd( s, 1000 );
//    printf( "Current dir name : %s\n", s );
//    sprintf( ss, "%s/%s/%s", s, "../bin", ETHERNAUDE_NAME );
//    ethernaude = dlopen( ss, RTLD_LAZY );
    ethernaude=dlopen( ETHERNAUDE_NAME, RTLD_LAZY );
    if ( ethernaude != NULL ) {
        ETHERNAUDE_MAIN = (ETHERNAUDE_CALL *) dlsym( ethernaude, ETHERNAUDE_MAINQ );
        if ( ETHERNAUDE_MAIN == NULL ) {
            close_ethernaude();
            return (2);
        }
    }
    else {
        return (1);
    }
#endif
    return (0);
}

/***************************************************************************/
/* close_ethernaude                                                        */
/***************************************************************************/
/* Close the Ethernaude Driver (which is a shared, dynamic library)        */
/* Becareful, ethernet connexion should be closed before this step !       */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : library anb import function are well closed.                       */
/***************************************************************************/
int close_ethernaude(void)
{
#if defined(OS_WIN)
    FreeLibrary(ethernaude);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
    dlclose(ethernaude);
#endif
    return 0;
}

#define DUMP_ParamCCDOut {\
   char res[200]; int dd;\
   for( dd=0; dd<ParamCCDOut.NbreParam; dd++ ) {\
      sprintf( res, "<LIBETHERNAUDE/new_ethernaude:%d> param[%d]='%s'", __LINE__, dd, ParamCCDOut.Param[dd]); util_log(res, 0);\
   }\
}


/***************************************************************************/
/* new_ethernaude                                                          */
/***************************************************************************/
/* Open and initialize parameters of an ethernaude connexion.              */
/*                                                                         */
/* Input parameters                                                        */
/*  unsigned short *ip : a pointer of 4 values containing the IP number    */
/*                       of the ethernaude box.                            */
/*                                                                         */
/* Output parameters                                                       */
/*  ethernaude_var *ethvar : the structure containing informations         */
/*                           collected during connexion (type of CCD, etc) */
/*                           The ethernaude_var strucutre is defined in    */
/*                           the ethernaude.h file.                        */
/*                                                                         */
/* Returned integer value :                                                */
/* =0 : all is right.                                                      */
/* =1 : error : did not find the library file.                             */
/*              causes can be an invalid pathname or a LD_LIBRARY_PATH not */
/*              initialized in the Unix environnements.                    */
/* =2 : error : libray file is well loaded but not the import function.    */
/*              see the ethernaude.h file and verify the value of the      */
/*              ETHERNAUDE_MAIN definition.                                */
/* ::cam::create ethernaude udp */
/***************************************************************************/
int new_ethernaude( struct new_ethernaude_inp *inparams, ethernaude_var * ethvar )
{
    int k, errnum;
    char result[MAXLENGTH + 1];
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    int paramtype;
#ifdef ETHERNAUDE_DEBUG
    remove("ethernaude.log");
#endif

    strcpy(ethvar->message, "");
    /* --- open and initialize the ethernaude driver cam::create ethernaude udp --- */
    if ( ( errnum = open_ethernaude() ) != 0 ) {
        if ( errnum == 1 ) {
            sprintf( ethvar->message, "Driver file %s not found", ETHERNAUDE_NAME) ;
        }
        else if ( errnum == 2 ) {
            sprintf( ethvar->message, "Function %s not found in driver file %s", ETHERNAUDE_MAINQ, ETHERNAUDE_NAME );
        }
        return errnum;
    }
    paramCCD_new( &ParamCCDIn );
    paramCCD_new( &ParamCCDOut);
    for ( k = 0; k < MAXCOMMAND; k++ ) {
        memset( result, ' ', MAXLENGTH );
        result[MAXLENGTH] = '\0';
        paramCCD_put( -1, result, &ParamCCDOut, 1 );
    }

    /* - GetDriverCCD_DLLinfos - */
    /* - it is the first function to call */
    paramCCD_clearall(&ParamCCDIn, 1);
    paramCCD_put(-1, "GetDriverCCD_DLLinfos", &ParamCCDIn, 1);
    util_log("", 1);
    for (k = 0; k < ParamCCDIn.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDIn);
        util_log(result, 0);
    }
    AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
    util_log("", 2);
    for (k = 0; k < ParamCCDOut.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDOut);
        util_log(result, 0);
#ifdef ETHERNAUDE_DEBUG
        printf("DLL=%s\n", result);
#endif
    }
    util_log("\n", 0);
    if (ParamCCDOut.NbreParam >= 1) {
        paramCCD_get(0, result, &ParamCCDOut);
        if (strcmp(result, "FAILED") == 0) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(ethvar->message, "GetDriverCCD_DLLinfos Failed\n%s", result);
            close_ethernaude();
            return (3);
        }
    }

    /* - catch the number ID of the camera - */
    strcpy(keyword, "Camera_ID");
    ethvar->Camera_ID = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->Camera_ID = atoi(value);
    }

    /* - how many setup parameters ? - */
    strcpy(keyword, "NbreParamSetup");
    ethvar->NbreParamSetup = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->NbreParamSetup = atoi(value);
    }

    /* - OPEN_Driver - */
    /* - it is the second function to call */
    paramCCD_clearall(&ParamCCDIn, 1);
    paramCCD_put(-1, "OPEN_Driver", &ParamCCDIn, 1);
    sprintf(result, "ParamSetup1=%d", inparams->ip[0]);
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    sprintf(result, "ParamSetup2=%d", inparams->ip[1]);
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    sprintf(result, "ParamSetup3=%d", inparams->ip[2]);
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    sprintf(result, "ParamSetup4=%d", inparams->ip[3]);
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    strcpy(result, "ParamSetup5=192");
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    strcpy(result, "ParamSetup6=FALSE");
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    if (inparams->shutterinvert == 0) {
        strcpy(result, "ParamSetup7=FALSE");
    }
    else {
        strcpy(result, "ParamSetup7=TRUE");
    }
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    if (inparams->canspeed < 0) {
        inparams->canspeed = 0;
    }
    if (inparams->canspeed > 150) {
        inparams->canspeed = 150;
    }
    sprintf(result, "ParamSetup8=%d", inparams->canspeed);
    paramCCD_put(-1, result, &ParamCCDIn, 1);
    /* --- add default values of extra parameters */
    for (k = 9; k <= ethvar->NbreParamSetup; k++) {
        sprintf(keyword, "ParamSetup%d", k);
        if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
            sprintf(result, "%s=%s", keyword, value);
            paramCCD_put(-1, result, &ParamCCDIn, 1);
        }
    }
    util_log("", 1);
    for (k = 0; k < ParamCCDIn.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDIn);
        util_log(result, 0);
    }
    AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
    util_log("", 2);
    for (k = 0; k < ParamCCDOut.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDOut);
        util_log(result, 0);
    }
    util_log("\n", 0);
    if (ParamCCDOut.NbreParam >= 1) {
        paramCCD_get(0, result, &ParamCCDOut);
        if (strcmp(result, "FAILED") == 0) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(ethvar->message, "OPEN_Driver Failed \n%s\nVerify that ethernaude is on and has IP %d.%d.%d.%d", result, inparams->ip[0], inparams->ip[1], inparams->ip[2], inparams->ip[3]);
            close_ethernaude();
            return (4);
        }
    }

    DUMP_ParamCCDOut;

    /* - how many CCD are supported by this camera ? - */

    strcpy(keyword, "CCDDrivenAmount");
    ethvar->CCDDrivenAmount = 0;
    k = util_param_search(&ParamCCDOut, keyword, value, &paramtype);
    sprintf(result, "<LIBETHERNAUDE/new_ethernaude> param_util_search = %d (keyword='%s';value='%s';paramtype=%d)",k,keyword,value,paramtype); util_log(result, 0);
    if (k == 0) {
        ethvar->CCDDrivenAmount = atoi(value);
        sprintf(result, "<LIBETHERNAUDE/new_ethernaude> ethvar->CCDDrivenAmount = %d",ethvar->CCDDrivenAmount); util_log(result, 0);
    }

    /* - read current systeme name - */
    strcpy(keyword, "SystemName");
    strcpy(ethvar->SystemName, "");
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        strcpy(ethvar->SystemName, value);
    }

    /* - GetCCD_infos for the CCD number 1 - */
    /* - it is the third function to call */
    paramCCD_clearall(&ParamCCDIn, 1);
    paramCCD_put(-1, "GetCCD_infos", &ParamCCDIn, 1);
    paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
    util_log("", 1);
    for (k = 0; k < ParamCCDIn.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDIn);
        util_log(result, 0);
    }
    AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
    util_log("", 2);
    for (k = 0; k < ParamCCDOut.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDOut);
        util_log(result, 0);
    }
    util_log("\n", 0);
    if (ParamCCDOut.NbreParam >= 1) {
        paramCCD_get(0, result, &ParamCCDOut);
        if (strcmp(result, "FAILED") == 0) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(ethvar->message, "GetCCD_infos Failed\n%s", result);
            close_ethernaude();
            return (5);
        }
    }

    /* - how many chronograms are supported ? - */
    strcpy(keyword, "InfoCCD_ClockModes");
    ethvar->InfoCCD_ClockModes = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->InfoCCD_ClockModes = atoi(value);
    }
    /* - InfoCCD_NAME - */
    strcpy(keyword, "InfoCCD_NAME");
    strcpy(ethvar->InfoCCD_NAME, "");
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        strcpy(ethvar->InfoCCD_NAME, value);
    }
    /* - InfoCCD_MaxExposureTime in microseconds - */
    strcpy(keyword, "InfoCCD_MaxExposureTime");
    ethvar->InfoCCD_MaxExposureTime = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->InfoCCD_MaxExposureTime = atoi(value);
    }
    /* - InfoCCD_PixelsSizeX in micrometer - */
    strcpy(keyword, "InfoCCD_PixelsSizeX");
    ethvar->InfoCCD_PixelsSizeX = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->InfoCCD_PixelsSizeX = atoi(value);
    }
    /* - InfoCCD_PixelsSizeY in micrometer - */
    strcpy(keyword, "InfoCCD_PixelsSizeY");
    ethvar->InfoCCD_PixelsSizeY = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->InfoCCD_PixelsSizeY = atoi(value);
    }
    /* - InfoCCD_HasTDICaps - */
    strcpy(keyword, "InfoCCD_HasTDICaps");
    ethvar->InfoCCD_HasTDICaps = 0;
    k = util_param_search(&ParamCCDOut, keyword, value, &paramtype);
    sprintf(result, "<LIBETHERNAUDE/new_ethernaude> param_util_search = %d (keyword='%s';value='%s';paramtype=%d)",k,keyword,value,paramtype); util_log(result, 0);
    if (k == 0) {
        if (!strcmp(value,"TRUE")) {
        ethvar->InfoCCD_HasTDICaps = 1;
        }
        sprintf(result, "<LIBETHERNAUDE/new_ethernaude> ethvar->InfoCCD_HasTDICaps = %d",ethvar->InfoCCD_HasTDICaps); util_log(result, 0);
    }
    /* - InfoCCD_HasVideoCaps - */
    strcpy(keyword, "InfoCCD_HasVideoCaps");
    ethvar->InfoCCD_HasVideoCaps = 0;
    k = util_param_search(&ParamCCDOut, keyword, value, &paramtype);
    sprintf(result, "<LIBETHERNAUDE/new_ethernaude> param_util_search = %d (keyword='%s';value='%s';paramtype=%d)",k,keyword,value,paramtype); util_log(result, 0);
    if (k == 0) {
        if (!strcmp(value,"TRUE")) {
            ethvar->InfoCCD_HasVideoCaps = 1;
            sprintf(result, "<LIBETHERNAUDE/new_ethernaude> ethvar->InfoCCD_HasVideoCaps = %d",ethvar->InfoCCD_HasVideoCaps); util_log(result, 0);
        }
    }
    /* - InfoCCD_HasRegulationTempCaps - */
    strcpy(keyword, "InfoCCD_HasRegulationTempCaps");
    ethvar->InfoCCD_HasRegulationTempCaps = 0;
    k = util_param_search(&ParamCCDOut, keyword, value, &paramtype);
    sprintf(result, "<LIBETHERNAUDE/new_ethernaude> param_util_search = %d (keyword='%s';value='%s';paramtype=%d)",k,keyword,value,paramtype); util_log(result, 0);
    if (k == 0) {
        if (!strcmp(value,"TRUE")) {
            ethvar->InfoCCD_HasRegulationTempCaps = 1;
        }
        sprintf(result, "<LIBETHERNAUDE/new_ethernaude> ethvar->InfoCCD_HasRegulationTempCaps = %d",ethvar->InfoCCD_HasRegulationTempCaps); util_log(result, 0);
    }
    /* - InfoCCD_HasEventAude - */
    strcpy(keyword, "InfoCCD_HasGPSDatation");
    ethvar->InfoCCD_HasGPSDatation = 0;
    k = util_param_search(&ParamCCDOut, keyword, value, &paramtype);
    sprintf(result, "<LIBETHERNAUDE/new_ethernaude> param_util_search = %d (keyword='%s';value='%s';paramtype=%d)",k,keyword,value,paramtype); util_log(result, 0);
    if (k == 0) {
        if (!strcmp(value,"TRUE")) {
            ethvar->InfoCCD_HasGPSDatation = 1;
        }
        sprintf(result, "<LIBETHERNAUDE/new_ethernaude> ethvar->InfoCCD_HasGPSDatation = %d",ethvar->InfoCCD_HasGPSDatation); util_log(result, 0);
    }

    /* - GetClockModes for the CCD number 1 and the clock mode number 1 - */
    /* - it is the fourth function to call */
    paramCCD_clearall(&ParamCCDIn, 1);
    paramCCD_put(-1, "GetClockModes", &ParamCCDIn, 1);
    paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
    paramCCD_put(-1, "ClockMode=1", &ParamCCDIn, 1);
    util_log("", 1);
    for (k = 0; k < ParamCCDIn.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDIn);
        util_log(result, 0);
    }
    AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
    util_log("", 2);
    for (k = 0; k < ParamCCDOut.NbreParam; k++) {
        paramCCD_get(k, result, &ParamCCDOut);
        util_log(result, 0);
    }
    util_log("\n", 0);
    if (ParamCCDOut.NbreParam >= 1) {
        paramCCD_get(0, result, &ParamCCDOut);
        if (strcmp(result, "FAILED") == 0) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(ethvar->message, "GetClockModes failed\n%s", result);
            close_ethernaude();
            return (5);
        }
    }

    /* - number of photosites for this CCD - */
    strcpy(keyword, "WidthPixels");
    ethvar->WidthPixels = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->WidthPixels = atoi(value);
    }
    strcpy(keyword, "HeightPixels");
    ethvar->HeightPixels = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->HeightPixels = atoi(value);
    }
    strcpy(keyword, "PixelsPrescanX");
    ethvar->PixelsPrescanX = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->PixelsPrescanX = atoi(value);
    }
    strcpy(keyword, "PixelsPrescanY");
    ethvar->PixelsPrescanY = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->PixelsPrescanY = atoi(value);
    }
    strcpy(keyword, "PixelsOverscanX");
    ethvar->PixelsOverscanX = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->PixelsOverscanX = atoi(value);
    }
    strcpy(keyword, "PixelsOverscanY");
    ethvar->PixelsOverscanY = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->PixelsOverscanY = atoi(value);
    }
    strcpy(keyword, "BitPerPixels");
    ethvar->BitPerPixels = 0;
    if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
        ethvar->BitPerPixels = atoi(value);
    }

    return 0;
}

/***************************************************************************/
/* delete_ethernaude                                                       */
/***************************************************************************/
/* free and close parameters of an ethernaude connexion.                   */
/***************************************************************************/
int delete_ethernaude()
{
    int k;
    char result[MAXLENGTH + 1];
    /* - CLOSE_Driver */
    paramCCD_clearall(&ParamCCDIn, 1);
    paramCCD_put(-1, "CLOSE_Driver", &ParamCCDIn, 1);
    util_log("", 1);
    for (k = 0; k < ParamCCDIn.NbreParam; k++) {
    paramCCD_get(k, result, &ParamCCDIn);
    util_log(result, 0);
    }
    AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
    util_log("", 2);
    for (k = 0; k < ParamCCDOut.NbreParam; k++) {
    paramCCD_get(k, result, &ParamCCDOut);
    util_log(result, 0);
    }
    util_log("\n", 0);
    /* delete structures */
    paramCCD_delete(&ParamCCDIn);
    paramCCD_delete(&ParamCCDOut);
    close_ethernaude();
    return (0);
}

