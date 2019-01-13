/* telescop.h
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

#ifndef __TELESCOP_H__
#define __TELESCOP_H__

#include <tcl.h>
#include <libtel/libstruc.h>

#ifdef __cplusplus
extern "C" {      
#endif             // __cplusplus */

/*
 * Donnees propres a chaque telescope.
 */

//#define MOUCHARD
//#define MOUCHARD_EVAL

#define SCRIPT_TYPE_FILE 0
#define SCRIPT_TYPE_PROC 1

/* --- structure qui accueille les parametres---*/
struct telprop {
   /* --- parametres standards, ne pas changer ---*/
   COMMON_TELSTRUCT
   /* Ajoutez ici les variables necessaires a votre telescope */
	char loopThreadId[20];
	int script_type;
	char script[1024];
	char script_setup[1024];
	char proc_setup[128];
	char script_loop[1024];
	char proc_loop[128];
	char telname[100];
	char eval_command_line[1024];
	char eval_result[1024];
	char loop_error[1024];
	char home[80];
	char message[4096];
	char variables[4096];
	//
	int exit;
	int after;
	char action_next[100];
	char action_prev[100];
	char motion_next[100];
	char motion_prev[100];
	int compteur;
	int source;
	//
	double coord_app_cod_deg_dec;
	double coord_app_cod_deg_ha;
	double coord_app_cod_deg_ra;
	double ha0;
	//
	int hadec_goto_blocking;
	char move_direction[5];

};

#include "pthread.h"
pthread_mutex_t mutex;
pthread_mutexattr_t mutexAttr;

int tel_init(struct telprop *tel, int argc, char **argv);
int tel_goto(struct telprop *tel);
int tel_coord(struct telprop *tel,char *result);
int tel_testcom(struct telprop *tel);
int tel_close(struct telprop *tel);
int tel_radec_init(struct telprop *tel);
int tel_radec_goto(struct telprop *tel);
int tel_radec_state(struct telprop *tel,char *result);
int tel_radec_coord(struct telprop *tel,char *result);
int tel_radec_move(struct telprop *tel,char *direction);
int tel_radec_stop(struct telprop *tel,char *direction);
int tel_radec_motor(struct telprop *tel);
int tel_focus_init(struct telprop *tel);
int tel_focus_goto(struct telprop *tel);
int tel_focus_coord(struct telprop *tel,char *result);
int tel_focus_move(struct telprop *tel,char *direction);
int tel_focus_stop(struct telprop *tel,char *direction);
int tel_focus_motor(struct telprop *tel);
int tel_date_get(struct telprop *tel,char *ligne);
int tel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int tel_home_get(struct telprop *tel,char *ligne);
int tel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);
int tel_get_position_tube(struct telprop *tel);

int mytel_radec_init(struct telprop *tel);
int mytel_hadec_init(struct telprop *tel);
int mytel_radec_init_additional(struct telprop *tel);
int mytel_radec_goto(struct telprop *tel);
int mytel_hadec_goto(struct telprop *tel);
int mytel_radec_state(struct telprop *tel,char *result);
int mytel_radec_coord(struct telprop *tel,char *result);
int mytel_hadec_coord(struct telprop *tel,char *result);
int mytel_radec_move(struct telprop *tel,char *direction);
int mytel_radec_stop(struct telprop *tel,char *direction);
int mytel_radec_motor(struct telprop *tel);
int mytel_focus_init(struct telprop *tel);
int mytel_focus_goto(struct telprop *tel);
int mytel_focus_coord(struct telprop *tel,char *result);
int mytel_focus_move(struct telprop *tel,char *direction);
int mytel_focus_stop(struct telprop *tel,char *direction);
int mytel_focus_motor(struct telprop *tel);
int mytel_date_get(struct telprop *tel,char *ligne);
int mytel_date_set(struct telprop *tel,int y,int m,int d,int h, int min,double s);
int mytel_home_get(struct telprop *tel,char *ligne);
int mytel_home_set(struct telprop *tel,double longitude,char *ew,double latitude,double altitude);
int mytel_init_mount_default(struct telprop *tel,int mountno);
int mytel_tcl_procs(struct telprop *tel);
int mytel_motor_off(struct telprop *tel);
int mytel_motor_stop(struct telprop *tel);
int mytel_motor_move_stop(struct telprop *tel);
int mytel_app_cod_setadu(struct telprop *tel);
int mytel_app_sim_setadu(struct telprop *tel);
int mytel_motor_move_start(struct telprop *tel);



int mytel_adu_coord(struct telprop *tel,char *result);

int mytel_get_format(struct telprop *tel);
int mytel_set_format(struct telprop *tel,int longformatindex);
int mytel_flush(struct telprop *tel);
int mytel_tcleval(struct telprop *tel,char *ligne);
int mytel_correct(struct telprop *tel,char *direction, int duration);

int my_pthread_mutex_lock (pthread_mutex_t * mutex);
int my_pthread_mutex_unlock (pthread_mutex_t * mutex);

void mytel_decimalsymbol(char *strin, char decin, char decout, char *strout);
void mytel_error(struct telprop *tel,int axisno, int err);
int etel_home(struct telprop *tel, char *home_default);
double etel_tsl(struct telprop *tel,int *h, int *m,int *sec);
void etel_GetCurrentFITSDate_function(Tcl_Interp *interp, char *s,char *function);
void etel_radec_coord(struct telprop *tel, int flagha, int *voidangles,double *angledegs,int *angleucs);

int mytel_get_register(struct telprop *tel,int axisno,int typ,int idx,int sidx,int *val);
int mytel_execute_command(struct telprop *tel,int axisno,int cmd,int nparams,int typ,int conv,double val);
int mytel_set_register(struct telprop *tel,int axisno,int typ,int idx,int sidx,int val);
void mytel_tel2cat(struct telprop *tel, double jd, double coord1, double coord2, double *raJ2000, double *decJ2000);
void mytel_cat2tel(struct telprop *tel, double jd, double raJ2000, double decJ2000);
void mytel_coord_stopped(struct telprop *tel);
int mytel_loadparams(struct telprop *tel,int naxisno);
int mytel_limites(void);

// --- MCMT
int mytel_motor_on(struct telprop *tel);
int mytel_mcmt_stop(struct telprop *tel);
int mytel_mcmt_tcl_procs(struct telprop *tel);

// --- cod and sim coordinate systems
double mytel_sec2jd(time_t secs1970);
int mytel_app_cod_getadu(struct telprop *tel);
void mytel_app_cod_setadu0(struct telprop *tel);
void mytel_app_cod_setdadu(struct telprop *tel);
void mytel_app_cod_adu2deg(struct telprop *tel);
void mytel_app2cat_cod_deg(struct telprop *tel);
void mytel_cat2app_cod_deg(struct telprop *tel, double jd);
void mytel_app_cod_deg2adu(struct telprop *tel);
void mytel_app2cat_cod_deg0(struct telprop *tel);
void mytel_cat2app_cod_deg0(struct telprop *tel);
int mytel_app_sim_getadu(struct telprop *tel);
void mytel_app_sim_setadu0(struct telprop *tel);
void mytel_app_sim_setdadu(struct telprop *tel);
void mytel_app_sim_adu2deg(struct telprop *tel);
void mytel_app2cat_sim_deg(struct telprop *tel);
void mytel_cat2app_sim_deg(struct telprop *tel, double jd);
void mytel_app_sim_deg2adu(struct telprop *tel);
void mytel_app2cat_sim_deg0(struct telprop *tel);
void mytel_cat2app_sim_deg0(struct telprop *tel);
void mytel_app_setutcjd0_now(struct telprop *tel);
void mytel_app_setutcjd_now(struct telprop *tel);
void mytel_speed_corrections(struct telprop *tel);

// --- thread
struct telprop *telthread;
int ThreadTel_loop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int ThreadTel_Init(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
static int CmdThreadTel_loopeval(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

#ifdef __cplusplus
}
#endif      // __cplusplus


#endif

