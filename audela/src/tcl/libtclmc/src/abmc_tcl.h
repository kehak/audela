
#pragma once

//=============================================================================
// export directive and import directive
//=============================================================================
#ifdef WIN32
#if defined(TCLMC_EXPORTS) // inside DLL
#   define TCLMC_API   __declspec(dllexport)
#else // outside DLL
#   define TCLMC_API   __declspec(dllimport)
#endif 

#else 

#if defined(TCLMC_EXPORTS) // inside DLL
#   define TCLMC_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define TCLMC_API 
#endif 

#endif

#include <tcl.h>  // for Tcl_Interp

// unique entry point 
extern "C" TCLMC_API int Tclmc_Init(Tcl_Interp *interp);



