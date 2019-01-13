/*
 * ppmx.h
 *
 *  Created on: 18/03/2013
 *      Author: Y. Damerdji
 *
 *  This code is inspired from Francois Ochsenbein's code
 */

#ifndef CSPPMX_H_
#define CSPPMX_H_

#include "libcatalog.h"
using namespace libcatalog;
#include "useful.h"

/* PPMX */
#define PPMX_HEADER_LENGTH      80
#define PPMX_RECORD_LENGTH      46
#define PPMX_DECLINATION_STEP              27000000
#define PPMX_BINARY_FILE_NAME_LENGTH       16
#if defined(LIBRARY_DLL)
#define PPMX_BINARY_FILE_NAME_FORMAT_SOUTH "data\\s%s.bin"
#define PPMX_BINARY_FILE_NAME_FORMAT_NORTH "data\\n%s.bin"
#else
#define PPMX_BINARY_FILE_NAME_FORMAT_SOUTH "data/s%s.bin"
#define PPMX_BINARY_FILE_NAME_FORMAT_NORTH "data/n%s.bin"
#endif

#define PPMX_CHUNK_SHIFT_RA     23

/* PPMXL */
#define PPMXL_HEADER_FORMAT                 "N=%d n4=%d Noff=%d*2 oDE=%dmas"
#define PPMXL_HEADER_UNUSEFUL_LENGTH        21
#define PPMXL_SHORT_RECORD_LENGTH           29
#define PPMXL_DECLINATION_FIRST_STEP        3600000
#define PPMXL_DECLINATION_SECOND_STEP       900000
#define PPMXL_BINARY_FILE_NAME_LENGTH       13
#if defined(LIBRARY_DLL)
#define PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH "dat\\s%02d%c.bin"
#define PPMXL_BINARY_FILE_NAME_FORMAT_NORTH "dat\\n%02d%c.bin"
#else
#define PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH "dat/s%02d%c.bin"
#define PPMXL_BINARY_FILE_NAME_FORMAT_NORTH "dat/n%02d%c.bin"
#endif
#define binRA(s)                            ((s[12]&0x7f)<<24)|(s[13]<<16)|(s[14]<<8)|s[15]
#define NUMBER_OF_2MASS_MAGNITUDES          3
#define NUMBER_OF_USNO_MAGNITUDES           5

#define BAD_MAGNITUDE                    	-32768	/* NULL value for int2 values   */

typedef struct {
	searchZoneRaDecMas subSearchZone;
	magnitudeBoxMilliMag  magnitudeBox;
	char** binaryFileNames;
	int numberOfBinaryFiles;
} searchZonePPMX;

typedef struct {
	int numberOfExtra2;
	int numberOfExtra4;
	int lengthOfAcceleratorTable;
	short int* extraValues2;
	int* extraValues4;
	int* chunkOffsets;
	int* chunkNumberOfStars;
	int decStartInMas;
} headerInformationPPMX;

typedef struct {
	int numberOfExtra4;
	int lengthOfAcceleratorTable;
	int* extraValues4;
	int* chunkOffsets;
	int* chunkOffRa;
	int* chunkSizes;
	int decStartInMas;
} headerInformationPPMXL;

searchZonePPMX findSearchZonePPMX(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax);
searchZonePPMX findSearchZonePPMXL(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax);
void allocateMemoryForSearchZonePPMX(searchZonePPMX& mySearchZonePPMX);
void processOneFilePPMX(const searchZonePPMX& mySearchZonePPMX,const char* const binaryFileName, elementListPpmx** headOfList);
void processOneFilePPMXL(const searchZonePPMX& mySearchZonePPMX,const char* const binaryFileName, elementListPpmxl** headOfList);
void readHeaderPPMX(FILE* const inputStream, headerInformationPPMX& headerInformation,const char* const binaryFileName);
void readHeaderPPMXL(FILE* const inputStream, headerInformationPPMXL& headerInformation,const char* const binaryFileName);
void processChunksPPMX(const searchZonePPMX& mySearchZonePPMX,FILE* const inputStream,const headerInformationPPMX& headerInformation,const int chunkStart,const int chunkEnd,
		const char* const binaryFileName, elementListPpmx** headOfList);
void processChunksPPMXL(const searchZonePPMX& mySearchZonePPMX,FILE* const inputStream,const headerInformationPPMXL& headerInformation,const int chunkStart,const int chunkEnd,
		const char* const binaryFileName, elementListPpmxl** headOfList);
void processBufferedDataPPMX(const searchZonePPMX& mySearchZonePPMX, unsigned char* buffer,const headerInformationPPMX& headerInformation, const int raStart,
		elementListPpmx** headOfList);
void processBufferedDataPPMXL(const searchZonePPMX& mySearchZonePPMX, unsigned char* buffer,const headerInformationPPMXL& headerInformation,
		int& lengthOfRecor, elementListPpmxl** headOfList);
void sJname(char * const str, const int ra, const int de, const int modJ);

#endif /* CSPPMX_H_ */
