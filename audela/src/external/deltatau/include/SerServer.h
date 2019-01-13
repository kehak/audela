#ifndef _SERSERVER_H
#define _SERSERVER_H

#include <windows.h>
#include <windowsx.h>

// modif Michel
// suppression de #include <iostream.h> qui faisait planter la compilation avec VC9 car iostream.h  n'existe plus.
//#include <iostream.h>

#include <string.h>
#include <conio.h>

#include "resource.h"// Included for serial error code defines which match strings

////// DEFINES /////////////////////////////////////////////////////////////
#define MAX_USERS       4

#define AC_SERVER_IS_RUNNING 0xFFFFFFFF  // Used to check if server is running

#define AC_NO_OPERATION   0  // No op
#define AC_INIT_COMM      1  // Initialize Communicaiton Call
#define AC_SHUTDOWN_COMM  2  // Shutdown Communication Call
#define AC_GETRESPONSE    3  // GetResponse Call
#define AC_GETLINE        4  // GetLine Call
#define AC_SENDLINE       5  // SendLine Call
#define AC_SENDCHAR       6  // SendChar Call
#define AC_READREADY      7  // ReadReady Call
#define AC_FLUSH          8  // Flush Call
#define AC_GETCONTROLRESPONSE 9 // GetControlResponse Call
#define AC_DOWNLOAD_FIRMWARE 10 // Download firmware
#define AC_CHECKSUM_ENABLE   11  // Turn on/off checksum
#define AC_CHECKSUM_GETRESPONSE  13  // GetResponseChecksum
#define AC_CHECKSUM_SENDLINE 14      // SerCheckResponse
#define AC_CHECKSUM_GETLINE 15  // SERGetLineCheck

#define CTRL_A          1
#define CTRL_B          2
#define CTRL_C          3
#define CTRL_D          4
#define CTRL_E          5
#define CTRL_F          6
#define CTRL_G          7
#define CTRL_H          8
#define CTRL_I          9
#define CTRL_J         10
#define CTRL_K         11
#define CTRL_L         12
#define CTRL_M         13
#define CTRL_N         14
#define CTRL_O         15
#define CTRL_P         16
#define CTRL_Q         17
#define CTRL_R         18
#define CTRL_S         19
#define CTRL_T         20
#define CTRL_U         21
#define CTRL_V         22
#define CTRL_W         23
#define CTRL_X         24
#define CTRL_Y         25
#define CTRL_Z         26

#define ERR_OK           0    // no configuration error

#define MEM_MAP_INPUT_SIZE 200000
#define SO_FLUSHTIMEOUT    15     // Timeouts used when running stand alone.
#define SO_CHARTIMEOUT     1000

////// STRUCTURES //////////////////////////////////////////////////////////
typedef struct server
{
  DWORD   dwActionCode;  // i.e. AC_INITCOMM
  DWORD   dwParam1;      // i.e. COM2
  DWORD   dwParam2;      // i.e. 38400
  DWORD   dwParam3;      // i.e. Parity
  char    InputBuffer[MEM_MAP_INPUT_SIZE];
  char    OutputBuffer[256];
  DWORD   dwReturnValue;
  DWORD   SERCommError;
  DWORD   dwSERFlushTimeout;
  DWORD   dwSERFlushTimeoutCount;
  DWORD   dwSERCharTimeout;
  DWORD   dwSERCharTimeoutCount;
} SERVER;

typedef struct serverInfo
{
  HANDLE    hPM;
  SERVER  * pPM;

// Serial
  HANDLE        hCom;
  DCB           dcb;
  COMMTIMEOUTS  cto;
  DWORD         port;
  DWORD         baudrate;
  short         SERCommError;
  BOOL          Initialized;

} SERVER_INFO;

extern SERVER_INFO si;

////// FUNCTIONS ///////////////////////////////////////////////////////////
#ifdef __cplusplus
extern "C" {
#endif

BOOL InitCommunication(DWORD dwDeviceNum);
BOOL ShutdownCommunication(DWORD dwDeviceNum);

BOOL InitMemoryMapping(DWORD dwPmacDevice);
BOOL ShutdownMemoryMapping(DWORD dwPmacDevice);

int GetCMDLine(int argc, char **argv);


void show_printf (char *lbuf);
#ifdef __cplusplus
}
#endif

#endif
