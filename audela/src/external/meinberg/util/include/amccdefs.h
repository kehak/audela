
/**************************************************************************
 *
 *  $Id: amccdefs.h 1.2 2007/06/06 10:16:53 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions to be used with AMCC PCI interface chips.
 *
 * -----------------------------------------------------------------------
 *  $Log: amccdefs.h $
 *  Revision 1.2  2007/06/06 10:16:53  martin
 *  Moved some IRQ bit masks here.
 *  Revision 1.1  2000/07/20 09:19:39Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _AMCCDEFS_H
#define _AMCCDEFS_H


/* Other headers to be included */


#ifdef _AMCCDEFS
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */


// The following operation registers are implemented
// in the S5933. The registers can be accessed via port
// I/O to base_addr_0 + offset as defined below:

#define AMCC_OP_REG_OMB1    0x00  // Outgoing Mail Box 1
#define AMCC_OP_REG_OMB2    0x04  // Outgoing Mail Box 2
#define AMCC_OP_REG_OMB3    0x08  // Outgoing Mail Box 3
#define AMCC_OP_REG_OMB4    0x0C  // Outgoing Mail Box 4
#define AMCC_OP_REG_IMB1    0x10  // Incoming Mail Box 1
#define AMCC_OP_REG_IMB2    0x14  // Incoming Mail Box 2
#define AMCC_OP_REG_IMB3    0x18  // Incoming Mail Box 3
#define AMCC_OP_REG_IMB4    0x1C  // Incoming Mail Box 4
#define AMCC_OP_REG_FIFO    0x20  // FIFO Register
#define AMCC_OP_REG_MWAR    0x24  // Master Write Address Register
#define AMCC_OP_REG_MWTC    0x28  // Master Write Transfer Count Register
#define AMCC_OP_REG_MRAR    0x2C  // Master Read Address Register
#define AMCC_OP_REG_MRTC    0x30  // Master Read Transfer Count Register
#define AMCC_OP_REG_MBEF    0x34  // Mailbox Empty/Full Status
#define AMCC_OP_REG_INTCSR  0x38  // Interrupt Control/Status Register
#define AMCC_OP_REG_MCSR    0x3C  // Bus Master Control/Status Register

#define AMCC_OP_REG_RANGE_S5933  0x40  // number of operation registers



// The following operation registers are implemented
// in the S5920. The registers can be accessed via port
// I/O to base_addr_0 + offset as defined below:

#define AMCC_OP_REG_OMB     0x0C  // Outgoing Mail Box
#define AMCC_OP_REG_IMB     0x1C  // Incoming Mail Box
#define AMCC_OP_REG_MBEF    0x34  // Mailbox Empty/Full Status
#define AMCC_OP_REG_INTCSR  0x38  // Interrupt Control/Status Register
#define AMCC_OP_REG_RCR     0x3C  // Reset Control Register
#define AMCC_OP_REG_PTCR    0x60  // Pass-Thru Configuration Register

#define AMCC_OP_REG_RANGE_S5920  0x64  // number of operation registers



// The following bit masks are used by the drivers in order to
// control interrupts on the PCI bus:

#define AMCC_INT_MASK     0x0000FFFFL
#define AMCC_INT_ENB      ( 1L << 12 )
#define AMCC_INT_FLAG     ( 1L << 17 )
#define AMCC_INT_ACK      ( AMCC_INT_ENB | AMCC_INT_FLAG )


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


#endif  /* _AMCCDEFS_H */
