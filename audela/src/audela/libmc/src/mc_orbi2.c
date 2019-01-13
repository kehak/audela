/* mc_orbi2.c
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

void mc_gem3b(struct observ *obs,double offc, double offl,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode GEM 3 observations. Contraintes de Marsden (offc,offl)          */
/* offc est le Delta-n de courbue defini par Marsden (en arcsec)           */
/* offl est le Delta-m de sinus de longitude par Marsden (en arcsec)       */
/***************************************************************************/
/* ref : Danby J.M.A. "Fundamentals of Celestial Mechanics" 2nd ed. 1992   */
/*       William Bell                                                      */
/* Formules et listing pp 226-232                                          */
/* ref : MArsden B.G. AJ102 (1991) pp 1539-1552                            */
/***************************************************************************/
{
   double l[4],m[4],n[4],ll[4],mm[4],nn[4];
   double a[10];
   double jj[4],rho[4],rho0[4];
   double x[4],y[4],z[4],r[4];
   double xs[4],ys[4],zs[4],xxs,yys,zzs,eps;
   double lls[10],mms[10],uus[10],ls,bs,rs;
   double dt,kay[4],yg[4];
   int k,k0,k1,k2;
   double tau1,tau3,c1,c3;
   double w2,f,g,vx,vy,vz;
   double mu;
   struct observ *obs2;
   double asd,dec,delta;
   double rrp,xxp,yyp,zzp,mmm,v,jjda;
   struct pqw elempq;
   double jjj;
   double alpha0,alpha;
   double rho2,l2;
   double paradx,parady,paradz;
   double nboucle=0,nbouclemax=100;

   mu=(K)*(K);

   /*--- calcul des elements pour une orbite circulaire ---*/
   obs2 = (struct observ *) calloc(2+1,sizeof(struct observ));
   for (k1=1,k2=1;k2<=2;k2++) {
      if (k2!=1) {k1=3;}
      strcpy(obs2[k2].designation,obs[k1].designation);
      obs2[k2].jjtu=obs[k1].jjtu;
      obs2[k2].jjtd=obs[k1].jjtd;
      obs2[k2].asd=obs[k1].asd;
      obs2[k2].dec=obs[k1].dec;
      obs2[k2].jj_equinoxe=obs[k1].jj_equinoxe;
      strcpy(obs2[k2].codmpc,obs[k1].codmpc);
      obs2[k2].longuai=obs[k1].longuai;
      obs2[k2].rhocosphip=obs[k1].rhocosphip;
      obs2[k2].rhosinphip=obs[k1].rhosinphip;
      obs2[k2].mag1=obs[k1].mag1;
   }
   mc_mvc2b(obs2,elem,jj_equinoxe);
   free(obs2);

   /*--- calcul de la dist geos <rho2> pour la deuxieme observation ---*/
   /*--- constantes equatoriales ---*/
   mc_obliqmoy(jj_equinoxe,&eps);
   /*--- precession et conversion des elements ---*/
   mc_precelem(*elem,elem->jj_equinoxe,jj_equinoxe,elem);
   mc_elempqec(*elem,&elempq);
   mc_elempqeq(elempq,eps,&elempq);
   jjj=obs[2].jjtd;
   /*--- soleil ---*/
   mc_jd2lbr1a(jjj,lls,mms,uus);
   mc_jd2lbr1b(jjj,SOLEIL,lls,mms,uus,&ls,&bs,&rs);
   mc_lbr2xyz(ls,bs,rs,&xxs,&yys,&zzs);
   mc_xyzec2eq(xxs,yys,zzs,eps,&xxs,&yys,&zzs);
   mc_precxyz(jjj,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
   k=2;
   mc_paraldxyzeq((obs+k)->jjtd,(obs+k)->longuai,(obs+k)->rhocosphip,(obs+k)->rhosinphip,&paradx,&parady,&paradz);
   xxs-=paradx;
   yys-=parady;
   zzs-=paradz;
   /*--- planete ---*/
   mc_anomoy(*elem,jjj,&mmm);
   mc_anovrair(*elem,mmm,&v,&rrp);
   mc_rv_xyz(elempq,rrp,v,&xxp,&yyp,&zzp); /* equatoriale J2000 */
   mc_he2ge(xxp,yyp,zzp,xxs,yys,zzs,&xxp,&yyp,&zzp);
   mc_xyz2add(xxp,yyp,zzp,&asd,&dec,&delta);
   /* --- planete corrigee de l'aberration de la lumiere ---*/
   mc_aberpla(jjj,delta,&jjda);
   mc_anomoy(*elem,jjda,&mmm);
   mc_anovrair(*elem,mmm,&v,&rrp);
   mc_rv_xyz(elempq,rrp,v,&xxp,&yyp,&zzp); /* equatoriale J2000 */
   mc_he2ge(xxp,yyp,zzp,xxs,yys,zzs,&xxp,&yyp,&zzp);
   mc_xyz2add(xxp,yyp,zzp,&asd,&dec,&delta);
   rho2=delta;

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
   c1= tau3/(tau3-tau1);
   c3=-tau1/(tau3-tau1);
   rho0[1]=0.0;
   rho0[2]=0.0;
   rho0[3]=0.0;

   /*--- contraintes de Marsden pour creer l'observation virtuelle 2 ---*/
   /*--- formules 6,8,9 pp 1541 ---*/
   alpha0=m[2]/(m[1]*c1);
   alpha=alpha0;
   n[2]=(-c1*zs[1]+zs[2]-c3*zs[3])/rho2;
   m[2]=alpha*m[1]*c1;
   m[2]+=(offl/206265);
   n[2]+=(offc/206265);
   l2=1-m[2]*m[2]-n[2]*n[2];
   if (l2<0) {
      m[2]-=(offl/206265);
      n[2]-=(offc/206265);
      l2=1-m[2]*m[2]-n[2]*n[2];
   }
   l[2]=sqrt(l2);

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
      nboucle++;
      if ((w2<1e-7)||(nboucle>nbouclemax)) { w2=-1; /* flag de sortie */ }

      /*--- vecteurs heliocentriques de l'astre ---*/
      for (k=1;k<=3;k++) {
         x[k]=rho[k]*l[k]-xs[k];
         y[k]=rho[k]*m[k]-ys[k];
         z[k]=rho[k]*n[k]-zs[k];
         r[k]=(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);
         r[k]=sqrt(r[k]);
      }

      /*--- calcul des ratio d'aire des secteurs ---*/
      for (k=1;k<=3;k++) {
         k1=(int) (1+fmod(k  ,3));
         k2=(int) (1+fmod(k+1,3));
         dt=jj[k2]-jj[k1];
         if (dt<0) {
            dt=-dt;
            k0=k1;k1=k2;k2=k0;
         }
         kay[k]=sqrt(2*(x[k1]*x[k2]+y[k1]*y[k2]+z[k1]*z[k2])+2*r[k1]*r[k2]);
         mc_secratio(r[k1],r[k2],kay[k],dt,K,&yg[k]);
      }

      c1=(yg[2]/yg[1])*(jj[3]-jj[2])/(jj[3]-jj[1]);
      c3=(yg[2]/yg[3])*(jj[2]-jj[1])/(jj[3]-jj[1]);

   } while (w2>0);

   /*--- coordonnees geocentriques dans le repere ecliptique ---*/
   for (k=1;k<=3;k++) {
      mc_cu2xyzeq(x[k],y[k],z[k],a,&x[k],&y[k],&z[k]);
      mc_xyzeq2ec(x[k],y[k],z[k],eps,&x[k],&y[k],&z[k]);
      r[k]=sqrt(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);
   }

   /*--- vecteur vitesse a l'instant 1 ---*/
   f=1-2*dt*dt*mu/(kay[3]*kay[3]*yg[3]*yg[3]*r[1]);
   g=dt/yg[3];
   vx=(x[2]-f*x[1])/g;
   vy=(y[2]-f*y[1])/g;
   vz=(z[2]-f*z[1])/g;
   /*--- recherche des elements orbitaux a l'instant 1 ---*/
   mc_xvx2elem(x[1],y[1],z[1],vx,vy,vz,jj[1],jj_equinoxe,K,elem);
   mc_elemplus(obs,elem,3);

}

void mc_mvc2b(struct observ *obs,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode MVC 2 observations. Orbite circulaire contrainte.               */
/***************************************************************************/
/* ref : Marsden B.G. AJ 90, (1985) pp 1546                                */
/***************************************************************************/
{
   double l[4],m[4],n[4],ll[4],mm[4],nn[4];
   double a[10];
   double jj[4],rho[4];
   double x[4],y[4],z[4],r[4];
   double xs[4],ys[4],zs[4],rs2[3],xxs,yys,zzs,eps;
   double lls[10],mms[10],uus[10],ls,bs,rs;
   int k;
   double tau1,f1,g1,u2;
   double w2,vx2,vy2,vz2;
   double aaa,bbb,ccc,ddd,contrainte,contrainte0,drho2;
   double contrainte00 = 0;
   double paradx,parady,paradz;

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
      rs2[k]=xs[k]*xs[k]+ys[k]*ys[k]+zs[k]*zs[k];
   }

   /*--- initialisation des coefs du polynome pour trouver rho[1] ---*/
   aaa=l[1]*l[1]+m[1]*m[1]+n[1]*n[1];
   bbb=-2*(l[1]*xs[1]+m[1]*ys[1]+n[1]*zs[1]);

   /*--- valeur initiale de rho[2] assumee ---*/
   rho[2]=.2;

   /*--- valeur initiale du pas sur rho[2] ---*/
   drho2=1e-4;

   /*--- initialisation de la premiere valeur de la contrainte ---*/
   contrainte0=0;
   w2=1;

   /*--- recherche iterative sur le produit scalaire r2.v2 ---*/
   do {

      /*--- vecteur heliocentrique de l'astre a l'instant 2 ---*/
      k=2;
      x[k]=rho[k]*l[k]-xs[k];
      y[k]=rho[k]*m[k]-ys[k];
      z[k]=rho[k]*n[k]-zs[k];
      r[k]=sqrt(x[k]*x[k]+y[k]*y[k]+z[k]*z[k]);

      /*--- calcul de rho[1] avec la contrainte (r1)2 = (r2)2 ---*/
      ccc=rs2[1]-r[2]*r[2];
      ddd=bbb*bbb-4*aaa*ccc;
      if (ddd>=0) {
         rho[1]=(-bbb+sqrt(ddd))/(2*aaa);
      } else {
         rho[1]=0;
      }

      /*--- correction de l'aberration planetaire ---*/
      for (k=1;k<=2;k++) {
         jj[k]=(obs+k)->jjtd-0.005768*rho[k];
      }

      /*--- initialisation du coef tau1 ---*/
      tau1=K*(jj[1]-jj[2]);

      /*--- calcul de f1 g1 ---*/
      u2=r[2]*r[2]*r[2];
      f1=1-tau1*tau1/(2*u2);
      g1=(tau1-tau1*tau1*tau1/(6*u2))/(K);

      /*--- calcul du vecteur vitesse a l'instant 2 (form. 2 pp 1542) ---*/
      vx2=(rho[1]*l[1]-f1*x[2]-xs[1])/g1;
      vy2=(rho[1]*m[1]-f1*y[2]-ys[1])/g1;
      vz2=(rho[1]*n[1]-f1*z[2]-zs[1])/g1;
      /*v2=sqrt(vx2*vx2+vy2*vy2+vz2*vz2);*/

      /*--- calcul du produit scalaire r2.v2=contrainte ---*/
      mc_prodscal(x[2],y[2],z[2],vx2,vy2,vz2,&contrainte);

      /* pour debugger ...
      printf("rho[2]=%f drho2=%f r2=%f d=%e\n",rho[2],drho2,r[2],contrainte);
      getch();
      */

      /*--- ne pas inverser cet ordre de conditions sur w2 ---*/ 
      if (w2==3) {
         w2=-1;
      }
      if (w2==2) {
         /*
         v=sqrt(vx2*vx2+vy2*vy2+vz2*vz2);
         rr=sqrt(x[2]*x[2]+y[2]*y[2]+z[2]*z[2]);
         rv=contrainte;
         ex=(v*v/mu-1/rr)*x[2]-rv/mu*vx2;
         ey=(v*v/mu-1/rr)*y[2]-rv/mu*vy2;
         ez=(v*v/mu-1/rr)*z[2]-rv/mu*vz2;
         contrainte=sqrt(ex*ex+ey*ey+ez*ez);
         printf("w2=%f rho[2]=%f c00=%+e c0=%e c=%e\n",w2,rho[2],contrainte00,contrainte0,contrainte);
         getch();
         */
         if ((contrainte0<=contrainte)&&(contrainte0<=contrainte00)) {
            rho[2]-=drho2;
            w2=3;
         } else {
            rho[2]+=drho2;
            contrainte00=contrainte0;
            contrainte0=contrainte;
         }
         if (rho[2]>100) {
            rho[2]=1.0;
            w2=3;
         }
      }
      /*--- adapte le pas d'iteration et condition de sortie ---*/
      /*--- la contrainte doit changer de signe pour sortir  ---*/
      /*--- et le pas de drho2 doit etre petit.              ---*/      
      if (w2==1) {
         if ((contrainte*contrainte0)<0) {
            if (fabs(drho2)<1e-6) {
               w2=-1;
            } else {
               drho2=-drho2/2;
            }
         } else {
            drho2=1.5*drho2;
         }
         rho[2]+=drho2;
         contrainte0=contrainte;
         if (rho[2]>100) {
            rho[2]=.20;
            drho2=1e-2;
            w2=2;
            contrainte00=-1;
            contrainte0=0;
         }
      }

   } while (w2>0);

   /*--- recherche des elements orbitaux a l'instant 2 ---*/
   mc_cu2xyzeq(x[2],y[2],z[2],a,&x[2],&y[2],&z[2]);
   mc_xyzeq2ec(x[2],y[2],z[2],eps,&x[2],&y[2],&z[2]);
   mc_cu2xyzeq(vx2,vy2,vz2,a,&vx2,&vy2,&vz2);
   mc_xyzeq2ec(vx2,vy2,vz2,eps,&vx2,&vy2,&vz2);
   mc_xvx2elem(x[2],y[2],z[2],vx2,vy2,vz2,jj[2],jj_equinoxe,K,elem);
   mc_elemplus(obs,elem,2);
   elem->code2+=2;
}

void mc_mvc2c(struct observ *obs,double aa,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode MVC 2 observations. Contrainte sur le demi grand axe.           */
/***************************************************************************/
/* Orbite de Vaisala (perihelique) avec contrainte sur le demi grand axe.  */
/* ref : Marsden B.G. AJ 90, (1985) pp 1546                                */
/* Methode utilisable pour les satellites                                  */
/* mc_menu 12 geos.obs 0.000283056 geos.elm                                */
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
   double w2,vx2,vy2,vz2,ww2,contrainte,contrainte0,drho2;
   double mu;
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
   mu=(kgrav)*(kgrav);

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

   if (centre==SOLEIL) {
      /*--- valeur initiale de rho[2] assumee ---*/
      rho[2]=1e-4;
      /*--- valeur initiale du pas sur rho[2] ---*/
      drho2=1e-4;
   }
   if (centre==TERRE) {
      /*--- valeur initiale de rho[2] assumee ---*/
      rho[2]=5e-5;
      /*--- valeur initiale du pas sur rho[2] ---*/
      drho2=1e-6;
   }

   /*--- initialisation de la premiere valeur de la contrainte ---*/
   contrainte0=0;
   ww2=1;

   /*--- recherche iterative sur le produit scalaire r2.v2 ---*/
   do {

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
         g1=(tau1-tau1*tau1*tau1/(6*u2))/(kgrav);

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

      /*--- calcul de phi=contrainte ---*/
      /*--- formule (8) pp 1546 ---*/
      contrainte=2*mu/r[2]-mu/aa-vx2*vx2-vy2*vy2-vz2*vz2;

      /*--- adapte le pas d'iteration et condition de sortie ---*/
      /*--- la contrainte doit changer de signe pour sortir  ---*/
      /*--- et le pas de drho2 doit etre petit.              ---*/
      if (centre==SOLEIL) {
         if ((contrainte*contrainte0)<0) {
            if (fabs(drho2)<1e-6) {
               ww2=-1;
            } else {
               drho2=-drho2/2.;
            }
         } else {
            drho2=1.5*drho2;
         }
         rho[2]+=drho2;
      }
      if (centre==TERRE) {
         if ((contrainte*contrainte0)<0) {
            if (fabs(drho2)<1e-8) {
               ww2=-1;
            } else {
               drho2=-drho2/2.;
            }
         } else {
            drho2=1.5*drho2;
         }
         rho[2]+=drho2;
      }
      contrainte0=contrainte;

   } while(ww2>0) ;

   /*--- recherche des elements orbitaux a l'instant 2 ---*/
   mc_cu2xyzeq(x[2],y[2],z[2],a,&x[2],&y[2],&z[2]);
   if (centre==SOLEIL) {
      mc_xyzeq2ec(x[2],y[2],z[2],eps,&x[2],&y[2],&z[2]);
   }
   mc_cu2xyzeq(vx2,vy2,vz2,a,&vx2,&vy2,&vz2);
   if (centre==SOLEIL) {
      mc_xyzeq2ec(vx2,vy2,vz2,eps,&vx2,&vy2,&vz2);
   }
   mc_xvx2elem(x[2],y[2],z[2],vx2,vy2,vz2,jj[2],jj_equinoxe,kgrav,elem);
   mc_elemplus(obs,elem,2);
   elem->code2+=4;
}

void mc_mvc2d(struct observ *obs,double ee,struct elemorb *elem,double jj_equinoxe)
/***************************************************************************/
/* Methode MVC 2 observations. Excentricite contrainte.                    */
/***************************************************************************/
/* ref : Marsden B.G. AJ 90, (1985) pp 1546                                */
/* Methode utilisable pour les satellites                                  */
/***************************************************************************/
{
   double l[4],m[4],n[4],ll[4],mm[4],nn[4];
   double a[10];
   double jj[4],rho[3],rho0[3];
   double x[4],y[4],z[4],r[4];
   double xs[4],ys[4],zs[4],xxs,yys,zzs,eps;
   double lls[10],mms[10],uus[10],ls,bs,rs;
   int k;
   double tau1,f1,g1,u2;
   double w2,vx2,vy2,vz2,contrainte,drho2;
   double mu;
   double paradx,parady,paradz;
   double rv,v,rr,ex,ey,ez,e0;
   int centre; /* helio=SOLEIL  geo=TERRE */
   double kgrav;
   double *xiter,*yiter,yitermin;
   double rhomax;
   int niter,kiter,kk,kyitermin,sortie,elemok=0;
   struct elemorb elem0;
   double areach=3.0,dareachmin=1e23,dareach;
   /*FILE *f;*/
   
   centre=SOLEIL;
   /*centre=TERRE;*/
   if (centre==TERRE) {
      kgrav=(KGEOS);
   } else {
      kgrav=(K);
   }
   mu=(kgrav)*(kgrav);

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
         mc_precxyz((obs+k)->jjtd,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
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
      if (centre==TERRE) {
         mc_precxyz((obs+k)->jjtd,xxs,yys,zzs,jj_equinoxe,&xxs,&yys,&zzs);
      }
      mc_xyzeq2cu(xxs,yys,zzs,a,&xs[k],&ys[k],&zs[k]);
   }

   if (centre==SOLEIL) {
      /*--- valeur initiale de rho[2] assumee ---*/
      rho[2]=1e-4;
      /*--- valeur initiale du pas sur rho[2] ---*/
      drho2=1e-2;
      /*--- valeur maximale sur rho[2] ---*/
      rhomax=100.;
   }
   if (centre==TERRE) {
      /*--- valeur initiale de rho[2] assumee ---*/
      rho[2]=5e-5;
      /*--- valeur initiale du pas sur rho[2] ---*/
      drho2=1e-6;
      /*--- valeur maximale sur rho[2] ---*/
      rhomax=0.05;
   }
   niter = (int)ceil((rhomax-rho[2])/drho2);
   xiter=(double*)calloc(niter,sizeof(double));
   if (xiter==NULL) {
      return;
   }
   yiter=(double*)calloc(niter,sizeof(double));
   if (yiter==NULL) {
      free(xiter);
      return;
   }
   for (kiter=0;kiter<niter;kiter++) {
      xiter[kiter]=rho[2]+(drho2*kiter);
      yiter[kiter]=0.;
   }

   /* --- kk=0 : premiere boucle pour calculer la variation globale des residus ---*/
   /* --- kk=1 : boucle pour calculer les elements d'orbites au plus près de chaque solution ---*/
   /* --- kk=2 : calcule les elements d'orbites pour le plus faible résidu ---*/
   yitermin=1e23;
   kyitermin=0;
   sortie=0;
   for (kk=0;kk<=2;kk++) {

      if (sortie==1) {
         break;
      }

      for (kiter=0;kiter<niter;kiter++) {
         rho[2]=xiter[kiter];

         if (kk==1) {
            if (kiter>niter-2) {
               continue;
            }
            if (fabs(yiter[kiter])<=yitermin) {
               kyitermin=kiter;
               yitermin=fabs(yiter[kiter]);
            }
            if ((yiter[kiter]*yiter[kiter+1])>0) {
               continue;
            }
            /* --- on affine la valeur ---*/
            rho[2]=xiter[kiter]+drho2*yiter[kiter]/(yiter[kiter]-yiter[kiter+1]);
         }

         if (kk==2) {
            kiter=kyitermin;
            /* --- on affine la valeur ---*/
            rho[2]=xiter[kiter]+drho2*yiter[kiter]/(yiter[kiter]-yiter[kiter+1]);
         }

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
            g1=(tau1-tau1*tau1*tau1/(6*u2))/(kgrav);

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
   
         /*--- calcul du produit scalaire r2.v2=contrainte ---*/
         mc_prodscal(x[2],y[2],z[2],vx2,vy2,vz2,&rv);
         v=sqrt(vx2*vx2+vy2*vy2+vz2*vz2);
         rr=sqrt(x[2]*x[2]+y[2]*y[2]+z[2]*z[2]);
         ex=(v*v/mu-1/rr)*x[2]-rv/mu*vx2;
         ey=(v*v/mu-1/rr)*y[2]-rv/mu*vy2;
         ez=(v*v/mu-1/rr)*z[2]-rv/mu*vz2;
         e0=sqrt(ex*ex+ey*ey+ez*ez);
         contrainte=e0-ee;
         yiter[kiter]=contrainte;

         /*
         if (kk==0) {
            if (kiter==0) {
               f=fopen("toto.txt","wt");
            } else {
               f=fopen("toto.txt","at");
            }
            fprintf(f,"%f %f %f\n",xiter[kiter],yiter[kiter],e0);
            fclose(f);
         }
         */

         if (kk>=1) {
            /*--- recherche des elements orbitaux a l'instant 2 ---*/
            mc_cu2xyzeq(x[2],y[2],z[2],a,&x[2],&y[2],&z[2]);
            if (centre==SOLEIL) {
               mc_xyzeq2ec(x[2],y[2],z[2],eps,&x[2],&y[2],&z[2]);
            }
            mc_cu2xyzeq(vx2,vy2,vz2,a,&vx2,&vy2,&vz2);
            if (centre==SOLEIL) {
               mc_xyzeq2ec(vx2,vy2,vz2,eps,&vx2,&vy2,&vz2);
            }
            mc_xvx2elem(x[2],y[2],z[2],vx2,vy2,vz2,jj[2],jj_equinoxe,kgrav,&elem0);
            mc_elemplus(obs,&elem0,2);
            elem0.code2+=2;
            /* */
            dareach = fabs(elem0.q/(1.-elem0.e)-areach);
            if (dareach<dareachmin) {
               dareachmin=dareach;
               *elem=elem0;
               elemok=1;
            }
            sortie=1;
         }
      }

   }
   if (elemok==0) {
      *elem=elem0;
   }

   free(xiter);
   free(yiter);

}

