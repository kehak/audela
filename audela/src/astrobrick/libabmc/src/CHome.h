#pragma once

#include <abmc.h>
using namespace abmc;
#include "mc.h"

// References for TRF and CRF
// http://www.iers.org/IERS/EN/Publications/Bulletins/bulletins.html (bulletins A)
// Terrestrial Reference Frame (TRF)
//	Celestial Reference Frame (CRF)
//
// References for obscodes
// http://www.minorplanetcenter.net/iau/lists/ObsCodesF.html
//
// CHome inherits from IHome (classe of abstracted interface)

class CHome : public abmc::IHome
{

public:

	// Builders are in TRF
   CHome();
   CHome(const char *value);
	CHome(const char *obscode, const char *obscode_file);
   CHome(double longmpc, double rhocosphip, double rhosinphip);
   CHome(double longitude, Sense sense, double latitude, double altitude);
   ~CHome(void);

	// Error message
	const char *get_errmsg();

	// Accessors (output angles in degrees)
   const char *get_GPS(Frame frame);
   const char *get_MPC(Frame frame);
	//
   double get_longitude(Frame frame);
   Sense  get_sense(Frame frame);
   double get_latitude(Frame frame);
   double get_altitude(Frame frame);
	//
	double get_longmpc(Frame frame);
	double get_rhocosphip(Frame frame); 
	double get_rhosinphip(Frame frame); 
	//
	void set_pole(double xp_arcsec, double yp_arcsec); // update automatically the CRF
	void get_pole(double *xp_arcsec, double *yp_arcsec);
	//
	void convert_geosys(const char *geosysin,const char *geosysout,int compute_h);
   
   void set(double longitude, Sense sense, double latitude, double altitude);

private:

	// Functions
	void latalt2rhophi(double latitude,double altitude,double *rhosinphip,double *rhocosphip);
	void rhophi2latalt(double rhosinphip,double rhocosphip,double *latitude,double *altitude);
   void update_gps2mpc(double *longitude, Sense *sense, double *latitude, double *altitude,double *longmpc, double *rhosinphip,double *rhocosphip);
   void update_mpc2gps(double *longmpc, double *rhosinphip,double *rhocosphip,double *longitude, Sense *sense, double *latitude, double *altitude);
	void update_string_formats();
	void update_trf2crf();
	int  readfile_obscode_mpc(const char *obscode_file,const char *obscode);
	void update_geosys(const char *geosysin,const char *geosysout,int compute_h);

	// Variables
   std::string errmsg;
   int ed50_wgs84; // =1 if the transform from ED50 to WGS84 is done once (it is forbiden to do than more).
	// -------------------------
	// --- GPS definition 
	// Format: GPS abslongitude sense latitude altitude
	// -------------------------
	// abslongitude sense =  180 W   90 W  0 E|W  90 E  180 E
	// longitude          = -180    -90    0      90    180
	// -------------------------
   double m_longitude_trf; // radian
	Sense  m_sense_trf; // one char
   double m_latitude_trf; // radian
   double m_altitude_trf; // m
	std::string m_homeGPS_trf;
	// -------------------------
   double m_longitude_crf; // radian
	Sense m_sense_crf; // one char
   double m_latitude_crf; // radian
   double m_altitude_crf; // m
	std::string m_homeGPS_crf;
	// -------------------------
	// --- MPC definition 
	// Format: MPC mpclongitude rhocosphip rhosinphip
	// -------------------------
	// longitude          = -180   -90    0       90     180
	// longmpc            =  180   270    0       90     180
	// -------------------------
	double m_longmpc_trf; // radian
	double m_rhocosphip_trf; // earth equatorial radius
	double m_rhosinphip_trf; // earth equatorial radius
	std::string m_homeMPC_trf;
	// -------------------------
	double m_longmpc_crf; // radian
	double m_rhocosphip_crf; // earth equatorial radius
	double m_rhosinphip_crf; // earth equatorial radius
	std::string m_homeMPC_crf;
	// -------------------------
	std::string iaucodeobs; // IAU observatory code (three chars)
	std::string iaunameobs; // IAU observatory name (chars)
	// -------------------------
	// CIO-BIH
	double xp; // radian
	double yp; // radian

};

