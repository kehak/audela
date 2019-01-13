
/**************************************************************************
 *
 *  $Id: gpsserio.h 1.37.1.2 2011/12/13 08:35:42 martin TEST martin $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for gpsserio.c.
 *
 *    This file defines structures and codes to be used to access
 *    Meinberg GPS clocks via their serial interface COM0. COM0 should
 *    be set to a high baud rate, default is 19200.
 *
 *    Standard Meinberg GPS serial operation is to send the Meinberg
 *    standard time string automatically once per second, once per
 *    minute, or on request per ASCII '?'.
 *
 *    GPS parameter setup or parameter readout uses blocks of binary
 *    data which have to be isolated from the standard string. A block
 *    of data starts with a SOH code (ASCII Start Of Header, 0x01)
 *    followed by a message header with constant length and a block of
 *    data with variable length.
 *
 *    The first field (cmd) of the message header holds the command
 *    code rsp. the type of data to be transmitted. The next field (len)
 *    gives the number of data bytes that follow the header. This number
 *    ranges from 0 to sizeof( MSG_DATA ). The third field (data_csum)
 *    holds a checksum of all data bytes and the last field of the header
 *    finally holds the checksum of the header itself.
 *
 * -----------------------------------------------------------------------
 *  $Log: gpsserio.h $
 *  Revision 1.37.1.2  2011/12/13 08:35:42  martin
 *  Revision 1.37.1.1  2011/12/12 16:08:26  martin
 *  Indention fix.
 *  Revision 1.37  2011/11/25 14:59:17Z  martin
 *  Account for some renamed evt_log library symbols.
 *  Revision 1.36  2011/11/25 10:37:10  martin
 *  Added commands and data structures to support log events.
 *  Revision 1.35  2011/07/29 09:46:54  daniel
 *  Use native alignment only.
 *  Added command code GPS_XMR_INSTANCES.
 *  Support GPIO configuration.
 *  Support for USB.
 *  Revision 1.34  2011/04/15 13:12:02  martin
 *  Added initializer for command name table.
 *  Unified mutex stuff using macros from mbgmutex.h.
 *  Revision 1.33  2010/09/07 07:18:08  daniel
 *  New codes and structures for multi GNSS support.
 *  Defines to support reading raw IRIG data.
 *  Revision 1.32  2009/08/26 09:02:21  daniel
 *  Added new commands GPS_NAV_ENG_SETTINGS and
 *  GPS_GLNS_ALM.
 *  Revision 1.31  2009/08/24 13:32:33Z  martin
 *  Renamed symbol MBGEXTIO_TIMEOUT_SOCKET to MBGEXTIO_RCV_TIMEOUT_SOCKET.
 *  Support new timeout handling distinguishing between character timeout
 *  and message timeout. Timeout values are now expected in milliseconds.
 *  Revision 1.30  2009/07/02 09:19:31  martin
 *  Moved definitions related to LAN interface configuration to gpsdefs.h.
 *  Revision 1.29  2009/03/10 17:00:29  martin
 *  Support configurable time scales.
 *  Don't pack structure MBG_MSG_CTL but use default alignment.
 *  Revision 1.28  2008/09/04 12:47:10Z  martin
 *  Moved generic serial I/O stuff to mbgserio.h.
 *  Preliminarily support chk_tstr.
 *  Revision 1.27  2008/04/07 10:49:13Z  martin
 *  Added cmd GPS_CLR_UCAP_BUFF.
 *  Revision 1.26  2007/02/27 09:51:45  martin
 *  Modified mutex macros for Windows.
 *  Added type TZCODE which is used by the binary protocol but
 *  has a different size than PCPS_TZCODE.
 *  Now _USE_PCPSDEFS by default for non-firmware apps.
 *  Fixed comments on GPS_OPT_SETTINGS and GPS_OPT_INFO.
 *  Revision 1.25  2007/02/06 16:31:04Z  martin
 *  Modified comment for PZF_PCPS_TIME which can now also 
 *  be sent to a device.
 *  Added mutex support.
 *  Added SVNO to the buffer union.
 *  Added support for OPT_SETTINGS.
 *  Added XMULTI_REF_... definitions.
 *  Modified some comments.
 *  Revision 1.24  2006/12/21 10:54:14Z  martin
 *  Moved macro _IS_MBG_FIRMWARE to words.h.
 *  Cleaned up definitions of default I/O macros.
 *  Revision 1.23  2006/12/12 15:53:58  martin
 *  Added structure LAN_IF_INFO and associated codes.
 *  Added cmd codes GPS_IRIG_RX_SETTINGS and GPS_IRIG_RX_INFO.
 *  Added new member irig_rx_info to union MSG_DATA.
 *  Added cmd code GPS_REF_OFFS and associated definitions.
 *  Added cmd code GPS_DEBUG_STATUS.
 *  Define MBG_HANDLE for DOS even without v24tools.
 *  Revision 1.22  2006/11/02 08:57:56  martin
 *  Added a typedef to avoid firmware build errors.
 *  Revision 1.21  2006/10/25 12:25:35Z  martin
 *  Support serial I/O under Windows.
 *  Removed obsolete definitions.
 *  Updated function prototypes.
 *  Revision 1.20  2006/08/24 13:00:08Z  martin
 *  Added conditional support for network socket I/O and encrypted packets.
 *  Serial I/O is now also conditional only.
 *  Added/renamed/redefined structures as required.
 *  Revision 1.19  2006/06/15 10:39:49Z  martin
 *  Added some special types to the MSG_DATA union which have
 *  previously been defined as generic uint16_t types.
 *  Removed MBG_OPT_SETTINGS and MBG_OPT_INFO from 
 *  the MSG_DATA union since those types are not used with
 *  the binary protocol.
 *  Revision 1.18  2006/05/18 09:43:35Z  martin
 *  New cmd code GPS_IGNORE_LOCK.
 *  Added command codes for PZF receivers.
 *  Renamed IRIG_... symbols to IRIG_TX_... in order to distinguish
 *  from IRIG input configuration which might be available in the future.
 *  Added some fields to the MSG_DATA union.
 *  Renamed MSG_BUFF field "data" to "msg_data" in order to avoid 
 *  conflict with reserved word in some environments.
 *  Rewrote inclusion control macros.
 *  Replace control of inclusion of function prototypes by new symbol
 *  _USE_GPSSERIO_FNC which can be fully overridden.
 *  Updated lots of comments.
 *  Revision 1.17  2005/09/08 14:47:05Z  martin
 *  Changed type of MSG_RCV_CTL::flags from int to ulong
 *  to avoid compiler warnings.
 *  Revision 1.16  2005/04/26 10:53:53Z  martin
 *  Updated function prototypes.
 *  Revision 1.15  2004/12/28 11:02:20Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Replaced received_header by flags in MSG_RCV_CTL.
 *  Defined flag bits and corresponding bit masks.
 *  Updated function prototypes.
 *  Revision 1.14  2004/07/08 08:28:30  martin
 *  New cmd code GPS_RCV_TIMEOUT which is only supported if
 *  feature mask GPS_HAS_RCV_TIMEOUT is set.
 *  Revision 1.13  2004/06/16 14:13:50  martin
 *  Changed name of symbol which controls inclusion of function prototypes.
 *  Don't include function prototypes by default if compiling firmware.
 *  Conditionally support private data structures, automatically include
 *  those definitions if compiling firmware.
 *  The data portion of MSG_BUFF is now a union whose maximum size 
 *  can be overridden by a preprocessor value.
 *  Added MBG_OPT_SETTINGS and MBG_OPT_INFO to the buffer union.
 *  Updated function prototypes.
 *  Revision 1.12  2004/04/16 09:16:00Z  andre
 *  Added command code GPS_MULTI_REF_STATUS.
 *  Revision 1.11  2004/03/26 11:08:28Z  martin
 *  Compile function prototypes conditionally only.
 *  if symbol _INCL_GPSSERIO_FNC is defined.
 *  New structure MSG_RCV_CTL to support binary
 *  protocol on several ports.
 *  Added support for IPv4 LAN interface configuration.
 *  Support MULTI_REF_SETTINGS/MULTI_REF_INFO.
 *  Added command code to query ROM checksum.
 *  Modified some comments.
 *  Updated function prototypes.
 *  Revision 1.10  2002/08/21 07:39:32Z  werner
 *  POUT_PROG -> POUT_INFO
 *  Revision 1.9  2002/01/29 15:29:16Z  MARTIN
 *  Renamed cmd code GPS_IRIG_CFG to GPS_IRIG_SETTINGS.
 *  Added new cmd codes GPS_RECEIVER_INFO...GPS_IRIG_INFO
 *  and updated msg buffer union with corresponding fields.
 *  Removed obsolete types OPT_FEATURES, IRIG_CFG  and
 *  associated definitions.
 *  Modified some comments.
 *  Revision 1.8  2001/04/06 11:51:24  Andre
 *  transfercodes and structures for IRIG parameter and installed
 *  options added
 *  Revision 1.7  2001/03/30 10:47:04Z  MARTIN
 *  New file header.
 *  Control alignment of structures from new file use_pack.h.
 *  Modified syntax and some comments.
 *
 **************************************************************************/

#ifndef _GPSSERIO_H
#define _GPSSERIO_H


/* Other headers to be included */

#include <gpsdefs.h>
#include <use_pack.h>


/*
 * The following macros control parts of the build process.
 * The default values are suitable for most cases but can be
 * overridden by global definitions, if required.
 */

#if _IS_MBG_FIRMWARE
  // This handle type in not used by the firmware.
  // However, we define it to avoid build errors.
  typedef int MBG_HANDLE;

#endif


#ifndef _USE_MUTEX
  #if defined( MBG_TGT_WIN32 )
    #define _USE_MUTEX  1
  #elif defined( MBG_TGT_UNIX )
    #define _USE_MUTEX  1
  #endif
#endif

#ifndef _USE_MUTEX
  #define _USE_MUTEX          0  // not used by default
#endif


/* Control whether network socket communication shall be supported */
#ifndef _USE_SOCKET_IO
  #define _USE_SOCKET_IO      0  // not supported by default
#endif

/* Control whether serial port communication shall be supported */
#ifndef _USE_SERIAL_IO
  #if _IS_MBG_FIRMWARE
    #define _USE_SERIAL_IO    0   // Firmware provides its own serial I/O functions
  #else
    #define _USE_SERIAL_IO    1   // supported by default
  #endif
#endif

/* Control inclusion of secudefs.h */
#if _USE_SOCKET_IO
  // Network socket I/O always requires secudefs, so make sure
  // this is defined correctly.
  #ifdef _USE_ENCRYPTION
    #undef _USE_ENCRYPTION
  #endif
  #define _USE_ENCRYPTION      1
#else
  // If no socket I/O is used then secudefs aren't required, either.
  #ifndef _USE_ENCRYPTION
    #define _USE_ENCRYPTION    0
  #endif
#endif

/* Control inclusion of pcpsdefs.h */
#ifndef _USE_PCPSDEFS
  #if _IS_MBG_FIRMWARE
    // for firmware depend on the target system
    #if defined( _CC51 )
      #define _USE_PCPSDEFS    1
    #else
      #define _USE_PCPSDEFS    0
    #endif
  #else
    // otherwise include it by default
    #define _USE_PCPSDEFS      1
  #endif
#endif

/* Control inclusion of non-public declarations */
#ifndef _USE_GPSPRIV
  /* by default do include if building a GPS firmware */
  #define _USE_GPSPRIV  _IS_MBG_FIRMWARE
#endif

/* Control inclusion of function prototypes */
#ifndef _USE_GPSSERIO_FNC
  /* by default don't include if building a firmware */
  #define _USE_GPSSERIO_FNC  ( !_IS_MBG_FIRMWARE )
#endif

#ifndef _USE_RCV_TSTAMP
  #define _USE_RCV_TSTAMP    ( !_IS_MBG_FIRMWARE )
#endif


#if _USE_MUTEX
  #include <mbgmutex.h>
#endif

#if _USE_SERIAL_IO
  #include <mbgserio.h>
#endif

#if _USE_USB_IO
  #include <mbgusbio.h>
#endif

#if _USE_SOCKET_IO
  #if defined( MBG_TGT_UNIX )
    #include <netdb.h>
  #endif
#endif

#if _USE_ENCRYPTION
  #include <secudefs.h>
  #include <aes128.h>
#endif

#if _USE_PCPSDEFS
  #include <pcpsdefs.h>
#endif

#if _USE_GPSPRIV
  #include <gpspriv.h>
#endif

#if _USE_RCV_TSTAMP
  #include <mbg_tmo.h>
#endif


#ifdef __cplusplus
extern "C" {
#endif

#ifdef _GPSSERIO
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

// We don't use pragma pack() here but native alignment.


/* Status codes of check_transfer() function. */

#define TR_COMPLETE      2
#define TR_RECEIVING     1
#define TR_WAITING       0
#define TR_TIMEOUT      -1
#define TR_CSUM_HDR     -2
#define TR_CSUM_DATA    -3
#define TR_DECRYPTION   -4
#define TR_OPEN_ERR     -5
#define TR_IO_ERR       -6
#define TR_AUTH_ERR     -7


/* The code below is sent before a message header. */

#define START_OF_HEADER   0x01     /* ASCII SOH */


/* The control codes defined below are to be or'ed with a command/type code. */

#define GPS_REQACK    0x8000   /* to GPS rcvr: request acknowledge */
#define GPS_ACK       0x4000   /* from GPS rcvr: acknowledge a command */
#define GPS_NACK      0x2000   /* from GPS rcvr: error receiving command */

#define GPS_CTRL_MSK  0xF000   /* masks control code from command */


/**< @defgroup gps_cmds_serial GPS commands passed via serial port
 *
 * These codes specify commands/types of data to be supplied to
 * the GPS receiver:
 */
/*                            clock auto-message to host             */
/*                            |   host request, clock response       */
/*                            |   |   host download to clock         */
/*                            |   |   |                              */
enum  /*                      |   |   |                              */
{ /* system data */
  GPS_AUTO_ON = 0x000,   /* |   |   | X | no param, enable auto-msgs from GPS rcvr */
  GPS_AUTO_OFF,          /* |   |   | X | no param, disable auto-msgs from GPS rcvr */
  GPS_SW_REV,            /* |   | X |   | SW_REV, software revision */
  GPS_BVAR_STAT,         /* |   | X |   | BVAR_STAT, status of buffered variables */
  GPS_TIME,              /* | X |   | X | TTM, current time or capture, or init board time */
  GPS_POS_XYZ,           /* |   | X | X | XYZ, current position in ECEF coords */
  GPS_POS_LLA,           /* |   | X | X | LLA, current position in geographic coords */
  GPS_TZDL,              /* |   | X | X | TZDL, time zone / daylight saving */
  GPS_PORT_PARM,         /* |   | X | X | PORT_PARM, (obsolete, use PORT_SETTINGS etc. ) */
  GPS_SYNTH,             /* |   | X | X | SYNTH synthesizer's frequency and phase */
  GPS_ANT_INFO,          /* | X | X |   | ANT_INFO, time diff after antenna disconnect */
  GPS_UCAP,              /* | X | X |   | TTM, user capture events */
  GPS_ENABLE_FLAGS,      /* |   | X | X | ENABLE_FLAGS, when to enable serial, pulses, and synth */
  GPS_STAT_INFO,         /* |   | X |   | STAT_INFO, request SV, mode and DAC info */
  GPS_SWITCH_PARMS,      /* |   | X | X | (obsolete, use GPS_POUT_PROG_IDX) */
  GPS_STRING_PARMS,      /* |   | X | X | (obsolete, use GPS_PORT_INFO/GPS_PORT_SETTINGS */
  GPS_ANT_CABLE_LENGTH,  /* |   | X | X | ANT_CABLE_LEN, length of antenna cable */
  GPS_SYNC_OUTAGE_DELAY, /* |   | X | X | (customized firmware only) */
  GPS_PULSE_INFO,        /* |   | X | X | (customized firmware only) */
  GPS_OPT_FEATURES,      /* |   | X |   | (obsolete, use GPS_RECEIVER_INFO) */
  GPS_IRIG_TX_SETTINGS,  /* |   | X | X | IRIG_SETTINGS, (only if GPS_HAS_IRIG_TX) */
  GPS_RECEIVER_INFO,     /* |   | X |   | RECEIVER_INFO, model specific info */
  GPS_STR_TYPE_INFO_IDX, /* |   | X |   | STR_TYPE_INFO_IDX, names and modes of supp. string types */
  GPS_PORT_INFO_IDX,     /* |   | X |   | PORT_INFO_IDX, port settings + additional info */
  GPS_PORT_SETTINGS_IDX, /* |   | X | X | PORT_SETTINGS_IDX, settings for specified port */
  GPS_POUT_INFO_IDX,     /* |   | X |   | POUT_INFO_IDX, pout settings + additional info */
  GPS_POUT_SETTINGS_IDX, /* |   | X | X | POUT_SETTINGS_IDX, programmable pulse output cfg */
  GPS_IRIG_TX_INFO,      /* |   | X |   | IRIG_INFO, (only if GPS_HAS_IRIG_TX) */
  GPS_MULTI_REF_SETTINGS,/* |   | X | X | MULTI_REF_SETTINGS, (only if HAS_MULTI_REF) */
  GPS_MULTI_REF_INFO,    /* |   | X |   | MULTI_REF_INFO, (only if HAS_MULTI_REF) */
  GPS_ROM_CSUM,          /* |   | X |   | ROM_CSUM, (not supported by all devices) */
  GPS_MULTI_REF_STATUS,  /* |   | X |   | MULTI_REF_STATUS, (only if HAS_MULTI_REF) */
  GPS_RCV_TIMEOUT,       /* |   | X | X | RCV_TIMEOUT, [min] (only if HAS_RCV_TIMEOUT) */
  GPS_IGNORE_LOCK,       /* |   | X | X | IGNORE_LOCK, if != 0 always claim to be sync */
  GPS_IRIG_RX_SETTINGS,  /* |   | X | X | IRIG_SETTINGS, (only if GPS_HAS_IRIG_RX) */
  GPS_IRIG_RX_INFO,      /* |   | X |   | IRIG_INFO, (only if GPS_HAS_IRIG_RX) */
  GPS_REF_OFFS,          /* |   | X | X | MBG_REF_OFFS, (only if GPS_HAS_REF_OFFS) */
  GPS_DEBUG_STATUS,      /* |   | X |   | MBG_DEBUG_STATUS, (only if GPS_HAS_DEBUG_STATUS) */
  GPS_XMR_SETTINGS_IDX,  /* |   | X | X | XMULTI_REF_SETTINGS_IDX, (only if GPS_HAS_XMULTI_REF) */
  GPS_XMR_INFO_IDX,      /* |   | X |   | XMULTI_REF_INFO_IDX, (only if GPS_HAS_XMULTI_REF) */
  GPS_XMR_STATUS_IDX,    /* |   | X |   | XMULTI_REF_STATUS_IDX, (only if GPS_HAS_XMULTI_REF) */
  GPS_OPT_SETTINGS,      /* |   | X | X | MBG_OPT_SETTINGS, (only if GPS_HAS_OPT_SETTINGS) */
  GPS_OPT_INFO,          /* |   | X |   | MBG_OPT_INFO, (only if GPS_HAS_OPT_SETTINGS) */
  GPS_CLR_UCAP_BUFF,     /* |   |   | X | command only, no data */
  GPS_TIME_SCALE,        /* |   | X | X | MBG_TIME_SCALE_{SETTINGS|INFO}, (only if GPS_HAS_TIME_SCALE) */
  GPS_NAV_ENG_SETTINGS,  /* |   | X | X | NAV_ENGINE_SETTINGS, (only if GPS_HAS_NAV_ENGINE_SETTINGS) */
  GPS_RAW_IRIG_DATA,     /* |   | X |   | MBG_RAW_IRIG_DATA, (only if GPS_HAS_RAW_IRIG_DATA) */
  GPS_GPIO_CFG_LIMITS,   /* |   | X |   | MBG_GPIO_CFG_LIMITS, only if GPS_HAS_GPIO */
  GPS_GPIO_INFO_IDX,     /* |   | X |   | MBG_GPIO_INFO_IDX, cfg. and capabilities, only if GPS_HAS_GPIO */
  GPS_GPIO_SETTINGS_IDX, /* |   | X | X | MBG_GPIO_SETTINGS_IDX, cfg. of a specific port, only if PCPS_HAS_GPIO */
  GPS_XMR_INSTANCES,     /* |   | X | X | XMULTI_REF_INSTANCES (only if GPS_HAS_XMULTI_REF) */
  GPS_CLR_EVT_LOG,       /* |   |   | X | clear log command, no data (only if GPS_HAS_EVT_LOG) */
  GPS_NUM_EVT_LOG_ENTRIES, /* | | X |   | MBG_NUM_EVT_LOG_ENTRIES, num. of log entries (only if GPS_HAS_EVT_LOG) */
  GPS_FIRST_EVT_LOG_ENTRY, /* | | X |   | read oldest MBG_EVT_LOG_ENTRY (only if GPS_HAS_EVT_LOG) */
  GPS_NEXT_EVT_LOG_ENTRY,  /* | | X |   | read next MBG_EVT_LOG_ENTRY (only if GPS_HAS_EVT_LOG) */

  /* GPS data */
  GPS_CFGH = 0x100,      /* |   | X | X | CFGH, SVs' configuration and health codes */
  GPS_ALM,               /* |   | X | X | req: uint16_t SV num, SV_ALM, one SV's almanac */
  GPS_EPH,               /* |   | X | X | req: uint16_t SV num, SV_EPH, one SV's ephemeris */
  GPS_UTC,               /* |   | X | X | UTC, GPS UTC correction parameters */
  GPS_IONO,              /* |   | X | X | IONO, GPS ionospheric correction parameters */
  GPS_ASCII_MSG,         /* |   | X |   | ASCII_MSG, the GPS ASCII message */

  /* Glonass data */
  GPS_GLNS_ALM = 0x200,  /* |   | X | X | ** preliminary ** */  //##++
  GPS_GNSS_SAT_INFO,     /* |   | X |   | GNSS_SAT_INFO, request SVs */
  GPS_GNSS_MODE,         /* |   | X | X | MBG_GNSS_MODE_{SETTINGS|INFO}, GNSS operation mode */

  /* Misc data */
  GPS_IP4_SETTINGS = 0x800,  /* | X | X | IP4_SETTINGS, cfg of optional LAN interface */
  GPS_LAN_IF_INFO,           /* | X |   | LAN_IF_INFO, LAN interface info */

  GPS_CRYPTED_PACKET = 0x880,  /* | X | X | X | encrypted binary packet */
  GPS_CRYPTED_RAW_PACKET,      /* | X | X | X | encrypted binary raw packet */

  GPS_SECU_INFO = 0x900, /* |   | X |   | encryption method for LAN interface */
  GPS_SECU_SETTINGS,     /* |   | X | X | reserved for public key LAN interface */ 
  GPS_SECU_PUBLIC_KEY,   /* |   |   |   | settings and password for LAN interface */

  /* PZF data */
  PZF_PCPS_TIME = 0xA00, /* |   | X | X | PCPS_TIME, date/time/status */
  PZF_TR_DISTANCE,       /* |   | X | X | TR_DISTANCE, dist. from transmitter [km] */
  PZF_TZCODE,            /* |   | X | X | TZCODE, time zone code */
  PZF_CORR_INFO          /* |   | X |   | CORR_INFO, correlation info */
};

/*
 * Caution: If GPS_ALM, GPS_EPH or a code named ..._IDX is sent to retrieve
 * some data from a device then an uint16_t parameter must be also supplied 
 * in order to specify the index number of the data set to be returned.
 * The valid index range depends on the command code.
 *
 * For GPS_ALM and GPS_EPH the index is the SV number which may be 0 or 
 * MIN_SVNO to MAX_SVNO. If the number is 0, ALL almanacs (32) are returned.
 */


typedef struct
{
  GPS_CMD cmd_code;
  const char *cmd_name;
} GPS_CMD_NAME_TABLE_ENTRY;

#define GPS_CMD_NAME_TABLE_ENTRIES                      \
{                                                       \
  { GPS_AUTO_ON,            "GPS_AUTO_ON" },            \
  { GPS_AUTO_OFF,           "GPS_AUTO_OFF" },           \
  { GPS_SW_REV,             "GPS_SW_REV" },             \
  { GPS_BVAR_STAT,          "GPS_BVAR_STAT" },          \
  { GPS_TIME,               "GPS_TIME" },               \
  { GPS_POS_XYZ,            "GPS_POS_XYZ" },            \
  { GPS_POS_LLA,            "GPS_POS_LLA" },            \
  { GPS_TZDL,               "GPS_TZDL" },               \
  { GPS_PORT_PARM,          "GPS_PORT_PARM" },          \
  { GPS_SYNTH,              "GPS_SYNTH" },              \
  { GPS_ANT_INFO,           "GPS_ANT_INFO" },           \
  { GPS_UCAP,               "GPS_UCAP" },               \
  { GPS_ENABLE_FLAGS,       "GPS_ENABLE_FLAGS" },       \
  { GPS_STAT_INFO,          "GPS_STAT_INFO" },          \
  { GPS_SWITCH_PARMS,       "GPS_SWITCH_PARMS" },       \
  { GPS_STRING_PARMS,       "GPS_STRING_PARMS" },       \
  { GPS_ANT_CABLE_LENGTH,   "GPS_ANT_CABLE_LENGTH" },   \
  { GPS_SYNC_OUTAGE_DELAY,  "GPS_SYNC_OUTAGE_DELAY" },  \
  { GPS_PULSE_INFO,         "GPS_PULSE_INFO" },         \
  { GPS_OPT_FEATURES,       "GPS_OPT_FEATURES" },       \
  { GPS_IRIG_TX_SETTINGS,   "GPS_IRIG_TX_SETTINGS" },   \
  { GPS_RECEIVER_INFO,      "GPS_RECEIVER_INFO" },      \
  { GPS_STR_TYPE_INFO_IDX,  "GPS_STR_TYPE_INFO_IDX" },  \
  { GPS_PORT_INFO_IDX,      "GPS_PORT_INFO_IDX" },      \
  { GPS_PORT_SETTINGS_IDX,  "GPS_PORT_SETTINGS_IDX" },  \
  { GPS_POUT_INFO_IDX,      "GPS_POUT_INFO_IDX" },      \
  { GPS_POUT_SETTINGS_IDX,  "GPS_POUT_SETTINGS_IDX" },  \
  { GPS_IRIG_TX_INFO,       "GPS_IRIG_TX_INFO" },       \
  { GPS_MULTI_REF_SETTINGS, "GPS_MULTI_REF_SETTINGS" }, \
  { GPS_MULTI_REF_INFO,     "GPS_MULTI_REF_INFO" },     \
  { GPS_ROM_CSUM,           "GPS_ROM_CSUM" },           \
  { GPS_MULTI_REF_STATUS,   "GPS_MULTI_REF_STATUS" },   \
  { GPS_RCV_TIMEOUT,        "GPS_RCV_TIMEOUT" },        \
  { GPS_IGNORE_LOCK,        "GPS_IGNORE_LOCK" },        \
  { GPS_IRIG_RX_SETTINGS,   "GPS_IRIG_RX_SETTINGS" },   \
  { GPS_IRIG_RX_INFO,       "GPS_IRIG_RX_INFO" },       \
  { GPS_REF_OFFS,           "GPS_REF_OFFS" },           \
  { GPS_DEBUG_STATUS,       "GPS_DEBUG_STATUS" },       \
  { GPS_XMR_SETTINGS_IDX,   "GPS_XMR_SETTINGS_IDX" },   \
  { GPS_XMR_INFO_IDX,       "GPS_XMR_INFO_IDX" },       \
  { GPS_XMR_STATUS_IDX,     "GPS_XMR_STATUS_IDX" },     \
  { GPS_OPT_SETTINGS,       "GPS_OPT_SETTINGS" },       \
  { GPS_OPT_INFO,           "GPS_OPT_INFO" },           \
  { GPS_CLR_UCAP_BUFF,      "GPS_CLR_UCAP_BUFF" },      \
  { GPS_TIME_SCALE,         "GPS_TIME_SCALE" },         \
  { GPS_NAV_ENG_SETTINGS,   "GPS_NAV_ENG_SETTINGS" },   \
  { GPS_RAW_IRIG_DATA,      "GPS_RAW_IRIG_DATA" },      \
  { GPS_GPIO_CFG_LIMITS,    "GPS_GPIO_CFG_LIMITS" },    \
  { GPS_GPIO_INFO_IDX,      "GPS_GPIO_INFO_IDX" },      \
  { GPS_GPIO_SETTINGS_IDX,  "GPS_GPIO_SETTINGS_IDX" },  \
  { GPS_XMR_INSTANCES,      "GPS_XMR_INSTANCES" },      \
                                                        \
  /* GPS data */                                        \
  { GPS_CFGH,               "GPS_CFGH" },               \
  { GPS_ALM,                "GPS_ALM" },                \
  { GPS_EPH,                "GPS_EPH" },                \
  { GPS_UTC,                "GPS_UTC" },                \
  { GPS_IONO,               "GPS_IONO" },               \
  { GPS_ASCII_MSG,          "GPS_ASCII_MSG" },          \
                                                        \
  /* Glonass data */                                    \
  { GPS_GLNS_ALM,           "GPS_GLNS_ALM" },           \
  { GPS_GNSS_SAT_INFO,      "GPS_GNSS_SAT_INFO" },      \
  { GPS_GNSS_MODE,          "GPS_GNSS_MODE" },          \
                                                        \
  /* Misc data */                                       \
  { GPS_IP4_SETTINGS,       "GPS_IP4_SETTINGS" },       \
  { GPS_LAN_IF_INFO,        "GPS_LAN_IF_INFO" },        \
                                                        \
  { GPS_CRYPTED_PACKET,     "GPS_CRYPTED_PACKET" },     \
  { GPS_CRYPTED_RAW_PACKET, "GPS_CRYPTED_RAW_PACKET" }, \
                                                        \
  { GPS_SECU_INFO,          "GPS_SECU_INFO" },          \
  { GPS_SECU_SETTINGS,      "GPS_SECU_SETTINGS" },      \
  { GPS_SECU_PUBLIC_KEY,    "GPS_SECU_PUBLIC_KEY" },    \
                                                        \
  /* PZF data */                                        \
  { PZF_PCPS_TIME,          "PZF_PCPS_TIME" },          \
  { PZF_TR_DISTANCE,        "PZF_TR_DISTANCE" },        \
  { PZF_TZCODE,             "PZF_TZCODE" },             \
  { PZF_CORR_INFO,          "PZF_CORR_INFO" },          \
  { 0,                      NULL }                      \
}


/* A structure holding the number of a SV and the SV's almanac. */

typedef struct
{
  SVNO svno;
  ALM alm;
} SV_ALM;



/* A structure holding the number of a SV and the SV's ephemeris. */

typedef struct
{
  SVNO svno;
  EPH eph;
} SV_EPH;



#if _USE_PCPSDEFS

/* Attention: this differs from PCPS_TZCODE defined in pcpsdefs.h */
typedef uint16_t TZCODE;

#endif



/* The message header */

typedef struct
{
  GPS_CMD cmd;
  uint16_t len;
  CSUM data_csum;
  CSUM hdr_csum;
} MSG_HDR;



/* A union combining all kinds of parameters to be read from or written */
/* to the GPS receiver. The size of the union corresponds to the maximum */
/* size of the data part of a message. */

typedef union
{
  /* common types */
  uint16_t us;
  double d;
  SVNO svno;

  /* user data */
  SW_REV sw_rev;
  BVAR_STAT bvar_stat;
  TTM ttm;
  XYZ xyz;
  LLA lla;
  TZDL tzdl;
  PORT_PARM port_parm;
  SYNTH synth;
  ANT_INFO ant_info;
  TTM ucap;
  ENABLE_FLAGS enable_flags;
  STAT_INFO stat_info;
  ANT_CABLE_LEN ant_cable_len;
  IRIG_SETTINGS irig_tx_settings;
  RECEIVER_INFO receiver_info;
  STR_TYPE_INFO_IDX str_type_info_idx;
  PORT_INFO_IDX port_info_idx;
  PORT_SETTINGS_IDX port_settings_idx;
  POUT_INFO_IDX pout_info_idx;
  POUT_SETTINGS_IDX pout_settings_idx;
  IRIG_INFO irig_tx_info;
  MULTI_REF_SETTINGS multi_ref_settings;
  MULTI_REF_INFO multi_ref_info;
  ROM_CSUM rom_csum;
  MULTI_REF_STATUS multi_ref_status;
  RCV_TIMEOUT rcv_timeout;
  IGNORE_LOCK ignore_lock;
  IRIG_SETTINGS irig_rx_settings;
  IRIG_INFO irig_rx_info;
  MBG_REF_OFFS ref_offs;
  MBG_DEBUG_STATUS debug_status;
  XMULTI_REF_SETTINGS_IDX xmulti_ref_settings_idx;
  XMULTI_REF_INFO_IDX xmulti_ref_info_idx;
  XMULTI_REF_STATUS_IDX xmulti_ref_status_idx;
  MBG_OPT_SETTINGS opt_settings;
  MBG_OPT_INFO opt_info;
  MBG_TIME_SCALE_INFO time_scale_info;
  MBG_TIME_SCALE_SETTINGS time_scale_settings;
  NAV_ENGINE_SETTINGS nav_engine_settings;
  MBG_RAW_IRIG_DATA raw_irig_data;
  GNSS_SAT_INFO gnss_sat_info;                    //##++++++
  MBG_GNSS_MODE_INFO gnss_mode_info;              //##++++++
  MBG_GNSS_MODE_SETTINGS gnss_mode_settings;      //##++++++
  MBG_GPIO_CFG_LIMITS gpio_cfg_limits;
  MBG_GPIO_INFO_IDX gpio_info_idx;
  MBG_GPIO_SETTINGS_IDX gpio_settings_idx;
  XMULTI_REF_INSTANCES xmulti_ref_instances;
  MBG_NUM_EVT_LOG_ENTRIES num_evt_log_entries;
  MBG_EVT_LOG_ENTRY evt_log_entry;

  /* GPS system data */
  CFGH cfgh;
  SV_ALM sv_alm;
  SV_EPH sv_eph;
  UTC utc;
  IONO iono;
  ASCII_MSG ascii_msg;

  /* Misc data */
  IP4_SETTINGS ip4_settings;
  LAN_IF_INFO lan_if_info;

#if _USE_PCPSDEFS
  PCPS_TIME pcps_time;
  TR_DISTANCE tr_distance;
  TZCODE tzcode;
  CORR_INFO corr_info;
#endif

#if _USE_ENCRYPTION
  SECU_SETTINGS secu_settings;
#endif

#if _USE_GPSPRIV
  _mbg_gps_types_priv
#endif

} MSG_DATA;


#ifndef MAX_MSG_DATA_SIZE
  #ifndef ADD_MSG_DATA_SIZE
    #if _USE_ENCRYPTION
      #define ADD_MSG_DATA_SIZE  AES_BLOCK_SIZE    // round up to full paragraphs
    #else
      #define ADD_MSG_DATA_SIZE  0
    #endif
  #endif

  #define MAX_MSG_DATA_SIZE   ( sizeof( MSG_DATA ) + ADD_MSG_DATA_SIZE )
#endif



/* The structures below define parts of a binary message packet which */
/* are used with encrypted messages, */

typedef struct
{
  MSG_HDR hdr;

  #if _USE_ENCRYPTION
    uint8_t aes_initvect[AES_BLOCK_SIZE];
  #else
    // In this case this structure is just a dummy to avoid 
    // a compiler error with the function prototypes.
  #endif

} CRYPT_MSG_PREFIX;



#if _USE_ENCRYPTION

typedef struct
{
  uint8_t aes_initvect[AES_BLOCK_SIZE];

  struct
  {
    MSG_HDR enc_hdr;

    union
    {
      uint8_t bytes[MAX_MSG_DATA_SIZE];
      MSG_DATA msg_data;
    } enc_msg;

  } enc_msg;

} CRYPT_MSG_DATA;

#endif



/* A buffer holding a message header plus data part of a message */
/* For portability reasons the CMSG_BUFF structure defined below */
/* should be preferred for coding. */

typedef struct
{
  MSG_HDR hdr;

  union
  {
    uint8_t bytes[MAX_MSG_DATA_SIZE];
    MSG_DATA msg_data;

    #if _USE_ENCRYPTION
      CRYPT_MSG_DATA crypt_msg_data;
    #endif

  } u;

} MBG_MSG_BUFF;



/* The structure below is used to control the reception of messages */

typedef struct
{
  MBG_MSG_BUFF *pmb;      /* points to unencrypted message buffer */
  int buf_size;           /* size of buffer, including header */
  uint8_t *cur;           /* points to current pos inside receive buffer */
  int cnt;                /* the number of bytes to receive */
  ulong flags;            /* flags if header already completed */
  #if _USE_RCV_TSTAMP
    MBG_TMO_TIME tstamp;
  #endif
  #if _USE_CHK_TSTR
    void (*chk_tstr_fnc)( char c, TIMESTR_CHECK *arg );  /* optional handler for normal, non-protocol data */
    TIMESTR_CHECK *chk_tstr_arg;
  #endif

} MBG_MSG_RCV_CTL;


/* The flag bits below and the corresponding bit masks are used 
   for MBG_MSG_RCV_CTL::flags: */

enum
{
  MBG_MSG_RCV_CTL_BIT_RCVD_HDR,
  MBG_MSG_RCV_CTL_BIT_MSG_TOO_LONG,
  MBG_MSG_RCV_CTL_BIT_OVERFLOW,
  MBG_MSG_RCV_CTL_BIT_DECRYPT_ERR,
  MBG_MSG_RCV_CTL_BIT_DECRYPTED,
  N_MBG_MSG_RCV_CTL_BIT
};

#define MBG_MSG_RCV_CTL_RCVD_HDR     ( 1UL << MBG_MSG_RCV_CTL_BIT_RCVD_HDR )
#define MBG_MSG_RCV_CTL_MSG_TOO_LONG ( 1UL << MBG_MSG_RCV_CTL_BIT_MSG_TOO_LONG )
#define MBG_MSG_RCV_CTL_OVERFLOW     ( 1UL << MBG_MSG_RCV_CTL_BIT_OVERFLOW )
#define MBG_MSG_RCV_CTL_DECRYPT_ERR  ( 1UL << MBG_MSG_RCV_CTL_BIT_DECRYPT_ERR )
#define MBG_MSG_RCV_CTL_DECRYPTED    ( 1UL << MBG_MSG_RCV_CTL_BIT_DECRYPTED )


typedef struct 
{
  MBG_MSG_BUFF *pmb;
  int buf_size;
  int xfer_mode;

  #if _USE_MUTEX
    MBG_MUTEX xmt_mutex;
  #endif

} MBG_MSG_XMT_CTL;


// codes used with MBG_MSG_CTL::xfer_mode:

enum
{
  MBG_XFER_MODE_NORMAL,
  MBG_XFER_MODE_ENCRYTED,
  N_MBG_XFER_MODE
};



#if _USE_SOCKET_IO

#if !defined ( MBGEXTIO_RCV_TIMEOUT_SOCKET )
  #define MBGEXTIO_RCV_TIMEOUT_SOCKET   2000   // [ms]
#endif

#define LAN_XPT_PORT 10001

#ifndef INVALID_SOCKET
  #define INVALID_SOCKET -1
#endif

typedef struct
{
  int sockfd;
  struct sockaddr_in addr;

} SOCKET_IO_STATUS;

#endif  // _USE_SOCKET_IO


#if _USE_SERIAL_IO

#endif  // _USE_SERIAL_IO



typedef struct 
{
  MBG_MSG_RCV_CTL rcv;
  MBG_MSG_XMT_CTL xmt;

  int conn_type;
  int io_error;
  ulong msg_rcv_timeout;    // binary message receive timeout [ms]
  ulong char_rcv_timeout;   // serial character receive timeout [ms]

  #if _USE_ENCRYPTION
    uint8_t aes_initvect[AES_BLOCK_SIZE];
    uint8_t aes_keyvect[AES_BLOCK_SIZE];
  #endif

  #if _USE_SOCKET_IO
    SECU_SETTINGS secu_settings;
  #endif

  #if _USE_SERIAL_IO || _USE_SOCKET_IO || _USE_USB_IO
    union
    {
      #if _USE_SOCKET_IO
        SOCKET_IO_STATUS sockio;
      #endif

      #if _USE_SERIAL_IO
        SERIAL_IO_STATUS serio;
      #endif

      #if _USE_USB_IO
        USB_IO_STATUS usbio;
      #endif
    } st;
  #endif

} MBG_MSG_CTL;


// codes used with MBG_MSG_CTL::conn_type:

enum
{
  MBG_CONN_TYPE_SERIAL,
  MBG_CONN_TYPE_SOCKET,
  MBG_CONN_TYPE_USB,
  N_MBG_CONN_TYPE
};



/* function prototypes: */

#if _USE_GPSSERIO_FNC

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 CSUM msg_csum_update( CSUM csum, uint8_t *p, int n ) ;
 CSUM msg_csum( uint8_t *p, int n ) ;
 CSUM msg_hdr_csum( MSG_HDR *pmh ) ;
 int chk_hdr_csum( MSG_HDR *pmh ) ;
 int chk_data_csum( MBG_MSG_BUFF *pmb ) ;
 int encrypt_message( MBG_MSG_CTL *pmctl, CRYPT_MSG_PREFIX *pcmp, MBG_MSG_BUFF *pmb ) ;
 int decrypt_message( MBG_MSG_CTL *pmctl ) ;
 void set_encryption_mode( MBG_MSG_CTL *pmctl, int mode, const char *key ) ;
 int xmt_tbuff( MBG_MSG_CTL *pmctl ) ;
 int xmt_cmd( MBG_MSG_CTL *pmctl, GPS_CMD cmd ) ;
 int xmt_cmd_us( MBG_MSG_CTL *pmctl, GPS_CMD cmd, uint16_t us ) ;
 int check_transfer( MBG_MSG_RCV_CTL *prctl, uint8_t c ) ;

/* ----- function prototypes end ----- */

#endif // _USE_GPSSERIO_FNC

/* End of header body */


#undef _ext

#ifdef __cplusplus
}
#endif


#endif  /* _GPSSERIO_H */

