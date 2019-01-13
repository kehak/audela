/* tt_fits1.c
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

int tt_imareturnkeyvalue(TT_IMA *p,char *keyname,char *value,int *datatype,char *comment,char *unit)
/***************************************************************************/
/* Retourne les parametres de la premiere occurence trouvee dans la liste  */
/* de mots cle de l'image *p.                                              */
/* on ne recherche que les arguments de mots cles non reserves.            */
/***************************************************************************/
/* datatype=0 en retour si l'occurence n'est pas trouvee.                  */
/***************************************************************************/
{
   int msg,found;
   int nbkeys,k;
   char **keynames=NULL;
   void **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;

   /* --- cree la nouvelle liste de mots cle ---*/
   if((msg=tt_imalistkeys(p,&nbkeys,(void*)(&keynames),&values,(void*)(&comments),(void*)(&units),(void*)(&datatypes)))!=0) {
      return(msg);
   }

   /* --- recherche du mot dans la liste ---*/
   *datatype=0;
   for (found=TT_NO,k=0;k<nbkeys;k++) {
      if (strcmp(keynames[k],keyname)==0) {
	 strcpy(comment,comments[k]);
	 strcpy(unit,units[k]);
	 *datatype=(int)(datatypes[k]);
	 if (*datatype==TSTRING) {
	    sprintf(value,"%s",(char*)(values[k]));
	 } else if (*datatype==TBYTE) {
	    sprintf(value,"%d",*(char*)(values[k]));
	 } else if (*datatype==TSHORT) {
	    sprintf(value,"%d",*(short*)(values[k]));
	 } else if (*datatype==TUSHORT) {
	    sprintf(value,"%d",*(unsigned short*)(values[k]));
	 } else if (*datatype==TINT) {
	    sprintf(value,"%d",*(int*)(values[k]));
	 } else if (*datatype==TLONG) {
	    sprintf(value,"%ld",*(long*)(values[k]));
	 } else if (*datatype==TULONG) {
	    sprintf(value,"%ld",*(unsigned long*)(values[k]));
	 } else if (*datatype==TFLOAT) {
       if (fabs((float)*(float*)(values[k]))<0.1) {
	       sprintf(value,"%e",(float)*(float*)(values[k]));
       } else {
	       sprintf(value,"%g",(float)*(float*)(values[k]));
       }
	 } else if (*datatype==TDOUBLE) {
	    sprintf(value,"%20.15g",*(double*)(values[k]));
	 } else {
	    strcpy(value,"");
	 }
	 found=TT_YES;
	 break;
      }
   }
   if(found==TT_NO) {
      strcpy(value,"");
      strcpy(comment,"");
      strcpy(unit,"");
      datatype=0;
      /* on se sert de datatype=0 dans tt_util2.c */
   }
   tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
   tt_util_free_ptrptr2((void***)&values,"p->values");
   tt_util_free_ptrptr2((void***)&comments,"p->comments");
   tt_util_free_ptrptr2((void***)&units,"p->units");
   tt_free2((void**)&datatypes,"p->datatypes");
   return(OK_DLL);
}

int tt_imalistkeys(TT_IMA *p,int *nkeys,void ***pkeynames,void ***pvalues,void ***pcomments,void ***punits,void **pdatatypes)
/***************************************************************************/
/* Remplit une liste de mots cle avec les listes de l'image                */
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
         tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer keynames");
	 return(TT_ERR_PB_MALLOC);
      }
      values=NULL;
      len=(int)(FLEN_VALUE);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&values,&nbkeys,&len,"p->values"))!=0) {
        tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer values");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 return(TT_ERR_PB_MALLOC);
      }
      comments=NULL;
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&comments,&nbkeys,&len,"p->comments"))!=0) {
         tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer comments");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 tt_util_free_ptrptr2((void***)&values,"p->values");
	 return(TT_ERR_PB_MALLOC);
      }
      units=NULL;
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&units,&nbkeys,&len,"p->units"))!=0) {
        tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer units");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 tt_util_free_ptrptr2((void***)&values,"p->values");
	 tt_util_free_ptrptr2((void***)&comments,"p->comments");
	 return(TT_ERR_PB_MALLOC);
      }
      datatypes=NULL;
      nombre=nbkeys;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&datatypes,&nombre,&taille,"p->datatypes"))!=0) {
        tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer datatypes");
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

int tt_imalistallkeys(TT_IMA *p,int *nkeys,void ***pkeynames,void ***pvalues,void ***pcomments,void ***punits,void **pdatatypes)
/***************************************************************************/
/* Remplit une liste de mots cle avec les listes de l'image                */
/***************************************************************************/
/* Pas d'exclusion des mots cle reserves.                                  */
/* Attention, ***values est un pointeur de char.                           */
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
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer keynames");
	 return(TT_ERR_PB_MALLOC);
      }
      values=NULL;
      len=(int)(FLEN_VALUE);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&values,&nbkeys,&len,"p->values"))!=0) {
	tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer values");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 return(TT_ERR_PB_MALLOC);
      }
      comments=NULL;
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&comments,&nbkeys,&len,"p->comments"))!=0) {
	 tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer comments");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 tt_util_free_ptrptr2((void***)&values,"p->values");
	 return(TT_ERR_PB_MALLOC);
      }
      units=NULL;
      len=(int)(FLEN_COMMENT);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&units,&nbkeys,&len,"p->units"))!=0) {
	tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer units");
	 tt_util_free_ptrptr2((void***)&keynames,"p->keynames");
	 tt_util_free_ptrptr2((void***)&values,"p->values");
	 tt_util_free_ptrptr2((void***)&comments,"p->comments");
	 return(TT_ERR_PB_MALLOC);
      }
      datatypes=NULL;
      nombre=nbkeys;
      taille=sizeof(int);
      if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&datatypes,&nombre,&taille,"p->datatypes"))!=0) {
	tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imalistkeys for pointer datatypes");
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
	       match=0;
	       if (match==0) {
		  for (already=0,kk=0;kk<nbkeys;kk++) { if (strcmp(p->new_keynames[k],keynames[kk])==0) {already=1; break;} }
		  if (already==0) {
		     datatypes[nbkeys]=p->new_datatypes[k];
		     strcpy(keynames[nbkeys],p->new_keynames[k]);
		     /*tt_values2values(p->new_values[k],values[nbkeys],datatypes[nbkeys]);*/
		     strcpy(values[nbkeys],p->new_values[k]);
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
	       match=0;
	       if (match==0) {
		  for (already=0,kk=0;kk<nbkeys;kk++) { 
           if (strcmp(p->keynames[k],keynames[kk])==0) {
              already=1;
              break;
         } 
        }
		  if (already==0) {
		     datatypes[nbkeys]=p->datatypes[k];
		     strcpy(keynames[nbkeys],p->keynames[k]);
		     /*tt_values2values(p->values[k],values[nbkeys],datatypes[nbkeys]);*/
		     strcpy(values[nbkeys],p->values[k]);
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
	       match=0;
	       if (match==0) {
		  for (already=0,kk=0;kk<nbkeys;kk++) { if (strcmp(p->ref_keynames[k],keynames[kk])==0) {already=1; break;} }
		  if (already==0) {
		     datatypes[nbkeys]=p->ref_datatypes[k];
		     strcpy(keynames[nbkeys],p->ref_keynames[k]);
		     /*tt_values2values(p->ref_values[k],values[nbkeys],datatypes[nbkeys]);*/
		     strcpy(values[nbkeys],p->ref_values[k]);
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

int tt_imadelnewkey(TT_IMA *p,char *keyname)
/***************************************************************************/
/* Enleve une entree a la liste des new_* dans l'entete.                   */
/***************************************************************************/
/***************************************************************************/
{
   int nbnewkey,indice,k;
   if (p->new_keyused==TT_YES) {
      /* --- compte le nombre de mots dans new_* ---*/
      for (nbnewkey=(p->new_nbkeys)-1,k=0;k<(p->new_nbkeys);k++) {
	 if (strcmp(p->new_keynames[k],"")==0) {
	    nbnewkey=k;
	    break;
	 }
      }
      if (((int)strlen(keyname))>((int)(FLEN_KEYWORD-1))) {
	 keyname[(int)(FLEN_KEYWORD-1)]='\0';
      }
      /* --- indice du mot a rechercher dans new_* ---*/
      for (indice=0,k=0;k<nbnewkey;k++) {
	 if (strcmp(p->new_keynames[k],keyname)==0) {
	    indice=k;
	    break;
	 }
      }
      /* --- le mot cle n'est pas trouve ---*/
      if (indice==0) { return(OK_DLL); }
      /* --- on decale toutes les lignes ---*/
      for (k=indice;k<(nbnewkey-1);k++) {
	 strcpy(p->new_keynames[k],p->new_keynames[k+1]);
	 strcpy(p->new_comments[k],p->new_comments[k+1]);
	 strcpy(p->new_units[k],p->new_units[k+1]);
	 strcpy(p->new_values[k],p->new_values[k+1]);
	 p->new_datatypes[k]=p->new_datatypes[k+1];
      }
      /* --- on met a zero la derniere ligne ---*/
      k=nbnewkey-1;
      strcpy(p->new_keynames[k],"");
      strcpy(p->new_comments[k],"");
      strcpy(p->new_units[k],"");
      strcpy(p->new_values[k],"");
      p->new_datatypes[k]=0;
      /* --- compte le nombre de mots dans new_* ---*/
      for (k=0;k<(p->new_nbkeys);k++) {
	 if (strcmp(p->new_keynames[k],"")==0) {
	    break;
	 }
      }
   }
   return(OK_DLL);
}

int tt_imareallocnewkey(TT_IMA *p,int nbkeys2add)
/***************************************************************************/
/* redimensionne les pointeurs newkeys avec nbkeys2add nouveaux mots       */
/***************************************************************************/
{
	int k;
   int len,msg;
   int nombre,taille;
	TT_IMA pp_tmp,*p_tmp;
	p_tmp=&pp_tmp;
	if ((msg=tt_imabuilder(p_tmp))!=OK_DLL) {
		return(msg);
	}
	/* --- on libere les pointeurs temporaires ---*/
	tt_util_free_ptrptr2((void***)&p_tmp->new_keynames,"p_tmp->new_keynames");
	tt_util_free_ptrptr2((void***)&p_tmp->new_values,"p_tmp->new_values");
	tt_util_free_ptrptr2((void***)&p_tmp->new_comments,"p_tmp->new_comments");
	tt_util_free_ptrptr2((void***)&p_tmp->new_units,"p_tmp->new_units");
	tt_free2((void**)&p_tmp->new_datatypes,"p_tmp->new_datatypes");
	/* --- On alloue la memoire des pointeurs temporaires --- */
	p_tmp->new_nbkeys=p->new_nbkeys;
	len=(int)(FLEN_KEYWORD);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p_tmp->new_keynames,&p_tmp->new_nbkeys,&len,"p_tmp->new_keynames"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_keynames");
		tt_imadestroyer(p_tmp);
		return(TT_ERR_PB_MALLOC);
	}
	len=(int)(FLEN_VALUE);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p_tmp->new_values,&p_tmp->new_nbkeys,&len,"p_tmp->new_values"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_values");
		tt_imadestroyer(p_tmp);
		return(TT_ERR_PB_MALLOC);
	}
	len=(int)(FLEN_COMMENT);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p_tmp->new_comments,&p_tmp->new_nbkeys,&len,"p_tmp->new_comments"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_comments");
		tt_imadestroyer(p_tmp);
		return(TT_ERR_PB_MALLOC);
	}
	len=(int)(FLEN_COMMENT);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p_tmp->new_units,&p_tmp->new_nbkeys,&len,"p_tmp->new_units"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_units");
		tt_imadestroyer(p_tmp);
		return(TT_ERR_PB_MALLOC);
	}
	nombre=p_tmp->new_nbkeys;
	taille=sizeof(int);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p_tmp->new_datatypes,&nombre,&taille,"p_tmp->new_datatypes"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_datatypes");
		tt_imadestroyer(p_tmp);
		return(TT_ERR_PB_MALLOC);
	}
	/* --- copie les valeurs vers le pointeur temporaire ---*/
	for (k=0;k<p_tmp->new_nbkeys;k++) {
		strcpy(p_tmp->new_keynames[k],p->new_keynames[k]);
		strcpy(p_tmp->new_values[k],p->new_values[k]);
		strcpy(p_tmp->new_comments[k],p->new_comments[k]);
		strcpy(p_tmp->new_units[k],p->new_units[k]);
		p_tmp->new_datatypes[k]=p->new_datatypes[k];
	}
	/* --- libere les pointeurs du pointeur de l'image ---*/
	tt_util_free_ptrptr2((void***)&p->new_keynames,"p->new_keynames");
	tt_util_free_ptrptr2((void***)&p->new_values,"p->new_values");
	tt_util_free_ptrptr2((void***)&p->new_comments,"p->new_comments");
	tt_util_free_ptrptr2((void***)&p->new_units,"p->new_units");
	tt_free2((void**)&p->new_datatypes,"p->new_datatypes");
	/* --- On alloue une memoire plus grande pour les pointeurs image --- */
	p->new_nbkeys+=nbkeys2add;
	len=(int)(FLEN_KEYWORD);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_keynames,&p->new_nbkeys,&len,"p->new_keynames"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_keynames");
		tt_imadestroyer(p);
		return(TT_ERR_PB_MALLOC);
	}
	len=(int)(FLEN_VALUE);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_values,&p->new_nbkeys,&len,"p->new_values"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_values");
		tt_imadestroyer(p);
		return(TT_ERR_PB_MALLOC);
	}
	len=(int)(FLEN_COMMENT);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_comments,&p->new_nbkeys,&len,"p->new_comments"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_comments");
		tt_imadestroyer(p);
		return(TT_ERR_PB_MALLOC);
	}
	len=(int)(FLEN_COMMENT);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_units,&p->new_nbkeys,&len,"p->new_units"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_units");
		tt_imadestroyer(p);
		return(TT_ERR_PB_MALLOC);
	}
	nombre=p->new_nbkeys;
	taille=sizeof(int);
	if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->new_datatypes,&nombre,&taille,"p->new_datatypes"))!=0) {
		tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imanewkeychar for pointer new_datatypes");
		tt_imadestroyer(p);
		return(TT_ERR_PB_MALLOC);
	}
	/* --- copie les valeurs temporaires vers le pointeur image ---*/
	for (k=0;k<p_tmp->new_nbkeys;k++) {
		strcpy(p->new_keynames[k],p_tmp->new_keynames[k]);
		strcpy(p->new_values[k],p_tmp->new_values[k]);
		strcpy(p->new_comments[k],p_tmp->new_comments[k]);
		strcpy(p->new_units[k],p_tmp->new_units[k]);
		p->new_datatypes[k]=p_tmp->new_datatypes[k];
	}
	/* --- on libere les pointeurs temporaires ---*/
	tt_imadestroyer(p_tmp);
	return(OK_DLL);
}

int tt_imanewkeychar(TT_IMA *p,char *keyname,char *value,int datatype,char *comment,char *unit)
/***************************************************************************/
/* ajoute une nouvelle entree a la liste des new_* dans l'entete.          */
/***************************************************************************/
/* ici, values est un char **                                              */
/***************************************************************************/
{
   int knew,k,msg;
	/* Traite le cas ou l'on a atteind la limite des p->new_nbkeys */
	/* Il faut alors redimensionner les pointeurs avec 250 mots clés de plus */
	k=(p->new_nbkeys)-1;
	if (strcmp(p->new_keynames[k],"")!=0) {
		if ((msg=tt_imareallocnewkey(p,250))!=OK_DLL) {
			return(msg);
		}
	}
	/* recherche le dernier indice vide */
   p->new_keyused=TT_YES;
   for (knew=(p->new_nbkeys)-1,k=0;k<(p->new_nbkeys);k++) {
		if (strcmp(p->new_keynames[k],"")==0) {
			knew=k;
			break;
      }
   }
	/* Effectue l'ajout de la card */
   if (((int)strlen(keyname))>((int)(FLEN_KEYWORD-1))) {
      keyname[(int)(FLEN_KEYWORD-1)]='\0';
   }
   strcpy(p->new_keynames[knew],keyname);
   if (comment!=NULL) {
      if (((int)strlen(comment))>((int)(FLEN_COMMENT-1))) {
	 comment[(int)(FLEN_COMMENT-1)]='\0';
      }
      strcpy(p->new_comments[knew],comment);
   } else {
      strcpy(p->new_comments[knew],"");
   }
   if (unit!=NULL) {
      if (((int)strlen(unit))>((int)(FLEN_COMMENT-1))) {
	 unit[(int)(FLEN_COMMENT-1)]='\0';
      }
      strcpy(p->new_units[knew],unit);
   } else {
      strcpy(p->new_units[knew],"");
   }
   if (value!=NULL) {
      if (((int)strlen(value))>((int)(FLEN_VALUE-1))) {
	 unit[(int)(FLEN_VALUE-1)]='\0';
      }
      strcpy(p->new_values[knew],value);
   } else {
      strcpy(p->new_values[knew],"");
   }
   p->new_datatypes[knew]=datatype;
   return(OK_DLL);
}


int tt_imanewkey(TT_IMA *p,char *keyname,void *value,int datatype,char *comment,char *unit)
/***************************************************************************/
/* ajoute une nouvelle entree a la liste des new_* dans l'entete.          */
/***************************************************************************/
/***************************************************************************/
{
   int knew,k;
   char *string_v;
   p->new_keyused=TT_YES;
   for (knew=(p->new_nbkeys)-1,k=0;k<(p->new_nbkeys);k++) {
      if (strcmp(p->new_keynames[k],"")==0) {
	 knew=k;
	 break;
      }
   }
   if (((int)strlen(keyname))>((int)(FLEN_KEYWORD-1))) {
      keyname[(int)(FLEN_KEYWORD-1)]='\0';
   }
   strcpy(p->new_keynames[knew],keyname);
   if (comment!=NULL) {
      if (((int)strlen(comment))>((int)(FLEN_COMMENT-1))) {
         comment[(int)(FLEN_COMMENT-1)]='\0';
      }
      strcpy(p->new_comments[knew],comment);
   } else {
      strcpy(p->new_comments[knew],"");
   }
   if (unit!=NULL) {
      if (((int)strlen(unit))>((int)(FLEN_COMMENT-1))) {
         unit[(int)(FLEN_COMMENT-1)]='\0';
      }
      strcpy(p->new_units[knew],unit);
   } else {
      strcpy(p->new_units[knew],"");
   }
   p->new_datatypes[knew]=datatype;
   if (datatype==TSTRING) {
      string_v=(char*)(value);
      if (((int)strlen(string_v))>((int)(FLEN_VALUE-1))) {
	 string_v[(int)(FLEN_COMMENT-1)]='\0';
      }
      strcpy(p->new_values[knew],string_v);
   /* il faudrait metre aussi le logical */
   } else if (datatype==TBYTE) {
      sprintf(p->new_values[knew],"%d",*(char*)(value));
   } else if (datatype==TSHORT) {
      sprintf(p->new_values[knew],"%hd",*(short*)(value));
   } else if (datatype==TUSHORT) {
      sprintf(p->new_values[knew],"%uhd",*(unsigned short*)(value));
   } else if (datatype==TINT) {
      sprintf(p->new_values[knew],"%d",*(int*)(value));
   } else if (datatype==TLONG) {
      sprintf(p->new_values[knew],"%ld",*(long*)(value));
   } else if (datatype==TULONG) {
      sprintf(p->new_values[knew],"%ld",*(unsigned long*)(value));
   } else if (datatype==TFLOAT) {
      /*sprintf(p->new_values[knew],"%20.15le",(double)*(float*)(value)); incompatible DEC */
      sprintf(p->new_values[knew],"%20.15e",(double)*(float*)(value));
   } else if (datatype==TDOUBLE) {
      /*sprintf(p->new_values[knew],"%20.15le",*(double*)(value)); incompatible DEC */
      sprintf(p->new_values[knew],"%20.15e",*(double*)(value));
   } else {
      strcpy(p->new_values[knew],"");
   }
   return(OK_DLL);
}

int tt_imanewkeytt(TT_IMA *p,char *value,char *comment,char *unit)
/***************************************************************************/
/* ajoute une nouvelle entree TT a la liste des new_* dans l'entete.       */
/***************************************************************************/
/* L'indice de TT est calcule automatiquement.                             */
/* L'argumentest de type TSTRING                                           */
/***************************************************************************/
{
   int k,n,nmax,knew;
   char c0,c1,*reste;
   char keyname[FLEN_KEYWORD];
   nmax=0;
   if ((p->keyused==TT_YES)&&(p->nbkeys>0)) {
      for (k=0;k<(p->nbkeys);k++) {
			if (strlen(p->keynames[k])>=3) {
				c0=p->keynames[k][0];c1=p->keynames[k][1];
				if ((c0=='T')&&(c1=='T')) {
					reste=(p->keynames[k]+(int)(2));
					n=atoi(reste);if (n>nmax) {nmax=n;}
				}
			}
      }
   }
   if ((p->ref_keyused==TT_YES)&&(p->ref_nbkeys>0)) {
      for (k=0;k<(p->ref_nbkeys);k++) {
			if (strlen(p->ref_keynames[k])>=3) {
				c0=p->ref_keynames[k][0];c1=p->ref_keynames[k][1];
				if ((c0=='T')&&(c1=='T')) {
					reste=(p->ref_keynames[k])+(int)(2);n=atoi(reste);if (n>nmax) {nmax=n;}
				}
			}
      }
   }
   knew=0;
   if ((p->new_keyused==TT_YES)&&(p->new_nbkeys>0)) {
      for (k=0;k<(p->new_nbkeys);k++) {
			if (strlen(p->new_keynames[k])>=3) {
				c0=p->new_keynames[k][0];
				c1=p->new_keynames[k][1];
				if ((c0=='T')&&(c1=='T')) {
					reste=(p->new_keynames[k])+(int)(2);
					n=atoi(reste);
					if (n>nmax) {nmax=n;}
				}
			}
			if (strcmp(p->new_keynames[k],"")==0) {
				knew=k;
				break;
			}
      }
   }
   p->new_keyused=TT_YES;
   n=nmax+1;
   sprintf(keyname,"TT%d",n);
   tt_imanewkeychar(p,keyname,value,TSTRING,comment,unit);
	/*
   strcpy(p->new_keynames[knew],keyname);
   strcpy(p->new_values[knew],value);
   strcpy(p->new_comments[knew],comment);
   strcpy(p->new_units[knew],unit);
   p->new_datatypes[knew]=TSTRING;
	*/
   return(OK_DLL);
}

int tt_imafilenamespliter(char *fullname,char *path,char *name,char *suffix,int *hdunum)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int len,n1,n2,n3,k;
   char xpath[FLEN_FILENAME];
   char xname[FLEN_FILENAME];
   char xsuffix[FLEN_FILENAME];
   char mot[FLEN_FILENAME];
   char message[TT_MAXLIGNE];
   int xhdunum;
   int pos_last_point,pos_last_pcoma,pos_last_slash;

   len=(int)strlen(fullname);
   /* --- repere la position des derniers . ; / \ ---*/
   pos_last_point=-1;
   pos_last_pcoma=-1;
   pos_last_slash=-1;
   for (k=0;k<len;k++) {
      if ((fullname[k]=='\\')||(fullname[k]=='/')) {pos_last_slash=k;}
      if (fullname[k]=='.') {pos_last_point=k;}
      if (fullname[k]==';') {pos_last_pcoma=k;}
   }
   if (pos_last_point<pos_last_slash) {
	   /* --- cas ou le . est dans le nom du repertoire */
	   /*     et non en tant qu'extension */
	   pos_last_point=-1;
   }

   /* --- extrait le numero de l'entete ---*/
   if (pos_last_pcoma==-1) {
      xhdunum=0;
      n1=len;
   } else {
      strcpy(mot,fullname+pos_last_pcoma+1);
      xhdunum=atoi(mot);
      n1=pos_last_pcoma;
   }

   /*                  n3   n2  n1
		       |    |   | |
   0123456789 123456789 123456789 1
   /tytyty/ytyty/ytyty/popo5.fit;1
   */
   /* --- extrait l'extension ---*/
   if (pos_last_point==-1) {
      strcpy(xsuffix,".fit");
      if (pos_last_pcoma==-1) {
	 n2=len;
      } else {
	 n2=pos_last_pcoma;
      }
   } else {
      strncpy(xsuffix,fullname+pos_last_point,n1-pos_last_point);
      xsuffix[n1-pos_last_point]='\0';
      n2=pos_last_point;
   }

   /* --- extrait le repertoire ---*/
   if (pos_last_slash==-1) {
      n3=0;
      strcpy(xpath,"");
   } else {
      n3=1+pos_last_slash;
      strncpy(xpath,fullname,n3);
      xpath[n3]='\0';
   }

   /* --- extrait le nom ---*/
   if ((n2-n3)==0) {
      strcpy(xname,"");
   } else {
      strncpy(xname,fullname+n3,n2-n3);
      xname[n2-n3]='\0';
   }
   /*printf("<%s><%s><%s><%d>\n",xpath,xname,xsuffix,xhdunum);*/

   len=strlen(xpath)+strlen(xname)+strlen(xsuffix);
   if (len>=FLEN_FILENAME) {
      len=FLEN_FILENAME;
      sprintf(message,"Pb full filename too long limited to %d chars (%s%s%s)",len,xpath,xname,xsuffix);
      tt_errlog("",TT_ERR_FILENAME_TOO_LONG,message);
      return(TT_ERR_FILENAME_TOO_LONG);
   }
   strcpy(path,xpath);
   strcpy(name,xname);
   strcpy(suffix,xsuffix);
   *hdunum=xhdunum;

   return(OK_DLL);
}

char *tt_imafilecater(char *path, char *name, char *suffix)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   static char chaine[FLEN_FILENAME];
   char slash[2];
   int pos_last_slash,len,k;
   int pos_last_aslash;

   len=(int)strlen(path);
   if (len!=0) {
      /* --- repere la position des derniers / \ ---*/
      pos_last_slash=-1;
      pos_last_aslash=-1;
      for (k=0;k<len;k++) {
	 if (path[k]=='\\') {pos_last_aslash=k;}
	 if (path[k]=='/') {pos_last_slash=k;}
      }
      if ((pos_last_aslash==-1)&&(pos_last_slash==-1)) {
#ifdef FILE_DOS
	 strcpy(slash,"\\");
#endif
#ifdef FILE_UNIX
	 strcpy(slash,"/");
#endif
      } else if (pos_last_aslash>pos_last_slash) {
	 strcpy(slash,"\\");
      } else {
	 strcpy(slash,"/");
      }
      if (path[len-1]==slash[0]) {
	 strcpy(slash,"");
      }
   } else {
      strcpy(slash,"");
   }
   sprintf(chaine,"%s%s%s%s",path,slash,name,suffix);
   return(chaine);
}

int tt_imasaver(TT_IMA *p,char *fullname,int bitpix)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int nbhdu,typehdu;
   int msg;
   int *hdunum=NULL,hdunum_keys;
   int nbkeys;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char message[TT_MAXLIGNE];

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

   /* --- sauve l'image avec une entete minimale ---*/
   typehdu=IMAGE_HDU;
   p->save_bitpix=bitpix;
   if ((msg=libfiles_main(FS_MACR_WRITE,11,p->save_fullname,hdunum,&typehdu,
    NULL,NULL,NULL,
    &p->naxis,p->naxes,&p->save_bitpix,&p->datatype,p->p))!=0) {
      if (msg!=412) {
	 return(msg);
      }
   }

   /* --- cree la nouvelle liste de mots cle ---*/
   tt_imalistkeys(p,&nbkeys,(void***)(&keynames),(void***)(&values),(void***)(&comments),(void***)(&units),(void**)(&datatypes));

   /* --- sauvegarde de la nouvelle liste de mots cle ---*/
   hdunum_keys=(hdunum==NULL)?1:((*hdunum)+1);
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

int tt_values2values(char *value_string,char *value,int datatype)
/***************************************************************************/
/* Transforme une chaine de char en *value d'un datatype donne             */
/***************************************************************************/
/***************************************************************************/
{
   if (datatype==TDOUBLE) {
      *(double*)(value)=(double)atof(value_string);
   } else if (datatype==TFLOAT) {
      *(float*)(value)=(float)atof(value_string);
   } else if (datatype==TSHORT) {
      *(short*)(value)=(short)atoi(value_string);
   } else if (datatype==TBYTE) {
      *(unsigned char*)(value)=(unsigned char)atoi(value_string);
   } else if (datatype==TUSHORT) {
      *(unsigned short*)(value)=(unsigned short)atoi(value_string);
   } else if (datatype==TLOGICAL) {
      strcpy(value,value_string);
   } else if (datatype==TINT) {
      *(int*)(value)=(int)atoi(value_string);
   } else if (datatype==TLONG) {
      *(long*)(value)=(long)atoi(value_string);
   } else if (datatype==TULONG) {
      *(unsigned long*)(value)=(unsigned long)atoi(value_string);
   } else {
      strcpy(value,value_string);
   }
   return(OK_DLL);
}

int tt_imaloader(TT_IMA *p,char *fullname,long firstelem,long nelements)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int nbhdu,typehdu;
   int msg;
   char message[TT_MAXLIGNE];
   int k;
   double bzero,bscale;

   if ((&p->naxes==NULL)||(&p->p==NULL)) {
      /* code-erreur sur pointeurs deja alloues ---*/
      sprintf(message,"Pointers naxes or p already allocated in tt_imaloader");
      tt_errlog("",TT_ERR_PTR_ALREADY_ALLOC,message);
      return(TT_ERR_PTR_ALREADY_ALLOC);
   }

   /* --- identification du nom de fichier FITS ---*/
   if ((msg=tt_imafilenamespliter(fullname,p->load_path,p->load_name,p->load_suffix,&p->load_hdunum))!=0) { return(msg); }
   strcpy(p->load_fullname,tt_imafilecater(p->load_path,p->load_name,p->load_suffix));

   /* --- Recherche le nombre d'entetes dans le fichier Fits ---*/
   nbhdu=0;
   /* nbhdu va provoquer une erreur dans le service FS_MACR_READ mais   */
   /* il va nous retourner le veritable nombre de HDUs dans la variable */
   /* nbhdu.                                                            */

   /*printf("1\n");*/
   msg=libfiles_main(FS_MACR_READ,2,p->load_fullname,&nbhdu);
   /* FS_ERR_HDUNUM_OVER est un code erreur defini dans libfiles.h */
   /*printf("2\n");*/

   if (msg!=FS_ERR_HDUNUM_OVER) {
      sprintf(message,"Problem concerning image %s",fullname);
      tt_errlog("",msg,message);
      return(msg);
   }
   if (p->load_hdunum==0) {
      p->load_hdunum=1;
   }
   if ((p->load_hdunum<0)||(p->load_hdunum>nbhdu)) {
      sprintf(message,"Problem concerning image %s",fullname);
      tt_errlog("",TT_ERR_HDUNUM_OVER,message);
      return(TT_ERR_HDUNUM_OVER);
   }

   /* --- recherche le type de l'entete dans le fichier Fits ---*/
   typehdu=-2;
   /* Il faut mettre typehdu=-2 pour provoquer une erreur dans le service*/
   /* FS_MACR_READ qui retournera neanmoins le veritable type du HDU     */
   /* selectionne dans la variable typehdu.                              */
   msg=libfiles_main(FS_MACR_READ,3,p->load_fullname,&p->load_hdunum,&typehdu);
   if (msg==FS_ERR_HDU_NOT_SAME_TYPE) {
      if (typehdu!=IMAGE_HDU) {
        sprintf(message,"The file %s is not an image",p->load_fullname);
        tt_errlog("",TT_ERR_HDU_NOT_IMAGE,message);
	 return(TT_ERR_HDU_NOT_IMAGE);
      }
   } else {
      return(msg);
   }
   p->load_typehdu=IMAGE_HDU;

   p->firstelem=(firstelem<0)?0:firstelem;
   p->nelements=(nelements<0)?0:nelements;

   if ((msg=libfiles_main(FS_MACR_READ,10,p->load_fullname,&p->load_hdunum,&p->load_typehdu,
    &p->firstelem,&p->nelements,&p->naxis,&p->naxes,&p->load_bitpix,&p->datatype,&p->p))!=0) {
      return(msg);
   }
#ifdef TT_MOUCHARDPTR
   /* --- debug ---*/
   tt_util_mouchard("p->p",1,(int)(p->p));
#endif
   p->naxis1=(int)(p->naxes[0]);
   p->naxis2=(int)(p->naxes[1]);
   p->naxis3=(int)(p->naxes[2]);
   if (p->naxis2==0) { p->naxis2=1; }

   /* --- RAZ des mots cles dans l'image de travail ---*/
   if (p->keyused==(TT_YES)) {
      tt_util_free_ptrptr2((void***)&p->keynames,"p->keynames");
      tt_util_free_ptrptr2((void***)&p->values,"p->values");
      tt_util_free_ptrptr2((void***)&p->comments,"p->comments");
      tt_util_free_ptrptr2((void***)&p->units,"p->units");
      tt_free2((void**)&p->datatypes,"p->datatypes");
      p->keyused=(TT_NO);
      p->keynames=NULL;
      p->values=NULL;
      p->comments=NULL;
      p->units=NULL;
      p->datatypes=NULL;
   }
   p->nbkeys=0;
   /* Le fait de placer un nbkeys==0 indique a la fonction de */
   /* retourner l'ensemble des mots cles et leur valeurs.     */
   /* En retour, la fonction indique le veritable nbkeys,     */
   /* effectue des 'calloc' sur **keynames, *keynames, etc... */
   /* et remplit leurs valeurs.                               */
   if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,p->load_fullname,&p->load_hdunum,&p->nbkeys,
    &p->keynames,&p->comments,&p->units,&p->datatypes,&p->values))!=0) {
       return(msg);
   }
   /*printf("!! %p %p %p\n",p->units,p->datatypes,p->values);*/
   p->keyused=TT_YES;
   tt_dateobs_release(p,0);
   /*tt_astrom_release(p);*/
   /*-- recherche si l'on est en unsigned --*/
   if ((p->load_bitpix==SHORT_IMG)||(p->load_bitpix==LONG_IMG)) {
      bscale=1.;
      bzero=0.;
      for (k=0;k<p->nbkeys;k++) {
         if (strcmp(p->keynames[k],"BSCALE")==0) { bscale=atof(p->values[k]); }
         if (strcmp(p->keynames[k],"BZERO")==0) { bzero=atof(p->values[k]); }
      }
      if (bscale==(double)(1)) {
         if ((bzero==(double)(32768))&&(p->load_bitpix==SHORT_IMG)) {
            p->load_bitpix=USHORT_IMG;
	 } else if ((bzero==(double)(2147483648.))&&(p->load_bitpix==LONG_IMG)) {
            p->load_bitpix=ULONG_IMG;
         }
      }
   }

   return(OK_DLL);
}

int tt_imarefheader(TT_IMA *p,char *fullname)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int nbhdu,typehdu;
   int msg;
   char message[TT_MAXLIGNE];

   /* --- identification du nom de fichier FITS ---*/
   if ((msg=tt_imafilenamespliter(fullname,p->ref_path,p->ref_name,p->ref_suffix,&p->ref_hdunum))!=0) { return(msg); }
   strcpy(p->ref_fullname,tt_imafilecater(p->ref_path,p->ref_name,p->ref_suffix));

   /* --- Recherche le nombre d'entetes dans le fichier Fits ---*/
   nbhdu=0;
   /* nbhdu va provoquer une erreur dans le service FS_MACR_READ mais   */
   /* il va nous retourner le veritable nombre de HDUs dans la variable */
   /* nbhdu.                                                            */
   msg=libfiles_main(FS_MACR_READ,2,p->ref_fullname,&nbhdu);
   /* FS_ERR_HDUNUM_OVER est un code erreur defini dans libfiles.h */
   if (msg!=FS_ERR_HDUNUM_OVER) {
     sprintf(message,"Problem concerning reference image %s",p->ref_fullname);
     tt_errlog("",msg,message);
      return(msg);
   }
   if (p->ref_hdunum==0) {
      p->ref_hdunum=1;
   }
   if ((p->ref_hdunum<0)||(p->ref_hdunum>nbhdu)) {
      sprintf(message,"Problem concerning reference image %s",p->ref_fullname);
      tt_errlog("",TT_ERR_HDUNUM_OVER,message);
      return(TT_ERR_HDUNUM_OVER);
   }

   /* --- recherche le type de l'entete dans le fichier Fits ---*/
   typehdu=-2;
   /* Il faut mettre typehdu=-2 pour provoquer une erreur dans le service*/
   /* FS_MACR_READ qui retournera neanmoins le veritable type du HDU     */
   /* selectionne dans la variable typehdu.                              */
   msg=libfiles_main(FS_MACR_READ,3,p->ref_fullname,&p->ref_hdunum,&typehdu);
   if (msg==FS_ERR_HDU_NOT_SAME_TYPE) {
      if (typehdu!=IMAGE_HDU) {
         sprintf(message,"File %s is not an image",p->ref_fullname);
         tt_errlog("",TT_ERR_HDU_NOT_IMAGE,message);
	 return(TT_ERR_HDU_NOT_IMAGE);
      }
   } else {
      return(msg);
   }
   p->ref_typehdu=IMAGE_HDU;

   /* --- RAZ des mots cles dans l'image de travail ---*/
   if (p->ref_keyused==(TT_YES)) {
      tt_util_free_ptrptr2((void***)&p->ref_keynames,"p->ref_keynames");
      tt_util_free_ptrptr2((void***)&p->ref_values,"p->ref_values");
      tt_util_free_ptrptr2((void***)&p->ref_comments,"p->ref_comments");
      tt_util_free_ptrptr2((void***)&p->ref_units,"p->ref_units");
      tt_free2((void**)&p->ref_datatypes,"p->ref_datatypes");
      p->ref_keyused=(TT_NO);
      p->ref_keynames=NULL;
      p->ref_values=NULL;
      p->ref_comments=NULL;
      p->ref_units=NULL;
      p->ref_datatypes=NULL;
   }
   p->ref_nbkeys=0;
   /* Le fait de placer un nbkeys==0 indique a la fonction de */
   /* retourner l'ensemble des mots cles et leur valeurs.     */
   /* En retour, la fonction indique le veritable nbkeys,     */
   /* effectue des 'calloc' sur **keynames, *keynames, etc... */
   /* et remplit leurs valeurs.                               */
   if ((msg=libfiles_main(FS_MACR_READ_KEYS,8,p->ref_fullname,&p->ref_hdunum,&p->ref_nbkeys,
    &p->ref_keynames,&p->ref_comments,&p->ref_units,&p->ref_datatypes,&p->ref_values))!=0) {
       return(msg);
   }
   /*printf("!! %p %p %p\n",p->ref_units,p->ref_datatypes,p->ref_values);*/
   p->ref_keyused=TT_YES;
   tt_dateobs_release(p,2);

   return(OK_DLL);
}

int tt_imabuilder(TT_IMA *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int len,msg;
   int taille,nombre;
   /* -------------------------------------------------------------------------- */
   /* --- premiere partie. On initialise les valeurs et les pointeurs a NULL --- */
   /* -------------------------------------------------------------------------- */
   /* --- image de travail a charger ---*/
   strcpy(p->load_path,"");
   sprintf(p->load_name,"#0");
   sprintf(p->load_suffix,".fit");
   sprintf(p->load_fullname,"%s%s%s",p->load_path,p->load_name,p->load_suffix);
   p->load_typehdu=IMAGE_HDU;
   p->load_hdunum=1;
   /* --- image de travail a sauver ---*/
   strcpy(p->save_path,"");
   sprintf(p->save_name,"#0");
   sprintf(p->save_suffix,".fit");
   sprintf(p->save_fullname,"%s%s%s",p->save_path,p->save_name,p->save_suffix);
   p->save_typehdu=IMAGE_HDU;
   p->save_hdunum=0;
   /* --- image de reference pour l'entete ---*/
   strcpy(p->ref_path,"");
   strcpy(p->ref_name,"");
   strcpy(p->ref_suffix,"");
   sprintf(p->ref_fullname,"%s%s%s",p->ref_path,p->ref_name,p->ref_suffix);
   p->ref_typehdu=IMAGE_HDU;
   p->ref_hdunum=1;
   /* --- mots cles dans l'image de travail ---*/
   p->keyused=TT_NO;
   p->nbkeys=0;
   p->keynames=NULL;
   p->values=NULL;
   p->comments=NULL;
   p->units=NULL;
   p->datatypes=NULL;
   /* --- mots cles dans l'image de reference pour l'entete ---*/
   p->ref_keyused=TT_NO;
   p->ref_nbkeys=0;
   p->ref_keynames=NULL;
   p->ref_values=NULL;
   p->ref_comments=NULL;
   p->ref_units=NULL;
   p->ref_datatypes=NULL;
   /* --- nouveaux mots cles a ajouter dans l'image de travail ---*/
   p->new_keynames=NULL;
   p->new_values=NULL;
   p->new_comments=NULL;
   p->new_units=NULL;
   p->new_datatypes=NULL;
   p->new_nbkeys=250;
   p->new_keyused=TT_YES;
   /* --- valeur de la derniere de l'indice du mot cle TT ---*/
   p->last_tt=0;
   /* --- definition de l'image ---*/
   p->p=NULL;
   p->naxes=NULL;
   p->datatype=TT_DATATYPE;
   p->naxis=0;
   p->naxis1=0;
   p->naxis2=0;
   p->naxis3=0;
   p->firstelem=0;
   p->nelements=0;
   p->load_bitpix=0;
   p->save_bitpix=SHORT_IMG;
   /* --- definition de la liste d'objets ---*/
   strcpy(p->objekey,"");
   strcpy(p->objelist_fullname,"");
   p->objelist=NULL;
   /* --- definition de la liste de pixels ---*/
   strcpy(p->pixekey,"");
   strcpy(p->pixelist_fullname,"");
   p->pixelist=NULL;
   /* --- definition de la liste de catalogue ---*/
   strcpy(p->catakey,"");
   strcpy(p->catalist_fullname,"");
   p->catalist=NULL;

   /* ------------------------------------------------------------ */
   /* --- deuxieme partie. On alloue la memoire des pointeurs  --- */
   /* ------------------------------------------------------------ */
   /* --- nouveaux mots cles a ajouter dans l'image de travail ---*/
   len=(int)(FLEN_KEYWORD);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_keynames,&p->new_nbkeys,&len,"p->new_keynames"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer new_keynames");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_VALUE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_values,&p->new_nbkeys,&len,"p->new_values"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer new_values");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_COMMENT);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_comments,&p->new_nbkeys,&len,"p->new_comments"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer new_comments");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   len=(int)(FLEN_COMMENT);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTRPTR_CHAR,4,&p->new_units,&p->new_nbkeys,&len,"p->new_units"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer new_units");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   nombre=p->new_nbkeys;
   taille=sizeof(int);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->new_datatypes,&nombre,&taille,"p->new_datatypes"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer new_datatypes");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }

   /* --- definition de la liste d'objets ---*/
   nombre=1;
   taille=sizeof(TT_TBL_OBJELIST);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->objelist,&nombre,&taille,"p->objelist"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer objelist");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }

   /* --- definition de la liste de pixels ---*/
   nombre=1;
   taille=sizeof(TT_TBL_PIXELIST);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->pixelist,&nombre,&taille,"p->pixelist"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer pixelist");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }
   /* --- definition de la liste de catalogue ---*/
   nombre=1;
   taille=sizeof(TT_TBL_CATALIST);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->catalist,&nombre,&taille,"p->catalist"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imabuilder for pointer catalist");
      tt_imadestroyer(p);
      return(TT_ERR_PB_MALLOC);
   }

   /* ------------------------------------------------------- */
   /* --- troisieme partie. On appelle les constructeurs  --- */
   /* ---                   des objets herites.           --- */
   /* ------------------------------------------------------- */
   /* --- definition de la liste d'objets ---*/
   if ((msg=tt_tblobjbuilder(p->objelist))!=OK_DLL) {
      tt_errlog("",msg,"Pb tt_tblobjbuilder in tt_imabuilder for pointer p->objelist");
      tt_imadestroyer(p);
      return(msg);
   }
   /* --- definition de la liste de pixels ---*/
   if ((msg=tt_tblpixbuilder(p->pixelist))!=OK_DLL) {
      tt_errlog("",msg,"Pb tt_tblpixbuilder in tt_imabuilder for pointer p->pixelist");
      tt_imadestroyer(p);
      return(msg);
   }
   /* --- definition de la liste de catalogue ---*/
   if ((msg=tt_tblcatbuilder(p->catalist))!=OK_DLL) {
      tt_errlog("",msg,"Pb tt_tblcatbuilder in tt_imabuilder for pointer p->catalist");
      tt_imadestroyer(p);
      return(msg);
   }

   return(OK_DLL);
}

int tt_imacreater(TT_IMA *p,int naxis1,int naxis2)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int taille,nombre,msg;
   if ((&p->naxes==NULL)||(&p->p==NULL)) {
      /* code-erreur sur pointeurs deja alloues ---*/
      tt_errlog("",TT_ERR_PTR_ALREADY_ALLOC,"Pointers naxes or p already allocated");
      return(TT_ERR_PTR_ALREADY_ALLOC);
   }
   p->naxis=2;
   p->naxis1=(int)(naxis1);
   p->naxis2=(int)(naxis2);
   p->naxis3=(int)(1);
   nombre=3;
   taille=sizeof(long);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->naxes,&nombre,&taille,"p->naxes"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imacreater for pointer naxes");
      return(TT_ERR_PB_MALLOC);
   }
   p->naxes[0]=(long)(naxis1);
   p->naxes[1]=(long)(naxis2);
   p->naxes[2]=(long)(1);
   nombre=naxis1*naxis2;
   taille=sizeof(TT_PTYPE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->p,&nombre,&taille,"p->p"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imacreater for pointer p");
      tt_free2((void**)&p->naxes,"p->naxes");
      return(TT_ERR_PB_MALLOC);
   }
   p->firstelem=(long)(0);
   p->nelements=(long)(naxis1*naxis2);
   return(OK_DLL);
}

int tt_imacreater3d(TT_IMA *p,int naxis1,int naxis2,int naxis3)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int taille,nombre,msg;
   if ((&p->naxes==NULL)||(&p->p==NULL)) {
      /* code-erreur sur pointeurs deja alloues ---*/
      tt_errlog("",TT_ERR_PTR_ALREADY_ALLOC,"Pointers naxes or p already allocated");
      return(TT_ERR_PTR_ALREADY_ALLOC);
   }
   p->naxis=3;
   p->naxis1=(int)(naxis1);
   p->naxis2=(int)(naxis2);
   p->naxis3=(int)(naxis3);
   nombre=3;
   taille=sizeof(long);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->naxes,&nombre,&taille,"p->naxes"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imacreater3d for pointer naxes");
      return(TT_ERR_PB_MALLOC);
   }
   p->naxes[0]=(long)(naxis1);
   p->naxes[1]=(long)(naxis2);
   p->naxes[2]=(long)(naxis3);
   nombre=naxis1*naxis2*naxis3;
   taille=sizeof(TT_PTYPE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->p,&nombre,&taille,"p->p"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imacreater3d for pointer p");
      tt_free2((void**)&p->naxes,"p->naxes");
      return(TT_ERR_PB_MALLOC);
   }
   p->firstelem=(long)(0);
   p->nelements=(long)(naxis1*naxis2*naxis3);
   return(OK_DLL);
}

int tt_imacreater1d(TT_IMA *p,int naxis1)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int taille,nombre,msg;
   if ((&p->naxes==NULL)||(&p->p==NULL)) {
      /* code-erreur sur pointeurs deja alloues ---*/
      tt_errlog("",TT_ERR_PTR_ALREADY_ALLOC,"Pointers naxes or p already allocated");
      return(TT_ERR_PTR_ALREADY_ALLOC);
   }
   p->naxis=1;
   p->naxis1=(int)(naxis1);
   p->naxis2=(int)(1);
   p->naxis3=(int)(1);
   nombre=3;
   taille=sizeof(long);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->naxes,&nombre,&taille,"p->naxes"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imacreater1d for pointer naxes");
      return(TT_ERR_PB_MALLOC);
   }
   p->naxes[0]=(long)(naxis1);
   p->naxes[1]=(long)(1);
   p->naxes[2]=(long)(1);
   nombre=naxis1;
   taille=sizeof(TT_PTYPE);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&p->p,&nombre,&taille,"p->p"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_imacreater1d for pointer p");
      tt_free2((void**)&p->naxes,"p->naxes");
      return(TT_ERR_PB_MALLOC);
   }
   p->firstelem=(long)(0);
   p->nelements=(long)(naxis1);
   return(OK_DLL);
}

int tt_imadestroyer(TT_IMA *p)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   /* --- mots cles dans l'image de travail ---*/
   /*if (p->keyused==(TT_YES)) {*/
      tt_util_free_ptrptr2((void***)&p->keynames,"p->keynames");
      tt_util_free_ptrptr2((void***)&p->values,"p->values");
      tt_util_free_ptrptr2((void***)&p->comments,"p->comments");
      tt_util_free_ptrptr2((void***)&p->units,"p->units");
      tt_free2((void**)&p->datatypes,"p->datatypes");
      p->keyused=(TT_NO);
   /*}*/
   /* --- mots cles dans l'image de reference pour l'entete ---*/
   if (p->ref_keyused==(TT_YES)) {
      tt_util_free_ptrptr2((void***)&p->ref_keynames,"p->keynames");
      tt_util_free_ptrptr2((void***)&p->ref_values,"p->values");
      tt_util_free_ptrptr2((void***)&p->ref_comments,"p->comments");
      tt_util_free_ptrptr2((void***)&p->ref_units,"p->units");
      tt_free2((void**)&p->ref_datatypes,"p->datatypes");
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
      tt_free2((void**)&p->p,"p->p");
      p->p=NULL;
   }
   p->datatype=TT_DATATYPE;
   p->naxis=0;
   p->naxis1=0;
   p->naxis2=0;
   p->naxis3=0;
   p->firstelem=0;
   p->nelements=0;
   if ((p->naxes)!=NULL) {
      tt_free2((void**)&p->naxes,"p->naxes");
      p->naxes=NULL;
   }
   p->load_bitpix=0;
   p->save_bitpix=SHORT_IMG;
   /* --- liste d'objets ---*/
   strcpy(p->objekey,"");
   strcpy(p->objelist_fullname,"");
   if (p->objelist!=NULL) {
      tt_tblobjdestroyer(p->objelist);
      tt_free2((void**)&p->objelist,"p->objelist");
      p->objelist=NULL;
   }
   /* --- liste de pixels ---*/
   strcpy(p->pixekey,"");
   strcpy(p->pixelist_fullname,"");
   if (p->pixelist!=NULL) {
      tt_tblpixdestroyer(p->pixelist);
      tt_free2((void**)&p->pixelist,"p->pixelist");
      p->pixelist=NULL;
   }
   /* --- liste de catalogue ---*/
   strcpy(p->catakey,"");
   strcpy(p->catalist_fullname,"");
   if (p->catalist!=NULL) {
      tt_tblcatdestroyer(p->catalist);
      tt_free2((void**)&p->catalist,"p->catalist");
      p->catalist=NULL;
   }
   return(OK_DLL);
}
