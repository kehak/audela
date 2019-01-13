/* util.c
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

// $Id: util.cpp,v 1.1 2010-09-05 19:25:03 michelpujol Exp $

#include "sysexp.h"

#include <math.h>
#if defined(OS_LIN) || defined(OS_MACOS)
#   include <stdlib.h>
#   include <string.h>
#   include <dlfcn.h>
#   include <unistd.h>
#   include <stdio.h>
#   include "system.h" // au lieu de <asm/system.h> (pb redhat)
#   include <sys/time.h>
#   if defined(OS_LIN)
#      include <sys/io.h>
#   endif
#endif
#if defined(OS_WIN)
#   include <windows.h>
#   include <stdio.h>
#endif

#include <libtel/util.h>

/*
 * Echange deux entiers pointes par a et b.
 */
void libtel_swap(int *a, int *b)
{
   register int t;
   t = *a;
   *a = *b;
   *b = t;
}


/*
 * Attente en millisecondes.
 */
void libtel_sleep(int ms)
{
#if defined(OS_LIN) || defined(OS_MACOS)
   usleep(ms*1000);
#endif
#if defined(OS_WIN)
   Sleep(ms);
#endif
}


/*
 * Sortie sur un port donne.
 */
void libtel_out(unsigned short a, unsigned char d)
{
#if defined(OS_WIN)
   _asm {
      mov dx, a
      mov al, d
      out dx, al
   }
#endif
#if defined(OS_LIN)
   outb(d,a);
#endif
}


/*
 * Entree sur un port.
 */
unsigned char libtel_in(unsigned short a)
{
#if defined(OS_WIN)
   _asm {
      mov dx, a
      in al, dx
   }
   // ne pas mettre de return
#endif
#if defined(OS_LIN)
   return inb(a);
#endif
#if defined(OS_MACOS)
   return 0;
#endif
}

unsigned short libtel_inw(unsigned short a)
{
#if defined(OS_WIN)
   _asm {
      mov dx, a
      in ax, dx
   }
   // ne pas mettre de return
#endif
#if defined(OS_LIN)
   return inw(a);
#endif
#if defined(OS_MACOS)
   return 0;
#endif
}


/*
 * Blocage des interruptions. Attention, sous Linux un appel systeme retablit
 * les interruptions (acces memoire, printf, etc...).
 */
void libtel_bloquer()
{
#if defined(OS_LIN)
    int permission;
    if ((permission = iopl(3)) != 0) {
	printf("Impossible d'acceder au port parallele.\n");
	exit(1);
    }
    AUDELA_CLI();
#endif
#if defined(OS_WIN)
/* *INDENT-OFF* */
    _asm {
        cli
    }
/* *INDENT-ON* */
#endif
}


/*
 * Debloquage des interruptions.
 */
void libtel_debloquer()
{
#if defined(OS_LIN)
    AUDELA_STI();
#endif
#if defined(OS_WIN)
/* *INDENT-OFF* */
    _asm {
        sti
    }
/* *INDENT-ON* */
#endif
}

/*
 * Mise a jour de l'horloge de l'OS a partir du BIOS
 */
void update_clock()
{
   int second=0, minute=0, hour=0, day=1, dayofweek, month=1, year=1970;
#if defined(OS_WIN)
   SYSTEMTIME time;
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
   int s1970;
   double jour,jd1970,jd;
   struct timeval nowdate;
#endif

   if ((clock_read_RTC(REGISTER_D) & MASK_BATTERY) == MASK_BATTERY) {

      // attendre la fin de la mise a jour
      while ((clock_read_RTC(REGISTER_A) & MASK_UIP) == MASK_UIP);

      // bloquer la mise a jour
      clock_write_RTC(REGISTER_B,clock_read_RTC(REGISTER_B) | MASK_UPDATE);
      if ((clock_read_RTC(REGISTER_B)&MASK_BCD)==MASK_BCD) {
         // Mode binaire
         second    = clock_read_RTC(SECOND);
         minute    = clock_read_RTC(MINUTE);
         hour      = clock_read_RTC(HOUR);
         day       = clock_read_RTC(DAY);
         dayofweek = clock_read_RTC(DAYOFWEEK);
         month     = clock_read_RTC(MONTH);
         year      = clock_read_RTC(YEAR);
         year += 100*BCD2BIN(clock_read_RTC(CENTURY));
      } else {
         // Mode BCD
         second    = BCD2BIN(clock_read_RTC(SECOND));
         minute    = BCD2BIN(clock_read_RTC(MINUTE));
         hour      = BCD2BIN(clock_read_RTC(HOUR));
         day       = BCD2BIN(clock_read_RTC(DAY));
         dayofweek = BCD2BIN(clock_read_RTC(DAYOFWEEK));
         month     = BCD2BIN(clock_read_RTC(MONTH));
         year      = BCD2BIN(clock_read_RTC(YEAR));
         year += 100*BCD2BIN(clock_read_RTC(CENTURY));
      }
      clock_write_RTC(REGISTER_B,clock_read_RTC(REGISTER_B) & ~MASK_UPDATE); /* autoriser la mise a jour */
   }

#if defined(OS_WIN)
   GetLocalTime (&time);
   time.wSecond    = (WORD)second;
   time.wMinute    = (WORD)minute;
   time.wHour      = (WORD)hour;
   time.wDay       = (WORD)day;
   time.wDayOfWeek = (WORD)dayofweek;
   time.wMonth     = (WORD)month;
   time.wYear      = (WORD)year;
   SetLocalTime (&time);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
   /* date sour la forme du nombre de secondes ecoulees */
   /* depuis le 1er Janvier 1970 a 00h 00m 00s GMT */
   date_jd(1970,1,1.0,&jd1970);
   jour=(double)(day)+(double)(hour)/24.+(double)(minute)/1440.+(double)(second)/86400.;
   date_jd(year,month,jour,&jd);
   s1970=(int)((jd-jd1970)*86400.);
   nowdate.tv_usec=(int)0;
   nowdate.tv_sec=(int)s1970;
   settimeofday(&nowdate,NULL);
#endif
}

void date_jd(int annee, int mois, double jour, double *jj)
/***************************************************************************/
/* Donne le jour juliene correspondant a la date                           */
/***************************************************************************/
/* annee : valeur de l'annee correspondante                                */
/* mois  : valeur du mois correspondant                                    */
/* jour  : valeur du jour decimal correspondant                            */
/* *jj   : valeur du jour julien converti                                  */
/***************************************************************************/
{
   double a,m,j,aa,bb,jd;
   a=annee;
   m=mois;
   j=jour;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   *jj=jd;
}

unsigned char clock_read_RTC(int index)
{
   libtel_out(CTRL_RTC,(unsigned char)index);
   return libtel_in(DATA_RTC);
}

void clock_write_RTC(int index, int value)
{
   libtel_out(CTRL_RTC,(unsigned char)index);
   libtel_out(DATA_RTC,(unsigned char)value);
}

unsigned long libcam_getms()
/* --- utilitaire pour le drift scan ---*/
{
   unsigned long now;
#if defined(OS_LIN) || defined(OS_MACOS)
   struct timeval date;
   gettimeofday(&date,NULL);
   now = date.tv_sec*1000 + date.tv_usec/1000;
   return now;
#endif

#if defined(OS_WIN)
   now=(unsigned long)GetTickCount();
#endif
   return now;
}

void test_out_time(unsigned short port,unsigned long nb_out,unsigned long shouldbezero)
{
   unsigned long muloop;
   for (muloop=1;muloop<=nb_out;muloop++) {
      if (muloop>shouldbezero) {
         libtel_out(port,255);
      }
   }
}

unsigned long loopsmillisec()
/* retourne micro1, le nombre de boucles pour faire 1 microseconde */
/*
unsigned long micro1,muloop,muloop10,muloops[10];
micro1=loopsmicrosec();
for (muloop10=0,muloop=0;muloop<micro1;muloop++) { muloops[muloop10]=(unsigned long)(0); if (++muloop10>9) { muloop10=0; } }
*/
{
	unsigned long micro1,muloop,muloop10,muloops[10];
   unsigned long t1,t2,t3;
	int sortie=0,b;
	micro1=10;
	b=0;
	while (sortie==0) {
    t1=libcam_getms();
		/* La boucle suivante est obligee d'etre effectuee */
		/* en entier meme si le compilateur optimise */
      for (muloop10=0,muloop=0;muloop<micro1;muloop++) { muloops[muloop10]=(unsigned long)(0); if (++muloop10>9) { muloop10=0; } }
      muloops[0]=libcam_getms();
		t2=muloops[0];
		/* t3 : nombre de millisecondes pour effectuer n boucles */
      t3=(t2-t1);
      if (t3<(unsigned long)500) {
			micro1=(unsigned long)10*micro1;
		} else {
			sortie=1;
			micro1=micro1/t3;
			break;
		}
		if (b>10) {
			t3=1;
			sortie=1;
			break;
		}
	}
	return micro1;
}

unsigned long loopsmicrosec()
/* retourne micro1, le nombre de boucles pour faire 1 microseconde */
/*
unsigned long micro1,muloop,muloop10,muloops[10];
micro1=loopsmicrosec();
for (muloop10=0,muloop=0;muloop<micro1;muloop++) { muloops[muloop10]=(unsigned long)(0); if (++muloop10>9) { muloop10=0; } }
*/
{
   unsigned long t1,t2,t3;
   unsigned long n;
	int sortie=0,b;
	unsigned long x,xx,a[10];
	n=100000;
	b=0;
	while (sortie==0) {
		b++;
      t1=libcam_getms();
		/* La boucle suivante est obligee d'etre effectuee */
		/* en entier meme si le compilateur optimise */
      for (xx=0,x=0;x<n;x++) { a[xx]=(unsigned long)(0); if (++xx>9) { xx=0; } }
      a[0]=libcam_getms();
		t2=a[0];
		/* t3 : nombre de millisecondes pour effectuer n boucles */
      t3=(t2-t1);
      if (t3<(unsigned long)30) {
			n=(unsigned long)10*n;
		} else {
			sortie=1;
			break;
		}
		if (b>10) {
			t3=1;
			sortie=1;
			break;
		}
	}
	/* nombre de microsecondes pour effectuer n boucles */
   t3*=(unsigned long)1000;
	/* nombre de boucles a effectuer pour 1 microseconde */
	return ((int)(n/t3*10));
}

void libtel_strupr(char *chainein, char *chaineout)
/***************************************************************************/
/* Fonction de mise en majuscules emulant strupr (pb sous unix)            */
/***************************************************************************/
{
   int len,k;
   char a;
   len=(int)strlen(chainein);
   for (k=0;k<=len;k++) {
      a=chainein[k];
      if ((a>='a')&&(a<='z')){chaineout[k]=(char)(a-32); }
      else {chaineout[k]=a; }
   }
}

void libtel_strlwr(char *chainein, char *chaineout)
/***************************************************************************/
/* Fonction de mise en minuscules emulant strupr (pb sous unix)            */
/***************************************************************************/
{
   int len,k;
   char a;
   len=(int)strlen(chainein);
   for (k=0;k<=len;k++) {
      a=chainein[k];
      if ((a>='A')&&(a<='Z')){chaineout[k]=(char)(a+32); }
      else {chaineout[k]=a; }
   }
}
