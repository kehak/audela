
/**************************************************************************
 *
 *  $Id: pcpsutil.c 1.14 2011/06/29 11:03:44 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Utility functions used with programs for Meinberg devices.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsutil.c $
 *  Revision 1.14  2011/06/29 11:03:44  martin
 *  Updated a comment.
 *  Revision 1.13  2009/03/09 13:39:45  martin
 *  Made pcps_exp_year() an inline function.
 *  Revision 1.12  2008/12/10 19:59:48  martin
 *  Made frac_sec_from_bin() an inline function.
 *  Revision 1.11  2008/11/25 10:00:25  martin
 *  Use new definitions of fraction conversion type and scale 
 *  from pcpsdefs.h.
 *  Revision 1.10  2006/06/29 10:38:24Z  martin
 *  New function pcps_time_is_valid().
 *  Modified pcps_str_to_port(), doesn't add a 0 entry to the list anymore.
 *  Fixed a compiler warning related to type conversion.
 *  Revision 1.9  2005/01/14 10:14:31Z  martin
 *  Changed type of ISA port addr to int.
 *  Revision 1.8  2004/11/09 14:29:27Z  martin
 *  Rewrote functions using C99 fixed-size definitions.
 *  Revision 1.7  2003/04/17 10:08:59Z  martin
 *  Added some type casts to fix compiler warnings.
 *  Revision 1.6  2001/11/28 14:39:16Z  MARTIN
 *  In frac_sec_from_bin(), define the divisor as floating point
 *  constant to avoid a domain errors on 16 bit systems.
 *  Revision 1.5  2001/09/17 07:28:01  MARTIN
 *  New function frac_sec_from_bin() to convert
 *  PCPS_HR_TIME fractions.
 *  Revision 1.4  2001/03/01 14:01:09  MARTIN
 *  Modified parameters for pcps_setup_isa_ports().
 *  Revision 1.3  2000/08/31 14:05:30  MARTIN
 *  Replaced pcps_str_to_port() by pcps_setup_isa_ports().
 *  Revision 1.2  2000/07/21 13:42:54  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _PCPSUTIL
  #include <pcpsutil.h>
#undef _PCPSUTIL

#include <stdlib.h>


/*--------------------------------------------------------------
 * Name:         pcps_time_is_valid()
 *
 * Purpose:      Pack a structure with serial port parameters
 *
 * Input/Output: p   address of a structure holding both the
 *                   packed and unpacked information
 *
 * Ret value:    --
 *-------------------------------------------------------------*/

/*HDR*/
int pcps_time_is_valid( const PCPS_TIME *p )
{
  return ( p->sec100 <= 99 )
      && ( p->sec <= 60 )   /* allow for leap second */
      && ( p->min <= 59 )
      && ( p->hour <= 23 )
      && ( p->mday >= 1 ) && ( p->mday <= 31 )
      && ( p->wday >= 1 ) && ( p->wday <= 7 )
      && ( p->month >= 1 ) && ( p->month <= 12 )
      && ( p->year <= 99 );

}  /* pcps_time_is_valid */



/*--------------------------------------------------------------
 * Name:         pcps_str_to_port()
 *
 * Purpose:      Try to convert a string to a valid port
 *               address.
 *
 * Input:        s   the string
 *
 * Output:       --
 *
 * Ret value:    a valid port number or 0
 *+-------------------------------------------------------------*/

/*HDR*/
void pcps_setup_isa_ports( char *s,
                           int *port_vals,
                           int n_vals )
{
  ushort i;


  for ( i = 0; i < n_vals; i++ )
  {
    if ( *s == 0 )
      break;

    *port_vals++ = (uint16_t) strtoul( s, &s, 16 );

    if ( *s == ',' )
      s++;
  }

}  // pcps_setup_isa_ports



/*--------------------------------------------------------------
 * Name:         pcps_unpack_serial()
 *
 * Purpose:      Unpack a structure with serial port parameters
 *
 * Input/Output: p   address of a structure holding both the
 *                   packed and unpacked information
 *
 * Ret value:    --
 *-------------------------------------------------------------*/

/*HDR*/
void pcps_unpack_serial( PCPS_SER_PACK *p )
{
  uint8_t pack = p->pack;

  p->baud = (uint8_t) ( pack & BITMASK( PCPS_BD_BITS ) );
  p->frame = (uint8_t) ( ( pack >> PCPS_FR_SHIFT ) & BITMASK( PCPS_FR_BITS ) );
  p->mode = (uint8_t) ( ( pack >> PCPS_MOD_SHIFT ) & BITMASK( PCPS_MOD_BITS ) );

}  // pcps_unpack_serial



/*--------------------------------------------------------------
 * Name:         pcps_pack_serial()
 *
 * Purpose:      Pack a structure with serial port parameters
 *
 * Input/Output: p   address of a structure holding both the
 *                   packed and unpacked information
 *
 * Ret value:    --
 *-------------------------------------------------------------*/

/*HDR*/
void pcps_pack_serial( PCPS_SER_PACK *p )
{
  p->pack = (uint8_t) ( ( p->baud & BITMASK( PCPS_BD_BITS ) )
        | ( ( p->frame & BITMASK( PCPS_FR_BITS ) ) << PCPS_FR_SHIFT )
        | ( ( p->mode & BITMASK( PCPS_MOD_BITS ) ) << PCPS_MOD_SHIFT ) );

}  /* pcps_pack_serial */



