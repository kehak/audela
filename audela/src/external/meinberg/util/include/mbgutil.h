
/**************************************************************************
 *
 *  $Id: mbgutil.h 1.16.1.2 2011/06/22 10:21:57 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions used with mbgutil.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgutil.h $
 *  Revision 1.16.1.2  2011/06/22 10:21:57  martin
 *  Cleaned up handling of pragma pack().
 *  Revision 1.16.1.1  2011/02/09 15:27:23  martin
 *  Include stdlib.h.
 *  Revision 1.16  2009/08/14 10:11:53Z  daniel
 *  New version code 306, compatibility version still 110.
 *  Revision 1.15  2009/06/09 08:57:47Z  daniel
 *  Rev No. 305
 *  Revision 1.14  2009/03/19 09:06:00Z  daniel
 *  New version code 304, compatibility version still 110.
 *  Revision 1.13  2009/01/12 09:35:41Z  daniel
 *  New version code 303, compatibility version still 110.
 *  Updated function prototypes.
 *  Revision 1.12  2008/01/17 10:15:26Z  daniel
 *  New version code 302, compatibility version still 110.
 *  Revision 1.11  2007/10/16 10:01:17Z  daniel
 *  New version code 301, compatibility version still 110.
 *  Revision 1.9  2007/03/21 16:48:31Z  martin
 *  New version code 219, compatibility version still 110.
 *  Revision 1.8  2006/08/09 13:18:18Z  martin
 *  New version code 218, compatibility version still 110.
 *  Revision 1.7  2006/06/08 10:48:52Z  martin
 *  New version code 217, compatibility version still 110.
 *  Added macro _mbg_strncpy().
 *  Revision 1.6  2006/05/10 10:56:54Z  martin
 *  Updated function prototypes.
 *  Revision 1.5  2006/05/02 13:24:49Z  martin
 *  New version code 216, compatibility version still 110.
 *  Revision 1.4  2006/01/11 12:24:05Z  martin
 *  New version code 215, compatibility version still 110.
 *  Revision 1.3  2005/12/15 10:01:51Z  martin
 *  New version 214, compatibility version still 110.
 *  Revision 1.2  2005/02/18 15:13:42Z  martin
 *  Updated function prototypes.
 *  Revision 1.1  2005/02/18 10:39:49Z  martin
 *  Initial revision
 *
 **************************************************************************/

#ifndef _MBGUTIL_H
#define _MBGUTIL_H


/* Other headers to be included */

#include <mbg_tgt.h>
#include <use_pack.h>
#include <pcpsdefs.h>
#include <mbggeo.h>
#include <pci_asic.h>

#include <stdlib.h>


#define MBGUTIL_VERSION         0x0306

#define MBGUTIL_COMPAT_VERSION  0x0110


#if defined( MBG_TGT_WIN32 )

  #include <windows.h>

#elif defined( MBG_TGT_LINUX )


#elif defined( MBG_TGT_OS2 )


#elif defined( MBG_TGT_DOS )

  #if !defined( MBG_USE_DOS_TSR )
  #endif

#else

#endif

#ifdef _MBGUTIL
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


#if defined( MBG_TGT_WIN32 )

#elif defined( MBG_TGT_LINUX )

#elif defined( MBG_TGT_OS2 )

#else

#endif



/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

// The macro below can be used to simplify the API call if
// a string variable is used rather than a char *.
#define _mbg_strncpy( _s, _src ) \
  mbg_strncpy( _s, sizeof( _s ), _src )


/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 _MBG_API_ATTR int _MBG_API mbgutil_get_version( void ) ;
 _MBG_API_ATTR int _MBG_API mbgutil_check_version( int header_version ) ;
 _MBG_API_ATTR int _MBG_API mbg_snprintf( char *s, size_t max_len, const char * fmt, ... ) ;
 _MBG_API_ATTR int _MBG_API mbg_strncpy( char *s, size_t max_len, const char *src ) ;
 _MBG_API_ATTR int _MBG_API mbg_strchar( char *s, size_t max_len, char c, size_t n ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_date_short( char *s, int max_len,  int mday, int month ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_date( char *s, int max_len,  int mday, int month, int year ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_time_short( char *s, int max_len,  int hour, int min ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_time( char *s, int max_len, int hour, int min, int sec ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_time_long( char *s, int max_len, int hour, int min, int sec, int sec100 ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_tm_gps_date_time( char *s, int max_len, const TM_GPS *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_date_short( char *s, int max_len,  const PCPS_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_date( char *s, int max_len,  const PCPS_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_time_short( char *s, int max_len, const PCPS_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_time( char *s, int max_len, const PCPS_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_time_long( char *s, int max_len, const PCPS_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_date_time( char *s, int max_len,  const PCPS_TIME *pt,  const char *tz_str ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_date( char *s, int max_len,  uint32_t sec ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time( char *s, int max_len,  uint32_t sec ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_date_time_utc( char *s, int max_len,  const PCPS_HR_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_date_time_loc( char *s, int max_len,  const PCPS_HR_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time_frac( char *s, int max_len,  uint32_t frac ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time_offs( char *s, int max_len,  const PCPS_HR_TIME *pt, const char *info ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_tstamp_utc( char *s, int max_len,  const PCPS_HR_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_tstamp_loc( char *s, int max_len,  const PCPS_HR_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_tstamp_raw( char *s, int max_len,  const PCPS_TIME_STAMP *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time_raw( char *s, int max_len,  const PCPS_HR_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_ucap( char *s, int max_len,  const PCPS_HR_TIME *pt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pos_dms( char *s, int max_len,  const DMS *pdms, int prec ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pos_alt( char *s, int max_len, double alt ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_pos( char *s, int max_len,  const POS *ppos, int prec ) ;
 _MBG_API_ATTR int _MBG_API mbg_str_dev_name( char *s, int max_len, const char *short_name,  uint16_t fw_rev_num, PCI_ASIC_VERSION asic_version_num ) ;

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

#endif  /* _MBGUTIL_H */

