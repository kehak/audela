#pragma once

#include "abmc.h"
#include "mc.h"

// References for TRF and CRF
// http://www.iers.org/IERS/EN/Publications/Bulletins/bulletins.html (bulletins A)
// UT1-UTC
// TAI-UTC(MJD 57290) = 36.0        

// CDate inherits from IDate (classe of abstracted interface)

class CDate : public abmc::IDate
{

public:

	// Builders are in UTC
   CDate();
   CDate(const char *value);
	CDate(int year, int month, double day);
   CDate(int year, int month, int day, int hour, int min, double sec);
   ~CDate(void);

	// Error message
	const char *get_errmsg();

	// Accessors
   const char*  get_iso(abmc::Frame frame);
   double   get_jd(abmc::Frame frame);
	void     get_ymdhms(abmc::Frame frame,int *y,int *m,int *d,int *hh, int *mm, double *ss); 
   char*    get_equinox(abmc::Frame frame,int year_type,int nb_subdigit);

   void set(const char * value);
   void set(double jd);
   void set(int year, int month, int day, int hour, int min, double sec);
	//
	void set_pole(double ut1_utc); // update automatically the CRF
	void get_pole(double *ut1_utc);
	
private:
   // Functions
	void update_string_formats();
	//void CDate::update_trf2crf();

	// Variables
   std::string m_errmsg;
   std::string m_iso; 
	// -------------------------
	double m_jd_utc;
	double m_jd_tt;
	// -------------------------
	// CIO-BIH
	double m_ut1_utc; // second

};
