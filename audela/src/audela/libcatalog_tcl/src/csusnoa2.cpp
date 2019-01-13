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

int cmd_tcl_csusnoa2(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsUsnoa2* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csusnoa2(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}
   
	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { USNOA2 { } { ID ra_deg dec_deg sign qflag field magB magR } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListUsnoa2* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,"{ { USNOA2 { } {%04d-%08d %f %f %d %d %d %.2f %.2f} } } ",
				currentElement->theStar.zoneId, currentElement->theStar.position,
				currentElement->theStar.ra,currentElement->theStar.dec,
				currentElement->theStar.sign,currentElement->theStar.qflag,currentElement->theStar.field,
				currentElement->theStar.magnitudeB,currentElement->theStar.magnitudeR);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarUsnoa2(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
