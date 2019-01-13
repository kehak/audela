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
   {"DFM",    /* telescope name */
    "Dfm",    /* protocol name */
    "dfm",    /* product */
     1.         /* default focal lenght of optic system */
   },
   {"",       /* telescope name */
    "",       /* protocol name */
    "",       /* product */
	1.        /* default focal lenght of optic system */
   },
};

//#define DFM_MOUCHARD

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
   int k, kk, kdeb, nbp, klen,res;
   Tcl_DString dsptr;
#if defined DFM_MOUCHARD
   FILE *f;
#endif

	/* -ip 127.0.0.1 -port 1025 -type umac|pmac*/
   tel->tempo=400;
#if defined DFM_MOUCHARD
   f=fopen("mouchard_dfm.txt","wt");
   fclose(f);
#endif
	/* --- decode type (umac by default) ---*/
	kk=2;
   if ((strcmp(argv[kk],"tcp")==0)||(strcmp(argv[kk],"TCP")==0)) {
		tel->type=0;
	} else {
		tel->type=1;
		strcpy(tel->portcom,argv[2]);
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
#if defined DFM_MOUCHARD
	f=fopen("mouchard_dfm.txt","at");
	fprintf(f,"IP=%s\n",tel->ip);
	fclose(f);
#endif
	/* --- decode port  --- */
	tel->port = 5003;
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
#if defined DFM_MOUCHARD
	f=fopen("mouchard_dfm.txt","at");
	fprintf(f,"PORT=%d\n",tel->port);
	fclose(f);
#endif
	/* ================== */
	/* === connection === */
	/* ================== */
	strcpy(tel->channel,"");
	res=dfm_connection(tel);
	if (res!=0) {
		return res;
	}
	/* ============== */
	/* === inits  === */
	/* ============== */
   sprintf(s,"after 350"); mytel_tcleval(tel,s);
   res=dfm_put(tel,"#22,2000.;"); /* J2000.0 display */
   sprintf(s,"after 100"); mytel_tcleval(tel,s);
	tel->track_diurnal=360./86164.; /* (deg/s) */
	tel->speed_track_ra=tel->track_diurnal; /* (deg/s) */
	tel->speed_track_dec=0.; /* (deg/s) */
	tel->blockingmethod=0; /* =0 for status, =1 for a coord loop */
	/* --- Home --- */
	tel->latitude=-31.356667;
	sprintf(tel->home0,"GPS 115.713611 E %+.6f 50",tel->latitude);
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
   dfm_delete(tel);
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
/* it corresponds to the "match" function of an LX200 */
{
   dfm_match(tel);
   return 0;
}

int mytel_radec_state(struct telprop *tel,char *result)
{
   int state;
   dfm_stategoto(tel,&state);
   if (state==1) {strcpy(result,"tracking");}
   else if (state==2) {strcpy(result,"pointing");}
   else {strcpy(result,"unknown");}
   return 0;
}

int mytel_radec_goto(struct telprop *tel)
{
   char s[1024],bits[25];
   int time_in=0,time_out=70,res;
	double sepangledeg,sepangledeglim;
   dfm_arret_pointage(tel);
   /* --- function TRACK --- */
   sprintf(s,"#14,%.6f,0,%.6f,0;",tel->track_diurnal*3600,tel->track_diurnal*3600);
   res=dfm_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   dfm_goto(tel);
   sate_move_radec='A';
	sepangledeglim=5./3600;
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
		if (tel->blockingmethod==0) {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				dfm_stat(tel,s,bits);
				if (bits[0]==0) { break; }
				if (time_in>=time_out) {break;}
			}
		} else {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				dfm_movingdetect(tel,1,&sepangledeg);
				if (sepangledeg<sepangledeglim) { break; }
				if (time_in>=time_out) {break;}
			}
		   dfm_arret_pointage(tel);
		}
      sate_move_radec=' ';
      dfm_suivi_marche(tel);
   }
	sprintf(s,"after 500"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_hadec_goto(struct telprop *tel)
{
   char s[1024],bits[25];
   int time_in=0,time_out=70;
	double sepangledeg,sepangledeglim;

   dfm_arret_pointage(tel);
   dfm_hadec_goto(tel);
   sate_move_radec='A';
	sepangledeglim=5./3600;
   if (tel->radec_goto_blocking==1) {
      /* A loop is actived until the telescope is stopped */
		if (tel->blockingmethod==0) {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				dfm_stat(tel,s,bits);
				if (bits[0]==0) { break; }
				if (time_in>=time_out) {break;}
			}
		} else {
			while (1==1) {
   			time_in++;
				sprintf(s,"after 350"); mytel_tcleval(tel,s);
				dfm_movingdetect(tel,0,&sepangledeg);
				if (sepangledeg<sepangledeglim) { break; }
				if (time_in>=time_out) {break;}
			}
		}
      sate_move_radec=' ';
	  dfm_suivi_marche(tel);
   }
	sprintf(s,"after 500"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_move(struct telprop *tel,char *direction)
{
   char s[1024],direc[10];
   int res;
   double pos,length,rate;
   
   if (tel->radec_move_rate>1.0) {
      tel->radec_move_rate=1;
   } else if (tel->radec_move_rate<0.) {
      tel->radec_move_rate=0.;
   }
	pos=0.;
	length=3600;
	rate=tel->radec_move_rate*180.;
   if (strcmp(direc,"N")==0) {
		pos=0.;
   } else if (strcmp(direc,"S")==0) {
		pos=180.;
   } else if (strcmp(direc,"E")==0) {
		pos=90.;
   } else if (strcmp(direc,"W")==0) {
		pos=270.;
   }
   sprintf(s,"#17,%f,%f,%f",rate,length,pos);
   res=dfm_put(tel,s);
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_stop(struct telprop *tel,char *direction)
{
   if (sate_move_radec=='A') {
      /* on arrete un GOTO */
      dfm_stopgoto(tel);
      sate_move_radec=' ';
   } else {
      /* on arrete un MOVE */
      dfm_stopgoto(tel);
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
      dfm_suivi_arret(tel);
   } else {
      /* start the motor */
      dfm_suivi_marche(tel);
   }
   sprintf(s,"after 50"); mytel_tcleval(tel,s);
   return 0;
}

int mytel_radec_coord(struct telprop *tel,char *result)
{
   dfm_coord(tel,result);
   return 0;
}

int mytel_focus_init(struct telprop *tel)
{
   return 0;
}

int mytel_focus_goto(struct telprop *tel)
{
   char s[1024],bits[25];
   int time_in=0,time_out=70,res;
	sprintf(s,"#27,%f;",tel->focus0);
   res=dfm_put(tel,s);
   sate_move_radec='A';
   if (tel->focus_goto_blocking==1) {
      /* A loop is actived until the focus is stopped */
      while (1==1) {
   	   time_in++;
         sprintf(s,"after 350"); mytel_tcleval(tel,s);
			dfm_stat(tel,s,bits);
			if (bits[15]==0) { break; }
         if (time_in>=time_out) {break;}
      }
      sate_move_radec=' ';
   }
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
   dfm_hadec_coord(tel,result);
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
#if defined DFM_MOUCHARD
   FILE *f;
   f=fopen("mouchard_dfm.txt","at");
   fprintf(f,"EVAL <%s>\n",ligne);
   fclose(f);
#endif
   if (Tcl_Eval(tel->interp,ligne)!=TCL_OK) {
#if defined DFM_MOUCHARD
      f=fopen("mouchard_dfm.txt","at");
      fprintf(f,"RESU-PB <%s>\n",Tcl_GetStringResult(tel->interp));
      fclose(f);
#endif
      return 1;
   }
#if defined DFM_MOUCHARD
   f=fopen("mouchard_dfm.txt","at");
   fprintf(f,"RESU-OK <%s>\n",Tcl_GetStringResult(tel->interp));
   fclose(f);
#endif
   return 0;
}

int dfm_delete(struct telprop *tel)
{
   char s[1024];
	/* --- Fermeture du port com ou tcp */
	if (strcmp(tel->channel,"")!=0) {
		sprintf(s,"catch {close %s} ",tel->channel); mytel_tcleval(tel,s);
	}
   return 0;
}

int dfm_put(struct telprop *tel,char *cmd)
{
   char s[1024],ss[1024],c[]="\\%c";

	if (tel->type==1) {
		sprintf(s,"regsub -all \\# \"%s\" \"\" a ; regsub -all , \"$a\" \"[format %s 0x0D]\" s ; regsub -all \\; \"$s\" \"[format %s 0x0D];\" a ; set a $a",cmd,c,c);
		if (mytel_tcleval(tel,s)==1) {
			return 1;
		}
	   strcpy(ss,Tcl_GetStringResult(tel->interp));
	} else {
		strcpy(ss,cmd);
	}
	sprintf(s,"puts -nonewline %s \"%s\"",tel->channel,ss);
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
   return 0;
}

int dfm_read(struct telprop *tel,char *res)
{
   char s[2048],c[]="\\%c";
	strcpy(res,"");
	sprintf(s,"read -nonewline %s",tel->channel);
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
	if (tel->type==0) {
		sprintf(s,"regsub -all \\# \"%s\" \"\" a ; regsub -all \\; \"$a\" \"\" s ; split $s ,",Tcl_GetStringResult(tel->interp));
	} else {
		sprintf(s,"regsub -all \\# \"%s\" \"\" a ; regsub -all \\; \"$a\" \"\" s ; split $s \"[format %s 0x0D]\"",Tcl_GetStringResult(tel->interp),c);
	}
	if (mytel_tcleval(tel,s)==1) {
		return 1;
	}
	strcpy(res,Tcl_GetStringResult(tel->interp));
   return 0;
}

/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage dfm   --------------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int dfm_connection(struct telprop *tel)
/*
*
*/
{
   char s[1024],ss[1024];
   char ssusb[1024],ssres[1024];
   int k;
	dfm_delete(tel);
	/* ============ */
	/* === TCP  === */
	/* ============ */
	if (tel->type==0) {
		strcpy(ss,tel->portcom);
		/* --- open the port and record the channel name ---*/
		sprintf(s,"socket \"%s\" \"%d\"",tel->ip,tel->port);
		if (mytel_tcleval(tel,s)==1) {
			strcpy(tel->msg,Tcl_GetStringResult(tel->interp));
			return 1;
		}
		strcpy(tel->channel,Tcl_GetStringResult(tel->interp));
		/* --- configuration of the TCP socket ---*/
		//sprintf(s,"fconfigure %s  -buffering none -blocking 0 -eofchar { } -buffersize 100000",tel->channel); mytel_tcleval(tel,s);
		sprintf(s,"fconfigure %s  -buffering none -blocking 0 -eofchar { } -buffersize 1000",tel->channel); mytel_tcleval(tel,s);
		sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
	}
	/* ============== */
	/* === EXCOM  === */
	/* ============== */
	if (tel->type==1) {
		/* --- transcode a port argument into comX or into /dev... */
		strcpy(ss,tel->portcom);
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
			} else {
				strcpy(tel->msg,ssres);
				return 1;
			}
		}
		strcpy(tel->channel,Tcl_GetStringResult(tel->interp));
		/*
		# 9600 : vitesse de transmission (bauds)
		# 0 : 0 bit de parity
		# 8 : 8 bits de data
		# 1 : 1 bits de stop
		*/
		sprintf(s,"fconfigure %s -mode \"9600,n,8,1\" -buffering none -translation {binary binary} -blocking 0",tel->channel); mytel_tcleval(tel,s);
	}
   return 0;
}

int dfm_stat(struct telprop *tel,char *result,char *bits)
/*
*
*/
{
   char s[1024],ss[1024];
   int res,octet,k,pos,b,bos;
   Tcl_DString dsptr;
   Tcl_DStringInit(&dsptr);
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function STAT --- */
   res=dfm_put(tel,"#26;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=dfm_read(tel,ss);
	k=0;
	/* Byte STATL */
	strcpy(s,"{ ");Tcl_DStringAppend(&dsptr,s,-1);
   sprintf(s,"lindex \"%s\" 0",ss); mytel_tcleval(tel,s);
	octet=atoi(Tcl_GetStringResult(tel->interp));
	pos=7;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{slewing %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=6;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{final_limit %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=5;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{approaching_limit %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=4;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{dome_on/off %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=3;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{slew_enable %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=2;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{track_on/off %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=1;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{guide_on/off %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=0;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{initialized %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	strcpy(s,"} ");Tcl_DStringAppend(&dsptr,s,-1);

	/* Byte STATH */
	strcpy(s,"{ ");Tcl_DStringAppend(&dsptr,s,-1);
   sprintf(s,"lindex \"%s\" 1",ss); mytel_tcleval(tel,s);
	octet=atoi(Tcl_GetStringResult(tel->interp));
	pos=7;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{drives_on/off %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=6;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{rate_cor_on/off %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=5;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{cosdec_on/off %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=4;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{target_out_of_range %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=3;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{dome_ok %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=2;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{excom_on/off %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=1;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{trailing %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=0;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{setting %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	strcpy(s,"} ");Tcl_DStringAppend(&dsptr,s,-1);
	/* Byte STATLH */
	strcpy(s,"{ ");Tcl_DStringAppend(&dsptr,s,-1);
   sprintf(s,"lindex \"%s\" 2",ss); mytel_tcleval(tel,s);
	octet=atoi(Tcl_GetStringResult(tel->interp));
	pos=7;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{aux._track_rate %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=6;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{next_object_active %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=5;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{W %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=4;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{E %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=3;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{S %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=2;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{N %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=1;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{dome_track/free %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	octet=octet-bos*b;
	pos=0;bos=(int)pow(2,pos);b=(int)floor(octet/bos);sprintf(bits+k,"%d",b);k++;
	sprintf(s,"{slew_computing %d} ",b);Tcl_DStringAppend(&dsptr,s,-1);
	strcpy(s,"} ");Tcl_DStringAppend(&dsptr,s,-1);
	/* */
	bits[k]='\0';
	strcpy(result,Tcl_DStringValue(&dsptr));
   Tcl_DStringFree(&dsptr);
   return 0;
}

int dfm_arret_pointage(struct telprop *tel)
{
   char s[1024];
   int res;
   /*--- Arret mouvement des moteurs */
   sprintf(s,"#13;");
   res=dfm_put(tel,s);
   return 0;
}

int dfm_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024];
   int res;
   char ras[20];
   char decs[20];   
	double ra,dec;
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function COORDS --- */
   res=dfm_put(tel,"#25;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=dfm_read(tel,ss);
   sprintf(s,"lindex \"%s\" 1",ss); mytel_tcleval(tel,s);
	ra=15.*atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex \"%s\" 2",ss); mytel_tcleval(tel,s);
	dec=atof(Tcl_GetStringResult(tel->interp));
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 0 auto string",ra); mytel_tcleval(tel,s);
   strcpy(ras,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2dms %f 90 zero 0 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
   sprintf(result,"%s %s",ras,decs);
   return 0;
}

int dfm_hadec_coord(struct telprop *tel,char *result)
/*
*
*/
{
   char s[1024],ss[1024];
   int res;
   char has[20];
   char decs[20];   
	double ha,dec;
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function COORDS --- */
   res=dfm_put(tel,"#25;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=dfm_read(tel,ss);
   sprintf(s,"lindex \"%s\" 0",ss); mytel_tcleval(tel,s);
	ha=15.*atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex \"%s\" 2",ss); mytel_tcleval(tel,s);
	dec=atof(Tcl_GetStringResult(tel->interp));
   /* --- --- */
   sprintf(s,"mc_angle2hms %f 360 zero 0 auto string",ha); mytel_tcleval(tel,s);
   strcpy(has,Tcl_GetStringResult(tel->interp));
   sprintf(s,"mc_angle2dms %f 90 zero 0 + string",dec); mytel_tcleval(tel,s);
   strcpy(decs,Tcl_GetStringResult(tel->interp));
   sprintf(result,"%s %s",has,decs);
   return 0;
}

int dfm_movingdetect(struct telprop *tel,int hara, double *sepangledeg)
/*
*
*/
{
   char s[1024],ss[1024];
   int res,khara=0;
	double ra1,dec1,ra2,dec2;
	if (hara==0) { khara=0; } else { khara=1; }
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function COORDS --- */
   res=dfm_put(tel,"#25;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=dfm_read(tel,ss);
   sprintf(s,"lindex \"%s\" %d",ss,khara); mytel_tcleval(tel,s);
	ra1=15.*atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex \"%s\" 2",ss); mytel_tcleval(tel,s);
	dec1=atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function COORDS --- */
   res=dfm_put(tel,"#25;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=dfm_read(tel,ss);
   sprintf(s,"lindex \"%s\" %d",ss,khara); mytel_tcleval(tel,s);
	ra2=15.*atof(Tcl_GetStringResult(tel->interp));
   sprintf(s,"lindex \"%s\" 2",ss); mytel_tcleval(tel,s);
	dec2=atof(Tcl_GetStringResult(tel->interp));
   /* --- retourne l'angle de separation --- */
   sprintf(s,"lindex [mc_sepangle %.7f %.7f %.7f %.7f] 0",ra1,dec1,ra2,dec2); mytel_tcleval(tel,s);
   *sepangledeg=atof(Tcl_GetStringResult(tel->interp));
   return 0;
}

int dfm_match(struct telprop *tel)
{
   char s[1024];
   int res;
	double epoch=2000.;
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function ZPOINT --- */
	sprintf(s,"#3,%.6f,%.6f,%f;",tel->ra0/15,tel->dec0,epoch);
   res=dfm_put(tel,s);
   /* --- --- */
   return 0;
}

int dfm_goto(struct telprop *tel)
{
   char s[1024];
   int res;
	double epoch=2000.;
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function SLEW --- */
	sprintf(s,"#6,%.6f,%.6f,%f;",tel->ra0/15,tel->dec0,epoch);
   res=dfm_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=dfm_put(tel,"#12;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   //res=dfm_put(tel,"#22,2000.;");
   /* --- --- */
   return 0;
}

int dfm_hadec_goto(struct telprop *tel)
{
   char s[1024];
   int res;
	double epoch=2000.;
	double lst,sec,ra;
	int h,m;
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- Angle horaire --- */
	lst=dfm_tsl(tel,&h,&m,&sec);
	ra=fmod(lst-tel->ra0+360,360);
   /* --- function SLEW --- */
	sprintf(s,"#6,%.6f,%.6f,%f;",ra/15,tel->dec0,epoch);
   res=dfm_put(tel,s);
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   res=dfm_put(tel,"#12;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   //res=dfm_put(tel,"#22,2000.;");
   /* --- --- */
   return 0;
}

int dfm_initzenith(struct telprop *tel)
{
	int res;
	char s[1024];
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function TRACK --- */
   res=dfm_put(tel,"#14,0,0,0,0;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- function ZENITH --- */
   res=dfm_put(tel,"#10;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- --- */
   /* --- function SLEW --- */
   res=dfm_put(tel,"#12;");
   return 0;
}

int dfm_initfiducial(struct telprop *tel)
{
	int res;
	char s[1024];
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function TRACK --- */
   res=dfm_put(tel,"#14,0,0,0,0;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- function ZENITH --- */
   res=dfm_put(tel,"#30,0;");
   sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
   /* --- --- */
   return 0;
}

int dfm_stopgoto(struct telprop *tel)
{
   char s[1024];
   int res;
   /*--- Arret mouvement des moteurs */
   sprintf(s,"#13;");
   res=dfm_put(tel,s);
   return 0;
}

int dfm_stategoto(struct telprop *tel,int *state)
{
   return 0;
}

int dfm_suivi_arret (struct telprop *tel)
{
	int res;
	char s[1024];
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function TRACK --- */
   strcpy(s,"#14,0,0,0,0;");
   res=dfm_put(tel,s);
	return 0;
}

int dfm_suivi_marche (struct telprop *tel)
{
	int res;
	char s[1024];
   /* --- Vide le buffer --- */
   res=dfm_read(tel,s);
   /* --- function TRACK --- */
   sprintf(s,"#14,%.6f,%.6f,%.6f,%.6f;",tel->speed_track_ra*3600,tel->speed_track_dec*3600,tel->speed_track_ra*3600,tel->speed_track_dec*3600);
   res=dfm_put(tel,s);
	return 0;
}

int dfm_position_tube(struct telprop *tel,char *sens)
{
   return 0;
}

int dfm_setderive(struct telprop *tel,int var, int vdec)
{
   return 0;
}

int dfm_getderive(struct telprop *tel,int *var,int *vdec)
{
   return 0;
}


/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/
/* ----------------- langage dfm TOOLS ----------------------*/
/* ---------------------------------------------------------------*/
/* ---------------------------------------------------------------*/

int dfm_home(struct telprop *tel, char *home_default)
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

double dfm_tsl(struct telprop *tel,int *h, int *m,double *sec)
{
   char s[1024];
   char ss[1024];
   static double tsl;
   /* --- temps sideral local */
   dfm_home(tel,"");
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
