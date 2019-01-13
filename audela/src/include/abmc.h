// abmc.h 
// header of libabmc astrobrick 
// abmc is a partial clone of libmc which can be used with TCL, C#, Python, ... 

#pragma once

#ifdef WIN32
#if defined(ABMC_EXPORTS) // inside DLL
#   define ABMC_API   __declspec(dllexport)
#else // outside DLL
#   define ABMC_API   __declspec(dllimport)
#endif 

#else 

#if defined(ABMC_EXPORTS) // inside DLL
#   define ABMC_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define ABMC_API 
#endif 

#endif

// unique  include autorisé dans le header principal d'une astrobrick
#include <abcommon2.h>
using namespace abcommon;


#include <string>
//#include <vector>

#define ABMC_OK 0
#define ABMC_ERROR 1

//#define ABMC_IERS_FRAME_TRF 0
//#define ABMC_IERS_FRAME_CRF 1

//#define ABMC_YEAR_TYPE_AUTO 0
//#define ABMC_YEAR_TYPE_JULIAN 1
//#define ABMC_YEAR_TYPE_BESSELIAN 2

//=============================================================================
/// \namespace abmc
/// \brief celestial mechanics computing
///
/// abmc : celestial mechanics computing
///===============================
/// Libmc is a library which adds functions concerning celestial mechanics.
///
namespace abmc {

   //=============================================================================
   // Frame  
   //=============================================================================
   // References for TRF and CRF
   // http://www.iers.org/IERS/EN/Publications/Bulletins/bulletins.html (bulletins A)
   // Terrestrial Reference Frame (TRF)
   //	Celestial Reference Frame (CRF)
   class Frame 
   {
   public:
      enum Values { TR, CR };
      Frame(Values t) : m_value(t) {}
      operator Values () const {return m_value;}
   private:
      Values m_value;   
   };

   //=============================================================================
   // Equinox  
   //=============================================================================
   class Equinox 
   {
   public:
      enum Values { NOW, J2000 };
      Equinox(Values t) : m_value(t) {}
      operator Values () const {return m_value;}
   private:
      Values m_value;   
   };

   //=============================================================================
   // Sense  
   //=============================================================================
   class Sense 
   {
   public:
      enum Values { EAST, WEST };
      Sense(Values t) : m_value(t) {}
      operator Values () const {return m_value;}
   private:
      Values m_value;   
   };

   //=============================================================================
   // YearType  
   //=============================================================================
   class YearType 
   {
   public:
      enum Values { AUTO, JULIAN, BESSELIAN};
      YearType(Values t) : m_value(t) {}
      operator Values () const {return m_value;}
   private:
      Values m_value;   
   };

   //=============================================================================
   // IHome interface 
   //=============================================================================

   class IHome
   {
   public:
      virtual ~IHome() {}; // destructeur virtuel demande sous linux
      virtual const char *get_errmsg()=0;
      // Accessors (output angles in degrees)
      virtual const char *get_GPS(Frame frame)=0;
      virtual const char *get_MPC(Frame frame)=0;
      //
      virtual double get_longitude(Frame frame)=0;
      virtual Sense  get_sense(Frame frame)=0;
      virtual double get_latitude(Frame frame)=0;
      virtual double get_altitude(Frame frame)=0;
      //
      virtual double get_longmpc(Frame frame)=0;
      virtual double get_rhocosphip(Frame frame)=0; 
      virtual double get_rhosinphip(Frame frame)=0; 
      //
      virtual void set_pole(double xp_arcsec, double yp_arcsec)=0; // update automatically the CRF
      virtual void get_pole(double *xp_arcsec, double *yp_arcsec)=0;
      //
      virtual void convert_geosys(const char *geosysin,const char *geosysout,int compute_h)=0;

      virtual void set(double longitude, Sense sense, double latitude, double elevation)=0;


   };

   /**
   @brief Create an instance of Home type from a string.
   @param home (formated as GPS abs(longitude_deg) E|W latitude_deg altitude_m)
   @return Pointer IHome 
   @code {.cpp}
   Ihome *home = abmc::IHome_createInstance_from_string("GPS 2 E 43 1345");
   ...
   IHome_deleteInstance(home); 
   @endcode
   */
   extern "C" ABMC_API IHome*  IHome_createInstance();
   extern "C" ABMC_API IHome*  IHome_createInstance_from_string(const char *home);
   extern "C" ABMC_API IHome*  IHome_createInstance_from_obscode(const char *obscode, const char *obscode_file);
   extern "C" ABMC_API IHome*  IHome_createInstance_from_MPC(double longimpc, double rhocosphip, double rhosinphip);
   extern "C" ABMC_API IHome*  IHome_createInstance_from_GPS(double longitude, Sense sense, double latitude, double altitude);
   extern "C" ABMC_API void    IHome_deleteInstance(IHome* home);

   extern "C" ABMC_API const char * IHome_get_errmsg(IHome *home);

   extern "C" ABMC_API const char * IHome_get_MPC(IHome *home,Frame frame);
   extern "C" ABMC_API const char * IHome_get_GPS(IHome *home,Frame frame);

   extern "C" ABMC_API double       IHome_get_longitude(IHome *home,Frame frame);
   extern "C" ABMC_API const Sense::Values IHome_get_sense(IHome *home,Frame frame);
   extern "C" ABMC_API double       IHome_get_latitude(IHome *home,Frame frame);
   extern "C" ABMC_API double       IHome_get_altitude(IHome *home,Frame frame);

   extern "C" ABMC_API double IHome_get_longmpc(IHome *home,Frame frame);
   extern "C" ABMC_API double IHome_get_rhocosphip(IHome *home,Frame frame);
   extern "C" ABMC_API double IHome_get_rhosinphip(IHome *home,Frame frame);

   extern "C" ABMC_API void IHome_set_pole(IHome *home,double xp_arcsec, double yp_arcsec);
   extern "C" ABMC_API void IHome_get_pole(IHome *home,double *xp_arcsec, double *yp_arcsec);

   extern "C" ABMC_API void IHome_convert_geosys(IHome *home,const char *geosysin,const char *geosysout,int compute_h);

   //=============================================================================
   // IAngle interface 
   //=============================================================================
   /// @brief convert angle string value to double value 

   class IAngle
   {
   public:
      virtual ~IAngle() {}; // destructeur virtuel demande sous linux

      // Accessors
      virtual double get_deg(double limit_deg)=0;
      virtual double get_rad(double limit_rad)=0;
      virtual void   get_s_d_m_s(double limit_deg,int *sign,int *deg,int *min,double *sec)=0;
      virtual char*  get_sdd_mm_ss(double limit_deg)=0;
      virtual std::string getSexagesimal(std::string format)=0;
      virtual void   setDegree(double deg)=0;
      
   };

   extern "C" ABMC_API IAngle* IAngle_createInstance_from_string(const char *angle);
   extern "C" ABMC_API IAngle* IAngle_createInstance_from_deg(double deg);
   extern "C" ABMC_API IAngle* IAngle_createInstance_from_h_m_s(int hour, int min, double sec);
   extern "C" ABMC_API void    IAngle_deleteInstance(IAngle* angle);

   extern "C" ABMC_API double IAngle_get_deg(IAngle *angle,int limit_deg);
   extern "C" ABMC_API double IAngle_get_rad(IAngle *angle,int limit_rad);
   extern "C" ABMC_API void IAngle_get_s_d_m_s(IAngle *angle,int limit_deg,int *sign,int *deg,int *arcmin,double *arcsec);
   extern "C" ABMC_API char *IAngle_get_sdd_mm_ss(IAngle *angle,int limit_deg);
   extern "C" ABMC_API char *IAngle_getSexagesimal(IAngle *angle,const char* format);



   //=============================================================================
   // ICoordinates interface 
   //=============================================================================
   /// @brief convert angle string value to double value 

   class ICoordinates
   {
   public:
      //ABMC_API static ICoordinates* createInstance();
      //ABMC_API static ICoordinates* createInstance_from_string(const char *angles, abmc::Equinox equinox);
      //ABMC_API static ICoordinates* createInstance_from_coord(ICoordinates& coords);
      
      // Accessors
      //virtual void get_deg(double *deg1,double *deg2)=0;
      //
      virtual double             getRa(Equinox equinox)=0;
      virtual double             getDec(Equinox equinox)=0;
      virtual IAngle&            getAngle1()=0;
      virtual IAngle&            getAngle2()=0;
      virtual void               setRaDec(double ra, double dec, Equinox equinox)=0;

   };

   extern "C" ABMC_API ICoordinates* ICoordinates_createInstance();
   extern "C" ABMC_API ICoordinates* ICoordinates_createInstance_from_coord(ICoordinates* coords);
   //extern "C" ABMC_API ICoordinates* ICoordinates_createInstance_from_angle(IAngle* angle1, IAngle* angle2);
   extern "C" ABMC_API ICoordinates* ICoordinates_createInstance_from_string(const char *angles, abmc::Equinox equinox);
   extern "C" ABMC_API void          ICoordinates_deleteInstance(ICoordinates* coordinates);

   //extern "C" ABMC_API void ICoordinates_get_deg(ICoordinates *coordinates,double *deg1,double *deg2);
   extern "C" ABMC_API const IAngle* ICoordinates_getAngle1(ICoordinates* coordinates);
   extern "C" ABMC_API const IAngle* ICoordinates_getAngle2(ICoordinates* coordinates);

   //=============================================================================
   // IDate interface 
   //=============================================================================

   class IDate
   {
   public:
      virtual const char *get_errmsg()=0;

      // Accessors
      virtual const char*  get_iso(Frame frame)=0;
      virtual double       get_jd(Frame frame)=0;
      virtual void         get_ymdhms(Frame frame,int *y,int *m,int *d,int *hh, int *mm, double *ss)=0;
      virtual char*        get_equinox(Frame frame,int year_type,int nb_subdigit)=0;
      virtual void         set(const char * value)=0;
      virtual void         set(double jd)=0;
      virtual void         set(int year, int month, int day, int hour, int min, double sec) = 0;

      //
      virtual void set_pole(double ut1_utc)=0; // update automatically the CRF
      virtual void get_pole(double *ut1_utc)=0;
   };

   /**
   @brief Create an instance of Date type from a string.
   @param home (formated as one string ISO 8601 or two strings ISO 8601 or 6 elements as Y M D h m s)
   @return Pointer IDate
   @code {.cpp}
   IDate *date = abmc::IDate_createInstance_from_string("2015-08-23T19:50:34.567");
   ...
   IDate_deleteInstance(date); 
   @endcode
   */
   extern "C" ABMC_API IDate* IDate_createInstance();
   extern "C" ABMC_API IDate* IDate_createInstance_from_string(const char *date);
   extern "C" ABMC_API IDate* IDate_createInstance_from_ymd(int year, int month, double day);
   extern "C" ABMC_API IDate* IDate_createInstance_from_ymdhms(int year, int month, int day, int hour, int min, double sec);
   extern "C" ABMC_API void   IDate_deleteInstance(IDate* date);

   extern "C" ABMC_API double IDate_get_jd(IDate *date,Frame frame);
   extern "C" ABMC_API const char*  IDate_get_iso(IDate *date,Frame frame);
   extern "C" ABMC_API void   IDate_get_ymdhms(IDate *date,Frame frame,int *year,int *month,int *day,int *hour,int *minute,double *seconds);
   extern "C" ABMC_API char*  IDate_get_equinox(IDate *date,Frame frame,int year_type,int nb_subdigit);
   extern "C" ABMC_API void   IDate_set(IDate *date, const char * value);
   extern "C" ABMC_API void   IDate_set_jd(IDate *date, double jd);

   extern "C" ABMC_API void   IDate_set_pole(IDate *date,double ut1_utc);
   extern "C" ABMC_API void   IDate_get_pole(IDate *date,double *ut1_utc);

   //=============================================================================
   // utilities
   //=============================================================================
   /// delete returned string created by astrobrick functions
   extern "C" ABMC_API void deleteCharArray(char charArray[]);

   //=============================================================================
   // class IMc
   //=============================================================================

   class IMc : public abcommon::IPoolInstance
   {
   public:  // C++ method
      virtual      ~IMc() {};
      // angle
      virtual  int angle2deg(const char *string_angle,double *deg)=0;
      virtual  int angle2rad(const char *string_angle,double *rad)=0;
      virtual  int angle2sexagesimal(double deg,const char *string_format,char *string_sexa)=0;
      virtual  int angles_computation(const char *string_angle1,const char *string_operande,const char *string_angle2,double *deg)=0;

      //date
      virtual  int date2jd(const char *string_date,double *jd)=0;
      virtual  int date2iso8601(const char *string_date,char *date_iso8601)=0;
      virtual  int date2ymdhms(const char *string_date,int *year,int *month,int *day,int *hour,int *minute,double *seconds)=0;
      virtual  int date2tt(const char *string_date,double *jd_tt)=0;
      virtual  int date2equinox(const char *string_date,int year_type,int nb_subdigit,char *date_equ)=0;
      virtual  int date2lst(const char *string_date_utc, double ut1_utc, const char *string_home, double xp_arcsec, double yp_arcsec, double *lst)=0;
      //virtual  int dates_ut2bary(const char *string_date_utc,, const char *string_coord, const char *string_date_equinox, const char *string_home, double **jd_bary)=0;

      virtual  int coordinates_separation(const char *coord1_angle1,const char *coord1_angle2,const char *coord2_angle1,const char *coord2_angle2,double *angle_distance,double *angle_position)=0;

      virtual IHome* createHome()=0;

      virtual ICoordinates* createCoordinates()=0;
      virtual ICoordinates* createCoordinates_from_string(const char *angles, abmc::Equinox equinox)=0;
      virtual ICoordinates* createCoordinates_from_coord(ICoordinates& coords)=0;

      //accesseurs
      virtual void setFixedDate(IDate &date) = 0;
      virtual void unsetFixedDate() = 0;
      virtual IDate& getDate()=0;
      virtual IHome& getHome() = 0;
      virtual void   setHome(IHome &home) = 0;



   };
   //  C function
   extern "C" ABMC_API int abmc_angle2deg(IMc* mc, const char *string_angle,double *deg);
   extern "C" ABMC_API int abmc_angle2rad(IMc* mc, const char *string_angle,double *rad);
   extern "C" ABMC_API int abmc_angle2sexagesimal(IMc* mc, double deg,const char *string_format,char *string_sexa);
   extern "C" ABMC_API int abmc_angles_computation(IMc* mc, const char *string_angle1,const char *string_operande,const char *string_angle2,double *deg);

   extern "C" ABMC_API int abmc_date2jd(IMc* mc, const char *string_date,double *jd);
   extern "C" ABMC_API int abmc_date2iso8601(IMc* mc, const char *string_date,char *date_iso8601);
   extern "C" ABMC_API int abmc_date2ymdhms(IMc* mc, const char *string_date,int *year,int *month,int *day,int *hour,int *minute,double *seconds);
   extern "C" ABMC_API int abmc_date2tt(IMc* mc, const char *string_date,double *jd_tt);
   extern "C" ABMC_API int abmc_date2equinox(IMc* mc, const char *string_date,int year_type,int nb_subdigit,char *date_equ);
   extern "C" ABMC_API int abmc_date2lst(IMc* mc, const char *string_date_utc, double ut1_utc, const char *string_home, double xp_arcsec, double yp_arcsec, double *lst);
   //extern "C" ABMC_API int abmc::abmc_dates_ut2bary(const char *string_date_utc, const char *string_coord, const char *string_date_equinox, const char *string_home, double **jd_bary)

   extern "C" ABMC_API int abmc_coordinates_separation(IMc* mc, const char *coord1_angle1,const char *coord1_angle2,const char *coord2_angle1,const char *coord2_angle2,double *angle_distance,double *angle_position);

   //=============================================================================
   // class IMcPool (pool des insatnce de IMc
   //=============================================================================

   class IMcPool
   {
   public: // C++ factory
      ABMC_API static IMc*   createInstance();
      ABMC_API static void   deleteInstance(IMc* mc);
      ABMC_API static int    getInstanceNo(IMc* mc);
      ABMC_API static IMc*   getInstance(int producerNo);
      ABMC_API static abcommon::IIntArray* getIntanceNoList();
   };

   //  C factory
   extern "C" ABMC_API IMc*   IMcPool_createInstance();
   extern "C" ABMC_API void   IMcPool_deleteInstance(IMc* mc);
   extern "C" ABMC_API int    IMcPool_getInstanceNo(IMc* mc);
   extern "C" ABMC_API IMc*  IMcPool_getInstance(int producerNo);
   extern "C" ABMC_API abcommon::IIntArray* IMcPool_getIntanceNoList();


   //=============================================================================
   // IStruct_mastruct interface 
   //=============================================================================

   //class IStruct_mastruct
   //{
   //public:
   //	// Accessors
   //   virtual int size(void)=0;
   //   virtual mastruct *at(int index)=0;
   //	//
   //};

   //extern "C" ABMC_API int abmc_test_struct(mastruct *toto);
   //extern "C" ABMC_API int abmc_test_struct_pointer(mastruct **toto);
   //extern "C" ABMC_API void abmc_test_struct_delete_mastruct(mastruct *toto);
   //extern "C" ABMC_API mastruct *abmc_test_struct_pointer2(void);

   //#define IDataArray void

   typedef struct {
      char nom[20];
      int numero;
   } mastruct;


   extern "C" ABMC_API IStructArray*  abmc_test_struct_tableau(void);

   typedef struct {
      char nom[20];
      double ra;
      double dec;
      double mag;
   } SEtoile;

   extern "C" ABMC_API IStructArray*  abmc_getTableEtoiles(void);

   //=============================================================================
   // IArray 
   //=============================================================================
   extern "C" ABMC_API void        IArray_deleteInstance(IArray* dataArray);
   extern "C" ABMC_API int         IArray_size(IArray* dataArray);
   extern "C" ABMC_API int         IIntArray_at(IIntArray* dataArray, int index);
   extern "C" ABMC_API const char* IStringArray_at(IStringArray* dataArray, int index);
   extern "C" ABMC_API void*       IStructArray_at(IStructArray* dataArray, int index);

} // namespace end
