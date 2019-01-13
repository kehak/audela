/*

HISTORY
19Jun98 JET eliminate duplicate code with NO_EXTERN, reformat for easy maint.
16Jun98 JET add ncPpGetDouble and ncPpSetDouble for parametric programming.
13Apr98 JET add NcAddErrorRecordEx
02Apr98 JET Add DPR Numeric read/write functions, remove redundant typedefs.
13Mar98 JET Add DPRWriteBuffer
12Mar98 JET Add DPRVarBufChange, DPRBackground, DPRFloat, DPRLFixed
13Jan98 JET added GetErrorLevel for probing display update.
11Dec97 JET Made RewindTextBuffer() arguments agree with PMAC.DLL version.
19Nov97 JET added PMACLMH function
*/

#ifndef RUNTIME_H
  #define RUNTIME_H

  #include <pmacu.h>

  #define DRIVERNAME          TEXT("Pmac.dll") //name of the user-dll driver

  #ifdef  __BORLANDC__
    #ifdef  __BORLANDC__ >= 0x0530 // C Builder 3.0 doesn't do enums
      #define PROGRAM        int   // as ints if we are using vcl so
      #define MOTION         int   // make them ints
      #define MOTIONMODE     int
      #define PMACDEVICETYPE int
      #define ASCIIMODE      int
      #define BUSTYPE        int
      #define VMEHOSTTYPE    int
      #define LOCATIONTYPE   int
      #define GATMODE        int
    #endif
  #endif

//************************************************************************
// COMM Type Defines
//************************************************************************
typedef BOOL   (CALLBACK* OPENPMACDEVICE)(DWORD dwDevice);
typedef long   (CALLBACK* SELECTPMACDEVICE)(HWND hwnd);
typedef long   (CALLBACK* NUMBEROFDEVICES)();
typedef BOOL   (CALLBACK* CLOSEPMACDEVICE)(DWORD dwDevice);
typedef BOOL   (CALLBACK* PMACSETLANGUAGE)(const DWORD dwDevice,char *locale);
typedef void   (CALLBACK* PMACLMH)(HANDLE *hndl);
typedef BOOL   (CALLBACK* SETLANGUAGEMODULE)(const char *locale,const HANDLE hProcess,HANDLE *h);
typedef LPSTR  (CALLBACK* SZLOADSTRINGA)(HANDLE hInst,int iID);
typedef PCHAR  (CALLBACK* SZSTRIPCONTROLCHARA)(PCHAR str);
typedef PCHAR  (CALLBACK* SZSTRIPWHITESPACEA)(PCHAR str);
typedef int    (CALLBACK* GETERROR)(DWORD dwDevice);
typedef ASCIIMODE (CALLBACK* GETASCIICOMM)(DWORD dwDevice);
typedef BOOL   (CALLBACK* SETASCIICOMM)(DWORD dwDevice,ASCIIMODE m);
typedef BOOL   (CALLBACK* MOTIONBUFOPEN)(DWORD dwDevice);
typedef BOOL   (CALLBACK* ROTBUFOPEN)(DWORD dwDevice);
typedef BOOL   (CALLBACK* GETVARIABLESTRA)(DWORD dwDevice,CHAR ch,LPSTR str,UINT num);
typedef short int (CALLBACK* GETIVARIABLE)(DWORD dwDevice,UINT num,short int def);
typedef long   (CALLBACK* GETVARIABLELONG)(DWORD dwDevice,TCHAR ch,UINT num,long def);
typedef double (CALLBACK* GETVARIABLEDOUBLE)(DWORD dwDevice,TCHAR ch,UINT num,double def);
typedef long   (CALLBACK* GETIVARIABLELONG)(DWORD dwDevice,UINT num,long def);
typedef double (CALLBACK* GETIVARIABLEDOUBLE)(DWORD dwDevice,UINT num,double def);
typedef void   (CALLBACK* SETIVARIABLE)(DWORD dwDevice,UINT num,short int val);
typedef void   (CALLBACK* SETIVARIABLELONG)(DWORD dwDevice,UINT num,long val);
typedef void   (CALLBACK* SETIVARIABLEDOUBLE)(DWORD dwDevice,UINT num,double val);
typedef int    (CALLBACK* GETPROGRAMINFO)(DWORD dwDevice,BOOL plc,int num,UINT *sadr,UINT *fadr);
//typedef int    (CALLBACK* GETProgramInfo)(DWORD dwDevice,BOOL plc,int num,UINT *sadr,UINT *fadr);
typedef PUSER_HANDLE (CALLBACK* GETUSERHANDLE)(DWORD dwDevice);
typedef BOOL   (CALLBACK* CONFIGURE)(HWND hwnd,DWORD dwDevice);
typedef BOOL   (CALLBACK* GETDPRAMAVAILABLE)(DWORD dwDevice);
typedef void   (CALLBACK* LOCKPMAC)(DWORD dwDevice);
typedef void   (CALLBACK* RELEASEPMAC)(DWORD dwDevice);

typedef DWORD  (CALLBACK* SERGETPORT)(DWORD dwDevice);
typedef BOOL   (CALLBACK* SERSETPORT)(DWORD dwDevice,DWORD p);
typedef DWORD  (CALLBACK* SERGETBAUDRATE)(DWORD dwDevice);
typedef BOOL   (CALLBACK* SERSETBAUDRATE)(DWORD dwDevice,DWORD br);

// ASCII string exported functions
typedef PCHAR (CALLBACK* GETROMDATEA)(DWORD dwDevice,LPSTR s,int maxchar);
typedef PCHAR (CALLBACK* GETROMVERSIONA)(DWORD dwDevice,LPSTR s,int maxchar);
typedef int   (CALLBACK* GETPMACTYPE)(DWORD dwDevice);
typedef BOOL  (CALLBACK* GETIVARIABLESTRA)(DWORD dwDevice,LPSTR str,UINT num);
typedef int   (CALLBACK* MULTIDOWNLOADA)(DWORD dwDevice,DOWNLOADMSGPROC msgp,LPCSTR outfile,
                LPCSTR inifile,LPCSTR szUserId,BOOL macro,BOOL map,BOOL log,BOOL dnld);
typedef int   (CALLBACK* ADDDOWNLOADFILEA)(DWORD dwDevice,LPCSTR inifile,LPCSTR szUserId,LPCSTR szDLFile);
typedef int   (CALLBACK* REMOVEDOWNLOADFILEA)(DWORD dwDevice,LPCSTR inifile,LPCSTR szUserId,LPCSTR szDLFile);
typedef void  (CALLBACK* RENUMBERFILESA)(DWORD dwDevice,int file_num,LPCSTR szIniFile);
typedef int   (CALLBACK* GETERRORSTRA)(DWORD dwDevice,LPSTR str,int maxchar);

// Unicode string exported functions
typedef BOOL (CALLBACK* GETIVARIABLESTRW)(DWORD dwDevice,LPWSTR str,UINT num);
//typedef WORD (CALLBACK* GETPLCSTATUS)(DWORD dwDevice,TOTAL_PLC_STATUS_STRUCT *plc_stat);
typedef int  (CALLBACK* MULTIDOWNLOADW)(DWORD dwDevice,DOWNLOADMSGPROC msgp,PWCHAR outfile,
                PWCHAR inifile,PWCHAR szUserId,BOOL macro,BOOL map,BOOL log,BOOL dnld);
typedef int  (CALLBACK* ADDDOWNLOADFILEW)(DWORD dwDevice,PWCHAR inifile,PWCHAR szUserId,PWCHAR szDLFile);
typedef int  (CALLBACK* REMOVEDOWNLOADFILEW)(DWORD dwDevice,PWCHAR inifile,PWCHAR szUserId,PWCHAR szDLFile);
typedef void (CALLBACK* RENUMBERFILESW)(DWORD dwDevice,int file_num,PWCHAR szIniFile);
typedef int  (CALLBACK* GETERRORSTRW)(DWORD dwDevice,PWCHAR str,int maxchar);


typedef BOOL  (CALLBACK* READREADY)(DWORD dwDevice);
typedef int   (CALLBACK* SENDCHARA)(DWORD dwDevice,CHAR outch);
typedef int   (CALLBACK* SENDCHARW)(DWORD dwDevice,WCHAR outch);
typedef int   (CALLBACK* SENDLINEA)(DWORD dwDevice,LPCTSTR outstr);
typedef int   (CALLBACK* SENDLINEW)(DWORD dwDevice,PWCHAR outstr);
typedef int   (CALLBACK* GETLINEA)(DWORD dwDevice,LPTSTR s,UINT maxchar);
typedef int   (CALLBACK* WAITGETLINEA)(DWORD dwDevice,LPTSTR s,UINT maxchar);
typedef int   (CALLBACK* GETLINEW)(DWORD dwDevice,PWCHAR s,UINT maxchar);
typedef int   (CALLBACK* GETRESPONSEA)(DWORD dwDevice,LPTSTR s,UINT maxchar,LPCTSTR outstr);
typedef int   (CALLBACK* GETRESPONSEW)(DWORD dwDevice,PWCHAR s,UINT maxchar,PWCHAR outstr);
typedef int   (CALLBACK* GETCONTROLRESPONSEA)(DWORD dwDevice,LPTSTR s,UINT maxchar,CHAR outchar);
typedef int   (CALLBACK* GETCONTROLRESPONSEW)(DWORD dwDevice,PWCHAR s,UINT maxchar,WCHAR outchar);
typedef void  (CALLBACK* FLUSH)(DWORD dwDevice);
typedef void  (CALLBACK* SENDCOMMANDA)(DWORD dwDevice,LPCTSTR outchar);
typedef void  (CALLBACK* SENDCOMMANDW)(DWORD dwDevice,PWCHAR outstr);
typedef int   (CALLBACK* SENDCTRLCHARA)(DWORD dwDevice,CHAR outstr);
typedef int   (CALLBACK* SENDCTRLCHARW)(DWORD dwDevice,WCHAR outstr);
typedef BOOL  (CALLBACK* INBOOTSTRAP)(DWORD dwDevice);
typedef int 	(CALLBACK* GETBUFFERA)(DWORD dwDevice,LPTSTR s,UINT maxchar);
typedef BOOL  (CALLBACK* PMACCONFIGURE)(HANDLE hwnd,DWORD dwDevice);
typedef LONG	(CALLBACK* TESTDPRAM)(DWORD dwDevice, DPRTESTMSGPROC msgp,DPRTESTPROGRESS prgp);
typedef int	  (CALLBACK* GETPMACTYPE)(DWORD dwDevice);
typedef void	(CALLBACK* TESTDPRABORT)(void);

typedef void (CALLBACK* DPRSETHOSTBUSYBIT)(DWORD dwDevice,int value);
typedef int  (CALLBACK* DPRGETHOSTBUSYBIT)(DWORD dwDevice);
typedef int  (CALLBACK* DPRGETPMACBUSYBIT)(DWORD dwDevice);
typedef int  (CALLBACK* DPRGETSERVOTIMER)(DWORD dwDevice);
typedef void (CALLBACK* DPRSETMOTORS)(DWORD dwDevice,UINT n);
typedef BOOL	 (CALLBACK* DPRAVAILABLE)(DWORD dwDevice);

// Turbo Specific
// Turbo Handshaking
typedef void (CALLBACK*  DPRRESETDATAREADYBIT)(DWORD dwDevice);
typedef long (CALLBACK*  DPRGETDATAREADYBIT)(DWORD dwDevice);
//typedef long (CALLBACK*  DPRDOREALTIMEHANDSHAKE)(DWORD dwDevice);
typedef BOOL (CALLBACK*  DPRDOREALTIMEHANDSHAKE)(DWORD dwDevice);
// Turbo Initialization
//typedef BOOL (CALLBACK* DPRREALTIMETURBO)(DWORD dwDevice,long mask, UINT period, long on);
//typedef void (CALLBACK* DPRREALTIMESETMOTORMASK)(DWORD dwDevice, long mask);
// Data Access
typedef struct ssTurbo (CALLBACK* DPRMOTORSERVOSTATUSTURBO)(DWORD dwDevice,int mtr);

typedef BOOL (CALLBACK* DPRREALTIME)(DWORD dwDevice,UINT period,int on);
typedef  void (CALLBACK *DPRREALTIMESETMOTOR)(DWORD dwDevice, long mask);
typedef  BOOL (CALLBACK *DPRBACKGROUND)(DWORD dwDevice,int on);
typedef  BOOL (CALLBACK *DPRBACKGROUNDEX)(DWORD dwDevice,int on, UINT period, UINT crd);
typedef  BOOL (CALLBACK *DPRBACKGROUNDVAR)(DWORD dwDevice,int on);
typedef  BOOL (CALLBACK *DPRREALTIMEEX)(DWORD dwDevice,long mask,UINT period,int on);




typedef int   (CALLBACK* DOWNLOADA)(DWORD dwDevice,DOWNLOADMSGPROC msgp,DOWNLOADGETPROC getp,
                            DOWNLOADPROGRESS ppgr,PCHAR filename,BOOL macro,BOOL map,BOOL log,BOOL dnld);
typedef int   (CALLBACK* DOWNLOADW)(DWORD dwDevice,DOWNLOADMSGPROC msgp,DOWNLOADGETPROC getp,
                            DOWNLOADPROGRESS ppgr,PWCHAR fname,BOOL macro,BOOL map,BOOL log,BOOL dnld);
typedef void  (CALLBACK* DOWNLOADFILE)(DWORD dwDevice,char *fname);
typedef BOOL  (CALLBACK* COMPILEPLCC)(DWORD dwDevice,char *plccName,char *outName);
typedef BOOL  (CALLBACK* WRITEDICTIONARY)(const char *tblName,PMACRO *root);
typedef BOOL  (CALLBACK* READDICTIONARY)(const char *tblName,PMACRO *root);
typedef int   (CALLBACK* DOWNLOADFIRMWAREFILE)(DWORD dwDevice,char *cFilename,DOWNLOADMSGPROC msgp);
typedef void  (CALLBACK* ABORTDOWNLOAD)(DWORD dwDevice);
typedef void  (CALLBACK* SETMAXDOWNLOADERRORS)(UINT max);

typedef void   (CALLBACK* DPRSTATUS)(DWORD dwDevice,UINT *comm,UINT *bg,UINT * bgv,
                UINT *rt,UINT *cp, UINT *rot);
// Lips stuff
typedef long   (CALLBACK* WHYMOTORNOTMOVING) (DWORD dwDevice,UINT motor);
typedef LPCSTR (CALLBACK* WHYMOTORNOTMOVINGSTRING)(long err);
typedef long   (CALLBACK* WHYMOTORNOTMOVINGTURBO) (DWORD dwDevice,UINT motor);
typedef LPCSTR (CALLBACK* WHYMOTORNOTMOVINGSTRINGTURBO)(long err);
typedef long   (CALLBACK* WHYCSNOTMOVING)(DWORD dwDevice, UINT CS);
typedef LPCSTR (CALLBACK* WHYCSNOTMOVINGSTRING)(long err);
typedef LPCSTR (CALLBACK* WHYCSNOTMOVINGSTRINGTURBO)(long err);
typedef long   (CALLBACK* WHYCSNOTMOVINGTURBO)(DWORD dwDevice, UINT CS);
typedef int    (CALLBACK* INITDATAGARHERING)(DWORD dwDevice, int size);
typedef int    (CALLBACK* STARTGATHER)(DWORD dwDevice);
typedef int    (CALLBACK* STOPGATHER)(DWORD dwDevice);
typedef int    (CALLBACK* IGETNUMGATHERSAMPLES)(DWORD dwDevice);
typedef BOOL   (CALLBACK* GETBITVALUE)(char *s, int bit);
typedef long   (CALLBACK* HEXLONG2)(char *in_str, int str_ln);

// Numeric read/write functions
// Standard
typedef WORD  (CALLBACK* DPRGETWORD)(DWORD dwDevice,UINT offset);
typedef void  (CALLBACK* DPRSETWORD)(DWORD dwDevice,UINT offset, WORD val);
typedef DWORD  (CALLBACK* DPRGETDWORD)(DWORD dwDevice,UINT offset);
typedef void  (CALLBACK* DPRSETDWORD)(DWORD dwDevice,UINT offset, DWORD val);
typedef float (CALLBACK* DPRGETFLOAT)(DWORD dwDevice,UINT offset);
typedef void  (CALLBACK* DPRSETFLOAT)(DWORD dwDevice,UINT offset,double val);
// Masking
typedef BOOL  (CALLBACK* DPRDWORDBITSET)(DWORD dwDevice,UINT offset,UINT bit);
typedef void  (CALLBACK* DPRSETDWORDBIT)(DWORD dwDevice,UINT offset,UINT bit);
typedef void   (CALLBACK* DPRRESETDWORDBIT)(DWORD dwDevice,UINT offset,UINT bit);
typedef void  (CALLBACK* DPRSETDWORDMASK)(DWORD dwDevice,UINT offset,DWORD val,BOOL onoff);
typedef DWORD  (CALLBACK* DPRGETDWORDMASK)(DWORD dwDevice,UINT offset,DWORD val);

typedef double (CALLBACK* DPRFLOAT)(long d[],double scale);
typedef double (CALLBACK* DPRLFIXED)(long d[],double scale);


typedef double (CALLBACK* DPRCOMMANDED)(DWORD dwDevice,int coord,char axchar);
typedef double (CALLBACK* DPRVELOCITY)(DWORD dwDevice,int mtr,double units);
typedef double (CALLBACK* DPRVECTORVELOCITY)(DWORD dwDevice,int num,int mtr[],double units[]);
typedef BOOL   (CALLBACK* DPRSETBACKGROUND)(DWORD dwDevice);
//typedef BOOL   (CALLBACK* DPRBACKGROUND)(DWORD dwDevice,int on, UINT period, UINT crd);

// Functions pertaining to coord systems
typedef long   (CALLBACK* DPRPE)(DWORD dwDevice,int cs);
typedef BOOL   (CALLBACK* DPRROTBUFFULL)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRSYSINPOSITION)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRSYSWARNFERROR)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRSYSFATALFERROR)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRSYSRUNTIMEERROR)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRSYSCIRCLERADERROR)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRSYSAMPFAULTERROR)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRPROGRUNNING)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRPROGSTEPPING)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRPROGCONTMOTION)(DWORD dwDevice,int crd);
typedef BOOL   (CALLBACK* DPRPROGCONTREQUEST)(DWORD dwDevice,int crd);
typedef int    (CALLBACK* DPRPROGREMAINING)(DWORD dwDevice,int crd);

// Functions pertaining to individual motors
// Background-Functions pertaining to individual motors
typedef BOOL   (CALLBACK* DPRAMPENABLED)(DWORD dwDevice,int mtr);
typedef BOOL   (CALLBACK* DPRWARNFERROR)(DWORD dwDevice,int mtr);
typedef BOOL   (CALLBACK* DPRFATALFERROR)(DWORD dwDevice,int mtr);
typedef BOOL   (CALLBACK* DPRAMPFAULT)(DWORD dwDevice,int mtr);
typedef BOOL   (CALLBACK* DPRONPOSITIONLIMIT)(DWORD dwDevice,int mtr);
typedef BOOL   (CALLBACK* DPRHOMECOMPLETE)(DWORD dwDevice,int mtr);
typedef BOOL   (CALLBACK* DPRINPOSITION)(DWORD dwDevice,int mtr);
typedef double (CALLBACK* DPRGETTARGETPOS)(DWORD dwDevice,int motor, double posscale);
typedef double (CALLBACK* DPRGETBIASPOS)(DWORD dwDevice,int motor, double posscale);
typedef long   (CALLBACK* DPRTIMEREMINMOVE)(DWORD dwDevice,int cs);
typedef long   (CALLBACK* DPRTIMEREMINTATS)(DWORD dwDevice,int cs);


// Logical query functions
typedef PROGRAM    (CALLBACK* DPRGETPROGRAMMODE)(DWORD dwDevice,int csn);
typedef MOTIONMODE (CALLBACK* DPRGETMOTIONMODE)(DWORD dwDevice,int csn);

////////////////////////////////////////////////////////////////////////////
// DPR Control Panel functions
////////////////////////////////////////////////////////////////////////////
typedef BOOL  (CALLBACK* DPRCONTROLPANEL)(DWORD dwDevice,long on);
typedef void  (CALLBACK* DPRSETJOGPOSBIT)(DWORD dwDevice,long motor,long onoff);
typedef long  (CALLBACK* DPRGETJOGPOSBIT)(DWORD dwDevice,long motor);
typedef void  (CALLBACK* DPRSETJOGNEGBIT)(DWORD dwDevice,long motor,long onoff);
typedef long  (CALLBACK* DPRGETJOGNEGBIT)(DWORD dwDevice,long motor);
typedef void  (CALLBACK* DPRSETJOGRETURNBIT)(DWORD dwDevice,long motor,long onoff);
typedef long  (CALLBACK* DPRGETJOGRETURNBIT)(DWORD dwDevice,long motor);
typedef void  (CALLBACK* DPRSETRUNBIT)(DWORD dwDevice,long cs,long onoff);
typedef long  (CALLBACK* DPRGETRUNBIT)(DWORD dwDevice,long cs);
typedef void  (CALLBACK* DPRSETSTOPBIT)(DWORD dwDevice,long cs,long onoff);
typedef long  (CALLBACK* DPRGETSTOPBIT)(DWORD dwDevice,long cs);
typedef void  (CALLBACK* DPRSETHOMEBIT)(DWORD dwDevice,long cs,long onoff);
typedef long  (CALLBACK* DPRGETHOMEBIT)(DWORD dwDevice,long cs);
typedef void  (CALLBACK* DPRSETHOLDBIT)(DWORD dwDevice,long cs,long onoff);
typedef long  (CALLBACK* DPRGETHOLDBIT)(DWORD dwDevice,long cs);
typedef long  (CALLBACK* DPRGETSTEPBIT)(DWORD dwDevice,long cs);
typedef void  (CALLBACK* DPRSETSTEPBIT)(DWORD dwDevice,long cs,long onoff);
typedef long  (CALLBACK* DPRGETREQUESTBIT)(DWORD dwDevice,long mtrcrd);
typedef void  (CALLBACK* DPRSETREQUESTBIT)(DWORD dwDevice,long mtrcrd,long onoff);
typedef long  (CALLBACK* DPRGETFOENABLEBIT)(DWORD dwDevice,long cs);
typedef void  (CALLBACK* DPRSETFOENABLEBIT)(DWORD dwDevice,long cs, long on_off);
typedef void  (CALLBACK* DPRSETFOVALUE)(DWORD dwDevice,long cs, long value);
typedef long  (CALLBACK* DPRGETFOVALUE)(DWORD dwDevice,long cs);


////////////////////////////////////////////////////////////////////////////
// DPR Real Time Data Buffer functions
////////////////////////////////////////////////////////////////////////////
typedef void (CALLBACK* DPRSETHOSTBUSYBIT)(DWORD dwDevice,int value);
typedef int  (CALLBACK* DPRGETHOSTBUSYBIT)(DWORD dwDevice);
typedef int  (CALLBACK* DPRGETPMACBUSYBIT)(DWORD dwDevice);
typedef int  (CALLBACK* DPRGETSERVOTIMER)(DWORD dwDevice);
typedef void (CALLBACK* DPRSETMOTORS)(DWORD dwDevice,UINT n);

typedef double (CALLBACK* DPRGETCOMMANDEDPOS)(DWORD dwDevice,int mtr, double units);
typedef double (CALLBACK* DPRPOSITION)(DWORD dwDevice,int i,double units);
typedef double (CALLBACK* DPRFOLLOWERROR)(DWORD dwDevice,int mtr,double units);
typedef double (CALLBACK* DPRGETVEL)(DWORD dwDevice,int mtr,double units);
typedef void   (CALLBACK* DPRGETMASTERPOS)(DWORD dwDevice,int mtr,double units,double *the_double);
typedef void   (CALLBACK* DPRGETCOMPENSATIONPOS)(DWORD dwDevice,int mtr,double units,double *the_double);

typedef DWORD  (CALLBACK* DPRGETPREVDAC)(DWORD dwDevice,int mtr);
typedef DWORD  (CALLBACK* DPRGETMOVETIME)(DWORD dwDevice,int mtr);

//Gather Time Buffer-Functions pertaining to individual motors
typedef struct ss (CALLBACK* DPRMOTORSERVOSTATUS)(DWORD dwDevice,int mtr);
typedef BOOL (CALLBACK* DPRDATABLOCK)(DWORD dwDevice,int mtr);
typedef BOOL (CALLBACK* DPRPHASEDMOTOR)(DWORD dwDevice,int mtr);
typedef BOOL (CALLBACK* DPRMOTORENABLED)(DWORD dwDevice,int mtr);
typedef BOOL (CALLBACK* DPRHANDWHEELENABLED)(DWORD dwDevice,int mtr);
typedef BOOL (CALLBACK* DPROPENLOOP)(DWORD dwDevice,int mtr);
typedef BOOL (CALLBACK* DPRONNEGATIVELIMIT)(DWORD dwDevice,int mtr);
typedef BOOL (CALLBACK* DPRONPOSITIVELIMIT)(DWORD dwDevice,int mtr);
typedef void (CALLBACK* DPRSETJOGRETURN)(DWORD dwDevice,int mtr);

// Logical query functions
typedef MOTION (CALLBACK* DPRGETMOTORMOTION)(DWORD dwDevice,int mtr);

// Functions pertaining to coord systems
typedef BOOL (CALLBACK* DPRMOTIONBUFOPEN)(DWORD dwDevice);
typedef BOOL (CALLBACK* DPRROTBUFOPEN)(DWORD dwDevice);
typedef double (CALLBACK* DPRGETFEEDRATEMODE)(DWORD dwDevice,int csn, BOOL  *mode);

// Function pertaining to global
typedef BOOL (CALLBACK* DPRSYSSERVOERROR)(DWORD dwDevice);
typedef BOOL (CALLBACK* DPRSYSREENTRYERROR)(DWORD dwDevice);
typedef BOOL (CALLBACK* DPRSYSMEMCHECKSUMERROR)(DWORD dwDevice);
typedef BOOL (CALLBACK* DPRSYSPROMCHECKSUMERROR)(DWORD dwDevice);
typedef struct gs (CALLBACK* DPRGETGLOBALSTATUS)(DWORD dwDevice);

typedef BOOL  (CALLBACK* INTRINIT)(DWORD dwDevice,DWORD dwCallback,DWORD dwFlags,
                            DWORD dwUser,ULONG mask);
typedef BOOL  (CALLBACK* INTRTERMINATE)(DWORD dwDevice);
typedef BOOL  (CALLBACK* INTRWNDMSGINIT)(DWORD dwDevice,HWND hWnd,UINT msg,ULONG ulMask);
typedef DWORD (CALLBACK* INTRTHREADINIT)(DWORD *dwDev);
typedef BOOL  (CALLBACK* INTRFUNCCALLINIT)(DWORD dwDevice,PMACINTRPROC pFunc,DWORD msg,ULONG ulMask);

typedef VOID  (CALLBACK* INTRCALLBACK)(DWORD dwDevice);
typedef VOID  (CALLBACK* INTRQUEUE)(DWORD dwDevice,DWORD dwEvent);
typedef VOID  (CALLBACK* INTRCOMPLETE)(DWORD dwDevice,DWORD dwEvent);
typedef BOOL  (CALLBACK* INTRPROCESSFUNCTION)(DWORD dwDevice,MCFUNC Func,DWORD Param,
                  LPDWORD pResult);

/*****************************************************************************/

//**************************************
// DPR Binary rotary buffer functions
// Initialization/shutdown
typedef SHORT (CALLBACK* DPRROTBUFINIT)(DWORD dwDevice,USHORT bufnum);
typedef SHORT (CALLBACK* DPRROTBUFREMOVE)(DWORD dwDevice,USHORT bufnum);
typedef SHORT (CALLBACK* DPRROTBUFCHANGE)(DWORD dwDevice,USHORT bufnum,USHORT new_size) ;
typedef void  (CALLBACK* DPRROTBUFCLR)(DWORD dwDevice,USHORT bufnum);
typedef SHORT (CALLBACK* DPRROTBUF)(DWORD dwDevice,BOOL on);
typedef int   (CALLBACK* DPRBUFLAST)(DWORD dwDevice);

// Transfer functions
typedef SHORT (CALLBACK* DPRASCIISTRTOROTA)(DWORD dwDevice,PCHAR inpstr, USHORT bufnum);
typedef SHORT (CALLBACK* DPRSENDBINARYCOMMANDA)(DWORD dwDevice,PCHAR inpstr, USHORT bufnum);
typedef SHORT (CALLBACK* DPRASCIISTRTOBINARYFILEA)(PCHAR inpstr, FILE *outfile);

typedef SHORT (CALLBACK* DPRASCIISTRTOROTW)(DWORD dwDevice,PWCHAR inpstr, USHORT bufnum);
typedef SHORT (CALLBACK* DPRSSNDBINARYCOMMANDW)(DWORD dwDevice,PWCHAR inpstr, USHORT bufnum);
typedef SHORT (CALLBACK* DPRASCIISTRTOBINARYFILEW)(PWCHAR inpstr, FILE *outfile);


typedef SHORT (CALLBACK* DPRASCIIFILETOROT)(DWORD dwDevice,FILE *inpfile, USHORT bufnum);
typedef SHORT (CALLBACK* DPRBINARYFILETOROT)(DWORD dwDevice,FILE *inpfile, USHORT bufnum);
typedef SHORT (CALLBACK* DPRASCIITOBINARYFILE)(FILE *inpfile,FILE *outfile);
typedef SHORT (CALLBACK* DPRBINARYTOROT)(DWORD dwDevice,WORD *inpbinptr,WORD **outbinptr,WORD bufnum);

// Variable Background Buffer Functions
// Initialization
typedef long  (CALLBACK* DPRVARBUFINIT)(DWORD dwDevice,long new_num_entries,PLONG addrarray);
typedef long  (CALLBACK* DPRVARBUFINITEX)(DWORD dwDevice,long new_num_entries,PLONG addrarray,PUINT addrtype);
typedef long  (CALLBACK* DPRVARBUFREMOVE)(DWORD dwDevice,long h);
typedef long  (CALLBACK* DPRVARBUFCHANGE)(DWORD dwDevice,long handle, long new_num_entries,
                  long *addrarray);
typedef long  (CALLBACK* DPRVARBUFREAD)(DWORD dwDevice,long h,long entry_num,PLONG long_2);
typedef long  (CALLBACK* PPDPRVARBUFREAD)(DWORD dwControl,long h,long entry_num,PLONG long_2);
typedef long  (CALLBACK* DPRGETVBGADDRESS)(DWORD dwDevice,long h,long entry_num);

typedef long  (CALLBACK* DPRGETVBGNUMENTRIES)(DWORD dwDevice,long h);
typedef long  (CALLBACK* DPRGETVBGDATAOFFSET)(DWORD dwDevice,long h);
typedef long  (CALLBACK* DPRGETVBGADDROFFSET)(DWORD dwDevice,long h);

// Both
typedef UINT  (CALLBACK* DPRGETVBGSERVOTIMER)(DWORD dwDevice);
typedef UINT  (CALLBACK* DPRGETVBGSTARTADDR)(DWORD dwDevice);
typedef int   (CALLBACK* DPRGETVBGTOTALENTRIES)(DWORD dwDevice);

typedef int   (CALLBACK* DPRWRITEBUFFER)(DWORD dwDevice,int num_entries,
                struct VBGWFormat *the_data);


////////////////////////////////////////////////////////////////////////////
// Data Gather functions
////////////////////////////////////////////////////////////////////////////
typedef UINT     (CALLBACK* GETGATHERPERIOD)(DWORD dwDevice);
typedef double   (CALLBACK* GETGATHERSAMPLETIME)(DWORD dwDevice);
typedef UINT     (CALLBACK* GETNUMGATHERSOURCES)(DWORD dwDevice);
typedef UINT     (CALLBACK* GETNUMGATHERSAMPLES)(DWORD dwDevice);
typedef UINT     (CALLBACK* SETGATHERPERIOD)(DWORD dwDevice,UINT msec);
typedef double   (CALLBACK* SETGATHERSAMPLETIME)(DWORD dwDevice,double msec);
typedef BOOL     (CALLBACK* SETGATHERENABLE)(DWORD dwDevice,UINT num,BOOL ena);
typedef BOOL     (CALLBACK* GETGATHERENABLE)(DWORD dwDevice,UINT num);
typedef BOOL     (CALLBACK* SETGATHER)(DWORD dwDevice,UINT num,LPSTR str,BOOL ena);
typedef BOOL     (CALLBACK* SETQUICKGATHER)(DWORD dwDevice,UINT mask,BOOL ena);
typedef BOOL     (CALLBACK* SETQUICKGATHEREX)(DWORD dwDevice,PWTG_EX mask,BOOL ena);
typedef BOOL     (CALLBACK* GETGATHER)(DWORD dwDevice,UINT num,LPSTR str,UINT maxchar);
typedef void     (CALLBACK* CLEARGATHER)(DWORD dwDevice);
typedef BOOL     (CALLBACK* INITGATHER)(DWORD dwDevice,UINT size,double msec);
typedef void     (CALLBACK* CLEARGATHERDATA)(DWORD dwDevice);
typedef double * (CALLBACK* COLLECTGATHERDATA)(DWORD dwDevice,PUINT sources,PUINT samples);
typedef BOOL     (CALLBACK* GETGATHERSAMPLES)(DWORD dwDevice,UINT source,PUINT sample,double *p,UINT max);
typedef BOOL     (CALLBACK* GETGATHERPOINT)(DWORD dwDevice,UINT source,UINT sample,double *p);

typedef int      (CALLBACK* STARTGATHER)(DWORD dwDevice);
typedef int      (CALLBACK* STOPGATHER)(DWORD dwDevice);

// Real time
typedef BOOL     (CALLBACK* INITRTGATHER)(DWORD dwDevice);
typedef void     (CALLBACK* CLEARRTGATHER)(DWORD dwDevice);
typedef BOOL     (CALLBACK* ADDRTGATHER)(DWORD dwDevice,ULONG val);
typedef double * (CALLBACK* COLLECTRTGATHERDATA)(DWORD dwDevice,PUINT sources);

typedef long (CALLBACK* MACROGETIVARIABLELONG)(DWORD dwDevice,DWORD node,UINT num,long def);
typedef BOOL (CALLBACK* MACROUPLOADCONFIG)(DWORD dwDevice,DOWNLOADPROGRESS prgp,char * fname);
//************************************************************************
// NC Type Defines
//************************************************************************
  #ifdef _NC

    #include <nc.h>
    #ifdef __BORLANDC__
      #define COORDTYPE    int
      #define TOOLOFSTYPE  int
    #endif

// block.h
typedef int    (CALLBACK *D_TO_STR)(char *st,char addr,double val,int prec);
typedef PBLOCK (CALLBACK *CREATEBLOCK)(PRS274MAP pMap);
typedef char*  (CALLBACK *PARSERS274)(LPSTR instr,PRS274MAP pMap,PBLOCK pBlk);
typedef int    (CALLBACK *CREATERS274)(LPSTR line,PRS274MAP pMap,PBLOCK pBlk);
typedef void   (CALLBACK *SETBLOCKTODEFAULT)(PRS274MAP pMap,PBLOCK pBlk);

// cncsys.h
typedef PCNCSYSTEM (CALLBACK *CREATECNCSYSTEM)(DWORD dwDevice,DWORD dwControl);
typedef void   (CALLBACK *DELETECNCSYSTEM)(DWORD dwControl);
typedef UINT (CALLBACK * GETNUMBEROFCONTROLS)(void);
typedef PCNCSYSTEM (CALLBACK * GETCONTROL)(DWORD dwControl);
typedef void (CALLBACK * SETDNCMODE)(DWORD dwControl,BOOL dnc);
typedef BOOL (CALLBACK * GETDNCMODE)(DWORD dwControl);

//typedef void (CALLBACK * READCNCSYSTEMPROFILE)(DWORD dwControl);
//typedef void (CALLBACK * WRITECNCSYSTEMPROFILE)(DWORD dwControl);
typedef BOOL (CALLBACK * RESETCNCSYSTEM)(DWORD dwControl);
typedef BOOL (CALLBACK * STARTUPCODE)(DWORD dwControl);
typedef LPCSTR (CALLBACK * SZLOADNCSTRING)(int iID);
typedef void (CALLBACK * READERRORPROFILE)(LPSTR szInitFileName,char *errorString,ERRORMODE errType,int errNumber);

typedef BOOL (CALLBACK * OPENTEXTFILE)(DWORD dwControl,DWORD dwCoord,HWND hWindow,LPSTR fName);
typedef void (CALLBACK * CLOSETEXTFILE)(DWORD dwControl,DWORD dwCoord);

typedef BOOL (CALLBACK * RUNCNCSYSTEM)(DWORD dwControl);
typedef void (CALLBACK * STOPCNCSYSTEM)(DWORD dwControl);
typedef void (CALLBACK * UPDATECNCSYSTEM)(DWORD dwControl);
typedef void (CALLBACK * DOIO)(DWORD dwControl);
typedef BOOL (CALLBACK * DOCOMMAND)(DWORD dwControl,UINT id,UINT iv,double fv,LPSTR str);
typedef BOOL (CALLBACK * NCCOMMAND)(DWORD dwControl,UINT id,UINT iv,double fv,LPSTR str);
typedef LPSTR (CALLBACK * GETTITLE)(DWORD dwControl,LPSTR str,UINT maxchar);
typedef void (CALLBACK * SETTITLE)(DWORD dwControl,LPSTR str);

typedef void (CALLBACK * SETOPERATIONMODE)(DWORD dwControl,OPERMODE m);
typedef DWORD (CALLBACK * GETNUMCOORDSYSTEMS)(DWORD dwControl);
typedef DWORD (CALLBACK * GETCOORDSYSTEM)(DWORD dwControl);
typedef void (CALLBACK * SETCOORDSYSTEM)(DWORD dwControl,DWORD dwCoord);
typedef MODESELECT (CALLBACK * GETMODE)(DWORD dwControl);
typedef void (CALLBACK * SETMODE)(DWORD dwControl,MODESELECT mode);
typedef AXISSELECT (CALLBACK * GETAXISSELECT)(DWORD dwControl,DWORD dwCoord);
typedef BOOL (CALLBACK * SETAXISSELECT)(DWORD dwControl,DWORD dwCoord,AXISSELECT ax);
typedef JOGSELECT (CALLBACK * GETJOGSELECT)(DWORD dwControl);
typedef void (CALLBACK * SETJOGSELECT)(DWORD dwControl,JOGSELECT j);
typedef SPEEDSELECT (CALLBACK * GETSPEEDSELECT)(DWORD dwControl);
typedef BOOL (CALLBACK * SETSPEEDSELECT)(DWORD dwControl,SPEEDSELECT speed);
typedef SPEEDSELECT (CALLBACK * GETDISTANCESELECT)(DWORD dwControl);
typedef void (CALLBACK * SETDISTANCESELECT)(DWORD dwControl,SPEEDSELECT ss);

typedef double        (CALLBACK * GETFEEDOVERRIDE)(DWORD dwControl,DWORD dwCoord);
typedef void          (CALLBACK * SETFEEDOVERRIDE)(DWORD dwControl,DWORD dwCoord,double ff);
typedef FEEDOVRSELECT (CALLBACK * GETFEEDOVRSELECT)(DWORD dwControl,DWORD dwCoord);
typedef void          (CALLBACK * SETFEEDOVRSELECT)(DWORD dwControl,DWORD dwCoord,FEEDOVRSELECT f);
typedef double        (CALLBACK * GETRAPIDOVERRIDE)(DWORD dwControl,DWORD dwCoord);
typedef void          (CALLBACK * SETRAPIDOVERRIDE)(DWORD dwControl,DWORD dwCoord,double rr);
typedef RAPIDOVRSELECT (CALLBACK * GETRAPIDOVRSELECT)(DWORD dwControl,DWORD dwCoord);
typedef void          (CALLBACK * SETRAPIDOVRSELECT)(DWORD dwControl,DWORD dwCoord,RAPIDOVRSELECT rr);
typedef CLNTSELECT    (CALLBACK * GETCOOLANTSELECT)(DWORD dwControl);
typedef CLNTSELECT    (CALLBACK * GETCOOLANTSTATUS)(DWORD dwControl);
typedef void          (CALLBACK * SETCOOLANTSELECT)(DWORD dwControl,CLNTSELECT c);

typedef void          (CALLBACK * DRAWPOSITIONS)(DWORD dwControl,HWND hWnd,POSTYPE disp,
  HFONT hDigitFont,HFONT hUnitsFont,COLORREF digitColor,COLORREF unitsColor,BOOL displayUnits);
typedef void          (CALLBACK * DRAWPOSITIONSRECT)(DWORD dwControl,DWORD dwCoord,HDC dc,RECT *r,
  POSTYPE disp,HFONT hDigitFont,HFONT hUnitsFont,COLORREF digitColor,COLORREF unitsColor,BOOL displayUnits);

typedef void (CALLBACK * SETMETRICUNITS)(DWORD dwControl,DWORD dwCoord,BOOL status);
typedef BOOL (CALLBACK * GETMETRICUNITS)(DWORD dwControl,DWORD dwCoord);

typedef BOOL   (CALLBACK * GETAXISENABLED)(DWORD dwControl,DWORD dwCoord,TCHAR ax);
typedef BOOL   (CALLBACK * GETMACHINELOCK)(DWORD dwControl);
typedef void   (CALLBACK * SETMACHINELOCK)(DWORD dwControl,BOOL newval);
typedef MACHINETYPE (CALLBACK * GETMACHINETYPE)(DWORD dwControl);
typedef BOOL   (CALLBACK * GETPROGRAMLOADED)(DWORD dwControl,DWORD dwCoord);
typedef UINT   (CALLBACK * GETSEMAPHORE)(DWORD dwControl,DWORD dwCoord);
typedef BOOL   (CALLBACK * GETPROGRAMSTATUS)(DWORD dwControl,DWORD dwCoord,PULONG numLines,PULONG line,PULONG parseLine,PUINT repeat,PUINT count);
typedef UINT   (CALLBACK * GETCURRENTLABEL)(DWORD dwControl,DWORD dwCoord);
typedef double (CALLBACK * GETJOGSTEP)(DWORD dwControl,DWORD dwCoord);
typedef double (CALLBACK * GETHANDLESTEP)(DWORD dwControl,DWORD dwCoord);
typedef PMOTOR (CALLBACK * GETAXISPOINTER)(DWORD dwControl,DWORD dwCoord,TCHAR ax);
typedef PMOTOR (CALLBACK * GETSELECTEDAXISPOINTER)(DWORD dwControl);
typedef UINT   (CALLBACK * GETNUMDISPLAYAXIS)(DWORD dwControl,DWORD dwCoord);
typedef UINT   (CALLBACK * GETNUMDISPLAYAXISTOTAL)(DWORD dwControl);
typedef UINT   (CALLBACK * GETNUMAXISTOTAL)(DWORD dwControl);

//typedef double (CALLBACK * GETSELECTEDAXISJOGSTEP)(DWORD dwControl,DWORD dwCoord);
//typedef double (CALLBACK * GETSELECTEDAXISHANDLESTEP)(DWORD dwControl,DWORD dwCoord);
typedef TCHAR  (CALLBACK * GETSELECTEDAXISCHAR)(DWORD dwControl);
typedef int    (CALLBACK * GETCURRENTGVALUE)(DWORD dwControl,DWORD dwCoord,UINT group);
typedef ERRORMODE (CALLBACK * GETCURRENTERRORLEVEL)(DWORD dwControl);

typedef BOOL   (CALLBACK * GETSINGLEBLOCK)(DWORD dwControl);
typedef BOOL   (CALLBACK * SETSINGLEBLOCK)(DWORD dwControl,BOOL status);
typedef BOOL   (CALLBACK * GETBLOCKDELETE)(DWORD dwControl);
typedef BOOL   (CALLBACK * SETBLOCKDELETE)(DWORD dwControl,BOOL status);
typedef BOOL   (CALLBACK * GETOPTIONALSTOP)(DWORD dwControl);
typedef BOOL   (CALLBACK * SETOPTIONALSTOP)(DWORD dwControl,BOOL status);

typedef BOOL       (CALLBACK * GETINPOSITION)(DWORD dwControl,DWORD dwCoord);
typedef BUFFERMODE (CALLBACK * GETBUFFERMODE)(DWORD dwControl,DWORD dwCoord);
typedef BUFFERMODE (CALLBACK * GETSELECTEDBUFFERMODE)(DWORD dwControl);
typedef void       (CALLBACK * SETBUFFERMODE)(DWORD dwControl,DWORD dwCoord,BUFFERMODE bm);
typedef PROGRAM    (CALLBACK * GETPROGRAMMODE)(DWORD dwControl,DWORD dwCoord);
typedef MOTION     (CALLBACK * GETSELECTEDAXISMOTIONMODE)(DWORD dwControl);
typedef MOTIONMODE (CALLBACK * GETPROGRAMMOTIONMODE)(DWORD dwControl,DWORD dwCoord);
typedef BOOL       (CALLBACK * GETBUFFEROPEN)(DWORD dwControl);
typedef UINT       (CALLBACK * GETBUFFERREMAINING)(DWORD dwControl,DWORD dwCoord);

typedef TIMEBASEMODE (CALLBACK * GETTIMEBASEMODE)(DWORD dwControl,DWORD dwCoord);
typedef void         (CALLBACK * SETTIMEBASEMODE)(DWORD dwControl,DWORD dwCoord,TIMEBASEMODE mode);

//typedef FEEDRATEMODE (CALLBACK * GETFEEDRATEMODE)(DWORD dwControl,DWORD dwCoord);
//typedef void         (CALLBACK * SETFEEDRATEMODE)(DWORD dwControl,DWORD dwCoord,FEEDRATEMODE mode);
typedef double       (CALLBACK * GETFEEDRATE)(DWORD dwControl,DWORD dwCoord,FEEDRATEMODE *mode);
typedef void         (CALLBACK * SETFEEDRATE)(DWORD dwControl,DWORD dwCoord,double fr,FEEDRATEMODE mode);
typedef BOOL         (CALLBACK * GETDRYRUN)(DWORD dwControl,DWORD dwCoord);
typedef void         (CALLBACK * SETDRYRUN)(DWORD dwControl,DWORD dwCoord,BOOL mode);
typedef double       (CALLBACK * GETTHREADLEAD)(DWORD dwControl,DWORD dwCoord);
typedef void         (CALLBACK * SETTHREADLEAD)(DWORD dwControl,DWORD dwCoord,double lead);

typedef double       (CALLBACK * GETPOSITIONBIAS)(DWORD dwControl,DWORD dwCoord,TCHAR ax,BOOL metric);

typedef double       (CALLBACK * METRICCONVERSION)(double value,BOOL ismetric,BOOL wantmetric);
typedef ULONG        (CALLBACK * GETPARTSTOTAL)(DWORD dwControl);
typedef void         (CALLBACK * SETPARTSTOTAL)(DWORD dwControl,ULONG val);
typedef ULONG        (CALLBACK * GETPARTSREQUIRED)(DWORD dwControl);
typedef void         (CALLBACK * SETPARTSREQUIRED)(DWORD dwControl,ULONG val);
typedef ULONG        (CALLBACK * GETPARTSCOUNT)(DWORD dwControl);
typedef void         (CALLBACK * SETPARTSCOUNT)(DWORD dwControl,ULONG val);

typedef double       (CALLBACK * GETACTIVEGCODE)(DWORD dwControl,DWORD dwCoord,UINT group);
typedef LPSTR        (CALLBACK * GETACTIVEGCODESTR)(DWORD dwControl,DWORD dwCoord,UINT group,LPSTR str);

typedef UINT         (CALLBACK * GETTOOLOFFSET)(DWORD dwControl,DWORD dwCoord);
typedef UINT         (CALLBACK * GETCOMPOFFSET)(DWORD dwControl,DWORD dwCoord);

typedef void         (CALLBACK * GETOPERATINGTIME)(DWORD dwControl,PLONG days,PLONG hours,PLONG minutes,PLONG seconds);
typedef void         (CALLBACK * GETCYCLETIME)(DWORD dwControl,PLONG hours,PLONG minutes,PLONG seconds);
typedef void         (CALLBACK * GETRUNNINGTIME)(DWORD dwControl,PLONG days,PLONG hours,PLONG minutes,PLONG seconds);
typedef void         (CALLBACK * GETCYCLECUTTINGTIME)(DWORD dwControl,PLONG hours,PLONG minutes,PLONG seconds);
typedef void         (CALLBACK * GETTOTALCUTTINGTIME)(DWORD dwControl,PLONG days,PLONG hours,PLONG minutes,PLONG seconds);

typedef DWORD        (CALLBACK * GETINPUTDWORD)(DWORD dwControl,DWORD num);
typedef DWORD        (CALLBACK * GETOUTPUTDWORD)(DWORD dwControl,DWORD num);
typedef DWORD        (CALLBACK * GETCOMMANDDWORD)(DWORD dwControl,DWORD num);
typedef DWORD        (CALLBACK * GETSTATUSDWORD)(DWORD dwControl,DWORD num);
typedef DWORD        (CALLBACK * GETCHANGEDWORD)(DWORD dwControl,DWORD num);

typedef UINT         (CALLBACK * GETHOMEREFERENCE)(DWORD dwControl);
typedef void         (CALLBACK * SETHOMEREFERENCE)(DWORD dwControl,UINT status);
typedef BOOL         (CALLBACK * GETHOMEINIT)(DWORD dwControl);
typedef void         (CALLBACK * SETHOMEINIT)(DWORD dwControl,BOOL status);
typedef DWORD        (CALLBACK * GETHOMEMOTORMASK)(DWORD dwControl);
typedef void         (CALLBACK * SETHOMEMOTORMASK)(DWORD dwControl,DWORD mask);
typedef BOOL         (CALLBACK * GETHOMEINPROGRESS)(DWORD dwControl);

typedef BOOL (CALLBACK * READ274)(DWORD dwControl,DWORD dwCoord);
typedef BOOL (CALLBACK * ROTATEBLOCKARRAY)(DWORD dwControl,DWORD dwCoord);
typedef void (CALLBACK * RESETBLOCKARRAY)(DWORD dwControl,DWORD dwCoord);
typedef void (CALLBACK * REWINDPROGBUFFER)(DWORD dwControl,DWORD dwCoord,BOOL rewindMain);
typedef void (CALLBACK * DEFINEROTARYBUFFERS)(DWORD dwControl);
typedef void (CALLBACK * CLEARROTARYBUFFER)(DWORD dwControl,DWORD dwCoord);
typedef void (CALLBACK * OPENROTARYBUFFER)(DWORD dwControl,BOOL clear);
typedef UINT (CALLBACK * LOADMDIBUFFER)(DWORD dwControl,DWORD dwCoord,HWND hdlg,int idControl,UINT repeat);
typedef void (CALLBACK * READMDIBUFFER)(DWORD dwControl,DWORD dwCoord,HWND hdlg,int idControl);

typedef double (CALLBACK * GETVECTORVELOCITY)(DWORD dwControl,DWORD dwCoord);
typedef BOOL (CALLBACK * ALLAXISHOMED)(DWORD dwControl);
//typedef int  (CALLBACK * CREATEPMACLINE)(DWORD dwControl,DWORD dwCoord,char *sp);
typedef int  (CALLBACK * OFFSETTOPMAC)(DWORD dwControl,DWORD dwCoord,char *sp,COORDTYPE coord);

typedef int  (CALLBACK * STOREDSTROKECHECK)(DWORD dwControl,DWORD dwCoord,char *sp);

typedef int  (CALLBACK * COORDLOCATIONSTR)(DWORD dwControl,DWORD dwCoord,char *sp,COORDTYPE t);

typedef void (CALLBACK * SETSYSCOORD)(DWORD dwControl,DWORD dwCoord,COORDTYPE t,double v,BOOL each,BOOL inc,BOOL mm,BOOL rad);
typedef void (CALLBACK * SETSYSLOCAL)(DWORD dwControl,DWORD dwCoord,double v,BOOL each,BOOL inc,BOOL mm,BOOL rad);
typedef void (CALLBACK * SETSYSWORK)(DWORD dwControl,DWORD dwCoord,double v,BOOL each,BOOL inc,BOOL mm,BOOL rad);

typedef void (CALLBACK * SETTOOLOFFSETS)(DWORD dwControl,DWORD dwCoord,struct tagBlock *blk);
typedef void (CALLBACK * PROGRAMDATAINPUT)(DWORD dwControl,DWORD dwCoord,struct tagBlock *blk);
typedef BOOL (CALLBACK * SYSTEMJOG)(DWORD dwControl,char c);
typedef BOOL (CALLBACK * SYSTEMAUTO)(DWORD dwControl,char c);
typedef BOOL (CALLBACK * GETFILENAMEFROMBLOCK)(DWORD dwCoord,struct tagBlock *blk,LPSTR fname,LPSTR ext);
typedef void (CALLBACK * SETBUFFERMODE)(DWORD dwControl,DWORD dwCoord,BUFFERMODE bm);
typedef BOOL (CALLBACK * OPENASCIIFILE)(DWORD dwControl,DWORD dwCoord,LPSTR filename);
typedef BOOL (CALLBACK * OPENBINARYFILE)(DWORD dwControl,DWORD dwCoord,LPSTR filename);
typedef void (CALLBACK * CLOSEASCIIFILE)(DWORD dwControl,DWORD dwCoord);
typedef void (CALLBACK * CLOSEBINARYFILE)(DWORD dwControl,DWORD dwCoord);
typedef BOOL (CALLBACK * REGISTERBUFFERMODE)(DWORD dwControl,DWORD dwCoord);
typedef BOOL (CALLBACK * REGISTERHIGHSPEED)(DWORD dwControl,DWORD dwCoord);
typedef BOOL (CALLBACK * CALLHIGHSPEED)(DWORD dwControl,DWORD dwCoord,LPSTR filename,BOOL skip);

typedef void (CALLBACK * HOME)(DWORD dwControl,BOOL all); // start homing sequence
typedef BOOL (CALLBACK * TURRETJOG)(DWORD dwControl,char ch);
typedef BOOL (CALLBACK * SETORGIN)(DWORD dwControl,DWORD dwCoord,BOOL bOrginAll,ADDRESS adr,BOOL bClear,double v,BOOL metric);
typedef void (CALLBACK * ZEROSHIFT)(DWORD dwControl,DWORD dwCoord,BOOL bShiftAll,ADDRESS adr,BOOL bClear,double v,BOOL metric);
typedef int  (CALLBACK * COORDSYSSET)(DWORD dwControl,DWORD dwCoord,char *sp);
typedef void (CALLBACK * EXTOFFSETSET)(DWORD dwControl,DWORD dwCoord,UINT type);

// Spindle functions
typedef void (CALLBACK * DRAWSPINDLE)(DWORD dwControl,HDC hdc,int x, int y ,
      COLORREF aColor,COLORREF nColor);
typedef void (CALLBACK * DRAWSPINDLEMEASURE)(DWORD dwControl,HDC hdc, int x, int y,
      COLORREF color);

typedef BOOL (CALLBACK * PROGRAMSDOWNLOADED)(DWORD dwControl);
typedef void (CALLBACK * EXITING)(HINSTANCE hInstance);


// coordsys.h
typedef BOOL   (CALLBACK *CREATECOORDSYS)(DWORD dwControl,DWORD dwCoord);
typedef void   (CALLBACK *DELETECOORDSYS)(DWORD dwControl,DWORD dwCoord);
typedef void   (CALLBACK *WRITECOORDSYSPROFILE)(DWORD dwControl,DWORD dwCoord);
typedef void   (CALLBACK *READCOORDSYSPROFILE)(DWORD dwControl,DWORD dwCoord);
//typedef char*  (CALLBACK *COORDSYSSTRING)(DWORD dwControl,DWORD dwCoord,char *s,int index,COORDTYPE t);
typedef void   (CALLBACK *SETCOORD)(DWORD dwControl,DWORD dwCoord,int index,COORDTYPE t,double v);
typedef void   (CALLBACK *CALCCOORDSYS)(DWORD dwControl,DWORD dwCoord);
typedef double (CALLBACK * GETOFFSETVALUE)(DWORD dwControl,DWORD dwCoord,TCHAR ax,COORDTYPE t,BOOL wantmetric);
typedef BOOL   (CALLBACK * SETOFFSETVALUE)(DWORD dwControl,DWORD dwCoord,TCHAR ax,COORDTYPE t,double v,BOOL ismetric);
typedef void   (CALLBACK * AUTOSETOFFSET) (DWORD dwControl,DWORD dwCoord,TCHAR axis,COORDTYPE t);
typedef LPSTR  (CALLBACK * GETOFFSETSTRING)(DWORD dwControl,DWORD dwCoord,LPTSTR s,TCHAR ax,COORDTYPE t,BOOL wantmetric);

// motor.h
typedef PMOTOR (CALLBACK *CREATEMOTOR)(LPSTR szPName,DWORD dwC,DWORD dwCs,UINT mtr,char ax);
typedef void   (CALLBACK *DELETEMOTOR)(PMOTOR m);
typedef double (CALLBACK *INPUTCONVERSION)(PMOTOR m,double v,BOOL metric);
typedef double (CALLBACK *OUTPUTCONVERSION)(PMOTOR m,double v,BOOL metric);
typedef double (CALLBACK *POSTOMACH)(PMOTOR m,double val,BOOL metric,BOOL abs);
typedef int    (CALLBACK *POSTOMACHSTR)(char *sp,PMOTOR m,PBLOCK blk,PRS274MAP map);
typedef void   (CALLBACK *MAPMOTORPARAMETERS)(PMOTOR m);
typedef UINT   (CALLBACK *MOTORERROR)(PMOTOR m);
typedef void   (CALLBACK *MAPMOTORCOORDSYS)(PMOTOR m);
typedef void   (CALLBACK *WRITEMOTORPROFILE)(PMOTOR m);
typedef void   (CALLBACK *READMOTORPROFILE)(PMOTOR m);
typedef void   (CALLBACK *AXISTOSPINDLE)(PMOTOR m);
typedef void   (CALLBACK *SPINDLETOAXIS)(PMOTOR m);
typedef void   (CALLBACK *SETMOTORRAPID)(PMOTOR m,double rapid);
typedef void   (CALLBACK *SETJOGRETURN)(PMOTOR m);
typedef void   (CALLBACK *SETMOTORHANDLE)(PMOTOR m,BOOL on,double step);
typedef void   (CALLBACK *JOG)(PMOTOR m,char ch);
typedef void   (CALLBACK *JOGSTOP)(PMOTOR m);
typedef void   (CALLBACK *JOGSTEP)(PMOTOR m,char ch,double dist);
typedef void   (CALLBACK *SETJOGFEED)(PMOTOR m,double feed);
typedef BOOL   (CALLBACK *HOMECOMPLETE)(PMOTOR m);
typedef BOOL   (CALLBACK *CLOSELOOP)(PMOTOR m);
typedef void   (CALLBACK * SETMOTORCOORD)(DWORD dwControl,DWORD dwCoord,ADDRESS adr,COORDTYPE t,
                            double v,BOOL incremental,BOOL metric);
//typedef void   (CALLBACK * UPDATEMOTOR2)(PCNCSYSTEM sys,PMOTOR m,UINT csn);
typedef void   (CALLBACK * UPDATEMOTOR)(DWORD dwControl,DWORD dwCoord,ADDRESS adr);
typedef void   (CALLBACK * UPDATEALLMOTORS)(DWORD dwControl);

typedef LPSTR  (CALLBACK * GETAXISFORMATSTR)(DWORD dwControl,DWORD dwCoord,TCHAR ax,LPSTR str,BOOL metric);
typedef void   (CALLBACK * GETAXISFORMAT)(DWORD dwControl,DWORD dwCoord,TCHAR ax,PUINT len,PUINT decplaces,BOOL metric);
typedef void   (CALLBACK * SETAXISFORMAT)(DWORD dwControl,DWORD dwCoord,TCHAR ax,UINT len,UINT decplaces,BOOL metric);
//typedef void   (CALLBACK * SETDISPLAYFORMAT)(PMOTOR m);
typedef double (CALLBACK * GETAXISPOSITION)(DWORD dwControl,DWORD dwCoord,ADDRESS adr,POSTYPE t);

// draw.h
typedef void   (CALLBACK *DRAWMOTOR)(DWORD dwControl,DWORD dwCoord,DWORD dwMtr,HDC pDC,int x,int y,POSTYPE t,
    COLORREF aColor,COLORREF nColor,BOOL dispcoord);
typedef void   (CALLBACK *DRAWMOTORCOORD)(DWORD dwControl,DWORD dwCoord,DWORD dwMtr,HDC hdc,int x,int y,COORDTYPE t,
    COLORREF aColor,COLORREF nColor,BOOL dispcoord);
typedef void   (CALLBACK *DRAWMOTORMEASURE)(DWORD dwControl,DWORD dwCoord,DWORD dwMtr,HDC hDC, int x,int y,COLORREF color);

// spindle .h
typedef void  (CALLBACK * SETSPINDLESELECT)(DWORD dwControl,SPINDLESELECT sel);
typedef SPINDLESELECT (CALLBACK * GETSPINDLESELECT)(DWORD dwControl);
typedef UINT          (CALLBACK * GETSPINDLERPM)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLERPM)(DWORD dwControl,UINT rpm);
typedef double        (CALLBACK * GETSPINDLECSS)(DWORD dwControl);
typedef UINT          (CALLBACK * GETSPINDLEACTRPM)(DWORD dwControl);
typedef UINT          (CALLBACK * GETSPINDLEMAXRPM)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLEMAXRPM)(DWORD dwControl,UINT rpm);
typedef BOOL          (CALLBACK * GETSPINDLECSSMODE)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLECSSMODE)(DWORD dwControl,BOOL status);
typedef void  (CALLBACK * SETSPINDLEOVERRIDE)(DWORD dwControl,DWORD dwCoord,double rr);
typedef double        (CALLBACK * GETSPINDLEOVERRIDE)(DWORD dwControl,DWORD dwCoord);
typedef void          (CALLBACK * SETSPINDLEOVRSELECT)(DWORD dwControl,SPINDLEOVRSELECT s);
typedef SPINDLEOVRSELECT (CALLBACK * GETSPINDLEOVRSELECT)(DWORD dwControl);

typedef double        (CALLBACK * GETSPINDLECTSREV)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLECTSREV)(DWORD dwControl,double cts);
typedef double        (CALLBACK * GETSPINDLECSSUNITS)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLECSSUNITS)(DWORD dwControl,double unit);
typedef void          (CALLBACK * SETSPINDLECSS)(DWORD dwControl,double css);
typedef double        (CALLBACK * GETSPINDLEGEARRATIO)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLEGEARRATIO)(DWORD dwControl,double ratio);
typedef UINT          (CALLBACK * GETSPINDLECMDRPM)(DWORD dwControl);
typedef BOOL          (CALLBACK * GETSPINDLEDETECT)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLEDETECT)(DWORD dwControl,BOOL status);
typedef BOOL          (CALLBACK * GETSPINDLEATZERO)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLEATZERO)(DWORD dwControl,BOOL status);
typedef BOOL          (CALLBACK * GETSPINDLEATSPEED)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLEATSPEED)(DWORD dwControl,BOOL status);
typedef BOOL          (CALLBACK * GETSPINDLEFPR)(DWORD dwControl);
typedef void          (CALLBACK * SETSPINDLEFPR)(DWORD dwControl,BOOL status);

// textbuf.h
typedef int    (CALLBACK *GETPROGRAMINSTANCE)(DWORD dwControl,DWORD dwCoord);
typedef int    (CALLBACK *GETPROGRAMNUMBER)(DWORD dwControl,DWORD dwCoord);
typedef BOOL   (CALLBACK *GETCURRENTLINE)(DWORD dwControl,DWORD dwCoord,LPSTR str,UINT max);
typedef BOOL   (CALLBACK *GETBUFFERLINE)(DWORD dwControl,DWORD dwCoord,LPSTR str,ULONG line,UINT max);
typedef BOOL   (CALLBACK *GETNEXTLINE)(DWORD dwControl,DWORD dwCoord,LPSTR str,UINT max);
typedef BOOL   (CALLBACK *GETPREVLINE)(DWORD dwControl,DWORD dwCoord,LPSTR str,UINT max);
typedef BOOL   (CALLBACK *SETDISPLINENUMBER)(DWORD dwControl,DWORD dwCoord,ULONG line);
typedef ULONG  (CALLBACK *GETDISPLINENUMBER)(DWORD dwControl,DWORD dwCoord);
typedef LPTSTR (CALLBACK *GETPROGRAMNAME)(DWORD dwControl,DWORD dwCoord,LPTSTR str,UINT maxchar,BOOL main);
typedef LPTSTR (CALLBACK *GETPROGRAMPATH)(DWORD dwControl,DWORD dwCoord,LPTSTR str,UINT maxchar,BOOL main);

typedef UINT   (CALLBACK *READEDITBUFFER)(DWORD dwControl,DWORD dwCoord,BOOL mdi,HWND hdlg,int idControl,UINT repeat);
typedef void   (CALLBACK *WRITEEDITBUFFER)(DWORD dwControl,DWORD dwCoord,BOOL mdi,HWND hdlg,int idControl);
typedef void   (CALLBACK *REWINDTEXTBUFFER)(DWORD dwControl,DWORD dwCoord,BOOL rewindMain);
typedef void   (CALLBACK *CLEARTEXTBUFFER)(DWORD dwControl,DWORD dwCoord);
typedef BOOL   (CALLBACK *SEARCHTEXTNEXT)(DWORD dwControl,DWORD dwCoord,LPSTR Text);
typedef BOOL   (CALLBACK *SEARCHADDRESSNEXT)(DWORD dwControl,DWORD dwCoord,char adr,double val);
typedef BOOL   (CALLBACK *SEARCHTEXT)(DWORD dwControl,DWORD dwCoord,LPSTR Text);
typedef BOOL   (CALLBACK *SEARCHADDRESS)(DWORD dwControl,DWORD dwCoord,char adr,double val);
typedef BOOL   (CALLBACK *SETCURRENTLINE)(DWORD dwControl,DWORD dwCoord,ULONG line,BOOL parse);
typedef void   (CALLBACK *DISPLAYTEXTBUFFER)(DWORD dwControl,DWORD dwCoord,HWND hWnd,
  COLORREF bkcolor,COLORREF prevcolor,COLORREF nextcolor,COLORREF atcolor);
typedef void   (CALLBACK *DISPLAYTEXTBUFFERRECT)(DWORD dwControl,DWORD dwCoord,HDC  hdc,RECT r,
  COLORREF bkcolor,COLORREF prevcolor,COLORREF nextcolor,COLORREF atcolor);
typedef BOOL   (CALLBACK * GETDNCCONFIG)(DWORD dwControl,DWORD dwCoord,PDWORD port,PDWORD baud,
                           PBYTE parity,PBYTE size,PBYTE stop);
typedef BOOL   (CALLBACK * SETDNCCONFIG)(DWORD dwControl,DWORD dwCoord,DWORD port,DWORD baud,
                           BYTE parity,BYTE size,BYTE stop);

// tool.h
typedef PTOOL  (CALLBACK *CREATETOOL)(DWORD dwCoord,LPSTR szPName,UINT tool);
typedef void   (CALLBACK *DELETETOOL)(PTOOL t);
typedef void   (CALLBACK *READTOOLPROFILE)(PTOOL t);
typedef void   (CALLBACK *WRITETOOLPROFILE)(PTOOL t);
typedef void   (CALLBACK *PRINTTOOLSPEC)(PTOOL t,HDC pDC,int x,int y,int aTabs[],int n,BOOL metricDisplay);
typedef void   (CALLBACK *PRINTTOOLOFFSET)(PTOOL t,HDC pDC,int x,int y,BOOL metricDisplay);
typedef LPCSTR (CALLBACK *TOOLTYPESTRING)(PTOOL t);
typedef LPCSTR (CALLBACK *TOOLMATERIALSTRING)(PTOOL t);
typedef int    (CALLBACK *TOOLOFFSETSTRING)(PTOOL t,LPSTR s,BOOL wantmetric);
typedef int    (CALLBACK *TOOLSTRING)(PTOOL t,LPSTR s,BOOL wantmetric);

typedef double (CALLBACK * GETTYPETOOLOFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR chAxis,TOOLOFSTYPE type,BOOL wantmetric);
typedef void   (CALLBACK * SETTYPETOOLOFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR chAxis,TOOLOFSTYPE type,double fValue,UINT nValue,BOOL wantmetric);
typedef double (CALLBACK * GETTOOLTIPANGLE)(DWORD dwControl,DWORD dwCoord,UINT tool,BOOL wantmetric);
typedef void   (CALLBACK * SETTOOLTIPANGLE)(DWORD dwControl,DWORD dwCoord,UINT tool,double val,BOOL ismetric);
typedef double (CALLBACK * GETTOOLCLEARANCEANGLE)(DWORD dwControl,DWORD dwCoord,UINT tool,BOOL wantmetric);
typedef void   (CALLBACK * SETTOOLCLEARANCEANGLE)(DWORD dwControl,DWORD dwCoord,UINT tool,double val,BOOL ismetric);
typedef double (CALLBACK * GETTOOLCOMP)(DWORD dwControl,DWORD dwCoord,UINT tool,BOOL wantmetric);
typedef void   (CALLBACK * SETTOOLCOMP)(DWORD dwControl,DWORD dwCoord,UINT tool,double val,BOOL ismetric);
typedef BOOL   (CALLBACK * GETTOOLCOMPDIA)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef void   (CALLBACK * SETTOOLCOMPDIA)(DWORD dwControl,DWORD dwCoord,UINT tool,BOOL status);
typedef double (CALLBACK * GETTOOLRADIUS)(DWORD dwControl,DWORD dwCoord,UINT tool,BOOL wantmetric);
typedef void   (CALLBACK * SETTOOLRADIUS)(DWORD dwControl,DWORD dwCoord,UINT tool,double val,BOOL ismetric);
typedef BOOL   (CALLBACK * GETTOOLMETRICUNITS)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef void   (CALLBACK * SETTOOLMETRICUNITS)(DWORD dwControl,DWORD dwCoord,UINT tool,BOOL metric);
typedef double (CALLBACK * GETTOOLGEOMETRYOFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR ax,BOOL wantmetric);
typedef void   (CALLBACK * SETTOOLGEOMETRYOFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR ax,double val,BOOL ismetric);
typedef double (CALLBACK * GETTOOLWEAROFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR ax,BOOL wantmetric);
typedef void   (CALLBACK * SETTOOLWEAROFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR ax,double val,BOOL ismetric);
typedef double (CALLBACK * GETTOOLGUAGEOFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR ax,BOOL wantmetric);
typedef void   (CALLBACK * SETTOOLGUAGEOFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR ax,double val,BOOL ismetric);
typedef TOOLTYPE (CALLBACK * GETTOOLTYPE)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef void   (CALLBACK * SETTOOLTYPE)(DWORD dwControl,DWORD dwCoord,UINT tool,TOOLTYPE t);
typedef MATERIALTYPE (CALLBACK * GETTOOLMATERIAL)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef void   (CALLBACK * SETTOOLMATERIAL)(DWORD dwControl,DWORD dwCoord,UINT tool,MATERIALTYPE m);
typedef TOOLHAND (CALLBACK * GETTOOLHAND)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef void   (CALLBACK * SETTOOLHAND)(DWORD dwControl,DWORD dwCoord,UINT tool,TOOLHAND m);
//typedef UINT   (CALLBACK * GETTOOLNUMBER)(DWORD dwControl,DWORD dwCoord);
//typedef void   (CALLBACK * SETTOOLNUMBER)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef UINT   (CALLBACK * GETTOOLHOLDERNUMBER)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef void   (CALLBACK * SETTOOLHOLDERNUMBER)(DWORD dwControl,DWORD dwCoord,UINT tool,UINT holder);
typedef TOOLDIRECTION (CALLBACK * GETTOOLDIRECTION)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef void   (CALLBACK * SETTOOLDIRECTION)(DWORD dwControl,DWORD dwCoord,UINT tool,TOOLDIRECTION dir);
typedef void    (CALLBACK *AUTOSETTOOLOFFSET)(DWORD dwControl,DWORD dwCoord,UINT tool,TCHAR axis);

typedef UINT   (CALLBACK * GETNUMOFTOOLS)(DWORD dwControl,DWORD dwCoord);
typedef UINT   (CALLBACK * GETSYSTOOLNUMBER)(DWORD dwControl,DWORD dwCoord);
typedef void   (CALLBACK * SETSYSTOOLNUMBER)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef UINT   (CALLBACK * GETNEXTTOOLNUMBER)(DWORD dwControl,DWORD dwCoord);
typedef void   (CALLBACK * SETNEXTTOOLNUMBER)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef UINT   (CALLBACK * GETSYSTOOLHOLDERNUMBER)(DWORD dwControl,DWORD dwCoord);
typedef void   (CALLBACK * SETSYSTOOLHOLDERNUMBER)(DWORD dwControl,DWORD dwCoord,UINT holder);
typedef UINT   (CALLBACK * GETTOOLINSPINDLE)(DWORD dwControl,DWORD dwCoord);
typedef void   (CALLBACK * SETTOOLINSPINDLE)(DWORD dwControl,DWORD dwCoord,UINT tool);
typedef double (CALLBACK * GETTOOLBLOCKHEIGHT)(DWORD dwControl);
typedef void   (CALLBACK * SETTOOLBLOCKHEIGHT)(DWORD dwControl,double newValue);

// ncerror.h
typedef BOOL  (CALLBACK * UPDATEERRORS)(DWORD dwControl);
typedef void  (CALLBACK * CLEARERRORS)(DWORD dwControl);
typedef ERRORMODE (CALLBACK * GETERRORLEVEL)(DWORD dwControl);
typedef UINT  (CALLBACK * GETNUMOFERRORS)(DWORD dwControl);
typedef LPSTR (CALLBACK * GETERRORHEADER)(DWORD dwControl,UINT num,LPSTR str,UINT maxchar);
typedef LPSTR (CALLBACK * GETERRORSTRING)(DWORD dwControl,UINT num,LPSTR str,UINT maxchar);
typedef BOOL  (CALLBACK * GETERRORRECORD)(DWORD dwControl,UINT num,PNCERR_RECORD pRec);
typedef void  (CALLBACK * ADDERRRECORD)(DWORD dwControl,UINT errnum,ERRORMODE em,ERRORTYPE et,long line,TCHAR ax);
typedef void  (CALLBACK * ADDERRRECORDEX)(DWORD dwControl,UINT errnum,ERRORMODE em,ERRORTYPE et,long line,TCHAR ax,char *msg);
typedef void  (CALLBACK * DELETEERRRECORD)(DWORD dwControl,UINT num);
typedef void  (CALLBACK * CLEARERRLOGFILE)(DWORD dwControl);
typedef BOOL  (CALLBACK * SETERRLOGFILEPATH)(DWORD dwControl,LPSTR str,BOOL delOld);
typedef LPSTR (CALLBACK * GETERRLOGFILEPATH)(DWORD dwControl,LPSTR str,UINT maxchar);
typedef BOOL  (CALLBACK * GETERRORLOGGING)(DWORD dwControl);
typedef void  (CALLBACK * SETERRORLOGGING)(DWORD dwControl,BOOL status);

// Registry
typedef HKEY (CALLBACK * DRVOPENNCKEY)(DWORD control,LPCTSTR Section);
typedef LONG (CALLBACK * DRVSETNCDWORD)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,DWORD Value);
typedef LONG (CALLBACK * DRVQUERYNCDWORD)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,PDWORD pValue,
                DWORD defValue);
typedef LONG (CALLBACK * DRVSETNCDOUBLE)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,double Value);
typedef LONG (CALLBACK * DRVQUERYNCDOUBLE)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,double *pValue,
                double defValue);
typedef LONG (CALLBACK * DRVSETNCSTRING)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,LPTSTR Value);
typedef LONG (CALLBACK * DRVQUERYNCSTRING)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,LPTSTR pValue,
                DWORD ValueLength,LPTSTR defValue);
typedef LONG (CALLBACK * DRVSETNCBOOL)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,BOOL Value);
typedef LONG (CALLBACK * DRVQUERYNCBOOL)(DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,PBOOL pValue,
                BOOL defValue);

typedef void (CALLBACK * NC_AUDIT)(char *str);
typedef void (CALLBACK * NC_AUDITOPEN)();
typedef void (CALLBACK * NC_AUDITCLOSE)();

typedef void (CALLBACK * NC_GETNCDLLVERSIONSTR)(char *str);

typedef BOOL (CALLBACK * PPGETDOUBLE)(char *region,UINT indx,double *result);
typedef BOOL (CALLBACK * PPSETDOUBLE)(char *region,UINT indx,double value);

typedef DWORD (CALLBACK * NCOFFSETSUPDATE)(DWORD dwControl);
typedef DWORD (CALLBACK * NCOFFSETSUPDATECLEAR)(DWORD dwControl,DWORD clearMask);
  #endif // NC

///////////////////////////////////////////////////////////////////////////
// Functions


#ifdef NO_EXTERN
#define EXTRN
#else
#define EXTRN extern
#endif

  #ifdef __cplusplus
extern "C" {
  #endif

HINSTANCE OpenRuntimeLink();
void      CloseRuntimeLink();

// Comm functions
EXTRN READREADY DeviceReadReady;
EXTRN FLUSH DeviceFlush;
EXTRN OPENPMACDEVICE DeviceOpen;
EXTRN SELECTPMACDEVICE DeviceSelect;
EXTRN NUMBEROFDEVICES DeviceNumberOfDevices;
EXTRN CLOSEPMACDEVICE DeviceClose;
EXTRN PMACSETLANGUAGE DeviceSetLanguage;
EXTRN PMACLMH DeviceLMH;
EXTRN SETLANGUAGEMODULE DeviceSetLanguageModule;
EXTRN CONFIGURE DeviceConfigure;
EXTRN GETPMACTYPE DeviceGetType;
EXTRN SENDLINEA DeviceSendLine;
EXTRN GETLINEA DeviceGetLine;
EXTRN WAITGETLINEA DeviceWaitGetLine;
EXTRN SENDCHARA DeviceSendChar;
EXTRN GETRESPONSEA DeviceGetResponse;
EXTRN GETCONTROLRESPONSEA DeviceGetControlResponse;
EXTRN GETASCIICOMM DeviceGetAsciiComm;
EXTRN SETASCIICOMM DeviceSetAsciiComm;
EXTRN GETERROR DeviceGetError;
EXTRN DOWNLOADA DeviceDownload;
EXTRN INTRTERMINATE DeviceINTRTerminate;
EXTRN INTRWNDMSGINIT  DeviceINTRWndMsgInit;
EXTRN INTRFUNCCALLINIT DeviceINTRFuncCallInit;
EXTRN LOCKPMAC   DeviceLock;
EXTRN RELEASEPMAC DeviceRelease;
EXTRN GETVARIABLESTRA DeviceGetVariableStr;
EXTRN GETVARIABLELONG DeviceGetVariableLong;
EXTRN GETVARIABLEDOUBLE DeviceGetVariableDouble;
EXTRN GETIVARIABLELONG DeviceGetIVariableLong;
EXTRN SETIVARIABLELONG DeviceSetIVariableLong;
EXTRN GETIVARIABLEDOUBLE DeviceGetIVariableDouble;
EXTRN SETIVARIABLEDOUBLE DeviceSetIVariableDouble;
EXTRN GETUSERHANDLE DeviceGetUserHandle;
EXTRN SZLOADSTRINGA DeviceLoadString;
EXTRN INBOOTSTRAP DeviceInBootStrapMode;
EXTRN GETBUFFERA  DeviceGetBuffer;
EXTRN PMACCONFIGURE DevicePmacConfigure;
EXTRN TESTDPRAM DeviceTestDPRAM;
EXTRN GETPMACTYPE DeviceGetPmacType;
EXTRN TESTDPRABORT DeviceTestDPRAMAbort;
// Binary Rotary Buffer
EXTRN DPRROTBUFINIT	DeviceDPRRotBufInit;
EXTRN DPRROTBUF	DeviceDPRRotBuf;
EXTRN DPRBUFLAST	DeviceDPRBufLast;
EXTRN DPRROTBUFREMOVE DeviceDPRRotBufRemove;
EXTRN DPRROTBUFCHANGE DeviceDPRRotBufChange;
EXTRN DPRASCIISTRTOROTA	DeviceDPRAsciiStrToRot;
EXTRN DPRREALTIME DeviceDPRRealTime;
EXTRN DPRSETHOSTBUSYBIT DeviceDPRSetHostBusyBit;
EXTRN DPRGETHOSTBUSYBIT DeviceDPRGetHostBusyBit;
EXTRN DPRGETPMACBUSYBIT DeviceDPRGetPMACBusyBit;
EXTRN DPRGETSERVOTIMER DeviceDPRGetServoTimer;
EXTRN DPRSETMOTORS DeviceDPRSetMotors;
EXTRN DPRGETCOMMANDEDPOS DeviceDPRGetCommandedPos;
EXTRN DPRPOSITION DeviceDPRPosition;
EXTRN DPRFOLLOWERROR DeviceDPRFollowError;
EXTRN DPRGETVEL DeviceDPRGetVel;
EXTRN DPRGETMASTERPOS DeviceDPRGetMasterPos;
EXTRN DPRGETCOMPENSATIONPOS DeviceDPRGetCompensationPos;
EXTRN DPRGETPREVDAC DeviceDPRGetPrevDAC;
EXTRN DPRGETMOVETIME DeviceDPRGetMoveTime;
EXTRN DPRAVAILABLE DeviceDPRAvailable;
// Turbo Specific
EXTRN DPRRESETDATAREADYBIT DeviceDPRResetDataReadyBit;
EXTRN DPRGETDATAREADYBIT DeviceDPRGetDataReadyBit;
EXTRN DPRDOREALTIMEHANDSHAKE DeviceDPRDoRealTimeHandshake;
//EXTRN DPRREALTIMETURBO DeviceDPRRealTimeTurbo;
//EXTRN DPRREALTIMESETMOTORMASK DeviceDPRRealTimeSetMotorMask;
EXTRN DPRREALTIMESETMOTOR DeviceDPRRealTimeSetMotor;
EXTRN DPRREALTIMEEX  DeviceDPRRealTimeEx;
EXTRN DPRBACKGROUNDEX DeviceDPRBackgroundEx;
EXTRN DPRBACKGROUNDVAR DeviceDPRBackgroundVar;
EXTRN DPRMOTORSERVOSTATUSTURBO DeviceDPRMotorServoStatusTurbo;
EXTRN DPRGETTARGETPOS DeviceDPRGetTargetPos;
EXTRN DPRGETBIASPOS DeviceDPRGetBiasPos;
EXTRN DPRPE DeviceDPRPe;
EXTRN DPRTIMEREMINMOVE DeviceDPRTimeRemainingInMove;
EXTRN DPRTIMEREMINTATS DeviceTimeRemInTATS;
EXTRN DPRPROGREMAINING DeviceDPRProgRemaining;
EXTRN DPRCOMMANDED DeviceDPRCommanded;
// background buffer commands
EXTRN DPRVARBUFINIT DeviceDPRVarBufInit;
EXTRN DPRVARBUFINITEX DeviceDPRVarBufInitEx;
EXTRN DPRVARBUFREMOVE DeviceDPRVarBufRemove;
EXTRN DPRVARBUFCHANGE DeviceDPRVarBufChange;
EXTRN DPRBACKGROUND   DeviceDPRBackground;
EXTRN DPRWRITEBUFFER  DeviceDPRWriteBuffer;
EXTRN DPRGETVBGSERVOTIMER DeviceDPRGetVBGServoTimer;
EXTRN DPRVELOCITY DeviceDPRVelocity;
EXTRN DPRVARBUFREAD DeviceDPRVarBufRead;
EXTRN PPDPRVARBUFREAD DeviceppDPRVarBufRead;
//EXTRN GETPLCSTATUS DeviceGetPlcStatus;
EXTRN GETROMDATEA DeviceGetRomDate;
EXTRN GETROMVERSIONA DeviceGetRomVersion;
EXTRN GETERRORSTRA DeviceGetErrorStr;
EXTRN MULTIDOWNLOADA DeviceMultiDownload;
EXTRN ADDDOWNLOADFILEA DeviceAddDownloadFile;
EXTRN REMOVEDOWNLOADFILEA DeviceRemoveDownloadFile;
EXTRN RENUMBERFILESA DeviceRenumberFiles;
EXTRN DOWNLOADFIRMWAREFILE DeviceLoadFirmwareFile;
EXTRN SERGETPORT DeviceSERGetPort;
EXTRN SERSETPORT DeviceSERSetPort;
EXTRN SERGETBAUDRATE DeviceSERGetBaudrate;
EXTRN SERSETBAUDRATE DeviceSERSetBaudrate;
EXTRN GETDPRAMAVAILABLE DeviceGetDpramAvailable;
EXTRN DPRGETMOTORMOTION DeviceDPRGetMotorMotion;
EXTRN DPRGETPROGRAMMODE DeviceDPRGetProgramMode;
EXTRN DPRSYSINPOSITION DeviceDPRSysInposition;
EXTRN DPRROTBUFOPEN DeviceDPRRotBufOpen;
EXTRN DPRGETFEEDRATEMODE DeviceDPRGetFeedRateMode;
EXTRN WHYMOTORNOTMOVING DeviceWhyMotorNotMoving;
EXTRN WHYMOTORNOTMOVINGSTRING DeviceWhyMotorNotMovingString;
EXTRN WHYCSNOTMOVINGSTRING DeviceWhyCsNotMovingString;
EXTRN WHYCSNOTMOVING  DeviceWhyCsNotMoving;
EXTRN WHYMOTORNOTMOVINGTURBO DeviceWhyMotorNotMovingTURBO;
EXTRN WHYMOTORNOTMOVINGSTRINGTURBO DeviceWhyMotorNotMovingStringTURBO;
EXTRN WHYCSNOTMOVINGSTRINGTURBO DeviceWhyCsNotMovingStringTURBO;
EXTRN WHYCSNOTMOVINGTURBO  DeviceWhyCsNotMovingTURBO;

EXTRN GETBITVALUE DeviceGetBitValue;
EXTRN HEXLONG2 DeviceHexLong2;
// Numeric read/write functions
// Standard
EXTRN DPRGETWORD DeviceDPRGetWord;
EXTRN DPRSETWORD DeviceDPRSetWord;
EXTRN DPRGETDWORD DeviceDPRGetDWord;
EXTRN DPRSETDWORD DeviceDPRSetDWord;
EXTRN DPRGETFLOAT DeviceDPRGetFloat;
EXTRN DPRSETFLOAT DeviceDPRSetFloat;
// Masking
EXTRN DPRDWORDBITSET DeviceDPRDWordBitSet;
EXTRN DPRSETDWORDBIT DeviceDPRSetDWordBit;
EXTRN DPRRESETDWORDBIT DeviceDPRResetDWordBit;
EXTRN DPRSETDWORDMASK DeviceDPRSetDWordMask;
EXTRN DPRGETDWORDMASK DeviceDPRGetDWordMask;
EXTRN DPRFLOAT DeviceDPRFloat;
EXTRN DPRLFIXED DeviceDPRLFixed;
// Control Panel
EXTRN DPRCONTROLPANEL DeviceDPRControlPanel;
EXTRN DPRSETJOGPOSBIT DeviceDPRSetJogPosBit;
EXTRN DPRGETJOGPOSBIT DeviceDPRGetJogPosBit;
EXTRN DPRSETJOGNEGBIT DeviceDPRSetJogNegBit;
EXTRN DPRGETJOGNEGBIT DeviceDPRGetJogNegBit;
EXTRN DPRSETJOGRETURNBIT DeviceDPRSetJogReturnBit;
EXTRN DPRGETJOGRETURNBIT DeviceDPRGetJogReturnBit;
EXTRN DPRSETRUNBIT DeviceDPRSetRunBit;
EXTRN DPRGETRUNBIT DeviceDPRGetRunBit;
EXTRN DPRSETSTOPBIT DeviceDPRSetStopBit;
EXTRN DPRGETSTOPBIT DeviceDPRGetStopBit;
EXTRN DPRSETHOMEBIT DeviceDPRSetHomeBit;
EXTRN DPRGETHOMEBIT DeviceDPRGetHomeBit;
EXTRN DPRSETHOLDBIT DeviceDPRSetHoldBit;
EXTRN DPRGETHOLDBIT DeviceDPRGetHoldBit;
EXTRN DPRGETSTEPBIT DeviceDPRGetStepBit;
EXTRN DPRSETSTEPBIT DeviceDPRSetStepBit;
EXTRN DPRGETREQUESTBIT DeviceDPRGetRequestBit;
EXTRN DPRSETREQUESTBIT DeviceDPRSetRequestBit;
EXTRN DPRGETFOENABLEBIT DeviceDPRGetFOEnableBit;
EXTRN DPRSETFOENABLEBIT DeviceDPRSetFOEnableBit;
EXTRN DPRSETFOVALUE DeviceDPRSetFOValue;
EXTRN DPRGETFOVALUE DeviceDPRGetFOValue;
// Data Gathering
EXTRN GETGATHERSAMPLES DeviceGetGatherSamples;
EXTRN GETGATHERPERIOD DeviceGetGatherPeriod;
EXTRN GETGATHERSAMPLETIME DeviceGetGatherSampleTime;
EXTRN SETGATHERSAMPLETIME DeviceSetGatherSampleTime;
EXTRN GETNUMGATHERSOURCES DeviceGetNumGatherSources;
EXTRN GETNUMGATHERSAMPLES DeviceGetNumGatherSamples;
EXTRN SETGATHERPERIOD DeviceSetGatherPeriod;
EXTRN SETGATHERENABLE DeviceSetGatherEnable;
EXTRN GETGATHERENABLE DeviceGetGatherEnable;
EXTRN SETGATHER DeviceSetGather;
EXTRN SETQUICKGATHER DeviceSetQuickGather;
EXTRN SETQUICKGATHEREX DeviceSetQuickGatherEx;
EXTRN GETGATHER DeviceGetGather;
EXTRN CLEARGATHER DeviceClearGather;
EXTRN INITGATHER DeviceInitGather;
EXTRN CLEARGATHERDATA DeviceClearGatherData;
EXTRN COLLECTGATHERDATA DeviceCollectGatherData;
EXTRN GETGATHERPOINT DeviceGetGatherPoint;
EXTRN STARTGATHER DeviceStartGather;
EXTRN STOPGATHER DeviceStopGather;
// Real time
EXTRN INITRTGATHER DeviceInitRTGather;
EXTRN CLEARRTGATHER DeviceClearRTGather;
EXTRN ADDRTGATHER DeviceAddRTGather;
EXTRN COLLECTRTGATHERDATA DeviceCollectRTGatherData;
EXTRN MACROGETIVARIABLELONG DeviceMACROGetIVariableLong;
EXTRN MACROUPLOADCONFIG DeviceMACROUploadConfig;

#ifdef _NC
// NC functions
EXTRN SETORGIN NcSetOrgin;                           // POSDLG.CPP
EXTRN ZEROSHIFT NcZeroShift;                         // POSDLG.CPP
EXTRN CREATECNCSYSTEM NcCreateCncSystem;             // NCUI.CPP
EXTRN DELETECNCSYSTEM NcDeleteCncSystem;             // NCUI.CPP
EXTRN RUNCNCSYSTEM NcRun;
EXTRN STOPCNCSYSTEM NcStop;
EXTRN DOCOMMAND NcDoCommand;                         // NCUI.CPP
EXTRN OPENTEXTFILE NcOpenTextFile;                   // NCUI.CPP
EXTRN CLOSETEXTFILE NcCloseTextFile;
EXTRN DRAWMOTORCOORD NcDrawMotorCoord;               // OFSDISP.CPP
EXTRN DRAWMOTORMEASURE NcDrawMotorMeasure;           // OFSDISP.CPP
EXTRN SETMOTORCOORD NcSetMotorCoord;                 // OFSDLG.CPP
EXTRN SETCOORD NcSetCoord;                           // OFSDLG.CPP
EXTRN WRITECOORDSYSPROFILE NcWriteCoordSysProfile;   // OFSDLG.CPP
EXTRN REWINDTEXTBUFFER NcRewindTextBuffer;           // OFSDLG.CPP
EXTRN UPDATEMOTOR NcUpdateMotor;                     // OFSDLG.CPP
EXTRN UPDATEALLMOTORS NcUpdateAllMotors;
EXTRN INPUTCONVERSION NcInputConversion;             // OFSDLG.CPP
EXTRN SETRAPIDOVERRIDE NcSetRapidOverride;           // OPERDLG.CPP
EXTRN SETFEEDOVERRIDE NcSetFeedOverride;             // OPERDLG.CPP
EXTRN DRAWMOTOR NcDrawMotor;                         // POSDISP.CPP
EXTRN DISPLAYTEXTBUFFERRECT NcDisplayTextBufferRect; // TEXTDISP.CPP
EXTRN GETVECTORVELOCITY NcGetVectorVelocity;         // FEEDDISP.CPP
EXTRN READMDIBUFFER NcReadMdiBuffer;                 // MDIDLG.CPP
EXTRN CLEARTEXTBUFFER NcClearTextBuffer;             // MDIDLG.CPP
EXTRN LOADMDIBUFFER NcLoadMdiBuffer;                 // MDIDLG.CPP
EXTRN READERRORPROFILE NcReadErrorProfile;           // ERRDISP.CPP
EXTRN GETCOORDSYSTEM NcGetCoordSystem;               //
EXTRN GETMETRICUNITS NcGetMetricUnits;
EXTRN SETMETRICUNITS NcSetMetricUnits;
EXTRN GETMODE NcGetMode;
EXTRN GETTITLE NcGetTitle;
EXTRN SETTITLE NcSetTitle;
EXTRN GETAXISENABLED NcGetAxisEnabled;
EXTRN GETNUMCOORDSYSTEMS NcGetNumCoordSystems;
EXTRN GETMACHINELOCK NcGetMachineLock;
EXTRN SETMACHINELOCK NcSetMachineLock;
EXTRN GETMACHINETYPE NcGetMachineType;
EXTRN GETPROGRAMNAME NcGetProgramName;
EXTRN GETPROGRAMPATH NcGetProgramPath;
EXTRN GETPROGRAMLOADED NcGetProgramLoaded;
EXTRN GETSEMAPHORE NcGetSemaphore;
EXTRN GETPROGRAMSTATUS NcGetProgramStatus;
EXTRN GETPROGRAMNUMBER NcGetProgramNumber;
EXTRN GETCURRENTLABEL NcGetCurrentLabel;
EXTRN GETJOGSELECT NcGetJogSelect;
EXTRN SETJOGSELECT NcSetJogSelect;
EXTRN GETSPEEDSELECT NcGetSpeedSelect;
EXTRN SETSPEEDSELECT NcSetSpeedSelect;
EXTRN GETDISTANCESELECT NcGetDistanceSelect;
EXTRN SETDISTANCESELECT NcSetDistanceSelect;
EXTRN GETJOGSTEP NcGetJogStep;
EXTRN GETHANDLESTEP NcGetHandleStep;
EXTRN GETAXISPOINTER NcGetAxisPointer;
EXTRN GETSELECTEDAXISPOINTER NcGetSelectedAxisPointer;
EXTRN GETSINGLEBLOCK NcGetSingleBlock;
EXTRN SETSINGLEBLOCK NcSetSingleBlock;
EXTRN GETBLOCKDELETE NcGetBlockDelete;
EXTRN SETBLOCKDELETE NcSetBlockDelete;
EXTRN GETOPTIONALSTOP NcGetOptionalStop;
EXTRN SETOPTIONALSTOP NcSetOptionalStop;
EXTRN GETSELECTEDAXISCHAR NcGetSelectedAxisChar;
EXTRN GETCURRENTGVALUE NcGetCurrentGValue;
EXTRN GETCURRENTERRORLEVEL NcGetCurrentErrorLevel;
EXTRN GETAXISSELECT NcGetAxisSelect;
EXTRN SETAXISSELECT NcSetAxisSelect;
EXTRN GETINPOSITION NcGetInposition;
EXTRN GETBUFFERMODE NcGetBufferMode;
EXTRN GETSELECTEDBUFFERMODE NcGetSelectedBufferMode;
EXTRN SETBUFFERMODE NcSetBufferMode;
EXTRN GETPROGRAMMODE NcGetProgramMode;
EXTRN GETSELECTEDAXISMOTIONMODE NcGetSelectedAxisMotionMode;
EXTRN GETPROGRAMMOTIONMODE NcGetProgramMotionMode;
EXTRN GETBUFFEROPEN NcGetBufferOpen;
EXTRN GETBUFFERREMAINING NcGetBufferRemaining;
EXTRN SETSPINDLESELECT NcSetSpindleSelect;
EXTRN GETSPINDLESELECT NcGetSpindleSelect;
EXTRN GETSPINDLERPM NcGetSpindleRPM;
EXTRN SETSPINDLERPM NcSetSpindleRPM;
EXTRN GETSPINDLECSS NcGetSpindleCSS;
EXTRN GETSPINDLEACTRPM NcGetSpindleActRPM;
EXTRN GETSPINDLEMAXRPM NcGetSpindleMaxRPM;
EXTRN SETSPINDLEMAXRPM NcSetSpindleMaxRPM;
EXTRN GETSPINDLECSSMODE NcGetSpindleCSSMode;
EXTRN SETSPINDLECSSMODE NcSetSpindleCSSMode;
EXTRN SETSPINDLEOVERRIDE NcSetSpindleOverride;
EXTRN GETSPINDLEOVERRIDE NcGetSpindleOverride;
EXTRN SETSPINDLEOVRSELECT NcSetSpindleOvrSelect;
EXTRN GETSPINDLEOVRSELECT NcGetSpindleOvrSelect;
EXTRN GETFEEDOVERRIDE NcGetFeedOverride;
EXTRN GETFEEDOVRSELECT NcGetFeedOvrSelect;
EXTRN SETFEEDOVRSELECT NcSetFeedOvrSelect;
EXTRN GETRAPIDOVERRIDE NcGetRapidOverride;
EXTRN GETRAPIDOVRSELECT NcGetRapidOvrSelect;
EXTRN SETRAPIDOVRSELECT NcSetRapidOvrSelect;
EXTRN GETCOOLANTSELECT NcGetCoolantSelect;
EXTRN GETCOOLANTSTATUS NcGetCoolantStatus;
EXTRN SETCOOLANTSELECT NcSetCoolantSelect;
EXTRN GETTIMEBASEMODE NcGetTimebaseMode;
EXTRN SETTIMEBASEMODE NcSetTimebaseMode;
EXTRN GETFEEDRATE NcGetFeedrate;
EXTRN SETFEEDRATE NcSetFeedrate;
EXTRN GETDRYRUN NcGetDryRun;
EXTRN SETDRYRUN NcSetDryRun;
EXTRN GETTHREADLEAD NcGetThreadLead;
EXTRN SETTHREADLEAD NcSetThreadLead;
EXTRN GETNUMOFTOOLS NcGetNumOfTools;
EXTRN GETSYSTOOLNUMBER NcGetSysToolNumber;
EXTRN SETSYSTOOLNUMBER NcSetSysToolNumber;
EXTRN GETNEXTTOOLNUMBER NcGetNextToolNumber;
EXTRN SETNEXTTOOLNUMBER NcSetNextToolNumber;
EXTRN GETTOOLHOLDERNUMBER NcGetToolHolderNumber;
EXTRN SETTOOLHOLDERNUMBER NcSetToolHolderNumber;
EXTRN GETTYPETOOLOFFSET NcGetTypeToolOffset;
EXTRN SETTYPETOOLOFFSET NcSetTypeToolOffset;
EXTRN GETTOOLINSPINDLE NcGetToolInSpindle;
EXTRN SETTOOLINSPINDLE NcSetToolInSpindle;
EXTRN GETTOOLDIRECTION NcGetToolDirection;
EXTRN SETTOOLDIRECTION NcSetToolDirection;
EXTRN AUTOSETTOOLOFFSET NcAutoSetToolOffset;
EXTRN DRAWPOSITIONS NcDrawPositions;
EXTRN DRAWPOSITIONSRECT NcDrawPositionsRect;
EXTRN GETNUMDISPLAYAXIS NcGetNumDisplayAxis;
EXTRN GETNUMDISPLAYAXISTOTAL NcGetNumDisplayAxisTotal;
EXTRN GETNUMAXISTOTAL NcGetNumAxisTotal;
EXTRN GETOFFSETVALUE NcGetOffsetValue;
EXTRN AUTOSETOFFSET  NcAutoSetWorkOffset;
EXTRN SETOFFSETVALUE NcSetOffsetValue;
EXTRN GETOFFSETSTRING NcGetOffsetString;
EXTRN GETTOOLBLOCKHEIGHT NcGetToolBlockHeight;
EXTRN SETTOOLBLOCKHEIGHT NcSetToolBlockHeight;
EXTRN GETPOSITIONBIAS NcGetPositionBias;
EXTRN GETTOOLTIPANGLE NcGetToolTipAngle;
EXTRN SETTOOLTIPANGLE NcSetToolTipAngle;
EXTRN GETTOOLCLEARANCEANGLE NcGetToolClearanceAngle;
EXTRN SETTOOLCLEARANCEANGLE NcSetToolClearanceAngle;
EXTRN GETTOOLCOMP NcGetToolComp;
EXTRN SETTOOLCOMP NcSetToolComp;
EXTRN GETTOOLCOMPDIA NcGetToolCompDia;
EXTRN SETTOOLCOMPDIA NcSetToolCompDia;
EXTRN GETTOOLRADIUS NcGetToolRadius;
EXTRN SETTOOLRADIUS NcSetToolRadius;
EXTRN GETTOOLMETRICUNITS NcGetToolMetricUnits;
EXTRN SETTOOLMETRICUNITS NcSetToolMetricUnits;
EXTRN GETTOOLGEOMETRYOFFSET NcGetToolGeometryOffset;
EXTRN SETTOOLGEOMETRYOFFSET NcSetToolGeometryOffset;
EXTRN GETTOOLWEAROFFSET NcGetToolWearOffset;
EXTRN SETTOOLWEAROFFSET NcSetToolWearOffset;
EXTRN GETTOOLGUAGEOFFSET NcGetToolGuageOffset;
EXTRN SETTOOLGUAGEOFFSET NcSetToolGuageOffset;
EXTRN GETTOOLTYPE NcGetToolType;
EXTRN SETTOOLTYPE NcSetToolType;
EXTRN GETTOOLMATERIAL NcGetToolMaterial;
EXTRN SETTOOLMATERIAL NcSetToolMaterial;
EXTRN GETTOOLHAND NcGetToolHand;
EXTRN SETTOOLHAND NcSetToolHand;
EXTRN GETNUMBEROFCONTROLS NcGetNumberOfControls;
EXTRN METRICCONVERSION NcMetricConversion;
EXTRN GETPARTSTOTAL NcGetPartsTotal;
EXTRN SETPARTSTOTAL NcSetPartsTotal;
EXTRN GETPARTSREQUIRED NcGetPartsRequired;
EXTRN SETPARTSREQUIRED NcSetPartsRequired;
EXTRN GETPARTSCOUNT NcGetPartsCount;
EXTRN SETPARTSCOUNT NcSetPartsCount;
EXTRN GETACTIVEGCODE NcGetActiveGCode;
EXTRN GETACTIVEGCODESTR NcGetActiveGCodeStr;
EXTRN GETTOOLOFFSET NcGetToolOffset;
EXTRN GETCOMPOFFSET NcGetCompOffset;
EXTRN GETOPERATINGTIME NcGetOperatingTime;
EXTRN GETCYCLETIME NcGetCycleTime;
EXTRN GETRUNNINGTIME NcGetRunningTime;
EXTRN GETCYCLECUTTINGTIME NcGetCycleCuttingTime;
EXTRN GETTOTALCUTTINGTIME NcGetTotalCuttingTime;
EXTRN GETSPINDLECTSREV NcGetSpindleCtsRev;
EXTRN SETSPINDLECTSREV NcSetSpindleCtsRev;
EXTRN GETSPINDLECSSUNITS NcGetSpindleCssUnits;
EXTRN SETSPINDLECSSUNITS NcSetSpindleCssUnits;
EXTRN SETSPINDLECSS NcSetSpindleCSS;
EXTRN GETSPINDLEGEARRATIO NcGetSpindleGearRatio;
EXTRN SETSPINDLEGEARRATIO NcSetSpindleGearRatio;
EXTRN GETSPINDLECMDRPM NcGetSpindleCmdRPM;
EXTRN GETSPINDLEDETECT NcGetSpindleDetect;
EXTRN SETSPINDLEDETECT NcSetSpindleDetect;
EXTRN GETSPINDLEATZERO NcGetSpindleAtZero;
EXTRN SETSPINDLEATZERO NcSetSpindleAtZero;
EXTRN GETSPINDLEATSPEED NcGetSpindleAtSpeed;
EXTRN SETSPINDLEATSPEED NcSetSpindleAtSpeed;
EXTRN GETSPINDLEFPR NcGetSpindleFPR;
EXTRN SETSPINDLEFPR NcSetSpindleFPR;
EXTRN GETINPUTDWORD NcGetInputDword;
EXTRN GETOUTPUTDWORD NcGetOutputDword;
EXTRN GETCOMMANDDWORD NcGetCommandDword;
EXTRN GETSTATUSDWORD NcGetStatusDword;
EXTRN GETCHANGEDWORD NcGetChangeDword;
EXTRN GETHOMEREFERENCE NcGetHomeReference;
EXTRN SETHOMEREFERENCE NcSetHomeReference;
EXTRN GETHOMEINIT NcGetHomeInit;
EXTRN SETHOMEINIT NcSetHomeInit;
EXTRN GETHOMEMOTORMASK NcGetHomeMotorMask;
EXTRN SETHOMEMOTORMASK NcSetHomeMotorMask;
EXTRN GETHOMEINPROGRESS NcGetHomeInProgress;
EXTRN UPDATEERRORS NcUpdateErrors;
EXTRN CLEARERRORS NcClearErrors;
EXTRN GETERRORLEVEL NcGetErrorLevel;
EXTRN GETNUMOFERRORS NcGetNumOfErrors;
EXTRN GETERRORHEADER NcGetErrorHeader;
EXTRN GETERRORSTRING NcGetErrorString;
EXTRN GETERRORRECORD NcGetErrorRecord;
EXTRN ADDERRRECORD NcAddErrorRecord;
EXTRN ADDERRRECORDEX NcAddErrorRecordEx;
EXTRN DELETEERRRECORD NcDeleteErrorRecord;
EXTRN CLEARERRLOGFILE NcClearErrLogFile;
EXTRN SETERRLOGFILEPATH NcSetErrLogFilePath;
EXTRN GETERRLOGFILEPATH NcGetErrLogFilePath;
EXTRN GETERRORLOGGING NcGetErrorLogging;
EXTRN SETERRORLOGGING NcSetErrorLogging;
EXTRN GETAXISFORMATSTR NcGetAxisFormatStr;
EXTRN GETAXISFORMAT NcGetAxisFormat;
EXTRN SETAXISFORMAT NcSetAxisFormat;
EXTRN GETAXISPOSITION NcGetAxisPosition;
EXTRN DRVOPENNCKEY NcOpenKey;
EXTRN DRVSETNCDWORD NcSetDword;
EXTRN DRVQUERYNCDWORD NcGetDword;
EXTRN DRVSETNCDOUBLE NcSetDouble;
EXTRN DRVQUERYNCDOUBLE NcGetDouble;
EXTRN DRVSETNCSTRING NcSetString;
EXTRN DRVQUERYNCSTRING NcGetString;
EXTRN DRVSETNCBOOL NcSetBool;
EXTRN DRVQUERYNCBOOL NcGetBool;
EXTRN SETDNCMODE NcSetDncMode;
EXTRN GETDNCMODE NcGetDncMode;
EXTRN GETDNCCONFIG NcGetDncConfig;
EXTRN SETDNCCONFIG NcSetDncConfig;
EXTRN SZLOADNCSTRING NcLoadString;
EXTRN NC_AUDIT ncaudit;
EXTRN NC_AUDITOPEN ncauditopen;
EXTRN NC_AUDITCLOSE ncauditclose;
EXTRN NCOFFSETSUPDATE NcOffsetsUpdate;
EXTRN NCOFFSETSUPDATECLEAR NcOffsetsUpdateClear;
EXTRN NC_GETNCDLLVERSIONSTR ncGetNcdllVersionStr;
EXTRN PPGETDOUBLE ncPpGetDouble;
EXTRN PPSETDOUBLE ncPpSetDouble;

#endif

#ifdef __cplusplus

}

#endif

#endif
