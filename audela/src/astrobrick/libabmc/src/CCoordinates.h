#pragma once

#include <abmc.h>
using namespace abmc;
#include "mc.h"
#include "CAngle.h"
#include "CMc.h"


// CCoordinates inherits from ICoordinates (classe of abstracted interface)

class CCoordinates : public abmc::ICoordinates
{

public:

	// Builders
   CCoordinates(CMc &mc);
   CCoordinates(CMc &mc, CAngle& value1,CAngle& value2, abmc::Equinox equinox);
   CCoordinates(CMc &mc, CCoordinates& coords );
   CCoordinates(CMc &mc, const char * value, abmc::Equinox equinox);
   ~CCoordinates(void);

	// Accessors (output angles in degrees)
	// Think to copy them as virtuals in abmc.h
   IAngle&      getAngle1()  ;
   IAngle&      getAngle2() ;
   double       getRa(Equinox equinox);
   double       getDec(Equinox equinox);
   void         setRaDec(double ra, double dec, Equinox equinox);

private:

	// Methods
   void hip2tel();
   void tel2hip();

	// Menbers
   CMc& m_mc;
	CAngle m_angle1C;
	CAngle m_angle2C;
   CAngle m_angle1O;
   CAngle m_angle2O;

};

