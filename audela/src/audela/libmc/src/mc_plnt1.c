/* mc_plnt1.c
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
/* Calculs d'ephemerides precises des planetes, du Soleil ...              */
/***************************************************************************/
#include "mc.h"

void mc_jd2elem1(double jj, int planete, struct elemorb *elempla)
/***************************************************************************/
/* Retourne la valeur des elements de l'orbite d'une planete donnee pour jj*/
/***************************************************************************/
/***************************************************************************/
{
   double t,l0=0,l1=0,l2=0,l3=0,a0=0,a1=0,a2=0,a3=0,e0=0,e1=0,e2=0,e3=0;
   double   i0=0,i1=0,i2=0,i3=0,o0=0,o1=0,o2=0,o3=0,p0=0,p1=0,p2=0,p3=0;
   double l,a,e,i,o,p,n,m0;
   t=(jj-2451545.0)/36525.0;
   if (planete==TERRE) {
      /* --- equinoxe moyen ---*/
      l0=100.466449; l1=36000.7698231; l2=0.000030368; l3=0.000000021;
      a0=1.000001018;
      e0=0.01670862; e1=-0.000042037; e2=-0.0000001236; e3=0.00000000004;
      i0=0;
      p0=102.937348; p1=1.7195269; p2=0.00045962; p3=0.000000499;
   } else if (planete==JUPITER) {
      l0=34.351484; l1=3036.3027889; l2=0.00022374; l3=0.000000025;
      a0=5.202603191; a1=0.0000001913;
      e0=0.04849485; e1=0.000163244; e2=0.0000004719; e3=-0.00000000197;
      i0=1.303270; i1=-0.0054966; i2=0.00000465; i3=-0.000000004;
      o0=100.464441; o1=1.0209550; o2=0.00040117; o3=0.000000569;
      p0=14.331309; p1=1.6126668; p2=0.00103127; p3=-0.000004569;
   }
   l=l0+l1*t+l2*t*t+l3*t*t*t;
   a=a0+a1*t+a2*t*t+a3*t*t*t;
   e=e0+e1*t+e2*t*t+e3*t*t*t;
   i=i0+i1*t+i2*t*t+i3*t*t*t;
   o=o0+o1*t+o2*t*t+o3*t*t*t;
   p=p0+p1*t+p2*t*t+p3*t*t*t;
   m0=fmod((l-p)*DR,2*PI);
   n=K/(DR)/a/sqrt(a);
   /* m(jj)=(jj-jj_perihelie)*n*DR  */
   /* m(jj)=m0 dans notre cas       */
   elempla->m0=m0;
   elempla->jj_m0=jj;
   elempla->e=e;
   elempla->q=a*(1-e); /* toujours elliptique */
   elempla->jj_perihelie=jj-m0/n/(DR);
   elempla->jj_epoque=jj;
   elempla->i=fmod(i*DR,2*PI);
   elempla->o=fmod(o*DR,2*PI);
   elempla->w=fmod((p-o)*DR,2*PI);
   elempla->jj_equinoxe=jj;
}

void mc_jd2lbr1a(double jj, double *l, double *m, double *u)
/***************************************************************************/
/* Retourne les valeurs des tableaux L, M, U necessaires pour tenir        */
/* compte des principales perturbations planetaires a entrer dans          */
/* la fonction mc_jd2lbr1b                                                 */
/***************************************************************************/
/* Les tableaux *l, *m et *u doivent etre dimensiones chacun avec          */
/* 9 elements (0 a 8)                                                      */
/***************************************************************************/
{
   double t;
   t=(jj-2451545.0);
   /*
   l[0]=(0.779072+0.00273790931*t)*360.*DR;
   m[0]=(0.993126+0.00273777850*t)*360.*DR;
   u[0]=(0.606434+0.03660110129*t)*360.*DR; 
   */
   /* Lune */
   /*
   l[1]=(0.700695+0.01136771400*t)*360.*DR;
   m[1]=(0.485541+0.01136759566*t)*360.*DR;
   u[1]=(0.566441+0.01136762384*t)*360.*DR;
   l[2]=(0.505498+0.00445046867*t)*360.*DR;
   m[2]=(0.140023+0.00445036173*t)*360.*DR;
   u[2]=(0.292498+0.00445040017*t)*360.*DR;
   l[3]=(0.987353+0.00145575328*t)*360.*DR;
   m[3]=(0.053856+0.00145561327*t)*360.*DR;
   u[3]=(0.849694+0.00145569465*t)*360.*DR;
   l[4]=(0.089608+0.00023080893*t)*360.*DR;
   m[4]=(0.056531+0.00023080893*t)*360.*DR;
   u[4]=(0.814794+0.00023080893*t)*360.*DR;
   l[5]=(0.133295+0.00009294371*t)*360.*DR;
   m[5]=(0.882987+0.00009294371*t)*360.*DR;
   u[5]=(0.821218+0.00009294371*t)*360.*DR;
   l[6]=(0.870169+0.00003269438*t)*360.*DR;
   m[6]=(0.400589+0.00003269438*t)*360.*DR;
   u[6]=(0.664614+0.00003265562*t)*360.*DR;
   l[7]=(0.846912+0.00001672092*t)*360.*DR;
   m[7]=(0.725368+0.00001672092*t)*360.*DR;
   u[7]=(0.480856+0.00001663715*t)*360.*DR;
   l[8]=(0.663854+0.00001115482*t)*360.*DR;
   m[8]=(0.041020+0.00001104864*t)*360.*DR;
   u[8]=(0.357355+0.00001104864*t)*360.*DR;
*/
   
   t=(jj-2415020.0)/36525;
   l[0]=(279.6964027+36000.7695173*t)*DR;
   m[0]=(358.4758635+35999.0494965*t)*DR;
   u[0]=(270.435377+481267.880863*t)*DR; /*lune*/
   l[1]=(178.178814+149474.071386*t)*DR;
   m[1]=(102.279426+149472.515334*t)*DR;
   u[1]=(131.032888+149472.885872*t)*DR;
   l[2]=(342.766738+58519.212542*t)*DR;
   m[2]=(212.601892+58517.806388*t)*DR;
   u[2]=(266.987445+58518.311835*t)*DR;
   l[3]=(293.747201+19141.699879*t)*DR;
   m[3]=(319.529273+19139.858887*t)*DR;
   u[3]=(244.960887+19140.928953*t)*DR;
   l[4]=(237.352259+3034.906621*t)*DR;
   m[4]=(225.444539+3034.906621*t)*DR;
   u[4]=(138.419219+3034.906621*t)*DR;
   l[5]=(265.869357+1222.116843*t)*DR;
   m[5]=(175.758477+1222.116843*t)*DR;
   u[5]=(153.521637+1222.116843*t)*DR;
   l[6]=(243.362437+429.898403*t)*DR;
   m[6]=( 74.313637+429.898403*t)*DR;
   u[6]=(169.872293+429.388747*t)*DR;
   l[7]=( 85.024943+219.863377*t)*DR;
   m[7]=( 41.269103+219.863377*t)*DR;
   u[7]=(314.346275+218.761885*t)*DR;
   l[8]=( 92.312712+146.674728*t)*DR;
   m[8]=(229.488633+145.278567*t)*DR;
   u[8]=(343.369233+145.278567*t)*DR;

}

