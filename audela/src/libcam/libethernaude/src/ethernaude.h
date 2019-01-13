/* ethernaude.h
 *
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 *
 * Mettre ici le texte de la license.
 *
 */

/***************************************************************************/
/* ethernaude.h                                                            */
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
#define MAXLENGTH  2000
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
    int InfoCCD_HasTDICaps;
    int InfoCCD_HasVideoCaps;
    int InfoCCD_HasRegulationTempCaps;
    int InfoCCD_HasGPSDatation;

    int BitPerPixels;
    double VersionID;		/* obsolete ? */
    char SX52_Audine_Release[10];
    char SX52_Ethernet_Release[10];
    /* status modified by functions */
    char CCDStatus[30];
    /* asked by user */
    unsigned char nbwipe;
    int Exposure;
#ifdef OS_WIN
    // Only 32 bits "pointers" are supported. Too bad ...
    int ImageAddress;
#else
    unsigned char * ImageAddress;
#endif
    int CCDno;
    int ClockMode;
    int X1;
    int X2;
    int Y1;
    int Y2;
    int BinningX;
    int BinningY;
    int ShutterOpen;

} ethernaude_var;


/* #define ETHERNAUDE_DEBUG */
extern int ethernaude_debug;

/***************************************************************************/
#endif
