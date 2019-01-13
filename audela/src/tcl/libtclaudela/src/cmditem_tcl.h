
#include <tcl.h>

/*
 * Structure cmditem used to hold the TCL name of a command, and
 * the corresponding C function.
 */
struct cmditem {
   char *cmd;
   Tcl_CmdProc *func;
};