// Projet      : AudeLA
// Librairie   : LIBBM
// Fichier     : libbm.h
// Description : Point d'entrée de la librairie
// ============================================

#define NUMERO_VERSION "1.5"


#ifndef __LIBBMH__
#define __LIBBMH__

#include "sysexp.h"

#ifdef LIBRARY_DLL
# include <windows.h>
#endif

#ifdef OS_WIN_BORL_DLL
# include "tcl.h"
# include "tk.h"
#endif

#ifdef OS_WIN_VCPP_DLL
# include "tcl.h"
# include "tk.h"
#endif

#include <tcl.h>

#include "bm_c_tcl.h"
#include "bm.h"

#endif


