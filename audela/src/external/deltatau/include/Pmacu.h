/*
 * pmacu.h
 *
 * 32-bit Motion Control Device Driver
 * Data structures and function entry-points for Pmac user-mode driver
 *
 */

#ifndef _PMACU_H_
  #define _PMACU_H_

//
// include needed headers
//
  #include <windows.h>
  #include <windowsx.h>
  #include <mcstruct.h>
  #include <common.h>
  #include "private.h"
  #include "dpr.h"
  #include "intr.h"
  #include "gather.h"

  #include "serserver.h"

  #ifdef _CUI_
    #define _MAX_PATH MAX_PATHNAME_LEN
  #endif

#define LINKLIST_FILE "PMAC_LINKLIST.INI"

// forward declarations
typedef struct _USER_HANDLE USER_HANDLE, *PUSER_HANDLE;
typedef struct _GLOBAL_HANDLE GLOBAL_HANDLE, *PGLOBAL_HANDLE;
typedef enum { BUS, DPR, SER } ASCIIMODE;
typedef enum { BT_PC, BT_VME } BUSTYPE;
typedef enum { VH_VMIC, VH_NONE } VMEHOSTTYPE;
typedef enum {LT_PCBUS, LT_RING0, LT_SERIALPORT, LT_VMEBUS} LOCATIONTYPE;
typedef enum {PT_PMAC1=1,PT_PMAC2=2,PT_PMACU=3,PT_PMAC=4,PT_PMAC1T=5,PT_PMAC2T=6,PT_PMACUT=7} PMACDEVICETYPE;
// PT_PMAC is the transition marker between PMAC and TURBO do not remove



/////////////////////////////////////////////////////////////////////////////
// Process User Handle Sructure
/////////////////////////////////////////////////////////////////////////////
typedef struct _USER_HANDLE
{
  // Keep track of structure size to detect for memory corruption
  DWORD      dwSize;
  DWORD      dwUser;                            // User No. for this device
  HANDLE     hDriver;                           // Handle to ring zero driver
  HANDLE     hAsynch;                           // Asynchronous handle to ring zero driver
  HANDLE     hMutex;                            // Global mutex handle
  HANDLE     hPM;                               // Handle to PMAC SerialServer Map
  SERVER     *pPM;
  HANDLE     hCom;                              // Serial handle
  ASCIIMODE  ascii_comm;                        // current mode of ascii comm
                                                // Command logging stuff
  BOOL       dCommandLogging;                   // Command Logging Enabled
  TCHAR      tcComandLoggingFilename[MAX_PATH]; // Command Logging File Name
  UINT       uMaxCommandLoggingFileSize;        // Command Logging Max. file size
  HANDLE     hCommandLoggingFileHandle;         // Command Logging File Handle
  CHAR       languageDll[_MAX_PATH];            // Language translation DLL name

  // DPRAM
  PVOID                 DPRAM;             // pointer to base of DPRAM (FIFO)
  struct cpane          *DPRCPanel;        // pointer to control panel
  struct cpane          *DPRCPanelTurbo;   // ?? pointer to Turbo control panel
  struct realt          *DPRRTBuffer;      // pointer to real time buffer
  struct realtTURBO     *DPRRTBufferTurbo; // pointer to Turbo real time buffer
  struct backg          *DPRBGBuffer;      // pointer to background buffer
  struct backgTURBO     *DPRBGBufferTurbo; // pointer to Turbo background buffer
  struct ascii          *DPRAscii;         // pointer to ASCII-comm buffer
  struct backgvar       *DPRbkvbf;         // $D1FA
  struct backgvar       *DPRbkvbfTurbo;    // ??? temp
  struct backgvarwrite  *DPRbgvWrite;      // $D1F5, BGV Write Buffer
  struct rotbuf         *DPRrotbf[16];     // DPR Bin Rot Status PTR $D1FC,$D1F7
  struct gatbuf         *DPRgatbf;         // $D1FF

  struct backgvarbuf_status *bgv_status[MAX_VBGBUF_USERS]; // Background variable data
  DWORD  *DPRrotbuffer[16];                                // DPR Binary Rotary Buffer Start

  // Gather stuff
  double *pGatherData[MAXGATHERS2]; // Pointers to gathered data
  double *pRTGatherData;            // Pointer to gathered data

  // Interrupt Stuff
  // inter-thread sync data
  DWORD  ThreadId;
  HANDLE hThread;
  MCFUNC FunctionCode;
  DWORD  FunctionArg;
  DWORD  FunctionResult;
  HANDLE hWorkEvent;
  HANDLE hCompleteEvent;
  BOOL   bTerminateThread;

  // worker thread data
  MCCALLBACK Callback;                // interrupt callback function
                                      //UINT   CallbackUsers;                  // number of interrupt callback users
                                      //MCCALLBACK Callback[MAX_DEVICE_USERS]; // interrupt callback function
  HANDLE hEvents[1 + ALL_INTERRUPTS]; // events to wait on
  BOOL   EventsFired[ALL_INTERRUPTS]; // currently in use events

  int    iSentCount;                         // count of buffers with kernel
  DWORD  IntsOutstanding;                    // number of wait-error outstanding
  DWORD  WaitResult;
  DWORD  SkipCount;
  OVERLAPPED overlapped[1 + ALL_INTERRUPTS]; // 1 for each async i/o
  INTRBUFFER Buffer;

  HWND   hWnd; // Window handle of app for use w/ messages boxes

} USER_HANDLE, *PUSER_HANDLE;


///////////////////////////////////////////////////////////////////////////////
// Global
///////////////////////////////////////////////////////////////////////////////
typedef struct _GLOBAL_HANDLE
{
  // Keep track of structure size to detect for memory corruption
  DWORD dwSize;
  // common data
  DWORD  dwUserCount; // User count for this device
                      //HANDLE hDriver;               // Handle to ring zero driver
                      //HANDLE hAsynch;               // Asynchronous handle to ring zero driver

  CHAR   version[VERSION_BUFFER_SIZE]; // store version string
  CHAR   date[DATE_BUFFER_SIZE];       // store date string
  CHAR   errorstr[80];                 // stored last error string
  PMACDEVICETYPE PmacType;             // 0 = DT_PMAC, 1 = DT_TURBO
  BOOL   bIsTurbo;

  LOCATIONTYPE Location; // PCBUS, SERIALPORT, VMEBUS
  DWORD  dwMaxMotors;    // Maximum motors on PMAC, 32 if turbo else 8
  DWORD  dwMaxIMPQVars;  // Maximum IMPQ Vars on PMAC, 8191 if turbo else 1023
                         // BUS
  short  BUSCommError;   // BUS ascii comm error current value
  DWORD Interrupt;       // Interrupt n

  // VME Bus
  DWORD VMEHostID;             // VME Host Computer Identifier
  DWORD VMEBase;               // VME Mailbox base address
  DWORD VMEDPRBase;            // VME DPR Base
  DWORD VMEInterrupt;          // VME IRQ Level
  DWORD VMEAM;                 // VME Address Modifier
  DWORD VMEAMDC;               // VME Address Modifier Dont Care bits
  DWORD VMEIRQVect;            // VME IRQ Vector (i.e. A1 )
  struct mailbox  *VMEMailbox; // pointer to base of VME mailbox
  short VMECommError;

  // SERIAL
  DCB           dcb;
  COMMTIMEOUTS  cto;
  DWORD         port;
  DWORD         baudrate;
  short         SERCommError;
  BOOL          bDoChecksums;

  // Status storage
  DWORD  DPRbuf_start;    // PMAC/TURBO DPR Start Address
  BOOL   bDPRInitialized; // DPR has been initialized
  UINT   DPRnumMotors;    // number of motor/coords (i59)
  USHORT DPRAsciiActive;  // DPR is currently active
  USHORT DPRRealtActive;  // DPR real time buffer active
  USHORT DPRBackgActive;  // DPR background active
  USHORT DPRBackgvActive; // DPR Background variable data buffer active
  USHORT DPRCpanelActive; // DPR control panel active
  USHORT DPRRotaryActive; // DPR Binary rotary buffer active

  short  DPRCommError; // DPR ascii comm error current value
  DWORD  i10;          // current i10 parameter
  double posscale[32]; // current ix08 * 32 scale factor
  double velscale[32]; // current ix09 * 32 scale factor
                       // double position_prev[32];     // storage for velocity math etc.
                       // USHORT servotimer_prev[32];   // storage for servo period each motor

  USHORT DPRRotSize[16];       // Size of DPRAM binary rotary 1 & 2
  USHORT DPRBGVBnum_usrs;
  USHORT DPRBGVBmulti_user_mode;
  DWORD  DPRVarStart;          // Start of DPR var & end of DPR buffers
  BOOL  CanUsePlcc;            // indicates can use compiled plc
  BOOL  CanUseLDs;             // indicates can use Ladder stuff
  BOOL  WantUsePlcc;           // Want to compile PLC
  BOOL  WantUseLDs;            // Want to use ladder
  BOOL  Downloading;           // indicates download thread working
  BOOL bootstrap_mode;         // In bootstrap mode
  DWORD linkfile[MAXLINKS];    // PLCC PMAC Link addresses
  DWORD linkldsfile[MAXLINKS]; // Ladder PMAC Link addresses
  DWORD plccbuffer;           // PLCC Program Scheduler Start Addresses
  DWORD plccret;              // PLCC Program RET
  DWORD plccstart;            // PLCC Program Start
  DWORD plccjmp;              // PLCC Program Scheduler Start


  // Gather stuff
  double ulGatherSampleTime;                  // Sample gather time in msec
  UINT   uGatherPeriod;                       // I19 number servo cycles per sample
  DWORD  dwGatherMask;                        // I20 (determines #sources & types)
  DWORD  dwGatherMask2;
  UINT   uGatherSources;                      // Number of sources gathered
  UINT   uGatherSamples;                      // Number of samples gathered
  UINT   uGatherSampleLen;                    // Number 24-bit words per sample
  BOOL   bGatherEnabled[MAXGATHERS2];         // Sources enabled
  char   szGatherAdr[MAXGATHERS2][MAXADRLEN]; // Types and addresses of gathers
  UINT   uGatherSize[MAXGATHERS2];            // Size of gather type in 24bit words

  // Real gather stuff
  int    hRTGatherHandle;             // Handle to var background
  UINT   uRTGatherSources;            // Number of sources gathered
  UINT   uRTGatherSamples;            // Number of samples in gather array
  ULONG  ulRTGatherAdr[MAXRTGATHERS]; // Array of var buf gather sources

  // Mutex handle makes multi threading safe even from serial port
  //HANDLE hMutex;

  // Timeout values and counts
  DWORD  dwBaseTimeoutCount;

  DWORD  dwDPRRTimeoutCount;
  DWORD  dwDPRRTimeout;
  DWORD  dwDPRBKTimeoutCount;
  DWORD  dwDPRBKTimeout;
  DWORD  dwDPRCharTimeoutCount;
  DWORD  dwDPRCharTimeout;
  DWORD  dwDPRFlushTimeoutCount;
  DWORD  dwDPRFlushTimeout;
  DWORD  dwVMEFlushTimeoutCount;
  DWORD  dwVMEFlushTimeout;
  DWORD  dwVMECharTimeoutCount;
  DWORD  dwVMECharTimeout;
  DWORD  dwBUSCharTimeoutCount;
  DWORD  dwBUSCharTimeout;
} GLOBAL_HANDLE, *PGLOBAL_HANDLE;

  #if defined(_DRIVER) // DLL Include +++++++++++++++++++++++++++
                       // // debug macros
                       //  #if defined(DBG) || defined(_DEBUG)
                       //    void dbgPrintf(PTCHAR szFormat, ...);
                       //    extern int vcuDebugLevel;
                       //
                       //    #define dprintf(_x_)      dbgPrintf _x_
                       //    #define dprintf1(_x_)     if (vcuDebugLevel >= 1) dbgPrintf _x_
                       //    #define dprintf2(_x_)     if (vcuDebugLevel >= 2) dbgPrintf _x_
                       //    #define dprintf3(_x_)     if (vcuDebugLevel >= 3) dbgPrintf _x_
                       //    #define dprintf4(_x_)     if (vcuDebugLevel >= 4) dbgPrintf _x_
                       //  #else
                       //    #define dprintf(_x_)
                       //    #define dprintf1(_x_)
                       //    #define dprintf2(_x_)
                       //    #define dprintf3(_x_)
                       //    #define dprintf4(_x_)
                       // #endif

    #define WAIT_2SEC 2000 // Mutex object wait period of 2 sec.
    #define WAIT_5SEC 5000 // Mutex object wait period of 5 sec.
    #define TIMEOUT_COUNT_TIME    500


    #include <CRTDBG.H>
    #include <mmddk.h>
    #include <devioctl.h>
    #include <assert.h>
    #include <mcstruct.h>
    #include <mioctl.h>
    #include "dprrealt.h"
    #include "dprbkg.h"
    #include "registry.h"
    #include "motmsg.h"
    #include "vme.h"
    #include "bus.h"
    #include "ser.h"
    #include "bintoken.h"
    #include "dprotlib.h"
    #include "cmplc56k.h"
    #include "cmplclib.h"
    #include "pmacerr.h"
    #include "download.h"
    #include "utile.h"
    #include "lips.h"
// Global externals
extern HANDLE        ghModule;
extern HANDLE        ghLangModule;
extern REG_ACCESS    RegAccess[MAX_MOTION_DEVICES+1]; // registry access global
extern OSVERSIONINFO OsInfo;                        // Operating system information
extern USER_HANDLE   vh[MAX_MOTION_DEVICES+1];        // driver access handle
extern GLOBAL_HANDLE gh[MAX_MOTION_DEVICES+1];        // device access handle

  #else // Application include +++++++++++++++++++++++++++++++++++++++++++++++++

//#include <registry.h>
    #include <mioctl.h>
    #include <mmsystem.h>
    #include <common.h>
    #include <motmsg.h>
    #include <vme.h>
    #include <bus.h>
    #include <dpr.h>
    #include <ser.h>
    #include <intr.h>
    #include <dprotlib.h>
    #include <dprbkg.h>
    #include <cmplclib.h>
    #include <pmacerr.h>
    #include <download.h>
    #include <utile.h>
    #include <gather.h>
    #include <lips.h>


extern HANDLE       *ghModule;
extern HANDLE       *ghLangModule;
extern USER_HANDLE   vh[MAX_MOTION_DEVICES+1]; // driver access handle
extern GLOBAL_HANDLE gh[MAX_MOTION_DEVICES+1]; // device access handle
  #endif

/****************************************************************************
 * information needed to locate/initialise hardware. Set by user
 * in ConfigDlgProc and written to registry to kernel driver.
 ****************************************************************************/
typedef struct _Config_Location {
    PMACDEVICETYPE PmacType; // 1 = DT_PMAC1, 2 = DT_PMAC2,3 = DT_TURBO
    DWORD Port;              // Port number
    DWORD Interrupt;         // Interrupt number
    DWORD FifoWindow;        // Pmac DP Ram physical address
    DWORD Location;          // typedef enum {LT_PCBUS, LT_SER, LT_VMEBUS};
    DWORD PCBusType;         // ISA, PCI etc.
    DWORD DPRRot1Size;
    DWORD DPRRot2Size;
    DWORD DPRRot3Size;
    DWORD DPRRot4Size;
    DWORD DPRRot5Size;
    DWORD DPRRot6Size;
    DWORD DPRRot7Size;
    DWORD DPRRot8Size;
    DWORD DPRRot9Size;
    DWORD DPRRot10Size;
    DWORD DPRRot11Size;
    DWORD DPRRot12Size;
    DWORD DPRRot13Size;
    DWORD DPRRot14Size;
    DWORD DPRRot15Size;
    DWORD DPRRot16Size;

    DWORD DPRVarAdr;
    //DWORD DPRUserSize;
    //DWORD DPRFBStart;
    //DWORD DPRFBTimer;
    DWORD port_num;
    DWORD baudrate;
    DWORD odd_parity;
        DWORD VMEBase;    // VME Mailbox base address
        DWORD VMEDPRBase;
        DWORD VMEInterrupt;
        DWORD VMEHostID;  // VME Host Computer Identifier
        DWORD VMEAM;      // VME Address Modifier
        DWORD VMEAMDC;    // VME Address Modifier Dont Care bits
        DWORD VMEIRQVect; // VME IRQ Vector (i.e. A1 )

  DWORD  dwDPRRTimeout;
  DWORD  dwDPRBKTimeout;
  DWORD  dwDPRCharTimeout;
  DWORD  dwDPRFlushTimeout;
  DWORD  dwVMEFlushTimeout;
  DWORD  dwVMECharTimeout;
  DWORD  dwSERFlushTimeout;
  DWORD  dwSERCharTimeout;
  DWORD  dwBUSFlushTimeout;
  DWORD  dwBUSCharTimeout;

#ifdef _NC
    TCHAR szNcTitle[256];
    TCHAR szSourceProfile[_MAX_PATH];
    TCHAR szToolProfile[_MAX_PATH];
    TCHAR szCoordProfile[_MAX_PATH];
    DWORD MachineType;
    DWORD NoOfTools;
    DWORD NoOfBlocks;
    DWORD NoOfCoordSys;
    DWORD MetricDisplay;
    double LeastHandleInc;
    double MaxHandleInc;
    double LeastJogInc;
    TCHAR szAxisMotorMap[15];
    TCHAR szAxisMotorSel[15];
    TCHAR szAxisDispMap[15];
    double MaxRapidOvrd;
    double MaxFeedOvrd;
    // Axis stuff
    DWORD IsSpindle;
    DWORD HasSlave;
    DWORD IsPhantom;
    DWORD Display;
    DWORD DisplaySlave;
    DWORD HomeMode;
    DWORD HomePrgNumber;
    DWORD Precision;
    DWORD AxisMetricDisplay;
    DWORD MetricUnits;
    DWORD ProbePrgNumber;
    TCHAR szPulsePerUnit[15];
    TCHAR szInPositionBand[15];
    TCHAR szMaxRapid[15];
    TCHAR szMaxFeed[15];
    TCHAR szFatalFError[15];
    TCHAR szWarnFError[15];
    TCHAR szJogSpeedLow[15];
    TCHAR szJogSpeedMedLow[15];
    TCHAR szJogSpeedMed[15];
    TCHAR szJogSpeedMedHigh[15];
    TCHAR szJogSpeedHigh[15];
    TCHAR szFormatInch[15];
    TCHAR szFormatMM[15];
#endif
} CONFIG_LOCATION, *PCONFIG_LOCATION;

#endif //_PMACU_H_
