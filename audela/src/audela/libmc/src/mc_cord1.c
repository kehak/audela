/* mc_cord1.c
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
/* Transformation de systemes de coordonnees                               */
/***************************************************************************/
#include "mc.h"

void mc_anomoy(struct elemorb elem,double jd,double *m)
/***************************************************************************/
/* Calcul de M a partir de Mo et des elements d'orbite                     */
/***************************************************************************/
/* ENTREES :                                                               */
/* elempla : structure des elements d'orbite M, e et q                     */
/*           calcules a l'instant de l'observation                         */
/*           Angles en radians modulo 2*PI                                 */
/* SORTIES :                                                               */
/* *m : anomalie moyenne                                                  */
/***************************************************************************/
{
   double e,a,q,m0,jdm0,n,k_gauss;
   q=elem.q;
   e=elem.e;
   m0=elem.m0;
   jdm0=elem.jj_m0;
   if (elem.type==4) {
      k_gauss=KGEOS;
   } else {
      k_gauss=K;
   }
   if (e==1) {
      n=k_gauss/(DR)/q/sqrt(2*q);
   } else {
      a=q/fabs(1-e);
      n=k_gauss/(DR)/a/sqrt(a);
   }
   *m=(m0+(jd-jdm0)*n*DR);
}

void mc_anovrair(struct elemorb elempla,double m,double *v,double *r)
/***************************************************************************/
/* Calcul de v et r dans le cas d'une orbite                               */
/***************************************************************************/
/* ENTREES :                                                               */
/* elempla : structure des elements d'orbite e et q                        */
/*           calcules a l'instant de l'observation                         */
/*           Angles en radians modulo 2*PI                                 */
/* m       : anomalie moyenne                                              */
/* SORTIES :                                                               */
/* *v : anomalie vraie                                                     */
/* *r : rayon vecteur                                                      */
/***************************************************************************/
{
   double q,u,e,a,u0,vv,rr,cosv,sinv,s,w;
   /* --- Decomposition de la structure des elements d'orbite --- */
   e=elempla.e;
   q=elempla.q;
   if (e<1) {
      a=q/(1-e);
      /* --- calcul de l'anomalie excentrique ---*/
      /* --- Equation de Kepler : 1ere methode --- */
      if (e<0.95) {u=m;}
      else {u=mc_sgn2(m)*sqrt(6*fabs(m));}
      do {
         u0=u;
         u=u0-(u0-e*sin(u0)-m)/(1-e*cos(u0));
      } while (fabs(u-u0)>1e-10);
      u=fmod(u,2*PI);
      /* --- calcul du rayon vecteur ---*/
      rr=a*(1-e*cos(u));
      /* --- calcul de l'anomalie vraie ---*/
      cosv=a*(cos(u)-e)/rr;
      sinv=a*sqrt(1-e*e)*sin(u)/rr;
      vv=atan2(sinv,cosv);
      vv=fmod(vv,2*PI);
   } else if (e==1) {
      /* --- calcul de l'anomalie excentrique ---*/
      w=3.*m/2;
      u=2*sinh(1./3*log(w+sqrt(w*w+1)));
      s=u;
      /* --- calcul du rayon vecteur ---*/
      rr=q*(1+s*s);
      /* --- calcul de l'anomalie vraie ---*/
      cosv=q*(1-s*s)/rr;
      sinv=2*q*s/rr;
      vv=atan2(sinv,cosv);
      vv=fmod(vv,2*PI);
   } else /* if (e>1) */ {
      a=q/(e-1);
      /* --- calcul de l'anomalie excentrique ---*/
      u=m;
      do {
         u0=u;
         u=u0-(e*sinh(u0)-u0-m)/(e*cosh(u0)-1);
      } while (fabs(u-u0)>1e-10);
      /* --- calcul du rayon vecteur ---*/
      rr=a*(e*cosh(u)-1);
      /* --- calcul de l'anomalie vraie ---*/
      cosv=a*(e-cosh(u))/rr;
      sinv=a*sqrt(e*e-1)*sinh(u)/rr;
      vv=atan2(sinv,cosv);
      vv=fmod(vv,2*PI);
   }
   *v=vv;
   *r=rr;
}

void mc_aster2elem(struct asterident aster, struct elemorb *elem)
/***************************************************************************/
/* Copie les valeurs d'elements d'orbite definis a partir de la structure  */
/* asterident vers les elements d'orbites definis a partir de la structure */
/* elemorb. (utile pour la base de Bowell).                                */
/***************************************************************************/
/***************************************************************************/
{
   double n;
   if (aster.num==0) {
      sprintf(elem->designation,"{%s}",aster.name);
   } else {
      sprintf(elem->designation,"{(%d) %s}",aster.num,aster.name);
   }
   elem->m0=aster.m0;
   elem->jj_m0=aster.jj_m0;
   elem->e=aster.e;
   elem->q=aster.a*fabs(1-aster.e);
   n=K/(DR)/aster.a/sqrt(aster.a);
   elem->jj_perihelie=aster.jj_m0-aster.m0/n/(DR);
   elem->i=aster.i;
   elem->o=aster.o;
   elem->w=aster.w;
   elem->jj_equinoxe=aster.jj_equinoxe;
   elem->jj_epoque=aster.jj_epoque;
   elem->type=ASTEROIDE;
   elem->h=aster.h;
   elem->g=aster.g;
   elem->nbjours=aster.nbjours;
   elem->nbobs=aster.nbobs;
   elem->ceu0=aster.ceu0;
   elem->ceut=aster.ceut;
   elem->jj_ceu0=aster.jj_ceu0;
   elem->code1=aster.code1;
   elem->code2=aster.code2;
   elem->code3=aster.code3;
   elem->code4=aster.code4;
   elem->code5=aster.code5;
   elem->code6=aster.code6;
}

void mc_copyelem(struct elemorb elem1, struct elemorb *elem2)
/***************************************************************************/
/* Duplique les caracteristiques de elem1 vers elem2                       */
/***************************************************************************/
/***************************************************************************/
{
   strcpy(elem2->designation,elem1.designation);
   elem2->m0=elem1.m0;
   elem2->jj_m0=elem1.jj_m0;
   elem2->e=elem1.e;
   elem2->q=elem1.q;
   elem2->jj_perihelie=elem1.jj_perihelie;
   elem2->jj_epoque=elem1.jj_epoque;
   elem2->i=elem1.i;
   elem2->o=elem1.o;
   elem2->w=elem1.w;
   elem2->jj_equinoxe=elem1.jj_equinoxe;
   elem2->type=elem1.type;
   elem2->h0=elem1.h0;
   elem2->n=elem1.n;
   elem2->h=elem1.h;
   elem2->g=elem1.g;
   elem2->nbjours=elem1.nbjours;
   elem2->nbobs=elem1.nbobs;
   elem2->ceu0=elem1.ceu0;
   elem2->ceut=elem1.ceut;
   elem2->jj_ceu0=elem1.jj_ceu0;
   elem2->code1=elem1.code1;
   elem2->code2=elem1.code2;
   elem2->code3=elem1.code3;
   elem2->code4=elem1.code4;
   elem2->code5=elem1.code5;
   elem2->code6=elem1.code6;
}

void mc_elem2aster(struct elemorb elem,struct asterident *aster)
/***************************************************************************/
/* Copie les valeurs d'elements d'orbite definis a partir de la structure  */
/* elemorb vers les elements d'orbites definis a partir de la structure    */
/* asterident. (utile pour la base de Bowell).                             */
/***************************************************************************/
/***************************************************************************/
{
   char chaine[80];
   if (elem.designation[0]=='(') {
      strcpy(chaine,elem.designation+1);
      aster->num=atoi(chaine);
   } else {
      aster->num=0;
   }
   aster->m0=elem.m0;
   aster->jj_m0=elem.jj_m0;
   aster->e=elem.e;
   if (elem.e!=1) {
      aster->a=elem.q/fabs(1-elem.e);
   } else {
      aster->a=1e6;
   }
   aster->i=elem.i;
   aster->o=elem.o;
   aster->w=elem.w;
   aster->jj_equinoxe=elem.jj_equinoxe;
   aster->jj_epoque=elem.jj_epoque;
   aster->h=elem.h;
   aster->g=elem.g;
   aster->nbjours=elem.nbjours;
   aster->nbobs=elem.nbobs;
   aster->ceu0=elem.ceu0;
   aster->ceut=elem.ceut;
   aster->jj_ceu0=elem.jj_ceu0;
   aster->code1=elem.code1;
   aster->code2=elem.code2;
   aster->code3=elem.code3;
   aster->code4=elem.code4;
   aster->code5=elem.code5;
   aster->code6=elem.code6;
}

void mc_elempqec(struct elemorb elem, struct pqw *vect)
/***************************************************************************/
/* Retourne la valeur des composante des vecteurs P' Q' et W' ecliptique   */
/* a partir de o,w,i                                                       */
/***************************************************************************/
/***************************************************************************/
{
   vect->px=( cos(elem.o)*cos(elem.w)-sin(elem.o)*sin(elem.w)*cos(elem.i));
   vect->py=( sin(elem.o)*cos(elem.w)+cos(elem.o)*sin(elem.w)*cos(elem.i));
   vect->pz=( sin(elem.w)*sin(elem.i));
   vect->qx=(-cos(elem.o)*sin(elem.w)-sin(elem.o)*cos(elem.w)*cos(elem.i));
   vect->qy=(-sin(elem.o)*sin(elem.w)+cos(elem.o)*cos(elem.w)*cos(elem.i));
   vect->qz=( cos(elem.w)*sin(elem.i));
   vect->wx=( sin(elem.o)*sin(elem.i));
   vect->wy=(-cos(elem.o)*sin(elem.i));
   vect->wz=  cos(elem.i) ;
}

void mc_elempqeq(struct pqw vectec, double eps, struct pqw *vecteq)
/***************************************************************************/
/* Retourne la valeur des composante des vecteurs P Q et W equatoriaux     */
/* a partir de P' Q' W' ecliptiques et de l'obliquite eps                  */
/***************************************************************************/
/***************************************************************************/
{
   double cose,sine,px,py,pz,qx,qy,qz,wx,wy,wz;
   cose=cos(eps);
   sine=sin(eps);
   px= vectec.px;
   py= vectec.py*cose - vectec.pz*sine;
   pz= vectec.py*sine + vectec.pz*cose;
   qx= vectec.qx;
   qy= vectec.qy*cose - vectec.qz*sine;
   qz= vectec.qy*sine + vectec.qz*cose;
   wx= vectec.wx;
   wy= vectec.wy*cose - vectec.wz*sine;
   wz= vectec.wy*sine + vectec.wz*cose;
   vecteq->px= px;
   vecteq->py= py;
   vecteq->pz= pz;
   vecteq->qx= qx;
   vecteq->qy= qy;
   vecteq->qz= qz;
   vecteq->wx= wx;
   vecteq->wy= wy;
   vecteq->wz= wz;
}

void mc_he2ge(double xh,double yh,double zh,double xs,double ys,double zs,double *xg,double *yg,double *zg)
/***************************************************************************/
/* Translation du repere heliocentrique en geocentrique (cartesien)        */
/***************************************************************************/
/* ENTREES :                                                               */
/* xh,yh,zh : coordonnees heliocentriques de l'astre                       */
/* xs,ys,zs : coordonnees geocentriques du Soleil                          */
/* SORTIES :                                                               */
/* *xg,*yg,*zg : coordonnees geocentriques de l'astre                      */
/***************************************************************************/
{
   *xg=xh+xs;
   *yg=yh+ys;
   *zg=zh+zs;
}

void mc_lbr2xyz(double l, double b, double r, double *x, double *y, double *z)
/***************************************************************************/
/* Transforme les coord. spher. en coord. cart.                            */
/***************************************************************************/
/***************************************************************************/
{
   double cosb,sinb,cosl,sinl;
   cosb=cos(b);
   sinb=sin(b);
   cosl=cos(l);
   sinl=sin(l);
   *x=r*cosb*cosl;
   *y=r*cosb*sinl;
   *z=r*sinb;
}

void mc_rv_xyz(struct pqw vectpqw, double r, double v, double *x, double *y, double *z)
/***************************************************************************/
/* Retourne la valeur des composante des vecteurs position (x,y,z)         */
/* a partir de l'anomalie vraie et du rayon vecteur                        */
/***************************************************************************/
/* ENTREES :                                                               */
/* vectpqw : elements orbitaux PQW (mc_elempqec et mc_elempqeq) heliocent  */
/*           mc_elempqec pour l'ecliptique ou                              */
/*           mc_elempqec suivit de mc_elempqeq pour equatorial             */
/* r       : rayon vecteur (en UA)                                         */
/* v       : anomalie vraie (en radians)                                   */
/* SORTIES :                                                               */
/* *x, *y, *z : coordonnees cartesiennes de la position                    */
/***************************************************************************/
{
   double xx,yy;
   xx=r*cos(v);
   yy=r*sin(v);
   *x=vectpqw.px*xx+vectpqw.qx*yy;
   *y=vectpqw.py*xx+vectpqw.qy*yy;
   *z=vectpqw.pz*xx+vectpqw.qz*yy;
}

void mc_rv_vxyz(struct pqw vectpqw, struct elemorb elem, double r, double v, double *vx, double *vy, double *vz)
/***************************************************************************/
/* Retourne la valeur des composante des vecteurs vitesse (vx,vy,vz) helio */
/* a partir de l'anomalie vraie et du rayon vecteur                        */
/***************************************************************************/
/* ENTREES :                                                               */
/* vectpqw : elements orbitaux PQW (mc_elempqec et mc_elempqeq)            */
/*           mc_elempqec pour l'ecliptique ou                              */
/*           mc_elempqec suivit de mc_elempqeq pour equatorial             */
/* elem    : elements orbitaux angulaires (e,q sont utilises)              */
/* r       : rayon vecteur (en UA)                                         */
/* v       : anomalie vraie (en radians)                                   */
/* SORTIES :                                                               */
/* *vx, *vy, *vz : coordonnees cartesiennes de la vitesse (ua/j)           */
/*                                                                         */
/* ref : Dumoulin C., Parisot J.-P. "Astronomie pratique et informatique"  */
/*       1987, ed. Masson                                                  */
/* Formules pp 197-198                                                     */
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules pp 134-135                                                     */
/***************************************************************************/
{
   double xx,yy,e,p,p0,pp,qq,vx0,vy0,vz0;
   xx=r*cos(v);
   yy=r*sin(v);
   e=elem.e;
   p=elem.q*fabs(1+e);
   p0=K*sqrt(p)/r/r;
   pp=(e*xx/p-1)*yy;
   qq=e*yy*yy/p+xx;
   vx0=p0*(pp*vectpqw.px + qq*vectpqw.qx);
   vy0=p0*(pp*vectpqw.py + qq*vectpqw.qy);
   vz0=p0*(pp*vectpqw.pz + qq*vectpqw.qz);
   *vx=vx0;
   *vy=vy0;
   *vz=vz0;
}

void mc_xvx2elem(double x, double y, double z, double vx, double vy, double vz, double jj, double jj_equinoxe, double kgrav, struct elemorb *elem)
/***************************************************************************/
/* Calcule les elements d'orbite a partir des vecteurs position et vitesse */
/* dans le repere heliocentrique ecliptique.                               */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules pp 204-206                                                     */
/* ref : Dumoulin C., Parisot J.-P. "Astronomie pratique et informatique"  */
/*       1987, ed. Masson                                                  */
/* Formules pp 199-200                                                     */
/* ref : Boulet D., "Methods of orbit determination for the microcomputer" */
/*       1991, William Bell                                                */
/* Formules pp 151-157                                                     */
/* Listing pp 169-173                                                      */
/***************************************************************************/
{
   double mu=1;
   double m,hx,hy,hz,ex,ey,ez,o,i,w,e,r,v,rv,a0,a,ecosu,esinu;
   double parab=1e-4,jjaber=J2000;
   double q,tau,cosw,n,jj_q,h,u,zz,m0,cosi;

   m=mu*(kgrav)*(kgrav); /* K2=GM et v2=GM/a => GM=av2  m3/j2 */
   v=sqrt(vx*vx+vy*vy+vz*vz);
   r=sqrt(x*x+y*y+z*z);

   mc_prodscal(x,y,z,vx,vy,vz,&rv);
   mc_prodvect(x,y,z,vx,vy,vz,&hx,&hy,&hz);
   h=sqrt(hx*hx+hy*hy+hz*hz);

   ex=(v*v/m-1/r)*x-rv/m*vx;
   ey=(v*v/m-1/r)*y-rv/m*vy;
   ez=(v*v/m-1/r)*z-rv/m*vz;
   e=sqrt(ex*ex+ey*ey+ez*ez);

   cosi=hz/h;

   if (fabs(cosi)<=1) {
      i=mc_acos(cosi);
      o=atan2(hx,-hy);
      cosw=(ex*cos(o)+ey*sin(o));
      if (i==0) {
         w=PI/2*mc_sgn(ez*cosw);
      } else {
         w=atan2((ez/sin(i)),cosw);
      }
   } else {
      i=0; /* orbite aberrante */
      o=0;
      w=0;
      e=0;
      rv=0;
      r=1;
      v=sqrt(m/r);
   }
   if (jj==PLOSS) {
      jj=jjaber;
   }
   a0=2/r-v*v/m;
   a=1/a0;
   if (a0>parab) {
      /*--- orbite elliptique ---*/
      q=a*(1-e);
      ecosu=(1-r/a);
      esinu=rv/sqrt(a*m);
      u=atan2(esinu,ecosu);
      jj_q=jj-(u-e*sin(u))*sqrt(a*a*a/m);
   } else if (a0<-parab) {
      /*--- orbite hyperbolique ---*/
      q=fabs(a*(1-e));
      zz=(1-r/a)/e;
      u=log(zz+sqrt(fabs(zz*zz-1)))*mc_sgn(rv);
      jj_q=jj-(e*sinh(u)-u)*sqrt(-a*a*a/m);
   } else {
      /*--- orbite parabolique ---*/
      e=1.0;
      q=h*h/2/m;
      tau=sqrt(r/q-1)*mc_sgn(rv);
      jj_q=jj-(tau*tau*tau/3+tau)*sqrt(2*q*q*q/m);
   }

   /*--- on rapporte l'angle d'anomalie vraie a la date d'observation ---*/
   if (e==1) {
      n=kgrav/(DR)/q/sqrt(2*q);
   } else {
      a=q/fabs(1-e);
      n=kgrav/(DR)/a/sqrt(a);
   }
   m0=0;
   m0=(m0+(jj-jj_q)*n*DR);

   /*--- mise en forme finale au format de la structure elemorb ---*/
   o=fmod(4*PI+o,2*PI);
   w=fmod(4*PI+w,2*PI);
   i=fmod(4*PI+i,2*PI);
   m0=fmod(4*PI+m0,2*PI);

   elem->m0=m0;
   elem->jj_m0=jj;
   elem->e=e;
   elem->q=q;
   elem->jj_perihelie=jj_q;
   elem->i=i;
   elem->o=o;
   elem->w=w;
   elem->jj_equinoxe=jj_equinoxe;  /* A VOIR */
   elem->jj_epoque=jj;

   /*--- on rapporte les angles i o w a l'equinoxe de reference ---*/
/*
   mc_precelem(*elem,jj,jj_equinoxe,elem);
*/
}

void mc_xyz2lbr(double x, double y, double z, double *l, double *b, double *r)
/***************************************************************************/
/* Transforme les coord. cart. en coord. spher.                            */
/***************************************************************************/
/***************************************************************************/
{
   double r0,b0,l0;
   r0=sqrt(x*x+y*y+z*z);
   b0=mc_asin(z/r0);
   l0=fmod((4*PI+atan2(y,x)),(2*PI));
   *r=r0;
   *b=b0;
   *l=l0;
}

void mc_xyz2add(double xg, double yg, double zg, double *asd, double *dec, double *delta)
/***************************************************************************/
/* Transforme les coord. cart. geoc. equatoriales en spheriques            */
/***************************************************************************/
/***************************************************************************/
{
   double r;
   r=sqrt(xg*xg+yg*yg+zg*zg);
   *dec=mc_asin(zg/r);
   *asd=fmod(4*PI+atan2(yg,xg),2*PI);
   *delta=r;
}

void mc_xyzec2eq(double xec, double yec, double zec, double eps, double *xeq, double *yeq, double *zeq)
/***************************************************************************/
/* Transforme les coord. cart. ecliptiques vers equatoriales               */
/***************************************************************************/
/***************************************************************************/
{
   double xeq0,yeq0,zeq0;
   xeq0=xec;
   yeq0=yec*cos(eps)-zec*sin(eps);
   zeq0=yec*sin(eps)+zec*cos(eps);
   *xeq=xeq0;
   *yeq=yeq0;
   *zeq=zeq0;
}

void mc_xyzeq2ec(double xeq, double yeq, double zeq, double eps, double *xec, double *yec, double *zec)
/***************************************************************************/
/* Transforme les coord. cart. equatoriales vers ecliptiques               */
/***************************************************************************/
/***************************************************************************/
{
   double xec0,yec0,zec0;
   eps=-eps;
   xec0=xeq;
   yec0=yeq*cos(eps)-zeq*sin(eps);
   zec0=yeq*sin(eps)+zeq*cos(eps);
   *xec=xec0;
   *yec=yec0;
   *zec=zec0;
}

void mc_ad2hd(double jd, double longuai, double asd, double *ha)
/***************************************************************************/
/* Transforme l'ascension droite en angle horaire                           */
/***************************************************************************/
/***************************************************************************/
{
   double tsl,h;
   /* --- calcul du TSL en radians ---*/
   mc_tsl(jd,-longuai,&tsl);
   h=tsl-asd;
   *ha=fmod(4*PI+h,2*PI);
}

void mc_hd2ad(double jd, double longuai, double ha, double *asd)
/***************************************************************************/
/* Transforme l'angle horaire en ascension droite                          */
/***************************************************************************/
/***************************************************************************/
{
   double tsl,ra;
   /* --- calcul du TSL en radians ---*/
   mc_tsl(jd,-longuai,&tsl);
   ra=tsl-ha;
   *asd=fmod(4*PI+ra,2*PI);
}

void mc_hd2parallactic(double ha, double dec, double latitude, double *parallactic)
/***************************************************************************/
/* Transforme les coord. sph. equatoriales vers angle parallactic          */
/***************************************************************************/
/* ha est l'angle horaire local.                                           */
/***************************************************************************/
{
   double aa;
   if (fabs(latitude)>=PISUR2) { aa=0;}
   else if ((ha==0.)&&(dec==latitude)) { aa=0.; }
   else {
      aa=atan2(sin(ha),cos(dec)*tan(latitude)-sin(dec)*cos(ha));
   }
   *parallactic=aa;
}

void mc_hd2parallactic_altalt(double ha, double dec, double latitude, double *parallactic)
/***************************************************************************/
/* Transforme les coord. sph. equatoriales vers angle parallactic altalt   */
/***************************************************************************/
/* ha est l'angle horaire local.                                           */
/***************************************************************************/
{
   double aa;
   if (fabs(latitude)>=PISUR2) { aa=0;}
   else if ((ha==0.)&&(dec==latitude)) { aa=0.; }
   else {
      aa=atan2(sin(ha),cos(dec)/tan(latitude)+sin(dec)*cos(ha));
   }
   *parallactic=aa;
}

void mc_hd2ah(double ha, double dec, double latitude, double *az, double *h)
/***************************************************************************/
/* Transforme les coord. sph. equatoriales vers sph. azinuth hauteur       */
/***************************************************************************/
/* ha est l'angle horaire local.                                           */
/***************************************************************************/
{
   double aa,hh;
   if (dec>=PISUR2) { aa=(PI); hh=latitude;}
   else if (dec<=-PISUR2) { aa=0.; hh=-latitude;}
   else {
      aa=atan2(sin(ha),cos(ha)*sin(latitude)-tan(dec)*cos(latitude));
      hh=mc_asin(sin(latitude)*sin(dec)+cos(latitude)*cos(dec)*cos(ha));
   }
   *az=fmod(4*PI+aa,2*PI);
   *h=hh;
}

void mc_ah2hd(double az, double h, double latitude, double *ha, double *dec)
/***************************************************************************/
/* Transforme les coord. sph. azinuth hauteur vers sph. equatoriales       */
/***************************************************************************/
/* ha est l'angle horaire local.                                           */
/***************************************************************************/
{
   double ahh,decc;
   if (h>=PISUR2) { ahh=0.; decc=latitude;}
   else if (h<=-PISUR2) { ahh=0.; decc=-latitude;}
   else {
      ahh=atan2(sin(az),cos(az)*sin(latitude)+tan(h)*cos(latitude));
      decc=mc_asin(sin(latitude)*sin(h)-cos(latitude)*cos(h)*cos(az));
   }
   *ha=fmod(4*PI+ahh,2*PI);
   *dec=decc;
}

void mc_hd2rp(double ha, double dec, double latitude, double *az, double *h)
/***************************************************************************/
/* Transforme les coord. sph. equatoriales vers sph. roulis assiette       */
/***************************************************************************/
/* ha est l'angle horaire local.                                           */
/***************************************************************************/
{
   double aa,hh;
   if (dec>=PISUR2) { aa=(PI); hh=latitude;}
   else if (dec<=-PISUR2) { aa=0.; hh=-latitude;}
   else {
      aa=atan2(sin(ha),cos(ha)*cos(latitude)+tan(dec)*sin(latitude));
      hh=mc_asin(cos(latitude)*sin(dec)-sin(latitude)*cos(dec)*cos(ha));
   }
   *az=fmod(4*PI+aa,2*PI);
   *h=hh;
}

void mc_rp2hd(double az, double h, double latitude, double *ha, double *dec)
/***************************************************************************/
/* Transforme les coord. sph. roulis assiette vers sph. equatoriales       */
/***************************************************************************/
/* ha est l'angle horaire local.                                           */
/***************************************************************************/
{
   double ahh,decc;
   if (h>=PISUR2) { ahh=0.; decc=latitude;}
   else if (h<=-PISUR2) { ahh=0.; decc=-latitude;}
   else {
      ahh=atan2(sin(az),cos(az)*cos(latitude)-tan(h)*sin(latitude));
      decc=mc_asin(cos(latitude)*sin(h)+sin(latitude)*cos(h)*cos(az));
   }
   *ha=fmod(4*PI+ahh,2*PI);
   *dec=decc;
}

void mc_ad2ah(double jd, double longuai, double latitude, double asd, double dec, double *az,double *h)
/***************************************************************************/
/* Transforme les coord. sph. equatoriales vers sph. azinuth hauteur       */
/***************************************************************************/
/***************************************************************************/
{
   double ha;
   mc_ad2hd(jd,longuai,asd,&ha);
   mc_hd2ah(ha,dec,latitude,az,h);
}

void mc_radec2galactic(double ra2000, double dec2000, double *lon,double *lat)
/***************************************************************************/
/* Transforme les coord. sph. equatoriales J2000.0 vers sph. galactiques   */
/***************************************************************************/
/***************************************************************************/
{
   double psi=0.57477043300;
   double st=0.88998808748;
   double ct=0.45598377618;
   double phi=4.9368292465;
   double a,b,aa,bb;
   a=ra2000-phi;
   b=dec2000;
   bb=mc_asin(-st*cos(b)*sin(a)+ct*sin(b));
   aa=mc_atan2(ct*cos(b)*sin(a)+st*sin(b),cos(b)*cos(a));
   *lon=fmod(4*PI+aa+psi,2*PI);
   *lat=bb;
}

void mc_galactic2radec(double lon,double lat, double *ra2000, double *dec2000)
/***************************************************************************/
/* Transforme les coord. sph. galactiques vers sph. equatoriales J2000.0   */
/***************************************************************************/
/***************************************************************************/
{
   double psi=4.9368292465;
   double st=-0.88998808748;
   double ct=0.45598377618;
   double phi=0.57477043300;
   double a,b,aa,bb;
   a=lon-phi;
   b=lat;
   bb=mc_asin(-st*cos(b)*sin(a)+ct*sin(b));
   aa=mc_atan2(ct*cos(b)*sin(a)+st*sin(b),cos(b)*cos(a));
   *ra2000=fmod(4*PI+aa+psi,2*PI);
   *dec2000=bb;
}

void mc_map_xy2lonlat(double lc, double bc, double p, double f, double xc, double yc, double rc, double ls, double bs, double power,double i,double j,double *lon,double *lat,double *visibility)
/****************************************************************************/
/* Conversion of a pixel (i,j) towards planetographics coordinates.         */
/*                                                                          */
/* inputs :                                                                 */
/* lc : center longitude (radians)                                          */
/* bc : center latitude (radians)                                           */
/* p : position angle of the north pole (radians)                           */
/* f : ratio of the polar and equatorial radius of the planet               */
/* xc : X center position of the planet on the image (pixel)                */
/* yc : Y center position of the planet on the image (pixel)                */
/* rc : equatorial radius of the planet on the image (pixel)                */
/* ls : sun longitude in planetographic coordinates (radian) [optional]     */
/* bs : sun latitude in planetographic coordinates (radian) [optional]      */
/* power : power of a cosinus law to predict berder extinction [optional]   */
/* i : x position on the image to convert (pixels)                          */
/* j : y position on the image to convert (pixels)                          */
/*                                                                          */
/* outputs :                                                                */
/* lon : longitude on a planetographic map (radian)                         */
/* lat : longitude on a planetographic map (radian)                         */
/* visibility : lightning attenuation (0 when dark to 1 for brightenest     */
/*              and -1 if the region if back).                              */
/****************************************************************************/
{
   double a,b,c,delta,X,Y,x,y,z,u,u0,unf,pisur2,sepang,posang;
   int sortie,compteur;
   double lonplus,visplus,uplus;
   /*double lonmoins,vismoins,umoins;*/

   X=(i-xc)/rc;
   Y=(j-yc)/rc;
   y=cos(p)*X+sin(p)*Y;
   sortie=0;
   a=1+(tan(bc)*tan(bc));
   b=2*sin(bc)/cos(bc)/cos(bc)*(Y*cos(p)-X*sin(p));
   *lon=lonplus=0.;
   /* --- solution positive : point devant la planete ---*/
   u=u0=0;
   compteur=0;
   while (sortie==0) {
      unf=1.+f*(f-2)*sin(u0)*sin(u0);
      c=pow((Y*cos(p)-X*sin(p))/cos(bc),2)+pow(Y*sin(p)+X*cos(p),2)-unf;
      delta=b*b-4*a*c;
      visplus=-1.;
      if (delta>=0) {
         visplus=1.;
         x=(-b+sqrt(delta))/(2*a);
         z=tan(bc)*x+(cos(p)*Y-sin(p)*X)/cos(bc);
         /*z=mc_sqrt(unf-x*x-y*y);*/
         u=mc_asin(z/(1-f));
         lonplus=lc+mc_atan2(y,x);
         lonplus=fmod(8*PI+lonplus,2*PI);
         if (fabs((u-u0)/(DR)*1e8)<1.) {
            sortie=1;
         }
         u0=u;
      } else {
         sortie=1;
      }
      if (compteur++>15) {
         sortie=1;
      }
   }
   uplus=u;
   /* --- solution negative : point derriere la planete ---*/
   /*
   u=u0=0;
   compteur=0;
   sortie=0;
   while (sortie==0) {
      unf=1.+f*(f-2)*sin(u0)*sin(u0);
      c=pow((Y*cos(p)-X*sin(p))/cos(bc),2)+pow(Y*sin(p)+X*cos(p),2)-unf;
      delta=b*b-4*a*c;
      vismoins=-1.;
      if (delta>=0) {
         vismoins=1.;
         x=(-b-sqrt(delta))/(2*a);
         z=tan(bc)*x+(cos(p)*Y-sin(p)*X)/cos(bc);
         u=mc_asin(z/(1-f));
         lonmoins=lc+mc_atan2(y,x);
         lonmoins=fmod(8*PI+lonmoins,2*PI);
         if (fabs((u-u0)/(DR)*1e8)<1.) {
            sortie=1;
         }
         u0=u;
      } else {
         sortie=1;
      }
      if (compteur++>15) {
         sortie=1;
      }
   }
   umoins=u;
   */
   /* */
   *visibility=visplus;
   *lon=lonplus;
   u=uplus;
   /* */
   if (*visibility==1.) {
      pisur2=acos(0.);
      if (u>=pisur2) {*lat=pisur2;}
      else if (u<=-pisur2) {*lat=-pisur2;}
      else {
         *lat=atan(tan(u)/(1-f));
      }
   } else {
      *lat=0.;
   }
   mc_sepangle(ls,*lon,bs,*lat,&sepang,&posang);
   if (*visibility>=0) {
      if (cos(sepang)>0) {
         /* - visible et eclaire par le soleil -*/
         *visibility*=pow(cos(sepang),power);
      } else {
         /* - visible mais dans l'ombre -*/
         /* - y ajouter la lumiere cendree enventuellement */
         *visibility=0.;
      }
   }
   return;
}

void mc_map_lonlat2xy(double lc, double bc, double p, double f, double xc, double yc, double rc, double ls, double bs, double power,double lon,double lat,double *i,double *j,double *visibility)
/****************************************************************************/
/* Conversion planetographics coordinates towards a pixel (i,j).            */
/*                                                                          */
/* inputs :                                                                 */
/* lc : center longitude (radians)                                          */
/* bc : center latitude (radians)                                           */
/* p : position angle of the north pole (radians)                           */
/* f : ratio of the polar and equatorial radius of the planet               */
/* xc : X center position of the planet on the image (pixel)                */
/* yc : Y center position of the planet on the image (pixel)                */
/* rc : equatorial radius of the planet on the image (pixel)                */
/* ls : sun longitude in planetographic coordinates (radian) [optional]     */
/* bs : sun latitude in planetographic coordinates (radian) [optional]      */
/* power : power of a cosinus law to predict berder extinction [optional]   */
/* lon : longitude on a planetographic map (radian)                         */
/* lat : longitude on a planetographic map (radian)                         */
/*                                                                          */
/* outputs :                                                                */
/* i : x position on the image to convert (pixels)                          */
/* j : y position on the image to convert (pixels)                          */
/* visibility : lightning attenuation (0 when dark to 1 for brightenest     */
/*              and -1 if the region if back).                              */
/****************************************************************************/
{
   double xx,X,Y,x,y,z,u,pisur2,sepang,posang;

   pisur2=acos(0.);
   if (lat>=pisur2) {u=pisur2;}
   else if (lat<=-pisur2) {u=-pisur2;}
   else {
      if (lat!=0) {
         u=atan((1-f)*tan(lat));
      } else {
         u=lat;
      }
   }
   x=cos(lon-lc)*cos(u);
   y=sin(lon-lc)*cos(u);
   z=(1-f)*sin(u);
   xx=cos(bc)*x+sin(bc)*z;
   X= sin(bc)*sin(p)*x+cos(p)*y-cos(bc)*sin(p)*z;
   Y=-sin(bc)*cos(p)*x+sin(p)*y+cos(bc)*cos(p)*z;
   if (xx>=0) {
      *visibility=1.;  /* face visible */
   } else {
      *visibility=-1.;  /* face cachee */
   }
   mc_sepangle(ls,lon,bs,lat,&sepang,&posang);
   if (*visibility>=0) {
      /* - face visible -*/
      if (cos(sepang)>0) {
         /* - visible et eclaire par le soleil -*/
         *visibility*=pow(cos(sepang),power);
      } else {
         /* - visible mais dans l'ombre -*/
         /* - y ajouter la lumiere cendree enventuellement */
         *visibility=0.;
      }
   }
   *i=X*rc+xc;
   *j=Y*rc+yc;
   return;
}


void mc_equat2altaz(int annee, int mois, double jour, double longi, double latitude, double ra, double dec, double *az, double *h, double *hr, double *p)
/***************************************************************************/
/* Transforme les coord. sph. equatoriales vers sph. azinuth hauteur (T)   */
/***************************************************************************/
/***************************************************************************/
{
   /* === en entree ===*/
   /* --- int annee   : l'année (2000 par ex.)    */
   /* --- int mois    : le mois (9 pour Septembre)  */
   /* --- double jour : le jour decimal (22.5 pour le 22 a 12h TU) */
   /* --- double longi    : longitude (en radian) positif vers l'est (Calern est positif) */
   /* --- double latitude : latitude (en radian), positif vers le nord (Calern est positif) */
   /* --- double ra,dec   : ra,dec (en raidan) coordonnées équatoriales */
   /* --- */
   /* === en sortie ===*/
   /* --- double *az   : l'azimut (radians) */
   /* --- double *h    : la hauteur sur l'horizon (radians) */
   /* --- double *hr   : l'angle horaire (radians) */
   /* --- double *p    : l'angle parallactique (radians) */
   /* --- */
   /*
   #include <stdlib.h>
   #include <string.h>
   #include <stdio.h>
   #include <math.h>
   */
   /* --- */
   /*
   #define PI 3.1415926535897
   #define PISUR2 PI/2
   #define DR PI/180
   */
   /* --- */
   double a,m,j,aa,bb,jd;
   double t,theta0,tsl;
   double ha;
   double hh;
   /* --- calcul du jour julien ---*/
   a=annee;
   m=mois;
   j=jour;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   /* --- calcul du temps sideral local ---*/
   j=(jd-2451545.0);
   t=j/36525;
   theta0=280.46061837+360.98564736629*j+.000387933*t*t-t*t*t/38710000;
   theta0+=longi/(DR);
   theta0=fmod(theta0,360.);
   tsl=fmod(theta0+720.,360.)*DR;
   /* --- calcul de l'angle horaire ---*/
   ha=tsl-ra;
   ha=fmod(4*PI+ha,2*PI);
   *hr=ha;
   /* --- calcul de l'azimut et de la hauteur ---*/
   if (dec>=PISUR2) { aa=(PI); hh=latitude;}
   else if (dec<=-PISUR2) { aa=0.; hh=-latitude;}
   else {
      aa=atan2(sin(ha),cos(ha)*sin(latitude)-tan(dec)*cos(latitude));
      hh=mc_asin(sin(latitude)*sin(dec)+cos(latitude)*cos(dec)*cos(ha));
   }
   *az=fmod(4*PI+aa,2*PI);
   *h=hh;
   /* --- calcul de l'angle parallactique ---*/
   if (fabs(latitude)>=PISUR2) { aa=0;}
   else if ((ha==0.)&&(dec==latitude)) { aa=0.; }
   else {
      aa=atan2(sin(ha),cos(dec)*tan(latitude)-sin(dec)*cos(ha));
   }
   *p=aa;
}

