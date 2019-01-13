
/**************************************************************************
 *
 *  $Id: use_pack.h 1.3 2011/01/26 10:01:41 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Check the current compiler type to decide if pragma pack() is 
 *    required to pack cross-platform data structures.
 *
 * -----------------------------------------------------------------------
 *  $Log: use_pack.h $
 *  Revision 1.3  2011/01/26 10:01:41  martin
 *  Provided a way to suppress packing of structures on a project base.
 *  Revision 1.2  2002/02/25 08:50:33  Andre
 *  query __ARM added, __SH2 removed
 *  Revision 1.1  2001/03/30 08:54:33Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _USE_PACK_H
#define _USE_PACK_H

#if ( !defined( _C166 ) && \
      !defined( _CC51 ) && \
      !defined( __ARM ) )

  // _NO_USE_PACK can be defined for specific projects
  // to avoid packing of structures.
  #if ( !defined( _NO_USE_PACK ) )
    #define _USE_PACK
  #endif

#endif

#endif  /* _USE_PACK_H */

