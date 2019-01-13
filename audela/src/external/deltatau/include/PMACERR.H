/***************************************************************************
  (C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992

  Title:    error.h

  Version:  1.00

  Date:   11/18/1992

  Author(s):  Dennis Smith

  Header file for PMAC Dual Ported RAM communications errors.

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------

***************************************************************************/
#ifndef _ERROR_H
  #define _ERROR_H

///////////////////////////////////////////////////////////////////////////
// Error defines for system
  #define SYS_FATAL_FERR    0X0001
  #define SYS_WARN_FERR   0X0002
  #define SYS_SERVO_ERR   0X0004
  #define SYS_REENTRY_ERR   0X0008
  #define SYS_MEM_CHKSUM    0X0010
  #define SYS_PROM_CHKSUM   0X0020
  #define SYS_RUNTIME_ERR   0X0040
  #define SYS_CIR_RAD_ERR   0X0080
  #define SYS_AMP_FAULT   0X0100

// Error Defines for communications
  #define ERR_BAUDSEARCH    -27
  #define ERR_VBG_DPRNOTON    -28
// Variable background buffer defines
  #define ERR_VBG_MAXUSERS    -100 // Maximum number of users achieved in Variable Background Data Buffer
  #define ERR_VBG_MAXENTRIES  -101 // Maximum number of entries (>128) in Variable Background Data Buffer

// Polled Checksum communication defines
  #define CHECKSUMACKOK   -20   // good acknowlegde checksum
  #define CHECKSUMDATAOK    -21 // good data checksum
  #define CHECKSUMTIMEOUT   -22 // it times out
  #define CHECKSUMDATABAD   -23 // bad data checksum
  #define CHECKSUMACKBAD    -24 // bad command acknowledge checksum

/*
///////////////////////////////////////////////////////////////////////////
// Error Defines for communications
#define ERR_SYNTAX      -1  // comm returned BELL
#define ERR_COMMAND     -2  // comm returned 0x0800 and ERROR#
#define ERR_PORTRANGE   -25
#define ERR_BAUDRANGE   -26
#define ERR_BAUDSEARCH    -27
#define ERR_SERIAL_NOPMAC -28
#define ERR_BUS_NOPMAC    -29
#define ERR_DPR_NOPMAC    -30
#define ERR_DPR_NOBUS   -31
#define ERR_DPR_NOALLOC   -32
#define ERR_DPR_BADADDR   -33
#define ERR_DPR_CHECKSUM  -34
#define ERR_DPR_MEMCHECK  -35
#define ERR_INTR_NOBUS    -40


// Initialization errors (invalid parameters, or procedure etc.)
#define ERR_BUILDCOMM     -50 // BuildComm() routine failed
#define ERR_SETCOMMSTATE    -51 // SetCommstate routine failed
#define ERR_SER_NOPMAC      -53 // Unable to find PMAC
#define ERR_BAD_INIT    -54 // Unable to establish communication
#define ERR_NO_MEMORY       -55 // Could not allocate structure or buffer

*/
/*#define ERR_MAX_TERM    -201  // Maximum number of terminals already open
#define ERR_NO_MEMORY -202  // No memory to allocate buffer or structure
#define ERR_BAD_ADDRESS -203  // Bad base address
#define ERR_BI_OPEN     -205    // Commun. already established by this method.
#define ERR_SI_OPEN   -206  // Commun. already established by this method.
#define ERR_PORTRANGE -207  // Invalid port range
#define ERR_BAUDRANGE -208    // Unsupported baudrange
*/
//                  established
///////////////////////////////////////////////////////////////////////////
// Functions
  #ifdef __cplusplus
extern "C" {
  #endif

//int _export GetError(void);
//int _export GetErrorStringA(int cbSize, LPSTR errorString);

  #ifdef __cplusplus
}
  #endif

#endif

