
/**************************************************************************
 *
 *  $Id: mbggeo.h 1.11 2011/06/22 10:18:10 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for mbggeo.c.
 *
 *  Terms used:
 *
 *     WGS84   world geodetic system of 1984
 *
 *     XYZ     WGS84 earth centered, earth fixed (ECEF) kartesian
 *             coordinates
 *
 *     LLA     longitude, latitude, altitude depending on the reference
 *             ellipsoid used.
 *
 *     DMS     degrees, minutes, seconds
 *
 * -----------------------------------------------------------------------
 *  $Log: mbggeo.h $
 *  Revision 1.11  2011/06/22 10:18:10  martin
 *  Cleaned up handling of pragma pack().
 *  Revision 1.10  2008/09/03 14:54:28  martin
 *  Added macros to swap endianess of structures.
 *  Revision 1.9  2008/01/17 09:31:33  daniel
 *  Made comments compatible for doxygen parser.
 *  No sourcecode changes.
 *  Revision 1.8  2004/11/09 14:16:00Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Revision 1.7  2003/02/14 13:23:04Z  martin
 *  Omit inclusion of mystd.h.
 *  Revision 1.6  2003/01/13 15:17:15  martin
 *  Structures were defined with default alignment which 
 *  could result in different data sizes on different platforms.
 *  Revision 1.5  2002/12/18 14:46:41Z  martin
 *  Removed variable USER_POS meinberg.
 *  Updated function prototypes.
 *  Revision 1.4  2002/12/12 12:04:25Z  martin
 *  Moved some definitions here.
 *  Use standard file format.
 *
 **************************************************************************/

#ifndef _MBGGEO_H
#define _MBGGEO_H


/* Other headers to be included */

#include <gpsdefs.h>
#include <use_pack.h>

#ifdef _MBGGEO
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


/**
 Geographic longitude or latitude in [degrees, minutes, seconds] 
 longitude East latitude North and positve, South or West angles negative
 */
typedef struct
{
  uint16_t prefix;  /**< 'N', 'E', 'S' or 'W' */
  uint16_t deg;     /**< [0...90 (lat) or 0...180 (lon)] */
  uint16_t min;     /**< [0...59] */
  double sec;       /**< [0...59.999] */
} DMS;

// The corresponding macro _mbg_swab_dms() is defined in gpsdefs.h.
#define _mbg_swab_dms( _p )        \
{                                  \
  _mbg_swab16( &(_p)->prefix );    \
  _mbg_swab16( &(_p)->deg );       \
  _mbg_swab16( &(_p)->min );       \
  _mbg_swab_double( &(_p)->sec );  \
}



typedef struct
{
  XYZ xyz;           /**< always WGS84 ECEF coordinates */
  LLA lla;           /**< depending on the ellipsoid used for reference */
  DMS longitude;     /**< longitude in degrees, minutes, seconds */
  DMS latitude;      /**< latitude in degrees, minutes, seconds */
  int16_t ellipsoid; /**< ellipsoid used for reference */
} POS;

#define _mbg_swab_pos( _p )           \
{                                     \
  _mbg_swab_xyz( (_p)->xyz );         \
  _mbg_swab_lla( (_p)->lla );         \
  _mbg_swab_dms( &(_p)->longitude );  \
  _mbg_swab_dms( &(_p)->latitude );   \
  _mbg_swab16( &(_p)->ellipsoid );    \
}



typedef struct
{
  CSUM csum;        /* checksum of the remaining bytes */
  int16_t valid;    /* flag data are valid */

  char name[40];
  POS pos;          /* the position in WGS84 ECEF coords and LLA */
  double det;


/* The components below hold the results of intermediate terms */
/* computed in complete_user_pos(). */

/* The sin.., cos.., nt.. and ut.. variables are used to compute the */
/* enu_dcos[] parameters of a SV structure in xyz_to_ead(). */

/* The e_radius.. variables are used to compute the latitude, longitude */
/* and altitude from ECEF coordinates in lla_to_xyz(). */

  double sin_lat;        /* sin( latitude ) */
  double cos_lat;        /* cos( latitude ) */
  double sin_lon;        /* sin( longitude ) */
  double cos_lon;        /* cos( longitude ) */

  double nt1;            /* -sin_lat * cos_lon */
  double nt2;            /* -sin_lat * sin_lon */
  double utx;            /*  cos_lat * cos_lon */
  double uty;            /*  cos_lat * sin_lon */

  double e_radius;       /* N */
  double e_radius_alt;   /* N + h */

} USER_POS;



typedef struct
{
  CSUM csum;        /* checksum of the remaining bytes */
  int16_t valid;    /* flag data are valid */

  char name[40];
  XYZ dxyz;            /* offset from the WGS84 ECEF coords */
  double a;            /* semi major axis */
  double rcp_f;        /* reciproke of flatness */

/* the variables below will be computed in the init_mbggeo() function: */

  double f;            /* flatness */
  double b;            /* semi minor axis */
  double sqr_e;        /* square of numerical eccentricity */
} ELLIPSOID;



enum { WGS84, BESSEL, N_ELLIPSOIDS };

_ext ELLIPSOID ellipsoid[N_ELLIPSOIDS]
#ifdef _DO_INIT
 = { { 0, 0,
       "WGS 84",
       { 0.0, 0.0, 0.0 },
       6378137.0,
       298.257223563
     },

     { 0, 0,
       "Bessel",
       { -128.0, 481.0, 664.0 },
       6377397.0,
       299.15
     }

   }
#endif
;


/* WGS84 constants used */

_ext double OMEGADOTe   /* earth's rotation rate  [rad/sec] */
#ifdef _DO_INIT
  = 7.2921151467e-5
#endif
;

_ext double mue         /* earth's gravitational constant  [m^3/sec^2] */
#ifdef _DO_INIT
  = 3.986005e14
#endif
;



_ext double vr_to_doppler;


_ext double gps_pi
#ifdef _DO_INIT
  = 3.1415926535898
#endif
;

_ext double gps_c0
#ifdef _DO_INIT
  = 2.99792458e8
#endif
;


#ifndef PI
  #define PI 3.1415926535897932
#endif


_ext double pi
#ifdef _DO_INIT
 = PI
#endif
;


_ext double r2d
#ifdef _DO_INIT
  = 180.0 / PI
#endif
;


_ext double d2r
#ifdef _DO_INIT
  = PI / 180.0
#endif
;


/* variables for simplifying computations */

_ext double gps_two_pi;
_ext double sqrt_mue;         /* sqrt( mue )  */



/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 void dms_to_rad( const DMS *dms, double *rad ) ;
 void rad_to_dms( const double *rad, DMS *dms, const char prefix ) ;
 void dms_to_lla( POS *pos ) ;
 void lla_to_dms( POS *pos ) ;
 void lla_to_xyz( USER_POS *pos ) ;
 void xyz_to_lla( POS *pos, void (*cyclic_func)( void ) ) ;
 void dms_to_xyz( USER_POS *pos ) ;
 void setup_user_pos_from_dms( USER_POS *user ) ;
 void setup_user_pos_from_lla( USER_POS *user ) ;
 void setup_user_pos_from_xyz( USER_POS *user, void (*cyclic_func)( void ) ) ;
 double distance( XYZ xyz_1, XYZ xyz_2 ) ;
 void init_mbggeo( void ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _MBGGEO_H */

