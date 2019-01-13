/* libabaudela.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#pragma once

//=============================================================================
// export directive and import directive
//=============================================================================

#ifdef WIN32
#if defined(ABAUDELA_EXPORTS) // inside DLL
#   define ABAUDELA_API   __declspec(dllexport)
#else // outside DLL
#   define ABAUDELA_API   __declspec(dllimport)
#endif 

#else 

#if defined(ABAUDELA_EXPORTS) // inside DLL
#   define ABAUDELA_API   __attribute__((visibility ("default")))
#else // outside DLL
#   define ABAUDELA_API 
#endif 

#endif

#ifdef _WIN32
//  C4290 : C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#pragma warning( disable : 4290 )
#endif

#include <abcommon2.h>
#include <abmc.h>

namespace abaudela {


   typedef float TYPE_PIXELS;

   typedef enum { CLASS_GRAY, CLASS_RGB, CLASS_3D, CLASS_VIDEO, CLASS_UNKNOWN } TPixelClass;
   typedef enum { FORMAT_BYTE, FORMAT_SHORT, FORMAT_USHORT, FORMAT_FLOAT, FORMAT_UNKNOWN } TPixelFormat;
   typedef enum { COMPRESS_NONE, COMPRESS_RGB, COMPRESS_I420, COMPRESS_JPEG, COMPRESS_RAW, COMPRESS_UNKNOWN } TPixelCompression;
   typedef enum { PLANE_GREY, PLANE_RGB, PLANE_R, PLANE_G, PLANE_B, PLANE_UNKNOWN } TColorPlane;

   //--------------------------------------------------------------------------------------
   // enum Alignment
   //--------------------------------------------------------------------------------------
   class Alignment
   {
   public:
      enum Values { ALTAZ, EQUATORIAL, POLAR };
      Alignment() { m_value = EQUATORIAL; }
      Alignment(Values t) : m_value(t) {}
      operator Values () const { return m_value; }
   protected:
      Values m_value;
   };

   //--------------------------------------------------------------------------------------
   // enum Direction
   //--------------------------------------------------------------------------------------
   class Direction 
   {
   public:
      enum Values { NORTH, SOUTH, EAST, WEST , ALL};
      Direction(Values t) : m_value(t) {}
      operator Values () const {return m_value;}
   protected:
      Values m_value;   
   };

   



   // autoguider
   typedef enum { DetectionPSF, DetectionSLIT} AutoguiderDetectionType;

   struct AutoguiderCallbackData {
      int code;
      double value1; 
      double value2; 
      const char * message;
   };

   /// callback error type. User program must implement a function with to capture exception. 
   typedef void (* ErrorCallbackType)(int code, const char * message);

   // autoguider callback type. 
   typedef void (* AutoguiderCallbackType)(AutoguiderCallbackData *data);

   //--------------------------------------------------------------------------------------
   // class IFitsKeyword
   //--------------------------------------------------------------------------------------
   class IFitsKeyword {
   public:
      virtual  ~IFitsKeyword(){};       // vitual destructor requis par le compilateur g++
      virtual int          getDataType()=0;
      virtual const char * getName()=0;
      virtual const char * getComment()=0;
      virtual const char * getUnit()=0;
      virtual const char * getStringValue()=0;
      virtual double       getDoubleValue()=0;
      virtual float        getFloatValue()=0;
      virtual int          getIntValue()=0;
      virtual IFitsKeyword* getNextKeyword()=0;

   };

   class IFitsKeywords {

   };


   //--------------------------------------------------------------------------------------
   // class IBuffer
   //--------------------------------------------------------------------------------------
   class IBuffer : public abcommon::IPoolInstance {
   public: // C++ factorys
      ABAUDELA_API static IBuffer*     createInstance() throw(abcommon::IError);
      ABAUDELA_API static void         deleteInstance(IBuffer* buffer);
      ABAUDELA_API static int          getInstanceNo(IBuffer* buffer);
      ABAUDELA_API static IBuffer*     getInstance(int bufferNo);
      ABAUDELA_API static abcommon::IIntArray* getIntanceNoList();
   
   public:
      enum TDataType {dt_Short, dt_Int, dt_Float}  ;
      enum TCompressType {BUFCOMPRESS_NONE, BUFCOMPRESS_GZIP};
      enum TFreeBuffer { KEEP_KEYWORDS, DONT_KEEP_KEYWORDS }; 
      virtual 				~IBuffer(){};

      //Reference
      virtual void reference()=0;
      virtual void unreference()=0;
      virtual int getReference()=0;

      //process
      virtual int A_StarList(int x1, int y1, int x2, int y2, double threshin, const char *filename, int fileFormat, double fwhm,int radius,
                     int border,double threshold,int after_gauss)=0;
      virtual void Add(char *filename, float offset)=0;
      virtual void AstroFlux(int x1, int y1, int x2, int y2,
                        TYPE_PIXELS* flux, TYPE_PIXELS* maxi, int *xmax, int* ymax,
                        TYPE_PIXELS *moy, TYPE_PIXELS *seuil, int *nbpix)=0;
      virtual void AstroCentro(int x1, int y1, int x2, int y2, int xmax, int ymax,
                        TYPE_PIXELS seuil,float* sx, float* sy, float* r)=0;
      virtual void AstroPhoto(int x1, int y1, int x2, int y2, int xmax, int ymax,
                        TYPE_PIXELS moy, double *dFlux, int* ntot)=0;
      virtual void AstroPhotom(int x1, int y1, int x2, int y2, int method, double r1, double r2,double r3,
                         double *flux, double* f23, double* fmoy, double* sigma, int *n1)=0;
      virtual void AstroBaricenter(int x1, int y1, int x2, int y2, double *xc, double *yc)=0;
      virtual void AstroSlitCentro(int x1, int y1, int x2, int y2,
                           int starDetectionMode, int pixelMinCount,
                           int slitWidth, double signalRatio,
                           char *starStatus, double *xc, double *yc,
                           TYPE_PIXELS* maxIntensity, char * message)=0;
      virtual void AstroFiberCentro(int x1, int y1, int x2, int y2,
                             int starDetectionMode, int fiberDetectionMode,
                             int integratedImage, int findFiber,
                             IBuffer *  maskBuf, IBuffer * sumBuf , IBuffer *  fiberBuf,
                             int maskRadius, double maskFwhm, double maskPercent,
                             int originSumMinCounter, int originSumCounter,
                             double previousFiberX, double previousFiberY,
                             int pixelMinCount, double biasValue,
                             char *starStatus,  double *starX,  double *starY,
                             char *fiberStatus, double *fiberX, double *fiberY,
                             double *measuredFwhmX, double *measuredFwhmY,
                             double *background, double *maxIntensity,
                             double *starFlux, char *message)=0;
      virtual void Autocut(double *phicut,double *plocut,double *pmode)=0;
      virtual void BinX(int x1, int x2, int width)=0;
      virtual void BinY(int y1, int y2, int height)=0;
      virtual void Cfa2Rgb(int method)=0;
      virtual void Clipmax(double value)=0;
      virtual void Clipmin(double value)=0;
      virtual void Div(char *filename, float constante)=0;
      virtual void p2radec(double p1, double p2, double *ra, double *dec,int order)=0;
      virtual void radec2p(double ra, double dec,double *p1, double *p2, int order)=0;
      virtual void Fwhm(int x1, int y1, int x2, int y2,
         double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
         double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
         double fwhmx0, double fwhmy0)=0;
      virtual void Fwhm2d(int x1, int y1, int x2, int y2,
         double *maxx, double *posx, double *fwhmx, double *fondx, double *errx,
         double *maxy, double *posy, double *fwhmy, double *fondy, double *erry,
         double fwhmx0, double fwhmy0)=0;
      virtual void psfimcce(int x1, int y1, int x2, int y2,
         double *xsm, double *ysm, double *err_xsm, double *err_ysm,
         double *fwhmx, double *fwhmy, double *fwhm, double *flux,
         double *err_flux, double *pixmax, double *intensity, double *sky,
         double *err_sky, double *snint, int *radius, int *err_psf,
         float **residus, float **synthetic)=0;
      virtual void Histogram(int n, float *adus, float *meanadus, long *histo,
         int ismini,float mini,int ismaxi,float maxi)=0;

      virtual void Log(float coef, float offset)=0;
      virtual void NGain(float gain)=0;
      virtual void NOffset(float offset)=0;
      virtual void Unsmear(float coef)=0;
      virtual void MedX(int x1, int x2, int width)=0;
      virtual void MedY(int y1, int y2, int height)=0;
      virtual void Offset(TYPE_PIXELS offset)=0;
      virtual void Opt(char *dark, char *offset)=0;
      virtual void RestoreInitialCut()=0;
      virtual void Rot(float x0, float y0, float angle)=0;
      virtual void Sub(char *filename, float offset)=0;
      virtual void Sub(IBuffer* subBuffer, float offset)=0;
      virtual void TtImaSeries(char *s)=0;
      virtual void Stat(int x1,int y1,int x2,int y2,
         float *locut, float *hicut,  float *maxi,    float *mini,   float *mean,
         float *sigma, float *bgmean, float *bgsigma, float *contrast)=0;
      virtual void Scar( int x1,int y1,int x2,int y2)=0;
      virtual void SyntheGauss(double xc, double yc, double imax, double jmax, double fwhmx, double fwhmy, double limitadu)=0;
      virtual void radec2xy(double ra, double dec, double *x, double *y,int order)=0;
      virtual void xy2radec(double x, double y, double *ra, double *dec,int order)=0;
      virtual void SubStars(const char *fileName, int indexcol_x, int indexcol_y, int indexcol_bg, double radius, double xc_exclu, double yc_exclu, double radius_exclu,int *n)=0;
      virtual void Window(int x1, int y1, int x2, int y2)=0;

      // pixels
      virtual void freeBuffer(TFreeBuffer keep_keywords)=0;
      virtual TDataType getDataType()=0;
      virtual TPixelClass getPixelClass(const char * planeName)=0;
      virtual TPixelCompression getPixelCompression(const char *)=0;
      virtual TPixelFormat getPixelFormat(const char * formatName)=0;
      virtual TColorPlane getColorPlane(const char * planeName)=0;
      virtual int  getWidth()=0;
      virtual int  getHeight()=0;
      virtual int  getNaxis()=0;
      virtual void getPix(int *plane, TYPE_PIXELS *val1,TYPE_PIXELS *val2,TYPE_PIXELS *val3,int x, int y)=0;
      virtual void getPixels(TYPE_PIXELS* pixels)=0;
      virtual void getPixels(TYPE_PIXELS *pixels, TColorPlane colorPlane)=0;
      virtual void getPixels(int x1, int y1, int x2, int y2, TPixelFormat pixelFormat, TColorPlane plane, void* pixelsPtr)=0;
      virtual void getPixelsPointer(TYPE_PIXELS **ppixels)=0;
      virtual void getPixelsVisu( int x1,int y1,int x2, int y2,
               int mirrorX, int mirrorY, float *cuts,
               unsigned char *palette[3], unsigned char *ptr)=0;
      virtual void mergePixels(TColorPlane plane, int pixels)=0;
      virtual void setPix(TColorPlane plane, TYPE_PIXELS,int,int)=0;
      virtual void setPixels(int width, int height, int plane, TYPE_PIXELS * pixels, int reverseX, int reverseY)=0;
      virtual void setPixels(TColorPlane plane, int width, int height, TPixelFormat pixelFormat, TPixelCompression compression, void * pixels, long pixelSize, int reverse_x, int reverse_y)=0;

      virtual void copyFrom(IFitsKeywords* hdr, TColorPlane plane, TYPE_PIXELS*pix)=0;
      virtual void copyTo(IBuffer* bufTo)=0;
      virtual void copyKwdFrom(IBuffer* bufFrom)=0;
      virtual bool isPixelsReady(void)=0;


      // keywords
      virtual bool hasKeyword(const char *keywordName)=0;
      virtual int          getKeywordDataType(const char *keywordName)=0;
      virtual const char * getKeywordComment(const char *keywordName)=0;
      virtual const char * getKeywordUnit(const char *keywordName)=0;
      virtual const char * getKeywordStringValue(const char *keywordName)=0;
      virtual double       getKeywordDoubleValue(const char *keywordName)=0;
      virtual float        getKeywordFloatValue(const char *keywordName)=0;
      virtual int          getKeywordIntValue(const char *keywordName)=0;
      virtual void setKeyword(const char *nom, double doubleValue, const char *comment, const char *unit)=0;
      virtual void setKeyword(const char *nom, float floatValue, const char *comment, const char *unit)=0;
      virtual void setKeyword(const char *nom, int   intValue, const char *comment, const char *unit)=0;
      virtual void setKeyword(const char *nom, const char *stringValue, const char *comment, const char *unit)=0;
      virtual void deleteKeyword(const char *keywordName)=0;
      virtual void deleteAllKeywords()=0;
      virtual IFitsKeyword* getFirstKeyword()=0;

      //file
      virtual const char * getExtension()=0;
      virtual void setExtension(const char *ext)=0;
      virtual int getCompressType()=0;
      virtual void setCompressType(int ct)=0;
      virtual int getSavingType()=0;
      virtual void setSavingType(int st)=0;
      virtual void create3d(char *filename,int init, int nbtot, int index,int *naxis10, int *naxis20, int *errcode)=0;
      virtual void loadFile(const char *filename, int iaxis3)=0;
      virtual void loadFits(const char *filename)=0;
      virtual void load3d(const char *filename,int iaxis3)=0;
      virtual void save1d(char *filename,int iaxis2)=0;
      virtual void save3d(char *filename,int naxis3,int iaxis3_beg,int iaxis3_end)=0;
      virtual void saveFits(const char *filename, int iaxis3)=0;
      virtual void saveFits(const char *filename)=0;
      virtual void saveJpg(char *filename,int quality, unsigned char *palette[3], int mirrorx, int mirrory)=0;
      virtual void saveJpg(char *filename,int quality,int sbsh, double sb,double sh)=0;
      virtual void saveRawFile(const char *filename)=0;
   };

   //  C factory 
   extern "C" ABAUDELA_API IBuffer*    IBuffer_createInstance();
   extern "C" ABAUDELA_API void        IBuffer_deleteInstance(IBuffer* buffer);
   extern "C" ABAUDELA_API int         IBuffer_getInstanceNo(IBuffer* buffer);
   extern "C" ABAUDELA_API IBuffer*    IBuffer_getInstance(int bufferNo);
   extern "C" ABAUDELA_API abcommon::IIntArray* IBuffer_getIntanceNoList();

   // C functions
   extern "C" ABAUDELA_API   int    IBuffer_getWidth(IBuffer* buffer);
   extern "C" ABAUDELA_API   int    IBuffer_getHeight(IBuffer* buffer);


   // declaration tempaire de ITelescope pour pouvoir l'utiliser dans ICamera
   class ITelescope;
   class IEvent {
   public:
      virtual int getType()=0;
   };

   //-----------------------------------------------------------------------------
   //  ICamera
   //-----------------------------------------------------------------------------
   // camera callback type. 
   
   class ICamera : public abcommon::IPoolInstance {

   public:  
      // camera factory
      ABAUDELA_API static ICamera*     createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]) throw(abcommon::IError);
      ABAUDELA_API static void         deleteInstance(ICamera* camera);
      ABAUDELA_API static int          getInstanceNo(ICamera* camera);
      ABAUDELA_API static ICamera*     getInstance(int cameraNo);
      ABAUDELA_API static abcommon::IIntArray* getIntanceNoList();
      ABAUDELA_API static abcommon::IStructArray* getAvailableCamera(const char* libraryPath, const char * libraryFileName);

   public:
      /// status de l'acquisition d'image
      enum AcquisitionStatus { AcquisitionStand, AcquisitionExp, AcquisitionRead } ;
      enum ShutterMode { ShutterClosed, ShutterOpened, ShutterSynchro} ;
      enum Capability { Shutter, ExpTimeCommand, ExpTimeList, VideoMode } ;

      typedef void(*CameraStatusCallbackType)(void *clientData, AcquisitionStatus status);

      virtual 				   ~ICamera(){};
      virtual void         setSatusCallback(void *clientData, CameraStatusCallbackType cameraCallback)=0;
      virtual void         acq()=0;
      virtual void         getBinning(int* binx, int* biny)=0; 
      virtual void         setBinning(int binx, int biny)=0;
      virtual void         getBinningMax(int* binMaxX, int* binMaxY)=0;
      virtual IBuffer*     getBuffer()=0; 
      virtual void         setBuffer(IBuffer* buffer)=0;
      virtual bool         getCapability(Capability capability)=0;
      virtual const char*  getCcd()=0;
      virtual void         getCellDim(double* celldimx, double* celldimy)=0;
      //virtual void       setCellDim(double celldimx, double celldimy)=0;
      virtual void         getCellNb(int* cellx, int* celly) = 0;
      virtual bool         getCooler()=0;
      virtual void         setCooler(bool on)=0;
      virtual double       getCoolerCheckTemperature()=0;
      virtual void         setCoolerCheckTemperature(double temperature)=0;
      virtual double       getCoolerCcdTemperature()=0;
      virtual int          getDebug()=0;
      virtual void         setDebug(int debug)=0;
      virtual const char*  getDriverName()=0;
      virtual int          executeSpecificCommand(char** result, int argc, const char *argv[])=0;
      virtual void         freeSpecificCommandResult()=0;
      virtual int          executeTclSpecificCommand(void* interp, int argc, const char *argv[])=0;
      virtual double       getExptime()=0; 
      virtual void         setExptime(double exptime)=0;
      virtual double       getFillFactor()=0;   
      virtual double       getGain()=0;

      virtual const char*  getLibraryName()=0;
      virtual double       getMaxDyn()=0;
      virtual bool         getMirrorH()=0;
      virtual void         setMirrorH(bool mirror)=0;
      virtual bool         getMirrorV()=0;
      virtual void         setMirrorV(bool mirror)=0;
      virtual const char*  getCameraName()=0;
      virtual void         getPixDim(double* dimx, double* dimy) = 0;
      virtual void         getPixNb(int* pixx, int* pixy)=0;
      virtual bool         getOverScan()=0;
      virtual void         setOverScan(bool overScan)=0;
      virtual const char*  getProduct()=0;
      virtual const char*  getPortName()=0;
      virtual bool         getRadecFromTel()=0;
      virtual void         setRadecFromTel(bool radecFromTel)=0;
      virtual double       getReadNoise()=0;
      virtual int          getRgb()=0;
      virtual ShutterMode  getShutterMode()=0; 
      virtual void         setShutterClosed()=0;
      virtual void         setShutterOpened() = 0;
      virtual void         setShutterSyncho()=0;
      virtual bool          getStopMode()=0;
      virtual void         setStopMode(bool stopMode)=0;
      virtual void         stopExposure()=0;
      virtual ITelescope*  getTelescope()=0;
      virtual void         setTelescope(ITelescope* telescope)=0;
      virtual int          getTimer(bool countDown)=0;
      virtual void         getWindow(int* x1, int* y1, int* x2, int* y2)=0;
      virtual void         setWindow(int x1, int y1, int x2, int y2)=0;
     
   };


   // C Interface camera Pool
   extern "C" ABAUDELA_API ICamera*    ICamera_createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]);
   extern "C" ABAUDELA_API void        ICamera_deleteInstance(ICamera* camera);
   extern "C" ABAUDELA_API int         ICamera_getInstanceNo(ICamera* camera);
   extern "C" ABAUDELA_API ICamera*    ICamera_getInstance(int cameraNo);
   extern "C" ABAUDELA_API abcommon::IIntArray* ICamera_getIntanceNoList();

   extern "C" ABAUDELA_API abcommon::IStructArray*  ICamera_getAvailableCamera(const char* librayPath, const char * libraryFileName);


   extern "C" ABAUDELA_API void        ICamera_acq(ICamera* camera);
   extern "C" ABAUDELA_API void        ICamera_setCallback(ICamera* camera, void *clientData, ICamera::CameraStatusCallbackType cameraCallback) ;
   extern "C" ABAUDELA_API void        ICamera_getBinning(ICamera* camera, int* binx, int* biny); 
   extern "C" ABAUDELA_API void        ICamera_setBinning(ICamera* camera, int binx, int biny);
   extern "C" ABAUDELA_API const char* ICamera_getCameraName(ICamera* camera);

   extern "C" ABAUDELA_API double      ICamera_getExptime(ICamera* camera); 
   extern "C" ABAUDELA_API void        ICamera_setExptime(ICamera* camera, double exptime);


   //  C factory 
   //-----------------------------------------------------------------------------
   //  Telescope
   //-----------------------------------------------------------------------------
   
   // camera callback type. 
   typedef void (* TelescopeCallbackType)(void *clientdata, int code, int value1, double value2, char * message);

   typedef void (*TelescopeCallbackCoordType)(void *clientData, abmc::ICoordinates* coordinates);

   class ITelescope : public abcommon::IPoolInstance {
   public: // C++ factorys
      ABAUDELA_API static ITelescope*     createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]) throw(abcommon::IError);
      ABAUDELA_API static void            deleteInstance(ITelescope* telescope);
      ABAUDELA_API static int             getInstanceNo(ITelescope* telescope);
      ABAUDELA_API static ITelescope*     getInstance(int telescopeNo);
      ABAUDELA_API static abcommon::IIntArray* getIntanceNoList();
   public:
      enum MountSide { MOUNT_SIDE_AUTO, MOUNT_SIDE_EAST, MOUNTSIDE_WEST };

   public:
	   virtual 				                  ~ITelescope(){};
      virtual abcommon::ILogger*          getLogger()=0;

      virtual Alignment                   alignment_get() = 0;
      virtual void                        alignment_set(Alignment alignment) = 0;
      virtual void                        date_get(abmc::IDate* date)=0;
      virtual void                        date_set(abmc::IDate* date)=0;
      virtual double                      foclen_get() = 0;
      virtual void                        foclen_set(double foclen) = 0;

/*
      virtual void                        focus_blocking_set(boolean blocking) = 0;
      virtual double                      focus_coord() = 0;
      virtual void                        focus_goto(double position) = 0;
      virtual void                        focus_init(double position) = 0;
      virtual boolean                     focus_motor_get() = 0;
      virtual void                        focus_motor_set(boolean motor) = 0;
      virtual void                        focus_move(boolean increase) = 0;
      virtual void                        focus_rate_set(double rate) = 0;
      virtual void                        focus_stop() = 0;
*/      
      virtual void                        home_get(abmc::IHome* home)=0;
      virtual void                        home_set(abmc::IHome* home)=0;
      virtual const char *                home_name_get()=0;
      virtual void                        home_name_set(const char* homeNames)=0;
      virtual const char *                library_name_get() = 0;

      virtual int                         executeSpecificCommand(int argc, const char *argv[], char** result)=0;
      virtual void                        freeSpecificCommandResult(char* result)=0;
      virtual int                         executeTclSpecificCommand(void* interp, int argc, const char *argv[])=0;

      virtual const char *                name_get()=0;
      virtual const char *                port_name_get()=0;
      virtual const char *                product_get()=0;

      virtual abmc::ICoordinates*         radec_coord_get()=0;
	   virtual bool                        radec_coord_monitor_get() = 0;
	   virtual void                        radec_coord_monitor_start(TelescopeCallbackCoordType callback, void* clientData) = 0;
	   virtual void                        radec_coord_monitor_stop() = 0;
      virtual void                        radec_goto(abmc::ICoordinates*  radec, bool blocking, bool backslash)=0;
      virtual double                      radec_goto_rate_get()=0;
      virtual void                        radec_goto_rate_set(double rate)=0;
      virtual bool                        radec_guiding_get() = 0;
      virtual void                        radec_guiding_set(bool enabled) = 0;
      virtual void                        radec_init(abmc::ICoordinates*  radec, MountSide mountSide) = 0;
      virtual bool                        radec_model_enabled_get() = 0;
	   virtual void                        radec_model_enabled_set(bool enabled) = 0;
	   virtual void                        radec_move_start(Direction direction, double rate) = 0;
	   virtual void                        radec_move_stop(Direction direction) = 0;
      virtual void                        radec_guide_rate_get(double* raRate, double* decRate) = 0;
      virtual void                        radec_guide_rate_set(double raRate, double decRate) = 0;
      virtual void                        radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration, abaudela::Direction deltaDirection, double deltaDuration) = 0;
      virtual void                        radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance, abaudela::Direction deltaDirection, double deltaDistance) = 0;
      virtual bool                        radec_guide_pulse_moving_get() = 0;
      virtual bool                        radec_tracking_get()=0;
      virtual void                        radec_tracking_set(bool tracking)=0;
      virtual bool                        refraction_correction_get() = 0;

   };

   //  C factory 
   extern "C" ABAUDELA_API ITelescope*    ITelescope_createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]);
   extern "C" ABAUDELA_API void           ITelescope_deleteInstance(ITelescope* telescope);
   extern "C" ABAUDELA_API int            ITelescope_getInstanceNo(ITelescope* telescope);
   extern "C" ABAUDELA_API ITelescope*    ITelescope_getInstance(int telescopeNo);
   extern "C" ABAUDELA_API abcommon::IIntArray* ITelescope_getIntanceNoList();


   //-----------------------------------------------------------------------------
   //  Link
   //-----------------------------------------------------------------------------
   class ILink : public abcommon::IPoolInstance {
   public:
      ABAUDELA_API static ILink*       createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]) throw(abcommon::IError);
      ABAUDELA_API static void         deleteInstance(ILink* link);
      ABAUDELA_API static int          getInstanceNo(ILink* link);
      ABAUDELA_API static ILink*       getInstance(int linkNo);
      ABAUDELA_API static abcommon::IIntArray* getIntanceNoList();

   public:
      virtual 				~ILink(){};
      virtual const char* getLibraryName()=0;

   };

   //  C factory 
   extern "C" ABAUDELA_API ILink*      ILink_createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]);
   extern "C" ABAUDELA_API void        ILink_deleteInstance(ILink* link);
   extern "C" ABAUDELA_API int         ILink_getInstanceNo(ILink* link);
   extern "C" ABAUDELA_API ILink*      ILink_getInstance(int linkNo);
   extern "C" ABAUDELA_API abcommon::IIntArray* ILink_getIntanceNoList();

   //-----------------------------------------------------------------------------
   //  Mc
   //-----------------------------------------------------------------------------
   extern "C" ABAUDELA_API abmc::IMc * getMc();


   ///////////////////////////////////////////////////////////////
   // point d'entree de la librairie
   //
   ///////////////////////////////////////////////////////////////
  class  ABAUDELA_API  ILibaudela  {
   public:
      //static abcommon::IStructArray* getAvailableCamera(const char* librayPath, const char * libraryFileName);
   
      static void        cfa2Rgb(char* cfaFileName, char* rgbFileName, int interpolationMethod);

      static void        guideStart(int camNo, double exptime, AutoguiderDetectionType detection, 
                     double originX, double originY, double targetX, double targetY, double angle,
                     double targetBoxSize, 
                     int telNo, bool mountEnabled, double alphaSpeed, double deltaSpeed, bool alphaReverse, bool deltaReverse, bool declinaisonEnabled,
                     double seuilX, double seuilY, 
                     double slitWidth, double slitRatio, 
                     double intervalle, 
                     AutoguiderCallbackType guideCallback);

      static void        guideStop();

   };

   

   //  interface C
   extern "C" ABAUDELA_API   void        abaudela_cfa2Rgb(char* cfaFileName, char* rgbFileName, int interpolationMethod);
   
   extern "C" ABAUDELA_API   void        abaudela_guideStart(int camNo, double exptime, AutoguiderDetectionType detection, 
                                 double originX, double originY, double targetX, double targetY, double angle,
                                 double targetBoxSize, 
                                 int telNo, bool mountEnabled, double alphaSpeed, double deltaSpeed, bool alphaReverse, bool deltaReverse, bool declinaisonEnabled,
                                 double seuilX, double seuilY, 
                                 double slitWidth, double slitRatio, 
                                 double intervalle, 
                                 AutoguiderCallbackType guideCallback);
   
   extern "C" ABAUDELA_API   void        abaudela_guideStop();

   //extern "C" ABAUDELA_API   const char* abaudela_message(int errnum);


   extern "C" ABAUDELA_API void        IArray_deleteInstance(IArray* dataArray);
   extern "C" ABAUDELA_API int         IArray_size(IArray* dataArray);
   extern "C" ABAUDELA_API int         IIntArray_at(IIntArray* dataArray, int index);
   extern "C" ABAUDELA_API const char* IStringArray_at(IStringArray* dataArray, int index);
   extern "C" ABAUDELA_API void*       IStructArray_at(IStructArray* dataArray, int index);
   
   
} // namespace end



// codes d'erreur
#define ELIBSTD_BUF_EMPTY                  -1
#define ELIBSTD_NO_MEMORY_FOR_PIXELS       -2
#define ELIBSTD_NO_MEMORY_FOR_KWDS         -3
#define ELIBSTD_NO_MEMORY_FOR_ASTROMPARAMS -4
#define ELIBSTD_NO_KWDS                    -5
#define ELIBSTD_NO_NAXIS1_KWD              -6
#define ELIBSTD_NO_NAXIS2_KWD              -7
#define ELIBSTD_DEST_BUF_NOT_FOUND         -8
#define ELIBSTD_NO_ASTROMPARAMS            -9
#define ELIBSTD_NO_MEMORY_FOR_LUT          -10
#define ELIBSTD_CANNOT_CREATE_BUFFER       -11
#define ELIBSTD_CANT_GETORCREATE_TKIMAGE   -12
#define ELIBSTD_NO_ASSOCIATED_BUFFER       -13
#define ELIBSTD_NO_TKPHOTO_HANDLE          -14
#define ELIBSTD_NO_MEMORY_FOR_DISPLAY      -15
#define ELIBSTD_WIDTH_POSITIVE             -16
#define ELIBSTD_X1X2_NOT_IN_1NAXIS1        -17
#define ELIBSTD_HEIGHT_POSITIVE            -18
#define ELIBSTD_Y1Y2_NOT_IN_1NAXIS2        -19
#define ELIBSTD_KWD_NOT_FOUND              -20

#define ELIBSTD_PALETTE_CANT_FIND_FILE     -30
#define ELIBSTD_PALETTE_MALFORMED_FILE     -31
#define ELIBSTD_PALETTE_NOTCOMPLETE        -32
#define ELIBSTD_SUB_WINDOW_ALREADY_EXIST   -33
#define ELIBSTD_PIXEL_FORMAT_UNKNOWN       -34
#define ELIBSTD_CANT_OPEN_FILE				 -35
#define ELIBSTD_NO_NAXIS_KWD               -36

#define ELIBSTD_LIBTT_ERROR    				 -50

#define ELIBSTD_NOT_IMPLEMENTED				 -51

#define EFITSKW 								0x00010000
#define EFITSKW_NO_KWDS						(EFITSKW+1)
#define EFITSKW_INTERNAL_INVALID_ARG0  (EFITSKW+2)
#define EFITSKW_NO_SUCH_KWD				(EFITSKW+3)

// format des fichiers FITS
#ifndef BYTE_IMG
#define BYTE_IMG      8  /* BITPIX code values for FITS image types */
#define SHORT_IMG    16
#define LONG_IMG     32
#define FLOAT_IMG   -32
#define DOUBLE_IMG  -64
			 /* The following 2 codes are not true FITS         */
			 /* datatypes; these codes are only used internally */
			 /* within cfitsio to make it easier for users      */
			 /* to deal with unsigned integers.                 */
#define USHORT_IMG   20
#define ULONG_IMG    40
#endif
