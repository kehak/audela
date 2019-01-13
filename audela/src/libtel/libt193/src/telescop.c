/* telescop.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel Pujol
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
// @version  $Id: telescop.c,v 1.32 2011-02-13 15:37:44 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <sys/timeb.h>		// pour timer 
#include <pthread.h>       // pcreate_thread()

#include <stdio.h>
#include <NIDAQmx.h>       // API pour driver NI-DAQmx (National Intrument)
#include "telescop.h"
#include "socketT193.h"
#include "coordserver.h"


#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"T193",    /* telescope name */
    "t193",    /* protocol name */
    "t193",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
  	 1.        /* default focal lenght of optic system */
   },
};



// variables locales

// fonctions locales
void mytel_logConsole(struct telprop *tel, char *messageFormat, ...) ;
int mytel_readUsbCard(struct telprop *tel, unsigned char *notification);
int mytel_getBit(struct telprop *tel, unsigned char notification, int numbit);
void mytel_startTimer(struct telprop *tel);
double mytel_getTimer(struct telprop *tel);
double mytel_stopTimer(struct telprop *tel);
int mytel_sendUsbCommandTelescop(struct telprop *tel, int command);
int mytel_sendCommandFilter(struct telprop *tel, int command);

int mytel_setRadecNotification(struct telprop *tel, int mode);
int mytel_setFocusNotification(struct telprop *tel, int mode);
void mytel_processNotification(struct telprop *tel, char * notification);
const char * mytel_getControlInterfaceLabelError(int numMessage) ;
int mytel_checkControlInterfaceResponse(struct telprop *tel, char *fonction, char *command, char *response, int returnCode, int requiredValue, int readValue);

//codes retours avec l'interface de controle
#define BACKCMD_RECEIVED	  0 // Commande prise en compte : acquittement d'envoi de commande à la PMAC (sans erreur)
#define BACKCMD_COMPLETED	  1 // Commande terminée        : acquittement de fin de commande sur la PMAC (sans erreur)
#define BACKCMD_UNKNOWN		  2 // Commande inconnue ou erreur de paramètre ou erreur de type
#define BACKCMD_ERRREFUSED	  3 // Commande refusée (mouvement en cours, etc.)
#define BACKCMD_ERRCOMM		  4 // Accès PMAC impossible
#define BACKCMD_ERRMOTOR	  5 // Problème moteur
#define BACKCMD_ERRLIM		  6 // Butée atteinte (option)
#define BACKCMD_ERRCONTROL	  7 // Couple moteur dépassé/erreur poursuite (option)
#define BACKCMD_MOTORSTOPPED  8 // Moteur déjà arrêté (commande STOP)

#define BACKCMD_BAD_PARAM_NUMBER 101 // nombre de parametres incorrect
#define BACKCMD_CAT2TEL_ERROR 102  


/**
 * mytel_getControlInterfaceLabelError 
 *   retoune le libellé d'un message d'erreur de l'interface de controle
 * @param tel  
 * @param messageFormat chaine de formatage du message suivi d'un nombre variable de parametres
 * @return  void
 */
const char * mytel_getControlInterfaceLabelError(int numMessage) {

   switch (numMessage) {
      case BACKCMD_RECEIVED :
         return "OK";
      case BACKCMD_COMPLETED :	
         return "Acquittement de fin de commande sur la PMAC (sans erreur)";
      case BACKCMD_UNKNOWN	:	  
         return "Commande inconnue ou erreur de paramètre ou erreur de type )";
      case BACKCMD_ERRREFUSED :	 
          return "Commande refusée (mouvement en cours, etc.)";
      case BACKCMD_ERRCOMM	:	
          return "Accès PMAC impossible";
      case BACKCMD_ERRMOTOR :	 
          return "Problème moteur";
      case BACKCMD_ERRLIM :		 
          return "Butée atteinte";
      case BACKCMD_ERRCONTROL :	 
          return "Couple moteur dépassé/erreur poursuite";
      case BACKCMD_MOTORSTOPPED : 
          return "Moteur déjà arrêté (commande STOP)";
      default:
         return "code inconnu";
   }   
}
/* noms des fichier LOG pour les coirrections de guidage */
char lognamecorrA[256], lognamecorrD[256];

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage du telescope      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque telescope.   */
/* et sont appelees par libtel.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int tel_init(struct telprop *tel, int argc, char **argv)
/* --------------------------------------------------------- */
/* --- tel_init permet d'initialiser les variables de la --- */
/* --- structure 'telprop'                               --- */
/* --- specifiques a ce telescope.                       --- */
/* --------------------------------------------------------- */
/* --- called by : ::tel::create                         --- */
/* --------------------------------------------------------- */
{

   int         error=0;
	uInt32      notification=0xffffffff;
   char        hpcom[128]={'\0'};
   char        usbCardName[128]     ="Dev1";    // ces valeurs par defaut seront ecrasées par les paramètres optionels
   char        usbTelescopPort[128] ="port0";
   char        usbFilterPort[128]   ="port1";
   int         i;
   int         result = 0;
   char s[1024],ssres[1024];
   char ss[256],ssusb[256];
   char tu[20];
   int k;

   FILE *flog,*flogCorrA,*flogCorrD;
   flog=fopen("mouchard_protocole_T193.txt","wt");
   fclose(flog);

   // 2 fichiers Log des corrections de guidage en Alpha et Delta
   strcpy(lognamecorrA,"");
   strcpy(lognamecorrD,"");
   strcpy(ss, "clock format [ clock seconds ] -format %Y-%m-%d_T%H-%M-%S -timezone :UTC "); 
   result = Tcl_Eval(tel->interp,ss);
   if ( result == TCL_OK) {
      strcpy(tu, Tcl_GetStringResult(tel->interp));
      sprintf(lognamecorrA, "mouchard_correction_alpha_T193-%s.txt", tu);
      sprintf(lognamecorrD, "mouchard_correction_delta_T193-%s.txt", tu);
   } else {
      strcpy(lognamecorrA, "mouchard_correction_alpha_T193-00h00m00s.txt");
      strcpy(lognamecorrD, "mouchard_correction_delta_T193-00h00m00s.txt");
   }
   flogCorrA=fopen(lognamecorrA,"wt");
   fclose(flogCorrA);
   flogCorrD=fopen(lognamecorrD,"wt");
   fclose(flogCorrD);
   flogCorrA=fopen(lognamecorrA,"at");
   fprintf(flogCorrA,"%s\t\t\t%s\t%s\n","date","direction (E|W)","correction ALPHA (arcsec)");
   fclose(flogCorrA);
   flogCorrD=fopen(lognamecorrD,"at");
   fprintf(flogCorrD,"%s\t\t\t%s\t%s\n","date","direction (N|S)","correction DELTA (arcsec)");
   fclose(flogCorrD);

   // je configure les fonctions specifiques du telescope
   TEL_DRV.tel_sendPulseDistance =  tel_radec_correct;
   TEL_DRV.tel_getRadecGuidingState = tel_get_radec_guiding;
   TEL_DRV.tel_setRadecGuidingState = tel_set_radec_guiding;
   // j'intialise les variables
   strcpy(tel->channel , "");
   tel->outputTelescopTaskHandle = 0;
   tel->outputFilterTaskHandle = 0;
   tel->inputFilterTaskHandle = 0;   
   tel->outputTelescopNotification = 255;
   tel->outputFilterNotification = 255;
   tel->consoleLog = 0;    
   tel->filterMaxDelay = 10;  
   tel->filterCurrentDelay = 0; 
   tel->startTime = 0.0;
   tel->filterCommand = -1;   // L'indicateur de mouvement du filtre vaut :
                              //    -1=pas de mouvement en cours, 
                              //    tel->decreaseFilterRelay = mouvement "-" en cours
                              //    tel->increaseFilterRelay = mouvement "+" en cours

   tel->northRelay         = 0;
   tel->southRelay         = 1;
   tel->estRelay           = 2;
   tel->westRelay          = 3;
   tel->enabledRelay       = 4;
   tel->decreaseFilterRelay = 0;
   tel->increaseFilterRelay = 1;
   tel->minDetectorFilterInput = 2;
   tel->maxDetectorFilterInput = 3;

   tel->telescopeCommandSocket = NULL;
   tel->telescopeNotificationSocket = NULL;
   tel->telescopeNotificationThread = NULL;
   strcpy(tel->telescopeHost,"");
   tel->telescopeCommandPort = 0;
   tel->telescopeNotificationPort = 0;
	tel->choice_controler = 1;

   strcpy(tel->raBrut,"00h00m00.00s"); 
   strcpy(tel->decBrut, "+00d00m00.00s"); 
   //tel->radecNotification = 0;
   tel->radec_motor = 0; 
   tel->radecIsMoving = 0;
   tel->focus_goto_blocking = 0;
   tel->focusCurrentPosition = 0;

   // je lis les parametres optionels
   for (i=3;i<argc-1;i++) {
	   if (strcmp(argv[i],"-hpcom")==0) {
			   strcpy(hpcom, argv[i+1]);
      }
	   if (strcmp(argv[i],"-usbCardName")==0) {
			   strcpy(usbCardName, argv[i+1]);
		}
	   if (strcmp(argv[i],"-usbTelescopPort")==0) {
			   strcpy(usbTelescopPort, argv[i+1]);
		}
	   if (strcmp(argv[i],"-usbFilterPort")==0) {
			   strcpy(usbFilterPort, argv[i+1]);
		}
	   if (strcmp(argv[i],"-northRelay")==0) {
         tel->northRelay = atoi(argv[i+1]); 
         if ( tel->northRelay < 0 && tel->northRelay > 7 ) {
            sprintf(tel->msg,"northRelay=%d Must be beetween 0 and 7", tel->northRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-southRelay")==0) {
         tel->southRelay = atoi(argv[i+1]); 
         if ( tel->southRelay < 0 && tel->southRelay > 7 ) {
            sprintf(tel->msg,"southRelay=%d Must be beetween 0 and 7", tel->southRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-estRelay")==0) {
         tel->estRelay = atoi(argv[i+1]); 
         if ( tel->estRelay < 0 && tel->estRelay > 7 ) {
            sprintf(tel->msg,"estRelay=%d Must be beetween 0 and 7", tel->estRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-westRelay")==0) {
         tel->westRelay = atoi(argv[i+1]); 
         if ( tel->westRelay < 0 && tel->westRelay > 7 ) {
            sprintf(tel->msg,"westRelay=%d Must be beetween 0 and 7", tel->westRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-enabledRelay")==0) {
         tel->enabledRelay = atoi(argv[i+1]); 
         if ( tel->enabledRelay < 0 && tel->enabledRelay > 7 ) {
            sprintf(tel->msg,"enabledRelay=%d Must be beetween 0 and 7", tel->enabledRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-decreaseFilterRelay")==0) {
         tel->decreaseFilterRelay = atoi(argv[i+1]); 
         if ( tel->decreaseFilterRelay < 0 && tel->decreaseFilterRelay > 7 ) {
            sprintf(tel->msg,"decreaseFilterRelay=%d Must be beetween 0 and 7", tel->decreaseFilterRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-increaseFilterRelay")==0) {
         tel->increaseFilterRelay = atoi(argv[i+1]); 
         if ( tel->increaseFilterRelay < 0 && tel->increaseFilterRelay > 7 ) {
            sprintf(tel->msg,"increaseFilterRelay=%d Must be beetween 0 and 7", tel->increaseFilterRelay );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-minDetectorFilterInput")==0) {
         tel->minDetectorFilterInput = atoi(argv[i+1]); 
         if ( tel->minDetectorFilterInput < 0 && tel->minDetectorFilterInput > 7 ) {
            sprintf(tel->msg,"minDetectorFilterInput=%d Must be beetween 0 and 7", tel->minDetectorFilterInput );
            return 1;
         }
      }
	   if (strcmp(argv[i],"-maxDetectorFilterInput")==0) {
         tel->maxDetectorFilterInput = atoi(argv[i+1]); 
         if ( tel->maxDetectorFilterInput < 0 && tel->maxDetectorFilterInput > 7 ) {
            sprintf(tel->msg,"maxDetectorFilterInput=%d Must be beetween 0 and 7", tel->maxDetectorFilterInput );
            return 1;
         }
      }

	   if (strcmp(argv[i],"-filterMaxDelay")==0) {
         tel_filter_setMax(tel,atof(argv[i+1])); 
      }
  	   if (strcmp(argv[i],"-ethernetHost")==0) {
	      strcpy(tel->telescopeHost, argv[i+1]);
         if ( strlen(tel->telescopeHost) == 0 ) {
            sprintf(tel->msg,"telescopeHost=%s is empty", tel->telescopeHost );
            return 1;
         }
      }
  	   if (strcmp(argv[i],"-telescopeCommandPort")==0) {
	      tel->telescopeCommandPort = atoi(argv[i+1]);
         if ( tel->telescopeCommandPort == 0 ) {
            sprintf(tel->msg,"telescopeCommandPort=%d is null", tel->telescopeCommandPort );
            return 1;
         }
      }
  	   if (strcmp(argv[i],"-telescopeNotificationPort")==0) {
	      tel->telescopeNotificationPort = atoi(argv[i+1]);
         if ( tel->telescopeNotificationPort == 0 ) {
            sprintf(tel->msg,"telescopeNotificationPort=%d is null", tel->telescopeNotificationPort );
            return 1;
         }
      }

   }

   if ( result == 1 ) {
      // j'arrete l'init s'il y a eu une erreur
      return 1;
   }

   // argv2 contient le type de connexion du telescope HP1000 ou PC 
   if ( strcmp(argv[2], "HP1000") == 0 ) {
      if ( strcmp(usbCardName, "simulation") !=  0 ) {
			if (tel->choice_controler==0) {
				//DAQmxGetSysDevNames

				// je verifie que la carte est presente 
				if( ! DAQmxFailed(error) ) {
					error = DAQmxSelfTestDevice(usbCardName);
				}

				// J'ouvre la connexion de la carte USB-6501
				// je cree la tache du telescope en ecriture
				if( ! DAQmxFailed(error) ) {
					error = DAQmxCreateTask("",&tel->outputTelescopTaskHandle);
				}

				if( ! DAQmxFailed(error) ) {
					char lines[256];

					sprintf(lines, "%s/%s/line%d, %s/%s/line%d, %s/%s/line%d, %s/%s/line%d, %s/%s/line%d",
						  usbCardName,usbTelescopPort, tel->northRelay,
						  usbCardName,usbTelescopPort, tel->southRelay,
						  usbCardName,usbTelescopPort, tel->estRelay,
						  usbCardName,usbTelescopPort, tel->westRelay,
						  usbCardName,usbTelescopPort, tel->enabledRelay);
					error = DAQmxCreateDOChan(tel->outputTelescopTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
				}

				// je cree la tache de l'attenuateur en ecriture
				if( ! DAQmxFailed(error) ) {
   				error = DAQmxCreateTask("",&tel->outputFilterTaskHandle);
				}
				if( ! DAQmxFailed(error) ) {
					char lines[256];

					sprintf(lines, "%s/%s/line%d, %s/%s/line%d",
						  usbCardName,usbFilterPort, tel->decreaseFilterRelay,
						  usbCardName,usbFilterPort, tel->increaseFilterRelay);
					error = DAQmxCreateDOChan(tel->outputFilterTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
				}

				// je cree la tache de l'attenuateur en lecture
				if( ! DAQmxFailed(error) ) {
					// je cree la tache de lecture 
   				error = DAQmxCreateTask("",&tel->inputFilterTaskHandle);
				}

				if( ! DAQmxFailed(error) ) {
					char lines[256];
					// je crée le canal en lecture
					sprintf(lines, "%s/%s/line%d, %s/%s/line%d",
						  usbCardName,usbFilterPort, tel->minDetectorFilterInput,
						  usbCardName,usbFilterPort, tel->maxDetectorFilterInput);
					error = DAQmxCreateDIChan(tel->inputFilterTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
				}
	         
				// je demarre les taches
				if( ! DAQmxFailed(error) ) {
					error = DAQmxStartTask(tel->outputTelescopTaskHandle);
				}
				// je demarre les taches
				if( ! DAQmxFailed(error) ) {
					error = DAQmxStartTask(tel->outputFilterTaskHandle);
				}
				if( ! DAQmxFailed(error) ) {
					// je demarre la tache de lecture
					error = DAQmxStartTask(tel->inputFilterTaskHandle);
				}
				if( ! DAQmxFailed(error) ) {

					//  je met tous les bits à 1 (position de repos de la commande du télescope) 
					tel->outputTelescopNotification = 255;
					result = mytel_sendUsbCommandTelescop(tel , tel->outputTelescopNotification);

					//  je met tous les bits à 1 (position de repos de la commande de l'attenuateur) 
					tel->outputFilterNotification = 255;
					result = mytel_sendCommandFilter(tel , tel->outputFilterNotification);
				} else {
					char errBuff[2001]={'\0'};
					// je recupere le message d'erreur
					//DAQmxGetExtendedErrorInfo(errBuff,2000);
					DAQmxGetErrorString(error, errBuff, 2000);
					//sprintf(tel->msg, "DAQmx error %d", error);
					sprintf(tel->msg, "Device=%s %s",usbCardName, errBuff) ;
					result = 1;
				} 
			} else {
				tel->outputFilterTaskHandle=NULL;
				sprintf(s,"load libbeckhoffadstcl.dll");
				// on envoie la commande de load libbeckhofftcl
				error=Tcl_Eval(tel->interp,s);
				// on traite l'erreur
				if ( error == TCL_ERROR ) {
					strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
					result = 1;
				}
				sprintf(s,"beckhoff_ads_open");
				// on envoie la commande dans la libbeckhofftcl
				error=Tcl_Eval(tel->interp,s);
				// on traite l'erreur
				if ( error == TCL_ERROR ) {
					strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
					result = 1;
				}
				tel->outputFilterTaskHandle=(void*)1;
			}
      } else {
         //simulation de la carte USB
         mytel_logConsole(tel, "simul open %s OK",usbCardName);
      }

      if ( result == 1 ) {
         // j'arrete l'init s'il y a eu une erreur
   	   tel_close(tel);
         return 1;
      }

 
      // j'ouvre la connexion avec le port serie du HP1000 pour la reception des ccordonnees
      if ( strlen(hpcom) > 0 ) {
         strcpy(ss,hpcom);
         sprintf(s,"string range [string toupper %s] 0 2",ss);
         Tcl_Eval(tel->interp,s);
         strcpy(s,Tcl_GetStringResult(tel->interp));
         if (strcmp(s,"COM")==0) {
            sprintf(s,"string range [string toupper %s] 3 end",ss);
            Tcl_Eval(tel->interp,s);
            strcpy(s,Tcl_GetStringResult(tel->interp));
            k=(int)atoi(s);
            Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
            strcpy(s,Tcl_GetStringResult(tel->interp));
            if (strcmp(s,"Linux")==0) {
               sprintf(ss,"/dev/ttyS%d",k-1);
               sprintf(ssusb,"/dev/ttyUSB%d",k-1);
            }
         }
         /* --- open the port and record the channel name ---*/
         sprintf(s,"open \"%s\" r+",ss);
         if (Tcl_Eval(tel->interp,s)!=TCL_OK) {
            strcpy(ssres,Tcl_GetStringResult(tel->interp));
            Tcl_Eval(tel->interp,"set ::tcl_platform(os)");
            strcpy(ss,Tcl_GetStringResult(tel->interp));
            if (strcmp(ss,"Linux")==0) {
               /* if ttyS not found, we test ttyUSB */
               sprintf(ss,"open \"%s\" r+",ssusb);
               if (Tcl_Eval(tel->interp,ss)!=TCL_OK) {
                  strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
                  result = 1;
               }
            } else {
               strcpy(tel->msg,ssres);
               result = 1;
            }
         }
         strcpy(tel->channel,Tcl_GetStringResult(tel->interp));
         
         // je lance la boucle de lecture permanente des coordonnées

         /*
         # 19200 : vitesse de transmission (bauds)
         # 0 : 0 bit de parité
         # 8 : 8 bits de données
         # 1 : 1 bits de stop
         */
         sprintf(s,"fconfigure %s -mode \"19200,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); 
         mytel_tcleval(tel,s);
      }
   } else if ( strcmp(argv[2], "ETHERNET") == 0 ) { 
      if ( strcmp(usbCardName, "simulation") !=  0 ) {
			if (tel->choice_controler==0) {
				//DAQmxGetSysDevNames

				// je verifie que la carte est presente 
				if( ! DAQmxFailed(error) ) {
					error = DAQmxSelfTestDevice(usbCardName);
				}

				// J'ouvre la connexion de la carte USB-6501
				// je cree la tache de l'attenuateur en ecriture
				if( ! DAQmxFailed(error) ) {
   				error = DAQmxCreateTask("",&tel->outputFilterTaskHandle);
				}
				if( ! DAQmxFailed(error) ) {
					char lines[256];

					sprintf(lines, "%s/%s/line%d, %s/%s/line%d",
						  usbCardName,usbFilterPort, tel->decreaseFilterRelay,
						  usbCardName,usbFilterPort, tel->increaseFilterRelay);
					error = DAQmxCreateDOChan(tel->outputFilterTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
				}

				// je cree la tache de l'attenuateur en lecture
				if( ! DAQmxFailed(error) ) {
					// je cree la tache de lecture 
   				error = DAQmxCreateTask("",&tel->inputFilterTaskHandle);
				}

				if( ! DAQmxFailed(error) ) {
					char lines[256];
					// je crée le canal en lecture
					sprintf(lines, "%s/%s/line%d, %s/%s/line%d",
						  usbCardName,usbFilterPort, tel->minDetectorFilterInput,
						  usbCardName,usbFilterPort, tel->maxDetectorFilterInput);
					error = DAQmxCreateDIChan(tel->inputFilterTaskHandle,lines,"", DAQmx_Val_ChanForAllLines  );  //DAQmx_Val_ChanForAllLines DAQmx_Val_ChanPerLine
				}

				// je demarre les taches
				if( ! DAQmxFailed(error) ) {
					error = DAQmxStartTask(tel->outputFilterTaskHandle);
				}
				if( ! DAQmxFailed(error) ) {
					// je demarre la tache de lecture
					error = DAQmxStartTask(tel->inputFilterTaskHandle);
				}
				if( ! DAQmxFailed(error) ) {
					//  je met tous les bits à 1 (position de repos de la commande de l'attenuateur) 
					tel->outputFilterNotification = 255;
					result = mytel_sendCommandFilter(tel , tel->outputFilterNotification);
				} else {
					char errBuff[2001]={'\0'};
					// je recupere le message d'erreur
					//DAQmxGetExtendedErrorInfo(errBuff,2000);
					DAQmxGetErrorString(error, errBuff, 2000);
					//sprintf(tel->msg, "DAQmx error %d", error);
					sprintf(tel->msg, "Device=%s %s",usbCardName, errBuff) ;
					result = 1;
				} 
			} else {
				tel->outputFilterTaskHandle=NULL;
				sprintf(s,"load libbeckhoffadstcl.dll");
				// on envoie la commande de load libbeckhofftcl
				error=Tcl_Eval(tel->interp,s);
				// on traite l'erreur
				if ( error == TCL_ERROR ) {
					strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
					result = 1;
				}
				sprintf(s,"beckhoff_ads_open");
				// on envoie la commande dans la libbeckhofftcl
				error=Tcl_Eval(tel->interp,s);
				// on traite l'erreur
				if ( error == TCL_ERROR ) {
					strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
					result = 1;
				}
				//On met à 0 les variables d'incrementation et de decrementation. 
				sprintf(s,"beckhoff_ads_Stop_IncAtt ; beckhoff_ads_Stop_DecAtt");
				// on envoie la commande dans la libbeckhofftcl
				error=Tcl_Eval(tel->interp,s);
				// on traite l'erreur
				if ( error == TCL_ERROR ) {
				strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
				}
				tel->outputFilterTaskHandle=(void*)1;
			}
      } else {
         //simulation de la carte USB
         mytel_logConsole(tel, "simul open %s OK",usbCardName);
      }

      if ( result == 1 ) {
         // j'arrete l'init s'il y a eu une erreur
   	   tel_close(tel);
         return 1;
      }

      // j'ouvre la socket de commande du telescope
      result = socket_openTelescopeCommandSocket(tel, tel->telescopeHost, tel->telescopeCommandPort);


      // j'ouvre la socket de notification du telescope
      if ( result == 0 ) {
         result = socket_openTelescopeNotificationSocket(tel, tel->telescopeHost, tel->telescopeNotificationPort);
      }

      // je demande a recevoir les coordonnees en permanence 
      if ( result == 0 ) {         
         result = mytel_setRadecNotification(tel, 1);
      }

		// AK
   // je ferme la socket de notification du telescope 
   if ( tel->telescopeNotificationSocket != NULL ) {
      socket_closeTelescopeNotificationSocket(tel);
   }

      /*F.FILLION : PAS DE SUIVI AU DEMARRAGE
      // j'active le suivi
      if ( result == 0 ) {
         // attention, il faut mettre 0 tel->radec_motor pour activer le suivi
         tel->radec_motor = 0;
         result = tel_radec_motor(tel);
      }
		*/

      // j'initilise le serveur de coordonnees
	  // AK pb de plantage a resoudre avec tel1
      //socket_openCoordServerSocket(tel, 5028);

   } else {
      sprintf(tel->msg,"Invalid connection mode %s", argv[2]);
      result = 1;
   }

   if ( result == 1 ) {
      // s'il y a eu une erreur, je ferme tout 
   	tel_close(tel);
      return 1;
   } else {
      return 0;
   }

     return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
      return 1;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   char s[1024];
	int error;
	if (tel->choice_controler==0) {

		// je ferme la tache en ecriture du telescope sur la carte USB
 		if( tel->outputTelescopTaskHandle!=0 ) {
			DAQmxStopTask(tel->outputTelescopTaskHandle);
			DAQmxClearTask(tel->outputTelescopTaskHandle);
			tel->outputTelescopTaskHandle = 0;
		}

		// je ferme la tache en ecriture de l'attenuateur sur la carte USB
 		if( tel->outputFilterTaskHandle!=0 ) {
			DAQmxStopTask(tel->outputFilterTaskHandle);
			DAQmxClearTask(tel->outputFilterTaskHandle);
			tel->outputFilterTaskHandle = 0;
		}
		// je ferme la tache en lecture de l'attenuateur sur la carte USB
 		if( tel->inputFilterTaskHandle!=0 ) {
			DAQmxStopTask(tel->inputFilterTaskHandle);
			DAQmxClearTask(tel->inputFilterTaskHandle);
			tel->inputFilterTaskHandle = 0;
		}

	} else {
		//On arrete les variables d'incrementation et de decrementation. 
		sprintf(s,"beckhoff_ads_Stop_IncAtt ; beckhoff_ads_Stop_DecAtt");
		// on envoie la commande dans la libbeckhofftcl
		error=Tcl_Eval(tel->interp,s);
		// on traite l'erreur
		if ( error == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
		}
		//On ferme le port
		sprintf(s,"beckhoff_ads_close");
		// on envoie la commande dans la libbeckhofftcl
		error=Tcl_Eval(tel->interp,s);
		// on traite l'erreur
		if ( error == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
		}
		tel->outputFilterTaskHandle=(void*)0;

	}

   // je ferme le port de liaison série avec le HP1000
   if( strcmp(tel->channel,"") != 0 ) {
      char s[1024];
      sprintf(s,"close %s",tel->channel); mytel_tcleval(tel,s);
      strcpy(tel->channel,"");
   }   


   // je ferme la socket de commande du telescope
   if ( tel->telescopeCommandSocket != NULL ) {
      // j'arrete les notifications des coordonnees
      mytel_setRadecNotification(tel, 0);
      // je ferme la socket de commande
      socket_closeTelescopeCommandSocket(tel);
   }

   // je ferme la socket de notification du telescope 
   if ( tel->telescopeNotificationSocket != NULL ) {
      socket_closeTelescopeNotificationSocket(tel);
   }

   // je ferme la socket de notification des coordonnees 
   if ( tel->telescopeCoordServerSocket != NULL ) {
      socket_closeCoordServerSocket(tel);
   }

   return 0;
}



/////////////////////////////////////////////////////////////////////////
//
//  commandes RADEC de positionnement de la monture
//
/////////////////////////////////////////////////////////////////////////


/**
 * tel_radec_init
 *   rien a faire pour cette monture
 *
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope
 * @return 0=OK 1=erreur
 */
int tel_radec_init(struct telprop *tel)
{
   return 0;
}


/**
 * tel_radec_coord
 *   retourne les coordonnes alpha et delta
 *
 *
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope
 * @param result  coordonnees "00h00m00.00s +00d00m00s"
 * @return 0=OK 1=erreur
 */
int tel_radec_coord(struct telprop *tel,char *coord)
{
   int result;
   if (tel->telescopeCommandSocket != NULL) {
      if ( tel->radecIsMoving  == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!RADEC COORD 2 @\n" );
         result = socket_writeTelescopeCommandSocket(tel,command,response);
         if ( result == 0 ) {
            int returnCode;
            char ra[NOTIFICATION_MAX_SIZE];
            char dec[NOTIFICATION_MAX_SIZE];
            int readValue = sscanf(response,"!RADEC COORD %d %s %s @", &returnCode, ra, dec);
            result = mytel_checkControlInterfaceResponse(tel, "tel_radec_coord", command, response, returnCode, 3, readValue); 
            if (result == 0 ) {
               // je copie les coordonnees dans la variable de sortie
               sprintf(coord,"%s %s", ra, dec);
               result = 0;
            }
         }
      } else {
         // si le telescope est en mouvement, je retourne les coordonnees recuperees dans la derniere notification
         sprintf(coord,"%s %s", tel->raBrut, tel->decBrut);
         result = 0;
      }
   } else {
      // je retourne une reponse par defaut 
      strcpy(coord,"00h00m00.00s +00d00m00.00s");
      result = 0; 
   }
   return result;
}


//-------------------------------------------------------------
// mytel_setRadecNotification
//
// demande a recevoir les coordonnes sur la socket de notification
//
// @param tel   pointeur structure telprop
// @param mode  0 : arret de la notification des coordonnees radec
//              1 : marche de la notification des coordonnees radec
// @return 0 = OK,  1= erreur
//-------------------------------------------------------------
int mytel_setRadecNotification(struct telprop *tel, int mode )
{
   int result; 
   
   if ( tel->telescopeCommandSocket != 0 ) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      sprintf(command,"!RADEC COORD %d @\n", mode);
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!RADEC COORD %d @", &returnCode);
         result = mytel_checkControlInterfaceResponse(tel, "mytel_setRadecNotification", command, response, returnCode, 1, readValue);
         if (result == 0) {
            // je memorise l'etat des notifications (1=marche 0=arret)
            switch (mode) {
            case 0 : 
               //   tel->radecNotification = 0;
               break;
            case 1 : 
               //   tel->radecNotification = 1;
               break; 
            }                  
         }
      }
   } else {
      result = 0; 
   }
   return result;
}


int tel_radec_state(struct telprop *tel,char *text)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   sprintf(text,"");
   return 0;
}

/**
 * tel_radec_goto 
 *
 *   lance un goto vers les coordonnees tel->ra0 tel->dec0
 *   
 *   Si tel->radec_goto_blocking==1 alors attend que la fin du GOTO
 *   
 *   Si le modele de pointage est actif, ces coordonnes sont deja corrigees. 
 * 
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope            
 * @return 0=OK 1=erreur
 */
int tel_radec_goto(struct telprop *tel) {
	int result; 

   if (tel->telescopeCommandSocket != NULL) {
      char ligne[1024];
      char gotoRa[13];
      char gotoDec[14];
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      result = 0; 

      // je retourne un message d'erreur si le guidage automatique en cours
      if ( tel->radecGuidingState == 1 && result == 0) {
         sprintf(tel->msg, "GOTO ignoré car le guidage automatique est en cours.");
         result = 1; 
      }

      // je verifie s'il n'y a pas deja un mouvement en cours
      if ( tel->radecIsMoving != 0 && result == 0 ) {
         sprintf(tel->msg, "tel_radec_goto already moving");
         result = 1;          
      }

      if ( result == 0 ) {   
         // je convertis les coordonnees en chaine de caractere
         sprintf(ligne,"mc_angle2hms %.7f 360 zero 2 auto string",tel->ra0); 
         if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
            sprintf(tel->msg, "tel_radec_goto %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
            result = 1; 
         } else {
            strcpy(gotoRa,Tcl_GetStringResult(tel->interp));
            //F.FILLION : transforme "10h30m20s99" en "10h30m20.99s"
            gotoRa[8]  = '.';
            gotoRa[11] = 's';
            gotoRa[12] = '\0';
         } // gotoRa	= "10h30m20s99" => OK

         sprintf(ligne,"mc_angle2dms %.7f 90 zero 1 + string",tel->dec0);
         if ( mytel_tcleval(tel,ligne) == TCL_ERROR) {
            sprintf(tel->msg, "tel_radec_goto %s error: %s", ligne, Tcl_GetStringResult(tel->interp));
            result = 1; 
         } else {
            strcpy(gotoDec,Tcl_GetStringResult(tel->interp));
            //F.FILLION : transforme "+23d33m43s99" en "+23d33m43.99s"
            gotoDec[9]  = '.';
            gotoDec[12] = 's';
            gotoDec[13] = '\0';
         }
      }

      // j'envoi la commande GOTO
      if ( result == 0 ) {
         sprintf(command,"!RADEC GOTO %s %s @\n", gotoRa, gotoDec );
         result = socket_writeTelescopeCommandSocket(tel,command,response);
      }

      // je traite la reponse
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!RADEC GOTO %d @", &returnCode);
         result = mytel_checkControlInterfaceResponse(tel, "tel_radec_goto", command, response, returnCode, 1, readValue);
         if (result == 0) {
            // rien à faire 
         } else {
            // rien a faire. Le message d'erreur est deja dans tel->msg
         }
      } else {
         // rien a faire. Le message d'erreur est deja dans tel->msg
      }

      if ( result == 0 ) {
	      if (tel->radec_goto_blocking==1) {
            int foundEvent = 1 ;
            tel->radecIsMoving = 1;
            // j'attend la fin du mouvement (tel->moving est mis a jour par mytel_processNotification ) 
            while (tel->radecIsMoving == 1 ) {
               foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
            }
         }
      }
   } else {
      // cette fonction n'est pas implementee pour le HP1000
      result = 0;
   }
   return result;
}

/**
 * tel_radec_move 
 *
 *   Mouvements en alpha et delta en continu (voir 
 *   la direction est fournie en parametre
 *   la vitesse est dans tel->speed  (valeur entre 0.0 et 1.0)
 *
 * @param tel   pointeur d'une structure telprop contenant les attributs du telescope            
 * @param direction  direction= N S E W
 * @return 0=OK 1=erreur
 */
int tel_radec_move(struct telprop *tel,char *direction)
{
   int result = 0;

   if ( tel->outputTelescopTaskHandle != 0 ) {
      char mask; 
      int numbit;

      switch (tolower(direction[0])) {
         case 'n' : 
            numbit = tel->northRelay;
            break;
         case 's' : 
            numbit = tel->southRelay;
            break;
         case 'e' : 
            numbit = tel->estRelay;
            break;
         case 'w' : 
            numbit = tel->westRelay;
            break;
         default : 
            sprintf(tel->msg,"invalid direction %s",direction);
            return 1;
      }

      // je cree le masque de l'octet
      mask = 1 << numbit;
      // je force à 0 le bit correspondant 
      tel->outputTelescopNotification &= ~mask;
      result = mytel_sendUsbCommandTelescop(tel , tel->outputTelescopNotification);
   } else if (tel->telescopeCommandSocket != NULL) {
      char direction2;

      // je retourne un message d'erreur si le guidage automatique en cours
      if ( tel->radecGuidingState == 1 && result == 0 ) {
         sprintf(tel->msg, "Mouvement manuel ignoré car le guidage automatique est en cours.");
         result = 1; 
      }

      // je verifie s'il n'y a pas deja un mouvement en cours
      if ( tel->radecIsMoving != 0 && result == 0 ) {
         sprintf(tel->msg, "tel_radec_move already moving");
         result = 1;          
      }

      if ( result == 0 ) {
         // je convertis en majuscule
         direction2 = toupper(direction[0]);

         // je verifie la valeur
         switch (direction2) {
            case 'N' : 
            case 'S' : 
            case 'E' : 
            case 'W' : 
               result = 0; 
               break;
            default : 
               sprintf(tel->msg,"invalid direction %s",direction);
               result = 1;
         }
      }
      
      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         if ( tel->radec_move_rate == 0.0 ) {
            // vitesse de guidage
            sprintf(command,"!RADEC MOVE %c guidage @\n", direction2 );  
         } else if ( tel->radec_move_rate == 0.33 ) {
            // vitesse de centrage
            sprintf(command,"!RADEC MOVE %c centrage @\n", direction2 );
         } else if ( tel->radec_move_rate == 0.66 ) {
            // vitesse de centrage
            sprintf(command,"!RADEC MOVE %c centrage2 @\n", direction2 );
         } else {
            // par defaut vitesse de guidage
            sprintf(command,"!RADEC MOVE %c guidage @\n", direction2 );  
         }
		   //envoi du mouvement et recupération du code 0
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
            int returnDirection; 
            int readValue = sscanf(response,"!RADEC MOVE %d %c @", &returnCode, &returnDirection);
            result = mytel_checkControlInterfaceResponse(tel, "tel_radec_move", command, response, returnCode, 2, readValue);
         }
      }
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul radec move %s OK",direction);
      result = 0;
   }
   return result;
}

//-------------------------------------------------------------
// tel_radec_stop
//
// arret du mouvement en ascension droite (E ou W) ou en declinaison (N ou S)
// ou arret sur les deux axes (T)
//
// @param tel   pointeur structure telprop
// @param direction direction de la correction N,S, E, W ,T 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_radec_stop(struct telprop *tel,char *direction)
{
   int result ;

   if ( tel->outputTelescopTaskHandle != 0 ) {
      char mask; 
      int numbit;

      if ( strlen(direction) > 0 ) {
         // j'arrete le mouvement dans la direction precisee en parametre
         switch (tolower(direction[0])) {
            case 'n' : 
               numbit = tel->northRelay;
               break;
            case 's' : 
               numbit = tel->southRelay;
               break;
            case 'e' : 
               numbit = tel->estRelay;
               break;
            case 'w' : 
               numbit = tel->westRelay;
               break;
            default : 
               sprintf(tel->msg,"invalid direction %s",direction);
               return 1;
         }

         // je cree le masque 
         mask = 1 << numbit;
         // je force à 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;
      } else {
         // j'arrete le mouvement dans toutes les directions 

         // je cree le masque northRelay
         mask = 1 << tel->northRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;

         // je cree le masque 
         mask = 1 << tel->southRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;

         // je cree le masque 
         mask = 1 << tel->estRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;

         // je cree le masque 
         mask = 1 << tel->westRelay;
         // je force à 1 le bit correspondant 
         tel->outputTelescopNotification |= mask;
      }
      result = mytel_sendUsbCommandTelescop(tel, tel->outputTelescopNotification);
   } else if (tel->telescopeCommandSocket != NULL) {

      // je convertis en majuscule
      char direction2 = toupper(direction[0]);

      // je verifie la valeur
      switch (direction2) {
         case 'N' : 
         case 'S' : 
         case 'E' : 
         case 'W' : 
            result = 0; 
            break;
         case 0 : 
            direction2 = 'T';
            result = 0; 
            break;
         default : 
            sprintf(tel->msg,"invalid direction %s",direction);
            return 1;
      }
      
      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!RADEC STOP %c @\n", direction2 );
         result = socket_writeTelescopeCommandSocket(tel,command,response);
         if ( result == 0 ) {
            int returnCode;
            char returnDirection;
            int readValue = sscanf(response,"!RADEC STOP %d %c @", &returnCode, &returnDirection);
            result = mytel_checkControlInterfaceResponse(tel, "tel_radec_stop", command, response, returnCode, 2, readValue);
         }
      }
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul radec stop %s OK",direction);
      result = 0; 
   }
   return result;
}

//-------------------------------------------------------------
// tel_radec_correct
//
// envoie une correction en ascension droite ou en declinaison
// avec une distance donnee en arcseconde   
//
// @param tel   pointeur structure telprop
// @param direction direction de la correction sur l'axe alpha E, W  
// @param distance  valeur de la correction sur l'axe alpha en arseconde  
// @param direction direction de la correction sur l'axe delta N ,S  
// @param distance  valeur de la correction sur l'axe delta en arseconde  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_radec_correct(struct telprop *tel, char alphaDirection, double alphaDistance, char deltaDirection, double deltaDistance)
{
   int result ;
	FILE *flogCorrA, *flogCorrD;
	char ss[256],tu[20];
	int tclresult;

   if (fabs(alphaDistance) < 0.001  && fabs(deltaDistance) < 0.001 ) return 0; //ajout F.FILLION : pas de JOG continue en guidage (rem: 0.001 arcsec = 0.2 cts de #2)
 
   // je verifie s'il n'y a pas deja un mouvement en cours
   if ( tel->radecIsMoving != 0 ) {
      sprintf(tel->msg, "tel_radec_goto already moving");
      result = 1;          
   } else {
		result = 0;
   }

   if (result == 0 ) {

      if ( tel->telescopeCommandSocket != 0 ) {

         if ( result == 0 ) {
            char command[NOTIFICATION_MAX_SIZE];
            char response[NOTIFICATION_MAX_SIZE];
				//LOG des corrections
				strcpy(ss, "clock format [ clock seconds ] -format %Y-%m-%dT%H:%M:%S -timezone :UTC "); 
				tclresult = Tcl_Eval(tel->interp,ss);
				if ( tclresult == TCL_OK) {
					strcpy(tu, Tcl_GetStringResult(tel->interp));
				} else {
					strcpy(tu, "erreur date");
				}
			   flogCorrA = fopen(lognamecorrA, "at");
				fprintf(flogCorrA, "\n%s\t%c\t\t%6.3lf", tu, alphaDirection, alphaDistance);
				fclose(flogCorrA);
				flogCorrD = fopen(lognamecorrD, "at");
				fprintf(flogCorrD, "\n%s\t%c\t\t%6.3lf", tu, deltaDirection, deltaDistance);
				fclose(flogCorrD);

            if ( tel->radec_move_rate == 0.0 ) {
               // vitesse de guidage
               sprintf(command,"!RADEC CORRECT %c %.3f %c %.3f guidage @\n", alphaDirection, alphaDistance, deltaDirection, deltaDistance );  
            } else if ( tel->radec_move_rate == 0.33 ) {
               // vitesse de centrage
               sprintf(command,"!RADEC CORRECT %c %.3f %c %.3f centrage @\n", alphaDirection, alphaDistance, deltaDirection, deltaDistance );  
            } else if ( tel->radec_move_rate == 0.66 ) {
               // vitesse de centrage
               sprintf(command,"!RADEC CORRECT %c %.3f %c %.3f centrage2 @\n", alphaDirection, alphaDistance, deltaDirection, deltaDistance );  
            } else {
               // par defaut vitesse de guidage
               sprintf(command,"!RADEC CORRECT %c %.3f %c %.3f guidage @\n", alphaDirection, alphaDistance, deltaDirection, deltaDistance );    
            }

            result = socket_writeTelescopeCommandSocket(tel,command,response);

            if ( result == 0 ) {
               int returnCode;
               char returnAlphaDirection; 
               char returnDeltaDirection; 
               int readValue = sscanf(response,"!RADEC CORRECT %d %c %c @", &returnCode, &returnAlphaDirection, &returnDeltaDirection);
               result = mytel_checkControlInterfaceResponse(tel, "tel_radec_correct", command, response, returnCode, 3, readValue);
               if (result == 0) {
                  int foundEvent = 1;
                  tel->radecIsMoving = 1;
                  // j'attend la fin du mouvement (tel->moving est mis a jour par mytel_processNotification ) 
                  while (tel->radecIsMoving /*&& foundEvent*/) { //F.FILLION : modif pour éviter l'arrêt du guidage lors d'une correction en cours
                     foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
                  }
               }
            }

            // j'affiche une trace dans la console si l'utilisateur l'a demandé
            if ( tel->consoleLog >= 1 ) {
               mytel_logConsole(tel, "T193 %s", command);
            }
         }
      }
   }
   return result;
}

int tel_get_position_tube(struct telprop *tel)
/* ---------------------------------------------------- */
/* --- called by : tel1 position_tube               --- */
/* ---------------------------------------------------- */
{
	return PT_UNKNOWN;
}

//  thread::send -async [tel1 threadid] [list tel1 correct n 0  10]

//-------------------------------------------------------------
// tel_radec_motor
//
//    commande marche/arret du suivi
//     tel->radec_motor = 0  marche 
//     tel->radec_motor = 1  arret 
//
// @param tel   pointeur structure telprop
// @param mode  0 : arret de la notification des coordonnees radec
//              1 : marche de la notification des coordonnees radec
//              2 : demande de coordonnees radec immediate 
// @return         0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_radec_motor(struct telprop *tel) {
   int result; 

   if ( tel->telescopeCommandSocket != 0 ) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      int slew ; 

      if (tel->radec_motor == 0 ) {
         slew = 1; 
      } else {
         slew = 0;
      }

      sprintf(command,"!RADEC SLEW %d @\n", slew);
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!RADEC SLEW %d @", &returnCode);
         result = mytel_checkControlInterfaceResponse(tel, "tel_radec_motor", command, response, returnCode, 1, readValue);
      }
   } else {
      result = 0; 
   }
   return result;
}

//-------------------------------------------------------------
// tel_get_radec_guiding 
//
//  retourne l'etat de l'autoguidage 
//
// @param tel   pointeur structure telprop
// @param guiding  0 : auto guidage arrete, 1 : auto guidage actif
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_get_radec_guiding(struct telprop *tel, int *guiding) {
   
   *guiding = tel->radecGuidingState;   
   return 0;  
}

//-------------------------------------------------------------
// tel_set_radec_guiding 
//
//  commande marche/arret du guidage
//  Avertit l'interface de controle Audela est en auto-guidage (checkbox du bandeau sophie dans AudeLA)
//  pour inhiber les raquettes physiques au T193 pendant l'uto-guidage
//
// @param tel   pointeur structure telprop
// @param guiding  0 : auto guidage arrete, 1 : auto guidage actif
// @return   0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_set_radec_guiding(struct telprop *tel, int guiding) {
   int result; 
	FILE *flogCorrA, *flogCorrD;

   if ( tel->telescopeCommandSocket != 0 ) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      int slew ; 

      if (tel->radec_motor == 0 ) {
         slew = 1; 
      } else {
         slew = 0;
      }

      if ( guiding == 1 ) {
         sprintf(command,"!RADEC GUIDING ON @\n");
			//LOG des corrections
		   flogCorrA = fopen(lognamecorrA, "at");
			fprintf(flogCorrA, "\n%s", "--------------------------- nouvelle étoile ---------------------------");
			fclose(flogCorrA);
			flogCorrD = fopen(lognamecorrD, "at");
			fprintf(flogCorrD, "\n%s", "--------------------------- nouvelle étoile ---------------------------");
			fclose(flogCorrD);
      } else {
         sprintf(command,"!RADEC GUIDING OFF @\n");
      }
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!RADEC GUIDING %d @", &returnCode);
         result = mytel_checkControlInterfaceResponse(tel, "tel_set_radec_guiding", command, response, returnCode, 1, readValue);
      }
   } else {
      result = 0; 
   }
   return result;
}


////////////////////////////////////////////////////////////////////
//
//  FOCALISATION
//
////////////////////////////////////////////////////////////////////


int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return 0;
}

//-------------------------------------------------------------
// tel_focus_coord
//
//    recupere la position de la focalisation
//
// @param tel   pointeur structure telprop
// @param result 
//          + : augmentation de la foc
//          - : diminution de la foc 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_coord(struct telprop *tel,char *position)
{
   int result;
   if (tel->telescopeCommandSocket != NULL) {
      if ( tel->focusIsMoving == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!FOC COORD 2 @\n" );
         result = socket_writeTelescopeCommandSocket(tel,command,response);
         if ( result == 0 ) {
            int returnCode;
            int etatM2;
            int readValue = sscanf(response,"!FOC COORD %d %d %s @", &returnCode, &etatM2, position);
            result = mytel_checkControlInterfaceResponse(tel, "tel_focus_coord", command, response, returnCode, 3, readValue);
            if ( result == 0 ) {
                // je memorise la position
               tel->focusCurrentPosition = (float) atof(position);
               sprintf(position,"%0.2f",tel->focusCurrentPosition);
            }
         }
      } else {
         // Pour eviter d'envoyer une commande pendant un mouvement en cours
         // je retourne la position recuperee dans la derniere notification (voir mytel_processNotification )
         sprintf(position,"%0.2f", tel->focusCurrentPosition );
      }
   } else {
      // je retourne une reponse par defaut 
      strcpy(position,"0.0");
      result = 0; 
   }


   return result;
}

//-------------------------------------------------------------
// tel_focus_move
//
//    deplacement a une position qui est dans tel->focus0 
//
// @param tel   pointeur structure telprop
// @param direction 
//          + : augmentation de la foc
//          - : diminution de la foc 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_goto(struct telprop *tel)
{
  int result = 0;

  if (tel->telescopeCommandSocket != NULL) {

      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!FOC GOTO %.2f @\n", tel->focus0 );  
		   //envoi de la commande et recupération de la reponse 
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
			   // j'extrait le code retour
            int readValue = sscanf(response,"!FOC GOTO %d @", &returnCode);
            result = mytel_checkControlInterfaceResponse(tel, "tel_focus_goto", command, response, returnCode, 1, readValue);
            if (result == 0) {
               // j'active les notifications de la position du focus
               result = mytel_setFocusNotification(tel, 1);
               // si le goto est lance en mode bloquant , j'attends la fin du deplacement
               if ( tel->focus_goto_blocking == 1 ) {
                  int foundEvent = 1;
                  tel->focusIsMoving = 1;
                  // j'attend la fin du mouvement (tel->moving est mis a jour par mytel_processNotification ) 
                  while (tel->focusIsMoving /*&& foundEvent*/ ) {
                     foundEvent = Tcl_DoOneEvent(TCL_ALL_EVENTS);
                     Tcl_Sleep(1);
                  }
               }
               result = 0;
            }
         }
      }
   }
   return result;
}

//-------------------------------------------------------------
// tel_focus_move
//
//    commande marche/arret de la focalisation
//     tel->radec_motor = 0  marche 
//     tel->radec_motor = 1  arret 
//
// @param tel   pointeur structure telprop
// @param direction 
//          + : augmentation de la foc
//          - : diminution de la foc 
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_move(struct telprop *tel,char *direction)
{
  int result = 0;
  char direction2 =direction[0]; 

  if (tel->telescopeCommandSocket != NULL) {

      // j'active la notification des coordonnées pendant le deplacement
      // la notification sera desactivee a la fin du deplacement par mytel_processNotification
      if ( result == 0 ) {
         result = mytel_setFocusNotification(tel, 1);
      }

      // je verifie s'il n'y a pas deja un mouvement en cours
      if ( tel->focusIsMoving != 0 ) {
         sprintf(tel->msg, "focalisation already moving");
         result = 1;          
      }

      if ( result == 0 ) {
         
         // je verifie la valeur
         switch (direction2) {
            case '+' : 
            case '-' : 
               result = 0; 
               break;
            default : 
               sprintf(tel->msg,"invalid direction %s",direction);
               result = 1;
         }
      }
      
      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         if ( tel->focus_move_rate == 0.0 ) {
            // vitesse lente
            sprintf(command,"!FOC MOVE %c L 0 @\n", direction2 );  
         } else {
            // vitesse de rapide
			   sprintf(command,"!FOC MOVE %c R 0 @\n", direction2 );
         } 
		  //envoi du mouvement et recupération du code 0
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
            int readValue = sscanf(response,"!FOC MOVE %d @", &returnCode);
            result = mytel_checkControlInterfaceResponse(tel, "tel_focus_move", command, response, returnCode, 1, readValue);
         }
      }
   }
   return result;
}

//-------------------------------------------------------------
// tel_focus_stop
//
// arret du mouvement de focalisation 
// @param tel   pointeur structure telprop
// @param direction parametre non utilisé
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_focus_stop(struct telprop *tel,char * direction)
{
  int result = 0;

  if (tel->telescopeCommandSocket != NULL) {

      if ( result == 0 ) {
         char command[NOTIFICATION_MAX_SIZE];
         char response[NOTIFICATION_MAX_SIZE];
         sprintf(command,"!FOC STOP @\n");  
		   //envoi de la commande et recupere la reponse
         result = socket_writeTelescopeCommandSocket(tel, command, response);

         if ( result == 0 ) {
            int returnCode;
            int readValue = sscanf(response,"!FOC STOP %d @", &returnCode);
            result = mytel_checkControlInterfaceResponse(tel, "tel_focus_stop", command, response, returnCode, 1, readValue);
            // j'arrete la notification de la position du focuseur
            mytel_setFocusNotification(tel, 0);
         }
      }
   }
   return result;
}

//-------------------------------------------------------------
// mytel_setFocusNotification
//
// demande a recevoir la position du focus sur la socket de notification
//
// @param tel   pointeur structure telprop
// @param mode  0 : arret de la notification de la position du focus
//              1 : marche de la notification de la position du focus
// @return 0 = OK,  1= erreur
//-------------------------------------------------------------
int mytel_setFocusNotification(struct telprop *tel, int mode )
{
   int result; 
   
   if ( tel->telescopeCommandSocket != 0 ) {
      char command[NOTIFICATION_MAX_SIZE];
      char response[NOTIFICATION_MAX_SIZE];
      sprintf(command,"!FOC COORD %d @\n", mode);
      result = socket_writeTelescopeCommandSocket(tel,command,response);
      if ( result == 0 ) {
         int returnCode;
         int readValue = sscanf(response,"!FOC COORD %d @", &returnCode);
         result = mytel_checkControlInterfaceResponse(tel, "mytel_setFocusNotification", command, response, returnCode, 1, readValue);
      }
   } else {
      result = 0; 
   }
   return result;
}

//-------------------------------------------------------------
// tel_home_get
//
// Retourne le status de mmoteur de focus 
// @param tel   pointeur structure telprop
// @param homePosition  chaine de caractere en sortie contenant la position GPS 
// @return 0 = OK,  1= erreur
//
// @TODO il vaudrait mieux demander les cordonnees a l'interface de controle du T193
//
//-------------------------------------------------------------

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return 0;
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   //return mytel_date_get(tel,ligne);
   return 0;
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   //return mytel_date_set(tel,y,m,d,h,min,s);
   return 0;

}

//-------------------------------------------------------------
// tel_home_get
//
// Retourne la position geographique du telescope au format GPS
// Format GPS :
//   "GPS [longitude] [e|w] [signe][latitude] "
//   "GPS %f %s %s%f"
// Exemple : "GPS 5.7157 E 43.931892 633.9"
//
// @param tel   pointeur structure telprop
// @param homePosition  chaine de caractere en sortie contenant la position GPS 
// @return 0 = OK,  1= erreur
//
// @TODO il vaudrait mieux demander les cordonnees a l'interface de controle du T193
//
//-------------------------------------------------------------
int tel_home_get(struct telprop *tel,char *homePosition)
{
   strcpy(homePosition,tel->homePosition);
   return 0;

}


//-------------------------------------------------------------
// tel_home_set
//
// enregistre la position geographique du telescope au format GPS
// Format GPS :
//   "GPS [longitude] [e|w] [latitude] "
//   "GPS %f %s %f"
// Exemple : "GPS 5.7157 E 43.931892 633.9"
//
// @param tel   pointeur structure telprop
// @param longitude  longitude du lieu
// @param ew         e ou w  
// @param latitude   latitude du lieu
// @param altitude   altitude du lieu
// @return 0 = OK,  1= erreur
//
// @TODO il vaudrait mieux envoyer les cordonnees a l'interface de controle du T193
//
//-------------------------------------------------------------
int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   sprintf(tel->homePosition,"GPS %f %s %f %f",longitude,ew,latitude, altitude);
   return 0;

}


////////////////////////////////////////////////////////////////////
//
// gestion des atténuateurs 
//
////////////////////////////////////////////////////////////////////


//-------------------------------------------------------------
// tel_filter_setMax
//
// Inialise la duree de déplement entre les 2 fin de course de l'attenuateur 
// a partir du fichier d'initialisation
// Cette durée servira pour calculer le pourcentage d'atténuation
//
// @param tel 
// @param filterMaxDelay  duree de déplacement entre les fin de course (en seconde)
//
//-------------------------------------------------------------

int tel_filter_setMax(struct telprop *tel, double dureeMaxAttenuateur) {  
   // je memorise la valeur max 
   tel->filterMaxDelay = dureeMaxAttenuateur;


   // j'ecrete la valeur courante pour ne pas provoquer une situation incohérente
   if ( tel->filterCurrentDelay > tel->filterMaxDelay ) {
      tel->filterCurrentDelay = tel->filterMaxDelay;
   }

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter set max %f OK", filterMaxDelay);
   }
   return 0;   
}

//-------------------------------------------------------------
// tel_filter_getMax
//
// retour,la durée de deplacement entre les 2 butées de fin de course 
//
// @param tel 
// @param filterMaxDelay  duree de déplacement entre les fin de course (en seconde)
//-------------------------------------------------------------

int tel_filter_getMax(struct telprop *tel, double *filterMaxDelay) {   
   *filterMaxDelay     = tel->filterMaxDelay;
   return 0;   
}


//-------------------------------------------------------------
// tel_filter_coord
//
// Retourne la position du filtre d'attenuation (entre 0.0 et 10.0) 
//
// @param tel    pointeur struture telprop
// @param coord  chaine de caractere contenant la valeur d'attenuation (entre 0.0 et 10.0) 
//-------------------------------------------------------------
int tel_filter_coord(struct telprop *tel, char * coord) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je lis la carte
      unsigned char inputNotification;
      result = mytel_readUsbCard(tel, &inputNotification);
      if ( result == 0 ) {
         double delay ; 


         // je recupere l'etat de la butee min
         int min = mytel_getBit(tel, inputNotification, tel->minDetectorFilterInput);
         // je recupere l'etat de la butee max
         int max = mytel_getBit(tel, inputNotification, tel->maxDetectorFilterInput);

         if ( min == 0 ) {
            // la butee MIN est au niveau 0 quand elle est rencontrée
            delay= 0;
            tel->filterCurrentDelay = delay; 
         } else if (max == 0 ) {
            // la butee MAX est au niveau 0 quand elle est rencontrée
            delay = tel->filterMaxDelay;
            tel->filterCurrentDelay = delay; 
         } else {
            // la position est entre les deux butees
            if (tel->filterCommand == tel->decreaseFilterRelay) {
               // si un mouvement "-" en cours , je soustrais la durée ecoulee depuis le début du mouvement
               delay =  tel->filterCurrentDelay -  mytel_getTimer(tel);
            } else if (tel->filterCommand == tel->increaseFilterRelay) {
               // si un mouvement "-" en cours , j'ajoute la durée ecoulee depuis le début du mouvement
               delay =  tel->filterCurrentDelay +  mytel_getTimer(tel);
            } else {
               // si pas de un mouvement en cours, je retourne le delai courant
               delay = tel->filterCurrentDelay;
            }

            if (delay< 0.0 ) {
               delay = 0.0;
            } else if (delay > tel->filterMaxDelay ) {
               delay = tel->filterMaxDelay;
            }
         }

         // je calcule le pourcentage par rapport au delai max
         sprintf(coord, "%3.1f", ( delay * 10.0 / tel->filterMaxDelay)); 
         result = 0;
      }
   } else {
      strcpy(coord, "5.0");
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter coord %s OK", coord);
      result = 0;
   }
   return result;
}


//-------------------------------------------------------------
// tel_filter_extremity
//
// Retourne l'etat des butees aux extremités
//    retourne MIN si la position est sur la butée MIN
//    retourne MAX si la position est sur la butée MAX
//    retourne MED si la position est entre les deux butées
//
// @param tel    pointeur struture telprop
// @param extremity  chaine de caractere contenant l'état de la position (MIN , MED , MAX)
//                
//-------------------------------------------------------------
int tel_filter_extremity(struct telprop *tel, char * extremity) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      // je lis la carte
      unsigned char inputNotification;
      result = mytel_readUsbCard(tel, &inputNotification);
      if ( result == 0 ) {
         // je recupere l'etat de la butee min
         int min = mytel_getBit(tel, inputNotification, tel->minDetectorFilterInput);
         // je recupere l'etat de la butee max
         int max = mytel_getBit(tel, inputNotification, tel->maxDetectorFilterInput);

         // la fin de course est au niveau 0 quand elle est rencontrée
         if ( min == 0 ) {
            strcpy(extremity,"MIN");
         } else if (max == 0 ) {
            strcpy(extremity,"MAX");
         }  else {
            strcpy(extremity,"MED");
         }
         result = 0;
      }
   } else {
      strcpy(extremity, "MED");
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter coord %s OK", coord);
      result = 0;
   }
   return result;
   
   
}

//-------------------------------------------------------------
// tel_filter_move
//
// demarrer le changement de position de l'atténuateur
//
// @param tel    pointeur structure telprop
// @param direction  sens du deplacement ( "-" ou "+" )
// @return      0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_filter_move(struct telprop *tel, char * direction) {
   int result = 0;

   if ( tel->outputFilterTaskHandle != 0 ) {
      char mask; 
      int numbit;

      switch (tolower(direction[0])) {
         case '-' : 
            numbit = tel->decreaseFilterRelay;
            break;
         case '+' : 
            numbit = tel->increaseFilterRelay;
            break;
         default : 
            sprintf(tel->msg,"invalid direction %s",direction);
            return 1;
      }

      // je cree le masque 
      mask = 1 << numbit;
      // je force à 0 le bit correspondant 
      tel->outputFilterNotification &= ~mask;
      result = mytel_sendCommandFilter(tel, tel->outputFilterNotification);
      // je memorise l'heure de début du mouvememt
      mytel_startTimer(tel);
      // je memorise le sens du mouvememt qui sera utilisé par tel_filter_stop
      tel->filterCommand = numbit;      
   } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter move %s OK",direction);
      result = 0;
   }

   return result;   
}

//-------------------------------------------------------------
// tel_filter_stop
//
// arrete le changement de position de l'atténuateur
//
// @param tel    pointeur structure telprop
// @return      0 = OK,  1= erreur
//-------------------------------------------------------------
int tel_filter_stop(struct telprop *tel) {
   int result;

   if ( tel->outputFilterTaskHandle != 0 ) {
      char mask; 
      double delay;

      // je cree le masque pour decreaseFilterRelay
      mask = 1 << tel->decreaseFilterRelay;
      // je force à 1 le bit correspondant 
      tel->outputFilterNotification |= mask;

      // je cree le masque pour increaseFilterRelay
      mask = 1 << tel->increaseFilterRelay;
      // je force à 1 le bit correspondant 
      tel->outputFilterNotification |= mask;
      // j'enoive la commande sur la carte
      result = mytel_sendCommandFilter(tel, tel->outputFilterNotification);
      
      // je memorise l'heure de fin du mouvememt et je calule le délai en millisecondes
      delay = mytel_stopTimer(tel);

      if (tel->filterCommand == tel->decreaseFilterRelay) {
         // diminution de l'attenuateur => je diminue le temps cumulé
         tel->filterCurrentDelay -= delay;
         if (tel->filterCurrentDelay < 0.0 ) {
            tel->filterCurrentDelay = 0.0;
         } 
      } else {
         // augmentation de l'attenuateur => j'augmente le temps cumulé
         tel->filterCurrentDelay += delay;
         if (tel->filterCurrentDelay > tel->filterMaxDelay ) {
            tel->filterCurrentDelay = tel->filterMaxDelay;
         } 
      }
      // Raz de la commande pour indiquer que le mouvement est arrete
      tel->filterCommand = -1;
    } else {
      // je simule l'envoi de la commande
      //mytel_logConsole(tel, "simul filter stop OK");
      result = 0;
   }
   return result;   
}

//-------------------------------------------------------------
// mytel_sendUsbCommandTelescop
//
// envoie une commande au telescope sur le port tel->outputTelescopTaskHandle
//
// @param tel     pointeur structure telprop
// @param command integer contenant la conmmande  
// @return        0 = OK,  1= erreur
//-------------------------------------------------------------

int mytel_sendUsbCommandTelescop(struct telprop *tel, int command) {
	int      cr = 0;
   int      error=0;
   uInt8    notification=0;
   int32	   written;

   notification = (uInt8) command;

   if ( tel->consoleLog >= 2 ) {
      // j'affiche une trace dans la console
      mytel_logConsole(tel, "T193 command: %d",notification); 
   }

   // DAQmx Write Code
   // parametres : 
   //    outputTaskHandle outputTaskHandle,  
   //    int32 numSampsPerChan,        1
   //    bool32 autoStart,             1
   //    float64 timeout,              10.0 seconds
   //    bool32 notificationLayout,            DAQmx_Val_GroupByChannel
   //    const uInt32 writeArray[],    notification 
   //    int32 *sampsPerChanWritten,   written
   //    bool32 *reserved);            NULL
	//error = DAQmxWriteDigitalU32(tel->outputTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);
   error = DAQmxWriteDigitalU8(tel->outputTelescopTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);
    

   if( DAQmxFailed(error)) {
      // je copie le message d'erreur
		DAQmxGetExtendedErrorInfo(tel->msg,1024);
      cr = 1;
   } else {
		strcpy(tel->msg,"");
      cr = 0;
   }

	return cr;
}

//-------------------------------------------------------------
// mytel_sendCommandFilter
//
// envoie une commande au filtre sur le port tel->outputFilterTaskHandle
//
// @param tel      pointeur structure telprop
// @param command  integer contenant la conmmande 
// @return         0 = OK,  1= erreur
//-------------------------------------------------------------
int mytel_sendCommandFilter(struct telprop *tel, int command) {
	char     ligne[1024];
	int      cr = 0;
   uInt8   notification=0;
   int32	   written;
   int      error=0;
	int bits[8],k;
   notification = (uInt8) command;

   if ( tel->consoleLog >= 2 ) {
      // j'affiche une trace dans la console
      mytel_logConsole(tel, "T193 command: %d",notification); 
      Tcl_Eval(tel->interp,ligne);
   }

	//Choice_controller : 0 <-> NI DAQmx ; 1 <-> beckhoff
	if (tel->choice_controler==0) {
		// DAQmx Write Code
		// parametres : 
		//    outputTaskHandle outputTaskHandle,  
		//    int32 numSampsPerChan,        1
		//    bool32 autoStart,             1
		//    float64 timeout,              10.0 seconds
		//    bool32 notificationLayout,            DAQmx_Val_GroupByChannel
		//    const uInt32 writeArray[],    notification 
		//    int32 *sampsPerChanWritten,   written
		//    bool32 *reserved);            NULL
		//error = DAQmxWriteDigitalU32(tel->outputTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);
	   error = DAQmxWriteDigitalU8(tel->outputFilterTaskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,&notification,&written,NULL);
		if( DAQmxFailed(error)) {
			// je copie le message d'erreur
			DAQmxGetExtendedErrorInfo(tel->msg,1024);
			cr = 1;
		} else {
			strcpy(tel->msg,"");
			cr = 0;
		}
	} else {
	   sprintf(ligne,"lindex [beckhoff_ads_status] 4");
		// on envoie la commande dans la libbeckhofftcl
      error=Tcl_Eval(tel->interp,ligne);
		// on traite l'erreur
      if ( error == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			cr = 1;
			return cr;
		} else {
			// pas d'erreur et on traite le mode RUN (GN ne resout pas le probleme de plantage en cas de beckhoff non allumé à l'initialisation.)
			if (strcmp(Tcl_GetStringResult(tel->interp),"RUN")!=0) {
				sprintf(tel->msg,"Bad Beckhoff status: %s",Tcl_GetStringResult(tel->interp));
				cr = 1;
			} else {
				// pas d'erreur et on est en mode RUN
				strcpy(tel->msg,"");
				cr = 0;
				// decodage de la commande dans le tableaux bits[]
				for (k=0;k<8;k++) {
					bits[k] = (command >> k) & 0x01;
				}
				// serie de if pour traiter chaque type de commande (On garde la logique inverse : héritage du DAQmx)
				if ( bits[tel->increaseFilterRelay] == 0 ) {
					sprintf(ligne,"beckhoff_ads_Start_IncAtt");
				} else if ( bits[tel->decreaseFilterRelay] == 0 ) {
					sprintf(ligne,"beckhoff_ads_Start_DecAtt");
				} else if ( (bits[tel->increaseFilterRelay]==1) && (bits[tel->decreaseFilterRelay]==1) ) {
					sprintf(ligne,"beckhoff_ads_Stop_IncAtt ; beckhoff_ads_Stop_DecAtt");
				}
				// on envoie la commande dans la libbeckhofftcl
				error=Tcl_Eval(tel->interp,ligne);
				// on traite l'erreur
				if ( error == TCL_ERROR ) {
					strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
					cr = 1;
				} else {
					strcpy(tel->msg,"");
					cr = 0;
				}
	/*			if ( tel->consoleLog >= 2 ) {
				// j'affiche une trace dans la console
					mytel_logConsole(tel,"T193 write Beckhoff: %d %s",command,ligne); 
					Tcl_Eval(tel->interp,ligne);
				}
				mytel_logConsole(tel,"T193 write Beckhoff: %d %s",command,ligne); 
				Tcl_Eval(tel->interp,ligne); */
			}
		}
	}

	return cr;
}

/**
 * mytel_readUsb : send a command to the telescop
 * @param tel  
 * @param command : long integer 
 * @return 0=OK 1=erreur
 */
int mytel_readUsbCard(struct telprop *tel, unsigned char *notification ) {
	char     ligne[1024];
	int      cr = 0;
   int      error=0;
   int32	   readden;
	int bits[8],k;
	int resultat;
	//Choice_controller : 0 <-> NI DAQmx ; 1 <-> beckhoff
	if (tel->choice_controler==0) {
		// DAQmxReadDigitalU8
		// parametres : 
		//    outputTaskHandle outputTaskHandle,  
		//    int32 numSampsPerChan,        1
		//    float64 timeout,              10.0 seconds
		//    bool32 notificationLayout,            DAQmx_Val_GroupByChannel
		//    const uInt32 writeArray[],    notification 
		//    int32 *sampsPerChanWritten,   readden elements nb
		//    bool32 *reserved);            NULL 
		error = DAQmxReadDigitalU8 (tel->inputFilterTaskHandle, 1, 10.0, DAQmx_Val_GroupByChannel, notification, 1, &readden, NULL);

		if( DAQmxFailed(error)) {
			// je copie le message d'erreur
			DAQmxGetExtendedErrorInfo(tel->msg,1024);
			cr = 1;
		} else {
			if ( tel->consoleLog >= 2 ) {
				// j'affiche une trace dans la console
				//mytel_logConsole(tel,"T193 read USB: %d",*notification); 
				//Tcl_Eval(tel->interp,ligne);
			}
			strcpy(tel->msg,"");
			cr = 0;
		}
	} else {
		// prepare la commande
	   sprintf(ligne,"beckhoff_ads_butee");
		// on envoie la commande dans la libbeckhofftcl
      error=Tcl_Eval(tel->interp,ligne);
		// on traite l'erreur
      if ( error == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			cr = 1;
		} else {
			resultat = (uInt8)atoi(Tcl_GetStringResult(tel->interp));
			// decodage de la commande dans le tableaux bits[]
			// bits[0]=1 pour la butee min atteinte
			// bits[1]=1 pour la butee max atteinte
			for (k=0;k<8;k++) {
				bits[k] = (resultat >> k) & 0x01;
			}
			// on fabrique la notification
			*notification = (int)pow(2,tel->minDetectorFilterInput)*(1-bits[0])+(int)pow(2,tel->maxDetectorFilterInput)*(1-bits[1]);
			strcpy(tel->msg,"");
			cr = 0;
			//if ( tel->consoleLog >= 2 ) {
				// j'affiche une trace dans la console
				//mytel_logConsole(tel,"T193 read Beckhoff: %d",*notification); 
				//Tcl_Eval(tel->interp,ligne);
			//}
				//mytel_logConsole(tel,"T193 read Beckhoff: %d",*notification); 
				//Tcl_Eval(tel->interp,ligne);
		}
	}

	return cr;
}


/**
* getBit 
*    lit un octet  et retourne la valeur d'un bit
*/
int mytel_getBit(struct telprop *tel, unsigned char notification, int numbit)
{
   unsigned char mask; 
   unsigned char tempValue;
   char result;

   if(numbit <0 || numbit >7 ) {
      return 0;
   }

   mask = 1 << numbit;
   
   tempValue = notification & mask;

   if( tempValue ==0 ) {
      result = 0;
   } else {
      result = 1;
   }

   return result;
}


//-------------------------------------------------------------
// mytel_sendNotificationError
//
// affiche une erreur dans la console pour signaler une notification erronee
//
// @param tel   pointeur structure telprop
// @param notification  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
void mytel_sendNotificationError(struct telprop *tel, int errorNo, const char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   
   // je formate le message 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
	va_end (mkr);


   // j'affiche une erreur dans la console
   if ( strcmp(tel->telThreadId,"") == 0 ) {
      sprintf(ligne,"error \"t193 error=%d notification=%s \" ",errorNo, message); 
   } else {
      sprintf(ligne,"::thread::send -async %s { error \"t193 error=%d notification=%s \" }" , tel->mainThreadId, errorNo, message ); 
   }
   Tcl_Eval(tel->interp,ligne);   
}

//-------------------------------------------------------------
// mytel_processNotification
//
// traite les notifications suivantes : 
// 
//   
//     "!RADEC COORD [Code retour] [mouvement] [suivi] [alpha] [delta] @"
//     "!RADEC FOC [Code retour] [mouvement] [position] @"
//
// @param tel   pointeur structure telprop
// @param notification  
// @return  0 = OK,  1= erreur
//-------------------------------------------------------------
void mytel_processNotification(struct telprop *tel, char * notification) {
   int  nbArrayElements;
   char command1[NOTIFICATION_MAX_SIZE]= {'\0'} ;
   char command2[NOTIFICATION_MAX_SIZE];
      
   nbArrayElements = sscanf(notification, "!%s %s @", command1, command2);
	mytel_logConsole(tel,"[mc_date2iso8601 now] : mytel_processNotification notification=%s",notification); // AK
   
   if ( nbArrayElements == 2 ) {
      // je traite la notification
      if ( strcmp( command1, "RADEC")==0) {
         if ( strcmp( command2, "NOTIF")==0 ) {
            int returnCode;
            int moveCode;
            int slewCode;
            char raCalage;
            char decCalage;
            char raBrut[NOTIFICATION_MAX_SIZE];
            char decBrut[NOTIFICATION_MAX_SIZE];
            char ra[NOTIFICATION_MAX_SIZE];
            char dec[NOTIFICATION_MAX_SIZE];
            // traitement de "!RADEC COORD [Code retour] [mouvement] [suivi] [alpha] [delta] @"
            nbArrayElements = sscanf(notification, "!RADEC NOTIF %d %d %d %c %c %s %s @", &returnCode, &moveCode, &slewCode, &raCalage, &decCalage, raBrut, decBrut);
            // je verifie que le nombre de valeurs lues
            if ( nbArrayElements == 7 ) {
               // je verifie le code retour 
               if ( returnCode == 0) {
                  char ligne[1024];      
                  int tclResult; 
                  char tu[20];
                  char radec[30];

                  // je memorise le code du mouvement
                  tel->radecIsMoving = moveCode;

                  // je recupere la date courante TU
                  strcpy(ligne, "clock format [ clock seconds ] -format %Y-%m-%dT%H:%M:%S -timezone :UTC "); 
                  tclResult = Tcl_Eval(tel->interp,ligne);
                  if ( tclResult == TCL_OK) {
                     strcpy(tu, Tcl_GetStringResult(tel->interp));
                  } 
                  if ( tclResult == TCL_OK) {
                     // j'applique le modele de pointage avec la fonction mc_tel2cat de LIBMC et je convertis en coordonnes J2000
                     // usage: mc_tel2cat {12h 36d} EQUATORIAL { dateTu } {GPS 5 E 43 1230} 101325 290 { symbols } { values }
                     if (tel->radec_model_enabled == 1 ) {
                        sprintf(ligne, "mc_tel2cat { %s %s  } EQUATORIAL { %s } { %s } %d %d { %s } { %s }", 
                           raBrut,decBrut, tu, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature, 
                           tel->radec_model_symbols, tel->radec_model_coefficients);
                     } else {
                        sprintf(ligne, "mc_tel2cat { %s %s  } EQUATORIAL { %s } { %s } %d %d", 
                           raBrut,decBrut, tu, tel->homePosition, 
                           tel->radec_model_pressure, tel->radec_model_temperature);
                     }
                     tclResult = Tcl_Eval(tel->interp,ligne);
                     strcpy(radec,Tcl_GetStringResult(tel->interp));
                     // je convertis les angles en HMS et DMS
                     sprintf(ligne,"mc_angle2hms [lindex {%s} 0] 360 zero 2 auto string",radec);
                     tclResult = Tcl_Eval(tel->interp,ligne);
                     if ( tclResult == TCL_ERROR) {
                        mytel_sendNotificationError(tel, 12, Tcl_GetStringResult(tel->interp));
                     } else {
                        strcpy(ra,Tcl_GetStringResult(tel->interp));                           
                     } 
                     sprintf(ligne,"mc_angle2dms [lindex {%s} 1] 90 zero 1 + string",radec); 
                     tclResult = Tcl_Eval(tel->interp,ligne);
                     if ( tclResult == TCL_ERROR) {
                        mytel_sendNotificationError(tel, 13, Tcl_GetStringResult(tel->interp));
                     } else {
                        strcpy(dec,Tcl_GetStringResult(tel->interp));
                     }                      
                  }                  
                  
                  // j'affiche les coordonnees 
                  if (tclResult == TCL_OK) {
                     // je memorise les coordonnees brutes pour la fonction tel_radec_coord
                     strcpy(tel->raBrut, raBrut);
                     strcpy(tel->decBrut, decBrut);

							// j'envoie les coordonnes { ra, dec } aux clients du serveur de coordonnees
							socket_writeCoordServerSocket(tel, returnCode, ra, dec, raBrut, decBrut, raCalage, decCalage);
							/* AK
                     sprintf(ligne,"::thread::send -async %s { set ::audace(telescope,t193_displaycoord) \"%d %s %s %s %s %c %c %d\" ;update} " , tel->mainThreadId, returnCode, ra, dec, raBrut, decBrut, raCalage, decCalage,tel->radec_model_enabled); 
	                  Tcl_Eval(tel->interp,ligne);
							*/
                     // je notifie les nouvelles coordonnes au thread principal                
                     if ( strcmp(tel->telThreadId,"") == 0 ) {
                        sprintf(ligne,"set ::audace(telescope,getra) \"%s\" ; set ::audace(telescope,getdec) \"%s\" ",ra, dec); 
                     } else {
                        sprintf(ligne,"::thread::send -async %s { set ::audace(telescope,getra) \"%s\" ; set ::audace(telescope,getdec) \"%s\" ;update} " , tel->mainThreadId, ra , dec); 
                     }
                     Tcl_Eval(tel->interp,ligne);

                  }
               }
            } else {
               mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
            }
            
         } else {
            mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
         }
      } else if ( strcmp( command1, "FOC")==0) {
         if ( strcmp( command2, "COORD")==0 ) {
            int returnCode;
            int moveCode;
            float position;

            // traitement de "!FOC COORD [Code retour] [mouvement] [position] @"
            nbArrayElements = sscanf(notification, "!FOC COORD %d %d %f @", &returnCode, &moveCode, &position);
            // je verifie que le nombre de valeurs lues est 5
            if ( nbArrayElements >= 3 ) {
               // je verifie le code retour 
               if ( returnCode == 0) {
                  char ligne[1024];
                  
                  // je memorise le mouvement et la position
                  tel->focusIsMoving = moveCode;
                  tel->focusCurrentPosition = position;

                  // je notifie les nouvelles coordonnes au thread principal                
                  if ( strcmp(tel->telThreadId,"") == 0 ) {
                     sprintf(ligne,"set ::audace(focus,currentFocus) %s", position); 
                  } else {
                     sprintf(ligne,"::thread::send -async %s { set ::audace(focus,currentFocus) %6.2f ; update }" , tel->mainThreadId, position); 
                  }
                  Tcl_Eval(tel->interp,ligne);
               }
            } else {
               mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
            }   
         } else {
            mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
         }
	  }
   } else {
      mytel_sendNotificationError(tel, BACKCMD_BAD_PARAM_NUMBER, notification);
   }
}


//////////////////////////////////////////////////////////////////////
//  gestion du timers
/////////////////////////////////////////////////////////////////////

/**
 * mytel_startTimer : enregistre l'heure courante comme heure de demarrage du timer
 * @param tel  
 * @return none
 */
void mytel_startTimer(struct telprop *tel)
{
#if defined(OS_WIN)
    struct _timeb timebuffer;
    _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
    struct timeb timebuffer;
    ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
    tel->startTime = ((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
    struct timeval date;
    gettimeofday(&date, NULL);
    _startTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
}


/**
 * mytel_getTimer : retourne le delay 
 * @param tel  
 * @return  delay ecoule entre le demarrage et l'arret du timer (en seconde)
 */

double mytel_getTimer(struct telprop *tel)
{
    double stopTime;
    if ( tel->startTime == 0.0 ) {
       // je retourne une valeur nulle si le timer est arrete
       return 0.0;
    } else {
#if defined(OS_WIN)
      struct _timeb timebuffer;
      _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
      struct timeb timebuffer;
      ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
      stopTime = ((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
      struct timeval date;
      gettimeofday(&date, NULL);
      stopTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
      return stopTime - tel->startTime;
   }
}


/**
 * mytel_startTimer : enregistre l'heure courante comme heure de demarrage du timer
 * @param tel  
 * @return  delay ecoule entre le demarrage et l'arret du timer (en seconde)
 */

double mytel_stopTimer(struct telprop *tel)
{
    double stopTime;
    double delay;

#if defined(OS_WIN)
   struct _timeb timebuffer;
   _ftime(&timebuffer);
#endif
#if defined(OS_LIN)
   struct timeb timebuffer;
   ftime(&timebuffer);
#endif
#if defined(OS_WIN) || defined(OS_LIN)
   stopTime = ((double) timebuffer.millitm) / 1000.0 + (double) timebuffer.time;
#endif
#if defined(OS_MACOS)
   struct timeval date;
   gettimeofday(&date, NULL);
   stopTime = (double) date.tv_sec + ((double) date.tv_usec) / 1000000.0;
#endif
   delay = stopTime - tel->startTime;
   // RAZ de l'heure de debut pour indiquer qque le timer est arrete
   tel->startTime = 0.0; 
   return delay;

}


/**
 * mytel_logConsole 
 *   affiche un message dans la console d'Audela
 * @param tel  
 * @param messageFormat chaine de formatage du message suivi d'un nombre variable de parametres
 * @return  void
 */
void mytel_logConsole(struct telprop *tel, char *messageFormat, ...) {
   char message[1024];
   char ligne[1200];
   va_list mkr;
   int result;
   
   // j'assemble la commande 
   va_start(mkr, messageFormat);
   vsprintf(message, messageFormat, mkr);
	va_end (mkr);

   if ( strcmp(tel->telThreadId,"") == 0 ) {
      sprintf(ligne,"::console::disp \"libT193: %s\n\" ",message); 
   } else {
      sprintf(ligne,"::thread::send -async %s { ::console::disp \"libT193: %s \n\" } " , tel->mainThreadId, message); 
   }
   result = Tcl_Eval(tel->interp,ligne);

   
}

/**
 * mytel_getControlInterfaceLabelError 
 *   retoune le libellé d'un message d'erreur de l'interface de controle
 * @param tel  
 * @param messageFormat chaine de formatage du message suivi d'un nombre variable de parametres
 * @return  0=OK, 1=nombre de parametres incorrect, sinon retourne le code d'erreur extrait de la reponse de l'interface
 */
int mytel_checkControlInterfaceResponse(struct telprop *tel, char *fonction, char *command, char *response, int returnCode, int requiredValue, int readValue) {
   int result;
   if (readValue != requiredValue) {
      sprintf(tel->msg,"%s error: l'interface de controle a retourné un nombre de parametres incorrects=%d (attendu=%d) \nCommand=%s Response=%s",
         fonction,readValue, requiredValue, command, response );
      result = 1;
   } else {
      if ( returnCode != 0 ) {
         sprintf(tel->msg,"%s error: L'interface de controle a retourné le code erreur=%d (%s)\nCommand=%sReponse=%s", 
            fonction, returnCode, mytel_getControlInterfaceLabelError(returnCode), command, response);
         result = returnCode;
      } else {
         result = 0;
      }
   }
   return result;
}

//#define MOUCHARD

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_lx200.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD)
   fprintf(f,"# [%d] = %s\n", result, Tcl_GetStringResult(tel->interp));
   fclose(f);
#endif
   return result;
}
