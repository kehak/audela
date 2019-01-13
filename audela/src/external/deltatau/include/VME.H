#include "VMIC.H"

///////////////////////////////////////////////////////////////////////////
// VME Mailbox Structure
struct boxes {
    BYTE    low;
    BYTE    hi;
};
struct mailbox{
    struct boxes box[16];
};

#ifdef __cplusplus
extern "C" {
#endif


  BOOL VMEInit(DWORD dwDevice);
  void VMEShutDown(DWORD dwDevice);
  BOOL  VMECardOnLine(DWORD dwDevice);
  BOOL VMEVerifyPMACDPRSetup(DWORD dwDevice);
  BOOL VMEInitDPR(DWORD dwDevice);
  void VMEReleaseMailboxResources(DWORD dwDevice);

  DWORD __cdecl ISRAcknowledge(DWORD ID);
  DWORD __cdecl ISRReadReady(DWORD ID);
  BOOL CALLBACK PmacVMEReadReady(DWORD dwDevice);
  void  PmacVMEFlush(DWORD dwDevice);
  BOOL CALLBACK PmacVMESendCharA(DWORD dwDevice,DWORD pos,CHAR outchar);
  BOOL CALLBACK PmacVMESendCharW(DWORD dwDevice,WCHAR outchar);
  int CALLBACK PmacVMESendLineA(DWORD dwDevice,PCHAR outchar);
  int CALLBACK PmacVMESendLineW(DWORD dwDevice,PWCHAR outstr);
  int CALLBACK PmacVMEGetLineA(DWORD dwDevice,PCHAR linebuf,UINT maxchar,PUINT num_char);
  int CALLBACK PmacVMEGetLineW(DWORD dwDevice,PWCHAR s,UINT maxchar,PUINT nc);
  int CALLBACK PmacVMEGetControlResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,CHAR outchar);
  int CALLBACK PmacVMEGetControlResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar, WCHAR outchar);
  int CALLBACK PmacVMEGetResponseA(DWORD dwDevice,PCHAR s,UINT maxchar,PCHAR outstr);
  int CALLBACK PmacVMEGetResponseW(DWORD dwDevice,PWCHAR s,UINT maxchar,PWCHAR outstr);
  void CALLBACK PmacVMESendCommandA(DWORD dwDevice,PCHAR outchar);
  void CALLBACK PmacVMESendCommandW(DWORD dwDevice,PWCHAR outstr);
  int CALLBACK PmacVMEGetBufferA(DWORD dwDevice,PCHAR s,UINT maxchar,PUINT nc);
  int CALLBACK PmacVMEGetBufferW(DWORD dwDevice,PWCHAR s,UINT maxchar,PUINT nc);

#ifdef __cplusplus
}
#endif
