
/**************************************************************************
 *
 *  $Id: parmpcps.h 1.7.1.1 2011/06/09 11:04:21 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for parmpcps.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: parmpcps.h $
 *  Revision 1.7.1.1  2011/06/09 11:04:21  martin
 *  Revision 1.7  2011/04/01 10:30:51  martin
 *  Fixed macro syntax for _setup_default_receiver_info_dcf().
 *  Revision 1.6  2011/02/16 10:13:12  martin
 *  Fixed macro syntax for _setup_default_receiver_info_pcps().
 *  Revision 1.5  2004/11/09 14:24:58Z  martin
 *  Updated function prototypes.
 *  Revision 1.4  2004/05/19 07:52:25Z  martin
 *  Fixed macro setting default number of string types.
 *  Revision 1.3  2004/04/14 09:21:44Z  martin
 *  Pack structures 1 byte aligned.
 *  Revision 1.2  2003/04/17 10:42:46Z  martin
 *  Moved typedef RECEIVER_PORT_CFG to pcpsdev.h.
 *  Moved some definitions from parmpcps.c here.
 *  Removed some global variables.
 *  Updated function prototypes.
 *  Revision 1.1  2002/02/19 14:00:19Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _PARMPCPS_H
#define _PARMPCPS_H

/* Other headers to be included */

#include <pcpsdev.h>
#include <use_pack.h>


#ifdef _PARMPCPS
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


#ifdef __cplusplus
extern "C" {
#endif


#define DEFAULT_BAUD_RATES_DCF \
(                              \
  MBG_PORT_HAS_300   |         \
  MBG_PORT_HAS_600   |         \
  MBG_PORT_HAS_1200  |         \
  MBG_PORT_HAS_2400  |         \
  MBG_PORT_HAS_4800  |         \
  MBG_PORT_HAS_9600            \
)

#define DEFAULT_BAUD_RATES_DCF_HS \
(                                 \
  MBG_PORT_HAS_300   |            \
  MBG_PORT_HAS_600   |            \
  MBG_PORT_HAS_1200  |            \
  MBG_PORT_HAS_2400  |            \
  MBG_PORT_HAS_4800  |            \
  MBG_PORT_HAS_9600  |            \
  MBG_PORT_HAS_19200 |            \
  MBG_PORT_HAS_38400              \
)


#define DEFAULT_FRAMINGS_DCF \
(                            \
  MBG_PORT_HAS_7E2 |         \
  MBG_PORT_HAS_8N1 |         \
  MBG_PORT_HAS_8N2 |         \
  MBG_PORT_HAS_8E1           \
)


#define DEFAULT_N_STR_TYPE_DCF  1

#define DEFAULT_SUPP_STR_TYPES_DCF \
  ( ( 1UL << DEFAULT_N_STR_TYPE_DCF ) - 1 )


/*
 * The macro below can be used to initialize a
 * RECEIVER_INFO structure for DCF77 receivers
 * which don't supply that structure.
 *
 * Parameters: (RECEIVER_INFO *) _p
 */
#define _setup_default_receiver_info_dcf( _p, _pdev )    \
do                                                       \
{                                                        \
  memset( (_p), 0, sizeof( *(_p) ) );                    \
                                                         \
  (_p)->ticks_per_sec = DEFAULT_GPS_TICKS_PER_SEC;       \
  (_p)->n_ucaps = 0;                                     \
  (_p)->n_com_ports = _pcps_has_serial( _pdev ) ? 1 : 0; \
  (_p)->n_str_type = ( (_p)->n_com_ports != 0 ) ?        \
                     DEFAULT_N_STR_TYPE_DCF : 0;         \
} while ( 0 )


#define DEFAULT_MAX_STR_TYPE   2   //##++ DEFAULT_N_STR_TYPE_GPS

_ext STR_TYPE_INFO default_str_type_info[DEFAULT_MAX_STR_TYPE] 
#ifdef _DO_INIT
  = {
      { DEFAULT_STR_MODES,      "Default Time String", "Time", 0 },
      { DEFAULT_STR_MODES_UCAP, "Capture String",      "Cap",  0 }
    }
#endif
;



/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 void port_info_from_pcps_serial( PORT_INFO_IDX *p_pii, PCPS_SERIAL pcps_serial, uint32_t supp_baud_rates ) ;
 void pcps_serial_from_port_info( PCPS_SERIAL *p, const PORT_INFO_IDX *p_pii ) ;

/* ----- function prototypes end ----- */


#ifdef __cplusplus
}
#endif


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */


#undef _ext
#undef _DO_INIT

#endif  /* _PARMPCPS_H */
