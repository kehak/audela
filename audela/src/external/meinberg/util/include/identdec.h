
/**************************************************************************
 *
 *  $Id: identdec.h 1.1 2002/02/19 13:46:19 MARTIN REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for identdec.h.
 *
 * -----------------------------------------------------------------------
 *  $Log: identdec.h $
 *  Revision 1.1  2002/02/19 13:46:19  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _IDENTDEC_H
#define _IDENTDEC_H


/* Other headers to be included */

#include <gpsdefs.h>


#ifdef _IDENTDEC
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

 char *mbg_gps_ident_swap( char *p_dst, const char *p_src ) ;
 void mbg_gps_ident_decode( char *s, const IDENT *p_id ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _IDENTDEC_H */
