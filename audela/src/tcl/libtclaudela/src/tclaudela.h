/* libstd.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef __LIBSTDH__
#define __LIBSTDH__

#include "sysexp.h"

#if defined(OS_WIN)
  #include <windows.h>
#endif

#include <tcl.h>
#include <abaudela.h>

#include "libtt.h"
//#include "fitskw.h"
#include "history.h"
//#include "stats.h"
//#include "cpool.h"
//#include "cerror.h"
#include "cmditem_tcl.h"

#define __DLL__

#define STD_VERSION AUDELA_VERSION

//=============================================================================
// export directive and import directive
//=============================================================================
#ifdef _WIN32
#if defined(TCLAUDELA_EXPORTS) // inside DLL
#   define TCLAUDELA_API   __declspec(dllexport)
#else // outside DLL
#   define TCLAUDELA_API   __declspec(dllimport)
#endif 

#else 

#if defined(TCLAUDELA_EXPORTS) // inside DLL
#   define TCLAUDELA_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define TCLAUDELA_API 
#endif 

#endif


extern CHistory *history;

extern void audelaInit(Tcl_Interp *interp);

/*extern int DEBUG_SERIAL;*/

extern void audela_sleep(int ms);
extern void audela_strupr(char *s);
extern unsigned long audela_getms();
extern int audela_strcasecmp(char *a, char *b);

extern void LogFile(char*s);
extern void vlogfile(char *fmt, ...);


//------------------------------------------------------------------------------
// Fonctions implementant la creations d'objets, et manipulation de leur liste.
//
extern int CmdCreatePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
extern int CmdListPoolItems(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdDeletePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdAvailablePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdGetGenericNamePoolItem(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

//------------------------------------------------------------------------------
// Fonctions de manipulation des objets.
//
extern int CmdBuf(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
//extern int CmdVisu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdCam(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
extern int CmdTel(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
extern int CmdLink(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);


/*
 * Non-object functions to be declared in the Tcl interpreter.
 */
extern int CmdTtScript(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdTtScript2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdTtScript3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdFits2ColorJpg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdFitsHeader(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
extern int CmdFitsConvert3d(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

/*----
  -- Pour l'execution de Audela depuis une DLL
  ----*/
#define AUDELA_EXCH_CMDBUFSIZE    1024
#define AUDELA_EXCH_RESBUFSIZE    1024
#define KILLED_THREAD_STR         "Tcl interpreter killed."
#define AUDELA_EXCH_NAME          "audelaExch"
#define AUDELA_WINMSG_NAME        "audelaMsg"
#define AUDELA_SESSIONCOUNT_NAME  "audelaCnt"
#define AUDELA_EVENT_NAME         "audelaEvt"
const int MAXSTRING = 255;
typedef struct {
   int cmdpending;
   int cmdok;
   int cmdres;
   int keepthread;
   int threaddead;
   char cmd[AUDELA_EXCH_CMDBUFSIZE];
   char res[AUDELA_EXCH_RESBUFSIZE];
} exchStruct_T;




#endif


