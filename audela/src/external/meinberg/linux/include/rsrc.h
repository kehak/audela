
/**************************************************************************
 *
 *  $Id: rsrc.h 1.4.1.1 2006/09/19 14:52:02 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions used to access resource manager functions under
 *    different operating systems.
 *
 * -----------------------------------------------------------------------
 *  $Log: rsrc.h $
 *  Revision 1.4.1.1  2006/09/19 14:52:02  martin
 *  Preliminary support for *BSD.
 *  Revision 1.4  2001/02/28 15:45:11  MARTIN
 *  Modified preprocessor syntax.
 *  Revision 1.3  2001/02/05 10:22:24  MARTIN
 *  Linux support.
 *  Revision 1.2  2000/09/20 08:15:34  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _RSRC_H
#define _RSRC_H


/* Other headers to be included */

#include <mbg_tgt.h>

#if defined( MBG_TGT_OS2 )
  #include <rsrc_os2.h>     // resource manager functions for OS/2
#elif defined( MBG_TGT_WIN32 )
  #include <rsrc_nt.h>      // resource manager functions for Win NT
#elif defined( MBG_TGT_LINUX )
  #include <rsrc_lx.h>      // resource manager functions for Linux
#elif defined( MBG_TGT_BSD )
  #include <rsrc_bsd.h>      // resource manager functions for *BSD
#endif



#ifdef _RSRC
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

enum
{
  RSRC_BUS_ISA,
  RSRC_BUS_EISA,
  RSRC_BUS_MCA,
  RSRC_BUS_PCI
};


/* End of header body */

#undef _ext


/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

/* (no header definitions found) */

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


#endif  /* _RSRC_H */

