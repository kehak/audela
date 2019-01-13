
/**************************************************************************
 *
 *  $Id: plxdefs.h 1.2 2010/01/28 15:46:31 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions to be used with PLX PCIexpress interface chips.
 *
 * -----------------------------------------------------------------------
 *  $Log: plxdefs.h $
 *  Revision 1.2  2010/01/28 15:46:31  martin
 *  Added PLX8311_REG_CTRL.
 *  Revision 1.1  2007/06/08 07:46:56Z  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _PLXDEFS_H
#define _PLXDEFS_H


/* Other headers to be included */


#ifdef _PLXDEFS
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

// The following PLX8311 operation registers can
// be accessed via port I/O or memory mapped:
#define PLX8311_REG_INTCSR  0x68

// The following bits must be set in the INTCSR register
// to let the local microcontroller be able to generate
// interrupts on the PCI bus via the chip's LINTi# line:
#define PLX8311_INT_ENB     ( (1UL << 11) | (1UL << 8) )

// The bit below signals if an LINTi# interrupt is active:
#define PLX8311_INT_FLAG    (1UL << 15)

#define PLX8311_REG_CNTRL   0x6C


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


#endif  /* _PLXDEFS_H */
