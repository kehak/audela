// CMc.cpp
// 
//
#include <cmath>
#include <abcommon.h>
using namespace abcommon;

#include <sofa.h>

#include "CMc.h"
#include "mc.h"
#include "CAngle.h"
#include "CCoordinates.h"
#include "CDate.h"
#include "CHome.h"

///
// contructeur
// intialise les attributs privés (s'il en a)
CMc::CMc() {
   m_fixedDate = false;
}

///
// destructor
// desallour les attributs privés contruit dynamiquement avec new() ou malloc()  (s'il en a)
CMc::~CMc() {

}


//=============================================================================
// Coordinates methods
//=============================================================================

///////////////////////////////////////////////////////////////////////////////
// ICoordinates C++  methods
///////////////////////////////////////////////////////////////////////////////
IHome* CMc::createHome() {
   return new CHome();
}

ICoordinates* CMc::createCoordinates() {
   return new CCoordinates(*this);
}

ICoordinates* CMc::createCoordinates_from_string(const char *angles, abmc::Equinox equinox) {
   return new CCoordinates(*this, angles, equinox);
}

ICoordinates* CMc::createCoordinates_from_coord(ICoordinates& coords) {
   return new CCoordinates(*this, (CCoordinates&)coords);
}

void CMc::setHome(IHome &home) {
   m_home.set(home.get_longitude(Frame::TR), home.get_sense(Frame::TR), home.get_latitude(Frame::TR), home.get_altitude(Frame::TR));
}

IHome& CMc::getHome() {
   return m_home;
}







//=============================================================================
// angle methods
//=============================================================================


//=============================================================================
// angle methods
//=============================================================================

int CMc::angle2deg(const char *string_angle,double *deg)
{
	//abmc::IAngle* Iangle = abmc::IAngle_createInstance_from_string(string_angle);
	//*deg = abmc::IAngle_get_deg(Iangle,0);
	//abmc::IAngle_deleteInstance(Iangle);
   
   CAngle angle(string_angle);
   *deg = angle.get_deg(0);
   return ABMC_OK;
}

int CMc::angle2rad(const char *string_angle,double *rad)
{
   CAngle angle(string_angle);
   *rad = angle.get_rad(0);
   return ABMC_OK;
}

int CMc::angles_computation(const char *string_angle1,const char *string_operande,const char *string_angle2,double *deg)
{
	CAngle angle1(string_angle1);
	CAngle angle2(string_angle2);
	char car = string_operande[0];
	if (car=='-') {
		*deg = angle1.get_deg(0) - angle2.get_deg(0);
	} else if (car=='+') {
		*deg = angle2.get_deg(0) + angle2.get_deg(0);
	} else if (car=='*') {
		*deg = angle1.get_deg(0) * angle2.get_deg(0);
	} else if (car=='/') {
		if (angle2.get_deg(0)!=0) {
			*deg = angle1.get_deg(0) / angle2.get_deg(0);
		} else {
			*deg = angle1.get_deg(0);
		}
	} else if (car=='%') {
		*deg = fmod ( angle1.get_deg(0) , angle2.get_deg(0) );
	}
   return ABMC_OK;
}

int CMc::angle2sexagesimal(double deg,const char *string_format,char *string_sexa)
{
	CAngle angle(deg);
	std::string sexa = angle.getSexagesimal(string_format);
	strcpy(string_sexa,sexa.c_str());
   return ABMC_OK;
}

int CMc::coordinates_separation(const char *coord1_angle1,const char *coord1_angle2,const char *coord2_angle1,const char *coord2_angle2,double *angle_distance,double *angle_position)
{
   CAngle  angle1a1(coord1_angle1);
   CAngle  angle1a2(coord1_angle2);
   CAngle  angle2a1(coord2_angle1);
   CAngle  angle2a2(coord2_angle2);

  
	double c1a1,c1a2,c2a1,c2a2;
   c1a1 =angle1a1.get_deg(360);
   c1a2 =angle1a2.get_deg(360);
	c2a1 =angle2a1.get_deg(360);
   c2a2 =angle2a2.get_deg(360);
	mc_sepangle(c1a1*(DR),c2a1*(DR),c1a2*(DR),c2a2*(DR),angle_distance,angle_position);
	*angle_distance /= (DR);
	*angle_position /= (DR);
   return ABMC_OK;
}

//=============================================================================
// date methods
//=============================================================================
void CMc::setFixedDate(IDate &date) {
   m_date.set(date.get_jd(Frame::TR) );
   m_fixedDate = true;
}
void CMc::unsetFixedDate() {
   m_fixedDate = false;
}

IDate& CMc::getDate() {

   int y, m, d, h, mn;
   double s; 
   if (m_fixedDate == false) {
      ::abcommon::getutc_ymdhhmmss(&y, &m, &d, &h, &mn, &s);
      m_date.set(y, m, d, h, mn, s);
   }
   return m_date;
}

int CMc::date2jd(const char *string_date,double *jd)
{
	CDate date(string_date);
	*jd = date.get_jd(Frame::TR);
   return ABMC_OK;
}

int CMc::date2iso8601(const char *string_date,char *date_iso8601)
{
	CDate date(string_date);
	strcpy(date_iso8601,date.get_iso(Frame::TR));
   return ABMC_OK;
}
   
int CMc::date2ymdhms(const char *string_date,int *year,int *month,int *day,int *hour,int *minute,double *seconds)
{
	CDate date(string_date);
	date.get_ymdhms(Frame::TR,year,month,day,hour,minute,seconds);
   return ABMC_OK;
}

int CMc::date2tt(const char *string_date,double *jd_tt)
{
   CDate date(string_date);
	*jd_tt = date.get_jd(Frame::CR);
   return ABMC_OK;
}

int CMc::date2equinox(const char *string_date,int year_type,int nb_subdigit, char *date_equ)
{
	CDate date(string_date);
	strcpy(date_equ,date.get_equinox(Frame::TR,year_type,nb_subdigit));
   return ABMC_OK;
}

int CMc::date2lst(const char *string_date_utc, double ut1_utc, const char *string_home, double xp_arcsec, double yp_arcsec, double *lst)
{
	CDate date(string_date_utc);
   CHome home(string_home);
   //
	date.set_pole(ut1_utc);
	Frame frame = Frame::TR;
	double jd = date.get_jd(frame);
	jd+=ut1_utc;
	//
	home.set_pole(xp_arcsec,yp_arcsec);
	frame = Frame::CR;
	double longi = home.get_longmpc(frame);
	double rhocosphip = home.get_rhocosphip(frame);
	double rhosinphip = home.get_rhosinphip(frame);
   // --- Compute Local Sideral Time 
   mc_tsl(jd,-longi*(DR),lst);
	*lst/=(DR);
   return ABMC_OK;
}

/*
int CMc::dates_ut2bary(const char *string_date_utc,, const char *string_coord, const char *string_date_equinox, const char *string_home, double **jd_bary)
{
	abmc::IDate* Idate = abmc::IDate_createInstance_from_string(string_date_utc);
	abmc::ICoordinates* Icoordinates1 = new CCoordinates(string_coord);
	abmc::IDate* Idate = abmc::IDate_createInstance_from_string(string_date_equinox);
	abmc::IHome* Ihome = abmc::IHome_createInstance_from_string(string_home);
	// --- decode Date equinox
	double ut1_utc=0;
	abmc::IDate_set_pole(Idate,ut1_utc);
	Frame frame = Frame::TR;
	double ut = abmc::IDate_get_jd(Idate,frame);
	ut+=ut1_utc;
	// --- decode Home
	double xp_arcsec=0,yp_arcsec=0;
	abmc::IHome_set_pole(Ihome,xp_arcsec,yp_arcsec);
	frame = Frame::CR;
	double longi = abmc::IHome_get_longmpc(Ihome,frame);
	double rhocosphip = abmc::IHome_get_rhocosphip(Ihome,frame);
	double rhosinphip = abmc::IHome_get_rhosinphip(Ihome,frame);
	// --- decode Coord
	double asd,dec;
	Icoordinates1.get_deg(&asd,&dec);
	ut=jds[k];
	// --- convertir en TT ---
	mc_tu2td(ut,&jj);
	// --- correction de la precession equinox -> a la date ---
	mc_precad(equinox,asd,dec,jj,&asd2,&dec2);
	// --- correction de la nutation ---
	mc_nutradec(jj,asd2,dec2,&asd2,&dec2,1);
	// --- calcul --- 
	mc_baryvel(jj,longi,rhocosphip,rhosinphip,asd2,dec2,&x_helio,&y_helio,&z_helio,&vx_helio,&vy_helio,&vz_helio,&v_helio,&hjd,&x_bary,&y_bary,&z_bary,&vx_bary,&vy_bary,&vz_bary,&v_bary,&bjd);
	xx=cos(asd2)*cos(dec2);
	yy=sin(asd2)*cos(dec2);
	zz=sin(dec2);
	d=x_bary*xx+y_bary*yy+z_bary*zz;
	djd=d*UA/CLIGHT/86400.;
	sprintf(s,"%.10f ",bjd);
   // --- Compute Local Sideral Time 
   mc_tsl(jd,-longi*(DR),lst);
	*lst/=(DR);
   return ABMC_OK;
}
*/




