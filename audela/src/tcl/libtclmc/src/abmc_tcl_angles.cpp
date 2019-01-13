// abmc_tcl_angles.cpp : 
// import interface of abmc astrobrick

#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>
#include <tcl.h>
#include <math.h>

#include <abmc.h>
#include "abmc_tcl_common.h"

#define PI 3.1415926535897
#define PISUR2 PI/2
#define DR PI/180

// utilitaires de conversion de variables C en Tcl

// variable locale au fichier

int Cmd_mctcl_angle2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en degres                                        */
/****************************************************************************/
/* mc_angle2deg                                                             */
/*  Angle                                                                   */
/****************************************************************************/
{
   char s[524];
   int result;
   double angle;

   abmc::IMc* mc = getInstance(clientData);

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode l'angle ---*/
		result = mc->angle2deg(argv[1],&angle);
	   sprintf(s,"%s",mc_d2s(angle));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angle2rad(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en radians                                       */
/****************************************************************************/
/* mc_angle2rad                                                             */
/*  Angle                                                                   */
/****************************************************************************/
{
   char s[524];
   int result;
   double angle;

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      abmc::IMc* mc = getInstance(clientData);
	  /* --- decode l'angle ---*/
		result = mc->angle2deg(argv[1],&angle);
      sprintf(s,"%s",mc_d2s(angle*(DR)));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angle2sexagesimal(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en sexagesimal                                           */
/****************************************************************************/
/*
Format = uspzad
u (unit) = h,H,d,D (default=D)
s (separator) = " ",:,"" (default="")
p (plus/moins) = +,"" (default="")
z (zeros) = 0,"" (default="")
a (angle_digits) = 2,3 (default=3 if unit D,H)
d (sec_digits) = "",".1",".2",... (default="")
//
load libabmc_tcl
set sangles { 34 -34  34 -34  -33.999999 234.567854 234.567854 -78.45454656}
set sformats {"d" "d" "D" "D" "d +.2"    "H:.2"     "H.2"      "d+.1"}
set n [llength $sangles]
for {set k 0} {$k<$n} {incr k} {
   set sangle [lindex $sangles $k]
   set sformat [lindex $sformats $k]
   set res [abmc_angle2sexagesimal $sangle $sformat]
   console::affiche_resultat "$sangle $sformat = <${res}>\n"
}
*/
/****************************************************************************/
{
   char s[524];
   int result;
   
   abmc::IMc* mc = getInstance(clientData);
		
   if(argc<=2) {
      sprintf(s,"Usage: %s Angle format", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- mise en forme ---*/
		char string_sexagesimal[50];
		double deg;
		mc->angle2deg(argv[1],&deg);
		mc->angle2sexagesimal(deg,argv[2],string_sexagesimal);
      Tcl_SetResult(interp,string_sexagesimal,TCL_VOLATILE);
      result = TCL_OK;
	}
   return(result);
}

int Cmd_mctcl_angles_computation(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul sur les Angles                                                    */
/****************************************************************************/
/* mc_anglescomp                                                            */
/*  Angle1 Operande Angle2                                                  */
/*
load libabmc_tcl
set angle1 "34:20:00"
set op +
set angle2 "57:51:00"
set res [abmc_anglescomp $angle1 $op $angle2]
console::affiche_resultat "$angle1 $op $angle2 = <${res}>\n"
set res [abmc_angle2sexagesimal $res "d.2"]
console::affiche_resultat "<${res}>\n"
set angle1 "34:20:00"
set op *
set angle2 "2"
set res [abmc_anglescomp $angle1 $op $angle2]
console::affiche_resultat "$angle1 $op $angle2 = <${res}>\n"
set res [abmc_angle2sexagesimal $res "d.2"]
console::affiche_resultat "<${res}>\n"
*/
/****************************************************************************/
{
   char s[524];
   int result,op;
   double angle12;

   abmc::IMc* mc = getInstance(clientData);

   if(argc<4) {
      sprintf(s,"Usage: %s Angle1 Operand Angle2", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	   /* --- decode l'operande ---*/
		strcpy(s,argv[2]);
		if (strcmp(s,"*")==0) {op=2;}
		else if (strcmp(s,"/")==0) {op=-2;}
		else if (strcmp(s,"-")==0) {op=-1;}
		else if (strcmp(s,"%")==0) {op=3;}
		else if (strcmp(s,"modulo")==0) {op=3; strcpy(s,"%"); }
		else if (strcmp(s,"+")==0) {op=1;}
		else {
         strcpy(s,"Operand should be +|-|*|/|%");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_ERROR;
			return result;
		}
		mc->angles_computation(argv[1],s,argv[3],&angle12);
		sprintf(s,"%s",mc_d2s(angle12));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
	}
	return result;
}

int Cmd_mctcl_angles_separation(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul l'angle de separation entre deux coordonnees.                     */
/****************************************************************************/
/****************************************************************************/
{
   char s[524],ss[100];
   int result;
   double dist,posangle;

   abmc::IMc* mc = getInstance(clientData);

   if(argc<=4) {
      sprintf(s,"Usage: %s Cooord1_angle1 Cooord1_angle2 Cooord2_angle1 Cooord2_angle2", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
		//mc->coordinates_separation(argv[1],argv[2],argv[3],argv[4],&dist,&posangle);
		//strcpy(s,"");
		//sprintf(ss,"%s ",mc_d2s(dist)); strcat(s,ss);
		//sprintf(ss,"%s",mc_d2s(posangle)); strcat(s,ss);
		//Tcl_SetResult(interp,s,TCL_VOLATILE);
		result=TCL_OK;
   }
   return result;
}
