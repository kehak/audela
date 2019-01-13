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
 *   structure pour les fonctions etendues
 */
char *tel_longformat[] = {
   "on",
   "off",
   NULL
};

int cmdTelChoiceController(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   if((argc!=2)) {
      sprintf(ligne,"Usage: %s %s One argument is required ",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
	  tel->choice_controler = atoi(argv[2]);

      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}


int cmdTelsocket_readTelescopeNotificationSocket(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
	socket_readTelescopeNotificationSocket(tel,0);
	sprintf(ligne,"");
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}


int cmdTelDisplayCoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK;
	/*
   struct telprop *tel;
   int returnCode;
   int moveCode;
   int slewCode;
   char raCalage;
   char decCalage;
   char raBrut[NOTIFICATION_MAX_SIZE];
   char decBrut[NOTIFICATION_MAX_SIZE];
   char ra[NOTIFICATION_MAX_SIZE];
   char dec[NOTIFICATION_MAX_SIZE];
   char command[NOTIFICATION_MAX_SIZE];
   char response[NOTIFICATION_MAX_SIZE];

   tel = (struct telprop*)clientData;

   sprintf(command,"!RADEC COORD 2 @\n" );
   result = socket_writeTelescopeCommandSocket(tel,command,response);
   if ( result == 0 ) {
		int readValue = sscanf(response,"!RADEC COORD %d %s %s @", &returnCode, ra, dec);
	} else {
      strcpy(ra,"00h00m00.00s");
		strcpy(dec,"+00d00m00.00s");
		returnCode=5; // AK a verifier
	}







	//tel->raBrut, tel->decBrut tel->radec_model_enabled

	//returnCode, ra, dec, raBrut, decBrut, raCalage, decCalage, tel->radec_model_enabled); 
*/


	sprintf(ligne,"");
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdTelFilter(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?stop|move|coord|init? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"max")==0) {
         if (argc == 3) {
            double maxDelay; 
            tel_filter_getMax(tel,&maxDelay);
            sprintf(ligne, "%f",maxDelay);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         } else if (argc==4) {
            tel_filter_setMax(tel,atoi(argv[3]));
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init number",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         // --- coord : retourne le % d'attenuation, 
         tel_filter_coord(tel,ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"extremity")==0) {
         // --- extremity : retourne l'etat des butees (MIN MED MAX)
         tel_filter_extremity(tel,ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"move")==0) {
         // --- move 
         if (argc==4) {
            result = tel_filter_move(tel,argv[3]);
				if (result!=0) {
					Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
					result = TCL_ERROR;
				} else {
	            Tcl_SetResult(interp,"",TCL_VOLATILE);
				}
         } else {
            sprintf(ligne,"Usage: %s %s move +|- ",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         // --- stop 
         tel_filter_stop(tel);
         strcpy(ligne,"");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else {
         //--- sub command not found 
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdTelChoiceControler(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop*)clientData;
   if (argc>=3) {
		tel->choice_controler = atoi( argv[2] );
		if (tel->choice_controler<0) {
			tel->choice_controler = 0;
		}
		if (tel->choice_controler>1) {
			tel->choice_controler = 1;
		}
	}
	if (tel->choice_controler==0) {
		sprintf(ligne,"0 DAQmx");
	} else {
		sprintf(ligne,"1 Beckhoff");
	}
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
int cmdTelCorrect(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   char   alphaDirection[2];
   double alphaDistance;
   char   deltaDirection[2];
   double deltaDistance;
   
   tel = (struct telprop *)clientData;
   if(argc!=7) {
      sprintf(ligne,"Usage: %s %s {e|w|} distanceAlpha {n|s} distanceDelta speed",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      switch(argv[2][0]) {
      case 'e':
      case 'E':
         alphaDirection[0] = 'E';
         alphaDirection[1] =  0;
         break;
      case 'w':
      case 'W':
         alphaDirection[0] = 'W';
         alphaDirection[1] =  0;
         break;
      default:
         sprintf(ligne,"Usage: %s %s direction time\nalpahaDirection shall be e|w",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if (Tcl_GetDouble(interp, argv[3], &alphaDistance) != TCL_OK) {
         sprintf(ligne,"Usage: %s %s distance \nalphaDistance shall be a decimal number",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }
      switch(argv[4][0]) {
      case 'n':
      case 'N':
         deltaDirection[0] = 'N';
         deltaDirection[1] =  0;
         break;
      case 's':
      case 'S':
         deltaDirection[0]= 'S';
         deltaDirection[1]=  0;
         break;
      default:
         sprintf(ligne,"Usage: %s %s direction time\ndirection shall be n|s",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }

      if (Tcl_GetDouble(interp, argv[5], &deltaDistance) != TCL_OK) {
         sprintf(ligne,"Usage: %s %s distance \ndistance shall be a decimal number",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }
      if (Tcl_GetDouble(interp, argv[6], &tel->radec_move_rate) != TCL_OK) {
         sprintf(ligne,"Usage: %s %s speed \nspeed shall be a decimal number between 0.0 and 1.0",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         return TCL_ERROR;
      }

      // j'applique la correction
      if ( mytel_correct(tel,alphaDirection,alphaDistance,deltaDirection,deltaDistance) == 0 ) {
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      } else {
         Tcl_SetResult(interp,tel->msg,TCL_VOLATILE);
         return TCL_ERROR;
      }
   }
   return TCL_OK;
}
*/


/*
 * -----------------------------------------------------------------------------
 *  cmdTelSendCommand()
 *
 *  envoie une commande a la carte USB 
 *  La command est un octet. Chque bit correspond a un bit du port
 *     bit 0 => line0
 *     bit 1 => line1
 *     bit 2 => line2
 *     bit 3 => line3
 *     bit 4 => line4
 *     bit 5 => line5
 *     bit 6 => line6
 *     bit 7 => line7
 *
 * -----------------------------------------------------------------------------
 */
/*
int cmdTelSendCommand(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int retour;
   char *usage= "Usage: %s %s ?command? ";
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if(argc!=3) {
      sprintf(ligne,usage,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      int result;
      int command;
      if (Tcl_GetInt(interp, argv[2], &command) != TCL_OK) {
	      sprintf(ligne,"Usage: %s %s command \n command shall be an integer between 0 and 7",argv[0],argv[1]);
	      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	      return TCL_ERROR;
      }
      if ( command < 0 || command > 255) {
	      sprintf(ligne,"Usage: %s %s command \n command shall be an integer between 0 and 255",argv[0],argv[1]);
	      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	      return TCL_ERROR;
      }

      result = mytel_sendCommand(tel, command);
      if ( result == 1 ) {
         Tcl_SetResult(interp, tel->msg, TCL_VOLATILE);
         retour = TCL_ERROR;
      } else {
         retour = TCL_OK;
      }
   }
   return retour;
}
*/

