/***************************************************************************

        Title:          dprotlib.h

        Version:        1.00

        Date:           04/15/1993

        Author(s):      Ed Lay

----------------------------------------------------------------------------

        Change log:

       Date       Rev     Who                    Description
  ---------       -----   -----   --------------------------------------------
  07/14/1993              DES     Modified for Windows 'CNC' DLL.
  06/06/1994              EBL     Changed functions for Dual Binary Rot Buffers
  07/06/1995              DES     Modified for WIN32 and USERDLL.
  05/18/1997              EBL     Changes for Expression( Now a two PASS conversion )

***************************************************************************/

#ifndef _DPROTLIB_H
  #define _DPROTLIB_H

  #include <stdio.h>
  #include "resource.h"


  #define DPRTOKENMAX 125 // Maximume number of TOKENS in a Line of ASCII code
  #define DPRCMDMAX 150   // Two times the maximum number of PMAC commands in a line

enum Dpr_Bin_Rot_Errors {
    DprOk          =   0,
    DprBufBsy      =   1, // DPR Rotary Buffer is Busy
    DprEOF         =   2, // DPR Rotary Buffer End of File detected
};


struct dprbcnvt{ // DPR BIN ROT ASCII to Binary Token convert structure
    int           token;
    double        data;
    int           code1;
    int           code2;
    DWORD         ldata;
}; // 18 bytes

//*****************  Strings  ***********************************
  #define SABS "ABS"
  #define SACOS   "ACOS"
  #define SADIS "ADIS\xD0\xCC\xC1\xC3\xC5"                   // ADISPLACE'
  #define SAROT "AROT\xC1\xD4\xC5"                           //'AROTATE'
  #define SASIN   "ASIN"
  #define SATAN   "ATAN"
  #define SATAN2  "ATAN2"
  #define SBSTART "\x42\xCC\xCF\xC3\xCB\xA0START"            // 'BLOCK START'
  #define SBSTOP  "\x42\xCC\xCF\xC3\xCB\xA0STOP"             // 'BLOCK STOP'
  #define SCC     "CC"
  #define SCCR    "CCR"
  #define SCIR    "CIR\xC3\xCC\xC5"                          // 'CIRCLE'
  #define SCALL   "CALL"
  #define SCOS    "COS"
  #define SDWELL  "DWE\xCC\xCC"                              // DWELL
  #define SDELAY  "\x44\xC5\x4C\xC1\x59"                     // DELAY
  #define SDISPLC "DIS\xC1\xC2\xCC\xC5\xA0\x50\x4C\x43"      // 'DISABLE PLC'
  #define SDISPLCC "DIS\xC1\xC2\xCC\xC5\xA0\x50\x4C\x43\x43" // 'DISABLE PLCC'
  #define SENAPLC "ENA\xC2\xCC\xC5\xA0\x50\x4C\x43"          // 'ENABLE PLC'
  #define SENAPLCC "ENA\xC2\xCC\xC5\xA0\x50\x4C\x43\x43"     // 'ENABLE PLCC'
  #define SEXP    "EXP"
  #define SFRAX   "FRAX"
  #define SHOME   "\x48\xCF\x4D\xC5"                         // "HOME"
  #define SHOMEZ  "\x48\xCF\x4D\xC5\x5A"                     // " HOMEZ"
  #define SINC    "INC"
  #define SIDIS   "IDI\x53\xD0\xCC\xC1\xC3\xC5"              // "IDISPLACE"
  #define SIROT   "IROT\xC1\xD4\xC5"                         //  'IROTATE'
  #define SIF     "IF"
  #define SINT    "INT"
  #define SLINEAR "LIN\xC5\xC1\xD2"                          // 'LINEAR'
  #define SLN     "LN"
                                                             //#define SLSTART "L\xCF\xCF\xCB\xC1\xC8\xC5\xC1\xC4\xA0START"
                                                             //#define SLSTOP  "L\xCF\xCF\xCB\xC1\xC8\xC5\xC1\xC4\xA0STOP"
  #define SNORM   "\x4E\xCF\x52\x4D\xC1\xCC"                 // 'NORMAL'
  #define SPREL   "PRELUDE"
  #define SPVT    "PVT"
  #define SPSET   "PSET"
  #define SRAPID  "\x52\xC1\x50\xC9\x44"                     // 'RAPID'
  #define SSPLINE "SPLINE"
  #define SSTOP   "STOP"
  #define SSIN    "SIN"
  #define SSQRT   "SQRT"
  #define STAN    "TAN"
  #define STSEL   "TSE\x4C\xC5\xC3\xD4"                      // 'TSELECT'
  #define STINIT  "TINIT"
  #define STA     "TA"
  #define STS     "TS"
  #define STM     "TM"
  #define SWAIT   "WAIT"
  #define SWHILE  "WHILE"

//*****************  Integer Max Values  ***********************************

  #define AROTMAX 1015L
  #define ADISMAX 1021L
  #define CCMAX   2L
  #define CIRMAX  2L
  #define IDISMAX 1021L
  #define IROTMAX 1015L
  #define SPLINEMAX 1L
  #define TSELMAX 5L
  #define PRELMAX 1024L

//***************** Axis Mask Values  ***********************************

  #define RM 1L
  #define AM 2L
  #define BM 8L
  #define CM 32L
  #define UM 128L
  #define VM 512L
  #define WM 2048L
  #define XM 8192L
  #define YM 32768L
  #define ZM 131072L
  #define ALLM AM+BM+CM+XM+YM+ZM+UM+VM+WM

//****************************************************************************
//
//      Function Return codes for DPRstrcnvt, DPRpack_??, DPRstrtod, DPRmtrnum,
//      DPRplcnum, DPRaxisnum
//
//****************************************************************************

///////////////////////////////////////////////////////////////////////////
// Functions
  #ifdef __cplusplus
extern "C" {
  #endif

  // DPR Binary rotary buffer functions
  // Initialization/shutdown
  SHORT CALLBACK PmacDPRRotBufInit(DWORD dwDevice,USHORT bufnum);
  SHORT CALLBACK PmacDPRRotBufRemove(DWORD dwDevice,USHORT bufnum);
  SHORT CALLBACK PmacDPRRotBufChange(DWORD dwDevice,USHORT bufnum,USHORT new_size) ;
  void  CALLBACK PmacDPRRotBufClr(DWORD dwDevice,UINT bufnum);
  SHORT CALLBACK PmacDPRRotBuf(DWORD dwDevice,BOOL on);
  int   CALLBACK PmacDPRBufLast(DWORD dwDevice);

  // Transfer functions
  SHORT CALLBACK PmacDPRAsciiStrToRotA(DWORD dwDevice,PCHAR inpstr, USHORT bufnum);
  SHORT CALLBACK PmacDPRSendBinaryCommandA(DWORD dwDevice,PCHAR inpstr, USHORT bufnum);
  SHORT CALLBACK PmacDPRAsciiStrToBinaryFileA(DWORD dwDevice,PCHAR inpstr, FILE *outfile);

  SHORT CALLBACK PmacDPRAsciiStrToRotW(DWORD dwDevice,PWCHAR inpstr, USHORT bufnum);
  SHORT CALLBACK PmacDPRSendBinaryCommandW(DWORD dwDevice,PWCHAR inpstr, USHORT bufnum);
  SHORT CALLBACK PmacDPRAsciiStrToBinaryFileW(DWORD dwDevice,PWCHAR inpstr, FILE *outfile);


  SHORT CALLBACK PmacDPRAsciiFileToRot(DWORD dwDevice,FILE *inpfile, USHORT bufnum);
  SHORT CALLBACK PmacDPRBinaryFileToRot(DWORD dwDevice,FILE *inpfile, USHORT bufnum);
  SHORT CALLBACK PmacDPRAsciiToBinaryFile(DWORD dwDevice,FILE *inpfile,FILE *outfile);
  SHORT CALLBACK PmacDPRBinaryToRot(DWORD dwDevice,WORD *inpbinptr,WORD **outbinptr,WORD bufnum);

  // Packing/compiling functions
  int DPRpack_0A(int code1,double data );
  int DPRpack_0B(int code1,int code2,double data );
  int DPRpack_1A(int code1,int code2,unsigned long data );
  int DPRpack_1B(int code1,int code2,unsigned long data );
  int DPRpack_1C(int code1,unsigned long data);
  int DPRpack_1D(DWORD dwDevice,int code1,int code2,unsigned long data);
  int DPRpack_1E(DWORD dwDevice, int code1, int code2, unsigned long data );
  int DPRpack_1F(int code1,int code2);
  int DPRpack_2(int code1,int code2,int data1,double data);

  int DPRstrcmp(char *instr,char *instrc,char **endptr);
  int DPRstrtod(char *instr,double *ddata,char **endptr);
  int DPRcmdend(char *instr);
  int  DPRmtrnum(DWORD dwDevice, unsigned long *retmask, char *instr, char **endptr );
  int DPRplcnum(char *instr,unsigned long *retmask,char **endptr);
  int DPRaxisnum(char *instr,unsigned long *retmask,char **endptr);
  int DPRstrcnvt(DWORD dwDevice, char *instr, struct dprbcnvt *pmc_cmd );
  int CALLBACK DPRrotput(int num_put,LPDWORD rotdat, int bufnum);
  int DPRTokentoBin(DWORD dwDevice, struct dprbcnvt *dprtoknptr );
  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  //
  // Variable Background Buffer Functions
  // Initialization
  long  CALLBACK PmacDPRVarBufInit(DWORD dwDevice,long new_num_entries,PLONG addrarray);
  long  CALLBACK PmacDPRVarBufInitEx(DWORD dwDevice,long new_num_entries,PLONG addrarray, PUINT addrtype);
  BOOL  CALLBACK PmacDPRVarBufRemove(DWORD dwDevice,long h);
  BOOL  CALLBACK PmacDPRVarBufChange(DWORD dwDevice,long handle, long new_num_entries,long *addrarray);
  BOOL  CALLBACK PmacDPRVarBufChangeEx(DWORD dwDevice,long handle, long new_num_entries,long *addrarray,PUINT addrtype);
  BOOL  CALLBACK PmacDPRVarBufRead(DWORD dwDevice,long h,long entry_num,PLONG long_2);
  long  CALLBACK PmacDPRGetVBGAddress(DWORD dwDevice,long h,long entry_num);

  long  CALLBACK PmacDPRGetVBGNumEntries(DWORD dwDevice,long h);
  long  CALLBACK PmacDPRGetVBGDataOffset(DWORD dwDevice,long h);
  long  CALLBACK PmacDPRGetVBGAddrOffset(DWORD dwDevice,long h);

  // Both
  UINT  CALLBACK PmacDPRGetVBGServoTimer(DWORD dwDevice);
  UINT  CALLBACK PmacDPRGetVBGStartAddr(DWORD dwDevice);
  int   CALLBACK PmacDPRGetVBGTotalEntries(DWORD dwDevice);

  int   CALLBACK PmacDPRWriteBuffer(DWORD dwDevice,int num_entries,
                  struct VBGWFormat *the_data);
  #ifdef __cplusplus
}
  #endif

  #ifdef UNICODE
    #define PmacDPRAsciiStrToRot PmacDPRAsciiStrToRotW
    #define PmacDPRSendBinaryCommand PmacDPRSendBinaryCommandW
    #define PmacDPRAsciiStrToBinaryFile PmacDPRAsciiStrToBinaryFileW
  #else
    #define PmacDPRAsciiStrToRot PmacDPRAsciiStrToRotA
    #define PmacDPRSendBinaryCommand PmacDPRSendBinaryCommandA
    #define PmacDPRAsciiStrToBinaryFile PmacDPRAsciiStrToBinaryFileA
  #endif // !UNICODE

#endif
