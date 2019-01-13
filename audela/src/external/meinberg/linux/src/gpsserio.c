
/**************************************************************************
 *
 *  $Id: gpsserio.c 1.10.1.1 2011/12/12 16:07:45 martin TEST martin $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Low level functions used to access Meinberg GPS receivers via
 *    serial port.
 *
 * -----------------------------------------------------------------------
 *  $Log: gpsserio.c $
 *  Revision 1.10.1.1  2011/12/12 16:07:45  martin
 *  Use mbgserio_read/write functions rather than macros.
 *  Conditionally save timestamp for incoming binary packet.
 *  Revision 1.10  2011/07/29 09:53:43Z  daniel
 *  Account for communication via USB if _USE_USB_IO is defined
 *  Revision 1.9  2009/09/01 09:51:56  martin
 *  Removed obsolete includes.
 *  Revision 1.8  2009/03/10 16:58:09  martin
 *  Fixed compiler warnings.
 *  Revision 1.7  2008/09/03 15:22:40  martin
 *  Decryption with wrong password yields garbage, still needs to be fixed.
 *  In xmt_tbuff() use MBG_PORT_HANDLE for serial connections.
 *  Some cleanup in check_transfer().
 *  Fixed a VC6 compiler warning.
 *  Moved low level serial I/O routines to mbgserio.c.
 *  Revision 1.6  2006/10/25 12:24:01Z  martin
 *  Support serial I/O under Windows.
 *  Removed obsolete code.
 *  Revision 1.5  2006/08/24 12:57:41Z  martin
 *  Conditionally also support network socket I/O and encrypted packets.
 *  Support also serial I/O conditionally only.
 *  Added/renamed/redefined structures as required.
 *  Revision 1.4  2006/05/17 10:19:39  martin
 *  Account for renamed structure.
 *  Revision 1.3  2005/04/26 11:00:30  martin
 *  Added standard file header.
 *  Source code cleanup.
 *  check_transfer() now expects a control structure which keeps
 *  the reception status corresponding to the receive buffer.
 *  After receive error reinitialize the byte counter to restart
 *  reception with next incoming byte.
 *  Use type CSUM where appropriate.
 *  Use C99 fixed-size data types where applicable.
 *  Renamed the function csum() to mbg_csum().
 *
 **************************************************************************/

#define _GPSSERIO
 #include <gpsserio.h>
#undef _GPSSERIO

#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#if defined( MBG_TGT_UNIX )
  #include <unistd.h>
//##++++   #include <sys/time.h>
#endif

#if _USE_ENCRYPTION
  #include <aes128.h>
#endif



/*--------------------------------------------------------------
 * Name:         msg_csum_update()
 *
 * Purpose:      Compute a checksum about a number of bytes
 *               starting with a given initial value.
 *
 * Input:        CSUM csum   the initial value
 *               uint8_t *p  address of the first byte
 *               int n       the number of bytes
 *
 * Output:       --
 *
 * Ret val:      the checksum
 *+------------------------------------------------------------*/

/*HDR*/
CSUM msg_csum_update( CSUM csum, uint8_t *p, int n )
{
  int i;

  for ( i = 0; i < n; i++ )
    csum += *p++;

  return csum;

}  /* msg_csum_update */



/*--------------------------------------------------------------
 * Name:         msg_csum()
 *
 * Purpose:      Compute a message checksum over a number 
 *               of bytes.
 *
 *               ATTENTION: This function differs from the 
 *               checksum() function which is used to compute 
 *               the checksum of battery-buffered variables!
 *
 * Input:        uint8_t *p  address of the first byte
 *               int n       the number of bytes
 *
 * Output:       --
 *
 * Ret val:      the checksum
 *+------------------------------------------------------------*/

/*HDR*/
CSUM msg_csum( uint8_t *p, int n )
{
  return msg_csum_update( 0, p, n );

}  /* msg_csum */



/*--------------------------------------------------------------
 * Name:         msg_hdr_csum()
 *
 * Purpose:      Compute the checksum of a message header.
 *
 * Input:        MSG_HDR *pmh pointer to a message header 
 *
 * Output:       --
 *
 * Ret val:      the checksum
 *+------------------------------------------------------------*/

/*HDR*/
CSUM msg_hdr_csum( MSG_HDR *pmh )
{
  return msg_csum( (uint8_t *) pmh, 
         sizeof( *pmh ) - sizeof( pmh->hdr_csum ) );

}  /* msg_hdr_csum */



/*HDR*/
int chk_hdr_csum( MSG_HDR *pmh )
{
  CSUM calc_csum = msg_hdr_csum( pmh );

  if ( calc_csum != pmh->hdr_csum )
    return -1;   /* error */

  return 0;

}  /* chk_hdr_csum */



/*HDR*/
int chk_data_csum( MBG_MSG_BUFF *pmb )
{
  CSUM calc_csum = msg_csum( pmb->u.bytes, pmb->hdr.len );

  if ( calc_csum != pmb->hdr.data_csum )
    return -1;   /* error */

  return 0;

}  /* chk_data_csum */



#if _USE_ENCRYPTION

#ifdef MBG_TGT_WIN32

  static
  void randomize( void )
  {
    LARGE_INTEGER perfc;

    QueryPerformanceCounter( &perfc );

    srand( perfc.LowPart );

  }  /* randomize */

#else

  static
  void randomize( void )
  {
    struct timeval tv;

    gettimeofday( &tv, NULL );

    srand( tv.tv_usec );

  }  /* randomize */

#endif

//----------------------------------------------------------------------
// in encrypted mode data packets are packed into a new encrypted packet
// where InitVect, XMSG_BUFF and Fill bytes form the new data section
//
// Format : [MSG_HDR][InitVect][XMSG_BUFF][FillBytes]
//          |<-HDR->|<----------- DATA ------------>|
//          |<-- plaintext -->|<---- encrypted ---->|
//
//  - MSG_HDR :    Standard Binary Message Handler with
//                 cmd = GPS_CRYPTED_PACKET, len is size of complete
//                 block, data_csum calculated over complete block
//                 ( InitVect, XMSG_BUFF and FILL_BYTES )
//  - InitVect :   random number for AES128 CFM initialization
//  - XMSG_BUFF :  Message buffer as prepared for unencrypted transfer
//                 consists of MSG_HEADER and DATA, will be completely
//                 encrypted before transmission
//  - FillBytes :  Bytes to fill up for the next 128Bit/16Byte boundary
//----------------------------------------------------------------------


/*HDR*/
int encrypt_message( MBG_MSG_CTL *pmctl, CRYPT_MSG_PREFIX *pcmp, MBG_MSG_BUFF *pmb )
{
  int n_bytes = pmb->hdr.len + sizeof( pmb->hdr );  /* size of unencrypted msg */
  int rc;

  /* correct original msg size for 16 byte boundary */
  n_bytes += AES_BLOCK_SIZE - ( n_bytes % AES_BLOCK_SIZE );

  /* encrypt original message */
  rc = aes_encrypt_buff( (uint8_t *) pmb, pmctl->aes_keyvect, pmctl->aes_initvect, n_bytes );

  if ( rc < 0 )
    return rc;   // encryption failed


  /* copy AES init vector into encrypted message */
  memcpy( pcmp->aes_initvect, pmctl->aes_initvect, sizeof( pcmp->aes_initvect ) );

  pcmp->hdr.cmd = GPS_CRYPTED_PACKET;
  pcmp->hdr.len = n_bytes + sizeof( pcmp->aes_initvect );

  pcmp->hdr.data_csum = msg_csum( pcmp->aes_initvect, sizeof( pcmp->aes_initvect ) );
  pcmp->hdr.data_csum = msg_csum_update( pcmp->hdr.data_csum, 
                          (uint8_t *) pmb, n_bytes );

  pcmp->hdr.hdr_csum = msg_hdr_csum( &pcmp->hdr );

  return n_bytes;

}  /* encrypt_message */



/*HDR*/
int decrypt_message( MBG_MSG_CTL *pmctl )
{
  MBG_MSG_RCV_CTL *prctl = &pmctl->rcv;
  MBG_MSG_BUFF *pmb = prctl->pmb;
  CRYPT_MSG_DATA *pcmd = &pmb->u.crypt_msg_data;
  int rc;

  if ( pmb->hdr.len < AES_BLOCK_SIZE )
    return 0;

  rc = aes_decrypt_buff( (unsigned char *) &pcmd->enc_msg,
                         pmctl->aes_keyvect, 
                         pcmd->aes_initvect,
                         pmb->hdr.len - sizeof( pcmd->aes_initvect )
                       ); 

  if ( rc < 0 )  /* decryption error */
  {
    prctl->flags |= MBG_MSG_RCV_CTL_DECRYPT_ERR;
    return TR_DECRYPTION;
  }

  /* packet decrypted successfully. */
  prctl->flags |= MBG_MSG_RCV_CTL_DECRYPTED;

  // If the wrong password has been used for decryption 
  // then decryption may have been formally successful, 
  // but the decrypted message contains garbage.
  // So we must check whether the decrypted packet
  // also contains a valid header and data part.
  //##+++  TODO

  /* copy the decrypted message to head of the buffer */
  memcpy( pmb, &pcmd->enc_msg, pcmd->enc_msg.enc_hdr.len + sizeof( pcmd->enc_msg.enc_hdr ) );

  /* now check the csums of the decrypted packet */

  if ( chk_hdr_csum( &pmb->hdr ) < 0 )  /* error */
    return TR_CSUM_DATA;                /* invalid header checksum received */

  if ( chk_data_csum( pmb ) < 0 )       /* error */
    return TR_CSUM_DATA;                /* invalid header checksum received */

  return 0;

}  /* decrypt_message */



/*HDR*/
void set_encryption_mode( MBG_MSG_CTL *pmctl, int mode, const char *key )
{
  int i;

  randomize();

  for ( i = 0; i < AES_BLOCK_SIZE; i++ )
  {
    pmctl->aes_initvect[i] = rand();
    pmctl->aes_keyvect[i] = key[i];
  }

  pmctl->xmt.xfer_mode = mode;

}  // set_encryption_mode

#endif  // _USE_ENCRYPTION



/*--------------------------------------------------------------
 * Name:         xmt_tbuff()
 *
 * Purpose:      Compute checksums and complete the message
 *               header, then transmit both header and data.
 *               The caller must have copied the data to be
 *               sent to the data field of the transmit buffer
 *               and have set up the cmd field and the
 *               len field of pm->hdr.
 *
 * Input:        MBG_MSG_BUFF *pm  pointer to the message buffer
 *
 * Output:       --
 *
 * Ret val:      --
 *+------------------------------------------------------------*/

/*HDR*/
int xmt_tbuff( MBG_MSG_CTL *pmctl )
{
  static const char soh = START_OF_HEADER;

  MBG_MSG_BUFF *pmb = pmctl->xmt.pmb;
  int n_bytes = pmb->hdr.len + sizeof( pmb->hdr );
  #if _USE_ENCRYPTION || _USE_SOCKET_IO || _USE_USB_IO
    int rc;
  #endif
  #if _USE_ENCRYPTION
    CRYPT_MSG_PREFIX cm_pfx = { { 0 } };
  #endif

  // Set up the checksums of the unencrypted packet.
  pmb->hdr.data_csum = msg_csum( pmb->u.bytes, pmb->hdr.len );
  pmb->hdr.hdr_csum = msg_hdr_csum( &pmb->hdr );

  #if _USE_ENCRYPTION
    if ( pmctl->xmt.xfer_mode == MBG_XFER_MODE_ENCRYTED )
    {
      rc = encrypt_message( pmctl, &cm_pfx, pmb );

      if ( rc < 0 )
        return rc;   // an error occurred

      n_bytes = rc;
    }
  #endif

  // n_bytes now contains the original msg data len which may 
  // possibly have been rounded up by the encryption routine. 
  //
  // The full msg consists of the CRYPT_MSG_PREFIX (if the msg 
  // has been encrypted), the msg header, and n_bytes of data.
  switch ( pmctl->conn_type )
  {
    #if _USE_SERIAL_IO
      case MBG_CONN_TYPE_SERIAL:
      {
        MBG_PORT_HANDLE port_handle = pmctl->st.serio.port_handle;

        // Note: encrypted msgs over serial are not yet supported.

        mbgserio_write( port_handle, &soh, sizeof( soh ) );
        mbgserio_write( port_handle, pmb, n_bytes );
      } break;
    #endif  // _USE_SERIAL_IO

    #if _USE_SOCKET_IO
      case MBG_CONN_TYPE_SOCKET:
      {
        uint8_t net_xmt_buffer[sizeof( MBG_MSG_BUFF ) + 1] = { 0 };
        uint8_t *p = net_xmt_buffer;

        *p++ = soh;

        rc = n_bytes;  // save the value of n_bytes

        #if _USE_ENCRYPTION
          if ( pmctl->xmt.xfer_mode == MBG_XFER_MODE_ENCRYTED )
          {
            memcpy( p, &cm_pfx, sizeof( cm_pfx ) );
            p += sizeof( cm_pfx );
            n_bytes += sizeof( cm_pfx );
          }
        #endif

        memcpy( p, pmb, rc );
        p += rc;

        n_bytes++;   // also account for SOH

        rc = sendto( pmctl->st.sockio.sockfd, net_xmt_buffer, n_bytes, 0,
                    (const struct sockaddr *) &pmctl->st.sockio.addr, 
                    sizeof( pmctl->st.sockio.addr ) );

        if ( rc < 0 )
          goto fail;

      } break;
  #endif  // _USE_SOCKET_IO
  
   #if _USE_USB_IO
      case MBG_CONN_TYPE_USB:
      {

        uint8_t usb_xmt_buffer[sizeof( MBG_MSG_BUFF ) + 1] = { 0 };
        uint8_t *p = usb_xmt_buffer;

        *p++ = soh;

        memcpy( p, pmb, n_bytes );
        n_bytes++; // account for command byte 
        --p;	

        // Note: encrypted msgs over serial are not yet supported.
        rc = mbg_usb_write( pmctl->st.usbio.udev, 0x02,  p, n_bytes, 1000 );	
        	
        if ( rc < 0 )
        {
          printf( "mbg_usb_write() returned %d.\n", rc );
          goto fail;
        }

      } break;
  #endif  // _USE_USB_IO


    default:
      goto fail;

  }  /* switch */

  return 0;

fail:
  return -1;  //##++

}  /* xmt_tbuff */



/*--------------------------------------------------------------
 * Name:         xmt_cmd()
 *
 * Purpose:      Send a command without parameters
 *
 * Input:        MBG_MSG_BUFF *pm  pointer to the message buffer
 *               ushort cmd    the command code
 *
 * Output:       --
 *
 * Ret val:      --
 *+------------------------------------------------------------*/

/*HDR*/
int xmt_cmd( MBG_MSG_CTL *pmctl, GPS_CMD cmd )
{
  MBG_MSG_BUFF *pmb = pmctl->xmt.pmb;

  pmb->hdr.len = 0;
  pmb->hdr.cmd = cmd;

  return xmt_tbuff( pmctl );

}  /* xmt_cmd */



/*--------------------------------------------------------------
 * Name:         xmt_cmd_us()
 *
 * Purpose:      Send a command that needs one parameter with
 *               type ushort.
 *
 * Input:        MBG_MSG_BUFF *pm  pointer to the message buffer
 *               ushort cmd        the command code
 *               ushort us         the parameter
 *
 * Output:       --
 *
 * Ret val:      --
 *+------------------------------------------------------------*/

/*HDR*/
int xmt_cmd_us( MBG_MSG_CTL *pmctl, GPS_CMD cmd, uint16_t us )
{
  MBG_MSG_BUFF *pmb = pmctl->xmt.pmb;

  pmb->u.msg_data.us = us;
  pmb->hdr.len = sizeof( pmb->u.msg_data.us );
  pmb->hdr.cmd = cmd;

  return xmt_tbuff( pmctl );

}  /* xmt_cmd_us  */



/*--------------------------------------------------------------
 * Name:         check_transfer()
 *
 * Purpose:      Check the sequence of incoming characters for
 *               blocks of binary data. Blocks of data are
 *               saved in a MBG_MSG_BUFF variable and the
 *               caller checks the return value to get the
 *               receive status.
 *
 * Input:        MSG_RCV_CTL *pctl  pointer to rcv ctrl structure
 *               uint8_t c          the latest char that came in
 *
 * Output:       --
 *
 * Ret val:      see header file for valid codes
 *+------------------------------------------------------------*/

/*HDR*/
int check_transfer( MBG_MSG_RCV_CTL *prctl, uint8_t c )
{
  MBG_MSG_BUFF *pmb = prctl->pmb;
  MSG_HDR *pmh = &pmb->hdr;

  if ( prctl->cnt == 0 )             /* not receiving yet */
  {
    if ( c != START_OF_HEADER )
      return TR_WAITING;             /* ignore this character */

    /* initialize receiving */
    mbg_tmo_get_time( &prctl->tstamp );
    prctl->cur = (uint8_t *) pmb;    /* first byte of buffer */
    prctl->cnt = sizeof( *pmh );     /* prepare to rcv msg header */
    prctl->flags = 0;

    return TR_RECEIVING;
  }


  /* SOH has already been received */

  if ( prctl->cur < &prctl->pmb->u.bytes[prctl->buf_size] )
  {
    *prctl->cur = c;          /* save incoming character */
    prctl->cur++;
  }
  else                        /* don't write beyond buffer */
    prctl->flags |= MBG_MSG_RCV_CTL_OVERFLOW;


  prctl->cnt--;

  if ( prctl->cnt )           /* transfer not complete */
    return TR_RECEIVING;


  /* cnt == 0, so the header or the whole message is complete */

  if ( !( prctl->flags & MBG_MSG_RCV_CTL_RCVD_HDR ) )  /* header complete now */
  {
    unsigned int data_len;

    if ( chk_hdr_csum( pmh ) < 0 )  /* error */
    {
      prctl->cnt = 0;               /* restart receiving */
      return TR_CSUM_HDR;           /* invalid header checksum received */
    }

    if ( pmh->len == 0 )            /* no data to wait for */
      goto msg_complete;            /* message complete */

    data_len = pmh->len;

    prctl->cnt = data_len;     /* save number of bytes to wait for */
    prctl->flags |= MBG_MSG_RCV_CTL_RCVD_HDR;  /* flag header complete */

    if ( data_len > ( prctl->buf_size - sizeof( *pmh ) ) )
      prctl->flags |= MBG_MSG_RCV_CTL_MSG_TOO_LONG;

    return TR_RECEIVING;
  }


  /* Header and data have been received. The header checksum has been */
  /* checked, now recompute and compare data checksum. */

  if ( chk_data_csum( pmb ) < 0 )   /* error */
  {
    prctl->cnt = 0;                 /* restart receiving */
    return TR_CSUM_DATA;            /* invalid header checksum received */
  }


msg_complete:
  return TR_COMPLETE;               /* message complete, must be evaluated */

}  /* check_transfer */




