///@file abcommon_string.h
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


#include <sstream>
#include <algorithm>
#include <iterator>	 // pour back_inserter
#include <stdarg.h>  // for va_start
#include <stdio.h>   // for sprintf
#include <string.h>
#include <abcommon.h>


// utilitaires 
std::string abcommon::utils_trim(std::string str)
{
   str.erase(0, str.find_first_not_of(' '));       //prefixing spaces
   str.erase(str.find_last_not_of(' ')+1);         //surfixing spaces
   return str;
}

std::vector<std::string> abcommon::utils_split(const std::string s, char seperator = ' ')
{
   std::vector<std::string> output;
   std::string::size_type prev_pos = 0, pos = 0;
   while((pos = s.find(seperator, pos)) != std::string::npos)
   {
      std::string substring( s.substr(prev_pos, pos-prev_pos) );
      output.push_back(substring);
      prev_pos = ++pos;
   }
   output.push_back(s.substr(prev_pos, pos-prev_pos)); // Last word
   return output;
}

void abcommon::utils_strupr(const std::string& input, std::string& ouput) 
{
   ouput.clear();
   std::transform(input.begin(), input.end(), std::back_inserter(ouput), ::toupper);
}

//  
// palliatif à la fonction std::stod qui n'est disponible qu'a partir de VisualC 2010 et de GGC-std=c++11 
int abcommon::utils_stod(const std::string& input, double *output) 
{

   double value;

   std::stringstream stream(input);
   stream >> value;
   if (stream.fail()) {      
      return 1;
   }
   *output = value;
   return 0;
}

std::string abcommon::utils_d2st(double val)
/***************************************************************************/
/* Double to String conversion with many digits                            */
/***************************************************************************/
/***************************************************************************/
{
   int kk,nn;
   char s[200];
   sprintf(s,"%13.12g",val);
	nn=(int)strlen(s);
	for (kk=0;kk<nn;kk++) {
		if (s[kk]!=' ') {
			break;
		}
	}		
   return s+kk;
}

double abcommon::utils_st2d(const std::string& input) 
{

   double value;

   std::stringstream stream(input);
   stream >> value;
   if (stream.fail()) {      
      return 1;
   }
   return value;
}

std::string abcommon::utils_dost(double val)
/***************************************************************************/
/* Double to String conversion with many digits                            */
/***************************************************************************/
/***************************************************************************/
{
   int kk,nn;
   static char s[200];
   sprintf(s,"%13.12g",val);
	nn=(int)strlen(s);
	for (kk=0;kk<nn;kk++) {
		if (s[kk]!=' ') {
			break;
		}
	}		
	std::string st ;
	st = (s+kk);
   return st;
}


std::string abcommon::utils_format(const char *fmt, ...) {
    int size = 512;
    char* buffer = 0;
    buffer = new char[size];
    va_list vl;
    va_start(vl,fmt);
    int nsize = vsnprintf(buffer,size,fmt,vl);
    if(size<=nsize){//fail delete buffer and try again
        delete buffer; buffer = 0;
        buffer = new char[nsize+1];//+1 for /0
        nsize = vsnprintf(buffer,size,fmt,vl);
    }
    std::string ret(buffer);
    va_end(vl);
    delete buffer;
    return ret;
}


bool abcommon::utils_caseInsensitiveStringCompare( const std::string& str1, const std::string& str2 ) {
    std::string str1Cpy( str1 );
    std::string str2Cpy( str2 );
    std::transform( str1Cpy.begin(), str1Cpy.end(), str1Cpy.begin(), ::tolower );
    std::transform( str2Cpy.begin(), str2Cpy.end(), str2Cpy.begin(), ::tolower );
    return ( str1Cpy == str2Cpy );
}
