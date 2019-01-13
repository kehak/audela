/* mc_orbi1.c
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
/* Determination des elements d'orbite.                                    */
/***************************************************************************/
#include "mc.h"

void mc_cu2xyzeq(double l,double m,double n,double *a,double *ll, double *mm, double *nn)
/***************************************************************************/
/* Calcul des coordonnees cart. du repere de Cunningham vers equatorial    */
/***************************************************************************/
/*      | 1  2  3 |             | 1  4  7 |                                */
/*  A = | 4  5  6 |   =>  A-1 = | 2  5  8 |                                */
/*      | 7  8  9 |             | 3  6  9 |                                */
/*  (ll,mm,nn) vecteur equatorial unitaire                                 */
/*  (l,m,n) vecteur de Cunningham                                          */
/*  pour le calcul : (ll,mm,nn) = (l,m,n) * A-1                            */
/***************************************************************************/
{
   double ll0,mm0,nn0;
   ll0=l*a[1]+m*a[2]+n*a[3];
   mm0=l*a[4]+m*a[5]+n*a[6];
   nn0=l*a[7]+m*a[8]+n*a[9];
   *ll=ll0;
   *mm=mm0;
   *nn=nn0;
}

void mc_elemplus(struct observ *obs,struct elemorb *elem,int nbobs)
/***************************************************************************/
/* Ajoute quelques renseignements supplementaires aux elements d'orbites   */
/* en particulier les incertitudes estimees                                */
/***************************************************************************/
/***************************************************************************/
{
   double a;
   strcpy(elem->designation,(obs+1)->designation);
   elem->nbjours=(int) (1+floor((obs+nbobs)->jjtu-(obs+1)->jjtu));
   elem->nbobs=nbobs;
   elem->ceu0=0;
   a=((obs+nbobs)->jjtu-(obs+1)->jjtu);
   if (a!=0) {
      elem->ceut=1./a;
   } else {
      elem->ceut=45000;
   }
   elem->jj_ceu0=(obs+1)->jjtu;
   elem->type=UNKNOWN;
   mc_elemtype(elem);
}

void mc_elemtype(struct elemorb *elem)
/***************************************************************************/
/* Complete le type d'astre et les codes Bowell dans la structure elem.    */
/***************************************************************************/
{
   if (elem->type==UNKNOWN) {
      if (elem->e<0.35) { elem->type=ASTEROIDE; }
      if (elem->e>0.95) { elem->type=COMETE; }
   }
   elem->code1=0;
   if ((elem->q)<1.0167) {
      elem->code1=1;
   }
   if (((elem->q)>=1.0167)&&((elem->q)<1.3)) {
      elem->code1=4;
   }
   if (((elem->q)>=1.3)&&((elem->q)<1.6660)) {
      elem->code1=8;
   }
   elem->code2=0;
   elem->code3=0;
   elem->code4=0;
   elem->code5=0;
   if (elem->nbjours>1000) {
      elem->code6=5;
   } else {
      elem->code6=3;
   }
}

void mc_gem3(struct observ *obs,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode GEM 3 observations.                                             */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules et listing pp 226-232                                          */
/***************************************************************************/
{
   double l[4],m[4],n[4],ll[4],mm[4],nn[4];
   double a[10];
   double jj[4],rho[4],rho0[4];
   double x[4],y[4],z[4],r[4];
   double xs[4],ys[4],zs[4],xxs,yys,zzs,eps;
   double lls[10],mms[10],uus[10],ls,bs,rs;
   double dt,kay[4],yg[4];
   int k,k0,k1,k2,compteur=0,compteurmax=500;
   double tau1,tau3,c1,c3;
   double w2,f,g,vx,vy,vz;
   double mu;
   double paradx,parady,paradz;
   int centre; /* helio=SOLEIL  geo=TERRE */
   double kgrav,w2err;
   /*FILE *fid;*/

   centre=SOLEIL;
   /*centre=TERRE;*/
   if (centre==TERRE) {
      kgrav=(KGEOS);
      w2err=1e-9;
   } else {
      kgrav=(K);
      w2err=1e-7;
   }
   mu=(kgrav)*(kgrav);

   /*--- coordonnees cartesiennes equatoriales unitaires ---*/
   for (k=1;k<=3;k++) {
      mc_lbr2xyz((obs+k)->asd,(obs+k)->dec,1.0,&ll[k],&mm[k],&nn[k]);
      jj[k]=(obs+k)->jjtd;
   }

   /*--- matrice de Cunningham a partir des observations 1 et 3 ---*/
   mc_matcunni(ll[1],mm[1],nn[1],ll[3],mm[3],nn[3],a);

   /*--- coordonnees cartesiennes de Cunningham unitaire ---*/
   for (k=1;k<=3;k++) {
      mc_xyzeq2cu(ll[k],mm[k],nn[k],a,&l[k],&m[k],&n[k]);
   }

   /*--- coordonnees cartesiennes topocentriques de Cunningham du Soleil ---*/
   mc_obliqmoy(jj_equinoxe,&eps);
   for (k=1;k<=3;k++) {
      if (centre==SOLEIL) {
         mc_jd2lbr1a(jj[k],lls,mms,uus);
         mc_jd2lbr1b(jj[k],SOLEIL,lls,mms,uus,&ls,&bs,&rs);
         mc_lbr2xyz(ls,bs,rs,&xxs,&yys,&zzs);
         mc_xyzec2eq(xxs,yys,zzs,eps,&xxs,&yys,&zzs);
      }
      if (centre==TERRE) {
	      xxs=0.0;
	      yys=0.0;
	      zzs=0.0;
      }
      mc_paraldxyzeq((obs+k)->jjtd,(obs+k)->longuai,(obs+k)->rhocosphip,(obs+k)->rhosinphip,&paradx,&parady,&paradz);
      xxs-=paradx;
      yys-=parady;
      zzs-=paradz;
      mc_precxyz((obs+k)->jjtd,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
      mc_xyzeq2cu(xxs,yys,zzs,a,&xs[k],&ys[k],&zs[k]);
   }

   /*--- initialisation des coefs tau et c (Marsden AJ 102, pp1540 ---*/
   tau1=kgrav*(jj[1]-jj[2]);
   tau3=kgrav*(jj[3]-jj[2]);
   c1= tau3/(tau3-tau1);
   c3=-tau1/(tau3-tau1);
   rho0[1]=0.0;
   rho0[2]=0.0;
   rho0[3]=0.0;
   /*
   fid=fopen("geobug.txt","wt");
   fclose(fid);
   */
   do {
      /*---  vecteurs topocentriques de l'astre ---*/
      rho[2]=(-c1*zs[1]+zs[2]-c3*zs[3])/n[2];
      rho[1]=(rho[2]*m[2]-ys[2]+c1*ys[1]+c3*ys[3])/(c1*m[1]);
      rho[3]=(rho[2]*l[2]-c1*rho[1]*l[1]-xs[2]+c1*xs[1]+c3*xs[3])/c3;

      /*--- condition de sortie ---*/
      for (w2=0,k=1;k<=3;k++) {
         jj[k]=(obs+k)->jjtd-0.005768*rho[k];
         w2+=fabs(rho0[k]-rho[k]);
         rho0[k]=rho[k];
      }
      compteur++;
      if ((w2<w2err)||(compteur>compteurmax)) { w2=-1; /* flag de sortie */ }

      /*--- vecteurs heliocentriques de l'astre ---*/
      for (k=1;k<=3;k++) {
         x[k]=rho[k]*l[k]-xs[k];
         y[k]=rho[k]*m[k]-ys[k];
         z[k]=rho[k]*n[k]-zs[k];
         r[k]=(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);
         r[k]=sqrt(r[k]);
      }

      /*--- affichage de debug ---*/
      /*
      fid=fopen("geobug.txt","at");
      fprintf(fid,"c1 c3\n %10g %10g\n",c1,c3);
      fprintf(fid,"xs ys zs (topo/centreterre) (dist topo/centreterre) (X+Y)\n");
      for (k=1;k<=3;k++) {
         fprintf(fid," %10g %10g %10g %10g %10g\n",xs[k],ys[k],zs[k],sqrt(xs[k]*xs[k]+ys[k]*ys[k]+zs[k]*zs[k]),sqrt(xs[k]*xs[k]+ys[k]*ys[k]));
      }
      fprintf(fid,"l m n (topo/satel unitaire) (X+Y)\n");
      for (k=1;k<=3;k++) {
         fprintf(fid," %10g %10g %10g %10g\n",l[k],m[k],n[k],sqrt(l[k]*l[k]+m[k]*m[k]));
      }
      fprintf(fid,"rho (dists topo-satel)\n");
      for (k=1;k<=3;k++) {
         fprintf(fid," %10g\n",rho[k]);
      }
      fprintf(fid,"x y z (centreterre/satel) (dists centreterre-satel)\n");
      for (k=1;k<=3;k++) {
         fprintf(fid," %10g %10g %10g %10g\n",x[k],y[k],z[k],r[k]);
      }
      fclose(fid);
      */

      /*--- calcul des ratio d'aire des secteurs ---*/
      for (k=1;k<=3;k++) {
         k1=(int) (1+fmod(k  ,3));
         k2=(int) (1+fmod(k+1,3));
         dt=jj[k2]-jj[k1];
         if (dt<0) {
            dt=-dt;
            k0=k1;k1=k2;k2=k0;
         }
         kay[k]=sqrt(2.*(x[k1]*x[k2]+y[k1]*y[k2]+z[k1]*z[k2])+2.*r[k1]*r[k2]);
         mc_secratio(r[k1],r[k2],kay[k],dt,kgrav,&yg[k]);
      }

      c1=(yg[2]/yg[1])*(jj[3]-jj[2])/(jj[3]-jj[1]);
      c3=(yg[2]/yg[3])*(jj[2]-jj[1])/(jj[3]-jj[1]);

   } while (w2>0);

   /*--- coordonnees geocentriques dans le repere ecliptique ---*/
   for (k=1;k<=3;k++) {
      mc_cu2xyzeq(x[k],y[k],z[k],a,&x[k],&y[k],&z[k]);
      if (centre==SOLEIL) {
         mc_xyzeq2ec(x[k],y[k],z[k],eps,&x[k],&y[k],&z[k]);
      }
      r[k]=sqrt(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);
   }

   /*--- vecteur vitesse a l'instant 1 ---*/
   f=1-2*dt*dt*mu/(kay[3]*kay[3]*yg[3]*yg[3]*r[1]);
   g=dt/yg[3];
   vx=(x[2]-f*x[1])/g;
   vy=(y[2]-f*y[1])/g;
   vz=(z[2]-f*z[1])/g;

   /*--- recherche des elements orbitaux a l'instant 1 ---*/
   mc_xvx2elem(x[1],y[1],z[1],vx,vy,vz,jj[1],jj_equinoxe,kgrav,elem);
   mc_elemplus(obs,elem,3);
}

void mc_herget2(struct observ *obs,double *delta,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode d'Herget a 2 observations.                                      */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules pp 235                                                         */
/***************************************************************************/
{
   double ll[3],mm[3],nn[3],lls[10],mms[10],uus[10],ls,bs,rs;
   double xs[3],ys[3],zs[3],xxs,yys,zzs,eps,jj[3],x[3],y[3],z[3],r[3];
   double dt,yr,kay,f,mu,g,vx,vy,vz;
   int k;
   double paradx,parady,paradz;

   /*--- coordonnees cartesiennes equatoriales unitaires ---*/
   for (k=1;k<=2;k++) {
      mc_lbr2xyz((obs+k)->asd,(obs+k)->dec,1.0,&ll[k],&mm[k],&nn[k]);
      jj[k]=(obs+k)->jjtd-0.005768*delta[k];
   }

   /*--- coordonnees cartesiennes de equatoriales du Soleil ---*/
   mc_obliqmoy(jj_equinoxe,&eps);
   for (k=1;k<=2;k++) {
      mc_jd2lbr1a((obs+k)->jjtd,lls,mms,uus);
      mc_jd2lbr1b((obs+k)->jjtd,SOLEIL,lls,mms,uus,&ls,&bs,&rs);
      mc_lbr2xyz(ls,bs,rs,&xxs,&yys,&zzs);
      mc_xyzec2eq(xxs,yys,zzs,eps,&xxs,&yys,&zzs);
      mc_precxyz((obs+k)->jjtd,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
      mc_paraldxyzeq((obs+k)->jjtd,(obs+k)->longuai,(obs+k)->rhocosphip,(obs+k)->rhosinphip,&paradx,&parady,&paradz);
      xxs-=paradx;
      yys-=parady;
      zzs-=paradz;
      xs[k]=xxs;
      ys[k]=yys;
      zs[k]=zzs;
   }

   /*--- coordonnees cartesiennes des rayons vecteurs ---*/
   for (k=1;k<=2;k++) {
      x[k]=delta[k]*ll[k]-xs[k];
      y[k]=delta[k]*mm[k]-ys[k];
      z[k]=delta[k]*nn[k]-zs[k];
      x[k]=delta[k]*cos((obs+k)->asd)*cos((obs+k)->dec)-xs[k];
      y[k]=delta[k]*sin((obs+k)->asd)*cos((obs+k)->dec)-ys[k];
      z[k]=delta[k]*sin((obs+k)->dec)-zs[k];
      r[k]=sqrt(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);
   }

   /*--- calcul du sector ratio ---*/
   dt=jj[2]-jj[1];
   kay=sqrt(2*(x[1]*x[2]+y[1]*y[2]+z[1]*z[2])+2*r[1]*r[2]);
   mc_secratio(r[1],r[2],kay,dt,K,&yr);

   /*--- vecteur vitesse a l'instant 1 ---*/
   mu=1.*K*K;
   f=1-2*dt*dt*mu/(kay*kay*yr*yr*r[1]);
   g=dt/yr;
   vx=(x[2]-f*x[1])/g;
   vy=(y[2]-f*y[1])/g;
   vz=(z[2]-f*z[1])/g;

   /*--- recherche des elements orbitaux a l'instant 1 ---*/
   mc_xyzeq2ec(x[1],y[1],z[1],eps,&x[1],&y[1],&z[1]);
   mc_xyzeq2ec(vx,vy,vz,eps,&vx,&vy,&vz);
   mc_xvx2elem(x[1],y[1],z[1],vx,vy,vz,jj[1],jj_equinoxe,K,elem);
   mc_elemplus(obs,elem,2);

}

void mc_matcunni(double ll1, double mm1, double nn1, double ll3, double mm3, double nn3, double *a)
/***************************************************************************/
/* Calcul des elements de la matrice de Cunningham                         */
/***************************************************************************/
/* ref : Marsden B.G. AJ 102, pp 1540                                      */
/*      | 1  2  3 |                                                        */
/*  A = | 4  5  6 |                                                        */
/*      | 7  8  9 |                                                        */
/*  (a',b',c') vecteur equatorial unitaire                                 */
/*  (a,b,c) vecteur de Cunningham                                          */
/*  pour le calcul : (a,b,c) = (a',b',c') * A                              */
/***************************************************************************/
{
   double norme;
   /*--- vecteur colonne i ---*/
   a[1]=ll3;
   a[4]=mm3;
   a[7]=nn3;
   /*--- vecteur colonne k ---*/
   mc_prodvect(ll3,mm3,nn3,ll1,mm1,nn1,&a[3],&a[6],&a[9]);
   norme=sqrt(a[3]*a[3]+a[6]*a[6]+a[9]*a[9]);
   a[3]/=norme;
   a[6]/=norme;
   a[9]/=norme;
   /*--- vecteur colonne j ---*/
   mc_prodvect(a[3],a[6],a[9],a[1],a[4],a[7],&a[2],&a[5],&a[8]);
}

void mc_mvc2a(struct observ *obs,double delta,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode MVC 2 observations. methode de Vaisala (orbite perihelique).    */
/***************************************************************************/
/* ref : Marsden B.G. AJ 90, (1985) pp 1546                                */
/***************************************************************************/
{
   double l[4],m[4],n[4],ll[4],mm[4],nn[4];
   double a[10];
   double jj[4],rho[4],rho0[4];
   double x[4],y[4],z[4],r[4];
   double xs[4],ys[4],zs[4],xxs,yys,zzs,eps;
   double lls[10],mms[10],uus[10],ls,bs,rs;
   int k;
   double tau1,f1,g1,u2;
   double w2,vx2,vy2,vz2;
   double paradx,parady,paradz;
   int centre; /* helio=SOLEIL  geo=TERRE */
   double kgrav;

   centre=SOLEIL;
   /*centre=TERRE;*/
   if (centre==TERRE) {
      kgrav=(KGEOS);
   } else {
      kgrav=(K);
   }

   /*--- coordonnees cartesiennes equatoriales unitaires ---*/
   for (k=1;k<=2;k++) {
      mc_lbr2xyz((obs+k)->asd,(obs+k)->dec,1.0,&ll[k],&mm[k],&nn[k]);
      jj[k]=(obs+k)->jjtd;
   }

   /*--- matrice de Cunningham a partir des observations 1 et 2 ---*/
   mc_matcunni(ll[1],mm[1],nn[1],ll[2],mm[2],nn[2],a);

   /*--- coordonnees cartesiennes de Cunningham unitaire ---*/
   for (k=1;k<=2;k++) {
      mc_xyzeq2cu(ll[k],mm[k],nn[k],a,&l[k],&m[k],&n[k]);
   }

   /*--- coordonnees cartesiennes de Cunningham du Soleil ---*/
   mc_obliqmoy(jj_equinoxe,&eps);
   for (k=1;k<=2;k++) {
      if (centre==SOLEIL) {
         mc_jd2lbr1a(jj[k],lls,mms,uus);
         mc_jd2lbr1b(jj[k],SOLEIL,lls,mms,uus,&ls,&bs,&rs);
         mc_lbr2xyz(ls,bs,rs,&xxs,&yys,&zzs);
         mc_xyzec2eq(xxs,yys,zzs,eps,&xxs,&yys,&zzs);
      }
      if (centre==TERRE) {
	      xxs=0.0;
	      yys=0.0;
	      zzs=0.0;
      }
      mc_paraldxyzeq((obs+k)->jjtd,(obs+k)->longuai,(obs+k)->rhocosphip,(obs+k)->rhosinphip,&paradx,&parady,&paradz);
      xxs-=paradx;
      yys-=parady;
      zzs-=paradz;
      mc_precxyz((obs+k)->jjtd,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
      mc_xyzeq2cu(xxs,yys,zzs,a,&xs[k],&ys[k],&zs[k]);
   }

   /*--- valeur initiale de rho[2] assumee ---*/
   /*--- etape i de Marsden ---*/
   rho[2]=delta;

   for (k=1;k<=2;k++) {
      rho0[k]=0;
   }

   /*--- recherche iterative de rho[1] ---*/
   /*--- l'iteration porte uniquement sur l'aberration planetaire ---*/
   do {

      /*--- vecteurs heliocentriques de l'astre ---*/
      /*--- etape ii de Marsden ---*/
      k=2;
      x[k]=rho[k]*l[k]-xs[k];
      y[k]=rho[k]*m[k]-ys[k];
      z[k]=rho[k]*n[k]-zs[k];
      r[k]=sqrt(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);

      /*--- initialisation du coefs tau1 ---*/
      tau1=kgrav*(jj[1]-jj[2]);

      /*--- calcul de f1 g1 ---*/
      /*--- etape iii de Marsden ---*/
      u2=r[2]*r[2]*r[2];
      f1=1-tau1*tau1/(2*u2);
      g1=(tau1-tau1*tau1*tau1/(6*u2))/(K);

      /*--- etape iv de Marsden formule 10 pp 1546 ---*/
      rho[1]=(f1*r[2]*r[2]+xs[1]*x[2]+ys[1]*y[2]+zs[1]*z[2])/(l[1]*x[2]+m[1]*y[2]+n[1]*z[2]);

      /*--- correction de l'aberration planetaire ---*/
      for (w2=0,k=1;k<=2;k++) {
         jj[k]=(obs+k)->jjtd-0.005768*rho[k];
         w2+=fabs(rho0[k]-rho[k]);
         rho0[k]=rho[k];
      }
      if (w2<1e-7) { w2=-1; /* flag de sortie */ }

   } while (w2>0);

   /*--- calcul du vecteur vitesse a l'instant 2 (form. 2 pp 1542) ---*/
   vx2=(rho[1]*l[1]-f1*x[2]-xs[1])/g1;
   vy2=(rho[1]*m[1]-f1*y[2]-ys[1])/g1;
   vz2=(rho[1]*n[1]-f1*z[2]-zs[1])/g1;

   /*--- recherche des elements orbitaux a l'instant 2 ---*/
   mc_cu2xyzeq(x[2],y[2],z[2],a,&x[2],&y[2],&z[2]);
   mc_xyzeq2ec(x[2],y[2],z[2],eps,&x[2],&y[2],&z[2]);
   mc_cu2xyzeq(vx2,vy2,vz2,a,&vx2,&vy2,&vz2);
   mc_xyzeq2ec(vx2,vy2,vz2,eps,&vx2,&vy2,&vz2);
   mc_xvx2elem(x[2],y[2],z[2],vx2,vy2,vz2,jj[2],jj_equinoxe,kgrav,elem);
   mc_elemplus(obs,elem,2);

}

void mc_mvc3a(struct observ *obs,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode MVC 3 observations. methode Aa de Danby                         */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules pp 232-234                                                     */
/***************************************************************************/
{
   double l[4],m[4],n[4],ll[4],mm[4],nn[4];
   double a[10];
   double jj[4],rho[4],rho0[4],rho00[4];
   double x[4],y[4],z[4],r[4];
   double xs[4],ys[4],zs[4],xxs,yys,zzs,eps;
   double lls[10],mms[10],uus[10],ls,bs,rs;
   int k,compteur,compteurmax=500;
   double tau,tau1,tau3,c1,c3,f1,g1,f3,g3,u2;
   double w2,vx2,vy2,vz2,vz2a,vz2b,ww2;
   double paradx,parady,paradz;
   int centre; /* helio=SOLEIL  geo=TERRE */
   double kgrav;

   centre=SOLEIL;
   /*centre=TERRE;*/
   if (centre==TERRE) {
      kgrav=(KGEOS);
   } else {
      kgrav=(K);
   }

   /*--- coordonnees cartesiennes equatoriales unitaires ---*/
   for (k=1;k<=3;k++) {
      mc_lbr2xyz((obs+k)->asd,(obs+k)->dec,1.0,&ll[k],&mm[k],&nn[k]);
      jj[k]=(obs+k)->jjtd;
   }

   /*--- matrice de Cunningham a partir des observations 1 et 3 ---*/
   mc_matcunni(ll[1],mm[1],nn[1],ll[3],mm[3],nn[3],a);

   /*--- coordonnees cartesiennes de Cunningham unitaire ---*/
   for (k=1;k<=3;k++) {
      mc_xyzeq2cu(ll[k],mm[k],nn[k],a,&l[k],&m[k],&n[k]);
   }

   /*--- coordonnees cartesiennes de Cunningham du Soleil ---*/
   mc_obliqmoy(jj_equinoxe,&eps);
   for (k=1;k<=3;k++) {
      if (centre==SOLEIL) {
         mc_jd2lbr1a(jj[k],lls,mms,uus);
         mc_jd2lbr1b(jj[k],SOLEIL,lls,mms,uus,&ls,&bs,&rs);
         mc_lbr2xyz(ls,bs,rs,&xxs,&yys,&zzs);
         mc_xyzec2eq(xxs,yys,zzs,eps,&xxs,&yys,&zzs);
      }
      if (centre==TERRE) {
	      xxs=0.0;
	      yys=0.0;
	      zzs=0.0;
      }
      mc_paraldxyzeq((obs+k)->jjtd,(obs+k)->longuai,(obs+k)->rhocosphip,(obs+k)->rhosinphip,&paradx,&parady,&paradz);
      xxs-=paradx;
      yys-=parady;
      zzs-=paradz;
      mc_precxyz((obs+k)->jjtd,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
      mc_xyzeq2cu(xxs,yys,zzs,a,&xs[k],&ys[k],&zs[k]);
   }

   for (k=1;k<=3;k++) {
      rho00[k]=0;
   }
   r[2]=0.;
   /*--- boucle sur l'aberration planetaire ---*/
   do {

      /*--- initialisation des coefs tau et c (Marsden AJ 102, pp1540 ---*/
      tau1=kgrav*(jj[1]-jj[2]);
      tau3=kgrav*(jj[3]-jj[2]);
      tau=tau3-tau1;
      if (rho00[2]==0.) {
         c1= tau3/tau;
         c3=-tau1/tau;
      } else {
         u2=r[2]*r[2]*r[2];
         c1= tau3/tau+tau3*(tau*tau-tau3*tau3)/(6*u2*tau);
         c3=-tau1/tau+tau1*(tau*tau-tau1*tau1)/(6*u2*tau);
      }

      /*--- valeur initiale de rho[2] ---*/
      rho[2]=(-c1*zs[1]+zs[2]-c3*zs[3])/n[2];

      /*--- recherche iterative de rho[2] ---*/
      compteur=0;
      do {
         rho0[2]=rho[2];
         /*--- vecteurs heliocentriques de l'astre ---*/
         k=2;
         x[k]=rho[k]*l[k]-xs[k];
         y[k]=rho[k]*m[k]-ys[k];
         z[k]=rho[k]*n[k]-zs[k];
         r[k]=sqrt(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);

         /*--- calcul de f1 g1 f3 g3 ---*/
         u2=r[2]*r[2]*r[2];
         f1=1-tau1*tau1/(2*u2);
         g1=(tau1-tau1*tau1*tau1/(6*u2))/(kgrav);
         f3=1-tau3*tau3/(2*u2);
         g3=(tau3-tau3*tau3*tau3/(6*u2))/(kgrav);
         rho[2]=((-g3*zs[1]+g1*zs[3])/(f1*g3-g1*f3)+zs[2])/n[2];
         w2=fabs(rho[2]-rho0[2]);
         compteur++;
      } while ((w2>1e-7)&&(compteur<compteurmax));

      /*--- resolution du systeme 7.3.21 ---*/
      vy2=(-ys[3]-f3*y[2])/g3;
      rho[1]=(f1*y[2]+g1*vy2+ys[1])/m[1];
      vx2=(rho[1]*l[1]-xs[1]-f1*x[2])/g1;
      rho[3]=(f3*x[2]+g3*vx2+xs[3]);

      /*--- condition de sortie ---*/
      for (ww2=0,k=1;k<=3;k++) {
         jj[k]=(obs+k)->jjtd-0.005768*rho[k];
         ww2+=fabs(rho00[k]-rho[k]);
         rho00[k]=rho[k];
      }
      if (ww2<1e-7) { ww2=-1; /* flag de sortie */ }

   } while (ww2>0);

   /*--- resolution du systeme 7.3.20 ---*/
   vz2a=(-zs[1]-f1*z[2])/g1;
   vz2b=(-zs[3]-f3*z[2])/g3;
   vz2=(vz2a+vz2b)/2;

   /*--- recherche des elements orbitaux a l'instant 2 ---*/
   mc_cu2xyzeq(x[2],y[2],z[2],a,&x[2],&y[2],&z[2]);
   mc_xyzeq2ec(x[2],y[2],z[2],eps,&x[2],&y[2],&z[2]);
   mc_cu2xyzeq(vx2,vy2,vz2,a,&vx2,&vy2,&vz2);
   mc_xyzeq2ec(vx2,vy2,vz2,eps,&vx2,&vy2,&vz2);

   mc_xvx2elem(x[2],y[2],z[2],vx2,vy2,vz2,jj[2],jj_equinoxe,kgrav,elem);
   mc_elemplus(obs,elem,3);

}

void mc_mvc3b(struct observ *obs,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode MVC 3 observations. methode B de Danby (Marsden)                */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules pp 232-234                                                     */
/* ref : Marsden B.G. AJ 90, (1985) pp 1542                                */
/***************************************************************************/
{
   double l[4],m[4],n[4],ll[4],mm[4],nn[4];
   double a[10];
   double jj[4],rho[4],rho0[4];
   double x[4],y[4],z[4],r[4];
   double xs[4],ys[4],zs[4],xxs,yys,zzs,eps;
   double lls[10],mms[10],uus[10],ls,bs,rs;
   int k,compteur=0,compteurmax=500;
   double tau,tau1,tau3,c1,c3,f1,g1,f3,g3,u2;
   double w2,vx2,vy2,vz2,vz2a,vz2b;
   double mu;
   double paradx,parady,paradz;

   mu=(K)*(K);

   /*--- coordonnees cartesiennes equatoriales unitaires ---*/
   for (k=1;k<=3;k++) {
      mc_lbr2xyz((obs+k)->asd,(obs+k)->dec,1.0,&ll[k],&mm[k],&nn[k]);
      jj[k]=(obs+k)->jjtd;
   }

   /*--- matrice de Cunningham a partir des observations 1 et 3 ---*/
   mc_matcunni(ll[1],mm[1],nn[1],ll[3],mm[3],nn[3],a);

   /*--- coordonnees cartesiennes de Cunningham unitaire ---*/
   for (k=1;k<=3;k++) {
      mc_xyzeq2cu(ll[k],mm[k],nn[k],a,&l[k],&m[k],&n[k]);
   }

   /*--- coordonnees cartesiennes de Cunningham du Soleil ---*/
   mc_obliqmoy(jj_equinoxe,&eps);
   for (k=1;k<=3;k++) {
      mc_jd2lbr1a(jj[k],lls,mms,uus);
      mc_jd2lbr1b(jj[k],SOLEIL,lls,mms,uus,&ls,&bs,&rs);
      mc_lbr2xyz(ls,bs,rs,&xxs,&yys,&zzs);
      mc_xyzec2eq(xxs,yys,zzs,eps,&xxs,&yys,&zzs);
      mc_precxyz((obs+k)->jjtd,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
      mc_paraldxyzeq((obs+k)->jjtd,(obs+k)->longuai,(obs+k)->rhocosphip,(obs+k)->rhosinphip,&paradx,&parady,&paradz);
      xxs-=paradx;
      yys-=parady;
      zzs-=paradz;
      mc_xyzeq2cu(xxs,yys,zzs,a,&xs[k],&ys[k],&zs[k]);
   }

   /*--- initialisation des coefs tau et c (Marsden AJ 102, pp1540 ---*/
   tau1=K*(jj[1]-jj[2]);
   tau3=K*(jj[3]-jj[2]);
   tau=tau3-tau1;
   c1= tau3/tau;
   c3=-tau1/tau;

   /*--- valeur initiale de rho[2] ---*/
   rho[2]=(-c1*zs[1]+zs[2]-c3*zs[3])/n[2];

   for (k=1;k<=3;k++) {
      rho0[k]=0;
   }

   /*--- recherche iterative des rho[] ---*/
   do {

      /*--- vecteurs heliocentriques de l'astre <B2> ---*/
      /*--- etape ii de Marsden ---*/
      k=2;
      x[k]=rho[k]*l[k]-xs[k];
      y[k]=rho[k]*m[k]-ys[k];
      z[k]=rho[k]*n[k]-zs[k];
      r[k]=sqrt(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);

      /*--- recalcule les coefs tau et c (Marsden AJ 102, pp1540) ---*/
      /*--- +DL Boulet. pp 417-419 (DL inutile d'apres Marsden !) ---*/
      tau1=K*(jj[1]-jj[2]);
      tau3=K*(jj[3]-jj[2]);
      tau=tau3-tau1;
      u2=mu/(r[2]*r[2]*r[2]);
      c1= tau3/tau+u2*tau3*(tau*tau-tau3*tau3)/(6*tau);
      c3=-tau1/tau+u2*tau1*(tau*tau-tau1*tau1)/(6*tau);

      /*--- calcul de f1 g1 f3 g3 <B2> ---*/
      /*--- etape iii de Marsden ---*/
      u2=r[2]*r[2]*r[2];
      f1=1-tau1*tau1/(2*u2);
      g1=(tau1-tau1*tau1*tau1/(6*u2))/(K);
      f3=1-tau3*tau3/(2*u2);
      g3=(tau3-tau3*tau3*tau3/(6*u2))/(K);

      /*--- resolution du systeme 7.3.21 <B4> ---*/
      /*--- etape iv de Marsden ---*/
      vy2=(-ys[3]-f3*y[2])/g3;
      rho[1]=(f1*y[2]+g1*vy2+ys[1])/m[1];
      vx2=(rho[1]*l[1]-xs[1]-f1*x[2])/g1;
      rho[3]=(f3*x[2]+g3*vx2+xs[3]);

      /*--- valeur moyenne de vz2 (7.3.25) <B3> ---*/
      /*--- etape v de Marsden ---*/
      vz2a=(-zs[1]-f1*z[2])/g1;
      vz2b=(-zs[3]-f3*z[2])/g3;
      vz2=(vz2a*tau3+vz2b*tau1)/(tau1+tau3);

      /*--- estimation de rho[2] (7.3.22) <B6> ---*/
      /*--- etape vi de Marsden ---*/
      rho[2]=((-g3*zs[1]+g1*zs[3])/(f1*g3-g1*f3)+zs[2])/n[2];
      z[2]=rho[2]*n[2]-zs[2];

      /*--- correction de l'abberation planetaire ---*/
      for (w2=0,k=2;k<=2;k++) {
         jj[k]=(obs+k)->jjtd-0.005768*rho[k];
         w2+=fabs(rho0[k]-rho[k]);
         rho0[k]=rho[k];
      }
      compteur++;
      if ((w2<1e-7)||(compteur>compteurmax)) { w2=-1; /* flag de sortie */ }

   } while (w2>0);

   /*--- recherche des elements orbitaux a l'instant 2 ---*/
   mc_cu2xyzeq(x[2],y[2],z[2],a,&x[2],&y[2],&z[2]);
   mc_xyzeq2ec(x[2],y[2],z[2],eps,&x[2],&y[2],&z[2]);
   mc_cu2xyzeq(vx2,vy2,vz2,a,&vx2,&vy2,&vz2);
   mc_xyzeq2ec(vx2,vy2,vz2,eps,&vx2,&vy2,&vz2);
   mc_xvx2elem(x[2],y[2],z[2],vx2,vy2,vz2,jj[2],jj_equinoxe,K,elem);
   mc_elemplus(obs,elem,3);

}

void mc_xyzeq2cu(double ll,double mm,double nn,double *a,double *l, double *m, double *n)
/***************************************************************************/
/* Calcul des coordonnees cartesiennes dans le repere de Cunningham        */
/***************************************************************************/
/*      | 1  2  3 |                                                        */
/*  A = | 4  5  6 |                                                        */
/*      | 7  8  9 |                                                        */
/*  (ll,mm,nn) vecteur equatorial unitaire                                 */
/*  (l,m,n) vecteur de Cunningham                                          */
/*  pour le calcul : (l,m,n) = (ll,mm,nn) * A                              */
/***************************************************************************/
{
   double l0,m0,n0;
   l0=ll*a[1]+mm*a[4]+nn*a[7];
   m0=ll*a[2]+mm*a[5]+nn*a[8];
   n0=ll*a[3]+mm*a[6]+nn*a[9];
   *l=l0;
   *m=m0;
   *n=n0;
}

void mc_secratio(double r1, double r2, double kay, double dt, double kgrav, double *y)
/***************************************************************************/
/* Calcul du ratio des aires des secteurs de Gauss.                        */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Listing page 194-195 <lignes 10-4170>                                   */
/* Formules pp 184-185, 193-194                                            */
/***************************************************************************/
{
   double ms,el,yg1,xs,q,yg2,yg3,den,dy;
   /* 6.12.11 */
   ms=(kgrav*dt)*(kgrav*dt)/(kay*kay*kay);
   /* 6.12.12 */
   el=(r1+r2-kay)/(2*kay);
   /* 6.12.15 */
   yg1=1.;
   do {
      den=yg1*yg1;
      if (fabs(den)<1e-100) {
         *y=yg1;
         return;
      }
      xs=ms/(den)-el;
      q=mc_secratiq(xs);
      yg2=1.+4.*ms*q/(3*den);
      den=yg2*yg2;
      if (fabs(den)<1e-100) {
         *y=yg1;
         return;
      }
      xs=ms/(den)-el;
      q=mc_secratiq(xs);
      yg3=1.+4.*ms*q/(3*den);
      den=yg1-2*yg2+yg3;
      if (fabs(den)<1e-15) {
         *y=yg1;
         return;
      }
      dy=(yg2-yg1)*(yg2-yg1)/den;
      yg1=yg1-dy;
   } while (fabs(dy<1e-15));
   *y=yg1;
}

double mc_secratiq(double x)
/***************************************************************************/
/* Serie hypergeometrique.                                                 */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Listing page 195 <lignes 4500 a 4680>                                   */
/* Formules pp 184-185, 193-194                                            */
/***************************************************************************/
{
   double q,y,fac,n,dn;
   if (x>0.5) {
      x=0.5;
   } else if (x<-0.5) {
      x=-0.5;
   }
   if (fabs(x>0.1)) {
      if (x<0) {
         /* 6.11.32 */
         y=sqrt(x*x-x);
         q=3./16*(2*(1-2*x)*y-log(1-2*x+2*y))/(y*y*y);
         return(q);
      } else {         
         /*
         y=2*x-1;
         q=3./16*(atan(y/sqrt(1-y*y))+2*y*sqrt(x-x*x)+(PI)/2);
         q=q/pow((x-x*x),1.5);
         */
         /* 6.11.31 */
         y=sqrt(x-x*x);
         q=3./16*(2*(2*x-1)*y+asin(2*x-1)+PI/2)/(y*y*y);
         return(q);
      }
   } else {
      /* 6.11.29 */
      fac=1.2*x;
      q=1.+fac;
      for (n=1.;n<=10.;n++) {
         dn=n;
         fac=fac*(3.+dn)/(2.5+dn)*x;
         q=q+fac;
      }
      return(q);
   }
}

