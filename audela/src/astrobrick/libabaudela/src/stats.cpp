/* stats.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#include <math.h>
#include <stdlib.h>
#include "stats.h"



/*
 * -----------------------------------------------------------------------------
 *  stat_miller(int longueur, TYPE_PIX *p, double *moyenne, double *sigma) --
 *
 *  Statistiques de sur un echantillon 'p' de longueur 'longueur" par l'
 *  algorithme progressif de MILLER. Si les pointeurs 'moyenne' et 'sigma"
 *  sont non NULL, alors leurs dereferences sont affectees par la moyenne
 *  et l'ecart-type.
 *
 *  Ne retourne rien.
 * -----------------------------------------------------------------------------
 */
void stat_miller(int longueur, TYPE_PIX *p, double *moyenne, double *sigma)
{
   double valeur, mu_i,mu_ii,sx_i,sx_ii,i, delta;
   double moy, sig; // valeurs locales

   valeur=(double)(p[0]);
   i=0.;
   mu_i=valeur;
   sx_i=0.;
   mu_ii=0.;
   sx_ii=0.;
   for (int k=1;k<=longueur-1;k++) {
      valeur=(double)(p[k]);
      i=(double) (k+1);
      delta=valeur-mu_i;
      mu_ii=mu_i+delta/(i);
      sx_ii=sx_i+delta*(valeur-mu_ii);
      mu_i=mu_ii;
      sx_i=sx_ii;
   }
   moy=mu_ii;
   sig=sqrt(sx_ii/i);
   if(moyenne!=NULL) *moyenne = moy;
   if(sigma!=NULL) *sigma = sig;
}


/*
 * -----------------------------------------------------------------------------
 *  stat_contours(TYPE_PIX *pix, int naxis1, int x1, int y1, int x2, int y2,
 *    double* m_c, double* s_c) --
 *
 *  Statistiques de un contours de l'image 'pix' donne par les coordonnees
 *  ('x1','y1") et ('x2','y2'). La largeur de l'image doit etre specifiee dans
 *  naxis1. Si les pointeurs 'moyenne' et 'sigma" sont non NULL, alors leurs
 *  dereferences sont affectees par la moyenne et l'ecart-type.
 *
 *  Attention : l'origine de l'image est prise en (0,0).
 *
 *  Retourne 0 si tout s'est bien passe, !=0 sinon.
 * -----------------------------------------------------------------------------
 */
int stat_contours(TYPE_PIX *pix, int naxis1, int x1, int y1, int x2, int y2, double* m_c, double* s_c)
{
   int w,h;
   TYPE_PIX *contours;
   int longueur_contours;
   double moy_con, sig_con;
   int n;
   int indice;
   int adr1, adr2;

   //--- Largeur et hauteur de la zone a analyser
   w = x2-x1+1;
   h = y2-y1+1;

   //--- Creation du contours de l'image
   longueur_contours = 2*(w-1)+(2*h-1);
   contours = (TYPE_PIX*)calloc(longueur_contours,sizeof(TYPE_PIX));

   if(contours==NULL) return 1;

   adr1 = y1 * naxis1;
   adr2 = y2 * naxis1;
   indice = 0;
   for(n=x1;n<=x2;n++) {
      contours[indice++] = *(pix+adr1+n);
      contours[indice++] = *(pix+adr2+n);
   }
   for(n=y1+1;n<y2;n++) {
      adr1 = n * naxis1;
      contours[indice++] = *(pix+adr1+x1);
      contours[indice++] = *(pix+adr1+x2);
   }

   //--- Calcul des stats sur le contours
   stat_miller(longueur_contours,contours,&moy_con,&sig_con);

   //--- Retour des données
   if(m_c!=NULL) *m_c = moy_con;
   if(s_c!=NULL) *s_c = sig_con;

   free(contours);

   return 0;
}



