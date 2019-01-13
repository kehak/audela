/* mc_modl1.c
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
/* Modele de pointage                                                      */
/***************************************************************************/
#include "mc.h"

/****************************************************************************/
/* mc_modpoi_addobs_az                                                      */
/****************************************************************************/
/**	Fill a line of the matrix of the pointing model
 * @param az is the azimuth (radian).
 * @param h is the elevation (radian).
 * @param nb_coef is number of model terms.
 * @param vecy is vector which defines model terms.
 * @param matx is matrix line corresponding to this star.
*/
/****************************************************************************/
double mc_modpoi_addobs_az(double az,double h,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx) {
	int k,kk;
	double daz;
	double tane,cosa,sina,sece,cos2a,sin2a,cos3a,sin3a,cos4a,sin4a;
	// double sine,cose;
	double cos5a,sin5a,cos6a,sin6a;
	/* --- altaz corrections ---*/
	tane=tan(h);
	cosa=cos(az);
	sina=sin(az);
	//cose=cos(h);
	//sine=sin(h);
	sece=1./cos(h);
	cos2a=cos(2.*az);
	sin2a=sin(2.*az);
	cos3a=cos(3.*az);
	sin3a=sin(3.*az);
	cos4a=cos(4.*az);
	sin4a=sin(4.*az);
	cos5a=cos(5.*az);
	sin5a=sin(5.*az);
	cos6a=cos(6.*az);
	sin6a=sin(6.*az);
	kk=0;
	for (k=0;k<nb_coef;k++) {
		matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.;
		if (strcmp(vecy[k].type,"IA")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=1.; }
		if (strcmp(vecy[k].type,"IE")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"NPAE")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=tane; }
		if (strcmp(vecy[k].type,"CA")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sece; }
		if (strcmp(vecy[k].type,"AN")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sina*tane; }
		if (strcmp(vecy[k].type,"AW")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cosa*tane; }
		if (strcmp(vecy[k].type,"ACEC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosa; }
		if (strcmp(vecy[k].type,"ECEC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ACES")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sina; }
		if (strcmp(vecy[k].type,"ECES")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"NRX")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=1.; }
		if (strcmp(vecy[k].type,"NRY")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=tane; }
		if (strcmp(vecy[k].type,"ACEC2")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos2a; }
		if (strcmp(vecy[k].type,"ACES2")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin2a; }
		if (strcmp(vecy[k].type,"AN2")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin2a*tane; }
		if (strcmp(vecy[k].type,"AW2")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cos2a*tane; }
		if (strcmp(vecy[k].type,"ACEC3")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos3a; }
		if (strcmp(vecy[k].type,"ACES3")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin3a; }
		if (strcmp(vecy[k].type,"AN3")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin3a*tane; }
		if (strcmp(vecy[k].type,"AW3")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cos3a*tane; }
		if (strcmp(vecy[k].type,"ACEC4")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos4a; }
		if (strcmp(vecy[k].type,"ACES4")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin4a; }
		if (strcmp(vecy[k].type,"AN4")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin4a*tane; }
		if (strcmp(vecy[k].type,"AW4")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cos4a*tane; }
		if (strcmp(vecy[k].type,"ACEC5")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos5a; }
		if (strcmp(vecy[k].type,"ACES5")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin5a; }
		if (strcmp(vecy[k].type,"AN5")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin5a*tane; }
		if (strcmp(vecy[k].type,"AW5")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cos5a*tane; }
		if (strcmp(vecy[k].type,"ACEC6")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos6a; }
		if (strcmp(vecy[k].type,"ACES6")==0) { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin6a; }
		if (strcmp(vecy[k].type,"AN6")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin6a*tane; }
		if (strcmp(vecy[k].type,"AW6")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cos6a*tane; }
		kk++;
	}
	daz=0.;
	for (k=0;k<nb_coef;k++) {
		daz+=(matx[k].coef*vecy[k].coef);
	}
	return daz;
}

/****************************************************************************/
/* mc_modpoi_addobs_h                                                       */
/****************************************************************************/
/**	Fill a line of the matrix of the pointing model
 * @param az is the azimuth (radian).
 * @param h is the elevation (radian).
 * @param nb_coef is number of model terms.
 * @param vecy is vector which defines model terms.
 * @param matx is matrix line corresponding to this star.
*/
/****************************************************************************/
double mc_modpoi_addobs_h(double az,double h,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx) {
	int k,kk;
	double dh;
	double cosa,sina,cose,sine,cos2a,sin2a,cos3a,sin3a,cos4a,sin4a;
	//double tane,sece;
	double cos5a,sin5a,cos6a,sin6a;
	/* --- altaz corrections ---*/
	//tane=tan(h);
	cosa=cos(az);
	sina=sin(az);
	cose=cos(h);
	sine=sin(h);
	//sece=1./cos(h);
	cos2a=cos(2.*az);
	sin2a=sin(2.*az);
	cos3a=cos(3.*az);
	sin3a=sin(3.*az);
	cos4a=cos(4.*az);
	sin4a=sin(4.*az);
	cos5a=cos(5.*az);
	sin5a=sin(5.*az);
	cos6a=cos(6.*az);
	sin6a=sin(6.*az);
	kk=0;
	for (k=0;k<nb_coef;k++) {
		matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.;
		if (strcmp(vecy[k].type,"IA")==0)    { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"IE")==0)    { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=1.; }
		if (strcmp(vecy[k].type,"NPAE")==0)  { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"CA")==0)    { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"AN")==0)    { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosa; }
		if (strcmp(vecy[k].type,"AW")==0)    { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sina; }
		if (strcmp(vecy[k].type,"ACEC")==0)  { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ECEC")==0)  { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cose; }
		if (strcmp(vecy[k].type,"ACES")==0)  { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ECES")==0)  { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sine; }
		if (strcmp(vecy[k].type,"NRX")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-sine; }
		if (strcmp(vecy[k].type,"NRY")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cose; }
		if (strcmp(vecy[k].type,"ACEC2")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ACES2")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"AN2")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos2a; }
		if (strcmp(vecy[k].type,"AW2")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin2a; }
		if (strcmp(vecy[k].type,"ACEC3")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ACES3")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"AN3")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos3a; }
		if (strcmp(vecy[k].type,"AW3")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin3a; }
		if (strcmp(vecy[k].type,"ACEC4")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ACES4")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"AN4")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos4a; }
		if (strcmp(vecy[k].type,"AW4")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin4a; }
		if (strcmp(vecy[k].type,"ACEC5")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ACES5")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"AN5")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos5a; }
		if (strcmp(vecy[k].type,"AW5")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin5a; }
		if (strcmp(vecy[k].type,"ACEC6")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ACES6")==0) { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"AN6")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos6a; }
		if (strcmp(vecy[k].type,"AW6")==0)   { matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin6a; }
		kk++;
	}
	dh=0.;
	for (k=0;k<nb_coef;k++) {
//modif michel
      //dh+=(matx[nb_coef+k].coef*vecy[k].coef);
		dh+=(matx[k].coef*vecy[k].coef);
	}
	return dh;
}

/****************************************************************************/
/* mc_modpoi_addobs_ha                                                      */
/****************************************************************************/
/**	Fill a line of the matrix of the pointing model
 * @param ha is the hour angle (radian).
 * @param dec is the declination (radian).
 * @param latrad is the observatory latitude (radian).
 * @param nb_coef is number of model terms.
 * @param vecy is vector which defines model terms.
 * @param matx is matrix line corresponding to this star.
*/
/****************************************************************************/
double mc_modpoi_addobs_ha(double ha,double dec,double latrad,int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx) {
	int k,kk;
	double dha;
	double tand,cosh,sinh,cosd,sind,cosl,sinl,secd;
	double cos2h,cos3h,cos4h; //cos2d,cos3d,cos4d;
	double sin2h,sin3h,sin4h; //sin2d,sin3d,sin4d;
	/* --- equatorial corrections ---*/
	tand=tan(dec);
	cosh=cos(ha);
	sinh=sin(ha);
	cosd=cos(dec);
	sind=sin(dec);
	cosl=cos(latrad);
	sinl=sin(latrad);
	secd=1./cos(dec);
	cos2h=cos(2.*ha);
	sin2h=sin(2.*ha);
	cos3h=cos(3.*ha);
	sin3h=sin(3.*ha);
	cos4h=cos(4.*ha);
	sin4h=sin(4.*ha);
	/*
	cos2d=cos(2.*dec);
	sin2d=sin(2.*dec);
	cos3d=cos(3.*dec);
	sin3d=sin(3.*dec);
	cos4d=cos(4.*dec);
	sin4d=sin(4.*dec);
	*/
	kk=0;
	for (k=0;k<nb_coef;k++) {
		matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.;
		if (strcmp(vecy[k].type,"IH")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=1.; }
		if (strcmp(vecy[k].type,"ID")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"NP")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=tand; }
		if (strcmp(vecy[k].type,"CH")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=secd; }
		if (strcmp(vecy[k].type,"ME")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh*tand; }
		if (strcmp(vecy[k].type,"MA")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cosh*tand; }
		if (strcmp(vecy[k].type,"TF")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosl*sinh/cosd; }
		if (strcmp(vecy[k].type,"FO")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
// modif michel
      //if (strcmp(vecy[k].type,"DAF")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosl*cosh+sinl*tand; }
		//if (strcmp(vecy[k].type,"HF")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh/cosd; }
		if (strcmp(vecy[k].type,"DAF")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-cosl*cosh-sinl*tand; }
		if (strcmp(vecy[k].type,"HF")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=-sinh/cosd; }
		if (strcmp(vecy[k].type,"TX")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=(cosl*sinh*cosd)/(sind*sinl+cosd*cosh*cosl); }
		if (strcmp(vecy[k].type,"DNP")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh*tand; }
		if (strcmp(vecy[k].type,"EHS")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh*sinh*tand; }
		if (strcmp(vecy[k].type,"EHC")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh*cosh*tand; }
		if (strcmp(vecy[k].type,"HCEC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosh; }
		if (strcmp(vecy[k].type,"DCEC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"HCES")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh; }
		if (strcmp(vecy[k].type,"DCES")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"D2HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"D3HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"D4HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"D2HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"D3HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"D4HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X1HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh/cosd; }
		if (strcmp(vecy[k].type,"X2HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin2h/cosd; }
		if (strcmp(vecy[k].type,"X3HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin3h/cosd; }
		if (strcmp(vecy[k].type,"X4HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin4h/cosd; }
		if (strcmp(vecy[k].type,"X1HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosh/cosd; }
		if (strcmp(vecy[k].type,"X2HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos2h/cosd; }
		if (strcmp(vecy[k].type,"X3HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos3h/cosd; }
		if (strcmp(vecy[k].type,"X4HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos4h/cosd; }
		kk++;
	}
	dha=0.;
	for (k=0;k<nb_coef;k++) {
		dha+=(matx[k].coef*vecy[k].coef);
	}
	return dha;
}

/****************************************************************************/
/* mc_modpoi_addobs_dec                                                     */
/****************************************************************************/
/**	Fill a line of the matrix of the pointing model
 * @param ha is the hour angle (radian).
 * @param dec is the declination (radian).
 * @param latrad is the observatory latitude (radian).
 * @param nb_coef is number of model terms.
 * @param vecy is vector which defines model terms.
 * @param matx is matrix line corresponding to this star.
*/
/****************************************************************************/
double mc_modpoi_addobs_dec(double ha,double dec,double latrad, int nb_coef,mc_modpoi_vecy *vecy,mc_modpoi_matx *matx) {
	int k,kk;
	double ddec;
	double cosh,sinh,cosd,sind,cosl,sinl; //tand,secd;
	double /*cos2h,cos3h,cos4h,*/ cos2d,cos3d,cos4d;
	double /*sin2h,sin3h,sin4h,*/ sin2d,sin3d,sin4d;
	/* --- equatorial corrections ---*/
	//tand=tan(dec);
	cosh=cos(ha);
	sinh=sin(ha);
	cosd=cos(dec);
	sind=sin(dec);
	cosl=cos(latrad);
	sinl=sin(latrad);
	//secd=1./cos(dec);
	/*
	cos2h=cos(2.*ha);
	sin2h=sin(2.*ha);
	cos3h=cos(3.*ha);
	sin3h=sin(3.*ha);
	cos4h=cos(4.*ha);
	sin4h=sin(4.*ha);
	*/
	cos2d=cos(2.*dec);
	sin2d=sin(2.*dec);
	cos3d=cos(3.*dec);
	sin3d=sin(3.*dec);
	cos4d=cos(4.*dec);
	sin4d=sin(4.*dec);
	kk=0;
	for (k=0;k<nb_coef;k++) {
		matx[kk].kl=1 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.;
		if (strcmp(vecy[k].type,"IH")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ID")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=1.; }
		if (strcmp(vecy[k].type,"NP")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"CH")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"ME")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosh; }
		if (strcmp(vecy[k].type,"MA")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh; }
		if (strcmp(vecy[k].type,"TF")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosl*cosh*sind-sinl*cosd; }
		if (strcmp(vecy[k].type,"FO")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosh; }
		if (strcmp(vecy[k].type,"DAF")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"HF")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"TX")==0)    { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=(cosl*cosh*sind-sinl*cosd)/(sind*sinl+cosd*cosh*cosl); }
		if (strcmp(vecy[k].type,"DNP")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0; }
		if (strcmp(vecy[k].type,"EHS")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sinh*cosh; }
		if (strcmp(vecy[k].type,"EHC")==0)   { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosh*cosh; }
		if (strcmp(vecy[k].type,"HCEC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"DCEC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cosd; }
		if (strcmp(vecy[k].type,"HCES")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"DCES")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sind; }
		if (strcmp(vecy[k].type,"D2HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin2d; }
		if (strcmp(vecy[k].type,"D3HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin3d; }
		if (strcmp(vecy[k].type,"D4HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=sin4d; }
		if (strcmp(vecy[k].type,"D2HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos2d; }
		if (strcmp(vecy[k].type,"D3HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos3d; }
		if (strcmp(vecy[k].type,"D4HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=cos4d; }
		if (strcmp(vecy[k].type,"X1HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X2HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X3HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X4HS")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X1HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X2HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X3HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		if (strcmp(vecy[k].type,"X4HC")==0)  { matx[kk].kl=0 ; matx[kk].kc=vecy[k].k ; matx[kk].coef=0.; }
		kk++;
	}
	ddec=0.;
	for (k=0;k<nb_coef;k++) {
		ddec+=(matx[k].coef*vecy[k].coef);
	}
	return ddec;
}
