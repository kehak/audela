/* utils.c
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

#include "sysexp.h"

#if defined(OS_LIN)
   #include <ctype.h>
   #include <stdlib.h>
   #include <string.h>
   #include <dlfcn.h>
   #include <stdio.h>
   #include <asm/io.h>
   #include <asm/segment.h>
   #include "../../common/system.h"
   #include <sys/time.h>
   #include <unistd.h>
   #include <sys/perm.h>
#endif

void audela_strupr(char *s)
{
   int k;
   char a;
   for (k=0;k<(int)strlen(s);k++) {
      a=s[k];
      if ((a>='a')&&(a<='z')) {
         s[k]=(char)(a-32);
      }
   }
}
int audela_strcasecmp(char *a, char *b)
{
	while(toupper(*a)==toupper(*b)) {
		if(*a==0) return 0;
		a++;
		b++;
	}
	return 1;
}


unsigned long audela_getms()
{
#if defined(OS_LIN)
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

/*

void audela_out(unsigned short a, unsigned char d)
{
#if defined(PF_PC)
   #if defined(OS_WIN)
      _asm {
         mov dx, a
         mov al, d
         out dx, al
      }
   #elif defined(OS_LIN)
      outb(d,a);
   #endif
#endif
}

unsigned char audela_in(unsigned short a)
{
#if defined(PF_PC)
   #if defined(OS_WIN)
      _asm {
         mov dx, a
         in al, dx
      }
   #elif defined(OS_LIN)
      return inb(a);
   #endif
#else
   return (unsigned char)0;
#endif
}

unsigned short audela_inw(unsigned short a)
{
#if defined(PF_PC)
   #if defined(OS_WIN)
      _asm {
         mov dx, a
         in ax, dx
      }
   #elif defined(OS_LIN)
      return inw(a);
   #endif
#else
   return (unsigned char)0;
#endif
}

*/

void audela_sleep(int ms)
{
#if defined(OS_LIN)
   usleep(ms*1000);
#elif defined(OS_WIN)
   Sleep(ms);
#elif defined(OS_UNX)
   usleep(ms*1000);
#endif
}

void bloquer()
{
#if defined(PF_PC)
   #if defined(OS_WIN)
      _asm {
         cli
      }
   #elif defined(OS_LIN)
/*
      int toto;
      toto=iopl(3);
      if(toto!=0) {
         fprintf(stderr,"Impossible d'acceder au port parallele.\n");
         exit(1);
      }
      cli();
*/
   #endif
#endif
}


void debloquer()
{
#if defined(PF_PC)
   #if defined(OS_WIN)
      _asm {
         sti
      }
   #elif defined(OS_LIN)
/*
      sti();
*/
   #endif
#endif
}

