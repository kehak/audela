
/**************************************************************************
 *
 *  $Id: mbgstatus.c 1.13.1.19 2011/10/28 13:46:14 martin TEST $
 *
 *  Description:
 *    Main file for mbgstatus program which demonstrates how to
 *    access a Meinberg device via IOCTL calls and prints device
 *    information.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgstatus.c $
 *  Revision 1.13.1.19  2011/10/28 13:46:14  martin
 *  Revision 1.13.1.18  2011/10/28 13:05:03  martin
 *  Revision 1.13.1.17  2011/10/05 15:10:56  martin
 *  Show PZF correlation state.
 *  Revision 1.13.1.16  2011/10/05 13:03:34  martin
 *  Adapted PZF correlation/signal/status display.
 *  Revision 1.13.1.15  2011/10/05 11:57:42  martin
 *  Revision 1.13.1.14  2011/09/29 16:30:03  martin
 *  Started to support PZF.
 *  Optionally show hex status.
 *  Changed what is displayed in certain levels of verbosity.
 *  Revision 1.13.1.13  2011/09/07 15:08:55  martin
 *  Account for modified library functions which can now
 *  optionally print the raw (hex) HR time stamp.
 *  Revision 1.13.1.12  2011/07/08 11:02:47  martin
 *  Revision 1.13.1.11  2011/07/05 15:35:55  martin
 *  Modified version handling.
 *  Revision 1.13.1.10  2011/07/05 14:35:19  martin
 *  New way to maintain version information.
 *  Revision 1.13.1.9  2011/04/20 16:08:27  martin
 *  Use snprint_ip4_addr() from module lan_util.
 *  Revision 1.13.1.8  2011/03/03 10:01:23  daniel
 *  Indicate Unicast role in PTP port state
 *  Revision 1.13.1.7  2011/02/07 12:10:58  martin
 *  Use mbg_get_ptp_status() API call.
 *  Revision 1.13.1.6  2010/11/25 14:54:51  martin
 *  Revision 1.13.1.5  2010/11/05 12:54:22  martin
 *  Introduce "verbose" flag and associated command line parameter -v.
 *  Revision 1.13.1.4  2010/10/15 11:28:56  martin
 *  Display UTC offs from IRIG signal.
 *  Revision 1.13.1.3  2010/08/30 08:22:24  martin
 *  Revision 1.13.1.2  2010/08/11 15:06:49  martin
 *  Preliminarily display raw IRIG data, if supported by the device.
 *  Revision 1.13.1.1  2010/02/17 14:11:43  martin
 *  Cosmetics ...
 *  Revision 1.13  2009/09/29 15:02:16  martin
 *  Updated version number to 3.4.0.
 *  Revision 1.12  2009/07/24 14:02:59  martin
 *  Display LAN and PTP status of PTP cards.
 *  Updated version number to 3.3.0.
 *  Revision 1.11  2009/06/19 14:20:36  martin
 *  Display raw IRIG time with TCR cards which support this.
 *  Revision 1.10  2009/06/16 08:21:08  martin
 *  Intermediate version 3.1.0a.
 *  Display IRIG debug status, if supported by the card.
 *  Revision 1.9  2009/03/20 11:35:41  martin
 *  Updated version number to 3.1.0.
 *  Updated copyright year to include 2009.
 *  Display signal source after signal level.
 *  Display GPS UTC parameter info, if supported by the card.
 *  Display IRIG control bits, if supported by the card.
 *  Revision 1.8  2008/12/22 12:48:18  martin
 *  Updated description, copyright, revision number and string.
 *  Use unified functions from toolutil module.
 *  Warn if a PCI Express device with unsafe IRQ support is detected.
 *  Account for signed irq_num.
 *  Accept device name(s) on the command line.
 *  Don't use printf() without format, which migth produce warnings
 *  with newer gcc versions.
 *  Revision 1.7  2007/07/24 09:33:52  martin
 *  Fixed display of port and IRQ resources.
 *  Updated copyright to include 2007.
 *  Revision 1.6  2006/03/10 12:38:22  martin
 *  Fixed printing of sign in print_position().
 *  Revision 1.5  2004/11/08 15:41:56  martin
 *  Modified formatted printing of date/time string.
 *  Using type casts to avoid compiler warnings.
 *  Revision 1.4  2003/07/30 08:16:39  martin
 *  Also displays oscillator DAC values for GPS.
 *  Revision 1.3  2003/07/08 15:38:57  martin
 *  Call mbg_find_devices().
 *  Account for swap_doubles() now being called inside
 *  the mbgdevio API functions.
 *  Show IRQ number assigned to a device.
 *  Revision 1.2  2003/04/25 10:28:05  martin
 *  Use new functions from mbgdevio library.
 *  New program version v2.1.
 *  Revision 1.1  2001/09/17 15:08:59  martin
 *
 **************************************************************************/

// include Meinberg headers
#include <mbgdevio.h>
#include <mbgtime.h>
#include <pcpslstr.h>
#include <pcpsutil.h>
#include <toolutil.h>  // common utility functions
#include <lan_util.h>

// include system headers
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


#define MBG_MICRO_VERSION          0
#define MBG_FIRST_COPYRIGHT_YEAR   2001
#define MBG_LAST_COPYRIGHT_YEAR    0      // use current year by default

static const char *pname = "mbgstatus";


static unsigned int verbose;

static const char *ref_name[N_PCPS_REF]= PCPS_REF_NAMES_ENG;
static const char *icode_rx_names[N_ICODE_RX] = DEFAULT_ICODE_RX_NAMES;
static const char *osc_name[N_GPS_OSC] = DEFAULT_GPS_OSC_NAMES;

static int year_limit = 1990;

static int max_ref_offs_h = MBG_REF_OFFS_MAX / MINS_PER_HOUR;

LANGUAGE language;
CTRY ctry;



static /*HDR*/
void print_pcps_time( const char *s, const PCPS_TIME *tp, const char *tail )
{
  const char *fmt = "%s";
  char ws[256];

  if ( s )
    printf( fmt, s );

  printf( fmt, pcps_date_time_str( ws, tp, year_limit, pcps_tz_name( tp, PCPS_TZ_NAME_FORCE_UTC_OFFS, 0 ) ) );

  if ( ( verbose > 0 ) && _pcps_time_is_read( tp ) )
    printf( ", st: 0x%02lX", (ulong) tp->status );

  if ( tail )
    printf(  fmt, tail );

}  // print_pcps_time



static /*HDR*/
void print_dms( const char *s, const DMS *p, const char *tail )
{
  const char *fmt = "%s";

  printf( "%s %c %3i deg %02i min %05.2f sec",
          s,
          p->prefix,
          p->deg,
          p->min,
          p->sec
        );

  if ( tail )
    printf( fmt, tail );

}  // print_dms



static /*HDR*/
void print_position( const char *s, const POS *p, const char *tail )
{
  const char *fmt = "%s";
  double r2d = 180 / PI;


  if ( s )
    printf( fmt, s );

  if ( verbose > 0 )
  {
    printf( "  x: %.0fm y: %.0fm z: %.0fm",
            p->xyz[XP], p->xyz[YP], p->xyz[ZP] );

    if ( tail )
      printf( fmt, tail );
  }

  // LLA latitude and longitude are in radians, convert to degrees
  printf( "  lat: %+.4f lon: %+.4f alt: %.0fm",
          p->lla[LAT] * r2d, p->lla[LON] * r2d, p->lla[ALT] );

  if ( tail )
    printf( fmt, tail );

  print_dms( "  latitude: ", &p->latitude, tail );
  print_dms( "  longitude:", &p->longitude, tail );

}  // print_position



static /*HDR*/
void show_signal( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev, int signal )
{
  int ref_type;
  int rc;

  ref_type = _pcps_ref_type( pdev );

  if ( ref_type >= N_PCPS_REF )
    ref_type = PCPS_REF_NONE;

  printf( "Signal: %u%%  (%s", signal * 100 / PCPS_SIG_MAX, ref_name[ref_type] );

  if ( _pcps_is_irig_rx( pdev ) )
  {
    IRIG_INFO irig_rx_info;
    MBG_REF_OFFS ref_offs;

    rc = mbg_get_irig_rx_info( dh, &irig_rx_info );

    if ( rc == MBG_SUCCESS )
    {
      int idx = irig_rx_info.settings.icode;

      if ( idx < N_ICODE_RX )
      {
        printf( " %s", icode_rx_names[idx] );

        if ( !( MSK_ICODE_RX_HAS_TZI & ( 1UL << idx ) ) )
        {
          if ( _pcps_has_ref_offs( pdev ) )
          {
            rc = mbg_get_ref_offs( dh, &ref_offs );

            if ( rc == MBG_SUCCESS )
            {
              int ref_offs_h = ref_offs / MINS_PER_HOUR;

              if ( abs( ref_offs_h ) > max_ref_offs_h )
                printf( ", ** UTC offs not configured **" );
              else
                printf( ", UTC%+ih", ref_offs_h );
            }
          }
        }
      }
    }
  }
  else
    if ( _pcps_has_pzf( pdev ) )
      printf( "/PZF" );

  printf( ")\n" );

}  // show_signal



static /*HDR*/
void show_time_and_status( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev, const char *tail )
{
  const char *status_fmt = "Status info: %s%s\n";
  const char *status_err = "*** ";
  const char *status_ok = "";
  PCPS_TIME t;
  PCPS_STATUS_STRS strs;
  int signal;
  int i;
  int rc = mbg_get_time( dh, &t );
  if ( mbg_ioctl_err( rc, "mbg_get_time" ) )
    return;


  print_pcps_time( "Date/time:  ", &t, tail );

  if ( ( verbose > 0 ) && _pcps_has_hr_time( pdev ) )
  {
    PCPS_HR_TIME ht;
    char ws[80];

    rc = mbg_get_hr_time( dh, &ht );

    if ( mbg_ioctl_err( rc, "mbg_get_hr_time" ) )
      return;

    mbg_snprint_hr_time( ws, sizeof( ws ), &ht, 0 );  // raw timestamp?
    printf( "Local HR time:  %s", ws );

    if ( verbose > 0 )
      printf( ", st: 0x%04lX", (ulong) ht.status );

    printf( "%s", tail );
  }

  signal = t.signal - PCPS_SIG_BIAS;

  if ( signal < 0 )
    signal = 0;
  else
    if ( signal > PCPS_SIG_MAX )
      signal = PCPS_SIG_MAX;

  if ( _pcps_has_signal( pdev ) )
    show_signal( dh, pdev, signal );

  if ( _pcps_has_pzf( pdev ) )
  {
    mbg_show_pzf_corr_info( dh, pdev, 0 );
    printf( "\n" );
  }

  if ( _pcps_has_irig_time( pdev ) )
  {
    PCPS_IRIG_TIME it;

    rc = mbg_get_irig_time( dh, &it );

    if ( !mbg_ioctl_err( rc, "mbg_get_irig_time" ) )
      printf( "Raw IRIG time: yday %u, %02u:%02u:%02u\n",
              it.yday, it.hour, it.min, it.sec );
  }

  if ( _pcps_is_irig_rx( pdev ) )
  {
    printf( status_fmt,
            ( signal < PCPS_SIG_ERR ) ? status_err : status_ok,
            ( signal < PCPS_SIG_ERR ) ? "NO INPUT SIGNAL"
                                      : "Input signal available" );
  }
  else
  {
    printf( status_fmt,
            ( signal < PCPS_SIG_ERR ) ? status_err : status_ok,
            ( signal < PCPS_SIG_ERR ) ? "ANTENNA IS NOT CONNECTED"
                                      : "Antenna is connected" );
  }

  // Evaluate the status code and setup status messages.
  pcps_status_strs( t.status, _pcps_time_is_read( &t ),
                    _pcps_is_gps( pdev ), &strs );

  // Print the status messages.
  for ( i = 0; i < N_PCPS_STATUS_STR; i++ )
  {
    PCPS_STATUS_STR *pstr = &strs.s[i];
    if ( pstr->cp )
      printf( status_fmt,
              pstr->is_err ? status_err : status_ok,
              pstr->cp );
  }

}  // show_time_and_status



static /*HDR*/
void show_sync_time( MBG_DEV_HANDLE dh, const char *tail )
{
  PCPS_TIME t;
  int rc = mbg_get_sync_time( dh, &t );

  if ( mbg_ioctl_err( rc, "mbg_get_sync_time" ) )
    return;

  print_pcps_time( "Last sync:  ", &t, tail );

}  // show_sync_time



static /*HDR*/
void show_ext_stat_info( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev, const char *tail )
{
  const char *fmt = "%s";
  RECEIVER_INFO ri;
  STAT_INFO si = { 0 };
  char ws[80];
  char *mode_name;

  int rc = mbg_setup_receiver_info( dh, p_dev, &ri );

  if ( mbg_ioctl_err( rc, "mbg_setup_receiver_info" ) )
    return;

  if ( _pcps_has_stat_info( p_dev ) )
  {
    rc = mbg_get_gps_stat_info( dh, &si );

    if ( mbg_ioctl_err( rc, "mbg_get_gps_stat_info" ) )
      return;


    if ( _pcps_has_stat_info_mode( p_dev ) )
    {
      switch ( si.mode )
      {
        case AUTO_166: mode_name = "Normal Operation";  break;
        case WARM_166: mode_name = "Warm Boot";         break;
        case COLD_166: mode_name = "Cold Boot";         break;

        default:  // This should never happen!
          sprintf( ws, "Unknown mode of operation: %02Xh", si.mode );
          mode_name = ws;

      }  // switch
    }

    if ( _pcps_has_stat_info_svs( p_dev ) )
      printf( "%s, %i sats in view, %i sats used\n", mode_name, si.svs_in_view, si.good_svs );
  }

  if ( verbose )
  {
    printf( "Osc type: %s", osc_name[( ri.osc_type < N_GPS_OSC ) ? ri.osc_type : GPS_OSC_UNKNOWN] );

    if ( _pcps_has_stat_info( p_dev ) )
    {
      printf( ", DAC cal: %+i, fine: %+i",
              (int) ( si.dac_cal - OSC_DAC_BIAS ),
              (int) ( si.dac_val - OSC_DAC_BIAS ) );
    }

    puts( "" );
  }

  if ( tail )
    printf( fmt, tail );

}  // show_ext_stat_info



static /*HDR*/
void show_gps_pos( MBG_DEV_HANDLE dh, const char *tail )
{
  POS pos;
  int rc = mbg_get_gps_pos( dh, &pos );

  if ( mbg_ioctl_err( rc, "mbg_get_gps_pos" ) )
    return;

  print_position( "Receiver Position:\n", &pos, tail );

}  // show_gps_pos



static /*HDR*/
void show_utc_info( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev )
{
  UTC utc;

  int rc = mbg_get_utc_parm( dh, &utc );

  if ( mbg_ioctl_err( rc, "mbg_get_utc_parm" ) )
    return;

  if ( !utc.valid )
  {
    puts( "** UTC parameters not valid" );
    return;
  }

  if ( verbose > 1 )
  {
    //##++++ utc.delta_tls = utc.delta_tlsf - 1;

    printf( "CSUM: %04X, valid: %04X\n", utc.csum, utc.valid );
    printf( "t0t: %u|%u.%07u, A0: %g A1: %g\n",
            utc.t0t.wn, utc.t0t.sec, utc.t0t.tick,
            utc.A0, utc.A1 );
    printf( "WNlsf: %u, DN: %u, offs: %i/%i\n",
            utc.WNlsf, utc.DNt, utc.delta_tls, utc.delta_tlsf );
  }

  if ( utc.delta_tls != utc.delta_tlsf )
  {
    // a leap second is currently being announced
    time_t t_ls = (time_t) utc.WNlsf * SECS_PER_WEEK
                + (time_t) utc.DNt * SECS_PER_DAY
                + GPS_SEC_BIAS - 1;

    struct tm *tm = gmtime( &t_ls );

    printf( "UTC offset transition from %is to %is due to leap second\n"
            "%s at UTC midnight at the end of %04i-%02i-%02i.\n",
            utc.delta_tls, utc.delta_tlsf,
            ( utc.delta_tls < utc.delta_tlsf ) ? "insertion" : "deletion",
            tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday
          );
  }
  else
    printf( "UTC offset parameter: %is, no leap second announced.\n", utc.delta_tls );

}  // show_utc_info



static /*HDR*/
void show_irig_ctrl_bits( MBG_DEV_HANDLE dh )
{
  MBG_IRIG_CTRL_BITS irig_ctrl_bits;

  int rc = mbg_get_irig_ctrl_bits( dh, &irig_ctrl_bits );

  if ( mbg_ioctl_err( rc, "mbg_get_irig_ctrl_bits" ) )
    return;

  printf( "IRIG control bits: %08lX (hex, LSB first)", (ulong) irig_ctrl_bits );
  printf( ", TFOM: 0x%X", _pcps_tfom_from_irig_ctrl_bits( &irig_ctrl_bits ) );
  printf( "\n" );

}  // show_irig_ctrl_bits



static /*HDR*/
char *str_raw_irig_utc_offs_hours( char *s, int max_len, const MBG_RAW_IRIG_DATA *p )
{
  int n;
  long offs = ( p->data_bytes[8] & 0x08 )
            | ( ( p->data_bytes[8] >> 2 ) & 0x04 )
            | ( ( p->data_bytes[8] >> 4 ) & 0x02 )
            | ( ( p->data_bytes[8] >> 6 ) & 0x01 );

  n = snprintf( s, max_len, "%c%li", ( p->data_bytes[8] & 0x80 ) ? '-' : '+', offs );

  if ( p->data_bytes[8] & 0x02 )
    n += snprintf( &s[n], max_len - n, "%s", ".5" );

  return s;

}  // str_raw_irig_utc_offs_hours



static /*HDR*/
void show_raw_irig_data( MBG_DEV_HANDLE dh )
{
  MBG_RAW_IRIG_DATA raw_irig_data;
  char ws[80];
  int i;

  int rc = mbg_get_raw_irig_data( dh, &raw_irig_data );

  if ( mbg_ioctl_err( rc, "mbg_get_raw_irig_data" ) )
    return;

  printf( "Raw IRIG data:" );

  for ( i = 0; i < sizeof( raw_irig_data ); i++ )
    printf( " %02X", raw_irig_data.data_bytes[i] );

  printf( " (hex)" );
  printf( ", TFOM: 0x%X", _pcps_tfom_from_raw_irig_data( &raw_irig_data ) );
  printf( ", UTC offs: %sh", str_raw_irig_utc_offs_hours( ws, sizeof( ws ), &raw_irig_data ) );
  printf( "\n" );

}  // show_raw_irig_data



static /*HDR*/
void show_irig_debug_status( MBG_DEV_HANDLE dh )
{
  static const char *status_str[N_MBG_DEBUG_BIT] = MBG_DEBUG_STATUS_STRS;

  MBG_DEBUG_STATUS st;
  int i;
  int rc = _mbg_generic_read_var( dh, PCPS_GET_DEBUG_STATUS, st );

  if ( mbg_ioctl_err( rc, "show_irig_debug_status" ) )
    return;

  printf( "Debug status (hex): %08lX\n", (ulong) st );

  for ( i = 0; i < N_MBG_DEBUG_BIT; i++ )
    if ( st & ( 1UL << i ) )
      printf( "  %s\n", status_str[i] );

}  // show_irig_debug_status



static /*HDR*/
void show_lan_intf_state( MBG_DEV_HANDLE dh )
{
  IP4_SETTINGS ip4_settings;
  LAN_IF_INFO lan_if_info;
  char ws[100];

  int rc = mbg_get_ip4_state( dh, &ip4_settings );

  if ( mbg_ioctl_err( rc, "mbg_get_ip4_state" ) )
    return;

  rc = mbg_get_lan_if_info( dh, &lan_if_info );

  if ( mbg_ioctl_err( rc, "mbg_get_lan_if_info" ) )
    return;


  printf( "On-board LAN interface settings:\n" );

  snprintf( ws, sizeof( ws ), "%02X-%02X-%02X-%02X-%02X-%02X",
            lan_if_info.mac_addr[0],
            lan_if_info.mac_addr[1],
            lan_if_info.mac_addr[2],
            lan_if_info.mac_addr[3],
            lan_if_info.mac_addr[4],
            lan_if_info.mac_addr[5]
         );
  printf( "  MAC Address:    %s\n", ws );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.ip_addr, NULL );
  printf( "  IP Address:     %s%s\n", ws, ( ip4_settings.flags & IP4_MSK_DHCP ) ?
          " (DHCP)" : "" );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.netmask, NULL );
  printf( "  Net Mask:       %s\n", ws );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.broad_addr, NULL );
  printf( "  Broadcast Addr: %s\n", ws );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.gateway, NULL );
  printf( "  Gateway:        %s\n", ws );

  printf( "  Link detected:  %s\n", ( ip4_settings.flags & IP4_MSK_LINK ) ? "YES" : "NO" );

}  // show_lan_intf_state



static /*HDR*/
void show_ptp_state( MBG_DEV_HANDLE dh )
{
  static const char *ptp_stat_str[N_PTP_PORT_STATE] = PTP_PORT_STATE_STRS;
  char ws[100];
  const char *cp;
  int ptp_state_available;
  PTP_STATE ptp_state;
  PTP_CFG_INFO ptp_info;

  int rc = mbg_get_ptp_state( dh, &ptp_state );

  if ( mbg_ioctl_err( rc, "mbg_get_ptp_state" ) )
    return;

  rc = mbg_get_ptp_cfg_info( dh, &ptp_info );

  if ( mbg_ioctl_err( rc, "mbg_get_ptp_info" ) )
    return;

  printf( "PTP port status:\n" );

  ptp_state_available = ( ptp_state.port_state == PTP_PORT_STATE_SLAVE );

  printf( "  Port mode:       %s%s\n", ( ptp_state_available && ptp_info.settings.ptp_role == PTP_ROLE_UNICAST_SLAVE ) ? "Unicast" : "",
                                         ( ptp_state.port_state < N_PTP_PORT_STATE ) ? ptp_stat_str[ptp_state.port_state] : "(undefined)" );

  cp = ptp_state_available ? ws : str_not_avail;

//##++++++++++
  snprintf( ws, sizeof( ws ), "%02X-%02X-%02X-%02X-%02X-%02X",
            ptp_state.gm_id.b[0],
            ptp_state.gm_id.b[1],
            ptp_state.gm_id.b[2],
            ptp_state.gm_id.b[5],
            ptp_state.gm_id.b[6],
            ptp_state.gm_id.b[7]
         );
  printf( "  Grandmaster MAC: %s\n", cp );


  snprintf( ws, sizeof( ws ), "%c%li.%09li s",
            _nano_time_negative( &ptp_state.path_delay ) ? '-' : '+',
            labs( (long) ptp_state.path_delay.secs ),
            labs( (long) ptp_state.path_delay.nano_secs )
          );
  printf( "  PTP path delay:  %s\n", cp );


  snprintf( ws, sizeof( ws ), "%c%li.%09li s",
            _nano_time_negative( &ptp_state.offset ) ? '-' : '+',
            labs( (long) ptp_state.offset.secs ),
            labs( (long) ptp_state.offset.nano_secs )
            );
  printf( "  PTP time offset: %s\n", cp );

}  // show_ptp_state



static /*HDR*/
int check_irq_unsafe( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev )
{
  PCPS_IRQ_STAT_INFO irq_stat_info;
  int ret_val = 0;
  int rc = mbg_get_irq_stat_info( dh, &irq_stat_info );

  if ( mbg_ioctl_err( rc, "mbg_get_irq_stat_info" ) )
    return -1;

  if ( irq_stat_info & PCPS_IRQ_STAT_UNSAFE )
  {
    static const char *warn_line = "************************************************************************************";

    puts( "" );
    puts( warn_line );

    printf(
      "**  WARNING!\n"
      "**\n"
      "**  Device %s with S/N %s has a firmware version and ASIC version\n"
      "**  which do not allow safe operation with hardware interrupts (IRQs) enabled.\n"
      "**\n"
      "**  Please see http://www.meinberg.de/english/info/pex-upgrades.htm\n"
      "**  for information how the card can easily be upgraded, or contact\n"
      "**  Meinberg support (Email: support@meinberg.de) or your local\n"
      "**  representative.\n"
      ,
      _pcps_type_name( p_dev ), _pcps_sernum( p_dev )
    );

    if ( irq_stat_info & PCPS_IRQ_STAT_ENABLED )
    {
      printf(
        "**\n"
        "**  Interrupts are currently enabled for this card (NTP daemon running?)\n"
        "**  so other access is inhibited to prevent the system from hanging.\n"
      );

      ret_val = -1;
    }

    puts( warn_line );
    puts( "" );
  }

  return ret_val;

}  // check_irq_unsafe



static /*HDR*/
int do_mbgstatus( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev )
{
  int ret_val = 0;

  if ( check_irq_unsafe( dh, p_dev ) < 0 )
    goto done;

  if ( _pcps_has_gps_data( p_dev ) )
    show_ext_stat_info( dh, p_dev, NULL );

  show_time_and_status( dh, p_dev, "\n" );
  show_sync_time( dh, "\n" );

  if ( _pcps_is_gps( p_dev ) )
    show_gps_pos( dh, "\n" );

  if ( _pcps_has_utc_parm( p_dev ) && ( _pcps_is_gps( p_dev ) || ( verbose > 0 ) ) )
    show_utc_info( dh, p_dev );

  if ( _pcps_has_irig_ctrl_bits( p_dev ) )
    show_irig_ctrl_bits( dh );

  if ( _pcps_has_raw_irig_data( p_dev ) )
    show_raw_irig_data( dh );

  if ( _pcps_is_irig_rx( p_dev ) )
    show_irig_debug_status( dh );

  if ( _pcps_has_lan_intf( p_dev ) )
    show_lan_intf_state( dh );

  if ( _pcps_has_ptp( p_dev ) )
    show_ptp_state( dh );

done:
  return ret_val;

}  // do_mbgstatus



static /*HDR*/
void usage( void )
{
  mbg_print_usage_intro( pname,
    "This program prints status information for a device.\n"
    "The displayed information depends on the type of the card."
  );
  mbg_print_help_options();
  mbg_print_device_options();
  puts( "" );

}  // usage



int mbg_status( int argc, char *argv[] )
{
  int c;
  int rc;

  ctry_setup( 0 );
  language = LNG_ENGLISH;
  ctry.dt_fmt = DT_FMT_YYYYMMDD;
  ctry.dt_sep = '-';

  mbg_print_program_info( pname, MBG_MICRO_VERSION, MBG_FIRST_COPYRIGHT_YEAR, MBG_LAST_COPYRIGHT_YEAR );

  // check command line parameters
  while ( ( c = getopt( argc, argv, "vh?" ) ) != -1 )
  {
    switch ( c )
    {
      case 'v':
        verbose++;
        break;

      case 'h':
      case '?':
      default:
        must_print_usage = 1;
    }
  }

  if ( must_print_usage )
  {
    usage();
    return 1;
  }


  if ( verbose )
    pcps_date_time_dist = 1;

  // The function below checks which devices have been specified
  // on the command, and for each device
  // - tries to open the device
  // - shows basic device info
  // - calls the function passed as last parameter
  rc = mbg_check_devices( argc, argv, optind, do_mbgstatus );

  return abs( rc );
}
