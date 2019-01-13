/* coordserver.c
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
// Mise a jour $Id: coordserver.c,v 1.5 2010-02-23 20:08:14 michelpujol Exp $

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include "telescop.h"
#include "coordserver.h"


#define DATA_SOCKET_SIZE 128

void socket_acceptCoordServerSocket(ClientData clientData, Tcl_Channel channel, char *hostName, int port);
void socket_readTelescopeNotificationSocket(ClientData clientData, int mask);

#define MAX_CLIENT_COORD 10
Tcl_Channel clientCoordSocketList[MAX_CLIENT_COORD];

//////////////////////////////////////////////////////////////////////
//  gestion de coordServerSocket
/////////////////////////////////////////////////////////////////////


/**
 * socket_openCoordServerSocket 
 *   ouvre la socket de notification des coordonnees
 * @param tel  
 * @param ethernetHost  
 * @param ethernetPort  
 * @return 0= OK ou 1=ERROR (voir le libelle de l'erreur dans tel->msg)
 */
int socket_openCoordServerSocket(struct telprop *tel, int coordServerPort) {
   int tclResult;
   int index; 

   // j'intialise la liste des clients à vide 
   for(index = 0; index < MAX_CLIENT_COORD; index++ ) {
      clientCoordSocketList[index] = NULL;
   }
   
   // j'ouvre la socket client de notification vers les PC d'affichage des coordonnees
   //  parametre 1 interp      interpreteur TCP associe au telescope
   //  parametre 2 myport      port de reception des connexions des clients
   //  parametre 3 myapp       Nom du host client. If NULL the special address INADDR_ANY should be used to allow connections from any network interface
   //  parametre 4 proc        Pointer to a procedure to invoke each time a new connection is accepted via the socket. 
   //  parametre 5 ClientData  Arbitrary one-word value to pass to proc   
	if (1==1) {
		//tel->telescopeCoordServerSocket = Tcl_OpenTcpServer(tel->interp, coordServerPort, NULL, socket_acceptCoordServerSocket, (ClientData) tel) ;
	   tel->telescopeCoordServerSocket=NULL;
		if ( tel->telescopeCoordServerSocket == NULL ) {
			sprintf(tel->msg,"Open ethernet connection error %d. %s", Tcl_GetErrno() , Tcl_GetStringResult(tel->interp));
			tclResult = TCL_ERROR;
		}
	} else {		
      char ligne[1024];
		strcpy(ligne,"proc socket_coordserver_accept {fid ip port} { fconfigure $fid -buffering line ; fileevent $fid readable [list socket_coordserver_respons $fid] }");
      tclResult = Tcl_Eval(tel->interp, ligne );
		strcpy(ligne,"proc socket_coordserver_respons {fid } { return }");
      tclResult = Tcl_Eval(tel->interp, ligne );
      sprintf(ligne,"socket -server socket_coordserver_accept %d",coordServerPort);
      tclResult = Tcl_Eval(tel->interp, ligne );		
		tel->telescopeCoordServerSocket=NULL;
      if ( tclResult == TCL_OK) {
		}
	}

   if ( tclResult == TCL_OK) {
      return 0;
   } else {
      return 1;
   }
   
}


/**
 * socket_closeCoordServerSocket 
 *   ferme  la socket de notification des coordonnees
 * @param tel   structure contenant les attributs du telescope
 * @return 0= OK ou 1=ERROR Le libelle de l'erreur est dans tel->msg
 */
int socket_closeCoordServerSocket(struct telprop *tel) {
   int tclResult;
   int index;
   // je deconnecte le clients
   for( index=0; index < MAX_CLIENT_COORD; index++ ) {
      if ( clientCoordSocketList[index] != NULL ) {    
         Tcl_Close( tel->interp, clientCoordSocketList[index]);
         clientCoordSocketList[index] = NULL;
      }
   }

   // je ferme la socket de connexion du serveur
   tclResult = Tcl_Close( tel->interp, tel->telescopeCoordServerSocket);
   tel->telescopeCoordServerSocket = NULL; 
   if ( tclResult != TCL_OK ) {
      sprintf(tel->msg,"Close telescope coord socket error: %s", Tcl_GetStringResult(tel->interp));
   }

   if ( tclResult == TCL_OK) {
      return 0;
   } else {
      return 1;
   }
   
}

/**
 * socket_acceptCoordServerSocket 
 *   accepte la connexion d'un client
 * @param tel  
 * @return none
 */
void socket_acceptCoordServerSocket(ClientData clientData, Tcl_Channel clientSocket, char *hostName, int port) {
   int tclResult = TCL_OK; 
   struct telprop *tel = (struct telprop *) clientData;
   
   //  je configure la gestion des buffer -buffering none -blocking false -translation binary -encoding binary
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-buffering", "line");
   }
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-blocking", "false");
   }
   
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-translation", "binary");
   }
   if ( tclResult == TCL_OK ) {
      tclResult = Tcl_SetChannelOption(tel->interp, clientSocket, "-encoding", "binary");
   }
   
   if ( tclResult == TCL_OK ) {
      int index;
      // j'ajoute la socket dans la liste de clients à notifier 
      for( index=0; index < MAX_CLIENT_COORD; index++ ) {
         if ( clientCoordSocketList[index] == NULL ) {    
            clientCoordSocketList[index] = clientSocket;
            break;
         }
      }
      if ( index >= MAX_CLIENT_COORD ) {
         tclResult = TCL_ERROR;
      }

   }
   if ( tclResult == TCL_ERROR) {
      // je referme la socket du client
      Tcl_Close( tel->interp, tel->telescopeCommandSocket);
   }
}



/**
 * socket_writeCoordServerSocket 
 *   envoie la 
 * @param tel  
 * @return none
 */
void socket_writeCoordServerSocket(struct telprop *tel, int returnCode, char * ra, char *dec, char *raBrut, char *decBrut, char raCalage, char decCalage) {
   int index;

   for( index=0; index < MAX_CLIENT_COORD; index++ ) {
      if ( clientCoordSocketList[index] != NULL ) { 
         int tclResult;
         char ligne[1024];
         int writeResult;
         char notification[1024]; 
         char tu[21];
         char ts[21];
         //double azimut;
         //double hauteur;
         //double angleHoraire;
         float longitude = 0.0;
         char   estouest = 'E';
         float latitude = 0.0;
         float altitude = 0.0;
         
         // je recupere l'heure TU au format ISO8601
         strcpy(ligne,"clock format [clock seconds] -gmt 1 -format %Y-%m-%dT%H:%M:%S");
         tclResult = Tcl_Eval(tel->interp, ligne );
         if ( tclResult == TCL_OK) {
            // je mets en forme le temps TU
            int tuy;
            int tumo;
            int tud;
            int tuh;
            int tum;
            int tus;
            sscanf(Tcl_GetStringResult(tel->interp),"%d-%d-%dT%d:%d:%d", &tuy, &tumo, &tud, &tuh, &tum, &tus);
            sprintf(tu,"%04d-%02d-%02dT%02d:%02d:%02d", tuy, tumo, tud, tuh, tum, tus);
         }

         if ( tclResult == TCL_OK) {
            // je calcule le temps sideral       
            sprintf(ligne,"mc_date2lst {%s} {%s}", Tcl_GetStringResult(tel->interp), tel->homePosition);
            tclResult = Tcl_Eval(tel->interp, ligne );
         }
         if ( tclResult == TCL_OK) {
            // je mets en forme le temps TS 
            int tsh;
            int tsm;
            int tss;
            sscanf(Tcl_GetStringResult(tel->interp),"%d %d %d", &tsh, &tsm, &tss);
            sprintf(ts,"%02d:%02d:%02d", tsh, tsm, tss);
         }

         // je recupere la longitude , latitude et altitude
         if ( tclResult == TCL_OK) {
            int scanResult; 
            scanResult = sscanf(tel->homePosition,"GPS %f %c %f %f", &longitude, &estouest, &latitude, &altitude); 
            if ( scanResult != 4 ) {
               tclResult = TCL_ERROR;
            }
         }
         
         
         if ( tclResult == TCL_OK) {
            // je prepare la notification 

            // !RADEC COORD [Code retour] [TU] [TS] [alpha_corr] [delta_corr] [alpha_0] [delta_0] [calage_alpha] [calage_delta] [longitude] [estouest] [latitude] [altitude] [nom_observatoire]\n
            // Code retour
            //    0 à OK
            //    5 à Problème moteur
            //    6 à Butées atteintes
            // TU  (format ISO 8601)
            //    Format= "%04d-%02d-%02dT%02d:%02d:%02d"
            // TS
            //    Format= "%02d:%02d:%02d" 
            // alpha_corr : coordonnée alpha corrigée avec le modèle de pointage
            //    Format = "%02dh%02dm%05.2fs"
            // delta_corr : coordonnée delta corrigée avec le modèle de pointage
            //    Format = "%1s%02dd%02dm%05.2fs"
            // alpha_0 : coordonnée brute alpha
            //    Format = "%02dh%02dm%05.2fs"
            // delta_0 : coordonnée brute delta
            //    Format = "%1s%02dd%02dm%05.2fs"
            // calage_alpha
            //    C : calé
            //    D : décalé
            //    A : autre : ni calé ni décalé
            // calage_delta
            //    C : calé
            //    D : décalé
            //    A : autre : ni calé ni décalé
            // longitude (en degres)
            //     Format "%10.6f"
            // estouest (E ou W)
            //     Format "%c"
            // latitude (en degres)
            //     Format "%10.6f"
            // altitude (en metre)
            //     Format "%5.1f"
            // nom_observatoire  (le nom doit etre entre guillement pour proteger les eventuels espaces)
            //     Format "\"%s\""
            // nom modele de pointage  (le nom doit etre entre guillement pour proteger les eventuels espaces)
            //     Format "\"%s\""
            // etat du modle ACTIF=1 INACTIF=0 
            //     Format %d

            sprintf(notification, "!RADEC COORD %d %s %s %s %s %s %s %c %c %10.6f %c %10.6f %5.1f \"%s \" \"%s \" %d @\n", 
               returnCode, tu, ts, ra, dec, raBrut, decBrut, raCalage, decCalage,
               longitude, estouest, latitude, altitude, tel->homeName, tel->radec_model_name, tel->radec_model_enabled ); 
            writeResult = Tcl_WriteChars(clientCoordSocketList[index], notification, strlen(notification));

            if ( writeResult == -1) {
               Tcl_Close( tel->interp, clientCoordSocketList[index]);
               // je supprime la socket client de la liste            
               clientCoordSocketList[index] = NULL;
            } else {
               Tcl_Flush(clientCoordSocketList[index]);
            }
         }
      }
   }
}
