/* cpool.cpp
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
#include "cpool.h"

CPool::CPool(const char*classname)
{
   dev = NULL;
   ClassName = (char*)calloc(strlen(classname)+1,sizeof(char));
   strcpy(ClassName,classname);
}

CPool::~CPool()
{
   LibererDevices();
   free(ClassName);
}

int CPool::LibererDevices()
{
   CDevice *toto;

   if(dev==NULL) return 1;
   while(dev) {
      toto = dev->next;
      delete dev;
      dev = toto;
   }
   return 0;
}

//------------------------------------------------------------------------------
// Retirer un device de la liste des devices. Celui-ci est fourni a partir de
// son pointeur. Il peut etre obtenu par la fonction de recherche.
//
int CPool::RetirerDev(CDevice *device)
{
   if(device==NULL) return 1;
   if(device->prev) device->prev->next = device->next;
   else dev = device->next;
   if(device->next) device->next->prev = device->prev;
   delete device;
   return 0;
}

//------------------------------------------------------------------------------
// Ajouter un device a la liste des devices. Celui-ci est fourni a partir de
// son pointeur.
//
int CPool::AjouterDev(CDevice *after, CDevice *device ,int device_no)
{
   if(device==NULL) return 1;
   if(after) {                        // le device est insere en milieu de liste
      device->next = after->next;
      if(device->next) device->next->prev = device;
      after->next = device;
      device->prev = after;
   } else {                             // le device est insere en tete de liste
      device->prev = NULL;
      device->next = dev;
      dev = device;
      if(dev->next) dev->next->prev = dev;
   }
   device->no = device_no;
   return 0;
}

CDevice* CPool::Ajouter(int device_no, CDevice* device)
{
   CDevice *toto;

   if(device_no>0) {
      toto = Chercher(device_no);
      if(toto) {
         device_no = toto->no;
         RetirerDev(toto);
      }
      for(toto=dev;((toto)&&(toto->next)&&(toto->next->no<=device_no));toto=toto->next);
      AjouterDev(toto,device,device_no);
   } else if(device_no==0) {
      device_no = 0;
      toto = dev;
      while(1) {
         if(toto==NULL) break;
         if(dev->no>1) {
            toto = NULL;
            break;
         }
         if(toto->next) {
            if(toto->next->no>(toto->no+1)) {
               device_no = toto->no;
               break;
            } else {
               device_no++;
            }
            toto = toto->next;
         } else {
            device_no++;
            break;
         }
      }
      AjouterDev(toto,device,device_no+1);
   }

   return device;
}

CDevice* CPool::Chercher(int device_no)
{
   CDevice *toto;
   for(toto=dev;((toto!=NULL)&&(toto->no!=device_no));toto=toto->next);
   return toto;
}

char* CPool::GetClassname()
{
   return ClassName;
}



