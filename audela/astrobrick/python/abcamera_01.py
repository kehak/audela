# file: abcamera_01.py

# load abaudela astrobrick
import abaudela

import getopt


params = ['-log_level', '4', '-log_file', 'libabtestcam.log']


print(params)
print(params[0])
#print (getopt.getopt(['-a', '-bval', '-c', 'val'], 'ab:c:') )

try:
	cam1 = abaudela.Camera(".", "simulator", params)
	
	print("camName=",cam1.getCameraName() )
	
	del cam1

except abaudela.Error as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )
	
