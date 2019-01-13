#include <libcatalog.h>
using namespace libcatalog;
#include "libcatalog_tcl.h"
#include "common.h"
/*
 * csurat1.c
 *
 *  Created on: Jan 17, 2016
 *      Author: Y. Damerdji
 */

int cmd_tcl_csurat1(ClientData , Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLogChar[STRING_COMMON_LENGTH];
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	listOfStarsUrat1* theStars = NULL;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

   ICatalog * catalog  = ICatalog_createInstance(NULL);

	try {

		theStars = catalog->csurat1(pathToCatalog, ra, dec, radius, magMin, magMax);

	} catch (IAllExceptions& theException) {

		strcpy(outputLogChar,theException.getTheMessage());
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
      catalog->release();
		return (TCL_ERROR);
	}
   
	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { URAT1 { } { ID ra_deg dec_deg sigs nst nsu epoc magnitude sigmaMagnitude"
			" nsm ref nit niu ngt ngu pmr pmd pme mf2 mfa id2"
			" jmag hmag kmag ejmag ehmag ekmag iccj icch icck phqj phqh phqk"
			" abm avm agm arm aim ebm evm egm erm eim"
			" ann ano} } } ",-1);

	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	elementListUrat1* currentElement = theStars;

	while(currentElement) {

		starUrat1& theStar           = currentElement->theStar;

		sprintf(outputLogChar,"{ { URAT1 { } {%11s %10.6f %+10.6f %8.6f %8.6f "
				"%d %d %8.6f %7.4f %7.4f "
				"%d %d %d %d "
				"%d %d %d %d %d "
				"%d %d %d "
				"%9.6f %9.6f %9.6f %9.6f %9.6f %9.6f "
				"%d %d %d %d %d %d "
				"%9.6f %9.6f %9.6f %9.6f %9.6f "
				"%9.6f %9.6f %9.6f %9.6f %9.6f "
				"%d %d} } } ",
				theStar.id, theStar.ra,theStar.dec,theStar.sigs,theStar.sigm,
				theStar.nst,theStar.nsu,theStar.epoc,theStar.magnitude,theStar.sigmaMagnitude,
				theStar.nsm,theStar.ref,theStar.nit,theStar.niu,
				theStar.ngt,theStar.ngu,theStar.pmr,theStar.pmd,theStar.pme,
				theStar.mf2,theStar.mfa,theStar.id2,
				theStar.jmag,theStar.hmag,theStar.kmag,theStar.ejmag,theStar.ehmag,theStar.ekmag,
				theStar.iccj,theStar.icch,theStar.icck,theStar.phqj,theStar.phqh,theStar.phqk,
				theStar.abm,theStar.avm,theStar.agm,theStar.arm,theStar.aim,
				theStar.ebm,theStar.evm,theStar.egm,theStar.erm,theStar.eim,
				theStar.ann,theStar.ano);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);

		/* Release memory */
		currentElement = currentElement->nextStar;
	}

	catalog->releaseListOfStarUrat1(theStars);
	catalog->release();

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	return (TCL_OK);
}
