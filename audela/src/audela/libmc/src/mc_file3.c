/* mc_file3.c
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

void mc_lec_mpc_noms(char *nom_fichier_in,char *nom_fichier_noms)
/***************************************************************************/
/* Retourne un fichier texte contenant les noms et le nombre d'observations*/
/* pour chaque nom.                                                        */
/***************************************************************************/
{
   FILE *fichier_in,*fichier_out;
   char ligne[120],texte[120],texte2[120],designation[15];
   int len,n,k,col1,col2,premier;
   int nblignes,*checkligne,numligne;

   if (( fichier_in=fopen(nom_fichier_in,"r") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   if (( fichier_out=fopen(nom_fichier_noms,"wt") ) == NULL) {
      printf("fichier non trouve\n");
      return;
   }
   nblignes=0;
   do {
      if (fgets(ligne,120,fichier_in)!=NULL) {
         nblignes++;
      }
   } while (feof(fichier_in)==0);
   checkligne = (int *) calloc(nblignes+1,sizeof(int));
   do {
      rewind(fichier_in);
      numligne=0;
      n=0;
      strcpy(designation,"");
      premier=OK;
      do {
         if (fgets(ligne,120,fichier_in)!=NULL) {
            numligne++;
            if (checkligne[numligne]==0) {
               len=strlen(ligne);
               strcpy(texte,ligne);
               for (k=0;k<=len;k++) {
                  if (ligne[k]==' ') {
                     texte[k]=' ';
                  } else if (ligne[k]=='.') {
                     texte[k]='.';
                  } else if ((ligne[k]>='0')&&(ligne[k]<='9')) {
                     texte[k]='x';
                  } else {
                     texte[k]='a';
                  }
               }
               texte[k]='\0';
               if (strlen(texte)>=65) {
                  col1= 15;col2= 65;strncpy(texte2,texte+col1-1,col2-col1+1);*(texte2+col2-col1+1)='\0';
                  if (strcmp(texte2,"axxxx xx xx.xxxxx xx xx xx.xx axx xx xx.x          ")==0) {
                     memset(texte,' ',13);texte[13]='\0';
                     col1= 1;col2=12;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
                     if (strcmp(designation,texte)==0) {
			checkligne[numligne]=1;
                        n++;
                     } else {
			if (premier==OK) {
			   premier=PB;
			   strcpy(designation,texte);
			   n=1;
			   checkligne[numligne]=1;
			   fprintf(fichier_out,"%s ",designation);
			}
                     }
                  }
               }
            }
         }
      } while (feof(fichier_in)==0);
      if (n!=0) {fprintf(fichier_out,"%d\n",n);}
   } while (n!=0);
   free(checkligne);
   fclose(fichier_in);
   fclose(fichier_out);
}

