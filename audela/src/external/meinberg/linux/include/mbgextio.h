
/**************************************************************************
 *
 *  $Id: mbgextio.h 1.8.2.6 2011/11/28 15:46:44 martin TEST martin $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for mbgextio.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgextio.h $
 *  Revision 1.8.2.6  2011/11/28 15:46:44  martin
 *  Updated function prototypes.
 *  Revision 1.8.2.5  2011/11/25 15:11:21  martin
 *  Account for renamed event log library symbols.
 *  Revision 1.8.2.4  2011/11/21 16:34:17  marvin
 *  new function: support event log
 *  Revision 1.8.2.3  2011/08/31 09:10:21  marvin
 *  Updated function prototypes.
 *  Revision 1.8.2.2  2011/08/23 10:17:08  martin
 *  Updated function prototypes.
 *  Revision 1.8.2.1  2011/08/19 13:05:34  martin
 *  Started to migrate to opaque stuctures.
 *  Revision 1.8  2011/04/08 11:26:09  martin
 *  New macros _ttm_time_set_unavail() and _ttm_time_is_avail().
 *  Revision 1.7  2009/10/02 14:21:08  martin
 *  Updated function prototypes.
 *  Revision 1.6  2009/10/01 11:13:42Z  martin
 *  Updated function prototypes.
 *  Revision 1.5  2009/03/10 17:03:09Z  martin
 *  Updated function prototypes.
 *  Revision 1.4  2008/09/04 14:13:19Z  martin
 *  Added macro _mbgextio_xmt_msg().
 *  Updated function prototypes.
 *  Removed obsolete code.
 *  Revision 1.3  2007/02/27 10:30:06Z  martin
 *  Added some global variables.
 *  Updated function prototypes.
 *  Revision 1.2  2006/12/21 10:56:35  martin
 *  Updated function prototypes.
 *  Revision 1.1  2006/08/24 12:40:37  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _MBGEXTIO_H
#define _MBGEXTIO_H


/* Other headers to be included */

#include <gpsserio.h>
#include <time.h>

#ifdef _MBGEXTIO
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */


// The macros below can be used to set a TTM variable to a state
// indicating "time not available", and to check this state.
// This can be used for example to indicate if a capture event
// could have been read from a device, or not.
#define _ttm_time_set_unavail( _t )       do { (_t)->tm.sec = (uint8_t) 0xFF; } while ( 0 )
#define _ttm_time_is_avail( _t )          ( (uint8_t) (_t)->tm.sec != (uint8_t) 0xFF )


#if _USE_SERIAL_IO
  #if !defined( DEFAULT_DEV_NAME )
    #if defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_DOS )
      #define DEFAULT_DEV_NAME   "COM1"
    #elif defined( MBG_TGT_LINUX )
      #define DEFAULT_DEV_NAME   "/dev/ttyS0"
    #endif
  #endif
#endif  // _USE_SERIAL_IO


#if !defined MBGEXTIO_READ_BUFFER_SIZE
  #if _USE_SOCKET_IO
    #define MBGEXTIO_READ_BUFFER_SIZE  1000
  #else
    #define MBGEXTIO_READ_BUFFER_SIZE  10
  #endif
#endif


_ext uint32_t mbg_baud_rates[N_MBG_BAUD_RATES]
#ifdef _DO_INIT
  = MBG_BAUD_RATES
#endif
;

_ext const char *mbg_baud_rate_strs[N_MBG_BAUD_RATES]
#ifdef _DO_INIT
  = MBG_BAUD_STRS
#endif
;

_ext const char *mbg_framing_strs[N_MBG_FRAMINGS]
#ifdef _DO_INIT
  = MBG_FRAMING_STRS
#endif
;



/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 _NO_MBG_API_ATTR MBG_MSG_CTL * _MBG_API mbgextio_open_socket( const char *host, const char *passwd ) ;
 _NO_MBG_API_ATTR MBG_MSG_CTL * _MBG_API mbgextio_open_serial( const char *dev, uint32_t baud_rate, const char *framing ) ;
 _NO_MBG_API_ATTR void _MBG_API mbgextio_close_connection( MBG_MSG_CTL **ppmctl ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_force_connection( const char *dev ) ;
 _NO_MBG_API_ATTR void _MBG_API mbgextio_set_char_rcv_timeout( MBG_MSG_CTL *pmctl, ulong new_timeout ) ;
 _NO_MBG_API_ATTR ulong _MBG_API mbgextio_get_char_rcv_timeout( const MBG_MSG_CTL *pmctl ) ;
 _NO_MBG_API_ATTR void _MBG_API mbgextio_set_msg_rcv_timeout( MBG_MSG_CTL *pmctl, ulong new_timeout ) ;
 _NO_MBG_API_ATTR ulong _MBG_API mbgextio_get_msg_rcv_timeout( const MBG_MSG_CTL *pmctl ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_xmt_msg( MBG_MSG_CTL *pmctl, GPS_CMD cmd,  const void *p, size_t n_bytes ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_rcv_msg( MBG_MSG_CTL *pmctl, GPS_CMD cmd ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_xmt_cmd( MBG_MSG_CTL *pmctl, GPS_CMD cmd ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_xmt_cmd_us( MBG_MSG_CTL *pmctl, GPS_CMD cmd, uint16_t us ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_req_data( MBG_MSG_CTL *pmctl, GPS_CMD cmd ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_req_data_idx( MBG_MSG_CTL *pmctl, GPS_CMD cmd, uint16_t idx ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_receiver_info( MBG_MSG_CTL *pmctl, RECEIVER_INFO *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_sw_rev( MBG_MSG_CTL *pmctl, SW_REV *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_bvar_stat( MBG_MSG_CTL *pmctl, BVAR_STAT *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_time( MBG_MSG_CTL *pmctl, TTM *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_time( MBG_MSG_CTL *pmctl, const TTM *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_pos_lla( MBG_MSG_CTL *pmctl, LLA lla ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_pos_lla( MBG_MSG_CTL *pmctl, const LLA lla ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_tzdl( MBG_MSG_CTL *pmctl, TZDL *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_tzdl( MBG_MSG_CTL *pmctl, const TZDL *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_port_parm( MBG_MSG_CTL *pmctl, PORT_PARM *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_port_parm( MBG_MSG_CTL *pmctl, const PORT_PARM *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_synth( MBG_MSG_CTL *pmctl, SYNTH *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_synth( MBG_MSG_CTL *pmctl, const SYNTH *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_ant_info( MBG_MSG_CTL *pmctl, ANT_INFO *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_ucap( MBG_MSG_CTL *pmctl, TTM *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_enable_flags( MBG_MSG_CTL *pmctl, ENABLE_FLAGS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_enable_flags( MBG_MSG_CTL *pmctl, const ENABLE_FLAGS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_stat_info( MBG_MSG_CTL *pmctl, STAT_INFO *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_ant_cable_len( MBG_MSG_CTL *pmctl, ANT_CABLE_LEN *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_ant_cable_len( MBG_MSG_CTL *pmctl, const ANT_CABLE_LEN *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_irig_tx_info( MBG_MSG_CTL *pmctl, IRIG_INFO *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_irig_tx_settings( MBG_MSG_CTL *pmctl, const IRIG_SETTINGS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_irig_rx_info( MBG_MSG_CTL *pmctl, IRIG_INFO *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_irig_rx_settings( MBG_MSG_CTL *pmctl, const IRIG_SETTINGS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_ref_offs( MBG_MSG_CTL *pmctl, MBG_REF_OFFS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_ref_offs( MBG_MSG_CTL *pmctl, const MBG_REF_OFFS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_debug_status( MBG_MSG_CTL *pmctl, MBG_DEBUG_STATUS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_opt_info( MBG_MSG_CTL *pmctl, MBG_OPT_INFO *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_opt_settings( MBG_MSG_CTL *pmctl, const MBG_OPT_SETTINGS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_str_type_info_idx( MBG_MSG_CTL *pmctl, STR_TYPE_INFO_IDX *p, uint16_t idx ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_port_info_idx( MBG_MSG_CTL *pmctl,  PORT_INFO_IDX *p, uint16_t idx ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_port_settings_idx( MBG_MSG_CTL *pmctl, const PORT_SETTINGS *p, uint16_t idx ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_pout_info_idx( MBG_MSG_CTL *pmctl,  POUT_INFO_IDX *p, uint16_t idx ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_pout_settings_idx( MBG_MSG_CTL *pmctl,  const POUT_SETTINGS *p, uint16_t idx ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_clr_ucap_buff( MBG_MSG_CTL *pmctl ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_time_scale_info( MBG_MSG_CTL *pmctl,  MBG_TIME_SCALE_INFO *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_set_time_scale_settings( MBG_MSG_CTL *pmctl,  const MBG_TIME_SCALE_SETTINGS *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_clr_evt_log( MBG_MSG_CTL *pmctl ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_num_evt_log_entries( MBG_MSG_CTL *pmctl, MBG_NUM_EVT_LOG_ENTRIES *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_first_evt_log_entry( MBG_MSG_CTL *pmctl, MBG_EVT_LOG_ENTRY *p ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgextio_get_next_evt_log_entry( MBG_MSG_CTL *pmctl, MBG_EVT_LOG_ENTRY *p ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif

#define _mbgextio_xmt_msg( _pmctl, _cmd, _s ) \
  mbgextio_xmt_msg( _pmctl, _cmd, _s, sizeof( *(_s) ) )

/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _MBGEXTIO_H */
