/* mc_macr3.c
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

void mc_determag(struct elemorb *elem, struct observ *obs, int nbobs)
/***************************************************************************/
/* Determination du coef de magnitude absolue pour un asteroide ou de Ho   */
/* et n pour une comete.                                                   */
/* La valeur de g=0.15                                                     */
/***************************************************************************/
{
   double asd,dec,delta,rr,rsol,elong,phase,mag,h,h0;
   double logd1=0.,logd2=0.,logr1=0.,logr2=0.,mag1=0.,mag2=0.,a;
   int k,kk;
   elem->n=4;
   elem->g=0.15;
   if (elem->nbjours>50) {
      for (kk=0,k=1;k<=nbobs;k++) {
         if (obs[k].mag1!=MAGNULL) {
            kk++;
            mc_adastrom(obs[k].jjtd,*elem,obs[k].jj_equinoxe,&asd,&dec,&delta,&rr,&rsol);
            if (kk==1) {
               mag1=obs[k].mag1;
               logd1=log10(delta);
               logr1=log10(rr);
            } else {
               mag2=obs[k].mag1;
               logd2=log10(delta);
               logr2=log10(rr);
            }
         }
      }
      if (kk>=2) {
         a=logr1-logr2;
         if (fabs(a)>1e-3) {
            elem->n=((mag1-mag2)-5*(logd1-logd2))/a;
         }
      }
   }
   h=0;
   h0=0;
   for (kk=0,k=1;k<=nbobs;k++) {
      if (obs[k].mag1!=MAGNULL) {
         kk++;
         mc_adastrom(obs[k].jjtd,*elem,obs[k].jj_equinoxe,&asd,&dec,&delta,&rr,&rsol);
         mc_elonphas(rr,rsol,delta,&elong,&phase);
         mc_magaster(rr,delta,phase,0,elem->g,&mag);
         h+=((obs[k].mag1)-mag);
         mc_magcomete(rr,delta,0,elem->n,&mag);
         h0+=((obs[k].mag1)-mag);
      }
   }
   if (kk==0) {
      elem->h=14.;
      elem->h0=14.;
      elem->code2+=64;
   } else {
      elem->h=(1.*h/kk);
      elem->h0=(1.*h0/kk);
   }
}

void mc_bowell22(char *nom_fichier_in,char *num_aster,char *nom_fichier_out,int *concordance)
/***************************************************************************/
/* Transforme les elements d'orbite initialement au format de la base de   */
/* Bowell en elements d'orbite au format interne                           */
/* On rentre, soit le numero (ex : 1 pour Ceres) ou bien le numero         */
/* provisoire toutes lettres collees (ex : 1997DQ).                        */
/***************************************************************************/
/***************************************************************************/
{
   char chaine[80];
   int trouve;
   struct elemorb elem;
   struct asterident aster;

   mc_bow_dec2(num_aster,nom_fichier_in,&elem,&aster,&trouve);
   if (trouve==1) {
      *concordance=OK;
      if (aster.num!=0) {
         sprintf(chaine,"(%d) ",aster.num);
      } else {
         strcpy(chaine,"");
      }
      strcat(chaine,aster.name);
      *(chaine+70)='\0';
      sprintf(elem.designation,chaine);
      mc_writeelem(&elem,nom_fichier_out);
   } else {
      *concordance=PB;
   }
}

void mc_ephem1b(char *nom_fichier_ele,double jjdeb,double jjfin, double pasjj, double equinoxe, char *nom_fichier_out,int *concordance)
/***************************************************************************/
/* Genere un fichier ASCII d'ephemerides pour des astres definis par leurs */
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
   char separ[81];
   int trouve,nblighead,ligdeb,ligdebold,premier=OK;

   ligdeb=1;
   do {
      ligdebold=ligdeb+1;
      trouve=PB;
      mc_lec_ele_mpec1(nom_fichier_ele,&elem,&trouve,&ligdeb);
      if (ligdeb!=ligdebold) {
         *concordance=OK;
         if (premier==OK) {
            premier=PB;
            mc_wri_ele_mpec1(nom_fichier_out,elem,WRITE);
         } else {
            mc_wri_ele_mpec1(nom_fichier_out,elem,APPEND);
         }
         if (( fichier_out=fopen(nom_fichier_out,"a") ) == NULL) {
            printf("fichier non trouve\n");
            return;
         }
         memset(separ,'-',79);separ[79]='\0';
         fprintf(fichier_out,"%s\n",separ);
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
         fprintf(fichier_out,"\n");
         fclose(fichier_out);
      } else {
         *concordance=PB;
      }
   } while(ligdeb!=ligdebold);
}


void mc_ephem2(char *nom_fichier_ele,double jj, double rangetq, double pastq, double equinoxe, char *nom_fichier_out,int *concordance)
/***************************************************************************/
/* Genere un fichier ASCII d'ephemerides pour un astre defini par ses      */
/* elements d'orbite.                                                      */
/* pour la date julienne jj.                                               */
/* on fait varier l'instant de passage au perihelie entre -rangetq et      */
/* +rangetq autour de Tq par pas de pastq.                                 */
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
   double jjtq0,jjtqdeb,jjtqfin,jjtq;
   int /*trouve,*/nblighead,k,kmin,kmax;

   mc_readelem(nom_fichier_ele,&elem);
   /*
   trouve=1;
   if (trouve==1) {
   */
      *concordance=OK;
      if (( fichier_out=fopen(nom_fichier_out,"w") ) == NULL) {
         printf("fichier non trouve\n");
         return;
      }
      /*--- entete du fichier de sortie ---*/
      mc_fprfeph2(1,equinoxe,jj,elem,fichier_out,&nblighead);
      /*--- constantes equatoriales ---*/
      mc_obliqmoy(equinoxe,&eps);
      /*--- precession et conversion des elements ---*/
      mc_precelem(elem,elem.jj_equinoxe,equinoxe,&elem);
      mc_elempqec(elem,&elempq);
      mc_elempqeq(elempq,eps,&elempq);
/*
   if (elem.e==1) {
      n=K/(DR)/elem.q/sqrt(2*elem.q);
   } else {
      a=elem.q/fabs(1-elem.e);
      n=K/(DR)/a/sqrt(a);
   }
   ...
   jj_m0-jj_q=m0/(n*DR)
   m0=0;
   m0=(m0+(jj-jj_q)*n*DR);
   jj_m0=jj;

*/
      jjtqdeb=elem.jj_m0-rangetq;
      jjtq0  =elem.jj_m0;
      jjtqfin=elem.jj_m0+rangetq;
      jjtq=jjtqdeb;
      kmin=(int)(floor((jjtqdeb-jjtq0)/pastq));
      kmax=-kmin;
      k=kmin;
      do {
         jjtq=jjtq0+k*pastq;
         if (jjtq>jjtqfin) {
            jjtq=jjtqfin;
         }
         elem.jj_m0=jjtq;
         k++;

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
         mc_fprfeph22(1,elem,(jjtq-jjtq0),asd,dec,mag,delta,r,elong,dist,posangle,incert,fichier_out);
      } while (k<=kmax) ;
      fclose(fichier_out);
   /*
   } else {
      *concordance=PB;
   }
   */
}

void mc_paradist(char *nom_fichier_obs,char *nom_fichier_ele,char *nom_fichier_out)
/***************************************************************************/
/* Calcul de la distance Terre Astre a partir d'observations effectuees    */
/* aux memes moments par deux sites.                                       */
/***************************************************************************/
/***************************************************************************/
{
   char nom_fichier_noms[25],designation[15],texte2[120],ligne[120];
   FILE *fichier_nom,*fichier_out;
   int len,col1,col2,nbobs1,nbobs2;
   struct observ *obs1,*obs2;
   int k1,k2;
   double dt,dist,corde,pa;
   double jour;
   int annee,mois;
   char chaine[80];
   struct elemorb elem;
   int ligdeb=1,concordance;
   double asd,dec,delta,rr,rsol,a;

   if (strcmp(nom_fichier_obs,nom_fichier_out)==0) {return;}
   strcpy(nom_fichier_noms,"@names.txt");
   mc_lec_mpc_noms(nom_fichier_obs,nom_fichier_noms);
   nbobs1=0;
   obs1 = (struct observ *) calloc(nbobs1+1,sizeof(struct observ));
   mc_lec_obs_mpc(nom_fichier_obs,obs1,&nbobs1);
   free(obs1);
   obs1 = (struct observ *) calloc(nbobs1+1,sizeof(struct observ));
   mc_lec_obs_mpc(nom_fichier_obs,obs1,&nbobs1);
   if (( fichier_nom=fopen(nom_fichier_noms,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   if (( fichier_out=fopen(nom_fichier_out,"wt") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   do {
      if (fgets(ligne,120,fichier_nom)!=NULL) {
	 mc_lec_ele_mpec1(nom_fichier_ele,&elem,&concordance,&ligdeb);
	 /*
	 printf("con=%d\n",concordance);
	 mc_affielem(elem);
	 */
	 len=strlen(ligne);
	 col1= 1;col2= 12;strncpy(texte2,ligne+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
	 strcpy(designation,texte2);
	 col1= 14;col2=len;strncpy(texte2,ligne+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
	 nbobs2=atoi(texte2);
	 obs2 = (struct observ *) calloc(nbobs2+1,sizeof(struct observ));
	 mc_select_observ(obs1,nbobs1,designation,obs2,&nbobs2);
	 fprintf(fichier_out,"Resultats de mesure de parallaxe sur %s\n",designation);
	 fprintf(fichier_out,"-sites- ------date------ corde   angle  mesure   ephem  erreur\n");
	 fprintf(fichier_out," (MPC)        (TU)        (km)  arcsec   (UA)     (UA) pourcent\n\n");
	 for (k1=1;k1<=nbobs2-1;k1++) {
	    for (k2=k1+1;k2<=nbobs2;k2++) {
	       dt=obs2[k2].jjtd-obs2[k1].jjtd;
	       if ((fabs(dt)<=1e-4)&&(strcmp(obs2[k1].codmpc,"500")!=0)&&(strcmp(obs2[k2].codmpc,"500")!=0)) {
		  mc_paradist_calc(obs2,k1,k2,&pa,&corde,&dist);
		  fprintf(fichier_out,"%s-%s ",obs2[k1].codmpc,obs2[k2].codmpc);
		  mc_jd_date(obs2[k1].jjtu,&annee,&mois,&jour);
		  mc_fstr((double)(annee),PB,4,0,PB,chaine);
		  fprintf(fichier_out,"%s ",chaine);
		  mc_fstr((double)(mois),PB,2,0,PB,chaine);
		  fprintf(fichier_out,"%s ",chaine);
		  mc_fstr(jour,PB,2,5,PB,chaine);
		  fprintf(fichier_out,"%s ",chaine);
		  mc_fstr(corde,PB,5,0,PB,chaine);
		  fprintf(fichier_out,"%s ",chaine);
		  mc_fstr(pa/(DR)*3600,PB,4,2,PB,chaine);
		  fprintf(fichier_out,"%s ",chaine);
		  mc_fstr(dist/(UA),PB,2,4,PB,chaine);
		  fprintf(fichier_out,"%s ",chaine);
		  /*
		  if (concordance==OK) {
		     mc_adastrom(obs2[k1].jjtd,elem,obs2[k1].jj_equinoxe,&asd,&dec,&delta,&rr,&rsol);
		     mc_fstr(delta,PB,2,4,PB,chaine);
		     fprintf(fichier_out,"%s ",chaine);
		     a=(dist/(UA)-delta)/delta*100;
		     mc_fstr(a,PBB,4,0,PB,chaine);
		     fprintf(fichier_out,"%s\% ",chaine);
		  }
		  */
		     mc_adastrom(obs2[k1].jjtd,elem,obs2[k1].jj_equinoxe,&asd,&dec,&delta,&rr,&rsol);
		     mc_fstr(delta,PB,2,4,PB,chaine);
		     fprintf(fichier_out,"%s ",chaine);
		     a=(dist/(UA)-delta)/delta*100;
		     mc_fstr(a,PBB,4,0,PB,chaine);
		     fprintf(fichier_out,"%s ",chaine);
		  fprintf(fichier_out,"\n");
	       } else {
		  break;
	       }
	    }
	 }
	 free(obs2);
      }
   } while (feof(fichier_nom)==0);
   free(obs1);
   fclose(fichier_out);
   fclose(fichier_nom);
}

void mc_paradist_calc(struct observ *obs,int k1, int k2,double *parallaxe,double *corde,double *dist)
/***************************************************************************/
/* Calcul de la distance d'un astre a partir de deux observations realisees*/
/* en seux sites differents. Methode de la parallaxe.                      */
/***************************************************************************/
/***************************************************************************/
{
   double pdtot,posangle,lat_lieu1,lat_lieu2,dist1,dist2;
   double asd_lieu1,asd_lieu2,lon_lieu1,lon_lieu2,tsl1,tsl2;
   double dec_lieu1,dec_lieu2,x1,y1,z1,x2,y2,z2,alpha,beta,gamma,r,a,b,c;
   double delta_opt,ptot,x3,y3,z3,v1x,v1y,v1z,v2x,v2y,v2z,cospa,pa;
   int sortie;

   /*--- mesure de la parallaxe ---*/
   mc_sepangle(obs[k1].asd,obs[k2].asd,obs[k1].dec,obs[k2].dec,&pdtot,&posangle);

   /*--- prise en compte de l'applatissement de la Terre ---*/
   /*--- calcul de la distance entre les sites et le centre de la Terre --*/
   lat_lieu1=(obs[k1].rhocosphip==0) ? PI/2 : atan(obs[k1].rhosinphip/obs[k1].rhocosphip) ;
   dist1=6378140*obs[k1].rhocosphip/cos(lat_lieu1);
   lon_lieu1=-obs[k1].longuai;
   lat_lieu2=(obs[k2].rhocosphip==0) ? PI/2 : atan(obs[k2].rhosinphip/obs[k2].rhocosphip) ;
   dist2=6378140*obs[k2].rhocosphip/cos(lat_lieu2);
   lon_lieu2=-obs[k2].longuai;

   /*--- coordonnees spheriques equatoriales geocentriques des sites ---*/
   mc_tsl(obs[k1].jjtd,lon_lieu1,&tsl1);
   asd_lieu1=tsl1;
   dec_lieu1=lat_lieu1;
   mc_tsl(obs[k2].jjtd,lon_lieu2,&tsl2);
   asd_lieu2=tsl2;
   dec_lieu2=lat_lieu2;
   /*
   b=.99664719;
   c=atan((tan(lat_lieu1)/b/b));
   printf("%s (%f) %f %f\n",obs[k1].codmpc,obs[k1].jjtd,lon_lieu1/(DR),c/(DR));
   c=atan((tan(lat_lieu2)/b/b));
   printf("%s (%f) %f %f\n",obs[k2].codmpc,obs[k2].jjtd,lon_lieu2/(DR),c/(DR));
   printf("tsl1-tsl2=%f\n",(tsl1-tsl2)/(DR));
   */

   /*--- coordonnees cartesiennes equatoriales geocentriques des sites ---*/
   x1=dist1*cos(asd_lieu1)*cos(dec_lieu1);
   y1=dist1*sin(asd_lieu1)*cos(dec_lieu1);
   z1=dist1*sin(dec_lieu1);
   x2=dist2*cos(asd_lieu2)*cos(dec_lieu2);
   y2=dist2*sin(asd_lieu2)*cos(dec_lieu2);
   z2=dist2*sin(dec_lieu2);
   a=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
   *corde=a/1000;
   /*
   printf("Longueur de la corde entre les deux sites = %f km\n",a/1000);
   printf(" site 1 X=%+e Y=%+e Z=%+e metres\n",x1,y1,z1);
   printf(" site 2 X=%+e Y=%+e Z=%+e metres\n",x2,y2,z2);
   */

   /*--- determination de la distance de l'asteroide ---*/
   alpha=cos(obs[k1].asd)*cos(obs[k1].dec);
   beta =sin(obs[k1].asd)*cos(obs[k1].dec);
   gamma=sin(obs[k1].dec);
   r = (dist1>dist2) ? dist1 : dist2 ;
   delta_opt=0;
   ptot=pdtot;
   sortie=PB;
   do {
      r+=1e-4*UA;
      if (r>100*UA) {sortie=OK;}
      x3=r*alpha;
      y3=r*beta;
      z3=r*gamma;
      v1x=x1-x3;
      v1y=y1-y3;
      v1z=z1-z3;
      v2x=x2-x3;
      v2y=y2-y3;
      v2z=z2-z3;
      a=v1x*v2x+v1y*v2y+v1z*v2z;
      b=sqrt(v1x*v1x+v1y*v1y+v1z*v1z);
      c=sqrt(v2x*v2x+v2y*v2y+v2z*v2z);
      cospa=a/b/c;
      pa=acos(cospa);
      if ((pa<(ptot))&&(delta_opt==0)) { delta_opt=r; sortie=OK;}
   } while (sortie==PB) ;
   *dist=delta_opt;
   *parallaxe=ptot;
}

/***************************************************************************/
/* Save the *mat as a FITS file */
/***************************************************************************/
char *mc_savefits(float *mat,int naxis1, int naxis2,char *filename,mc_wcs *wcs)
{
   static char stringresult[1024];
   FILE *f;
   char line[1024],car;
   float value0;
   char *cars0;
   int k,k0;
   double deg2rad;
   long one= 1;
   int big_endian;
   f=fopen(filename,"wb");
   strcpy(line,"SIMPLE  =                    T / file does conform to FITS standard             ");
   fwrite(line,80,sizeof(char),f);
   strcpy(line,"BITPIX  =                  -32 / number of bits per data pixel                  ");
   fwrite(line,80,sizeof(char),f);
   strcpy(line,"NAXIS   =                    2 / number of data axes                            ");
   fwrite(line,80,sizeof(char),f);
   sprintf(line,"NAXIS1  =                  %3d / length of data axis 1                          ",naxis1);
   fwrite(line,80,sizeof(char),f);
   sprintf(line,"NAXIS2  =                  %3d / length of data axis 2                          ",naxis2);
   fwrite(line,80,sizeof(char),f);
   k0=7;
   if (wcs!=NULL) {
      deg2rad=(PI)/180.;
      strcpy(line,"EQUINOX  =               2000.0 / WCS keyword                                    ");
      fwrite(line,80,sizeof(char),f); k0++;
      strcpy(line,"CTYPE1   =           'RA---TAN' / WCS keyword                                    ");
      fwrite(line,80,sizeof(char),f); k0++;
      strcpy(line,"CTYPE2   =           'DEC--TAN' / WCS keyword                                    ");
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRPIX1  =           %10.5f / WCS keyword                                    ",wcs->crpix1);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRPIX2  =           %10.5f / WCS keyword                                    ",wcs->crpix2);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRVAL1  =           %10.6f / WCS keyword                                    ",wcs->crval1/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CRVAL2  =           %10.6f / WCS keyword                                    ",wcs->crval2/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CROTA2  =           %10.6f / WCS keyword                                    ",wcs->crota2/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CDELT1  =      %15.10f / WCS keyword                                    ",wcs->cdelt1/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CDELT2  =      %15.10f / WCS keyword                                    ",wcs->cdelt2/deg2rad);
      wcs->cd11=wcs->cdelt1*cos(wcs->crota2);
      wcs->cd12=fabs(wcs->cdelt2)*wcs->cdelt1/fabs(wcs->cdelt1)*sin(wcs->crota2);
      wcs->cd21=-fabs(wcs->cdelt1)*wcs->cdelt2/fabs(wcs->cdelt2)*sin(wcs->crota2);
      wcs->cd22=wcs->cdelt2*cos(wcs->crota2);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD11    =      %15.10f / WCS keyword                                    ",wcs->cd11/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD12    =      %15.10f / WCS keyword                                    ",wcs->cd12/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD21    =      %15.10f / WCS keyword                                    ",wcs->cd21/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD22    =      %15.10f / WCS keyword                                    ",wcs->cd22/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD1_1   =      %15.10f / WCS keyword                                    ",wcs->cd11/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD1_2   =      %15.10f / WCS keyword                                    ",wcs->cd12/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD2_1   =      %15.10f / WCS keyword                                    ",wcs->cd21/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
      sprintf(line,"CD2_2   =      %15.10f / WCS keyword                                    ",wcs->cd22/deg2rad);
      fwrite(line,80,sizeof(char),f); k0++;
   }
   strcpy(line,"END                                                                             ");
   fwrite(line,80,sizeof(char),f);
   strcpy(line,"                                                                                ");
   for (k=k0;k<=36;k++) {
      fwrite(line,80,sizeof(char),f);
   }
   /* byte order test */
   if (!(*((char *)(&one)))) {
      big_endian=1;
   } else {
      big_endian=0;
   }
   /* write data */
   for (k=0;k<naxis1*naxis2;k++) {
      value0=mat[k]; // 32=4*8bits
      if (big_endian==0) {
         cars0=(char*)&value0;
         car=cars0[0];
         cars0[0]=cars0[3];
         cars0[3]=car;
         car=cars0[1];
         cars0[1]=cars0[2];
         cars0[2]=car;
      }
      fwrite(&value0,1,sizeof(float),f);
   }
   //dx=naxis1*naxis2/2880.;
   //n=(int)(2880.*(dx-floor(dx)));
   value0=(float)0.;
   for (k=0;k<naxis1*naxis2;k++) {
      if (big_endian==0) {
         cars0=(char*)&value0;
         car=cars0[0];
         cars0[0]=cars0[3];
         cars0[3]=car;
         car=cars0[1];
         cars0[1]=cars0[2];
         cars0[2]=car;
      }
      fwrite(&value0,1,sizeof(float),f);
   }
   fclose(f);
   return stringresult;
}

void mc_simulc(mc_cdr cdr,double *relief,double *albedo,mc_cdrpos *cdrpos,int n,char *genefilename)
/***************************************************************************/
/* simulation de la courbe de lumiere d'un asteroide                       */
/***************************************************************************/
/***************************************************************************/
{
   int nhtm,exp,khtm0,khemis,khtm,k,kt;
   char *htm;
   double lll,bbb,l1,b1,l2,b2,l3,b3;
   double cosb,sinb,coslcosb,sinlcosb;
   double dl;
   double x1,x2,x3,y1,y2,y3,z1,z2,z3;
   double px12,py12,pz12,px13,py13,pz13;
   double px,py,pz;
   double npx,npy,npz,nx,ny,nz;
   double np,tr,q;
   double coslp,sinlp,coslpcosi,sinlpcosi,coslpsini,sinlpsini,sini,cosi;
   double r,rr,delta,delta2,dx,dy,dz;
   double nsx,nsy,nsz;  
   double e0,pr,i,cosths,costht,e,etotlamb,etotls,pe;
   double fourpi;
   double trtot=0.;
   double trtotmin,trtotmax;
   int khtms,nhtms;
   mc_htm *htms;
   double pmaxi,rmini;
   double rsx,rsy,rsz,lrs,brs,lc,bc,rs;
   double field;
   int k1,k2;
   float *image=NULL;
   double elamb,els;
   mc_wcs wcs;
   char filename[1024];
   double *dist=NULL;
   int *kdist=NULL;
   double pixx[3],pixy[3],x,y,z,frac;
   double albedomean;
   double volume,volumetot,masstot,xg,yg,zg;

   int nlon,nlat,klon,klat;
   double lon,lat;
   int level;
   double l0,date0,period,lp,bp;
   int frame_center; /* =0 sun =1 earth */
   date0=cdr.jd_phase0;
   level=cdr.htmlevel;
   l0=cdr.lon_phase0;
   period=cdr.period;
   lp=cdr.lonpole;
   bp=cdr.latpole;
   frame_center=cdr.frame_center;

   htm=(char*)calloc(level+3,sizeof(char));
   l0=l0*(DR);
   lp=lp*(DR);
   bp=bp*(DR);
   /* - F6 -*/
   i=bp-(PI)/2;
   cosi=cos(i);
   sini=sin(i);
   coslp=cos(lp);
   sinlp=sin(lp);
   coslpcosi=coslp*cosi;
   sinlpcosi=sinlp*cosi;
   coslpsini=coslp*sini;
   sinlpsini=sinlp*sini;
  
   e0=1400.; /* W/m2 at 1 A.U. */
   fourpi=4.*(PI);
   /* --- total number of triangles in each hemsiphere ---*/
   nhtm=(int)(8*pow(4,level))/2;
   /* --- total number of triangles ---*/
   nhtms=2*nhtm;
   /* --- fill the HTM structure by the corner coordinates ---*/
   if (level>5) { level=5; }
   if (level<0) { level=0; }
   htms=(mc_htm*)calloc(nhtms,sizeof(mc_htm));
   if (htms==NULL) {
      return;
   }
   dist=(double*)calloc(nhtms,sizeof(double));
   if (dist==NULL) {
      free(htms);
      return;
   }
   kdist=(int*)calloc(nhtms,sizeof(int));
   if (kdist==NULL) {
      free(htms);
      free(dist);
      return;
   }
   khtms=0;
   for (khemis=0;khemis<=1;khemis++) {
      for (khtm=0;khtm<nhtm;khtm++) {
         /* --- build the HTM code ---*/
         if (khemis==0) { htm[0]='S'; } else { htm[0]='N'; } 
         exp=(int)pow(4,level);
         khtm0=khtm;
         for (k=0;k<=level;k++) {
            htm[k+1]=khtm0/exp;
            khtm0-=(htm[k+1]*exp);
            htm[k+1]+=48;
            exp/=4;
         }
         htm[k+1]='\0';
         /* --- F1 : compute the corner coordinates ---*/
         mc_htm2radec(htm,&lll,&bbb,&level,&l1,&b1,&l2,&b2,&l3,&b3);
         /* --- fill the structure ---*/
         strcpy(htms[khtms].index,htm);
         htms[khtms].l=lll;
         htms[khtms].b=bbb;
         htms[khtms].l1=l1;
         htms[khtms].b1=b1;
         htms[khtms].l2=l2;
         htms[khtms].b2=b2;
         htms[khtms].l3=l3;
         htms[khtms].b3=b3;
         khtms++;
      }
   }
   free(htm);
   /* --- fill the HTM structure by the relief and albedo maps ---*/
   nlon=360;
   nlat=181;
   volumetot=0;
   masstot=0;
   x=y=z=0.;
   xg=yg=zg=0.;
   for (khtms=0;khtms<nhtms;khtms++) {
      /* --- F2 : compute the distance of surface to center for corners (m) ---*/
      albedomean=0.;
      lon=htms[khtms].l1;
      lat=htms[khtms].b1;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r1=relief[klon*nlat+klat];
      albedomean+=albedo[klon*nlat+klat];
      lon=htms[khtms].l2;
      lat=htms[khtms].b2;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r2=relief[klon*nlat+klat];
      albedomean+=albedo[klon*nlat+klat];
      lon=htms[khtms].l3;
      lat=htms[khtms].b3;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r3=relief[klon*nlat+klat];
      albedomean+=albedo[klon*nlat+klat];
      htms[khtms].albedo=albedomean/3.;
      /* --- compute the volume of the tetraedron ---*/
      lon=htms[khtms].l1;
      lat=htms[khtms].b1;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x1=htms[khtms].x1=htms[khtms].r1*coslcosb;
      y1=htms[khtms].y1=htms[khtms].r1*sinlcosb;
      z1=htms[khtms].z1=htms[khtms].r1*sinb;
      lon=htms[khtms].l2;
      lat=htms[khtms].b2;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x2=htms[khtms].x2=htms[khtms].r2*coslcosb;
      y2=htms[khtms].y2=htms[khtms].r2*sinlcosb;
      z2=htms[khtms].z2=htms[khtms].r2*sinb;
      lon=htms[khtms].l3;
      lat=htms[khtms].b3;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x3=htms[khtms].x3=htms[khtms].r3*coslcosb;
      y3=htms[khtms].y3=htms[khtms].r3*sinlcosb;
      z3=htms[khtms].z3=htms[khtms].r3*sinb;
      /* --- center of gravity of the tetraedron --- */
      volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
      htms[khtms].volume=volume;
      htms[khtms].density=cdr.density;
      htms[khtms].mass=volume*htms[khtms].density;
      htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
      htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
      htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
      /* --- add to determine the center of gravity of the body --- */
      x+=(htms[khtms].xg*htms[khtms].mass);
      y+=(htms[khtms].yg*htms[khtms].mass);
      z+=(htms[khtms].zg*htms[khtms].mass);
      masstot+=htms[khtms].mass;
      volumetot+=volume;
   }
   /* --- center of gravity (m) --- */
   xg=x/masstot;
   yg=y/masstot;
   zg=z/masstot;
   /* --- iterating corrections due to the offcentering of the center of gravity --- */
   for (kt=0;kt<4;kt++) {
      x=y=z=0.;
      volumetot=0;
      masstot=0;
      for (khtms=0;khtms<nhtms;khtms++) {
         htms[khtms].x1-=xg;
         htms[khtms].y1-=yg;
         htms[khtms].z1-=zg;
         x1=htms[khtms].x1;
         y1=htms[khtms].y1;
         z1=htms[khtms].z1;
         htms[khtms].r1=sqrt(x1*x1+y1*y1+z1*z1);
         htms[khtms].l1=atan2(htms[khtms].y1,htms[khtms].x1);
         htms[khtms].b1=asin(htms[khtms].z1/htms[khtms].r1);
         htms[khtms].x2-=xg;
         htms[khtms].y2-=yg;
         htms[khtms].z2-=zg;
         x2=htms[khtms].x2;
         y2=htms[khtms].y2;
         z2=htms[khtms].z2;
         htms[khtms].r2=sqrt(x2*x2+y2*y2+z2*z2);
         htms[khtms].l2=atan2(htms[khtms].y2,htms[khtms].x2);
         htms[khtms].b2=asin(htms[khtms].z2/htms[khtms].r2);
         htms[khtms].x3-=xg;
         htms[khtms].y3-=yg;
         htms[khtms].z3-=zg;
         x3=htms[khtms].x3;
         y3=htms[khtms].y3;
         z3=htms[khtms].z3;
         htms[khtms].r3=sqrt(x3*x3+y3*y3+z3*z3);
         htms[khtms].l3=atan2(htms[khtms].y3,htms[khtms].x3);
         htms[khtms].b3=asin(htms[khtms].z3/htms[khtms].r3);
         /* --- center of gravity of the tetraedron --- */
         volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
         htms[khtms].volume=volume;
         htms[khtms].density=cdr.density;
         htms[khtms].mass=volume*htms[khtms].density;
         htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
         htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
         htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
         /* --- add to determine the center of gravity of the body --- */
         x+=(htms[khtms].xg*htms[khtms].mass);
         y+=(htms[khtms].yg*htms[khtms].mass);
         z+=(htms[khtms].zg*htms[khtms].mass);
         masstot+=htms[khtms].mass;
         volumetot+=volume;
      }
      /* --- center of gravity should converge to (0,0,0) --- */
      xg=x/masstot;
      yg=y/masstot;
      zg=z/masstot;
   }
   /* --- searching for the largest altitude from the gravity center ---*/
   pmaxi=0.;
   for (khtms=0;khtms<nhtms;khtms++) {
      if (htms[khtms].r1>pmaxi) {pmaxi=htms[khtms].r1;}
      if (htms[khtms].r2>pmaxi) {pmaxi=htms[khtms].r2;}
      if (htms[khtms].r3>pmaxi) {pmaxi=htms[khtms].r3;}
   }
   /* --- allocate an image matrix ---*/
   /* --- the image is centered on the gravity center: cdrpos[].?aster ---*/
   rmini=1e21;
   for (kt=0;kt<n;kt++) {
      dx=cdrpos[kt].xaster;
      dy=cdrpos[kt].yaster;
      dz=cdrpos[kt].zaster;
      if (frame_center==1) {
         dx-=cdrpos[kt].xearth;
         dy-=cdrpos[kt].yearth;
         dz-=cdrpos[kt].zearth;
      }
      rr=dx*dx+dy*dy+dz*dz;
      rr+=(xg*xg+yg*yg+zg*zg)/(UA)/(UA);
      r=sqrt(rr);
      if (r<rmini) {rmini=r;}
   }
   wcs.naxis1=200;
   wcs.naxis2=200;
   field=atan(2*pmaxi/(UA)/rmini)*1.5;
   wcs.cdelt1=field/wcs.naxis1;
   wcs.cdelt2=field/wcs.naxis2;
   wcs.crpix1=wcs.naxis1/2+.5;
   wcs.crpix2=wcs.naxis2/2+.5;
   wcs.crota2=0.;
   if (genefilename!=NULL) {
      image=(float*)calloc(wcs.naxis1*wcs.naxis2,sizeof(float));
      if (image==NULL) {
         /* --- TBD error */
         free(htms);
         free(dist);
         free(kdist);
      }
   }
   /* --- loop over the phase dates ---*/
   for (kt=0;kt<n;kt++) {
      etotlamb=etotls=0.;
      dl=fmod(l0/(DR)+360.*(cdrpos[kt].jd-date0)/period,360.)*(DR);
      trtot=0.;
      /* --- distances from the gravity center ---*/
      rr=cdrpos[kt].xaster*cdrpos[kt].xaster+cdrpos[kt].yaster*cdrpos[kt].yaster+cdrpos[kt].zaster*cdrpos[kt].zaster;
      r=sqrt(rr);
      dx=cdrpos[kt].xaster-cdrpos[kt].xearth;
      dy=cdrpos[kt].yaster-cdrpos[kt].yearth;
      dz=cdrpos[kt].zaster-cdrpos[kt].zearth;
      delta2=dx*dx+dy*dy+dz*dz;
      delta=sqrt(delta2);
      /* --- defines the center for the projection ---*/
      bc=0.;
      lc=0.;
      if (frame_center==0) {
         lc=atan2(cdrpos[kt].yaster,cdrpos[kt].xaster);
         bc=asin(cdrpos[kt].zaster/r);
      } else if (frame_center==1) {
         lc=atan2(cdrpos[kt].yaster-cdrpos[kt].yearth,cdrpos[kt].xaster-cdrpos[kt].xearth);
         bc=asin((cdrpos[kt].zaster-cdrpos[kt].zearth)/delta);
      }
      wcs.crval1=fmod(lc/(DR)+360.,360.)*(DR);
      wcs.crval2=bc;
      /* --- initialize the projected image ---*/
      if (image!=NULL) {
         for (k=0;k<wcs.naxis1*wcs.naxis2;k++) {image[k]=(float)0.;}
      }
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- F5 : take account for the rotation ---*/
         l1=htms[khtms].l1+dl;
         l2=htms[khtms].l2+dl;
         l3=htms[khtms].l3+dl;
         /* --- F3 : convert corners into cart. coord. in the frame of asteroid ---*/
         /*          take account for the gravity center ---*/
         cosb=cos(htms[khtms].b1);
         sinb=sin(htms[khtms].b1);
         coslcosb=cos(l1)*cosb;
         sinlcosb=sin(l1)*cosb;
         x1=htms[khtms].r1*coslcosb;
         y1=htms[khtms].r1*sinlcosb;
         z1=htms[khtms].r1*sinb;
         cosb=cos(htms[khtms].b2);
         sinb=sin(htms[khtms].b2);
         coslcosb=cos(l2)*cosb;
         sinlcosb=sin(l2)*cosb;
         x2=htms[khtms].r2*coslcosb;
         y2=htms[khtms].r2*sinlcosb;
         z2=htms[khtms].r2*sinb;
         cosb=cos(htms[khtms].b3);
         sinb=sin(htms[khtms].b3);
         coslcosb=cos(l3)*cosb;
         sinlcosb=sin(l3)*cosb;
         x3=htms[khtms].r3*coslcosb;
         y3=htms[khtms].r3*sinlcosb;
         z3=htms[khtms].r3*sinb;
         /* --- F4 : external normal vector to the triangular surface in the frame of asteroid ---*/
         px12=x2-x1;
         py12=y2-y1;
         pz12=z2-z1;
         px13=x3-x1;
         py13=y3-y1;
         pz13=z3-z1;
         px=(x1+x2+x3)/3.;
         py=(y1+y2+y3)/3.;
         pz=(z1+z2+z3)/3.;
         npx=(py12*pz13-py13*pz12);
         npy=-(px12*pz13-px13*pz12);
         npz=(px12*py13-px13*py12);
         np=sqrt(npx*npx+npy*npy+npz*npz);
         tr=0.5*np;
         nx=npx/np;
         ny=npy/np;
         nz=npz/np;
         q=px*nx+py*ny+pz*nz;
         if (q<0) {
            nx=-nx;
            ny=-ny;
            nz=-nz;
         }
         /* --- F7 : rotations to take account for the pole orientation / frame ---*/
         nsx=coslpcosi*nx-sinlp*ny-coslpsini*nz;
         nsy=sinlpcosi*nx+coslp*ny-sinlpsini*nz;
         nsz=sini*nx+cosi*nz;
         htms[khtms].x=coslpcosi*px-sinlp*py-coslpsini*pz;
         htms[khtms].y=sinlpcosi*px+coslp*py-sinlpsini*pz;
         htms[khtms].z=sini*px+cosi*pz;
         htms[khtms].x1=coslpcosi*x1-sinlp*y1-coslpsini*z1;
         htms[khtms].y1=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
         htms[khtms].z1=sini*x1+cosi*z1;
         htms[khtms].x2=coslpcosi*x2-sinlp*y2-coslpsini*z2;
         htms[khtms].y2=sinlpcosi*x2+coslp*y2-sinlpsini*z2;
         htms[khtms].z2=sini*x2+cosi*z2;
         htms[khtms].x3=coslpcosi*x3-sinlp*y3-coslpsini*z3;
         htms[khtms].y3=sinlpcosi*x3+coslp*y3-sinlpsini*z3;
         htms[khtms].z3=sini*x3+cosi*z3;
         /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the observer ---*/
         rsx=(htms[khtms].x)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         dist[khtms]=rs;
         kdist[khtms]=khtms;
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs=rs;
         htms[khtms].db=brs-bc;
         htms[khtms].dl=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x1)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y1)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z1)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs1=rs;
         htms[khtms].db1=brs-bc;
         htms[khtms].dl1=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x2)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y2)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z2)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs2=rs;
         htms[khtms].db2=brs-bc;
         htms[khtms].dl2=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x3)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y3)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z3)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs3=rs;
         htms[khtms].db3=brs-bc;
         htms[khtms].dl3=-(lrs-lc)*cos(bc);
         /* --- F8 : absorbed and reflected powers (W) ---*/
         cosths=(cdrpos[kt].xaster*nsx+cdrpos[kt].yaster*nsy+cdrpos[kt].zaster*nsz)/r;
         if (cosths<0) {
            pr=-e0/rr*tr*cosths*htms[khtms].albedo;
         } else {
            pr=0.;
         }
         /* --- F9 : eclairement recu sur terre ---*/
         costht=(dx*nsx+dy*nsy+dz*nsz)/delta;
         if (costht<0) {
            pe=-1./fourpi*pr*costht;
            e=pe/fourpi/delta2;
         } else {
            pe=0.;
            e=0.;
         }
         /* --- surface exposée vers la Terre (m2) ---*/
         if (costht<0) {
            trtot+=(-tr*costht);
         }
         /* --- contribution to the total E (Lambert) ---*/
         elamb=e;
         etotlamb+=elamb;
         /* --- contribution to the total E (Lommel-Seeliger) ---*/
         els=-e/(cosths+costht);
         etotls+=els;
         /* --- infos for plots ---*/
         htms[khtms].pr=pr/tr;
         htms[khtms].elamb=elamb/tr;
         htms[khtms].els=els/tr;
      }
      /* --- fill the projected image ---*/
      if (image!=NULL) {
         /* --- sort the distances observer-triangles ---*/
         mc_quicksort_double(dist,0,nhtms-1,kdist);
         /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
         for (khtms=nhtms-1;khtms>=0;khtms--) {
            if (frame_center==0) {
               e=htms[kdist[khtms]].pr;
            } else {
               e=htms[kdist[khtms]].els;
            }
            if (e==0.) { continue; }
            pixx[0]=htms[kdist[khtms]].dl1/wcs.cdelt1+wcs.crpix1;
            pixy[0]=htms[kdist[khtms]].db1/wcs.cdelt2+wcs.crpix2;
            pixx[1]=htms[kdist[khtms]].dl2/wcs.cdelt1+wcs.crpix1;
            pixy[1]=htms[kdist[khtms]].db2/wcs.cdelt2+wcs.crpix2;
            pixx[2]=htms[kdist[khtms]].dl3/wcs.cdelt1+wcs.crpix1;
            pixy[2]=htms[kdist[khtms]].db3/wcs.cdelt2+wcs.crpix2;
            /* --- sort as x1<x2<x3 ---*/
            for (k1=0;k1<2;k1++) {
               for (k2=k1+1;k2<3;k2++) {
                  if (pixx[k1]>pixx[k2]) {
                     x=pixx[k1];
                     pixx[k1]=pixx[k2];
                     pixx[k2]=x;
                     x=pixy[k1];
                     pixy[k1]=pixy[k2];
                     pixy[k2]=x;
                  }
               }
            }
            /* --- first half triangle (1-2) ---*/
            x1=floor(pixx[0]+.5);
            if (x1>=wcs.naxis1) { continue; }
            x2=floor(pixx[1]+.5);
            if (x2<0) { continue; }
            if (x1<0) { x1=0; }
            if (x2>=wcs.naxis1) { x2=wcs.naxis1-1; }
            for (k1=(int)x1;k1<=(int)x2;k1++) {
               if (pixx[1]==pixx[0]) { y2=pixy[1]; }
               else { 
                  frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
                  if (frac<0) {frac=0;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[0]+(pixy[1]-pixy[0])*frac;
               }
               if (pixx[2]==pixx[0]) { y3=pixy[2]; }
               else { 
                  frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[0]+(pixy[2]-pixy[0])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs.naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs.naxis2) { y3=wcs.naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs.naxis1+k1]=(float)e;
               }
            }            
            /* --- second half triangle (2-3) ---*/
            x2=floor(pixx[1]+.5);
            if (x2>=wcs.naxis1) { continue; }
            x3=floor(pixx[2]+.5);
            if (x3<0) { continue; }
            if (x2<0) { x2=0; }
            if (x3>=wcs.naxis1) { x3=wcs.naxis1-1; }
            for (k1=(int)x2;k1<=(int)x3;k1++) {
               if (pixx[0]==pixx[2]) { y2=pixy[0]; }
               else { 
                  frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[2]+(pixy[0]-pixy[2])*frac;
               }
               if (pixx[1]==pixx[2]) { y3=pixy[1]; }
               else { 
                  frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[2]+(pixy[1]-pixy[2])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs.naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs.naxis2) { y3=wcs.naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs.naxis1+k1]=(float)e;
               }
            }            
         }
         sprintf(filename,"%s%d.fit",genefilename,kt+1);
         mc_savefits(image,wcs.naxis1,wcs.naxis2,filename,&wcs);
      }
      /* --- cas when the object in the shadow of the Earth ---*/
      etotlamb*=cdrpos[kt].eclipsed;
      etotls*=cdrpos[kt].eclipsed;
      /* --- mag1 take account for a pure Lambert law ---*/
      if (etotlamb==0) {
         cdrpos[kt].mag1=99.99;
      } else {
         cdrpos[kt].mag1=32.2800-2.5*log10(etotlamb);
      }
      /* --- mag2 take account for a pure Lommel-Seeliger law ---*/
      if (etotls==0) {
         cdrpos[kt].mag2=99.99;
      } else {
         cdrpos[kt].mag2=31.9665-2.5*log10(etotls);
      }
      /**/
      if (kt==0) {
         trtotmin=trtot;
         trtotmax=trtot;
      } else {
         if (trtot>trtotmax) { trtotmax=trtot; }
         if (trtot<trtotmin) { trtotmin=trtot; }
      }
   }
   free(htms);
   if (image!=NULL) {free(image);}
   free(dist);
   free(kdist);
}

void mc_simulc_sat_stl(mc_cdr cdr,struct_point *point1,struct_point *point2,struct_point *point3,struct_point *point4,int n_in,double albedo,mc_cdrpos *cdrpos,int n,char *genefilename)
/***************************************************************************/
/* simulation de la courbe de lumiere d'un satellite                       */
/***************************************************************************/
/***************************************************************************/
{
   int k,kt,nrug;
   double l1,l2,l3;
   double cosb,sinb,coslcosb,sinlcosb;
   double dl;
   double x1,x2,x3,y1,y2,y3,z1,z2,z3;
   double px12,py12,pz12,px13,py13,pz13;
   double px,py,pz;
   double npx,npy,npz,nx,ny,nz;
   double np,tr,q;
   double coslp,sinlp,coslpcosi,sinlpcosi,coslpsini,sinlpsini,sini,cosi;
   double r,rr,delta,delta2,dx,dy,dz;
   double nsx,nsy,nsz;  
   double e0,pr,i,cosths,costht,e,etotlamb,etotls,etotmin, etotphong, ephong, emin, pe,cosalpha;
   double fourpi;
   double trtot=0.;
   double trtotmin,trtotmax;
   int khtms,nhtms;
   mc_htm *htms;
   double pmaxi,rmini;
   double rsx,rsy,rsz,lrs,brs,lc,bc,rs;
   double field;
   int k1,k2;
   float *image=NULL;
   double elamb,els;
   mc_wcs wcs;
   char filename[1024];
   double *dist=NULL;
   int *kdist=NULL;
   double pixx[3],pixy[3],x,y,z,frac;
   double volume,volumetot,masstot,xg,yg,zg;

   //int level;
   double l0,date0,period,lp,bp, ks, ksp;
   int frame_center; /* =0 sun =1 earth */

   date0=cdr.jd_phase0;
   //level=cdr.htmlevel;
   l0=cdr.lon_phase0;
   period=cdr.period;
   lp=cdr.lonpole;
   bp=cdr.latpole;
   frame_center=cdr.frame_center;

   l0=l0*(DR);
   lp=lp*(DR);
   bp=bp*(DR);
   /* - F6 -*/
   i=bp-(PI)/2;
   cosi=cos(i);
   sini=sin(i);
   coslp=cos(lp);
   sinlp=sin(lp);
   coslpcosi=coslp*cosi;
   sinlpcosi=sinlp*cosi;
   coslpsini=coslp*sini;
   sinlpsini=sinlp*sini;
  
   e0=1400.; /* W/m2 at 1 A.U. */
   fourpi=4.*(PI);

   /* --- total number of triangles ---*/
   nhtms=n_in;
   htms=(mc_htm*)calloc(nhtms,sizeof(mc_htm));
   if (htms==NULL) {
      return;
   }
   dist=(double*)calloc(nhtms,sizeof(double));
   if (dist==NULL) {
      free(htms);
      return;
   }
   kdist=(int*)calloc(nhtms,sizeof(int));
   if (kdist==NULL) {
      free(htms);
      free(dist);
      return;
   }
   khtms=0;
   volumetot=0;
   masstot=0;
   x=y=z=0.;
   xg=yg=zg=0.;
   /* --- fill the HTM structure by the corner coordinates ---*/
   // /10 pour avoir des metres!
   for (khtms=0;khtms<nhtms;khtms++) {
	  x1=htms[khtms].x1=point1[khtms].x/10;
      y1=htms[khtms].y1=point1[khtms].y/10;
      z1=htms[khtms].z1=point1[khtms].z/10;
      x2=htms[khtms].x2=point2[khtms].x/10;
      y2=htms[khtms].y2=point2[khtms].y/10;
      z2=htms[khtms].z2=point2[khtms].z/10;
	  x3=htms[khtms].x3=point3[khtms].x/10;
      y3=htms[khtms].y3=point3[khtms].y/10;
      z3=htms[khtms].z3=point3[khtms].z/10;
    
      /* --- center of gravity of the tetraedron --- */
      volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
      htms[khtms].volume=volume;
      htms[khtms].density=cdr.density;
      htms[khtms].mass=volume*htms[khtms].density;
      htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
      htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
      htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
      /* --- add to determine the center of gravity of the body --- */
      x+=(htms[khtms].xg*htms[khtms].mass);
      y+=(htms[khtms].yg*htms[khtms].mass);
      z+=(htms[khtms].zg*htms[khtms].mass);
      masstot+=htms[khtms].mass;
      volumetot+=volume;
   }
   /* --- center of gravity (m) --- */
   xg=x/masstot;
   yg=y/masstot;
   zg=z/masstot;

   /* --- iterating corrections due to the offcentering of the center of gravity --- */
   for (kt=0;kt<4;kt++) {
      x=y=z=0.;
      volumetot=0;
      masstot=0;
      for (khtms=0;khtms<nhtms;khtms++) {
         htms[khtms].x1-=xg;
         htms[khtms].y1-=yg;
         htms[khtms].z1-=zg;
         x1=htms[khtms].x1;
         y1=htms[khtms].y1;
         z1=htms[khtms].z1;
         htms[khtms].r1=sqrt(x1*x1+y1*y1+z1*z1);
         htms[khtms].l1=atan2(htms[khtms].y1,htms[khtms].x1);
         htms[khtms].b1=asin(htms[khtms].z1/htms[khtms].r1);
         htms[khtms].x2-=xg;
         htms[khtms].y2-=yg;
         htms[khtms].z2-=zg;
         x2=htms[khtms].x2;
         y2=htms[khtms].y2;
         z2=htms[khtms].z2;
         htms[khtms].r2=sqrt(x2*x2+y2*y2+z2*z2);
         htms[khtms].l2=atan2(htms[khtms].y2,htms[khtms].x2);
         htms[khtms].b2=asin(htms[khtms].z2/htms[khtms].r2);
         htms[khtms].x3-=xg;
         htms[khtms].y3-=yg;
         htms[khtms].z3-=zg;
         x3=htms[khtms].x3;
         y3=htms[khtms].y3;
         z3=htms[khtms].z3;
         htms[khtms].r3=sqrt(x3*x3+y3*y3+z3*z3);
         htms[khtms].l3=atan2(htms[khtms].y3,htms[khtms].x3);
         htms[khtms].b3=asin(htms[khtms].z3/htms[khtms].r3);
         /* --- center of gravity of the tetraedron --- */
         volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
         htms[khtms].volume=volume;
         htms[khtms].density=cdr.density;
         htms[khtms].mass=volume*htms[khtms].density;
         htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
         htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
         htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
         /* --- add to determine the center of gravity of the body --- */
         x+=(htms[khtms].xg*htms[khtms].mass);
         y+=(htms[khtms].yg*htms[khtms].mass);
         z+=(htms[khtms].zg*htms[khtms].mass);
         masstot+=htms[khtms].mass;
         volumetot+=volume;
      }
      /* --- center of gravity should converge to (0,0,0) --- */
      xg=x/masstot;
      yg=y/masstot;
      zg=z/masstot;
   }
   /* --- searching for the largest altitude from the gravity center ---*/
   pmaxi=0.;
   for (khtms=0;khtms<nhtms;khtms++) {
      if (htms[khtms].r1>pmaxi) {pmaxi=htms[khtms].r1;}
      if (htms[khtms].r2>pmaxi) {pmaxi=htms[khtms].r2;}
      if (htms[khtms].r3>pmaxi) {pmaxi=htms[khtms].r3;}
   }
   /* --- allocate an image matrix ---*/
   /* --- the image is centered on the gravity center: cdrpos[].?aster ---*/
   rmini=1e21;
   for (kt=0;kt<n;kt++) {
      dx=cdrpos[kt].xaster;
      dy=cdrpos[kt].yaster;
      dz=cdrpos[kt].zaster;
      if (frame_center==1) {
         dx-=cdrpos[kt].xearth;
         dy-=cdrpos[kt].yearth;
         dz-=cdrpos[kt].zearth;
      }
      rr=dx*dx+dy*dy+dz*dz;
      rr+=(xg*xg+yg*yg+zg*zg)/(UA)/(UA);
      r=sqrt(rr);
      if (r<rmini) {rmini=r;}
   }
   wcs.naxis1=200;
   wcs.naxis2=200;
   field=atan(2*pmaxi/(UA)/rmini)*1.5;
   wcs.cdelt1=field/wcs.naxis1;
   wcs.cdelt2=field/wcs.naxis2;
   wcs.crpix1=wcs.naxis1/2+.5;
   wcs.crpix2=wcs.naxis2/2+.5;
   wcs.crota2=0.;
   if (genefilename!=NULL) {
      image=(float*)calloc(wcs.naxis1*wcs.naxis2,sizeof(float));
      if (image==NULL) {
         /* --- TBD error */
         free(htms);
         free(dist);
         free(kdist);
      }
   }
   /* --- loop over the phase dates ---*/
   for (kt=0;kt<n;kt++) {
      etotlamb=etotls=etotmin=etotphong=0.;
      dl=fmod(l0/(DR)+360.*(cdrpos[kt].jd-date0)/period,360.)*(DR);
      trtot=0.;
      /* --- distances from the gravity center ---*/
      rr=cdrpos[kt].xaster*cdrpos[kt].xaster+cdrpos[kt].yaster*cdrpos[kt].yaster+cdrpos[kt].zaster*cdrpos[kt].zaster;
      r=sqrt(rr);
      dx=cdrpos[kt].xaster-cdrpos[kt].xearth;
      dy=cdrpos[kt].yaster-cdrpos[kt].yearth;
      dz=cdrpos[kt].zaster-cdrpos[kt].zearth;
      delta2=dx*dx+dy*dy+dz*dz;
      delta=sqrt(delta2);
      /* --- defines the center for the projection ---*/
      bc=0.;
      lc=0.;
      if (frame_center==0) {
         lc=atan2(cdrpos[kt].yaster,cdrpos[kt].xaster);
         bc=asin(cdrpos[kt].zaster/r);
      } else if (frame_center==1) {
         lc=atan2(cdrpos[kt].yaster-cdrpos[kt].yearth,cdrpos[kt].xaster-cdrpos[kt].xearth);
         bc=asin((cdrpos[kt].zaster-cdrpos[kt].zearth)/delta);
      }
      wcs.crval1=fmod(lc/(DR)+360.,360.)*(DR);
      wcs.crval2=bc;
      /* --- initialize the projected image ---*/
      if (image!=NULL) {
         for (k=0;k<wcs.naxis1*wcs.naxis2;k++) {image[k]=(float)0.;}
      }
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- F5 : take account for the rotation ---*/
         l1=htms[khtms].l1+dl;
         l2=htms[khtms].l2+dl;
         l3=htms[khtms].l3+dl;
         /* --- F3 : convert corners into cart. coord. in the frame of asteroid ---*/
         /*          take account for the gravity center ---*/
         cosb=cos(htms[khtms].b1);
         sinb=sin(htms[khtms].b1);
         coslcosb=cos(l1)*cosb;
         sinlcosb=sin(l1)*cosb;
         x1=htms[khtms].r1*coslcosb;
         y1=htms[khtms].r1*sinlcosb;
         z1=htms[khtms].r1*sinb;
         cosb=cos(htms[khtms].b2);
         sinb=sin(htms[khtms].b2);
         coslcosb=cos(l2)*cosb;
         sinlcosb=sin(l2)*cosb;
         x2=htms[khtms].r2*coslcosb;
         y2=htms[khtms].r2*sinlcosb;
         z2=htms[khtms].r2*sinb;
         cosb=cos(htms[khtms].b3);
         sinb=sin(htms[khtms].b3);
         coslcosb=cos(l3)*cosb;
         sinlcosb=sin(l3)*cosb;
         x3=htms[khtms].r3*coslcosb;
         y3=htms[khtms].r3*sinlcosb;
         z3=htms[khtms].r3*sinb;
         /* --- F4 : external normal vector to the triangular surface in the frame of asteroid ---*/
         px12=x2-x1;
         py12=y2-y1;
         pz12=z2-z1;
         px13=x3-x1;
         py13=y3-y1;
         pz13=z3-z1;
         px=(x1+x2+x3)/3.;
         py=(y1+y2+y3)/3.;
         pz=(z1+z2+z3)/3.;
         npx=(py12*pz13-py13*pz12);
         npy=-(px12*pz13-px13*pz12);
         npz=(px12*py13-px13*py12);
         np=sqrt(npx*npx+npy*npy+npz*npz);
         tr=0.5*np;
         nx=npx/np;
         ny=npy/np;
         nz=npz/np;
         q=px*nx+py*ny+pz*nz;
         if (q<0) {
            nx=-nx;
            ny=-ny;
            nz=-nz;
         }
         /* --- F7 : rotations to take account for the pole orientation / frame ---*/
         nsx=coslpcosi*nx-sinlp*ny-coslpsini*nz;
         nsy=sinlpcosi*nx+coslp*ny-sinlpsini*nz;
         nsz=sini*nx+cosi*nz;
         htms[khtms].x=coslpcosi*px-sinlp*py-coslpsini*pz;
         htms[khtms].y=sinlpcosi*px+coslp*py-sinlpsini*pz;
         htms[khtms].z=sini*px+cosi*pz;
         htms[khtms].x1=coslpcosi*x1-sinlp*y1-coslpsini*z1;
         htms[khtms].y1=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
         htms[khtms].z1=sini*x1+cosi*z1;
         htms[khtms].x2=coslpcosi*x2-sinlp*y2-coslpsini*z2;
         htms[khtms].y2=sinlpcosi*x2+coslp*y2-sinlpsini*z2;
         htms[khtms].z2=sini*x2+cosi*z2;
         htms[khtms].x3=coslpcosi*x3-sinlp*y3-coslpsini*z3;
         htms[khtms].y3=sinlpcosi*x3+coslp*y3-sinlpsini*z3;
         htms[khtms].z3=sini*x3+cosi*z3;
         /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the observer ---*/
         rsx=(htms[khtms].x)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         dist[khtms]=rs;
         kdist[khtms]=khtms;
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs=rs;
         htms[khtms].db=brs-bc;
         htms[khtms].dl=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x1)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y1)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z1)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs1=rs;
         htms[khtms].db1=brs-bc;
         htms[khtms].dl1=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x2)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y2)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z2)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs2=rs;
         htms[khtms].db2=brs-bc;
         htms[khtms].dl2=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x3)/(UA)+cdrpos[kt].xaster;
         rsy=(htms[khtms].y3)/(UA)+cdrpos[kt].yaster;
         rsz=(htms[khtms].z3)/(UA)+cdrpos[kt].zaster;
         if (frame_center==1) {
            rsx-=cdrpos[kt].xearth;
            rsy-=cdrpos[kt].yearth;
            rsz-=cdrpos[kt].zearth;
         }
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs3=rs;
         htms[khtms].db3=brs-bc;
         htms[khtms].dl3=-(lrs-lc)*cos(bc);
         /* --- F8 : absorbed and reflected powers (W) ---*/
         cosths=(cdrpos[kt].xaster*nsx+cdrpos[kt].yaster*nsy+cdrpos[kt].zaster*nsz)/r;
         if (cosths<0) {
            pr=-e0/rr*tr*cosths*albedo;
         } else {
            pr=0.;
         }
         /* --- F9 : eclairement recu sur terre ---*/
         costht=(dx*nsx+dy*nsy+dz*nsz)/delta;
         if (costht<0) {
            pe=-1./fourpi*pr*costht;
            e=pe/fourpi/delta2;
         } else {
            pe=0.;
            e=0.;
         }
		 cosalpha=(cdrpos[kt].xaster*dx+cdrpos[kt].yaster*dy+cdrpos[kt].zaster*dz)/(delta*r);
         /* --- surface exposée vers la Terre (m2) ---*/
         if (costht<0) {
            trtot+=(-tr*costht);
         }
         /* --- contribution to the total E (Lambert) ---*/
         elamb=e;
         etotlamb+=elamb;
         /* --- contribution to the total E (Lommel-Seeliger) ---*/
         els=-e/(cosths+costht);
         etotls+=els;
		  /* --- contribution to the total E (Minnaert) ---*/	 
         emin=-e*(pow(cosths,6))*(pow(costht,5));
         etotmin+=emin;
		  /* --- contribution to the total E (Phong) ---*/
		 ks=500;
		 nrug=150;
		 ksp=ks/(albedo);
		 ephong=e*(1+ksp*pow(cosalpha,nrug));
         etotphong+=ephong;
         /* --- infos for plots ---*/
         htms[khtms].pr=pr/tr;
         htms[khtms].elamb=elamb/tr;
         htms[khtms].els=els/tr;
		 htms[khtms].emin=emin/tr;
         htms[khtms].ephong=ephong/tr;
      }
      /* --- fill the projected image ---*/
      if (image!=NULL) {
         /* --- sort the distances observer-triangles ---*/
         mc_quicksort_double(dist,0,nhtms-1,kdist);
         /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
         for (khtms=nhtms-1;khtms>=0;khtms--) {
            if (frame_center==0) {
               e=htms[kdist[khtms]].pr;
            } else {
               e=htms[kdist[khtms]].els;
            }
            if (e==0.) { continue; }
            pixx[0]=htms[kdist[khtms]].dl1/wcs.cdelt1+wcs.crpix1;
            pixy[0]=htms[kdist[khtms]].db1/wcs.cdelt2+wcs.crpix2;
            pixx[1]=htms[kdist[khtms]].dl2/wcs.cdelt1+wcs.crpix1;
            pixy[1]=htms[kdist[khtms]].db2/wcs.cdelt2+wcs.crpix2;
            pixx[2]=htms[kdist[khtms]].dl3/wcs.cdelt1+wcs.crpix1;
            pixy[2]=htms[kdist[khtms]].db3/wcs.cdelt2+wcs.crpix2;
            /* --- sort as x1<x2<x3 ---*/
            for (k1=0;k1<2;k1++) {
               for (k2=k1+1;k2<3;k2++) {
                  if (pixx[k1]>pixx[k2]) {
                     x=pixx[k1];
                     pixx[k1]=pixx[k2];
                     pixx[k2]=x;
                     x=pixy[k1];
                     pixy[k1]=pixy[k2];
                     pixy[k2]=x;
                  }
               }
            }
            /* --- first half triangle (1-2) ---*/
            x1=floor(pixx[0]+.5);
            if (x1>=wcs.naxis1) { continue; }
            x2=floor(pixx[1]+.5);
            if (x2<0) { continue; }
            if (x1<0) { x1=0; }
            if (x2>=wcs.naxis1) { x2=wcs.naxis1-1; }
            for (k1=(int)x1;k1<=(int)x2;k1++) {
               if (pixx[1]==pixx[0]) { y2=pixy[1]; }
               else { 
                  frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
                  if (frac<0) {frac=0;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[0]+(pixy[1]-pixy[0])*frac;
               }
               if (pixx[2]==pixx[0]) { y3=pixy[2]; }
               else { 
                  frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[0]+(pixy[2]-pixy[0])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs.naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs.naxis2) { y3=wcs.naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs.naxis1+k1]=(float)e;
               }
            }            
            /* --- second half triangle (2-3) ---*/
            x2=floor(pixx[1]+.5);
            if (x2>=wcs.naxis1) { continue; }
            x3=floor(pixx[2]+.5);
            if (x3<0) { continue; }
            if (x2<0) { x2=0; }
            if (x3>=wcs.naxis1) { x3=wcs.naxis1-1; }
            for (k1=(int)x2;k1<=(int)x3;k1++) {
               if (pixx[0]==pixx[2]) { y2=pixy[0]; }
               else { 
                  frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[2]+(pixy[0]-pixy[2])*frac;
               }
               if (pixx[1]==pixx[2]) { y3=pixy[1]; }
               else { 
                  frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[2]+(pixy[1]-pixy[2])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs.naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs.naxis2) { y3=wcs.naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs.naxis1+k1]=(float)e;
               }
            }            
         }
         sprintf(filename,"%s%d.fit",genefilename,kt+1);
         mc_savefits(image,wcs.naxis1,wcs.naxis2,filename,&wcs);
      }
      /* --- cas when the object in the shadow of the Earth ---*/
      etotlamb*=cdrpos[kt].eclipsed;
      etotls*=cdrpos[kt].eclipsed;
	  etotmin*=cdrpos[kt].eclipsed;
	  etotphong*=cdrpos[kt].eclipsed;
      /* --- mag1 take account for a pure Lambert law ---*/
      if (etotlamb==0) {
         cdrpos[kt].mag1=99.99;
      } else {
         cdrpos[kt].mag1=32.2800-2.5*log10(etotlamb);
      }
      /* --- mag2 take account for a pure Lommel-Seeliger law ---*/
      if (etotls==0) {
         cdrpos[kt].mag2=99.99;
      } else {
         cdrpos[kt].mag2=31.9665-2.5*log10(etotls);
      }
	  /* --- mag3 take account for a pure Minnaert law ---*/
      if (etotmin==0) {
         cdrpos[kt].mag3=99.99;
      } else {
         cdrpos[kt].mag3=32-2.5*log10(etotmin);
      }
	  /* --- mag3 take account for a pure Phong law ---*/
      if (etotphong==0) {
         cdrpos[kt].mag4=99.99;
      } else {
         cdrpos[kt].mag4=32-2.5*log10(etotphong);
      }
      /**/
      if (kt==0) {
         trtotmin=trtot;
         trtotmax=trtot;
      } else {
         if (trtot>trtotmax) { trtotmax=trtot; }
         if (trtot<trtotmin) { trtotmin=trtot; }
      }
   }
   free(htms);
   if (image!=NULL) {free(image);}
   free(dist);
   free(kdist);

}
void mc_simulcbin(mc_cdr cdr,double *relief1,double *albedo1,double *relief2,double *albedo2,mc_cdrpos *cdrpos,int n,char *genefilename)
/***************************************************************************/
/* simulation de la courbe de lumiere d'un asteroide SSB                   */
/***************************************************************************/
/***************************************************************************/
{
   int nhtm,exp,khtm0,khemis,khtm,k,kt;
   char *htm;
   double lll,bbb,l1,b1,l2,b2,l3,b3;
   double cosb,sinb,coslcosb,sinlcosb;
   double dl;
   double x1,x2,x3,y1,y2,y3,z1,z2,z3;
   double px12,py12,pz12,px13,py13,pz13;
   double px,py,pz;
   double npx,npy,npz,nx,ny,nz;
   double np,tr,q;
   double coslp,sinlp,coslpcosi,sinlpcosi,coslpsini,sinlpsini,sini,cosi;
   double r,rr,delta,delta2,dx,dy,dz;
   double nsx,nsy,nsz;
   double e0,pr,i,cosths,costht,e,etotlamb,etotls,pe;
   double fourpi;
   double trtot=0.;
   /*double trtotmin,trtotmax;*/
   int khtms,nhtms;
   mc_htm *htms,*htm1s,*htm2s;
   double pmaxi=0.,rmini;
   double rsx,rsy,rsz,lrs,brs,lc,bc,rs;
   double field;
   int k1,k2;
   float *image=NULL,*imagebin=NULL,*imagesun=NULL,*imageearth=NULL;
   double elamb,els;
   mc_wcs *wcs,wcsbin,wcssun,wcsearth;
   char filename[1024];
   double *dist=NULL,*dist1=NULL,*dist2=NULL;
   int *kdist=NULL,*kdist1=NULL,*kdist2=NULL;
   double pixx[3],pixy[3],x,y,z,frac;
   double albedomean;
   double volume,volumetot,masstot,masstot1,masstot2,xg,yg,zg;
   mc_cdrpos *cdrpos1,*cdrpos2,*cdrpos12;
   double pmaxibin,rr1,rr2;
   int *kfarsun,*kfarearth; /* index of the asteroid farest from the sun & earth respectively */
   double a1,a2;

   int nlon,nlat,klon,klat;
   double lon,lat;
   int level;
   double l0,date0,period,lp,bp;
   int frame_center; /* =0 sun =1 earth */
   date0=cdr.jd_phase0;
   level=cdr.htmlevel;
   l0=cdr.lon_phase0;
   period=cdr.period;
   lp=cdr.lonpole;
   bp=cdr.latpole;
   frame_center=cdr.frame_center;

   htm=(char*)calloc(level+3,sizeof(char));
   l0=l0*(DR);
   lp=lp*(DR);
   bp=bp*(DR);
   /* - F6 -*/
   i=bp-(PI)/2;
   cosi=cos(i);
   sini=sin(i);
   coslp=cos(lp);
   sinlp=sin(lp);
   coslpcosi=coslp*cosi;
   sinlpcosi=sinlp*cosi;
   coslpsini=coslp*sini;
   sinlpsini=sinlp*sini;

   /******************************************************************************/
   /******************************************************************************/
   /**** Compute the HTM shape of each object relative to the center of masse ****/
   /******************************************************************************/
   /******************************************************************************/
   e0=1400.; /* W/m2 at 1 A.U. */
   fourpi=4.*(PI);
   /* --- total number of triangles in each hemsiphere ---*/
   nhtm=(int)(8*pow(4,level))/2;
   /* --- total number of triangles ---*/
   nhtms=2*nhtm;
   /* --- fill the HTM structure by the corner coordinates ---*/
   if (level>5) { level=5; }
   if (level<0) { level=0; }
   htm1s=(mc_htm*)calloc(nhtms,sizeof(mc_htm));
   if (htm1s==NULL) {
      /* --- TBD error */
      return;
   }
   htm2s=(mc_htm*)calloc(nhtms,sizeof(mc_htm));
   if (htm2s==NULL) {
      free(htm1s);
      /* --- TBD error */
      return;
   }
   dist1=(double*)calloc(nhtms,sizeof(double));
   if (dist1==NULL) {
      free(htm1s);
      free(htm2s);
      /* --- TBD error */
      return;
   }
   dist2=(double*)calloc(nhtms,sizeof(double));
   if (dist2==NULL) {
      free(htm1s);
      free(htm2s);
      free(dist1);
      /* --- TBD error */
      return;
   }
   kdist1=(int*)calloc(nhtms,sizeof(int));
   if (kdist1==NULL) {
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      /* --- TBD error */
      return;
   }
   kdist2=(int*)calloc(nhtms,sizeof(int));
   if (kdist2==NULL) {
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      free(kdist1);
      /* --- TBD error */
      return;
   }
   /* --- computation for the object 1 ---*/
   htms=htm1s;
   khtms=0;
   for (khemis=0;khemis<=1;khemis++) {
      for (khtm=0;khtm<nhtm;khtm++) {
         /* --- build the HTM code ---*/
         if (khemis==0) { htm[0]='S'; } else { htm[0]='N'; }
         exp=(int)pow(4,level);
         khtm0=khtm;
         for (k=0;k<=level;k++) {
            htm[k+1]=khtm0/exp;
            khtm0-=(htm[k+1]*exp);
            htm[k+1]+=48;
            exp/=4;
         }
         htm[k+1]='\0';
         /* --- F1 : compute the corner coordinates ---*/
         mc_htm2radec(htm,&lll,&bbb,&level,&l1,&b1,&l2,&b2,&l3,&b3);
         /* --- fill the structure ---*/
         strcpy(htms[khtms].index,htm);
         htms[khtms].l=lll;
         htms[khtms].b=bbb;
         htms[khtms].l1=l1;
         htms[khtms].b1=b1;
         htms[khtms].l2=l2;
         htms[khtms].b2=b2;
         htms[khtms].l3=l3;
         htms[khtms].b3=b3;
         khtms++;
      }
   }
   /* --- fill the HTM structure by the relief and albedo maps ---*/
   nlon=360;
   nlat=181;
   volumetot=0;
   masstot=0;
   x=y=z=0.;
   xg=yg=zg=0.;
   for (khtms=0;khtms<nhtms;khtms++) {
      /* --- F2 : compute the distance of surface to center for corners (m) ---*/
      albedomean=0.;
      lon=htms[khtms].l1;
      lat=htms[khtms].b1;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r1=relief1[klon*nlat+klat];
      albedomean+=albedo1[klon*nlat+klat];
      lon=htms[khtms].l2;
      lat=htms[khtms].b2;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r2=relief1[klon*nlat+klat];
      albedomean+=albedo1[klon*nlat+klat];
      lon=htms[khtms].l3;
      lat=htms[khtms].b3;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r3=relief1[klon*nlat+klat];
      albedomean+=albedo1[klon*nlat+klat];
      htms[khtms].albedo=albedomean/3.;
      /* --- compute the volume of the tetraedron ---*/
      lon=htms[khtms].l1;
      lat=htms[khtms].b1;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x1=htms[khtms].x1=htms[khtms].r1*coslcosb;
      y1=htms[khtms].y1=htms[khtms].r1*sinlcosb;
      z1=htms[khtms].z1=htms[khtms].r1*sinb;
      lon=htms[khtms].l2;
      lat=htms[khtms].b2;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x2=htms[khtms].x2=htms[khtms].r2*coslcosb;
      y2=htms[khtms].y2=htms[khtms].r2*sinlcosb;
      z2=htms[khtms].z2=htms[khtms].r2*sinb;
      lon=htms[khtms].l3;
      lat=htms[khtms].b3;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x3=htms[khtms].x3=htms[khtms].r3*coslcosb;
      y3=htms[khtms].y3=htms[khtms].r3*sinlcosb;
      z3=htms[khtms].z3=htms[khtms].r3*sinb;
      /* --- center of gravity of the tetraedron --- */
      volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
      htms[khtms].volume=volume;
      htms[khtms].density=cdr.density;
      htms[khtms].mass=volume*htms[khtms].density;
      htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
      htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
      htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
      /* --- add to determine the center of gravity of the body --- */
      x+=(htms[khtms].xg*htms[khtms].mass);
      y+=(htms[khtms].yg*htms[khtms].mass);
      z+=(htms[khtms].zg*htms[khtms].mass);
      masstot+=htms[khtms].mass;
      volumetot+=volume;
   }
   /* --- center of gravity (m) --- */
   xg=x/masstot;
   yg=y/masstot;
   zg=z/masstot;
   /* --- iterating corrections due to the offcentering of the center of gravity --- */
   for (kt=0;kt<4;kt++) {
      x=y=z=0.;
      volumetot=0;
      masstot=0;
      for (khtms=0;khtms<nhtms;khtms++) {
         htms[khtms].x1-=xg;
         htms[khtms].y1-=yg;
         htms[khtms].z1-=zg;
         x1=htms[khtms].x1;
         y1=htms[khtms].y1;
         z1=htms[khtms].z1;
         htms[khtms].r1=sqrt(x1*x1+y1*y1+z1*z1);
         htms[khtms].l1=atan2(htms[khtms].y1,htms[khtms].x1);
         htms[khtms].b1=asin(htms[khtms].z1/htms[khtms].r1);
         htms[khtms].x2-=xg;
         htms[khtms].y2-=yg;
         htms[khtms].z2-=zg;
         x2=htms[khtms].x2;
         y2=htms[khtms].y2;
         z2=htms[khtms].z2;
         htms[khtms].r2=sqrt(x2*x2+y2*y2+z2*z2);
         htms[khtms].l2=atan2(htms[khtms].y2,htms[khtms].x2);
         htms[khtms].b2=asin(htms[khtms].z2/htms[khtms].r2);
         htms[khtms].x3-=xg;
         htms[khtms].y3-=yg;
         htms[khtms].z3-=zg;
         x3=htms[khtms].x3;
         y3=htms[khtms].y3;
         z3=htms[khtms].z3;
         htms[khtms].r3=sqrt(x3*x3+y3*y3+z3*z3);
         htms[khtms].l3=atan2(htms[khtms].y3,htms[khtms].x3);
         htms[khtms].b3=asin(htms[khtms].z3/htms[khtms].r3);
         /* --- center of gravity of the tetraedron --- */
         volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
         htms[khtms].volume=volume;
         htms[khtms].density=cdr.density;
         htms[khtms].mass=volume*htms[khtms].density;
         htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
         htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
         htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
         /* --- add to determine the center of gravity of the body --- */
         x+=(htms[khtms].xg*htms[khtms].mass);
         y+=(htms[khtms].yg*htms[khtms].mass);
         z+=(htms[khtms].zg*htms[khtms].mass);
         masstot+=htms[khtms].mass;
         volumetot+=volume;
         /*htm2s[khtms]=htms[khtms];*/
      }
      /* --- center of gravity should converge to (0,0,0) --- */
      xg=x/masstot;
      yg=y/masstot;
      zg=z/masstot;
   }
   /* --- searching for the largest altitude from the gravity center ---*/
   for (khtms=0;khtms<nhtms;khtms++) {
      if (htms[khtms].r1>pmaxi) {pmaxi=htms[khtms].r1;}
      if (htms[khtms].r2>pmaxi) {pmaxi=htms[khtms].r2;}
      if (htms[khtms].r3>pmaxi) {pmaxi=htms[khtms].r3;}
   }
   masstot1=masstot;
   /* --- computation for the object 2 ---*/
   htms=htm2s;
   khtms=0;
   for (khemis=0;khemis<=1;khemis++) {
      for (khtm=0;khtm<nhtm;khtm++) {
         /* --- build the HTM code ---*/
         if (khemis==0) { htm[0]='S'; } else { htm[0]='N'; }
         exp=(int)pow(4,level);
         khtm0=khtm;
         for (k=0;k<=level;k++) {
            htm[k+1]=khtm0/exp;
            khtm0-=(htm[k+1]*exp);
            htm[k+1]+=48;
            exp/=4;
         }
         htm[k+1]='\0';
         /* --- F1 : compute the corner coordinates ---*/
         mc_htm2radec(htm,&lll,&bbb,&level,&l1,&b1,&l2,&b2,&l3,&b3);
         /* --- fill the structure ---*/
         strcpy(htms[khtms].index,htm);
         htms[khtms].l=lll;
         htms[khtms].b=bbb;
         htms[khtms].l1=l1;
         htms[khtms].b1=b1;
         htms[khtms].l2=l2;
         htms[khtms].b2=b2;
         htms[khtms].l3=l3;
         htms[khtms].b3=b3;
         khtms++;
      }
   }
   free(htm);
   /* --- fill the HTM structure by the relief and albedo maps ---*/
   nlon=360;
   nlat=181;
   volumetot=0;
   masstot=0;
   x=y=z=0.;
   xg=yg=zg=0.;
   for (khtms=0;khtms<nhtms;khtms++) {
      /* --- F2 : compute the distance of surface to center for corners (m) ---*/
      albedomean=0.;
      lon=htms[khtms].l1;
      lat=htms[khtms].b1;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r1=relief2[klon*nlat+klat];
      albedomean+=albedo2[klon*nlat+klat];
      lon=htms[khtms].l2;
      lat=htms[khtms].b2;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r2=relief2[klon*nlat+klat];
      albedomean+=albedo2[klon*nlat+klat];
      lon=htms[khtms].l3;
      lat=htms[khtms].b3;
      klon=(int)(lon/(DR)/1.);
      if (klon<0) {klon=0;}
      if (klon>nlon) {klon=nlon-1;}
      klat=(int)(((lat+(PI)/2)/(DR))/1.);
      if (klat<0) {klat=0;}
      htms[khtms].r3=relief2[klon*nlat+klat];
      albedomean+=albedo2[klon*nlat+klat];
      htms[khtms].albedo=albedomean/3.;
      /* --- compute the volume of the tetraedron ---*/
      lon=htms[khtms].l1;
      lat=htms[khtms].b1;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x1=htms[khtms].x1=htms[khtms].r1*coslcosb;
      y1=htms[khtms].y1=htms[khtms].r1*sinlcosb;
      z1=htms[khtms].z1=htms[khtms].r1*sinb;
      lon=htms[khtms].l2;
      lat=htms[khtms].b2;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x2=htms[khtms].x2=htms[khtms].r2*coslcosb;
      y2=htms[khtms].y2=htms[khtms].r2*sinlcosb;
      z2=htms[khtms].z2=htms[khtms].r2*sinb;
      lon=htms[khtms].l3;
      lat=htms[khtms].b3;
      cosb=cos(lat);
      sinb=sin(lat);
      coslcosb=cos(lon)*cosb;
      sinlcosb=sin(lon)*cosb;
      x3=htms[khtms].x3=htms[khtms].r3*coslcosb;
      y3=htms[khtms].y3=htms[khtms].r3*sinlcosb;
      z3=htms[khtms].z3=htms[khtms].r3*sinb;
      /* --- center of gravity of the tetraedron --- */
      volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
      htms[khtms].volume=volume;
      htms[khtms].density=cdr.density;
      htms[khtms].mass=volume*htms[khtms].density;
      htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
      htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
      htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
      /* --- add to determine the center of gravity of the body --- */
      x+=(htms[khtms].xg*htms[khtms].mass);
      y+=(htms[khtms].yg*htms[khtms].mass);
      z+=(htms[khtms].zg*htms[khtms].mass);
      masstot+=htms[khtms].mass;
      volumetot+=volume;
   }
   /* --- center of gravity (m) --- */
   xg=x/masstot;
   yg=y/masstot;
   zg=z/masstot;
   /* --- iterating corrections due to the offcentering of the center of gravity --- */
   for (kt=0;kt<4;kt++) {
      x=y=z=0.;
      volumetot=0;
      masstot=0;
      for (khtms=0;khtms<nhtms;khtms++) {
         htms[khtms].x1-=xg;
         htms[khtms].y1-=yg;
         htms[khtms].z1-=zg;
         x1=htms[khtms].x1;
         y1=htms[khtms].y1;
         z1=htms[khtms].z1;
         htms[khtms].r1=sqrt(x1*x1+y1*y1+z1*z1);
         htms[khtms].l1=atan2(htms[khtms].y1,htms[khtms].x1);
         htms[khtms].b1=asin(htms[khtms].z1/htms[khtms].r1);
         htms[khtms].x2-=xg;
         htms[khtms].y2-=yg;
         htms[khtms].z2-=zg;
         x2=htms[khtms].x2;
         y2=htms[khtms].y2;
         z2=htms[khtms].z2;
         htms[khtms].r2=sqrt(x2*x2+y2*y2+z2*z2);
         htms[khtms].l2=atan2(htms[khtms].y2,htms[khtms].x2);
         htms[khtms].b2=asin(htms[khtms].z2/htms[khtms].r2);
         htms[khtms].x3-=xg;
         htms[khtms].y3-=yg;
         htms[khtms].z3-=zg;
         x3=htms[khtms].x3;
         y3=htms[khtms].y3;
         z3=htms[khtms].z3;
         htms[khtms].r3=sqrt(x3*x3+y3*y3+z3*z3);
         htms[khtms].l3=atan2(htms[khtms].y3,htms[khtms].x3);
         htms[khtms].b3=asin(htms[khtms].z3/htms[khtms].r3);
         /* --- center of gravity of the tetraedron --- */
         volume=-1./6.*(-x1*(y2*z3-y3*z2)+x2*(y1*z3-y3*z1)-x3*(y1*z2-y2*z1));
         htms[khtms].volume=volume;
         htms[khtms].density=cdr.density;
         htms[khtms].mass=volume*htms[khtms].density;
         htms[khtms].xg=2./3.*(x1+x2+x3)/3.;
         htms[khtms].yg=2./3.*(y1+y2+y3)/3.;
         htms[khtms].zg=2./3.*(z1+z2+z3)/3.;
         /* --- add to determine the center of gravity of the body --- */
         x+=(htms[khtms].xg*htms[khtms].mass);
         y+=(htms[khtms].yg*htms[khtms].mass);
         z+=(htms[khtms].zg*htms[khtms].mass);
         masstot+=htms[khtms].mass;
         volumetot+=volume;
      }
      /* --- center of gravity should converge to (0,0,0) --- */
      xg=x/masstot;
      yg=y/masstot;
      zg=z/masstot;
   }
   /* --- searching for the largest altitude from the gravity center ---*/
   for (khtms=0;khtms<nhtms;khtms++) {
      if (htms[khtms].r1>pmaxi) {pmaxi=htms[khtms].r1;}
      if (htms[khtms].r2>pmaxi) {pmaxi=htms[khtms].r2;}
      if (htms[khtms].r3>pmaxi) {pmaxi=htms[khtms].r3;}
   }
   masstot2=masstot;

   /*************************************************************/
   /*************************************************************/
   /**** complete the orbit position of each object          ****/
   /*************************************************************/
   /*************************************************************/
   /* --- shift of the asteroid position on the orbit of binaries --- */
   kfarsun=(int*)malloc(n*sizeof(int));
   if (kfarsun==NULL) {
      /* --- TBD error */
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      free(kdist1);
      return;
   }
   kfarearth=(int*)malloc(n*sizeof(int));
   if (kfarearth==NULL) {
      /* --- TBD error */
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      free(kdist1);
      free(kfarsun);
      return;
   }
   cdrpos1=(mc_cdrpos*)malloc(n*sizeof(mc_cdrpos));
   if (cdrpos1==NULL) {
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      free(kdist1);
      free(kfarsun);
      free(kfarearth);
      /* --- TBD error */
      return;
   }
   cdrpos2=(mc_cdrpos*)malloc(n*sizeof(mc_cdrpos));
   if (cdrpos2==NULL) {
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      free(kdist1);
      free(kfarsun);
      free(kfarearth);
      free(cdrpos1);
      /* --- TBD error */
      return;
   }
   pmaxibin=0.;
   for (kt=0;kt<n;kt++) {
     cdrpos1[kt]=cdrpos[kt];
     cdrpos2[kt]=cdrpos[kt];
     dl=fmod(l0/(DR)+360.*(cdrpos[kt].jd-date0)/period,360.)*(DR);
     /* - F5 -*/
     l1=dl;
     b1=0.;
     /* - F3 -*/
     cosb=cos(b1);
     sinb=sin(b1);
     coslcosb=cos(l1)*cosb;
     sinlcosb=sin(l1)*cosb;
     /* = object 1 -*/
     a1=2.*cdr.a*masstot2/(masstot1+masstot2);
     x1=a1*coslcosb/(UA);
     y1=a1*sinlcosb/(UA);
     z1=a1*sinb/(UA);
     /* - F7 -*/
     x=coslpcosi*x1-sinlp*y1-coslpsini*z1;
     y=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
     z=sini*x1+cosi*z1;
     rr=x*x+y*y+z*z;
     r=sqrt(rr)*(UA);
     if (r>pmaxibin) { pmaxibin=r; }
     /* - distance from the sun ---*/
     cdrpos1[kt].xaster+=x;
     cdrpos1[kt].yaster+=y;
     cdrpos1[kt].zaster+=z;
     rr1=cdrpos1[kt].xaster*cdrpos1[kt].xaster+cdrpos1[kt].yaster*cdrpos1[kt].yaster+cdrpos1[kt].zaster*cdrpos1[kt].zaster;
     /* = object 2 -*/
     a2=2.*cdr.a*masstot1/(masstot1+masstot2);
     x1=a2*coslcosb/(UA);
     y1=a2*sinlcosb/(UA);
     z1=a2*sinb/(UA);
     /* - F7 -*/
     x=coslpcosi*x1-sinlp*y1-coslpsini*z1;
     y=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
     z=sini*x1+cosi*z1;
     rr=x*x+y*y+z*z;
     r=sqrt(rr)*(UA);
     if (r>pmaxibin) { pmaxibin=r; }
     /* - distance from the sun ---*/
     cdrpos2[kt].xaster-=x;
     cdrpos2[kt].yaster-=y;
     cdrpos2[kt].zaster-=z;
     rr2=cdrpos2[kt].xaster*cdrpos2[kt].xaster+cdrpos2[kt].yaster*cdrpos2[kt].yaster+cdrpos2[kt].zaster*cdrpos2[kt].zaster;
     /* - -*/
     if (rr1>rr2) {
        kfarsun[kt]=1;
     } else {
        kfarsun[kt]=2;
     }
     /* - distance from the earth ---*/
     x=cdrpos1[kt].xaster-cdrpos[kt].xearth;
     y=cdrpos1[kt].yaster-cdrpos[kt].yearth;
     z=cdrpos1[kt].zaster-cdrpos[kt].zearth;
     rr1=x*x+y*y+z*z;
     x=cdrpos2[kt].xaster-cdrpos[kt].xearth;
     y=cdrpos2[kt].yaster-cdrpos[kt].yearth;
     z=cdrpos2[kt].zaster-cdrpos[kt].zearth;
     rr2=x*x+y*y+z*z;
     if (rr1>rr2) {
        kfarearth[kt]=1;
     } else {
        kfarearth[kt]=2;
     }
   }

   /*************************************************************/
   /*************************************************************/
   /**** init image of the farest object viewed from the sun ****/
   /*************************************************************/
   /*************************************************************/
   /* --- Allocate an image matrix image[] view from the sun */
   /*     for the asteroid farest from the sun to compute umbrial effects ---*/
   /* --- The image is centered on the gravity center: cdrpos?[].?aster ---*/
   rmini=1e21;
   for (kt=0;kt<n;kt++) {
      if (kfarsun[kt]==1) {
         cdrpos12=cdrpos1;
      } else {
         cdrpos12=cdrpos2;
      }
      dx=cdrpos12[kt].xaster;
      dy=cdrpos12[kt].yaster;
      dz=cdrpos12[kt].zaster;
      rr=dx*dx+dy*dy+dz*dz;
      rr+=(xg*xg+yg*yg+zg*zg)/(UA)/(UA);
      r=sqrt(rr);
      if (r<rmini) {rmini=r;}
   }
   wcssun.naxis1=200;
   wcssun.naxis2=200;
   field=atan(2*pmaxi/(UA)/rmini)*1.5;
   wcssun.cdelt1=field/wcssun.naxis1;
   wcssun.cdelt2=field/wcssun.naxis2;
   wcssun.crpix1=wcssun.naxis1/2+.5;
   wcssun.crpix2=wcssun.naxis2/2+.5;
   wcssun.crota2=0.;
   imagesun=(float*)malloc(wcssun.naxis1*wcssun.naxis2*sizeof(float));
   if (imagesun==NULL) {
      free(kfarsun);
      free(kfarearth);
      free(cdrpos1);
      free(cdrpos2);
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      free(kdist1);
      free(kdist2);
      /* --- TBD error */
      return;
   }
   /***************************************************************/
   /***************************************************************/
   /**** init image of the farest object viewed from the earth ****/
   /***************************************************************/
   /***************************************************************/
   /* --- Allocate an image matrix image[] view from the earth */
   /*     for the asteroid farest from the earth to compute occultation effects ---*/
   /* --- The image is centered on the gravity center: cdrpos?[].?aster ---*/
   rmini=1e21;
   for (kt=0;kt<n;kt++) {
      if (kfarsun[kt]==1) {
         cdrpos12=cdrpos1;
      } else {
         cdrpos12=cdrpos2;
      }
      dx=cdrpos12[kt].xaster;
      dy=cdrpos12[kt].yaster;
      dz=cdrpos12[kt].zaster;
      dx-=cdrpos12[kt].xearth;
      dy-=cdrpos12[kt].yearth;
      dz-=cdrpos12[kt].zearth;
      rr=dx*dx+dy*dy+dz*dz;
      rr+=(xg*xg+yg*yg+zg*zg)/(UA)/(UA);
      r=sqrt(rr);
      if (r<rmini) {rmini=r;}
   }
   wcsearth.naxis1=200;
   wcsearth.naxis2=200;
   field=atan(2*pmaxi/(UA)/rmini)*1.5;
   wcsearth.cdelt1=field/wcsearth.naxis1;
   wcsearth.cdelt2=field/wcsearth.naxis2;
   wcsearth.crpix1=wcsearth.naxis1/2+.5;
   wcsearth.crpix2=wcsearth.naxis2/2+.5;
   wcsearth.crota2=0.;
   imageearth=(float*)malloc(wcsearth.naxis1*wcsearth.naxis2*sizeof(float));
   if (imageearth==NULL) {
      free(kfarsun);
      free(kfarearth);
      free(cdrpos1);
      free(cdrpos2);
      free(htm1s);
      free(htm2s);
      free(dist1);
      free(dist2);
      free(kdist1);
      free(kdist2);
      if (imagesun!=NULL) {free(imagesun);}
      /* --- TBD error */
      return;
   }
   /***************************************/
   /***************************************/
   /**** init image of the two objects ****/
   /***************************************/
   /***************************************/
   /* --- Allocate an image matrix imagebin[] of the two bodies viewed from the frame_center */
   /* --- The image is centered on the common gravity center: cdrpos[].?aster ---*/
   rmini=1e21;
   for (kt=0;kt<n;kt++) {
      if (kfarsun[kt]==1) {
         cdrpos12=cdrpos2;
      } else {
         cdrpos12=cdrpos1;
      }
      dx=cdrpos12[kt].xaster;
      dy=cdrpos12[kt].yaster;
      dz=cdrpos12[kt].zaster;
      if (frame_center==1) {
         dx-=cdrpos12[kt].xearth;
         dy-=cdrpos12[kt].yearth;
         dz-=cdrpos12[kt].zearth;
      }
      rr=dx*dx+dy*dy+dz*dz;
      rr+=(xg*xg+yg*yg+zg*zg)/(UA)/(UA);
      r=sqrt(rr);
      if (r<rmini) {rmini=r;}
   }
   wcsbin.naxis1=300;
   wcsbin.naxis2=300;
   field=atan(2*(pmaxibin+pmaxi)/(UA)/rmini)*1.1;
   wcsbin.cdelt1=field/wcsbin.naxis1;
   wcsbin.cdelt2=field/wcsbin.naxis2;
   wcsbin.crpix1=wcsbin.naxis1/2+.5;
   wcsbin.crpix2=wcsbin.naxis2/2+.5;
   wcsbin.crota2=0.;
   if (genefilename!=NULL) {
      imagebin=(float*)malloc(wcsbin.naxis1*wcsbin.naxis2*sizeof(float));
      if (imagebin==NULL) {
         free(kfarsun);
         free(kfarearth);
         free(cdrpos1);
         free(cdrpos2);
         free(htm1s);
         free(htm2s);
         free(dist1);
         free(dist2);
         free(kdist1);
         free(kdist2);
         if (imagesun!=NULL) {free(imagesun);}
         if (imageearth!=NULL) {free(imageearth);}
         /* --- TBD error */
         return;
      }
   }
   /***********************************/
   /***********************************/
   /**** loop over the phase dates ****/
   /***********************************/
   /***********************************/
   for (kt=0;kt<n;kt++) {
      etotlamb=etotls=0.;
      dl=fmod(l0/(DR)+360.*(cdrpos[kt].jd-date0)/period,360.)*(DR);
      trtot=0.;
      /* == in the 1,2,3 we compute pr for the two bodies ===*/
      /* ===========================================*/
      /* ===========================================*/
      /* === 1) The asteroid farest from the Sun ===*/
      /* ===========================================*/
      /* ===========================================*/
      if (kfarsun[kt]==1) {
         cdrpos12=cdrpos1;
         htms=htm1s;
         dist=dist1;
         kdist=kdist1;
      } else {
         cdrpos12=cdrpos2;
         htms=htm2s;
         dist=dist2;
         kdist=kdist2;
      }
      image=imagesun;
      wcs=&wcssun;
      /* --- distances from the gravity center ---*/
      rr=cdrpos12[kt].xaster*cdrpos12[kt].xaster+cdrpos12[kt].yaster*cdrpos12[kt].yaster+cdrpos12[kt].zaster*cdrpos12[kt].zaster;
      r=sqrt(rr);
      /* --- defines the center for the projection viewed from the sun ---*/
      lc=atan2(cdrpos12[kt].yaster,cdrpos12[kt].xaster);
      bc=asin(cdrpos12[kt].zaster/r);
      wcs->crval1=fmod(lc/(DR)+360.,360.)*(DR);
      wcs->crval2=bc;
      /* --- initialize the projected image ---*/
      for (k=0;k<wcs->naxis1*wcs->naxis2;k++) {image[k]=(float)0.;}
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- F5 : take account for the rotation ---*/
         l1=htms[khtms].l1+dl;
         l2=htms[khtms].l2+dl;
         l3=htms[khtms].l3+dl;
         /* --- F3 : convert corners into cart. coord. in the frame of asteroid ---*/
         /*          take account for the gravity center ---*/
         cosb=cos(htms[khtms].b1);
         sinb=sin(htms[khtms].b1);
         coslcosb=cos(l1)*cosb;
         sinlcosb=sin(l1)*cosb;
         x1=htms[khtms].r1*coslcosb;
         y1=htms[khtms].r1*sinlcosb;
         z1=htms[khtms].r1*sinb;
         cosb=cos(htms[khtms].b2);
         sinb=sin(htms[khtms].b2);
         coslcosb=cos(l2)*cosb;
         sinlcosb=sin(l2)*cosb;
         x2=htms[khtms].r2*coslcosb;
         y2=htms[khtms].r2*sinlcosb;
         z2=htms[khtms].r2*sinb;
         cosb=cos(htms[khtms].b3);
         sinb=sin(htms[khtms].b3);
         coslcosb=cos(l3)*cosb;
         sinlcosb=sin(l3)*cosb;
         x3=htms[khtms].r3*coslcosb;
         y3=htms[khtms].r3*sinlcosb;
         z3=htms[khtms].r3*sinb;
         /* --- F4 : external normal vector to the triangular surface in the frame of asteroid ---*/
         px12=x2-x1;
         py12=y2-y1;
         pz12=z2-z1;
         px13=x3-x1;
         py13=y3-y1;
         pz13=z3-z1;
         px=(x1+x2+x3)/3.;
         py=(y1+y2+y3)/3.;
         pz=(z1+z2+z3)/3.;
         npx=(py12*pz13-py13*pz12);
         npy=-(px12*pz13-px13*pz12);
         npz=(px12*py13-px13*py12);
         np=sqrt(npx*npx+npy*npy+npz*npz);
         tr=0.5*np;
         nx=npx/np;
         ny=npy/np;
         nz=npz/np;
         q=px*nx+py*ny+pz*nz;
         if (q<0) {
            nx=-nx;
            ny=-ny;
            nz=-nz;
         }
         /* --- F7 : rotations to take account for the pole orientation / frame ---*/
         nsx=coslpcosi*nx-sinlp*ny-coslpsini*nz;
         nsy=sinlpcosi*nx+coslp*ny-sinlpsini*nz;
         nsz=sini*nx+cosi*nz;
         htms[khtms].x=coslpcosi*px-sinlp*py-coslpsini*pz;
         htms[khtms].y=sinlpcosi*px+coslp*py-sinlpsini*pz;
         htms[khtms].z=sini*px+cosi*pz;
         htms[khtms].x1=coslpcosi*x1-sinlp*y1-coslpsini*z1;
         htms[khtms].y1=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
         htms[khtms].z1=sini*x1+cosi*z1;
         htms[khtms].x2=coslpcosi*x2-sinlp*y2-coslpsini*z2;
         htms[khtms].y2=sinlpcosi*x2+coslp*y2-sinlpsini*z2;
         htms[khtms].z2=sini*x2+cosi*z2;
         htms[khtms].x3=coslpcosi*x3-sinlp*y3-coslpsini*z3;
         htms[khtms].y3=sinlpcosi*x3+coslp*y3-sinlpsini*z3;
         htms[khtms].z3=sini*x3+cosi*z3;
         /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the Sun ---*/
         rsx=(htms[khtms].x)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         dist[khtms]=rs;
         kdist[khtms]=khtms;
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs=rs;
         htms[khtms].db=brs-bc;
         htms[khtms].dl=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x1)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y1)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z1)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs1=rs;
         htms[khtms].db1=brs-bc;
         htms[khtms].dl1=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x2)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y2)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z2)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs2=rs;
         htms[khtms].db2=brs-bc;
         htms[khtms].dl2=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x3)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y3)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z3)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs3=rs;
         htms[khtms].db3=brs-bc;
         htms[khtms].dl3=-(lrs-lc)*cos(bc);
         /* --- F8 : absorbed and reflected powers (W) ---*/
         cosths=(cdrpos12[kt].xaster*nsx+cdrpos12[kt].yaster*nsy+cdrpos12[kt].zaster*nsz)/r;
         if (cosths<0) {
            pr=-e0/rr*tr*cosths*htms[khtms].albedo;
         } else {
            pr=0.;
         }
         /* --- infos for plots ---*/
         htms[khtms].tr=tr;
         htms[khtms].pr=pr;
      }
      /* --- sort the distances observer-triangles ---*/
      mc_quicksort_double(dist,0,nhtms-1,kdist);
      /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
      for (khtms=nhtms-1;khtms>=0;khtms--) {
         e=htms[kdist[khtms]].pr/htms[kdist[khtms]].tr;
         if (e==0.) { continue; }
         pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
         pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
         pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
         pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
         pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
         pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
         /* --- sort as x1<x2<x3 ---*/
         for (k1=0;k1<2;k1++) {
            for (k2=k1+1;k2<3;k2++) {
               if (pixx[k1]>pixx[k2]) {
                  x=pixx[k1];
                  pixx[k1]=pixx[k2];
                  pixx[k2]=x;
                  x=pixy[k1];
                  pixy[k1]=pixy[k2];
                  pixy[k2]=x;
               }
            }
         }
         /* --- first half triangle (1-2) ---*/
         x1=floor(pixx[0]+.5);
         if (x1>=wcs->naxis1) { continue; }
         x2=floor(pixx[1]+.5);
         if (x2<0) { continue; }
         if (x1<0) { x1=0; }
         if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
         for (k1=(int)x1;k1<=(int)x2;k1++) {
            if (pixx[1]==pixx[0]) { y2=pixy[1]; }
            else {
               frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
               if (frac<0) {frac=0;}
               if (frac>1) {frac=1.;}
               y2=pixy[0]+(pixy[1]-pixy[0])*frac;
            }
            if (pixx[2]==pixx[0]) { y3=pixy[2]; }
            else {
               frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[0]+(pixy[2]-pixy[0])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)e;
            }
         }
         /* --- second half triangle (2-3) ---*/
         x2=floor(pixx[1]+.5);
         if (x2>=wcs->naxis1) { continue; }
         x3=floor(pixx[2]+.5);
         if (x3<0) { continue; }
         if (x2<0) { x2=0; }
         if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
         for (k1=(int)x2;k1<=(int)x3;k1++) {
            if (pixx[0]==pixx[2]) { y2=pixy[0]; }
            else {
               frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y2=pixy[2]+(pixy[0]-pixy[2])*frac;
            }
            if (pixx[1]==pixx[2]) { y3=pixy[1]; }
            else {
               frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[2]+(pixy[1]-pixy[2])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)e;
            }
         }
      }
      /* ============================================*/
      /* ============================================*/
      /* === 2) The asteroid nearest from the Sun ===*/
      /* ============================================*/
      /* ============================================*/
      if (kfarsun[kt]==1) {
         cdrpos12=cdrpos2;
         htms=htm2s;
         dist=dist2;
         kdist=kdist2;
      } else {
         cdrpos12=cdrpos1;
         htms=htm1s;
         dist=dist1;
         kdist=kdist1;
      }
      image=imagesun;
      wcs=&wcssun;
      /* --- distances from the gravity center ---*/
      rr=cdrpos12[kt].xaster*cdrpos12[kt].xaster+cdrpos12[kt].yaster*cdrpos12[kt].yaster+cdrpos12[kt].zaster*cdrpos12[kt].zaster;
      r=sqrt(rr);
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- F5 : take account for the rotation ---*/
         l1=htms[khtms].l1+dl;
         l2=htms[khtms].l2+dl;
         l3=htms[khtms].l3+dl;
         /* --- F3 : convert corners into cart. coord. in the frame of asteroid ---*/
         /*          take account for the gravity center ---*/
         cosb=cos(htms[khtms].b1);
         sinb=sin(htms[khtms].b1);
         coslcosb=cos(l1)*cosb;
         sinlcosb=sin(l1)*cosb;
         x1=htms[khtms].r1*coslcosb;
         y1=htms[khtms].r1*sinlcosb;
         z1=htms[khtms].r1*sinb;
         cosb=cos(htms[khtms].b2);
         sinb=sin(htms[khtms].b2);
         coslcosb=cos(l2)*cosb;
         sinlcosb=sin(l2)*cosb;
         x2=htms[khtms].r2*coslcosb;
         y2=htms[khtms].r2*sinlcosb;
         z2=htms[khtms].r2*sinb;
         cosb=cos(htms[khtms].b3);
         sinb=sin(htms[khtms].b3);
         coslcosb=cos(l3)*cosb;
         sinlcosb=sin(l3)*cosb;
         x3=htms[khtms].r3*coslcosb;
         y3=htms[khtms].r3*sinlcosb;
         z3=htms[khtms].r3*sinb;
         /* --- F4 : external normal vector to the triangular surface in the frame of asteroid ---*/
         px12=x2-x1;
         py12=y2-y1;
         pz12=z2-z1;
         px13=x3-x1;
         py13=y3-y1;
         pz13=z3-z1;
         px=(x1+x2+x3)/3.;
         py=(y1+y2+y3)/3.;
         pz=(z1+z2+z3)/3.;
         npx=(py12*pz13-py13*pz12);
         npy=-(px12*pz13-px13*pz12);
         npz=(px12*py13-px13*py12);
         np=sqrt(npx*npx+npy*npy+npz*npz);
         tr=0.5*np;
         nx=npx/np;
         ny=npy/np;
         nz=npz/np;
         q=px*nx+py*ny+pz*nz;
         if (q<0) {
            nx=-nx;
            ny=-ny;
            nz=-nz;
         }
         /* --- F7 : rotations to take account for the pole orientation / frame ---*/
         nsx=coslpcosi*nx-sinlp*ny-coslpsini*nz;
         nsy=sinlpcosi*nx+coslp*ny-sinlpsini*nz;
         nsz=sini*nx+cosi*nz;
         htms[khtms].x=coslpcosi*px-sinlp*py-coslpsini*pz;
         htms[khtms].y=sinlpcosi*px+coslp*py-sinlpsini*pz;
         htms[khtms].z=sini*px+cosi*pz;
         htms[khtms].x1=coslpcosi*x1-sinlp*y1-coslpsini*z1;
         htms[khtms].y1=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
         htms[khtms].z1=sini*x1+cosi*z1;
         htms[khtms].x2=coslpcosi*x2-sinlp*y2-coslpsini*z2;
         htms[khtms].y2=sinlpcosi*x2+coslp*y2-sinlpsini*z2;
         htms[khtms].z2=sini*x2+cosi*z2;
         htms[khtms].x3=coslpcosi*x3-sinlp*y3-coslpsini*z3;
         htms[khtms].y3=sinlpcosi*x3+coslp*y3-sinlpsini*z3;
         htms[khtms].z3=sini*x3+cosi*z3;
         /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the Sun ---*/
         rsx=(htms[khtms].x)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         dist[khtms]=rs;
         kdist[khtms]=khtms;
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs=rs;
         htms[khtms].db=brs-bc;
         htms[khtms].dl=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x1)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y1)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z1)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs1=rs;
         htms[khtms].db1=brs-bc;
         htms[khtms].dl1=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x2)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y2)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z2)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs2=rs;
         htms[khtms].db2=brs-bc;
         htms[khtms].dl2=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x3)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y3)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z3)/(UA)+cdrpos12[kt].zaster;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs3=rs;
         htms[khtms].db3=brs-bc;
         htms[khtms].dl3=-(lrs-lc)*cos(bc);
         /* --- F8 : absorbed and reflected powers (W) ---*/
         cosths=(cdrpos12[kt].xaster*nsx+cdrpos12[kt].yaster*nsy+cdrpos12[kt].zaster*nsz)/r;
         if (cosths<0) {
            pr=-e0/rr*tr*cosths*htms[khtms].albedo;
         } else {
            pr=0.;
         }
         /* --- infos for plots ---*/
         htms[khtms].tr=tr;
         htms[khtms].pr=pr;
      }
      /* --- sort the distances observer-triangles ---*/
      mc_quicksort_double(dist,0,nhtms-1,kdist);
      /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
      for (khtms=nhtms-1;khtms>=0;khtms--) {
         pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
         pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
         pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
         pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
         pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
         pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
         /* --- sort as x1<x2<x3 ---*/
         for (k1=0;k1<2;k1++) {
            for (k2=k1+1;k2<3;k2++) {
               if (pixx[k1]>pixx[k2]) {
                  x=pixx[k1];
                  pixx[k1]=pixx[k2];
                  pixx[k2]=x;
                  x=pixy[k1];
                  pixy[k1]=pixy[k2];
                  pixy[k2]=x;
               }
            }
         }
         /* --- first half triangle (1-2) ---*/
         x1=floor(pixx[0]+.5);
         if (x1>=wcs->naxis1) { continue; }
         x2=floor(pixx[1]+.5);
         if (x2<0) { continue; }
         if (x1<0) { x1=0; }
         if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
         for (k1=(int)x1;k1<=(int)x2;k1++) {
            if (pixx[1]==pixx[0]) { y2=pixy[1]; }
            else {
               frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
               if (frac<0) {frac=0;}
               if (frac>1) {frac=1.;}
               y2=pixy[0]+(pixy[1]-pixy[0])*frac;
            }
            if (pixx[2]==pixx[0]) { y3=pixy[2]; }
            else {
               frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[0]+(pixy[2]-pixy[0])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)0;
            }
         }
         /* --- second half triangle (2-3) ---*/
         x2=floor(pixx[1]+.5);
         if (x2>=wcs->naxis1) { continue; }
         x3=floor(pixx[2]+.5);
         if (x3<0) { continue; }
         if (x2<0) { x2=0; }
         if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
         for (k1=(int)x2;k1<=(int)x3;k1++) {
            if (pixx[0]==pixx[2]) { y2=pixy[0]; }
            else {
               frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y2=pixy[2]+(pixy[0]-pixy[2])*frac;
            }
            if (pixx[1]==pixx[2]) { y3=pixy[1]; }
            else {
               frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[2]+(pixy[1]-pixy[2])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)0;
            }
         }
      }
      /*
      sprintf(filename,"farsun_%d.fit",kt+1);
      mc_savefits(image,wcs->naxis1,wcs->naxis2,filename,wcs);
      */
      /* ===========================================*/
      /* ===========================================*/
      /* === 3) The asteroid farest from the Sun ===*/
      /* ===========================================*/
      /* ===========================================*/
      if (kfarsun[kt]==1) {
         cdrpos12=cdrpos1;
         htms=htm1s;
         dist=dist1;
         kdist=kdist1;
      } else {
         cdrpos12=cdrpos2;
         htms=htm2s;
         dist=dist2;
         kdist=kdist2;
      }
      image=imagesun;
      wcs=&wcssun;
      /* --- put htms to zero if they are eclipsed (triangle by triangle from the farest to the nearest) ---*/
      for (khtms=nhtms-1;khtms>=0;khtms--) {
         if (htms[kdist[khtms]].pr==0.) {
            continue;
         }
         pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
         pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
         pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
         pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
         pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
         pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
         /* --- sort as x1<x2<x3 ---*/
         for (k1=0;k1<2;k1++) {
            for (k2=k1+1;k2<3;k2++) {
               if (pixx[k1]>pixx[k2]) {
                  x=pixx[k1];
                  pixx[k1]=pixx[k2];
                  pixx[k2]=x;
                  x=pixy[k1];
                  pixy[k1]=pixy[k2];
                  pixy[k2]=x;
               }
            }
         }
         /* --- first half triangle (1-2) ---*/
         x1=floor(pixx[0]+.5);
         if (x1>=wcs->naxis1) { continue; }
         x2=floor(pixx[1]+.5);
         if (x2<0) { continue; }
         if (x1<0) { x1=0; }
         if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
         for (k1=(int)x1;k1<=(int)x2;k1++) {
            if (pixx[1]==pixx[0]) { y2=pixy[1]; }
            else {
               frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
               if (frac<0) {frac=0;}
               if (frac>1) {frac=1.;}
               y2=pixy[0]+(pixy[1]-pixy[0])*frac;
            }
            if (pixx[2]==pixx[0]) { y3=pixy[2]; }
            else {
               frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[0]+(pixy[2]-pixy[0])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               if (image[k2*wcs->naxis1+k1]==0) {
                  htms[kdist[khtms]].pr=0.;
                  htms[kdist[khtms]].elamb=0.;
                  htms[kdist[khtms]].els=0.;
                  break;
               }
            }
            if (htms[kdist[khtms]].pr==0.) {
               break;
            }
         }
         if (htms[kdist[khtms]].pr==0.) {
            continue;
         }
         /* --- second half triangle (2-3) ---*/
         x2=floor(pixx[1]+.5);
         if (x2>=wcs->naxis1) { continue; }
         x3=floor(pixx[2]+.5);
         if (x3<0) { continue; }
         if (x2<0) { x2=0; }
         if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
         for (k1=(int)x2;k1<=(int)x3;k1++) {
            if (pixx[0]==pixx[2]) { y2=pixy[0]; }
            else {
               frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y2=pixy[2]+(pixy[0]-pixy[2])*frac;
            }
            if (pixx[1]==pixx[2]) { y3=pixy[1]; }
            else {
               frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[2]+(pixy[1]-pixy[2])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               if (image[k2*wcs->naxis1+k1]==0) {
                  htms[kdist[khtms]].pr=0.;
                  htms[kdist[khtms]].elamb=0.;
                  htms[kdist[khtms]].els=0.;
                  break;
               }
            }
            if (htms[kdist[khtms]].pr==0.) {
               break;
            }
         }
      }
      /* == in the 4,5,6 we compute e for the two bodies ===*/
      /* =============================================*/
      /* =============================================*/
      /* === 4) The asteroid farest from the Earth ===*/
      /* =============================================*/
      /* =============================================*/
      if (kfarearth[kt]==1) {
         cdrpos12=cdrpos1;
         htms=htm1s;
         dist=dist1;
         kdist=kdist1;
      } else {
         cdrpos12=cdrpos2;
         htms=htm2s;
         dist=dist2;
         kdist=kdist2;
      }
      image=imageearth;
      wcs=&wcsearth;
      /* --- distances from the gravity center ---*/
      rr=cdrpos12[kt].xaster*cdrpos12[kt].xaster+cdrpos12[kt].yaster*cdrpos12[kt].yaster+cdrpos12[kt].zaster*cdrpos12[kt].zaster;
      r=sqrt(rr);
      dx=cdrpos12[kt].xaster-cdrpos12[kt].xearth;
      dy=cdrpos12[kt].yaster-cdrpos12[kt].yearth;
      dz=cdrpos12[kt].zaster-cdrpos12[kt].zearth;
      delta2=dx*dx+dy*dy+dz*dz;
      delta=sqrt(delta2);
      /* --- defines the center for the projection viewed from the earth ---*/
      lc=atan2(cdrpos12[kt].yaster-cdrpos12[kt].yearth,cdrpos12[kt].xaster-cdrpos12[kt].xearth);
      bc=asin((cdrpos12[kt].zaster-cdrpos12[kt].zearth)/delta);
      wcs->crval1=fmod(lc/(DR)+360.,360.)*(DR);
      wcs->crval2=bc;
      /* --- initialize the projected image ---*/
      for (k=0;k<wcs->naxis1*wcs->naxis2;k++) {image[k]=(float)0.;}
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- F5 : take account for the rotation ---*/
         l1=htms[khtms].l1+dl;
         l2=htms[khtms].l2+dl;
         l3=htms[khtms].l3+dl;
         /* --- F3 : convert corners into cart. coord. in the frame of asteroid ---*/
         /*          take account for the gravity center ---*/
         cosb=cos(htms[khtms].b1);
         sinb=sin(htms[khtms].b1);
         coslcosb=cos(l1)*cosb;
         sinlcosb=sin(l1)*cosb;
         x1=htms[khtms].r1*coslcosb;
         y1=htms[khtms].r1*sinlcosb;
         z1=htms[khtms].r1*sinb;
         cosb=cos(htms[khtms].b2);
         sinb=sin(htms[khtms].b2);
         coslcosb=cos(l2)*cosb;
         sinlcosb=sin(l2)*cosb;
         x2=htms[khtms].r2*coslcosb;
         y2=htms[khtms].r2*sinlcosb;
         z2=htms[khtms].r2*sinb;
         cosb=cos(htms[khtms].b3);
         sinb=sin(htms[khtms].b3);
         coslcosb=cos(l3)*cosb;
         sinlcosb=sin(l3)*cosb;
         x3=htms[khtms].r3*coslcosb;
         y3=htms[khtms].r3*sinlcosb;
         z3=htms[khtms].r3*sinb;
         /* --- F4 : external normal vector to the triangular surface in the frame of asteroid ---*/
         px12=x2-x1;
         py12=y2-y1;
         pz12=z2-z1;
         px13=x3-x1;
         py13=y3-y1;
         pz13=z3-z1;
         px=(x1+x2+x3)/3.;
         py=(y1+y2+y3)/3.;
         pz=(z1+z2+z3)/3.;
         npx=(py12*pz13-py13*pz12);
         npy=-(px12*pz13-px13*pz12);
         npz=(px12*py13-px13*py12);
         np=sqrt(npx*npx+npy*npy+npz*npz);
         tr=0.5*np;
         nx=npx/np;
         ny=npy/np;
         nz=npz/np;
         q=px*nx+py*ny+pz*nz;
         if (q<0) {
            nx=-nx;
            ny=-ny;
            nz=-nz;
         }
         /* --- F7 : rotations to take account for the pole orientation / frame ---*/
         nsx=coslpcosi*nx-sinlp*ny-coslpsini*nz;
         nsy=sinlpcosi*nx+coslp*ny-sinlpsini*nz;
         nsz=sini*nx+cosi*nz;
         htms[khtms].x=coslpcosi*px-sinlp*py-coslpsini*pz;
         htms[khtms].y=sinlpcosi*px+coslp*py-sinlpsini*pz;
         htms[khtms].z=sini*px+cosi*pz;
         htms[khtms].x1=coslpcosi*x1-sinlp*y1-coslpsini*z1;
         htms[khtms].y1=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
         htms[khtms].z1=sini*x1+cosi*z1;
         htms[khtms].x2=coslpcosi*x2-sinlp*y2-coslpsini*z2;
         htms[khtms].y2=sinlpcosi*x2+coslp*y2-sinlpsini*z2;
         htms[khtms].z2=sini*x2+cosi*z2;
         htms[khtms].x3=coslpcosi*x3-sinlp*y3-coslpsini*z3;
         htms[khtms].y3=sinlpcosi*x3+coslp*y3-sinlpsini*z3;
         htms[khtms].z3=sini*x3+cosi*z3;
         /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the Sun ---*/
         rsx=(htms[khtms].x)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         dist[khtms]=rs;
         kdist[khtms]=khtms;
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs=rs;
         htms[khtms].db=brs-bc;
         htms[khtms].dl=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x1)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y1)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z1)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs1=rs;
         htms[khtms].db1=brs-bc;
         htms[khtms].dl1=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x2)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y2)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z2)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs2=rs;
         htms[khtms].db2=brs-bc;
         htms[khtms].dl2=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x3)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y3)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z3)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs3=rs;
         htms[khtms].db3=brs-bc;
         htms[khtms].dl3=-(lrs-lc)*cos(bc);
         /* --- F8 : absorbed and reflected powers (W) ---*/         
         cosths=(cdrpos12[kt].xaster*nsx+cdrpos12[kt].yaster*nsy+cdrpos12[kt].zaster*nsz)/r;
         pr=htms[khtms].pr;
         /* --- F9 : eclairement recu sur terre ---*/
         costht=(dx*nsx+dy*nsy+dz*nsz)/delta;
         if (costht<0) {
            pe=-1./fourpi*pr*costht;
            e=pe/fourpi/delta2;
         } else {
            pe=0.;
            e=0.;
         }
         /* --- surface exposée vers la Terre (m2) ---*/
         if (costht<0) {
            trtot+=(-tr*costht);
         }
         /* --- contribution to the total E (Lambert) ---*/
         elamb=e;
         /* --- contribution to the total E (Lommel-Seeliger) ---*/
         els=-e/(cosths+costht);
         /* --- infos for plots ---*/
         htms[khtms].tr=tr;
         htms[khtms].elamb=elamb/tr;
         htms[khtms].els=els/tr;
      }
      /* --- sort the distances observer-triangles ---*/
      mc_quicksort_double(dist,0,nhtms-1,kdist);
      /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
      for (khtms=nhtms-1;khtms>=0;khtms--) {
         e=htms[kdist[khtms]].els;
         if (e==0.) { continue; }
         pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
         pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
         pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
         pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
         pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
         pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
         /* --- sort as x1<x2<x3 ---*/
         for (k1=0;k1<2;k1++) {
            for (k2=k1+1;k2<3;k2++) {
               if (pixx[k1]>pixx[k2]) {
                  x=pixx[k1];
                  pixx[k1]=pixx[k2];
                  pixx[k2]=x;
                  x=pixy[k1];
                  pixy[k1]=pixy[k2];
                  pixy[k2]=x;
               }
            }
         }
         /* --- first half triangle (1-2) ---*/
         x1=floor(pixx[0]+.5);
         if (x1>=wcs->naxis1) { continue; }
         x2=floor(pixx[1]+.5);
         if (x2<0) { continue; }
         if (x1<0) { x1=0; }
         if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
         for (k1=(int)x1;k1<=(int)x2;k1++) {
            if (pixx[1]==pixx[0]) { y2=pixy[1]; }
            else {
               frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
               if (frac<0) {frac=0;}
               if (frac>1) {frac=1.;}
               y2=pixy[0]+(pixy[1]-pixy[0])*frac;
            }
            if (pixx[2]==pixx[0]) { y3=pixy[2]; }
            else {
               frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[0]+(pixy[2]-pixy[0])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)e;
            }
         }
         /* --- second half triangle (2-3) ---*/
         x2=floor(pixx[1]+.5);
         if (x2>=wcs->naxis1) { continue; }
         x3=floor(pixx[2]+.5);
         if (x3<0) { continue; }
         if (x2<0) { x2=0; }
         if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
         for (k1=(int)x2;k1<=(int)x3;k1++) {
            if (pixx[0]==pixx[2]) { y2=pixy[0]; }
            else {
               frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y2=pixy[2]+(pixy[0]-pixy[2])*frac;
            }
            if (pixx[1]==pixx[2]) { y3=pixy[1]; }
            else {
               frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[2]+(pixy[1]-pixy[2])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)e;
            }
         }
      }
      /* ==============================================*/
      /* ==============================================*/
      /* === 5) The asteroid nearest from the Earth ===*/
      /* ==============================================*/
      /* ==============================================*/
      if (kfarearth[kt]==1) {
         cdrpos12=cdrpos2;
         htms=htm2s;
         dist=dist2;
         kdist=kdist2;
      } else {
         cdrpos12=cdrpos1;
         htms=htm1s;
         dist=dist1;
         kdist=kdist1;
      }
      image=imageearth;
      wcs=&wcsearth;
      /* --- distances from the gravity center ---*/
      rr=cdrpos12[kt].xaster*cdrpos12[kt].xaster+cdrpos12[kt].yaster*cdrpos12[kt].yaster+cdrpos12[kt].zaster*cdrpos12[kt].zaster;
      r=sqrt(rr);
      dx=cdrpos12[kt].xaster-cdrpos12[kt].xearth;
      dy=cdrpos12[kt].yaster-cdrpos12[kt].yearth;
      dz=cdrpos12[kt].zaster-cdrpos12[kt].zearth;
      delta2=dx*dx+dy*dy+dz*dz;
      delta=sqrt(delta2);
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- F5 : take account for the rotation ---*/
         l1=htms[khtms].l1+dl;
         l2=htms[khtms].l2+dl;
         l3=htms[khtms].l3+dl;
         /* --- F3 : convert corners into cart. coord. in the frame of asteroid ---*/
         /*          take account for the gravity center ---*/
         cosb=cos(htms[khtms].b1);
         sinb=sin(htms[khtms].b1);
         coslcosb=cos(l1)*cosb;
         sinlcosb=sin(l1)*cosb;
         x1=htms[khtms].r1*coslcosb;
         y1=htms[khtms].r1*sinlcosb;
         z1=htms[khtms].r1*sinb;
         cosb=cos(htms[khtms].b2);
         sinb=sin(htms[khtms].b2);
         coslcosb=cos(l2)*cosb;
         sinlcosb=sin(l2)*cosb;
         x2=htms[khtms].r2*coslcosb;
         y2=htms[khtms].r2*sinlcosb;
         z2=htms[khtms].r2*sinb;
         cosb=cos(htms[khtms].b3);
         sinb=sin(htms[khtms].b3);
         coslcosb=cos(l3)*cosb;
         sinlcosb=sin(l3)*cosb;
         x3=htms[khtms].r3*coslcosb;
         y3=htms[khtms].r3*sinlcosb;
         z3=htms[khtms].r3*sinb;
         /* --- F4 : external normal vector to the triangular surface in the frame of asteroid ---*/
         px12=x2-x1;
         py12=y2-y1;
         pz12=z2-z1;
         px13=x3-x1;
         py13=y3-y1;
         pz13=z3-z1;
         px=(x1+x2+x3)/3.;
         py=(y1+y2+y3)/3.;
         pz=(z1+z2+z3)/3.;
         npx=(py12*pz13-py13*pz12);
         npy=-(px12*pz13-px13*pz12);
         npz=(px12*py13-px13*py12);
         np=sqrt(npx*npx+npy*npy+npz*npz);
         tr=0.5*np;
         nx=npx/np;
         ny=npy/np;
         nz=npz/np;
         q=px*nx+py*ny+pz*nz;
         if (q<0) {
            nx=-nx;
            ny=-ny;
            nz=-nz;
         }
         /* --- F7 : rotations to take account for the pole orientation / frame ---*/
         nsx=coslpcosi*nx-sinlp*ny-coslpsini*nz;
         nsy=sinlpcosi*nx+coslp*ny-sinlpsini*nz;
         nsz=sini*nx+cosi*nz;
         htms[khtms].x=coslpcosi*px-sinlp*py-coslpsini*pz;
         htms[khtms].y=sinlpcosi*px+coslp*py-sinlpsini*pz;
         htms[khtms].z=sini*px+cosi*pz;
         htms[khtms].x1=coslpcosi*x1-sinlp*y1-coslpsini*z1;
         htms[khtms].y1=sinlpcosi*x1+coslp*y1-sinlpsini*z1;
         htms[khtms].z1=sini*x1+cosi*z1;
         htms[khtms].x2=coslpcosi*x2-sinlp*y2-coslpsini*z2;
         htms[khtms].y2=sinlpcosi*x2+coslp*y2-sinlpsini*z2;
         htms[khtms].z2=sini*x2+cosi*z2;
         htms[khtms].x3=coslpcosi*x3-sinlp*y3-coslpsini*z3;
         htms[khtms].y3=sinlpcosi*x3+coslp*y3-sinlpsini*z3;
         htms[khtms].z3=sini*x3+cosi*z3;
         /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the Sun ---*/
         rsx=(htms[khtms].x)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         dist[khtms]=rs;
         kdist[khtms]=khtms;
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs=rs;
         htms[khtms].db=brs-bc;
         htms[khtms].dl=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x1)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y1)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z1)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs1=rs;
         htms[khtms].db1=brs-bc;
         htms[khtms].dl1=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x2)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y2)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z2)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs2=rs;
         htms[khtms].db2=brs-bc;
         htms[khtms].dl2=-(lrs-lc)*cos(bc);
         rsx=(htms[khtms].x3)/(UA)+cdrpos12[kt].xaster;
         rsy=(htms[khtms].y3)/(UA)+cdrpos12[kt].yaster;
         rsz=(htms[khtms].z3)/(UA)+cdrpos12[kt].zaster;
         rsx-=cdrpos12[kt].xearth;
         rsy-=cdrpos12[kt].yearth;
         rsz-=cdrpos12[kt].zearth;
         rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
         lrs=atan2(rsy,rsx);
         brs=asin(rsz/rs);
         htms[khtms].rs3=rs;
         htms[khtms].db3=brs-bc;
         htms[khtms].dl3=-(lrs-lc)*cos(bc);
         /* --- F8 : absorbed and reflected powers (W) ---*/         
         cosths=(cdrpos12[kt].xaster*nsx+cdrpos12[kt].yaster*nsy+cdrpos12[kt].zaster*nsz)/r;
         pr=htms[khtms].pr;
         /* --- F9 : eclairement recu sur terre ---*/
         costht=(dx*nsx+dy*nsy+dz*nsz)/delta;
         if (costht<0) {
            pe=-1./fourpi*pr*costht;
            e=pe/fourpi/delta2;
         } else {
            pe=0.;
            e=0.;
         }
         /* --- surface exposée vers la Terre (m2) ---*/
         /*
         if (costht<0) {
            trtot+=(-tr*costht);
         }
         */
         /* --- contribution to the total E (Lambert) ---*/
         elamb=e;
         /* --- contribution to the total E (Lommel-Seeliger) ---*/
         els=-e/(cosths+costht);
         /* --- infos for plots ---*/
         htms[khtms].tr=tr;
         htms[khtms].elamb=elamb/tr;
         htms[khtms].els=els/tr;
      }
      /* --- sort the distances observer-triangles ---*/
      mc_quicksort_double(dist,0,nhtms-1,kdist);
      /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
      for (khtms=nhtms-1;khtms>=0;khtms--) {
         pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
         pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
         pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
         pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
         pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
         pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
         /* --- sort as x1<x2<x3 ---*/
         for (k1=0;k1<2;k1++) {
            for (k2=k1+1;k2<3;k2++) {
               if (pixx[k1]>pixx[k2]) {
                  x=pixx[k1];
                  pixx[k1]=pixx[k2];
                  pixx[k2]=x;
                  x=pixy[k1];
                  pixy[k1]=pixy[k2];
                  pixy[k2]=x;
               }
            }
         }
         /* --- first half triangle (1-2) ---*/
         x1=floor(pixx[0]+.5);
         if (x1>=wcs->naxis1) { continue; }
         x2=floor(pixx[1]+.5);
         if (x2<0) { continue; }
         if (x1<0) { x1=0; }
         if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
         for (k1=(int)x1;k1<=(int)x2;k1++) {
            if (pixx[1]==pixx[0]) { y2=pixy[1]; }
            else {
               frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
               if (frac<0) {frac=0;}
               if (frac>1) {frac=1.;}
               y2=pixy[0]+(pixy[1]-pixy[0])*frac;
            }
            if (pixx[2]==pixx[0]) { y3=pixy[2]; }
            else {
               frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[0]+(pixy[2]-pixy[0])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)0;
            }
         }
         /* --- second half triangle (2-3) ---*/
         x2=floor(pixx[1]+.5);
         if (x2>=wcs->naxis1) { continue; }
         x3=floor(pixx[2]+.5);
         if (x3<0) { continue; }
         if (x2<0) { x2=0; }
         if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
         for (k1=(int)x2;k1<=(int)x3;k1++) {
            if (pixx[0]==pixx[2]) { y2=pixy[0]; }
            else {
               frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y2=pixy[2]+(pixy[0]-pixy[2])*frac;
            }
            if (pixx[1]==pixx[2]) { y3=pixy[1]; }
            else {
               frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[2]+(pixy[1]-pixy[2])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               image[k2*wcs->naxis1+k1]=(float)0;
            }
         }
      }
      /*
      sprintf(filename,"farearth_%d.fit",kt+1);
      mc_savefits(image,wcs->naxis1,wcs->naxis2,filename,wcs);
      */
      /* =============================================*/
      /* =============================================*/
      /* === 6) The asteroid farest from the Earth ===*/
      /* =============================================*/
      /* =============================================*/
      if (kfarearth[kt]==1) {
         cdrpos12=cdrpos1;
         htms=htm1s;
         dist=dist1;
         kdist=kdist1;
      } else {
         cdrpos12=cdrpos2;
         htms=htm2s;
         dist=dist2;
         kdist=kdist2;
      }
      image=imageearth;
      wcs=&wcsearth;
      /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
      for (khtms=nhtms-1;khtms>=0;khtms--) {
         if (htms[kdist[khtms]].els==0.) {
            continue;
         }
         pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
         pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
         pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
         pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
         pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
         pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
         /* --- sort as x1<x2<x3 ---*/
         for (k1=0;k1<2;k1++) {
            for (k2=k1+1;k2<3;k2++) {
               if (pixx[k1]>pixx[k2]) {
                  x=pixx[k1];
                  pixx[k1]=pixx[k2];
                  pixx[k2]=x;
                  x=pixy[k1];
                  pixy[k1]=pixy[k2];
                  pixy[k2]=x;
               }
            }
         }
         /* --- first half triangle (1-2) ---*/
         x1=floor(pixx[0]+.5);
         if (x1>=wcs->naxis1) { continue; }
         x2=floor(pixx[1]+.5);
         if (x2<0) { continue; }
         if (x1<0) { x1=0; }
         if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
         for (k1=(int)x1;k1<=(int)x2;k1++) {
            if (pixx[1]==pixx[0]) { y2=pixy[1]; }
            else {
               frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
               if (frac<0) {frac=0;}
               if (frac>1) {frac=1.;}
               y2=pixy[0]+(pixy[1]-pixy[0])*frac;
            }
            if (pixx[2]==pixx[0]) { y3=pixy[2]; }
            else {
               frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[0]+(pixy[2]-pixy[0])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               if (image[k2*wcs->naxis1+k1]==0) {
                  htms[kdist[khtms]].pr=0.;
                  htms[kdist[khtms]].elamb=0.;
                  htms[kdist[khtms]].els=0.;
                  break;
               }
            }
            if (htms[kdist[khtms]].pr==0.) {
               break;
            }
         }
         if (htms[kdist[khtms]].pr==0.) {
            continue;
         }
         /* --- second half triangle (2-3) ---*/
         x2=floor(pixx[1]+.5);
         if (x2>=wcs->naxis1) { continue; }
         x3=floor(pixx[2]+.5);
         if (x3<0) { continue; }
         if (x2<0) { x2=0; }
         if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
         for (k1=(int)x2;k1<=(int)x3;k1++) {
            if (pixx[0]==pixx[2]) { y2=pixy[0]; }
            else {
               frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y2=pixy[2]+(pixy[0]-pixy[2])*frac;
            }
            if (pixx[1]==pixx[2]) { y3=pixy[1]; }
            else {
               frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
               if (frac<0) {frac=0.;}
               if (frac>1) {frac=1.;}
               y3=pixy[2]+(pixy[1]-pixy[2])*frac;
            }
            if (y2>y3) { y=y2; y2=y3; y3=y; }
            y2=floor(y2+.5);
            if (y2>=wcs->naxis2) { continue; }
            y3=floor(y3+.5);
            if (y3<0) { continue; }
            if (y2<0) { y2=0; }
            if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
            for (k2=(int)y2;k2<=(int)y3;k2++) {
               if (image[k2*wcs->naxis1+k1]==0) {
                  htms[kdist[khtms]].pr=0.;
                  htms[kdist[khtms]].elamb=0.;
                  htms[kdist[khtms]].els=0.;
                  break;
               }
            }
            if (htms[kdist[khtms]].pr==0.) {
               break;
            }
         }
      }

      /* ===========================================================*/
      /* ===========================================================*/
      /* === 7) image of the binary system viewed from the Earth ===*/
      /* ===========================================================*/
      /* ===========================================================*/
      if (genefilename!=NULL) {
         if (kfarearth[kt]==1) {
            cdrpos12=cdrpos1;
            htms=htm1s;
            dist=dist1;
            kdist=kdist1;
         } else {
            cdrpos12=cdrpos2;
            htms=htm2s;
            dist=dist2;
            kdist=kdist2;
         }
         image=imagebin;
         wcs=&wcsbin;
         /* --- distances from the gravity center of the system---*/
         rr=cdrpos[kt].xaster*cdrpos[kt].xaster+cdrpos[kt].yaster*cdrpos[kt].yaster+cdrpos[kt].zaster*cdrpos[kt].zaster;
         r=sqrt(rr);
         dx=cdrpos[kt].xaster-cdrpos[kt].xearth;
         dy=cdrpos[kt].yaster-cdrpos[kt].yearth;
         dz=cdrpos[kt].zaster-cdrpos[kt].zearth;
         delta2=dx*dx+dy*dy+dz*dz;
         delta=sqrt(delta2);
         /* --- defines the center for the projection viewed from the earth ---*/
         lc=atan2(cdrpos[kt].yaster-cdrpos[kt].yearth,cdrpos[kt].xaster-cdrpos[kt].xearth);
            bc=asin((cdrpos[kt].zaster-cdrpos[kt].zearth)/delta);
         wcs->crval1=fmod(lc/(DR)+360.,360.)*(DR);
         wcs->crval2=bc;
         /* --- initialize the projected image ---*/
         for (k=0;k<wcs->naxis1*wcs->naxis2;k++) {image[k]=(float)0.;}
         /* === aster1 ===*/
         cdrpos12=cdrpos1;
         htms=htm1s;
         dist=dist1;
         kdist=kdist1;
         /* --- loop over the triangles ---*/
         for (khtms=0;khtms<nhtms;khtms++) {
            /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the Sun ---*/
            rsx=(htms[khtms].x)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            dist[khtms]=rs;
            kdist[khtms]=khtms;
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs=rs;
            htms[khtms].db=brs-bc;
            htms[khtms].dl=-(lrs-lc)*cos(bc);
            rsx=(htms[khtms].x1)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y1)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z1)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs1=rs;
            htms[khtms].db1=brs-bc;
            htms[khtms].dl1=-(lrs-lc)*cos(bc);
            rsx=(htms[khtms].x2)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y2)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z2)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs2=rs;
            htms[khtms].db2=brs-bc;
            htms[khtms].dl2=-(lrs-lc)*cos(bc);
            rsx=(htms[khtms].x3)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y3)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z3)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs3=rs;
            htms[khtms].db3=brs-bc;
            htms[khtms].dl3=-(lrs-lc)*cos(bc);
         }
         /* --- sort the distances observer-triangles ---*/
         mc_quicksort_double(dist,0,nhtms-1,kdist);
         /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
         for (khtms=nhtms-1;khtms>=0;khtms--) {
            e=htms[kdist[khtms]].els;
            if (e==0.) { continue; }
            pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
            pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
            pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
            pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
            pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
            pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
            /* --- sort as x1<x2<x3 ---*/
            for (k1=0;k1<2;k1++) {
               for (k2=k1+1;k2<3;k2++) {
                  if (pixx[k1]>pixx[k2]) {
                     x=pixx[k1];
                     pixx[k1]=pixx[k2];
                     pixx[k2]=x;
                     x=pixy[k1];
                     pixy[k1]=pixy[k2];
                     pixy[k2]=x;
                  }
               }
            }
            /* --- first half triangle (1-2) ---*/
            x1=floor(pixx[0]+.5);
            if (x1>=wcs->naxis1) { continue; }
            x2=floor(pixx[1]+.5);
            if (x2<0) { continue; }
            if (x1<0) { x1=0; }
            if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
            for (k1=(int)x1;k1<=(int)x2;k1++) {
               if (pixx[1]==pixx[0]) { y2=pixy[1]; }
               else {
                  frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
                  if (frac<0) {frac=0;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[0]+(pixy[1]-pixy[0])*frac;
               }
               if (pixx[2]==pixx[0]) { y3=pixy[2]; }
               else {
                  frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[0]+(pixy[2]-pixy[0])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs->naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs->naxis1+k1]=(float)e;
               }
            }
            /* --- second half triangle (2-3) ---*/
            x2=floor(pixx[1]+.5);
            if (x2>=wcs->naxis1) { continue; }
            x3=floor(pixx[2]+.5);
            if (x3<0) { continue; }
            if (x2<0) { x2=0; }
            if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
            for (k1=(int)x2;k1<=(int)x3;k1++) {
               if (pixx[0]==pixx[2]) { y2=pixy[0]; }
               else {
                  frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[2]+(pixy[0]-pixy[2])*frac;
               }
               if (pixx[1]==pixx[2]) { y3=pixy[1]; }
               else {
                  frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[2]+(pixy[1]-pixy[2])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs->naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs->naxis1+k1]=(float)e;
               }
            }
         }
         /* === aster2 ===*/
         cdrpos12=cdrpos2;
         htms=htm2s;
         dist=dist2;
         kdist=kdist2;
         /* --- loop over the triangles ---*/
         for (khtms=0;khtms<nhtms;khtms++) {
            /* --- defines the (dl,db) of the triangle projection in a plane perpendicular to the Sun ---*/
            rsx=(htms[khtms].x)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            dist[khtms]=rs;
            kdist[khtms]=khtms;
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs=rs;
            htms[khtms].db=brs-bc;
            htms[khtms].dl=-(lrs-lc)*cos(bc);
            rsx=(htms[khtms].x1)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y1)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z1)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs1=rs;
            htms[khtms].db1=brs-bc;
            htms[khtms].dl1=-(lrs-lc)*cos(bc);
            rsx=(htms[khtms].x2)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y2)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z2)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs2=rs;
            htms[khtms].db2=brs-bc;
            htms[khtms].dl2=-(lrs-lc)*cos(bc);
            rsx=(htms[khtms].x3)/(UA)+cdrpos12[kt].xaster;
            rsy=(htms[khtms].y3)/(UA)+cdrpos12[kt].yaster;
            rsz=(htms[khtms].z3)/(UA)+cdrpos12[kt].zaster;
            rsx-=cdrpos12[kt].xearth;
            rsy-=cdrpos12[kt].yearth;
            rsz-=cdrpos12[kt].zearth;
            rs=sqrt(rsx*rsx+rsy*rsy+rsz*rsz);
            lrs=atan2(rsy,rsx);
            brs=asin(rsz/rs);
            htms[khtms].rs3=rs;
            htms[khtms].db3=brs-bc;
            htms[khtms].dl3=-(lrs-lc)*cos(bc);
         }
         /* --- sort the distances observer-triangles ---*/
         mc_quicksort_double(dist,0,nhtms-1,kdist);
         /* --- fill image pixels, triangle by triangle from the farest to the nearest ---*/
         for (khtms=nhtms-1;khtms>=0;khtms--) {
            e=htms[kdist[khtms]].els;
            if (e==0.) { continue; }
            pixx[0]=htms[kdist[khtms]].dl1/wcs->cdelt1+wcs->crpix1;
            pixy[0]=htms[kdist[khtms]].db1/wcs->cdelt2+wcs->crpix2;
            pixx[1]=htms[kdist[khtms]].dl2/wcs->cdelt1+wcs->crpix1;
            pixy[1]=htms[kdist[khtms]].db2/wcs->cdelt2+wcs->crpix2;
            pixx[2]=htms[kdist[khtms]].dl3/wcs->cdelt1+wcs->crpix1;
            pixy[2]=htms[kdist[khtms]].db3/wcs->cdelt2+wcs->crpix2;
            /* --- sort as x1<x2<x3 ---*/
            for (k1=0;k1<2;k1++) {
               for (k2=k1+1;k2<3;k2++) {
                  if (pixx[k1]>pixx[k2]) {
                     x=pixx[k1];
                     pixx[k1]=pixx[k2];
                     pixx[k2]=x;
                     x=pixy[k1];
                     pixy[k1]=pixy[k2];
                     pixy[k2]=x;
                  }
               }
            }
            /* --- first half triangle (1-2) ---*/
            x1=floor(pixx[0]+.5);
            if (x1>=wcs->naxis1) { continue; }
            x2=floor(pixx[1]+.5);
            if (x2<0) { continue; }
            if (x1<0) { x1=0; }
            if (x2>=wcs->naxis1) { x2=wcs->naxis1-1; }
            for (k1=(int)x1;k1<=(int)x2;k1++) {
               if (pixx[1]==pixx[0]) { y2=pixy[1]; }
               else {
                  frac=(k1-pixx[0])/(pixx[1]-pixx[0]);
                  if (frac<0) {frac=0;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[0]+(pixy[1]-pixy[0])*frac;
               }
               if (pixx[2]==pixx[0]) { y3=pixy[2]; }
               else {
                  frac=(k1-pixx[0])/(pixx[2]-pixx[0]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[0]+(pixy[2]-pixy[0])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs->naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs->naxis1+k1]=(float)e;
               }
            }
            /* --- second half triangle (2-3) ---*/
            x2=floor(pixx[1]+.5);
            if (x2>=wcs->naxis1) { continue; }
            x3=floor(pixx[2]+.5);
            if (x3<0) { continue; }
            if (x2<0) { x2=0; }
            if (x3>=wcs->naxis1) { x3=wcs->naxis1-1; }
            for (k1=(int)x2;k1<=(int)x3;k1++) {
               if (pixx[0]==pixx[2]) { y2=pixy[0]; }
               else {
                  frac=(k1-pixx[2])/(pixx[0]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y2=pixy[2]+(pixy[0]-pixy[2])*frac;
               }
               if (pixx[1]==pixx[2]) { y3=pixy[1]; }
               else {
                  frac=(k1-pixx[2])/(pixx[1]-pixx[2]);
                  if (frac<0) {frac=0.;}
                  if (frac>1) {frac=1.;}
                  y3=pixy[2]+(pixy[1]-pixy[2])*frac;
               }
               if (y2>y3) { y=y2; y2=y3; y3=y; }
               y2=floor(y2+.5);
               if (y2>=wcs->naxis2) { continue; }
               y3=floor(y3+.5);
               if (y3<0) { continue; }
               if (y2<0) { y2=0; }
               if (y3>=wcs->naxis2) { y3=wcs->naxis2-1; }
               for (k2=(int)y2;k2<=(int)y3;k2++) {
                  image[k2*wcs->naxis1+k1]=(float)e;
               }
            }
         }
         sprintf(filename,"%s%d.fit",genefilename,kt+1);
         mc_savefits(image,wcs->naxis1,wcs->naxis2,filename,wcs);
      }
      /* ===========================================================*/
      /* ===========================================================*/
      /* === 8) magnitude computation ===*/
      /* ===========================================================*/
      /* ===========================================================*/
      /* === aster1 ===*/
      cdrpos12=cdrpos1;
      htms=htm1s;
      dist=dist1;
      kdist=kdist1;
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- contribution to the total E (Lambert) ---*/
         etotlamb+=(htms[khtms].elamb*htms[khtms].tr);
         /* --- contribution to the total E (Lommel-Seeliger) ---*/
         etotls+=(htms[khtms].els*htms[khtms].tr);
      }
      /* === aster2 ===*/
      cdrpos12=cdrpos2;
      htms=htm2s;
      dist=dist2;
      kdist=kdist2;
      /* --- loop over the triangles ---*/
      for (khtms=0;khtms<nhtms;khtms++) {
         /* --- contribution to the total E (Lambert) ---*/
         etotlamb+=(htms[khtms].elamb*htms[khtms].tr);
         /* --- contribution to the total E (Lommel-Seeliger) ---*/
         etotls+=(htms[khtms].els*htms[khtms].tr);
      }
      /* --- cas when the object in the shadow of the Earth ---*/
      etotlamb*=cdrpos[kt].eclipsed;
      etotls*=cdrpos[kt].eclipsed;
      /* --- mag1 take account for a pure Lambert law ---*/
      if (etotlamb==0) {
         cdrpos[kt].mag1=99.99;
      } else {
         cdrpos[kt].mag1=32.2800-2.5*log10(etotlamb);
      }
      /* --- mag2 take account for a pure Lommel-Seeliger law ---*/
      if (etotls==0) {
         cdrpos[kt].mag2=99.99;
      } else {
         cdrpos[kt].mag2=31.9665-2.5*log10(etotls);
      }
   }
   /* --- destroy memory allocations ---*/
   free(kfarsun);
   free(kfarearth);
   free(cdrpos1);
   free(cdrpos2);
   free(htm1s);
   free(htm2s);
   free(dist1);
   free(dist2);
   free(kdist1);
   free(kdist2);
   if (imagesun!=NULL) {free(imagesun);}
   if (imageearth!=NULL) {free(imageearth);}
   if (imagebin!=NULL) {free(imagebin);}
}
