
/**************************************************************************
 *
 *  $Id: identdec.c 1.3 2009/04/01 14:15:05 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Supplies a function to decode various types of a GPS receiver's
 *    IDENT structure and generate a group code + S/N string.
 *
 * -----------------------------------------------------------------------
 *  $Log: identdec.c $
 *  Revision 1.3  2009/04/01 14:15:05  martin
 *  Fixed compiler warning.
 *  Revision 1.2  2002/11/21 08:11:59Z  martin
 *  Avoid usage of strcpy functions since they may not
 *  be available in kernel space for some targets.
 *  Revision 1.1  2002/02/19 13:46:19  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _IDENTDEC
 #include <identdec.h>
#undef _IDENTDEC

#include <qsdefs.h>


// Some targets don't support isdigit() from ctype.h:
#define _is_digit( _c )  ( (_c) >= '0' && (_c) <= '9' )


// Some targets are unable to call functions from the
// stancard C library, so we provide necessary functions locally.

static /*HDR*/
char *do_strnpcpy( char *p_dst, const char *p_src, int n )
{
  int i;

  for ( i = 0; i < n; i++ )
  {
    char c = *p_src++;
    *p_dst++ = c;

    if ( c == 0 )
      break;
  }

  return p_dst;

}  // do_strnpcpy



/*--------------------------------------------------------------
 * Name:         mbg_gps_ident_decode()
 *
 * Purpose:      Convert a GPS ident code to a string with
 *               serial number.
 *
 * Input:        p_id  pointer to the IDENT
 *
 * Output:       s     the resulting string
 *
 * Ret value:    --
 *+-------------------------------------------------------------*/

/*HDR*/
char *mbg_gps_ident_swap( char *p_dst, const char *p_src )
{
  int i;

  for ( i = 0; i < 4; i++ )
  {
    *p_dst++ = *( p_src + 3 );
    *p_dst++ = *( p_src + 2 );
    *p_dst++ = *( p_src + 1 );
    *p_dst++ = *( p_src );
    p_src += 4;
  }

  return( p_dst );

}  // mbg_gps_ident_swap



/*HDR*/
void mbg_gps_ident_decode( char *s, const IDENT *p_id )
{
  char ws[sizeof( *p_id ) + 1];  // tmp buffer
  char *cp;
  char c = 0;
  int n_spaces = 0;
  int i;

  // get string from binary format used by firmware
  mbg_gps_ident_swap( ws, (const char *) p_id );

  // make sure the resulting string is terminated by 0
  ws[sizeof( *p_id )] = 0;

  // Now ws contains a raw string which may be in one
  // of the following formats. The first one, which includes
  // a group code is the preferred format:
  //
  // "gggg    nnnnnnnn"  group code, gap filled with spaces, S/N
  // "nnnnnnnn........"  S/N, plus non-digits
  // "........nnnnnnnn"  non-digits, followed by S/N

  cp = ws;

  // test for the number of digits at the beginning
  for ( i = 0; i < MBG_SERNUM_LEN; i++ )
  {
    c = *cp++;

    if ( !_is_digit( c ) )
      break;
  }

  if ( i != MBG_GRP_CODE_LEN )
    goto copy;   // not a group code


  // expect a number of spaces
  n_spaces = sizeof( *p_id ) - MBG_GRP_SERNUM_LEN;

  for ( i = 0; i < n_spaces; i++ )
  {
    if ( c != ' ' )
    {
      n_spaces = 0;
      goto copy;
    }

    c = *cp++;
  }


  // test number of S/N digits
  for ( i = 0; i < MBG_SERNUM_LEN; i++ )
  {
    if ( !_is_digit( c ) )
    {
      n_spaces = 0;
      goto copy;
    }

    c = *cp++;
  }

copy:
  cp = do_strnpcpy( s, ws, MBG_GRP_CODE_LEN );
  i = MBG_GRP_CODE_LEN + n_spaces;
  do_strnpcpy( cp, &ws[i], sizeof( ws ) - i );

}  // mbg_gps_ident_decode



