/* util.h
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

#ifndef __UTILH__
#define __UTILH__

#ifdef __cplusplus
extern "C" {            /* Assume C declarations for C++ */
#endif  /* __cplusplus */

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
#define MASK_UIP        0x80    /* 1 = Heure en cours d'actualisation */
#define MASK_12_24      0x02    /* 0 = 12 heures - 1 = 24 heures      */
#define MASK_BCD        0x04    /* 0 = BCD       - 1 = binaire        */
#define MASK_UPDATE     0x80    /* 1 = Actualiser l'heure             */
#define MASK_BATTERY    0x80    /* 0 = Batteries a plat               */
#define BCD2BIN(n)      (((n)>>4)*10 + ((n)&0x0F))


void libtel_swap(int *a, int *b);
void libtel_out(unsigned short a, unsigned char d);
unsigned char libtel_in(unsigned short a);
void libtel_bloquer();
void libtel_debloquer();

void update_clock();
unsigned char clock_read_RTC(int index);
void clock_write_RTC(int index, int value);
void date_jd(int annee, int mois, double jour, double *jj);

unsigned long libtel_getms();
void libtel_sleep(int ms);
unsigned long loopsmicrosec();
unsigned long loopsmillisec();
void test_out_time(unsigned short port,unsigned long nb_out,unsigned long shouldbezero);

void libtel_strupr(char *chainein, char *chaineout);
void libtel_strlwr(char *chainein, char *chaineout);

#ifdef __cplusplus
}
#endif

#endif
