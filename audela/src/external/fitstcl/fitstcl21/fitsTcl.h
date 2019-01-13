/*
 * fitsTcl.h --
 *
 *          This header file describes the externally visible
 *          calls in the Tcl wrapping for Fitsio.
 *
 */

#ifndef FITSTCL
#define FITSTCL

#define FITSTCL_VERSION "2.2"
#define FITSTCL_MAJOR_VERSION  2
#define FITSTCL_MINOR_VERSION  2
#define FITSTCL_SERIAL         0

#include <tcl.h>

/*  Sun4s do not support %p, so switch to %lx  */

#ifdef HEX_PTRFORMAT
#define PTRFORMAT "%lx"
#else
#define PTRFORMAT "%p"
#endif

EXTERN int  Fits_Init (Tcl_Interp *interp);

EXTERN int  Fits_MainCommand (ClientData clientData,  
			      Tcl_Interp *interp, int argc,
			      Tcl_Obj *const argv[]);

EXTERN int  fitsDispatch (ClientData clientData,  
			  Tcl_Interp *interp, int argc, Tcl_Obj *const argv[]);

EXTERN int  fitsLst2Ptr (ClientData clientData,  
			 Tcl_Interp *interp, int argc, Tcl_Obj *const argv[]);
EXTERN int  fitsPtr2Lst (ClientData clientData,  
			 Tcl_Interp *interp, int argc, Tcl_Obj *const argv[]);
EXTERN int  fitsExpr (ClientData clientData,  
		      Tcl_Interp *interp, int argc, Tcl_Obj *const argv[]);
EXTERN int  fitsRange(ClientData clientData,
                      Tcl_Interp *interp, int argc, Tcl_Obj *const argv[]);



EXTERN int  getMaxCmd (ClientData clientData,  
		       Tcl_Interp *interp, int argc, char *const argv[]);

EXTERN int  getMinCmd (ClientData clientData,  
		       Tcl_Interp *interp, int argc, char *const argv[]);

EXTERN int  isFitsCmd (ClientData clientData, 
		       Tcl_Interp *interp,
		       int argc,
		       char *const argv[]);

EXTERN int  updateFirst (ClientData clientData, 
			 Tcl_Interp *interp,
			 int argc,
			 char *const argv[]);

EXTERN int  dataBlockToVar (ClientData clientData, 
			    Tcl_Interp *interp,
			    int argc,
			    char *const argv[]);

EXTERN int  setArray (ClientData clientData, 
		      Tcl_Interp *interp,
		      int argc,
		      char *const argv[]);

EXTERN int  searchArray (ClientData clientData, 
			 Tcl_Interp *interp,
			 int argc,
			 char *const argv[]);

EXTERN int  Table_calAbsXPos (ClientData clientData,
			      Tcl_Interp *interp,
			      int argc,
			      char *const argv[]);

EXTERN int  Table_updateCell ( ClientData clientData,
			       Tcl_Interp *interp,
			       int argc,
                               Tcl_Obj *const argv[] );

#endif
