// abmc.cpp 
//

#include <string.h>  // pour strcpy
#include <math.h>

#include "abmc.h"	// pour les declarations de l'interface
#include "CHome.h"
#include "CDate.h"
#include "CAngle.h"
#include "CCoordinates.h"
#include "mc.h"		// pour les declarations internes mc_...
#include "CStruct_mastruct.h"
#include <abcommon.h>
using namespace ::abcommon;

///////////////////////////////////////////////////////////////////////////////
// IHome factory 
///////////////////////////////////////////////////////////////////////////////
abmc::IHome* abmc::IHome_createInstance() {
    return new CHome();
}

abmc::IHome* abmc::IHome_createInstance_from_string(const char * home) {
    return new CHome(home);
}

abmc::IHome* abmc::IHome_createInstance_from_obscode(const char *obscode, const char *obscode_file) {
    return new CHome(obscode,obscode_file);
}

abmc::IHome* abmc::IHome_createInstance_from_MPC(double longimpc, double rhocosphip, double rhosinphip) {
    return new CHome(longimpc,rhocosphip,rhosinphip);
}

abmc::IHome* abmc::IHome_createInstance_from_GPS(double longitude, abmc::Sense sense, double latitude, double altitude) {
   return new CHome(longitude,sense,latitude,altitude);
}

void abmc::IHome_deleteInstance(IHome* home) {
	delete home;
}

const char* abmc::IHome_get_GPS(abmc::IHome *home, Frame frame) {
    return home->get_GPS(frame);
}

const char* abmc::IHome_get_MPC(abmc::IHome *home, Frame frame) {
    return home->get_MPC(frame);
}

double abmc::IHome_get_longitude(abmc::IHome *home,Frame frame) {
    return home->get_longitude(frame);
}

const abmc::Sense::Values  abmc::IHome_get_sense(abmc::IHome *home,Frame frame) {
   return home->get_sense(frame);
}

double abmc::IHome_get_latitude(abmc::IHome *home,Frame frame) {
    return home->get_latitude(frame);
}

double abmc::IHome_get_altitude(abmc::IHome *home,Frame frame) {
    return home->get_altitude(frame);
}

double abmc::IHome_get_longmpc(abmc::IHome *home,Frame frame) {
    return home->get_longmpc(frame);
}

double abmc::IHome_get_rhocosphip(abmc::IHome *home,Frame frame) {
    return home->get_rhocosphip(frame);
}

double abmc::IHome_get_rhosinphip(abmc::IHome *home,Frame frame) {
    return home->get_rhosinphip(frame);
}

void abmc::IHome_set_pole(abmc::IHome *home, double xp_arcsec, double yp_arcsec) {
    return home->set_pole(xp_arcsec,yp_arcsec);
}

void abmc::IHome_get_pole(abmc::IHome *home,double *xp_arcsec, double *yp_arcsec) {
    return home->get_pole(xp_arcsec,yp_arcsec);
}

void abmc::IHome_convert_geosys(abmc::IHome *home,const char *geosysin,const char *geosysout,int compute_h) {
    return home->convert_geosys(geosysin,geosysout,compute_h);
}



///////////////////////////////////////////////////////////////////////////////
// IDate factory 
///////////////////////////////////////////////////////////////////////////////
abmc::IDate* abmc::IDate_createInstance() {
    CATCH_ERROR( new CDate() ,  NULL)
}
abmc::IDate* abmc::IDate_createInstance_from_string(const char * date) {
    return new CDate(date);
}

abmc::IDate* abmc::IDate_createInstance_from_ymd(int year, int month, double day) {
    return new CDate(year,month,day);
}

abmc::IDate* abmc::IDate_createInstance_from_ymdhms(int year, int month, int day, int hour, int min, double sec) {
    return new CDate(year,month,day,hour,min,sec);
}

void abmc::IDate_deleteInstance(abmc::IDate *date) {
   if(date != NULL) {
      delete date;
   }
}

double abmc::IDate_get_jd(abmc::IDate *date,Frame frame) {
	double jj=date->get_jd(frame);
   return jj;
}

const char* abmc::IDate_get_iso(abmc::IDate *date,Frame frame) {
    return date->get_iso(frame);
}

void abmc::IDate_get_ymdhms(abmc::IDate *date,Frame frame,int *year,int *month,int *day,int *hour,int *minute,double *seconds) {
    return date->get_ymdhms(frame,year,month,day,hour,minute,seconds);
}

char* abmc::IDate_get_equinox(abmc::IDate *date,Frame frame,int year_type,int nb_subdigit) {
    return date->get_equinox(frame,year_type,nb_subdigit);
}

void abmc::IDate_set(IDate *date,const char * value) {
   CATCH_ERROR_VOID( date->set( value) );
}

void abmc::IDate_set_jd(IDate *date,double jd) {
   CATCH_ERROR_VOID( date->set( jd ) );
}


void abmc::IDate_set_pole(abmc::IDate *date, double ut1_utc) {
    return date->set_pole(ut1_utc);
}

void abmc::IDate_get_pole(abmc::IDate *date,double *ut1_utc) {
    return date->get_pole(ut1_utc);
}

///////////////////////////////////////////////////////////////////////////////
// IAngle C functions 
///////////////////////////////////////////////////////////////////////////////
abmc::IAngle* abmc::IAngle_createInstance_from_string(const char * angle) {
    return new CAngle(angle);
}

abmc::IAngle* abmc::IAngle_createInstance_from_deg(double deg) {
    return new CAngle(deg);
}

/*
abmc::IAngle* abmc::IAngle_createInstance_from_h_m_s(int hour, int min, double sec) {
    return new CAngle(hour,min,sec);
}
*/

void abmc::IAngle_deleteInstance(IAngle *angle) {
	delete angle;
}

double abmc::IAngle_get_deg(IAngle *angle,int limit_deg) {
    return angle->get_deg(limit_deg);
}

double abmc::IAngle_get_rad(IAngle *angle,int limit_rad) {
   return angle->get_rad(limit_rad);
}
void abmc::IAngle_get_s_d_m_s(IAngle *angle,int limit_deg,int *sign, int *deg,int *arcmin,double *arcsec) {
    return angle->get_s_d_m_s(limit_deg,sign,deg,arcmin,arcsec);
}

char* abmc::IAngle_get_sdd_mm_ss(IAngle *angle,int limit_deg) {
    return angle->get_sdd_mm_ss(limit_deg);
}

char *IAngle_getSexagesimal(IAngle *angle,const char* format) {
   std::string strResult =  angle->getSexagesimal(std::string(format));
   char*  charResult = new char[strResult.size() +1];
   strcpy(charResult, strResult.c_str());
   return charResult;
}

///////////////////////////////////////////////////////////////////////////////
// ICoordinates C functions  
///////////////////////////////////////////////////////////////////////////////
//abmc::ICoordinates* abmc::ICoordinates_createInstance() {
//    return new CCoordinates();
//}

//abmc::ICoordinates* abmc::ICoordinates_createInstance_from_angle(IAngle* angle1,IAngle* angle2) {
//    return new CCoordinates( (CAngle&)(*angle1) , (CAngle&)(*angle2));
//}

//abmc::ICoordinates* abmc::ICoordinates_createInstance_from_coord(ICoordinates* coords) {
//   CATCH_ERROR(abmc::ICoordinates::createInstance_from_coord((ICoordinates&)(*coords)), NULL);
//}

//abmc::ICoordinates* abmc::ICoordinates_createInstance_from_string(const char * angles, abmc::Equinox equinox) {
//   CATCH_ERROR( abmc::ICoordinates::createInstance_from_string(angles, equinox), NULL );
//}

void abmc::ICoordinates_deleteInstance(ICoordinates *coordinates) {
	delete coordinates;
}


const IAngle* abmc::ICoordinates_getAngle1(ICoordinates *coordinates) {
   return &(coordinates->getAngle1());
}

const IAngle* abmc::ICoordinates_getAngle2(ICoordinates *coordinates) {
   return &(coordinates->getAngle2());
}




//=============================================================================
// fonction utilitaire 
//=============================================================================

void abmc::deleteCharArray(char charArray[]) {
   if( charArray != NULL ) {
      delete [] charArray; 
   }
};

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Standalone functions
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

//=============================================================================
//C angle functions
//=============================================================================

int abmc::abmc_angle2deg(IMc* mc, const char *string_angle,double *deg)
{
   CATCH_ERROR( mc->angle2deg(string_angle, deg) , 0);	
}

int abmc::abmc_angle2rad(IMc* mc, const char *string_angle,double *rad)
{
   CATCH_ERROR( mc->angle2rad(string_angle, rad) , 0);	
}

int abmc::abmc_angles_computation(IMc* mc, const char *string_angle1,const char *string_operande,const char *string_angle2,double *deg)
{
   CATCH_ERROR( mc->angles_computation(string_angle1, string_operande, string_angle2, deg) , 0);	
}

int abmc::abmc_angle2sexagesimal(IMc* mc, double deg,const char *string_format,char *string_sexa)
{
   CATCH_ERROR( mc->angle2sexagesimal(deg, string_format, string_sexa) , 0);	
}

int abmc::abmc_coordinates_separation(IMc* mc, const char *coord1_angle1,const char *coord1_angle2,const char *coord2_angle1,const char *coord2_angle2,double *angle_distance,double *angle_position)
{
   CATCH_ERROR( mc->coordinates_separation(coord1_angle1, coord1_angle2, coord2_angle1, coord2_angle2, angle_distance, angle_position) , 0);	
}

//=============================================================================
//C date functions
//=============================================================================

int abmc::abmc_date2jd(IMc* mc, const char *string_date,double *jd)
{
   CATCH_ERROR( mc->date2jd(string_date, jd) , 0);
}

int abmc::abmc_date2iso8601(IMc* mc, const char *string_date,char *date_iso8601)
{
   CATCH_ERROR( mc->date2iso8601(string_date, date_iso8601) , 0);
}

int abmc::abmc_date2ymdhms(IMc* mc, const char *string_date,int *year,int *month,int *day,int *hour,int *minute,double *seconds)
{
   CATCH_ERROR( mc->date2ymdhms(string_date, year, month, day, hour, minute, seconds) , 0);
}

int abmc::abmc_date2tt(IMc* mc, const char *string_date,double *jd_tt)
{
   CATCH_ERROR( mc->date2tt(string_date, jd_tt) , 0);
}

int abmc::abmc_date2equinox(IMc* mc, const char *string_date,int year_type,int nb_subdigit, char *date_equ)
{
   CATCH_ERROR( mc->date2equinox(string_date, year_type, nb_subdigit, date_equ) , 0);
}

int abmc::abmc_date2lst(IMc* mc, const char *string_date_utc, double ut1_utc, const char *string_home, double xp_arcsec, double yp_arcsec, double *lst)
{
   CATCH_ERROR( mc->date2lst(string_date_utc, ut1_utc, string_home, xp_arcsec, yp_arcsec, lst) , 0);
}

/*
int abmc::abmc_dates_ut2bary(const char *string_date_utc, const char *string_coord, const char *string_date_equinox, const char *string_home, double **jd_bary)
{
   CATCH_ERROR( mc->dates_ut2bary(string_date_utc, string_coord, string_date_equinox, string_home, jd_bary) , 0);
}
*/

//=============================================================================
//C xxxx  functions
//=============================================================================

//int abmc::abmc_test_struct(abmc::mastruct *toto)
//{
//	strcpy(toto->nom,"robert");
//	toto->numero=34;
//   return ABMC_OK;
//}

//int abmc::abmc_test_struct_pointer(abmc::mastruct **toto)
//{
//	*toto = new mastruct();
//	strcpy((*toto)->nom,"robert");
//	(*toto)->numero=34;
//   return ABMC_OK;
//}

//void abmc::abmc_test_struct_delete_mastruct(abmc::mastruct *toto)
//{
//	delete toto ;
//}

//abmc::mastruct *abmc::abmc_test_struct_pointer2(void)
//{
//	mastruct *toto ;
//	toto = new mastruct();
//	strcpy(toto->nom,"franck");
//	toto->numero=35;
//   return toto;
//}

IStructArray *abmc::abmc_test_struct_tableau(void)
{
   abcommon::CStructArray<mastruct*> *obj ;
	obj = new abcommon::CStructArray<mastruct*>();
	for (int k=0;k<4;k++) {
   	mastruct* toto =new mastruct();
		sprintf(toto->nom,"franck_%d",k);
		toto->numero=40+k;
		obj->append(toto);
	}
   return obj;
}


// liste d'etoiles
IStructArray *abmc::abmc_getTableEtoiles(void)
{
   abcommon::CStructArray<SEtoile*>* etoiles ;
	etoiles = new abcommon::CStructArray<SEtoile*>();
	for (int k=0;k<4;k++) {
      SEtoile* etoile = new SEtoile();
      etoile->ra =  5*k;
      etoile->dec = 10*k;
      etoile->mag = k;
      sprintf(etoile->nom,"etoile_%d",k);
		etoiles->append(etoile);
	}
   return etoiles;
}


///////////////////////////////////////////////////////////////////////////////
// C IMc functions
///////////////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////////////
// C IMcPool functions : gère le pool des instances IMc
///////////////////////////////////////////////////////////////////////////////

abmc::IMc*  abmc::IMcPool_createInstance() {
   CATCH_ERROR( abmc::IMcPool::createInstance() , NULL);
}

void abmc::IMcPool_deleteInstance(abmc::IMc* producer) {
   CATCH_ERROR_VOID(abmc::IMcPool::deleteInstance(producer) );
}  

int abmc::IMcPool_getInstanceNo(abmc::IMc* producer) {
   CATCH_ERROR(abmc::IMcPool::getInstanceNo(producer) , 0 );
}

abmc::IMc* abmc::IMcPool_getInstance(int producerNo) {
   CATCH_ERROR(abmc::IMcPool::getInstance(producerNo) , NULL )
}

IIntArray* abmc::IMcPool_getIntanceNoList() {
   CATCH_ERROR(abmc::IMcPool::getIntanceNoList() , NULL );
}


//=============================================================================
// IArray 
//=============================================================================
// retourne le nombre d'elements d'un tableau
int abmc::IArray_size(IArray* dataArray) {
   CATCH_ERROR(dataArray->size(), 0);
}

// detruit le tableau
void abmc::IArray_deleteInstance(IArray* dataArray) {
   CATCH_ERROR_VOID(dataArray->release());
}


int abmc::IIntArray_at(IIntArray* dataArray, int index) {
   CATCH_ERROR(dataArray->at(index), 0);

}

const char* abmc::IStringArray_at(IStringArray* dataArray, int index) {
   CATCH_ERROR(dataArray->at(index), NULL);

}

void* abmc::IStructArray_at(IStructArray* dataArray, int index) {
   CATCH_ERROR(dataArray->at(index), NULL);

}
