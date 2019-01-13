/*
 * useful.h
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#ifndef USEFUL_H_
#define USEFUL_H_

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "AllExceptions.h"

/***************************************************************************/
/*                            Useful definitions                      */
/***************************************************************************/
#ifndef max
#   define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#   define min(a,b) (((a)<(b))?(a):(b))
#endif

/* pi */
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif /* M_PI */


/* 0 deg = 0 mas */
#define START_RA_MAS    0
/* 360 deg = 1296000000. mas */
#define COMPLETE_RA_MAS 1296000000
/* 0 deg */
#define START_RA_DEG    0
/* 360 deg */
#define COMPLETE_RA_DEG 360.

/* 1 deg = 360000 cas (= centi arc second)*/
#define DEG2CAS         360000
/* 0 deg = 0 cas */
#define START_RA_CAS    0
/* 360 deg = 129600000. cas */
#define COMPLETE_RA_CAS 129600000
/* dec at the south pole in mas : -90 deg = -324000000. mas */
#define DEC_SOUTH_POLE_MAS -324000000
/* dec at the north pole in mas : +90 deg = +324000000. mas */
#define DEC_NORTH_POLE_MAS  324000000
/* distance to south pole at at the south pole in Cas : 0 deg = 0. cas */
#define DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_CAS 0
/* distance to south pole at at the north pole in mas : +180 deg = 64800000. cas */
#define DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS 64800000
/* distance to south pole at at the south pole in Mas : 0 deg = 0. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS 0.
/* distance to south pole at at the north pole in mas : +180 deg = 648000000. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS 648000000

#define STRING_COMMON_LENGTH 1024

/* Search zones structures */
/* {RA,DEC} in DEGREE */
typedef struct {
	double  raStartInDeg;
	double  raEndInDeg;
	double  decStartInDeg;
	double  decEndInDeg;
	char isArroundZeroRa;
} searchZoneRaDecDeg;
/* {RA,DEC} in MAS */
typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	int  decStartInMas;
	int  decEndInMas;
	char isArroundZeroRa;
} searchZoneRaDecMas;
/* {RA,DEC} in Micro DEG */
typedef struct {
	int   raStartInMicroDegree;
	int   raEndInMicroDegree;
	int   decStartInMicroDegree;
	int   decEndInMicroDegree;
	char  isArroundZeroRa;
} searchZoneRaDecMicroDeg;
/* {RA,SPD} in MAS */
typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	int  spdStartInMas;
	int  spdEndInMas;
	char isArroundZeroRa;
} searchZoneRaSpdMas;
/* {RA,SPD} in CAS */
typedef struct {
	int  raStartInCas;
	int  raEndInCas;
	int  spdStartInCas;
	int  spdEndInCas;
	char isArroundZeroRa;
} searchZoneRaSpdCas;

/* Magnitude box structures */
/* Milli mag */
typedef struct {
	int  magnitudeStartInMilliMag;
	int  magnitudeEndInMilliMag;
} magnitudeBoxMilliMag;
/* Centi mag */
typedef struct {
	short int  magnitudeStartInCentiMag;
	short int  magnitudeEndInCentiMag;
} magnitudeBoxCentiMag;
/* Deci mag */
typedef struct {
	short int  magnitudeStartInDeciMag;
	short int  magnitudeEndInDeciMag;
} magnitudeBoxDeciMag;
/* Mag */
typedef struct {
	double  magnitudeStartInMag;
	double  magnitudeEndInMag;
} magnitudeBoxMag;

#define DEBUG 0

void releaseSimpleArray(void* theOneDArray);
void releaseDoubleArray(void** theTwoDArray, const int firstDimension);
int convertBig2LittleEndianForInteger(int l);
void convertBig2LittleEndianForArrayOfInteger(int* const inputArray, const int length);
short convertBig2LittleEndianForShort(short int l);
void convertBig2LittleEndianForArrayOfShort(short int* const inputArray, const int length);
int sumNumberOfElements(const int* const inputArray,const int indexStart,const int indexEnd);
int findComponentNumber(const int* const sortedArrayOfValues, const int lengthOfArray, const int value);
void fillSearchZoneRaDecDeg(searchZoneRaDecDeg& theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaDecMas(searchZoneRaDecMas& theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaSpdMas(searchZoneRaSpdMas& theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaDecMicroDeg(searchZoneRaDecMicroDeg& theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaSpdCas(searchZoneRaSpdCas& theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillMagnitudeBoxMilliMag(magnitudeBoxMilliMag& magnitudeBox, const double magMin, const double magMax);
void fillMagnitudeBoxCentiMag(magnitudeBoxCentiMag& magnitudeBox, const double magMin, const double magMax);
void fillMagnitudeBoxDeciMag(magnitudeBoxDeciMag& magnitudeBox, const double magMin, const double magMax);
void fillMagnitudeBoxMag(magnitudeBoxMag& magnitudeBox, const double magMin, const double magMax);
/* Francois Ochsenbein's methods */
int getBits(unsigned char * const a, const int b, const int length);
int xget4(unsigned char * const a, const int b, const int length, const int max, const int * const xtra4);
int xget2(unsigned char * const a, const int b, const int length, const int max, const short int* const xtra2);
int strloc(char * const text, const int c);

#endif /* USEFUL_H_ */
