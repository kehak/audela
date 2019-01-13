
/**************************************************************************
 *
 *  $Id: ctrydttm.c 1.5 2008/11/24 16:15:46 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Functions converting dates and time into strings depending on
 *    language/country settings.
 *
 * -----------------------------------------------------------------------
 *  $Log: ctrydttm.c $
 *  Revision 1.5  2008/11/24 16:15:46  martin
 *  Don't use sprintf() without format string.
 *  Revision 1.4  2000/11/27 10:06:27  MARTIN
 *  Renamed local variable wday_str to lstrs_wday.
 *  If macro USER_LSTR_WDAY is defined, lstrs_wday can be declared 
 *  externally to override the defaults.
 *  Revision 1.3  2000/09/14 15:13:25  MARTIN
 *  Renamed sprint_short_ctry_dt() to sprint_ctry_dt_short() to match
 *  other naming conventions.
 *  Revision 1.2  2000/07/21 11:53:42  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _CTRYDTTM
 #include <ctrydttm.h>
#undef _CTRYDTTM

#include <ctry.h>

#include <stdio.h>


#ifndef DAYS_PER_WEEK
  #define DAYS_PER_WEEK 7
#endif

#ifdef USER_LSTRS_WDAY
  extern const char *lstrs_wday[N_LNG][DAYS_PER_WEEK];
#else
  static const char *lstrs_wday[N_LNG][DAYS_PER_WEEK] =
  {
    { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" },
    { "So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"  }
  };
#endif

extern CTRY ctry;
extern LANGUAGE language;


/*HDR*/
ushort sprint_02u( char *s, uchar uc )
{
  return( sprintf( s, "%02u", uc ) );

}  // sprint_02u



/*HDR*/
ushort sprint_04u( char *s, ushort us )
{
  return( sprintf( s, "%04u", us ) );

}  // sprint_04u



/*HDR*/
ushort sprint_ctry_wday( char *s, uchar wday, ushort language )
{
  if ( language >= N_LNG )
    language = LNG_ENGLISH;

  return( sprintf( s, "%s", ( wday < DAYS_PER_WEEK ) ?
                   lstrs_wday[language][wday] : "--" ) );

}  // sprint_ctry_wday



/*HDR*/
ushort sprint_ctry_dt_short( char *s, uchar mday, uchar month )
{
  uchar tmp_1;
  uchar tmp_2;
  ushort n = 0;


  switch( ctry.dt_fmt )
  {
    case DT_FMT_YYYYMMDD:
    case DT_FMT_MMDDYYYY:
      tmp_1 = month;
      tmp_2 = mday;
      break;

    default:
      tmp_1 = mday;
      tmp_2 = month;
      break;

  }  // switch

  n = sprint_02u( s, tmp_1 );
  s[n++] = ctry.dt_sep;
  n += sprint_02u( &s[n], tmp_2 );
  s[n++] = ctry.dt_sep;
  s[n] = 0;

  return( n );

}  // sprint_ctry_dt_short



/*HDR*/
ushort sprint_ctry_dt( char *s, uchar mday, uchar month, ushort year )
{
  ushort n = 0;


  if ( ctry.dt_fmt == DT_FMT_YYYYMMDD )
  {
    n = sprint_04u( s, year );
    s[n++] = ctry.dt_sep;
  }

  n += sprint_ctry_dt_short( &s[n], mday, month );

  if ( ctry.dt_fmt == DT_FMT_YYYYMMDD )
    s[--n] = 0;
  else
    n += sprint_04u( &s[n], year );

  return( n );

}  // sprint_ctry_dt



/*HDR*/
ushort sprint_ctry_tm_short( char *s, uchar hour, uchar minute )
{
  ushort n = sprint_02u( s, hour );
  s[n++] = ctry.tm_sep;
  n += sprint_02u( &s[n], minute );

  return( n );

}  // sprint_ctry_tm_short



/*HDR*/
ushort sprint_ctry_tm( char *s, uchar hour, uchar minute, uchar second )
{
  ushort n = sprint_ctry_tm_short( s, hour, minute );
  s[n++] = ctry.tm_sep;
  n += sprint_02u( &s[n], second );

  return( n );

}  // sprint_ctry_tm



/*HDR*/
ushort sprint_ctry_tm_long( char *s, uchar hour, uchar minute, uchar second,
                            long frac, ushort frac_digits )
{
  ushort n = sprint_ctry_tm( s, hour, minute, second );
  s[n++] = '.';
  n += sprintf( &s[n], "%0*lu", frac_digits, frac );

  return( n );

}  // sprint_ctry_tm_long


