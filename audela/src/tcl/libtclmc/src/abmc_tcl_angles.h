// abmc_tcl_angles.h : 
// import interface of abmc astrobrick

#pragma once

int Cmd_mctcl_angle2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mctcl_angle2rad(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mctcl_angle2sexagesimal(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mctcl_angles_computation(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
int Cmd_mctcl_angles_separation(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
