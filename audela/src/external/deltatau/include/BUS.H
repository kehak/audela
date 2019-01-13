/***************************************************************************
  (C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992

  Title:    bus.h

  Version:  1.00

  Date:   12/11/1992

  Author(s):  Dennis Smith, Allen Segall

  Header file for PMAC bus communications.

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------

***************************************************************************/

#ifndef _BUS_H
  #define _BUS_H

// Functions --------------------------------------------------------------
  #ifdef __cplusplus
extern "C" {
  #endif

  BOOL  CALLBACK PmacBUSReadReady(DWORD dwDevice);
  int   CALLBACK PmacBUSSendCharA(DWORD dwDevice,CHAR outch);
  int   CALLBACK PmacBUSSendCharW(DWORD dwDevice,WCHAR outch);
  int   CALLBACK PmacBUSSendLineA(DWORD dwDevice,PCHAR outstr);
  int   CALLBACK PmacBUSSendLineW(DWORD dwDevice,PWCHAR outstr);
  int   CALLBACK PmacBUSGetLineA(DWORD dwDevice,PCHAR s,UINT maxchar,PUINT nc);
  int   CALLBACK PmacBUSGetLineW(DWORD dwDevice,PWCHAR s,UINT maxchar,PUINT nc);
  int   CALLBACK PmacBUSGetBufferA(DWORD dwDevice,PCHAR s,UINT maxchar,PUINT nc);
  int   CALLBACK PmacBUSGetBufferW(DWORD dwDevice,PWCHAR s,UINT maxchar,PUINT nc);
  int   CALLBACK PmacBUSGetResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,PCHAR outstr);
  int   CALLBACK PmacBUSGetResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,PWCHAR outstr);
  int   CALLBACK PmacBUSGetControlResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,CHAR outchar);
  int   CALLBACK PmacBUSGetControlResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,WCHAR outchar);
  void  CALLBACK PmacBUSFlush(DWORD dwDevice);
  void  CALLBACK PmacBUSSendCommandA(DWORD dwDevice,PCHAR outchar);
  void  CALLBACK PmacBUSSendCommandW(DWORD dwDevice,PWCHAR outstr);

  int  CALLBACK Outp(DWORD dwDevice,BYTE offset,BYTE ch);
  BYTE CALLBACK Inp(DWORD dwDevice,BYTE offset);

  #ifdef __cplusplus
}
  #endif

  #ifdef UNICODE
    #define PmacBUSSendChar PmacBUSSendCharW
    #define PmacBUSSendLine PmacBUSSendLineW
    #define PmacBUSGetLine PmacBUSGetLineW
    #define PmacBUSBuffer PmacBUSGetBufferW
    #define PmacBUSGetResponse PmacBUSGetResponseW
    #define PmacBUSGetControlResponse PmacBUSGetControlResponseW
    #define PmacBUSSendCommand PmacBUSSendCommandW
  #else
    #define PmacBUSSendChar PmacBUSSendCharA
    #define PmacBUSSendLine PmacBUSSendLineA
    #define PmacBUSBuffer PmacBUSGetBufferA
    #define PmacBUSGetLine PmacBUSGetLineA
    #define PmacBUSGetResponse PmacBUSGetResponseA
    #define PmacBUSGetControlResponse PmacBUSGetControlResponseA
    #define PmacBUSSendCommand PmacBUSSendCommandA
  #endif // !UNICODE

#endif
