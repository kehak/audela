/* history.h
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

#ifndef __HISTORYH__
#define __HISTORYH__

typedef struct __LCElem {
   __LCElem *prev;
   __LCElem *next;
   char *content;
} LCElem;

class CHistoryLC {
      protected:
   LCElem *first;
   LCElem *current;
   LCElem *recall;
      public:
   CHistoryLC();
   ~CHistoryLC();
   void Add(const char*);
   char* Element(int);
   char* Backward();
   char* Forward();
   void Synchro();
   int List(char*chaine);
   int GetMaxDepth();
};


class CHistory {
      protected:
   char liste[20][256];
   int nb_elems_max;
   int a_ajouter;
   int a_rappeler;

      public:
   CHistory();
   CHistory(int);
   ~CHistory();
   void Add(const char*);
   char* Element(int toto);
   char* Backward();
   char* Forward();
   void Synchro();
   int GetMaxDepth();
};

#endif


