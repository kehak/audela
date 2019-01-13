// wizardthar.h : prototype des fonctions du wizard
//
#ifndef _INC_LIBESHEL_WIZARDTHAR
#define _INC_LIBESHEL_WIZARDTHAR

#include <list>
#include <string>
#include <valarray>
#include "order.h"
#include "linegap.h"

void Eshel_findReferenceLine(
   char *ledfileName, 
   char *tharfileName, 
   char *outputFileName,
   int ordre_ref_num, 
   double ordre_ref_lambda, 
   INFOSPECTRO &spectro,
   ::std::list<double> &lineList,
   int threshin,
   int fwhm,
   std::string &returnMessage);

#endif