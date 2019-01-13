/* mc_cata1.c
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

/***************************************************************************/
/* MC : Utilitaire de meca celeste                                         */
/* Auteur : Alain Klotz                                                    */
/***************************************************************************/
/* Calculs utilitaires avec le catalogue Hipparcos                         */
/***************************************************************************/
#include "mc.h"

/* Equinox=2451545.00000 Epoch=2448349.06250 */
/*
          1         2         3         4         5         6         7         8         9        10         11        12        13        14       15         16        17       18        19         20        21        22        23        24        25        26        27        28       29        30        31         32        33        34        35        36
 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
H|           1| |00 00 00.22|+01 05 20.4| 9.10| |H|000.00091185|+01.08901332| |   3.54|   -5.20|   -1.88|  1.32|  0.74|  1.39|  1.36|  0.81| 0.32|-0.07|-0.11|-0.24| 0.09|-0.01| 0.10|-0.01| 0.01| 0.34|  0| 0.74|     1| 9.643|0.020| 9.130|0.019| | 0.482|0.025|T|0.55|0.03|L| | 9.2043|0.0020|0.017| 87| | 9.17| 9.24|       | | | |          | |  | 1| | | |  |   |       |     |     |    |S| | |224700|B+00 5077 |          |          |0.66|F5          |S 
0            1 2 3           4            5    6 7 8            9            10  11     12      13       14     15     16     17     18     19    20    21    22    23    24    25    26    27    28    29  30    31     32     33    34     35   36  37    38   39 40   41  42 43 44     45     46    47 48  49    50    51    525354 55        56 57 5859   
--------------
mc_readhip c:/d/meo/hip_main.dat
--------------
flags est une liste de bits
bit0 : =1 pour ne pas prendre les etoiles doubles (values[0]=0 toujours)
bit1 : =1 pour prendre une limite sur plx (values[1] en mas)
bit2 : =1 pour prendre une limite sur mura et mudec (values[2] en mas/yr)
bit3 : =1 pour inclure la magnitude < maglim_faint (values[3] mag)
bit4 : =1 pour inclure la magnitude > maglim_bright (values[4] mag)
bit5 : =1 pour inclure la declinaison < declim_max (values[5] deg)
bit6 : =1 pour inclure la declinaison > declim_min (values[6] deg)
*/

int mc_readhip(char *hip_main_file, char *bits, double *values, int *nstars, mc_cata_astrom *hips) {
   FILE *f;
   char ligne[1025];
   char temp1[100];
	double ra,dec,plx,mura,mudec,mag;
   int k,n,kr,id;
   /* --- read the WCS ascii file ---*/
	if (hips==NULL) {
		kr=0;
	} else {
		kr=1;
	}
	if (kr<2) {
		f=fopen(hip_main_file,"rt");
		if (f==NULL) {
			return 1;
		}
		k=0;
		while (feof(f)==0) {
			if (fgets(ligne,1024,f)==NULL) {
				continue;
			}
			if (strlen(ligne)>360) {
				if ((bits[0]=='1')&&(values[0]==0)) {
					n=346-346+1;
					strncpy(temp1,ligne+346,n);
					temp1[n]='\0';
					if (temp1[0]!=' ') {
						continue;
					}
				}
				n=13-2+1;
				strncpy(temp1,ligne+2,n);
				temp1[n]='\0';
				id=atoi(temp1);
				n=45-41+1;
				strncpy(temp1,ligne+41,n);
				temp1[n]='\0';
				mag=atof(temp1);
				n=62-51+1;
				strncpy(temp1,ligne+51,n);
				temp1[n]='\0';
				ra=atof(temp1);
				n=75-64+1;
				strncpy(temp1,ligne+64,n);
				temp1[n]='\0';
				dec=atof(temp1);
				n=85-79+1;
				strncpy(temp1,ligne+79,n);
				temp1[n]='\0';
				plx=atof(temp1);
				n=94-87+1;
				strncpy(temp1,ligne+87,n);
				temp1[n]='\0';
				mura=atof(temp1);
				n=103-96+1;
				strncpy(temp1,ligne+96,n);
				temp1[n]='\0';
				mudec=atof(temp1);
				if ((bits[1]=='1')&&(fabs(plx)>=values[1])) {
					continue;
				}
				if ((bits[2]=='1')&&((fabs(mura)>=values[2])||(fabs(mudec)>=values[2]))) {
					continue;
				}
				if ((bits[3]=='1')&&(mag>=values[3])) {
					continue;
				}
				if ((bits[4]=='1')&&(mag<=values[4])) {
					continue;
				}
				if ((bits[5]=='1')&&(dec>=values[5])) {
					continue;
				}
				if ((bits[6]=='1')&&(dec<=values[6])) {
					continue;
				}
				if (kr==1) {
					/* --- enregistre les donnees ---*/
					hips[k].id=id;
					hips[k].ra=ra;
					hips[k].dec=dec;
					hips[k].mag=mag;
					hips[k].plx=plx;
					hips[k].dec=dec;
					hips[k].mura=mura;
					hips[k].mudec=mudec;
				}
				k++;				
			}
		}
		fclose(f);
		*nstars=k;
	}
	return 0;
}
