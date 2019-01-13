/* download.h - Header for Download.c

HISTORY

30Nov98 JET comment out AddMacro(), does not need to be exported/global.
05Dec95 DS  created file
*/

#if !defined(_DOWNLOAD_H)
  #define _DOWNLOAD_H

  #define MAXKEYSIZE    32
  #define MAXMACROSIZE  128
  #define MAXWORDSIZE   32
  #define MAXTEXTSIZE   81
  #define MAXNESTDEPTH  10
  #define MAXPARAMETERS 5
  #define MAXINCLUDE    10

typedef struct tagMacro {
  long line;
  char *key, *macro;
  struct tagMacro *left,*right;
} MACRO, *PMACRO;

typedef void (FAR WINAPI *DOWNLOADMSGPROC)(LPTSTR str,BOOL newline);
typedef int  (FAR WINAPI *DOWNLOADGETPROC)(int nIndex,LPTSTR lpszBuffer,int nMaxLength);
typedef void (FAR WINAPI *DOWNLOADPROGRESS)(int nPercent);



// Globals *******************************************************************
typedef struct tagDownload {

  ULONG     TotalLines;
  UINT      TotalWarnings;
  UINT      TotalErrors;
  UINT      TotalMessages;
  BOOL      bMacro,bMap,bLog,bDnld,bTable;
  ULONG     hThread;
  BOOL      bThreadRunning;
  BOOL      bAbortThread;
  DWORD     dwDevice;
  DWORD     iTimeout;

  PMACRO    macroTable;
  PMACRO    keyTable;
  PMACRO    messages;
  char      fileName[MAX_PATH]; // original input path
  char      mapName[MAX_PATH];  // map file name
  char      msgName[MAX_PATH];  // message/log file name
  char      tblName[MAX_PATH];  // label table file name
  char      outName[MAX_PATH];  // output file name
  char      plccName[MAX_PATH]; // binary plc output file name

  DOWNLOADMSGPROC  messageProc;  // Pointer to a message callback function
  DOWNLOADGETPROC  getlineProc;  // Pointer to a getline callback function
  DOWNLOADPROGRESS progressProc; // Pointer to a progress callback function

  BOOL      bInComment;            // inside comment section
  int       Warnings;
  int       Errors;
  int       Include;               // != 0 currently getting input from file
  char      *inName[MAXINCLUDE];   // current include input file name
  UINT      inLine[MAXINCLUDE];    // current line number
  FILE      *inFile[MAXINCLUDE];   // current input file for includes
  long      inFileLen[MAXINCLUDE]; // length of file in bytes
  long      inFilePos[MAXINCLUDE]; // current pos in file
  int       inErrors[MAXINCLUDE];
  int       inWarnings[MAXINCLUDE];
  UINT      IfNestDepth;
  BOOL      IfStack[MAXNESTDEPTH];

} DOWNLOAD, *PDOWNLOAD;

// Functions --------------------------------------------------------------
  #ifdef __cplusplus
extern "C" {
  #endif

  // Exported functions
  int  CALLBACK PmacDownloadA(DWORD dwDevice,DOWNLOADMSGPROC msgp,DOWNLOADGETPROC getp,
                              DOWNLOADPROGRESS pprg,PCHAR filename,BOOL macro,BOOL map,BOOL log,BOOL dnld);
  int  CALLBACK PmacDownloadW(DWORD dwDevice,DOWNLOADMSGPROC msgp,DOWNLOADGETPROC getp,
                              DOWNLOADPROGRESS pprg,PWCHAR fname,BOOL macro,BOOL map,BOOL log,BOOL dnld);
  int  CALLBACK PmacThreadDownloadA(DWORD dwDevice,DOWNLOADMSGPROC msgp,DOWNLOADGETPROC getp,
                              DOWNLOADPROGRESS pprg,PCHAR filename,BOOL macro,BOOL map,BOOL log,BOOL dnld);
  int  CALLBACK PmacThreadDownloadW(DWORD dwDevice,DOWNLOADMSGPROC msgp,DOWNLOADGETPROC getp,
                              DOWNLOADPROGRESS pprg,PWCHAR fname,BOOL macro,BOOL map,BOOL log,BOOL dnld);
  void CALLBACK PmacDownloadFile(DWORD dwDevice,char *fname);
  BOOL CALLBACK PmacCompilePLCC(DWORD dwDevice,char *plccName,char *outName);
  BOOL CALLBACK WriteDictionary(const char *tblName,PMACRO *root);
  BOOL CALLBACK ReadDictionary(const char *tblName,PMACRO *root);
  int  CALLBACK PmacDownloadFirmwareFile(DWORD dwDevice,DOWNLOADMSGPROC msgp,DOWNLOADPROGRESS prgp,PCHAR filename);
  void CALLBACK PmacAbortDownload(DWORD dwDevice);
  void CALLBACK PmacSetMaxDownloadErrors(UINT max);


  // Internal functions
  void  _cdecl DownloadThread(PCHAR filename);
  void  _cdecl DownloadFirmwareThread(PCHAR filename);
  void CheckAndReportErrors(DWORD dwDevice, DWORD line, char * instr);
  void  AddError(LPSTR err,LONG line);
  void  AddWarning(LPSTR warn,LONG line);
  void  AddMessage(LPSTR msg);
  void  SetPredefinedMacros(DWORD dwDevice);
  BOOL  StoreMacro(char *key,char *macro);
  BOOL  PreProcess(DWORD dwDevice,char *inname,char *outName);
  BOOL  ReadLine(PTCHAR ln, UINT maxchr);
  BOOL  CloseInclude(void);
  BOOL  OpenInclude(char *filename);
  UINT  ParseFilename(const char* inStr,char* outStr,UINT maxchar);
  UINT  ParseKeyWord(const char* inStr,char* outStr,UINT maxchar);
  UINT  ParseMacro(const char* inStr,char* outStr,UINT maxchar);
  BOOL  ParseLine(const char* inStr,char* outStr,UINT maxchar);
  int   ParseParameters(char *src, int *pcount,char *param[]);
  int   Function(char *dest,char *src,char **ep);
  BOOL  WriteMap(char *mapName,char *inname);
  BOOL  WriteMessages(char *msgName,char *inname);

  // Macro table specific
  PMACRO SearchForKey(PMACRO root,char *key);
  void   Flush(PMACRO *root);
  PMACRO DeleteByKey(PMACRO root,char *key);
  // PMACRO AddMacro(PMACRO root,PMACRO r,char *k,char *m,long l);
  PMACRO StoreByLine(PMACRO root,PMACRO r,char *k,char *m,long l);
  void   fPrintKey(PMACRO root,FILE *fptr);
  void   PrintKey(PMACRO root,FILE *fptr);

  #ifdef __cplusplus
}
  #endif

  #ifdef UNICODE
    #define PmacDownload PmacDownloadW
  #else
    #define PmacDownload PmacDownloadA
  #endif // !UNICODE

#endif


