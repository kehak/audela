#include <vector>
using namespace ::std;
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <abcommon.h>
using namespace ::abcommon;
#include <abmc.h>
using namespace ::abmc;

#include <sofa.h>
#include "CAngle.h"
#include "CCoordinates.h"
#include "CMc.h"


CCoordinates::CCoordinates(CMc &mc) : m_mc(mc)
{
   // rien a faire , les angles sont crees par defaut a vide
}


// @bief contructor from two angles
CCoordinates::CCoordinates(CMc &mc, CAngle& angle1, CAngle& angle2, abmc::Equinox equinox) : m_mc(mc)
{
   if (equinox == Equinox::NOW ) {
      m_angle1C.reset();
      m_angle2C.reset();
      m_angle1O.set(angle1);
      m_angle2O.set(angle2);
   } else {
      m_angle1C.set(angle1);
      m_angle2C.set(angle2);
      m_angle1O.reset();
      m_angle2O.reset();
   }
}

// @brief contructor from another CCoordinates
CCoordinates::CCoordinates(CMc &mc, CCoordinates& coords) : m_mc(mc)
{   
   m_angle1C.set( coords.getAngle1() );
   m_angle2C.set( coords.getAngle2() );
}


//CCoordinates::CCoordinates(const char * value1,const char * value2)
//{
//	std::string text0,text;
//	text0.assign(value1);
//	utils_strupr(text0,text);
//	std::size_t found1 = text.find(" ");
//	std::size_t found2 = text.find(":");
//	if ((found1!=std::string::npos)||(found2!=std::string::npos)) {
//		text += "H";
//	}
//	m_angle1.set( text );
//   string text2(value2);
//	m_angle2.set( text2 );
//}

// @brief contructor from text value
CCoordinates::CCoordinates(CMc &mc, const char * value, abmc::Equinox equinox): m_mc(mc)
{

   vector<string> values = utils_split(value, ' ');
	int n = values.size();
	std::string value1="";
	std::string value2="";
	std::string text="";
	if (n==1) {
		value1 += "0";
		value2 += "0";
		text = value1;
	} else {
		if (n%2==1) {
			n--; // n must be always even
		}
		int nn = n/2;
		int k;
		for (k=0;k<nn;k++) {
			value1 += values[k];
			//value1 += " ";
		}
		for (k=nn;k<n;k++) {
			value2 += values[k];
			//value2 += " ";
		}
		std::string text0;
		text0.assign(value1);
		utils_strupr(text0,text);
		std::size_t found1 = text.find(" ");
		std::size_t found2 = text.find(":");
		if ((found1!=std::string::npos)||(found2!=std::string::npos)) {
			text += "H";
		}
	}
   if (equinox == Equinox::NOW) {
      m_angle1C.reset();
      m_angle2C.reset();
      m_angle1O.set(text);
      m_angle2O.set(value2);
   } else {
      m_angle1C.set(text);
      m_angle2C.set(value2);
      m_angle1O.reset();
      m_angle2O.reset();
   }
}

CCoordinates::~CCoordinates(void)
{
}



// Accessors

IAngle& CCoordinates::getAngle1()  {
   return m_angle1C;
}

IAngle& CCoordinates::getAngle2()  {
   return m_angle2C;
}

double CCoordinates::getRa(Equinox equinox) {
   if (equinox == Equinox::NOW) {
      if (m_angle1O.isEmpty() ) {
         hip2tel();

      }
      return  m_angle1O.get_deg(360);
   } else {
      if (m_angle1C.isEmpty()) {
         tel2hip();
      }
      return  m_angle1C.get_deg(360);
   }
}


double CCoordinates::getDec(Equinox equinox) {
   if (equinox == Equinox::NOW) {
      if (m_angle2O.isEmpty()) {
         hip2tel();
      }
      return  m_angle2O.get_deg(90);
   } else {
      if (m_angle2C.isEmpty()) {
         tel2hip();
      }
      return  m_angle2C.get_deg(360);
   }
}

void CCoordinates::setRaDec(double ra, double dec, Equinox equinox ) {
   if (equinox == Equinox::NOW) {
      m_angle1C.reset();
      m_angle2C.reset();
      m_angle1O.setDegree(ra);
      m_angle2O.setDegree(dec);
   } else {
      m_angle1C.setDegree(ra);
      m_angle2C.setDegree(dec);
      m_angle1O.reset();
      m_angle2O.reset();
   }

}

void CCoordinates::hip2tel() {
   
   // Site longitude, latitude (radians) and height above the geoid (m).
   double elong, phi, hm;
   elong = m_mc.getHome().get_longitude(Frame::TR);
   phi = m_mc.getHome().get_latitude(Frame::TR);
   hm = m_mc.getHome().get_altitude(Frame::TR);

   // Ambient pressure (HPa), temperature (C) and rel. humidity (frac). 
   double phpa, tc, rh;
   phpa = 952.0;
   tc = 18.5;
   rh = 0.83;

   // Effective color (microns). 
   double wl;
   wl = 0.55;

   // UTC date
   double utc1, utc2, tai1, tai2, tt1, tt2;
   //IDate &date, IHome &home,
   int year, month, day, hour, minute;
   double second;

   m_mc.getDate().get_ymdhms(Frame::TR, &year, &month, &day, &hour, &minute, &second);
   int iauResult = iauDtf2d("UTC", year, month, day, hour, minute, second, &utc1, &utc2);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauDtf2d error = %d", iauResult);
   }

   // TT date.
   iauResult = iauUtctai(utc1, utc2, &tai1, &tai2);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauUtctai error = %d", iauResult);
   }
   iauResult = iauTaitt(tai1, tai2, &tt1, &tt2);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauTaitt error = %d", iauResult);
   }

   // EOPs: polar motion in radians, UT1-UTC in seconds. 
   double xp, yp, dut1, dx, dy;
   xp = 50.995e-3 * DAS2R;
   yp = 376.723e-3 * DAS2R;
   dut1 = 155.0675e-3;
   // Corrections to IAU 2000A CIP (radians).
   dx = 0.269e-3 * DAS2R;
   dy = -0.274e-3 * DAS2R;

   // Star ICRS RA,Dec (radians)
   double rc = m_angle1C.get_rad(2. * PI);
   double dc = m_angle2C.get_rad(PISUR2);

   // Proper motion: RA/Dec derivatives, epoch J2000.0. 
   double pr, pd;
   //pr = atan2(-354.45e-3 * DAS2R, cos(dc));
   //pd = 595.35e-3 * DAS2R;
   pr = 0;
   pd = 0;


   // Parallax (arcsec) and recession speed (km/s).
   double px, rv;
   px = 164.99e-3;
   rv = 0.0;

   // ICRS to observed.
   double aob, zob, hob, dob, rob, eo;
   iauResult = iauAtco13(rc, dc, pr, pd, px, rv, utc1, utc2, dut1,
      elong, phi, hm, xp, yp, phpa, tc, rh, wl,
      &aob, &zob, &hob, &dob, &rob, &eo);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauAtco13 error=%d", iauResult);
   }

   m_angle1O.setDegree(rob* 180. / PI);
   m_angle2O.setDegree(dob* 180. / PI);

}


void CCoordinates::tel2hip() {

   // Site longitude, latitude (radians) and height above the geoid (m).
   double elong, phi, hm;
   elong = m_mc.getHome().get_longitude(Frame::TR);
   phi = m_mc.getHome().get_latitude(Frame::TR);
   hm = m_mc.getHome().get_altitude(Frame::TR);

   // Ambient pressure (HPa), temperature (C) and rel. humidity (frac). 
   double phpa, tc, rh;
   phpa = 952.0;
   tc = 18.5;
   rh = 0.83;

   // Effective color (microns). 
   double wl;
   wl = 0.55;

   // UTC date
   double utc1, utc2, tai1, tai2, tt1, tt2;
   //IDate &date, IHome &home,
   int year, month, day, hour, minute;
   double second;

   m_mc.getDate().get_ymdhms(Frame::TR, &year, &month, &day, &hour, &minute, &second);
   int iauResult = iauDtf2d("UTC", year, month, day, hour, minute, second, &utc1, &utc2);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauDtf2d error = %d", iauResult);
   }

   // TT date.
   iauResult = iauUtctai(utc1, utc2, &tai1, &tai2);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauUtctai error = %d", iauResult);
   }
   iauResult = iauTaitt(tai1, tai2, &tt1, &tt2);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauTaitt error = %d", iauResult);
   }

   // EOPs: polar motion in radians, UT1-UTC in seconds. 
   double xp, yp, dut1, dx, dy;
   xp = 50.995e-3 * DAS2R;
   yp = 376.723e-3 * DAS2R;
   dut1 = 155.0675e-3;
   // Corrections to IAU 2000A CIP (radians).
   dx = 0.269e-3 * DAS2R;
   dy = -0.274e-3 * DAS2R;

   // Star ICRS RA,Dec (radians)
   double rob = m_angle1O.get_rad(2. * PI);
   double dob = m_angle2O.get_rad(PISUR2);

   // Proper motion: RA/Dec derivatives, epoch J2000.0. 
   double pr, pd;
   //pr = atan2(-354.45e-3 * DAS2R, cos(dc));
   //pd = 595.35e-3 * DAS2R;
   pr = 0;
   pd = 0;


   // Parallax (arcsec) and recession speed (km/s).
   double px, rv;
   px = 164.99e-3;
   rv = 0.0;

   // ICRS to observed.
   double rc, dc;
   iauResult = iauAtoc13("R", rob, dob, utc1, utc2, dut1,
      elong, phi, hm, xp, yp, phpa, tc, rh, wl,
      &rc, &dc);
   if (iauResult) {
      throw CError(CError::ErrorGeneric, "iauAtco13 error=%d", iauResult);
   }

   m_angle1C.setDegree(rc* 180. / PI);
   m_angle2C.setDegree(dc* 180. / PI);

}



