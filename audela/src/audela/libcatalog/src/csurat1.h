/*
 * csurat1.h
 *
 *  Created on: Jan 17, 2016
 *      Author: Y. Damerdji
 */

#ifndef CSURAT1_H_
#define CSURAT1_H_

#include "libcatalog.h"
#include "useful.h"

/* Extensions and format */
#define URAT1_INDEX_FILENAME                   "v12/v1index.asc"
#define URAT1_CATALOG_NAME_FORMAT              "v12/z%d"
#define URAT1_ID_FORMAT                        "%3d-%06d"
#define URAT1_DISTANCE_TO_POLE_WIDTH_IN_DEGREE 0.2
#define URAT1_FIRST_ZONE_INDEX                 326
#define URAT1_LAST_ZONE_INDEX                  900
#define URAT1_NUMBER_OF_DEC_ZONES              575
#define URAT1_INDEX_RA_ZONE_WIDTH_IN_DEGREE    0.25
#define URAT1_NUMBER_OF_RA_ZONES               1440
/* Format of the ACC file */
#ifdef _WIN32 /* For win32 and win64 */
#define URAT1_FORMAT_ACC "%ld %ld %ld %ld %ld %ld"
#else
#define URAT1_FORMAT_ACC "%d %d %d %d %d %d"
#endif

typedef struct {
	searchZoneRaSpdMas subSearchZone;
	magnitudeBoxMilliMag magnitudeBox;
	int    indexOfFirstDistanceToPoleZone;
	int    indexOfLastDistanceToPoleZone;
	int    indexOfFirstRightAscensionZone;
	int    indexOfLastRightAscensionZone;
} searchZoneUrat1;

typedef struct {
	  int   ra;     // I*4  mas      mean RA on ICRF at URAT mean obs.epoch   ( 1)
	  int   spd;    // I*4  mas      mean South Pole Distance = Dec + 90 deg  ( 1)
	  short sigs;   // I*2  mas      position error per coord. from scatter   ( 2)
	  short sigm;   // I*2  mas      position error per coord. from model     ( 2)
	  char  nst;    // I*1  --       tot. number of sets the star is in       ( 3)
	  char  nsu;    // I*1  --       n. of sets used for mean position + flag ( 3)
	  short epoc;   // I*2  myr      mean URAT obs. epoch - 2000.0            ( 1)
	  short mmag;   // I*2  mmag     mean URAT model fit magnitude            ( 4)
	  short sigp;   // I*2  mmag     URAT photometry error                    ( 5)
	  char  nsm;    // I*1  --       number of sets used for URAT magnitude   ( 3)
	  char  ref;    // I*1  --       largest reference star flag              ( 6)
	  short nit;    // I*2  --       total number of images (observations)
	  short niu;    // I*2  --       number of images used for mean position
	  char  ngt;    // I*1  --       total number of 1st order grating obs.
	  char  ngu;    // I*1  --       number of 1st order grating positions used
	  short pmr;    // I*2 0.1mas/yr proper motion RA*cosDec (from 2MASS)     ( 7)
	  short pmd;    // I*2 0.1mas/yr proper motion Dec                        ( 7)
	  short pme;    // I*2 0.1mas/yr proper motion error per coordinate       ( 8)
	  char  mf2;    // I*1  --       match flag URAT with 2MASS               ( 9)
	  char  mfa;    // I*1  --       match flag URAT with APASS               ( 9)
	  int   id2;    // I*4  --       unique 2MASS star identification number
	  short jmag;   // I*2  mmag     2MASS J mag
	  short hmag;   // I*2  mmag     2MASS H mag
	  short kmag;   // I*2  mmag     2MASS K mag
	  short ejmag;  // I*2  mmag     error 2MASS J mag
	  short ehmag;  // I*2  mmag     error 2MASS H mag
	  short ekmag;  // I*2  mmag     error 2MASS K mag
	  char  iccj;   // I*1  --       CC flag 2MASS J                          (10)
	  char  icch;   // I*1  --       CC flag 2MASS H
	  char  icck;   // I*1  --       CC flag 2MASS K
	  char  phqj;   // I*1  --       photometry quality flag 2MASS J          (10)
	  char  phqh;   // I*1  --       photometry quality flag 2MASS H
	  char  phqk;   // I*1  --       photometry quality flag 2MASS K
	  short abm;    // I*2  mmag     APASS B mag                              (11)
	  short avm;    // I*2  mmag     APASS V mag
	  short agm;    // I*2  mmag     APASS g mag
	  short arm;    // I*2  mmag     APASS r mag
	  short aim;    // I*2  mmag     APASS i mag
	  short ebm;    // I*2  mmag     error APASS B mag
	  short evm;    // I*2  mmag     error APASS V mag
	  short egm;    // I*2  mmag     error APASS g mag
	  short erm;    // I*2  mmag     error APASS r mag
	  short eim;    // I*2  mmag     error APASS i mag
	  char  ann;    // I*1  --       APASS numb. of nights                    (12)
	  char  ano;    // I*1  --       APASS numb. of observ.                   (12)
} starUrat1Raw;

searchZoneUrat1 findSearchZoneUrat1(const double ra,const double dec,const double radius,const double magMin, const double magMax);
int** readIndexFileUrat1(const char* const pathOfCatalog, int& maximumNumberOfStarsPerZone);
void processOneZoneUrat1(FILE* const inputStream,const int* const numberOfStarsPerZone,
		elementListUrat1** headOfList, starUrat1Raw* readStars,const searchZoneUrat1& mySearchZoneUrat1,
		const int indexOfDecZone, const int indexOfRA);
bool isGoodStarUrat1(const starUrat1Raw& theStar, const searchZoneUrat1& mySearchZoneUrat1);
#endif /* CSURAT1_H_ */

