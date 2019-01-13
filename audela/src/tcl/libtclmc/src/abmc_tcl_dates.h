// abmc_tcl_dates.h : 
// import interface of abmc astrobrick

#pragma once

int Cmd_mctcl_date2jd      (ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int Cmd_mctcl_date2lst     (ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int Cmd_mctcl_date2iso8601 (ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int Cmd_mctcl_date2ymdhms  (ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int Cmd_mctcl_date2tt      (ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int Cmd_mctcl_date2equinox (ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
