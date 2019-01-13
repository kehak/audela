/* mc_corc1.cpp
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
/* Corrections de precession, nutation, aberration ...                     */
/***************************************************************************/
#include "mc.h"
#include <math.h>

void mc_parallaxe_stellaire(double jj,double asd1,double dec1,double *asd2,double *dec2,double plx_mas)
/***************************************************************************/
/* Corrige asd1,dec1 de la parallaxe stellaire et retourne asd2 et dec2    */
/***************************************************************************/
/* A. Danjon : Astronomie Generale ed. A. Blanchard (1980) p130            */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],ls,bs,rs,eps,dpsi,deps;
   double secd,dasd,ddec;
   double plxrad;

   /* --- obliquite moyenne --- */
   mc_obliqmoy(jj,&eps);

   /* --- longitude vraie du soleil ---*/
   mc_jd2lbr1a(jj,llp,mmp,uup);
   mc_jd2lbr1b(jj,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_nutation(jj,1,&dpsi,&deps);
   ls+=dpsi;

   plxrad=plx_mas*1e-3/3600.*(DR);
   secd=cos(dec1);
   if (secd==0) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   secd=1./secd;
   dasd=(cos(eps)*cos(asd1)*sin(ls)-sin(asd1)*cos(ls))*secd;
   ddec=(sin(eps)*cos(dec1)*sin(ls)-sin(dec1)*cos(asd1)*cos(ls)-cos(eps)*sin(dec1)*sin(asd1)*sin(ls));
   asd1+=plxrad*dasd;
   dec1+=plxrad*ddec;
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;
}

void mc_aberration_annuelle(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de l'aberration annuelle et retourne asd2 et dec2     */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p81-82    */
/* Formule sans les E-terms                                                */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],ls,bs,rs,eps,dpsi,deps;
   double k=20.49552; /* constant of annual aberration */
   double c,cc,d,dd,secd,cp,dp,dasd,ddec;

   /* --- obliquite moyenne --- */
   mc_obliqmoy(jj,&eps);

   /* --- longitude vraie du soleil ---*/
   mc_jd2lbr1a(jj,llp,mmp,uup);
   mc_jd2lbr1b(jj,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_nutation(jj,1,&dpsi,&deps);
   ls+=dpsi;

   secd=cos(dec1);
   if (secd==0) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   secd=1./secd;
	if (fabs(secd)<100) {
		c=cos(asd1)*secd;
		d=sin(asd1)*secd;
		cp=tan(eps)*cos(dec1)-sin(asd1)*sin(dec1);
		dp=cos(asd1)*sin(dec1);
		cc=-k*cos(eps)*cos(ls);
		dd=-k*sin(ls);
		dasd=(cc*c+dd*d)/3600.*(DR);
		ddec=(cc*cp+dd*dp)/3600.*(DR);
		dasd*=(double)signe;
		ddec*=(double)signe;
		asd1+=dasd;
		dec1+=ddec;
	}
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;
}

void mc_aberration_eterms(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de l'aberration eterms et retourne asd2 et dec2       */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p82-83    */
/* Formule des E-terms                                                     */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],ls,bs,rs,eps,dpsi,deps;
   double k=20.49552; /* constant of annual aberration */
   double c,cc,d,dd,secd,cp,dp,dasd,ddec;
   double t,e,w;

   /* --- obliquite moyenne --- */
   mc_obliqmoy(jj,&eps);

   /* --- longitude vraie du soleil ---*/
   mc_jd2lbr1a(jj,llp,mmp,uup);
   mc_jd2lbr1b(jj,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_nutation(jj,1,&dpsi,&deps);
   ls+=dpsi;

   secd=cos(dec1);
   if (secd==0) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   secd=1./secd;
   c=cos(asd1)*secd;
   d=sin(asd1)*secd;
   cp=tan(eps)*cos(dec1)-sin(asd1)*sin(dec1);
   dp=cos(asd1)*sin(dec1);
   t=(jj-2451545.)/36525.;
   e=0.016708320-0.000042229*t-0.000000126*t*t;
   w=102.938346+1.719457*t;
   cc=k*e*cos(eps)*cos(w);
   dd=k*e*sin(w);
   dasd=(cc*c+dd*d)/3600.*(DR);
   ddec=(cc*cp+dd*dp)/3600.*(DR);
   dasd*=(double)signe;
   ddec*=(double)signe;
   asd1+=dasd;
   dec1+=ddec;
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;
}

void mc_aberration_diurne(double jj,double asd1,double dec1, double longuai, double rhocosphip, double rhosinphip,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de l'aberration diurne et retourne asd2 et dec2       */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p83-84    */
/***************************************************************************/
{
   double secd,dasd,ddec;
   double tsl,latitude,altitude,phip,a,sinphi,r,h;
	a=(EARTH_SEMI_MAJOR_RADIUS)*1e-3;
   mc_tsl(jj,-longuai,&tsl);
   h=tsl-asd1;
   mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
   if (rhocosphip==0.) {
      if (rhosinphip>0) {
         phip=(PI)/2.;
      } else {
         phip=-(PI)/2.;
      }
   } else {
      phip=mc_atan2(rhosinphip,rhocosphip);
   }
   sinphi=sin(latitude);
   r=(21*sinphi*sinphi+a)/a;
   secd=cos(dec1);
   if (secd==0) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
   secd=1./secd;
	if (fabs(secd)<100) {
		dasd=(0.320*r*cos(phip)*cos(h)*secd)/3600.*(DR);
		ddec=(0.320*r*cos(phip)*sin(h)*sin(dec1))/3600.*(DR);
	} else {
		dasd=0;
		ddec=0;
	}
   dasd*=(double)signe;
   ddec*=(double)signe;
   asd1+=dasd;
   dec1+=ddec;
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;
}

void mc_aberpla(double jj1, double delta, double *jj2)
/***************************************************************************/
/* Corrige jj1 de l'aberration de la lumiere et retourne jj2               */
/***************************************************************************/
/***************************************************************************/
{
   *jj2=jj1-0.0057755*delta;
}

void mc_latalt2rhophi(double latitude,double altitude,double *rhosinphip,double *rhocosphip)
/***************************************************************************/
/* Retourne les valeurs de rhocosphi' et rhosinphi' (en rayons equatorial  */
/* terrestres) a partir de la latitude et de l'altitude.                   */
/***************************************************************************/
/* Latitude en degres decimaux.                                            */
/* Altitude en metres.                                                     */
/* Algo : Meeus "Astronomical Algorithms" p78                              */
/***************************************************************************/
{
   double aa,ff,bb,a,b,u,lat,alt;
   lat=latitude*(DR);
   alt=altitude;
   //aa=6378140;
   aa=EARTH_SEMI_MAJOR_RADIUS;
   //ff=1./298.257;
	ff=1./EARTH_INVERSE_FLATTENING;
   bb=aa*(1-ff);
   u=atan(bb/aa*tan(lat));
   a=bb/aa*sin(u)+alt/aa*sin(lat);
   b=      cos(u)+alt/aa*cos(lat);
   *rhocosphip=b;
   *rhosinphip=a;
}

void mc_nutation(double jj, int precision, double *dpsi, double *deps)
/***************************************************************************/
/* Retourne la valeur de la nutation pour jj donne                         */
/***************************************************************************/
/* precision=0 pour une incertitude de 0"5 sur dpsi 0"1 sur deps           */
/* precision=1 pour de la tres haute precision (environ 0.01")             */
/***************************************************************************/
{
   double t,d,m,mp,f,o,l,lp,dpsi0,deps0;
   t=(jj-2451545.0)/36525;
   o=125.04452-1934.136261*t+.0020708*t*t+t*t*t/450000;
   o=fmod(o*DR,2*PI);
   if (precision==0) {
      l=280.4665+36000.7698*t;
      lp=218.3165+481267.8813*t;
      l=fmod(l*DR,2*PI);
      lp=fmod(lp*DR,2*PI);
      dpsi0=-17.20*sin(o)-1.32*sin(2*l)-.23*sin(2*lp)+.21*sin(2*o);
      dpsi0=dpsi0/3600*DR;
      deps0=9.20*cos(o)+.57*cos(2*l)+.10*cos(2*lp)-.09*cos(2*o);
      deps0=deps0/3600*DR;
   } else /* if (precision==1) */ {
      d=297.85036+445267.111480*t-.0019142*t*t+t*t*t/189474;
      m=357.52772+35999.050340*t-.0001603*t*t-t*t*t/300000;
      mp=134.96298+477198.867398*t+.0086972*t*t+t*t*t/56250;
      f=93.27191+483202.017538*t-.0036825*t*t+t*t*t/327270;
      d=fmod(d*DR,2*PI);
      m=fmod(m*DR,2*PI);
      mp=fmod(mp*DR,2*PI);
      f=fmod(f*DR,2*PI);
      dpsi0=(-171996-174.2*t)*sin(o)+(-13187-1.6*t)*sin(-2*d+2*f+2*o)
         +(-2274-.02*t)*sin(2*f+2*o)+(2062+.2*t)*sin(2*o)
         +(1426-3.4*t)*sin(m)+(712+.1*t)*sin(mp);
      dpsi0+=((-517+1.2*t)*sin(-2*d+m+2*f+2*o)-(386-.4*t)*sin(2*f+o)
         -301*sin(mp+2*f+2*o)+(217-.5*t)*sin(-2*d-m+2*f+2*o)
         -158*sin(-2*d+mp)+(129+.1*t)*sin(-2*d+2*f+o));
      dpsi0+=(123*sin(-mp+2*f+2*o)+63*sin(2*d)+(63+.1*t)*sin(mp+o)
         -59*sin(2*d-mp+2*f+2*o)+(-58-.1*t)*sin(-mp+o)-51*sin(mp+2*f+o)
         +48*sin(-2*d+2*mp)+46*sin(-2*mp+2*f+o)-38*sin(2*d+2*f+2*o));
      dpsi0=dpsi0*1e-4/3600*DR;
      deps0=(92025+8.9*t)*cos(o)+(5736-3.1*t)*cos(-2*d+2*f+2*o)
         +(977-.5*t)*cos(2*f+2*o)+(-895+.5*t)*cos(2*o)+(54-.1*t)*cos(m)
         -7*cos(mp)+(224-.6*t)*cos(-2*d+m+2*f+2*o)+200*cos(2*f+o);
      deps0+=((129-.1*t)*cos(mp+2*f+2*o)+(-95+.3*t)*cos(-2*d-m+2*f+2*o)
         -70*cos(-2*d+2*f+o)-53*cos(-mp+2*f+2*o)-33*cos(mp+o)
         +26*cos(2*d-mp+2*f+2*o)+32*cos(-mp+o)+27*cos(mp+2*f+o));
      deps0=deps0*1e-4/3600*DR;
   }
   *dpsi=dpsi0;
   *deps=deps0;
}

void mc_nutradec(double jj,double asd1,double dec1,double *asd2,double *dec2,int signe)
/***************************************************************************/
/* Corrige asd1,dec1 de la nutation et retourne asd2 et dec2               */
/***************************************************************************/
/* Trueblood & Genet : Telescop Control ed. Willmann Bell (1997) p71       */
/***************************************************************************/
{
   double eps,tand,dasd,ddec,dpsi,deps;
	double xeq,yeq,zeq,xec,yec,zec,l,b,r;
	int methode=1;
   /* --- obliquite moyenne --- */
   mc_obliqmoy(jj,&eps);

   /* --- nutation ---*/
   mc_nutation(jj,1,&dpsi,&deps);

   if (fabs(dec1)>=(PI)/2.) {
      *asd2=asd1;
      *dec2=dec1;
      return;
   }
	if (methode==0) {
		tand=tan(dec1);
		dasd=(cos(eps)+sin(eps)*sin(asd1)*tand)*dpsi-cos(asd1)*tand*deps;
		ddec=sin(eps)*cos(asd1)*dpsi+sin(asd1)*deps;
		dasd*=(double)signe;
		ddec*=(double)signe;
		asd1+=dasd;
		dec1+=ddec;
	} else {
		// eq->ecl
		l=asd1 ; b=dec1 ; r=1;
		mc_lbr2xyz(l,b,r,&xeq,&yeq,&zeq);
		mc_xyzeq2ec(xeq,yeq,zeq,eps,&xec,&yec,&zec);
		// correction ecl
		mc_xyz2lbr(xec,yec,zec,&l,&b,&r);
		l=l+dpsi*signe;
		eps=eps+deps*signe;
		mc_lbr2xyz(l,b,r,&xec,&yec,&zec);
		// ecl->eq
		mc_xyzec2eq(xec,yec,zec,eps,&xeq,&yeq,&zeq);
		mc_xyz2lbr(xeq,yeq,zeq,asd2,dec2,&r);
	}
   asd1=fmod(4*PI+asd1,2*PI);
   *asd2=asd1;
   *dec2=dec1;

}

void mc_obliqmoy(double jj, double *eps)
/***************************************************************************/
/* Retourne la valeur de l'obliquite terrestre moyenne pour jj             */
/***************************************************************************/
/* formule de Laskar (JM)                                                  */
/***************************************************************************/
{
   double t,u,eps0;
   t=(jj-2451545.0)/36525;
   u=t/100;
   eps0=u*(-4680.93-u*(1.55+u*(1999.25-u*(51.38-u*(249.67-u*(39.05+u*(7.12+u*(27.87+u*(5.79+u*(2.45))))))))));
   eps0=(23.4392911111+eps0/3600)*DR;
   *eps=eps0;
}

void mc_paraldxyzeq(double jj, double longuai, double rhocosphip, double rhosinphip, double *dxeq, double *dyeq, double *dzeq)
/***************************************************************************/
/* Calcul des corrections cartesiennes equatoriales de la parallaxe        */
/* Xtopo = Xgeo - *dxeq etc...                                             */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       Willmann Bell                                                      */
/* Formules (6.17.1) pp 208                                                */
/***************************************************************************/
{
   double tsl,cst;
	//double latitude,altitude,ff,phip,f,gc,gs;
	cst=(EARTH_SEMI_MAJOR_RADIUS)/(UA); /* equatorial radius of the Earth in U.A. */
   mc_tsl(jj,-longuai,&tsl);
   *dxeq=(cst*rhocosphip*cos(tsl));
   *dyeq=(cst*rhocosphip*sin(tsl));
   *dzeq=(cst*rhosinphip);
	/*
	//
	Dan Boulet "Methods of orbit determination" Willmann Bell
	Formules (2.28) a (2.33)
	Il y a une ambuite dans le texte (7.1.13) page 181 de 
	"Introduction aux ephemrides astronomiques" BDL
	//
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	latitude*=(DR);
	ff=1./EARTH_INVERSE_FLATTENING;
   phip=atan2(rhosinphip,rhocosphip);
	altitude/=(EARTH_SEMI_MAJOR_RADIUS);
	f=sqrt(1-(2*ff-ff*ff)*sin(latitude)*sin(latitude));
	gc=1/f+altitude;
	gs=(1-ff)*(1-ff)/f+altitude;
   *dxeq=(gc*cst*cos(latitude)*cos(tsl));
   *dyeq=(gc*cst*cos(latitude)*sin(tsl));
   *dzeq=(gs*cst*sin(latitude));
	*/
}

void mc_precelem(struct elemorb elem1, double jd1, double jd2, struct elemorb *elem2)
/***************************************************************************/
/* Passage des elements de l'orbite d'un equinoxe a un autre               */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,eta,pi,p,i0,o0,w0,i,o,w,dw,psi,a;
   double cosi0,sini0,coso0pi,sino0pi,coseta,sineta,sini,sina,cosa;

   t=(jd2-jd1)/36525;
   tt=(jd1-2451545.0)/36525;
   eta=(47.0029-0.06603*tt+0.000598*tt*tt)*t+(-0.03302+0.000598*tt)*t*t+.000060*t*t*t;
   eta=eta/3600*DR;
   pi=174.876384+(3289.4789*tt+0.60622*tt*tt-(869.8089+.50491*tt)*t+.03536*t*t)/3600;
   pi=pi*DR;
   p=(5029.0966+2.22226*tt-.000042*tt*tt)*t+(1.11113-.000042*tt)*t*t-.000006*t*t*t;
   p=p/3600*DR;
   psi=p+pi;
   i0=elem1.i;
   o0=elem1.o;
   w0=elem1.w;
   cosi0=cos(i0);
   sini0=sin(i0);
   coseta=cos(eta);
   sineta=sin(eta);
   coso0pi=cos(o0-pi);
   sino0pi=sin(o0-pi);
   if (fabs(i0/(DR))<1e-6) {
      i=eta;
      sini=sin(i);
      o=psi+PI/2;
   } else {
      i=acos(cosi0*coseta+sini0*sineta*coso0pi);
      sini=sin(i);
      sina=sini0*sino0pi/sini;
      cosa=(-sineta*cosi0+coseta*sini0*coso0pi)/sini;
      a=atan2(sina,cosa);
      o=psi+a;
   }
   sina=-sineta*sino0pi/sini;
   cosa=(sini0*coseta-cosi0*sineta*coso0pi)/sini;
   dw=atan2(sina,cosa);
   w=w0+dw;
   i=fmod(4*PI+i,2*PI);
   o=fmod(4*PI+o,2*PI);
   w=fmod(4*PI+w,2*PI);
   mc_copyelem(elem1,elem2);
   elem2->i=i;
   elem2->o=o;
   elem2->w=w;
   elem2->jj_equinoxe=jd2;
}

void mc_precxyz(double jd1, double x1, double y1, double z1, double jd2, double *x2, double *y2, double *z2)
/***************************************************************************/
/* Passage des coordonnees cartes. equatoriales d'un equinoxe a un autre   */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,dz,zz,th,cosdz,sindz,coszz,sinzz,costh,sinth,a,b,c,x20,y20,z20;

   t=(jd2-jd1)/36525;
   tt=(jd1-2451545.0)/36525;
   dz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(0.30188-.000344*tt)*t*t+.017998*t*t*t;
   dz=dz/3600*DR;
   zz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(1.09468+.000066*tt)*t*t+.018203*t*t*t;
   zz=zz/3600*DR;
   th=(2004.3109-0.85330*tt-.000217*tt*tt)*t-(0.42665+.000217*tt)*t*t-.041833*t*t*t;
   th=th/3600*DR;
   cosdz=cos(dz);
   sindz=sin(dz);
   coszz=cos(zz);
   sinzz=sin(zz);
   costh=cos(th);
   sinth=sin(th);
   a= cosdz*costh*coszz-sindz*sinzz;
   b=-sindz*costh*coszz-cosdz*sinzz;
   c=-sinth*coszz;
   x20=x1*a+y1*b+z1*c;
   a= cosdz*costh*sinzz+sindz*coszz;
   b=-sindz*costh*sinzz+cosdz*coszz;
   c=-sinth*sinzz;
   y20=x1*a+y1*b+z1*c;
   a= cosdz*sinth;
   b=-sindz*sinth;
   c= costh;
   z20=x1*a+y1*b+z1*c;
   *x2=x20;
   *y2=y20;
   *z2=z20;
}

void mc_precad(double jd1, double asd1, double dec1, double jd2, double *asd2, double *dec2)
/***************************************************************************/
/* Passage des coordonnees spheri. equatoriales d'un equinoxe a un autre   */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,dz,zz,th,cosasddz,sinasddz,costh,sinth,cosdec,sindec,a,b,c;

   t=(jd2-jd1)/36525.;
   tt=(jd1-2451545.0)/36525.;
   dz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(0.30188-.000344*tt)*t*t+.017998*t*t*t;
   dz=dz/3600*DR;
   zz=(2306.2181+1.39656*tt-.000139*tt*tt)*t+(1.09468+.000066*tt)*t*t+.018203*t*t*t;
   zz=zz/3600*DR;
   th=(2004.3109-0.85330*tt-.000217*tt*tt)*t-(0.42665+.000217*tt)*t*t-.041833*t*t*t;
   th=th/3600*DR;
   cosasddz=cos(asd1+dz);
   sinasddz=sin(asd1+dz);
   costh=cos(th);
   sinth=sin(th);
   cosdec=cos(dec1);
   sindec=sin(dec1);
   a=cosdec*sinasddz;
   b=costh*cosdec*cosasddz-sinth*sindec;
   c=sinth*cosdec*cosasddz+costh*sindec;
   a=atan2(a,b)+zz;
   *asd2=fmod(4*PI+a,2*PI);
   *dec2=asin(c);
}

void mc_preclb(double jd1, double lon1, double lat1, double jd2, double *lon2, double *lat2)
/***************************************************************************/
/* Passage des coord. sph. ecliptiques d'un equinoxe a un autre            */
/***************************************************************************/
/***************************************************************************/
{
   double t,tt,eta,pi,p,psi,a,b,c;
   double coseta,sineta,coslonpi,sinlonpi,coslat,sinlat;

   t=(jd2-jd1)/36525;
   tt=(jd1-2451545.0)/36525;
   eta=(47.0029-0.06603*tt+0.000598*tt*tt)*t+(-0.03302+0.000598*tt)*t*t+.000060*t*t*t;
   eta=eta/3600*DR;
   pi=174.876384+(3289.4789*tt+0.60622*tt*tt-(869.8089+.50491*tt)*t+.03536*t*t)/3600;
   pi=pi*DR;
   p=(5029.0966+2.22226*tt-.000042*tt*tt)*t+(1.11113-.000042*tt)*t*t-.000006*t*t*t;
   p=p/3600*DR;
   psi=p+pi;
   coslonpi=cos(pi-lon1);
   sinlonpi=sin(pi-lon1);
   coseta=cos(eta);
   sineta=sin(eta);
   coslat=cos(lat1);
   sinlat=sin(lat1);
   a=coseta*coslat*sinlonpi-sineta*sinlat;
   b=coslat*coslonpi;
   c=coseta*sinlat+sineta*coslat*sinlonpi;
   a=psi-mc_atan2(a,b);
   *lon2=fmod(4*PI+a,2*PI);
   *lat2=mc_asin(c);
}

void mc_rhophi2latalt(double rhosinphip,double rhocosphip,double *latitude,double *altitude)
/***************************************************************************/
/* Retourne les valeurs de la latitude et de l'altitude a partir de        */
/* rhocosphi' et rhosinphi' (en rayons equatorial terrestres)              */
/***************************************************************************/
/* Latitude en degres decimaux.                                            */
/* Altitude en metres.                                                     */
/* Algo : Meeus "Astronomical Algorithms" p78                              */
/***************************************************************************/
{
   double aa,ff,bb,lat,alt,phip,rho,phi0,u0,rhosinphip0,rhocosphip0,rho0;
   double sinu0,cosu0,sinphi0,cosphi0;
   //aa=6378140;
   aa=EARTH_SEMI_MAJOR_RADIUS;
   //ff=1./298.257;
	ff=1./EARTH_INVERSE_FLATTENING;
   bb=aa*(1-ff);
   rho=sqrt(rhosinphip*rhosinphip+rhocosphip*rhocosphip);
   if (rho==0.) {
      *latitude=0.;
      *altitude=-aa;
      return;
   }
   phip=atan2(rhosinphip,rhocosphip);
   phi0=atan(aa*aa/bb/bb*tan(phip)); /* alt=0 */
   u0=atan(bb/aa*tan(phi0));
   sinu0=sin(u0);
   cosu0=cos(u0);
   sinphi0=sin(phi0);
   cosphi0=cos(phi0);
   for (alt=-1000;alt<20000.;alt+=0.1) {
      rhosinphip0 = bb/aa*sinu0 + alt/aa*sinphi0 ;
      rhocosphip0 =       cosu0 + alt/aa*cosphi0 ;
      rho0=sqrt(rhosinphip0*rhosinphip0+rhocosphip0*rhocosphip0);
      if ((rho-rho0)<0) {
         break;
      }
   }
   lat=phi0;
   alt-=0.1;
   *latitude=lat/(DR);
   *altitude=alt;
}

void mc_corearthsatelem(double jj,struct elemorb *elem)
/***************************************************************************/
/* Correction de perturbations de la figure de la Terre pour satellites    */
/***************************************************************************/
/***************************************************************************/
{
   double k_gauss,sini,cosi,e2,a,a2,j2,dt,dws=0,dos=0,dm0s=0,req,n0;
   double k6,k7,k8,k9,h0,k0,ebar,hbar,kbar,betabar,ht,kt,beta;
   /*double p2,ntilda,n;*/
   double e,i,jjd;

   double k1,k2,k3,k4,k5;
   double wbar,mbar,nbar,sqrtmu,abar,w0,m0,req2;

   jjd=jj;

   /*--- perturabtions seculaires dues a l'applatissement de la Terre ---*/
   if (elem->type==4) {
      k_gauss=KGEOS;
      a=elem->q/(1-elem->e); /* U.A. */
      n0=k_gauss/(DR)/pow(a,3./2.); /* deg/day */
      sini=sin(elem->i);
      cosi=cos(elem->i);
      e2=elem->e*elem->e;
      a2=a*a;
      req=(EARTH_SEMI_MAJOR_RADIUS)/(UA); /* equatorial radius of the Earth in U.A. */
      j2=+1.08263e-3*req*req; /* U.A.2 */
      dt=jjd-elem->jj_epoque;
		e=elem->e;
      /* - Dunby */
		/*
      dws=dt*3*n0*j2/(2*a2*(1-e2)*(1-e2))*(5./2.*sini*sini-2.);
      dos=-dt*3*n0*j2/(2*a2*(1-e2)*(1-e2))*cosi;
      dm0s=dt*(-3*j2/(2*a2*pow((1-e2),3./2.))*(3./2.*sini*sini-1.));
      i=elem->i;
      e=elem->e;
		*/
      /* - Kozai */
      /*
      p2=a2*(1.-e2)*(1.-e2);
      ntilda=n0+j2/p2*n0*(1-3./2.*sini*sini)*sqrt(1.-e2);
      dws=dt*j2/p2*ntilda*(2.-5./2.*sini*sini)*3./2.;
      dos=-dt*j2/p2*ntilda*cosi*3./2.;
      dm0s=dt*ntilda*3./2.;
      a=a*(1.-j2/p2*(1.-3./2.*sini*sini)*sqrt(1.-e2));
      i=elem->i;
      e=elem->e;
      */
      /* --- 12540lec05.pdf ---*/
      /*
      req=(EARTH_SEMI_MAJOR_RADIUS)/(UA); // equatorial radius of the Earth in U.A.
      req2=req*req;
      j2=+1.08263e-3;
      ntilda=n0*(1+3./4.*j2*req2/(a2*sqrt((1-e2)*(1-e2)*(1-e2)))*(3.*cosi*cosi-1.));
      dos=-3./2.*j2*req2/(a2*(1-e2)*(1-e2))*n0*cosi; // (16)
      dws=+3./4.*j2*req2/(a2*(1-e2)*(1-e2))*n0*(5.*cosi*cosi-1.); // (17)
      i=elem->i;
      e=elem->e;
      dws*=dt;
      dos*=dt;
      dm0s=(ntilda*dt);
      */
      /* - Born */
      req=(EARTH_SEMI_MAJOR_RADIUS)/(UA); // equatorial radius of the Earth in U.A.
      req2=req*req;
      j2=+1.08263e-3;
      // - secular terms -
      dos=-3./2.*j2*req2/(a2*(1-e2)*(1-e2))*n0*cosi; // (16)
      dws=+3./2.*j2*req2/(a2*(1-e2)*(1-e2))*n0*(2.-5./2.*sini*sini); // (17)
      k1=3./2.*j2*req2/a*sini*sini; // U.A.  // (27)
      w0=elem->w;
      m0=elem->m0;
      abar=a-k1*cos(2*(w0+m0)); // (28a)
      sqrtmu=k_gauss/(DR); // (19)
      nbar=sqrtmu/pow(abar,3./2.); // deg/day  // (19)
      dm0s=nbar+3./2.*j2*req2/(a2*sqrt((1-e2)*(1-e2)*(1-e2)))*n0*(1.-3./2.*sini*sini); // (18)
      wbar=elem->w/(DR)+dws*dt;   // (29)
      mbar=elem->m0/(DR)+dm0s*dt; // (30)
      wbar=fmod(wbar,360.);
      mbar=fmod(mbar,360.);
      wbar*=(DR);
      mbar*=(DR);
      // - periodic terms -
      k2=j2*req2/a2; // (37)
      k3=3./8.*k2*sin(2*elem->i); // (37)
      k4=3./4.*k2*cosi; // (37)
      k5=3./2.*k2; // (37)
      a=abar+k1*cos(2*(wbar+mbar)); // (31)
      e=elem->e + k2*sini*sini*(3./8.*cos(2*wbar+mbar)+7./8.*cos(2*wbar+3*mbar)) + 3./4.*k2*(3*cosi*cosi-1.)*cos(mbar); // (32)
      i=elem->i + k3*cos(2*(wbar+mbar)); // (33)
      // - secular  periodic
      dos =dos*dt  +k4/(DR)*sin(2*(wbar+mbar)); // (34)
      if (elem->e>0.001) {
         dws =dws*dt  +k5/(DR)*( (1.-3./2.*sini*sini)*(1./elem->e*sin(mbar)+0.5*sin(2*mbar)) - 0.5*(1.-5./2.*sini*sini)*sin(2*(wbar+mbar)) + sini*sini* (-1./4./elem->e*sin(2*wbar+mbar)+7./12./elem->e*sin(2*wbar+3*mbar)+3./8.*sin(2*wbar+4*mbar) ) ); // (35)
         dm0s=dm0s*dt +k5/(DR)*(-(1.-3./2.*sini*sini)*(1./elem->e*sin(mbar)+0.5*sin(2*mbar))                                               - sini*sini* (-1./4./elem->e*sin(2*wbar+mbar)+7./12./elem->e*sin(2*wbar+3*mbar)+3./8.*sin(2*wbar+4*mbar) ) ); // (36)
      } else {
         k6=0.25*k2*(6.-21./2.*sini*sini); // (62)
         k7=7./8.*k2*sini*sini;
         k8=0.25*k2*(6.-15./2.*sini*sini);
         k9=3./8.*k2*(3.-5.*cosi*cosi);
         h0=elem->e*sin(elem->w); // (54)
         k0=elem->e*cos(elem->w); // (54)
         ebar=sqrt(h0*h0+k0*k0); // (59c)
         hbar=ebar*sin(wbar);  // (59a)
         kbar=ebar*cos(wbar); // (59b)
         betabar=wbar+mbar; // (58b)
         ht=hbar+k6*sin(betabar)+k7*sin(3*betabar); // (57)
         kt=kbar+k8*cos(betabar)+k7*cos(3*betabar); // (58)
         beta=betabar+k9*sin(2*betabar); // (61)
         e=sqrt(ht*ht+kt*kt); // (63)
         elem->w=atan2(ht,kt); // (64)
         elem->m0=beta-elem->w; // (65)
         dws=0.;
         dm0s=0.;
      }
      /* --- update the elements ---*/
      elem->w/=(DR);
      elem->o/=(DR);
      elem->m0/=(DR);
      elem->w+=dws;
      elem->o+=dos;
      elem->m0+=dm0s;
      elem->q=a*(1-e);
      elem->w=fmod(elem->w,360.);
      elem->o=fmod(elem->o,360.);
      elem->m0=fmod(elem->m0,360.);
      elem->w*=(DR);
      elem->o*=(DR);
      elem->m0*=(DR);
      elem->e=e;
      elem->i=i;
      elem->jj_epoque=jjd;
      //elem->jj_m0=jjd;
   }
}

void mc_refraction(double h,int inout,double temperature,double pressure,double *refraction)
/***************************************************************************/
/* Retourne la valeur de la refraction.                                    */
/***************************************************************************/
/* h hauteur sur l'horizon (radians)                                       */
/* inout = +1 pour le sens "sans air" -> "apparent"                        */
/*            alors h est la hauteur vraie sans air                        */
/*         -1 pour le sens "apparent" -> "sans air"                        */
/*            alors h est la hauteur apparente                             */
/* temperature en K                                                        */
/* Pressure en Pascal                                                      */
/* refraction en radians                                                   */
/* Algo : Meeus "Astronomical Algorithms" p101-103                         */
/***************************************************************************/
{
   double r,angle;
   if (inout==-1) {
      h=h/(DR);
		if (h>-4.3) {
			angle=(h+7.31/(h+4.4))*(DR);
			r=1./tan(angle);
			r=r-0.06*sin((14.7*r+13)*(DR));
			r=r/60.*(DR);
			if (temperature>0.) {
				r=r*fabs(pressure)/101000.*283/temperature;
			}
		} else {
			r=0;
		}
   } else {
      double tolerance = .01 * (DR) / 3600.;
      int n_iter = 10;
      double delta = 1.;

      h=h/(DR);
		if (h>-4.3) {
			angle=(h+10.3/(h+5.11))*(DR);
			r=1.02/tan(angle);
			r=r/60.*(DR);

			if (temperature>0.) {
				r=r*fabs(pressure)/101000.*283/temperature;
			}

			h = h*(DR);
			while( n_iter-- && (delta > tolerance || delta < -tolerance)) {
				delta = r;
				mc_refraction( h + r, -1, temperature, pressure, &r);
				delta -= r;
			}
		} else {
			r=0;
		}
   }
   *refraction=r;
}

void mc_refraction2(double h,int inout,double tk,double ppa, double lnm, double hump, double latd, double altm, double *refraction)
/***************************************************************************/
/* Retourne la valeur de la refraction .                                   */
/***************************************************************************/
/* h hauteur sur l'horizon (radians)                                       */
/* inout = +1 pour le sens "sans air" -> "apparent"                        */
/*            alors h est la hauteur vraie sans air                        */
/*         -1 pour le sens "apparent" -> "sans air"                        */
/*            alors h est la hauteur apparente                             */
/* tk temperature (Kelvin)                                                 */
/* ppa pression atmospherique (Pascal)                                     */
/* lnm longueur d'onde (nm)                                                */
/* hump humidite en pourcent                                               */
/* latd latitude (degres)                                                  */
/* altm altitude (metres)                                                  */
/* Algo : "Introduction aux ephemrides astronomiques" BDL                  */
/* refraction en radians                                                   */
/***************************************************************************/
{
   double r,z,z_in,z_out,dz_out;
	double tolerance = .01 / 3600.;
	int n_iter=0;
	h=h/(DR); // h (deg)
	z=90-h; // z (deg)
   if (inout==-1) {
		z_in = z ; // z = z_in = z0
		mc_refraction_coef_r(z_in*(DR),tk,ppa,lnm,hump,latd,altm,&r);
		// z_out = z_in - r
		// e.g. z0=90 to compute the rise/set of an object
	} else {
		// first estimation of the refraction using the approximation z_in = z_out 
		z_out = z;
		r=0; // first estimation using r(z_in) = 0
		do {
			// itteration estimation of the refraction using the approximation z_in = z_out + r(z_in)
			z_in = z_out + r/60.;
			mc_refraction_coef_r(z_in*(DR),tk,ppa,lnm,hump,latd,altm,&r);
			dz_out = (z_in - r/60.) - z_out;
			n_iter++;
		} while ((fabs(dz_out)>tolerance)&&(n_iter<10));
   }
	r=r/60.*(DR); // arcmin -> radians
   *refraction=r;
}

void mc_refraction_coef_fz(double zdeg,double *fz)
/***************************************************************************/
/* Retourne la valeur du coef f(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* Algo : "Introduction aux ephemrides astronomiques" BDL Table 7.3.1 p194 */
/***************************************************************************/
{
	int n=8;
	double zs[]={35, 40, 45, 50, 55, 60, 65, 70};
	double vals[]={0, 2, 6, 12, 21, 34, 56, 97};
	double res=0;
	int k;
	if (zdeg<=zs[0]) { 
		res=vals[0]; 
	} else if (zdeg>zs[n-1]) { 
		res=vals[n-1]; 
	} else {
		for (k=1;k<n;k++) {
			if ((zdeg>zs[k-1])&&(zdeg<=zs[k])) {
				res=vals[k-1]+(vals[k]-vals[k-1])*(zdeg-zs[k-1])/(zs[k]-zs[k-1]);
				break;
			}
		}
	}
	*fz=res*1e-4;
}

void mc_refraction_coef_gz(double zdeg,double *gz)
/***************************************************************************/
/* Retourne la valeur du coef g(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* Algo : "Introduction aux ephemrides astronomiques" BDL Table 7.3.2 p195 */
/***************************************************************************/
{
	int n=9;
	double   zs[]={0, 10, 20, 30, 40, 50, 60, 65, 70};
	double vals[]={4,  4,  4,  5,  5,  6,  8, 10, 13};
	double res=0;
	int k;
	if (zdeg<=zs[0]) { 
		res=vals[0]; 
	} else if (zdeg>zs[n-1]) { 
		res=vals[n-1]; 
	} else {
		for (k=1;k<n;k++) {
			if ((zdeg>zs[k-1])&&(zdeg<=zs[k])) {
				res=vals[k-1]+(vals[k]-vals[k-1])*(zdeg-zs[k-1])/(zs[k]-zs[k-1]);
				break;
			}
		}
	}
	*gz=res*1e-4;
}

void mc_refraction_coef_r0(double zdeg, double *r0)
/***************************************************************************/
/* Retourne la valeur du coef Ro(z) de la refraction.                      */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* r0 refraction normale (arcmin)                                          */
/* Algo : "Introduction aux ephemrides astronomiques" BDL                  */
/***************************************************************************/
{
	double res,z0,tanz0;
	double r[121],frac,dz;
	int k1,k2;
	if (zdeg<=70) {
		// Formule 7.3.10 (page 194)
		z0=zdeg*(DR);
		tanz0=tan(z0);
		res=(57.085*tanz0-0.0666*tanz0*tanz0*tanz0)/60.;
	} else if (zdeg<=90) {
		// Table 7.3.3 (page 198)
		r[0]=2.59118; r[1]=2.61443; r[2]=2.63802; r[3]=2.66200; r[4]=2.68638; r[5]=2.71112; 
      r[6]=2.73627; r[7]=2.76183; r[8]=2.78785; r[9]=2.81428; r[10]=2.84118; r[11]=2.86853; 
      r[12]=2.89633; r[13]=2.92462; r[14]=2.95338; r[15]=2.98270; r[16]=3.01258; r[17]=3.04290; 
      r[18]=3.07390; r[19]=3.10533; r[20]=3.13747; r[21]=3.17015; r[22]=3.20345; r[23]=3.23742; 
      r[24]=3.27203; r[25]=3.30733; r[26]=3.34333; r[27]=3.38002; r[28]=3.41750; r[29]=3.45572; 
      r[30]=3.49468; r[31]=3.53450; r[32]=3.57518; r[33]=3.61675; r[34]=3.65913; r[35]=3.70253; 
      r[36]=3.74678; r[37]=3.79208; r[38]=3.83838; r[39]=3.88578; r[40]=3.93432; r[41]=3.98390; 
      r[42]=4.03468; r[43]=4.08667; r[44]=4.13988; r[45]=4.19448; r[46]=4.25038; r[47]=4.30763; 
      r[48]=4.36645; r[49]=4.42668; r[50]=4.48858; r[51]=4.55207; r[52]=4.61720; r[53]=4.68413; 
      r[54]=4.75290; r[55]=4.82368; r[56]=4.89630; r[57]=4.97117; r[58]=5.04812; r[59]=5.12730; 
      r[60]=5.20882; r[61]=5.29283; r[62]=5.37947; r[63]=5.46888; r[64]=5.56095; r[65]=5.65612; 
      r[66]=5.75425; r[67]=5.85570; r[68]=5.96058; r[69]=6.06888; r[70]=6.18115; r[71]=6.29722; 
      r[72]=6.41755; r[73]=6.54212; r[74]=6.67143; r[75]=6.80548; r[76]=6.94462; r[77]=7.08922; 
      r[78]=7.23967; r[79]=7.39603; r[80]=7.55890; r[81]=7.72838; r[82]=7.90513; r[83]=8.08960; 
      r[84]=8.28207; r[85]=8.48338; r[86]=8.69358; r[87]=8.91372; r[88]=9.14447; r[89]=9.38618; 
      r[90]=9.63982; r[91]=9.90647; r[92]=10.18658; r[93]=10.48138; r[94]=10.79217; r[95]=11.11985; 
      r[96]=11.46565; r[97]=11.83147; r[98]=12.21825; r[99]=12.62812; r[100]=13.06318; r[101]=13.52505; 
      r[102]=14.01615; r[103]=14.53913; r[104]=15.09693; r[105]=15.69273; r[106]=16.32972; r[107]=17.01173; 
      r[108]=17.73980; r[109]=18.52972; r[110]=19.37532; r[111]=20.28705; r[112]=21.27153; r[113]=22.33617; 
      r[114]=23.49032; r[115]=24.74280; r[116]=26.10530; r[117]=27.59045; r[118]=29.21317; r[119]=30.98908; 
      r[120]=32.96618; 
		dz=6*(zdeg-70);
		k1=(int)(floor(dz));
		if (k1<0) { k1=0; }
		if (k1>119) { 
			res = r[120]; 
		} else {
			k2=k1+1;
			frac=dz-floor(dz);
			res = r[k1] + frac * (r[k2]-r[k1]);
		}
	} else {
      r[0]=32.96618; // 90 
      r[1]=35; 
      r[2]=25; 
      r[3]=15; 
      r[4]=5; 
      r[5]=2; 
      r[6]=1; 
      r[7]=0; // 97 
		dz=(zdeg-90);
		k1=(int)(floor(dz));
		if (k1<0) { k1=0; }
		if (k1>7) { 
			res = r[7]; 
		} else {
			k2=k1+1;
			frac=dz-floor(dz);
			res = r[k1] + frac * (r[k2]-r[k1]);
		}
	}
	*r0=res;
}

void mc_refraction_coef_a(double zdeg, double t, double *a)
/***************************************************************************/
/* Retourne la valeur du coef A(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* t temperature (degres Celcius)                                          */
/* Algo : "Introduction aux ephemrides astronomiques" BDL                  */
/***************************************************************************/
{
	double res,resc1,resc2,fracc,fracl,d;
	double ta[61][4];
	int kc1,kc2,kl1,kl2;
	// Table 7.3.4 (page 199)
   ta[0][0]=1.00000; ta[0][1]=1.00000; ta[0][2]=1.00000; ta[0][3]=1.00000; 
   ta[1][0]=1.00000; ta[1][1]=1.00000; ta[1][2]=1.00000; ta[1][3]=1.00000; 
   ta[2][0]=1.00000; ta[2][1]=1.00000; ta[2][2]=1.00000; ta[2][3]=1.00000; 
   ta[3][0]=1.00000; ta[3][1]=1.00000; ta[3][2]=1.00000; ta[3][3]=1.00000; 
   ta[4][0]=1.00003; ta[4][1]=1.00002; ta[4][2]=1.00000; ta[4][3]=0.99999; 
   ta[5][0]=1.00010; ta[5][1]=1.00005; ta[5][2]=1.00001; ta[5][3]=0.99997; 
   ta[6][0]=1.00020; ta[6][1]=1.00011; ta[6][2]=1.00002; ta[6][3]=0.99994; 
   ta[7][0]=1.00036; ta[7][1]=1.00019; ta[7][2]=1.00004; ta[7][3]=0.99989; 
   ta[8][0]=1.00058; ta[8][1]=1.00031; ta[8][2]=1.00006; ta[8][3]=0.99983; 
   ta[9][0]=1.00096; ta[9][1]=1.00051; ta[9][2]=1.00010; ta[9][3]=0.99970; 
   ta[10][0]=1.00162; ta[10][1]=1.00088; ta[10][2]=1.00017; ta[10][3]=0.99949; 
   ta[11][0]=1.00181; ta[11][1]=1.00099; ta[11][2]=1.00019; ta[11][3]=0.99942; 
   ta[12][0]=1.00205; ta[12][1]=1.00111; ta[12][2]=1.00022; ta[12][3]=0.99935; 
   ta[13][0]=1.00232; ta[13][1]=1.00126; ta[13][2]=1.00025; ta[13][3]=0.99927; 
   ta[14][0]=1.00263; ta[14][1]=1.00144; ta[14][2]=1.00028; ta[14][3]=0.99916; 
   ta[15][0]=1.00303; ta[15][1]=1.00165; ta[15][2]=1.00033; ta[15][3]=0.99904; 
   ta[16][0]=1.00349; ta[16][1]=1.00191; ta[16][2]=1.00038; ta[16][3]=0.99888; 
   ta[17][0]=1.00406; ta[17][1]=1.00222; ta[17][2]=1.00044; ta[17][3]=0.99870; 
   ta[18][0]=1.00476; ta[18][1]=1.00260; ta[18][2]=1.00051; ta[18][3]=0.99847; 
   ta[19][0]=1.00565; ta[19][1]=1.00310; ta[19][2]=1.00061; ta[19][3]=0.99819; 
   ta[20][0]=1.00680; ta[20][1]=1.00372; ta[20][2]=1.00074; ta[20][3]=0.99781; 
   ta[21][0]=1.00751; ta[21][1]=1.00411; ta[21][2]=1.00081; ta[21][3]=0.99759; 
   ta[22][0]=1.00832; ta[22][1]=1.00455; ta[22][2]=1.00090; ta[22][3]=0.99733; 
   ta[23][0]=1.00925; ta[23][1]=1.00506; ta[23][2]=1.00100; ta[23][3]=0.99703; 
   ta[24][0]=1.01035; ta[24][1]=1.00566; ta[24][2]=1.00112; ta[24][3]=0.99668; 
   ta[25][0]=1.01163; ta[25][1]=1.00636; ta[25][2]=1.00126; ta[25][3]=0.99627; 
   ta[26][0]=1.01317; ta[26][1]=1.00720; ta[26][2]=1.00142; ta[26][3]=0.99579; 
   ta[27][0]=1.01498; ta[27][1]=1.00820; ta[27][2]=1.00162; ta[27][3]=0.99520; 
   ta[28][0]=1.01720; ta[28][1]=1.00941; ta[28][2]=1.00185; ta[28][3]=0.99450; 
   ta[29][0]=1.01992; ta[29][1]=1.01088; ta[29][2]=1.00214; ta[29][3]=0.99365; 
   ta[30][0]=1.02328; ta[30][1]=1.01271; ta[30][2]=1.00250; ta[30][3]=0.99260; 
   ta[31][0]=1.02458; ta[31][1]=1.01341; ta[31][2]=1.00264; ta[31][3]=0.99219; 
   ta[32][0]=1.02598; ta[32][1]=1.01417; ta[32][2]=1.00279; ta[32][3]=0.99176; 
   ta[33][0]=1.02750; ta[33][1]=1.01499; ta[33][2]=1.00295; ta[33][3]=0.99129; 
   ta[34][0]=1.02915; ta[34][1]=1.01588; ta[34][2]=1.00312; ta[34][3]=0.99078; 
   ta[35][0]=1.03095; ta[35][1]=1.01686; ta[35][2]=1.00331; ta[35][3]=0.99022; 
   ta[36][0]=1.03290; ta[36][1]=1.01791; ta[36][2]=1.00352; ta[36][3]=0.98962; 
   ta[37][0]=1.03504; ta[37][1]=1.01906; ta[37][2]=1.00374; ta[37][3]=0.98897; 
   ta[38][0]=1.03738; ta[38][1]=1.02031; ta[38][2]=1.00398; ta[38][3]=0.98826; 
   ta[39][0]=1.03995; ta[39][1]=1.02168; ta[39][2]=1.00425; ta[39][3]=0.98748; 
   ta[40][0]=1.04276; ta[40][1]=1.02319; ta[40][2]=1.00454; ta[40][3]=0.98664; 
   ta[41][0]=1.04586; ta[41][1]=1.02485; ta[41][2]=1.00486; ta[41][3]=0.98571; 
   ta[42][0]=1.04930; ta[42][1]=1.02667; ta[42][2]=1.00521; ta[42][3]=0.98468; 
   ta[43][0]=1.05310; ta[43][1]=1.02870; ta[43][2]=1.00560; ta[43][3]=0.98356; 
   ta[44][0]=1.05732; ta[44][1]=1.03094; ta[44][2]=1.00603; ta[44][3]=0.98232; 
   ta[45][0]=1.06204; ta[45][1]=1.03343; ta[45][2]=1.00651; ta[45][3]=0.98094; 
   ta[46][0]=1.06733; ta[46][1]=1.03621; ta[46][2]=1.00704; ta[46][3]=0.97942; 
   ta[47][0]=1.07327; ta[47][1]=1.03932; ta[47][2]=1.00763; ta[47][3]=0.97772; 
   ta[48][0]=1.07996; ta[48][1]=1.04282; ta[48][2]=1.00829; ta[48][3]=0.97583; 
   ta[49][0]=1.08757; ta[49][1]=1.04677; ta[49][2]=1.00904; ta[49][3]=0.97372; 
   ta[50][0]=1.09624; ta[50][1]=1.05124; ta[50][2]=1.00987; ta[50][3]=0.97134; 
   ta[51][0]=1.10616; ta[51][1]=1.05633; ta[51][2]=1.01082; ta[51][3]=0.96867; 
   ta[52][0]=1.11761; ta[52][1]=1.06216; ta[52][2]=1.01190; ta[52][3]=0.96565; 
   ta[53][0]=1.13092; ta[53][1]=1.06886; ta[53][2]=1.01313; ta[53][3]=0.96223; 
   ta[54][0]=1.14647; ta[54][1]=1.07660; ta[54][2]=1.01454; ta[54][3]=0.95833; 
   ta[55][0]=1.16484; ta[55][1]=1.08563; ta[55][2]=1.01617; ta[55][3]=0.95388; 
   ta[56][0]=1.18675; ta[56][1]=1.09623; ta[56][2]=1.01805; ta[56][3]=0.94878; 
   ta[57][0]=1.21316; ta[57][1]=1.10876; ta[57][2]=1.02025; ta[57][3]=0.94289; 
   ta[58][0]=1.24550; ta[58][1]=1.12374; ta[58][2]=1.02283; ta[58][3]=0.93609; 
   ta[59][0]=1.28567; ta[59][1]=1.14184; ta[59][2]=1.02588; ta[59][3]=0.92814; 
   ta[60][0]=1.37050; ta[60][1]=1.17963; ta[60][2]=1.03230; ta[60][3]=0.91170; 
	/* -- interp cols ---*/
	if (t<-30) { t=-30; }
	if (t>30) { t=30; }
	d=(t+30)/20;
	kc1=(int)(floor(d));
	if (kc1>=3) {
		kc1--;
		kc2=kc1+1;
		fracc=1;
	} else {
		kc2=kc1+1;
		fracc=d-floor(d);
	}
	/* -- interp ligs ---*/
	if (zdeg<40) {
		d=(zdeg-0)/10.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<70) {
		d=4+(zdeg-40)/5.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<80) {
		d=10+(zdeg-70)/1.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<85) {
		d=21+(zdeg-80)/0.5;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<90) {
		d=31+(zdeg-85)*6.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else {
		kl1=59;
		kl2=kl1+1;
		fracl=1;
	}
	resc1 = ta[kl1][kc1] + fracl * (ta[kl2][kc1]-ta[kl1][kc1]);
	resc2 = ta[kl1][kc2] + fracl * (ta[kl2][kc2]-ta[kl1][kc2]);
	res   = resc1 + fracc * (resc2-resc1);
	*a=res;
}

void mc_refraction_coef_b(double zdeg, double p, double *b)
/***************************************************************************/
/* Retourne la valeur du coef B(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* p pression atmospherique (Pascal)                                       */
/* Algo : "Introduction aux ephemrides astronomiques" BDL                  */
/***************************************************************************/
{
	double res,resc1,resc2,fracc,fracl,d;
	double tb[40][4];
	int kc1,kc2,kl1,kl2;
	// Table 7.3.5 (page 200)
   tb[0][0]=0.99979; tb[0][1]=0.99989; tb[0][2]=0.99995; tb[0][3]=1.00003; 
   tb[1][0]=0.99979; tb[1][1]=0.99989; tb[1][2]=0.99995; tb[1][3]=1.00003; 
   tb[2][0]=0.99979; tb[2][1]=0.99989; tb[2][2]=0.99995; tb[2][3]=1.00003; 
   tb[3][0]=0.99979; tb[3][1]=0.99988; tb[3][2]=0.99995; tb[3][3]=1.00004; 
   tb[4][0]=0.99979; tb[4][1]=0.99985; tb[4][2]=0.99994; tb[4][3]=1.00004; 
   tb[5][0]=0.99972; tb[5][1]=0.99982; tb[5][2]=0.99993; tb[5][3]=1.00005; 
   tb[6][0]=0.99958; tb[6][1]=0.99974; tb[6][2]=0.99991; tb[6][3]=1.00007; 
   tb[7][0]=0.99951; tb[7][1]=0.99967; tb[7][2]=0.99988; tb[7][3]=1.00009; 
   tb[8][0]=0.99929; tb[8][1]=0.99956; tb[8][2]=0.99985; tb[8][3]=1.00012; 
   tb[9][0]=0.99922; tb[9][1]=0.99952; tb[9][2]=0.99983; tb[9][3]=1.00013; 
   tb[10][0]=0.99915; tb[10][1]=0.99948; tb[10][2]=0.99981; tb[10][3]=1.00015; 
   tb[11][0]=0.99908; tb[11][1]=0.99945; tb[11][2]=0.99980; tb[11][3]=1.00016; 
   tb[12][0]=0.99901; tb[12][1]=0.99937; tb[12][2]=0.99977; tb[12][3]=1.00017; 
   tb[13][0]=0.99887; tb[13][1]=0.99930; tb[13][2]=0.99975; tb[13][3]=1.00019; 
   tb[14][0]=0.99873; tb[14][1]=0.99922; tb[14][2]=0.99973; tb[14][3]=1.00021; 
   tb[15][0]=0.99859; tb[15][1]=0.99915; tb[15][2]=0.99968; tb[15][3]=1.00025; 
   tb[16][0]=0.99838; tb[16][1]=0.99900; tb[16][2]=0.99964; tb[16][3]=1.00028; 
   tb[17][0]=0.99817; tb[17][1]=0.99885; tb[17][2]=0.99959; tb[17][3]=1.00032; 
   tb[18][0]=0.99781; tb[18][1]=0.99867; tb[18][2]=0.99951; tb[18][3]=1.00038; 
   tb[19][0]=0.99739; tb[19][1]=0.99841; tb[19][2]=0.99942; tb[19][3]=1.00044; 
   tb[20][0]=0.99683; tb[20][1]=0.99808; tb[20][2]=0.99930; tb[20][3]=1.00054; 
   tb[21][0]=0.99612; tb[21][1]=0.99760; tb[21][2]=0.99914; tb[21][3]=1.00067; 
   tb[22][0]=0.99500; tb[22][1]=0.99697; tb[22][2]=0.99890; tb[22][3]=1.00085; 
   tb[23][0]=0.99359; tb[23][1]=0.99605; tb[23][2]=0.99857; tb[23][3]=1.00110; 
   tb[24][0]=0.99261; tb[24][1]=0.99546; tb[24][2]=0.99835; tb[24][3]=1.00127; 
   tb[25][0]=0.99142; tb[25][1]=0.99473; tb[25][2]=0.99808; tb[25][3]=1.00148; 
   tb[26][0]=0.98995; tb[26][1]=0.99381; tb[26][2]=0.99774; tb[26][3]=1.00174; 
   tb[27][0]=0.98807; tb[27][1]=0.99267; tb[27][2]=0.99733; tb[27][3]=1.00204; 
   tb[28][0]=0.98695; tb[28][1]=0.99197; tb[28][2]=0.99707; tb[28][3]=1.00227; 
   tb[29][0]=0.98570; tb[29][1]=0.99120; tb[29][2]=0.99679; tb[29][3]=1.00248; 
   tb[30][0]=0.98430; tb[30][1]=0.99032; tb[30][2]=0.99646; tb[30][3]=1.00274; 
   tb[31][0]=0.98278; tb[31][1]=0.98937; tb[31][2]=0.99611; tb[31][3]=1.00302; 
   tb[32][0]=0.98097; tb[32][1]=0.98824; tb[32][2]=0.99570; tb[32][3]=1.00334; 
   tb[33][0]=0.97897; tb[33][1]=0.98696; tb[33][2]=0.99522; tb[33][3]=1.00371; 
   tb[34][0]=0.97662; tb[34][1]=0.98553; tb[34][2]=0.99469; tb[34][3]=1.00414; 
   tb[35][0]=0.97400; tb[35][1]=0.98390; tb[35][2]=0.99407; tb[35][3]=1.00463; 
   tb[36][0]=0.97105; tb[36][1]=0.98197; tb[36][2]=0.99336; tb[36][3]=1.00519; 
   tb[37][0]=0.96755; tb[37][1]=0.97979; tb[37][2]=0.99255; tb[37][3]=1.00584; 
   tb[38][0]=0.96360; tb[38][1]=0.97730; tb[38][2]=0.99160; tb[38][3]=1.00660; 
   tb[39][0]=0.95925; tb[39][1]=0.97452; tb[39][2]=0.99061; tb[39][3]=1.00785; 
	/* -- interp cols ---*/
	if (p<50000) { p=50000; }
	if (p>110000) { p=110000; }
	d=(p-50000)/20000;
	kc1=(int)(floor(d));
	if (kc1>=3) {
		kc1--;
		kc2=kc1+1;
		fracc=1;
	} else {
		kc2=kc1+1;
		fracc=d-floor(d);
	}
	/* -- interp ligs ---*/
	if (zdeg<60) {
		d=(zdeg-0)/10.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<70) {
		d=6+(zdeg-60)/5.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<85) {
		d=8+(zdeg-70)/1.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<87) {
		d=23+(zdeg-85)/0.5;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else if (zdeg<90) {
		d=27+(zdeg-87)*4.;
		kl1=(int)(floor(d));
		kl2=kl1+1;
		fracl=d-floor(d);
	} else {
		kl1=38;
		kl2=kl1+1;
		fracl=1;
	}
	resc1 = tb[kl1][kc1] + fracl * (tb[kl2][kc1]-tb[kl1][kc1]);
	resc2 = tb[kl1][kc2] + fracl * (tb[kl2][kc2]-tb[kl1][kc2]);
	res   = resc1 + fracc * (resc2-resc1);
	*b=res;
}

void mc_refraction_coef_c(double zdeg, double lnm, double *c)
/***************************************************************************/
/* Retourne la valeur du coef C(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* lnm longueur d'onde (nanometres)                                        */
/* Algo : "Introduction aux ephemrides astronomiques" BDL Table 7.3.6 p201 */
/***************************************************************************/
{
	double r90;
	// Interpolation/extrapolation de la Table 7.3.7 (page 201) valable pour toute longueur d'onde.
	if (zdeg>=90) {
		zdeg=90.;
	}
	// --- valeur asymptotique pour la longueur d'onde
	r90=0.99920+1./pow(lnm/55.,3.);
	// --- valeur pour z
	*c = 1.+(r90-1.)*exp( -(90.-zdeg)/2.6 );
}

void mc_refraction_coef_d(double zdeg, double f, double *dd)
/***************************************************************************/
/* Retourne la valeur du coef D(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* f pression partiel de l'eau atmospherique (Pascal)                      */
/* Algo : "Introduction aux ephemrides astronomiques" BDL Table 7.3.7 p201 */
/***************************************************************************/
{
	double res,resc1,resc2,fracc,fracl,d;
	double td[19][6];
	int kc1,kc2,kl1,kl2;
	// Table 7.3.7 (page 201)
   td[0][0]=1.00000; td[0][1]=1.00000; td[0][2]=1.00000; td[0][3]=1.00000; td[0][4]=1.00000; td[0][5]=1.00000; 
   td[1][0]=1.00000; td[1][1]=1.00000; td[1][2]=0.99999; td[1][3]=0.99997; td[1][4]=0.99989; td[1][5]=0.99959; 
   td[2][0]=1.00000; td[2][1]=1.00000; td[2][2]=0.99998; td[2][3]=0.99994; td[2][4]=0.99975; td[2][5]=0.99906; 
   td[3][0]=1.00000; td[3][1]=0.99999; td[3][2]=0.99996; td[3][3]=0.99987; td[3][4]=0.99959; td[3][5]=0.99843; 
   td[4][0]=1.00000; td[4][1]=0.99999; td[4][2]=0.99994; td[4][3]=0.99982; td[4][4]=0.99942; td[4][5]=0.99774; 
   td[5][0]=1.00000; td[5][1]=0.99998; td[5][2]=0.99992; td[5][3]=0.99976; td[5][4]=0.99922; td[5][5]=0.99675; 
   td[6][0]=1.00000; td[6][1]=0.99998; td[6][2]=0.99991; td[6][3]=0.99970; td[6][4]=0.99901; td[6][5]=0.99588; 
   td[7][0]=1.00000; td[7][1]=0.99997; td[7][2]=0.99989; td[7][3]=0.99965; td[7][4]=0.99878; td[7][5]=0.99491; 
   td[8][0]=1.00000; td[8][1]=0.99997; td[8][2]=0.99988; td[8][3]=0.99958; td[8][4]=0.99855; td[8][5]=0.99383; 
   td[9][0]=1.00000; td[9][1]=0.99996; td[9][2]=0.99986; td[9][3]=0.99950; td[9][4]=0.99825; td[9][5]=0.99254; 
   td[10][0]=1.00000; td[10][1]=0.99996; td[10][2]=0.99985; td[10][3]=0.99941; td[10][4]=0.99797; td[10][5]=0.99125; 
   td[11][0]=1.00000; td[11][1]=0.99995; td[11][2]=0.99981; td[11][3]=0.99931; td[11][4]=0.99765; td[11][5]=0.98989; 
   td[12][0]=1.00000; td[12][1]=0.99995; td[12][2]=0.99978; td[12][3]=0.99922; td[12][4]=0.99731; td[12][5]=0.98830; 
   td[13][0]=1.00000; td[13][1]=0.99994; td[13][2]=0.99975; td[13][3]=0.99912; td[13][4]=0.99696; td[13][5]=0.98662; 
   td[14][0]=1.00000; td[14][1]=0.99994; td[14][2]=0.99971; td[14][3]=0.99901; td[14][4]=0.99659; td[14][5]=0.98487; 
   td[15][0]=1.00000; td[15][1]=0.99993; td[15][2]=0.99967; td[15][3]=0.99889; td[15][4]=0.99618; td[15][5]=0.98308; 
   td[16][0]=1.00000; td[16][1]=0.99992; td[16][2]=0.99964; td[16][3]=0.99878; td[16][4]=0.99576; td[16][5]=0.98110; 
   td[17][0]=1.00000; td[17][1]=0.99991; td[17][2]=0.99960; td[17][3]=0.99866; td[17][4]=0.99533; td[17][5]=0.97905; 
   td[18][0]=1.00000; td[18][1]=0.99990; td[18][2]=0.99956; td[18][3]=0.99854; td[18][4]=0.99487; td[18][5]=0.97686; 
	/* -- interp cols ---*/
	if (zdeg<60) { zdeg=60; }
	if (zdeg>90) { zdeg=90; }
	if (zdeg<80) {
		d=(zdeg-60)/10.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else if (zdeg<85) {
		d=2+(zdeg-80)/5.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else if (zdeg<88) {
		d=3+(zdeg-85)/3.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else {
		d=4+(zdeg-88)/2.;
		kc1=(int)(floor(d));
		if (kc1>=5) {
			kc1--;
			kc2=kc1+1;
			fracc=1;			
		} else {
			kc2=kc1+1;
			fracc=d-floor(d);
		}
	}
	/* -- interp ligs ---*/
	if (f<0) { f=0.; }
	if (f>3600) { f=3600.; }
	d=(f-0)/200.;
	kl1=(int)(floor(d));
	kl2=kl1+1;
	fracl=d-floor(d);
	resc1 = td[kl1][kc1] + fracl * (td[kl2][kc1]-td[kl1][kc1]);
	resc2 = td[kl1][kc2] + fracl * (td[kl2][kc2]-td[kl1][kc2]);
	res   = resc1 + fracc * (resc2-resc1);
	*dd=res;
}

void mc_refraction_coef_e(double zdeg, double phi, double *e)
/***************************************************************************/
/* Retourne la valeur du coef E(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* phi latitude du lieu d'observation (deg)                                */
/* Algo : "Introduction aux ephemrides astronomiques" BDL Table 7.3.8 p202 */
/***************************************************************************/
{
	double res,resc1,resc2,fracc,fracl,d;
	double te[10][10];
	int kc1,kc2,kl1,kl2;
	// Table 7.3.8 (page 202)
	te[0][0]=0; te[0][1]=-6; te[0][2]=-23; te[0][3]=-32; te[0][4]=-53; te[0][5]=-90; te[0][6]=-124; te[0][7]=-175; te[0][8]=-255; te[0][9]=-400; 
	te[1][0]=0; te[1][1]=-5; te[1][2]=-21; te[1][3]=-30; te[1][4]=-48; te[1][5]=-85; te[1][6]=-115; te[1][7]=-163; te[1][8]=-240; te[1][9]=-378; 
	te[2][0]=0; te[2][1]=-4; te[2][2]=-16; te[2][3]=-25; te[2][4]=-39; te[2][5]=-69; te[2][6]=-94; te[2][7]=-132; te[2][8]=-195; te[2][9]=-313; 
	te[3][0]=0; te[3][1]=-2.5; te[3][2]=-11; te[3][3]=-18; te[3][4]=-25; te[3][5]=-46; te[3][6]=-62; te[3][7]=-88; te[3][8]=-129; te[3][9]=-210; 
	te[4][0]=0; te[4][1]=-1; te[4][2]=-4; te[4][3]=-5; te[4][4]=-9; te[4][5]=-16; te[4][6]=-22; te[4][7]=-32; te[4][8]=-48; te[4][9]=-87; 
	te[5][0]=0; te[5][1]=0.5; te[5][2]=2; te[5][3]=4; te[5][4]=7; te[5][5]=13; te[5][6]=19; te[5][7]=25; te[5][8]=37; te[5][9]=58; 
	te[6][0]=0; te[6][1]=2; te[6][2]=9; te[6][3]=14; te[6][4]=23; te[6][5]=41; te[6][6]=58; te[6][7]=83; te[6][8]=120; te[6][9]=182; 
	te[7][0]=0; te[7][1]=4; te[7][2]=16; te[7][3]=23; te[7][4]=37; te[7][5]=65; te[7][6]=90; te[7][7]=129; te[7][8]=186; te[7][9]=283; 
	te[8][0]=0; te[8][1]=5; te[8][2]=21; te[8][3]=30; te[8][4]=48; te[8][5]=85; te[8][6]=115; te[8][7]=163; te[8][8]=240; te[8][9]=378; 
	te[9][0]=0; te[9][1]=6; te[9][2]=23; te[9][3]=32; te[9][4]=53; te[9][5]=90; te[9][6]=124; te[9][7]=175; te[9][8]=255; te[9][9]=400; 
	/* -- interp cols ---*/
	if (zdeg<70) {
		d=(zdeg-0)/70.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else if (zdeg<80) {
		d=1+(zdeg-70)/10.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else if (zdeg<86) {
		d=2+(zdeg-80)/2.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else {
		d=5+(zdeg-86)/1.;
		kc1=(int)(floor(d));
		if (kc1>=9) {
			kc1--;
			kc2=kc1+1;
			fracc=1;			
		} else {
			kc2=kc1+1;
			fracc=d-floor(d);
		}
	}
	/* -- interp ligs ---*/
	phi=fabs(phi);
	if (phi<0) { phi=0.; }
	if (phi>90) { phi=90.; }
	d=(phi-0)/10.;
	kl1=(int)(floor(d));
	kl2=kl1+1;
	fracl=d-floor(d);
	resc1 = te[kl1][kc1] + fracl * (te[kl2][kc1]-te[kl1][kc1]);
	resc2 = te[kl1][kc2] + fracl * (te[kl2][kc2]-te[kl1][kc2]);
	res   = resc1 + fracc * (resc2-resc1);
	*e=(res*1e-5);
}

void mc_refraction_coef_h(double zdeg, double altm, double *h)
/***************************************************************************/
/* Retourne la valeur du coef H(z) de la refraction.                       */
/***************************************************************************/
/* zdeg distance zenitale (degres)                                         */
/* altm altitude du lieu d'observation (m)                                 */
/* Algo : "Introduction aux ephemrides astronomiques" BDL Table 7.3.9 p202 */
/***************************************************************************/
{
	double res,fracc,res5000,d,h0;
	double th[5];
	int kc1,kc2;
	// Interpolation/extrapolation d'apres la Table 7.3.9 (page 202)
   th[0]=1.0; th[1]=0.99981; th[2]=0.99587; th[3]=0.96387; th[4]=0.7532; 
	/* -- interp cols ---*/
	if (zdeg<80) {
		d=(zdeg-0)/80.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else if (zdeg<85) {
		d=1+(zdeg-80)/10.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else if (zdeg<88) {
		d=2+(zdeg-80)/3.;
		kc1=(int)(floor(d));
		kc2=kc1+1;
		fracc=d-floor(d);
	} else {
		d=3+(zdeg-88)/2.;
		kc1=(int)(floor(d));
		if (kc1>=4) {
			kc1--;
			kc2=kc1+1;
			fracc=1;			
		} else {
			kc2=kc1+1;
			fracc=d-floor(d);
		}
	}
	res5000 = th[kc1] + fracc * (th[kc2]-th[kc1]);
	h0 = 5000./log(res5000);
	if (altm<-1000) { altm=-1000.; }
	res = exp ( altm/h0 );
	*h=res;
}

void mc_refraction_coef_fsat(double t, double *fsat)
/***************************************************************************/
/* Retourne la valeur de la pression de vapeur saturante de l'eau          */
/***************************************************************************/
/* t temperature (deg Celcius)                                           */
/* fsat pression de vapeur saturante de l'eau (Pascal)                     */
/* Algo :  http://fr.wikipedia.org/wiki/Pression_de_vapeur_saturante       */
/***************************************************************************/
{
	int n=15;
	// deg C
	double   ts[]={  -60,  -40,  -20, -10,    0,    5,   10, 15,     20,   25,   30,   40,  50,  60, 100};
	// mbar
	double vals[]={0.001, 0.13, 1.03, 2.6, 6.10, 8.72, 12.3, 17.0, 23.4, 31.7, 42.4, 73.8, 123, 199, 1013.25 };
	double res=0,logvark1,logvark;
	int k;
	if (t<=ts[0]) { 
		res=vals[0]; 
	} else if (t>ts[n-1]) { 
		res=vals[n-1]; 
	} else {
		for (k=1;k<n;k++) {
			if ((t>ts[k-1])&&(t<=ts[k])) {
				logvark1=log(vals[k-1]);
				logvark=log(vals[k]);
				res=logvark1+(logvark-logvark1)*(t-ts[k-1])/(ts[k]-ts[k-1]);
				res=exp(res);
				break;
			}
		}
	}
	*fsat=res*1e-3*101325;
}

void mc_refraction_coef_r(double z0, double tk, double ppa, double lnm,double hump,double latd, double altm,double *r)
/***************************************************************************/
/* Retourne la valeur du coef R de la refraction (arcmin)                  */
/***************************************************************************/
/* z0 distance zenitale apparente (radians)                                */
/* tk temperature (Kelvin)                                                 */
/* ppa pression atmospherique (Pascal)                                     */
/* lnm longueur d'onde (nm)                                                */
/* hump humidite en pourcent                                               */
/* latd latitude (degres)                                                  */
/* altm altitude (metres)                                                  */
/* Algo : "Introduction aux ephemrides astronomiques" BDL                  */
/***************************************************************************/
{
	double zdeg,r0;
	double p0,a,b,c,t0,l0,f0,f,fsat,e,h;
	double r_tplf,r_tpl,r_tp,l,l2,d,t,p;
	// normal conditions of Poulkovo (1985)
	p0=101325; // Pa
	t0=15; // degC
	l0=0.590; // um
	f0=0; // Pa
	// valeurs par defaut et conversion des unites
	zdeg=z0/(DR);
	// t (degC)
	if (tk==0) {
		t=t0;
	} else {
		t=tk-273.15;
	}
	// p (Pascal)
	if (ppa==0) {
		p=p0;
	} else {
		p=ppa;
	}
	// l (um)
	if (lnm==0) {
		l=l0;
	} else {
		l=lnm/1e3;
	}
	// conversion humidite
	if (hump==0) {
		f=f0;
	} else {
		mc_refraction_coef_fsat(t,&fsat);
		f=hump*fsat/100.;
	}
	// Ro
	mc_refraction_coef_r0(zdeg,&r0);
	// R(t,p)
	mc_refraction_coef_a(zdeg,t,&a);
	mc_refraction_coef_b(zdeg,p,&b);
	r_tp=r0*p/p0*1.0552126*a*b/(1+0.00368084*t);
	// R(t,p,l)
	mc_refraction_coef_c(zdeg,lnm,&c);
	l2=l*l;
	r_tpl=r_tp*(0.98282+0.005981/l2)*c;
	// R(t,p,l,f)
	mc_refraction_coef_d(zdeg,f,&d);
	r_tplf=r_tpl*(1-0.152e-5*f-0.55e-9*f*f)*d;
	// latitude
	mc_refraction_coef_e(zdeg,fabs(latd),&e);
	r_tplf=r_tplf*(1+e);
	// altitude
	mc_refraction_coef_h(zdeg,altm,&h);
	r_tplf=r_tplf*h;
	*r=r_tplf;
}
