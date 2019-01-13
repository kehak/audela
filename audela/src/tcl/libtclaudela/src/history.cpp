/* history.cpp
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
#if defined(OS_LIN)
#  include <stdio.h>
#endif
#include "history.h"

#include <stdio.h>
#if defined (OS_WIN)
#include <windows.h>
#endif

// #define _DISPLAY_ORDER_ // pour afficher le numero dans la liste des commandes


CHistory::CHistory()
{
    int i;
    nb_elems_max = 20;
    a_ajouter = 0;
    a_rappeler = 0;
    for(i=0;i<nb_elems_max;i++) memset(liste[i],0,256);
}

CHistory::CHistory(int nb_elems)
{
    nb_elems_max = nb_elems;
    a_ajouter = 0;
    a_rappeler = 0;
}

CHistory::~CHistory()
{
    if(liste) free(liste);
}

void CHistory::Add(const char *toto)
{
    strcpy(liste[a_ajouter],toto);
    a_ajouter+=1;
    if(a_ajouter==nb_elems_max) a_ajouter = 0;
    a_rappeler = a_ajouter;
}

char* CHistory::Element(int toto)
{
    if((toto<0)&&(toto>=nb_elems_max)) return NULL;
    return liste[toto];
}

char* CHistory::Backward()
{
    a_rappeler -= 1;
//    if(a_rappeler==-1) a_rappeler = nb_elems_max-1;
    if(a_rappeler==-1) a_rappeler = 0;
#ifdef _DISPLAY_ORDER_
    char s[256];
    sprintf(s,"%s #%d",liste[a_rappeler],a_rappeler);
    return s;
#else
    return liste[a_rappeler];
#endif
}

char* CHistory::Forward()
{
    a_rappeler += 1;
//    if(a_rappeler==nb_elems_max) a_rappeler = 0;
    if(a_rappeler==nb_elems_max) a_rappeler = nb_elems_max-1;
#ifdef _DISPLAY_ORDER_
    char s[256];
    sprintf(s,"%s #%d",liste[a_rappeler],a_rappeler);
    return s;
#else
    return liste[a_rappeler];
#endif
}

void CHistory::Synchro()
{
    a_rappeler = a_ajouter;
}

int CHistory::GetMaxDepth()
{
    return nb_elems_max;
}





CHistoryLC::CHistoryLC()
{
   first = current = recall = NULL;
}
CHistoryLC::~CHistoryLC()
{
   LCElem *el;
   while(first) {
      #if 0
      LCElem *e;
      char *t;
      char u[256];
      t = (char*)calloc(10000,1);
      for(e=first;e;e=e->next) {
         sprintf(u,"%p: prev=%p, next=%p, content=%s\n",e,e->prev,e->next,e->content);
         strcat(t,u);
      }
      MessageBox(NULL,t,"DEBUG",MB_OK);
      free(t);
      #endif
      el = first->next;
      free(first->content);
      free(first);
      first=el;
   }
}
void CHistoryLC::Add(const char*in)
{
   if(current==NULL) {
      first = (LCElem*)calloc(1,sizeof(LCElem));
      first->next = first->prev = NULL;
      first->content = (char*)calloc(strlen(in)+1,sizeof(char));
      strcpy(first->content,in);
      current = first;
   } else {
      current->next = (LCElem*)calloc(1,sizeof(LCElem));
      current->next->prev = current;
      current = current->next;
      current->next = NULL;
      current->content = (char*)calloc(strlen(in)+1,sizeof(char));
      strcpy(current->content,in);
   }
   recall = NULL;

   #if 0
   LCElem *e;
   char *t;
   char u[256];
   t = (char*)calloc(10000,1);
   for(e=first;e;e=e->next) {
      sprintf(u,"%p: prev=%p, next=%p, content=%s\n",e,e->prev,e->next,e->content);
      strcat(t,u);
   }
   MessageBox(NULL,t,"DEBUG",MB_OK);
   free(t);
   #endif
}
char* CHistoryLC::Element(int n)
{
   int i;
   LCElem *el;
   el = first;
   i = 0;
   while(el!=NULL) {
      if(i==n) return el->content;
      el = el->next;
   }
   return NULL;
}
char* CHistoryLC::Backward()
{
   char*toto=NULL;
   if(recall!=NULL) {
      if(recall->prev!=NULL) recall=recall->prev;
      toto=recall->content;
   } else {
      recall = current;
      if(recall!=NULL) toto=recall->content;
   }
   return toto;
}
char* CHistoryLC::Forward()
{
   char*toto=NULL;
   if(recall!=NULL) {
      recall = recall->next;
      if(recall!=NULL) {
         toto=recall->content;
      }
//      if(recall->next!=NULL) {
//         recall=recall->next;
//         toto=recall->content;
//      }
   }
   return toto;
}
void CHistoryLC::Synchro()
{
   recall = NULL;
}
int CHistoryLC::GetMaxDepth()
{
   return -1;
}
int CHistoryLC::List(char*chaine)
{
   LCElem *el=first;
   int total=0;
   if(chaine==NULL) { // calcule la taille de la chaine
      while(el) {
         total = total + strlen(el->content) + 4;
         el = el->next;
      }
      return total;
   } else { // remplissage de la chaine
      *chaine = 0;
      while(el) {
         strcat(chaine,"{");
         strcat(chaine,el->content);
         strcat(chaine,"} ");
         el = el->next;
      }
   }
   return 0;
}




