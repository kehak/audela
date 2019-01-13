/* telescop.c
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
 *
 * ----------------------------
 * ----------------------------
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include <stdio.h>
#include "telescop.h"
#include <libtel/util.h>
#include <libtel/util.h>

 /*
 *  Definition of different telescopes supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"Telescope Script",    /* telescope name */
    "Telescope Script",    /* protocol name */
    "telscript",    /* product */
     1.         /* default focal lenght of optic system */
   },
};

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
   char s[1024];
	int threadpb=0,k;
	/*
	Tcl_CmdInfo p;
	int err;
	*/

#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_tel.txt","wt");
   fprintf(f,"Demarre une init\n");
	fclose(f);
#endif
	/* - ce clock format permet de debloquer les prochains acces a cette fonction - */
   //Tcl_Eval(tel->interp,"clock format 1318667930");

	/* - creates mutex -*/
   pthread_mutexattr_init(&mutexAttr);
   pthread_mutexattr_settype(&mutexAttr, PTHREAD_MUTEX_RECURSIVE);
   pthread_mutex_init(&mutex, &mutexAttr);

	/* - create the proc ThreadTel_Init dans l'interpreteur AudeLA -*/
   Tcl_CreateCommand(tel->interp,"ThreadTel_Init", (Tcl_CmdProc *)ThreadTel_Init, (ClientData)NULL, NULL);

	/* - creates the thread -*/
   if (Tcl_Eval(tel->interp, "thread::create { thread::wait } ") == TCL_OK) {
		
		// --- Importe la proc de ThreadTel_Init dans le thread
		strcpy(tel->loopThreadId, Tcl_GetStringResult(tel->interp));
      sprintf(s,"thread::copycommand %s ThreadTel_Init ",tel->loopThreadId);
      if ( Tcl_Eval(tel->interp, s) == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			threadpb=2;
      }

		// --- Importe les procs de libmc dans le thread
      sprintf(s,"foreach mc_proc [info commands mc_*] { thread::copycommand %s $mc_proc }", tel->loopThreadId);
      if ( Tcl_Eval(tel->interp, s) == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			threadpb=3;
      }

		/*
		// --- Importe la proc portalk
		err=Tcl_GetCommandInfo(tel->interp,"thread::porttalk",&p);

		sprintf(s,"thread::copycommand %s thread::porttalk}", tel->loopThreadId);
      if ( Tcl_Eval(tel->interp, s) == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			threadpb=3;
      }
		*/

		// --- Appel des initialisations et fait demarrer la boucle 
		sprintf(s,"thread::send %s {ThreadTel_Init", tel->loopThreadId);
		for (k=0;k<argc;k++) {
			strcat(s," ");
			strcat(s,"\"");
			strcat(s,argv[k]);
			strcat(s,"\"");
		}
		strcat(s,"}");
      if ( Tcl_Eval(tel->interp, s) == TCL_ERROR ) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			threadpb=4;
      }

		// --- On passe ici lorsque la grande boucle du telescope est lancée (?)

	} else {

		strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
		threadpb=1;

	}
#if defined(MOUCHARD)
   f=fopen("mouchard_tel.txt","at");
   fprintf(f,"Fin de l'init. threadpb=%d\n",threadpb);
	fclose(f);
#endif
	return threadpb;
}

int tel_radec_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec init --- */
/* ----------------------------------- */
{
   return mytel_radec_init(tel);
}

int tel_radec_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec coord --- */
/* ------------------------------------ */
{
   return mytel_radec_coord(tel,result);
}

int tel_radec_state(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 radec state --- */
/* ------------------------------------ */
{
   return mytel_radec_state(tel,result);
}

int tel_radec_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 radec goto --- */
/* ----------------------------------- */
{
   return mytel_radec_goto(tel);
}

int tel_radec_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec move --- */
/* ----------------------------------- */
{
   return mytel_radec_move(tel,direction);
}

int tel_radec_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 radec stop --- */
/* ----------------------------------- */
{
   return mytel_radec_stop(tel,direction);
}

int tel_radec_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 radec motor --- */
/* ------------------------------------ */
{
   return mytel_radec_motor(tel);
}

int tel_focus_init(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus init --- */
/* ----------------------------------- */
{
   return mytel_focus_init(tel);
}

int tel_focus_coord(struct telprop *tel,char *result)
/* ------------------------------------ */
/* --- called by : tel1 focus coord --- */
/* ------------------------------------ */
{
   return mytel_focus_coord(tel,result);
}

int tel_focus_goto(struct telprop *tel)
/* ----------------------------------- */
/* --- called by : tel1 focus goto --- */
/* ----------------------------------- */
{
   return mytel_focus_goto(tel);
}

int tel_focus_move(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus move --- */
/* ----------------------------------- */
{
   return mytel_focus_move(tel,direction);
}

int tel_focus_stop(struct telprop *tel,char *direction)
/* ----------------------------------- */
/* --- called by : tel1 focus stop --- */
/* ----------------------------------- */
{
   return mytel_focus_stop(tel,direction);
}

int tel_focus_motor(struct telprop *tel)
/* ------------------------------------ */
/* --- called by : tel1 focus motor --- */
/* ------------------------------------ */
{
   return mytel_focus_motor(tel);
}

int tel_date_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 date --- */
/* ----------------------------- */
{
   return mytel_date_get(tel,ligne);
}

int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
/* ---------------------------------- */
/* --- called by : tel1 date Date --- */
/* ---------------------------------- */
{
   return mytel_date_set(tel,y,m,d,h,min,s);
}

int tel_home_get(struct telprop *tel,char *ligne)
/* ----------------------------- */
/* --- called by : tel1 home --- */
/* ----------------------------- */
{
   return mytel_home_get(tel,ligne);
}

int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
/* ---------------------------------------------------- */
/* --- called by : tel1 home {GPS long e|w lat alt} --- */
/* ---------------------------------------------------- */
{
   return mytel_home_set(tel,longitude,ew,latitude,altitude);
}

int tel_get_position_tube(struct telprop *tel)
/* ---------------------------------------------------- */
/* --- called by : tel1 position_tube               --- */
/* ---------------------------------------------------- */
{
	return PT_UNKNOWN;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage du telescope      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_radec_init(struct telprop *tel) {
   my_pthread_mutex_lock(&mutex);
	telthread->ra0=tel->ra0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"radec_init");
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_init_additional(struct telprop *tel)
 {
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
	int sortie,t0,dt,time_out=300;
	time_t ltime;
   my_pthread_mutex_lock(&mutex);
	telthread->ra0=tel->ra0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"radec_goto");
   my_pthread_mutex_unlock(&mutex);
   if (tel->radec_goto_blocking==1) {
		sortie=0;
		t0=(int)time(&ltime);
		while (sortie==0) {
			libtel_sleep(telthread->after+500);
			my_pthread_mutex_lock(&mutex);
			if (strcmp(telthread->motion_next,"radec_slewing")!=0) {
				sortie=1;
			}
		   my_pthread_mutex_unlock(&mutex);
			dt=(int)time(&ltime);
			if (dt>time_out) {
				sortie=2;
			}
		}
	}
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
	int sortie,t0,dt,time_out=300;
	time_t ltime;
   my_pthread_mutex_lock(&mutex);
	telthread->ha0=tel->ha0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"hadec_goto");
   my_pthread_mutex_unlock(&mutex);
   if (tel->hadec_goto_blocking==1) {
		sortie=0;
		t0=(int)time(&ltime);
		while (sortie==0) {
			libtel_sleep(telthread->after+500);
			my_pthread_mutex_lock(&mutex);
			if (strcmp(telthread->motion_next,"hadec_slewing")!=0) {
				sortie=1;
			}
		   my_pthread_mutex_unlock(&mutex);
			dt=(int)time(&ltime);
			if (dt>time_out) {
				sortie=2;
			}
		}
	}
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   my_pthread_mutex_lock(&mutex);
	telthread->radec_move_rate=tel->radec_move_rate;
	strcpy(telthread->move_direction,direction);
	strcpy(telthread->action_next,"move_start");
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   my_pthread_mutex_lock(&mutex);
	strcpy(telthread->move_direction,direction);
	strcpy(telthread->action_next,"motor_stop");
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   my_pthread_mutex_lock(&mutex);
   if (tel->radec_motor==1) {
		strcpy(telthread->action_next,"motor_off");
   } else {
		strcpy(telthread->action_next,"motor_on");
   }
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   my_pthread_mutex_lock(&mutex);
	sprintf(result,"%f %f",telthread->coord_app_cod_deg_ra,telthread->coord_app_cod_deg_dec);
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_hadec_coord(struct telprop *tel,char *result)
{
   my_pthread_mutex_lock(&mutex);
	sprintf(result,"%f %f",telthread->coord_app_cod_deg_ha,telthread->coord_app_cod_deg_dec);
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_hadec_init(struct telprop *tel)
{
   my_pthread_mutex_lock(&mutex);
	telthread->ha0=tel->ha0;
	telthread->dec0=tel->dec0;
	strcpy(telthread->action_next,"hadec_init");
   my_pthread_mutex_unlock(&mutex);
   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_stop(struct telprop *tel,char *direction)
{
   return 0;
}

int mytel_focus_motor(struct telprop *tel)
{
   return 0;
}

int mytel_focus_coord(struct telprop *tel,char *result)
{
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   /* Get the longitude */
   my_pthread_mutex_lock(&mutex);
   strcpy(tel->home,telthread->home);
   my_pthread_mutex_unlock(&mutex);
   strcpy(ligne,tel->home);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   /* Set the longitude */
   sprintf(tel->home,"GPS %f %s %f %f",longitude,ew,latitude,altitude);
   my_pthread_mutex_lock(&mutex);
   strcpy(telthread->home,tel->home);
   my_pthread_mutex_unlock(&mutex);
   return 0;
}


/*****************************************************************************************/
//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
// TOUTES LES COMMANDES CI-DESSOUS SONT EXECUTEES DANS LE CONTEXTE DU THREAD PERIODIQUE //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////
/*****************************************************************************************/

// Commande d'initialisation du thread (en particulier de la variable telthread)
// ::tel::create telscript com1 -script c:/toto/titi.tcl
int ThreadTel_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char s[1024];
	int kk;
#if defined(MOUCHARD)
   FILE *f;
   f=fopen("mouchard_tel.txt","at");
   fprintf(f,"Debut de ThreadTel_Init\n",threadpb);
	fclose(f);
#endif

	telthread = (struct telprop*) calloc( 1, sizeof(struct telprop) );
	telthread->interp = interp;

	// decode les arguments
	telthread->script_type=SCRIPT_TYPE_FILE;
	strcpy(telthread->telname,"telscript_template_equatorial");
	sprintf(telthread->script,"[pwd]/%s.tcl",telthread->telname);
	sprintf(telthread->script_setup,"[pwd]/%s_setup.tcl",telthread->telname);
	sprintf(telthread->script_loop,"[pwd]/%s_loop.tcl",telthread->telname);
	strcpy(telthread->proc_setup,"setup");
	strcpy(telthread->proc_loop,"loop");
	telthread->after=250;
	strcpy(telthread->home,"GPS 2 E 43 148");
	if (argc >= 1) {
		for (kk = 0; kk < argc-1; kk++) {
			if (strcmp(argv[kk], "-script") == 0) {
				strcpy(telthread->script,argv[kk + 1]);
			}
			if (strcmp(argv[kk], "-setup") == 0) {
				strcpy(telthread->script_setup,argv[kk + 1]);
				strcpy(telthread->proc_setup,argv[kk + 1]);
			}
			if (strcmp(argv[kk], "-loop") == 0) {
				strcpy(telthread->script_loop,argv[kk + 1]);
				strcpy(telthread->proc_loop,argv[kk + 1]);
			}
			if (strcmp(argv[kk], "-telname") == 0) {
				strcpy(telthread->telname,argv[kk + 1]);
				strcpy(tel_ini[0].name,telthread->telname);
			}
			if (strcmp(argv[kk], "-home") == 0) {
				strcpy(telthread->home,argv[kk + 1]);
			}
			if (strcmp(argv[kk], "-after") == 0) {
				telthread->after=atoi(argv[kk + 1]);
				if (telthread->after<1) { telthread->after=1; }
				if (telthread->after>10000) { telthread->after=10000; }
			}
		}
	}

	// initialise les variables avant d'entrer dans la boucle
	strcpy(telthread->action_next,"motor_off");
	strcpy(telthread->action_prev,telthread->action_next);
	strcpy(telthread->motion_next,"stopped");
	strcpy(telthread->motion_prev,telthread->motion_next);
	telthread->coord_app_cod_deg_ra=0;
	telthread->coord_app_cod_deg_dec=0;
	telthread->coord_app_cod_deg_ha=0;
	telthread->ha0=0;
	telthread->ra0=0;
	telthread->dec0=0;
	strcpy(telthread->eval_command_line,"");
	telthread->compteur=0;
	strcpy(telthread->loop_error,"");
	telthread->source=0;
	telthread->radec_move_rate=0;
	strcpy(telthread->move_direction,"N");

	sprintf(s,"set telscript(def,telname) \"%s\"",telthread->telname);
	mytel_tcleval(telthread,s);
	sprintf(s,"file exists \"%s\"",telthread->script);
	mytel_tcleval(telthread,s);
	if (strcmp(Tcl_GetStringResult(telthread->interp),"1")==0) {
		// charge le script general puisqu'il existe
		sprintf(s,"source \"%s\"",telthread->script);
		if (mytel_tcleval(telthread,s)==TCL_ERROR) {
			sprintf(s,"Error in the script %s : %s",telthread->script,Tcl_GetStringResult(telthread->interp));
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		// verifie la presence de la proc setup
		sprintf(s,"info procs %s",telthread->proc_setup);
		mytel_tcleval(telthread,s);
		if (strcmp(Tcl_GetStringResult(telthread->interp),"")==0) {
			sprintf(s,"Error, script %s does not contain proc %s",telthread->script,telthread->proc_setup);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		// verifie la presence de la proc loop
		sprintf(s,"info procs %s",telthread->proc_loop);
		mytel_tcleval(telthread,s);
		if (strcmp(Tcl_GetStringResult(telthread->interp),"")==0) {
			sprintf(s,"Error, script %s does not contain proc %s",telthread->script,telthread->proc_loop);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		// execute la proc setup
		if (mytel_tcleval(telthread,telthread->proc_setup)==TCL_ERROR) {
			return TCL_ERROR;
		}
		telthread->script_type=SCRIPT_TYPE_PROC;
	} else {
		// --- le script general n'existe pas
		sprintf(s,"file exists \"%s\"",telthread->script_setup);
		mytel_tcleval(telthread,s);
		if (strcmp(Tcl_GetStringResult(telthread->interp),"0")==0) {
			sprintf(s,"Error, the script %s does not exist.",telthread->script);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		// charge le script du setup
		sprintf(s,"source \"%s\"",telthread->script_setup);
		mytel_tcleval(telthread,s);
		if (mytel_tcleval(telthread,s)==TCL_ERROR) {
			sprintf(s,"Error in the script %s. %s",telthread->script_setup,Tcl_GetStringResult(telthread->interp));
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		telthread->script_type=SCRIPT_TYPE_FILE;
	}

	// initialisation des commandes tcl necessaires au fonctionnement en boucle.
	Tcl_CreateCommand(telthread->interp,"ThreadTel_loop", (Tcl_CmdProc *)ThreadTel_loop, (ClientData)telthread, NULL);
	sprintf(s,"proc TTel_Loop {} { global telscript ; ThreadTel_loop ; after %d TTel_Loop }",telthread->after);
	mytel_tcleval(telthread,s);

	// Lance le fonctionnement en boucle.
	mytel_tcleval(telthread,"TTel_Loop");

	return TCL_OK;
}

/************************/
/*** Boucle du thread ***/
/************************/
int ThreadTel_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[1024]; 

	if (telthread->exit==1) {
		free(telthread);
		telthread=NULL;
		return TCL_ERROR;
	}

   my_pthread_mutex_lock(&mutex);

	telthread->compteur++;

	/********************************************/
   /*** update variables from tel1 functions ***/
	/********************************************/
	sprintf(s,"set telscript(%s,action_next) %s",telthread->telname,telthread->action_next);
	mytel_tcleval(telthread,s);
	sprintf(s,"set telscript(%s,action_prev) %s",telthread->telname,telthread->action_prev);
	mytel_tcleval(telthread,s);
	sprintf(s,"set telscript(%s,ra0) %f",telthread->telname,telthread->ra0);
	mytel_tcleval(telthread,s);
	sprintf(s,"set telscript(%s,ha0) %f",telthread->telname,telthread->ha0);
	mytel_tcleval(telthread,s);
	sprintf(s,"set telscript(%s,dec0) %f",telthread->telname,telthread->dec0);
	mytel_tcleval(telthread,s);
	sprintf(s,"set telscript(%s,home) {%s}",telthread->telname,telthread->home);
	mytel_tcleval(telthread,s);
	sprintf(s,"set telscript(%s,radec_move_rate) %f",telthread->telname,telthread->radec_move_rate);
	mytel_tcleval(telthread,s);
	sprintf(s,"set telscript(%s,move_direction) {%s}",telthread->telname,telthread->move_direction);
	mytel_tcleval(telthread,s);

	/****************************************/
   /*** check and execute a command line ***/
	/****************************************/
	// --- eval une ligne Tcl
	if (strcmp(telthread->eval_command_line,"")!=0) {
		mytel_tcleval(telthread,telthread->eval_command_line);
		strcpy(telthread->eval_result,Tcl_GetStringResult(telthread->interp));
		strcpy(telthread->eval_command_line,"");
	}

	/**************************/
   /*** call the proc loop ***/
	/**************************/
	strcpy(telthread->loop_error,"");
	if (telthread->script_type==SCRIPT_TYPE_PROC) {
		if (telthread->source==1) {
			// recharge eventuellement le script de la boucle
			sprintf(s,"source \"%s\"",telthread->script);
			mytel_tcleval(telthread,s);
			if (mytel_tcleval(telthread,s)==TCL_ERROR) {
				strcat(telthread->loop_error,Tcl_GetStringResult(telthread->interp));
				strcat(telthread->loop_error,". ");
			}
		}
		telthread->source=0;
		// execute la proc de la boucle
		strcpy(s,telthread->proc_loop);
		mytel_tcleval(telthread,s);
	} else {
		// charge le script de la boucle
		sprintf(s,"source \"%s\"",telthread->script_loop);
		mytel_tcleval(telthread,s);
	}
	if (mytel_tcleval(telthread,s)==TCL_ERROR) {
		strcat(telthread->loop_error,Tcl_GetStringResult(telthread->interp));
	}

	/*******************************************/
   /*** commit variables for tel1 functions ***/
	/*******************************************/
	sprintf(s,"set telscript(%s,action_next)",telthread->telname);
	mytel_tcleval(telthread,s);
	strcpy(telthread->action_next,Tcl_GetStringResult(telthread->interp));
	strcpy(telthread->action_prev,Tcl_GetStringResult(telthread->interp));

	sprintf(s,"set telscript(%s,motion_next)",telthread->telname);
	mytel_tcleval(telthread,s);
	strcpy(telthread->motion_next,Tcl_GetStringResult(telthread->interp));
	strcpy(telthread->motion_prev,Tcl_GetStringResult(telthread->interp));

	sprintf(s,"set telscript(%s,message)",telthread->telname);
	mytel_tcleval(telthread,s);
	strcpy(telthread->message,Tcl_GetStringResult(telthread->interp));

	strcpy(s,"set res \"\" ; foreach name [array names telscript] { lappend res [list telscript($name) $telscript($name)] } ; set res");
	mytel_tcleval(telthread,s);
	strcpy(telthread->variables,Tcl_GetStringResult(telthread->interp));

	// --- Variables speciales pour mettre a jour "tel1 radec coord"
	sprintf(s,"set telscript(%s,coord_app_cod_deg_ha)",telthread->telname);
	if (mytel_tcleval(telthread,s)==TCL_OK) {
		telthread->coord_app_cod_deg_ha=atof(Tcl_GetStringResult(telthread->interp));
	}
	sprintf(s,"set telscript(%s,coord_app_cod_deg_ra)",telthread->telname);
	if (mytel_tcleval(telthread,s)==TCL_OK) {
		telthread->coord_app_cod_deg_ra=atof(Tcl_GetStringResult(telthread->interp));
	}
	sprintf(s,"set telscript(%s,coord_app_cod_deg_dec)",telthread->telname);
	if (mytel_tcleval(telthread,s)==TCL_OK) {
		telthread->coord_app_cod_deg_dec=atof(Tcl_GetStringResult(telthread->interp));
	}

	my_pthread_mutex_unlock(&mutex);

	return TCL_OK;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
	/* Is the drive pointer valid ? */
		return 1;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
	// close the channel
	telthread->exit=1; // envoie un signal de sortie
	libtel_sleep(500); // attente superieur a la duree d'une boucle
	my_pthread_mutex_unlock(&mutex);
   pthread_mutexattr_destroy(&mutexAttr);
   pthread_mutex_destroy(&mutex);
   return 0;
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */


//#define MOUCHARD_EVAL

int mytel_tcleval(struct telprop *tel,char *ligne)
{
   int result;
#if defined(MOUCHARD_EVAL)
   FILE *f;
   f=fopen("mouchard_tel.txt","at");
   fprintf(f,"%s\n",ligne);
#endif
   result = Tcl_Eval(tel->interp,ligne);
#if defined(MOUCHARD_EVAL)
   fprintf(f,"# [%d] = %s\n", result, Tcl_GetStringResult(tel->interp));
   fclose(f);
#endif
   return result;
}

int my_pthread_mutex_lock (pthread_mutex_t * mutex) {
   return(pthread_mutex_lock(mutex));
}

int my_pthread_mutex_unlock (pthread_mutex_t * mutex) {
   return(pthread_mutex_unlock(mutex));
}

/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */

/* Dans ce driver, ce sont les scripts Tcl qui devraient remplacer cette partie */
