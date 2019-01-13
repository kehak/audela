/* mc_plnt4.c
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

void mc_jd2lbr1e(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0)
/***************************************************************************/
/* Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr  */
/* pour l'equinoxe moyen de la date. (longitudes vraies)                   */
/* SATURNE                                                                 */
/***************************************************************************/
/* Les tableaux l, m et u doivent etre dimensiones chacun avec             */
/* 9 elements (0 a 8) et sont initialises dans la fonction mc_jd2lbr1a     */
/***************************************************************************/
{
   double t,l0,b0,r0;
   u[0]*=1.;
   t=(jj-2415020.0)/36525;
      l0=2507+5014*t+23043*sin(m[5])-2689*cos(2*m[4]-5*m[5])+1177*sin(2*m[4]-5*m[5])-826*cos(2*m[4]-4*m[5])+802*sin(2*m[5])+425*sin(m[4]-2*m[5])-229*t*cos(m[5])-142*t*sin(m[5])-153*cos(2*m[4]-6*m[5])-114*cos(m[5])+101*t*sin(2*m[4]-5*m[5]);
      l0+=-70*cos(2*l[5])+67*sin(2*l[5])+66*sin(2*m[4]-6*m[5])+60*t*cos(2*m[4]-5*m[5])+41*sin(m[4]-3*m[5])+39*sin(3*m[5])+31*sin(m[4]-m[5])+31*sin(2*m[4]-2*m[5])-29*cos(2*m[4]-3*m[5])-28*sin(2*m[4]-6*m[5]+3*m[6])+28*cos(m[4]-3*m[5]);
      l0+=+22*t*sin(2*m[4]-4*m[5])-22*sin(m[5]-3*m[6])+20*sin(2*m[4]-3*m[5])+20*cos(4*m[4]-10*m[5])+19*cos(2*m[5]-3*m[6])+19*sin(4*m[4]-10*m[5])-17*t*cos(2*m[5])-16*cos(m[5]-3*m[6])-12*sin(2*m[4]-4*m[5])+12*cos(m[4]);
      l0+=-12*sin(2*m[5]-2*m[6])-11*t*sin(2*m[5])-11*cos(2*m[4])-12*sin(2*m[5]-2*m[6])-11*t*sin(2*m[5])-11*cos(2*m[4]-7*m[5])+10*sin(2*m[5]-3*m[6])+10*cos(2*m[4]-2*m[5])+9*sin(4*m[4]-9*m[5])-8*sin(m[5]-2*m[6])-8*cos(2*l[5]+m[5]);
      l0+=+8*cos(2*l[5]-m[5])+8*cos(m[5]-m[6])-8*sin(2*l[5]-m[5])+7*sin(2*l[5]+m[5])-7*cos(m[4]-2*m[5])-7*cos(2*m[5])-6*t*sin(4*m[4]-10*m[5])+6*t*cos(4*m[4]-10*m[5])+6*t*(2*m[4]-6*m[5])-5*sin(3*m[4]-7*m[5])-5*cos(3*m[4]-3*m[5]);
      l0+=-5*cos(2*m[5]-2*m[6])+5*sin(3*m[4]-4*m[5])+5*sin(2*m[4]-7*m[5])+4*sin(3*m[4]-3*m[5])+4*sin(3*m[4]-5*m[5])+4*t*cos(m[4]-3*m[5])+3*t*cos(2*m[4]-4*m[5])+3*cos(2*m[4]-6*m[5]+3*m[6])-3*t*sin(2*l[5]);
      l0+=+3*t*cos(2*m[4]-6*m[5])-3*t*cos(2*l[5])+3*cos(3*m[4]-7*m[5])+3*cos(4*m[4]-9*m[5])+3*sin(3*m[4]-6*m[5])+3*sin(2*m[4]-m[5])+3*sin(m[4]-4*m[5])+2*cos(3*m[5]-3*m[6])+2*t*sin(m[4]-2*m[5])+2*sin(4*m[5])-2*cos(3*m[4]-4*m[5])-2*cos(2*m[4]-m[5]);
      l0+=-2*sin(2*m[4]-7*m[5]+3*m[6])+2*cos(m[4]-4*m[5])+2*cos(4*m[4]-11*m[5])-2*sin(m[5]-m[6]);
      l0=l[5]+l0/3600*DR;
      b0=185+8297*sin(m[5])-3346*cos(m[5])+462*sin(2*m[5])-189*cos(2*m[5])+79*t*cos(m[5])-71*cos(2*m[4]-4*m[5])+46*sin(2*m[4]-6*m[5])-45*cos(2*m[4]-6*m[5])+29*sin(3*m[5])-20*cos(2*m[4]-3*m[5])+18*t*sin(m[5]);
      b0+=-14*cos(2*m[4]-5*m[5])-11*cos(3*m[5])-10*t+9*sin(m[4]-3*m[5])+8*sin(m[4]-m[5])-6*sin(2*m[4]-3*m[5])+5*sin(2*m[4]-7*m[5])-5*cos(2*m[4]-7*m[5])+4*sin(2*m[4]-5*m[5])-4*t*sin(2*m[5])-4*cos(m[4]-m[5])+3*cos(m[4]-3*m[5])+3*t*sin(2*m[4]-4*m[5]);
      b0+=+3*sin(m[4]-2*m[5])+2*sin(4*m[5])-2*cos(2*m[4]-2*m[5]);
      b0=b0/3600*DR;
      r0=9.55774-.00028*t-.53252*cos(m[5])-.01878*sin(2*m[4]-4*m[5])-.01482*cos(2*m[5])+.00817*sin(m[4]-m[5])-.00539*cos(m[4]-2*m[5])-.00524*t*sin(m[5])+.00349*sin(2*m[4]-5*m[5])+.00347*sin(2*m[4]-6*m[5]);
      r0+=+.00328*t*cos(m[5])-.00225*sin(m[5])+.00149*cos(2*m[4]-6*m[5])-.00126*cos(2*m[4]-2*m[5])+.00104*cos(m[4]-m[5])+.00101*cos(2*m[4]-5*m[5])+.00098*cos(m[4]-3*m[5])-.00073*cos(2*m[4]-3*m[5])-.00062*cos(3*m[5]);
      r0+=+.00043*sin(2*m[5]-3*m[6])+.00041*sin(2*m[4]-2*m[5])-.00040*sin(m[4]-3*m[5])+.0004*cos(2*m[4]-4*m[5])-.00023*sin(m[4])+.0002*sin(2*m[4]-7*m[5]);
   *ll0=l0;
   *bb0=b0;
   *rr0=r0;
}

void mc_jd2lbr1f(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0)
/***************************************************************************/
/* Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr  */
/* pour l'equinoxe moyen de la date. (longitudes vraies)                   */
/* URANUS                                                                  */
/***************************************************************************/
/* Les tableaux l, m et u doivent etre dimensiones chacun avec             */
/* 9 elements (0 a 8) et sont initialises dans la fonction mc_jd2lbr1a     */
/***************************************************************************/
{
   double t,l0,b0,r0;
   u[0]*=1.;
   t=(jj-2415020.0)/36525;
      l0=32*t*t+19397*sin(m[6])+570*sin(2*m[6])-536*t*cos(m[6])+143*sin(m[5]-2*m[6])+110*t*sin(m[6])+102*sin(m[5]-3*m[6])+76*cos(m[5]-3*m[6])-49*sin(m[4]-m[6])-30*t*cos(2*m[6])+29*sin(2*m[4]-6*m[5]+3*m[6])+29*cos(2*m[6]-2*m[7]);
      l0+=-28*cos(m[6]-m[7])+23*sin(3*m[6])-21*cos(m[4]-m[6])+20*sin(m[6]-m[7])+20*cos(m[5]-m[6])-12*t*t*cos(m[6])-12*cos(m[6])+10*sin(2*m[6]-2*m[7])-9*sin(2*u[6])-9*t*t*sin(m[6])+9*cos(2*m[6]-3*m[7])+8*t*cos(m[5]-2*m[6]);
      l0+=+7*t*cos(m[5]-3*m[6])-7*t*sin(m[5]-3*m[6])+7*t*sin(2*m[6])+6*sin(2*m[4]-6*m[5]+2*m[6])+6*cos(2*m[4]-6*m[5]+2*m[6])+5*sin(m[5]-4*m[6])-4*sin(3*m[6]-4*m[7])+4*cos(3*m[6]-3*m[7])-3*cos(m[7])-2*sin(m[7]);
      l0=l[6]+l0/3600*DR;
      b0=2775*sin(u[6])+131*sin(m[6]-u[6])+130*sin(m[6]+u[6]);
      b0=b0/3600*DR;
      r0=19.21216-.90154*cos(m[6])-.02488*t*sin(m[6])-.02121*cos(2*m[6])-.00585*cos(m[5]-2*m[6])-.00508*t*cos(m[6])-.00451*cos(m[4]-m[6])+.00336*sin(m[5]-m[6])+.00198*sin(m[4]-m[6])+.00118*cos(m[5]-3*m[6])+.00107*sin(m[5]-2*m[6]);
      r0+=-.00103*t*sin(2*m[6])-.00081*cos(3*m[6]-3*m[7]);
   *ll0=l0;
   *bb0=b0;
   *rr0=r0;
}

void mc_jd2lbr1g(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0)
/***************************************************************************/
/* Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr  */
/* pour l'equinoxe moyen de la date. (longitudes vraies)                   */
/* NEPTUNE                                                                 */
/***************************************************************************/
/* Les tableaux l, m et u doivent etre dimensiones chacun avec             */
/* 9 elements (0 a 8) et sont initialises dans la fonction mc_jd2lbr1a     */
/***************************************************************************/
{
   double t,l0,b0,r0;
   u[0]*=1.;
   t=(jj-2415020.0)/36525;
      l0=3523*sin(m[7])-50*sin(2*u[7])-43*t*cos(m[7])+29*sin(m[4]-m[7])+19*sin(2*m[7])-18*cos(m[4]-m[7])+13*cos(m[5]-m[7])+13*sin(m[5]-m[7])-9*sin(2*m[6]-3*m[7])+9*cos(2*m[6]-2*m[7])-5*cos(2*m[6]-3*m[7]);
      l0+=-4*t*sin(m[7])+4*cos(m[6]-2*m[7])+4*t*t*sin(m[7]);
      l0=l[7]+l0/3600*DR;
      b0=6404*sin(u[7])+55*sin(m[7]+u[7])+55*sin(m[7]-u[7])-33*t*sin(u[7]);
      b0=b0/3600*DR;
      r0=30.07175-.22701*cos(m[7])-.00787*cos(2*l[6]-m[6]-2*l[7])+.00409*cos(m[4]-m[7])-.00314*t*sin(m[7])+.0025*sin(m[4]-m[7])-.00194*sin(m[5]-m[7])+.00185*cos(m[5]-m[7]);
   *ll0=l0;
   *bb0=b0;
   *rr0=r0;
}

void mc_jd2lbr1h(double jj, double *l, double *m, double *u, double *ll0, double *bb0, double *rr0)
/***************************************************************************/
/* Retourne les valeurs de longitude *ll, latitude *bb, rayon vecteur *rr  */
/* pour l'equinoxe J2000. ()                                               */
/* PLUTON                                                                  */
/***************************************************************************/
/* Les tableaux l, m et u doivent etre dimensiones chacun avec             */
/* 9 elements (0 a 8) et sont initialises dans la fonction mc_jd2lbr1a     */
/* mais ne servent a rien car on se sert de l'algo de Meeus                */
/* Astronomical Algorithms page 247                                        */
/***************************************************************************/
{
   double t,l0,b0,r0,j,s,p,a,A,B,sina,cosa;
   int ij,is,ip,k;
   int meeus[43*10]={
   1,0,0,1,-19798886,19848454,-5453098,-14974876,66867334,68955876,
   2,0,0,2,897499,-4955707,3527363,1672673,-11826086,-333765,
   3,0,0,3,610820,1210521,-1050939,327763,1593657,-1439953,
   4,0,0,4,-341639,-189719,178691,-291925,-18948,482443,
   5,0,0,5,129027,-34863,18763,100448,-66634,-85576,
   6,0,0,6,-38215,31061,-30594,-25838,30841,-5765,
   7,0,1,-1,20349,-9886,4965,11263,-6140,22254,
   8,0,1,0,-4045,-4904,310,-132,4434,4443,
   9,0,1,1,-5885,-3238,2036,-947,-1518,641,
   10,0,1,2,-3812,3011,-2,-674,-5,792,
   11,0,1,3,-601,3468,-329,-563,518,518,
   12,0,2,-2,1237,463,-64,39,-13,-221,
   13,0,2,-1,1086,-911,-94,210,837,-494,
   14,0,2,0,595,-1229,-8,-160,-281,616,
   15,1,-1,0,2484,-485,-177,259,260,-395,
   16,1,-1,1,839,-1414,17,234,-191,-396,
   17,1,0,-3,-964,1059,582,-285,-3218,370,
   18,1,0,-2,-2303,-1038,-298,692,8019,-7869,
   19,1,0,-1,7049,747,157,201,105,45637,
   20,1,0,0,1179,-358,304,825,8623,8444,
   21,1,0,1,393,-63,-124,-29,-896,-801,
   22,1,0,2,111,-268,15,8,208,-122,
   23,1,0,3,-52,-154,7,15,-133,65,
   24,1,0,4,-78,-30,2,2,-16,1,
   25,1,1,-3,-34,-26,4,2,-22,7,
   26,1,1,-2,-43,1,3,0,-8,16,
   27,1,1,-1,-15,21,1,-1,2,9,
   28,1,1,0,-1,15,0,-2,12,5,
   29,1,1,1,4,7,1,0,1,-3,
   30,1,1,3,1,5,1,-1,1,0,
   31,2,0,-6,8,3,-2,-3,9,5,
   32,2,0,-5,-3,6,1,2,2,-1,
   33,2,0,-4,6,-13,-8,2,14,10,
   34,2,0,-3,10,22,10,-7,-65,12,
   35,2,0,-2,-57,-32,0,21,126,-233,
   36,2,0,-1,157,-46,8,5,270,1068,
   37,2,0,0,12,-18,13,16,254,155,
   38,2,0,1,-4,8,-2,-3,-26,-2,
   39,2,0,2,-5,0,0,0,7,0,
   40,2,0,3,3,4,0,1,-11,4,
   41,3,0,-2,-1,-1,0,0,4,-14,
   42,3,0,-1,6,-3,0,0,18,35,
   43,3,0,0,-1,-2,0,1,13,3};
   u[0]*=1.;
   /*
   t=(jj-2415020.0)/36525;
      l0=101557*sin(m[8])+15517*sin(2*m[8])-3593*sin(2*u[8])+3414*sin(3*m[8])-2101*sin(m[8]-2*u[8])-1871*sin(m[8]+2*u[8])+839*sin(4*m[8])-757*sin(2*m[8]+2*u[8])-285*sin(3*m[8]+2*u[8])+227*t*t*sin(m[8])+218*sin(2*m[8]-2*u[8])+200*t*sin(m[8]);
      l0=l[8]+l0/3600*DR;
      b0=57726*sin(u[8])+15257*sin(m[8]-u[8])+14102*sin(m[8]+u[8])+3870*sin(2*m[8]+u[8])+1138*sin(3*m[8]+u[8])+472*sin(2*m[8]-u[8])+353*sin(4*m[8]+u[8])-144*sin(m[8]-3*u[8])-119*sin(3*u[8])-111*sin(m[8]+3*u[8]);
      b0=b0/3600*DR;
      r0=40.74638-9.58235*cos(m[8])-1.16703*cos(2*m[8])-0.22649*cos(3*m[8])-.04996*cos(4*m[8]);
   *ll0=l0;
   *bb0=b0;
   *rr0=r0;
   */
   t=(jj-2451545.0)/36525;
   j=34.35+3034.9057*t;
   s=50.08+1222.1138*t;
   p=238.96+144.9600*t;
   l0=0.;
   b0=0.;
   r0=0.;
   for (k=0;k<43;k++) {
      ij=meeus[k*10+1];
      is=meeus[k*10+2];
      ip=meeus[k*10+3];
	  a=(DR)*(j*ij+s*is+p*ip);
	  sina=sin(a);
	  cosa=cos(a);
      A=meeus[k*10+4];
      B=meeus[k*10+5];
      l0+=(double)(A*sina+B*cosa);
      A=meeus[k*10+6];
      B=meeus[k*10+7];
      b0+=(double)(A*sina+B*cosa);
      A=meeus[k*10+8];
      B=meeus[k*10+9];
      r0+=(double)(A*sina+B*cosa);
   }
   l0=(238.956785+144.96*t+l0*1e-6)*DR;
   b0=(-3.908202+b0*1e-6)*DR;
   r0=40.7247248+r0*1e-7;
   *ll0=l0;
   *bb0=b0;
   *rr0=r0;
}


