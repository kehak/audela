#include "CAngle.h"

#include <vector>
#include <stdio.h>
#include <stdlib.h>  // pour atof
using namespace ::std;
#include <string.h>
#include <math.h>

#include <abcommon.h>
using namespace ::abcommon;


/* ********************************************************************** */
/* ********************************************************************** */
/* Builders */
/* ********************************************************************** */
/* ********************************************************************** */

///@brief construteur par defaut 
// intitialise un angle 0 degres
//
CAngle::CAngle() {
   reset();
}

CAngle::CAngle(const char * value)
{

   char chiffres[50],sec[50],car;

	std::string text0,text;
	text0.assign(value);
	utils_strupr(text0,text);
   int nt = text.size();
	double angles[4];
	for (int kt=0 ; kt<4 ; kt++) {
		angles[kt]=0.;
	}
   //int signe=1;
	int na=-1;
	int kk=0;
	int kh=0;
	int kr=0;
	int ks=1;
	int ke=0;
	for (int kt=0 ; kt<nt ; kt++) {
      car=text[kt];
      if (((car>='0')&&(car<='9'))||(car=='E')||(car=='.')||(car=='-')||(car=='+')) {
			// car is a number
			if (kk==0) { 
				na++;
			}
			if (car=='E') {
				ke=1;
			}
			if ((car=='-')&&(ke==0)&&(na==0)) {
				ks=-1;
			}
			if (kk<50) {
				chiffres[kk]=car;
				kk++;
	         chiffres[kk]='\0';
			}
			if (na<3) {
				angles[na]=abs((int) atof(chiffres));
			} else if (na==3) {
				sprintf(sec,"%.0f.%s",angles[na-1],chiffres);
				angles[na]=abs((int) atof(sec));
			}
		} else {
			kk=0;
			ke=0;
			if (car=='H') { 
				kh=1;
			} else if (car=='R') { 
				kr=1;
			}
		}
	}
	double angle=0;
	if (na>=0) {
		angle += angles[0];
	}
	if (na>=1) {
		angle += (angles[1]/60.);
	}
	if (na>=3) {
		angle += (angles[3]/3600.);
	} else if (na>=2) {
		angle += (angles[2]/3600.);
	}
	if (ks==-1) {
		angle *= -1.;
	}
	if (kh==1) {
		angle *= 15.;
	} else if (kr==1) {
		angle /= (DR);
	}
   initDegree(angle); 
}

CAngle::CAngle(double deg)
{
   setDegree(deg); 
}

CAngle::~CAngle(void)
{
}

void CAngle::setDegree(double deg ) {
   initDegree(deg);
}

void CAngle::set(IAngle& angle) {
   initDegree( angle.get_deg(360));
}

void CAngle::set(string &value) {
   init(value);
}

void CAngle::reset() {
   m_empty = true;
   m_deg = 0;
   m_value = "";
}

bool CAngle::isEmpty()
{
   return m_empty;
}


/// operateur de copie d'un angle
//CAngle& CAngle::operator=(CAngle angle)
//{
//  swap(angle);
//  return *this;
//}

//-----------------------------------------------------------------------------
// private methods
//-----------------------------------------------------------------------------

void CAngle::initDegree(double deg ) {
   m_deg=deg;
   m_value = "";
   m_empty = false;
}


void CAngle::init(string& value ) {

   char chiffres[50],sec[50],car;

	std::string text0,text;
	text0.assign(value);
	utils_strupr(text0,text);
   int nt = text.size();
	double angles[4];
	for (int kt=0 ; kt<4 ; kt++) {
		angles[kt]=0.;
	}
   //int signe=1;
	int na=-1;
	int kk=0;
	int kh=0;
	int kr=0;
	int ks=1;
	int ke=0;
	for (int kt=0 ; kt<nt ; kt++) {
      car=text[kt];
      if (((car>='0')&&(car<='9'))||(car=='E')||(car=='.')||(car=='-')||(car=='+')) {
			// car is a number
			if (kk==0) { 
				na++;
			}
			if (car=='E') {
				ke=1;
			}
			if ((car=='-')&&(ke==0)&&(na==0)) {
				ks=-1;
			}
			if (kk<50) {
				chiffres[kk]=car;
				kk++;
	         chiffres[kk]='\0';
			}
			if (na<3) {
				angles[na]=(int) abs((int)atof(chiffres));
			} else if (na==3) {
				sprintf(sec,"%.0f.%s",angles[na-1],chiffres);
				angles[na]=(int) abs((int)atof(sec));
			}
		} else {
			kk=0;
			ke=0;
			if (car=='H') { 
				kh=1;
			} else if (car=='R') { 
				kr=1;
			}
		}
	}
	double angle=0;
	if (na>=0) {
		angle += angles[0];
	}
	if (na>=1) {
		angle += (angles[1]/60.);
	}
	if (na>=3) {
		angle += (angles[3]/3600.);
	} else if (na>=2) {
		angle += (angles[2]/3600.);
	}
	if (ks==-1) {
		angle *= -1.;
	}
	if (kh==1) {
		angle *= 15.;
	} else if (kr==1) {
		angle /= (DR);
	}
   initDegree(angle); 

}


/* ********************************************************************** */
/* ********************************************************************** */
/* Accessors */
/* ********************************************************************** */
/* ********************************************************************** */


double CAngle::get_deg(double limit_deg = 360) {
	double deg = this->m_deg;
	if (limit_deg>=360) {
		deg = fmod(deg,limit_deg);
		deg = fmod(deg+limit_deg,limit_deg);
	} else if (limit_deg>0) {
		deg = fmod(deg,limit_deg);
	}
	return deg;
}

double CAngle::get_rad(double limit_rad) { 
	double rad = this->m_deg*(DR);
	if (limit_rad>=2*(PI)) {
		rad = fmod(rad,limit_rad);
		rad = fmod(rad+limit_rad,limit_rad);
	} else if (limit_rad>0) {
		rad = fmod(rad,limit_rad);
	}
	return rad;
}

void CAngle::get_s_d_m_s(double limit_deg,int *sign,int *deg,int *min,double *sec) {
	std::string value = CAngle::mc_deg2sexadecimal("D +.9");
   vector<string> argvv = utils_split(value,' ');
   int argcc = argvv.size();
   if (argcc >= 3 ) {
		std::string argvv0 = argvv[0];
		char car = argvv0[0];
		if (car=='-') {
			*sign=-1;
		} else {
			*sign=1;
		}
		*deg = (int)fabs(1.*atoi(argvv0.c_str()));
		*min = atoi(argvv[1].c_str());
		*sec = atof(argvv[2].c_str());
	}
	return;
}

char* CAngle::get_sdd_mm_ss(double limit_deg) {
	std::string tmp = CAngle::mc_deg2sexadecimal("D +.9");
   char * sexadecimal = new char[tmp.size()+1];
   strcpy(sexadecimal, tmp.c_str());
	return sexadecimal;
}

///@brief retourne la valeur d'un angle en chaine de caractere
//
// Exemple : 
//    get_sexagesimal("H 03.2") =>  02H35m11.23 
//
// @param format uspzad
//   - u (unit) = h,H,d,D (default=D)
//   - s (separator) = " ",:,"" (default="")
//   - p (plus/moins) = +,"" (default="")
//   - z (zeros) = 0,"" (default="")
//   - a (angle_digits) = 0,2,3 (default=3 if unit D,H)
//   - d (sec_digits) = "",".1",".2",... (default="")
//
std::string CAngle::getSexagesimal(std::string format) {
	return CAngle::mc_deg2sexadecimal(format);
}

/* ********************************************************************** */
/* ********************************************************************** */
/* Privates */
/* ********************************************************************** */
/* ********************************************************************** */

void CAngle::mc_deg2d_m_s(double valeur,char *charsigne,int *d,int *m,double *s)
/***************************************************************************/
/* Calcul la valeur d.ms a partir de la valeur decimale.                   */
/***************************************************************************/
{
   double y,dd,mm,sss;
   y=valeur;
   if (y<0) {strcpy(charsigne,"-");} else {strcpy(charsigne,"+");}
   y=fabs(y);
   dd=floor(y);
   y=(y-dd)*60.;
   mm=floor(y);
   y=(y-mm)*60.;
   sss=y;
   *d=(int)(dd);
   *m=(int)(mm);
   *s=sss;
   return;
}

void CAngle::mc_deg2h_m_s(double valeur,char *charsigne,int *h,int *m,double *s)
/***************************************************************************/
/* Calcul la valeur h.ms a partir de la valeur decimale.                   */
/***************************************************************************/
{
   double y,dd,mm,sss;
   y=valeur/15.;
   if (y<0) {strcpy(charsigne,"-");} else {strcpy(charsigne,"+");}
   y=fabs(y);
   dd=floor(y);
   y=(y-dd)*60.;
   mm=floor(y);
   y=(y-mm)*60.;
   sss=y;
   *h=(int)(dd);
   *m=(int)(mm);
   *s=sss;
   return;
}

double CAngle::mc_frac(double x)
/***************************************************************************/
/* Calcul de la partie fractionnaire d'un nombre decimal.                  */
/***************************************************************************/
{
   return(x-floor(x));
}

/*
Format = uspzad
u (unit) = h,H,d,D (default=D)
s (separator) = " ",:,"" (default="")
p (plus/moins) = +,"" (default="")
z (zeros) = 0,"" (default="")
a (angle_digits) = 1,2,3 (default=3 if unit D,H)
d (sec_digits) = "",".1",".2",... (default="")
*/
std::string CAngle::mc_deg2sexadecimal(std::string format) {
   int klen=format.size();
	char car;
	// === leading format (units)
	int unit=0; // 0=deg 1=hours
	int separator=0; // 0=hdms 1=space 2=:
	int modulo=0; // 0=360 1=180
	int sign=0; // 0=[0:modulo] 1=[-modulo/2:modulo/2]
	int k,kk=0;
   for (k=0;k<klen;k++) {
      car=format[k];
      if (car=='D') { unit=0; modulo=0; }
      if (car=='d') { unit=0; modulo=1; }
      if (car=='H') { unit=1; modulo=0; }
      if (car=='h') { unit=1; modulo=1; }
      if (car==' ') { separator=1; }
      if (car=='_') { separator=1; }
		if (car==':') { separator=2; }
		if (car=='+') { sign=1; }
		if (((car>='0')&&(car<='9'))||(car=='.')) {
			kk=k;
			break;
		}
	}
	// === trailing format (digits)
	int zeros=1; // 0=leading zeros 1=spaces
	int nb_angular_digits=3; //
	if ( modulo==1 ) {
		nb_angular_digits=2;
	}
   for (k=kk;k<klen;k++) {
		kk=klen;
      car=format[k];
      if (car=='.') { 
			kk=k+1;
			break;
		}
      if (car=='0') { zeros=0; }
		if ((car>'0')&&(car<='9')) {
			nb_angular_digits=int(car)-48;
		}
	}
	int nb_decimal_digits=0;
   for (k=kk;k<klen;k++) {
      car=format[k];
		if ((car>='0')&&(car<='9')) {
			nb_decimal_digits=int(car)-48;
			break;
		}
	}
	// === compute the modulo
	double deg = fmod(this->m_deg,360); // -360:360
	if (modulo==0) {
		deg = fmod(deg+720,360); // 0:360
	} else {
		if (nb_angular_digits==3) {
			deg = fmod(deg+720,360); // 0:360
			if (deg>180) {
				deg-=360; // -180:180
			}
		} else {
			// -90:90
			if (deg>90) {
				deg=90;
			} else if (deg<-90) {
				deg=-90;
			}
		}
	}
	// === prepare the fields
	char charsigne[5];
	int sexa_angle,sexa_min;
	double sexa_sec;
	if (unit==0) {
		this->mc_deg2d_m_s(deg,charsigne,&sexa_angle,&sexa_min,&sexa_sec);
	} else {
		this->mc_deg2h_m_s(deg,charsigne,&sexa_angle,&sexa_min,&sexa_sec);
	}
   // round the result according the subdigits 
	int mult = (int)pow(10.,nb_decimal_digits);
	double frac = sexa_sec*mult-floor(sexa_sec*mult);
	if (frac>=0.5) {
		sexa_sec = floor(sexa_sec*mult+1)/mult;
		if (sexa_sec >= 60 ) {
			sexa_sec -= 60;
			sexa_min += 1; 
			if (sexa_min >= 60 ) {
				sexa_min -= 60;
				sexa_angle += 1;
			}
		}
	} else {
		sexa_sec = floor(sexa_sec*mult)/mult;
	}
	int sexa_sec_intg = (int)sexa_sec;
	int sexa_sec_frac = (int)((sexa_sec-sexa_sec_intg)*mult);
	// === build the string
	char text[20];
   
   m_value = "";
	// --- sign
	if (sign==1) {
		m_value += charsigne;
	} else if ( strcmp(charsigne,"-")==0 ) {
		m_value += charsigne;
	}
	// --- deg/hour
	if (zeros==1) {
		if (separator==1) {
			if (nb_angular_digits<2) {
				sprintf(text,"%d",sexa_angle);
			} else if (nb_angular_digits==2) {
				sprintf(text,"%2d",sexa_angle);
			} else {
				sprintf(text,"%3d",sexa_angle);
			}
		} else {
			sprintf(text,"%d",sexa_angle);
		}
	} else {
		if (nb_angular_digits<2) {
			sprintf(text,"%d",sexa_angle);
		} else if (nb_angular_digits==2) {
			sprintf(text,"%02d",sexa_angle);
		} else {
			sprintf(text,"%03d",sexa_angle);
		}
	}
	m_value += text;
	// --- symbol
	if (separator==0) { 
		if (unit==0) {
			m_value += "d";
		} else {
			m_value += "h";
		}
	} 
	else if (separator==1) { m_value += " "; }
	else if (separator==2) { m_value += ":"; }
	// --- min
	if (zeros==1) {
		if (separator==1) {
			sprintf(text,"%2d",sexa_min);
		} else {
			sprintf(text,"%d",sexa_min);
		}
	} else {
		sprintf(text,"%02d",sexa_min);
	}
	m_value += text;
	// --- symbol
	if (separator==0) { 
		m_value += "m";
	} 
	else if (separator==1) { m_value += " "; }
	else if (separator==2) { m_value += ":"; }
	// --- sec_int
	if (zeros==1) {
		if (separator==1) {
			sprintf(text,"%2d",sexa_sec_intg);
		} else {
			sprintf(text,"%d",sexa_sec_intg);
		}
	} else {
		sprintf(text,"%02d",sexa_sec_intg);
	}
	m_value += text;
	char format_sec[10];
	if (nb_decimal_digits>0) {
		strcpy(text,".");
		sprintf(format_sec,"%%0%dd",nb_decimal_digits);
		sprintf(text,format_sec,sexa_sec_frac);
		m_value += ".";
		m_value += text;
	}
	// --- symbol
	if (separator==0) { 
		m_value += "s";
	} 
	return m_value;
}
