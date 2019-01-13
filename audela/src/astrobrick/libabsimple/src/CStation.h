///@file CStation.h
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
// $Id: CStation.h 13265 2016-02-24 18:12:57Z michelpujol $

#pragma once

#include <absimple.h>

class CStation : public absimple::IStation
{
public:
   CStation();
   CStation(const char * data);
   CStation(const char * data, Sense sense);
   ~CStation();

   const char* get_GPS( absimple::Frame frame);
   Sense       getSense();
   
private:

   std::string      m_data_TRF;
   std::string      m_data_CRF;
   Sense            m_sense;

};