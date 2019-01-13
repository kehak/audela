#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"

#include "common.h"
/*
 * cstycho.c
 *
 *  Created on: Jul 24, 2012
 *      Author: A. Klotz / Y. Damerdji
 */

int cmd_tcl_cstycho2(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsTycho* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog*  catalog = ICatalog_createInstance(NULL);
	
   try {

		theStars = catalog->cstycho2(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		catalog->release();
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { TYCHO2 { } "
			"{ ID TYC1 TYC2 TYC3 pflag mRAdeg mDEdeg pmRA pmDE e_mRA e_mDE "
			"e_pmRA e_pmDE mepRA mepDE Num g_mRA g_mDE g_pmRA g_pmDE BT "
			"e_BT VT e_VT prox TYC HIP CCDM RAdeg DEdeg epRA epDE e_RA "
			"e_DE posflg corr } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListTycho* currentElement = theStars;

	while(currentElement) {

		if(currentElement->theStar.pflag == ' ') {
			currentElement->theStar.pflag = '_';
		}

		if(currentElement->theStar.solutionType == ' ') {
			currentElement->theStar.solutionType = '_';
		}

		if(currentElement->theStar.isTycho1Star == ' ') {
			currentElement->theStar.isTycho1Star = '_';
		}

		if(currentElement->theStar.componentIdentifierHIP[0] == ' ') {
			currentElement->theStar.componentIdentifierHIP[0] = '_';
			currentElement->theStar.componentIdentifierHIP[1] = '_';
			currentElement->theStar.componentIdentifierHIP[2] = '_';
		}

		sprintf(outputLogChar,"{ { TYCHO2 { } {%d %d %d %c %c %.8f %+.8f %+.1f %+.1f %d %d %.1f %.1f %.2f %.2f %d %.1f %.1f %.1f %.1f %.3f %.3f %.3f %.3f %d %c %d %3s %.8f %+.8f %.2f %.2f %.1f %.1f %c %.1f} } } ",
				currentElement->theStar.id, currentElement->theStar.idTycho1,currentElement->theStar.idTycho2,currentElement->theStar.idTycho3,currentElement->theStar.pflag,
				currentElement->theStar.ra,currentElement->theStar.dec,currentElement->theStar.pmRa,currentElement->theStar.pmDec,currentElement->theStar.errorRa,currentElement->theStar.errorDec,
				currentElement->theStar.errorPmRa,currentElement->theStar.errorPmDec,currentElement->theStar.meanEpochRA,currentElement->theStar.meanEpochDec,
				currentElement->theStar.numberOfUsedPositions,currentElement->theStar.goodnessOfFitRa,currentElement->theStar.goodnessOfFitDec,
				currentElement->theStar.goodnessOfFitPmRa,currentElement->theStar.goodnessOfFitPmDec,
				currentElement->theStar.magnitudeB,currentElement->theStar.errorMagnitudeB,currentElement->theStar.magnitudeV,currentElement->theStar.errorMagnitudeV,
				currentElement->theStar.proximityIndicator,currentElement->theStar.isTycho1Star,currentElement->theStar.hipparcosId,
				currentElement->theStar.componentIdentifierHIP,
				currentElement->theStar.observedRa,currentElement->theStar.observedDec,currentElement->theStar.epoch1990Ra,currentElement->theStar.epoch1990Dec,
				currentElement->theStar.errorObservedRa,currentElement->theStar.errorObservedDec,currentElement->theStar.solutionType,currentElement->theStar.correlationRaDec);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarTycho(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}

int cmd_tcl_cstycho2_fast(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsTycho* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog*  catalog = ICatalog_createInstance(NULL);

   try {

		theStars = catalog->cstycho2Fast(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		catalog->release();
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { TYCHO2 { } "
			"{ ID TYC1 TYC2 TYC3 pflag mRAdeg mDEdeg pmRA pmDE e_mRA e_mDE "
			"e_pmRA e_pmDE mepRA mepDE Num g_mRA g_mDE g_pmRA g_pmDE BT "
			"e_BT VT e_VT prox TYC HIP CCDM RAdeg DEdeg epRA epDE e_RA "
			"e_DE posflg corr } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListTycho* currentElement = theStars;

	while(currentElement) {

		if(currentElement->theStar.pflag == ' ') {
			currentElement->theStar.pflag = '_';
		}

		if(currentElement->theStar.solutionType == ' ') {
			currentElement->theStar.solutionType = '_';
		}

		if(currentElement->theStar.isTycho1Star == ' ') {
			currentElement->theStar.isTycho1Star = '_';
		}

		if(currentElement->theStar.componentIdentifierHIP[0] == ' ') {
			currentElement->theStar.componentIdentifierHIP[0] = '_';
			currentElement->theStar.componentIdentifierHIP[1] = '_';
			currentElement->theStar.componentIdentifierHIP[2] = '_';
		}

		sprintf(outputLogChar,"{ { TYCHO2 { } {%d %d %d %c %c %.8f %+.8f %+.1f %+.1f %d %d %.1f %.1f %.2f %.2f %d %.1f %.1f %.1f %.1f %.3f %.3f %.3f %.3f %d %c %d %3s %.8f %+.8f %.2f %.2f %.1f %.1f %c %.1f} } } ",
				currentElement->theStar.id, currentElement->theStar.idTycho1,currentElement->theStar.idTycho2,currentElement->theStar.idTycho3,currentElement->theStar.pflag,
				currentElement->theStar.ra,currentElement->theStar.dec,currentElement->theStar.pmRa,currentElement->theStar.pmDec,currentElement->theStar.errorRa,currentElement->theStar.errorDec,
				currentElement->theStar.errorPmRa,currentElement->theStar.errorPmDec,currentElement->theStar.meanEpochRA,currentElement->theStar.meanEpochDec,
				currentElement->theStar.numberOfUsedPositions,currentElement->theStar.goodnessOfFitRa,currentElement->theStar.goodnessOfFitDec,
				currentElement->theStar.goodnessOfFitPmRa,currentElement->theStar.goodnessOfFitPmDec,
				currentElement->theStar.magnitudeB,currentElement->theStar.errorMagnitudeB,currentElement->theStar.magnitudeV,currentElement->theStar.errorMagnitudeV,
				currentElement->theStar.proximityIndicator,currentElement->theStar.isTycho1Star,currentElement->theStar.hipparcosId,
				currentElement->theStar.componentIdentifierHIP,
				currentElement->theStar.observedRa,currentElement->theStar.observedDec,currentElement->theStar.epoch1990Ra,currentElement->theStar.epoch1990Dec,
				currentElement->theStar.errorObservedRa,currentElement->theStar.errorObservedDec,currentElement->theStar.solutionType,currentElement->theStar.correlationRaDec);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarTycho(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
