/* fitskw.h
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

#ifndef __FITSKWH__
#define __FITSKWH__

#define EFITSKW 								0x00010000

#define EFITSKW_NO_KWDS						(EFITSKW+1)
#define EFITSKW_INTERNAL_INVALID_ARG0  (EFITSKW+2)
#define EFITSKW_NO_SUCH_KWD				(EFITSKW+3)

#include <libaudela.h>

#ifdef WIN32
   #pragma warning(disable: 4786 ) // disable ::std warning
#endif
#include <list>         // ::std::list

class CFitsKeyword {
      protected:
   char *name;           // Chaines de caracteres pour remplir
   char *comment;        // la structure a passer a libtt
   char *unit;

   int datatype;         // Type de la valeur du mot cle.
   float float_value;    // Ensemble des valeurs possibles
   double double_value;  // pour le mot cle en fonction
   char *string_value;   // du type de sa valeur.
   int int_value;
      public:
   CFitsKeyword *prev;
   CFitsKeyword *next;
   CFitsKeyword();
   ~CFitsKeyword();
   void SetKeyword(const char*a_nom, const void*a_value, const int a_datatype,const char*a_comment,const char*a_unit);
   void PutToArray(int,char***,char***,char***,char***,int**);
   void GetFromArray(int,char***,char***,char***,char***,int**);
   void GetIntValue(int*data,int*default_data);

   int GetDatatype() { return datatype; };
   char *GetName() { return name; };
   char *GetComment() { return comment; };
   char *GetUnit() { return unit; };
   char *GetStringValue() { return string_value; };
   double GetDoubleValue() { return double_value; };
   float GetFloatValue() { return float_value; };
   int GetIntValue() { return int_value; };
   void * GetPtrValue();
};

class CFitsKeywords {
    private :
    int _reference;

    protected:
    CFitsKeyword *kw;

    public:
    CFitsKeywords();
    ~CFitsKeywords();
    void Reference() { ++_reference; };
    void Unreference() { --_reference; };
    int GetReference() { return _reference; };
    CFitsKeyword* FindKeyword(const char* kw_name);
    std::list<CFitsKeyword *> FindMultipleKeyword(const char * kw_name);
    CFitsKeyword* AddKeyword(const char* name);
    int Delete(const char*kw_name);
    int DeleteAll();
    void Add(const char*a_nom, const void*a_data,int a_datatype,const char*a_comment,const char*a_unit);
    void Add(const char *nom, const char *data, const char *datatype, const char *comment, const char *unit);
    void AddFromArray(int,char***,char***,char***,char***,int**);
    void GetFromArray(int,char***,char***,char***,char***,int**);
    void SetToArray(char***,char***,char***,char***,int**);
    int GetKeywordNb();
    CFitsKeyword* GetFirstKeyword() { return kw; };
};

#endif


