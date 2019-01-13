/*
 * nomad1.h
 *
 *  Created on: 27/03/2013
 *      Author: Y. Damerdji
 *
 *  This code is inspired from Francois Ochsenbein's code
 */

#ifndef NOMAD1_H_
#define NOMAD1_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

//#define NOMAD1_HEADER_FORMAT "NOMAD-1.0(%d) %d/N%d.bin %d-%d  pm=%d mag=%d Ep=%d xtra=%d,%d UCAC2=%d(%07d/%07d) Tyc2=%d"
#define NOMAD1_HEADER_LENGTH                     160
#define NOMAD1_SPD_STEP                          360000 /* 0.1 deg = 360000 mas */
#define NOMAD1_BINARY_FILE_NAME_LENGTH           21
#if defined(LIBRARY_DLL)
#define NOMAD1_BINARY_FILE_NAME_FORMAT           "bindat\\%03d\\N%04d.bin"
#else
#define NOMAD1_BINARY_FILE_NAME_FORMAT           "bindat/%03d/N%04d.bin"
#endif
#define NOMAD1_NUMBER_OF_FILES_PER_SUBDIRECTORY  10
#define NOMAD1_LENTGH_ACCELERATOR_TABLE          160
#define NOMAD1_HALF_LENTGH_ACCELERATOR_TABLE     80
#define NOMAD1_CHUNK_SHIFT_RA                    24
#define NOMAD1_CHUNK_HEADER_NUMBER_OF_INTEGERS   7
#define NOMAD1_CHUNK_HEADER_NUMBER_OF_SHORTS     2
#define NOMAD1_RECORD_LENGTH                     25
#define NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION 3

#define NOMAD_OMAGBIT                            0x00200  /* Blue magnitude from O (not J) plate    */
#define NOMAD_EMAGBIT                            0x00400  /* Red magnitude from E (not F) plate     */
#define EXTRA_13_2                               7000
#define EXTRA_13_4                               8024
#define EXTRA_14_2                               15000
#define EXTRA_14_4                               16024

typedef struct {
	searchZoneRaSpdMas subSearchZone;
	magnitudeBoxMilliMag  magnitudeBox;
	char** binaryFileNames;
	int numberOfBinaryFiles;
} searchZoneNOMAD1;

typedef struct {
	int prefaceLength;
	int id;
	int id0;
	int id1;
	int ra0;
	int ra1;
	int spd0;
	int spd1;
	short int numberOfExtra2;
	short int numberOfExtra4;
	short int* extraValues2;
	int* extraValues4;
} chunkHeader;

typedef struct {
	int chunkTable[NOMAD1_LENTGH_ACCELERATOR_TABLE];
	int numberOfChunks;
	int pm;
	int mag;
	int ep;
	int zoneNumber;
	chunkHeader theChunkHeader;
} headerInformationNOMAD1;


searchZoneNOMAD1 findSearchZoneNOMAD1(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax);
void processOneFileNOMAD1(const searchZoneNOMAD1& mySearchZoneNOMAD1, const char* const binaryFileName, elementListNomad1** headOfList);
void readHeaderNOMAD1(FILE* const inputStream, headerInformationNOMAD1& headerInformation, const char* const binaryFileName);
void processChunksNOMAD1(const searchZoneNOMAD1& mySearchZoneNOMAD1, FILE* const inputStream,
		headerInformationNOMAD1& headerInformation,const int chunkNumber, const char* const binaryFileName, elementListNomad1** headOfList);
void processBufferedDataNOMAD1(const searchZoneNOMAD1& mySearchZoneNOMAD1, unsigned char* buffer,
		const headerInformationNOMAD1& headerInformation, int& lengthOfRecord, elementListNomad1** headOfList);
void allocateMemoryForSearchZoneNOMAD1(searchZoneNOMAD1& mySearchZoneNomad1);
int getExtraValues(const int value, const int max, const int max2, const int* const extraValue4, const short int* const extraValue2);
#endif /* NOMAD1_H_ */
