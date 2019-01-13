/* mc_scdl1.c
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
/* Scheduler d'observations                                                */
/***************************************************************************/
#include "mc.h"
#include "time.h"
int mc_printplani(int npl,mc_PLANI **plani);
int mc_printobject(int njd,mc_SUNMOON *sunmoon,mc_OBJECTLOCAL *objectlocal);
int mc_printusers(int nu,mc_USERS *users);

/*****************************************************************************/
/*****************************************************************************/
/* Compute the start and end dates for the next observing range.             */
/* The observing range is based on consecutive meridian passages of the Sun. */
/* Outputs : jd_prevmidsun and jd_nextmidsun                                 */
/*****************************************************************************/
int mc_scheduler_windowdates1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,double *jd_prevmidsun, double *jd_nextmidsun) {

	double jd,djd,latitude,altitude,jd_max,jd1,jd2,dt;
	int k,astrometric;
	double ra,dec,delta,mag,diamapp,elong,phase,r,diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north,long1_sun,lati_sun;
	double ha,ha1=0;

	// --- initialize
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	astrometric=0;
	mc_tdminusut(jd_now,&dt);
	dt/=86400.;

	// --- searching for gross jd_prevmidsun (=previous meridian)
	djd=60./86400;
	jd1=jd_now;
	jd2=jd1-2.;
	for (jd=jd1,k=0;jd>=jd2;jd-=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; if (ha>0.05) { jd=jd-ha/2/(PI)+0.05; } continue; }
		if ((ha1<PI)&&(ha>PI)) { break; }
		ha1=ha;
	}
	jd_max=jd+djd/2;

	// --- searching for fine jd_prevmidsun (=previous meridian)
	djd=1./86400;
	jd1=jd_max+90./86400;
	jd2=jd_max-90./86400;
	for (jd=jd1,k=0;jd>=jd2;jd-=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; continue; }
		if ((ha1<PI)&&(ha>PI)) { break; }
		ha1=ha;
	}
	*jd_prevmidsun=jd+djd/2;

	// --- searching for gross jd_nextmidsun (=next meridian)
	djd=60./86400;
	jd1=jd_now;
	jd2=jd1+2.;
	for (jd=jd1,k=0;jd<=jd2;jd+=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
	   mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; if (ha>(2*(PI)-0.05)) { jd=jd+ha/2/(PI)-0.05; } continue; }
		if ((ha1>PI)&&(ha<PI)) { break; }
		ha1=ha;
	}
	jd_max=jd-djd/2;

	// --- searching for fine jd_nextmidsun (=next meridian)
	djd=1./86400;
	jd1=jd_max-90./86400;
	jd2=jd_max+90./86400;
	for (jd=jd1,k=0;jd<=jd2;jd+=djd,k++) {
		mc_adsolap(jd+dt,jd+dt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
		mc_ad2hd(jd,longmpc,ra,&ha);
		if (k==0) { ha1=ha; continue; }
		if ((ha1>PI)&&(ha<PI)) { break; }
		ha1=ha;
	}
	*jd_nextmidsun=jd-djd/2;
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Compute the vector of local conditions for Sun and Moon.                  */
/* Outputs : njd, sunmoon                                                    */
/*****************************************************************************/
int mc_scheduler_sunmoon1(double longmpc, double rhocosphip, double rhosinphip,double jd_prevmidsun, double jd_nextmidsun,double djd, int *pnjd, mc_SUNMOON **psunmoon) {
	double jd,latitude,altitude,da,dh;
	int astrometric,njd,njdm;
	double ra,dec,delta,mag,diamapp,elong,phase,r,diamapp_equ,diamapp_pol,long1,long2,long3,lati,posangle_sun,posangle_north,long1_sun,lati_sun;
	double ha,az,h,dt,jdtt,latrad,tsl,djdm;
	mc_SUNMOON *sunmoon=NULL;
	double *dummy1s,*dummy2s,*dummy3s,*dummy4s,*dummy5s,*dummy6s;
	int kjd;

	// --- initialize
	*pnjd=0;
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	latrad=latitude*(DR);
	astrometric=0;

	// --- prepare sur-ech vectors
	//djd=1./86400.;
	njd=(int)ceil((jd_nextmidsun-jd_prevmidsun)/djd);
	sunmoon=(mc_SUNMOON*)calloc(njd+1,sizeof(mc_SUNMOON));
	*psunmoon=sunmoon;
	*pnjd=njd;
	for (kjd=0;kjd<=njd;kjd++) {
		jd=jd_prevmidsun+(jd_nextmidsun-jd_prevmidsun)*kjd/njd;
		sunmoon[kjd].jd=jd;
	}
	dummy5s=(double*)calloc(njd+2,sizeof(double)); // jd sur-ech
	for (kjd=0;kjd<=njd;kjd++) {
		dummy5s[kjd+1]=sunmoon[kjd].jd;
	}
	dummy6s=(double*)calloc(njd+2,sizeof(double)); // angle sur-ech

	// --- prepare sous-ech vectors
	djdm=1./24.;
	njdm=2+(int)ceil((jd_nextmidsun-jd_prevmidsun)/djdm);
	mc_tdminusut(jd_prevmidsun,&dt);
	dt/=86400.;
	dummy1s=(double*)calloc(njdm+2,sizeof(double)); // jd sous-ech
	dummy2s=(double*)calloc(njdm+2,sizeof(double)); // ra ou tsl sous-ech
	dummy3s=(double*)calloc(njdm+2,sizeof(double)); // dec sous-ech
	dummy4s=(double*)calloc(njdm+2,sizeof(double)); // phase sous-ech
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=-djdm/2+jd_prevmidsun+(jd_nextmidsun-jd_prevmidsun)*kjd/njdm;
		dummy1s[kjd]=jd;
	}

	// --- local sideral time during the night
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=dummy1s[kjd];
		mc_tsl(jd,-longmpc,&tsl);
		dummy2s[kjd]=tsl/(DR);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360*ceil(-da/360.); }
			if (da> 180) { dummy2s[kjd]-=360*ceil(da/360.); }
		}
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // lst
	for (kjd=0;kjd<=njd;kjd++) {
		dummy6s[kjd+1]=fmod(dummy6s[kjd+1]+1440,360);
		sunmoon[kjd].lst=dummy6s[kjd+1]; // lst
	}

	// --- sun parameters during the night
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=dummy1s[kjd];
		jdtt=jd+dt;
		mc_adsolap(jdtt,jdtt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
		dummy2s[kjd]=ra/(DR);
		dummy3s[kjd]=dec/(DR);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360*ceil(-da/360.); }
			if (da> 180) { dummy2s[kjd]-=360*ceil(da/360.); }
		}
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // ra
	for (kjd=0;kjd<=njd;kjd++) {
		dummy6s[kjd+1]=fmod(dummy6s[kjd+1]+1440,360);
		sunmoon[kjd].sun_az=dummy6s[kjd+1]; // ra
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy3s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // dec
	for (kjd=0;kjd<=njd;kjd++) {
		sunmoon[kjd].sun_elev=dummy6s[kjd+1]; // dec
	}
	for (kjd=0;kjd<=njd;kjd++) {
		ra=sunmoon[kjd].sun_az; // ra
		dec=sunmoon[kjd].sun_elev*(DR); // dec
		ha=(sunmoon[kjd].lst-ra)*(DR);
		mc_hd2ah(ha,dec,latrad,&az,&h);
		sunmoon[kjd].sun_az=az/(DR); // az
		if (kjd>=8450) {
			kjd+=0;
		}
		mc_refraction(h,1,283,101325,&dh);
		sunmoon[kjd].sun_elev=(h+dh)/(DR); // elev
	}

	// --- moon parameters during the night
	for (kjd=0;kjd<=njdm+1;kjd++) {
		jd=dummy1s[kjd];
		jdtt=jd+dt;
		mc_adlunap(LUNE,jdtt,jd,jdtt,astrometric,longmpc,rhocosphip,rhosinphip,&ra,&dec,&delta,&mag,&diamapp,&elong,&phase,&r,&diamapp_equ,&diamapp_pol,&long1,&long2,&long3,&lati,&posangle_sun,&posangle_north,&long1_sun,&lati_sun);
		dummy2s[kjd]=ra/(DR);
		dummy3s[kjd]=dec/(DR);
		dummy4s[kjd]=phase/(DR);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360*ceil(-da/360.); }
			if (da> 180) { dummy2s[kjd]-=360*ceil(da/360.); }
		}
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // ra
	for (kjd=0;kjd<=njd;kjd++) {
		dummy6s[kjd+1]=fmod(dummy6s[kjd+1]+1440,360);
		sunmoon[kjd].moon_az=dummy6s[kjd+1]; // ra
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy3s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // dec
	for (kjd=0;kjd<=njd;kjd++) {
		sunmoon[kjd].moon_elev=dummy6s[kjd+1]; // dec
	}
	mc_interplin1(0,njdm+1,dummy1s,dummy4s,dummy1s,0.5,njd+1,dummy5s,dummy6s); // dec
	for (kjd=0;kjd<=njd;kjd++) {
		sunmoon[kjd].moon_phase=dummy6s[kjd+1]; // dec
	}
	for (kjd=0;kjd<=njd;kjd++) {
		ra=sunmoon[kjd].moon_az; // ra
		dec=sunmoon[kjd].moon_elev*(DR); // dec
		ha=(sunmoon[kjd].lst-ra)*(DR);
		mc_hd2ah(ha,dec,latrad,&az,&h);
		sunmoon[kjd].moon_az=az/(DR); // az
		sunmoon[kjd].moon_elev=h/(DR); // elev
		mc_refraction(h,1,283,101325,&dh);
		sunmoon[kjd].moon_elev=(h+dh)/(DR); // elev
	}

	free(dummy1s);
	free(dummy2s);
	free(dummy3s);
	free(dummy4s);
	free(dummy5s);
	free(dummy6s);
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Correction of coordinates                                                 */
/* Outputs : objectdescr                                                     */
/*****************************************************************************/
int mc_sheduler_corccoords(mc_OBJECTDESCR *objectdescr) {
	int n,k;
	double ra,cosdec,mura,mudec,parallax;
	double dec,asd2,dec2;
	double jd;
	n=objectdescr->axe_njd;
	if (objectdescr->axe_type==0) {
		for (k=0;k<n;k++) {
			jd=objectdescr->axe_jd[k];
			/* === CALCULS === */
			ra=objectdescr->axe_pos1[k]*(DR);
			dec=objectdescr->axe_pos2[k]*(DR);
			cosdec=cos(dec);
			mura=objectdescr->axe_mura*1e-3/86400/cosdec;
			mudec=objectdescr->axe_mudec*1e-3/86400;
			parallax=objectdescr->axe_plx;
			/* --- aberration annuelle ---*/
			mc_aberration_annuelle(jd,ra,dec,&asd2,&dec2,1);
			ra=asd2;
			dec=dec2;
			/* --- calcul de mouvement propre ---*/
			ra+=(jd-objectdescr->axe_epoch)/365.25*mura;
			dec+=(jd-objectdescr->axe_epoch)/365.25*mudec;
			objectdescr->axe_epoch=jd;
			/* --- calcul de la precession ---*/
			mc_precad(objectdescr->axe_equinox,ra,dec,jd,&asd2,&dec2);
			ra=asd2;
			dec=dec2;
			objectdescr->axe_equinox=jd;
			/* --- correction de parallaxe stellaire*/
			if (parallax>0) {
				mc_parallaxe_stellaire(jd,ra,dec,&asd2,&dec2,parallax);
				ra=asd2;
				dec=dec2;
			}
			/* --- correction de nutation */
			mc_nutradec(jd,ra,dec,&asd2,&dec2,1);
			ra=asd2;
			dec=dec2;
			/* --- aberration de l'aberration diurne*/
			/*
			mc_aberration_diurne(jd,ra,dec,longmpc,rhocosphip,rhosinphip,&asd2,&dec2,1);
			ra=asd2;
			dec=dec2;
			*/
			objectdescr->axe_pos1[k]=ra/(DR);
			objectdescr->axe_pos2[k]=dec/(DR);
		}
	}
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Conversion of apparent coordinates to J2000                               */
/* Outputs : objectdescr                                                     */
/*****************************************************************************/
int mc_sheduler_coord_app2cat(double jd,double ra,double dec,double equinox,double *racat,double *deccat) {
	double asd2,dec2;
	/* --- aberration annuelle ---*/
	mc_aberration_annuelle(jd,ra,dec,&asd2,&dec2,-1);
	ra=asd2;
	dec=dec2;
	/* --- calcul de la precession ---*/
	mc_precad(jd,ra,dec,equinox,&asd2,&dec2);
	ra=asd2;
	dec=dec2;
	/* --- correction de nutation */
	mc_nutradec(jd,ra,dec,&asd2,&dec2,-1);
	ra=asd2;
	dec=dec2;
	*racat=ra;
	*deccat=dec;
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Compute local parameters for a given date index k of mc_SUNMOON           */
/* elevation is corrected by refraction but not ra,dec,ha,az                 */
/*****************************************************************************/
int mc_scheduler_local1(int k,double longmpc, double rhocosphip, double rhosinphip, double latrad, double *luminance_ciel_bleus, mc_OBJECTDESCR *objectdescr,int njd, mc_SUNMOON *sunmoon,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadecint,double *pjd,double *pha,double *pelev,double *paz,double *pdec,double *pmoon_dist,double *psun_dist,double *pbrillance_totale,double *pra) {
	double jd;
	//double *dummy1s=NULL,*dummy2s=NULL,*dummy3s=NULL,*dummy4s=NULL,*dummy5s=NULL,*dummy6s=NULL,*dummy7s=NULL,*dummy8s=NULL,*dummy9s=NULL;
	//double *dummy01s=NULL,*dummy02s=NULL;
	int kk,kh;
	double ra=0,dec=0,ha=0,elev=0,az=0,c,moon_dist_phase,dh;
	//mc_OBJECTLOCAL *objectlocal=NULL;
	double h,moon_az,moon_elev,sun_az,sun_elev,moon_dist,sun_dist,helev;
	double luminance_diffusion_lune;
	double luminance_totale,brillance_totale;
	double frac_moon,cordis,luminance_ciel_soleil,luminance_ciel_lune,luminance_ciel_nocturne;

	//dummy1s[kjd]=sunmoon[k].jd;
	jd=sunmoon[k].jd;
	moon_az=sunmoon[k].moon_az*(DR);
	moon_elev=sunmoon[k].moon_elev*(DR);
	sun_az=sunmoon[k].sun_az*(DR);
	sun_elev=sunmoon[k].sun_elev*(DR);
	if (objectdescr->axe_type==0) {
		// --- type = RADEC
		mc_sheduler_interpcoords(objectdescr,jd,&ra,&dec);
		ha=sunmoon[k].lst-ra;
		if (ha<0) { ha+=360.; }
		if (ha>360) { ha-=360.; }
		//dummy2s[kjd]=ha;
		//dummy9s[kjd]=ra; // laisser apres ha
		mc_hd2ah(ha*(DR),dec*(DR),latrad,&az,&h);
		mc_refraction(h,1,283,101325,&dh);
		h+=dh;
		//dummy3s[kjd]=h/(DR); 
		elev=h;
		//dummy4s[kjd]=az/(DR); // az
		//dummy5s[kjd]=dec;
	} else if (objectdescr->axe_type==1) {
		// --- type = HADEC
		mc_sheduler_interpcoords(objectdescr,jd,&ha,&dec);
		ra=sunmoon[k].lst-ha;
		if (ra<0) { ra+=360.; }
		if (ra>360) { ra-=360.; }
		//dummy9s[kjd]=ra;
		//dummy2s[kjd]=ha; // laisser apres ra
		mc_hd2ah(ha*(DR),dec*(DR),latrad,&az,&h);
		mc_refraction(h,1,283,101325,&dh);
		h+=dh;
		//dummy3s[kjd]=h/(DR); 
		elev=h;
		//dummy4s[kjd]=az/(DR); // az
		//dummy5s[kjd]=dec;
	} else if (objectdescr->axe_type==2) {
		// --- type = ALTAZ
		mc_sheduler_interpcoords(objectdescr,jd,&az,&h);
		mc_ah2hd(az*(DR),h*(DR),latrad,&ha,&dec);
		ra=sunmoon[k].lst-ha;
		if (ra<0) { ra+=360.; }
		if (ra>360) { ra-=360.; }
		//dummy9s[kjd]=ra;
		//dummy2s[kjd]=ha; // laisser apres ra
		mc_refraction(h,1,283,101325,&dh);
		h+=dh;
		//dummy3s[kjd]=h/(DR); 
		elev=h;
		//dummy4s[kjd]=az/(DR); // az
		//dummy5s[kjd]=dec;
	}
	// --- moon_dist
	c=(sin(elev)*sin(moon_elev)+cos(elev)*cos(moon_elev)*cos(az-moon_az));
	if (c<-1.) {c=-1.;}
	if (c>1.) {c=1.;}
	moon_dist=acos(c)/(DR);
	//dummy6s[kjd]=moon_dist;
	// --- sun_dist
	c=(sin(elev)*sin(sun_elev)+cos(elev)*cos(sun_elev)*cos(az-sun_az));
	if (c<-1.) {c=-1.;}
	if (c>1.) {c=1.;}
	sun_dist=acos(c)/(DR);
	//dummy7s[kjd]=sun_dist;
	// --- skylevel
	az/=(DR);
	kh=(int)(az);
	if (kh>360) {kh-=360;}
	if (kh<0) {kh+=360;}
	helev=horizon_altaz[kh].elev;
	elev/=(DR);
	moon_dist_phase=objectdescr->const_fullmoondist*(sqrt(fabs(moon_dist)/180.));
	if (elev<helev) {
		brillance_totale=-50;
	} else if (elev<objectdescr->const_elev) {
		brillance_totale=-50;
	} else if (sun_dist<=objectdescr->const_sundist) {
		brillance_totale=-50;
	} else if (moon_dist<=moon_dist_phase) {
		brillance_totale=-50;
	} else {
		// Conversions d'unites : luminance(cd/m2) = 10^(-(brillance(mag/arcsec2)-13)/2.5)
		luminance_ciel_nocturne=5.2e-4; // cd/m2 (equivalent à 21.21 magV/arcsec2 pour une nuit sans Lune)
		// brillance_ciel_bleus : tableau de mesures du ciel bleu (cd/m2) pour les elevations -90 -89.9 -89.8 ... +89.9 +90.0
		cordis=(0.2 - pow (10 , 0.65-4.0*pow((sin(sun_dist*(DR)/2)),2.) ) ) ; // (deg) decalage empirique pour tenir compte de la diffusion autour du Soleil
		kk=(int)(10*(sunmoon[k].sun_elev+90+cordis)); 
		if (kk<0) { kk=0; }
		if (kk>1800) { kk=1800; }
		luminance_ciel_soleil=luminance_ciel_bleus[kk]; // cd/m2
		// on considere que la brillance du ciel par la pleine lune est 15.0 mag superieure a celle du Soleil (facteur 1e-6)
		kk=(int)(10*(sunmoon[k].moon_elev+90));
		if (kk<0) { kk=0; }
		if (kk>1800) { kk=1800; }
		frac_moon=(1+cos(sunmoon[k].moon_phase*(DR)))/2; // fraction illumniee de la Lune (0 a 1)
		luminance_ciel_lune=1e-6*frac_moon*luminance_ciel_bleus[kk]; // cd/m2
		// diffusion par la Lune
		// pour elev_moon=34 deg : luminance_diffusion_lune=1.42857e-3*frac_moon*pow( sin(moon_dist*(DR)/2),-2.1 ); // cd/m2
		luminance_diffusion_lune=4.23546e-3*luminance_ciel_bleus[kk]/luminance_ciel_bleus[1800]*frac_moon*pow( sin(moon_dist*(DR)/2),-2.1 ); // cd/m2
		// luminance totale dans cette direction de visee (cd/m2)
		luminance_totale=luminance_ciel_nocturne+luminance_ciel_soleil+luminance_ciel_lune+luminance_diffusion_lune;
		// brillance totale dans cette direction de visee (cd/m2)
		brillance_totale=13-2.5*log10(luminance_totale);
	}
	//dummy8s[kjd]=brillance_totale;
	*pjd=jd;
	*pha=ha;
	*pelev=elev;
	*paz=az;
	*pdec=dec;
	*pmoon_dist=moon_dist;
	*psun_dist=sun_dist;
	*pbrillance_totale=brillance_totale;
	*pra=ra;
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Interpolation of coordinates                                              */
/* Outputs : objectlocal                                                     */
/*****************************************************************************/
int mc_sheduler_interpcoords(mc_OBJECTDESCR *objectdescr,double jd,double *pos1,double *pos2) {
	int n,k;
	double p1,p2,da,djd,jdfrac;
	n=objectdescr->axe_njd;
	for (k=1;k<n;k++) {
		da=objectdescr->axe_pos1[k]-objectdescr->axe_pos1[k-1];
		if (da<-180) { objectdescr->axe_pos1[k]+=360.; }
		if (da>180) { objectdescr->axe_pos1[k]-=360.; }
	}
	p1=objectdescr->axe_pos1[0];
	p2=objectdescr->axe_pos2[0];
	if ((jd>objectdescr->axe_jd[0])||(objectdescr->axe_jd[0]==0)||(n==1)) {
		p1=objectdescr->axe_pos1[0];
		p2=objectdescr->axe_pos2[0];
	} else {
		for (k=1;k<n;k++) {
			if (jd<=objectdescr->axe_jd[k]) {
				djd=objectdescr->axe_jd[k]-objectdescr->axe_jd[k-1];
				if (djd!=0) {
					jdfrac=(jd-objectdescr->axe_jd[k-1])/djd;
					p1=objectdescr->axe_pos1[k-1]+jdfrac*(objectdescr->axe_pos1[k]-objectdescr->axe_pos1[k-1]);
					p2=objectdescr->axe_pos2[k-1]+jdfrac*(objectdescr->axe_pos2[k]-objectdescr->axe_pos2[k-1]);
				} else {
					p1=(objectdescr->axe_pos1[k]+objectdescr->axe_pos1[k-1])/2;
					p2=(objectdescr->axe_pos2[k]+objectdescr->axe_pos2[k-1])/2;
				}
			}
		}
	}
	*pos1=p1;
	*pos2=p2;
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Fill the skylevel vector                                                  */
/* Units : cd/m2                                                             */
/* Sampling elevation -90 to +90 step 0.1 deg                                */
/*	double *luminance_ciel_bleus=NULL; // -90 -89.9 -89.8 ... +89.9 +90.0     */
/*****************************************************************************/
int mc_fill_luminance_ciel_bleus(double *luminance_ciel_bleus) {
	luminance_ciel_bleus[0]=1.585e-007;
	luminance_ciel_bleus[1]=1.585e-007;
	luminance_ciel_bleus[2]=1.585e-007;
	luminance_ciel_bleus[3]=1.585e-007;
	luminance_ciel_bleus[4]=1.585e-007;
	luminance_ciel_bleus[5]=1.585e-007;
	luminance_ciel_bleus[6]=1.585e-007;
	luminance_ciel_bleus[7]=1.585e-007;
	luminance_ciel_bleus[8]=1.585e-007;
	luminance_ciel_bleus[9]=1.585e-007;
	luminance_ciel_bleus[10]=1.586e-007;
	luminance_ciel_bleus[11]=1.586e-007;
	luminance_ciel_bleus[12]=1.586e-007;
	luminance_ciel_bleus[13]=1.586e-007;
	luminance_ciel_bleus[14]=1.586e-007;
	luminance_ciel_bleus[15]=1.586e-007;
	luminance_ciel_bleus[16]=1.586e-007;
	luminance_ciel_bleus[17]=1.586e-007;
	luminance_ciel_bleus[18]=1.586e-007;
	luminance_ciel_bleus[19]=1.586e-007;
	luminance_ciel_bleus[20]=1.586e-007;
	luminance_ciel_bleus[21]=1.587e-007;
	luminance_ciel_bleus[22]=1.587e-007;
	luminance_ciel_bleus[23]=1.587e-007;
	luminance_ciel_bleus[24]=1.587e-007;
	luminance_ciel_bleus[25]=1.587e-007;
	luminance_ciel_bleus[26]=1.587e-007;
	luminance_ciel_bleus[27]=1.587e-007;
	luminance_ciel_bleus[28]=1.587e-007;
	luminance_ciel_bleus[29]=1.588e-007;
	luminance_ciel_bleus[30]=1.588e-007;
	luminance_ciel_bleus[31]=1.588e-007;
	luminance_ciel_bleus[32]=1.588e-007;
	luminance_ciel_bleus[33]=1.588e-007;
	luminance_ciel_bleus[34]=1.588e-007;
	luminance_ciel_bleus[35]=1.588e-007;
	luminance_ciel_bleus[36]=1.589e-007;
	luminance_ciel_bleus[37]=1.589e-007;
	luminance_ciel_bleus[38]=1.589e-007;
	luminance_ciel_bleus[39]=1.589e-007;
	luminance_ciel_bleus[40]=1.589e-007;
	luminance_ciel_bleus[41]=1.589e-007;
	luminance_ciel_bleus[42]=1.590e-007;
	luminance_ciel_bleus[43]=1.590e-007;
	luminance_ciel_bleus[44]=1.590e-007;
	luminance_ciel_bleus[45]=1.590e-007;
	luminance_ciel_bleus[46]=1.590e-007;
	luminance_ciel_bleus[47]=1.590e-007;
	luminance_ciel_bleus[48]=1.591e-007;
	luminance_ciel_bleus[49]=1.591e-007;
	luminance_ciel_bleus[50]=1.591e-007;
	luminance_ciel_bleus[51]=1.591e-007;
	luminance_ciel_bleus[52]=1.591e-007;
	luminance_ciel_bleus[53]=1.592e-007;
	luminance_ciel_bleus[54]=1.592e-007;
	luminance_ciel_bleus[55]=1.592e-007;
	luminance_ciel_bleus[56]=1.592e-007;
	luminance_ciel_bleus[57]=1.593e-007;
	luminance_ciel_bleus[58]=1.593e-007;
	luminance_ciel_bleus[59]=1.593e-007;
	luminance_ciel_bleus[60]=1.593e-007;
	luminance_ciel_bleus[61]=1.593e-007;
	luminance_ciel_bleus[62]=1.594e-007;
	luminance_ciel_bleus[63]=1.594e-007;
	luminance_ciel_bleus[64]=1.594e-007;
	luminance_ciel_bleus[65]=1.594e-007;
	luminance_ciel_bleus[66]=1.595e-007;
	luminance_ciel_bleus[67]=1.595e-007;
	luminance_ciel_bleus[68]=1.595e-007;
	luminance_ciel_bleus[69]=1.595e-007;
	luminance_ciel_bleus[70]=1.596e-007;
	luminance_ciel_bleus[71]=1.596e-007;
	luminance_ciel_bleus[72]=1.596e-007;
	luminance_ciel_bleus[73]=1.596e-007;
	luminance_ciel_bleus[74]=1.597e-007;
	luminance_ciel_bleus[75]=1.597e-007;
	luminance_ciel_bleus[76]=1.597e-007;
	luminance_ciel_bleus[77]=1.598e-007;
	luminance_ciel_bleus[78]=1.598e-007;
	luminance_ciel_bleus[79]=1.598e-007;
	luminance_ciel_bleus[80]=1.598e-007;
	luminance_ciel_bleus[81]=1.599e-007;
	luminance_ciel_bleus[82]=1.599e-007;
	luminance_ciel_bleus[83]=1.599e-007;
	luminance_ciel_bleus[84]=1.600e-007;
	luminance_ciel_bleus[85]=1.600e-007;
	luminance_ciel_bleus[86]=1.600e-007;
	luminance_ciel_bleus[87]=1.601e-007;
	luminance_ciel_bleus[88]=1.601e-007;
	luminance_ciel_bleus[89]=1.601e-007;
	luminance_ciel_bleus[90]=1.602e-007;
	luminance_ciel_bleus[91]=1.602e-007;
	luminance_ciel_bleus[92]=1.602e-007;
	luminance_ciel_bleus[93]=1.603e-007;
	luminance_ciel_bleus[94]=1.603e-007;
	luminance_ciel_bleus[95]=1.603e-007;
	luminance_ciel_bleus[96]=1.604e-007;
	luminance_ciel_bleus[97]=1.604e-007;
	luminance_ciel_bleus[98]=1.604e-007;
	luminance_ciel_bleus[99]=1.605e-007;
	luminance_ciel_bleus[100]=1.605e-007;
	luminance_ciel_bleus[101]=1.605e-007;
	luminance_ciel_bleus[102]=1.606e-007;
	luminance_ciel_bleus[103]=1.606e-007;
	luminance_ciel_bleus[104]=1.606e-007;
	luminance_ciel_bleus[105]=1.607e-007;
	luminance_ciel_bleus[106]=1.607e-007;
	luminance_ciel_bleus[107]=1.608e-007;
	luminance_ciel_bleus[108]=1.608e-007;
	luminance_ciel_bleus[109]=1.608e-007;
	luminance_ciel_bleus[110]=1.609e-007;
	luminance_ciel_bleus[111]=1.609e-007;
	luminance_ciel_bleus[112]=1.610e-007;
	luminance_ciel_bleus[113]=1.610e-007;
	luminance_ciel_bleus[114]=1.610e-007;
	luminance_ciel_bleus[115]=1.611e-007;
	luminance_ciel_bleus[116]=1.611e-007;
	luminance_ciel_bleus[117]=1.612e-007;
	luminance_ciel_bleus[118]=1.612e-007;
	luminance_ciel_bleus[119]=1.612e-007;
	luminance_ciel_bleus[120]=1.613e-007;
	luminance_ciel_bleus[121]=1.613e-007;
	luminance_ciel_bleus[122]=1.614e-007;
	luminance_ciel_bleus[123]=1.614e-007;
	luminance_ciel_bleus[124]=1.615e-007;
	luminance_ciel_bleus[125]=1.615e-007;
	luminance_ciel_bleus[126]=1.616e-007;
	luminance_ciel_bleus[127]=1.616e-007;
	luminance_ciel_bleus[128]=1.616e-007;
	luminance_ciel_bleus[129]=1.617e-007;
	luminance_ciel_bleus[130]=1.617e-007;
	luminance_ciel_bleus[131]=1.618e-007;
	luminance_ciel_bleus[132]=1.618e-007;
	luminance_ciel_bleus[133]=1.619e-007;
	luminance_ciel_bleus[134]=1.619e-007;
	luminance_ciel_bleus[135]=1.620e-007;
	luminance_ciel_bleus[136]=1.620e-007;
	luminance_ciel_bleus[137]=1.621e-007;
	luminance_ciel_bleus[138]=1.621e-007;
	luminance_ciel_bleus[139]=1.622e-007;
	luminance_ciel_bleus[140]=1.622e-007;
	luminance_ciel_bleus[141]=1.623e-007;
	luminance_ciel_bleus[142]=1.623e-007;
	luminance_ciel_bleus[143]=1.624e-007;
	luminance_ciel_bleus[144]=1.624e-007;
	luminance_ciel_bleus[145]=1.625e-007;
	luminance_ciel_bleus[146]=1.625e-007;
	luminance_ciel_bleus[147]=1.626e-007;
	luminance_ciel_bleus[148]=1.626e-007;
	luminance_ciel_bleus[149]=1.627e-007;
	luminance_ciel_bleus[150]=1.628e-007;
	luminance_ciel_bleus[151]=1.628e-007;
	luminance_ciel_bleus[152]=1.629e-007;
	luminance_ciel_bleus[153]=1.629e-007;
	luminance_ciel_bleus[154]=1.630e-007;
	luminance_ciel_bleus[155]=1.630e-007;
	luminance_ciel_bleus[156]=1.631e-007;
	luminance_ciel_bleus[157]=1.631e-007;
	luminance_ciel_bleus[158]=1.632e-007;
	luminance_ciel_bleus[159]=1.633e-007;
	luminance_ciel_bleus[160]=1.633e-007;
	luminance_ciel_bleus[161]=1.634e-007;
	luminance_ciel_bleus[162]=1.634e-007;
	luminance_ciel_bleus[163]=1.635e-007;
	luminance_ciel_bleus[164]=1.636e-007;
	luminance_ciel_bleus[165]=1.636e-007;
	luminance_ciel_bleus[166]=1.637e-007;
	luminance_ciel_bleus[167]=1.637e-007;
	luminance_ciel_bleus[168]=1.638e-007;
	luminance_ciel_bleus[169]=1.639e-007;
	luminance_ciel_bleus[170]=1.639e-007;
	luminance_ciel_bleus[171]=1.640e-007;
	luminance_ciel_bleus[172]=1.640e-007;
	luminance_ciel_bleus[173]=1.641e-007;
	luminance_ciel_bleus[174]=1.642e-007;
	luminance_ciel_bleus[175]=1.642e-007;
	luminance_ciel_bleus[176]=1.643e-007;
	luminance_ciel_bleus[177]=1.644e-007;
	luminance_ciel_bleus[178]=1.644e-007;
	luminance_ciel_bleus[179]=1.645e-007;
	luminance_ciel_bleus[180]=1.646e-007;
	luminance_ciel_bleus[181]=1.646e-007;
	luminance_ciel_bleus[182]=1.647e-007;
	luminance_ciel_bleus[183]=1.648e-007;
	luminance_ciel_bleus[184]=1.648e-007;
	luminance_ciel_bleus[185]=1.649e-007;
	luminance_ciel_bleus[186]=1.650e-007;
	luminance_ciel_bleus[187]=1.650e-007;
	luminance_ciel_bleus[188]=1.651e-007;
	luminance_ciel_bleus[189]=1.652e-007;
	luminance_ciel_bleus[190]=1.652e-007;
	luminance_ciel_bleus[191]=1.653e-007;
	luminance_ciel_bleus[192]=1.654e-007;
	luminance_ciel_bleus[193]=1.655e-007;
	luminance_ciel_bleus[194]=1.655e-007;
	luminance_ciel_bleus[195]=1.656e-007;
	luminance_ciel_bleus[196]=1.657e-007;
	luminance_ciel_bleus[197]=1.657e-007;
	luminance_ciel_bleus[198]=1.658e-007;
	luminance_ciel_bleus[199]=1.659e-007;
	luminance_ciel_bleus[200]=1.660e-007;
	luminance_ciel_bleus[201]=1.660e-007;
	luminance_ciel_bleus[202]=1.661e-007;
	luminance_ciel_bleus[203]=1.662e-007;
	luminance_ciel_bleus[204]=1.663e-007;
	luminance_ciel_bleus[205]=1.663e-007;
	luminance_ciel_bleus[206]=1.664e-007;
	luminance_ciel_bleus[207]=1.665e-007;
	luminance_ciel_bleus[208]=1.666e-007;
	luminance_ciel_bleus[209]=1.667e-007;
	luminance_ciel_bleus[210]=1.667e-007;
	luminance_ciel_bleus[211]=1.668e-007;
	luminance_ciel_bleus[212]=1.669e-007;
	luminance_ciel_bleus[213]=1.670e-007;
	luminance_ciel_bleus[214]=1.670e-007;
	luminance_ciel_bleus[215]=1.671e-007;
	luminance_ciel_bleus[216]=1.672e-007;
	luminance_ciel_bleus[217]=1.673e-007;
	luminance_ciel_bleus[218]=1.674e-007;
	luminance_ciel_bleus[219]=1.674e-007;
	luminance_ciel_bleus[220]=1.675e-007;
	luminance_ciel_bleus[221]=1.676e-007;
	luminance_ciel_bleus[222]=1.677e-007;
	luminance_ciel_bleus[223]=1.678e-007;
	luminance_ciel_bleus[224]=1.679e-007;
	luminance_ciel_bleus[225]=1.679e-007;
	luminance_ciel_bleus[226]=1.680e-007;
	luminance_ciel_bleus[227]=1.681e-007;
	luminance_ciel_bleus[228]=1.682e-007;
	luminance_ciel_bleus[229]=1.683e-007;
	luminance_ciel_bleus[230]=1.683e-007;
	luminance_ciel_bleus[231]=1.684e-007;
	luminance_ciel_bleus[232]=1.685e-007;
	luminance_ciel_bleus[233]=1.686e-007;
	luminance_ciel_bleus[234]=1.687e-007;
	luminance_ciel_bleus[235]=1.688e-007;
	luminance_ciel_bleus[236]=1.688e-007;
	luminance_ciel_bleus[237]=1.689e-007;
	luminance_ciel_bleus[238]=1.690e-007;
	luminance_ciel_bleus[239]=1.691e-007;
	luminance_ciel_bleus[240]=1.692e-007;
	luminance_ciel_bleus[241]=1.693e-007;
	luminance_ciel_bleus[242]=1.693e-007;
	luminance_ciel_bleus[243]=1.694e-007;
	luminance_ciel_bleus[244]=1.695e-007;
	luminance_ciel_bleus[245]=1.696e-007;
	luminance_ciel_bleus[246]=1.697e-007;
	luminance_ciel_bleus[247]=1.698e-007;
	luminance_ciel_bleus[248]=1.698e-007;
	luminance_ciel_bleus[249]=1.699e-007;
	luminance_ciel_bleus[250]=1.700e-007;
	luminance_ciel_bleus[251]=1.701e-007;
	luminance_ciel_bleus[252]=1.702e-007;
	luminance_ciel_bleus[253]=1.703e-007;
	luminance_ciel_bleus[254]=1.703e-007;
	luminance_ciel_bleus[255]=1.704e-007;
	luminance_ciel_bleus[256]=1.705e-007;
	luminance_ciel_bleus[257]=1.706e-007;
	luminance_ciel_bleus[258]=1.707e-007;
	luminance_ciel_bleus[259]=1.707e-007;
	luminance_ciel_bleus[260]=1.708e-007;
	luminance_ciel_bleus[261]=1.709e-007;
	luminance_ciel_bleus[262]=1.710e-007;
	luminance_ciel_bleus[263]=1.711e-007;
	luminance_ciel_bleus[264]=1.711e-007;
	luminance_ciel_bleus[265]=1.712e-007;
	luminance_ciel_bleus[266]=1.713e-007;
	luminance_ciel_bleus[267]=1.714e-007;
	luminance_ciel_bleus[268]=1.715e-007;
	luminance_ciel_bleus[269]=1.715e-007;
	luminance_ciel_bleus[270]=1.716e-007;
	luminance_ciel_bleus[271]=1.717e-007;
	luminance_ciel_bleus[272]=1.718e-007;
	luminance_ciel_bleus[273]=1.718e-007;
	luminance_ciel_bleus[274]=1.719e-007;
	luminance_ciel_bleus[275]=1.720e-007;
	luminance_ciel_bleus[276]=1.721e-007;
	luminance_ciel_bleus[277]=1.721e-007;
	luminance_ciel_bleus[278]=1.722e-007;
	luminance_ciel_bleus[279]=1.723e-007;
	luminance_ciel_bleus[280]=1.724e-007;
	luminance_ciel_bleus[281]=1.724e-007;
	luminance_ciel_bleus[282]=1.725e-007;
	luminance_ciel_bleus[283]=1.726e-007;
	luminance_ciel_bleus[284]=1.727e-007;
	luminance_ciel_bleus[285]=1.727e-007;
	luminance_ciel_bleus[286]=1.728e-007;
	luminance_ciel_bleus[287]=1.729e-007;
	luminance_ciel_bleus[288]=1.729e-007;
	luminance_ciel_bleus[289]=1.730e-007;
	luminance_ciel_bleus[290]=1.731e-007;
	luminance_ciel_bleus[291]=1.731e-007;
	luminance_ciel_bleus[292]=1.732e-007;
	luminance_ciel_bleus[293]=1.733e-007;
	luminance_ciel_bleus[294]=1.733e-007;
	luminance_ciel_bleus[295]=1.734e-007;
	luminance_ciel_bleus[296]=1.735e-007;
	luminance_ciel_bleus[297]=1.735e-007;
	luminance_ciel_bleus[298]=1.736e-007;
	luminance_ciel_bleus[299]=1.737e-007;
	luminance_ciel_bleus[300]=1.737e-007;
	luminance_ciel_bleus[301]=1.738e-007;
	luminance_ciel_bleus[302]=1.738e-007;
	luminance_ciel_bleus[303]=1.739e-007;
	luminance_ciel_bleus[304]=1.740e-007;
	luminance_ciel_bleus[305]=1.740e-007;
	luminance_ciel_bleus[306]=1.741e-007;
	luminance_ciel_bleus[307]=1.741e-007;
	luminance_ciel_bleus[308]=1.742e-007;
	luminance_ciel_bleus[309]=1.743e-007;
	luminance_ciel_bleus[310]=1.743e-007;
	luminance_ciel_bleus[311]=1.744e-007;
	luminance_ciel_bleus[312]=1.744e-007;
	luminance_ciel_bleus[313]=1.745e-007;
	luminance_ciel_bleus[314]=1.746e-007;
	luminance_ciel_bleus[315]=1.746e-007;
	luminance_ciel_bleus[316]=1.747e-007;
	luminance_ciel_bleus[317]=1.747e-007;
	luminance_ciel_bleus[318]=1.748e-007;
	luminance_ciel_bleus[319]=1.749e-007;
	luminance_ciel_bleus[320]=1.749e-007;
	luminance_ciel_bleus[321]=1.750e-007;
	luminance_ciel_bleus[322]=1.750e-007;
	luminance_ciel_bleus[323]=1.751e-007;
	luminance_ciel_bleus[324]=1.752e-007;
	luminance_ciel_bleus[325]=1.752e-007;
	luminance_ciel_bleus[326]=1.753e-007;
	luminance_ciel_bleus[327]=1.754e-007;
	luminance_ciel_bleus[328]=1.755e-007;
	luminance_ciel_bleus[329]=1.755e-007;
	luminance_ciel_bleus[330]=1.756e-007;
	luminance_ciel_bleus[331]=1.757e-007;
	luminance_ciel_bleus[332]=1.758e-007;
	luminance_ciel_bleus[333]=1.759e-007;
	luminance_ciel_bleus[334]=1.759e-007;
	luminance_ciel_bleus[335]=1.760e-007;
	luminance_ciel_bleus[336]=1.761e-007;
	luminance_ciel_bleus[337]=1.762e-007;
	luminance_ciel_bleus[338]=1.763e-007;
	luminance_ciel_bleus[339]=1.764e-007;
	luminance_ciel_bleus[340]=1.765e-007;
	luminance_ciel_bleus[341]=1.766e-007;
	luminance_ciel_bleus[342]=1.767e-007;
	luminance_ciel_bleus[343]=1.768e-007;
	luminance_ciel_bleus[344]=1.769e-007;
	luminance_ciel_bleus[345]=1.770e-007;
	luminance_ciel_bleus[346]=1.771e-007;
	luminance_ciel_bleus[347]=1.772e-007;
	luminance_ciel_bleus[348]=1.774e-007;
	luminance_ciel_bleus[349]=1.775e-007;
	luminance_ciel_bleus[350]=1.776e-007;
	luminance_ciel_bleus[351]=1.778e-007;
	luminance_ciel_bleus[352]=1.779e-007;
	luminance_ciel_bleus[353]=1.780e-007;
	luminance_ciel_bleus[354]=1.782e-007;
	luminance_ciel_bleus[355]=1.783e-007;
	luminance_ciel_bleus[356]=1.785e-007;
	luminance_ciel_bleus[357]=1.786e-007;
	luminance_ciel_bleus[358]=1.788e-007;
	luminance_ciel_bleus[359]=1.789e-007;
	luminance_ciel_bleus[360]=1.791e-007;
	luminance_ciel_bleus[361]=1.793e-007;
	luminance_ciel_bleus[362]=1.795e-007;
	luminance_ciel_bleus[363]=1.796e-007;
	luminance_ciel_bleus[364]=1.798e-007;
	luminance_ciel_bleus[365]=1.800e-007;
	luminance_ciel_bleus[366]=1.802e-007;
	luminance_ciel_bleus[367]=1.804e-007;
	luminance_ciel_bleus[368]=1.806e-007;
	luminance_ciel_bleus[369]=1.808e-007;
	luminance_ciel_bleus[370]=1.811e-007;
	luminance_ciel_bleus[371]=1.813e-007;
	luminance_ciel_bleus[372]=1.815e-007;
	luminance_ciel_bleus[373]=1.817e-007;
	luminance_ciel_bleus[374]=1.820e-007;
	luminance_ciel_bleus[375]=1.822e-007;
	luminance_ciel_bleus[376]=1.825e-007;
	luminance_ciel_bleus[377]=1.827e-007;
	luminance_ciel_bleus[378]=1.830e-007;
	luminance_ciel_bleus[379]=1.833e-007;
	luminance_ciel_bleus[380]=1.835e-007;
	luminance_ciel_bleus[381]=1.838e-007;
	luminance_ciel_bleus[382]=1.841e-007;
	luminance_ciel_bleus[383]=1.844e-007;
	luminance_ciel_bleus[384]=1.847e-007;
	luminance_ciel_bleus[385]=1.850e-007;
	luminance_ciel_bleus[386]=1.854e-007;
	luminance_ciel_bleus[387]=1.857e-007;
	luminance_ciel_bleus[388]=1.860e-007;
	luminance_ciel_bleus[389]=1.864e-007;
	luminance_ciel_bleus[390]=1.867e-007;
	luminance_ciel_bleus[391]=1.871e-007;
	luminance_ciel_bleus[392]=1.874e-007;
	luminance_ciel_bleus[393]=1.878e-007;
	luminance_ciel_bleus[394]=1.882e-007;
	luminance_ciel_bleus[395]=1.886e-007;
	luminance_ciel_bleus[396]=1.890e-007;
	luminance_ciel_bleus[397]=1.894e-007;
	luminance_ciel_bleus[398]=1.898e-007;
	luminance_ciel_bleus[399]=1.902e-007;
	luminance_ciel_bleus[400]=1.906e-007;
	luminance_ciel_bleus[401]=1.911e-007;
	luminance_ciel_bleus[402]=1.915e-007;
	luminance_ciel_bleus[403]=1.920e-007;
	luminance_ciel_bleus[404]=1.925e-007;
	luminance_ciel_bleus[405]=1.930e-007;
	luminance_ciel_bleus[406]=1.934e-007;
	luminance_ciel_bleus[407]=1.939e-007;
	luminance_ciel_bleus[408]=1.944e-007;
	luminance_ciel_bleus[409]=1.950e-007;
	luminance_ciel_bleus[410]=1.955e-007;
	luminance_ciel_bleus[411]=1.960e-007;
	luminance_ciel_bleus[412]=1.966e-007;
	luminance_ciel_bleus[413]=1.971e-007;
	luminance_ciel_bleus[414]=1.977e-007;
	luminance_ciel_bleus[415]=1.982e-007;
	luminance_ciel_bleus[416]=1.988e-007;
	luminance_ciel_bleus[417]=1.994e-007;
	luminance_ciel_bleus[418]=2.000e-007;
	luminance_ciel_bleus[419]=2.006e-007;
	luminance_ciel_bleus[420]=2.012e-007;
	luminance_ciel_bleus[421]=2.018e-007;
	luminance_ciel_bleus[422]=2.025e-007;
	luminance_ciel_bleus[423]=2.031e-007;
	luminance_ciel_bleus[424]=2.038e-007;
	luminance_ciel_bleus[425]=2.044e-007;
	luminance_ciel_bleus[426]=2.051e-007;
	luminance_ciel_bleus[427]=2.057e-007;
	luminance_ciel_bleus[428]=2.064e-007;
	luminance_ciel_bleus[429]=2.071e-007;
	luminance_ciel_bleus[430]=2.078e-007;
	luminance_ciel_bleus[431]=2.085e-007;
	luminance_ciel_bleus[432]=2.092e-007;
	luminance_ciel_bleus[433]=2.100e-007;
	luminance_ciel_bleus[434]=2.107e-007;
	luminance_ciel_bleus[435]=2.114e-007;
	luminance_ciel_bleus[436]=2.122e-007;
	luminance_ciel_bleus[437]=2.129e-007;
	luminance_ciel_bleus[438]=2.137e-007;
	luminance_ciel_bleus[439]=2.145e-007;
	luminance_ciel_bleus[440]=2.152e-007;
	luminance_ciel_bleus[441]=2.160e-007;
	luminance_ciel_bleus[442]=2.168e-007;
	luminance_ciel_bleus[443]=2.176e-007;
	luminance_ciel_bleus[444]=2.185e-007;
	luminance_ciel_bleus[445]=2.193e-007;
	luminance_ciel_bleus[446]=2.201e-007;
	luminance_ciel_bleus[447]=2.209e-007;
	luminance_ciel_bleus[448]=2.218e-007;
	luminance_ciel_bleus[449]=2.226e-007;
	luminance_ciel_bleus[450]=2.235e-007;
	luminance_ciel_bleus[451]=2.244e-007;
	luminance_ciel_bleus[452]=2.252e-007;
	luminance_ciel_bleus[453]=2.261e-007;
	luminance_ciel_bleus[454]=2.270e-007;
	luminance_ciel_bleus[455]=2.279e-007;
	luminance_ciel_bleus[456]=2.288e-007;
	luminance_ciel_bleus[457]=2.297e-007;
	luminance_ciel_bleus[458]=2.306e-007;
	luminance_ciel_bleus[459]=2.316e-007;
	luminance_ciel_bleus[460]=2.325e-007;
	luminance_ciel_bleus[461]=2.334e-007;
	luminance_ciel_bleus[462]=2.344e-007;
	luminance_ciel_bleus[463]=2.353e-007;
	luminance_ciel_bleus[464]=2.363e-007;
	luminance_ciel_bleus[465]=2.373e-007;
	luminance_ciel_bleus[466]=2.382e-007;
	luminance_ciel_bleus[467]=2.392e-007;
	luminance_ciel_bleus[468]=2.402e-007;
	luminance_ciel_bleus[469]=2.412e-007;
	luminance_ciel_bleus[470]=2.422e-007;
	luminance_ciel_bleus[471]=2.432e-007;
	luminance_ciel_bleus[472]=2.442e-007;
	luminance_ciel_bleus[473]=2.453e-007;
	luminance_ciel_bleus[474]=2.463e-007;
	luminance_ciel_bleus[475]=2.473e-007;
	luminance_ciel_bleus[476]=2.484e-007;
	luminance_ciel_bleus[477]=2.494e-007;
	luminance_ciel_bleus[478]=2.505e-007;
	luminance_ciel_bleus[479]=2.515e-007;
	luminance_ciel_bleus[480]=2.526e-007;
	luminance_ciel_bleus[481]=2.536e-007;
	luminance_ciel_bleus[482]=2.547e-007;
	luminance_ciel_bleus[483]=2.558e-007;
	luminance_ciel_bleus[484]=2.569e-007;
	luminance_ciel_bleus[485]=2.580e-007;
	luminance_ciel_bleus[486]=2.591e-007;
	luminance_ciel_bleus[487]=2.602e-007;
	luminance_ciel_bleus[488]=2.613e-007;
	luminance_ciel_bleus[489]=2.624e-007;
	luminance_ciel_bleus[490]=2.635e-007;
	luminance_ciel_bleus[491]=2.646e-007;
	luminance_ciel_bleus[492]=2.658e-007;
	luminance_ciel_bleus[493]=2.669e-007;
	luminance_ciel_bleus[494]=2.680e-007;
	luminance_ciel_bleus[495]=2.692e-007;
	luminance_ciel_bleus[496]=2.703e-007;
	luminance_ciel_bleus[497]=2.715e-007;
	luminance_ciel_bleus[498]=2.726e-007;
	luminance_ciel_bleus[499]=2.738e-007;
	luminance_ciel_bleus[500]=2.749e-007;
	luminance_ciel_bleus[501]=2.761e-007;
	luminance_ciel_bleus[502]=2.773e-007;
	luminance_ciel_bleus[503]=2.785e-007;
	luminance_ciel_bleus[504]=2.796e-007;
	luminance_ciel_bleus[505]=2.808e-007;
	luminance_ciel_bleus[506]=2.820e-007;
	luminance_ciel_bleus[507]=2.832e-007;
	luminance_ciel_bleus[508]=2.844e-007;
	luminance_ciel_bleus[509]=2.856e-007;
	luminance_ciel_bleus[510]=2.869e-007;
	luminance_ciel_bleus[511]=2.881e-007;
	luminance_ciel_bleus[512]=2.894e-007;
	luminance_ciel_bleus[513]=2.906e-007;
	luminance_ciel_bleus[514]=2.919e-007;
	luminance_ciel_bleus[515]=2.932e-007;
	luminance_ciel_bleus[516]=2.945e-007;
	luminance_ciel_bleus[517]=2.959e-007;
	luminance_ciel_bleus[518]=2.972e-007;
	luminance_ciel_bleus[519]=2.986e-007;
	luminance_ciel_bleus[520]=3.000e-007;
	luminance_ciel_bleus[521]=3.014e-007;
	luminance_ciel_bleus[522]=3.028e-007;
	luminance_ciel_bleus[523]=3.043e-007;
	luminance_ciel_bleus[524]=3.057e-007;
	luminance_ciel_bleus[525]=3.072e-007;
	luminance_ciel_bleus[526]=3.088e-007;
	luminance_ciel_bleus[527]=3.103e-007;
	luminance_ciel_bleus[528]=3.119e-007;
	luminance_ciel_bleus[529]=3.135e-007;
	luminance_ciel_bleus[530]=3.152e-007;
	luminance_ciel_bleus[531]=3.168e-007;
	luminance_ciel_bleus[532]=3.186e-007;
	luminance_ciel_bleus[533]=3.203e-007;
	luminance_ciel_bleus[534]=3.221e-007;
	luminance_ciel_bleus[535]=3.239e-007;
	luminance_ciel_bleus[536]=3.257e-007;
	luminance_ciel_bleus[537]=3.276e-007;
	luminance_ciel_bleus[538]=3.296e-007;
	luminance_ciel_bleus[539]=3.315e-007;
	luminance_ciel_bleus[540]=3.336e-007;
	luminance_ciel_bleus[541]=3.356e-007;
	luminance_ciel_bleus[542]=3.378e-007;
	luminance_ciel_bleus[543]=3.399e-007;
	luminance_ciel_bleus[544]=3.421e-007;
	luminance_ciel_bleus[545]=3.444e-007;
	luminance_ciel_bleus[546]=3.467e-007;
	luminance_ciel_bleus[547]=3.491e-007;
	luminance_ciel_bleus[548]=3.515e-007;
	luminance_ciel_bleus[549]=3.540e-007;
	luminance_ciel_bleus[550]=3.566e-007;
	luminance_ciel_bleus[551]=3.592e-007;
	luminance_ciel_bleus[552]=3.619e-007;
	luminance_ciel_bleus[553]=3.646e-007;
	luminance_ciel_bleus[554]=3.675e-007;
	luminance_ciel_bleus[555]=3.704e-007;
	luminance_ciel_bleus[556]=3.733e-007;
	luminance_ciel_bleus[557]=3.764e-007;
	luminance_ciel_bleus[558]=3.795e-007;
	luminance_ciel_bleus[559]=3.827e-007;
	luminance_ciel_bleus[560]=3.860e-007;
	luminance_ciel_bleus[561]=3.894e-007;
	luminance_ciel_bleus[562]=3.928e-007;
	luminance_ciel_bleus[563]=3.964e-007;
	luminance_ciel_bleus[564]=4.001e-007;
	luminance_ciel_bleus[565]=4.038e-007;
	luminance_ciel_bleus[566]=4.077e-007;
	luminance_ciel_bleus[567]=4.117e-007;
	luminance_ciel_bleus[568]=4.157e-007;
	luminance_ciel_bleus[569]=4.199e-007;
	luminance_ciel_bleus[570]=4.242e-007;
	luminance_ciel_bleus[571]=4.287e-007;
	luminance_ciel_bleus[572]=4.332e-007;
	luminance_ciel_bleus[573]=4.379e-007;
	luminance_ciel_bleus[574]=4.427e-007;
	luminance_ciel_bleus[575]=4.476e-007;
	luminance_ciel_bleus[576]=4.527e-007;
	luminance_ciel_bleus[577]=4.580e-007;
	luminance_ciel_bleus[578]=4.634e-007;
	luminance_ciel_bleus[579]=4.689e-007;
	luminance_ciel_bleus[580]=4.746e-007;
	luminance_ciel_bleus[581]=4.805e-007;
	luminance_ciel_bleus[582]=4.865e-007;
	luminance_ciel_bleus[583]=4.927e-007;
	luminance_ciel_bleus[584]=4.992e-007;
	luminance_ciel_bleus[585]=5.058e-007;
	luminance_ciel_bleus[586]=5.126e-007;
	luminance_ciel_bleus[587]=5.196e-007;
	luminance_ciel_bleus[588]=5.268e-007;
	luminance_ciel_bleus[589]=5.342e-007;
	luminance_ciel_bleus[590]=5.419e-007;
	luminance_ciel_bleus[591]=5.498e-007;
	luminance_ciel_bleus[592]=5.579e-007;
	luminance_ciel_bleus[593]=5.663e-007;
	luminance_ciel_bleus[594]=5.750e-007;
	luminance_ciel_bleus[595]=5.839e-007;
	luminance_ciel_bleus[596]=5.932e-007;
	luminance_ciel_bleus[597]=6.027e-007;
	luminance_ciel_bleus[598]=6.125e-007;
	luminance_ciel_bleus[599]=6.226e-007;
	luminance_ciel_bleus[600]=6.331e-007;
	luminance_ciel_bleus[601]=6.439e-007;
	luminance_ciel_bleus[602]=6.551e-007;
	luminance_ciel_bleus[603]=6.666e-007;
	luminance_ciel_bleus[604]=6.784e-007;
	luminance_ciel_bleus[605]=6.907e-007;
	luminance_ciel_bleus[606]=7.033e-007;
	luminance_ciel_bleus[607]=7.164e-007;
	luminance_ciel_bleus[608]=7.299e-007;
	luminance_ciel_bleus[609]=7.437e-007;
	luminance_ciel_bleus[610]=7.581e-007;
	luminance_ciel_bleus[611]=7.728e-007;
	luminance_ciel_bleus[612]=7.881e-007;
	luminance_ciel_bleus[613]=8.037e-007;
	luminance_ciel_bleus[614]=8.199e-007;
	luminance_ciel_bleus[615]=8.366e-007;
	luminance_ciel_bleus[616]=8.538e-007;
	luminance_ciel_bleus[617]=8.715e-007;
	luminance_ciel_bleus[618]=8.898e-007;
	luminance_ciel_bleus[619]=9.087e-007;
	luminance_ciel_bleus[620]=9.281e-007;
	luminance_ciel_bleus[621]=9.481e-007;
	luminance_ciel_bleus[622]=9.687e-007;
	luminance_ciel_bleus[623]=9.899e-007;
	luminance_ciel_bleus[624]=1.012e-006;
	luminance_ciel_bleus[625]=1.034e-006;
	luminance_ciel_bleus[626]=1.058e-006;
	luminance_ciel_bleus[627]=1.082e-006;
	luminance_ciel_bleus[628]=1.106e-006;
	luminance_ciel_bleus[629]=1.132e-006;
	luminance_ciel_bleus[630]=1.158e-006;
	luminance_ciel_bleus[631]=1.185e-006;
	luminance_ciel_bleus[632]=1.212e-006;
	luminance_ciel_bleus[633]=1.241e-006;
	luminance_ciel_bleus[634]=1.271e-006;
	luminance_ciel_bleus[635]=1.301e-006;
	luminance_ciel_bleus[636]=1.332e-006;
	luminance_ciel_bleus[637]=1.364e-006;
	luminance_ciel_bleus[638]=1.397e-006;
	luminance_ciel_bleus[639]=1.432e-006;
	luminance_ciel_bleus[640]=1.467e-006;
	luminance_ciel_bleus[641]=1.503e-006;
	luminance_ciel_bleus[642]=1.540e-006;
	luminance_ciel_bleus[643]=1.579e-006;
	luminance_ciel_bleus[644]=1.618e-006;
	luminance_ciel_bleus[645]=1.659e-006;
	luminance_ciel_bleus[646]=1.701e-006;
	luminance_ciel_bleus[647]=1.744e-006;
	luminance_ciel_bleus[648]=1.788e-006;
	luminance_ciel_bleus[649]=1.834e-006;
	luminance_ciel_bleus[650]=1.881e-006;
	luminance_ciel_bleus[651]=1.929e-006;
	luminance_ciel_bleus[652]=1.979e-006;
	luminance_ciel_bleus[653]=2.030e-006;
	luminance_ciel_bleus[654]=2.083e-006;
	luminance_ciel_bleus[655]=2.138e-006;
	luminance_ciel_bleus[656]=2.195e-006;
	luminance_ciel_bleus[657]=2.253e-006;
	luminance_ciel_bleus[658]=2.314e-006;
	luminance_ciel_bleus[659]=2.377e-006;
	luminance_ciel_bleus[660]=2.442e-006;
	luminance_ciel_bleus[661]=2.509e-006;
	luminance_ciel_bleus[662]=2.580e-006;
	luminance_ciel_bleus[663]=2.653e-006;
	luminance_ciel_bleus[664]=2.729e-006;
	luminance_ciel_bleus[665]=2.809e-006;
	luminance_ciel_bleus[666]=2.891e-006;
	luminance_ciel_bleus[667]=2.978e-006;
	luminance_ciel_bleus[668]=3.068e-006;
	luminance_ciel_bleus[669]=3.163e-006;
	luminance_ciel_bleus[670]=3.262e-006;
	luminance_ciel_bleus[671]=3.365e-006;
	luminance_ciel_bleus[672]=3.474e-006;
	luminance_ciel_bleus[673]=3.588e-006;
	luminance_ciel_bleus[674]=3.708e-006;
	luminance_ciel_bleus[675]=3.834e-006;
	luminance_ciel_bleus[676]=3.967e-006;
	luminance_ciel_bleus[677]=4.106e-006;
	luminance_ciel_bleus[678]=4.253e-006;
	luminance_ciel_bleus[679]=4.409e-006;
	luminance_ciel_bleus[680]=4.573e-006;
	luminance_ciel_bleus[681]=4.746e-006;
	luminance_ciel_bleus[682]=4.930e-006;
	luminance_ciel_bleus[683]=5.124e-006;
	luminance_ciel_bleus[684]=5.329e-006;
	luminance_ciel_bleus[685]=5.548e-006;
	luminance_ciel_bleus[686]=5.779e-006;
	luminance_ciel_bleus[687]=6.025e-006;
	luminance_ciel_bleus[688]=6.287e-006;
	luminance_ciel_bleus[689]=6.566e-006;
	luminance_ciel_bleus[690]=6.863e-006;
	luminance_ciel_bleus[691]=7.180e-006;
	luminance_ciel_bleus[692]=7.518e-006;
	luminance_ciel_bleus[693]=7.879e-006;
	luminance_ciel_bleus[694]=8.265e-006;
	luminance_ciel_bleus[695]=8.679e-006;
	luminance_ciel_bleus[696]=9.122e-006;
	luminance_ciel_bleus[697]=9.598e-006;
	luminance_ciel_bleus[698]=1.011e-005;
	luminance_ciel_bleus[699]=1.066e-005;
	luminance_ciel_bleus[700]=1.125e-005;
	luminance_ciel_bleus[701]=1.188e-005;
	luminance_ciel_bleus[702]=1.257e-005;
	luminance_ciel_bleus[703]=1.331e-005;
	luminance_ciel_bleus[704]=1.410e-005;
	luminance_ciel_bleus[705]=1.496e-005;
	luminance_ciel_bleus[706]=1.589e-005;
	luminance_ciel_bleus[707]=1.688e-005;
	luminance_ciel_bleus[708]=1.796e-005;
	luminance_ciel_bleus[709]=1.912e-005;
	luminance_ciel_bleus[710]=2.038e-005;
	luminance_ciel_bleus[711]=2.173e-005;
	luminance_ciel_bleus[712]=2.320e-005;
	luminance_ciel_bleus[713]=2.478e-005;
	luminance_ciel_bleus[714]=2.649e-005;
	luminance_ciel_bleus[715]=2.834e-005;
	luminance_ciel_bleus[716]=3.033e-005;
	luminance_ciel_bleus[717]=3.249e-005;
	luminance_ciel_bleus[718]=3.483e-005;
	luminance_ciel_bleus[719]=3.736e-005;
	luminance_ciel_bleus[720]=4.010e-005;
	luminance_ciel_bleus[721]=4.306e-005;
	luminance_ciel_bleus[722]=4.626e-005;
	luminance_ciel_bleus[723]=4.973e-005;
	luminance_ciel_bleus[724]=5.349e-005;
	luminance_ciel_bleus[725]=5.755e-005;
	luminance_ciel_bleus[726]=6.194e-005;
	luminance_ciel_bleus[727]=6.669e-005;
	luminance_ciel_bleus[728]=7.183e-005;
	luminance_ciel_bleus[729]=7.738e-005;
	luminance_ciel_bleus[730]=8.338e-005;
	luminance_ciel_bleus[731]=8.987e-005;
	luminance_ciel_bleus[732]=9.687e-005;
	luminance_ciel_bleus[733]=1.044e-004;
	luminance_ciel_bleus[734]=1.126e-004;
	luminance_ciel_bleus[735]=1.214e-004;
	luminance_ciel_bleus[736]=1.309e-004;
	luminance_ciel_bleus[737]=1.411e-004;
	luminance_ciel_bleus[738]=1.522e-004;
	luminance_ciel_bleus[739]=1.640e-004;
	luminance_ciel_bleus[740]=1.768e-004;
	luminance_ciel_bleus[741]=1.905e-004;
	luminance_ciel_bleus[742]=2.053e-004;
	luminance_ciel_bleus[743]=2.211e-004;
	luminance_ciel_bleus[744]=2.382e-004;
	luminance_ciel_bleus[745]=2.567e-004;
	luminance_ciel_bleus[746]=2.767e-004;
	luminance_ciel_bleus[747]=2.984e-004;
	luminance_ciel_bleus[748]=3.222e-004;
	luminance_ciel_bleus[749]=3.483e-004;
	luminance_ciel_bleus[750]=3.771e-004;
	luminance_ciel_bleus[751]=4.088e-004;
	luminance_ciel_bleus[752]=4.439e-004;
	luminance_ciel_bleus[753]=4.828e-004;
	luminance_ciel_bleus[754]=5.257e-004;
	luminance_ciel_bleus[755]=5.730e-004;
	luminance_ciel_bleus[756]=6.252e-004;
	luminance_ciel_bleus[757]=6.828e-004;
	luminance_ciel_bleus[758]=7.461e-004;
	luminance_ciel_bleus[759]=8.157e-004;
	luminance_ciel_bleus[760]=8.921e-004;
	luminance_ciel_bleus[761]=9.758e-004;
	luminance_ciel_bleus[762]=1.067e-003;
	luminance_ciel_bleus[763]=1.168e-003;
	luminance_ciel_bleus[764]=1.278e-003;
	luminance_ciel_bleus[765]=1.398e-003;
	luminance_ciel_bleus[766]=1.529e-003;
	luminance_ciel_bleus[767]=1.673e-003;
	luminance_ciel_bleus[768]=1.831e-003;
	luminance_ciel_bleus[769]=2.004e-003;
	luminance_ciel_bleus[770]=2.194e-003;
	luminance_ciel_bleus[771]=2.404e-003;
	luminance_ciel_bleus[772]=2.634e-003;
	luminance_ciel_bleus[773]=2.887e-003;
	luminance_ciel_bleus[774]=3.166e-003;
	luminance_ciel_bleus[775]=3.474e-003;
	luminance_ciel_bleus[776]=3.815e-003;
	luminance_ciel_bleus[777]=4.191e-003;
	luminance_ciel_bleus[778]=4.608e-003;
	luminance_ciel_bleus[779]=5.070e-003;
	luminance_ciel_bleus[780]=5.583e-003;
	luminance_ciel_bleus[781]=6.153e-003;
	luminance_ciel_bleus[782]=6.787e-003;
	luminance_ciel_bleus[783]=7.491e-003;
	luminance_ciel_bleus[784]=8.271e-003;
	luminance_ciel_bleus[785]=9.133e-003;
	luminance_ciel_bleus[786]=1.008e-002;
	luminance_ciel_bleus[787]=1.113e-002;
	luminance_ciel_bleus[788]=1.227e-002;
	luminance_ciel_bleus[789]=1.352e-002;
	luminance_ciel_bleus[790]=1.489e-002;
	luminance_ciel_bleus[791]=1.639e-002;
	luminance_ciel_bleus[792]=1.802e-002;
	luminance_ciel_bleus[793]=1.980e-002;
	luminance_ciel_bleus[794]=2.174e-002;
	luminance_ciel_bleus[795]=2.385e-002;
	luminance_ciel_bleus[796]=2.616e-002;
	luminance_ciel_bleus[797]=2.868e-002;
	luminance_ciel_bleus[798]=3.144e-002;
	luminance_ciel_bleus[799]=3.447e-002;
	luminance_ciel_bleus[800]=3.778e-002;
	luminance_ciel_bleus[801]=4.142e-002;
	luminance_ciel_bleus[802]=4.543e-002;
	luminance_ciel_bleus[803]=4.984e-002;
	luminance_ciel_bleus[804]=5.470e-002;
	luminance_ciel_bleus[805]=6.008e-002;
	luminance_ciel_bleus[806]=6.603e-002;
	luminance_ciel_bleus[807]=7.263e-002;
	luminance_ciel_bleus[808]=7.996e-002;
	luminance_ciel_bleus[809]=8.812e-002;
	luminance_ciel_bleus[810]=9.720e-002;
	luminance_ciel_bleus[811]=1.073e-001;
	luminance_ciel_bleus[812]=1.186e-001;
	luminance_ciel_bleus[813]=1.312e-001;
	luminance_ciel_bleus[814]=1.453e-001;
	luminance_ciel_bleus[815]=1.611e-001;
	luminance_ciel_bleus[816]=1.787e-001;
	luminance_ciel_bleus[817]=1.986e-001;
	luminance_ciel_bleus[818]=2.208e-001;
	luminance_ciel_bleus[819]=2.459e-001;
	luminance_ciel_bleus[820]=2.741e-001;
	luminance_ciel_bleus[821]=3.060e-001;
	luminance_ciel_bleus[822]=3.418e-001;
	luminance_ciel_bleus[823]=3.823e-001;
	luminance_ciel_bleus[824]=4.278e-001;
	luminance_ciel_bleus[825]=4.791e-001;
	luminance_ciel_bleus[826]=5.369e-001;
	luminance_ciel_bleus[827]=6.020e-001;
	luminance_ciel_bleus[828]=6.753e-001;
	luminance_ciel_bleus[829]=7.578e-001;
	luminance_ciel_bleus[830]=8.506e-001;
	luminance_ciel_bleus[831]=9.551e-001;
	luminance_ciel_bleus[832]=1.073e+000;
	luminance_ciel_bleus[833]=1.205e+000;
	luminance_ciel_bleus[834]=1.355e+000;
	luminance_ciel_bleus[835]=1.523e+000;
	luminance_ciel_bleus[836]=1.714e+000;
	luminance_ciel_bleus[837]=1.929e+000;
	luminance_ciel_bleus[838]=2.173e+000;
	luminance_ciel_bleus[839]=2.449e+000;
	luminance_ciel_bleus[840]=2.762e+000;
	luminance_ciel_bleus[841]=3.118e+000;
	luminance_ciel_bleus[842]=3.523e+000;
	luminance_ciel_bleus[843]=3.984e+000;
	luminance_ciel_bleus[844]=4.510e+000;
	luminance_ciel_bleus[845]=5.109e+000;
	luminance_ciel_bleus[846]=5.793e+000;
	luminance_ciel_bleus[847]=6.573e+000;
	luminance_ciel_bleus[848]=7.461e+000;
	luminance_ciel_bleus[849]=8.473e+000;
	luminance_ciel_bleus[850]=9.622e+000;
	luminance_ciel_bleus[851]=1.092e+001;
	luminance_ciel_bleus[852]=1.240e+001;
	luminance_ciel_bleus[853]=1.405e+001;
	luminance_ciel_bleus[854]=1.591e+001;
	luminance_ciel_bleus[855]=1.799e+001;
	luminance_ciel_bleus[856]=2.030e+001;
	luminance_ciel_bleus[857]=2.286e+001;
	luminance_ciel_bleus[858]=2.568e+001;
	luminance_ciel_bleus[859]=2.877e+001;
	luminance_ciel_bleus[860]=3.217e+001;
	luminance_ciel_bleus[861]=3.587e+001;
	luminance_ciel_bleus[862]=3.990e+001;
	luminance_ciel_bleus[863]=4.428e+001;
	luminance_ciel_bleus[864]=4.902e+001;
	luminance_ciel_bleus[865]=5.413e+001;
	luminance_ciel_bleus[866]=5.964e+001;
	luminance_ciel_bleus[867]=6.556e+001;
	luminance_ciel_bleus[868]=7.190e+001;
	luminance_ciel_bleus[869]=7.868e+001;
	luminance_ciel_bleus[870]=8.591e+001;
	luminance_ciel_bleus[871]=9.360e+001;
	luminance_ciel_bleus[872]=1.018e+002;
	luminance_ciel_bleus[873]=1.104e+002;
	luminance_ciel_bleus[874]=1.195e+002;
	luminance_ciel_bleus[875]=1.291e+002;
	luminance_ciel_bleus[876]=1.391e+002;
	luminance_ciel_bleus[877]=1.497e+002;
	luminance_ciel_bleus[878]=1.607e+002;
	luminance_ciel_bleus[879]=1.722e+002;
	luminance_ciel_bleus[880]=1.841e+002;
	luminance_ciel_bleus[881]=1.965e+002;
	luminance_ciel_bleus[882]=2.093e+002;
	luminance_ciel_bleus[883]=2.224e+002;
	luminance_ciel_bleus[884]=2.360e+002;
	luminance_ciel_bleus[885]=2.500e+002;
	luminance_ciel_bleus[886]=2.643e+002;
	luminance_ciel_bleus[887]=2.790e+002;
	luminance_ciel_bleus[888]=2.940e+002;
	luminance_ciel_bleus[889]=3.093e+002;
	luminance_ciel_bleus[890]=3.250e+002;
	luminance_ciel_bleus[891]=3.410e+002;
	luminance_ciel_bleus[892]=3.573e+002;
	luminance_ciel_bleus[893]=3.738e+002;
	luminance_ciel_bleus[894]=3.907e+002;
	luminance_ciel_bleus[895]=4.078e+002;
	luminance_ciel_bleus[896]=4.251e+002;
	luminance_ciel_bleus[897]=4.427e+002;
	luminance_ciel_bleus[898]=4.604e+002;
	luminance_ciel_bleus[899]=4.782e+002;
	luminance_ciel_bleus[900]=4.962e+002;
	luminance_ciel_bleus[901]=5.143e+002;
	luminance_ciel_bleus[902]=5.325e+002;
	luminance_ciel_bleus[903]=5.507e+002;
	luminance_ciel_bleus[904]=5.690e+002;
	luminance_ciel_bleus[905]=5.873e+002;
	luminance_ciel_bleus[906]=6.056e+002;
	luminance_ciel_bleus[907]=6.239e+002;
	luminance_ciel_bleus[908]=6.421e+002;
	luminance_ciel_bleus[909]=6.603e+002;
	luminance_ciel_bleus[910]=6.785e+002;
	luminance_ciel_bleus[911]=6.966e+002;
	luminance_ciel_bleus[912]=7.146e+002;
	luminance_ciel_bleus[913]=7.325e+002;
	luminance_ciel_bleus[914]=7.503e+002;
	luminance_ciel_bleus[915]=7.680e+002;
	luminance_ciel_bleus[916]=7.855e+002;
	luminance_ciel_bleus[917]=8.029e+002;
	luminance_ciel_bleus[918]=8.202e+002;
	luminance_ciel_bleus[919]=8.373e+002;
	luminance_ciel_bleus[920]=8.543e+002;
	luminance_ciel_bleus[921]=8.711e+002;
	luminance_ciel_bleus[922]=8.877e+002;
	luminance_ciel_bleus[923]=9.042e+002;
	luminance_ciel_bleus[924]=9.204e+002;
	luminance_ciel_bleus[925]=9.365e+002;
	luminance_ciel_bleus[926]=9.524e+002;
	luminance_ciel_bleus[927]=9.682e+002;
	luminance_ciel_bleus[928]=9.837e+002;
	luminance_ciel_bleus[929]=9.991e+002;
	luminance_ciel_bleus[930]=1.014e+003;
	luminance_ciel_bleus[931]=1.029e+003;
	luminance_ciel_bleus[932]=1.044e+003;
	luminance_ciel_bleus[933]=1.059e+003;
	luminance_ciel_bleus[934]=1.073e+003;
	luminance_ciel_bleus[935]=1.087e+003;
	luminance_ciel_bleus[936]=1.101e+003;
	luminance_ciel_bleus[937]=1.115e+003;
	luminance_ciel_bleus[938]=1.129e+003;
	luminance_ciel_bleus[939]=1.142e+003;
	luminance_ciel_bleus[940]=1.155e+003;
	luminance_ciel_bleus[941]=1.169e+003;
	luminance_ciel_bleus[942]=1.182e+003;
	luminance_ciel_bleus[943]=1.194e+003;
	luminance_ciel_bleus[944]=1.207e+003;
	luminance_ciel_bleus[945]=1.220e+003;
	luminance_ciel_bleus[946]=1.232e+003;
	luminance_ciel_bleus[947]=1.244e+003;
	luminance_ciel_bleus[948]=1.256e+003;
	luminance_ciel_bleus[949]=1.268e+003;
	luminance_ciel_bleus[950]=1.279e+003;
	luminance_ciel_bleus[951]=1.291e+003;
	luminance_ciel_bleus[952]=1.302e+003;
	luminance_ciel_bleus[953]=1.313e+003;
	luminance_ciel_bleus[954]=1.324e+003;
	luminance_ciel_bleus[955]=1.335e+003;
	luminance_ciel_bleus[956]=1.346e+003;
	luminance_ciel_bleus[957]=1.356e+003;
	luminance_ciel_bleus[958]=1.367e+003;
	luminance_ciel_bleus[959]=1.377e+003;
	luminance_ciel_bleus[960]=1.388e+003;
	luminance_ciel_bleus[961]=1.398e+003;
	luminance_ciel_bleus[962]=1.408e+003;
	luminance_ciel_bleus[963]=1.418e+003;
	luminance_ciel_bleus[964]=1.428e+003;
	luminance_ciel_bleus[965]=1.438e+003;
	luminance_ciel_bleus[966]=1.448e+003;
	luminance_ciel_bleus[967]=1.458e+003;
	luminance_ciel_bleus[968]=1.468e+003;
	luminance_ciel_bleus[969]=1.478e+003;
	luminance_ciel_bleus[970]=1.488e+003;
	luminance_ciel_bleus[971]=1.498e+003;
	luminance_ciel_bleus[972]=1.507e+003;
	luminance_ciel_bleus[973]=1.517e+003;
	luminance_ciel_bleus[974]=1.526e+003;
	luminance_ciel_bleus[975]=1.536e+003;
	luminance_ciel_bleus[976]=1.545e+003;
	luminance_ciel_bleus[977]=1.555e+003;
	luminance_ciel_bleus[978]=1.564e+003;
	luminance_ciel_bleus[979]=1.574e+003;
	luminance_ciel_bleus[980]=1.583e+003;
	luminance_ciel_bleus[981]=1.592e+003;
	luminance_ciel_bleus[982]=1.601e+003;
	luminance_ciel_bleus[983]=1.610e+003;
	luminance_ciel_bleus[984]=1.619e+003;
	luminance_ciel_bleus[985]=1.628e+003;
	luminance_ciel_bleus[986]=1.637e+003;
	luminance_ciel_bleus[987]=1.646e+003;
	luminance_ciel_bleus[988]=1.655e+003;
	luminance_ciel_bleus[989]=1.663e+003;
	luminance_ciel_bleus[990]=1.672e+003;
	luminance_ciel_bleus[991]=1.681e+003;
	luminance_ciel_bleus[992]=1.689e+003;
	luminance_ciel_bleus[993]=1.698e+003;
	luminance_ciel_bleus[994]=1.706e+003;
	luminance_ciel_bleus[995]=1.715e+003;
	luminance_ciel_bleus[996]=1.723e+003;
	luminance_ciel_bleus[997]=1.732e+003;
	luminance_ciel_bleus[998]=1.740e+003;
	luminance_ciel_bleus[999]=1.748e+003;
	luminance_ciel_bleus[1000]=1.757e+003;
	luminance_ciel_bleus[1001]=1.765e+003;
	luminance_ciel_bleus[1002]=1.773e+003;
	luminance_ciel_bleus[1003]=1.781e+003;
	luminance_ciel_bleus[1004]=1.789e+003;
	luminance_ciel_bleus[1005]=1.797e+003;
	luminance_ciel_bleus[1006]=1.806e+003;
	luminance_ciel_bleus[1007]=1.814e+003;
	luminance_ciel_bleus[1008]=1.821e+003;
	luminance_ciel_bleus[1009]=1.829e+003;
	luminance_ciel_bleus[1010]=1.837e+003;
	luminance_ciel_bleus[1011]=1.845e+003;
	luminance_ciel_bleus[1012]=1.853e+003;
	luminance_ciel_bleus[1013]=1.860e+003;
	luminance_ciel_bleus[1014]=1.868e+003;
	luminance_ciel_bleus[1015]=1.875e+003;
	luminance_ciel_bleus[1016]=1.883e+003;
	luminance_ciel_bleus[1017]=1.890e+003;
	luminance_ciel_bleus[1018]=1.897e+003;
	luminance_ciel_bleus[1019]=1.904e+003;
	luminance_ciel_bleus[1020]=1.911e+003;
	luminance_ciel_bleus[1021]=1.918e+003;
	luminance_ciel_bleus[1022]=1.925e+003;
	luminance_ciel_bleus[1023]=1.932e+003;
	luminance_ciel_bleus[1024]=1.939e+003;
	luminance_ciel_bleus[1025]=1.945e+003;
	luminance_ciel_bleus[1026]=1.952e+003;
	luminance_ciel_bleus[1027]=1.959e+003;
	luminance_ciel_bleus[1028]=1.965e+003;
	luminance_ciel_bleus[1029]=1.972e+003;
	luminance_ciel_bleus[1030]=1.978e+003;
	luminance_ciel_bleus[1031]=1.985e+003;
	luminance_ciel_bleus[1032]=1.991e+003;
	luminance_ciel_bleus[1033]=1.997e+003;
	luminance_ciel_bleus[1034]=2.004e+003;
	luminance_ciel_bleus[1035]=2.010e+003;
	luminance_ciel_bleus[1036]=2.017e+003;
	luminance_ciel_bleus[1037]=2.023e+003;
	luminance_ciel_bleus[1038]=2.029e+003;
	luminance_ciel_bleus[1039]=2.036e+003;
	luminance_ciel_bleus[1040]=2.042e+003;
	luminance_ciel_bleus[1041]=2.048e+003;
	luminance_ciel_bleus[1042]=2.055e+003;
	luminance_ciel_bleus[1043]=2.061e+003;
	luminance_ciel_bleus[1044]=2.068e+003;
	luminance_ciel_bleus[1045]=2.075e+003;
	luminance_ciel_bleus[1046]=2.081e+003;
	luminance_ciel_bleus[1047]=2.088e+003;
	luminance_ciel_bleus[1048]=2.095e+003;
	luminance_ciel_bleus[1049]=2.102e+003;
	luminance_ciel_bleus[1050]=2.108e+003;
	luminance_ciel_bleus[1051]=2.115e+003;
	luminance_ciel_bleus[1052]=2.122e+003;
	luminance_ciel_bleus[1053]=2.129e+003;
	luminance_ciel_bleus[1054]=2.136e+003;
	luminance_ciel_bleus[1055]=2.143e+003;
	luminance_ciel_bleus[1056]=2.151e+003;
	luminance_ciel_bleus[1057]=2.158e+003;
	luminance_ciel_bleus[1058]=2.165e+003;
	luminance_ciel_bleus[1059]=2.172e+003;
	luminance_ciel_bleus[1060]=2.180e+003;
	luminance_ciel_bleus[1061]=2.187e+003;
	luminance_ciel_bleus[1062]=2.194e+003;
	luminance_ciel_bleus[1063]=2.202e+003;
	luminance_ciel_bleus[1064]=2.209e+003;
	luminance_ciel_bleus[1065]=2.217e+003;
	luminance_ciel_bleus[1066]=2.224e+003;
	luminance_ciel_bleus[1067]=2.232e+003;
	luminance_ciel_bleus[1068]=2.239e+003;
	luminance_ciel_bleus[1069]=2.247e+003;
	luminance_ciel_bleus[1070]=2.254e+003;
	luminance_ciel_bleus[1071]=2.262e+003;
	luminance_ciel_bleus[1072]=2.270e+003;
	luminance_ciel_bleus[1073]=2.277e+003;
	luminance_ciel_bleus[1074]=2.285e+003;
	luminance_ciel_bleus[1075]=2.293e+003;
	luminance_ciel_bleus[1076]=2.300e+003;
	luminance_ciel_bleus[1077]=2.308e+003;
	luminance_ciel_bleus[1078]=2.316e+003;
	luminance_ciel_bleus[1079]=2.324e+003;
	luminance_ciel_bleus[1080]=2.331e+003;
	luminance_ciel_bleus[1081]=2.339e+003;
	luminance_ciel_bleus[1082]=2.347e+003;
	luminance_ciel_bleus[1083]=2.354e+003;
	luminance_ciel_bleus[1084]=2.362e+003;
	luminance_ciel_bleus[1085]=2.370e+003;
	luminance_ciel_bleus[1086]=2.378e+003;
	luminance_ciel_bleus[1087]=2.385e+003;
	luminance_ciel_bleus[1088]=2.393e+003;
	luminance_ciel_bleus[1089]=2.401e+003;
	luminance_ciel_bleus[1090]=2.408e+003;
	luminance_ciel_bleus[1091]=2.416e+003;
	luminance_ciel_bleus[1092]=2.423e+003;
	luminance_ciel_bleus[1093]=2.431e+003;
	luminance_ciel_bleus[1094]=2.438e+003;
	luminance_ciel_bleus[1095]=2.446e+003;
	luminance_ciel_bleus[1096]=2.453e+003;
	luminance_ciel_bleus[1097]=2.461e+003;
	luminance_ciel_bleus[1098]=2.468e+003;
	luminance_ciel_bleus[1099]=2.475e+003;
	luminance_ciel_bleus[1100]=2.483e+003;
	luminance_ciel_bleus[1101]=2.490e+003;
	luminance_ciel_bleus[1102]=2.497e+003;
	luminance_ciel_bleus[1103]=2.504e+003;
	luminance_ciel_bleus[1104]=2.511e+003;
	luminance_ciel_bleus[1105]=2.518e+003;
	luminance_ciel_bleus[1106]=2.525e+003;
	luminance_ciel_bleus[1107]=2.532e+003;
	luminance_ciel_bleus[1108]=2.539e+003;
	luminance_ciel_bleus[1109]=2.546e+003;
	luminance_ciel_bleus[1110]=2.553e+003;
	luminance_ciel_bleus[1111]=2.560e+003;
	luminance_ciel_bleus[1112]=2.566e+003;
	luminance_ciel_bleus[1113]=2.573e+003;
	luminance_ciel_bleus[1114]=2.580e+003;
	luminance_ciel_bleus[1115]=2.586e+003;
	luminance_ciel_bleus[1116]=2.593e+003;
	luminance_ciel_bleus[1117]=2.600e+003;
	luminance_ciel_bleus[1118]=2.606e+003;
	luminance_ciel_bleus[1119]=2.613e+003;
	luminance_ciel_bleus[1120]=2.619e+003;
	luminance_ciel_bleus[1121]=2.626e+003;
	luminance_ciel_bleus[1122]=2.633e+003;
	luminance_ciel_bleus[1123]=2.639e+003;
	luminance_ciel_bleus[1124]=2.645e+003;
	luminance_ciel_bleus[1125]=2.652e+003;
	luminance_ciel_bleus[1126]=2.658e+003;
	luminance_ciel_bleus[1127]=2.664e+003;
	luminance_ciel_bleus[1128]=2.670e+003;
	luminance_ciel_bleus[1129]=2.676e+003;
	luminance_ciel_bleus[1130]=2.682e+003;
	luminance_ciel_bleus[1131]=2.688e+003;
	luminance_ciel_bleus[1132]=2.694e+003;
	luminance_ciel_bleus[1133]=2.700e+003;
	luminance_ciel_bleus[1134]=2.705e+003;
	luminance_ciel_bleus[1135]=2.711e+003;
	luminance_ciel_bleus[1136]=2.717e+003;
	luminance_ciel_bleus[1137]=2.722e+003;
	luminance_ciel_bleus[1138]=2.728e+003;
	luminance_ciel_bleus[1139]=2.733e+003;
	luminance_ciel_bleus[1140]=2.739e+003;
	luminance_ciel_bleus[1141]=2.744e+003;
	luminance_ciel_bleus[1142]=2.749e+003;
	luminance_ciel_bleus[1143]=2.755e+003;
	luminance_ciel_bleus[1144]=2.760e+003;
	luminance_ciel_bleus[1145]=2.765e+003;
	luminance_ciel_bleus[1146]=2.770e+003;
	luminance_ciel_bleus[1147]=2.776e+003;
	luminance_ciel_bleus[1148]=2.781e+003;
	luminance_ciel_bleus[1149]=2.786e+003;
	luminance_ciel_bleus[1150]=2.791e+003;
	luminance_ciel_bleus[1151]=2.796e+003;
	luminance_ciel_bleus[1152]=2.801e+003;
	luminance_ciel_bleus[1153]=2.806e+003;
	luminance_ciel_bleus[1154]=2.812e+003;
	luminance_ciel_bleus[1155]=2.817e+003;
	luminance_ciel_bleus[1156]=2.822e+003;
	luminance_ciel_bleus[1157]=2.827e+003;
	luminance_ciel_bleus[1158]=2.832e+003;
	luminance_ciel_bleus[1159]=2.837e+003;
	luminance_ciel_bleus[1160]=2.842e+003;
	luminance_ciel_bleus[1161]=2.847e+003;
	luminance_ciel_bleus[1162]=2.853e+003;
	luminance_ciel_bleus[1163]=2.858e+003;
	luminance_ciel_bleus[1164]=2.863e+003;
	luminance_ciel_bleus[1165]=2.868e+003;
	luminance_ciel_bleus[1166]=2.873e+003;
	luminance_ciel_bleus[1167]=2.879e+003;
	luminance_ciel_bleus[1168]=2.884e+003;
	luminance_ciel_bleus[1169]=2.889e+003;
	luminance_ciel_bleus[1170]=2.894e+003;
	luminance_ciel_bleus[1171]=2.900e+003;
	luminance_ciel_bleus[1172]=2.905e+003;
	luminance_ciel_bleus[1173]=2.910e+003;
	luminance_ciel_bleus[1174]=2.915e+003;
	luminance_ciel_bleus[1175]=2.921e+003;
	luminance_ciel_bleus[1176]=2.926e+003;
	luminance_ciel_bleus[1177]=2.931e+003;
	luminance_ciel_bleus[1178]=2.937e+003;
	luminance_ciel_bleus[1179]=2.942e+003;
	luminance_ciel_bleus[1180]=2.947e+003;
	luminance_ciel_bleus[1181]=2.953e+003;
	luminance_ciel_bleus[1182]=2.958e+003;
	luminance_ciel_bleus[1183]=2.963e+003;
	luminance_ciel_bleus[1184]=2.969e+003;
	luminance_ciel_bleus[1185]=2.974e+003;
	luminance_ciel_bleus[1186]=2.979e+003;
	luminance_ciel_bleus[1187]=2.985e+003;
	luminance_ciel_bleus[1188]=2.990e+003;
	luminance_ciel_bleus[1189]=2.995e+003;
	luminance_ciel_bleus[1190]=3.001e+003;
	luminance_ciel_bleus[1191]=3.006e+003;
	luminance_ciel_bleus[1192]=3.011e+003;
	luminance_ciel_bleus[1193]=3.017e+003;
	luminance_ciel_bleus[1194]=3.022e+003;
	luminance_ciel_bleus[1195]=3.027e+003;
	luminance_ciel_bleus[1196]=3.033e+003;
	luminance_ciel_bleus[1197]=3.038e+003;
	luminance_ciel_bleus[1198]=3.043e+003;
	luminance_ciel_bleus[1199]=3.049e+003;
	luminance_ciel_bleus[1200]=3.054e+003;
	luminance_ciel_bleus[1201]=3.059e+003;
	luminance_ciel_bleus[1202]=3.065e+003;
	luminance_ciel_bleus[1203]=3.070e+003;
	luminance_ciel_bleus[1204]=3.075e+003;
	luminance_ciel_bleus[1205]=3.081e+003;
	luminance_ciel_bleus[1206]=3.086e+003;
	luminance_ciel_bleus[1207]=3.091e+003;
	luminance_ciel_bleus[1208]=3.096e+003;
	luminance_ciel_bleus[1209]=3.102e+003;
	luminance_ciel_bleus[1210]=3.107e+003;
	luminance_ciel_bleus[1211]=3.112e+003;
	luminance_ciel_bleus[1212]=3.118e+003;
	luminance_ciel_bleus[1213]=3.123e+003;
	luminance_ciel_bleus[1214]=3.128e+003;
	luminance_ciel_bleus[1215]=3.134e+003;
	luminance_ciel_bleus[1216]=3.139e+003;
	luminance_ciel_bleus[1217]=3.144e+003;
	luminance_ciel_bleus[1218]=3.150e+003;
	luminance_ciel_bleus[1219]=3.155e+003;
	luminance_ciel_bleus[1220]=3.161e+003;
	luminance_ciel_bleus[1221]=3.166e+003;
	luminance_ciel_bleus[1222]=3.172e+003;
	luminance_ciel_bleus[1223]=3.177e+003;
	luminance_ciel_bleus[1224]=3.183e+003;
	luminance_ciel_bleus[1225]=3.188e+003;
	luminance_ciel_bleus[1226]=3.194e+003;
	luminance_ciel_bleus[1227]=3.200e+003;
	luminance_ciel_bleus[1228]=3.205e+003;
	luminance_ciel_bleus[1229]=3.211e+003;
	luminance_ciel_bleus[1230]=3.217e+003;
	luminance_ciel_bleus[1231]=3.223e+003;
	luminance_ciel_bleus[1232]=3.229e+003;
	luminance_ciel_bleus[1233]=3.235e+003;
	luminance_ciel_bleus[1234]=3.242e+003;
	luminance_ciel_bleus[1235]=3.248e+003;
	luminance_ciel_bleus[1236]=3.254e+003;
	luminance_ciel_bleus[1237]=3.261e+003;
	luminance_ciel_bleus[1238]=3.267e+003;
	luminance_ciel_bleus[1239]=3.274e+003;
	luminance_ciel_bleus[1240]=3.281e+003;
	luminance_ciel_bleus[1241]=3.288e+003;
	luminance_ciel_bleus[1242]=3.295e+003;
	luminance_ciel_bleus[1243]=3.302e+003;
	luminance_ciel_bleus[1244]=3.309e+003;
	luminance_ciel_bleus[1245]=3.316e+003;
	luminance_ciel_bleus[1246]=3.324e+003;
	luminance_ciel_bleus[1247]=3.331e+003;
	luminance_ciel_bleus[1248]=3.338e+003;
	luminance_ciel_bleus[1249]=3.346e+003;
	luminance_ciel_bleus[1250]=3.353e+003;
	luminance_ciel_bleus[1251]=3.361e+003;
	luminance_ciel_bleus[1252]=3.369e+003;
	luminance_ciel_bleus[1253]=3.376e+003;
	luminance_ciel_bleus[1254]=3.384e+003;
	luminance_ciel_bleus[1255]=3.392e+003;
	luminance_ciel_bleus[1256]=3.400e+003;
	luminance_ciel_bleus[1257]=3.408e+003;
	luminance_ciel_bleus[1258]=3.415e+003;
	luminance_ciel_bleus[1259]=3.423e+003;
	luminance_ciel_bleus[1260]=3.431e+003;
	luminance_ciel_bleus[1261]=3.439e+003;
	luminance_ciel_bleus[1262]=3.447e+003;
	luminance_ciel_bleus[1263]=3.455e+003;
	luminance_ciel_bleus[1264]=3.463e+003;
	luminance_ciel_bleus[1265]=3.471e+003;
	luminance_ciel_bleus[1266]=3.479e+003;
	luminance_ciel_bleus[1267]=3.487e+003;
	luminance_ciel_bleus[1268]=3.495e+003;
	luminance_ciel_bleus[1269]=3.503e+003;
	luminance_ciel_bleus[1270]=3.510e+003;
	luminance_ciel_bleus[1271]=3.518e+003;
	luminance_ciel_bleus[1272]=3.526e+003;
	luminance_ciel_bleus[1273]=3.534e+003;
	luminance_ciel_bleus[1274]=3.542e+003;
	luminance_ciel_bleus[1275]=3.549e+003;
	luminance_ciel_bleus[1276]=3.557e+003;
	luminance_ciel_bleus[1277]=3.565e+003;
	luminance_ciel_bleus[1278]=3.572e+003;
	luminance_ciel_bleus[1279]=3.580e+003;
	luminance_ciel_bleus[1280]=3.588e+003;
	luminance_ciel_bleus[1281]=3.596e+003;
	luminance_ciel_bleus[1282]=3.603e+003;
	luminance_ciel_bleus[1283]=3.611e+003;
	luminance_ciel_bleus[1284]=3.619e+003;
	luminance_ciel_bleus[1285]=3.627e+003;
	luminance_ciel_bleus[1286]=3.635e+003;
	luminance_ciel_bleus[1287]=3.643e+003;
	luminance_ciel_bleus[1288]=3.651e+003;
	luminance_ciel_bleus[1289]=3.659e+003;
	luminance_ciel_bleus[1290]=3.667e+003;
	luminance_ciel_bleus[1291]=3.675e+003;
	luminance_ciel_bleus[1292]=3.683e+003;
	luminance_ciel_bleus[1293]=3.691e+003;
	luminance_ciel_bleus[1294]=3.699e+003;
	luminance_ciel_bleus[1295]=3.708e+003;
	luminance_ciel_bleus[1296]=3.716e+003;
	luminance_ciel_bleus[1297]=3.725e+003;
	luminance_ciel_bleus[1298]=3.733e+003;
	luminance_ciel_bleus[1299]=3.742e+003;
	luminance_ciel_bleus[1300]=3.751e+003;
	luminance_ciel_bleus[1301]=3.759e+003;
	luminance_ciel_bleus[1302]=3.768e+003;
	luminance_ciel_bleus[1303]=3.777e+003;
	luminance_ciel_bleus[1304]=3.786e+003;
	luminance_ciel_bleus[1305]=3.794e+003;
	luminance_ciel_bleus[1306]=3.803e+003;
	luminance_ciel_bleus[1307]=3.812e+003;
	luminance_ciel_bleus[1308]=3.820e+003;
	luminance_ciel_bleus[1309]=3.829e+003;
	luminance_ciel_bleus[1310]=3.838e+003;
	luminance_ciel_bleus[1311]=3.846e+003;
	luminance_ciel_bleus[1312]=3.855e+003;
	luminance_ciel_bleus[1313]=3.863e+003;
	luminance_ciel_bleus[1314]=3.871e+003;
	luminance_ciel_bleus[1315]=3.879e+003;
	luminance_ciel_bleus[1316]=3.887e+003;
	luminance_ciel_bleus[1317]=3.895e+003;
	luminance_ciel_bleus[1318]=3.903e+003;
	luminance_ciel_bleus[1319]=3.911e+003;
	luminance_ciel_bleus[1320]=3.919e+003;
	luminance_ciel_bleus[1321]=3.926e+003;
	luminance_ciel_bleus[1322]=3.934e+003;
	luminance_ciel_bleus[1323]=3.942e+003;
	luminance_ciel_bleus[1324]=3.949e+003;
	luminance_ciel_bleus[1325]=3.956e+003;
	luminance_ciel_bleus[1326]=3.964e+003;
	luminance_ciel_bleus[1327]=3.971e+003;
	luminance_ciel_bleus[1328]=3.978e+003;
	luminance_ciel_bleus[1329]=3.986e+003;
	luminance_ciel_bleus[1330]=3.993e+003;
	luminance_ciel_bleus[1331]=4.000e+003;
	luminance_ciel_bleus[1332]=4.008e+003;
	luminance_ciel_bleus[1333]=4.015e+003;
	luminance_ciel_bleus[1334]=4.022e+003;
	luminance_ciel_bleus[1335]=4.029e+003;
	luminance_ciel_bleus[1336]=4.037e+003;
	luminance_ciel_bleus[1337]=4.044e+003;
	luminance_ciel_bleus[1338]=4.051e+003;
	luminance_ciel_bleus[1339]=4.059e+003;
	luminance_ciel_bleus[1340]=4.066e+003;
	luminance_ciel_bleus[1341]=4.074e+003;
	luminance_ciel_bleus[1342]=4.081e+003;
	luminance_ciel_bleus[1343]=4.089e+003;
	luminance_ciel_bleus[1344]=4.096e+003;
	luminance_ciel_bleus[1345]=4.104e+003;
	luminance_ciel_bleus[1346]=4.111e+003;
	luminance_ciel_bleus[1347]=4.119e+003;
	luminance_ciel_bleus[1348]=4.126e+003;
	luminance_ciel_bleus[1349]=4.134e+003;
	luminance_ciel_bleus[1350]=4.142e+003;
	luminance_ciel_bleus[1351]=4.149e+003;
	luminance_ciel_bleus[1352]=4.157e+003;
	luminance_ciel_bleus[1353]=4.165e+003;
	luminance_ciel_bleus[1354]=4.172e+003;
	luminance_ciel_bleus[1355]=4.180e+003;
	luminance_ciel_bleus[1356]=4.188e+003;
	luminance_ciel_bleus[1357]=4.196e+003;
	luminance_ciel_bleus[1358]=4.203e+003;
	luminance_ciel_bleus[1359]=4.211e+003;
	luminance_ciel_bleus[1360]=4.219e+003;
	luminance_ciel_bleus[1361]=4.227e+003;
	luminance_ciel_bleus[1362]=4.234e+003;
	luminance_ciel_bleus[1363]=4.242e+003;
	luminance_ciel_bleus[1364]=4.250e+003;
	luminance_ciel_bleus[1365]=4.258e+003;
	luminance_ciel_bleus[1366]=4.265e+003;
	luminance_ciel_bleus[1367]=4.273e+003;
	luminance_ciel_bleus[1368]=4.281e+003;
	luminance_ciel_bleus[1369]=4.288e+003;
	luminance_ciel_bleus[1370]=4.296e+003;
	luminance_ciel_bleus[1371]=4.304e+003;
	luminance_ciel_bleus[1372]=4.311e+003;
	luminance_ciel_bleus[1373]=4.319e+003;
	luminance_ciel_bleus[1374]=4.326e+003;
	luminance_ciel_bleus[1375]=4.334e+003;
	luminance_ciel_bleus[1376]=4.341e+003;
	luminance_ciel_bleus[1377]=4.348e+003;
	luminance_ciel_bleus[1378]=4.356e+003;
	luminance_ciel_bleus[1379]=4.363e+003;
	luminance_ciel_bleus[1380]=4.370e+003;
	luminance_ciel_bleus[1381]=4.377e+003;
	luminance_ciel_bleus[1382]=4.385e+003;
	luminance_ciel_bleus[1383]=4.392e+003;
	luminance_ciel_bleus[1384]=4.399e+003;
	luminance_ciel_bleus[1385]=4.406e+003;
	luminance_ciel_bleus[1386]=4.413e+003;
	luminance_ciel_bleus[1387]=4.420e+003;
	luminance_ciel_bleus[1388]=4.427e+003;
	luminance_ciel_bleus[1389]=4.434e+003;
	luminance_ciel_bleus[1390]=4.442e+003;
	luminance_ciel_bleus[1391]=4.449e+003;
	luminance_ciel_bleus[1392]=4.456e+003;
	luminance_ciel_bleus[1393]=4.463e+003;
	luminance_ciel_bleus[1394]=4.470e+003;
	luminance_ciel_bleus[1395]=4.477e+003;
	luminance_ciel_bleus[1396]=4.484e+003;
	luminance_ciel_bleus[1397]=4.491e+003;
	luminance_ciel_bleus[1398]=4.499e+003;
	luminance_ciel_bleus[1399]=4.506e+003;
	luminance_ciel_bleus[1400]=4.513e+003;
	luminance_ciel_bleus[1401]=4.520e+003;
	luminance_ciel_bleus[1402]=4.527e+003;
	luminance_ciel_bleus[1403]=4.534e+003;
	luminance_ciel_bleus[1404]=4.542e+003;
	luminance_ciel_bleus[1405]=4.549e+003;
	luminance_ciel_bleus[1406]=4.556e+003;
	luminance_ciel_bleus[1407]=4.563e+003;
	luminance_ciel_bleus[1408]=4.570e+003;
	luminance_ciel_bleus[1409]=4.578e+003;
	luminance_ciel_bleus[1410]=4.585e+003;
	luminance_ciel_bleus[1411]=4.592e+003;
	luminance_ciel_bleus[1412]=4.599e+003;
	luminance_ciel_bleus[1413]=4.607e+003;
	luminance_ciel_bleus[1414]=4.614e+003;
	luminance_ciel_bleus[1415]=4.621e+003;
	luminance_ciel_bleus[1416]=4.629e+003;
	luminance_ciel_bleus[1417]=4.636e+003;
	luminance_ciel_bleus[1418]=4.643e+003;
	luminance_ciel_bleus[1419]=4.651e+003;
	luminance_ciel_bleus[1420]=4.658e+003;
	luminance_ciel_bleus[1421]=4.665e+003;
	luminance_ciel_bleus[1422]=4.673e+003;
	luminance_ciel_bleus[1423]=4.680e+003;
	luminance_ciel_bleus[1424]=4.687e+003;
	luminance_ciel_bleus[1425]=4.695e+003;
	luminance_ciel_bleus[1426]=4.702e+003;
	luminance_ciel_bleus[1427]=4.710e+003;
	luminance_ciel_bleus[1428]=4.717e+003;
	luminance_ciel_bleus[1429]=4.725e+003;
	luminance_ciel_bleus[1430]=4.732e+003;
	luminance_ciel_bleus[1431]=4.740e+003;
	luminance_ciel_bleus[1432]=4.747e+003;
	luminance_ciel_bleus[1433]=4.755e+003;
	luminance_ciel_bleus[1434]=4.762e+003;
	luminance_ciel_bleus[1435]=4.770e+003;
	luminance_ciel_bleus[1436]=4.777e+003;
	luminance_ciel_bleus[1437]=4.785e+003;
	luminance_ciel_bleus[1438]=4.793e+003;
	luminance_ciel_bleus[1439]=4.800e+003;
	luminance_ciel_bleus[1440]=4.808e+003;
	luminance_ciel_bleus[1441]=4.816e+003;
	luminance_ciel_bleus[1442]=4.823e+003;
	luminance_ciel_bleus[1443]=4.831e+003;
	luminance_ciel_bleus[1444]=4.839e+003;
	luminance_ciel_bleus[1445]=4.846e+003;
	luminance_ciel_bleus[1446]=4.854e+003;
	luminance_ciel_bleus[1447]=4.862e+003;
	luminance_ciel_bleus[1448]=4.870e+003;
	luminance_ciel_bleus[1449]=4.878e+003;
	luminance_ciel_bleus[1450]=4.885e+003;
	luminance_ciel_bleus[1451]=4.893e+003;
	luminance_ciel_bleus[1452]=4.901e+003;
	luminance_ciel_bleus[1453]=4.909e+003;
	luminance_ciel_bleus[1454]=4.917e+003;
	luminance_ciel_bleus[1455]=4.925e+003;
	luminance_ciel_bleus[1456]=4.933e+003;
	luminance_ciel_bleus[1457]=4.941e+003;
	luminance_ciel_bleus[1458]=4.949e+003;
	luminance_ciel_bleus[1459]=4.957e+003;
	luminance_ciel_bleus[1460]=4.965e+003;
	luminance_ciel_bleus[1461]=4.973e+003;
	luminance_ciel_bleus[1462]=4.981e+003;
	luminance_ciel_bleus[1463]=4.989e+003;
	luminance_ciel_bleus[1464]=4.997e+003;
	luminance_ciel_bleus[1465]=5.005e+003;
	luminance_ciel_bleus[1466]=5.014e+003;
	luminance_ciel_bleus[1467]=5.022e+003;
	luminance_ciel_bleus[1468]=5.030e+003;
	luminance_ciel_bleus[1469]=5.038e+003;
	luminance_ciel_bleus[1470]=5.047e+003;
	luminance_ciel_bleus[1471]=5.055e+003;
	luminance_ciel_bleus[1472]=5.063e+003;
	luminance_ciel_bleus[1473]=5.072e+003;
	luminance_ciel_bleus[1474]=5.080e+003;
	luminance_ciel_bleus[1475]=5.089e+003;
	luminance_ciel_bleus[1476]=5.097e+003;
	luminance_ciel_bleus[1477]=5.106e+003;
	luminance_ciel_bleus[1478]=5.114e+003;
	luminance_ciel_bleus[1479]=5.123e+003;
	luminance_ciel_bleus[1480]=5.131e+003;
	luminance_ciel_bleus[1481]=5.140e+003;
	luminance_ciel_bleus[1482]=5.148e+003;
	luminance_ciel_bleus[1483]=5.157e+003;
	luminance_ciel_bleus[1484]=5.166e+003;
	luminance_ciel_bleus[1485]=5.174e+003;
	luminance_ciel_bleus[1486]=5.183e+003;
	luminance_ciel_bleus[1487]=5.192e+003;
	luminance_ciel_bleus[1488]=5.201e+003;
	luminance_ciel_bleus[1489]=5.210e+003;
	luminance_ciel_bleus[1490]=5.219e+003;
	luminance_ciel_bleus[1491]=5.228e+003;
	luminance_ciel_bleus[1492]=5.236e+003;
	luminance_ciel_bleus[1493]=5.245e+003;
	luminance_ciel_bleus[1494]=5.255e+003;
	luminance_ciel_bleus[1495]=5.264e+003;
	luminance_ciel_bleus[1496]=5.273e+003;
	luminance_ciel_bleus[1497]=5.282e+003;
	luminance_ciel_bleus[1498]=5.291e+003;
	luminance_ciel_bleus[1499]=5.300e+003;
	luminance_ciel_bleus[1500]=5.309e+003;
	luminance_ciel_bleus[1501]=5.319e+003;
	luminance_ciel_bleus[1502]=5.328e+003;
	luminance_ciel_bleus[1503]=5.337e+003;
	luminance_ciel_bleus[1504]=5.347e+003;
	luminance_ciel_bleus[1505]=5.356e+003;
	luminance_ciel_bleus[1506]=5.366e+003;
	luminance_ciel_bleus[1507]=5.375e+003;
	luminance_ciel_bleus[1508]=5.385e+003;
	luminance_ciel_bleus[1509]=5.394e+003;
	luminance_ciel_bleus[1510]=5.404e+003;
	luminance_ciel_bleus[1511]=5.414e+003;
	luminance_ciel_bleus[1512]=5.423e+003;
	luminance_ciel_bleus[1513]=5.433e+003;
	luminance_ciel_bleus[1514]=5.443e+003;
	luminance_ciel_bleus[1515]=5.453e+003;
	luminance_ciel_bleus[1516]=5.463e+003;
	luminance_ciel_bleus[1517]=5.473e+003;
	luminance_ciel_bleus[1518]=5.483e+003;
	luminance_ciel_bleus[1519]=5.493e+003;
	luminance_ciel_bleus[1520]=5.503e+003;
	luminance_ciel_bleus[1521]=5.513e+003;
	luminance_ciel_bleus[1522]=5.523e+003;
	luminance_ciel_bleus[1523]=5.533e+003;
	luminance_ciel_bleus[1524]=5.543e+003;
	luminance_ciel_bleus[1525]=5.554e+003;
	luminance_ciel_bleus[1526]=5.564e+003;
	luminance_ciel_bleus[1527]=5.575e+003;
	luminance_ciel_bleus[1528]=5.585e+003;
	luminance_ciel_bleus[1529]=5.595e+003;
	luminance_ciel_bleus[1530]=5.606e+003;
	luminance_ciel_bleus[1531]=5.617e+003;
	luminance_ciel_bleus[1532]=5.627e+003;
	luminance_ciel_bleus[1533]=5.638e+003;
	luminance_ciel_bleus[1534]=5.649e+003;
	luminance_ciel_bleus[1535]=5.660e+003;
	luminance_ciel_bleus[1536]=5.670e+003;
	luminance_ciel_bleus[1537]=5.681e+003;
	luminance_ciel_bleus[1538]=5.692e+003;
	luminance_ciel_bleus[1539]=5.703e+003;
	luminance_ciel_bleus[1540]=5.714e+003;
	luminance_ciel_bleus[1541]=5.726e+003;
	luminance_ciel_bleus[1542]=5.737e+003;
	luminance_ciel_bleus[1543]=5.748e+003;
	luminance_ciel_bleus[1544]=5.759e+003;
	luminance_ciel_bleus[1545]=5.771e+003;
	luminance_ciel_bleus[1546]=5.782e+003;
	luminance_ciel_bleus[1547]=5.794e+003;
	luminance_ciel_bleus[1548]=5.805e+003;
	luminance_ciel_bleus[1549]=5.817e+003;
	luminance_ciel_bleus[1550]=5.828e+003;
	luminance_ciel_bleus[1551]=5.840e+003;
	luminance_ciel_bleus[1552]=5.852e+003;
	luminance_ciel_bleus[1553]=5.864e+003;
	luminance_ciel_bleus[1554]=5.876e+003;
	luminance_ciel_bleus[1555]=5.888e+003;
	luminance_ciel_bleus[1556]=5.900e+003;
	luminance_ciel_bleus[1557]=5.912e+003;
	luminance_ciel_bleus[1558]=5.924e+003;
	luminance_ciel_bleus[1559]=5.936e+003;
	luminance_ciel_bleus[1560]=5.948e+003;
	luminance_ciel_bleus[1561]=5.961e+003;
	luminance_ciel_bleus[1562]=5.973e+003;
	luminance_ciel_bleus[1563]=5.986e+003;
	luminance_ciel_bleus[1564]=5.998e+003;
	luminance_ciel_bleus[1565]=6.011e+003;
	luminance_ciel_bleus[1566]=6.024e+003;
	luminance_ciel_bleus[1567]=6.036e+003;
	luminance_ciel_bleus[1568]=6.049e+003;
	luminance_ciel_bleus[1569]=6.062e+003;
	luminance_ciel_bleus[1570]=6.075e+003;
	luminance_ciel_bleus[1571]=6.088e+003;
	luminance_ciel_bleus[1572]=6.101e+003;
	luminance_ciel_bleus[1573]=6.114e+003;
	luminance_ciel_bleus[1574]=6.128e+003;
	luminance_ciel_bleus[1575]=6.141e+003;
	luminance_ciel_bleus[1576]=6.155e+003;
	luminance_ciel_bleus[1577]=6.168e+003;
	luminance_ciel_bleus[1578]=6.182e+003;
	luminance_ciel_bleus[1579]=6.195e+003;
	luminance_ciel_bleus[1580]=6.209e+003;
	luminance_ciel_bleus[1581]=6.223e+003;
	luminance_ciel_bleus[1582]=6.237e+003;
	luminance_ciel_bleus[1583]=6.251e+003;
	luminance_ciel_bleus[1584]=6.265e+003;
	luminance_ciel_bleus[1585]=6.279e+003;
	luminance_ciel_bleus[1586]=6.293e+003;
	luminance_ciel_bleus[1587]=6.307e+003;
	luminance_ciel_bleus[1588]=6.321e+003;
	luminance_ciel_bleus[1589]=6.336e+003;
	luminance_ciel_bleus[1590]=6.350e+003;
	luminance_ciel_bleus[1591]=6.364e+003;
	luminance_ciel_bleus[1592]=6.378e+003;
	luminance_ciel_bleus[1593]=6.393e+003;
	luminance_ciel_bleus[1594]=6.407e+003;
	luminance_ciel_bleus[1595]=6.421e+003;
	luminance_ciel_bleus[1596]=6.436e+003;
	luminance_ciel_bleus[1597]=6.450e+003;
	luminance_ciel_bleus[1598]=6.464e+003;
	luminance_ciel_bleus[1599]=6.478e+003;
	luminance_ciel_bleus[1600]=6.492e+003;
	luminance_ciel_bleus[1601]=6.506e+003;
	luminance_ciel_bleus[1602]=6.520e+003;
	luminance_ciel_bleus[1603]=6.534e+003;
	luminance_ciel_bleus[1604]=6.548e+003;
	luminance_ciel_bleus[1605]=6.562e+003;
	luminance_ciel_bleus[1606]=6.575e+003;
	luminance_ciel_bleus[1607]=6.589e+003;
	luminance_ciel_bleus[1608]=6.602e+003;
	luminance_ciel_bleus[1609]=6.616e+003;
	luminance_ciel_bleus[1610]=6.629e+003;
	luminance_ciel_bleus[1611]=6.642e+003;
	luminance_ciel_bleus[1612]=6.655e+003;
	luminance_ciel_bleus[1613]=6.668e+003;
	luminance_ciel_bleus[1614]=6.680e+003;
	luminance_ciel_bleus[1615]=6.693e+003;
	luminance_ciel_bleus[1616]=6.705e+003;
	luminance_ciel_bleus[1617]=6.717e+003;
	luminance_ciel_bleus[1618]=6.729e+003;
	luminance_ciel_bleus[1619]=6.741e+003;
	luminance_ciel_bleus[1620]=6.752e+003;
	luminance_ciel_bleus[1621]=6.764e+003;
	luminance_ciel_bleus[1622]=6.775e+003;
	luminance_ciel_bleus[1623]=6.787e+003;
	luminance_ciel_bleus[1624]=6.798e+003;
	luminance_ciel_bleus[1625]=6.809e+003;
	luminance_ciel_bleus[1626]=6.820e+003;
	luminance_ciel_bleus[1627]=6.832e+003;
	luminance_ciel_bleus[1628]=6.843e+003;
	luminance_ciel_bleus[1629]=6.854e+003;
	luminance_ciel_bleus[1630]=6.866e+003;
	luminance_ciel_bleus[1631]=6.877e+003;
	luminance_ciel_bleus[1632]=6.889e+003;
	luminance_ciel_bleus[1633]=6.901e+003;
	luminance_ciel_bleus[1634]=6.913e+003;
	luminance_ciel_bleus[1635]=6.925e+003;
	luminance_ciel_bleus[1636]=6.937e+003;
	luminance_ciel_bleus[1637]=6.950e+003;
	luminance_ciel_bleus[1638]=6.963e+003;
	luminance_ciel_bleus[1639]=6.976e+003;
	luminance_ciel_bleus[1640]=6.989e+003;
	luminance_ciel_bleus[1641]=7.002e+003;
	luminance_ciel_bleus[1642]=7.016e+003;
	luminance_ciel_bleus[1643]=7.030e+003;
	luminance_ciel_bleus[1644]=7.044e+003;
	luminance_ciel_bleus[1645]=7.058e+003;
	luminance_ciel_bleus[1646]=7.072e+003;
	luminance_ciel_bleus[1647]=7.086e+003;
	luminance_ciel_bleus[1648]=7.101e+003;
	luminance_ciel_bleus[1649]=7.115e+003;
	luminance_ciel_bleus[1650]=7.130e+003;
	luminance_ciel_bleus[1651]=7.145e+003;
	luminance_ciel_bleus[1652]=7.160e+003;
	luminance_ciel_bleus[1653]=7.175e+003;
	luminance_ciel_bleus[1654]=7.190e+003;
	luminance_ciel_bleus[1655]=7.205e+003;
	luminance_ciel_bleus[1656]=7.220e+003;
	luminance_ciel_bleus[1657]=7.235e+003;
	luminance_ciel_bleus[1658]=7.250e+003;
	luminance_ciel_bleus[1659]=7.265e+003;
	luminance_ciel_bleus[1660]=7.281e+003;
	luminance_ciel_bleus[1661]=7.296e+003;
	luminance_ciel_bleus[1662]=7.311e+003;
	luminance_ciel_bleus[1663]=7.326e+003;
	luminance_ciel_bleus[1664]=7.342e+003;
	luminance_ciel_bleus[1665]=7.357e+003;
	luminance_ciel_bleus[1666]=7.372e+003;
	luminance_ciel_bleus[1667]=7.388e+003;
	luminance_ciel_bleus[1668]=7.403e+003;
	luminance_ciel_bleus[1669]=7.419e+003;
	luminance_ciel_bleus[1670]=7.434e+003;
	luminance_ciel_bleus[1671]=7.449e+003;
	luminance_ciel_bleus[1672]=7.465e+003;
	luminance_ciel_bleus[1673]=7.480e+003;
	luminance_ciel_bleus[1674]=7.496e+003;
	luminance_ciel_bleus[1675]=7.511e+003;
	luminance_ciel_bleus[1676]=7.527e+003;
	luminance_ciel_bleus[1677]=7.542e+003;
	luminance_ciel_bleus[1678]=7.558e+003;
	luminance_ciel_bleus[1679]=7.574e+003;
	luminance_ciel_bleus[1680]=7.589e+003;
	luminance_ciel_bleus[1681]=7.605e+003;
	luminance_ciel_bleus[1682]=7.620e+003;
	luminance_ciel_bleus[1683]=7.636e+003;
	luminance_ciel_bleus[1684]=7.652e+003;
	luminance_ciel_bleus[1685]=7.667e+003;
	luminance_ciel_bleus[1686]=7.683e+003;
	luminance_ciel_bleus[1687]=7.699e+003;
	luminance_ciel_bleus[1688]=7.714e+003;
	luminance_ciel_bleus[1689]=7.730e+003;
	luminance_ciel_bleus[1690]=7.746e+003;
	luminance_ciel_bleus[1691]=7.762e+003;
	luminance_ciel_bleus[1692]=7.778e+003;
	luminance_ciel_bleus[1693]=7.793e+003;
	luminance_ciel_bleus[1694]=7.809e+003;
	luminance_ciel_bleus[1695]=7.825e+003;
	luminance_ciel_bleus[1696]=7.841e+003;
	luminance_ciel_bleus[1697]=7.857e+003;
	luminance_ciel_bleus[1698]=7.873e+003;
	luminance_ciel_bleus[1699]=7.889e+003;
	luminance_ciel_bleus[1700]=7.905e+003;
	luminance_ciel_bleus[1701]=7.921e+003;
	luminance_ciel_bleus[1702]=7.937e+003;
	luminance_ciel_bleus[1703]=7.953e+003;
	luminance_ciel_bleus[1704]=7.969e+003;
	luminance_ciel_bleus[1705]=7.985e+003;
	luminance_ciel_bleus[1706]=8.001e+003;
	luminance_ciel_bleus[1707]=8.017e+003;
	luminance_ciel_bleus[1708]=8.033e+003;
	luminance_ciel_bleus[1709]=8.049e+003;
	luminance_ciel_bleus[1710]=8.065e+003;
	luminance_ciel_bleus[1711]=8.082e+003;
	luminance_ciel_bleus[1712]=8.098e+003;
	luminance_ciel_bleus[1713]=8.114e+003;
	luminance_ciel_bleus[1714]=8.130e+003;
	luminance_ciel_bleus[1715]=8.146e+003;
	luminance_ciel_bleus[1716]=8.163e+003;
	luminance_ciel_bleus[1717]=8.179e+003;
	luminance_ciel_bleus[1718]=8.195e+003;
	luminance_ciel_bleus[1719]=8.212e+003;
	luminance_ciel_bleus[1720]=8.228e+003;
	luminance_ciel_bleus[1721]=8.244e+003;
	luminance_ciel_bleus[1722]=8.261e+003;
	luminance_ciel_bleus[1723]=8.277e+003;
	luminance_ciel_bleus[1724]=8.294e+003;
	luminance_ciel_bleus[1725]=8.310e+003;
	luminance_ciel_bleus[1726]=8.327e+003;
	luminance_ciel_bleus[1727]=8.343e+003;
	luminance_ciel_bleus[1728]=8.360e+003;
	luminance_ciel_bleus[1729]=8.376e+003;
	luminance_ciel_bleus[1730]=8.393e+003;
	luminance_ciel_bleus[1731]=8.410e+003;
	luminance_ciel_bleus[1732]=8.426e+003;
	luminance_ciel_bleus[1733]=8.443e+003;
	luminance_ciel_bleus[1734]=8.460e+003;
	luminance_ciel_bleus[1735]=8.476e+003;
	luminance_ciel_bleus[1736]=8.493e+003;
	luminance_ciel_bleus[1737]=8.510e+003;
	luminance_ciel_bleus[1738]=8.526e+003;
	luminance_ciel_bleus[1739]=8.543e+003;
	luminance_ciel_bleus[1740]=8.560e+003;
	luminance_ciel_bleus[1741]=8.577e+003;
	luminance_ciel_bleus[1742]=8.594e+003;
	luminance_ciel_bleus[1743]=8.611e+003;
	luminance_ciel_bleus[1744]=8.628e+003;
	luminance_ciel_bleus[1745]=8.645e+003;
	luminance_ciel_bleus[1746]=8.662e+003;
	luminance_ciel_bleus[1747]=8.679e+003;
	luminance_ciel_bleus[1748]=8.696e+003;
	luminance_ciel_bleus[1749]=8.713e+003;
	luminance_ciel_bleus[1750]=8.730e+003;
	luminance_ciel_bleus[1751]=8.747e+003;
	luminance_ciel_bleus[1752]=8.764e+003;
	luminance_ciel_bleus[1753]=8.781e+003;
	luminance_ciel_bleus[1754]=8.798e+003;
	luminance_ciel_bleus[1755]=8.815e+003;
	luminance_ciel_bleus[1756]=8.833e+003;
	luminance_ciel_bleus[1757]=8.850e+003;
	luminance_ciel_bleus[1758]=8.867e+003;
	luminance_ciel_bleus[1759]=8.885e+003;
	luminance_ciel_bleus[1760]=8.902e+003;
	luminance_ciel_bleus[1761]=8.919e+003;
	luminance_ciel_bleus[1762]=8.937e+003;
	luminance_ciel_bleus[1763]=8.954e+003;
	luminance_ciel_bleus[1764]=8.972e+003;
	luminance_ciel_bleus[1765]=8.989e+003;
	luminance_ciel_bleus[1766]=9.007e+003;
	luminance_ciel_bleus[1767]=9.024e+003;
	luminance_ciel_bleus[1768]=9.042e+003;
	luminance_ciel_bleus[1769]=9.059e+003;
	luminance_ciel_bleus[1770]=9.077e+003;
	luminance_ciel_bleus[1771]=9.094e+003;
	luminance_ciel_bleus[1772]=9.112e+003;
	luminance_ciel_bleus[1773]=9.130e+003;
	luminance_ciel_bleus[1774]=9.148e+003;
	luminance_ciel_bleus[1775]=9.165e+003;
	luminance_ciel_bleus[1776]=9.183e+003;
	luminance_ciel_bleus[1777]=9.201e+003;
	luminance_ciel_bleus[1778]=9.219e+003;
	luminance_ciel_bleus[1779]=9.237e+003;
	luminance_ciel_bleus[1780]=9.255e+003;
	luminance_ciel_bleus[1781]=9.273e+003;
	luminance_ciel_bleus[1782]=9.291e+003;
	luminance_ciel_bleus[1783]=9.309e+003;
	luminance_ciel_bleus[1784]=9.327e+003;
	luminance_ciel_bleus[1785]=9.345e+003;
	luminance_ciel_bleus[1786]=9.363e+003;
	luminance_ciel_bleus[1787]=9.381e+003;
	luminance_ciel_bleus[1788]=9.399e+003;
	luminance_ciel_bleus[1789]=9.417e+003;
	luminance_ciel_bleus[1790]=9.435e+003;
	luminance_ciel_bleus[1791]=9.454e+003;
	luminance_ciel_bleus[1792]=9.472e+003;
	luminance_ciel_bleus[1793]=9.490e+003;
	luminance_ciel_bleus[1794]=9.509e+003;
	luminance_ciel_bleus[1795]=9.527e+003;
	luminance_ciel_bleus[1796]=9.546e+003;
	luminance_ciel_bleus[1797]=9.564e+003;
	luminance_ciel_bleus[1798]=9.583e+003;
	luminance_ciel_bleus[1799]=9.601e+003;
	luminance_ciel_bleus[1800]=9.620e+003;
	return 0;
}

/*****************************************************************************/
/*****************************************************************************/
/* Compute the vector of local conditions for an Object.                     */
/* Outputs : objectlocal                                                     */
/* elevation is corrected by refraction but not ra,dec,ha,az                 */
/*****************************************************************************/
int mc_scheduler_objectlocal1(double longmpc, double rhocosphip, double rhosinphip, mc_OBJECTDESCR *objectdescr,int njd, mc_SUNMOON *sunmoon,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadecint,mc_OBJECTLOCAL **pobjectlocal,mc_OBJECTLOCALRANGES *objectlocalranges) {
	double latitude,altitude;
	int njdm;
	double *dummy1s=NULL,*dummy2s=NULL,*dummy3s=NULL,*dummy4s=NULL,*dummy5s=NULL,*dummy6s=NULL,*dummy7s=NULL,*dummy8s=NULL,*dummy9s=NULL;
	double *dummy01s=NULL,*dummy02s=NULL;
	int kjd,sousech,k,kr;
	mc_OBJECTLOCAL *objectlocal=NULL;
	double latrad;
	double *luminance_ciel_bleus=NULL; // -90 -89.9 -89.8 ... +89.9 +90.0
	double maxelev=0,da,elev,drangeindex;
	int started;

	// --- cd/m2
	luminance_ciel_bleus=(double*)calloc(1801,sizeof(double));
	mc_fill_luminance_ciel_bleus(luminance_ciel_bleus);

	// --- initialize
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	latrad=latitude*(DR);

	// --- prepare sur-ech vectors
	if (pobjectlocal!=NULL) {
		objectlocal=(mc_OBJECTLOCAL*)calloc(njd+1,sizeof(mc_OBJECTLOCAL));
		*pobjectlocal=objectlocal;
		if (objectlocal==NULL) { free(luminance_ciel_bleus); return 1; }
	}

	// --- prepare sous-ech vectors
	njdm=24*60+1;
	sousech=(int)floor(1.*njd/njdm);
	if (sousech<1) { sousech=1; }
	njdm=(int)ceil(1.*njd/sousech);
	dummy1s=(double*)calloc(njdm+1,sizeof(double)); // jd sous-ech
	dummy2s=(double*)calloc(njdm+1,sizeof(double)); // ha sous-ech
	dummy3s=(double*)calloc(njdm+1,sizeof(double)); // elev sous-ech
	dummy4s=(double*)calloc(njdm+1,sizeof(double)); // az sous-ech
	dummy5s=(double*)calloc(njdm+1,sizeof(double)); // dec sous-ech
	dummy6s=(double*)calloc(njdm+1,sizeof(double)); // moon_dist sous-ech
	dummy7s=(double*)calloc(njdm+1,sizeof(double)); // sun_dist sous-ech
	dummy8s=(double*)calloc(njdm+1,sizeof(double)); // skylevel sous-ech
	dummy9s=(double*)calloc(njdm+1,sizeof(double)); // ra sous-ech
	if ((dummy1s==NULL)||(dummy2s==NULL)||(dummy3s==NULL)||(dummy4s==NULL)||(dummy5s==NULL)||(dummy6s==NULL)||(dummy7s==NULL)||(dummy8s==NULL)||(dummy9s==NULL)) {
		free(luminance_ciel_bleus);
		if (objectlocal!=NULL) { free(objectlocal); }
		if (dummy1s!=NULL) { free(dummy1s); }
		if (dummy2s!=NULL) { free(dummy2s); }
		if (dummy3s!=NULL) { free(dummy3s); }
		if (dummy4s!=NULL) { free(dummy4s); }
		if (dummy5s!=NULL) { free(dummy5s); }
		if (dummy6s!=NULL) { free(dummy6s); }
		if (dummy7s!=NULL) { free(dummy7s); }
		if (dummy8s!=NULL) { free(dummy8s); }
		if (dummy9s!=NULL) { free(dummy9s); }
		return 1;
	}
	for (kjd=0;kjd<=njdm;kjd++) {
		k=kjd*sousech; if (k>njd) { k=njd; }
		mc_scheduler_local1(k,longmpc,rhocosphip,rhosinphip,latrad,luminance_ciel_bleus,objectdescr,njd,sunmoon,horizon_altaz,horizon_hadecint,&dummy1s[kjd],&dummy2s[kjd],&dummy3s[kjd],&dummy4s[kjd],&dummy5s[kjd],&dummy6s[kjd],&dummy7s[kjd],&dummy8s[kjd],&dummy9s[kjd]);
		if (kjd>0) {
			da=dummy2s[kjd]-dummy2s[kjd-1];
			if (da<-180) { dummy2s[kjd]+=360.; }
			if (da>180) { dummy2s[kjd]-=360.; }
			da=dummy9s[kjd]-dummy9s[kjd-1];
			if (da<-180) { dummy9s[kjd]+=360.; }
			if (da>180) { dummy9s[kjd]-=360.; }
			da=dummy4s[kjd]-dummy4s[kjd-1];
			if (da<-180) { dummy4s[kjd]+=360.; }
			if (da>180) { dummy4s[kjd]-=360.; }
		}
	}

	if (objectlocalranges!=NULL) {
		// --- remplissage des ranges
		drangeindex=(objectdescr->const_jd2-objectdescr->const_jd1)*njdm;
		for (kjd=1,kr=0,started=0;(kjd<=njdm)||(kr==NB_OBJECTLOCALRANGES_MAX-1);kjd++) {
			elev=dummy3s[kjd];
			if (drangeindex<=2) {
				if ((dummy8s[kjd]>=objectdescr->const_skylightlevel)&&(dummy1s[kjd]>=objectdescr->const_jd1)&&(started==0)) {
					// --- range start
					maxelev=elev;
					objectlocalranges->jd1[kr]=objectdescr->const_jd1;
					objectlocalranges->jd2[kr]=objectdescr->const_jd2;
					objectlocalranges->jdelevmax[kr]=objectdescr->const_jd1;
					objectlocalranges->elev1[kr]=maxelev;
					objectlocalranges->elev2[kr]=maxelev;
					objectlocalranges->elevmax[kr]=maxelev;
					kr++;
					started=1;
				}
			} else {
				if ((dummy8s[kjd]>=objectdescr->const_skylightlevel)&&(dummy1s[kjd]>=objectdescr->const_jd1)&&(dummy1s[kjd]<=objectdescr->const_jd2)&&(started==0)) {
					// --- range start
					maxelev=elev;
					objectlocalranges->jd1[kr]=dummy1s[kjd];
					objectlocalranges->jd2[kr]=dummy1s[kjd];
					objectlocalranges->jdelevmax[kr]=dummy1s[kjd];
					objectlocalranges->elev1[kr]=maxelev;
					objectlocalranges->elev2[kr]=maxelev;
					objectlocalranges->elevmax[kr]=maxelev;
					started=1;
				} else if ((dummy8s[kjd]>=objectdescr->const_skylightlevel)&&(started==1)) {
					// --- range in
					if (dummy3s[kjd]>maxelev) {
						maxelev=elev;
						objectlocalranges->jdelevmax[kr]=dummy1s[kjd];
						objectlocalranges->elevmax[kr]=maxelev;
					}
				}
				if (((dummy8s[kjd]<objectdescr->const_skylightlevel)||(dummy1s[kjd-1]>=objectdescr->const_jd2))&&(started==1)) {
					// --- range end
					objectlocalranges->jd2[kr]=dummy1s[kjd-1];
					objectlocalranges->elev2[kr]=dummy3s[kjd-1];
					if (objectlocalranges->jdelevmax[kr]>objectlocalranges->jd2[kr]) {
						objectlocalranges->jdelevmax[kr]=objectlocalranges->jd1[kr];
					}
					kr++;
					started=0;
				}
			}
		}
		objectlocalranges->nbrange=kr;
	}

	if (pobjectlocal!=NULL) {
		// --- interpolations
		dummy01s=(double*)calloc(njd+2,sizeof(double)); // jd
		dummy02s=(double*)calloc(njd+2,sizeof(double));
		if ((dummy01s==NULL)||(dummy02s==NULL)) {
			free(luminance_ciel_bleus);
			free(objectlocal);
			free(dummy1s);
			free(dummy2s);
			free(dummy3s);
			free(dummy4s);
			free(dummy5s);
			free(dummy6s);
			free(dummy7s);
			free(dummy8s);
			free(dummy9s);
			if (dummy01s!=NULL) { free(dummy01s); }
			if (dummy02s!=NULL) { free(dummy02s); }
			return 1;
		}
		for (kjd=0;kjd<=njd;kjd++) {
			dummy01s[kjd+1]=sunmoon[kjd].jd;
		}
		mc_interplin2(0,njdm,dummy1s,dummy2s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
			objectlocal[kjd].ha=dummy02s[kjd+1];
		}
		mc_interplin2(0,njdm,dummy1s,dummy3s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			objectlocal[kjd].elev=dummy02s[kjd+1];
		}
		mc_interplin2(0,njdm,dummy1s,dummy4s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
			objectlocal[kjd].az=dummy02s[kjd+1];
		}
		mc_interplin2(0,njdm,dummy1s,dummy5s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
			objectlocal[kjd].dec=dummy02s[kjd+1];
		}
		mc_interplin2(0,njdm,dummy1s,dummy6s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			objectlocal[kjd].moon_dist=dummy02s[kjd+1];
		}
		mc_interplin2(0,njdm,dummy1s,dummy7s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			objectlocal[kjd].sun_dist=dummy02s[kjd+1];
		}
		mc_interplin2(0,njdm,dummy1s,dummy8s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			objectlocal[kjd].skylevel=dummy02s[kjd+1];
		}
		mc_interplin2(0,njdm,dummy1s,dummy9s,dummy1s,0.5,njd+1,dummy01s,dummy02s);
		for (kjd=0;kjd<=njd;kjd++) {
			if (dummy02s[kjd+1]>360) { dummy02s[kjd+1]-=360.; }
			objectlocal[kjd].ra=dummy02s[kjd+1];
		}
		for (kjd=0;kjd<=njd;kjd++) {
			objectlocal[kjd].flagobs=1;
			if (objectlocal[kjd].skylevel<0) {
				objectlocal[kjd].flagobs=0;
			}
		}
		free(dummy01s);
		free(dummy02s);
	}

	free(luminance_ciel_bleus);
	free(dummy1s);
	free(dummy2s);
	free(dummy3s);
	free(dummy4s);
	free(dummy5s);
	free(dummy6s);
	free(dummy7s);
	free(dummy8s);
	free(dummy9s);
	return 0;
}

/************************************************************************/
/************************************************************************/
/************************************************************************/
int mc_obsconditions1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadec,int nobj,mc_OBJECTDESCR *objectdescr,double djd,char *fullfilename) {

	double jd_prevmidsun,jd_nextmidsun;
	int njd,kjd,err;
	mc_SUNMOON *sunmoon=NULL;
	mc_OBJECTLOCAL *objectlocal=NULL;
	FILE *fid;

	// --- compute dates of observing range (=the start-end of the schedule)
	mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

	// --- compute mc_SUNMOON vector for the observing range.
	mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

	// --- compute mc_OBJECTLOCAL vector for the observing range.
	mc_sheduler_corccoords(&objectdescr[0]);
	err=mc_scheduler_objectlocal1(longmpc,rhocosphip,rhosinphip,&objectdescr[0],njd,sunmoon,horizon_altaz,horizon_hadec,&objectlocal,NULL);
	if (err>0) {
		free(sunmoon);
		if (objectlocal!=NULL) { free(objectlocal); }
		return 1;
	}

	// --- output file
	fid=fopen(fullfilename,"wt");
	if (fid!=NULL) {
		for (kjd=0;kjd<njd;kjd++) {
			fprintf(fid,"%.5f %6.2f  %6.2f %+6.2f  %6.2f %+6.2f %6.2f  %6.2f %+6.2f %6.2f %6.2f %+6.2f  %+6.2f %6.2f %6.2f\n",sunmoon[kjd].jd,sunmoon[kjd].lst, sunmoon[kjd].sun_az,sunmoon[kjd].sun_elev, sunmoon[kjd].moon_az,sunmoon[kjd].moon_elev,sunmoon[kjd].moon_phase, objectlocal[kjd].az,objectlocal[kjd].elev,objectlocal[kjd].ha,objectlocal[kjd].ra,objectlocal[kjd].dec,objectlocal[kjd].skylevel,objectlocal[kjd].sun_dist,objectlocal[kjd].moon_dist);
		}
		fclose(fid);
	} else {
		return 2;
	}

	free(sunmoon);
	free(objectlocal);
   return 0;
}

/************************************************************************/
/************************************************************************/
/************************************************************************/
int mc_scheduler1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,mc_HORIZON_ALTAZ *horizon_altaz,mc_HORIZON_HADEC *horizon_hadec,int nobj,mc_OBJECTDESCR *objectdescr,int output_type, char *output_file, char *log_file) {

	double jd_prevmidsun,jd_nextmidsun,djd,racat,deccat;
	int njd,ko,nobjloc,kjd,flag,kp,kpp,kppp,k,kpl,npl,np,ku,k1,k2,k3,kk,kd,kk1,kk2,kr;
	mc_SUNMOON *sunmoon=NULL;
	mc_OBJECTLOCAL *objectlocal0=NULL,*objectlocal=NULL,**objectlocals=NULL;
	mc_PLANI **planis=NULL;
	double *priority_total=NULL,*same_priority=NULL,*dummys=NULL;
	int *kpriority_total=NULL,*ksame_priority=NULL,*kdummys=NULL;
	double current_priority,id0,id,jd0,jd1,jd2,jd00;
	int *objectlinks=NULL,nu,npl0,mode_quota,err;
	mc_USERS *users;
	double angle,duration,d1,d2,d12,total_duration_sequenced,d12b,dd;
	double jdobsmin,jdobsmax,jdseq_prev,jdseq_next;
	double jdobsminmin,jdobsmaxmax,total_duration_obsobs;
	double ha1,ha2,dec1,dec2;
	long clk_tck = CLOCKS_PER_SEC;
   clock_t clock0;
	double dt;
	double compute_mode=1; // =0 to use mc_OBJECTLOCAL. =1 to use mc_OBJECTLOCALRANGES
	int print_mode=0; // =0 no debug files  =1 debug files
	mc_OBJECTLOCALRANGES *objectlocalranges=NULL;
	double *luminance_ciel_bleus=NULL;
	double jd_loc,ha_loc,elev_loc,az_loc,dec_loc,moon_dist_loc,sun_dist_loc,brillance_totale_loc,ra_loc;
	double latitude,altitude,latrad,j1,j2,jdseq_prev0,jdseq_next0,dd0,dd1,durationtot;
	double *jdsets=NULL;
	int *kjdsets=NULL,user,user0,prio_order,k4;
	FILE *fid=NULL,*fidlog=NULL;
	char s[300];

	// --- open log file
	if (log_file!=NULL) {
		fidlog=fopen(log_file,"wt");
	}

	// --- compute dates of observing range (=the start-end of the schedule)
	mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);
	if (fidlog!=NULL) {
		fprintf(fidlog,"=== Day %f\n",jd_now);
		fprintf(fidlog," jd_prevmidsun=%f jd_nextmidsun=%f\n",jd_prevmidsun,jd_nextmidsun);
	}

	// --- compute mc_SUNMOON vector for the observing range.
	djd=5./86400.;
	mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

	// --- brillance du ciel
	luminance_ciel_bleus=(double*)calloc(1801,sizeof(double));
	mc_fill_luminance_ciel_bleus(luminance_ciel_bleus);

	// --- variables de site
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	latrad=latitude*(DR);

	// --- mc_OBJECTLOCAL vector for temporary computations
	objectlocal0=(mc_OBJECTLOCAL*)malloc(njd*sizeof(mc_OBJECTLOCAL));
	objectlinks=(int*)calloc(nobj,sizeof(int));

	// --- compute mc_OBJECTLOCAL vector for the observing range.
	// --- complete the mc_OBJECTLOCAL.flagobs vector
	// --- complete the objectdescr[ko].private_elevmaxi;
	// --- complete the objectdescr[ko].private_jdelevmaxi;
	if (compute_mode==0) {
		objectlocals=(mc_OBJECTLOCAL**)malloc(nobj*sizeof(mc_OBJECTLOCAL*));
	}
	if (compute_mode==1) {
		objectlocalranges=(mc_OBJECTLOCALRANGES*)malloc(nobj*sizeof(mc_OBJECTLOCALRANGES));
	}
	nobjloc=0;
	jdobsmin=jd_nextmidsun;
	jdobsmax=jd_prevmidsun;
	jdobsminmin=0.5*(jd_nextmidsun+jd_prevmidsun)-0.01*(jd_nextmidsun-jd_prevmidsun);
	jdobsmaxmax=0.5*(jd_nextmidsun+jd_prevmidsun)+0.01*(jd_nextmidsun-jd_prevmidsun);
	if (fidlog!=NULL) {
		fprintf(fidlog,"=== First loop to compute observing conditions of %d sequences:\n",nobj);
	}
	for (ko=0;ko<nobj;ko++) {
		objectdescr[ko].status_plani=STATUS_PLANI_NOT_PLANIFIED;
		//sprintf(s,"%d / %d",ko,nobj);
		//strncpy(objectdescr[ko].comments,s,OBJECTDESCR_MAXCOM-1);
		objectdescr[ko].nb_plani=0;
		if (objectdescr[ko].const_jd2<jd_prevmidsun) {
			// -- la fin des observations est demandée avant le début du mer2mer
			objectdescr[ko].status_plani=STATUS_PLANI_END_OBS_BEFORE_RANGE;
			sprintf(s,"jd2 = %f < %f",objectdescr[ko].const_jd2,jd_prevmidsun);
			if (fidlog!=NULL) {
				fprintf(fidlog," Sequence %d: not observable (%s) %s\n",ko,s,objectdescr[ko].comments);
			}
			strncpy(objectdescr[ko].comments,s,OBJECTDESCR_MAXCOM-1);
			continue;
		} else if (objectdescr[ko].const_jd1>jd_nextmidsun) {
			// -- le debut des observations est demandée apres la fin du mer2mer
			objectdescr[ko].status_plani=STATUS_PLANI_START_OBS_AFTER_RANGE;
			sprintf(s,"jd1 = %f > %f",objectdescr[ko].const_jd1,jd_nextmidsun);
			if (fidlog!=NULL) {
				fprintf(fidlog," Sequence %d: not observable (%s) %s\n",ko,s,objectdescr[ko].comments);
			}
			strncpy(objectdescr[ko].comments,s,OBJECTDESCR_MAXCOM-1);
			continue;
		}
		mc_sheduler_corccoords(&objectdescr[ko]);
		clock0 = clock();
		err=0;
		if (compute_mode==0) {
			objectlocals[nobjloc]=NULL;
			err=mc_scheduler_objectlocal1(longmpc,rhocosphip,rhosinphip,&objectdescr[ko],njd,sunmoon,horizon_altaz,horizon_hadec,&objectlocals[nobjloc],NULL);
			if (err>0) {
				for (ko=0;ko<nobjloc-1;ko++) {
					free(objectlocals[ko]);
				}
				free(objectlocals);
			}
		}
		if (compute_mode==1) {
			err=mc_scheduler_objectlocal1(longmpc,rhocosphip,rhosinphip,&objectdescr[ko],njd,sunmoon,horizon_altaz,horizon_hadec,NULL,&objectlocalranges[nobjloc]);
		}
		if (err>0) {
			free(sunmoon);
			free(objectlocal0);
			free(objectlinks);
			free(luminance_ciel_bleus);
			return 1;
		}
		dt=(double)(clock()-clock0)/(double)clk_tck;
		if (compute_mode==0) {
			flag=0;
			for (kjd=0;kjd<=njd;kjd++) {
				if (objectlocals[nobjloc][kjd].skylevel<objectdescr[ko].const_skylightlevel) {
					objectlocals[nobjloc][kjd].flagobs=0;
					flag++;
				}
			}
			if (flag>=njd) {
				// -- l'astre nest jamais observable dans le mer2mer
				objectdescr[ko].status_plani=STATUS_PLANI_NEVER_VISIBLE_IN_RANGE;
				free(objectlocals[nobjloc]);
				continue;
			}
		}
		if (compute_mode==1) {
			if (objectlocalranges[nobjloc].nbrange==0) {
				// -- l'astre nest jamais observable dans le mer2mer
				objectdescr[ko].status_plani=STATUS_PLANI_NEVER_VISIBLE_IN_RANGE;
				sprintf(s,"elevmax = %f",objectdescr[ko].private_elevmaxi);
				if (fidlog!=NULL) {
					fprintf(fidlog," Sequence %d: not observable in this mer2mer. %s\n",ko,objectdescr[ko].comments);
				}
				strncpy(objectdescr[ko].comments,s,OBJECTDESCR_MAXCOM-1);
				continue;
			}
		}
		objectdescr[ko].private_elevmaxi=-90.;
		objectdescr[ko].private_jdelevmaxi=0.;
		jdobsmin=jd_nextmidsun;
		jdobsmax=jd_prevmidsun;
		if (compute_mode==0) {
			for (kjd=0;kjd<=njd;kjd++) {
				if (objectlocals[nobjloc][kjd].flagobs==1) {
					if (sunmoon[kjd].jd<jdobsmin) {
						jdobsmin=sunmoon[kjd].jd;
					}
					if (sunmoon[kjd].jd>jdobsmax) {
						jdobsmax=sunmoon[kjd].jd;
					}
					if (objectlocals[nobjloc][kjd].elev>objectdescr[ko].private_elevmaxi) {
						objectdescr[ko].private_elevmaxi=objectlocals[nobjloc][kjd].elev;
						objectdescr[ko].private_jdelevmaxi=sunmoon[kjd].jd;
					}
					if (sunmoon[kjd].jd<jdobsminmin) {
						jdobsminmin=sunmoon[kjd].jd;
					}
					if (sunmoon[kjd].jd>jdobsmaxmax) {
						jdobsmaxmax=sunmoon[kjd].jd;
					}
				}
			}
		}
		if (compute_mode==1) {
			for (kr=0;kr<objectlocalranges[nobjloc].nbrange;kr++) {
				if (objectlocalranges[nobjloc].jd1[kr]<jdobsmin) {
					jdobsmin=objectlocalranges[nobjloc].jd1[kr];
				}
				if (objectlocalranges[nobjloc].jd2[kr]>jdobsmax) {
					jdobsmax=objectlocalranges[nobjloc].jd2[kr];
				}
				if (objectlocalranges[nobjloc].elevmax[kr]>objectdescr[ko].private_elevmaxi) {
					objectdescr[ko].private_elevmaxi=objectlocalranges[nobjloc].elevmax[kr];
					objectdescr[ko].private_jdelevmaxi=objectlocalranges[nobjloc].jdelevmax[kr];
				}
				if (objectlocalranges[nobjloc].jd1[kr]<jdobsminmin) {
					jdobsminmin=objectlocalranges[nobjloc].jd1[kr];
				}
				if (objectlocalranges[nobjloc].jd2[kr]>jdobsmaxmax) {
					jdobsmaxmax=objectlocalranges[nobjloc].jd2[kr];
				}
			}
			if (fidlog!=NULL) {
				fprintf(fidlog," Sequence %d: observable %.0f times (jdobsmin=%f jdobsmax=%f elevmax=%f jdelevmax=%f) %s\n",ko,objectlocalranges[nobjloc].nbrange,jdobsmin,jdobsmax,objectdescr[ko].private_elevmaxi,objectdescr[ko].private_jdelevmaxi,objectdescr[ko].comments);
			}
		}
		objectlinks[nobjloc]=ko;
		nobjloc++;
	}
	total_duration_obsobs=(jdobsmaxmax-jdobsminmin);
	total_duration_sequenced=0.;
	if (fidlog!=NULL) {
		fprintf(fidlog,"=== Total sequence limits\n");
		fprintf(fidlog," jdobsminmin=%f jdobsmaxmax=%f\n",jdobsminmin,jdobsmaxmax);
	}

	// ---
	if (nobjloc==0) {
		if (fidlog!=NULL) {
			fprintf(fidlog,"=== Free memory");
		}
		if (sunmoon!=NULL) free(sunmoon);
		if (compute_mode==0) {
			if (objectlocals!=NULL) free(objectlocals);
		} 
		if (compute_mode==1) {
			if (objectlocal!=NULL) free(objectlocal);
		} 
		if (objectlocal0!=NULL) free(objectlocal0);
		if (objectlinks!=NULL) free(objectlinks);
		if (luminance_ciel_bleus!=NULL) free(luminance_ciel_bleus);
		if (fidlog!=NULL) {
			fclose(fidlog);
		}
		return 2;
	}

	// --- vecteur des users et des quotas
	if (fidlog!=NULL) {
		fprintf(fidlog,"=== Compute users\n");
	}
	dummys=(double*)calloc(nobjloc,sizeof(double));
	kdummys=(int*)calloc(nobjloc,sizeof(int));
	for (ko=0;ko<nobjloc;ko++) {
		dummys[ko]=objectdescr[objectlinks[ko]].user;
		kdummys[ko]=ko;
	}
	mc_quicksort_double(dummys,0,nobjloc-1,kdummys);
	id0=dummys[0];
	for (ko=1,nu=1;ko<nobjloc;ko++) {
		id=dummys[ko];
		if (id!=id0) {
			nu++;
			id0=id;
		}
	}
	users=(mc_USERS*)malloc(nu*sizeof(mc_USERS));
	id0=dummys[0];
	users[0].iduser=(int)dummys[0];
	users[0].percent_quota_authorized=objectdescr[objectlinks[kdummys[0]]].user_quota;
	users[0].percent_quota_used=0.;
	users[0].duration_total_used=0.;
	nu=0;
	if (fidlog!=NULL) {
		fprintf(fidlog," %d : user_id=%d quota=%f\n",nu,users[nu].iduser,users[nu].percent_quota_authorized);
	}
	for (ko=1,nu=1;ko<nobjloc;ko++) {
		id=dummys[ko];
		if (id!=id0) {
			users[nu].iduser=(int)dummys[ko];
			users[nu].percent_quota_authorized=objectdescr[objectlinks[kdummys[ko]]].user_quota;
			users[nu].percent_quota_used=0.;
			users[nu].duration_total_used=0.;
			if (fidlog!=NULL) {
				fprintf(fidlog," %d : user_id=%d quota=%f\n",nu,users[nu].iduser,users[nu].percent_quota_authorized);
			}
			nu++;
			id0=id;
		}
	}
	if (print_mode==1) {
		mc_printusers(nu,users);
	}

	// --- vecteur des priorites trie dans l'ordre croissant
	if (fidlog!=NULL) {
		fprintf(fidlog,"=== Sort priorities\n");
	}
	priority_total=(double*)calloc(nobjloc,sizeof(double));
	kpriority_total=(int*)calloc(nobjloc,sizeof(int));
	for (ko=0;ko<nobjloc;ko++) {
		priority_total[ko]=objectdescr[objectlinks[ko]].user_priority;
		kpriority_total[ko]=ko;
	}
	mc_quicksort_double(priority_total,0,nobjloc-1,kpriority_total);
	same_priority=(double*)calloc(nobjloc,sizeof(double));
	ksame_priority=(int*)calloc(nobjloc,sizeof(int));

	// --- vecteur des couchers pour trier les priorites egales
	jdsets=(double*)calloc(nobjloc,sizeof(double));
	kjdsets=(int*)calloc(nobjloc,sizeof(int));

	// --- initialise les vecteurs de la planification
	planis=(mc_PLANI**)malloc(2*sizeof(mc_PLANI*));
	for (kpl=0;kpl<2;kpl++) {
		planis[kpl]=(mc_PLANI*)malloc(1*sizeof(mc_PLANI));
	}
	npl0=npl=0;

	if (fidlog!=NULL) {
		fprintf(fidlog,"====================================================================\n");
		fprintf(fidlog,"=== Enter in the great loop for %d sequences potentially observable:\n",nobjloc);
		fprintf(fidlog,"====================================================================\n");
	}
	clock0 = clock();
	// --- planification in-quotas
	// ko : index in objectlocal
	// kd : index in objectdescr
	// npl : nombre de scenes planifiees
	// mode_quota : 1=in quotas 2=hors quotas 3=duplique dans les trous
	mode_quota=1;
	ko=nobjloc-1;
	prio_order=0;
	while (1==1) {
		current_priority=priority_total[ko];
		// --- on cherche toutes les sequences de meme priorite
		for (k=ko,np=0;k>=0;k--,np++) {
			if (priority_total[k]<current_priority) {
				break;
			} else {
				ksame_priority[np]=kpriority_total[k];
			}
		}
		np--;
		// --- on trie les sequences de meme priorite en ordre de coucher
		for (kp=0;kp<=np;kp++) {
			kk=ksame_priority[kp]; // kk index in objectlocal ou objectlocalranges
			kd=objectlinks[kk]; ///// kd index in objectdescr
			kr=(int)objectlocalranges[kk].nbrange-1; // indice du dernier coucher
			jdsets[kp]=objectlocalranges[kk].jd2[kr];
			kjdsets[kp]=kp;
		}
		mc_quicksort_double(jdsets,0,np,kjdsets);
		// --- on trie les sequences de meme priorite pour intercaler les users
		for (kp=0;kp<=np-1;kp++) {
			kk=ksame_priority[kjdsets[kp]]; // kk index in objectlocal ou objectlocalranges
			kd=objectlinks[kk]; ///// kd index in objectdescr
			user0=objectdescr[kd].user;
			for (kpp=kp+1;kpp<=np;kpp++) {
				kk=ksame_priority[kjdsets[kp]]; // kk index in objectlocal ou objectlocalranges
				kd=objectlinks[kk]; ///// kd index in objectdescr
				user=objectdescr[kd].user;
				if (user!=user0) {
					// --- on echange kpp<->kp+1
					kppp=kjdsets[kpp];
					kjdsets[kpp]=kjdsets[kp+1];
					kjdsets[kp+1]=kppp;
				}
			}
		}
		if (fidlog!=NULL) {
			fprintf(fidlog," ====================================================================\n");
			fprintf(fidlog," --- mode_quota=%d current_priority=%f np=%d (=nombre de sequences concurrentes)\n",mode_quota,current_priority,np);
			fprintf(fidlog," ====================================================================\n");
		}
		// --- on place les kp=[0..np] sequences de meme priorite dans la planif
		for (kp=0;kp<=np;kp++) {
			kk=ksame_priority[kjdsets[kp]]; // kk index in objectlocal ou objectlocalranges
			kd=objectlinks[kk]; ///// kd index in objectdescr
			prio_order++;
			if (objectdescr[kd].status_plani==STATUS_PLANI_NOT_PLANIFIED) {
				sprintf(s,"prio=%.1f (%d / %d) prio_order=%d",current_priority,kp,np,prio_order);
				strncpy(objectdescr[kd].comments,s,OBJECTDESCR_MAXCOM-1);
			}
			// --- calcule les quotas absolus utilises 
			if (total_duration_sequenced>0) {
				for (ku=0;ku<nu;ku++) {
					users[ku].percent_quota_used=(users[ku].duration_total_used/total_duration_obsobs*100);
				}
			}
			// --- recherche l'indice ku du user dans mc_USERS
			for (ku=0;ku<nu;ku++) {
				if (users[ku].iduser==objectdescr[kd].user) {
					break;
				}
			}
			if (fidlog!=NULL) {
				fprintf(fidlog,"  ---- BEGIN SEQUENCE %4d/%4d user=%3d prio_order=%d kd=%d (kd=indice de sequence)\n",kp,np,ku,prio_order,kd);
			}
			// --- si le user a dépasse son quota alors on passe a la sequence suivante
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- user=%3d quota=%f / %f\n",ku,users[ku].percent_quota_used,users[ku].percent_quota_authorized);
			}
			if ((total_duration_sequenced>0)&&(mode_quota==1)) {
				if (users[ku].percent_quota_used>users[ku].percent_quota_authorized) {
					if (objectdescr[kd].status_plani<STATUS_PLANI_PLANIFIED) {
						objectdescr[kd].status_plani=STATUS_PLANI_OVER_QUOTA;	
						sprintf(s,"quotas %.1f > %.1f prio=%.1f prio_order=%d",users[ku].percent_quota_used,users[ku].percent_quota_authorized,current_priority,prio_order);
						strncpy(objectdescr[kd].comments,s,OBJECTDESCR_MAXCOM-1);
					}
					if (fidlog!=NULL) {
						fprintf(fidlog,"   --- kd=%4d (seq=%4d/%4d user=%3d). prio_order=%d. Over_quota : %s PASSE A LA SEQUENCE SUIVANTE \n",kd,kp,np,ku,prio_order,s);
						fprintf(fidlog,"  ---- END SEQUENCE %4d/%4d\n",kp,np);
					}
					continue;
				}
			}
			// --- compute the maximum duration of this sequence, including slewing
			duration=objectdescr[kd].delay_slew+objectdescr[kd].delay_exposures;
			angle=180;
			d1=angle/objectdescr[kd].axe_slew1;
			angle=130;
			d2=angle/objectdescr[kd].axe_slew2;
			d12b=(d1>d2)?d1:d2;
			durationtot=duration+d12b;
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- duration=%f d12b=%f durationtot=%f\n",duration,d12b,durationtot);
			}
			// --- initialize the flagobs vector with ever known sequence constraints
			j1=jdobsminmin;
			j2=jdobsmaxmax;
			if (compute_mode==0) {
				for (kjd=0;kjd<njd;kjd++) {
					objectlocal0[kjd]=objectlocals[kk][kjd];
				}
			}
			if (compute_mode==1) {
				for (kjd=0;kjd<njd;kjd++) {
					objectlocal0[kjd].flagobs=0;
				}
				// --- (STEP_4)
				kr=0;
				j1=objectlocalranges[kk].jd1[kr];
				kr=(int)objectlocalranges[kk].nbrange-1;
				j2=objectlocalranges[kk].jd2[kr];
				for (kr=0;kr<objectlocalranges[kk].nbrange;kr++) {
					k1=(int)floor((objectlocalranges[kk].jd1[kr]-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)/djd);
					if (k1<0) {
						k1=0;
					}
					k2=(int)ceil((objectlocalranges[kk].jd2[kr]-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)/djd);
					if (k2>=njd) {
						k2=njd-1;
					}
					for (kjd=k1;kjd<=k2;kjd++) {
						objectlocal0[kjd].flagobs=1;
					}
					if (fidlog!=NULL) {
						fprintf(fidlog,"   --- STEP_4 =1 kr=%d j1=%f k1=%d\n",kr,objectlocalranges[kk].jd1[kr],k1);
						fprintf(fidlog,"   --- STEP_4 =1 kr=%d j2=%f k2=%d\n",kr,objectlocalranges[kk].jd2[kr],k2);
					}
				}
			}
			// ----------------------------------------------------------
			// ===== Description des dates d'une sequence planifiee =====
			// ----------------------------------------------------------
			// planis[0][].jd_slew_start_with_slew=jd0;
			//  <d12>
			// planis[0][].jd_slew_start_without_slew=jd00;
			//  <objectdescr[].delay_slew>
			// planis[0][].jd_acq_start=jd1;
			//  <objectdescr[].delay_exposures>
			// planis[0][].jd_acq_end=jd2;
			//
			// --- switch to zero the flagobs to take account for the sequence duration (STEP_5)
			//     Now, only the end of the night is concerned because STEP_4 put 1 only for the start range jd1.
			k2=njd-1;
			k1=k2-(int)(duration/86400./djd);
			if (k1<0) { k1=0; }
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- STEP_5a =0 k1=%d k2=%d\n",k1,k2);
			}
			for (k=k1;k<=k2;k++) {
				objectlocal0[k].flagobs=0;
			}
			// --- switch to zero the flagobs to take account for sequences already planified
			for (k=0;k<npl;k++) {
				k1=(int)ceil((planis[0][k].jd_slew_start_without_slew-duration/86400.-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd);
				if (k1<0) { k1=0; }
				if (k1>=njd) { k1=njd-1; }
				k2=(int)floor((planis[0][k].jd_acq_end-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd);
				if (k2<0) { k2=0; }
				if (k2>=njd) { k2=njd-1; }
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- STEP_5b =0 k1=%d k2=%d\n",k1,k2);
				}
				for (kjd=k1;kjd<=k2;kjd++) {
					objectlocal0[kjd].flagobs=0;
				}
			}
try_a_gap:
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- Try a gap\n");
			}
			//mc_printobject(njd,sunmoon,objectlocal0);
			// ------------------------------------------------------------
			// ------- Reference date for the sequence is jd1  ------------
			// ------------------------------------------------------------
			// --- search for the best start after slew (jd1)
			// --- jd0(slew_start_with_slew) jd00(slew_start_without_slew) jd1(acq_start) jd2(acq_end)
			// int const_startexposures; // =0 best elevation, =1 start exposure as soon as possible, =2 start in the middle of the [start stop] sequence
			jd1=0;
			k4=-1;
			if (objectdescr[kd].const_startexposures==1) {
				// --- il faut demarrer le plus vite possible
				for (kjd=0;kjd<njd;kjd++) {
					if (objectlocal0[kjd].flagobs==1) {
						k=kjd;
						jd1=sunmoon[kjd].jd;
						break;
					}
				}
			} else if (objectdescr[kd].const_startexposures==0) {
				// --- on observe au meilleur moment du creneau d'observation en explorant de part et d'autre
				k1=(int)((objectdescr[kd].private_jdelevmaxi-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd);
				if (k1>=njd) { k1=njd-1; }
				k3=njd-k1;
				if (k3>k1) { k2=k3; } else { k2=k1; }
				for (k3=0;k3<=k2;k3++) {
					kjd=k1+k3;
					if (kjd<njd) {
						if (objectlocal0[kjd].flagobs==1) {
							k4=kjd;
							jd1=sunmoon[kjd].jd;
							break;
						}
					}
					kjd=k1-k3;
					if (kjd>=0) {
						if (objectlocal0[kjd].flagobs==1) {
							k4=kjd;
							jd1=sunmoon[kjd].jd;
							break;
						}
					}
				}
			} else if (objectdescr[kd].const_startexposures==2) {
				// --- on observe au milieu du creneau d'observation en explorant de part et d'autre
				j1=objectdescr[kd].const_jd1;
				j2=objectdescr[kd].const_jd2;
				if (j1<jd_prevmidsun) {
					j1=jd_prevmidsun;
				}
				if (j2>jd_nextmidsun) {
					j2=jd_nextmidsun;
				}
				// k1 est l'indice du milieu du creneau des contraintes
				k1=(int)(((j1+j2)/2-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd);
				if (k1>=njd) { k1=njd-1; }
				// k3 est le nombre maximal de cases à parcourir de part et d'autre de k1
				k3=njd-k1;
				if (k3>k1) { k2=k3; } else { k2=k1; }
				for (k3=0;k3<=k2;k3++) {
					// kjd est l'indice de la case au dela du milieu
					kjd=k1+k3;
					if (kjd<njd) {
						if (objectlocal0[kjd].flagobs==1) {
							k4=kjd;
							jd1=sunmoon[kjd].jd;
							break;
						}
					}
					// kjd est l'indice de la case en deca du milieu
					kjd=k1-k3;
					if (kjd>=0) {
						if (objectlocal0[kjd].flagobs==1) {
							k4=kjd;
							jd1=sunmoon[kjd].jd;
							break;
						}
					}
				}
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- STEP_6  k4=%d, jd1=%f < j1=%f || jd1=%f > j2=%f\n",k4,jd1,j1,jd1,j2);
				}
				if ((jd1<j1)||(jd1>j2)) {
					// --- trou trouve en dehors des limites d'observations
					if (fidlog!=NULL) {
						fprintf(fidlog,"   --- STEP_6  milieu\n");
					}
					jd1=(j1+j2)/2.;
				}
			}
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- STEP_6a jd1=%f\n",jd1);
			}
			if (k4==-1) {
				// --- There is no gap large enough to insert the current sequence.
				// --- At these step, the slewing time is not taken into account.
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). There is no gap large enough to insert the current sequence\n",kd,kp,np,ku);
					fprintf(fidlog,"  ---- END SEQUENCE %4d/%4d\n",kp,np);
				}
				continue;
			}
			jd0=jd00=jd1;
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- STEP_6b jd00=%f\n",jd00);
			}
			//mc_printobject(njd,sunmoon,objectlocal0);
			// =============================================================================================
			// ================= DEBUT de la partie qui tient compte des durees de slew ====================
			// =============================================================================================
			// --- kk1 : indice dans objectlocal0 pour mc_scheduler_local1
			kk1=(int)floor((jd00-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd);
			// --- jd0(debut_slew) jd1(debut_acq) jd2(fin_acq)
			// --- recherche la sequence deja planifiee precedente
			for (k=0,k3=-1;k<npl;k++) {
				if (planis[0][k].jd_acq_end<jd1) {
					k3=k;
				} else {
					break;
				}
			}
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- PRECEDENTE : k3=%d\n",k3);
			}
			// --- if k3!=-1, k3 is the previous ever planified sequence (planis[0][k3]).
			// --- if k3==-1, there is no previous ever planified sequence.
			// ---
			// --- calcule d12, le temps de raliement de la fin de la sequence precedente et celle-ci
			if (k3>=0) {
				ha1=planis[0][k3].ha_acq_end; if (ha1>180) { ha1-=360; }
				dec1=planis[0][k3].dec_acq_end;
				ha2=ha1;
				dec2=dec1;
				if (compute_mode==0) {
					ha2=objectlocal0[kk1].ha; if (ha2>180) { ha2-=360; }
					dec2=objectlocal0[kk1].dec;
				}
				if (compute_mode==1) {
					mc_scheduler_local1(kk1,longmpc,rhocosphip,rhosinphip,latrad,luminance_ciel_bleus,&objectdescr[kd],njd,sunmoon,horizon_altaz,horizon_hadec,&jd_loc,&ha_loc,&elev_loc,&az_loc,&dec_loc,&moon_dist_loc,&sun_dist_loc,&brillance_totale_loc,&ra_loc);
					ha2=ha_loc; if (ha2>180) { ha2-=360; }
					dec2=dec_loc;
				}
				angle=fabs(ha1-ha2);
				d1=angle/objectdescr[kd].axe_slew1;
				angle=fabs(dec1-dec2);
				d2=angle/objectdescr[kd].axe_slew2;
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- ha1=%f ha2=%f d1=%f dec1=%f dec2=%f d2=%f\n",ha1,ha2,d1,dec1,dec2,d2);
				}
				d12=(d1>d2)?d1:d2;
				k1=k3;
			} else {
				angle=70.;
				d1=angle/objectdescr[kd].axe_slew1;
				d2=angle/objectdescr[kd].axe_slew2;
				d12=(d1>d2)?d1:d2;
				k3=-1;
				k1=0;
			}
			// --- decalage pour tenir compte du temps de pointage avec la sequence precedente
			jd00=jd1-objectdescr[kd].delay_slew/86400.;
			jd0=jd00-d12/86400.;
			dd=0;
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- jd0=%f d12=%f\n",jd0,d12);
			}
			// --- if k3>=0, k3 is the previous ever planified sequence (planis[0][k3]).
			jdseq_prev0=jdseq_prev=jd_prevmidsun;
			if (k3>=0) {
				jdseq_prev0=jdseq_prev=planis[0][k3].jd_acq_end;
				// -- on traite le cas où l'on colle deja a la sequence precedente
				dd=jd0-jdseq_prev;
				if (dd<0) {
					jd0=jdseq_prev;
					jd00=jd0+d12/86400;
					jd1=jd00+objectdescr[kd].delay_slew/86400.;
				}
			}
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- jdseq_prev=%f\n",jdseq_prev);
			}
			// --- compute jd2 knowing a valid jd00 and the duration
			jd2=jd00+duration/86400.;
			// --- kk2 : indice dans objectlocal0 pour mc_scheduler_local1
			kk2=(int)ceil((jd2-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd); if (kk2>njd) { kk2=njd-1; }
			// --- recherche la sequence deja planifiee suivante
			if (k3>=0) {
				k3++;
				if (k3>=npl) {
					k3=-1;
				}
			} else {
				for (k=k1,k3=-1;k<npl;k++) {
					if (planis[0][k].jd_acq_start>jd2) {
						k3=k;
						break;
					}
				}
			}
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- SUIVANTE : k3=%d\n",k3);
			}
			// --- if k3>=0,  k3 is the next ever planified sequence (planis[0][k3]).
			// --- if k3==-1, there is no next ever planified sequence.
			// --- calcule d12b, le temps de raliement de la sequence choisie et du debut de la sequence suivante
			d12b=0;
			jdseq_next0=jdseq_next=jd_nextmidsun;
			if (k3>=0) {
				ha1=planis[0][k3].ha_acq_start; if (ha1>180) { ha1-=360; }
				dec1=planis[0][k3].dec_acq_start;
				ha2=ha1;
				dec2=dec1;
				if (compute_mode==0) {
					ha2=objectlocal0[kk2].ha; if (ha2>180) { ha2-=360; }
					dec2=objectlocal0[kk2].dec;
				}
				if (compute_mode==1) {
					mc_scheduler_local1(kk2,longmpc,rhocosphip,rhosinphip,latrad,luminance_ciel_bleus,&objectdescr[kd],njd,sunmoon,horizon_altaz,horizon_hadec,&jd_loc,&ha_loc,&elev_loc,&az_loc,&dec_loc,&moon_dist_loc,&sun_dist_loc,&brillance_totale_loc,&ra_loc);
					ha2=ha_loc; if (ha2>180) { ha2-=360; }
					dec2=dec_loc;
				}
				angle=fabs(ha1-ha2);
				d1=angle/objectdescr[kd].axe_slew1;
				angle=fabs(dec1-dec2);
				d2=angle/objectdescr[kd].axe_slew2;
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- ha1=%f ha2=%f d1=%f dec1=%f dec2=%f d2=%f\n",ha1,ha2,d1,dec1,dec2,d2);
				}
				d12b=(d1>d2)?d1:d2;
				// -- dd est la correction sur jd_slew_start_with_slew de la sequence suivante deja programmee
				dd=(planis[0][k3].jd_slew_start_without_slew-planis[0][k3].jd_slew_start_with_slew)-d12b/86400.;
				jdseq_next=planis[0][k3].jd_slew_start_with_slew+dd;
				jdseq_next0=planis[0][k3].jd_slew_start_without_slew;
			}
			// --- on compare la duree de la sequence avec la largeur du gap dans lequel l'inserer en tenant compte des temps de pointage
			durationtot=jd2-jd0;
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- jdseq_next=%f d12b=%f\n",jdseq_next,d12b);
				fprintf(fidlog,"   --- durationtot=%f sec\n",durationtot*86400);
			}
			if (durationtot>(jdseq_next-jdseq_prev)) {
				// --- The gap is not large enough to insert the current sequence.
				kk1=(int)floor((jdseq_prev0-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd); if (kk1<0) { kk1=0; }
				kk2=(int)ceil((jdseq_next0-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd); if (kk2>=njd) { kk2=njd-1; }
				// --- we fill the gap with zeros to avoid to retry the same gap the next time
				k1=0;
				for (kjd=kk1;kjd<=kk2;kjd++) {
					if (objectlocal0[kjd].flagobs==1) {
						k1++;
					}
					objectlocal0[kjd].flagobs=0;
				}
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d %3d). The gap is not large enough to insert the current sequence. Go to try another gap.\n",kd,kp,np,ku,k1);
				}
				if (k1>0) {
					if (fidlog!=NULL) {
						fprintf(fidlog,"   --- TRY ANOTHER GAP b\n");
					}
					goto try_a_gap; // try another gap
				} else {
					if (fidlog!=NULL) {
						fprintf(fidlog,"  ---- END SEQUENCE %4d/%4d\n",kp,np);
					}
					continue; // next sequence
				}
			} 
			if (jd2>jdseq_next) {
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). The gap must be shifted backward to be just aside the beginning of the next sequence.\n",kd,kp,np,ku);
				}
				// --- The gap must be shifted backward to be just aside the beginning of the next sequence
				dd0=jd2-jdseq_next;
				jd2-=dd0;
				jd1-=dd0;
				jd00-=dd0;
				jd0-=dd0;
				if (fidlog!=NULL) {
					//fprintf(fidlog," kd=%4d (%4d/%4d). B jdseq_prev=%f jd0=%f jd00=%f jd2=%f jdseq_next=%f.\n",kd,kp,np,jdseq_prev,jd0,jd00,jd2,jdseq_next);
				}
				if (jd0<jdseq_prev) {
					// --- The gap is definitively to small
					kk1=(int)floor((jdseq_prev0-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd); if (kk1<0) { kk1=0; }
					kk2=(int)ceil((jdseq_next0-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd); if (kk2>=njd) { kk2=njd-1; }
					// --- we fill the gap with zeros to avoid to retry the same gap the next time
					k1=0;
					for (kjd=kk1;kjd<=kk2;kjd++) {
						if (objectlocal0[kjd].flagobs==1) {
							k1++;
						}
						objectlocal0[kjd].flagobs=0;
					}
					if (fidlog!=NULL) {
						fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). The gap is definitively to small. Go to try another gap.\n",kd,kp,np,ku);
					}
					if (k1>0) {
						if (fidlog!=NULL) {
							fprintf(fidlog,"   --- TRY ANOTHER GAP b\n");
						}
						goto try_a_gap; // try another gap
					} else {
						if (fidlog!=NULL) {
							fprintf(fidlog,"  ---- END SEQUENCE %4d/%4d\n",kp,np);
						}
						continue; // next sequence
					}
				}
			} 
			if (jd2>jdseq_next-(objectdescr[kd].delay_slew)/86400.) {
				// --- This is the case corresponding to a gap between the end of the
				//     sequence and the start of the next sequence which is too small
				//     to insert another future sequence. We push the sequence to the
				//     next ever planified sequence if possible by constraints.
				dd0=jdseq_next-jd2;
				dd1=j2-jd1;
				if (dd1<dd0) {
					dd0=dd1;
				}
				if (dd0>0) {
					if (fidlog!=NULL) {
						fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). The gap must be shifted forward to be just aside the beginning of the next sequence.\n",kd,kp,np,ku);
					}
					// --- The gap must be shifted forward to be just aside the beginning of the next sequence
					jd2+=dd0;
					jd1+=dd0;
					jd00+=dd0;
					jd0+=dd0;
				}
			} 
			// --- the insertion implies to change the pointing duration of the next sequence ever planified
			if (k3>=0) {
				planis[0][k3].jd_slew_start_with_slew+=dd;
			}
			// =============================================================================================
			// ================= FIN de la partie qui tient compte des durees de slew ======================
			// =============================================================================================
			// --- jd0(slew_start_with_slew) jd00(slew_start_without_slew) jd1(acq_start) jd2(acq_end)
			// ----------------------------------------------------------
			// ===== Description des dates d'une sequence planifiee =====
			// ----------------------------------------------------------
			// planis[0][].jd_slew_start_with_slew=jd0;
			//  <d12>
			// planis[0][].jd_slew_start_without_slew=jd00;
			//  <objectdescr[].delay_slew>
			// planis[0][].jd_acq_start=jd1;
			//  <objectdescr[].delay_instrum+objectdescr[].delay_exposures>
			// planis[0][].jd_acq_end=jd2;
			//
			jd1=jd00+objectdescr[kd].delay_slew/86400.;
			jd2=jd1+(objectdescr[kd].delay_exposures)/86400.;
			if (fidlog!=NULL) {
				fprintf(fidlog,"   === PLANIFICATION-OK : jd0=%f jd00=%f jd1=%f jd2=%f\n",jd0,jd00,jd1,jd2);
			}
			// --- the sequence will be inserted in the gap.
			// --- on remplit la planif d'indice npl (0 pour la premiere planif)
			// --- a noter que planis[0][*] est la plani officielle et planis[1][*] est un swap utilise lors de l'insertion de la sequence
			free(planis[1]);
			planis[1]=(mc_PLANI*)malloc((npl+1)*sizeof(mc_PLANI));
			// --- on commence par copier les sequences planifiées precedentes.
			k=k1=0;
			for (k=k1;k<npl;k++) {
				if (planis[0][k].jd_acq_end<=jd0) {
					planis[1][k]=planis[0][k];
				} else {
					break;
				}
			}
			// --- insertion de la sequence
			k1=k;
			total_duration_sequenced+=(jd2-jd0);
			users[ku].duration_total_used+=(jd2-jd0);
			planis[1][k1].idseq=objectdescr[kd].idseq;
			planis[1][k1].jd_slew_start_with_slew=jd0;
			planis[1][k1].jd_slew_start_without_slew=jd00;
			planis[1][k1].jd_acq_start=jd1;
			planis[1][k1].jd_acq_end=jd2;
			planis[1][k1].jd_elev_max=0.;
			planis[1][k1].order=npl;
			planis[1][k1].percent_quota_used=users[ku].duration_total_used/total_duration_obsobs*100;
			kk1=(int)((jd1-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd);
			if (kk1>=njd) { 
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). PROBLEM kk1=%d jd1=%f.\n",kd,kp,np,ku,kk1,jd1);
				}
				kk1=njd-1; 
			}
			if (compute_mode==0) {
				mc_sheduler_coord_app2cat(jd1,objectlocal0[kk1].ra*(DR),objectlocal0[kk1].dec*(DR),J2000,&racat,&deccat);
				planis[1][k1].az_acq_start=objectlocal0[kk1].az;
				planis[1][k1].elev_acq_start=objectlocal0[kk1].elev;
				planis[1][k1].ra_acq_start=racat/(DR);
				planis[1][k1].ha_acq_start=objectlocal0[kk1].ha;
				planis[1][k1].dec_acq_start=deccat/(DR);
			}
			if (compute_mode==1) {
				mc_scheduler_local1(kk1,longmpc,rhocosphip,rhosinphip,latrad,luminance_ciel_bleus,&objectdescr[kd],njd,sunmoon,horizon_altaz,horizon_hadec,&jd_loc,&ha_loc,&elev_loc,&az_loc,&dec_loc,&moon_dist_loc,&sun_dist_loc,&brillance_totale_loc,&ra_loc);
				mc_sheduler_coord_app2cat(jd1,ra_loc*(DR),dec_loc*(DR),J2000,&racat,&deccat);
				planis[1][k1].az_acq_start=az_loc;
				planis[1][k1].elev_acq_start=elev_loc;
				planis[1][k1].ra_acq_start=racat/(DR);
				planis[1][k1].ha_acq_start=ha_loc;
				planis[1][k1].dec_acq_start=deccat/(DR);
			}
			kk2=(int)((jd2-jd_prevmidsun)/(jd_nextmidsun-jd_prevmidsun)*njd);
			if (kk2>=njd) { 
				if (fidlog!=NULL) {
					fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). PROBLEM kk2=%d jd2=%f.\n",kd,kp,np,ku,kk2,jd2);
				}
				kk2=njd-1; 
			}
			if (compute_mode==0) {
				mc_sheduler_coord_app2cat(jd2,objectlocal0[kk2].ra*(DR),objectlocal0[kk2].dec*(DR),J2000,&racat,&deccat);
				planis[1][k1].az_acq_end=objectlocal0[kk2].az;
				planis[1][k1].elev_acq_end=objectlocal0[kk2].elev;
				planis[1][k1].ra_acq_end=racat/(DR);
				planis[1][k1].ha_acq_end=objectlocal0[kk2].ha;
				planis[1][k1].dec_acq_end=deccat/(DR);
			}
			if (compute_mode==1) {
				mc_scheduler_local1(kk2,longmpc,rhocosphip,rhosinphip,latrad,luminance_ciel_bleus,&objectdescr[kd],njd,sunmoon,horizon_altaz,horizon_hadec,&jd_loc,&ha_loc,&elev_loc,&az_loc,&dec_loc,&moon_dist_loc,&sun_dist_loc,&brillance_totale_loc,&ra_loc);
				mc_sheduler_coord_app2cat(jd2,ra_loc*(DR),dec_loc*(DR),J2000,&racat,&deccat);
				planis[1][k1].az_acq_end=az_loc;
				planis[1][k1].elev_acq_end=elev_loc;
				planis[1][k1].ra_acq_end=racat/(DR);
				planis[1][k1].ha_acq_end=ha_loc;
				planis[1][k1].dec_acq_end=deccat/(DR);
			}
			// --- on termine en copiant les sequences planifiées suivantes.
			for (k=k1+1;k<=npl;k++) {
				planis[1][k]=planis[0][k-1];
			}
			if (k1+1<=npl) {
				if (planis[1][k1].jd_acq_end>planis[1][k1+1].jd_slew_start_with_slew) {
					// --- probleme dans le calcul
					if (fidlog!=NULL) {
						fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). PROBLEM 0 %f > %f\n",kd,kp,np,ku,planis[1][k1].jd_acq_end,planis[1][k1+1].jd_slew_start_with_slew);
					}
				}
			}
			free(planis[0]);
			planis[0]=(mc_PLANI*)malloc((npl+1)*sizeof(mc_PLANI));
			objectdescr[kd].nb_plani++;
			sprintf(s,"(mode_quota=%d nb_plani=%d prio=%.1f prio_order=%d)",mode_quota,objectdescr[kd].nb_plani,current_priority,prio_order);
			strncpy(objectdescr[kd].comments,s,OBJECTDESCR_MAXCOM-1);
			if (objectdescr[kd].status_plani==STATUS_PLANI_PLANIFIED) {
				objectdescr[kd].status_plani=STATUS_PLANI_PLANIFIED_OVER;
			} else {
				objectdescr[kd].status_plani=STATUS_PLANI_PLANIFIED;
			}
			if (fidlog!=NULL) {
				fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). Planified %s (%d)\n",kd,kp,np,ku,s,objectdescr[kd].status_plani);
			}
			// --- on met a jour la planification.
			for (k4=0,k=0;k<=npl;k++) {
				planis[0][k]=planis[1][k];
				if (k>0) {
					if (planis[1][k].jd_slew_start_without_slew<planis[1][k-1].jd_acq_end) {
						k4++;
					}
				}
				if (fidlog!=NULL) {
					fprintf(fidlog,"   *** k=%d %f %f %f %f (%d)\n",k,planis[1][k].jd_slew_start_with_slew,planis[1][k].jd_slew_start_without_slew,planis[1][k].jd_acq_start,planis[1][k].jd_acq_end,k4);
				}
			}
			if (fidlog!=NULL) {
				if (k4>0) {
					fprintf(fidlog,"   --- PROBLEM k4=%d\n",k4);
				}
				fprintf(fidlog,"   --- kd=%4d (%4d/%4d:%3d). planified\n",kd,kp,np,ku);
				fprintf(fidlog,"  ---- END SEQUENCE %4d/%4d\n",kp,np);
			}
			npl++;
			//mc_printplani(npl,planis);
		}
		ko-=(np+1);
		if (ko<0) {
			if (mode_quota==1) {
				ko=nobjloc-1;
				mode_quota=2;
				prio_order=0;
			} else {
				ko=nobjloc-1;
				if (npl==npl0) {
					break;
				}
			}
			npl0=npl;
			dt=(double)(clock()-clock0)/(double)clk_tck;
			if (dt>300) {
				break;
			}
		}
	}
	dt=(double)(clock()-clock0)/(double)clk_tck;
	if (print_mode==1) {
		mc_printplani(npl,planis);
		mc_printusers(nu,users);
	}
	if (fidlog!=NULL) {
		fprintf(fidlog,"=== Quit the great loop");
	}

	/* --- sorties ---*/
	if (output_type==1) {
		fid=fopen(output_file,"wt");
		if (fid!=NULL) {
			for (k=0;k<npl;k++) {
				fprintf(fid,"%5d ",planis[0][k].idseq);
				fprintf(fid,"%15.6f ",planis[0][k].jd_slew_start_with_slew);
				fprintf(fid,"%15.6f ",planis[0][k].jd_slew_start_without_slew);
				fprintf(fid,"%15.6f ",planis[0][k].jd_acq_start);
				fprintf(fid,"%15.6f ",planis[0][k].jd_acq_end);
				fprintf(fid,"%15.6f ",planis[0][k].jd_elev_max);
				fprintf(fid,"%5d ",planis[0][k].order);
				fprintf(fid,"%7.4f ",planis[0][k].percent_quota_used);
				fprintf(fid,"%10.5f ",planis[0][k].az_acq_start);
				fprintf(fid,"%10.5f ",planis[0][k].elev_acq_start);
				fprintf(fid,"%10.5f ",planis[0][k].ha_acq_start);
				fprintf(fid,"%10.5f ",planis[0][k].ra_acq_start);
				fprintf(fid,"%+10.5f ",planis[0][k].dec_acq_start);
				fprintf(fid,"%10.5f ",planis[0][k].az_acq_end);
				fprintf(fid,"%10.5f ",planis[0][k].elev_acq_end);
				fprintf(fid,"%10.5f ",planis[0][k].ha_acq_end);
				fprintf(fid,"%10.5f ",planis[0][k].ra_acq_end);
				fprintf(fid,"%+10.5f ",planis[0][k].dec_acq_end);
				fprintf(fid,"\n");
			}
			fclose(fid);
		}
	}

   //mc_fitspline(n1,n2,x,y,dy,s,nn,xx,ff);
	if (fidlog!=NULL) {
		fprintf(fidlog,"=== Free memory");
	}
	if (users!=NULL) free(users);
	if (sunmoon!=NULL) free(sunmoon);
	for (kp=0;kp<2;kp++) {
		if (planis[kp]!=NULL) free(planis[kp]);
	}
	if (planis!=NULL) free(planis);
	if (compute_mode==0) {
		for (ko=0;ko<nobjloc;ko++) {
			if (objectlocals[ko]!=NULL) free(objectlocals[ko]);
		}
		if (objectlocals!=NULL) free(objectlocals);
	} 
	if (compute_mode==1) {
		if (objectlocal!=NULL) free(objectlocal);
	} 
	if (objectlocal0!=NULL) free(objectlocal0);
	if (objectlinks!=NULL) free(objectlinks);
	if (luminance_ciel_bleus!=NULL) free(luminance_ciel_bleus);
	if (dummys!=NULL) free(dummys);
	if (kdummys!=NULL) free(kdummys);
	if (same_priority!=NULL) free(same_priority);
	if (ksame_priority!=NULL) free(ksame_priority);
	if (priority_total!=NULL) free(priority_total);
	if (kpriority_total!=NULL) free(kpriority_total);
	if (jdsets!=NULL) free(jdsets);
	if (kjdsets!=NULL) free(kjdsets);
	if (fidlog!=NULL) {
		fclose(fidlog);
	}
   return 0;
}

int mc_printplani(int npl,mc_PLANI **planis) {
	FILE *f;
	int k;
	f=fopen("planis.txt","wt");
	for (k=0;k<npl;k++) {
		fprintf(f,"%5d ",planis[0][k].idseq);
		fprintf(f,"%15.6f ",planis[0][k].jd_slew_start_with_slew);
		fprintf(f,"%15.6f ",planis[0][k].jd_slew_start_without_slew);
		fprintf(f,"%15.6f ",planis[0][k].jd_acq_start);
		fprintf(f,"%15.6f ",planis[0][k].jd_acq_end);
		fprintf(f,"%15.6f ",planis[0][k].jd_elev_max);
		fprintf(f,"%5d ",planis[0][k].order);
		fprintf(f,"%7.4f ",planis[0][k].percent_quota_used);
		fprintf(f,"%10.5f ",planis[0][k].az_acq_start);
		fprintf(f,"%10.5f ",planis[0][k].elev_acq_start);
		fprintf(f,"%10.5f ",planis[0][k].ha_acq_start);
		fprintf(f,"%10.5f ",planis[0][k].ra_acq_start);
		fprintf(f,"%+10.5f ",planis[0][k].dec_acq_start);
		fprintf(f,"%10.5f ",planis[0][k].az_acq_end);
		fprintf(f,"%10.5f ",planis[0][k].elev_acq_end);
		fprintf(f,"%10.5f ",planis[0][k].ha_acq_end);
		fprintf(f,"%10.5f ",planis[0][k].ra_acq_end);
		fprintf(f,"%+10.5f ",planis[0][k].dec_acq_end);
		fprintf(f,"\n");
	}
	fclose(f);
	return 0;
}

int mc_printusers(int nu,mc_USERS *users) {
	FILE *f;
	int k;
	f=fopen("users.txt","wt");
	for (k=0;k<nu;k++) {
		fprintf(f,"%5d ",users[k].iduser);
		fprintf(f,"%f ",users[k].duration_total_used);
		fprintf(f,"%f ",users[k].percent_quota_authorized);
		fprintf(f,"%f ",users[k].percent_quota_used);
		fprintf(f,"\n");
	}
	fclose(f);
	return 0;
}

int mc_printobject(int njd,mc_SUNMOON *sunmoon,mc_OBJECTLOCAL *objectlocal) {
	FILE *f;
	int k;
	f=fopen("objectlocal.txt","wt");
	for (k=0;k<njd;k++) {
		fprintf(f,"%4d ",k);
		fprintf(f,"%15.6f ",sunmoon[k].jd);
		fprintf(f,"%d ",objectlocal[k].flagobs);
		fprintf(f,"%+6.2f ",objectlocal[k].elev);
		fprintf(f,"%+6.2f ",objectlocal[k].skylevel);
		fprintf(f,"\n");
	}
	fclose(f);
	return 0;
}

/************************************************************************/
/************************************************************************/
/************************************************************************/
int mc_nextnight1(double jd_now, double longmpc, double rhocosphip, double rhosinphip,double elev_set,double elev_twilight, double *jdprev, double *jdset,double *jddusk,double *jddawn,double *jdrise,double *jdnext,double *jdriseprev2,double *jdmer2,double *jdset2,double *jddusk2,double *jddawn2,double *jdrisenext2) {
	double jd_prevmidsun,jd_nextmidsun,djd;
	int njd,kjd;
	mc_SUNMOON *sunmoon=NULL;

	// === mer2mer ===

	// --- compute dates of observing range (=the start-end of the schedule) mer2mer
	mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

	// --- compute mc_SUNMOON vector for the observing range.
	djd=1./86400.;
	mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

	*jdprev=jd_prevmidsun;
	*jdset=jd_prevmidsun;
	*jddusk=jd_prevmidsun;
	*jdrise=jd_nextmidsun;
	*jddawn=jd_nextmidsun;
	*jdnext=jd_nextmidsun;
	for (kjd=1;kjd<njd;kjd++) {
		if ((sunmoon[kjd-1].sun_elev>=elev_twilight)&&(sunmoon[kjd].sun_elev<elev_twilight)) {
			*jddusk=sunmoon[kjd-1].jd;
		}
		if ((sunmoon[kjd-1].sun_elev>=elev_set)&&(sunmoon[kjd].sun_elev<elev_set)) {
			*jdset=sunmoon[kjd-1].jd;
		}
		if ((sunmoon[kjd-1].sun_elev<=elev_set)&&(sunmoon[kjd].sun_elev>elev_set)) {
			*jdrise=sunmoon[kjd-1].jd;
		}
		if ((sunmoon[kjd-1].sun_elev<=elev_twilight)&&(sunmoon[kjd].sun_elev>elev_twilight)) {
			*jddawn=sunmoon[kjd-1].jd;
		}
	}
	free(sunmoon);

	// === rise2rise ===

	if (jd_now<*jdrise) {

		*jdriseprev2=*jdprev; // a recalculer
		*jdmer2=*jdprev;
		*jdset2=*jdset;
		*jddusk2=*jddusk;
		*jddawn2=*jddawn;
		*jdrisenext2=*jdrise;

		jd_now=*jdprev-0.1;
		// --- compute dates of observing range (=the start-end of the schedule) mer2mer
		mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

		// --- compute mc_SUNMOON vector for the observing range.
		djd=1./86400.;
		mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

		for (kjd=1;kjd<njd;kjd++) {
			if ((sunmoon[kjd-1].sun_elev<=elev_set)&&(sunmoon[kjd].sun_elev>elev_set)) {
				*jdriseprev2=sunmoon[kjd-1].jd;
			}
		}
		free(sunmoon);

	} else {
		*jdriseprev2=*jdrise;
		*jdmer2=*jdnext;
		*jdset2=*jdnext; //  a recalculer
		*jddusk2=*jdnext; // a recalculer
		*jddawn2=*jdnext; // a recalculer
		*jdrisenext2=*jdnext; // a recalculer

		jd_now=*jdnext+0.1;
		// --- compute dates of observing range (=the start-end of the schedule) mer2mer
		mc_scheduler_windowdates1(jd_now,longmpc,rhocosphip,rhosinphip,&jd_prevmidsun,&jd_nextmidsun);

		// --- compute mc_SUNMOON vector for the observing range.
		djd=1./86400.;
		mc_scheduler_sunmoon1(longmpc,rhocosphip,rhosinphip,jd_prevmidsun,jd_nextmidsun,djd,&njd,&sunmoon);

		for (kjd=1;kjd<njd;kjd++) {
			if ((sunmoon[kjd-1].sun_elev>=elev_twilight)&&(sunmoon[kjd].sun_elev<elev_twilight)) {
				*jddusk2=sunmoon[kjd-1].jd;
			}
			if ((sunmoon[kjd-1].sun_elev>=elev_set)&&(sunmoon[kjd].sun_elev<elev_set)) {
				*jdset2=sunmoon[kjd-1].jd;
			}
			if ((sunmoon[kjd-1].sun_elev<=elev_set)&&(sunmoon[kjd].sun_elev>elev_set)) {
				*jdrisenext2=sunmoon[kjd-1].jd;
			}
			if ((sunmoon[kjd-1].sun_elev<=elev_twilight)&&(sunmoon[kjd].sun_elev>elev_twilight)) {
				*jddawn2=sunmoon[kjd-1].jd;
			}
		}
		free(sunmoon);

	}

   return 0;
}

