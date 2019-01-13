//Cabsimple.cpp


#include <string>
#include <absimple.h>  // pour #include IPlanetOrbite
#include <abcommon.h>
using namespace ::abcommon;
#include "planet.h"


double getPlanetMass(const char * planetName ) {
   double mass; 

   if ( planetName == NULL) {
      throw CError(CError::ErrorInput, "planetName is NULL");
   }

   if( strcmp(planetName, "Mercury")==0 ) {
      mass = 0.06;
   } else if( strcmp(planetName, "Venus")==0 ) {
      mass = 0.949;
   } else if( strcmp(planetName, "Earth")==0 ) {
      mass = 1;
   } else {
      throw CError(CError::ErrorInput, "unknown planet %s", planetName);
   }
   return mass;
}

CStringArray* getPlanetNameList() {
   
   CStringArray*  planetNames = new CStringArray(); 
   planetNames->append("Mercury");
   planetNames->append("Venus");
   planetNames->append("Earth");

   return planetNames;
}


CDataArray<double>* getPlanetMassList() {
   
   CDataArray<double>*  massList = new CDataArray<double>(); 
   massList->append(0.06);
   massList->append( 0.949);
   massList->append( 1 );

   return massList;
}


CIntArray* getSatelliteNbList() {
   
   CIntArray*  satelliteNb = new CIntArray(); 
   satelliteNb->append( 0 );
   satelliteNb->append( 0 );
   satelliteNb->append( 1 );

   return satelliteNb;
}


CStructArray<absimple::SOrbit*>* getOrbitList() {
   
   CStructArray<absimple::SOrbit*>*  Orbits = new CStructArray<absimple::SOrbit*>(); 
   absimple::SOrbit* mercure = new absimple::SOrbit() ; 
   mercure->a = 0.387;
   mercure->e = 0.206;
   mercure->i = 3.38; 
   Orbits->append( mercure );

   absimple::SOrbit* venus = new absimple::SOrbit() ; 
   venus->a = 0.723;
   venus->e = 0.007;
   venus->i = 3.86; 
   Orbits->append( venus );

   return Orbits;
}










