#==============================================================================

# abmc.py
# import interface of abmc astrobrick
#==============================================================================


# --- Imports
import os
import ctypes
from ctypes import *
import copy 
from sys import platform
import json
from pprint import pprint

# --- Load the library
libname = "libabmc"
extension = ""
if platform == "linux" or platform == "linux2":
	extension = ".so"
elif platform== "darwin":
	extension = ".dylib"
elif platform == "win32":
	extension = ".dll"
ficlib = libname + extension
_abmc  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),ficlib))

#==============================================================================
# --- Help of the library
#==============================================================================
def help(function=""):
	libname = "abmc"
	fic = libname + "_ref_scripts.json"
	json_data=open(os.path.join( os.path.dirname(__file__),fic))
	data = json.load(json_data)
	doc = data["document"]
	if (doc!="Reference guide"):
		return 
	text = ""
	if (function=="") or (function=="*"):
		text = text + doc + " of " + data["name"] + "\n"
		text = text + data["details"]
	if (function==""):
		text = text + "\nType " + libname + ".help(\"*\") to list all functions."
		text = text + "\nType " + libname + ".help(\"angle2deg\") to obtain details of this function."
	else:
		# --- scan standalone functions
		if (function=="*"):
			text = text + "\n\nList of functions:\n\n"
		ns = 0
		defs = data["functions"]
		nd = len(defs)
		for kd in range(0,nd):
			d = defs[kd]["fn"]
			if (d==function) or (function=="*"):
				a = defs[kd]["args"]
				na = len(a)
				if (ns>0):
					text = text + "\n"
				text = text + doc + " for function " + libname + "." + d + " ("
				for ka in range(0,na):
					if ka>0:
						text = text + ", "
					text = text + a[ka]
				text = text + ")\n"
				if (d==function):
					text = text + "\n"
				text = text + defs[kd]["brief"] + "\n"
				if (d==function):
					text = text + "\n"
					text = text + defs[kd]["details"] + "\n"
					t = defs[kd]["example"]
					if (t!=""):
						text = text + "\nExample:\n\n"
						text = text + t + "\n"
					t = defs[kd]["related functions"]
					if (t!=""):
						text = text + "\nRelated functions:\n\n"
						text = text + t + "\n"					
				ns=ns+1
		# --- scan types
		if (function=="*"):
			text = text + "\n\nList of types:\n\n"
		ns = 0
		defs = data["types"]
		nd = len(defs)
		for kd in range(0,nd):
			d = defs[kd]["type"]
			if (d==function) or (function=="*"):
				if (ns>0):
					text = text + "\n"
				text = text + "Type " + d + "\n"
				if (d==function):
					text = text + "\n"
				text = text + defs[kd]["brief"] + "\n"
				if (d==function):
					text = text + "\n"
					text = text + defs[kd]["details"] + "\n"
				ns=ns+1
	json_data.close()
	return text
	

#==============================================================================
# IError
#==============================================================================
class IError(BaseException):
	def __init__(self, code=None, message=None):
		if code is None :
			self.code = _abmc.errorCode()
			self.message = ctypes.string_at( _abmc.errorMessage()).decode('utf-8')	
		else:
			self.code = code
			self.message = ctypes.string_at(message).decode('utf-8')
	def __del__(self): pass
	def dump(self):
		print (self.code, self.message)
		return

#checkError =  lambda x: if( _abmc.errorCode() != 0 ) : raise IError
def checkError():
	if( _abmc.errorCode() != 0 ) : raise IError()
	return

#==============================================================================
# deleteCharArray  
#==============================================================================
# remarque : Unfortunately, the normal return value for func would be c_char_p, 
# but ctypes tries to be helpful and convert a c_char_p return value to a Python string
# losing access to the raw C pointer value. Instead, you can declare the return type as c_void_p. 
_abmc.deleteCharArray.argtypes = [ctypes.c_void_p]

#==============================================================================
# Sense enum ( utilise par la classe Home )
#==============================================================================
import enum 

##@brief controle la valeur d'un Enum et convertit la valeur  en c_int 
class CtypesIntEnum(enum.IntEnum):

	def __new__(cls):
		value = len(cls.__members__) 
		obj = int.__new__(cls)
		obj._value_ = value
		return obj
		
	@classmethod
	def from_param(cls, obj):
		#--- see https://docs.python.org/3.3/library/ctypes.html?highlight=cdll#data-types
		if not isinstance(obj, cls):
			message = "value %s is not %s" % (obj,cls)
			raise IError( 104, message.encode('utf8') )
		return int(obj)

#==============================================================================
# Sense enum ( utilise par la classe Home )
#==============================================================================
class Sense(CtypesIntEnum):
	EAST = ()
	WEST = ()

#==============================================================================
# Frame enum 
#==============================================================================
class Frame(CtypesIntEnum):
	TRF =()
	CRF =()


#==============================================================================
# Angle class
#==============================================================================
_abmc.IAngle_get_deg.argtypes = [ctypes.c_void_p, ctypes.c_double]
_abmc.IAngle_get_deg.restype = ctypes.c_double
_abmc.IAngle_get_rad.restype = ctypes.c_double
_abmc.IAngle_get_sdd_mm_ss.restype = ctypes.c_void_p

class Angle(object):
	def __init__(self, angle, const = 0): 
		supertype = tool_get_supertype(angle)
		if (supertype=="string"):
			this = _abmc.IAngle_createInstance_from_string(angle.encode('utf8'))
		elif (supertype=="numeric") and const==1:
			this = angle
		elif (supertype=="numeric"):
			this = _abmc.IAngle_createInstance_from_deg(angle)
		else:
			raise Error(1, "ERREUR de type de donnees")
		checkError()
		try: self.this.append(this)
		except: self.this = this
		self.const = const
	def __del__(self): 
		if hasattr(self,'this') and self.const ==0 :
			_abmc.IAngle_deleteInstance(self.this)
			checkError()
	def get_deg(self, limit_deg):
		result = _abmc.IAngle_get_deg(self.this, limit_deg)
		checkError()
		return result
	def get_rad(self, limit_rad):
		result = _abmc.IAngle_get_rad(self.this, limit_rad)
		checkError()
		return result
	def getSDMS(self, imit_deg):
		result = _abmc.IAngle_get_sdd_mm_ss(self.this, imit_deg)
		checkError()
		result2 = ctypes.string_at(copy.copy(result)).decode('utf-8') 
		_abmc.deleteCharArray(result)
		return result2
	def getSexagesimal(self, format):
		result = _abmc.IAngle_getSexagesimal(self.this, format)
		checkError()
		result2 = ctypes.string_at(copy.copy(result)).decode('utf-8') 
		_abmc.deleteCharArray(result)
		return result2
	
#==============================================================================
# Coordinates class
#==============================================================================
_abmc.ICoordinates_getAngle1.restype = c_void_p

class Coordinates(object):
	def __init__(self, *args): 
		argc = len(args)
		if argc==0:
			this = _abmc.ICoordinates_createInstance()
			checkError()
		elif argc==1 :
			this = _abmc.ICoordinates_createInstance_from_string(args[0].encode('utf8') )
			checkError()
		elif argc==2 :
			this = _abmc.ICoordinates_createInstance_from_angle(args[0], args[1] )
			checkError()
		else: 
			raise IError( 104, "Date(args) invalid args number".encode('utf8'))		
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): 
		if hasattr(self,'this'):
			_abmc.ICoordinates_deleteInstance(self.this)
			checkError()
	def getAngle1(self):
		result = _abmc.ICoordinates_getAngle1(self.this)
		checkError()
		return Angle(result,1)		
			
				
#==============================================================================
# Date class
#==============================================================================
_abmc.IDate_get_iso.restype = ctypes.c_void_p
_abmc.IDate_get_jd.restype = ctypes.c_double
class Date(object):
	def __init__(self, *args): 
		argc = len(args)
		if argc==0:
			this = _abmc.IDate_createInstance()
			checkError()
		elif argc==1 :
			this = _abmc.IDate_createInstance_from_string(args[0].encode('utf8') )
			checkError()
		elif argc==3 :
			this = _abmc.IDate_createInstance_from_ymd(args[0], args[1], argvs[2] )
			checkError()
		elif argc==6 :
			this = _abmc.IDate_createInstance_from_ymdhms(args[0], args[1], argvs[2], args[3], args[4], argvs[5] )
			checkError()
		else: 
			raise IError( 104, "Date(args) invalid args number".encode('utf8'))
		try: self.this.append(this)
		except: self.this = this		
	def __del__(self): 
		if hasattr(self,'this'):
			_abmc.IDate_deleteInstance(self.this)
			checkError()
	def get_jd(self, frame):
		result = _abmc.IDate_get_jd(self.this, frame)
		checkError()
		return result
	def get_iso(self, frame):
		result = _abmc.IDate_get_iso(self.this, frame)
		result2 = ctypes.string_at(copy.copy(result)).decode('utf-8')
		_abmc.deleteCharArray(result)
		checkError()
		return result2



#==============================================================================
# Home class
#==============================================================================
_abmc.IHome_createInstance_from_GPS.argtypes = [ctypes.c_double, Sense, ctypes.c_double, ctypes.c_double]
_abmc.IHome_get_GPS.argtypes = [ctypes.c_void_p, Frame]
_abmc.IHome_get_GPS.restype = ctypes.c_char_p
_abmc.IHome_get_MPC.argtypes = [ctypes.c_void_p, Frame]
_abmc.IHome_get_MPC.restype = ctypes.c_char_p
_abmc.IHome_get_sense.restype = Sense
class Home(object):
	def __init__(self, *args): 
		argc = len(args)
		if argc==0:
			this = _abmc.IHome_createInstance()
			checkError()
		elif argc==1 :
			this = _abmc.IHome_createInstance_from_string(args[0].encode('utf8'))
			checkError()
		elif argc==4 :
			this = _abmc.IHome_createInstance_from_GPS(args[0].encode('utf8'), args[1], argvs[2], args[3] )
			checkError()
		else: 
			raise IError( 104, "Home(args) invalid args number".encode('utf8'))
		try: self.this.append(this)
		except: self.this = this		
	def __del__(self): 
		if hasattr(self,'this'):
			_abmc.IHome_deleteInstance(self.this)
			checkError()
	def getGPS(self, frame):
		result = _abmc.IHome_get_GPS(self.this, frame)
		checkError()
		return result.decode('utf8')
	def getMPC(self, frame):
		result = _abmc.IHome_get_MPC(self.this, frame)
		checkError()
		return result.decode('utf8')
	def getSense(self):
		result = _abmc.IHome_get_sense(self.this)
		checkError()
		return result
	

#==============================================================================
# Mc class
#==============================================================================

class Mc(object):
	def __init__(self, this=None): 
		if this==None:
			this = _abmc.IMcPool_createInstance()
			checkError()
		try: self.this.append(this)
		except: self.this = this		
	def __del__(self):
		if hasattr(self,'this'): 
			_abmc.IMcPool_deleteInstance(self.this)
			checkError()
	def angle2deg(self, angle):
		supertype = tool_get_supertype(angle)
		if (supertype=="string"):
			cdeg=ctypes.c_double()
			_abmc.abmc_angle2deg(self.this, angle.encode('utf8'),ctypes.byref(cdeg))
			checkError()
			angle_deg = cdeg.value
		elif (supertype=="numeric"):
			angle_deg = angle
		else:
			print("ERREUR de type de donnees")
			return
		return angle_deg
	def angle2rad(self, angle):
		supertype = tool_get_supertype(angle)
		if (supertype=="string"):
			cdeg=ctypes.c_double()
			_abmc.abmc_angle2rad(self.this, angle.encode('utf8'),ctypes.byref(cdeg))
			checkError()
			angle_rad = cdeg.value
		elif (supertype=="numeric"):
			angle_rad = angle
		else:
			print("ERREUR de type de donnees")
			return
		return angle_rad
	def angle2sexagesimal(self, angle, format):
		# --- decode angle
		angle_deg = self.angle2deg(angle)
		sexagesimal = create_string_buffer(80)
		_abmc.abmc_angle2sexagesimal(self.this, c_double(angle_deg),format.encode('utf8'),byref(sexagesimal))
		checkError()
		return sexagesimal.value.decode('utf8')
	def date2jd(self, date):
		# --- decode date
		supertype = tool_get_supertype(date)
		if (supertype=="string"):
			cjd=ctypes.c_double()
			_abmc.abmc_date2jd(self.this, date.encode('utf8'),ctypes.byref(cjd))
			checkError()
			date_jd = cjd.value
		elif (supertype=="numeric"):
			date_jd = date
		else:
			print("ERREUR de type de donnees")
			return
		return date_jd

# ==================================================================
# ==================================================================
# tools
# ==================================================================
# ==================================================================

# --- Give the supertype as a string numeric or string
def tool_get_supertype(variable):
	vartype = type(variable)
	supertype = "unknown"
	if (vartype==int) or (vartype==float) or (vartype==bool):
		supertype = "numeric"
	#elif (vartype==str) or (vartype==unicode) or (vartype==basestring):
	elif (vartype==str):
		supertype = "string"
	return supertype
	
"""
_abmc.IDate_createInstance_from_string.argtypes = [ctypes.c_char_p]
_abmc.IDate_createInstance_from_string.restypes = [ctypes.c_double]

_abmc.IDate_releaseInstance.argtypes = [ctypes.c_void_p]
_abmc.IDate_releaseInstance.restypes = None

_abmc.IDate_get_jd.argtypes = [ctypes.c_void_p, ctypes.c_int]
_abmc.IDate_get_jd.restypes = [ctypes.c_double]

_abmc.abmc_date2jd.argtypes = [ctypes.c_char_p, ctypes.POINTER(ctypes.c_double)]
_abmc.abmc_date2jd.restypes = [ctypes.c_int]

def date2jd_2(date):
	jj=ctypes.c_double();
	ABMC_IERS_FRAME_TRF = 0
	IDate = _abmc.IDate_createInstance_from_string(date.encode('utf8'))
	jj = _abmc.IDate_get_jd(IDate,ABMC_IERS_FRAME_TRF)
	_abmc.IDate_releaseInstance(IDate);
	return jj
"""

"""	
class mastruct(ctypes.Structure):
	_fields_ = [
		("chaine" , ctypes.c_char * 20) ,
		("numero" , ctypes.c_int)
		]
	
def test_struct():
	toto=mastruct()
	_abmc.abmc_test_struct(byref(toto))
	return toto
	
def test_struct_pointer():
	# ca marche pas
	toto=ctypes.POINTER(mastruct)
	_abmc.abmc_test_struct_pointer(ctypes.POINTER.byref(toto))
	titi= mastruct(toto)
	_abmc.abmc_test_struct_delete_mastruct(toto)
	return titi

_abmc.abmc_test_struct_pointer2.restype=ctypes.POINTER(mastruct)

def test_struct_pointer2():
	toto=_abmc.abmc_test_struct_pointer2()
	titi= copy.copy(toto.contents)
	_abmc.abmc_test_struct_delete_mastruct(toto)
	return titi

_abmc.abmc_test_struct_tableau.restype=ctypes.POINTER(mastruct)
_abmc.abmc_test_struct_tableau_at.restype=ctypes.POINTER(mastruct)

def test_struct_tableau():
	toto=_abmc.abmc_test_struct_tableau()
	n=_abmc.abmc_test_struct_tableau_size(toto)
	titis=[];
	for i in range(0,n) :
		titi = _abmc.abmc_test_struct_tableau_at(toto,i)
		titis.append( copy.copy ( titi.contents ) )		
	_abmc.abmc_test_struct_tableau_release(toto)
	return titis
"""
