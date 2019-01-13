/* mc_macr2.c
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
/* Macro fonctions a appeler de l'exterieur                                */
/***************************************************************************/
#include "mc.h"

void mc_baryvel(double jj,double longmpc,double rhocosphip,double rhosinphip, double asd0, double dec0, double *x_helio,double *y_helio,double *z_helio, double *vx_helio,double *vy_helio,double *vz_helio, double *v_helio, double *hjd, double *x_bary,double *y_bary,double *z_bary, double *vx_bary,double *vy_bary,double *vz_bary, double *v_bary,double *bjd)
/***************************************************************************/
/* Calcule la vitesse de la Terre a la date                                */
/***************************************************************************/
/* jj est la date julienne en TT                                           */
/* asd0,dec0 sont les coordonnees moyennes a la date                       */
/*                                                                         */
/* v estr la valeur a ajouter a la vitesse observee                        */
/* pour la corriger de la vitesse de revolution de la Terre                */
/* autour du barycentre du systeme solaire.                                */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,epsmoy,epsnut,dpsi,deps,xs,ys,zs;
	double xp,yp,zp,xx,yy,zz,d,djd;
   double dxeq,dyeq,dzeq;
   double jjs[3],xx_helio[3],yy_helio[3],zz_helio[3],djj; // asd,dec,delta;
   double xx_bary[3],yy_bary[3],zz_bary[3];
	double dx=0,dy=0,dz=0,ratio;
   int k;
	int kp,np,planetes[10];
	double ratios[10],mass_total=0;

	kp=0;
	planetes[kp]=JUPITER ; 	ratios[kp]=MASS_JUPITER ; kp++ ;
	planetes[kp]=SATURNE; 	ratios[kp]=MASS_SATURNE ; kp++ ;
	planetes[kp]=NEPTUNE ; 	ratios[kp]=MASS_NEPTUNE ; kp++ ;
	planetes[kp]=URANUS ; 	ratios[kp]=MASS_URANUS ; kp++ ;
	/*
	planetes[kp]=TERRE ; 	ratios[kp]=MASS_TERRE ; kp++ ;
	planetes[kp]=VENUS ; 	ratios[kp]=MASS_VENUS ; kp++ ;
	planetes[kp]=MARS ; 	   ratios[kp]=MASS_MARS ; kp++ ;
	planetes[kp]=MERCURE ; 	ratios[kp]=MASS_MERCURE ; kp++ ;
	*/
	np=kp;
	mass_total=MASS_SOLEIL;
	for (kp=0;kp<np;kp++) {
		mass_total+=ratios[kp];
	}
	for (kp=0;kp<np;kp++) {
		ratios[kp]/=mass_total;
	}

   djj=5e-5;
   jjs[0]=jj;
   jjs[1]=jj-djj;
   jjs[2]=jj+djj;
   for (k=0;k<1;k++) {
      jjd=jjs[k];
		/*--- calcul de la precession ---*/
      mc_obliqmoy(jjd,&epsmoy);
		/*--- calcul de la nutation ---*/
      mc_nutation(jjd,1,&dpsi,&deps);
      epsnut=epsmoy+deps;
		/*--- coordonnees moyennes ---*/
      mc_jd2lbr1a(jjd,llp,mmp,uup);
      mc_jd2lbr1b(jjd,TERRE,llp,mmp,uup,&ls,&bs,&rs);
		/*--- correction de nutation ---*/
      ls+=dpsi;
      mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
      mc_xyzec2eq(xs,ys,zs,epsnut,&xs,&ys,&zs);
      /*--- correction de la parallaxe ---*/
      mc_paraldxyzeq(jjd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
      xs+=dxeq;
      ys+=dyeq;
      zs+=dzeq;
		/* --- correction barycentrique des planetes du systeme solaire ---*/
		dx=0;
		dy=0;
		dz=0;
		/* --- on stocke le resultat ---*/
      xx_helio[k]=xs;
      yy_helio[k]=ys;
      zz_helio[k]=zs;
      xx_bary[k]=xs-dx;
      yy_bary[k]=ys-dy;
      zz_bary[k]=zs-dz;
   }
	xx=cos(asd0)*cos(dec0);
	yy=sin(asd0)*cos(dec0);
	zz=sin(dec0);
   d=xx_helio[0]*xx+yy_helio[0]*yy+zz_helio[0]*zz;
   djd=d*UA/CLIGHT/86400.;
	*hjd=djd+jj;
   jjs[0]=djd+jj;
   jjs[1]=djd+jj-djj;
   jjs[2]=djd+jj+djj;
   for (k=0;k<3;k++) {
      jjd=jjs[k];
		/*--- calcul de la precession ---*/
      mc_obliqmoy(jjd,&epsmoy);
		/*--- calcul de la nutation ---*/
      mc_nutation(jjd,1,&dpsi,&deps);
      epsnut=epsmoy+deps;
		/*--- coordonnees moyennes ---*/
      mc_jd2lbr1a(jjd,llp,mmp,uup);
      mc_jd2lbr1b(jjd,TERRE,llp,mmp,uup,&ls,&bs,&rs);
		/*--- correction de nutation ---*/
      ls+=dpsi;
      mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
      mc_xyzec2eq(xs,ys,zs,epsnut,&xs,&ys,&zs);
      /*--- correction de la parallaxe ---*/
      mc_paraldxyzeq(jjd-djd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
      xs+=dxeq;
      ys+=dyeq;
      zs+=dzeq;
		/* --- correction barycentrique des planetes du systeme solaire ---*/
		dx=0;
		dy=0;
		dz=0;
		for (kp=0;kp<np;kp++) {
			mc_jd2lbr1b(jjd,planetes[kp],llp,mmp,uup,&ls,&bs,&rs);
			/*--- correction de nutation ---*/
			ls+=dpsi;
			mc_lbr2xyz(ls,bs,rs,&xp,&yp,&zp);
			mc_xyzec2eq(xp,yp,zp,epsnut,&xp,&yp,&zp);
			/*--- barycentre ---*/
			ratio=ratios[kp];
			dx+=(xp*ratio);
			dy+=(yp*ratio);
			dz+=(xp*ratio);
		}
		/* --- lune ---*/
		/*
		mc_jd2lbr1b(jjd,LUNE,llp,mmp,uup,&ls,&bs,&rs);
		ls+=dpsi;
		mc_lbr2xyz(ls,bs,rs,&xp,&yp,&zp);
		mc_xyzec2eq(xp,yp,zp,epsnut,&xp,&yp,&zp);
		ratio=7.3477e22/(7.3477e22+MASS_TERRE);
		dx+=(xp*ratio);
		dy+=(yp*ratio);
		dz+=(xp*ratio);
		*/
		/* --- on stocke le resultat ---*/
      xx_helio[k]=xs;
      yy_helio[k]=ys;
      zz_helio[k]=zs;
      xx_bary[k]=xs-dx;
      yy_bary[k]=ys-dy;
      zz_bary[k]=zs-dz;
   }
   *x_helio=xx_helio[0];
   *y_helio=yy_helio[0];
   *z_helio=zz_helio[0];
   *vx_helio=(xx_helio[2]-xx_helio[1])/2./djj;
   *vy_helio=(yy_helio[2]-yy_helio[1])/2./djj;
   *vz_helio=(zz_helio[2]-zz_helio[1])/2./djj;
   *x_bary=xx_bary[0];
   *y_bary=yy_bary[0];
   *z_bary=zz_bary[0];
   *vx_bary=(xx_bary[2]-xx_bary[1])/2./djj;
   *vy_bary=(yy_bary[2]-yy_bary[1])/2./djj;
   *vz_bary=(zz_bary[2]-zz_bary[1])/2./djj;
   /* vitesse projetee vers l'astre pointe mc_baryvel 1994-02-15T00:00 19h50m46.77s 8d52m3.5s */
	/* mc_baryvel [mc_date2tt {1995-11-23T10:37:37.0}] 8h13m29.3s 29d02m12s J2000 {GPS 110.8775 W 31.68094 2320} */
	/* Heliocentric Julian date: 2450044.94573 */
	/* gbcvel = 25.2207  ghcvel = 25.2165  geovel = 0.0770 */
	/* bcv = 25.2977  hcv = 25.2936 computed  */
   *v_helio =(*vx_helio)*cos(dec0)*cos(asd0) + (*vy_helio)*cos(dec0)*sin(asd0) + (*vz_helio)*sin(dec0);
   *v_bary  =(*vx_bary)*cos(dec0)*cos(asd0) + (*vy_bary)*cos(dec0)*sin(asd0) + (*vz_bary)*sin(dec0);
   d=xx_bary[0]*xx+yy_bary[0]*yy+zz_bary[0]*zz;
   djd=d*UA/CLIGHT/86400.;
	*bjd=djd+jj;
}

void mc_rvcor(double asd0, double dec0, double equinox, int reference, double *v)
/***************************************************************************/
/* Calcule la correction de vitesse KLSR (Kinetic local standard of rest)  */
/* Calcule la correction de vitesse DLSR (Dynamic local standard of rest)  */
/* Calcule la correction de vitesse GALC (Galactocentric)                  */
/* Calcule la correction de vitesse LOG (Local Group)                      */
/* Calcule la correction de vitesse COSM (Cosmic)                          */
/***************************************************************************/
/* v est  la valeur a ajouter a la vitesse observee                        */
/***************************************************************************/
/* KLSR  Gordon (1975)                                                     */
/*  "Computer Programs for Radio Astronomy," by M.A.Gordon, page 281, in   */
/*  " Methods of Experimental Physics: Volume 12: Astrophysics, Part C:    */
/*  Radio Observations", ed. M.L.Meeks, Academic Press 1976.               */
/*                                                                         */
/* DLSR  Delhaye (1965)                                                    */
/*  pages 73-74, in  "Stars and Stellar Systems, Volume 5: Galactic        */
/*  Structure", ed. Blaauw and Schmidt, Univ. of Chicago Press (1965).     */
/*                                                                         */
/* GALC  Kerr and Lynden-Bell (1986)                                       */
/*  Mon.Not.Roy.Astron.Soc. vol.221, p.1023 (1986)                         */
/*                                                                         */
/* LOG  Yahil et al. 1977                                                  */
/*  Astrophys.J. vol.217,  p.903, November 1, 1977.                        */
/*                                                                         */
/* COSM  Kogut et al. 1993                                                 */
/*  Astrophys.J. vol.419,  p.1, December 10, 1993.                         */
/***************************************************************************/
{
   double jjfrom,jjto,as,ds,asd2,dec2,vr;
   jjfrom=equinox;
   /* --- constantes ---*/
   jjto=J2000;
   as=270.959542*(DR);
   ds=30.004667*(DR);
   vr=20.0; /* km/s */
   if (reference==RV_KLSR) {
      /* --- constantes ---*/
      jjto=J2000;
      as=270.959542*(DR);
      ds=30.004667*(DR);
      vr=20.0; /* km/s */
   } else if (reference==RV_DLSR) {
      /* --- constantes ---*/
      jjto=J2000;
      as=267.494446*(DR);
      ds=28.117767*(DR);
      vr=16.55294; /* km/s */
   } else if (reference==RV_GALC) {
      /* --- constantes ---*/
      jjto=J2000;
      as=313.861542*(DR);
      ds=47.823194*(DR);
      vr=232.3; /* km/s */
   } else if (reference==RV_LOG) {
      /* --- constantes ---*/
      jjto=J2000;
      as=343.310625*(DR);
      ds=51.708944*(DR);
      vr=308.; /* km/s */
   } else if (reference==RV_COSM) {
      /* --- constantes ---*/
      jjto=J2000;
      as=168.235000*(DR);
      ds=-6.963889*(DR);
      vr=369.5; /* km/s */
   }
   /* --- calcul de la precession ---*/
   mc_precad(jjfrom,asd0,dec0,jjto,&asd2,&dec2);
   /* --- calcul ---*/
   *v=vr*(cos(as)*cos(ds)*cos(asd2)*cos(dec2)+sin(as)*cos(ds)*sin(asd2)*cos(dec2)+sin(ds)*sin(dec2));
}

void mc_adastrom(double jj, struct elemorb elem, double equinoxe, double *asd, double *dec, double *delta,double *rr,double *rsol)
/***************************************************************************/
/* Calcul de l'asd, dec et distance a jj donne rapporte a un equinoxe      */
/* pour un astre defini par ses elements d'orbite.                         */
/***************************************************************************/
/* coordonnees astrometriques a l'instant jj a partir des elements d'orb.  */
/* equinoxe : instant de l'equinoxe de reference (souvent J2000)           */
/* Il n'y a pas de correction de nutation et d'aberrations autre que le    */
/* temps de parcours de la lumiere (Meeus page 216)                        */
/***************************************************************************/
/*
   EXEMPLE 32.b de la page 217 du Meeus
   elem.m0=0;
   mc_date_jd(1990,10,28.54502,&jjq);
   elem.jj_m0=jjq;
   elem.e=0.8502196;
   elem.q=2.2091404*(1-elem.e);
   elem.jj_perihelie=jjq;
   elem.i=11.94524*DR;
   elem.o=334.75006*DR;
   elem.w=186.23352*DR;
   elem.jj_equinoxe=J2000;
   mc_date_jd(1990,10,6.,&jjd);
   elem.jj_epoque=jjd;
   mc_date_jd(1990,10,6.,&jjd);
   mc_adastrom(jjd,elem,J2000,&asd,&dec,&delta,&r);
*/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,xs,ys,zs;
   double r,x,y,z,m,v,jjda;
   struct pqw elempq;
   jjd=jj;

   /*--- constantes equatoriales ---*/
   mc_obliqmoy(equinoxe,&eps);

   /*--- precession et conversion des elements ---*/
   mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
   mc_elempqec(elem,&elempq);
   mc_elempqeq(elempq,eps,&elempq);

   /*--- soleil ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
   mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */

   /*--- planete ---*/
   mc_anomoy(elem,jjd,&m);
   mc_anovrair(elem,m,&v,&r);
   mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
   mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
   mc_xyz2add(x,y,z,asd,dec,delta);

   /* --- planete corrigee de l'aberration de la lumiere ---*/
   mc_aberpla(jjd,*delta,&jjda);
   mc_anomoy(elem,jjda,&m);
   mc_anovrair(elem,m,&v,&r);
   mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
   mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);

   /* --- coord. spheriques ---*/
   mc_xyz2add(x,y,z,asd,dec,delta);
   *rr=r;
   *rsol=rs;
}

void mc_adasaap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, struct elemorb elem, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr)
/***************************************************************************/
/* Calcul de l'asd, dec et distance a jj donne rapporte a un equinoxe      */
/* pour un astre defini par ses elements d'orbite.                         */
/***************************************************************************/
/* coordonnees astrometriques a l'instant jj a partir des elements d'orb.  */
/* equinoxe : instant de l'equinoxe de reference (souvent J2000)           */
/* Il n'y a pas de correction de nutation et d'aberrations autre que le    */
/* temps de parcours de la lumiere (Meeus page 216)                        */
/***************************************************************************/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,xs,ys,zs;
   double r,x,y,z,m,v,jjda,xg,yg,zg,l,b,dpsi,deps;
   struct pqw elempq;
   double dxeq=0.,dyeq=0.,dzeq=0.;
   /*FILE *fichier_out;*/
   jjd=jj;

   /*--- constantes equatoriales ---*/
   mc_obliqmoy(equinoxe,&eps);

   /*--- precession et conversion des elements ---*/
   mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
   mc_elempqec(elem,&elempq);
   mc_elempqeq(elempq,eps,&elempq);

   /*--- soleil ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
   mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */

   /*--- correction de la parallaxe ---*/
   mc_paraldxyzeq(jjd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
   xs-=dxeq;
   ys-=dyeq;
   zs-=dzeq;

   /*--- planete ---*/
   mc_anomoy(elem,jjd,&m);
   mc_anovrair(elem,m,&v,&r);
   mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
   mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
   mc_xyz2add(x,y,z,asd,dec,delta);

   /* --- planete corrigee de l'aberration de la lumiere ---*/
   mc_aberpla(jjd,*delta,&jjda);
   mc_anomoy(elem,jjda,&m);
   mc_anovrair(elem,m,&v,&r);
   *rr=r;
   mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
   mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);

   /*--- correction de la nutation ---*/
	if (astrometric==0) {
		mc_xyzeq2ec(x,y,z,eps,&xg,&yg,&zg);
		mc_xyz2lbr(xg,yg,zg,&l,&b,&r);
		mc_nutation(jjd,1,&dpsi,&deps);
		l+=dpsi;
		eps+=deps;
		mc_lbr2xyz(l,b,r,&xg,&yg,&zg);
		mc_xyzec2eq(xg,yg,zg,eps,&x,&y,&z);
	}

   /* --- coord. spheriques ---*/
   mc_xyz2add(x,y,z,asd,dec,delta);

   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_aberration_annuelle(jjd,*asd,*dec,asd,dec,1);
	}

   /* --- parametres elong et magnitude ---*/
   r=*rr;
   mc_elonphas(r,rs,*delta,elong,phase);
   mc_magaster(r,*delta,*phase,elem.h,elem.g,mag);
   *diamapp=0.;

}

void mc_xyzasaaphelio(double jj,double jjutc, double equinoxe, int astrometric,double longmpc,double rhocosphip,double rhosinphip, struct elemorb elem, int frame, double *xearth,double *yearth,double *zearth,double *xaster,double *yaster,double *zaster, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr)
/***************************************************************************/
/* Calcul de coord. cartesiennes heliocentriquesa jj donne rapporte a un equinoxe         */
/* pour un astre defini par ses elements d'orbite.                         */
/***************************************************************************/
/* coordonnees astrometriques a l'instant jj a partir des elements d'orb.  */
/* equinoxe : instant de l'equinoxe de reference (souvent J2000)           */
/* Il n'y a pas de correction de nutation et d'aberrations autre que le    */
/* temps de parcours de la lumiere (Meeus page 216)                        */
/***************************************************************************/
/* frame=0 for ecliptic J2000.0 */
/* frame=1 for equatorial J2000.0 */
/* si *diamapp=0 alors l'astre est dans l'ombre de la Terre */
/* si *diamapp=1 alors l'astre est completement eclaire */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,xs,ys,zs;
   double r,x,y,z,m,v,jjda;
   struct pqw elempq;
   double dxeq=0.,dyeq=0.,dzeq=0.;
   double xsgeo,ysgeo,zsgeo,xlgeo,ylgeo,zlgeo;
   double r1,r2;
   double reqter=6378.14/UA*1e3,reqsol=696000./UA*1e3;
   double da1,da2,R1,R2,rho,t1,t2,cosa,aire,airetot,ts,tt;
   int cas=0;

   /*FILE *fichier_out;*/
   jjd=jj;

   if (elem.type==4) {
      /*--- frame = equatorial geocentric J2000.0 ---*/
      mc_xyzgeoelem(jj,jj,J2000,1,elem,longmpc,rhocosphip,rhosinphip,0,xaster,yaster,zaster,xearth,yearth,zearth,&xsgeo,&ysgeo,&zsgeo,&xlgeo,&ylgeo,&zlgeo);
      r= sqrt( (*xaster-xsgeo)*(*xaster-xsgeo) + (*yaster-ysgeo)*(*yaster-ysgeo) + (*zaster-zsgeo)*(*zaster-zsgeo) );
      rs=sqrt( (*xearth-xsgeo)*(*xearth-xsgeo) + (*yearth-ysgeo)*(*yearth-ysgeo) + (*zearth-zsgeo)*(*zearth-zsgeo) );
      /* --- coord. spheriques locales ---*/
      mc_xyz2add( (*xaster-*xearth), (*yaster-*yearth), (*zaster-*zearth),asd,dec,delta);
      mc_paraldxyzeq(jjd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
      /* --- geo-> helio ---*/
      mc_he2ge(*xaster,*yaster,*zaster,-xsgeo,-ysgeo,-zsgeo,xaster,yaster,zaster);
      mc_he2ge(*xearth,*yearth,*zearth,-xsgeo,-ysgeo,-zsgeo,xearth,yearth,zearth);
      if (frame==0) {
         mc_obliqmoy(jjd,&eps);
         mc_xyzeq2ec(*xaster,*yaster,*zaster,eps,xaster,yaster,zaster);
         mc_xyzeq2ec(*xearth,*yearth,*zearth,eps,xearth,yearth,zearth);
      }

      /* --- parametres elong et magnitude ---*/
      *rr=r;
      mc_elonphas(r,rs,*delta,elong,phase);
      mc_magaster(r,*delta,*phase,elem.h,elem.g,mag);
      *diamapp=1.;

   } else {
      /*--- constantes equatoriales ---*/
      mc_obliqmoy(equinoxe,&eps);

      /*--- precession et conversion des elements ---*/
      mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
      mc_elempqec(elem,&elempq);
      mc_elempqeq(elempq,eps,&elempq);

      /*--- soleil ---*/
      mc_jd2lbr1a(jjd,llp,mmp,uup);
      mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
      mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
      mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
      mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */

      /*--- correction de la parallaxe ---*/
      mc_paraldxyzeq(jjd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
      xs-=dxeq;
      ys-=dyeq;
      zs-=dzeq;

      /*--- planete ---*/
      mc_anomoy(elem,jjd,&m);
      mc_anovrair(elem,m,&v,&r);
      mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
      mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
      mc_xyz2add(x,y,z,asd,dec,delta);

      /* --- planete corrigee de l'aberration de la lumiere ---*/
      mc_aberpla(jjd,*delta,&jjda);
      mc_anomoy(elem,jjda,&m);
      mc_anovrair(elem,m,&v,&r);
      *rr=r;
      mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */

      /* --- heliocentric cartesian coordinates in the equatorial J2000.0 frame ---*/
      *xearth=-xs;
      *yearth=-ys;
      *zearth=-zs;
      if (frame==0) {
         mc_xyzeq2ec(*xearth,*yearth,*zearth,eps,xearth,yearth,zearth); /* ecliptic J2000.0 */
      }
      *xaster=x; 
      *yaster=y;
      *zaster=z;
      if (frame==0) {
         mc_xyzeq2ec(*xaster,*yaster,*zaster,eps,xaster,yaster,zaster); /* ecliptic J2000.0 */
      }

      /* --- geocentric cartesian coordinates ---*/
      mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);

      /* --- coord. spheriques ---*/
      mc_xyz2add(x,y,z,asd,dec,delta);

      /* --- parametres elong et magnitude ---*/
      r=*rr;
      mc_elonphas(r,rs,*delta,elong,phase);
      mc_magaster(r,*delta,*phase,elem.h,elem.g,mag);
      *diamapp=1.;
   }

   /* --- case of eclipses ---*/
   if (*delta<0.015) {

      /*--- correction de la parallaxe topo -> geo ---*/
      if (frame==0) {
         mc_xyzeq2ec(*xearth,*yearth,*zearth,-eps,xearth,yearth,zearth); /* ecliptic J2000.0 */
      }
      x=*xearth-dxeq;
      y=*yearth-dyeq;
      z=*zearth-dzeq;

      /*--- soleil ---*/
      mc_jd2lbr1a(jjd,llp,mmp,uup);
      mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
      mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
      mc_obliqmoy(jjd,&eps);
      mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
      mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */
      xs*=-1;
      ys*=-1;
      zs*=-1;

      r1=sqrt((x-*xaster)*(x-*xaster)+(y-*yaster)*(y-*yaster)+(z-*zaster)*(z-*zaster));
      r2=sqrt((*xaster)*(*xaster)+(*yaster)*(*yaster)+(*zaster)*(*zaster));
      cosa=-((x-*xaster)*(*xaster)+(y-*yaster)*(*yaster)+(z-*zaster)*(*zaster))/r1/r2;

		tt=mc_asin(reqter/r1);
		ts=mc_asin(reqsol/r2);

		if ((reqter/r1)>(reqsol/r2)) {
			R1=tan(tt);;
			R2=tan(ts);
			cas=0;
			airetot=PI*R2*R2; // aire du disque solaire projete
		} else {
			R1=tan(ts);
			R2=tan(tt);
			cas=1;
			airetot=PI*R1*R1; // aire du disque solaire projete
		}
		rho=fabs(tan(mc_acos(cosa)));
      t2=2*mc_acos((R2*R2+rho*rho-R1*R1)/2/R2/rho);
      t1=2*mc_acos((R1*R1+rho*rho-R2*R2)/2/R1/rho);
      da1=0.5*R1*R1*(t1-sin(t1));
      da2=0.5*R2*R2*(t2-sin(t2));
      if (rho<(R1-R2)) {
         if (cas==0) {
            aire=0;
         } else {
            aire=PI*R1*R1-PI*R2*R2;
         }
      } else if (rho<sqrt(R1*R1-R2*R2)) {
         if (cas==0) {
            aire=da2-da1;
         } else {
            aire=PI*R1*R1-PI*R2*R2+da2-da1;
         }
      } else if (rho<(R1+R2)) {
         if (cas==0) {
            aire=PI*R2*R2-da1-da2;
         } else {
            aire=PI*R1*R1-da1-da2;
         }
      } else {
         if (cas==0) {
            aire=PI*R2*R2;
         } else {
            aire=PI*R1*R1;
         }
      }
      *diamapp=(aire/airetot);
   }

}


void mc_adplaap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun)
/***************************************************************************/
/* Calcul de l'asd, dec et distance apparentes d'une planete a jj donne.   */
/***************************************************************************/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,/*dpsi,deps,*/xs,ys,zs;
   double l,b,r,x,y,z,xg,yg,zg;
   double dxeq,dyeq,dzeq;
	double dpsi,deps;
   jjd=jj;

   /*--- soleil ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);

   /*--- correction de la parallaxe ---*/
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_paraldxyzeq(jjd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
   xs-=dxeq;
   ys-=dyeq;
   zs-=dzeq;
   mc_xyzeq2ec(xs,ys,zs,eps,&xs,&ys,&zs);

   /*--- planete ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,planete,llp,mmp,uup,&l,&b,&r);
   mc_lbr2xyz(l,b,r,&x,&y,&z);
   mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
   mc_xyzec2eq(x,y,z,eps,&x,&y,&z);
   mc_xyz2add(x,y,z,asd,dec,delta);

   /*--- planete corrigee de l'aberration de la lumiere ---*/
   mc_aberpla(jjd,*delta,&jjd);
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,planete,llp,mmp,uup,&l,&b,&r);
   *rr=r;
   mc_lbr2xyz(l,b,r,&x,&y,&z);
   mc_he2ge(x,y,z,xs,ys,zs,&xg,&yg,&zg);
   mc_obliqmoy(jjd,&eps);

   /*--- correction de la nutation ---*/
	if (astrometric==0) {
		mc_xyz2lbr(xg,yg,zg,&l,&b,&r);
		mc_nutation(jjd,1,&dpsi,&deps);
		l+=dpsi;
		eps+=deps;
		mc_lbr2xyz(l,b,r,&xg,&yg,&zg);
	}

   /*--- coord. spheriques ---*/
   mc_xyzec2eq(xg,yg,zg,eps,&xg,&yg,&zg);
   mc_xyz2add(xg,yg,zg,asd,dec,delta);

   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_aberration_annuelle(jjd,*asd,*dec,asd,dec,1);
	}

   /*--- correction de la precession ---*/
   if (planete!=PLUTON) {
      mc_precad(jjd,*asd,*dec,equinoxe,asd,dec); /*equatoriale J2000*/
   }

   /* --- parametres elong et magnitude ---*/
   r=*rr;
   mc_elonphas(r,rs,*delta,elong,phase);
   mc_magplanet(r,*delta,planete,*phase,l,b,mag,diamapp);

   /*--- coord. helio equatoriales ---*/
   mc_xyzec2eq(x,y,z,eps,&x,&y,&z);
   mc_physephem(jjd,planete,xg,yg,zg,x,y,z,diamapp_equ,diamapp_pol,
      long1,long2,long3,lati,posangle_north,posangle_sun,long1_sun,lati_sun);
}

void mc_adlunap(int planete, double jj, double jjutc, double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip,double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun)
/***************************************************************************/
/* Calcul de l'asd, dec et distance apparentes de la Lune a jj donne.      */
/***************************************************************************/
/* 
mc_ephem moon 1992-04-12T00:00:00 {RA DEC DELTA PHASE MAG} 
*/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,dpsi,deps,xs,ys,zs;
   double l,b,r,x,y,z;
   double dxeq,dyeq,dzeq;
   double jjds,asds,decs,limb,ttminusutc;
   jjd=jj;
	ttminusutc=jj-jjutc;

   /*planete=LUNE ou LUNE_ELP;*/

   /*--- soleil ---*/
   *delta=1.; /* correction de l'abberation planetaire a priori */
   mc_aberpla(jjd,*delta,&jjds);
   mc_jd2lbr1a(jjds,llp,mmp,uup);
   mc_jd2lbr1b(jjds,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);

   /*--- soleil : correction de la parallaxe ---*/
   mc_obliqmoy(jjds,&eps);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_paraldxyzeq(jjds-ttminusutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
   xs-=dxeq;
   ys-=dyeq;
   zs-=dzeq;
   mc_xyzeq2ec(xs,ys,zs,eps,&xs,&ys,&zs);

   /*--- soleil : coordonnes asd,dec du Soleil ---*/
	if (astrometric==0) {
		mc_xyz2lbr(xs,ys,zs,&ls,&bs,&rs);
		mc_nutation(jjd,1,&dpsi,&deps);
		ls+=dpsi;
		eps+=deps;
		mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
	}
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_xyz2add(xs,ys,zs,&asds,&decs,delta);

   /* a ce niveau on retient (asds,decs) pour le calcul de la phase */
   /* On recommence tout le calcul sans abberation pour la position */
	/* dans le repere heliocentrique */

   /*--- Terre ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&r);
   mc_lbr2xyz(ls,bs,r,&xs,&ys,&zs);

   /*--- Terre : correction de la parallaxe ---*/
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_paraldxyzeq(jjd-ttminusutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
   xs-=dxeq;
   ys-=dyeq;
   zs-=dzeq;
   mc_xyzeq2ec(xs,ys,zs,eps,&xs,&ys,&zs);

   /*--- Terre : coordonnes asd,dec du Soleil ---*/
	if (astrometric==0) {
		mc_xyz2lbr(xs,ys,zs,&ls,&bs,&r);
		mc_nutation(jjd,1,&dpsi,&deps);
		ls+=dpsi;
		eps+=deps;
		mc_lbr2xyz(ls,bs,r,&xs,&ys,&zs);
	}
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_xyz2add(xs,ys,zs,asd,dec,delta);

   /* ici on ne garde que (xs,ys,zs,delta) pour la position geocentrique */

   /*--- LUNE : planete (coordonnees ecliptiques astrometriques a la date) ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,planete,llp,mmp,uup,&l,&b,&r);
   mc_lbr2xyz(l,b,r,&x,&y,&z);
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(x,y,z,eps,&x,&y,&z);
   mc_xyz2add(x,y,z,asd,dec,delta);

   /*--- planete corrigee de l'aberration de la lumiere ---*/
   mc_aberpla(jjd,*delta,&jjd);
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,planete,llp,mmp,uup,&l,&b,&r);
   mc_lbr2xyz(l,b,r,&x,&y,&z);
   mc_obliqmoy(jjd,&eps);

   /*--- correction de la nutation ---*/
	if (astrometric==0) {
		mc_xyz2lbr(x,y,z,&l,&b,&r);
		mc_nutation(jjd,1,&dpsi,&deps);
		l+=dpsi;
		eps+=deps;
		mc_lbr2xyz(l,b,r,&x,&y,&z);
	}

   /*--- correction de la parallaxe ---*/
   mc_xyzec2eq(x,y,z,eps,&x,&y,&z);
   x-=dxeq;
   y-=dyeq;
   z-=dzeq;

   /*--- coord. spheriques ---*/
   mc_xyz2add(x,y,z,asd,dec,delta);

   /* --- parametres physiques ---*/
   if (*long1==0.) {
      *long1=longmpc;
      *long2=rhocosphip;
      *long3=rhosinphip;
      mc_physephem(jjd,planete,x,y,z,0.,0.,0.,diamapp_equ,diamapp_pol,
      long1,long2,long3,lati,posangle_north,posangle_sun,long1_sun,lati_sun);
   }

   /* --- parametres elong et magnitude ---*/
   mc_he2ge(x,y,z,-xs,-ys,-zs,&x,&y,&z);
   r=sqrt(x*x+y*y+z*z);
   mc_elonphaslimb(*asd,*dec,asds,decs,rs,*delta,elong,phase,&limb);
   *posangle_sun=limb;
   mc_magplanet(r,*delta,planete,*phase,l,b,mag,diamapp);
   *rr=r;

   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_aberration_annuelle(jjd,*asd,*dec,asd,dec,1);
	}

   /*--- correction de la precession ---*/
	mc_precad(jjd,*asd,*dec,equinoxe,asd,dec);
}

void mc_adsolap(double jj,double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun)
/***************************************************************************/
/* Calcul de l'asd, dec et distance apparentes du Soleil a jj donne        */
/***************************************************************************/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,/*dpsi,deps,*/xs,ys,zs;
   double dxeq,dyeq,dzeq;
   int planete;
	double dpsi,deps;

   planete=SOLEIL;
   jjd=jj;

   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_aberpla(jjd,rs,&jjd);
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,0,llp,mmp,uup,&ls,&bs,&rs);
   mc_obliqmoy(jjd,&eps);

   /*--- correction de la parallaxe ---*/
   mc_obliqmoy(jjd,&eps);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_paraldxyzeq(jjd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
   xs-=dxeq;
   ys-=dyeq;
   zs-=dzeq;
   mc_xyzeq2ec(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_xyz2lbr(xs,ys,zs,&ls,&bs,&rs);

	if (astrometric==0) {
		mc_nutation(jjd,1,&dpsi,&deps);
		ls+=dpsi;
		eps+=deps;
	}
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_xyz2add(xs,ys,zs,asd,dec,delta);

   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_aberration_annuelle(jjd,*asd,*dec,asd,dec,1);
	}

   /*--- correction de la precession ---*/
   mc_precad(jjd,*asd,*dec,equinoxe,asd,dec); /* equatoriale J2000 */

   /* --- parametres elong et magnitude ---*/
   *elong=0.;
   *phase=0.;
   mc_magplanet(0,*delta,planete,*phase,ls,bs,mag,diamapp);
   *rr=0.;
   mc_physephem(jjd,planete,xs,ys,zs,0.,0.,0.,diamapp_equ,diamapp_pol,
      long1,long2,long3,lati,posangle_north,posangle_sun,long1_sun,lati_sun);
   *long1_sun=*long1;
   *lati_sun=*lati;

}

void mc_adelemap(double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun,double *sunfraction)
/***************************************************************************/
/* Calcul de l'asd, dec et distance apparentes d'un astre defini par ses elements d'orbite a jj donne.   */
/***************************************************************************/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,/*dpsi,deps,*/xs,ys,zs;
   double /*l,b,*/r,x,y,z/*,xg,yg,zg*/;
   double dxeq,dyeq,dzeq;
   struct pqw elempq;
   double m,v,jjda;
	double xaster,yaster,zaster;
   double da1,da2,R1,R2,rho,t1,t2,cosa,aire,airetot,tt,ts;
   double r1,r2;
   double reqter=6378.14/UA*1e3,reqsol=696000./UA*1e3;
	int cas;
   jjd=jj;

	/* type d'astre (0=inconnu 1=comete 2=asteroide 3=planete 4=geocentrique) */
   if (elem.type!=4) {
      /*--- centre de revolution = Soleil ---*/
      mc_jd2lbr1a(jjd,llp,mmp,uup);
      mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
      mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
      mc_obliqmoy(jjd,&eps);
      mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
   } else {
      /*--- centre de revolution = Terre ---*/
      xs=0.;ys=0.;zs=0.;
   }

   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);

   /*--- coords du centre de revolution geo->topo ---*/
   xs-=dxeq;
   ys-=dyeq;
   zs-=dzeq;

   /*--- precession et conversion des elements ---*/
   mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);

   /*--- perturabtions seculaires dues a l'applatissement de la Terre ---*/
	mc_corearthsatelem(jjd,&elem);
   mc_elempqec(elem,&elempq);
   if (elem.type!=4) {
      mc_elempqeq(elempq,eps,&elempq);
   }

   /*--- astre a observer ---*/
   mc_anomoy(elem,jjd,&m);
   mc_anovrair(elem,m,&v,&r);
   mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
   mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
   mc_xyz2add(x,y,z,asd,dec,delta);

   /* --- astre corrige de l'aberration de la lumiere ---*/
   mc_aberpla(jjd,*delta,&jjda);
   mc_anomoy(elem,jjda,&m);
   mc_anovrair(elem,m,&v,&r);
   mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
   *rr=r;

   /*--- correction centre de revolution -> topo ---*/
   mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);

   /* --- coord. spheriques topocentriques ---*/
   mc_xyz2add(x,y,z,asd,dec,delta);

   /* --- calculation of eclipses ---*/

   /*--- correction de la parallaxe topo -> geo ---*/
	xaster=x+dxeq;
	yaster=y+dyeq;
	zaster=z+dzeq;

   /*--- observer -> geo ---*/
   x=-dxeq;
   y=-dyeq;
   z=-dzeq;

   /*--- soleil geo ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
   mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */
	rs=sqrt(xs*xs+ys*ys+zs*zs);

   r1=sqrt((xaster-x)*(xaster-x)+(yaster-y)*(yaster-y)+(zaster-z)*(zaster-z));
   r2=sqrt((xs-x)*(xs-x)+(ys-y)*(ys-y)+(zs-z)*(zs-z));
   cosa=-((xaster-x)*(xs-x)+(yaster-y)*(ys-y)+(zaster-z)*(zs-z))/r1/r2;
   *elong=mc_acos(cosa);

   r1=sqrt((x-xaster)*(x-xaster)+(y-yaster)*(y-yaster)+(z-zaster)*(z-zaster));
   r2=sqrt((xs-xaster)*(xs-xaster)+(ys-yaster)*(ys-yaster)+(zs-zaster)*(zs-zaster));
   cosa=-((x-xaster)*(xs-xaster)+(y-yaster)*(ys-yaster)+(z-zaster)*(zs-zaster))/r1/r2;
   *phase=mc_acos(cosa);

	tt=mc_asin(reqter/r1);
	ts=mc_asin(reqsol/r2);

   if ((reqter/r1)>(reqsol/r2)) {
      R1=tan(tt);;
      R2=tan(ts);
      cas=0;
      airetot=PI*R2*R2; // aire du disque solaire projete
   } else {
      R1=tan(ts);
      R2=tan(tt);
      cas=1;
      airetot=PI*R1*R1; // aire du disque solaire projete
   }
   rho=fabs(tan(mc_acos(cosa)));
   t2=2*mc_acos((R2*R2+rho*rho-R1*R1)/2/R2/rho);
   t1=2*mc_acos((R1*R1+rho*rho-R2*R2)/2/R1/rho);
   da1=0.5*R1*R1*(t1-sin(t1));
   da2=0.5*R2*R2*(t2-sin(t2));
   if (rho<(R1-R2)) {
      if (cas==0) {
         aire=0;
      } else {
         aire=PI*R1*R1-PI*R2*R2;
      }
   } else if (rho<sqrt(R1*R1-R2*R2)) {
      if (cas==0) {
         aire=da2-da1;
      } else {
         aire=PI*R1*R1-PI*R2*R2+da2-da1;
      }
   } else if (rho<(R1+R2)) {
      if (cas==0) {
         aire=PI*R2*R2-da1-da2;
      } else {
         aire=PI*R1*R1-da1-da2;
      }
   } else {
      if (cas==0) {
         aire=PI*R2*R2;
      } else {
         aire=PI*R1*R1;
      }
   }
   *sunfraction=(aire/airetot);

}

void mc_adelemap_sgp(int sgp_method,double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *asd, double *dec, double *delta,double *mag,double *diamapp,double *elong,double *phase,double *rr,double *diamapp_equ,double *diamapp_pol,double *long1,double *long2,double *long3,double *lati,double *posangle_sun,double *posangle_north,double *long1_sun,double *lati_sun,double *sunfraction,double *zenith_longmpc,double *zenith_latmpc,double *azimuth, double *elevation, double *parallactic, double *hour_angle,double *zenith_dist)
/***************************************************************************/
/* Calcul de l'asd, dec et distance apparentes d'un astre defini par ses  elements d'orbite GEOCENTRIQUES uniquement a jj donne.   */
/***************************************************************************/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,/*dpsi,deps,*/xs,ys,zs;
   double l,b,x,y,z,xt,yt,zt;
   double dxeq,dyeq,dzeq;
   double jjda;
	double xaster,yaster,zaster;
   double da1,da2,R1,R2,rho,t1,t2,cosa,aire,airetot,tt,ts;
   double r1,r2,r;
   double reqter=(EARTH_SEMI_MAJOR_RADIUS)/UA,reqsol=696000./UA*1e3;
	int cas;
	double xgeo,ygeo,zgeo,vxgeo,vygeo,vzgeo;
	double tsl,zlong,zlat,latitude,altitude;
	double aa,bb,ff,dx,dy,dz,alpha,ttsol,ttt;
	double alpha_min,alpha_max,phasegeo;
   jjd=jj;

	/* type d'astre (0=inconnu 1=comete 2=asteroide 3=planete 4=geocentrique) */
   if (elem.type!=4) {
		return;
   }

   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);

   /*--- astre a observer ---*/
	/* equatorial coordinates at epoch=jjutc by definition of TLEs */
	mc_norad_sgdp48(jjutc,sgp_method,&elem,&xgeo,&ygeo,&zgeo,&vxgeo,&vygeo,&vzgeo);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,asd,dec,delta);

   /* --- astre corrige de l'aberration de la lumiere ---*/
   mc_aberpla(jjutc,*delta,&jjda);

	/* equatorial coordinates at epoch=jjutc-timelight */
	mc_norad_sgdp48(jjda,sgp_method,&elem,&xgeo,&ygeo,&zgeo,&vxgeo,&vygeo,&vzgeo);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,asd,dec,delta);

	/* --- local coordinates ---*/
	mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
	latitude*=(DR);
   mc_ad2hd(jjutc,longmpc,*asd,hour_angle);
   mc_hd2ah(*hour_angle,*dec,latitude,azimuth,elevation);
   mc_hd2parallactic(*hour_angle,*dec,latitude,parallactic);

	/* --- calcul des coordonnees terrestre ou ca passe au zenith ---*/
	r=sqrt(xgeo*xgeo+ygeo*ygeo+zgeo*zgeo);
	zlat=asin(zgeo/r);
	mc_rhophi2latalt(sin(zlat),cos(zlat),&latitude,&altitude);
	zlat=latitude*(DR);
	zlong=atan2(ygeo,xgeo);
   mc_tsl(jjutc,0,&tsl);
	zlong=fmod(4*(PI)+zlong-tsl,2*(PI));
	*zenith_longmpc=zlong;
	*zenith_latmpc=zlat;
   aa=(EARTH_SEMI_MAJOR_RADIUS)/(UA);
	ff=1./EARTH_INVERSE_FLATTENING;
   bb=aa*(1-ff);
	x=aa*cos(zlong)*cos(zlat);
	y=aa*sin(zlong)*cos(zlat);
	z=bb*sin(zlat);
	alpha=(x*x)+(y*y)+(z*z);
	*zenith_dist = r - sqrt(alpha);

	/* === J2000 astrometric coordinates ---*/
   //mc_precxyz(jjd,x,y,z,equinoxe,&x,&y,&z); /* topocentric equatoriale J2000 */
   //mc_xyz2add(x,y,z,asd,dec,delta);

   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_nutradec(jjd,*asd,*dec,asd,dec,1);
		mc_aberration_annuelle(jjd,*asd,*dec,asd,dec,1);
	}

   /*--- correction de la precession ---*/
   mc_precad(jjd,*asd,*dec,equinoxe,asd,dec); /* equatoriale J2000 */

   /* === calculation of eclipses ---*/

   /*--- correction de la parallaxe topo -> geo ---*/
	xaster=xgeo;
	yaster=ygeo;
	zaster=zgeo;

   /*--- observer -> geo ---*/
   x=-dxeq;
   y=-dyeq;
   z=-dzeq;

   /*--- soleil geo ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
	rs=sqrt(xs*xs+ys*ys+zs*zs);

	// --- elong, angle de sommet l'observateur
	// r1 = distance observateur->satellite
	// r2 = distance observateur->soleil
   r1=sqrt((xaster-x)*(xaster-x)+(yaster-y)*(yaster-y)+(zaster-z)*(zaster-z));
   r2=sqrt((xs-x)*(xs-x)+(ys-y)*(ys-y)+(zs-z)*(zs-z));
   cosa=-((xaster-x)*(xs-x)+(yaster-y)*(ys-y)+(zaster-z)*(zs-z))/r1/r2;
   *elong=mc_acos(cosa);

	// --- phasegeo, angle de sommet le satellite
	// r1 = distance satellite->centre_terre
	// r2 = distance satellite->soleil
   r1=sqrt((-xaster)*(-xaster)+(-yaster)*(-yaster)+(-zaster)*(-zaster));
   r2=sqrt((xs-xaster)*(xs-xaster)+(ys-yaster)*(ys-yaster)+(zs-zaster)*(zs-zaster));
   cosa=-((-xaster)*(xs-xaster)+(-yaster)*(ys-yaster)+(-zaster)*(zs-zaster))/r1/r2;
   phasegeo=mc_acos(cosa);

	// --- phase, angle de sommet le satellite
	// r1 = distance satellite->observateur
	// r2 = distance satellite->soleil
   r1=sqrt((x-xaster)*(x-xaster)+(y-yaster)*(y-yaster)+(z-zaster)*(z-zaster));
   r2=sqrt((xs-xaster)*(xs-xaster)+(ys-yaster)*(ys-yaster)+(zs-zaster)*(zs-zaster));
   cosa=-((x-xaster)*(xs-xaster)+(y-yaster)*(ys-yaster)+(z-zaster)*(zs-zaster))/r1/r2;
   *phase=mc_acos(cosa);

	r1=sqrt(xaster*xaster+yaster*yaster+zaster*zaster);
	tt=mc_asin(reqter/r1);

   r2=sqrt((xs-xaster)*(xs-xaster)+(ys-yaster)*(ys-yaster)+(zs-zaster)*(zs-zaster));
	ts=mc_asin(reqsol/r2);

	/*
   if ((reqter/r1)>(reqsol/r2)) {
      R1=tan(tt);
      R2=tan(ts);
      cas=0;
      airetot=PI*R2*R2; // aire du disque solaire projete
   } else {
      R1=tan(ts);
      R2=tan(tt);
      cas=1;
      airetot=PI*R1*R1; // aire du disque solaire projete
   }
   rho=fabs(tan(mc_acos(cosa)));
   t2=2*mc_acos((R2*R2+rho*rho-R1*R1)/2/R2/rho);
   t1=2*mc_acos((R1*R1+rho*rho-R2*R2)/2/R1/rho);
   da1=0.5*R1*R1*(t1-sin(t1));
   da2=0.5*R2*R2*(t2-sin(t2));
   if (rho<(R1-R2)) {
      if (cas==0) {
         aire=0;
      } else {
         aire=PI*R1*R1-PI*R2*R2;
      }
   } else if (rho<sqrt(R1*R1-R2*R2)) {
      if (cas==0) {
         aire=da2-da1;
      } else {
         aire=PI*R1*R1-PI*R2*R2+da2-da1;
      }
   } else if (rho<(R1+R2)) {
      if (cas==0) {
         aire=PI*R2*R2-da1-da2;
      } else {
         aire=PI*R1*R1-da1-da2;
      }
   } else {
      if (cas==0) {
         aire=PI*R2*R2;
      } else {
         aire=PI*R1*R1;
      }
   }
   *sunfraction=(aire/airetot);
	*/

	*sunfraction=1.;
	// --- alpha est le scalaire de l'equation parametrique de la ligne de visée aster-Soleil qui définit le point le plus proche du centre de la Terre
	dx=xs-xaster;
	dy=ys-yaster;
	dz=zs-zaster;
	alpha=-(xaster*dx+yaster*dy+zaster*dz)/(dx*dx+dy*dy+dz*dz);
	// --- coordonnees du point le plus proche au centre la Terre de la ligne de visee aster-soleil
	x=xaster+alpha*dx;
	y=yaster+alpha*dy;
	z=zaster+alpha*dz;
   aa=(EARTH_SEMI_MAJOR_RADIUS)/(UA);
	ff=1./EARTH_INVERSE_FLATTENING;
   bb=aa*(1-ff);
	// --- limites de alpha
	b=mc_asin(aa/r1);
	alpha_max=sin(b+ts)/sin(b);
	b=mc_asin(bb/r1);
	alpha_min=sin(b-ts)/sin(b);
	// --- alpha <=1 si la ligne de visee intercepte la Terre
	alpha=(x*x/aa/aa)+(y*y/aa/aa)+(z*z/bb/bb);
	if (phasegeo<(PI/2)) {
		*sunfraction=1.;
	} else if (alpha<alpha_min) {
		*sunfraction=0.;
	} else if (alpha>alpha_max) {
		*sunfraction=1.;
	} else {
		// --- projection du point sur la surface de la Terre
		mc_xyz2lbr(x,y,z,&l,&b,&r);
		xt=aa*cos(l)*cos(b);
		yt=aa*sin(l)*cos(b);
		zt=bb*sin(b);
		// --- On deplace le reférentiel sur le satellite
		x=x-xaster; // direction satel->soleil
		y=y-yaster;
		z=z-zaster;
		xt=xt-xaster; // direction satel->bord de la Terre
		yt=yt-yaster;
		zt=zt-zaster;
		xs=xs-xaster; // direction satel->soleil
		ys=ys-yaster;
		zs=zs-zaster;
		xgeo=-xaster; // direction satel->centre de la Terre
		ygeo=-yaster;
		zgeo=-zaster;
		// --- demi angle apparent du Soleil vu du satellite
		r2=sqrt(xs*xs+ys*ys+zs*zs);
		ts=mc_asin(reqsol/r2);
		// --- angle centre_Terre|satellite|bord_Terre
		r1=sqrt(xt*xt+yt*yt+zt*zt);
		r2=sqrt(xgeo*xgeo+ygeo*ygeo+zgeo*zgeo);
		ttt=acos((xt*xgeo+yt*ygeo+zt*zgeo)/r1/r2);
		// --- angle centre_Terre|satellite|centre_Soleil
		r1=sqrt(x*x+y*y+z*z);
		r2=sqrt(xgeo*xgeo+ygeo*ygeo+zgeo*zgeo);
		ttsol=acos((x*xgeo+y*ygeo+z*zgeo)/r1/r2);
		// --- condition de tengeance des deux disques

		rho=tan(ttsol);

		if (tt>ts) {
			R1=tan(ttt);
			R2=tan(ts);
			cas=0;
			airetot=PI*R2*R2; // aire du disque solaire projete
		} else {
			R1=tan(ts);
			R2=tan(ttt);
			cas=1;
			airetot=PI*R1*R1; // aire du disque solaire projete
		}
		t2=2*mc_acos((R2*R2+rho*rho-R1*R1)/2/R2/rho);
		t1=2*mc_acos((R1*R1+rho*rho-R2*R2)/2/R1/rho);
		da1=0.5*R1*R1*(t1-sin(t1));
		da2=0.5*R2*R2*(t2-sin(t2));
		if (rho<(R1-R2)) {
			if (cas==0) {
				aire=0;
			} else {
				aire=PI*R1*R1-PI*R2*R2;
			}
		} else if (rho<sqrt(R1*R1-R2*R2)) {
			if (cas==0) {
				aire=da2-da1;
			} else {
				aire=PI*R1*R1-PI*R2*R2+da2-da1;
			}
		} else if (rho<(R1+R2)) {
			if (cas==0) {
				aire=PI*R2*R2-da1-da2;
			} else {
				aire=PI*R1*R1-da1-da2;
			}
		} else {
			if (cas==0) {
				aire=PI*R2*R2;
			} else {
				aire=PI*R1*R1;
			}
		}
		*sunfraction=(aire/airetot);
	}


}

void mc_adshadow(double jj,double jjutc, double equinoxe, int astrometric, double longmpc,double rhocosphip,double rhosinphip, double nrevperday, double *asd_center, double *dec_center, double *semi_angle_eq, double *semi_angle_po, double *asd_west, double *dec_west, double *asd_east, double *dec_east, double *asd_north, double *dec_north, double *asd_south, double *dec_south, double *asd_satel_west, double *asd_satel_east, double *dec_satel, double *impact)
/***************************************************************************/
/* Calcul de l'asd, dec de l'ombre de la Terre */
/***************************************************************************/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,/*dpsi,deps,*/xs,ys,zs;
   double dxeq,dyeq,dzeq;
   double reqter=(EARTH_SEMI_MAJOR_RADIUS)/UA,reqsol=696000./UA*1e3;
	double xgeo,ygeo,zgeo;
	double asd,dec;
	double ux,uy,uz,aa,bb,cc,delta,alpha,beta,theta_eq,theta_po,ff;
	double rpoter,rc_eq,rc_po;
	double k_gauss,n,a,alpha0,alphans,alphaew;
	double y0,xc,x,y,z,sepang,posang;
	double dz,alphacosp;
   jjd=jj;

   /*--- soleil geo ---*/
	// Tenir compte de l'abberation de la lumiere a 1 UA ?
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
	rs=sqrt(xs*xs+ys*ys+zs*zs);

   /*--- vecteur unitaire geo en direction du sommet du cone d'ombre ---*/
	ux=-xs/rs;
	uy=-ys/rs;
	uz=-zs/rs;

	/* --- angle equatorial du cone d'ombre ---*/
	theta_eq=mc_asin((reqsol-reqter)/rs);

	/* --- angle polaire du cone d'ombre ---*/
	ff=1./EARTH_INVERSE_FLATTENING;
   rpoter=reqter*(1-ff);
	theta_po=mc_asin((reqsol-rpoter)/rs);

	/* --- longueur du cone d'ombre ---*/
	rc_eq=reqter/sin(theta_eq);
	rc_po=rpoter/sin(theta_po);

	/* --- conversion du nrevperday en demi-grand axe de l'orbite ---*/
   k_gauss=KGEOS;
   n=nrevperday*360.; /* deg/day */
   a=pow(k_gauss/(DR)/n,2./3.);

	/* === coordonnees de l'axe du cone d'ombre qui intercepte une orbite equatoriale === */
	xgeo=ux*a;
	ygeo=uy*a;
	zgeo=uz*a;
	alpha0=atan2(ygeo,xgeo);
   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,&asd,&dec,&delta);
   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_nutradec(jjd,asd,dec,&asd,&dec,1);
		mc_aberration_annuelle(jjd,asd,dec,&asd,&dec,1);
	}
   /*--- correction de la precession ---*/
   mc_precad(jjd,asd,dec,equinoxe,&asd,&dec); /* equatoriale J2000 */
	*asd_center=asd;
	*dec_center=dec;

	*asd_west=*asd_center;
	*dec_west=*dec_center;
	*asd_east=*asd_center;
	*dec_east=*dec_center;
	*asd_north=*asd_center;
	*dec_north=*dec_center;
	*asd_south=*asd_center;
	*dec_south=*dec_center;
	*semi_angle_eq=0;
	*semi_angle_po=0;
	if (a>rc_po) {
		// toujours au dela du cone d'ombre
		return;
	}

	/* === calcul de l'angle alpha des bords est-west du cone d'ombre qui intercepte une orbite equatoriale === */
	y0=rc_eq*tan(theta_eq);
	xc=rc_eq;
	aa=xc*xc+y0*y0;
	bb=-2*y0*y0;
	cc=y0*y0-a*a;
	delta=bb*bb-4*aa*cc;
	if (delta>=0) {
		beta=(-bb+sqrt(delta))/2./aa;
		alpha=mc_acos(xc/a*beta);
	} else {
		beta=1;
		alpha=0;
	}

	/* === coordonnees du bord west du cone d'ombre qui intercepte une orbite equatoriale === */
	xgeo=a*cos(alpha0-alpha);
	ygeo=a*sin(alpha0-alpha);
	zgeo=uz*a;
   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,&asd,&dec,&delta);
   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_nutradec(jjd,asd,dec,&asd,&dec,1);
		mc_aberration_annuelle(jjd,asd,dec,&asd,&dec,1);
	}
   /*--- correction de la precession ---*/
   mc_precad(jjd,asd,dec,equinoxe,&asd,&dec); /* equatoriale J2000 */
	*asd_west=asd;
	*dec_west=dec;
   mc_sepangle(*asd_center,asd,*dec_center,dec,&sepang,&posang);
	*semi_angle_eq=sepang;
	alphaew=sepang;

	/* === coordonnees du bord east du cone d'ombre === */
	xgeo=a*cos(alpha0+alpha);
	ygeo=a*sin(alpha0+alpha);
	zgeo=uz*a;
   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,&asd,&dec,&delta);
   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_nutradec(jjd,asd,dec,&asd,&dec,1);
		mc_aberration_annuelle(jjd,asd,dec,&asd,&dec,1);
	}
   /*--- correction de la precession ---*/
   mc_precad(jjd,asd,dec,equinoxe,&asd,&dec); /* equatoriale J2000 */
	*asd_east=asd;
	*dec_east=dec;

	/* === calcul de l'angle alpha des bords north-south du cone d'ombre qui intercepte une orbite equatoriale === */
	y0=rc_po*tan(theta_po);
	xc=rc_po;
	aa=xc*xc+y0*y0;
	bb=-2*y0*y0;
	cc=y0*y0-a*a;
	delta=bb*bb-4*aa*cc;
	if (delta>=0) {
		beta=(-bb+sqrt(delta))/2./aa;
		alpha=mc_acos(xc/a*beta);
	} else {
		beta=1;
		alpha=0;
	}

	/* === coordonnees du bord north du cone d'ombre === */
	xgeo=ux*a;
	ygeo=uy*a;
	zgeo=uz*a+a*sin(alpha);
   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,&asd,&dec,&delta);
   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_nutradec(jjd,asd,dec,&asd,&dec,1);
		mc_aberration_annuelle(jjd,asd,dec,&asd,&dec,1);
	}
   /*--- correction de la precession ---*/
   mc_precad(jjd,asd,dec,equinoxe,&asd,&dec); /* equatoriale J2000 */
	*asd_north=asd;
	*dec_north=dec;
   mc_sepangle(*asd_center,asd,*dec_center,dec,&sepang,&posang);
	*semi_angle_po=sepang;
	alphans=sepang;

	/* === coordonnees du bord south du cone d'ombre === */
	xgeo=ux*a;
	ygeo=uy*a;
	zgeo=uz*a-a*sin(alpha);
   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,&asd,&dec,&delta);
   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_nutradec(jjd,asd,dec,&asd,&dec,1);
		mc_aberration_annuelle(jjd,asd,dec,&asd,&dec,1);
	}
   /*--- correction de la precession ---*/
   mc_precad(jjd,asd,dec,equinoxe,&asd,&dec); /* equatoriale J2000 */
	*asd_south=asd;
	*dec_south=dec;

	/* === passage d'un satellite a orbite équatoriale === */
	delta=sqrt(ux*ux+uy*uy);
	xgeo=ux/delta*a;
	ygeo=uy/delta*a;
	zgeo=0;
   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjutc,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);
	/* geo -> topo */
   mc_he2ge(xgeo,ygeo,zgeo,-dxeq,-dyeq,-dzeq,&x,&y,&z);
   mc_xyz2add(x,y,z,&asd,&dec,&delta);
   /*--- correction de l'aberration annuelle ---*/
	if (astrometric==0) {
		mc_nutradec(jjd,asd,dec,&asd,&dec,1);
		mc_aberration_annuelle(jjd,asd,dec,&asd,&dec,1);
	}
   /*--- correction de la precession ---*/
   mc_precad(jjd,asd,dec,equinoxe,&asd,&dec); /* equatoriale J2000 */
	*asd_satel_west=asd;
	*asd_satel_east=asd;
	*dec_satel=dec;
	*impact=(*dec_satel-*dec_center);
	if (fabs(*impact)<alphans) {
		dz=fabs(*impact/alphans);
		alpha=alphans*dz+alphaew*(1-dz);
		alphacosp=alpha*(1-dz*dz);
		asd=*asd_center-alphacosp;
	   asd=fmod(4*PI+asd,2*PI);
		*asd_satel_west=asd;
		asd=*asd_center+alphacosp;
	   asd=fmod(4*PI+asd,2*PI);
		*asd_satel_east=asd;
	}
}

void mc_xyzgeoelem(double jj,double jjutc, double equinoxe, int astrometric, struct elemorb elem, double longmpc,double rhocosphip,double rhosinphip, int planete, double *xageo, double *yageo, double *zageo, double *xtgeo, double *ytgeo, double *ztgeo, double *xsgeo, double *ysgeo, double *zsgeo, double *xlgeo, double *ylgeo, double *zlgeo)
/***************************************************************************/
/* Calcul de X,Y,Z geocentrique d'un astre defini par ses elements d'orbite a jj donne.   */
/***************************************************************************/
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,/*dpsi,deps,*/xs,ys,zs;
   double l,b,r,x,y,z,xl,yl,zl;
   double dxeq,dyeq,dzeq;
   struct pqw elempq;
   double m,v;

   jjd=jj;

   /*--- soleil ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs);
   mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */

   /* --- Lune ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,LUNE,llp,mmp,uup,&l,&b,&r);
   mc_lbr2xyz(l,b,r,&x,&y,&z);
   mc_obliqmoy(jjd,&eps);
   mc_xyzec2eq(x,y,z,eps,&xl,&yl,&zl);
   mc_precxyz(jjd,xl,yl,zl,equinoxe,&xl,&yl,&zl); /* equatoriale J2000 */

   /*--- calcul de la parallaxe ---*/
   mc_paraldxyzeq(jjd,longmpc,rhocosphip,rhosinphip,&dxeq,&dyeq,&dzeq);

   /*--- precession et conversion des elements ---*/
   mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);

   /*--- perturabtions seculaires dues a l'applatissement de la Terre ---*/
	mc_corearthsatelem(jjd,&elem);

   mc_elempqec(elem,&elempq);
   /*
   if (elem.type!=4) {
      mc_elempqeq(elempq,eps,&elempq);
   }
   */

   /*--- astre a observer ---*/
   mc_anomoy(elem,jjd,&m);
   mc_anovrair(elem,m,&v,&r);
   mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */

   /* sortir x,y,z,xs,ys,zs */
   *xageo=x;
   *yageo=y;
   *zageo=z;
   *xtgeo=dxeq;
   *ytgeo=dyeq;
   *ztgeo=dzeq;
   *xsgeo=xs;
   *ysgeo=ys;
   *zsgeo=zs;
   *xlgeo=xl;
   *ylgeo=yl;
   *zlgeo=zl;

}

void mc_bowell1(char *nom_fichier_in,double jj,double equinoxe,double lim_mag_sup, double lim_mag_inf,double lim_elong,double lim_dec_sup, double lim_dec_inf,double lim_inc_sup, double lim_inc_inf,int flag1,int flag2,int flag3,char *nom_fichier_out)
/***************************************************************************/
/* Genere un fichier ASCII d'ephemerides des petites planetes de la base   */
/* de Bowell pour jj donne rapporte a un equinoxe. On donne des criteres   */
/* de selection tels que la limite en elongation, la limite en magnitude...*/
/***************************************************************************/
/* par defaut si la variable vaut TLOSS                                    */
/* lim_mag_sup=17.0                                                        */
/* lim_mag_inf=-99                                                         */
/* lim_elong  =60*(DR)                                                     */
/* lim_dec_sup=90*(DR)                                                     */
/* lim_dec_inf=-90*(DR)                                                    */
/* lim_inc_sup=600 <toujours en arcsec>                                    */
/* lim_inc_inf=0                                                           */
/* === exclusion sur les types de designation ===                          */
/* flag1=1 : pour les tous les asteroides numerotes                        */
/*      =2 : pour les tous les asteroides a numeros provisoires            */
/* === exclusion sur les types d'orbites ===                               */
/* flag2=1 : pour tous les types                                           */
/*      =2 : pour les asteroides lointains (Kuiper et Centaurs)            */
/*      =4 : pour les asteroides troyens                                   */
/*      =8 : pour les MarsCrossers                                         */
/*      =16 : pour les EGA                                                 */
/*      =32: pour les ECA                                                  */
/* === exclusion sur les types d'incertitudes ===                          */
/* flag3=1 : pour tous les cas d'incertitude ou d'importance               */
/*      =2 : pour les critical list                                        */
/*      =4 : pour les ObsRequired ou Numberable                            */
/*      =8 : pour les MassDetermination ou SpaceMissionTarget              */
/* === pour tous types confondus, les flags seront 3,1,1                   */
/***************************************************************************/
{
   FILE *fichier_in,*fichier_out,*fichier_sort ;
   char ligne[300],name[30];
   struct asterident aster;
   struct elemorb elem;
   double ceu,incert=0.;
   int calcul,nb=0,k,nblighead;
   double asd,dec,delta,rsol,elong,phase,mag,dist,posangle,r2;
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,xs,ys,zs,xs2,ys2,zs2;
   double r,x,y,z,m,v,jjda,asd2,dec2,delta2,e,a,q,qq;
   struct pqw elempq;
   int intrien1,intrien2;
   int flag11,flag12;
   int flag21,flag22,flag23,flag24,flag25,flag26;
   int flag31,flag32,flag33,flag34;
/*mc_menu 71 astorb.dat 20040701 20050101*/
   /*
FILE *f;
double xs2ec,ys2ec,zs2ec,xec,yec,zec;
*/

   /* --- initialisation des flags de selection ---*/
   if(flag1>= 2) {flag12=OK;flag1-= 2;} else {flag12=NO;}
   if(flag1>= 1) {flag11=OK;flag1-= 1;} else {flag11=NO;}
   if(flag2>=32) {flag26=OK;flag2-=32;} else {flag26=NO;}
   if(flag2>=16) {flag25=OK;flag2-=16;} else {flag25=NO;}
   if(flag2>= 8) {flag24=OK;flag2-= 8;} else {flag24=NO;}
   if(flag2>= 4) {flag23=OK;flag2-= 4;} else {flag23=NO;}
   if(flag2>= 2) {flag22=OK;flag2-= 2;} else {flag22=NO;}
   if(flag2>= 1) {flag21=OK;flag2-= 1;} else {flag21=NO;}
   if(flag3>= 8) {flag34=OK;flag3-= 8;} else {flag34=NO;}
   if(flag3>= 4) {flag33=OK;flag3-= 4;} else {flag33=NO;}
   if(flag3>= 2) {flag32=OK;flag3-= 2;} else {flag32=NO;}
   if(flag3>= 1) {flag31=OK;flag3-= 1;} else {flag31=NO;}
   if (lim_mag_sup==TLOSS) {lim_mag_sup=17.0;}
   if (lim_mag_inf==TLOSS) {lim_mag_inf=-99;}
   if (lim_elong  ==TLOSS) {lim_elong  =60*(DR);}
   if (lim_dec_sup==TLOSS) {lim_dec_sup=90*(DR);}
   if (lim_dec_inf==TLOSS) {lim_dec_inf=-90*(DR);}
   if (lim_inc_sup==TLOSS) {lim_inc_sup=600;}
   if((lim_inc_inf==TLOSS)||(lim_inc_inf==0)) {lim_inc_inf=1e-14;}
   jjd=jj;

   /*--- constantes equatoriales ---*/
   mc_obliqmoy(equinoxe,&eps);
   /*--- soleil ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
   mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */
   rsol=rs;
   /*--- soleil +1h ---*/
   mc_jd2lbr1a(jjd+1./24,llp,mmp,uup);
   mc_jd2lbr1b(jjd+1./24,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs2,&ys2,&zs2);
   mc_xyzec2eq(xs2,ys2,zs2,eps,&xs2,&ys2,&zs2); /* equatoriale a la date */
   mc_precxyz(jjd+1./24,xs2,ys2,zs2,equinoxe,&xs2,&ys2,&zs2); /* equatoriale J2000 */

   /* --- ouverture et initialisation des entetes des fichiers ---*/
   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   if (( fichier_out=fopen("#.txt","w") ) == NULL) {
      return;
   }
   mc_fprfbow1(1,equinoxe,fichier_out,&nblighead);
   if (( fichier_sort=fopen("##.txt","w") ) == NULL) {
      return;
   }
   for (k=1;k<=nblighead;k++) {
      fprintf(fichier_sort,"%d %f\n",++nb,((double)(k-nblighead-1)));
   }

   /* --- grande boucle sur l'ensemble de la base de Bowell ---*/
   do {
      fgets(ligne,300,fichier_in);
      mc_bow_dec1(ligne,&aster);
      calcul=OK;
      /* === exclusion sur les types de designation ===*/
      if (calcul==OK) {
         calcul=NO;
         if ((flag11==OK)&&(aster.num!=0)) {calcul=OK;}
         if ((flag12==OK)&&(aster.num==0)) {calcul=OK;}
      }
      /* === exclusion sur les types d'orbites ===*/
      if (calcul==OK) {
         e=aster.e;
         a=aster.a;
         q=a*(1-e);
         qq=a*(1+e);
         calcul=NO;
         if ((flag21==OK)) {calcul=OK;}
         if ((flag22==OK)&&(a>10)) {calcul=OK;}
         if ((flag23==OK)&&(a>4.8)&&(a<5.6)) {calcul=OK;}
         if ((flag24==OK)&&(qq>1.3)&&(q<1.666)) {calcul=OK;}
         if ((flag25==OK)&&(q<1.0167)) {calcul=OK;}
         if ((flag26==OK)&&(q<1.0167)) {calcul=OK;}
      }
      /* === exclusion sur les types d'incertitudes ===*/
      if (calcul==OK) {
         calcul=NO;
         if ((flag31==OK)) {calcul=OK;}
         if ((flag32==OK)&&(aster.code4>=1)&&(aster.code4<=6)) {calcul=OK;}
         if ((flag33==OK)&&(aster.code6>=5)&&(aster.code6<=8)) {calcul=OK;}
         if ((flag34==OK)&&(aster.code6>=9)&&(aster.code6<=10)) {calcul=OK;}
      }
      /* === exclusion sur les valeurs de l'incertitude ===*/
      if (calcul==OK) {
         calcul=NO;
         ceu=aster.ceu0+aster.ceut*fabs(jj-aster.jj_ceu0);
         if (fabs(jj-aster.jj_ceu0)<365) {
            if ((aster.ceu0<=lim_inc_sup)&&(aster.ceu0!=0)&&(fabs(ceu)<=lim_inc_sup)&&(fabs(ceu)>=lim_inc_inf)) {
               calcul=OK;
               incert=fabs(ceu);
            }
         } else {
            if ((aster.ceu0<lim_inc_sup)&&(fabs(ceu)>=lim_inc_inf)) {
               calcul=OK;
               incert=aster.ceu0;
            }
         }
      }
      /* === Calcul de la position ===*/
      if (calcul==OK) {
         mc_aster2elem(aster,&elem);
         /*--- precession et conversion des elements ---*/
         mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
         mc_elempqec(elem,&elempq);
         mc_elempqeq(elempq,eps,&elempq);
         /*--- planete ---*/
         mc_anomoy(elem,jjd,&m);
         mc_anovrair(elem,m,&v,&r);
         mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
         mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
         mc_xyz2add(x,y,z,&asd,&dec,&delta);
         /* --- planete corrigee de l'aberration de la lumiere ---*/
         mc_aberpla(jjd,delta,&jjda);
         mc_anomoy(elem,jjda,&m);
         mc_anovrair(elem,m,&v,&r);
         mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
/*
f=fopen("frostia_xyz_helio.txt","at");
mc_xyzeq2ec(xs2,ys2,zs2,eps,&xs2ec,&ys2ec,&zs2ec);
mc_xyzeq2ec(x,y,z,eps,&xec,&yec,&zec);
fprintf(f,"%15f %f %f %f %f %f %f\n",jjd,-xs2ec,-ys2ec,-zs2ec,xec,yec,zec);
fclose(f);
*/
         mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
         /* --- coord. spheriques ---*/
         mc_xyz2add(x,y,z,&asd,&dec,&delta);
         /* --- parametres elong et magnitude ---*/
         mc_elonphas(r,rsol,delta,&elong,&phase);
         mc_magaster(r,delta,phase,aster.h,aster.g,&mag);
      }
      /* === exclusion sur l'elongation ===*/
      if (calcul==OK) {
         calcul=NO;
         if (elong>=lim_elong) {calcul=OK;}
      }
      /* === exclusion sur la magnitude ===*/
      if (calcul==OK) {
         calcul=NO;
         if ((mag<=lim_mag_sup)&&(mag>=lim_mag_inf)) {calcul=OK;}
      }
      /* === exclusion sur la declinaison ===*/
      if (calcul==OK) {
         calcul=NO;
         if ((dec<=lim_dec_sup)&&(dec>=lim_dec_inf)) {calcul=OK;}
      }
      /* === mise en forme finale ===*/
      if (calcul==OK) {
         /* --- planete corrigee de l'aberration de la lumiere +1h ---*/
         mc_anomoy(elem,jjda+1./24,&m);
         mc_anovrair(elem,m,&v,&r2);
         mc_rv_xyz(elempq,r2,v,&x,&y,&z); /* equatoriale J2000 */
         mc_he2ge(x,y,z,xs2,ys2,zs2,&x,&y,&z);
         /* --- coord. spheriques +1h ---*/
         mc_xyz2add(x,y,z,&asd2,&dec2,&delta2);
         mc_sepangle(asd,asd2,dec,dec2,&dist,&posangle);
         /* --- sorties sur fichiers ---*/
         if (aster.num!=0) {
            strcpy(name,"(");
            strcat(name,fcvt(10000+aster.num,5,&intrien1,&intrien2)+1);
            name[5]='\0';
            strcat(name,")        ");
         } else {
            strcpy(name,aster.name);
         }
         *(name+9)='\0';
         mc_fprfbow11(name,asd,dec,mag,delta,aster,incert,dist,posangle,fichier_out);
         mc_typedaster(aster,ligne);
         fprintf(fichier_out,"%s",ligne);
         if (aster.num!=0) {
            fprintf(fichier_out," =%s",aster.name);
         }
         fprintf(fichier_out,"\n");
         fprintf(fichier_sort,"%d %f\n",++nb,asd/(DR));
      }
   } while ((feof(fichier_in)==0));
   fclose(fichier_in );
   fclose(fichier_out);
   fclose(fichier_sort);
   mc_tri1("##.txt","###.txt");
   mc_tri2("#.txt",nom_fichier_out,"###.txt");
   remove("#.txt");
   remove("##.txt");
   remove("###.txt");
}

void mc_bowell3(char *nom_fichier_in,double jj,double asd0, double dec0,double equinoxe,double dist0, char *nom_fichier_out)
/***************************************************************************/
/* Genere un fichier ASCII d'ephemerides des petites planetes a numero     */
/* provisoire pour jj donne rapporte a un equinoxe. On donne un critere    */
/* de centre du champ asd,dec + un cercle angulaire centre                 */
/***************************************************************************/
/* nom_fichier_in : nom du fichier de Bowell (Astorb.dat)                  */
/* jj             : jj de l'instant d'observation                          */
/* asd0           : ascension droite (en radian)                           */
/* dec0           : declinaison (en radian)                                 */
/* equinoxe       : jj de l'equinoxe des coordonnees                       */
/* dist0          : distance angulaire (en radian)                         */
/***************************************************************************/
{
   FILE *fichier_in,*fichier_out,*fichier_sort ;
   char ligne[300],name[30];
   struct asterident aster;
   struct elemorb elem;
   double ceu,incert;
   int nb=0,intrien1,intrien2,k,nblighead;
   double asd,dec,delta,rsol,elong,phase,mag,dist,posangle,r2;
   double llp[10],mmp[10],uup[10],jjd,ls,bs,rs,eps,xs,ys,zs,xs2,ys2,zs2;
   double r,x,y,z,m,v,jjda,asd2,dec2,delta2,dist1;
   struct pqw elempq;
   jjd=jj;

   /*--- constantes equatoriales ---*/
   mc_obliqmoy(equinoxe,&eps);

   /*--- soleil ---*/
   mc_jd2lbr1a(jjd,llp,mmp,uup);
   mc_jd2lbr1b(jjd,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
   mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
   mc_precxyz(jjd,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */
   rsol=rs;
   /*--- soleil +1h ---*/
   mc_jd2lbr1a(jjd+1./24,llp,mmp,uup);
   mc_jd2lbr1b(jjd+1./24,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xs2,&ys2,&zs2);
   mc_xyzec2eq(xs2,ys2,zs2,eps,&xs2,&ys2,&zs2); /* equatoriale a la date */
   mc_precxyz(jjd+1./24,xs2,ys2,zs2,equinoxe,&xs2,&ys2,&zs2); /* equatoriale J2000 */

   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   if (( fichier_out=fopen("#.txt","w") ) == NULL) {
      return;
   }
   mc_fprfbow1(3,equinoxe,fichier_out,&nblighead);
   if (( fichier_sort=fopen("##.txt","w") ) == NULL) {
      return;
   }
   for (k=1;k<=nblighead;k++) {
      fprintf(fichier_sort,"%d %f\n",++nb,((double)(k-nblighead-1)));
   }

   do {
      fgets(ligne,300,fichier_in);
      mc_bow_dec1(ligne,&aster);

      ceu=aster.ceu0+aster.ceut*(jj-aster.jj_ceu0);
      if ((ceu>0)&&(ceu<1e5)) {
         incert=ceu;
      } else {
         incert=-aster.ceu0;
         if (fabs(incert)>=1e5) {
            incert=-(1e5-1);
         }
      }

      mc_aster2elem(aster,&elem);

      /*--- precession et conversion des elements ---*/
      mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
      mc_elempqec(elem,&elempq);
      mc_elempqeq(elempq,eps,&elempq);

      /*--- planete ---*/
      mc_anomoy(elem,jjd,&m);
      mc_anovrair(elem,m,&v,&r);
      mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
      mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
      mc_xyz2add(x,y,z,&asd,&dec,&delta);

      /* --- planete corrigee de l'aberration de la lumiere ---*/
      mc_aberpla(jjd,delta,&jjda);
      mc_anomoy(elem,jjda,&m);
      mc_anovrair(elem,m,&v,&r);
      mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
      mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);

      /* --- coord. spheriques ---*/
      mc_xyz2add(x,y,z,&asd,&dec,&delta);

      /* --- condition d'appartenance au cercle ---*/
      mc_sepangle(asd,asd0,dec,dec0,&dist1,&posangle);

      if (dist1<=dist0) {
         mc_elonphas(r,rsol,delta,&elong,&phase);
         mc_magaster(r,delta,phase,aster.h,aster.g,&mag);
         /* --- planete corrigee de l'aberration de la lumiere +1h ---*/
         mc_anomoy(elem,jjda+1./24,&m);
         mc_anovrair(elem,m,&v,&r2);
         mc_rv_xyz(elempq,r2,v,&x,&y,&z); /* equatoriale J2000 */
         mc_he2ge(x,y,z,xs2,ys2,zs2,&x,&y,&z);
         /* --- coord. spheriques +1h ---*/
         mc_xyz2add(x,y,z,&asd2,&dec2,&delta2);
         mc_sepangle(asd,asd2,dec,dec2,&dist,&posangle);
         /* --- sorties sur fichiers ---*/
         if (aster.num!=0) {
            strcpy(name,"(");
            strcat(name,fcvt(10000+aster.num,5,&intrien1,&intrien2)+1);
            name[5]='\0';
            strcat(name,")        ");
         } else {
            strcpy(name,aster.name);
         }
         *(name+9)='\0';
         mc_fprfbow11(name,asd,dec,mag,delta,aster,incert,dist,posangle,fichier_out);
         mc_typedaster(aster,ligne);
         fprintf(fichier_out,"%s",ligne);
         if (aster.num!=0) {
            fprintf(fichier_out," =%s",aster.name);
         }
         fprintf(fichier_out,"\n");
         fprintf(fichier_sort,"%d %f\n",++nb,asd/(DR));
      }
   } while ((feof(fichier_in)==0));
   fclose(fichier_in );
   fclose(fichier_out);
   fclose(fichier_sort);
   mc_tri1("##.txt","###.txt");
   mc_tri2("#.txt",nom_fichier_out,"###.txt");
   remove("#.txt");
   remove("##.txt");
   remove("###.txt");
}

void mc_bowell4(char *nom_fichier_in,char *num_aster,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance)
/***************************************************************************/
/* Changement d'epoque d'elements d'orbite par integration numerique.      */
/***************************************************************************/
/* fonction desuette a effacer (remplacee par void changepoque...          */
/***************************************************************************/
{
   struct asterident aster;
   struct elemorb elem;
   double eps;
   double r,x,y,z,m,v;
   struct pqw elempq;
   double jj;
   double vx,vy,vz;
   int trouve;

   mc_bow_dec2(num_aster,nom_fichier_in,&elem,&aster,&trouve);
   if (trouve==1) {
      *concordance=OK;
      /*--- constantes equatoriales ---*/
      mc_obliqmoy(equinoxe,&eps);
      /*--- precession et conversion des elements ---*/
      mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
      mc_elempqec(elem,&elempq);
      mc_elempqeq(elempq,eps,&elempq);

      jj=jjdeb;
      /*--- planete x,y,z vx,vy,vz equatorial ---*/
      mc_anomoy(elem,jj,&m);
      mc_anovrair(elem,m,&v,&r);
      mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
      mc_rv_vxyz(elempq,elem,r,v,&vx,&vy,&vz);

      /* ---- inserer ici l'integration numerique ---*/
      jjfin=0;pasjj=0;

      /*--- planete x,y,z vx,vy,vz ecliptique ---*/
      mc_xyzeq2ec(x,y,z,eps,&x,&y,&z);
      mc_xyzeq2ec(vx,vy,vz,eps,&vx,&vy,&vz);

      /*--- calcul des elements ---*/
      mc_xvx2elem(x,y,z,vx,vy,vz,jj,equinoxe,K,&elem);

      /*--- affichage des elements d'orbite ---*/
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_out);
   } else {
      *concordance=PB;
   }
}

void mc_changepoque(char *nom_fichier_ele_deb,char *num_aster,double jj, double equinoxe, char *nom_fichier_ele_fin,int *concordance)
/***************************************************************************/
/* Changement d'epoque d'elements d'orbite par integration numerique a     */
/* a partir des elements a une autre epoque.                               */
/***************************************************************************/
/***************************************************************************/
{
   struct elemorb elem;
   double x,y,z;
   double vx,vy,vz;
   double jjpas0,eps,jjdeb0,jjfin0;

   *concordance=PB;
   if (strcmp(num_aster,"")!=0) {
      /*
      mc_bow_dec2(num_aster,nom_fichier_in,&elem,&aster,&trouve);
      *concordance=trouve;
      */
   } else {
      mc_readelem(nom_fichier_ele_deb,&elem);
      *concordance=OK;
   }

   if (*concordance==OK) {
      /* ---- integration numerique ---*/
      jjdeb0=elem.jj_epoque;
      jjfin0=jj;
      jjpas0=0.;
      mc_integ1(jjdeb0,jjfin0,jjpas0,elem,elem.jj_equinoxe,&x,&y,&z,&vx,&vy,&vz);

      /*--- planete x,y,z vx,vy,vz ecliptique ---*/
      mc_obliqmoy(elem.jj_equinoxe,&eps);
      mc_xyzeq2ec(x,y,z,eps,&x,&y,&z);
      mc_xyzeq2ec(vx,vy,vz,eps,&vx,&vy,&vz);

      /*--- calcul des elements ---*/
      mc_xvx2elem(x,y,z,vx,vy,vz,jj,equinoxe,K,&elem);
      /* !!! voir le probleme de l'equinoxe dans xvx2... ___*/

      /*--- affichage des elements d'orbite ---*/
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele_fin);
   }
}

void mc_ephem1(char *nom_fichier_ele,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance)
/***************************************************************************/
/* Genere un fichier ASCII d'ephemerides pour un astre defini par ses      */
/* elements d'orbite.                                                      */
/* Entre les dates juliennes jjdeb et jjfin avec un pas de pasjj           */
/* Rapporte a l'equinoxe donne.                                            */
/***************************************************************************/
/***************************************************************************/
{
   FILE *fichier_out;
   struct elemorb elem;
   double asd,dec,delta,rsol,elong,phase,mag,dist,posangle,r2;
   double llp[10],mmp[10],uup[10],ls,bs,rs,eps,xs,ys,zs,xs2,ys2,zs2;
   double r,x,y,z,m,v,jjda,asd2,dec2,delta2;
   struct pqw elempq;
   double incert,ceu;
   double jj;
   int trouve,nblighead;

   mc_readelem(nom_fichier_ele,&elem);
   trouve=1;
   if (trouve==1) {
      *concordance=OK;
      if (( fichier_out=fopen(nom_fichier_out,"w") ) == NULL) {
         printf("fichier non trouve\n");
         return;
      }
      /*--- entete du fichier de sortie ---*/
      mc_fprfeph1(1,equinoxe,elem,fichier_out,&nblighead);
      /*--- constantes equatoriales ---*/
      mc_obliqmoy(equinoxe,&eps);
      /*--- precession et conversion des elements ---*/
      mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
      mc_elempqec(elem,&elempq);
      mc_elempqeq(elempq,eps,&elempq);

      jj=jjdeb;
      do {
         /*--- calcul de l'incertitude ---*/
         ceu=elem.ceu0+elem.ceut*(jj-elem.jj_ceu0);
         if (ceu>0) {
            incert=ceu;
         } else if (elem.ceu0==0) {
            incert=-999;
         } else {
            incert=-elem.ceu0;
         }

         /*--- soleil ---*/
         mc_jd2lbr1a(jj,llp,mmp,uup);
         mc_jd2lbr1b(jj,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
         mc_lbr2xyz(ls,bs,rs,&xs,&ys,&zs);
         mc_xyzec2eq(xs,ys,zs,eps,&xs,&ys,&zs); /* equatoriale a la date */
         mc_precxyz(jj,xs,ys,zs,equinoxe,&xs,&ys,&zs); /* equatoriale J2000 */
         rsol=rs;

         /*--- soleil +1h ---*/
         mc_jd2lbr1a(jj+1./24,llp,mmp,uup);
         mc_jd2lbr1b(jj+1./24,SOLEIL,llp,mmp,uup,&ls,&bs,&rs);
         mc_lbr2xyz(ls,bs,rs,&xs2,&ys2,&zs2);
         mc_xyzec2eq(xs2,ys2,zs2,eps,&xs2,&ys2,&zs2); /* equatoriale a la date */
         mc_precxyz(jj+1./24,xs2,ys2,zs2,equinoxe,&xs2,&ys2,&zs2); /* equatoriale J2000 */

         /*--- planete ---*/
         mc_anomoy(elem,jj,&m);
         mc_anovrair(elem,m,&v,&r);
         mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
         mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);
         mc_xyz2add(x,y,z,&asd,&dec,&delta);

         /* --- planete corrigee de l'aberration de la lumiere ---*/
         mc_aberpla(jj,delta,&jjda);
         mc_anomoy(elem,jjda,&m);
         mc_anovrair(elem,m,&v,&r);
         mc_rv_xyz(elempq,r,v,&x,&y,&z); /* equatoriale J2000 */
         mc_he2ge(x,y,z,xs,ys,zs,&x,&y,&z);

         /* --- coord. spheriques ---*/
         mc_xyz2add(x,y,z,&asd,&dec,&delta);

         /*--- elongation, phase et magnitude ---*/
         mc_elonphas(r,rsol,delta,&elong,&phase);
         mc_magaster(r,delta,phase,elem.h,elem.g,&mag);

         /* --- planete corrigee de l'aberration de la lumiere +1h ---*/
         mc_anomoy(elem,jjda+1./24,&m);
         mc_anovrair(elem,m,&v,&r2);
         mc_rv_xyz(elempq,r2,v,&x,&y,&z); /* equatoriale J2000 */
         mc_he2ge(x,y,z,xs2,ys2,zs2,&x,&y,&z);

         /* --- coord. spheriques +1h ---*/
         mc_xyz2add(x,y,z,&asd2,&dec2,&delta2);
         mc_sepangle(asd,asd2,dec,dec2,&dist,&posangle);
         /* --- sorties sur disque ---*/
         mc_fprfeph21(1,elem,jj,asd,dec,mag,delta,r,elong,dist,posangle,incert,fichier_out);
         jj+=pasjj;
      } while (jj<=jjfin) ;
      fclose(fichier_out);
   } else {
      *concordance=PB;
   }
}

void mc_lec_mpc_auto(char *nom_fichier_in,struct observ *obs, int *nbobs)
/***************************************************************************/
/* Macro destinee a charger la serie de trois dates d'observations du      */
/* premier objet rencontre dans la base *nom_fichier_in au format MPC.     */
/***************************************************************************/
{
   struct observ *obs1,*obs2;
   int nbobs1,nbobs2,n;
   char designation[14],nom[120];

   strcpy(nom,nom_fichier_in);
   /* --- recherche le nombre de lignes au format MPC ---*/
   nbobs1=0;
   obs1 = (struct observ *) calloc(nbobs1+1,sizeof(struct observ));
   mc_lec_obs_mpc(nom,obs1,&nbobs1);
   free(obs1);
   n=0;
   if (nbobs1>=1) {
      /* --- lit toutes les lignes au format MPC ---*/
      obs1 = (struct observ *) calloc(nbobs1+1,sizeof(struct observ));
      mc_lec_obs_mpc(nom,obs1,&nbobs1);
      /* --- choisit le premier objet lu ---*/
      strcpy(designation,obs1[1].designation);
      /* --- recherche le nombre d'observations de l'objet choisit ---*/
      nbobs2=0;
      obs2 = (struct observ *) calloc(nbobs2+1,sizeof(struct observ));
      mc_select_observ(obs1,nbobs1,designation,obs2,&nbobs2);
      free(obs2);
      /* --- lit toutes les observations de l'objet choisit ---*/
      obs2 = (struct observ *) calloc(nbobs2+1,sizeof(struct observ));
      mc_select_observ(obs1,nbobs1,designation,obs2,&nbobs2);
      /* --- recherche le nombre de lignes ---*/
      n=0;
      mc_select32_observ(obs2,nbobs2,obs1,&n,*nbobs);
      /* --- isole les 2 ou 3 lignes interessantes ---*/
      mc_select32_observ(obs2,nbobs2,obs,&n,*nbobs);
      free(obs1);
      free(obs2);
   }
   *nbobs=n;
}

void mc_typedaster(struct asterident aster, char *ligne)
/***************************************************************************/
/* Genere un ligne de mots clairs qui designe le type d'asteroide a partir */
/* des 6 codes de la base de Bowell.                                       */
/***************************************************************************/
{
   int a;
   strcpy(ligne,"");
   if (aster.code1==1) {
      strcat(ligne," <<EarthCrossing>>");
   }
   if (aster.code1==2) {
      strcat(ligne," <<EarthGrazing>>");
   }
   if (aster.code1==4) {
      strcat(ligne," <<Amor>>");
   }
   if (aster.code1==8) {
      strcat(ligne," <<MarsCrosser>>");
   }
   if (aster.code1>=16) {
      strcat(ligne," OuterPlanetCrosser");
   }
   a=aster.code2;
   if (a>=64) {
      strcat(ligne," H=14Assumed");
      a=a-64;
   }
   if (a>=32) {
      strcat(ligne," +DataNotMPC");
      a=a-32;
   }
   if (a>=16) {
      strcat(ligne," SomeDataOmitted");
      a=a-16;
   }
   if (a>=8) {
      strcat(ligne," FewDataOmitted");
      a=a-8;
   }
   if (a>=4) {
      strcat(ligne," Eccentricity&AxisAssumed");
      a=a-4;
   }
   if (a>=2) {
      strcat(ligne," EccentricityAssumed");
      a=a-2;
   }
   if (a>=1) {
      strcat(ligne," UncertainData");
/*
      a=a-1;
 */
   }
   if (aster.code4==1) {
      strcat(ligne," Lost");
   }
   if (aster.code4==2) {
      strcat(ligne," CriticalList2App");
   }
   if (aster.code4==3) {
      strcat(ligne," CriticalList3App");
   }
   if (aster.code4==4) {
      strcat(ligne," CriticalList>3AppLast>10y");
   }
   if (aster.code4==5) {
      strcat(ligne," CriticalList>3AppOne<10y");
   }
   if (aster.code4==6) {
      strcat(ligne," CriticalList>3AppPoorObs");
   }
   if (aster.code4==7) {
      strcat(ligne," HPoor");
   }
   if (aster.code6==10) {
      strcat(ligne," SpaceMissionTarget");
   }
   if (aster.code6==9) {
      strcat(ligne," MassDetermination");
   }
   if (aster.code6==8) {
      strcat(ligne," ObsRequired");
   }
   if ((aster.code6==7)&&(aster.num==0)) {
      strcat(ligne," BowellNumberable");
   }
   if (((aster.code6==6)||(aster.code6==5))&&(aster.num==0)) {
      strcat(ligne," Numberable");
   }
   if (((aster.code6==6)||(aster.code6==5))&&(aster.num!=0)) {
      strcat(ligne," ObsRequired");
   }
   if (((aster.code6==4)||(aster.code6==3))&&(aster.num==0)) {
      strcat(ligne," ProbablyLost");
   }
   if (((aster.code6==4)||(aster.code6==3))&&(aster.num!=0)) {
      strcat(ligne," ObsRequired");
   }
}

void mc_xvxpla(double jj, int planete, double jj_equinoxe, double *x, double *y,double *z, double *vx, double *vy,double *vz)
/***************************************************************************/
/* Calcul de pos. et vit. cart. equ. heliocent. d'une planete a jj donne.  */
/***************************************************************************/
/* heliocentriques.                                                        */
/***************************************************************************/
{
   double llp[10],mmp[10],uup[10],eps;
   double l,b,r;
   double jj0[4],x0[4],y0[4],z0[4],r0[4],kay[4],dt,yg[4],f,g,vx1,vy1,vz1,mu;
   int k,k0,k1,k2;

   mu=(K)*(K);

   mc_obliqmoy(jj_equinoxe,&eps);
   for (k=1;k<=3;k++) {
      jj0[k]=jj+1.000*(k-1);
      mc_jd2lbr1a(jj0[k],llp,mmp,uup);
      mc_jd2lbr1b(jj0[k],planete,llp,mmp,uup,&l,&b,&r);
      mc_lbr2xyz(l,b,r,&x0[k],&y0[k],&z0[k]);
      mc_xyzec2eq(x0[k],y0[k],z0[k],eps,&x0[k],&y0[k],&z0[k]);
      mc_precxyz(jj0[k],x0[k],y0[k],z0[k],jj_equinoxe,&x0[k],&y0[k],&z0[k]); /* equatoriale J2000 */
      r0[k]=sqrt(x0[k]*x0[k]+y0[k]*y0[k]+z0[k]*z0[k]);
   }

   /*--- calcul des ratio d'aire des secteurs ---*/
   for (k=1;k<=3;k++) {
      k1=(int) (1+fmod(k  ,3));
      k2=(int) (1+fmod(k+1,3));
      dt=jj0[k2]-jj0[k1];
      if (dt<0) {
         dt=-dt;
         k0=k1;k1=k2;k2=k0;
      }
      kay[k]=sqrt(2*(x0[k1]*x0[k2]+y0[k1]*y0[k2]+z0[k1]*z0[k2])+2*r0[k1]*r0[k2]);
/*
printf("k1=%d k2=%d k=%d r0[k1]=%f r0[k2]=%f kay=%f dt=%f\n",
k1,k2,k,r0[k1],r0[k2],kay[k],dt,yg[k]);
*/
      mc_secratio(r0[k1],r0[k2],kay[k],dt,K,&yg[k]);
   }

   /*--- vecteur vitesse a l'instant 1 ---*/
   f=1-2*dt*dt*mu/(kay[3]*kay[3]*yg[3]*yg[3]*r0[1]);
   g=dt/yg[3];
   vx1=(x0[2]-f*x0[1])/g;
   vy1=(y0[2]-f*y0[1])/g;
   vz1=(z0[2]-f*z0[1])/g;

   *x=x0[1];
   *y=y0[1];
   *z=z0[1];
   *vx=vx1;
   *vy=vy1;
   *vz=vz1;
}


void mc_affielem(struct elemorb elem)
/***************************************************************************/
/* Affiche les elements d'orbite en clair a l'ecran.                       */
/***************************************************************************/
{
   double jour,periode,a;
   int annee,mois;
   /*--- affichage des elements d'orbite ---*/
   mc_jd_date(elem.jj_m0,&annee,&mois,&jour);
   printf("M0=%fø a jj=%f (%d %d %f)\n",elem.m0/(DR),elem.jj_m0,annee,mois,jour);
   mc_jd_date(elem.jj_perihelie,&annee,&mois,&jour);
   printf("e=%f q=%f Tq=%f (%d %d %f)\n",elem.e,elem.q,elem.jj_perihelie,annee,mois,jour);
   if (elem.e!=1) {
      a=elem.q/(1-elem.e);
      printf("a=%f ",a);
      if (elem.e<1) {
         periode=sqrt(a*a*a);
         printf("P=%f ans",periode);
      }
      printf("\n");
   }
   printf("i=%fd o=%fd w=%fd\n",elem.i/(DR),elem.o/(DR),elem.w/(DR));
   mc_jd_date(elem.jj_equinoxe,&annee,&mois,&jour);
   printf("equinoxe : jj=%f (%d %d %f)\n",elem.jj_equinoxe,annee,mois,jour);
   mc_jd_date(elem.jj_epoque,&annee,&mois,&jour);
   printf("epoque   : jj=%f (%d %d %f)\n",elem.jj_epoque,annee,mois,jour);
   if (elem.type==COMETE) {
      printf("m0=%3.3f n=%3.3f\n",elem.h0,elem.n);
   } else if (elem.type==ASTEROIDE) {
      printf("h=%3.3f g=%2.2f\n",elem.h,elem.g);
   }
}
