
/**************************************************************************
 *
 *  $Id: mbgextio.c 1.11.2.11 2011/12/13 08:35:52 martin TEST martin $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Meinberg extended I/O functions for the binary data protocol
 *    via serial communication and network socket I/O.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgextio.c $
 *  Revision 1.11.2.11  2011/12/13 08:35:52  martin
 *  Revision 1.11.2.10  2011/12/12 16:09:20  martin
 *  Tmp. debug code.
 *  Assume output is flushed when enforcing connection.
 *  Revision 1.11.2.9  2011/11/28 16:13:54Z  martin
 *  Revision 1.11.2.8  2011/11/28 15:46:25Z  martin
 *  Fixed opening socket connection.
 *  Revision 1.11.2.7  2011/11/25 15:11:19  martin
 *  Account for renamed event log library symbols.
 *  Revision 1.11.2.6  2011/11/21 16:34:12  marvin
 *  new function: support event log
 *  Revision 1.11.2.5  2011/09/20 15:34:18  marvin
 *  tmp: define MBGEXTIO_DIRECT_RC changed from 0 to 1
 *  Revision 1.11.2.4  2011/08/31 09:09:53  marvin
 *  Cast pointers returned by malloc().
 *  Revision 1.11.2.3  2011/08/23 09:56:39  martin
 *  Syntax workaround which is required until this module becomes a DLL.
 *  Revision 1.11.2.2  2011/08/19 13:36:15  martin
 *  Revision 1.11.2.1  2011/08/19 13:05:10  martin
 *  Started to migrate to opaque stuctures.
 *  Revision 1.11  2011/04/15 13:17:14  martin
 *  Use common mutex support macros from mbgmutex.h.
 *  Revision 1.10  2011/04/08 11:28:24  martin
 *  Modified mbgextio_get_ucap() to account for different device behaviour.
 *  Added missing braces.
 *  Revision 1.9  2009/10/02 14:19:05  martin
 *  Added a bunch of missing functions.
 *  Revision 1.8  2009/10/01 11:10:51  martin
 *  Added functions to set/retrieve char and msg rcv timeout.
 *  Revision 1.7  2009/09/01 10:44:58  martin
 *  Cleanup for CVI.
 *  Use new portable timeout functions from mbg_tmo.h.
 *  Timeouts are now specified in milliseconds.
 *  Distinguish between character timeout and message timeout.
 *  Only fetch one character at a time to prevent received characters
 *  from being discarded after the end of one message.
 *  Revision 1.6  2009/03/10 17:02:08Z  martin
 *  Added support for configurable time scales.
 *  Added mbgextio_get_time() call.
 *  Fixed some compiler warnings.
 *  Revision 1.5  2008/09/04 14:35:50Z  martin
 *  Fixed opening COM port under CVI.
 *  Moved generic serial I/O stuff to mbgserio.c and mbgserio.h.
 *  Restart reception if received msg does not match expected cmd code.
 *  Fixed timeout value for Windows.
 *  New symbol _MBGEXTIO_DIRECT_RC controls whether the return code of the 
 *  mbgextio_set_...() functions is evaluated or returned as-is.
 *  New functions mbgextio_set_time(), mbgextio_set_tzdl().
 *  Added mbgextio_get_ucap(). This may not work with older firmware,
 *  see the comments in mbgextio_get_ucap().
 *  Conditionally support checking of time strings.
 *  Revision 1.4  2007/02/27 10:35:19Z  martin
 *  Added mutex for transmit buffer to make transmission thread-safe.
 *  Fixed timeout handling for serial reception.
 *  Renamed mbgextio_get_data() to mbgextio_rcv_msg().
 *  Added some new functions.
 *  Temp. changes for parameter setting functions.
 *  Added comments on POSIX flags used when opening serial port.
 *  Revision 1.3  2006/12/21 10:56:17  martin
 *  Added function mbgextio_set_port_parm.
 *  Revision 1.2  2006/10/25 12:18:31  martin
 *  Support serial I/O under Windows.
 *  Revision 1.1  2006/08/24 12:40:37Z  martin
 *  Initial revision.
 *
 **************************************************************************/

#define _MBGEXTIO
  #include <mbgextio.h>
#undef _MBGEXTIO

#include <mbgserio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gpsutils.h>

#if defined( MBG_TGT_UNIX )
  #include <unistd.h>
  #include <fcntl.h>
#include "gpsserio.h"
#include "gpsserio.h"
#include "gpsserio.h"
#include "gpsserio.h"
#else
  typedef int ssize_t;
#endif

#if !defined( MBGEXTIO_DIRECT_RC )
  #define _MBGEXTIO_DIRECT_RC     1
#endif


// default serial message timeout
#if !defined ( MBGEXTIO_MSG_RCV_TIMEOUT_SERIAL )
  #define MBGEXTIO_MSG_RCV_TIMEOUT_SERIAL     3000  // [ms]
#endif

// default serial single character timeout
#if !defined ( MBGEXTIO_CHAR_RCV_TIMEOUT_SERIAL )
  #define MBGEXTIO_CHAR_RCV_TIMEOUT_SERIAL     200  // [ms]
#endif



static /*HDR*/
void dealloc_msg_ctl( MBG_MSG_CTL **ppmctl )
{
  MBG_MSG_CTL *pmctl = *ppmctl;

  if ( pmctl )
  {
    if ( pmctl->xmt.pmb )
    {
      free( pmctl->xmt.pmb );
      pmctl->xmt.pmb = NULL;
    }

    pmctl->xmt.buf_size = 0;

    if ( pmctl->xmt.pmb )
    {
      free( pmctl->xmt.pmb );
      pmctl->xmt.pmb = NULL;
    }

    pmctl->rcv.buf_size = 0;

    free( pmctl );
    *ppmctl = NULL;
  }

}  // dealloc_msg_ctl



static /*HDR*/
MBG_MSG_CTL *alloc_msg_ctl( void )
{
  MBG_MSG_CTL *pmctl = (MBG_MSG_CTL *) malloc( sizeof( *pmctl ) );

  if ( pmctl )
  {
    memset( pmctl, 0, sizeof( *pmctl ) );

    pmctl->rcv.buf_size = sizeof( *(pmctl->rcv.pmb) );
    pmctl->rcv.pmb = (MBG_MSG_BUFF *) malloc( pmctl->rcv.buf_size );

    pmctl->xmt.buf_size = sizeof( *(pmctl->xmt.pmb) );
    pmctl->xmt.pmb = (MBG_MSG_BUFF *) malloc( pmctl->xmt.buf_size );

    // if memory could not be allocated, clean up
    if ( ( pmctl->rcv.pmb == NULL ) || ( pmctl->xmt.pmb == NULL ) )
      dealloc_msg_ctl( &pmctl );  // also sets pmctl to NULL
  }

  return pmctl;

}  // alloc_msg_ctl



#if defined( MBG_TGT_WIN32 ) && _USE_SOCKET_IO

static /*HDR*/
BOOL WINAPI mbgextio_on_console_event( DWORD dwCtrlType )
{
  switch ( dwCtrlType )
  {
    case CTRL_BREAK_EVENT:
    case CTRL_C_EVENT:
    case CTRL_CLOSE_EVENT:
    case CTRL_SHUTDOWN_EVENT:
      exit( 0 );

  }  // switch

  return FALSE;

}  // mbgextio_on_console_event



static /*HDR*/
void mbgextio_set_console_control_handler( void )
{
  static int has_been_set;

  if ( !has_been_set )
  {
    SetConsoleCtrlHandler( mbgextio_on_console_event, TRUE );
    has_been_set = 1;
  }

}  // mbgextio_set_console_control_handler

#endif  //  defined MBG_TGT_WIN32




#if _USE_SOCKET_IO

static /*HDR*/
int socket_init( MBG_MSG_CTL *pmctl, const char *host )
{
  struct hostent *hp;
  struct sockaddr_in *paddr;
  const struct sockaddr *p;
  int sz;
  int rc;

  hp = gethostbyname( host );

  #if defined( MBG_TGT_WIN32 )
    if ( hp == NULL )
    {
      // The winsock2.dll may not yet have been initialized,
      // so try to initialize now.
      WORD wVersionRequested;
      WSADATA wsaData;

      wVersionRequested = MAKEWORD( 2, 2 );

      rc = WSAStartup( wVersionRequested, &wsaData );

      // If initialization has succeeded, try again.
      if ( rc == 0 )
        hp = gethostbyname( host );
    }
  #endif  // defined( MBG_TGT_WIN32 )

  if ( hp == NULL )
    return TR_OPEN_ERR;


  // create socket on which to send.
  pmctl->st.sockio.sockfd = socket( PF_INET, SOCK_STREAM, 0 );

  if ( pmctl->st.sockio.sockfd == INVALID_SOCKET )
    return TR_OPEN_ERR;

  paddr = &pmctl->st.sockio.addr;
  memset( paddr, 0, sizeof( *paddr ) );

  memcpy( &paddr->sin_addr, hp->h_addr, hp->h_length );
  paddr->sin_family = AF_INET;
  paddr->sin_port = htons( LAN_XPT_PORT );

  p = (const struct sockaddr *) paddr;
  sz = sizeof( *paddr );

  rc = connect( pmctl->st.sockio.sockfd, p, sz );

  if ( rc < 0 )
  {
    #if defined( MBG_TGT_WIN32 )
      DWORD err = WSAGetLastError();
      // e.g. WSAECONNREFUSED (10061): connection refused
    #endif
    return TR_OPEN_ERR;
  }

  return 0;

}  // socket_init



static /*HDR*/
int comm_init( MBG_MSG_CTL *pmctl, const char *passwd )
{
  SECU_SETTINGS *pss = &pmctl->secu_settings;
  MBG_MSG_BUFF *pmb;
  int rc;

  memset( pss, 0, sizeof *pss );
  strncpy( pss->password, passwd, sizeof( pss->password ) );

  pmctl->conn_type = MBG_CONN_TYPE_SOCKET;
  pmctl->msg_rcv_timeout = MBGEXTIO_RCV_TIMEOUT_SOCKET;
  // pmctl->char_rcv_timeout is not used with sockets

  set_encryption_mode( pmctl, MBG_XFER_MODE_ENCRYTED, pss->password );

  pmb = pmctl->xmt.pmb;
  pmb->u.msg_data.secu_settings = *pss;
  pmb->hdr.cmd = GPS_SECU_SETTINGS;
  pmb->hdr.len = sizeof( pmb->u.msg_data.secu_settings );

  xmt_tbuff( pmctl );
  rc = mbgextio_rcv_msg( pmctl, GPS_SECU_SETTINGS );

  if ( rc != TR_COMPLETE )
    return -1;  /* connection refused */

  pmb = pmctl->rcv.pmb;

  if ( !( pmb->hdr.cmd & GPS_ACK ) )
    return -2;  /* authentication failed */

  return 0;

}  // comm_init



/*HDR*/
_NO_MBG_API_ATTR MBG_MSG_CTL * _MBG_API mbgextio_open_socket( const char *host,
                                                              const char *passwd )
{
  MBG_MSG_CTL *pmctl = alloc_msg_ctl();
  int rc;

  if ( pmctl == NULL )
    return NULL;


  rc = socket_init( pmctl, host );

  if ( rc < 0 )
    goto fail_free;

  comm_init( pmctl, passwd );

  #if defined( MBG_TGT_WIN32 )
    mbgextio_set_console_control_handler();
  #endif

  #if _USE_MUTEX
    _mbg_mutex_init( &pmctl->xmt.xmt_mutex );
  #endif

  goto done;

fail_free:
  dealloc_msg_ctl( &pmctl );

done:
  return pmctl;

}  // mbgextio_open_socket

#endif  // _USE_SOCKET_IO



#if _USE_SERIAL_IO

/*HDR*/
_NO_MBG_API_ATTR MBG_MSG_CTL * _MBG_API mbgextio_open_serial( const char *dev,
                             uint32_t baud_rate, const char *framing )
{
  MBG_MSG_CTL *pmctl = alloc_msg_ctl();
  int rc;

  if ( pmctl == NULL )
    return NULL;


  pmctl->conn_type = MBG_CONN_TYPE_SERIAL;
  pmctl->msg_rcv_timeout = MBGEXTIO_MSG_RCV_TIMEOUT_SERIAL;
  pmctl->char_rcv_timeout = MBGEXTIO_CHAR_RCV_TIMEOUT_SERIAL;

  rc = mbgserio_open( &pmctl->st.serio, dev );

  if ( rc < 0 )  //##++
    goto fail_free;

  mbgserio_set_parms( &pmctl->st.serio, baud_rate, framing );

  #if _USE_MUTEX
    _mbg_mutex_init( &pmctl->xmt.xmt_mutex );
  #endif

  goto done;

fail_free:
  dealloc_msg_ctl( &pmctl );

done:
  return pmctl;

}  // mbgextio_open_serial

#endif



/*HDR*/
_NO_MBG_API_ATTR void _MBG_API mbgextio_close_connection( MBG_MSG_CTL **ppmctl )
{
  MBG_MSG_CTL *pmctl = *ppmctl;

  switch ( pmctl->conn_type )
  {
    #if _USE_SERIAL_IO
      case MBG_CONN_TYPE_SERIAL:
        mbgserio_close( &pmctl->st.serio );
    #endif  // _USE_SERIAL_IO

    #if _USE_SOCKET_IO
      case MBG_CONN_TYPE_SOCKET:
      {
        #if defined( MBG_TGT_CVI ) || defined( MBG_TGT_WIN32 )
          _close( pmctl->st.sockio.sockfd );
        #elif defined( MBG_TGT_UNIX )
          close( pmctl->st.sockio.sockfd );
        #else
          #error close socket needs to be implemented for this target
        #endif
        pmctl->st.sockio.sockfd = 0;
      } break;
    #endif  // _USE_SOCKET_IO

  }  // switch

  #if _USE_MUTEX
    _mbg_mutex_destroy( &pmctl->xmt.xmt_mutex );
  #endif

  dealloc_msg_ctl( ppmctl );

}  // mbgextio_close_connection



#if _USE_SERIAL_IO

/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_force_connection( const char *dev )
{
  static const char *cmd_str = "\nDFC\n";  //##++

  int i;
  int j;
  int len = strlen( cmd_str );

  for ( i = 0; i < N_MBG_BAUD_RATES; i++ )
  {
    for ( j = 0; j < N_MBG_FRAMINGS; j++ )
    {
      uint32_t baud_rate = mbg_baud_rates[i];
      const char *framing = mbg_framing_strs[j];
      MBG_MSG_CTL *pmctl = mbgextio_open_serial( dev, baud_rate, framing );

      if ( pmctl == NULL ) // failed to open port
        return -1;

      mbgserio_write( pmctl->st.serio.port_handle, cmd_str, len );
      mbgextio_close_connection( &pmctl );
    }
  }

  return 0;

}  // mbgextio_force_connection

#endif  // _USE_SERIAL_IO



/*HDR*/
_NO_MBG_API_ATTR void _MBG_API mbgextio_set_char_rcv_timeout( MBG_MSG_CTL *pmctl, ulong new_timeout )
{
  pmctl->char_rcv_timeout = new_timeout;

}  // mbgextio_set_char_rcv_timeout



/*HDR*/
_NO_MBG_API_ATTR ulong _MBG_API mbgextio_get_char_rcv_timeout( const MBG_MSG_CTL *pmctl )
{
  return pmctl->char_rcv_timeout;

}  // mbgextio_get_char_rcv_timeout



/*HDR*/
_NO_MBG_API_ATTR void _MBG_API mbgextio_set_msg_rcv_timeout( MBG_MSG_CTL *pmctl, ulong new_timeout )
{
  pmctl->msg_rcv_timeout = new_timeout;

}  // mbgextio_set_msg_rcv_timeout



/*HDR*/
_NO_MBG_API_ATTR ulong _MBG_API mbgextio_get_msg_rcv_timeout( const MBG_MSG_CTL *pmctl )
{
  return pmctl->msg_rcv_timeout;

}  // mbgextio_get_msg_rcv_timeout



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_xmt_msg( MBG_MSG_CTL *pmctl, GPS_CMD cmd, 
                                                const void *p, size_t n_bytes )
{
  MBG_MSG_BUFF *pmb;

  if ( n_bytes > sizeof( pmb->u.msg_data ) )
    return -1;  // bytes to send exceed buffer size


  #if _USE_MUTEX
    _mbg_mutex_acquire( &pmctl->xmt.xmt_mutex );
  #endif

  pmb = pmctl->xmt.pmb;

  if ( p && n_bytes )
    memcpy( pmb->u.bytes, p, n_bytes );

  pmb->hdr.len = n_bytes;
  pmb->hdr.cmd = cmd;
  xmt_tbuff( pmctl );

  #if _USE_MUTEX
    _mbg_mutex_release( &pmctl->xmt.xmt_mutex );
  #endif

  if ( cmd & GPS_REQACK )
  {
    int rc = mbgextio_rcv_msg( pmctl, (GPS_CMD) ( cmd &  ~GPS_CTRL_MSK ) );

    if ( rc != TR_COMPLETE )
      return -2;

    if ( pmctl->rcv.pmb->hdr.cmd & GPS_NACK )
      return -3;

    if ( !(pmctl->rcv.pmb->hdr.cmd & GPS_ACK) )
      return -4;
  }


  return 0;

}  // mbgextio_xmt_msg



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_rcv_msg( MBG_MSG_CTL *pmctl, GPS_CMD cmd )
{
  MBG_MSG_RCV_CTL *prctl;
  MBG_MSG_BUFF *pmb;
  MBG_TMO_TIME msg_timeout;
  char buff[MBGEXTIO_READ_BUFFER_SIZE];
  ssize_t n_bytes;
  int rc;
  int i;

  mbg_tmo_set_timeout_ms( &msg_timeout, pmctl->msg_rcv_timeout );

  for (;;)  // loop until complete msg received
  {
    n_bytes = 0;

    if ( mbg_tmo_curr_time_is_after( &msg_timeout ) )
      return TR_TIMEOUT;

    #if _USE_SOCKET_IO
      if ( pmctl->conn_type == MBG_CONN_TYPE_SOCKET )
      {
        struct timeval tv_timeout;
        fd_set fds;

        if ( pmctl->io_error )
          return TR_IO_ERR;

        mbgserio_msec_to_timeval( pmctl->msg_rcv_timeout, &tv_timeout );

        FD_ZERO( &fds );
        FD_SET( pmctl->st.sockio.sockfd, &fds );

        rc = select( pmctl->st.sockio.sockfd + 1, &fds, NULL, NULL, &tv_timeout );

        if ( rc == 0 )    // timeout
          return TR_TIMEOUT;

        if ( rc < 0 )     // error
        {
          pmctl->io_error = 1;
          return TR_IO_ERR;
        }

        // data is available

        n_bytes = recv( pmctl->st.sockio.sockfd, buff, sizeof( buff ), 0 );

        if ( n_bytes < 0 )
        {
          pmctl->io_error = 1;
          return TR_IO_ERR;
        }
      }
    #endif  // _USE_SOCKET_IO

    #if _USE_SERIAL_IO
      if ( pmctl->conn_type == MBG_CONN_TYPE_SERIAL )
      {
        n_bytes = mbgserio_read_wait( pmctl->st.serio.port_handle, &buff[0],
                                      sizeof( buff[0] ), pmctl->char_rcv_timeout );

        if ( n_bytes < 0 )
        {
          if ( n_bytes == MBGSERIO_TIMEOUT )
             return TR_TIMEOUT;

          pmctl->io_error = 1;
          return TR_IO_ERR;
        }
      }
    #endif  // _USE_SERIAL_IO

    prctl = &pmctl->rcv;
    pmb = prctl->pmb;

    for ( i = 0; i < n_bytes; i++ )
    {
      char c = buff[i];

      /* check if the new char belongs to a data transfer sequence */
      rc = check_transfer( prctl, c );

      switch ( rc )
      {
        case TR_WAITING:      /* no data transfer sequence in progress */
          #if _USE_CHK_TSTR
            if ( prctl->chk_tstr_fnc )  /* optionally handle normal, non-protocol data */
              prctl->chk_tstr_fnc( c, prctl->chk_tstr_arg );
          #endif
          // intentional fall-through

        case TR_RECEIVING:    /* data transfer sequence in progress, keep waiting */
          continue;

        case TR_COMPLETE:
          {
            uint16_t rcvd_cmd = pmb->hdr.cmd & ~GPS_CTRL_MSK;

            if ( rcvd_cmd == cmd )  /* the received packet is what we've been waiting for */
              return TR_COMPLETE;

            #if _USE_ENCRYPTION
              /* if an encrypted packet has been received then decrypt it */
              if ( rcvd_cmd == GPS_CRYPTED_PACKET )
              {
                rc = decrypt_message( pmctl );

                if ( rc < 0 )  /* decryption error */
                  return rc;

                rcvd_cmd = pmb->hdr.cmd & ~GPS_CTRL_MSK;

                if ( rcvd_cmd == cmd )  /* the received packet is what we've been waiting for */
                  return TR_COMPLETE;
              }
            #endif

            /* not waiting  for a specific packet, so return if any packet is complete */
            if ( cmd == (uint16_t) -1 )
              return TR_COMPLETE;

            //##++ received a msg which does not match the expected code
            prctl->cnt = 0;      /* restart receiving */
          }
          break;

        default:    /* any error condition */
          return rc;

      }  /* switch */
    }
  }

}  // mbgextio_rcv_msg



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_xmt_cmd( MBG_MSG_CTL *pmctl, GPS_CMD cmd )
{
  int rc;

  #if _USE_MUTEX
    _mbg_mutex_acquire( &pmctl->xmt.xmt_mutex );
  #endif

  rc = xmt_cmd( pmctl, cmd );

  #if _USE_MUTEX
    _mbg_mutex_release( &pmctl->xmt.xmt_mutex );
  #endif

  return rc;

}  // mbgextio_xmt_cmd



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_xmt_cmd_us( MBG_MSG_CTL *pmctl, GPS_CMD cmd, uint16_t us )
{
  int rc;

  #if _USE_MUTEX
    _mbg_mutex_acquire( &pmctl->xmt.xmt_mutex );
  #endif

  rc = xmt_cmd_us( pmctl, cmd, us );

  #if _USE_MUTEX
    _mbg_mutex_release( &pmctl->xmt.xmt_mutex );
  #endif

  return rc;

}  // mbgextio_xmt_cmd_us



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_req_data( MBG_MSG_CTL *pmctl, GPS_CMD cmd )
{
  xmt_cmd( pmctl, cmd );   /* request a set of data */

  return mbgextio_rcv_msg( pmctl, cmd );

}  // mbgextio_req_data



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_req_data_idx( MBG_MSG_CTL *pmctl, GPS_CMD cmd, uint16_t idx )
{
  xmt_cmd_us( pmctl, cmd, idx );   /* request a set of data */

  return mbgextio_rcv_msg( pmctl, cmd );

}  // mbgextio_req_data_idx



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_receiver_info( MBG_MSG_CTL *pmctl, RECEIVER_INFO *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_RECEIVER_INFO );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.receiver_info;

  return rc;

}  // mbgextio_get_receiver_info



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_sw_rev( MBG_MSG_CTL *pmctl, SW_REV *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_SW_REV );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.sw_rev;

  return rc;

}  // mbgextio_get_sw_rev



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_bvar_stat( MBG_MSG_CTL *pmctl, BVAR_STAT *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_BVAR_STAT );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.bvar_stat;

  return rc;

}  // mbgextio_get_bvar_stat



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_time( MBG_MSG_CTL *pmctl, TTM *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_TIME );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.ttm;

  return rc;

}  // mbgextio_get_time



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_time( MBG_MSG_CTL *pmctl, const TTM *p )
{
  GPS_CMD cmd = GPS_TIME;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_time



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_pos_lla( MBG_MSG_CTL *pmctl, LLA lla )
{
  int rc = mbgextio_req_data( pmctl, GPS_POS_LLA );

  if ( rc == TR_COMPLETE )
  {
    MSG_DATA *pmb = &pmctl->rcv.pmb->u.msg_data;
    int i;

    for ( i = 0; i < N_LLA; i++ )
    {
      swap_double( &pmb->lla[i] );

      if ( lla )
        lla[i] = pmb->lla[i];
    }
  }

  return rc;

}  // mbgextio_get_pos_lla



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_pos_lla( MBG_MSG_CTL *pmctl, const LLA lla )
{
  GPS_CMD cmd = GPS_POS_LLA;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) lla, sizeof( LLA ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) lla, sizeof( LLA ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_pos_lla



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_tzdl( MBG_MSG_CTL *pmctl, TZDL *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_TZDL );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.tzdl;

  return rc;

}  // mbgextio_get_tzdl



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_tzdl( MBG_MSG_CTL *pmctl, const TZDL *p )
{
  GPS_CMD cmd = GPS_TZDL;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_get_tzdl



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_port_parm( MBG_MSG_CTL *pmctl, PORT_PARM *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_PORT_PARM );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.port_parm;

  return rc;

}  // mbgextio_get_port_parm



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_port_parm( MBG_MSG_CTL *pmctl, const PORT_PARM *p )
{
  GPS_CMD cmd = GPS_PORT_PARM;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else

  MBG_MSG_BUFF *pmb = pmctl->xmt.pmb;
  int rc;

  pmb->u.msg_data.port_parm = *p;

  pmb->hdr.len = sizeof( pmb->u.msg_data.port_parm );
  pmb->hdr.cmd = cmd | GPS_REQACK;
  xmt_tbuff( pmctl );

  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_port_parm



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_synth( MBG_MSG_CTL *pmctl, SYNTH *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_SYNTH );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.synth;

  return rc;

}  // mbgextio_get_synth



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_synth( MBG_MSG_CTL *pmctl, const SYNTH *p )
{
  GPS_CMD cmd = GPS_SYNTH;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_synth



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_ant_info( MBG_MSG_CTL *pmctl, ANT_INFO *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_ANT_INFO );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.ant_info;

  return rc;

}  // mbgextio_get_ant_info



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_ucap( MBG_MSG_CTL *pmctl, TTM *p )
{
  int rc;

  xmt_cmd( pmctl, GPS_UCAP );   /* request a set of data */

  // Attention: Older firmware versions may reply with GPS_TIME 
  // messages instead of GPS_UCAP messages, and may not send a reply 
  // at all if no capture event is available in the on-board FIFO.
  for (;;)
  {
    rc = mbgextio_rcv_msg( pmctl, -1 );

    if ( rc < 0 )
      break;

    if ( rc != TR_COMPLETE )
      continue;

    if ( pmctl->rcv.pmb->hdr.cmd == GPS_UCAP )
      break;

    if ( pmctl->rcv.pmb->hdr.cmd == GPS_TIME )
      if ( pmctl->rcv.pmb->hdr.len > 0 )
        if ( pmctl->rcv.pmb->u.msg_data.ttm.channel >= 0 )
          break;
  }

  if ( p )
  {
    // If the length of the msg header is 0 then the capture buffer
    // is empty. This is indicated with 0xFF in the seconds field of
    // the GPS time structure.
    if ( pmctl->rcv.pmb->hdr.len > 0 )
      *p = pmctl->rcv.pmb->u.msg_data.ttm;
    else
      _ttm_time_set_unavail( p );  // no capture event available
  }

  return rc;

}  // mbgextio_get_ucap



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_enable_flags( MBG_MSG_CTL *pmctl, ENABLE_FLAGS *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_ENABLE_FLAGS );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.enable_flags;

  return rc;

}  // mbgextio_get_enable_flags



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_enable_flags( MBG_MSG_CTL *pmctl, const ENABLE_FLAGS *p )
{
  GPS_CMD cmd = GPS_ENABLE_FLAGS;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_enable_flags



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_stat_info( MBG_MSG_CTL *pmctl, STAT_INFO *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_STAT_INFO );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.stat_info;

  return rc;

}  // mbgextio_get_stat_info



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_ant_cable_len( MBG_MSG_CTL *pmctl, ANT_CABLE_LEN *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_ANT_CABLE_LENGTH );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.ant_cable_len;

  return rc;

}  // mbgextio_get_ant_cable_len



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_ant_cable_len( MBG_MSG_CTL *pmctl, const ANT_CABLE_LEN *p )
{
  GPS_CMD cmd = GPS_ANT_CABLE_LENGTH;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_ant_cable_len



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_irig_tx_info( MBG_MSG_CTL *pmctl, IRIG_INFO *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_IRIG_TX_INFO );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.irig_tx_info;

  return rc;

}  // mbgextio_get_irig_tx_info



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_irig_tx_settings( MBG_MSG_CTL *pmctl, const IRIG_SETTINGS *p )
{
  GPS_CMD cmd = GPS_IRIG_TX_SETTINGS;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_irig_tx_settings



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_irig_rx_info( MBG_MSG_CTL *pmctl, IRIG_INFO *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_IRIG_RX_INFO );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.irig_rx_info;

  return rc;

}  // mbgextio_get_irig_rx_info



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_irig_rx_settings( MBG_MSG_CTL *pmctl, const IRIG_SETTINGS *p )
{
  GPS_CMD cmd = GPS_IRIG_RX_SETTINGS;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_irig_rx_settings



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_ref_offs( MBG_MSG_CTL *pmctl, MBG_REF_OFFS *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_REF_OFFS );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.ref_offs;

  return rc;

}  // mbgextio_get_ref_offs



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_ref_offs( MBG_MSG_CTL *pmctl, const MBG_REF_OFFS *p )
{
  GPS_CMD cmd = GPS_REF_OFFS;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_ref_offs



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_debug_status( MBG_MSG_CTL *pmctl, MBG_DEBUG_STATUS *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_DEBUG_STATUS );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.debug_status;

  return rc;

}  // mbgextio_get_debug_status



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_opt_info( MBG_MSG_CTL *pmctl, MBG_OPT_INFO *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_OPT_INFO );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.opt_info;

  return rc;

}  // mbgextio_get_opt_info



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_opt_settings( MBG_MSG_CTL *pmctl, const MBG_OPT_SETTINGS *p )
{
  GPS_CMD cmd = GPS_OPT_SETTINGS;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else
  int rc;

  rc = mbgextio_xmt_msg( pmctl, (uint16_t) ( cmd | GPS_ACK ), (const uint8_t *) p, sizeof( *p ) );
  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_opt_settings



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_str_type_info_idx( MBG_MSG_CTL *pmctl,
                             STR_TYPE_INFO_IDX *p, uint16_t idx )
{
  int rc;

  xmt_cmd_us( pmctl, GPS_STR_TYPE_INFO_IDX, idx );

  rc = mbgextio_rcv_msg( pmctl, GPS_STR_TYPE_INFO_IDX );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.str_type_info_idx;

  return rc;

}  // mbgextio_get_str_type_info_idx



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_port_info_idx( MBG_MSG_CTL *pmctl, 
                             PORT_INFO_IDX *p, uint16_t idx )
{
  int rc;

  xmt_cmd_us( pmctl, GPS_PORT_INFO_IDX, idx );

  rc = mbgextio_rcv_msg( pmctl, GPS_PORT_INFO_IDX );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.port_info_idx;

  return rc;

}  // mbgextio_get_port_info_idx



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_port_settings_idx( MBG_MSG_CTL *pmctl,
                             const PORT_SETTINGS *p, uint16_t idx )
{
  GPS_CMD cmd = GPS_PORT_SETTINGS_IDX;
  MBG_MSG_BUFF *pmb = pmctl->xmt.pmb;
  int rc;

  pmb->u.msg_data.port_settings_idx.port_settings = *p;
  pmb->u.msg_data.port_settings_idx.idx = idx;

  pmb->hdr.len = sizeof( pmb->u.msg_data.port_settings_idx );
  pmb->hdr.cmd = cmd | GPS_REQACK;
  rc = xmt_tbuff( pmctl );

#if _MBGEXTIO_DIRECT_RC

  return rc;

#else

  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_port_settings_idx



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_pout_info_idx( MBG_MSG_CTL *pmctl, 
                             POUT_INFO_IDX *p, uint16_t idx )
{
  int rc;

  xmt_cmd_us( pmctl, GPS_POUT_INFO_IDX, idx );

  rc = mbgextio_rcv_msg( pmctl, GPS_POUT_INFO_IDX );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.pout_info_idx;

  return rc;

}  // mbgextio_get_pout_info_idx



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_pout_settings_idx( MBG_MSG_CTL *pmctl, 
                             const POUT_SETTINGS *p, uint16_t idx )
{
  GPS_CMD cmd = GPS_POUT_SETTINGS_IDX;
  MBG_MSG_BUFF *pmb = pmctl->xmt.pmb;
  int rc;

  pmb->u.msg_data.pout_settings_idx.pout_settings = *p;
  pmb->u.msg_data.pout_settings_idx.idx = idx;

  pmb->hdr.len = sizeof( pmb->u.msg_data.pout_settings_idx );
  pmb->hdr.cmd = cmd | GPS_REQACK;
  rc = xmt_tbuff( pmctl );

#if _MBGEXTIO_DIRECT_RC

  return rc;

#else

  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_pout_settings_idx



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_clr_ucap_buff( MBG_MSG_CTL *pmctl )
{
  return mbgextio_xmt_cmd( pmctl, GPS_CLR_UCAP_BUFF );

}  // mbgextio_clr_ucap_buff



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_time_scale_info( MBG_MSG_CTL *pmctl, 
                                                         MBG_TIME_SCALE_INFO *p )
{
  int rc;

  xmt_cmd( pmctl, GPS_TIME_SCALE );

  rc = mbgextio_rcv_msg( pmctl, GPS_TIME_SCALE );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.time_scale_info;

  return rc;

}  // mbgextio_get_time_scale_info



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_set_time_scale_settings( MBG_MSG_CTL *pmctl, 
                             const MBG_TIME_SCALE_SETTINGS *p )
{
  GPS_CMD cmd = GPS_TIME_SCALE;

#if _MBGEXTIO_DIRECT_RC

  return mbgextio_xmt_msg( pmctl, cmd, (const uint8_t *) p, sizeof( *p ) );

#else

  MBG_MSG_BUFF *pmb = pmctl->xmt.pmb;
  int rc;

  pmb->u.msg_data.time_scale_settings = *p;

  pmb->hdr.len = sizeof( pmb->u.msg_data.time_scale_settings );
  pmb->hdr.cmd = cmd | GPS_REQACK;
  xmt_tbuff( pmctl );

  rc = mbgextio_rcv_msg( pmctl, cmd );

  if ( ( rc != TR_COMPLETE ) || !( pmctl->rcv.pmb->hdr.cmd & GPS_ACK ) ) 
  {
    return -1;  // no ack packet received
    // data has not been set or, if GPS_AUTO_ON has been 
    // transmitted before, an automatic frame (current time, capture)
    // has been sent before the acknowledge code.
  }

  return 0;

#endif

}  // mbgextio_set_time_scale_settings



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_clr_evt_log( MBG_MSG_CTL *pmctl )
{
  return mbgextio_xmt_cmd( pmctl, GPS_CLR_EVT_LOG );

}  // mbgextio_clr_evt_log



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_num_evt_log_entries( MBG_MSG_CTL *pmctl, MBG_NUM_EVT_LOG_ENTRIES *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_NUM_EVT_LOG_ENTRIES );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.num_evt_log_entries;

  return rc;

}  // mbgextio_get_num_evt_log_entries



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_first_evt_log_entry( MBG_MSG_CTL *pmctl, MBG_EVT_LOG_ENTRY *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_FIRST_EVT_LOG_ENTRY );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.evt_log_entry;

  return rc;

}  // mbgextio_get_first_evt_log_entry



/*HDR*/
_NO_MBG_API_ATTR int _MBG_API mbgextio_get_next_evt_log_entry( MBG_MSG_CTL *pmctl, MBG_EVT_LOG_ENTRY *p )
{
  int rc = mbgextio_req_data( pmctl, GPS_NEXT_EVT_LOG_ENTRY );

  if ( ( rc == TR_COMPLETE ) && p )
    *p = pmctl->rcv.pmb->u.msg_data.evt_log_entry;

  return rc;

}  // mbgextio_get_next_evt_log_entry



