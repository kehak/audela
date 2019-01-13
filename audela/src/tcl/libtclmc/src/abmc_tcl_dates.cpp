// abmc_tcl_dates.cpp : 
// import interface of abmc astrobrick

#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>
#include <stdlib.h> // pour atof atoi
#include <tcl.h>
#include <math.h>

#include "abmc_tcl.h"
#include "abmc_tcl_common.h"
#include <abmc.h>
using namespace abmc;

#define PI 3.1415926535897
#define PISUR2 PI/2
#define DR PI/180

// utilitaires de conversion de variables C en Tcl

// variable locale au fichier

int Cmd_mctcl_date2jd(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
/****************************************************************************/
/* Convertit une date en jour julien				  			                   */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* jd																		                   */
/****************************************************************************/
   int result;
   char s[100];
   double jj=0.;

   abmc::IMc* mc = getInstance(clientData);

   if(argc!=3) {
      sprintf(s,"Usage: %s %s Date", argv[0], argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		/* --- decode la date ---*/
		result = mc->date2jd(argv[2],&jj);
      sprintf(s,"%.10f",jj);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2iso8601(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
/****************************************************************************/
/* Convertit une date en calendrier gregorienne 				  			       */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* ISO8601																		             */
/****************************************************************************/
   int result;
   char s[100];

   abmc::IMc* mc = getInstance(clientData);

   if(argc!=2) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		/* --- decode la date ---*/
		char date_iso8601[30];
		result = mc->date2iso8601(argv[1],date_iso8601);
      Tcl_SetResult(interp,date_iso8601,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2ymdhms(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
/****************************************************************************/
/* Convertit une date en calendrier gregorienne 				  			       */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* YMDhms																		             */
/****************************************************************************/
   int result;
   char s[200];

   abmc::IMc* mc = getInstance(clientData);

   if(argc!=2) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		/* --- decode la date ---*/
		int y,m,d,hh,mm;
		double ss;
		result = mc->date2ymdhms(argv[1],&y,&m,&d,&hh,&mm,&ss);
		sprintf(s,"%d %d %d %d %d %f",y,m,d,hh,mm,ss);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2tt(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
/****************************************************************************/
/* Convertit une date en jour julien TT			  			                   */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* jd																		                   */
/****************************************************************************/
   int result;
   char s[100];
   double jj=0.;

   abmc::IMc* mc = getInstance(clientData);

   if(argc!=2) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		/* --- decode la date ---*/
		result = mc->date2tt(argv[1],&jj);
      sprintf(s,"%.10f",jj);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2equinox(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
/****************************************************************************/
/* Convertit une date en annee julienne ou besselienne 				  			 */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* ISO8601																		             */
/****************************************************************************/
   int result;
   char s[100];

   abmc::IMc* mc = getInstance(clientData);

   if(argc<=2) {
      sprintf(s,"Usage: %s Date ?J|B? ?year_subdigits?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		// --- get the date
		char date_equ[30];
		// --- get the year type
      YearType year_type= YearType::AUTO;
		if (argc>=3) {
			if (strcmp(argv[2],"J")==0) {
				year_type=YearType::JULIAN;
			}
			if (strcmp(argv[2],"B")==0) {
				year_type=YearType::BESSELIAN;
			}
		}
		// --- get the number of subdigits
		int nb_subdigit=1;
		if (argc>=4) {
			nb_subdigit=(int)fabs((double)atoi(argv[3]));
		}
		//
		result = mc->date2equinox(argv[1],year_type,nb_subdigit,date_equ);
      Tcl_SetResult(interp,date_equ,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}


int Cmd_mctcl_date2lst(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]) {
/****************************************************************************/
/* Convertit une date en annee julienne ou besselienne 				  			 */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* ISO8601																		             */
/****************************************************************************/
   int result;
   char s[100];
   
   abmc::IMc* mc = getInstance(clientData);

   if(argc<=2) {
      sprintf(s,"Usage: %s Date_UTC Home_cep ?-ut1-utc UT1-UTC(sec)? ?-nutation 1|0? ?-format hms|deg?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      
 		const char * date_utc = argv[1];
      const char *home =argv[2];
      double xp_arcsec = 0;
      double yp_arcsec = 0;
      double lst;

      int type_format=0;
      double ut1_utc=0; 

      for (int ko=3; ko<argc-1; ko++) {
         //    strcpy(s,argv[ko]);
         //  mc_strupr(s,s);
         //    if (strcmp(s,"-NUTATION")==0) {
         //   do_nutation=(int)atoi(argv[ko+1]);
         //}
	      if (strcmp(s,"-FORMAT")==0) {
				strcpy(s,argv[ko+1]);
				mc_strupr(s,s);
				if (strcmp(s,"HMS")==0) { 
               type_format=0; 
            } else if (strcmp(s,"DEG")==0) {
               type_format=1; 
            }
         }
			/*
	      if (strcmp(s,"-TAI-UTC")==0) {
			   tai_utc=atof(argv[ko+1])/86400.;
			}
			*/
	      if (strcmp(s,"-UT1-UTC")==0) {
            ut1_utc=copyArgvToDouble(interp,argv[ko+1],"UT1-UTC");
				if (ut1_utc>1)  { ut1_utc = 1.; }
				if (ut1_utc<-1) { ut1_utc = -1.; }
				ut1_utc/=86400;
			}
		}

      result = mc->date2lst(date_utc, ut1_utc, home, xp_arcsec, yp_arcsec, &lst); 
		
		// --- formatage de sortie ---
		if (type_format==0) {
         int hhh; 
         int mmm;
         double ss;
			// --- conversion radian vers hms ---
			mc_deg2h_m_s((lst/(DR)),&hhh,&mmm,&ss);
	      sprintf(s,"%d %d %f",hhh,mmm,ss);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_OK;
		} else {
			lst/=(DR);
			lst=fmod(720.+lst,360);
	      sprintf(s,"%.7f",lst);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_OK;
		}
   }
   return result;
}
