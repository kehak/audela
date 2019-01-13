# file: abmc_example.py

# load abmc astrobrick
import abmc

#-- je recupere une instance de mc
mc1 = abmc.Mc()	

angle = "11"
result = mc1.angle2deg(angle)
print ("abmc.angle2deg :",angle,"=",result)

# example #1
# call standalone function s
date = "2015 01 03"
result = mc1.date2jd(date)
print ("abmc.date2jd :",date,"=",result)

date = result
result = mc1.date2jd(date)
print ("abmc.date2jd :",date,"=",result)

angle = "-0h04m02.05s"
format = "h:1.2"
result = mc1.angle2sexagesimal(angle,format)
print ("abmc.angle2sexagesimal :",angle,"/",format,"=",result)

angle = -0.075
format = "D 2.2"
result = mc1.angle2sexagesimal(angle,format)
print ("abmc.angle2sexagesimal :",angle,"/",format,"=",result)

result = mc1.angle2deg("-00:04:30")
print(result)


print("----------------------------------")
print(abmc.help(""))
print("----------------------------------")
print(abmc.help("*"))
print("----------------------------------")
print(abmc.help("Angle"))
print("----------------------------------")
#print(amc.help("angle2sexagesimal"))

"""
result = abmc.test_struct()
print ("abmc.test_struct =",result)
print ("abmc.test_struct chaine=",result.chaine.decode('utf8'))
print ("abmc.test_struct numero=",result.numero)

result = abmc.test_struct_pointer2()
print ("abmc.test_struct_pointer2 =",result)
print ("abmc.test_struct_pointer2 chaine=",result.chaine.decode('utf8'))
print ("abmc.test_struct_pointer2 numero=",result.numero)

result = abmc.test_struct_tableau()
n=len(result);
for i in range(0,n) :
	res = result[i]
	print ("abmc.test_struct_tebleau =",res)
	print ("abmc.test_struct_tebleau chaine=",res.chaine.decode('utf8'))
	print ("abmc.test_struct_tebleau numero=",res.numero)

"""