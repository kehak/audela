/* mc_orbi3.c
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

void mc_orbi_auto(char *nom_fichier_obs,char *nom_fichier_ele)
/***************************************************************************/
/* Traitement automatique des observations d'un fichier qui contient les   */
/* les observations de plusieurs astres.                                   */
/* Le fichier de sortie contient les elements d'orbite les uns a la suite  */
/* des autres au format MPEC.                                              */
/***************************************************************************/
/***************************************************************************/
{
   char nom_fichier_noms[25],designation[15],texte2[120],ligne[120];
   FILE *fichier_nom;
   int len,col1,col2,nbobs1,nbobs2,nbobs3,type=WRITE,contrainte;
   struct observ *obs1,*obs2,*obs3;
   struct elemorb elem;
   double e=0.2,deltaj=0.8,t1,t2,t3;

   if (strcmp(nom_fichier_obs,nom_fichier_ele)==0) {return;}
   strcpy(nom_fichier_noms,"@names.txt");
   mc_lec_mpc_noms(nom_fichier_obs,nom_fichier_noms);
   nbobs1=0;
   obs1 = (struct observ *) calloc(nbobs1+1,sizeof(struct observ));
   mc_lec_obs_mpc(nom_fichier_obs,obs1,&nbobs1);
   free(obs1);
   nbobs3=3;
   obs3 = (struct observ *) calloc(nbobs3+1,sizeof(struct observ));
   obs1 = (struct observ *) calloc(nbobs1+1,sizeof(struct observ));
   mc_lec_obs_mpc(nom_fichier_obs,obs1,&nbobs1);
   if (( fichier_nom=fopen(nom_fichier_noms,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   do {
      if (fgets(ligne,120,fichier_nom)!=NULL) {
         len=strlen(ligne);
         col1= 1;col2= 12;strncpy(texte2,ligne+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
         strcpy(designation,texte2);
         col1= 14;col2=len;strncpy(texte2,ligne+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
         nbobs2=atoi(texte2);
         obs2 = (struct observ *) calloc(nbobs2+1,sizeof(struct observ));
         mc_select_observ(obs1,nbobs1,designation,obs2,&nbobs2);
         contrainte=3;
         mc_select32_observ(obs2,nbobs2,obs3,&nbobs3,contrainte);
         t1=obs3[1].jjtu;
         if (nbobs3==2) {
            t2=obs3[2].jjtu;
            if (fabs(t2-t1)<deltaj) {
               mc_mvc2b(obs3,&elem,obs3[1].jj_equinoxe);
            } else {
               mc_mvc2d(obs3,e,&elem,obs3[1].jj_equinoxe);
            }
         }
         if (nbobs3>=3) {
            t2=obs3[2].jjtu;
            t3=obs3[nbobs3].jjtu;
            if ((fabs(t3-t1)<deltaj)) {
               contrainte=2;
               mc_select32_observ(obs2,nbobs2,obs3,&nbobs3,contrainte);
               mc_mvc2b(obs3,&elem,obs3[1].jj_equinoxe);
            } else if ((fabs(t2-t1)<deltaj)||(fabs(t2-t3)<deltaj)) {
               contrainte=2;
               mc_select32_observ(obs2,nbobs2,obs3,&nbobs3,contrainte);
               mc_mvc2d(obs3,e,&elem,obs3[1].jj_equinoxe);
            } else {
               mc_gem3(obs3,&elem,obs3[1].jj_equinoxe);
            }
         }
         if (nbobs3>=2) {
	    mc_rms_obs(&elem,obs2,nbobs2);
            mc_determag(&elem,obs3,nbobs3);
            mc_affielem(elem);
            mc_wri_ele_mpec1(nom_fichier_ele,elem,type);
            if (type==WRITE) {type=APPEND;}
         }
      }
   } while (feof(fichier_nom)==0);
   free(obs1);
   free(obs3);
}

void mc_rms_obs(struct elemorb *elem, struct observ *obs, int nbobs)
/***************************************************************************/
/* calcule les ecarts o-c entre les asd/dec des observations et ceux prevus*/
/* par les elements d'orbite.                                              */
/* complete la valeur du residu RMS en arcsec pour l'ensemble des obs      */
/* dans elem.residu_rms.                                                   */
/***************************************************************************/
{
   double asd,dec,delta,rr,rsol,a,d,*ecart;
   double somme_ecart,mean_ecart;
   int k;
   somme_ecart=0;
   ecart = (double *) calloc(nbobs+1,sizeof(double));
   for (k=1;k<=nbobs;k++) {
      mc_adastrom(obs[k].jjtd,*elem,obs[k].jj_equinoxe,&asd,&dec,&delta,&rr,&rsol);
      obs[k].ecart_asd=obs[k].asd-asd;
      obs[k].ecart_dec=obs[k].dec-dec;
      a=obs[k].ecart_asd;
      d=obs[k].ecart_dec;
      ecart[k]=sqrt(a*a+d*d);
      somme_ecart+=ecart[k];
   }
   mean_ecart=somme_ecart/nbobs;
   somme_ecart=0;
   for (k=1;k<=nbobs;k++) {
      a=(ecart[k]-mean_ecart);
      somme_ecart+=(a*a);
   }
   d=(nbobs>1)? sqrt(somme_ecart/(nbobs-1)) : sqrt(somme_ecart);
   elem->residu_rms=(d/(DR)*3600);
   free(ecart);
}
