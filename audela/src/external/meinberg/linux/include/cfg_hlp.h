
/**************************************************************************
 *
 *  $Id: cfg_hlp.h 1.1 2011/09/21 15:59:59 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for configuration programs.
 *
 * -----------------------------------------------------------------------
 *  $Log: cfg_hlp.h $
 *  Revision 1.1  2011/09/21 15:59:59  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _CFG_HLP_H
#define _CFG_HLP_H


/* Other headers to be included */

#include <gpsdefs.h>


#ifdef _CFG_HLP
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#ifdef __cplusplus
extern "C" {
#endif


/*
 * The definitions and types below are used to collect
 * all configuration parameters of a clock's serial ports
 * that can be handled by this library:
 */


/*
 * The maximum number of clocks' serial ports and string types
 * that can be handled by the configuration programs.
 * WARNING: Changing these constants affects the size of the
 * structures ALL_PORT_INFO ALL_STR_TYPE_INFO
 */
#define MAX_PARM_PORT        4
#define MAX_PARM_STR_TYPE    20

typedef PORT_INFO_IDX ALL_PORT_INFO[MAX_PARM_PORT];
typedef STR_TYPE_INFO_IDX ALL_STR_TYPE_INFO[MAX_PARM_STR_TYPE];

typedef struct
{
  ALL_PORT_INFO pii;
  ALL_STR_TYPE_INFO stii;
  PORT_PARM tmp_pp;

} RECEIVER_PORT_CFG;


/*
 * The definitions and types below are used to collect
 * all configuration parameters of a clock's programmable
 * pulse outputs that can be handled by this library:
 */

#define MAX_PARM_POUT        4

typedef POUT_INFO_IDX ALL_POUT_INFO[MAX_PARM_POUT];



/*
 * The definitions and types below are used to collect
 * all configuration parameters of PTP device's unicast
 * master specification:
 */

#define MAX_PARM_PTP_UC_MASTER    3

typedef PTP_UC_MASTER_INFO_IDX ALL_PTP_UC_MASTER_INFO[MAX_PARM_PTP_UC_MASTER];




/* function prototypes: */

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */


/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _CFG_HLP_H */
