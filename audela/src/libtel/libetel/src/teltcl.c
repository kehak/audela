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

int cmdTelStatus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char ligne[256], s[32767];
	int result = TCL_OK, err = 0, k;
	DSA_STATUS sta = { sizeof(DSA_STATUS) };
	struct telprop *tel;
	tel = (struct telprop *)clientData;
	/* getting status */
	/* --- boucle sur les axes ---*/
	strcpy(s, "");
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
			if (err = dsa_get_status(tel->etel.drv[k], &sta)) {
				etel_error(tel,k, err);
				sprintf(ligne, "%s", tel->etel.msg);
				Tcl_SetResult(interp, ligne, TCL_VOLATILE);
				return TCL_ERROR;
			}
			strcpy(ligne, "{"); strcat(s, ligne);
			sprintf(ligne, "{raw.sw1 %d} ", sta.raw.sw1); strcat(s, ligne);
			sprintf(ligne, "{raw.sw2 %d} ", sta.raw.sw2); strcat(s, ligne);
			sprintf(ligne, "{drive.present %d} ", sta.drive.present); strcat(s, ligne);
			sprintf(ligne, "{drive.moving %d} ", sta.drive.moving); strcat(s, ligne);
			sprintf(ligne, "{drive.in_window %d} ", sta.drive.in_window); strcat(s, ligne);
			sprintf(ligne, "{drive.sequence %d} ", sta.drive.sequence); strcat(s, ligne);
			sprintf(ligne, "{drive.error %d} ", sta.drive.error); strcat(s, ligne);
			sprintf(ligne, "{drive.trace %d} ", sta.drive.trace); strcat(s, ligne);
			sprintf(ligne, "{drive.warning %d} ", sta.drive.warning); strcat(s, ligne);
			sprintf(ligne, "{drive.breakpoint %d} ", sta.drive.breakpoint); strcat(s, ligne);
			sprintf(ligne, "{drive.user %d} ", sta.drive.user); strcat(s, ligne);
			sprintf(ligne, "{dsmax.present %d} ", sta.dsmax.present); strcat(s, ligne);
			sprintf(ligne, "{dsmax.moving %d} ", sta.dsmax.moving); strcat(s, ligne);
			sprintf(ligne, "{dsmax.sequence %d} ", sta.dsmax.sequence); strcat(s, ligne);
			sprintf(ligne, "{dsmax.error %d} ", sta.dsmax.error); strcat(s, ligne);
			sprintf(ligne, "{dsmax.trace %d} ", sta.dsmax.trace); strcat(s, ligne);
			sprintf(ligne, "{dsmax.warning %d} ", sta.dsmax.warning); strcat(s, ligne);
			//sprintf(ligne,"{dsmax.breakpoint %d} ", sta.dsmax.breakpoint); strcat(s,ligne);
			sprintf(ligne, "{dsmax.user %d} ", sta.dsmax.user); strcat(s, ligne);
			strcpy(ligne, "} "); strcat(s, ligne);
		}
	}
	Tcl_SetResult(interp, s, TCL_VOLATILE);
	return result;
}

int cmdTelExecuteCommandXS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char ligne[256];
	int result = TCL_OK, err = 0;
	DSA_COMMAND_PARAM params[] = { { 0,0,0 },{ 0,0,0 },{ 0,0,0 },{ 0,0,0 },{ 0,0,0 } };
	int cmd, nparams, k, kk;
	int axisno;
	struct telprop *tel;
	tel = (struct telprop *)clientData;
#if defined(MOUCHARD)
	FILE *f;
#endif

	if (argc<4) {
		sprintf(ligne, "usage: %s axisno cmd nparams ?typ1 conv1 par1? ?type2 conv2 par2? ...", argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}

	axisno = atoi(argv[2]);

	if (argc >= 4) {
		cmd = atoi(argv[3]);
	}
	if (argc >= 5) {
		nparams = atoi(argv[4]);
}
	for (k = 5; k<argc - 2; k += 3) {
		kk = (k - 3) / 3;
		if (kk>4) {
			break;
		}
		params[kk].typ = atoi(argv[k]); // =0 in general
		params[kk].conv = atoi(argv[k + 1]); // =0 if digital units
		if (params[kk].conv == 0) {
			params[kk].val.i = atoi(argv[k + 2]);
		}
		else {
			params[kk].val.d = atof(argv[k + 2]);
		}
	}
#if defined(MOUCHARD)
	f = fopen("mouchard_etel1.txt", "at");
	fprintf(f, "dsa_execute_command_x_s(%d=>axe%d,%d,%d,%d)\n", etel.drv[axisno], axisno, cmd, params[kk].val.i, nparams);
	fclose(f);
#endif
	if (err = dsa_execute_command_x_s(tel->etel.drv[axisno], cmd, params, nparams, FALSE, FALSE, DSA_DEF_TIMEOUT)) {
		etel_error(tel,k, err);
		sprintf(ligne, "%s", tel->etel.msg);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	Tcl_SetResult(interp, "", TCL_VOLATILE);
	return result;
}

int cmdTelGetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char ligne[1024];
	int result = TCL_OK, err = 0, axisno, k;
	int typ, idx, sidx = 0, ks, ctype;
	long val;
	double vald;
	float valf;
	__int64 vall;
	struct telprop *tel;
	tel = (struct telprop *)clientData;
	/*
	#if defined(MOUCHARD)
	FILE *f;
	#endif
	*/
	if (argc<4) {
		sprintf(ligne, "usage: %s axisno typ(", argv[1]);
		for (k = 0; k<NB_TYP; k++) {
			if (k>0) {
				strcat(ligne, "|");
			}
			strcat(ligne, tel->typs[k].type_symbol);
	}
		strcat(ligne, ") idx ?sidx?");
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
}
	axisno = atoi(argv[2]);
	ks = etel_symbol2type(tel,argv[3]);
	if (ks == -1) {
		typ = atoi(argv[3]);
	}
	else {
		typ = tel->typs[ks].typ;
		ctype = tel->typs[ks].ctype;
	}
	idx = atoi(argv[4]);
	if (argc >= 6) {
		sidx = atoi(argv[5]);
	}
	if (ctype == ETEL_VAL_INT32) {
		err = dsa_get_register_int32_s(tel->etel.drv[axisno], typ, idx, sidx, &val, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%d", val);
	}
	else if (ctype == ETEL_VAL_INT64) {
		err = dsa_get_register_int64_s(tel->etel.drv[axisno], typ, idx, sidx, &vall, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%I64i", vall);
	}
	else if (ctype == ETEL_VAL_FLOAT32) {
		err = dsa_get_register_float32_s(tel->etel.drv[axisno], typ, idx, sidx, &valf, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%f", valf);
	}
	else if (ctype == ETEL_VAL_FLOAT64) {
		err = dsa_get_register_float64_s(tel->etel.drv[axisno], typ, idx, sidx, &vald, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
		sprintf(ligne, "%lf", vald);
	}
	if (err != 0) {
		etel_error(tel,axisno, err);
		sprintf(ligne, "%s", tel->etel.msg);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	/*
	#if defined(MOUCHARD)
	f=fopen("mouchard_etel.txt","at");
	fprintf(f,"dsa_get_register_s(%d=>axe%d,%d,%d,%d) => %s\n",etel.drv[axisno],axisno,typ,idx,sidx,ligne);
	fclose(f);
	#endif
	*/
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	return result;
	}

int cmdTelSetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char ligne[1024];
	int result = TCL_OK, err = 0, axisno, k;
	int typ, idx, sidx = 0, ks, ctype;
	long val;
	double vald;
	float valf;
	__int64 vall;
	struct telprop *tel;
	tel = (struct telprop *)clientData;
#if defined(MOUCHARD)
	FILE *f;
#endif
	if (argc<7) {
		sprintf(ligne, "usage: %s axisno typ(", argv[1]);
		for (k = 0; k<NB_TYP; k++) {
			if (k>0) {
				strcat(ligne, "|");
			}
			strcat(ligne, tel->typs[k].type_symbol);
		}
		strcat(ligne, ") idx sidx val");
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	axisno = atoi(argv[2]);
	ks = etel_symbol2type(tel, argv[3]);
	if (ks == -1) {
		typ = atoi(argv[3]);
	}
	else {
		typ = tel->typs[ks].typ;
		ctype = tel->typs[ks].ctype;
	}
	idx = atoi(argv[4]);
	sidx = atoi(argv[5]);
	if (ctype == ETEL_VAL_INT32) {
		val = (long)atol(argv[6]);
		err = dsa_set_register_int32_s(tel->etel.drv[axisno], typ, idx, sidx, val, DSA_DEF_TIMEOUT);
	}
	else if (ctype == ETEL_VAL_INT64) {
		vall = (__int64)atoi64(argv[6], 10);
		err = dsa_set_register_int64_s(tel->etel.drv[axisno], typ, idx, sidx, vall, DSA_DEF_TIMEOUT);
	}
	else if (ctype == ETEL_VAL_FLOAT32) {
		valf = (float)atof(argv[6]);
		err = dsa_set_register_float32_s(tel->etel.drv[axisno], typ, idx, sidx, valf, DSA_DEF_TIMEOUT);
	}
	else if (ctype == ETEL_VAL_FLOAT64) {
		vald = (double)atof(argv[6]);
		err = dsa_set_register_float64_s(tel->etel.drv[axisno], typ, idx, sidx, vald, DSA_DEF_TIMEOUT);
	}
	if (err != 0) {
		etel_error(tel,axisno, err);
		sprintf(ligne, "%s", tel->etel.msg);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
#if defined(MOUCHARD)
	f = fopen("mouchard_etel.txt", "at");
	fprintf(f, "dsa_set_register_s(%d=>axe%d,%d,%d,%d,%d)\n", etel.drv[axisno], axisno, typ, idx, sidx, val);
	fclose(f);
#endif
	Tcl_SetResult(interp, "", TCL_VOLATILE);
	return result;
}

int cmdTelDsa_quick_stop_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/*
* Now it's time to stop the motor. the dsa_quick_stop_s()
* function will bypass any other command pending into the drive.
* If the motor is already stopped, this operation doesn't have
* any effect.
*/
//#define DSA_QS_BYPASS                    2           /* bypass all pending command */
//#define DSA_QS_INFINITE_DEC              1           /* stop motor with infinite deceleration (step) */
//#define DSA_QS_POWER_OFF                 0           /* switch off power bridge */
//#define DSA_QS_PROGRAMMED_DEC            2           /* stop motor with programmed deceleration */
//#define DSA_QS_STOP_SEQUENCE             1           /* also stop the sequence */

/****************************************************************************/
{
	char ligne[256];
	int result = TCL_OK, err = 0, axisno;
	struct telprop *tel;
	tel = (struct telprop *)clientData;
	if (argc<2) {
		sprintf(ligne, "usage: %s axisno", argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	axisno = atoi(argv[2]);
	if (err = dsa_quick_stop_s(tel->etel.drv[axisno], DSA_QS_PROGRAMMED_DEC, DSA_QS_BYPASS | DSA_QS_STOP_SEQUENCE, DSA_DEF_TIMEOUT)) {
		etel_error(tel,axisno, err);
		sprintf(ligne, "%s", tel->etel.msg);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	Tcl_SetResult(interp, "", TCL_VOLATILE);
	return result;
}

int cmdTelDsa_power_on_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char ligne[256];
	int result = TCL_OK, err = 0, axisno;
	struct telprop *tel;
	tel = (struct telprop *)clientData;
	if (argc<2) {
		sprintf(ligne, "usage: %s axisno", argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	axisno = atoi(argv[2]);
	if (err = dsa_power_on_s(tel->etel.drv[axisno], 10000)) {
		sprintf(ligne, "Error axis=%d dsa_power_on_s error=%d", axisno, err);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	sprintf(ligne, "OK axis=%d dsa_power_on_s error=%d", axisno, err);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	return result;
}

int cmdTelDsa_reset_error_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
	char ligne[256];
	int result = TCL_OK, err = 0, axisno;
	struct telprop *tel;
	tel = (struct telprop *)clientData;
	if (argc<2) {
		sprintf(ligne, "usage: %s axisno", argv[1]);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	axisno = atoi(argv[2]);
	if (err = dsa_reset_error_s(tel->etel.drv[axisno], 10000)) {
		sprintf(ligne, "Error axis=%d dsa_power_on_s error=%d", axisno, err);
		Tcl_SetResult(interp, ligne, TCL_VOLATILE);
		return TCL_ERROR;
	}
	sprintf(ligne, "OK axis=%d dsa_reset_error_s error=%d", axisno, err);
	Tcl_SetResult(interp, ligne, TCL_VOLATILE);
	return result;
}

/*
 *   Valeurs des accelerations de pointage (deg/s2)
 */
int cmdTelAccslew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?acc_slew_ra acc_slew_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      value=atof(argv[2]);
      if (value<0.1) { value=0.1; }
      if (value>200.)  { value=200.; }
      tel->acceleration_slew_ra=value;
      value=atof(argv[3]);
      if (value<0.1) { value=0.1; }
      if (value>200.)  { value=200.; }
      tel->acceleration_slew_dec=value;
   }
   sprintf(ligne,"%f %f",tel->acceleration_slew_ra,tel->acceleration_slew_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Valeurs des vitesses de suivi (deg/s)
 */
int cmdTelSpeedtrack(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?speed_track_ra|diurnal speed_track_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      if (strcmp(argv[2],"diurnal")==0) {
         value=tel->track_diurnal;
      } else {
         value=atof(argv[2]);
      }
      if (value<-30.) { value=-30.; }
      if (value>30.)  { value=30.; }
      tel->speed_track_ra=value;
      value=atof(argv[3]);
      if (value<-30.) { value=-30.; }
      if (value>30.)  { value=30.; }
      tel->speed_track_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_track_ra,tel->speed_track_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Valeurs des accelerations de tracking (deg/s2)
 *   Faire en sorte que ces valeurs soient fortes pour que le tracking agisse vite
 */
int cmdTelAcctrack(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?acc_track_ra acc_track_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      value=atof(argv[2]);
      if (value<0.1) { value=0.1; }
      if (value>200.)  { value=200.; }
      tel->acceleration_track_ra=value;
      value=atof(argv[3]);
      if (value<0.1) { value=0.1; }
      if (value>200.)  { value=200.; }
      tel->acceleration_track_dec=value;
   }
   sprintf(ligne,"%f %f",tel->acceleration_track_ra,tel->acceleration_track_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Pointage en coordonnées horaires
 */
int cmdTelHaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],texte[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         if (argc>=4) {
			 /* - call the pointing model if exists -*/
				/*
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
			if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
			}
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,Tcl_GetStringResult(interp));
				*/
			 /* - end of pointing model-*/
            libtel_Getradec(interp,argv[3],&tel->ra0,&tel->dec0);
            mytel_hadec_init(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init {angle_ha angle_dec}",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         /* --- coord ---*/
			mytel_hadec_coord(tel,texte);
			 /* - call the pointing model if exists -*/
         sprintf(ligne,"set libtel(radec) {%s}",texte);
         Tcl_Eval(interp,ligne);
         sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_tel2cat,texte);
         Tcl_Eval(interp,ligne);
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,Tcl_GetStringResult(interp));
			 /* - end of pointing model-*/
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"state")==0) {
         /* --- state ---*/
			tel_radec_state(tel,texte);
            Tcl_SetResult(interp,texte,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
			tel->radec_goto_blocking=0;
			tel->radec_goto_rate=0;
         /* --- goto ---*/
         if (argc>=4) {
			 /* - call the pointing model if exists -*/
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
			if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
			}
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,Tcl_GetStringResult(interp));
			 /* - end of pointing model-*/
            libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
            if (argc>=5) {
               for (k=4;k<=argc-1;k++) {
                  if (strcmp(argv[k],"-rate")==0) {
                     tel->radec_goto_rate=atof(argv[k+1]);
                  }
                  if (strcmp(argv[k],"-blocking")==0) {
                     tel->radec_goto_blocking=atoi(argv[k+1]);
                  }
               }
            }
            mytel_hadec_goto(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s goto {angle_ha angle_dec} ?-rate value? ?-blocking boolean?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         /* --- move ---*/
         if (argc>=4) {
            if (argc>=5) {
               tel->radec_move_rate=atof(argv[4]);
            }
            tel_radec_move(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s move n|s|e|w ?rate?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         if (argc>=4) {
            tel_radec_stop(tel,argv[3]);
         } else {
            tel_radec_stop(tel,"");
         }
      } else if (strcmp(argv[2],"motor")==0) {
         /* --- motor ---*/
         if (argc>=4) {
            tel->radec_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->radec_motor=1;
            }
            tel_radec_motor(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

/*
 *   delai en secondes estime pour un slew sans bouger
 */
int cmdTelDeadDelaySlew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {   
      tel->dead_delay_slew=atof(argv[2]);
   }
   sprintf(s,"%f",tel->dead_delay_slew);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   delai en secondes pour prendre en compte la refraction differentielle
 */
int cmdTelRefracDelay(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {   
		tel->refrac_delay=atof(argv[2]);
   }
   if (argc>=4) {   
		tel->refrac_div=atof(argv[3]);
		if ((tel->refrac_div>0)&&(tel->refrac_div<0.1)) { 
			tel->refrac_div=0.1;
		}
		if ((tel->refrac_div<0)&&(tel->refrac_div>-0.1)) { 
			tel->refrac_div=-0.1;
		}
		if ((tel->refrac_div==0)) { 
			tel->refrac_div=1;
		}
   }
   sprintf(s,"%f %f",tel->refrac_delay,tel->refrac_div);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   Valeurs des vitesses max de pointage (deg/s)
 */
int cmdTelSpeedslew(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   double value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if ((argc!=2)&&(argc<4)) {
      sprintf(ligne,"Usage: %s %s ?speed_slew_ra speed_slew_dec?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   if (argc>=4) {
      value=atof(argv[2]);
      if (value<0.) { value=0.; }
      if (value>300.)  { value=300.; }
      tel->speed_slew_ra=value;
      value=atof(argv[3]);
      if (value<0.) { value=0.; }
      if (value>300.)  { value=300.; }
      tel->speed_slew_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_slew_ra,tel->speed_slew_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Choice of the move mode (tel1 radec move)
 */
int cmdTelMovemode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   struct telprop *tel;
	int move_pulse;
   tel = (struct telprop *)clientData;
	move_pulse=tel->move_pulse;
   if (argc>=3) {
		if (strcmp(argv[2],"continue")==0) {
			move_pulse=0;
		} else if (strcmp(argv[2],"pulse")==0) {
			move_pulse=1;
		} else {
			sprintf(ligne,"Usage: %s %s ?continue|pulse?",argv[0],argv[1]);
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			result = TCL_ERROR;
			return result;
		}
	}
	tel->move_pulse=move_pulse;
	if (tel->move_pulse==0) {
		strcpy(ligne,"continue");
	} else {
		strcpy(ligne,"pulse");
	}
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Get/Set the init positions
 */
int cmdTelPos0(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
		sprintf(ligne,"Usage: %s %s pol|bas ?ADU0 Ang0?",argv[0],argv[1]);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	if (strcmp(argv[2],"pol")==0) {
		if (argc>=5) {
			tel->MecPolAdu0=atof(argv[3]);
			tel->MecPolAng0=atof(argv[4]);
		} else {
			sprintf(ligne,"%f %f",tel->MecPolAdu0,tel->MecPolAng0);
		}
	} else if (strcmp(argv[2],"bas")==0) {
		if (argc>=5) {
			tel->MecBasAdu0=atof(argv[3]);
			tel->MecBasAng0=atof(argv[4]);
		} else {
			sprintf(ligne,"%f %f",tel->MecBasAdu0,tel->MecBasAng0);
		}
	} else if (strcmp(argv[2],"c")==0) {
		sprintf(ligne,"tel->MecPolAdu0=%f tel->MecPolAng0=%f tel->MecBasAdu0=%f tel->MecBasAng0=%f",tel->MecPolAdu0,tel->MecPolAng0,tel->MecBasAdu0,tel->MecBasAng0);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return result;
	} else if (strcmp(argv[2],"tcl")==0) {
		sprintf(ligne,"tel1 pos0 pol %f %f ; tel1 pos0 bas %f %f",tel->MecPolAdu0,tel->MecPolAng0,tel->MecBasAdu0,tel->MecBasAng0);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return result;
	} else {
		sprintf(ligne,"Usage: %s %s pol|bas ?ADU0 Ang0?",argv[0],argv[1]);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		result = TCL_ERROR;
		return result;
	}
	Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return result;
}

/*
 *   Reset the controler
 */
int cmdTelReset(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   int faire,k;
	char value[256];
	cmd_param params[NB_PARAMS_MAXI];
	int nparams;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<4) {
      sprintf(ligne,"Usage: %s %s Bas_0|1 Pol_0|1",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
	} else {
		nparams=0;
		params[nparams].conv=0;
		params[nparams].typ=0;
		params[nparams].vald=79;
		nparams++;
		// ---
      faire=atoi(argv[2]);
		if (faire==1) {
			k=0;
			if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
				etel_ExecuteCommandXS(tel,k,26,params,nparams,value);
			}
		}
		// ---
      faire=atoi(argv[3]);
		if (faire==1) {
			k=1;
			if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
				etel_ExecuteCommandXS(tel,k,26,params,nparams,value);
			}
		}
   }
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

/*
 *  mono ou double pointage
 */
int cmdTelPointingprecision(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   int value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>=3) {
      value=atoi(argv[2]);
		if (value>=1) {
			value=1; // double pointing
		} else {
			value=0; // mono pointing
		}
		tel->slew_hiprecision=value;
	}
   sprintf(ligne,"%d",tel->slew_hiprecision);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *  Get the message code
 *  In the file AccurET-Oper&Soft-Manual-VerK.pdf
 */
int cmdTelGetError(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   char msg[256];
   char msg2[256];
   int result = TCL_OK;
   struct telprop *tel;
	int err,k;
   tel = (struct telprop *)clientData;
	strcpy(ligne,"");
	for (k = 0; k<ETEL_NAXIS_MAXI; k++) {
		if (tel->etel.axis[k] == AXIS_STATE_OPENED) {
			err = etel_GetRegisterS(tel,k,"M",64,0,msg);
			err = atoi(msg);
			strcpy(msg,"");
			if      (err==0) { strcpy(msg,"NO ERROR"); }
         else if (err==3) { strcpy(msg,"OVER CURRENT3"); }
         else if (err==4) { strcpy(msg,"I2T ERR MOTOR"); }
         else if (err==5) { strcpy(msg,"OVER TEMPERAT"); }
         else if (err==6) { strcpy(msg,"OVER VOLTAGE"); }
         else if (err==7) { strcpy(msg,"INRUSH P.SUPPLY"); }
         else if (err==9) { strcpy(msg,"UNDER VOLTAGE"); }
         else if (err==10) { strcpy(msg,"OFFSET CURERROR"); }
         else if (err==11) { strcpy(msg,"I2T ERR CTRL"); }
         else if (err==12) { strcpy(msg,"POWER CHK 3V"); }
         else if (err==13) { strcpy(msg,"SENSOR TEMP ERR"); }
         else if (err==14) { strcpy(msg,"DOUT FUSE KO"); }
         else if (err==15) { strcpy(msg,"ERR MON VOLTAGE"); }
         else if (err==16) { strcpy(msg,"ENDAT OVERFLOW"); }
         else if (err==17) { strcpy(msg,"ENDAT POS LOST"); }
         else if (err==19) { strcpy(msg,"ENDAT POS ERR"); }
         else if (err==20) { strcpy(msg,"ENCODER AMPLITUD"); }
         else if (err==21) { strcpy(msg,"ENCODER POS LOST"); }
         else if (err==22) { strcpy(msg,"SECOND ENCODER"); }
         else if (err==23) { strcpy(msg,"TRACKING ERROR"); }
         else if (err==24) { strcpy(msg,"OVER SPEED"); }
         else if (err==26) { strcpy(msg,"POWER OFF/ON"); }
         else if (err==27) { strcpy(msg,"ENDAT TIMEOUT"); }
         else if (err==28) { strcpy(msg,"TORQUE MODE ERR"); }
         else if (err==29) { strcpy(msg,"MOTOR OVERTEMP"); }
         else if (err==30) { strcpy(msg,"SWITCH LIMIT"); }
         else if (err==31) { strcpy(msg,"ENDAT ENCO ERR"); }
         else if (err==35) { strcpy(msg,"ENCODER FUSE KO"); }
         else if (err==36) { strcpy(msg,"LABEL ERROR"); }
         else if (err==37) { strcpy(msg,"ERR GAIN SCHEDUL"); }
         else if (err==38) { strcpy(msg,"REGISTER NUM ERR"); }
         else if (err==40) { strcpy(msg,"K79 BAD VALUE"); }
         else if (err==41) { strcpy(msg,"K89 BAD VALUE"); }
         else if (err==42) { strcpy(msg,"ERR CFG FDOUT"); }
         else if (err==44) { strcpy(msg,"SET REG BAD PAR"); }
         else if (err==45) { strcpy(msg,"ERR CFG DOUT"); }
         else if (err==46) { strcpy(msg,"ERR CFG TRIGGER"); }
         else if (err==49) { strcpy(msg,"ETH. NOT CONNECT"); }
         else if (err==50) { strcpy(msg,"TCP OUT BUF FULL"); }
         else if (err==51) { strcpy(msg,"TCP IN BUF FULL"); }
         else if (err==53) { strcpy(msg,"TRIGGER ENABLED"); }
         else if (err==55) { strcpy(msg,"TIME OUT KEEPALIV"); }
         else if (err==56) { strcpy(msg,"TIMEOUT TRANSNET"); }
         else if (err==57) { strcpy(msg,"DIPSWITC BAD CFG"); }
         else if (err==58) { strcpy(msg,"BAD SLOT TRANSNET"); }
         else if (err==60) { strcpy(msg,"LEAVEREF ERROR"); }
         else if (err==61) { strcpy(msg,"MULT IDX SEARCH"); }
         else if (err==62) { strcpy(msg,"SING IDX SEARCH"); }
         else if (err==63) { strcpy(msg,"SYNCHRO START"); }
         else if (err==64) { strcpy(msg,"FOUND MEC STOP"); }
         else if (err==65) { strcpy(msg,"OUT OF STROKE"); }
         else if (err==66) { strcpy(msg,"REF OUT OFSTROKE"); }
         else if (err==67) { strcpy(msg,"MVT NOT POSSIBLE"); }
         else if (err==69) { strcpy(msg,"HOME NOT POSSIBLE"); }
         else if (err==70) { strcpy(msg,"BAD CMD PARAM"); }
         else if (err==71) { strcpy(msg,"HOMING NOT DONE"); }
         else if (err==72) { strcpy(msg,"NO PWR ON"); }
         else if (err==73) { strcpy(msg,"STRETCH ERROR"); }
         else if (err==74) { strcpy(msg,"ER SCALE MAPPING"); }
         else if (err==75) { strcpy(msg,"STAGEMAP ACTIVE"); }
         else if (err==76) { strcpy(msg,"STAGEMAP CFG"); }
         else if (err==77) { strcpy(msg,"STAGEMAP STEP ERR"); }
         else if (err==78) { strcpy(msg,"NO POWER DUAL FDB"); }
         else if (err==79) { strcpy(msg,"TRACKING DUAL FDB"); }
         else if (err==87) { strcpy(msg,"USB BUFF IN FULL USB"); }
         else if (err==90) { strcpy(msg,"FORCE CTRL CFG"); }
         else if (err==91) { strcpy(msg,"MVT NOT ALLOWED"); }
         else if (err==99) { strcpy(msg,"EXTBOARD CORRUPT"); }
         else if (err==106) { strcpy(msg,"AD BAD SETTING"); }
         else if (err==116) { strcpy(msg,"EXTERNAL ERROR"); }
         else if (err==118) { strcpy(msg,"GANTRY ERROR"); }
         else if (err==119) { strcpy(msg,"GANTRY TRACKING"); }
         else if (err==120) { strcpy(msg,"GANTRY PWR ERR"); }
         else if (err==121) { strcpy(msg,"GTRY BAD CMD LVL2"); }
         else if (err==122) { strcpy(msg,"GTRY ERR PARAM"); }
         else if (err==123) { strcpy(msg,"GTRY NO SEQ LVL2"); }
         else if (err==124) { strcpy(msg,"GTRY ERR HM OFFST"); }
         else if (err==135) { strcpy(msg,"BRIDGE OVERCUR1"); }
         else if (err==144) { strcpy(msg,"ERROR OSCILLAT"); }
         else if (err==151) { strcpy(msg,"INITIALI MOTOR1"); }
         else if (err==152) { strcpy(msg,"INITIALI POWER OF"); }
         else if (err==153) { strcpy(msg,"INITIALI LOW CUR"); }
         else if (err==154) { strcpy(msg,"INITIALI HIGH CUR"); }
         else if (err==155) { strcpy(msg,"INITIALI LOW TIME"); }
         else if (err==156) { strcpy(msg,"TIMEOUT AUT CMD"); }
         else if (err==180) { strcpy(msg,"ENCODER NO REPLY A"); }
         else if (err==181) { strcpy(msg,"ENCODER NOT SUPP"); }
         else if (err==182) { strcpy(msg,"ENCODER COM ERR"); }
         else if (err==183) { strcpy(msg,"ENCODER ERROR"); }
         else if (err==184) { strcpy(msg,"ENCODER FATAL ER"); }
         else if (err==190) { strcpy(msg,"SWITCH OFF & ON"); }
         else if (err==191) { strcpy(msg,"ERROR DIG HALL"); }
         else if (err==210) { strcpy(msg,"STG PROT INIT ERR"); }
         else if (err==212) { strcpy(msg,"CFG EXT2 ERROR"); }
         else if (err==213) { strcpy(msg,"CFG EXT3 ERROR"); }
         else if (err==214) { strcpy(msg,"STG PROT OTHERAXI"); }
         else if (err==215) { strcpy(msg,"STG PROT SETTING"); }
         else if (err==401) { strcpy(msg,"SEQ BAD REG IDX"); }
         else if (err==402) { strcpy(msg,"SEQ BAD THREAD"); }
         else if (err==403) { strcpy(msg,"SEQ RUN TWICE"); }
         else if (err==404) { strcpy(msg,"SEQ DIV BY ZERO"); }
         else if (err==405) { strcpy(msg,"SEQ BAD CMD PAR"); }
         else if (err==406) { strcpy(msg,"SEQ BAD ACCESS"); }
         else if (err==407) { strcpy(msg,"SEQ BAD NODE"); }
         else if (err==408) { strcpy(msg,"SEQ FCT NOT AVAI"); }
         else if (err==460) { strcpy(msg,"FORMAT SEQ ERR"); }
			else               { strcpy(msg,"UNREFERENCED ERROR"); }
			sprintf(msg2,"{%d {%s}} ",err,msg);
			strcat(ligne,msg2);
		}
	}
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}
