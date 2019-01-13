# abtt.py
# import interface of absimple astrobrick

import os
import ctypes
import copy 
from sys import platform

if platform == "linux" or platform == "linux2":
   _abtt  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libtt.so"))
elif platform== "darwin":
   _abtt  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libtt.dylib"))
elif platform == "win32":
   _abtt  = ctypes.cdll.LoadLibrary(os.path.join( os.path.dirname(__file__),"libtt.dll"))

class ImageStackOptions(ctypes.Structure):
	_fields_ = [
		("bitpix" 			, ctypes.c_int) ,
		("nullpix_exist" 	, ctypes.c_int),
		("nullpix_value" 	, ctypes.c_double) ,
		("percent" 			, ctypes.c_double) ,
		("jpegfile_make" 	, ctypes.c_int) ,
		("jpegfile" 		, ctypes.c_char_p),
		("jpeg_qualite" 	, ctypes.c_int) ,
		("kappa" 			, ctypes.c_double),
		("drop_pixsize" 	, ctypes.c_double) ,
		("oversampling" 	, ctypes.c_double) ,
		("powernorm" 		, ctypes.c_int) ,
		("hotPixelList" 	, ctypes.POINTER(ctypes.c_int)) ,
		("cosmicThreshold" 	, ctypes.c_float) ,
		("xcenter"          , ctypes.c_double) ,
		("ycenter"          , ctypes.c_double) ,
		("radius"          	, ctypes.c_double) 	
	]
	
	def __init__(self, 
			bitpix 	        = 0 ,
			nullpix_exist 	= 1 ,
			nullpix_value 	= 0 ,
			percent 		= 50 ,
			jpegfile_make 	= 1 ,
			jpegfile 		= "",
			jpeg_qualite 	= 75 ,
			kappa 			= 3,
			drop_pixsize 	= 0.5 ,
			oversampling 	= 2 ,
			powernorm 		= 0 ,
			hotPixelList 	= 0 ,
			cosmicThreshold = 0 ,
			xcenter         = 0 ,
			ycenter         = 0 ,
			radius         	= 0 
	    ):
			super(ImageStackOptions, self).__init__(
				bitpix 	        ,
				nullpix_exist 	,
				nullpix_value 	,
				percent 		,
				jpegfile_make 	,
				ctypes.c_char_p(0),
				jpeg_qualite 	,
				kappa 			,
				drop_pixsize 	,
				oversampling 	,
				powernorm 		,
				ctypes.cast(0, ctypes.POINTER(ctypes.c_long)) 	,
				cosmicThreshold ,
				xcenter         ,
				ycenter         ,
				radius
			    )

# Function prototypes
_abtt.abtt_imageStack.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int, ctypes.c_char_p, ctypes.c_char_p, ctypes.POINTER(ImageStackOptions)]
_abtt.abtt_imageStack.restype = ctypes.c_int				

# declare standalone function
def imageStack(dirname, 
				load_file_name, 
				load_indice_deb,
				load_indice_fin,
				load_level_index,
				load_extension,
				save_path_name,
				save_file_name, 
				save_indice_deb, 
				save_level_index,
				save_extension,
				fonction,
				options):
	return _abtt.abtt_imageStack(
				dirname.encode('utf8'), 
				load_file_name.encode('utf8'), 
				load_indice_deb,
				load_indice_fin,
				load_level_index,
				load_extension.encode('utf8'),
				save_path_name.encode('utf8'),
				save_file_name.encode('utf8'), 
				save_indice_deb, 
				save_level_index,
				save_extension.encode('utf8'),
				fonction.encode('utf8'),
				options)
	



