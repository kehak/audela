/* beckhoffadstcltcl_1.c
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
/* sont disponibles dans les fichiers eteltcl_*.c.                         */
/***************************************************************************/
/* Le include eteltcltcl.h ne contient des infos concernant Tcl.           */
/***************************************************************************/
#include "beckhoffadstcltcl.h"

/*
load libbeckhoffadstcl.dll
beckhoff_ads_open -driver DSTEB3 -axis 0 -axis 2
beckhoff_ads_status
beckhoff_ads_close
*/
//#define MOUCHARD

int Cmd_beckhoffadstcltcl_open(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   if(argc<1) {
      sprintf(s,"Usage: %s ", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {

		#if defined(MOUCHARD)
		FILE *f;
		f=fopen("mouchard_beckhoffads.txt","wt");
		fprintf(f,"Open the driver\n");
		fclose(f);
		#endif

      strcpy(ads.beckhoffads_driver,"Beckhoff ADS");
      //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////     Variables  Beckhoff 	//////////////////////////////////////////////////////	
      nErr = 0;
      pAddr = &(Addr);
      Notif_MbRunning=0;
      DureeTotal_AttGuidage = 0.;
      Densite_AttGuidage = 0.;
      
      /*********************************************************************************/
      // Initialisation du système Beckhoff (controle des composant de la bonnette Sophie)

      printf("******************************************\n");
      printf("Initialisation communication Beckhoff \n");
      printf("******************************************\n");

      //Ouverture du port de communication sur le routeur ADS
      nPort = AdsPortOpen();
		//Récupère l'adresse locale du programme appelant
      nErr = AdsGetLocalAddress(pAddr);
      if (nErr) 
      {
         sprintf(s,"Error %d. Access to Beckhoff PLC not possible, Check network connection and contact expert",nErr);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      //Nom AMSNet Id du Beckhoff distant (adresse IP + 1.1)
		//pAddr->netId.b = (AmsNetId) {192, 168, 1, 15, 1, 1}
		pAddr->netId.b[0] = 192;
		pAddr->netId.b[1] = 168;
		pAddr->netId.b[2] = 1;
		pAddr->netId.b[3] = 15;
		pAddr->netId.b[4] = 1;
		pAddr->netId.b[5] = 1;
      // TwinCAT2 PLC1 = 801
      pAddr->port = 801;
		AdsSyncSetTimeout(500);
      // Fin d'initialisation Système Beckhoff	
      /*********************************************************************************/
   }
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_beckhoffadstcltcl_close(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char s[200];

	#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_beckhoffads.txt","at");
	fprintf(f,"Close the driver\n");
	fclose(f);
	#endif

	strcpy(ads.beckhoffads_driver,"Beckhoff ADS");
	nErr = 0;
	// Fermeture du système Beckhoff (controle des composant de la bonnette Sophie)
	printf("******************************************\n");
	printf("Fermeture communication Beckhoff \n");
	printf("******************************************\n");
	//Fermeture du port de communication sur le routeur ADS
	nErr = AdsPortClose();
	if (nErr) {
		sprintf(s,"Error %d. Close of Beckhoff PLC not possible, Check wether the port was open or check network connection and contact expert",nErr);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	Tcl_SetResult(interp,"",TCL_VOLATILE);
	return TCL_OK;
}

int Cmd_beckhoffadstcltcl_status(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char s[200];
	short unsigned int nAdsState;
	short unsigned int nDeviceState;
	char ModeBeckhoff[18][15] = {"INVALID","IDLE", "RESET","INIT","START","RUN","STOP","SAVECONFIG","LOADCONFIG","POWERFAILURE",
						   "POWERGOOD","ERROR","SHUTDOWN","SUSPEND","RESUME","CONFIG","RECONFIG","MAXSTATES"};

	#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_beckhoffads.txt","at");
	fprintf(f,"Status of the driver\n");
	fclose(f);
	#endif

	//Lecture de l'etat de l'automate (mode de fonctionnement)
	nErr = AdsSyncReadStateReq(pAddr, &nAdsState, &nDeviceState);
	if (nErr) {
		sprintf(s,"Error %d. Access to Beckhoff PLC state not possible, Check PLC working mode and contact expert",nErr);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
   }
	printf("Beckhoff Mode : %s\n",ModeBeckhoff[nAdsState]);
   printf("DeviceState: %d\n",nDeviceState);
	sprintf(s,"Beckhoff system is in %s State\n",ModeBeckhoff[nAdsState]);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_beckhoffadstcltcl_Start_IncAtt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char s[200];
	unsigned char ValToWrite_MbCmd_inc=0;
	ULONG HdlIncAtt;
	char SetIncAtt[45]="Attguide.MbCmd_inc";

	#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_beckhoffads.txt","at");
	fprintf(f,"Cmd_Start_IncAtt\n");
	fclose(f);
	#endif

	//On incremente la densite des attenuateurs de guidage
	//Récupération de la référence sur les variables PLC
	//Handle : HdlIncAtt
	nErr = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(HdlIncAtt), &HdlIncAtt, strlen(SetIncAtt)+1,SetIncAtt);
	if (nErr) {
      sprintf(s,"Error %d. Access to the reference of the Beckhoff incrementation variable not possible, Check network connection and contact expert",nErr);//texte à changer
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
	}	else {
		//Demande incrementation des attenuateurs de guidage
		ValToWrite_MbCmd_inc = 1;
			
		//Ecriture de la variable PLC MbIncAtt --> Attguide.MbCmd_inc = 1
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_VALBYHND, HdlIncAtt, sizeof(ValToWrite_MbCmd_inc), &ValToWrite_MbCmd_inc); //Demarage incrementation
		if (nErr) {
			sprintf(s,"Error %d. Impossible to Write the value of the Beckhoff incrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
			}	
		else printf("Incrementation de la densite des attenuateurs de guidage\n");
		
		//Fin demarrage incrementation
		//Libère la référence sur la variable PLC HdlIncAtt
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(HdlIncAtt), &HdlIncAtt);
		if (nErr) {
			sprintf(s,"Error %d. Impossible to release the reference of the Beckhoff incrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
	}
	Tcl_SetResult(interp,"",TCL_VOLATILE);
	return TCL_OK;
}


int Cmd_beckhoffadstcltcl_Stop_IncAtt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char s[200];
	unsigned char ValToWrite_MbCmd_inc=0;
	ULONG HdlIncAtt;
	char SetIncAtt[45]="Attguide.MbCmd_inc";

	#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_beckhoffads.txt","at");
	fprintf(f,"Cmd_Start_IncAtt\n");
	fclose(f);
	#endif

	//On incremente la densite des attenuateurs de guidage
	//Récupération de la référence sur les variables PLC
	//Handle : HdlIncAtt
	nErr = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(HdlIncAtt), &HdlIncAtt, strlen(SetIncAtt)+1,SetIncAtt);
	if (nErr) {
		sprintf(s,"Error %d. Access to the reference of the Beckhoff incrementation variable not possible, Check network connection and contact expert",nErr);//texte à changer
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}else {
		//Demande arret incrementation des attenuateurs de guidage
		ValToWrite_MbCmd_inc = 0;
			
		//Ecriture de la variable PLC MbIncAtt --> Attguide.MbIncAtt = 0
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_VALBYHND, HdlIncAtt, sizeof(ValToWrite_MbCmd_inc), &ValToWrite_MbCmd_inc); //Demarrage incrementation
		if (nErr){
			sprintf(s,"Error %d. Impossible to Write the value of the Beckhoff incrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}	
		else printf("Arret Incrementation de la densite des attenuateurs de guidage\n");
		//Fin arret incrementation
		//Libère la référence sur la variable PLC HdlIncAtt
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(HdlIncAtt), &HdlIncAtt);
		if (nErr){
			sprintf(s,"Error %d. Impossible to release the reference of the Beckhoff incrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
	}
	Tcl_SetResult(interp,"",TCL_VOLATILE);
	return TCL_OK;
}



int Cmd_beckhoffadstcltcl_Start_DecAtt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char s[200];
	unsigned char ValToWrite_MbCmd_dec=0;	
	ULONG HdlDecAtt;
	char SetDecAtt[45]="Attguide.MbCmd_dec";

	#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_beckhoffads.txt","at");
	fprintf(f,"Cmd_Start_DecAtt\n");
	fclose(f);
	#endif

	//On decremente la densite des attenuateurs de guidage
	//Récupération de la référence sur les variables PLC
	//Handle : HdlDecAtt
	nErr = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(HdlDecAtt), &HdlDecAtt, strlen(SetDecAtt)+1,SetDecAtt);
	if (nErr){
      sprintf(s,"Error %d. Access to the reference of the Beckhoff decrementation variable not possible, Check network connection and contact expert",nErr);//texte à changer
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
	}else {
		//Demande decrementation des attenuateurs de guidage
		ValToWrite_MbCmd_dec = 1;	
		//Ecriture de la variable PLC MbDecAtt --> Attguide.MbDecAtt = 1
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_VALBYHND, HdlDecAtt, sizeof(ValToWrite_MbCmd_dec), &ValToWrite_MbCmd_dec); //Demarage Decrementation
		if (nErr){
			sprintf(s,"Error %d. Impossible to Write the value of the Beckhoff decrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}	
		else printf("Decrementation de la densite des attenuateurs de guidage\n");
		//Fin demarrage decrementation
		//Libère la référence sur la variable PLC HdlDecAtt
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(HdlDecAtt), &HdlDecAtt);
		if (nErr){
			sprintf(s,"Error %d. Impossible to release the reference of the Beckhoff decrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
	}
	Tcl_SetResult(interp,"",TCL_VOLATILE);
	return TCL_OK;
}

int Cmd_beckhoffadstcltcl_Stop_DecAtt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	 char s[200];
	unsigned char ValToWrite_MbCmd_dec=0;
	ULONG HdlDecAtt;
	char SetDecAtt[45]="Attguide.MbCmd_dec";

	#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_beckhoffads.txt","at");
	fprintf(f,"Cmd_Stop_DecAtt\n");
	fclose(f);
	#endif

	//On arrete la decrementation de la densite des attenuateurs de guidage
	//Récupération de la référence sur les variables PLC
	//Handle : HdlDecAtt
	nErr = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(HdlDecAtt), &HdlDecAtt, strlen(SetDecAtt)+1,SetDecAtt);
	if (nErr){
      sprintf(s,"Error %d. Access to the reference of the Beckhoff decrementation variable not possible, Check network connection and contact expert",nErr);//texte à changer
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
	}else{
		//Demande arret decrementation des attenuateurs de guidage
		ValToWrite_MbCmd_dec = 0;	
		//Ecriture de la variable PLC MbDecAtt --> Attguide.MbDecAtt = 0
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_VALBYHND, HdlDecAtt, sizeof(ValToWrite_MbCmd_dec), &ValToWrite_MbCmd_dec); //Arret Decrementation
		if (nErr){
			sprintf(s,"Error %d. Impossible to Write the value of the Beckhoff decrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}	
		else printf("Arret Decrementation de la densite des attenuateurs de guidage\n");
		//Fin Arret decrementation
		//Libère la référence sur la variable PLC HdlDecAtt
		nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(HdlDecAtt), &HdlDecAtt);
		if (nErr){
			sprintf(s,"Error %d. Impossible to release the reference of the Beckhoff decrementation variable, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
	}
	Tcl_SetResult(interp,"",TCL_VOLATILE);
	return TCL_OK;
}

int Cmd_beckhoffadstcltcl_butee(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char s[200];
	unsigned char ValToRead_bP1min = 0;
	unsigned char ValToRead_bP2max = 0;
	ULONG HdlbP1min;
	ULONG HdlbP2max;
	char Setbuteemin[45]="Attguide.bP1min";
	char Setbuteemax[45]="Attguide.bP2max";

	#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_beckhoffads.txt","at");
	fprintf(f,"Status of the driver\n");
	fclose(f);
	#endif

	//butee min : 
	//On demande la reférence : 
	nErr = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(HdlbP1min), &HdlbP1min, strlen(Setbuteemin)+1,Setbuteemin);
	if (nErr){
      sprintf(s,"Error %d. Access to the reference of the Beckhoff decrementation variable not possible, Check network connection and contact expert",nErr);//texte à changer
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
	}else {
		//lecture de bP1min :
		nErr = AdsSyncReadReq(pAddr, ADSIGRP_SYM_VALBYHND, HdlbP1min, sizeof(ValToRead_bP1min), &ValToRead_bP1min); 
		if (nErr){
			sprintf(s,"Error %d. Impossible to Read the value of bP1min, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
 		}
	}
	//Libere la reference
	nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(HdlbP1min), &HdlbP1min);
	if (nErr){
		sprintf(s,"Error %d. Impossible to release the reference of the Beckhoff bP1min variable, Check network connection and contact expert",nErr);//texte à changer
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	//butée max 
	//on demande la référence
	nErr = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(HdlbP2max), &HdlbP2max, strlen(Setbuteemax)+1,Setbuteemax);
	if (nErr){
      sprintf(s,"Error %d. Access to the reference of the Beckhoff bp2max not possible, Check network connection and contact expert",nErr);//texte à changer
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
	}else {
		//lecture de bP2max :
		nErr = AdsSyncReadReq(pAddr, ADSIGRP_SYM_VALBYHND, HdlbP2max, sizeof(ValToRead_bP2max), &ValToRead_bP2max); 
		if (nErr){
			sprintf(s,"Error %d. Impossible to Read the value of bP2max, Check network connection and contact expert",nErr);//texte à changer
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
 		}
	}
	//Libere la reference sur la variable bP2max
	nErr = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(HdlbP2max), &HdlbP2max);
	if (nErr){
		sprintf(s,"Error %d. Impossible to release the reference of the Beckhoff bP2max variable, Check network connection and contact expert",nErr);//texte à changer
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	}
	sprintf(s,"%d", ValToRead_bP1min+2*ValToRead_bP2max);
	//0-> aucune butée atteinte
	//1-> butée min
	//2-> butée max
	//3-> impossible
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK; 
}

	
