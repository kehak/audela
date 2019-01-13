// abmc_tcl_obsoletes.h : 
// import interface of abmc astrobrick

#pragma once

int Cmd_mctcl_angle2dms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mctcl_angle2hms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mctcl_anglesep(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mctcl_sepangle(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
