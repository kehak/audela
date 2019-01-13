// abmc_tcl_common.h : 
// common functions 

#pragma once

#include <tcl.h>
#include <abmc.h>

int Cmd_mctcl_help(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);

//
abmc::IMc* getInstance(ClientData clientData);

// common functions
char *mc_d2s(double val);
void mc_strupr(char *chainein, char *chaineout);
void mc_deg2d_m_s(double valeur,char *charsigne,int *d,int *m,double *s);
void mc_deg2h_m_s(double valeur,int *h,int *m,double *s);


// utilitaires de conversion des const char* argv  en variable C
int copyArgvToInt(Tcl_Interp *interp, const char *argv, const char * paramName);
double copyArgvToDouble(Tcl_Interp *interp, const char *argv, const char * paramName);
bool copyArgvToBoolean(Tcl_Interp *interp, const char *argv, const char * paramName);

