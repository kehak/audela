/***************************************************************************
  (C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992

  Title:    vmic.h

  Version:  1.00

  Date:   08/14/1997

  Author(s):  Allen Segall

  Header file for VME bus communications, via the VMIC VMEMGR.DLL Driver
  under NT only.  Built and tested with VMIC 7686.

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------

***************************************************************************/
#ifndef _VMIC_H
  #define _VMIC_H

  #include "windows.h"
  #include "stdio.h"
  #include "conio.h"
  #include "math.h" // for pow
  #include "vmemgr.h"

  #define VMICDRIVERNAME   TEXT("VMEMGR.dll") //name of the user-dll driver

  #ifdef __cplusplus
extern "C" {
  #endif

  //////////////////////////////////////////////////////////////////
  // RUN TIME LINKING
  //////////////////////////////////////////////////////////////////
  typedef DWORD (CALLBACK* VMEINIT)(DWORD reserved1,DWORD reserved2);
  typedef DWORD (CALLBACK* VMETERM)(DWORD reserved1);
  typedef DWORD (CALLBACK* VMEGETVMEWINDOWADR)(DWORD reserved1,DWORD handle,void **);
  typedef DWORD (CALLBACK* VMELOCKVMEWINDOW)(DWORD Reserved,DWORD Size,DWORD Adr,DWORD *Handle,DWORD NumElements,DWORD AccessMode,DWORD Flags,DWORD RequestLevel,DWORD Timeout,DWORD Reserved2);
  typedef DWORD (CALLBACK* VMEUNLOCKVMEWINDOW)(DWORD Reserved,DWORD Handle);
  typedef DWORD (CALLBACK* VMEFREEVMEWINDOWADR)(DWORD Reserved,DWORD WinHandle,void *Adr);
  typedef DWORD (CALLBACK* VMEINSTALLINTERRUPTHANDLER)(DWORD Reserved,DWORD IntNum,DWORD ID,DWORD (__cdecl *HandlerFunction)(DWORD ID));

  // Start up shutdown
  HINSTANCE VMICRunTimeLink(void);
  BOOL VMICInit(DWORD dwDevice);
  void VMICShutDown(DWORD dwDevice);
  BOOL VMICInitDPR(DWORD dwDevice);
  void VMICReleaseMailboxResources(DWORD dwDevice);

  // Internal use only
  void * VMICLockWindow(DWORD *windowHandle, DWORD width,DWORD VmeAdr,DWORD size);
  void VMICReleaseWindow(DWORD *windowHandle,void *WindowAddress);

  #ifdef __cplusplus
}
  #endif

#endif

