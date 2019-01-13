// abmc_tcl_obsoletes.cpp : 
// import interface of abmc astrobrick

#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>
#include <cstdlib> // pour atof atoi
#include <math.h>
#include <tcl.h>

#include <abmc.h>
#include "abmc_tcl_common.h"

#define PI 3.1415926535897
#define PISUR2 PI/2
#define DR PI/180

// utilitaires de conversion de variables C en Tcl

// variable locale au fichier

int Cmd_mctcl_angle2dms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en dms                                           */
/****************************************************************************/
/* mc_angle2dms                                                             */
/*  Angle ?limit? ?nozero|zero? ?subsecdigits? ?auto|+? ?list|string?       */
/****************************************************************************/
{
   char s[524];
   int result,format;
   double angle,limit=360.;
	int subsecdigits=2,zero=0,plus=0;

   abmc::IMc* mc = getInstance(clientData);

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle ?limit? ?nozero|zero? ?subsecdigits? ?auto|+? ?list|string?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		/* --- decode l'angle ---*/
		mc->angle2deg(argv[1],&angle);
      angle=fmod(angle,360.);
      angle=fmod(angle+360.,360.);
		/* --- limit ---*/
      if (argc>=3) {
		   strcpy(s,argv[2]);
		   mc_strupr(s,s);
         if ((s[0]=='D')) {
		      limit=90.;
         } else {
            limit=atof(s);
			}
			if ((limit>0.)&&(limit<=180.)) {
			   if ((angle>limit)&&(angle<=180.)) { angle=limit; }
			   if ((angle>180)&&(angle<(360.-limit))) { angle=-limit; }
			   if ((angle>=(360.-limit))) { angle-=360.; }
			} else {
				limit=360.;
			}
      }
		/* --- nozero|zero ---*/
      if (argc>=4) {
		   strcpy(s,argv[3]);
		   mc_strupr(s,s);
         if (strcmp(s,"ZERO")==0) {
				zero=1;
			}
		}
		/* --- subsecdigits ---*/
      if (argc>=5) {
			subsecdigits=(int)atoi(argv[4]);
		}
		/* --- auto|+ ---*/
      if (argc>=6) {
		   strcpy(s,argv[5]);
		   mc_strupr(s,s);
         if (strcmp(s,"+")==0) {
				plus=1;
			}
		}
		/* --- output format ---*/
		format=0;
      if (argc>=7) {
		   strcpy(s,argv[6]);
		   mc_strupr(s,s);
			if (strcmp(s,"STRING")==0) {
				format=1;
			}
		}
		/* --- Prepare the format abmc ---*/
		char string_format[50];
		strcpy(string_format,"");
		if (limit==360) {
			strcat(string_format,"D");
		} else {
			strcat(string_format,"d");
		}
		if (format==0) {
			strcat(string_format," ");
		}
		if (plus==1) {
			strcat(string_format,"+");
		}
		if (zero==1) {
			strcat(string_format,"0");
		}
		if (subsecdigits>0) {
			strcat(string_format,".");
			if (subsecdigits>9) {
				subsecdigits=9;
			}
			sprintf(s,"%d",subsecdigits);
			strcat(string_format,s);
		}
		/* --- mise en forme ---*/
		char string_sexagesimal[50];
		double deg;
		mc->angle2deg(argv[1],&deg);
		mc->angle2sexagesimal(deg,string_format,string_sexagesimal);
      Tcl_SetResult(interp,string_sexagesimal,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angle2hms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en hms                                           */
/****************************************************************************/
/* mc_angle2dms                                                             */
/*  Angle ?limit? ?nozero|zero? ?subsecdigits? ?auto|+? ?list|string?       */
/****************************************************************************/
{
   char s[524];
   int result,format;
   double angle,limit=360.;
	int subsecdigits=2,zero=0,plus=0;
   abmc::IMc* mc = getInstance(clientData);

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle ?limit? ?nozero|zero? ?subsecdigits? ?auto|+? ?list|string?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		/* --- decode l'angle ---*/
		mc->angle2deg(argv[1],&angle);
      angle=fmod(angle,360.);
      angle=fmod(angle+360.,360.);
		/* --- limit ---*/
      if (argc>=3) {
		   strcpy(s,argv[2]);
		   mc_strupr(s,s);
         if ((s[0]=='D')) {
		      limit=90.;
         } else {
            limit=atof(s);
			}
			if ((limit>0.)&&(limit<=180.)) {
			   if ((angle>limit)&&(angle<=180.)) { angle=limit; }
			   if ((angle>180)&&(angle<(360.-limit))) { angle=-limit; }
			   if ((angle>=(360.-limit))) { angle-=360.; }
			} else {
				limit=360.;
			}
      }
		/* --- nozero|zero ---*/
      if (argc>=4) {
		   strcpy(s,argv[3]);
		   mc_strupr(s,s);
         if (strcmp(s,"ZERO")==0) {
				zero=1;
			}
		}
		/* --- subsecdigits ---*/
      if (argc>=5) {
			subsecdigits=(int)atoi(argv[4]);
		}
		/* --- auto|+ ---*/
      if (argc>=6) {
		   strcpy(s,argv[5]);
		   mc_strupr(s,s);
         if (strcmp(s,"+")==0) {
				plus=1;
			}
		}
		/* --- output format ---*/
		format=0;
      if (argc>=7) {
		   strcpy(s,argv[6]);
		   mc_strupr(s,s);
			if (strcmp(s,"STRING")==0) {
				format=1;
			}
		}
		/* --- Prepare the format abmc ---*/
		char string_format[50];
		strcpy(string_format,"");
		if (limit==360) {
			strcat(string_format,"H");
		} else {
			strcat(string_format,"h");
		}
		if (format==0) {
			strcat(string_format," ");
		}
		if (plus==1) {
			strcat(string_format,"+");
		}
		if (zero==1) {
			strcat(string_format,"0");
		}
		if (subsecdigits>0) {
			strcat(string_format,".");
			if (subsecdigits>9) {
				subsecdigits=9;
			}
			sprintf(s,"%d",subsecdigits);
			strcat(string_format,s);
		}
		/* --- mise en forme ---*/
		char string_sexagesimal[50];
		double deg;
		mc->angle2deg(argv[1],&deg);
		mc->angle2sexagesimal(deg,string_format,string_sexagesimal);
      Tcl_SetResult(interp,string_sexagesimal,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_anglesep(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul l'angle de separation entre deux coordonnees.                     */
/****************************************************************************/
/* mc_anglesep                                                              */
/*  Listangles ?Units?                                                      */
/*                                                                          */
/* Si Units=D alors les entrees et les sorties sont en degres.              */
/* Si Units=R alors les entrees et les sorties sont en radians.             */
/****************************************************************************/
{
   char s[524],ss[100];
   int result,argcc;
   const char **argvv=NULL;
   double dist,posangle;
   abmc::IMc* mc = getInstance(clientData);

   if(argc<=1) {
      sprintf(s,"Usage: %s ListAngles", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
      Tcl_SplitList(interp,argv[1],&argcc,&argvv);
		mc->coordinates_separation(argvv[0],argvv[1],argvv[2],argvv[3],&dist,&posangle);
		strcpy(s,"");
		sprintf(ss,"%s ",mc_d2s(dist)); strcat(s,ss);
		sprintf(ss,"%s",mc_d2s(posangle)); strcat(s,ss);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result=TCL_OK;
   }
   if (argvv!=NULL) { Tcl_Free((char *) argvv); }
   return result;
}

int Cmd_mctcl_sepangle(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul l'angle de separation entre deux coordonnees.                     */
/****************************************************************************/
/* mc_sepangle                                                              */
/*  Ra1 Dec1 Ra2 Dec2 ?Units?                                               */
/*                                                                          */
/* Si Units=D alors les entrees et les sorties sont en degres.              */
/****************************************************************************/
{
   char s[524],ss[100];
   int result;
   double dist,posangle;
   abmc::IMc* mc = getInstance(clientData);

   if(argc<=4) {
      sprintf(s,"Usage: %s Ra1 Dec1 Ra2 Dec2", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
		mc->coordinates_separation(argv[1],argv[2],argv[3],argv[4],&dist,&posangle);
		strcpy(s,"");
		sprintf(ss,"%s ",mc_d2s(dist)); strcat(s,ss);
		sprintf(ss,"%s",mc_d2s(posangle)); strcat(s,ss);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		result=TCL_OK;
   }
   return result;
}
