/* tt_fits5.c
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

int tt_tbllistkeys(TT_TBL *p,int *nkeys,void ***pkeynames,void ***pvalues,void ***pcomments,void ***punits,void **pdatatypes)
/***************************************************************************/
/* Remplit une liste de mots cle avec les listes de la table               */
/***************************************************************************/
/* Exclusion des mots cle reserves.                                        */
/* Attention, ***values n'est pas un pointeur de char mais a le datatype.  */
/***************************************************************************/
{
   int nbkeys,len,k,match,already,kk,msg;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   int nombre,taille;

   nbkeys=0;
   if (p->keyused==TT_YES) {nbkeys+=p->nbkeys;}
   if (p->ref_keyused==TT_YES) {nbkeys+=p->ref_nbkeys;}
   if (p->new_keyused==TT_YES) {nbkeys+=p->new_nbkeys;}
   if (nbkeys!=0) {
      keynames=NULL;
      len=(int)(FLEN_KEYWORD);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&keynames,&nbkeys,&len,"p->keynames"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tbllistkeys for pointer keynames");
	 return(TT_ERR_PB_MALLOC);
      }
      values=NULL;
      len=(int)(FLEN_VALUE);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&values,&nbkeys,&len,"p->values"))!=0) {
        tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tbllistkeys for pointer values");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 return(TT_ERR_PB_MALLOC);
      }
      comments=NULL;
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&comments,&nbkeys,&len,"p->comments"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tbllistkeys for pointer comments");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 tt_util_free_ptrptr2((void***)&values,"p->values");
	 return(TT_ERR_PB_MALLOC);
      }
      units=NULL;
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&units,&nbkeys,&len,"p->units"))!=0) {
        tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tbllistkeys for pointer units");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 tt_util_free_ptrptr2((void***)&values,"p->values");
	 tt_util_free_ptrptr2((void***)&comments,"p->comments");
	 return(TT_ERR_PB_MALLOC);
      }
      datatypes=NULL;
      nombre=nbkeys;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&datatypes,&nombre,&taille,"p->datatypes"))!=0) {
        tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tbllistkeys for pointer datatypes");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 tt_util_free_ptrptr2((void***)&values,"p->values");
	 tt_util_free_ptrptr2((void***)&comments,"p->comments");
	 tt_util_free_ptrptr2((void***)&units,"p->units");
	 return(TT_ERR_PB_MALLOC);
      }
      /*keyused=TT_YES;*/

      /* --- cree la nouvelle liste de mots cle ---*/
      nbkeys=0;
      if (p->new_keyused==TT_YES) {
	 for (k=0;k<p->new_nbkeys;k++) {
	    if (strcmp(p->new_keynames[k],"")!=0) {
	       if ((msg=libfiles_main(FS_UTIL_MATCH_RESERVED_KEY,2,p->new_keynames[k],&match))!=0) {
		  return(msg);
	       }
	       if (match==0) {
		  for (already=0,kk=0;kk<nbkeys;kk++) { if (strcmp(p->new_keynames[k],keynames[kk])==0) {already=1;} }
		  if (already==0) {
		     datatypes[nbkeys]=p->new_datatypes[k];
		     strcpy(keynames[nbkeys],p->new_keynames[k]);
		     tt_values2values(p->new_values[k],values[nbkeys],datatypes[nbkeys]);
		     strcpy(comments[nbkeys],p->new_comments[k]);
		     strcpy(units[nbkeys],p->new_units[k]);
		     nbkeys++;
		  }
	       }
	    }
	 }
      }
      if (p->keyused==TT_YES) {
	 for (k=0;k<p->nbkeys;k++) {
	    if (strcmp(p->keynames[k],"")!=0) {
	       if ((msg=libfiles_main(FS_UTIL_MATCH_RESERVED_KEY,2,p->keynames[k],&match))!=0) {
		  return(msg);
	       }
	       if (match==0) {
		  for (already=0,kk=0;kk<nbkeys;kk++) { if (strcmp(p->keynames[k],keynames[kk])==0) {already=1;} }
		  if (already==0) {
		     datatypes[nbkeys]=p->datatypes[k];
		     strcpy(keynames[nbkeys],p->keynames[k]);
		     tt_values2values(p->values[k],values[nbkeys],datatypes[nbkeys]);
		     strcpy(comments[nbkeys],p->comments[k]);
		     strcpy(units[nbkeys],p->units[k]);
		     nbkeys++;
		  }
	       }
	    }
	 }
      }
      if (p->ref_keyused==TT_YES) {
	 for (k=0;k<p->ref_nbkeys;k++) {
	    if (strcmp(p->ref_keynames[k],"")!=0) {
	       if ((msg=libfiles_main(FS_UTIL_MATCH_RESERVED_KEY,2,p->ref_keynames[k],&match))!=0) {
		  return(msg);
	       }
	       if (match==0) {
		  for (already=0,kk=0;kk<nbkeys;kk++) { if (strcmp(p->ref_keynames[k],keynames[kk])==0) {already=1;} }
		  if (already==0) {
		     datatypes[nbkeys]=p->ref_datatypes[k];
		     strcpy(keynames[nbkeys],p->ref_keynames[k]);
		     tt_values2values(p->ref_values[k],values[nbkeys],datatypes[nbkeys]);
		     strcpy(comments[nbkeys],p->ref_comments[k]);
		     strcpy(units[nbkeys],p->ref_units[k]);
		     nbkeys++;
		  }
	       }
	    }
	 }
      }
   }

   *pkeynames=(void**)(keynames);
   *pvalues=(void**)(values);
   *pcomments=(void**)(comments);
   *punits=(void**)(units);

   *pdatatypes=(int*)(datatypes);
   *nkeys=nbkeys;
   return(OK_DLL);
}

int tt_tblsaver(TT_TBL *p,char *fullname,int binorascii)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int nbhdu,typehdu;
   int msg,k,len,taille;
   int *hdunum=NULL,hdunum_keys;
   int nbkeys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char message[TT_MAXLIGNE];
   void **cols=NULL;
   void *colsk;

   /* --- identification du nom de fichier FITS ---*/
   if ((msg=tt_imafilenamespliter(fullname,p->save_path,p->save_name,p->save_suffix,&p->save_hdunum))!=0) { return(msg); }
   strcpy(p->save_fullname,tt_imafilecater(p->save_path,p->save_name,p->save_suffix));
   /*printf("<<%s>> %d\n",p->save_fullname,p->save_hdunum);*/

   /* --- initialise les variables de numero d'entete ---*/
   if (p->save_hdunum<=0) {
      p->save_hdunum=0;
      hdunum=NULL;
   } else {
      hdunum=&p->save_hdunum;
   }
   if (hdunum!=NULL) {
      /* --- Recherche le nombre d'entetes dans le fichier Fits ---*/
      nbhdu=0;
      /* nbhdu va provoquer une erreur dans le service FS_MACR_READ mais   */
      /* il va nous retourner le veritable nombre de HDUs dans la variable */
      /* nbhdu.                                                            */
      msg=libfiles_main(FS_MACR_READ,2,p->save_fullname,&nbhdu);
      /* FS_ERR_HDUNUM_OVER est un code erreur defini dans libfiles.h */
      if (msg!=FS_ERR_HDUNUM_OVER) {
         sprintf(message,"Problem concerning image %s",fullname);
         tt_errlog("",msg,message);
	 return(msg);
      }
   }
   if (p->save_hdunum>nbhdu) {
      p->save_hdunum=nbhdu;
   }

   /* --- remplit les colonnes avec la table ---*/
   /*len=p->tfields;*/
   len=20; /*-- limite du nombre de colonnes de la table ---*/
   taille=(int)(sizeof(int)); /* taille d'une adresse : 4 octets ! */
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,(void**)&cols,&len,&taille,"cols"))!=OK_DLL) {
      return(TT_ERR_PB_MALLOC);
   }
   for (k=0;k<len;k++) {
      colsk=NULL;
      if (k<p->tfields) {
         msg=tt_tblcol_ascii2bin(p,k,(void**)&colsk);
      }
      cols[k]=colsk;
   }

   /* --- sauve la table avec une entete minimale ---*/
   typehdu=binorascii;
   if ((msg=libfiles_main(FS_MACR_WRITE,32,p->save_fullname,hdunum,&typehdu,
    NULL,NULL,NULL,
    &p->tfields,&p->naxis2,NULL,p->tunit,p->ttype,p->tbldatatypes,
    cols[0],cols[1],cols[2],cols[3],cols[4],cols[5],cols[6],cols[7],cols[8],cols[9],
    cols[10],cols[11],cols[12],cols[13],cols[14],cols[15],cols[16],cols[17],cols[18],cols[19]
    ))!=OK_DLL) {
      if (msg!=412) {
         return(msg);
      }
   }

   /* --- on detruit tous les vecteurs colonnes ---*/
   for (k=0;k<p->tfields;k++) {
      /*tt_free2((void**)((int*)(cols)+k),"cols(k)");*/
      tt_free2((void**)&(cols[k]),"colsk");
   }
   tt_free2((void**)&cols,"cols");

   /* --- cree la nouvelle liste de mots cle ---*/
   tt_tbllistkeys(p,&nbkeys,(void***)(&keynames),(void***)(&values),(void***)(&comments),(void***)(&units),(void**)(&datatypes));

   /* --- sauvegarde de la nouvelle liste de mots cle dans le header de la table---*/
   hdunum_keys=(hdunum==NULL)?2:((*hdunum)+1);


   if (nbkeys!=0) {
      /*
      printf("nbkeys=%d\n",nbkeys);
      printf("fichier=<%s> hdu=%d\n",p->save_fullname,hdunum_keys);
      for (kkkk=0;kkkk<nbkeys;kkkk++) {
	 printf("<%s>(%d)<%s><%s>\n",keynames[kkkk],datatypes[kkkk],comments[kkkk],units[kkkk]);
      }
      getch();
      */
      if ((msg=libfiles_main(FS_MACR_WRITE_KEYS,8,p->save_fullname,&hdunum_keys,&nbkeys,
       keynames,comments,units,datatypes,values))!=0) {
          tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
          tt_util_free_ptrptr2((void***)&values,"p->values");
          tt_util_free_ptrptr2((void***)&comments,"p->comments");
          tt_util_free_ptrptr2((void***)&units,"p->units");
          tt_free2((void**)&datatypes,"p->datatypes");
          return(msg);
       }
   }
   tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
   tt_util_free_ptrptr2((void***)&values,"p->values");
   tt_util_free_ptrptr2((void***)&comments,"p->comments");
   tt_util_free_ptrptr2((void***)&units,"p->units");
   tt_free2((void**)&datatypes,"p->datatypes");
   return(OK_DLL);
}

int tt_tbldatainfos(char **table,int tfields,int *naxis2,int *nbcars)
/***************************************************************************/
/* Calcule la valeur de naxis2 (nombre de lignes de la table).             */
/* et nbcars, le nombre de caracteres maximumdes champs.                   */
/***************************************************************************/
{
   char *colonne,*mot;
   int k,len,taille,klig,nblig=0,nbcar=0,msg;
   *nbcars=0;
   *naxis2=0;
   for (k=0;k<tfields;k++) {
      klig=0;
      len=(int)(strlen(table[k])+1);
      taille=(int)sizeof(char);
      colonne=NULL;
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,(char**)&colonne,&len,&taille,"colonne"))!=OK_DLL) {
         return(TT_ERR_PB_MALLOC);
      }
      strcpy(colonne,table[k]);
      mot=strtok(colonne," \t\n");
      if (mot!=NULL) {
         klig++;
         if (nbcar<(int)(strlen(mot))) {nbcar=(int)(strlen(mot));}
      }
      while (mot!=NULL) {
         mot=strtok(NULL," \t\n");
         if (mot!=NULL) {
            klig++;
            if (nbcar<(int)(strlen(mot))) {nbcar=(int)(strlen(mot));}
         }
      }
      tt_free2((void**)&colonne,"colonne");
      if (k!=0) {
         if (klig!=nblig) {
            // erreur, nombre de lignes different dans la colonne k
            return(PB_DLL);
         }
      } else {
         nblig=klig;
      }
   }
   *naxis2=nblig;
   *nbcars=nbcar;
   return(OK_DLL);
}

int tt_tblcol_ascii2bin(TT_TBL *p,int colnum,void **colsk)
/***************************************************************************/
/* Alloue et retourne un vecteur rempli des valeurs binaires de la colonne */
/* colnum de la table ascii.                                               */
/***************************************************************************/
/***************************************************************************/
{
   int len,tbldatatype,taille,naxis2,k,msg;
   char *mot,*colascii,*colonne=NULL;
   void *colbin;
   colascii=p->p[colnum];
   tbldatatype=p->tbldatatypes[colnum];
   naxis2=p->naxis2; /* nombre de lignes dans la table */
   if (tbldatatype==TSHORT) { len=(int)(sizeof(short)); }
   else if (tbldatatype==TINT) { len=(int)(sizeof(int)); }
   else if (tbldatatype==TLONG) { len=(int)(sizeof(long)); }
   else if (tbldatatype==TFLOAT) { len=(int)(sizeof(float)); }
   else if (tbldatatype==TDOUBLE) { len=(int)(sizeof(double)); }
   colbin=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,(void**)&colbin,&naxis2,&len,"colbin"))!=OK_DLL) {
      return(TT_ERR_PB_MALLOC);
   }
   *colsk=(void*)colbin;
   colonne=NULL;
   len=(int)(strlen(colascii)+1);
   taille=(int)sizeof(char);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,(char**)&colonne,&len,&taille,"colonne"))!=OK_DLL) {
      tt_free2((void**)&colbin,"colbin");
      return(TT_ERR_PB_MALLOC);
   }
   strcpy(colonne,colascii);
   mot=strtok(colonne," \t\n");
   if (mot!=NULL) {
      if (tbldatatype==TSHORT) { *((short*)(colbin)+0)=(short)(atoi(mot)); }
      else if (tbldatatype==TINT) { *((int*)(colbin)+0)=(int)(atoi(mot)); }
      else if (tbldatatype==TLONG) { *((long*)(colbin)+0)=(long)(atol(mot)); }
      else if (tbldatatype==TFLOAT) { *((float*)(colbin)+0)=(float)(atof(mot)); }
      else if (tbldatatype==TDOUBLE) { *((double*)(colbin)+0)=(double)(atof(mot)); }
   }
   for (k=1;k<naxis2;k++) {
      mot=strtok(NULL," \t\n");
      if (mot!=NULL) {
         if (tbldatatype==TSHORT) {*((short*)(colbin)+k)=(short)(atoi(mot));}
         else if (tbldatatype==TINT) { *((int*)(colbin)+k)=(int)(atoi(mot)); }
         else if (tbldatatype==TLONG) { *((long*)(colbin)+k)=(long)(atol(mot)); }
         else if (tbldatatype==TFLOAT) { *((float*)(colbin)+k)=(float)(atof(mot)); }
         else if (tbldatatype==TDOUBLE) { *((double*)(colbin)+k)=(double)(atof(mot)); }
      }
   }
   tt_free2((void**)&colonne,"colonne");
   return(OK_DLL);
}

int tt_tblnewkeychar(TT_TBL *p,char *keyname,char *value,int datatype,char *comment,char *unit)
/***************************************************************************/
/* ajoute une nouvelle entree a la liste des new_* dans l'entete.          */
/***************************************************************************/
/* ici, values est un char **                                              */
/***************************************************************************/
{
   int knew,k;
   p->new_keyused=TT_YES;
   for (knew=(p->new_nbkeys)-1,k=0;k<(p->new_nbkeys);k++) {
      if (strcmp(p->new_keynames[k],"")==0) {
	 knew=k;
	 break;
      }
   }
   if (((int)strlen(keyname))>((int)(FLEN_KEYWORD))) {
      keyname[(int)(FLEN_KEYWORD)]='\0';
   }
   strcpy(p->new_keynames[knew],keyname);
   if (comment!=NULL) {
      if (((int)strlen(comment))>((int)(FLEN_COMMENT))) {
	 comment[(int)(FLEN_COMMENT)]='\0';
      }
      strcpy(p->new_comments[knew],comment);
   } else {
      strcpy(p->new_comments[knew],"");
   }
   if (unit!=NULL) {
      if (((int)strlen(unit))>((int)(FLEN_COMMENT))) {
	 unit[(int)(FLEN_COMMENT)]='\0';
      }
      strcpy(p->new_units[knew],unit);
   } else {
      strcpy(p->new_units[knew],"");
   }
   if (value!=NULL) {
      if (((int)strlen(value))>((int)(FLEN_VALUE))) {
	 unit[(int)(FLEN_VALUE)]='\0';
      }
      strcpy(p->new_values[knew],value);
   } else {
      strcpy(p->new_values[knew],"");
   }
   p->new_datatypes[knew]=datatype;
   return(OK_DLL);
}

int tt_tblbuilder(TT_TBL *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int len,msg;
   int taille,nombre;
   /* -------------------------------------------------------------------------- */
   /* --- premiere partie. On initialise les valeurs et les pointeurs a NULL --- */
   /* -------------------------------------------------------------------------- */
   /* --- table de travail a charger ---*/
   strcpy(p->load_path,"");
   sprintf(p->load_name,"#0");
   sprintf(p->load_suffix,".fit");
   sprintf(p->load_fullname,"%s%s%s",p->load_path,p->load_name,p->load_suffix);
   p->load_typehdu=BINARY_TBL;
   p->load_hdunum=1;
   /* --- table de travail a sauver ---*/
   strcpy(p->save_path,"");
   sprintf(p->save_name,"#0");
   sprintf(p->save_suffix,".fit");
   sprintf(p->save_fullname,"%s%s%s",p->save_path,p->save_name,p->save_suffix);
   p->save_typehdu=BINARY_TBL;
   p->save_hdunum=0;
   /* --- table de reference pour l'entete ---*/
   strcpy(p->ref_path,"");
   strcpy(p->ref_name,"");
   strcpy(p->ref_suffix,"");
   sprintf(p->ref_fullname,"%s%s%s",p->ref_path,p->ref_name,p->ref_suffix);
   p->ref_typehdu=BINARY_TBL;
   p->ref_hdunum=1;
   /* --- mots cles dans la table de travail ---*/
   p->keyused=TT_NO;
   p->nbkeys=0;
   p->keynames=NULL;
   p->values=NULL;
   p->comments=NULL;
   p->units=NULL;
   p->datatypes=NULL;
   /* --- mots cles dans la table de reference pour l'entete ---*/
   p->ref_keyused=TT_NO;
   p->ref_nbkeys=0;
   p->ref_keynames=NULL;
   p->ref_values=NULL;
   p->ref_comments=NULL;
   p->ref_units=NULL;
   p->ref_datatypes=NULL;
   /* --- nouveaux mots cles a ajouter dans la table de travail ---*/
   p->new_keynames=NULL;
   p->new_values=NULL;
   p->new_comments=NULL;
   p->new_units=NULL;
   p->new_datatypes=NULL;
   p->new_nbkeys=250;
   p->new_keyused=TT_YES;
   /* --- valeur de la derniere de l'indice du mot cle TT ---*/
   p->last_tt=0;
   /* --- definition de la table ---*/
   p->p=NULL;
   p->tbldatatypes=NULL;
   p->tfields=0;
   p->naxis2=0;
   p->firstelem=0;
   p->nelements=0;
   p->tform=NULL;
   p->tunit=NULL;
   p->ttype=NULL;

   /* ------------------------------------------------------------ */
   /* --- deuxieme partie. On alloue la memoire des pointeurs  --- */
   /* ------------------------------------------------------------ */
   /* --- nouveaux mots cles a ajouter dans la table de travail ---*/
   len=(int)(FLEN_KEYWORD);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_keynames,&p->new_nbkeys,&len,"p->new_keynames"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblbuilder for pointer new_keynames");
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_values,&p->new_nbkeys,&len,"p->new_values"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblbuilder for pointer new_values");
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_COMMENT);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_comments,&p->new_nbkeys,&len,"p->new_comments"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblbuilder for pointer new_comments");
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_COMMENT);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_units,&p->new_nbkeys,&len,"p->new_units"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblbuilder for pointer new_units");
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=p->new_nbkeys;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->new_datatypes,&nombre,&taille,"p->new_datatypes"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblbuilder for pointer new_datatypes");
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }

   /* --- definition des objets herites ---*/
   /* rien dans ce cas ---*/

   /* ------------------------------------------------------- */
   /* --- troisieme partie. On appelle les constructeurs  --- */
   /* ---                   des objets herites.           --- */
   /* ------------------------------------------------------- */

   return(OK_DLL);
}

int tt_tblsizeline(int tfields, int *tbldatatypes, int *size)
/***************************************************************************/
/* Calcule le nombre de char occupe par la table a partir de datatypes  ---*/
/***************************************************************************/
/* datatypes est au format TT                                                  */
/***************************************************************************/
{
   int k;
   int taille=0;
   if (tfields<=0) {*size=0; return(OK_DLL); }
   for (k=0;k<tfields;k++) {
      if (tbldatatypes[k]==TSHORT) {taille+=TT_NBDIGITS_SHORT;}
      else if (tbldatatypes[k]==TINT) {taille+=TT_NBDIGITS_INT;}
      else if (tbldatatypes[k]==TLONG) {taille+=TT_NBDIGITS_LONG;}
      else if (tbldatatypes[k]==TFLOAT) {taille+=TT_NBDIGITS_FLOAT;}
      else if (tbldatatypes[k]==TDOUBLE) {taille+=TT_NBDIGITS_DOUBLE;}
      else if (tbldatatypes[k]>TSTRINGS) {taille+=(tbldatatypes[k]-TSTRINGS);}
      else {
         *size=taille;
         return(TT_ERR_TBLDATATYPES);
      }
      taille+=1; /* ajoute un espace entre chaque champ */
   }
   *size=taille;
   return(OK_DLL);
}

int tt_tbl_dtypes2tbldatatypes(char *dtypes,int *tfields,int **tbldatatypes)
/***************************************************************************/
/* Converti la chaine dtypes qui definit le type de chaque champ de la     */
/* table en le tableau d'entiers tbldatatypes contenant le code TT/FS.     */
/***************************************************************************/
/***************************************************************************/
{
   char **keys;
   int k,nbkeys,len,msg,taille;
   int *dt;

   /* --- transcode les valeurs de *datatypes ---*/
   tt_decodekeys(dtypes,(void***)&keys,&nbkeys);
   *tfields=nbkeys;
   if (*tfields<=0) {*tfields=1;}
   /* --- allocation memoire tbldatatypes ---*/
   dt=NULL;
   taille=nbkeys;
   len=(int)(sizeof(int));
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,(void**)&dt,&nbkeys,&len,"dt"))!=OK_DLL) {
      tt_util_free_ptrptr2((void***)&keys,"keys");
      return(TT_ERR_PB_MALLOC);
   }
   *tbldatatypes=dt;
   /* --- remplit les valeurs de tbldatatypes ---*/
   for (k=0;k<*tfields;k++) {
      tt_strupr(keys[k]);
      if (strcmp(keys[k],"FLOAT")==0) { dt[k]=TFLOAT; }
      else if (strcmp(keys[k],"DOUBLE")==0) { dt[k]=TDOUBLE; }
      else if (strcmp(keys[k],"INT")==0) { dt[k]=TINT; }
      else if (strcmp(keys[k],"LONG")==0) { dt[k]=TLONG; }
      else if (strcmp(keys[k],"SHORT")==0) { dt[k]=TSHORT; }
      else {
         taille=atoi(keys[k]);
         if (taille<=0) {
            tt_util_free_ptrptr((void**)keys,"keys");
            return(TT_ERR_TBLDATATYPES);
         }
         dt[k]=TSTRINGS+taille;
      }
   }
   tt_util_free_ptrptr2((void***)&keys,"keys");
   return(OK_DLL);
}


int tt_tblcreater(TT_TBL *p,int tfields,int naxis2, int *tbldatatypes)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int msg,len;
   if (p->p!=NULL) {
      /* code-erreur sur pointeurs deja alloues ---*/
      tt_errlog("",TT_ERR_PTR_ALREADY_ALLOC,"Pointer p already allocated");
      return(TT_ERR_PTR_ALREADY_ALLOC);
   }
   p->tfields=(int)(tfields);
   p->naxis2=(int)(naxis2);

   p->tunit=NULL;
   p->ttype=NULL;
   p->p=NULL;

   /* --- allocation memoire tunit et ttype ---*/
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->tunit,&tfields,&len,"p->tunit"))!=OK_DLL) {
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->ttype,&tfields,&len,"p->ttype"))!=OK_DLL) {
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }

   /* --- allocation memoire table ---*/
   /*
   tt_tblsizeline(tfields,tbldatatypes,&len);
   if (len<=0) { len=1; }
   */
   len=(int)(sizeof(char));
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->p,&naxis2,&len,"p->ptbl"))!=OK_DLL) {
      tt_tbldestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }

   p->firstelem=(long)(0);
   p->nelements=(long)(naxis2);
   return(OK_DLL);
}

int tt_tbldestroyer(TT_TBL *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   /* --- mots cles dans l'image de travail ---*/
   if (p->keyused==(TT_YES)) {
      tt_util_free_ptrptr2((void***)&p->keynames,"p->keynames");
      tt_util_free_ptrptr2((void***)&p->values,"p->values");
      tt_util_free_ptrptr2((void***)&p->comments,"p->comments");
      tt_util_free_ptrptr2((void***)&p->units,"p->units");
      tt_free2((void**)&p->datatypes,"p->datatypes");
      p->keyused=(TT_NO);
   }
   /* --- mots cles dans l'image de reference pour l'entete ---*/
   if (p->ref_keyused==(TT_YES)) {
      tt_util_free_ptrptr2((void***)&p->ref_keynames,"p->ref_keynames");
      tt_util_free_ptrptr2((void***)&p->ref_values,"p->ref_values");
      tt_util_free_ptrptr2((void***)&p->ref_comments,"p->ref_comments");
      tt_util_free_ptrptr2((void***)&p->ref_units,"p->ref_units");
      tt_free2((void**)&p->ref_datatypes,"p->ref_datatypes");
      p->ref_keyused=(TT_NO);
   }
   /* --- nouveaux mots cles a ajouter dans l'image de travail ---*/
   if (p->new_keyused==(TT_YES)) {
      tt_util_free_ptrptr2((void***)&p->new_keynames,"p->new_keynames");
      tt_util_free_ptrptr2((void***)&p->new_values,"p->new_values");
      tt_util_free_ptrptr2((void***)&p->new_comments,"p->new_comments");
      tt_util_free_ptrptr2((void***)&p->new_units,"p->new_units");
      tt_free2((void**)&p->new_datatypes,"p->new_datatypes");
      p->new_keyused=(TT_NO);
   }
   /* --- definition de l'image ---*/
   if ((p->p)!=NULL) {
      tt_util_free_ptrptr2((void***)&p->p,"p->ptbl");
      p->p=NULL;
   }
   if ((p->tbldatatypes)!=NULL) {
      tt_free2((void**)&p->tbldatatypes,"p->tbldatatypes");
      p->tbldatatypes=NULL;
   }
   p->naxis2=0;
   p->firstelem=0;
   p->nelements=0;
   if ((p->tform)!=NULL) {
      tt_util_free_ptrptr2((void***)&p->tform,"p->tform");
      p->tform=NULL;
   }
   if ((p->tunit)!=NULL) {
      tt_util_free_ptrptr2((void***)&p->tunit,"p->tunit");
      p->tunit=NULL;
   }
   if ((p->ttype)!=NULL) {
      tt_util_free_ptrptr2((void***)&p->ttype,"p->ttype");
      p->ttype=NULL;
   }
   return(OK_DLL);
}
