/* libtt_tcl.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL
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


#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>

#ifdef WIN32 
#define sscanf sscanf_s
#endif

#include <tcl.h>
#include "libtt_tcl.h"
#include "libtt.h"

// fonctions locals au fichier
//int CmdTtScript(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdTtScript2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdTtScript3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdFits2ColorJpg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdFitsHeader(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int CmdFitsConvert3d(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

// utilitaires de conversion de variables C en Tcl
int copyObjToInt(Tcl_Interp *interp, const char *argv, const char * paramName);
double copyObjToDouble(Tcl_Interp *interp, const char *argv, const char * paramName);
bool copyObjToBoolean(Tcl_Interp *interp, const char *argv, const char * paramName);

// load d:/devcpp/audela-tcl86/bin/libtt_tcl.dll

// cd /devcpp/audela-tcl86/bin
// load libtt_tcl.dll

/***************************************************************************/
/*                      Point d'entree de la librairie TCL                 */
/***************************************************************************/
#ifdef WIN32
   extern "C" TCLTT_API int __cdecl Tcltt_Init(Tcl_Interp *interp)
#else
   extern "C" TCLTT_API int Tcltt_Init(Tcl_Interp *interp)
#endif

{
   if(Tcl_InitStubs(interp,"8.6",0)==NULL) {
      Tcl_SetResult(interp, (char *) "Tcl Stubs initialization",TCL_STATIC);
      return TCL_ERROR;
   }

   Tcl_PkgProvide(interp,"libtt","1.0");

   //load_libtt(Tcl_GetVar(interp,"audela_start_dir",TCL_GLOBAL_ONLY));

   Tcl_CreateCommand(interp,"ttscript",(Tcl_CmdProc *)CmdTtScript3,NULL,NULL);
   Tcl_CreateCommand(interp,"ttscript2",(Tcl_CmdProc *)CmdTtScript2,NULL,NULL);

   Tcl_CreateCommand(interp,"fits2colorjpeg",(Tcl_CmdProc *)CmdFits2ColorJpg,NULL,NULL);
   Tcl_CreateCommand(interp,"fitsheader",(Tcl_CmdProc *)CmdFitsHeader,NULL,NULL);
   Tcl_CreateCommand(interp,"fitsconvert3d",(Tcl_CmdProc *)CmdFitsConvert3d,NULL,NULL);

   return TCL_OK;
}

double copyObjToDouble(Tcl_Interp *interp, const char *argv, const char * paramName) {
   double value;
   if(strlen(argv) == 0 ||Tcl_GetDouble(interp, argv,&value)!=TCL_OK) {
      std::ostringstream message;
      message << paramName <<"=" << argv << " is not a double";
      throw std::runtime_error( message.str().c_str());
   }
   return value;
}

int copyObjToInt(Tcl_Interp *interp, const char *argv, const char * paramName) {
   int value;
   if(strlen(argv) == 0  || Tcl_GetInt(interp, argv,&value)!=TCL_OK) {
      std::ostringstream message;
      message << paramName <<"=" << argv << " is not an integer";
      throw std::runtime_error( message.str().c_str());
   }
   return value;
}

bool copyObjToBoolean(Tcl_Interp *interp, const char *argv, const char * paramName) {
   int value;
   if(strlen(argv) == 0  || Tcl_GetBoolean(interp, argv, &value)!=TCL_OK) {
      std::ostringstream message;
      message << paramName <<"=" << argv << " is not a boolean integer";
      throw std::runtime_error( message.str().c_str());
   }
   return (value == 1);
}

