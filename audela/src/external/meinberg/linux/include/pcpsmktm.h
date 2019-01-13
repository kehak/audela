
/**************************************************************************
 *
 *  $Id: pcpsmktm.h 1.1 2001/02/02 15:31:07 MARTIN REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for pcpsmktm.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsmktm.h $
 *  Revision 1.1  2001/02/02 15:31:07  MARTIN
 *
 **************************************************************************/

#ifndef _PCPSMKTM_H
#define _PCPSMKTM_H


/* Other headers to be included */

#include <pcpsdefs.h>


#ifdef _PCPSMKTM
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

//_ext PCPS_TIME tx;

/* End of header body */

#undef _ext


/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 long pcps_mktime( PCPS_TIME *tp ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


#endif  /* _PCPSMKTM_H */
