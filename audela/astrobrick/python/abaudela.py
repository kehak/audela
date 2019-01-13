# absimple.py
# import interface of absimple astrobrick

import os
import ctypes
import copy 
from sys import platform

# --- Load the library
libname = "libabaudela"
#print( libname )
extension = ""
if platform == "linux" or platform == "linux2":
	extension = ".so"
elif platform== "darwin":
	extension = ".dylib"
elif platform == "win32":
	extension = ".dll"
	
ficlib = libname + extension

#print( ficlib )
ablib  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),ficlib))




#-----------------------------------------------------------------------------
# convert params list to argc, argv 
#-----------------------------------------------------------------------------
def getArgcArgv(params):
	argc = len(params)
	argv = (ctypes.c_char_p * argc)()
	for i in range(argc):
		argv[i] =params[i].encode('utf8')
	return (argc, argv)

#-----------------------------------------------------------------------------
# Error
#-----------------------------------------------------------------------------
class Error(BaseException):
	def __init__(self, code, message):
		self.code = code
		self.message = ctypes.string_at(message).decode('utf-8')
	def __del__(self): pass
	def dump(self):
		print (self.code, self.message)
		return

#-----------------------------------------------------------------------------
# Buffer
#-----------------------------------------------------------------------------	
ablib.IBuffer_createInstance.restype = ctypes.c_void_p
ablib.IBuffer_deleteInstance.argtypes = [ctypes.c_void_p]

class Buffer(object):
	def __init__(self):
		this = ablib.IBuffer_createInstance()
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): ablib.IBuffer_deleteInstance(self.this)
	def getWidth(self):
		return ablib.IBuffer_getHeight(self.this)
	def getHeight(self):
		return ablib.IBuffer_getWidth(self.this)

	
#-----------------------------------------------------------------------------
# Camera
#-----------------------------------------------------------------------------	
# Define the error callback function type	( /\ first argument must be return type)   
CB_FUNC_TYPE = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_double, ctypes.c_char_p)

# ICamera functions prototypes
ablib.ICamera_acq.argtypes = [ctypes.c_void_p]
ablib.ICamera_setCallback.argtypes = [ctypes.c_void_p, CB_FUNC_TYPE, ctypes.c_void_p]
ablib.ICamera_getExptime.restype = ctypes.c_double
ablib.ICamera_setExptime.argtypes = [ctypes.c_void_p, ctypes.c_double]
ablib.ICamera_getCameraName.restype = ctypes.c_char_p

def cameraCallback( clientData, code, value1, value2 , message):
	print( "acqCallback", clientData, code, value1, value2 , message )
	return 0

#def cameraCallback():
#	print( "acqCallback" )
#	return


class Camera(object):
	def __init__(self, libraryPath, libraryFileName, params):
		#self.this = None
		argc, argv = getArgcArgv(params)
		this = ablib.ICamera_createInstance(libraryPath.encode('utf8'), libraryFileName.encode('utf8'), argc, argv)
		if( ablib.errorCode() != 0 ) : raise  Error(ablib.errorCode(), ablib.errorMessage() )
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): 
		if self.this != None:
			ablib.ICamera_deleteInstance(self.this)
			if( ablib.errorCode() != 0 ) : raise Error(ablib.errorCode(), ablib.errorMessage() )
	def acq(self):
		ablib.ICamera_acq(self.this)
		if( ablib.errorCode() != 0 ) : raise Error(ablib.errorCode(), ablib.errorMessage() )
		return	
	def setCallback(self, callbackFunction):
		ablib.ICamera_setCallback(self.this, CB_FUNC_TYPE(cameraCallback), 0)
		if( ablib.errorCode() != 0 ) : raise Error(ablib.errorCode(), ablib.errorMessage() )
		return	
	def getExptime(self):
		value = ablib.ICamera_getExptime(self.this)
		if( ablib.errorCode() != 0 ) : raise Error(ablib.errorCode(), ablib.errorMessage() )
		return value			
	def setExptime(self, exptime):
		ablib.ICamera_setExptime(self.this, exptime)
		if( ablib.errorCode() != 0 ) : raise Error(ablib.errorCode(), ablib.errorMessage() )
		return	
	def getCameraName(self):
		value = ablib.ICamera_getCameraName(self.this).decode('utf8')
		if( ablib.errorCode() != 0 ) : raise Error(ablib.errorCode(), ablib.errorMessage() )
		return value
	


