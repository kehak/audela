/* mc_macr1.c
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

void mc_macro11(char *nom_fichier_obs,double delta,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=2;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=2) {
      mc_mvc2a(obs,delta,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro12(char *nom_fichier_obs,double a,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=2;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=2) {
      mc_mvc2c(obs,a,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro13(char *nom_fichier_obs,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=2;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=2) {
      mc_mvc2b(obs,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro14(char *nom_fichier_obs,double offc, double offl,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=3;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=3) {
      mc_gem3b(obs,offc,offl,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro15(char *nom_fichier_obs,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=3;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=3) {
      mc_gem3(obs,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro16(char *nom_fichier_obs,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=3;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=3) {
      mc_mvc3a(obs,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro17(char *nom_fichier_obs,char *nom_fichier_ele)
/***************************************************************************/
{
   mc_orbi_auto(nom_fichier_obs,nom_fichier_ele);
}

void mc_macro18(char *nom_fichier_obs,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=3;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=3) {
      mc_mvc3b(obs,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro19(char *nom_fichier_obs,double e,char *nom_fichier_ele)
/***************************************************************************/
{
   struct observ obs[4];
   struct elemorb elem;
   int nbobs;
   nbobs=2;
   mc_lec_mpc_auto(nom_fichier_obs,obs,&nbobs);
   if (nbobs>=2) {
      mc_mvc2d(obs,e,&elem,obs[1].jj_equinoxe);
      mc_determag(&elem,obs,nbobs);
      mc_affielem(elem);
      mc_writeelem(&elem,nom_fichier_ele);
   }
}

void mc_macro21(char *nom_fichier_bow,char *num_objet,char *nom_fichier_ele)
/***************************************************************************/
{
   int concordance;
   mc_bowell22(nom_fichier_bow,num_objet,nom_fichier_ele,&concordance);
}

void mc_macro22(char *nom_fichier_ele1,char *nom_fichier_ele2)
/***************************************************************************/
{
   int concordance;
   mc_convformat(2,nom_fichier_ele1,nom_fichier_ele2,&concordance);
}

void mc_macro23(char *nom_fichier_ele1,char *nom_fichier_ele2)
/***************************************************************************/
{
   int concordance;
   mc_convformat(3,nom_fichier_ele1,nom_fichier_ele2,&concordance);
}

void mc_macro24(char *nom_fichier_ele1,char *nom_fichier_ele2)
/***************************************************************************/
{
   int concordance;
   mc_convformat(4,nom_fichier_ele1,nom_fichier_ele2,&concordance);
}

void mc_macro25(char *nom_fichier_ele1,char *nom_fichier_ele2)
/***************************************************************************/
{
   int concordance;
   mc_convformat(5,nom_fichier_ele1,nom_fichier_ele2,&concordance);
}

void mc_macro31(char *nom_fichier_ele1,double jj,char *nom_fichier_ele2)
/***************************************************************************/
{
   int concordance;
   char num_aster[]="";
   mc_changepoque(nom_fichier_ele1,num_aster,jj,J2000,nom_fichier_ele2,&concordance);
}

void mc_macro41(char *nom_fichier_ele,double jjdeb, double jjfin,double jjpas,char *nom_fichier_out)
/***************************************************************************/
{
   int concordance;
   mc_ephem1(nom_fichier_ele,jjdeb,jjfin,jjpas,J2000,nom_fichier_out,&concordance);
}

void mc_macro42(char *nom_fichier_ele,double jj, double heuretu, double rangetq, double pastq, double equinoxe, char *nom_fichier_out)
/***************************************************************************/
{
   int concordance;
   double jjtd;
   jjtd=mc_deg(heuretu)/24+jj;
   mc_ephem2(nom_fichier_ele,jjtd,rangetq,pastq,equinoxe,nom_fichier_out,&concordance);
}

void mc_macro43(char *nom_fichier_ele,double jjdeb, double jjfin,double jjpas,char *nom_fichier_out)
/***************************************************************************/
{
   int concordance;
   mc_ephem1b(nom_fichier_ele,jjdeb,jjfin,jjpas,J2000,nom_fichier_out,&concordance);
}

void mc_macro51(char *nom_fichier_ele,double jjdeb, double jjfin,double jjpas,char *nom_fichier_out)
/***************************************************************************/
{
   int concordance;
   char nom_fichier_ele_tmp[]="@mc.elm",num_aster[]="";
   mc_changepoque(nom_fichier_ele,num_aster,jjdeb,J2000,nom_fichier_ele_tmp,&concordance);
   jjfin=1;
   jjpas=1;
   if (strcmp(nom_fichier_ele,nom_fichier_out)==0) {}
}

void mc_macro61(char *nom_fichier_in,char *nom_fichier_out)
/***************************************************************************/
{
   int concordance;
   mc_bowspace(nom_fichier_in,nom_fichier_out,&concordance);
}

void mc_macro62(char *nom_fichier_in,char *nom_fichier_ele,char *nom_fichier_out)
/***************************************************************************/
{
   mc_paradist(nom_fichier_in,nom_fichier_ele,nom_fichier_out);
}

void mc_macro63(double latitude,double altitude)
/***************************************************************************/
{
   double rhosinphip,rhocosphip;
   mc_latalt2rhophi(latitude,altitude,&rhosinphip,&rhocosphip);
   printf(" rhocosphi'=%f\n",rhocosphip);
   printf(" rhosinphi'=%f\n",rhosinphip);
}

void mc_macro64(double rhocosphip,double rhosinphip)
/***************************************************************************/
{
   double latitude,altitude;
   mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
   printf(" latitude=%f (degres)\n",latitude);
   printf(" altitude=%f (metres)\n",altitude);
}

void mc_macro71(char *nom_fichier_bow,double jjdeb, double jjfin)
/***************************************************************************/
{
   double j,jj,vint;
   int a,m,dec,signe;
   char nom_fichier[90],chaine1[20],chaine2[10],chaine3[10];

   if (jjfin<jjdeb) { jjfin=jjdeb; }
   for (jj=jjdeb;jj<=jjfin;jj++) {
      mc_jd_date(jj,&a,&m,&j);
      vint=floor(a);
      vint+=10000;
      strcpy(chaine1,fcvt(vint,4,&dec,&signe)+1);
      *(chaine1+4)='\0';
      vint=floor(m);
      vint+=100;
      strcpy(chaine2,fcvt(vint,2,&dec,&signe)+1);
      *(chaine2+2)='\0';
      vint=floor(j);
      vint+=100;
      strcpy(chaine3,fcvt(vint,2,&dec,&signe)+1);
      *(chaine3+2)='\0';
      strcat(chaine1,chaine2);
      strcat(chaine1,chaine3);
      strcat(chaine1,".txt");
      strcpy(nom_fichier,chaine1);
      mc_bowell1(nom_fichier_bow,jj,J2000,17,-50,60*(DR),90*(DR),-90*(DR),600,0,1,1,1,nom_fichier);
   }
}

void mc_macro72(char *nom_fichier_bow,double jjdeb, double jjfin,double magmax,double magmin,double elong,double decmax,double decmin,double incmax,double incmin,int flag1,int flag2,int flag3)
/***************************************************************************/
{
   double j,jj,vint;
   int a,m,dec,signe;
   char nom_fichier[90],chaine1[20],chaine2[10],chaine3[10];

   if (jjfin<jjdeb) { jjfin=jjdeb; }
   for (jj=jjdeb;jj<=jjfin;jj++) {
      mc_jd_date(jj,&a,&m,&j);
      vint=floor(a);
      vint+=10000;
      strcpy(chaine1,fcvt(vint,4,&dec,&signe)+1);
      *(chaine1+4)='\0';
      vint=floor(m);
      vint+=100;
      strcpy(chaine2,fcvt(vint,2,&dec,&signe)+1);
      *(chaine2+2)='\0';
      vint=floor(j);
      vint+=100;
      strcpy(chaine3,fcvt(vint,2,&dec,&signe)+1);
      *(chaine3+2)='\0';
      strcat(chaine1,chaine2);
      strcat(chaine1,chaine3);
      strcat(chaine1,".txt");
      strcpy(nom_fichier,chaine1);
      mc_bowell1(nom_fichier_bow,jj,J2000,magmax,magmin,elong*(DR),decmax*(DR),decmin*(DR),incmax,incmin,flag1,flag2,flag3,nom_fichier);
   }
}

void mc_macro81(char *nom_fichier_bow,double jj, double heuretu,double asd, double dec, double champ,char *nom_fichier_out)
/***************************************************************************/
{
   double aasd,ddec,cchamp,jjtd;
   char nom_fichier[90];
   aasd=mc_deg(asd)*15*DR;
   ddec=mc_deg(dec)*DR;
   cchamp=champ/60*DR;
   strcpy(nom_fichier,nom_fichier_out);
   jjtd=mc_deg(heuretu)/24+jj;
   mc_bowell3(nom_fichier_bow,jjtd,aasd,ddec,J2000,cchamp,nom_fichier);
}

