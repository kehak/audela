
/**************************************************************************
 *
 *  $Id: pcpsdefs.h 1.48 2011/11/25 15:02:28 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    General definitions for Meinberg plug-in devices.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsdefs.h $
 *  Revision 1.48  2011/11/25 15:02:28  martin
 *  Support on-board event logs.
 *  Revision 1.47  2011/11/25 10:22:44  martin
 *  Modified handling of pragma pack().
 *  Made command group codes obsolete. They are still supported
 *  when building firmware, though.
 *  Support PTP unicast configuration.
 *  Support GPIO configuration.
 *  Support PZF180PEX.
 *  Added commands to read CORR_INFO, read/write TR_DISTANCE,
 *  PCPS_SYNC_PZF status, and associated structures. 
 *  Added an initializer for a table of GPS command code/names.
 *  Added definitions MBG_PCPS_FMT_STATUS.
 *  Updated some comments.
 *  Revision 1.46  2011/01/13 11:44:29Z  martin
 *  Moved status port register definitions here.
 *  Revision 1.45  2010/09/06 07:36:24  martin
 *  Support GPS180PEX and TCR180PEX.
 *  Moved some IRIG related definitions to gpsdefs.h.
 *  Revision 1.44  2010/06/30 11:09:49  martin
 *  Added definitions for JJY longwave transmitter.
 *  Renamed MBG_RAW_IRIG_DATA::data field to data_bytes
 *  since "data" is a reserved word for C51 architecture.
 *  Revision 1.43  2010/02/09 11:20:17Z  martin
 *  Renamed yet unused CORR_INFO::flags field to signal and updated comments.
 *  Revision 1.42  2010/01/12 14:02:37  daniel
 *  Added definitions to support reading the raw IRIG data bits.
 *  Revision 1.41  2009/06/19 12:16:42Z  martin
 *  Added PCPS_GIVE_IRIG_TIME command and associated definitions.
 *  Revision 1.40  2009/06/08 19:29:11  daniel
 *  Support PTP configuration.
 *  Support LAN_IF configuration
 *  Added definition of PCPS_CMD_INFO.
 *  Revision 1.39  2009/03/19 08:58:09  martin
 *  Added PCPS_GET_IRIG_CTRL_BITS cmd and associated data type.
 *  Revision 1.38  2009/03/10 17:07:09  martin
 *  Support configurable time scales and GPS UTC parameters.
 *  Added ext. status flag for time scales, and PCPS_LS_ANN_NEG.
 *  Added bit mask PCPS_SCALE_MASK.
 *  Revision 1.37  2008/12/05 16:01:37Z  martin
 *  Added ref types PTP, FRC, and WWVB.
 *  Added ref names MSF, PTP, FRC, and WWVB.
 *  Added device codes TCR170PEX, PTP270PEX, and FRC511PEX.
 *  Added macros to convert the endianess of structures.
 *  Moved definitions of PCPS_HRT_FRAC_SCALE and
 *  PCPS_HRT_FRAC_SCALE_FMT here.
 *  Added definitions of PCPS_HRT_FRAC_CONVERSION_TYPE
 *  and PCPS_HRT_BIN_FRAC_SCALE.
 *  Escaped '<' and '>' characters for doxygen.
 *  Modified comments for PCPS_TZDL.
 *  Removed trailing spaces and obsolete comments.
 *  Revision 1.36  2008/01/17 09:20:25Z  daniel
 *  Added new REF type PCPS_REF_MSF.
 *  Revision 1.35  2008/01/17 09:18:46Z  daniel
 *  Made comments compatible for doxygen parser.
 *  No sourcecode changes. 
 *  Revision 1.34  2007/07/17 08:22:47Z  martin
 *  Added support for TCR511PEX and GPS170PEX.
 *  Revision 1.33  2007/05/20 21:39:51Z  martin
 *  Added support for PEX511.
 *  Added PCPS_GET_STATUS_PORT cmd code for devices 
 *  that do not support a hardware status port.
 *  Revision 1.32  2007/03/29 12:57:32Z  martin
 *  Renamed some TZCODE numbers for unique naming conventions.
 *  Added definitions of the older symbols for compatibility.
 *  Revision 1.31  2007/03/26 15:42:31Z  martin
 *  Replaced PCPS_REF_OFFS and associated definitions by MBG_REF_OFFS, etc.,
 *  which are defined in gpsdefs.h.
 *  Added PCPS_GET_DEBUG_STATUS code.
 *  Revision 1.30  2006/06/29 10:13:13  martin
 *  Added some descriptive comments.
 *  Revision 1.29  2006/06/14 12:59:12Z  martin
 *  Added support for TCR511PCI.
 *  Revision 1.28  2006/05/18 09:45:16  martin
 *  Added data types used with PZF receivers.
 *  Revision 1.27  2006/05/03 10:19:14Z  martin
 *  Added initializers for reference source names.
 *  Revision 1.26  2006/03/10 10:24:45Z  martin
 *  New definitions for PCI511.
 *  Added command codes to configure programmable pulse outputs.
 *  Revision 1.25  2005/11/03 15:05:16Z  martin
 *  New definitions for GPS170PCI.
 *  New types PCPS_TIME_STATUS and PCPS_TIME_STATUS_X.
 *  Removed obsolete enumeration of PCPS_TIME fields.
 *  Revision 1.24  2005/05/03 07:56:55Z  martin
 *  Added command PCPS_GET_SYNTH_STATE.
 *  Revision 1.23  2005/03/29 12:51:10Z  martin
 *  New cmd code PCPS_GENERIC_IO.
 *  Revision 1.22  2004/12/09 11:03:37Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.21  2004/11/09 12:55:32Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Added workaround macros for some structure sizes because the C166 
 *  compiler always reports an even structure size even if the structure 
 *  size is in fact odd, which might lead to different sizes in C166 and 
 *  other environments.
 *  Modifications were required in order to be able to configure IRIG 
 *  settings of cards which provide both IRIG input and output.
 *  The existing codes have been renamed with .._RX.. and are used to 
 *  configure the IRIG receiver (input). New codes have been defined 
 *  used to configure the IRIG transmitter.
 *  Renamed PC_GPS_STAT to PC_GPS_BVAR_STAT.
 *  Use more specific data types than generic types.
 *  Revision 1.20  2004/10/14 15:01:23  martin
 *  Added support for TCR167PCI.
 *  Revision 1.19  2004/06/16 12:46:33Z  martin
 *  Moved OPT_SETTINGS related definitions to gpsdefs.h,
 *  and renamed symbols from PCPS_.. to to MBG_...
 *  Revision 1.18  2004/04/26 14:27:08Z  martin
 *  Added union PCPS_TIME_UNION.
 *  Revision 1.17  2003/05/27 08:50:35Z  MARTIN
 *  New commands PCPS_GIVE_UCAP_ENTRIES, PCPS_GIVE_UCAP_EVENT
 *  and associated definitions which allow faster reading of
 *  user capture events and monitoring of the capture buffer
 *  fill level.
 *  Revision 1.16  2003/04/03 10:48:53  martin
 *  Support for PCI510, GPS169PCI, and TCR510PCI.
 *  New codes PCPS_GET_REF_OFFS, PCPS_SET_REF_OFFS 
 *  and related structures.
 *  New codes PCPS_GET_OPT_INFO, PCPS_SET_OPT_SETTINGS
 *  and related structures.
 *  New codes PCPS_GET_IRIG_INFO, PCPS_SET_IRIG_SETTINGS.
 *  Preliminary PCPS_TZDL structure and cmd codes 
 *  to read/write that structure.
 *  Revision 1.15  2002/08/08 13:24:03  MARTIN
 *  Moved definition of ref time sources here.
 *  Added new ref time source IRIG.
 *  Added new cmd to clear time capture buffer.
 *  Fixed some comments.
 *  Revision 1.14  2002/01/31 13:39:38  MARTIN
 *  Added new GPS data type codes for RECEIVER_INFO, etc.
 *  New PCPS_HR_TIME status flag PCPS_IO_BLOCKED.
 *  Moved REV_NUMs defining special features to pcpsdev.h.
 *  Removed obsolete initializer for framing string table.
 *  Updated some comments.
 *  Removed obsolete code.
 *  Revision 1.13  2001/12/03 16:15:14  martin
 *  Introduced PCPS_TIME_STAMP which allows to handle high precision
 *  time stamps.
 *  Replaced the sec/frac fields in PCPS_HR_TIME by PCPS_TIME_STAMP.
 *  This is compatible on byte level but may require source code
 *  modifications.
 *  Introduced new command PCPS_SET_EVENT_TIME which is used
 *  EXCLUSIVELY with a custom GPS firmware.
 *  Revision 1.12  2001/10/16 10:07:42  MARTIN
 *  Defined PCI509 firmware revision number which supports
 *  baud rate higher than standard.
 *  Revision 1.11  2001/03/30 13:02:39  MARTIN
 *  Control alignment of structures from new file use_pack.h.
 *  Defined initializers with valid framing parameters.
 *  Revision 1.10  2001/02/28 15:39:25  MARTIN
 *  Modified preprocessor syntax.
 *  Revision 1.9  2001/02/16 11:32:05  MARTIN
 *  Renamed "PROM" or "EPROM" in comments or and names to
 *  "FW" or firmware.
 *  This includes the cmd codes PCPS_GIVE_PROM_ID_... which have
 *  been renamed to PCPS_GIVE_FW_ID_...
 *  Renamed structure PCPS_TIME_SET to PCPS_STIME.
 *  Renamed return code PCPS_ERR_NONE to PCPS_SUCCESS.
 *  Modified some comments.
 *  Revision 1.8  2000/10/11 09:17:09  MARTIN
 *  Cleaned up comment syntax.
 *  Revision 1.7  2000/07/21 14:16:30  MARTIN
 *  Modified some comments.
 *  Added PCI definitions.
 *  Renamed PCPS_GET_GPS_DATA to PCPS_READ_GPS_DATA.
 *  Renamed PCPS_SET_GPS_DATA to PCPS_WRITE_GPS_DATA.
 *  New types PCPS_SERIAL and PCPS_TZCODE.
 *  Removed PCPS_SERIAL_BYTES and PCPS_TZCODE_BYTES, may use sizeof()
 *  the types instead.
 *  New type PCPS_TIME_SET which can be used to write date and time
 *  to the clock.
 *  Revision 1.6  2000/06/07 12:09:31  MARTIN
 *  renamed PCPS_SERIAL_GROUP to PCPS_CFG_GROUP
 *  renamed PCPS_ERR_SERIAL to PCPS_ERR_CFG
 *  modified definitions for baud rate, framing, and mode
 *  added PCPS_SN_... definitions
 *  added PCPS_GET_TZCODE and PCPS_SET_TZCODE definitions
 *  added PC_GPS_ANT_CABLE_LEN definition
 *  added RCS keywords
 *  updated some comments
 *
 * -----------------------------------------------------------------------
 *  Changes before put under RCS control:
 *
 *  Revision 1.5  2000/03/24
 *    Introduced PCPS_GIVE_SERNUM
 *    Cleaned up for definitions for serial parameter byte
 *    Reviewed and updated comments.
 *
 *  1998/07/22
 *    Introduced PCPS_HR_TIME.
 *    Rearranged order of definitions.
 *    Reviewed and updated comments.
 *
 *  1997/06/12
 *    GPS definitions added.
 *
 *  1996/01/25
 *    PCPS_TIME redefined from an array of bytes to a structure.
 *
 **************************************************************************/

#ifndef _PCPSDEFS_H
#define _PCPSDEFS_H


/* Other headers to be included */

#include <words.h>
#include <use_pack.h>


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


/**
 * @brief Enumeration of the ref time signal sources used by Meinberg devices
 */
enum
{
  PCPS_REF_NONE,   /**< (unknown or not defined) */
  PCPS_REF_DCF,    /**< see http://www.meinberg.de/english/info/dcf77.htm */
  PCPS_REF_GPS,    /**< see http://www.meinberg.de/english/info/gps.htm */
  PCPS_REF_IRIG,   /**< see http://www.meinberg.de/english/info/irig.htm */
  PCPS_REF_MSF,    /**< MSF Receiver (UK) */
  PCPS_REF_PTP,    /**< PTP/IEEE1588 network protocol */
  PCPS_REF_FRC,    /**< Free Running Clock */
  PCPS_REF_WWVB,   /**< WWVB Receiver (US) */
  PCPS_REF_JJY,    /**< JJY Receiver (Japan) */
  N_PCPS_REF       /**< number of valid ref time sources */
};


/* Initializers for the reference source names */

#define PCPS_REF_NAME_NONE_ENG  "unknown" 
#define PCPS_REF_NAME_NONE_GER  "nicht bekannt" 
#define PCPS_REF_NAME_DCF       "DCF77"
#define PCPS_REF_NAME_GPS       "GPS"
#define PCPS_REF_NAME_IRIG      "IRIG"
#define PCPS_REF_NAME_MSF       "MSF"
#define PCPS_REF_NAME_PTP       "PTP"
#define PCPS_REF_NAME_FRC       "FRC"
#define PCPS_REF_NAME_WWVB      "WWVB"
#define PCPS_REF_NAME_JJY       "JJY"


#define PCPS_REF_NAMES_ENG \
{                          \
  PCPS_REF_NAME_NONE_ENG,  \
  PCPS_REF_NAME_DCF,       \
  PCPS_REF_NAME_GPS,       \
  PCPS_REF_NAME_IRIG,      \
  PCPS_REF_NAME_MSF,       \
  PCPS_REF_NAME_PTP,       \
  PCPS_REF_NAME_FRC,       \
  PCPS_REF_NAME_WWVB,      \
  PCPS_REF_NAME_JJY        \
}


#define PCPS_REF_NAMES_LSTR                            \
{                                                      \
  { PCPS_REF_NAME_NONE_ENG, PCPS_REF_NAME_NONE_GER },  \
  { PCPS_REF_NAME_DCF, NULL },                         \
  { PCPS_REF_NAME_GPS, NULL },                         \
  { PCPS_REF_NAME_IRIG, NULL },                        \
  { PCPS_REF_NAME_MSF, NULL },                         \
  { PCPS_REF_NAME_PTP, NULL },                         \
  { PCPS_REF_NAME_FRC, NULL },                         \
  { PCPS_REF_NAME_WWVB, NULL },                        \
  { PCPS_REF_NAME_JJY, NULL }                          \
}



/**
 * @brief Meinberg PCI vendor ID (assigned by PCI SIG)
 */
#define PCI_VENDOR_MEINBERG     0x1360

/* PCI device ID numbers (assigned by Meinberg) *
 *   High byte:  type of ref time source
 *   Low Byte:   enumeration of device types
 */
#define PCI_DEV_PCI32           ( ( PCPS_REF_DCF << 8 )  | 0x01 )
#define PCI_DEV_PCI509          ( ( PCPS_REF_DCF << 8 )  | 0x02 )
#define PCI_DEV_PCI510          ( ( PCPS_REF_DCF << 8 )  | 0x03 )
#define PCI_DEV_PCI511          ( ( PCPS_REF_DCF << 8 )  | 0x04 )
#define PCI_DEV_PEX511          ( ( PCPS_REF_DCF << 8 )  | 0x05 )
#define PCI_DEV_PZF180PEX       ( ( PCPS_REF_DCF << 8 )  | 0x06 )

#define PCI_DEV_GPS167PCI       ( ( PCPS_REF_GPS << 8 )  | 0x01 )
#define PCI_DEV_GPS168PCI       ( ( PCPS_REF_GPS << 8 )  | 0x02 )
#define PCI_DEV_GPS169PCI       ( ( PCPS_REF_GPS << 8 )  | 0x03 )
#define PCI_DEV_GPS170PCI       ( ( PCPS_REF_GPS << 8 )  | 0x04 )
#define PCI_DEV_GPS170PEX       ( ( PCPS_REF_GPS << 8 )  | 0x05 )
#define PCI_DEV_GPS180PEX       ( ( PCPS_REF_GPS << 8 )  | 0x06 )

#define PCI_DEV_TCR510PCI       ( ( PCPS_REF_IRIG << 8 ) | 0x01 )
#define PCI_DEV_TCR167PCI       ( ( PCPS_REF_IRIG << 8 ) | 0x02 )
#define PCI_DEV_TCR511PCI       ( ( PCPS_REF_IRIG << 8 ) | 0x03 )
#define PCI_DEV_TCR511PEX       ( ( PCPS_REF_IRIG << 8 ) | 0x04 )
#define PCI_DEV_TCR170PEX       ( ( PCPS_REF_IRIG << 8 ) | 0x05 )
#define PCI_DEV_TCR180PEX       ( ( PCPS_REF_IRIG << 8 ) | 0x06 )

#define PCI_DEV_PTP270PEX       ( ( PCPS_REF_PTP  << 8 ) | 0x01 )

#define PCI_DEV_FRC511PEX       ( ( PCPS_REF_FRC  << 8 ) | 0x01 )



// definitions used for the status port register
// (not to be intermixed with PCPS_TIME_STATUS)
typedef uint8_t PCPS_STATUS_PORT;  /**< see @ref group_status_port "Bitmask" */

/**
 * @defgroup group_status_port Bit masks of PCPS_STATUS_PORT
 *
 * Bit definitions used with the #PCPS_STATUS_PORT register.
 *
 * The flags #PCPS_ST_SEC and #PCPS_ST_MIN are cleared whenever the clock
 * is read, so they are not very reliable in multitasking environments.
 *
 * @note The PCPS_ST_IRQF flag originates from old ISA cards.
 * Some PCI cards also support this, but in case of PCI cards the
 * associated flag of the PCI interface chip should be checked to see
 * if a certain card has generated an IRQ on the PC bus.
 *
 * The macro _pcps_ddev_has_gen_irq() cares about this and should be used
 * to determine in a portable way whether a card has generated an IRQ.
 *
 * @{ */

#define PCPS_ST_BUSY  0x01  /**< the clock is busy filling the output FIFO */
#define PCPS_ST_IRQF  0x02  /**< the clock has generated an IRQ on the PC bus (ISA only)*/
#define PCPS_ST_MOD   0x20  /**< the raw demodulated DCF77 signal */
#define PCPS_ST_SEC   0x40  /**< seconds have changed since last reading */
#define PCPS_ST_MIN   0x80  /**< minutes have changed since last reading */

/** @} group_status_port */

/**
 * A format string to be used with snprintb() which is available on some Unix
 * systems to print information held in a bit coded variable.
 */
#define MBG_PCPS_FMT_STATUS \
  "\177\20b\0FREER\0b\1DL_ENB\0b\2SYNCD\0b\3DL_ANN\0b\4UTC\0b\5LS_ANN\0b\6IFTM\0b\7INVT" \
  "\0b\x08LS_ENB\0b\11ANT_FAIL\0b\x0aLS_ANN_NEG\0b\x0bSCALE_GPS\0b\x0cSCALE_TAI\0\0"



/** @defgroup group_cmd_bytes Command bytes used to access the device

  The commands described below are used to access computer peripherals
  manufactured by Meinberg.

  The header files pcpsdev.h and pcpsdrvr.h contain macros which can be
  used to check if a detected device supports a certain feature or command.
  If checking is required then the name of the macro is given in the
  comments below.

  Some commands expect parameters to be passed to the board. In that
  case, the board returns the number of parameter bytes expected when
  the command code is passed. Every parameter byte has to be supplied
  to the board exactly like a command byte.
  Refer to function pcps_write_data() and the macro _pcps_write_var()
  for details.


 - #PCPS_GIVE_TIME<br>
    Return a PCPS_TIME structure with current date,
    time and status. Supported by all clocks.

 - #PCPS_GIVE_TIME_NOCLEAR<br>
    Same as #PCPS_GIVE_TIME but the bits #PCPS_ST_SEC
    and #PCPS_ST_MIN (see pcpsdev.h) of the status
    port are not cleared.
    Supported by all clocks except PC31/PS31 with
    firmware version older than v3.0.
    This is mainly used by the DOS TSR and should
    not be used in other environments.

 - #PCPS_GIVE_SYNC_TIME<br>
    Return a ::PCPS_TIME structure with date and time
    of last synchronization of the clock or
    the last time set via the interface.
    _pcps_has_sync_time() checks whether supported.

 - #PCPS_GIVE_HR_TIME<br>
    Return a PCPS_HR_TIME structure with current
    date, time and status. This command should be
    used to read the clock with higher resolution.
    _pcps_has_hr_time() checks whether supported.

 - #PCPS_GIVE_IRIG_TIME<br>
    Return a PCPS_IRIG_TIME structure with day-of-year,
    time and status as decoded from the IRIG signal.
    _pcps_has_irig_time() checks whether supported.

 - #PCPS_SET_TIME<br>
    Set the board date, time and status. This
    command expects sizeof( ::PCPS_STIME ) parameter
    bytes.
    _pcps_can_set_time() checks whether supported.

 - #PCPS_SET_EVENT_TIME<br>
    Send a high resolution time stamp to the clock to
    configure a UTC time when the clock shall generate
    some event. This command expects a PCPS_TIME_STAMP
    parameter.
    _pcps_has_event_time() checks whether supported.
    (requires custom GPS CERN firmware)

 - #PCPS_IRQ_NONE<br>
    Disable the board's hardware IRQ<br>
 - #PCPS_IRQ_1_SEC<br>
    Enable hardware IRQs once per second<br>
 - #PCPS_IRQ_1_MIN<br>
    Enable hardware IRQs once per minute<br>
 - #PCPS_IRQ_10_MIN<br>
    Enable hardware IRQs once per 10 minutes<br>
 - #PCPS_IRQ_30_MIN<br>
    Enable hardware IRQs once per 30 minutes<br>

 - #PCPS_GET_SERIAL<br>
   #PCPS_SET_SERIAL<br>
    These commands read or set the configuration
    of a clock's serial port COM0. The commands 
    expect PCPS_SERIAL_BYTES parameter bytes and
    should be used preferably with the DCF77
    clocks which have only one COM port.
    _pcps_has_serial() checks whether supported.
    Recent GPS clocks' COM ports should be cfg'd
    using the structures RECEIVER_INFO, PORT_INFO,
    and STR_TYPE_INFO.
    _pcps_has_receiver_info() checks whether
    these are supported. If they are not, then
    the code #PC_GPS_PORT_PARM together with the
    #PCPS_READ_GPS_DATA and #PCPS_WRITE_GPS_DATA
    commands should be used.

 - #PCPS_GET_TZCODE<br>
   #PCPS_SET_TZCODE<br>
    These commands read or set a DCF77 clock's
    time zone code and should be used preferably
    with the newer DCF77 clocks which have limited
    support of different time zones.
    _pcps_has_tzcode() checks whether supported.
    A GPS clock's time zone must be cfg'd using
    the code #PC_GPS_TZDL together with the
    #PCPS_READ_GPS_DATA and #PCPS_WRITE_GPS_DATA
    commands.

 - #PCPS_GET_PCPS_TZDL<br>
   #PCPS_SET_PCPS_TZDL<br>
    These commands read or set a DCF77 clock's
    time zone / daylight saving configuration.
    _pcps_has_pcps_tzdl() checks whether supported.
    A GPS clock's time zone must be cfg'd using
    the code #PC_GPS_TZDL together with the
    #PCPS_READ_GPS_DATA and #PCPS_WRITE_GPS_DATA
    commands.

 - #PCPS_GET_REF_OFFS<br>
   #PCPS_SET_REF_OFFS<br>
    These commands can be used to configure the
    reference time offset from UTC for clocks
    which can't determine the offset automatically,
    e.g. from an IRIG input signal.
    _pcps_has_ref_offs() checks whether supported.

 - #PCPS_GET_OPT_INFO<br>
   #PCPS_SET_OPT_SETTINGS<br>
    These commands can be used to configure some
    optional settings, controlled by flags.
    When reading, the clock returns a MBG_OPT_INFO
    structure which contains the supported values,
    plus the current settings.
    When writing, clocks accepts a MBG_OPT_SETTINGS
    structure only which contain the desired settings
    of the supported flags only.
    _pcps_has_opt_flags() checks whether supported.

 - #PCPS_GET_IRIG_RX_INFO<br>
   #PCPS_SET_IRIG_RX_SETTINGS<br>
   #PCPS_GET_IRIG_TX_INFO<br>
   #PCPS_SET_IRIG_TX_SETTINGS<br>
    These commands can be used to configure IRIG 
    inputs and outputs.<br>
    When reading, the clock returns an IRIG_INFO 
    structure which contains the supported values, 
    plus the current settings.<br>
    When writing, clocks accepts an IRIG_SETTINGS 
    structure only which contain the desired settings 
    only. _pcps_is_irig_rx() and _pcps_is_irig_tx() 
    check whether supported.

 - #PCPS_GET_IRIG_CTRL_BITS<br>
    This command can be used to retrieve the control function
    bits of the latest IRIG input frame. Those bits may carry
    some well-known information as in the IEEE1344 code, but
    may also contain some customized information, depending on
    the IRIG frame type and the configuration of the IRIG generator.
    So these bits are returned as-is and must be interpreted 
    by the application.
    _pcps_has_irig_ctrl_bits() checks whether supported.

 - #PCPS_GET_SYNTH<br>
   #PCPS_SET_SYNTH<br>
   #PCPS_GET_SYNTH_STATE<br>
    These commands can be used to configure an on-board
    frequency synthesizer and query the synthesizer
    status. The commands are only supported if the board
    supports the RECEIVER_INFO structure and the flag
    #GPS_HAS_SYNTH is set in the RECEIVER_INFO::features.
    _pcps_has_synth() checks whether supported.
    The structures SYNTH and SYNTH_STATE used with these
    commands are defined in gpsdefs.h.

 - #PCPS_GIVE_FW_ID_1<br>
   #PCPS_GIVE_FW_ID_2<br>
    Returns the first/second block of PCPS_FIFO_SIZE
    characters of the firmware ID string. These
    commands can be used to check if the board
    responds properly. This is done by the clock
    detection functions.
 
 - #PCPS_GIVE_SERNUM<br>
    Returns PCPS_FIFO_SIZE characters of the
    clock's serial number.
    _pcps_has_sernum() checks whether supported.

 - #PCPS_GENERIC_IO<br>
    Generic I/O read and write. Can be used to query
    specific data, e.g. a selected element of an array.
    _pcps_has_generic_io() checks whether supported.

 - #PCPS_GET_DEBUG_STATUS<br>
    This command reads a MBG_DEBUG_STATUS structure
    which represents the internal status of the
    IRIG decoder and some additional debug info.
    _pcps_has_debug_status() checks whether supported.

 - #PCPS_READ_GPS_DATA<br>
   #PCPS_WRITE_GPS_DATA<br>
    These commands are used by the functions
    pcps_read_gps_data() and pcps_write_gps_data()
    to read or write large data structures to
    Meinberg GPS plug-in clocks.
    _pcps_is_gps() checks whether supported.

 - #PCPS_CLR_UCAP_BUFF<br>
    Clear a clock's time capture buffer.
    _pcps_can_clr_ucap_buff() checks whether
    supported.

 - #PCPS_GIVE_UCAP_ENTRIES<br>
    Read a PCPS_UCAP_ENTRIES structure which
    reports the max number of entries and the
    currently used number of entries in the
    user capture buffer.
    _pcps_has_ucap() checks whether supported.

 - #PCPS_GIVE_UCAP_EVENT<br>
    Read capture events using a PCPS_HR_TIME
    structure. This is faster than reading using the
    GPS command #PC_GPS_UCAP. If no capture event is
    available then the structure is filled with 0s.
    _pcps_has_ucap() checks whether supported.

 - #PCPS_GET_CORR_INFO<br>
    Read PZF correlation info using a CORR_INFO
    structure.
    _pcps_has_pzf() checks whether supported.

 - #PCPS_GET_TR_DISTANCE<br>
   #PCPS_SET_TR_DISTANCE<br>
    Read or write distance from the RF transmitter.
    This is used to compensate the RF propagation delay
    for PZF receivers.
    _pcps_has_tr_distance() checks whether supported.

 - #PCPS_CLR_EVT_LOG<br>
    Clear on-board event log.
    _pcps_has_evt_log() checks whether supported.

 - #PCPS_NUM_EVT_LOG_ENTRIES<br>
    Read max number of num event log entries which can
    be saved on the board, and how many entries actually
    have been saved.
    _pcps_has_evt_log() checks whether supported.

 - #PCPS_FIRST_EVT_LOG_ENTRY<br>
 - #PCPS_NEXT_EVT_LOG_ENTRY<br>
    Read first (oldest) or next event log entry.
    _pcps_has_evt_log() checks whether supported.

 - #PCPS_FORCE_RESET<br>
    Resets the microprocessor on the device. This is
    for special test scenarios only and should not be
    used by standard applications since this may lock up
    the PC.

 The command codes listed above are defined below.

 @{ */


#if _IS_MBG_FIRMWARE  //##++

// These group codes are obsolete and should be removed.
// The explicite command codes defined below should be used instead.
#define PCPS_GIVE_TIME_GROUP     0x00
#define PCPS_SET_TIME_GROUP      0x10
#define PCPS_IRQ_GROUP           0x20
#define PCPS_CFG_GROUP           0x30
#define PCPS_GIVE_DATA_GROUP     0x40
#define PCPS_GPS_DATA_GROUP      0x50
#define PCPS_CTRL_GROUP          0x60
#define PCPS_CFG2_GROUP          0x70

#endif



#define PCPS_GIVE_TIME           0x00
#define PCPS_GIVE_TIME_NOCLEAR   0x01
#define PCPS_GIVE_SYNC_TIME      0x02  // only supported if _pcps_has_sync_time()
#define PCPS_GIVE_HR_TIME        0x03  // only supported if _pcps_has_hr_time()
#define PCPS_GIVE_IRIG_TIME      0x04  // only supported if _pcps_has_irig_time()

#define PCPS_SET_TIME            0x10
/* on error, return PCPS_ERR_STIME */

/* Attention: The code below can be used EXCLUSIVELY */
/* with a GPS167PCI with customized CERN firmware !! */
/* _pcps_has_event_time() checks whether supported. */
#define PCPS_SET_EVENT_TIME      0x14

#define PCPS_IRQ_NONE            0x20
#define PCPS_IRQ_1_SEC           0x21
#define PCPS_IRQ_1_MIN           0x22
#define PCPS_IRQ_10_MIN          0x24
#define PCPS_IRQ_30_MIN          0x28

#define PCPS_GET_SERIAL          0x30
#define PCPS_SET_SERIAL          0x31
/* on error, return PCPS_ERR_CFG */

typedef uint8_t PCPS_SERIAL;


#define PCPS_GET_TZCODE          0x32
#define PCPS_SET_TZCODE          0x33
/* on error, return PCPS_ERR_CFG */

typedef uint8_t PCPS_TZCODE;

/* the following codes are used with the PCPS_TZCODE parameter: */
enum
{
  PCPS_TZCODE_CET_CEST,  /* default as broadcasted by DCF77 (UTC+1h/UTC+2h) */
  PCPS_TZCODE_CET,       /* always CET (UTC+1h), discard DST */
  PCPS_TZCODE_UTC,       /* always UTC */
  PCPS_TZCODE_EET_EEST,  /* East European Time, CET/CEST + 1h */
  N_PCPS_TZCODE          /* the number of valid codes */
};

/* the definitions below are for compatibily only: */
#define PCPS_TZCODE_MEZMESZ  PCPS_TZCODE_CET_CEST
#define PCPS_TZCODE_MEZ      PCPS_TZCODE_CET
#define PCPS_TZCODE_OEZ      PCPS_TZCODE_EET_EEST


#define PCPS_GET_PCPS_TZDL       0x34
#define PCPS_SET_PCPS_TZDL       0x35
/* on error, return PCPS_ERR_CFG */


/**
 * The structures below can be used to configure a clock's
 * time zone/daylight saving setting. This structure is shorter
 * than the TZDL structure used with GPS clocks.
 */
typedef struct
{
  // The year_or_wday field below contains the full year number
  // or 0..6 == Sun..Sat if the DL_AUTO_FLAG is set; see below.
  uint16_t year_or_wday;
  uint8_t month;
  uint8_t mday;
  uint8_t hour;
  uint8_t min;
} PCPS_DL_ONOFF;

#define _mbg_swab_pcps_dl_onoff( _p )  \
{                                      \
  _mbg_swab16( &(_p)->year_or_wday );  \
}

/**
 * If the field year_or_wday is or'ed with the constant DL_AUTO_FLAG
 * defined below then this means that start and end of daylight saving
 * time shall be computed automatically for each year. In this case
 * the remaining bits represent the day-of-week after the specified
 * mday/month at which the change shall occur. If that flag is not set
 * then the field contains the full four-digit year number and the
 * mday/month values specify the exact date of that year.
 */
#define DL_AUTO_FLAG  0x8000  // also defined in gpsdefs.h

typedef struct
{
  int16_t offs;          /**< offset from UTC to local time [min] */
  int16_t offs_dl;       /**< additional offset if DST enabled [min] */
  PCPS_DL_ONOFF tm_on;   /**< date/time when daylight saving starts */
  PCPS_DL_ONOFF tm_off;  /**< date/time when daylight saving ends */
} PCPS_TZDL;

#define _mbg_swab_pcps_tzdl( _p )            \
{                                            \
  _mbg_swab16( &(_p)->offs );                \
  _mbg_swab16( &(_p)->offs_dl );             \
  _mbg_swab_pcps_dl_onoff( &(_p)->tm_on );   \
  _mbg_swab_pcps_dl_onoff( &(_p)->tm_off );  \
}



#define PCPS_GET_REF_OFFS        0x36
#define PCPS_SET_REF_OFFS        0x37
/* on error, return PCPS_ERR_CFG */

/* The associated type MBG_REF_OFFS is defined in gpsdefs.h. */


#define PCPS_GET_OPT_INFO        0x38
#define PCPS_SET_OPT_SETTINGS    0x39
/* on error, return PCPS_ERR_CFG */

/* The associated structures MBG_OPT_INFO and MBG_OPT_SETTINGS
   are defined in gpsdefs.h. */


#define PCPS_GET_IRIG_RX_INFO     0x3A
#define PCPS_SET_IRIG_RX_SETTINGS 0x3B
/* on error, return PCPS_ERR_CFG */

#define PCPS_GET_IRIG_TX_INFO     0x3C
#define PCPS_SET_IRIG_TX_SETTINGS 0x3D
/* on error, return PCPS_ERR_CFG */

/* The associated structures IRIG_INFO and IRIG_SETTINGS
   are defined in gpsdefs.h. */


#define PCPS_GET_SYNTH            0x3E
#define PCPS_SET_SYNTH            0x3F
/* on error, return PCPS_ERR_CFG */

/* The associated structure SYNTH is defined in gpsdefs.h. */


#define PCPS_GIVE_FW_ID_1         0x40
#define PCPS_GIVE_FW_ID_2         0x41
#define PCPS_GIVE_SERNUM          0x42
#define PCPS_GENERIC_IO           0x43
#define PCPS_GET_SYNTH_STATE      0x44
#define PCPS_GET_IRIG_CTRL_BITS   0x45
#define PCPS_GET_RAW_IRIG_DATA    0x46



#define PCPS_GET_STATUS_PORT      0x4B
#define PCPS_GET_DEBUG_STATUS     0x4C
// expects sizeof( MBG_DEBUG_STATUS ) chars

// Command codes 0x4D, 0x4E, and 0x4F are reserved.


#define PCPS_READ_GPS_DATA        0x50
#define PCPS_WRITE_GPS_DATA       0x51

#define PCPS_CLR_UCAP_BUFF        0x60
#define PCPS_GIVE_UCAP_ENTRIES    0x61
#define PCPS_GIVE_UCAP_EVENT      0x62

typedef struct
{
  uint32_t used;   /**< the number of saved capture events */
  uint32_t max;    /**< capture buffer size */
} PCPS_UCAP_ENTRIES;

#define _mbg_swab_pcps_ucap_entries( _p )  \
{                                          \
  _mbg_swab32( &(_p)->used );              \
  _mbg_swab32( &(_p)->max );               \
}



#define PCPS_GET_CORR_INFO        0x63    // read CORR_INFO structure, only if _pcps_has_pzf()
#define PCPS_GET_TR_DISTANCE      0x64    // read TR_DISTANCE, only if _pcps_has_tr_distance()
#define PCPS_SET_TR_DISTANCE      0x65    // write TR_DISTANCE, only if _pcps_has_tr_distance()


#define PCPS_CLR_EVT_LOG          0x66    // clear on-board event log, only if _pcps_has_evt_log()
#define PCPS_NUM_EVT_LOG_ENTRIES  0x67    // read num event log entries, only if _pcps_has_evt_log()
#define PCPS_FIRST_EVT_LOG_ENTRY  0x68    // read first (oldest) event log entry, only if _pcps_has_evt_log()
#define PCPS_NEXT_EVT_LOG_ENTRY   0x69    // read next event log entry, only if _pcps_has_evt_log()


/**
  special -- use with care !
*/
#define PCPS_FORCE_RESET          0x80

// Command codes 0xF0 through 0xFF are reserved.

/** @} group_cmd_bytes */


/* Codes returned when commands with parameters have been passed */
/* to the board */
#define PCPS_SUCCESS       0   /**< OK, no error */
#define PCPS_ERR_STIME    -1   /**< invalid date/time/status passed */
#define PCPS_ERR_CFG      -2   /**< invalid parms for a cmd writing config parameters */



#ifndef BITMASK
  #define BITMASK( b )  ( ( 1 << b ) - 1 )
#endif


/** The size of the plug-in card's on-board FIFO */
#define PCPS_FIFO_SIZE     16

typedef int8_t PCPS_BUFF[PCPS_FIFO_SIZE];


#define PCPS_ID_SIZE   ( 2 * PCPS_FIFO_SIZE + 1 )  /**< ASCIIZ string */
typedef char PCPS_ID_STR[PCPS_ID_SIZE];


#define PCPS_SN_SIZE   ( PCPS_FIFO_SIZE + 1 )  /**< ASCIIZ string */
typedef char PCPS_SN_STR[PCPS_SN_SIZE];


/**
 * The structure has been introduced to be able to handle
 * high resolution time stamps.
 */
typedef struct
{
  uint32_t sec;       /**< seconds since 1970 (UTC) */
  uint32_t frac;      /**< fractions of second ( 0xFFFFFFFF == 0.9999.. sec) */
} PCPS_TIME_STAMP;

#define _mbg_swab_pcps_time_stamp( _p )  \
{                                        \
  _mbg_swab32( &(_p)->sec );             \
  _mbg_swab32( &(_p)->frac );            \
}



// Depending on the target environment define a data type
// which can be used to convert binary fractions without
// range overflow.
#if defined( MBG_TGT_UNIX )
  #define PCPS_HRT_FRAC_CONVERSION_TYPE int64_t
#elif defined( MBG_TGT_WIN32 )
  #define PCPS_HRT_FRAC_CONVERSION_TYPE int64_t
#elif defined( __WATCOMC__ ) && ( __WATCOMC__ >= 1100 )
  #define PCPS_HRT_FRAC_CONVERSION_TYPE int64_t
#else
  #define PCPS_HRT_FRAC_CONVERSION_TYPE double
#endif

// Max value of PCPS_TIME_STAMP::frac + 1 used for scaling
#define PCPS_HRT_BIN_FRAC_SCALE  ( (PCPS_HRT_FRAC_CONVERSION_TYPE) 4294967296.0  )  // == 0x100000000


// The scale and format to be used to print the fractions
// of a second as returned in the PCPS_TIME_STAMP structure.
// The function frac_sec_from_bin() can be used for
// the conversion.
#ifndef PCPS_HRT_FRAC_SCALE
  #define PCPS_HRT_FRAC_SCALE       10000000UL
#endif

#ifndef PCPS_HRT_FRAC_SCALE_FMT
  #define PCPS_HRT_FRAC_SCALE_FMT   "%07lu"
#endif



typedef uint16_t PCPS_TIME_STATUS_X;  /**< extended status */

#define _mbg_swab_pcps_time_status_x( _p )   _mbg_swab16( _p )


/**
 * The structure has been introduced to be able to read the
 * current time with higher resolution of fractions of seconds and
 * more detailed information on the time zone and status.
 * The structure is returned if the new command #PCPS_GIVE_HR_TIME
 * is written to the board.
 * _pcps_has_hr_time() checks whether supported.
 *
 * Newer GPS boards also accept the #PCPS_GIVE_UCAP_EVENT command
 * to return user capture event times using this format. In this
 * case, the "signal" field contains the number of the capture
 * input line, e.g. 0 or 1.
 * _pcps_has_ucap() checks whether supported.
 */
typedef struct
{
  PCPS_TIME_STAMP tstamp;     /**< High resolution time stamp (UTC) */
  int32_t utc_offs;           /**< UTC offs [sec] (loc_time = UTC + utc_offs) */
  PCPS_TIME_STATUS_X status;  /**< status flags as defined below */
  uint8_t signal;             /**< for normal time, the relative RF signal level, for ucap, the channel number */
} PCPS_HR_TIME;

#define _mbg_swab_pcps_hr_time( _p )              \
{                                                 \
  _mbg_swab_pcps_time_stamp( &(_p)->tstamp );     \
  _mbg_swab32( &(_p)->utc_offs );                 \
  _mbg_swab_pcps_time_status_x( &(_p)->status );  \
}


typedef uint8_t PCPS_TIME_STATUS;

/** 
  The standard structure used to read times from the board.
  The time has a resultion of 10 ms.
*/
typedef struct PCPS_TIME_s
{
  uint8_t sec100;  /**< hundredths of seconds, 0..99 */
  uint8_t sec;     /**< seconds, 0..59, or 60 if leap second */
  uint8_t min;     /**< minutes, 0..59 */
  uint8_t hour;    /**< hours, 0..23 */

  uint8_t mday;    /**< day of month, 0..31 */
  uint8_t wday;    /**< day of week, 1..7, 1 = Monday */
  uint8_t month;   /**< month, 1..12 */
  uint8_t year;    /**< year of the century, 0..99 */

  PCPS_TIME_STATUS status;  /**< status bits, see below */
  uint8_t signal;  /**< relative signal strength, range depends on device type */
  int8_t offs_utc; /**< [hours], 0 if !_pcps_has_utc_offs() */
} PCPS_TIME;


/** 
  The structure is passed as parameter with the PCPS_SET_TIME cmd 
*/
typedef struct PCPS_STIME_s
{
  uint8_t sec100;  /**< hundredths of seconds, 0..99 */
  uint8_t sec;     /**< seconds, 0..59, or 60 if leap second */
  uint8_t min;     /**< minutes, 0..59 */
  uint8_t hour;    /**< hours, 0..23 */

  uint8_t mday;    /**< day of month, 0..31 */
  uint8_t wday;    /**< day of week, 1..7, 1 = Monday */
  uint8_t month;   /**< month, 1..12 */
  uint8_t year;    /**< year of the century, 0..99 */

  PCPS_TIME_STATUS status;  /**< status bits, see below */
} PCPS_STIME;

#ifdef _C166
  // This is a workaround to specify some structure sizes. The C166 compiler 
  // always reports an even structure size although the structure size may 
  // be odd due to the number of bytes. This might lead to errors between 
  // the C166 and other build environments.
  #define sizeof_PCPS_TIME   ( sizeof( PCPS_TIME ) - 1 )
  #define sizeof_PCPS_STIME  ( sizeof( PCPS_STIME ) - 1 )
#else
  #define sizeof_PCPS_TIME   sizeof( PCPS_TIME )
  #define sizeof_PCPS_STIME  sizeof( PCPS_STIME )
#endif

typedef union
{
  PCPS_TIME t;
  PCPS_STIME stime;
} PCPS_TIME_UNION;



/**
  The structure below can be used to read the raw IRIG time
  from an IRIG receiver card, if the card supports this.
  See the #PCPS_GIVE_IRIG_TIME command.

  The granularity of the value in the .frac field depends on
  the update interval of the structure as implementation
  in the firmware. I.e. if the raw IRIG time is updated
  only once per second, the .frac value can always be 0.
*/
typedef struct PCPS_IRIG_TIME_s
{
  PCPS_TIME_STATUS_X status;  /**< status bits, see below */
  int16_t offs_utc;  /**< [minutes] */
  uint16_t yday;     /**< day of year, 1..365/366 */
  uint16_t frac;     /**< fractions of seconds, 0.1 ms units */
  uint8_t sec;       /**< seconds, 0..59, or 60 if leap second */
  uint8_t min;       /**< minutes, 0..59 */
  uint8_t hour;      /**< hours, 0..23 */
  uint8_t year;      /**< 2 digit year number, 0xFF if year not supp. by the IRIG code */
  uint8_t signal;    /**< relative signal strength, range depends on device type */
  uint8_t reserved;  /**< currently not used, always 0 */
} PCPS_IRIG_TIME;

#define _mbg_swab_pcps_irig_time( _p )            \
{                                                 \
  _mbg_swab_pcps_time_status_x( &(_p)->status );  \
  _mbg_swab16( &(_p)->offs_utc );                 \
  _mbg_swab16( &(_p)->yday );                     \
  _mbg_swab16( &(_p)->frac );                     \
}




/**
 * Bit masks used with both PCPS_TIME_STATUS and PCPS_TIME_STATUS_X
 */
#define PCPS_FREER     0x01  /**< DCF77 clock running on xtal */
                             /**< GPS receiver has not verified its position */

#define PCPS_DL_ENB    0x02  /**< daylight saving enabled */

#define PCPS_SYNCD     0x04  /**< clock has sync'ed at least once after pwr up */

#define PCPS_DL_ANN    0x08  /**< a change in daylight saving is announced */

#define PCPS_UTC       0x10  /**< a special UTC firmware is installed */

#define PCPS_LS_ANN    0x20  /**< leap second announced */
                             /**< (requires firmware rev. REV_PCPS_LS_ANN_...) */

#define PCPS_IFTM      0x40  /**< the current time was set via PC */
                             /**< (requires firmware rev. REV_PCPS_IFTM_...) */

#define PCPS_INVT      0x80  /**< invalid time because battery was disconn'd */


/**
 * Bit masks used only with PCPS_TIME_STATUS_X
 */
#define PCPS_LS_ENB      0x0100  /**< current second is leap second */
#define PCPS_ANT_FAIL    0x0200  /**< antenna failure */
#define PCPS_LS_ANN_NEG  0x0400  /**< announced leap second is negative */
#define PCPS_SCALE_GPS   0x0800  /**< time stamp is GPS scale */
#define PCPS_SCALE_TAI   0x1000  /**< time stamp is TAI scale */

/**
 * Bit masks used only with time stamps representing user capture events
 */
#define PCPS_UCAP_OVERRUN      0x2000  /**< events interval too short */
#define PCPS_UCAP_BUFFER_FULL  0x4000  /**< events read too slow */

/**
 * Bit masks used only with time stamps representing the current board time.
 * A DCF77 PZF receiver can set this bit if it is actually synchronized
 * using PZF correlation and thus provides higher accuracy than AM receivers.
 */
#define PCPS_SYNC_PZF          0x2000  /**< same code as PCPS_UCAP_OVERRUN */

/**
 * Immediately after a clock has been accessed, subsequent accesses
 * are blocked for up to 1.5 msec to give the clock's microprocessor
 * some time to decode the incoming time signal.
 * The flag below is set if a program tries to read the PCPS_HR_TIME
 * during this interval. In this case the read function returns the
 * proper time stamp which is taken if the command byte is written,
 * however, the read function returns with delay.
 * This flag is not supported by all clocks.
 */
#define PCPS_IO_BLOCKED        0x8000

/**
 * This bit mask can be used to extract the time scale information out
 * of a PCPS_TIME_STATUS_X value.
*/
#define PCPS_SCALE_MASK ( PCPS_SCALE_TAI | PCPS_SCALE_GPS )


/**
 * Some DCF77 clocks have a serial interface that can be controlled
 * using the commands PCPS_SET_SERIAL and PCPS_GET_SERIAL. Both commands
 * use a parameter byte describing transmission speed, framing and mode
 * of operation. The parameter byte can be build using the constants
 * defined below, by or'ing one of the constants of each group, shifted
 * to the right position. PCPS_GET_SERIAL expects that parameter byte
 * and PCPS_GET_SERIAL returns the current configuration from the board.
 * _pcps_has_serial() checks whether supported.
 * For GPS clocks, please refer to the comments for the PCPS_GET_SERIAL
 * command.
 */

/**
 * Baud rate indices. The values below are obsolete and should
 * be replaced by the codes named MBG_BAUD_RATE_... which are
 * defined in gpsdefs.h. The resulting index numbers, however,
 * have not changed.
 */
enum
{
  PCPS_BD_300,
  PCPS_BD_600,
  PCPS_BD_1200,
  PCPS_BD_2400,
  PCPS_BD_4800,
  PCPS_BD_9600,
  PCPS_BD_19200,
  N_PCPS_BD     /* number of codes */
};

#define PCPS_BD_BITS   4  /* field with in the cfg byte */
#define PCPS_BD_SHIFT  0  /* num of bits to shift left */

/*
 * Initializers for a table of all baud rate strings
 * and values can be found in gpsdefs.h.
 */


/**
 * Unfortunately, the framing codes below can not simply be
 * replaced by the newer MBG_FRAMING_... definitions since
 * the order of indices does not match.
 */
enum
{
  PCPS_FR_8N1,
  PCPS_FR_7E2,
  PCPS_FR_8N2,
  PCPS_FR_8E1,
  N_PCPS_FR_DCF     /* number of valid codes */
};

#define PCPS_FR_BITS   2             /* field with in the cfg byte */
#define PCPS_FR_SHIFT  PCPS_BD_BITS  /* num of bits to shift left */

/*
 * An initializer for a table of framing strings is only defined for
 * the new MBG_FRAMING_... definitions. For editing the serial port
 * configuration, the old codes above should be translated to the new
 * codes to unify handling inside the edit functions.
 */

/** 
  Modes of operation

 * Indices for modes of operation. The values below are obsolete
 * and should be replaced by the codes named STR_... which are
 * defined in gpsdefs.h. The resulting index numbers, however,
 * have not changed.
 */
enum
{
  PCPS_MOD_REQ,     /* time string on request '?' only */
  PCPS_MOD_SEC,     /* time string once per second */
  PCPS_MOD_MIN,     /* time string once per minute */
  PCPS_MOD_RSVD,    /* reserved */
  N_PCPS_MOD_DCF    /* number of possible codes */
};

#define PCPS_MOD_BITS   2      /* field with in the cfg byte */
#define PCPS_MOD_SHIFT  ( PCPS_BD_BITS + PCPS_FR_BITS )
                               /* num of bits to shift left */


/**
 * Some definitions used with PZF receivers
 */

/* receiver distance from transmitter [km] */
typedef uint16_t TR_DISTANCE;

#define _mbg_swab_tr_distance( _p )  \
  _mbg_swab16( _p )



/* correlation status info */
typedef struct
{
  uint8_t val;       /**< correlation value, or check count if status == PZF_CORR_CHECK */
  uint8_t status;    /**< status codes, see below */
  char corr_dir;     /**< space, '<', or '>' */
  uint8_t signal;    /**< signal level, may always be 0 for devices which do not support this */
} CORR_INFO;

#define _mbg_swab_corr_info( _p )  \
  _nop_macro_fnc()


/** Codes used with CORR_INFO::status: */
enum
{
  PZF_CORR_RAW,      /**< trying raw correlation, combi receivers running in AM mode */
  PZF_CORR_CHECK,    /**< raw correlation achieved, doing plausibility checks */
  PZF_CORR_FINE,     /**< fine correlation achieved */
  N_PZF_CORR_STATE
};


#define PZF_CORR_STATE_NAME_RAW_ENG     "Searching"
#define PZF_CORR_STATE_NAME_CHECK_ENG   "Correlating"
#define PZF_CORR_STATE_NAME_FINE_ENG    "Locked"

#define PZF_CORR_STATE_NAME_RAW_GER     "suchen"
#define PZF_CORR_STATE_NAME_CHECK_GER   "korrelieren"
#define PZF_CORR_STATE_NAME_FINE_GER    "eingerastet"


#define PZF_CORR_STATE_NAMES_ENG \
{                                \
  PZF_CORR_STATE_NAME_RAW_ENG,   \
  PZF_CORR_STATE_NAME_CHECK_ENG, \
  PZF_CORR_STATE_NAME_FINE_ENG   \
}


#define PZF_CORR_STATE_NAMES_LSTR                                   \
{                                                                   \
  { PZF_CORR_STATE_NAME_RAW_ENG, PZF_CORR_STATE_NAME_RAW_GER },     \
  { PZF_CORR_STATE_NAME_CHECK_ENG, PZF_CORR_STATE_NAME_CHECK_GER }, \
  { PZF_CORR_STATE_NAME_FINE_ENG, PZF_CORR_STATE_NAME_FINE_GER }    \
}



/** @defgroup group_gps_cmds_bus GPS commands passed via the system bus

   This enumeration defines the various types of data that can be read
   from or written to Meinberg bus level devices which support this.
   Access should be done using the functions pcps_read_gps_data()
   and pcps_write_gps_data() since the size of some of the structures
   exceeds the size of the device's I/O buffer and must therefore be
   accessed in several blocks.

   The structures to be used are defined in gpsdefs.h. Not all structures
   are supported, yet. Check the R/W indicators for details.

 * @{ */
enum
{                           // R/W  data type       description
  // system data            -----------------------------------------------
  PC_GPS_TZDL = 0,          // R/W  TZDL            time zone / daylight saving
  PC_GPS_SW_REV,            // R/-  SW_REV          software revision
  PC_GPS_BVAR_STAT,         // R/-  BVAR_STAT       status of buffered variables
  PC_GPS_TIME,              // R/W  TTM             curr. time
  PC_GPS_POS_XYZ,           // -/W  XYZ             curr. pos. in ECEF coords
  PC_GPS_POS_LLA,           // -/W  LLA             curr. pos. in geogr. coords
  PC_GPS_PORT_PARM,         // R/W  PORT_PARM       param. of the serial ports
  PC_GPS_ANT_INFO,          // R/-  ANT_INFO        time diff after ant. disconn.
  PC_GPS_UCAP,              // R/-  TTM             user capture
  PC_GPS_ENABLE_FLAGS,      // R/W  ENABLE_FLAGS    controls when to enable outp.
  PC_GPS_STAT_INFO,         // R/-  GPS_STAT_INFO
  PC_GPS_CMD,               // -/W  GPS_CMD         commands as described below
  PC_GPS_IDENT,             // R/-  GPS_IDENT       serial number
  PC_GPS_POS,               // R/-  POS             position XYZ, LLA, and DMS
  PC_GPS_ANT_CABLE_LEN,     // R/W  ANT_CABLE_LEN   used to compensate delay
  // The codes below are supported by new GPS receiver boards:
  PC_GPS_RECEIVER_INFO,     // R/-  RECEIVER_INFO        rcvr model info
  PC_GPS_ALL_STR_TYPE_INFO, // R/-  n*STR_TYPE_INFO_IDX  all string types
  PC_GPS_ALL_PORT_INFO,     // R/-  n*PORT_INFO_IDX      all port info
  PC_GPS_PORT_SETTINGS_IDX, // -/W  PORT_SETTINGS_IDX    port settings only
  PC_GPS_ALL_POUT_INFO,     // R/-  n*POUT_INFO_IDX      all pout info
  PC_GPS_POUT_SETTINGS_IDX, // -/W  POUT_SETTINGS_IDX    pout settings only
  PC_GPS_TIME_SCALE,        // R/W  MBG_TIME_SCALE_{SETTINGS|INFO}, only if PCPS_HAS_TIME_SCALE
  PC_GPS_LAN_IF_INFO,       // R/-  LAN_IF_INFO   LAN interface info, only if PCPS_HAS_LAN_INTF
  PC_GPS_IP4_STATE,         // R/-  IP4_SETTINGS  LAN interface state, only if PCPS_HAS_LAN_INTF
  PC_GPS_IP4_SETTINGS,      // R/W  IP4_SETTINGS  LAN interface configuration, only if PCPS_HAS_LAN_INTF
  PC_GPS_PTP_STATE,         // R/-  PTP_STATE, only if PCPS_HAS_PTP
  PC_GPS_PTP_CFG,           // R/W  PTP_CFG_{SETTINGS|INFO}, only if PCPS_HAS_PTP
  PC_GPS_PTP_UC_MASTER_CFG_LIMITS,   // R/-  PTP_UC_MASTER_CFG_LIMITS, only if can be unicast master
  PC_GPS_ALL_PTP_UC_MASTER_INFO,     // R/-  n*PTP_UC_MASTER_INFO_IDX, only if can be unicast master
  PC_GPS_PTP_UC_MASTER_SETTINGS_IDX, // -/W  PTP_UC_MASTER_SETTINGS_IDX, only if can be unicast master
  PC_GPS_GPIO_CFG_LIMITS,   // R/-  MBG_GPIO_CFG_LIMITS, only if PCPS_HAS_GPIO
  PC_GPS_ALL_GPIO_INFO,     // R/-  n*MBG_GPIO_INFO, all GPIO info, only if PCPS_HAS_GPIO
  PC_GPS_GPIO_SETTINGS_IDX, // -/W  MBG_GPIO_SETTINGS_IDX, GPIO cfg for a specific port, only if PCPS_HAS_GPIO

  // GPS data
  PC_GPS_CFGH = 0x80,  // -/-  CFGH          SVs' config. and health codes
  PC_GPS_ALM,          // -/-  SV_ALM        one SV's num and almanac
  PC_GPS_EPH,          // -/-  SV_EPH        one SV's num and ephemeris
  PC_GPS_UTC,          // R/W  UTC           UTC corr. param., only if PCPS_HAS_UTC_PARM
  PC_GPS_IONO,         // -/-  IONO          ionospheric corr. param.
  PC_GPS_ASCII_MSG     // -/-  ASCII_MSG     the GPS ASCII message
};

/**  @} group_gps_cmds_bus */



/**
 * @brief An initializer for a table of code/name entries of GPS commands.
 *
 * This can e.g. be assigned to an array of MBG_CODE_NAME_TABLE_ENTRY elements
 * and may be helpful when debugging.
 */
#define MBG_PC_GPS_CMD_TABLE                                                    \
{                                                                               \
  { PC_GPS_TZDL,                        "PC_GPS_TZDL" },                        \
  { PC_GPS_SW_REV,                      "PC_GPS_SW_REV" },                      \
  { PC_GPS_BVAR_STAT,                   "PC_GPS_BVAR_STAT" },                   \
  { PC_GPS_TIME,                        "PC_GPS_TIME" },                        \
  { PC_GPS_POS_XYZ,                     "PC_GPS_POS_XYZ" },                     \
  { PC_GPS_POS_LLA,                     "PC_GPS_POS_LLA" },                     \
  { PC_GPS_PORT_PARM,                   "PC_GPS_PORT_PARM" },                   \
  { PC_GPS_ANT_INFO,                    "PC_GPS_ANT_INFO" },                    \
  { PC_GPS_UCAP,                        "PC_GPS_UCAP" },                        \
  { PC_GPS_ENABLE_FLAGS,                "PC_GPS_ENABLE_FLAGS" },                \
  { PC_GPS_STAT_INFO,                   "PC_GPS_STAT_INFO" },                   \
  { PC_GPS_CMD,                         "PC_GPS_CMD" },                         \
  { PC_GPS_IDENT,                       "PC_GPS_IDENT" },                       \
  { PC_GPS_POS,                         "PC_GPS_POS" },                         \
  { PC_GPS_ANT_CABLE_LEN,               "PC_GPS_ANT_CABLE_LEN" },               \
  { PC_GPS_RECEIVER_INFO,               "PC_GPS_RECEIVER_INFO" },               \
  { PC_GPS_ALL_STR_TYPE_INFO,           "PC_GPS_ALL_STR_TYPE_INFO" },           \
  { PC_GPS_ALL_PORT_INFO,               "PC_GPS_ALL_PORT_INFO" },               \
  { PC_GPS_PORT_SETTINGS_IDX,           "PC_GPS_PORT_SETTINGS_IDX" },           \
  { PC_GPS_ALL_POUT_INFO,               "PC_GPS_ALL_POUT_INFO" },               \
  { PC_GPS_POUT_SETTINGS_IDX,           "PC_GPS_POUT_SETTINGS_IDX" },           \
  { PC_GPS_TIME_SCALE,                  "PC_GPS_TIME_SCALE" },                  \
  { PC_GPS_LAN_IF_INFO,                 "PC_GPS_LAN_IF_INFO" },                 \
  { PC_GPS_IP4_STATE,                   "PC_GPS_IP4_STATE" },                   \
  { PC_GPS_IP4_SETTINGS,                "PC_GPS_IP4_SETTINGS" },                \
  { PC_GPS_PTP_STATE,                   "PC_GPS_PTP_STATE" },                   \
  { PC_GPS_PTP_CFG,                     "PC_GPS_PTP_CFG" },                     \
  { PC_GPS_PTP_UC_MASTER_CFG_LIMITS,    "PC_GPS_PTP_UC_MASTER_CFG_LIMITS" },    \
  { PC_GPS_ALL_PTP_UC_MASTER_INFO,      "PC_GPS_ALL_PTP_UC_MASTER_INFO" },      \
  { PC_GPS_PTP_UC_MASTER_SETTINGS_IDX,  "PC_GPS_PTP_UC_MASTER_SETTINGS_IDX" },  \
  { PC_GPS_GPIO_CFG_LIMITS,             "PC_GPS_GPIO_CFG_LIMITS" },             \
  { PC_GPS_ALL_GPIO_INFO,               "PC_GPS_ALL_GPIO_INFO" },               \
  { PC_GPS_GPIO_SETTINGS_IDX,           "PC_GPS_GPIO_SETTINGS_IDX" },           \
  { PC_GPS_CFGH,                        "PC_GPS_CFGH" },                        \
  { PC_GPS_ALM,                         "PC_GPS_ALM" },                         \
  { PC_GPS_EPH,                         "PC_GPS_EPH" },                         \
  { PC_GPS_UTC,                         "PC_GPS_UTC" },                         \
  { PC_GPS_IONO,                        "PC_GPS_IONO" },                        \
  { PC_GPS_ASCII_MSG,                   "PC_GPS_ASCII_MSG" },                   \
  { 0, NULL }                                                                   \
}



/** codes used with PC_GPS_CMD */
enum
{
  PC_GPS_CMD_BOOT = 1,   /**< force the clock to boot mode */
  PC_GPS_CMD_INIT_SYS,   /**< let the clock clear its system variables */
  PC_GPS_CMD_INIT_USER,  /**< reset the clock's user parameters to defaults */
  PC_GPS_CMD_INIT_DAC,   /**< initialize the oscillator disciplining values */
  N_PC_GPS_CMD           /**< no command, just the number of known commands */
};



// The type below can be used to store an unambiguous command code.
// In case of the standard PCPS_... commands the lower byte contains
// the command code and the upper byte is 0.
// In case of a GPS command the lower byte contains PCPS_READ_GPS_DATA
// or PCPS_WRITE_GPS_DATA, as appropriate, and the upper byte contains
// the associated PC_GPS_... type code.
typedef uint16_t PCPS_CMD_INFO;


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */

#endif  /* _PCPSDEFS_H */

