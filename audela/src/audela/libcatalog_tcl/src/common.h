/*
 * useful.h
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#ifndef COMMON_H_
#define COMMON_H_

#include <libcatalog.h>

#define STRING_COMMON_LENGTH 1024

int decodeInputs(char* const outputLogChar, const int argc, char* const argv[],
		char* const pathToCatalog,double* const ra, double* const dec,
		double* const radius, double* const magBright, double* const magFaint);
void addLastSlashToPath(char* onePath);

#endif /* COMMON_H_ */
