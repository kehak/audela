/*
        File: cmplclib.h

        PMAC Compiled PLC Command strings, Max parameters,
        Axis masks, & Error codes

        Author(s):      Ed Lay

        08/03/93      EBL     Created

        Change log:

          Date       Rev     Who         Description
        ---------    -----   -----   -----------------------------------------
        01/11/4              EBL     Changes for windows DLL
        01/21/4              EBL     Add "dlllib.h" & "struct.h" for WINDOWS
        01/27/4              EBL     New lvardef structure
        03/03/4              EBL     New Function Blocks(TON,TOF,TP,CTU,CTD,CTUD)
        03/03/4              EBL     Change CmdSingle VALUE
        03/13/5              EBL     Add FBnn.ET &=  logic

*/
// #define _DEBUG 1

#ifndef _CMPLCLIB_H
  #define _CMPLCLIB_H
  #include <stdlib.h>
  #include <stdio.h>
  #include <ctype.h>
  #include <share.h>
  #ifdef _MSC_VER
    #include <malloc.h>
  #endif

//*****************  Strings  ***********************************

  #define SABS    "ABS"
  #define SACOS   "ACOS"
  #define SADD    "ADD"
  #define SADDR   "\x41\x44\xC4\x52\xC5\xD3\xD3"        // ADDRESS
  #define SAND    "AND"
  #define SASIN   "ASIN"
  #define SATAN   "ATAN"
  #define SATAN2  "ATAN2"
  #define SCLEAR  "\x43\x4C\xC5\xC1\x52"
  #define SCLOSE  "\x43\x4C\xCF\x53\xC5"
  #define SCMD    "\x43\xCF\x4D\xCD\xC1\xCE\x44"        // COMMAND
  #define SCOS    "COS"
  #define SCTD    "CTD"
  #define SCTR_R  "CTR_R"
  #define SCTU    "CTU"
  #define SCTUD   "CTUD"
  #define SDISPLC "DIS\xC1\xC2\xCC\xC5\xA0\x50\x4C\x43" // 'DISABLE PLC'
  #define SDISP   "DIS\x50\xCC\xC1\xD9"                 // 'DISPLAY'
  #define SDIV     "DIV"
  #define SENAPLC "ENA\xC2\xCC\xC5\xA0\x50\x4C\x43"     // 'ENABLE PLC'
  #define SENDI   "END\xA0\x49\xC6"                     // 'END IF'
  #define SENDW   "END\xA0\x57\xC8\xC9\xCC\xC5"         // 'END WHILE'
  #define SELSE   "ELSE"
  #define SEQ     "EQ"
  #define SEXP    "EXP"
  #define SGT     "GT"
  #define SGTE    "GTE"
  #define SIF     "IF"
  #define SINT    "INT"
  #define SLN     "LN"
  #define SLT     "LT"
  #define SLTE    "LTE"
  #define SMOD    "MOD"
  #define SMULT   "MULT"
  #define SNAND   "NAND"
  #define SNEQ    "NE"
  #define SNOR    "NOR"
  #define SOPEN   "\x4F\x50\xC5\x4E"                    // OPEN - OPN
  #define SOR     "OR"
  #define SPLCC   "PLCC\xA0"                            // 'PLCC '
  #define SSCAN   "SCAN"
  #define SSEND   "SEND"
  #define SSIN    "SIN"
  #define SSQRT   "SQRT"
  #define SSUB    "SUB"
  #define STAN    "TAN"
  #define STON    "TON"
  #define STOF    "TOF"
  #define STP     "TP"
  #define STMR_R  "TMR_R"
  #define SWHILE  "WHILE"
  #define SXOR    "XOR"

//
// TIMER STRUCTURE ELEMENTs
//
  #define STMR_IN ".IN"     // Strings
  #define STMR_TT ".TT"
  #define STMR_Q  ".Q"
  #define STMR_PT ".PT"
  #define STMR_ET ".ET"
  #define TMR_IN 0x160A     // Format Code
  #define TMR_TT 0x150A
  #define TMR_Q  0x140A
  #define TMR_PT 0x00A2
  #define TMR_ET 0x0000
  #define FBXREAD 0x800000L // READS DATA INTO "X1" REGISTER

//
// COUNTER STRUCTURE ELEMENTs
//
  #define SCTR_RS ".R"  // Strings
  #define SCTR_CU ".CU"
  #define SCTR_Q ".Q"
  #define SCTR_PV ".PV"
  #define SCTR_LD ".LD"
  #define SCTR_CD ".CD"
  #define SCTR_CV ".CV"
  #define CTR_RS 0x170A // Format Code
  #define CTR_CU 0x160A
  #define CTR_QU 0x140A
  #define CTR_PV 0x00A2
  #define CTR_LD 0x1708
  #define CTR_CD 0x1608
  #define CTR_QD 0x1408
  #define CTR_CV 0x00A0

//
// MATH STRUCTURE ELEMENTs
//
  #define SMATH_A ".A"
  #define SMATH_B ".B"
  #define SMATH_C ".C"
  #define SMATH_Q ".Q"
  #define SMATH_EN ".EN"
  #define SMATH_ENO ".ENO"
  #define SSCAN_TIME ".TIME"
  #define SSCAN_MAX ".MAX"
  #define SSCAN_MIN ".MIN"
  #define SSCAN_CLR ".CLR"
// FB READ/WRITE FORMAT CODE
  #define MATH_A      0x0002
  #define MATH_B      0x0000
  #define MATH_C      0x0002
  #define MATH_Q      0x1708
  #define MATH_ENO    0x1708
  #define MATH_EN     0x1608
  #define SCAN_TIME   0x0000
  #define SCAN_MAX    0x0002
  #define SCAN_MIN    0x0080
  #define SCAN_CLR    0x1508

//****************************************************************************
//
//      Function Return codes for PLCstrcnvt, PLCstrtod, PLCmtrnum,
//      PLCplcnum, PLCaxisnum
//
//****************************************************************************
//  #ifdef _DEBUG
//    #define PLCTOKENMAX 655  // For DEBUG?? limited to 64k at the present struct size = 10
//    #define PLC56KMAX  1536  // For DEBUG maximum number of PLC 56k memory = 15K
//    #define LVARSIZE   1024  // Max size of L-var variables
//  #else
//    #define PLCTOKENMAX 6553 // limited to 64k at the present struct size = 10
    #define PLC56KMAX  15360 // maximum number of PLC 56k memory = 15K
    #define LVARSIZE   8192  // Max size of L-var variables
//  #endif

  #define STACKMAX   128    // maximum number of temporary 56k stack
  #define PLCSTRMAX  8192  // max number of buffered characters allowed for string cmds.
  #define PLCSTRLINEMAX 256 // max number of characters allowed in one string + 1
  #define PLCOk   0
  #define PLCClose 1        // Close command encoutered - not an error

//enum PLCCompileErrors {       Is now in "pmacresc.h"
//    PLCOk              =   0,
//     PLCClose           =   1,   // Close command encoutered - not an error
//     PLCFltErr          = -33,   // Unable to pack; floating point number too large
//     PLCStrToDErr       = -34,   // Unable to convert string to double float number
//     PLCCmdErr          = -35,   // Illegal Command or Format in string
//     PLCIntErr          = -36,   // Integer number out of range
//     PLCParenErr        = -37,   // Unmatching parenthesis
//     PLCElseErr         = -38,   // Illegal Else
//     PLCEndIfErr        = -39,   // Illegal EndIf
//     PLCEndWhErr        = -40,   // Illegal EndWhile
//     PLCOutFileErr      = -41,   // PLCC Output File Error
//     PLCInpFileErr      = -42,   // PLCC Input File Error
//     PLCCmdClsErr       = -43,   // Unclosed If or While
//     PLC56kMemMaxErr    = -44,   // Max number of PLC 56k memory exceeded
//     PLC56kstackMaxErr  = -45,   // Max number of PLC 56k conversion stack exceeded
//     PLCTokenMaxErr     = -46,   // Max number of Tokens exceeded for allowed memory
//     PLCfarheapErr      = -47,   // Far heap allocate error
//     PLCStrErr          = -48,   // String error Must be in "" & less than 255 characters
//     PLCLvarNotDef      = -49,   // L-var address not defined
//     PLCLvarMpyDef      = -50    // Two L-vars have the same address definition
// or has already been defined
//};


struct plccnvt { // PLC ASCII to Binary Token convert structure

     WORD    token;
     double  data;
};


  #define XYBITMASK 0x5F // see below
  #define XYMASK 0x40    // see below
  #define BITMASK 0x1F   // see below
  #define FORMATMASK 0x80

struct lvardef_struct { // PLC ASCII to Binary Token convert structure

     DWORD           addr;
     unsigned char   xybit; // Bit use      7           6        5    43210
                            //              ---    --------  --  ----------
                            //            U/S= 0/1 x/y= 0/1  0   offset # 0-23

     unsigned char   width; // width 1,4,8,12,16,24
};

///////////////////////////////////////////////////////////////////////////
// Functions

  #ifdef __cplusplus
extern "C" {
  #endif
  // Converts from a .PMA to .56K
  int CALLBACK PmacPlccCompilerA(DWORD dwDevice, int *datainfo,PCHAR inName,PCHAR outName);
  int CALLBACK PmacPlccCompilerW(DWORD dwDevice, int *datainfo,PWCHAR inName,PWCHAR outName);
  #ifdef __cplusplus
}
  #endif

  #ifdef UNICODE
    #define PlccCompiler PlccCompilerW
  #else
    #define PlccCompiler PlccCompilerA
  #endif // !UNICODE

#endif

