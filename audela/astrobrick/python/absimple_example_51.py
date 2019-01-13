# file: absimple_example_51.py

# load absimple astrobrick
import absimple

#--- sample  with exception handle
# the first two planets exist and their names are printed
# but the third planet does not exist and an exception is raised 
try :
	planetName = "Mercury"
	mass = absimple.getPlanetMass(planetName)	
	print ("absimple.getPlanetMass(%s) : %f" % ( planetName , mass ) ) 
	
	planetName = "Venus"
	mass = absimple.getPlanetMass(planetName)	
	print ("absimple.getPlanetMass(%s) : %f" % ( planetName , mass ) ) 
	
	#--- unknown planet => exception !!
	planetName = "Altair"
	mass = absimple.getPlanetMass(planetName)	
	print ("absimple.getPlanetMass(%s) : %f" % ( planetName , mass ) ) 
	
except absimple.IError as error: 
	print ("Error[%d] %s" % (error.code, error.message ) )
	
