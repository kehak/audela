/***************************************************************************
  (C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992

  Title:    Gather.h

  Version:  1.00

  Date:   12/11/1997

  Author(s):  Dennis Smith

  Header file for PMAC gather function.

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------

***************************************************************************/

#ifndef _GATHER_H
  #define _GATHER_H

  #define MAXGATHERS     24
  #define MAXGATHERS2    48
  #define MAXRTGATHERS   3
  #define MAXADRLEN      15
  #define MAX_CURVES_PER_AXIS  4
  #define BaseI21        21
  #define BaseI5001     5001


// Mode & location of gather buffer. I45
typedef enum {
  GAT_RAM_NOWRAP = 0,GAT_RAM_WRAP,GAT_DPR_NOWRAP,GAT_DPR_WRAP
} GATMODE;


// Quick gather masks ( legacy )
  #define GATHER_COM1    0x00000001L
  #define GATHER_COM2    0x00000002L
  #define GATHER_COM3    0x00000004L
  #define GATHER_COM4    0x00000008L
  #define GATHER_COM5    0x00000010L
  #define GATHER_COM6    0x00000020L
  #define GATHER_COM7    0x00000040L
  #define GATHER_COM8    0x00000080L

  #define GATHER_ENC1    0x00000100L
  #define GATHER_ENC2    0x00000200L
  #define GATHER_ENC3    0x00000400L
  #define GATHER_ENC4    0x00000800L
  #define GATHER_ENC5    0x00001000L
  #define GATHER_ENC6    0x00002000L
  #define GATHER_ENC7    0x00004000L
  #define GATHER_ENC8    0x00008000L

  #define GATHER_DAC1    0x00010000L
  #define GATHER_DAC2    0x00020000L
  #define GATHER_DAC3    0x00040000L
  #define GATHER_DAC4    0x00080000L
  #define GATHER_DAC5    0x00100000L
  #define GATHER_DAC6    0x00200000L
  #define GATHER_DAC7    0x00400000L
  #define GATHER_DAC8    0x00800000L

  #define GATHER_CUR1    0x01000000L
  #define GATHER_CUR2    0x02000000L
  #define GATHER_CUR3    0x04000000L
  #define GATHER_CUR4    0x08000000L
  #define GATHER_CUR5    0x10000000L
  #define GATHER_CUR6    0x20000000L
  #define GATHER_CUR7    0x40000000L
  #define GATHER_CUR8    0x80000000L

typedef struct
{
  DWORD  size;                                // Size of this header
  double ulGatherSampleTime;                  // Sample gather time in msec
  UINT   uGatherPeriod;                       // I19 number servo cycles per sample
  DWORD  dwGatherMask;                        // I20 (determines #sources & types)
  DWORD  dwGatherMask2;                       // added for Turbo
  UINT   uGatherSources;                      // Number of sources gathered
  UINT   uGatherSamples;                      // Number of samples gathered
  UINT   uGatherSampleLen;                    // Number 24-bit words per sample
  BOOL   bGatherEnabled[MAXGATHERS2];         // Sources enabled
  char   szGatherAdr[MAXGATHERS2][MAXADRLEN]; // Types and addresses of gathers
  UINT   uGatherSize[MAXGATHERS2];            // Size of gather type in 24bit words
  double *pGatherData[MAXGATHERS2];           // Pointers to gathered data
  double dGatherScale[MAXGATHERS2];           // Scale values for data
} GATHER_HEADER, *PGATHER_HEADER;

typedef struct _WTG_EX
{
  UINT COM_TO_G ;
  UINT ENC_TO_G ;
  UINT DAC_TO_G ;
  UINT CUR_TO_G ;
 } WTG_EX, *PWTG_EX;

// Functions --------------------------------------------------------------
  #ifdef __cplusplus
extern "C" {
  #endif

  double   CALLBACK PmacGetGatherSampleTime(DWORD dwDevice);
  UINT     CALLBACK PmacGetGatherPeriod(DWORD dwDevice);
  UINT     CALLBACK PmacGetNumGatherSources(DWORD dwDevice);
  UINT     CALLBACK PmacGetNumGatherSamples(DWORD dwDevice);
  double   CALLBACK PmacSetGatherSampleTime(DWORD dwDevice,double msec);
  UINT     CALLBACK PmacSetGatherPeriod(DWORD dwDevice,UINT period);
  BOOL     CALLBACK PmacSetGatherEnable(DWORD dwDevice,UINT num,BOOL ena);
  BOOL     CALLBACK PmacGetGatherEnable(DWORD dwDevice,UINT num);
  BOOL     CALLBACK PmacSetGather(DWORD dwDevice,UINT num,LPSTR str,BOOL ena);
  BOOL     CALLBACK PmacSetQuickGather(DWORD dwDevice,UINT mask,BOOL ena);
  BOOL     CALLBACK PmacSetQuickGatherWithDirectCurrent(DWORD dwDevice,UINT mask,BOOL ena);
  BOOL     CALLBACK PmacSetQuickGatherWithDirectCurrentEx(DWORD dwDevice,PWTG_EX mask,BOOL ena);
  
  BOOL     CALLBACK PmacSetQuickGatherEx(DWORD dwDevice,PWTG_EX mask,BOOL ena);
  BOOL     CALLBACK PmacGetGather(DWORD dwDevice,UINT num,LPSTR str,UINT maxchar);
  void     CALLBACK PmacClearGather(DWORD dwDevice);
  BOOL     CALLBACK PmacInitGather(DWORD dwDevice,UINT size,double msec);
  BOOL     CALLBACK PmacInitPlotGather(DWORD dwDevice,UINT size,UINT period);
  void     CALLBACK PmacClearGatherData(DWORD dwDevice);
  BOOL     CALLBACK PmacCollectGatherData(DWORD dwDevice,PUINT sources,PUINT samples);
  BOOL     CALLBACK PmacGetGatherSamples(DWORD dwDevice,UINT source,PUINT samples,
                                   double *p,UINT max);
  BOOL     CALLBACK PmacGetGatherPoint(DWORD dwDevice,UINT source,UINT sample,double *p);
  GATMODE  CALLBACK PmacGetGatherMode(DWORD dwDevice);
  BOOL     CALLBACK PmacSetGatherMode(DWORD dwDevice,GATMODE mode);
  int      CALLBACK PmacStartGather(DWORD dwDevice);
  int      CALLBACK PmacStopGather(DWORD dwDevice);
  BOOL     CALLBACK PmacReadGatherFile(DWORD dwDevice,LPSTR filename);
  BOOL     CALLBACK PmacWriteGatherFile(DWORD dwDevice,LPSTR filename);

  // Real time
  BOOL     CALLBACK PmacInitRTGather(DWORD dwDevice);
  void     CALLBACK PmacClearRTGather(DWORD dwDevice);
  BOOL     CALLBACK PmacAddRTGather(DWORD dwDevice,ULONG val);
  double * CALLBACK PmacCollectRTGatherData(DWORD dwDevice,PUINT sources);

  double   CALLBACK strtod48f(LPCSTR str);
  double   CALLBACK strtod48l(LPCSTR str);
  double   CALLBACK strtod24(LPCSTR str);
  double   CALLBACK strtod32dp(LPCSTR str);
  double   CALLBACK strtod32f(LPCSTR str);
  long     CALLBACK hex_long2(LPCSTR in_str, int str_ln);
  BOOL     CALLBACK getBitValue(char *s,int bit);

  #ifdef __cplusplus
}
  #endif

  #ifdef UNICODE
  #else
  #endif // !UNICODE

#endif
