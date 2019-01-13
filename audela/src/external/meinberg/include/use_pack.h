
/**************************************************************************
 *
 *  $Id: use_pack.h,v 1.1 2011-02-23 14:19:10 myrtillelaas Exp $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Check the current compiler type to decide if pragma pack() is 
 *    required to pack cross-platform data structures.
 *
 * -----------------------------------------------------------------------
 *  $Log: not supported by cvs2svn $
 *  Revision 1.2  2002/02/25 08:50:33Z  Andre
 *  query __ARM added, __SH2 removed
 *  Revision 1.1  2001/03/30 08:54:33Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _USE_PACK_H
#define _USE_PACK_H

#if ( !defined( _C166 ) && !defined( _CC51 ) && !defined( __ARM ) )
  #define _USE_PACK   
#endif

#endif  /* _USE_PACK_H */

