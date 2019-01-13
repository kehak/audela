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

 /*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct telini tel_ini[] = {
   {"AUTOSTAR",    /* telescope name */
    "Autostar",    /* protocol name */
    "autostar",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

//#define autostar_MOUCHARD

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
   char ipstring[50],portstring[50],s[1024],comstring[1024];
	char response[1024];
   int k, kk, kdeb, nbp, klen,res;
   char ssres[1024];
   char ss[256],ssusb[256];

#if defined autostar_MOUCHARD
   FILE *f;
#endif

	/* -ip 192.168.0.44 -port 11110 */
   tel->tempo=50;
#if defined autostar_MOUCHARD
   f=fopen("mouchard_autostar.txt","wt");
   fclose(f);
#endif
	/* --- decode type (RS232 by default) ---*/
	tel->type=1;
	strcpy(tel->portcom,argv[2]);
	kk=2;
   if ((strcmp(argv[kk],"tcp")==0)||(strcmp(argv[kk],"TCP")==0)) {
		tel->type=0;
	}
	/* --- decode IP  --- */
	ip[0] = 127;
	ip[1] = 0;
	ip[2] = 0;
	ip[3] = 1;
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
#if defined autostar_MOUCHARD
	f=fopen("mouchard_autostar.txt","at");
	fprintf(f,"IP=%s\n",tel->ip);
	fclose(f);
#endif
	/* --- decode port  --- */
	tel->port = 5000;
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
#if defined autostar_MOUCHARD
	f=fopen("mouchard_autostar.txt","at");
	fprintf(f,"PORT=%d\n",tel->port);
	fclose(f);
#endif
	/* ================== */
	/* === connection === */
	/* ================== */
	/* --- open ---*/
	strcpy(comstring,"");
	strcpy(tel->channel,"");
	if (tel->type==0) {
		res=autostar_connection(tel);
		if (res!=0) {
			return res;
		}
	} else {
		/* --- transcode a port argument into comX or into /dev... */
		strcpy(ss,argv[2]);
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
				return 1;
			 }
			strcpy(comstring,ssusb);
		  } else {
			 strcpy(tel->msg,ssres);
			 return 1;
		  }
		}
		strcpy(comstring,ss);
		strcpy(tel->channel,Tcl_GetStringResult(tel->interp));
	   sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); mytel_tcleval(tel,s);
	   mytel_flush(tel);
	}
	/* ============== */
	/* === inits  === */
	/* ============== */
	/* --- wait --- */
	sprintf(s,"after 350"); mytel_tcleval(tel,s);
	/* --- wait for G# --- */
	tel->alignment='?';
	for (k=1;k<20;k++) {
		res = autostar_putread(tel,"ACK",response);
		if (res!=0) {
			return res;
		}
		if ( (strcmp(response,"A")==0) || (strcmp(response,"P")==0) || (strcmp(response,"L")==0) ) {
			tel->alignment=response[0];
			break;
		}
	}
	if (tel->alignment=='?') {
		return -1;
	}
	// --- Set date at now UTC
	tel_date_set(tel,-1,0,0,0,0,0); 
	// --- Check if it is an autostar
	res = autostar_putread(tel,":GVP#",response);
	if (res!=0) {
		return res;
	}
	if (strcmp(response,"Autostar#")!=0) {
		return -1;
	}
	/* --- wait --- */
	sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
	/* --- Stop motors --- */
	autostar_suivi_arret (tel);
	/* --- Precision --- */
	res = autostar_putread(tel,":P#",response);
	if (res!=0) {
		return res;
	}
	if (strcmp(response,"LOW  PRECISION")==0) {
		// Toggle to high precision
		res = autostar_putread(tel,":U#",response);
		if (res!=0) {
			return res;
		}
	}
	/* --- drifts --- */
	tel->track_diurnal=360./86164.; /* (deg/s) */
	tel->speed_track_ra=tel->track_diurnal; /* (deg/s) */
	tel->speed_track_dec=0.; /* (deg/s) */
	/* --- Home --- */
	tel->latitude=43.2;
	sprintf(tel->home0,"GPS 6.23 E %+.6f 650",tel->latitude);
	//autostar_set_sideral_time(tel);
	/* --- Tracking status --- */
	res = autostar_putread(tel,":Gv#",response);
	if (res!=0) {
		return res;
	}
	if (strcmp(response,"")==0) {
		tel->blockingmethod=1; /* =0 for status, =1 for a coord loop */
	} else {
		tel->blockingmethod=0; /* =0 for status, =1 for a coord loop */
	}

   /* --- sortie --- */
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
   autostar_delete(tel);
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

int mytel_flush(struct telprop *tel)
/* flush the input channel until nothing is received */
{
   char s[1024];
   int k=0;
   while (1==1) {
      //sprintf(s,"read -nonewline %s 1",tel->channel); mytel_tcleval(tel,s);
      sprintf(s,"read -nonewline %s",tel->channel); mytel_tcleval(tel,s);
      strcpy(s,Tcl_GetStringResult(tel->interp));
      if (strcmp(s,"")==0) {
         return k;
      }
      k++;
   }
}

int mytel_radec_init(struct telprop *tel)
/* it corresponds to the "match" function of an LX200 */
{
   autostar_radec_match(tel);
   return 0;
}

int mytel_hadec_init(struct telprop *tel)
/* it corresponds to the "match" function of an LX200 */
{
   autostar_hadec_match(tel);
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int state;
   autostar_stategoto(tel,&state);
   if (state==1) {strcpy(result,"tracking");}
   else if (state==2) {strcpy(result,"pointing");}
   else {strcpy(result,"unknown");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
	double sepangledeg,sepangledeglim;
   autostar_arret_pointage(tel);
   /* --- function TRACK --- */
   autostar_goto(tel);
   sate_move_radec='A';
	sepangledeglim=5./3600;
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
		if (tel->blockingmethod==0) {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				autostar_putread(tel,":Gv#",s);
				if (s[0]=='T') { break; }
				if (time_in>=time_out) {break;}
			}
		} else {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				autostar_movingdetect(tel,1,&sepangledeg);
				if (sepangledeg<sepangledeglim) { break; }
				if (time_in>=time_out) {break;}
			}
		   autostar_arret_pointage(tel);
		}
      sate_move_radec=' ';
      autostar_suivi_marche(tel);
   }
	sprintf(s,"after 500"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
   char s[1024];
   int time_in=0,time_out=70;
	double sepangledeg,sepangledeglim;

   autostar_arret_pointage(tel);
   autostar_hadec_goto(tel);
   sate_move_radec='A';
	sepangledeglim=5./3600;
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
		if (tel->blockingmethod==0) {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				autostar_putread(tel,":Gv#",s);
				if (s[0]=='N') { break; }
				if (time_in>=time_out) {break;}
			}
		} else {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				autostar_movingdetect(tel,0,&sepangledeg);
				if (sepangledeg<sepangledeglim) { break; }
				if (time_in>=time_out) {break;}
			}
		}
      sate_move_radec=' ';
	  autostar_suivi_marche(tel);
   }
	sprintf(s,"after 500"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   int res;   
   if (tel->radec_move_rate>1.0) {
      tel->radec_move_rate=1;
   } else if (tel->radec_move_rate<0.) {
      tel->radec_move_rate=0.;
   }
   if (tel->radec_move_rate<=0.25) {
		res = autostar_putread(tel,":RG#",s);
	} else if (tel->radec_move_rate<=0.5) {
		res = autostar_putread(tel,":RC#",s);
	} else if (tel->radec_move_rate<=0.75) {
		res = autostar_putread(tel,":RM#",s);
	} else {
		res = autostar_putread(tel,":RS#",s);
	}
	sprintf(s,"string index [string toupper %s] 0",direction); mytel_tcleval(tel,s);
   strcpy(direc,Tcl_GetStringResult(tel->interp));
   if (strcmp(direc,"N")==0) {
		res = autostar_putread(tel,":Mn#",s);
   } else if (strcmp(direc,"S")==0) {
		res = autostar_putread(tel,":Ms#",s);
   } else if (strcmp(direc,"E")==0) {
		res = autostar_putread(tel,":Me#",s);
   } else if (strcmp(direc,"W")==0) {
		res = autostar_putread(tel,":Mw#",s);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   if (sate_move_radec=='A') {
      /* on arrete un GOTO */
      autostar_stopgoto(tel);
      sate_move_radec=' ';
   } else {
      /* on arrete un MOVE */
      autostar_stopgoto(tel);
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
      autostar_suivi_arret(tel);
   } else {
      /* start the motor */
      autostar_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   autostar_coord(tel,result);
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
   char s[1024], date[30], shift[20];
   int res;
	double jd_clt, jd_utc, djd;
	// :GC# <mm>/<dd>/<yy># Local Calendar Date, month mm, days dd and years yy separated by slashes.
	// :GL# <hh>:<mm>:<ss># Civil Time (UTC time from the internal Real Time Clock + UTC offset), hours, minutes, seconds in 24-hour format.
	// :GG# {+-}<hh># Get the number of hours by which your local time differs from UTC (from L1, V2.0 up). If your local time is earlier than UTC this command will return a positive value, if later than UTC the value is negative.
	//
   /* LAT = {+-}<dd>°<mm># */
	res = autostar_putread(tel,":GC#:GL#",s);
	sprintf(date,"20%c%c-%c%c-%c%cT%c%c:%c%c:%c%c",s[6],s[7],s[0],s[1],s[3],s[4],s[9],s[10],s[12],s[13],s[15],s[16]);
	res = autostar_putread(tel,":GG#",s);
	sprintf(shift,"%c%c%c",s[0],s[1],s[2]);
	djd = atof(shift)/24.;
   sprintf(s,"mc_date2jd %s",date); mytel_tcleval(tel,s);
   strcpy(shift,Tcl_GetStringResult(tel->interp));
	jd_clt = atof(shift);
	jd_utc = jd_clt + djd;
   sprintf(s,"mc_date2iso8601 %f",jd_utc); mytel_tcleval(tel,s);
   strcpy(date,Tcl_GetStringResult(tel->interp));
	strcpy(ligne,date);
   return 0;
}

int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s)
{
	// :SC<mm>/<dd>/<yy># 0 if invalid or 1 Updating planetary data#<24 blanks># Set Calendar Date: months mm, days dd, year yy of the civil time according to the timezone set. The internal calendar/clock uses GMT.
	// :SL<hh>:<mm>:<ss># 1 Set RTC Time from the civil time hours hh, minutes mm and seconds ss. The timezone must be set before using this command.
	// :SG{+-}hh# 1 Set the number of hours by which your local time differs from UTC. If your local time is earlier than UTC set a positive value, if later than UTC set a negative value. The time difference has to be set before setting the calendar date (SC) and local time (SL), since the Real Time Clock is running at UTC.
   char ligne[1024], ss[1024], response[1024];
   int res;
	if (y==-1) {
		libtel_GetCurrentUTCDate(tel->interp,ligne);
		sprintf(ss,"mc_date2ymdhms %s",ligne); mytel_tcleval(tel,ss);
		strcpy(ligne,Tcl_GetStringResult(tel->interp));
		sprintf(ss,"lindex {%s} 0",ligne); mytel_tcleval(tel,ss);
		strcpy(ss,Tcl_GetStringResult(tel->interp));
		y = atoi(ss);
		sprintf(ss,"lindex {%s} 1",ligne); mytel_tcleval(tel,ss);
		strcpy(ss,Tcl_GetStringResult(tel->interp));
		m = atoi(ss);
		sprintf(ss,"lindex {%s} 2",ligne); mytel_tcleval(tel,ss);
		strcpy(ss,Tcl_GetStringResult(tel->interp));
		d = atoi(ss);
		sprintf(ss,"lindex {%s} 3",ligne); mytel_tcleval(tel,ss);
		strcpy(ss,Tcl_GetStringResult(tel->interp));
		h = atoi(ss);
		sprintf(ss,"lindex {%s} 4",ligne); mytel_tcleval(tel,ss);
		strcpy(ss,Tcl_GetStringResult(tel->interp));
		min = atoi(ss);
		sprintf(ss,"lindex {%s} 5",ligne); mytel_tcleval(tel,ss);
		strcpy(ss,Tcl_GetStringResult(tel->interp));
		s = atof(ss);
	}
	sprintf(ligne,":SG+00#:SC%02d/%02d/%02d#:SL%02d:%02d:%02.0f#",m,d,y-2000,h,min,s);
	res = autostar_putread(tel,ligne,response);
	if (res!=0) {
		return res;
	}
   return 0;
}

int mytel_home_get(struct telprop *tel,char *ligne)
{
   char s[1024];
   int res;
   char longs[20],sense;
   char lats[20]; 
	double longideg,latideg;
	//
   /* LAT = {+-}<dd>°<mm># */
	res = autostar_putread(tel,":Gt#",s);
	sprintf(lats,"%c%c%cd%c%cm",s[0],s[1],s[2],s[5],s[6]);
   sprintf(s,"mc_angle2dms %s 90 zero 1 + string",lats); mytel_tcleval(tel,s);
   strcpy(lats,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2deg %s",lats); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
	latideg = atof(s);
	//
   /* LONG = +-}<ddd>°<mm># */
	res = autostar_putread(tel,":Gg#",s);
	sprintf(longs,"%c%c%c%cd%c%cm",s[0],s[1],s[2],s[3],s[6],s[7]);
   sprintf(s,"mc_angle2dms %s 360 zero 2 auto string",longs); mytel_tcleval(tel,s);
   strcpy(longs,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2deg %s",longs); mytel_tcleval(tel,s);
   strcpy(s,Tcl_GetStringResult(tel->interp));
	longideg = atof(s);
	if (longideg>180) {
		sense = 'E';
		longideg = 360-longideg ;
	} else {
		sense = 'W';
	}
	//
	sprintf(tel->home0,"GPS %.7f %c %+.7f 0",longideg,sense,latideg);
   strcpy(ligne,tel->home0);
   return 0;
}

int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude)
{
   char ligne[1024],ligne2[1024],response[1024];
	int res;
   // Set the longitude
   if ((strcmp(ew,"E")==0)||(strcmp(ew,"e")==0)) {
      longitude=360.-longitude;
   }
   sprintf(ligne,"mc_angle2dms %f 360 zero 0 + list",longitude); mytel_tcleval(tel,ligne);
   strcpy(ligne2,Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"string range \"[string range [lindex {%s} 0] 1 3]\xDF[string range [lindex {%s} 1] 0 1]\" 0 6",ligne2,ligne2); mytel_tcleval(tel,ligne);
   strcpy(ligne2,Tcl_GetStringResult(tel->interp));
   sprintf(ligne,":Sg%s#",ligne2);
	res = autostar_putread(tel,ligne,response);
	if (res!=0) {
		return res;
	}
   /* Set the latitude */
   sprintf(ligne,"mc_angle2dms %f 90 zero 0 + list",latitude); mytel_tcleval(tel,ligne);
   strcpy(ligne2,Tcl_GetStringResult(tel->interp));
   sprintf(ligne,"string range \"[string range [lindex {%s} 0] 0 0][string range [lindex {%s} 0] 1 2]\xDF[string range [lindex {%s} 1] 0 1]\" 0 6",ligne2,ligne2,ligne2); mytel_tcleval(tel,ligne);
   strcpy(ligne2,Tcl_GetStringResult(tel->interp));
   sprintf(ligne,":St%s#",ligne2);
	res = autostar_putread(tel,ligne,response);
	if (res!=0) {
		return res;
	}
	// -- update the sideral time of the Autostar
	//autostar_set_sideral_time(tel);
   return 0;
}

int mytel_hadec_coord(struct telprop *tel,char *result)
{
   autostar_hadec_coord(tel,result);
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
#if defined autostar_MOUCHARD
   FILE *f;
   f=fopen("mouchard_autostar.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   fclose(f);
#endif
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {
#if defined autostar_MOUCHARD
      f=fopen("mouchard_autostar.txt","at");
      fprintf(f,"RESU-PB <%s>\n",Tcl_GetStringResult(tel->interp));
      fclose(f);
#endif
      return TCL_ERROR;
   }
#if defined autostar_MOUCHARD
   f=fopen("mouchard_autostar.txt","at");
   fprintf(f,"RESU-OK <%s>\n",Tcl_GetStringResult(tel->interp));
   fclose(f);
#endif
   return TCL_OK;
}

int autostar_delete(struct telprop *tel)
{
	char s[1024];
	sprintf(s,"close \"%s\"",tel->channel);
	Tcl_Eval(tel->interp,s);
   return 0;
}

int autostar_put(struct telprop *tel,char *cmd)
{
   char s[1024],ss[1024];
	int n;
	strcpy(ss,cmd);
	n=strlen(ss);
	if (strcmp(cmd,"ACK")==0) {
		sprintf(ss,"%c",6);
	}
	sprintf(s,"puts -nonewline %s \"%s\"",tel->channel,ss);
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
   return 0;
}

int autostar_read(struct telprop *tel, char *response)
{
   char s[1024],ss[1024];
	int sortie=0,ks=0;
	// j'attend une chaine qui se termine par diese
	int k = 0, kwait=0, n=0;
	int cr = 0;
	strcpy(response,"");
	do {
		sprintf(s,"read %s",tel->channel); 
		if ( mytel_tcleval(tel,s) == TCL_OK ) {
			strcpy(ss,Tcl_GetStringResult(tel->interp));
			n = strlen(ss);
			if (strcmp(ss,"") == 0 ) {
				// si pas de chaine recue , j'attends 50 milliseconde
				// (insdispensable pour les ordinateurs rapides)
				libtel_sleep(50) ;
				kwait+=50;
			} else if ( n>0 ) {
				// si ce n'est pas un diese j'ajoute la chaine lue dans le resultat
				strcat(response,ss);
				// je remet la temporisation a zero
				if (ss[n-1]=='#') {
					// c'est un diese
					cr ++;
				} else {
					k = 0;
				}
			}
		} else {
			// erreur, je copie le message d'erreur dans la variable tel->msg
			strcpy(tel->msg, Tcl_GetStringResult(tel->interp));
			strcpy(response,"Error");
		}
		k++;
	} while ( k<13 );
   return 0;
}

int autostar_putread(struct telprop *tel,char *command,char *response)
{
	int res;
	res=autostar_put(tel,command);
	if (res==0) {
		res=autostar_read(tel,response);
		if (res!=0) {
			return res;
		}
	}
	return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage autostar   --------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int autostar_connection(struct telprop *tel)
/*
*
*/
{
   return 0;
}

int autostar_stat(struct telprop *tel,char *result,char *bits)
/*
*
*/
{
   return 0;
}

int autostar_arret_pointage(struct telprop *tel)
{
   char s[1024];
   int res;
   /*--- Arret mouvement des moteurs */
   sprintf(s,"#13;");
   res=autostar_put(tel,s);
   return 0;
}

int autostar_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024];
   int res,len;
   char ras[20];
   char decs[20];   
   /* --- function COORDS --- */
	//
   /* DEC = +12:34:45# ou +12:34# */
	res = autostar_putread(tel,":GD#",s);
   len=(int)strlen(s);
   if (len>=10) {
		sprintf(decs,"%c%c%cd%c%cm%c%cs",s[0],s[1],s[2],s[5],s[6],s[8],s[9]);
	} else {
		sprintf(decs,"%c%c%cd%c%cm",s[0],s[1],s[2],s[5],s[6]);
	}
   sprintf(s,"mc_angle2dms %s 90 zero 0 + string",decs); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
	//
	/* RA = 12:34:45# ou 12:34.7# */
	res = autostar_putread(tel,":GR#",s);
   len=(int)strlen(s);
   if (len>=9) {
		sprintf(ras,"%c%ch%c%cm%c%cs",s[0],s[1],s[3],s[4],s[6],s[7]);
	} else {
		sprintf(ras,"%c%ch%c%c.%cm",s[0],s[1],s[3],s[4],s[6]);
	}
   sprintf(s,"mc_angle2hms %s 360 zero 0 auto string",ras); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
	//
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int autostar_hadec_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024];
   int res,len;
   char ras[20];
   char decs[20];   
   char lsts[20];
   char has[20];
	double ra,lst,ha;
   /* --- function COORDS --- */
	//
   /* DEC = +12:34:45# ou +12:34# */
	res = autostar_putread(tel,":GD#",s);
   len=(int)strlen(s);
   if (len>=10) {
		sprintf(decs,"%c%c%cd%c%cm%c%cs",s[0],s[1],s[2],s[5],s[6],s[8],s[9]);
	} else {
		sprintf(decs,"%c%c%cd%c%cm",s[0],s[1],s[2],s[5],s[6]);
	}
   sprintf(s,"mc_angle2dms %s 90 zero 0 + string",decs); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
	// Get RA and sideral time
	/* RA = 12:34:45# ou 12:34.7# */
	res = autostar_putread(tel,":GR#",s);
   len=(int)strlen(s);
   if (len>=9) {
		sprintf(ras,"%c%ch%c%cm%c%cs",s[0],s[1],s[3],s[4],s[6],s[7]);
	} else {
		sprintf(ras,"%c%ch%c%c.%cm",s[0],s[1],s[3],s[4],s[6]);
	}
	res = autostar_putread(tel,":GS#",s);
	sprintf(lsts,"%c%ch%c%cm%c%cs",s[0],s[1],s[3],s[4],s[6],s[7]);
   sprintf(s,"mc_angle2deg %s",ras); mytel_tcleval(tel,s);
   ra = atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2deg %s",lsts); mytel_tcleval(tel,s);
   lst = atof(Tcl_GetStringResult(tel->interp));
	ha = lst-ra;
   sprintf(s,"mc_angle2hms %f 360 zero 0 auto string",ha+720); mytel_tcleval(tel,s);
   strcpy(has,Tcl_GetStringResult(tel->interp));
   sprintf(result,"%s %s",has,decs);
   return 0;
}

int autostar_movingdetect(struct telprop *tel,int hara, double *sepangledeg)
/*
* hara=1 for RADEC goto. hara=0 for HADEC goto. 
*/
{
   char s[1024],ss[1024];
	char ra1[30],dec1[30],ra2[30],dec2[30];
	if (hara==0) {
		autostar_hadec_coord(tel,ss);
		sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
	   strcpy(ra1,Tcl_GetStringResult(tel->interp));
		sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
	   strcpy(dec1,Tcl_GetStringResult(tel->interp));
		sprintf(s,"after 500"); mytel_tcleval(tel,s);
		autostar_hadec_coord(tel,ss);
		sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
	   strcpy(ra2,Tcl_GetStringResult(tel->interp));
		sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
	   strcpy(dec2,Tcl_GetStringResult(tel->interp));
	} else {
		autostar_coord(tel,ss);
		sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
	   strcpy(ra1,Tcl_GetStringResult(tel->interp));
		sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
	   strcpy(dec1,Tcl_GetStringResult(tel->interp));
		sprintf(s,"after 500"); mytel_tcleval(tel,s);
		autostar_coord(tel,ss);
		sprintf(s,"lindex {%s} 0",ss); mytel_tcleval(tel,s);
	   strcpy(ra2,Tcl_GetStringResult(tel->interp));
		sprintf(s,"lindex {%s} 1",ss); mytel_tcleval(tel,s);
	   strcpy(dec2,Tcl_GetStringResult(tel->interp));
	}
   /* --- retourne l'angle de separation --- */
   sprintf(s,"lindex [mc_sepangle %s %s %s %s] 0",ra1,dec1,ra2,dec2); mytel_tcleval(tel,s);
   *sepangledeg=atof(Tcl_GetStringResult(tel->interp));
   return 0;
}

int autostar_radec_match(struct telprop *tel)
{
   char s[1024],response[1024];
   int res;
   char ras[20];
   char decs[20];   
   char secs[20];   
	double sec;
   /* --- function MATCH --- */
	//
   /* DEC = :Sd+12*34# */
   sprintf(s,"mc_angle2dms %.6f 90 zero 0 + string",tel->dec0); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
	decs[3]='*';
	decs[6]='\0';
   /* RA = :Sr02:34.5# */
   sprintf(s,"mc_angle2hms %.6f 360 zero 0 auto string",tel->ra0); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
   sprintf(s,"%c%c.0",ras[6],ras[7]);
	sec = atof(s)/60.;
   sprintf(secs,"%4.2f",sec);
	ras[2]=':';
	ras[5]='.';
	ras[6]=secs[2];
	ras[7]='\0';
	//
	sprintf(s,":Sr%s#",ras);
	res = autostar_putread(tel,s,response);
	sprintf(s,":Sd%s#",decs);
	res = autostar_putread(tel,s,response);
	strcpy(s,":CM#");
	res = autostar_putread(tel,s,response);
   return 0;
}

int autostar_set_sideral_time(struct telprop *tel)
{
   char s[1024],response[1024];
   int res;
	double lst,sec;
	int h,m;
   /* --- Sideral Time --- */
	strcpy(s,":GS#"); // verify
	res = autostar_putread(tel,s,response);
	lst=autostar_tsl(tel,&h,&m,&sec);
	sprintf(s,":SS%02d:%02d:%02.0f#",h,m,sec);
	res = autostar_putread(tel,s,response);
	strcpy(s,":GS#"); // verify
	res = autostar_putread(tel,s,response);
   return 0;
}

int autostar_hadec_match(struct telprop *tel)
{
   char s[1024],response[1024];
   int res;
   char ras[20];
   char decs[20];   
   char secs[20];   
	double lst,sec,ra;
	int h,m;
   /* --- Angle horaire --- */
	lst=autostar_tsl(tel,&h,&m,&sec);
	ra=fmod(lst-tel->ra0+360,360);
   /* --- function MATCH --- */
	//
   /* DEC = :Sd+12*34# */
   sprintf(s,"mc_angle2dms %.6f 90 zero 0 + string",tel->dec0); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
	decs[3]='*';
	decs[6]='\0';
   /* RA = :Sr02:34.5# */
   sprintf(s,"mc_angle2hms %.6f 360 zero 0 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
   sprintf(s,"%c%c.0",ras[6],ras[7]);
	sec = atof(s)/60.;
   sprintf(secs,"%4.2f",sec);
	ras[2]=':';
	ras[5]='.';
	ras[6]=secs[2];
	ras[7]='\0';
	//
	sprintf(s,":Sr%s#",ras);
	res = autostar_putread(tel,s,response);
	sprintf(s,":Sd%s#",decs);
	res = autostar_putread(tel,s,response);
	strcpy(s,":CM#");
	res = autostar_putread(tel,s,response);
   return 0;
}

int autostar_goto(struct telprop *tel)
{
   char s[1024],response[1024];
   int res;
   char ras[20];
   char decs[20];   
   char secs[20];   
	double sec;
   /* --- function GOTO --- */
	//
   /* DEC = :Sd+12*34# */
   sprintf(s,"mc_angle2dms %.6f 90 zero 0 + string",tel->dec0); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
	decs[3]='*';
	decs[6]='\0';
   /* RA = :Sr02:34.5# */
   sprintf(s,"mc_angle2hms %.6f 360 zero 0 auto string",tel->ra0); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
   sprintf(s,"%c%c.0",ras[6],ras[7]);
	sec = atof(s)/60.;
   sprintf(secs,"%4.2f",sec);
	ras[2]=':';
	ras[5]='.';
	ras[6]=secs[2];
	ras[7]='\0';
	//
	sprintf(s,":Sr%s#",ras);
	res = autostar_putread(tel,s,response);
	sprintf(s,":Sd%s#",decs);
	res = autostar_putread(tel,s,response);
	strcpy(s,":MS#");
	res = autostar_putread(tel,s,response);
   return 0;
}

int autostar_hadec_goto(struct telprop *tel)
{
   char s[1024],response[1024];
   int res;
   char ras[20];
   char decs[20];   
   char secs[20];   
	double lst,sec,ra;
	int h,m;
   /* --- Angle horaire --- */
	lst=autostar_tsl(tel,&h,&m,&sec);
	ra=fmod(lst-tel->ra0+360,360);
   /* --- function GOTO --- */
	//
   /* DEC = :Sd+12*34# */
   sprintf(s,"mc_angle2dms %.6f 90 zero 0 + string",tel->dec0); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
	decs[3]='*';
	decs[6]='\0';
   /* RA = :Sr02:34.5# */
   sprintf(s,"mc_angle2hms %.6f 360 zero 0 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
   sprintf(s,"%c%c.0",ras[6],ras[7]);
	sec = atof(s)/60.;
   sprintf(secs,"%4.2f",sec);
	ras[2]=':';
	ras[5]='.';
	ras[6]=secs[2];
	ras[7]='\0';
	//
	sprintf(s,":Sr%s#",ras);
	res = autostar_putread(tel,s,response);
	sprintf(s,":Sd%s#",decs);
	res = autostar_putread(tel,s,response);
	strcpy(s,":MS#");
	res = autostar_putread(tel,s,response);
   return 0;
}

int autostar_initzenith(struct telprop *tel)
{
   return 0;
}

int autostar_initfiducial(struct telprop *tel)
{
   return 0;
}

int autostar_gotoparking(struct telprop *tel)
{
   char s[1024];
   int res;
   /*--- Parking */
	res = autostar_putread(tel,":hP#",s);
   return 0;
}

int autostar_stopgoto(struct telprop *tel)
{
   char s[1024];
   int res;
   /*--- Arret mouvement des moteurs */
	res = autostar_putread(tel,":Q#",s);
   return 0;
}

int autostar_stategoto(struct telprop *tel,int *state)
{
   return 0;
}

int autostar_suivi_arret (struct telprop *tel)
{
	int res;
	char s[1024];
	res = autostar_putread(tel,":hN#",s);
	return 0;
}

int autostar_suivi_marche (struct telprop *tel)
{
	int res;
	char s[1024];
	res = autostar_putread(tel,":hW#",s);
	return 0;
}

int autostar_position_tube(struct telprop *tel,char *sens)
{
	int res;
	char s[1024];
	res = autostar_putread(tel,":Gm#",s);
	if (s[0]=='E') {
		strcpy(sens,"E");
	} else {
		strcpy(sens,"W");
	}
   return res;
}

int autostar_setderive(struct telprop *tel,int var, int vdec)
{
   return 0;
}

int autostar_getderive(struct telprop *tel,int *var,int *vdec)
{
   return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage autostar TOOLS ----------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int autostar_home(struct telprop *tel, char *home_default)
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

double autostar_tsl(struct telprop *tel,int *h, int *m,double *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   autostar_home(tel,"");
   libtel_GetCurrentUTCDate(tel->interp,ss);
   sprintf(s,"mc_date2lst %s {%s}",ss,tel->home);
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

int conv_hexas2ascii(char *buffer_hexas,char *buffer_ascii,int *n_ascii) {
    char conv16[17];
    int nb,kb,res,kc,na;
    char cars[3],s[3];
    strcpy(conv16,"0123456789ABCDEF");
    //
    nb = strlen(buffer_hexas);
    na=0;
    for (kb=0 ; kb<nb ; kb+=2) {
        cars[0] = buffer_hexas[kb];
        cars[1] = buffer_hexas[kb+1];
        cars[2] = '\0';
        res=0;
        for (kc=0 ; kc<16 ; kc++) {
            if (cars[0]==conv16[kc]) {
                res = res + kc*16;
                break;
            }
        }
        for (kc=0 ; kc<16 ; kc++) {
            if (cars[1]==conv16[kc]) {
                res = res + kc;
                break;
            }
        }
        sprintf(s,"%c",res);
        //printf("%s => %d ==> <%c>\n",cars,res,res);
        buffer_ascii[na]=s[0];
        na++;
        buffer_ascii[na]='\0';
    }
    *n_ascii=na;
	 return 0;
}

int conv_ascii2hexas(char *buffer_ascii,int n_ascii,char *buffer_hexas) {
    char conv16[17];
    int kb,res,ka,dec;
    unsigned char s[4];
    strcpy(conv16,"0123456789ABCDEF");
    //
    kb=0;
    for (ka=0 ; ka<n_ascii ; ka++) {
        sprintf(s,"%d",buffer_ascii[ka]);
        dec = atoi(s);
        if (dec<0) {
            dec = 256+dec;
        }
        res = dec/16;
        buffer_hexas[kb] = conv16[res];
        kb++;
        res = dec - res*16;
        buffer_hexas[kb] = conv16[res];
        kb++;
        buffer_hexas[kb] = '\0';
    }
    return 0;
}
