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
char *tel_longformat[] = {
   "on",
   "off",
   NULL
};




int cmdTelLongFormat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0,comok=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      comok=1;
      pb=0;
   } else {
      if (strcmp(argv[2],tel_longformat[0])==0) {
         tel->longformatindex=0;
         comok=mytel_set_format(tel,tel->longformatindex);
         pb=0;
      } else if (strcmp(argv[2],tel_longformat[1])==0) {
         tel->longformatindex=1;
         comok=mytel_set_format(tel,tel->longformatindex);
         pb=0;
      } else {
         pb=1;
      }
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s %s|%s",argv[0],argv[1],tel_longformat[0],tel_longformat[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ligne,"");
      if (comok==0) {
         Tcl_SetResult(interp,"-1",TCL_VOLATILE);
      } else {
         if (tel->longformatindex==0) {
            sprintf(ligne,"%s",tel_longformat[0]);
         } else if (tel->longformatindex==1) {
            sprintf(ligne,"%s",tel_longformat[1]);
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

int cmdTelTempo(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,pb=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if((argc!=2)&&(argc!=3)) {
      pb=1;
   } else if(argc==2) {
      pb=0;
   } else {
      pb=0;
      tel->tempo=(int)fabs((double)atoi(argv[2]));
   }
   if (pb==1) {
      sprintf(ligne,"Usage: %s %s ?ms?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne,"%d",tel->tempo);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

int cmdTelVersion(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
	sprintf(ligne,"{version %f} {azmra_motor %f} {altdec_motor %f} {gps_unit %f} {rtc %f}",tel->version,tel->device_azmra_motor_version,tel->device_altdec_motor_version,tel->device_gps_unit_version,tel->device_rtc_version);
	Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}
