/*

  ethernaude.h

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
/* Header for all C files that use ethernaude driver.                      */
/***************************************************************************/

#ifndef __ETHERNAUDE_H__
#define __ETHERNAUDE_H__

/***************************************************************************/
/* MAXCOMMAND                                                              */
/***************************************************************************/
/* It is the maximum number of elements allowed in the TParamCCD structure */
/***************************************************************************/

#define MAXCOMMAND 100
#define MAXLENGTH  100
/***************************************************************************/
/* TParamCCD                                                               */
/***************************************************************************/
/* It is the data exchange structure used in the imported function of the  */
/* ethernaude driver.                                                      */
/*                                                                         */
/* That structure contains an array of strings which will contain commands */
/* as input and results as output data exhanged with the ethernaude driver.*/
/*                                                                         */
/* NbreParam is the number of not NULL strings from the first element of   */
/*           the array.                                                    */
/*                                                                         */
/* *Param[MAXCOMMAND] is an array of strings that will be allocated and    */
/*                    filled by the exchange data.                         */
/***************************************************************************/

typedef struct {
    int NbreParam;
    char *Param[MAXCOMMAND];
} TParamCCD;

extern TParamCCD ParamCCDIn, ParamCCDOut;

/***************************************************************************/
/* Define names associated to the ethernaude driver                        */
/***************************************************************************/
/* The imported data exchange function of the ethernaude library driver    */
/* is named AskForExecuteCCDCommand and is declared as a global function.  */
/***************************************************************************/
#define ETHERNAUDE_MAIN AskForExecuteCCDCommand
#define ETHERNAUDE_MAINQ "AskForExecuteCCDCommand"

typedef struct {
    char message[256];
    /* informations returned */
    int Camera_ID;
    int NbreParamSetup;
    int CCDDrivenAmount;
    char SystemName[50];
    char InfoCCD_NAME[50];
    int InfoCCD_ClockModes;
    int WidthPixels;
    int HeightPixels;
    int PixelsPrescanX;
    int PixelsPrescanY;
    int PixelsOverscanX;
    int PixelsOverscanY;
    int InfoCCD_MaxExposureTime;
    int InfoCCD_PixelsSizeX;
    int InfoCCD_PixelsSizeY;
    int InfoCCD_IsGuidingCCD;
    int BitPerPixels;
    double VersionID;		/* obsolete ? */
    char SX52_Audine_Release[10];
    char SX52_Ethernet_Release[10];
    /* status modified by functions */
    char CCDStatus[30];
    /* asked by user */
    unsigned char nbwipe;
    int Exposure;
    unsigned char * ImageAddress;
    int CCDno;
    int ClockMode;
    int X1;
    int X2;
    int Y1;
    int Y2;
    int BinningX;
    int BinningY;
    int ShutterOpen;
    int CanSpeed;

} ethernaude_var;

/*
// #define ETHERNAUDE_DEBUG
*/

/***************************************************************************/
#endif
