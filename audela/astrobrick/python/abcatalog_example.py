# libcatalog_test.py

import abcatalog 
import ctypes 
import os
from sys import platform

# create catalog session object
catalog = abcatalog.ICatalog()

# set TYCHO-2 catalog path to the default AUDELA catalog path
if platform == "linux" or platform == "linux2" or platform== "darwin":
	catalogPath = os.path.join(os.path.expanduser('~'), ".audela", "catalog", "TYCHO-2")
elif platform == "win32":
	catalogPath = os.path.join(os.path.expanduser('~'), "AppData", "Roaming","AudeLA", "catalog", "TYCHO-2")
print( "catalogPath=", catalogPath)



try :
	ra = 1
	dec = 0
	radius = 11
	magMin = -99
	magMax = 99
	print( "cstycho2( %s, %d, %d, %d, %d, %d )" % 
	       (catalogPath, ra, dec, radius, magMin, magMax))
	stars = catalog.cstycho2(catalogPath, 1, 0, 11, -99, 99)
	print( "len(stars)=" , len(stars) )

	for i in range(0, len(stars) ) :
		star = stars[i] 
		print ( "star " ,  i , " \n"
			, "ra                       " , star.ra , "\n"
			, "dec                      " , star.dec , "\n"
			, "pmRa                     " , star.pmRa , "\n"
			, "pmDec                    " , star.pmDec , "\n"
			, "errorPmRa                " , star.errorPmRa , "\n"
			, "errorPmDec               " , star.errorPmDec , "\n"
			, "meanEpochRA              " , star.meanEpochRA , "\n"
			, "meanEpochDec             " , star.meanEpochDec , "\n"
			, "goodnessOfFitRa          " , star.goodnessOfFitRa , "\n"
			, "goodnessOfFitDec         " , star.goodnessOfFitDec , "\n"
			, "goodnessOfFitPmRa        " , star.goodnessOfFitPmRa , "\n"
			, "goodnessOfFitPmDec       " , star.goodnessOfFitPmDec , "\n"
			, "magnitudeB               " , star.magnitudeB , "\n"
			, "errorMagnitudeB          " , star.errorMagnitudeB , "\n"
			, "magnitudeV               " , star.magnitudeV , "\n"
			, "errorMagnitudeV          " , star.errorMagnitudeV , "\n"
			, "observedRa               " , star.observedRa , "\n"
			, "observedDec              " , star.observedDec , "\n"
			, "epoch1990Ra              " , star.epoch1990Ra , "\n"
			, "epoch1990Dec             " , star.epoch1990Dec , "\n"
			, "errorObservedRa          " , star.errorObservedRa , "\n"
			, "errorObservedDec         " , star.errorObservedDec , "\n"
			, "correlationRaDec         " , star.correlationRaDec , "\n"
			, "id                       " , star.id , "\n"
			, "idTycho1                 " , star.idTycho1 , "\n"
			, "idTycho2                 " , star.idTycho2 , "\n"
			, "numberOfUsedPositions    " , star.numberOfUsedPositions , "\n"
			, "errorRa                  " , star.errorRa , "\n"
			, "errorDec                 " , star.errorDec , "\n"
			, "proximityIndicator       " , star.proximityIndicator , "\n"
			, "hipparcosId              " , star.hipparcosId , "\n"
			, "isTycho1Star             " , star.isTycho1Star , "\n"
			, "idTycho3                 " , star.idTycho3 , "\n"
			, "pflag                    " , star.pflag , "\n"
			, "solutionType             " , star.solutionType , "\n"
			, "componentIdentifierHIP   " , star.componentIdentifierHIP , "\n"  )

except abcatalog.IError as error: 
	print ('catalog.cstycho2 codeError=', error.code, " message=", error.message)
			
			
del catalog





