/*
 * cswfibc.h
 *
 *  Created on: 30/06/2013
 *      Author: Y. Damerdji
 */

#ifndef CSWFIBC_H_
#define CSWFIBC_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

#ifdef WIN32
#define ACCELERATOR_TABLE           "cat\\accelerator_table.txt"
#define OFFSET_TABLE                "cat\\offset_table.txt"
#else
#define ACCELERATOR_TABLE           "cat/accelerator_table.txt"
#define OFFSET_TABLE                "cat/offset_table.txt"
#endif

#define RA_STEP                     0.25
#define RA_START                    0.
#define RA_END                      359.9999
#define FORMAT_OFFSET_TABLE_COMMENT "# RA =   %lf -   %lf"
#define FORMAT_OFFSET_TABLE_DATA    "\t FILE : %20s - OFFSET = %d - NUMBER_OF_LINES = %d"
#define CATALOG_LINE_FORMAT         "%d %d %lf %d %d %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf"

typedef struct {
	double raStart;
	double raEnd;
	int offset; // The offset in OFFSET_TABLE
	int numberOfLines;
} raZone;

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag magnitudeBox;
	int indexOfFirstRightAscensionZone;
	int indexOfLastRightAscensionZone;
} searchZoneWfibc;

searchZoneWfibc findSearchZoneWfibc(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax);
raZone* readAcceleratorFileWfbic(const char* const pathToCatalog, const int numberOfZones);
void processOneZone(FILE* const offsetFileStream, const raZone& theRaZone, const searchZoneWfibc& mySearchZoneWfibc,
		const char* const pathToCatalog,elementListWfibc** headOfList);
void processOneZoneInOneFile(const char* const catalogFullName, const int offset, const int numberOfLines, const searchZoneWfibc& mySearchZoneWfibc,elementListWfibc** headOfList);

#endif /* CSWFIBC_H_ */
