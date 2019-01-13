/***************************************************************************
	(C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992
		
	Title: 		ser.h

	Version:	1.00

	Date:		08/06/1995

	Author(s):	Dennis Smith

	Header file for PMAC NT serial communications.

	Note(s):

----------------------------------------------------------------------------

	Change log:

	  Date	     Rev	 Who			Description
	---------	-----	-----	--------------------------------------------

***************************************************************************/

#ifndef _SERIAL_H
#define _SERIAL_H

#include <windows.h>
#include <windowsx.h>
#include <assert.h>
#include "resource.h"// Included for serial error code defines which match strings
#include "mioctl.h"  // Included for status defines, i.e. COMM_TIMEOUT
// Functions --------------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif

BOOL  CALLBACK PmacSERIsOpen(DWORD dwDevice);
HANDLE CALLBACK PmacSERGetHandle(DWORD dwDevice);
DWORD CALLBACK PmacSERGetPort(DWORD dwDevice);
BOOL  CALLBACK PmacSERSetPort(DWORD dwDevice,DWORD p);
DWORD CALLBACK PmacSERGetBaudrate(DWORD dwDevice);
BOOL  CALLBACK PmacSERSetBaudrate(DWORD dwDevice,DWORD br);
BOOL  CALLBACK PmacSEROpen(DWORD dwDevice);
BOOL  CALLBACK PmacSERSetComm(DWORD dwDevice,DWORD port,DWORD baud,BOOL odd);
void  CALLBACK PmacSERClose(DWORD dwDevice);
BOOL  CALLBACK PmacSEROnLine(DWORD dwDevice);

BOOL  CALLBACK PmacSERReadReady(DWORD dwDevice);
int   CALLBACK PmacSERSendCharA(DWORD dwDevice,CHAR outch);
int   CALLBACK PmacSERSendCharW(DWORD dwDevice,WCHAR outch);
int   CALLBACK PmacSERSendLineA(DWORD dwDevice,PCHAR outstr);
int   CALLBACK PmacSERSendLineW(DWORD dwDevice,PWCHAR outstr);
int   CALLBACK PmacSERGetLineA(DWORD dwDevice,PCHAR response,UINT maxchar,PUINT num_char);
int   CALLBACK PmacSERGetLineInitA(DWORD dwDevice,PCHAR response,UINT maxchar,PUINT num_char);
int   CALLBACK PmacSERGetLineW(DWORD dwDevice,PWCHAR s,UINT maxchar,PUINT num_char);
int   CALLBACK PmacSERGetBufferA(DWORD dwDevice,PCHAR s,UINT maxchar,PUINT num_char);
int   CALLBACK PmacSERGetBufferW(DWORD dwDevice,PWCHAR s,UINT maxchar,PUINT num_char);
int   CALLBACK PmacSERGetResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,PCHAR outstr);
int   CALLBACK PmacSERGetResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,PWCHAR outstr);
int   CALLBACK PmacSERGetControlResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,CHAR outchar);
int   CALLBACK PmacSERGetControlResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,WCHAR outchar);
void  CALLBACK PmacSERFlush(DWORD dwDevice);
void  CALLBACK PmacSERFlushInit(DWORD dwDevice);
void  CALLBACK PmacSERSendCommandA(DWORD dwDevice,PCHAR outchar);
void  CALLBACK PmacSERSendCommandW(DWORD dwDevice,PWCHAR outstr);
void  _cdecl PmacSERDownloadFirmware(DWORD dwDevice, PCHAR name);
void SERFlush(DWORD dwDevice);
int  CALLBACK PmacSERGetChar(DWORD dwDevice,PCHAR response);
int  CALLBACK PmacSERDoChecksums(DWORD dwDevice, UINT do_checksums);
BOOL CALLBACK PmacSERCheckSendLine(DWORD dwDevice,char * outchar, char * command_csum);
int  CALLBACK PmacSERCheckGetLine(DWORD dwDevice,PCHAR response,UINT maxchar, PUINT num_char);
int  CALLBACK PmacSERCheckResponse(DWORD dwDevice,char * response, UINT maxchar,char * outchar);

#ifdef __cplusplus
}
#endif

#ifdef UNICODE
  #define PmacSERSendChar PmacSERSendCharW
  #define PmacSERSendLine PmacSERSendLineW
  #define PmacSERGetLine PmacSERGetLineW
  #define PmacSERGetResponse PmacSERGetResponseW
  #define PmacSERGetControlResponse PmacSERGetControlResponseW
  #define PmacSERSendCommand PmacSERSendCommandW
#else
  #define PmacSERSendChar PmacSERSendCharA
  #define PmacSERSendLine PmacSERSendLineA
  #define PmacSERGetLine PmacSERGetLineA
  #define PmacSERGetResponse PmacSERGetResponseA
  #define PmacSERGetControlResponse PmacSERGetControlResponseA
  #define PmacSERSendCommand PmacSERSendCommandA
#endif // !UNICODE

#endif
