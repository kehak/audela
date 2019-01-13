
/**************************************************************************
 *
 *  $Id: mbgioctl.h 1.24.1.12 2011/11/25 15:03:23 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions used with device driver IOCTL.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgioctl.h $
 *  Revision 1.24.1.12  2011/11/25 15:03:23  martin
 *  Support on-board event logs.
 *  Revision 1.24.1.11  2011/11/22 15:47:27  martin
 *  Support debug status.
 *  Revision 1.24.1.10  2011/07/20 15:49:00  martin
 *  Conditionally use older IOCTL request buffer structures.
 *  Revision 1.24.1.9  2011/07/19 12:31:59  martin
 *  Relaxed required priority level for generic read functions.
 *  Revision 1.24.1.8  2011/07/18 10:18:49  martin
 *  Revision 1.24.1.7  2011/07/15 14:50:11  martin
 *  Revision 1.24.1.6  2011/07/14 14:54:01  martin
 *  Modified generic IOCTL handling such that for calls requiring variable sizes
 *  a fixed request block containing input and output buffer pointers and sizes is
 *  passed down to the kernel driver. This simplifies implementation under *BSD
 *  and also works for other target systems.
 *  Revision 1.24.1.5  2011/07/06 11:19:28  martin
 *  Support reading CORR_INFO, and reading/writing TR_DISTANCE.
 *  Revision 1.24.1.4  2011/06/29 10:52:00  martin
 *  New code IOCTL_DEV_HAS_PZF.
 *  Revision 1.24.1.3  2011/06/21 15:03:29  martin
 *  Support PTP unicast configuration.
 *  Changed the names of a few IOCTL codes to follow general naming conventions.
 *  Added definitions to support privilege level requirements for IOCTLs.
 *  Use native alignment to avoid problems on Sparc and IA64.
 *  Added definitions to set up a table of all known
 *  IOCTL codes and names.
 *  Use MBG_TGT_KERNEL instead of _KDD_.
 *  Fixed a typo.
 *  Revision 1.24.1.2  2011/03/22 11:19:46  martin
 *  Use IOTYPE 'Z' under *BSD since this means passthrough on NetBSD.
 *  Revision 1.24.1.1  2011/02/15 11:21:21  daniel
 *  Added ioctls to support PTP unicast configuration
 *  Revision 1.24  2009/12/15 15:34:59Z  daniel
 *  Support reading the raw IRIG data bits for firmware versions 
 *  which support this feature.
 *  Revision 1.23  2009/09/29 15:08:41Z  martin
 *  Support retrieving time discipline info.
 *  Revision 1.22  2009/08/17 13:48:17  martin
 *  Moved specific definition of symbol _HAVE_IOCTL_WITH_SIZE from
 *  mbgdevio.c here and renamed it to _MBG_SUPP_VAR_ACC_SIZE.
 *  Revision 1.21  2009/06/19 12:18:53  martin
 *  Added PCPS_GIVE_IRIG_TIME command and associated definitions.
 *  Fixed a declaration which might have led to syntax errors.
 *  Revision 1.20  2009/06/09 10:02:36Z  daniel
 *  Support PTP configuration and state.
 *  Support simple LAN interface configuration.
 *  Revision 1.19  2009/03/19 15:17:59  martin
 *  Support reading MM timestamps without cycles.
 *  Support UTC parms and configurable time scales.
 *  For consistent naming renamed IOCTL_GET_FAST_HR_TIMESTAMP
 *  to IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES.
 *  Added IOCTL_DEV_HAS_IRIG_CTRL_BITS and IOCTL_GET_IRIG_CTRL_BITS.
 *  Revision 1.18  2008/12/11 10:32:56Z  martin
 *  Added _cmd_from_ioctl_code() macro for Linux.
 *  Added IOCTL codes for .._has_asic_version() and .._has_asic_features().
 *  Added IOCTL codes for ..._is_msf(), .._is_lwr(), .._is_wwvb().
 *  Added IOCTL codes IOCTL_GET_IRQ_STAT_INFO, IOCTL_GET_CYCLES_FREQUENCY,
 *  IOCTL_HAS_FAST_HR_TIMESTAMP, and IOCTL_GET_FAST_HR_TIMESTAMP.
 *  Revision 1.17  2008/01/17 09:35:15  daniel
 *  Added ioctl calls IOCTL_GET_MAPPED_MEM_ADDR and
 *  IOCTL_UNMAP_MAPPED_MEM.
 *  Cleanup for PCI ASIC version and features.
 *  Revision 1.16  2007/09/25 10:37:04Z  martin
 *  Added macro _cmd_from_ioctl_code() for Windows.
 *  Revision 1.15  2007/05/21 15:00:01Z  martin
 *  Unified naming convention for symbols related to ref_offs.
 *  Revision 1.14  2007/03/02 10:27:03  martin
 *  Preliminary support for *BSD.
 *  Preliminary _cmd_from_ioctl().
 *  Revision 1.13  2006/03/10 10:36:54  martin
 *  Added support for programmable pulse outputs.
 *  Revision 1.12  2005/06/02 10:22:05Z  martin
 *  Added IOCTL code IOCTL_GET_SYNTH_STATE.
 *  Added IOCTL codes IOCTL_DEV_HAS_GENERIC_IO, 
 *  IOCTL_PCPS_GENERIC_IO, and IOCTL_GET_SYNTH_STATE.
 *  Revision 1.11  2005/01/14 10:21:11Z  martin
 *  Added IOCTLs which query device features.
 *  Revision 1.10  2004/12/09 11:03:36Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.9  2004/11/09 12:49:41Z  martin
 *  Modifications were required in order to be able to configure IRIG 
 *  settings of cards which provide both IRIG input and output.
 *  The existing codes have been renamed with .._RX.. and are used to 
 *  configure the IRIG receiver (input). New codes have been defined 
 *  used to configure the IRIG transmitter.
 *  Renamed IOCTL_GET_GPS_STAT to IOCTL_GET_GPS_BVAR_STAT.
 *  Use more specific data types than generic types.
 *  Modified IOCTL codes used for hardware debugging.
 *  Revision 1.8  2004/09/06 15:46:04Z  martin
 *  Changed definition of IOCTL codes to support syntax used 
 *  with Linux kernel 2.6.x.
 *  Account for renamed symbols.
 *  Revision 1.7  2004/04/07 10:08:11  martin
 *  Added IOCTL codes used to trigger hardware debug events.
 *  Revision 1.6  2003/12/22 15:37:18Z  martin
 *  Added codes to read ASIC version, and read times
 *  with associated cycle counter values.
 *  Revision 1.5  2003/06/19 09:02:30Z  martin
 *  New codes IOCTL_GET_PCPS_UCAP_ENTRIES and IOCTL_GET_PCPS_UCAP_EVENT.
 *  Renamed IOCTL_PCPS_CLR_CAP_BUFF to IOCTL_PCPS_CLR_UCAP_BUFF.
 *  Cleaned up IOCTL code names related to PCPS_TZDL.
 *  Reordered upper IOCTL code numbers again.
 *  Revision 1.4  2003/04/09 13:50:39Z  martin
 *  Re-organized IOCTL codes.
 *  Supports Win32.
 *  Added missing pragma pack().
 *  Revision 1.3  2003/02/14 13:20:08Z  martin
 *  Include mbggeo.h instead of mygeo.h.
 *  Revision 1.2  2001/11/30 09:52:48  martin
 *  Added support for event_time which, however, requires
 *  a custom GPS firmware.
 *  Revision 1.1  2001/03/05 16:34:22  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _MBGIOCTL_H
#define _MBGIOCTL_H


/* Other headers to be included */

#include <mbg_tgt.h>
#include <mbggeo.h>
#include <pcpsdev.h>
#include <pci_asic.h>


#define USE_DEBUG_PORT    defined( MBG_ARCH_X86 )


#if defined( MBG_TGT_LINUX )

  #include <linux/ioctl.h>

  // a magic number used to generate IOCTL cmd codes
  #define IOTYPE 'M'

  #define _MBG_IO   _IO
  #define _MBG_IOR  _IOR
  #define _MBG_IOW  _IOW

  #define _cmd_from_ioctl_code( _ioc ) \
    _IOC_NR( _ioc )

#elif defined( MBG_TGT_BSD )

  #include <sys/ioccom.h>

  // Under NetBSD 'Z' marks passthrough IOCTLs, under FreeBSD the code
  // does not seem to matter, so we use 'Z' anyway.
  #define IOTYPE 'Z'

  #define _MBG_IO   _IO
  #define _MBG_IOR  _IOR
  #define _MBG_IOW  _IOW

#elif defined( MBG_TGT_WIN32 )

  #if !defined( _MBG_SUPP_VAR_ACC_SIZE )
    // Windows supports IOCTL commands where the sizes of
    // input and output buffer can be specified dynamically.
    #define _MBG_SUPP_VAR_ACC_SIZE   1
  #endif

  #if !defined( MBG_TGT_KERNEL )
    #include <windows.h>
    #include <winioctl.h>
  #endif

  #if !defined( MBG_TGT_WIN32_NON_PNP )
    #ifdef _MBGIOCTL
      #include <initguid.h>   // instance the GUID
    #else
      #include <guiddef.h>    // just define the GUID
    #endif
  #endif

  #ifdef DEFINE_GUID   // don't break compiles of drivers that
                       // include this header but don't want the
                       // GUIDs

    // ClassGuid = { 78A1C341-4539-11d3-B88D-00C04FAD5171 }
    DEFINE_GUID( GUID_MEINBERG_DEVICE,
                 0x78A1C341L, 0x4539, 0x11D3,
                 0xB8, 0x8D, 0x00, 0xC0, 0x4F, 0xAD, 0x51, 0x71 );
  #endif

  // Device type in the "User Defined" range."
  #define PCPS_TYPE 40000

  // IOCTL function codes from 0x800 to 0xFFF are for customer use.
  #define _MBG_IOCTL_BIAS  0x930

  #define _MBG_IO( _t, _n ) \
    CTL_CODE( PCPS_TYPE, _MBG_IOCTL_BIAS + _n, METHOD_BUFFERED, FILE_READ_ACCESS )

  #define _MBG_IOR( _t, _n, _sz ) \
    _MBG_IO( _t, _n )

  #define _MBG_IOW  _MBG_IOR

  #define _cmd_from_ioctl_code( _ioc ) \
    ( ( ( (_ioc) >> 2 ) & 0x0FFF ) - _MBG_IOCTL_BIAS )

#endif


#if !defined( _MBG_SUPP_VAR_ACC_SIZE )
  // Many operating systems don't support specifying the sizes of IOCTL
  // input and output buffers dynamically, so we disable this by default.
  #define _MBG_SUPP_VAR_ACC_SIZE   0
#endif


#ifdef _MBGIOCTL
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

// We must use native alignment here!


// The structure below is used by the IOCTL_PCPS_GENERIC_... calls.

#if defined( MBG_TGT_LINUX )
  #if defined( MBG_ARCH_ARM ) || defined( MBG_ARCH_SPARC )
    #define USE_IOCTL_GENERIC_REQ   0
  #endif
#endif

#if !defined( USE_IOCTL_GENERIC_REQ )
  #define USE_IOCTL_GENERIC_REQ   1
#endif


#if USE_IOCTL_GENERIC_REQ

// This does not yet work properly under Linux/Sparc where the kernel may be 64 bit
// while user space is 32 bit, which leads to different sizes for pointers and size_t.

typedef struct
{
  ulong info;
  const void *in_p;
  size_t in_sz;
  void *out_p;
  size_t out_sz;

} IOCTL_GENERIC_REQ;

#define _MBG_IOG( _t, _n, _s )   _MBG_IOW( _t, _n, _s )

#else

// The structure below is used by the IOCTL_PCPS_GENERIC_... calls.
typedef struct
{
  uint32_t info;
  uint32_t data_size_in;
  uint32_t data_size_out;
} IOCTL_GENERIC_CTL;

typedef struct
{
  IOCTL_GENERIC_CTL ctl;
  uint8_t data[1];
} IOCTL_GENERIC_BUFFER;

#define _MBG_IOG( _t, _n, _s )  _MBG_IO( _t, _n )

#endif



// read general driver info, device info, and status port
#define IOCTL_GET_PCPS_DRVR_INFO         _MBG_IOR( IOTYPE, 0x00, PCPS_DRVR_INFO )
#define IOCTL_GET_PCPS_DEV               _MBG_IOR( IOTYPE, 0x01, PCPS_DEV )
#define IOCTL_GET_PCPS_STATUS_PORT       _MBG_IOR( IOTYPE, 0x02, PCPS_STATUS_PORT )

// Generic read/write operations. We define _MBG_IOW codes since these calls
// eventually pass a generic request structure IOCTL_GENERIC_REQ to the driver.
#define IOCTL_PCPS_GENERIC_READ          _MBG_IOG( IOTYPE, 0x03, IOCTL_GENERIC_REQ )
#define IOCTL_PCPS_GENERIC_WRITE         _MBG_IOG( IOTYPE, 0x04, IOCTL_GENERIC_REQ )
#define IOCTL_PCPS_GENERIC_READ_GPS      _MBG_IOG( IOTYPE, 0x05, IOCTL_GENERIC_REQ )
#define IOCTL_PCPS_GENERIC_WRITE_GPS     _MBG_IOG( IOTYPE, 0x06, IOCTL_GENERIC_REQ )

// normal direct read/write operations
#define IOCTL_GET_PCPS_TIME              _MBG_IOR( IOTYPE, 0x10, PCPS_TIME )
#define IOCTL_SET_PCPS_TIME              _MBG_IOW( IOTYPE, 0x11, PCPS_STIME )

#define IOCTL_GET_PCPS_SYNC_TIME         _MBG_IOR( IOTYPE, 0x12, PCPS_TIME )

#define IOCTL_GET_PCPS_TIME_SEC_CHANGE   _MBG_IOR( IOTYPE, 0x13, PCPS_TIME )

#define IOCTL_GET_PCPS_HR_TIME           _MBG_IOR( IOTYPE, 0x14, PCPS_HR_TIME )

// the next one is supported with custom GPS firmware only:
#define IOCTL_SET_PCPS_EVENT_TIME        _MBG_IOW( IOTYPE, 0x15, PCPS_TIME_STAMP )

#define IOCTL_GET_PCPS_SERIAL            _MBG_IOR( IOTYPE, 0x16, PCPS_SERIAL )
#define IOCTL_SET_PCPS_SERIAL            _MBG_IOW( IOTYPE, 0x17, PCPS_SERIAL )

#define IOCTL_GET_PCPS_TZCODE            _MBG_IOR( IOTYPE, 0x18, PCPS_TZCODE )
#define IOCTL_SET_PCPS_TZCODE            _MBG_IOW( IOTYPE, 0x19, PCPS_TZCODE )

#define IOCTL_GET_PCPS_TZDL              _MBG_IOR( IOTYPE, 0x1A, PCPS_TZDL )
#define IOCTL_SET_PCPS_TZDL              _MBG_IOW( IOTYPE, 0x1B, PCPS_TZDL )

#define IOCTL_GET_REF_OFFS               _MBG_IOR( IOTYPE, 0x1C, MBG_REF_OFFS )
#define IOCTL_SET_REF_OFFS               _MBG_IOW( IOTYPE, 0x1D, MBG_REF_OFFS )

#define IOCTL_GET_MBG_OPT_INFO           _MBG_IOR( IOTYPE, 0x1E, MBG_OPT_INFO )
#define IOCTL_SET_MBG_OPT_SETTINGS       _MBG_IOW( IOTYPE, 0x1F, MBG_OPT_SETTINGS )

#define IOCTL_GET_PCPS_IRIG_RX_INFO      _MBG_IOR( IOTYPE, 0x20, IRIG_INFO )
#define IOCTL_SET_PCPS_IRIG_RX_SETTINGS  _MBG_IOW( IOTYPE, 0x21, IRIG_SETTINGS )

#define IOCTL_PCPS_CLR_UCAP_BUFF         _MBG_IO(  IOTYPE, 0x22 )
#define IOCTL_GET_PCPS_UCAP_ENTRIES      _MBG_IOR( IOTYPE, 0x23, PCPS_UCAP_ENTRIES )
#define IOCTL_GET_PCPS_UCAP_EVENT        _MBG_IOR( IOTYPE, 0x24, PCPS_HR_TIME )


#define IOCTL_GET_GPS_TZDL               _MBG_IOR( IOTYPE, 0x25, TZDL )
#define IOCTL_SET_GPS_TZDL               _MBG_IOW( IOTYPE, 0x26, TZDL )

#define IOCTL_GET_GPS_SW_REV             _MBG_IOR( IOTYPE, 0x27, SW_REV )

#define IOCTL_GET_GPS_BVAR_STAT          _MBG_IOR( IOTYPE, 0x28, BVAR_STAT )

#define IOCTL_GET_GPS_TIME               _MBG_IOR( IOTYPE, 0x29, TTM )
#define IOCTL_SET_GPS_TIME               _MBG_IOW( IOTYPE, 0x2A, TTM )

#define IOCTL_GET_GPS_PORT_PARM          _MBG_IOR( IOTYPE, 0x2B, PORT_PARM )
#define IOCTL_SET_GPS_PORT_PARM          _MBG_IOW( IOTYPE, 0x2C, PORT_PARM )

#define IOCTL_GET_GPS_ANT_INFO           _MBG_IOR( IOTYPE, 0x2D, ANT_INFO )

#define IOCTL_GET_GPS_UCAP               _MBG_IOR( IOTYPE, 0x2E, TTM )

#define IOCTL_GET_GPS_ENABLE_FLAGS       _MBG_IOR( IOTYPE, 0x2F, ENABLE_FLAGS )
#define IOCTL_SET_GPS_ENABLE_FLAGS       _MBG_IOW( IOTYPE, 0x30, ENABLE_FLAGS )

#define IOCTL_GET_GPS_STAT_INFO          _MBG_IOR( IOTYPE, 0x31, STAT_INFO )

#define IOCTL_SET_GPS_CMD                _MBG_IOW( IOTYPE, 0x32, GPS_CMD )

#define IOCTL_GET_GPS_IDENT              _MBG_IOR( IOTYPE, 0x33, IDENT )

#define IOCTL_GET_GPS_POS                _MBG_IOR( IOTYPE, 0x34, POS )
#define IOCTL_SET_GPS_POS_XYZ            _MBG_IOW( IOTYPE, 0x35, XYZ )
#define IOCTL_SET_GPS_POS_LLA            _MBG_IOW( IOTYPE, 0x36, LLA )

#define IOCTL_GET_GPS_ANT_CABLE_LEN      _MBG_IOR( IOTYPE, 0x37, ANT_CABLE_LEN )
#define IOCTL_SET_GPS_ANT_CABLE_LEN      _MBG_IOW( IOTYPE, 0x38, ANT_CABLE_LEN )

#define IOCTL_GET_GPS_RECEIVER_INFO      _MBG_IOR( IOTYPE, 0x39, RECEIVER_INFO )
#define IOCTL_GET_GPS_ALL_STR_TYPE_INFO  _MBG_IOG( IOTYPE, 0x3A, IOCTL_GENERIC_REQ )  // variable size
#define IOCTL_GET_GPS_ALL_PORT_INFO      _MBG_IOG( IOTYPE, 0x3B, IOCTL_GENERIC_REQ )  // variable size

#define IOCTL_SET_GPS_PORT_SETTINGS_IDX  _MBG_IOW( IOTYPE, 0x3C, PORT_SETTINGS_IDX )

#define IOCTL_GET_PCI_ASIC_VERSION       _MBG_IOR( IOTYPE, 0x3D, PCI_ASIC_VERSION )

#define IOCTL_GET_PCPS_TIME_CYCLES       _MBG_IOR( IOTYPE, 0x3E, PCPS_TIME_CYCLES )
#define IOCTL_GET_PCPS_HR_TIME_CYCLES    _MBG_IOR( IOTYPE, 0x3F, PCPS_HR_TIME_CYCLES )

#define IOCTL_GET_PCPS_IRIG_TX_INFO      _MBG_IOR( IOTYPE, 0x40, IRIG_INFO )
#define IOCTL_SET_PCPS_IRIG_TX_SETTINGS  _MBG_IOW( IOTYPE, 0x41, IRIG_SETTINGS )

#define IOCTL_GET_SYNTH                  _MBG_IOR( IOTYPE, 0x42, SYNTH )
#define IOCTL_SET_SYNTH                  _MBG_IOW( IOTYPE, 0x43, SYNTH )


#define IOCTL_DEV_IS_GPS                 _MBG_IOR( IOTYPE, 0x44, int )
#define IOCTL_DEV_IS_DCF                 _MBG_IOR( IOTYPE, 0x45, int )
#define IOCTL_DEV_IS_IRIG_RX             _MBG_IOR( IOTYPE, 0x46, int )

#define IOCTL_DEV_HAS_HR_TIME            _MBG_IOR( IOTYPE, 0x47, int )
#define IOCTL_DEV_HAS_CAB_LEN            _MBG_IOR( IOTYPE, 0x48, int )
#define IOCTL_DEV_HAS_TZDL               _MBG_IOR( IOTYPE, 0x49, int )
#define IOCTL_DEV_HAS_PCPS_TZDL          _MBG_IOR( IOTYPE, 0x4A, int )
#define IOCTL_DEV_HAS_TZCODE             _MBG_IOR( IOTYPE, 0x4B, int )
#define IOCTL_DEV_HAS_TZ                 _MBG_IOR( IOTYPE, 0x4C, int )
#define IOCTL_DEV_HAS_EVENT_TIME         _MBG_IOR( IOTYPE, 0x4D, int )
#define IOCTL_DEV_HAS_RECEIVER_INFO      _MBG_IOR( IOTYPE, 0x4E, int )
#define IOCTL_DEV_CAN_CLR_UCAP_BUFF      _MBG_IOR( IOTYPE, 0x4F, int )
#define IOCTL_DEV_HAS_UCAP               _MBG_IOR( IOTYPE, 0x50, int )
#define IOCTL_DEV_HAS_IRIG_TX            _MBG_IOR( IOTYPE, 0x51, int )
#define IOCTL_DEV_HAS_SERIAL_HS          _MBG_IOR( IOTYPE, 0x52, int )
#define IOCTL_DEV_HAS_SIGNAL             _MBG_IOR( IOTYPE, 0x53, int )
#define IOCTL_DEV_HAS_MOD                _MBG_IOR( IOTYPE, 0x54, int )
#define IOCTL_DEV_HAS_IRIG               _MBG_IOR( IOTYPE, 0x55, int )
#define IOCTL_DEV_HAS_REF_OFFS           _MBG_IOR( IOTYPE, 0x56, int )
#define IOCTL_DEV_HAS_OPT_FLAGS          _MBG_IOR( IOTYPE, 0x57, int )
#define IOCTL_DEV_HAS_GPS_DATA           _MBG_IOR( IOTYPE, 0x58, int )
#define IOCTL_DEV_HAS_SYNTH              _MBG_IOR( IOTYPE, 0x59, int )
#define IOCTL_DEV_HAS_GENERIC_IO         _MBG_IOR( IOTYPE, 0x5A, int )

#define IOCTL_PCPS_GENERIC_IO            _MBG_IOG( IOTYPE, 0x5B, IOCTL_GENERIC_REQ )

#define IOCTL_GET_SYNTH_STATE            _MBG_IOR( IOTYPE, 0x5C, SYNTH_STATE )

#define IOCTL_GET_GPS_ALL_POUT_INFO      _MBG_IOG( IOTYPE, 0x5D, IOCTL_GENERIC_REQ )  // variable size
#define IOCTL_SET_GPS_POUT_SETTINGS_IDX  _MBG_IOW( IOTYPE, 0x5E, POUT_SETTINGS_IDX )

#define IOCTL_GET_MAPPED_MEM_ADDR        _MBG_IOR( IOTYPE, 0x5F, PCPS_MAPPED_MEM )
#define IOCTL_UNMAP_MAPPED_MEM           _MBG_IOR( IOTYPE, 0x60, PCPS_MAPPED_MEM )

#define IOCTL_GET_PCI_ASIC_FEATURES      _MBG_IOR( IOTYPE, 0x61, PCI_ASIC_FEATURES )

#define IOCTL_DEV_HAS_PCI_ASIC_FEATURES  _MBG_IOR( IOTYPE, 0x62, int )
#define IOCTL_DEV_HAS_PCI_ASIC_VERSION   _MBG_IOR( IOTYPE, 0x63, int )

#define IOCTL_DEV_IS_MSF                 _MBG_IOR( IOTYPE, 0x64, int )
#define IOCTL_DEV_IS_LWR                 _MBG_IOR( IOTYPE, 0x65, int )
#define IOCTL_DEV_IS_WWVB                _MBG_IOR( IOTYPE, 0x66, int )

#define IOCTL_GET_IRQ_STAT_INFO          _MBG_IOR( IOTYPE, 0x67, PCPS_IRQ_STAT_INFO )
#define IOCTL_GET_CYCLES_FREQUENCY       _MBG_IOR( IOTYPE, 0x68, MBG_PC_CYCLES_FREQUENCY )

#define IOCTL_DEV_HAS_FAST_HR_TIMESTAMP     _MBG_IOR( IOTYPE, 0x69, int )
#define IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES  _MBG_IOR( IOTYPE, 0x6A, PCPS_TIME_STAMP_CYCLES )
#define IOCTL_GET_FAST_HR_TIMESTAMP         _MBG_IOR( IOTYPE, 0x6B, PCPS_TIME_STAMP )

#define IOCTL_DEV_HAS_GPS_TIME_SCALE        _MBG_IOR( IOTYPE, 0x6C, int )
#define IOCTL_GET_GPS_TIME_SCALE_INFO       _MBG_IOR( IOTYPE, 0x6D, MBG_TIME_SCALE_INFO )
#define IOCTL_SET_GPS_TIME_SCALE_SETTINGS   _MBG_IOW( IOTYPE, 0x6E, MBG_TIME_SCALE_SETTINGS )

#define IOCTL_DEV_HAS_GPS_UTC_PARM       _MBG_IOR( IOTYPE, 0x6F, int )
#define IOCTL_GET_GPS_UTC_PARM           _MBG_IOR( IOTYPE, 0x70, UTC )
#define IOCTL_SET_GPS_UTC_PARM           _MBG_IOW( IOTYPE, 0x71, UTC )

#define IOCTL_DEV_HAS_IRIG_CTRL_BITS     _MBG_IOR( IOTYPE, 0x72, int )
#define IOCTL_GET_IRIG_CTRL_BITS         _MBG_IOR( IOTYPE, 0x73, MBG_IRIG_CTRL_BITS )

#define IOCTL_DEV_HAS_LAN_INTF           _MBG_IOR( IOTYPE, 0x74, int )
#define IOCTL_GET_LAN_IF_INFO            _MBG_IOR( IOTYPE, 0x75, LAN_IF_INFO )
#define IOCTL_GET_IP4_STATE              _MBG_IOR( IOTYPE, 0x76, IP4_SETTINGS )
#define IOCTL_GET_IP4_SETTINGS           _MBG_IOR( IOTYPE, 0x77, IP4_SETTINGS )
#define IOCTL_SET_IP4_SETTINGS           _MBG_IOW( IOTYPE, 0x78, IP4_SETTINGS )

#define IOCTL_DEV_IS_PTP                 _MBG_IOR( IOTYPE, 0x79, int )
#define IOCTL_DEV_HAS_PTP                _MBG_IOR( IOTYPE, 0x7A, int )
#define IOCTL_GET_PTP_STATE              _MBG_IOR( IOTYPE, 0x7B, PTP_STATE )
#define IOCTL_GET_PTP_CFG_INFO           _MBG_IOR( IOTYPE, 0x7C, PTP_CFG_INFO )
#define IOCTL_SET_PTP_CFG_SETTINGS       _MBG_IOW( IOTYPE, 0x7D, PTP_CFG_SETTINGS )

#define IOCTL_DEV_HAS_IRIG_TIME          _MBG_IOR( IOTYPE, 0x7E, int )
#define IOCTL_GET_IRIG_TIME              _MBG_IOR( IOTYPE, 0x7F, PCPS_IRIG_TIME )

#define IOCTL_GET_TIME_INFO_HRT          _MBG_IOR( IOTYPE, 0x80, MBG_TIME_INFO_HRT )
#define IOCTL_GET_TIME_INFO_TSTAMP       _MBG_IOR( IOTYPE, 0x81, MBG_TIME_INFO_TSTAMP )

#define IOCTL_DEV_HAS_RAW_IRIG_DATA      _MBG_IOR( IOTYPE, 0x82, int )
#define IOCTL_GET_RAW_IRIG_DATA          _MBG_IOR( IOTYPE, 0x83, MBG_RAW_IRIG_DATA )

#define IOCTL_DEV_HAS_PTP_UNICAST             _MBG_IOR( IOTYPE, 0x84, int )
#define IOCTL_PTP_UC_MASTER_CFG_LIMITS        _MBG_IOR( IOTYPE, 0x85, PTP_UC_MASTER_CFG_LIMITS )
#define IOCTL_GET_ALL_PTP_UC_MASTER_INFO      _MBG_IOG( IOTYPE, 0x86, IOCTL_GENERIC_REQ )  // variable size
#define IOCTL_SET_PTP_UC_MASTER_SETTINGS_IDX  _MBG_IOW( IOTYPE, 0x87, PTP_UC_MASTER_SETTINGS_IDX )

#define IOCTL_DEV_HAS_PZF                _MBG_IOR( IOTYPE, 0x88, int )
#define IOCTL_DEV_HAS_CORR_INFO          _MBG_IOR( IOTYPE, 0x89, int )
#define IOCTL_DEV_HAS_TR_DISTANCE        _MBG_IOR( IOTYPE, 0x8A, int )
#define IOCTL_GET_CORR_INFO              _MBG_IOR( IOTYPE, 0x8B, CORR_INFO )
#define IOCTL_GET_TR_DISTANCE            _MBG_IOR( IOTYPE, 0x8C, TR_DISTANCE )
#define IOCTL_SET_TR_DISTANCE            _MBG_IOW( IOTYPE, 0x8D, TR_DISTANCE )

#define IOCTL_DEV_HAS_DEBUG_STATUS       _MBG_IOR( IOTYPE, 0x8E, int )
#define IOCTL_GET_DEBUG_STATUS           _MBG_IOR( IOTYPE, 0x8F, MBG_DEBUG_STATUS )

#define IOCTL_DEV_HAS_EVT_LOG            _MBG_IOR( IOTYPE, 0x90, int )
#define IOCTL_CLR_EVT_LOG                _MBG_IO(  IOTYPE, 0x91 )
#define IOCTL_GET_NUM_EVT_LOG_ENTRIES    _MBG_IOR( IOTYPE, 0x92, MBG_NUM_EVT_LOG_ENTRIES )
#define IOCTL_GET_FIRST_EVT_LOG_ENTRY    _MBG_IOR( IOTYPE, 0x93, MBG_EVT_LOG_ENTRY )
#define IOCTL_GET_NEXT_EVT_LOG_ENTRY     _MBG_IOR( IOTYPE, 0x94, MBG_EVT_LOG_ENTRY )


// The codes below are subject to changes without notice. They may be supported
// by some kernel drivers, but usage is restricted to Meinberg software development.
// Unrestricted usage may cause system malfunction !!
#define IOCTL_MBG_DBG_GET_PORT_ADDR      _MBG_IOR( IOTYPE, 0xF0, uint16_t )
#define IOCTL_MBG_DBG_SET_PORT_ADDR      _MBG_IOW( IOTYPE, 0xF1, uint16_t )
#define IOCTL_MBG_DBG_SET_BIT            _MBG_IOW( IOTYPE, 0xF2, uint8_t )
#define IOCTL_MBG_DBG_CLR_BIT            _MBG_IOW( IOTYPE, 0xF3, uint8_t )
#define IOCTL_MBG_DBG_CLR_ALL            _MBG_IO(  IOTYPE, 0xF4 )



/**
 * @brief An initializer for a table of IOCTL codes and associated names.
 *
 * This can e.g. be assigned to an array of MBG_CODE_NAME_TABLE_ENTRY elements
 * and may be helpful when debugging.
 */
#define MBG_IOCTL_CODE_TABLE                                                         \
{                                                                                    \
  { IOCTL_GET_PCPS_DRVR_INFO,             "IOCTL_GET_PCPS_DRVR_INFO" },              \
  { IOCTL_GET_PCPS_DEV,                   "IOCTL_GET_PCPS_DEV" },                    \
  { IOCTL_GET_PCPS_STATUS_PORT,           "IOCTL_GET_PCPS_STATUS_PORT" },            \
  { IOCTL_PCPS_GENERIC_READ,              "IOCTL_PCPS_GENERIC_READ" },               \
  { IOCTL_PCPS_GENERIC_WRITE,             "IOCTL_PCPS_GENERIC_WRITE" },              \
  { IOCTL_PCPS_GENERIC_READ_GPS,          "IOCTL_PCPS_GENERIC_READ_GPS" },           \
  { IOCTL_PCPS_GENERIC_WRITE_GPS,         "IOCTL_PCPS_GENERIC_WRITE_GPS" },          \
  { IOCTL_GET_PCPS_TIME,                  "IOCTL_GET_PCPS_TIME" },                   \
  { IOCTL_SET_PCPS_TIME,                  "IOCTL_SET_PCPS_TIME" },                   \
  { IOCTL_GET_PCPS_SYNC_TIME,             "IOCTL_GET_PCPS_SYNC_TIME" },              \
  { IOCTL_GET_PCPS_TIME_SEC_CHANGE,       "IOCTL_GET_PCPS_TIME_SEC_CHANGE" },        \
  { IOCTL_GET_PCPS_HR_TIME,               "IOCTL_GET_PCPS_HR_TIME" },                \
  { IOCTL_SET_PCPS_EVENT_TIME,            "IOCTL_SET_PCPS_EVENT_TIME" },             \
  { IOCTL_GET_PCPS_SERIAL,                "IOCTL_GET_PCPS_SERIAL" },                 \
  { IOCTL_SET_PCPS_SERIAL,                "IOCTL_SET_PCPS_SERIAL" },                 \
  { IOCTL_GET_PCPS_TZCODE,                "IOCTL_GET_PCPS_TZCODE" },                 \
  { IOCTL_SET_PCPS_TZCODE,                "IOCTL_SET_PCPS_TZCODE" },                 \
  { IOCTL_GET_PCPS_TZDL,                  "IOCTL_GET_PCPS_TZDL" },                   \
  { IOCTL_SET_PCPS_TZDL,                  "IOCTL_SET_PCPS_TZDL" },                   \
  { IOCTL_GET_REF_OFFS,                   "IOCTL_GET_REF_OFFS" },                    \
  { IOCTL_SET_REF_OFFS,                   "IOCTL_SET_REF_OFFS" },                    \
  { IOCTL_GET_MBG_OPT_INFO,               "IOCTL_GET_MBG_OPT_INFO" },                \
  { IOCTL_SET_MBG_OPT_SETTINGS,           "IOCTL_SET_MBG_OPT_SETTINGS" },            \
  { IOCTL_GET_PCPS_IRIG_RX_INFO,          "IOCTL_GET_PCPS_IRIG_RX_INFO" },           \
  { IOCTL_SET_PCPS_IRIG_RX_SETTINGS,      "IOCTL_SET_PCPS_IRIG_RX_SETTINGS" },       \
  { IOCTL_PCPS_CLR_UCAP_BUFF,             "IOCTL_PCPS_CLR_UCAP_BUFF" },              \
  { IOCTL_GET_PCPS_UCAP_ENTRIES,          "IOCTL_GET_PCPS_UCAP_ENTRIES" },           \
  { IOCTL_GET_PCPS_UCAP_EVENT,            "IOCTL_GET_PCPS_UCAP_EVENT" },             \
  { IOCTL_GET_GPS_TZDL,                   "IOCTL_GET_GPS_TZDL" },                    \
  { IOCTL_SET_GPS_TZDL,                   "IOCTL_SET_GPS_TZDL" },                    \
  { IOCTL_GET_GPS_SW_REV,                 "IOCTL_GET_GPS_SW_REV" },                  \
  { IOCTL_GET_GPS_BVAR_STAT,              "IOCTL_GET_GPS_BVAR_STAT" },               \
  { IOCTL_GET_GPS_TIME,                   "IOCTL_GET_GPS_TIME" },                    \
  { IOCTL_SET_GPS_TIME,                   "IOCTL_SET_GPS_TIME" },                    \
  { IOCTL_GET_GPS_PORT_PARM,              "IOCTL_GET_GPS_PORT_PARM" },               \
  { IOCTL_SET_GPS_PORT_PARM,              "IOCTL_SET_GPS_PORT_PARM" },               \
  { IOCTL_GET_GPS_ANT_INFO,               "IOCTL_GET_GPS_ANT_INFO" },                \
  { IOCTL_GET_GPS_UCAP,                   "IOCTL_GET_GPS_UCAP" },                    \
  { IOCTL_GET_GPS_ENABLE_FLAGS,           "IOCTL_GET_GPS_ENABLE_FLAGS" },            \
  { IOCTL_SET_GPS_ENABLE_FLAGS,           "IOCTL_SET_GPS_ENABLE_FLAGS" },            \
  { IOCTL_GET_GPS_STAT_INFO,              "IOCTL_GET_GPS_STAT_INFO" },               \
  { IOCTL_SET_GPS_CMD,                    "IOCTL_SET_GPS_CMD" },                     \
  { IOCTL_GET_GPS_IDENT,                  "IOCTL_GET_GPS_IDENT" },                   \
  { IOCTL_GET_GPS_POS,                    "IOCTL_GET_GPS_POS" },                     \
  { IOCTL_SET_GPS_POS_XYZ,                "IOCTL_SET_GPS_POS_XYZ" },                 \
  { IOCTL_SET_GPS_POS_LLA,                "IOCTL_SET_GPS_POS_LLA" },                 \
  { IOCTL_GET_GPS_ANT_CABLE_LEN,          "IOCTL_GET_GPS_ANT_CABLE_LEN" },           \
  { IOCTL_SET_GPS_ANT_CABLE_LEN,          "IOCTL_SET_GPS_ANT_CABLE_LEN" },           \
  { IOCTL_GET_GPS_RECEIVER_INFO,          "IOCTL_GET_GPS_RECEIVER_INFO" },           \
  { IOCTL_GET_GPS_ALL_STR_TYPE_INFO,      "IOCTL_GET_GPS_ALL_STR_TYPE_INFO" },       \
  { IOCTL_GET_GPS_ALL_PORT_INFO,          "IOCTL_GET_GPS_ALL_PORT_INFO" },           \
  { IOCTL_SET_GPS_PORT_SETTINGS_IDX,      "IOCTL_SET_GPS_PORT_SETTINGS_IDX" },       \
  { IOCTL_GET_PCI_ASIC_VERSION,           "IOCTL_GET_PCI_ASIC_VERSION" },            \
  { IOCTL_GET_PCPS_TIME_CYCLES,           "IOCTL_GET_PCPS_TIME_CYCLES" },            \
  { IOCTL_GET_PCPS_HR_TIME_CYCLES,        "IOCTL_GET_PCPS_HR_TIME_CYCLES" },         \
  { IOCTL_GET_PCPS_IRIG_TX_INFO,          "IOCTL_GET_PCPS_IRIG_TX_INFO" },           \
  { IOCTL_SET_PCPS_IRIG_TX_SETTINGS,      "IOCTL_SET_PCPS_IRIG_TX_SETTINGS" },       \
  { IOCTL_GET_SYNTH,                      "IOCTL_GET_SYNTH" },                       \
  { IOCTL_SET_SYNTH,                      "IOCTL_SET_SYNTH" },                       \
  { IOCTL_DEV_IS_GPS,                     "IOCTL_DEV_IS_GPS" },                      \
  { IOCTL_DEV_IS_DCF,                     "IOCTL_DEV_IS_DCF" },                      \
  { IOCTL_DEV_IS_IRIG_RX,                 "IOCTL_DEV_IS_IRIG_RX" },                  \
  { IOCTL_DEV_HAS_HR_TIME,                "IOCTL_DEV_HAS_HR_TIME" },                 \
  { IOCTL_DEV_HAS_CAB_LEN,                "IOCTL_DEV_HAS_CAB_LEN" },                 \
  { IOCTL_DEV_HAS_TZDL,                   "IOCTL_DEV_HAS_TZDL" },                    \
  { IOCTL_DEV_HAS_PCPS_TZDL,              "IOCTL_DEV_HAS_PCPS_TZDL" },               \
  { IOCTL_DEV_HAS_TZCODE,                 "IOCTL_DEV_HAS_TZCODE" },                  \
  { IOCTL_DEV_HAS_TZ,                     "IOCTL_DEV_HAS_TZ" },                      \
  { IOCTL_DEV_HAS_EVENT_TIME,             "IOCTL_DEV_HAS_EVENT_TIME" },              \
  { IOCTL_DEV_HAS_RECEIVER_INFO,          "IOCTL_DEV_HAS_RECEIVER_INFO" },           \
  { IOCTL_DEV_CAN_CLR_UCAP_BUFF,          "IOCTL_DEV_CAN_CLR_UCAP_BUFF" },           \
  { IOCTL_DEV_HAS_UCAP,                   "IOCTL_DEV_HAS_UCAP" },                    \
  { IOCTL_DEV_HAS_IRIG_TX,                "IOCTL_DEV_HAS_IRIG_TX" },                 \
  { IOCTL_DEV_HAS_SERIAL_HS,              "IOCTL_DEV_HAS_SERIAL_HS" },               \
  { IOCTL_DEV_HAS_SIGNAL,                 "IOCTL_DEV_HAS_SIGNAL" },                  \
  { IOCTL_DEV_HAS_MOD,                    "IOCTL_DEV_HAS_MOD" },                     \
  { IOCTL_DEV_HAS_IRIG,                   "IOCTL_DEV_HAS_IRIG" },                    \
  { IOCTL_DEV_HAS_REF_OFFS,               "IOCTL_DEV_HAS_REF_OFFS" },                \
  { IOCTL_DEV_HAS_OPT_FLAGS,              "IOCTL_DEV_HAS_OPT_FLAGS" },               \
  { IOCTL_DEV_HAS_GPS_DATA,               "IOCTL_DEV_HAS_GPS_DATA" },                \
  { IOCTL_DEV_HAS_SYNTH,                  "IOCTL_DEV_HAS_SYNTH" },                   \
  { IOCTL_DEV_HAS_GENERIC_IO,             "IOCTL_DEV_HAS_GENERIC_IO" },              \
  { IOCTL_PCPS_GENERIC_IO,                "IOCTL_PCPS_GENERIC_IO" },                 \
  { IOCTL_GET_SYNTH_STATE,                "IOCTL_GET_SYNTH_STATE" },                 \
  { IOCTL_GET_GPS_ALL_POUT_INFO,          "IOCTL_GET_GPS_ALL_POUT_INFO" },           \
  { IOCTL_SET_GPS_POUT_SETTINGS_IDX,      "IOCTL_SET_GPS_POUT_SETTINGS_IDX" },       \
  { IOCTL_GET_MAPPED_MEM_ADDR,            "IOCTL_GET_MAPPED_MEM_ADDR" },             \
  { IOCTL_UNMAP_MAPPED_MEM,               "IOCTL_UNMAP_MAPPED_MEM" },                \
  { IOCTL_GET_PCI_ASIC_FEATURES,          "IOCTL_GET_PCI_ASIC_FEATURES" },           \
  { IOCTL_DEV_HAS_PCI_ASIC_FEATURES,      "IOCTL_DEV_HAS_PCI_ASIC_FEATURES" },       \
  { IOCTL_DEV_HAS_PCI_ASIC_VERSION,       "IOCTL_DEV_HAS_PCI_ASIC_VERSION" },        \
  { IOCTL_DEV_IS_MSF,                     "IOCTL_DEV_IS_MSF" },                      \
  { IOCTL_DEV_IS_LWR,                     "IOCTL_DEV_IS_LWR" },                      \
  { IOCTL_DEV_IS_WWVB,                    "IOCTL_DEV_IS_WWVB" },                     \
  { IOCTL_GET_IRQ_STAT_INFO,              "IOCTL_GET_IRQ_STAT_INFO" },               \
  { IOCTL_GET_CYCLES_FREQUENCY,           "IOCTL_GET_CYCLES_FREQUENCY" },            \
  { IOCTL_DEV_HAS_FAST_HR_TIMESTAMP,      "IOCTL_DEV_HAS_FAST_HR_TIMESTAMP" },       \
  { IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES,   "IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES" },    \
  { IOCTL_GET_FAST_HR_TIMESTAMP,          "IOCTL_GET_FAST_HR_TIMESTAMP" },           \
  { IOCTL_DEV_HAS_GPS_TIME_SCALE,         "IOCTL_DEV_HAS_GPS_TIME_SCALE" },          \
  { IOCTL_GET_GPS_TIME_SCALE_INFO,        "IOCTL_GET_GPS_TIME_SCALE_INFO" },         \
  { IOCTL_SET_GPS_TIME_SCALE_SETTINGS,    "IOCTL_SET_GPS_TIME_SCALE_SETTINGS" },     \
  { IOCTL_DEV_HAS_GPS_UTC_PARM,           "IOCTL_DEV_HAS_GPS_UTC_PARM" },            \
  { IOCTL_GET_GPS_UTC_PARM,               "IOCTL_GET_GPS_UTC_PARM" },                \
  { IOCTL_SET_GPS_UTC_PARM,               "IOCTL_SET_GPS_UTC_PARM" },                \
  { IOCTL_DEV_HAS_IRIG_CTRL_BITS,         "IOCTL_DEV_HAS_IRIG_CTRL_BITS" },          \
  { IOCTL_GET_IRIG_CTRL_BITS,             "IOCTL_GET_IRIG_CTRL_BITS" },              \
  { IOCTL_DEV_HAS_LAN_INTF,               "IOCTL_DEV_HAS_LAN_INTF" },                \
  { IOCTL_GET_LAN_IF_INFO,                "IOCTL_GET_LAN_IF_INFO" },                 \
  { IOCTL_GET_IP4_STATE,                  "IOCTL_GET_IP4_STATE" },                   \
  { IOCTL_GET_IP4_SETTINGS,               "IOCTL_GET_IP4_SETTINGS" },                \
  { IOCTL_SET_IP4_SETTINGS,               "IOCTL_SET_IP4_SETTINGS" },                \
  { IOCTL_DEV_IS_PTP,                     "IOCTL_DEV_IS_PTP" },                      \
  { IOCTL_DEV_HAS_PTP,                    "IOCTL_DEV_HAS_PTP" },                     \
  { IOCTL_GET_PTP_STATE,                  "IOCTL_GET_PTP_STATE" },                   \
  { IOCTL_GET_PTP_CFG_INFO,               "IOCTL_GET_PTP_CFG_INFO" },                \
  { IOCTL_SET_PTP_CFG_SETTINGS,           "IOCTL_SET_PTP_CFG_SETTINGS" },            \
  { IOCTL_DEV_HAS_IRIG_TIME,              "IOCTL_DEV_HAS_IRIG_TIME" },               \
  { IOCTL_GET_IRIG_TIME,                  "IOCTL_GET_IRIG_TIME" },                   \
  { IOCTL_GET_TIME_INFO_HRT,              "IOCTL_GET_TIME_INFO_HRT" },               \
  { IOCTL_GET_TIME_INFO_TSTAMP,           "IOCTL_GET_TIME_INFO_TSTAMP" },            \
  { IOCTL_DEV_HAS_RAW_IRIG_DATA,          "IOCTL_DEV_HAS_RAW_IRIG_DATA" },           \
  { IOCTL_GET_RAW_IRIG_DATA,              "IOCTL_GET_RAW_IRIG_DATA" },               \
  { IOCTL_DEV_HAS_PTP_UNICAST,            "IOCTL_DEV_HAS_PTP_UNICAST" },             \
  { IOCTL_PTP_UC_MASTER_CFG_LIMITS,       "IOCTL_PTP_UC_MASTER_CFG_LIMITS" },        \
  { IOCTL_GET_ALL_PTP_UC_MASTER_INFO,     "IOCTL_GET_ALL_PTP_UC_MASTER_INFO" },      \
  { IOCTL_SET_PTP_UC_MASTER_SETTINGS_IDX, "IOCTL_SET_PTP_UC_MASTER_SETTINGS_IDX" },  \
  { IOCTL_DEV_HAS_PZF,                    "IOCTL_DEV_HAS_PZF" },                     \
  { IOCTL_DEV_HAS_CORR_INFO,              "IOCTL_DEV_HAS_CORR_INFO" },               \
  { IOCTL_DEV_HAS_TR_DISTANCE,            "IOCTL_DEV_HAS_TR_DISTANCE" },             \
  { IOCTL_GET_CORR_INFO,                  "IOCTL_GET_CORR_INFO" },                   \
  { IOCTL_GET_TR_DISTANCE,                "IOCTL_GET_TR_DISTANCE" },                 \
  { IOCTL_SET_TR_DISTANCE,                "IOCTL_SET_TR_DISTANCE" },                 \
  { IOCTL_DEV_HAS_DEBUG_STATUS,           "IOCTL_DEV_HAS_DEBUG_STATUS" },            \
  { IOCTL_GET_DEBUG_STATUS,               "IOCTL_GET_DEBUG_STATUS" },                \
  { IOCTL_DEV_HAS_EVT_LOG,                "IOCTL_DEV_HAS_EVT_LOG" },                 \
  { IOCTL_CLR_EVT_LOG,                    "IOCTL_CLR_EVT_LOG" },                     \
  { IOCTL_GET_NUM_EVT_LOG_ENTRIES,        "IOCTL_GET_NUM_EVT_LOG_ENTRIES" },         \
  { IOCTL_GET_FIRST_EVT_LOG_ENTRY,        "IOCTL_GET_FIRST_EVT_LOG_ENTRY" },         \
  { IOCTL_GET_NEXT_EVT_LOG_ENTRY,         "IOCTL_GET_NEXT_EVT_LOG_ENTRY" },          \
                                                                                     \
  { IOCTL_MBG_DBG_GET_PORT_ADDR,          "IOCTL_MBG_DBG_GET_PORT_ADDR" },           \
  { IOCTL_MBG_DBG_SET_PORT_ADDR,          "IOCTL_MBG_DBG_SET_PORT_ADDR" },           \
  { IOCTL_MBG_DBG_SET_BIT,                "IOCTL_MBG_DBG_SET_BIT" },                 \
  { IOCTL_MBG_DBG_CLR_BIT,                "IOCTL_MBG_DBG_CLR_BIT" },                 \
  { 0,                                    NULL }                                     \
}


#if !defined( _cmd_from_ioctl_code )
  #define _cmd_from_ioctl_code( _ioctl_code )   _ioctl_code
#endif



/**
 * @brief Privilege levels for IOCTL codes.
 *
 * IOCTLs can be used to do different things ranging from simply
 * reading a timestamp up to forcing a GPS receiver into boot mode
 * which may completely mess up the time keeping on the PC.
 *
 * These codes are used to determine a privilege level required
 * to execute a specific IOCTL command.
 *
 * How to determine if a calling process has sufficient privileges
 * depends strongly on the rights management features provided
 * by the underlying OS (e.g simple user/group rights, ACLs,
 * Linux capabilities, Windows privileges) so this needs to be
 * implemented in the OS-specific code of a driver.
 *
 * Implementation should be done in a way which introduces as low
 * latency as possible when reading time stamps from a device.
 */
enum
{
  MBG_REQ_PRIVL_NONE,         //< e.g. read date/time/sync status
  MBG_REQ_PRIVL_EXT_STATUS,   //< e.g. read receiver position
  MBG_REQ_PRIVL_CFG_READ,     //< read device config data
  MBG_REQ_PRIVL_CFG_WRITE,    //< write config data to the device
  MBG_REQ_PRIVL_SYSTEM,       //< operations which may affect system operation
  N_MBG_REQ_PRIVL             //< the number of supported privilege levels
};


#if defined( __GNUC__ )
// Avoid "no previous prototype" with some gcc versions.
static __mbg_inline
int ioctl_get_required_privilege( ulong ioctl_code ) __attribute__((always_inline));
#endif

/**
 * @brief Determine the privilege level required to execute a specific IOCTL command.
 *
 * @param ioctl_code The IOCTL code for which to return the privilege level
 *
 * @return One of the enumerated privilege levels
 * @return -1 for unknown IOCTL codes
 */
static __mbg_inline
int ioctl_get_required_privilege( ulong ioctl_code )
{
  // To provide best maintainability the sequence of cases in ioctl_switch()
  // should match the sequence of the cases here, which also makes sure
  // commands requiring lowest latency are handled first.

  switch ( ioctl_code )
  {
    // Commands requiring lowest latency:
    case IOCTL_GET_FAST_HR_TIMESTAMP:
    case IOCTL_GET_PCPS_HR_TIME:
    case IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES:
    case IOCTL_GET_PCPS_HR_TIME_CYCLES:
    case IOCTL_GET_PCPS_UCAP_EVENT:
    // Other low latency commands:
    case IOCTL_GET_PCPS_TIME:
    case IOCTL_GET_PCPS_TIME_CYCLES:
    case IOCTL_GET_PCPS_STATUS_PORT:
    case IOCTL_GET_PCPS_TIME_SEC_CHANGE:
    case IOCTL_GET_GPS_TIME:
    case IOCTL_GET_GPS_UCAP:
    case IOCTL_GET_TIME_INFO_HRT:
    case IOCTL_GET_TIME_INFO_TSTAMP:
      return MBG_REQ_PRIVL_NONE;

    // Commands returning public status information:
    case IOCTL_GET_PCPS_DRVR_INFO:
    case IOCTL_GET_PCPS_DEV:
    case IOCTL_GET_PCPS_SYNC_TIME:
    case IOCTL_GET_GPS_SW_REV:
    case IOCTL_GET_GPS_BVAR_STAT:
    case IOCTL_GET_GPS_ANT_INFO:
    case IOCTL_GET_GPS_STAT_INFO:
    case IOCTL_GET_GPS_IDENT:
    case IOCTL_GET_GPS_RECEIVER_INFO:
    case IOCTL_GET_PCI_ASIC_VERSION:
    case IOCTL_GET_SYNTH_STATE:
    case IOCTL_GET_PCPS_UCAP_ENTRIES:
    case IOCTL_GET_PCI_ASIC_FEATURES:
    case IOCTL_GET_IRQ_STAT_INFO:
    case IOCTL_GET_CYCLES_FREQUENCY:
    case IOCTL_GET_IRIG_CTRL_BITS:
    case IOCTL_GET_IP4_STATE:
    case IOCTL_GET_PTP_STATE:
    case IOCTL_GET_CORR_INFO:
    case IOCTL_GET_DEBUG_STATUS:
    case IOCTL_GET_NUM_EVT_LOG_ENTRIES:
    case IOCTL_GET_FIRST_EVT_LOG_ENTRY:
    case IOCTL_GET_NEXT_EVT_LOG_ENTRY:
      return MBG_REQ_PRIVL_NONE;

    // Commands returning device capabilities and features:
    case IOCTL_DEV_IS_GPS:
    case IOCTL_DEV_IS_DCF:
    case IOCTL_DEV_IS_MSF:
    case IOCTL_DEV_IS_WWVB:
    case IOCTL_DEV_IS_LWR:
    case IOCTL_DEV_IS_IRIG_RX:
    case IOCTL_DEV_HAS_HR_TIME:
    case IOCTL_DEV_HAS_CAB_LEN:
    case IOCTL_DEV_HAS_TZDL:
    case IOCTL_DEV_HAS_PCPS_TZDL:
    case IOCTL_DEV_HAS_TZCODE:
    case IOCTL_DEV_HAS_TZ:
    case IOCTL_DEV_HAS_EVENT_TIME:
    case IOCTL_DEV_HAS_RECEIVER_INFO:
    case IOCTL_DEV_CAN_CLR_UCAP_BUFF:
    case IOCTL_DEV_HAS_UCAP:
    case IOCTL_DEV_HAS_IRIG_TX:
    case IOCTL_DEV_HAS_SERIAL_HS:
    case IOCTL_DEV_HAS_SIGNAL:
    case IOCTL_DEV_HAS_MOD:
    case IOCTL_DEV_HAS_IRIG:
    case IOCTL_DEV_HAS_REF_OFFS:
    case IOCTL_DEV_HAS_OPT_FLAGS:
    case IOCTL_DEV_HAS_GPS_DATA:
    case IOCTL_DEV_HAS_SYNTH:
    case IOCTL_DEV_HAS_GENERIC_IO:
    case IOCTL_DEV_HAS_PCI_ASIC_FEATURES:
    case IOCTL_DEV_HAS_PCI_ASIC_VERSION:
    case IOCTL_DEV_HAS_FAST_HR_TIMESTAMP:
    case IOCTL_DEV_HAS_GPS_TIME_SCALE:
    case IOCTL_DEV_HAS_GPS_UTC_PARM:
    case IOCTL_DEV_HAS_IRIG_CTRL_BITS:
    case IOCTL_DEV_HAS_LAN_INTF:
    case IOCTL_DEV_IS_PTP:
    case IOCTL_DEV_HAS_PTP:
    case IOCTL_DEV_HAS_IRIG_TIME:
    case IOCTL_DEV_HAS_RAW_IRIG_DATA:
    case IOCTL_DEV_HAS_PTP_UNICAST:
    case IOCTL_DEV_HAS_PZF:
    case IOCTL_DEV_HAS_CORR_INFO:
    case IOCTL_DEV_HAS_TR_DISTANCE:
    case IOCTL_DEV_HAS_DEBUG_STATUS:
    case IOCTL_DEV_HAS_EVT_LOG:
      return MBG_REQ_PRIVL_NONE;

    // The next codes are somewhat special since they change something
    // on the board but do not affect basic operation:
    case IOCTL_PCPS_CLR_UCAP_BUFF:
    case IOCTL_SET_PCPS_EVENT_TIME:  // supported by some customized firmware only
    case IOCTL_CLR_EVT_LOG:
      return MBG_REQ_PRIVL_NONE;

    // Status information which may not be available for everybody:
    case IOCTL_GET_GPS_POS:
      return MBG_REQ_PRIVL_EXT_STATUS;

    // Reading device configuration:
    case IOCTL_GET_PCPS_SERIAL:
    case IOCTL_GET_PCPS_TZCODE:
    case IOCTL_GET_PCPS_TZDL:
    case IOCTL_GET_REF_OFFS:
    case IOCTL_GET_MBG_OPT_INFO:
    case IOCTL_GET_PCPS_IRIG_RX_INFO:
    case IOCTL_GET_GPS_TZDL:
    case IOCTL_GET_GPS_PORT_PARM:
    case IOCTL_GET_GPS_ENABLE_FLAGS:
    case IOCTL_GET_GPS_ANT_CABLE_LEN:
    case IOCTL_GET_PCPS_IRIG_TX_INFO:
    case IOCTL_GET_SYNTH:
    case IOCTL_GET_GPS_TIME_SCALE_INFO:
    case IOCTL_GET_GPS_UTC_PARM:
    case IOCTL_GET_LAN_IF_INFO:
    case IOCTL_GET_IP4_SETTINGS:
    case IOCTL_GET_PTP_CFG_INFO:
    case IOCTL_GET_IRIG_TIME:
    case IOCTL_GET_RAW_IRIG_DATA:
    case IOCTL_PTP_UC_MASTER_CFG_LIMITS:
    case IOCTL_GET_TR_DISTANCE:
    // generic read functions
    case IOCTL_PCPS_GENERIC_READ:
    case IOCTL_PCPS_GENERIC_READ_GPS:
  #if _MBG_SUPP_VAR_ACC_SIZE
    // These codes are only supported on target systems where a variable size of
    // the IOCTL buffer can be specified in the IOCTL call. On other systems the
    // generic IOCTL functions are used instead.
    case IOCTL_GET_GPS_ALL_STR_TYPE_INFO:
    case IOCTL_GET_GPS_ALL_PORT_INFO:
    case IOCTL_GET_GPS_ALL_POUT_INFO:
    case IOCTL_GET_ALL_PTP_UC_MASTER_INFO:
  #endif
      return MBG_REQ_PRIVL_CFG_READ;

    // Writing device configuration:
    case IOCTL_SET_PCPS_SERIAL:
    case IOCTL_SET_PCPS_TZCODE:
    case IOCTL_SET_PCPS_TZDL:
    case IOCTL_SET_REF_OFFS:
    case IOCTL_SET_MBG_OPT_SETTINGS:
    case IOCTL_SET_PCPS_IRIG_RX_SETTINGS:
    case IOCTL_SET_GPS_TZDL:
    case IOCTL_SET_GPS_PORT_PARM:
    case IOCTL_SET_GPS_ENABLE_FLAGS:
    case IOCTL_SET_GPS_ANT_CABLE_LEN:
    case IOCTL_SET_GPS_PORT_SETTINGS_IDX:
    case IOCTL_SET_PCPS_IRIG_TX_SETTINGS:
    case IOCTL_SET_SYNTH:
    case IOCTL_SET_GPS_POUT_SETTINGS_IDX:
    case IOCTL_SET_IP4_SETTINGS:
    case IOCTL_SET_PTP_CFG_SETTINGS:
    case IOCTL_SET_PTP_UC_MASTER_SETTINGS_IDX:
    case IOCTL_SET_TR_DISTANCE:
      return MBG_REQ_PRIVL_CFG_WRITE;

    // Operations which may severely affect system operation:
    case IOCTL_SET_PCPS_TIME:
    case IOCTL_SET_GPS_TIME:
    case IOCTL_SET_GPS_POS_XYZ:
    case IOCTL_SET_GPS_POS_LLA:
    case IOCTL_SET_GPS_TIME_SCALE_SETTINGS:
    case IOCTL_SET_GPS_UTC_PARM:
    case IOCTL_SET_GPS_CMD:
    // generic write operations can do anything
    case IOCTL_PCPS_GENERIC_WRITE:
    case IOCTL_PCPS_GENERIC_WRITE_GPS:
    case IOCTL_PCPS_GENERIC_IO:
      return MBG_REQ_PRIVL_SYSTEM;

    // The next codes are somewhat special and normally
    // not used by the driver software:
    case IOCTL_GET_MAPPED_MEM_ADDR:
    case IOCTL_UNMAP_MAPPED_MEM:
      return MBG_REQ_PRIVL_SYSTEM;

  #if USE_DEBUG_PORT
    // The codes below are used for debugging only.
    // Unrestricted usage may cause system malfunction !!
    case IOCTL_MBG_DBG_GET_PORT_ADDR:
    case IOCTL_MBG_DBG_SET_PORT_ADDR:
    case IOCTL_MBG_DBG_SET_BIT:
    case IOCTL_MBG_DBG_CLR_BIT:
    case IOCTL_MBG_DBG_CLR_ALL:
      return MBG_REQ_PRIVL_SYSTEM;
  #endif
  }  // switch

  return -1;   // unsupported code, should always be denied

}  // ioctl_get_required_privilege



/* End of header body */

#undef _ext
#undef _DO_INIT


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


#endif  /* _MBGIOCTL_H */
