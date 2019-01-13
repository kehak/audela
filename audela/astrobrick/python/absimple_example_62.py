
# load absimple astrobrick
import absimple


#--- return list 
try:
	producer = absimple.Producer()	
	print ("Producer.acq"  )
	producer.acq( 3000 ); 
	print ("Producer.acq started"  )
	
	print ("Producer waitMessage=", producer.waitMessage() ) 
	print ("Producer waitMessage=", producer.waitMessage() ) 
	print ("Producer waitMessage=", producer.waitMessage() ) 
	
	
	del producer
	
except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )


