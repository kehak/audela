
/**************************************************************************
 *
 *  $Id: parmgps.h 1.7.1.1 2011/06/09 11:04:14 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for parmgps.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: parmgps.h $
 *  Revision 1.7.1.1  2011/06/09 11:04:14  martin
 *  Revision 1.7  2011/02/16 10:12:13  martin
 *  Fixed macro syntax for _setup_default_receiver_info_gps().
 *  Revision 1.6  2008/10/21 10:41:09Z  martin
 *  Renamed check_port_info() to check_valid_port_info()
 *  to avoid naming conflicts.
 *  Revision 1.5  2008/09/10 16:22:32  martin
 *  Updated function prototypes.
 *  Revision 1.4  2004/11/09 14:22:34  martin
 *  Updated function prototypes.
 *  Revision 1.3  2004/05/19 07:50:16Z  martin
 *  Use symbolic constant as initializer.
 *  Revision 1.2  2004/04/14 09:21:23Z  martin
 *  Pack structures 1 byte aligned.
 *  Revision 1.1  2002/01/30 10:33:38Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _PARMGPS_H
#define _PARMGPS_H


/* Other headers to be included */

#include <gpsdefs.h>
#include <use_pack.h>


#ifdef _PARMGPS
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


#define DEFAULT_N_STR_TYPE_GPS      2

#define DEFAULT_SUPP_STR_TYPES_GPS  \
  ( ( 1UL << DEFAULT_N_STR_TYPE_GPS ) - 1 )


/*
 * The macro below can be used to initialize a
 * RECEIVER_INFO structure for old GPS receiver models
 * which don't supply that structure.
 *
 * Parameters: (RECEIVER_INFO *) _p
 */
#define _setup_default_receiver_info_gps( _p )      \
do                                                  \
{                                                   \
  memset( (_p), 0, sizeof( *(_p) ) );               \
                                                    \
  (_p)->ticks_per_sec = DEFAULT_GPS_TICKS_PER_SEC;  \
  (_p)->n_ucaps = 2;                                \
  (_p)->n_com_ports = DEFAULT_N_COM;                \
  (_p)->n_str_type = DEFAULT_N_STR_TYPE_GPS;        \
} while ( 0 )


_ext BAUD_RATE mbg_baud_rate[N_MBG_BAUD_RATES]
#ifdef _DO_INIT
 = MBG_BAUD_RATES
#endif
;

_ext const char *mbg_baud_str[N_MBG_BAUD_RATES]
#ifdef _DO_INIT
 = MBG_BAUD_STRS
#endif
;

_ext const char *mbg_framing_str[N_MBG_FRAMINGS]
#ifdef _DO_INIT
 = MBG_FRAMING_STRS
#endif
;


/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 int get_str_idx( const char *search, const char *str_table[], int n_entries ) ;
 int get_baud_rate_idx( BAUD_RATE baud_rate ) ;
 int get_framing_idx( const char *framing ) ;
 void port_settings_from_port_parm_mode( PORT_SETTINGS *p_ps, uint8_t pp_mode, int str_type_cap ) ;
 void port_parm_mode_from_port_settings( uint8_t *pp_mode, const PORT_SETTINGS *p_ps, int str_type_cap ) ;
 void port_settings_from_port_parm( PORT_SETTINGS *p_ps, int port_num, const PORT_PARM *p_pp, int cap_str_idx ) ;
 void port_parm_from_port_settings( PORT_PARM *p_pp, int port_num, const PORT_SETTINGS *p_ps, int cap_str_idx ) ;
 int check_valid_port_info( const PORT_INFO *p, const STR_TYPE_INFO_IDX str_type_info_idx[], int n_str_type ) ;
 int valid_port_info( const PORT_INFO *p, const STR_TYPE_INFO_IDX str_type_info_idx[], int n_str_type ) ;

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

#endif  /* _PARMGPS_H */

