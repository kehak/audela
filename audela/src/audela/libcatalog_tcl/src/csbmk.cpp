#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"

#include "common.h"
/*
 * csbmk.h
 *
 *  Created on: Jul 05, 2015
 *      Author: Y. Damerdji
 */

int cmd_tcl_csbmk(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsBmk* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog*  catalog = ICatalog_createInstance(NULL);

   try {

		theStars = catalog->csbmk(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		catalog->release();
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { BMK { } "
			"{ ID RA DEC SOURCE_OF_COORDINATES STAR_NAME BIBCODE MAGNITUDE PASSBAND SPECTRAL_TYPE } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListBmk* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,"{ { BMK { } {%d %.6f %.6f %s %s %s %.2f %s %s} } } ",
				currentElement->theStar.id, currentElement->theStar.ra,currentElement->theStar.dec,
				currentElement->theStar.sourceOfCoordinates,currentElement->theStar.starName,
				currentElement->theStar.bibCode,currentElement->theStar.magnitude,currentElement->theStar.passBand,
				currentElement->theStar.spectralType);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarBmk(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
