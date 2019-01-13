
/**************************************************************************
 *
 *  $Id: ctrydttm.h 1.3 2000/09/14 15:13:45 MARTIN REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for ctrydttm.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: ctrydttm.h $
 *  Revision 1.3  2000/09/14 15:13:45  MARTIN
 *  Updated function prototypes.
 *  Revision 1.2  2000/07/21 11:50:43  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _CTRYDTTM_H
#define _CTRYDTTM_H


/* Other headers to be included */

#include <ctry.h>


#ifdef __cplusplus
extern "C" {
#endif

#ifdef _CTRYDTTM
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */






/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 ushort sprint_02u( char *s, uchar uc ) ;
 ushort sprint_04u( char *s, ushort us ) ;
 ushort sprint_ctry_wday( char *s, uchar wday, ushort language ) ;
 ushort sprint_ctry_dt_short( char *s, uchar mday, uchar month ) ;
 ushort sprint_ctry_dt( char *s, uchar mday, uchar month, ushort year ) ;
 ushort sprint_ctry_tm_short( char *s, uchar hour, uchar minute ) ;
 ushort sprint_ctry_tm( char *s, uchar hour, uchar minute, uchar second ) ;
 ushort sprint_ctry_tm_long( char *s, uchar hour, uchar minute, uchar second, long frac, ushort frac_digits ) ;

/* ----- function prototypes end ----- */

/* End of header body */


#undef _ext

#ifdef __cplusplus
}
#endif


#endif  /* _CTRYDTTM_H */

