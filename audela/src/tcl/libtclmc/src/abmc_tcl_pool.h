// abmc_tcl_dates.h : 
// import interface of abmc astrobrick

#pragma once

int cmdMcCreate(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int cmdMcDelete(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);
int cmdMcList(ClientData clientData, Tcl_Interp *interp, int argc, const char *argv[]);

