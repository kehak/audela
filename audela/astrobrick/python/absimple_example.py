# file: audela.py

# load absimple astrobrick
import absimple

# example #1
# call standalone function s
a = 8
b = 4
result = absimple.processAdd(a,b)
print ("absimple.processAdd : %d + %d = %d" % (a,b,result))


result2 = absimple.processSub(a,b)
print ("absimple.processAdd : %d - %d = %d" % (a,b,result2))

# example #2
# call ICalculator methods
calculator = absimple.ICalculator()
current = calculator.set(a)
print ("calculator.set : %d " % (current))
current = calculator.add(b)
print ("calculator.add : %d = %d" % (b,current))
current = calculator.divide(b)
print ("calculator.divide : %d = %d" % (b,current))

#try :
#	b = 0
#	current = calculator.divide(b)
#	print ("calculator.divide :",  b , " = ", current)
#except IndexError: 
#	print ('calculator.divide codeError=', error.code, " message=", error.message)
#
#
#del calculator

# example #3
# call ICalendar methods
calendar = absimple.ICalendar()
result3 = calendar.convertIntToString(2015, 2, 1, 14, 5, 10);
print ("calendar.convertIntToString : " , result3)

result4 = calendar.convertIntToStruct(2015, 2, 1, 14, 5, 10);
print ("calendar.convertIntToStruct : %s %s %s %s %s %s " % 
	(result4.year, result4.month, result4.day, result4.hour, result4.minute, result4.second))
	
result5 = calendar.convertStringToStruct("2015-02-01T14:05:10");
print ("calendar.convertStringToStruct : %s %s %s %s %s %s " % 
	(result5.year, result5.month, result5.day, result5.hour, result5.minute, result5.second))	

try :
	result6 = calendar.convertStringToStruct("");
	print ("calendar.convertStringToStruct : %s %s %s %s %s %s " % 
	(result6.year, result6.month, result6.day, result6.hour, result6.minute, result6.second))
except absimple.IError: 
	print ('convertStringToStruct codeError=', error.code, " message=", error.message)
		
result7 = calendar.convertStringToStruct("2015-02-01T14:05:10");
print ("calendar.convertStringToStruct : %s %s %s %s %s %s " % 
	(result7.year, result7.month, result7.day, result7.hour, result7.minute, result7.second))	

del calendar








