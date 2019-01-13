//====================================================================
//
//                         COPYRIGHT NOTICE
//
//   Copyright (C) 1995-1997 VME Microsystems International Corporation
//       International copyright secured.  All rights reserved.
//--------------------------------------------------------------------//
//
// $Workfile:   vmemgr.h  $
// $Revision: 1.1 $
// $Modtime:   08 May 1997 09:10:08  $
//
//--------------------------------------------------------------------//
//////////////////////////////////////////////
// vmemgr.h
//
// You must include windows.h BEFORE you include this file.
//
// Applications using the IOWorks VME Manager DLL should include
// this file in all their sources that use that DLL.
//
// Then link with the import library (vmemgr.lib).
//
///////////////////////////////

#ifndef VMEMGR_DEFINED
  #define VMEMGR_DEFINED


  #ifdef __cplusplus
extern "C"
{
  #endif

  //////////////////////////////////////////////////////
  // SYMBOLS
  //////////////////////////////////////////////////////

  /////////////////////////
  // Our custom error return codes. Other error codes are gotten
  // from windows.h (which includes winerror.h)
  //
  #define V_ERROR_BUSERR                                0x20000001
  #define V_ERROR_MAPPING_SPANS_A_THRESHOLD             0x20000003


  /////////////////////////
  // flags used as arguments to various vme access functions
  #define V_BIG_ENDIAN     123
  #define V_LITTLE_ENDIAN  124
  #define V_LOCKBUS           0x80000000 // (not yet supported)
  #define V_NO_BUSERR_CHECK   0x40000000
  #define V_THREAD_UNSAFE      0x20000000
  #define V_HOLDOFF_INTERRUPTS      0x10000000
  #define V_NO_BLT 0x08000000
  #define V_BLOCKING       0x00000000    // default flag is zero
  #define V_NON_BLOCKING     0x04000000
  #define V_SOFT_BYTE_SWAP 0x02000000

  /////////////////////////
  // Size of data (byte, word, long, or VME64)
  //
  #define V_DATA8            1
  #define V_DATA16           2
  #define V_DATA32           4
  #define V_DATA64           8


  /////////////////////////
  // Bus request level to use.
  //
  #define V_LEVEL_BR0        0
  #define V_LEVEL_BR1        1
  #define V_LEVEL_BR2        2
  #define V_LEVEL_BR3        3

  /////////////////////////
  // Bus release mode
  //
  #define V_ROR            101 // Release on request
  #define V_RWD            102 // Release when done
  #define V_ROC            103 // Release on command
  #define V_BCAP           104 // VME bus capture and hold

  /////////////////////////
  // Bus priority scheme if board is the arbiter
  //
  #define V_ARB_PRI        109
  #define V_ARB_RRS        110


  /////////////////////////
  // Supported accessing modes
  //
  #define V_A16UD          0x29 // 16 bit address as user to data memory
  #define V_A16UP          0x2A // 16 bit address as user to program memory (not in VMEbus spec)
  #define V_A16SD          0x2D // 16 bit address as supervisor to data memory
  #define V_A16SP          0x2E // 16 bit address as supervisor to program memory  (not in VMEbus spec)
  #define V_A24UD          0x39 // 24 bit address as user to data memory
  #define V_A24UP          0x3A // 24 bit address as user to program memory
  #define V_A24SD          0x3D // 24 bit address as supervisor to data memory
  #define V_A24SP          0x3E // 24 bit address as supervisor to program memory
  #define V_A32UD          0x09 // 32 bit address as user to data memory
  #define V_A32UP          0x0A // 32 bit address as user to program memory
  #define V_A32SD          0x0D // 32 bit address as supervisor to data memory
  #define V_A32SP          0x0E // 32 bit address as supervisor to program memory



  //////////////////////////////////////////////////////
  // STRUCTURES
  //////////////////////////////////////////////////////

  #ifndef ISR3_DRIVER_CODE

  /////////////////////////
  // Holds all the info for one interrupt ID.
  //
  typedef struct
  {
      DWORD (__cdecl *HandlerFunction)(DWORD ID);
      DWORD IntLevel;
      DWORD SentCount;
      DWORD RcvdCount;
  } INTIDINFO;

  //////////////////////////////////////////////////////
  // Holds all the info for one interrupt level
  //
  typedef struct
  {
      DWORD LastSentID;
      DWORD LastRcvdID;
      DWORD Enabled;
      DWORD SentCount;
      DWORD RcvdCount;
  } INTLEVELINFO;


  //////////////////////////////////////////////////////
  // PROTOTYPES
  //////////////////////////////////////////////////////

  //
  // For applications, we can define EXPORT (as "__declspec(dllimport)" ) for performance.
  // Only when building the DLL do we override this to be "__declspec(dllexport)".
  // But the default is nothing since that is more portable accross compilers.
    #ifndef EXPORT
  //#define EXPORT __declspec(dllimport)
      #define EXPORT
    #endif

  EXPORT DWORD __stdcall vmeRtGetTime(DWORD *Time);
  EXPORT DWORD __stdcall vmeRtSleep(DWORD Time);
  EXPORT DWORD __stdcall vmeRtEnable(DWORD Flags,DWORD Reserved2);
  EXPORT DWORD __stdcall vmeRtSleepUntil(DWORD EndTime);


  EXPORT DWORD __stdcall vmeInit(DWORD Reserved,DWORD Reserved2);
  EXPORT DWORD __stdcall vmeTerm(DWORD Reserved);
  EXPORT DWORD __stdcall vmeLockVmeBus(DWORD Reserved,DWORD Flags);
  EXPORT DWORD __stdcall vmeUnlockVmeBus(DWORD Reserved,DWORD Flags);
  EXPORT DWORD __stdcall vmeReadLibVersion(DWORD Reserved,char *StrVersion);
  EXPORT DWORD __stdcall vmeInstallInterruptHandler(DWORD Reserved,DWORD IntNum,DWORD ID,DWORD (__cdecl *HandlerFunction)(DWORD ID));
  EXPORT DWORD __stdcall vmeInstallInterruptHandlerEx(DWORD Reserved,DWORD IntNum,DWORD ID, DWORD (__cdecl *HandlerFunction)(DWORD ID),DWORD Flags,DWORD Priority,DWORD Reserved3);
  EXPORT DWORD __stdcall vmeGenerateInterrupt(DWORD Reserved,DWORD IntNum,DWORD ID,DWORD Enable);
  EXPORT DWORD __stdcall vmeGetSlaveRam(DWORD Reserved, DWORD *VmeAdr,DWORD *BlockSize,void **SlaveBase,DWORD *AccessMode,DWORD *Endian,DWORD Reserved2);
  EXPORT DWORD __stdcall vmeLockVmeWindow(DWORD Reserved,DWORD Size,DWORD Adr,DWORD *Handle,DWORD NumElements,DWORD AccessMode,DWORD Flags,DWORD RequestLevel,DWORD Timeout,DWORD Reserved2);
  EXPORT DWORD __stdcall vmeUnlockVmeWindow(DWORD Reserved,DWORD Handle);
  EXPORT DWORD __stdcall vmeGetVmeWindowAdr(DWORD Reserved,DWORD WinHandle,void **Adr);
  EXPORT DWORD __stdcall vmeFreeVmeWindowAdr(DWORD Reserved,DWORD WinHandle,void *Adr);
  EXPORT DWORD __stdcall vmeWriteSYSRESET(DWORD Reserved,BOOL State);
  EXPORT DWORD __stdcall vmeWriteSYSFAIL(DWORD Reserved,BOOL State);
  EXPORT DWORD __stdcall vmeReadSYSFAIL(DWORD Reserved,DWORD *State);
  EXPORT DWORD __stdcall vmeWriteBusEnable(DWORD Reserved,BOOL State);
  EXPORT DWORD __stdcall vmeWriteLED(DWORD Reserved,DWORD Code);
  EXPORT DWORD __stdcall vmeWriteArbitrationMode(DWORD Reserved,DWORD ArbitrationMode);
  EXPORT DWORD __stdcall vmeWriteBusReleaseMode(DWORD Reserved,DWORD Mode);
  EXPORT DWORD __stdcall vmeReadSCON(DWORD Reserved,DWORD *State);
  EXPORT DWORD __stdcall vmeReadBUSERR(DWORD Reserved,DWORD *State);
  EXPORT DWORD __stdcall vmeReadACFAIL(DWORD Reserved,DWORD *State);
  EXPORT DWORD __stdcall vmeReadArbitrationTimeout(DWORD Reserved,DWORD *State);
  EXPORT DWORD __stdcall vmeReadVmeEx(DWORD Handle,DWORD Size,DWORD Adr,void *Data,DWORD NumElements,DWORD AccessMode,DWORD Flags,DWORD RequestLevel,DWORD Timeout,DWORD Reserved2);
  EXPORT DWORD __stdcall vmeWriteVmeEx(DWORD Handle,DWORD Size,DWORD Adr,void *Data,DWORD NumElements,DWORD AccessMode,DWORD Flags,DWORD RequestLevel,DWORD Timeout,DWORD Reserved2);
  EXPORT DWORD __stdcall vmeReadLED(DWORD Reserved,DWORD *State);
  EXPORT DWORD __stdcall vmeReadBusEnable(DWORD Reserved,DWORD *State);
  EXPORT DWORD __stdcall vmeReadBusTimeoutValue(DWORD Reserved,DWORD *TimeoutValue);
  EXPORT DWORD __stdcall vmeReadBusReleaseMode(DWORD Reserved,DWORD *Mode);
  EXPORT DWORD __stdcall vmeReadBusRequestLevel(DWORD Reserved,DWORD *RequestLevel);
  EXPORT DWORD __stdcall vmeReadBusArbitrationMode(DWORD Reserved,DWORD *ArbitrationMode);
  EXPORT DWORD __stdcall vmeReadDataSize(DWORD Reserved,DWORD *Size);
  EXPORT DWORD __stdcall vmeReadEndian(DWORD Reserved,DWORD *Endian);
  EXPORT DWORD __stdcall vmeReadAddress(DWORD Reserved,DWORD *Adr);
  EXPORT DWORD __stdcall vmeReadAddressModifier(DWORD Reserved,DWORD *AdrMod);
  EXPORT DWORD __stdcall vmeReadIntIDInfo(DWORD Reserved,DWORD ID,INTIDINFO *IntInfo);
  EXPORT DWORD __stdcall vmeReadIntLevelInfo(DWORD Reserved,DWORD Level,INTLEVELINFO *IntInfo);
  EXPORT DWORD __stdcall vmeReleasePointer(DWORD Reserved,PVOID Pointer);
  EXPORT DWORD __stdcall vmeMapSlaveRam(DWORD Reserved,DWORD *VmeAdr,DWORD *BlockSize,void **SlaveBase,DWORD AccessMode,DWORD Endian,DWORD Reserved2);
  EXPORT DWORD __stdcall vmeUnmapSlaveRam(DWORD Reserved,void *SlaveBase);



  EXPORT DWORD  __stdcall vmeReadDmaEx(DWORD Reserved,DWORD Handle,DWORD AccessSize,DWORD VmeAdr,void *DMABuf,DWORD NumBytes,DWORD AccessMode,DWORD Flags,DWORD RequestLevel,DWORD (__cdecl *CallbackFunction)(DWORD));
  EXPORT DWORD  __stdcall vmeWriteDmaEx(DWORD Reserved,DWORD Handle,DWORD AccessSize,DWORD VmeAdr,void *DMABuf,DWORD NumBytes,DWORD AccessMode,DWORD Flags,DWORD RequestLevel,DWORD (__cdecl *CallbackFunction)(DWORD));
  EXPORT DWORD  __stdcall vmeLockDmaWindow(DWORD Reserved,DWORD *Handle,DWORD AccessSize,DWORD VmeAddr,DWORD MaxRangeSize,DWORD AccessMode,DWORD Flags,DWORD RequestLevel,DWORD (__cdecl *CallbackFunction)(DWORD),DWORD Reserved2);
  EXPORT DWORD  __stdcall vmeUnlockDmaWindow(DWORD Reserved,DWORD Handle);

  EXPORT void* __stdcall vmeCallocCommonRAM(DWORD NumElements, DWORD ElementSize);
  EXPORT void  __stdcall vmeFreeCommonRAM(void *Address);
  EXPORT void* __stdcall vmeMallocCommonRAM(DWORD Size);
  EXPORT void* __stdcall vmeReallocCommonRAM(void *Address,DWORD Size);


  // The following functions deal with maintaining a custom ISR device driver - May '96
  EXPORT DWORD __stdcall vmeEnableCustomInterruptHandler(ULONG vector, ULONG irqLevel, WCHAR isr3Name[]);
  EXPORT DWORD __stdcall vmeDisableCustomInterruptHandler(WCHAR isr3Name[]);
  EXPORT DWORD __stdcall vmeGetCommonRamPtr(void **commonRamPtr, WCHAR isr3Name[]);
  EXPORT DWORD __stdcall vmeGetIpcDataPtr(void **ipcDataPtr);
  EXPORT DWORD __stdcall vmeGetCustomIsrId(WCHAR isr3Name[], char *isr3Id);
  EXPORT DWORD __stdcall vmeGetLastDriverError (void);

  // The following is used by the interrupt dispatcher. DO NOT CALL IT YOURSELF.
  EXPORT DWORD __stdcall vmeGlobalInterruptDispatcher(DWORD Reserved,void *Reserved2);

  // BEGIN UNSUPPORTED
  // The following program code up to the words "END UNSUPPORTED" should not be used.
  // It is present only as preparation for certain functionality that
  // may be supported in later releases of IOWorks Access.
  EXPORT DWORD __stdcall vmeReadSlave(DWORD Reserved,DWORD Size,DWORD Adr,void *Data,DWORD NumElements);
  EXPORT DWORD __stdcall vmeWriteSlave(DWORD Reserved,DWORD Size,DWORD Adr,void *Data,DWORD NumElements);

  // Visual basic doesn't have a poke and peek function, so that's what these are for
  EXPORT DWORD __stdcall vmeWriteMem(DWORD Reserved,DWORD DestPointer,void *Src,DWORD NumBytes);
  EXPORT DWORD __stdcall vmeReadMem(DWORD Reserved,DWORD SrcPointer,void *Dest,DWORD NumBytes);
  // END UNSUPPORTED


  #endif // ifndef ISR3_DRIVER_CODE

  #ifdef __cplusplus
} // end extern "C"
  #endif


#endif // ifndef VMEMGR_DEFINED



