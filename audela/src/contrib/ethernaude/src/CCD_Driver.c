/*

  CCD_Driver.c

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
#include "ethernaude.h"
#include "ethernaude_make.h"
#include "ethernaude_util.h"
#include "etherlinkudp.h"

/* === Global variables ===*/
ethernaude_var ethvar;
TParamCCD ParamCCDIn, ParamCCDOut;

/* === CCD_Driver active functions === */
int GetDriverCCD_DLLinfos(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int OPEN_Driver(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int GetCCD_infos(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int GetClockModes(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int InitExposure(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int AbortExposure(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int CCDStatus(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int StartReadoutCCD(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);
int CLOSE_Driver(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut);

/* === Ethernaude Dialog functions === */
int ethernaude_0x00(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x01(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x02(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x03(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x04(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x05(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x06(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x07(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x08(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x09(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x0A(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0x0C(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);
int ethernaude_0xFA(ethernaude_var * ethvar, TParamCCD * ParamCCDOut);


void ethernaude_main(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = This function begins each CCD_Driver call.            */
/* ========================================================*/
/* It sends to the corresponding function.                 */
/* ========================================================*/
{
    int errnum;
    char ligne[1000];

    /* --- Copy empty strings in the output structure --- */
    errnum = paramCCD_clearall(ParamCCDOut, 0);
    if (errnum != 0) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "%dth element of ParamCCDOut is a NULL pointer", errnum);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
        return;
    }

    /* --- Case of no command in the input structure --- */
    if (ParamCCDIn->Param[0] == NULL) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        paramCCD_put(-1, "No input command", ParamCCDOut, 0);
    return;
    }
    LOG_DEBUG("%f Commande=%s\n", GetTimeStamp(), ParamCCDIn->Param[0]);

    /* --- Go to the function, relative to the input command --- */
    if (strcmp(ParamCCDIn->Param[0], "GetDriverCCD_DLLinfos") == 0) {
        GetDriverCCD_DLLinfos(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "OPEN_Driver") == 0) {
        OPEN_Driver(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "GetCCD_infos") == 0) {
        GetCCD_infos(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "GetClockModes") == 0) {
        GetClockModes(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "InitExposure") == 0) {
        InitExposure(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "CCDStatus") == 0) {
        CCDStatus(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "StartReadoutCCD") == 0) {
        StartReadoutCCD(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "AbortExposure") == 0) {
        AbortExposure(ParamCCDIn, ParamCCDOut);
    } else if (strcmp(ParamCCDIn->Param[0], "CLOSE_Driver") == 0) {
        CLOSE_Driver(ParamCCDIn, ParamCCDOut);
    } else {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "%s is not a known command", ParamCCDIn->Param[0]);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
    }
    return;
}

int GetDriverCCD_DLLinfos(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
/* ========================================================*/
{
    LOG_INFO( "%s ParamCCDIn=%p ParamCCDOut=%p\n", "GetDriverCCD_DLLinfos", ParamCCDIn, ParamCCDOut );
    char ligne[MAXLENGTH + 1];
    char version[MAXLENGTH + 1];
    /* --- Complete some elements of ethernaude_var structure --- */
    sprintf(version, "1.01c Ethernaude DLL %s", __DATE__);
    ethvar.Camera_ID = 46;
    ethvar.NbreParamSetup = 8;
    /* --- returned parameters --- */
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    sprintf(ligne, "VersionDLL=%s", version);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    paramCCD_put(-1, "SignatureDLL=0x7711DD22", ParamCCDOut, 0);
    sprintf(ligne, "Camera_ID= %d", ethvar.Camera_ID);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "NbreParamSetup=%d", ethvar.NbreParamSetup);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup1 = #Adresse IP 1 (octet le plus fort) : #INT#134#0#255", ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup2 = #Adresse IP 2 : #INT#171#0#255", ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup3 = #Adresse IP 3 : #INT#73#0#255", ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup4 = #Adresse IP 4 (octet le plus faible) : #INT#46#0#255", ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup5 = #UDP Service : #INT#192#0#255", ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup6 = #Enable debug file (ccd_driver.log) : #BOOL#FALSE#", ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup7 = #Invert Shutter behavior : #BOOL#FALSE#", ParamCCDOut, 0);
    paramCCD_put(-1, "ParamSetup8 = #Pixel readout speed : #INT#4#0#150", ParamCCDOut, 0);
    sprintf(ligne, "SystemName= [%s]", version);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    return 0;
}

int OPEN_Driver(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
/* ========================================================*/
{
    LOG_NOTICE( "%s ParamCCDIn=%p ParamCCDOut=%p\n", "OPEN_Driver", ParamCCDIn, ParamCCDOut );
    int errnum, k;
    char ligne[MAXLENGTH + 1];
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    int paramtype;
    int destport;
    int inverseshutter;
    int canspeed;
    char destIP[50];
    unsigned char ip[4];

    /* --- Return value of IP from ParamCCDIn structure --- */
    for (k = 1; k <= 4; k++) {
        sprintf(keyword, "ParamSetup%d", k);
        ip[k - 1] = 0;
        if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
            ip[k - 1] = (unsigned char) atoi(value);
        }
        else {
            paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
            sprintf(ligne, "No ParamSetup%d", k);
            paramCCD_put(-1, ligne, ParamCCDOut, 0);
            return k;
        }
    }

    /* --- Return value of port from ParamCCDIn structure --- */
    strcpy(keyword, "ParamSetup5");
    destport = 0;
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        destport = (unsigned short) atoi(value);
    } else {
        destport = 192;		/* default value */

/*    paramCCD_put(-1,"FAILED",ParamCCDOut,0);
      paramCCD_put(-1,"No ParamSetup5",ParamCCDOut,0);
      return 5;    */
    }

    /* --- Return value of inverseshutter from ParamCCDIn structure --- */
    strcpy(keyword, "ParamSetup7");
    inverseshutter = 1;
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        if (strcmp(value, "TRUE") == 0) {
            inverseshutter = 0;
        }
    }
    else {
        inverseshutter = 1;	/* default value  */

/*      paramCCD_put(-1,"FAILED",ParamCCDOut,0);
      paramCCD_put(-1,"No ParamSetup7",ParamCCDOut,0);
      return 7; */
    }

    /* --- Return value of speed of CAN from ParamCCDIn structure --- */
    strcpy(keyword, "ParamSetup8");
    canspeed = 4;
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        canspeed = (unsigned short) atoi(value);
    }
    else {
        canspeed = 4;		/* default value  */
/*      paramCCD_put(-1,"FAILED",ParamCCDOut,0);
      paramCCD_put(-1,"No ParamSetup8",ParamCCDOut,0);
      return 7;  */
    }
    ethvar.CanSpeed = canspeed;

    /* --- Open the UDP socket connection --- */
    sprintf(destIP, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
    Init_TEtherLinkUDP(destIP);
    /* --- Send a reset to EthernAude --- */

    errnum = ethernaude_0x00(&ethvar, ParamCCDOut);

    if (errnum != 0) {
        return errnum;
    }

    /* inverse shutter port if necessary */
    if (inverseshutter == 0) {
        errnum = ethernaude_0x05(&ethvar, ParamCCDOut);
        if (errnum != 0) {
            return errnum;
        }
    }

    /* set the speed of CAN */
    errnum = ethernaude_0x0C(&ethvar, ParamCCDOut);
    if (errnum != 0) {
        return errnum;
    }

    ethvar.CCDDrivenAmount = 1;
    strcpy(ethvar.SystemName, "Ethernaude");
    /* --- Returned parameters --- */
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    sprintf(ligne, "CCDDrivenAmount = %d", ethvar.CCDDrivenAmount);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "SystemName = %s", ethvar.SystemName);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "SX52_Audine_Release = %s", ethvar.SX52_Audine_Release);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "SX52_Ethernet_Release = %s", ethvar.SX52_Ethernet_Release);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    strcpy(ethvar.CCDStatus, "Idle");

    return 0;
}

int GetCCD_infos(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
/* ========================================================*/
{
    int errnum, ccdnb;
    char ligne[MAXLENGTH + 1];
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    int paramtype;

    /* --- Return value of CCD# from ParamCCDIn strcuture --- */
    strcpy(keyword, "CCD#");
    ccdnb = 0;
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        ccdnb = atoi(value);
    }
    else {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        paramCCD_put(-1, "No CCD#", ParamCCDOut, 0);
        return 1;
    }
    if (ccdnb > ethvar.CCDDrivenAmount) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "Bad CCD#=%d. Only %d CCDs", ccdnb, ethvar.CCDDrivenAmount);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
        return 2;
    }
    if (ccdnb <= 0) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "Bad CCD#=%d. Must be between 1 and %d", ccdnb, ethvar.CCDDrivenAmount);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
        return 3;
    }
    /* --- Ask Ethernaude to ID_CCD informations and   --- */
    /* --- converts them to ethernaude_var structure.  --- */
/*   errnum=ethernaude_0x03(&ethvar,ParamCCDOut);
   if (errnum!=0) {
      return errnum;
   }
*/
    /* --- Complete some elements of ethernaude_var structure --- */
    errnum = ethernaude_0x03(&ethvar, ParamCCDOut);
    if (errnum != 0) {
        return errnum;
    }
    /* --- Complete some elements of ethernaude_var structure --- */
    ethvar.InfoCCD_ClockModes = 1;
/*    ethvar.PixelsOverscanY = 0;   */
    ethvar.InfoCCD_MaxExposureTime = 10800000;
    /* --- Returned Parameters --- */
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    if (ethvar.Camera_ID == 1) {
        strcpy(ligne, "InfoCCD_NAME = Kaf0400");
    }
    else if (ethvar.Camera_ID == 2) {
        strcpy(ligne, "InfoCCD_NAME = Kaf1600");
    }
    else if (ethvar.Camera_ID == 3) {
        strcpy(ligne, "InfoCCD_NAME = Kaf3200");
    }
    else {
        sprintf(ligne, "InfoCCD_NAME = %s", ethvar.InfoCCD_NAME);
    }
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    paramCCD_put(-1, "InfoCCD_HasTDICaps = TRUE", ParamCCDOut, 0);
    paramCCD_put(-1, "InfoCCD_HasRegulationTempCaps = TRUE", ParamCCDOut, 0);
    paramCCD_put(-1, "InfoCCD_ClockModes=1", ParamCCDOut, 0);
    sprintf(ligne, "InfoCCD_MaxExposureTime = %d", ethvar.InfoCCD_MaxExposureTime);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    if (ethvar.InfoCCD_IsGuidingCCD == 1) {
        paramCCD_put(-1, "InfoCCD_IsGuidingCCD =TRUE", ParamCCDOut, 0);
    }
    else {
        paramCCD_put(-1, "InfoCCD_IsGuidingCCD =FALSE", ParamCCDOut, 0);
    }
    paramCCD_put(-1, "InfoCCD_HasEmbeddedShutter = TRUE", ParamCCDOut, 0);
    paramCCD_put(-1, "InfoCCD_IsColorCCD = FALSE", ParamCCDOut, 0);
    paramCCD_put(-1, "InfoCCD_IsFrameTransferCCD =FALSE", ParamCCDOut, 0);
    sprintf(ligne, "InfoCCD_PixelsSizeX = %d", ethvar.InfoCCD_PixelsSizeX);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "InfoCCD_PixelsSizeY = %d", ethvar.InfoCCD_PixelsSizeY);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    paramCCD_put(-1, "InfoCCD_Shutter_standalone_drivableCaps = FALSE", ParamCCDOut, 0);
    paramCCD_put(-1, "InfoCCD_HasVideoCaps = TRUE", ParamCCDOut, 0);
    return 0;
}

int GetClockModes(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
/* ========================================================*/
{
    int ccdnb, clocknb;
    char ligne[MAXLENGTH + 1];
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    int paramtype;

    /* --- Return value of CCD# from ParamCCDIn strcuture --- */
    strcpy(keyword, "CCD#");
    ccdnb = 0;
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
    	ccdnb = atoi(value);
    }
    else {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        paramCCD_put(-1, "No CCD#", ParamCCDOut, 0);
        return 1;
    }
    if (ccdnb > ethvar.CCDDrivenAmount) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "Bad CCD#=%d. Only %d CCDs", ccdnb, ethvar.CCDDrivenAmount);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
        return 2;
    }
    if (ccdnb <= 0) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "Bad CCD#=%d. Must be between 1 and %d", ccdnb, ethvar.CCDDrivenAmount);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
        return 3;
    }
    /* --- Return value of ClockMode from ParamCCDIn strcuture --- */
    strcpy(keyword, "ClockMode");
    clocknb = 0;
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        clocknb = atoi(value);
    }
    else {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        paramCCD_put(-1, "No ClockMode", ParamCCDOut, 0);
	return 1;
    }
    if (clocknb > ethvar.InfoCCD_ClockModes) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "Bad ClockMode=%d. Only %d ClockModes", ccdnb, ethvar.InfoCCD_ClockModes);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
        return 2;
    }
    if (ccdnb <= 0) {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        sprintf(ligne, "Bad ClockMode=%d. Must be between 1 and %d", ccdnb, ethvar.InfoCCD_ClockModes);
        paramCCD_put(-1, ligne, ParamCCDOut, 0);
        return 3;
    }
    /* --- Ask Ethernaude to ID_CCD informations and   --- */
    /* --- converts them to ethernaude_var structure.  --- */
/*   errnum=ethernaude_0x03(&ethvar,ParamCCDOut);
   if (errnum!=0) {
      return errnum;
   }
*/
    /* --- Complete some elements of ethernaude_var structure --- */
    ethvar.InfoCCD_ClockModes = 1;
/*    ethvar.PixelsOverscanY = 0;  */
    ethvar.InfoCCD_MaxExposureTime = 10800000;
    /* --- Returned Parameters --- */
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    paramCCD_put(-1, "ModeName = Standard", ParamCCDOut, 0);
    sprintf(ligne, "WidthPixels = %d", ethvar.WidthPixels);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "HeightPixels = %d", ethvar.HeightPixels);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "PixelsPrescanX = %d", ethvar.PixelsPrescanX);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "PixelsPrescanY = %d", ethvar.PixelsPrescanY);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "PixelsOverscanX = %d", ethvar.PixelsOverscanX);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    if (ethvar.Camera_ID == 1) {
    sprintf(ligne, "PixelsOverscanY = %d", 4);
    } else if (ethvar.Camera_ID == 2) {
    sprintf(ligne, "PixelsOverscanY = %d", 4);
    } else if (ethvar.Camera_ID == 3) {
    sprintf(ligne, "PixelsOverscanY = %d", 4);
    }
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    paramCCD_put(-1, "SpeedReadout = 150", ParamCCDOut, 0);
    paramCCD_put(-1, "NumberPorts = 1", ParamCCDOut, 0);
    paramCCD_put(-1, "GainPort1 = 4", ParamCCDOut, 0);
    //sprintf(ligne, "InfoCCD_PixelsSizeX = %d", ethvar.InfoCCD_PixelsSizeX);
    //sprintf(ligne, "InfoCCD_PixelsSizeY = %d", ethvar.InfoCCD_PixelsSizeY);
    //paramCCD_put(-1, ligne, ParamCCDOut, 0);
    sprintf(ligne, "BitPerPixels = %d", ethvar.BitPerPixels);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    paramCCD_put(-1, "HasWindowingCaps = TRUE", ParamCCDOut, 0);
    paramCCD_put(-1, "HasBinningCaps = TRUE", ParamCCDOut, 0);
    paramCCD_put(-1, "AllBinningPossible = TRUE", ParamCCDOut, 0);
    paramCCD_put(-1, "HasTDIBinningCaps = TRUE", ParamCCDOut, 0);
    paramCCD_put(-1, "TDIBinningXMax = 2", ParamCCDOut, 0);
    paramCCD_put(-1, "TDIBinningYMax = 64", ParamCCDOut, 0);
    return 0;
}

int InitExposure(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
 /**/
/* ========================================================*/
{
    int errnum;
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    int paramtype;
    int CCDno, ClockMode, EExposure, X1, X2, Y1, Y2, BinningX, BinningY, ShutterOpen;

    strcpy(keyword, "CCD#");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	CCDno = (int) atoi(value);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "No CCD# parameter", ParamCCDOut, 0);
	return 1;
    }
    strcpy(keyword, "ClockMode");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	ClockMode = (int) atoi(value);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "No ClockMode parameter", ParamCCDOut, 0);
	return 1;
    }
    strcpy(keyword, "Exposure");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	EExposure = (int) atoi(value);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "No Exposure parameter", ParamCCDOut, 0);
	return 1;
    }
    strcpy(keyword, "X1");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	X1 = (int) atoi(value);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "No X1 parameter", ParamCCDOut, 0);
	return 1;
    }
    strcpy(keyword, "X2");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	X2 = (int) atoi(value);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "No X2 parameter", ParamCCDOut, 0);
	return 1;
    }
    strcpy(keyword, "Y1");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	Y1 = (int) atoi(value);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "No Y1 parameter", ParamCCDOut, 0);
	return 1;
    }
    strcpy(keyword, "Y2");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	Y2 = (int) atoi(value);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "No Y2 parameter", ParamCCDOut, 0);
	return 1;
    }
    strcpy(keyword, "BinningX");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	BinningX = (int) atoi(value);
    } else {
	BinningX = 1;		/* default value  */
/*      paramCCD_put(-1,"FAILED",ParamCCDOut,0);
      paramCCD_put(-1,"No BinningX parameter",ParamCCDOut,0);
      return 1;   */
    }
    strcpy(keyword, "BinningY");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	BinningY = (int) atoi(value);
    } else {
	BinningY = 1;		/* default value  */
/*      paramCCD_put(-1,"FAILED",ParamCCDOut,0);
      paramCCD_put(-1,"No BinningY parameter",ParamCCDOut,0);
      return 1;   */
    }
    strcpy(keyword, "ShutterOpen");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
	ShutterOpen = (int) atoi(value);
    } else {
	ShutterOpen = 1;	/* default value  */
/*      paramCCD_put(-1,"FAILED",ParamCCDOut,0);
      paramCCD_put(-1,"No ShutterOpen parameter",ParamCCDOut,0);
      return 1;  */
    }
    ethvar.nbwipe = (unsigned char) 4;
    errnum = ethernaude_0x01(&ethvar, ParamCCDOut);
    if (errnum != 0) {
	return errnum;
    }
    ethvar.Exposure = EExposure;
    ethvar.ShutterOpen = ShutterOpen;
    errnum = ethernaude_0x02(&ethvar, ParamCCDOut);
    if (errnum != 0) {
	return errnum;
    }
    ethvar.CCDno = CCDno;
    ethvar.ClockMode = ClockMode;
    ethvar.X1 = X1;
    ethvar.X2 = X2;
    ethvar.Y1 = Y1;
    ethvar.Y2 = Y2;
    ethvar.BinningX = BinningX;
    ethvar.BinningY = BinningY;
    ethvar.ShutterOpen = ShutterOpen;
    /* --- Returned parameters --- */
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    return 0;
}

int AbortExposure(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Stop the exposure and return the time of exposure    =*/
/* = really done.                                         =*/
/* ========================================================*/
/* ========================================================*/
{
    int errnum;
    errnum = ethernaude_0xFA(&ethvar, ParamCCDOut);
    if (errnum != 0) {
	return errnum;
    }
    return 0;
}

int CCDStatus(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
 /**/
/* ========================================================*/
{
    char ligne[MAXLENGTH + 1];
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    int paramtype;
    int CCDno;

    strcpy(keyword, "CCD#");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        CCDno = (int) atoi(value);
    } else {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        paramCCD_put(-1, "No CCD# parameter", ParamCCDOut, 0);
        return 1;
    }
    /* --- Returned parameters --- */
    strcpy(ethvar.CCDStatus, "Idle");
    if (Exposure_Pending == true)
        strcpy(ethvar.CCDStatus, "EXPOSURE_PENDING");
    if (Exposure_Completed == true)
        strcpy(ethvar.CCDStatus, "EXPOSURE_COMPLETED");
    if (Readout_in_Progress == true)
        strcpy(ethvar.CCDStatus, "READOUT_in_PROGRESS");
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    #ifdef CCDDRIVER_DEBUG
    printf("%f CCDStatus=%s\n", GetTimeStamp(), ethvar.CCDStatus);
    #endif
    sprintf(ligne, "%s", ethvar.CCDStatus);
    paramCCD_put(-1, ligne, ParamCCDOut, 0);
    /*
       EXPOSURE_COMPLETED

       READOUT_in_PROGRESS
       ReadoutProgression = 97

       READOUT_COMPLETED
     */
    return 0;
}

int StartReadoutCCD(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
 /**/
/* ========================================================*/
{
    LOG_NOTICE( "%s ParamCCDIn=%p ParamCCDOut=%p\n", "StartReadoutCCD", ParamCCDIn, ParamCCDOut );
    int errnum;
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    int paramtype;
    int CCDno = 0;
    unsigned char * ImageAddress = 0;

    strcpy(keyword, "CCD#");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        CCDno = (int) atoi(value);
    }
    else {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        paramCCD_put(-1, "No CCD# parameter", ParamCCDOut, 0);
        return 1;
    }
    strcpy(keyword, "ImageAddress");
    if (util_param_search(ParamCCDIn, keyword, value, &paramtype) == 0) {
        LOG_DEBUG( "%s %s\n", "value=", value );
        ImageAddress = (unsigned char *)strtoul( value, 0, 0 );
    }
    else {
        paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
        paramCCD_put(-1, "No ImageAddress parameter", ParamCCDOut, 0);
        return 1;
    }
    /* on lance la lecture du CCD */
    ethvar.ImageAddress = ImageAddress;
    errnum = ethernaude_0x04(&ethvar, ParamCCDOut);
    if (errnum != 0) {
        return errnum;
    }
    /* --- Returned parameters --- */
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    /* TimeStamp=2452764.43212581 a ecrire */
    paramCCD_put(-1, "TimeStamp=2452764.43212581", ParamCCDOut, 0);
    return 0;
}

int CLOSE_Driver(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = CCD_Driver active function                           =*/
/* ========================================================*/
/* ========================================================*/
{
    /* --- Close the UDP socket connection --- */
    Close_TEtherLinkUDP();
    /* --- Returned parameters --- */
    paramCCD_put(-1, "SUCCES", ParamCCDOut, 0);
    return 0;
}

int ethernaude_0x00(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Reset and returns EthIO version infos.                  */
/* ========================================================*/
{
    unsigned char message[65536];
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Ask Ethernaude to Reset --- */
    if (EthernaudeReset(message)) {
        while (Info_Received() == 0);
    }
    if (EthernaudeReset(message)) {
		/* --- Receive Reset informations --- */
		while (Info_Received() == 0);
    }
	else {
		paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
		paramCCD_put(-1, "Cause is : Error sending Reset to socket", ParamCCDOut, 0);
		return 1;
    }
    /* --- Converts Reset infos to ethernaude_var structure  --- */
    sprintf(ethvar->SX52_Ethernet_Release, "%d.%02d", (int) message[0], (int) message[1]);
    return 0;
}

int ethernaude_0x01(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Clear the CCD.                                          */
/* ========================================================*/
{
    unsigned char message[65536];
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Ask Ethernaude to --- */
    if (ClearCCD(message, ethvar->nbwipe)) {
	/* --- Receive informations --- */
	while (Info_Received() == 0);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "Cause is : Error sending ClearCCD to socket", ParamCCDOut, 0);
	return 1;
    }
    /* --- Converts infos to ethernaude_var structure  --- */
    /* decoder (int)message[0] */
    return 0;
}

int ethernaude_0x02(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Timer for exposure                                      */
/* ========================================================*/
{
    unsigned char message[65536];
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Ask Ethernaude to --- */
    if (Exposure(message, ethvar->Exposure, ethvar->ShutterOpen)) {
	/* --- Receive informations --- */
	/* while (Info_Received ()==0) */ ;
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "Cause is : Error sending Exposure to socket", ParamCCDOut, 0);
	return 1;
    }
    /* --- Converts infos to ethernaude_var structure  --- */
    /* decoder (int)message[0] (int)message[1] (int)message[2] */
    return 0;
}

int ethernaude_0x03(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Returns the name of the CCD camera and other infos.     */
/* ========================================================*/
{
    unsigned char message[65536];
    int k;
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Ask Ethernaude to ID_CCD informations --- */
    if (Identity(message)) {
	/* --- Receive ID_CCD informations --- */
	while (Info_Received() == 0);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "Cause is : Error sending ID_CCD to socket", ParamCCDOut, 0);
	return 1;
    }
    /* --- Converts ID_CCD infos to ethernaude_var structure  --- */
    ethvar->Camera_ID = (int) (message[0]);
    ethvar->PixelsPrescanX = (int) (message[1]);
    ethvar->PixelsOverscanX = (int) (message[2]);
    ethvar->InfoCCD_PixelsSizeX = ((int) (message[3]))*1000 + ((int) (message[4]) * 10); /* dim in nm */
    ethvar->InfoCCD_PixelsSizeY = ((int) (message[3]))*1000 + ((int) (message[4]) * 10);
    ethvar->WidthPixels = ((int) (message[5]) << 8) + (int) (message[6]);
    ethvar->HeightPixels = ((int) (message[7]) << 8) + (int) (message[8]);
    ethvar->BitPerPixels = (int) (message[11]);
    ethvar->InfoCCD_IsGuidingCCD = (int) (message[12]);
    for (k = 13; k <= 24; k++) {
	ethvar->InfoCCD_NAME[k - 13] = message[k];
    }
    ethvar->InfoCCD_NAME[12] = '\0';
    sprintf(ethvar->SX52_Audine_Release, "%d.%02d", (int) (message[26]), (int) (message[25]));
    ethvar->PixelsPrescanY = (int) (message[27]);
    ethvar->PixelsOverscanY = (int) (message[27]);
    return 0;
}

int ethernaude_0x04(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Read an image                                           */
/* ========================================================*/
{
    LOG_INFO( "%s ParamCCDIn=%p ParamCCDOut=%p\n", "ethernaude_0x04", ethvar, ParamCCDOut );
    LOG_DEBUG( "ImageAddress=%p\n", ethvar->ImageAddress );
    unsigned char *p;
    int dx, dy;
    paramCCD_clearall(ParamCCDOut, 0);
    p = (unsigned char *) ethvar->ImageAddress;
    dx = (ethvar->X2 - ethvar->X1 + 1) / ethvar->BinningX;
    dy = (ethvar->Y2 - ethvar->Y1 + 1) / ethvar->BinningY;
    /* --- Ask Ethernaude to --- */
    strcpy(ethvar->CCDStatus, "READOUT_in_PROGRESS");
    Readout(p, (unsigned char) ethvar->BinningX, (unsigned char) ethvar->BinningY, ethvar->X1, ethvar->Y1, dx, dy);
    /* --- Receive informations --- */
    while (Info_Received() == 0);
    /* on retourne les pixels de l'image */
    strcpy(ethvar->CCDStatus, "READOUT_COMPLETED");
    /* --- Converts infos to ethernaude_var structure  --- */
    /* decoder (int)message[0] (int)message[1] (int)message[2] */
    return 0;
}

int ethernaude_0x05(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Inverse shutter                                         */
/* ========================================================*/
{
    unsigned char message[65536];
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Ask Ethernaude to inverse shutter port --- */
    if (ShutterChange(message)) {
	/* --- Receive ID_CCD informations --- */
	while (Info_Received() == 0);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "Cause is : Error changing shutter port", ParamCCDOut, 0);
	return 1;
    }
    return 0;
}

int ethernaude_0x06(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Initialize inputs/outputs.                              */
/* ========================================================*/
{
    unsigned char message[65536];
    /*int errnum; */
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Send to Ethernaude : InitIOsCommand --- */
    message[0] = (unsigned char) 0x06;
    message[1] = '\0';
    /*
       errnum=sockudp_send(message);
       if (errnum!=0) {
       paramCCD_put(-1,"FAILED",ParamCCDOut,0);
       paramCCD_put(-1,"Cause is : Error sending InitIOsCommand to socket",ParamCCDOut,0);
       return errnum;
       }
     */
    return 0;
}

int ethernaude_0x07(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* All clocks at 1.                                        */
/* ========================================================*/
{
    unsigned char message[65536];
    /*int errnum; */
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Send to Ethernaude : AllCloksToOne --- */
    message[0] = (unsigned char) 0x07;
    message[1] = '\0';
    /*
       errnum=sockudp_send(message);
       if (errnum!=0) {
       paramCCD_put(-1,"FAILED",ParamCCDOut,0);
       paramCCD_put(-1,"Cause is : Error sending AllCloksToOne command to socket",ParamCCDOut,0);
       return errnum;
       }
     */
    return 0;
}

int ethernaude_0x08(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* All clocks at 0.                                        */
/* ========================================================*/
{
    unsigned char message[65536];
    /*int errnum; */
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Send to Ethernaude : AllCloksToZero --- */
    message[0] = (unsigned char) 0x08;
    message[1] = '\0';
    /*
       errnum=sockudp_send(message);
       if (errnum!=0) {
       paramCCD_put(-1,"FAILED",ParamCCDOut,0);
       paramCCD_put(-1,"Cause is : Error sending AllCloksToZero to socket",ParamCCDOut,0);
       return errnum;
       }
     */
    return 0;
}

int ethernaude_0x09(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Open shutter.                                           */
/* ========================================================*/
{
    unsigned char message[65536];
    /*int errnum; */
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Send to Ethernaude : OpenShutter --- */
    message[0] = (unsigned char) 0x09;
    message[1] = '\0';
    /*
       errnum=sockudp_send(message);
       if (errnum!=0) {
       paramCCD_put(-1,"FAILED",ParamCCDOut,0);
       paramCCD_put(-1,"Cause is : Error sending OpenShutter to socket",ParamCCDOut,0);
       return errnum;
       }
     */
    return 0;
}

int ethernaude_0x0A(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Close shutter.                                          */
/* ========================================================*/
{
    unsigned char message[65536];
    /*int errnum; */
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Send to Ethernaude : CloseShutter --- */
    message[0] = (unsigned char) 0x0A;
    message[1] = '\0';
    /*
       errnum=sockudp_send(message);
       if (errnum!=0) {
       paramCCD_put(-1,"FAILED",ParamCCDOut,0);
       paramCCD_put(-1,"Cause is : Error sending CloseShutter to socket",ParamCCDOut,0);
       return errnum;
       }
     */
    return 0;
}

int ethernaude_0x0C(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Set the speed of CAN                                    */
/* ========================================================*/
{
    unsigned char message[65536];
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Ask Ethernaude to --- */
    if (SetCANSpeed(message, (unsigned char) ethvar->CanSpeed)) {
	/* --- Receive informations --- */
	while (Info_Received() == 0);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "Cause is : Error sending CANSpeed to socket", ParamCCDOut, 0);
	return 1;
    }
    /* --- Converts infos to ethernaude_var structure  --- */
    /* decoder (int)message[0] */
    return 0;
}


int ethernaude_0xFA(ethernaude_var * ethvar, TParamCCD * ParamCCDOut)
/* ========================================================*/
/* = Ethernaude Dialog function                           =*/
/* ========================================================*/
/* Abort Command.                                          */
/* ========================================================*/
{
    unsigned char message[65536];
    /*int errnum; */
    paramCCD_clearall(ParamCCDOut, 0);
    /* --- Send to Ethernaude : Abort_Command --- */

    if (StopExposure(message)) {
	/* --- Receive informations --- */
	while (Info_Received() == 0);
    } else {
	paramCCD_put(-1, "FAILED", ParamCCDOut, 0);
	paramCCD_put(-1, "Cause is : Error sending AbortExposure to socket or no exposure", ParamCCDOut, 0);
	return 1;
    }




    return 0;
}

