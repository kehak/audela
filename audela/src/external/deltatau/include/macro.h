#ifndef _MACRO_H
  #define _MACRO_H

// Functions --------------------------------------------------------------
  #ifdef __cplusplus
extern "C" {
  #endif

  PCHAR CALLBACK MACROGetIVariableString(DWORD dwDevice,DWORD node,UINT num,PCHAR def);
  long CALLBACK MACROGetIVariableLong(DWORD dwDevice,DWORD node,UINT num,long def);
  BOOL CALLBACK MACROUploadConfig(DWORD dwDevice,DOWNLOADPROGRESS prgp,char * fname);
  BOOL MACROGetIVariableSet(DWORD dwDevice,DOWNLOADPROGRESS progressProc,
      long node, FILE * fp,long start, long end);
  BOOL MACROUploadGlobalNodeConfig(DWORD dwDevice,DOWNLOADPROGRESS prgp,long LowNode,FILE * fp);
  void GetActiveNodes(DWORD dwDevice);

#ifdef __cplusplus
}
#endif
#endif 