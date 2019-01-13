/***************************************************************************
  Title:    pmacutil.h

  Version:  1.00

  Date:   8/29/1995

  Author(s):  Harry Rivera

  Misc. Routines for PMAC-II Setup Program

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------

***************************************************************************/



//#include "runtime.h"
#include <pmacu.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <conio.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#include <windows.h>
#include <time.h>

#define _FUNC FAR PASCAL _export

//#define _LOAD_DLL

// Global variables...
extern HINSTANCE hPmacLib;

#define CLEAR_MEM '\x12345'
#define BELL '\x7'
#define ACK  '\x6'
#define CR   '\x13'

// Function prototypes
#ifdef __cplusplus
extern "C" {
#endif

  void msg (const char *fmt,...);
  long myGetIVariableLong (DWORD pmac,UINT num);
  void myGetResponse (DWORD pmac,char *response,int max_char,const char *fmt,...);
  void mySendLine (DWORD pmac,const char *fmt,...);
  void strip_off_extra (char *vbuf);

  void delete_file (char *filename);
  //void copy_file (char *dest,char *source);

  void DownloadPosLimitPLC (DWORD pmac,short motor);

#ifdef __cplusplus
}
#endif



