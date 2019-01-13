/* focusfli_1.c
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

/***************************************************************************/
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers focusfli_*.c.                         */
/***************************************************************************/
/* Le include focusflitcl.h ne contient des infos concernant Tcl.           */
/***************************************************************************/
#include "focusflitcl.h"

/*
load libfocusfli.dll
focusfli_open
focusfli_get

focusfli_incr 1000
*/

int Cmd_focusflitcl_open(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	int err;
   char **camlist, *semicolon;
   // Version du driver FLI
   if ((err = FLIGetLibVersion(fli.ver, 100))) {
	   Tcl_SetResult(interp,"error in FLIGetLibVersion",TCL_VOLATILE);
      return TCL_ERROR;
   }
   // Recupere la liste des cameras disponibles sur le systeme
   camlist = NULL;
   if ((err = FLIList(FLIDOMAIN_USB | FLIDEVICE_FOCUSER, &camlist))) {
   Tcl_SetResult(interp,"",TCL_VOLATILE);
	   Tcl_SetResult(interp,"error in FLIList",TCL_VOLATILE);
      return TCL_ERROR;
   }
	if (camlist==NULL) {
	   Tcl_SetResult(interp,"error. No FLI device detected.",TCL_VOLATILE);
      return TCL_ERROR;
	}
   strcpy (fli.fliname , camlist[0]);
   semicolon = strchr(fli.fliname, ';');
   if (semicolon) {
      *semicolon = '\0';
   }
   if ((err = FLIFreeList(camlist))) {
	   Tcl_SetResult(interp,"impossible to free camlist by FLIFreeList",TCL_VOLATILE);
      return TCL_ERROR;
   }
   // Ouverture du focuser
   if ((err = FLIOpen(&fli.device, fli.fliname,FLIDOMAIN_USB | FLIDEVICE_FOCUSER))) {
	   Tcl_SetResult(interp,"impossible to connect to the camera by FLIOpen",TCL_VOLATILE);
      return TCL_ERROR;
   }
   // Modele du focuser
   if ((err = FLIGetModel(fli.device, fli.model, sizeof(fli.model)))) {
	   Tcl_SetResult(interp,"error in FLIGetModel",TCL_VOLATILE);
      return TCL_ERROR;
   }

   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_focusflitcl_infos(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[2000];
	sprintf(s,"{version {%s}} {name %s} {model {%s}}",fli.ver,fli.fliname,fli.model);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_focusflitcl_close(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	int err;
	// Fermeture du focuser
	if (err = FLIClose(fli.device)) {
		Tcl_SetResult(interp,"impossible to close connection by FLIClose",TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_focusflitcl_get(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
	int err;
	long position,extent;
	double temp_in, temp_ex;
	if (err = FLIGetStepperPosition(fli.device,&position)) {
		Tcl_SetResult(interp,"impossible to use FLIGetStepperPosition",TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (err = FLIGetFocuserExtent(fli.device,&extent)) {
		Tcl_SetResult(interp,"impossible to use FLIGetFocuserExtent",TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (err = FLIReadTemperature(fli.device,FLI_TEMPERATURE_INTERNAL,&temp_in)) {
		Tcl_SetResult(interp,"impossible to use FLIReadTemperature",TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (err = FLIReadTemperature(fli.device,FLI_TEMPERATURE_EXTERNAL,&temp_ex)) {
		Tcl_SetResult(interp,"impossible to use FLIReadTemperature",TCL_VOLATILE);
		return TCL_ERROR;
	}
	//sprintf(s,"{position %d} {extent %d} {temperature_internal %.2f} {temperature_external %.2f}",position,extent,temp_in,temp_ex);
	sprintf(s,"{position %d} {extent %d} {temperature_internal %.2f}",position,extent,temp_in);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_focusflitcl_incr(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
	int k,err,async=0;
	long steps;
   if (argc < 2 ) {
      sprintf(s,"%s steps", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   }
	if (argc >= 3) {
		for (k=2 ; k<argc ; k++) {
			if (strcmp(argv[k],"-async")==0) {
				async=1;
			}
		}
	}
	steps=(long)atoi(argv[1]);
	/*
	// probablement impossible d'utiliser FLIStepMotor sans passer par un thread 
	if (async==0) {
		if (err = FLIStepMotor(fli.device,steps)) {
			Tcl_SetResult(interp,"impossible d'utiliser FLIStepMotor",TCL_VOLATILE);
			return TCL_ERROR;
		}
	} else {
		if (err = FLIStepMotorAsync(fli.device,steps)) {
			Tcl_SetResult(interp,"impossible d'utiliser FLIStepMotorAsync",TCL_VOLATILE);
			return TCL_ERROR;
		}
	}
	*/
	if (err = FLIStepMotorAsync(fli.device,steps)) {
		Tcl_SetResult(interp,"impossible to use FLIStepMotorAsync",TCL_VOLATILE);
		return TCL_ERROR;
	}
	Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_focusflitcl_home(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	int err;
	if (err = FLIHomeFocuser(fli.device)) {
		Tcl_SetResult(interp,"impossible to use FLIHomeFocuser",TCL_VOLATILE);
		return TCL_ERROR;
	}
	Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

