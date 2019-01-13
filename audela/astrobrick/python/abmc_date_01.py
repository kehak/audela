# file: abmc_date.py

# load abmc astrobrick
import abmc

try:
	#-- je recupere une instance de mc
	home1 = abmc.Date("NOW")
	print ("home1 = abmc.Date(NOW)" )
	print ("home1.get_iso(TRF)=", home1.get_iso(abmc.Frame.TRF))
	print ("home1.get_jd(TRF)=", home1.get_jd(abmc.Frame.TRF))
	
except abmc.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )
