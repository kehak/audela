
/**************************************************************************
 *
 *  $Id: qsdefs.h 1.1 2002/02/19 13:46:20 MARTIN REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions used with the Meinberg Quality Management System.
 *
 * -----------------------------------------------------------------------
 *  $Log: qsdefs.h $
 *  Revision 1.1  2002/02/19 13:46:20  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _QSDEFS_H
#define _QSDEFS_H


/* Other headers to be included */

/* Start of header body */

// The fixed length of the group code string:
#define MBG_GRP_CODE_LEN    4

// The mem size required to store a group code string
// including terminating 0:
#define MBG_GRP_CODE_SIZE   ( MBG_GRP_CODE_LEN + 1 )

// A data type used to store a group code string:
typedef char MBG_GRP_CODE[MBG_GRP_CODE_SIZE];


// The length of the serial number:
#define MBG_SERNUM_LEN      8

// The length of the group code + serial number:
#define MBG_GRP_SERNUM_LEN  ( MBG_GRP_CODE_LEN + MBG_SERNUM_LEN )


/* End of header body */

#endif  /* _QSDEFS_H */
