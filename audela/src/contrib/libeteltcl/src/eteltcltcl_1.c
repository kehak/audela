/* eteltcl_1.c
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
#include "eteltcltcl.h"

/*
load libeteltcl.dll
etel_open -driver DSTEB3 -axis 0 -axis 2
etel_close

etel_open -driver DSTEB3 -axis 0 -axis 1
etel_status
etel_get_register_s 0 M 7

etel_set_register_s

etel_execute_command_x_s
*/
//#define MOUCHARD

int Cmd_eteltcltcl_open(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[200],ss[200];
	int k,kk,kkk,err;
   if(argc<3) {
      sprintf(s,"Usage: %s ?-driver name? ?-axis axisno? ?-axis axisno? ...", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
#if defined(MOUCHARD)
		FILE *f;
		f=fopen("mouchard_etel.txt","wt");
		fprintf(f,"Open the driver\n");
		fclose(f);
#endif
		for (k=0;k<ETEL_NAXIS_MAXI;k++) {
			etel.axis[k]=AXIS_STATE_CLOSED;
			etel.drv[k]=NULL;
		}
		strcpy(etel.etel_driver,"DSTEB3");
		if (argc >= 1) {
			kkk=0;
			for (kk = 0; kk < argc-1; kk++) {
				if (strcmp(argv[kk], "-driver") == 0) {
					strcpy(etel.etel_driver,argv[kk + 1]);
				}
				if (strcmp(argv[kk], "-axis") == 0) {
					if (kkk<ETEL_NAXIS_MAXI) {
						etel.axis[kkk]=AXIS_STATE_TO_BE_OPENED;
						etel.axisno[kkk]=atoi(argv[kk + 1]);
						kkk++;
					}
				}
			}
		}
		/* --- boucle de creation des axes ---*/
		for (k=0;k<ETEL_NAXIS_MAXI;k++) {
			if (etel.axis[k]!=AXIS_STATE_TO_BE_OPENED) {
				continue;
			}
			etel.drv[k]=NULL;
			/* create drive */
			if (err = dsa_create_drive(&etel.drv[k])) {
				etel_error(k,err);
				sprintf(s,"Error axis=%d dsa_create_drive %s",k,etel.msg);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			sprintf(ss,"etb:%s:%d",etel.etel_driver,etel.axisno[k]);
			if (err = dsa_open_u(etel.drv[k],ss)) {
				etel_error(k,err);
				sprintf(s,"Error axis=%d dsa_open_u(%s) %s",etel.axisno[k],ss,etel.msg);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			/* Reset error */
			/*
			if (err = dsa_reset_error_s(etel.drv[k], 1000)) {
				sprintf(s,"Error axis=%d dsa_reset_error_s error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			*/
			/* power on */
			/*
			if (err = dsa_power_on_s(etel.drv[k], 10000)) {
				sprintf(s,"Error axis=%d dsa_power_on_s error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			*/
			etel.axis[k]=AXIS_STATE_OPENED;
		}
		/* initialisation des types de reistres*/
		// int32
		k=0;
		strcpy(typs[k].type_symbol,"X");
		typs[k].typ=DMD_TYP_USER_INT32;
		typs[k].ctype=ETEL_VAL_INT32;
		k++;
		strcpy(typs[k].type_symbol,"K");
		typs[k].typ=DMD_TYP_PPK_INT32;
		typs[k].ctype=ETEL_VAL_INT32;
		k++;
		strcpy(typs[k].type_symbol,"M");
		typs[k].typ=DMD_TYP_MONITOR_INT32;
		typs[k].ctype=ETEL_VAL_INT32;
		k++;
		strcpy(typs[k].type_symbol,"C");
		typs[k].typ=DMD_TYP_COMMON_INT32;
		typs[k].ctype=ETEL_VAL_INT32;
		k++;
		strcpy(typs[k].type_symbol,"P");
		typs[k].typ=DMD_TYP_MAPPING_INT32;
		typs[k].ctype=ETEL_VAL_INT32;
		// Long
		k++;
		strcpy(typs[k].type_symbol,"XL");
		typs[k].typ=DMD_TYP_USER_INT64;
		typs[k].ctype=ETEL_VAL_INT64;
		k++;
		strcpy(typs[k].type_symbol,"KL");
		typs[k].typ=DMD_TYP_PPK_INT64;
		typs[k].ctype=ETEL_VAL_INT64;
		k++;
		strcpy(typs[k].type_symbol,"ML");
		typs[k].typ=DMD_TYP_MONITOR_INT64;
		typs[k].ctype=ETEL_VAL_INT64;
		k++;
		strcpy(typs[k].type_symbol,"CL");
		typs[k].typ=DMD_TYP_COMMON_INT64;
		typs[k].ctype=ETEL_VAL_INT64;
		k++;
		strcpy(typs[k].type_symbol,"EL");
		typs[k].typ=DMD_TYP_TRIGGER_INT64;
		typs[k].ctype=ETEL_VAL_INT64;
		// Float
		k++;
		strcpy(typs[k].type_symbol,"XF");
		typs[k].typ=DMD_TYP_USER_FLOAT32;
		typs[k].ctype=ETEL_VAL_FLOAT32;
		k++;
		strcpy(typs[k].type_symbol,"KF");
		typs[k].typ=DMD_TYP_PPK_FLOAT32;
		typs[k].ctype=ETEL_VAL_FLOAT32;
		k++;
		strcpy(typs[k].type_symbol,"MF");
		typs[k].typ=DMD_TYP_MONITOR_FLOAT32;
		typs[k].ctype=ETEL_VAL_FLOAT32;
		k++;
		strcpy(typs[k].type_symbol,"CF");
		typs[k].typ=DMD_TYP_COMMON_FLOAT32;
		typs[k].ctype=ETEL_VAL_FLOAT32;
		// Double
		k++;
		strcpy(typs[k].type_symbol,"XD");
		typs[k].typ=DMD_TYP_USER_FLOAT64;
		typs[k].ctype=ETEL_VAL_FLOAT64;
		k++;
		strcpy(typs[k].type_symbol,"KD");
		typs[k].typ=DMD_TYP_USER_FLOAT64;
		typs[k].ctype=ETEL_VAL_FLOAT64;
		k++;
		strcpy(typs[k].type_symbol,"MD");
		typs[k].typ=DMD_TYP_USER_FLOAT64;
		typs[k].ctype=ETEL_VAL_FLOAT64;
		k++;
		strcpy(typs[k].type_symbol,"CD");
		typs[k].typ=DMD_TYP_COMMON_FLOAT64;
		typs[k].ctype=ETEL_VAL_FLOAT64;
		k++;
		strcpy(typs[k].type_symbol,"LD");
		typs[k].typ=DMD_TYP_LKT_FLOAT64;
		typs[k].ctype=ETEL_VAL_FLOAT64;
   }
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_eteltcltcl_close(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
	int k,err;
#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_etel.txt","wt");
	fprintf(f,"Close the driver\n");
	fclose(f);
#endif
	for (k=0;k<ETEL_NAXIS_MAXI;k++) {
		if (etel.axis[k]==AXIS_STATE_OPENED) {
			/* power off */
			if (err = dsa_power_off_s(etel.drv[k], 10000)) {
				etel_error(k,err);
				sprintf(s,"Error axis=%d dsa_power_off_s %s",k,etel.msg);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			/* close and destroy */
			if (err = dsa_close(etel.drv[k])) {
				etel_error(k,err);
				sprintf(s,"Error axis=%d dsa_close %s",k,etel.msg);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			if (err = dsa_destroy(&etel.drv[k])) {
				etel_error(k,err);
				sprintf(s,"Error axis=%d dsa_destroy %s",k,etel.msg);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			etel.axis[k]=AXIS_STATE_CLOSED;
		}
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_eteltcltcl_status(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256],s[32767];
   int result = TCL_OK,err=0,k;
	DSA_STATUS sta = {sizeof(DSA_STATUS)};
	/* getting status */
	/* --- boucle sur les axes ---*/
	strcpy(s,"");
	for (k=0;k<ETEL_NAXIS_MAXI;k++) {
		if (etel.axis[k]==AXIS_STATE_OPENED) {
			if (err = dsa_get_status(etel.drv[k], &sta)) {
				etel_error(k,err);
   			sprintf(ligne,"%s",etel.msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
			}
			strcpy(ligne,"{"); strcat(s,ligne);
			sprintf(ligne,"{raw.sw1 %d} ", sta.raw.sw1); strcat(s,ligne);
			sprintf(ligne,"{raw.sw2 %d} ", sta.raw.sw2); strcat(s,ligne);
			sprintf(ligne,"{drive.present %d} ", sta.drive.present); strcat(s,ligne);
			sprintf(ligne,"{drive.moving %d} ", sta.drive.moving); strcat(s,ligne);
			sprintf(ligne,"{drive.in_window %d} ", sta.drive.in_window); strcat(s,ligne);
			sprintf(ligne,"{drive.sequence %d} ", sta.drive.sequence); strcat(s,ligne);
			sprintf(ligne,"{drive.error %d} ", sta.drive.error); strcat(s,ligne);
			sprintf(ligne,"{drive.trace %d} ", sta.drive.trace); strcat(s,ligne);
			sprintf(ligne,"{drive.warning %d} ", sta.drive.warning); strcat(s,ligne);
			sprintf(ligne,"{drive.breakpoint %d} ", sta.drive.breakpoint); strcat(s,ligne);
			sprintf(ligne,"{drive.user %d} ", sta.drive.user); strcat(s,ligne);
			sprintf(ligne,"{dsmax.present %d} ", sta.dsmax.present); strcat(s,ligne);
			sprintf(ligne,"{dsmax.moving %d} ", sta.dsmax.moving); strcat(s,ligne);
			sprintf(ligne,"{dsmax.sequence %d} ", sta.dsmax.sequence); strcat(s,ligne);
			sprintf(ligne,"{dsmax.error %d} ", sta.dsmax.error); strcat(s,ligne);
			sprintf(ligne,"{dsmax.trace %d} ", sta.dsmax.trace); strcat(s,ligne);
			sprintf(ligne,"{dsmax.warning %d} ", sta.dsmax.warning); strcat(s,ligne);
			//sprintf(ligne,"{dsmax.breakpoint %d} ", sta.dsmax.breakpoint); strcat(s,ligne);
			sprintf(ligne,"{dsmax.user %d} ", sta.dsmax.user); strcat(s,ligne);
			strcpy(ligne,"} "); strcat(s,ligne);
		}
	}
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_ExecuteCommandXS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256];
   int result = TCL_OK,err=0;
	DSA_COMMAND_PARAM params[] = { {0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0} };
	int cmd, nparams,k,kk;
   int axisno;
#if defined(MOUCHARD)
	FILE *f;
#endif

   if (argc<3) {
   	sprintf(ligne,"usage: %s axisno cmd nparams ?typ1 conv1 par1? ?type2 conv2 par2? ...",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}

   axisno=atoi(argv[1]);

	if (argc>=3) {
   	cmd=atoi(argv[2]);
	}
	if (argc>=4) {
   	nparams=atoi(argv[3]);
	}
	for (k=4;k<argc-2;k+=3) {
		kk=(k-3)/3;
		if (kk>4) {
			break;
		}
		params[kk].typ=atoi(argv[k]); // =0 in general
		params[kk].conv=atoi(argv[k+1]); // =0 if digital units
		if (params[kk].conv==0) {
		   params[kk].val.i=atoi(argv[k+2]);
		} else {
		   params[kk].val.d=atof(argv[k+2]);
		}
	}
#if defined(MOUCHARD)
   f=fopen("mouchard_etel1.txt","at");
   fprintf(f,"dsa_execute_command_x_s(%d=>axe%d,%d,%d,%d)\n",etel.drv[axisno],axisno,cmd,params[kk].val.i,nparams);
	fclose(f);
#endif
	if (err = dsa_execute_command_x_s(etel.drv[axisno],cmd,params,nparams,FALSE,FALSE,DSA_DEF_TIMEOUT)) {
		etel_error(k,err);
   	sprintf(ligne,"%s",etel.msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_GetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[1024];
   int result = TCL_OK,err=0,axisno,k;
	int typ,idx,sidx=0,ks,ctype;
	long val;
	double vald;
	float valf;
	__int64 vall;
/*
#if defined(MOUCHARD)
	FILE *f;
#endif
*/
   if (argc<4) {
   	sprintf(ligne,"usage: %s axisno typ(",argv[0]);
		for (k=0;k<NB_TYP;k++) {
			if (k>0) {
				strcat(ligne,"|");
			}
			strcat(ligne,typs[k].type_symbol);
		}
   	strcat(ligne,") idx ?sidx?");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[1]);
	ks=etel_symbol2type(argv[2]);
	if (ks==-1) {
   	typ=atoi(argv[2]);
	} else {
		typ=typs[ks].typ;
		ctype=typs[ks].ctype;
	}
	idx=atoi(argv[3]);
	if (argc>=5) {
   	sidx=atoi(argv[4]);
	}
	if (ctype==ETEL_VAL_INT32) {
		err = dsa_get_register_int32_s(etel.drv[axisno],typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT);
	  	sprintf(ligne,"%d",val);
	} else if (ctype==ETEL_VAL_INT64) {
		err = dsa_get_register_int64_s(etel.drv[axisno],typ,idx,sidx,&vall,DSA_GET_CURRENT,DSA_DEF_TIMEOUT);
	  	sprintf(ligne,"%I64i",vall);		
	} else if (ctype==ETEL_VAL_FLOAT32) {
		err = dsa_get_register_float32_s(etel.drv[axisno],typ,idx,sidx,&valf,DSA_GET_CURRENT,DSA_DEF_TIMEOUT);
	  	sprintf(ligne,"%f",valf);
	} else if (ctype==ETEL_VAL_FLOAT64) {
		err = dsa_get_register_float64_s(etel.drv[axisno],typ,idx,sidx,&vald,DSA_GET_CURRENT,DSA_DEF_TIMEOUT);
	  	sprintf(ligne,"%lf",vald);
	}
	if (err!=0) {
		etel_error(axisno,err);
   	sprintf(ligne,"%s",etel.msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	/*
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"dsa_get_register_s(%d=>axe%d,%d,%d,%d) => %s\n",etel.drv[axisno],axisno,typ,idx,sidx,ligne);
	fclose(f);
#endif
	*/
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_SetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[1024];
   int result = TCL_OK,err=0,axisno,k;
	int typ,idx,sidx=0,ks,ctype;
	long val;
	double vald;
	float valf;
	__int64 vall;
#if defined(MOUCHARD)
	FILE *f;
#endif
   if (argc<6) {
   	sprintf(ligne,"usage: %s axisno typ(",argv[0]);
		for (k=0;k<NB_TYP;k++) {
			if (k>0) {
				strcat(ligne,"|");
			}
			strcat(ligne,typs[k].type_symbol);
		}
   	strcat(ligne,") idx sidx val");
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[1]);
	ks=etel_symbol2type(argv[2]);
	if (ks==-1) {
   	typ=atoi(argv[2]);
	} else {
		typ=typs[ks].typ;
		ctype=typs[ks].ctype;
	}
	idx=atoi(argv[3]);
  	sidx=atoi(argv[4]);
	if (ctype==ETEL_VAL_INT32) {
		val=(long)atol(argv[5]);
		err = dsa_set_register_int32_s(etel.drv[axisno],typ,idx,sidx,val,DSA_DEF_TIMEOUT);
	} else if (ctype==ETEL_VAL_INT64) {
		vall = (__int64)atoi64(argv[5],10);
		err = dsa_set_register_int64_s(etel.drv[axisno],typ,idx,sidx,vall,DSA_DEF_TIMEOUT);
	} else if (ctype==ETEL_VAL_FLOAT32) {
		valf=(float)atof(argv[5]);
		err = dsa_set_register_float32_s(etel.drv[axisno],typ,idx,sidx,valf,DSA_DEF_TIMEOUT);
	} else if (ctype==ETEL_VAL_FLOAT64) {
		vald=(double)atof(argv[5]);
		err = dsa_set_register_float64_s(etel.drv[axisno],typ,idx,sidx,vald,DSA_DEF_TIMEOUT);
	}
	if (err!=0) {
		etel_error(axisno,err);
   	sprintf(ligne,"%s",etel.msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"dsa_set_register_s(%d=>axe%d,%d,%d,%d,%d)\n",etel.drv[axisno],axisno,typ,idx,sidx,val);
	fclose(f);
#endif
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_dsa_quick_stop_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
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
   int result = TCL_OK,err=0,axisno;
   if (argc<2) {
   	sprintf(ligne,"usage: %s axisno",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[1]);
	if (err = dsa_quick_stop_s(etel.drv[axisno],DSA_QS_PROGRAMMED_DEC,DSA_QS_BYPASS | DSA_QS_STOP_SEQUENCE, DSA_DEF_TIMEOUT)) {
		etel_error(axisno,err);
   	sprintf(ligne,"%s",etel.msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_open2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[32767],s[256];
   char ss[200];
	int k,kk,kkk,err;
   if(argc<3) {
      sprintf(s,"Usage: %s ?-driver name? ?-axis axisno? ?-axis axisno? ...", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
#if defined(MOUCHARD)
		FILE *f;
		f=fopen("mouchard_etel.txt","wt");
		fprintf(f,"Open the driver\n");
		fclose(f);
#endif
		for (k=0;k<ETEL_NAXIS_MAXI;k++) {
			etel.axis[k]=AXIS_STATE_CLOSED;
			etel.drv[k]=NULL;
		}
		strcpy(etel.etel_driver,"DSTEB3");
		if (argc >= 1) {
			kkk=0;
			for (kk = 0; kk < argc-1; kk++) {
				if (strcmp(argv[kk], "-driver") == 0) {
					strcpy(etel.etel_driver,argv[kk + 1]);
				}
				if (strcmp(argv[kk], "-axis") == 0) {
					if (kkk<ETEL_NAXIS_MAXI) {
						etel.axis[kkk]=AXIS_STATE_TO_BE_OPENED;
						etel.axisno[kkk]=atoi(argv[kk + 1]);
						kkk++;
					}
				}
			}
		}
		strcpy(ligne,"");
		sprintf(s,"{-driver %s} ",etel.etel_driver);
		strcat(ligne,s);
		/* --- AXE 3 = axis_0 Etel */
		k=3;
		etel.axis[k]=AXIS_STATE_TO_BE_OPENED;
		etel.axisno[k]=0;
		/* create drive */
		if (err = dsa_create_drive(&etel.drv[k])) {
			sprintf(s,"Error axis=%d dsa_create_drive error=%d",k,err);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		sprintf(ss,"etb:%s:%d",etel.etel_driver,etel.axisno[k]);
		if (err = dsa_open_u(etel.drv[k],ss)) {
			sprintf(s,"Error axis=%d dsa_open_u(%s) error=%d",etel.axisno[k],ss,err);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		etel.axis[k]=AXIS_STATE_OPENED;
		sprintf(s,"{-axis %d -> etel.axisno %d} ",k,etel.axisno[k]);
		strcat(ligne,s);
		/* --- boucle de creation des axes ---*/
		strcpy(s,"{ ");
		strcat(ligne,s);
		for (k=0;k<ETEL_NAXIS_MAXI;k++) {
			sprintf(s,"{ k=%d etel.axis[%d]=%d ",k,k,etel.axis[k]);
			strcat(ligne,s);
			if (etel.axis[k]==AXIS_STATE_TO_BE_OPENED) {
				etel.drv[k]=NULL;
				strcpy(s,"create ");
				strcat(ligne,s);
				/* create drive */
				if (err = dsa_create_drive(&etel.drv[k])) {
					sprintf(s,"Error axis=%d dsa_create_drive error=%d",k,err);
					strcat(ligne,s);
					sprintf(s,"} }");
					strcat(ligne,s);
					Tcl_SetResult(interp,ligne,TCL_VOLATILE);
					return TCL_ERROR;
				}
				sprintf(s,"err=%d open etb:%s:%d ",err,etel.etel_driver,etel.axisno[k]);
				strcat(ligne,s);
				sprintf(ss,"etb:%s:%d",etel.etel_driver,etel.axisno[k]);
				if (err = dsa_open_u(etel.drv[k],ss)) {
					sprintf(s,"Error axis=%d dsa_open_u(%s) error=%d",etel.axisno[k],ss,err);
					strcat(ligne,s);
					sprintf(s,"} }");
					strcat(ligne,s);
					Tcl_SetResult(interp,ligne,TCL_VOLATILE);
					return TCL_ERROR;
				}
				/* Reset error */
				/*
				if (err = dsa_reset_error_s(etel.drv[k], 1000)) {
					sprintf(s,"Error axis=%d dsa_reset_error_s error=%d",k,err);
					strcat(ligne,s);
					sprintf(s,"} }");
					strcat(ligne,s);
					Tcl_SetResult(interp,ligne,TCL_VOLATILE);
					return TCL_ERROR;
				}
				*/
				/* power on */
				/*
				if (err = dsa_power_on_s(etel.drv[k], 10000)) {
					sprintf(s,"Error axis=%d dsa_power_on_s error=%d",k,err);
					strcat(ligne,s);
					sprintf(s,"} }");
					strcat(ligne,s);
					Tcl_SetResult(interp,ligne,TCL_VOLATILE);
					return TCL_ERROR;
				}
				*/
				etel.axis[k]=AXIS_STATE_OPENED;
				sprintf(s,"err=%d -axis %d -> etel.axisno %d} ",err,k,etel.axisno[k]);
				strcat(ligne,s);
				strcpy(s,"} ");
				strcat(ligne,s);
			} else {
				sprintf(s,"Do_not_connect} ");
				strcat(ligne,s);
				continue;
			}
			strcpy(s,"} ");
			strcat(ligne,s);
		}
   }
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_eteltcltcl_dsa_power_on_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
   if (argc<2) {
   	sprintf(ligne,"usage: %s axisno",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[1]);
	if (err = dsa_power_on_s(etel.drv[axisno], 10000)) {
		sprintf(ligne,"Error axis=%d dsa_power_on_s error=%d",axisno,err);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	sprintf(ligne,"OK axis=%d dsa_power_on_s error=%d",axisno,err);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_dsa_reset_error_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
   if (argc<2) {
   	sprintf(ligne,"usage: %s axisno",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[1]);
	if (err = dsa_reset_error_s(etel.drv[axisno], 10000)) {
		sprintf(ligne,"Error axis=%d dsa_power_on_s error=%d",axisno,err);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	sprintf(ligne,"OK axis=%d dsa_reset_error_s error=%d",axisno,err);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}
