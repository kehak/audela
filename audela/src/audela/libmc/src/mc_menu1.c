/* mc_menu1.c
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
/* Gestion des choix de calcul de MC                                       */
/***************************************************************************/
#include "mc.h"

void mc_entree(struct mcvar *param)
/***************************************************************************/
{
   mc_paramjj(param->date1,"aaaammjj",&param->jj1);
   mc_paramjj(param->date2,"aaaammjj",&param->jj2);
   switch (param->choix)
   {
      case 11:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 1. methode MVC 2 observations (orbite de Vaisala,      */
         /*    distance contrainte)                                */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* reel1   : valeur de la distance Terre-Astre (en ua)    */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         mc_macro11(param->chaine1,param->reel1,param->chaine2);
         break;
      case 12:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 2. methode MVC 2 observations (orbite de Vaisala,      */
         /*    grand axe contraint                                 */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* reel1   : valeur du demi grand axe de l'orbite (en ua) */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         mc_macro12(param->chaine1,param->reel1,param->chaine2);
         break;
      case 13:
         /*********************************************************/
         /* 1. observations -> elements d'orbite                  */
         /* 3. methode MVC 2 observations (orbite circulaire)     */
         /*********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC */
         /* chaine2 : nom du fichier de sortie des elements       */
         /*********************************************************/
         mc_macro13(param->chaine1,param->chaine2);
         break;
      case 14:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 4. methode GEM 3/2 observations                        */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* reel1   : offset de courbure en arcsec (+/- 0)         */
         /* reel2   : offset de longitude en arcsec (+/- 0)        */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         mc_macro14(param->chaine1,param->reel1,param->reel2,param->chaine2);
         break;
      case 15:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 5. methode GEM 3 observations                          */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         mc_macro15(param->chaine1,param->chaine2);
         break;
      case 16:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 6. methode MVC 3 observations (algorithme AA)          */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         mc_macro16(param->chaine1,param->chaine2);
         break;
      case 17:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 7. traitement automatique d'un lot d'observations      */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         mc_macro17(param->chaine1,param->chaine2);
         break;
      case 18:
         /**********************************************************/
         /* 1. observations -> elements d'orbite                   */
         /* 8. methode MVC 3 observations (algorithme B)           */
         /**********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC  */
         /* chaine2 : nom du fichier de sortie des elements        */
         /**********************************************************/
         mc_macro18(param->chaine1,param->chaine2);
         break;
      case 19:
         /***********************************************************/
         /* 1. observations -> elements d'orbite                    */
         /* 9. methode MVC 2 observations (excentricite contrainte) */
         /***********************************************************/
         /* chaine1 : nom du fichier d'observations au format MPC   */
         /* reel1   : valeur de l'excentricite                      */
         /* chaine2 : nom du fichier de sortie des elements         */
         /***********************************************************/
         mc_macro19(param->chaine1,param->reel1,param->chaine2);
         break;
      case 21:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 1. base de Bowell -> format MC                             */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* chaine2 : numero d'identification de l'asteroide           */
         /* chaine3 : nom du fichier de sortie des elements d'orbite   */
         /**************************************************************/
         mc_macro21(param->chaine1,param->chaine2,param->chaine3);
         break;
      case 22:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 2. format MPEC Daily Orbit Update -> format MC             */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MPEC D.O.U.             */
         /* chaine2 : nom du fichier au format MC                      */
         /**************************************************************/
         mc_macro22(param->chaine1,param->chaine2);
         break;
      case 23:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 3. format MPEC -> format MC                                */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MPEC                    */
         /* chaine2 : nom du fichier au format MC                      */
         /**************************************************************/
         mc_macro23(param->chaine1,param->chaine2);
         break;
      case 24:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 4. format MC -> format MPEC Daily Orbit Update             */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MC                      */
         /* chaine2 : nom du fichier au format MPEC D.O.U.             */
         /**************************************************************/
         mc_macro24(param->chaine1,param->chaine2);
         break;
      case 25:
         /**************************************************************/
         /* 2. conversion de formats d'elements d'orbite               */
         /* 5. format MC -> format MPEC                                */
         /**************************************************************/
         /* chaine1 : nom du fichier au format MC                      */
         /* chaine2 : nom du fichier au format MPEC                    */
         /**************************************************************/
         mc_macro25(param->chaine1,param->chaine2);
         break;
      case 31:
         /*************************************************************/
         /* 3. changement d'epoque des elements d'orbite par          */
         /*    integration numerique                                  */
         /* 1. changement d'epoque par la methode de Cowell           */
         /*************************************************************/
         /* chaine1 : nom du fichier d'entree des elements d'orbite   */
         /* date1   : date de l'epoque a calculer (aaaammjj)          */
         /* chaine2 : nom du fichier de sortie des elements d'orbite  */
         /*************************************************************/
         mc_macro31(param->chaine1,param->jj1,param->chaine2);
         break;
      case 41:
         /***********************************************************/
         /* 4. elements d'orbite -> ephemeride d'un astre           */
         /*    par probleme a deux corps                            */
         /* 1. ephemeride entre deux dates                          */
         /***********************************************************/
         /* chaine1 : nom du fichier des elements d'orbite          */
         /* date1   : code du premier jour d'observation (aaaammjj) */
         /* date2   : code du dernier jour d'observation (aaaammjj) */
         /* reel1   : pas de calcul (en fraction de jours)          */
         /* chaine2 : nom du fichier de sortie de l'ephemeride      */
         /***********************************************************/
         mc_macro41(param->chaine1,param->jj1,param->jj2,param->reel1,param->chaine2);
         break;
      case 42:
         /***********************************************************/
         /* 4. elements d'orbite -> ephemeride d'un astre           */
         /*    par probleme a deux corps                            */
         /* 2. ephemeride pour une date et variation du perihelie   */
         /***********************************************************/
         /* chaine1 : nom du fichier des elements d'orbite          */
         /* date1   : code du jour d'observation (aaaammjj)         */
         /* reel1   : heure TU de l'observation (hh.mmss)           */
         /* reel2   : etendue de variation de Tq (en jours)         */
         /* reel3   : pas de variation de Tq (en fraction de jours) */
         /* date2   : date de l'equinoxe de calcul                  */
         /* chaine2 : nom du fichier de sortie de l'ephemeride      */
         /***********************************************************/
         mc_macro42(param->chaine1,param->jj1,param->reel1,param->reel2,param->reel3,param->jj2,param->chaine2);
         break;
      case 43:
         /***********************************************************/
         /* 4. elements d'orbite -> ephemeride d'un astre           */
         /*    par probleme a deux corps                            */
         /* 3. ephemeride d'un lot d'astres entre deux dates        */
         /***********************************************************/
         /* chaine1 : nom du fichier des elements d'orbite          */
         /* date1   : code du premier jour d'observation (aaaammjj) */
         /* date2   : code du dernier jour d'observation (aaaammjj) */
         /* reel1   : pas de calcul (en fraction de jours)          */
         /* chaine2 : nom du fichier de sortie de l'ephemeride      */
         /***********************************************************/
         mc_macro43(param->chaine1,param->jj1,param->jj2,param->reel1,param->chaine2);
         break;
      case 51:
         /***************************************************************/
         /* 5. elements d'orbite -> ephemeride d'un astre               */
         /*    par integration numerique                                */
         /* 1. element d'orbite -> ephemeride par la methode de Cowell  */
         /***************************************************************/
         /* chaine1 : nom du fichier des elements d'orbite              */
         /* date1   : code du premier jour d'observation (aaaammjj)     */
         /* date2   : code du dernier jour d'observation (aaaammjj)     */
         /* reel1   : pas de calcul (en fraction de jours)              */
         /* chaine2 : nom du fichier de sortie de l'ephemeride          */
         /***************************************************************/
         mc_macro51(param->chaine1,param->jj1,param->jj2,param->reel1,param->chaine2);
         break;
      case 61:
         /**************************************************************/
         /* 6. utilitaires (fichiers, etc...)                          */
         /* 1. simplification de la base de Bowell                     */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* chaine2 : nom du fichier de sortie                         */
         /**************************************************************/
         mc_macro61(param->chaine1,param->chaine2);
         break;
      case 62:
	 /**************************************************************/
	 /* 6. utilitaires (fichiers, etc...)                          */
	 /* 2. calculs automatiques de paradist                        */
	 /**************************************************************/
	 /* chaine1 : nom du fichier d'entree (obs format MPC)         */
	 /* chaine2 : nom du fichier d'elements d'orbite               */
	 /* chaine3 : nom du fichier de sortie                         */
	 /**************************************************************/
	 mc_macro62(param->chaine1,param->chaine2,param->chaine3);
	 break;
      case 63:
	 /**************************************************************/
	 /* 6. utilitaires (fichiers, etc...)                          */
	 /* 3. conversion latitude-altitude en rhocosphi'-rhosinphip   */
	 /**************************************************************/
	 /* reel1 : valeur de la latitude (degres)                     */
	 /* reel2 : valeur de l'altitude (en metres)                   */
	 /**************************************************************/
	 mc_macro63(param->reel1,param->reel2);
	 break;
      case 64:
	 /**************************************************************/
	 /* 6. utilitaires (fichiers, etc...)                          */
	 /* 4. conversion rhocosphi'-rhosinphip en latitude-altitude   */
	 /**************************************************************/
	 /* reel1 : valeur de rhocosphip'                              */
	 /* reel2 : valeur de rhosinphip'                              */
	 /**************************************************************/
	 mc_macro64(param->reel1,param->reel2);
	 break;
      case 71:
         /**************************************************************/
         /* 7. base de Bowell -> ephemerides quotidiennes d'asteroides */
         /* 1. selection par des criteres par defaut                   */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* date1   : code du premier jour d'observation (aaaammjj)    */
         /* date2   : code du dernier jour d'observation (aaaammjj)    */
         /**************************************************************/
         mc_macro71(param->chaine1,param->jj1,param->jj2);
         break;
      case 72:
         /***********************************************************************/
         /* 7. base de Bowell -> ephemerides quotidiennes d'asteroides          */
         /* 2. selection par des criteres manuels                               */
         /***********************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat)          */
         /* date1   : code du premier jour d'observation (aaaammjj)             */
         /* date2   : code du dernier jour d'observation (aaaammjj)             */
         /* reel1   : limite de la magnitude minimum                            */
         /* reel2   : limite de la magnitude maximum                            */
         /* reel3   : limite en elongation                                      */
         /* reel4   : limite de la declinaison minimum                          */
         /* reel5   : limite de la declinaison maximum                          */
         /* reel6   : limite de l'incertitude minimum                           */
         /* reel7   : limite de l'incertitude maximum                           */
         /* entier1 : flag1 :  =0  par defaut                                   */
         /*                 : +=1  calculer les asteroides numerotes            */
         /*                 : +=2  calculer les asteroides provisoires          */
         /* entier2 : flag2 :  =0  pour calculer tous les types d'orbite, sinon */
         /*                 : +=2  asteroides lointains                         */
         /*                 : +=4  asteroides troyens                           */
         /*                 : +=8  Mars crossers                                */
         /*                 : +=16 Earth Grazers                                */
         /*                 : +=32 Earth Crossers                               */
         /* entier3 : flag3 :  =0  tous les types d'incertitude                 */
         /*                 : +=2  critical list                                */
         /*                 : +=4  orbites a ameliorer                          */
         /*                 : +=8  asteroides a explorer ou mesure de la masse  */
         /***********************************************************************/
         mc_macro72(param->chaine1,param->jj1,param->jj2,param->reel1,param->reel2,param->reel3,param->reel4,param->reel5,param->reel6,param->reel7,param->entier1,param->entier2,param->entier3);
         break;
      case 81:
         /**************************************************************/
         /* 8. base de Bowell -> asteroides dans un champ              */
         /* 1. tous les asteroides dans un champ circulaire            */
         /**************************************************************/
         /* chaine1 : nom du fichier de la base de Bowell (astorb.dat) */
         /* date1   : code du jour de l'observation (aaaammjj)         */
         /* reel1   : heure TU de l'observation (hh.mmss)              */
         /* reel2   : ascension droite J2000 du centre (hh.mmss)       */
         /* reel3   : declinaison J2000 du centre (+dd.''ss)           */
         /* reel4   : rayon du champ (arcmin)                          */
         /* chaine2 : nom du fichier de sortie                         */
         /**************************************************************/
         mc_macro81(param->chaine1,param->jj1,param->reel1,param->reel2,param->reel3,param->reel4,param->chaine2);
         break;
   }
}

void mc_paramjj(char *date,char *contrainte, double *jj)
/***************************************************************************/
{
   char ligne[80],texte[80];
   int col1,col2,a,m;
   double j,n;
   strcpy(ligne,date);
   if (strcmp(contrainte,"aaaammjj")==0) {
      if ((strlen(ligne)==8)&&(atoi(ligne)!=0)) {
         col1= 1;col2= 4;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
         a=atoi(texte);
         col1= 5;col2= 6;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
         m=atoi(texte);
         col1= 7;col2= 8;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
         j=(double) (atoi(texte));
         mc_date_jd(a,m,j,&n);
      } else {
         n=J2000;
      }
   }
   *jj=n;
}

