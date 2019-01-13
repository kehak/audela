/* utils.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2008 The AudeLA Core Team
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

#include <stdlib.h>

#include "sysexp.h"

#if defined(OS_LIN) || defined(OS_MACOS)
   #include <sys/time.h>
#endif

#if defined(OS_WIN)
   #include <windows.h>
#endif

unsigned long audela_getms()
{
#if defined(OS_LIN) || defined(OS_MACOS)
   struct timeval thedate;
   unsigned long now;
   gettimeofday(&thedate,NULL);
   now = thedate.tv_sec*1000 + thedate.tv_usec/1000;
   return now;
#elif defined(OS_WIN)
   return GetTickCount();
#else
   return 0;
#endif
}
