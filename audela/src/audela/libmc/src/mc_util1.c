/* mc_util1.c
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
/* Utilitaires de petits calculs astro (magnitudes, elongation ...)        */
/***************************************************************************/
#include "mc.h"

/****************************************************************************/
/* Quick sort.                                                              */
/****************************************************************************/
/**	Tools to sort an array of (double)
 * @param arr contains the array of (double) to sort.
 * @param low is the first index of the array.
 * @param high is the last index of the array.
 * @param karr contains the array of (int) of indexes to sort.
*/
/****************************************************************************/
void mc_quicksort_double(double *arr, int low, int high, int *karr) {
   double y;
   int i,j;
   double z;
   int ky;
   y=0.;
   i=low;
   j=high;
   /* compare value */
   z = arr[(low + high) / 2];
   /* partition */
   do {
      /* find member above ... */
      while(arr[i] < z) i++;
      /* find element below ... */
      while(arr[j] > z) j--;
      if(i <= j) {
         /* swap two elements */
         y = arr[i];
         arr[i] = arr[j];
         arr[j] = y;
         if (karr!=NULL) {
            ky = karr[i];
            karr[i] = karr[j];
            karr[j] = ky;
         }
         i++;
         j--;
      }
   } while(i <= j);
   /* recurse */
   if(low < j) {
      mc_quicksort_double(arr, low, j, karr);
   }
   if(i < high) {
      mc_quicksort_double(arr, i, high, karr);
   }
}

void mc_elonphaslimb(double asd, double dec, double asds, double decs, double r, double delta, double *elong, double *phase, double *posang_brightlimb)
/***************************************************************************/
/* Calcul des angles d'elongation de phase et de position du limbe.        */
/***************************************************************************/
/* Meeus page 316 (46.2) (46.3) (46.5)                                     */
/* asd,dec : planete.                                                      */
/* asds,decs : soleil                                                      */
/* r : distance Terre-Soleil (corrigee de l'abberation).                   */
/* delta : distance Terre-Planete (corrigee de l'abberation).              */
/***************************************************************************/
{
    double i;
    *elong=0.;
	*phase=0.;
    *elong=mc_acos(sin(decs)*sin(dec)+cos(decs)*cos(dec)*cos(asds-asd));
    i=mc_atan2(r*sin(*elong),delta-r*cos(*elong));
    if (i<0) {
       i=i+PI;
    }
    *phase=i;
    i=mc_atan2(cos(decs)*sin(asds-asd),sin(decs)*cos(dec)-cos(decs)*sin(dec)*cos(asds-asd));
    if (i<0) {
       i=2*PI+i;
    }
    *posang_brightlimb=fmod(4*PI+i,2*PI);
}

void mc_elonphas(double r, double rsol, double delta, double *elong, double *phase)
/***************************************************************************/
/* Calcul des angles d'elongation et de phase.                             */
/***************************************************************************/
/***************************************************************************/
{
    *elong=0.;
	*phase=0.;
	if (delta!=0.) {
      if (rsol!=0.) {
         *elong=mc_acos((rsol*rsol+delta*delta-r*r)/(2*rsol*delta));
	  }
	  if (r!=0.) {
         *phase=mc_acos((r*r+delta*delta-rsol*rsol)/(2*r   *delta));
	  }
   }
}

void mc_magaster(double r, double delta, double phase, double h, double g, double *mag)
/***************************************************************************/
/* Calcule la magnitude d'un asteroide a partir de H, G et la phase        */
/***************************************************************************/
/***************************************************************************/
{
   double phi1,phi2,tanb,argu;
   tanb=tan(phase/2);
   phi1=exp(-3.33*pow(tanb,0.63));
   phi2=exp(-1.87*pow(tanb,1.22));
   argu=(1-g)*phi1+g*phi2;
   if (argu<1e-15) {
      argu=1e-15;
   }
   *mag=h+5*log(r*delta)/log(10)-2.5*log(argu)/log(10);
}

void mc_magplanet(double r,double delta,int planete,double phase,double l,double b,double *mag,double *diamapp)
/***************************************************************************/
/* Calcule la magnitude d'une planete                                      */
/***************************************************************************/
/* Meuus page 269 et 302-303 pour Saturne								   */
/***************************************************************************/
{
   double i,o,n,bb,lp,bp,u1,u2;
   i=phase/(DR);
   *mag=0.;
   *diamapp=0.;
   if (r==0.) {r=1e-10;}
   if (delta==0.) {delta=1e-10;}
   if (r*delta>0) {
      *mag=5*log10(r*delta);
	  if (planete==SOLEIL) {
	     *mag=2.5*log10(delta);
	  }
   }
   if (planete==MERCURE) { *mag+=(-0.42+.0380*i-.000273*i*i+.000002*i*i*i); *diamapp=2.*atan(1.6303e-5/delta); }
   else if (planete==VENUS) { *mag+=(-4.40+.0009*i+.000239*i*i-.00000065*i*i*i); *diamapp=2.*atan(4.0455e-5/delta); }
   else if (planete==MARS) { *mag+=(-1.52+.016*i); *diamapp=2.*atan(2.2694e-5/delta);}
   else if (planete==JUPITER) { *mag+=(-9.40+.005); *diamapp=2.*atan(4.7741e-4/delta);}
   else if (planete==URANUS) { *mag+=(-7.19); *diamapp=2.*atan(1.6979e-4/delta);}
   else if (planete==NEPTUNE) { *mag+=(-6.87); *diamapp=2.*atan(1.6243e-4/delta);}
   else if (planete==PLUTON) { *mag+=(-1.00); *diamapp=2.*atan(1.5608e-5/delta);}
   else if (planete==SOLEIL) { *mag+=(-26.86); *diamapp=2.*atan(4.6541e-3/delta); }
   else if ((planete==LUNE)||(planete==LUNE_ELP)) { *mag+=(0.38+2.97*(i/100.)-0.78*(i/100.)*(i/100.)+.90*(i/100.)*(i/100.)*(i/100.)); *diamapp=2.*atan(1.1617e-5/delta); }
   else if (planete==SATURNE) {
      i=28.08*(DR);
	  o=169.51*(DR);
	  n=113.67*(DR);
	  bb=asin(sin(i)*cos(b)*sin(l-o)-cos(i)*sin(b));
	  lp=l-(.01759/r)*(DR);
	  bp=b-(.000764*cos(l-n)/r)*(DR);
	  u1=atan2(sin(i)*sin(bp)+cos(i)*cos(bp)*sin(lp-o),cos(bp)*cos(lp-o));
	  u2=atan2(sin(i)*sin(b)+cos(i)*cos(b)*sin(l-o),cos(b)*cos(l-o));
	  bb=sin(fabs(bb));
      *mag+=(-8.68+.044*fabs(u1-u2)/(DR)-2.60*bb+1.25*bb*bb);
	  *diamapp=2.*atan(4.0395e-4/delta);
   }
}


void mc_magcomete(double r, double delta, double h0, double n, double *mag)
/***************************************************************************/
/* Calcule la magnitude d'une comete a partir de h0 et n.                  */
/***************************************************************************/
/***************************************************************************/
{
   *mag=h0+5*log(delta)/log(10)+n*log(r)/log(10);
}

void mc_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle)
/***************************************************************************/
/* Calcul de l'angle de separation et de l'angle de position au pole nord  */
/* a partir de deux coordonnees spheriques.                                */
/***************************************************************************/
/***************************************************************************/
{
   double a,b,c,aa,d3,a3;
   d3=PI/2;
   a3=0;
   a=(sin(d2)*sin(d3)+cos(d2)*cos(d3)*cos(a2-a3));
   if (a<-1.) {a=-1.;}
   if (a>1.) {a=1.;}
   a=acos(a);
   b=(sin(d1)*sin(d3)+cos(d1)*cos(d3)*cos(a1-a3));
   if (b<-1.) {b=-1.;}
   if (b>1.) {b=1.;}
   b=acos(b);
   c=(sin(d1)*sin(d2)+cos(d1)*cos(d2)*cos(a1-a2));
   if (c<-1.) {c=-1.;}
   if (c>1.) {c=1.;}
   c=acos(c);
   if (b*c!=0.) {
      aa=((cos(a)-cos(b)*cos(c))/(sin(b)*sin(c)));
      aa=(aa>1)?1.:aa;
      aa=(aa<-1)?-1.:aa;
      aa=acos(aa);
      if (sin(a2-a1)<0) {
         aa=-aa;
      }
      aa=fmod(aa+4*PI,2*PI);
   } else {
	  aa=0.;
   }
   *dist=c;
   *posangle=aa;
}

void mc_libration(double jj,int planete,double longmpc,double rhocosphip,double rhosinphip,double *lonc, double *latc, double *p,double *lons, double *lats)
/***************************************************************************/
/* Calcul de la libration apparentes de la Lune a jj donne.                */
/***************************************************************************/
/* D'apres Meeus "Astronomical Algorithms" p341-347                        */
/* lonc : longitude selenographique du centre topocentrique                */
/* latc : latitude selenographique du centre topocentrique                 */
/* p    : position de l'angle de l'axe de rotation (axe des poles)         */
/* lons : longitude selenographique du centre heliocentrique               */
/* lats : latitude selenographique du centre heliocentrique                */
/***************************************************************************/
{
   double asd,dec,delta,mag,diamapp,elong,phase,rr;
   double eps,deps,dpsi;
   double xeq,yeq,zeq,xec,yec,zec,r;
   double equinoxe=J2000,T,d,m,mp,f,e,o,i;
   double w,a,lp,bp;
   double k1,k2,rho,tau,sigma,lpp,bpp;
   double ls,bs,l,b;
   double v,x,y;
   double diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north;
   double long1_sun,lati_sun,jjutc;
	int astrometric=1;

   /* --- nutation ---*/
   mc_obliqmoy(jj,&eps);
   mc_nutation(jj,1,&dpsi,&deps);
   eps+=deps;
   /* --- Moon arguments ---*/
   T=(jj-2451545.)/36525.;
   d=(297.8502042+445267.1115168*T-.00016300*T*T+T*T*T/545868-T*T*T*T/113065000)*(DR);
   m=(357.5291092+35999.0502909*T-.0001536*T*T+T*T*T*T/24490000)*(DR);
   mp=(134.9634114+477198.8676313*T+.0089970*T*T+T*T*T/69699.-T*T*T*T/14712000)*(DR);
   f=(93.2720993+483202.0175273*T-.0034029*T*T+T*T*T/3526000+T*T*T*T/863310000)*(DR);
   e=1-.002516*T-.0000074*T*T;
   f=(93.2720993+483202.0175273*T-.0034029*T*T+T*T*T/3526000+T*T*T*T/863310000)*(DR);
   o=(125.0445550-1934.1361849*T+0.0020762*T*T+T*T*T/467410.-T*T*T*T/60616000.)*(DR);
   i=1.54242*(DR);
   f=fmod(4*PI+f,2*PI);
   /* --- parameters of physical libration ---*/
   k1=(119.75+131.849*T)*(DR);
   k2=(72.56+20.186*T)*(DR);
   rho=-0.02752*cos(mp)-0.02245*sin(f)+0.00684*cos(mp-2*f)-0.00293*cos(2*f)-0.00085*cos(2*f-2*d);
   rho=rho-0.00054*cos(mp-2*d)-0.00020*cos(mp+f)-0.00020*cos(mp+2*f)-0.00020*cos(mp-f);
   rho=rho+0.00014*cos(mp+2*f-2*d);
   sigma=-0.02816*sin(mp)+0.02244*cos(f)-0.00682*sin(mp-2*f)-0.00279*sin(2*f)-0.00083*sin(2*f-2*d);
   sigma=sigma+0.00069*sin(mp-2*d)+0.00040*cos(mp+f)-0.00025*sin(2*mp);
   sigma=sigma-0.00023*sin(mp+2*f)+0.00020*cos(mp-f)+0.00019*sin(mp-f)+0.00013*sin(mp+2*f-2*d);
   sigma=sigma-0.00010*cos(mp-3*f);
   tau=0.02520*e*sin(m)+0.00473*sin(2*mp-2*f)-0.00467*sin(mp)+0.00396*sin(k1)+0.00276*sin(2*mp-2*d);
   tau=tau+0.00196*sin(o)-0.00183*cos(mp-f)+0.00115*sin(mp-2*d)-0.00096*sin(mp-d);
   tau=tau+0.00046*sin(2*f-2*d)-0.00039*sin(mp-f)-0.00032*sin(mp-m-d)+0.00027*sin(2*mp-m-2*d);
   tau=tau+0.00023*sin(k2)-0.00014*sin(2*d)+0.00014*cos(2*mp-2*f)-0.00012*sin(mp-2*f);
   tau=tau-0.00012*sin(2*mp)+0.00011*sin(2*mp-2*m-2*d);
   tau*=(DR);
   sigma*=(DR);
   rho*=(DR);
   /* =============== earth lon,lat =====================*/
   /* --- topocentric coordinates of moon ---*/
   long1=1.; /* pour eviter la recursivite folle */
	jjutc=jj;
   mc_adlunap(planete,jj,jjutc,equinoxe,astrometric,longmpc,rhocosphip,rhosinphip,&asd,&dec,&delta,&mag,&diamapp,&elong,&phase,&rr,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
   /* --- precession J2000.0 -> date ---*/
   mc_precad(equinoxe,asd,dec,jj,&asd,&dec);
   /* --- coord ecl */
   mc_lbr2xyz(asd,dec,1,&xeq,&yeq,&zeq);
   mc_xyzeq2ec(xeq,yeq,zeq,eps,&xec,&yec,&zec);
   mc_xyz2lbr(xec,yec,zec,&l,&b,&rr);
   /* --- optical topocentric libration ---*/
   w=l-dpsi-o;
   a=mc_atan2(sin(w)*cos(b)*cos(i)-sin(b)*sin(i),cos(w)*cos(b));
   lp=a-f;
   bp=mc_asin(-sin(w)*cos(b)*sin(i)-sin(b)*cos(i));
   /* --- physical topocentric libration ---*/
   lpp=-tau+(rho*cos(a)+sigma*sin(a))*tan(bp);
   bpp=sigma*cos(a)-rho*sin(a);
   /* --- topocentric libration  ---*/
   v=fmod(4*PI+lp+lpp,2*PI);
   if (v>(PI)) { v-=(2*(PI)); }
   *lonc=v;
   *latc=(bp+bpp);
   /* --- pole axis position ---*/
   v=o+deps+sigma/sin(i);
   x=sin(i+rho)*sin(v);
   y=sin(i+rho)*cos(v)*cos(eps)-cos(i+rho)*sin(eps);
   w=mc_atan2(x,y);
   v=mc_asin(sqrt(x*x+y*y)*cos(asd-w)/cos(bp+bpp));
   *p=fmod(4*PI+v,2*PI);
   /* =============== earth lon,lat =====================*/
   /* --- geocentric coordinates of sun ---*/
   mc_adsolap(jj,equinoxe,astrometric,0.0,0.0,0.0,&asd,&dec,&r,&mag,&diamapp,&elong,&phase,&rr,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
   /* --- precession J2000.0 -> date ---*/
   mc_precad(equinoxe,asd,dec,jj,&asd,&dec);
   /* --- coord ecl */
   mc_lbr2xyz(asd,dec,1,&xeq,&yeq,&zeq);
   mc_xyzeq2ec(xeq,yeq,zeq,eps,&xec,&yec,&zec);
   mc_xyz2lbr(xec,yec,zec,&ls,&bs,&rr);
   /* --- sun ---*/
   l=ls+(PI)+delta/r*cos(b)*sin(ls-l);
   b=delta/r*b;
   /* --- optical topocentric libration ---*/
   w=l-dpsi-o;
   a=mc_atan2(sin(w)*cos(b)*cos(i)-sin(b)*sin(i),cos(w)*cos(b));
   lp=a-f;
   bp=mc_asin(-sin(w)*cos(b)*sin(i)-sin(b)*cos(i));
   /* --- physical topocentric libration ---*/
   lpp=-tau+(rho*cos(a)+sigma*sin(a))*tan(bp);
   bpp=sigma*cos(a)-rho*sin(a);
   /* --- topocentric libration  ---*/
   v=fmod(4*PI+lp+lpp,2*PI);
   if (v>(PI)) { v-=(2*(PI)); }
   *lons=v;
   *lats=(bp+bpp);
}

void mc_physephem(double jj,int planete,double xg,double yg,double zg,double x,double y,double z,
                  double *diamapp_equ,double *diamapp_pol,
                  double *long1,double *long2,double *long3,double *lati,double *posangle_north,
                  double *posangle_sun,double *long1_sun,double *lati_sun)
/***************************************************************************/
/* Cacul des parametres do'bservation physique des planetes                */
/***************************************************************************/
/* D'apres "Astronomy with computer".                                      */
/* pages 135-154 (chapitre 7)                                              */
/***************************************************************************/
{
   double t,a0=0.,d0=0.,w1=0.,w2=0.,w3=0.,f=0.,req=0.,n,longmpc,rhocosphip,rhosinphip,lats,lons,d;
   double r,dx,dy,dz,rho,costh,sinth,th,sx,sy,sz;
   double e1x,e1y,e1z,e2x,e2y,e2z,e3x,e3y,e3z;
   double sina,cosa,sind,cosd,sinw,cosw;
   double phip,phi,lambdp,lambd;
   double sense=1.;
   *diamapp_equ=0.;
   *diamapp_pol=0.;
   *long1=0.;
   *long2=0.;
   *long3=0.;
   *lati=0.;
   *posangle_sun=0.;
   *posangle_north=0.;
   t=(jj-2451545.)/36525.;
   d=(jj-2451545.);
   if (planete==MERCURE) {
      a0=281.01-0.033*t;
      d0=61.45-0.005*t;
      req=2439.;
      f=0.;
      w1=w2=w3=(329.68+6.1385025*d);
      sense=1.;
   } else if (planete==VENUS) {
      a0=272.76;
      d0=67.16;
      req=6051.;
      f=0.;
      w1=w2=w3=(160.20-1.4813688*d);
      sense=-1.;
   } else if (planete==TERRE) {
      a0=0.-0.641*t;
      d0=90.0-0.557*t;
      req=6378.14;
      f=0.00335281;
      w1=w2=w3=(190.16+360.9856235*d);
      sense=1.;
   } else if (planete==MARS) {
      a0=317.681-0.108*t;
      d0=52.886-0.061*t;
      req=3393.4;
      f=0.0051865;
      w1=w2=w3=(176.901+350.8919830*d);
      sense=1.;
   } else if (planete==JUPITER) {
      a0=268.05-0.009*t;
      d0=64.49+0.003*t;
      req=71398.;
      f=0.0648088;
      w1=(67.1+877.900*d);
      w2=(43.3+870.270*d);
      w3=(284.695+870.536*d);
      sense=1.;
   } else if (planete==SATURNE) {
      a0=40.589-0.036*t;
      d0=83.537-0.004*t;
      req=60000.;
      f=0.1076209;
      w1=w2=(227.2037+844.300*d);
      w3=(38.90+810.7939024*d);
      sense=1.;
   } else if (planete==URANUS) {
      a0=257.311;
      d0=-15.175;
      req=25400.;
      f=0.030;
      w1=w2=w3=(203.81-501.1600928*d);
      sense=-1.;
   } else if (planete==NEPTUNE) {
      n=(357.85+52.316*t)*(DR);
      a0=299.36+0.7*sin(n);
      d0=43.46-0.51*cos(n);
      req=24300.;
      f=0.0259;
      w1=w2=w3=(253.18+536.3128492*d-0.48*sin(n));
      sense=1.;
   } else if (planete==PLUTON) {
      a0=313.02;
      d0=9.09;
      req=1500.;
      f=0.;
      w1=w2=w3=(236.77-56.3623195*d);
      sense=-1.;
   } else if (planete==SOLEIL) {
      a0=286.13;
      d0=63.87;
      req=696000.;
      f=0.;
      w1=w2=w3=(84.182+14.1844000*d);
      sense=-1.;
   } else if ((planete==LUNE)||(planete==LUNE_ELP)) {
      longmpc=*long1;
      rhocosphip=*long2;
      rhosinphip=*long3;
      mc_libration(jj,planete,longmpc,rhocosphip,rhosinphip,long1,lati,posangle_north,&lons,&lats);
      *long2=*long1;
      *long3=*long1;
      r=sqrt(xg*xg+yg*yg+zg*zg);
      *diamapp_equ=2.*atan(1.1617e-5/r);
      *diamapp_pol=*diamapp_equ;
      *posangle_sun=0.;
      *lati_sun=lats;
      *long1_sun=lons;
      return;
   }
   a0*=(DR);
   d0*=(DR);
   w1*=(DR);
   w2*=(DR);
   w3*=(DR);
   req/=(UA*1e-3);
   sina=sin(a0);
   cosa=cos(a0);
   sind=sin(d0);
   cosd=cos(d0);
   dx=cosa*cosd;
   dy=sina*cosd;
   dz=sind;
   rho=sqrt(xg*xg+yg*yg);
   r=sqrt(xg*xg+yg*yg+zg*zg);
   *diamapp_equ=2*mc_asin(req/r);
   costh=((-xg*zg)*dx+(-yg*zg)*dy+(xg*xg+yg*yg)*dz)/(r*rho);
   sinth=(-yg*dx+xg*dy)/rho;
   th=mc_atan2(sinth,costh);
   *posangle_north=fmod(4*PI+th,2*PI);
   /* w1 */
   cosw=cos(w1);
   sinw=sin(w1);
   e1x=-cosw*sina-sinw*sind*cosa;
   e1y= cosw*cosa-sinw*sind*sina;
   e1z= sinw*cosd;
   e2x= sinw*sina-cosw*sind*cosa;
   e2y=-sinw*cosa-cosw*sind*sina;
   e2z= cosw*cosd;
   e3x= cosd*cosa;
   e3y= cosd*sina;
   e3z= sind;
   sx=-(e1x*xg+e1y*yg+e1z*zg);
   sy=-(e2x*xg+e2y*yg+e2z*zg);
   sz=-(e3x*xg+e3y*yg+e3z*zg);
   phip=mc_atan2(sz,sqrt(sx*sx+sy*sy));
   phi=mc_atan2(tan(phip),((1-f)*(1-f)));
   lambdp=mc_atan2(sy,sx);
   lambd=-1.*sense*lambdp;
   /* mc_ephem jup {{1999-08-30}} */
   *lati=phi;
   *diamapp_pol=(*diamapp_equ)*(1-f*cos(phip)*cos(phip));
   *long1=fmod(4*PI+lambd,2*PI);
   /* w1 sun */
   sx=-(e1x*x+e1y*y+e1z*z);
   sy=-(e2x*x+e2y*y+e2z*z);
   sz=-(e3x*x+e3y*y+e3z*z);
   phip=mc_atan2(sz,sqrt(sx*sx+sy*sy));
   phi=mc_atan2(tan(phip),((1-f)*(1-f)));
   lambdp=mc_atan2(sy,sx);
   lambd=-1.*sense*lambdp;
   *lati_sun=phi;
   *long1_sun=fmod(4*PI+lambd,2*PI);
   /* w2 */
   cosw=cos(w2);
   sinw=sin(w2);
   e1x=-cosw*sina-sinw*sind*cosa;
   e1y= cosw*cosa-sinw*sind*sina;
   e1z= sinw*cosd;
   e2x= sinw*sina-cosw*sind*cosa;
   e2y=-sinw*cosa-cosw*sind*sina;
   e2z= cosw*cosd;
   e3x= cosd*cosa;
   e3y= cosd*sina;
   e3z= sind;
   sx=-(e1x*xg+e1y*yg+e1z*zg);
   sy=-(e2x*xg+e2y*yg+e2z*zg);
   lambdp=mc_atan2(sy,sx);
   lambd=-1.*sense*lambdp;
   *long2=fmod(4*PI+lambd,2*PI);
   /* w3 */
   cosw=cos(w3);
   sinw=sin(w3);
   e1x=-cosw*sina-sinw*sind*cosa;
   e1y= cosw*cosa-sinw*sind*sina;
   e1z= sinw*cosd;
   e2x= sinw*sina-cosw*sind*cosa;
   e2y=-sinw*cosa-cosw*sind*sina;
   e2z= cosw*cosd;
   e3x= cosd*cosa;
   e3y= cosd*sina;
   e3z= sind;
   sx=-(e1x*xg+e1y*yg+e1z*zg);
   sy=-(e2x*xg+e2y*yg+e2z*zg);
   sz=-(e3x*xg+e3y*yg+e3z*zg);
   lambdp=mc_atan2(sy,sx);
   lambd=-1.*sense*lambdp;
   *long3=fmod(4*PI+lambd,2*PI);
   /* sun */
   d=sqrt(x*x+y*y+z*z);
   dx=-x;
   dy=-y;
   dz=-z;
   costh=((-xg*zg)*dx+(-yg*zg)*dy+(xg*xg+yg*yg)*dz)/(r*rho);
   sinth=(-yg*dx+xg*dy)/rho;
   th=mc_atan2(sinth,costh);
   *posangle_sun=fmod(4*PI+th,2*PI);
   if (planete==SOLEIL) {
      *posangle_sun=0.;
      *lati_sun=*lati;
      *long1_sun=*long1;
   }
}

int mc_util_cd2cdelt_old(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2)
/***************************************************************************/
/* Utilitaire qui tranforme les mots wcs de la matrice cd vers les         */
/* vieux mots cle cdelt1, cdelt2 et crota2.                                */
/***************************************************************************/
{
   double cdp1,cdp2,crotap2;
   double deuxpi,pisur2,sina,cosa,sinb,cosb,cosab,sinab,ab,aa,bb,cosr,sinr;
   double signr,signc,signd;

   deuxpi=2.*(PI);
   pisur2=(PI)/2.;

   aa=fmod(deuxpi+atan2(cd21,cd11),deuxpi);
   bb=fmod(deuxpi+atan2(-cd12,cd22),deuxpi);

   cosa=cos(aa);
   sina=sin(aa);
   cosb=cos(bb);
   sinb=sin(bb);

   /* a-b */
   cosab=cosa*cosb+sina*sinb;
   sinab=sina*cosb-cosa*sinb;
   ab=fabs(atan2(sinab,cosab));

   /* cas |a-b| proche de PI */
   if (ab>pisur2) {
	   if (cosa>cosb) {
         bb=fmod((PI)+bb,deuxpi);
      } else {
         aa=fmod((PI)+aa,deuxpi);
      }
   }

   /* mean (a+b)/2 */
   ab=bb-aa;
   if (ab>PI) {
   	aa=aa+deuxpi;
   }
   ab=aa-bb;
   if (ab>PI) {
   	bb=bb+deuxpi;
   }
   crotap2=fmod(deuxpi+(aa+bb)/2.,deuxpi);

   cosr=fabs(cos(crotap2));
   sinr=fabs(sin(crotap2));

   /* cdelt */
   if (cosr>sinr) {
	   cdp1=cd11/cos(crotap2);
	   cdp2=cd22/cos(crotap2);
   } else {
   	cdp1=fabs(-cd21/sin(crotap2));
   	cdp2=fabs( cd12/sin(crotap2));
      signr=sinr/fabs(sinr);
      /**/
      signc=cd12/fabs(cd12);
      signd=signc/signr;
      if (signd<0) { cdp1*=-1.; }
      /**/
      signc=cd21/fabs(cd21);
      signd=-signc/signr;
      if (signd<0) { cdp2*=-1.; }
   }

   *cdelt1=cdp1;
   *cdelt2=cdp2;
   *crota2=crotap2;
   return(0);
}


int mc_htm_testin(double *v0, double *v1, double *v2, double *v)
/****************************************************************************/
/* Retourne 1 si v est l'interieur du triangle v0,v1,v2.                    */
/****************************************************************************/
/****************************************************************************/
{
   double p[4],res1,res2,res3;
   int res;
   /* res = (v0 x v1) . v */
   p[0]=v0[1]*v1[2]-v0[2]*v1[1];
   p[1]=v0[2]*v1[0]-v0[0]*v1[2];
   p[2]=v0[0]*v1[1]-v0[1]*v1[0];
   res1=p[0]*v[0]+p[1]*v[1]+p[2]*v[2];
   /* res = (v1 x v2) . v */
   p[0]=v1[1]*v2[2]-v1[2]*v2[1];
   p[1]=v1[2]*v2[0]-v1[0]*v2[2];
   p[2]=v1[0]*v2[1]-v1[1]*v2[0];
   res2=p[0]*v[0]+p[1]*v[1]+p[2]*v[2];
   /* res = (v2 x v0) . v */
   p[0]=v2[1]*v0[2]-v2[2]*v0[1];
   p[1]=v2[2]*v0[0]-v2[0]*v0[2];
   p[2]=v2[0]*v0[1]-v2[1]*v0[0];
   res3=p[0]*v[0]+p[1]*v[1]+p[2]*v[2];
   res=0;
   if ((res1>0)&&(res2>0)&&(res3>0)) {
      res=1;
   }
   return res;
}

int mc_radec2htm(double ra,double dec,int niter,char *htm)
/****************************************************************************/
/* Retourne le code Hierarchical Triangle Mesh.                             */
/****************************************************************************/
/****************************************************************************/
{
   int k,res,iter;
   double v[4],vv0[4],vv1[4],vv2[4],vv3[4],vv4[4],vv5[4];
   double vx0[4],vx1[4],vx2[4];
   double *v0,*v1,*v2;
   double w0[4],w1[4],w2[4];
   double w;
   v[0]=cos(ra)*cos(dec);
   v[1]=sin(ra)*cos(dec);
   v[2]=sin(dec);
   vv0[0]=0.;
   vv0[1]=0.;
   vv0[2]=1.;
   vv1[0]=1.;
   vv1[1]=0.;
   vv1[2]=0.;
   vv2[0]=0.;
   vv2[1]=1.;
   vv2[2]=0.;
   vv3[0]=-1.;
   vv3[1]=0.;
   vv3[2]=0.;
   vv4[0]=0.;
   vv4[1]=-1.;
   vv4[2]=0.;
   vv5[0]=0.;
   vv5[1]=0.;
   vv5[2]=-1.;
   /* === identification du premier noeud */
   v0=vv1;
   v1=vv5;
   v2=vv2;
   for (k=1;k<=8;k++) {
      if (k==1) {
         htm[0]='S';htm[1]='0';
         v0=vv1;
         v1=vv5;
         v2=vv2;
      }
      if (k==2) {
         htm[0]='S';htm[1]='1';
         v0=vv2;
         v1=vv5;
         v2=vv3;
      }
      if (k==3) {
         htm[0]='S';htm[1]='2';
         v0=vv3;
         v1=vv5;
         v2=vv4;
      }
      if (k==4) {
         htm[0]='S';htm[1]='3';
         v0=vv4;
         v1=vv5;
         v2=vv1;
      }
      if (k==5) {
         htm[0]='N';htm[1]='0';
         v0=vv1;
         v1=vv0;
         v2=vv4;
      }
      if (k==6) {
         htm[0]='N';htm[1]='1';
         v0=vv4;
         v1=vv0;
         v2=vv3;
      }
      if (k==7) {
         htm[0]='N';htm[1]='2';
         v0=vv3;
         v1=vv0;
         v2=vv2;
      }
      if (k==8) {
         htm[0]='N';htm[1]='3';
         v0=vv2;
         v1=vv0;
         v2=vv1;
      }
      res=mc_htm_testin(v0,v1,v2,v);
      if (res==1) {
         break;
      }
   }
   /* === identification des noeuds suivants */
   for (iter=1;iter<=niter;iter++) {
      for (k=0;k<3;k++) { vx0[k]=v0[k]; }
      for (k=0;k<3;k++) { vx1[k]=v1[k]; }
      for (k=0;k<3;k++) { vx2[k]=v2[k]; }
      /* --- vecteurs w0,w1,w2 */
      for (w=0.,k=0;k<3;k++) { w0[k]=vx1[k]+vx2[k]; w+=(w0[k]*w0[k]); }
      for (k=0;k<3;k++) { w0[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w1[k]=vx0[k]+vx2[k]; w+=(w1[k]*w1[k]); }
      for (k=0;k<3;k++) { w1[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w2[k]=vx0[k]+vx1[k]; w+=(w2[k]*w2[k]); }
      for (k=0;k<3;k++) { w2[k]/=sqrt(w); }
      /* --- boucle sur les 4 triangles */
      for (k=1;k<=4;k++) {
         if (k==1) {
            htm[1+iter]='0';
            v0=vx0;
            v1=w2;
            v2=w1;
         }
         if (k==2) {
            htm[1+iter]='1';
            v0=vx1;
            v1=w0;
            v2=w2;
         }
         if (k==3) {
            htm[1+iter]='2';
            v0=vx2;
            v1=w1;
            v2=w0;
         }
         if (k==4) {
            htm[1+iter]='3';
            v0=w0;
            v1=w1;
            v2=w2;
         }
         res=mc_htm_testin(v0,v1,v2,v);
         if (res==1) {
            break;
         }
      }
   }
   return 0;
}

int mc_htm2radec(char *htm,double *ra,double *dec,int *niter,double *ra0,double *dec0,double *ra1,double *dec1,double *ra2,double *dec2)
/****************************************************************************/
/* Retourne le ra,dec a paertir du code Hierarchical Triangle Mesh.         */
/****************************************************************************/
/*
set radec [mc_htm2radec N3300] ; mc_radec2htm [lindex $radec 0] [lindex $radec 1] [lindex $radec 2]
*/
/****************************************************************************/
{
   int k,iter;
   double v[4],vv0[4],vv1[4],vv2[4],vv3[4],vv4[4],vv5[4];
   double vx0[4],vx1[4],vx2[4];
   double *v0,*v1,*v2;
   double w0[4],w1[4],w2[4];
   double w,twopi;
   int n;
   n=(int)strlen(htm);
   vv0[0]=0.;
   vv0[1]=0.;
   vv0[2]=1.;
   vv1[0]=1.;
   vv1[1]=0.;
   vv1[2]=0.;
   vv2[0]=0.;
   vv2[1]=1.;
   vv2[2]=0.;
   vv3[0]=-1.;
   vv3[1]=0.;
   vv3[2]=0.;
   vv4[0]=0.;
   vv4[1]=-1.;
   vv4[2]=0.;
   vv5[0]=0.;
   vv5[1]=0.;
   vv5[2]=-1.;
   /* === identification du premier noeud */
   v0=vv1;
   v1=vv5;
   v2=vv2;
      if ((htm[0]=='S')&&(htm[1]=='0')) {
         v0=vv1;
         v1=vv5;
         v2=vv2;
      }
      if ((htm[0]=='S')&&(htm[1]=='1')) {
         v0=vv2;
         v1=vv5;
         v2=vv3;
      }
      if ((htm[0]=='S')&&(htm[1]=='2')) {
         v0=vv3;
         v1=vv5;
         v2=vv4;
      }
      if ((htm[0]=='S')&&(htm[1]=='3')) {
         v0=vv4;
         v1=vv5;
         v2=vv1;
      }
      if ((htm[0]=='N')&&(htm[1]=='0')) {
         v0=vv1;
         v1=vv0;
         v2=vv4;
      }
      if ((htm[0]=='N')&&(htm[1]=='1')) {
         v0=vv4;
         v1=vv0;
         v2=vv3;
      }
      if ((htm[0]=='N')&&(htm[1]=='2')) {
         v0=vv3;
         v1=vv0;
         v2=vv2;
      }
      if ((htm[0]=='N')&&(htm[1]=='3')) {
         v0=vv2;
         v1=vv0;
         v2=vv1;
      }
   /* === identification des noeuds suivants */
   *niter=n-2;
   for (iter=1;iter<=*niter;iter++) {
      for (k=0;k<3;k++) { vx0[k]=v0[k]; }
      for (k=0;k<3;k++) { vx1[k]=v1[k]; }
      for (k=0;k<3;k++) { vx2[k]=v2[k]; }
      /* --- vecteurs w0,w1,w2 */
      for (w=0.,k=0;k<3;k++) { w0[k]=vx1[k]+vx2[k]; w+=(w0[k]*w0[k]); }
      for (k=0;k<3;k++) { w0[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w1[k]=vx0[k]+vx2[k]; w+=(w1[k]*w1[k]); }
      for (k=0;k<3;k++) { w1[k]/=sqrt(w); }
      for (w=0.,k=0;k<3;k++) { w2[k]=vx0[k]+vx1[k]; w+=(w2[k]*w2[k]); }
      for (k=0;k<3;k++) { w2[k]/=sqrt(w); }
      /* --- boucle sur les 4 triangles */
         if (htm[1+iter]=='0') {
            v0=vx0;
            v1=w2;
            v2=w1;
         }
         if (htm[1+iter]=='1') {
            v0=vx1;
            v1=w0;
            v2=w2;
         }
         if (htm[1+iter]=='2') {
            v0=vx2;
            v1=w1;
            v2=w0;
         }
         if (htm[1+iter]=='3') {
            v0=w0;
            v1=w1;
            v2=w2;
         }
   }
   v[0]=(v0[0]+v1[0]+v2[0])/3.;
   v[1]=(v0[1]+v1[1]+v2[1])/3.;
   v[2]=(v0[2]+v1[2]+v2[2])/3.;
   twopi=8*atan(1.);
   *dec=asin(v[2]);
   *ra=atan2(v[1],v[0]); if (*ra<0.) *ra+=(twopi);
   *dec0=asin(v0[2]);
   *ra0=atan2(v0[1],v0[0]); if (*ra0<0.) *ra0+=(twopi);
   *dec1=asin(v1[2]);
   *ra1=atan2(v1[1],v1[0]); if (*ra1<0.) *ra1+=(twopi);
   *dec2=asin(v2[2]);
   *ra2=atan2(v2[1],v2[0]); if (*ra2<0.) *ra2+=(twopi);
   return 0;
}
