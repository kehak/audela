/* camtcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ & Philippe AMBERT <alain.klotz@free.fr>
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
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

int cmdCagireTest(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    int retour = TCL_OK;
    return retour;
}

int cmdCagireInitialize(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
	struct camprop *cam;
	int retour = TCL_OK,res;
	cam = (struct camprop *) clientData;
	res=cagire_initialize(cam);
	if (res==1) {
		retour = TCL_ERROR;
	}
	Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
	return retour;
}

int cmdCagirePut(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
	char ligne[1000];
	int retour = TCL_OK;
	int res;
	struct camprop *cam;

	if (argc<3) {
		sprintf(ligne, "Usage %s %s string", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		retour = TCL_ERROR;
	} else {
	   cam = (struct camprop *) clientData;
		res=cagire_put(cam,argv[2]);
      if (res==1) {
         retour = TCL_ERROR;
         Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
      } else {
         Tcl_ResetResult(interp);
      }
	}
	return retour;
}

int cmdCagireRead(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
	char ligne[1000];
	int retour = TCL_OK;
	int res;
	struct camprop *cam;

	cam = (struct camprop *) clientData;
	res=cagire_read(cam,ligne);
   if (res==1) {
      retour = TCL_ERROR;
      Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
   } else {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
	return retour;
}

int cmdCagirePutRead(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
	char ligne[1000];
	int retour = TCL_OK;
	int res;
	struct camprop *cam;

	if (argc<3) {
		sprintf(ligne, "Usage %s %s string", argv[0], argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		retour = TCL_ERROR;
	} else {
	   cam = (struct camprop *) clientData;
		res=cagire_put(cam,argv[2]);
      if (res==1) {
         retour = TCL_ERROR;
         Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
      } else {
			sprintf(ligne,"after %d",cam->tempo); mycam_tcleval(cam,ligne);
			res=cagire_read(cam,ligne);
			if (res==1) {
				retour = TCL_ERROR;
				Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			} else {
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			}
		}
	}
	return retour;
}

int cmdCagireChannel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
	int retour = TCL_OK;
	struct camprop *cam;
	cam = (struct camprop *) clientData;
   Tcl_SetResult(interp,cam->channel,TCL_VOLATILE);
	return retour;
}
