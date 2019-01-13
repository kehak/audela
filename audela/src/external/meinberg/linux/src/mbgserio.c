
/**************************************************************************
 *
 *  $Id: mbgserio.c 1.4.2.7 2011/12/13 12:05:20 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Meinberg serial I/O functions.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgserio.c $
 *  Revision 1.4.2.7  2011/12/13 12:05:20  martin
 *  Revision 1.4.2.6  2011/12/13 08:36:50Z  martin
 *  Got rid of _mbg_open/clos/read/write() macros.
 *  Revision 1.4.2.5  2011/12/12 17:20:23  martin
 *  Revision 1.4.2.4  2011/12/12 16:11:28  martin
 *  Setup DCB under Windows when opening the port,
 *  not when setting parameters.
 *  Always use mbgserio_read/write rather than the macros.
 *  Revision 1.4.2.3  2011/08/23 09:37:26Z  martin
 *  Syntax workaround which is required until this module becomes a DLL.
 *  Revision 1.4.2.2  2011/08/19 07:45:40  martin
 *  New code trying different ways to detect existing ports reliably under Linux.
 *  Revision 1.4.2.1  2011/08/04 10:12:35  martin
 *  Flush output on close.
 *  Test USB converter ports under Linux.
 *  Revision 1.4  2011/07/29 10:12:15  martin
 *  Allow baud rates 115200 and 230400 under Linux, if supported by the OS version.
 *  Revision 1.3  2009/09/01 10:49:30  martin
 *  Cleanup for CVI.
 *  Use new portable timeout functions from mbg_tmo.h.
 *  Timeouts are now specified in milliseconds.
 *  Set DOS/v24tools low level receive timeout to minimum on open.
 *  Let functions return predefined codes.
 *  Revision 1.2  2008/09/04 15:34:18Z  martin
 *  Moved support for different target environments from other files here.
 *  Added mbgserio_set_parms() and don't set parms when opening a port.
 *  Fixed bugs in timeout calculations in mbgserio_read_wait().
 *  Preliminary support for port device lists.
 *  Revision 1.1  2007/11/12 16:48:02  martin
 *  Initial revision.
 *
 **************************************************************************/

#define _MBGSERIO
 #include <mbgserio.h>
#undef _MBGSERIO

#include <stdio.h>
#include <ctype.h>
#include <time.h>

#if defined( MBG_TGT_UNIX )
  #include <unistd.h>
  #include <fcntl.h>
  #include <dirent.h>
  #include <errno.h>
#endif



#if defined( MBG_TGT_UNIX )
  static const char dev_dir[] = "/dev";
#endif



#if defined( _USE_V24TOOLS )

/*------------------------------------------------------------------------
 * The definitions in this block and all v24...() functions are part of a
 * third-party library called V.24 Tools Plus by Langner Expertensysteme.
 *
 * This library may no be distributed freely, so the v24..() functions
 * must be replaced by user-written functions or some library available
 * to the user of this demo.
 *-----------------------------------------------------------------------*/

#ifdef __cplusplus
extern "C" {
#endif

int v24open( char *portname, int mode );
/* Open a port with specified name (e.g. "COM1"). The functions return a
 * handle to be used with the other functions. If the handle is < 0, the
 * port could not be opened.
 */

#define O_DIRECT     0x0100  /* Schnittstelle fuer direkten Hardware-Zugriff oeffnen     */
#define O_HIGHPRIO   0x2000  /* Schnittstelle mit hoher Prioritaet oeffnen (fastopen)    */

#define OPEN_MODE    ( O_DIRECT | O_HIGHPRIO )


int v24setparams( int port, long speed, int dbits, int parity, int stopbits );
/* Set the port's transmission speed, number of data bits, parity and
 * number of stop bits. Returns 0 on success.
 */

int v24qempty( int port, int which );
/* Returns 1 if the receive buffer is empty, 0 if it is not, or an other
 * value on error.
 */

int v24getch( int port );
/* Return a character from the receive buffer.
 */

int v24putc( int port, char c );
/* Write a character to the port.
 */

int v24close( int port );
/* Close the port
 */

#ifdef __cplusplus
}
#endif

#endif  // defined( _USE_V24TOOLS )

/*------------------------------------------------------------------------*/



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgserio_open( SERIAL_IO_STATUS *pst, const char *dev )
{
  MBG_PORT_HANDLE port_handle;

  #if defined( MBG_TGT_CVI )
  {
    int data_bits = 8;  //##++
    int parity_code = 0;
    int baud_rate = 19200;
    int stop_bits = 1;
    int i;
    int len;
    int rc;

    // Under CVI the port handle passed to OpenComConfig and used furtheron
    // corresponds to the COM port number, e.g. 1 for COM1, so we extract
    // the number from the device name passed as parameter.
    port_handle = 0;
    len = strlen( dev );

    for ( i = 0; i < len; i++ )
    {
      char c = dev[i];
      if ( c >= '0' && c <= '9' )
        break;
    }

    if ( i == len )
      return MBGSERIO_INV_CFG;   // no numeric substring found


    port_handle = atoi( &dev[i] );

    rc = OpenComConfig( port_handle, NULL, baud_rate, parity_code, data_bits, stop_bits, 8192, 1024);   //##++
    if ( rc < 0 )
      goto fail;

    pst->port_handle = port_handle;

    SetComTime( port_handle, 1.0 ); //##++
    SetXMode( port_handle, 0 );
  }
  #elif defined( MBG_TGT_WIN32 )
  {
    static const char *prefix = "\\\\.\\";

    COMMTIMEOUTS commtimeouts;
    DCB dcb;
    int len = strlen( prefix ) + strlen( dev ) + 1;
    char *tmp_name = (char *) malloc( len );

    if ( tmp_name == NULL )  // unable to allocate memory
      goto fail;


    strcpy( tmp_name, prefix );
    strcat( tmp_name, dev );

    port_handle = CreateFile( tmp_name, GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH,
        NULL );

    free( tmp_name );

    if ( port_handle == INVALID_HANDLE_VALUE )
      goto fail;


    pst->port_handle = port_handle;

    // save settings found at startup
    pst->old_dcb.DCBlength = sizeof( pst->old_dcb );
    GetCommState( port_handle, &pst->old_dcb );
    GetCommTimeouts( port_handle, &pst->old_commtimeouts );

    // configure our settings
    memcpy( &dcb, &pst->old_dcb, sizeof( dcb ) );
    dcb.fOutxCtsFlow = FALSE;      // CTS output flow control
    dcb.fOutxDsrFlow = FALSE;      // DSR output flow control
    dcb.fDtrControl = DTR_CONTROL_ENABLE;  // enable DTR for C28COM
    dcb.fDsrSensitivity = FALSE;   // don't require DSR input active
    //##++ more missing here
    dcb.fRtsControl = RTS_CONTROL_ENABLE;  // enable RTS for C28COM
    dcb.fOutX = FALSE;

#if 0 //##+++++++++++++++++++++++++++

    DWORD DCBlength;      /* sizeof(DCB)                     */
    DWORD BaudRate;       /* Baudrate at which running       */
    DWORD fBinary: 1;     /* Binary Mode (skip EOF check)    */
    DWORD fParity: 1;     /* Enable parity checking          */
    DWORD fOutxCtsFlow:1; /* CTS handshaking on output       */
    DWORD fOutxDsrFlow:1; /* DSR handshaking on output       */
    DWORD fDtrControl:2;  /* DTR Flow control                */
    DWORD fDsrSensitivity:1; /* DSR Sensitivity              */
    DWORD fTXContinueOnXoff: 1; /* Continue TX when Xoff sent */
    DWORD fOutX: 1;       /* Enable output X-ON/X-OFF        */
    DWORD fInX: 1;        /* Enable input X-ON/X-OFF         */
    DWORD fErrorChar: 1;  /* Enable Err Replacement          */
    DWORD fNull: 1;       /* Enable Null stripping           */
    DWORD fRtsControl:2;  /* Rts Flow control                */
    DWORD fAbortOnError:1; /* Abort all reads and writes on Error */
    DWORD fDummy2:17;     /* Reserved                        */
    WORD wReserved;       /* Not currently used              */
    WORD XonLim;          /* Transmit X-ON threshold         */
    WORD XoffLim;         /* Transmit X-OFF threshold        */
    BYTE ByteSize;        /* Number of bits/byte, 4-8        */
    BYTE Parity;          /* 0-4=None,Odd,Even,Mark,Space    */
    BYTE StopBits;        /* 0,1,2 = 1, 1.5, 2               */
    char XonChar;         /* Tx and Rx X-ON character        */
    char XoffChar;        /* Tx and Rx X-OFF character       */
    char ErrorChar;       /* Error replacement char          */
    char EofChar;         /* End of Input character          */
    char EvtChar;         /* Received Event character        */
    WORD wReserved1;      /* Fill for now.                   */
#endif

    SetCommState( port_handle, &dcb );

    memset( &commtimeouts, 0, sizeof( commtimeouts ) );
    SetCommTimeouts( port_handle, &commtimeouts );

    #if !defined( MBGSERIO_IN_BUFFER_SIZE )
      #define MBGSERIO_IN_BUFFER_SIZE 2048
    #endif

    #if !defined( MBGSERIO_OUT_BUFFER_SIZE )
      #define MBGSERIO_OUT_BUFFER_SIZE 2048
    #endif

//##+++++    SetupComm( port_handle, MBGSERIO_IN_BUFFER_SIZE, MBGSERIO_OUT_BUFFER_SIZE );

    PurgeComm( port_handle, PURGE_TXABORT|PURGE_TXCLEAR );
    PurgeComm( port_handle, PURGE_RXABORT|PURGE_RXCLEAR );

    //##++ mbgextio_set_console_control_handler();
  }
  #elif defined( MBG_TGT_UNIX )
  {
    // Open as not controlling TTY to prevent from being
    // killed if CTRL-C is received.
    // O_NONBLOCK is the same as O_NDELAY.
    port_handle = open( dev, O_RDWR | O_NOCTTY | O_NONBLOCK );

    //##++ TODO: Under Unix a serial port can by default be opened 
    // by several processes. However, we don't want that, so we 
    // should care about this using a lock file for the device 
    // and/or setting the TIOCEXCL flag (which unfortunately
    // is not an atomic operation with open()).

    if ( port_handle < 0 )  // check errno for the reason
      goto fail;


    pst->port_handle = port_handle;

    /* save current device settings */
    tcgetattr( port_handle, &pst->old_tio );

    // atexit( port_deinit );

    fflush( stdout );  //##++
    setvbuf( stdout, NULL, _IONBF, 0 );
  }
  #elif defined( MBG_TGT_DOS )
    #if defined( _USE_V24TOOLS )
    {
      port_handle = v24open( (char *) dev, OPEN_MODE );

      if ( port_handle < 0 )
        goto fail;

      pst->port_handle = port_handle;
      v24settimeout( port_handle, 1 );
    }
    #else

      #error Target DOS requires v24tools for serial I/O.

    #endif

  #else

    #error This target OS is not supported.

  #endif

  return 0;


fail:
  pst->port_handle = MBG_INVALID_PORT_HANDLE;
  return MBGSERIO_FAIL;

}  // mbgserio_open



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgserio_close( SERIAL_IO_STATUS *pst )
{
  if ( pst->port_handle != MBG_INVALID_PORT_HANDLE )
  {
    MBG_PORT_HANDLE port_handle = pst->port_handle;

    mbgserio_flush_tx( port_handle );

    #if defined( MBG_TGT_CVI )

      CloseCom( port_handle );

    #elif defined( MBG_TGT_WIN32 )

      SetCommState( port_handle, &pst->old_dcb );
      SetCommTimeouts( port_handle, &pst->old_commtimeouts );
      CloseHandle( port_handle );

    #elif defined( MBG_TGT_UNIX )

      tcsetattr( port_handle, TCSANOW, &pst->old_tio );
      close( port_handle );

    #elif defined( MBG_TGT_DOS )
      #if defined( _USE_V24TOOLS )

        v24close( port_handle );

      #else

        #error Target DOS requires v24tools for serial I/O.

      #endif

    #else

      #error This target OS is not supported.

    #endif

    pst->port_handle = MBG_INVALID_PORT_HANDLE;
  }

  return 0;

}  // mbgserio_close



#if defined( MBG_TGT_UNIX )

static /*HDR*/
int scandir_filter_serial_port( const struct dirent *pde )
{
  static const char dev_name_1[] = "ttyS";
  static const char dev_name_2[] = "ttyUSB";
  char tmp_str[100];
  SERIAL_IO_STATUS iost;
  int rc;

  int l;

  l = strlen( dev_name_1 );

  if ( strncmp( pde->d_name, dev_name_1, l ) == 0 )
    goto check;


  l = strlen( dev_name_2 );

  if ( strncmp( pde->d_name, dev_name_2, l ) == 0 )
    goto check;

  return 0;

check:
  // if the first character after the search string is not a digit
  // then the search result is not what we want
  if ( pde->d_name[l] < '0' || pde->d_name[l] > '9' )
    return 0;

  snprintf( tmp_str, sizeof( tmp_str ), "%s/%s", dev_dir, pde->d_name );

  rc = mbgserio_open( &iost, tmp_str );

  if ( rc < 0 )
  {
    #if defined( DEBUG )
      fprintf( stderr, "failed to open %s: %i\n", tmp_str, rc );
    #endif

    return 0;
  }

  #if defined( DEBUG )
    fprintf( stderr, "port %s opened successfully\n", tmp_str );
  #endif

  mbgserio_close( &iost );

  return 1;

}  // scandir_filter_serial_port

#endif  // defined( MBG_TGT_UNIX )



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgserio_setup_port_str_list( MBG_STR_LIST **list, int max_devs )
{
  MBG_STR_LIST *list_head;
  int n = 0;
  int i = 0;

  (*list) = (MBG_STR_LIST *) malloc( sizeof( **list ) );
  memset( (*list), 0, sizeof( **list ) );

  list_head = (*list);


#if 1 && defined( MBG_TGT_UNIX )

  struct dirent **namelist;

  n = scandir( dev_dir, &namelist, scandir_filter_serial_port, versionsort );

  if ( n < 0 )
    perror( "scandir" );
  else
  {
    for ( i = 0; i < n; i++ )
    {
      printf( "%s/%s\n", dev_dir, namelist[i]->d_name );
      free( namelist[i] );
    }

    free( namelist );
  }

#elif 1 && defined( MBG_TGT_UNIX )

  DIR *pd = opendir( dev_dir );

  if ( pd )
  {
    struct dirent *pde;

    while ( ( pde = readdir( pd ) ) != NULL )
    {
      if ( strncmp( pde->d_name, "ttyS", 4 ) == 0 )
        goto found;

      if ( strncmp( pde->d_name, "ttyUSB", 6 ) == 0 )
        goto found;

      continue;

found:
      fprintf( stderr, "found /dev/%s\n", pde->d_name );
    }

    closedir( pd );
  }

#else

  for ( i = 0; i < max_devs; i++ )
  {
    SERIAL_IO_STATUS iost;
    char dev_name[100] = { 0 };
    int rc;

    #if defined( MBG_TGT_WIN32 )
      sprintf( dev_name, "COM%i", i + 1 );
    #elif defined( MBG_TGT_LINUX )
      sprintf( dev_name, "/dev/ttyS%i", i );
    #endif

    rc = mbgserio_open( &iost, dev_name );

    if ( rc < 0 )
    {
      #if defined( MBG_TGT_LINUX )
        sprintf( dev_name, "/dev/ttyUSB%i", i );

        rc = mbgserio_open( &iost, dev_name );

        if ( rc < 0 )
          continue;

      #else  // non-Linux targets

        continue;

      #endif
    }

    mbgserio_close( &iost );

    (*list)->s = (char *) malloc( strlen( dev_name ) + 1 );
    strcpy( (*list)->s, dev_name );

    (*list)->next = (MBG_STR_LIST *) malloc( sizeof( **list ) );
    (*list) = (*list)->next;

    memset( (*list), 0, sizeof( **list ) );
    n++;

//    if ( ++i >= MBG_MAX_DEVICES )
//      break;
  }

  if ( n == 0 )
  {
    free( *list );
    list_head = NULL;
  }
#endif

  *list = list_head;

  return n;

}  // mbgserio_setup_port_str_list



/*HDR*/
_NO_MBG_API_ATTR void _MBG_API mbgserio_free_str_list( MBG_STR_LIST *list )
{
  int i = 0;

  while ( i < 1000 )  //##++
  {
    if ( list )
    {
      if ( list->s )
      {
        free( list->s );
        list->s = NULL;
      }

      if ( list->next )
      {
        MBG_STR_LIST *next = list->next;
        free( list );
        list = next;
      }
      else
      {
        if ( list )
        {
          free( list );
          list = NULL;
        }
        break;
      }
    }
    else
      break;

    i++;
  }

}  // mbgserio_free_str_list



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgserio_set_parms( SERIAL_IO_STATUS *pst, 
                                               uint32_t baud_rate, const char *framing )
{
  MBG_PORT_HANDLE port_handle = pst->port_handle;
  const char *cp;

  #if defined( MBG_TGT_CVI )
  {
    int data_bits = 8;
    int parity_code = 0; 
    int stop_bits = 1;
    int rc;

    // setup framing.
    for ( cp = framing; *cp; cp++ )
    {
      char c = toupper( *cp );

      switch ( c )
      {
        case '7':
        case '8':
          data_bits = c - '0';
          break;

        case 'N':
          parity_code = 0;
          break;

        case 'E':
          parity_code = 2;
          break;

        case 'O':
          parity_code = 1;
          break;

        case '1':
        case '2':
          stop_bits = c - '0';
          break;

        default:
          return MBGSERIO_INV_CFG;  // invalid framing string
      }
    }

    rc = OpenComConfig( port_handle, NULL, baud_rate, parity_code, 
                        data_bits, stop_bits, 8192, 1024 ); 
    if ( rc < 0 )
      return rc;

    SetComTime( port_handle, 1.0 ); //##++
    SetXMode( port_handle, 0 );
  }
  #elif defined( MBG_TGT_WIN32 )
  {
    DCB dcb;

    // get current settings
    dcb.DCBlength = sizeof( DCB );
    GetCommState( port_handle, &dcb );

    // update changed settings
    dcb.BaudRate = baud_rate;


    // setup framing.
    for ( cp = framing; *cp; cp++ )
    {
      char c = toupper( *cp );

      switch ( c )
      {
        case '7':
        case '8':
          dcb.ByteSize = c - '0';
          break;

        case 'N':
          dcb.Parity = NOPARITY;
          break;

        case 'E':
          dcb.Parity = EVENPARITY;
          break;

        case 'O':
          dcb.Parity = ODDPARITY;
          break;

        case '1':
          dcb.StopBits = ONESTOPBIT;
          break;

        case '2':
          dcb.StopBits = TWOSTOPBITS;
          break;

        default:
          return MBGSERIO_INV_CFG;  // invalid framing string
      }
    }


    SetCommState ( port_handle, &dcb );
  }
  #elif defined( MBG_TGT_UNIX )
  {
    tcflag_t c_cflag = 0;
    struct termios tio;

    tcgetattr( port_handle, &tio );

    // setup transmission speed
    switch( baud_rate )
    {
      case 300:    c_cflag = B300;    break;
      case 600:    c_cflag = B600;    break;
      case 1200:   c_cflag = B1200;   break;
      case 2400:   c_cflag = B2400;   break;
      case 4800:   c_cflag = B4800;   break;
      case 9600:   c_cflag = B9600;   break;
      case 19200:  c_cflag = B19200;  break;
      case 38400:  c_cflag = B38400;  break;
      case 57600:  c_cflag = B57600;  break;
      #if defined( B115200 )
        case 115200: c_cflag = B115200; break;
      #endif
      #if defined( B230400 )
        case 230400: c_cflag = B230400; break;
      #endif

      default: return MBGSERIO_INV_CFG;  // invalid
    }

    #if 0 //##++ This should be used preferably for portability reasons
       int cfsetispeed( struct termios *termios_p, speed_t speed );
       int cfsetospeed( struct termios *termios_p, speed_t speed );
    #endif

    // setup framing.
    for ( cp = framing; *cp; cp++ )
    {
      switch ( _toupper( *cp ) )
      {
        case '7':  c_cflag |= CS7;             break;
        case '8':  c_cflag |= CS8;             break;

        case 'N':                              break;
        case 'E':  c_cflag |= PARENB;          break;
        case 'O':  c_cflag |= PARENB | PARODD; break;

        case '1':                              break;
        case '2':  c_cflag |= CSTOPB;          break;

        default: return MBGSERIO_INV_CFG;  // invalid framing string
      }
    }


    // Setup control flags. The following flags are defined:
    //   CBAUD   (not in POSIX) Baud speed mask (4+1 bits).
    //   CBAUDEX (not in POSIX) Extra baud speed mask (1 bit), included in CBAUD.
    //           (POSIX says that the baud speed is stored in the termios structure
    //           without specifying where precisely, and provides cfgetispeed() and
    //           cfsetispeed() for getting at it. Some systems use bits selected
    //           by CBAUD in c_cflag, other systems use separate fields, 
    //           e.g. sg_ispeed and sg_ospeed.)
    //   CSIZE   Character size mask. Values are CS5, CS6, CS7, or CS8.
    //   CSTOPB  Set two stop bits, rather than one.
    //   CREAD   Enable receiver.
    //   PARENB  Enable parity generation on output and parity checking for input.
    //   PARODD  Parity for input and output is odd.
    //   HUPCL   Lower modem control lines after last process closes the device (hang up).
    //   CLOCAL  Ignore modem control lines.
    //   LOBLK   (not in POSIX) Block output from a noncurrent shell layer.
    //           (For use by shl)
    //   CIBAUD  (not in POSIX) Mask for input speeds. The values for the CIBAUD bits are
    //           the same as the values for the CBAUD bits, shifted left IBSHIFT bits.
    //   CRTSCTS (not in POSIX) Enable RTS/CTS (hardware) flow control.

    //   local connection, no modem control (CLOCAL)
    //   no flow control (no CRTSCTS)
    //   enable receiving
    tio.c_cflag = c_cflag | CLOCAL | CREAD;


    // Setup input flags. The following flags are defined:
    //   IGNBRK  Ignore BREAK condition on input
    //   BRKINT  If IGNBRK is set, a BREAK is ignored. If it is not set 
    //           but BRKINT is set, then a BREAK causes the input and output 
    //           queues to be flushed, and if the terminal is the controlling
    //           terminal of a foreground process group, it will cause a 
    //           SIGINT to be sent to this foreground process  group. When
    //           neither IGNBRK nor BRKINT are set, a BREAK reads as a NUL
    //           character, except when PARMRK is set, in which case it reads
    //           as the sequence \377 \0 \0.
    //   IGNPAR  Ignore framing errors and parity errors.
    //   PARMRK  If IGNPAR is not set, prefix a character with a parity error 
    //           framing error with \377 \0. If neither IGNPAR nor PARMRK or 
    //           is set, read a character with a parity error or framing error as \0.
    //   INPCK   Enable input parity checking.
    //   ISTRIP  Strip off eighth bit.
    //   INLCR   Translate NL to CR on input.
    //   IGNCR   Ignore carriage return on input.
    //   ICRNL   Translate carriage return to newline on input (unless IGNCR is set).
    //   IUCLC   (not in POSIX) Map uppercase characters to lowercase on input.
    //   IXON    Enable XON/XOFF flow control on output.
    //   IXANY   (not in POSIX.1; XSI) Enable any character to restart output.
    //   IXOFF   Enable XON/XOFF flow control on input.
    //   IMAXBEL (not in POSIX) Ring bell when input queue is full. Linux does not
    //           implement this bit, and acts as if it is always set.
    tio.c_iflag = 0;

    #if 0  //##++
    if ( c_cflag & PARENB )
      tio.c_iflag |= IGNPAR;  //##++ this also ignores framing errors
    #endif


    // Setup output flags. The following flags are defined:
    //   OPOST   Enable implementation-defined output processing.
    // The remaining c_oflag flag constants are defined in POSIX 1003.1-2001,
    // unless marked otherwise.
    //   OLCUC   (not in POSIX) Map lowercase characters to uppercase on output.
    //   ONLCR   (XSI) Map NL to CR-NL on output.
    //   OCRNL   Map CR to NL on output.
    //   ONOCR   Don't output CR at column 0.
    //   ONLRET  Don't output CR.
    //   OFILL   Send fill characters for a delay, rather than using a timed delay.
    //   OFDEL   (not in POSIX) Fill character is ASCII DEL (0177). If unset, 
    //           fill character is ASCII NUL.
    //   NLDLY   Newline delay mask. Values are NL0 and NL1.
    //   CRDLY   Carriage return delay mask. Values are CR0, CR1, CR2, or CR3.
    //   TABDLY  Horizontal tab delay mask. Values are TAB0, TAB1, TAB2, TAB3 
    //           (or XTABS). A value of TAB3, that is, XTABS, expands tabs to 
    //           spaces (with tab stops every eight columns).
    //   BSDLY   Backspace delay mask. Values are BS0 or BS1. 
    //           (Has never been implemented.)
    //   VTDLY   Vertical tab delay mask. Values are VT0 or VT1.
    //   FFDLY   Form feed delay mask. Values are FF0 or FF1.
    tio.c_oflag = 0;


    // Setup local mode flags. The following flags are defined:
    //   ISIG    When any of the characters INTR, QUIT, SUSP, or DSUSP are
    //           received, generate the corresponding signal.
    //   ICANON  Enable canonical mode. This enables the special characters
    //           EOF, EOL, EOL2, ERASE, KILL, LNEXT, REPRINT, STATUS, and
    //           WERASE, and buffers by lines.
    //   XCASE   (not in POSIX; not supported under Linux) If ICANON is also
    //           set, terminal is uppercase only. Input is converted to 
    //           lowercase, except for characters preceded by \. On output, 
    //           uppercase characters are preceded by \ and lowercase 
    //           characters are converted to uppercase.
    //   ECHO    Echo input characters.
    //   ECHOE   If ICANON is also set, the ERASE character erases the preceding 
    //           input character, and WERASE erases the preceding word.
    //   ECHOK   If ICANON is also set, the KILL character erases the current line.
    //   ECHONL  If ICANON is also set, echo the NL character even if ECHO is not set.
    //   ECHOCTL (not  in  POSIX) If ECHO is also set, ASCII control signals
    //           other than TAB, NL, START, and STOP are echoed as ^X, where
    //           X is the character with ASCII code 0x40 greater than the control 
    //           signal. For example, character 0x08 (BS) is echoed as ^H.
    //   ECHOPRT (not in POSIX) If ICANON and IECHO are also set, characters are 
    //           printed as they are being erased.
    //   ECHOKE  (not in POSIX) If ICANON is also set, KILL is echoed by erasing 
    //           each character on the line, as specified by ECHOE and ECHOPRT.
    //   DEFECHO (not in POSIX) Echo only when a process is reading.
    //   FLUSHO  (not in POSIX; not supported under Linux) Output is being flushed.
    //           This flag is toggled by typing the DISCARD character.
    //   NOFLSH  Disable flushing the input and output queues when generating the
    //           SIGINT, SIGQUIT and SIGSUSP signals.
    //   TOSTOP  Send the SIGTTOU signal to the process group of a background 
    //           process which tries to write to its controlling terminal.
    //   PENDIN  (not in POSIX; not supported under Linux) All characters in the
    //           input queue are reprinted when the next character is read. 
    //           (bash  handles typeahead this way.)
    //   IEXTEN  Enable implementation-defined input processing. This flag, as
    //           well as ICANON must be enabled for the special characters EOL2, 
    //           LNEXT, REPRINT, WERASE to be interpreted, and for the IUCLC flag
    //           to be effective.
    tio.c_lflag = 0;


    //   VINTR   (003, ETX, Ctrl-C, or also 0177, DEL, rubout) Interrupt character.
    //           Send a SIGINT signal. Recognized when ISIG is set, and then not 
    //           passed as input.
    //   VQUIT   (034, FS, Ctrl-\) Quit character. Send SIGQUIT signal. Recognized
    //           when ISIG is set, and then not passed as input.
    //   VERASE  (0177, DEL, rubout, or 010, BS, Ctrl-H, or also #) Erase character.
    //           This erases the previous not-yet-erased character, but does not erase
    //           past EOF or beginning-of-line. Recognized when ICANON is set, 
    //           and then not passed as input.
    //   VKILL   (025, NAK, Ctrl-U, or Ctrl-X, or also @) Kill character. This erases
    //           the input since the last EOF or beginning-of-line. Recognized when
    //           ICANON is set, and then not passed as input.
    //   VEOF    (004, EOT, Ctrl-D) End-of-file character. More precisely: this 
    //           character causes the pending tty buffer to be sent to the waiting
    //           user program without waiting for end-of-line. If it is the first
    //           character of the line, the read() in the user program returns 0,
    //           which signifies end-of-file. Recognized when ICANON is set, and
    //           then not passed as input.
    //   VMIN    Minimum number of characters for non-canonical read.
    //   VEOL    (0, NUL) Additional end-of-line character. Recognized when ICANON is set.
    //   VTIME   Timeout in deciseconds for non-canonical read.
    //   VEOL2   (not in POSIX; 0, NUL) Yet another end-of-line character.
    //           Recognized when ICANON is set.
    //   VSWTCH  (not in POSIX; not supported under Linux; 0, NUL) Switch character.
    //           (Used by shl only.)
    //   VSTART  (021, DC1, Ctrl-Q) Start character. Restarts output stopped by the Stop
    //           character. Recognized when IXON is set, and then not passed as input.
    //   VSTOP   (023, DC3, Ctrl-S) Stop character. Stop output until Start character
    //           typed. Recognized when IXON is set, and then not passed as input.
    //   VSUSP   (032, SUB, Ctrl-Z) Suspend character. Send SIGTSTP signal. Recognized
    //           when ISIG is set, and then not passed as input.
    //   VDSUSP  (not in POSIX; not supported under Linux; 031, EM, Ctrl-Y) Delayed 
    //           suspend character: send SIGTSTP signal when the character is read by
    //           the user program. Recognized when IEXTEN and ISIG are set, and the 
    //           system supports job control, and then not passed as input.
    //   VLNEXT  (not in POSIX; 026, SYN, Ctrl-V) Literal next. Quotes the next input
    //           character, depriving it of a possible special meaning.  Recognized
    //           when IEXTEN is set, and then not passed as input.
    //   VWERASE (not in POSIX; 027, ETB, Ctrl-W) Word erase. Recognized when ICANON
    //           and IEXTEN are set, and then not passed as input.
    //   VREPRINT (not in POSIX; 022, DC2, Ctrl-R) Reprint unread characters. Recognized
    //           when ICANON and IEXTEN are set, and then not passed as input.
    //   VDISCARD (not in POSIX; not supported under Linux; 017, SI, Ctrl-O) Toggle: 
    //           start/stop discarding pending output. Recognized when IEXTEN is set,
    //           and then not passed as input.
    //   VSTATUS (not in POSIX; not supported under Linux; status request: 024, DC4, Ctrl-T).


    // Setting up c_cc[VMIN] and c_cc[VTIME]:
    // If MIN > 0 and TIME = 0, MIN sets the number of characters to receive before 
    //            the read is satisfied. As TIME is zero, the timer is not used.
    // If MIN = 0 and TIME > 0, TIME serves as a timeout value. The read will be
    //            satisfied if a single character is read, or TIME is exceeded 
    //            (t = TIME *0.1 s). If TIME is exceeded, no character will be 
    //            returned.
    // If MIN > 0 and TIME > 0, TIME serves as an inter-character timer. The
    //            read will be satisfied if MIN characters are received, or the
    //            time between two characters exceeds TIME. The timer is restarted
    //            every time a character is received and only becomes active after
    //            the first character has been received.
    // If MIN = 0 and TIME = 0, read will be satisfied immediately. The number of
    //            characters currently available, or the number of characters 
    //            requested will be returned. You could issue a 
    //            fcntl(fd, F_SETFL, FNDELAY); before reading to get the same result.

    // setup control characters for non-blocking read
    tio.c_cc[VMIN] = 0;
    tio.c_cc[VTIME] = 0;

    // now clean the modem line and activate the settings for modem
    tcflush( port_handle, TCIFLUSH );
    tcsetattr( port_handle, TCSANOW, &tio );

    fflush( stdout );
    setvbuf( stdout, NULL, _IONBF, 0 );
  }
  #elif defined( MBG_TGT_DOS )
    #if defined( _USE_V24TOOLS )
    {
      int datab = 8;
      char parity = 'N';
      int stopb = 1;

      // setup framing.
      for ( cp = framing; *cp; cp++ )
      {
        char c = toupper( *cp );

        switch ( c )
        {
          case '7':
          case '8':
            datab = c - '0';
            break;

          case 'N':
          case 'E':
          case 'O':
            parity = *cp;
            break;

          case '1':
          case '2':
            stopb = c - '0';
            break;

          default:
            return MBGSERIO_INV_CFG;  // invalid framing string
        }
      }

      v24setparams( port_handle, baud_rate, datab, parity, stopb );
    }
    #else

      #error This has to be modified for DOS without v24tools.

    #endif

  #else

    #error This target OS is not supported.

  #endif

  return 0;

}  // mbgserio_set_parms



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgserio_read( MBG_PORT_HANDLE h, void *buffer, unsigned int count )
{
  #if defined( MBG_TGT_CVI )

    return ComRd( h, (char *) buffer, count );

  #elif defined( MBG_TGT_WIN32 )

    BOOL fReadStat;
    COMSTAT ComStat;
    DWORD dwErrorFlags;
    DWORD dwLength;

    ClearCommError( h, &dwErrorFlags, &ComStat );

    if ( dwErrorFlags )  // transmission error (parity, framing, etc.)
      return MBGSERIO_FAIL;


    dwLength = min( (DWORD) count, ComStat.cbInQue );

    if ( dwLength )
    {
      fReadStat = ReadFile( h, buffer, dwLength, &dwLength, NULL );

      if ( !fReadStat )
        return MBGSERIO_FAIL;
    }

    return dwLength;

  #elif defined( MBG_TGT_UNIX )

    return read( h, buffer, count );

  #elif defined( MBG_TGT_DOS ) && defined( _USE_V24TOOLS )

    return v24read( h, buffer, count );

  #else

    #error mbgserio_read() not implemented for this target

  #endif

} // mbgserio_read



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgserio_write( MBG_PORT_HANDLE h, const void *buffer, unsigned int count )
{
  #if defined( MBG_TGT_CVI )

    return ComWrt( h, (char *) buffer, count );

  #elif defined( MBG_TGT_WIN32 )

    BOOL fWriteStat;
    COMSTAT ComStat;
    DWORD dwErrorFlags;
    DWORD dwThisBytesWritten;
    DWORD dwTotalBytesWritten = 0;

    while ( dwTotalBytesWritten < (DWORD) count )
    {
      dwThisBytesWritten = 0;

      fWriteStat = WriteFile( h, ( (char *) buffer ) + dwTotalBytesWritten,
                              count - dwTotalBytesWritten,
                              &dwThisBytesWritten, NULL );
      if ( !fWriteStat )
      {
        #if defined( _DEBUG )
          DWORD dw = GetLastError();
        #endif
        break;   //##++ Error: Unable to write
      }

      dwTotalBytesWritten += dwThisBytesWritten;

      ClearCommError( h, &dwErrorFlags, &ComStat );

      if ( dwErrorFlags )
        break;   //#++ Error: Check flags
    }

    return dwTotalBytesWritten;

  #elif defined( MBG_TGT_UNIX )

    return write( h, buffer, count );

  #elif defined( MBG_TGT_DOS ) && defined( _USE_V24TOOLS )

    return v24write( h, buffer, count );

  #else

    #error mbgserio_write() not implemented for this target

  #endif

}  // mbgserio_write



/*HDR*/
_NO_MBG_API_ATTR void _MBG_API mbgserio_flush_tx( MBG_PORT_HANDLE h )
{
  #if defined( MBG_TGT_CVI )

    FlushOutQ( h );

  #elif defined( MBG_TGT_WIN32 )

    FlushFileBuffers( h );
  
  #elif defined( MBG_TGT_UNIX )

    tcdrain( h );

  #elif defined( MBG_TGT_DOS ) && defined( _USE_V24TOOLS )

    v24flush( h, SND );

  #else

    #error mbgserio_flush_tx() not implemented for this target

  #endif

}  // mbgserio_flush_tx



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgserio_read_wait( MBG_PORT_HANDLE h, void *buffer,
                                                  uint count, ulong char_timeout )
{
  int n_bytes;

  #if _USE_SELECT_FOR_SERIAL_IO

    struct timeval tv_char_timeout;
    fd_set fds;
    int rc;

    mbgserio_msec_to_timeval( char_timeout, &tv_char_timeout );

    FD_ZERO( &fds );
    FD_SET( h, &fds );

    rc = select( h + 1, &fds, NULL, NULL, &tv_char_timeout );

    if ( rc < 0 )     // error
      goto fail;

    if ( rc == 0 )    // timeout
      goto timeout;

    // data is available
    n_bytes = mbgserio_read( h, buffer, count );

  #else
    MBG_TMO_TIME tmo;

    mbg_tmo_set_timeout_ms( &tmo, char_timeout );

    for (;;)  // wait to read one new char
    {
      n_bytes = mbgserio_read( h, buffer, count );

      if ( n_bytes > 0 )     // new char(s) received
        break;

      if ( n_bytes < 0 )     // error
        goto fail;

      if ( mbg_tmo_curr_time_is_after( &tmo ) )
        goto timeout;

      #if defined( MBG_TGT_UNIX )
        usleep( 10 * 1000 );
      #endif
    }
  #endif

  return n_bytes;

timeout:
  return MBGSERIO_TIMEOUT;

fail:
  return MBGSERIO_FAIL;

}  // mbgserio_read_wait



