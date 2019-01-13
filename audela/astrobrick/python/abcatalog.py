# abcatalog.py
# import interface of abcatalog astrobrick

import os
import ctypes
import copy 
from sys import platform

# load libcatalog astrobrick
if platform == "linux" or platform == "linux2":
   abcatalog  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libcatalog.so"))
elif platform== "darwin":
   abcatalog = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libcatalog.dylib"))
elif platform == "win32":
   abcatalog = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libcatalog.dll"))

abcatalog.ICatalog_createInstance.argtypes= [ctypes.c_void_p]
abcatalog.ICatalog_createInstance.restype = ctypes.c_void_p
abcatalog.ICatalog_releaseInstance.argtypes= [ctypes.c_void_p]
abcatalog.ICatalog_releaseInstance.restype = None


class starTycho(ctypes.Structure):
	_fields_ = [
		("ra" 						, ctypes.c_double) ,
		("dec" 						, ctypes.c_double),
		("pmRa" 					, ctypes.c_double) ,
		("pmDec" 					, ctypes.c_double) ,
		("errorPmRa" 				, ctypes.c_double) ,
		("errorPmDec" 				, ctypes.c_double),
		("meanEpochRA" 				, ctypes.c_double) ,
		("meanEpochDec" 			, ctypes.c_double),
		("goodnessOfFitRa" 			, ctypes.c_double) ,
		("goodnessOfFitDec" 		, ctypes.c_double) ,
		("goodnessOfFitPmRa" 		, ctypes.c_double) ,
		("goodnessOfFitPmDec" 		, ctypes.c_double) ,
		("magnitudeB" 				, ctypes.c_double) ,
		("errorMagnitudeB"          , ctypes.c_double) ,
		("magnitudeV"               , ctypes.c_double) ,
		("errorMagnitudeV"          , ctypes.c_double) ,
		("observedRa" 				, ctypes.c_double) ,
		("observedDec" 				, ctypes.c_double) ,
		("epoch1990Ra" 				, ctypes.c_double) ,
		("epoch1990Dec" 			, ctypes.c_double),
		("errorObservedRa" 			, ctypes.c_double) ,
		("errorObservedDec" 		, ctypes.c_double) ,
		("correlationRaDec" 		, ctypes.c_double),
		("id" 						, ctypes.c_int) ,
		("idTycho1" 				, ctypes.c_int) ,
		("idTycho2" 				, ctypes.c_int) ,
		("numberOfUsedPositions" 	, ctypes.c_int) ,
		("errorRa" 					, ctypes.c_int) ,
		("errorDec" 				, ctypes.c_int) ,
		("proximityIndicator" 		, ctypes.c_int) ,
		("hipparcosId" 				, ctypes.c_int) ,
		("isTycho1Star" 			, ctypes.c_char) ,
		("idTycho3" 				, ctypes.c_char),
		("pflag" 					, ctypes.c_char) ,
		("solutionType" 			, ctypes.c_char) ,
		("componentIdentifierHIP" 	, ctypes.c_char * 3)	
		]
	
#--- 	listOfStarsTycho  class declaration (because recursive deinition)
class listOfStarsTycho(ctypes.Structure):
	pass
listOfStarsTycho._fields_ = [("star", starTycho), ("nextStarList", ctypes.POINTER(listOfStarsTycho))]
	
abcatalog.ICatalog_cstycho2.argtypes = [ctypes.c_void_p, ctypes.c_char_p, 
	ctypes.c_double, ctypes.c_double, ctypes.c_double, ctypes.c_double, ctypes.c_double]
abcatalog.ICatalog_cstycho2.restype = ctypes.POINTER(listOfStarsTycho)

abcatalog.ICatalog_releaseListOfStarTycho.argtypes = [ctypes.c_void_p, ctypes.POINTER(listOfStarsTycho)]

#-----------------------------------------------------------------------------
# IError
#-----------------------------------------------------------------------------
class IError(BaseException):
	def __init__(self, code, message):
		self.code = code
		self.message = message
	def __del__(self): pass
	def dump(self):
		print (repr(self.__dict__))
		return

def raisePendingError():
	global pendingError
	tempError = pendingError
	pendingError = None
	raise tempError		

pendingError = None
		
def errorCallback(code, message):
	global pendingError
	pendingError = IError(code, ctypes.string_at(message).decode('utf-8'))
	#print ('errorCallback pendingError=', pendingError)
	return		
	
# Define the error callback function type	
CB_FUNC_TYPE = ctypes.CFUNCTYPE(None, ctypes.c_int, ctypes.c_char_p)
# Wrap errorCallback in CB_FUNC_TYPE to pass it to ctypes
error_callback_function = CB_FUNC_TYPE(errorCallback)	

#-----------------------------------------------------------------------------
# ICatalog
#-----------------------------------------------------------------------------	
class ICatalog(object):
	def __init__(self): 
		this = abcatalog.ICatalog_createInstance(error_callback_function)
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): abcatalog.ICatalog_releaseInstance(self.this)
	def cstycho2(self, catalogPath, ra, dec, radius, magMin, magMax):
		starList = abcatalog.ICatalog_cstycho2(self.this, catalogPath.encode('utf8'), ra, dec, radius, magMin, magMax)
		global pendingError
		if (pendingError is not None) : raisePendingError()
		#-- copy linked list to array
		stars = []
		nextStarList = starList
		while nextStarList :
			stars.append( copy.copy(nextStarList.contents.star))
			nextStarList = nextStarList.contents.nextStarList
		#--- release starList
		abcatalog.ICatalog_releaseListOfStarTycho(self.this, starList)
		return stars

