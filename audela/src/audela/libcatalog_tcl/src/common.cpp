/**
 * @file common.c
 * @brief Some useful and common methods for the whole library
 * @author Y. Damerdji
 * @version   1.0
 * @date      Dec 19, 2011
 * @copyright GNU Public License.
 * @par Ressource
 * @endcode
 */

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h> // pour atof
#include "common.h"

/* ============================================================================= */
/* Decode inputs : this method is common for all cmd_tcl_cs{catalog} methods
 * It defines the usage of the cone search methods                               */
/* ============================================================================= */
int decodeInputs(char* const outputLogChar, const int argc, char* const argv[],
		char* const pathToCatalog, double* const ra, double* const dec, double* const radius,
		double* const magBright, double* const magFaint) {

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLogChar,"Help usage: %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeFaint(mag)? ?magnitudeBright(mag)?",
				argv[0]);
		return (1);
	}

	if((argc != 5) && (argc != 6) && (argc != 7)) {
		sprintf(outputLogChar,"usage: %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeFaint(mag)? ?magnitudeBright(mag)?",
				argv[0]);
		return (1);
	}

	/* Read inputs */
	sprintf(pathToCatalog,"%s",argv[1]);
	*ra             = atof(argv[2]);
	*dec            = atof(argv[3]);
	*radius         = atof(argv[4]);
	if(*radius      < 0.) {
		sprintf(outputLogChar,"Function %s : radius(arcmin) = %f must be > 0.",argv[0],*radius);
		return (1);
	}

	if(argc == 6) {
		*magFaint   = atof(argv[5]);
		*magBright  = -99.999;
	} else if(argc == 7) {
		*magFaint   = atof(argv[5]);
		*magBright  = atof(argv[6]);
	} else {
		*magBright  = -99.999;
		*magFaint   = 99.999;
	}

	if(*magBright   > *magFaint) {
		sprintf(outputLogChar,"Function %s : magBright = %f must be < magFaint = %f",argv[0],*magBright,*magFaint);
		return (1);
	}

	/* Add slash to the end of the path if not exist*/
	addLastSlashToPath(pathToCatalog);

	return (0);
}

/*=========================================================*/
/* Add a slash to the end of a path if not exist           */
/*=========================================================*/
void addLastSlashToPath(char* onePath) {

	char slash[3];

#if defined(LIBRARY_DLL)
	sprintf(slash,"\\");
#else
	sprintf(slash,"/");
#endif

	if (strlen(onePath) > 0) {
		if (onePath[strlen(onePath)-1] != slash[0] ) {
			strcat(onePath,slash);
		}
	}
}
