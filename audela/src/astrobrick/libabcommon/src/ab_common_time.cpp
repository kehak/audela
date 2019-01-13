///@file abcommon_time.h
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


#include <abcommon.h>

// declaration gettimeofday sous Windows  pour avoir l'équivalent de la fonction 
//   gettimeofday sous Linux (fournie dans <sys/time.h> )
// Remarque: gettimeofday  n'est pas dans le namespace abcommon sous Windows 
//   pour qu'elle puisse être utilisée dans les memes condition que sous Linux 
#ifdef WIN32
#include <sys/timeb.h>
#include <winsock.h>    // pour struct timeval 
void  gettimeofday ( struct timeval * start, void * ) {
   struct _timeb timebuffer;
   _ftime( &timebuffer );
   start->tv_sec = (long)timebuffer.time;
   start->tv_usec = timebuffer.millitm *1000;
}
#endif

void ::abcommon::getutc_ymdhhmmss(int *y,int *m,int *d,int *hh,int *mm,double *sec) {
	struct timeval start;
	gettimeofday (&start,NULL);
	time_t seconds = start.tv_sec;
   struct tm* date = gmtime(&seconds);
	*y=date->tm_year+1900;
	*m=date->tm_mon+1;
	*d=date->tm_mday;
	*hh=date->tm_hour;
	*mm=date->tm_min;
	*sec=date->tm_sec+start.tv_usec/1e6;
}
