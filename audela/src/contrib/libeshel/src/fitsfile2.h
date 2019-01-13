#ifndef _INC_LIBESHEL_FITS_FILE2
#define _INC_LIBESHEL_FITS_FILE2
#include <CCfits/CCfits>
#include <valarray>
#include <list>
#include "infoimage.h"
#include "linegap.h"
#include "order.h"

class CFitsFile
{
public:
   CFitsFile(void);
   virtual ~CFitsFile(void);

   void create(const char *fileName);
   void create(const char *fileName, std::valarray<PIC_TYPE> &imageValue, int width, int height);
   void create(const char *fileName, std::valarray<double> &profile, double lambda1, double step);
   void open(const char *fileName, bool write);

   void getInfoSpectro ( INFOSPECTRO * infoSpectro);
   void getOrders(ORDRE *orderValue, double *dx_ref);

   void getLinearProfile(const char * hduName, ::std::valarray<double> &linearProfile, double *lambda1, double *step);
   void getLinearProfile(const char * prefix, int numOrder, valarray<double> &linearProfile, double *lambda1, double *step);
   void setLinearProfile(const char * prefix, int numOrder, valarray<double> &linearProfile, double lambda1, double step);

   void getKeyword(const char * hduName, const char* name, string &value);
   void setKeyword(const char * hduName, string &name, string &stringValue, string &comment);

private: 
  void close();

  CCfits::FITS * pFits;

};

#endif

