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

#ifndef __UTILH__
#define __UTILH__

/**********************************************************/
/* Constantes associees a la lecture de l'horloge interne */
/**********************************************************/
#define CTRL_RTC        0x70
#define DATA_RTC        0x71
#define SECOND          0x00
#define MINUTE          0x02
#define HOUR            0x04
#define DAY             0x07
#define DAYOFWEEK       0x06
#define MONTH           0x08
#define YEAR            0x09
#define CENTURY         0x32
#define REGISTER_A      0x0A
#define REGISTER_B      0x0B
#define REGISTER_C      0x0C
#define REGISTER_D      0x0D
#define MASK_UIP        0x80	/* 1 = Heure en cours d'actualisation */
#define MASK_12_24      0x02	/* 0 = 12 heures - 1 = 24 heures      */
#define MASK_BCD        0x04	/* 0 = BCD       - 1 = binaire        */
#define MASK_UPDATE     0x80	/* 1 = Actualiser l'heure             */
#define MASK_BATTERY    0x80	/* 0 = Batteries a plat               */
#define BCD2BIN(n)      (((n)>>4)*10 + ((n)&0x0F))


#ifdef __cplusplus
extern "C" {            /* Assume C declarations for C++ */
#endif  /* __cplusplus */

void libcam_swap(int *a, int *b);
void libcam_out(unsigned short a, unsigned char d);
unsigned char libcam_in(unsigned short a);
unsigned short libcam_inw(unsigned short a);
int libcam_can_access_parport();
void libcam_bloquer();
void libcam_debloquer();

void update_clock();
unsigned char clock_read_RTC(int index);
void clock_write_RTC(int index, int value);
void date_jd(int annee, int mois, double jour, double *jj);

unsigned long libcam_getms();
void libcam_sleep(int ms);
unsigned long loopsmicrosec();
unsigned long loopsmillisec();
void test_out_time(unsigned short port, unsigned long nb_out, unsigned long shouldbezero);

void libcam_strupr(char *chainein, char *chaineout);
void libcam_strlwr(char *chainein, char *chaineout);


/***************************************************************************/
/* Fonction de trace                                                       */
/***************************************************************************/
#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4
extern int debug_level;     // pour libcam.cpp TODO : remplacer l'access a cette variable laocal par une focntion
extern char logFileName[1024];
void libcam_log(int level, const char *fmt, ...);


#ifdef __cplusplus
}                       /* End of extern "C" { */
#endif  /* __cplusplus */



#endif
