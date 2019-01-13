///@file CStation.cpp
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
// $Id: CStation.cpp 13265 2016-02-24 18:12:57Z michelpujol $

#include <fstream>   // pour ofstream

#include <abcommon.h>
using namespace abcommon;
#include <absimple.h>
using namespace absimple;
#include "CStation.h"

CStation::CStation() : m_sense(Sense::EAST)
{
}

CStation::~CStation() {

}


CStation::CStation(const  char* data) : m_sense(Sense::EAST)
{

   m_data_TRF = data ; m_data_TRF += "_TRF";
   m_data_CRF = data;  m_data_CRF += "_CRF";
   m_sense = Sense::EAST;

}

CStation::CStation(const char * data, Sense sense) : m_sense(Sense::EAST)  
{
   m_data_TRF = data ; m_data_TRF += "_TRF";
   m_data_CRF = data;  m_data_CRF += "_CRF";
   m_sense = sense;
}



const char* CStation::get_GPS(Frame frame) {
   if( frame == Frame::TR ) {
      return m_data_TRF.c_str();
   } else {
      return m_data_CRF.c_str();
   }
}


Sense CStation::getSense() {
   return m_sense;
}

