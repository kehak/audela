/* sysexp.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 * 
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
 */

#ifndef __SYSEXPH__
#define __SYSEXPH__

/* --- definition de l'operating systeme (OS) employe pour compiler    ---*/

#define OS_UNK

/* Choose an Operating System among the followings : */
//#define OS_WIN
//#define OS_LIN
//#define OS_UNX
//#define OS_MAC

/* Choose an platform among the following : */
//#define PF_PC
//#define PF_SUN

/* Defines for libtt */
//#define OS_WIN_BORLB_DLL
//#define OS_WIN_BORL_DLL
//#define OS_WIN_VCPP_DLL
//#define OS_UNIX_CC
//#define OS_UNIX_CC_HP_SL
//#define OS_UNIX_CC_DECBAG_SO_VADCL
//#define OS_LINUX_GCC_SO
//#define OS_DOS_WATC
//#define OS_DOS_WATC_LIB
//#define OS_WIN_VCPP


/* Automatic detection */
#if defined(_Windows)
   // Borland
   #define OS_WIN
   #define PF_PC
   #undef OS_UNK
   #define OS_WIN_BORL_DLL
   #define LIBRARY_DLL
#elif defined(_MSC_VER)
   // Visual C++
   #define OS_WIN
   #define PF_PC
   #undef OS_UNK
   #define OS_WIN_VCPP_DLL
   #define LIBRARY_DLL
#elif defined(__linux__)
   // gcc Linux
   #define OS_LIN
   #define PF_PC
   #undef OS_UNK
   #define OS_LINUX_GCC_SO
   #define LIBRARY_SO
#elif defined(__WIN32__)
   #define OS_WIN
   #define PF_PC
   #undef OS_UNK
   #define LIBRARY_DLL
#elif defined(__APPLE_CC__)
   #define OS_MACOS
   #define PF_MAC
   #undef OS_UNK
   #define OS_LINUX_GCC_SO // Pour compatibilite libtt <-> MacOsX
   #define LIBRARY_SO
#else
   // Autres Windows
   #define OS_LINUX_GCC_SO
   #define LIBRARY_SO
#endif

#if defined(__arm__)
	#define PROCESSOR_INSTRUCTIONS_ARM
#else
	#define PROCESSOR_INSTRUCTIONS_INTEL
#endif

// Que fait une SUN-SPARC ? : -Dsparc -Dsun -Dunix -D__svr4__ -D__SVR4

#endif

