
/**************************************************************************
 *
 *  $Id: gpsutils.h,v 1.1 2011-02-23 14:19:10 myrtillelaas Exp $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for gpsutils.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: not supported by cvs2svn $
 *  Revision 1.6  2005/02/18 10:32:33Z  martin
 *  Check more predefined macros to determine if compiling for Windows.
 *  Revision 1.5  2003/02/04 09:18:48Z  MARTIN
 *  Updated function prototypes.
 *  Revision 1.4  2002/12/12 16:08:11  martin
 *  Definitions for degree character.
 *  Requires mbggeo.h.
 *  Updated function prototypes.
 *  Revision 1.3  2001/02/05 09:40:42Z  MARTIN
 *  New file header.
 *  Source code cleanup.
 *
 **************************************************************************/

#ifndef _GPSUTILS_H
#define _GPSUTILS_H


/* Other headers to be included */

#include <mbggeo.h>


#ifdef _GPSUTILS
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#define ANSI_C_DEGREE     '°'    // single char
#define ANSI_S_DEGREE     "°"    // string

#if defined( _Windows ) || defined( _WINDOWS ) \
  || defined( WIN32 ) || defined( __linux )
  #define C_DEGREE  ANSI_C_DEGREE
  #define S_DEGREE  ANSI_S_DEGREE
#else
  #define C_DEGREE  'ø'
  #define S_DEGREE  "ø"
#endif


/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 void swap_double( double *d ) ;
 void swap_eph_doubles( EPH *ephp ) ;
 void swap_alm_doubles( ALM *almp ) ;
 void swap_utc_doubles( UTC *utcp ) ;
 void swap_iono_doubles( IONO *ionop ) ;
 void swap_pos_doubles( POS *posp ) ;
 void sprint_dms( char *s, DMS *pdms, int prec ) ;
 void sprint_alt( char *s, double alt ) ;
 void sprint_pos_geo( char *s, POS *ppos, const char *sep, int prec ) ;
 void sprint_fixed_freq( char *s, FIXED_FREQ_INFO *p_ff ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _GPSUTILS_H */

