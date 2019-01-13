
#include <tcl.h>

#ifdef macintosh
#pragma export on
#endif

#ifdef __WIN32__
int _export Fitstcl_Init (Tcl_Interp *interp);
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

int Fitstcl_SafeInit (interp)
    Tcl_Interp *interp;		/* Interpreter for application. */
{
  return Fits_SafeInit(interp);
}

int Fitstcl_SafeUnload(Tcl_Interp *interp, int flags) 
{
     return FitsTcl_SafeUnload(interp, flags);
}

int Fitstcl_Unload(Tcl_Interp *interp, int flags) 
{
     return FitsTcl_Unload(interp, flags);
}
