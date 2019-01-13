///@file CCalculator.h
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

#include <abmc.h>
#include "CHome.h"
#include "CDate.h"

class CMc : public abmc::IMc
{
public:
   CMc();
   ~CMc();
   //  angle
   int angle2deg(const char *string_angle,double *deg);
   int angle2rad(const char *string_angle,double *rad);
   int angle2sexagesimal(double deg,const char *string_format,char *string_sexa);
   int angles_computation(const char *string_angle1,const char *string_operande,const char *string_angle2,double *deg);
   int coordinates_separation(const char *coord1_angle1,const char *coord1_angle2,const char *coord2_angle1,const char *coord2_angle2,double *angle_distance,double *angle_position);

   // Coordinates
   abmc::ICoordinates* createCoordinates();
   abmc::ICoordinates* createCoordinates_from_string(const char *angles, abmc::Equinox equinox);
   abmc::ICoordinates* createCoordinates_from_coord(abmc::ICoordinates& coords);


   //  date
   int date2jd(const char *string_date,double *jd);
   int date2iso8601(const char *string_date,char *date_iso8601);
   int date2ymdhms(const char *string_date,int *year,int *month,int *day,int *hour,int *minute,double *seconds);
   int date2tt(const char *string_date,double *jd_tt);
   int date2equinox(const char *string_date,int year_type,int nb_subdigit,char *date_equ);
   int date2lst(const char *string_date_utc, double ut1_utc, const char *string_home, double xp_arcsec, double yp_arcsec, double *lst);
   //int dates_ut2bary(const char *string_date_utc,, const char *string_coord, const char *string_date_equinox, const char *string_home, double **jd_bary)

   // home 
   abmc::IHome* createHome();

   // accesseurs
   void setHome(IHome &Home);
   IHome& getHome();
   void setFixedDate(IDate &date);
   void unsetFixedDate();
   IDate& getDate();



private: 
   CHome m_home;
   CDate m_date;
   bool  m_fixedDate;

};