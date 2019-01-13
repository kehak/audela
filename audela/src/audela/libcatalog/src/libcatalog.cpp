// libcatalog.cpp
// implements the factory and "C" exported functions of libcatalog

#include "libcatalog.h"
using namespace libcatalog;
#include "CCatalog.h"
#include "AllExceptions.h"


///////////////////////////////////////////////////////////////////////////////
// ICatalog factory 
///////////////////////////////////////////////////////////////////////////////
ICatalog*  libcatalog::ICatalog_createInstance(ErrorCallbackType applicationCallback) {
   return new CCatalog(applicationCallback);
}

void libcatalog::ICatalog_releaseInstance( ICatalog* catalog) {
   catalog->release();
}

///////////////////////////////////////////////////////////////////////////////
// ICatalog "C" functions for other languages than C++ 
///////////////////////////////////////////////////////////////////////////////

listOfStars2Mass* libcatalog::ICatalog_cs2mass(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->cs2mass(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void ICatalog_releaseListOfStar2Mass(ICatalog* catalog, listOfStars2Mass* listOfStars)
{
   try {
      return catalog->releaseListOfStar2Mass(listOfStars);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return;
   }
}

listOfStarsNomad1* libcatalog::ICatalog_csnomad1(ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->csnomad1(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarNomad1(ICatalog* catalog, listOfStarsNomad1* listOfStars)
{
   try {
      return catalog->releaseListOfStarNomad1(listOfStars);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return;
   }
}

listOfStarsPpmx* libcatalog::ICatalog_csppmx (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->csppmx(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarPpmx(ICatalog* catalog, listOfStarsPpmx* listOfStars)
{
   try {
      return catalog->releaseListOfStarPpmx(listOfStars);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return;
   }
}

listOfStarsPpmxl* libcatalog::ICatalog_csppmxl (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->csppmxl(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarPpmxl (ICatalog* catalog, listOfStarsPpmxl* listOfStars) {

	try {
	  return catalog->releaseListOfStarPpmxl(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsTycho* libcatalog::ICatalog_cstycho2 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->cstycho2(pathToCatalog, ra, dec, radius, magMin, magMax);
      //return catalog->cstycho2(pathToCatalog, ra, 0, 5, -99, 99);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

listOfStarsTycho* libcatalog::ICatalog_cstycho2Fast (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try {
      return catalog->cstycho2Fast(pathToCatalog, ra, dec, radius, magMin, magMax);
      //return catalog->cstycho2(pathToCatalog, ra, 0, 5, -99, 99);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarTycho (ICatalog* catalog, listOfStarsTycho* listOfStars) {

	try {
	  return catalog->releaseListOfStarTycho(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsUcac2* libcatalog::ICatalog_csucac2 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->csucac2(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarUcac2 (ICatalog* catalog, listOfStarsUcac2* listOfStars) {

	try {
	  return catalog->releaseListOfStarUcac2(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsUcac3* libcatalog::ICatalog_csucac3 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->csucac3(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarUcac3 (ICatalog* catalog, listOfStarsUcac3* listOfStars) {

	try {
	  return catalog->releaseListOfStarUcac3(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsUcac4* libcatalog::ICatalog_csucac4 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->csucac4(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarUcac4 (ICatalog* catalog, listOfStarsUcac4* listOfStars) {

	try {
	  return catalog->releaseListOfStarUcac4(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsUsnoa2* libcatalog::ICatalog_csusnoa2 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try { 
      return catalog->csusnoa2(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarUsnoa2(ICatalog* catalog, listOfStarsUsnoa2* listOfStars) {

	try {
		return catalog->releaseListOfStarUsnoa2(listOfStars);
	} catch (AllExceptions & exception) {
		catalog->throwCallbackError(exception);
		return;
	}
}

listOfStarsWfibc* libcatalog::ICatalog_cswfibc (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax) 
{
   try { 
      return catalog->cswfibc(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarWfibc (ICatalog* catalog, listOfStarsWfibc*  listOfStars) {

	try {
		return catalog->releaseListOfStarWfibc(listOfStars);
	} catch (AllExceptions & exception) {
		catalog->throwCallbackError(exception);
		return;
	}
}

listOfStarsBmk* libcatalog::ICatalog_csbmk (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try {
      return catalog->csbmk(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarBmk (ICatalog* catalog, listOfStarsBmk* listOfStars) {

	try {
	  return catalog->releaseListOfStarBmk(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsLoneos* libcatalog::ICatalog_csloneos (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try {
      return catalog->csloneos(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarLoneos (ICatalog* catalog, listOfStarsLoneos* listOfStars) {

	try {
	  return catalog->releaseListOfStarLoneos(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsTGAS* libcatalog::ICatalog_cstgas (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try {
      return catalog->cstgas(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarTGAS (ICatalog* catalog, listOfStarsTGAS* listOfStars) {

	try {
	  return catalog->releaseListOfStarTGAS(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}

listOfStarsGaia1* libcatalog::ICatalog_csgaia1 (ICatalog* catalog, const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax)
{
   try {
      return catalog->csgaia1(pathToCatalog, ra, dec, radius, magMin, magMax);
   } catch (AllExceptions & exception) {
      catalog->throwCallbackError(exception);
      return NULL;
   }
}

void libcatalog::ICatalog_releaseListOfStarGaia1(ICatalog* catalog, listOfStarsGaia1* listOfStars) {

	try {
	  return catalog->releaseListOfStarGaia1(listOfStars);
   } catch (AllExceptions & exception) {
	  catalog->throwCallbackError(exception);
	  return;
   }
}


