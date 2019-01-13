# file: abmc_example.py

# load abmc astrobrick
import abmc

try:
	#-- je recupere une instance de mc
	home1 = abmc.Home()
	print ("home1.getMPC(TRF)=", home1.getMPC(abmc.Frame.TRF))
	
	home2 = abmc.Home("GPS 0.142300 E 42.936639 2890.5")
	print ("home2.getGPS(TRF)=", home2.getGPS(abmc.Frame.TRF))
	print ("home2.getGPS(CRF)=", home2.getGPS(abmc.Frame.CRF))
	print ("home2.getMPC(TRF)=", home2.getMPC(abmc.Frame.TRF))
	print ("home2.getMPC(CRF)=", home2.getMPC(abmc.Frame.CRF))
	print ("home2.getSense()=", home2.getSense() )
	

except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )
