///@file CPool.cpp
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author : Michel PUJOL
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// $Id:$

#include <stdio.h>  // pour NULL

#include <abcommon.h>

int abcommon::IPoolInstance::getNo() {
   return m_itemNo;
}

void abcommon::IPoolInstance::setNo(int itemNo) {
   this->m_itemNo = itemNo;
}

int abcommon::CPool::add(abcommon::IPoolInstance* item)
{
   int itemNo = -1;
   for(int i=0; i < (int) items.size(); i++){
      if ( items[i] == NULL ) {
         items[i] = item;
         itemNo = i+1;
         break;
      }
   }
   if( itemNo == -1) {
      items.push_back(item);
      itemNo = items.size();
   }
   item->setNo(itemNo);
   return itemNo;
}


void abcommon::CPool::remove(abcommon::IPoolInstance* item)
{
   int i;
   for(i=0; i < (int)items.size(); i++){
      if ( items[i] == item ) {
         items[i] = NULL;
         break;
      }
   }
   if( i == (int)items.size() -1 ) {
      items.pop_back();
   }
}

abcommon::IPoolInstance * abcommon::CPool::getInstance(int itemNo) {
   return items[itemNo -1];
};
   
int abcommon::CPool::getInstanceNo(abcommon::IPoolInstance * item) {
   int itemNo = 0;
   for(int i=0; i < (int) items.size(); i++){
      if ( items[i] == item ) {
         itemNo = i+1;
         break;
      }
   }
   return itemNo;
}

abcommon::CIntArray* abcommon::CPool::getIntanceNoList() {
   abcommon::CIntArray* list = new abcommon::CIntArray();
   for(int i=0; i < (int) items.size(); i++){
      if ( items[i] !=NULL ) {
         list->append(i+1);
      }
   }
   return list;
}