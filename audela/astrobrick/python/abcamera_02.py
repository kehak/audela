# file: audela.py

# load abaudela astrobrick
import abaudela
from time import sleep

import getopt

#  
#def cameraCallback( clientData, code, value1, value2, message ):
#	print( "acqCallback", clientData, code, value1, value2, message )
#	return

def cameraCallback( clientData, code, value1, value2 , message):
	##value2=ctypes.c_double()
	print( "acqCallback", clientData, code, value1, value2, message )
	return 0


params = ['-log_level', '4', '-log_file', 'libabtestcam.log']


print(params)
print(params[0])
#print (getopt.getopt(['-a', '-bval', '-c', 'val'], 'ab:c:') )

try:
	cam1 = abaudela.Camera(".", "simulator", params)
	
	print("camName=",cam1.getCameraName() )
	cam1.setExptime( 3.5 )
	
	print("exptime=",cam1.getExptime() )
	
	cam1.setCallback(cameraCallback)
	
	cam1.acq()
	
	sleep(5) 
	del cam1
	

except abaudela.Error as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )
	



