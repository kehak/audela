#pragma once

#include "abmc.h"
#include "mc.h"


// CAngle inherits from IAngle (classe of abstracted interface)

class CAngle : public abmc::IAngle
{

public:

	// Builders are in UTC
   CAngle();
   CAngle(const char *value);
	CAngle(double deg);
   ~CAngle(void);


	// Accessors (output angles in degrees)
	// Think to copy them as virtuals in abmc.h
   double get_deg(double limit_deg);
   double get_rad(double limit_rad);
	void get_s_d_m_s(double limit_deg,int *sign,int *deg,int *min,double *sec);
	char* get_sdd_mm_ss(double limit_deg);
   std::string getSexagesimal(std::string format);

   void setDegree(double deg);
   void set(std::string &value);
   void set(IAngle& angle);
   void reset();
   bool isEmpty();
   //CAngle& operator=(CAngle angle);

private:
   void initDegree(double deg);
   void init(std::string& value );

	// Methods
	std::string mc_deg2sexadecimal(std::string format);

	void mc_deg2d_m_s(double valeur,char *charsigne,int *d,int *m,double *s);
	void mc_deg2h_m_s(double valeur,char *charsigne,int *h,int *m,double *s);
	double mc_frac(double x);

	// Attributs
	double m_deg;
   ::std::string m_value;
   bool m_empty;

};

