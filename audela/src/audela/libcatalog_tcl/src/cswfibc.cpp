#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"
/*
 * csusnoa2.c
 *
 *  Created on: Jul 24, 2012
 *      Author: A. Klotz / Y. Damerdji
 */

int cmd_tcl_cswfibc (ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsWfibc* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);
	try {

		theStars = catalog->cswfibc(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		catalog->release();
		return (TCL_ERROR);
	}

   /* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { WFIBC { } { RA_deg DEC_deg error_AlphaCosDelta error_Delta JD PM_AlphaCosDelta PM_Delta error_PM_AlphaCosDelta"
				" error_PM_Delta magR error_magR} } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListWfibc* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,"{ { WFIBC { } {%.6f %.6f %.3f %.3f %.8f %.3f %.3f %.3f %.3f %.3f %.3f} } } ",
				currentElement->theStar.ra, currentElement->theStar.dec, currentElement->theStar.errorRa, currentElement->theStar.errorDec,
				currentElement->theStar.jd, currentElement->theStar.pmRa, currentElement->theStar.pmDec, currentElement->theStar.errorPmRa, currentElement->theStar.errorPmDec,
				currentElement->theStar.magnitudeR, currentElement->theStar.errorMagnitudeR);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarWfibc(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
