
#include <vector>
#include <stdio.h>
#include <string.h>
using namespace ::std;
#include <stdlib.h>  // pour atof
#include <math.h>

#include "CDate.h"
#include <abcommon.h>
using namespace ::abcommon;
#include <abmc.h>
using namespace ::abmc;

/* ********************************************************************** */
/* ********************************************************************** */
/* Builders */
/* ********************************************************************** */
/* ********************************************************************** */

CDate::CDate()
{
	m_errmsg = "";
   m_iso = "";
	m_ut1_utc = 0.;
   m_jd_utc = 0;
   m_jd_tt = 0;
}

CDate::CDate(const char * value)
{
	set(value);
}

CDate::CDate(int year, int month, double day)
{
	m_errmsg = "";
	m_ut1_utc = 0.;

	mc_date_jd(year,month,day,&this->m_jd_utc);
	// dt=TT-UT:
	double dt;
	mc_tdminusut(this->m_jd_utc,&dt);
	this->m_jd_tt = this->m_jd_utc+dt/86400.;
	// --- Update string formats
	update_string_formats(); 
}

CDate::CDate(int year, int month, int day, int hour, int min, double sec)
{
   set(year, month, day, hour, min, sec);
}

CDate::~CDate(void)
{
}

/* ********************************************************************** */
/* ********************************************************************** */
/* Accessors */
/* ********************************************************************** */
/* ********************************************************************** */

const char *CDate::get_errmsg() { 
	return m_errmsg.c_str(); 
}

void CDate::set_pole(double ut1_utc) {
	this->m_ut1_utc=ut1_utc; // sec
}

void CDate::get_pole(double *ut1_utc) {
	*ut1_utc=this->m_ut1_utc; // sec
}

const char* CDate::get_iso(Frame frame) { 
   if(m_iso.empty()) {
	   double jd = CDate::get_jd(frame);
	   char*  date = new char[25];
	   mc_jd2dateobs(jd, date);
      m_iso = date;
   }
	return m_iso.c_str();
}

char* CDate::get_equinox(Frame frame,int year_type,int nb_subdigit) { 
	double jd = CDate::get_jd(frame);
	//char date[25];
	//mc_jd_equinoxe2(jd,year_type,nb_subdigit,date);
	//std::string tmp = date;
	//return tmp.c_str();

   char*  date = new char[25];
   mc_jd2dateobs(jd, date);
   return date;
}

double CDate::get_jd(Frame frame) { 
	double jd;
	if (frame==	Frame::TR) {
		jd = this->m_jd_utc;
	} else {
		jd = (m_jd_tt+this->m_ut1_utc/86400.);
	}
	return jd;
}

void CDate::get_ymdhms(Frame frame,int *y,int *m,int *d,int *hh, int *mm, double *ss) { 
	double jd;
	if (frame==	Frame::TR) {
		jd = this->m_jd_utc;
	} else {
		jd = (m_jd_tt+this->m_ut1_utc/86400.);
	}
	double day,r;
	mc_jd_date(jd,y,m,&day);
	*d=(int)floor(day);
	r=(day-*d)*24.;
	*hh=(int)floor(r);
	r=(r-*hh)*60.;
	*mm=(int)floor(r);
	*ss=(r-*mm)*60.;
	return;
}


void CDate::set(const char * value)
{
	int year,month,day,hour=0,min=0;
	double sec=0.;
	m_errmsg = "";
	m_ut1_utc = 0.;
	this->m_jd_utc=0;

   vector<string> values = utils_split(value, ' ');
	int n = values.size();

	if (n==1) {
		std::string output;
		utils_strupr(utils_trim(values.at(0)),output);
		if (output.compare("NOW")==0) {
			getutc_ymdhhmmss(&year,&month,&day,&hour,&min,&sec);
			double dday = day + ( hour + ( min + sec/60.) /60.) /24.;
			mc_date_jd(year,month,dday,&this->m_jd_utc);
		} else if (output.compare("NOW0")==0) {
			getutc_ymdhhmmss(&year,&month,&day,&hour,&min,&sec);
			mc_date_jd(year,month,(double)day,&this->m_jd_utc);
		} else if (output.compare("NOW1")==0) {
			getutc_ymdhhmmss(&year,&month,&day,&hour,&min,&sec);
			mc_date_jd(year,month,(double)day+1,&this->m_jd_utc);
		} else {
			char car = output[0];
			if ((car=='J')||(car=='B')) {
				/* --- date du style J2000.0 ou B1950.0 ---*/
				mc_equinoxe_jd(output.c_str(),&this->m_jd_utc);
			} else {
				string v = utils_trim(values.at(0));
				if ((v.find("-")!=string::npos)||(v.find("T")!=string::npos)||(v.find("t")!=string::npos)||(v.find(":")!=string::npos)) {
					/* recherche une date au format Fits */
					mc_dateobs2jd(v.c_str(),&this->m_jd_utc);
				} else {
					/* La date est supposee en Jour Julien */
					this->m_jd_utc=atof(v.c_str());
					/* On corrige si on suppose que l'on a rentre un MJD */
					if (this->m_jd_utc<1e6) {this->m_jd_utc+=2400000.5;}
				}
			}
		}
	} else {
		string v = value;
		if ((n==2)&&((v.find("-")!=string::npos)||(v.find(":")!=string::npos))) {
			/* recherche une date au format MySQL */
			::std::string iso1 = utils_trim(values.at(0));
			::std::string iso2 = utils_trim(values.at(1));
			::std::string iso  = iso1 + "T" + iso2;
			mc_dateobs2jd(iso.c_str(),&this->m_jd_utc);
		} else {
			double d;
			utils_stod(utils_trim(values.at(0)), &d); year=(int)d;
			utils_stod(utils_trim(values.at(1)), &d); month=(int)d;
			utils_stod(utils_trim(values.at(2)), &d); day=(int)d;
			if (n>3) {
				utils_stod(utils_trim(values.at(3)), &d); hour=(int)d;
			}
			if (n>4) {
				utils_stod(utils_trim(values.at(4)), &d); min=(int)d;
			}
			if (n>5) {
				utils_stod(utils_trim(values.at(5)), &sec);
			}
			double dday = day + ( hour + ( min + sec/60.) /60.) /24.;
			mc_date_jd(year,month,dday,&this->m_jd_utc);
		}
	}
	// dt=TT-UT:
	double dt;
	mc_tdminusut(this->m_jd_utc,&dt);
	this->m_jd_tt = this->m_jd_utc+dt/86400.;
	// --- Update string formats
	update_string_formats(); 
}


/// 
void CDate::set(double jd) {

   this->m_jd_utc = jd; 

   // dt=TT-UT:
	double dt;
	mc_tdminusut(this->m_jd_utc,&dt);
	this->m_jd_tt = this->m_jd_utc+dt/86400.;
	// --- Update string formats
	update_string_formats(); 


}

void CDate::set(int year, int month, int day, int hour, int min, double sec) {
   m_errmsg = "";
   m_ut1_utc = 0.;

   double dday = day + (hour + (min + sec / 60.) / 60.) / 24.;
   mc_date_jd(year, month, dday, &this->m_jd_utc);
   // dt=TT-UT:
   double dt;
   mc_tdminusut(this->m_jd_utc, &dt);
   this->m_jd_tt = this->m_jd_utc + dt / 86400.;
   // --- Update string formats
   update_string_formats();

}

/* ********************************************************************** */
/* ********************************************************************** */
/* Privates */
/* ********************************************************************** */
/* ********************************************************************** */

void CDate::update_string_formats() { 
	// --- String formats
}
