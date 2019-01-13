/* util.c
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

/*
 * $Id: util.c,v 1.4 2008-12-13 14:38:34 denismarchais Exp $
 */


#include "sysexp.h"

#include <math.h>
#if defined(OS_LIN)
#   include <stdlib.h>
#   include <string.h>
#   include <dlfcn.h>
#   include <unistd.h>
#   include <stdio.h>
#   include <sys/io.h>
#   include "system.h"		// au lieu de <asm/system.h> (pb redhat)
#   include <sys/time.h>
#   include <stdarg.h>     // va_list, va_start, va_arg, va_end 
#endif
#if defined(OS_MACOS)
#   include <stdio.h>
#   include <unistd.h>
#   include <string.h>
#   include <sys/time.h>
#endif
#if defined(OS_WIN)
#   include <windows.h>
#   include <stdio.h>
#endif

#include <libcam/util.h>
#include <libname.h>    //C pour CAM_LIBNAME, CAM_LIBVER

/*
 * Echange deux entiers pointes par a et b.
 */
void libcam_swap(int *a, int *b)
{
    register int t;
    t = *a;
    *a = *b;
    *b = t;
}


/*
 * Attente en millisecondes.
 */
void libcam_sleep(int ms)
{
#if defined(OS_LIN)
    usleep(ms * 1000);
#elif defined(OS_WIN)
    Sleep(ms);
#elif defined(OS_MACOS)
    usleep(ms * 1000);
#endif
}


/*
 * Sortie sur un port donne.
 */
void libcam_out(unsigned short a, unsigned char d)
{
#if defined(OS_WIN)
/* *INDENT-OFF* */
    _asm {
        mov dx, a 
        mov al, d 
        out dx, al
    }
/* *INDENT-ON* */
#elif defined(OS_LIN)
    outb(d, a);
#elif defined(OS_MACOS)
#endif
}


/*
 * Entree sur un port.
 */
unsigned char libcam_in(unsigned short a)
{
#if defined(OS_WIN)
/* *INDENT-OFF* */
    _asm {
        mov dx, a
        in al, dx
    }
    // ne pas mettre de return
/* *INDENT-ON* */
#elif defined(OS_LIN)
    return inb(a);
#elif defined(OS_MACOS)
	return 0;
#endif
}

unsigned short libcam_inw(unsigned short a)
{
#if defined(OS_WIN)
/* *INDENT-OFF* */
    _asm {
        mov dx, a
        in ax, dx
    }
    // ne pas mettre de return
/* *INDENT-ON* */
#elif defined(OS_LIN)
    return inw(a);
#elif defined(OS_MACOS)
	return 0;
#endif
}


// libcam_can_access_parport renvoie 1 si on peut acceder au port parallele, 0 sinon.
int libcam_can_access_parport()
{
#if defined(OS_LIN)
    if ( iopl(3) != 0 ) {
	return 0;
    }
#endif
    return 1;
}


/*
 * Blocage des interruptions. Attention, sous Linux un appel systeme retablit
 * les interruptions (acces memoire, printf, etc...).
 */
void libcam_bloquer()
{
#if defined(OS_LIN)
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
void libcam_debloquer()
{
#if defined(OS_LIN)
    AUDELA_STI();
#elif defined(OS_WIN)
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
int second = 0, minute = 0, hour = 0, day = 1, month = 1, year = 1970;
#if defined(OS_WIN)
    SYSTEMTIME time;
    int dayofweek;
#endif
#if defined(OS_LIN)
    int s1970;
    double jour, jd1970, jd;
    struct timeval nowdate;
    
#endif

    if ((clock_read_RTC(REGISTER_D) & MASK_BATTERY) == MASK_BATTERY) {

	// attendre la fin de la mise a jour
	while ((clock_read_RTC(REGISTER_A) & MASK_UIP) == MASK_UIP);

	// bloquer la mise a jour
	clock_write_RTC(REGISTER_B, clock_read_RTC(REGISTER_B) | MASK_UPDATE);
	if ((clock_read_RTC(REGISTER_B) & MASK_BCD) == MASK_BCD) {
	    // Mode binaire
	    second = clock_read_RTC(SECOND);
	    minute = clock_read_RTC(MINUTE);
	    hour = clock_read_RTC(HOUR);
	    day = clock_read_RTC(DAY);
#if defined(OS_WIN)
	    dayofweek = clock_read_RTC(DAYOFWEEK);
#endif
	    month = clock_read_RTC(MONTH);
	    year = clock_read_RTC(YEAR);
	    year += 100 * BCD2BIN(clock_read_RTC(CENTURY));
	} else {
	    // Mode BCD
	    second = BCD2BIN(clock_read_RTC(SECOND));
	    minute = BCD2BIN(clock_read_RTC(MINUTE));
	    hour = BCD2BIN(clock_read_RTC(HOUR));
	    day = BCD2BIN(clock_read_RTC(DAY));
#if defined(OS_WIN)
	    dayofweek = BCD2BIN(clock_read_RTC(DAYOFWEEK));
#endif
	    month = BCD2BIN(clock_read_RTC(MONTH));
	    year = BCD2BIN(clock_read_RTC(YEAR));
	    year += 100 * BCD2BIN(clock_read_RTC(CENTURY));
	}
	clock_write_RTC(REGISTER_B, clock_read_RTC(REGISTER_B) & ~MASK_UPDATE);	/* autoriser la mise a jour */
    }
#if defined(OS_WIN)
    GetLocalTime(&time);
    time.wSecond = (WORD) second;
    time.wMinute = (WORD) minute;
    time.wHour = (WORD) hour;
    time.wDay = (WORD) day;
    time.wDayOfWeek = (WORD) dayofweek;
    time.wMonth = (WORD) month;
    time.wYear = (WORD) year;
    SetLocalTime(&time);
#endif
#if defined(OS_LIN)
    /* date sour la forme du nombre de secondes ecoulees */
    /* depuis le 1er Janvier 1970 a 00h 00m 00s GMT */
    date_jd(1970, 1, 1.0, &jd1970);
    jour = (double) (day) + (double) (hour) / 24. + (double) (minute) / 1440. + (double) (second) / 86400.;
    date_jd(year, month, jour, &jd);
    s1970 = (int) ((jd - jd1970) * 86400.);
    nowdate.tv_usec = (int) 0;
    nowdate.tv_sec = (int) s1970;
    settimeofday(&nowdate, NULL);
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
    double a, m, j, aa, bb, jd;
    a = annee;
    m = mois;
    j = jour;
    if (m <= 2) {
	a = a - 1;
	m = m + 12;
    }
    aa = floor(a / 100);
    bb = 2 - aa + floor(aa / 4);
    jd = floor(365.25 * (a + 4716)) + floor(30.6001 * (m + 1)) + j + bb - 1524.5;
    *jj = jd;
}

unsigned char clock_read_RTC(int index)
{
    libcam_out(CTRL_RTC, (unsigned char) index);
    return libcam_in(DATA_RTC);
}

void clock_write_RTC(int index, int value)
{
    libcam_out(CTRL_RTC, (unsigned char) index);
    libcam_out(DATA_RTC, (unsigned char) value);
}

unsigned long libcam_getms()
/* --- utilitaire pour le drift scan ---*/
{
    unsigned long now;
#if defined(OS_LIN)
    struct timeval date;
    gettimeofday(&date, NULL);
    now = date.tv_sec * 1000 + date.tv_usec / 1000;
#elif defined(OS_WIN)
    now = (unsigned long) GetTickCount();
#elif defined(OS_MACOS)
    struct timeval date;
    gettimeofday(&date, NULL);
    now = date.tv_sec * 1000 + date.tv_usec / 1000;
#endif
    return now;
}

void test_out_time(unsigned short port, unsigned long nb_out, unsigned long shouldbezero)
{
    unsigned long muloop;
    for (muloop = 1; muloop <= nb_out; muloop++) {
	if (muloop > shouldbezero) {
	    libcam_out(port, 255);
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
    unsigned long micro1, muloop, muloop10, muloops[10];
    unsigned long t1, t2, t3;
    int sortie = 0, b;
    micro1 = 10;
    b = 0;
    while (sortie == 0) {
	t1 = libcam_getms();
	/* La boucle suivante est obligee d'etre effectuee */
	/* en entier meme si le compilateur optimise */
	for (muloop10 = 0, muloop = 0; muloop < micro1; muloop++) {
	    muloops[muloop10] = (unsigned long) (0);
	    if (++muloop10 > 9) {
		muloop10 = 0;
	    }
	}
	muloops[0] = libcam_getms();
	t2 = muloops[0];
	/* t3 : nombre de millisecondes pour effectuer n boucles */
	t3 = (t2 - t1);
	if (t3 < (unsigned long) 500) {
	    micro1 = (unsigned long) 10 *micro1;
	} else {
	    sortie = 1;
	    micro1 = micro1 / t3;
	    break;
	}
	if (b > 10) {
	    t3 = 1;
	    sortie = 1;
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
    unsigned long t1, t2, t3;
    unsigned long n;
    int sortie = 0, b;
    unsigned long x, xx, a[10];
    n = 100000;
    b = 0;
    while (sortie == 0) {
	b++;
	t1 = libcam_getms();
	/* La boucle suivante est obligee d'etre effectuee */
	/* en entier meme si le compilateur optimise */
	for (xx = 0, x = 0; x < n; x++) {
	    a[xx] = (unsigned long) (0);
	    if (++xx > 9) {
		xx = 0;
	    }
	}
	a[0] = libcam_getms();
	t2 = a[0];
	/* t3 : nombre de millisecondes pour effectuer n boucles */
	t3 = (t2 - t1);
	if (t3 < (unsigned long) 30) {
	    n = (unsigned long) 10 *n;
	} else {
	    sortie = 1;
	    break;
	}
	if (b > 10) {
	    t3 = 1;
	    sortie = 1;
	    break;
	}
    }
    /* nombre de microsecondes pour effectuer n boucles */
    t3 *= (unsigned long) 1000;
    /* nombre de boucles a effectuer pour 1 microseconde */
    return ((int) (n / t3 * 10));
}

void libcam_strupr(char *chainein, char *chaineout)
/***************************************************************************/
/* Fonction de mise en majuscules emulant strupr (pb sous unix)            */
/***************************************************************************/
{
    int len, k;
    char a;
    len = (int) strlen(chainein);
    for (k = 0; k <= len; k++) {
	a = chainein[k];
	if ((a >= 'a') && (a <= 'z')) {
	    chaineout[k] = (char) (a - 32);
	} else {
	    chaineout[k] = a;
	}
    }
}

void libcam_strlwr(char *chainein, char *chaineout)
/***************************************************************************/
/* Fonction de mise en minuscules emulant strupr (pb sous unix)            */
/***************************************************************************/
{
    int len, k;
    char a;
    len = (int) strlen(chainein);
    for (k = 0; k <= len; k++) {
	a = chainein[k];
	if ((a >= 'A') && (a <= 'Z')) {
	    chaineout[k] = (char) (a + 32);
	} else {
	    chaineout[k] = a;
	}
    }
}


/***************************************************************************/
/* Fonction de trace                                                       */
/***************************************************************************/
#include <time.h>               /* time, ftime, strftime, localtime */
#include <sys/timeb.h>          /* ftime, struct timebuffer */
// local variables
int debug_level = 0;
char logFileName[1024];

/*
 * char* getlogdate(char *buf, size_t size)
 *   Generates a FITS compliant string into buf representing the date at which
 *   this function is called. Returns buf.
 */
char *getlogdate(char *buf, size_t size)
{
#if defined(OS_WIN)
  #ifdef _MSC_VER
    /* cas special a Microsoft C++ pour avoir les millisecondes */
    struct _timeb timebuffer;
    time_t ltime;
    _ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
  #else
    struct time t1;
    struct date d1;
    getdate(&d1);
    gettime(&t1);
    sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d.%02d : ", d1.da_year,
        d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec,
        t1.ti_hund);
  #endif
#elif defined(OS_LIN)
    struct timeb timebuffer;
    time_t ltime;
    ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
#elif defined(OS_MACOS)
    struct timeval t;
    char message[50];
    char s1[27];
    gettimeofday(&t,NULL);
    strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime((const time_t*)(&t.tv_sec)));
    sprintf(s1,"%s.%02d : ",message,(t.tv_usec)/10000);
#else
    sprintf(s1,"[No time functions available]");
#endif

    return buf;
}

void libcam_log(int level, const char *fmt, ...)
{
   if (level <= debug_level) {
      FILE *f;
      char buf[100];

      va_list mkr;
      va_start(mkr, fmt);

      getlogdate(buf,100);
      f = fopen(logFileName,"at+");
      switch (level) {
      case LOG_ERROR:
         fprintf(f,"%s - %s(%s) <ERROR> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_WARNING:
         fprintf(f,"%s - %s(%s) <WARNING> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_INFO:
         fprintf(f,"%s - %s(%s) <INFO> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      case LOG_DEBUG:
         fprintf(f,"%s - %s(%s) <DEBUG> : ", buf, CAM_LIBNAME, CAM_LIBVER);
         break;
      }
      vfprintf(f,fmt, mkr);
      fprintf(f,"\n");
      va_end(mkr);
      fclose(f);
   }

}


