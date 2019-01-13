/*
 * mckernel.h
 *
 * 32-bit Motion Control Device Driver
 *
 * Definition of interface between hardware-specific portions of
 * kernel driver and the helper library mckernel.lib
 *
 * The hardware-specific portion of a motion control driver will
 * have an NT-specific DriverEntry function that will call Init()
 * to initialise the helper library after performing hardware detect and
 * initialise. All NT interaction will then be done by the library mckernel.lib
 * calling back to the hardware-specific code only through the dispatch
 * table below.
 *
 * All h/w specific functions are given a pointer to a PDEVICE_INFO structure
 * which they can pass to Inp(), Outp(). GetHWInfo() will return a
 * pointer to the hardware-specific data structure requested from Init().
 *
 */

#ifndef _MCKERNEL_
  #define _MCKERNEL_

/* include necessary headers so that hardware-specific callers do not
 * explicitly reference NT-specific headers.
 */

  #if defined(_NT)
    #include <ntddk.h>
  #else
typedef long NTSTATUS;
  #endif

  #include <windef.h>
  #include <mcstruct.h>
  #include <mioctl.h>

  #define PT_PMAC1  1
  #define PT_PMAC2  2
  #define PT_PMACU  3
  #define PT_PMAC   4
  #define PT_PMAC1T 5
  #define PT_PMAC2T 6
  #define PT_PMACUT 7

/*****************************************************************************
 * hardware-independent device-extension data structure - opaque to
 * h/w specific functions.
*****************************************************************************/
typedef struct _DEVICE_INFO DEVICE_INFO, *PDEVICE_INFO;

/*****************************************************************************
 Callbacks to h/w specific code

 These are the hardware-specific functions called from the dispatcher
*****************************************************************************/
typedef struct __CALLBACK
{
  // called on device open/close - optional routines
  BOOLEAN (*DeviceOpenFunc)(PDEVICE_INFO);
  BOOLEAN (*DeviceCloseFunc)(PDEVICE_INFO);
  BOOLEAN (*InterruptInitFunc)(PDEVICE_INFO pDevInfo, ULONG interruptMask);
  BOOLEAN (*InterruptTermFunc)(PDEVICE_INFO);

  // returns TRUE if Interrupt needs Service
  ULONG   (*InterruptAcknowledge)(PDEVICE_INFO);

  // called on driver-unload
  BOOLEAN (*CleanupFunc)(PDEVICE_INFO);

} _CALLBACK, * P_CALLBACK;

/*****************************************************************************

 Support functions for NT
*****************************************************************************/
  #if defined(_NT)
/*
 * PmacCreateDevice
 *
 * Create the device object, and any necessary related setup, and
 * allocate device extension data. The device extension data is
 * a DEVICE_INFO struct plus however much data the caller wants for
 * hardware-specific data.
 *
 * parameters:
 *  pDriverObject - pointer to driver object (arg to DriverEntry)
 *  RegistryPathName - entry for this driver in registry (arg to DriverEntry)
 *  HWInfoSize - amount of data to allocate at end of DeviceExtension
 *  DeviceNumber - the nth Pmac to create a device object for
 *
 * returns pointer to device extension data as DEVICE_INFO struct.
 */
PDEVICE_OBJECT
  PmacCreateDevice(
      PDRIVER_OBJECT  pDriverObject,
      PUNICODE_STRING RegistryPathName,
      ULONG           HWInfoSize,
    UCHAR           DeviceNumber);

PDEVICE_INFO PmacDeleteDevice(PDRIVER_OBJECT  pDriverObject,PDEVICE_INFO pDevInfo);

/*
 * GetResources
 *
 * map port and frame buffer into system address space or i/o space, and
 * report resource usage of the ports, interrupt and physical memory
 * address used.
 *
 * Note: We do not connect the interrupt: this is not done until
 * a subsequent call to ConnectInterrupt(). We do, however, report
 * usage of the interrupt.
 *
 * we return TRUE if success, or FALSE if we couldn't get the resources.
 */
BOOLEAN
  GetResources(
      PDEVICE_INFO pDevInfo,
      PDRIVER_OBJECT pDriverObject,
      DWORD  PortBase,
      ULONG   NrOfPorts,
      ULONG   Interrupt,
      BOOLEAN bLatched,
      DWORD   FrameBuffer,
      ULONG   FrameLength);

// the dispatch routine to which all IRPs go
NTSTATUS Dispatch(
    IN PDEVICE_OBJECT pDeviceObject,
    IN PIRP pIrp
);


// cancel routine - set as cancel routine for pending irps (wait-error
// or add-buffer). Called to de-queue and complete them if cancelled.
VOID Cancel(
    IN PDEVICE_OBJECT pDeviceObject,
    IN PIRP pIrp
);

// call to unload or abort load of the driver
VOID Cleanup(PDRIVER_OBJECT pDriverObject);

/* interrupt service routine - returns TRUE if interrupt handled.
 * all interrupts come in here and are then dispatched to hw ack routine
 * the Context pointer is a pointer to DEVICE_INFO.
 */
BOOLEAN
  InterruptService(
      IN PKINTERRUPT pInterruptObject,
      IN PVOID Context
  );

/*
 * DPC routine scheduled in MC_InterruptService.
 */
VOID
  Deferred(
      PKDPC pDpc,
      PDEVICE_OBJECT pDeviceObject,
      PIRP pIrpNotUsed,
      PVOID Context
  );

/*
 * extract the next item from a cancellable queue of irps
 * if bCancelHeld is true, then we already hold the cancel spinlock so we
 * should not try to get it
 */
PIRP
  ExtractNextIrp(
      PLIST_ENTRY pQueueHead,
      BOOLEAN bCancelHeld
  );

/*
 * extract a specific IRP from the given queue, while possibly holding the
 * cancel spinlock already.
 */
PIRP
  ExtractThisIrp(
      PLIST_ENTRY pHead,
      PIRP pIrpToFind,
      BOOLEAN bCancelHeld
  );

/*
 * interlocked queue access functions
 */
/*
 * QueueRequest
 *
 * Add an irp to a cancellable queue.
 * Check the cancel flag and return FALSE if cancelled.
 * otherwise set the cancel routine and add to queue.
 *
 */
BOOLEAN
  QueueRequest(
      PIRP pIrp,
      PLIST_ENTRY pQueueHead,
      PDRIVER_CANCEL pCancelFunc
  );

/*
 * ReplaceRequest
 *
 * return a request to the head of a cancellable queue
 *
 */
BOOLEAN
  ReplaceRequest(
      PIRP pIrp,
      PLIST_ENTRY pQueueHead,
      PDRIVER_CANCEL pCancelFunc
  );


/*
 * increment the skipcount, and complete a wait-error irp if there
 * is one waiting.
 */
VOID
  ReportSkip(
      PDEVICE_INFO pDevInfo
  );

/*
 * queue a wait-error request to the queue of cancellable wait-error requests,
 * and return the irp's status (pending, cancelled, etc);
 *
 * When queuing, check the cancel flag and insert the correct cancel routine.
 *
 * If there is a skip-count to report, then:
 *   --- if there is another irp on the q already complete that and leave
 *       the current irp pending.
 *   -- otherwise return STATUS_SUCCESSFUL for this IRP, having written out
 *      the result data.
 *
 * Even if cancelled or complete, IoCompleteRequest will NOT have been called
 * for this request.
 */
NTSTATUS
QueueWaitError(
    PDEVICE_INFO pDevInfo,
    PIRP pIrp
);

/*****************************************************************************

*****************************************************************************/
  #endif // _NT

/*
 * ConnectInterrupt
 *
 * This assumes that GetResources() has already been called to report the
 * resource usage, and that the _CALLBACK table has been set up
 * to handle interrupts.
 *
 * returns TRUE if success.
 */
BOOLEAN ConnectInterrupt(
    PDEVICE_INFO pDevInfo,
    BOOLEAN bLatched);



// get the hardware specific portion of the device extension
PVOID GetHWInfo(PDEVICE_INFO);

// get card information stored for user retrieval
LONG  atol(PCHAR s,PCHAR *ep); // like strtol
int   GetRomDate(PDEVICE_INFO pDevInfo);
int   GetRomVersion(PDEVICE_INFO pDevInfo);
BOOL  GetLinkList(PDEVICE_INFO pDevInfo);
BOOL  GetLDSList(PDEVICE_INFO pDevInfo);
int   GetIVariableStr(PDEVICE_INFO pDevInfo,PCHAR str,UINT maxchar,UINT num);
int   GetPmacType(PDEVICE_INFO pDevInfo);
DWORD SetMaxMotors(PDEVICE_INFO pDevInfo);
LONG  GetIVariableLong(PDEVICE_INFO pDevInfo,ULONG num,LONG def);
BOOL  SetIVariableLong(PDEVICE_INFO pDevInfo,ULONG num,LONG val);
BOOL  GetScales(PDEVICE_INFO pDevInfo);
int   GetDPRAMAddress(PDEVICE_INFO pDevInfo,PDWORD adr);
BOOL  ConfigureDPRAM(PDEVICE_INFO pDevInfo);
int   SaveConfiguration(PDEVICE_INFO pDevInfo);

//============================================================================
// PORT Related macro,defines and functions
  #define PORT_STALL_USEC    5     // usec stall per retry period

// determine if PMAC card can be found on this port address
BOOL CardOnPort(PDEVICE_INFO pDevInfo);

//----------------------------------------------------------------------------------
//  Specialized flush, determines if PMAC is in the bus.
//  THEORY: If no card exists in bus at the specified i/o address then it
//      will appear that there is an infinite amount of characters of type
//      0xFF to be stripped.  This function is useful to initiate communication
//      on the bus since a deadlock situation may occur otherwise.
//----------------------------------------------------------------------------------
BOOL PmacPingAndClean(PDEVICE_INFO pDevInfo);

// output one byte from the port at bOffset offset from the port base address
VOID Outp(PDEVICE_INFO pDevInfo, BYTE bOffset, BYTE bData);
// input one byte from the port at bOffset offset from the port base address
BYTE Inp(PDEVICE_INFO pDevInfo, BYTE bOffset);

// flush bus port
void FlushPort(PDEVICE_INFO pDevInfo);
// write a character to PMAC bus port
int  WriteCharPort(PDEVICE_INFO pDevInfo, UCHAR outchar);
// write buffer to bus port
int  WriteLinePort(PDEVICE_INFO pDevInfo,PUCHAR str);
// see if port has a read ready
BOOL PortIsReadReady(PDEVICE_INFO pDevInfo);
// read bus port into buffer until eol with wait
int ReadLinePort(PDEVICE_INFO pDevInfo,PUCHAR str,UINT maxchar);
// send a command then read bus port into buffer until eot or err or timeout
int GetResponsePort(PDEVICE_INFO pDevInfo,PUCHAR s,UINT maxchar,
                        PUCHAR outstr);
// Get response to control characters
int GetControlResponse(PDEVICE_INFO pDevInfo ,CHAR inChar,
             PCHAR outStr,DWORD maxChars);

//============================================================================
// MEMORY Related macro,defines and functions
  #define MEM_STALL_USEC    5     // usec stall per retry period

/*
The macros below are based on this PMAC DPRAM ASCII structure

struct ascii {
  unsigned short  sendready:1;  // Y:$D18B output control word 0x62C
  unsigned short    pad:15;
  unsigned short  ctrlchar;     // X:$D18B control character
  char      outstr[MAXAOUT];    // $D18C - $D1B3 output string buffer
  unsigned short  instatus;     // Y:$D1B4 input control word 0x6D0
  unsigned short  charcount;    // X:$D1B4 input character count
  char      instr[MAXAIN];      // $D1B5 - $D1F4 input string buffer
};
*/

// Turbo ASCII memory port macros ---------------------------------------------
// Base = 0x0E9C
  #define SENDREADY_T     (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xE9C)) == 0)
  #define NOT_SENDREADY_T (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xE9C)) > 0)
  #define SET_SENDREADY_T (WRITE_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xE9C),1))
  #define CTRL_CHAR_T     (PUCHAR)(pDevInfo->FrameBase + 0xE9E)
  #define READREADY_T     (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40)) > 0)
  #define NOT_READREADY_T (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40)) == 0)
  #define SET_READREADY_T (WRITE_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40),0))
  #define ERROR_SET_T     ((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40)) & 0x8000) > 0)
  #define ERROR_T         (((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40))) &  0x0F) + \
                        (((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40))) >> 4) & 0x0F) * 10)
  #define NUM_CHARS_T     (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF42)) - 1)
  #define MEM_ACK_T       ((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40)) & 0x000F) == 0x0006)
  #define MEM_CR_T        ((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0xF40)) & 0x000F) == 0x000D)

// Pmac1/2 ASCII memory port macros ---------------------------------------------
// Base = 0x062C
  #define SENDREADY     (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x62C)) == 0)
  #define NOT_SENDREADY (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x62C)) > 0)
  #define SET_SENDREADY (WRITE_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x62C),1))
  #define CTRL_CHAR     (PUCHAR)(pDevInfo->FrameBase + 0x62E)
  #define READREADY     (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0)) > 0)
  #define NOT_READREADY (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0)) == 0)
  #define SET_READREADY (WRITE_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0),0))
  #define ERROR_SET     ((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0)) & 0x8000) > 0)
  #define ERROR2        (((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0))) &  0x0F) + \
                        (((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0))) >> 4) & 0x0F) * 10)
  #define NUM_CHARS     (READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D2)) - 1)
  #define MEM_ACK       ((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0)) & 0x000F) == 0x0006)
  #define MEM_CR        ((READ_REGISTER_USHORT((PUSHORT)(pDevInfo->FrameBase + 0x6D0)) & 0x000F) == 0x000D)

// determine if PMAC card has DPRAM and can communicate through it
BOOL CardHasMem(PDEVICE_INFO pDevInfo);
// configure card memory address
void ConfigureMem(PDEVICE_INFO pDevInfo);
// Get a portion of DPRAM
UINT GetMem(PDEVICE_INFO pDevInfo,PMEM_BUFFER pMemBuffer);
// Set a portion of DPRAM
UINT SetMem(PDEVICE_INFO pDevInfo,PMEM_BUFFER pMemBuffer);
// flush mem port
void FlushMem(PDEVICE_INFO pDevInfo);
// write a character to pmac dpram ascii port (ie. 'ch' + '\0')
UINT WriteCharMem(PDEVICE_INFO pDevInfo,UCHAR outchar);
// write a control character to pmac dpram ascii port
UINT WriteCtrlCharMem(PDEVICE_INFO pDevInfo,UCHAR outchar);
// write a character to frame ASCII buffer
UINT WriteLineMem(PDEVICE_INFO pDevInfo,PUCHAR str);
// see if dpram port has a read ready
BOOL MemIsReadReady(PDEVICE_INFO pDevInfo);
// read frame memory into buffer until eol with wait
int  ReadLineMem(PDEVICE_INFO pDevInfo,PUCHAR str);
//----------------------------------------------------------------------------------
// This function sends the requested control character between 1 - 26 to the
// PMAC. If the request is known not to return any characters it sets the EOT
// status bit then exits immediately to avoid any timeout.  If the request is known
// to return "1" line of data the function grabs the data then returns with EOT set.
// If the funtion returns "n" lines of data the function doesn't attempt to grab
// any data and doesn't set the EOT status so it is up to the caller to grab the data
//-----------------------------------------------------------------------------------
int GetControlResponseMem(PDEVICE_INFO pDevInfo ,CHAR inChar,PCHAR outStr,DWORD maxChars);

/*
 * i/o memory on adapter cards such as the frame buffer memory cannot
 * be accessed like ordinary memory on all processors (especially alpha).
 * You must read and write this memory using the following macros. These are
 * wrappers for the appropriate NT macros.
 */

// return one ULONG from the frame buffer at p
  #ifdef i386

    #define ReadIOMemoryULONG(p)     ( * (DWORD volatile *)p)

// return a word from the frame buffer at p
    #define ReadIOMemoryUSHORT(p)    ( * (USHORT volatile *)p)

// return a byte from the frame buffer at p
    #define ReadIOMemoryBYTE(p)      ( * (unsigned char volatile *) p)

  #else

    #define ReadIOMemoryULONG(p)     READ_REGISTER_ULONG((PUCHAR)p)

// return a word from the frame buffer at p
    #define ReadIOMemoryUSHORT(p)    READ_REGISTER_USHORT((PUCHAR)p)

// return a byte from the frame buffer at p
    #define ReadIOMemoryBYTE(p)      READ_REGISTER_UCHAR(p)

  #endif

// read a block of c bytes from the frame buffer at s to memory at d
  #define ReadIOMemoryUCHAR(d, s, c)   READ_REGISTER_BUFFER_UCHAR(s, d, c)

// write a byte b to the frame buffer at p
  #define WriteIOMemoryBYTE(p, b)  WRITE_REGISTER_UCHAR(p, b)

// write a word w to the frame buffer at p
  #define WriteIOMemoryUSHORT(p, w)    WRITE_REGISTER_USHORT((PUSHORT)p, w)

// write a ULONG l to the frame buffer at p
  #define WriteIOMemoryULONG(p, l)     WRITE_REGISTER_ULONG((PULONG)p, l)

// write a block of c bytes to the frame buffer d from memory at s
  #define WriteIOMemoryUCHAR(d, s, c)  WRITE_REGISTER_BUFFER_UCHAR(d, s, c)


P_CALLBACK GetCallbackTable(PDEVICE_INFO);

/* get a pointer to the frame buffer mapped into system memory */
PUCHAR GetFrameBuffer(PDEVICE_INFO);


/* this function is a wrapper for KeSynchronizeExecution (at least in the NT
 * version). It will call back the function specified with the context
 * argument specified, having first disabled the video interrupt in
 * a multi-processor safe way.
 */
typedef BOOLEAN (*PSYNC_ROUTINE)(PVOID);
BOOLEAN SynchronizeExecution(PDEVICE_INFO, PSYNC_ROUTINE, PVOID);

/*
 * This function can be used like SynchronizeExecution(), to sync
 * between the captureservice routine and the passive-level requests. This
 * will not necessarily disable interrupts. On win-16, this function may be
 * the same as SynchronizeExecution(). On NT, the CaptureService func
 * runs as a DPC, at a lower interrupt priority than the isr itself, and
 * so can be protected using this (spinlock-based) function without having
 * to disable all interrupts.
 */
BOOLEAN SynchronizeDPC(PDEVICE_INFO, PSYNC_ROUTINE, PVOID);


/*
 * AccessData() gives access to the data in kernel mode in a safe way.
 * It calls the given function with the address and size of the buffer
 * after any necessary mapping, and wrapped in exception handlers
 * as necessary.
 *
 * This function cannot be called from the InterruptAcknowledge or
 * ServiceCapture call back functions - it must be running in the
 * context of the calling thread (in kernel mode).
 */
typedef BOOLEAN (*PACCESS_ROUTINE)(PDEVICE_INFO, PUCHAR, ULONG, PVOID);
BOOLEAN AccessData(PDEVICE_INFO, PUCHAR, ULONG, PACCESS_ROUTINE, PVOID);

/* these functions allocate and free non-paged memory for use
 * in kernel mode, including at interrupt time.
 */
PVOID AllocMem(PDEVICE_INFO, ULONG);
VOID FreeMem(PDEVICE_INFO, PVOID, ULONG);


/*
 * delay for a number of milliseconds. This is accurate only to
 * +- 15msecs at best.
 */
VOID Delay(int nMillisecs);

/* block for given number of microseconds by polling. Not recommended
 * for more than 25 usecs.
 */
VOID Stall(int nMicrosecs);

#endif // _MCKERNEL_
