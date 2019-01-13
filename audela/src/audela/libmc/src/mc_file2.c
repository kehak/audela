/* mc_file2.c
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
/* Utilitaires de gestion de fichiers (base de Bowell, tri ...)            */
/***************************************************************************/
#include "mc.h"

void mc_bowspace(char *nom_fichier_in,char *nom_fichier_out,int *concordance)
/***************************************************************************/
/* Ecrit un fichier de l base de Bowell en remplacant tous les parametres  */
/* inutiles par des espaces. On peut ainsi compacter ulterieument la base. */
/***************************************************************************/
{
   FILE *fichier_in,*fichier_out;
   char ligne[300];
   int len,k,deb,fin;
   /* --- recherche de l'asteroide dans la base de Bowell ---*/
   *concordance=OK;
   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      *concordance=PB;
      return;
   }
   if (( fichier_out=fopen(nom_fichier_out,"w") ) == NULL) {
      *concordance=PB;
      return;
   }
   do {
      fgets(ligne,300,fichier_in);
      len=strlen(ligne);
      deb= 24-1; fin= 40-1; for (k=deb;k<=fin;k++) { ligne[k]=' '; }
      deb= 66-1; fin= 68-1; for (k=deb;k<=fin;k++) { ligne[k]=' '; }
      deb=104-1; fin=104-1; for (k=deb;k<=fin;k++) { ligne[k]=' '; }
      deb=180-1; fin=188-1; for (k=deb;k<=fin;k++) { ligne[k]=' '; }
      deb=215-1; fin=len-2; for (k=deb;k<=fin;k++) { ligne[k]=' '; }
      fputs(ligne,fichier_out);
   } while ((feof(fichier_in)==0));
   fclose(fichier_in);
   fclose(fichier_out);
}

void mc_fprfbow1(int flag, double equinoxe, FILE *fichier_out,int *nblighead)
/***************************************************************************/
/* Entete de sorties d'ephemerides de la base de Bowell                    */
/* flag=1 appel par mc_bowell1                                             */
/* flag=3 appel par mc_bowell3                                             */
/***************************************************************************/
{
   char chaine[80],astre[80];
   mc_jd_equinoxe(equinoxe,chaine);
   strcpy(astre,"Asteroide");
   if (flag==1) {
      *nblighead=14;
   }
   if (flag==3) {
      *nblighead=14;
   }
   fprintf(fichier_out,"%d\n",*nblighead);
   fprintf(fichier_out,"designat. : designation\n");
   fprintf(fichier_out,"ascens.   : ascension droite %s sous la forme hh.mmss\n",chaine);
   fprintf(fichier_out,"declina.  : declinaison %s sous la forme +dd.''ss\n",chaine);
   fprintf(fichier_out,"mag.      : magnitude visuelle\n");
   fprintf(fichier_out,"delt.     : distance Terre-%s (en ua)\n",astre);
   fprintf(fichier_out,"njob.     : nombre de jours de l'arc observe (jours)\n");
   fprintf(fichier_out,"nob.      : nombre de points d'observations\n");
   fprintf(fichier_out,"in.       : incertitude de localisation (en arcsec)\n");
   fprintf(fichier_out,"deph.     : deplacement apparent horaire (en arcsec/heure)\n");
   fprintf(fichier_out,"pa.       : angle de position du deplacement horaire (degres)\n");
   fprintf(fichier_out,"rem.      : remarques diverses\n\n");
   fprintf(fichier_out,"designat.   ascens.   declina.  mag.  delt. njob. nob.    in. deph. pa. rem.\n");
}

void mc_fprfbow11(char *name,double asd,double dec,double mag,double delta,struct asterident aster,double incert,double dist,double posangle,FILE *fichier_out)
/***************************************************************************/
/* Sorties d'ephemerides d'apres l'entete definie par mc_fprfbow1          */
/* Serie de positions pour d'astres divers pour une date donnee            */
/***************************************************************************/
{
   char chaine[80];
   fprintf(fichier_out,"%s ",name);
   mc_fstr((mc_dms(asd/15/(DR))),PB,2,4,OK,chaine);
   fprintf(fichier_out,"%c%c %c%c %c%c ",chaine[0],chaine[1],chaine[3],chaine[4],chaine[5],chaine[6]);
   mc_fstr((mc_dms(dec/(DR))),OK,2,4,OK,chaine);
   fprintf(fichier_out,"%c%c%c %c%c %c%c ",chaine[0],chaine[1],chaine[2],chaine[4],chaine[5],chaine[6],chaine[7]);
   mc_fstr(mag,PBB,2,1,PB,chaine);
   fprintf(fichier_out,"%s ",chaine);
   mc_fstr(delta,PB,2,3,PB,chaine);
   fprintf(fichier_out,"%s ",chaine);
   mc_fstr((double)(aster.nbjours),PB,5,0,PB,chaine);
   fprintf(fichier_out,"%s ",chaine);
   mc_fstr((double)(aster.nbobs),PB,4,0,PB,chaine);
   fprintf(fichier_out,"%s ",chaine);
   mc_fstr(incert,PBB,5,0,PB,chaine);
   fprintf(fichier_out,"%s ",chaine);
   mc_fstr((dist/(DR)*3600),PB,5,0,PB,chaine);
   fprintf(fichier_out,"%s ",chaine);
   mc_fstr((posangle/(DR)),PB,3,0,PB,chaine);
   fprintf(fichier_out,"%s",chaine);
}

void mc_fprfeph1(int flag, double equinoxe, struct elemorb elem, FILE *fichier_out,int *nblighead)
/***************************************************************************/
/* Entete de sorties d'ephemerides a partir des elements orbitaux          */
/* flag=1 appel par mc_ephem1                                              */
/***************************************************************************/
{
   struct asterident aster;
   char ligne[300];
   char chaine[80],astre[80];
   mc_typedastre(elem,astre);
   mc_jd_equinoxe(equinoxe,chaine);
   if (flag==1) {
      *nblighead=14;
   }
   fprintf(fichier_out,"%d\n",*nblighead);
   fprintf(fichier_out,"date(TU)  : instant de l'ephemeride (temps universel)\n");
   fprintf(fichier_out,"ascens.   : ascension droite %s sous la forme hh.mmss\n",chaine);
   fprintf(fichier_out,"declina.  : declinaison %s sous la forme +dd.''ss\n",chaine);
   fprintf(fichier_out,"mag.      : magnitude visuelle\n");
   fprintf(fichier_out,"delt.     : distance Terre-%s (en ua)\n",astre);
   fprintf(fichier_out,"r         : distance Soleil-%s (en ua)\n",astre);
   fprintf(fichier_out,"el.       : angle d'elongation (en degres)\n");
   fprintf(fichier_out,"deph.     : deplacement apparent horaire (en arcsec/heure)\n");
   fprintf(fichier_out,"pa.       : angle de position du deplacement horaire (degres)\n");
   fprintf(fichier_out,"in.       : incertitude de localisation (en arcsec)\n\n");
   if (flag==1) {
      strcpy(ligne,elem.designation);
      fprintf(fichier_out,"%s ",ligne);
      mc_elem2aster(elem,&aster);
      mc_typedaster(aster,ligne);
      fprintf(fichier_out,"%s\n",ligne);
   }
   fprintf(fichier_out,"        date(TU)     ascens.    declina.  mag.  delt.      r el. deph. pa.    in.\n");
}

void mc_fprfeph21(int flag,struct elemorb elem,double jj,double asd,double dec,double mag,double delta,double r,double elong,double dist,double posangle,double incert,FILE *fichier_out)
/***************************************************************************/
/* Sorties d'ephemerides d'apres l'entete definie par mc_fprfbow2          */
/* Serie de positions a differentes dates pour un astre donne              */
/***************************************************************************/
{
   double jour;
   int annee,mois;
   char chaine[80];
   mc_jd_date(jj,&annee,&mois,&jour);
   elem.nbjours=elem.nbjours*1;
   if (flag==1) {
      mc_fstr((double)(annee),PB,4,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr((double)(mois),PB,2,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(jour,PB,2,5,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr((mc_dms(asd/15/(DR))),PB,2,6,OK,chaine);
      fprintf(fichier_out,"%c%c %c%c %c%c.%c%c ",chaine[0],chaine[1],chaine[3],chaine[4],chaine[5],chaine[6],chaine[7],chaine[8]);
      mc_fstr((mc_dms(dec/(DR))),OK,2,5,OK,chaine);
      fprintf(fichier_out,"%c%c%c %c%c %c%c.%c ",chaine[0],chaine[1],chaine[2],chaine[4],chaine[5],chaine[6],chaine[7],chaine[8]);
      mc_fstr(mag,PBB,2,1,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(delta,PB,2,3,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(r,PB,2,3,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(elong/(DR),PB,3,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(dist/(DR)*3600,PB,5,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(posangle/(DR),PB,3,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(incert,PBB,5,0,PB,chaine);
      fprintf(fichier_out,"%s",chaine);
      fprintf(fichier_out,"\n");
   }
}

void mc_fprfeph2(int flag, double equinoxe, double jj, struct elemorb elem, FILE *fichier_out,int *nblighead)
/***************************************************************************/
/* Entete de sorties d'ephemerides a partir des elements orbitaux          */
/* flag=1 appel par mc_ephem2                                              */
/***************************************************************************/
{
   struct asterident aster;
   char ligne[300];
   char chaine[80],astre[80];
   double jour;
   int annee,mois;
   mc_typedastre(elem,astre);
   mc_jd_equinoxe(equinoxe,chaine);
   if (flag==1) {
      *nblighead=15;
   }
   fprintf(fichier_out,"%d\n",*nblighead);
   fprintf(fichier_out,"Tq        : decalage de instant du perihelie (en jours)\n");
   fprintf(fichier_out,"ascens.   : ascension droite %s sous la forme hh.mmss\n",chaine);
   fprintf(fichier_out,"declina.  : declinaison %s sous la forme +dd.''ss\n",chaine);
   fprintf(fichier_out,"mag.      : magnitude visuelle\n");
   fprintf(fichier_out,"delt.     : distance Terre-%s (en ua)\n",astre);
   fprintf(fichier_out,"r         : distance Soleil-%s (en ua)\n",astre);
   fprintf(fichier_out,"el.       : angle d'elongation (en degres)\n");
   fprintf(fichier_out,"deph.     : deplacement apparent horaire (en arcsec/heure)\n");
   fprintf(fichier_out,"pa.       : angle de position du deplacement horaire (degres)\n");
   fprintf(fichier_out,"in.       : incertitude de localisation (en arcsec)\n\n");
   if (flag==1) {
      strcpy(ligne,elem.designation);
      fprintf(fichier_out,"%s ",ligne);
      mc_elem2aster(elem,&aster);
      mc_typedaster(aster,ligne);
      fprintf(fichier_out,"%s\n",ligne);
   }
   mc_jd_date(jj,&annee,&mois,&jour);
   mc_fstr((double)(annee),PB,4,0,PB,chaine);
   fprintf(fichier_out,"instant de l'ephemeride : %s",chaine);
   mc_fstr((double)(mois),PB,2,0,PB,chaine);
   fprintf(fichier_out,"%s",chaine);
   mc_fstr(jour,PB,2,5,PB,chaine);
   fprintf(fichier_out,"%s (TU)\n",chaine);
   fprintf(fichier_out,"       Tq     ascens.    declina.  mag.  delt.      r el. deph. pa.    in.\n");
}

void mc_fprfeph22(int flag,struct elemorb elem,double jj,double asd,double dec,double mag,double delta,double r,double elong,double dist,double posangle,double incert,FILE *fichier_out)
/***************************************************************************/
/* Sorties d'ephemerides d'apres l'entete definie par mc_fprfeph2          */
/* Serie de positions a differentes dates pour un astre donne              */
/***************************************************************************/
{
   char chaine[80];
   elem.nbjours=elem.nbjours*1;
   if (flag==1) {
      mc_fstr(jj,OK,4,3,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr((mc_dms(asd/15/(DR))),PB,2,6,OK,chaine);
      fprintf(fichier_out,"%c%c %c%c %c%c.%c%c ",chaine[0],chaine[1],chaine[3],chaine[4],chaine[5],chaine[6],chaine[7],chaine[8]);
      mc_fstr((mc_dms(dec/(DR))),OK,2,5,OK,chaine);
      fprintf(fichier_out,"%c%c%c %c%c %c%c.%c ",chaine[0],chaine[1],chaine[2],chaine[4],chaine[5],chaine[6],chaine[7],chaine[8]);
      mc_fstr(mag,PBB,2,1,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(delta,PB,2,3,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(r,PB,2,3,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(elong/(DR),PB,3,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(dist/(DR)*3600,PB,5,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(posangle/(DR),PB,3,0,PB,chaine);
      fprintf(fichier_out,"%s ",chaine);
      mc_fstr(incert,PBB,5,0,PB,chaine);
      fprintf(fichier_out,"%s",chaine);
      fprintf(fichier_out,"\n");
   }
}

void mc_typedastre(struct elemorb elem,char *astre)
/***************************************************************************/
/* Retourne la nature d'un astre dans une chaine d'apres la structure elem.*/
/***************************************************************************/
{
   if (elem.type==UNKNOWN) { strcpy(astre,"Astre"); }
   if (elem.type==ASTEROIDE) { strcpy(astre,"Asteroide"); }
   if (elem.type==COMETE) { strcpy(astre,"Comete"); }
   if (elem.type==PLANETE) { strcpy(astre,"Planete"); }
}

void mc_convformat(int flag,char *nom_fichier_ele1,char *nom_fichier_ele2, int *concordance)
/***************************************************************************/
/* Conversion de format d'elements d'orbite.                               */
/***************************************************************************/
/* flag =                                                                  */
/*  2. format MPEC Daily Orbit Update -> format MC                         */
/*  3. format MPEC -> format MC                                            */
/*  4. format MC -> format MPEC Daily Orbit Update                         */
/*  5. format MC -> format MPEC                                            */
/* *nom_fichier_ele1 : nom du fichier d'entree. Seul le premier objet      */
/*  rencontre est traite.                                                  */
/* *nom_fichier_ele2 : nom du fichier de sortie.                           */
/* *concordance : =OK si un objet est trouve dans le fichier d'entree.     */
/***************************************************************************/
{
   struct elemorb elem;
   int ligdeb=0;
   *concordance=PB;
   if (flag==2) {
   }
   if (flag==3) {
      ligdeb=1;
      mc_lec_ele_mpec1(nom_fichier_ele1,&elem,concordance,&ligdeb);
      mc_writeelem(&elem,nom_fichier_ele2);
   }
   if (flag==4) {
   }
   if (flag==5) {
      mc_readelem(nom_fichier_ele1,&elem);
      mc_wri_ele_mpec1(nom_fichier_ele2,elem,APPEND);
   }
}

void mc_wri_ele_mpec1(char *nom_fichier_out, struct elemorb elem,int type_fichier)
/***************************************************************************/
/* Converti les donnees d'element d'orbite format interne vers format MPEC.*/
/***************************************************************************/
{
   FILE *fichier_out;
   char texte[81],egal;
   double a,p,n,m,q,e,jd,jdm0,jj1,jj2,kgrav;
   int annee,mois,checksum,len,k;
   double jour;
   int centre;
   if (type_fichier==APPEND) {
      if (( fichier_out=fopen(nom_fichier_out,"a") ) == NULL) {
         printf("fichier non trouve\n");
         return;
      }
   }
   /*if (type_fichier==WRITE) {*/
   else {
      if (( fichier_out=fopen(nom_fichier_out,"w") ) == NULL) {
         printf("fichier non trouve\n");
         return;
      }
   }

   centre=SOLEIL;
   /*centre=TERRE;*/
   if (centre==TERRE) {
      kgrav=(KGEOS);
   } else {
      kgrav=(K);
   }

   if (centre==SOLEIL) {
      /* on genere au format MPC */
      egal='=';memset(texte,egal,79);texte[79]='\0';
      fprintf(fichier_out,"%s\n",texte); 
      fprintf(fichier_out,"%s\n",elem.designation);
      jd=PB;
      mc_mpec_jjjjdates(elem.jj_epoque,jd,texte);
      fprintf(fichier_out,"Epoch %s TT\n",texte);
      e=elem.e;
      if (e<10) {
         q=elem.q;
         a=q/fabs(1-e);
         n= kgrav/(DR)/a/sqrt(a);
         jdm0=elem.jj_m0;
         jd=elem.jj_epoque;
         m=(elem.m0+(jd-jdm0)*n*DR)/(DR);
         mc_fstr(m,PB,3,5,PB,texte);
         fprintf(fichier_out,"M %s              (2000.0)            P               Q\n",texte);
         mc_fstr(n,PB,3,8,PB,texte);
         fprintf(fichier_out,"n %s     ",texte);
         mc_fstr(elem.w/(DR),PBB,3,5,PB,texte);
         fprintf(fichier_out,"Peri. %s     \n",texte);
         mc_fstr(a,PB,3,7,PB,texte);
         fprintf(fichier_out,"a %s      ",texte);
         mc_fstr(elem.o/(DR),PBB,3,5,PB,texte);
         fprintf(fichier_out,"Node  %s     \n",texte);
         mc_fstr(elem.e,PB,3,7,PB,texte);
         fprintf(fichier_out,"e %s      ",texte);
         mc_fstr(elem.i/(DR),PBB,3,5,PB,texte);
         fprintf(fichier_out,"Incl. %s     \n",texte);
         p=sqrt(a*a*a);
         mc_fstr(p,PB,3,2,PB,texte);
         fprintf(fichier_out,"P%s            ",texte);
         if (elem.type==ASTEROIDE) {
            mc_fstr(elem.h,PBB,4,1,PB,texte);
            fprintf(fichier_out,"H%s           ",texte);
            mc_fstr(elem.g,PBB,3,2,PB,texte);
            fprintf(fichier_out,"G%s",texte);
         }
         if (elem.type==COMETE) {
            mc_fstr(elem.h0,PBB,5,1,PB,texte);
            fprintf(fichier_out,"H%s           ",texte);
         }
         fprintf(fichier_out,"\n");
         fprintf(fichier_out,"From %d observations ",elem.nbobs);
         jj1=elem.jj_ceu0;
         jj2=jj1+elem.nbjours-1;
         mc_mpec_jjjjdates(jj1,jj2,texte);
         fprintf(fichier_out,"%s",texte);
         if (elem.residu_rms!=0) {
	         fprintf(fichier_out," mean residual %.2f\"",elem.residu_rms);
         }
         fprintf(fichier_out,"\n");
         if (elem.type==ASTEROIDE) {
            fprintf(fichier_out,"BowellCodes %d %d %d %d %d %d\n",elem.code1,elem.code2,elem.code3,elem.code4,elem.code5,elem.code6);
         }
      }
   }
   if (centre==TERRE) {
      /* on genere au format TLE */
      fprintf(fichier_out,"%s\n",elem.designation);
      mc_jd_date(elem.jj_epoque,&annee,&mois,&jour);
      mc_date_jd(annee,mois,jour,&jj1);
      mc_date_jd(annee,1,1.,&jj2);
      jj2=jj1-jj2+1.;
      q=elem.q;
      a=q/fabs(1-e);
      n= kgrav/(DR)/a/sqrt(a);
      jdm0=elem.jj_m0;
      jd=elem.jj_epoque;
      m=(elem.m0+(jd-jdm0)*n*DR)/(DR);
      n=n/360.;
      /*1 24209U 96044B   03262.91033065 -.00000065  00000-0  00000+0 0  8956*/
      sprintf(texte,"1 00000U 00000B   %02d%012.8f -.00000000  00000-0  00000+0 0  000",(annee-2000),jj2);
      len=(int)strlen(texte);
      checksum=0;
      for (k=0;k<len;k++) {
         if ((texte[k]>='1')&&(texte[k]<='9')) {
            checksum+=(int)(texte[k]-'0');
         }
         if (texte[k]=='-') {
            checksum+=(int)(1);
         }
      }
      checksum=(int)fmod((double)checksum,(double)10);
      fprintf(fichier_out,"%s%d\n",texte,checksum);
      /*2 24209   0.0626 123.5457 0004535  56.5151 138.1659  1.00273036 26182*/
      sprintf(texte,"2 00000   %06.4f %8.4f %07d %8.4f %8.4f %11.8f 0000",elem.i/(DR),elem.o/(DR),(int)(elem.e*1e7),elem.w/(DR),m,n);
      len=(int)strlen(texte);
      checksum=0;
      for (k=0;k<len;k++) {
         if ((texte[k]>='1')&&(texte[k]<='9')) {
            checksum+=(int)(texte[k]-'0');
         }
         if (texte[k]=='-') {
            checksum+=(int)(1);
         }
      }
      checksum=(int)fmod((double)checksum,(double)10);
      fprintf(fichier_out,"%s%d\n",texte,checksum);
   }
   fclose(fichier_out);
}

void mc_lec_ele_mpec1(char *nom_fichier_in, struct elemorb *elem,int *concordance,int *ligfin)
/***************************************************************************/
/* Converti les donnees d'element d'orbite format MPEC vers format interne.*/
/***************************************************************************/
/* ligfin est le numero de ligne a partir duquel on commence a rechercher  */
/* les elements d'orbite. Lorsqu'un deuxieme lot d'elements d'orbite est   */
/* detecte, on renvoit dans *ligfin, le numero de la ligne ou il faudra    */
/* commencer a lire les elements d'orbite lors du deuxieme appel a la      */
/* fonction. On peut ainsi lire une suite d'elements d'orbites dans un     */
/* meme fichier.                                                           */
/***************************************************************************/
{
   FILE *fichier_in;
   char ligne[120],texte1[120],texte2[120],texte3[120];
   int check,lig=0,ligdeb=0,len,k,design,kligfin,type=TYPE_MPEC1;
   struct elemorb elemok;
   double jj1=0,jj2=0,a;

   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   strcpy(elem->designation,"");
   elem->m0=0;
   elem->jj_m0=J2000;
   elem->e=0;
   elem->q=1;
   elem->jj_perihelie=J2000;
   elem->i=0;
   elem->o=0;
   elem->w=0;
   elem->jj_equinoxe=J2000;
   elem->jj_epoque=J2000;
   elem->type=ASTEROIDE;
   elem->h0=14;
   elem->n=4;
   elem->h=14;
   elem->g=.15;
   elem->nbjours=1;
   elem->nbobs=0;
   elem->ceu0=0;
   elem->ceut=0;
   elem->jj_ceu0=J2000;
   elem->code1=0;
   elem->code2=0;
   elem->code3=0;
   elem->code4=0;
   elem->code5=0;
   elem->code6=3;
   elem->residu_rms=0;
   strcpy(elemok.designation,"");
   elemok.m0=PB;
   elemok.jj_m0=PB;
   elemok.e=PB;
   elemok.q=PB;
   elemok.jj_perihelie=PB;
   elemok.i=PB;
   elemok.o=PB;
   elemok.w=PB;
   elemok.jj_equinoxe=PB;
   elemok.jj_epoque=PB;
   elemok.type=PB;
   elemok.h0=PB;
   elemok.n=PB;
   elemok.h=PB;
   elemok.g=PB;
   elemok.nbjours=PB;
   elemok.nbobs=PB;
   elemok.ceu0=PB;    /* correspond a n */
   elemok.ceut=PB;    /* correspond a a */
   elemok.jj_ceu0=PB;
   elemok.code1=PB;
   elemok.code2=PB;
   elemok.code3=PB;
   elemok.code4=PB;
   elemok.code5=PB;
   elemok.code6=PB;
   elemok.residu_rms=PB;
   memset(elem->designation,' ',13);elem->designation[13]='\0';
   check=PB;
   *concordance=PB;
   kligfin=*ligfin;
   for (k=1;k<=(kligfin-1);k++) {
      if (fgets(ligne,120,fichier_in)!=NULL) {
         lig++;
      }
   }
   do {
      if (fgets(ligne,120,fichier_in)!=NULL) {
         lig++;
         /*printf("[%d]%s",lig,ligne);getch();*/
         len=strlen(ligne);
         /* --- supprime le caractere de controle final ---*/
         for (design=PB,k=1;k<=len;k++) {
            if ((ligne[k]==13)||(ligne[k]==10)) {
               ligne[k]='\0';
            } else if (ligne[k]!=' ') {
               design=OK;
            }
         }
         /* --- identifie le mot "Epoch " --- */
         strcpy(texte3,"Epoch ");
         mc_mpec_datejj(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.jj_epoque==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->jj_epoque=atof(texte2);
               elemok.jj_epoque=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "T " --- */
         strcpy(texte3,"T ");
         mc_mpec_datejj(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.jj_perihelie==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->jj_perihelie=atof(texte2);
               elemok.jj_perihelie=OK;
               elem->jj_m0=elem->jj_epoque;
               elemok.jj_m0=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "Perihelion " --- */
         strcpy(texte3,"Perihelion ");
         mc_mpec_datejj(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.jj_perihelie==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->jj_perihelie=atof(texte2);
               elemok.jj_perihelie=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "Peri. " --- */
         strcpy(texte3,"Peri. ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.w==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->w=atof(texte2)*(DR);
               elemok.w=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "Node " --- */
         strcpy(texte3,"Node ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.o==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->o=atof(texte2)*(DR);
               elemok.o=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "Incl. " --- */
         strcpy(texte3,"Incl. ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.i==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->i=atof(texte2)*(DR);
               elemok.i=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "a " --- */
         strcpy(texte3,"a ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.ceut==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->ceut=atof(texte2);
               elemok.ceut=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "e " --- */
         strcpy(texte3,"e ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.e==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->e=atof(texte2);
               elemok.e=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "n " --- */
         strcpy(texte3,"n ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.ceu0==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->ceu0=atof(texte2);
               elemok.ceu0=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "q " --- */
         strcpy(texte3,"q ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.q==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->q=atof(texte2);
               elemok.q=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "M " --- */
         strcpy(texte3,"M ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.m0==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->m0=atof(texte2)*(DR);
               elemok.m0=OK;
               elem->jj_m0=elem->jj_epoque;
               elemok.jj_m0=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "H " --- */
         strcpy(texte3,"H ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.h==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->h=atof(texte2);
               elem->h0=atof(texte2);
               elemok.h=OK;
               elemok.h0=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "G " --- */
         strcpy(texte3,"G ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.g==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->g=atof(texte2);
               elemok.g=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "From " ---*/
         strcpy(texte3,"From ");
         mc_mpec_argnum(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.nbobs==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               elem->nbobs=atoi(texte2);
               elemok.nbobs=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- identifie le mot "observations " ---*/
         strcpy(texte3,"observations ");
         mc_mpec_datesjjjj(ligne,texte3,texte1,texte2);
         if (strcmp(texte2,"")!=0) {
            if (elemok.jj_ceu0==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
               jj1=atof(texte1);
               jj2=atof(texte2);
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
               elemok.jj_ceu0=OK;
            }
         }
	 /* --- identifie le mot "BowellCodes " ---*/
         strcpy(texte3,"BowellCodes ");
	 mc_mpec_argbowell(ligne,texte3,texte2);
         if (strcmp(texte2,"")!=0) {
	    if (elemok.code1==OK) {
               if (check==OK) {*concordance=OK;check=OKOK;}break;
            } else {
               *ligfin=lig;type=TYPE_MPEC1;
	       sscanf(texte2,"%d %d %d %d %d %d",&elem->code1,&elem->code2,&elem->code3,&elem->code4,&elem->code5,&elem->code6);
               elemok.code1=OK;
               elemok.code2=OK;
               elemok.code3=OK;
               elemok.code4=OK;
               elemok.code5=OK;
               elemok.code6=OK;
               ligdeb=(ligdeb==0)?lig:ligdeb;
               mc_mpec_check(elem,&elemok,&check);
            }
         }
         /* --- designation de l'astre (a laisser a la fin) des types MPEC1 ---*/
         if ((ligdeb==0)&&(design==OK)) {
            strcpy(elem->designation,ligne);
         }
      }
   } while (feof(fichier_in)==0);
   check=OKOK;
   if (type==TYPE_MPEC1) {
      mc_mpec_check(elem,&elemok,&check);
      if ((jj1!=0)&&(jj2!=0)) {
         elem->nbjours=(int) (1+floor(jj2-jj1));
         elem->ceu0=0;
         a=jj2-jj1;
         if (a!=0) {
            elem->ceut=1./a;
         } else {
            elem->ceut=45000;
         }
         elem->jj_ceu0=jj1;
      }
   }
   *ligfin=(*ligfin)+1;
   fclose(fichier_in);
}

void mc_mpec_check(struct elemorb *elem,struct elemorb *elemok,int *check)
/***************************************************************************/
/* Verifie la coherence des elements d'orbites deja lus et retourne un     */
/* *check=OK pour arreter la lecture des elements dans le fichier          */
/***************************************************************************/
/* Ajoute les redondances d'elements si check=OKOK en entree               */
/***************************************************************************/
{
   double e,n,a,q;
   int check_aqn=PB,check_tq=PB,check_orb=PB;

   if ((elemok->jj_epoque==OK)&&(elemok->i==OK)&&(elemok->o==OK)&&(elemok->w==OK)&&(elemok->e==OK)) {
      check_orb=OK;
   }
   if ((elemok->q==OK)||(elemok->ceu0==OK)||(elemok->ceut==OK)) {
      check_aqn=OK;
   }
   if ((elemok->jj_perihelie==OK)&&((elemok->m0==PB)||(elemok->jj_m0==PB))) {
      check_tq=OK;
   /*} else if ((elemok->m0==OK)&&(elem->jj_m0==OK)&&(n!=0)) {*/
   } else if ((elemok->m0==OK)&&(elem->jj_m0==OK)) {
      check_tq=OK;
   }
   if (*check==PB) {
      if ((check_orb==OK)&&(check_aqn==OK)&&(check_tq==OK)) {
         *check=OK;
      }
   }
   if (*check==OKOK) {
      e=elem->e;
      n=0;
      /* --- calcul de q et de n ---*/
      if (elemok->q==OK) {
         q=elem->q;
         if (e==1) {
            n=K/(DR)/q/sqrt(2*q);
            a=0;
         } else {
            a=q/fabs(1-e);
            n=K/(DR)/a/sqrt(a);
         }
      } else if (elemok->ceu0==OK) {
         n=elem->ceu0;
         if (elem->e==1) {
            elem->q=pow((K/(n*DR)/sqrt(2)),(2/3));
            elemok->q=OK;
         } else {
            a=pow((K)/n/(DR),1/1.5);
            elem->q=a*fabs(1-elem->e);
            elemok->q=OK;
         }
      } else if (elemok->ceut==OK) {
         a=elem->ceut;
         n=K/(DR)/a/sqrt(a);
         elem->q=a*fabs(1-elem->e);
         elemok->q=OK;
      }
      /* --- calcul de M TM(jj_m0) Tq(jj_periehlie) ---*/
      if ((elemok->jj_perihelie==OK)&&((elemok->m0==PB)||(elemok->jj_m0==PB))) {
         elem->m0=0;
         elemok->m0=OK;
         elem->jj_m0=elem->jj_perihelie;
         elemok->jj_m0=OK;
      } else if ((elemok->m0==OK)&&(elemok->jj_m0==OK)&&(n!=0)) {
         elem->jj_perihelie=elem->jj_m0-elem->m0/n/(DR);
         elemok->jj_perihelie=OK;
      }
      elem->jj_equinoxe=J2000;
      elemok->jj_equinoxe=OK;
      if (elemok->code1==PB) {
	 mc_elemtype(elem);
      }
   }
}

void mc_mpec_datesjjjj(char *ligne, char *motcle,char *argument1,char *argument2)
/***************************************************************************/
/* Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans    */
/* "argument1" la premiere date trouvee immediatement apres "motcle" et    */
/* "argument2" la deuxieme date trouvee immediatement apres la premiere.   */
/***************************************************************************/
/* On peut ainsi decoder les dates des circulaires MPEC comme par exemple  */
/* >From 21 observations 1997 Dec. 8-Dec. 9.                               */
/* il suffit de mettre *motcle="observations"                              */
/***************************************************************************/
{
   char *car,motcle2[120];
   int col1,col2=0,aa=2000,mm=1;
   double j=1,jj1,jj2;
   strcpy(argument1,"");
   strcpy(argument2,"");
   mc_strupr(ligne,ligne);
   mc_strupr(motcle,motcle);
   car=strstr(ligne,motcle);
   col1=car-ligne+1;
   if (car!=NULL) {
      col1+=strlen(motcle);
      strcpy(motcle2,"-");
      car=strstr(ligne,motcle2);
      if (car!=NULL) {
         col2=car-ligne+1;
         col2-=1;strncpy(argument2,ligne+col1-1,col2-col1+1);*(argument2+col2-col1+1)='\0';
      }
      mc_mpec_t2amj(argument2,&aa,&mm,&j);
      /*printf("date1 <%s> -> %d/%d/%f\n",argument2,aa,mm,j);*/
      mc_date_jd(aa,mm,j,&jj1);
      mc_fstr(jj1,PBB,7,7,OK,argument1);
      col1=col2+2;
      col2=strlen(ligne);
      strncpy(argument2,ligne+col1-1,col2-col1+1);*(argument2+col2-col1+1)='\0';
      mc_mpec_t2amj(argument2,&aa,&mm,&j);
      /*printf("date2 <%s> -> %d/%d/%f\n",argument2,aa,mm,j);*/
      mc_date_jd(aa,mm,j,&jj2);
      mc_fstr(jj2,PBB,7,7,OK,argument2);
   }
}

void mc_mpec_datejj(char *ligne, char *motcle,char *argument)
/***************************************************************************/
/* Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans    */
/* "argument" la premiere date trouvee immediatement apres "motcle".       */
/***************************************************************************/
/* La date est recherchee apres le mot cle selon l'ordre suivant :         */
/* 1) jour julien qui suit "JTD ", sinon                                   */
/* 2) la date en clair qui precede "TT".                                   */
/* Argument est le jour julien qui correspond a la date recherchee.        */
/* Ne tient pas compte des majuscules et minuscules.                       */
/* argument="" si l'occurence n'est pas trouvee                            */
/***************************************************************************/
{
   char *car,motcle2[120];
   int col1,col2,aa,mm;
   double j,jj;
   mc_strupr(ligne,ligne);
   mc_strupr(motcle,motcle);
   car=strstr(ligne,motcle);
   col1=car-ligne+1;
   if (car!=NULL) {
      strcpy(motcle2,"JDT ");
      car=strstr(ligne,motcle2);
      if (car!=NULL) {
         col1=car-ligne+1;
         col1+=strlen(motcle2);
         col2=col1+9;strncpy(argument,ligne+col1-1,col2-col1+1);*(argument+col2-col1+1)='\0';
      } else {
         col1+=strlen(motcle);
         strcpy(motcle2,"TT");
         car=strstr(ligne,motcle2);
         col2=car-ligne+1;
         strcpy(argument,"");
         if (car!=NULL) {
            col2-=1;strncpy(argument,ligne+col1-1,col2-col1+1);*(argument+col2-col1+1)='\0';
         }
         aa=2000;
         mm=1;
         j=1;
         mc_mpec_t2amj(argument,&aa,&mm,&j);
         mc_date_jd(aa,mm,j,&jj);
         mc_fstr(jj,PBB,7,7,OK,argument);
      }
   } else {
      strcpy(argument,"");
   }
}

void mc_mpec_argnum(char *ligne, char *motcle,char *argument)
/***************************************************************************/
/* Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans    */
/* "argument" le premier nombre trouve immediatement apres "motcle".       */
/***************************************************************************/
/* Ne tient pas compte des majuscules et minuscules.                       */
/* argument="" si l'occurence n'est pas trouvee                            */
/* Le mot cle doit se situer en debut de ligne ou derriere un espace ou    */
/* apres un signe > (reply internet).                                      */
/***************************************************************************/
{
   char *car,carp;
   int k,col1,col2=0,deb,fin;
   mc_strupr(ligne,ligne);
   mc_strupr(motcle,motcle);
   car=strstr(ligne,motcle);
   col1=car-ligne;
   carp=' ';
   if ((col1>=1)&&(car!=NULL)) {
      carp=ligne[col1-1];
   }
   if ((car!=NULL)&&((carp==' ')||(carp=='>'))) {
      deb=col1+strlen(motcle);
      fin=strlen(ligne)-1;
      for (col1=1+strlen(ligne),k=deb;k<=fin;k++) {
	 if ((ligne[k]=='.')||(ligne[k]=='+')||(ligne[k]=='-')||((ligne[k]>='0')&&(ligne[k]<='9'))) {
            col1=k;
            break;
         }
      }
      for (k=col1;k<=fin;k++) {
         if ((ligne[k]=='.')||((ligne[k]>='0')&&(ligne[k]<='9'))) {
            col2=k;
         } else {
            break;
         }
      }
      if (col1<=fin) {
         strncpy(argument,ligne+col1,col2-col1+1);*(argument+col2-col1+1)='\0';
      } else {
         strcpy(argument,"");
      }
   } else {
      strcpy(argument,"");
   }
}

void mc_mpec_argbowell(char *ligne, char *motcle,char *argument)
/***************************************************************************/
/* Recherche la chaine "motcle" dans la chaine "ligne" et retourne dans    */
/* "argument" les 6 nombres trouve immediatement apres "motcle".           */
/***************************************************************************/
/* Ne tient pas compte des majuscules et minuscules.                       */
/* argument="" si l'occurence n'est pas trouvee                            */
/* Le mot cle doit se situer en debut de ligne ou derriere un espace ou    */
/* apres un signe > (reply internet).                                      */
/***************************************************************************/
{
   char *car,carp;
   int k,col1,col2,deb,fin,nbarg=6,indice,col11;
   mc_strupr(ligne,ligne);
   mc_strupr(motcle,motcle);
   car=strstr(ligne,motcle);
   col1=car-ligne;
   carp=' ';
   if ((col1>=1)&&(car!=NULL)) {
      carp=ligne[col1-1];
   }
   if ((car!=NULL)&&((carp==' ')||(carp=='>'))) {
      deb=col1+strlen(motcle);
      fin=strlen(ligne)-1;
      indice=0;
      col11=fin+1;
      col2=deb-1;
      do {
	 for (col1=1+strlen(ligne),k=col2+1;k<=fin;k++) {
	    if ((ligne[k]=='+')||(ligne[k]=='-')||((ligne[k]>='0')&&(ligne[k]<='9'))) {
	       col1=k;
	       indice++;
	       break;
	    }
	 }
	 if (indice==1) {
	    col11=col1;
	 }
	 for (k=col1;k<=fin;k++) {
	    if ((ligne[k]=='.')||((ligne[k]>='0')&&(ligne[k]<='9'))) {
	       col2=k;
	    } else {
	       break;
	    }
	 }
      } while ((indice<nbarg)&&(k<fin));
      if ((col11<=fin)&&(indice==nbarg)) {
	 strncpy(argument,ligne+col11,col2-col11+1);*(argument+col2-col11+1)='\0';
      } else {
	 strcpy(argument,"");
      }
   } else {
      strcpy(argument,"");
   }
}

void mc_mpec_t2amj(char *texte, int *annee, int *mois, double *jour)
/***************************************************************************/
/* Convertit une date d'une variable texte en trois composantes A/M/J      */
/***************************************************************************/
/* par exemple "1997 Nov. 30" donnera 1997 11 30.                          */
/* par exemple "Nov. 18" donnera 1997 11 18 si *annee=1997                 */
/* par exemple "18" donnera 1997 11 18 si *annee=1997 *mois=11             */
/* On peut ainsi decoder les dates des circulaires MPEC comme par exemple  */
/* >From 21 observations 1997 Dec. 8-Dec. 9.                               */
/***************************************************************************/
{
   int k,col1,col2,len;
   char texte2[40],num1[40],num2[40],str1[40];
   mc_strupr(texte,texte);
   len=strlen(texte);
   if (len>40) { len=40; }
   strcpy(num1,"");
   strcpy(num2,"");
   strcpy(str1,"");
   for (k=0;k<=len;k++) {
      /* --- detection d'un nombre --- */
      if ((texte[k]>='0')&&(texte[k]<='9')) {
         /*detection du debut d'un nombre*/
         col1=1+k;
         col2=1+k;
         for (k=col1+1;k<=len;k++) {
            if (((texte[k]<'0')||(texte[k]>'9'))&&(texte[k]!='.')) {
               /*detection de la fin du nombre*/
               col2=k;
               break;
            }
         }
         strncpy(texte2,texte+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
         if (strcmp(num1,"")==0) {
            strcpy(num1,texte2);
         } else if (strcmp(num2,"")==0) {
            strcpy(num2,texte2);
         }
      }
      /* --- detection d'un mot --- */
      if ((texte[k]>='A')&&(texte[k]<='Z')) {
         /*detection du debut de la chaine*/
         col1=1+k;
         col2=1+k;
         for (k=col1+1;k<=len;k++) {
            if ((texte[k]<'A')||(texte[k]>'Z')) {
               /*detection de la fin de la chaine*/
               col2=k;
               break;
            }
         }
         strncpy(texte2,texte+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
         if (strcmp(str1,"")==0) {
            strcpy(str1,texte2);
         }
      }
   }
   /* --- analyse de la date ---*/
   if (strcmp(num1,"")==0) {
      return;
   }
   if (strcmp(num2,"")==0) {
      *jour=atof(num1);
   } else {
      *annee=atoi(num1);
      *jour=atof(num2);
   }
   if (strcmp(str1,"")!=0) {
      str1[3]='\0';
      if (strcmp(str1,"JAN")==0) {*mois=1;}
      if (strcmp(str1,"FEB")==0) {*mois=2;}
      if (strcmp(str1,"MAR")==0) {*mois=3;}
      if (strcmp(str1,"APR")==0) {*mois=4;}
      if (strcmp(str1,"MAY")==0) {*mois=5;}
      if (strcmp(str1,"JUN")==0) {*mois=6;}
      if (strcmp(str1,"JUL")==0) {*mois=7;}
      if (strcmp(str1,"AUG")==0) {*mois=8;}
      if (strcmp(str1,"SEP")==0) {*mois=9;}
      if (strcmp(str1,"OCT")==0) {*mois=10;}
      if (strcmp(str1,"NOV")==0) {*mois=11;}
      if (strcmp(str1,"DEC")==0) {*mois=12;}
   }
}

void mc_mpec_jjjjdates(double jj1, double jj2, char *texte)
/***************************************************************************/
/* Convertit un JJ en une variable texte en trois composantes A/M/J MPEC   */
/***************************************************************************/
/* Si jj2=PB alors on ne convertit que jj1 avec un jour decimal sinon on   */
/* convertit les deux jj1 et jj2 au format MPC avec des jours entiers.     */
/***************************************************************************/
{
   int annee1,mois1,annee2,mois2,jjour1,jjour2;
   double jour1,jour2;
   char texte1[80],texte2[80];
   mc_jd_date(jj1,&annee1,&mois1,&jour1);
   mc_mpec_mois(mois1,texte1);
   sprintf(texte,"%d %s %f",annee1,texte1,jour1);
   if (jj2!=PB) {
      mc_jd_date(jj2,&annee2,&mois2,&jour2);
      mc_mpec_mois(mois2,texte2);
      jjour1=(int) (floor(jour1));
      jjour2=(int) (floor(jour2));
      if (annee1!=annee2) {
         sprintf(texte,"%d %s %d-%d %s %d",annee1,texte1,jjour1,annee2,texte2,jjour2);
         return;
      } else if (mois1!=mois2) {
         sprintf(texte,"%d %s %d-%s %d",annee1,texte1,jjour1,texte2,jjour2);
         return;
      } else {
         sprintf(texte,"%d %s %d-%d",annee1,texte1,jjour1,jjour2);
         return;
      }
   }
}

void mc_mpec_mois(int mois,char *texte)
/***************************************************************************/
/* Convertit un mois en une variable texte MPEC                            */
/***************************************************************************/
{
   if (mois== 1) {strcpy(texte,"Jan.");}
   if (mois== 2) {strcpy(texte,"Feb.");}
   if (mois== 3) {strcpy(texte,"Mar.");}
   if (mois== 4) {strcpy(texte,"Apr.");}
   if (mois== 5) {strcpy(texte,"May");}
   if (mois== 6) {strcpy(texte,"Jun.");}
   if (mois== 7) {strcpy(texte,"Jul.");}
   if (mois== 8) {strcpy(texte,"Aug.");}
   if (mois== 9) {strcpy(texte,"Sep.");}
   if (mois==10) {strcpy(texte,"Oct.");}
   if (mois==11) {strcpy(texte,"Nov.");}
   if (mois==12) {strcpy(texte,"Dec.");}
}
