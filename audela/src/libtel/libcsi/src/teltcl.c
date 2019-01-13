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

/*
 *   structure pour les fonctions étendues
 */


/*
 *   Envoie une commande
 */
int cmdTelPut(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s command",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=csi_put(tel,argv[2]);
      if (res==1) {
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,"",TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Lit une reponse
 */
int cmdTelRead(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   res=csi_read(tel,ligne);
   if (res==1) {
      result = TCL_ERROR;
   } else {
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   }
   return result;
}

/*
 *   Envoie une commande et retourne la reponse
 */
int cmdTelPutread(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048],s[1024];
   int result = TCL_OK,res;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
      sprintf(ligne,"Usage: %s %s command",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=csi_put(tel,argv[2]);
      sprintf(s,"after %d",tel->tempo); mytel_tcleval(tel,s);
      res=csi_read(tel,ligne);
      if (res==1) {
         Tcl_SetResult(interp,"connection problem",TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      }
   }
   return result;
}

/*
 *   Envoie une Init
 */
int cmdTelInit(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[4096];
   char ligne2[2048];
   int result = TCL_OK,res;//,res2;
   //double ha,dec,lst,sec;
   //int h,m;

   struct telprop *tel;
   int axe_min=0,axe_max=3;
   tel = (struct telprop *)clientData;
   tel->ra_maxvel = 93157;
   tel->dec_maxvel = 93157;
   tel->foc_maxvel = 3000;
   tel->dome_maxvel = 100000;

   if (argc<3) {
      sprintf(ligne,"Usage: %s %s AxeNo",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      res=atoi(argv[2]);
      if ((res<axe_min)||(res>axe_max)) { 
         sprintf(ligne,"AxeNo must be between %d and %d",axe_min,axe_max);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
	  /* Original code by AK :	
	  if (res==0) {
			// We are homing the dome
			sprintf(ligne,"!%d; ",res);
			strcat(ligne,"\\\$4 = clock + 50000;"); // timeout
			strcat(ligne,"homebit=0x1; ");
			strcat(ligne,"=iedge=homebit; ");
			res2=csi_put(tel,ligne);
			sprintf(ligne,"!%d; ",res);
			strcat(ligne,"=mtvel=");
			sprintf(ligne2,"%d",tel->dome_maxvel);
			strcat(ligne,ligne2);
			strcat(ligne,";");
			res2=csi_put(tel,ligne);
			sprintf(ligne,"!%d; ",res);
			strcat(ligne,"while (\\\$4 > clock) if ((iedge | ilevel) & homebit) break;; ");
			strcat(ligne,"=mtvel=0;");
			//res2=csi_put(tel,ligne);
			strcat(ligne,"pause(500); ");
			strcat(ligne,"=mtvel = -");
			sprintf(ligne2,"%d",tel->dome_maxvel/4);
			strcat(ligne,ligne2);
			strcat(ligne,"; ");
			res2=csi_put(tel,ligne);
			sprintf(ligne,"!%d; while (\\\$4 > clock) if ((iedge | ilevel) & homebit) break;; ", res); 
			strcat(ligne,"mtvel=0; =mpos=0;");
	  }
	  else if (res==1) {
			// We are homing the RA
			sprintf(ligne,"!%d; ",res);
			strcat(ligne,"");
			strcat(ligne,"maxvel=");
			sprintf(ligne2,"%d",tel->ra_maxvel);
			strcat(ligne,ligne2);
			strcat(ligne,"; ");
			strcat(ligne,"\\\$2=0;");
			strcat(ligne,"\\\$4 = clock + 50000;"); // timeout
			strcat(ligne,"iedge=homebit;");
			strcat(ligne,"etvel=1*maxvel;");
			strcat(ligne,"while(!(iedge & homebit) && (\\\$4 > clock));");
			//strcat(ligne,"while ( ((ilevel & plimbit)==0) && ((iedge & homebit)!=0) && (clock<\\\$4) );");
			strcat(ligne,"=printf(\\\"%%d %%d reste %%d\n\\\",ilevel,iedge,\\\$4-clock);");
			strcat(ligne,"etvel = 0;");
			strcat(ligne,"pause(500);");
			strcat(ligne,"if (clock<\\\$4) {");
			strcat(ligne," \\\$1=1;");
			strcat(ligne,"	while ( 1==1 ) {");
			strcat(ligne,"    etpos=epos+50000/\\\$1;"); // go back a few
			strcat(ligne,"    while(working);");
			strcat(ligne,"    pause(500);");
			strcat(ligne,"		iedge=homebit;");
			strcat(ligne,"		etvel=-1*maxvel/\\\$1;"); // slew to the home
			strcat(ligne,"		if (etvel==0) { break; };");
			strcat(ligne,"		while( (iedge & homebit)==0 );");
			strcat(ligne,"    \\\$1=\\\$1*10;"); // divisor for the next iteration
			strcat(ligne,"	};");
			strcat(ligne,"	mpos=0;");
			strcat(ligne,"	epos=0;");
			//strcat(ligne," \\\$3=epos;");
			//strcat(ligne," etpos=epos-200000;"); // final go back (optional)
			//strcat(ligne," while(working);");
			//strcat(ligne,"} else {");
			//strcat(ligne," \\\$3=epos;");
			//strcat(ligne,"};");
			strcat(ligne,"=epos;");
			
		}
		else if (res==2) {
			sprintf(ligne,"!%d; ",res);
			strcat(ligne,"");
			strcat(ligne,"maxvel=");
			sprintf(ligne2,"%d",tel->dec_maxvel);
			strcat(ligne,ligne2);
			strcat(ligne,"; ");
			strcat(ligne,"\\\$2=0;");
			strcat(ligne,"\\\$3 = clock;");
			strcat(ligne,"\\\$4 = \\\$3 + 40000;"); // timeout
			strcat(ligne,"iedge=homebit;");
			strcat(ligne,"etvel=-1*maxvel;");
			strcat(ligne,"while ( ((ilevel & nlimbit)==0) && ((iedge & homebit)==0) && (clock<\\\$4) );");
			strcat(ligne,"pause(500);");
			strcat(ligne,"if (clock<\\\$4) {");
			strcat(ligne," \\\$1=1;");
			strcat(ligne,"	while ( 1==1 ) {");
			strcat(ligne,"    etpos=epos-50000/\\\$1;"); // go back a few
			strcat(ligne,"    while(working);");
			strcat(ligne,"    pause(500);");
			strcat(ligne,"		iedge=homebit;");
			strcat(ligne,"		etvel=1*maxvel/\\\$1;"); // slew to the home
			strcat(ligne,"		if (etvel==0) { break; };");
			strcat(ligne,"		while( (iedge & homebit)==0 );");
			strcat(ligne,"    \\\$1=\\\$1*10;"); // divisor for the next interation
			strcat(ligne,"	};");
			strcat(ligne,"	mpos=0;");
			strcat(ligne,"	epos=0;");
			//strcat(ligne," etpos=epos+200000;"); // final go back (optional)
			//strcat(ligne," while(working);");
			strcat(ligne,"};");
			strcat(ligne,"=epos;");

		}
		else if (res==3) {
			sprintf(ligne,"!%d; ",res);
			strcat(ligne,"");
			strcat(ligne,"maxvel=");
			sprintf(ligne2,"%d",tel->foc_maxvel);
			strcat(ligne,ligne2);
			strcat(ligne,"; ");
			strcat(ligne,"\\\$4=45000;");
			strcat(ligne,"\\\$2=0;");
			strcat(ligne,"\\\$3 = clock;");
			strcat(ligne,"etvel=-1*maxvel;");
			strcat(ligne,"while (ilevel!=nlimbit) {");
			strcat(ligne,"	if ((clock-\\\$3)>\\\$4) {");
			strcat(ligne,"		\\\$2=\\\$2+1;");
			strcat(ligne,"		break;");
			strcat(ligne,"	};");
			strcat(ligne,"};");
			strcat(ligne,"if {\\\$2==0) {");
			strcat(ligne," mpos=0;");
			strcat(ligne," mtpos=3000;");
			strcat(ligne," while(working);");
			strcat(ligne," \\\$4=45000;");
			strcat(ligne," \\\$3 = clock;");
			strcat(ligne," while (ilevel!=nlimbit) {");
			strcat(ligne,"	 if ((clock-\\\$3)>\\\$4) {");
			strcat(ligne,"	 	\\\$2=\\\$2+1;");
			strcat(ligne,"	 	break;");
			strcat(ligne,"	 };");
			strcat(ligne," };");
			strcat(ligne," stop();");
			strcat(ligne," if {\\\$2==0) {");
			strcat(ligne,"  mpos=0;");
			strcat(ligne," };");
			strcat(ligne,"};");
		} */
       
        /* Code by BG */


if (res==0) {
			// We are homing the dome
			sprintf(ligne,"!%d; HomeRodger(%d);",res, 1);
	  }
	  else if (res==1) {
			// We are homing the DEC, because we need to put it to the horizon for RA
			sprintf(ligne,"!%d; decfindhome();",2);
			if (strcmp(ligne,"")!=0) {
				res=csi_put(tel,ligne);
				if (res==1) {
					result = TCL_ERROR;
					Tcl_SetResult(interp,"Connection problem",TCL_VOLATILE);
					return result;
				} 
				strcpy(ligne,"");
				while (!strcmp(ligne,"")) {
					sprintf(ligne2,"after %d",tel->tempo); mytel_tcleval(tel,ligne2);
					res=csi_read(tel,ligne);
				}
				if (res==1) {
					result = TCL_ERROR;
					Tcl_SetResult(interp,"Connection problem for reading",TCL_VOLATILE);
					return result;
				}
			}
			sprintf(ligne2,"after %d",tel->tempo); mytel_tcleval(tel,ligne2);
			sprintf(ligne,"!%d; moveto(2300000);",2);
		}
		else if (res==2) {
			// We are homing the RA
			sprintf(ligne,"!%d; rafindhome();",1);
		}
		else if (res==3) {
			// We are homing the Focus
			sprintf(ligne,"!%d; focreset();",res);
		}    

	/*	End Code by BG */
		if (strcmp(ligne,"")!=0) {
			res=csi_put(tel,ligne);
			if (res==1) {
				result = TCL_ERROR;
				Tcl_SetResult(interp,"Connection problem",TCL_VOLATILE);
				return result;
			} 
			strcpy(ligne,"");
			while (!strcmp(ligne,"")) {
				sprintf(ligne2,"after %d",tel->tempo); mytel_tcleval(tel,ligne2);
				res=csi_read(tel,ligne);
			}
			if (res==1) {
				result = TCL_ERROR;
				Tcl_SetResult(interp,"Connection problem",TCL_VOLATILE);
				return result;
			}
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);	
		}
   }
   return result;
}

/*
 *   Points zero des coordonnes
 */
int cmdTelRot0(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc>3) {
		tel->roth00=(int)atoi(argv[2]);
		tel->rotd00=(int)atoi(argv[3]);
   }
	sprintf(ligne,"%d %d",tel->roth00,tel->rotd00);
	Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	result = TCL_OK;
	return result;
}

/*
 *   Retourne les positions des axes
 */
int cmdTelPosition(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK,res;
   struct telprop *tel;
   /*int axe_min=1,axe_max=4;*/
   char s[1024],ss[1024],axe;
   double ha,lst,sec,ra,dec;
   int h,m;
   Tcl_DString dsptr;
   double roth_uc,rotd_uc;

   tel = (struct telprop *)clientData;
   if (argc<2) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   Tcl_DStringInit(&dsptr);
   /* --- Vide le buffer --- */
   //res=csi_read(tel,s);
   /* --- Lecture AXE 1 (horaire) --- */
   axe='1';
   sprintf(ss,"!%c; =mpos;",axe);
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
   sprintf(ligne,"{position_1 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_1 %f degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_1 %d ADU} ",tel->roth00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_1 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{hour_angle_match %f degrees} ",tel->ha00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      roth_uc=atof(s);
      ha=tel->ha00+1.*(roth_uc-tel->roth00)/tel->radec_position_conversion;
      ha=fmod(ha+720,360.);
      sprintf(ligne,"{hour_angle %.5f degrees} ",ha);
      Tcl_DStringAppend(&dsptr,ligne,-1);
      lst=csi_tsl(tel,&h,&m,&sec,0);
      sprintf(ligne,"{local_sideral_time %.5f degrees} ",lst);
      Tcl_DStringAppend(&dsptr,ligne,-1);
      ra=lst-ha+360*5;
      ra=fmod(ra,360.);
      sprintf(ligne,"{ra %.5f degrees} ",ra);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   sprintf(ss,"#%cv",axe);
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
   sprintf(ligne,"{speed_1 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{speed_deg_1 %e ADU/s} ",atof(s)/tel->radec_speed_ra_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- Lecture AXE 2 (delta) --- */
   axe='2';
   sprintf(ss,"!%c; =mpos;",axe);
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
   sprintf(ligne,"{position_2 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_2 %f degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_2 %d ADU} ",tel->rotd00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_2 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{dec_match %f degrees} ",tel->dec00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      rotd_uc=atof(s);
      dec=tel->dec00-1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      sprintf(ligne,"{dec %.5f degrees} ",dec);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   sprintf(ss,"#%cv",axe);
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
   sprintf(ligne,"{speed_2 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{speed_deg_2 %e ADU/s} ",atof(s)/tel->radec_speed_dec_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- Lecture AXE 3 (focus) --- */
   axe='3';
   sprintf(ss,"!%c; =mpos;",axe);
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
   sprintf(ligne,"{position_3 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{position_deg_3 %s degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_3 %d ADU} ",tel->rotd00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_3 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{dec_match_3 %f degrees} ",tel->dec00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      rotd_uc=atof(s);
      dec=tel->dec00+1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      sprintf(ligne,"{dec %.5f degrees} ",dec);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   */
   sprintf(ss,"#%cv",axe);
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
   sprintf(ligne,"{speed_3 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{speed_deg_3 %e ADU/s} ",atof(s)tel->radec_speed_dec_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   */
   /* --- Lecture AXE 0 (dome) --- */
   axe='0';
   sprintf(ss,"!%c; =mpos;",axe);
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
   sprintf(ligne,"{position_0 %s ADU} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{position_deg_4 %s degrees} ",1.*atof(s)/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_match_4 %d ADU} ",tel->rotd00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{position_deg_match_4 %f degrees} ",1.*tel->roth00/tel->radec_position_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   sprintf(ligne,"{dec_match_4 %f degrees} ",tel->dec00);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   if (res==0) {
      rotd_uc=atof(s);
      dec=tel->dec00+1.*(rotd_uc-tel->rotd00)/tel->radec_position_conversion;
      sprintf(ligne,"{dec %.5f degrees} ",dec);
      Tcl_DStringAppend(&dsptr,ligne,-1);
   }
   */
   sprintf(ss,"#%cv",axe);
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
   sprintf(ligne,"{speed_0 %s ADU/s} ",s);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /*
   sprintf(ligne,"{speed_deg_4 %e ADU/s} ",atof(s)tel->radec_speed_dec_conversion);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   */
   /* --- --- */
   Tcl_DStringResult(tel->interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   return result;
}

/*
 *   Valeurs des vitesses de pointage (deg/s)
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
      if (value<-100.) { value=-100.; }
      if (value>100.)  { value=100.; }
      tel->speed_slew_ra=value;
      value=atof(argv[3]);
      if (value<-100.) { value=-100.; }
      if (value>100.)  { value=100.; }
      tel->speed_slew_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_slew_ra,tel->speed_slew_dec);
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
      if (value<-5.) { value=-5.; }
      if (value>5.)  { value=5.; }
      tel->speed_track_ra=value;
      value=atof(argv[3]);
      if (value<-5.) { value=-5.; }
      if (value>5.)  { value=5.; }
      tel->speed_track_dec=value;
   }
   sprintf(ligne,"%f %f",tel->speed_track_ra,tel->speed_track_dec);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

/*
 *   Retourne le temps sideral actuel
 */
int cmdTelLst(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2048];
   int result = TCL_OK;
   struct telprop *tel;
   double lst,sec;
   int h,m;
   Tcl_DString dsptr;

   tel = (struct telprop *)clientData;
   if (argc<2) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
      return result;
   }
   Tcl_DStringInit(&dsptr);
   /* --- Lecture AXE 1 (horaire) --- */
   lst=csi_tsl(tel,&h,&m,&sec,0);
   sprintf(ligne,"%.5f",lst);
   Tcl_DStringAppend(&dsptr,ligne,-1);
   /* --- --- */
   Tcl_DStringResult(tel->interp,&dsptr);
   Tcl_DStringFree(&dsptr);
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
            //mytel_hadec_init(tel);
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
 *   tolerence de position lors d'un GOTO bloquant
 */
int cmdTelTolPos(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
	//int p1=0,p2=0;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {   
      tel->radec_tol=atof(argv[2]);
   }
   sprintf(s,"%f",tel->radec_tol);
	/*
	csi_positions12(tel,&p1,&p2);
   sprintf(s,"%d %d",p1,p2);
	*/
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
}

/*
 *   flag de simultaneite des mouvements lors d'un GOTO
 */
int cmdTelSimultaneus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024];
   struct telprop *tel;
   tel = (struct telprop *)clientData;   
   if (argc>=3) {   
      tel->simultaneus=atoi(argv[2]);
   }
   sprintf(s,"%d",tel->simultaneus);
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_OK;
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

int cmdTelDome(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc!=3) {
      sprintf(ligne,"Usage: %s %s open|close|enable|disable",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (!strcmp(argv[2],"open")) {
	    csi_dome_open(tel);
	    Tcl_SetResult(interp,"Open",TCL_VOLATILE);
		return TCL_OK;
   }
   if (!strcmp(argv[2],"close")) {
		csi_dome_close(tel);
		Tcl_SetResult(interp,"Close",TCL_VOLATILE);
		return TCL_OK;
   }
   if (!strcmp(argv[2],"enable")) {
      csi_dome_enable(tel);
		Tcl_SetResult(interp,"Dome Enabled",TCL_VOLATILE);
		return TCL_OK;
   }
   if (!strcmp(argv[2],"disable")) {
      csi_dome_disable(tel);
		Tcl_SetResult(interp,"Dome Disabled",TCL_VOLATILE);
		return TCL_OK;
   }
   return TCL_ERROR;
}


int cmdTelRotate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],s[256];
   int res,pos=0;
   double az=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   strcpy(s,"");
   if (argc>3) {
      sprintf(ligne,"Usage: %s %s azimuth",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      csi_dome_get_azimuth(tel,&az,&pos);
      if (argc>2) {
         tel->ra0=atof(argv[2]);
         csi_dome_rotate(tel);
         Tcl_SetResult(interp,"Moving",TCL_VOLATILE);
      }
      sprintf(s,"%f %d",az,pos);
   }
   Tcl_SetResult(interp,s,TCL_VOLATILE);   
   return TCL_OK;
   
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
                sprintf(ligne,"Usage: %s %s dec|ha ?ADU0 Ang0?",argv[0],argv[1]);
                Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                result = TCL_ERROR;
                return result;
        }
        if (strcmp(argv[2],"dec")==0) {
                if (argc>=5) {
                        tel->rotd00=atoi(argv[3]);
                        tel->dec00=atof(argv[4]);
                }
               sprintf(ligne,"%d %f",tel->rotd00,tel->dec00);
        } else if (strcmp(argv[2],"ha")==0) {
                if (argc>=5) {
                        tel->roth00=atoi(argv[3]);
                        tel->ha00=atof(argv[4]);
                }
                sprintf(ligne,"%d %f",tel->roth00,tel->ha00);
        } else if (strcmp(argv[2],"c")==0) {
                sprintf(ligne,"tel->rotd00=%d tel->dec00=%f tel->roth00=%d tel->ha00=%f",tel->rotd00,tel->dec00,tel->roth00,tel->ha00);
                Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                return result;
        } else if (strcmp(argv[2],"tcl")==0) {
                sprintf(ligne,"tel1 pos0 dec %d %f ; tel1 pos0 ha %d %f",tel->rotd00,tel->dec00,tel->roth00,tel->ha00);
                Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                return result;
        } else {
                sprintf(ligne,"Usage: %s %s dec|ha ?ADU0 Ang0?",argv[0],argv[1]);
                Tcl_SetResult(interp,ligne,TCL_VOLATILE);
                result = TCL_ERROR;
                return result;
        }
        Tcl_SetResult(interp,ligne,TCL_VOLATILE);
        return result;
}

int cmdTelSecurity(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],s[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   strcpy(s,"");
   if (argc>3) {
      sprintf(ligne,"Usage: %s %s 1|0",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      if (argc>2) {
         tel->security=atoi(argv[2]);
      }
      sprintf(s,"%d",tel->security);
   }
   Tcl_SetResult(interp,s,TCL_VOLATILE);   
   return TCL_OK;
   
}

/*
 * This function will read the values of the encoders 
 */
int cmdTelEncoders(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[256], texte[256], ligne[256];
	char c;
	struct telprop *tel;
	tel = (struct telprop *)clientData;
   	strcpy(s,"");
	// Extraction of the kind of encoder to be read
   	if (argc<3) {
      		sprintf(ligne,"Usage: %s %s e|m",argv[0],argv[1]);
      		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      		return TCL_ERROR;
   	} else {
      		if (argc>2) {
      		   	strcpy(s,argv[2]);
			c = s[0];
      		}
   	}
	// Reading of the encoders
	if (c == 'e') {
	// encoders
	mytel_encoder_coord(tel, texte);
	} else {
	// motors
	mytel_motor_coord(tel, texte);
	};
	// Packing of the results
	strcpy(s, texte);
   	Tcl_SetResult(interp,s,TCL_VOLATILE);
   	return TCL_OK;

}

int cmdTelTrackingDuration(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],s[256];
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   strcpy(s,"");
   if (argc>3) {
      sprintf(ligne,"Usage: %s %s sec",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      if (argc>2) {
         tel->trackingduration=atof(argv[2]);
      }
      sprintf(s,"%f",tel->trackingduration);
   }
   Tcl_SetResult(interp,s,TCL_VOLATILE);   
   return TCL_OK;
   
}
