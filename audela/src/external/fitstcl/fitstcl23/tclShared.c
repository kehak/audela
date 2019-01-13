
#include <tcl.h>

#ifdef macintosh
#pragma export on
#endif

#ifdef __WIN32__
int Fitstcl_Init (Tcl_Interp *interp);
#else 
int Fitstcl_Init (Tcl_Interp *interp);
#endif

#ifdef macintosh
#pragma export reset
#endif

int Fitstcl_Init (interp)
    Tcl_Interp *interp;		/* Interpreter for application. */
{
  return Fits_Init(interp);
}

