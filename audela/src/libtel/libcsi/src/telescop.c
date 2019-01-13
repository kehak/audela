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
#include <libtel/libtel.h>
#include <libtel/util.h>

//extern int csi_init_socket(void);
//extern void csi_doCmd (char *buf);
//extern void csi_loop_socket(struct telprop *tel, char *res);

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"CSI",    /* telescope name */
    "CSI",    /* protocol name */
    "Clear Sky Institute",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

/********************************************************/
/* sate_move_radec                                      */
/* ' ' : pas de mouvement                               */
/* 'A' : mouvement demande en mode Temma (radec goto)   */
/*                                                      */
/********************************************************/
char sate_move_radec;

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
   unsigned short ip[4];
   char ipstring[50],portstring[50],s[1024];
   int k, kk, kdeb, nbp, klen,startmotor=0;
   Tcl_DString dsptr;
   const char **argvv=NULL;
   int argcc,res;
   //FILE *f;

	/*
   f=fopen("mouchard_csi.txt","wt");
   fclose(f);
	*/
	/* --- decode type (umac by default) ---*/
	strcpy(s,"csi");
   if (argc >= 1) {
      for (kk = 0; kk < argc; kk++) {
         if (strcmp(argv[kk], "-type") == 0) {
            if ((kk + 1) <= (argc - 1)) {
               strcpy(s, argv[kk + 1]);
            }
         }
      }
   }
	tel->security = 1;
	tel->enable_dome = 1;
   tel->type=0;
	tel->simultaneus=1;
	tel->track_diurnal=0.004180983;
	/* =================== */
	/* === CSI classic === */
	/* =================== */
	if (tel->type==0) {
	   tel->tempo=1000;
	   tel->tempo_exe = 200;
		/* --- decode IP  --- */
		ip[0] = 146;
		ip[1] = 226;
		ip[2] = 87;
		ip[3] = 7;
		if (argc >= 1) {
			for (kk = 0; kk < argc; kk++) {
				if (strcmp(argv[kk], "-ip") == 0) {
					if ((kk + 1) <= (argc - 1)) {
						strcpy(ipstring, argv[kk + 1]);
					}
				}
			}
		}
		klen = (int) strlen(ipstring);
		nbp = 0;
		for (k = 0; k < klen; k++) {
			if (ipstring[k] == '.') {
				nbp++;
			}
		}
		if (nbp == 3) {
			kdeb = 0;
			nbp = 0;
			for (k = 0; k <= klen; k++) {
				if ((ipstring[k] == '.') || (ipstring[k] == '\0')) {
					ipstring[k] = '\0';
					ip[nbp] = (unsigned short) (unsigned char) atoi(ipstring + kdeb);
					kdeb = k + 1;
					nbp++;
				}
			}
		}
		sprintf(tel->ip, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
		/*
		f=fopen("mouchard_csi.txt","at");
		fprintf(f,"IP=%s\n",tel->ip);
		fclose(f);
		*/
		/* --- decode port  --- */
		tel->port = 51717;
		if (argc >= 1) {
			for (kk = 0; kk < argc; kk++) {
				if (strcmp(argv[kk], "-port") == 0) {
					if ((kk + 1) <= (argc - 1)) {
						strcpy(portstring, argv[kk + 1]);
						tel->port = atoi(portstring);
					}
				}
			}
		}
		/*
		f=fopen("mouchard_csi.txt","at");
		fprintf(f,"PORT=%d\n",tel->port);
		fclose(f);
		*/
		/* --- open the port and record the channel name ---*/
		

		sprintf(s,"socket \"%s\" \"%d\"",tel->ip,tel->port);
		//sprintf(s,"after 5 {set connected timeout} ; set sock [socket -async \"%s\" \"%d\"] ; fileevent $sock w {set connected ok} ; vwait connected ; if {$connected==\"timeout\"} {set sock \"\"} else {set sock}",tel->ip,tel->port);
		//strcpy(s,"open com1 w+");
		if (mytel_tcleval(tel,s)==1) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			return 1;
		}
		if (strcmp(Tcl_GetStringResult(tel->interp),"")==0) {
			strcpy(tel->msg,"Timeout connexion");
			return 1;
		}
		strcpy(tel->channel,Tcl_GetStringResult(tel->interp));

		/* --- configuration of the TCP socket ---*/
		// Decide what is the best: blocking or not blocking
		sprintf(s,"fconfigure %s  -buffering none -blocking 1 -buffersize 1000",tel->channel); mytel_tcleval(tel,s);
		//sprintf(s,"fconfigure %s  -buffering none -blocking 0 -eofchar {} -buffersize 1000",tel->channel); mytel_tcleval(tel,s);

		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		/* --- decode init command list --- */
		Tcl_DStringInit(&dsptr);
		if (argc >= 1) {
			for (kk = 0; kk < argc; kk++) {
				if (strcmp(argv[kk], "-init") == 0) {
					if ((kk + 1) <= (argc - 1)) {
						Tcl_DStringAppend(&dsptr,argv[kk + 1],-1);
					}
				}
				if (strcmp(argv[kk], "-startmotor") == 0) {
					startmotor=1;
				}
			}
		}
		if (strcmp(Tcl_DStringValue(&dsptr),"")==0) {
			Tcl_DStringAppend(&dsptr,"",-1); // TBD inits of connections
		}
		/* --- execute init command list--- */
		if (strcmp(Tcl_DStringValue(&dsptr),"")!=0) {
			if (Tcl_SplitList(tel->interp,Tcl_DStringValue(&dsptr),&argcc,&argvv)==TCL_OK) {
				for (k=0;k<argcc;k++) {
					res=csi_put(tel,(char*)argvv[k]);
					if (res==1) {
						Tcl_Free((char *) argvv);
						return TCL_ERROR;
					}
					res=csi_read(tel,s);
				}
				Tcl_Free((char *) argvv);
			}
		}
		/* --- sppeds --- */
		tel->speed_track_ra=tel->track_diurnal; /* (deg/s) */
		tel->speed_track_dec=0.; /* (deg/s) */
		tel->speed_slew_ra=6.7; /* (deg/s) */
		tel->speed_slew_dec=6.7; /* (deg/s) */
		tel->radec_speed_ra_conversion=36044.8; /* (ADU)/(deg) */
		tel->radec_speed_dec_conversion=36044.8; /* (ADU)/(deg) */
		tel->radec_position_conversion=-12976128/360.; /* (ADU)/(deg) */
		tel->radec_move_rate_max=1.0; /* deg/s */
		tel->radec_tol=10 ; /* 10 arcsec */
		tel->dead_delay_slew=-4.0; /* delai en secondes estime pour un slew sans bouger */
		tel->refrac_delay=0;
		tel->refrac_div=1;
		tel->ontrack=0;
		if (startmotor==1) {
			tel->radec_motor=0;
			csi_suivi_marche(tel);
			tel->ontrack=1;
		}
		tel->trackingduration=3600;
		/* --- Match --- */
		tel->ha00=0.;
		tel->roth00=(int)(-1842845);
		tel->dec00=23.89039445;
		tel->rotd00=(int)(0);
		/* --- stops --- */
		tel->stop_e_uc=-13900;
		tel->stop_w_uc=3090000;
		/* --- Home --- */
		tel->latitude=18.35232;
		sprintf(tel->home0,"GPS 64.95678611 W %+.6f 421",tel->latitude);
	}
   /* --- sortie --- */
   Tcl_DStringFree(&dsptr);
   return 0;
}

int tel_testcom(struct telprop *tel)
/* -------------------------------- */
/* --- called by : tel1 testcom --- */
/* -------------------------------- */
{
   return 0;
}

int tel_close(struct telprop *tel)
/* ------------------------------ */
/* --- called by : tel1 close --- */
/* ------------------------------ */
{
   csi_delete(tel);
   return 0;
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
/* --- called by : tel1 home {PGS long e|w lat alt} --- */
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

int mytel_radec_init(struct telprop *tel)
/* init of the telescope */
{
   csi_init(tel);
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int state;
   csi_stategoto(tel,&state);
   if (state==1) {strcpy(result,"tracking");}
   else if (state==2) {strcpy(result,"pointing");}
   else {strcpy(result,"unknown");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   /*
   int nbgoto=2;
	if ((tel->speed_slew_ra>30)&&(tel->speed_slew_dec>30)) {
		// -- pas de double pointage en cas de tres grande vitesse
		// pour gagner environ 2.4 secondes (pour alertes sursauts gamma).
		nbgoto=1;
	}
	//clock00 = clock();
	if (tel->ontrack) csi_suivi_arret(tel);
	csi_dome_rotate(tel);
	csi_goto(tel);  // always blocking
	sate_move_radec='A';
   if (nbgoto>1) {
      csi_goto(tel);  // always blocking
   }
   csi_suivi_marche(tel);
   sate_move_radec=' ';
   */
   csi_supergoto(tel,TYPE_RADEC); 
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
   /*
   double ha0,dt;
   int h,m;
   double sec,lst;

   if (tel->ontrack) csi_suivi_arret(tel);
   ha0=tel->ra0;
   dt=tel->dead_delay_slew/86400;
   lst=csi_tsl(tel,&h,&m,&sec,dt);
   tel->ra0=lst-ha0+360*5;
   tel->ra0=fmod(tel->ra0,360),
   csi_dome_rotate(tel);
   tel->ra0=ha0;
   csi_hadec_goto(tel); // always blocking
   sate_move_radec='A';
   csi_suivi_marche(tel);
   */
   csi_supergoto(tel,TYPE_HADEC);    
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
/*
* #1I122=v en horaire
* #2I222=v en delta
# v=(deg/s)*10
*/
{
   char s[1024],direc[10],axe;
   int duration_ms,delta_inc;
   int track_mode;
	double r,d,r1,r2,d1,d2;
   
   if (tel->radec_move_rate>1.0) {
      tel->radec_move_rate=1;
   } else if (tel->radec_move_rate<0.) {
      tel->radec_move_rate=0.;
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   sprintf(s,"lindex [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
	duration_ms=1000;
	// rate = [0;0.25]   ]0.25;0.5]        ]0.5;0.75] ]0.75;1.00]
	// degs = [0 5/3600] ]5/3600;60/3600] ]60/3600;0.25] ]0.25:2]
	r = tel->radec_move_rate;
	if (r<=0.25) {
		r1=0; r2=0.25;
		d1=0; d2=5/3600.;
	} else if (tel->radec_move_rate<=0.5) {
		r1=0.25; r2=0.5;
		d1=5/3600.; d2=60/3600.;
	} else if (tel->radec_move_rate<=0.75) {
		r1=0.5; r2=0.75;
		d1=60/3600.; d2=0.25;
	} else {
		r1=0.75; r2=1.0;
		d1=0.25; d2=2.;
	}
	d = (r-r1)/(r2-r1)*(d2-d1)+d1;
	delta_inc=(int)fabs(d*tel->radec_position_conversion);
	axe=' ';
	track_mode = tel->ontrack;
	if (tel->ontrack) csi_suivi_arret(tel);
   if (strcmp(direc,"N")==0) {
		axe='2';
		sprintf(s,"!%c; followme(%d,%d);",axe,delta_inc,duration_ms);
   } else if (strcmp(direc,"S")==0) {
		axe='2';
		sprintf(s,"!%c; followme(%d,%d);",axe,delta_inc,duration_ms);
   } else if (strcmp(direc,"E")==0) {
		axe='1';
		sprintf(s,"!%c; followme(%d,%d);",axe,delta_inc,duration_ms);
   } else if (strcmp(direc,"W")==0) {
		axe='1';
		sprintf(s,"!%c; followme(%d,%d);",axe,delta_inc,duration_ms);
   }
	if (axe!=' ') {
		csi_put(tel,s);
		csi_read(tel,s);
		libtel_sleep(duration_ms+200);
		if (track_mode==1) {
	      csi_suivi_marche(tel);
		}
	}
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   if (sate_move_radec=='A') {
      /* on arrete un GOTO */
      csi_stopgoto(tel);
      sate_move_radec=' ';
   }
   return 0;
}

int mytel_radec_motor(struct telprop *tel)
{
   char s[1024];
   sprintf(s,"after 20"); mytel_tcleval(tel,s);
   if (tel->radec_motor==1) {
      /* stop the motor */
      csi_suivi_arret(tel);
   } else {
      /* start the motor */
      csi_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   csi_coord(tel,result);
   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
    csi_focus_init(tel);
	return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   csi_focus_goto(tel);
   return 0;
}

int mytel_focus_move(struct telprop *tel,char *direction)
{
   csi_focus_move(tel,direction);
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
   csi_focus_coord(tel,result);
   return 0;
}

int mytel_date_get(struct telprop *tel,char *ligne)
{
   libtel_GetCurrentUTCDate(tel->interp,ligne);
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   strcpy(ligne,tel->home0);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   longitude=(double)fabs(longitude);
   if (longitude>360.) { longitude=0.; }
   if ((ew[0]!='w')&&(ew[0]!='W')&&(ew[0]!='e')&&(ew[0]!='E')) {
      ew[0]='E';
   }
   if (latitude>90.) {latitude=90.;}
   if (latitude<-90.) {latitude=-90.;}
   sprintf(tel->home0,"GPS %f %c %f %f",longitude,ew[0],latitude,altitude);
   tel->latitude=latitude;
   return 0;
}

int mytel_hadec_coord(struct telprop *tel,char *result)
{
   csi_hadec_coord(tel,result);
   return 0;
}

int mytel_motor_coord(struct telprop *tel,char *result)
{
   csi_motor_coord(tel,result);
   return 0;
}

int mytel_encoder_coord(struct telprop *tel,char *result)
{
   csi_encoder_coord(tel,result);
   return 0;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions etendues pour le pilotage du telescope     === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque telescope.          */
/* ================================================================ */

int mytel_tcleval(struct telprop *tel,char *ligne)
{
	/*
   FILE *f;
   f=fopen("mouchard_csi.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   fclose(f);
	*/
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {
		/*
      f=fopen("mouchard_csi.txt","at");
      fprintf(f,"RESU-PB <%s>\n",Tcl_GetStringResult(tel->interp));
      fclose(f);
		*/
      return 1;
   }
	/*
   f=fopen("mouchard_csi.txt","at");
   fprintf(f,"RESU-OK <%s>\n",Tcl_GetStringResult(tel->interp));
   fclose(f);
	*/
   return 0;
}

int csi_delete(struct telprop *tel)
{
   char s[1024];
	if (tel->type==0) {
		/* --- Fermeture du port com */
		sprintf(s,"close %s ",tel->channel); mytel_tcleval(tel,s);
	}
   return 0;
}

int csi_put(struct telprop *tel,char *cmd)
{
   char s[1024];
	/*char ss[1024];*/
   FILE *f;
   f=fopen("mouchard_csi.txt","at");
   //fprintf(f,"PUT <%s>\n",cmd);
   fclose(f);
	// flush any pending info
    //sprintf(s,"flush %s",tel->channel);
	//mytel_tcleval(tel,s);

	// send the order
	if ((tel->type==0)&&(strcmp(cmd,"")!=0)) {
		if (cmd[0]!='#') {
			sprintf(s,"puts -nonewline %s \"%s%%\"",tel->channel,cmd);
			//sprintf(ss,"puts \"PUT s=<%s> envoye\"",s);
			//mytel_tcleval(tel,ss);
			//mytel_tcleval(tel,s);	
			if (mytel_tcleval(tel,s)==1) {
            strcpy(s,Tcl_GetStringResult(tel->interp));
				return 1;
			}
			//sprintf(s,"flush %s",tel->channel);
			//mytel_tcleval(tel,s);
	   
		}
	}
   return 0;
}

int csi_read(struct telprop *tel,char *res)
{
	char s[2048];
	FILE *f;
	if (tel->type==0) {
		/* --- trancoder l'hexadécimal de res en numérique ---*/
		sprintf(s,"gets %s",tel->channel); // read -nonewline
		if (mytel_tcleval(tel,s)==1) {
			strcpy(res,Tcl_GetStringResult(tel->interp));
			return 1;
		}
	   //sprintf(s,"flush %s",tel->channel);
	   //mytel_tcleval(tel,s);
	   strcpy(res,Tcl_GetStringResult(tel->interp));
		/*
		n=(int)strlen(res);
		if (n>=1) {
			res[n-1]='\0';
		}*/
		
	}
	if (!strcmp(res, "")) {
		if (csi_read(tel, res)==1) return 1;
	}
	else {
		f=fopen("mouchard_csi.txt","at");
		//fprintf(f,"READ <%s>\n",res);
		fclose(f);
	}
	
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage csi   --------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int csi_arret_pointage(struct telprop *tel)
{
   char s[1024],axe1,axe2;
   /*--- Arret pointage */
   axe1='1';
   axe2='2';
   sprintf(s,"!%c; stop(); wait();",axe1);
   csi_put(tel,s);
   csi_read(tel,s);
   sprintf(s,"!%c; stop(); wait();",axe2);
   csi_put(tel,s);
   csi_read(tel, s);
	tel->radec_motor=0;
	if (tel->ontrack==1) {
		csi_suivi_marche (tel);
	}
   return 0;
}

int csi_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024],axe;
   int res;
   char ras[20];
   char decs[20];   
   int roth_uc,rotd_uc;
   int h,m,retournement=0;
   double sec,lst,ha,dec=0,ra=0;
   /* --- Vide le buffer --- */
   //res=csi_read(tel,s);
   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
   axe='2';
   sprintf(ss,"!%c; =epos;",axe);
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res==0) {
      rotd_uc=atoi(s);
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      if (fabs(dec)>90) {
         retournement=1;
         dec=(tel->latitude)/fabs(tel->latitude)*180-dec;
      }
   }
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"!%c; =epos;",axe);
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res==0) {
      roth_uc=atoi(s);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      /* H=TSL-alpha => alpha=TSL-H */
      lst=csi_tsl(tel,&h,&m,&sec,0);
      ra=lst-ha+360*5;
      if (retournement==1) {
         ra+=180.;
      }
      ra=fmod(ra,360.);
   }
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 0 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2dms %f 90 zero 0 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int csi_motor_coord(struct telprop *tel,char *result) {
   int res;
   char s[256], ss[256], temp[256];
   strcpy(ss,"!1; =mpos;");
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res == 0) {
           strcpy(temp, s);
   } else {
           strcpy(temp, "NaN");
   }
   strcpy(ss,"!2; =mpos;");
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res == 0) {
           sprintf(result, "%s %s", temp, s);
   } else {
           sprintf(result, "%s %s", temp, "NaN");
   }
	return 0;

}

int csi_encoder_coord(struct telprop *tel,char *result) {
   int res;
   char s[256], ss[256], temp[256];
   strcpy(ss,"!1; =epos;");
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res == 0) {
	   strcpy(temp, s);
   } else {
	   strcpy(temp, "NaN");
   }
   strcpy(ss,"!2; =epos;");
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res == 0) {
           sprintf(result, "%s %s", temp, s);
   } else {
           sprintf(result, "%s %s", temp, "NaN");
   }
	return 0;

}

int csi_hadec_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024],axe;
   int res;
   char ras[20];
   char decs[20];   
   int roth_uc,rotd_uc;
   int retournement=0;
   double ha,dec=0,ra=0;
   /* --- Vide le buffer --- */
   //res=csi_read(tel,s);
   /* --- Lecture AXE 2 (delta) en premier pour tester le retournement --- */
   axe='2';
   sprintf(ss,"!%c; =epos;",axe);
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res==0) {
      rotd_uc=atoi(s);
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      if (fabs(dec)>90) {
         retournement=1;
         dec=(tel->latitude)/fabs(tel->latitude)*180-dec;
      }
   }
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"!%c; =epos;",axe);
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res==0) {
      roth_uc=atoi(s);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      ra=ha+360*5;
      if (retournement==1) {
         ra+=180.;
      }
      ra=fmod(ra,360.);
   }
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 0 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2dms %f 90 zero 0 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int csi_positions12(struct telprop *tel,int *p1,int *p2)
/*
* Coordonnées en ADU
*/
{
   char s[1024],ss[1024],axe1,axe2;
   int res;
	double pp1,pp2;
   
   /* --- Vide le buffer --- */
   //res=csi_read(tel,s);
   sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
   /* --- Lecture AXE 1 (horaire) et AXE 2 (declinaison) --- */
   axe1='1';
   axe2='2';
   
   // Axe 1
   sprintf(ss,"!%c; =epos;",axe1);
   res=csi_put(tel,ss);
   sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
   res=csi_read(tel,s);
   sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
   if (res==0) {
		sscanf(s,"%lf",&pp1);
        *p1=(int)(pp1);
   } else {
	   return 1;
	}

   // Axe 2
   sprintf(ss,"!%c; =epos;",axe2);
   res=csi_put(tel,ss);
   sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
   res=csi_read(tel,s);
   sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
   if (res==0) {
	  sscanf(s,"%lf",&pp2);
      *p2=(int)(pp2);
	   return 0;
   } else {
	   return 1;
	}
}

int csi_init(struct telprop *tel)
{
   char s[1024],ss[1024],axe;
   int res;
   
   double ha,dec,lst,sec;
   int h,m;

   // Compute the RA/DEC for home
   // H=TSL-alpha => alpha=TSL-H
   ha = -50.96063077; // value fixed at home
   dec = 24.06015385; // value fixed at home
   lst=csi_tsl(tel,&h,&m,&sec,0);
   tel->ra0=lst-ha+360*5;
   tel->ra0=fmod(tel->ra0,360.);
   tel->dec0 = dec;
   
   // --- Lecture AXE 1 (horaire) ---
   axe='1';
   sprintf(ss,"!%c; =epos;",axe);
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res==0) {
      tel->roth00=atoi(s);
      tel->ha00=ha;
   }
   /* --- Lecture AXE 2 (delta) --- */
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   axe='2';
   sprintf(ss,"!%c; =epos;",axe);
   res=csi_put(tel,ss);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=csi_read(tel,s);
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (strcmp(s,"")==0) {
      res=csi_put(tel,ss);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,s);
   }
   if (res==0) {
      tel->rotd00=atoi(s);
      tel->dec00=tel->dec0;
   }
   // Align the dome and the telescope (optional, not coded for the moment)
   /* --- --- */
   return 0;
}

int csi_goto(struct telprop *tel)
{
   char s[1024],axe,s1[1024],s2[1024];
   int retournement=0;
   int p;
   double v,dt;
   double ha,lst,sec;
   int h,m;
   /* --- Effectue le pointage RA --- */
   /* H=TSL-alpha => alpha=TSL-H */
   dt=tel->dead_delay_slew/86400;
   lst=csi_tsl(tel,&h,&m,&sec,dt);
   ha=lst-tel->ra0+360*5;
   ha=fmod(ha,360.);
	if (ha>180) {
		ha=ha-360;
	}
   p=(int)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion);
   axe='1';
   v=fabs(tel->speed_slew_ra*tel->radec_speed_ra_conversion);
	sprintf(s1,"etpos=%d;",p);
   /* --- Effectue le pointage DEC --- */
   if (retournement==1) {
      v=(tel->latitude)/fabs(tel->latitude)*180-tel->dec0;
   } else {
      v=tel->dec0;
   }
   p=(int)(tel->rotd00-(v-tel->dec00)*tel->radec_position_conversion);
   axe='2';
   v=fabs(tel->speed_slew_ra*tel->radec_speed_dec_conversion); 
   /* --- Slew simultaneously or not --- */
	if (tel->simultaneus==1) {
		sprintf(s2,"etpos@%c=%d;",axe,p);
		sprintf(s,"!1; %s %s wait();",s1,s2);
		csi_put(tel,s);
		csi_read(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
	} else {
		sprintf(s,"!2; %s wait();",s2);
		csi_put(tel,s);
		csi_read(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		sprintf(s,"!1; %s wait();",s1);
		csi_put(tel,s);
		csi_read(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
	}
   return 0;
}

/*
 * suivi -> arret
 * dome -> rotate
 * goto
 * suivi -> marche
 */
int csi_supergoto(struct telprop *tel,int type_coord)
{
   char s[1024],ss[1024];
   double dt=0,sec,lst,ha;
	int dur=1,De_ra=0,De_dec=0;   
   int h,m;   
   long position_dome,tol_dome;
   long position_ha,tol_ha;
   long position_dec,tol_dec;
   double tol_dome_deg,tol_ha_deg,tol_dec_deg;
   int do_tracking;
   int nbgoto,kgoto,valid;
   double azimut,altitude,dec;
   
   // --- Pointing security 
   if (tel->security==1) {
      valid=1;
      if (type_coord!=TYPE_ALTAZ) {
         dec=tel->dec0;
         if (type_coord==TYPE_RADEC) {
            lst=csi_tsl(tel,&h,&m,&sec,0);
            ha=lst-tel->ra0+360*5+2/1440*360;
         } else {
            ha=tel->ra0;
         }
         ha=fmod(ha,360.);
         if (ha>180) {
            ha=ha-360;
         };
         // conversion of the local az to dome
         csi_hd2ah(ha,dec,18.33,&azimut,&altitude);
      } else {
         altitude=tel->dec0;
         dec=0;
      }
      if ((altitude<19)&&(dec>70)) {
         valid=0;
      } else if (dec<-65) {
         valid=0;
      } else {
         if (altitude<5) {
            valid=0;
         }
      }
      if (valid==0) {
         return 1;
      }
   }
   
   // --- configuration
   if (type_coord==TYPE_RADEC) {
      nbgoto=2;
   } else {
      nbgoto=1;
   }
   do_tracking=0;
   
   // --- suivi arret
	tel->radec_motor=0;
	tel->ontrack=0;
   
   for (kgoto=1 ; kgoto<=nbgoto ; kgoto++) {
      
      // --- configuration
      if (kgoto==1) {
         tol_dome_deg = 3; // tolerence en deg
      } else {
         //strcpy(s,"after 10000"); mytel_tcleval(tel,s);
         tol_dome_deg = 0.8; // tolerence en deg
      }
      if ((type_coord==TYPE_RADEC)&&(kgoto==nbgoto)) {
         do_tracking=1;
      }

      tol_ha_deg = tel->radec_tol/3600; // tolerence en deg
      tol_dec_deg = tel->radec_tol/3600; // tolerence en deg

      // --- dome rotate   
      position_dome = csi_dome_compute_azimuth(tel,type_coord); // uc
      if (tel->enable_dome == 0) {
         tol_dome_deg = 1000;
      }
      if ((type_coord==TYPE_RADEC)&&(kgoto==nbgoto)&&(nbgoto>1)) {
         tol_dome_deg = 1000;
      }
      tol_dome = (long) floor(encoder*tol_dome_deg/360.0); // uc

      // --- Calcule le pointage en (HA,Dec) a partir de (RA,Dec)
      // H=TSL-alpha => alpha=TSL-H  
      if (type_coord==TYPE_RADEC) {
         dt=tel->dead_delay_slew/86400;
         lst=csi_tsl(tel,&h,&m,&sec,dt);
         ha=lst-tel->ra0+360*5;
      } else {
         ha=tel->ra0+360*5;
      }
      ha=fmod(ha,360.);
      if (ha>180) {
         ha=ha-360;
      }
      position_ha=(long)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion); //uc
      tol_ha=(long) floor(tel->radec_position_conversion*tol_ha_deg); // uc
      position_dec=(long)(tel->rotd00-(tel->dec0-tel->dec00)*tel->radec_position_conversion); //uc
      tol_dec=(long) floor(tel->radec_position_conversion*tol_dec_deg); // uc

      // --- suivi marche
      if (do_tracking==1) {   
         csi_compute_tracking(tel,&De_ra,&De_dec,&dur);
         tel->radec_motor=1;
         tel->ontrack=1;
      }

      // --- envoi les parametres a CSI du premier GOTO
      strcpy(ss,"!1; PointSource(%d, %d, %d, %d, %d, %d, %d, %d, %d);");
      sprintf(s,ss,position_dome, tol_dome, position_ha, tol_ha, position_dec, tol_dec, do_tracking, De_ra, dur);
      csi_put(tel,s);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      csi_read(tel,s);
   
   }

   return 0;
}


int csi_hadec_goto(struct telprop *tel)
{
   char s[1024],axe,s1[1024],s2[1024];
   int retournement=0;
   int p;
   double v;
   double ha;
   /* --- Effectue le pointage RA --- */
   ha=tel->ra0+360*5;
   ha=fmod(ha,360.);
	if (ha>180) {
		ha=ha-360;
	}
   p=(int)(tel->roth00+(ha-tel->ha00)*tel->radec_position_conversion);
   axe='1';
   v=fabs(tel->speed_slew_ra*tel->radec_speed_ra_conversion);
	sprintf(s1,"etpos=%d;",p);
   /* --- Effectue le pointage DEC --- */
   if (retournement==1) {
      v=(tel->latitude)/fabs(tel->latitude)*180-tel->dec0;
   } else {
      v=tel->dec0;
   }
   p=(int)(tel->rotd00-(v-tel->dec00)*tel->radec_position_conversion);
   axe='2';
   v=fabs(tel->speed_slew_ra*tel->radec_speed_dec_conversion);
	
   /* --- Slew simultaneously or not --- */
	if (tel->simultaneus==1) {
		sprintf(s2,"etpos@%c=%d;",axe,p);
		sprintf(s,"!1; %s %s wait();",s1,s2);
		csi_put(tel,s);
		csi_read(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
	} else {
		sprintf(s,"!2; %s wait();",s2);
		csi_put(tel,s);
		csi_read(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		sprintf(s,"!1; %s wait();",s1);
		csi_put(tel,s);
		csi_read(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
	}
   return 0;
}

int csi_initzenith(struct telprop *tel)
{
   return 0;
}

int csi_stopgoto(struct telprop *tel)
{
   char s[1024],axe;
   /*--- Arret pointage */
	if (tel->simultaneus==1) {
		axe='1';
		sprintf(s,"!%c; stop(); wait();",axe);
		csi_put(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		csi_read(tel,s);
		axe='2';
		sprintf(s,"!%c; stop(); wait();",axe);
		csi_put(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		csi_read(tel,s);
	} else {
		axe='1';
		sprintf(s,"!%c; stop(); wait();",axe);
		csi_put(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		csi_read(tel,s);
		axe='2';
		sprintf(s,"!%c; stop(); wait();",axe);
		csi_put(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
		csi_read(tel,s);
	}
	tel->radec_motor=0;
   return 0;
}

int csi_stategoto(struct telprop *tel,int *state)
{
   return 0;
}

int csi_suivi_arret (struct telprop *tel)
{
	tel->radec_motor=0;
	tel->ontrack=0;
	csi_stopgoto(tel);
   return 0;
}

int csi_suivi_marche (struct telprop *tel)
{
   /* ==== suivi sideral ou autre ===*/
	int dur,De_ra,De_dec;
   char s[1024],axe,s10[1024],s20[1024],ss[1024];
   csi_compute_tracking(tel,&De_ra,&De_dec,&dur);
   /*--- Track alpha */
	axe='1';
	sprintf(s10,"!%c; followme(%d,%d);",axe,De_ra,dur);
	/*--- Track delta */
	axe='2';
	sprintf(s20,"!%c; followme(%d,%d);",axe,De_dec,dur);
	/*--- Track start */
	tel->radec_motor=1;
	tel->ontrack=1;
	/* Which command to send for tracking?*/
	strcpy(s, s10);
	csi_put(tel,s);
	sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
	csi_read(tel,s);
	if (De_dec != 0) {
		strcpy(s, s20);
		csi_put(tel,s);
		sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
		csi_read(tel,s);
	}
	sprintf(ss,"after %d",1000); mytel_tcleval(tel,ss);
    return 0;
}

int csi_compute_tracking(struct telprop *tel,int *De_ra, int *De_dec,int *dur) {
   /* ==== suivi sideral ou autre ===*/
	int duration; // sec
   char s[1024],ss[1024];
   double speed_track_ra,speed_track_dec,dradif,ddecdif;
	/*--- differential refraction */
	speed_track_ra=tel->speed_track_ra;
	speed_track_dec=tel->speed_track_dec;
	if (tel->refrac_delay>0) {
	   libtel_GetCurrentUTCDate(tel->interp,ss);
		sprintf(s,"mc_refraction_difradec %f %f {%s} %s %f 288 80000",tel->ra0,tel->dec0,tel->home,ss,tel->refrac_delay); 
		if (mytel_tcleval(tel,s)==TCL_OK) {
			strcpy(ss,Tcl_GetStringResult(tel->interp));
			sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
			dradif=atof(Tcl_GetStringResult(tel->interp))/tel->refrac_delay;
			sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
			ddecdif=atof(Tcl_GetStringResult(tel->interp))/tel->refrac_delay;
			speed_track_ra-=(dradif/tel->refrac_div);
			speed_track_dec+=(ddecdif/tel->refrac_div);
		}
	}
	duration=(int)tel->trackingduration; // sec
	*dur=duration*1000; // msec
   /*--- Track alpha */
	*De_ra = (int)(duration*speed_track_ra*tel->radec_position_conversion);
	/*--- Track delta */
	*De_dec = (int)(duration*speed_track_dec*tel->radec_position_conversion);
   return 0;
}

int csi_position_tube(struct telprop *tel,char *sens)
{
   return 0;
}

int csi_setderive(struct telprop *tel,int var, int vdec)
{
   return 0;
}

int csi_getderive(struct telprop *tel,int *var,int *vdec)
{
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage csi TOOLS ----------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int csi_home(struct telprop *tel, char *home_default)
{
   char s[1024];
   if (strcmp(tel->home0,"")!=0) {
      strcpy(tel->home,tel->home0);
      return 0;
   }
   sprintf(s,"info exists audace(posobs,observateur,gps)");
   mytel_tcleval(tel,s);
   if (strcmp(Tcl_GetStringResult(tel->interp),"1")==0) {
      sprintf(s,"set audace(posobs,observateur,gps)");
      mytel_tcleval(tel,s);
      strcpy(tel->home,Tcl_GetStringResult(tel->interp));
	} else {
      if (strcmp(home_default,"")!=0) {
         strcpy(tel->home,home_default);
      }
   }
   return 0;
}

double csi_tsl(struct telprop *tel,int *h, int *m,double *sec,double dt)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- local sideral time computation */
	// dt=tel->dead_delay_slew/86400;
   csi_home(tel,"");
   // Get the UTC from the command line.
   libtel_GetCurrentUTCDate(tel->interp,ss);
   // Use the command line to obtain the local sideral time
   sprintf(s,"mc_date2lst [expr [mc_date2jd %s]+%f] {%s}",ss,dt,tel->home);
   mytel_tcleval(tel,s);
   strcpy(ss,Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 0",ss);
   mytel_tcleval(tel,s);
   *h=(int)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 1",ss);
   mytel_tcleval(tel,s);
   *m=(int)atoi(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex {%s} 2",ss);
   mytel_tcleval(tel,s);
   *sec=(double)atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"expr ([lindex {%s} 0]+[lindex {%s} 1]/60.+[lindex {%s} 2]/3600.)*15",ss,ss,ss);
   mytel_tcleval(tel,s);
   tsl=atof(Tcl_GetStringResult(tel->interp)); /* en degres */
   return tsl;
}

int csi_dome_rotate (struct telprop *tel) {
	char s[1024],ss[1024];
	char axe = '0';
	long position, tol;
	if (tel->enable_dome == 0) return 0;
   position = csi_dome_compute_azimuth(tel,TYPE_ALTAZ);
	tol = (long) floor(encoder/360.0);
	//domeseek(position, tol); // tol & pos are in encoder steps
   strcpy(ss,"!%c; SeekRodger(%d, %d);");
	sprintf(s,ss,axe, position, tol); // function return something
    csi_put(tel,s);
	sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
    csi_read(tel,s);
    return 0;
}


long csi_dome_compute_azimuth (struct telprop *tel,int type_coord) {
	double lst, ha, sec, azimut, altitude;
	int h, m;
   long position;
   if (type_coord!=TYPE_ALTAZ) {
      if (type_coord==TYPE_RADEC) {
         lst=csi_tsl(tel,&h,&m,&sec,0);
         ha=lst-tel->ra0+360*5+2/1440*360;
      } else {
         ha=tel->ra0;
      }
      ha=fmod(ha,360.);
      if (ha>180) {
         ha=ha-360;
      };
      // conversion of the local az to dome
      csi_hd2ah(ha,tel->dec0,18.33,&azimut,&altitude);
   } else {
      azimut=fmod(tel->ra0,360);
   }
   if (azimut>180) {
      azimut=azimut-360.;
   }
	// conversion from HA to dome encoder steps
	// dome is HA = 355 at home
	position = (long) floor(encoder/360.0*(180+azimut+5));
   //printf("ha=%f az=%f pos=%ld\n",ha,azimut,position);
   return position;
}

int csi_dome_get_azimuth (struct telprop *tel, double *az, int *adu) {
   char axe,s[256],ss[256];
   int res;
   double azimuth=-360;
   int position=0;
   axe='0';
   sprintf(ss,"!%c; =mpos;",axe);
   csi_put(tel,ss);
   sprintf(ss,"after %d",tel->tempo); mytel_tcleval(tel,ss);
   res=csi_read(tel,s);
   if (res==0) {
      sscanf(s,"%d",&position);
      // conversion from az from dome encoder steps
      // dome is az = 355 at home
      azimuth = 360.*position/encoder-180-5;
      azimuth=fmod(azimuth+720*2,360);
      if (azimuth>180) {
         azimuth=azimuth-360.;
      }
   }
   *az=azimuth;
   *adu=position;
   return res;
}

int csi_dome_close(struct telprop *tel) {
   char s[1024];
   char axe='0';
   if (tel->enable_dome == 0) return 0;
   sprintf(s,"!%c; SeekLight(-1);",axe); // return mpos for sending out something
   csi_put(tel,s);
   csi_read(tel,s);
   return 0;
}

int csi_dome_open(struct telprop *tel) {
   char s[1024];
   char axe='0';
   if (tel->enable_dome ==0) return 0;
   sprintf(s,"!%c; SeekLight(1);",axe); // return mpos for sending out something
   csi_put(tel,s);
   csi_read(tel,s);
   return 0;
}

int csi_dome_invert(struct telprop *tel) {
    char s[1024],ss[1024];	
    char axe='0';
    long position;;
    if (tel->enable_dome == 0) return 0;
    position = csi_dome_locate(tel);
    position = position + encoder / 2; // A VERIFIER : DIVISION ENTIERE !!
    if (position > encoder) position = position - encoder;
    strcpy(ss,"!%c; mtpos= %l; while(working) {}; =mpos;");
    sprintf(s,ss,axe, position);
    csi_put(tel,s);
	 csi_read(tel,s);
    return 0;
}

long csi_dome_locate(struct telprop *tel) {
    char s[1024];
	char axe='0';
    sprintf(s,"!%c; =mpos;",axe);
    csi_put(tel,s);
    csi_read(tel,s);
	return atoi(s);
}

int csi_dome_enable(struct telprop *tel) {
	tel->enable_dome = 1;
	return 0;
}

int csi_dome_disable(struct telprop *tel) {
	tel->enable_dome = 0;
	return 0;
}

// Angle functions. Copied from libangle, not found by linker !

void csi_hd2ah(double ha, double dec, double latitude, double *az, double *h)
/***************************************************************************/
/* Change the coordinate system fro HA/DEC to ALTZ/H                       */
/***************************************************************************/
/* all angles are entered in degres                                        */
/***************************************************************************/
{
   double aa,hh;
   double factor = 180.0/PI;
   ha = ha/factor;
   dec = dec/factor;
   latitude = latitude/factor;
   if (dec>=PISUR2) { aa=(PI); hh=latitude;}
   else if (dec<=-PISUR2) { aa=0.; hh=-latitude;}
   else {
      aa=atan2(sin(ha),cos(ha)*sin(latitude)-tan(dec)*cos(latitude));
      hh=csi_asin(sin(latitude)*sin(dec)+cos(latitude)*cos(dec)*cos(ha));
   }
   *az=fmod(4*PI+aa,2*PI)*factor;
   *h=hh*factor;
}


double csi_asin(double x)
/***************************************************************************/
/* Fonction arcsinus evitant les problemes de depassement                  */
/***************************************************************************/
{
   if (x>1.) {x=1.;}
   if (x<-1.) {x=-1;}
   return(asin(x));
}

int csi_decode_date(Tcl_Interp *interp, double *jj)
/****************************************************************************/
/* Simplication of mctcl_decode_date                                	    */
/****************************************************************************/
/* Date will be now !      										          */
/****************************************************************************/
{
   //int result=TCL_ERROR;//,code,retour;
   double y=0.,m=0.,d=0.,jour=0.;
   double hh=0.,mm=0.,ss=0.;
   time_t ltime;
   char text[100];
   int millisec=0;
#if defined(_MSC_VER)
   /* cas special a Microsoft C++ pour avoir les millisecondes */
   struct _timeb timebuffer;
#endif

   *jj=0.;
   millisec=0;
#if defined(_MSC_VER)
   /* cas special a Microsoft C++ pour avoir les millisecondes */
   _ftime( &timebuffer );
   millisec=(int)(timebuffer.millitm);
#endif
    time( &ltime );
    strftime(text,50,"%Y %m %d %H %M %S",localtime( &ltime ));
    strftime(text,50,"%Y",localtime( &ltime )); y=atof(text);
    strftime(text,50,"%m",localtime( &ltime )); m=atof(text);
    strftime(text,50,"%d",localtime( &ltime )); d=atof(text);
    strftime(text,50,"%H",localtime( &ltime )); hh=atof(text);
    strftime(text,50,"%M",localtime( &ltime )); mm=atof(text);
    strftime(text,50,"%S",localtime( &ltime )); ss=atof(text)+((double)millisec)/1000.;
	jour=1.*d+(((ss/60+mm)/60)+hh)/24;
	/*--- Calcul du Jour Julien */
	csi_date_jd((int)y,(int)m,jour,jj);
	return TCL_OK;
}

void csi_date_jd(int annee, int mois, double jour, double *jj)
/***************************************************************************/
/* Donne le jour juliene correspondant a la date                           */
/***************************************************************************/
/* annee : valeur de l'annee correspondante                                */
/* mois  : valeur du mois correspondant                                    */
/* jour  : valeur du jour decimal correspondant                            */
/* *jj   : valeur du jour julien converti                                  */
/***************************************************************************/
{
   double a,m,j,aa,bb,jd;
   a=annee;
   m=mois;
   j=jour;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+bb-1524.5;
	jd=jd+j;
   if (jd<2299160.5) {
      /* --- julian date ---*/
      jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))-1524.5;
		jd=jd+j;
   }
   *jj=jd;
}



/*
Focus area. The following functions control the focus of the telescope. They are called by the various tel1 focus ... commands
*/

int csi_focus_move(struct telprop *tel, char *direction) {
// Move the focus by a certain amount in a given direction

	char ligne[1024];
	int current_pos = 0;
	int new_pos = 0;
	int delta = 0;
	// Obtain the current position
	csi_focus_coord(tel,ligne);
	// Compute the new position
	current_pos = atoi(ligne);
	delta = (int) tel->focus_move_rate;
	if (strcmp(direction, "-") == 0) new_pos = current_pos - delta; else new_pos = current_pos + delta;
	tel->focus0 = new_pos;
	// Move to that position.
	return csi_focus_goto(tel);
}

int csi_focus_goto(struct telprop *tel) {
// Move the focus to a given position
	int res=3;
	int pos=0;
	char ligne[1024];
	char ligne2[1024];
	int result;
	// Obtain the position
	pos = (int)tel->focus0;
	// Go !
	sprintf(ligne,"!%d; mtpos=%d; =mpos;",res,pos);
	if (strcmp(ligne,"")!=0) {
		res=csi_put(tel,ligne);
		if (res==1) {
			result = TCL_ERROR;
			return result;
		} 
		strcpy(ligne,"");
		while (!strcmp(ligne,"")) {
			sprintf(ligne2,"after %d",tel->tempo); mytel_tcleval(tel,ligne2);
			res=csi_read(tel,ligne);
		}
		if (res==1) {
			result = TCL_ERROR;
			return result;
		}
    }
	return pos;
}

int csi_focus_coord(struct telprop *tel, char *result) {
// obtain the current position on the focus axis
	int res=3;
	char ligne[1024];
	char ligne2[1024];
	int resultat = 0;
	sprintf(ligne,"!%d; =mpos;",res);
	if (strcmp(ligne,"")!=0) {
		res=csi_put(tel,ligne);
		if (res==1) {
			resultat = TCL_ERROR;
			return resultat;
		} 
		strcpy(ligne,"");
		while (!strcmp(ligne,"")) {
			sprintf(ligne2,"after %d",tel->tempo); mytel_tcleval(tel,ligne2);
			res=csi_read(tel,ligne);
		}
		if (res==1) {
			resultat = TCL_ERROR;
			return resultat;
		}
    }
    strcpy(result,ligne);
	return atoi(result);
}

int csi_focus_init(struct telprop *tel) {
// init the focus axis
	int res=3;
	char ligne[1024];
	char ligne2[1024];
	int result = 0;
	sprintf(ligne,"!%d; focreset();",res);
	if (strcmp(ligne,"")!=0) {
		res=csi_put(tel,ligne);
		if (res==1) {
			result = TCL_ERROR;
			return result;
		} 
		strcpy(ligne,"");
		while (!strcmp(ligne,"")) {
			sprintf(ligne2,"after %d",tel->tempo); mytel_tcleval(tel,ligne2);
			res=csi_read(tel,ligne);
		}
		if (res==1) {
			result = TCL_ERROR;
			return result;
		}
    }
    return result;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- Unused functions but let them here ----------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/**/
static void libtel_startRadecSurvey (struct telprop* tel) {
   libtel_stopRadecSurvey(tel);
   return;
}

static void libtel_stopRadecSurvey (struct telprop* tel) {
   libtel_startRadecSurvey(tel);
   return;
}
/**/

