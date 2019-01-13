/***
 * @file : libjm.h
 * @brief : objets génériques de lq libJM
 * @author : Jacques MICHELET <jacques.michelet@laposte.net>
 *
 * Mise à jour $Id: libjm.h,v 1.9 2010-06-19 16:58:42 jacquesmichelet Exp $
 *
 * <pre>
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * </pre>
 */


#ifndef __LIBJM_H__
#define __LIBJM_H__

#include <sysexp.h>
#include <string>

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

#ifdef LIBRARY_SO
# include <tcl.h>
#endif

namespace LibJM
{
    class Generique
    {
    public:
#if defined(WIN32) && defined(_MSC_VER) &&( _MSC_VER < 1500)
// Les versions VisualC++ anterieures a VC90 ne suportent pas l'initialisation des variables statiques
        enum{OK = 1, PB = 1, PB2 = 2};
#else
        static const int OK = 0;
        static const int PB = 1;
        static const int PB2 = 2;
#endif
        static const std::string NUMERO_VERSION;
        static std::string repertoire_log;

        static int CmdVersionLib( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );
        static int CmdRepertoireLog( ClientData clientData, Tcl_Interp *interp, int argc, char *argv[] );

    };
}


#ifdef LIBRARY_DLL
   extern "C" int __cdecl Jm_Init(Tcl_Interp *interp);
#endif

#ifdef LIBRARY_SO
   extern "C" int Jm_Init(Tcl_Interp *interp);
#endif

#endif


