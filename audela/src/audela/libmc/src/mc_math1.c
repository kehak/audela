/* mc_math1.c
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
/* Utilitaires mathematiques                                               */
/***************************************************************************/
#include "mc.h"

void mc_fstr(double valeur, int signe, int nbint, int nbfrac,int zeros,char *chaine)
/***************************************************************************/
/* Formatage d'une chaine de sortie a partir d'une valeur numerique.       */
/***************************************************************************/
/* valeur : valeur numerique a formater                                    */
/* signe : =OK pour ajouter + ou - devant la chaine                        */
/*         =PBB pour ajouter ' ' ou - devant la chaine                     */
/*         =PB pour la valeur absolue                                      */
/* nbint : nombre de chiffres pour la partie entiere                       */
/* nbfrac : nombre de chiffres pour la partie decimale                     */
/* zeros  : =OK pour laisser les zeros devant sinon (=PB) des espaces      */
/***************************************************************************/
{
   double v,vint,vfrac,cstint,cstfrac;
   int s,dec,lon,k,ssigne;
   char chaines[3],chaine1[84],chaine2[84],chaine3[84],chainezero[84];

   /*--- test de depassement de chaine ---*/
   memset(chaine3,'-',83);chaine3[83]='\0';
   lon=0;
   if (signe==1) {
      lon+=1;
   }
   if (nbfrac>0) {
      lon+=1;
   }
   lon+=(nbint+nbfrac);
   if (lon>(int)(strlen(chaine3))) {
      memset(chaine3,'-',strlen(chaine3));chaine3[strlen(chaine3)]='\0';
      strcpy(chaine,chaine3);
      return;
   }

   /*--- constantes multiplicatives pour les parties entieres et decimales */
   cstint =pow(10,nbint ) ;
   cstfrac=pow(10,nbfrac) ;

   /*--- on traite le signe ---*/
   s=(int) (mc_sgn(valeur));
   if (signe==OK) {
      if (s>=0) { strcpy(chaines,"+"); } else { strcpy(chaines,"-"); }
   } else if (signe==PBB) {
      if (s>=0) { strcpy(chaines," "); } else { strcpy(chaines,"-"); }
   } else {
      strcpy(chaines,"");
   }

   /*--- on arondit la valeur tronquee ---*/
   v=fabs(valeur);
   vfrac=mc_frac(v*cstfrac);
   vint=floor(v*cstfrac);
   if (vfrac>=.5) {
      v=(vint+1.)/cstfrac;
   }

   /*--- on traite la partie entiere ---*/
   vint=floor(v);
   if (vint>=cstint) {
      vint=cstint-1;
   }
   vint+=cstint;
   strcpy(chaine1,fcvt(vint,nbint+2,&dec,&ssigne)+1);
   *(chaine1+nbint)='\0';
   if ((nbint>1)&&(zeros==PB)) {
      for (k=1;k<=nbint-1;k++) {
         if (chaine1[k-1]=='0') {
            if (signe==PB) {
               chaine1[k-1]=' ';
            } else {
               if (k==1) {
                  chaine1[k-1]=chaines[0];
                  chaines[0]=' ';
               } else {
                  chaine1[k-1]=chaine1[k-2];
                  chaine1[k-2]=' ';
               }
            }
         } else {
            break;
         }
      }
   }

   /*--- on traite la partie decimale ---*/
   if (nbfrac==0) {
      strcpy(chaine2,"");
   } else {
      vfrac=cstfrac+floor(mc_frac(v)*(cstfrac+.1));
      strcpy(chaine2,fcvt(vfrac,nbfrac+2,&dec,&ssigne)+1);
      memset(chainezero,'0',nbfrac);chainezero[nbfrac]='\0';
      strcat(chaine2,chainezero);
      *(chaine2+nbfrac)='\0';
   }

   /*--- creation de la chaine de sortie formatee ---*/
   strcpy(chaine3,chaines);
   strcat(chaine3,chaine1);
   if (nbfrac>0) {
      strcat(chaine3,".");
      strcat(chaine3,chaine2);
   }
   strcpy(chaine,chaine3);
   return;
}

double mc_deg(double valeur)
/***************************************************************************/
/* Calcul la valeur decimale a partir de la valeur d.ms                    */
/***************************************************************************/
{
   double x,y;
   int ss;
   if (valeur==0) { return(0); }
   x=fabs(valeur);
   ss=(int)(x/valeur);
   y=ss*(floor(x)+floor(mc_frac(x)*100)/60+mc_frac(x*100)/36);
   return(y);
}

double mc_dms(double valeur)
/***************************************************************************/
/* Calcul la valeur d.ms a partir de la valeur decimale.                   */
/***************************************************************************/
{
   double x,y;
   int ss;
   if (valeur==0) { return(0); }
   x=fabs(valeur);
   ss=(int)(x/valeur);
   y=ss*(floor(x)+floor(mc_frac(x)*60)/100+mc_frac(mc_frac(x)*60)*.006);
   return(y);
}

void mc_deg2d_m_s(double valeur,char *charsigne,int *d,int *m,double *s)
/***************************************************************************/
/* Calcul la valeur d.ms a partir de la valeur decimale.                   */
/***************************************************************************/
{
   double y,dd,mm,sss;
   y=valeur;
   if (y<0) {strcpy(charsigne,"-");} else {strcpy(charsigne,"+");}
   y=fabs(y);
   dd=floor(y);
   y=(y-dd)*60.;
   mm=floor(y);
   y=(y-mm)*60.;
   sss=y;
   if (sss>59.999999) {sss=59.999999;}
   *d=(int)(dd);
   *m=(int)(mm);
   *s=sss;
   return;
}

void mc_deg2h_m_s(double valeur,int *h,int *m,double *s)
/***************************************************************************/
/* Calcul la valeur h.ms a partir de la valeur decimale.                   */
/***************************************************************************/
{
   double y,dd,mm,sss,signe;
   y=valeur/15.;
   if (y<0) {signe=-1.;} else {signe=1.;}
   y=fabs(y);
   dd=floor(y);
   y=(y-dd)*60.;
   mm=floor(y);
   y=(y-mm)*60.;
   sss=y;
   if (sss>59.999999) {sss=59.999999;}
   *h=(int)(signe*dd);
   *m=(int)(mm);
   *s=sss;
   return;
}

double mc_frac(double x)
/***************************************************************************/
/* Calcul de la partie fractionnaire d'un nombre decimal.                  */
/***************************************************************************/
{
   return(x-floor(x));
}

void mc_prodscal(double x1, double y1,double z1, double x2,double y2,double z2, double *p)
/***************************************************************************/
/* Produit vectoriel de deux vecteurs                                      */
/***************************************************************************/
{
   double p0;
   p0=x1*x2+y1*y2+z1*z2;
   *p=p0;
}

void mc_prodvect(double x1, double y1,double z1, double x2,double y2,double z2, double *x3, double *y3, double *z3)
/***************************************************************************/
/* Produit vectoriel de deux vecteurs                                      */
/***************************************************************************/
{
   double x30,y30,z30;
   x30=y1*z2-z1*y2;
   y30=z1*x2-x1*z2;
   z30=x1*y2-y1*x2;
   *x3=x30;
   *y3=y30;
   *z3=z30;
}

double mc_sgn(double arg)
/***************************************************************************/
/* -1 si  arg<0                                                            */
/* +1 si  arg>=0                                                           */
/***************************************************************************/
{
   if (arg>=0) { return(1); }
   else {return(-1); }
}

double mc_sgn2(double arg)
/***************************************************************************/
/* +1 si  0<=arg<PI                                                        */
/* -1 si PI<=arg<2*PI                                                      */
/***************************************************************************/
{
   arg=fmod(arg,2*PI)-PI;
   return(mc_sgn(arg));
}

void mc_strupr(char *chainein, char *chaineout)
/***************************************************************************/
/* Fonction de mise en majuscules emulant strupr (pb sous unix)            */
/***************************************************************************/
{
   int len,k;
   char a;
   len=strlen(chainein);
   /*
   len2=strlen(chaineout);
   len=(len1<len2)?len1:len2;
   */
   for (k=0;k<=len;k++) {
      a=chainein[k];
      if ((a>='a')&&(a<='z')){chaineout[k]=(char)(a-32); }
      else {chaineout[k]=a; }
   }
}

double mc_acos(double x)
/***************************************************************************/
/* Fonction arccosinus evitant les problemes de depassement                */
/***************************************************************************/
{
   if (x>1.) {x=1.;}
   if (x<-1.) {x=-1;}
   return(acos(x));
}

double mc_asin(double x)
/***************************************************************************/
/* Fonction arcsinus evitant les problemes de depassement                  */
/***************************************************************************/
{
   if (x>1.) {x=1.;}
   if (x<-1.) {x=-1;}
   return(asin(x));
}

double mc_atan2(double y, double x)
/***************************************************************************/
/* Calcul de atan2 sans 'domain error'.                                    */
/***************************************************************************/
{
   if (y==0) {
      if (x>=0) { return(0.); }
      else { return(2.*acos(0.)); }
   } else if (x==0) {
      if (y>=0) { return(acos(0.)); }
      else { return(-acos(0.)); }
   } else {
      return(atan2(y,x));
   }
}

double mc_sqrt(double x)
/***************************************************************************/
/* Fonction sqrt evitant les problemes de negatif                          */
/***************************************************************************/
{
   if (x<0.) {x=0.;}
   return(sqrt(x));
}
