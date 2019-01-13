
# load absimple astrobrick
import absimple
import ctypes



try:
	station1 = absimple.Station()	
	print ("station1.get_GPS=",  station1.get_GPS( absimple.Frame.TRF ) )
	station2 = absimple.Station("GPS 11", absimple.Sense.WEST)	
	#station2 = absimple.Station("GPS 11", )	
	print ("station2.get_GPS(TRF)=",  station2.get_GPS( absimple.Frame.TRF ) )
	print ("station2.get_GPS(CRF)=",  station2.get_GPS( absimple.Frame.CRF ) )
	print (" absimple.Frame.CRF=",   absimple.Frame.CRF )

	print ("station2.getSense()=",  station2.getSense() )

except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )


try:
	print ("station2.get_GPS(2)=",  station2.get_GPS( 2 ) )
	
except ctypes.ArgumentError as error: 
	print ("Error" , error )
except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )

try:
	station3 = absimple.Station("GPS 11", absimple.Sense.WEST, "xxx")	

except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )
