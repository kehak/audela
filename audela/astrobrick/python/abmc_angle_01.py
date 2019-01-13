# file: abmc_example.py

# load abmc astrobrick
import abmc

#-- je recupere une instance de mc
angle1 = abmc.Angle("11")

print ("angle1.get_deg :",angle1.get_deg(0))

print ("angle1.get_sdd_mm_ss :",angle1.getSDMS(0))

print ("angle1.get_deg :", abmc.Angle("21").get_deg(360))

print ("angle1.getSDMS :",angle1.getSDMS(360))

coord1 = abmc.Coordinates("11d12m 12d10m")
print ("coord1.getAngle1 :", coord1.getAngle1().get_deg(360) )
angle3 = coord1.getAngle1()

print ("angle3.get_deg :",angle3.get_deg(0))
print ("angle3.get_rad :",angle3.get_rad(0))
print ("angle3.get_sdd_mm_ss :",angle3.getSDMS(0))


