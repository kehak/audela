
/**************************************************************************
 *
 *  $Id: macioctl.h 1.33.1.31 2011/11/25 15:03:17 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Macros used inside the IOCTL handlers of device drivers
 *    for Meinberg PCI and USB devices.
 *
 * -----------------------------------------------------------------------
 *  $Log: macioctl.h $
 *  Revision 1.33.1.31  2011/11/25 15:03:17  martin
 *  Support on-board event logs.
 *  Revision 1.33.1.30  2011/11/24 08:24:54  martin
 *  Revision 1.33.1.29  2011/11/23 16:49:06  martin
 *  Fixed a bug in IOCTL_PCPS_GENERIC_IO handler.
 *  Support debug status.
 *  Revision 1.33.1.28  2011/10/05 09:00:14  martin
 *  Made inline functions static.
 *  Revision 1.33.1.27  2011/09/21 16:01:54  martin
 *  Include cfg_hlp.h.
 *  Revision 1.33.1.26  2011/09/08 13:17:54  martin
 *  Always read receiver info directly from the device.
 *  Revision 1.33.1.25  2011/07/20 15:48:22  martin
 *  Conditionally use older IOCTL request buffer structures.
 *  Revision 1.33.1.24  2011/07/19 12:52:05  martin
 *  Revision 1.33.1.23  2011/07/14 14:53:58  martin
 *  Modified generic IOCTL handling such that for calls requiring variable sizes
 *  a fixed request block containing input and output buffer pointers and sizes is
 *  passed down to the kernel driver. This simplifies implementation under *BSD
 *  and also works for other target systems.
 *  Revision 1.33.1.22  2011/07/06 11:19:19  martin
 *  Support reading CORR_INFO, and reading/writing TR_DISTANCE.
 *  Revision 1.33.1.21  2011/06/29 10:51:16  martin
 *  Support IOCTL_DEV_HAS_PZF.
 *  Revision 1.33.1.20  2011/05/18 10:08:13  martin
 *  Re-ordered IOCTL evaluation to match ioctl_get_required_privilege()
 *  which also makes sure calls requiring lowest latency are handled first.
 *  Revision 1.33.1.19  2011/05/17 16:05:06  martin
 *  Use a single union type buffer instead of a large number of local
 *  variables in ioctl_switch().
 *  The accumulated size of all local variables required much stack
 *  space which led to problems under Windows.
 *  Revision 1.33.1.18  2011/05/17 09:37:31  martin
 *  Support PTP unicast configuration.
 *  Account for some IOCTL codes renamed to follow common naming conventions.
 *  Revision 1.33.1.17  2011/04/12 15:28:54  martin
 *  Use common mutex primitives from mbgmutex.h.
 *  Revision 1.33.1.16  2011/03/31 10:57:00  martin
 *  Revision 1.33.1.15  2011/03/31 07:32:09  martin
 *  This version is the same as 1.33.1.12.
 *  Revision 1.33.1.14  2011/03/31 07:16:34  martin
 *  Changes by Frank Kardel: Don't require copyin/copyout under NetBSD.
 *  Revision 1.33.1.13  2011/03/23 16:50:30  martin
 *  Support NetBSD beside FreeBSD.
 *  Revision 1.33.1.12  2011/03/21 16:25:23  martin
 *  Account for modified _pcpc_kfree().
 *  Revision 1.33.1.11  2011/03/02 09:59:50  daniel
 *  Bug fix: Use PCPS_TIME_STAMP with 
 *  IOCTL_GET_FAST_HR_TIMESTAMP as output size.
 *  Revision 1.33.1.10  2011/02/15 14:50:39Z  martin
 *  In a call to retrieve RECEIVER_INFO don't read from device
 *  but just copy the field from the device info structure.
 *  Revision 1.33.1.9  2011/02/15 11:08:33  daniel
 *  Preliminary support for PTP unicast
 *  Revision 1.33.1.8  2011/02/09 17:08:27Z  martin
 *  Specify I/O range number when calling port I/O macros
 *  so they can be used for different ranges under BSD.
 *  Revision 1.33.1.7  2011/01/26 16:37:55  martin
 *  Modified inline declarations for gcc.
 *  Revision 1.33.1.6  2011/01/24 17:08:40  martin
 *  Fixed build under FreeBSD.
 *  Revision 1.33.1.5  2010/11/09 10:57:33  martin
 *  Added _sem_inc_safe_no_irp() macro (Windows only).
 *  Revision 1.33.1.4  2010/07/16 08:31:32Z  martin
 *  Revision 1.33.1.3  2010/07/15 15:47:07  martin
 *  Revision 1.33.1.2  2010/07/14 14:48:52  martin
 *  Simplified code and renamed some inline functions.
 *  Revision 1.33.1.1  2010/03/03 15:11:51  martin
 *  Fixed macro.
 *  Revision 1.33  2009/12/21 16:22:55  martin
 *  Moved code reading memory mapped timestamps to inline functions.
 *  Revision 1.32  2009/12/15 15:34:57  daniel
 *  Support reading the raw IRIG data bits for firmware versions 
 *  which support this feature.
 *  Revision 1.31  2009/11/04 14:58:52Z  martin
 *  Conditionally exclude port status query from build.
 *  Revision 1.30  2009/09/29 15:08:39  martin
 *  Support retrieving time discipline info.
 *  Revision 1.29  2009/08/18 08:45:16  martin
 *  Removed IOCTL switch macro, inline code used for all targets.
 *  Revision 1.28  2009/06/26 13:16:11Z  martin
 *  Fixed duplicate case in inline code (copy and paste error).
 *  Revision 1.27  2009/06/22 13:52:56  martin
 *  Fixed a bug where the size of GPS data had been truncated to 8 bits,
 *  which resulted in an IOCTL error if a buffer larger than 256 bytes had been
 *  used. This had been observed with the PC_GPS_ALL_STR_TYPE_INFO
 *  command if more than 6 string types are supported by a card.
 *  Revision 1.26  2009/06/19 12:21:12  martin
 *  Support reading raw IRIG time.
 *  Revision 1.25  2009/06/09 10:01:01  daniel
 *  Support configuration of LAN intf. and PTP.
 *  Started to support ARM / firmware.
 *  Conditionally compile ioctl_switch as inline function.
 *  Revision 1.24  2009/03/19 15:25:19  martin
 *  Support UTC parms and configurable time scales.
 *  Support IOCTL_DEV_HAS_IRIG_CTRL_BITS and IOCTL_GET_IRIG_CTRL_BITS.
 *  Support reading MM timestamps without cycles.
 *  IOCTL_GET_PCI_ASIC_VERSION now returns the ASIC
 *  version code from the device info structure which already
 *  has the correct endianess.
 *  For consistent naming renamed IOCTL_GET_FAST_HR_TIMESTAMP
 *  to IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES.
 *  Use mbg_get_cycles...() instead of _pcps_get_cycles...().
 *  Revision 1.23  2008/12/11 10:30:38Z  martin
 *  _pcps_get_cycles() is now called inside the low level routines
 *  immediately when the command byte is written.
 *  Mutex for hardware access is now acquired/released in _pcps_sem_inc() 
 *  and _pcps_sem_dec(), so other IOCTLs which don't access the card
 *  can be run in parallel.
 *  Moved definitions of _pcps_sem_inc(), _pcps_sem_dec(), and
 *  _pcps_get_cycles() to pcpsdrvr.h.
 *  Defined a macro which checks if access is safe (may be unsafe
 *  with certain PEX cards which have IRQs enabled).
 *  Use _pcps_sem_inc_safe() macro to check if access is safe and
 *  inhibit access if this is not the case.
 *  Consistenly use pcps_drvr_name instead of mbgclock_name 
 *  for debug messages.
 *  Don't return error for unmap_mm...() under Linux.
 *  Account for ASIC_FEATURES being coded as flags, and account
 *  for new symbol PCI_ASIC_HAS_MM_IO.
 *  Handle new IOCTLs IOCTL_HAS_PCI_ASIC_FEATURES, IOCTL_HAS_PCI_ASIC_VERSION,
 *  IOCTL_DEV_IS_MSF, IOCTL_DEV_IS_LWR, IOCTL_DEV_IS_WWVB, 
 *  IOCTL_GET_IRQ_STAT_INFO, IOCTL_GET_CYCLES_FREQUENCY, 
 *  IOCTL_HAS_FAST_HR_TIMESTAMP, and IOCTL_GET_FAST_HR_TIMESTAMP.
 *  Support mapped I/O resources.
 *  Revision 1.22  2008/01/17 09:28:49  daniel
 *  Support for memory mapped I/O under Linux and Windows.
 *  Added macros _io_get_mapped_mem_address(),
 *  _io_unmap_mapped_mem_address().
 *  Account for IOCTL_GET_PCI_ASIC_FEATURES
 *  Cleanup for PCI ASIC version.
 *  Revision 1.21  2007/09/26 07:31:47Z  martin
 *  Support reading status port of USB devices.
 *  Use kernel malloc/free macros from pcpsdrvr.h.
 *  Modified _pcps_sem..() to take PCPS_DDEV argument.
 *  Revision 1.20  2007/05/21 15:00:00Z  martin
 *  Unified naming convention for symbols related to ref_offs.
 *  Revision 1.19  2007/03/30 13:31:42  martin
 *  Changes due to renamed library symbol.
 *  Revision 1.18  2007/03/02 10:31:21Z  martin
 *  Use generic port I/O macros.
 *  Preliminary support for *BSD.
 *  Preliminary _cmd_from_ioctl().
 *  Revision 1.17  2006/03/10 10:35:43  martin
 *  Added support for programmable pulse outputs.
 *  Revision 1.16  2005/06/02 10:16:37Z  martin
 *  Implemented IOCTL_PCPS_GENERIC_.. calls.
 *  Added support for SYNTH_STATE.
 *  Moved Debug IOCTL handling here.
 *  Revision 1.15  2005/01/14 10:26:41Z  martin
 *  Support IOCTLs which query device features.
 *  Revision 1.14  2004/12/09 11:03:36Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.13  2004/11/09 12:47:19Z  martin
 *  Use new macro _pcps_ddev_has_gps_data() to check whether GPS large 
 *  data I/O is supported.
 *  Changes due to renamed symbols, IRIG RX/TX.
 *  Modifications were required in order to be able to configure IRIG 
 *  settings of cards which provide both IRIG input and output.
 *  GPS169PCI cards with IRIG output and early firmware versions 
 *  used the same codes to configure the IRIG output as the TCR 
 *  cards use to configure the IRIG input. Those codes are now 
 *  exclusively used to configure the IRIG input. A workaround
 *  has been included for those GPS169PCI cards, because otherwise 
 *  the IRIG configuration would not work properly after a driver 
 *  update, without also doing a firmware update.
 *  Show debug msg if GPS169PCI workaround for IRIG cfg in effect.
 *  Use more specific data types than generic types.
 *  Modified contents of debug messages.
 *  Added (uchar FAR *) cast.
 *  Revision 1.12  2004/06/07 09:20:52  martin
 *  Account for renamed symbols.
 *  Revision 1.11  2004/04/07 09:05:17  martin
 *  Support OS dependent IOCTLs used to trigger debug events.
 *  Revision 1.10  2004/03/16 16:25:42Z  martin
 *  Support new macro _pcps_has_irig().
 *  Revision 1.9  2004/01/08 10:57:23Z  martin
 *  Support codes to read ASIC version, and read times
 *  with associated cycle counter values.
 *  Support higher baud rates for TCR510PCI and PCI510.
 *  Support PCPS_HR_TIME for TCR510PCI.
 *  Revision 1.8  2003/09/17 12:49:57Z  martin
 *  Use PCPS_GIVE_TIME_NOCLEAR in API mbg_get_time().
 *  Revision 1.7  2003/09/09 13:33:55Z  martin
 *  Support IOCTL_GET_PCPS_TIME_SEC_CHANGE.
 *  Revision 1.6  2003/06/19 09:18:02Z  martin
 *  Supports new APIs IOCTL_PCPS_GET_UCAP_ENTRIES
 *  and IOCTL_PCPS_GET_UCAP_EVENT.
 *  Changes due to renamed symbols.
 *  Preliminary _pout_size for Linux.
 *  Revision 1.5  2003/04/15 08:50:38Z  martin
 *  Support ALL_STR_TYPE_INFO, ALL_PORT_INFO for Win32.
 *  Revision 1.4  2003/04/09 16:51:29Z  martin
 *  Use new common IOCTL codes from mbgioctl.h.
 *  Support almost all IOCTL codes.
 *  Support for Win32.
 *  Revision 1.3  2001/11/30 09:52:47Z  martin
 *  Added support for event_time which, however, requires 
 *  a custom GPS firmware.
 *  Revision 1.2  2001/09/14 12:01:17  martin
 *  Decode PCPS_IOCTL_SET_GPS_CMD.
 *  Added some comments.
 *  Revision 1.1  2001/04/09 07:47:01  MARTIN
 *
 **************************************************************************/

#ifndef _MACIOCTL_H
#define _MACIOCTL_H

#include <mbgioctl.h>
#include <cfg_hlp.h>
#include <pcpsdrvr.h>
#include <pci_asic.h>
#include <mbgddmsg.h>


// The types below are used since the macros used in this file
// have been written to use structs and compilers return errors
// if those macros are used with array variables.

typedef struct
{
  LLA lla;
} LLAs;

typedef struct
{
  XYZ xyz;
} XYZs;



// OS dependent primitives
#if defined( MBG_TGT_LINUX )

  #define _iob_to_pout( _piob, _pout, _size )  \
    if ( copy_to_user( _pout, _piob, _size ) ) \
      goto err_to_user;

  #define _iob_from_pin( _piob, _pin, _size )   \
    if ( copy_from_user( _piob, _pin, _size ) ) \
      goto err_from_user;

  #define _io_wait_pcps_sec_change( _pddev, _cmd, _type, _pout ) \
    goto err_inval

  #define _io_get_mapped_mem_address( _pddev, _pout )                                                \
  {                                                                                                  \
    iob.mapped_mem.pfn_offset = ( pddev->rsrc_info.mem[0].start & ~PAGE_MASK ) + sizeof( PCI_ASIC ); \
    iob.mapped_mem.len = pddev->rsrc_info.mem[0].len - sizeof( PCI_ASIC );                           \
    _iob_to_pout_var( iob.mapped_mem, _pout );                                                       \
  }

  #define _io_unmap_mapped_mem_address( _pddev, _pin ) \
    _nop_macro_fnc()

  #define USE_COPY_KERNEL_USER   1

#elif defined( MBG_TGT_BSD )

  #include <sys/malloc.h>

  #define _iob_to_pout( _piob, _pout, _size ) \
    memcpy( _pout, _piob, _size )

  #define _iob_from_pin( _piob, _pin, _size ) \
    memcpy( _piob, _pin, _size )

  #define _frc_iob_to_pout( _piob, _pout, _size ) \
    copyout( _piob, _pout, _size )

  #define _frc_iob_from_pin( _piob, _pin, _size ) \
    copyin( _pin, _piob, _size )

  #define _io_wait_pcps_sec_change( _pddev, _cmd, _type, _pout ) \
    goto err_inval

  #define _io_get_mapped_mem_address( _pddev, _pout ) \
    goto err_inval

  #define _io_unmap_mapped_mem_address( _pddev, _pin ) \
    goto err_inval

#elif defined( MBG_TGT_WIN32 )

  #define _iob_to_pout( _piob, _pout, _size ) \
  {                                           \
    RtlCopyMemory( _pout, _piob, _size );     \
    *ret_size = _size;                        \
  }

  #define _iob_from_pin( _piob, _pin, _size ) \
    RtlCopyMemory( _piob, _pin, _size );

  // The following macros are defined in the OS dependent code:
  //
  //   _io_wait_pcps_sec_change()
  //   _io_get_mapped_mem_address()
  //   _io_unmap_mapped_mem_address()
  //   _io_set_interrupt()
  //

#endif



#if !defined( _frc_iob_to_pout )
  #define _frc_iob_to_pout   _iob_to_pout
#endif

#if !defined( _frc_iob_from_pin )
  #define _frc_iob_from_pin  _iob_from_pin
#endif


#define _iob_to_pout_var( _iob, _pout ) \
  _iob_to_pout( &(_iob), _pout, sizeof( _iob ) )

#define _iob_from_pin_var( _iob, _pin ) \
  _iob_from_pin( &(_iob), _pin, sizeof( _iob ) )



// For some cards it may be unsafe to access the card while
// interrups are enabled for the card since IRQs may during
// access may mess up the interface. The macro below checks
// whether this is the case.
#define _pcps_access_is_unsafe( _pddev ) \
  ( ( (_pddev)->irq_stat_info & PCPS_IRQ_STATE_DANGER ) == PCPS_IRQ_STATE_DANGER )



// Check whether a card can be accessed safely and set a flag
// preventing the card from being accessed from IRQ handler.
#if defined( MBG_TGT_WIN32 )

  // Under Windows we need to save a pointer to the current
  // IRP by default.
  #define _pcps_sem_inc_safe( _pddev )      \
    if ( _pcps_access_is_unsafe( _pddev ) ) \
      goto err_busy_unsafe;                 \
                                            \
    _pcps_sem_inc( _pddev );                \
    (_pddev)->irp = pIrp

  // If a function which is exported by our kernel driver
  // is called from a different kernel driver then there is
  // no IRP, so we provide a different, Windows-only macro
  // which is used by those export functions and sets the
  // IRP pointer of the device structure to NULL.
  #define _pcps_sem_inc_safe_no_irp( _pddev ) \
    if ( _pcps_access_is_unsafe( _pddev ) )   \
      goto err_busy_unsafe;                   \
                                              \
    _pcps_sem_inc( _pddev );                  \
    (_pddev)->irp = NULL

#else

  // Other OSs don't use an IRP, so no IRP pointer
  // needs to be set up.
  #define _pcps_sem_inc_safe( _pddev )      \
    if ( _pcps_access_is_unsafe( _pddev ) ) \
      goto err_busy_unsafe;                 \
                                            \
    _pcps_sem_inc( _pddev );                \

#endif




// Check a condition and go to an error handler
// if the condition is not true.
#define _io_chk_cond( _cond )  \
  if ( !(_cond) )              \
    goto err_support;



// Read a data structure from a device.
// Check the return code and if no error occurred,
// copy the data to the caller's memory space.
#define _io_read_var( _pddev, _cmd, _fld, _pout )  \
{                                                  \
  _pcps_sem_inc_safe( _pddev );                    \
  rc = _pcps_read_var( _pddev, _cmd, iob._fld );   \
  _pcps_sem_dec( _pddev );                         \
                                                   \
  if ( rc != MBG_SUCCESS )                         \
    goto err_access;                               \
                                                   \
  _iob_to_pout_var( iob._fld, _pout );             \
}


// Retrieve a data structure from the caller's
// memory space, write it to the device and
// check the return code.
#define _io_write_var( _pddev, _cmd, _fld, _pin )  \
{                                                  \
  _iob_from_pin_var( iob._fld, _pin );             \
                                                   \
  _pcps_sem_inc_safe( _pddev );                    \
  rc = _pcps_write_var( _pddev, _cmd, iob._fld );  \
  _pcps_sem_dec( _pddev );                         \
                                                   \
  if ( rc != MBG_SUCCESS )                         \
    goto err_access;                               \
}


// Write a command byte to the device and
// check the return code.
#define _io_write_cmd( _pddev, _cmd )              \
{                                                  \
  _pcps_sem_inc_safe( _pddev );                    \
  rc = _pcps_write_byte( _pddev, _cmd );           \
  _pcps_sem_dec( _pddev );                         \
                                                   \
  if ( rc != MBG_SUCCESS )                         \
    goto err_access;                               \
}


// Check if a device supports large (GPS) data structures.
// If it does, read GPS data of given size from the device.
// Check the return code and if no error occurred,
// copy the data to the caller's memory space.
#define _io_read_gps( _pddev, _cmd, _fld, _pout, _size )               \
{                                                                      \
  _io_chk_cond( _pcps_ddev_has_gps_data( _pddev ) );                   \
                                                                       \
  _pcps_sem_inc_safe( _pddev );                                        \
  rc = pcps_read_gps( _pddev, _cmd, (uchar FAR *) &iob._fld, _size );  \
  _pcps_sem_dec( _pddev );                                             \
                                                                       \
  if ( rc != MBG_SUCCESS )                                             \
    goto err_access;                                                   \
                                                                       \
  _iob_to_pout( &iob._fld, _pout, _size );                             \
}


// Check if a device supports large (GPS) data structures.
// If it does, read a GPS data structure from the device.
// Check the return code and if no error occurred,
// copy the data to the caller's memory space.
#define _io_read_gps_var( _pddev, _cmd, _fld, _pout )  \
{                                                      \
  _io_chk_cond( _pcps_ddev_has_gps_data( _pddev ) );   \
                                                       \
  _pcps_sem_inc_safe( _pddev );                        \
  rc = _pcps_read_gps_var( _pddev, _cmd, iob._fld );   \
  _pcps_sem_dec( _pddev );                             \
                                                       \
  if ( rc != MBG_SUCCESS )                             \
    goto err_access;                                   \
                                                       \
  _iob_to_pout_var( iob._fld, _pout );                 \
}


// Check if a device supports large (GPS) data structures.
// If it does, retrieve a data structure from the caller's
// memory space, write it to the device and check
// the return code.
#define _io_write_gps_var( _pddev, _cmd, _fld, _pin )  \
{                                                      \
  _io_chk_cond( _pcps_ddev_has_gps_data( _pddev ) );   \
                                                       \
  _iob_from_pin_var( iob._fld, _pin );                 \
                                                       \
  _pcps_sem_inc_safe( _pddev );                        \
  rc = _pcps_write_gps_var( _pddev, _cmd, iob._fld );  \
  _pcps_sem_dec( _pddev );                             \
                                                       \
  if ( rc != MBG_SUCCESS )                             \
    goto err_access;                                   \
}



// The macros below are similar to those defined above except
// that they check if a condition is true before they really
// do anything. This is used for IOCTL calls which may not
// be supported by every device.
#define _io_read_var_chk( _pddev, _cmd, _fld, _pout, _cond )  \
{                                                             \
  _io_chk_cond( _cond );                                      \
  _io_read_var( _pddev, _cmd, _fld, _pout );                  \
}

#define _io_write_var_chk( _pddev, _cmd, _fld, _pin, _cond )  \
{                                                             \
  _io_chk_cond( _cond );                                      \
  _io_write_var( _pddev, _cmd, _fld, _pin );                  \
}

#define _io_write_cmd_chk( _pddev, _cmd, _cond )  \
{                                                 \
  _io_chk_cond( _cond );                          \
  _io_write_cmd( _pddev, _cmd );                  \
}

#define _io_read_gps_chk( _pddev, _cmd, _fld, _pout, _size, _cond )  \
{                                                                    \
  _io_chk_cond( _cond );                                             \
  _io_read_gps( _pddev, _cmd, _fld, _pout, _size );                  \
}

#define _io_read_gps_var_chk( _pddev, _cmd, _fld, _pout, _cond )  \
{                                                                 \
  _io_chk_cond( _cond );                                          \
  _io_read_gps_var( _pddev, _cmd, _fld, _pout );                  \
}

#define _io_write_gps_var_chk( _pddev, _cmd, _fld, _pin, _cond )  \
{                                                                 \
  _io_chk_cond( _cond );                                          \
  _io_write_gps_var( _pddev, _cmd, _fld, _pin );                  \
}


#define _report_cond( _cond, _pout )  \
{                                     \
  iob.i = _cond;                      \
  _iob_to_pout_var( iob.i, _pout );   \
}



#define _mbg_dbg_set_bit( _d, _v )                          \
{                                                           \
  mbg_dbg_data |= (_v);                                     \
  _mbg_outp8( (_d), 0, mbg_dbg_port_mapped, mbg_dbg_data ); \
}

#define _mbg_dbg_clr_bit( _d, _v )                          \
{                                                           \
  mbg_dbg_data &= ~(_v);                                    \
  _mbg_outp8( (_d), 0, mbg_dbg_port_mapped, mbg_dbg_data ); \
}

#define _mbg_dbg_clr_all( _d )                              \
{                                                           \
  mbg_dbg_data = 0;                                         \
  _mbg_outp8( (_d), 0, mbg_dbg_port_mapped, mbg_dbg_data ); \
}



#define TEST_MM_ACCESS_TIME  ( 0 && defined( MBG_TGT_LINUX ) )
#define TEST_MM_ACCESS_64    0
#define TEST_FRAC_ONLY       0

#if TEST_MM_ACCESS_TIME
  #include <pcpsutil.h>
#endif


typedef union
{
  PCPS_STATUS_PORT pcps_status_port;
  PCPS_TIME pcps_time;
  PCPS_STIME pcps_stime;
  PCPS_HR_TIME pcps_hr_time;
  PCPS_TIME_STAMP pcps_time_stamp;
  PCPS_SERIAL pcps_serial;
  PCPS_TZCODE pcps_tzcode;
  PCPS_TZDL pcps_tzdl;
  MBG_REF_OFFS mbg_ref_offs;
  MBG_OPT_INFO mbg_opt_info;
  MBG_OPT_SETTINGS mbg_opt_settings;
  IRIG_INFO irig_info;
  IRIG_SETTINGS irig_settings;
  PCPS_UCAP_ENTRIES pcps_ucap_entries;
  TZDL tzdl;
  SW_REV sw_rev;
  BVAR_STAT bvar_stat;
  TTM ttm;
  PORT_PARM port_parm;
  ANT_INFO ant_info;
  ENABLE_FLAGS enable_flags;
  STAT_INFO stat_info;
  RECEIVER_INFO receiver_info;
  GPS_CMD gps_cmd;
  IDENT ident;
  POS pos;
  XYZs xyzs;
  LLAs llas;
  ANT_CABLE_LEN ant_cable_len;
  PORT_SETTINGS_IDX port_settings_idx;
  SYNTH synth;
  SYNTH_STATE synth_state;
  ALL_POUT_INFO all_pout_info;
  POUT_SETTINGS_IDX pout_settings_idx;
  ALL_STR_TYPE_INFO all_str_type_info;
  ALL_PORT_INFO all_port_info;
  ALL_PTP_UC_MASTER_INFO all_ptp_uc_master_info;
  MBG_TIME_SCALE_INFO mbg_time_scale_info;
  MBG_TIME_SCALE_SETTINGS mbg_time_scale_settings;
  UTC utc;
  MBG_IRIG_CTRL_BITS mbg_irig_ctrl_bits;
  LAN_IF_INFO lan_if_info;
  IP4_SETTINGS ip4_settings;
  PTP_STATE ptp_state;
  PTP_CFG_INFO ptp_cfg_info;
  PTP_CFG_SETTINGS ptp_cfg_settings;
  PCPS_IRIG_TIME pcps_irig_time;
  MBG_RAW_IRIG_DATA mbg_raw_irig_data;
  PTP_UC_MASTER_CFG_LIMITS ptp_uc_master_cfg_limits;
  PTP_UC_MASTER_SETTINGS_IDX ptp_uc_master_settings_idx;
  PCPS_TIME_CYCLES pcps_time_cycles;
  PCPS_HR_TIME_CYCLES pcps_hr_time_cycles;
  MBG_DBG_PORT mbg_dbg_port;
  MBG_DBG_DATA mbg_dbg_data;
  MBG_PC_CYCLES_FREQUENCY mbg_pc_cycles_frequency;
  PCPS_TIME_STAMP_CYCLES pcps_time_stamp_cycles;
  MBG_TIME_INFO_HRT mbg_time_info_hrt;
  MBG_TIME_INFO_TSTAMP mbg_time_info_tstamp;
  CORR_INFO corr_info;
  TR_DISTANCE tr_distance;
  MBG_DEBUG_STATUS debug_status;
  MBG_NUM_EVT_LOG_ENTRIES num_evt_log_entries;
  MBG_EVT_LOG_ENTRY evt_log_entry;

  PCPS_MAPPED_MEM mapped_mem;

  #if USE_IOCTL_GENERIC_REQ
    IOCTL_GENERIC_REQ req;
  #else
    IOCTL_GENERIC_CTL ctl;
  #endif

  int i;

} IOCTL_BUFFER;



#if defined( __GNUC__ )
// Avoid "no previous prototype" with some gcc versions.
static __mbg_inline
void swap_tstamp( PCPS_TIME_STAMP *p_ts ) __attribute__((always_inline));
#endif

static __mbg_inline
void swap_tstamp( PCPS_TIME_STAMP *p_ts )
{
  uint32_t tmp = p_ts->sec;
  p_ts->sec = p_ts->frac;
  p_ts->frac = tmp;

}  // swap_tstamp



#if defined( __GNUC__ )
// Avoid "no previous prototype" with some gcc versions.
static __mbg_inline
void do_get_fast_hr_timestamp_safe( PCPS_DDEV *pddev, PCPS_TIME_STAMP *p_ts ) __attribute__((always_inline));
#endif


static __mbg_inline
void do_get_fast_hr_timestamp_safe( PCPS_DDEV *pddev, PCPS_TIME_STAMP *p_ts )
{
#if TEST_MM_ACCESS_64
  volatile uint64_t *p = (volatile uint64_t *) pddev->mm_tstamp_addr;
#else
  volatile uint32_t *p = (volatile uint32_t *) pddev->mm_tstamp_addr;
#endif

#if TEST_MM_ACCESS_TIME
  PCPS_TIME_STAMP tmp;
  MBG_PC_CYCLES cyc_1;
  MBG_PC_CYCLES cyc_2;
  MBG_PC_CYCLES cyc_3;
  long delta_frac;
  unsigned delta_ns;
#endif

#if TEST_MM_ACCESS_TIME
  mbg_get_pc_cycles( &cyc_1 );
#endif

  _mbg_spin_lock_acquire( &pddev->mm_lock );

#if TEST_MM_ACCESS_64
  *( (volatile uint64_t *) p_ts ) = *p;
#else
  p_ts->frac = _mbg32_to_cpu( *p );
  #if !TEST_FRAC_ONLY
    p_ts->sec = _mbg32_to_cpu( *( p + 1 ) );
  #endif
#endif

#if TEST_MM_ACCESS_TIME
  #if TEST_MM_ACCESS_64
    *( (volatile uint64_t *) &tmp ) = *p;
  #else
    tmp.frac = _mbg32_to_cpu( *p );
    #if !TEST_FRAC_ONLY
      tmp.sec = _mbg32_to_cpu( *( p + 1 ) );
    #endif
  #endif
#endif

  _mbg_spin_lock_release( &pddev->mm_lock );

#if TEST_FRAC_ONLY
  p_ts->sec = 0;
  #if TEST_MM_ACCESS_TIME
    tmp.sec = 0;
  #endif
#endif

#if TEST_MM_ACCESS_64
  swap_tstamp( p_ts );
  #if TEST_MM_ACCESS_TIME
    swap_tstamp( &tmp );
  #endif
#endif


#if TEST_MM_ACCESS_TIME
  mbg_get_pc_cycles( &cyc_2 );
  mbg_get_pc_cycles( &cyc_3 );
#endif

#if TEST_MM_ACCESS_TIME
  delta_frac = (long) ( tmp.frac - p_ts->frac );
  delta_ns = (unsigned) frac_sec_from_bin( delta_frac, 1000000000UL );

  printk( KERN_INFO "MM tstamp dev %04X: %li/%li cyc (%lu kHz)"
          " %08lX.%08lX->%08lX.%08lX: %li (%u.%03u us)"
          "\n",
          _pcps_ddev_dev_id( pddev ),
         (long) ( cyc_2 - cyc_1 ),
         (long) ( cyc_3 - cyc_2 ),
         (ulong) cpu_khz,
         (ulong) p_ts->sec, (ulong) p_ts->frac,
         (ulong) tmp.sec, (ulong) tmp.frac,
         (long) ( tmp.frac - p_ts->frac ),
         delta_ns / 1000,
         delta_ns % 1000
        );
#endif

}  // do_get_fast_hr_timestamp_safe



#if defined( __GNUC__ )
// Avoid "no previous prototype" with some gcc versions.
static __mbg_inline
void do_get_fast_hr_timestamp_cycles_safe( PCPS_DDEV *pddev, PCPS_TIME_STAMP_CYCLES *p_ts_cyc ) __attribute__((always_inline));
#endif

static __mbg_inline
void do_get_fast_hr_timestamp_cycles_safe( PCPS_DDEV *pddev, PCPS_TIME_STAMP_CYCLES *p_ts_cyc )
{
  volatile uint32_t *p = (volatile uint32_t *) pddev->mm_tstamp_addr;

  _mbg_spin_lock_acquire( &pddev->mm_lock );
  mbg_get_pc_cycles( &p_ts_cyc->cycles );
  p_ts_cyc->tstamp.frac = _mbg32_to_cpu( *p++ );
  p_ts_cyc->tstamp.sec  = _mbg32_to_cpu( *p );
  _mbg_spin_lock_release( &pddev->mm_lock );

}  // do_get_fast_hr_timestamp_cycles_safe


#if defined( __GNUC__ )
// Avoid "no previous prototype" with some gcc versions.
static __mbg_inline
int ioctl_switch( PCPS_DDEV *pddev, unsigned int ioctl_code,
                  #if defined( MBG_TGT_WIN32 )
                    IRP *pIrp, int *ret_size, uint16_t pout_size,
                  #endif
                  void *pin, void *pout ) __attribute__((always_inline));
#endif

/**
 * @brief Decode an handle IOCTL commands.
 *
 * This function is called from the OS dependent IOCTL handlers.
 *
 * @param pddev       Pointer to the device structure
 * @param ioctl_code  The IOCTL code to be handled
#if defined( MBG_TGT_WIN32 )
 * @param pIrp        The IRP associated to the IOCTL call
 * @param ret_size    The number of bytes to be returned
 * @param pout_size   The size of the output buffer
#endif
 * @param pin         The input buffer
 * @param pout        The output buffer
 *
 * @return MBG_SUCCESS or one of the Meinberg error codes which need to be translated
 *         by the calling function to the OS dependent error code.
 * @return -1 for unknown IOCTL codes
 */
static __mbg_inline
int ioctl_switch( PCPS_DDEV *pddev, unsigned int ioctl_code,
                  #if defined( MBG_TGT_WIN32 )
                    IRP *pIrp, int *ret_size, uint16_t pout_size,
                  #endif
                  void *pin, void *pout )
{
  #if USE_DEBUG_PORT
    MBG_PC_CYCLES cyc;
  #endif
  IOCTL_BUFFER iob;
  #if USE_IOCTL_GENERIC_REQ
    void *p_buff_in;
    void *p_buff_out;
  #else
    IOCTL_GENERIC_BUFFER *p_buff;
    int buffer_size;
  #endif
  uint8_t pcps_cmd;
  int rc = MBG_SUCCESS;

  // To provide best maintainability the sequence of cases here should match
  // the sequence in ioctl_get_required_privilege(), which also makes sure
  // commands requiring lowest latency are handled first.

  switch ( ioctl_code )
  {
    // Commands requiring lowest latency

    case IOCTL_GET_FAST_HR_TIMESTAMP:
      _io_chk_cond( _pcps_ddev_has_fast_hr_timestamp( pddev ) );
      do_get_fast_hr_timestamp_safe( pddev, &iob.pcps_time_stamp );
      _iob_to_pout_var( iob.pcps_time_stamp, pout );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_GET_PCPS_HR_TIME:
      _io_read_var_chk( pddev, PCPS_GIVE_HR_TIME, pcps_hr_time, pout,
                        _pcps_ddev_has_hr_time( pddev ) );
      break;


    case IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES:
      _io_chk_cond( _pcps_ddev_has_fast_hr_timestamp( pddev ) );
      do_get_fast_hr_timestamp_cycles_safe( pddev, &iob.pcps_time_stamp_cycles );
      _iob_to_pout_var( iob.pcps_time_stamp_cycles, pout );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_GET_PCPS_HR_TIME_CYCLES:
      _pcps_sem_inc_safe( pddev );
      rc = _pcps_read_var( pddev, PCPS_GIVE_HR_TIME, iob.pcps_hr_time_cycles.t );
      iob.pcps_hr_time_cycles.cycles = pddev->acc_cycles;
      _pcps_sem_dec( pddev );

      if ( rc != MBG_SUCCESS )
        goto err_access;

      _iob_to_pout_var( iob.pcps_hr_time_cycles, pout );
      break;


    case IOCTL_GET_PCPS_UCAP_EVENT:
      _io_read_var_chk( pddev, PCPS_GIVE_UCAP_EVENT, pcps_hr_time,
                        pout, _pcps_ddev_has_ucap( pddev ) );
      break;


    // Other low latency commands

    case IOCTL_GET_PCPS_TIME:
      _io_read_var( pddev, PCPS_GIVE_TIME_NOCLEAR, pcps_time, pout );
      break;


    case IOCTL_GET_PCPS_TIME_CYCLES:
      _pcps_sem_inc_safe( pddev );
      rc = _pcps_read_var( pddev, PCPS_GIVE_TIME_NOCLEAR, iob.pcps_time_cycles.t );
      if ( _pcps_ddev_is_usb( pddev ) )
        iob.pcps_time_cycles.cycles = pddev->acc_cycles;
      else
        mbg_get_pc_cycles( &iob.pcps_time_cycles.cycles );
      _pcps_sem_dec( pddev );

      if ( rc != MBG_SUCCESS )
        goto err_access;

      _iob_to_pout_var( iob.pcps_time_cycles, pout );
      break;


  #if !defined( OMIT_STATUS_PORT )
    case IOCTL_GET_PCPS_STATUS_PORT:
      if ( _pcps_ddev_is_usb( pddev ) )
      {
        _io_read_var( pddev, PCPS_GET_STATUS_PORT, pcps_status_port, pout );
      }
      else
      {
        iob.pcps_status_port = _pcps_ddev_read_status_port( pddev );
        _iob_to_pout_var( iob.pcps_status_port, pout );
      }
      break;
  #endif


    case IOCTL_GET_PCPS_TIME_SEC_CHANGE:
      _io_wait_pcps_sec_change( pddev, PCPS_GIVE_TIME, PCPS_TIME, pout );
      break;


    case IOCTL_GET_GPS_TIME:
      _io_read_gps_var( pddev, PC_GPS_TIME, ttm, pout );
      break;


    case IOCTL_GET_GPS_UCAP:
      _io_read_gps_var( pddev, PC_GPS_UCAP, ttm, pout );
      break;


    case IOCTL_GET_TIME_INFO_HRT:
      _io_chk_cond( _pcps_ddev_has_hr_time( pddev ) );

      mbg_get_pc_cycles( &iob.mbg_time_info_hrt.sys_time_cycles.cyc_before );
      mbg_get_sys_time( &iob.mbg_time_info_hrt.sys_time_cycles.sys_time );
      mbg_get_pc_cycles( &iob.mbg_time_info_hrt.sys_time_cycles.cyc_after );

      _pcps_sem_inc_safe( pddev );
      rc = _pcps_read_var( pddev, PCPS_GIVE_HR_TIME, iob.mbg_time_info_hrt.ref_hr_time_cycles.t );
      iob.mbg_time_info_hrt.ref_hr_time_cycles.cycles = pddev->acc_cycles;
      _pcps_sem_dec( pddev );

      if ( rc != MBG_SUCCESS )
        goto err_access;

      _iob_to_pout_var( iob.mbg_time_info_hrt, pout );
      break;


    case IOCTL_GET_TIME_INFO_TSTAMP:
      _io_chk_cond( _pcps_ddev_has_fast_hr_timestamp( pddev ) );

      mbg_get_pc_cycles( &iob.mbg_time_info_tstamp.sys_time_cycles.cyc_before );
      mbg_get_sys_time( &iob.mbg_time_info_tstamp.sys_time_cycles.sys_time );
      mbg_get_pc_cycles( &iob.mbg_time_info_tstamp.sys_time_cycles.cyc_after );

      do_get_fast_hr_timestamp_cycles_safe( pddev, &iob.mbg_time_info_tstamp.ref_tstamp_cycles );
      rc = MBG_SUCCESS;

      _iob_to_pout_var( iob.mbg_time_info_tstamp, pout );
      break;


    // Commands returning public status information

    case IOCTL_GET_PCPS_DRVR_INFO:
      _iob_to_pout_var( drvr_info, pout );
      break;


    case IOCTL_GET_PCPS_DEV:
      _iob_to_pout_var( pddev->dev, pout );
      break;


    case IOCTL_GET_PCPS_SYNC_TIME:
      _io_read_var_chk( pddev, PCPS_GIVE_SYNC_TIME, pcps_time,
                        pout, _pcps_ddev_has_sync_time( pddev ) );
      break;


    case IOCTL_GET_GPS_SW_REV:
      _io_read_gps_var( pddev, PC_GPS_SW_REV, sw_rev, pout );
      break;


    case IOCTL_GET_GPS_BVAR_STAT:
      _io_read_gps_var( pddev, PC_GPS_BVAR_STAT, bvar_stat, pout );
      break;


    case IOCTL_GET_GPS_ANT_INFO:
      _io_read_gps_var( pddev, PC_GPS_ANT_INFO, ant_info, pout );
      break;


    case IOCTL_GET_GPS_STAT_INFO:
      _io_read_gps_var( pddev, PC_GPS_STAT_INFO, stat_info, pout );
      break;


    case IOCTL_GET_GPS_IDENT:
      _io_read_gps_var( pddev, PC_GPS_IDENT, ident, pout );
      break;


    case IOCTL_GET_GPS_RECEIVER_INFO:
      // Always read the receiver info directly from the device. Never
      // just return a previous copy which has been read earlier since
      // something may just have been changed by a configuration API call.
      _io_read_gps_var_chk( pddev, PC_GPS_RECEIVER_INFO,
                            receiver_info, pout,
                            _pcps_ddev_has_receiver_info( pddev ) );
      break;


    case IOCTL_GET_PCI_ASIC_VERSION:
      _io_chk_cond( _pcps_ddev_has_asic_version( pddev ) );
      _iob_to_pout_var( pddev->raw_asic_version, pout );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_GET_SYNTH_STATE:
      _io_read_var_chk( pddev, PCPS_GET_SYNTH_STATE, synth_state,
                        pout, _pcps_ddev_has_synth( pddev ) );
      break;


    case IOCTL_GET_PCPS_UCAP_ENTRIES:
      _io_read_var_chk( pddev, PCPS_GIVE_UCAP_ENTRIES, pcps_ucap_entries,
                        pout, _pcps_ddev_has_ucap( pddev ) );
      break;


    case IOCTL_GET_PCI_ASIC_FEATURES:
      _io_chk_cond( _pcps_ddev_has_asic_features( pddev ) );
      _iob_to_pout_var( pddev->asic_features, pout );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_GET_IRQ_STAT_INFO:
      _iob_to_pout_var( pddev->irq_stat_info, pout );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_GET_CYCLES_FREQUENCY:
      mbg_get_pc_cycles_frequency( &iob.mbg_pc_cycles_frequency );
      _iob_to_pout_var( iob.mbg_pc_cycles_frequency, pout );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_GET_IRIG_CTRL_BITS:
      _io_read_var_chk( pddev, PCPS_GET_IRIG_CTRL_BITS, mbg_irig_ctrl_bits,
                        pout, _pcps_ddev_has_irig_ctrl_bits( pddev ) );
      break;


    case IOCTL_GET_IP4_STATE:
      _io_read_gps_var_chk( pddev, PC_GPS_IP4_STATE, ip4_settings,
                            pout, _pcps_ddev_has_lan_intf( pddev ) );
      break;


    case IOCTL_GET_PTP_STATE:
      _io_read_gps_var_chk( pddev, PC_GPS_PTP_STATE, ptp_state,
                            pout, _pcps_ddev_has_ptp( pddev ) );
      break;


    case IOCTL_GET_CORR_INFO:
      _io_read_var_chk( pddev, PCPS_GET_CORR_INFO, corr_info,
                        pout, _pcps_ddev_has_corr_info( pddev ) );
      break;


    case IOCTL_GET_DEBUG_STATUS:
      _io_read_var_chk( pddev, PCPS_GET_DEBUG_STATUS, debug_status,
                        pout, _pcps_ddev_has_debug_status( pddev ) );
      break;


    case IOCTL_GET_NUM_EVT_LOG_ENTRIES:
      _io_read_var_chk( pddev, PCPS_NUM_EVT_LOG_ENTRIES, num_evt_log_entries,
                        pout, _pcps_ddev_has_evt_log( pddev ) );
      break;


    case IOCTL_GET_FIRST_EVT_LOG_ENTRY:
      _io_read_var_chk( pddev, PCPS_FIRST_EVT_LOG_ENTRY, evt_log_entry,
                        pout, _pcps_ddev_has_evt_log( pddev ) );
      break;


    case IOCTL_GET_NEXT_EVT_LOG_ENTRY:
      _io_read_var_chk( pddev, PCPS_NEXT_EVT_LOG_ENTRY, evt_log_entry,
                        pout, _pcps_ddev_has_evt_log( pddev ) );
      break;


    // Commands returning device capabilities and features

    case IOCTL_DEV_IS_GPS:
      _report_cond( _pcps_ddev_is_gps( pddev ), pout );
      break;


    case IOCTL_DEV_IS_DCF:
      _report_cond( _pcps_ddev_is_dcf( pddev ), pout );
      break;


    case IOCTL_DEV_IS_MSF:
      _report_cond( _pcps_ddev_is_msf( pddev ), pout );
      break;


    case IOCTL_DEV_IS_WWVB:
      _report_cond( _pcps_ddev_is_wwvb( pddev ), pout );
      break;


    case IOCTL_DEV_IS_LWR:
      _report_cond( _pcps_ddev_is_lwr( pddev ), pout );
      break;


    case IOCTL_DEV_IS_IRIG_RX:
      _report_cond( _pcps_ddev_is_irig_rx( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_HR_TIME:
      _report_cond( _pcps_ddev_has_hr_time( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_CAB_LEN:
      _report_cond( _pcps_ddev_has_cab_len( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_TZDL:
      _report_cond( _pcps_ddev_has_tzdl( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_PCPS_TZDL:
      _report_cond( _pcps_ddev_has_pcps_tzdl( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_TZCODE:
      _report_cond( _pcps_ddev_has_tzcode( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_TZ:
      _report_cond( _pcps_ddev_has_tz( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_EVENT_TIME:
      _report_cond( _pcps_ddev_has_event_time( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_RECEIVER_INFO:
      _report_cond( _pcps_ddev_has_receiver_info( pddev ), pout );
      break;


    case IOCTL_DEV_CAN_CLR_UCAP_BUFF:
      _report_cond( _pcps_ddev_can_clr_ucap_buff( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_UCAP:
      _report_cond( _pcps_ddev_has_ucap( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_IRIG_TX:
      _report_cond( _pcps_ddev_has_irig_tx( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_SERIAL_HS:
      _report_cond( _pcps_ddev_has_serial_hs( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_SIGNAL:
      _report_cond( _pcps_ddev_has_signal( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_MOD:
      _report_cond( _pcps_ddev_has_mod( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_IRIG:
      _report_cond( _pcps_ddev_has_irig( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_REF_OFFS:
      _report_cond( _pcps_ddev_has_ref_offs( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_OPT_FLAGS:
      _report_cond( _pcps_ddev_has_opt_flags( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_GPS_DATA:
      _report_cond( _pcps_ddev_has_gps_data( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_SYNTH:
      _report_cond( _pcps_ddev_has_synth( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_GENERIC_IO:
      _report_cond( _pcps_ddev_has_generic_io( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_PCI_ASIC_FEATURES:
      _report_cond( _pcps_ddev_has_asic_features( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_PCI_ASIC_VERSION:
      _report_cond( _pcps_ddev_has_asic_version( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_FAST_HR_TIMESTAMP:
      _report_cond( _pcps_ddev_has_fast_hr_timestamp( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_GPS_TIME_SCALE:
      _report_cond( _pcps_ddev_has_time_scale( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_GPS_UTC_PARM:
      _report_cond( _pcps_ddev_has_utc_parm( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_IRIG_CTRL_BITS:
      _report_cond( _pcps_ddev_has_irig_ctrl_bits( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_LAN_INTF:
      _report_cond( _pcps_ddev_has_lan_intf( pddev ), pout );
      break;


    case IOCTL_DEV_IS_PTP:
      _report_cond( _pcps_ddev_is_ptp( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_PTP:
      _report_cond( _pcps_ddev_has_ptp( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_IRIG_TIME:
      _report_cond( _pcps_ddev_has_irig_time( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_RAW_IRIG_DATA:
      _report_cond( _pcps_ddev_has_raw_irig_data( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_PTP_UNICAST:
      _report_cond( _pcps_ddev_has_ptp_unicast( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_PZF:
      _report_cond( _pcps_ddev_has_pzf( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_CORR_INFO:
      _report_cond( _pcps_ddev_has_corr_info( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_TR_DISTANCE:
      _report_cond( _pcps_ddev_has_tr_distance( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_DEBUG_STATUS:
      _report_cond( _pcps_ddev_has_debug_status( pddev ), pout );
      break;


    case IOCTL_DEV_HAS_EVT_LOG:
      _report_cond( _pcps_ddev_has_evt_log( pddev ), pout );
      break;


    // The next codes are somewhat special since they change something
    // on the board but do not affect basic operation

    case IOCTL_PCPS_CLR_UCAP_BUFF:
      _io_write_cmd_chk( pddev, PCPS_CLR_UCAP_BUFF,
                         _pcps_ddev_can_clr_ucap_buff( pddev ) );
      break;


    case IOCTL_SET_PCPS_EVENT_TIME:
      _io_write_var_chk( pddev, PCPS_SET_EVENT_TIME,
                           pcps_time_stamp, pin,
                           _pcps_ddev_has_event_time( pddev ) );
      break;


    case IOCTL_CLR_EVT_LOG:
      _io_write_cmd_chk( pddev, PCPS_CLR_EVT_LOG, _pcps_ddev_has_evt_log( pddev ) );
      break;


    // Status information which may not be available for everybody

    case IOCTL_GET_GPS_POS:
      _io_read_gps_var( pddev, PC_GPS_POS, pos, pout );
      break;


    // Codes reading device configuration

    case IOCTL_GET_PCPS_SERIAL:
      _io_read_var( pddev, PCPS_GET_SERIAL, pcps_serial, pout );
      break;


    case IOCTL_GET_PCPS_TZCODE:
      _io_read_var_chk( pddev, PCPS_GET_TZCODE, pcps_tzcode, pout,
                        _pcps_ddev_has_tzcode( pddev ) );
      break;


    case IOCTL_GET_PCPS_TZDL:
      _io_read_var_chk( pddev, PCPS_GET_PCPS_TZDL, pcps_tzdl, pout,
                        _pcps_ddev_has_pcps_tzdl( pddev ) );
      break;


    case IOCTL_GET_REF_OFFS:
      _io_read_var_chk( pddev, PCPS_GET_REF_OFFS, mbg_ref_offs, pout,
                        _pcps_ddev_has_ref_offs( pddev ) );
      break;


    case IOCTL_GET_MBG_OPT_INFO:
      _io_read_var_chk( pddev, PCPS_GET_OPT_INFO, mbg_opt_info, pout,
                        _pcps_ddev_has_opt_flags( pddev ) );
      break;


    case IOCTL_GET_PCPS_IRIG_RX_INFO:
      _io_read_var_chk( pddev, PCPS_GET_IRIG_RX_INFO, irig_info, pout,
                        _pcps_ddev_is_irig_rx( pddev ) );
      break;


    case IOCTL_GET_GPS_TZDL:
      _io_read_gps_var( pddev, PC_GPS_TZDL, tzdl, pout );
      break;


    case IOCTL_GET_GPS_PORT_PARM:
      _io_read_gps_var( pddev, PC_GPS_PORT_PARM, port_parm, pout );
      break;


    case IOCTL_GET_GPS_ENABLE_FLAGS:
      _io_read_gps_var( pddev, PC_GPS_ENABLE_FLAGS, enable_flags, pout );
      break;


    case IOCTL_GET_GPS_ANT_CABLE_LEN:
      _io_read_gps_var_chk( pddev, PC_GPS_ANT_CABLE_LEN, ant_cable_len, pout,
                            _pcps_ddev_has_cab_len( pddev ) );
      break;


    case IOCTL_GET_PCPS_IRIG_TX_INFO:
      /* This is a workaround for GPS169PCIs with early */
      /* firmware versions. See RCS log for details. */
      pcps_cmd = PCPS_GET_IRIG_TX_INFO;

      if ( _pcps_ddev_requires_irig_workaround( pddev ) )
      {
        pcps_cmd = PCPS_GET_IRIG_RX_INFO;
        _mbgddmsg_1( MBG_DBG_INFO, "%s: workaround for GPS169PCI \"get IRIG TX cfg\"",
                     pcps_driver_name );
      }

      _io_read_var_chk( pddev, pcps_cmd, irig_info, pout,
                        _pcps_ddev_has_irig_tx( pddev ) );
      break;


    case IOCTL_GET_SYNTH:
      _io_read_var_chk( pddev, PCPS_GET_SYNTH, synth, pout,
                        _pcps_ddev_has_synth( pddev ) );
      break;


    case IOCTL_GET_GPS_TIME_SCALE_INFO:
      _io_read_gps_var_chk( pddev, PC_GPS_TIME_SCALE, mbg_time_scale_info,
                            pout, _pcps_ddev_has_time_scale( pddev ) );
      break;


    case IOCTL_GET_GPS_UTC_PARM:
      _io_read_gps_var_chk( pddev, PC_GPS_UTC, utc, pout,
                            _pcps_ddev_has_utc_parm( pddev ) );
      break;


    case IOCTL_GET_LAN_IF_INFO:
      _io_read_gps_var_chk( pddev, PC_GPS_LAN_IF_INFO, lan_if_info,
                            pout, _pcps_ddev_has_lan_intf( pddev ) );
      break;


    case IOCTL_GET_IP4_SETTINGS:
      _io_read_gps_var_chk( pddev, PC_GPS_IP4_SETTINGS, ip4_settings,
                            pout, _pcps_ddev_has_lan_intf( pddev ) );
      break;


    case IOCTL_GET_PTP_CFG_INFO:
      _io_read_gps_var_chk( pddev, PC_GPS_PTP_CFG, ptp_cfg_info,
                            pout, _pcps_ddev_has_ptp( pddev ) );
      break;


    case IOCTL_GET_IRIG_TIME:
      _io_read_var_chk( pddev, PCPS_GIVE_IRIG_TIME, pcps_irig_time,
                        pout, _pcps_ddev_has_irig_time( pddev ) );
      break;


    case IOCTL_GET_RAW_IRIG_DATA:
      _io_read_var_chk( pddev, PCPS_GET_RAW_IRIG_DATA, mbg_raw_irig_data,
                        pout, _pcps_ddev_has_raw_irig_data( pddev ) );
      break;


    case IOCTL_PTP_UC_MASTER_CFG_LIMITS:
      _io_read_gps_var_chk( pddev, PC_GPS_PTP_UC_MASTER_CFG_LIMITS, ptp_uc_master_cfg_limits,
                            pout, _pcps_ddev_has_ptp_unicast( pddev ) );
      break;


    case IOCTL_GET_TR_DISTANCE:
      _io_read_var_chk( pddev, PCPS_GET_TR_DISTANCE, tr_distance,
                        pout, _pcps_ddev_has_tr_distance( pddev ) );
      break;


  #if _MBG_SUPP_VAR_ACC_SIZE

    // These codes are only supported on target systems where a variable size of
    // the IOCTL buffer can be specified in the IOCTL call. On other systems the
    // generic IOCTL functions are used instead.

    case IOCTL_GET_GPS_ALL_STR_TYPE_INFO:
      _io_read_gps_chk( pddev, PC_GPS_ALL_STR_TYPE_INFO, all_str_type_info, pout,
                        pout_size, _pcps_ddev_has_receiver_info( pddev ) );
      break;


    case IOCTL_GET_GPS_ALL_PORT_INFO:
      _io_read_gps_chk( pddev, PC_GPS_ALL_PORT_INFO, all_port_info, pout,
                        pout_size, _pcps_ddev_has_receiver_info( pddev ) );
      break;


    case IOCTL_GET_GPS_ALL_POUT_INFO:
      _io_read_gps_chk( pddev, PC_GPS_ALL_POUT_INFO, all_pout_info, pout,
                        pout_size, _pcps_ddev_has_receiver_info( pddev ) );
      break;


    case IOCTL_GET_ALL_PTP_UC_MASTER_INFO:
      _io_read_gps_chk( pddev, PC_GPS_ALL_PTP_UC_MASTER_INFO, all_ptp_uc_master_info,
                        pout, pout_size, _pcps_ddev_has_ptp_unicast( pddev ) );
      break;

  #endif  // _MBG_SUPP_VAR_ACC_SIZE


    // Codes writing device configuration

    case IOCTL_SET_PCPS_SERIAL:
      _io_write_var( pddev, PCPS_SET_SERIAL, pcps_serial, pin );
      break;


    case IOCTL_SET_PCPS_TZCODE:
      _io_write_var_chk( pddev, PCPS_SET_TZCODE, pcps_tzcode, pin,
                         _pcps_ddev_has_tzcode( pddev ) );
      break;


    case IOCTL_SET_PCPS_TZDL:
      _io_write_var_chk( pddev, PCPS_SET_PCPS_TZDL, pcps_tzdl, pin,
                         _pcps_ddev_has_pcps_tzdl( pddev ) );
      break;


    case IOCTL_SET_REF_OFFS:
      _io_write_var_chk( pddev, PCPS_SET_REF_OFFS, mbg_ref_offs, pin,
                         _pcps_ddev_has_ref_offs( pddev ) );
      break;


    case IOCTL_SET_MBG_OPT_SETTINGS:
      _io_write_var_chk( pddev, PCPS_SET_OPT_SETTINGS, mbg_opt_settings,
                         pin, _pcps_ddev_has_opt_flags( pddev ) );
      break;


    case IOCTL_SET_PCPS_IRIG_RX_SETTINGS:
      _io_write_var_chk( pddev, PCPS_SET_IRIG_RX_SETTINGS,
                           irig_settings, pin,
                           _pcps_ddev_is_irig_rx( pddev ) );
      break;


    case IOCTL_SET_GPS_TZDL:
      _io_write_gps_var( pddev, PC_GPS_TZDL, tzdl, pin );
      break;


    case IOCTL_SET_GPS_PORT_PARM:
      _io_write_gps_var( pddev, PC_GPS_PORT_PARM, port_parm, pin );
      break;


    case IOCTL_SET_GPS_ENABLE_FLAGS:
      _io_write_gps_var( pddev, PC_GPS_ENABLE_FLAGS, enable_flags, pin );
      break;


    case IOCTL_SET_GPS_ANT_CABLE_LEN:
      _io_write_gps_var_chk( pddev, PC_GPS_ANT_CABLE_LEN, ant_cable_len,
                             pin, _pcps_ddev_has_cab_len( pddev ) );
      break;


    case IOCTL_SET_GPS_PORT_SETTINGS_IDX:
      _io_write_gps_var_chk( pddev, PC_GPS_PORT_SETTINGS_IDX, port_settings_idx,
                             pin, _pcps_ddev_has_receiver_info( pddev ) );
      break;


    case IOCTL_SET_PCPS_IRIG_TX_SETTINGS:
      /* This is a workaround for GPS169PCIs with early */
      /* firmware versions. See RCS log for details. */
      pcps_cmd = PCPS_SET_IRIG_TX_SETTINGS;

      if ( _pcps_ddev_requires_irig_workaround( pddev ) )
      {
        pcps_cmd = PCPS_SET_IRIG_RX_SETTINGS;
        _mbgddmsg_1( MBG_DBG_INFO, "%s: workaround for GPS169PCI \"set IRIG TX cfg\"",
                     pcps_driver_name );
      }

      _io_write_var_chk( pddev, pcps_cmd, irig_settings, pin,
                         _pcps_ddev_has_irig_tx( pddev ) );
      break;


    case IOCTL_SET_SYNTH:
      _io_write_var_chk( pddev, PCPS_SET_SYNTH, synth, pin,
                         _pcps_ddev_has_synth( pddev ) );
      break;


    case IOCTL_SET_GPS_POUT_SETTINGS_IDX:
      _io_write_gps_var_chk( pddev, PC_GPS_POUT_SETTINGS_IDX, pout_settings_idx,
                             pin, _pcps_ddev_has_receiver_info( pddev ) );
      break;


    case IOCTL_SET_IP4_SETTINGS:
      _io_write_gps_var_chk( pddev, PC_GPS_IP4_SETTINGS, ip4_settings,
                             pin, _pcps_ddev_has_lan_intf( pddev ) );
      break;


    case IOCTL_SET_PTP_CFG_SETTINGS:
      _io_write_gps_var_chk( pddev, PC_GPS_PTP_CFG, ptp_cfg_settings,
                             pin, _pcps_ddev_has_ptp( pddev ) );
      break;


    case IOCTL_SET_PTP_UC_MASTER_SETTINGS_IDX:
      _io_write_gps_var_chk( pddev, PC_GPS_PTP_UC_MASTER_SETTINGS_IDX,
                             ptp_uc_master_settings_idx, pin,
                            _pcps_ddev_has_ptp_unicast( pddev ) );
      break;


    case IOCTL_SET_TR_DISTANCE:
      _io_write_var_chk( pddev, PCPS_SET_TR_DISTANCE, tr_distance,
                         pin, _pcps_ddev_has_tr_distance( pddev ) );
      break;


    // Operations which may severely affect system operation

    case IOCTL_SET_PCPS_TIME:
      _io_write_var_chk( pddev, PCPS_SET_TIME, pcps_stime, pin,
                         _pcps_ddev_can_set_time( pddev ) );
      break;


    case IOCTL_SET_GPS_TIME:
      _io_write_gps_var( pddev, PC_GPS_TIME, ttm, pin );
      break;


    case IOCTL_SET_GPS_POS_XYZ:
      _io_write_gps_var( pddev, PC_GPS_POS_XYZ, xyzs, pin );
      break;


    case IOCTL_SET_GPS_POS_LLA:
      _io_write_gps_var( pddev, PC_GPS_POS_LLA, llas, pin );
      break;


    case IOCTL_SET_GPS_TIME_SCALE_SETTINGS:
      _io_write_gps_var_chk( pddev, PC_GPS_TIME_SCALE, mbg_time_scale_settings,
                             pin, _pcps_ddev_has_time_scale( pddev ) );
      break;


    case IOCTL_SET_GPS_UTC_PARM:
      _io_write_gps_var_chk( pddev, PC_GPS_UTC, utc, pin,
                             _pcps_ddev_has_utc_parm( pddev ) );
      break;


    case IOCTL_SET_GPS_CMD:
      _io_write_gps_var( pddev, PC_GPS_CMD, gps_cmd, pin );
      break;


    // Generic read/write operations which can do anything

    case IOCTL_PCPS_GENERIC_READ:
    #if USE_IOCTL_GENERIC_REQ
      _iob_from_pin_var( iob.req, pin );
      p_buff_out = _pcps_kmalloc( iob.req.out_sz );

      if ( p_buff_out == NULL )
      {
        _mbgddmsg_4( MBG_DBG_INFO, "%s: unable to alloc %lu bytes for %s, cmd: %02lX",
                     pcps_driver_name, (ulong) iob.req.out_sz,
                     "IOCTL_PCPS_GENERIC_READ", (ulong) iob.req.info );
        goto err_no_mem;
      }

      _pcps_sem_inc_safe( pddev );
      rc = _pcps_read( pddev, (uint8_t) iob.req.info, p_buff_out,
                       (uint8_t) iob.req.out_sz );
      _pcps_sem_dec( pddev );

      if ( rc == MBG_SUCCESS )
        _frc_iob_to_pout( p_buff_out, iob.req.out_p, iob.req.out_sz );

      _pcps_kfree( p_buff_out, iob.req.out_sz );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #else

      _iob_from_pin_var( iob.ctl, pin );
      buffer_size = sizeof( iob.ctl ) + iob.ctl.data_size_out;
      p_buff = _pcps_kmalloc( buffer_size );

      if ( p_buff == NULL )
        goto err_no_mem;

      _pcps_sem_inc_safe( pddev );
      rc = _pcps_read( pddev, (uint8_t) iob.ctl.info, p_buff->data,
                       (uint8_t) iob.ctl.data_size_out );
      _pcps_sem_dec( pddev );

      if ( rc == MBG_SUCCESS )
      {
        p_buff->ctl = iob.ctl;
        _iob_to_pout( p_buff, pout, buffer_size );   //##+++++++ need to check this !!
      }

      _pcps_kfree( p_buff, buffer_size );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #endif
      break;


    case IOCTL_PCPS_GENERIC_WRITE:
    #if USE_IOCTL_GENERIC_REQ
      _iob_from_pin_var( iob.req, pin );
      p_buff_in = _pcps_kmalloc( iob.req.in_sz );

      if ( p_buff_in == NULL )
      {
        _mbgddmsg_4( MBG_DBG_INFO, "%s: unable to alloc %lu bytes for %s, cmd: %02lX",
                     pcps_driver_name, (ulong) iob.req.in_sz,
                     "IOCTL_PCPS_GENERIC_WRITE", (ulong) iob.req.info );
        goto err_no_mem;
      }

      _frc_iob_from_pin( p_buff_in, iob.req.in_p, iob.req.in_sz );

      _pcps_sem_inc_safe( pddev );
      rc = pcps_write( pddev, (uint8_t) iob.req.info, p_buff_in,
                       (uint8_t) iob.req.in_sz );
      _pcps_sem_dec( pddev );

      _pcps_kfree( p_buff_in, iob.req.in_sz );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #else

      _iob_from_pin_var( iob.ctl, pin );
      buffer_size = sizeof( iob.ctl ) + iob.ctl.data_size_in;
      p_buff = _pcps_kmalloc( buffer_size );

      if ( p_buff == NULL )
        goto err_no_mem;

      _iob_from_pin( p_buff, pin, buffer_size );

      _pcps_sem_inc_safe( pddev );
      rc = pcps_write( pddev, (uint8_t) iob.ctl.info, p_buff->data,
                       (uint8_t) iob.ctl.data_size_in );
      _pcps_sem_dec( pddev );

      _pcps_kfree( p_buff, buffer_size );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #endif
      break;


    case IOCTL_PCPS_GENERIC_READ_GPS:
    #if USE_IOCTL_GENERIC_REQ
      _iob_from_pin_var( iob.req, pin );
      p_buff_out = _pcps_kmalloc( iob.req.out_sz );

      if ( p_buff_out == NULL )
      {
        _mbgddmsg_4( MBG_DBG_INFO, "%s: unable to alloc %lu bytes for %s, GPS cmd: %02lX",
                     pcps_driver_name, (ulong) iob.req.out_sz,
                     "IOCTL_PCPS_GENERIC_READ_GPS", (ulong) iob.req.info );
        goto err_no_mem;
      }

      _pcps_sem_inc_safe( pddev );
      rc = pcps_read_gps( pddev, (uint8_t) iob.req.info, p_buff_out,
                          (uint16_t) iob.req.out_sz );
      _pcps_sem_dec( pddev );

      if ( rc == MBG_SUCCESS )
        _frc_iob_to_pout( p_buff_out, iob.req.out_p, iob.req.out_sz );

      _pcps_kfree( p_buff_out, iob.req.out_sz );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #else

      _iob_from_pin_var( iob.ctl, pin );
      buffer_size = sizeof( iob.ctl ) + iob.ctl.data_size_out;
      p_buff = _pcps_kmalloc( buffer_size );

      if ( p_buff == NULL )
        goto err_no_mem;

      _pcps_sem_inc_safe( pddev );
      rc = pcps_read_gps( pddev, (uint8_t) iob.ctl.info, p_buff->data,
                          (uint16_t) iob.ctl.data_size_out );
      _pcps_sem_dec( pddev );

      if ( rc == MBG_SUCCESS )
      {
        p_buff->ctl = iob.ctl;
        _iob_to_pout( p_buff, pout, buffer_size );   //##+++++++ need to check this !!
      }

      _pcps_kfree( p_buff, buffer_size );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #endif
      break;


    case IOCTL_PCPS_GENERIC_WRITE_GPS:
    #if USE_IOCTL_GENERIC_REQ
      _iob_from_pin_var( iob.req, pin );
      p_buff_in = _pcps_kmalloc( iob.req.in_sz );

      if ( p_buff_in == NULL )
      {
        _mbgddmsg_4( MBG_DBG_INFO, "%s: unable to alloc %lu bytes for %s, cmd: %02lX",
                     pcps_driver_name, (ulong) iob.req.in_sz,
                     "IOCTL_PCPS_GENERIC_WRITE_GPS", (ulong) iob.req.info );
        goto err_no_mem;
      }

      _frc_iob_from_pin( p_buff_in, iob.req.in_p, iob.req.in_sz );

      _pcps_sem_inc_safe( pddev );
      rc = pcps_write_gps( pddev, (uint8_t) iob.req.info, p_buff_in,
                           (uint16_t) iob.req.in_sz );
      _pcps_sem_dec( pddev );

      _pcps_kfree( p_buff_in, iob.req.in_sz );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #else

      _iob_from_pin_var( iob.ctl, pin );
      buffer_size = sizeof( iob.ctl ) + iob.ctl.data_size_in;
      p_buff = _pcps_kmalloc( buffer_size );

      if ( p_buff == NULL )
        goto err_no_mem;

      _iob_from_pin( p_buff, pin, buffer_size );

      _pcps_sem_inc_safe( pddev );
      rc = pcps_write_gps( pddev, (uint8_t) iob.ctl.info, p_buff->data,
                           (uint8_t) iob.ctl.data_size_in );
      _pcps_sem_dec( pddev );

      _pcps_kfree( p_buff, buffer_size );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #endif
      break;


    case IOCTL_PCPS_GENERIC_IO:
    #if USE_IOCTL_GENERIC_REQ
      _io_chk_cond( _pcps_ddev_has_generic_io( pddev ) );
      _iob_from_pin_var( iob.req, pin );

      if ( iob.req.in_p && iob.req.in_sz )
      {
        p_buff_in = _pcps_kmalloc( iob.req.in_sz );

        if ( p_buff_in == NULL )
        {
          _mbgddmsg_4( MBG_DBG_INFO, "%s: unable to alloc %lu bytes for input in %s, cmd: %02lX",
                       pcps_driver_name, (ulong) iob.req.in_sz,
                       "IOCTL_PCPS_GENERIC_IO", (ulong) iob.req.info );
          goto err_no_mem;
        }

        _frc_iob_from_pin( p_buff_in, iob.req.in_p, iob.req.in_sz );
      }
      else
      {
        p_buff_in = NULL;
        iob.req.in_sz = 0;  // just to be sure
      }

      if ( iob.req.out_p && iob.req.out_sz )
      {
        p_buff_out = _pcps_kmalloc( iob.req.out_sz );

        if ( p_buff_out == NULL )
        {
          _mbgddmsg_4( MBG_DBG_INFO, "%s: unable to alloc %lu bytes for output in %s, cmd: %02lX",
                       pcps_driver_name, (ulong) iob.req.in_sz,
                       "IOCTL_PCPS_GENERIC_IO", (ulong) iob.req.info );

          // free the input buffer we already have allocated
          _pcps_kfree( p_buff_in, iob.req.in_sz );
          goto err_no_mem;
        }
      }
      else
      {
        p_buff_out = NULL;
        iob.req.out_sz = 0;  // just to be sure
      }

      _pcps_sem_inc_safe( pddev );
      rc = pcps_generic_io( pddev, (uint8_t) iob.req.info,
                            p_buff_in, (uint8_t) iob.req.in_sz,
                            p_buff_out, (uint8_t) iob.req.out_sz );
      _pcps_sem_dec( pddev );

      if ( rc == MBG_SUCCESS )
        _frc_iob_to_pout( p_buff_out, iob.req.out_p, iob.req.out_sz );

      if ( p_buff_in )
        _pcps_kfree( p_buff_in, iob.req.in_sz );

      if ( p_buff_out )
        _pcps_kfree( p_buff_out, iob.req.out_sz );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #else

      _io_chk_cond( _pcps_ddev_has_generic_io( pddev ) );

      _iob_from_pin_var( iob.ctl, pin );
      buffer_size = sizeof( iob.ctl ) +
                ( ( iob.ctl.data_size_in > iob.ctl.data_size_out ) ?
                    iob.ctl.data_size_in : iob.ctl.data_size_out );
      p_buff = _pcps_kmalloc( buffer_size );

      if ( p_buff == NULL )
        goto err_no_mem;

      _iob_from_pin( p_buff, pin, sizeof( p_buff->ctl ) + iob.ctl.data_size_in );

      _pcps_sem_inc_safe( pddev );
      rc = pcps_generic_io( pddev, (uint8_t) iob.ctl.info,
                            p_buff->data, (uint8_t) iob.ctl.data_size_in,
                            p_buff->data, (uint8_t) iob.ctl.data_size_out );
      _pcps_sem_dec( pddev );

      if ( rc == MBG_SUCCESS )
      {
        p_buff->ctl = iob.ctl;
        _iob_to_pout( p_buff, pout, sizeof( p_buff->ctl ) + iob.ctl.data_size_out );   //##+++++++ need to check this !!
      }

      _pcps_kfree( p_buff, buffer_size );

      if ( rc != MBG_SUCCESS )
        goto err_access;

    #endif
      break;


    // The next codes are somewhat special and normally
    // not used by the driver software:

    case IOCTL_GET_MAPPED_MEM_ADDR:
      _io_chk_cond( ( pddev->asic_features & PCI_ASIC_HAS_MM_IO ) );
      _io_get_mapped_mem_address( pddev, pout );
      break;


    case IOCTL_UNMAP_MAPPED_MEM:
      _io_chk_cond( ( pddev->asic_features & PCI_ASIC_HAS_MM_IO ) );
      _io_unmap_mapped_mem_address( pddev, pin );
      break;


  #if USE_DEBUG_PORT
    // The codes below are used for debugging only.
    // Unrestricted usage may cause system malfunction !!

    case IOCTL_MBG_DBG_GET_PORT_ADDR:
      _iob_to_pout_var( mbg_dbg_port, pout );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_MBG_DBG_SET_PORT_ADDR:
      _iob_from_pin_var( mbg_dbg_port, pin );
      mbg_dbg_port_mapped = _pcps_ioremap( mbg_dbg_port, sizeof( mbg_dbg_port ) );
      rc = MBG_SUCCESS;
      break;


    case IOCTL_MBG_DBG_SET_BIT:
      _iob_from_pin_var( iob.mbg_dbg_data, pin );
      _mbg_dbg_set_bit( pddev, iob.mbg_dbg_data );
      mbg_get_pc_cycles( &cyc );
      _iob_to_pout_var( cyc, pout );
      break;


    case IOCTL_MBG_DBG_CLR_BIT:
      _iob_from_pin_var( iob.mbg_dbg_data, pin );
      _mbg_dbg_clr_bit( pddev, iob.mbg_dbg_data );
      mbg_get_pc_cycles( &cyc );
      _iob_to_pout_var( cyc, pout );
      break;


    case IOCTL_MBG_DBG_CLR_ALL:
      _mbg_dbg_clr_all( pddev );
      mbg_get_pc_cycles( &cyc );
      _iob_to_pout_var( cyc, pout );
      break;

  #endif  // USE_DEBUG_PORT


    default:
      goto err_inval;
  }

  return rc;


err_inval:
  return MBG_ERR_INV_DEV_REQUEST;

err_support:
  return MBG_ERR_NOT_SUPP_BY_DEV;

err_no_mem:
  return MBG_ERR_NO_MEM;

err_busy_unsafe:
  return MBG_ERR_IRQ_UNSAFE;

err_access:
  return rc;  // return the rc from the low level routine


#if defined( USE_COPY_KERNEL_USER )

err_to_user:
  return MBG_ERR_COPY_TO_USER;

err_from_user:
  return MBG_ERR_COPY_FROM_USER;

#endif // defined( USE_COPY_KERNEL_USER )

}  // ioctl_switch

#endif  /* _MACIOCTL_H */

