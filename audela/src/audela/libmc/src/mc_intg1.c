/* mc_intg1.c
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
/* MC : utilitaire de meca celeste                                         */
/* Alain Klotz                                                             */
/***************************************************************************/
/* Integration numerique pour le mouvement des n corps.                    */
/***************************************************************************/
#include "mc.h"

void mc_inimasse(double *mass)
/***************************************************************************/
/* Initialisation du tableau des masses des planetes.                      */
/***************************************************************************/
/***************************************************************************/
{
   mass[SOLEIL] =1.;
   mass[MERCURE]=1./6023600;
   mass[VENUS]  =1./408523.5;
   mass[TERRE]  =1./332946;
   mass[MARS]   =1./3098710;
   mass[JUPITER]=1./1047.355;
   mass[SATURNE]=1./3498.5;
   mass[URANUS] =1./22869;
   mass[NEPTUNE]=1./19314;
   mass[PLUTON] =1./3000000;
   mass[LUNE]   =mass[TERRE]/81.3;
   mass[LUNE_ELP]=mass[TERRE]/81.3;
   mass[CERES]  =5.9e-10;
   mass[VESTA]  =1.2e-10;
   mass[PALLAS] =1.1e-10; /* 13 */
}

void mc_integ1(double jjdeb, double jjfin, double jjpas, struct elemorb elem,double jj_equinoxe, double *x, double *y, double *z, double *vx, double *vy, double *vz)
/***************************************************************************/
/* Calcule le vect. geocent. d'un astre elem a la date jjfin dans le       */
/* repere equatorial.                                                      */
/***************************************************************************/
/***************************************************************************/
{
   double mass[NB_PLANETES+1],masse[NB_PLANETES+3];
   int k,kk,planete,nbcorps,nbvect,plan_deb,plan_fin;
   double *vect,eps,r,v,m;
   struct pqw elempq;
   char nom_fichier_out[]="" ;

   plan_deb=VENUS;
   plan_fin=JUPITER;
   nbcorps=2+plan_fin-plan_deb+1;
   nbvect=nbcorps*6;
   vect  = (double *)calloc(nbvect+1 ,sizeof(double));

   mc_inimasse(mass);
   /*--- Soleil ---*/
   masse[1]=mass[SOLEIL];
   vect[1]=vect[2]=vect[3]=vect[4]=vect[5]=vect[6]=0.;
   /*--- Planete ---*/
   masse[2]=0.0;
   mc_obliqmoy(jj_equinoxe,&eps);
   mc_precelem(elem,elem.jj_equinoxe,jj_equinoxe,&elem);
   mc_elempqec(elem,&elempq);
   mc_elempqeq(elempq,eps,&elempq);
   mc_anomoy(elem,jjdeb,&m);
   mc_anovrair(elem,m,&v,&r);
   mc_rv_xyz(elempq,r,v,&vect[7],&vect[8],&vect[9]);
   mc_rv_vxyz(elempq,elem,r,v,&vect[10],&vect[11],&vect[12]);
   /*--- autres planetes du systeme solaire ---*/
   for (k=plan_deb;k<=plan_fin;k++) {
      kk=1+k-plan_deb;
      planete=k;
      masse[3+kk]=mass[planete];
      mc_xvxpla(jjdeb,planete,jj_equinoxe,
      &vect[12+(kk-1)*6+1],&vect[12+(kk-1)*6+2],&vect[12+(kk-1)*6+3],
      &vect[12+(kk-1)*6+4],&vect[12+(kk-1)*6+5],&vect[12+(kk-1)*6+6]);
   }
   if (jjpas==0) {
      mc_rk45(jjdeb,jjfin,vect,nbvect,nom_fichier_out,masse,1e-8);
   } else {
      mc_rk4(jjdeb,jjfin,vect,nbvect,nom_fichier_out,masse,jjpas);
   }
   *x =vect[ 7]-vect[1];
   *y =vect[ 8]-vect[2];
   *z =vect[ 9]-vect[3];
   *vx=vect[10]-vect[4];
   *vy=vect[11]-vect[5];
   *vz=vect[12]-vect[6];
   /*--- il faut rajouter vx vy vz pour le changement d'epoque ---*/
   free(vect);
}

void mc_rk4(double tdeb, double tfin, double *x, int dimx, char *nom_fichier_out,double *masse,double pas)
/***************************************************************************/
/* equadif : indice permettant de se connecter sur un systeme differentiel */
/* tdeb    : temps de l'instant initial                                    */
/* tfin    : temps de l'instant final d'integration                        */
/* *x      : vecteur des conditions initiales (et du resultat)             */
/* dimx    : nombre d'elements dans le vecteur.                            */
/* *nom_fichier_out : =="" en mode normal                                  */
/*                    !="" pour sortir tous les resultats intermediaires   */
/* pas     : pas du calcul (en jours)                                      */
/***************************************************************************/
/*   x       = (double *)          calloc(dimx+1,sizeof(double));          */
/***************************************************************************/
{
   FILE *fichier1=NULL;
   int save,k,k1,n,l,ii;
   long compteur,signe;
   double t,tt,h,ht,tm,tl=1e0;
   int dimbk=6,dimbl=5,dimch=6,dima=6,dimxx,dimbll;
   double *a,*b,*ch,*ct,*f,*z,*xt,*te;

   a  = (double *) calloc((dima+1),sizeof(double));
   b  = (double *) calloc((dimbk+1)*(dimbl+1),sizeof(double));
   ch = (double *) calloc((dimch+1),sizeof(double));
   ct = (double *) calloc((dimch+1),sizeof(double));
   f  = (double *) calloc((dimbk+1)*(dimx+1),sizeof(double));
   z  = (double *) calloc((dimx+1),sizeof(double));
   xt = (double *) calloc((dimx+1),sizeof(double));
   te = (double *) calloc((dimx+1),sizeof(double));

   /* === initialisation de RK 5 === */
   a[1]=0.0;
   a[2]=2./9;
   a[3]=1./3;
   a[4]=3./4;
   a[5]=1.;
   a[6]=5./6;

   /* B(K,L)=b[dimbll*K+L] */
   dimbll=dimbl+1;
   b[dimbll*2+1]=2./9;
   b[dimbll*3+1]=1./12;
   b[dimbll*3+2]=1./4;
   b[dimbll*4+1]=69./128;
   b[dimbll*4+2]=-243./128;
   b[dimbll*4+3]=135./64;
   b[dimbll*5+1]=-17./12;
   b[dimbll*5+2]=27./4;
   b[dimbll*5+3]=-27./5;
   b[dimbll*5+4]=16./15;
   b[dimbll*6+1]=65./432;
   b[dimbll*6+2]=-5./16;
   b[dimbll*6+3]=13./16;
   b[dimbll*6+4]=4./27;
   b[dimbll*6+5]=5./144;

   ch[1]=47./450;
   ch[2]=0.0;
   ch[3]=12./25;
   ch[4]=32./225;
   ch[5]=1./30;
   ch[6]=6./25;

   ct[1]=-1./150;
   ct[2]=0.0;
   ct[3]=3./100;
   ct[4]=-16./75;
   ct[5]=-1./20;
   ct[6]=6./25;

   t=tdeb;
   if (tdeb>tfin) {
      signe=-1;
   } else {
      signe=1;
   }
   compteur=1;
   h=0.1;
   dimxx=dimx+1;

   if (strcmp(nom_fichier_out,"")==0) {
      save=0;
   } else {
      save=1;
      if((fichier1=fopen( nom_fichier_out,"wt"))==NULL) {
         printf("probleme d'ouverture du fichier\n");
      }
   }
   t=tdeb;

   /* === grande boucle sur t === */
   do {
      tt=t;
      mc_equa_dif2(x,dimx,z,masse);
      for (n=1;n<=dimx;n++) {
         f[dimxx*1+n]=z[n];
         xt[n]=x[n];
      }
      do {
         for (k=2;k<=6;k++) {
            t=tt+a[k]*h*signe;
            for (n=1;n<=dimx;n++) {
               x[n]=xt[n];
               k1=k-1;
               for (l=1;l<=k1;l++) {
                  x[n]+=(h*b[dimbll*k+l]*f[dimxx*l+n]);
               }
            }
            mc_equa_dif2(x,dimx,z,masse);
            for (n=1;n<=dimx;n++) {
               f[dimxx*k+n]=z[n];
            }
         }
         for (n=1;n<=dimx;n++) {
            te[n]=0.0;
            x[n]=xt[n];
            for (k=1;k<=6;k++) {
               x[n]+=(h*ch[k]*f[dimxx*k+n]);
               te[n]+=(h*ct[k]*f[dimxx*k+n]);
            }
            te[n]=fabs(te[n]);
         }
         tm=0;
         for (n=1;n<=dimx;n++) {
            if (te[n]>=tm) {
               tm=te[n];
            }
         }
         ht=h;
         h=.9*h*pow((tl/tm),.2);
         if (fabs(h)<fabs(pas)) {
            ht=fabs(pas);
            tm=tl+1;
         } else {
            /*--- le pas est trop grand ---*/
         }
      } while (tm>tl) ;
      t=tt+ht*signe;
      if (fmod(compteur,1)==0) {
         /*
         printf("(%g) ",t);
         for (k=1;k<=6;k++) {
            printf("%g ",x[k]);
         }
         printf("D=%g h=%g",sqrt( (x[1]-x[7])*(x[1]-x[7]) + (x[2]-x[8])*(x[2]-x[8]) ),h);
         printf("\n");
         */
         if (save==1) {
            fprintf(fichier1,"%e ",t);
            for (ii=1;ii<=dimx;ii++) {
               fprintf(fichier1,"%e ",x[ii]);
            }
            fprintf(fichier1,"\n");
         }
      }
      compteur++;
      if (h<0) {
         if (save==1) {
            fclose(fichier1);
         }
         free(a);
         free(b);
         free(ch);
         free(ct);
         free(f);
         free(z);
         free(xt);
         free(te);
         return;
      }
      if (((t>=tfin)&&(signe==1))||((t<=tfin)&&(signe==-1))) {
         h=-fabs(tfin-t);
      }
   } while (( ((t<tfin)&&(signe==1))||((t>tfin)&&(signe==-1)) )||(h<0)) ;
   if (save==1) {
      fclose(fichier1);
   }
   free(a);
   free(b);
   free(ch);
   free(ct);
   free(f);
   free(z);
   free(xt);
   free(te);
}

void mc_rk45(double tdeb, double tfin, double *x, int dimx, char *nom_fichier_out,double *masse,double tl)
/***************************************************************************/
/* resolution d'un systeme d'equatif par la methode RK45 (pas adaptatif)   */
/***************************************************************************/
/* equadif : indice permettant de se connecter sur un systeme differentiel */
/* tdeb    : temps de l'instant initial                                    */
/* tfin    : temps de l'instant final d'integration                        */
/* *x      : vecteur des conditions initiales (et du resultat)             */
/* dimx    : nombre d'elements dans le vecteur.                            */
/* *nom_fichier_out : =="" en mode normal                                  */
/*                    !="" pour sortir tous les resultats intermediaires   */
/* tl      : tolerence de l'erreur de calcul (1e0 en general)              */
/***************************************************************************/
/*   x       = (double *)          calloc(dimx+1,sizeof(double));          */
/***************************************************************************/
{
   FILE *fichier1=NULL;
   int save,k,k1,n,l,ii,signe;
   long compteur;
   double t,tt,h,ht,tm;
   int dimbk=6,dimbl=5,dimch=6,dima=6,dimxx,dimbll;
   double *a,*b,*ch,*ct,*f,*z,*xt,*te;

   a  = (double *) calloc((dima+1),sizeof(double));
   b  = (double *) calloc((dimbk+1)*(dimbl+1),sizeof(double));
   ch = (double *) calloc((dimch+1),sizeof(double));
   ct = (double *) calloc((dimch+1),sizeof(double));
   f  = (double *) calloc((dimbk+1)*(dimx+1),sizeof(double));
   z  = (double *) calloc((dimx+1),sizeof(double));
   xt = (double *) calloc((dimx+1),sizeof(double));
   te = (double *) calloc((dimx+1),sizeof(double));

   /* === initialisation de RK 5 === */
   a[1]=0.0;
   a[2]=2./9;
   a[3]=1./3;
   a[4]=3./4;
   a[5]=1.;
   a[6]=5./6;

   /* B(K,L)=b[dimbll*K+L] */
   dimbll=dimbl+1;
   b[dimbll*2+1]=2./9;
   b[dimbll*3+1]=1./12;
   b[dimbll*3+2]=1./4;
   b[dimbll*4+1]=69./128;
   b[dimbll*4+2]=-243./128;
   b[dimbll*4+3]=135./64;
   b[dimbll*5+1]=-17./12;
   b[dimbll*5+2]=27./4;
   b[dimbll*5+3]=-27./5;
   b[dimbll*5+4]=16./15;
   b[dimbll*6+1]=65./432;
   b[dimbll*6+2]=-5./16;
   b[dimbll*6+3]=13./16;
   b[dimbll*6+4]=4./27;
   b[dimbll*6+5]=5./144;

   ch[1]=47./450;
   ch[2]=0.0;
   ch[3]=12./25;
   ch[4]=32./225;
   ch[5]=1./30;
   ch[6]=6./25;

   ct[1]=-1./150;
   ct[2]=0.0;
   ct[3]=3./100;
   ct[4]=-16./75;
   ct[5]=-1./20;
   ct[6]=6./25;

   t=tdeb;
   if (tdeb>tfin) {
      signe=-1;
   } else {
      signe=1;
   }
   compteur=1;
   h=0.1;
   dimxx=dimx+1;

   if (strcmp(nom_fichier_out,"")==0) {
      save=0;
   } else {
      save=1;
      if((fichier1=fopen( nom_fichier_out,"wt"))==NULL) {
         printf("probleme d'ouverture du fichier\n");
      }
   }
   t=tdeb;

   /* === grande boucle sur t === */
   do {
      tt=t;
      mc_equa_dif2(x,dimx,z,masse);
      for (n=1;n<=dimx;n++) {
         f[dimxx*1+n]=z[n];
         xt[n]=x[n];
      }
      do {
         for (k=2;k<=6;k++) {
            t=tt+a[k]*h*signe;
            for (n=1;n<=dimx;n++) {
               x[n]=xt[n];
               k1=k-1;
               for (l=1;l<=k1;l++) {
                  x[n]+=(h*b[dimbll*k+l]*f[dimxx*l+n]);
               }
            }
            mc_equa_dif2(x,dimx,z,masse);
            for (n=1;n<=dimx;n++) {
               f[dimxx*k+n]=z[n];
            }
         }
         for (n=1;n<=dimx;n++) {
            te[n]=0.0;
            x[n]=xt[n];
            for (k=1;k<=6;k++) {
               x[n]+=(h*ch[k]*f[dimxx*k+n]);
               te[n]+=(h*ct[k]*f[dimxx*k+n]);
            }
            te[n]=fabs(te[n]);
         }
         tm=0;
         for (n=1;n<=dimx;n++) {
            if (te[n]>=tm) {
               tm=te[n];
            }
         }
         ht=h;
         h=.9*h*pow((tl/tm),.2);
      } while (tm>tl) ;
      t=tt+ht*signe;
      if (fmod(compteur,1)==0) {
         /*
         printf("(%g) ",t);
         for (k=1;k<=6;k++) {
            printf("%g ",x[k]);
         }
         printf("D=%g h=%g",sqrt( (x[1]-x[7])*(x[1]-x[7]) + (x[2]-x[8])*(x[2]-x[8]) ),h);
         printf("\n");
         */
         if (save==1) {
            fprintf(fichier1,"%e ",t);
            for (ii=1;ii<=dimx;ii++) {
               fprintf(fichier1,"%e ",x[ii]);
            }
            fprintf(fichier1,"\n");
         }
      }
      compteur++;
      if (h<0) {
         if (save==1) {
            fclose(fichier1);
         }
         free(a);
         free(b);
         free(ch);
         free(ct);
         free(f);
         free(z);
         free(xt);
         free(te);
         return;
      }
      if (((t>=tfin)&&(signe==1))||((t<=tfin)&&(signe==-1))) {
         h=-fabs(tfin-t);
      }
   } while (( ((t<tfin)&&(signe==1))||((t>tfin)&&(signe==-1)) )||(h<0)) ;
   if (save==1) {
      fclose(fichier1);
   }
   free(a);
   free(b);
   free(ch);
   free(ct);
   free(f);
   free(z);
   free(xt);
   free(te);
}

void mc_equa_dif2(double *x,int dimx,double *z,double *masse)
/****************************************************/
/* equations differentielles de gravitation         */
/****************************************************/
/* --- vect[1+(i-1)*6]=x  de la planete i       --- */
/* --- vect[2+(i-1)*6]=y  de la planete i       --- */
/* --- vect[3+(i-1)*6]=z  de la planete i       --- */
/* --- vect[4+(i-1)*6]=vx de la planete i       --- */
/* --- vect[5+(i-1)*6]=vx de la planete i       --- */
/* --- vect[6+(i-1)*6]=vx de la planete i       --- */
/****************************************************/
{
   int k,nbcorps,i,j;
   double xixj,dx,dy,dz,rij,res,gmsol;
   gmsol=(K)*(K);

   /* --- vect[k+(i-1)*6] ---*/
   nbcorps=dimx/6;
   for (i=1;i<=nbcorps;i++) {
      for (k=1;k<=3;k++) {
         /* --- d(xi)/dt=vxi ---*/
         z[k+(i-1)*6]=x[k+3+(i-1)*6];
      }
      for (k=4;k<=6;k++) {
         /* --- d(vxi)/dt=-G(mj*(xj-xi)/rij^3 ---*/
         res=0;
         for (j=1;j<=nbcorps;j++) {
            if (j!=i) {
               xixj=x[k-3+(j-1)*6]-x[k-3+(i-1)*6];
               dx=x[1+(j-1)*6]-x[1+(i-1)*6];
               dy=x[2+(j-1)*6]-x[2+(i-1)*6];
               dz=x[3+(j-1)*6]-x[3+(i-1)*6];
               rij=pow((dx*dx+dy*dy+dz*dz),1.5);
               res=res+gmsol*masse[j]*xixj/rij;
            }
         }
         z[k+(i-1)*6]=res;
      }
      /*
      printf("corps nø%d\n",i);
      for (k=1;k<=6;k++) {
         printf("x[i]=%g z[i]=%g\n",x[k+(i-1)*6],z[k+(i-1)*6]);
      }
      */
   }
}

