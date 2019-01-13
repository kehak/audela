
/**************************************************************************
 *
 *  $Id: ctry.c 1.7 2010/07/15 08:26:57 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Functions providing support for different country settings
 *    and languages.
 *
 *    Some OS dependent functions may be required which can be found
 *    in the OS dependent modules ctry_xxx.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: ctry.c $
 *  Revision 1.7  2010/07/15 08:26:57  martin
 *  Added clstr_lng() implemented by stefan returning a translated string
 *  by giving the different strings as function arguments.
 *  Revision 1.6  2007/03/29 12:21:51  martin
 *  New functions lstr_idx() and lstr_array_idx().
 *  Revision 1.1  2010/06/01 07:57:03  philipp
 *  Revision 1.5  2004/10/26 07:39:37Z  martin
 *  Use C99 fixed-size definitions where appropriate.
 *  Revision 1.4  2001/09/14 12:02:12  MARTIN
 *  Modified parameters for lstr_lng().
 *  Revision 1.3  2000/11/27 14:09:24  MARTIN
 *  Replaced lstr() by lstr_lng() with takes a language paramter to allow
 *  retrieval of strings for another than the current language.
 *  A new macro _lstr() has been added to ctry.h which calls lstr_lng()
 *  passing the current language.
 *  The functions ctry_fmt_dt() and ctry_fmt_times() and associated
 *  definitions have been moved to a new module ctry_fmt.c/ctry_fmt.h.
 *  Revision 1.2  2000/07/21 10:00:08  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _CTRY
 #include <ctry.h>
#undef _CTRY

#include <stdio.h>
#include <stdarg.h>
#include <string.h>


// Return the index of a CLSTR component for a
// certain language lng

/*HDR*/
int lstr_idx( CLSTR s, int lng )
{
  if ( lng >= N_LNG )  // if lng out of range
    return 0;          // use default index

  // If there are duplicate strings for several languages
  // then the duplicate strings may be NULL, in which case
  // the string at index 0 must be used.
  return s[lng] ? lng : 0;

}  // lstr_idx



// Return the index of a CLSTR component for a
// certain language lng out of an array of CLSTRs.
//   CLSTR s:    the array of CLSTRs
//   int idx:    the index of the array element
//   int n_lng:  the number of supported languages
//   int lng:    the language for which the inex shall be retrieved

/*HDR*/
int lstr_array_idx( CLSTR s, int idx, int n_lng, int lng )
{
  int str_idx = n_lng * idx;
  return str_idx + lstr_idx( &s[str_idx], lng );

}  // lstr_array_idx



/*HDR*/
const char *lstr_lng( CLSTR s, int lng )
{
  return s[lstr_idx( s, lng)];

}  // lstr_lng



/*HDR*/
void ctry_setup( CTRY_CODE code )
{
  language = LNG_ENGLISH;
  ctry.code = code;

  switch ( code )
  {
    case CTRY_US:
      ctry.dt_fmt = DT_FMT_MMDDYYYY;
      ctry.dt_sep = DT_SEP_MINUS;
      ctry.tm_fmt = TM_FMT_24H;
      ctry.tm_sep = TM_SEP_COLON;
      break;


    case CTRY_UK:
      ctry.dt_fmt = DT_FMT_DDMMYYYY;
      ctry.dt_sep = DT_SEP_SLASH;
      ctry.tm_fmt = TM_FMT_24H;
      ctry.tm_sep = TM_SEP_COLON;
      break;


    default:
      language = LNG_GERMAN;
      ctry.code = CTRY_GERMANY;

      ctry.dt_fmt = DT_FMT_DDMMYYYY;
      ctry.dt_sep = DT_SEP_DOT;
      ctry.tm_fmt = TM_FMT_24H;
      ctry.tm_sep = TM_SEP_COLON;

  }  /* switch */


}  /* ctry_setup */



/*HDR*/
void ctry_next( void )
{
  switch ( ctry.code )
  {
    case CTRY_GERMANY:
      ctry_setup( CTRY_US );
      break;

    case CTRY_US:
      ctry_setup( CTRY_UK );
      break;

    default:
      ctry_setup( CTRY_GERMANY );
      break;

  }  // switch

}  // ctry_next



/*HDR*/
const char *clstr_lng( int index, ... )
{
  const char *ret;
  const char *default_ret;
  int i;
  typedef char *MY_LSTR;

  va_list ap;
  va_start( ap, index );

  ret = va_arg( ap, MY_LSTR );
  default_ret = ret;

  for ( i = 1; ( i <= index ) && ( ret != NULL ); i++ )
    ret = va_arg( ap, MY_LSTR );

  va_end( ap );

  return ret ? ret : default_ret;

}  // clstr_lng

