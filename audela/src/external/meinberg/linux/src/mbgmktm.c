
/**************************************************************************
 *
 *  $Id: mbgmktm.c 1.1 2006/08/22 08:57:15 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Function to convert broken down time to Unix time (seconds since 1970)
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgmktm.c $
 *  Revision 1.1  2006/08/22 08:57:15  martin
 *  Former function totalsec() moved here from pcpsmktm.c.
 *
 **************************************************************************/

#define _MBGMKTM
 #include <mbgmktm.h>
#undef _MBGMKTM

#include <sys/types.h>


static const char Days[12] =
{
  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

static int YDays[12] =
{
  0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334
};


/*--------------------------------------------------------------
 * Name:         mbg_mktime()
 *
 * Purpose:      This function works like the standard mktime() 
 *               function but does not account for a timezone
 *               setting configured for the standard C library.
 *               Also, it does not take a structure but a set 
 *               of variables which makes it more versatile.
 *               The accepted variables are in the same ranges
 *               as the struct tm members used by mktime().
 *
 *  Input:       int year   year - 1900
 *               int month  months since January, 0..11
 *               int day    days after 1st, 0..30
 *               int hour   0..23
 *               int min    0..59
 *               int sec    0..59, 60 if leap second
 *
 * Output:       --
 *
 * Ret value:    seconds since 1970 (Unix time_t format)
 *               or -1 if range overflow
 *-------------------------------------------------------------*/

/*HDR*/
long mbg_mktime( int year, int month, int day,
                 int hour, int min, int sec )
{
  int leaps;
  long days;
  long secs;


  if ( year < 70 || year > 138 )
    return ( -1 );

  min += sec / 60;
  sec %= 60;              /* Seconds are normalized */
  hour += min / 60;
  min %= 60;              /* Minutes are normalized */
  day += hour / 24;
  hour %= 24;             /* Hours are normalized   */

  year += month / 12;     /* Normalize month (not necessarily final) */
  month %= 12;

  while ( day >= Days[month] )
  {
    if ( !( year & 3 ) && ( month == 1 ) )
    {
      if (day > 28)
      {
        day -= 29;
        month++;
      }
      else
        break;
    }
    else
    {
      day -= Days[month];
      month++;
    }

    year += month / 12; /* Normalize month */
    month %= 12;
  }

  year -= 70;
  leaps = ( year + 2 ) / 4;

  if ( !( ( year + 70 ) & 3 ) && ( month < 2 ) )
    --leaps;

  days = year * 365L + leaps + YDays[month] + day;

  secs = days * 86400L + hour * 3600L + min * 60L + sec;

  return( secs > 0 ? secs : -1 );

}  // mbg_mktime

