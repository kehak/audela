
/**************************************************************************
 *
 *  $Id: mbgtime.h 1.17.1.7 2011/10/21 14:07:52 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for mbgtime.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgtime.h $
 *  Revision 1.17.1.7  2011/10/21 14:07:52  martin
 *  Changes for QNX.
 *  Revision 1.17.1.6  2011/05/06 09:03:12  martin
 *  Fix for DOS.
 *  Revision 1.17.1.5  2011/05/06 08:07:58Z  daniel
 *  include <time.h> for WIN32 target and firmware only
 *  Revision 1.17.1.4  2011/02/09 15:46:48Z  martin
 *  Revision 1.17.1.3  2011/01/24 17:09:20  martin
 *  Fixed build under FreeBSD.
 *  Revision 1.17.1.2  2010/08/13 11:57:13  martin
 *  Revision 1.17.1.1  2010/08/13 11:39:20Z  martin
 *  Revision 1.17  2010/08/06 13:03:03  martin
 *  Removed obsolete code.
 *  Revision 1.16  2010/07/16 10:22:07Z  martin
 *  Moved definitions of HNS_PER_SEC and HNS_PER_MS here.
 *  Conditionally define FILETIME_1970.
 *  Defined MASK_CLOCK_T for ARM/Cortex.
 *  Revision 1.15  2009/10/23 09:55:21  martin
 *  Added MJD numbers for commonly used epochs.
 *  Revision 1.14  2009/08/12 10:28:12  daniel
 *  Added definition NSECS_PER_SEC.
 *  Revision 1.13  2009/06/12 13:31:44Z  martin
 *  Fix build errors with arm-linux-gcc.
 *  Revision 1.12  2009/03/27 14:14:00  martin
 *  Cleanup for CVI.
 *  Revision 1.11  2009/03/13 09:30:06Z  martin
 *  Include mystd.h in mbgtime.c rather than here. The bit type used
 *  here is now defined in words.h.
 *  Updated comments for GPS_SEC_BIAS.
 *  Revision 1.10  2008/12/11 10:45:41Z  martin
 *  Added clock_t mask for gcc (GnuC).
 *  Revision 1.9  2006/08/25 09:33:46Z  martin
 *  Updated function prototypes.
 *  Revision 1.8  2004/12/28 11:29:02Z  martin
 *  Added macro _n_days.
 *  Updated function prototypes.
 *  Revision 1.7  2002/09/06 07:15:48Z  martin
 *  Added MASK_CLOCK_T for Linux.
 *  Revision 1.6  2002/02/25 08:37:44  Andre
 *  definition MASK_CLOCK_T for ARM added
 *  Revision 1.5  2001/03/02 10:18:10Z  MARTIN
 *  Added MASK_CLOCK_T for Watcom C.
 *  Revision 1.4  2000/09/15 07:57:53  MARTIN
 *  Removed outdated function prototypes.
 *  Revision 1.3  2000/07/21 14:05:18  MARTIN
 *  Defined some new constants.
 *
 **************************************************************************/

#ifndef _MBGTIME_H
#define _MBGTIME_H


/* Other headers to be included */

#include <gpsdefs.h>

#if _IS_MBG_FIRMWARE \
  || defined( MBG_TGT_WIN32 ) \
  || defined( MBG_TGT_DOS ) \
  || defined( MBG_TGT_QNX_NTO )
  #include <time.h>
#endif


#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MBGTIME
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */


// The Unix time_t epoche is usually 1970-01-01 00:00 whereas
// the GPS epoche is 1980-01-06 00:00, so the difference is 10 years,
// plus 2 days due to leap years (1972 and 1976), plus the difference
// of the day-of-month (6 - 1).
#define GPS_SEC_BIAS  315964800UL     // ( ( ( 10UL * 365UL ) + 2 + 5 ) * SECS_PER_DAY )

// time_t t = ( gps_week * SECS_PER_WEEK ) + sec_of_week + GPS_SEC_BIAS


// Modified Julian Day (MJD) numbers for some commonly used epochs.
// To compute the MJD for a given date just compute the days since epoch
// and add the constant number of days according to the epoch, e.g.:
//   current_unix_mjd = ( time( NULL ) / SECS_PER_DAY ) + MJD_AT_UNIX_EPOCH;
#define MJD_AT_GPS_EPOCH    44244UL    // MJD at 1980-01-06
#define MJD_AT_UNIX_EPOCH   40587UL    // MJD at 1970-01-01
#define MJD_AT_NTP_EPOCH    40587UL    // MJD at 1900-01-01


// The constant below defines the Windows FILETIME number (100 ns intervals
// since 1601-01-01) for 1970-01-01, which is usually the epoche for the time_t
// type used by the standard C library.
#if !defined( FILETIME_1970 )
  // FILETIME represents a 64 bit number, so we need to defined the
  // constant with an appendix depending on the compiler.
  #if MBG_TGT_C99 || defined( __GNUC__ )
    // syntax introduced by C99 standard
    #define FILETIME_1970    0x019db1ded53e8000ULL  // Epoch offset from FILETIME to UNIX
  #elif defined( MBG_TGT_WIN32 )
    // MSC-specific syntax
    #define FILETIME_1970    0x019db1ded53e8000ui64
  #endif
#endif


#if defined( _C166 )
  #if _C166 >= 50
    #define MASK_CLOCK_T 0x7FFFFFFFL
  #else
    #define MASK_CLOCK_T 0x7FFF   /* time.h not shipped with compiler */
  #endif
#endif

#if defined( __WATCOMC__ )
  #define MASK_CLOCK_T 0x7FFFFFFFL
#endif

#if defined( _CVI ) || defined( _CVI_ )
  #define MASK_CLOCK_T 0x7FFFFFFFL
#endif

#if defined( _MSC_VER )
  #define MASK_CLOCK_T 0x7FFFFFFFL
#endif

#if defined( __NETWARE_386__ )
  #define MASK_CLOCK_T 0x7FFFFFFFL
#endif

#if defined( __ARM )
  #define MASK_CLOCK_T 0x7FFFFFFFL
#endif

#if defined( __ARMCC_VERSION )
  #define MASK_CLOCK_T ( ( (ulong) (clock_t) -1 ) >> 1 )
#endif

#if defined( __GNUC__ )
  #if defined( __linux )
    #define MASK_CLOCK_T ( ( (ulong) (clock_t) -1 ) >> 1 )
  #else  // Windows / MinGW
    #define MASK_CLOCK_T 0x7FFFFFFFL
  #endif
#endif


#if !defined( MASK_CLOCK_T )
  #if sizeof( clock_t ) == sizeof( short )
    #define MASK_CLOCK_T 0x7FFF
  #elif sizeof( clock_t ) == sizeof( long )
    #define MASK_CLOCK_T 0x7FFFFFFFL
  #endif
#endif

typedef struct
{
  clock_t start;
  clock_t stop;
  short is_set;
} TIMEOUT;


#define DAYS_PER_WEEK     7

#define SECS_PER_MIN      60
#define MINS_PER_HOUR     60
#define HOURS_PER_DAY     24
#define DAYS_PER_WEEK     7

#define MINS_PER_DAY      ( MINS_PER_HOUR * HOURS_PER_DAY )

#define SECS_PER_HOUR     3600
#define SECS_PER_DAY      86400L
#define SECS_PER_WEEK     604800L

#define SEC100S_PER_SEC   100L
#define SEC100S_PER_MIN   ( SEC100S_PER_SEC * SECS_PER_MIN )
#define SEC100S_PER_HOUR  ( SEC100S_PER_SEC * SECS_PER_HOUR )
#define SEC100S_PER_DAY   ( SEC100S_PER_SEC * SECS_PER_DAY )

#if !defined( MSEC_PER_SEC )
  #define MSEC_PER_SEC   1000L
#endif

#define MSEC_PER_MIN   ( MSEC_PER_SEC * SECS_PER_MIN )
#define MSEC_PER_HOUR  ( MSEC_PER_SEC * SECS_PER_HOUR )
#define MSEC_PER_DAY   ( MSEC_PER_SEC * SECS_PER_DAY )

#define NSECS_PER_SEC     1000000000UL  

#if !defined( HNS_PER_SEC )
  #define HNS_PER_SEC       10000000UL
#endif

#if !defined( HNS_PER_MS )
  #define HNS_PER_MS          10000UL
#endif



_ext TM_GPS dhms;
_ext TM_GPS datum;


_ext const char *short_time_fmt
#ifdef _MBGTIME
 = "%2i:%02i"
#endif
;

_ext const char *time_fmt
#ifdef _MBGTIME
 = "%2i:%02i:%02i"
#endif
;

_ext const char *long_time_fmt
#ifdef _MBGTIME
 = "%2i:%02i:%02i.%02i"
#endif
;

_ext const char *date_fmt
#ifdef _MBGTIME
 = "%2i.%02i.%04i"
#endif
;

_ext const char *day_date_fmt
#ifdef _MBGTIME
 = "%s, %2i.%02i.%04i"
#endif
;

_ext const char *day_name_eng[]
#ifdef _MBGTIME
 = { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" }
#endif
;

_ext const char *day_name_ger[]
#ifdef _MBGTIME
 = { "So", "Mo", "Di", "Mi", "Do", "Fr", "Sa" }
#endif
;

_ext const TM_GPS init_tm
#ifdef _MBGTIME
  = { 1980, 1, 1, 0, 0, 0, 0, 0, 0, 0 }
#endif
;


_ext char days_of_month[2][12]
#ifdef _MBGTIME
 = {
     { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 },
     { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
   }
#endif
;


// simplify call to n_days with structures
#define _n_days( _s ) \
  n_days( (_s)->mday, (_s)->month, (_s)->year )


/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 void set_timeout( TIMEOUT *t, clock_t clk, clock_t interval ) ;
 void stretch_timeout( TIMEOUT *t, clock_t interval ) ;
 bit check_timeout( TIMEOUT *t, clock_t clk ) ;
 int err_tm( TM_GPS *tm ) ;
 TM_GPS *clear_time( TM_GPS *tm ) ;
 TM_GPS *wsec_to_tm( long wsec, TM_GPS *tm ) ;
 long tm_to_wsec( TM_GPS *tm ) ;
 int is_leap_year( int y ) ;
 int day_of_year( int day, int month, int year ) ;
 void date_of_year ( int year, int day_num, TM_GPS *tm ) ;
 int day_of_week( int day, int month, int year ) ;
 int days_to_years( long *day_num, int year ) ;
 long n_days( ushort mday, ushort month, ushort year ) ;
 double nano_time_to_double( const NANO_TIME *p ) ;
 void double_to_nano_time( NANO_TIME *p, double d ) ;
 int sprint_time( char *s, const TM_GPS *tm ) ;
 int sprint_short_time( char *s, TM_GPS *time ) ;
 int sprint_date( char *s, const TM_GPS *tm ) ;
 int sprint_day_date( char *s, const TM_GPS *tm ) ;
 int sprint_tm( char *s, const TM_GPS *tm ) ;
 void sscan_time( char *s, TM_GPS *tm ) ;
 void sscan_date( char *s, TM_GPS *tm ) ;

/* ----- function prototypes end ----- */


/* End of header body */


#undef _ext

#ifdef __cplusplus
}
#endif


#endif  /* _MBGTIME_H */
