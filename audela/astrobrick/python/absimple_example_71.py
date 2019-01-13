
# load absimple astrobrick
import absimple


#--- return list 
try:
	producer1 = absimple.Producer()	
	producer2 = absimple.Producer()	
	producer3 = absimple.Producer()	
	producerList = absimple.Producer_getItemNoList()
	print ("MessageProducer_getItemNoList",  producerList )
	del producer2
	producerList = absimple.Producer_getItemNoList()
	print ("MessageProducer_getItemNoList",  producerList )
	
	
except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )


