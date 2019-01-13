/* mc_nora1.c
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
/* NORAD utilities                                                         */
/* Adapted from Fortran routines public code by NORAD                      */
/* Translated into C by A. Klotz                                           */
/***************************************************************************/
#include "mc.h"

void mc_dpinit(double *eqsq,double *siniq,double *cosiq,double *rteqsq,double *ao,double *cosq2,double *sinomo,double *cosomo,double *bsq,double *xlldot,double *omgdt,double *xnodot,double *xnodp);
void mc_dpsec(double *xll,double *omgasm,double *xnodes,double *em,double *xinc,double *xn,double *t);
void mc_dpper(double *em,double *xinc,double *omgasm,double *xnodes,double *xll);
void mc_thetag(double ep);

/*** variables globales pour les fichiers mc_nora*.c uniquement ***/
double xmo,xnodeo,omegao,eo,xincl,xno,xndt2o,xndd6o,bstar,x,y,z,xdot,ydot,zdot,epoch,ds50;
double ck2,ck4,e6a,qoms2t,s,tothrd,xj3,xke,xkmper,xmnpda,ae;
double de2ra,pi,pio2,twopi,x3pio2;
int method;

/* --- variables de retour des fonctions ---*/
double eqsq,siniq,cosiq,rteqsq,cosq2,sinomo,cosomo,bsq,xlldot;
double omgasm,t;

void mc_norad_sgdp48(double jj,int sgp, struct elemorb *elem,double *xgeo,double *ygeo,double *zgeo,double *vxgeo,double *vygeo,double *vzgeo)
/***************************************************************************/
/* models NORAD SGP, SGP4, SDP4, SGP8, SDP8 for satellites                 */
/***************************************************************************/
/* sgp = 0 for SGP                                                         */
/* sgp = 4 for SGP4                                                        */
/* sgp = 4 for SDP4                                                        */
/* sgp = 8 for SGP8                                                        */
/* sgp = 8 for SDP8                                                        */
/***************************************************************************/
{

	double a1,cosio,theta2,x3thm1,eosq,betao2,betao,del1,ao,delo,xnodp;
	double aodp,s4,qoms24,perige,pinvsq;
	double tsi,eta,etasq,eeta,psisq,coef,coef1,c2,c1,sinio,a3ovk2;
	double c3,x1mth2,c4,c5=0,theta4,temp1,temp2,temp3,xmdot,x1m5th,omgdot;
	double xhdot1,xnodot,omgcof,xmcof,xnodcf,t2cof,xlcof,aycof,delmo,sinmo,x7thm1;
	double c1sq,d2,temp,d3,d4,t3cof,t4cof,t5cof,iflag,xmdf,omgadf;
	double xnoddf,omega,xmp,tsq,xnode,tempa,tempe,templ,delomg,delm;
	double tcube,tfour,a,e,xl,beta;
	double xn,axn,xll,aynl,xlt,ayn,capu,sinepw;
	double cosepw,temp4,temp5,temp6,epw,ecose,esine,elsq;
	double pl,r,rdot,rfdot,betal,cosu,sinu,u;
	double sin2u,cos2u,rk,uk,xnodek,xinck,rdotk,rfdotk;
	double sinuk,cosuk,sinik,cosik,sinnok,cosnok,xmx,xmy,ux,uy,uz;
	double vx,vy,vz,x,y,z,xdot,ydot,zdot;
	int i,isimp;
	double d1,po,xlo,d1o,d2o,d3o,d4o,po2no,omgdt,c6,p;
	double xnodes,omgas,xls,axnsl,aynsl,item3,eo1,tem5,sineo1,coseo1,tem2,el2,pl2,rvdot,su;
	double sing,cosg;
	double em,xmam,xinc;
	/* --- constants decls --- */
	double qo,so,xj2,xj4;
	/* --- orbital elements --- */
	double tsince;
	/* --- variables d'appels aux fonctions ---*/
	double ffeosq,ffsinio,ffcosio,ffbetao,ffaodp,fftheta2,ffsing,ffcosg,ffbetao2,ffxmdot,ffomgdot,ffxnodot,ffxnodp;
	double ffxmdf,ffomgadf,ffxnode,ffem,ffxinc,ffxn,fftsince;
	double ffe,ffxmam;
	/*FILE *f;*/
	/* --- inits ---*/
	xdot=ydot=zdot=x=y=z=0;
	x7thm1=aycof=xlcof=xnodcf=xnodot=omgdot=xmdot=t2cof=0;
	c4=x1mth2=sinio=c1=x3thm1=cosio=t5cof=t4cof=t3cof=0;
	isimp=0;
	d4=d3=d2=sinmo=delmo=xmcof=omgcof=eta=aodp=0;
	/* --- constants inits --- */
	e6a=1e-6;
	pi=4*atan(1);
	de2ra=pi/180.;
	pio2=pi/2;
	qo=120.;
	so=78.;
	tothrd=2./3;
	twopi=2*pi;
	x3pio2=3.*pi/2;
	xj2=1.082616e-3;
	xj3=-.253881e-5;
	xj4=-1.65597e-6;
	xke=.743669161e-1;
	xkmper=6378.135;
	xmnpda=1440.;
	ae=1.;
	ck2=.5*xj2*ae*ae; // ck2=5.413079e-4;
	ck4=-.375*xj4*ae*ae*ae*ae; // ck4=6.209887e-7 ;
	qoms2t=pow(((qo-so)*ae/xkmper),4); // qoms2t=1.880279e-9 ;
	s=ae*(1.+so/xkmper); // s=1.012229;
	/* --- conversion elem->norad variables --- */
   /*
   0         1         2         3         4         5         6         7
    123456789 123456789 123456789 123456789 123456789 123456789 123456789
   TELECOM 2D
   1 24209U 96044B   03262.91033065 -.00000065  00000-0  00000+0 0  8956
   2 24209   0.0626 123.5457 0004535  56.5151 138.1659  1.00273036 26182
   */
   epoch=elem->jj_epoque;
	xno=elem->nrevperday;
	eo=elem->e;
	xndt2o=elem->ndot;
	xndd6o=elem->ndotdot;
	bstar=elem->bstar;
   xnodeo=elem->o;
   omegao=elem->w;
   xmo=elem->m0;
   xincl=elem->i;
	if (xincl==0) {
		xincl=1e-12; /* added by AK to avoid NaN */
	}
	temp=twopi/xmnpda/xmnpda;
	xno=xno*temp*xmnpda;
	xndt2o=xndt2o*temp;
	xndd6o=xndd6o*temp/xmnpda;
	a1=pow((xke/xno),tothrd);
	temp=1.5*ck2*(3*cos(xincl)*cos(xincl)-1.)/pow((1.-eo*eo),1.5);
	del1=temp/(a1*a1);
	ao=a1*(1.-del1*(.5*tothrd+del1*(1.+134./81.*del1)));
	delo=temp/(ao*ao);
	xnodp=xno/(1.+delo);
	if ((twopi/xnodp/xmnpda)>=0.15625) {
		//ideep=1;
		if (sgp==0) {
			method=MC_NORAD_SGP;
		} else if (sgp==8) {
			method=MC_NORAD_SDP8;
		} else {
			method=MC_NORAD_SDP4;
		}
	} else {
		//ideep=0;
		if (sgp==0) {
			method=MC_NORAD_SGP;
		} else if (sgp==8) {
			method=MC_NORAD_SGP8;
		} else {
			method=MC_NORAD_SGP4;
		}
	}
	bstar=bstar/ae;
	tsince=(jj-epoch)*24*60; // tsince expressed in minutes since epoch
	//tsince=1440.;
	//tsince=5100;
   epoch=elem->tle_epoch;
	//method=MC_NORAD_SGP4;
	iflag=1;
	/* =========== */
	/* === SGP === */
	/* =========== */
	if (method==MC_NORAD_SGP) {
		if(iflag==0) {
		} else { //go to 19;
			/* initialization; */
			c1= ck2*1.5;
			c2= ck2/4.0;
			c3= ck2/2.0;
			c4= xj3*ae*ae*ae/(4.0*ck2);
			cosio=cos(xincl);
			sinio=sin(xincl);
			a1=pow((xke/xno),tothrd);
			d1= c1/a1/a1*(3.*cosio*cosio-1.)/pow(1.-eo*eo,1.5);
			ao=a1*(1.-1./3.*d1-d1*d1-134./81.*d1*d1*d1);
			po=ao*(1.-eo*eo);
			qo=ao*(1.-eo);
			xlo=xmo+omegao+xnodeo;
			d1o= c3 *sinio*sinio;
			d2o= c2 *(7.*cosio*cosio-1.);
			d3o=c1*cosio;
			d4o=d3o*sinio;
			po2no=xno/(po*po);
			omgdt=c1*po2no*(5.*cosio*cosio-1.);
			xnodot=-2.*d3o*po2no;
			c5=.5*c4*sinio*(3.+5.*cosio)/(1.+cosio);
			c6=c4*sinio;
			iflag=0;
		}
		/* update for secular gravity and atmospheric drag; */
		a=xno+(2.*xndt2o+3.*xndd6o*tsince)*tsince;
		a=ao*pow(xno/a,tothrd);
		e=e6a;
		if (a>qo) {
			e=1.-qo/a;
		}
		p=a*(1.-e*e);
		xnodes= xnodeo+xnodot*tsince;
		omgas= omegao+omgdt*tsince;
		xls=fmod(xlo+(xno+omgdt+xnodot+(xndt2o+xndd6o*tsince)*tsince)*tsince,twopi);
		/* long period periodics; */
		axnsl=e*cos(omgas);
		aynsl=e*sin(omgas)-c6/p;
		xl=fmod(xls-c5/p*axnsl,twopi);
		/* solve keplers equation; */
		u=fmod(xl-xnodes,twopi);
		item3=0;
		eo1=u;
		tem5=1.;
		do {
			sineo1=sin(eo1);
			coseo1=cos(eo1);
			if (fabs(tem5)<e6a) break;
			if (item3>=10) break;
			item3=item3+1;
			tem5=1.-coseo1*axnsl-sineo1*aynsl;
			tem5=(u-aynsl*coseo1+axnsl*sineo1-eo1)/tem5;
			tem2=fabs(tem5);
			if(tem2>1.) tem5=tem2/tem5;
			eo1=eo1+tem5;
		} while (1==1);
		/* short period preliminary quantities; */
		ecose=axnsl*coseo1+aynsl*sineo1;
		esine=axnsl*sineo1-aynsl*coseo1;
		el2=axnsl*axnsl+aynsl*aynsl;
		pl=a*(1.-el2);
		pl2=pl*pl;
		r=a*(1.-ecose);
		rdot=xke*sqrt(a)/r*esine;
		rvdot=xke*sqrt(pl)/r;
		temp=esine/(1.+sqrt(1.-el2));
		sinu=a/r*(sineo1-aynsl-axnsl*temp);
		cosu=a/r*(coseo1-axnsl+aynsl*temp);
		su=atan2(sinu,cosu);
		/* update for short periodics; */
		sin2u=(cosu+cosu)*sinu;
		cos2u=1.-2.*sinu*sinu;
		rk=r+d1o/pl*cos2u;
		uk=su-d2o/pl2*sin2u;
		xnodek=xnodes+d3o*sin2u/pl2;
		xinck =xincl+d4o/pl2*cos2u;
		/* orientation vectors; */
		sinuk=sin(uk);
		cosuk=cos(uk);
		sinnok=sin(xnodek);
		cosnok=cos(xnodek);
		sinik=sin(xinck);
		cosik=cos(xinck);
		xmx=-sinnok*cosik;
		xmy=cosnok*cosik;
		ux=xmx*sinuk+cosnok*cosuk;
		uy=xmy*sinuk+sinnok*cosuk;
		uz=sinik*sinuk;
		vx=xmx*cosuk-cosnok*sinuk;
		vy=xmy*cosuk-sinnok*sinuk;
		vz=sinik*cosuk;
		/* position and velocity; */
		x=rk*ux;
		y=rk*uy;
		z=rk*uz;
		xdot=rdot*ux;
		ydot=rdot*uy;
		zdot=rdot*uz;
		xdot=rvdot*vx+xdot;
		ydot=rvdot*vy+ydot;
		zdot=rvdot*vz+zdot;
	}
	/* ============ */
	/* === SGP4 === */
	/* ============ */
	if (method==MC_NORAD_SGP4) {
		if (iflag==0) {
		} else {
			a1=pow((xke/xno),tothrd);
			cosio=cos(xincl);
			theta2=cosio*cosio;
			x3thm1=3.*theta2-1.;
			eosq=eo*eo;
			betao2=1.-eosq;
			betao=sqrt(betao2);
			del1=1.5*ck2*x3thm1/(a1*a1*betao*betao2);
			ao=a1*(1.-del1*(.5*tothrd+del1*(1.+134./81.*del1)));
			delo=1.5*ck2*x3thm1/(ao*ao*betao*betao2);
			xnodp=xno/(1.+delo);
			aodp=ao/(1.-delo);
			/*
			* initialization;
			* for perigee less than 220 kilometers, the isimp flag is set and;
			* the equations are truncated to linear variation in sqrt a and;
			* quadratic variation in mean anomaly. also, the c3 term, the;
			* delta omega term, and the delta m term are dropped.;
			*/
			isimp=0;
			if ((aodp*(1.-eo)/ae) < (220./xkmper+ae))  {
				isimp=1;
			}
			/*
			* for perigee below 156 km, the values of;
			* s and qoms2t are altered;
			*/
			s4=s;
			qoms24=qoms2t;
			perige=(aodp*(1.-eo)-ae)*xkmper;
			if(perige < 156) {
				if(perige <= 98) {
					s4 = 20;
				} else {
					s4 = perige-78;
				}
				qoms24 = pow((120-s4)*ae/xkmper,4);
				s4 = s4/xkmper+ae;
			}
			pinvsq=1./(aodp*aodp*betao2*betao2);
			tsi=1./(aodp-s4);
			eta=aodp*eo*tsi;
			etasq=eta*eta;
			eeta=eo*eta;
			psisq=fabs(1.-etasq);
			coef=qoms24*pow(tsi,4);
			coef1=coef/pow(psisq,3.5);
			c2=coef1*xnodp*(aodp*(1.+1.5*etasq+eeta*(4.+etasq))+.75*ck2*tsi/psisq*x3thm1*(8.+3.*etasq*(8.+etasq)));
			c1=bstar*c2;
			sinio=sin(xincl);
			a3ovk2=-xj3/ck2*pow(ae,3);
			c3=coef*tsi*a3ovk2*xnodp*ae*sinio/eo;
			x1mth2=1.-theta2;
			c4=2.*xnodp*coef1*aodp*betao2*(eta*(2.+.5*etasq)+eo*(.5+2.*etasq)-2.*ck2*tsi/(aodp*psisq)*(-3.*x3thm1*(1.-2.*eeta+etasq*(1.5-.5*eeta))+.75*x1mth2*(2.*etasq-eeta*(1.+etasq))*cos(2.*omegao)));
			c5=2.*coef1*aodp*betao2*(1.+2.75*(etasq+eeta)+eeta*etasq);
			theta4=theta2*theta2;
			temp1=3.*ck2*pinvsq*xnodp;
			temp2=temp1*ck2*pinvsq;
			temp3=1.25*ck4*pinvsq*pinvsq*xnodp;
			xmdot=xnodp+.5*temp1*betao*x3thm1+.0625*temp2*betao*(13.-78.*theta2+137.*theta4);
			x1m5th=1.-5.*theta2;
			omgdot=-.5*temp1*x1m5th+.0625*temp2*(7.-114.*theta2+395.*theta4)+temp3*(3.-36.*theta2+49.*theta4);
			xhdot1=-temp1*cosio;
			xnodot=xhdot1+(.5*temp2*(4.-19.*theta2)+2.*temp3*(3.-7.*theta2))*cosio;
			omgcof=bstar*c3*cos(omegao);
			xmcof=-tothrd*coef*bstar*ae/eeta;
			xnodcf=3.5*betao2*xhdot1*c1;
			t2cof=1.5*c1;
			xlcof=.125*a3ovk2*sinio*(3.+5.*cosio)/(1.+cosio);
			aycof=.25*a3ovk2*sinio;
			delmo=pow((1.+eta*cos(xmo)),3);
			sinmo=sin(xmo);
			x7thm1=7.*theta2-1.;
			if (isimp == 1) {
			} else {
				c1sq=c1*c1;
				d2=4.*aodp*tsi*c1sq;
				temp=d2*tsi*c1/3.;
				d3=(17.*aodp+s4)*temp;
				d4=.5*temp*aodp*tsi*(221.*aodp+31.*s4)*c1;
				t3cof=d2+2.*c1sq;
				t4cof=.25*(3.*d3+c1*(12.*d2+10.*c1sq));
				t5cof=.2*(3.*d4+12.*c1*d3+6.*d2*d2+15.*c1sq*(2.*d2+c1sq));
			}
			iflag=0;
		}
		/* update for secular gravity and atmospheric drag; */
		xmdf=xmo+xmdot*tsince;
		omgadf=omegao+omgdot*tsince;
		xnoddf=xnodeo+xnodot*tsince;
		omega=omgadf;
		xmp=xmdf;
		tsq=tsince*tsince;
		xnode=xnoddf+xnodcf*tsq;
		tempa=1.-c1*tsince;
		tempe=bstar*c4*tsince;
		templ=t2cof*tsq;
		if (isimp == 1) { 
		} else {
			delomg=omgcof*tsince;
			delm=xmcof*(pow(1.+eta*cos(xmdf),3)-delmo);
			temp=delomg+delm;
			xmp=xmdf+temp;
			omega=omgadf-temp;
			tcube=tsq*tsince;
			tfour=tsince*tcube;
			tempa=tempa-d2*tsq-d3*tcube-d4*tfour;
			tempe=tempe+bstar*c5*(sin(xmp)-sinmo);
			templ=templ+t3cof*tcube+tfour*(t4cof+tsince*t5cof);
		}
		a=aodp*tempa*tempa;
		e=eo-tempe;
		xl=xmp+omega+xnode+xnodp*templ;
		beta=sqrt(1.-e*e);
		xn=xke/pow(a,1.5);
		/* long period periodics; */
		axn=e*cos(omega);
		temp=1./(a*beta*beta);
		xll=temp*xlcof*axn;
		aynl=temp*aycof;
		xlt=xl+xll;
		ayn=e*sin(omega)+aynl;
		/* solve keplers equation; */
		capu=fmod(xlt-xnode,twopi);
		temp2=capu;
		for (i=1;i<=10;i++) {
			sinepw=sin(temp2);
			cosepw=cos(temp2);
			temp3=axn*sinepw;
			temp4=ayn*cosepw;
			temp5=axn*cosepw;
			temp6=ayn*sinepw;
			epw=(capu-temp4+temp3-temp2)/(1.-temp5-temp6)+temp2;
			if(fabs(epw-temp2) <= e6a) {
				break;
			}
			temp2=epw;
		}
		/* short period preliminary quantities; */
		ecose=temp5+temp6;
		esine=temp3-temp4;
		elsq=axn*axn+ayn*ayn;
		temp=1.-elsq;
		pl=a*temp;
		r=a*(1.-ecose);
		temp1=1./r;
		rdot=xke*sqrt(a)*esine*temp1;
		rfdot=xke*sqrt(pl)*temp1;
		temp2=a*temp1;
		betal=sqrt(temp);
		temp3=1./(1.+betal);
		cosu=temp2*(cosepw-axn+ayn*esine*temp3);
		sinu=temp2*(sinepw-ayn-axn*esine*temp3);
		u=atan2(sinu,cosu);
		sin2u=2.*sinu*cosu;
		cos2u=2.*cosu*cosu-1.;
		temp=1./pl;
		temp1=ck2*temp;
		temp2=temp1*temp;
		/* update for short periodics; */
		rk=r*(1.-1.5*temp2*betal*x3thm1)+.5*temp1*x1mth2*cos2u;
		uk=u-.25*temp2*x7thm1*sin2u;
		xnodek=xnode+1.5*temp2*cosio*sin2u;
		xinck=xincl+1.5*temp2*cosio*sinio*cos2u;
		rdotk=rdot-xn*temp1*x1mth2*sin2u;
		rfdotk=rfdot+xn*temp1*(x1mth2*cos2u+1.5*x3thm1);
		/* orientation vectors; */
		sinuk=sin(uk);
		cosuk=cos(uk);
		sinik=sin(xinck);
		cosik=cos(xinck);
		sinnok=sin(xnodek);
		cosnok=cos(xnodek);
		xmx=-sinnok*cosik;
		xmy=cosnok*cosik;
		ux=xmx*sinuk+cosnok*cosuk;
		uy=xmy*sinuk+sinnok*cosuk;
		uz=sinik*sinuk;
		vx=xmx*cosuk-cosnok*sinuk;
		vy=xmy*cosuk-sinnok*sinuk;
		vz=sinik*cosuk;
		/* position and velocity; */
		x=rk*ux;
		y=rk*uy;
		z=rk*uz;
		xdot=rdotk*ux+rfdotk*vx;
		ydot=rdotk*uy+rfdotk*vy;
		zdot=rdotk*uz+rfdotk*vz;
	}
	/* ============ */
	/* === SDP4 === */
	/* ============ */
	if (method==MC_NORAD_SDP4) {
		if (iflag==0) {
		} else {
			/*
			* recover original mean motion (xnodp) and semimajor axis (aodp);
			* from input elements;
			*/
			a1=pow((xke/xno),tothrd);
			cosio=cos(xincl);
			theta2=cosio*cosio;
			x3thm1=3.*theta2-1.;
			eosq=eo*eo;
			betao2=1.-eosq;
			betao=sqrt(betao2);
			del1=1.5*ck2*x3thm1/(a1*a1*betao*betao2);
			ao=a1*(1.-del1*(.5*tothrd+del1*(1.+134./81.*del1)));
			delo=1.5*ck2*x3thm1/(ao*ao*betao*betao2);
			xnodp=xno/(1.+delo);
			aodp=ao/(1.-delo);
			/*
			* initialization;
			* for perigee below 156 km, the values of;
			* s and qoms2t are altered;
			*/
			s4=s;
			qoms24=qoms2t;
			perige=(aodp*(1.-eo)-ae)*xkmper;
			if(perige >= 156.) {
			} else {
				s4=perige-78.;
				if(perige > 98.) { 
				} else {
					s4=20.;
				}
				qoms24=pow(((120.-s4)*ae/xkmper),4);
				s4=s4/xkmper+ae;
			}
			pinvsq=1./(aodp*aodp*betao2*betao2);
			sing=sin(omegao);
			cosg=cos(omegao);
			tsi=1./(aodp-s4);
			eta=aodp*eo*tsi;
			etasq=eta*eta;
			eeta=eo*eta;
			psisq=fabs(1.-etasq);
			coef=qoms24*pow(tsi,4);
			coef1=coef/pow(psisq,3.5);
			c2=coef1*xnodp*(aodp*(1.+1.5*etasq+eeta*(4.+etasq))+.75*ck2*tsi/psisq*x3thm1*(8.+3.*etasq*(8.+etasq)));
			c1=bstar*c2;
			sinio=sin(xincl);
			a3ovk2=-xj3/ck2*pow(ae,3);
			x1mth2=1.-theta2;
			c4=2.*xnodp*coef1*aodp*betao2*(eta*(2.+.5*etasq)+eo*(.5+2.*etasq)-2.*ck2*tsi/(aodp*psisq)*(-3.*x3thm1*(1.-2.*eeta+etasq*(1.5-.5*eeta))+.75*x1mth2*(2.*etasq-eeta*(1.+etasq))*cos(2.*omegao)));
			theta4=theta2*theta2;
			temp1=3.*ck2*pinvsq*xnodp;
			temp2=temp1*ck2*pinvsq;
			temp3=1.25*ck4*pinvsq*pinvsq*xnodp;
			xmdot=xnodp+.5*temp1*betao*x3thm1+.0625*temp2*betao*(13.-78.*theta2+137.*theta4);
			x1m5th=1.-5.*theta2;
			omgdot=-.5*temp1*x1m5th+.0625*temp2*(7.-114.*theta2+395.*theta4)+temp3*(3.-36.*theta2+49.*theta4);
			xhdot1=-temp1*cosio;
			xnodot=xhdot1+(.5*temp2*(4.-19.*theta2)+2.*temp3*(3.-7.*theta2))*cosio;
			xnodcf=3.5*betao2*xhdot1*c1;
			t2cof=1.5*c1;
			xlcof=.125*a3ovk2*sinio*(3.+5.*cosio)/(1.+cosio);
			aycof=.25*a3ovk2*sinio;
			x7thm1=7.*theta2-1.;
			iflag=0;
			ffeosq=eosq;
			ffsinio=sinio;
			ffcosio=cosio;
			ffbetao=betao;
			ffaodp=aodp;
			fftheta2=theta2;
			ffsing=sing;
			ffcosg=cosg;
			ffbetao2=betao2;
			ffxmdot=xmdot;
			ffomgdot=omgdot;
			ffxnodot=xnodot;
			ffxnodp=xnodp;
			mc_dpinit(&ffeosq,&ffsinio,&ffcosio,&ffbetao,&ffaodp,&fftheta2,&ffsing,&ffcosg,&ffbetao2,&ffxmdot,&ffomgdot,&ffxnodot,&ffxnodp);
			eosq=ffeosq;
			sinio=ffsinio;
			cosio=ffcosio;
			betao=ffbetao;
			aodp=ffaodp;
			theta2=fftheta2;
			sing=ffsing;
			cosg=ffcosg;
			betao2=ffbetao2;
			xmdot=ffxmdot;
			omgdot=ffomgdot;
			xnodot=ffxnodot;
			xnodp=ffxnodp;
			//
			eqsq=ffeosq;
			siniq=ffsinio;
			cosiq=ffcosio;
			rteqsq=ffbetao;
			ao=ffaodp;
			cosq2=fftheta2;
			sinomo=ffsing;
			cosomo=ffcosg;
			bsq=ffbetao2;
			xlldot=ffxmdot;
			omgdt=ffomgdot;
			xnodot=ffxnodot;
			xnodp=ffxnodp;
		}
		/* update for secular gravity and atmospheric drag; */
		xmdf=xmo+xmdot*tsince;
		omgadf=omegao+omgdot*tsince;
		xnoddf=xnodeo+xnodot*tsince;
		tsq=tsince*tsince;
		xnode=xnoddf+xnodcf*tsq;
		tempa=1.-c1*tsince;
		tempe=bstar*c4*tsince;
		templ=t2cof*tsq;
		xn=xnodp;
		ffxmdf=xmdf;
		ffomgadf=omgadf;
		ffxnode=xnode;
		ffem=em=0;
		ffxinc=xinc=0;
		ffxn=xn;
		fftsince=tsince;
		mc_dpsec(&ffxmdf,&ffomgadf,&ffxnode,&ffem,&ffxinc,&ffxn,&fftsince);
		xmdf=ffxmdf;
		omgadf=ffomgadf;
		xnode=ffxnode;
		em=ffem;
		xinc=ffxinc;
		xn=ffxn;
		tsince=fftsince;
		xll=ffxmdf;
		omgasm=ffomgadf;
		xnodes=ffxnode;
		t=fftsince;
		a=pow((xke/xn),tothrd)*tempa*tempa;
		e=em-tempe;
		xmam=xmdf+xnodp*templ;
		ffe=e;
		ffxinc=xinc;
		ffomgadf=omgadf;
		ffxnode=xnode;
		ffxmam=xmam;
		mc_dpper(&ffe,&ffxinc,&ffomgadf,&ffxnode,&ffxmam);
		e=ffe;
		xinc=ffxinc;
		omgadf=ffomgadf;
		xnode=ffxnode;
		xmam=ffxmam;
		em=ffe;
		omgasm=ffomgadf;
		xnodes=ffxnode;
		xll=ffxmam;
		xl=xmam+omgadf+xnode;
		beta=sqrt(1.-e*e);
		xn=xke/pow(a,1.5);
		/* long period periodics; */
		axn=e*cos(omgadf);
		temp=1./(a*beta*beta);
		xll=temp*xlcof*axn;
		aynl=temp*aycof;
		xlt=xl+xll;
		ayn=e*sin(omgadf)+aynl;
		/* solve keplers equation; */
		capu=fmod(xlt-xnode,twopi);
		temp2=capu;
		for (i=1;i<=10;i++) {
			sinepw=sin(temp2);
			cosepw=cos(temp2);
			temp3=axn*sinepw;
			temp4=ayn*cosepw;
			temp5=axn*cosepw;
			temp6=ayn*sinepw;
			epw=(capu-temp4+temp3-temp2)/(1.-temp5-temp6)+temp2;
			if(fabs(epw-temp2) <= e6a) { 
				break;
			}
			temp2=epw;
		}
		/* short period preliminary quantities; */
		ecose=temp5+temp6;
		esine=temp3-temp4;
		elsq=axn*axn+ayn*ayn;
		temp=1.-elsq;
		pl=a*temp;
		r=a*(1.-ecose);
		temp1=1./r;
		rdot=xke*sqrt(a)*esine*temp1;
		rfdot=xke*sqrt(pl)*temp1;
		temp2=a*temp1;
		betal=sqrt(temp);
		temp3=1./(1.+betal);
		cosu=temp2*(cosepw-axn+ayn*esine*temp3);
		sinu=temp2*(sinepw-ayn-axn*esine*temp3);
		u=atan2(sinu,cosu);
		sin2u=2.*sinu*cosu;
		cos2u=2.*cosu*cosu-1.;
		temp=1./pl;
		temp1=ck2*temp;
		temp2=temp1*temp;
		/* update for short periodics; */
		rk=r*(1.-1.5*temp2*betal*x3thm1)+.5*temp1*x1mth2*cos2u;
		uk=u-.25*temp2*x7thm1*sin2u;
		xnodek=xnode+1.5*temp2*cosio*sin2u;
		xinck=xinc+1.5*temp2*cosio*sinio*cos2u;
		rdotk=rdot-xn*temp1*x1mth2*sin2u;
		rfdotk=rfdot+xn*temp1*(x1mth2*cos2u+1.5*x3thm1);
		/* orientation vectors; */
		sinuk=sin(uk);
		cosuk=cos(uk);
		sinik=sin(xinck);
		cosik=cos(xinck);
		sinnok=sin(xnodek);
		cosnok=cos(xnodek);
		xmx=-sinnok*cosik;
		xmy=cosnok*cosik;
		ux=xmx*sinuk+cosnok*cosuk;
		uy=xmy*sinuk+sinnok*cosuk;
		uz=sinik*sinuk;
		vx=xmx*cosuk-cosnok*sinuk;
		vy=xmy*cosuk-sinnok*sinuk;
		vz=sinik*cosuk;
		/* position and velocity; */
		x=rk*ux;
		y=rk*uy;
		z=rk*uz;
		xdot=rdotk*ux+rfdotk*vx;
		ydot=rdotk*uy+rfdotk*vy;
		zdot=rdotk*uz+rfdotk*vz;
	}
	/* conversion units in km and km/sec */
	x=x*xkmper/ae;
	y=y*xkmper/ae;
	z=z*xkmper/ae;
	xdot=xdot*xkmper/ae*xmnpda/86400.;
	ydot=ydot*xkmper/ae*xmnpda/86400.;
	zdot=zdot*xkmper/ae*xmnpda/86400.;
	/*
	f=fopen("c:/d/meo/orbites/audela_res.txt","wt");
	fprintf(f,"x=%.15f\n",x);
	fprintf(f,"y=%.15f\n",y);
	fprintf(f,"z=%.15f\n",z);
	fprintf(f,"xdot=%.15f\n",xdot);
	fprintf(f,"ydot=%.15f\n",ydot);
	fprintf(f,"zdot=%.15f\n",zdot);
	fclose(f);
	*/
	/* conversion units in AU and m/sec */
	*xgeo=x*1e3/(UA);
	*ygeo=y*1e3/(UA);
	*zgeo=z*1e3/(UA);
	*vxgeo=xdot*1e3;
	*vygeo=ydot*1e3;
	*vzgeo=zdot*1e3;
	return;
}

