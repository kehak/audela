// CCatalog.h
// internal fonction declarations

#pragma once
#include "libcatalog.h"
using namespace libcatalog;

class CCatalog : public ICatalog
{
public:
   CCatalog();
   CCatalog( ErrorCallbackType applicationCallback); 
   virtual ~CCatalog() {};
   void release();
   void releaseStar(void *);

   listOfStars2Mass*  cs2mass (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsNomad1* csnomad1(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsPpmx*   csppmx  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsPpmxl*  csppmxl (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsTycho*  cstycho2(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsUcac2*  csucac2 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsUcac3*  csucac3 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsUcac4*  csucac4 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsUsnoa2* csusnoa2(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsWfibc*  cswfibc (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsTycho*  cstycho2Fast(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsBmk*    csbmk   (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsUrat1*  csurat1 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsLoneos* csloneos(const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsTGAS*   cstgas  (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsGaia1*  csgaia1 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);
   listOfStarsGaia2*  csgaia2 (const char* const pathToCatalog, const double ra,const double dec,const double radius,const double magMin,const double magMax);

   void releaseListOfStar2Mass(listOfStars2Mass* listOfStars);
   void releaseListOfStarNomad1(listOfStarsNomad1* listOfStars);
   void releaseListOfStarPpmx(listOfStarsPpmx* listOfStars);
   void releaseListOfStarPpmxl(listOfStarsPpmxl* listOfStars);
   void releaseListOfStarTycho(listOfStarsTycho* listOfStars);
   void releaseListOfStarUcac2(listOfStarsUcac2* listOfStars);
   void releaseListOfStarUcac3(listOfStarsUcac3* listOfStars);
   void releaseListOfStarUcac4(listOfStarsUcac4* listOfStars);
   void releaseListOfStarUsnoa2(listOfStarsUsnoa2* listOfStars);
   void releaseListOfStarWfibc(listOfStarsWfibc* listOfStars);
   void releaseListOfStarBmk(listOfStarsBmk* listOfStars);
   void releaseListOfStarUrat1(listOfStarsUrat1* listOfStars);
   void releaseListOfStarLoneos(listOfStarsLoneos* listOfStars);
   void releaseListOfStarTGAS(listOfStarsTGAS* listOfStars);
   void releaseListOfStarGaia1(listOfStarsGaia1* listOfStars);
   void releaseListOfStarGaia2(listOfStarsGaia2* listOfStars);

   void throwCallbackError(IAllExceptions &exception);

private:
   ErrorCallbackType errorCallback;
};

