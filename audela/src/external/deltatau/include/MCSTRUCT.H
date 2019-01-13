
/*
 * mcstruct.h
 *
 * 32-bit Motion Control Device Driver
 *
 * This header describes structures used in the interface between the
 * kernel driver and the user-mode dll.
 */

#ifndef _MCSTRUCT_
  #define _MCSTRUCT_

// Buffer limits
  #define MAX_BUSBUFFER   256
  #define MAX_DPRBUFFER   160

/* --- pmac configuration buffer layout --------------------------------- */

typedef struct _CONFIG_INFO {
    ULONG ulSize;   /* size of struct including size field */
    BYTE ulData[1]; /* (ulSize - sizeof(ULONG)) bytes of data */
} CONFIG_INFO, *PCONFIG_INFO;

/* --- pmac dpram buffer layout ----------------------------------------- */

typedef struct _MEMINITBUFFER {
    HANDLE  hProcess; // process handle
    PVOID   pAddress; // pointer to base of virtual ram
} MEMINITBUFFER, * PMEMINITBUFFER;

/* --- pmac interrupt buffer layout ------------------------------------- */
typedef struct _INTRBUFFER {
    PCH     lpData;          // buffer data area
    ULONG   dwBufferLength;  // length of buffer
    DWORD   dwInterruptType; // not used by kernel interface
} INTRBUFFER, * PINTRBUFFER;

#endif //_MCSTRUCT_
