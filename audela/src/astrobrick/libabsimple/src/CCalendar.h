///@file CCalendar.h
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author Michel Pujol
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
// @version $Id:  $

#pragma once

#include <string>
#include <vector>

#include <abcommon.h>
#include "absimple.h"
using namespace absimple;
#include <abcommon.h>      // pour CError
using namespace abcommon;

struct CDateTime : public IDateTime {
   //int year;
   //int month;
   //int day;
   //int hour;
   //int minute;
   //int second;

   //CDateTime();
   //CDateTime(const IDateTime * dateTime);
};

class CCalendar : public ICalendar
{
public:
   CCalendar();
   virtual ~CCalendar(void){};
   void Release();
   const char*      convertIntToString(int year, int month, int day, int hour, int minute, int second);
   IDateTime* convertIntToStruct(int year, int month, int day, int hour, int minute, int second);
   IDateTime* convertStringToStruct(const char* stringDate);

   CDataArray<std::string>* getDayList ();

};

//CArrayString* getMonthList ( );

