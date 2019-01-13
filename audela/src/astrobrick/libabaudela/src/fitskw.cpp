/* fitskw.cpp
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

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

#include "fitskw.h"
#include "libtt.h"    // for FLEN_CARD, FLEN_VALUE, ...
CFitsKeyword::CFitsKeyword()
{
   name = NULL;
   comment = NULL;
   unit = NULL;
   string_value = NULL;
   int_value = 0;
   float_value = 0.0f;
   double_value = 0.0;
   prev = NULL;
   next = NULL;
}

CFitsKeyword::~CFitsKeyword()
{
   if(name) free(name);
   if(comment) free(comment);
   if(unit) free(unit);
   if(string_value) free(string_value);
}

void CFitsKeyword::SetKeyword(
     const char *a_nom,
     const void *a_data,
     const int a_datatype,
     const char *a_comment,
     const char *a_unit
     )
{
   if(a_nom!=NULL) {
      if(name==NULL) {
         name = (char*)calloc(FLEN_KEYWORD,1);
      }
      memset(name,0,FLEN_KEYWORD);
      strncpy(name,a_nom,FLEN_KEYWORD-1);
   }
   if(a_comment!=NULL) {
      if(comment==NULL) {
         comment = (char*)calloc(FLEN_COMMENT,1);
      }
      memset(comment,0,FLEN_COMMENT);
      strncpy(comment,a_comment,FLEN_COMMENT-1);
   }
   if(a_unit!=NULL) {
      if(unit==NULL) {
         unit = (char*)calloc(FLEN_COMMENT,1);
      }
      memset(unit,0,FLEN_COMMENT);
      strncpy(unit,a_unit,FLEN_COMMENT-1);
   }
   if(string_value==NULL) {
      string_value = (char*)calloc(FLEN_VALUE,1);
   }
   memset(string_value,0,FLEN_VALUE);
   if(a_data!=NULL) {
      switch(a_datatype) {
         case TSTRING :
            datatype = a_datatype;
            strncpy(string_value,(char*)a_data,FLEN_VALUE-1);
            int_value = (int)atoi(string_value);
            float_value = (float)atof(string_value);
            double_value = (double)atof(string_value);
            break;
         case TFLOAT :
            datatype = a_datatype;
            float_value = *(float*)a_data;
            double_value = (double)float_value;
            int_value = (int)float_value;
            sprintf(string_value,"%g",float_value);
            break;
         case TDOUBLE :
            datatype = a_datatype;
            double_value = *(double*)a_data;
            float_value = (float)double_value;
            int_value = (int)double_value;
            sprintf(string_value,"%g",double_value);
            break;
         case TINT :
            datatype = a_datatype;
            int_value = *(int*)a_data;
            float_value = (float)int_value;
            double_value = (double)int_value;
            sprintf(string_value,"%d",int_value);
            break;
         default:
            datatype = TINT;
            int_value = 0;
            break;
      }
   }

}

/*
 * CFitsKeyword::getIntValue
 *    retoune la valeur du mot cle sous forme d'un entier
 *
 */
void CFitsKeyword::getIntValue(int*data,int*default_data)
{
   if(datatype!=TINT) {
      *data = *default_data;
   } else {
      *data = int_value;
   }
}


/*
 * CFitsKeyword::getPtrValue
 *    retoune la valeur du mot cle sous forme d'un pointeur
 *    sur la variable corresdant au datatype du mot cle
 *
 */
void * CFitsKeyword::getPtrValue()
{
   switch(datatype) {
      case TSTRING :
         return string_value;
         break;
      case TINT :
         return &int_value;
         break;
      case TFLOAT :
         return &float_value;
         break;
      case TDOUBLE :
         return &double_value;
         break;
      default:
         return NULL;
   }
}


void CFitsKeyword::PutToArray(
     int a_indice,    // indice dans le tableau, du mot cle a ecrire
     char ***a_keynames,
     char ***a_values,
     char ***a_comments,
     char ***a_units,
     int **a_datatypes
     )
{
    char **keynames = *a_keynames;
    char **values = *a_values;
    char **comments = *a_comments;
    char **units = *a_units;
    int *datatypes = *a_datatypes;

    datatypes[a_indice] = datatype;
    strcpy(keynames[a_indice],name);
    if(comment) {
       strcpy(comments[a_indice],comment);
    }
    if(unit) {
       strcpy(units[a_indice],unit);
    }
   switch(datatype) {
      case TSTRING :
         strcpy(values[a_indice],string_value);
         break;
      case TINT :
         sprintf(values[a_indice],"%d",int_value);
         break;
      case TFLOAT :
         if (fabs(float_value)<0.1) {
            sprintf(values[a_indice],"%e",float_value);
         } else {
            sprintf(values[a_indice],"%g",float_value);
         }
         break;
      case TDOUBLE :
         sprintf(values[a_indice],"%20.15g",double_value);
         break;
   }
}

void CFitsKeyword::GetFromArray(
     int a_indice,    // indice dans le tableau, du mot cle a ecrire
     char ***a_keynames,
     char ***a_values,
     char ***a_comments,
     char ***a_units,
     int **a_datatypes
     )
{
   char **keynames = *a_keynames;
   char **values = *a_values;
   char **comments = *a_comments;
   char **units = *a_units;
   int *datatypes = *a_datatypes;
   int i_int=(int)0;
   float i_float=(float)0.0;
   double i_double=(double)0.0;
   void *data=NULL;
   switch(datatypes[a_indice]) {
      case TINT :
         sscanf(values[a_indice],"%d",&i_int);
         data = (void*)&i_int;
         break;
      case TFLOAT :
         sscanf(values[a_indice],"%f",&i_float);
         data = (void*)&i_float;
         break;
      case TDOUBLE :
         sscanf(values[a_indice],"%lf",&i_double);
         data = (void*)&i_double;
         break;
      case TSTRING :
         data = (void*)values[a_indice];
         break;
      default :
         i_int = 0;
         data = (void*)&i_int;
         break;
   }
   SetKeyword(keynames[a_indice],data,datatypes[a_indice],comments[a_indice],units[a_indice]);
}

CFitsKeywords::CFitsKeywords()
{
   kw = NULL;
   _reference = 0;
}

CFitsKeywords::~CFitsKeywords()
{
    DeleteAll();
}

//------------------------------------------------------------------------------
// CFitsKeywords::FindKeyword renvoie le pointeur du mot-cle s'il existe deja
// la liste. Sinon elle renvoie NULL.
//
CFitsKeyword* CFitsKeywords::FindKeyword(const char*kw_name)
{
   CFitsKeyword *kwd;

   if(kw==NULL) { // S'il n'y a pas de mots-cles, c'est pas la peine de chercher
      return NULL;
   } else {
      kwd = kw;
   }

   // On recherche deja si le mot-cle existe. Si tel est le cas, alors il
   // prendra les nouvelles valeurs.
   for(;;) {
      if(kwd==NULL) { // S'il n'y a pas de mots-cles, c'est pas la peine de chercher
         break;
      } else { // Ben y'en a quand meme ... cherchons.
         if(kwd->getName()) { // S'il a un nom, tant mieux.
            if(strcmp(kwd->getName(),kw_name)==0) {
               break; // Il existe deja !
            } else {
               kwd = kwd->next; // Rate, on passe au suivant.
            }
         } else { // Ben la c'est pas normal : un mot-cle sans nom
            kwd = NULL;
            break;
         }
      }
   }
   return kwd;
}



//------------------------------------------------------------------------------
// CFitsKeywords::FindMultipleKeyword renvoie une liste de pointeurs du mot-cle s'il existe deja
// la liste. Sinon elle renvoie NULL.
//
std::list<CFitsKeyword *> CFitsKeywords::FindMultipleKeyword(const char * kwdName)
{
   CFitsKeyword *kwd;
   std::list<CFitsKeyword *> keywordList;

   if(kw==NULL) { // S'il n'y a pas de mots-cles, c'est pas la peine de chercher
      return keywordList;
   } else {
      kwd = kw;
   }

   // On recherche deja si le mot-cle existe. Si tel est le cas, alors il
   // prendra les nouvelles valeurs.
   for(;;) {
      if(kwd==NULL) { // S'il n'y a pas de mots-cles, c'est pas la peine de chercher
         break;
      } else { // Ben y'en a quand meme ... cherchons.
         if(kwd->getName()) { // S'il a un nom, tant mieux.
            if(strcmp(kwd->getName(), kwdName)==0) {
               // je l'ajoute dans la liste
               keywordList.push_back(kwd);
            }
            kwd = kwd->next; // on passe au suivant.
         } else { // Ben la c'est pas normal : un mot-cle sans nom
            kwd = NULL;
            break;
         }
      }
   }
   return keywordList;
}


//------------------------------------------------------------------------------
// Fonction d'ajout d'un mot-cle a la liste chainee des mots-cles. Attention !
// Si le mot-cle n'existe pas deja dans la liste, alors il est cree.
//
CFitsKeyword* CFitsKeywords::AddKeyword(const char*kw_name)
{
   CFitsKeyword *kwd;
   if ( strcmp(kw_name,"COMMENT") !=0 ) {
      kwd = FindKeyword(kw_name);
   } else {
      // je cree un nouveau mot cle systematiquement car COMMENT est mot cle multiple
      kwd = NULL;
   }
   if(kwd==NULL) { // Le mot-cle n'existe pas, donc il faut le creer.
      if(kw==NULL) {
         kw = new CFitsKeyword();
         kwd = kw;
      } else {
         kwd = kw;
         while(kwd->next) { // On cherche le dernier element de la liste
            kwd = kwd->next;
         }
         kwd->next = new CFitsKeyword(); // kwd est le dernier : on le cree.
         kwd->next->next = NULL;
         kwd->next->prev = kwd;
         kwd = kwd->next;
      }
   }

   return kwd;
}


//------------------------------------------------------------------------------
// Fonction d'ajout d'un mot-cle, et saisie de toutes ses caracteristiques.
// Comme il est cree avec la fonction AddKeyword, s'il existait avant, il sera
// ecrase.
//
void CFitsKeywords::Add(
     const char*a_nom,
     const void*a_data,
     const int a_datatype,
     const char*a_comment,
     const char*a_unit
     )
{
   CFitsKeyword *kwd;
   kwd = AddKeyword(a_nom);
   if(kwd) kwd->SetKeyword(a_nom,a_data,a_datatype,a_comment,a_unit);
}


void CFitsKeywords::Add(const char *nom, const char *data, const char *datatype, const char *comment, const char *unit)
{
   int iDatatype;
   int iInt;
   double dDouble;
   float fFloat;
   void *pvData;

   if(strcmp(datatype,"float")==0) {
      iDatatype = TFLOAT;
      sscanf(data,"%f",&fFloat);
      pvData = (void*)&fFloat;
   } else if(strcmp(datatype,"double")==0) {
      iDatatype = TDOUBLE;
      sscanf(data,"%lf",&dDouble);
      pvData = (void*)&dDouble;
   } else if(strcmp(datatype,"string")==0) {
      iDatatype = TSTRING;
      pvData = (void*)(data);
   } else {
      iDatatype = TINT;
      sscanf(data,"%d",&iInt);
      pvData = (void*)&iInt;
   }
   this->Add(nom,pvData,iDatatype,comment,unit);
}

//------------------------------------------------------------------------------
// Fonction d'ajout d'un mot-cle, et saisie de toutes ses caracteristiques.
// Comme il est cree avec la fonction AddKeyword, s'il existait avant, il sera
// ecrase. Le proprietes sont tirees directement de l'ensemble de tableau
// renvoyes par les fonctions Fits de Libtt.
//
void CFitsKeywords::AddFromArray(
     int a_indice,
     char ***a_keynames,
     char ***a_values,
     char ***a_comments,
     char ***a_units,
     int **a_datatypes
     )
{
   CFitsKeyword *kwd;
   kwd = AddKeyword((*a_keynames)[a_indice]);
   if(kwd) kwd->GetFromArray(a_indice,a_keynames,a_values,a_comments,a_units,a_datatypes);
}


//------------------------------------------------------------------------------
// Fonction qui permet de lire et de constituer la table des mots-cles a partir
// des tableaux renvoyes par Libtt. Tous les mots-cles du header fits sont donc
// en memoire apres une operation GetFromArray(...).
//
void CFitsKeywords::GetFromArray(
     int a_nb,
     char ***a_keynames,
     char ***a_values,
     char ***a_comments,
     char ***a_units,
     int   **a_datatypes
     )
{
   int i;
   for(i=0;i<a_nb;i++) {
      AddFromArray(i,a_keynames,a_values,a_comments,a_units,a_datatypes);
   }
}


void CFitsKeywords::SetToArray(
     char ***a_keynames,
     char ***a_values,
     char ***a_comments,
     char ***a_units,
     int   **a_datatypes)
{
   int i = 0;
   CFitsKeyword *kwd = kw;
   while(kwd!=NULL) {
      kwd->PutToArray(i++,a_keynames,a_values,a_comments,a_units,a_datatypes);
      kwd = kwd->next;
   }
}

int CFitsKeywords::GetKeywordNb()
{
   int i = 0;
   CFitsKeyword *kwd = kw;
   while(kwd!=NULL) {
      i++;
      kwd = kwd->next;
   }
   return i;
}

int CFitsKeywords::Delete(const char*kw_name)
{
	CFitsKeyword *todelete;

	if(kw_name==NULL) return EFITSKW_INTERNAL_INVALID_ARG0;
	if(kw==NULL) return EFITSKW_NO_KWDS;

	todelete = FindKeyword(kw_name);
   if(todelete) {
		if(todelete==kw) {
         kw = todelete->next;
         if(kw) kw->prev = NULL;
      } else {
			todelete->prev->next = todelete->next;
         if(todelete->next) todelete->next->prev = todelete->prev;
      }
		delete todelete;
		return 0;
   }
   return EFITSKW_NO_SUCH_KWD;
}

int CFitsKeywords::DeleteAll()
{
   CFitsKeyword *kwd;
	if(kw==NULL) return EFITSKW_NO_KWDS;
   while(kw) {
      kwd = kw->next;
      delete kw;
      kw = kwd;
   }
	kw = NULL;
   return 0;
}






