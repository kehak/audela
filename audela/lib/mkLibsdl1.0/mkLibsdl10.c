/*
 * mkLibsdl 1.0
 * ------------
 *
 * Please see the web pages for releases and documentation.
 *
 * Author: Michael Kraus
 *         mailto:mmg_kraus@onlinehome.de
 *         http://mkextensions.sourceforge.net
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted.
 * The author makes no representations about the suitability of this
 * software for any purpose.  It is provided "as is" without express
 * or implied warranty.  By use of this software the user agrees to
 * indemnify and hold harmless the author from any claims or
 * liability for loss arising out of such use.
 *
 */

/* required to build a dll using stubs. should be a compiler option */
/* #define USE_TCL_STUBS */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <tcl.h>
#include <SDL.h>

#ifndef TRUE
#  define TRUE  1
#  define FALSE 0
#endif

/* copied from sun's example.c */
#ifdef USE_TCL_STUBS
#ifdef __WIN32__
#if defined(__WIN32__)
#   define WIN32_LEAN_AND_MEAN
#   include <windows.h>
#   undef WIN32_LEAN_AND_MEAN
#   if defined(_MSC_VER)
#       define EXPORT(a,b) __declspec(dllexport) a b
#       define DllEntryPoint DllMain
#   else
#       if defined(__BORLANDC__)
#           define EXPORT(a,b) a _export b
#       else
#           define EXPORT(a,b) a b
#       endif
#   endif
#else
#   define EXPORT(a,b) a b
#endif

EXTERN EXPORT(int,Mklibsdl_Init)     _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN EXPORT(int,Mklibsdl_SafeInit) _ANSI_ARGS_((Tcl_Interp *interp));
BOOL APIENTRY DllEntryPoint(HINSTANCE hInst, DWORD reason, LPVOID reserved)
{
    return TRUE;
}
#endif
#endif

/* mkLibsdl version number */
#define _VERSION           "1.0"

/* some acronyms for popular Tcl_xxx functions */
#define _NSO(pcText)       Tcl_NewStringObj( pcText, -1 )
#define _SSO(pO,pcText)    Tcl_SetStringObj( pO, pcText, -1 )
#define _GSO(pO)           Tcl_GetStringFromObj( pO, NULL )
#define _SOL(pO,iLen)      Tcl_SetObjLength( pO, iLen )

#define _NIO(iVal)         Tcl_NewIntObj( iVal )
#define _SIO(pO,iVal)      Tcl_SetIntObj( pO, iVal )
#define _GIO(pO,piVal)     Tcl_GetIntFromObj( pI, pO, piVal )

#define _NBO(bVal)         Tcl_NewBooleanObj( bVal )
#define _SBO(pO,bVal)      Tcl_SetBooleanObj( pO, bVal )
#define _GBO(pO,pbVal)     Tcl_GetBooleanFromObj( pI, pO, pbVal )

#define _NDO(fVal)         Tcl_NewDoubleObj( fVal )
#define _SDO(pO,fVal)      Tcl_SetDoubleObj( pO, fVal )
#define _GDO(pO,pfVal)     Tcl_GetDoubleFromObj( pI, pO, pfVal )

#define _NAO(pcDt,iLen)    Tcl_NewByteArrayObj( pcDt, iLen )
#define _SAO(pO,pcDt,iLen) Tcl_SetByteArrayObj( pO, pcDt, iLen )
#define _GAO(pO,piLen)     Tcl_GetByteArrayFromObj( pO, piLen )
#define _SAL(pO,iLen)      Tcl_SetByteArrayLength( pO, iLen )

#define _LOAL(pO,pNewO)    Tcl_ListObjAppendList( pI, pO, pNewO )
#define _LOAE(pO,pNewO)    Tcl_ListObjAppendElement( pI, pO, pNewO )
#define _LOGL(pO,piLen)    Tcl_ListObjLength( pI, pO, piLen )
#define _LOGI(pO,iI,poE)   Tcl_ListObjIndex( pI, pO, iI, poE )
#define _LOGE(pO,piC,ppV)  Tcl_ListObjGetElements( pI, pO, piC, ppV )
#define _LORE(pO,iPos,poE) Tcl_ListObjReplace( pI, pO, iPos, 1, 1, poE )
#define _LODE(pO,iPos)     Tcl_ListObjReplace( pI, pO, iPos, 1, 0, NULL )

#define _OSV(po1,po2,poV)  Tcl_ObjSetVar2( pI, po1, po2, poV, TCL_LEAVE_ERR_MSG )
#define _OGV(po1,po2)      Tcl_ObjGetVar2( pI, po1, po2, TCL_LEAVE_ERR_MSG )
#define _OUV(po1,po2)      Tcl_UnsetVar2( pI, _GSO(po1), (po2==NULL)?NULL:_GSO(po2), TCL_LEAVE_ERR_MSG )
#define _OSVG(po1,po2,poV) Tcl_ObjSetVar2( pI, po1, po2, poV, TCL_GLOBAL_ONLY )
#define _OGVG(po1,po2)     Tcl_ObjGetVar2( pI, po1, po2, TCL_GLOBAL_ONLY )
#define _OUVG(po1,po2)     Tcl_UnsetVar2( pI, _GSO(po1), (po2==NULL)?NULL:_GSO(po2), TCL_GLOBAL_ONLY )

#define _NOB               Tcl_NewObj()
#define _DOB               Tcl_DuplicateObj
#define _SOB(pO)           Tcl_IsShared( pO )? Tcl_DuplicateObj( pO ):pO
#define _ASO               Tcl_AppendStringsToObj
#define _ATO               Tcl_AppendToObj

#define _DRC               Tcl_DecrRefCount
#define _IRC               Tcl_IncrRefCount

#define _GOR               Tcl_GetObjResult( pI )
#define _SOR(pO)           Tcl_SetObjResult( pI, pO )
#define _ROR               Tcl_ResetResult( pI )

#define _HACE              Tcl_CreateHashEntry
#define _HADE              Tcl_DeleteHashEntry
#define _HASV              Tcl_SetHashValue
#define _HAFE              Tcl_FindHashEntry
#define _HAGV              Tcl_GetHashValue
#define _HAGK              Tcl_GetHashKey

#define _HAFESV(phH,pcK,psD,piN) _HASV( _HACE( phH, pcK, piN ), psD )
#define _HASCAN(phH,peE,psS)     peE = Tcl_FirstHashEntry( phH, psS ); peE != NULL; peE = Tcl_NextHashEntry( psS )

#define _GIFO(pO,pA,pcTxt,piRes) Tcl_GetIndexFromObj( pI, pO, pA, pcTxt, 0, piRes )
#define _WNA(objc,pcText)        ( Tcl_WrongNumArgs( pI, objc, objv, pcText ), TCL_ERROR )

/* my very own exception handling */
#define try( Expr, Excep ) { if( Expr != TCL_OK ) throw Excep; }
#define throw              goto
#define catch

/* data for each joystick */
typedef struct Mkl_Joystick {
  int          iIndex;
  char         *pcName;
  SDL_Joystick *psStick;
  double        fDead;
  double        fMax;
  int           bIsInt;
} Mkl_Joystick;

/* data for each cd drive */
typedef struct Mkl_Cdrom {
  int          iIndex;
  char         *pcName;
  SDL_CD       *psDrive;
} Mkl_Cdrom;

/* event handler struct */
typedef struct Mkl_Event {
  Tcl_Event    sEvent;
  Tcl_Interp   *psInterp;
} Mkl_Event;

/* modul global variables */
static  int          iInUse = 0;
static  Tcl_Obj      *poScript = NULL;
static  Mkl_Joystick psJoysticks[32];          /* don't connect more than 32 */
static  Mkl_Cdrom    psCdroms[32];             /* ... or else ... */

/* static functions */
static int      _MklError( Tcl_Interp *, char *, ... );
static int      _MklGetOptions( Tcl_Interp *, int, Tcl_Obj *CONST[], char *[], Tcl_Obj ** );
static void     _MklOpenJoysticks();
static void     _MklCloseJoysticks();
static int      _MklFindJoystick( Tcl_Interp *, int, Tcl_Obj *CONST[], char *[], Tcl_Obj ** );
static Tcl_Obj* _MklFormatAxis( Mkl_Joystick *, int ); 
static int      _MklFormatEvent( Tcl_Interp *, SDL_Event *, Tcl_Obj * );
static int      _MklHandleEvent( Tcl_Event *, int );
static void     _MklSetupEvent( ClientData, int );
static void     _MklCheckEvent( ClientData, int );

/* exported functions */
int  Mkl_JoystickCmd( ClientData, Tcl_Interp *, int, Tcl_Obj *CONST[] );
int  Mkl_CdromCmd   ( ClientData, Tcl_Interp *, int, Tcl_Obj *CONST[] );

/* required for tck extensions */
int  Mklibsdl_Init( Tcl_Interp * );
int  Mklibsdl_SafeInit( Tcl_Interp * );
void Mklibsdl_Exit( ClientData, Tcl_Interp * );


/* _MklError
   creates a formatted result string and always returns TCL_ERROR.
   like with printf(), at least a format string must be provided.
   in addition, the format string may contain "%O" for Tcl_Obj* types.
*/
static int _MklError( Tcl_Interp *pI, char *pcFormat, ... )
{
  int     i;
  char    **args, *pcRun, pcMsg[2000], pcFmt[2000];
  va_list marker;

  if( pI == NULL || pcFormat == NULL )
    return TCL_ERROR;

  va_start( marker, pcFormat );
  args = (char**)marker;

  strcpy( pcFmt, pcFormat );

  for( i = 0, pcRun = pcFmt; *pcRun; pcRun++ )
  {
    if( *pcRun != '%' ) continue;

    pcRun++;
    if( *pcRun == 'O' )
    {
      *pcRun = 's';
      args[i] = _GSO( (Tcl_Obj*)args[i] );
      i++;
    }
  }

  vsprintf( pcMsg, pcFmt, marker );
  _SSO( _GOR, pcMsg );

  return TCL_ERROR;
}


/* _MklGetOptions (not used at the moment, may be later)
   helper function to analyze option-value pairs in an argument list.
   objv is expected to contain objc/2 option-value pairs. ppcOptions must
   point to a string array with the allowed options. the function will
   return TCL_ERROR if an illegal option was found. if not, the elements in
   ppoValues will either point to NULL (if the option was not found in objv),
   or to the option's value (if found in objv). the indexes in ppoValues
   correspond to those in ppcValues.
*/
static int _MklGetOptions( Tcl_Interp *pI, int objc, Tcl_Obj *CONST objv[], char *ppcOptions[], Tcl_Obj **ppoValues )
{
  int i, iMatch;

  for( i = 0; ppcOptions[i]; i++ )
    ppoValues[i] = NULL;

  for( i = 0; i < objc; i+= 2 )
  {
    try( _GIFO( objv[i], ppcOptions, "option", &iMatch ), eError );
    ppoValues[iMatch] = objv[i+1];
  }

  return TCL_OK;

  catch eError:
    return TCL_ERROR;
}


/* _MklGetJoystick
   extracts the joystick structure, which holds joystick specific data, from
   an (excpected) integer value in poIndex. if it isn't an integer, or if the
   value is out of range, or if the joystick couldn't be opened at start up 
   or after a 'joystick rescan', an error message is returned.
   otherwise, the pointer to the joystick structure is put into ppsJoy.
   note: yes, i use a static pointer array (1.5kB, allright), because a)
   i was too lazy for dynamic allocation and b) nobody, NOBODY, has more
   than a 100 joysticks - there isn't even a boundary check.
*/
static int _MklGetJoystick( Tcl_Interp *pI, Tcl_Obj *poIndex, Mkl_Joystick **ppsJoy, int bCheckOpen )
{
  int iIndex;

  try( _GIO( poIndex, &iIndex ), eError );

  if( iIndex < 0 || iIndex >= SDL_NumJoysticks() )
    throw eBadIndex;

  if( bCheckOpen && ! SDL_JoystickOpened( iIndex ) )
    throw eNotOpen;

  if( ppsJoy )
    *ppsJoy = &psJoysticks[iIndex];

  return TCL_OK;

  catch eError:
    return TCL_ERROR;
  catch eBadIndex:
    return _MklError( pI, "invalid joystick index %d, expected 0 to %d", iIndex, SDL_NumJoysticks()-1 );
  catch eNotOpen:
    return _MklError( pI, "joystick %d not open", iIndex );
}


/* _MklOpenJoysticks
   opens all joysticks that libsdl knows of. if a joystick can't be opened,
   nothing happens. instead, later calls for that joystick will return with
   an error message. this proc is called at init and with 'joystick rescan'.
*/
static void _MklOpenJoysticks()
{
  int i;
  SDL_Joystick *psJoystick;

  for( i = 0; i < SDL_NumJoysticks(); i++ )
  {
    if( SDL_JoystickOpened( i ) )
      continue;

    if( ! ( psJoystick = SDL_JoystickOpen( i ) ) )
      continue;

    psJoysticks[i].iIndex   = i;
    psJoysticks[i].pcName   = (char*)SDL_JoystickName( i );
    psJoysticks[i].psStick  = psJoystick;
    psJoysticks[i].fMax     = -1;
    psJoysticks[i].fDead    = -1;
    psJoysticks[i].bIsInt   = FALSE;
  }
}


/* _MklCloseJoysticks
   closes all open joysticks. this proc is called at exit and with 
   'joystick rescan'.
*/
static void _MklCloseJoysticks()
{
  int i;

  for( i = 0; i < SDL_NumJoysticks(); i++ )
    if( SDL_JoystickOpened( i ) )
      SDL_JoystickClose( psJoysticks[i].psStick );
}


/* _MklFormatAxis
   computes an axis value by taking the configured dead zone
   and maximum value into account, as set by 'joystick configure'.
   the returned object must be cleaned up by the caller (e.g. with _DRC).
*/
static Tcl_Obj *_MklFormatAxis( Mkl_Joystick *psJoy, int iValue )
{
  double fValue;

  fValue = (double)iValue;

  if( psJoy->fMax != -1 )
    fValue = psJoy->fMax * fValue / ( fValue < 0 ? 32768. : 32767. );

  if( psJoy->fDead != -1 && fabs( fValue ) <= psJoy->fDead )
    fValue = 0;

  if( psJoy->fMax == -1 && psJoy->fDead == -1 )
    return _NIO( (int)fValue );
  else if( psJoy->bIsInt )
    return _NIO( (int)fValue );
  else
    return _NDO( fValue );
}


/* _MklFormatEvent
   formats a libsdl event (in struct SDL_Event) into a tcl list. at this time
   we cover joystick events and the quit event (which is covered because with
   libsdl inside tcl, an interrupt (ctrl-c) seems to be caught by libsdl when
   in the event loop (vwait) - at least on windows). depending on the event
   type, the tcl list is of different format, but always suitable for an
   'array set' command, in case its desired. the proc is called upon
   'joystick event peek' or 'joystick event poll'.
*/
static int _MklFormatEvent( Tcl_Interp *pI, SDL_Event *psSdlEvent, Tcl_Obj *poData )
{
  switch( psSdlEvent->type ) 
  {
    case SDL_JOYAXISMOTION:
      try( _LOAE( poData, _NSO( "joystick"                ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jaxis.which   ) ), eError );
      try( _LOAE( poData, _NSO( "axis"                    ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jaxis.axis    ) ), eError );
      try( _LOAE( poData, _NSO( "value"                   ) ), eError );
      try( _LOAE( poData, _MklFormatAxis( &psJoysticks[psSdlEvent->jaxis.which], psSdlEvent->jaxis.value ) ), eError );
      break;

    case SDL_JOYHATMOTION:
      try( _LOAE( poData, _NSO( "joystick"                ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jhat.which    ) ), eError );
      try( _LOAE( poData, _NSO( "hat"                     ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jhat.hat      ) ), eError );
      try( _LOAE( poData, _NSO( "value"                   ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jhat.value    ) ), eError );
      break;

    case SDL_JOYBALLMOTION:
      try( _LOAE( poData, _NSO( "joystick"                ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jball.which   ) ), eError );
      try( _LOAE( poData, _NSO( "ball"                    ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jball.ball    ) ), eError );
      try( _LOAE( poData, _NSO( "xrel"                    ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jball.xrel    ) ), eError );
      try( _LOAE( poData, _NSO( "yrel"                    ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jball.yrel    ) ), eError );
      break;

    case SDL_JOYBUTTONUP:
    case SDL_JOYBUTTONDOWN:
      try( _LOAE( poData, _NSO( "joystick"                ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jbutton.which ) ), eError );
      try( _LOAE( poData, _NSO( "button"                  ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->jbutton.button) ), eError );
      try( _LOAE( poData, _NSO( "value"                   ) ), eError );
      try( _LOAE( poData, _NIO( psSdlEvent->type == SDL_JOYBUTTONUP? 0 : 1 ) ), eError );
      break;

    case SDL_QUIT:
      try( _LOAE( poData, _NSO( "quit"                    ) ), eError );
      try( _LOAE( poData, _NSO( ""                        ) ), eError );
      break;

  }

  return TCL_OK;

  catch eError:
    return TCL_ERROR;
}


/* _MklHandleEvent
   event handler as required by tcl's event concept. this is called whenever
   the event check proc _MklCheckEvent has detected and queued a libsdl event.
   so here we can evaluate the tcl script prior defined with 'joystick event 
   eval script'. if the script fails, we delete the event handler, to avoid
   endless calls (fileevent does it the same way). 
*/
static int _MklHandleEvent( Tcl_Event *psTclEvent, int iMask )
{
  Mkl_Event  *psEvent = (Mkl_Event*)psTclEvent;

  try( Tcl_EvalObjEx( psEvent->psInterp, poScript, TCL_EVAL_GLOBAL | TCL_EVAL_DIRECT ), eError );

  return 1;

  catch eError:
    Tcl_BackgroundError( psEvent->psInterp );
    Tcl_DeleteEventSource( _MklSetupEvent, _MklCheckEvent, psEvent->psInterp );
    _DRC( poScript );
    poScript = NULL;
    return 1;
}


/* _MklSetupEvent
   event setup proc as required by tcl's event concept. this is called by
   tcl periodially after the new event source is defined. we allow polling
   each 1 ms, which does not significantly increase cpu load.
*/
static void _MklSetupEvent( ClientData pC, int iFlags )
{
  static Tcl_Time sTime = { 0, 1000L };

  if( iFlags != TCL_ALL_EVENTS )
    return;

  Tcl_SetMaxBlockTime( &sTime );
}


/* _MklSetupEvent
   event check proc as required by tcl's event concept. this is called by
   tcl periodially after the new event source is defined. it is essentially
   derived from SDL_PollEvent(): first it puts any new events from the 
   devices into the sdl queue, then checks the queue. if at least one sdl 
   event is there, we create a tcl event and queue it. we only pass the
   tcl interp that is required to evaluate the event script (poScript).
   note that we do not take the sdl event from the queue. this is expected
   to happen in the event script with 'joystick event peek'. this mimic
   is similar to 'fileevent handle readable script' and e.g. 'gets handle'
   in the script.
*/
static void _MklCheckEvent( ClientData pC, int iFlags )
{
  Mkl_Event *psEvent;

	SDL_PumpEvents();

	if ( SDL_PeepEvents( NULL, 1, SDL_PEEKEVENT, SDL_JOYEVENTMASK | SDL_QUITMASK ) > 0 )
  {
    psEvent = (Mkl_Event*)ckalloc( sizeof( Mkl_Event ) );
    psEvent->sEvent.proc = _MklHandleEvent;
    psEvent->psInterp    = pC;

    Tcl_QueueEvent( (Tcl_Event*)psEvent, TCL_QUEUE_TAIL );
  }
}


/* _MklGetCdrom
   extracts the cdrom structure, which holds cdrom specific data, from
   an (excpected) integer value in poIndex. if it isn't an integer, or if the
   value is out of range, or if the cd-rom couldn't be opened at start up 
   or after a 'cdrom rescan', an error message is returned.
   otherwise, the pointer to the joystick structure is put into ppsCdrom.
   note: yes, the struct is sort of redundant, since no extra information
   is stored that couldn't be retrieved from libsdl directly. however, i
   did it like with the joystick struct to be prepared for future enhancements.
*/
static int _MklGetCdrom( Tcl_Interp *pI, Tcl_Obj *poIndex, Mkl_Cdrom **ppsCdrom, int bForceOpen )
{
  int iIndex;

  try( _GIO( poIndex, &iIndex ), eError );

  if( iIndex < 0 || iIndex >= SDL_CDNumDrives() )
    throw eBadIndex;

  if( bForceOpen && ! psCdroms[iIndex].psDrive )
  {   
    psCdroms[iIndex].iIndex = iIndex;
    psCdroms[iIndex].pcName = (char*)SDL_CDName( iIndex );
    psCdroms[iIndex].psDrive = SDL_CDOpen( iIndex );

    if( ! psCdroms[iIndex].psDrive )
      throw eOpenFailed;
  }

  if( ppsCdrom )
    *ppsCdrom = &psCdroms[iIndex];

  return TCL_OK;

  catch eBadIndex:
    return _MklError( pI, "invalid cdrom index %d, expected 0 to %d", iIndex, SDL_CDNumDrives()-1 );
  catch eOpenFailed:
    return _MklError( pI, "could not open drive %O (%s)", poIndex, SDL_GetError() );
  catch eError:
    return TCL_ERROR;
}


/* _MklCloseCdroms
   closes all open cd-roms. this proc is called at exit and with 
   'cdrom rescan'.
*/
static void _MklCloseCdroms()
{
  int i;

  for( i = 0; i < SDL_CDNumDrives(); i++ )
  {
    if( ! psCdroms[i].psDrive ) continue;
    SDL_CDClose( psCdroms[i].psDrive );
    psCdroms[i].psDrive = NULL;
  }
}


/* Mkl_JoystickCmd
   the joystick command proc. lenghty but flat. in the main switch, the 
   various options are handled one by one. 
*/
int Mkl_JoystickCmd( ClientData pC, Tcl_Interp *pI, int objc, Tcl_Obj *CONST objv[] )
{
  int          i, iMatch, iOption, iIndex, iCtrl, iValue, iDx, iDy;
  double       fValue, *pfAttrib;
  Tcl_Obj      *ppoValues[2];
  Mkl_Joystick *psJoy;
  SDL_Event    sSdlEvent;

  char *ppcOptions[] = { "rescan", "count", "names", "name", "index", "configure", "info", "get", "event", NULL };
  enum  eOptions       { _RESCAN , _COUNT , _NAMES , _NAME , _INDEX , _CONFIGURE , _INFO , _GET , _EVENT };

  char *ppcConfig[]  = { "-deadzone", "-maxvalue", NULL };
  enum  eConfig        {  _DEADZONE  , _MAXVALUE };

  char *ppcInfo[]    = { "axes", "balls", "hats", "buttons", NULL };
  enum  eInfo          { _AXES , _BALLS , _HATS , _BUTTONS };

  char *ppcGet[]     = { "axis", "ball", "hat", "button", NULL };
  enum  eGet           { _AXIS , _BALL , _HAT , _BUTTON };

  char *ppcEvent[]   = { "peek", "poll", "eval", NULL };
  enum  eEvent         { _PEEK , _POLL , _EVAL };


  if( objc < 2 )
    return _WNA( 1, "option ?args ...?" );

  try( _GIFO( objv[1], ppcOptions, "option", &iMatch ), eError );

  switch( iMatch )
  {
    case _RESCAN:

      if( objc != 2 )
        return _WNA( 1, "rescan" );

      /* just close all, then re-open all */
      _MklCloseJoysticks();
      SDL_QuitSubSystem( SDL_INIT_JOYSTICK );
      SDL_InitSubSystem( SDL_INIT_JOYSTICK );
      _MklOpenJoysticks();

      break;

    case _COUNT:

      if( objc != 2 )
        return _WNA( 1, "count" );

      /* set the number as the command result */
      _SOR( _NIO( SDL_NumJoysticks() ) );

      break;

    case _NAMES:

      if( objc != 2 )
        return _WNA( 1, "names" );

      /* format result as a tcl list with all joystick names */
      for( i = 0; i < SDL_NumJoysticks(); i++ )
        _LOAE( _GOR, _NSO( SDL_JoystickName( i ) ) );

      break;

    case _NAME:

      if( objc != 3 )
        return _WNA( 2, "index" );

      /* get joystick, but don't care here if it could be opened */
      try( _MklGetJoystick( pI, objv[2], &psJoy, FALSE ), eError );

      /* set the joystick name (essentially SDL_Joystick() */
      _SOR( _NSO( psJoy->pcName ) );

      break;

    case _INDEX:

      if( objc != 3 )
        return _WNA( 2, "pattern" );

      /* indicate 'not found' as joystick index */
      iIndex = -1;

      /* now find a name that matches the pattern... */
      for( i = 0; i < SDL_NumJoysticks(); i++ )
      {
        if( ! Tcl_StringCaseMatch( SDL_JoystickName( i ), _GSO( objv[2] ), TRUE ) )
          continue;

        /* if found, but another one was found before: it's not unique! */
        if( iIndex != -1 )
          throw eAmbiguous;

        /* store that joystick index */
        iIndex = i;
      }

      /* still at -1? then there was no match at all */
      if( iIndex == -1 )
        throw eNotFound;

      /* place the found index in the command result */
      _SOR( _NIO( iIndex ) );

      break;

    case _CONFIGURE:

      if( objc < 4 || ( objc > 4 && ( objc - 3 ) % 2 ) )
        return _WNA( 2, "index option ?value option value ...?" );

      try( _MklGetJoystick( pI, objv[2], &psJoy, TRUE ), eError );

      if( objc == 4 )
      {
        try( _GIFO( objv[3], ppcConfig, "option", &iOption ), eError );

        switch( iOption )
        {
          case _DEADZONE:

            if( psJoy->fDead != -1 )
              psJoy->bIsInt ? _SIO( _GOR, (int)psJoy->fDead ) : _SDO( _GOR, psJoy->fDead );

            break;

          case _MAXVALUE:

            if( psJoy->fMax != -1 )
              psJoy->bIsInt ? _SIO( _GOR, (int)psJoy->fMax  ) : _SDO( _GOR, psJoy->fMax  );
  
            break;
        }
      }
      else 
      {
        try( _MklGetOptions( pI, objc-3, objv+3, ppcConfig, ppoValues ), eError );
   
        if( ppoValues[_DEADZONE] )
        {
          if( ! strlen( _GSO( ppoValues[_DEADZONE] ) ) )
            psJoy->fDead = -1;
          else
          {
            try( _GDO( ppoValues[_DEADZONE], &fValue ), eError );
            psJoy->fDead = fValue;
          }
        }
  
        if( ppoValues[_MAXVALUE] )
        {
          if( ! strlen( _GSO( ppoValues[_MAXVALUE] ) ) )
            psJoy->fMax = -1;
          else
          {
            try( _GDO( ppoValues[_MAXVALUE], &fValue ), eError );
            psJoy->fMax   = fValue;
            psJoy->bIsInt = ( _GIO( ppoValues[_MAXVALUE], &iValue ) == TCL_OK );
          }
        }
  
        _ROR;
      }

      break;

    case _INFO:

      if( objc != 4 )
        return _WNA( 2, "index option" );

      try( _MklGetJoystick( pI, objv[2], &psJoy, TRUE ), eError );
      try( _GIFO( objv[3], ppcInfo, "option", &iOption ), eError );

      /* simply return the number of control type (axis etc.) */
      switch( iOption )
      {
        case _AXES   : _SOR( _NIO( SDL_JoystickNumAxes   ( psJoy->psStick ) ) ); break;
        case _BALLS  : _SOR( _NIO( SDL_JoystickNumBalls  ( psJoy->psStick ) ) ); break;
        case _HATS   : _SOR( _NIO( SDL_JoystickNumHats   ( psJoy->psStick ) ) ); break;
        case _BUTTONS: _SOR( _NIO( SDL_JoystickNumButtons( psJoy->psStick ) ) ); break;
      }

      break;

    case _GET:

      if( objc != 5 )
        return _WNA( 2, "index option control" );

      try( _MklGetJoystick( pI, objv[2], &psJoy, TRUE ), eError );
      try( _GIFO( objv[3], ppcGet, "option", &iOption ), eError );
      try( _GIO( objv[4], &iCtrl ), eError );

      /* sdl says we must first call this function before we can query */
      SDL_JoystickUpdate();

      /* now check if the control index is ok, and return the value */
      switch( iOption )
      {
        case _AXIS   :

          if( iCtrl < 0 || iCtrl >= SDL_JoystickNumAxes( psJoy->psStick ) )
            throw eBadAxisIndex;

          _SOR( _MklFormatAxis( psJoy, SDL_JoystickGetAxis( psJoy->psStick, iCtrl ) ) );

          break;

        case _BALL  :

          if( iCtrl < 0 || iCtrl >= SDL_JoystickNumBalls( psJoy->psStick ) )
            throw eBadBallIndex;

          SDL_JoystickGetBall( psJoy->psStick, iCtrl, &iDx, &iDy );

          _LOAE( _GOR, _NIO( iDx ) );
          _LOAE( _GOR, _NIO( iDy ) );

          break;

        case _HAT   :

          if( iCtrl < 0 || iCtrl >= SDL_JoystickNumHats( psJoy->psStick ) )
            throw eBadHatIndex;

          _SOR( _NIO( SDL_JoystickGetHat( psJoy->psStick, iCtrl ) ) );

          break;

        case _BUTTON:

          if( iCtrl < 0 || iCtrl >= SDL_JoystickNumButtons( psJoy->psStick ) )
            throw eBadButtonIndex;

          _SOR( _NIO( SDL_JoystickGetButton( psJoy->psStick, iCtrl ) ) );

          break;
  
      }

      break;

    case _EVENT:

      if( objc < 3 || objc > 4 )
        return _WNA( 2, "option ?arg ...?" );

      try( _GIFO( objv[2], ppcEvent, "option", &iOption ), eError );

      switch( iOption )
      {
        case _PEEK:
        case _POLL:

          if( objc != 3 )
            return _WNA( 3, "" );

          /* poll smashes new events into the queue first, peek doesn't */       
          if( iOption == _POLL )
            SDL_PumpEvents();

          /* check if an event is there and format it as command result */    
          switch( SDL_PeepEvents( &sSdlEvent, 1, SDL_GETEVENT, SDL_JOYEVENTMASK | SDL_QUITMASK ) )
          {
            case -1:
              throw eSdlError;
            case 1:
              try( _MklFormatEvent( pI, &sSdlEvent, _GOR ), eError );
          }
    
          break;

        case _EVAL:

          if( objc < 3 || objc > 4 )
            return _WNA( 3, "?script?" );

          if( objc == 3 )
          {
            /* now new script? return existing script, if any */    
            if( poScript )
              _SOR( poScript );
          }
          else
          {
            /* delete any existing event source first */
            if( poScript )
            {
              Tcl_DeleteEventSource( _MklSetupEvent, _MklCheckEvent, pI );
              _DRC( poScript );
              poScript = NULL;
            }

            /* set up new event source, if new script was given */    
            if( strlen( _GSO( objv[3] ) ) )
            {
              poScript = objv[3];
              _IRC( poScript );
              Tcl_CreateEventSource( _MklSetupEvent, _MklCheckEvent, pI );
            }
          }
    
          break;
      }

      break;

  }

  return TCL_OK;

  catch eError:
    return TCL_ERROR;
  catch eAmbiguous:
    return _MklError( pI, "ambiguous pattern '%O'", objv[2] );
  catch eNotFound:
    return _MklError( pI, "no match for pattern '%O'", objv[2] );
  catch eBadAxisIndex:
    return _MklError( pI, "invalid axis index %d, expected 0 to %d", iCtrl, SDL_JoystickNumAxes( psJoy->psStick )-1 );
  catch eBadBallIndex:
    return _MklError( pI, "invalid ball index %d, expected 0 to %d", iCtrl, SDL_JoystickNumBalls( psJoy->psStick )-1 );
  catch eBadHatIndex:
    return _MklError( pI, "invalid hat index %d, expected 0 to %d", iCtrl, SDL_JoystickNumHats( psJoy->psStick )-1 );
  catch eBadButtonIndex:
    return _MklError( pI, "invalid button index %d, expected 0 to %d", iCtrl, SDL_JoystickNumButtons( psJoy->psStick )-1 );
  catch eSdlError:
    return _MklError( pI, "libsdl error (%s)", SDL_GetError() );
}


int Mkl_CdromCmd( ClientData pC, Tcl_Interp *pI, int objc, Tcl_Obj *CONST objv[] )
{
  int       i, iMatch, iOption, iIndex, iTrack, iFrame, iNumTracks, iNumFrames;
  char      **ppcValues;
  Tcl_Obj   *ppoValues[4];
  Mkl_Cdrom *psCdrom;

  char *ppcOptions[] = { "rescan", "count", "names", "name", "index", "info", "trackinfo", "play", "stop", "pause", "resume", "eject", NULL };
  enum  eOptions       { _RESCAN , _COUNT , _NAMES , _NAME , _INDEX , _INFO , _TRACKINFO , _PLAY , _STOP , _PAUSE , _RESUME , _EJECT };

  char *ppcInfo[]    = { "status", "loaded", "tracks", "fps", "current", NULL };
  enum  eInfo          { _STATUS , _LOADED , _TRACKS , _FPS , _CURRENT };

  char *ppcTrack[]   = { "type", "length", "offset", NULL };
  enum  eTrack         { _TYPE , _LENGTH , _OFFSET };

  char *ppcPlay[]    = { "-track", "-frame", "-numtracks", "-numframes", NULL };
  enum  ePlay          {  _TRACK ,  _FRAME ,  _NUMTRACKS ,  _NUMFRAMES };

  if( objc < 2 )
    return _WNA( 1, "option ?args ...?" );

  try( _GIFO( objv[1], ppcOptions, "option", &iMatch ), eError );

  switch( iMatch )
  {
    case _RESCAN:

      if( objc != 2 )
        return _WNA( 1, "rescan" );

      /* just close all, then re-open all */
      _MklCloseCdroms();
      SDL_QuitSubSystem( SDL_INIT_CDROM );
      SDL_InitSubSystem( SDL_INIT_CDROM );

      break;

    case _COUNT:

      if( objc != 2 )
        return _WNA( 1, "count" );

      /* set the number as the command result */
      _SOR( _NIO( SDL_CDNumDrives() ) );

      break;

    case _NAMES:

      if( objc != 2 )
        return _WNA( 1, "names" );

      /* format result as a tcl list with all joystick names */
      for( i = 0; i < SDL_CDNumDrives(); i++ )
        _LOAE( _GOR, _NSO( SDL_CDName( i ) ) );

      break;

    case _NAME:

      if( objc != 3 )
        return _WNA( 2, "index" );

      /* get joystick, but don't care here if it could be opened */
      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );

      /* set the joystick name (essentially SDL_Joystick() */
      _SOR( _NSO( psCdrom->pcName ) );

      break;

    case _INDEX:

      if( objc != 3 )
        return _WNA( 2, "pattern" );

      /* indicate 'not found' as joystick index */
      iIndex = -1;

      /* now find a name that matches the pattern... */
      for( i = 0; i < SDL_CDNumDrives(); i++ )
      {
        if( ! Tcl_StringCaseMatch( SDL_CDName( i ), _GSO( objv[2] ), TRUE ) )
          continue;

        /* if found, but another one was found before: it's not unique! */
        if( iIndex != -1 )
          throw eAmbiguous;

        /* store that joystick index */
        iIndex = i;
      }

      /* still at -1? then there was no match at all */
      if( iIndex == -1 )
        throw eNotFound;

      /* place the found index in the command result */
      _SOR( _NIO( iIndex ) );

      break;

    case _INFO:

      if( objc != 4 )
        return _WNA( 2, "index option" );

      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );
      try( _GIFO( objv[3], ppcInfo, "option", &iOption ), eError );

      SDL_CDStatus( psCdrom->psDrive );

      /* simply return the number of control type (axis etc.) */
      switch( iOption )
      {
        case _STATUS: 
          
          switch( psCdrom->psDrive->status )
          {
            case CD_TRAYEMPTY: _SOR( _NSO( "trayempty" ) ); break;
            case CD_STOPPED  : _SOR( _NSO( "stopped"   ) ); break;
            case CD_PLAYING  : _SOR( _NSO( "playing"   ) ); break;
            case CD_PAUSED   : _SOR( _NSO( "paused"    ) ); break;
            case CD_ERROR    : _SOR( _NSO( "error"     ) ); break;
          }

          break;
 
        case _LOADED:

          _SOR( _NIO( CD_INDRIVE( SDL_CDStatus( psCdrom->psDrive ) ) ) );   
          break;

        case _TRACKS:

          _SOR( _NIO( psCdrom->psDrive->numtracks ) );
          break;

        case _FPS:

          _SOR( _NIO( CD_FPS ) );
          break;

        case _CURRENT:

          _LOAE( _GOR, _NIO( psCdrom->psDrive->cur_track ) );
          _LOAE( _GOR, _NIO( psCdrom->psDrive->cur_frame ) );
          break;

      }

      break;

    case _TRACKINFO:

      if( objc != 5 )
        return _WNA( 2, "index trackno option" );

      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );

      try( _GIFO( objv[4], ppcTrack, "option", &iOption ), eError );

      SDL_CDStatus( psCdrom->psDrive );

      try( _GIO( objv[3], &iTrack ), eError );
      if( iTrack < 0 || iTrack >= psCdrom->psDrive->numtracks )
        throw eBadTrack;

      /* simply return the number of control type (axis etc.) */
      switch( iOption )
      {
        case _TYPE:

          switch( psCdrom->psDrive->track[iTrack].type )
          {
            case SDL_AUDIO_TRACK: _SOR( _NSO( "audio" ) ); break;
            case SDL_DATA_TRACK : _SOR( _NSO( "data"  ) ); break;
          }

          break;

        case _LENGTH:

          _SOR( _NIO( psCdrom->psDrive->track[iTrack].length ) );
          break;

        case _OFFSET:

          _SOR( _NIO( psCdrom->psDrive->track[iTrack].offset ) );
          break;

      }

      break;

    case _PLAY:

      if( objc < 3 || ( objc - 3 ) % 2 )
        return _WNA( 2, "index ?options?" );

      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );
      try( _MklGetOptions( pI, objc-3, objv+3, ppcPlay, ppoValues ), eError );

      SDL_CDStatus( psCdrom->psDrive );

      iTrack     = 0;
      iFrame     = 0;
      iNumTracks = 0;
      iNumFrames = 0;

      if( ppoValues[_TRACK] )
        try( _GIO( ppoValues[_TRACK], &iTrack ), eError );

      if( ppoValues[_FRAME] )
        try( _GIO( ppoValues[_FRAME], &iFrame ), eError );

      if( ppoValues[_NUMTRACKS] )
        try( _GIO( ppoValues[_NUMTRACKS], &iNumTracks ), eError );

      if( ppoValues[_NUMFRAMES] )
        try( _GIO( ppoValues[_NUMFRAMES], &iNumFrames ), eError );

      if( SDL_CDPlayTracks( psCdrom->psDrive, iTrack, iFrame, iNumTracks, iNumFrames ) )
        throw ePlayFailed;
  
      break;

    case _STOP:

      if( objc != 3 )
        return _WNA( 2, "index" );

      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );

      if( SDL_CDStop( psCdrom->psDrive ) )
        throw eStopFailed;
     
      break;

    case _PAUSE:

      if( objc != 3 )
        return _WNA( 2, "index" );

      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );

      if( SDL_CDPause( psCdrom->psDrive ) )
        throw ePauseFailed;
     
      break;

    case _RESUME:

      if( objc != 3 )
        return _WNA( 2, "index" );

      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );

      if( SDL_CDResume( psCdrom->psDrive ) )
        throw eResumeFailed;
     
      break;

    case _EJECT:

      if( objc != 3 )
        return _WNA( 2, "index" );

      try( _MklGetCdrom( pI, objv[2], &psCdrom, TRUE ), eError );

      if( SDL_CDEject( psCdrom->psDrive ) )
        throw eEjectFailed;

      break;

  }

  return TCL_OK;

  catch eError:
    return TCL_ERROR;
  catch eAmbiguous:
    return _MklError( pI, "ambiguous pattern '%O'", objv[2] );
  catch eNotFound:
    return _MklError( pI, "no match for pattern '%O'", objv[2] );
  catch eBadTrack:
    return _MklError( pI, "invalid track number '%O'", objv[3] );
  catch ePlayFailed:
    return _MklError( pI, "could not play drive %O (%s)", objv[2], SDL_GetError() );
  catch eStopFailed:
    return _MklError( pI, "could not stop drive %O (%s)", objv[2], SDL_GetError() );
  catch ePauseFailed:
    return _MklError( pI, "could not pause drive %O (%s)", objv[2], SDL_GetError() );
  catch eResumeFailed:
    return _MklError( pI, "could not resume drive %O (%s)", objv[2], SDL_GetError() );
  catch eEjectFailed:
    return _MklError( pI, "could not eject drive %O (%s)", objv[2], SDL_GetError() );
  catch eSdlError:
    return _MklError( pI, "libsdl error (%s)", SDL_GetError() );
}



/* Mkziplib_Init
   package initialization. creates all new commands and registers the package.
   also opens all joysticks and counts how many tcl interps use libsdl. we
   need this counter in the package exit function.
*/
int Mklibsdl_Init( Tcl_Interp *pI )
{
  ClientData pC = NULL;

  /* check for version >= 8.4, because of byte arrays being used */
  if( TCL_MAJOR_VERSION < 8 || ( TCL_MAJOR_VERSION == 8 && TCL_MINOR_VERSION < 4 ) )
    throw eWrongVersion;

#ifdef USE_TCL_STUBS
  if( Tcl_InitStubs( pI, "8.4", 0) == NULL )
    throw eError;
#endif

  /* initialize libsdl with video, or events wouldn't work */
  if ( SDL_Init( SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_CDROM ) < 0 )
    throw eInitFailed;

  /* now open all joysticks for convenience */
  _MklOpenJoysticks();

  /* count inits, so we won't quit sdl prematurely */
  iInUse++;

  Tcl_CallWhenDeleted( pI, Mklibsdl_Exit, pC );

  Tcl_CreateObjCommand( pI, "joystick", Mkl_JoystickCmd, pC, NULL );
  Tcl_CreateObjCommand( pI, "cdrom"   , Mkl_CdromCmd   , pC, NULL );

  try( Tcl_PkgProvide( pI, "mkLibsdl", _VERSION ), eError );

  return TCL_OK;

  catch eError:
    return TCL_ERROR;
  catch eWrongVersion:
    return _MklError( pI, "Package mkLibsdl requires Tcl Version 8.3" );
  catch eInitFailed:
    return _MklError( pI, "Libsdl initialization failed (%s)", SDL_GetError() );
}

int Mklibsdl_SafeInit( Tcl_Interp *pI )
{
  return Mklibsdl_Init( pI );
}


/* Mkziplib_Exit
   package unloading: if no interp uses the package anymore then we can
   close all joysticks and quit sdl.
*/
void Mklibsdl_Exit( ClientData pC, Tcl_Interp *pI )
{
  int i;

  if( ! --iInUse )
  {
    _MklCloseJoysticks();
    _MklCloseCdroms();
    SDL_Quit();
  }
}


/* static linking. uncomment the following two functions if you want
   to create a stand-alone shell instead of a dynamic library. */

#ifndef USE_TCL_STUBS

int main( int argc, char *argv[] )
{
  Tcl_Main( argc, argv, Tcl_AppInit );
  return 0;
}

int Tcl_AppInit( Tcl_Interp *pI )
{
  try( Tcl_Init( pI ), eError );
  try( Mklibsdl_Init( pI ), eError );

  return TCL_OK;

  catch eError:
    return TCL_ERROR;
}

#endif

/*
 * mkLibsdl 1.0
 * ------------
 */

