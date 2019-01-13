
# load absimple astrobrick
import absimple


#--- return list 
try:
	producer = absimple.WorkItemProducer()	
	print ("MessageProducer start" ,  producer  )
	producer.run( 3 ); 
	
	print ("MessageProducer  end" ) 
	del producer
	
except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )


