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

int cmd_tcl_csnomad1(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsNomad1* theStars;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csnomad1(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}
   
	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { NOMAD1 { } { ID oriAstro RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec epochRa epochDec oriMagB magB oriMagV magV oriMagR magR magJ magH magK idUCAC2 idHIP idTYC1 idTYC2 idTYC3 flagDistTYC} } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListNomad1* currentElement = theStars;

	while(currentElement) {

		sprintf(outputLogChar,"{ { NOMAD1 { } {%04d-%07d %d %.8f %+.8f %.8f %.8f %+.8f %+.8f %.8f %.8f %.1f %.1f "
				"%d %.3f %d %.3f %d %.3f %.3f %.3f %.3f "
				"%d %d %d %d %d %hd} } } ",
				currentElement->theStar.zoneNOMAD,currentElement->theStar.idNOMAD,currentElement->theStar.origineAstro,
				currentElement->theStar.ra,currentElement->theStar.dec,currentElement->theStar.errorRa,currentElement->theStar.errorDec,
				currentElement->theStar.pmRa,currentElement->theStar.pmDec,currentElement->theStar.errorPmRa,currentElement->theStar.errorPmDec,
				currentElement->theStar.epochRa,currentElement->theStar.epochDec,
				currentElement->theStar.origineMagB,currentElement->theStar.magnitudeB,
				currentElement->theStar.origineMagV,currentElement->theStar.magnitudeV,
				currentElement->theStar.origineMagR,currentElement->theStar.magnitudeR,
				currentElement->theStar.magnitudeJ,currentElement->theStar.magnitudeH,currentElement->theStar.magnitudeK,
				currentElement->theStar.idUCAC2,currentElement->theStar.idHIP,currentElement->theStar.idTYC1, currentElement->theStar.idTYC2,
				currentElement->theStar.idTYC3,currentElement->theStar.flagDistTYC);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarNomad1(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

   
	return (TCL_OK);
}
