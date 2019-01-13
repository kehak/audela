
/**************************************************************************
 *
 *  $Id: pcpsdev.h 1.49.1.68 2011/11/28 10:04:39 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions used to share information on radio clock devices
 *    between device drivers which have direct access to the hardware
 *    devices and user space programs which evaluate and present that
 *    information.
 *
 *    At the bottom of the file there are some macros defined which
 *    should be used to access the structures to extract characteristics
 *    of an individual clock.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsdev.h $
 *  Revision 1.49.1.68  2011/11/28 10:04:39  martin
 *  PZF180PEX doesn't support TIME_SCALE by default.
 *  Revision 1.49.1.67  2011/11/25 15:03:23  martin
 *  Support on-board event logs.
 *  Revision 1.49.1.66  2011/11/24 14:01:45  martin
 *  Added kernel uptime/sleep for NetBSD.
 *  Revision 1.49.1.65  2011/11/24 08:54:53  martin
 *  Moved macro _must_do_fw_workaround_20ms() here.
 *  Revision 1.49.1.64  2011/11/22 16:27:25  martin
 *  New macro _pcps_has_debug_status().
 *  Revision 1.49.1.63  2011/11/01 12:20:00  martin
 *  Revision 1.49.1.62  2011/11/01 12:14:33  martin
 *  Revision 1.49.1.61  2011/11/01 09:13:05  martin
 *  Revision 1.49.1.60  2011/10/31 08:55:05  martin
 *  Revision 1.49.1.59  2011/10/28 13:51:15  martin
 *  Added some macros to test if specific stat_info stuff is supported.
 *  Revision 1.49.1.58  2011/10/21 14:07:27  martin
 *  Revision 1.49.1.57  2011/09/21 16:03:04  martin
 *  Moved some definitions useful for configuration tools to new file cfg_hlp.h.
 *  Revision 1.49.1.56  2011/09/20 08:31:22  martin
 *  Modified default features for PZF180PEX.
 *  Revision 1.49.1.55  2011/09/12 12:32:38Z  martin
 *  Revision 1.49.1.54  2011/09/12 09:45:12  martin
 *  Fixed a typo (missing comma).
 *  Revision 1.49.1.53  2011/08/05 11:02:28  martin
 *  Revision 1.49.1.52  2011/07/19 10:41:48  martin
 *  Revision 1.49.1.51  2011/07/14 13:29:14  martin
 *  Revision 1.49.1.50  2011/07/13 09:44:53  martin
 *  Moved IA64 includes from pcpsdev.h to mbgpccyc.h.
 *  Revision 1.49.1.49  2011/07/06 13:23:24  martin
 *  Revision 1.49.1.48  2011/07/06 11:22:50  martin
 *  Added macros _pcps_has_corr_info() and _pcps_has_tr_distance().
 *  Revision 1.49.1.47  2011/07/05 12:25:19  martin
 *  Revision 1.49.1.46  2011/07/04 10:29:44  martin
 *  Modified a comment.
 *  Revision 1.49.1.45  2011/06/29 14:06:08  martin
 *  Added support for TCR600USB, MSF600USB, and WVB600USB.
 *  Extended bus flag for USB v2 and macro _pcps_is_usb_v2().
 *  New feature ..._HAS_PZF and macro _pcps_has_pzf().
 *  Revision 1.49.1.44  2011/06/29 09:10:26  martin
 *  Renamed PZF600PEX to PZF180PEX.
 *  Revision 1.49.1.43  2011/06/24 10:26:52  martin
 *  Fixed warning under DOS.
 *  Revision 1.49.1.42  2011/06/24 08:07:03Z  martin
 *  Moved PC cycles stuff to an new extra header.
 *  Revision 1.49.1.41  2011/06/21 15:17:36  martin
 *  Fixed build under DOS.
 *  Revision 1.49.1.40  2011/06/21 14:23:59Z  martin
 *  Cleaned up handling of pragma pack().
 *  Introduced generic MBG_SYS_TIME with nanosecond resolution.
 *  Support struct timespec under Linux, if available.
 *  Revision 1.49.1.39  2011/06/01 09:29:09  martin
 *  Revision 1.49.1.38  2011/05/31 14:20:54  martin
 *  Revision 1.49.1.37  2011/05/16 13:18:38  martin
 *  Use MBG_TGT_KERNEL instead of _KDD_.
 *  Revision 1.49.1.36  2011/05/06 13:47:38Z  martin
 *  Support PZF600PEX.
 *  Revision 1.49.1.35  2011/04/19 15:06:24  martin
 *  Added PTP unicast master configuration stuff.
 *  Revision 1.49.1.34  2011/03/29 14:08:45  martin
 *  For compatibility use cpu_counter() instead of cpu_counter_serializing() under NetBSD.
 *  Revision 1.49.1.33  2011/03/28 09:50:18  martin
 *  Modifications for NetBSD from Frank Kardel.
 *  Revision 1.49.1.32  2011/03/25 11:09:43  martin
 *  Optionally support timespec for sys time (USE_TIMESPEC).
 *  Started to support NetBSD.
 *  Revision 1.49.1.31  2011/02/16 10:10:49  martin
 *  Fixed macro syntax for _pcps_time_set_unread().
 *  Revision 1.49.1.30  2011/02/15 14:24:56Z  martin
 *  Revision 1.49.1.29  2011/02/10 13:34:21  martin
 *  Revision 1.49.1.28  2011/02/10 13:21:59  martin
 *  Revision 1.49.1.27  2011/02/10 12:26:17  martin
 *  Revision 1.49.1.26  2011/02/09 15:46:49  martin
 *  Revision 1.49.1.25  2011/02/04 14:44:44  martin
 *  Revision 1.49.1.24  2011/02/04 10:10:00  martin
 *  Revision 1.49.1.23  2011/02/02 12:34:10  martin
 *  Revision 1.49.1.22  2011/02/01 17:12:04  martin
 *  Revision 1.49.1.21  2011/01/28 13:11:11  martin
 *  Preliminary implementation of mbg_get_sys_time for FreeBSD traps.
 *  Revision 1.49.1.20  2011/01/28 10:34:37  martin
 *  Moved MBG_TGT_SUPP_MEM_ACC definition here.
 *  Revision 1.49.1.19  2011/01/26 16:39:05  martin
 *  Preliminarily support FreeBSD build.
 *  Revision 1.49.1.18  2011/01/24 17:09:51  martin
 *  Preliminarily fixed build under FreeBSD.
 *  Revision 1.49.1.17  2010/12/14 13:19:58  martin
 *  Fixed doxgen comments.
 *  Revision 1.49.1.16  2010/12/14 12:20:10  martin
 *  Revision 1.49.1.15  2010/11/25 14:54:22  martin
 *  Moved status port register definitions to pcpsdefs.h.
 *  Revision 1.49.1.14  2010/11/11 09:15:38  martin
 *  Added definitions to support DCF600USB.
 *  Revision 1.49.1.13  2010/09/27 13:09:06  martin
 *  Features are now defined using enum and bit masks.
 *  Added initializer for feature names (used for debug).
 *  Revision 1.49.1.12  2010/08/25 12:44:42  martin
 *  Revision 1.49.1.11  2010/08/20 09:34:41Z  martin
 *  Added macro _pcps_features().
 *  Revision 1.49.1.10  2010/08/17 15:34:23  martin
 *  Revision 1.49.1.9  2010/08/16 15:41:32  martin
 *  Revision 1.49.1.8  2010/08/13 12:14:46  daniel
 *  Revision 1.49.1.7  2010/08/13 11:57:54Z  martin
 *  Revision 1.49.1.6  2010/08/13 11:39:28Z  martin
 *  Revision 1.49.1.5  2010/08/13 11:19:41  martin
 *  Implemented portable mbg_get_sys_uptime() and mbg_sleep_sec()
 *  functions and associated types.
 *  Revision 1.49.1.4  2010/08/11 14:32:14  martin
 *  Revision 1.49.1.3  2010/08/11 13:47:42  martin
 *  Cleanup.
 *  Revision 1.49.1.2  2010/07/14 14:50:42  martin
 *  Revision 1.49.1.1  2010/06/30 13:17:18  martin
 *  Support GPS180PEX and TCR180PEX.
 *  Revision 1.49  2010/06/30 13:03:48  martin
 *  Use new preprocessor symbol MBG_ARCH_X86.
 *  Use ulong port addresses for all platforms but x86.
 *  Support mbg_get_pc_cycles() for IA64, but mbg_get_pc_cycles_frequency()
 *  is not yet supported.
 *  Don't pack interface structures on Sparc and IA64 architecture.
 *  Revision 1.48  2010/04/26 14:47:42  martin
 *  Define symbol MBG_PC_CYCLES_SUPPORTED if this is the case.
 *  Revision 1.47  2010/01/12 14:03:22  daniel
 *  Added definitions to support reading the raw IRIG data bits.
 *  Revision 1.46  2009/09/29 15:10:35Z  martin
 *  Support generic system time, and retrieving time discipline info.
 *  Added _pcps_has_fast_hr_timestamp() macro and associated feature flag.
 *  Revision 1.45  2009/06/19 12:15:18  martin
 *  Added has_irig_time feature and associated macros.
 *  Revision 1.44  2009/06/08 19:30:48  daniel
 *  Account for new features PCPS_HAS_LAN_INTF and
 *  PCPS_HAS_PTP.
 *  Revision 1.43  2009/04/08 08:26:20  daniel
 *  Define firmware version at which the TCR511PCI starts
 *  to support IRIG control bits.
 *  Revision 1.42  2009/03/19 14:58:47Z  martin
 *  Tmp. workaround in mbg_delta_pc_cycles() under SPARC which might
 *  generate bus errors due to unaligned access.
 *  Revision 1.41  2009/03/16 16:01:22  martin
 *  Support reading IRIG control function bits.
 *  Revision 1.40  2009/03/13 09:13:39  martin
 *  Support new features .._has_time_scale() and .._has_utc_parm().
 *  Moved some inline functions dealing with MBG_PC_CYCLES
 *  from mbgdevio.h here.
 *  Merged the code from _pcps_get_cycles() and _pcps_get_cycles_frequency()
 *  to the mbg_get_pc_cycles...() inline functions which now replace the 
 *  _pcps_get_cycles...() macros.
 *  Fixed cycles code for non-x86 architectures.
 *  Revision 1.39  2008/12/05 16:24:24Z  martin
 *  Changed MAX_PARM_STR_TYPE from 10 to 20.
 *  Added support for WWVB signal source.
 *  Support new devices PTP270PEX, FRC511PEX, TCR170PEX, and WWVB51USB.
 *  Added macros _pcps_is_ptp(), _pcps_is_frc(), and _pcps_is_wwvb().
 *  Defined firmware version numbers which fix an IRQ problem with PEX511,
 *  TCR511PEX, and GPS170PEX cards. The fix also requires specific ASIC
 *  versions specified in pci_asic.h.
 *  Defined firmware versions at which PCI511 and PEX511 start 
 *  to support HR time.
 *  Support mapped I/O resources.
 *  Changed MBG_PC_CYCLES type for Windows to int64_t.
 *  Renamed MBG_VIRT_ADDR to MBG_MEM_ADDR.
 *  Added MBG_PC_CYCLES_FREQUENCY type.
 *  Added definition of PCPS_TIME_STAMP_CYCLES.
 *  Added PCPS_IRQ_STAT_INFO type and associated flags.
 *  Added macros to convert the endianess of structures.
 *  Added macros _pcps_fw_rev_num_major() and _pcps_fw_rev_num_minor().
 *  Made irq_num signed to use -1 for unassigned IRQ numbers.
 *  Revision 1.38  2008/01/17 10:12:34  daniel
 *  Added support for TCR51USB and MSF51USB.
 *  New type MBG_VIRT_ADDR to specify virtual address values.
 *  New struct PCPS_MAPPED_MEM
 *  Cleanup for PCI ASIC version and features.
 *  Added macros _pcps_is_msf(), _pcps_is_lwr(),
 *  _psps_has_asic_version(), _pcps_has_asic_features().
 *  Revision 1.37  2008/01/17 09:58:11Z  daniel
 *  Made comments compatible for doxygen parser.
 *  No sourcecode changes.  
 *  Revision 1.36  2007/09/26 09:34:38Z  martin
 *  Added support for USB in general and new USB device USB5131.
 *  Added new types PCPS_DEV_ID and PCPS_REF_TYPE.
 *  Removed old PCPS_ERR_... codes. Use MBG_ERR_... codes 
 *  from mbgerror.h instead. The old values haven't changed.
 *  Revision 1.35  2007/07/17 08:22:47Z  martin
 *  Added support for TCR511PEX and GPS170PEX.
 *  Revision 1.34  2007/07/16 12:50:41Z  martin
 *  Added support for PEX511.
 *  Modified/renamed some macros and symbols.
 *  Revision 1.33  2007/03/02 09:40:04Z  martin
 *  Changes due to renamed library symbols.
 *  Removed obsolete inclusion of headers.
 *  Preliminary support for *BSD.
 *  Preliminary support for USB.
 *  Revision 1.32  2006/10/23 08:47:55Z  martin
 *  Don't use abs() in _pcps_ref_offs_out_of_range() since this might 
 *  not work properly for 16 bit integers and value 0x8000.
 *  Revision 1.31  2006/06/14 12:59:13Z  martin
 *  Added support for TCR511PCI.
 *  Revision 1.30  2006/04/05 14:58:41  martin
 *  Support higher baud rates for PCI511.
 *  Revision 1.29  2006/04/03 07:29:07Z  martin
 *  Added a note about the missing PCPS_ST_IRQF signal 
 *  on PCI510 cards. 
 *  Revision 1.28  2006/03/10 10:32:56Z  martin
 *  Added support for PCI511.
 *  Added support for programmable pulse outputs.
 *  Revision 1.27  2005/11/04 08:48:00Z  martin
 *  Added support for GPS170PCI.
 *  Revision 1.26  2005/06/02 08:34:38Z  martin
 *  New types MBG_DBG_PORT, MBG_DBG_DATA.
 *  Revision 1.25  2005/05/03 10:04:14  martin
 *  Added macro _pcps_is_pci_amcc().
 *  Revision 1.24  2005/03/29 12:58:19Z  martin
 *  Support GENERIC_IO feature.
 *  Revision 1.23  2004/12/09 11:03:37Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.22  2004/11/09 12:57:52Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Added support for TCR167PCI.
 *  New macro _pcps_has_gps_data().
 *  New type PCPS_STATUS_PORT.
 *  Removed obsolete inclusion of asm/timex.h for Linux.
 *  Revision 1.21  2004/09/06 15:19:49Z  martin
 *  Support a GPS_DATA interface where sizes are specified 
 *  by 16 instead of the original 8 bit quantities, thus allowing 
 *  to transfer data blocks which exceed 255 bytes.
 *  Modified inclusion of header files under Linux.
 *  Modified definition of MBG_PC_CYCLES for Linux.
 *  Revision 1.20  2004/04/14 09:09:11  martin
 *  Source code cleanup.
 *  Revision 1.19  2004/04/07 09:49:14Z  martin
 *  Support new feature PCPS_HAS_IRIG_TX.
 *  New macros _pcps_has_irig(), _pcps_has_irig_tx().
 *  Revision 1.18  2004/01/14 11:02:14Z  MARTIN
 *  Added formal type MBG_PC_CYCLES for OS/2,
 *  though it's not really required or used.
 *  Revision 1.17  2003/12/22 15:40:16  martin
 *  Support higher baud rates for TCR510PCI and PCI510.
 *  Supports PCPS_HR_TIME for TCR510PCI.
 *  New structures used to read device time together with associated
 *  PC CPU cycles.
 *  For Win32, differentiate between kernel mode and non-kernel mode.
 *  Moved some definitions here from mbgdevio.h.
 *  New type PCPS_ASIC_VERSION.
 *  New macro _pcps_ref_offs_out_of_range().
 *  Revision 1.16  2003/06/19 09:48:30Z  MARTIN
 *  Renamed symbols ..clr_cap_buffer to ..clr_ucap_buffer.
 *  New macro _pcps_has_ucap().
 *  New definitions to support cmds PCPS_GIVE_UCAP_ENTRIES
 *  and PCPS_GIVE_UCAP_EVENT.
 *  Revision 1.15  2003/04/15 09:57:25  martin
 *  New typedefs ALL_STR_TYPE_INFO, ALL_PORT_INFO,
 *  RECEIVER_PORT_CFG.
 *  Revision 1.14  2003/04/09 14:07:01Z  martin
 *  Supports PCI510, GPS169PCI, and TCR510PCI,
 *  and new PCI_ASIC used by those devices.
 *  Renamed macro _pcps_is_irig() to _pcps_is_irig_rx().
 *  New macros _pcps_has_ref_offs(), _pcps_has_opt_flags().
 *  Fixed macro _pcps_has_hr_time().
 *  New type PCPS_BUS_FLAGS.
 *  Preliminary support for PCPS_TZDL.
 *  Revision 1.13  2002/08/09 07:19:49  MARTIN
 *  Moved definition of ref time sources to pcpsdefs.h.
 *  New feature PCPS_CAN_CLR_CAP_BUFF and
 *  associated macro _pcps_can_clr_cap_buff().
 *  New macros _pcps_is_irig(), _pcps_has_signal(),
 *  _pcps_has_mod().
 *  Revision 1.12  2002/02/19 09:22:53  MARTIN
 *  Added definitions for the maximum number of clocks' serial ports
 *  and string types that can be handled by the configuration programs.
 *  Revision 1.11  2002/02/01 11:36:58  MARTIN
 *  Added new definitions for GPS168PCI.
 *  Inserted definitions of firmware REV_NUMs  for supported features
 *  which had previously been defined in pcpsdefs.h.
 *  Include use_pack.h.
 *  Updated comments.
 *  Source code cleanup.
 *  Revision 1.10  2001/11/30 09:52:48  martin
 *  Added support for event_time which, however, requires
 *  a custom GPS firmware.
 *  Revision 1.9  2001/10/16 10:11:14  MARTIN
 *  New Macro _pcps_has_serial_hs() which determines whether
 *  DCF77 clock supports baud rate higher than default.
 *  Re-arranged order of macro definitions.
 *  Revision 1.8  2001/09/03 07:15:05  MARTIN
 *  Added macro to access the firmware revision number.
 *  Cleaned up macro syntax.
 *  Added some comments.
 *  Revision 1.7  2001/08/30 13:20:04  MARTIN
 *  New macro to mark a PCPS_TIME variable  as unread.
 *  New macro to check if a PCPS_TIME variable  is unread.
 *  Revision 1.6  2001/03/15 15:45:01  MARTIN
 *  Added types PCPS_ERR_FLAGS, PCPS_BUS_NUM, PCPS_SLOT_NUM.
 *  Revision 1.5  2001/03/01 13:53:10  MARTIN
 *  Initial version for the new driver library.
 *
 **************************************************************************/

#ifndef _PCPSDEV_H
#define _PCPSDEV_H

#include <mbg_tgt.h>
#include <mbgtime.h>
#include <mbgpccyc.h>
#include <pcpsdefs.h>
#include <gpsdefs.h>
#include <usbdefs.h>
#include <use_pack.h>

#if defined( MBG_TGT_LINUX )

  #if defined( MBG_TGT_KERNEL )
    #include <linux/delay.h>
    #include <linux/time.h>
  #else
    #include <unistd.h>
    #include <time.h>
    #include <sys/time.h>
    #include <sys/sysinfo.h>
  #endif

#elif defined( MBG_TGT_FREEBSD )

  #if defined( MBG_TGT_KERNEL )
    #include <sys/sysproto.h>
    #include <sys/pcpu.h>
    #include <sys/param.h>
    #include <sys/systm.h>
    #include <sys/proc.h>
  #else
    #include <unistd.h>
    #include <sys/time.h>
  #endif

#elif defined( MBG_TGT_NETBSD )

  #if defined( MBG_TGT_KERNEL )
    #include <sys/param.h>  // mstohz
    #include <sys/kernel.h>  // hz
  #else
    #include <unistd.h>
    #include <sys/time.h>
  #endif

#elif defined( MBG_TGT_QNX_NTO )

  #include <unistd.h>

#elif defined( MBG_TGT_DOS )

  #include <dos.h>     // for delay()

#endif


/* Start of header body */

#if defined( _USE_PACK )
  #if !defined( _NO_USE_PACK_INTF )
    #pragma pack( 1 )      // set byte alignment
    #define _USING_BYTE_ALIGNMENT
  #endif
#endif


#if defined( MBG_TGT_UNIX )
  #define USE_GENERIC_SYS_TIME  1
#else
  #define USE_GENERIC_SYS_TIME  0
#endif


#if USE_GENERIC_SYS_TIME

  typedef struct
  {
    uint64_t sec;
    uint64_t nsec;
  } NANO_TIME_64;

  typedef NANO_TIME_64 MBG_SYS_TIME;

#endif



/**
  Define generic types to hold PC cycle counter values and system timestamps.
  The generic types are defined using native types used by the target operating
  systems.

  The cycle counter value is usually derived from the PC CPU's TSC or some other
  timer hardware on the mainboard.
  */
#if defined( MBG_TGT_WIN32 )

  #define MBG_TGT_SUPP_MEM_ACC  1

  typedef int64_t MBG_SYS_UPTIME;    // [s]

  typedef LARGE_INTEGER MBG_SYS_TIME;

#elif defined( MBG_TGT_LINUX )

  #define MBG_TGT_SUPP_MEM_ACC  1

  typedef int64_t MBG_SYS_UPTIME;    // [s]

#elif defined( MBG_TGT_BSD )

  #define MBG_TGT_SUPP_MEM_ACC  1

  typedef int64_t MBG_SYS_UPTIME;    // [s]

  #if defined( MBG_TGT_NETBSD )
    #ifdef __LP64__
      #define MBG_MEM_ADDR uint64_t
    #else
      #define MBG_MEM_ADDR uint32_t
    #endif
  #endif

#elif defined( MBG_TGT_OS2 )

  typedef long MBG_SYS_UPTIME;     //## dummy

  typedef uint32_t MBG_SYS_TIME;   //## dummy

#elif defined( MBG_TGT_DOS )

  #define MBG_MEM_ADDR  uint32_t   // 64 bit not supported, nor required.

  typedef long MBG_SYS_UPTIME;     //## dummy

  typedef uint32_t MBG_SYS_TIME;   //## dummy

#else // other target OSs which access the hardware directly

  typedef long MBG_SYS_UPTIME;     //## dummy

  typedef uint32_t MBG_SYS_TIME;   //## dummy

#endif


#if !defined( MBG_TGT_SUPP_MEM_ACC )
  #define MBG_TGT_SUPP_MEM_ACC  0
#endif


// MBG_SYS_TIME is always read  in native machine endianess,
// so no endianess conversion is required.
#define _mbg_swab_mbg_sys_time( _p ) \
  _nop_macro_fnc()



/**
  The structure holds a system timestamp in a format depending on the target OS
  plus two cycles counter values which can be taken before and after reading
  the system time. These cycles values can be used to determine the execution
  time required to read the system time.

  Limitations of the operating system need to be taken into account,
  e.g. the Windows system time may increase once every ~16 ms only.
  */
typedef struct
{
  MBG_PC_CYCLES cyc_before;   /**< cycles count before sys time is read */
  MBG_PC_CYCLES cyc_after;    /**< cycles count after sys time has been read */
  MBG_SYS_TIME sys_time;      /**< system time stamp */
} MBG_SYS_TIME_CYCLES;

#define _mbg_swab_mbg_sys_time_cycles( _p )      \
{                                                \
  _mbg_swab_mbg_pc_cycles( &(_p)->cyc_before );  \
  _mbg_swab_mbg_pc_cycles( &(_p)->cyc_after );   \
  _mbg_swab_mbg_sys_time( &(_p)->sys_time );     \
}




static __mbg_inline
void mbg_get_sys_time( MBG_SYS_TIME *p )
{
  #if defined( MBG_TGT_WIN32 )

    #if defined( MBG_TGT_KERNEL )  // kernel space
      KeQuerySystemTime( p );
    #else                          // user space
    {
      FILETIME ft;
      GetSystemTimeAsFileTime( &ft );
      p->LowPart = ft.dwLowDateTime;
      p->HighPart = ft.dwHighDateTime;
    }
    #endif

  #elif defined( MBG_TGT_LINUX )

    #if defined( MBG_TGT_KERNEL )

      #if ( LINUX_VERSION_CODE >= KERNEL_VERSION( 2, 6, 22 ) )  //##+++++++++++++
      {
        // getnstimeofday() supported
        struct timespec ts;

        getnstimeofday( &ts );

        p->sec = ts.tv_sec;
        p->nsec = ts.tv_nsec;
      }
      #else
      {
        // getnstimeofday() *not* supported
        struct timeval tv;

        do_gettimeofday( &tv );

        p->sec = tv.tv_sec;
        p->nsec = tv.tv_usec * 1000;
      }
      #endif

    #else  // Linux user space
    {
      struct timespec ts;

      clock_gettime( CLOCK_REALTIME, &ts );

      p->sec = ts.tv_sec;
      p->nsec = ts.tv_nsec;
    }
    #endif

  #elif defined( MBG_TGT_BSD )

    struct timespec ts;

    #if defined( MBG_TGT_KERNEL )
      nanotime( &ts );
    #else
      #if defined( MBG_TGT_FREEBSD )
        clock_gettime( CLOCK_REALTIME_PRECISE, &ts );
      #else  // MBG_TGT_NETBSD, ...
        clock_gettime( CLOCK_REALTIME, &ts );
      #endif
    #endif

    p->sec = ts.tv_sec;
    p->nsec = ts.tv_nsec;

  #else

    *p = 0;

  #endif

}  // mbg_get_sys_time



static __mbg_inline
void mbg_get_sys_uptime( MBG_SYS_UPTIME *p )
{
  #if defined( MBG_TGT_WIN32 )

    #if defined( MBG_TGT_KERNEL )  // kernel space

      ULONGLONG time_increment  = KeQueryTimeIncrement();
      LARGE_INTEGER tick_count;

      KeQueryTickCount( &tick_count );

      // multiplication by time_increment yields HNS units,
      // but we need seconds
      *p = ( tick_count.QuadPart * time_increment ) / HNS_PER_SEC;

    #else                          // user space

      DWORD tickCount;
      DWORD timeAdjustment;
      DWORD timeIncrement;
      BOOL timeAdjustmentDisabled;

      if ( !GetSystemTimeAdjustment( &timeAdjustment, &timeIncrement, &timeAdjustmentDisabled ) )
        *p = -1;  // failed

      // ATTENTION: This is compatible with older Windows versions, but
      // the returned tick count wraps around to zero after 49.7 days.
      // A new GetTickCount64() call is available under Windows Vista and newer,
      // but the function call had to be imported dynamically since otherwise
      // programs refused to start under pre-Vista versions due to undefined DLL symbol.
      tickCount = GetTickCount();

      *p = ( ( (MBG_SYS_UPTIME) tickCount ) * timeIncrement ) / HNS_PER_SEC;

    #endif

  #elif defined( MBG_TGT_LINUX )

    #if defined( MBG_TGT_KERNEL )
    {
      // Using a simple 64 bit division may result in a linker error
      // in kernel mode due to a missing symbol __udivdi3, so we use
      // a specific inline function do_div().
      // Also, the jiffies counter is not set to 0 at startup but to
      // a defined initialization value we need to account for.
      uint64_t tmp = get_jiffies_64() - INITIAL_JIFFIES;
      do_div( tmp, HZ );
      *p = tmp;
    }
    #else
    {
      struct sysinfo si;
      int rc = sysinfo( &si );
      *p = ( rc == 0 ) ? si.uptime : -1;
    }
    #endif

  #elif defined( MBG_TGT_BSD )

    #if defined( MBG_TGT_KERNEL )
    {
      struct timespec ts;
      #if 0  //##+++++++
      {
        struct bintime bt;

        binuptime( &bt );
        #if defined( DEBUG )
          printf( "binuptime: %lli.%09lli\n",
                  (long long) bt.sec,
                  (long long) bt.frac );
        #endif
      }
      #endif

      nanouptime( &ts );
      #if defined( DEBUG )
        printf( "nanouptime: %lli.%09lli\n",
                (long long) ts.tv_sec,
                (long long) ts.tv_nsec );
      #endif
      *p = ts.tv_sec;
    }
    #elif defined( MBG_TGT_FREEBSD )
    {
      struct timespec ts;
      // CLOCK_UPTIME_FAST is specific to FreeBSD
      int rc = clock_gettime( CLOCK_UPTIME_FAST, &ts );
      *p = ( rc == 0 ) ? ts.tv_sec : -1;
    }
    #else  // MBG_TGT_NETBSD, ...

      *p = -1;  //##++ needs to be implemented

    #endif

  #else

    *p = -1;  // not supported

  #endif

}  // mbg_get_sys_uptime



static __mbg_inline
void mbg_sleep_sec( long sec )
{
  #if defined( MBG_TGT_WIN32 )

    #if defined( MBG_TGT_KERNEL )  // kernel space
      LARGE_INTEGER delay;

      // we need to pass a negative value to KeDelayExecutionThread()
      // since the given time is a relative time interval, not absolute
      // time. See the API docs for KeDelayExecutionThread().
      delay.QuadPart = (LONGLONG) sec * HNS_PER_SEC;

      KeDelayExecutionThread( KernelMode, FALSE, &delay );
    #else                          // user space
      // Sleep() expects milliseconds
      Sleep( sec * 1000 );
    #endif

  #elif defined( MBG_TGT_LINUX )

    #if defined( MBG_TGT_KERNEL )
      // msleep is not defined in older kernels, so we use this
      // only if it is surely supported.
      #if ( LINUX_VERSION_CODE >= KERNEL_VERSION( 2, 6, 16 ) ) //##+++++
        msleep( sec * 1000 );
      #else
      {
        DECLARE_WAIT_QUEUE_HEAD( tmp_wait );
        wait_event_interruptible_timeout( tmp_wait, 0, sec * HZ + 1 );
      }
      #endif
    #else
      sleep( sec );
    #endif

  #elif defined( MBG_TGT_BSD )

    #if defined( MBG_TGT_KERNEL )
      #if defined( MBG_TGT_FREEBSD )
        struct timeval tv = { 0 };
        int ticks;
        tv.tv_sec = sec;
        ticks = tvtohz( &tv );
        #if defined( DEBUG )
          printf( "pause: %lli.%06lli (%i ticks)\n",
                  (long long) tv.tv_sec,
                  (long long) tv.tv_usec,
                  ticks );
        #endif
        pause( "pause", ticks );
      #elif defined( MBG_TGT_NETBSD )
        int timeo = mstohz( sec * 1000 );
        #if defined( DEBUG )
          printf( "kpause: %i s (%i ticks)\n", sec, timeo );
        #endif
        kpause( "pause", 1, timeo, NULL );
      #endif
    #else
      sleep( sec );
    #endif

  #elif defined( MBG_TGT_QNX_NTO )

    // Actually only tested under Neutrino.
    sleep( sec );

  #elif defined( MBG_TGT_DOS )

    delay( (unsigned) ( sec * 1000 ) );

  #else

    // This needs to be implemented for the target OS
    // and thus will probably yield a linker error.
    do_sleep_sec( sec );

  #endif

}  // mbg_sleep_sec



#if !defined( MBG_MEM_ADDR )
  // By default a memory address is stored
  // as a 64 bit quantitiy.
  #define MBG_MEM_ADDR  uint64_t
#endif


typedef uint8_t MBG_DBG_DATA;
typedef uint16_t MBG_DBG_PORT;


// The following flags describe the bus types which are
// supported by the plugin clocks.
#define PCPS_BUS_ISA        0x0001    // IBM compatible PC/AT ISA bus
#define PCPS_BUS_MCA        0x0002    // IBM PS/2 micro channel
#define PCPS_BUS_PCI        0x0004    // PCI
#define PCPS_BUS_USB        0x0008    // USB


// The flags below are or'ed to the PC_BUS_PCI code
// in order to indicate which PCI interface chip is used
// on a PCI card. If no flag is set then the S5933 chip is
// installed which has been used for the first generation
// of Meinberg PCI cards.
#define PCPS_BUS_PCI_CHIP_S5920    0x8000    // S5920 PCI interface chip.
#define PCPS_BUS_PCI_CHIP_ASIC     0x4000    // Meinberg's own PCI interface chip.
#define PCPS_BUS_PCI_CHIP_PEX8311  0x2000    // PEX8311 PCI Express interface chip
#define PCPS_BUS_PCI_CHIP_MBGPEX   0x1000    // Meinberg's own PCI Express interface chip

// The constants below combine the PCI bus flags:
#define PCPS_BUS_PCI_S5933    ( PCPS_BUS_PCI )
#define PCPS_BUS_PCI_S5920    ( PCPS_BUS_PCI | PCPS_BUS_PCI_CHIP_S5920 )
#define PCPS_BUS_PCI_ASIC     ( PCPS_BUS_PCI | PCPS_BUS_PCI_CHIP_ASIC )
#define PCPS_BUS_PCI_PEX8311  ( PCPS_BUS_PCI | PCPS_BUS_PCI_CHIP_PEX8311 )
#define PCPS_BUS_PCI_MBGPEX   ( PCPS_BUS_PCI | PCPS_BUS_PCI_CHIP_MBGPEX )


// The flags below are or'ed to the PCPS_BUS_USB code
// in order to indicate which USB protocol version
// is supported by the device. If no additional flag is set
// then the device has a USB v1 interface.
#define PCPS_BUS_USB_FLAG_V2   0x8000

// The constant below combines the PCI bus flags:
#define PCPS_BUS_USB_V2       ( PCPS_BUS_USB | PCPS_BUS_USB_FLAG_V2 )



/** A list of known radio clocks. */
enum PCPS_TYPES
{
  PCPS_TYPE_PC31,
  PCPS_TYPE_PS31_OLD,
  PCPS_TYPE_PS31,
  PCPS_TYPE_PC32,
  PCPS_TYPE_PCI32,
  PCPS_TYPE_GPS167PC,
  PCPS_TYPE_GPS167PCI,
  PCPS_TYPE_PCI509,
  PCPS_TYPE_GPS168PCI,
  PCPS_TYPE_PCI510,
  PCPS_TYPE_GPS169PCI,
  PCPS_TYPE_TCR510PCI,
  PCPS_TYPE_TCR167PCI,
  PCPS_TYPE_GPS170PCI,
  PCPS_TYPE_PCI511,
  PCPS_TYPE_TCR511PCI,
  PCPS_TYPE_PEX511,
  PCPS_TYPE_TCR511PEX,
  PCPS_TYPE_GPS170PEX,
  PCPS_TYPE_USB5131,
  PCPS_TYPE_TCR51USB,
  PCPS_TYPE_MSF51USB,
  PCPS_TYPE_PTP270PEX,
  PCPS_TYPE_FRC511PEX,
  PCPS_TYPE_TCR170PEX,
  PCPS_TYPE_WWVB51USB,
  PCPS_TYPE_GPS180PEX,
  PCPS_TYPE_TCR180PEX,
  PCPS_TYPE_DCF600USB,
  PCPS_TYPE_PZF180PEX,
  PCPS_TYPE_TCR600USB,
  PCPS_TYPE_MSF600USB,
  PCPS_TYPE_WVB600USB,
  N_PCPS_DEV_TYPE
};


#define PCPS_CLOCK_NAME_SZ   10   // including terminating 0

typedef uint16_t PCPS_DEV_ID;
typedef uint16_t PCPS_REF_TYPE;
typedef uint16_t PCPS_BUS_FLAGS;

/**
  The structure contains the characteristics of each
  of the clocks listed above. These fields are always the
  same for a single type of clock and do not change with
  firmware version, port address, etc.
  */
typedef struct
{
  uint16_t num;
  char name[PCPS_CLOCK_NAME_SZ];
  PCPS_DEV_ID dev_id;
  PCPS_REF_TYPE ref_type;
  PCPS_BUS_FLAGS bus_flags;
} PCPS_DEV_TYPE;



#if !defined( MBG_TGT_UNIX ) || defined( MBG_ARCH_X86 )
  typedef uint16_t PCPS_PORT_ADDR;
#else
  typedef uint64_t PCPS_PORT_ADDR;
#endif



/**
  The structure below describes an I/O port resource
  used by a clock.
*/
typedef struct
{
  PCPS_PORT_ADDR base;
  uint16_t num;
} PCPS_PORT_RSRC;

/** The max number of I/O port resources used by a clock. */
#define N_PCPS_PORT_RSRC 2



typedef struct
{
  MBG_MEM_ADDR user_virtual_address;
  #if defined( MBG_TGT_LINUX )
    uint64_t len;
    uint64_t pfn_offset;
  #else
    ulong len;
  #endif
} PCPS_MAPPED_MEM;



typedef uint32_t PCPS_ERR_FLAGS;  /**< see \ref group_err_flags "Error flags" */
typedef uint32_t PCPS_FEATURES;   /**< see \ref group_features "Features" */
typedef uint16_t PCPS_BUS_NUM;
typedef uint16_t PCPS_SLOT_NUM;

/**
  The structure below contains data which depends
  on a individual instance of the clock, e.g.
  the firmware which is currently installed, the
  port address which has been configured, etc.
*/
typedef struct
{
  PCPS_ERR_FLAGS err_flags;   /**< See \ref group_err_flags "Error flags" */
  PCPS_BUS_NUM bus_num;
  PCPS_SLOT_NUM slot_num;
  PCPS_PORT_RSRC port[N_PCPS_PORT_RSRC];
  uint16_t status_port;
  int16_t irq_num;
  uint32_t timeout_clk;
  uint16_t fw_rev_num;
  PCPS_FEATURES features;     /**< See \ref group_features "Feature flags" */
  PCPS_ID_STR fw_id;
  PCPS_SN_STR sernum;
} PCPS_DEV_CFG;

/** @defgroup group_err_flags Error flags in PCPS_DEV_CFG
  Flags used with PCPS_DEV_CFG::err_flags
 @{
*/
#define PCPS_EF_TIMEOUT         0x00000001   /**< timeout occured  */
#define PCPS_EF_INV_EPROM_ID    0x00000002   /**< invalid EPROM ID */
#define PCPS_EF_IO_INIT         0x00000004   /**< I/O intf not init'd */
#define PCPS_EF_IO_CFG          0x00000008   /**< I/O intf not cfg'd */
#define PCPS_EF_IO_ENB          0x00000010   /**< I/O intf not enabled */
#define PCPS_EF_IO_RSRC         0x00000020   /**< I/O not registered w/ rsrcmgr */
/** @} */

/** @defgroup group_features Feature flags used with PCPS_FEATURES

    Some features of the radio clocks have been introduced with
    specific firmware versions, so depending on the firmware version
    a clock may support a feature or not. The clock detection function
    checks the clock model and firmware version and updates the field
    PCPS_DEV_CFG::features accordingly. There are some macros which
    can easily be used to query whether a clock device actually
    supports a function, or not. The definitions define
    the possible features.
 @{
*/
enum
{
  PCPS_BIT_CAN_SET_TIME,
  PCPS_BIT_HAS_SERIAL,
  PCPS_BIT_HAS_SYNC_TIME,
  PCPS_BIT_HAS_TZDL,
  PCPS_BIT_HAS_IDENT,
  PCPS_BIT_HAS_UTC_OFFS,
  PCPS_BIT_HAS_HR_TIME,
  PCPS_BIT_HAS_SERNUM,

  PCPS_BIT_HAS_TZCODE,
  PCPS_BIT_HAS_CABLE_LEN,
  PCPS_BIT_HAS_EVENT_TIME,    // custom GPS firmware only
  PCPS_BIT_HAS_RECEIVER_INFO,
  PCPS_BIT_CAN_CLR_UCAP_BUFF,
  PCPS_BIT_HAS_PCPS_TZDL,
  PCPS_BIT_HAS_UCAP,
  PCPS_BIT_HAS_IRIG_TX,

  PCPS_BIT_HAS_GPS_DATA_16,   // use 16 bit size specifiers
  PCPS_BIT_HAS_SYNTH,
  PCPS_BIT_HAS_GENERIC_IO,
  PCPS_BIT_HAS_TIME_SCALE,
  PCPS_BIT_HAS_UTC_PARM,
  PCPS_BIT_HAS_IRIG_CTRL_BITS,
  PCPS_BIT_HAS_LAN_INTF,
  PCPS_BIT_HAS_PTP,

  PCPS_BIT_HAS_IRIG_TIME,
  PCPS_BIT_HAS_FAST_HR_TSTAMP,
  PCPS_BIT_HAS_RAW_IRIG_DATA,
  PCPS_BIT_HAS_PZF,           // can also demodulate DCF77 PZF
  PCPS_BIT_HAS_EVT_LOG,

  N_PCPS_FEATURE              // must not exceed 32 !!
};


#define PCPS_CAN_SET_TIME       ( 1UL << PCPS_BIT_CAN_SET_TIME )
#define PCPS_HAS_SERIAL         ( 1UL << PCPS_BIT_HAS_SERIAL )
#define PCPS_HAS_SYNC_TIME      ( 1UL << PCPS_BIT_HAS_SYNC_TIME )
#define PCPS_HAS_TZDL           ( 1UL << PCPS_BIT_HAS_TZDL )
#define PCPS_HAS_IDENT          ( 1UL << PCPS_BIT_HAS_IDENT )
#define PCPS_HAS_UTC_OFFS       ( 1UL << PCPS_BIT_HAS_UTC_OFFS )
#define PCPS_HAS_HR_TIME        ( 1UL << PCPS_BIT_HAS_HR_TIME )
#define PCPS_HAS_SERNUM         ( 1UL << PCPS_BIT_HAS_SERNUM )
#define PCPS_HAS_TZCODE         ( 1UL << PCPS_BIT_HAS_TZCODE )
#define PCPS_HAS_CABLE_LEN      ( 1UL << PCPS_BIT_HAS_CABLE_LEN )
#define PCPS_HAS_EVENT_TIME     ( 1UL << PCPS_BIT_HAS_EVENT_TIME )
#define PCPS_HAS_RECEIVER_INFO  ( 1UL << PCPS_BIT_HAS_RECEIVER_INFO )
#define PCPS_CAN_CLR_UCAP_BUFF  ( 1UL << PCPS_BIT_CAN_CLR_UCAP_BUFF )
#define PCPS_HAS_PCPS_TZDL      ( 1UL << PCPS_BIT_HAS_PCPS_TZDL )
#define PCPS_HAS_UCAP           ( 1UL << PCPS_BIT_HAS_UCAP )
#define PCPS_HAS_IRIG_TX        ( 1UL << PCPS_BIT_HAS_IRIG_TX )
#define PCPS_HAS_GPS_DATA_16    ( 1UL << PCPS_BIT_HAS_GPS_DATA_16 )
#define PCPS_HAS_SYNTH          ( 1UL << PCPS_BIT_HAS_SYNTH )
#define PCPS_HAS_GENERIC_IO     ( 1UL << PCPS_BIT_HAS_GENERIC_IO )
#define PCPS_HAS_TIME_SCALE     ( 1UL << PCPS_BIT_HAS_TIME_SCALE )
#define PCPS_HAS_UTC_PARM       ( 1UL << PCPS_BIT_HAS_UTC_PARM )
#define PCPS_HAS_IRIG_CTRL_BITS ( 1UL << PCPS_BIT_HAS_IRIG_CTRL_BITS )
#define PCPS_HAS_LAN_INTF       ( 1UL << PCPS_BIT_HAS_LAN_INTF )
#define PCPS_HAS_PTP            ( 1UL << PCPS_BIT_HAS_PTP )
#define PCPS_HAS_IRIG_TIME      ( 1UL << PCPS_BIT_HAS_IRIG_TIME )
#define PCPS_HAS_FAST_HR_TSTAMP ( 1UL << PCPS_BIT_HAS_FAST_HR_TSTAMP )
#define PCPS_HAS_RAW_IRIG_DATA  ( 1UL << PCPS_BIT_HAS_RAW_IRIG_DATA )
#define PCPS_HAS_PZF            ( 1UL << PCPS_BIT_HAS_PZF )
#define PCPS_HAS_EVT_LOG        ( 1UL << PCPS_BIT_HAS_EVT_LOG )



#define PCPS_FEATURE_NAMES    \
{                             \
  "PCPS_CAN_SET_TIME",        \
  "PCPS_HAS_SERIAL",          \
  "PCPS_HAS_SYNC_TIME",       \
  "PCPS_HAS_TZDL",            \
  "PCPS_HAS_IDENT",           \
  "PCPS_HAS_UTC_OFFS",        \
  "PCPS_HAS_HR_TIME",         \
  "PCPS_HAS_SERNUM",          \
  "PCPS_HAS_TZCODE",          \
  "PCPS_HAS_CABLE_LEN",       \
  "PCPS_HAS_EVENT_TIME",      \
  "PCPS_HAS_RECEIVER_INFO",   \
  "PCPS_CAN_CLR_UCAP_BUFF",   \
  "PCPS_HAS_PCPS_TZDL",       \
  "PCPS_HAS_UCAP",            \
  "PCPS_HAS_IRIG_TX",         \
  "PCPS_HAS_GPS_DATA_16",     \
  "PCPS_HAS_SYNTH",           \
  "PCPS_HAS_GENERIC_IO",      \
  "PCPS_HAS_TIME_SCALE",      \
  "PCPS_HAS_UTC_PARM",        \
  "PCPS_HAS_IRIG_CTRL_BITS",  \
  "PCPS_HAS_LAN_INTF",        \
  "PCPS_HAS_PTP",             \
  "PCPS_HAS_IRIG_TIME",       \
  "PCPS_HAS_FAST_HR_TSTAMP",  \
  "PCPS_HAS_RAW_IRIG_DATA",   \
  "PCPS_HAS_PZF",             \
  "PCPS_HAS_EVT_LOG"          \
}

/** @} */



// The constants below define those features which are available
// in ALL firmware versions which have been shipped with a
// specific clock.

#define PCPS_FEAT_PC31PS31  0

// Some of the features are available in all newer clocks,
// so these have been put together in one definition:
#define PCPS_FEAT_LVL2      ( PCPS_CAN_SET_TIME   \
                            | PCPS_HAS_SERIAL     \
                            | PCPS_HAS_SYNC_TIME  \
                            | PCPS_HAS_UTC_OFFS )

#define PCPS_FEAT_PC32      ( PCPS_FEAT_LVL2 )

#define PCPS_FEAT_PCI32     ( PCPS_FEAT_LVL2 )

#define PCPS_FEAT_PCI509    ( PCPS_FEAT_LVL2 \
                            | PCPS_HAS_SERNUM \
                            | PCPS_HAS_TZCODE )

#define PCPS_FEAT_PCI510    ( PCPS_FEAT_PCI509 )

#define PCPS_FEAT_PCI511    ( PCPS_FEAT_PCI510 )

#define PCPS_FEAT_GPS167PC  ( PCPS_FEAT_LVL2 \
                            | PCPS_HAS_TZDL \
                            | PCPS_HAS_IDENT )

#define PCPS_FEAT_GPS167PCI ( PCPS_FEAT_LVL2 \
                            | PCPS_HAS_TZDL  \
                            | PCPS_HAS_IDENT \
                            | PCPS_HAS_HR_TIME )

#define PCPS_FEAT_GPS168PCI ( PCPS_FEAT_LVL2 \
                            | PCPS_HAS_TZDL  \
                            | PCPS_HAS_IDENT \
                            | PCPS_HAS_HR_TIME \
                            | PCPS_HAS_CABLE_LEN \
                            | PCPS_HAS_RECEIVER_INFO )

#define PCPS_FEAT_GPS169PCI ( PCPS_FEAT_GPS168PCI \
                            | PCPS_CAN_CLR_UCAP_BUFF \
                            | PCPS_HAS_UCAP )

#define PCPS_FEAT_GPS170PCI ( PCPS_FEAT_GPS169PCI \
                            | PCPS_HAS_IRIG_TX \
                            | PCPS_HAS_GPS_DATA_16 \
                            | PCPS_HAS_GENERIC_IO )

#define PCPS_FEAT_TCR510PCI ( PCPS_FEAT_LVL2 \
                            | PCPS_HAS_SERNUM )

#define PCPS_FEAT_TCR167PCI ( PCPS_FEAT_LVL2 \
                            | PCPS_HAS_SERNUM \
                            | PCPS_HAS_TZDL \
                            | PCPS_HAS_HR_TIME \
                            | PCPS_HAS_RECEIVER_INFO \
                            | PCPS_CAN_CLR_UCAP_BUFF \
                            | PCPS_HAS_UCAP \
                            | PCPS_HAS_IRIG_TX \
                            | PCPS_HAS_GPS_DATA_16 \
                            | PCPS_HAS_GENERIC_IO )

#define PCPS_FEAT_TCR511PCI ( PCPS_FEAT_TCR510PCI \
                            | PCPS_HAS_HR_TIME )

#define PCPS_FEAT_PEX511    ( PCPS_FEAT_PCI511 )

#define PCPS_FEAT_TCR511PEX ( PCPS_FEAT_TCR511PCI )

#define PCPS_FEAT_GPS170PEX ( PCPS_FEAT_GPS170PCI )

#define PCPS_FEAT_USB5131   ( PCPS_HAS_UTC_OFFS  \
                            | PCPS_HAS_SERNUM    \
                            | PCPS_HAS_SYNC_TIME \
                            | PCPS_HAS_HR_TIME   \
                            | PCPS_CAN_SET_TIME  \
                            | PCPS_HAS_TZCODE )

#define PCPS_FEAT_TCR51USB  ( PCPS_HAS_UTC_OFFS  \
                            | PCPS_HAS_SERNUM    \
                            | PCPS_HAS_SYNC_TIME \
                            | PCPS_HAS_HR_TIME   \
                            | PCPS_CAN_SET_TIME )

#define PCPS_FEAT_MSF51USB  ( PCPS_HAS_UTC_OFFS  \
                            | PCPS_HAS_SERNUM    \
                            | PCPS_HAS_SYNC_TIME \
                            | PCPS_HAS_HR_TIME   \
                            | PCPS_CAN_SET_TIME )

#define PCPS_FEAT_PTP270PEX ( PCPS_HAS_SERNUM    \
                            | PCPS_HAS_SYNC_TIME \
                            | PCPS_HAS_HR_TIME   \
                            | PCPS_HAS_RECEIVER_INFO \
                            | PCPS_CAN_SET_TIME  \
                            | PCPS_CAN_CLR_UCAP_BUFF \
                            | PCPS_HAS_UCAP \
                            | PCPS_HAS_GPS_DATA_16 )

#define PCPS_FEAT_FRC511PEX ( PCPS_HAS_SERNUM    \
                            | PCPS_HAS_HR_TIME   \
                            | PCPS_HAS_RECEIVER_INFO \
                            | PCPS_CAN_SET_TIME  \
                            | PCPS_CAN_CLR_UCAP_BUFF \
                            | PCPS_HAS_UCAP \
                            | PCPS_HAS_GPS_DATA_16 )

#define PCPS_FEAT_TCR170PEX ( PCPS_FEAT_TCR167PCI )

#define PCPS_FEAT_WWVB51USB ( PCPS_FEAT_MSF51USB )

#define PCPS_FEAT_GPS180PEX ( PCPS_FEAT_GPS170PEX | PCPS_HAS_FAST_HR_TSTAMP )

#define PCPS_FEAT_TCR180PEX ( PCPS_FEAT_TCR170PEX | PCPS_HAS_FAST_HR_TSTAMP )

#define PCPS_FEAT_DCF600USB ( PCPS_FEAT_USB5131 )

#define PCPS_FEAT_PZF180PEX ( PCPS_FEAT_LVL2 \
                            | PCPS_HAS_TZDL \
                            | PCPS_HAS_HR_TIME \
                            | PCPS_HAS_SERNUM \
                            | PCPS_HAS_RECEIVER_INFO \
                            | PCPS_CAN_CLR_UCAP_BUFF \
                            | PCPS_HAS_UCAP \
                            | PCPS_HAS_GPS_DATA_16 \
                            | PCPS_HAS_GENERIC_IO \
                            | PCPS_HAS_UTC_PARM \
                            | PCPS_HAS_PZF )

#define PCPS_FEAT_TCR600USB ( PCPS_FEAT_TCR51USB \
                            | PCPS_HAS_IRIG_CTRL_BITS \
                            | PCPS_HAS_IRIG_TIME \
                            | PCPS_HAS_RAW_IRIG_DATA )

#define PCPS_FEAT_MSF600USB ( PCPS_FEAT_MSF51USB )

#define PCPS_FEAT_WVB600USB ( PCPS_FEAT_WWVB51USB )

// Some features of the API used to access Meinberg plug-in devices
// have been implemented starting with the special firmware revision
// numbers defined below.
//
// If no number is specified for a feature/clock model then the feature
// is either always supported by that clock model, or not at all.


// There are some versions of PCI Express cards out there which do not
// safely support hardware IRQs. The following firmware versions are required 
// for safe IRQ operation:
#define REV_HAS_IRQ_FIX_MINOR_PEX511     0x0106
#define REV_HAS_IRQ_FIX_MINOR_TCR511PEX  0x0105
#define REV_HAS_IRQ_FIX_MINOR_GPS170PEX  0x0104
// Additionally there are certain revisions of the bus interface logic 
// required. The associated version codes are defined in pci_asic.h.

// The macro below can be used to check whether the required versions are there:
#define _pcps_pex_irq_is_safe( _curr_fw_ver, _req_fw_ver, _curr_asic_ver,    \
                               _req_asic_ver_major, _req_asic_ver_minor )    \
  ( ( (_curr_fw_ver) >= (_req_fw_ver) ) && _pcps_asic_version_greater_equal( \
    (_curr_asic_ver), (_req_asic_ver_major), (_req_asic_ver_minor ) )        \
  )

/* command PCPS_GIVE_RAW_IRIG_DATA: */
#define REV_HAS_RAW_IRIG_DATA_TCR511PEX 0x0111
#define REV_HAS_RAW_IRIG_DATA_TCR511PCI 0x0111
#define REV_HAS_RAW_IRIG_DATA_TCR51USB  0x0106

/* command PCPS_GIVE_IRIG_TIME: */
#define REV_HAS_IRIG_TIME_TCR511PEX 0x0109
#define REV_HAS_IRIG_TIME_TCR511PCI 0x0109
#define REV_HAS_IRIG_TIME_TCR51USB  0x0106

/* command PCPS_GET_IRIG_CTRL_BITS: */
#define REV_HAS_IRIG_CTRL_BITS_TCR511PEX 0x0107
#define REV_HAS_IRIG_CTRL_BITS_TCR511PCI 0x0107
#define REV_HAS_IRIG_CTRL_BITS_TCR51USB  0x0106

/* This board uses the GPS_DATA interface with 16 bit buffer sizes 
   instead of the original 8 bit sizes, thus allowing to transfer 
   data blocks which exceed 255 bytes (PCPS_HAS_GPS_DATA_16) */
#define REV_HAS_GPS_DATA_16_GPS169PCI    0x0202

/* the clock supports a higher baud rate than N_PCPS_BD_DCF */
#define REV_HAS_SERIAL_HS_PCI509         0x0104

/* commands PCPS_GIVE_UCAP_ENTRIES, PCPS_GIVE_UCAP_EVENT */
#define REV_HAS_UCAP_GPS167PCI           0x0421
#define REV_HAS_UCAP_GPS168PCI           0x0104

/* command PCPS_CLR_UCAP_BUFF */
#define REV_CAN_CLR_UCAP_BUFF_GPS167PCI  0x0419
#define REV_CAN_CLR_UCAP_BUFF_GPS168PCI  0x0101

/* commands PCPS_READ_GPS_DATA and PCPS_WRITE_GPS_DATA with */
/* code PC_GPS_ANT_CABLE_LEN */
#define REV_HAS_CABLE_LEN_GPS167PCI      0x0411
#define REV_HAS_CABLE_LEN_GPS167PC       0x0411

/* command PCPS_GIVE_HR_TIME, structure PCPS_HR_TIME: */
#define REV_HAS_HR_TIME_GPS167PC         0x0305
#define REV_HAS_HR_TIME_TCR510PCI        0x0200
#define REV_HAS_HR_TIME_PEX511           0x0105  // This also requires a certain ASIC version.
#define REV_HAS_HR_TIME_PCI511           0x0103

/* field offs_utc in structure PCPS_TIME: */
#define REV_HAS_UTC_OFFS_PC31PS31        0x0300

/* command PCPS_GIVE_SYNC_TIME: */
#define REV_HAS_SYNC_TIME_PC31PS31       0x0300

/* command PCPS_GET_SERIAL, PCPS_SET_SERIAL: */
#define REV_HAS_SERIAL_PC31PS31          0x0300

/* command PCPS_GIVE_TIME_NOCLEAR: */
#define REV_GIVE_TIME_NOCLEAR_PC31PS31   0x0300

/* status bit PCPS_LS_ANN: */
#define REV_PCPS_LS_ANN_PC31PS31         0x0300

/* status bit PCPS_IFTM: */
#define REV_PCPS_IFTM_PC31PS31           0x0300

/* command PCPS_SET_TIME: */
#define REV_CAN_SET_TIME_PC31PS31        0x0240

/* command PCPS_GIVE_TIME_NOCLEAR: */
// This is supported by all clocks but PC31/PS31 with
// firmware versions before v3.0. If such a card shall
// be used then the firmware should be updated to the
// last recent version.


/**
 The structure has been defined to pass all
 information on a clock device from a device driver
 to a user program. */
typedef struct
{
  PCPS_DEV_TYPE type;
  PCPS_DEV_CFG cfg;
} PCPS_DEV;


// The macros below simplify access to the data
// stored in PCPS_DEV structure and should be used
// to extract the desired information.
// If the formal parameter is called _d then a pointer
// to device structure PCPS_DEV is expected.
// If the formal parameter is called _c then a pointer
// to configuration structure PCPS_DEV_CFG is expected.

// Access device type information:
#define _pcps_type_num( _d )     ( (_d)->type.num )
#define _pcps_type_name( _d )    ( (_d)->type.name )
#define _pcps_dev_id( _d )       ( (_d)->type.dev_id )
#define _pcps_ref_type( _d )     ( (_d)->type.ref_type )
#define _pcps_bus_flags( _d )    ( (_d)->type.bus_flags )

// Query device type features:
#define _pcps_is_gps( _d )       ( _pcps_ref_type( _d ) == PCPS_REF_GPS )
#define _pcps_is_dcf( _d )       ( _pcps_ref_type( _d ) == PCPS_REF_DCF )
#define _pcps_is_msf( _d )       ( _pcps_ref_type( _d ) == PCPS_REF_MSF )
#define _pcps_is_wwvb( _d )      ( _pcps_ref_type( _d ) == PCPS_REF_WWVB )
#define _pcps_is_irig_rx( _d )   ( _pcps_ref_type( _d ) == PCPS_REF_IRIG )
#define _pcps_is_ptp( _d )       ( _pcps_ref_type( _d ) == PCPS_REF_PTP )
#define _pcps_is_frc( _d )       ( _pcps_ref_type( _d ) == PCPS_REF_FRC )

#define _pcps_is_lwr( _d )       ( _pcps_is_dcf( _d ) || _pcps_is_msf( _d ) || _pcps_is_wwvb( _d ) )

// Generic bus types:
#define _pcps_is_isa( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_ISA )
#define _pcps_is_mca( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_MCA )
#define _pcps_is_pci( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_PCI )
#define _pcps_is_usb( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_USB )

// Special bus types:
#define _pcps_is_usb_v2( _d )       ( _pcps_bus_flags( _d ) == PCPS_BUS_USB_V2 )
#define _pcps_is_pci_s5933( _d )    ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_S5933 )
#define _pcps_is_pci_s5920( _d )    ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_S5920 )
#define _pcps_is_pci_amcc( _d )     ( _pcps_is_pci_s5920( _d ) || _pcps_is_pci_s5933( _d )  )
#define _pcps_is_pci_asic( _d )     ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_ASIC )
#define _pcps_is_pci_pex8311( _d )  ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_PEX8311 )
#define _pcps_is_pci_mbgpex( _d )   ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_MBGPEX )


// Access device configuration information:
#define _pcps_bus_num( _d )            ( (_d)->cfg.bus_num )
#define _pcps_slot_num( _d )           ( (_d)->cfg.slot_num )

#define _pcps_cfg_port_rsrc( _c, _n )  ( (_c)->port[_n] )
#define _pcps_port_rsrc( _d, _n )      _pcps_cfg_port_rsrc( &(_d)->cfg, (_n) )
#define _pcps_port_rsrc_unused( _d )   ( (_d)->base == 0 || (_d)->num == 0 )

#define _pcps_cfg_port_base( _c, _n )  ( _pcps_cfg_port_rsrc( (_c), (_n) ).base )
#define _pcps_port_base( _d, _n )      ( _pcps_port_rsrc( (_d), (_n) ).base )

#define _pcps_cfg_irq_num( _c )        ( (_c)->irq_num )
#define _pcps_irq_num( _d )            _pcps_cfg_irq_num( &(_d)->cfg )

#define _pcps_cfg_timeout_clk( _c )    ( (_c)->timeout_clk )
#define _pcps_timeout_clk( _d )        _pcps_cfg_timeout_clk( &(_d)->cfg )

#define _pcps_fw_rev_num( _d )         ( (_d)->cfg.fw_rev_num )
#define _pcps_features( _d )           ( (_d)->cfg.features )
#define _pcps_fw_id( _d )              ( (_d)->cfg.fw_id )
#define _pcps_sernum( _d )             ( (_d)->cfg.sernum )


// The macros below handle the device's err_flags.
#define _pcps_err_flags( _d )           ( (_d)->cfg.err_flags )
#define _pcps_chk_err_flags( _d, _msk ) ( _pcps_err_flags( _d ) & (_msk) )
#define _pcps_set_err_flags( _d, _msk ) ( _pcps_err_flags( _d ) |= (_msk) )
#define _pcps_clr_err_flags( _d, _msk ) ( _pcps_err_flags( _d ) &= ~(_msk) )


// Query whether a special feature is supported:
#define _pcps_has_feature( _d, _f )    ( ( (_d)->cfg.features & (_f) ) != 0 )

// Query whether a special feature is supported according to RECEIVER_INFO:
#define _pcps_has_ri_feature( _p_ri, _f )    ( ( (_p_ri)->features & (_f) ) != 0 )


#define _pcps_can_set_time( _d )   _pcps_has_feature( (_d), PCPS_CAN_SET_TIME )
#define _pcps_has_serial( _d )     _pcps_has_feature( (_d), PCPS_HAS_SERIAL )
#define _pcps_has_sync_time( _d )  _pcps_has_feature( (_d), PCPS_HAS_SYNC_TIME )
#define _pcps_has_ident( _d )      _pcps_has_feature( (_d), PCPS_HAS_IDENT )
#define _pcps_has_utc_offs( _d )   _pcps_has_feature( (_d), PCPS_HAS_UTC_OFFS )
#define _pcps_has_hr_time( _d )    _pcps_has_feature( (_d), PCPS_HAS_HR_TIME )
#define _pcps_has_sernum( _d )     _pcps_has_feature( (_d), PCPS_HAS_SERNUM )
#define _pcps_has_cab_len( _d )    _pcps_has_feature( (_d), PCPS_HAS_CABLE_LEN )
#define _pcps_has_tzdl( _d )       _pcps_has_feature( (_d), PCPS_HAS_TZDL )
#define _pcps_has_pcps_tzdl( _d )  _pcps_has_feature( (_d), PCPS_HAS_PCPS_TZDL )
#define _pcps_has_tzcode( _d )     _pcps_has_feature( (_d), PCPS_HAS_TZCODE )
#define _pcps_has_tz( _d )         _pcps_has_feature( (_d), PCPS_HAS_TZDL \
                                                          | PCPS_HAS_PCPS_TZDL \
                                                          | PCPS_HAS_TZCODE )
// The next one is supported only with a certain GPS firmware version:
#define _pcps_has_event_time( _d ) _pcps_has_feature( (_d), PCPS_HAS_EVENT_TIME )
#define _pcps_has_receiver_info( _d ) _pcps_has_feature( (_d), PCPS_HAS_RECEIVER_INFO )
#define _pcps_can_clr_ucap_buff( _d ) _pcps_has_feature( (_d), PCPS_CAN_CLR_UCAP_BUFF )
#define _pcps_has_ucap( _d )       _pcps_has_feature( (_d), PCPS_HAS_UCAP )
#define _pcps_has_irig_tx( _d )    _pcps_has_feature( (_d), PCPS_HAS_IRIG_TX )

// The macro below determines whether a DCF77 clock
// supports a higher baud rate than standard
#define _pcps_has_serial_hs( _d ) \
  ( ( _pcps_type_num( _d ) == PCPS_TYPE_TCR511PEX ) || \
    ( _pcps_type_num( _d ) == PCPS_TYPE_PEX511 )    || \
    ( _pcps_type_num( _d ) == PCPS_TYPE_TCR511PCI ) || \
    ( _pcps_type_num( _d ) == PCPS_TYPE_TCR510PCI ) || \
    ( _pcps_type_num( _d ) == PCPS_TYPE_PCI511 )    || \
    ( _pcps_type_num( _d ) == PCPS_TYPE_PCI510 )    || \
    ( _pcps_type_num( _d ) == PCPS_TYPE_PCI509 &&      \
      _pcps_fw_rev_num( _d ) >= REV_HAS_SERIAL_HS_PCI509 ) )


#define _pcps_has_signal( _d ) \
  ( _pcps_is_dcf( _d ) || _pcps_is_msf( _d ) || _pcps_is_wwvb( _d ) || _pcps_is_irig_rx( _d )  )

#define _pcps_has_mod( _d ) \
  ( _pcps_is_dcf( _d ) || _pcps_is_msf( _d ) || _pcps_is_wwvb( _d ) )

#define _pcps_has_irig( _d ) \
  ( _pcps_is_irig_rx( _d ) || _pcps_has_irig_tx( _d ) )

#define _pcps_has_irig_ctrl_bits( _d ) \
  _pcps_has_feature( (_d), PCPS_HAS_IRIG_CTRL_BITS )

#define _pcps_has_irig_time( _d ) \
  _pcps_has_feature( (_d), PCPS_HAS_IRIG_TIME )

#define _pcps_has_raw_irig_data( _d ) \
  _pcps_has_feature( (_d), PCPS_HAS_RAW_IRIG_DATA )

#define _pcps_has_ref_offs( _d ) \
  _pcps_is_irig_rx( _d )

#define _pcps_ref_offs_out_of_range( _n ) \
  ( ( (_n) > MBG_REF_OFFS_MAX ) || ( (_n) < -MBG_REF_OFFS_MAX ) )

#define _pcps_has_opt_flags( _d ) \
  _pcps_is_irig_rx( _d )

#define _pcps_has_gps_data_16( _d )  _pcps_has_feature( (_d), PCPS_HAS_GPS_DATA_16 )

#define _pcps_has_gps_data( _d ) \
  ( _pcps_is_gps( _d ) || _pcps_has_gps_data_16( _d ) )

#define _pcps_has_synth( _d )  _pcps_has_feature( (_d), PCPS_HAS_SYNTH )

#define _pcps_has_generic_io( _d )  _pcps_has_feature( (_d), PCPS_HAS_GENERIC_IO )

#define _pcps_has_time_scale( _d )  _pcps_has_feature( (_d), PCPS_HAS_TIME_SCALE )

#define _pcps_has_utc_parm( _d )  _pcps_has_feature( (_d), PCPS_HAS_UTC_PARM )

#define _pcps_has_asic_version( _d ) ( _pcps_is_pci_asic( _d ) \
                                    || _pcps_is_pci_pex8311( _d ) \
                                    || _pcps_is_pci_mbgpex( _d ) )

#define _pcps_has_asic_features( _d ) _pcps_has_asic_version( _d )

#define _pcps_has_fast_hr_timestamp( _d )  _pcps_has_feature( (_d), PCPS_HAS_FAST_HR_TSTAMP )

#define _pcps_has_lan_intf( _d )  _pcps_has_feature( (_d), PCPS_HAS_LAN_INTF )

#define _pcps_has_ptp( _d )  _pcps_has_feature( (_d), PCPS_HAS_PTP )

#define _pcps_has_ri_ptp_unicast( _p_ri )  _pcps_has_ri_feature( (_p_ri), GPS_HAS_PTP_UNICAST )

#define _pcps_has_pzf( _d )  _pcps_has_feature( (_d), PCPS_HAS_PZF )

#define _pcps_has_corr_info( _d )  _pcps_has_pzf( _d )

#define _pcps_has_tr_distance( _d )  _pcps_has_pzf( _d )

#define _pcps_has_evt_log( _d ) _pcps_has_feature( (_d), PCPS_HAS_EVT_LOG )

#define _pcps_has_debug_status( _d ) _pcps_is_irig_rx( _d )

#define _pcps_has_stat_info( _d )  ( _pcps_is_gps( _d ) || _pcps_has_pzf( _d ) )

#define _pcps_has_stat_info_mode( _d )  _pcps_is_gps( _d )

#define _pcps_has_stat_info_svs( _d )  _pcps_is_gps( _d )



// There are some versions of IRIG receiver cards which ignore the TFOM code
// of an incoming IRIG signal even if an IRIG code has been configured which
// supports this. In this case these cards synchronize to the incoming IRIG
// signal even if the TFOM code reports the IRIG generator is not synchronized.
// The intended behaviour is that the IRIG receiver card changes its status
// to "freewheeling" in this case, unless it has been configured to ignore
// the TFOM code of the incoming IRIG signal (see the IFLAGS_DISABLE_TFOM flag
// defined in gpsdefs.h).

// The macro below can be used to check based on the device info if a specific
// card with a specific firmware always ignores the TFOM code:
#define _pcps_incoming_tfom_ignored( _d ) \
  ( ( ( _pcps_type_num( _d ) == PCPS_TYPE_TCR167PCI ) && ( _pcps_fw_rev_num( _d ) <= 0x121 ) ) \
 || ( ( _pcps_type_num( _d ) == PCPS_TYPE_TCR170PEX ) && ( _pcps_fw_rev_num( _d ) <= 0x103 ) ) )


// Some Meinberg PCI Express cards have a PCIe interface chip with an extra
// PCI bridge built into the chip. Unfortunately there are some mainboards out there
// which do not handle PCI resources behind this PCI bridge correctly. The symptom is
// usually that both I/O address ranges of these cards get the same base address
// assigned by the BIOS, and the efeect is that in this case a card is not accessible
// properly, since both I/O ranges try to respond to the same I/O addresses.
// As a consequence data read from the card is usually garbage.
// The only known fix for this is a BIOS update for the mainboard which makes the
// BIOS handle the card's resources properly.

// The macro below can be used to test if both port base addresses assigned to a card
// are identical, and thus the BIOS is probably faulty::
#define _pcps_pci_cfg_err( _d ) \
  ( _pcps_is_pci( _d ) && ( _pcps_port_base( _d, 1 ) == _pcps_port_base( _d, 0 ) ) )



// There are some versions of GPS PCI firmware which may occasionally return
// a HR time stamp which is wrong by 20 milliseconds, if the HR time is read
// right after some GPS data. As a workaround for that bug an application 
// must wait at least 1.5 ms and then just read the PCPS_TIME structure 
// in order to re-initialize the software interface state.
// This has been fixed in more recent versions of the affected firmware,
// but this macro can be used to let an application determine whether it
// must account for this bug with a given card and firmware version.
#define _must_do_fw_workaround_20ms( _d )                                               \
(                                                                                       \
  ( _pcps_type_num( _d ) == PCPS_TYPE_GPS168PCI && _pcps_fw_rev_num( _d ) < 0x0102 ) || \
  ( _pcps_type_num( _d ) == PCPS_TYPE_GPS167PCI && _pcps_fw_rev_num( _d ) < 0x0420 )    \
)



/**
  The structure is used to return info
  on the device driver.*/
typedef struct
{
  uint16_t ver_num;    /**< the device driver's version number */
  uint16_t n_devs;     /**< the number of radio clocks handled by the driver */
  PCPS_ID_STR id_str;  /**< the device driver's ID string */
} PCPS_DRVR_INFO;



// The macros below can be used to mark a PCPS_TIME variable
// as unread, i.e. its contents have not been read from the clock,
// and to check if such a variable is marked as unread.
#define _pcps_time_set_unread( _t )       do { (_t)->sec = 0xFF; } while ( 0 )
#define _pcps_time_is_read( _t )          ( (uchar) (_t)->sec != 0xFF )



/**
  The structure is used to read the current time from
  a device, combined with an associated PC cycle counter value
  to compensate program execution time.
  */
typedef struct
{
  MBG_PC_CYCLES cycles;
  PCPS_TIME t;
} PCPS_TIME_CYCLES;



/**
  The structure is used to read a high resolution UTC time stamp 
  plus associated PC cycles counter value to compensate the latency.
  */
typedef struct
{
  MBG_PC_CYCLES cycles;
  PCPS_TIME_STAMP tstamp;     /**< High resolution time stamp (UTC) */
} PCPS_TIME_STAMP_CYCLES;

#define _mbg_swab_pcps_time_stamp_cycles( _p ) \
{                                              \
  _mbg_swab_mbg_pc_cycles( &(_p)->cycles );    \
  _mbg_swab_pcps_time_stamp( &(_p)->tstamp );  \
}



/**
  The structure is used to read the current high resolution time 
  from a device, combined with an associated PC cycle counter value
  to compensate program execution time.
  */
typedef struct
{
  MBG_PC_CYCLES cycles;
  PCPS_HR_TIME t;
} PCPS_HR_TIME_CYCLES;

#define _mbg_swab_pcps_hr_time_cycles( _p ) \
{                                           \
  _mbg_swab_mbg_pc_cycles( &(_p)->cycles ); \
  _mbg_swab_pcps_hr_time( &(_p)->t );       \
}



/**
  The structure below can be used to let the kernel driver read
  the current system time plus the associated HR time from a plugin card
  as close as possibly, and return the results to a user space application
  which can then compute the time difference and latencies.
  This structure also contains the card's status information (e.g. sync status).
  */
typedef struct
{
  PCPS_HR_TIME_CYCLES ref_hr_time_cycles;  /**< HR time read from the card, plus cycles */
  MBG_SYS_TIME_CYCLES sys_time_cycles;     /**< system timestamp plus associated cycles */
} MBG_TIME_INFO_HRT;

#define _mbg_swab_mbg_time_info_hrt( _p )                     \
{                                                             \
  _mbg_swab_pcps_hr_time_cycles( &(_p)->ref_hr_time_cycles ); \
  _mbg_swab_mbg_sys_time_cycles( &(_p)->sys_time_cycles );    \
}



/**
  The structure below can be used to let the kernel driver read
  the current system time plus an associated HR timestamp from a plugin card
  as close as possibly, and return the results to a user space application
  which can then compute the time difference and latencies.
  Since the card's time stamp is usually taken using the fast memory mapped
  access this structure does *not* contain the card's status information 
  (e.g. sync status).
  */
typedef struct
{
  PCPS_TIME_STAMP_CYCLES ref_tstamp_cycles;  /**< HR timestamp from the card, plus cycles */
  MBG_SYS_TIME_CYCLES sys_time_cycles;       /**< system timestamp plus associated cycles */
} MBG_TIME_INFO_TSTAMP;

#define _mbg_swab_mbg_time_info_tstamp( _p )                    \
{                                                               \
  _mbg_swab_pcps_time_stamp_cycles( &(_p)->ref_tstamp_cycles ); \
  _mbg_swab_mbg_sys_time_cycles( &(_p)->sys_time_cycles );      \
}



typedef uint32_t PCPS_IRQ_STAT_INFO;

// Flags used with PCPS_IRQ_STAT_INFO:
#define PCPS_IRQ_STAT_ENABLE_CALLED  0x01
#define PCPS_IRQ_STAT_ENABLED        0x02
#define PCPS_IRQ_STAT_UNSAFE         0x04  // IRQs unsafe with this firmeware version / ASIC

#define PCPS_IRQ_STATE_DANGER        ( PCPS_IRQ_STAT_ENABLED | PCPS_IRQ_STAT_UNSAFE )

#define _pcps_fw_rev_num_major( _v ) \
  ( ( (_v) >> 8 ) & 0xFF )

#define _pcps_fw_rev_num_minor( _v ) \
  ( (_v) & 0xFF )


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */

#undef _ext

#endif  /* _PCPSDEV_H */

