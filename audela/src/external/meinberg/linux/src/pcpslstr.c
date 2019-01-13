
/**************************************************************************
 *
 *  $Id: pcpslstr.c 1.22.1.4 2011/02/07 10:34:59 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Functions generating commonly used multi-language strings used
 *    with programs for Meinberg radio clocks.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpslstr.c $
 *  Revision 1.22.1.4  2011/02/07 10:34:59  martin
 *  Fixed potential compiler warning for sprintf().
 *  Revision 1.22.1.3  2011/01/28 09:34:20  martin
 *  Fixed build under FreeBSD.
 *  Revision 1.22.1.2  2010/11/05 12:55:10  martin
 *  Revision 1.22.1.1  2010/07/15 12:39:34  martin
 *  Added function sprint_utc_offs().
 *  Revision 1.22  2010/06/25 13:57:57Z  daniel
 *  Account for time zone offsets with minutes other than 0.
 *  Revision 1.21  2009/03/19 08:06:58Z  daniel
 *  Added function pcps_tz_name_hr_status() to
 *  handle different time scales.
 *  Revision 1.20  2008/11/14 12:12:26Z  martin
 *  Made some parameters for some functions const.
 *  Revision 1.19  2008/07/18 10:50:46Z  martin
 *  Use _snwprintf with underscore for MS compilers.
 *  Revision 1.18  2008/01/30 14:51:12Z  martin
 *  Fixed gcc compiler warnings.
 *  Revision 1.17  2008/01/17 09:08:12  daniel
 *  Added function pcps_date_time_wstr().
 *  Changed function pcps_tz_name() to support MSF related time zones.
 *  Exclude functions using wchar_t from build if wide chars are
 *  not supported by the target environment.
 *  Revision 1.16  2007/08/14 09:08:25Z  martin
 *  Addad a workaround for older Borland compilers which don't
 *  like "const" inside structures.
 *  Revision 1.15  2007/07/20 10:55:27Z  martin
 *  Some modifications to avoid compiler warnings.
 *  Revision 1.14  2007/03/30 13:23:42  martin
 *  In pcps_status_strs() handle case where time has been 
 *  set manually.
 *  Revision 1.13  2007/03/29 12:58:18Z  martin
 *  Moved some definitions to the header file to make them public.
 *  Revision 1.12  2006/05/04 14:56:03Z  martin
 *  Strings returned by inv_str() ar surrounded by "**"s.
 *  Revision 1.11  2004/11/09 15:06:44Z  martin
 *  Type cast to avoid warning with format string.
 *  Revision 1.10  2004/08/18 14:58:02  martin
 *  pcps_tz_name() now expects a flags parameter which controls
 *  the format of the output string.
 *  Revision 1.9  2004/04/28 08:06:12Z  martin
 *  Append DST status to TZ names labeled "UTC+xh"
 *  in pcps_tz_name().
 *  Revision 1.8  2003/04/15 10:46:31Z  martin
 *  Pass RECEIVER_INFO to pcps_serial_str().
 *  Revision 1.7  2002/12/18 09:57:03Z  martin
 *  Made some vaiables and definitions global.
 *  Revision 1.6  2002/02/19 10:03:16Z  MARTIN
 *  New function pcps_serial_str().
 *  Revision 1.5  2001/09/17 13:17:40  MARTIN
 *  New function pcps_tz_name_from_status() which should be used
 *  instead of pcps_tz_name() if offset from UTC is not known.
 *  New function pcps_status_strs().
 *  Enhanced language support.
 *  Don't require myutil.h anymore.
 *  Added some comments.
 *  Source code cleanup.
 *  Revision 1.4  2001/08/14 11:32:24  MARTIN
 *  Modified pcps_date_time_str() to allow for variable
 *  spacing between date, time, and time zone..
 *  Revision 1.3  2001/02/28 15:47:29  MARTIN
 *  Replaced access to some structure elements by new macro calls.
 *  Revision 1.2  2000/08/31 14:03:46  MARTIN
 *  Modified initializers for tzcode_name for non CPP-compilers.
 *  Revision 1.1  2000/07/21 12:14:01  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _PCPSLSTR
 #include <pcpslstr.h>
#undef _PCPSLSTR

#include <pcpsutil.h>
#include <mbgtime.h>
#include <ctry.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#define _eos( _s )  ( &(_s)[strlen( _s )] )

typedef struct
{
  #if defined( __BORLANDC__ ) && ( __BORLANDC__ < 0x0500 )
    // old BCs don't like "const" inside the structure
    LSTR ok;
    LSTR err;
  #else
    CLSTR ok;
    CLSTR err;
  #endif
} CLSTR_STATUS;


static const char *tz_name_utc = TZ_NAME_UTC;
static CLSTR str_dst = { "DST", "Sommerzeit" };



/*HDR*/
const char *inv_str( void )
{
  static CLSTR s = { "** invalid **", "** ung" LCUE "ltig **" };

  return _lstr( s );

}  /* inv_str */



/*HDR*/
int sprint_utc_offs( char *s, const char *info, long utc_offs )
{
  int n = 0;

  // utc_offs is in [s]
  char utc_offs_sign = ( utc_offs < 0 ) ? '-' : '+';
  ulong abs_utc_offs = labs( utc_offs );
  ulong utc_offs_hours = abs_utc_offs / SECS_PER_HOUR;
  ulong tmp = abs_utc_offs % SECS_PER_HOUR;
  ulong utc_offs_mins = tmp / MINS_PER_HOUR;
  ulong utc_offs_secs = tmp % MINS_PER_HOUR;

  if ( info )
    n += sprintf( &s[n], "%s", info );

  n += sprintf( &s[n], "%c%lu", utc_offs_sign, utc_offs_hours );

  if ( utc_offs_mins || utc_offs_secs )
    n += sprintf( &s[n], ":%02lu", utc_offs_mins );

  if ( utc_offs_secs )
    n += sprintf( &s[n], ":%02lu", utc_offs_secs );

  n += sprintf( &s[n], "h" );

  return n;

}  // sprint_utc_offs



static /*HDR*/
const char *get_tz_name( PCPS_TIME_STATUS_X pcps_status, long utc_offs,
                         ushort flags, int is_msf )
{
  static char ws[40];
  const char *cp = NULL;
  int n = 0;

  if ( ( pcps_status & PCPS_UTC ) && ( utc_offs == 0 ) )
    return tz_name_utc;  // no offset, no DST

  if ( pcps_status & PCPS_DL_ENB )
  {
    if ( utc_offs == ( 2 * SECS_PER_HOUR ) )
    {
      cp = _lstr( lstr_cest );
      goto check_flags;
    }
    else
      if ( ( utc_offs == SECS_PER_HOUR ) && is_msf )
      {
        cp = _lstr( lstr_bst );
        goto check_flags;
      }
  }

  if ( !( pcps_status & PCPS_DL_ENB ) )
  {
    if ( utc_offs == SECS_PER_HOUR )
    {
      cp = _lstr( lstr_cet );
      goto check_flags;
    }
    else
      if ( ( utc_offs == 0  ) && is_msf )
      {
        cp = _lstr( lstr_gmt );
        goto check_flags;
      }
  }

  n = sprint_utc_offs( ws, tz_name_utc, utc_offs );

check_flags:
  if ( cp )
  {
    if ( flags == 0 )
      return cp;

    strcpy( ws, cp );

    if ( flags & PCPS_TZ_NAME_FORCE_UTC_OFFS )
    {
      n = strlen( ws );
      n += sprintf( &ws[n], "%*c(", pcps_time_tz_dist, ' ' );
      n += sprint_utc_offs( &ws[n], tz_name_utc, utc_offs );
      sprintf( &ws[n], ")" );
    }
  }

  if ( flags & PCPS_TZ_NAME_APP_DST )
  {
    if ( pcps_status & PCPS_DL_ENB )
      sprintf( _eos( ws ), ",%*c%s", pcps_time_tz_dist,
               ' ', _lstr( str_dst ) );
  }

  return ws;
}



/*HDR*/
const char *pcps_tz_name( const PCPS_TIME *t, ushort flags, int is_msf )
{
  return get_tz_name( t->status, t->offs_utc * SECS_PER_HOUR, flags, is_msf );

}  // pcps_tz_name



/*HDR*/
const char *pcps_tz_name_from_hr_time( const PCPS_HR_TIME *hrt, ushort flags, int is_msf )
{
  return get_tz_name( hrt->status, hrt->utc_offs, flags, is_msf );

}  // pcps_tz_name_from_hr_time



// The function below can be used to build a name for
// the time zone if the TIMESCALE, the UTC/DST status and the
// UTC offset are known, e.g. from plug-in clocks.

/*HDR*/
const char *pcps_tz_name_hr_status( const PCPS_HR_TIME *t, ushort flags, int is_msf )
{
  static char ws[40];

  if ( t->status & PCPS_SCALE_GPS )
    strcpy( ws, "GPS" );
  else
    if ( t->status & PCPS_SCALE_TAI )
      strcpy( ws, "TAI" );
  else
    return pcps_tz_name_from_hr_time( t, flags, is_msf);

  return ws;

}  // pcps_tz_name_hr_status



// The function below can be used to build a name for
// the time zone if only the UTC/DST status is known
// but the UTC offset is not. This is the case, for example,
// if the Meinberg standard time string is decoded.

/*HDR*/
const char *pcps_tz_name_from_status( ushort status )
{
  if ( status & PCPS_UTC )
    return tz_name_utc;

  return ( status & PCPS_DL_ENB ) ? _lstr(  str_dst ) : "";

}  // pcps_tz_name_from_status



/*HDR*/
char *pcps_date_time_str( char *s, const PCPS_TIME *t,
                          ushort year_limit, const char *tz_str )
{
  if ( !_pcps_time_is_read( t ) )
    strcpy( s, str_not_avail );
  else
  {
    char *cp;
    int i;

    _pcps_sprint_wday( s, t, language );
    cp = _eos( s );
    *cp++ = ',';
    for ( i = 0; i < pcps_wday_date_dist; i++ )
      *cp++ = ' ';
    _pcps_sprint_date( cp, t, year_limit );
    cp = _eos( s );
    for ( i = 0; i < pcps_date_time_dist; i++ )
      *cp++ = ' ';
    _pcps_sprint_time_long( cp, t );

    if ( tz_str )
    {
      cp = _eos( s );
      for ( i = 0; i < pcps_time_tz_dist; i++ )
        *cp++ = ' ';
      strcpy( cp, tz_str );
    }
  }

  return s;

}  // pcps_date_time_str



#if MBG_TGT_HAS_WCHAR_T && defined( MBG_TGT_WIN32 )

/*HDR*/
wchar_t *pcps_date_time_wstr( wchar_t *ws, const PCPS_TIME *t,
                              ushort year_limit, const wchar_t *tz_str )
{
  char    stemp[80];
  wchar_t wstemp[80];

  if ( !_pcps_time_is_read( t ) )
    mbstowcs( ws, str_not_avail, 32 );
  else
  {
    char *cp;
    int i;

    _pcps_sprint_wday( stemp, t, language );
    cp = _eos( stemp );
    *cp++ = ',';
    for ( i = 0; i < pcps_wday_date_dist; i++ )
      *cp++ = ' ';
    _pcps_sprint_date( cp, t, year_limit );
    cp = _eos( stemp );
    for ( i = 0; i < pcps_date_time_dist; i++ )
      *cp++ = ' ';
    _pcps_sprint_time_long( cp, t );

    mbstowcs( wstemp, stemp, sizeof( wstemp ) );

    if ( tz_str )
      _snwprintf( ws, sizeof( wstemp ) + 32, L"%s %s", wstemp, tz_str );
  }

  return ws;

}  // pcps_date_time_wstr

#endif // MBG_TGT_HAS_WCHAR



static /*HDR*/
void pcps_setup_status_str( PCPS_STATUS_STR *pstr, int err_cond,
                            CLSTR_STATUS *pss )
{
  pstr->is_err = err_cond != 0;
  pstr->cp = _lstr( pstr->is_err ? pss->err : pss->ok );

}  // pcps_setup_status_str



// to return status strings to be displayed depending on the
// a clocks PCPS_TIME.status.

/*HDR*/
void pcps_status_strs( ushort status, int status_is_read,
                       int is_gps, PCPS_STATUS_STRS *pstrs )
{
  CLSTR clstr_time_inval = DEFAULT_STR_TIME_INVAL;
  CLSTR clstr_set_manually = DEFAULT_STR_SET_MANUALLY;

  CLSTR_STATUS lstr_dcf_has_syncd =
    { DEFAULT_STR_DCF_HAS_SYNCD, DEFAULT_STR_DCF_HAS_NOT_SYNCD };

  CLSTR_STATUS lstr_gps_syncd =
    { DEFAULT_STR_GPS_SYNCD, DEFAULT_STR_GPS_NOT_SYNCD };

  CLSTR_STATUS lstr_dcf_not_free_running =
    { DEFAULT_STR_DCF_NOT_FREE_RUNNING, DEFAULT_STR_DCF_FREE_RUNNING };

  CLSTR_STATUS lstr_gps_pos =
    { DEFAULT_STR_GPS_POS_OK, DEFAULT_STR_GPS_POS_NOT_OK };

  CLSTR clstr_ann_dst = DEFAULT_STR_ANN_DST;
  CLSTR clstr_ann_ls = DEFAULT_STR_ANN_LS;

  PCPS_STATUS_STRS tmp_strs;
  PCPS_STATUS_STR *pstr = &tmp_strs.s[0];

  memset( &tmp_strs, 0, sizeof( tmp_strs ) );

  if ( !status_is_read )
    pstr->cp = str_not_avail;
  else
  {
    if ( status & PCPS_INVT )
    {
      pstr->cp = _lstr( clstr_time_inval );
      pstr->is_err = 1;
    }
    else
      if ( status & PCPS_IFTM )
      {
        pstr->cp = _lstr( clstr_set_manually );
        pstr->is_err = 1;
      }
      else
      {
        pcps_setup_status_str( pstr, ( status & PCPS_SYNCD ) == 0,
             is_gps ? &lstr_gps_syncd : &lstr_dcf_has_syncd );

        pstr++;

        pcps_setup_status_str( pstr, ( status & PCPS_FREER ) != 0,
             is_gps ? &lstr_gps_pos : &lstr_dcf_not_free_running );
      }

    pstr++;

    if ( status & PCPS_DL_ANN )
      pstr->cp = _lstr( clstr_ann_dst );
    else
      if ( status & PCPS_LS_ANN )
        pstr->cp = _lstr( clstr_ann_ls );
  }

  *pstrs = tmp_strs;

}  // pcps_status_strs



/*HDR*/
char *pcps_port_str( char *s, const PCPS_DEV *pdev )
{
  ushort port = _pcps_port_base( pdev, 0 );

  ushort n = sprintf( s, "%3Xh", port );

  port = _pcps_port_base( pdev, 1 );

  if ( port )
    sprintf( &s[n], ", %3Xh", port );

  return s;

}  // pcps_port_str



/*HDR*/
const char *pcps_tzcode_str( PCPS_TZCODE tzcode )
{
  if ( language < N_LNG && tzcode < N_PCPS_TZCODE )
    return tzcode_name[tzcode][language];

  return inv_str();

}  // pcps_tzcode_str



/*HDR*/
char *pcps_serial_str( char *s, int i, const RECEIVER_PORT_CFG *p,
                       const RECEIVER_INFO *p_ri, int short_strs )
{
  const PORT_SETTINGS *p_ps = &p->pii[i].port_info.port_settings;
  const STR_TYPE_INFO *p_sti = &p->stii[p_ps->str_type].str_type_info;

  sprintf( s, "%lu,%s", (ulong) p_ps->parm.baud_rate, p_ps->parm.framing );

  if ( short_strs )
    sprintf( _eos( s ), ",%s", short_mode_name[p_ps->mode] );
  else
  {
    if ( p_ri->n_str_type > 1 )
      sprintf( _eos( s ), ", %s", p_sti->long_name );

    sprintf( _eos( s ), ", %s", _lstr( mode_name[p_ps->mode] ) );
  }

  return( s );

}  // pcps_serial_str


