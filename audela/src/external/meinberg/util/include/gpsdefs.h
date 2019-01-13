
/**************************************************************************
 *
 *  $Id: gpsdefs.h 1.99 2011/12/09 09:22:03 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    General definitions to be used with Meinberg clocks.
 *    These definitions have initially be used with GPS devices only.
 *    However, more and more Meinberg non-GPS devices also use some of
 *    these definitions.
 *
 * -----------------------------------------------------------------------
 *  $Log: gpsdefs.h $
 *  Revision 1.99  2011/12/09 09:22:03  martin
 *  Fixed a typo.
 *  Revision 1.98  2011/11/25 14:58:34  martin
 *  Renamed some evt_log definitions.
 *  Revision 1.97  2011/11/25 10:11:17  martin
 *  Initializers for XMRS status bit strings added by gregoire.
 *  New feature GPS_FEAT_EVT_LOG.
 *  Added definitions used with event logs.
 *  Moved cal_reg and gen_io stuff here.
 *  Added macro _mbg_swab_debug_status().
 *  Updated some comments.
 *  Revision 1.96  2011/10/11 13:40:46Z  andre
 *  changed reserved field into slot_id in XMULTI_REF_INSTANCES
 *  Revision 1.95.1.1  2011/10/07 09:31:58Z  andre
 *  Revision 1.95  2011/10/04 09:35:41Z  martin
 *  Added support for ESI180.
 *  Changed RECEIVER_INFO::flags bit GPS_10MHZ_DISBD to a RECEIVER_INFO::features bit.
 *  Support MULTI_REF_INTERNAL, MULTI_REF_LWR and MULTI_REF_PZF.
 *  Added MBG_GPIO_BITS structure and associated definitions.
 *  Revision 1.94  2011/08/25 07:42:43Z  martin
 *  Fixed a bug  in macro _mbg_swab_pout_settings() where the 16 bit timeout
 *  field was swapped using a macro for 32 bit types.
 *  Use shorter names for some PTP unicast master default values.
 *  Revision 1.93  2011/08/10 08:19:38Z  martin
 *  New PORT_INFO and PORT_SETTINGS flag PORT_FLAG_PORT_INVISIBLE.
 *  Revision 1.92  2011/07/29 09:49:35  martin
 *  Support PZF180PEX, MGR180, MSF600, WWVB600, JJY600,
 *  GPS180HS, and GPS180AMC.
 *  Added receiver info features GPS_FEAT_PTP_UNICAST
 *  and GPS_FEAT_XMRS_MULT_INSTC.
 *  Added receiver info flag bit GPS_10MHZ_DISBD.
 *  Added initializers for PTP timescale names.
 *  New PTP_STATE flags bit PTP_FLAG_MSK_IS_UNICAST.
 *  Made unused PTP_STATE fields num_clients and num_masters reserved.
 *  Account for different PTP roles.
 *  Added / renamed some definitions for PTP.
 *  Modified default string for PTP layer 2 protocol.
 *  Support PTP unicast configuration.
 *  Support GPIO configuration.
 *  Introduced XMULTI_REF_INSTANCES.
 *  Moved flags XMRS_..._IS_EXTERNAL and XMRS_..._INSTC_EXCEEDED
 *  to definitions for XMULTI_REF_STATUS::status.
 *  Some comments added, updated, and converted to doxygen style.
 *  Cleaned up handling of pragma pack().
 *  Removed trailing whitespace and hard tabs.
 *  Revision 1.91  2011/01/31 11:23:56Z  martin
 *  Added model type name definitions for GPS180PEX and TCR180PEX.
 *  Introduced synthesizer mode for programmable outputs.
 *  Added IRIG-RX code TXC-101 DTR-6.
 *  Fixed missing comma bugs in DEFAULT_GPS_MODEL_NAMES.
 *  Fixed missing comma bugs in some IRIG string initializers.
 *  Fixed AFNOR notation.
 *  Modified some comments for doxygen.
 *  Revision 1.90  2010/10/15 11:47:53  martin
 *  Added definitions POUT_TIMEBASE_UTC and POUT_SUPP_DCF77_UTC.
 *  Added receiver info feature GPS_FEAT_RAW_IRIG_TIME.
 *  Support IRIG format C37.118.
 *  Added initializers for short IRIG code names.
 *  Cleaned up IRIG definitions and comments.
 *  Revision 1.89  2010/09/06 07:40:02Z  martin
 *  Picked up Daniel's definitions for multi GNSS support.
 *  Moved MBG_IRIG_CTRL_BITS, MBG_RAW_IRIG_DATA and related definitions
 *  from pcpsdefs.h here.
 *  Added macros _pcps_tfom_from_irig_ctrl_bits()
 *  and _pcps_tfom_from_raw_irig_data().
 *  Added RI_FEATURES type.
 *  Revision 1.88  2010/04/21 13:47:54  daniel
 *  Added support for new model GLN170.
 *  Revision 1.87  2010/03/10 11:29:37Z  martin
 *  Added definitions for GPS180.
 *  Added multiref source 1 PPS plus associated string.
 *  Revision 1.86  2010/02/17 14:16:42  martin
 *  Added definitions for PZF600 and TCR600.
 *  Revision 1.85  2010/02/15 11:34:36  martin
 *  Changed definition of PTP_TABLE::name to const char *.
 *  Added definitions to support new model JJY511.
 *  Revision 1.84  2010/02/01 13:20:50  martin
 *  Support programmable outputs being disabled when sync. is lost.
 *  Revision 1.83  2010/01/28 09:15:50  martin
 *  Added new POUT mode DCF77_M59 and associated definitions.
 *  Revision 1.82  2010/01/07 09:04:55  martin
 *  Added XMR status bit XMRS_BIT_NOT_PHASE_LOCKED.
 *  Revision 1.81  2009/11/09 09:08:24  martin
 *  New TM_GPS status bit TM_INVT.
 *  Added definitions to support VLAN.
 *  Changed DEFAULT_PTP_DELAY_MECH_MASK to include also
 *  PTP_DELAY_MECH_MSK_P2P.
 *  There is now only one type of  TCXO supported which matches the former
 *  TCXO HQ, so the default name for TCXO HQ has been changed to TCXO.
 *  TCXO LQ and MQ names are still supported for backward compatibility.
 *  Revision 1.80  2009/09/28 14:55:53  martin
 *  Support IRIG formats G002/G142 and G006/G146.
 *  Modified IRIG format description strings.
 *  Revision 1.79  2009/08/12 14:12:38  daniel
 *  Added definitions to support new model MGR170.
 *  Added definitions and commands to support configuration
 *  of navigation engine (currently supported by u-blox
 *  receivers only).
 *  Renamed simulation values in PTP_SETTINGS to reserved.
 *  Added "UNINITIALIZED" to PTP port state.
 *  Removed obsolete braces in initializer.
 *  Revision 1.78  2009/06/25 15:49:05Z  martin
 *  Added macro _nano_time_negative().
 *  Revision 1.77  2009/06/08 19:22:32Z  daniel
 *  Added feature GPS_HAS_PTP.
 *  Added preliminary structures and definitions for PTP
 *  configuration and state.
 *  Added IP4_ADDR type.
 *  Added Bitmask IP4_MSK_DHCP.
 *  Added byte swapper macros for LAN and PTP structures.
 *  Moved LAN interface configuration definitions here.
 *  Moved DAC_VAL definition here.
 *  Changed type iof FPGA_INFO::start_addr for non-firmware applications.
 *  Revision 1.76  2009/04/08 08:26:56  daniel
 *  Added feature GPS_FEAT_IRIG_CTRL_BITS.
 *  Revision 1.75  2009/03/19 14:06:39Z  martin
 *  Modified string initializer for unknown oscillator type.
 *  Revision 1.74  2009/03/18 13:45:53  daniel
 *  Added missing commas in
 *  MBG_DEBUG_STATUS_STRS initializer.
 *  Adjusted some comments for doxygen parser.
 *  Revision 1.73  2009/03/10 16:55:33Z  martin
 *  Support configurable time scales GPS and TAI.
 *  Defined extended TM status type and associated flags.
 *  Added definition TM_MSK_TIME_VALID.
 *  Added some macros to swap endianess of structures.
 *  Revision 1.72  2008/11/28 09:26:21Z  daniel
 *  Added definitions to support WWVB511
 *  Revision 1.71  2008/10/31 14:31:44Z  martin
 *  Added definitions for TCR170PEX.
 *  Revision 1.70  2008/09/18 11:14:39  martin
 *  Added definitions to support GEN170.
 *  Revision 1.69  2008/09/15 14:16:17  martin
 *  Added more macros to convert the endianess of structures.
 *  Added N_COM_HS to the enumeration of handshake modes.
 *  Added MBG_PS_... codes.
 *  Revision 1.68  2008/08/25 10:51:13  martin
 *  Added definitions for PTP270PEX and FRC511PEX.
 *  Revision 1.67  2008/07/17 08:54:52Z  martin
 *  Added macros to convert the endianess of structures.
 *  Added multiref fixed frequency source.
 *  Revision 1.66  2008/05/19 14:49:07  daniel
 *  Renamed s_addr to start_addr in FPGA_INFO.
 *  Revision 1.65  2008/05/19 09:00:01Z  martin
 *  Added definitions for GPS162.
 *  Added FPGA_INFO and GPS_HAS_FPGA.
 *  Added FPGA_START_INFO and associated definitions.
 *  Added new XMRS status XMRS_..._NOT_SETTLED.
 *  Added initializer XMULTI_REF_STATUS_INVALID.
 *  Revision 1.64  2008/01/17 11:50:33Z  daniel
 *  Made IGNORE_LOCK bit maskable.
 *  Revision 1.63  2008/01/17 11:42:09Z  daniel
 *  Made comments compatible for Doxygen parser.
 *  No sourcecode changes.
 *  Revision 1.62  2007/11/15 13:23:33Z  martin
 *  Decide whether other Meinberg headers are to be included depending on whether
 *  CLOCK_MEINBERG is defined (as with NTP) or not. Previous  versions checked
 *  for "PACKAGE" which is also defined by the Borland C++ build environment, though.
 *  Revision 1.61  2007/11/13 13:28:54  daniel
 *  Added definitions to support GPS170PEX.
 *  Revision 1.60  2007/09/13 12:37:35Z  martin
 *  Modified and added initializers for TZDL.
 *  Added multiref source PTP over E1.
 *  Added codes for MSF511 and GRC170 devices.
 *  Modified XMULTI_REF_SETTINGS and XMULTI_REF_STATUS structures.
 *  Avoid inclusion of other Meinberg headers in non-Meinberg projects.
 *  Added device classification macros _mbg_rcvr_is_...().
 *  Modified feature name string initializer for non-GPS devices.
 *  Updated some comments.
 *  Removed some obsolete comments.
 *  Revision 1.59  2007/07/19 07:41:56Z  martin
 *  Added symbol MBG_REF_OFFS_NOT_CFGD.
 *  Revision 1.58  2007/05/21 15:46:44Z  martin
 *  Fixed a typo.
 *  Revision 1.57  2007/03/29 12:20:43  martin
 *  Fixed some TZDL initializers.
 *  Revision 1.56  2007/02/14 14:17:10Z  andre
 *  bug fixed in mask XMRS_MSK_NO_CONN
 *  Revision 1.55  2007/02/06 16:23:18Z  martin
 *  Added definitions for AM511.
 *  Made SVNO unsigned.
 *  Added support for OPT_SETTINGS.
 *  Added XMULTI_REF_... definitions.
 *  Added string initializer DEFAULT_FREQ_RANGES.
 *  Revision 1.54  2007/01/04 11:39:39Z  martin
 *  Added definitions for TCR511.
 *  Added definition GPS_FEAT_5_MHZ.
 *  Updated some comments related to duplicate features/options
 *  IGNORE_LOCK and EMU_SYNC.
 *  Revision 1.53  2006/12/13 09:31:49  martin
 *  Added feature flag for ignore_lock.
 *  Revision 1.52  2006/12/12 15:47:18  martin
 *  Added MBG_DEBUG_STATUS type and associated definitions.
 *  Added definition GPS_HAS_REF_OFFS.
 *  Moved PCPS_REF_OFFS and associated definitions from pcpsdefs.h here
 *  and renamed them to MBG_REF_OFFS, etc.
 *  Revision 1.51  2006/10/23 15:31:27  martin
 *  Added definitions for GPS170.
 *  Added definitions for new multi_ref sources IRIG, NTP, and PTP.
 *  Added some definitions useful when editing synth frequency.
 *  Revision 1.50  2006/08/25 09:29:28Z  martin
 *  Added structure NANO_TIME.
 *  Revision 1.49  2006/08/09 07:06:42Z  martin
 *  New TM_GPS status flag TM_EXT_SYNC.
 *  Revision 1.48  2006/08/08 12:51:20Z  martin
 *  Added definitions for IRIG codes B006/B126 and B007/B127.
 *  Revision 1.47  2006/07/06 08:41:45Z  martin
 *  Added definition of MEINBERG_MAGIC.
 *  Revision 1.46  2006/06/21 14:08:53Z  martin
 *  Added masks of IRIG codes which contain time zone information.
 *  Revision 1.45  2006/06/15 12:13:32Z  martin
 *  Added MULTI_REF_STATUS and associated flags.
 *  Added ROM_CSUM, RCV_TIMEOUT, and IGNORE_LOCK types.
 *  Revision 1.44  2006/05/18 09:34:41Z  martin
 *  Added definitions for POUT max. pulse_len and max timeout.
 *  Changed comment for POUT_SETTINGS::timeout:
 *  Units are minutes, not seconds.
 *  Added definition for MAX_POUT_TIME_STR_PORTS.
 *  Added definitions for POUT mode 10MHz.
 *  Added hint strings for POUT modes.
 *  Added definitions for PZF511.
 *  Revision 1.43  2006/01/24 07:53:29Z  martin
 *  New TM_GPS status flag TM_HOLDOVER.
 *  Revision 1.42  2005/11/24 14:53:22Z  martin
 *  Added definitions for manchester encoded DC IRIG frames.
 *  Added POUT_TIMESTR and related definitions.
 *  Revision 1.41  2005/11/03 15:06:59Z  martin
 *  Added definitions to support GPS170PCI.
 *  Revision 1.40  2005/10/28 08:58:29Z  martin
 *  Added definitions for OCXO_DHQ.
 *  Revision 1.39  2005/09/08 14:06:00Z  martin
 *  Added definition SYNTH_PHASE_SYNC_LIMIT.
 *  Revision 1.38  2005/08/18 10:27:35  andre
 *  added definitions for GPS164,
 *  added POUT_TIMECODE,
 *  struct SCU_STAT changed,
 *  ulong flags changed into two byte clk_info and ushort flags
 *  Revision 1.37  2005/05/02 14:44:55Z  martin
 *  Added structure SYNTH_STATE and associated definitions.
 *  Revision 1.36  2005/03/29 12:44:07Z  martin
 *  New RECEIVER_INFO::flags code: GPS_IRIG_FO_IN
 *  Revision 1.35  2004/12/09 14:04:38Z  martin
 *  Changed max synth freq from 12 MHz to 10 MHz.
 *  Revision 1.34  2004/11/23 16:20:09Z  martin
 *  Added bit definitions for the existing TTM status bit masks.
 *  Revision 1.33  2004/11/09 12:39:59Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Added model code and name for TCR167PCI.
 *  New type GPS_CMD.
 *  Defined type BVAR_STAT and associated flags.
 *  Revision 1.32  2004/09/20 12:46:25  andre
 *  Added structures and definitions for SCU board.
 *  Revision 1.31  2004/07/08 08:30:36Z  martin
 *  Added feature GPS_FEAT_RCV_TIMEOUT.
 *  Revision 1.30  2004/06/21 13:38:42  martin
 *  New flag MBG_OPT_BIT_EMU_SYNC/MBG_OPT_FLAG_EMU_SYNC
 *  lets the receicer emulate/pretend to be always synchronized.
 *  Revision 1.30  2004/06/21 13:35:46Z  martin
 *  Revision 1.29  2004/06/16 12:47:53Z  martin
 *  Moved OPT_SETTINGS related definitions from pcpsdefs.h
 *  here and renamed symbols from PCPS_.. to to MBG_...
 *  Revision 1.28  2004/03/26 10:37:00Z  martin
 *  Added definitions to support multiple ref sources.
 *  Added definitions OSC_DAC_RANGE, OSC_DAC_BIAS.
 *  Revision 1.27  2004/03/08 14:06:45Z  martin
 *  New model code and name for GPS169PCI.
 *  Existing feature GPS_FEAT_IRIG has been
 *  renamed to GPS_FEAT_IRIG_TX.
 *  Added feature GPS_FEAT_IRIG_RX.
 *  Added IPv4 LAN interface feature flags.
 *  Renamed IFLAGS_IGNORE_TFOM to IFLAGS_DISABLE_TFOM.
 *  Revision 1.26  2003/12/05 12:28:20Z  martin
 *  Added some codes used with IRIG cfg.
 *  Revision 1.25  2003/10/29 16:18:14Z  martin
 *  Added 7N2 to DEFAULT_GPS_FRAMINGS_GP2021.
 *  Revision 1.24  2003/09/30 08:49:48Z  martin
 *  New flag TM_LS_ANN_NEG which is set in addition to
 *  TM_LS_ANN if next leap second is negative.
 *  Revision 1.23  2003/08/26 14:32:33Z  martin
 *  Added some initializers for commonly used
 *  TZDL configurations.
 *  Revision 1.22  2003/04/25 10:18:11  martin
 *  Fixed typo inside an IRIG name string initializer.
 *  Revision 1.21  2003/04/15 09:18:48  martin
 *  New typedef ANT_CABLE_LEN.
 *  Revision 1.20  2003/04/03 11:03:44Z  martin
 *  Extended definitions for IRIG support.
 *  Revision 1.19  2003/01/31 13:38:20  MARTIN
 *  Modified type of RECEIVER_INFO.fixed_freq field.
 *  Revision 1.18  2002/10/28 09:24:07  MARTIN
 *  Added/renamed some POUT related symbols.
 *  Revision 1.17  2002/09/05 10:58:39  MARTIN
 *  Renamed some symbols related to programmable outputs.
 *  Revision 1.16  2002/08/29 08:04:47  martin
 *  Renamed structure POUT_PROG to POUT_SETTINGS.
 *  New structures POUT_SETTINGS_IDX, POUT_INFO,
 *  POUT_INFO_IDX and associated definitions.
 *  Updated some comments.
 *  Revision 1.15  2002/07/17 07:39:39Z  Andre
 *  comma added in definition DEFAULT_GPS_OSC_NAMES
 *  Revision 1.14  2002/06/27 12:17:29Z  MARTIN
 *  Added new oscillator code TCXO_MQ.
 *  Added initializer for oscillator names.
 *  Added initializer for oscillator list ordered by quality.
 *  Revision 1.13  2002/05/08 08:16:03  MARTIN
 *  Added GPS_OSC_CFG_SUPP for RECEIVER_INFO::flags.
 *  Fixed some comments.
 *  Revision 1.12  2002/03/14 13:45:56  MARTIN
 *  Changed type CSUM from short to ushort.
 *  Revision 1.11  2002/03/01 12:29:30  Andre
 *  Added GPS_MODEL_GPS161 and GPS_MODEL_NAME_GPS161.
 *  Revision 1.10  2002/02/25 08:02:33Z  MARTIN
 *  Added array of chars to union IDENT.
 *  Revision 1.9  2002/01/29 15:21:46  MARTIN
 *  Added new field "reserved" to struct SW_REV to fix C166 data
 *  alignment/structure size. Converted structure IDENT to a union.
 *  The changes above should not affect existing monitoring programs.
 *  New status flag TM_ANT_SHORT.
 *  New structure RECEIVER_INFO and associated definitions to
 *  enhance control from monitoring programs.
 *  New structures PORT_INFO, STR_TYPE_INFO, and associated
 *  definitions to simplify and unify configuration from external programs.
 *  New structures IRIG_INFO and POUT_PROG_IDX to configure an
 *  optional IRIG interface and programmable pulse outputs.
 *  Modified some comments.
 *  Revision 1.8  2001/03/30 11:44:11  MARTIN
 *  Control alignment of structures from new file use_pack.h.
 *  Defined initializers with valid baud rate and framing parameters.
 *  Modified some comments.
 *  Revision 1.7  2001/03/01 08:09:22  MARTIN
 *  Modified preprocessor syntax.
 *  Revision 1.6  2000/07/21 14:04:33  MARTIN
 *  Added som #if directives to protect structures against being multiply
 *  defined.
 *  Modified some comments.
 *  Comments using characters for +/- and degree now include ASCII
 *  characters only.
 *
 **************************************************************************/

#ifndef _GPSDEFS_H
#define _GPSDEFS_H


/* Other headers to be included */

#if defined( HAVE_CONFIG_H )
  // this is mainly to simplify usage in non-Meinberg projects
  #include <config.h>
#endif

// CLOCK_MEINBERG is defined in NTP's config.h if configured
// to support Meinberg clocks.
#if !defined( CLOCK_MEINBERG )
  // avoid having to use these headers in non-Meinberg projects
  #include <words.h>
  #include <use_pack.h>
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


/* "magic" number */
#define MEINBERG_MAGIC 0x6AAC

#define MIN_SVNO         1                  /* min. SV number */
#define MAX_SVNO        32                  /* max. SV number */
#define N_SVNO ( MAX_SVNO - MIN_SVNO + 1)   /* number of possibly active SVs */


#define GPS_ID_STR_LEN      16
#define GPS_ID_STR_SIZE     ( GPS_ID_STR_LEN + 1 )

#define GPS_EPLD_STR_LEN    8
#define GPS_EPLD_STR_SIZE   ( GPS_EPLD_STR_LEN + 1 )


#define DEFAULT_GPS_TICKS_PER_SEC   10000000L  /* system time base */

#if !defined( GPS_TICKS_PER_SEC )
  /*
   * The actual ticks per seconds may vary for different
   * GPS receiver models. If this is the case, the receiver
   * model support the RECEIVER_INFO structure which contains
   * the actual value.
   */
  #define GPS_TICKS_PER_SEC   DEFAULT_GPS_TICKS_PER_SEC
#endif


typedef uint16_t SVNO;    /* the number of a SV */
typedef uint16_t HEALTH;  /* a SV's health code */
typedef uint16_t CFG;     /* a SV's configuration code */
typedef uint16_t IOD;     /* Issue-Of-Data code */


/* the type of various checksums */

#ifndef _CSUM_DEFINED
  typedef uint16_t CSUM;
  #define _CSUM_DEFINED

  #define _mbg_swab_csum( _p )    _mbg_swab16( _p )
#endif


/**
 * @brief The type of a GPS command code
 *
 * These command codes can be passed via
 * @ref gps_cmds_serial "serial port" (see @file gpsserio.h), or
 * @ref gps_cmds_bus "system bus" (see @file pcpsdefs.h).
 */
typedef uint16_t GPS_CMD;

#define _mbg_swab_gps_cmd( _p )    _mbg_swab16( _p )


/**
 * @brief Software revision information
 *
 * Contains a software revision code, plus an optional
 * identifier for a customized version.
 */
typedef struct
{
  uint16_t code;               /**< Version number, e.g. 0x0120 means v1.20 */
  char name[GPS_ID_STR_SIZE];  /**< Optional string identifying a customized version */
  uint8_t reserved;            /**< Reserved field to yield even structure size */
} SW_REV;

#define _mbg_swab_sw_rev( _p )  \
{                               \
  _mbg_swab16( &(_p)->code );   \
}



/**
 * @defgroup group_bvar_stat BVAR_STAT status of buffered GPS data
 *
 * Status word, associated bit numbers and bit masks indicating
 * whether certain data from the GPS satellites are
 * available and valid.
 *
 * These bits defined are set in ::BVAR_STAT if the corresponding
 * parameters are NOT valid and complete.
 *
 * @{ */

/**
 * @brief Status flags of battery buffered data received
 * from GPS satellites.
 *
 * All '0' means OK, single bits set to '1' indicate
 * the associated type of GPS data is not available.
 */
typedef uint16_t BVAR_STAT;

#define _mbg_swab_bvar_stat( _p )  _mbg_swab16( (_p) )


/** @brief Enumeration of bits used with BVAR_STAT */
enum
{
  BVAR_BIT_CFGH_INVALID,
  BVAR_BIT_ALM_NOT_COMPLETE,
  BVAR_BIT_UTC_INVALID,
  BVAR_BIT_IONO_INVALID,
  BVAR_BIT_RCVR_POS_INVALID,
  N_BVAR_BIT     /**< @brief number of defined ::BVAR_STAT bits */
};

#define BVAR_CFGH_INVALID      ( 1UL << BVAR_BIT_CFGH_INVALID )      /**< @brief Configuration and health data (::CFGH) not valid */
#define BVAR_ALM_NOT_COMPLETE  ( 1UL << BVAR_BIT_ALM_NOT_COMPLETE )  /**< @brief Almanach data (::ALM) not complete */
#define BVAR_UTC_INVALID       ( 1UL << BVAR_BIT_UTC_INVALID )       /**< @brief UTC data not valid */
#define BVAR_IONO_INVALID      ( 1UL << BVAR_BIT_IONO_INVALID )      /**< @brief Ionospheric correction data (::IONO) not valid */
#define BVAR_RCVR_POS_INVALID  ( 1UL << BVAR_BIT_RCVR_POS_INVALID )  /**< @brief Receiver position (::POS) not valid */

#define BVAR_MASK  ( ( 1UL << N_BVAR_BIT ) - 1 )       /**< @brief Bit mask for all defined bits */

/** @} group_bvar_stat */



/**
 A structure used to hold a fixed frequency value.
 frequ[kHz] = khz_val * 10^range
*/

typedef struct
{
  uint16_t khz_val;     /* the base frequency in [kHz] */
  int16_t range;        /* an optional base 10 exponent */
} FIXED_FREQ_INFO;

#define _mbg_swab_fixed_freq_info( _p )  \
{                                        \
  _mbg_swab16( &(_p)->khz_val );         \
  _mbg_swab16( &(_p)->range );           \
}


typedef uint32_t RI_FEATURES;     // type of RECEIVER_INFO::features field


/*
 * The following code defines features and properties
 * of the various GPS receivers. Older GPS receivers
 * may require a recent firmvare version to support
 * this, or may not support this at all.
 */

/**
 * The structure is ordered in a way that all fields
 * except chars or arrays of chars are word-aligned.
 */
typedef struct
{
  uint16_t model_code;               /**< identifier for receiver model */
  SW_REV sw_rev;                     /**< software revision and ID */
  char model_name[GPS_ID_STR_SIZE];  /**< ASCIIZ, name of receiver model */
  char sernum[GPS_ID_STR_SIZE];      /**< ASCIIZ, serial number */
  char epld_name[GPS_EPLD_STR_SIZE]; /**< ASCIIZ, file name of EPLD image */
  uint8_t n_channels;       /**< number of sats to be tracked simultaneously */
  uint32_t ticks_per_sec;   /**< resolution of fractions of seconds */
  RI_FEATURES features;     /**< optional features, see below */
  FIXED_FREQ_INFO fixed_freq; /**< optional non-standard fixed frequency */
  uint8_t osc_type;         /**< type of installed oscillator, see below */
  uint8_t osc_flags;        /**< oscillator flags, see below */
  uint8_t n_ucaps;          /**< number of user time capture inputs */
  uint8_t n_com_ports;      /**< number of on-board serial ports */
  uint8_t n_str_type;       /**< max num of string types supported by any port */
  uint8_t n_prg_out;        /**< number of programmable pulse outputs */
  uint16_t flags;           /**< additional information, see below */
} RECEIVER_INFO;

#define _mbg_swab_receiver_info( _p )              \
{                                                  \
  _mbg_swab16( &(_p)->model_code );                \
  _mbg_swab_sw_rev( &(_p)->sw_rev );               \
  _mbg_swab16( &(_p)->ticks_per_sec );             \
  _mbg_swab32( &(_p)->features );                  \
  _mbg_swab_fixed_freq_info( &(_p)->fixed_freq );  \
  _mbg_swab16( &(_p)->flags );                     \
}


/**
 * Valid codes for RECEIVER_INFO.model_code:
 */
enum
{
  GPS_MODEL_UNKNOWN,
  GPS_MODEL_GPS166,
  GPS_MODEL_GPS167,
  GPS_MODEL_GPS167SV,
  GPS_MODEL_GPS167PC,
  GPS_MODEL_GPS167PCI,
  GPS_MODEL_GPS163,
  GPS_MODEL_GPS168PCI,
  GPS_MODEL_GPS161,
  GPS_MODEL_GPS169PCI,
  GPS_MODEL_TCR167PCI,
  GPS_MODEL_GPS164,
  GPS_MODEL_GPS170PCI,
  GPS_MODEL_PZF511,
  GPS_MODEL_GPS170,
  GPS_MODEL_TCR511,
  GPS_MODEL_AM511,
  GPS_MODEL_MSF511,
  GPS_MODEL_GRC170,
  GPS_MODEL_GPS170PEX,
  GPS_MODEL_GPS162,
  GPS_MODEL_PTP270PEX,
  GPS_MODEL_FRC511PEX,
  GPS_MODEL_GEN170,
  GPS_MODEL_TCR170PEX,
  GPS_MODEL_WWVB511,
  GPS_MODEL_MGR170,
  GPS_MODEL_JJY511,
  GPS_MODEL_PZF600,
  GPS_MODEL_TCR600,
  GPS_MODEL_GPS180,
  GPS_MODEL_GLN170,
  GPS_MODEL_GPS180PEX,
  GPS_MODEL_TCR180PEX,
  GPS_MODEL_PZF180PEX,
  GPS_MODEL_MGR180,
  GPS_MODEL_MSF600,
  GPS_MODEL_WWVB600,
  GPS_MODEL_JJY600,
  GPS_MODEL_GPS180HS,
  GPS_MODEL_GPS180AMC,
  GPS_MODEL_ESI180,
  GPS_MODEL_CPE180,
  N_GPS_MODEL
  /* If new model codes are added then care must be taken
   * to update the associated string initializers below
   * accordingly, and to check whether the classification macros
   * also cover the new model names. */
};




/*
 * String initializers for each of the GPS
 * receiver models enum'ed above:
 */
#define GPS_MODEL_NAME_UNKNOWN   "(unknown)"
#define GPS_MODEL_NAME_GPS166    "GPS166"
#define GPS_MODEL_NAME_GPS167    "GPS167"
#define GPS_MODEL_NAME_GPS167SV  "GPS167SV"
#define GPS_MODEL_NAME_GPS167PC  "GPS167PC"
#define GPS_MODEL_NAME_GPS167PCI "GPS167PCI"
#define GPS_MODEL_NAME_GPS163    "GPS163"
#define GPS_MODEL_NAME_GPS168PCI "GPS168PCI"
#define GPS_MODEL_NAME_GPS161    "GPS161"
#define GPS_MODEL_NAME_GPS169PCI "GPS169PCI"
#define GPS_MODEL_NAME_TCR167PCI "TCR167PCI"
#define GPS_MODEL_NAME_GPS164    "GPS164"
#define GPS_MODEL_NAME_GPS170PCI "GPS170PCI"
#define GPS_MODEL_NAME_PZF511    "PZF511"
#define GPS_MODEL_NAME_GPS170    "GPS170"
#define GPS_MODEL_NAME_TCR511    "TCR511"
#define GPS_MODEL_NAME_AM511     "AM511"
#define GPS_MODEL_NAME_MSF511    "MSF511"
#define GPS_MODEL_NAME_GRC170    "GRC170"
#define GPS_MODEL_NAME_GPS170PEX "GPS170PEX"
#define GPS_MODEL_NAME_GPS162    "GPS162"
#define GPS_MODEL_NAME_PTP270PEX "PTP270PEX"
#define GPS_MODEL_NAME_FRC511PEX "FRC511PEX"
#define GPS_MODEL_NAME_GEN170    "GEN170"
#define GPS_MODEL_NAME_TCR170PEX "TCR170PEX"
#define GPS_MODEL_NAME_WWVB511   "WWVB511"
#define GPS_MODEL_NAME_MGR170    "MGR170"
#define GPS_MODEL_NAME_JJY511    "JJY511"
#define GPS_MODEL_NAME_PZF600    "PZF600"
#define GPS_MODEL_NAME_TCR600    "TCR600"
#define GPS_MODEL_NAME_GPS180    "GPS180"
#define GPS_MODEL_NAME_GLN170    "GLN170"
#define GPS_MODEL_NAME_GPS180PEX "GPS180PEX"
#define GPS_MODEL_NAME_TCR180PEX "TCR180PEX"
#define GPS_MODEL_NAME_PZF180PEX "PZF180PEX"
#define GPS_MODEL_NAME_MGR180    "MGR180"
#define GPS_MODEL_NAME_MSF600    "MSF600"
#define GPS_MODEL_NAME_WWVB600   "WWVB600"
#define GPS_MODEL_NAME_JJY600    "JJY600"
#define GPS_MODEL_NAME_GPS180HS  "GPS180HS"
#define GPS_MODEL_NAME_GPS180AMC "GPS180AMC"
#define GPS_MODEL_NAME_ESI180    "ESI180"
#define GPS_MODEL_NAME_CPE180    "CPE180"

/*
 * The definition below can be used to initialize
 * an array of N_GPS_MODEL type name strings.
 * Including the trailing 0, each name must not
 * exceed GPS_ID_STR_SIZE chars.
 */
#define DEFAULT_GPS_MODEL_NAMES \
{                               \
  GPS_MODEL_NAME_UNKNOWN,       \
  GPS_MODEL_NAME_GPS166,        \
  GPS_MODEL_NAME_GPS167,        \
  GPS_MODEL_NAME_GPS167SV,      \
  GPS_MODEL_NAME_GPS167PC,      \
  GPS_MODEL_NAME_GPS167PCI,     \
  GPS_MODEL_NAME_GPS163,        \
  GPS_MODEL_NAME_GPS168PCI,     \
  GPS_MODEL_NAME_GPS161,        \
  GPS_MODEL_NAME_GPS169PCI,     \
  GPS_MODEL_NAME_TCR167PCI,     \
  GPS_MODEL_NAME_GPS164,        \
  GPS_MODEL_NAME_GPS170PCI,     \
  GPS_MODEL_NAME_PZF511,        \
  GPS_MODEL_NAME_GPS170,        \
  GPS_MODEL_NAME_TCR511,        \
  GPS_MODEL_NAME_AM511,         \
  GPS_MODEL_NAME_MSF511,        \
  GPS_MODEL_NAME_GRC170,        \
  GPS_MODEL_NAME_GPS170PEX,     \
  GPS_MODEL_NAME_GPS162,        \
  GPS_MODEL_NAME_PTP270PEX,     \
  GPS_MODEL_NAME_FRC511PEX,     \
  GPS_MODEL_NAME_GEN170,        \
  GPS_MODEL_NAME_TCR170PEX,     \
  GPS_MODEL_NAME_WWVB511,       \
  GPS_MODEL_NAME_MGR170,        \
  GPS_MODEL_NAME_JJY511,        \
  GPS_MODEL_NAME_PZF600,        \
  GPS_MODEL_NAME_TCR600,        \
  GPS_MODEL_NAME_GPS180,        \
  GPS_MODEL_NAME_GLN170,        \
  GPS_MODEL_NAME_GPS180PEX,     \
  GPS_MODEL_NAME_TCR180PEX,     \
  GPS_MODEL_NAME_PZF180PEX,     \
  GPS_MODEL_NAME_MGR180,        \
  GPS_MODEL_NAME_MSF600,        \
  GPS_MODEL_NAME_WWVB600,       \
  GPS_MODEL_NAME_JJY600,        \
  GPS_MODEL_NAME_GPS180HS,      \
  GPS_MODEL_NAME_GPS180AMC,     \
  GPS_MODEL_NAME_ESI180,        \
  GPS_MODEL_NAME_CPE180         \
}


/*
 * The macros below can be used to classify a receiver,
 * e.g. depending on the time source and/or depending on
 * whether it's a plug-in card or an external device.
 */

#define _mbg_rcvr_is_plug_in( _p_ri )      \
  ( strstr( (_p_ri)->model_name, "PC" ) || \
  ( strstr( (_p_ri)->model_name, "PEX" ) )

#define _mbg_rcvr_is_gps( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "GPS" ) || \
  ( strstr( (_p_ri)->model_name, "MGR" ) )

#define _mbg_rcvr_is_mobile_gps( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "MGR" ) )

#define _mbg_rcvr_is_gps_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_gps( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )

#define _mbg_rcvr_is_irig( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "TCR" ) )

#define _mbg_rcvr_is_irig_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_irig( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )

#define _mbg_rcvr_is_dcf77_am( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "AM" ) )

#define _mbg_rcvr_is_dcf77_am_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_dcf77_am( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )

#define _mbg_rcvr_is_dcf77_pzf( _p_ri )  \
  ( strstr( (_p_ri)->model_name, "PZF" ) )

#define _mbg_rcvr_is_dcf77_pzf_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_dcf77_pzf( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )

#define _mbg_rcvr_is_any_dcf77( _p_ri )   \
  ( _mbg_rcvr_is_dcf77_am( _p_ri ) ||     \
    _mbg_rcvr_is_dcf77_pzf( _p_ri ) )

#define _mbg_rcvr_is_any_dcf77_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_any_dcf77( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )

#define _mbg_rcvr_is_msf( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "MSF" ) )

#define _mbg_rcvr_is_jjy( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "JJY" ) )

#define _mbg_rcvr_is_msf_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_msf( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )

#define _mbg_rcvr_is_glonass( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "GRC" ) || \
  ( strstr( (_p_ri)->model_name, "GLN" ) )

#define _mbg_rcvr_is_glonass_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_glonass( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )

#define _mbg_rcvr_is_wwvb( _p_ri ) \
  ( strstr( (_p_ri)->model_name, "WWVB" ) )

#define _mbg_rcvr_is_wwvb_plug_in( _p_ri ) \
  ( _mbg_rcvr_is_wwvb( _p_ri ) &&          \
    _mbg_rcvr_is_plug_in( _p_ri ) )


/**
 * The classification codes for oscillators below
 * are used with RECEIVER_INFO.osc_type. New codes
 * must be appended to the enumeration, so the sequence
 * of codes does NOT reflect the order of quality:
 */
enum
{
  GPS_OSC_UNKNOWN,
  GPS_OSC_TCXO_LQ,
  GPS_OSC_TCXO_HQ,
  GPS_OSC_OCXO_LQ,
  GPS_OSC_OCXO_MQ,
  GPS_OSC_OCXO_HQ,
  GPS_OSC_OCXO_XHQ,
  GPS_OSC_RUBIDIUM,
  GPS_OSC_TCXO_MQ,
  GPS_OSC_OCXO_DHQ,
  N_GPS_OSC
};


/*
 * The sequence and number of oscillator names
 * listed below must correspond to the enumeration
 * above:
 */
#define DEFAULT_GPS_OSC_NAMES \
{                             \
  "[unknown]",                \
  "TCXO LQ",                  \
  "TCXO",                     \
  "OCXO LQ",                  \
  "OCXO MQ",                  \
  "OCXO HQ",                  \
  "OCXO XHQ",                 \
  "RUBIDIUM",                 \
  "TCXO MQ",                  \
  "OCXO DHQ"                  \
}


/*
 * The initializer below can be used to initialize
 * an array (e.g. "int osc_quality_idx[N_GPS_OSC]")
 * which allows to display the oscillator types
 * ordered by quality:
 */
#define DEFAULT_GPS_OSC_QUALITY_IDX \
{                                   \
  GPS_OSC_UNKNOWN,                  \
  GPS_OSC_TCXO_LQ,                  \
  GPS_OSC_TCXO_MQ,                  \
  GPS_OSC_TCXO_HQ,                  \
  GPS_OSC_OCXO_LQ,                  \
  GPS_OSC_OCXO_MQ,                  \
  GPS_OSC_OCXO_HQ,                  \
  GPS_OSC_OCXO_DHQ,                 \
  GPS_OSC_OCXO_XHQ,                 \
  GPS_OSC_RUBIDIUM                  \
}



/*
 * Codes to be used with RECEIVER_INFO.osc_flags
 * are not yet used/required, so they are reserved
 * for future use.
 */


/**
 * The codes below enumerate some features which may be
 * supported by a given clock, or not.
 */
enum
{
  GPS_FEAT_PPS,                 /**< has pulse per second output */
  GPS_FEAT_PPM,                 /**< has pulse per minute output */
  GPS_FEAT_SYNTH,               /**< has programmable synthesizer output */
  GPS_FEAT_DCFMARKS,            /**< has DCF77 compatible time mark output */
  GPS_FEAT_IRIG_TX,             /**< has on-board IRIG output */
  GPS_FEAT_IRIG_RX,             /**< has on-board IRIG input */
  GPS_FEAT_LAN_IP4,             /**< has LAN IPv4 interface */
  GPS_FEAT_MULTI_REF,           /**< has multiple input sources with priorities */

  GPS_FEAT_RCV_TIMEOUT,         /**< timeout after GPS reception has stopped */
  GPS_FEAT_IGNORE_LOCK,         /**< supports "ignore lock", MBG_OPT_BIT_EMU_SYNC can be set alternatively */
  GPS_FEAT_5_MHZ,               /**< output 5 MHz rather than 100 kHz */
  GPS_FEAT_XMULTI_REF,          /**< has extended multiple input source configuration */
  GPS_FEAT_OPT_SETTINGS,        /**< supports MBG_OPT_SETTINGS */
  GPS_FEAT_TIME_SCALE,          /**< supports configurable time scale (UTC, TAI, GPS, ...) */
  GPS_FEAT_IRIG_CTRL_BITS,      /**< supports IRIG control bits */
  GPS_FEAT_PTP,                 /**< has PTP support */

  GPS_FEAT_NAV_ENGINE_SETTINGS, /**< supports navigation engine configuration */
  GPS_FEAT_RAW_IRIG_DATA,       /**< supports reading raw IRIG input data */
  GPS_FEAT_RAW_IRIG_TIME,       /**< supports reading decoded IRIG time */
  GPS_FEAT_PTP_UNICAST,         /**< has PTP Unicast support */
  GPS_FEAT_GPIO,                /**< has general purpose in/outputs */
  GPS_FEAT_XMRS_MULT_INSTC,     /**< multiple XMRS instances of the same ref type supported, @see XMRSF_BIT_MULT_INSTC_SUPP */
  GPS_FEAT_10MHZ_DISBD,         /**< 10 MHz output is always disabled */
  GPS_FEAT_EVT_LOG,             /**< Event logging supported */

  N_GPS_FEATURE                 /**< the number of valid features */
};


#define DEFAULT_GPS_FEATURE_NAMES \
{                                 \
  "Pulse Per Second",             \
  "Pulse Per Minute",             \
  "Programmable Synth.",          \
  "DCF77 Time Marks",             \
  "IRIG Out",                     \
  "IRIG In",                      \
  "IPv4 LAN Interface",           \
  "Multiple Ref. Sources",        \
  "Receive Timeout",              \
  "Ignore Lock",                  \
  "5 MHz Output",                 \
  "Ext. Multiple Ref. Src. Cfg.", \
  "Optional Settings",            \
  "Configurable Time Scale",      \
  "IRIG Control Bits",            \
  "PTP/IEEE1588",                 \
  "Nav. Engine Settings",         \
  "Raw IRIG Data",                \
  "Raw IRIG Time",                \
  "PTP/IEEE1588 Unicast",         \
  "General Purpose I/O",          \
  "Multiple XMRS Instances",      \
  "10 MHz Output Disabled",       \
  "Event Logging"                 \
}


/*
 * Bit masks used with RECEIVER_INFO.features
 * (others are reserved):
 */
#define GPS_HAS_PPS                  ( 1UL << GPS_FEAT_PPS )
#define GPS_HAS_PPM                  ( 1UL << GPS_FEAT_PPM )
#define GPS_HAS_SYNTH                ( 1UL << GPS_FEAT_SYNTH )
#define GPS_HAS_DCFMARKS             ( 1UL << GPS_FEAT_DCFMARKS )
#define GPS_HAS_IRIG_TX              ( 1UL << GPS_FEAT_IRIG_TX )
#define GPS_HAS_IRIG_RX              ( 1UL << GPS_FEAT_IRIG_RX )
#define GPS_HAS_LAN_IP4              ( 1UL << GPS_FEAT_LAN_IP4 )
#define GPS_HAS_MULTI_REF            ( 1UL << GPS_FEAT_MULTI_REF )
#define GPS_HAS_RCV_TIMEOUT          ( 1UL << GPS_FEAT_RCV_TIMEOUT )
#define GPS_HAS_IGNORE_LOCK          ( 1UL << GPS_FEAT_IGNORE_LOCK )
#define GPS_HAS_5_MHZ                ( 1UL << GPS_FEAT_5_MHZ )
#define GPS_HAS_XMULTI_REF           ( 1UL << GPS_FEAT_XMULTI_REF )
#define GPS_HAS_OPT_SETTINGS         ( 1UL << GPS_FEAT_OPT_SETTINGS )
#define GPS_HAS_TIME_SCALE           ( 1UL << GPS_FEAT_TIME_SCALE )
#define GPS_HAS_IRIG_CTRL_BITS       ( 1UL << GPS_FEAT_IRIG_CTRL_BITS )
#define GPS_HAS_PTP                  ( 1UL << GPS_FEAT_PTP )
#define GPS_HAS_NAV_ENGINE_SETTINGS  ( 1UL << GPS_FEAT_NAV_ENGINE_SETTINGS )
#define GPS_HAS_RAW_IRIG_DATA        ( 1UL << GPS_FEAT_RAW_IRIG_DATA )
#define GPS_HAS_RAW_IRIG_TIME        ( 1UL << GPS_FEAT_RAW_IRIG_TIME )
#define GPS_HAS_PTP_UNICAST          ( 1UL << GPS_FEAT_PTP_UNICAST )
#define GPS_HAS_GPIO                 ( 1UL << GPS_FEAT_GPIO )
#define GPS_HAS_XMRS_MULT_INSTC      ( 1UL << GPS_FEAT_XMRS_MULT_INSTC )
#define GPS_HAS_10MHZ_DISBD          ( 1UL << GPS_FEAT_10MHZ_DISBD )
#define GPS_HAS_EVT_LOG              ( 1UL << GPS_FEAT_EVT_LOG )

#define GPS_HAS_REF_OFFS             GPS_HAS_IRIG_RX


/*
 * The features below are supported by default by older
 * C166 based GPS receivers:
 */
#define DEFAULT_GPS_FEATURES_C166 \
{                                 \
  GPS_HAS_PPS |                   \
  GPS_HAS_PPM |                   \
  GPS_HAS_SYNTH |                 \
  GPS_HAS_DCFMARKS                \
}


/*
 * Codes to be used with RECEIVER_INFO::flags:
 */
#define GPS_OSC_CFG_SUPP    0x0001  // GPS_OSC_CFG supported
#define GPS_IRIG_FO_IN      0x0002  // IRIG input via fiber optics
#define GPS_HAS_FPGA        0x0004  // device provides on-board FPGA



/*
 * If the GPS_HAS_FPGA flag is set in RECEIVER_INFO::flags then the card
 * provides an FPGA and the following information about the FPGA is available:
 */
#define FPGA_NAME_LEN    31                     // max name length
#define FPGA_NAME_SIZE   ( FPGA_NAME_LEN + 1 )  // size including trailing 0

#define FPGA_INFO_SIZE   128

typedef union
{
  struct
  {
    CSUM csum;
    uint32_t fsize;
    #if _IS_MBG_FIRMWARE
      uint32_t start_addr;
    #else
      uint8_t *start_addr;
    #endif
    char name[FPGA_NAME_SIZE];
  } hdr;

  char b[FPGA_INFO_SIZE];

} FPGA_INFO;



/*
 * The definitions below are used to specify where a FPGA image is located
 * in the flash memory:
 */
typedef struct
{
  CSUM csum;
  uint16_t fpga_start_seg;   // Number of the 4k block where an FPGA image is located
} FPGA_START_INFO;

#define DEFAULT_FPGA_START_SEG     0x60

#define DEFAULT_FPGA_START_INFO    \
{                                  \
  0x1234 + DEFAULT_FPGA_START_SEG, \
  DEFAULT_FPGA_START_SEG           \
}



/**
 Date and time referred to the linear time scale defined by GPS.
 GPS time is defined by the number of weeks since midnight from
 January 5, 1980 to January 6, 1980 plus the number of seconds of
 the current week plus fractions of a second. GPS time differs from
 UTC because UTC is corrected with leap seconds while GPS time scale
 is continuous.
*/
typedef struct
{
  uint16_t wn;     /**< the week number since GPS has been installed */
  uint32_t sec;    /**< the second of that week */
  uint32_t tick;   /**< fractions of a second; scale: 1/GPS_TICKS_PER_SEC */
} T_GPS;

#define _mbg_swab_t_gps( _p )  \
{                              \
  _mbg_swab16( &(_p)->wn );    \
  _mbg_swab32( &(_p)->sec );   \
  _mbg_swab32( &(_p)->tick );  \
}


/**
  Local date and time computed from GPS time. The current number
  of leap seconds have to be added to get UTC from GPS time.
  Additional corrections could have been made according to the
  time zone/daylight saving parameters (TZDL, see below) defined
  by the user. The status field can be checked to see which corrections
  have been applied.
*/
typedef struct
{
  int16_t year;           /**< year number, 0..9999 */
  int8_t month;           /**< month, 1..12 */
  int8_t mday;            /**< day of month, 1..31 */
  int16_t yday;           /**< day of year, 1..366 */
  int8_t wday;            /**< day of week, 0..6 == Sun..Sat */
  int8_t hour;            /**< hours, 0..23 */
  int8_t min;             /**< minutes, 0..59 */
  int8_t sec;             /**< seconds, 0..59 */
  int32_t frac;           /**< fractions of a second; scale: 1/GPS_TICKS_PER_SEC */
  int32_t offs_from_utc;  /**< local time's offset from UTC */
  uint16_t status;        /**< status flags */
} TM_GPS;

#define _mbg_swab_tm_gps( _p )          \
{                                       \
  _mbg_swab16( &(_p)->year );           \
  _mbg_swab16( &(_p)->yday );           \
  _mbg_swab32( &(_p)->frac );           \
  _mbg_swab32( &(_p)->offs_from_utc );  \
  _mbg_swab16( &(_p)->status );         \
}


/* status flag bits used with conversion from GPS time to local time */

enum
{
  TM_BIT_UTC,        /* UTC correction has been made */
  TM_BIT_LOCAL,      /* UTC has been converted to local time */
  TM_BIT_DL_ANN,     /* state of daylight saving is going to change */
  TM_BIT_DL_ENB,     /* daylight saving is enabled */
  TM_BIT_LS_ANN,     /* leap second will be inserted */
  TM_BIT_LS_ENB,     /* current second is leap second */
  TM_BIT_LS_ANN_NEG, /* set in addition to TM_LS_ANN if leap sec negative */
  TM_BIT_INVT,       /* invalid time, e.g. if RTC battery empty */

  TM_BIT_EXT_SYNC,       /* sync'd externally */
  TM_BIT_HOLDOVER,       /* holdover mode after previous sync. */
  TM_BIT_ANT_SHORT,      /* antenna cable short circuited */
  TM_BIT_NO_WARM,        /* OCXO has not warmed up */
  TM_BIT_ANT_DISCONN,    /* antenna currently disconnected */
  TM_BIT_SYN_FLAG,       /* TIME_SYN output is low */
  TM_BIT_NO_SYNC,        /* time sync actually not verified */
  TM_BIT_NO_POS          /* position actually not verified, LOCK LED off */
};

// Type of an extended TM status which is mainly used by the firmware.
typedef uint32_t TM_STATUS_EXT;    // extended status, mainly used by the firmware

// The lower 16 bits of the TM_STATUS_X type correspond to those defined above,
// and the upper bits are defined below:
enum
{
  TM_BIT_SCALE_GPS = 16,
  TM_BIT_SCALE_TAI
  // the remaining bits are reserved
};


/* bit masks corresponding to the flag bits above */

#define TM_UTC          ( 1UL << TM_BIT_UTC )
#define TM_LOCAL        ( 1UL << TM_BIT_LOCAL )
#define TM_DL_ANN       ( 1UL << TM_BIT_DL_ANN )
#define TM_DL_ENB       ( 1UL << TM_BIT_DL_ENB )
#define TM_LS_ANN       ( 1UL << TM_BIT_LS_ANN )
#define TM_LS_ENB       ( 1UL << TM_BIT_LS_ENB )
#define TM_LS_ANN_NEG   ( 1UL << TM_BIT_LS_ANN_NEG )
#define TM_INVT         ( 1UL << TM_BIT_INVT )

#define TM_EXT_SYNC     ( 1UL << TM_BIT_EXT_SYNC )
#define TM_HOLDOVER     ( 1UL << TM_BIT_HOLDOVER )
#define TM_ANT_SHORT    ( 1UL << TM_BIT_ANT_SHORT )
#define TM_NO_WARM      ( 1UL << TM_BIT_NO_WARM )
#define TM_ANT_DISCONN  ( 1UL << TM_BIT_ANT_DISCONN )
#define TM_SYN_FLAG     ( 1UL << TM_BIT_SYN_FLAG )
#define TM_NO_SYNC      ( 1UL << TM_BIT_NO_SYNC )
#define TM_NO_POS       ( 1UL << TM_BIT_NO_POS )

// The following bits are only used with the TM_STATUS_X type:
#define TM_SCALE_GPS    ( 1UL << TM_BIT_SCALE_GPS )
#define TM_SCALE_TAI    ( 1UL << TM_BIT_SCALE_TAI )

#define TM_MSK_TIME_VALID  ( TM_UTC | TM_SCALE_GPS | TM_SCALE_TAI )

/**
 * @brief A structure used to transmit information on date and time
 */
typedef struct
{
  int16_t channel;      /**< -1: the current time; 0, 1: capture 0, 1 */
  T_GPS t;              /**< time in GPS format */
  TM_GPS tm;            /**< that time converted to local time */
} TTM;

#define _mbg_swab_ttm( _p )       \
{                                 \
  _mbg_swab16( &(_p)->channel );  \
  _mbg_swab_t_gps( &(_p)->t );    \
  _mbg_swab_tm_gps( &(_p)->tm );  \
}



typedef struct
{
  int32_t nano_secs;    // [nanoseconds]
  int32_t secs;         // [seconds]
} NANO_TIME;

#define _mbg_swab_nano_time( _p )   \
{                                   \
  _mbg_swab32( &(_p)->nano_secs );  \
  _mbg_swab32( &(_p)->secs );       \
}

// The macro below checks if a NANO_TIME value is negative.
#define _nano_time_negative( _nt ) \
  ( ( (_nt)->secs < 0 ) || ( (_nt)->nano_secs < 0 ) )



/* Two types of variables used to store a position. Type XYZ is */
/* used with a position in earth centered, earth fixed (ECEF) */
/* coordinates whereas type LLA holds such a position converted */
/* to geographic coordinates as defined by WGS84 (World Geodetic */
/* System from 1984). */

#ifndef _XYZ_DEFINED
  /* sequence and number of components of a cartesian position */
  enum { XP, YP, ZP, N_XYZ };

  /** @brief An array holding a cartesian position */
  typedef double XYZ[N_XYZ];      /**< values are in [m] */

  #define _XYZ_DEFINED
#endif

#define _mbg_swab_xyz( _p )  _mbg_swab_doubles( _p, N_XYZ )


#ifndef _LLA_DEFINED
  /* sequence and number of components of a geographic position */
  enum { LAT, LON, ALT, N_LLA };  /* latitude, longitude, altitude */

  /** @brief An array holding a geographic position */
  typedef double LLA[N_LLA];      /**< lon, lat in [rad], alt in [m] */

  #define _LLA_DEFINED
#endif

#define _mbg_swab_lla( _p )  _mbg_swab_doubles( _p, N_LLA )


/**
 @defgroup group_synth Synthesizer parameters

 Synthesizer frequency is expressed as a
 four digit decimal number (freq) to be multiplied by 0.1 Hz and an
 base 10 exponent (range). If the effective frequency is less than
 10 kHz its phase is synchronized corresponding to the variable phase.
 Phase may be in a range from -360 deg to +360 deg with a resolution
 of 0.1 deg, so the resulting numbers to be stored are in a range of
 -3600 to +3600.

 Example:<br>
 Assume the value of freq is 2345 (decimal) and the value of phase is 900.
 If range == 0 the effective frequency is 234.5 Hz with a phase of +90 deg.
 If range == 1 the synthesizer will generate a 2345 Hz output frequency
 and so on.

 Limitations:<br>
 If freq == 0 the synthesizer is disabled. If range == 0 the least
 significant digit of freq is limited to 0, 3, 5 or 6. The resulting
 frequency is shown in the examples below:
    - freq == 1230  -->  123.0 Hz
    - freq == 1233  -->  123 1/3 Hz (real 1/3 Hz, NOT 123.3 Hz)
    - freq == 1235  -->  123.5 Hz
    - freq == 1236  -->  123 2/3 Hz (real 2/3 Hz, NOT 123.6 Hz)

 If range == MAX_RANGE the value of freq must not exceed 1000, so the
 output frequency is limited to 10 MHz.
 @{
*/

#define N_SYNTH_FREQ_DIGIT  4    /**< number of digits to edit */
#define MAX_SYNTH_FREQ   1000    /**< if range == MAX_SYNTH_RANGE */

#define MIN_SYNTH_RANGE     0
#define MAX_SYNTH_RANGE     5
#define N_SYNTH_RANGE       ( MAX_SYNTH_RANGE - MIN_SYNTH_RANGE + 1 )

#define N_SYNTH_PHASE_DIGIT     4
#define MAX_SYNTH_PHASE  3600


#define MAX_SYNTH_FREQ_EDIT  9999  /**< max sequence of digits when editing */

/** @brief The maximum frequency that can be configured for the synthesizer */
#define MAX_SYNTH_FREQ_VAL   10000000UL     /**< 10 MHz */
/*   == MAX_SYNTH_FREQ * 10^(MAX_SYNTH_RANGE-1) */

/** @brief The synthesizer's phase is only be synchronized if the frequency is below this limit */
#define SYNTH_PHASE_SYNC_LIMIT   10000UL    /**< 10 kHz */

/**
  the position of the decimal point if the frequency is
  printed as 4 digit value */
#define _synth_dp_pos_from_range( _r ) \
  ( ( ( N_SYNTH_RANGE - (_r) ) % ( N_SYNTH_FREQ_DIGIT - 1 ) ) + 1 )

/**
  An initializer for commonly displayed synthesizer frequency units
  (N_SYNTH_RANGE strings) */
#define DEFAULT_FREQ_RANGES \
{                           \
  "Hz",                     \
  "kHz",                    \
  "kHz",                    \
  "kHz",                    \
  "MHz",                    \
  "MHz",                    \
}



typedef struct
{
  int16_t freq;    /**< four digits used; scale: 0.1; e.g. 1234 -> 123.4 Hz */
  int16_t range;   /**< scale factor for freq; 0..MAX_SYNTH_RANGE */
  int16_t phase;   /**< -MAX_SYNTH_PHASE..+MAX_SYNTH_PHASE; >0 -> pulses later */
} SYNTH;

#define _mbg_swab_synth( _p )   \
{                               \
  _mbg_swab16( &(_p)->freq );   \
  _mbg_swab16( &(_p)->range );  \
  _mbg_swab16( &(_p)->phase );  \
}


/**
  The definitions below can be used to query the
  current synthesizer state.
 */
enum
{
  SYNTH_DISABLED,   /**< disbled by cfg, i.e. freq == 0.0 */
  SYNTH_OFF,        /**< not enabled after power-up */
  SYNTH_FREE,       /**< enabled, but not synchronized */
  SYNTH_DRIFTING,   /**< has initially been sync'd, but now running free */
  SYNTH_SYNC,       /**< fully synchronized */
  N_SYNTH_STATE     /**< the number of known states */
};

typedef struct
{
  uint8_t state;     /**< state code as enumerated above */
  uint8_t flags;     /**< reserved, currently always 0 */
} SYNTH_STATE;

#define _mbg_swab_synth_state( _p )  _nop_macro_fnc()

#define SYNTH_FLAG_PHASE_IGNORED  0x01

/** @} group_synth */

/**
  @defgroup group_tzdl Time zone/daylight saving parameters

  Example: <br>
  For automatic daylight saving enable/disable in Central Europe,
  the variables are to be set as shown below: <br>
    - offs = 3600L           one hour from UTC
    - offs_dl = 3600L        one additional hour if daylight saving enabled
    - tm_on = first Sunday from March 25, 02:00:00h ( year |= DL_AUTO_FLAG )
    - tm_off = first Sunday from October 25, 03:00:00h ( year |= DL_AUTO_FLAG )
    - name[0] == "CET  "     name if daylight saving not enabled
    - name[1] == "CEST "     name if daylight saving is enabled
  @{
*/

/** the name of a time zone, 5 characters plus trailing zero */
typedef char TZ_NAME[6];

typedef struct
{
  int32_t offs;      /**< offset from UTC to local time [sec] */
  int32_t offs_dl;   /**< additional offset if daylight saving enabled [sec] */
  TM_GPS tm_on;      /**< date/time when daylight saving starts */
  TM_GPS tm_off;     /**< date/time when daylight saving ends */
  TZ_NAME name[2];   /**< names without and with daylight saving enabled */
} TZDL;

#define _mbg_swab_tzdl( _p )          \
{                                     \
  _mbg_swab32( &(_p)->offs );         \
  _mbg_swab32( &(_p)->offs_dl );      \
  _mbg_swab_tm_gps( &(_p)->tm_on );   \
  _mbg_swab_tm_gps( &(_p)->tm_off );  \
}


/**
  If the year in tzdl.tm_on and tzdl.tm_off is or'ed with that constant,
  the receiver automatically generates daylight saving year by year.
 */
#define DL_AUTO_FLAG  0x8000



// Below there are some initializers for commonly used TZDL configurations:

#define DEFAULT_TZDL_AUTO_YEAR   ( 2007 | DL_AUTO_FLAG )

#define DEFAULt_TZDL_OFFS_DL     3600L  /**< usually DST is +1 hour */


/**
  The symbol below can be used to initialize both the tm_on
  and tm_off fields for time zones which do not switch to DST:
 */
#define DEFAULT_TZDL_TM_ON_OFF_NO_DST \
  { DEFAULT_TZDL_AUTO_YEAR, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 }


// Settings used with UTC:

#define TZ_INFO_UTC  "UTC (Universal Time, Coordinated)"

#define DEFAULT_TZDL_NAMES_UTC    { "UTC  ", "UTC  " }

#define DEFAULT_TZDL_UTC                        \
{                                               \
  0L,                             /**< offs */    \
  0L,                             /**< offs_dl */ \
  DEFAULT_TZDL_TM_ON_OFF_NO_DST,  /**< tm_on */   \
  DEFAULT_TZDL_TM_ON_OFF_NO_DST,  /**< tm_off */  \
  DEFAULT_TZDL_NAMES_UTC          /**< name[] */  \
}


/**
  The symbols below specify beginning and end of DST for
  Central Europe, as constituted by the European Parliament:
  */

#define DEFAULT_TZDL_TM_ON_CET_CEST \
  { DEFAULT_TZDL_AUTO_YEAR, 3, 25, 0, 0, 2, 0, 0, 0L, 0L, 0 }

#define DEFAULT_TZDL_TM_OFF_CET_CEST \
  { DEFAULT_TZDL_AUTO_YEAR, 10, 25, 0, 0, 3, 0, 0, 0L, 0L, 0 }


// Settings used with Central European Time:

#define TZ_INFO_CET_CEST_EN  "CET/CEST (Central Europe)"
#define TZ_INFO_CET_CEST_DE  "MEZ/MESZ (Mitteleuropa)"

#define DEFAULT_TZDL_NAMES_CET_CEST_EN  { "CET  ", "CEST " }
#define DEFAULT_TZDL_NAMES_CET_CEST_DE  { "MEZ  ", "MESZ " }

#define DEFAULT_TZDL_OFFS_CET  3600L

#define DEFAULT_TZDL_CET_CEST_EN                \
{                                               \
  DEFAULT_TZDL_OFFS_CET,          /**< offs */    \
  DEFAULt_TZDL_OFFS_DL,           /**< offs_dl */ \
  DEFAULT_TZDL_TM_ON_CET_CEST,    /**< tm_on */   \
  DEFAULT_TZDL_TM_OFF_CET_CEST,   /**< tm_off */  \
  DEFAULT_TZDL_NAMES_CET_CEST_EN  /**< name[] */  \
}

#define DEFAULT_TZDL_CET_CEST_DE                \
{                                               \
  DEFAULT_TZDL_OFFS_CET,          /**< offs */    \
  DEFAULt_TZDL_OFFS_DL,           /**< offs_dl */ \
  DEFAULT_TZDL_TM_ON_CET_CEST,    /**< tm_on */   \
  DEFAULT_TZDL_TM_OFF_CET_CEST,   /**< tm_off */  \
  DEFAULT_TZDL_NAMES_CET_CEST_DE  /**< name[] */  \
}


// The symbols below specify beginning and end of DST for
// Easter Europe, as constituted by the European Parliament:

#define DEFAULT_TZDL_TM_ON_EET_EEST \
  { DEFAULT_TZDL_AUTO_YEAR, 3, 25, 0, 0, 3, 0, 0, 0L, 0L, 0 }

#define DEFAULT_TZDL_TM_OFF_EET_EEST \
  { DEFAULT_TZDL_AUTO_YEAR, 10, 25, 0, 0, 4, 0, 0, 0L, 0L, 0 }


// Settings used with Eastern European Time:

#define TZ_INFO_EET_EEST_EN  "EET/EEST (East Europe)"
#define TZ_INFO_EET_EEST_DE  "OEZ/OEST (Osteuropa)"

#define DEFAULT_TZDL_NAMES_EET_EEST_EN  { "EET  ", "EEST " }
#define DEFAULT_TZDL_NAMES_EET_EEST_DE  { "OEZ  ", "OESZ " }

#define DEFAULT_TZDL_OFFS_EET  7200L

#define DEFAULT_TZDL_EET_EEST_EN                \
{                                               \
  DEFAULT_TZDL_OFFS_EET,          /* offs */    \
  DEFAULt_TZDL_OFFS_DL,           /* offs_dl */ \
  DEFAULT_TZDL_TM_ON_EET_EEST,    /* tm_on */   \
  DEFAULT_TZDL_TM_OFF_EET_EEST,   /* tm_off */  \
  DEFAULT_TZDL_NAMES_EET_EEST_EN  /* name[] */  \
}

#define DEFAULT_TZDL_EET_EEST_DE                \
{                                               \
  DEFAULT_TZDL_OFFS_EET,          /* offs */    \
  DEFAULt_TZDL_OFFS_DL,           /* offs_dl */ \
  DEFAULT_TZDL_TM_ON_EET_EEST,    /* tm_on */   \
  DEFAULT_TZDL_TM_OFF_EET_EEST,   /* tm_off */  \
  DEFAULT_TZDL_NAMES_EET_EEST_DE  /* name[] */  \
}

/** @} group_tzdl */

/**
 * The structure below reflects the status of the antenna,
 * the times of last disconnect/reconnect, and the board's
 * clock offset after the disconnection interval.
 */
typedef struct
{
  int16_t status;      /**< current status of antenna */
  TM_GPS tm_disconn;   /**< time of antenna disconnect */
  TM_GPS tm_reconn;    /**< time of antenna reconnect */
  int32_t delta_t;     /**< clock offs. at reconn. time in #GPS_TICKS_PER_SEC */
} ANT_INFO;

#define _mbg_swab_ant_info( _p )          \
{                                         \
  _mbg_swab16( &(_p)->status );           \
  _mbg_swab_tm_gps( &(_p)->tm_disconn );  \
  _mbg_swab_tm_gps( &(_p)->tm_reconn );   \
  _mbg_swab32( &(_p)->delta_t );          \
}


/**
  The status field may be set to one of the values below:
*/
enum
{
  ANT_INVALID,   /**< struct not set yet because ant. has not been disconn. */
  ANT_DISCONN,   /**< ant. now disconn., tm_reconn and delta_t not set */
  ANT_RECONN     /**< ant. has been disconn. and reconn., all fields valid */
};

/* Defines used with ENABLE_FLAGS */

#define EF_OFF            0x00   /**< outputs off until sync'd */

#define EF_SERIAL_BOTH    0x03   /**< both serial ports on */
#define EF_PULSES_BOTH    0x03   /**< both pulses P_SEC and P_MIN on */
#define EF_FREQ_ALL       0x07   /**< all fixed freq. outputs on */
#define EF_SYNTH          0x01   /**< synth. on */

/**
  The structure holds some flags which let
  the corresponding outputs be disabled after power-up until
  the receiver has synchronized (flag == 0x00, the default) or force
  the outputs to be enabled immediately after power-up. The fixed
  frequency output is hard-wired to be enabled immediately after
  power-up, so the code for freq must always be 0x03.
*/
typedef struct
{
  uint16_t serial;   /**< #EF_OFF or #EF_SERIAL_BOTH */
  uint16_t pulses;   /**< #EF_OFF or #EF_PULSES_BOTH */
  uint16_t freq;     /**< always #EF_FREQ_ALL */
  uint16_t synth;    /**< #EF_OFF or #EF_SYNTH */
} ENABLE_FLAGS;

#define _mbg_swab_enable_flags( _p )  \
{                                     \
  _mbg_swab16( &(_p)->serial );       \
  _mbg_swab16( &(_p)->pulses );       \
  _mbg_swab16( &(_p)->freq );         \
  _mbg_swab16( &(_p)->synth );        \
}


/* A struct used to hold the settings of a serial port: */

#ifndef _COM_HS_DEFINED
  /* types of handshake */
  enum { HS_NONE, HS_XONXOFF, HS_RTSCTS, N_COM_HS };
  #define _COM_HS_DEFINED
#endif

#ifndef _COM_PARM_DEFINED
  typedef int32_t BAUD_RATE;

  /* indices used to identify a parameter in the framing string */
  enum { F_DBITS, F_PRTY, F_STBITS };

  typedef struct
  {
    BAUD_RATE baud_rate;  /* e.g. 19200L */
    char framing[4];      /* e.g. "8N1" */
    int16_t handshake;    /* a numeric value, only HS_NONE supported yet */
  } COM_PARM;

  #define _COM_PARM_DEFINED
#endif

#define _mbg_swab_baud_rate( _p )   _mbg_swab32( _p )

#define _mbg_swab_com_parm( _p )            \
{                                           \
  _mbg_swab_baud_rate( &(_p)->baud_rate );  \
  _mbg_swab16( &(_p)->handshake );          \
}


/*
 * Indices of any supported baud rates.
 * Note that not each baud rate must be supported by
 * any clock model and/or port:
 */
enum
{
  MBG_BAUD_RATE_300,
  MBG_BAUD_RATE_600,
  MBG_BAUD_RATE_1200,
  MBG_BAUD_RATE_2400,
  MBG_BAUD_RATE_4800,
  MBG_BAUD_RATE_9600,
  MBG_BAUD_RATE_19200,
  MBG_BAUD_RATE_38400,
  N_MBG_BAUD_RATES       /* the number of supported baud rates */
};

/*
 * An initializer for a table of baud rate values.
 * The values must correspond to the enumeration above.
 */
#define MBG_BAUD_RATES \
{                      \
  300L,                \
  600L,                \
  1200L,               \
  2400L,               \
  4800L,               \
  9600L,               \
  19200L,              \
  38400L               \
}

/*
 * An initializer for a table of baud rate strings.
 * The values must correspond to the enumeration above.
 */
#define MBG_BAUD_STRS \
{                     \
  "300",              \
  "600",              \
  "1200",             \
  "2400",             \
  "4800",             \
  "9600",             \
  "19200",            \
  "38400"             \
}

/*
 * The bit masks below can be used to determine which baud rates
 * are supported by a serial port. This may vary between
 * different ports of the same device since different
 * types of UART are used which must not necessarily support
 * each baud rate:
 */
#define MBG_PORT_HAS_300     ( 1UL << MBG_BAUD_RATE_300 )
#define MBG_PORT_HAS_600     ( 1UL << MBG_BAUD_RATE_600 )
#define MBG_PORT_HAS_1200    ( 1UL << MBG_BAUD_RATE_1200 )
#define MBG_PORT_HAS_2400    ( 1UL << MBG_BAUD_RATE_2400 )
#define MBG_PORT_HAS_4800    ( 1UL << MBG_BAUD_RATE_4800 )
#define MBG_PORT_HAS_9600    ( 1UL << MBG_BAUD_RATE_9600 )
#define MBG_PORT_HAS_19200   ( 1UL << MBG_BAUD_RATE_19200 )
#define MBG_PORT_HAS_38400   ( 1UL << MBG_BAUD_RATE_38400 )


/*
 * Indices of any supported framings.
 * Note that not each framing must be supported by
 * any clock model and/or port:
 */
enum
{
  MBG_FRAMING_7N2,
  MBG_FRAMING_7E1,
  MBG_FRAMING_7E2,
  MBG_FRAMING_8N1,
  MBG_FRAMING_8N2,
  MBG_FRAMING_8E1,
  MBG_FRAMING_7O1,
  MBG_FRAMING_7O2,
  MBG_FRAMING_8O1,
  N_MBG_FRAMINGS       /* the number of supported framings */
};

/*
 * An initializer for a table of framing strings.
 * The values must correspond to the enumeration above.
 */
#define MBG_FRAMING_STRS \
{                        \
  "7N2",                 \
  "7E1",                 \
  "7E2",                 \
  "8N1",                 \
  "8N2",                 \
  "8E1",                 \
  "7O1",                 \
  "7O2",                 \
  "8O1"                  \
}

/*
 * The bit masks below can be used to determine which framings
 * are supported by a serial port. This may vary between
 * different ports of the same device since different
 * types of UART are used which must not necessarily support
 * each framing type:
 */
#define MBG_PORT_HAS_7N2   ( 1UL << MBG_FRAMING_7N2 )
#define MBG_PORT_HAS_7E1   ( 1UL << MBG_FRAMING_7E1 )
#define MBG_PORT_HAS_7E2   ( 1UL << MBG_FRAMING_7E2 )
#define MBG_PORT_HAS_8N1   ( 1UL << MBG_FRAMING_8N1 )
#define MBG_PORT_HAS_8N2   ( 1UL << MBG_FRAMING_8N2 )
#define MBG_PORT_HAS_8E1   ( 1UL << MBG_FRAMING_8E1 )
#define MBG_PORT_HAS_7O1   ( 1UL << MBG_FRAMING_7O1 )
#define MBG_PORT_HAS_7O2   ( 1UL << MBG_FRAMING_7O2 )
#define MBG_PORT_HAS_8O1   ( 1UL << MBG_FRAMING_8O1 )



/*
 * By default, the baud rates and framings below
 * are supported by the UARTs integrated into
 * the C166 microcontroller:
 */
#define DEFAULT_GPS_BAUD_RATES_C166 \
(                                   \
  MBG_PORT_HAS_300   |              \
  MBG_PORT_HAS_600   |              \
  MBG_PORT_HAS_1200  |              \
  MBG_PORT_HAS_2400  |              \
  MBG_PORT_HAS_4800  |              \
  MBG_PORT_HAS_9600  |              \
  MBG_PORT_HAS_19200                \
)

#define DEFAULT_GPS_FRAMINGS_C166   \
(                                   \
  MBG_PORT_HAS_7N2 |                \
  MBG_PORT_HAS_7E1 |                \
  MBG_PORT_HAS_7E2 |                \
  MBG_PORT_HAS_8N1 |                \
  MBG_PORT_HAS_8N2 |                \
  MBG_PORT_HAS_8E1                  \
)


/*
 * By default, the baud rates and framings below
 * are supported by the UARTs integrated into
 * the GP2021 chipset:
 */
#define DEFAULT_GPS_BAUD_RATES_GP2021 \
(                                     \
  MBG_PORT_HAS_300   |                \
  MBG_PORT_HAS_600   |                \
  MBG_PORT_HAS_1200  |                \
  MBG_PORT_HAS_2400  |                \
  MBG_PORT_HAS_4800  |                \
  MBG_PORT_HAS_9600  |                \
  MBG_PORT_HAS_19200                  \
)

#define DEFAULT_GPS_FRAMINGS_GP2021   \
(                                     \
  MBG_PORT_HAS_7N2 |                  \
  MBG_PORT_HAS_7E2 |                  \
  MBG_PORT_HAS_8N1 |                  \
  MBG_PORT_HAS_8E1 |                  \
  MBG_PORT_HAS_8O1                    \
)


/*
 * The structure below is more flexible if different receiver
 * models have different numbers of serial ports, so the old
 * structure PORT_PARM will become obsolete.
 */
typedef struct
{
  COM_PARM parm;        /* speed, framing, etc. */
  uint8_t mode;         /* per second, per minute, etc. */
  uint8_t str_type;     /* type of the output string */
  uint32_t flags;       /* reserved for future use, currently 0 */
} PORT_SETTINGS;

#define _mbg_swab_port_settings( _p )  \
{                                      \
  _mbg_swab_com_parm( &(_p)->parm );   \
  _mbg_swab32( &(_p)->flags );         \
}


/*
 * The definitions below can be used to mark specific fields of a
 * PORT_SETTINGS structure, e.g. when editing build a mask indicating
 * which of the fields have changed or which are not valid.
 */
enum
{
  MBG_PS_BIT_BAUD_RATE_OVR_SW,   /* Baud rate index exceeds num supp by driver SW */
  MBG_PS_BIT_BAUD_RATE_OVR_DEV,  /* Baud rate index exceeds num supp by device */
  MBG_PS_BIT_BAUD_RATE,          /* Baud rate not supp by given port */
  MBG_PS_BIT_FRAMING_OVR_SW,     /* Framing index exceeds num supp by driver SW */
  MBG_PS_BIT_FRAMING_OVR_DEV,    /* Framing index exceeds num supp by device */
  MBG_PS_BIT_FRAMING,            /* Framing not supp by given port */
  MBG_PS_BIT_HS_OVR_SW,          /* Handshake index exceeds num supp by driver SW */
  MBG_PS_BIT_HS,                 /* Handshake mode not supp by given port */
  MBG_PS_BIT_STR_TYPE_OVR_SW,    /* String type index exceeds num supp by driver SW */
  MBG_PS_BIT_STR_TYPE_OVR_DEV,   /* String type index exceeds num supp by device */
  MBG_PS_BIT_STR_TYPE,           /* String type not supp by given port */
  MBG_PS_BIT_STR_MODE_OVR_SW,    /* String mode index exceeds num supp by driver SW */
  MBG_PS_BIT_STR_MODE_OVR_DEV,   /* String mode index exceeds num supp by device */
  MBG_PS_BIT_STR_MODE,           /* String mode not supp by given port and string type */
  MBG_PS_BIT_FLAGS_OVR_SW,       /* Flags not supp by driver SW */
  MBG_PS_BIT_FLAGS,              /* Flags not supp by device */
  N_MBG_PS_BIT
};

#define MBG_PS_MSK_BAUD_RATE_OVR_SW   ( 1UL << MBG_PS_BIT_BAUD_RATE_OVR_SW )
#define MBG_PS_MSK_BAUD_RATE_OVR_DEV  ( 1UL << MBG_PS_BIT_BAUD_RATE_OVR_DEV )
#define MBG_PS_MSK_BAUD_RATE          ( 1UL << MBG_PS_BIT_BAUD_RATE )
#define MBG_PS_MSK_FRAMING_OVR_SW     ( 1UL << MBG_PS_BIT_FRAMING_OVR_SW )
#define MBG_PS_MSK_FRAMING_OVR_DEV    ( 1UL << MBG_PS_BIT_FRAMING_OVR_DEV )
#define MBG_PS_MSK_FRAMING            ( 1UL << MBG_PS_BIT_FRAMING )
#define MBG_PS_MSK_HS_OVR_SW          ( 1UL << MBG_PS_BIT_HS_OVR_SW )
#define MBG_PS_MSK_HS                 ( 1UL << MBG_PS_BIT_HS )
#define MBG_PS_MSK_STR_TYPE_OVR_SW    ( 1UL << MBG_PS_BIT_STR_TYPE_OVR_SW )
#define MBG_PS_MSK_STR_TYPE_OVR_DEV   ( 1UL << MBG_PS_BIT_STR_TYPE_OVR_DEV )
#define MBG_PS_MSK_STR_TYPE           ( 1UL << MBG_PS_BIT_STR_TYPE )
#define MBG_PS_MSK_STR_MODE_OVR_SW    ( 1UL << MBG_PS_BIT_STR_MODE_OVR_SW )
#define MBG_PS_MSK_STR_MODE_OVR_DEV   ( 1UL << MBG_PS_BIT_STR_MODE_OVR_DEV )
#define MBG_PS_MSK_STR_MODE           ( 1UL << MBG_PS_BIT_STR_MODE )
#define MBG_PS_MSK_FLAGS_OVR_SW       ( 1UL << MBG_PS_BIT_FLAGS_OVR_SW )
#define MBG_PS_MSK_FLAGS              ( 1UL << MBG_PS_BIT_FLAGS )



/*
 * The structure below adds an index number to the structure
 * above to allow addressing of several instances:
 */
typedef struct
{
  uint16_t idx;         /* 0..RECEIVER_INFO.n_com_port-1 */
  PORT_SETTINGS port_settings;
} PORT_SETTINGS_IDX;

#define _mbg_swab_port_settings_idx( _p )           \
{                                                   \
  _mbg_swab16( &(_p)->idx );                        \
  _mbg_swab_port_settings( &(_p)->port_settings );  \
}


/*
 * The structure below holds the current settings
 * for a port, plus additional informaton on the
 * port's capabilities. This can be read by setup
 * programs to allow setup of supported features
 * only.
 */
typedef struct
{
  PORT_SETTINGS port_settings;  /* COM port settings as defined above */
  uint32_t supp_baud_rates;  /* bit mask of baud rates supp. by this port */
  uint32_t supp_framings;    /* bit mask of framings supp. by this port */
  uint32_t supp_str_types;   /* bit mask, bit 0 set if str_type[0] supp. */
  uint32_t reserved;         /* reserved for future use, currently 0 */
  uint32_t flags;            /* reserved for future use, currently 0 */
} PORT_INFO;

#define _mbg_swab_port_info( _p )                   \
{                                                   \
  _mbg_swab_port_settings( &(_p)->port_settings );  \
  _mbg_swab32( &(_p)->supp_baud_rates );            \
  _mbg_swab32( &(_p)->supp_framings );              \
  _mbg_swab32( &(_p)->supp_str_types );             \
  _mbg_swab32( &(_p)->reserved );                   \
  _mbg_swab32( &(_p)->flags );                      \
}


/**
 * @brief Flags used with PORT_SETTINGS::flags and PORT_INFO::flags
 */
enum
{
  PORT_FLAG_BIT_PORT_INVISIBLE,   /**< this port is used internally and should not be displayed by config apps */
  N_PORT_FLAGS                    /**< the number of defined bits */
};

#define PORT_FLAG_PORT_INVISIBLE     ( 1UL << PORT_FLAG_BIT_PORT_INVISIBLE )



/*
 * The structure below adds an index number to the structure
 * above to allow addressing of several instances:
 */
typedef struct
{
  uint16_t idx;         /* 0..RECEIVER_INFO.n_com_port-1 */
  PORT_INFO port_info;
} PORT_INFO_IDX;

#define _mbg_swab_port_info_idx( _p )       \
{                                           \
  _mbg_swab16( &(_p)->idx );                \
  _mbg_swab_port_info( &(_p)->port_info );  \
}


/*
 * The structure below keeps information for a given
 * string type, e.g. which modes can be used with that
 * string type:
 */
typedef struct
{
  uint32_t supp_modes;  /* bit mask of modes supp. with this string type */
  char long_name[23];   /* long name of the string format */
  char short_name[11];  /* short name of the string format */
  uint16_t flags;       /* reserved, currently always 0 */
} STR_TYPE_INFO;

#define _mbg_swab_str_type_info( _p )  \
{                                      \
  _mbg_swab32( &(_p)->supp_modes );    \
  _mbg_swab16( &(_p)->flags );         \
}



/*
 * The structure below adds an index number to the structure
 * above to allow addressing of several instances:
 */
typedef struct
{
  uint16_t idx;          /* 0..RECEIVER_INFO.n_str_type-1 */
  STR_TYPE_INFO str_type_info;
} STR_TYPE_INFO_IDX;

#define _mbg_swab_str_type_info_idx( _p )           \
{                                                   \
  _mbg_swab16( &(_p)->idx );                        \
  _mbg_swab_str_type_info( &(_p)->str_type_info );  \
}


/*
 * The codes below define valid modes for time strings,
 * i.e. the condition when a string is being sent
 * via the serial port:
 */
enum
{
  STR_ON_REQ,     /* on request only */
  STR_PER_SEC,    /* automatically if second changes */
  STR_PER_MIN,    /* automatically if minute changes */
  STR_AUTO,       /* automatically if required, e.g. on capture event */
  STR_ON_REQ_SEC, /* if second changes and a request has been received */
  N_STR_MODE      /* the number of valid modes */
};


#define DEFAULT_SHORT_MODE_NAMES \
{                                \
  "'?'",                         \
  "1 sec",                       \
  "1 min",                       \
  "auto",                        \
  "'?' sec"                      \
}


/*
 * Default initializers for English mode string names. Initializers
 * for multi-language strings can be found in pcpslstr.h.
 */
#define ENG_MODE_NAME_STR_ON_REQ       "on request '?' only"
#define ENG_MODE_NAME_STR_PER_SEC      "per second"
#define ENG_MODE_NAME_STR_PER_MIN      "per minute"
#define ENG_MODE_NAME_STR_AUTO         "automatically"
#define ENG_MODE_NAME_STR_ON_REQ_SEC   "sec after request"

#define DEFAULT_ENG_MODE_NAMES   \
{                                \
  ENG_MODE_NAME_STR_ON_REQ,      \
  ENG_MODE_NAME_STR_PER_SEC,     \
  ENG_MODE_NAME_STR_PER_MIN,     \
  ENG_MODE_NAME_STR_AUTO,        \
  ENG_MODE_NAME_STR_ON_REQ_SEC   \
}

/*
 * The definitions below are used to set up bit masks
 * which restrict the modes which can be used with
 * a given string type:
 */
#define MSK_STR_ON_REQ      ( 1UL << STR_ON_REQ )
#define MSK_STR_PER_SEC     ( 1UL << STR_PER_SEC )
#define MSK_STR_PER_MIN     ( 1UL << STR_PER_MIN )
#define MSK_STR_AUTO        ( 1UL << STR_AUTO )
#define MSK_STR_ON_REQ_SEC  ( 1UL << STR_ON_REQ_SEC )


/*
 *  The modes below are supported by most string types:
 */
#define DEFAULT_STR_MODES \
(                         \
  MSK_STR_ON_REQ |        \
  MSK_STR_PER_SEC |       \
  MSK_STR_PER_MIN         \
)


/*
 *  The modes below can be used with the capture string:
 */
#define DEFAULT_STR_MODES_UCAP \
(                              \
  MSK_STR_ON_REQ |             \
  MSK_STR_AUTO                 \
)



/**
 * The number of serial ports which were available
 * with all GPS receiver models:
 */
#define DEFAULT_N_COM   2

/*
 * By default that's also the number of ports
 * currently available:
 */
#ifndef N_COM
  #define N_COM     DEFAULT_N_COM
#endif

/**
 * The structure used to store the modes of both serial ports:<br>
 * <b>(now obsolete)</b>
 */
typedef struct
{
  COM_PARM com[DEFAULT_N_COM];    /**< COM0 and COM1 settings */
  uint8_t mode[DEFAULT_N_COM];    /**< COM0 and COM1 output mode */
} PORT_PARM;

#define _mbg_swab_port_parm( _p )         \
{                                         \
  int i;                                  \
  for ( i = 0; i < DEFAULT_N_COM; i++ )   \
  {                                       \
    _mbg_swab_com_parm( &(_p)->com[i] );  \
    /* no need to swap mode byte */       \
  }                                       \
}


/*
 * The codes below were used with the obsolete
 * PORT_PARM.mode above. They are defined for
 * compatibility with older devices only:
 */
enum
{
  /* STR_ON_REQ,   defined above */
  /* STR_PER_SEC,  defined above */
  /* STR_PER_MIN,  defined above */
  N_STR_MODE_0 = STR_AUTO,   /* COM0 and COM1 */
  STR_UCAP = N_STR_MODE_0,
  STR_UCAP_REQ,
  N_STR_MODE_1               /* COM1 only */
};



/**
  @defgroup group_icode IRIG codes

  The following definitions are used to configure an optional
  on-board IRIG input or output. Which frame types are supported
  by a device depends on the device type, and may eventually
  depend on the device's firmware version.

  All IRIG frames transport the day-of-year number plus the time-of-day,
  and include a control field segment which can transport user defined
  information.

  Some newer IRIG frames are compatible with older frame types but support
  well defined extensions like the year number, local time offset, DST status,
  etc., in the control fields:

 - Supported IRIG signal code types:
  - \b  A002:             1000 bps, DCLS, time-of-year
  - \b  A003:             1000 bps, DCLS, time-of-year, SBS
  - \b  A132:             1000 bps, 10 kHz carrier, time-of-year
  - \b  A133:             1000 bps, 10 kHz carrier, time-of-year, SBS
  - \b  B002:             100 bps, DCLS, time-of-year
  - \b  B003:             100 bps, DCLS, time-of-year, SBS
  - \b  B122:             100 bps, 1 kHz carrier, time-of-year
  - \b  B123:             100 bps, 1 kHz carrier, time-of-year, SBS
  - \b  B006:             100 bps, DCLS, complete date
  - \b  B007:             100 bps, DCLS, complete date, SBS
  - \b  B126:             100 bps, 1 kHz carrier, complete date
  - \b  B127:             100 bps, 1 kHz carrier, complete date, SBS
  - \b  B220/1344:        100 bps, DCLS, manchester encoded, IEEE1344 extensions
  - \b  B222:             100 bps, DCLS, manchester encoded, time-of-year
  - \b  B223:             100 bps, DCLS, manchester encoded, time-of-year, SBS
  - \b  G002:             10 kbps, DCLS, time-of-year
  - \b  G142:             10 kbps, 100 kHz carrier, time-of-year
  - \b  G006:             10 kbps, DCLS, complete date
  - \b  G146:             10 kbps, 100 kHz carrier, complete date
  - \b  AFNOR:            100 bps, 1 kHz carrier, SBS, complete date
  - <b> AFNOR DC:</b>     100 bps, DCLS, SBS, complete date
  - \b  IEEE1344:         100 bps, 1 kHz carrier, time-of-year, SBS, IEEE1344 extensions (B120)
  - <b> IEEE1344 DC:</b>  100 bps, DCLS, time-of-year, SBS, IEEE1344 extensions (B000)
  - \b  C37.118:          like IEEE1344, but UTC offset with reversed sign
  - \b  C37.118 DC:       like IEEE1344 DC, but UTC offset with reversed sign

  -  time-of-year: day-of-year, hours, minutes, seconds
  -  complete date: time-of-year plus year number
  -  SBS: straight binary seconds, second-of-day

  AFNOR codes are based on the french standard AFNOR NF S87-500

  IEEE1344 codes are defined in IEEE standard 1344-1995. The code frame is compatible
  with B002/B122 but provides some well defined extensions in the control field which
  include a quality indicator (time figure of merit, TFOM), year number, DST and leap
  second status, and local time offset from UTC.

  C37.118 codes are defined in IEEE standard C37.118-2005 which includes a revised version
  of the IEEE 1344 standard from 1995. These codes provide the same extensions as IEEE 1344
  but unfortunately define the UTC offset with reversed sign.

  @note There are 3rd party IRIG devices out there which apply the UTC offset as specified
  in C37.118, but claim to be compatible with IEEE 1344. So if local time is transmitted
  by the IRIG signal then care must be taken that the UTC offset is evaluated by the IRIG
  receiver in the same way as computed by the IRIG generator. Otherwise the UTC
  time computed by the receiver may be <b>wrong</b>.
  @{
 */

/**
 * Definitions used with IRIG transmitters which usually output both
 * the unmodulated and the modulated IRIG signals at the same time: */
enum
{
  ICODE_TX_B002_B122,
  ICODE_TX_B003_B123,
  ICODE_TX_A002_A132,
  ICODE_TX_A003_A133,
  ICODE_TX_AFNOR,
  ICODE_TX_IEEE1344,
  ICODE_TX_B2201344,     // DCLS only
  ICODE_TX_B222,         // DCLS only
  ICODE_TX_B223,         // DCLS only
  ICODE_TX_B006_B126,
  ICODE_TX_B007_B127,
  ICODE_TX_G002_G142,
  ICODE_TX_G006_G146,
  ICODE_TX_C37118,
  N_ICODE_TX    /**< number of code types */
};


/**
 * Initializers for format name strings.
 */
#define DEFAULT_ICODE_TX_NAMES \
{                              \
  "B002+B122",                 \
  "B003+B123",                 \
  "A002+A132",                 \
  "A003+A133",                 \
  "AFNOR NF S87-500",          \
  "IEEE1344",                  \
  "B220(1344) DCLS",           \
  "B222 DCLS",                 \
  "B223 DCLS",                 \
  "B006+B126",                 \
  "B007+B127",                 \
  "G002+G142",                 \
  "G006+G146",                 \
  "C37.118"                    \
}

/**
 * Initializers for short name strings which must not
 * be longer than 10 printable characters.
 */
#define DEFAULT_ICODE_TX_NAMES_SHORT \
{                                    \
  "B002+B122",                       \
  "B003+B123",                       \
  "A002+A132",                       \
  "A003+A133",                       \
  "AFNOR NF-S",                      \
  "IEEE1344",                        \
  "B220/1344",                       \
  "B222 DC",                         \
  "B223 DC",                         \
  "B006+B126",                       \
  "B007+B127",                       \
  "G002+G142",                       \
  "G006+G146",                       \
  "C37.118"                          \
}


/**
 * Initializers for English format description strings.
 */
#define DEFAULT_ICODE_TX_DESCRIPTIONS_ENG                                             \
{                                                                                     \
  "100 bps, DCLS or 1 kHz carrier",                                                   \
  "100 bps, DCLS or 1 kHz carrier, SBS",                                              \
  "1000 bps, DCLS or 10 kHz carrier",                                                 \
  "1000 bps, DCLS or 10 kHz carrier, SBS",                                            \
  "100 bps, DCLS or 1 kHz carrier, SBS, complete date",                               \
  "100 bps, DCLS or 1 kHz carrier, SBS, complete date, time zone info",               \
  "100 bps, Manchester enc., DCLS only, SBS, complete date, time zone info",          \
  "100 bps, Manchester enc., DCLS only",                                              \
  "100 bps, Manchester enc., DCLS only, SBS",                                         \
  "100 bps, DCLS or 1 kHz carrier, complete date",                                    \
  "100 bps, DCLS or 1 kHz carrier, complete date, SBS",                               \
  "10 kbps, DCLS or 100 kHz carrier",                                                 \
  "10 kbps, DCLS or 100 kHz carrier, complete date",                                  \
  "like IEEE1344, but UTC offset with reversed sign"                                  \
}

/*
 * The definitions below are used to set up bit masks
 * which restrict the IRIG formats which are supported
 * by a given IRIG transmitter device:
 */
#define MSK_ICODE_TX_B002_B122    ( 1UL << ICODE_TX_B002_B122 )
#define MSK_ICODE_TX_B003_B123    ( 1UL << ICODE_TX_B003_B123 )
#define MSK_ICODE_TX_A002_A132    ( 1UL << ICODE_TX_A002_A132 )
#define MSK_ICODE_TX_A003_A133    ( 1UL << ICODE_TX_A003_A133 )
#define MSK_ICODE_TX_AFNOR        ( 1UL << ICODE_TX_AFNOR )
#define MSK_ICODE_TX_IEEE1344     ( 1UL << ICODE_TX_IEEE1344 )
#define MSK_ICODE_TX_B2201344     ( 1UL << ICODE_TX_B2201344 )
#define MSK_ICODE_TX_B222         ( 1UL << ICODE_TX_B222 )
#define MSK_ICODE_TX_B223         ( 1UL << ICODE_TX_B223 )
#define MSK_ICODE_TX_B006_B126    ( 1UL << ICODE_TX_B006_B126 )
#define MSK_ICODE_TX_B007_B127    ( 1UL << ICODE_TX_B007_B127 )
#define MSK_ICODE_TX_G002_G142    ( 1UL << ICODE_TX_G002_G142 )
#define MSK_ICODE_TX_G006_G146    ( 1UL << ICODE_TX_G006_G146 )
#define MSK_ICODE_TX_C37118       ( 1UL << ICODE_TX_C37118 )

/**
 * A mask of IRIG formats with manchester encoded DC output:
 */
#define MSK_ICODE_TX_DC_MANCH \
(                             \
  MSK_ICODE_TX_B2201344 |     \
  MSK_ICODE_TX_B222     |     \
  MSK_ICODE_TX_B223           \
)

/**
 * A mask of IRIG formats with 1 kHz carrier:
 */
#define MSK_ICODE_TX_1KHZ  \
(                          \
  MSK_ICODE_TX_B002_B122 | \
  MSK_ICODE_TX_B003_B123 | \
  MSK_ICODE_TX_AFNOR     | \
  MSK_ICODE_TX_IEEE1344  | \
  MSK_ICODE_TX_B2201344  | \
  MSK_ICODE_TX_B222      | \
  MSK_ICODE_TX_B223      | \
  MSK_ICODE_TX_B006_B126 | \
  MSK_ICODE_TX_B007_B127 | \
  MSK_ICODE_TX_C37118      \
)

/**
 * A mask of IRIG formats with 10 kHz carrier:
 */
#define MSK_ICODE_TX_10KHZ \
(                          \
  MSK_ICODE_TX_A002_A132 | \
  MSK_ICODE_TX_A003_A133   \
)

/**
 * A mask of IRIG formats with 100 kHz carrier:
 */
#define MSK_ICODE_TX_100KHZ \
(                           \
  MSK_ICODE_TX_G002_G142 |  \
  MSK_ICODE_TX_G006_G146    \
)

/**
 * A mask of IRIG formats with 100 bps data rate:
 */
#define MSK_ICODE_TX_100BPS \
(                           \
  MSK_ICODE_TX_B002_B122 |  \
  MSK_ICODE_TX_B003_B123 |  \
  MSK_ICODE_TX_AFNOR     |  \
  MSK_ICODE_TX_IEEE1344  |  \
  MSK_ICODE_TX_B006_B126 |  \
  MSK_ICODE_TX_B007_B127 |  \
  MSK_ICODE_TX_C37118       \
)

/**
 * A mask of IRIG formats with 1000 bps data rate:
 */
#define MSK_ICODE_TX_1000BPS \
(                            \
  MSK_ICODE_TX_A002_A132 |   \
  MSK_ICODE_TX_A003_A133     \
)

/**
 * A mask of IRIG formats with 10 kbps data rate:
 */
#define MSK_ICODE_TX_10000BPS \
(                             \
  MSK_ICODE_TX_G002_G142 |    \
  MSK_ICODE_TX_G006_G146      \
)

/**
 * A mask of IRIG formats which support TFOM:
 */
#define MSK_ICODE_TX_HAS_TFOM \
(                             \
  MSK_ICODE_TX_IEEE1344  |    \
  MSK_ICODE_TX_C37118         \
)

/**
 * A mask of IRIG formats which support time zone information:
 */
#define MSK_ICODE_TX_HAS_TZI \
(                            \
  MSK_ICODE_TX_IEEE1344  |   \
  MSK_ICODE_TX_C37118        \
)

/**
 * The default mask of IRIG formats supported by
 * IRIG transmitters:
 */
#if !defined( SUPP_MSK_ICODE_TX )
  #define SUPP_MSK_ICODE_TX  \
  (                          \
    MSK_ICODE_TX_B002_B122 | \
    MSK_ICODE_TX_B003_B123 | \
    MSK_ICODE_TX_A002_A132 | \
    MSK_ICODE_TX_A003_A133 | \
    MSK_ICODE_TX_AFNOR       \
  )
#endif



/**
 * Definitions used with IRIG receivers which decode
 * two similar IRIG codes (with or without SBS)
 * at the same time.
 */
enum
{
  ICODE_RX_B122_B123,        // modulated
  ICODE_RX_A132_A133,        // modulated
  ICODE_RX_B002_B003,        // DCLS
  ICODE_RX_A002_A003,        // DCLS
  ICODE_RX_AFNOR,            // modulated
  ICODE_RX_AFNOR_DC,         // DCLS
  ICODE_RX_IEEE1344,         // modulated
  ICODE_RX_IEEE1344_DC,      // DCLS
  ICODE_RX_B126_B127,        // modulated
  ICODE_RX_B006_B007,        // DCLS
  ICODE_RX_G142_G146,        // modulated
  ICODE_RX_G002_G006,        // DCLS
  ICODE_RX_C37118,           // modulated
  ICODE_RX_C37118_DC,        // DCLS
  ICODE_RX_TXC_101,          // modulated
  ICODE_RX_TXC_101_DC,       // DCLS
  N_ICODE_RX          /* the number of valid signal code types */
};

/**
 * Initializers for format name strings.
 */
#define DEFAULT_ICODE_RX_NAMES \
{                              \
  "B122/B123",                 \
  "A132/A133",                 \
  "B002/B003 (DCLS)",          \
  "A002/A003 (DCLS)",          \
  "AFNOR NF S87-500",          \
  "AFNOR NF S87-500 (DCLS)",   \
  "IEEE1344",                  \
  "IEEE1344 (DCLS)",           \
  "B126/B127",                 \
  "B006/B007 (DCLS)",          \
  "G142/G146",                 \
  "G002/G006 (DCLS)",          \
  "C37.118",                   \
  "C37.118 (DCLS)",            \
  "TXC-101 DTR-6",             \
  "TXC-101 DTR-6 (DCLS)"       \
}

/**
 * Initializers for short name strings which must not
 * be longer than 11 printable characters.
 */
#define DEFAULT_ICODE_RX_NAMES_SHORT \
{                                    \
  "B122/B123",                       \
  "A132/A133",                       \
  "B002/B003",                       \
  "A002/A003",                       \
  "AFNOR NF-S",                      \
  "AFNOR DC",                        \
  "IEEE1344",                        \
  "IEEE1344 DC",                     \
  "B126/B127",                       \
  "B006/B007",                       \
  "G142/G146",                       \
  "G002/G006",                       \
  "C37.118",                         \
  "C37.118 DC",                      \
  "TXC-101",                         \
  "TXC-101 DC"                       \
}


/**
 * Initializers for English format description strings.
 */
#define DEFAULT_ICODE_RX_DESCRIPTIONS_ENG                   \
{                                                           \
  "100 bps, 1 kHz carrier, SBS optionally",                 \
  "1000 bps, 10 kHz carrier, SBS optionally",               \
  "100 bps, DCLS, SBS optionally",                          \
  "1000 bps, DCLS, SBS optionally",                         \
  "100 bps, 1 kHz carrier, SBS, complete date",             \
  "100 bps, DCLS, SBS, complete date",                      \
  "100 bps, 1 kHz carrier, SBS, time zone info",            \
  "100 bps, DCLS, SBS, time zone info",                     \
  "100 bps, 1 kHz carrier, complete date, SBS optionally",  \
  "100 bps, DCLS, complete date, SBS optionally",           \
  "10 kbps, 100 kHz carrier, complete date optionally",     \
  "10 kbps, DCLS, complete date optionally",                \
  "like IEEE1344, but UTC offset with reversed sign",       \
  "like IEEE1344 DC, but UTC offset with reversed sign",    \
  "code from TV time sync device TXC-101 DTR-6",            \
  "DC code from TV time sync device TXC-101 DTR-6"          \
}

/*
 * Bit masks corresponding to the enumeration above:
 */
#define MSK_ICODE_RX_B122_B123       ( 1UL << ICODE_RX_B122_B123 )
#define MSK_ICODE_RX_A132_A133       ( 1UL << ICODE_RX_A132_A133 )
#define MSK_ICODE_RX_B002_B003       ( 1UL << ICODE_RX_B002_B003 )
#define MSK_ICODE_RX_A002_A003       ( 1UL << ICODE_RX_A002_A003 )
#define MSK_ICODE_RX_AFNOR           ( 1UL << ICODE_RX_AFNOR )
#define MSK_ICODE_RX_AFNOR_DC        ( 1UL << ICODE_RX_AFNOR_DC )
#define MSK_ICODE_RX_IEEE1344        ( 1UL << ICODE_RX_IEEE1344 )
#define MSK_ICODE_RX_IEEE1344_DC     ( 1UL << ICODE_RX_IEEE1344_DC )
#define MSK_ICODE_RX_B126_B127       ( 1UL << ICODE_RX_B126_B127 )
#define MSK_ICODE_RX_B006_B007       ( 1UL << ICODE_RX_B006_B007 )
#define MSK_ICODE_RX_G142_G146       ( 1UL << ICODE_RX_G142_G146 )
#define MSK_ICODE_RX_G002_G006       ( 1UL << ICODE_RX_G002_G006 )
#define MSK_ICODE_RX_C37118          ( 1UL << ICODE_RX_C37118 )
#define MSK_ICODE_RX_C37118_DC       ( 1UL << ICODE_RX_C37118_DC )
#define MSK_ICODE_RX_TXC_101         ( 1UL << ICODE_RX_TXC_101 )
#define MSK_ICODE_RX_TXC_101_DC      ( 1UL << ICODE_RX_TXC_101_DC )

/**
 * A mask of IRIG DCLS formats:
 */
#define MSK_ICODE_RX_DC       \
(                             \
  MSK_ICODE_RX_B002_B003    | \
  MSK_ICODE_RX_A002_A003    | \
  MSK_ICODE_RX_AFNOR_DC     | \
  MSK_ICODE_RX_IEEE1344_DC  | \
  MSK_ICODE_RX_B006_B007    | \
  MSK_ICODE_RX_G002_G006    | \
  MSK_ICODE_RX_C37118_DC      \
)

/**
 * A mask of IRIG formats with 1 kHz carrier:
 */
#define MSK_ICODE_RX_1KHZ  \
(                          \
  MSK_ICODE_RX_B122_B123 | \
  MSK_ICODE_RX_AFNOR     | \
  MSK_ICODE_RX_IEEE1344  | \
  MSK_ICODE_RX_B126_B127 | \
  MSK_ICODE_RX_C37118      \
)

/**
 * A mask of IRIG formats with 10 kHz carrier:
 */
#define MSK_ICODE_RX_10KHZ \
(                          \
  MSK_ICODE_RX_A132_A133   \
)

/**
 * A mask of IRIG formats with 100 kHz carrier:
 */
#define MSK_ICODE_RX_100KHZ \
(                           \
  MSK_ICODE_RX_G142_G146    \
)

/**
 * A mask of IRIG formats with 100 bps data rate:
 */
#define MSK_ICODE_RX_100BPS   \
(                             \
  MSK_ICODE_RX_B122_B123    | \
  MSK_ICODE_RX_B002_B003    | \
  MSK_ICODE_RX_AFNOR        | \
  MSK_ICODE_RX_AFNOR_DC     | \
  MSK_ICODE_RX_IEEE1344     | \
  MSK_ICODE_RX_IEEE1344_DC  | \
  MSK_ICODE_RX_B126_B127    | \
  MSK_ICODE_RX_B006_B007    | \
  MSK_ICODE_RX_C37118       | \
  MSK_ICODE_RX_C37118_DC      \
)

/**
 * A mask of IRIG formats with 1000 bps data rate:
 */
#define MSK_ICODE_RX_1000BPS \
(                            \
  MSK_ICODE_RX_A132_A133 |   \
  MSK_ICODE_RX_A002_A003     \
)

/**
 * A mask of IRIG formats with 10 kbps data rate:
 */
#define MSK_ICODE_RX_10000BPS \
(                             \
  MSK_ICODE_RX_G142_G146      \
)

/**
 * A mask of IRIG formats which support TFOM:
 */
#define MSK_ICODE_RX_HAS_TFOM \
(                             \
  MSK_ICODE_RX_IEEE1344     | \
  MSK_ICODE_RX_IEEE1344_DC  | \
  MSK_ICODE_RX_C37118       | \
  MSK_ICODE_RX_C37118_DC      \
)

/**
 * A mask of IRIG formats which support time zone information:
 */
#define MSK_ICODE_RX_HAS_TZI  \
(                             \
  MSK_ICODE_RX_IEEE1344     | \
  MSK_ICODE_RX_IEEE1344_DC  | \
  MSK_ICODE_RX_C37118       | \
  MSK_ICODE_RX_C37118_DC      \
)

/**
 * The default mask of IRIG formats supported by
 * IRIG receivers:
 */
#if !defined( SUPP_MSK_ICODE_RX )
  #define SUPP_MSK_ICODE_RX  \
  (                          \
    MSK_ICODE_RX_B122_B123 | \
    MSK_ICODE_RX_A132_A133 | \
    MSK_ICODE_RX_B002_B003 | \
    MSK_ICODE_RX_A002_A003 | \
    MSK_ICODE_RX_AFNOR     | \
    MSK_ICODE_RX_AFNOR_DC    \
  )
#endif

/** @} group_icode */



/**
 * The structure below is used to configure an optional
 * on-board IRIG output:
 */
typedef struct
{
  uint16_t icode;   /**< IRIG signal code, see \ref group_icode */
  uint16_t flags;   /**< see \ref group_irig_flags */
} IRIG_SETTINGS;

#define _mbg_swab_irig_settings( _p )  \
{                                      \
  _mbg_swab16( &(_p)->icode );         \
  _mbg_swab16( &(_p)->flags );         \
}


/**
 * @defgroup group_irig_flags Bit Masks used with IRIG_SETTINGS::flags
 *
 * (others are reserved)
 * @{
 */
#define IFLAGS_DISABLE_TFOM        0x0001   /**< RX ignore/TX don't gen TFOM */
#define IFLAGS_TX_GEN_LOCAL_TIME   0x0002   /**< gen local time, not UTC */

#define IFLAGS_MASK                0x0003   /**< flags above or'ed */

// Note: the presence or absence of the IFLAGS_DISABLE_TFOM flag for the IRIG RX
// settings of some PCI cards may not be evaluated correctly by some firmware
// versions for those cards, even if an IRIG code has been configured which supports
// this flag. See the comments near the declaration of the _pcps_incoming_tfom_ignored()
// macro in pcpsdev.h for details.

/** @} group_irig_flags */

/**
 * @brief Current IRIG settings and supported codes
 *
 * Used to query the IRIG current IRIG settings
 * plus a mask of supported codes.
 */
typedef struct
{
  IRIG_SETTINGS settings;
  uint32_t supp_codes;     /**< bit mask of supported codes  */
} IRIG_INFO;

#define _mbg_swab_irig_info( _p )              \
{                                              \
  _mbg_swab_irig_settings( &(_p)->settings );  \
  _mbg_swab32( &(_p)->supp_codes );            \
}


/**
 * @defgroup group_irig_comp IRIG input delay compensation
 *
 * These definitions are used with IRIG RX delay compensation
 * which is supported by some IRIG receivers. Delay compensation
 * depends on the basic frame type, so there are different records
 * required for the different frame type groups.
 * @{ */

/**
 * The number of coefficients of a compensation record
 * for a single frame type group, and the structure
 * which contains those coefficients
 */
#define N_IRIG_RX_COMP_VAL  4

/** @brief A structure which stores compensation values. */
typedef struct
{
  int16_t c[N_IRIG_RX_COMP_VAL];  /**< compensation values [100 ns units] */
} IRIG_RX_COMP;

#define _mbg_swab_irig_rx_comp( _p )          \
{                                             \
  int i;                                      \
  for ( i = 0; i < N_IRIG_RX_COMP_VAL; i++ )  \
    _mbg_swab16( &(_p)->c[i] );               \
}


/** @brief Structure used to retrieve the number of calibration records. */
typedef struct
{
  uint16_t num;        /**< number of records supported by the device, */
  uint16_t rec_size;   /**< size of one record, in bytes */
} CAL_REC_INFO;

#define _mbg_swab_cal_rec_info( _p )  \
{                                     \
  _mbg_swab16( &(_p)->num );          \
  _mbg_swab16( &(_p)->rec_size );     \
}


/** @brief Structure used to retrieve the number of records for a given type */
typedef struct
{
  uint16_t type;    /**< record type */
  uint16_t idx;     /**< index if several records of same type are supported */
} CAL_REC_HDR;

#define _mbg_swab_cal_rec_hdr( _p )  \
{                                    \
  _mbg_swab16( &(_p)->type );        \
  _mbg_swab16( &(_p)->idx );         \
}


/** @brief Types to be used with CAL_REC_HDR::type */
enum
{
  CAL_REC_TYPE_UNDEF,          /**< undefined */
  CAL_REC_TYPE_IRIG_RX_COMP,   /**< IRIG receiver delay compensation */
  N_CAL_REC_TYPE               /**< number of known types */
};


/**
 * @brief Types to be used with CAL_REC_HDR::idx
 *
 * IRIG frame type groups to be distinguished for delay compensation.
 */
enum
{
  IRIG_RX_COMP_B1,  /**< codes B1xx, AFNOR, IEEE1344 */
  IRIG_RX_COMP_A1,  /**< code A1xx */
  IRIG_RX_COMP_B0,  /**< codes B0xx, AFNOR DC, IEEE1344 DC */
  IRIG_RX_COMP_A0,  /**< code A0xx */
  N_IRIG_RX_COMP    /**< number of compensation values */
};


/** @brief Initializers for format name strings. */
#define DEFAULT_IRIG_RX_COMP_NAMES \
{                                  \
  "B1xx/AFNOR/IEEE1344",           \
  "A1xx",                          \
  "B0xx/AFNOR DC/IEEE1344 DC",     \
  "A0xx",                          \
}



/** @brief Structure used to transfer calibration records. */
typedef struct
{
  CAL_REC_HDR hdr;
  IRIG_RX_COMP comp_data;   /**< IRIG receiver delay compensation */

} CAL_REC_IRIG_RX_COMP;

#define _mbg_swab_cal_rec_irig_rx_comp( _p )    \
{                                               \
  _mbg_swab_cal_rec_hdr( &(_p)->hdr );          \
  _mbg_swab_irig_rx_comp( &(_p)->comp_data );   \
}

/**  @} group_irig_comp */



// The type below is used to read the board's debug status
// which also include IRIG decoder status:
typedef uint32_t MBG_DEBUG_STATUS;

#define _mbg_swab_debug_status( _p ) \
  _mbg_swab32( _p )



// The debug status is bit coded as defined below:
enum
{
  MBG_IRIG_BIT_WARMED_UP,          /**< Osc has warmed up */
  MBG_IRIG_BIT_PPS_ACTIVE,         /**< PPS output is active */
  MBG_IRIG_BIT_INV_CONFIG,         /**< Invalid config, e.g. data csum error */
  MBG_IRIG_BIT_MSG_DECODED,        /**< IRIG msg could be decoded */
  MBG_IRIG_BIT_MSG_INCONSISTENT,   /**< IRIG msg contains inconsistent data */
  MBG_IRIG_BIT_LOOP_LOCKED,        /**< Decoder control loop is locked */
  MBG_IRIG_BIT_JITTER_TOO_LARGE,   /**< Phase jitter too large */
  MBG_IRIG_BIT_INV_REF_OFFS,       /**< UTC ref offset not configured */

  MBG_SYS_BIT_INV_TIME,            /**< Internal time not valid/set */
  MBG_SYS_BIT_TIME_SET_VIA_API,    /**< On board time set externally */
  MBG_SYS_BIT_INV_RTC,             /**< On board RTC invalid */
  MBG_SYS_BIT_CPU_PLL_FAILED,      /**< The CPU's PLL watchdog */

  N_MBG_DEBUG_BIT
};

/*
 * Initializers for IRIG status bit strings.
 */
#define MBG_DEBUG_STATUS_STRS      \
{                                  \
  "Osc has warmed up",             \
  "PPS output is active",          \
  "Config set to default",         \
  "IRIG msg decoded",              \
  "IRIG msg not consistent",       \
  "Decoder control loop locked",   \
  "Phase jitter too large",        \
  "Invalid ref offset",            \
                                   \
  "Internal time not valid",       \
  "On board time set via API",     \
  "On board RTC invalid",          \
  "CPU PLL failure, needs restart" \
}



#define MBG_IRIG_MSK_WARMED_UP        ( 1UL << MBG_IRIG_BIT_WARMED_UP )
#define MBG_IRIG_MSK_PPS_ACTIVE       ( 1UL << MBG_IRIG_BIT_PPS_ACTIVE )
#define MBG_IRIG_MSK_INV_CONFIG       ( 1UL << MBG_IRIG_BIT_INV_CONFIG )
#define MBG_IRIG_MSK_MSG_DECODED      ( 1UL << MBG_IRIG_BIT_MSG_DECODED )
#define MBG_IRIG_MSK_MSG_INCONSISTENT ( 1UL << MBG_IRIG_BIT_MSG_INCONSISTENT )
#define MBG_IRIG_MSK_LOOP_LOCKED      ( 1UL << MBG_IRIG_BIT_LOOP_LOCKED )
#define MBG_IRIG_MSK_JITTER_TOO_LARGE ( 1UL << MBG_IRIG_BIT_JITTER_TOO_LARGE )
#define MBG_IRIG_MSK_INV_REF_OFFS     ( 1UL << MBG_IRIG_BIT_INV_REF_OFFS )

#define MBG_SYS_MSK_INV_TIME          ( 1UL << MBG_SYS_BIT_INV_TIME )
#define MBG_SYS_MSK_TIME_SET_VIA_API  ( 1UL << MBG_SYS_BIT_TIME_SET_VIA_API )
#define MBG_SYS_MSK_INV_RTC           ( 1UL << MBG_SYS_BIT_INV_RTC )
#define MBG_SYS_MSK_CPU_PLL_FAILED    ( 1UL << MBG_SYS_BIT_CPU_PLL_FAILED )



typedef int16_t MBG_REF_OFFS;   /**< -MBG_REF_OFFS_MAX..MBG_REF_OFFS_MAX */

#define _mbg_swab_mbg_ref_offs( _p )  _mbg_swab16( (_p) )


/** the maximum allowed positive / negative offset */
#define MBG_REF_OFFS_MAX   ( ( 12L * 60 ) + 30 )  // [minutes]

/**
 * the following value is used to indicate that the ref offset
 * value has not yet been configured
 */
#define MBG_REF_OFFS_NOT_CFGD  0x8000


typedef struct
{
  uint32_t flags;
} MBG_OPT_SETTINGS;

#define _mbg_swab_mbg_opt_settings( _p )  \
{                                         \
  _mbg_swab32( &(_p)->flags );            \
}


typedef struct
{
  MBG_OPT_SETTINGS settings;
  uint32_t supp_flags;
} MBG_OPT_INFO;

#define _mbg_swab_mbg_opt_info( _p )              \
{                                                 \
  _mbg_swab_mbg_opt_settings( &(_p)->settings );  \
  _mbg_swab32( &(_p)->supp_flags );               \
}


enum
{
  MBG_OPT_BIT_STR_UTC,   /**< serial string contains UTC time */
  MBG_OPT_BIT_EMU_SYNC,  /**< emulate/pretend to be synchronized, */
                         /**< alternatively GPS_FEAT_IGNORE_LOCK may be supported */
  N_MBG_OPT_BIT
};

/*
 * Bit masks corresponding to the enumeration above:
 */
#define MBG_OPT_FLAG_STR_UTC   ( 1UL << MBG_OPT_BIT_STR_UTC )
#define MBG_OPT_FLAG_EMU_SYNC  ( 1UL << MBG_OPT_BIT_EMU_SYNC )



// bit coded return type for PCPS_GET_IRIG_CTRL_BITS
typedef uint32_t  MBG_IRIG_CTRL_BITS;

#define _mbg_swab_irig_ctrl_bits( _p )  _mbg_swab32( _p )


// The following macro extracts the 4 bit TFOM code from the
// IRIG control bits read from a card. This only works if the received
// IRIG code is a code which supports TFOM, this is currently
// only IEEE1344.
#define _pcps_tfom_from_irig_ctrl_bits( _p ) \
        ( ( ( *(_p) ) >> 24 ) & 0x0F )



#define RAW_IRIG_SIZE    16

/**
 The buffer below can be used to get the raw data bits
 from the IRIG decoder. A maximum number of RAW_IRIG_SIZE
 bytes can be filled. If less bytes are used then the rest
 of the bytes are filled with zeros.

 The first IRIG bit received from the transmitter is saved
 in the MSB (bit 7) of data_bytes[0], etc.
*/
typedef struct
{
  uint8_t data_bytes[RAW_IRIG_SIZE];
} MBG_RAW_IRIG_DATA;

// The following macro extracts the 4 bit TFOM code from the raw
// data bits read from a card. This only works if the received
// IRIG code is a code which supports TFOM, this is currently
// only IEEE1344.
#define _pcps_tfom_from_raw_irig_data( _p )    \
  ( ( ( (_p)->data_bytes[9] >> 2 ) & 0x08 )  \
  | ( ( (_p)->data_bytes[9] >> 4 ) & 0x04 )  \
  | ( ( (_p)->data_bytes[9] >> 6 ) & 0x02 )  \
  | ( ( (_p)->data_bytes[8] & 0x01 ) ) )



/**
  @defgroup group_time_scale Time Scale Configuration

  The structures and defines can be used to configure the GPS receiver's
  basic time scale. By default this is UTC which can optionally
  be converted to some local time. However, some applications
  prefer TAI or pure GPS time. This can be configured using the
  structures below if the GPS_HAS_TIME_SCALE flag is set in
  RECEIVER_INFO::features.
 @{
*/

enum
{
  MBG_TIME_SCALE_DEFAULT,   /**< UTC or local time, t_gps - deltat_ls */
  MBG_TIME_SCALE_GPS,       /**< GPS time, monotonical */
  MBG_TIME_SCALE_TAI,       /**< TAI, t_gps + GPS_TAI_OFFSET seconds */
  N_MBG_TIME_SCALE
};

#define MBG_TIME_SCALE_MSK_DEFAULT  ( 1UL << MBG_TIME_SCALE_DEFAULT )
#define MBG_TIME_SCALE_MSK_GPS      ( 1UL << MBG_TIME_SCALE_GPS )
#define MBG_TIME_SCALE_MSK_TAI      ( 1UL << MBG_TIME_SCALE_TAI )

// See also the extended status bits TM_SCALE_GPS and TM_SCALE_TAI
// indicating the active time scale setting.


#define MBG_TIME_SCALE_STRS \
{                           \
  "UTC/local",              \
  "GPS",                    \
  "TAI"                     \
}



/**
  The fixed time offset between the GPS and TAI time scales, in seconds
*/
#define GPS_TAI_OFFSET   19 /**< [s], TAI = GPS + GPS_TAI_OFFSET */


typedef struct
{
  uint8_t scale;             /**< current time scale code from the enum above */
  uint8_t flags;             /**< reserved, currently always 0 */
} MBG_TIME_SCALE_SETTINGS;

#define _mbg_swab_mbg_time_scale_settings( _p )  \
  _nop_macro_fnc()


typedef struct
{
  MBG_TIME_SCALE_SETTINGS settings;      /**< current settings */
  MBG_TIME_SCALE_SETTINGS max_settings;  /**< numb. of scales, all supported flags */
  uint32_t supp_scales;                  /**< bit masks of supported scales */
} MBG_TIME_SCALE_INFO;

#define _mbg_swab_mbg_time_scale_info( _p )                 \
{                                                           \
  _mbg_swab_mbg_time_scale_settings( &(_p)->settings );     \
  _mbg_swab_mbg_time_scale_settings( &(_p)->max_settings ); \
  _mbg_swab32( &(_p)->supp_scales );                        \
}

/** @} group_time_scale */


/*
 * The structures below are required to setup the programmable
 * pulse outputs which are provided by some GPS receivers.
 * The number of programmable pulse outputs supported by a GPS
 * receiver is reported in the RECEIVER_INFO.n_str_type field.
 */

/**
 * The structure is used to define a date of year:
 */
typedef struct
{
  uint8_t mday;    /* 1..28,29,30,31 */
  uint8_t month;   /* 1..12 */
  uint16_t year;   /* including century */
} MBG_DATE;

#define _mbg_swab_mbg_date( _p ) \
{                                \
  _mbg_swab16( &(_p)->year );    \
}


/**
 * The structure is used to define a time of day:
 */
typedef struct
{
  uint8_t hour;    /**< 0..23 */
  uint8_t min;     /**< 0..59 */
  uint8_t sec;     /**< 0..59,60 */
  uint8_t sec100;  /**< reserved, currently always 0 */
} MBG_TIME;

#define _mbg_swab_mbg_time( _p ) \
  _nop_macro_fnc()    // nothing to swap


/**
 * The structure defines a single date and time
 * for switching operations:
 */
typedef struct
{
  MBG_DATE d;    /* date to switch */
  MBG_TIME t;    /* time to switch */
  uint8_t wday;  /* reserved, currently always 0 */
  uint8_t flags; /* reserved, currently 0 */
} MBG_DATE_TIME;

#define _mbg_swab_mbg_date_time( _p ) \
{                                     \
  _mbg_swab_mbg_date( &(_p)->d );     \
  _mbg_swab_mbg_time( &(_p)->t );     \
}


/**
 * The structure defines times and dates
 * for an on/off cycle:
 */
typedef struct
{
  MBG_DATE_TIME on;   /* time and date to switch on */
  MBG_DATE_TIME off;  /* time and date to switch off */
} POUT_TIME;

#define _mbg_swab_pout_time( _p )        \
{                                        \
  _mbg_swab_mbg_date_time( &(_p)->on );  \
  _mbg_swab_mbg_date_time( &(_p)->off ); \
}


/**
 * The number of POUT_TIMEs for each programmable pulse output
 */
#define N_POUT_TIMES 3

/**
 * The structure is used to configure a single programmable
 * pulse output.
 */
typedef struct
{
  uint16_t mode;        /**< mode of operation, codes defined below */
  uint16_t pulse_len;   /**< 10 msec units, or COM port number */
  uint16_t timeout;     /**< [min], for dcf_mode */
  uint16_t flags;       /**< see below */
  POUT_TIME tm[N_POUT_TIMES];  /**< switching times */
} POUT_SETTINGS;

#define _mbg_swab_pout_settings( _p )     \
{                                         \
  int i;                                  \
  _mbg_swab16( &(_p)->mode );             \
  _mbg_swab16( &(_p)->pulse_len );        \
  _mbg_swab16( &(_p)->timeout );          \
  _mbg_swab16( &(_p)->flags );            \
                                          \
  for ( i = 0; i < N_POUT_TIMES; i++ )    \
    _mbg_swab_pout_time( &(_p)->tm[i] );  \
}


#define MAX_POUT_PULSE_LEN    1000         /**< 10 secs, in 10 msec units */
#define MAX_POUT_DCF_TIMOUT   ( 48 * 60 )  /**< 48 hours, in minutes */


/**
 * These codes are defined for POUT_SETTINGS.mode to setup
 * the basic mode of operation for a single programmable pulse
 * output:
 */
enum
{
  POUT_IDLE,          /**< always off, or on if POUT_INVERTED */
  POUT_TIMER,         /**< switch on/off at configured times */
  POUT_SINGLE_SHOT,   /**< pulse at time POUT_SETTINGS.tm[0].on */
  POUT_CYCLIC_PULSE,  /**< pulse every POUT_SETTINGS.tm[0].on.t interval */
  POUT_PER_SEC,       /**< pulse if second changes */
  POUT_PER_MIN,       /**< pulse if minute changes */
  POUT_PER_HOUR,      /**< pulse if hour changes */
  POUT_DCF77,         /**< emulate DCF77 signal */
  POUT_POS_OK,        /**< on if pos. OK (nav_solved) */
  POUT_TIME_SYNC,     /**< on if time sync (time_syn) */
  POUT_ALL_SYNC,      /**< on if pos. OK and time sync */
  POUT_TIMECODE,      /**< IRIG/AFNOR DCLS output */
  POUT_TIMESTR,       /**< COM port number in pulse_len field */
  POUT_10MHZ,         /**< 10 MHz fixed frequency */
  POUT_DCF77_M59,     /**< DCF77-like signal with 500 ms pulse in 59th second */
  POUT_SYNTH,         /**< programmable synthesizer frequency */
  N_POUT_MODES
};


/*
 * Default initializers for English pulse mode names. Initializers
 * for multi-language strings can be found in pcpslstr.h.
 */
#define ENG_POUT_NAME_IDLE            "Idle"
#define ENG_POUT_NAME_TIMER           "Timer"
#define ENG_POUT_NAME_SINGLE_SHOT     "Single Shot"
#define ENG_POUT_NAME_CYCLIC_PULSE    "Cyclic Pulse"
#define ENG_POUT_NAME_PER_SEC         "Pulse Per Second"
#define ENG_POUT_NAME_PER_MIN         "Pulse Per Min"
#define ENG_POUT_NAME_PER_HOUR        "Pulse Per Hour"
#define ENG_POUT_NAME_DCF77           "DCF77 Marks"
#define ENG_POUT_NAME_POS_OK          "Position OK"
#define ENG_POUT_NAME_TIME_SYNC       "Time Sync"
#define ENG_POUT_NAME_ALL_SYNC        "All Sync"
#define ENG_POUT_NAME_TIMECODE        "DCLS Time Code"
#define ENG_POUT_NAME_TIMESTR         "COM Time String"
#define ENG_POUT_NAME_10MHZ           "10 MHz Frequency"
#define ENG_POUT_NAME_DCF77_M59       "DCF77-like M59"
#define ENG_POUT_NAME_SYNTH           "Synthesizer Frequency"

#define DEFAULT_ENG_POUT_NAMES \
{                              \
  ENG_POUT_NAME_IDLE,          \
  ENG_POUT_NAME_TIMER,         \
  ENG_POUT_NAME_SINGLE_SHOT,   \
  ENG_POUT_NAME_CYCLIC_PULSE,  \
  ENG_POUT_NAME_PER_SEC,       \
  ENG_POUT_NAME_PER_MIN,       \
  ENG_POUT_NAME_PER_HOUR,      \
  ENG_POUT_NAME_DCF77,         \
  ENG_POUT_NAME_POS_OK,        \
  ENG_POUT_NAME_TIME_SYNC,     \
  ENG_POUT_NAME_ALL_SYNC,      \
  ENG_POUT_NAME_TIMECODE,      \
  ENG_POUT_NAME_TIMESTR,       \
  ENG_POUT_NAME_10MHZ,         \
  ENG_POUT_NAME_DCF77_M59,     \
  ENG_POUT_NAME_SYNTH          \
}


#define ENG_POUT_HINT_IDLE            "Constant output level"
#define ENG_POUT_HINT_TIMER           "Switch based on configured on/off times"
#define ENG_POUT_HINT_SINGLE_SHOT     "Generate a single pulse of determined length"
#define ENG_POUT_HINT_CYCLIC_PULSE    "Generate cyclic pulses of determined length"
#define ENG_POUT_HINT_PER_SEC         "Generate pulse at beginning of new second"
#define ENG_POUT_HINT_PER_MIN         "Generate pulse at beginning of new minute"
#define ENG_POUT_HINT_PER_HOUR        "Generate pulse at beginning of new hour"
#define ENG_POUT_HINT_DCF77           "DCF77 compatible time marks"
#define ENG_POUT_HINT_POS_OK          "Switch if receiver position has been verified"
#define ENG_POUT_HINT_TIME_SYNC       "Switch if time is synchronized"
#define ENG_POUT_HINT_ALL_SYNC        "Switch if full sync"
#define ENG_POUT_HINT_TIMECODE        "Duplicate IRIG time code signal"
#define ENG_POUT_HINT_TIMESTR         "Duplicate serial time string of specified port"
#define ENG_POUT_HINT_10MHZ           "10 MHz fixed output frequency"
#define ENG_POUT_HINT_DCF77_M59       "DCF77 time marks with 500 ms pulse in 59th second"
#define ENG_POUT_HINT_SYNTH           "Frequency generated by programmable synthesizer"

#define DEFAULT_ENG_POUT_HINTS \
{                              \
  ENG_POUT_HINT_IDLE,          \
  ENG_POUT_HINT_TIMER,         \
  ENG_POUT_HINT_SINGLE_SHOT,   \
  ENG_POUT_HINT_CYCLIC_PULSE,  \
  ENG_POUT_HINT_PER_SEC,       \
  ENG_POUT_HINT_PER_MIN,       \
  ENG_POUT_HINT_PER_HOUR,      \
  ENG_POUT_HINT_DCF77,         \
  ENG_POUT_HINT_POS_OK,        \
  ENG_POUT_HINT_TIME_SYNC,     \
  ENG_POUT_HINT_ALL_SYNC,      \
  ENG_POUT_HINT_TIMECODE,      \
  ENG_POUT_HINT_TIMESTR,       \
  ENG_POUT_HINT_10MHZ,         \
  ENG_POUT_HINT_DCF77_M59,     \
  ENG_POUT_HINT_SYNTH          \
}


/*
 * The definitions below are used to set up bit masks
 * which restrict the modes which can be used with
 * a given programmable output:
 */
#define MSK_POUT_IDLE          ( 1UL << POUT_IDLE )
#define MSK_POUT_TIMER         ( 1UL << POUT_TIMER )
#define MSK_POUT_SINGLE_SHOT   ( 1UL << POUT_SINGLE_SHOT )
#define MSK_POUT_CYCLIC_PULSE  ( 1UL << POUT_CYCLIC_PULSE )
#define MSK_POUT_PER_SEC       ( 1UL << POUT_PER_SEC )
#define MSK_POUT_PER_MIN       ( 1UL << POUT_PER_MIN )
#define MSK_POUT_PER_HOUR      ( 1UL << POUT_PER_HOUR )
#define MSK_POUT_DCF77         ( 1UL << POUT_DCF77 )
#define MSK_POUT_POS_OK        ( 1UL << POUT_POS_OK )
#define MSK_POUT_TIME_SYNC     ( 1UL << POUT_TIME_SYNC )
#define MSK_POUT_ALL_SYNC      ( 1UL << POUT_ALL_SYNC )
#define MSK_POUT_TIMECODE      ( 1UL << POUT_TIMECODE )
#define MSK_POUT_TIMESTR       ( 1UL << POUT_TIMESTR )
#define MSK_POUT_10MHZ         ( 1UL << POUT_10MHZ )
#define MSK_POUT_DCF77_M59     ( 1UL << POUT_DCF77_M59 )
#define MSK_POUT_SYNTH         ( 1UL << POUT_SYNTH )


/*
 * The codes below are used with POUT_SETTINGS::flags:
 */
#define POUT_INVERTED       0x0001   // invert output level
#define POUT_IF_SYNC_ONLY   0x0002   // disable in holdover mode
#define POUT_TIMEBASE_UTC   0x0004   // use UTC, only applicable for DCF77 output


/**
  Since a clock may support more than one programmable
  pulse output, setup tools must use the structure below
  to read/set pulse output configuration.
  The number of outputs supported by a receiver model
  can be queried using the RECEIVER_INFO structure.
 */
typedef struct
{
  uint16_t idx;        /**< 0..RECEIVER_INFO.n_prg_out-1 */
  POUT_SETTINGS pout_settings;
} POUT_SETTINGS_IDX;

#define _mbg_swab_pout_settings_idx( _p )           \
{                                                   \
  _mbg_swab16( &(_p)->idx );                        \
  _mbg_swab_pout_settings( &(_p)->pout_settings );  \
}


/**
  The structure below holds the current settings
  for a programmable pulse output, plus additional
  informaton on the output's capabilities.
  This can be read by setup programs to allow setup
  of supported features only.
 */
typedef struct
{
  POUT_SETTINGS pout_settings;
  uint32_t supp_modes;   /**< bit mask of modes supp. by this output */
  uint8_t timestr_ports; /**< bit mask of COM ports supported for POUT_TIMESTR */
  uint8_t reserved_0;    /**< reserved for future use, currently 0 */
  uint16_t reserved_1;   /**< reserved for future use, currently 0 */
  uint32_t flags;        /**< see below */
} POUT_INFO;

#define _mbg_swab_pout_info( _p )                   \
{                                                   \
  _mbg_swab_pout_settings( &(_p)->pout_settings );  \
  _mbg_swab32( &(_p)->supp_modes );                 \
  _mbg_swab16( &(_p)->reserved_1 );                 \
  _mbg_swab32( &(_p)->flags );                      \
}


/** The max number of COM ports that can be handled by POUT_INFO::timestr_ports */
#define MAX_POUT_TIMESTR_PORTS  8


/*
 * The codes below are used with POUT_INFO::flags:
 */
#define POUT_SUPP_IF_SYNC_ONLY   0x0001   // supports disabling outputs in holdover mode
#define POUT_SUPP_DCF77_UTC      0x0002   // supports UTC output in DCF77 mode


/**
 The structure below adds an index number to the structure
 above to allow addressing of several instances:
 */
typedef struct
{
  uint16_t idx;          /**< 0..RECEIVER_INFO.n_prg_out-1 */
  POUT_INFO pout_info;
} POUT_INFO_IDX;

#define _mbg_swab_pout_info_idx( _p )       \
{                                           \
  _mbg_swab16( &(_p)->idx );                \
  _mbg_swab_pout_info( &(_p)->pout_info );  \
}


/*
 * The codes below are used with devices which support multiple
 * ref time sources at the same time. The priorities of the
 * supported ref time sources is configurable.
 */


/**
 * @brief All possibly supported ref time sources
 */
enum
{
  MULTI_REF_NONE = -1,      /**< nothing, undefined */
  MULTI_REF_GPS = 0,        /**< standard GPS */
  MULTI_REF_10MHZ,          /**< 10 MHz input frequency */
  MULTI_REF_PPS,            /**< 1 PPS input signal */
  MULTI_REF_10MHZ_PPS,      /**< combined 10 MHz plus PPS */
  MULTI_REF_IRIG,           /**< IRIG input */
  MULTI_REF_NTP,            /**< Network Time Protocol (NTP) */
  MULTI_REF_PTP,            /**< Precision Time Protocol (PTP, IEEE1588) */
  MULTI_REF_PTP_E1,         /**< PTP over E1 */
  MULTI_REF_FREQ,           /**< fixed frequency */
  MULTI_REF_PPS_STRING,     /**< PPS in addition to string */
  MULTI_REF_GPIO,           /**< variable input signal via GPIO */
  MULTI_REF_INTERNAL,       /**< reserved, used internally by firmware only */
  MULTI_REF_PZF,            /**< DCF77 PZF providing much more accuracy than a standard LWR */
  MULTI_REF_LWR,            /**< long wave receiver. e.g. DCF77 AM, WWVB, MSF, JJY */
  N_MULTI_REF               /**< the number of defined sources, can not exceed bit number of uint32_t - 1 */
};


/*
 * Names of supported ref time sources
 */
#define DEFAULT_MULTI_REF_NAMES \
{                               \
  "GPS",                        \
  "10 MHz freq in",             \
  "PPS in",                     \
  "10 MHz + PPS in",            \
  "IRIG",                       \
  "NTP",                        \
  "PTP (IEEE1588)",             \
  "PTP over E1",                \
  "Fixed Freq. in",             \
  "PPS plus string",            \
  "Var. freq. via GPIO",        \
  "(reserved)",                 \
  "DCF77 PZF Receiver",         \
  "Long Wave Receiver"          \
}


/*
 * Bit masks used to indicate supported reference sources
 */
#define HAS_MULTI_REF_GPS        ( 1UL << MULTI_REF_GPS )
#define HAS_MULTI_REF_10MHZ      ( 1UL << MULTI_REF_10MHZ )
#define HAS_MULTI_REF_PPS        ( 1UL << MULTI_REF_PPS )
#define HAS_MULTI_REF_10MHZ_PPS  ( 1UL << MULTI_REF_10MHZ_PPS )
#define HAS_MULTI_REF_IRIG       ( 1UL << MULTI_REF_IRIG )
#define HAS_MULTI_REF_NTP        ( 1UL << MULTI_REF_NTP )
#define HAS_MULTI_REF_PTP        ( 1UL << MULTI_REF_PTP )
#define HAS_MULTI_REF_PTP_E1     ( 1UL << MULTI_REF_PTP_E1 )

#define HAS_MULTI_REF_FREQ       ( 1UL << MULTI_REF_FREQ )
#define HAS_MULTI_REF_PPS_STRING ( 1UL << MULTI_REF_PPS_STRING )
#define HAS_MULTI_REF_GPIO       ( 1UL << MULTI_REF_GPIO )
#define HAS_MULTI_REF_INTERNAL   ( 1UL << MULTI_REF_INTERNAL )
#define HAS_MULTI_REF_PZF        ( 1UL << MULTI_REF_PZF )
#define HAS_MULTI_REF_LWR        ( 1UL << MULTI_REF_LWR )


/*
 * There are 2 different ways to configure multi ref support
 * provided by some devices.
 *
 * Newer devices which have the GPS_FEAT_XMULTI_REF flag set
 * in RECEIVER_INFO::features support the newer XMULTI_REF_...
 * structures which provide a more flexible interface.
 *
 * Older devices which have the GPS_FEAT_MULTI_REF flag set
 * support these MULTI_REF_... structures below where
 * the number of supported input sources and priorities
 * is limited to N_MULTI_REF_PRIO.
 */

#define N_MULTI_REF_PRIO   4


/**
  The structure below is used to configure the priority of
  the supported ref sources.

  The number stored in prio[0] of the array indicates the ref time
  source with highest priority. If that source fails, the device
  falls back to the source indicated by prio[1]. Each field of
  the prio[] array must be set to one of the values 0..N_MULTI_REF-1,
  or to -1 (0xFF) if the value is not assigned.
 */
typedef struct
{
  uint8_t prio[N_MULTI_REF_PRIO];
} MULTI_REF_SETTINGS;


/**
  The structure below is used to query the MULTI_REF configuration,
  plus the supported ref sources.
 */
typedef struct
{
  MULTI_REF_SETTINGS settings;    /* current settings */
  uint32_t supp_ref;              /* supp. HAS_MULTI_REF_... codes or'ed */
  uint16_t n_levels;              /* supp. levels, 0..N_MULTI_REF_PRIO */
  uint16_t flags;                 /* reserved, currently 0 */
} MULTI_REF_INFO;


/*
 * The type below is used to query the MULTI_REF status information,
 */
typedef uint16_t MULTI_REF_STATUS;  /* flag bits as defined below */


/*
 * The bits and associated bit masks below are used with the
 * MULTI_REF_STATUS type. Each bit is set if the associated
 * condition is true and is reset if the condition is not true:
 */
enum
{
  WRN_MODULE_MODE,     /* selected input mode was invalid, set to default */
  WRN_COLD_BOOT,       /* GPS is in cold boot mode */
  WRN_WARM_BOOT,       /* GPS is in warm boot mode */
  WRN_ANT_DISCONN,     /* antenna is disconnected */
  WRN_10MHZ_UNLOCK,    /* impossible to lock to external 10MHz reference */
  WRN_1PPS_UNLOCK,     /* impossible to lock to external 1PPS reference */
  WRN_GPS_UNLOCK,      /* impossible to lock to GPS */
  WRN_10MHZ_MISSING,   /* external 10MHz signal not available */
  WRN_1PPS_MISSING,    /* external 1PPS signal not available */
  N_MULTI_REF_STATUS_BITS
};

#define MSK_WRN_COLD_BOOT            ( 1UL << WRN_COLD_BOOT )
#define MSK_WRN_WARM_BOOT            ( 1UL << WRN_WARM_BOOT )
#define MSK_WRN_ANT_DISCONN          ( 1UL << WRN_ANT_DISCONN )
#define MSK_WRN_10MHZ_UNLOCK         ( 1UL << WRN_10MHZ_UNLOCK )
#define MSK_WRN_1PPS_UNLOCK          ( 1UL << WRN_1PPS_UNLOCK )
#define MSK_WRN_GPS_UNLOCK           ( 1UL << WRN_GPS_UNLOCK )
#define MSK_WRN_10MHZ_MISSING        ( 1UL << WRN_10MHZ_MISSING )
#define MSK_WRN_1PPS_MISSING         ( 1UL << WRN_1PPS_MISSING )
#define MSK_WRN_MODULE_MODE          ( 1UL << WRN_MODULE_MODE )



/**
 * @defgroup group_xmr_cfg Extended multiref configuration stuff
 *
 * If the RECEIVER_INFO::features flag GPS_FEAT_XMULTI_REF is set
 * then the following XMULTI_REF_... data structures must be used
 * instead of the older MULTI_REF_... structures.
 *
 * Those devices support a number of priority levels addressed by
 * the priority index, starting at 0 for highest priority. A single
 * reference time source from the set of supported sources can be
 * assigned to each priority level.
 *
 * These structures are used to configure the individual
 * time source for each priority level, and retrieve the status
 * of the time source at each priority level.
 *
 * @{ */

/**
 * @brief Identifier for a reference source
 */
typedef struct
{
  uint8_t type;          /**< 0..N_MULTI_REF-1 from the enum above */
  uint8_t instance;      /**< instance number, if multiple instances are supported, else 0 */

} XMULTI_REF_ID;



/**
 * @brief Reference source configuration settings
 */
typedef struct
{
  XMULTI_REF_ID id;      /**< time source identifier */
  uint16_t flags;        /**< reserved, currently always 0 */
  NANO_TIME bias;        /**< time bias, e.g. path delay */
  NANO_TIME precision;   /**< precision of the time source */
  uint32_t fine_limit;   /**< smooth control if below this limit */

} XMULTI_REF_SETTINGS;



/**
 * @brief Reference source configuration settings for a specific priority level
 *
 * @note After configuring, a structure with idx == 0xFFFF (-1) must be sent
 * to let the changes become effective.
 */
typedef struct
{
  uint16_t idx;                   /* the priority level index, highest == 0 */
  XMULTI_REF_SETTINGS settings;   /* the settings configured for this level */

} XMULTI_REF_SETTINGS_IDX;



/**
 * @brief Reference source configuration settings and capabilities
 */
typedef struct
{
  XMULTI_REF_SETTINGS settings;   /**< current settings */
  uint32_t supp_ref;              /**< bit mask of or'ed HAS_MULTI_REF_... codes */
  uint8_t n_supp_ref;             /**< number of supported ref time sources */
  uint8_t n_prio;                 /**< number of supported priority levels */
  uint16_t flags;                 /**< currently always 0 */

} XMULTI_REF_INFO;



/**
 * @brief Reference source configuration settings and capabilities for a specific priority level
 */
typedef struct
{
  uint16_t idx;          /**< the priority level index, highest == 0 */
  XMULTI_REF_INFO info;  /**< ref source cfg and capabilities */

} XMULTI_REF_INFO_IDX;



/**
 * @brief Status information on a single ref time source
 */
typedef struct
{
  XMULTI_REF_ID id;      /**< time source identifier */
  uint16_t status;       /**< flag bits as defined below */
  NANO_TIME offset;      /**< time offset from main time base */
  uint16_t flags;        /**< see flags specified below */
  uint8_t  ssm;          /**< synchronization status message ( if supported by src. )*/
  uint8_t  soc;          /**< signal outage counter ( updt. on loss of signal ) */
} XMULTI_REF_STATUS;



/**
 * @brief Bits and masks used with XMULTI_REF_STATUS::flags
 *
 * @note This API is only supported if bit GPS_HAS_XMRS_MULT_INSTC
 * is set in RECEIVER_INFO::features.
 */
enum
{
  XMRSF_BIT_MULT_INSTC_SUPP,  /**< multiple instances of the same ref type supported */
  XMRSF_BIT_IS_EXTERNAL,      /**< this ref source is on extension card */
  N_XMRS_FLAGS
};

#define XMRSF_MSK_MULT_INSTC_SUPP  ( 1UL << XMRSF_BIT_MULT_INSTC_SUPP )
#define XMRSF_MSK_IS_EXTERNAL      ( 1UL << XMRSF_BIT_IS_EXTERNAL )



/**
 * @brief Status information on a ref time source at a specific priority level
 */
typedef struct
{
  uint16_t idx;              /**< the priority level index, highest == 0 */
  XMULTI_REF_STATUS status;  /**< status information */

} XMULTI_REF_STATUS_IDX;



/**
 * @brief Bits and bit masks used with XMULTI_REF_STATUS::status
 *
 * @note Flags XMRS_BIT_MULT_INSTC_SUPP and XMRS_BIT_NUM_SRC_EXC
 * are set in the status flags for every priority if the associated
 * condition is met.
 */
enum
{
  XMRS_BIT_NOT_SUPP,          /**< ref type cfg'd for this level is not supported */
  XMRS_BIT_NO_CONN,           /**< input signal is disconnected */
  XMRS_BIT_NO_SIGNAL,         /**< no input signal */
  XMRS_BIT_IS_MASTER,         /**< reference is master source */
  XMRS_BIT_IS_LOCKED,         /**< locked to input signal */
  XMRS_BIT_IS_ACCURATE,       /**< oscillator control has reached full accuracy */
  XMRS_BIT_NOT_SETTLED,       /**< reference time signal not settled */
  XMRS_BIT_NOT_PHASE_LOCKED,  /**< oscillator not phase locked to PPS */
  XMRS_BIT_NUM_SRC_EXC,       /**< number of available sources exceeds what can be handled */
  XMRS_BIT_IS_EXTERNAL,       /**< this ref source is on extension card */
  N_XMRS_BITS                 /**< number of know status bits */
};

#define XMRS_MSK_NOT_SUPP          ( 1UL << XMRS_BIT_NOT_SUPP )
#define XMRS_MSK_NO_CONN           ( 1UL << XMRS_BIT_NO_CONN )
#define XMRS_MSK_NO_SIGNAL         ( 1UL << XMRS_BIT_NO_SIGNAL )
#define XMRS_MSK_IS_MASTER         ( 1UL << XMRS_BIT_IS_MASTER )
#define XMRS_MSK_IS_LOCKED         ( 1UL << XMRS_BIT_IS_LOCKED )
#define XMRS_MSK_IS_ACCURATE       ( 1UL << XMRS_BIT_IS_ACCURATE )
#define XMRS_MSK_NOT_SETTLED       ( 1UL << XMRS_BIT_NOT_SETTLED )
#define XMRS_MSK_NOT_PHASE_LOCKED  ( 1UL << XMRS_BIT_NOT_PHASE_LOCKED )
#define XMRS_MSK_NUM_SRC_EXC       ( 1UL << XMRS_BIT_NUM_SRC_EXC )
#define XMRS_MSK_IS_EXTERNAL       ( 1UL << XMRS_BIT_IS_EXTERNAL )

/*
 * Initializers for XMRS status bit strings.
 */
#define MBG_XMRS_STATUS_STRS      \
{                                 \
  "Ref type not supported",       \
  "No connection",                \
  "No signal",                    \
  "Is Master",                    \
  "Is locked",                    \
  "Is accuracte",                 \
  "Not settled",                  \
  "Phase not locked",             \
  "Number sources exceeds limit", \
  "Is external"                   \
}


/*
 * An initializer for a XMULTI_REF_STATUS variable
 * with status invalid / not used
 */
#define XMULTI_REF_STATUS_INVALID                          \
{                                                          \
  { (uint8_t) MULTI_REF_NONE, 0 },  /* id; instance 0 ? */ \
  XMRS_MSK_NO_CONN | XMRS_MSK_NO_SIGNAL,  /* status */     \
  { 0 },                                  /* offset */     \
  0                                      /* reserved */    \
}


/**
 * @brief The number of supported instances of each ref source type
 *
 * @note This structure is only supported if bit GPS_HAS_XMRS_MULT_INSTC
 * is set in RECEIVER_INFO::features.
 */
typedef struct
{
  uint32_t flags;               /**< currently always 0 */
  uint16_t n_xmr_settings;      /**< number of configurable multi ref settings */
  uint8_t  slot_id;             /**< current slot ID of board ( 0..15 ) */
  uint8_t  reserved;            /**< reserved */
  uint8_t  n_inst[32];          /**< N_MULTI_REF entries used, but can not exceed bit number of uint32_t - 1 */
} XMULTI_REF_INSTANCES;

/** @} group_xmr_cfg */



/**
 * @defgroup group_gpio GPIO port configuration stuff
 *
 * @{ */

/**
 * @brief General GPIO config info to be read from a device
 */
typedef struct
{
  uint32_t num_io;     /**< number of supported GPIO ports */
  uint32_t reserved;   /**< currently always 0 */
  uint32_t flags;      /**< currently always 0 */

} MBG_GPIO_CFG_LIMITS;



/**
 * @brief A structure used to specify a variable frequency
 */
typedef struct
{
  uint32_t hz;      /**< integral number, Hz */
  uint32_t frac;    /**< fractional part, binary */

} MBG_GPIO_FREQ;


/**
 * @brief A structure used to specify a fixed frequency
 */
typedef struct
{
  uint32_t frq_bit;               /**< fixed freq. bit mask ( see enum ) */
  uint32_t reserved;               /**< reserved */

} MBG_GPIO_FIXED_FREQ;


/**
 * @brief A structure used to specify a framed datastream
 */
typedef struct
{
  uint32_t format;                   /**< format bit mask ( see enum and bit mask ! ) */
  uint32_t reserved;                 /**< reserved */

} MBG_GPIO_BITS;

/**
 * @brief A structure used to configure a GPIO as frequency output
 */
typedef struct
{
  MBG_GPIO_FREQ freq;    /**< frequency */
  int32_t milli_phase;   /**< phase [1/1000 degree units] */
  uint32_t type;         /**< sine, rectangle, etc. */  //##++++++++++++++
  uint32_t reserved;     /**< currently always 0 */
  uint32_t flags;        /**< currently always 0 */

} MBG_GPIO_FREQ_OUT_SETTINGS;


/**
 * @brief A structure used to configure a GPIO as frequency output
 */

typedef struct
{
  MBG_GPIO_FREQ freq;       /**< frequency */
  uint32_t csc_limit;       /**< max. cycle slip [1/1000 cycle units] */
  uint32_t type;            /**< sine, rectangle, etc. */  //##++++++++++++++
  uint32_t reserved;        /**< currently always 0 */
  uint32_t flags;           /**< currently always 0 */

} MBG_GPIO_FREQ_IN_SETTINGS;



/**
 * @brief A structure used to configure a GPIO as fixed frequency output
 */
typedef struct
{
  MBG_GPIO_FIXED_FREQ freq;    /**< frequency */
  uint32_t reserved_0;         /**< supported frequencies bit mask, see enum */
  uint32_t type;               /**< sine, rectangle, etc. */  //##++++++++++++++
  uint32_t reserved_1;         /**< currently always 0 */
  uint32_t flags;              /**< currently always 0 */

} MBG_GPIO_FIXED_FREQ_OUT_SETTINGS;


/**
 * @brief A structure used to configure a GPIO as BITS module
 */

typedef struct
{
  MBG_GPIO_BITS bits;              /**< DS Settings for building integrated timing supply */
  uint32_t  csc_limit;             /**< max. cycle slip [1/1000 cycle units] */

  union
  {
    struct
    {
      uint8_t  ssm;                /**< minimum E1 SSM ( 0...15 ) for acceptance */ 
      uint8_t  sa_bits;            /**< Sa Bits group ( 4...8 ) carrying SSM */
      uint16_t reserve;
    } e1;

    struct
    {
      uint8_t  min_boc;
      uint8_t  reserve_0;
      uint16_t reserve_1;
    } t1;

    uint32_t u32;
  } quality;

  uint32_t  err_msk;               /**< error mask msk, see enum */
  uint32_t  flags;                 /**< currently always 0 */
} MBG_GPIO_BITS_IN_SETTINGS;


/**
 * @brief A structure used to configure a GPIO port
 */
typedef struct
{
  uint32_t mode;           /** frequency out, frequency in, pulse out, etc. */
  uint32_t reserved;       /**< currently always 0 */
  uint32_t flags;          /**< currently always 0 */

  union
  {
    MBG_GPIO_FREQ_OUT_SETTINGS        freq_out;           /** if type is frequency output */
    MBG_GPIO_FREQ_IN_SETTINGS         freq_in;            /** if type is frequency input */
    MBG_GPIO_FIXED_FREQ_OUT_SETTINGS  ff_out;             /** if type is fixed frequency output */
    MBG_GPIO_BITS_IN_SETTINGS         bits_in;            /** if type is framed ds. in */
  } u;

} MBG_GPIO_SETTINGS;


/**
 * @brief A structure used to describe a GPIO ports limiting values
 */
typedef struct
{
  uint32_t supp_modes;          /**< supported modes */
  uint32_t reserved;
  uint32_t supp_flags;          /**< supported flags */

  union
  {
    MBG_GPIO_FREQ_OUT_SETTINGS       freq_out;      /** max. freq. values for output */
    MBG_GPIO_FREQ_IN_SETTINGS        freq_in;       /** max. freq. values for input  */
    MBG_GPIO_FIXED_FREQ_OUT_SETTINGS ff_out;        /** max. ff values for output */
    MBG_GPIO_BITS_IN_SETTINGS        bits_in;       /** if type is framed ds. in */
  } u;

} MBG_GPIO_LIMITS;



/**
 * @brief A structure used to configure a specific GPIO port
 */
typedef struct
{
  uint32_t idx;                /**< port number, 0..(MBG_GPIO_CFG_LIMITS::num_io - 1) */
  MBG_GPIO_SETTINGS settings;  /**< configuration settings */

} MBG_GPIO_SETTINGS_IDX;



/**
 * @brief A structure used query the current GPIO port settings and capabilities
 */
typedef struct
{
  MBG_GPIO_SETTINGS settings;   /**< current configuration */
  MBG_GPIO_LIMITS   limits;     /**< supp. and max. values */
} MBG_GPIO_INFO;



/**
 * @brief A structure used to query configuration and capabilities of a specific GPIO port
 */
typedef struct
{
  uint32_t idx;          /**< port number, 0..(MBG_GPIO_CFG_LIMITS::num_io - 1) */
  MBG_GPIO_INFO info;    /**< current settings and capabilities of this GPIO port */
} MBG_GPIO_INFO_IDX;



/**
 * @brief Definitions for MBG_GPIO_SETTINGS::mode
 */
enum
{
  MBG_GPIO_SIGNAL_TYPE_FREQ_OUT,         /**< variable frequency output */
  MBG_GPIO_SIGNAL_TYPE_FREQ_IN,          /**< variable frequency inputs */
  MBG_GPIO_SIGNAL_TYPE_FIXED_FREQ_OUT,   /**< fixed frequency outputs */
  MBG_GPIO_SIGNAL_TYPE_FIXED_FREQ_IN,    /**< fixed frequency input */
  MBG_GPIO_SIGNAL_TYPE_BITS_OUT,         /**< framed data stream output */
  MBG_GPIO_SIGNAL_TYPE_BITS_IN,          /**< framed data stream input */
  N_MBG_GPIO_SIGNAL_TYPES                /**< number of known modes */
};



/**
 * @brief Definitions for MBG_GPIO_FF_OUT_SETTINGS::frq_bit
 */
enum
{
  MBG_GPIO_FIXED_FREQ_8kHz,            /**< 8kHz */
  MBG_GPIO_FIXED_FREQ_48kHz,           /**< 48kHz */
  MBG_GPIO_FIXED_FREQ_1MHz,            /**< 1MHz */
  MBG_GPIO_FIXED_FREQ_1544kHz,         /**< 1.544MHz */
  MBG_GPIO_FIXED_FREQ_2048kHz,         /**< 2.048MHz */
  MBG_GPIO_FIXED_FREQ_5MHz,            /**< 5MHz */
  MBG_GPIO_FIXED_FREQ_10MHz,           /**< 10MHz */
  MBG_GPIO_FIXED_FREQ_19440kHz,        /**< 19.44MHz */
  N_MBG_GPIO_FIXED_FREQ                /**< number of known frequencies */
};

/**< Bit Masks to be used with MBG_GPIO_FF_OUT_SETTINGS::frq_bit */
#define MSK_MBG_GPIO_FIXED_FREQ_8kHz       ( 1UL << MBG_GPIO_FIXED_FREQ_8kHz )
#define MSK_MBG_GPIO_FIXED_FREQ_48kHz      ( 1UL << MBG_GPIO_FIXED_FREQ_48kHz )
#define MSK_MBG_GPIO_FIXED_FREQ_1MHz       ( 1UL << MBG_GPIO_FIXED_FREQ_1MHz )
#define MSK_MBG_GPIO_FIXED_FREQ_1544kHz    ( 1UL << MBG_GPIO_FIXED_FREQ_1544kHz )
#define MSK_MBG_GPIO_FIXED_FREQ_2048kHz    ( 1UL << MBG_GPIO_FIXED_FREQ_2048kHz )
#define MSK_MBG_GPIO_FIXED_FREQ_5MHz       ( 1UL << MBG_GPIO_FIXED_FREQ_5MHz )
#define MSK_MBG_GPIO_FIXED_FREQ_10MHz      ( 1UL << MBG_GPIO_FIXED_FREQ_10MHz )
#define MSK_MBG_GPIO_FIXED_FREQ_19440kHz   ( 1UL << MBG_GPIO_FIXED_FREQ_19440kHz )

/*
 * Initializers for GPIO fixed frequency strings.
 */
#define MBG_GPIO_FIXED_FREQ_STRS \
{                                \
  "8kHz",                        \
  "48kHz",                       \
  "1MHz",                        \
  "1544kHz",                     \
  "2048kHz",                     \
  "5MHz",                        \
  "10MHz",                       \
  "19440kHz"                     \
}


/**
 * @brief Definitions for MBG_GPIO_BITS::format
 */
enum
{
  MBG_GPIO_BITS_E1_FRAMED,              /**< 2.048MBit */
  MBG_GPIO_BITS_T1_FRAMED,              /**< 1.544MBit */
  MBG_GPIO_BITS_E1_TIMING,              /**< 2.048MHz  */
  MBG_GPIO_BITS_T1_TIMING,              /**< 2.048MHz  */
  N_MBG_GPIO_BITS                       /**< number of formats */
};

#define MSK_MBG_GPIO_BITS_E1_FRAMED   ( 1UL << MBG_GPIO_BITS_E1_FRAMED )
#define MSK_MBG_GPIO_BITS_T1_FRAMED   ( 1UL << MBG_GPIO_BITS_T1_FRAMED )
#define MSK_MBG_GPIO_BITS_E1_TIMING   ( 1UL << MBG_GPIO_BITS_E1_TIMING )
#define MSK_MBG_GPIO_BITS_T1_TIMING   ( 1UL << MBG_GPIO_BITS_T1_TIMING )


/**
 * @brief Definitions for MBG_GPIO_BITS_IN_SETTINGS::quality.err
 */
enum
{
  MBG_GPIO_BITS_ERR_LOS,                /**< loss of signal error */
  MBG_GPIO_BITS_ERR_LOF,                /**< loss of frame */
  N_MBG_GPIO_BITS_ERR                   /**< number of formats */
};

#define MSK_MBG_GPIO_BITS_ERR_LOS    ( 1UL << MBG_GPIO_BITS_ERR_LOS )
#define MSK_MBG_GPIO_BITS_ERR_LOF    ( 1UL << MBG_GPIO_BITS_ERR_LOF )


/** @} group_gpio */


/**
 * @defgroup group_evt_log Event logging support
 *
 * @note This is only available if GPS_HAS_EVT_LOG is set in RECEIVER_INFO::features.
 *
 * @{ */

/** @brief Number of event log entries that can be stored and yet have been saved */
typedef struct
{
  uint32_t used;     /**< current number of saved log entries */
  uint32_t max;      /**< max number of log entries which can be saved */
} MBG_NUM_EVT_LOG_ENTRIES;

#define _mbg_swab_mbg_num_evt_log_entries( _p ) \
{                                               \
  _mbg_swab32( &(_p)->used );                   \
  _mbg_swab32( &(_p)->max );                    \
}


typedef uint16_t MBG_EVT_CODE;
#define _mbg_swab_evt_code( _p ) _mbg_swab16( _p );

typedef uint16_t MBG_EVT_INFO;
#define _mbg_swab_evt_info( _p ) _mbg_swab16( _p );

/** @brief An event log entry */
 typedef struct
 {
   uint32_t time;       /**< like time_t, seconds since 1970 */
   MBG_EVT_CODE code;   /**< event ID or'ed with severity level */
   MBG_EVT_INFO info;   /**< optional event info, depending on event ID */
 } MBG_EVT_LOG_ENTRY;

#define _mbg_swab_mbg_evt_log_entry( _p ) \
{                                         \
  _mbg_swab32( &(_p)->time );             \
  _mbg_swab_evt_code( &(_p)->code );      \
  _mbg_swab_evt_info( &(_p)->info );      \
}


// MBG_EVT_LOG_ENTRY::code is a combination of some bits used for the ID,
// plus some bits used for the severity/level. The sum of bits must not
// exceed (8 * sizeof MBG_EVT_LOG_ENTRY::code):

#define MBG_EVT_ID_BITS      13
#define MBG_EVT_LVL_BITS     3

#define MBG_EVT_ID_MASK      ( ( 1UL << MBG_EVT_ID_BITS ) - 1 )
#define MBG_EVT_LVL_MASK     ( ( 1UL << MBG_EVT_LVL_BITS ) - 1 )


// Combine an ID and Level to a code which can be stored
// in the code field:
#define _mbg_mk_evt_code( _id, _lvl ) \
  ( (MBG_EVT_CODE) ( (MBG_EVT_CODE)(_id) | ( (MBG_EVT_CODE)(_lvl) << MBG_EVT_ID_BITS ) ) )

// Extract the event ID from the code field:
#define _mbg_get_evt_id( _code ) \
  ( (_code) & MBG_EVT_ID_MASK )

// Extract the severity level from the code field:
#define _mbg_get_evt_lvl( _code ) \
  ( ( (_code) >> MBG_EVT_ID_BITS ) & MBG_EVT_LVL_MASK )


/** @brief Enumeration of event IDs */
enum
{
  MBG_EVT_ID_NONE,          /**< no event (empty entry) */
  MBG_EVT_ID_POW_UP_RES,    /**< power up reset */
  MBG_EVT_ID_WDOG_RES,      /**< watchdog reset */
  MBG_EVT_ID_COLD_BOOT,     /**< entering cold boot mode */
  MBG_EVT_ID_WARM_BOOT,     /**< entering warm boot mode */
  MBG_EVT_ID_NORMAL_OP,     /**< entering normal operation */
  MBG_EVT_ID_ANT_DISCONN,   /**< antenna disconnect detected */
  MBG_EVT_ID_ANT_SHORT,     /**< antenna short circuit detected */
  MBG_EVT_ID_ANT_OK,        /**< antenna OK after failure */
  MBG_EVT_ID_LOW_SATS,      /**< no satellites can be received though antenna not failing */
  N_MBG_EVT_ID
};


#define ENG_EVT_ID_NAME_NONE          "No event"
#define ENG_EVT_ID_NAME_POW_UP_RES    "Power Up Reset"
#define ENG_EVT_ID_NAME_WDOG_RES      "Watchdog Reset"
#define ENG_EVT_ID_NAME_COLD_BOOT     "Cold Boot"
#define ENG_EVT_ID_NAME_WARM_BOOT     "Warm Boot"
#define ENG_EVT_ID_NAME_NORMAL_OP     "Normal Operation"
#define ENG_EVT_ID_NAME_ANT_DISCONN   "Antenna Disconn."
#define ENG_EVT_ID_NAME_ANT_SHORT     "Ant. Short-Circ."
#define ENG_EVT_ID_NAME_ANT_OK        "Antenna OK"
#define ENG_EVT_ID_NAME_LOW_SATS      "Few Sats Only"


#define MBG_EVT_ID_NAMES_ENG    \
{                               \
  ENG_EVT_ID_NAME_NONE,         \
  ENG_EVT_ID_NAME_POW_UP_RES,   \
  ENG_EVT_ID_NAME_WDOG_RES,     \
  ENG_EVT_ID_NAME_COLD_BOOT,    \
  ENG_EVT_ID_NAME_WARM_BOOT,    \
  ENG_EVT_ID_NAME_NORMAL_OP,    \
  ENG_EVT_ID_NAME_ANT_DISCONN,  \
  ENG_EVT_ID_NAME_ANT_SHORT,    \
  ENG_EVT_ID_NAME_ANT_OK,       \
  ENG_EVT_ID_NAME_LOW_SATS      \
}



/** @brief Enumeration of event severity levels */
enum
{
  MBG_EVT_LVL_NONE,
  MBG_EVT_LVL_DEBUG,
  MBG_EVT_LVL_INFO,
  MBG_EVT_LVL_WARN,
  MBG_EVT_LVL_ERR,
  MBG_EVT_LVL_CRIT,
  N_MBG_EVT_LVL
};


#define ENG_EVT_LVL_NAME_NONE    "None"
#define ENG_EVT_LVL_NAME_DEBUG   "Debug"
#define ENG_EVT_LVL_NAME_INFO    "Info"
#define ENG_EVT_LVL_NAME_WARN    "Warn"
#define ENG_EVT_LVL_NAME_ERR     "Err"
#define ENG_EVT_LVL_NAME_CRIT    "Crit."


#define MBG_EVT_LVL_NAMES_ENG \
{                             \
  ENG_EVT_LVL_NAME_NONE,      \
  ENG_EVT_LVL_NAME_DEBUG,     \
  ENG_EVT_LVL_NAME_INFO,      \
  ENG_EVT_LVL_NAME_WARN,      \
  ENG_EVT_LVL_NAME_ERR,       \
  ENG_EVT_LVL_NAME_CRIT       \
}


/** @brief Predefined event codes with associated severity levels */

#define MBG_EVT_NONE         _mbg_mk_evt_code( MBG_EVT_ID_NONE, MBG_EVT_LVL_NONE )
#define MBG_EVT_POW_UP_RES   _mbg_mk_evt_code( MBG_EVT_ID_POW_UP_RES, MBG_EVT_LVL_WARN )
#define MBG_EVT_WDOG_RES     _mbg_mk_evt_code( MBG_EVT_ID_WDOG_RES, MBG_EVT_LVL_CRIT )
#define MBG_EVT_COLD_BOOT    _mbg_mk_evt_code( MBG_EVT_ID_COLD_BOOT, MBG_EVT_LVL_ERR )
#define MBG_EVT_WARM_BOOT    _mbg_mk_evt_code( MBG_EVT_ID_WARM_BOOT, MBG_EVT_LVL_ERR )
#define MBG_EVT_NORMAL_OP    _mbg_mk_evt_code( MBG_EVT_ID_NORMAL_OP, MBG_EVT_LVL_INFO )
#define MBG_EVT_ANT_DISCONN  _mbg_mk_evt_code( MBG_EVT_ID_ANT_DISCONN, MBG_EVT_LVL_CRIT )
#define MBG_EVT_ANT_SHORT    _mbg_mk_evt_code( MBG_EVT_ID_ANT_SHORT, MBG_EVT_LVL_CRIT )
#define MBG_EVT_ANT_OK       _mbg_mk_evt_code( MBG_EVT_ID_ANT_OK, MBG_EVT_LVL_INFO )
#define MBG_EVT_LOW_SATS     _mbg_mk_evt_code( MBG_EVT_ID_LOW_SATS, MBG_EVT_LVL_WARN )


/** @} group_evt_log */


/**
 * @defgroup group_generic_io Generic I/O support.
 *
 * The definitions below are used with the GENERIC_IO API.
 *
 * This API is <b>NOT</b> supported by all devices, it depends on
 * the type of the device, and the firmware version. The macro
 * _pcps_has_generic_io() or the corresponding function
 * mbg_dev_has_generic_io() should be used by applications to
 * check whether a particular bus-level device supports this.
 * @{ */


typedef uint16_t GEN_IO_INFO_TYPE;

#define _mbg_swab_gen_io_info_type( _p )  \
  _mbg_swab16( _p )



/**
 * @brief The data structure used with the PCPS_GEN_IO_GET_INFO command
 *
 * type specifier in order to query from a device which of the other 
 * specified types is supported, and how many data sets are being 
 * used by the device. The GEN_IO_INFO_TYPE must be passed to the 
 * call which returns a GEN_IO_INFO structure filled by the device.
 */
typedef struct
{
  GEN_IO_INFO_TYPE type;  // a PCPS_GEN_IO_GET_INFO type from the enum above
  uint16_t num;           // supported number of data sets of the specified type

} GEN_IO_INFO;

#define _mbg_swab_gen_io_info( _p )           \
{                                             \
  _mbg_swab_gen_io_info_type( &(_p)->type );  \
  _mbg_swab16( &(_p)->num );                  \
}



/**
 * @brief Data types used with GEN_IO_INFO::type
 *
 * The first type specifier, PCPS_GEN_IO_GET_INFO, can
 * be used to find out which of the other data types are
 * supported, and how many data sets of the specified type
 * are supported by a device.
 */
enum
{
  PCPS_GEN_IO_GET_INFO,              /**< GEN_IO_INFO (read only) */
  PCPS_GEN_IO_CAL_REC_IRIG_RX_COMP,  /**< CAL_REC_IRIG_RX_COMP (read/write) */
  N_PCPS_GEN_IO_TYPE                 /**< number of known types */
};

/**  @} group_generic_io */


/*------------------------------------------------------------------------*/

/*
 * The types below are not used with all devices:
 */

typedef uint16_t ROM_CSUM;      /* The ROM checksum */
typedef uint16_t RCV_TIMEOUT;   /* [min] (only if HAS_RCV_TIMEOUT) */
typedef uint16_t IGNORE_LOCK;   /* (only if GPS_HAS_IGNORE_LOCK) */

/*
 * Originally IGNORE_LOG above has been a boolean value (equal or
 * not equal 0) which was evaluated the same way for all ports.
 *
 * Due to special firmware requirements it has been changed to a
 * bit maskable property in order to be able to specify the behaviour
 * for individual ports.
 *
 * In order to keep compatibility with older versions the LSB is used
 * to specify ignore_lock for all ports. The next higher bits are used
 * to specify ignore_lock for an individual port, where the bit position
 * depends on the port number, e.g. 0x02 for COM0, 0x04 for COM1, etc.
 * The macros below can be used to simplify the code:
 */

/* return a bit mask depending on the port number */
#define IGNORE_LOCK_FOR_ALL_PORTS            0x01

#define _ignore_lock_for_all_ports()         ( IGNORE_LOCK_FOR_ALL_PORTS )

#define _ignore_lock_for_port( _n )          ( 0x02 << (_n) )

/* check if all ports are ignore_lock'ed */
#define _is_ignore_lock_all_ports( _il )     ( (_il) & IGNORE_LOCK_FOR_ALL_PORTS )

/* check if a specific port is ignore_lock'ed */
#define _is_ignore_lock_for_port( _il, _n ) \
        ( (_il) & ( _ignore_lock_for_port(_n) | IGNORE_LOCK_FOR_ALL_PORTS ) )


/*------------------------------------------------------------------------*/

/*
 * The structures below are used with the SCU multiplexer board
 * in a redundant system:
 */

typedef struct
{
  uint32_t hw_id;                // hardware identification
  uint32_t fw_id;                // firmware identification
  uint16_t flags;                // reserved currently 0
  uint8_t  clk0_info;            // reference clock 0 type
  uint8_t  clk1_info;            // reference clock 1 type
  uint16_t epld_status;          // epld status word, see defintions below
  uint16_t epld_control;         // epld control word, see defintions below
} SCU_STAT_INFO;

typedef struct
{
  uint16_t epld_control_mask;    // control mask, determines which bit is to be changed
  uint16_t epld_control_value;   // control value, determines value of bits to be changed
  uint32_t flags;                // reserved, currently 0
} SCU_STAT_SETTINGS;

// definitions for status word bit masks
#define MSK_EPLD_STAT_TS1          0x0001   // state of time sync signal clk_1
#define MSK_EPLD_STAT_TS2          0x0002   // state of time sync signal clk_2
#define MSK_EPLD_STAT_TL_ERROR     0x0004   // state of time limit error input
#define MSK_EPLD_STAT_PSU1_OK      0x0008   // state of power supply 1 monitoring input
#define MSK_EPLD_STAT_PSU2_OK      0x0010   // state of power supply 2 monitoring input
#define MSK_EPLD_STAT_AUTO         0x0020   // AUTOMATIC/REMOTE or MANUAL Mode
#define MSK_EPLD_STAT_SEL          0x0040   // select bit for output MUX, ( clk_1 = 0 )
#define MSK_EPLD_STAT_ENA          0x0080   // enable Bit for output MUX, set if enabled
#define MSK_EPLD_STAT_ACO          0x4000   // Access control override bit
#define MSK_EPLD_STAT_WDOG_OK      0x8000   // WDT_OK set to zero if watchdog expired


#define MSK_EPLD_CNTL_SEL_REM      0x0800   // remote select for output MUX ( clk_1 = 0 )
#define MSK_EPLD_CNTL_DIS_REM      0x1000   // remote disable for output MUX
#define MSK_EPLD_CNTL_REMOTE       0x2000   // must be set to enable remote operation
#define MSK_EPLD_CNTL_SEL_SNMP     0x4000   // connect COM0 channels to XPORT
#define MSK_EPLD_CNTL_ENA_SNMP     0x8000   // select clk for comm. ( clk1 = 0 )


/*
 * Definitions for clk0_info and clk1_info, can be used to determine
 * the reference clock type connected to SCU input channel 0 and 1:
 */
enum
{
 SCU_CLK_INFO_GPS,                // ref. clock is GPS receiver
 SCU_CLK_INFO_DCF_PZF,            // ref. clock is DCF77 PZF receiver
 SCU_CLK_INFO_DCF_AM,             // ref. clock is DCF77 AM receiver
 SCU_CLK_INFO_TCR                 // ref. clock is IRIG time code receiver
};



/*------------------------------------------------------------------------*/

/**
 * @brief Satellite receiver modes of operation.
 *
 * @note Some of the code combinations are obsolete with recent
 * satellite receivers. However, this doesn't matter since the mode
 * is just read from the receiver.
 */
#define REMOTE    0x10
#define BOOT      0x20

#define TRACK     ( 0x01 )
#define AUTO_166  ( 0x02 )
#define WARM_166  ( 0x03          | BOOT )
#define COLD_166  ( 0x04          | BOOT )
#define AUTO_BC   ( 0x05 | REMOTE )
#define WARM_BC   ( 0x06 | REMOTE | BOOT )
#define COLD_BC   ( 0x07 | REMOTE | BOOT )
#define UPDA_166  ( 0x08          | BOOT )
#define UPDA_BC   ( 0x09 | REMOTE | BOOT )



typedef int16_t DAC_VAL;

#define _mbg_swab_dac_val( _p ) \
  _mbg_swab16( _p );



/**
 * @brief Satellite receiver status information
 */
typedef struct
{
  uint16_t mode;          /**< Mode of operation, see predefined codes */
  uint16_t good_svs;      /**< Numb. of satellites that can currently be received and used */
  uint16_t svs_in_view;   /**< Numb. of satellites that should be in view according to the almanac data */
  DAC_VAL dac_val;        /**< Oscillator fine DAC value */
  DAC_VAL dac_cal;        /**< Oscillator calibration DAC value ( see #OSC_DAC_RANGE, #OSC_DAC_BIAS ) */
} STAT_INFO;

#define _mbg_swab_stat_info( _p )      \
{                                      \
  _mbg_swab16( &(_p)->mode );          \
  _mbg_swab16( &(_p)->good_svs );      \
  _mbg_swab16( &(_p)->svs_in_view );   \
  _mbg_swab_dac_val( &(_p)->dac_val ); \
  _mbg_swab_dac_val( &(_p)->dac_cal ); \
}


#define OSC_DAC_RANGE     4096UL
#define OSC_DAC_BIAS      ( OSC_DAC_RANGE / 2 )



/**
 * @brief An enumeration of known satellite navigation systems
 */
enum
{
  GNSS_TYPE_GPS,      /**< GPS, United States */
  GNSS_TYPE_GLONASS,  /**< GLONASS, Russia */
  GNSS_TYPE_BEIDOU,   /**< BEIDOU, China */
  GNSS_TYPE_GALILEO,  /**< GALILEO, Europe */
  N_GNSS_TYPES        /**< Number of defined codes */
};

#define GNSS_TYPE_STRS \
{                      \
  "GPS",               \
  "GLONASS",           \
  "BEIDOU" ,           \
  "GALILEO"            \
}

#define MBG_GNSS_TYPE_MSK_GPS      ( 1UL << GNSS_TYPE_GPS )
#define MBG_GNSS_TYPE_MSK_GLONASS  ( 1UL << GNSS_TYPE_GLONASS )
#define MBG_GNSS_TYPE_MSK_BEIDOU   ( 1UL << GNSS_TYPE_BEIDOU )
#define MBG_GNSS_TYPE_MSK_GALILEO  ( 1UL << GNSS_TYPE_GALILEO )


#define N_GNSS_MODE_PRIO  8

typedef struct
{
  uint32_t gnss_set;                /**< current set of GNSS types */
  uint8_t  prio[N_GNSS_MODE_PRIO];  /**< index 0 for highest priority, use GNSS enumeration above, init with 0xFF if not supported */
  uint32_t flags;                   /**< see below */
} MBG_GNSS_MODE_SETTINGS;

#define _mbg_swab_mbg_gnss_mode_settings( _p ) \
{                                              \
  _mbg_swab32( &(_p)->gnss_set );              \
  _mbg_swab32( &(_p)->flags );                 \
}



typedef struct
{
  MBG_GNSS_MODE_SETTINGS settings;      /**< current GNSS mode settings */
  uint32_t supp_gnss_types;             /**< bit masks of supported GNSS types */
  uint32_t flags;                       /**< indicates which of the defined flags are supported by the device */
} MBG_GNSS_MODE_INFO;

#define _mbg_swab_mbg_gnss_mode_info( _p )              \
{                                                       \
  _mbg_swab_mbg_gnss_mode_settings( &(_p)->settings );  \
  _mbg_swab32( &(_p)->supp_gnss_types );                \
  _mbg_swab32( &(_p)->flags );                          \
}


/**
 * @brief Flags used with MBG_GNSS_MODE_SETTINGS::flags and MBG_GNSS_MODE_INFO::flags
 */
enum
{
  MBG_GNSS_FLAG_EXCLUSIVE,      /**< (read only) only one of the supported GNSS systems can be used at the same time */
  MBG_GNSS_FLAG_HAS_PRIORITY,   /**< (read only) priority can be configured using the MBG_GNSS_MODE_SETTINGS::prio field */
  N_MBG_GNSS_FLAGS
};

#define MBG_GNSS_FLAG_MSK_EXCLUSIVE     ( 1UL << MBG_GNSS_FLAG_EXCLUSIVE )
#define MBG_GNSS_FLAG_MSK_HAS_PRIORITY  ( 1UL << MBG_GNSS_FLAG_HAS_PRIORITY )



#define MAX_USED_SATS 32

/**
 * @brief SV information from a certain GNSS type.
 */
typedef struct
{
  uint8_t  gnss_type;           /**< GNSS type from the enumeration above */
  uint8_t  reserved;
  uint16_t good_svs;
  uint16_t svs_in_view;
  uint8_t  svs[MAX_USED_SATS];
} GNSS_SAT_INFO;

#define _mbg_swab_gnss_sat_info( _p )  \
{                                      \
  _mbg_swab16( &(_p)->good_svs );      \
  _mbg_swab16( &(_p)->svs_in_view );   \
}


#ifndef _IDENT_DEFINED

  typedef union
  {
    char c[16];       // as string which may NOT be terminated
    int16_t wrd[8];
    uint32_t lw[4];
  } IDENT;

  #define _IDENT_DEFINED
#endif

#define _mbg_swab_ident( _p )     \
{                                 \
  int i;                          \
  for ( i = 0; i < 4; i++ )       \
    _mbg_swab32( &(_p)->lw[i] );  \
}

/**
 * @brief A data type used to configure the length of an antenna cable [m]
 */
typedef uint16_t ANT_CABLE_LEN;

#define _mbg_swab_ant_cable_len( _p )    _mbg_swab16( _p )



/**
 * @defgroup group_ip4_cfg Simple configuration and status
 * of an optional LAN interface.
 *
 * @note This is only supported if the flag GPS_HAS_LAN_IP4 is set
 * in RECEIVER_INFO::features.
 *
 * @{ */


/**
 * @brief An IPv4 address
 */
typedef uint32_t IP4_ADDR;

#define _mbg_swab_ip4_addr( _p ) \
  _mbg_swab32( _p );


/**
 * @brief Settings of an IPv4 network interface
 */
typedef struct
{
  IP4_ADDR ip_addr;      /**< the IP address */
  IP4_ADDR netmask;      /**< the network mask */
  IP4_ADDR broad_addr;   /**< the broadcast address */
  IP4_ADDR gateway;      /**< the default gateway */
  uint16_t flags;        /**< flags as specified below */
  uint16_t vlan_cfg;     /**< VLAN configuration, see below */

} IP4_SETTINGS;

#define _mbg_swab_ip4_settings( _p )       \
{                                          \
  _mbg_swab_ip4_addr( &(_p)->ip_addr );    \
  _mbg_swab_ip4_addr( &(_p)->netmask );    \
  _mbg_swab_ip4_addr( &(_p)->broad_addr ); \
  _mbg_swab_ip4_addr( &(_p)->gateway );    \
  _mbg_swab16( &(_p)->flags );             \
  _mbg_swab16( &(_p)->vlan_cfg );          \
}


/**
 * @brief Definitions used with IP4_SETTINGS::vlan_cfg
 *
 * @note IP4_SETTINGS::vlan_cfg contains a combination of
 * a VLAN ID number plus a VLAN priority code.
 */
#define VLAN_ID_BITS        12                        //< number of bits to hold the ID
#define N_VLAN_ID           ( 1 << VLAN_ID_BITS )     //< number of ID values
#define MIN_VLAN_ID         0                         //< minimum ID value
#define MAX_VLAN_ID         ( N_VLAN_ID - 1 )         //< maximum ID value

// vlan_id = ( vlan_cfg >> VLAN_ID_SHIFT ) & VLAN_ID_MSK
#define VLAN_ID_SHIFT       0
#define VLAN_ID_MSK         ( ( 1 << VLAN_ID_BITS ) - 1 )


#define VLAN_PRIORITY_BITS  3                             //< number of bits to hold priority
#define N_VLAN_PRIORITY     ( 1 << VLAN_PRIORITY_BITS )   //< number of priority values
#define MIN_VLAN_PRIORITY   0                             //< minimum priority
#define MAX_VLAN_PRIORITY   ( N_VLAN_PRIORITY - 1 )       //< maximum priority

// vlan_priority = ( vlan_cfg >> VLAN_PRIORITY_SHIFT ) & VLAN_PRIORITY_MSK
#define VLAN_PRIORITY_SHIFT ( ( 8 * sizeof( uint16_t ) ) - VLAN_PRIORITY_BITS )
#define VLAN_PRIORITY_MSK   ( ( 1 << VLAN_PRIORITY_BITS ) - 1 )

/**
 * @brief Macros used to encode/decode packed vlan_cfg variables
 */
#define _decode_vlan_id( _cfg )         ( ( (_cfg) >> VLAN_ID_SHIFT ) & VLAN_ID_MSK )
#define _decode_vlan_priority( _cfg )   ( ( (_cfg) >> VLAN_PRIORITY_SHIFT ) & VLAN_PRIORITY_MSK )
#define _encode_vlan_cfg( _id, _prty )  ( ( (_id) << VLAN_ID_SHIFT ) | ( (_prty) << VLAN_PRIORITY_SHIFT ) )


#if 0  //##++ currently not used

/* Misc configuration */

typedef struct
{
  uint16_t id;     /* service ID, see below */
  uint16_t index;  /* used if several same svcs must be cfg'd, e.g. DNS */
  char host[50];   /* see below */

} IP_CFG;



/* Description of a service running on a device */

typedef struct
{
  uint16_t id;     /* service ID, see below */
  uint16_t socket; /* the socket on which the service is listening */
  uint32_t flags;  /* see below */

} IP_SERVICE;

#endif  // 0



/**
 * @brief LAN interface information
 *
 * This structure can be retrieved from a device
 * to check the device's capabilities.
 */
typedef struct
{
  uint16_t type;                 //< type of LAN interface, see below
  uint8_t mac_addr[6];           //< MAC address
  uint16_t ver_code;             //< version number, high byte.low byte, in hex
  char ver_str[GPS_ID_STR_SIZE]; //< version string
  char sernum[GPS_ID_STR_SIZE];  //< serial number
  uint32_t rsvd_0;               //< reserved, currently always 0
  uint16_t flags;                //< flags as specified below
  uint16_t rsvd_1;               //< reserved, currently always 0

} LAN_IF_INFO;

#define _mbg_swab_lan_if_info( _p )  \
{                                    \
  _mbg_swab16( &(_p)->type );        \
  _mbg_swab16( &(_p)->ver_code );    \
  _mbg_swab32( &(_p)->rsvd_0 );      \
  _mbg_swab16( &(_p)->flags );       \
  _mbg_swab16( &(_p)->rsvd_1 );      \
}



/**
 * @brief Codes used with LAN_IF_INFO::type
 */
enum
{
  LAN_IF_TYPE_XPORT,    //< LAN interface on an XPORT
  LAN_IF_TYPE_PTP,      //< LAN interface is a special PTP interface
  N_LAN_IF_TYPE         //< number of defined LAN interface types
};


/**
 * @brief Flags used with IP4_SETTINGS::flags and LAN_IF_INFO::flags
 */
enum
{
  IP4_BIT_DHCP,  //< DHCP supported (LAN_IF_INFO) / enabled (IP4_SETTINGS)
  IP4_BIT_LINK,  //< used only in IP4_SETTINGS to report link state
  IP4_BIT_VLAN,  //< VLAN supported (LAN_IF_INFO) / enabled (IP4_SETTINGS)
  N_IP4_BIT      //< number of defined flag bits
};

#define IP4_MSK_DHCP   ( 1UL << IP4_BIT_DHCP )
#define IP4_MSK_LINK   ( 1UL << IP4_BIT_LINK )
#define IP4_MSK_VLAN   ( 1UL << IP4_BIT_VLAN )

/** @} group_ip4_cfg */



/**
 * @defgroup group_ptp Definitions used with PTP/IEEE1588
 *
 * @{ */

/**
 * @brief Enumeration of protocols possibly used with PTP
 */
enum
{
  PTP_NW_PROT_BIT_RESERVED,      //< reserved
  PTP_NW_PROT_BIT_UDP_IPV4,      //< IPv4
  PTP_NW_PROT_BIT_UDP_IPV6,      //< IPv6
  PTP_NW_PROT_BIT_IEEE_802_3,    //< Ethernet (raw layer 2)
  PTP_NW_PROT_BIT_DEVICE_NET,    //< DeviceNet
  PTP_NW_PROT_BIT_CONTROL_NET,   //< ControlNet
  PTP_NW_PROT_BIT_PROFINET,      //< ProfiNet
  N_PTP_NW_PROT                  //< number of defined protocols
};

#define PTP_NW_PROT_MSK_RESERVED      ( 1UL << PTP_NW_PROT_BIT_RESERVED )
#define PTP_NW_PROT_MSK_UDP_IPV4      ( 1UL << PTP_NW_PROT_BIT_UDP_IPV4 )
#define PTP_NW_PROT_MSK_UDP_IPV6      ( 1UL << PTP_NW_PROT_BIT_UDP_IPV6 )
#define PTP_NW_PROT_MSK_IEEE_802_3    ( 1UL << PTP_NW_PROT_BIT_IEEE_802_3 )
#define PTP_NW_PROT_MSK_DEVICE_NET    ( 1UL << PTP_NW_PROT_BIT_DEVICE_NET )
#define PTP_NW_PROT_MSK_CONTROL_NET   ( 1UL << PTP_NW_PROT_BIT_CONTROL_NET )
#define PTP_NW_PROT_MSK_PROFINET      ( 1UL << PTP_NW_PROT_BIT_PROFINET )

#if !defined( DEFAULT_PTP_NW_PROT_MASK )
  #define DEFAULT_PTP_NW_PROT_MASK  ( PTP_NW_PROT_MSK_UDP_IPV4 | PTP_NW_PROT_MSK_IEEE_802_3 )
#endif

/**
 * @brief Name strings for the protocols possibly used with PTP
 */
#define PTP_NW_PROT_STRS   \
{                          \
  "Reserved",              \
  "UDP/IPv4 (L3)",         \
  "UDP/IPv6 (L3)",         \
  "IEEE 802.3 (L2)",       \
  "DeviceNet",             \
  "ControlNet",            \
  "PROFINET"               \
}


/**
 * @brief Short name strings for the protocols possibly used with PTP
 */
#define PTP_NW_PROT_STRS_SHORT \
{                              \
  "RES",                       \
  "IP4",                       \
  "IP6",                       \
  "ETH",                       \
  "DN",                        \
  "CN",                        \
  "PN"                         \
}


/**
 * @brief Possible states of a PTP port
 */
enum
{
  PTP_PORT_STATE_UNINITIALIZED,  //< uninitialized
  PTP_PORT_STATE_INITIALIZING,   //< currently initializing
  PTP_PORT_STATE_FAULTY,         //< faulty
  PTP_PORT_STATE_DISABLED,       //< disabled
  PTP_PORT_STATE_LISTENING,      //< listening for PTP packets
  PTP_PORT_STATE_PRE_MASTER,     //< going to become master
  PTP_PORT_STATE_MASTER,         //< master
  PTP_PORT_STATE_PASSIVE,        //< passive
  PTP_PORT_STATE_UNCALIBRATED,   //< uncalibrated
  PTP_PORT_STATE_SLAVE,          //< slave
  N_PTP_PORT_STATE               //< number of defined port states
};


/**
 * @brief Name strings for the PTP port states
 */
#define PTP_PORT_STATE_STRS   \
{                             \
  "UNINITIALIZED",            \
  "INITIALIZING",             \
  "FAULTY",                   \
  "DISABLED",                 \
  "LISTENING",                \
  "PRE_MASTER",               \
  "MASTER",                   \
  "PASSIVE",                  \
  "UNCALIBRATED",             \
  "SLAVE"                     \
}


/**
 * @brief An entry for a table of parameters which can not be accessed by an enumerated index
 */
typedef struct
{
  uint8_t value;      //< the parameter value
  const char *name;   //< the parameter name
} PTP_TABLE;


/**
 * @brief An enumeration of PTP delay mechanisms
 *
 * @note This is different than the numeric values specified
 * in the published specs for IEEE1588. In addition, the specs
 * define 0x14 for "disabled".
 */
enum
{
  PTP_DELAY_MECH_BIT_E2E,  //< End-to-End (in PTP2 specs: 0x01)
  PTP_DELAY_MECH_BIT_P2P,  //< Peer-to-Peer (in PTP2 specs: 0x02)
  N_PTP_DELAY_MECH         //< number of defined delay mechanisms
};

#define PTP_DELAY_MECH_MSK_E2E   ( 1UL << PTP_DELAY_MECH_BIT_E2E )
#define PTP_DELAY_MECH_MSK_P2P   ( 1UL << PTP_DELAY_MECH_BIT_P2P )

#if !defined( DEFAULT_PTP_DELAY_MECH_MASK )
  #define DEFAULT_PTP_DELAY_MECH_MASK  ( PTP_DELAY_MECH_MSK_E2E | PTP_DELAY_MECH_MSK_P2P )
#endif

/**
 * @brief Name strings for the PTP delay mechanisms
 */
#define PTP_DELAY_MECH_NAMES \
{                            \
  "E2E",                     \
  "P2P"                      \
}



#define PTP_CLOCK_ACCURACY_NUM_BIAS 0x20

/**
 * @brief An enumeration of accuracy classes used with PTP
 *
 * @note This enumeration does not start at 0 but with a bias
 * specified by PTP_CLOCK_ACCURACY_NUM_BIAS.
 */
enum
{
  PTP_CLOCK_ACCURACY_25ns = PTP_CLOCK_ACCURACY_NUM_BIAS,
  PTP_CLOCK_ACCURACY_100ns,
  PTP_CLOCK_ACCURACY_250ns,
  PTP_CLOCK_ACCURACY_1us,
  PTP_CLOCK_ACCURACY_2_5us,
  PTP_CLOCK_ACCURACY_10us,
  PTP_CLOCK_ACCURACY_25us,
  PTP_CLOCK_ACCURACY_100us,
  PTP_CLOCK_ACCURACY_250us,
  PTP_CLOCK_ACCURACY_1ms,
  PTP_CLOCK_ACCURACY_2_5ms,
  PTP_CLOCK_ACCURACY_10ms,
  PTP_CLOCK_ACCURACY_25ms,
  PTP_CLOCK_ACCURACY_100ms,
  PTP_CLOCK_ACCURACY_250ms,
  PTP_CLOCK_ACCURACY_1s,
  PTP_CLOCK_ACCURACY_10s,
  PTP_CLOCK_ACCURACY_MORE_10s,
  PTP_CLOCK_ACCURACY_RESERVED_1,
  PTP_CLOCK_ACCURACY_RESERVED_2,
  PTP_CLOCK_ACCURACY_RESERVED_3,
  PTP_CLOCK_ACCURACY_RESERVED_4,
  N_PTP_CLOCK_ACCURACY
};


/**
 * @brief Name strings for PTP accuracy classes
 *
 * @note The enumeration does not start at 0 but with a bias
 * specified by PTP_CLOCK_ACCURACY_NUM_BIAS, so this bias needs
 * to be accounted for when accessing a string table.
 */
#define PTP_CLOCK_ACCURACY_STRS \
{                               \
  "< 25 ns",                    \
  "< 100 ns",                   \
  "< 250 ns",                   \
  "< 1 us",                     \
  "< 2.5 us",                   \
  "< 10 us",                    \
  "< 25 us",                    \
  "< 100 us",                   \
  "< 250 us",                   \
  "< 1 ms",                     \
  "< 2.5 ms",                   \
  "< 10 ms",                    \
  "< 25 ms",                    \
  "< 100 ms",                   \
  "< 250 ms",                   \
  "< 1 s",                      \
  "< 10 s",                     \
  "more than 10 s",             \
  "reserved_1",                 \
  "reserved_2",                 \
  "reserved_3",                 \
  "reserved_4"                  \
}



/**
 * @brief Codes to specify the type of a time source used with PTP
 */
#define PTP_TIME_SOURCE_ATOMIC_CLOCK        0x10
#define PTP_TIME_SOURCE_GPS                 0x20
#define PTP_TIME_SOURCE_TERRESTRIAL_RADIO   0x30
#define PTP_TIME_SOURCE_PTP                 0x40
#define PTP_TIME_SOURCE_NTP                 0x50
#define PTP_TIME_SOURCE_HAND_SET            0x60
#define PTP_TIME_SOURCE_OTHER               0x90
#define PTP_TIME_SOURCE_INTERNAL_OSCILLATOR 0xA0



/**
 * @brief A table of PTP time source codes plus associated name strings
 */
#define PTP_TIME_SOURCE_TABLE                                     \
{                                                                 \
  { PTP_TIME_SOURCE_ATOMIC_CLOCK, "Atomic Clock" },               \
  { PTP_TIME_SOURCE_GPS, "GPS" },                                 \
  { PTP_TIME_SOURCE_TERRESTRIAL_RADIO, "Terrestrial Radio" },     \
  { PTP_TIME_SOURCE_PTP, "PTP" },                                 \
  { PTP_TIME_SOURCE_NTP, "NTP" },                                 \
  { PTP_TIME_SOURCE_HAND_SET, "HAND SET" },                       \
  { PTP_TIME_SOURCE_OTHER, "OTHER" },                             \
  { PTP_TIME_SOURCE_INTERNAL_OSCILLATOR, "Internal Oscillator" }, \
  { 0, NULL }                                                     \
}


/**
 * @brief An enumeration of roles which can be taken by a PTP node
 *
 * @note A role in this context specifies a certain mode of operation.
 * Depending on its specification a devices may not be able to take
 * each of the specified roles.
 */
enum
{
  PTP_ROLE_MULTICAST_SLAVE,    //< slave in multicast mode
  PTP_ROLE_UNICAST_SLAVE,      //< slave in unicast mode
  PTP_ROLE_MULTICAST_MASTER,   //< multicast master
  PTP_ROLE_UNICAST_MASTER,     //< unicast master
  N_PTP_ROLES                  //< number of defined roles
};


/**
 * @brief Name strings for defined PTP roles
 */
#define PTP_ROLE_STRS  \
{                      \
  "Multicast Slave",   \
  "Unicast Slave",     \
  "Multicast Master",  \
  "Unicast Master"     \
}


/**
 * @brief Short name strings for defined PTP roles
 */
#define PTP_ROLE_STRS_SHORT  \
{                            \
  "MCS",                     \
  "UCS",                     \
  "MCM",                     \
  "UCM"                      \
}


/**
 * @brief A PTP clock identity
 *
 * @note This usually consists of a 6 byte MAC address with
 * 2 fixed bytes inserted, or all ones as wildcard.
 */
typedef struct
{
  uint8_t b[8];
} PTP_CLOCK_ID;

#define _mbg_swab_ptp_clock_id( _p )   _nop_macro_fnc()  // nothing to swap

#define PTP_CLOCK_ID_WILDCARD   { { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF } }


/**
 * @brief A PTP port ID
 *
 * @note This usually consists of a 6 byte MAC address with
 * 2 fixed bytes inserted, or all ones as wildcard.
 */
typedef uint16_t PTP_PORT_ID;

#define _mbg_swab_ptp_port_id( _p )  _mbg_swab16( _p )

#define PTP_PORT_ID_WILDCARD   0xFFFF


/**
 * @brief An enumeration of time scales used with PTP
 *
 * @note The standard time scale used by PTP is TAI, which is a linear time scale.
 * The protocol provides a UTC offset to be able to convert TAI to compute UTC, which
 * can observe leap seconds. For the arbitrary time scale the UTC offset is unspecified.
 */
enum
{
  PTP_TIMESCALE_PTP,   /* default */
  PTP_TIMESCALE_ARB,
  N_PTP_TIMESCALE
};


/**
 * @brief Name strings for the PTP time scales
 */
#define PTP_TIMESCALE_NAME_PTP  "PTP Standard (TAI)"
#define PTP_TIMESCALE_NAME_ARB  "Arbitrary"

/**
 * @brief Short name strings for the PTP time scales
 */
#define PTP_TIMESCALE_NAME_PTP_SHORT  "PTP"
#define PTP_TIMESCALE_NAME_ARB_SHORT  "Arb"


/**
 * @brief A table of name strings for the PTP time scales
 */
#define PTP_TIMESCALE_NAMES \
{                           \
  PTP_TIMESCALE_NAME_PTP,   \
  PTP_TIMESCALE_NAME_ARB    \
}

/**
 * @brief A table of short name strings for the PTP time scales
 */
#define PTP_TIMESCALE_NAMES_SHORT \
{                                 \
  PTP_TIMESCALE_NAME_PTP_SHORT,   \
  PTP_TIMESCALE_NAME_ARB_SHORT    \
}



/**
 * @brief A structure to used to read the status of the PTP protocol stack
 */
typedef struct
{
  //##++++ Do we need a port identifier ??
  uint16_t nw_prot;                /**< one of the enumerated protocols (@see N_PTP_NW_PROT) */
  uint8_t ptp_prot_version;        /**< PTP protocol version, 1, or 2, usually 2 for v2 */
  uint8_t port_state;              /**< one of the enumerated port states (@see N_PTP_PORT_STATE ) */
  uint32_t flags;                  /**< bit masks as defined below */
  NANO_TIME offset;                /**< estimated time offset from the upstream time source */
  NANO_TIME path_delay;
  NANO_TIME mean_path_delay;
  NANO_TIME delay_asymmetry;

  PTP_CLOCK_ID gm_id;              /**< identifier ot the upstream time source */

  uint16_t clock_offset_scaled_log_variance;
  uint8_t clock_class;
  uint8_t clock_accuracy;          /**< one of the enumerated accuracy class codes (@see N_PTP_CLOCK_ACCURACY) */

  uint32_t reserved_1;             /**< reserved, currently always 0 */
  uint32_t reserved_2;             /**< reserved, currently always 0 */

  uint8_t domain_number;           /**< the PTP clock domain number, 0:3 */
  uint8_t time_source;             /**< one of the defined codes PTP_TIME_SOURCE_... */
  uint8_t delay_mech;              /**< PTP_DELAY_MECH_BIT_E2E or PTP_DELAY_MECH_BIT_P2P */
  int8_t log_delay_req_intv;

  int16_t utc_offset;              /**< UTC offset observed against TAI */
  DAC_VAL osc_dac_cal;             /**< disiplination value of the oscillator */

  uint32_t reserved_3;             /**< reserved, currently always 0 */

} PTP_STATE;

#define _mbg_swab_ptp_state( _p )                         \
{                                                         \
  _mbg_swab16( &(_p)->nw_prot );                          \
  _mbg_swab32( &(_p)->flags );                            \
  _mbg_swab_nano_time( &(_p)->offset );                   \
  _mbg_swab_nano_time( &(_p)->path_delay );               \
  _mbg_swab_nano_time( &(_p)->mean_path_delay );          \
  _mbg_swab_nano_time( &(_p)->delay_asymmetry );          \
  _mbg_swab_ptp_clock_id( &(_p)->gm_id );                 \
  _mbg_swab16( &(_p)->clock_offset_scaled_log_variance ); \
  _mbg_swab32( &(_p)->reserved_1 );                       \
  _mbg_swab32( &(_p)->reserved_2 );                       \
  _mbg_swab16( &(_p)->utc_offset );                       \
  _mbg_swab_dac_val( &(_p)->osc_dac_cal );                \
  _mbg_swab32( &(_p)->reserved_3 );                       \
}


/**
 * @brief Flag bits used with PTP_STATE::flags
 */
enum
{
  PTP_FLAG_BIT_SLAVE_ONLY,        /**< the port can only be slave */
  PTP_FLAG_BIT_IS_SLAVE,          /**< the port is currently slave */
  PTP_FLAG_BIT_TIMESCALE_IS_PTP,  /**< the timescale is PTP standard, not arbitrary */
  PTP_FLAG_BIT_LS_ANN,            /**< a leap second is being announced */
  PTP_FLAG_BIT_LS_ANN_NEG,        /**< the announced leap second is negative */
  PTP_FLAG_BIT_IS_UNICAST,        /**< the port currently operates in unicast mode */
  N_PTP_FLAG_BIT                  /**< the number of defined flag bits */
};

#define PTP_FLAG_MSK_SLAVE_ONLY         ( 1UL << PTP_FLAG_BIT_SLAVE_ONLY )
#define PTP_FLAG_MSK_IS_SLAVE           ( 1UL << PTP_FLAG_BIT_IS_SLAVE )
#define PTP_FLAG_MSK_TIMESCALE_IS_PTP   ( 1UL << PTP_FLAG_BIT_TIMESCALE_IS_PTP )
#define PTP_FLAG_MSK_LS_ANN             ( 1UL << PTP_FLAG_BIT_LS_ANN )
#define PTP_FLAG_MSK_LS_ANN_NEG         ( 1UL << PTP_FLAG_BIT_LS_ANN_NEG )
#define PTP_FLAG_MSK_IS_UNICAST         ( 1UL << PTP_FLAG_BIT_IS_UNICAST )



#define PTP_SYNC_INTERVAL_MIN -6
#define PTP_SYNC_INTERVAL_MAX  6

#define PTP_DELAY_REQ_INTERVAL_MIN -6
#define PTP_DELAY_REQ_INTERVAL_MAX  6

#define PTP_DEFAULT_UC_SYNC_INTV_MIN -4
#define PTP_DEFAULT_UC_SYNC_INTV_MAX  4

#define PTP_DEFAULT_UC_DLY_REQ_INTV_MIN -4
#define PTP_DEFAULT_UC_DLY_REQ_INTV_MAX  4

#define PTP_DEFAULT_UC_ANN_INTV_MIN -4
#define PTP_DEFAULT_UC_ANN_INTV_MAX  4

/**
 * @defgroup group_ptp_uc_msg_duration_limits Unicast PTP masters send messages
 * to a unicast slave only for a given interval as requested by the particular
 * slave, which is called message duration. These symbols define the minimum and
 * maximum message duration configured on a slave for a specific unicast master,
 * i.e. for PTP_UC_MASTER_SETTINGS::message_duration.
 * @{ */

#define PTP_UC_MSG_DURATION_MIN      10     //< minimum message duration [s]
#define PTP_UC_MSG_DURATION_MAX      1000   //< maximum message duration [s]
#define PTP_UC_MSG_DURATION_DEFAULT  60     //< default, though the specs say 300 s

/** @} group_ptp_uc_msg_duration_limits */



/**
 * @brief A structure used to configure a PTP port
 */
typedef struct
{
  //##++++ Do we need a port identifier ??
  uint16_t nw_prot;               /**< one of the enumerated and supported protocols (@see N_PTP_NW_PROT) */
  uint8_t profile;                /**< PTP profile, currently only 0 = default */
  uint8_t domain_number;          /**< the PTP clock domain number, 0:3 */

  uint8_t delay_mech;             /**< PTP_DELAY_MECH_BIT_E2E or PTP_DELAY_MECH_BIT_P2P, if supported */
  uint8_t ptp_role;               /**< one of the enumerated PTP roles (@see N_PTP_ROLES) */
  uint8_t priority_1;             /**< priority 1 */
  uint8_t priority_2;             /**< priority 2 */

  uint8_t dflt_clk_class_unsync_cold;   // 6:255
  uint8_t dflt_clk_class_unsync_warm;   // 6:255
  uint8_t dflt_clk_class_sync_cold;     // 6:255
  uint8_t dflt_clk_class_sync_warm;     // 6:255

  uint8_t reserved_1;             /**< reserved, currently always 0 */
  uint8_t reserved_2;             /**< reserved, currently always 0 */
  int16_t sync_intv;              /**< log2 of the sync interval [s] */

  int16_t ann_intv;               /**< log2 of the announce interval [s] */
  int16_t delay_req_intv;         /**< log2 of the delay request interval [s] */

  uint32_t upper_bound;           /**< sync state set to false if above this limit [ns] */
  uint32_t lower_bound;           /**< sync state set to true if below this limit [ns] */

  uint32_t reserved_3;            /**< reserved, currently always 0 */
  uint32_t flags;                 /**< bit masks as defined below */

} PTP_CFG_SETTINGS;

#define _mbg_swab_ptp_cfg_settings( _p )   \
{                                          \
  _mbg_swab16( &(_p)->nw_prot );           \
  _mbg_swab16( &(_p)->sync_intv );         \
  _mbg_swab16( &(_p)->ann_intv );          \
  _mbg_swab16( &(_p)->delay_req_intv );    \
  _mbg_swab32( &(_p)->upper_bound );       \
  _mbg_swab32( &(_p)->lower_bound );       \
  _mbg_swab32( &(_p)->reserved_3 );        \
  _mbg_swab32( &(_p)->flags );             \
}



/**
 * @brief A structure to used to query the current configurration and capabilities of a PTP port
 */
typedef struct
{
  PTP_CFG_SETTINGS settings;        /**< the current configuration */

  uint8_t ptp_proto_version;        /**< PTP protocol version, 1, or 2, usually 2 for v2 */
  uint8_t reserved_1;               /**< reserved, currently always 0 */
  uint16_t reserved_2;              /**< reserved, currently always 0 */

  int16_t sync_intv_min;            /**< log2 of minimum sync interval [s] */
  int16_t sync_intv_max;            /**< log2 of maximum sync interval [s] */
  int16_t ann_intv_min;             /**< log2 of minimum announce interval [s] */
  int16_t ann_intv_max;             /**< log2 of maximum announce interval [s] */
  int16_t delay_req_intv_min;       /**< log2 of minimum delay request interval [s] */
  int16_t delay_req_intv_max;       /**< log2 of maximum delay request interval [s] */

  uint32_t supp_flags;              /**< a bit mask of supported features (see below) */
  uint32_t supp_nw_prot;            /**< a bit mask of supported network protocols */
  uint32_t supp_profiles;           /**< a bit mask of supported profiles */
  uint32_t supp_delay_mech;         /**< a bit mask of supported delay mechanisms */

} PTP_CFG_INFO;

#define _mbg_swab_ptp_cfg_info( _p )              \
{                                                 \
  _mbg_swab_ptp_cfg_settings( &(_p)->settings );  \
  _mbg_swab16( &(_p)->reserved_2 );               \
  _mbg_swab16( &(_p)->sync_intv_min );            \
  _mbg_swab16( &(_p)->sync_intv_max );            \
  _mbg_swab16( &(_p)->ann_intv_min );             \
  _mbg_swab16( &(_p)->ann_intv_max );             \
  _mbg_swab16( &(_p)->delay_req_intv_min );       \
  _mbg_swab16( &(_p)->delay_req_intv_max );       \
  _mbg_swab32( &(_p)->supp_flags );               \
  _mbg_swab32( &(_p)->supp_nw_prot );             \
  _mbg_swab32( &(_p)->supp_profiles );            \
  _mbg_swab32( &(_p)->supp_delay_mech );          \
}



/**
 * @brief Flags used with PTP_CFG_SETTINGS::flags and PTP_CFG_INFO::supp_flags
 */
enum
{
  PTP_CFG_BIT_TIME_SCALE_IS_PTP,        /**< time scale is PTP/TAI, else arbitrary */
  PTP_CFG_BIT_V1_HW_COMPAT,             /**< maybe required for certain NIC chips, not used by Meinberg */
  PTP_CFG_BIT_CAN_BE_UNICAST_SLAVE,     /**< the PTP port can take the role of a unicast slave */
  PTP_CFG_BIT_CAN_BE_MULTICAST_MASTER,  /**< the PTP port can take the role of a multicast master */
  PTP_CFG_BIT_CAN_BE_UNICAST_MASTER,    /**< the PTP port can take the role of a unicast master */
  N_PTP_CFG_BIT                         /**< the number of defined bits */
};

#define PTP_CFG_MSK_TIME_SCALE_IS_PTP         ( 1UL << PTP_CFG_BIT_TIME_SCALE_IS_PTP )
#define PTP_CFG_MSK_V1_HW_COMPAT              ( 1UL << PTP_CFG_BIT_V1_HW_COMPAT )
#define PTP_CFG_MSK_CAN_BE_UNICAST_SLAVE      ( 1UL << PTP_CFG_BIT_CAN_BE_UNICAST_SLAVE )
#define PTP_CFG_MSK_CAN_BE_MULTICAST_MASTER   ( 1UL << PTP_CFG_BIT_CAN_BE_MULTICAST_MASTER )
#define PTP_CFG_MSK_CAN_BE_UNICAST_MASTER     ( 1UL << PTP_CFG_BIT_CAN_BE_UNICAST_MASTER )


#define PTP_CFG_MSK_SUPPORT_PTP_ROLES ( PTP_CFG_MSK_CAN_BE_UNICAST_SLAVE    | \
                                        PTP_CFG_MSK_CAN_BE_MULTICAST_MASTER | \
                                        PTP_CFG_MSK_CAN_BE_UNICAST_MASTER )

#define PTP_CFG_MSK_SUPPORT_PTP_UNICAST ( PTP_CFG_MSK_CAN_BE_UNICAST_SLAVE  | \
                                          PTP_CFG_MSK_CAN_BE_UNICAST_MASTER )

/**
 * @brief Derive a "supported PTP roles" bit mask from PTP_CFG_INFO::supp_flags
 *
 * There's no explicite flag to indicate that the role of a multicast slave
 * is supported, since this role is always supported. The sequence of flags
 * indicating that a specific optional role is supported matches the enumerated
 * roles above, but don't start at bit 0. So we compine the optional flag bits
 * with the LSB always set for the implicite multicast slave role to yield
 * a bit mask which according to the enumerated roles.
 */
#define _get_supp_ptp_role_idx_msk( _f ) \
  ( 1UL | ( ( (_f) & PTP_CFG_MSK_SUPPORT_PTP_ROLES ) >> ( PTP_CFG_BIT_CAN_BE_UNICAST_SLAVE - 1 ) ) )
//##+++++++++ #define _get_supp_ptp_roles( _r ) ((((_r) & ~3UL) >> PTP_CFG_BIT_V1_HW_COMPAT ) | 1UL)


/**
 * @brief A host's fully qualified domain name (FQDN), or a numeric IP address string
 *
 * In theory each single component (host name, domain name, top level domain name)
 * of a FQDN can have up to 63 characters, but the overall length is limited to
 * 255 characters. We specify one more character for the trailing 0.
 */
typedef char MBG_HOSTNAME[256];


/**
 * @brief Limits to be considered when specifying PTP unicast masters
 */
typedef struct
{
  uint16_t n_supp_master;      /**< number of unicast masters which can be specified */
  int16_t sync_intv_min;       /**< log2 of minimum sync interval [s] */
  int16_t sync_intv_max;       /**< log2 of maximum sync interval [s] */
  int16_t ann_intv_min;        /**< log2 of minimum announce interval [s] */
  int16_t ann_intv_max;        /**< log2 of maximum announce interval [s] */
  int16_t delay_req_intv_min;  /**< log2 of minimum delay request interval [s] */
  int16_t delay_req_intv_max;  /**< log2 of maximum delay request interval [s] */
  uint16_t reserved_0;         /**< reserved, currently always 0 */
  uint32_t supp_flags;         /**< a bit mask indicating which flags are supported */
  uint32_t reserved_1;         /**< reserved, currently always 0 */

} PTP_UC_MASTER_CFG_LIMITS;

#define _mbg_swab_ptp_uc_master_cfg_limits( _p ) \
{                                                \
  _mbg_swab16( &(_p)->n_supp_master );           \
  _mbg_swab16( &(_p)->sync_intv_min );           \
  _mbg_swab16( &(_p)->sync_intv_max );           \
  _mbg_swab16( &(_p)->ann_intv_min );            \
  _mbg_swab16( &(_p)->ann_intv_max );            \
  _mbg_swab16( &(_p)->delay_req_intv_min );      \
  _mbg_swab16( &(_p)->delay_req_intv_max );      \
  _mbg_swab16( &(_p)->reserved_0 );              \
  _mbg_swab32( &(_p)->supp_flags );              \
  _mbg_swab32( &(_p)->reserved_1 );              \
}


/**
 * @brief Specification of unicast masters
 *
 * This structure is used on a unicast slave to specify the settings of
 * a unicast master polled by the slave. The number of unicast masters
 * which can be specified depends on the capabilities of the slave device
 * and is returned in PTP_UC_MASTER_CFG_LIMITS::n_supp_master.
 */
typedef struct
{
  MBG_HOSTNAME gm_host;        /**< grandmaster's hostname or IP address */
  PTP_CLOCK_ID gm_clock_id;    /**< use clock ID of master port, or PTP_CLOCK_ID_WILDCARD */
  PTP_PORT_ID gm_port_id;      /**< use target port ID of master port (e.g. 135) or PTP_PORT_ID_WILDCARD */
  int16_t sync_intv;           /**< sync interval [log2 s] */
  int16_t ann_intv;            /**< announce interval [log2 s] */
  int16_t delay_req_intv;      /**< delay request interval [log2 s]*/
  int32_t fix_offset;          /**< constant time offset to be compensated [ns] */
  uint16_t message_duration;   /**< time period until master stops sending messages [s] */
  uint16_t reserved_0;         /**< reserved, currently always 0 */
  uint32_t reserved_1;         /**< reserved, currently always 0 */
  uint32_t flags;              /**< bit masks as specified below */

} PTP_UC_MASTER_SETTINGS;

#define _mbg_swab_ptp_uc_master_settings( _p )   \
{                                                \
  _mbg_swab_ptp_clock_id( &(_p)->gm_clock_id );  \
  _mbg_swab_ptp_port_id( &(_p)->gm_port_id );    \
  _mbg_swab16( &(_p)->sync_intv );               \
  _mbg_swab16( &(_p)->ann_intv );                \
  _mbg_swab16( &(_p)->delay_req_intv );          \
  _mbg_swab32( &(_p)->fix_offset );              \
  _mbg_swab16( &(_p)->message_duration );        \
  _mbg_swab16( &(_p)->reserved_0 );              \
  _mbg_swab32( &(_p)->reserved_1 );              \
  _mbg_swab32( &(_p)->flags );                   \
}


/**
 * @brief Specification of a certain unicast master
 */
typedef struct
{
  uint32_t idx;                     /**< index, 0..(PTP_UC_MASTER_CFG_LIMITS::n_supp_master - 1) */
  PTP_UC_MASTER_SETTINGS settings;  /**< specification for the unicast master with that index */

} PTP_UC_MASTER_SETTINGS_IDX;

#define _mbg_swab_ptp_uc_master_settings_idx( _p )      \
{                                                       \
  _mbg_swab32( &(_p)->idx );                            \
  _mbg_swab_ptp_uc_master_settings( &(_p)->settings );  \
}


/**
 * @brief Capabilities and current settings of a unicast master
 */
typedef struct
{
  PTP_UC_MASTER_SETTINGS settings;  /**< current settings */
  uint32_t reserved;                /**< reserved, currently always 0 */
  uint32_t flags;                   /**< reserved, currently always 0 */

} PTP_UC_MASTER_INFO;

#define _mbg_swab_ptp_uc_master_info( _p )              \
{                                                       \
  _mbg_swab_ptp_uc_master_settings( &(_p)->settings );  \
  _mbg_swab32( &(_p)->reserved );                       \
  _mbg_swab32( &(_p)->flags );                          \
}


/**
 * @brief Capabilities and current settings of a specific unicast master
 */
typedef struct
{
  uint32_t idx;             /**< index, 0..(PTP_UC_MASTER_CFG_LIMITS::n_supp_master - 1) */
  PTP_UC_MASTER_INFO info;  /**< capabilities and current settings */

} PTP_UC_MASTER_INFO_IDX;

#define _mbg_swab_ptp_uc_master_info_idx( _p )  \
{                                               \
  _mbg_swab32( &(_p)->idx );                    \
  _mbg_swab_ptp_uc_master_info( &(_p)->info );  \
}


/** @} group_ptp */



/*------------------------------------------------------------------------*/

/* Ephemeris parameters of one specific SV. Needed to compute the position */
/* of a satellite at a given time with high precision. Valid for an */
/* interval of 4 to 6 hours from start of transmission. */

typedef struct
{
  CSUM csum;       /*    checksum of the remaining bytes                  */
  int16_t valid;   /*    flag data are valid                              */

  HEALTH health;   /*    health indication of transmitting SV      [---]  */
  IOD IODC;        /*    Issue Of Data, Clock                             */
  IOD IODE2;       /*    Issue of Data, Ephemeris (Subframe 2)            */
  IOD IODE3;       /*    Issue of Data, Ephemeris (Subframe 3)            */
  T_GPS tt;        /*    time of transmission                             */
  T_GPS t0c;       /*    Reference Time Clock                      [---]  */
  T_GPS t0e;       /*    Reference Time Ephemeris                  [---]  */

  double sqrt_A;   /*    Square Root of semi-major Axis        [sqrt(m)]  */
  double e;        /*    Eccentricity                              [---]  */
  double M0;       /* +- Mean Anomaly at Ref. Time                 [rad]  */
  double omega;    /* +- Argument of Perigee                       [rad]  */
  double OMEGA0;   /* +- Longit. of Asc. Node of orbit plane       [rad]  */
  double OMEGADOT; /* +- Rate of Right Ascension               [rad/sec]  */
  double deltan;   /* +- Mean Motion Diff. from computed value [rad/sec]  */
  double i0;       /* +- Inclination Angle                         [rad]  */
  double idot;     /* +- Rate of Inclination Angle             [rad/sec]  */
  double crc;      /* +- Cosine Corr. Term to Orbit Radius           [m]  */
  double crs;      /* +- Sine Corr. Term to Orbit Radius             [m]  */
  double cuc;      /* +- Cosine Corr. Term to Arg. of Latitude     [rad]  */
  double cus;      /* +- Sine Corr. Term to Arg. of Latitude       [rad]  */
  double cic;      /* +- Cosine Corr. Term to Inclination Angle    [rad]  */
  double cis;      /* +- Sine Corr. Term to Inclination Angle      [rad]  */

  double af0;      /* +- Clock Correction Coefficient 0            [sec]  */
  double af1;      /* +- Clock Correction Coefficient 1        [sec/sec]  */
  double af2;      /* +- Clock Correction Coefficient 2      [sec/sec^2]  */
  double tgd;      /* +- estimated group delay differential        [sec]  */

  uint16_t URA;    /*    predicted User Range Accuracy                    */

  uint8_t L2code;  /*    code on L2 channel                         [---] */
  uint8_t L2flag;  /*    L2 P data flag                             [---] */
} EPH;



/* Almanac parameters of one specific SV. A reduced precision set of */
/* parameters used to check if a satellite is in view at a given time. */
/* Valid for an interval of more than 7 days from start of transmission. */

typedef struct
{
  CSUM csum;       /*    checksum of the remaining bytes                  */
  int16_t valid;   /*    flag data are valid                              */

  HEALTH health;   /*                                               [---] */
  T_GPS t0a;       /*    Reference Time Almanac                     [sec] */

  double sqrt_A;   /*    Square Root of semi-major Axis         [sqrt(m)] */
  double e;        /*    Eccentricity                               [---] */

  double M0;       /* +- Mean Anomaly at Ref. Time                  [rad] */
  double omega;    /* +- Argument of Perigee                        [rad] */
  double OMEGA0;   /* +- Longit. of Asc. Node of orbit plane        [rad] */
  double OMEGADOT; /* +- Rate of Right Ascension                [rad/sec] */
  double deltai;   /* +-                                            [rad] */
  double af0;      /* +- Clock Correction Coefficient 0             [sec] */
  double af1;      /* +- Clock Correction Coefficient 1         [sec/sec] */
} ALM;



/* Summary of configuration and health data of all SVs. */

typedef struct
{
  CSUM csum;               /* checksum of the remaining bytes */
  int16_t valid;           /* flag data are valid */

  T_GPS tot_51;            /* time of transmission, page 51 */
  T_GPS tot_63;            /* time of transmission, page 63 */
  T_GPS t0a;               /* complete reference time almanac */

  CFG cfg[N_SVNO];         /* SV configuration from page 63 */
  HEALTH health[N_SVNO];   /* SV health from pages 51, 63 */
} CFGH;



/**
 * @brief GPS UTC correction parameters
 */
typedef struct
{
  CSUM csum;          /**< Checksum of the remaining bytes */
  int16_t valid;      /**< Flag indicating UTC parameters are valid */

  T_GPS t0t;          /**< Reference Time UTC Parameters [wn|sec] */
  double A0;          /**< +- Clock Correction Coefficient 0 [sec] */
  double A1;          /**< +- Clock Correction Coefficient 1 [sec/sec] */

  uint16_t WNlsf;     /**< Week number of nearest leap second */
  int16_t DNt;        /**< The day number at the end of which a leap second occurs */
  int8_t delta_tls;   /**< Current UTC offset to GPS system time [sec] */
  int8_t delta_tlsf;  /**< Future UTC offset to GPS system time after next leap second transition [sec] */
} UTC;

#define _mbg_swab_utc_parm( _p )  \
{                                 \
  _mbg_swab_csum( &(_p)->csum );  \
  _mbg_swab16( &(_p)->valid );    \
  _mbg_swab_t_gps( &(_p)->t0t );  \
  _mbg_swab_double( &(_p)->A0 );  \
  _mbg_swab_double( &(_p)->A1 );  \
  _mbg_swab16( &(_p)->WNlsf );    \
  _mbg_swab16( &(_p)->DNt );      \
}



/* Ionospheric correction parameters */

typedef struct
{
  CSUM csum;       /*    checksum of the remaining bytes                  */
  int16_t valid;   /*    flag data are valid                              */

  double alpha_0;  /*    Ionosph. Corr. Coeff. Alpha 0              [sec] */
  double alpha_1;  /*    Ionosph. Corr. Coeff. Alpha 1          [sec/deg] */
  double alpha_2;  /*    Ionosph. Corr. Coeff. Alpha 2        [sec/deg^2] */
  double alpha_3;  /*    Ionosph. Corr. Coeff. Alpha 3        [sec/deg^3] */

  double beta_0;   /*    Ionosph. Corr. Coeff. Beta 0               [sec] */
  double beta_1;   /*    Ionosph. Corr. Coeff. Beta 1           [sec/deg] */
  double beta_2;   /*    Ionosph. Corr. Coeff. Beta 2         [sec/deg^2] */
  double beta_3;   /*    Ionosph. Corr. Coeff. Beta 3         [sec/deg^3] */
} IONO;



/* GPS ASCII message */

typedef struct
{
  CSUM csum;       /* checksum of the remaining bytes */
  int16_t valid;   /* flag data are valid */
  char s[23];      /* 22 chars GPS ASCII message plus trailing zero */
} ASCII_MSG;



enum
{
  GPS_PLATFORM_PORTABLE,
  GPS_PLATFORM_FIXED,
  GPS_PLATFORM_STATIONARY,
  GPS_PLATFORM_PEDESTRIAN,
  GPS_PLATFORM_AUTOMOTIVE,
  GPS_PLATFORM_SEA,
  GPS_PLATFORM_AIRBORNE_1G,
  GPS_PLATFORM_AIRBORNE_2G,
  GPS_PLATFORM_AIRBORNE_4G,
  N_GPS_PLATFORMS
};


#define GPS_PLATFORM_STRS \
{                         \
  "Portable    ",         \
  "Fixed       ",         \
  "Stationary  ",         \
  "Pedestrian  ",         \
  "Automotive  ",         \
  "Sea         ",         \
  "Airborne <1G",         \
  "Airborne <2G",         \
  "Airborne <4G"          \
}



enum
{
  TIME_MODE_DISABLED,
  TIME_MODE_SURVEY_IN,
  TIME_MODE_FIXED
};



typedef struct
{
  uint32_t time_mode;
  uint32_t survey_in_duration;
  uint32_t survey_in_pos_var;
  int32_t  fixedPosX;         // cm
  int32_t  fixedPosY;         // cm
  int32_t  fixedPosZ;         // cm
  uint32_t fixedPosVar;       // cm
  uint32_t  flags;            // currently 0
  uint32_t  reserved;         // currently 0
} NAV_TIME_MODE_SETTINGS;


/**
  Navigation Engine settings to set configuration
  parameters of a dynamic platform model.
*/
typedef struct
{
  uint8_t   dynamic_platform;
  uint8_t   fix_mode;
  int8_t    min_elevation;
  uint8_t   static_hold_threshold;
  int32_t   fixed_altitude;
  uint32_t  fixed_altitude_variance;
  uint32_t  flags;          // currently 0
  uint32_t  reserved;       // currently 0
  NAV_TIME_MODE_SETTINGS nav_time_mode_settings;
} NAV_ENGINE_SETTINGS;


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */

#endif  /* _GPSDEFS_H */
