/***************************************************************************
  (C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992

  Title:    intr.h

  Version:  1.00

  Date:   12/11/1992

  Author(s):  Dennis Smith

  Header file for PMAC NT interrupt worker thread.

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------

***************************************************************************/
#include "private.h"
#ifndef _INTR_H
  #define _INTR_H

/******************************************************************************
 * data streaming.
 *
 * Call PmacInitInterrupts to prepare for interrupts.
 * The callback function specified in PmacInitInterrupts will be called
 * with the interrupt that has completed.
 *
 * Finally call PmacTermInterrupts to tidy up.
 ******************************************************************************/

/*
 * these are the parameters we need to issue a DriverCallback. A
 * pointer to one of these structs is passed on InterruptInit
 * If the pointer is null, we don't need callbacks.
 */
typedef struct _MCCALLBACK {
    DWORD  dwCallback;
    DWORD  dwFlags;
    DWORD  dwDevice;
    DWORD  dwUser;
} MCCALLBACK, * PMCCALLBACK;

// Callback function pointer
typedef void (FAR WINAPI *PMACINTRPROC)(DWORD msg,PINTRBUFFER pBuffer);

// Functions --------------------------------------------------------------
  #ifdef __cplusplus
extern "C" {
  #endif

  // Functions exported
  BOOL  CALLBACK PmacINTRWndMsgInit(DWORD dwDevice,HWND hWnd,UINT msg,ULONG ulMask);
  BOOL  CALLBACK PmacINTRFuncCallInit(DWORD dwDevice,PMACINTRPROC pFunc,DWORD msg,ULONG ulMask);
  BOOL  CALLBACK PmacINTRFireEventInit(DWORD dwDevice,HANDLE hEvent,ULONG ulMask);
  BOOL  CALLBACK PmacINTRRunThreadInit(DWORD dwDevice,LPTHREAD_START_ROUTINE pFunc,UINT msg,ULONG ulMask);
  BOOL  CALLBACK PmacINTRTerminate(DWORD dwDevice);

  // Functions not exported
  BOOL  CALLBACK PmacINTRInit(DWORD dwDevice,DWORD dwCallback,DWORD dwFlags,
                              DWORD dwUser,ULONG mask);
  VOID  CALLBACK PmacINTRCallback(DWORD dwDevice);
  VOID  CALLBACK PmacINTRQueue(DWORD dwDevice,DWORD dwEvent);
  VOID  CALLBACK PmacINTRComplete(DWORD dwDevice,DWORD dwEvent);
  BOOL  CALLBACK PmacINTRProcessFunction(DWORD dwDevice,MCFUNC Func,DWORD Param,
                    LPDWORD pResult);
  DWORD CALLBACK PmacINTRThreadInit(DWORD *dwDev);
  VOID  PmacAddINTRCallback(DWORD dwDevice,DWORD dwCallback,DWORD dwFlags,
                             DWORD dwUser,ULONG ulMask);

  #ifdef __cplusplus
}
  #endif

#endif // _INTR_H
