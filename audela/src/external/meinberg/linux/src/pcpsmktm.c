
/**************************************************************************
 *
 *  $Id: pcpsmktm.c 1.4 2006/12/14 15:27:49 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Function to convert PCPS_TIME to Unix time (seconds since 1970)
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsmktm.c $
 *  Revision 1.4  2006/12/14 15:27:49  martin
 *  Include time.h.
 *  Revision 1.3  2006/08/22 09:10:03  martin
 *  Renamed function totalsec() to mbg_mktime() and moved it
 *  to a separate file mbgmktm.c.
 *  Revision 1.2  2001/08/14 11:58:08  MARTIN
 *  Included sys/time.h for time_t definition.
 *  Revision 1.1  2001/02/02 15:30:09  MARTIN
 *
 **************************************************************************/

#define _PCPSMKTM
 #include <pcpsmktm.h>
#undef _PCPSMKTM

#include <mbgmktm.h>

#include <time.h>


/*HDR*/
long pcps_mktime( PCPS_TIME *tp )
{
  time_t secs;
  int year = tp->year;

  if ( year < 70 )
    year += 100;

  secs = mbg_mktime( year, tp->month - 1, tp->mday - 1,
                     tp->hour, tp->min, tp->sec );

  if ( secs != -1 )
    secs -= tp->offs_utc * 3600;

  return( secs );

}  // pcps_mktime



