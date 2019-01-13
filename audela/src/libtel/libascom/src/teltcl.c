/* teltcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "telescop.h"
#include <libtel/libtel.h>
#include "teltcl.h"
#include <libtel/util.h>

/*
 *   structure pour les fonctions étendues
 */

/*
 *   fonctions étendues
 */

int cmdTelPut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* execute une fonction                                                                */
/***************************************************************************************/
   char s[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   Tcl_DString dsptr;
   tel = (struct telprop *)clientData;

   if(argc<2) {
      sprintf(s,"Usage: %s args", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
	   result=TCL_OK;
	   strcpy(s,"set telcmd $::ascom_variable(1)"); mytel_tcleval(tel,s);
	   Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"$telcmd ",-1);
		for (k=2;k<argc;k++) {
			Tcl_DStringAppend(&dsptr,argv[k],-1);
			Tcl_DStringAppend(&dsptr," ",-1);
		}
		result=mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
		Tcl_DStringFree(&dsptr);
   }
   return result;
}

int cmdTelProperties(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Retourne toutes les propriétés                                                      */
/***************************************************************************************/
   char s[256];
   int result = TCL_OK;
   struct telprop *tel;
   Tcl_DString dsptr;
   tel = (struct telprop *)clientData;

	strcpy(s,"set telcmd $::ascom_variable(1)"); mytel_tcleval(tel,s);
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"[::tcom::info interface $telcmd] properties",-1);
	result=mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
   return result;
}

int cmdTelMethods(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/***************************************************************************************/
/* Retourne toutes les methodes                                                        */
/***************************************************************************************/
   char s[256];
   int result = TCL_OK;
   struct telprop *tel;
   Tcl_DString dsptr;
   tel = (struct telprop *)clientData;

	strcpy(s,"set telcmd $::ascom_variable(1)"); mytel_tcleval(tel,s);
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"[::tcom::info interface $telcmd] methods",-1);
	result=mytel_tcleval(tel,Tcl_DStringValue(&dsptr));
	Tcl_DStringFree(&dsptr);
   return result;
}

// ---------------------------------------------------------------------------
// cmdTelConnectedSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int cmdTelConnectedSetupDialog(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   struct telprop *tel = (struct telprop *)clientData;
   int result = mytel_connectedSetupDialog(tel);
   if ( result == 0 ) {
      Tcl_SetResult(interp, (char*)"", TCL_VOLATILE);
      return TCL_OK;
   } else {
      Tcl_SetResult(interp, tel->msg, TCL_VOLATILE);
      return TCL_ERROR;
   }
}

// ---------------------------------------------------------------------------
// cmdTelSetupDialog 
//    affiche la fenetre de configuration fournie par le driver de la camera
// return
//    TCL_OK
// ---------------------------------------------------------------------------
int cmdTelSetupDialog(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   char errorMsg[1024]; 
   int result = mytel_setupDialog(argv[2], errorMsg);
   if ( result == 0 ) {
      Tcl_SetResult(interp, (char*)"", TCL_VOLATILE);
      return TCL_OK;
   } else {
      Tcl_SetResult(interp, errorMsg, TCL_VOLATILE);
      return TCL_ERROR;
   }
}


// ---------------------------------------------------------------------------
// cmdTelSelect 
//    selectionne le driver ASCOM du telescope
// return:
// 
// ---------------------------------------------------------------------------
int cmdTelSelect(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[])
{
   int result;
   char productName[1024];
   if (argc == 3 ) {
      strcpy(productName, argv[2]);
   }
   result = tel_select(productName);
   if (result == 0 ) {
      Tcl_SetResult(interp, productName, TCL_VOLATILE);
      return TCL_OK;
   } else {
      // productName contient le message d'erreur
      Tcl_SetResult(interp, productName, TCL_VOLATILE);
      return TCL_ERROR;
   }
}


