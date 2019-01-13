
# load absimple astrobrick
import absimple


#--- return list 
try:
	planetList = absimple.getPlanetNameList()	
	print ("absimple.getPlanetNameList", planetList ) 
	
	orbitList = absimple.getOrbitList()	
	for i in range(0, len(orbitList) ) :
		print ( "orbit ",  i, "a=", orbitList[i].a, "e=", orbitList[i].e, "i=", orbitList[i].i)
	
except absimple.IError as error:
	print ("Error[%d] %s" % (error.code, error.message ) )


