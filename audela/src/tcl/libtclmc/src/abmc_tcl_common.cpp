// abmc_tcl_commmon.cpp : 
#include <sstream>  // pour ostringstream
#include <string>
#include <stdexcept>
#include <cstring>
#include <cmath>
#include <abmc.h>
#include "abmc_tcl_common.h"

int Cmd_mctcl_help(ClientData , Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Help                                                                     */
/****************************************************************************/
/****************************************************************************/
{
   char s[512];
   int result;
   Tcl_DString text,res;

	// load libabmc_tcl ; abmc_help angle2deg c:/srv/develop/audela/src/astrobrick/libabmc/doc/abmc_ref_scripts.json
	// load libabmc_tcl ; abmc_help * c:/srv/develop/audela/src/astrobrick/libabmc/doc/abmc_ref_scripts.json
	// load libabmc_tcl ; abmc_help "" c:/srv/develop/audela/src/astrobrick/libabmc/doc/abmc_ref_scripts.json
   if(argc<=1) {
      sprintf(s,"Usage: %s item ?json_helpfile?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
		Tcl_DStringInit(&res);
		Tcl_DStringInit(&text);
		Tcl_DStringAppend(&text,"proc json2keyvals { json } { set n [expr [llength $json]] ; set keyvals \"\" ; for {set k 0} {$k<$n} {incr k 2} { lappend keyvals [list [lindex $json $k] [lindex $json [expr $k+1]]] } ; return $keyvals } ; ",-1);
		Tcl_DStringAppend(&text,"proc keyvals2vals { keyvals keytofind } { set n [expr [llength $keyvals]] ; set vals {} ; for {set k 0} {$k<$n} {incr k} { set keyval [lindex $keyvals $k] ; set key [lindex $keyval 0] ; if {$key==$keytofind} { lappend vals [lindex $keyval 1] } } ; return [lindex $vals 0] } ; ",-1);
		Tcl_DStringAppend(&text,"proc json2vals { json keytofind } { set keyvals [json2keyvals $json] ; return [keyvals2vals $keyvals $keytofind] } ; ",-1);
		Tcl_DStringAppend(&text,"proc get_help { filename libname function} { ",-1);
		Tcl_DStringAppend(&text,"   set lignes {package require json ; set f [open $filename r] ;set txt [read $f] ;close $f ; set res [json2keyvals [::json::json2dict $txt]]} ;",-1);
		Tcl_DStringAppend(&text,"   set data [eval $lignes]\n",-1);
		Tcl_DStringAppend(&text,"   set doc [keyvals2vals $data document]\n",-1);
		Tcl_DStringAppend(&text,"   if {$doc!=\"Reference guide\"} {\n",-1);
		Tcl_DStringAppend(&text,"      return \"\"\n",-1);
		Tcl_DStringAppend(&text,"   }\n",-1);
		Tcl_DStringAppend(&text,"   set text \"\"\n",-1);
		Tcl_DStringAppend(&text,"   if {($function==\"\") || ($function==\"*\")} {\n",-1);
		Tcl_DStringAppend(&text,"      append text \"$doc of [keyvals2vals $data name]\n\"\n",-1);
		Tcl_DStringAppend(&text,"      append text [keyvals2vals $data details]\n",-1);
		Tcl_DStringAppend(&text,"   }\n",-1);
		Tcl_DStringAppend(&text,"   if {$function==\"\"} {\n",-1);
		Tcl_DStringAppend(&text,"      append text \"\nType ${libname}_help \\\"*\\\" to list all functions.\"\n",-1);
		Tcl_DStringAppend(&text,"      append text \"\nType ${libname}_help \\\"angle2deg\\\" to obtain details of this function.\"\n",-1);
		Tcl_DStringAppend(&text,"   } else {\n",-1);
		Tcl_DStringAppend(&text,"      # --- scan standalone functions\n",-1);
		Tcl_DStringAppend(&text,"      if {$function==\"*\"} {\n",-1);
		Tcl_DStringAppend(&text,"         append text \"\n\nList of functions:\n\n\"\n",-1);
		Tcl_DStringAppend(&text,"      }\n",-1);
		Tcl_DStringAppend(&text,"      set ns 0\n",-1);
		Tcl_DStringAppend(&text,"      set defs [keyvals2vals $data functions]\n",-1);
		Tcl_DStringAppend(&text,"      set nd [llength $defs]\n",-1);
		Tcl_DStringAppend(&text,"      for {set kd 0} {$kd<$nd} {incr kd} {\n",-1);
		Tcl_DStringAppend(&text,"         set defskd [json2keyvals [lindex $defs $kd]]\n",-1);
		Tcl_DStringAppend(&text,"         set d [keyvals2vals $defskd fn]\n",-1);
		Tcl_DStringAppend(&text,"         if {($d==$function) || ($function==\"*\")} {\n",-1);
		Tcl_DStringAppend(&text,"            set a [keyvals2vals $defskd args]\n",-1);
		Tcl_DStringAppend(&text,"            set na [llength $a]\n",-1);
		Tcl_DStringAppend(&text,"            if {$ns>0} {\n",-1);
		Tcl_DStringAppend(&text,"               append text \"\n\"\n",-1);
		Tcl_DStringAppend(&text,"            }\n",-1);
		Tcl_DStringAppend(&text,"            append text \"$doc for function ${libname}.${d} \"\n",-1);
		Tcl_DStringAppend(&text,"            for {set ka 0} {$ka<$na} {incr ka} {\n",-1);
		Tcl_DStringAppend(&text,"               if {$ka>0} {\n",-1);
		Tcl_DStringAppend(&text,"                  append text \" \"\n",-1);
		Tcl_DStringAppend(&text,"               }\n",-1);
		Tcl_DStringAppend(&text,"               append text [lindex $a $ka]\n",-1);
		Tcl_DStringAppend(&text,"            }\n",-1);
		Tcl_DStringAppend(&text,"            append text \"\n\"\n",-1);
		Tcl_DStringAppend(&text,"            if {$d==$function} {\n",-1);
		Tcl_DStringAppend(&text,"               append text \"\n\"\n",-1);
		Tcl_DStringAppend(&text,"            }\n",-1);
		Tcl_DStringAppend(&text,"            append text \"[keyvals2vals $defskd brief]\n\"\n",-1);
		Tcl_DStringAppend(&text,"            if {$d==$function} {\n",-1);
		Tcl_DStringAppend(&text,"               append text \"\n\"\n",-1);
		Tcl_DStringAppend(&text,"               append text \"[keyvals2vals $defskd details]\n\"\n",-1);
		Tcl_DStringAppend(&text,"               set t [keyvals2vals $defskd example]\n",-1);
		Tcl_DStringAppend(&text,"               if {$t!=\"\"} {\n",-1);
		Tcl_DStringAppend(&text,"                  append text \"\nExample:\n\n\"\n",-1);
		Tcl_DStringAppend(&text,"                  append text \"${t}\n\"\n",-1);
		Tcl_DStringAppend(&text,"               }\n",-1);
		Tcl_DStringAppend(&text,"               set t [keyvals2vals $defskd \"related functions\"]\n",-1);
		Tcl_DStringAppend(&text,"               if {$t!=\"\"} {\n",-1);
		Tcl_DStringAppend(&text,"                  append text \"\nRelated functions:\n\n\"\n",-1);
		Tcl_DStringAppend(&text,"                  append text \"${t}\n\"\n",-1);
		Tcl_DStringAppend(&text,"               }\n",-1);
		Tcl_DStringAppend(&text,"            }\n",-1);
		Tcl_DStringAppend(&text,"            incr ns\n",-1);
		Tcl_DStringAppend(&text,"         }\n",-1);
		Tcl_DStringAppend(&text,"      }\n",-1);
		Tcl_DStringAppend(&text,"      # --- scan types\n",-1);
		Tcl_DStringAppend(&text,"      if {$function==\"*\"} {\n",-1);
		Tcl_DStringAppend(&text,"         append text \"\n\nList of types:\n\n\"\n",-1);
		Tcl_DStringAppend(&text,"      }\n",-1);
		Tcl_DStringAppend(&text,"      set ns 0\n",-1);
		Tcl_DStringAppend(&text,"      set defs [keyvals2vals $data types]\n",-1);
		Tcl_DStringAppend(&text,"      set nd [llength $defs]\n",-1);
		Tcl_DStringAppend(&text,"      for {set kd 0} {$kd<$nd} {incr kd} {\n",-1);
		Tcl_DStringAppend(&text,"         set defskd [json2keyvals [lindex $defs $kd]]\n",-1);
		Tcl_DStringAppend(&text,"         set d [keyvals2vals $defskd type]\n",-1);
		Tcl_DStringAppend(&text,"         if {($d==$function) || ($function==\"*\")} {\n",-1);
		Tcl_DStringAppend(&text,"            if {$ns>0} {\n",-1);
		Tcl_DStringAppend(&text,"               append text \"\n\"\n",-1);
		Tcl_DStringAppend(&text,"            }\n",-1);
		Tcl_DStringAppend(&text,"            append text \"Type ${d}\n\"\n",-1);
		Tcl_DStringAppend(&text,"            if {$d==$function} {\n",-1);
		Tcl_DStringAppend(&text,"               append text \"\n\"\n",-1);
		Tcl_DStringAppend(&text,"            }\n",-1);
		Tcl_DStringAppend(&text,"            append text \"[keyvals2vals $defskd brief]\n\"\n",-1);
		Tcl_DStringAppend(&text,"            if {$d==$function} {\n",-1);
		Tcl_DStringAppend(&text,"               append text \"\n\"\n",-1);
		Tcl_DStringAppend(&text,"               append text \"[keyvals2vals $defskd details]\n\"\n",-1);
		Tcl_DStringAppend(&text,"            }\n",-1);
		Tcl_DStringAppend(&text,"            incr ns\n",-1);
		Tcl_DStringAppend(&text,"         }\n",-1);
		Tcl_DStringAppend(&text,"      }\n",-1);
		Tcl_DStringAppend(&text,"   }\n",-1);
		Tcl_DStringAppend(&text,"   return $text\n",-1);
		Tcl_DStringAppend(&text,"}\n",-1);
		result = Tcl_Eval(interp,text.string);
		if (result==TCL_ERROR) {
			Tcl_DStringGetResult(interp,&res);
			Tcl_DStringResult(interp,&res);
			Tcl_DStringFree(&text);
			Tcl_DStringFree(&res);
			return result;
		}
		Tcl_DStringFree(&text);
		Tcl_DStringInit(&text);
		Tcl_DStringAppend(&text,"set filename ",-1);
	   if(argc>=3) {
			Tcl_DStringAppend(&text,"\"",-1);
			Tcl_DStringAppend(&text,argv[2],-1);
			Tcl_DStringAppend(&text,"\" ; ",-1);
		} else {
			Tcl_DStringAppend(&text,"abmc_ref_scripts.json ;",-1);
		}
		Tcl_DStringAppend(&text,"set libname abmc ; ",-1);
		Tcl_DStringAppend(&text,"set function \"",-1);
		Tcl_DStringAppend(&text,argv[1],-1);
		Tcl_DStringAppend(&text,"\" ; ",-1);
		Tcl_DStringAppend(&text,"get_help $filename $libname $function ",-1);
		result = Tcl_Eval(interp,text.string);
		Tcl_DStringGetResult(interp,&res);
		Tcl_DStringResult(interp,&res);
		Tcl_DStringFree(&text);
		Tcl_DStringFree(&res);
	}
	return result;
}

char *mc_d2s(double val)
/***************************************************************************/
/* Double to String conversion with many digits                            */
/***************************************************************************/
/***************************************************************************/
{
   int kk,nn;
   static char s[200];
   sprintf(s,"%13.12g",val);
	nn=(int)strlen(s);
	for (kk=0;kk<nn;kk++) {
		if (s[kk]!=' ') {
			break;
		}
	}		
   return s+kk;
}

void mc_strupr(char *chainein, char *chaineout)
/***************************************************************************/
/* Fonction de mise en majuscules emulant strupr (pb sous unix)            */
/***************************************************************************/
{
   int len,k;
   char a;
   len=strlen(chainein);
   for (k=0;k<=len;k++) {
      a=chainein[k];
      if ((a>='a')&&(a<='z')){chaineout[k]=(char)(a-32); }
      else {chaineout[k]=a; }
   }
}

void mc_deg2d_m_s(double valeur,char *charsigne,int *d,int *m,double *s)
/***************************************************************************/
/* Calcul la valeur d.ms a partir de la valeur decimale.                   */
/***************************************************************************/
{
   double y,dd,mm,sss;
   y=valeur;
   if (y<0) {strcpy(charsigne,"-");} else {strcpy(charsigne,"+");}
   y=fabs(y);
   dd=floor(y);
   y=(y-dd)*60.;
   mm=floor(y);
   y=(y-mm)*60.;
   sss=y;
   if (sss>59.999999) {sss=59.999999;}
   *d=(int)(dd);
   *m=(int)(mm);
   *s=sss;
   return;
}

void mc_deg2h_m_s(double valeur,int *h,int *m,double *s)
/***************************************************************************/
/* Calcul la valeur h.ms a partir de la valeur decimale.                   */
/***************************************************************************/
{
   double y,dd,mm,sss,signe;
   y=valeur/15.;
   if (y<0) {signe=-1.;} else {signe=1.;}
   y=fabs(y);
   dd=floor(y);
   y=(y-dd)*60.;
   mm=floor(y);
   y=(y-mm)*60.;
   sss=y;
   if (sss>59.999999) {sss=59.999999;}
   *h=(int)(signe*dd);
   *m=(int)(mm);
   *s=sss;
   return;
}


//**************************************************************************
// copy argv to double               
//**************************************************************************
double copyArgvToDouble(Tcl_Interp *interp, const char *argv, const char * paramName) {
   double value;
   if(strlen(argv) == 0 ||Tcl_GetDouble(interp, argv,&value)!=TCL_OK) {
      std::ostringstream message;
      message << paramName <<"=" << argv << " is not a double";
      throw std::runtime_error( message.str().c_str());
   }
   return value;
}

//**************************************************************************
// copy argv to int               
//**************************************************************************
int copyArgvToInt(Tcl_Interp *interp, const char *argv, const char * paramName) {
   int value;
   if(strlen(argv) == 0  || Tcl_GetInt(interp, argv,&value)!=TCL_OK) {
      std::ostringstream message;
      message << paramName <<"=" << argv << " is not an integer";
      throw std::runtime_error( message.str().c_str());
   }
   return value;
}

//**************************************************************************
// copy argv to bool               
//**************************************************************************
bool copyArgvToBoolean(Tcl_Interp *interp, const char *argv, const char * paramName) {
   int value;
   if(strlen(argv) == 0  || Tcl_GetBoolean(interp, argv, &value)!=TCL_OK) {
      std::ostringstream message;
      message << paramName <<"=" << argv << " is not a boolean integer";
      throw std::runtime_error( message.str().c_str());
   }
   return (value == 1);
}

abmc::IMc* getInstance(ClientData clientData) {
   return (abmc::IMc*) clientData;
}
