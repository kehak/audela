
/**************************************************************************
 *
 *  $Id: toolutil.c 1.3.2.12 2011/11/03 08:54:08 martin TEST $
 *
 *  Description:
 *    Common functions which can be used with Meinberg command line
 *    utility programs.
 *
 * -----------------------------------------------------------------------
 *  $Log: toolutil.c $
 *  Revision 1.3.2.12  2011/11/03 08:54:08  martin
 *  Revision 1.3.2.11  2011/10/31 08:48:52  martin
 *  Revision 1.3.2.10  2011/10/05 15:08:28  martin
 *  Added function to show PZF correlation.
 *  Revision 1.3.2.9  2011/09/29 16:31:53  martin
 *  New function mbg_print_hr_time() which optionally prints hex status.
 *  Revision 1.3.2.8  2011/09/20 16:14:13  martin
 *  Revision 1.3.2.7  2011/09/07 15:05:04  martin
 *  Let th display functions for HR timestamps optionally show
 *  the raw (hex) timestamps.
 *  Revision 1.3.2.6  2011/07/08 11:39:00  martin
 *  Revision 1.3.2.5  2011/07/06 07:55:32  martin
 *  Revision 1.3.2.4  2011/07/05 15:35:56  martin
 *  Modified version handling.
 *  Revision 1.3.2.3  2011/07/05 14:36:47  martin
 *  New way to maintain version information.
 *  Revision 1.3.2.2  2011/06/27 13:02:11  martin
 *  Open device with O_RDWR flag.
 *  Revision 1.3.2.1  2010/11/05 12:56:02  martin
 *  Revision 1.3  2009/06/19 12:12:14  martin
 *  Added function mbg_print_hr_timestamp().
 *  Revision 1.2  2009/02/18 09:15:55  martin
 *  Support TAI and GPS time scales in mbg_snprint_hr_time().
 *  Revision 1.1  2008/12/17 10:45:13  martin
 *  Initial revision.
 *  Revision 1.1  2008/12/15 08:35:07  martin
 *  Initial revision.
 *
 **************************************************************************/

#define _TOOLUTIL
  #include <toolutil.h>
#undef _TOOLUTIL

// include Meinberg headers
#include <pcpsutil.h>

// include system headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*HDR*/
int mbg_program_info_str( char *s, size_t max_len, const char *pname,
                          int micro_version, int first_year, int last_year )
{
  int n;

  if ( last_year == 0 )
    last_year = MBG_CURRENT_COPYRIGHT_YEAR;

  n = snprintf( s, max_len, "%s v%i.%i.%i Copyright Meinberg ", pname,
                MBG_MAJOR_VERSION_CODE, MBG_MINOR_VERSION_CODE, micro_version );

  if ( first_year != last_year )
    n += snprintf( &s[n], max_len - n, "%04i-", first_year );

  n += snprintf( &s[n], max_len - n, "%04i", last_year );

  return n;

}  // mbg_program_info_str



/*HDR*/
void mbg_print_program_info( const char *pname, int micro_version, int first_year, int last_year )
{
  char ws[256];
  #if defined( MBG_MICRO_VERSION_CODE_DEV )
    micro_version = MBG_MICRO_VERSION_CODE_DEV;
  #endif
  mbg_program_info_str( ws, sizeof( ws ), pname, micro_version, first_year, last_year );

  printf( "\n%s\n\n", ws );

}  // mbg_print_program_info



/*HDR*/
void mbg_print_usage_intro( const char *pname, const char *info )
{
  printf( "Usage:  %s [[opt] [opt] ...] [[dev] [dev] ...]\n\n", pname );

  if ( info )
    printf( "%s\n\n", info );


}  // mbg_print_usage_intro



/*HDR*/
void mbg_print_help_options( void )
{
  puts( "where opt is one of the options:" );
  mbg_print_opt_info( "-? or -h", "print this usage information" );

}  // mbg_print_help_options



/*HDR*/
void mbg_print_opt_info( const char *opt_name, const char *opt_info )
{
  if ( opt_name == NULL )
    opt_name = "";

  if ( opt_info == NULL )
    opt_info = "";

  printf( "  %8s   %s\n", opt_name, opt_info );

}  // mbg_print_opt_info



/*HDR*/
void mbg_print_device_options( void )
{
  puts( "\nwhere dev is the name of a device, e.g.:\n"
        "    /dev/mbgclock0"
      );

}  // mbg_print_device_options



/*HDR*/
void mbg_print_default_usage( const char *pname, const char *prog_info )
{
  mbg_print_usage_intro( pname, prog_info );
  mbg_print_help_options();
  mbg_print_device_options();
  puts( "" );

}  // mbg_print_default_usage



// test if ioctl error and print msg if true

/*HDR*/
int mbg_ioctl_err( int rc, const char *descr )
{
  if ( rc < 0 )
  {
    fprintf( stderr, "** IOCTL error %i: ", rc );
    perror( descr );
    return -1;
  }

  return 0;

}  // mbg_ioctl_err



/*HDR*/
int mbg_get_show_dev_info( MBG_DEV_HANDLE dh, const char *dev_name, PCPS_DEV *p_dev )
{
  unsigned long long port;
  int irq_num;
  int ret_val = 0;
  int rc;

  if ( dev_name )
    printf( "%s:\n", dev_name );

  // get information about the device
  rc = mbg_get_device_info( dh, p_dev );

  if ( mbg_ioctl_err( rc, "mbg_get_device_info" ) )
    goto fail;


  printf( "%s", _pcps_type_name( p_dev ) );

  if ( strlen( _pcps_sernum( p_dev ) ) && 
       strcmp( _pcps_sernum( p_dev ), "N/A" ) )
    printf( " %s", _pcps_sernum( p_dev ) );

  printf( " (FW %X.%02X", 
          _pcps_fw_rev_num_major( _pcps_fw_rev_num( p_dev ) ),
          _pcps_fw_rev_num_minor( _pcps_fw_rev_num( p_dev ) )
        );

  if ( _pcps_has_asic_version( p_dev ) )
  {
    PCI_ASIC_VERSION av;
    int rc = mbg_get_asic_version( dh, &av );

    if ( rc == MBG_SUCCESS )
    {
      av = _convert_asic_version_number( av );

      printf( ", ASIC %u.%02u",
              _pcps_asic_version_major( av ),
              _pcps_asic_version_minor( av )
            );
    }
  }

  printf( ")" );

  port = _pcps_port_base( p_dev, 0 );

  if ( port )
    printf( " at port 0x%03LX", port );

  port = _pcps_port_base( p_dev, 1 );

  if ( port )
    printf( "/0x%03LX", port );

  irq_num = _pcps_irq_num( p_dev );

  if ( irq_num != -1 )
    printf( ", irq %i", irq_num );

  goto done;

fail:
  ret_val = -1;

done:
  puts( "" );
  return ret_val;

}  // mbg_get_show_dev_info



/*HDR*/
int mbg_check_device( MBG_DEV_HANDLE dh, const char *dev_name, 
                      int (*fnc)( MBG_DEV_HANDLE, const PCPS_DEV *) )
{
  PCPS_DEV dev;
  int ret_val = 0;

  if ( dh == MBG_INVALID_DEV_HANDLE )
  {
    if ( dev_name )
      fprintf( stderr, "%s: ", dev_name );

    perror( "Unable to open device" );
    return -1;
  }

  if ( mbg_get_show_dev_info( dh, dev_name, &dev ) < 0 )
    goto fail;

  if ( fnc )
    ret_val = fnc( dh, &dev );

  goto done;

fail:
  ret_val = -1;

done:
  mbg_close_device( &dh );
  puts( "" );

  return ret_val;

}  // mbg_check_device



/*HDR*/
int mbg_check_devices( int argc, char *argv[], int optind, int (*fnc)( MBG_DEV_HANDLE, const PCPS_DEV *) )
{
  MBG_DEV_HANDLE dh;
  int ret_val = 0;
  int num_devices = argc - optind;

  if ( num_devices == 0 )  // no device name given on the command line
  {
    // No devices specified on the command line, so
    // try to find devices.
    int devices = mbg_find_devices();

    if ( devices == 0 )
    {
      printf( "No device found.\n" );
      return 1;
    }

    // Handle only first device found.
    dh = mbg_open_device( 0 );
    ret_val = mbg_check_device( dh, NULL, fnc );
  }
  else
  {
    int i;
    // One or more device names have been specified 
    // on the command line, so handle each device.
    for ( i = optind; i < argc; i++ )
    {
      // Print device name only if output for several devices
      // shall be displayed.
      const char *fn = ( num_devices > 1 ) ? argv[i] : NULL;

      dh = open( argv[i], O_RDWR );
      ret_val = mbg_check_device( dh, fn, fnc );

      if ( ret_val )
        break;
    }
  }

  return ret_val;

}  // mbg_check_devices



/*HDR*/
int mbg_snprint_hr_tstamp( char *s, int len_s, const PCPS_TIME_STAMP *p, int show_raw )
{
  int n = 0;

  // We'll use the standard C library functions to convert the seconds
  // to broken-down calendar date and time.
  time_t t = p->sec;

  // Our time stamp may be UTC, or have been converted to local time.
  // Anyway, since we don't want to account for the system's time zone 
  // settings, we always use the gmtime() function for conversion:
  struct tm *tmp = gmtime( &t );

  if ( show_raw )
    n += snprintf( s + n, len_s - n, "raw: 0x%08lX.%08lX, ",
                   (ulong) p->sec, 
                   (ulong) p->frac );

  n += snprintf( s + n, len_s - n, "%04i-%02i-%02i %02i:%02i:%02i." PCPS_HRT_FRAC_SCALE_FMT,
                 tmp->tm_year + 1900,
                 tmp->tm_mon + 1,
                 tmp->tm_mday,
                 tmp->tm_hour,
                 tmp->tm_min,
                 tmp->tm_sec,
                 (ulong) frac_sec_from_bin( p->frac, PCPS_HRT_FRAC_SCALE )
               );

  return n;

}  // mbg_snprint_hr_tstamp



/*HDR*/
int mbg_snprint_hr_time( char *s, int len_s, const PCPS_HR_TIME *p, int show_raw )
{
  char ws[80];
  PCPS_TIME_STAMP ts = p->tstamp;
  int n;
  const char *time_scale_name;
  const char *cp;

  // If the local time offset is not 0 then add this to the time stamp
  // and set up a string telling the offset.
  if ( p->utc_offs )
  {
    ldiv_t ldt;

    ts.sec += p->utc_offs;

    // The local time offset is in seconds and may be negative, so we
    // convert to absolute hours and minutes first.
    ldt = ldiv( labs( p->utc_offs ) / 60, 60 );

    snprintf( ws, sizeof( ws ), "%c%lu:%02luh",
              ( p->utc_offs < 0 ) ? '-' : '+',
              ldt.quot,
              ldt.rem
            );
    cp = ws;
  }
  else
    cp = "";   // no local time offset


  // Convert the local time stamp to calendar date and time.
  n = mbg_snprint_hr_tstamp( s, len_s, &ts, show_raw );

  // By default the time stamp represents UTC plus an optional local time offset.
  time_scale_name = "UTC";

  // However, some cards may be configured to output TAI or GPS time.
  if ( p->status & PCPS_SCALE_TAI )
    time_scale_name = "TAI";      // time stamp represents TAI
  else
    if ( p->status & PCPS_SCALE_GPS )
      time_scale_name = "GPS";    // time stamp represents GPS system time

  n += snprintf( s + n, len_s - n, " %s%s", time_scale_name, cp );

  return n;

}  // mbg_snprint_hr_time



/*HDR*/
void mbg_print_hr_timestamp( PCPS_TIME_STAMP *p_ts, int32_t hns_latency, PCPS_TIME_STAMP *p_prv_ts,
                             int no_latency, int show_raw )
{
  char ws[80];

  mbg_snprint_hr_tstamp( ws, sizeof( ws ), p_ts, show_raw );
  printf( "HR time %s", ws );

  if ( p_prv_ts )
  {
    // print the difference between the current and the previous time stamp
    uint64_t ts = pcps_time_stamp_to_uint64( p_ts );
    uint64_t prv_ts = pcps_time_stamp_to_uint64( p_prv_ts );
    // we divide by PCPS_HRT_BIN_FRAC_SCALE to get the correct fractions
    // and we multiply by 1E6 to get the result in microseconds
    double delta_t = (double) ( ts - prv_ts ) * 1E6 / PCPS_HRT_BIN_FRAC_SCALE;
    printf( " (%+.1f us)", delta_t );
  }

  if ( !no_latency )
    printf( ", latency: %.1f us", ( (double) hns_latency ) / 10 );

  puts( "" );

}  // mbg_print_hr_timestamp



/*HDR*/
void mbg_print_hr_time( PCPS_HR_TIME *p_ht, int32_t hns_latency, PCPS_TIME_STAMP *p_prv_ts,
                        int no_latency, int show_raw, int verbose )
{
  char ws[80];

  mbg_snprint_hr_time( ws, sizeof( ws ), p_ht, show_raw );
  printf( "HR time %s", ws );

  if ( p_prv_ts )
  {
    // print the difference between the current and the previous time stamp
    uint64_t ts = pcps_time_stamp_to_uint64( &p_ht->tstamp );
    uint64_t prv_ts = pcps_time_stamp_to_uint64( p_prv_ts );
    // we divide by PCPS_HRT_BIN_FRAC_SCALE to get the correct fractions
    // and we multiply by 1E6 to get the result in microseconds
    double delta_t = (double) ( ts - prv_ts ) * 1E6 / PCPS_HRT_BIN_FRAC_SCALE;
    printf( " (%+.1f us)", delta_t );
  }

  if ( !no_latency )
    printf( ", latency: %.1f us", ( (double) hns_latency ) / 10 );

  if ( verbose )
    printf( ", st: 0x%04lX", (ulong) p_ht->status );

  puts( "" );

}  // mbg_print_hr_time



/*HDR*/
int mbg_show_pzf_corr_info( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev, int show_corr_step )
{
  CORR_INFO ci;
  char ws[80];
  const char *cp;

  int rc = mbg_get_corr_info( dh, &ci );

  if ( mbg_ioctl_err( rc, "mbg_get_corr_info" ) )
    return rc;


  if ( ci.status < N_PZF_CORR_STATE )
    cp = pzf_corr_state_name[ci.status];
  else
  {
    snprintf( ws, sizeof( ws ) - 1, "(unknown, code: 0x%02X)", ci.status );
    ws[sizeof( ws ) - 1] = 0;  // force terminating 0
    cp = ws;
  }

  printf( "PZF correlation: %u%%, status: %s", ci.val, cp );

  if ( show_corr_step )
    if ( ci.corr_dir != ' ' )
      printf( " Shift: %c", ci.corr_dir );

  return MBG_SUCCESS;

}  // mbg_show_pzf_corr_info

