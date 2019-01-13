/* cvisupool.cpp
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
#include <stdio.h>
#include <string.h>
#include "cvisupool.h"

CVisuPool::CVisuPool(const char*classname)
{
   dev = NULL;
   ClassName = (char*)calloc(strlen(classname)+1,sizeof(char));
   strcpy(ClassName,classname);
}

CVisuPool::~CVisuPool()
{
   LibererDevices();
   free(ClassName);
}

int CVisuPool::LibererDevices()
{
   CVisu *toto;

   if(dev==NULL) return 1;
   while(dev) {
      toto = dev->next;
      delete dev;
      dev = toto;
   }
   return 0;
}

//------------------------------------------------------------------------------
// Retirer un visu de la liste des visus. Celui-ci est fourni a partir de
// son pointeur. Il peut etre obtenu par la fonction de recherche.
//
int CVisuPool::RetirerDev(CVisu *visu)
{
   if(visu==NULL) return 1;
   if(visu->prev) visu->prev->next = visu->next;
   else dev = visu->next;
   if(visu->next) visu->next->prev = visu->prev;
   delete visu;
   return 0;
}

//------------------------------------------------------------------------------
// Ajouter un visu a la liste des visus. Celui-ci est fourni a partir de
// son pointeur.
//
int CVisuPool::AjouterDev(CVisu *after, CVisu *visu ,int visu_no)
{
   if(visu==NULL) return 1;
   if(after) {                        // le visu est insere en milieu de liste
      visu->next = after->next;
      if(visu->next) visu->next->prev = visu;
      after->next = visu;
      visu->prev = after;
   } else {                             // le visu est insere en tete de liste
      visu->prev = NULL;
      visu->next = dev;
      dev = visu;
      if(dev->next) dev->next->prev = dev;
   }
   visu->no = visu_no;
   return 0;
}

CVisu* CVisuPool::Ajouter(int visu_no, CVisu* visu)
{
   CVisu *toto;

   if(visu_no>0) {
      toto = Chercher(visu_no);
      if(toto) {
         visu_no = toto->no;
         RetirerDev(toto);
      }
      for(toto=dev;((toto)&&(toto->next)&&(toto->next->no<=visu_no));toto=toto->next);
      AjouterDev(toto,visu,visu_no);
   } else if(visu_no==0) {
      visu_no = 0;
      toto = dev;
      while(1) {
         if(toto==NULL) break;
         if(dev->no>1) {
            toto = NULL;
            break;
         }
         if(toto->next) {
            if(toto->next->no>(toto->no+1)) {
               visu_no = toto->no;
               break;
            } else {
               visu_no++;
            }
            toto = toto->next;
         } else {
            visu_no++;
            break;
         }
      }
      AjouterDev(toto,visu,visu_no+1);
   }

   return visu;
}

CVisu* CVisuPool::Chercher(int visu_no)
{
   CVisu *toto;
   for(toto=dev;((toto!=NULL)&&(toto->no!=visu_no));toto=toto->next);
   return toto;
}

char* CVisuPool::GetClassname()
{
   return ClassName;
}



