/* fitsfile.h
 *
 */

#ifndef _INC_LIBESHEL_FITS_FILE
#define _INC_LIBESHEL_FITS_FILE
#include <valarray>
#include <list>
#include "infoimage.h"
#include "linegap.h"

// je definie ce type pour eviter d'importer ici toutes les définitions de ::CCFits
namespace CCfits {
   typedef class FITS *PFitsFile;   
};

CCfits::PFitsFile Fits_openFits(char *fileName, bool write);
void Fits_closeFits(CCfits::PFitsFile pFits);

CCfits::PFitsFile Fits_createFits(char *sourcefileName, char *fileName);
CCfits::PFitsFile Fits_createFits(char *fileName, std::valarray<double> &profil, double lambda1, double step);
CCfits::PFitsFile Fits_createFits(char *fileName, INFOIMAGE *pinfoImage ) ;
CCfits::PFitsFile Fits_createFits(char *fileName, std::valarray<PIC_TYPE> &imageValue, int width, int height);

void Fits_setImage(CCfits::PFitsFile pFits, INFOIMAGE *pinfoImage);
void Fits_getImage(CCfits::PFitsFile pFits, INFOIMAGE **pinfoImage );

void Fits_setOrders (CCfits::PFitsFile pFits, INFOSPECTRO *infoSpectro, PROCESS_INFO *processInfo, ORDRE *order, double dx_ref);
void Fits_getOrders(CCfits::PFitsFile pFits, ORDRE *orderValue, double *dx_ref);
void Fits_getInfoSpectro (CCfits::PFitsFile pFits, INFOSPECTRO * infoSpectro);
void Fits_getProcessInfo (CCfits::PFitsFile pFits, PROCESS_INFO * processInfo);

void Fits_setLineGap (CCfits::PFitsFile pFit, ::std::list<LINE_GAP> &lineGapList);
void Fits_getLineGap(CCfits::PFitsFile pFits, ::std::list<LINE_GAP> &lineGapListe);

void Fits_setRawProfile(CCfits::PFitsFile pOutFits, const char * prefix, int numOrder, ::std::valarray<double> &rawProfile, int min_x);
void Fits_getRawProfile(CCfits::PFitsFile pFits, const char * prefix, int numOrder, ::std::valarray<double> &rawProfile, int &min_x);

void Fits_setLinearProfile(CCfits::PFitsFile pFits, const char * prefix, int numOrder, ::std::valarray<double> &linearProfile, double lambda1, double step) ;
void Fits_getLinearProfile(CCfits::PFitsFile pFits, const char * prefix, int numOrder, ::std::valarray<double> &linearProfile, double *lambda1, double *step);
void Fits_getLinearProfile(CCfits::PFitsFile pFits, const char * hduName, ::std::valarray<double> &linearProfile, double *lambda1, double *step);

void Fits_setFullProfile(CCfits::PFitsFile pFits, const char * hduName, ::std::valarray<double> &profile, double lambda1, double step);
void Fits_getFullProfile(CCfits::PFitsFile pFits, const char * hduName, ::std::valarray<double> &linearProfile, double *lambda1, double *step); 

void Fits_setStraightLineImage(CCfits::PFitsFile pFits, int numOrder, ::std::valarray<int> &rawProfile, int width, int height);

void Fits_setKeyword(CCfits::PFitsFile pFits, const char * hduName, const char* name, char *stringValue, char *comment);
void Fits_getKeyword(CCfits::PFitsFile pFits, const char * hduName, const char* name, ::std::string &value);
void Fits_setKeyword(CCfits::PFitsFile pOutFits, CCfits::PFitsFile pInFits);

void Fits_setCatalogLine(CCfits::PFitsFile pFits, ::std::list<REFERENCE_LINE> &catalogLine );
void Fits_setImageLine(CCfits::PFitsFile pFits, ::std::list<REFERENCE_LINE> &imageLine );
#endif