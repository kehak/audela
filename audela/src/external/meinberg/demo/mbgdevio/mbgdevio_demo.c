
/**************************************************************************
 *
 *  $Id: mbgdevio_demo.c,v 1.1 2011-02-23 14:23:15 myrtillelaas Exp $
 *  $Name: not supported by cvs2svn $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 * -----------------------------------------------------------------------
 *  $Log: not supported by cvs2svn $
 *  Revision 1.10  2009/08/18 14:14:27Z  daniel
 *  Added calls to read the irig control bits, irig time, irig debug status, 
 *  ptp infos and LAN interface info.
 *  Revision 1.9  2009/04/01 14:07:24Z  martin
 *  Code cleanup.
 *  Revision 1.8  2009/03/23 15:12:54Z  daniel
 *  Include UTC parameters and time scales.
 *  Revision 1.7  2009/01/23 08:31:28Z  daniel
 *  Revision 1.6  2009/01/20 11:13:26Z  daniel
 *  Added comments.
 *  Revision 1.5  2009/01/08 07:52:59Z  daniel
 *  Code cleanup
 *  Revision 1.4  2008/12/04 13:39:04Z  daniel
 *  Revision 1.3  2008/02/07 08:29:08Z  daniel
 *  Use function mbg_mm_get_hr_timestamp_comp().
 *  Revision 1.2  2008/01/31 08:06:41Z  daniel
 *  Include demonstration of mapped memory support.
 *  Revision 1.1  2007/11/02 11:13:24Z  daniel
 *  Initial revision
 *
 **************************************************************************/
 
/**
    \file
      Example program to access Meinberg computer peripherals 
      using the mbgdevio (Meinberg Device I/O) DLL.<br>
      The program checks first whether a certain feature like high
      resolution time, Memory Mapped I/O, different time scales or 
      user capture is supported by the device.
       
   Build environment settings:
    
     Add "mbglib\include" directory to the include search path.
     Link the main file plus the required import libraries,
     in this case mbgdevio.lib and mbgutil.lib.
     
     The import libraries are located:<br>
       <B>"mbglib\lib\msc"</B>   for Microsoft C compilers<br>
       <B>"mbglib\lib\bc"</B>    for Inprise/Borland compilers
 */
 

#include <mbgdevio.h>
#include <mbgtime.h>
#include <mbgutil.h>

#include <stdio.h>
#include <stdlib.h>




/** Number of memory mapped time reads */
#define MAX_MEM_MAPPED_CNT 20 

static int n_sec_change = 0;

const char *time_scale_str[N_MBG_TIME_SCALE] = MBG_TIME_SCALE_STRS;



static /*HDR*/
void err_msg( const char *msg )
{
  fprintf( stderr, "** %s: %i\n", msg, GetLastError() );

}  // err_msg



static /*HDR*/
void print_drvr_info( void )
{
  int rc;
  PCPS_DRVR_INFO drvr_info;
  MBG_DEV_HANDLE dh = mbg_open_device( 0 );
  
  if ( dh == MBG_INVALID_DEV_HANDLE )
  {
    err_msg( "Unable to open device" );
    exit( 1 );
  }


  rc = mbg_get_drvr_info( dh, &drvr_info );

  mbg_close_device( &dh );


  if ( rc != PCPS_SUCCESS )
  {
    err_msg( "Failed to read driver info" );
    exit( 1 );
  }

  printf( "Kernel driver: %s v%i.%02i\n\n",
          drvr_info.id_str,
          drvr_info.ver_num / 100,
          drvr_info.ver_num % 100
        );

}  // print_drvr_info



static /*HDR*/
void print_dev_info( MBG_DEV_HANDLE dh,   
                     PCPS_DEV *p_dev )
{
  int rc;

  rc = mbg_get_device_info( dh, p_dev );

  if ( rc == PCPS_SUCCESS )
  {
    printf( "  %s at port %03Xh\n",
            _pcps_type_name( p_dev ),
            _pcps_port_base( p_dev, 0 )
          );
  }
  else
    err_msg( "Failed to read device info" );

}  // print_dev_info



static /*HDR*/
void print_date_time( PCPS_TIME *tp, const char *label )
{
  if ( label )
    printf( label );

  printf( "%02u.%02u.%02u  %02u:%02u:%02u.%02u (UTC%+dh)\n",
          tp->mday, tp->month, tp->year, 
          tp->hour, tp->min, tp->sec, tp->sec100,
          tp->offs_utc
        );

}  // print_date_time



static /*HDR*/
void print_date_time_status( MBG_DEV_HANDLE dh )
{
  PCPS_TIME t;


  // Read a simple time stamp with 10 ms resolution.
  if ( PCPS_SUCCESS == mbg_get_time( dh, &t ) )
  {
    print_date_time( &t, "  " );

    printf( "  %s\n", 
            ( t.status & PCPS_FREER ) ? 
            "free running" : 
            "synchronized" );

    printf( "  %s\n", 
            ( t.status & PCPS_SYNCD ) ? 
            "synchronized after last RESET" : 
            "not synchronized after last RESET" );
  }
  else
    err_msg( "Failed to read date/time/status" );

}  // print_date_time_status



static /*HDR*/
char *sprint_hr_time( char *s, const PCPS_HR_TIME *t )
{
  const char *cp = "UTC";
  
  if ( t->status & PCPS_SCALE_TAI )
    cp = "TAI";
  else
    if ( t->status & PCPS_SCALE_GPS )
      cp = "GPS";

  sprintf( s, "%08lX.%08lX %s%+ldsec, st: %04X", 
           t->tstamp.sec,
           t->tstamp.frac,
           cp,
           t->utc_offs,
           t->status
         );

  return s;

}  // sprint_hr_time



static /*HDR*/
void print_hr_time( MBG_DEV_HANDLE dh )
{
  PCPS_HR_TIME hr_t;

  // Read a high resolution time stamp with compensated latency. 
  // The function mbg_get_hr_time_comp() has been introduced in 
  // mbgdevio DLL v2.1.2 and compensates the execution time (latency) 
  // required to acces the hardware from inside the kernel driver. 

  #if 1  // use with mbgdevio DLL v2.1.2 or greater

    int32_t latency;  

    // The latency value can optionally be returned by this function. 
    // If the latency value is not required, a NULL pointer can be 
    // passed instead. The latency value is in hectonanoseconds [hns], 
    // i.e. 100 nanosecond units.

    if ( PCPS_SUCCESS == mbg_get_hr_time_comp( dh, &hr_t, &latency ) )
    {
      char ws[200];
      const char *cp = "UTC";

      if ( hr_t.status & PCPS_SCALE_TAI )
        cp = "TAI";
      else
        if ( hr_t.status & PCPS_SCALE_GPS )
          cp = "GPS";

      printf( "  HR time (RAW): %s, latency: %i hns\n", sprint_hr_time( ws, &hr_t ), latency );

      // Format function taken from mbgutil.h
      mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &hr_t );
      printf( "  HR time (%s): %s, latency=%i hns\n", cp, ws, latency );
    }
    else
      err_msg( "Failed to read High Resolution Time" );

  #else  // the code below can be used with mbgdevio DLL < v2.1.2.

    if ( PCPS_SUCCESS == mbg_get_hr_time( dh, &hr_t ) )
      printf( "  HR time: %s\n", sprint_hr_time( ws, &hr_t ) );
    else
      err_msg( "Failed to read High Resolution Time" );

  #endif

}  // print_hr_time



static /*HDR*/
void print_sec_changes( MBG_DEV_HANDLE dh )
{
  int i = 0;

  for (;;)
  {
    PCPS_TIME t;
    BOOL rc;

    // This IOCTL call blocks until a second change is detected.
    rc = mbg_get_time_sec_change( dh, &t );
    
    if ( rc == PCPS_SUCCESS )
    {
      print_hr_time( dh );
      print_date_time( &t, "  New sec: " );
    }
    else
      err_msg( "Failed to get time at second change." );

    // Wait for specified number of second changes.
    // If number is 0, wait forever.
    if ( n_sec_change )
      if ( ++i >= n_sec_change )
        break;
  }

}  // print_sec_changes

  
  
static /*HDR*/
void print_receiver_position( MBG_DEV_HANDLE dh )
{
  POS pos;
  char ws[256];


  if ( PCPS_SUCCESS == mbg_get_gps_pos( dh, &pos ) )
  {
    mbg_str_pos( ws, sizeof( ws ), &pos, 4 );
    printf( "  Receiver position: %s\n", ws );
  }
  else
    err_msg( "Failed to read receiver position" );

}  // print_receiver_position



static /*HDR*/
void print_sv_info( MBG_DEV_HANDLE dh )
{
  STAT_INFO stat_info;


  if ( PCPS_SUCCESS == mbg_get_gps_stat_info( dh, &stat_info ) )
  {
    printf( "  Satellites: %u in view, %u good\n",
            stat_info.svs_in_view, 
            stat_info.good_svs 
          );
  }
  else
    err_msg( "Failed to read GPS status info" );

}  // print_sv_info



static /*HDR*/
/**
  There are 3 functions to deal with the capture events:

  \li mbg_clr_ucap_buff() clears the on-board FIFO buffer
  \li mbg_get_ucap_entries() returns the maximum number of entries
    and the currently saved number of entries in the buffer
  \li mbg_get_ucap_event() retrieves a capture event from the
    on-board FIFO, or 0000.0000 if the FIFO buffer is empty.

  When using the time capture inputs the following hints might be helpful:

  \li The corresponding DIP switches on the card must be set to the "ON"
  position in order to wire the input pins to the capture circuitry. See
  the user manual for the correct DIP switches.
  \li Capture events are stored in the on-board FIFO, and entries can be
  retrieved from the FIFO in different ways. Once an entry has been
  retrieved it is removed from the FIFO, so if several ways or
  applications are used at the same time to retrieve capture events from
  the FIFO then capture events may be missed by one application since they
  have already been retrieved by another application.
  \li The card provides 2 physical serial interfaces either of which may
  have been configured to send a serial ASCII string automatically
  whenever a capture event has occurred. Of course this would also remove
  those capture events from the FIFO buffer. So the settings of both
  serial ports should be checked to make sure none of the serial ports
  have been configured to send the capture string automatically. This has
  to be done only once for a card since the setting is saved in
  non-volatile memory.
*/
void check_user_captures( MBG_DEV_HANDLE dh, PCPS_DEV *pdev )
{
  unsigned int ucaps_read = 0;

  if ( _pcps_has_ucap( pdev ) )
  {
    PCPS_UCAP_ENTRIES ucap_entries;
    PCPS_HR_TIME ucap_event;
    char ws[100];

    for (;;)   // read all entries from capture buffer
    {
      if ( PCPS_SUCCESS != mbg_get_ucap_entries( dh, &ucap_entries ) )
      {
        err_msg( "Failed to read user capture buffer entries." );
        break;
      }

      if ( PCPS_SUCCESS != mbg_get_ucap_event( dh, &ucap_event ) )
      {
        err_msg( "Failed to read user capture event." );
        break;
      }


      // If a user capture event has been read
      // then it it removed from the clock's buffer.

      // If no new capture event is available, the ucap.tstamp structure
      // is set to 0.
      // Alternatively, PCPS_UCAP_ENTRIES.used can be checked for the 
      // number of events pending in the buffer.

      if ( ucap_event.tstamp.sec == 0 ) // no new user capture event
        break;


      printf( "  New capture: CH%i: %s (%i/%i)\n", 
              ucap_event.signal,    // this is the channel number
              sprint_hr_time( ws, &ucap_event ),
              ucap_entries.used,
              ucap_entries.max
            );

      ucaps_read++;
    }
  }
  else
  {
    TTM ucap;

    for (;;)   // read all entries from capture buffer
    {
      if ( PCPS_SUCCESS != mbg_get_gps_ucap( dh, &ucap ) )
      {
        err_msg( "Failed to read user captures" );
        break;
      }


      // If a user capture event has been read
      // then it it removed from the clock's buffer.

      // If no new capture is available, the ucap.tm structure
      // is set to "unread".
      if ( !_pcps_time_is_read( &ucap.tm ) ) // no new user capture entry
        break;

      printf( "  New capture: CH%i: %02i.%02i.%02i  %2i:%02i:%02i.%07li\n",
              ucap.channel,
              ucap.tm.mday,
              ucap.tm.month,
              ucap.tm.year % 100,
              ucap.tm.hour,
              ucap.tm.min,
              ucap.tm.sec,
              ucap.tm.frac
            );

      ucaps_read++;
    }
  }
  

  if ( ucaps_read )
    printf( "  User captures read: %u\n", ucaps_read );
  else
    printf( "  No user captures to be read.\n" );


  if ( _pcps_can_clr_ucap_buff( pdev ) )
  {
    if ( PCPS_SUCCESS == mbg_clr_ucap_buff( dh ) )
      printf( "  Capture buffer cleared.\n" );
    else
      err_msg( "  Failed to clear capture buffer" );
  }
  else
    printf( "  Clearing capture buffer not supported.\n" );

}  // check_user_captures



static /*HDR*/
void print_utc_parameters( MBG_DEV_HANDLE dh, PCPS_DEV *pdev )
{

  if ( _pcps_has_utc_parm( pdev ) )
  {
    UTC utc;

    if ( mbg_get_utc_parm( dh, &utc ) == PCPS_SUCCESS )
    {
      printf("  UTC parameters:\n");

      if ( !utc.valid )
        printf("  UTC parameters not valid!\n");
      else
      {
        if ( utc.delta_tls != utc.delta_tlsf )
        {

          // a leap second is currently being announced

          time_t t_ls = (time_t) utc.WNlsf * SECS_PER_WEEK
                    + (time_t) utc.DNt * SECS_PER_DAY
                    + GPS_SEC_BIAS - 1;

          struct tm *tm = gmtime( &t_ls );

          printf( "  UTC offset transition from %is to %is due to leap second\n"
                  "  %s at UTC midnight at the end of %04i-%02i-%02i.\n",
                  utc.delta_tls, utc.delta_tlsf,
                  ( utc.delta_tls < utc.delta_tlsf ) ? "insertion" : "deletion",
                  tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday
                );

        }
        else
          printf( "  UTC offset parameter: %is, no leap second announced.\n", utc.delta_tls );
      }
    }
  }
} // print_utc_parameters



static /*HDR*/
void show_irig_ctrl_bits( MBG_DEV_HANDLE dh )
{
  MBG_IRIG_CTRL_BITS irig_ctrl_bits;

  int rc = mbg_get_irig_ctrl_bits( dh, &irig_ctrl_bits );

  if ( rc != MBG_SUCCESS )
    return;

  printf( "\nIRIG control bits: %08lX (hex, LSB first)\n", (ulong) irig_ctrl_bits );

}  // show_irig_ctrl_bits



static /*HDR*/
void show_irig_debug_status( MBG_DEV_HANDLE dh )
{
  static const char *status_str[N_MBG_DEBUG_BIT] = MBG_DEBUG_STATUS_STRS;

  MBG_DEBUG_STATUS st;
  int i;
  int rc = _mbg_generic_read_var( dh, PCPS_GET_DEBUG_STATUS, st );

  if ( rc != MBG_SUCCESS )
    return;

  printf( "\nDebug status (hex): %08lX\n", (ulong) st );

  for ( i = 0; i < N_MBG_DEBUG_BIT; i++ )
    if ( st & ( 1UL << i ) )
      printf( "  %s\n", status_str[i] );

}  // show_irig_debug_status


/*HDR*/
int snprint_ip4_addr( char *s, size_t max_len, const IP4_ADDR *addr )
{
  int n;

  n = mbg_snprintf( s, max_len, "%i.%i.%i.%i",
                BYTE_OF( *addr, 3 ),
                BYTE_OF( *addr, 2 ),
                BYTE_OF( *addr, 1 ),
                BYTE_OF( *addr, 0 )
              );

  return n;

}  // snprint_ip4_addr



static /*HDR*/
void show_lan_intf_state( MBG_DEV_HANDLE dh )
{
  IP4_SETTINGS ip4_settings;
  LAN_IF_INFO lan_if_info;
  char ws[100];

  int rc = mbg_get_ip4_state( dh, &ip4_settings );

  if ( rc != MBG_SUCCESS )
    return;

  rc = mbg_get_lan_if_info( dh, &lan_if_info );

  if ( rc != MBG_SUCCESS )
    return;


  printf( "\nOn-board LAN interface settings:\n" );

  mbg_snprintf( ws, sizeof( ws ), "%02X-%02X-%02X-%02X-%02X-%02X",
            lan_if_info.mac_addr[0],
            lan_if_info.mac_addr[1],
            lan_if_info.mac_addr[2],
            lan_if_info.mac_addr[3],
            lan_if_info.mac_addr[4],
            lan_if_info.mac_addr[5]
         );
  printf( "  MAC Address:    %s\n", ws );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.ip_addr );
  printf( "  IP Address:     %s%s\n", ws, ( ip4_settings.flags & IP4_MSK_DHCP ) ?
          "(DHCP)" : "" );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.netmask );
  printf( "  Net Mask:       %s\n", ws );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.broad_addr );
  printf( "  Broadcast Addr: %s\n", ws );

  snprint_ip4_addr( ws, sizeof( ws ), &ip4_settings.gateway );
  printf( "  Gateway:        %s\n", ws );

  printf( "  Link detected:  %s\n", ( ip4_settings.flags & IP4_MSK_LINK ) ? "YES" : "NO" );

}  // show_lan_intf_state



static /*HDR*/
void print_ptp_status( MBG_DEV_HANDLE dh )
{
  static const char *ptp_stat_str[N_PTP_PORT_STATE] = PTP_PORT_STATE_STRS;
  char ws[100];
  const char *cp;
  int ptp_state_available;
  PTP_STATE ptp_state;

  int rc = mbg_get_ptp_state( dh, &ptp_state );

  if ( rc != MBG_SUCCESS )
  {
    printf(" Error getting PTP State!\n");
    return;
  }

  printf( "\nPTP port status:\n" );

  printf( "  Port mode:       %s\n", ( ptp_state.port_state < N_PTP_PORT_STATE ) ?
          ptp_stat_str[ptp_state.port_state] : "(undefined)" );

  ptp_state_available = ( ptp_state.port_state == PTP_PORT_STATE_SLAVE );

  cp = ptp_state_available ? ws : "N/A";

  mbg_snprintf( ws, sizeof( ws ), "%02X-%02X-%02X-%02X-%02X-%02X",
            ptp_state.gm_identity.b[0],
            ptp_state.gm_identity.b[1],
            ptp_state.gm_identity.b[2],
            ptp_state.gm_identity.b[5],
            ptp_state.gm_identity.b[6],
            ptp_state.gm_identity.b[7]
         );
  printf( "  Grandmaster MAC: %s\n", cp );


  mbg_snprintf( ws, sizeof( ws ), "%c%li.%09li s",
            _nano_time_negative( &ptp_state.path_delay ) ? '-' : '+',
            labs( (long) ptp_state.path_delay.secs ),
            labs( (long) ptp_state.path_delay.nano_secs )
          );
  printf( "  PTP path delay:  %s\n", cp );


  mbg_snprintf( ws, sizeof( ws ), "%c%li.%09li s",
            _nano_time_negative( &ptp_state.offset ) ? '-' : '+',
            labs( (long) ptp_state.offset.secs ),
            labs( (long) ptp_state.offset.nano_secs )
            );
  printf( "  PTP time offset: %s\n\n", cp );


}


int main( int argc, char* argv[] )
{
  int i,j;
  int rc = 0;
  int devices_found;

  if ( mbgdevio_check_version( MBGDEVIO_VERSION ) != PCPS_SUCCESS )
  {
    printf( "The MBGDEVIO DLL API version %X which is installed is not compatible\n"
            "with API version %X required by this program.\n",
            mbgdevio_get_version(),
            MBGDEVIO_VERSION
          );
    exit( 1 );
  }

  devices_found = mbg_find_devices();

  if ( devices_found == 0 )
  {
    printf( "No radio clock found.\n" );
    return 1;
  }


  printf( "Found %i radio clock%s\n", 
          devices_found,
          ( devices_found == 1 ) ? "" : "s"
        );


  print_drvr_info();


  // There may be several radio clock devices installed. 
  // Try to get information from each of the devices.
  for ( i = 0; i < devices_found; i++ )
  {
    static PCPS_DEV dev;

    MBG_DEV_HANDLE dh;

    printf( "Radio clock %i:\n", i );

    dh = mbg_open_device( i );
    
    if ( dh == MBG_INVALID_DEV_HANDLE )
    {
      err_msg( "Unable to open device" );
      continue;
    }

    print_dev_info( dh, &dev );

    if ( _pcps_has_time_scale (&dev ) )
    {
      MBG_TIME_SCALE_INFO tsi;
      int rc;

      rc = mbg_get_time_scale_info( dh, &tsi );
      
      if ( rc == PCPS_SUCCESS )
        printf( "  Current time scale: \"%s\"\n", time_scale_str[tsi.settings.scale] );
      else
        printf( "  Error: mbg_get_time_scale_info() returned 0x%X.\n", rc);
    }

    // Read the current date, time, and status.
    print_date_time_status( dh );

    // Some clocks (mainly GPS receivers and IRIG decoders) 
    // support a high resolution time. If supported, read and 
    // display the HR time.
    if ( _pcps_has_hr_time( &dev ) )
      print_hr_time( dh );

    // Newer IRIG receiver cards support reading the original
    // raw IRIG time stamp.
    if ( _pcps_has_irig_time( &dev ) )
    {
      PCPS_IRIG_TIME it;

      rc = mbg_get_irig_time( dh, &it );

      if ( rc == MBG_SUCCESS )
        printf( "\nRaw IRIG time: yday %u, %02u:%02u:%02u\n",
                it.yday, it.hour, it.min, it.sec );
    }

    
    // Print some GPS clock specific info
    if ( _pcps_is_gps( &dev ) ) 
    {
      print_receiver_position( dh );
      print_sv_info( dh );
      check_user_captures( dh, &dev );

      printf("\n");
    }

    if ( _pcps_has_utc_parm( &dev ) )
      print_utc_parameters( dh, &dev );

    if ( _pcps_is_irig_rx( &dev ) )
      show_irig_debug_status( dh );

    if ( _pcps_has_irig_ctrl_bits( &dev ) )
      show_irig_ctrl_bits( dh );

    if ( _pcps_has_lan_intf( &dev ) ) 
      show_lan_intf_state( dh );

    if ( _pcps_is_ptp( &dev ) ) 
      print_ptp_status( dh );


    //***********
    // Loop some seconds waiting for second to change
    // Uncomment the line below if required:

    //print_sec_changes( dh );

    //***********


    // Check if device has support for memory mapped I/O
    // and read a couple of time stamps.
    if ( _pcps_has_asic_version( &dev ) )
    {
      PCI_ASIC_FEATURES asic_features;

      rc = mbg_get_asic_features( dh, &asic_features );

      if ( rc == PCPS_SUCCESS && ( asic_features &  PCI_ASIC_HAS_MM_IO ) )
      {
        PCPS_HR_TIME hrtime[MAX_MEM_MAPPED_CNT] = { 0 };
        uint32_t latency[MAX_MEM_MAPPED_CNT] = { 0 };
        int rc;

        // Read some memory mapped time stamps 
        // as fast as possible
        for ( j = 0; j < MAX_MEM_MAPPED_CNT; j++ )
        {
          rc = mbg_get_fast_hr_timestamp_comp( dh, &hrtime[j].tstamp, &latency[j] );
      
          if ( rc != PCPS_SUCCESS )
          {
            printf("  Error: mbg_get_fast_hr_timestamp_comp() returned 0x%X\n",rc );
            break;
          }
        }

        if ( j == MAX_MEM_MAPPED_CNT )
        {
          // Print time stamps
          for ( j = 0; j < MAX_MEM_MAPPED_CNT; j++ )
          {
            char ws[200];

            mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &hrtime[j] );
            printf( "  HR timestamp (MEM):  %s latency=%u hns\n", ws, latency[j] );
          }
        }
      }
    }

    mbg_close_device( &dh );   
    printf( "\n" );
  }
  
  printf ( "\n" );

  return rc;
}
