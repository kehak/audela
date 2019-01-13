/* util.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

// $Id: util.h,v 1.1 2009-03-14 11:52:14 michelpujol Exp $

#ifndef __PARALLEL_UTIL_H__
#define __PARALLEL_UTIL_H__

#include "sysexp.h"

#if defined(OS_WIN)
#define OS_WIN_USE_PARRALLEL_OLD_STYLE
#include <windows.h>
#include <winspool.h>   // for EnumPorts
#endif

#include <math.h>

#if defined(OS_LIN)
#define OS_LIN_USE_PARRALLEL_OLD_STYLE
#   include <stdlib.h>
#   include <string.h>
#   include <dlfcn.h>
#   include <unistd.h>
#   include <stdio.h>
#   include <sys/io.h>
#   include "system.h"          // au lieu de <asm/system.h> (pb redhat)
#endif

#ifdef __cplusplus
extern "C" {
#endif

void parallel_out(unsigned short a, unsigned char d);
void parallel_bloquer();
void parallel_debloquer();

#ifdef __cplusplus
}
#endif

#endif
