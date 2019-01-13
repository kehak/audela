/**************************************************************************
 *
 *  $Id: xhrtime.c,v 1.1 2011-02-23 14:23:15 myrtillelaas Exp $
 *
 * -----------------------------------------------------------------------
 *  $Log: not supported by cvs2svn $
 *  Revision 1.4  2009/01/23 08:31:28Z  daniel
 *  Revision 1.3  2009/01/20 11:13:26Z  daniel
 *  Added comments.
 *  Revision 1.2  2009/01/15 15:59:09Z  daniel
 *  Revision 1.1  2009/01/07 15:21:48Z  daniel
 *  Initial revision
 *
 **************************************************************************/

/*! \defgroup group_xhrt Getting extrapolated high resolution time stamps

    To retrieve extrapolated time stamps a polling thread 
    inside the mbgdevio.dll is started which 
    reads a high resolution time stamp and an associated CPU cycles counter 
    value once per second and saves that data pair.

    Current time stamps are then computed by taking the current CPU
    cycles value and extrapolating the time from the last data pair.

    This is very much faster than accessing the device for every 
    single time stamp.

    On systems where the cycles counter is implemented by a CPU's time stamp 
    counter (TSC) it maybe required to set the thread or process affinity to a 
    single CPU to get reliable cycles counts. In this case also care should be 
    taken that the CPU's clock frequency is not stepped up and down e.g. due 
    to power saving mechanisms (e.g. Intel SpeedStep, or AMD Cool'n'Quiet). 
    Otherwise time interpolation may be messed up.

    <b>Notes:</b>
    \li This approach works / makes sense only with cards which support
        high resolution time stamps (PCPS_HR_TIME). If a card doesn't support
        that then this program prints a warning.

    \li Extrapolation is done using the time stamp counter (TSC) registers 
        provided by Pentium CPUs and newer/compatible
        types as the cycles counter. On SMP / multicore CPUs those
        counters may not be synchronized, so this works only correctly
        if all cycles counter values are taken from the same CPU.
        To achieve this the process CPU affinity is by default set to
        the first CPU at program start, which means all threads of this
        process are executed only on that CPU.
        
   Associated functions:
    
   \li mbg_xhrt_poll_thread_create()
   \li mbg_get_xhrt_cycles_frequency()
   \li mbg_get_xhrt_time_as_pcps_hr_time()
   \li mbg_get_xhrt_time_as_filetime()
   \li mbg_xhrt_poll_thread_stop()
 
 */

 /**
  \file
  \copydoc group_xhrt

   Build environment settings:
    
   Add "mbglib\include" directory to the include search path.
   Link the main file plus the required import libraries,
   in this case mbgdevio.lib and mbgutil.lib.
   
   The import libraries are located:<br>
     <B>"mbglib\lib\msc"</B>   for Microsoft C compilers<br>
     <B>"mbglib\lib\bc"</B>    for Inprise/Borland compilers

 */


#include <mbgdevio.h>
#include <mbgutil.h>

#include <stdio.h>


// Configuration
#define N_LOOPS 30          /** Number of time stamps */
#define USE_PCPS_HR_TIME 1  /** Select 1 to use PCPS_HR_TIME as output format. Select 0 to use Windows FILETIME. */

/**
  Union to do a simple conversion between
  a Windows FILETIME to a 64 Bit value.
*/
typedef union
{
  FILETIME ft; 
  DWORDLONG dwl;
} FT_DWL;


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

  printf( "Kernel driver: %s v%i.%02i, %i device%s\n\n",
          drvr_info.id_str,
          drvr_info.ver_num / 100,
          drvr_info.ver_num % 100,
          drvr_info.n_devs,
          ( drvr_info.n_devs == 1 ) ? "" : "s"
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
    _pcps_port_base( p_dev, 0 ) ? 
      printf( "  %s, SN: %s at port %03Xh\n",
            _pcps_fw_id( p_dev ), _pcps_sernum( p_dev ),
            _pcps_port_base( p_dev, 0 )
          ) :
      printf( "  %s, SN: %s\n",
            _pcps_fw_id( p_dev ), _pcps_sernum( p_dev )
          );
  }
  else
    err_msg( "Failed to read device info" );

}  // print_dev_info



int main( int argc, char* argv[] )
{
  int i;
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
    printf( "\n" );


    // Start a polling thread and get extrapolated time stamps from the DLL.
    // Only devices which support PCPS_HR_TIME support the extrapolation feature.
    if ( _pcps_has_hr_time( &dev ) )
    {
      int rc;
      int this_loops = N_LOOPS;
      MBG_POLL_THREAD_INFO poll_thread_info = { { { { 0 } } } };

      // Start the polling thread.
      rc = mbg_xhrt_poll_thread_create( &poll_thread_info, dh, 0, 0 );

      if ( rc != MBG_SUCCESS )
        return -1;

      for (;;)
      {
        static int has_printed_msg = 0;
        MBG_PC_CYCLES cyc_1;
        MBG_PC_CYCLES cyc_2;
        MBG_PC_CYCLES_FREQUENCY freq_hz;        
        double access_time;

      #if USE_PCPS_HR_TIME
        PCPS_HR_TIME hrt;
        char ws[80];
      #else
        FT_DWL tstamp_ft;
        SYSTEMTIME tstamp_st, tstamp_lt;
        TIME_ZONE_INFORMATION tzi;
      #endif

        // Calculate the cycles frequency with high accuracy with the help
        // of the reference clock.
        rc = mbg_get_xhrt_cycles_frequency( &poll_thread_info.xhrt_info, &freq_hz );

        if ( rc != MBG_SUCCESS )
          goto fail;

        // As long as the frequency is 0, no valid time stamps can be received.
        // For the caclulation of the frequency at least 2 polling cycles are needed
        // which last 1 second by default.
        if ( freq_hz == 0 )
        {
          if ( !has_printed_msg )
          {
            printf( "Waiting until frequency has been computed ... " );
            has_printed_msg = 1;
          }

          Sleep( 50 );
          continue;
        }

        if ( has_printed_msg )
        {
          printf( "\n" );
          has_printed_msg = 0;
        }
        
        // Get PC cycles to compute the access time.        
        mbg_get_pc_cycles( &cyc_1 );

        // Request a time stamp
        #if USE_PCPS_HR_TIME
          rc = mbg_get_xhrt_time_as_pcps_hr_time( &poll_thread_info.xhrt_info, &hrt );
        #else
          rc = mbg_get_xhrt_time_as_filetime( &poll_thread_info.xhrt_info, &tstamp_ft.ft );
        #endif

        mbg_get_pc_cycles( &cyc_2 );

        if ( rc != MBG_SUCCESS )
          goto fail;

        // Compute the access_time
        access_time = ( (double) cyc_2 - (double) cyc_1 ) / (double) ( (int64_t) freq_hz ) * (double) 1E6;

        #if USE_PCPS_HR_TIME

          // Convert PCPS_HR_TIME into a readable time stamp with fractions as local time.
          mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &hrt );
          printf( "Extrapolated ref time (UTC)  : %s           (%.3f us)\n", ws, access_time );

          mbg_str_pcps_hr_tstamp_loc( ws, sizeof( ws ), &hrt );
          printf( "Extrapolated ref time (LOCAL): %s (%.3f us)\n\n", ws, access_time );

        #else

          // Convert the FILETIME timestamps into a readable format
          FileTimeToSystemTime( &tstamp_ft.ft, &tstamp_st );

          printf("Extrapolated ref time (UTC)  : %02d:%02d:%02d.%07d (%.3f us)\n",
            tstamp_st.wHour,tstamp_st.wMinute,tstamp_st.wSecond, 
            (DWORD) ( tstamp_ft.dwl % 10000000UL ), access_time ) ;

          // Convert the UTC time to local time if necessary
          GetTimeZoneInformation( &tzi );

          SystemTimeToTzSpecificLocalTime( &tzi, &tstamp_st, &tstamp_lt );

          printf("Extrapolated ref time (LOCAL): %02d:%02d:%02d.%07d (%.3f us)\n\n",
            tstamp_lt.wHour,tstamp_lt.wMinute,tstamp_lt.wSecond, 
            (DWORD) ( tstamp_ft.dwl % 10000000UL), access_time) ;

        #endif

        if ( this_loops > 0 )
          this_loops--;

        if ( this_loops == 0 )
          break;

        // if this_loops is < 0 then loop forever
      }

      goto done;

    fail:
      printf("** Aborting: xhrt function returned %i\n", rc );

    done:
      mbg_xhrt_poll_thread_stop( &poll_thread_info );

      mbg_close_device( &dh );
      printf( "\n" );  
    }
    else
      printf( "High resolution time not supported by this device.\n" );

  }
  
  printf ( "\n" );

  return rc;
}



