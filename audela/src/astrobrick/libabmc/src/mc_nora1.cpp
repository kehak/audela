/* mc_nora1.cpp
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
#include <math.h>

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

/*** variables globales pour ce fichier uniquement ***/
double zns,c1ss,zes,znl,c1l,zel,zcosis,zsinis,zsings,zcosgs,zcoshs,zsinhs;
double q22,q31,q33,g22,g32,g44,g52,g54,root22,root32,root44,root52,root54,thdt;
double eq,aqnv,xmao,xpidot,sinq ,cosq,day,thgr,xnq,xqncl,omegaq;
double preep=0.,xnodce,stem,ctem,zcosil,zsinil,zsinhl,zcoshl,c,gam,zmol ;
double zy,zx,zcosgl,zsingl,zmos,ls,savtsn,zcosg;
double zsing,zcosi,zsini,zcosh,zsinh,cc,zn,ze,zmo,xnoi;
double a3,a7,a8,a9,a10,a2,a4,a5,a6,x1,x2;
double x3,x4,x5,x6,x7,x8,z31,z32,z33,z1,z2;
double z3,z11,z12,z13,z21,z22,z23,s3;
double s2,s1,s5,s6,s7,se,si,sl,sgh,sh;
double ee2,e3,xi2,xi3,xl2,xl3,xl4,xgh2,xgh3,xgh4;
double xh2,xh3,sse ,ssi,ssl,ssh,ssg,se2,si2,sl2,sgh2;
double sh2,se3,si3,sl3,sgh3,sh3,sl4,sgh4;
double eoc,g201,g211,g310,g322,g410;
double g422,g520,g533,g521 ;
double g532 ,sini2,f220,f221,f321,f322,f441,f442;
double f522,f523 ,f542 ,f543,xno2,ainv2,d2201 ,d2211 ;
double d3210 ,d3222 ,d4410 ,d4422 ,d5220 ,d5232 ;
double d5421 ,d5433 ,xlamo ,bfact,g200,g300;
double f311,f330,del2,del3,fasx2,fasx4,fasx6;
double xfact,xli,xni,atime,stepp,stepn,step2;
double delt;
double ft,xndot,xnddt ,xomi ,x2omi ,x2li ;
double xldot;
double sinis ,cosis,f2,f3,ses,sis;
double sls,sghs,shs,zm,zf,sinzf,sel,sil,sll;
double sghl,shl,pe,pinc,pgh,ph;
double sinok,cosok,dalf,dbet,alfdp,betdp;
double dls;
double yr,ep,d,theta,thetag;
double a1,s4,temp1,temp,del1;
double omgdtv;
int iret,iretn,ii,jy;
int isynfl,iresfl ;

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
	pi=4*atan(1.);
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


void mc_dpinit(double *eqsq,double *siniq,double *cosiq,double *rteqsq,double *ao,double *cosq2,double *sinomo,double *cosomo,double *bsq,double *xlldot,double *omgdt,double *xnodot,double *xnodp) {
	/* data */
	zns=1.19459e-5;
	c1ss=2.9864797e-6;
	zes=.01675;
	znl=1.5835218e-4;
	c1l=4.7968065e-7;
	zel=.05490;
	zcosis=.91744867;
	zsinis=.39785416;
	zsings=-.98088458;
	zcosgs=.1945905;
	zcoshs=1.0;
	zsinhs=0.0;
	q22=1.7891679e-6;
	q31=2.1460748e-6;
	q33=2.2123015e-7;
	g22=5.7686396;
	g32=0.95240898;
	g44=1.8014998;
	g52=1.0508330;
	g54=4.4108898;
	root22=1.7891679e-6;
	root32=3.7393792e-7;
	root44=7.3636953e-9;
	root52=1.1428639e-7;
	root54=2.1765803e-9;
	thdt=4.3752691e-3;	
	/* entrance for deep space initialization; */
	/* entry dpinit(eqsq,siniq,cosiq,rteqsq,ao,cosq2,sinomo,cosomo,bsq,xlldot,omgdt,xnodot,xnodp) {*/
	mc_thetag(epoch);
	thgr=thetag;
	eq = eo;
	xnq = *xnodp;
	aqnv = 1./(*ao);
	xqncl = xincl;
	xmao=xmo;
	omgdtv=*omgdt;
	xpidot=*omgdt+*xnodot;
	sinq = sin(xnodeo);
	cosq = cos(xnodeo);
	omegaq = omegao;
	/* initialize lunar solar terms; */
	/*5*/ 
//flabel_5:
	day=ds50+18261.5;
	if (day==preep) {
		goto flabel_10;
	}
	preep = day;
	xnodce=4.5236020-9.2422029e-4*day;
	stem=sin(xnodce);
	ctem=cos(xnodce);
	zcosil=.91375164-.03568096*ctem;
	zsinil=sqrt (1.-zcosil*zcosil);
	zsinhl= .089683511*stem/zsinil;
	zcoshl=sqrt (1.-zsinhl*zsinhl);
	c=4.7199672+.22997150*day;
	gam=5.8351514+.0019443680*day;
	zmol = fmod(c-gam,twopi);
	zx= .39785416*stem/zsinil;
	zy= zcoshl*ctem+0.91744867*zsinhl*stem;
	zx=atan2(zx,zy);
	zx=gam+zx-xnodce;
	zcosgl=cos (zx);
	zsingl=sin (zx);
	zmos=6.2565837+.017201977*day;
	zmos=fmod(zmos,twopi);
	/* do solar terms; */
flabel_10:	
	/*10*/ 
	ls = 0;
	savtsn=1e20;
	zcosg=zcosgs;
	zsing=zsings;
	zcosi=zcosis;
	zsini=zsinis;
	zcosh=cosq;
	zsinh=sinq;
	cc=c1ss;
	zn=zns;
	ze=zes;
	zmo=zmos;
	xnoi=1./xnq;
	/*assign 30 to ls;*/
	ls=30;
flabel_20:
	/*20*/
	a1=zcosg*zcosh+zsing*zcosi*zsinh;
	a3=-zsing*zcosh+zcosg*zcosi*zsinh;
	a7=-zcosg*zsinh+zsing*zcosi*zcosh;
	a8=zsing*zsini;
	a9=zsing*zsinh+zcosg*zcosi*zcosh;
	a10=zcosg*zsini;
	a2= *cosiq*a7+ *siniq*a8;
	a4= *cosiq*a9+ *siniq*a10;
	a5=- *siniq*a7+ *cosiq*a8;
	a6=- *siniq*a9+ *cosiq*a10;
	x1=a1*(*cosomo)+a2*(*sinomo);
	x2=a3*(*cosomo)+a4*(*sinomo);
	x3=-a1*(*sinomo)+a2*(*cosomo);
	x4=-a3*(*sinomo)+a4*(*cosomo);
	x5=a5*(*sinomo);
	x6=a6*(*sinomo);
	x7=a5*(*cosomo);
	x8=a6*(*cosomo);
	z31=12.*x1*x1-3.*x3*x3;
	z32=24.*x1*x2-6.*x3*x4;
	z33=12.*x2*x2-3.*x4*x4;
	z1=3.*(a1*a1+a2*a2)+z31*(*eqsq);
	z2=6.*(a1*a3+a2*a4)+z32*(*eqsq);
	z3=3.*(a3*a3+a4*a4)+z33*(*eqsq);
	z11=-6.*a1*a5+(*eqsq) *(-24.*x1*x7-6.*x3*x5);
	z12=-6.*(a1*a6+a3*a5)+(*eqsq) *(-24.*(x2*x7+x1*x8)-6.*(x3*x6+x4*x5));
	z13=-6.*a3*a6+(*eqsq) *(-24.*x2*x8-6.*x4*x6);
	z21=6.*a2*a5+(*eqsq) *(24.*x1*x5-6.*x3*x7);
	z22=6.*(a4*a5+a2*a6)+(*eqsq) *(24.*(x2*x5+x1*x6)-6.*(x4*x7+x3*x8));
	z23=6.*a4*a6+(*eqsq) *(24.*x2*x6-6.*x4*x8);
	z1=z1+z1+*bsq*z31;
	z2=z2+z2+*bsq*z32;
	z3=z3+z3+*bsq*z33;
	s3=cc*xnoi;
	s2=-.5*s3/(*rteqsq);
	s4=s3*(*rteqsq);
	s1=-15.*eq*s4;
	s5=x1*x3+x2*x4;
	s6=x2*x3+x1*x4;
	s7=x2*x4-x1*x3;
	se=s1*zn*s5;
	si=s2*zn*(z11+z13);
	sl=-zn*s3*(z1+z3-14.-6.*(*eqsq));
	sgh=s4*zn*(z31+z33-6.);
	sh=-zn*s2*(z21+z23);
	if (xqncl<5.2359877e-2) { sh=0.0; }
	ee2=2.*s1*s6;
	e3=2.*s1*s7;
	xi2=2.*s2*z12;
	xi3=2.*s2*(z13-z11);
	xl2=-2.*s3*z2;
	xl3=-2.*s3*(z3-z1);
	xl4=-2.*s3*(-21.-9.*(*eqsq))*ze;
	xgh2=2.*s4*z32;
	xgh3=2.*s4*(z33-z31);
	xgh4=-18.*s4*ze;
	xh2=-2.*s2*z22;
	xh3=-2.*s2*(z23-z21);
	/*go to ls;*/
	if (ls==40) {
		goto flabel_40;
	} else if (ls==20) {
		goto flabel_20;
	} else if (ls==30) {
		goto flabel_30;
	} else {
	}
	/* do lunar terms; */
flabel_30:		
	/*30*/
	sse = se;
	ssi=si;
	ssl=sl;
	ssh=sh/(*siniq);
	ssg=sgh-*cosiq*ssh;
	se2=ee2;
	si2=xi2;
	sl2=xl2;
	sgh2=xgh2;
	sh2=xh2;
	se3=e3;
	si3=xi3;
	sl3=xl3;
	sgh3=xgh3;
	sh3=xh3;
	sl4=xl4;
	sgh4=xgh4;
	ls=1;
	zcosg=zcosgl;
	zsing=zsingl;
	zcosi=zcosil;
	zsini=zsinil;
	zcosh=zcoshl*cosq+zsinhl*sinq;
	zsinh=sinq*zcoshl-cosq*zsinhl;
	zn=znl;
	cc=c1l;
	ze=zel;
	zmo=zmol;
	/*assign 40 to ls;*/
	ls=40;
	/*go to 20;*/
	goto flabel_20;
flabel_40:
	/*40*/
	sse = sse+se;
	ssi=ssi+si;
	ssl=ssl+sl;
	ssg=ssg+sgh-*cosiq/(*siniq)*sh;
	ssh=ssh+sh/(*siniq);
	/* geopotential resonance initialization for 12 hour orbits; */
	iresfl=0;
	isynfl=0;
	if ((xnq<.0052359877)&&(xnq>.0034906585)) {
		goto flabel_70;
		/*go to 70;*/
	}
	if ((xnq<8.26e-3)||(xnq>9.24e-3)) { return;  }
	if (eq<0.5) { return;  }
	iresfl =1;
	eoc=eq*(*eqsq);
	g201=-.306-(eq-.64)*.440;
	if (eq>(.65)) {
		/*go to 45;*/
		goto flabel_45;
	}
	g211=3.616-13.247*eq+16.290*(*eqsq);
	g310=-19.302+117.390*eq-228.419*(*eqsq)+156.591*eoc;
	g322=-18.9068+109.7927*eq-214.6334*(*eqsq)+146.5816*eoc;
	g410=-41.122+242.694*eq-471.094*(*eqsq)+313.953*eoc;
	g422=-146.407+841.880*eq-1629.014*(*eqsq)+1083.435*eoc;
	g520=-532.114+3017.977*eq-5740*(*eqsq)+3708.276*eoc;
	/*go to 55;*/
	goto flabel_55;
flabel_45:		
	/*45*/ 
	g211=-72.099+331.819*eq-508.738*(*eqsq)+266.724*eoc;
	g310=-346.844+1582.851*eq-2415.925*(*eqsq)+1246.113*eoc;
	g322=-342.585+1554.908*eq-2366.899*(*eqsq)+1215.972*eoc;
	g410=-1052.797+4758.686*eq-7193.992*(*eqsq)+3651.957*eoc;
	g422=-3581.69+16178.11*eq-24462.77*(*eqsq)+12422.52*eoc;
	if (eq>(.715)) {
		/*go to 50;*/
		goto flabel_50;
	}
	g520=1464.74-4664.75*eq+3763.64*(*eqsq);
	goto flabel_55;
flabel_50:
	/*50*/
	g520=-5149.66+29936.92*eq-54087.36*(*eqsq)+31324.56*eoc;
flabel_55:
	/*55*/ 
	if(eq>=(.7)) {
		/*go to 60;*/
		goto flabel_60;
	}
	g533=-919.2277+4988.61*eq-9064.77*(*eqsq)+5542.21*eoc;
	g521 = -822.71072+4568.6173*eq-8491.4146*(*eqsq)+5337.524*eoc;
	g532 = -853.666+4690.25*eq-8624.77*(*eqsq)+5341.4*eoc;
	/*go to 65;*/
	goto flabel_65;
	/*60*/
flabel_60:
	g533=-37995.78+161616.52*eq-229838.2*(*eqsq)+109377.94*eoc;
	g521 = -51752.104+218913.95*eq-309468.16*(*eqsq)+146349.42*eoc;
	g532 = -40023.88+170470.89*eq-242699.48*(*eqsq)+115605.82*eoc;
	/*65*/ 
flabel_65:
	sini2=*siniq*(*siniq);
	f220=.75*(1.+2.*(*cosiq)+*cosq2);
	f221=1.5*sini2;
	f321=1.875*(*siniq)*(1.-2.*(*cosiq)-3.*(*cosq2));
	f322=-1.875*(*siniq)*(1.+2.*(*cosiq)-3.*(*cosq2));
	f441=35.*sini2*f220;
	f442=39.3750*sini2*sini2;
	f522=9.84375*(*siniq)*(sini2*(1.-2.*(*cosiq)-5.*(*cosq2))+.33333333*(-2.+4.*(*cosiq)+6.*(*cosq2)));
	f523 = (*siniq)*(4.92187512*sini2*(-2.-4.*(*cosiq)+10.*(*cosq2))+6.56250012*(1.+2.*(*cosiq)-3.*(*cosq2)));
	f542 = 29.53125*(*siniq)*(2.-8.*(*cosiq)+*cosq2*(-12.+8.*(*cosiq)+10.*(*cosq2)));
	f543=29.53125*(*siniq)*(-2.-8.*(*cosiq)+*cosq2*(12.+8.*(*cosiq)-10.*(*cosq2)));
	xno2=xnq*xnq;
	ainv2=aqnv*aqnv;
	temp1 = 3.*xno2*ainv2;
	temp = temp1*root22;
	d2201 = temp*f220*g201;
	d2211 = temp*f221*g211;
	temp1 = temp1*aqnv;
	temp = temp1*root32;
	d3210 = temp*f321*g310;
	d3222 = temp*f322*g322;
	temp1 = temp1*aqnv;
	temp = 2.*temp1*root44;
	d4410 = temp*f441*g410;
	d4422 = temp*f442*g422;
	temp1 = temp1*aqnv;
	temp = temp1*root52;
	d5220 = temp*f522*g520;
	d5232 = temp*f523*g532;
	temp = 2.*temp1*root54;
	d5421 = temp*f542*g521;
	d5433 = temp*f543*g533;
	xlamo = xmao+xnodeo+xnodeo-thgr-thgr;
	bfact = *xlldot+*xnodot+*xnodot-thdt-thdt;
	bfact=bfact+ssl+ssh+ssh;
	goto flabel_80;
	/*go to 80;*/		
	/* synchronous resonance terms initialization; */
	/*70*/ 
flabel_70:
	iresfl=1;
	isynfl=1;
	g200=1.0+*eqsq*(-2.5+.8125*(*eqsq));
	g310=1.0+2.0*(*eqsq);
	g300=1.0+*eqsq*(-6.0+6.60937*(*eqsq));
	f220=.75*(1.+*cosiq)*(1.+*cosiq);
	f311=.9375*(*siniq)*(*siniq)*(1.+3.*(*cosiq))-.75*(1.+*cosiq);
	f330=1.+*cosiq;
	f330=1.875*f330*f330*f330;
	del1=3.*xnq*xnq*aqnv*aqnv;
	del2=2.*del1*f220*g200*q22;
	del3=3.*del1*f330*g300*q33*aqnv;
	del1=del1*f311*g310*q31*aqnv;
	fasx2=.13130908;
	fasx4=2.8843198;
	fasx6=.37448087;
	xlamo=xmao+xnodeo+omegao-thgr;
	bfact = *xlldot+xpidot-thdt;
	bfact=bfact+ssl+ssg+ssh;
	/*80*/ 
flabel_80:
	xfact=bfact-xnq;
	/* initialize integrator;*/
	xli=xlamo;
	xni=xnq;
	atime=0.; //d0;
	stepp=720.; //d0;
	stepn=-720.; //d0;
	step2 = 259200.; //d0;
	return;
}

void mc_dpsec(double *xll,double *omgasm,double *xnodes,double *em,double *xinc,double *xn,double *t) {
	/* entrance for deep space secular effects;*/
	/* entry dpsec(xll,omgasm,xnodes,em,xinc,xn,t) {*/
	double xl;
	*xll=*xll+ssl*(*t);
	*omgasm=*omgasm+ssg*(*t);
	*xnodes=*xnodes+ssh*(*t);
	*em=eo+sse*(*t);
	*xinc=xincl+ssi*(*t);
	if(*xinc >= 0.) { 
		/*go to 90;*/
		goto flabel_90;
	}
	*xinc = -*xinc;
	*xnodes = *xnodes + pi;
	*omgasm = *omgasm - pi;
	/*90*/
flabel_90:
	if(iresfl == 0) { return; }
	/*100*/
flabel_100:
	if (atime==0.) {
		/*go to 170;*/
		goto flabel_170; 
	}
	if (((*t)>=0.)&&(atime<0.)) {
		/* go to 170; */
		goto flabel_170;
	}
	if (((*t)<0)&&(atime>=0)) {
		/*go to 170;*/
		goto flabel_170;
	}
	/*105*/
//flabel_105:
	if (fabs((*t))>=fabs(atime)) {
		/*go to 120;*/
		goto flabel_120;
	}
	delt=stepp;
	if ((*t)>=0.) { delt = stepn; }
	/*110*/
//flabel_110:
	/*assign 100 to iret;*/
	iret=100;
	/*go to 160;*/
	goto flabel_160;		
	/*120*/
flabel_120:
	delt=stepn;
	if ((*t)>0.) { delt = stepp; }
	/*125*/
flabel_125:
	if (fabs((*t)-atime)<stepp) {
		/*go to 130;*/
		goto flabel_130;
	}
	/*assign 125 to iret;*/
	iret=125;
	/*go to 160;*/
	goto flabel_160;
	/*130*/
flabel_130:
	ft = (*t)-atime;
	/*assign 140 to iretn;*/
	iretn=140;
	/*go to 150;*/
	goto flabel_150;
	/*140*/
flabel_140:
	*xn = xni+xndot*ft+xnddt*ft*ft*0.5;
	xl = xli+xldot*ft+xndot*ft*ft*0.5;
	temp = -*xnodes+thgr+(*t)*thdt;
	*xll = xl-*omgasm+temp;
	if (isynfl==0) { *xll = xl+temp+temp; }		
	return;
	/* dot terms calculated; */
flabel_150:
	/*150*/
	if (isynfl==0) {
		/*go to 152;*/
		goto flabel_152;
	}
	xndot=del1*sin (xli-fasx2)+del2*sin (2.*(xli-fasx4))+del3*sin (3.*(xli-fasx6));
	xnddt = del1*cos(xli-fasx2)+2.*del2*cos(2.*(xli-fasx4))+3.*del3*cos(3.*(xli-fasx6));
	/*go to 154;*/
	goto flabel_154;
	/*152*/
flabel_152:
	xomi = omegaq+omgdtv*atime;
	x2omi = xomi+xomi;
	x2li = xli+xli;
	xndot = d2201*sin(x2omi+xli-g22)+d2211*sin(xli-g22)+d3210*sin(xomi+xli-g32)+d3222*sin(-xomi+xli-g32)+d4410*sin(x2omi+x2li-g44)+d4422*sin(x2li-g44)+d5220*sin(xomi+xli-g52)+d5232*sin(-xomi+xli-g52)+d5421*sin(xomi+x2li-g54)+d5433*sin(-xomi+x2li-g54);
	xnddt = d2201*cos(x2omi+xli-g22)+d2211*cos(xli-g22)+d3210*cos(xomi+xli-g32)+d3222*cos(-xomi+xli-g32)+d5220*cos(xomi+xli-g52)+d5232*cos(-xomi+xli-g52)+2.*(d4410*cos(x2omi+x2li-g44)+d4422*cos(x2li-g44)+d5421*cos(xomi+x2li-g54)+d5433*cos(-xomi+x2li-g54));
	/*154*/ 
flabel_154:		
	xldot=xni+xfact;
	xnddt = xnddt*xldot;
	/*go to iretn;*/
	if (iretn==140) {
		goto flabel_140;
	} else if (iretn==165) {
		goto flabel_165;
	}
	/* integrator; */
	/*160*/
flabel_160:		
	/*assign 165 to iretn;*/
	iretn=165;
	/*go to 150;*/
	goto flabel_150;
	/*165*/
flabel_165:
	xli = xli+xldot*delt+xndot*step2;
	xni = xni+xndot*delt+xnddt*step2;
	atime=atime+delt;
	/*go to iret;*/
	if (iret==100) {
		goto flabel_100;
	} else if (iret==125) {
		goto flabel_125;
	}
	/* epoch restart; */
	/*170*/
flabel_170:		
	if ((*t)>=0.) {
		/*go to 175;*/
		goto flabel_175;
	}
	delt=stepn;
	/*go to 180;*/
	goto flabel_180;
	/*175*/ 
flabel_175:
	delt = stepp;
	/*180*/ 
flabel_180:
	atime = 0.;
	xni=xnq;
	xli=xlamo;
	/*go to 125;*/
	goto flabel_125;
	return;
}

void mc_dpper(double *em,double *xinc,double *omgasm,double *xnodes,double *xll) {
	/* entrances for lunar-solar periodics;*/
	/* entry dpper(em,xinc,omgasm,xnodes,xll) {*/
	double sinis ,cosis,f2,f3,ses,sis;
	double sls,sghs,shs,zm,zf,sinzf,sel,sil,sll;
	double sghl,shl,pe,pinc,pgh,ph;
	double sinok,cosok,dalf,dbet,alfdp,betdp;
	double dls;
	double pl,xls;
	double xnoh;
	/* --- inits ---*/
	pl=pinc=pe=shl=sghl=shs=sghs=0;
	/* --- calculs ---*/
	sinis = sin(*xinc);
	cosis = cos(*xinc);
	if (fabs(savtsn-t)<(30.)) {
		/*go to 210;*/
		goto flabel_210;
	}
	savtsn=t;
	zm=zmos+zns*t;
	/*205*/
//flabel_205:
	zf=zm+2.*zes*sin(zm);
	sinzf=sin (zf);
	f2=.5*sinzf*sinzf-.25;
	f3=-.5*sinzf*cos(zf);
	ses=se2*f2+se3*f3;
	sis=si2*f2+si3*f3;
	sls=sl2*f2+sl3*f3+sl4*sinzf;
	sghs=sgh2*f2+sgh3*f3+sgh4*sinzf;
	shs=sh2*f2+sh3*f3;
	zm=zmol+znl*t;
	zf=zm+2.*zel*sin(zm);
	sinzf=sin(zf);
	f2=.5*sinzf*sinzf-.25;
	f3=-.5*sinzf*cos(zf);
	sel=ee2*f2+e3*f3;
	sil=xi2*f2+xi3*f3;
	sll=xl2*f2+xl3*f3+xl4*sinzf;
	sghl=xgh2*f2+xgh3*f3+xgh4*sinzf;
	shl=xh2*f2+xh3*f3;
	pe=ses+sel;
	pinc=sis+sil;
	pl=sls+sll;
	/*210*/ 
flabel_210:
	pgh=sghs+sghl;
	ph=shs+shl;
	*xinc = *xinc+pinc;
	*em = *em+pe;
	if (xqncl<(.2)) {
		/*go to 220;*/
		goto flabel_220;
	}
	/*go to 218;*/
	goto flabel_218;
	/* apply periodics directly; */
	/*218*/
flabel_218:		
	ph=ph/siniq;
	pgh=pgh-cosiq*ph;
	*omgasm=*omgasm+pgh;
	*xnodes=*xnodes+ph;
	*xll = *xll+pl;
	/*go to 230;*/
	goto flabel_230;
	/* apply periodics with lyddane modification;*/
	/*220*/
flabel_220:
	sinok=sin(*xnodes);
	cosok=cos(*xnodes);
	alfdp=sinis*sinok;
	betdp=sinis*cosok;
	dalf=ph*cosok+pinc*cosis*sinok;
	dbet=-ph*sinok+pinc*cosis*cosok;
	alfdp=alfdp+dalf;
	betdp=betdp+dbet;
	xls = *xll+*omgasm+cosis*(*xnodes);
	dls=pl+pgh-pinc*(*xnodes)*sinis;
	xls=xls+dls;
	xnoh=*xnodes;
	*xnodes=atan2(alfdp,betdp);

	/* This is a patch to Lyddane modification */
	/* suggested by Rob Matson. */
	if(fabs(xnoh-*xnodes) > pi) {
		if(*xnodes < xnoh) {
			*xnodes =*xnodes+twopi;
		} else {
			*xnodes =*xnodes-twopi;
		}
	}

	*xll = *xll+pl;
	*omgasm = xls-*xll-cos(*xinc)*(*xnodes);
	/*230 continue;*/
flabel_230:
	return;
}

void mc_thetag(double ep) {
	/*
	double yr,d,theta,temp,thetag;
	int jy,ii,n;
	*/
	double yr,d,theta,thetag;
	int jy,ii,n;
	yr=(ep+2e-7)*1e-3;
	jy=(int)yr;
	yr=jy;
	d=ep-yr*1e3;
	if (jy<10) {
		jy=jy+80;
	}
	n=(jy-69)/4;
	if (jy<70) {
		n=(jy-72)/4;
	}
	ds50=7305.+365.*(jy-70)+n+d;
	theta=1.72944494 + 6.3003880987*ds50;
	temp=theta/twopi;
	ii=(int)temp;
	temp=ii;
	thetag=theta-temp*twopi;
	if (thetag<0) {
		thetag=thetag+twopi;
	}
	return;
}
