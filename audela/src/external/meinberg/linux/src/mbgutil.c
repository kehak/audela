
/**************************************************************************
 *
 *  $Id: mbgutil.c 1.5.2.3 2011/11/28 14:24:44 daniel TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Utility function used by Meinberg device drivers.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgutil.c $
 *  Revision 1.5.2.3  2011/11/28 14:24:44  daniel
 *  Fixed firmware and asic version string
 *  Revision 1.5.2.2  2011/09/21 16:01:18Z  martin
 *  Revision 1.5.2.1  2010/07/15 13:06:59  martin
 *  Revision 1.5  2009/03/19 09:09:55Z  daniel
 *  Fixed ambiguous syntax in mbg_str_dev_name().
 *  Support TAI and GPS time scales in mbg_str_pcps_hr_tstamp_loc().
 *  In mbg_str_pcps_hr_time_offs() append offset only if != 0.
 *  Revision 1.4  2009/01/12 09:34:12Z  daniel
 *  Added function mbg_str_dev_name().
 *  Revision 1.3  2006/05/10 10:57:44Z  martin
 *  Generally use and export mbg_snprintf().
 *  Revision 1.2  2005/02/18 15:12:13Z  martin
 *  Made functions mbg_strncpy() and mbg_strchar() public.
 *  New function mbg_str_tm_gps_date_time().
 *  Don't expand year number if already expanded.
 *  Revision 1.1  2005/02/18 10:39:49Z  martin
 *  Initial revision
 *
 **************************************************************************/

#define _MBGUTIL
 #include <mbgutil.h>
#undef _MBGUTIL

#include <pcpsutil.h>
#include <pcpslstr.h>
#include <pcpsdev.h>

#include <stdio.h>
#include <time.h>

// required at least for Linux:
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>


#if defined( MBG_TGT_WIN32 )
  #include <tchar.h>
#else
//  #include <>
#endif


static int mbg_date_time_dist = 2;
//##++ static int mbg_time_tz_dist = 1;
static int mbg_pos_dist = 2;

static uint16_t mbg_year_lim = 1980;


#if defined( MBG_TGT_WIN32 )
  #define mbg_vsnprintf _vsnprintf
#else
  #define mbg_vsnprintf vsnprintf
#endif


#if defined( MBG_TGT_DOS )

static /*HDR*/
int vsnprintf( char *s, int max_len, const char *fmt, va_list arg_list )
{
  return vsprintf( s, fmt, arg_list );

}  // vsnprintf

#endif



/*HDR*/
_MBG_API_ATTR int _MBG_API mbgutil_get_version( void )
{

  return MBGUTIL_VERSION;

}  // mbgutil_get_version



/*HDR*/
_MBG_API_ATTR int _MBG_API mbgutil_check_version( int header_version )
{
  if ( header_version >= MBGUTIL_COMPAT_VERSION )
    return PCPS_SUCCESS;

  return -1;

}  // mbgutil_check_version



// We have our own version of snprintf() since under Windows 
// _snprintf(), returns -1 and does not write a terminating 0 
// if the output exceeds the buffer size. 
// 
// This function terminates the output string properly. However,
// the maximum return value is (max_len - 1), so the function
// can not be used to determine the buffer size that would be 
// required for an untruncated string. 

/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_snprintf( char *s, size_t max_len, const char * fmt, ... )
{
  int n;

  va_list ap;

  va_start( ap, fmt );

  n = mbg_vsnprintf( s, max_len, fmt, ap );
 
  va_end( ap );


  #if defined( MBG_TGT_WIN32 )

    // Terminate the output string properly under Windows.
    // For other targets assume the POSIX version is available.
    if ( n < 0 || n >= (int) max_len )
    {
      n = max_len - 1;
      s[n] = 0;
    }

  #endif


  return n;

}  // mbg_snprintf



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_strncpy( char *s, size_t max_len, const char *src )
{
  //##++ This could be coded more efficiently
  return mbg_snprintf( s, max_len, "%s", src );

}  // mbg_strncpy



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_strchar( char *s, size_t max_len, char c, size_t n )
{
  size_t i;

  max_len--;

  for ( i = 0; i < n; i++ )
  {
    if ( i >= max_len )
      break;

    s[i] = c;
  }

  s[i] = 0;

  return i;

}  // mbg_strchar



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_date_short( char *s, int max_len, 
                                               int mday, int month )
{
  return mbg_snprintf( s, max_len, "%02u.%02u.", mday, month );
  
}  // mbg_str_date_short



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_date( char *s, int max_len, 
                                         int mday, int month, int year )
{
  int n = mbg_str_date_short( s, max_len, mday, month );
  n += mbg_snprintf( s + n, max_len - n, "%04u",
                     ( year < 256 ) ?    
                       pcps_exp_year( (uint8_t) year, mbg_year_lim ) :
                       year
                   );
  return n;

}  // mbg_str_date



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_time_short( char *s, int max_len, 
                                               int hour, int min )
{
  return mbg_snprintf( s, max_len, "%2u:%02u", hour, min );

}  // mbg_str_time_short



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_time( char *s, int max_len,
                                         int hour, int min, int sec )
{
  int n = mbg_str_time_short( s, max_len, hour, min );

  n += mbg_snprintf( s + n, max_len - n, ":%02u", sec );

  return n;

}  // mbg_str_time



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_time_long( char *s, int max_len,
                                              int hour, int min, int sec, int sec100 )
{
  int n = mbg_str_time( s, max_len, hour, min, sec );

  n += mbg_snprintf( s + n, max_len - n, ".%02u", sec100 );

  return n;

}  // mbg_str_time_long



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_tm_gps_date_time( char *s, int max_len,
                                                     const TM_GPS *pt )
{
  int n = mbg_str_date( s, max_len, pt->mday, pt->month, pt->year );
  n += mbg_strchar( s + n, max_len - n, ' ', mbg_date_time_dist );
  n += mbg_str_time( s + n, max_len - n, pt->hour, pt->min, pt->sec );

  return n;

}  // mbg_str_tm_gps_date_time



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_date_short( char *s, int max_len, 
                                                    const PCPS_TIME *pt )
{
  return mbg_str_date_short( s, max_len, pt->mday, pt->month );

}  // mbg_str_pcps_date_short



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_date( char *s, int max_len, 
                                              const PCPS_TIME *pt )
{
  return mbg_str_date( s, max_len, pt->mday, pt->month, pt->year );

}  // mbg_str_pcps_date



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_time_short( char *s, int max_len,
                                                    const PCPS_TIME *pt )
{
  return mbg_str_time_short( s, max_len, pt->hour, pt->min );

}  // mbg_str_pcps_time_short



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_time( char *s, int max_len,
                                              const PCPS_TIME *pt )
{
  return mbg_str_time( s, max_len, pt->hour, pt->min, pt->sec );

}  // mbg_str_pcps_time



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_time_long( char *s, int max_len,
                                                   const PCPS_TIME *pt )
{
  return mbg_str_time_long( s, max_len, pt->hour, pt->min, pt->sec, pt->sec100 );

}  // mbg_str_pcps_time_long



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_date_time( char *s, int max_len, 
                                                   const PCPS_TIME *pt, 
                                                   const char *tz_str )
{
  int n = mbg_str_pcps_date( s, max_len, pt );
  n += mbg_strchar( s + n, max_len - n, ' ', mbg_date_time_dist );
  n += mbg_str_pcps_time( s + n, max_len - n, pt );

  return n;
  
}  // mbg_str_pcps_date_time



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_date( char *s, int max_len, 
                                                 uint32_t sec )
{
  time_t t = sec;
  struct tm tm = *gmtime( &t );
  return mbg_str_date( s, max_len, tm.tm_mday, tm.tm_mon + 1, tm.tm_year );

}  // mbg_str_pcps_hr_date



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time( char *s, int max_len, 
                                                 uint32_t sec )
{
  time_t t = sec;
  struct tm tm = *gmtime( &t );
  return mbg_str_time( s, max_len, tm.tm_hour, tm.tm_min, tm.tm_sec );

}  // mbg_str_pcps_hr_time



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_date_time_utc( char *s, int max_len, 
                                                          const PCPS_HR_TIME *pt )
{
  time_t t = pt->tstamp.sec;
  struct tm tm = *gmtime( &t );
  int n = mbg_str_date( s, max_len, tm.tm_mday , tm.tm_mon + 1, tm.tm_year );
  n += mbg_strchar( s + n, max_len - n, ' ', mbg_date_time_dist );
  n += mbg_str_time( s + n, max_len - n, tm.tm_hour, tm.tm_min, tm.tm_sec );

  return n;

}  // mbg_str_pcps_hr_date_time_utc



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_date_time_loc( char *s, int max_len, 
                                                          const PCPS_HR_TIME *pt )
{
  time_t t = pt->tstamp.sec + pt->utc_offs;
  struct tm tm = *gmtime( &t );
  int n = mbg_str_date( s, max_len, tm.tm_mday , tm.tm_mon + 1, tm.tm_year );
  n += mbg_strchar( s + n, max_len - n, ' ', mbg_date_time_dist );
  n += mbg_str_time( s + n, max_len - n, tm.tm_hour, tm.tm_min, tm.tm_sec );

  return n;

}  // mbg_str_pcps_hr_date_time_loc



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time_frac( char *s, int max_len, 
                                                      uint32_t frac )
{
  return mbg_snprintf( s, max_len, PCPS_HRT_FRAC_SCALE_FMT,
                       frac_sec_from_bin( frac, PCPS_HRT_FRAC_SCALE ) );

}  // mbg_str_pcps_hr_time_frac



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time_offs( char *s, int max_len, 
                                                      const PCPS_HR_TIME *pt,
                                                      const char *info )
{
  int n = mbg_snprintf( s, max_len, "%s", info );

  if ( pt->utc_offs )
  {
    ldiv_t ldt = ldiv( labs( pt->utc_offs ) / 60, 60 );

    n += mbg_snprintf( s + n, max_len - n, "%c%02u:%02uh",
                       ( pt->utc_offs < 0 ) ? '-' : '+',
                       ldt.quot, ldt.rem );
  }

  return n;

}  // mbg_str_pcps_hr_time_offs



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_tstamp_utc( char *s, int max_len, 
                                                       const PCPS_HR_TIME *pt )
{
  int n = mbg_str_pcps_hr_date_time_utc( s, max_len, pt );

  if ( n < ( max_len - 1 ) )
  {
    s[n++] = '.';
    n += mbg_str_pcps_hr_time_frac( s + n, max_len - n, pt->tstamp.frac );
  }

  return n;

}  // mbg_str_pcps_hr_tstamp_utc



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_tstamp_loc( char *s, int max_len, 
                                                       const PCPS_HR_TIME *pt )
{
  int n = mbg_str_pcps_hr_date_time_loc( s, max_len, pt );

  if ( n < ( max_len - 1 ) )
  {
    s[n++] = '.';
    n += mbg_str_pcps_hr_time_frac( s + n, max_len - n, pt->tstamp.frac );
  }

  if ( n < ( max_len - 1 ) )
  {
    const char *cp = "UTC";

    if ( pt->status & PCPS_SCALE_TAI )
      cp = "TAI";
    else
      if ( pt->status & PCPS_SCALE_GPS )
        cp = "GPS";

    s[n++] = ' ';
    n += mbg_str_pcps_hr_time_offs( s + n, max_len - n, pt, cp );
  }

  return n;

}  // mbg_str_pcps_hr_tstamp_loc



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_tstamp_raw( char *s, int max_len, 
                                                    const PCPS_TIME_STAMP *pt )
{
  return mbg_snprintf( s, max_len, "%08lX.%08lX", pt->sec, pt->frac );

}  // mbg_str_pcps_tstamp_raw



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pcps_hr_time_raw( char *s, int max_len, 
                                                     const PCPS_HR_TIME *pt )
{
  int n = mbg_str_pcps_tstamp_raw( s, max_len, &pt->tstamp );
  n += mbg_str_pcps_hr_time_offs( s + n, max_len - n, pt, ", Loc: " );
  n += mbg_snprintf( s + n, max_len - n, ", st: 0x%04X", pt->status );

  return n;
  
}  // mbg_str_pcps_hr_time_raw



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_ucap( char *s, int max_len, 
                                         const PCPS_HR_TIME *pt )
{
  int n = mbg_snprintf( s, max_len, "CAP%u: ", pt->signal );
  n += mbg_str_pcps_hr_tstamp_loc( s + n, max_len - n, pt );

  return n;
  
}  // mbg_str_ucap



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pos_dms( char *s, int max_len, 
                                            const DMS *pdms, int prec )
{
  return mbg_snprintf( s, max_len, "%c %i" DEG "%02i'%02.*f\"",
                       pdms->prefix,
                       pdms->deg,
                       pdms->min,
                       prec,
                       pdms->sec
                     );

}  // mbg_str_pos_dms



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pos_alt( char *s, int max_len, double alt )
{
  return mbg_snprintf( s, max_len, "%.0fm", alt );

}  // mbg_str_pos_alt



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_pos( char *s, int max_len, 
                                        const POS *ppos, int prec )
{
  int n;

  if ( ppos->lla[LON] || ppos->lla[LAT] || ppos->lla[ALT] )
  {
    n = mbg_str_pos_dms( s, max_len, &ppos->latitude, prec );
    n += mbg_strchar( s + n, max_len - n, ',', 1 );
    n += mbg_strchar( s + n, max_len - n, ' ', mbg_pos_dist );
    n += mbg_str_pos_dms( s + n, max_len - n, &ppos->longitude, prec );
    n += mbg_strchar( s + n, max_len - n, ',', 1 );
    n += mbg_strchar( s + n, max_len - n, ' ', mbg_pos_dist );
    n += mbg_str_pos_alt( s + n, max_len - n, ppos->lla[ALT] );
  }
  else
    n = mbg_strncpy( s, max_len, "N/A" );

  return n;

}  // mbg_str_pos



/*HDR*/
_MBG_API_ATTR int _MBG_API mbg_str_dev_name( char *s, int max_len, const char *short_name, 
                                             uint16_t fw_rev_num, PCI_ASIC_VERSION asic_version_num )
{
  #define HW_NAME_SZ PCPS_CLOCK_NAME_SZ+PCPS_SN_SIZE+1

  char model_code[HW_NAME_SZ];
  PCPS_SN_STR sernum;
  unsigned int i = 0;
  int n = 0;

  memset( model_code, 0, sizeof( model_code ) );
  memset( sernum, 0, sizeof( sernum ) );

  if ( strlen( short_name ) > 0 )
  {
    if ( strstr( short_name, "COM") )
      return mbg_snprintf(s, max_len,"%s", short_name);

    for ( i = 0; ( i < HW_NAME_SZ ) && ( i < strlen( short_name ) ); i++ )
    {
      if ( short_name[i] == '_' )
      {
        i++;
        break;
      }
      model_code[i] = short_name[i];
    }
    strncpy( sernum, &short_name[i], PCPS_SN_SIZE-1 );

    if ( sernum[12] == ' ' )
      sernum[12] = '\0';
  }

  n = mbg_snprintf( s, max_len, "%s, S/N %s", model_code, sernum );

  if ( fw_rev_num > 0 )
    n += mbg_snprintf( &s[n], max_len," (FW v%d.%02d", fw_rev_num>>8, fw_rev_num & 0x00FF );

  if ( asic_version_num > 0 )
  {
    mbg_snprintf( &s[n], max_len," / ASIC v%d.%02d)", _convert_asic_version_number( asic_version_num ) >> 8, 
                                                      ( _convert_asic_version_number( asic_version_num ) ) & 0xFF );
  }
  else
    mbg_snprintf( &s[n], max_len,")" );

  return strlen(s);

}  // mbg_str_dev_name




#if defined( MBG_TGT_WIN32 )

BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved )
{
  return TRUE;
}

#endif  // defined( MBG_TGT_WIN32 )



