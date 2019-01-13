/***************************************************************************
  (C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992

  Title:    util.h

  Version:  1.00

  Date:   11/18/1992

  Author(s):  Dennis Smith

  Header file for Utility functions.

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------
19Nov97 JET added PmacLMH()
**************************************************************************/

#ifndef _UTIL_H
  #define _UTIL_H

  #include <stdio.h>

///////////////////////////////////////////////////////////////////////////
// Status structures

typedef struct {
  BOOL  plc_enabled;
  UINT  plc_start_addr;
  UINT  plc_end_addr;
  UINT  plc_size;
 } PLC_STATUS_STRUCT;

typedef struct  {
  BOOL  plcc_loaded;
  BOOL  plcc_enabled;
  UINT  plcc_start_addr;
  UINT  plcc_end_addr;
  UINT  plcc_size;
 } PLCC_STATUS_STRUCT;

typedef struct  {
  UINT num_plc;
  UINT num_plcc;
  UINT I5;
  PLC_STATUS_STRUCT plc[32];
  PLCC_STATUS_STRUCT plcc[32];
} TOTAL_PLC_STATUS_STRUCT;

///////////////////////////////////////////////////////////////////////////
// Functions
  #ifdef __cplusplus
extern "C" {
  #endif

  // Internal functions
  BOOL   GetFileName(HWND hWindow,BOOL save,LPTSTR title,LPTSTR fileName,LPTSTR filter);
  FILE   *getFilePointer(const char *full_path,const char *mode);
  BOOL   SetPmacType(DWORD dwDevice);
  DWORD  SetMaxMotors(DWORD dwDevice);
  BOOL   SetRomDate(DWORD dwDevice);
  BOOL   SetRomVersion(DWORD dwDevice);
  BOOL   SetLinkList(DWORD dwDevice);
  BOOL  CALLBACK BackupLinkList(DWORD dwDevice);
  BOOL  CALLBACK  RestoreLinkList(char * szFirmwareVersion);
  BOOL   SetLDSList(DWORD dwDevice);
  BOOL   SetScales(DWORD dwDevice);
  void   ReportSystemError(PCHAR name);
  BOOL   CalibrateTimeout(DWORD timeoutMsec,DWORD *timeoutCount);

  // Exported functions
  BOOL   CALLBACK OpenPmacDevice(DWORD dwDevice);
  BOOL   CALLBACK ClosePmacDevice(DWORD dwDevice);
  BOOL CALLBACK VMETestOpenPmacDevice(DWORD dwDevice);
  BOOL CALLBACK VMETestClosePmacDevice(DWORD dwDevice);
  BOOL CALLBACK bPMACIsTurbo(DWORD dwDevice);

  BOOL   CALLBACK PmacNcAvailable(void);
  BOOL   CALLBACK PmacSetLanguage(const DWORD dwDevice,char *locale);
  void   CALLBACK PmacLMH(HANDLE *hndl);
  BOOL   CALLBACK SetLanguageModule(const char *locale,const HANDLE hProcess,HANDLE *h);
  void   CALLBACK PmacSetWindow(DWORD dwDevice,HWND hWnd);
  LPSTR  CALLBACK szLoadStringA(HANDLE hInst,int iID);
  PCHAR  CALLBACK szStripControlCharA(PCHAR str);
  PCHAR  CALLBACK szStripWhiteSpaceA(PCHAR str);
  BOOL   CALLBACK PmacReadReady(DWORD dwDevice);
  int    CALLBACK PmacGetError(DWORD dwDevice);
  ASCIIMODE CALLBACK PmacGetAsciiComm(DWORD dwDevice);
  BOOL   CALLBACK PmacSetAsciiComm(DWORD dwDevice,ASCIIMODE m);
  BOOL   CALLBACK PmacMotionBufOpen(DWORD dwDevice);
  BOOL   CALLBACK PmacRotBufOpen(DWORD dwDevice);
  BYTE   CALLBACK PmacGetIntStatusReg(DWORD dwDevice);

  BOOL CALLBACK PmacLoadNTDriver(DWORD dwDevice);
  BOOL CALLBACK PmacUnloadNTDriver(DWORD dwDevice);
  BOOL CALLBACK PmacNTDriverLoaded(DWORD dwDevice);
  BOOL CALLBACK PmacRemoveNTDriver(DWORD dwDevice);
  void CALLBACK LockPmac(DWORD dwDevice);
  void CALLBACK ReleasePmac(DWORD dwDevice);

  BOOL   CALLBACK PmacGetVariableStrA(DWORD dwDevice,CHAR ch,LPSTR str,UINT num);
  short int CALLBACK PmacGetVariable(DWORD dwDevice,CHAR ch,UINT num,short int def);
  short int CALLBACK PmacGetIVariable(DWORD dwDevice,UINT num,short int def);
  long   CALLBACK PmacGetVariableLong(DWORD dwDevice,TCHAR ch,UINT num,long def);
  double CALLBACK PmacGetVariableDouble(DWORD dwDevice,TCHAR ch,UINT num,double def);
  long   CALLBACK PmacGetIVariableLong(DWORD dwDevice,UINT num,long def);
  double CALLBACK PmacGetIVariableDouble(DWORD dwDevice,UINT num,double def);

  void   CALLBACK PmacSetVariable(DWORD dwDevice,CHAR ch,UINT num,short int val);
  void   CALLBACK PmacSetIVariable(DWORD dwDevice,UINT num,short int val);
  void   CALLBACK PmacSetVariableLong(DWORD dwDevice,TCHAR ch,UINT num,long val);
  void   CALLBACK PmacSetVariableDouble(DWORD dwDevice,TCHAR ch,UINT num,double val);
  void   CALLBACK PmacSetIVariableLong(DWORD dwDevice,UINT num,long val);
  void   CALLBACK PmacSetIVariableDouble(DWORD dwDevice,UINT num,double val);
  int    CALLBACK PmacGetProgramInfo(DWORD dwDevice,BOOL plc,int num,UINT *sadr,UINT *fadr);
  PUSER_HANDLE CALLBACK PmacGetUserHandle(DWORD dwDevice);
  BOOL   CALLBACK PmacConfigure(HWND hwnd,DWORD dwDevice);
  double CALLBACK PmacGetDrvVersion(DWORD dwDevice);
  BOOL   CALLBACK PmacGetDpramAvailable(DWORD dwDevice);
  BOOL   CALLBACK PmacInBootStrapMode(DWORD dwDevice);

  // ASCII string exported functions
  PCHAR CALLBACK PmacGetRomDateA(DWORD dwDevice,PCHAR s,int maxchar);
  PCHAR CALLBACK PmacGetRomVersionA(DWORD dwDevice,PCHAR s,int maxchar);
  int   CALLBACK PmacGetResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,PCHAR outstr);
  int   CALLBACK PmacGetControlResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,CHAR outchar);
  BOOL  CALLBACK PmacSendCharA(DWORD dwDevice,CHAR outchar);
  int   CALLBACK PmacSendLineA(DWORD dwDevice,PCHAR outchar);
  int   CALLBACK PmacGetLineA(DWORD dwDevice,PCHAR linebuf,UINT maxCHAR);
  int   CALLBACK PmacGetBufferA(DWORD dwDevice,PCHAR linebuf,UINT maxchar);
  void  CALLBACK PmacSendCommandA(DWORD dwDevice,PCHAR outCHAR);
  void  CALLBACK PmacFlush(DWORD dwDevice);
  int   CALLBACK PmacGetPmacType(DWORD dwDevice);
  BOOL  CALLBACK PmacGetIVariableStrA(DWORD dwDevice,LPSTR str,UINT num);
  int   CALLBACK PmacMultiDownloadA(DWORD dwDevice,DOWNLOADMSGPROC msgp,PCHAR outfile,
                  PCHAR inifile,PCHAR szUserId,BOOL macro,BOOL map,BOOL log,BOOL dnld);
  int   CALLBACK PmacAddDownloadFileA(DWORD dwDevice,PCHAR inifile,PCHAR szUserId,PCHAR szDLFile);
  int   CALLBACK PmacRemoveDownloadFileA(DWORD dwDevice,PCHAR inifile,PCHAR szUserId,PCHAR szDLFile);
  void  CALLBACK PmacRenumberFilesA(DWORD dwDevice,int file_num,PCHAR szIniFile);
  int   CALLBACK PmacGetErrorStrA(DWORD dwDevice,PCHAR str,int maxchar);

  // Unicode string exported functions
  int  CALLBACK PmacGetResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,PWCHAR outstr);
  int  CALLBACK PmacGetControlResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,WCHAR outchar);
  BOOL CALLBACK PmacSendCharW(DWORD dwDevice,WCHAR outchar);
  int  CALLBACK PmacSendLineW(DWORD dwDevice,PWCHAR outchar);
  int  CALLBACK PmacGetLineW(DWORD dwDevice,PWCHAR linebuf,UINT maxCHAR);
  int  CALLBACK PmacGetBufferW(DWORD dwDevice,PWCHAR linebuf,UINT maxchar);
  void CALLBACK PmacSendCommandW(DWORD dwDevice,PWCHAR outchar);
  BOOL CALLBACK PmacGetIVariableStrW(DWORD dwDevice,LPWSTR str,UINT num);
  WORD CALLBACK PmacGetPlcStatus(DWORD dwDevice,TOTAL_PLC_STATUS_STRUCT *plc_stat);
  int  CALLBACK PmacMultiDownloadW(DWORD dwDevice,DOWNLOADMSGPROC msgp,PWCHAR outfile,
                  PWCHAR inifile,PWCHAR szUserId,BOOL macro,BOOL map,BOOL log,BOOL dnld);
  int  CALLBACK PmacAddDownloadFileW(DWORD dwDevice,PWCHAR inifile,PWCHAR szUserId,PWCHAR szDLFile);
  int  CALLBACK PmacRemoveDownloadFileW(DWORD dwDevice,PWCHAR inifile,PWCHAR szUserId,PWCHAR szDLFile);
  void CALLBACK PmacRenumberFilesW(DWORD dwDevice,int file_num,PWCHAR szIniFile);
  int  CALLBACK PmacGetErrorStrW(DWORD dwDevice,PWCHAR str,int maxchar);

  // Functions  pertaining to status
  BOOL CALLBACK PmacGetGlobalStatus(DWORD dwDevice,DWORD *status);
  BOOL CALLBACK PmacGetCoordStatus(DWORD dwDevice,UINT csn,DWORD *status);
  BOOL CALLBACK PmacGetMotorStatus(DWORD dwDevice,UINT mtr,DWORD *status);

  // Functions  pertaining to global
  BOOL CALLBACK PmacSysServoError(DWORD dwDevice);
  BOOL CALLBACK PmacSysReEntryError(DWORD dwDevice);
  BOOL CALLBACK PmacSysMemChecksumError(DWORD dwDevice);
  BOOL CALLBACK PmacSysPromChecksumError(DWORD dwDevice);

  // Functions pertaining to position
  double CALLBACK PmacGetCommandedPos(DWORD dwDevice,int mtr, double units);
  double CALLBACK PmacPosition(DWORD dwDevice,int mtr,double units);
  double CALLBACK PmacFollowError(DWORD dwDevice,int mtr,double units);
  double CALLBACK PmacGetVel(DWORD dwDevice,int mtr,double units);
  void   CALLBACK PmacGetMasterPos(DWORD dwDevice,int mtr,double units,double *the_double);
  void   CALLBACK PmacGetCompensationPos(DWORD dwDevice,int mtr,double units,double *the_double);


  // Functions pertaining to coord systems
  long CALLBACK PmacPe(DWORD dwDevice,int cs);
  BOOL CALLBACK PmacRotBufFull(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacSysInposition(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacSysWarnFError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacSysFatalFError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacSysRunTimeError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacSysCircleRadError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacSysAmpFaultError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacProgRunning(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacProgStepping(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacProgContMotion(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacProgContRequest(DWORD dwDevice,int crd);
  int  CALLBACK PmacProgRemaining(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacMotionBufOpen(DWORD dwDevice);
  BOOL CALLBACK PmacRotBufOpen(DWORD dwDevice);
  double CALLBACK PmacGetFeedRateMode(DWORD dwDevice,int csn, BOOL  *mode);
  double CALLBACK PmacGetAxisTargetPos(DWORD dwDevice,int crd,char axchar);

  // Functions pertaining to individual motors
  BOOL  CALLBACK PmacAmpEnabled(DWORD dwDevice,int mtr);
  BOOL  CALLBACK PmacWarnFError(DWORD dwDevice,int mtr);
  BOOL  CALLBACK PmacFatalFError(DWORD dwDevice,int mtr);
  BOOL  CALLBACK PmacAmpFault(DWORD dwDevice,int mtr);
  BOOL  CALLBACK PmacOnPositionLimit(DWORD dwDevice,int mtr);
  BOOL  CALLBACK PmacHomeComplete(DWORD dwDevice,int mtr);
  BOOL  CALLBACK PmacInposition(DWORD dwDevice,int mtr);
  double CALLBACK PmacGetTargetPos(DWORD dwDevice,int motor, double posscale);
  double CALLBACK PmacGetBiasPos(DWORD dwDevice,int motor, double posscale);
  long  CALLBACK PmacTimeRemInMove(DWORD dwDevice,int cs);
  long  CALLBACK PmacTimeRemInTATS(DWORD dwDevice,int cs);
  BOOL CALLBACK PmacDataBlock(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacPhasedMotor(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacMotorEnabled(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacHandwheelEnabled(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacOpenLoop(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacOnNegativeLimit(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacOnPositiveLimit(DWORD dwDevice,int mtr);
  void CALLBACK PmacSetJogReturn(DWORD dwDevice,int mtr);

  // Command Logging
  BOOL CALLBACK CommandLogging(DWORD dwDevice, PCHAR str, BOOL dirn);
  BOOL CALLBACK CommandLoggingW(DWORD dwDevice, PWCHAR outstr, BOOL dirn);

  // Logical query functions
  PROGRAM    CALLBACK PmacGetProgramMode(DWORD dwDevice,int csn);
  MOTIONMODE CALLBACK PmacGetMotionMode(DWORD dwDevice,int csn);
  MOTION     CALLBACK PmacGetMotorMotion(DWORD dwDevice,int mtr);

  #ifdef __cplusplus
}
  #endif

  #ifdef UNICODE
    #define PmacGetResponse PmacGetResponseW
    #define PmacGetControlResponse PmacGetControlResponseW
    #define PmacSendChar PmacSendCharW
    #define PmacSendLine PmacSendLineW
    #define PmacGetLine PmacGetLineW
    #define PmacGetBuffer PmacGetBufferW
    #define PmacSendCommand PmacSendCommandW
    #define PmacMultiDownload PmacMultiDownloadW
    #define PmacAddDownloadFile PmacAddDownloadFileW
    #define PmacRemoveDownloadFile PmacRemoveDownloadFileW
    #define PmacRenumberFiles PmacRenumberFilesW
    #define PmacGetErrorStr PmacGetErrorStrW
  #else
    #define PmacGetResponse PmacGetResponseA
    #define PmacGetControlResponse PmacGetControlResponseA
    #define PmacSendChar PmacSendCharA
    #define PmacSendLine PmacSendLineA
    #define PmacGetLine PmacGetLineA
    #define PmacGetBuffer PmacGetBufferA
    #define PmacSendCommand PmacSendCommandA
    #define PmacMultiDownload PmacMultiDownloadA
    #define PmacAddDownloadFile PmacAddDownloadFileA
    #define PmacRemoveDownloadFile PmacRemoveDownloadFileA
    #define PmacRenumberFiles PmacRenumberFilesA
    #define PmacGetErrorStr PmacGetErrorStrA
  #endif // !UNICODE

#endif
