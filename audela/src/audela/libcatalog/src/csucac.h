/*
 * csucac2.h
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

#ifndef CSUCAC_H_
#define CSUCAC_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

/* The index file name*/
#define INDEX_FILE_NAME_UCAC2                   "u2index.txt"
#define INDEX_FILE_NAME_UCAC3                   "u3index.asc"
#define INDEX_FILE_NAME_UCAC4                   "u4i/u4index.asc"
#define ZONE_FILE_FORMAT_NAME_UCAC2AND3         "%sz%03d"
#define ZONE_FILE_FORMAT_NAME_UCAC4             "%su4b/z%03d"
#define INDEX_TABLE_DEC_DIMENSION_UCAC2         288
#define INDEX_TABLE_DEC_DIMENSION_UCAC3         360
#define INDEX_TABLE_DEC_DIMENSION_UCAC4         900
#define INDEX_TABLE_RA_DIMENSION_UCAC2AND3      240
#define INDEX_TABLE_RA_DIMENSION_UCAC4          1440
#define INDEX_FILE_HEADER_NUMBER_OF_LINES_UCAC2 10
#define FORMAT_INDEX_FILE_UCAC2                 "%d %d %d %d %d %lf %lf"
#define FORMAT_INDEX_FILE_UCAC3AND4             "%d %d %d %d %lf"
/* 0.5 deg = 1800000 mas */
#define DEC_WIDTH_ZONE_MAS_UCAC2AND3            1800000.
/* 0.2 deg = 720000 mas */
#define DEC_WIDTH_ZONE_MAS_UCAC4                720000.
/* 0.1 hour = 1.5 deg = 5400000 mas */
#define RA_WIDTH_ZONE_MAS_UCAC2AND3             5400000.
/* 0.25 deg = 900000 mas */
#define RA_WIDTH_ZONE_MAS_UCAC4                 900000.

typedef struct {
	int idOfFirstStarInArray;
	int length;
} arrayOneDOfStarUcac2;

typedef struct {
	arrayOneDOfStarUcac2* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac2;

typedef struct {
	int idOfFirstStarInArray;
	int indexDec;
	int length;
} arrayOneDOfStarUcac3;

typedef struct {
	arrayOneDOfStarUcac3* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac3;

typedef struct {
	int idOfFirstStarInArray;
	int indexDec;
	int length;
} arrayOneDOfStarUcac4;

typedef struct {
	arrayOneDOfStarUcac4* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac4;

typedef struct {
	int numberOfStarsInZone;
	int idOfFirstStarInZone;
} indexTableUcac;

typedef struct {
	searchZoneRaDecMas subSearchZone;
	magnitudeBoxCentiMag magnitudeBox;
} searchZoneUcac2;

typedef struct {
	searchZoneRaSpdMas subSearchZone;
	magnitudeBoxMilliMag magnitudeBox;
} searchZoneUcac3And4;

/* Function prototypes for UCAC2 */
searchZoneUcac2 findSearchZoneUcac2(const double ra,const double dec,const double radius,const double magMin, const double magMax);
indexTableUcac** readIndexFileUcac2(const char* const pathOfCatalog);
void retrieveIndexesUcac2(const searchZoneUcac2& mySearchZoneUcac2,int& indexZoneDecStart,int& indexZoneDecEnd,	int& indexZoneRaStart,int& indexZoneRaEnd);
bool retrieveUnfilteredStarsUcac2(const char* const pathOfCatalog, const searchZoneUcac2& mySearchZoneUcac2,
		const indexTableUcac* const * const indexTable, arrayTwoDOfStarUcac2& unFilteredStars, elementListUcac2** headOfList);
void allocateUnfiltredStarUcac2(arrayTwoDOfStarUcac2& unFilteredStars, const indexTableUcac* const * const indexTable, const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa, int& maximumNumberOfStarsPerZone);
void allocateUnfiltredStarForOneDecZoneUcac2(arrayOneDOfStarUcac2& unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd, int& maximumNumberOfStarsPerZone);
void readUnfiltredStarUcac2(const char* const pathOfCatalog, const searchZoneUcac2& mySearchZoneUcac2, const arrayTwoDOfStarUcac2& unFilteredStars,
		const indexTableUcac* const * const indexTable, const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart, const char isArroundZeroRa,
		elementListUcac2** headOfList, starUcac2* readStars);
void readUnfiltredStarForOneDecZoneUcac2(const char* const pathOfCatalog, const searchZoneUcac2& mySearchZoneUcac2, arrayOneDOfStarUcac2& unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec, int indexDec, const int indexZoneRaStart, elementListUcac2** headOfList, starUcac2* readStars);
bool isGoodStarUcac2(const starUcac2& oneStar,const searchZoneUcac2& mySearchZoneUcac2);
void releaseMemoryArrayTwoDOfStarUcac2(const arrayTwoDOfStarUcac2& theTwoDArray);
void printUnfilteredStarUcac2(const arrayTwoDOfStarUcac2& unFilteredStars);

/* Function prototypes for UCAC3 (some functions are common with UCAC4)*/
searchZoneUcac3And4 findSearchZoneUcac3And4(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax);
indexTableUcac** readIndexFileUcac3(const char* const pathOfCatalog);
void retrieveIndexesUcac3(const searchZoneUcac3And4& mySearchZoneUcac3,int& indexZoneDecStart,int& indexZoneDecEnd, int& indexZoneRaStart,int& indexZoneRaEnd);
void retrieveUnfilteredStarsUcac3(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac3, const indexTableUcac* const * const indexTable,
		arrayTwoDOfStarUcac3& unFilteredStars, elementListUcac3** headOfList);
void allocateUnfiltredStarUcac3(arrayTwoDOfStarUcac3& unFilteredStars, const indexTableUcac* const * const indexTable, const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa, int& maximumNumberOfStarsPerZone);
void allocateUnfiltredStarForOneDecZoneUcac3(arrayOneDOfStarUcac3& unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd, int& maximumNumberOfStarsPerZone);
void readUnfiltredStarUcac3(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac3, const arrayTwoDOfStarUcac3& unFilteredStars,
		const indexTableUcac* const * const indexTable, const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,
		const char isArroundZeroRa, elementListUcac3** headOfList, starUcac3* readStars);
void readUnfiltredStarForOneDecZoneUcac3(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac3, arrayOneDOfStarUcac3& unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec,int indexDec, const int indexZoneRaStart, elementListUcac3** headOfList, starUcac3* readStars);
bool isGoodStarUcac3(const starUcac3& oneStar,const searchZoneUcac3And4& mySearchZoneUcac3);
void releaseMemoryArrayTwoDOfStarUcac3(const arrayTwoDOfStarUcac3& theTwoDArray);
void printUnfilteredStarUcac3(const arrayTwoDOfStarUcac3& unFilteredStars);

/* Function prototypes for UCAC4 */
void retrieveIndexesUcac4(const searchZoneUcac3And4& mySearchZoneUcac4,int& indexZoneDecStart,int& indexZoneDecEnd,int& indexZoneRaStart,int& indexZoneRaEnd);
indexTableUcac** readIndexFileUcac4(const char* const pathOfCatalog);
void retrieveUnfilteredStarsUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac4,
		const indexTableUcac* const * const indexTable,arrayTwoDOfStarUcac4& unFilteredStars, elementListUcac4** headOfList);
void allocateUnfiltredStarUcac4(const arrayTwoDOfStarUcac4& unFilteredStars, const indexTableUcac* const * const indexTable, const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa, int& maximumNumberOfStarsPerZone);
void allocateUnfiltredStarForOneDecZoneUcac4(arrayOneDOfStarUcac4& unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd, int& maximumNumberOfStarsPerZone);
void readUnfiltredStarUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac4, const arrayTwoDOfStarUcac4& unFilteredStars,
		const indexTableUcac* const * const indexTable, const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,
		const char isArroundZeroRa, elementListUcac4** headOfList, starUcac4* readStars);
void readUnfiltredStarForOneDecZoneUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4& mySearchZoneUcac4, arrayOneDOfStarUcac4& unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec,int indexDec, const int indexZoneRaStart, elementListUcac4** headOfList, starUcac4* readStars);
bool isGoodStarUcac4(const starUcac4& oneStar,const searchZoneUcac3And4& mySearchZoneUcac4);
void releaseMemoryArrayTwoDOfStarUcac4(const arrayTwoDOfStarUcac4& theTwoDArray);
void printUnfilteredStarUcac4(const arrayTwoDOfStarUcac4& unFilteredStars);

#endif /* CSUCAC_H_ */
