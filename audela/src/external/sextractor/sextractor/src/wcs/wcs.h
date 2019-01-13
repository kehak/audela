#ifndef WCS
#define WCS

#include "cel.h"
#include "lin.h"

#ifdef __cplusplus
extern "C" {
#endif

struct wcsprm {
   int flag;
   char pcode[4];
   char lngtyp[5], lattyp[5];
   int lng, lat;
   int cubeface;
};

#if __STDC__ || defined(__cplusplus)
   int wcssett(const int,
              const char[][9],
              struct wcsprm *);

   int wcsfwd(const char[][9],
              struct wcsprm *,
              const double[],
              const double[],
              struct celprm *, 
              double *,
              double *, 
              struct prjprm *, 
              double[], 
              struct linprm *,
              double[]);

   int wcsrevv(const char[][9],
              struct wcsprm *,
              const double[], 
              struct linprm *,
              double[], 
              struct prjprm *, 
              double *,
              double *, 
              const double[], 
              struct celprm *, 
              double[]);

   int wcsmix(const char[][9],
              struct wcsprm *,
              const int,
              const int,
              const double[],
              const double,
              int,
              double[],
              const double[],
              struct celprm *,
              double *,
              double *,
              struct prjprm *,
              double[], 
              struct linprm *,
              double[]);

#else
   int wcssett(), wcsfwd(), wcsrevv(), wcsmix();
#endif

extern const char *wcssett_errmsg[];
extern const char *wcsfwd_errmsg[];
extern const char *wcsrevv_errmsg[];
extern const char *wcsmix_errmsg[];

#define WCSSET 137

#ifdef __cplusplus
};
#endif

#endif /* WCS */
