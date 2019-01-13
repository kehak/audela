#include "CHome.h"

#include <vector>
#include <stdio.h>
#include <string.h>
using namespace ::std;
#include <stdlib.h>  // pour atof
#include <math.h>

#include <abcommon.h>
using namespace ::abcommon;
#include <abmc.h>
using namespace ::abmc;

/* ********************************************************************** */
/* ********************************************************************** */
/* Builders */
/* ********************************************************************** */
/* ********************************************************************** */

CHome::CHome() : m_sense_trf(Sense::EAST) , m_sense_crf(Sense::EAST)
{
	errmsg = "";
	iaucodeobs = "";
	iaunameobs = ""; 
	xp = 0.;
	yp = 0.;
	ed50_wgs84 = 0;

}

CHome::CHome(const char * value) :m_sense_trf(Sense::EAST) , m_sense_crf(Sense::EAST)
{
	errmsg = "";
	iaucodeobs = "";
	iaunameobs = ""; 
	xp = 0.;
	yp = 0.;
	ed50_wgs84 = 0;
   vector<string> values = utils_split(value, ' ');

	::std::string format = utils_trim(values.at(0));
	format = format.substr(0,3);

	if (utils_caseInsensitiveStringCompare(format,"GPS")==true) {
		// --- Decode GPS format
		if ( values.size() < 5 ) {
			errmsg = "Not enough elements.";
			return;
		}
	   utils_stod(utils_trim(values.at(1)), &this->m_longitude_trf);
		::std::string sense = utils_trim(values.at(2));
      m_sense_trf = toupper(sense[0]) == 'E' ? Sense::EAST : Sense::WEST;  
	   utils_stod(utils_trim(values.at(3)), &this->m_latitude_trf);
	   utils_stod(utils_trim(values.at(4)), &this->m_altitude_trf);
		this->m_longitude_trf*=(DR);
		this->m_latitude_trf*=(DR);
		// --- Encode MPC format
		update_gps2mpc(&m_longitude_trf, &m_sense_trf,&m_latitude_trf,&m_altitude_trf,&m_longmpc_trf,&m_rhosinphip_trf,&m_rhocosphip_trf);
	} else {
		// --- Decode MPC format
		if ( values.size() < 4 ) {
			errmsg = "Not enough elements.";
			return;
		}
	   utils_stod(utils_trim(values.at(1)), &m_longmpc_trf);
	   utils_stod(utils_trim(values.at(2)), &m_rhocosphip_trf);
	   utils_stod(utils_trim(values.at(3)), &m_rhosinphip_trf);
		// --- Encode GPS format
		update_mpc2gps(&m_longmpc_trf,&m_rhosinphip_trf,&m_rhocosphip_trf,&m_longitude_trf, &m_sense_trf,&m_latitude_trf,&m_altitude_trf);
	}
	// --- update CRF
	update_trf2crf();
	// --- Update string formats
	update_string_formats(); 
}


CHome::CHome(const char *obscode, const char *obscode_file) :m_sense_trf(Sense::EAST) , m_sense_crf(Sense::EAST)
{
	int errno;
	errmsg = "";
	iaucodeobs = "";
	iaunameobs = ""; 
	xp = 0.;
	yp = 0.;
	ed50_wgs84 = 0;

	errno = readfile_obscode_mpc(obscode_file,obscode);
	if (errno==0) {
		// --- Encode GPS format
		update_mpc2gps(&this->m_longmpc_trf,&this->m_rhosinphip_trf,&this->m_rhocosphip_trf,&m_longitude_trf,&m_sense_trf,&m_latitude_trf,&m_altitude_trf);
		// --- update CRF
		update_trf2crf();
		// --- Update string formats
		update_string_formats(); 
	}
}


CHome::CHome(double longmpc_trf, double rhocosphip_trf, double rhosinphip_trf) :m_sense_trf(Sense::EAST) , m_sense_crf(Sense::EAST)
{
	errmsg = "";
	iaucodeobs = "";
	iaunameobs = ""; 
	xp = 0.;
	yp = 0.;
	ed50_wgs84 = 0;

	// --- Decode MPC format
	this->m_longmpc_trf = fmod(longmpc_trf*(DR)+4*(PI),2*(PI));
	this->m_rhocosphip_trf = rhocosphip_trf;
	this->m_rhosinphip_trf = rhosinphip_trf;
	// --- Encode GPS format
	update_mpc2gps(&this->m_longmpc_trf,&this->m_rhosinphip_trf,&this->m_rhocosphip_trf,&this->m_longitude_trf,&this->m_sense_trf,&this->m_latitude_trf,&this->m_altitude_trf);
	// --- update CRF
	update_trf2crf();
	// --- Update string formats
	update_string_formats(); 
}

CHome::CHome(double longitude_trf, Sense sense_trf, double latitude_trf, double altitude_trf) : m_sense_trf(Sense::EAST) , m_sense_crf(Sense::EAST)
{
	set(longitude_trf, sense_trf, latitude_trf, altitude_trf);
}

CHome::~CHome(void)
{
}

void CHome::set(double longitude_trf, Sense sense_trf, double latitude_trf, double altitude_trf)
{
	errmsg = "";
	iaucodeobs = "";
	iaunameobs = ""; 
	xp = 0.;
	yp = 0.;
	ed50_wgs84 = 0;

	// --- Decode GPS format
	this->m_sense_trf = sense_trf;
	double l = fmod(longitude_trf+720,360);
	if (l>180) {
		l = 360 - l;
      this->m_sense_trf = (this->m_sense_trf==Sense::EAST) ? Sense::WEST : Sense::EAST;
	}
	this->m_longitude_trf = l;
	this->m_latitude_trf = latitude_trf;
	this->m_altitude_trf = altitude_trf;
	this->m_longitude_trf*=(DR);
	this->m_latitude_trf*=(DR);
	// --- Encode MPC format
	update_gps2mpc(&this->m_longitude_trf,&this->m_sense_trf,&this->m_latitude_trf,&this->m_altitude_trf,&this->m_longmpc_trf,&this->m_rhosinphip_trf,&this->m_rhocosphip_trf);
	// --- update CRF
	update_trf2crf();
	// --- Update string formats
	update_string_formats(); 
}





/* ********************************************************************** */
/* ********************************************************************** */
/* Accessors */
/* ********************************************************************** */
/* ********************************************************************** */

const char *CHome::get_errmsg() { 
	return errmsg.c_str(); 
}

void CHome::set_pole(double xp_arcsec, double yp_arcsec) {
	this->xp=xp_arcsec*(DR)/3600.; // arcsec -> radian
	this->yp=yp_arcsec*(DR)/3600.; // arcsec -> radian
	update_trf2crf();
}

void CHome::get_pole(double *xp_arcsec, double *yp_arcsec) {
	*xp_arcsec=this->xp/(DR)*3600.; // radian -> arcsec
	*yp_arcsec=this->yp/(DR)*3600.; // radian -> arcsec
}

const char *CHome::get_GPS(Frame frame) { 
   if (frame==Frame::TR) {
		return m_homeGPS_trf.c_str(); 
	} else {
		return m_homeGPS_crf.c_str(); 
	}
}

const char *CHome::get_MPC(Frame frame) { 
	if (frame==Frame::TR) {
		return m_homeMPC_trf.c_str();
	} else {
		return m_homeMPC_crf.c_str();
	}
}

double CHome::get_longitude(Frame frame) { 
	if (frame==Frame::TR) {
		return m_longitude_trf/(DR); 
	} else {
		return m_longitude_crf/(DR); 
	}
}

Sense CHome::get_sense(Frame frame) { 
	if (frame==Frame::TR) {
		return m_sense_trf; 
	} else {
		return m_sense_crf; 
	}
}

double CHome::get_latitude(Frame frame) { 
	if (frame==Frame::TR) {
		return m_latitude_trf/(DR); 
	} else {
		return m_latitude_crf/(DR); 
	}
}

double CHome::get_altitude(Frame frame) { 
	if (frame==Frame::TR) {
		return m_altitude_trf; 
	} else {
		return m_altitude_crf; 
	}
}

double CHome::get_longmpc(Frame frame) { 
	if (frame==Frame::TR) {
		return m_longmpc_trf/(DR); 
	} else {
		return m_longmpc_crf/(DR); 
	}
}

double CHome::get_rhocosphip(Frame frame) { 
	if (frame==Frame::TR) {
		return m_rhocosphip_trf; 
	} else {
		return m_rhocosphip_crf; 
	}
}

double CHome::get_rhosinphip(Frame frame) { 
	if (frame==Frame::TR) {
		return m_rhosinphip_trf; 
	} else {
		return m_rhosinphip_crf; 
	}
}

void CHome::convert_geosys(const char * geosysin,const char * geosysout,int compute_h) {
	update_geosys(geosysin,geosysout,compute_h);
}

/* ********************************************************************** */
/* ********************************************************************** */
/* Privates */
/* ********************************************************************** */
/* ********************************************************************** */

void CHome::update_string_formats() { 
	// --- String formats
   m_homeGPS_trf = "GPS " + utils_d2st(m_longitude_trf/(DR)) + " " + (m_sense_trf==Sense::EAST ? "E" : "W") + " " + utils_d2st(m_latitude_trf/(DR)) + " " + utils_d2st(m_altitude_trf);
	m_homeMPC_trf = "MPC " + utils_d2st(m_longmpc_trf/(DR))   + " " + utils_d2st(m_rhocosphip_trf) + " " + utils_d2st(m_rhosinphip_trf);
	m_homeGPS_crf = "GPS " + utils_d2st(m_longitude_crf/(DR)) + " " + (m_sense_crf==Sense::EAST ? "E" : "W") + " " + utils_d2st(m_latitude_crf/(DR)) + " " + utils_d2st(m_altitude_crf);
	m_homeMPC_crf = "MPC " + utils_d2st(m_longmpc_crf/(DR))   + " " + utils_d2st(m_rhocosphip_crf) + " " + utils_d2st(m_rhosinphip_crf);   
}

void CHome::update_gps2mpc(double *longitude, Sense *sense, double *latitude, double *altitude,double *longmpc, double *rhosinphip,double *rhocosphip) {
	double l = fmod(*longitude+4*(PI),2*(PI));
	if (l>(PI)) {
		l = 2*(PI) - l;
      *sense = (*sense==Sense::EAST) ? Sense::WEST : Sense::EAST;
	}
	*longitude = l;
   *longmpc = (*sense==Sense::EAST) ? l : 2*(PI)-l ;
	latalt2rhophi(*latitude,*altitude,rhosinphip,rhocosphip);
}

void CHome::update_mpc2gps(double *longmpc, double *rhosinphip,double *rhocosphip,double *longitude, Sense *sense, double *latitude, double *altitude) {
	double l;
	l = fmod(*longmpc+4*(PI),2*(PI));
	*longmpc = l;
	if (l>(PI)) {
		l=2*(PI)-l;
		*sense = Sense::WEST;
	} else {
		*sense = Sense::EAST;
	}
	*longitude = l;
	rhophi2latalt(*rhosinphip,*rhocosphip,latitude,altitude);
}

void CHome::latalt2rhophi(double latitude,double altitude,double *rhosinphip,double *rhocosphip)
/***************************************************************************/
/* Retourne les valeurs de rhocosphi' et rhosinphi' (en rayons equatorial  */
/* terrestres) a partir de la latitude et de l'altitude.                   */
/***************************************************************************/
/* Latitude in radians.                                            */
/* Altitude en metres.                                                     */
/* Algo : Meeus "Astronomical Algorithms" p78                              */
/***************************************************************************/
{
   double aa,ff,bb,a,b,u,lat,alt;
   lat=latitude;
   alt=altitude;
   aa=EARTH_SEMI_MAJOR_RADIUS;
	ff=1./EARTH_INVERSE_FLATTENING;
   bb=aa*(1-ff);
   u=atan(bb/aa*tan(lat));
   a=bb/aa*sin(u)+alt/aa*sin(lat);
   b=      cos(u)+alt/aa*cos(lat);
   *rhocosphip=b;
   *rhosinphip=a;
}

void CHome::rhophi2latalt(double rhosinphip,double rhocosphip,double *latitude,double *altitude)
/***************************************************************************/
/* Retourne les valeurs de la latitude et de l'altitude a partir de        */
/* rhocosphi' et rhosinphi' (en rayons equatorial terrestres)              */
/***************************************************************************/
/* Latitude in radians.                                            */
/* Altitude in metres.                                                     */
/* Algo : Meeus "Astronomical Algorithms" p78                              */
/***************************************************************************/
{
   double aa,ff,bb,lat,alt,phip,rho,phi0,u0,rhosinphip0,rhocosphip0,rho0;
   double sinu0,cosu0,sinphi0,cosphi0;
   aa=EARTH_SEMI_MAJOR_RADIUS;
	ff=1./EARTH_INVERSE_FLATTENING;
   bb=aa*(1-ff);
   rho=sqrt(rhosinphip*rhosinphip+rhocosphip*rhocosphip);
   if (rho==0.) {
      *latitude=0.;
      *altitude=-aa;
      return;
   }
   phip=atan2(rhosinphip,rhocosphip);
   phi0=atan(aa*aa/bb/bb*tan(phip)); /* alt=0 */
   u0=atan(bb/aa*tan(phi0));
   sinu0=sin(u0);
   cosu0=cos(u0);
   sinphi0=sin(phi0);
   cosphi0=cos(phi0);
   for (alt=-1000;alt<20000.;alt+=0.1) {
      rhosinphip0 = bb/aa*sinu0 + alt/aa*sinphi0 ;
      rhocosphip0 =       cosu0 + alt/aa*cosphi0 ;
      rho0=sqrt(rhosinphip0*rhosinphip0+rhocosphip0*rhocosphip0);
      if ((rho-rho0)<0) {
         break;
      }
   }
   lat=phi0;
   alt-=0.1;
   *latitude=lat;
   *altitude=alt;
}

void CHome::update_trf2crf() {
	double cl,sl,cp,sp,cu,su,cv,sv,longi;
   longi=(this->m_sense_trf==Sense::EAST)?this->m_longitude_trf:-this->m_longitude_trf;
	cl=cos(longi);
	sl=sin(longi);
	cp=cos(this->m_latitude_trf);
	sp=sin(this->m_latitude_trf);
	cu=cos(xp);
	su=sin(xp);
	cv=cos(yp);
	sv=sin(yp);
	this->m_latitude_crf=asin(cl*cp*su-sl*cp*cu*sv+cu*cv*sp);
	longi=atan2(sl*cp*cv+sv*sp , cl*cp*cu+sl*cp*su*sv-su*cv*sp);
   this->m_sense_crf=(longi>=0)?Sense::EAST:Sense::WEST;
   this->m_longitude_crf=fabs(longi);
	this->m_altitude_crf=m_altitude_trf;
	update_gps2mpc(&this->m_longitude_crf,&this->m_sense_crf,&this->m_latitude_crf,&this->m_altitude_crf,&this->m_longmpc_crf,&this->m_rhosinphip_crf,&this->m_rhocosphip_crf);

}

int CHome::readfile_obscode_mpc(const char *obscode_file, const char *obscode)
/***************************************************************************/
/* Return MPC coordinates from the obscode MPC file                        */
/***************************************************************************/
/***************************************************************************/
{
   FILE *fichier_obscode;
   char ligne[120],texte[120];
   int check_obscode,col1,col2,errno,n;
	std::string stext1,stext2;
	
   if (( fichier_obscode=fopen(obscode_file,"r") ) == NULL) {
		stext1 = obscode_file ;
		errmsg = "File " + stext1 + " not found";
		errno = 1;
		return errno;
   } else {
      check_obscode=0;
		stext2 = obscode;
      do {
         if (fgets(ligne,120,fichier_obscode)!=NULL) {
            col1=1;col2=3;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
				stext1 = texte;
				utils_strupr(stext1,stext1);
				if (stext1.compare(stext2)==0) {
					this->iaucodeobs = stext1;
					col1=5;col2=12;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
					this->m_longmpc_trf = atof(texte)*(DR);
					col1=14;col2=20;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
					this->m_rhocosphip_trf=atof(texte);
					col1=22;col2=29;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
					this->m_rhosinphip_trf=atof(texte);
					n = strlen(ligne);
					col1=31;col2=n;strncpy(texte,ligne+col1-1,col2-col1+1);*(texte+col2-col1+1)='\0';
					this->iaunameobs = texte;
			      check_obscode=1;
					break;
				}
			}
      } while (feof(fichier_obscode)==0);
      fclose(fichier_obscode);
		if (check_obscode==0) {
			stext1 = obscode_file ;
			errmsg = "File " + stext1 + " not found";
			errno = 1;
			return errno;
		}
   }
	return 0;
}

/****************************************************************************/
/* Convertit des coordonnées Home en divers repères géodésiques             */
/****************************************************************************/
/* geosysin = ED50 or WGS84 */
/* geosysout = WGS84 or ED50 */
/* compute_h = 1 to take account for altitude */
/****************************************************************************/
void CHome::update_geosys(const char * geosysin,const char * geosysout, int compute_h) {
   double longi;
   int in=0,out=0,sens=1;
   double a_wgs84,f_wgs84,a_ed50,f_ed50,a1,f1,a2,f2,a,f,ee,b;
   double dX,dY,dZ,X1,Y1,Z1,X2,Y2,Z2;
   double sinphi,cosphi,sinlon,coslon,h,W,N,phi0,phi2,delta;

   /* - */
   a_wgs84=6378137.0;
   f_wgs84=1./298.257223563;
   a_ed50=6378388.0;
   f_ed50=1./297.;
   /* - */
   in=0;
   a1=a_wgs84;
   f1=f_wgs84;
   if (strcmp(geosysin,"ED50")==0) {
		if (ed50_wgs84==1) {
			return;
		}
      in=1;
      a1=a_ed50;
      f1=f_ed50;
	} else {
		// in is WGS84
	}
   out=0;
   a2=a_wgs84;
   f2=f_wgs84;
   if (strcmp(geosysout,"ED50")==0) {
		if (ed50_wgs84==1) {
			return;
		}
      out=1;
      a2=a_ed50;
      f2=f_ed50;
	} else {
		if (ed50_wgs84==0) {
			return;
		}
		// out is WGS84
	}
	ed50_wgs84++;
   /* - */
   if (in==out) {
      // On ne touche a rien !!
      return;
   }
   dX=0.;
   dY=0.;
   dZ=0.;
   if ((in==1)&&(out==0)) {
      dX=-84.;
      dY=-97.;
      dZ=-117.;
   }
   if ((in==0)&&(out==1)) {
      dX=84.;
      dY=97.;
      dZ=117.;
   }
   /* - spheric to cartesian - */
   a=a1;
   f=f1;
   b=a*(1-f);
   ee=(a*a-b*b)/(a*a);
   sens=(this->m_sense_trf==Sense::EAST)?1:-1;
   sinphi=sin(this->m_latitude_trf);
   cosphi=cos(this->m_latitude_trf);
   coslon=cos(this->m_longitude_trf*sens);
   sinlon=sin(this->m_longitude_trf*sens);
   h=this->m_altitude_trf;
   W=sqrt(1-ee*sinphi*sinphi);
   N=a/W;
   X1=(N+h)*cosphi*coslon;
   Y1=(N+h)*cosphi*sinlon;
   Z1=(N*(1-ee)+h)*sinphi;
   /* - translation - */
   X2=X1+dX;
   Y2=Y1+dY;
   Z2=Z1+dZ;
   /* - spheric to cartesian - */
   a=a2;
   f=f2;
   b=a*(1-f);
   ee=(a*a-b*b)/(a*a);
   longi=2*atan2(Y2,X2+sqrt(X2*X2+Y2*Y2));
   phi0=atan2(Z2,sqrt(X2*X2+Y2*Y2)*(1-a*ee/sqrt(X2*X2+Y2*Y2+Z2*Z2)));
   do {
      cosphi=cos(phi0);
      sinphi=sin(phi0);
      phi2=atan((Z2/sqrt(X2*X2+Y2*Y2))/(1-a*ee*cosphi/(sqrt(X2*X2+Y2*Y2)*sqrt(1-ee*sinphi*sinphi))));
      delta=fabs(phi2-phi0)/(DR)*3600.;
      phi0=phi2;
   } while (delta>0.1);
   cosphi=cos(phi2);
   sinphi=sin(phi2);
   h=sqrt(X2*X2+Y2*Y2)/cosphi-a/sqrt(1-ee*sinphi*sinphi);
   /* - */
   this->m_latitude_trf=phi2;
   this->m_sense_trf=(longi>=0)?Sense::EAST:Sense::WEST;
   this->m_longitude_trf=fabs(longi);
   this->m_altitude_trf=h;
	//
	// --- Encode MPC format
	update_gps2mpc(&this->m_longitude_trf,&this->m_sense_crf,&this->m_latitude_trf,&this->m_altitude_trf,&m_longmpc_trf,&m_rhosinphip_trf,&m_rhocosphip_trf);
	// --- update CRF
	update_trf2crf();
	// --- Update string formats
	update_string_formats();
}
