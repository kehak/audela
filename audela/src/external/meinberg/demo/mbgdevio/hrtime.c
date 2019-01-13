
/**************************************************************************
 *
 *  $Id: hrtime.c,v 1.1 2011-02-23 14:23:15 myrtillelaas Exp $
 *  $Name: not supported by cvs2svn $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 * -----------------------------------------------------------------------
 *  $Log: not supported by cvs2svn $
 *  Revision 1.5  2009/01/23 08:31:28Z  daniel
 *  Revision 1.4  2009/01/07 15:22:36Z  daniel
 *  Cleaned up source code.
 *  Revision 1.3  2008/01/16 08:48:24Z  daniel
 *  Revision 1.2  2007/11/30 12:14:52Z  daniel
 *  Revision 1.1  2007/11/05 10:54:00Z  daniel
 *  Initial revision
 *
 **************************************************************************/

/*! \defgroup group_hrt Getting high resolution time stamps

  The structure PCPS_HR_TIME is read using
  the mbg_get_hr_time() call and contains the system time in seconds since
  1970 (standard time_t format), the fractions of a second, plus status
  and UTC offset.
  
  The device driver checks whether a particular feature like HR time is
  supported by a particular device and returns an error if it is not. 
  Also the latest driver software should be used since older
  versions of the driver don't check for HR time support.
  
  With our GPS cards, the effictive resolution of the HR time is better
  than 1 microsecond. For the IRIG receivers, the resolution is 400
  microseconds which is still much better than 10/15 milliseconds provided
  by the Windows system clock.
  
  To get most accuracy for time stamps, a program can read the PC's
  performance counter, and then call mbg_get_time_cycles() which returns
  the HR time plus the performance counter value which matches that HR
  time stamp. The difference between the two performance counter values
  can be used to compensate the program execution time delay.
  
  The way to access the time on the board is to write a command to the
  board's microcontroller which in turn makes the requested data available
   for reading. The advantage of this is that the interface is very
  flexible, but the disadvantage is that the on-board microcontroller is
  involved in any access to the board. In order to prevent applications
  from overruning the on-board microcontroller by countinuous accesses to
  the board the card has a limitation which limits the time between two 
  accesses to 200 microseconds and 1 millisecond depending on the device.

*/

/**
    \file
     Example program to read the high resolution time from 
     Meinberg computer peripherals
     using the mbgdevio (Meinberg Device I/O) DLL.
     
   \copydoc group_hrt
 
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


static int n_sec_change = 0;


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
      printf( "  %s at port %03Xh\n",
            _pcps_fw_id( p_dev ),
            _pcps_port_base( p_dev, 0 )
          ) :
      printf( "  %s\n",
            _pcps_fw_id( p_dev )
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


    // Some clocks (mainly GPS receivers and IRIG decoders) 
    // support a high resolution time. If supported, read and 
    // display the HR time.
    if ( _pcps_has_hr_time( &dev ) )
    {
      char ws[100];
      char offs[20];

      PCPS_HR_TIME hr_t;
      int32_t latency = 0;  
      int rc;

      // Read a high resolution time stamp with compensated latency. 
      // The function mbg_get_hr_time_comp() has been introduced in 
      // mbgdevio DLL v2.1.2 and compensates the execution time (latency) 
      // required to acces the hardware from inside the kernel driver. 

      #if 1 // use with mbgdevio DLL v2.1.2 or greater

 
        // The latency value can optionally be returned by this function. 
        // If the latency value is not required, a NULL pointer can be 
        // passed instead. The latency value is in hectonanoseconds [hns], 
        // i.e. 100 nanosecond units.

        rc = mbg_get_hr_time_comp( dh, &hr_t, &latency );
 
      #else  // the code below can be used with mbgdevio DLL < v2.1.2.

        rc = mbg_get_hr_time( dh, &hr_t );
 
      #endif

      if ( rc == PCPS_SUCCESS )
      {
        char latency_fmt[50];

        if ( latency )
          sprintf( latency_fmt,", latency: %i hns", latency);
        else
          strcpy(latency_fmt,"");

        // The format functions below are taken from mbgutil.dll.

        // Display PCPS_HR_TIME as raw data in hex format.
        mbg_str_pcps_hr_time_raw( ws, sizeof( ws ), &hr_t );
        printf( "  HR time (raw): %s %s\n\n", ws, latency_fmt );

        // Convert PCPS_HR_TIME into a readable timestamp with fractions as local time.
        mbg_str_pcps_hr_tstamp_loc( ws, sizeof( ws ), &hr_t );
        printf( "  HR timestamp (loc): %s%s\n", ws, latency_fmt);

        // Convert PCPS_HR_TIME into a readable timestamp with fractions as UTC time.
        mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &hr_t );
        printf( "  HR timestamp (utc): %s          %s\n", ws, latency_fmt);
  
        // Convert PCPS_HR_TIME into a readable date/time format as local time.
        mbg_str_pcps_hr_date_time_loc( ws, sizeof( ws ), &hr_t );
        mbg_str_pcps_hr_time_offs( offs, sizeof( offs ), &hr_t, "UTC" );
        printf( "  HR date/time (loc): %s %s%s\n", ws, offs, latency_fmt );

        // Convert PCPS_HR_TIME into a readable date/time format as UTC time.
        mbg_str_pcps_hr_date_time_utc( ws, sizeof( ws ), &hr_t );
        printf( "  HR date/time (utc): %s          %s\n", ws, latency_fmt );
      }
      else
        err_msg( "Failed to read High Resolution Time" );
    }

    mbg_close_device( &dh );

    printf( "\n" );
  }
  
  printf ( "\n" );

  return rc;
}
