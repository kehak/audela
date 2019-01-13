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

int cmdTelAction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   if (argc<2) {
   	sprintf(ligne,"usage: %s %s action",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   my_pthread_mutex_lock(&mutex);
	if (argc==2) {
		sprintf(ligne,"%s %d",telthread->action_next,telthread->compteur);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	} else {
		strcpy(telthread->action_next,argv[2]);
		Tcl_SetResult(interp,telthread->action_next,TCL_VOLATILE);
	}
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelMessage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   my_pthread_mutex_lock(&mutex);
	Tcl_SetResult(interp,telthread->message,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelVariables(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	//char s[4096];
   my_pthread_mutex_lock(&mutex);
	//sprintf(s,"foreach ls {%s} { set [lindex $ls 0] [lindex $ls 1] }",telthread->variables);
	//Tcl_Eval(interp,s);
	Tcl_SetResult(interp,telthread->variables,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelTelName(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   my_pthread_mutex_lock(&mutex);
	Tcl_SetResult(interp,telthread->telname,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelSource(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   my_pthread_mutex_lock(&mutex);
	telthread->source=1;
	//Tcl_SetResult(interp,"",TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	libtel_sleep(telthread->after+500); // risqué !
	my_pthread_mutex_lock(&mutex);
	Tcl_SetResult(interp,telthread->loop_error,TCL_VOLATILE);
   my_pthread_mutex_unlock(&mutex);

	return TCL_OK;
}

int cmdTelLoopError(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   my_pthread_mutex_lock(&mutex);
	Tcl_SetResult(interp,telthread->loop_error,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelLoopEval(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   if (argc<3) {
   	sprintf(ligne,"usage: %s %s command_line",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   my_pthread_mutex_lock(&mutex);
	strcpy(telthread->eval_command_line,argv[2]);
	sprintf(ligne,"Result stored in %s loopresult",argv[0]);
	Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelLoopResult(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   my_pthread_mutex_lock(&mutex);
	Tcl_SetResult(interp,telthread->eval_result,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelHaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],ligne2[2256];
   int result = TCL_OK;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state|?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         if (argc>=4) {
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 0]",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->ha0=atof(Tcl_GetStringResult(interp));
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 1] 90",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->dec0=atof(Tcl_GetStringResult(interp));
				tel->hadec_goto_blocking=0;
				result=mytel_hadec_init(tel);
				Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         } else {
            sprintf(ligne,"Usage: %s %s %s {angle_ra angle_dec}",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
			result=mytel_hadec_coord(tel,ligne);
			if ( result == TCL_OK) {                     
            sprintf(ligne2,"list [mc_angle2hms [lindex {%s} 0] 360 zero 2 auto string] [mc_angle2dms [lindex {%s} 1] 90 zero 1 + string]",ligne,ligne); 
				Tcl_Eval(interp,ligne2);
            Tcl_SetResult(interp,(char*)Tcl_GetStringResult(interp),TCL_VOLATILE);
            result = TCL_OK;
         }
      } else if (strcmp(argv[2],"goto")==0) {
         /* --- goto ---*/
         if (argc>=4) {
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 0]",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->ha0=atof(Tcl_GetStringResult(interp));
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 1] 90",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->dec0=atof(Tcl_GetStringResult(interp));
				result=mytel_hadec_goto(tel);
				Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         } else {
            sprintf(ligne,"Usage: %s %s %s {angle_ra angle_dec}",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}
