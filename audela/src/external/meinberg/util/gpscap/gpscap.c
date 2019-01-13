
/**************************************************************************
 *
 *  $Id: mbggpscap.c 1.10.1.6 2011/09/09 08:28:22 martin TEST $
 *
 *  Description:
 *    Main file for mbggpscap program which demonstrates how to access
 *    a Meinberg device via IOCTL calls and read entries from the time
 *    capture FIFO buffer.
 *
 *    Please note that this may only work with devices which provide
 *    time capture input(s).
 *
 * -----------------------------------------------------------------------
 *  $Log: mbggpscap.c $
 *  Revision 1.10.1.6  2011/09/09 08:28:22  martin
 *  Revision 1.10.1.5  2011/09/07 15:12:33  martin
 *  New option -r which displays raw timestamps and raw status.
 *  New option -o which forces usage of old API.
 *  Fixed a bug when displaying the capture event status. TTM and PCPS_HR_TIME
 *  are using different sets of status flags.
 *  Revision 1.10.1.4  2011/07/05 15:35:54  martin
 *  Modified version handling.
 *  Revision 1.10.1.3  2011/07/05 14:35:18  martin
 *  New way to maintain version information.
 *  Revision 1.10.1.2  2010/11/12 12:27:17  martin
 *  Improved reading capture events arriving at a high rate.
 *  Support validation of capture signals arriving at a constant rate.
 *  Revision 1.10.1.1  2010/03/10 16:42:33  martin
 *  Improved code execution paths.
 *  Revision 1.10  2009/09/29 15:02:15  martin
 *  Updated version number to 3.4.0.
 *  Revision 1.9  2009/07/24 09:50:08  martin
 *  Updated version number to 3.3.0.
 *  Revision 1.8  2009/06/19 12:38:51  martin
 *  Updated version number to 3.2.0.
 *  Revision 1.7  2009/03/19 17:04:26  martin
 *  Updated version number to 3.1.0.
 *  Updated copyright year to include 2009.
 *  Revision 1.6  2008/12/22 12:00:55  martin
 *  Updated description, copyright, revision number and string.
 *  Use unified functions from toolutil module.
 *  Accept device name(s) on the command line.
 *  Don't use printf() without format, which migth produce warnings
 *  with newer gcc versions.
 *  Revision 1.5  2007/07/24 09:32:26  martin
 *  Updated copyright to include 2007.
 *  Revision 1.4  2006/02/22 15:29:17  martin
 *  Support new ucap API.
 *  Print an error message if device can't be opened.
 *  Revision 1.3  2004/11/08 15:47:10  martin
 *  Using type cast to avoid compiler warning.
 *  Revision 1.2  2003/04/25 10:28:05  martin
 *  Use new functions from mbgdevio library.
 *  New program version v2.1.
 *  Revision 1.1  2001/09/17 15:08:22  martin
 *
 **************************************************************************/

// include Meinberg headers
#include <mbgdevio.h>
#include <pcpsutil.h>
#include <toolutil.h>  // common utility functions

// include system headers
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

// Schiavon MODIFY
#include <signal.h>

#define USLEEP_INTV  10000  // [microseconds]
// End MODIFY


#define MBG_MICRO_VERSION          0
#define MBG_FIRST_COPYRIGHT_YEAR   2001
#define MBG_LAST_COPYRIGHT_YEAR    0     // use default

// Schiavon MODIFY
static const char *pname = "gpscap";
FILE *out;
// End MODIFY


static int continuous;
static double nom_cap_intv;    // nominal capture interval to check [s]
static double max_cap_jitter;  // max allowed jitter [s]
static int raw;
static int force_old_api;

static int has_been_called;
static int must_check_intv;
static ulong err_cnt;
static PCPS_HR_TIME prv_ucap;


// Schiavon MODIFY
static /*HDR*/
void show_ucap_event( const PCPS_HR_TIME *ucap)
{
  char ws[80];

  // Print converted date and time to a string:
  mbg_snprint_hr_time( ws, sizeof( ws ), ucap, raw );

	// Schiavon MODIFY
  // Print the time stamp
  fprintf( out, "CH$i %s", ucap->signal, ws );
	// End MODIFY

  if ( must_check_intv && has_been_called )
  {
    double abs_delta;
    double d = ucap->tstamp.sec - prv_ucap.tstamp.sec;
    d += ( (double) ucap->tstamp.frac - prv_ucap.tstamp.frac ) / PCPS_HRT_BIN_FRAC_SCALE;

    fprintf(out, " %+.6f", d );

    abs_delta = d - nom_cap_intv;

    if ( abs_delta < 0.0 )
      abs_delta = -abs_delta;

    if ( abs_delta > max_cap_jitter )
      err_cnt++;

    if ( err_cnt )
      fprintf(out, " ** %lu", err_cnt );
  }

  // status bit definitions can be found in pcpsdefs.h.

  if ( raw )
    fprintf(out, ", st: 0x%04X", ucap->status );

  if ( ucap->status & PCPS_UCAP_OVERRUN )     // capture events have occurred too fast
    fprintf(out, " << CAP OVR" );

  if ( ucap->status & PCPS_UCAP_BUFFER_FULL ) // capture buffer has been full, events lost
    fprintf(out, " << BUF OVR" );

  prv_ucap = *ucap;
  has_been_called = 1;

  fprintf(out, "\n" );

	fflush(out);

}  // show_ucap_event
// End MODIFY


// The function below is normally outdated, and show_ucap_event()
// above should be used if possible, together with the associated
// API calls.

static /*HDR*/
void show_gps_ucap( const TTM *ucap )
{
  printf( "New capture: CH%i: %04i-%02i-%02i  %2i:%02i:%02i.%07li",
          ucap->channel,
          ucap->tm.year,
          ucap->tm.month,
          ucap->tm.mday,
          ucap->tm.hour,
          ucap->tm.min,
          ucap->tm.sec,
          (ulong) ucap->tm.frac
        );

  if ( raw )
    printf( ", st: 0x%04lX", (ulong) ucap->tm.status );

  printf( "\n" );

}  // show_gps_ucap



static /*HDR*/
void check_serial_mode( MBG_DEV_HANDLE dh )
{
  PORT_PARM port_parm;
  int i;
  int must_modify = 0;

  // read the clock's current port settings
  int rc = mbg_get_gps_port_parm( dh, &port_parm );

  if ( mbg_ioctl_err( rc, "mbg_get_gps_port_parm" ) )
    return;


  // If one of the ports has been set to send user captures
  // then the user capture buffer will most often be empty
  // if we check for captures, so modify the port mode.
  for ( i = 0; i < N_COM; i++ )
  {
    if ( port_parm.mode[i] == STR_UCAP )
    {
      port_parm.mode[i] = STR_UCAP_REQ;
      must_modify = 1;
    }
  }

  if ( !must_modify )
    return;


  rc = mbg_set_gps_port_parm( dh, &port_parm );

  if ( mbg_ioctl_err( rc, "mbg_set_gps_port_parm" ) )
    return;

  printf( "NOTE: the clock's serial port mode has been changed.\n" );

}  // check_serial_mode



static /*HDR*/
int do_mbggpscap( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev )
{
  int rc;

  must_check_intv = continuous && ( nom_cap_intv != 0 );
  has_been_called = 0;
  err_cnt = 0;

  if ( !_pcps_has_ucap( p_dev ) && !_pcps_is_gps( p_dev ) )
  {
    printf( "This device type does not provide time capture inputs.\n" );
    return 0;
  }

  check_serial_mode( dh );

	// Schiavon MODIFY
  //printf( "Be sure the card has been properly configured to enable capture inputs.\n" );
	// End MODIFY

  // There's an older API which has been introduced with the first GPS boards
  // and uses the TTM structure to return the capture events. However, that
  // API call is slow and not very flexible, so a new set of API calls has been
  // introduced to handle capture events.
  // The new API calls are supported by all supported by all newer boards which
  // provide user capture inputs, and also for older boards with a firmware update.

  if ( !force_old_api && _pcps_has_ucap( p_dev ) )  // check if the new API is supported
  {
    // The new API provides the following functions:
    //   mbg_clr_ucap_buff()     clear the on-board FIFO buffer
    //   mbg_get_ucap_entries()  get the max number of FIFO entries, and the current number of entries
    //   mbg_get_ucap_event()    read one entry from the FIFO

		// Schiavon ADD
		rc = mbg_clr_ucap_buff(dh);

		if ( rc != MBG_SUCCESS )
		{
			printf("WARNING: impossible to clear the on-board FIFO buffer");
		}
		// End ADD

    PCPS_UCAP_ENTRIES ucap_entries;

    // retrieve and print information of the maximum number of events that can
    // be stored in the on-board FIFO, and the number of events that are currently
    // stored
    rc = mbg_get_ucap_entries( dh, &ucap_entries );

    if ( rc == MBG_SUCCESS )
    {
      // Cards report they could save one more capture event
      // than they actually do save, so adjust the reported value
      // for a proper display.
      if ( ucap_entries.max )
        ucap_entries.max--;

			// Schiavon MODIFY
      /*printf( "\nOn-board FIFO: %u of %u entries used\n\n",
              ucap_entries.used, ucap_entries.max );*/
			// End MODIFY
    }

    // If the program is not to run continuously and no
    // capture events are available then we're through.
    if ( !continuous && ucap_entries.used == 0 )
      return 0;

		// Schiavon MODIFY
    /*printf( ( ucap_entries.used == 0 ) ?
            "Waiting for capture events:\n" :
            "Reading capture events:\n"
          );*/
		// End MODIFY

    // Now read out all events from the FIFO and wait
    // for new events if the FIFO is empty.
    for (;;)
    {
      PCPS_HR_TIME ucap_event;

      rc = mbg_get_ucap_event( dh, &ucap_event );

      if ( mbg_ioctl_err( rc, "mbg_get_ucap_event" ) )
        break;  // an error has occurred

      // If a user capture event has been read then it
      // has been removed from the card's FIFO buffer.

      // If the time stamp is not 0 then a new capture event has been retrieved.
      if ( ucap_event.tstamp.sec || ucap_event.tstamp.frac )
      {
        show_ucap_event( &ucap_event );
        continue;
      }

      usleep( USLEEP_INTV );   // sleep, then try again
    }
  }
  else    // use the old API
  {
    printf( "Checking for capture events using the old API:\n" );

    for (;;)
    {
      TTM ucap_ttm;

      rc = mbg_get_gps_ucap( dh, &ucap_ttm );

      if ( mbg_ioctl_err( rc, "mbg_get_gps_ucap" ) )
        break;  // an error has occurred


      // If a user capture event has been read then it
      // has been removed from the card's FIFO buffer.

      // If a new capture event has been available then
      // the ucap.tm contains a time stamp.
      if ( _pcps_time_is_read( &ucap_ttm.tm ) )
        show_gps_ucap( &ucap_ttm );

      if ( !continuous )
      {
        printf( "No capture event available!\n" );
        break;
      }

      //usleep( USLEEP_INTV );   // sleep, then try again
    }
  }

  return 0;

}  // do_mbggpscap



static /*HDR*/
void usage( void )
{
  mbg_print_usage_intro( pname,
    "This example program reads time capture events from a card.\n"
    "This works only with cards which provide time capture inputs."
  );
  mbg_print_help_options();
  mbg_print_opt_info( "-c", "run continuously" );
  mbg_print_opt_info( "-i val", "check interval between captures events [s]" );
  mbg_print_opt_info( "-j val", "max allowed jitter of capture interval [s]" );
  mbg_print_opt_info( "-r", "show raw (hex) timestamp and status)" );
  mbg_print_opt_info( "-o", "force usage of old API (for testing only)" );
  mbg_print_device_options();
  puts( "" );

}  // usage

// Schiavon ADD
void sigint(int signal) {
	exit(0);
}
// End ADD

// Schiavon ADD
void exit_func(void) {
	fflush(out);
	fclose(out);
}
// End ADD

int main( int argc, char *argv[] )
{
  int rc;
  int c;

	// Schiavon ADD
	signal(SIGINT,sigint);
	atexit(exit_func);
	// End ADD

	// Schiavon MODIFY
  //mbg_print_program_info( pname, MBG_MICRO_VERSION, MBG_FIRST_COPYRIGHT_YEAR, MBG_LAST_COPYRIGHT_YEAR );
	// End MODIFY

	// Schiavon ADD
	out = stdout;
	// End ADD

  // check command line parameters
  while ( ( c = getopt( argc, argv, "ci:j:rof:h?" ) ) != -1 )
  {
    switch ( c )
    {
      case 'c':
        continuous = 1;
        break;

      case 'i':
        nom_cap_intv = atof( optarg );
        break;

      case 'j':
        max_cap_jitter = atof( optarg );
        break;

      case 'r':
        raw = 1;
        break;

      case 'o':
        force_old_api = 1;
        break;

			case 'f':
				out = fopen(optarg,"w");
				break;

      case 'h':
      case '?':
      default:
        must_print_usage = 1;
    }
  }

	// Schiavon ADD
	continuous = 1;
	// End ADD

  if ( must_print_usage )
  {
    usage();
    return 1;
  }

  // The function below checks which devices have been specified
  // on the command, and for each device
  // - tries to open the device
  // - shows basic device info
  // - calls the function passed as last parameter
  rc = mbg_check_devices( argc, argv, optind, do_mbggpscap );

  return abs( rc );
}
