/* tt_fits4.c
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

int tt_tblcatloader(TT_IMA *p_ima,char *fullname)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int nbhdu,typehdu,khdu,k,goodhdu;
   int msg;
   /* --- pour la description generale d'une liste de mots cle ---*/
   int nbkeys;
   char **keynames=NULL;    /* liste mots cles */
   char **values=NULL;      /* liste de valeurs associees aux mots cle */
   char **comments=NULL;    /* liste de commentaires associes aux mots cle */
   char **units=NULL;       /* liste des unites physiques a ajouter aux commentaires */
   int *datatypes=NULL;
   char keyname[FLEN_KEYWORD];
   char value_char[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];
   int datatype;
   TT_TBL_CATALIST *p=NULL;
   long firstrow,nelements;
   /* --- pour la description des champs de la table ---*/
   char **tform=NULL;    /* formatage de chaque colonne (=champ) */
   char **ttype=NULL;    /* intitule de chaque colonne (=champ) */
   char **tunit=NULL;    /* unite physique de chaque colonne (=champ) */
   int *tdatatypes=NULL; /* type des donnees de chaque colonne (=champ) */

   p=p_ima->catalist;

   /* --- recherche CATAFILE dans l'entete de l'image ---*/
   strcpy(value_char,"");
   strcpy(keyname,"CATAFILE");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   strcpy(p_ima->catalist_fullname,value_char);
   if (strcmp(p_ima->catalist_fullname,"")==0) {
      strcpy(p_ima->catalist_fullname,fullname);
   } else if (strcmp(p_ima->catalist_fullname,".       ")==0) {
      strcpy(p_ima->catalist_fullname,p_ima->load_fullname);
   }
   /* --- recherche CATAKEY dans l'entete de l'image ---*/
   strcpy(value_char,"");
   strcpy(keyname,"CATAKEY");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   strcpy(p_ima->catakey,value_char);

   /* --- identification du nom de fichier FITS ---*/
   if ((msg=tt_imafilenamespliter(p_ima->catalist_fullname,p->load_path,p->load_name,p->load_suffix,&p->load_hdunum))!=0) { return(msg); }
   strcpy(p->load_fullname,tt_imafilecater(p->load_path,p->load_name,p->load_suffix));
   strcpy(p_ima->catalist_fullname,p->load_fullname);
   /*
   printf("== CATAFILE=%s CATAKEY=%s\n",p_ima->catalist_fullname,p_ima->catekey);
   */

   /* --- Recherche le nombre d'entetes dans le fichier Fits ---*/
   nbhdu=0;
   /* nbhdu va provoquer une erreur dans le service FS_MACR_READ mais   */
   /* il va nous retourner le veritable nombre de HDUs dans la variable */
   /* nbhdu.                                                            */
   msg=libfiles_main(FS_MACR_READ,2,p->load_fullname,&nbhdu);

   /* FS_ERR_HDUNUM_OVER est un code erreur defini dans libfiles.h */
   if (msg!=FS_ERR_HDUNUM_OVER) {
      char message[1024];
      sprintf(message,"Error tt_tblcatloader: could not load %s", p->load_fullname);
      tt_errlog("",msg,message);
      return(msg);
   }
   if (p->load_hdunum==0) {
      p->load_hdunum=1;
   }
   if ((p->load_hdunum<0)||(p->load_hdunum>nbhdu)) {
      return(TT_ERR_HDUNUM_OVER);
   }

   goodhdu=TT_NO;
   for (khdu=p->load_hdunum;khdu<=nbhdu;khdu++) {
      /*printf(" entete khdu=%d\n",khdu);*/
      goodhdu=TT_NO;
      /* --- recherche le type de l'entete dans le fichier Fits ---*/
      typehdu=-2;
      /* Il faut mettre typehdu=-2 pour provoquer une erreur dans le service*/
      /* FS_MACR_READ qui retournera neanmoins le veritable type du HDU     */
      /* selectionne dans la variable typehdu.                              */
      msg=libfiles_main(FS_MACR_READ,3,p->load_fullname,&khdu,&typehdu);
      if (msg==FS_ERR_HDU_NOT_SAME_TYPE) {
	 if ((typehdu==ASCII_TBL)||(typehdu==BINARY_TBL)) {
	    /* --- on va maintenant decoder les mots cles de cette entete ---*/
	    nbkeys=0;
	    /* Le fait de placer un nbkeys==0 indique a la fonction de */
	    /* retourner l'ensemble des mots cles et leur valeurs.     */
	    /* En retour, la fonction indique le veritable nbkeys,     */
	    /* effectue des 'calloc' sur **keynames, *keynames, etc... */
	    /* et remplit leurs valeurs.                               */
	    if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,p->load_fullname,&khdu,&nbkeys,
	     &keynames,&comments,&units,&datatypes,&values))!=0) {
		return(msg);
	    }
	    /* --- analyse les mots cles ---*/
	    /* --- recherche TTNAME dans l'entete FITS courante ---*/
	    strcpy(value_char,"");
	    for (k=0;k<nbkeys;k++) {
	       /*printf("  %s=%s\n",keynames[k],values[k]);getch();*/
	       if (strcmp(keynames[k],"TTNAME")==0) {
		  strcpy(value_char,values[k]);
		  break;
	       }
	    }
	    if (strcmp(value_char,"CATALIST")==0) {
	       /* --- recherche CATAKEY dans l'entete FITS courante ---*/
	       strcpy(value_char,"");
	       for (k=0;k<nbkeys;k++) {
		  if (strcmp(keynames[k],"CATAKEY")==0) {
		     strcpy(value_char,values[k]);
		     break;
		  }
	       }
	       if (strcmp(value_char,p_ima->catakey)==0) {
		  /* il faut lire le contenu de cet hdu ---*/
		  goodhdu=TT_YES;
	       }
	    }
	    tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	    tt_util_free_ptrptr2((void***)&values,"p->values");
	    tt_util_free_ptrptr2((void***)&comments,"p->comments");
	    tt_util_free_ptrptr2((void***)&units,"p->units");
	    tt_free2((void**)&datatypes,"p->datatypes");
	 } /* fin d'analyse de l'entete de la table */
      } /* fin de if */
      if (goodhdu==TT_YES) { break; }
   } /* fin de boucle sur les entetes */

   if (goodhdu==TT_NO) {
      return(TT_ERR_CATAFILE_NOT_FOUND);
   } else {
      p->load_hdunum=khdu;
      p->load_typehdu=typehdu;
   }

   /* --- on va maintenant charger la liste ---*/
   firstrow=1;
   nelements=0;
   tform=NULL;
   ttype=NULL;
   tunit=NULL;
   if ((msg=libfiles_main(FS_MACR_READ,12,p->load_fullname,&p->load_hdunum,&p->load_typehdu,&firstrow,&nelements,
    &p->tfields,&p->nrows,&tform,&ttype,&tunit,&tdatatypes,NULL
    ))!=0) {
      return(msg);
   }
#ifdef TT_MOUCHARDPTR
   /* --- debug ---*/
   if (tform!=NULL) {tt_util_mouchard("p->tform",1,(int)&p->tform);}
   if (ttype!=NULL) {tt_util_mouchard("p->ttype",1,(int)&p->ttype);}
   if (tunit!=NULL) {tt_util_mouchard("p->tunit",1,(int)&p->tunit);}
#endif
   if (tform!=NULL) {tt_util_free_ptrptr2((void***)&tform,"p->tform");}
   if (ttype!=NULL) {tt_util_free_ptrptr2((void***)&ttype,"p->ttype");}
   if (tunit!=NULL) {tt_util_free_ptrptr2((void***)&tunit,"p->tunit");}

   if ((msg=libfiles_main(FS_MACR_READ,20,p->load_fullname,&p->load_hdunum,&p->load_typehdu,&firstrow,&nelements,
    &p->tfields,&p->nrows,NULL,NULL,NULL,&tdatatypes,
    &p->x,&p->y,&p->ident,&p->ra,&p->dec,&p->magb,&p->magv,&p->magr,&p->magi
    ))!=0) {
      return(msg);
   }
#ifdef TT_MOUCHARDPTR
   /* --- debug ---*/
   tt_util_mouchard("p->x",1,(int)&p->x);
   tt_util_mouchard("p->y",1,(int)&p->y);
   tt_util_mouchard("p->ident",1,(int)&p->ident);
   tt_util_mouchard("p->ra",1,(int)&p->ra);
   tt_util_mouchard("p->dec",1,(int)&p->dec);
   tt_util_mouchard("p->magb",1,(int)&p->magb);
   tt_util_mouchard("p->magv",1,(int)&p->magv);
   tt_util_mouchard("p->magr",1,(int)&p->magr);
   tt_util_mouchard("p->magi",1,(int)&p->magi);
   tt_util_mouchard("tdatatypes",1,(int)&tdatatypes);
#endif
   tt_free2((void**)&tdatatypes,"tdatatypes");
   /*
   printf("Liste reperee dans le HDU=%d (goodhdu=%d) (nrows=%d)\n",khdu,goodhdu,p->nrows);
   for (k=0;k<p->nrows;k++) {
      printf("k=%d %f %f %d\n",k,p->x[k],p->y[k],p->ident[k]);
      getch();
   }
   */
   return(OK_DLL);
}


int tt_tblcatsaver(TT_IMA *p_ima,char *fullname)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   char path[FLEN_FILENAME];
   char name[FLEN_FILENAME];
   char suffix[FLEN_FILENAME];
   char fullname0[FLEN_FILENAME];
   int msg,nbhdu,hdunum,*phdunum,hdunum_keys;
   int nbkeys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   TT_TBL_CATALIST *p=NULL;

   p=p_ima->catalist;
   tt_imafilenamespliter(fullname,path,name,suffix,&hdunum);
   strcpy(fullname0,tt_imafilecater(path,name,suffix));

   /* --- Recherche le nombre d'entetes dans le fichier Fits ---*/
   nbhdu=0;
   /* nbhdu va provoquer une erreur dans le service FS_MACR_READ mais   */
   /* il va nous retourner le veritable nombre de HDUs dans la variable */
   /* nbhdu.                                                            */
   msg=libfiles_main(FS_MACR_READ,2,fullname0,&nbhdu);
   /* msg=FS_ERR_HDUNUM_OVER est un code erreur defini dans libfiles.h */
   /* msg=104 si le fichier n'est trouve sur le disque                 */

   /* --- numero HDU derriere lequel on insere la table ---*/
   phdunum=NULL;
   if ((msg==104)&&(hdunum<=0)) { p->save_hdunum=nbhdu; phdunum=NULL; }
   else if (hdunum<=0) {p->save_hdunum=nbhdu; phdunum=&p->save_hdunum; }
   else if (hdunum<nbhdu) {p->save_hdunum=hdunum; phdunum=&p->save_hdunum; }
   else {p->save_hdunum=nbhdu; phdunum=&p->save_hdunum; }

   /* --- enregistrement de la table ---*/
   /* L'avantage de ne pas                                                 */
   /* avoir defini explicitement tform est qu'il sera cree automatiquement */
   /* en fonction du type de tables (les standards d'ecriture sont         */
   /* differents entre les deux types de tables !!!).                      */
   /* Les donnees des colonnes sont ajoutees a la fin dans l'ordre.        */
   if ((msg=libfiles_main(FS_MACR_WRITE,25,fullname0,phdunum,&p->save_typehdu,
    NULL,NULL,NULL,&p->tfields,&p->nrows,p->tform,p->ttype,p->tunit,p->datatypes,
    p->x,p->y,p->ident,p->ra,p->dec,p->magb,p->magv,p->magr,p->magi
    ))!=0) {
      if (msg!=412) {
	 return(msg);
      }
   }

   /* --- ajout des mots cle pour la table d'objets ---*/
   tt_imadelnewkey(p_ima,"TTNAME");
   tt_imanewkey(p_ima,"TTNAME","CATALIST",TSTRING,"TT name of this table","");

   /* --- cree la nouvelle liste de mots cle ---*/
   tt_imalistkeys(p_ima,&nbkeys,(void***)(&keynames),(void***)(&values),(void***)(&comments),(void***)(&units),(void**)(&datatypes));
   tt_imadelnewkey(p_ima,"TTNAME");

   /* --- sauvegarde de la nouvelle liste de mots cle ---*/
   hdunum_keys=(phdunum==NULL)?1:((*phdunum)+1);
   if (hdunum_keys==1) { hdunum_keys=2; }
   if (nbkeys!=0) {
      /*
      printf("nbkeys=%d\n",nbkeys);
      printf("fichier=<%s> hdu=%d\n",fullname0,hdunum_keys);
      for (kkkk=0;kkkk<nbkeys;kkkk++) {
	 printf("<%s>(%d)<%s><%s>\n",keynames[kkkk],datatypes[kkkk],comments[kkkk],units[kkkk]);
      }
      getch();
      */
      if ((msg=libfiles_main(FS_MACR_WRITE_KEYS,8,fullname0,&hdunum_keys,&nbkeys,
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


int tt_tblcatbuilder(TT_TBL_CATALIST *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int len,msg,nombre,taille;
   /* -------------------------------------------------------------------------- */
   /* --- premiere partie. On initialise les valeurs et les pointeurs a NULL --- */
   /* -------------------------------------------------------------------------- */
   /* --- image de travail a charger ---*/
   strcpy(p->load_path,"");
   sprintf(p->load_name,"#0");
   sprintf(p->load_suffix,".fit");
   sprintf(p->load_fullname,"%s%s%s",p->load_path,p->load_name,p->load_suffix);
   p->load_typehdu=BINARY_TBL;
   p->load_hdunum=1;
   /* --- image de travail a sauver ---*/
   strcpy(p->save_path,"");
   sprintf(p->save_name,"#0");
   sprintf(p->save_suffix,".fit");
   sprintf(p->save_fullname,"%s%s%s",p->save_path,p->save_name,p->save_suffix);
   p->save_typehdu=BINARY_TBL;
   p->save_hdunum=0;
   /* --- pour la description de la table ---*/
   strcpy(p->extname,"CATALIST");
   p->extver=1;
   /* --- pour la description des champs de la table ---*/
   p->tfields=TT_TBLCAT_TFIELDS;     /* nombre de colonnes (=nombre de champ) */
   p->tform=NULL;
   p->ttype=NULL;
   p->tunit=NULL;
   p->datatypes=NULL;
   /* --- pour la description des donnees de la table ---*/
   p->nrows=0;
   p->x=NULL;
   p->y=NULL;
   p->ident=NULL;
   p->ra=NULL;
   p->dec=NULL;
   p->magb=NULL;
   p->magv=NULL;
   p->magr=NULL;
   p->magi=NULL;

   /* ------------------------------------------------------------ */
   /* --- deuxieme partie. On alloue la memoire des pointeurs  --- */
   /* ------------------------------------------------------------ */
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->ttype,&p->tfields,&len,"p->ttype"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatbuilder for pointer ttype");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->tunit,&p->tfields,&len,"p->tunit"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatbuilder for pointer tunit");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=p->tfields;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->datatypes,&nombre,&taille,"p->datatypes"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatbuilder for pointer datatypes");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   /* --------------------------------------------------------------- */
   /* --- troisieme partie. On remplit les valeurs des pointeurs  --- */
   /* --------------------------------------------------------------- */
   sprintf(p->ttype[TT_TBLCAT_X],"x coordinate");
   sprintf(p->ttype[TT_TBLCAT_Y],"y coordinate");
   sprintf(p->ttype[TT_TBLCAT_IDENT],"pixel identification");
   sprintf(p->ttype[TT_TBLCAT_RA],"right ascension");
   sprintf(p->ttype[TT_TBLCAT_DEC],"declination");
   sprintf(p->ttype[TT_TBLCAT_MAGB],"magnitude");
   sprintf(p->ttype[TT_TBLCAT_MAGV],"magnitude");
   sprintf(p->ttype[TT_TBLCAT_MAGR],"magnitude");
   sprintf(p->ttype[TT_TBLCAT_MAGI],"magnitude");

   sprintf(p->tunit[TT_TBLCAT_X],"pixel");
   sprintf(p->tunit[TT_TBLCAT_Y],"pixel");
   sprintf(p->tunit[TT_TBLCAT_IDENT],"identification symbol");
   sprintf(p->tunit[TT_TBLCAT_RA],"deg");
   sprintf(p->tunit[TT_TBLCAT_DEC],"deg");
   sprintf(p->tunit[TT_TBLCAT_MAGB],"mag");
   sprintf(p->tunit[TT_TBLCAT_MAGV],"mag");
   sprintf(p->tunit[TT_TBLCAT_MAGR],"mag");
   sprintf(p->tunit[TT_TBLCAT_MAGI],"mag");

   p->datatypes[TT_TBLCAT_X]=TDOUBLE;
   p->datatypes[TT_TBLCAT_Y]=TDOUBLE;
   p->datatypes[TT_TBLCAT_IDENT]=TSHORT;
   p->datatypes[TT_TBLCAT_RA]=TDOUBLE;
   p->datatypes[TT_TBLCAT_DEC]=TDOUBLE;
   p->datatypes[TT_TBLCAT_MAGB]=TDOUBLE;
   p->datatypes[TT_TBLCAT_MAGV]=TDOUBLE;
   p->datatypes[TT_TBLCAT_MAGR]=TDOUBLE;
   p->datatypes[TT_TBLCAT_MAGI]=TDOUBLE;
   return(OK_DLL);
}

int tt_tblcatcreater(TT_TBL_CATALIST *p,int nrows)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int msg,nombre,taille;
   if (p->nrows!=0) {
      /* code-erreur sur pointeurs deja alloues ---*/
      return(TT_ERR_PTR_ALREADY_ALLOC);
   }
   if (nrows<1) {
      return(PB_DLL);
   }
   p->nrows=nrows;
   nombre=p->nrows;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->x,&nombre,&taille,"p->x"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater x");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->y,&nombre,&taille,"p->y"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater y");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=p->nrows;
   taille=sizeof(short);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->ident,&nombre,&taille,"p->ident"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater ident");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=p->nrows;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->ra,&nombre,&taille,"p->ra"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater ra");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->dec,&nombre,&taille,"p->dec"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater dec");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->magb,&nombre,&taille,"p->magb"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater magb");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->magv,&nombre,&taille,"p->magv"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater magv");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->magr,&nombre,&taille,"p->magr"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater magr");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->magi,&nombre,&taille,"p->magi"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_tblcatcreater magi");
      tt_tblcatdestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   return(OK_DLL);
}

int tt_tblcatdestroyer(TT_TBL_CATALIST *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   p->nrows=0;
   /* --- pour la description des champs de la table ---*/
   tt_util_free_ptrptr2((void***)&p->tform,"p->tform");
   tt_util_free_ptrptr2((void***)&p->ttype,"p->ttype");
   tt_util_free_ptrptr2((void***)&p->tunit,"p->tunit");
   tt_free2((void**)&p->datatypes,"p->datatypes");
   /* --- pour la description des donnees de la table ---*/
   tt_free2((void**)&p->x,"p->x");
   tt_free2((void**)&p->y,"p->y");
   tt_free2((void**)&p->ident,"p->ident");
   tt_free2((void**)&p->ra,"p->ra");
   tt_free2((void**)&p->dec,"p->dec");
   tt_free2((void**)&p->magb,"p->magb");
   tt_free2((void**)&p->magv,"p->magv");
   tt_free2((void**)&p->magr,"p->magr");
   tt_free2((void**)&p->magi,"p->magi");
   return(OK_DLL);
}
