/* DPR.H  Header file for PMAC Dual Ported RAM communications.

HISTORY:

03Aug98 JET Added *_DPR_BASE definitions, added PmacDPRAddressRange() decl.
23Jan98 EBL Add TURBO PMAC changes
24May94 DES Removed bit defines, changed to bit fields.
18Nov92 DES Created
***************************************************************************/
#ifndef _DPR_H
  #define _DPR_H

  #define  PMAC_DPR_BASE      0xD000
  #define TURBO_DPR_BASE      0x60000

  #define RETRY               5
  #define MAXAOUT             160    // ASCII interface max output string length
  #define MAXAIN              256    // ASCII interface max input string length
  #define MAX_VBGBUF_USERS    9      // Maximum number of vbg data buffer users

typedef enum { stop,run,step,hold,joghold,jogstop } PROGRAM;
typedef enum { inpos,jog,running,homing,handle,openloop,disabled } MOTION;
typedef enum { linear,rapid,circw,circcw,spline,pvt } MOTIONMODE;

typedef void (FAR WINAPI *DPRTESTMSGPROC)(LONG NumErrors,LPTSTR action,LONG CURRENT_OFFSET);
typedef void (FAR WINAPI *DPRTESTPROGRESS)(LONG Percent);

//      Return codes for PmacDPRrotput()

  #define RET_ERROR       -1 // Internal Rotary Buffer has zero size, or conversion error
  #define RET_BUSY        1  // Could not load Command Array into DPR Rotary Buffer
  #define RET_OKAY        0  // Loaded Command Array into DPR Rotary Buffer

///////////////////////////////////////////////////////////////////////////
//  Dual Ported RAM structure
//

// Control Panel ----------------------------------------------------------
struct cpanec { // cpanel motor/coord request structure

        USHORT  spare           : 8; // place holder
        USHORT  jogminus        : 1; // jog minus ( motor only )
        USHORT  jogplus         : 1; // jog plus ( motor only )
        USHORT  jogreturn       : 1; // jog return ( motor only )
        USHORT  start           : 1; // start program ( coord only )
        USHORT  step            : 1; // step program ( coord only )
        USHORT  stop            : 1; // abort program ( coord only )
        USHORT  home            : 1; // home motor ( motor only )
        USHORT  hold            : 1; // hold program ( coord only )
};

struct cpanem { // cpanel motor/coord structure

        struct cpanec   request; // Y:$D001 motor/coord request
        USHORT  feedpot;         // X:$D001 feed pot override
};

struct cpane {

        USHORT request1         : 1; // Y:$D000:B0 enable coord/motor 1
        USHORT request2         : 1; // Y:$D000:B1 enable coord/motor 2
        USHORT request3         : 1; // Y:$D000:B2 enable coord/motor 3
        USHORT request4         : 1; // Y:$D000:B3 enable coord/motor 4
        USHORT request5         : 1; // Y:$D000:B4 enable coord/motor 5
        USHORT request6         : 1; // Y:$D000:B5 enable coord/motor 6
        USHORT request7         : 1; // Y:$D000:B6 enable coord/motor 7
        USHORT request8         : 1; // Y:$D000:B7 enable coord/motor 8
        USHORT notused          : 8; // Y:$D000:B8-B15 place holder
        USHORT feedoverride;         // X:$D000 reserved for feedpot override
        struct cpanem   mtrcrd[8];   // $D001 - $D008 for 8 coord/motor
};


///////////////////////////////////////////////////////////////////////////
// ASCII Interface Structure ----------------------------------------------
///////////////////////////////////////////////////////////////////////////
struct ascii {
        USHORT  sendready:1;     // Y:$D18B output control word
        USHORT  pad:15;
        USHORT  ctrlchar;        // X:$D18B control character
        char    outstr[MAXAOUT]; // $D18C - $D1B3 output string buffer
        USHORT  instatus;        // Y:$D1B4 input control word
        USHORT  charcount;       // X:$D1B4 input character count
        char    instr[MAXAIN];   // $D1B5 - $D1F4 input string buffer
};

///////////////////////////////////////////////////////////////////////////
// ROT BUFFER Interface Structure

struct rotbuf {
    USHORT    roterr:8;  // Y:$D1FC Error codes
    USHORT    spare0:6;
    USHORT    busy:1;    // Y:$D1FC Internal Rotary buffer full
    USHORT    error:1;   // Y:$D1FC Error Flag
    USHORT    coord;     // X:$D1FC coordinate system
    USHORT    hostindex; // Y:$D1FD Host Index to Rotary Buffer
    USHORT    pmacindex; // X:$D1FD PMAC Index to Rotary Buffer
    USHORT    bufsize;   // Y:$D1FE Size of rotary buffer
    USHORT    bufstart;  // X:$D1FE buffer start / TURBO = offset from fixed buf
};

///////////////////////////////////////////////////////////////////////////
// DATA GATHER Interface Structure

struct gatbuf {
        USHORT  bufsize;  // Y:$D1FF Size of rotary buffer
        USHORT  bufstart; // X:$D1FF buffer start index
};

//////////////////////////////////////////////////////////////////////////
// Functions
  #ifdef __cplusplus
extern "C" {
  #endif

  BOOL    PmacDPRInit(DWORD dwDevice);
  PVOID   CALLBACK PmacDPRGetPtr(DWORD dwDevice);

  VOID    SaveConfiguration(DWORD dwDevice);
  DWORD   GetDPRAMAddress(DWORD dwDevice);
  BOOL    ConfigureDPRAM(DWORD dwDevice, DWORD dwDPRBaseAddress);
  BOOL    CardHasMem(DWORD dwDevice, DWORD dwDPRBaseAddress);
  LONG    CALLBACK PmacDPRTest();
  void    _cdecl   DPRTestThread(PCHAR dummy);
  void    CALLBACK PmacAbortDPRTest(void);
  void    CALLBACK PmacDPRStatus(DWORD dwDevice,UINT *comm,UINT *bg,UINT * bgv,
                  UINT *rt,UINT *cp, UINT *rot);
  BOOL    CALLBACK PmacDPRAvailable(DWORD dwDevice);

  // Numeric read/write functions
  PVOID   CALLBACK PmacDPRGetMem(DWORD dwDevice,DWORD offset,size_t count,PVOID val);
  PVOID   CALLBACK PmacDPRSetMem(DWORD dwDevice,DWORD offset,size_t count,PVOID val);
  BOOL    CALLBACK PmacDPRDWordBitSet(DWORD dwDevice,UINT offset,UINT bit);
  void    CALLBACK PmacDPRSetDWordBit(DWORD dwDevice,UINT offset,UINT bit);
  void    CALLBACK PmacDPRResetDWordBit(DWORD dwDevice,UINT offset,UINT bit);
  WORD    CALLBACK PmacDPRGetWord(DWORD dwDevice,UINT offset);
  void    CALLBACK PmacDPRSetWord(DWORD dwDevice,UINT offset, WORD val);
  DWORD   CALLBACK PmacDPRGetDWord(DWORD dwDevice,UINT offset);
  void    CALLBACK PmacDPRSetDWord(DWORD dwDevice,UINT offset, DWORD val);
  float   CALLBACK PmacDPRGetFloat(DWORD dwDevice,UINT offset);
  void    CALLBACK PmacDPRSetFloat(DWORD dwDevice,UINT offset,double val);
  void    CALLBACK PmacDPRSetDWordMask(DWORD dwDevice,UINT offset,DWORD val,BOOL onoff);
  DWORD   CALLBACK PmacDPRGetDWordMask(DWORD dwDevice,UINT offset,DWORD val);

  double  CALLBACK PmacDPRFloat(long d[],double scale);
  double  CALLBACK PmacDPRLFixed(long d[],double scale);

  double  CALLBACK PmacDPRVelocity(DWORD dwDevice,int mtr,double units);
  double  CALLBACK PmacDPRVectorVelocity(DWORD dwDevice,int num,int mtr[],double units[]);

  void    CALLBACK PmacDPRSetMotors(DWORD dwDevice,UINT n);

  // Function     pertaining to global status
  BOOL CALLBACK PmacDPRMotionBufOpen(DWORD dwDevice);
  BOOL CALLBACK PmacDPRRotBufOpen(DWORD dwDevice);
  BOOL CALLBACK PmacDPRSysServoError(DWORD dwDevice);
  BOOL CALLBACK PmacDPRSysReEntryError(DWORD dwDevice);
  BOOL CALLBACK PmacDPRSysMemChecksumError(DWORD dwDevice);
  BOOL CALLBACK PmacDPRSysPromChecksumError(DWORD dwDevice);


  // Functions pertaining to individual motors
  //       Background-Functions pertaining to individual motors
  BOOL   CALLBACK PmacDPRAmpEnabled(DWORD dwDevice,int mtr);
  BOOL   CALLBACK PmacDPRWarnFError(DWORD dwDevice,int mtr);
  BOOL   CALLBACK PmacDPRFatalFError(DWORD dwDevice,int mtr);
  BOOL   CALLBACK PmacDPRAmpFault(DWORD dwDevice,int mtr);
  BOOL   CALLBACK PmacDPROnPositionLimit(DWORD dwDevice,int mtr);
  BOOL   CALLBACK PmacDPRHomeComplete(DWORD dwDevice,int mtr);
  BOOL   CALLBACK PmacDPRInposition(DWORD dwDevice,int mtr);
  double CALLBACK PmacDPRGetTargetPos(DWORD dwDevice,int motor, double posscale);
  double CALLBACK PmacDPRGetBiasPos(DWORD dwDevice,int motor, double posscale);
  long   CALLBACK PmacDPRTimeRemInMove(DWORD dwDevice,int cs);
  long   CALLBACK PmacDPRTimeRemInTATS(DWORD dwDevice,int cs);

  // Logical query functions
  PROGRAM CALLBACK PmacDPRGetProgramMode(DWORD dwDevice,int csn);
  MOTIONMODE  CALLBACK PmacDPRGetMotionMode(DWORD dwDevice,int csn);

  ////////////////////////////////////////////////////////////////////////////
  // DPR Control Panel functions
  ////////////////////////////////////////////////////////////////////////////
  BOOL  CALLBACK PmacDPRControlPanel(DWORD dwDevice,long on);
  void  CALLBACK PmacDPRSetJogPosBit(DWORD dwDevice,long motor,long onoff);
  long  CALLBACK PmacDPRGetJogPosBit(DWORD dwDevice,long motor);
  void  CALLBACK PmacDPRSetJogNegBit(DWORD dwDevice,long motor,long onoff);
  long  CALLBACK PmacDPRGetJogNegBit(DWORD dwDevice,long motor);
  void  CALLBACK PmacDPRSetJogReturnBit(DWORD dwDevice,long motor,long onoff);
  long  CALLBACK PmacDPRGetJogReturnBit(DWORD dwDevice,long motor);
  void  CALLBACK PmacDPRSetRunBit(DWORD dwDevice,long cs,long onoff);
  long  CALLBACK PmacDPRGetRunBit(DWORD dwDevice,long cs);
  void  CALLBACK PmacDPRSetStopBit(DWORD dwDevice,long cs,long onoff);
  long  CALLBACK PmacDPRGetStopBit(DWORD dwDevice,long cs);
  void  CALLBACK PmacDPRSetHomeBit(DWORD dwDevice,long cs,long onoff);
  long  CALLBACK PmacDPRGetHomeBit(DWORD dwDevice,long cs);
  void  CALLBACK PmacDPRSetHoldBit(DWORD dwDevice,long cs,long onoff);
  long  CALLBACK PmacDPRGetHoldBit(DWORD dwDevice,long cs);
  long  CALLBACK PmacDPRGetStepBit(DWORD dwDevice,long cs);
  void  CALLBACK PmacDPRSetStepBit(DWORD dwDevice,long cs,long onoff);
  long  CALLBACK PmacDPRGetRequestBit(DWORD dwDevice,long mtrcrd);
  void  CALLBACK PmacDPRSetRequestBit(DWORD dwDevice,long mtrcrd,long onoff);
  long  CALLBACK PmacDPRGetFOEnableBit(DWORD dwDevice,long cs);
  void  CALLBACK PmacDPRSetFOEnableBit(DWORD dwDevice,long cs, long on_off);
  void  CALLBACK PmacDPRSetFOValue(DWORD dwDevice,long cs, long value);
  long  CALLBACK PmacDPRGetFOValue(DWORD dwDevice,long cs);


  ////////////////////////////////////////////////////////////////////////////
  // Uses both Realtime and background features
  ////////////////////////////////////////////////////////////////////////////
  MOTION CALLBACK PmacDPRGetMotorMotion(DWORD dwDevice,int mtr);
  double CALLBACK PmacDPRGetFeedRateMode(DWORD dwDevice,int csn, BOOL     *mode);
  BOOL   CALLBACK  PmacDPRFixedBufferDataUpdate(DWORD dwDevice);

  ////////////////////////////////////////////////////////////////////////////
  // ASCII FUNCTIONS
  ////////////////////////////////////////////////////////////////////////////
  BOOL   CALLBACK PmacDPRComm(DWORD dwDevice,BOOL on);
  BOOL   CALLBACK PmacDPRReadReady(DWORD dwDevice);
  void   CALLBACK PmacDPRFlush(DWORD dwDevice);

  int    CALLBACK PmacDPRSendLineA(DWORD dwDevice,PCHAR outchar);
  int    CALLBACK PmacDPRSendCharA(DWORD dwDevice,CHAR outstr);
  int    CALLBACK PmacDPRSendCtrlCharA(DWORD dwDevice,CHAR outstr);
  int    CALLBACK PmacDPRGetLineA(DWORD dwDevice,PCHAR linebuf,UINT maxchar,PUINT nc);
  int    CALLBACK PmacDPRGetBufferA(DWORD dwDevice,PCHAR s,UINT       maxchar,PUINT nc);
  int    CALLBACK PmacDPRGetControlResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,CHAR outchar);
  int    CALLBACK PmacDPRGetResponseA(DWORD dwDevice,PCHAR s,UINT     maxchar,PCHAR outstr);
  void   CALLBACK PmacDPRSendCommandA(DWORD dwDevice,PCHAR outchar);

  int    CALLBACK PmacDPRSendLineW(DWORD dwDevice,PWCHAR outchar);
  int    CALLBACK PmacDPRSendCharW(DWORD dwDevice,WCHAR outstr);
  int    CALLBACK PmacDPRSendCtrlCharW(DWORD dwDevice,WCHAR outstr);
  int    CALLBACK PmacDPRGetLineW(DWORD dwDevice,PWCHAR linebuf,UINT maxchar,PUINT nc);
  int    CALLBACK PmacDPRGetBufferW(DWORD dwDevice,PWCHAR s,UINT      maxchar,PUINT nc);
  int    CALLBACK PmacDPRGetControlResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,WCHAR outchar);
  int    CALLBACK PmacDPRGetResponseW(DWORD dwDevice,PWCHAR s,UINT    maxchar,PWCHAR outstr);
  void   CALLBACK PmacDPRSendCommandW(DWORD dwDevice,PWCHAR outchar);
  long   CALLBACK PmacDPRAddressRange(DWORD dwDevice,BOOL Upper,BOOL PC_offsets);

  #ifdef __cplusplus
}
  #endif

  #ifdef UNICODE
    #define PmacDPRSendLine PmacDPRSendLineW
    #define PmacDPRSendChar PmacDPRSendCharW
    #define PmacDPRSendCtrlChar PmacDPRSendCtrlCharW
    #define PmacDPRWaitGetLine PmacDPRWaitGetLineW
    #define PmacDPRGetLine PmacDPRGetLineW
    #define PmacDPRGetResponse PmacDPRGetResponseW
    #define PmacDPRGetControlResponse PmacDPRGetControlResponseW
    #define PmacDPRSendCommand PmacDPRSendCommandW
  #else
    #define PmacDPRSendLine PmacDPRSendLineA
    #define PmacDPRSendChar PmacDPRSendCharA
    #define PmacDPRSendCtrlChar PmacDPRSendCtrlCharA
    #define PmacDPRWaitGetLine PmacDPRWaitGetLineA
    #define PmacDPRGetLine PmacDPRGetLineA
    #define PmacDPRGetResponse PmacDPRGetResponseA
    #define PmacDPRGetControlResponse PmacDPRGetControlResponseA
    #define PmacDPRSendCommand PmacDPRSendCommandA
  #endif // !UNICODE

#endif
