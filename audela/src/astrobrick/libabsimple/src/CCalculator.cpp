// CCalendar.cpp
// sample of internal implementation of class with methods 
// returning basic types (ex:double) 
//

#include <fstream>   // pour ofstream
#include <iomanip>   // pour setw
#include <stdexcept>
#include <cstdlib>   // pour atoi

#include "CCalculator.h"
#include <abcommon.h>
using namespace abcommon;

CCalculator::CCalculator(void)
{
   this->current = 0; 
   this->memory  = 0;
}

CCalculator::~CCalculator()
{
  
}


void CCalculator::Release()
{
    delete this;
}

double CCalculator::add( double x ) 
{
   current += x;
   return current;
}

double CCalculator::sub( double x ) 
{
   current -= x;
   return current;
}

double CCalculator::divide( double x )
{
   if ( x != 0 ) {
      current /= x;
      return current;
   } else {
      throw CError(CError::ErrorDivideByZero,"CCalculator::divide x=0"); 
   }
}


double CCalculator::set( double x ) 
{
   current = x;
   return current;
}

double CCalculator::clear( void) 
{
   current = 0;
   return current;
}

double CCalculator::clearMemory( void) 
{
   memory = 0;
   return memory;
}

double CCalculator::getMemory( void) 
{
   return memory;
}

double CCalculator::setMemory( void ) 
{
   memory = current;
   return memory;
}

double CCalculator::setMemoryPlus( void ) 
{
   memory += current;
   return memory;
}

double CCalculator::setMemoryMinus( void ) 
{
   memory -= current;
   return memory;
}



