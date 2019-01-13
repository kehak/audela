
/**************************************************************************
 *
 *  $Id: gpsutils.h 1.4.1.2 2010/07/15 09:19:04 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for gpsutils.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: gpsutils.h $
 *  Revision 1.4.1.2  2010/07/15 09:19:04  martin
 *  Use DEG character definition from pcpslstr.h.
 *  Revision 1.4.1.1  2003/05/15 09:40:25Z  martin
 *  Changed degree string/char for QNX.
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
 void sprint_pos_geo( char *s, POS *ppos, const char *sep, int prec ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _GPSUTILS_H */

