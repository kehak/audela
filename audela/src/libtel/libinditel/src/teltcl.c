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
 *   structure pour les fonctions �tendues
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

int cmdTelRadecInitAdditional(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;

   /* --- init ---*/
   if (argc>=3) {
      /* - call the pointing model if exists -*/
      sprintf(ligne,"set libtel(radec) {%s}",argv[2]);
      Tcl_Eval(interp,ligne);
      if (strcmp(tel->model_cat2tel,"")!=0) {
         sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[2]);
         Tcl_Eval(interp,ligne);
      }
      Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
      strcpy(ligne,Tcl_GetStringResult(interp));
      /* - end of pointing model-*/
      libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
      /* - sends specific GEMINI command for updating internal TPOINT model */
      mytel_radec_init_additional(tel);
   } else {
      sprintf(ligne,"Usage: %s %s {angle_ra angle_dec}",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   }

   result = TCL_OK;
   return result;
}

int cmdTelCorrect(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   char *direction;
   int duration;

   tel = (struct telprop *)clientData;
   if(argc!=4) {
      sprintf(ligne,"Usage: %s %s {n,e,w,s} {0...9999}",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      switch(argv[2][0]) {
      case 'n':
      case 'N':
	 direction = "n";
	 break;
      case 'e':
      case 'E':
	 direction = "e";
	 break;
      case 'w':
      case 'W':
	 direction = "w";
	 break;
      case 's':
      case 'S':
	 direction = "s";
	 break;
      default:
	 sprintf(ligne,"Usage: %s %s direction time\ndirection shall be n|e|w|s",argv[0],argv[1]);
	 Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	 return TCL_ERROR;
      }
      if (Tcl_GetInt(interp, argv[3], &duration) != TCL_OK) {
	 sprintf(ligne,"Usage: %s %s direction time\ntime shall be an integer between 0 and 9999",argv[0],argv[1]);
	 Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	 return TCL_ERROR;
      }
      if ((duration<0)||(duration>9999)) {
	 sprintf(ligne,"Usage: %s %s direction time\ntime shall be between 0 and 9999",argv[0],argv[1]);
	 Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	 return TCL_ERROR;
      }
      mytel_correct(tel,direction,duration);
   }
   return TCL_OK;
}


/*
 * -----------------------------------------------------------------------------
 *  cmdTelSendCommand()
 *
 *  envoie une commande qu
 *
 * -----------------------------------------------------------------------------
 */
int cmdTelSendCommand(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int retour;
   char *usage= "Usage: %s %s ?command? ?returnType:none|ok|sharp?";
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if(argc!=4) {
      sprintf(ligne,usage,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      int returnType = -1;

      if ( strcmp(argv[3],"none")==0) {
         returnType =0;
      } else if (strcmp(argv[3],"ok")==0) {
         returnType =1;
      } else if (strcmp(argv[3],"sharp")==0) {
         returnType =2;
      }

      if (returnType == -1 ) {
         sprintf(ligne,"%s . Error: bad return type %s ",usage, argv[3]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
      } else {
         int result;
         char response[1024];
         result = mytel_sendLX(tel, returnType, response, argv[2]);
         if ( result == 1 ) {
            Tcl_SetResult(interp, response, TCL_VOLATILE);
            retour = TCL_OK;
         }
		else {
            // le libelle de l'erreur est dans le parametre response
            Tcl_SetResult(interp, response, TCL_VOLATILE);
            retour = TCL_ERROR;
         }
      }
   }
   return retour;
}

