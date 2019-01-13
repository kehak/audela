/* tt_scri1.c
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

#include "tt.h"

int tt_script_2(void *arg1)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int msg,lentotal,lentotall,taille,nombre;
   char *ligne,*texte,*newligne;
   int nbcar,nbcarr,kdeb,nbvar,k,nb,len,*ident,kk,newlen,kkk;
   char *car,**varnames,**varvalues;
   int *index_deb,*index_fin,compteligne,kdebb;
   char chaine1[TT_LEN_VARNAME],chaine2[TT_LEN_VARNAME];
   char message[TT_MAXLIGNE];

   lentotal=strlen(arg1);
   ligne=NULL;
   index_deb=NULL;
   index_fin=NULL;
   ident=NULL;
   varnames=NULL;
   varvalues=NULL;
   ligne=NULL;
   texte=NULL;
   newligne=NULL;

   texte=(char*)(arg1);
   /*printf("%s\n===================\n",texte);*/

   tt_writelog("","===== Begin a process by script2 \n");
   /* --- variable globale pour le nom de fichiers temporaires ---*/   
   strcpy(tt_tmpfile_ext,"");
   /* === la premiere passe consiste a compter les variables ===*/
   nbvar=0;
   /* --- kdeb est l'indice de decalage absolu sur le texte ---*/
   kdeb=0;
   do {
      /* --- nbcar est le nombre de caracteres de la prochaine ligne ---*/
      car=strstr(texte+kdeb,"\n"); nbcar=0; if (car!=NULL) {nbcar=(int)(car-texte-kdeb);} else {nbcar=strlen(texte+kdeb);}
      ligne=NULL;
      nombre=nbcar+1;
      taille=sizeof(char);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ligne,&nombre,&taille,"ligne"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer ligne)");
         return(TT_ERR_PB_MALLOC);
      }
      /* --- extrait la nouvelle ligne ---*/
      strncpy(ligne,texte+kdeb,nbcar);
      ligne[nbcar]='\0';
      /* --- teste s'il s'agit de la definition d'une variable ---*/
      strcpy(chaine1,"");
      sscanf(ligne,"%s ",chaine1);
      if (strcmp(chaine1,"SET/VAR")==0) {
         nbvar++;
      }
      /* --- termine la boucle de lecture ---*/
      tt_free(ligne,"ligne");
      kdeb+=(nbcar+1);
   } while (kdeb<lentotal);

   /* === la seconde passe consiste a extraire les variables ===*/
   varnames=NULL;
   varvalues=NULL;
   compteligne=0;
   if (nbvar>0) {
      /* --- definition de la liste des noms de variable ---*/
      len=(int)(TT_LEN_VARNAME);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,3,&varnames,&nbvar,&len))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer varnames)");
         return(TT_ERR_PB_MALLOC);
      }
      /* --- definition de la liste des valeurs de variable ---*/
      len=(int)(TT_LEN_VARNAME);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,3,&varvalues,&nbvar,&len))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer varvalues)");
         tt_util_free_ptrptr((void**)varnames,"varnames");
         return(TT_ERR_PB_MALLOC);
      }
      /* --- definition de la liste des indices lignes de debut de validite ---*/
      index_deb=NULL;
      nombre=nbvar;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index_deb,&nombre,&taille,"index_deb"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer index_deb)");
         /* free a ajouter */
         return(TT_ERR_PB_MALLOC);
      }
      /* --- definition de la liste des indices lignes de fin de validite ---*/
      index_fin=NULL;
      nombre=nbvar;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index_fin,&nombre,&taille,"index_fin"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer index_fin)");
         /* free a ajouter */
         return(TT_ERR_PB_MALLOC);
      }
      /* --- k est le compteur de variables ---*/
      k=0;
      /* --- kdeb est l'indice de decalage absolu sur le texte ---*/
      kdeb=0;
      /* --- compteligne est le compteur de lignes ---*/
      compteligne=0;
      do {
         compteligne++;
         /* --- nbcar est le nombre de caracteres de la prochaine ligne ---*/
         car=strstr(texte+kdeb,"\n");nbcar=0; if (car!=NULL) {nbcar=(int)(car-texte-kdeb);} else {nbcar=strlen(texte+kdeb);}
         ligne=NULL;
         nombre=nbcar+1;
         taille=sizeof(char);
         if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ligne,&nombre,&taille,"ligne"))!=0) {
            tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer ligne)");
            return(TT_ERR_PB_MALLOC);
         }
         /* --- extrait la nouvelle ligne ---*/
         strncpy(ligne,texte+kdeb,nbcar);
         ligne[nbcar]='\0';
         /* --- teste s'il s'agit de la definition d'une variable ---*/
         strcpy(chaine1,"");
         sscanf(ligne,"%s ",chaine1);
         if (strcmp(chaine1,"SET/VAR")==0) {
            car=strstr(ligne,"SET/VAR");
            /* --- nbcarr est le nombre de caracteres non significatifs ---*/
            /* --- avant l'identificateur SET/VAR                       ---*/
            nbcarr=0;
            if (car!=NULL) {
               nbcarr=0; if (car!=NULL) {nbcarr=(int)(car-ligne);} else {nbcarr=strlen(ligne);}
               strcpy(chaine1,"");
               strcpy(chaine2,"");
               nb=sscanf(ligne+strlen("SET/VAR")+nbcarr," %s %s",chaine1,chaine2);
               if (nb==2) {
                  /* --- on assigne les valeurs de la variable ---*/
                  strcpy(varnames[k],chaine1);
                  strcpy(varvalues[k],chaine2);
                  /* --- debut de validite de la variable ---*/
                  index_deb[k]=compteligne;
                  k++;
               }
            }
         }
         /* --- termine la boucle de lecture ---*/
         tt_free(ligne,"ligne");
         kdeb+=(nbcar+1);
      } while (kdeb<lentotal);
      /* --- nbvar est le nombre de variables dans tout le texte ---*/
      nbvar=k;
   }
   /* --- on remplit les indices de fin de validite ---*/
   for (k=0;k<nbvar-1;k++) {
      for (kk=k+1;kk<nbvar;kk++) {
         if (strcmp(varnames[kk],varnames[k])==0) {
            index_fin[k]=index_deb[kk]-1;
            break;
         }
      }
   }
   /* --- idem si la variable n'apparait qu'une seule fois ---*/
   for (k=0;k<nbvar;k++) {
      if (index_fin[k]==0) { index_fin[k]=compteligne; }
   }
   /*
   printf("**** liste des variables dans le texte ****\n");
   for (k=0;k<nbvar;k++) {
   printf("%s=%s (%d-%d)\n",varnames[k],varvalues[k],index_deb[k],index_fin[k]);
   }
   getch();
   */

   /* === la troisieme passe execute les commandes ===*/
   /* --- kdeb est l'indice de decalage absolu sur le texte ---*/
   kdeb=0;
   /* --- msg est le statut de retour de la commande appellee ---*/
   msg=0;
   /* --- compteligne est le compteur de lignes ---*/
   compteligne=0;
   do {
      compteligne++;
      /* --- nbcar est le nombre de caracteres de la prochaine ligne ---*/
      car=strstr(texte+kdeb,"\n");nbcar=0; if (car!=NULL) {nbcar=(int)(car-texte-kdeb);} else {nbcar=strlen(texte+kdeb);}
      ligne=NULL;
      nombre=nbcar+1;
      taille=sizeof(char);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ligne,&nombre,&taille,"ligne"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer ligne)");
         return(TT_ERR_PB_MALLOC);
      }
      /* --- extrait la nouvelle ligne ---*/
      strncpy(ligne,texte+kdeb,nbcar);
      ligne[nbcar]='\0';
      /* --- ident est le marqueur de debut de variables dans la ligne ---*/
      ident=NULL;
      nombre=nbcar+1;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&ident,&nombre,&taille,"ident"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer ident)");
         /* free a ajouter */
         return(TT_ERR_PB_MALLOC);
      }
      /* --- ident vaut -1 s'il n'y a pas de debut de variable ---*/
      for (k=0;k<(nbcar+1);k++) {
         ident[k]=-1;
      }
      /* --- remplit le tableau de ident ---*/
      /* --- on balaye sur les variables ---*/
      for (k=0;k<nbvar;k++) {
         lentotall=strlen(ligne);
         /* --- kdebb est l'indice de decalage absolu sur la ligne ---*/
         kdebb=0;
         do {
            /* --- nbcar est le nombre de caracteres precedant le nom de variable ---*/
            nbcarr=0;
            car=strstr(ligne+kdebb,varnames[k]);
            /* --- le mot trouve n'est a remplace que si sa position ---*/
            /* --- est entre les index de deb et fin ---*/
            if ((car!=NULL)&&(compteligne>=index_deb[k])&&(compteligne<=index_fin[k])) {
               nbcarr=(int)(car-ligne-kdebb);
               /* --- occurence k trouve a la position nbcarr ---*/
               ident[kdebb+nbcarr]=k;
               nbcarr+=strlen(varnames[k]);
            } else {
               nbcarr=strlen(ligne+kdebb);
            }
            kdebb+=(nbcarr+1);
         } while (kdebb<lentotall);
      }
      /* --- calcule la longueur de la nouvelle chaine ---*/
      newlen=1;
      for (k=0;k<(int)(strlen(ligne));k++) {
         if (ident[k]==-1) { newlen++; }
         else {
            newlen=newlen-strlen(varnames[ident[k]])+strlen(varvalues[ident[k]])+1;
         }
      }
      newligne=NULL;
      nombre=newlen;
      taille=sizeof(char);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&newligne,&nombre,&taille,"newligne"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Problem of malloc in tt_script_2 function (pointer newligne)");
         /* free a ajouter */
         return(TT_ERR_PB_MALLOC);
      }
      /* --- substitue les variables par leur valeur ---*/
      for (kk=0,k=0;k<(int)(strlen(ligne));k++) {
         if (ident[k]==-1) {
            newligne[kk]=ligne[k];
            kk++;
         } else {
            for (kkk=0;kkk<(int)(strlen(varvalues[ident[k]]));kkk++) {
               newligne[kk]=varvalues[ident[k]][kkk];
               kk++;
            }
            k=k+strlen(varnames[ident[k]])-1;
         }
      }
      newligne[kk]='\0';
      /*
      printf("%s\n",ligne);
      printf("k=%d kk=%d newlen=%d\n",k,kk,newlen);
      //getch();
      */
      tt_free(ligne,"ligne");
      tt_free(ident,"ident");
      /* --- traite la newligne ---*/
      strcpy(chaine1,"");
      strcpy(chaine2,"");
      sscanf(newligne,"%s %s",chaine1,chaine2);
      /*printf("%s\n--------\n",ligne);
      printf("%s<BR>\n========<BR>\n",newligne);
      getch();
      */
      msg=0;
      tt_strupr(chaine1);
      if      (strcmp(chaine1,"IMA/STACK" )==0) { msg=tt_fct_ima_stack(newligne); }
      else if (strcmp(chaine1,"IMA/SERIES")==0) { msg=tt_fct_ima_series(newligne); }
      else if (strcmp(chaine1,"FILE/SCRIPT")==0) { msg=tt_script_3((void*)chaine2); }
      else if (strcmp(chaine1,"TMPFILE/EXT")==0) { strcpy(tt_tmpfile_ext,chaine2); }
      if (msg!=0) { tt_free(newligne,"newligne");break; }
      /* --- termine la boucle de lecture ---*/
      tt_free(newligne,"newligne");
      kdeb+=(nbcar+1);
   } while (kdeb<lentotal);

   /* === final ===*/
   if (index_deb!=NULL) {tt_free(index_deb,"index_deb");}
   if (index_fin!=NULL) {tt_free(index_fin,"index_fin");}
   if (varnames!=NULL) {
      tt_util_free_ptrptr((void**)varnames,"varnames");
   }
   if (varvalues!=NULL) {
      tt_util_free_ptrptr((void**)varvalues,"varvalues");
   }
   if (msg==OK_DLL) {
      sprintf(message,"----- Normal termination of script2");
   } else {
      sprintf(message,"----- Abnormal termination of script2 (%d)",msg);
   }
   tt_writelog("",message);
   return(msg);
}

int tt_script_3(void *arg1)
/***************************************************************************/
/* idem que script_2 mais on passe un nom de fichier                       */
/***************************************************************************/
/***************************************************************************/
{
   char *nom,*texte;
   int len,k,nombre,taille;
   int msg=0;
   FILE *fic;
   char message[TT_MAXLIGNE];

   tt_writelog("","===== Begin a process by script3 (calling script 2)");
   if (arg1==NULL) {
      msg=PB_DLL;
      tt_errlog("",msg,"File name is a NULL pointer");
      return(msg);
   }
   nom=arg1;
   if ((fic=fopen(nom,"rt"))==NULL) {
      msg=TT_ERR_FILE_NOT_FOUND;
      sprintf(message,"Script file %s not found !!!\n",nom);
      tt_errlog("",msg,message);
      return(msg);
   }
   len=0;
   do {
      len++;
      fgetc(fic);
   } while(feof(fic)==0);
   texte=NULL;
   nombre=len;
   taille=sizeof(char);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&texte,&nombre,&taille,"texte"))!=0) {
      msg=TT_ERR_PB_MALLOC;
      sprintf(message,"PB malloc for texte in tt_script3\n");
      tt_errlog("",msg,message);
      return(msg);
   }
   rewind(fic);
   k=0;
   do {
      texte[k++]=(char)(fgetc(fic));
   } while(feof(fic)==0);
   texte[k]='\0';
   fclose(fic);
   if ((msg=libtt_main0(TT_SCRIPT_2,1,texte))!=0) {
      return(msg);
   }
   tt_free(texte,"texte");
   texte=NULL;
   if (msg==OK_DLL) {
      sprintf(message,"----- Normal termination of script3");
   } else {
      sprintf(message,"----- Abnormal termination of script3 (%d)",msg);
   }
   tt_writelog("",message);
   return(msg);
}
