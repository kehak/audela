
/**************************************************************************
 *
 *  $Id: mbgmktm.h 1.1 2006/08/22 08:57:15 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for mbgmktm.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgmktm.h $
 *  Revision 1.1  2006/08/22 08:57:15  martin
 *  Former function totalsec() moved here from pcpsmktm.c.
 *
 **************************************************************************/

#ifndef _MBGMKTM_H
#define _MBGMKTM_H


/* Other headers to be included */

#ifdef _MBGMKTM
 #define _ext
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

long mbg_mktime( int year, int month, int day, int hour, int min, int sec ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif

/* End of header body */

#undef _ext

#endif  /* _MBGMKTM_H */
