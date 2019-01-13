# absimple.py
# import interface of absimple astrobrick

import os
import ctypes
import copy 
from sys import platform

if platform == "linux" or platform == "linux2":
   _absimple  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libabsimple.so"))
elif platform== "darwin":
   _absimple  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libabsimple.dylib"))
elif platform == "win32":
   _absimple  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libabsimple.dll"))

IDateTime_getMap = { 
		'year':   _absimple.IDateTime_year_get, 
		'month':  _absimple.IDateTime_month_get,
		'day':    _absimple.IDateTime_day_get,
		'hour':   _absimple.IDateTime_hour_get,
		'minute': _absimple.IDateTime_minute_get,
		'second': _absimple.IDateTime_second_get,
	}

class IDateTime(object):
	def __init__(self, cPtr): 
		this = cPtr
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): _absimple.IDateTime_deleteInstance(self.this)
	def dump(self):
		print (repr(self.__dict__))
		return
	def __getattr__(self,name):
		if (name != "this" ):
			if name in IDateTime_getMap:
				return IDateTime_getMap[name](self.this)
			else:
				print ("Couldn't find", name , " " , "IDateTime_getMap")
				return

_absimple.ICalculator_createInstance.argtypes = [ctypes.c_void_p]
_absimple.ICalculator_createInstance.restype = ctypes.c_void_p				
_absimple.ICalculator_deleteInstance.argtypes = [ctypes.c_void_p]
_absimple.ICalculator_deleteInstance.restype = None
_absimple.ICalculator_add.argtypes = [ctypes.c_void_p,ctypes.c_double]
_absimple.ICalculator_add.restype = ctypes.c_double
_absimple.ICalculator_set.argtypes = [ctypes.c_void_p,ctypes.c_double]
_absimple.ICalculator_set.restype = ctypes.c_double
_absimple.ICalculator_sub.argtypes = [ctypes.c_void_p,ctypes.c_double]
_absimple.ICalculator_sub.restype = ctypes.c_double
_absimple.ICalculator_divide.argtypes = [ctypes.c_void_p,ctypes.c_double]
_absimple.ICalculator_divide.restype = ctypes.c_double

_absimple.ICalendar_createInstance.argtypes = [ctypes.c_void_p]
_absimple.ICalendar_createInstance.restype = ctypes.c_void_p				
_absimple.ICalendar_deleteInstance.argtypes = [ctypes.c_void_p]
_absimple.ICalendar_deleteInstance.restype = None
_absimple.ICalendar_convertIntToString.argtypes = [ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int]
_absimple.ICalendar_convertIntToString.restype = ctypes.c_void_p
_absimple.ICalendar_convertIntToStruct.argtypes = [ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int]
_absimple.ICalendar_convertIntToStruct.restype = ctypes.c_void_p
_absimple.ICalendar_convertStringToStruct.argtypes = [ctypes.c_void_p,ctypes.c_char_p]
_absimple.ICalendar_convertStringToStruct.restype = ctypes.c_void_p


_absimple.errorMessage.restype = ctypes.c_void_p
_absimple.absimple_releaseCharArray.argtypes = [ctypes.c_void_p]
_absimple.IDateTime_deleteInstance.argtypes = [ctypes.c_void_p]

_absimple.IDateTime_year_get.argtypes = [ctypes.c_void_p]
_absimple.IDateTime_year_get.restype = ctypes.c_int
_absimple.IDateTime_year_set.argtypes = [ctypes.c_void_p, ctypes.c_int]
_absimple.IDateTime_year_set.restype = None
_absimple.IDateTime_month_get.argtypes = [ctypes.c_void_p]
_absimple.IDateTime_month_get.restype = ctypes.c_int
_absimple.IDateTime_month_set.argtypes = [ctypes.c_void_p, ctypes.c_int]
_absimple.IDateTime_month_set.restype = None
_absimple.IDateTime_day_get.argtypes = [ctypes.c_void_p]
_absimple.IDateTime_day_get.restype = ctypes.c_int
_absimple.IDateTime_day_set.argtypes = [ctypes.c_void_p, ctypes.c_int]
_absimple.IDateTime_day_set.restype = None
_absimple.IDateTime_hour_get.argtypes = [ctypes.c_void_p]
_absimple.IDateTime_hour_get.restype = ctypes.c_int
_absimple.IDateTime_hour_set.argtypes = [ctypes.c_void_p, ctypes.c_int]
_absimple.IDateTime_hour_set.restype = None
_absimple.IDateTime_minute_get.argtypes = [ctypes.c_void_p]
_absimple.IDateTime_minute_get.restype = ctypes.c_int
_absimple.IDateTime_minute_set.argtypes = [ctypes.c_void_p, ctypes.c_int]
_absimple.IDateTime_minute_set.restype = None
_absimple.IDateTime_second_get.argtypes = [ctypes.c_void_p]
_absimple.IDateTime_second_get.restype = ctypes.c_int
_absimple.IDateTime_second_set.argtypes = [ctypes.c_void_p, ctypes.c_int]
_absimple.IDateTime_second_set.restype = None

_absimple.IArray_size.argtypes = [ctypes.c_void_p]
_absimple.IArray_size.restype = ctypes.c_int
_absimple.IArray_deleteInstance.argtypes = [ctypes.c_void_p]



# declare standalone function
def processAdd(*args):
	return _absimple.absimple_processAdd(*args)
	
def processSub(*args):
	return _absimple.absimple_processSub(*args)
	
#-----------------------------------------------------------------------------
# IError
#-----------------------------------------------------------------------------
class IError(BaseException):
	def __init__(self, code=None, message=None):
		if code is None :
			self.code = _absimple.errorCode()
			self.message = ctypes.string_at( _absimple.errorMessage()).decode('utf-8')	
		else:
			self.code = code
			self.message = ctypes.string_at(message).decode('utf-8')
	def __del__(self): pass
	def dump(self):
		print (self.code, self.message)
		return

#checkError =  lambda x: if( _absimple.errorCode() != 0 ) : raise IError
def checkError():
	if( _absimple.errorCode() != 0 ) : raise IError()
	return
		
#-----------------------------------------------------------------------------
# IError Callback
#-----------------------------------------------------------------------------
def raisePendingError():
	global pendingError
	tempError = pendingError
	pendingError = None
	raise tempError		

pendingError = None

#register errorCallback
def errorCallback(code, message):
	global pendingError
	pendingError = IError(code, message)
	#print ('errorCallback2 pendingError=', pendingError)
	return

# Define the error callback function type	
CB_FUNC_TYPE = ctypes.CFUNCTYPE(None, ctypes.c_int, ctypes.c_char_p)
# Wrap errorCallback in CB_FUNC_TYPE to pass it to ctypes
error_callback_function = CB_FUNC_TYPE(errorCallback)	
	
#-----------------------------------------------------------------------------
# ICatalog
#-----------------------------------------------------------------------------	
class ICalculator(object):
	def __init__(self):
		this = _absimple.ICalculator_createInstance(error_callback_function)
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): _absimple.ICalculator_deleteInstance(self.this)
	def add(self, *args):
		return _absimple.ICalculator_add(self.this, *args)
	def set(self, *args):
		return _absimple.ICalculator_set(self.this, *args)
	def sub(self, *args): 
		return _absimple.ICalculator_sub(self.this, *args)
	def divide(self, *args): 
		result = _absimple.ICalculator_divide(self.this, *args)
		global pendingError
		if (pendingError is not None) : raisePendingError()
		return result

#-----------------------------------------------------------------------------
# ICalendar
#-----------------------------------------------------------------------------	
class ICalendar(object):
	def __init__(self): 
		this = _absimple.ICalendar_createInstance(error_callback_function)
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): _absimple.ICalendar_deleteInstance(self.this)
	def convertIntToString(self, *args):
		charPtr = _absimple.ICalendar_convertIntToString(self.this, *args)
		result = ctypes.string_at(copy.copy(charPtr)).decode('utf-8') 
		_absimple.absimple_releaseCharArray(charPtr)
		return result 
	def convertIntToString5(self, *args):
		charPtr = _absimple.ICalendar_convertIntToString5(self.this, *args)
		checkError()
		result = ctypes.string_at(copy.copy(charPtr)).decode('utf-8') 
		_absimple.absimple_releaseCharArray(charPtr)
		return result 
	def convertIntToStruct(self, y, m, d, hh, mm , ss):
		dateTimePtr = _absimple.ICalendar_convertIntToStruct(self.this, y, m, d, hh, mm , ss)
		global pendingError
		if (pendingError is not None) : raisePendingError()
		dateTime = IDateTime(dateTimePtr)
		return dateTime
	def convertStringToStruct(self, date):
		dateTimePtr = _absimple.ICalendar_convertStringToStruct(self.this, date.encode('utf8'))
		global pendingError
		if (pendingError is not None) : raisePendingError()
		return IDateTime(dateTimePtr)
				
#-----------------------------------------------------------------------------
# copy array
#-----------------------------------------------------------------------------	
class IArray(ctypes.Structure):
	pass
class IIntArray(IArray):
	pass
class IStringArray(IArray):
	pass
class IStructArray(IArray): 
	pass
class IDataArray(IArray): 
	pass
	
_absimple.IIntArray_at.restype  = ctypes.c_int
_absimple.IStringArray_at.restype  = ctypes.c_char_p
_absimple.IStructArray_at.restype  = ctypes.c_void_p
	
def copyToArray(clist, structType=None):
	myType = type(clist)
	print("type=", type(clist))
	result = []		
	if myType== ctypes.POINTER(IIntArray): 
		for i in range (0 , _absimple.IArray_size(clist)):
			result.append ( _absimple.IIntArray_at(clist,i) )
			checkError()
		_absimple.IArray_deleteInstance(clist)
	elif myType== ctypes.POINTER(IStringArray): 
		for i in range (0 , _absimple.IArray_size(clist)):
			result.append ( copy.copy(_absimple.IStringArray_at(clist,i)).decode('utf8') )
			checkError()
		_absimple.IArray_deleteInstance(clist)
	elif myType== ctypes.POINTER(IStructArray) or structType!=None: 
		result = []
		for i in range (0 , _absimple.IArray_size(clist)):
			result.append ( copy.deepcopy(ctypes.cast(_absimple.IStructArray_at(clist,i),structType).contents ) )
			checkError()
		_absimple.IArray_deleteInstance(clist)
	else: 
		raise NotImplementedError("copyToArray ", myType)
	return result	 	
		
#-----------------------------------------------------------------------------
# Planet
#-----------------------------------------------------------------------------

_absimple.absimple_getPlanetMass.restype = ctypes.c_double

def getPlanetMass(planetName):
	mass = _absimple.absimple_getPlanetMass(planetName.encode('utf8'));
	checkError()
	return mass

_absimple.absimple_getPlanetNameList.restype = ctypes.POINTER(IStringArray)

def getPlanetNameList():
	clist = _absimple.absimple_getPlanetNameList();
	checkError()
	return copyToArray(clist)

	
class orbit(ctypes.Structure):
	_fields_ = [
		("a" , ctypes.c_double),
		("e" , ctypes.c_double),
		("i" , ctypes.c_double) 
	]

def getOrbitList():
	clist = _absimple.absimple_getOrbitList();
	if( _absimple.errorCode() != 0 ) : raise IError()
	return copyToArray(clist, ctypes.POINTER(orbit))



class WorkItemProducer(object):
	def __init__(self): 
		this = _absimple.IWorkItemProducer_createInstance()
		checkError()
		try: self.this.append(this)
		except: self.this = this
	def __del__(self): 
		_absimple.IWorkItemProducer_deleteInstance(self.this)
		checkError()
	def run(self, iterations):
		_absimple.IWorkItemProducer_run(self.this, iterations)
		checkError()

class Producer(object):
	def __init__(self, this=None): 
		if this==None:
			this = _absimple.IProducerPool_createInstance()
			checkError()
		try: self.this.append(this)
		except: self.this = this
			
	def __del__(self): 
		_absimple.IProducerPool_deleteInstance(self.this)
		checkError()
	def acq(self, tempo):
		_absimple.IProducer_acq(self.this, tempo)
		checkError()
	def waitMessage(self):
		result = _absimple.IProducer_waitMessage(self.this)
		checkError()
		return result

_absimple.IProducerPool_getIntanceNoList.restype = ctypes.POINTER(IIntArray)
	
def Producer_getItemNoList():
	clist = _absimple.IProducerPool_getIntanceNoList()
	checkError()
	return copyToArray(clist)

#==============================================================================
# Station class
#==============================================================================

import enum 
class CtypesIntEnum(enum.IntEnum):

	def __new__(cls):
		print("new cls=", type(cls) )
		value = len(cls.__members__) 
		obj = int.__new__(cls)
		obj._value_ = value
		print("new cls type(obj)=", type(obj) , "value=", value )
		return obj
	
#	@classmethod
#	def __init__(self, *args):
#		argc = len(args)
#		if len(args) == 1:
#			print("new __init__type=", type(self) )
#			print( "CtypesIntEnum=", args[0] )
#			self._as_parameter = int(args[0])
		
	
	@classmethod
	def from_param(cls, obj):
		print("from_param=", type(cls) , "obj=",obj, "type(obj)=",type(obj), "int(obj)=", int(obj) )
		#--- see https://docs.python.org/3.3/library/ctypes.html?highlight=cdll#data-types
		if not isinstance(obj, cls):
			message = "value %s is not %s" % (obj,cls)
			#raise IError( 104, message.encode('utf8') )
			raise TypeError(message )
		return int(obj.value)
	
def _Types_parser(cls, value):
	if not isinstance(value, int):
		print("==Types_parser=", type(cls) , "value=",value)
		return super(num.Enum, cls).__new__(cls, value)
	else:
		# https://github.com/python/cpython/blob/master/Lib/enum.py
		print("==Types_parser=", type(cls) , "type(value)=", type(value), "value=", value )
		#value = len(cls.__members__) + 1
		#obj = int.__new__(cls)
		#obj._value_ = value
		#return obj
		return list(cls._member_map_.values())[value]
		#return list(cls.__members__.items())[value]

setattr(enum.Enum, '__new__', _Types_parser)
	
	
class Sense(CtypesIntEnum):
	EAST = ()
	WEST = ()

class Frame(CtypesIntEnum):
	TRF = ()
	CRF = ()

print("members=", Sense.__members__)
print("__iter__=", Sense.__iter__)



_absimple.IStation_get_GPS.restype = ctypes.c_char_p
_absimple.IStation_get_GPS.argtypes = [ctypes.c_void_p, Frame]
_absimple.IStation_createInstance_from_string2.argtypes = [ctypes.c_void_p, Sense]
_absimple.IStation_getSense.restype = Sense
class Station(object):
	def __init__(self, *args): 
		argc = len(args)
		if argc==0:
			this = _absimple.IStation_createInstance()
			checkError()
		elif argc==1 :
			this = _absimple.IStation_createInstance_from_string(args[0].encode('utf8'))
			checkError()
		elif argc==2 :
			print( "args[1]=", args[1])
			this = _absimple.IStation_createInstance_from_string2(args[0].encode('utf8'), args[1])
			checkError()
		else: 
			raise IError( 104, "Station(args) invalid args number".encode('utf8'))
		try: self.this.append(this)
		except: self.this = this		
	def __del__(self): 
		if hasattr(self,'this'):
			_absimple.IStation_deleteInstance(self.this)
			checkError()
	def get_GPS(self, frame):
		result = _absimple.IStation_get_GPS(self.this, frame)
		checkError()
		return result.decode('utf8')
	def getSense(self):
		result = _absimple.IStation_getSense(self.this)
		checkError()
		return result

