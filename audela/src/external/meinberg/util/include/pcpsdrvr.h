
/**************************************************************************
 *
 *  $Id: pcpsdrvr.h 1.41.1.39 2011/11/25 15:03:24 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for pcpsdrvr.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsdrvr.h $
 *  Revision 1.41.1.39  2011/11/25 15:03:24  martin
 *  Support on-board event logs.
 *  Revision 1.41.1.38  2011/11/22 16:27:47  martin
 *  New macro _pcps_ddev_has_debug_status().
 *  Revision 1.41.1.37  2011/10/28 13:51:15  martin
 *  Added some macros to test if specific stat_info stuff is supported.
 *  Revision 1.41.1.36  2011/10/21 14:07:29  martin
 *  Revision 1.41.1.35  2011/09/09 12:47:13  martin
 *  Fixes for DOS.
 *  Revision 1.41.1.34  2011/07/19 12:48:39Z  martin
 *  Updated function prototypes.
 *  Code cleanup.
 *  Revision 1.41.1.33  2011/07/06 11:23:09  martin
 *  Added macros _pcps_ddev_has_corr_info() and _pcps_ddev_has_tr_distance().
 *  Revision 1.41.1.32  2011/07/04 10:29:44  martin
 *  Modified a comment.
 *  Revision 1.41.1.31  2011/06/29 14:01:32  martin
 *  Renamed PZF600PEX to PZF180PEX.
 *  Added support for TCR600USB, MSF600USB, and WVB600USB.
 *  New macros _pcps_ddev_is_usb_v2() and _pcps_ddev_has_pcf().
 *  Updated some comments.
 *  Revision 1.41.1.30  2011/06/29 09:10:27  martin
 *  Renamed PZF600PEX to PZF180PEX.
 *  Revision 1.41.1.29  2011/05/31 14:24:18  martin
 *  Revision 1.41.1.28  2011/05/16 16:39:20  martin
 *  Allocate non-paged memory under Windows.
 *  Revision 1.41.1.27  2011/05/06 13:47:40Z  martin
 *  Support PZF600PEX.
 *  Revision 1.41.1.26  2011/04/12 15:50:57  martin
 *  Revision 1.41.1.25  2011/04/12 15:26:10Z  martin
 *  Moved mutex definitions to new mbgmutex.h.
 *  Revision 1.41.1.24  2011/04/01 13:32:45  martin
 *  Added missing mutex destroy for Windows.
 *  Revision 1.41.1.23  2011/04/01 10:38:42Z  martin
 *  Support mutex/spinlock destroy.
 *  Revision 1.41.1.22  2011/03/31 10:35:57  martin
 *  Fixed a typo.
 *  Revision 1.41.1.21  2011/03/28 09:53:52Z  martin
 *  Modifications for NetBSD from Frank Kardel.
 *  Revision 1.41.1.20  2011/03/25 11:11:44  martin
 *  Optionally support timespec for sys time (USE_TIMESPEC).
 *  Started to support NetBSD.
 *  Revision 1.41.1.19  2011/02/15 14:24:58  martin
 *  Revision 1.41.1.18  2011/02/09 17:08:31  martin
 *  Specify I/O range number when calling port I/O macros
 *  so they can be used for different ranges under BSD.
 *  Revision 1.41.1.17  2011/02/04 14:44:46  martin
 *  Revision 1.41.1.16  2011/02/04 10:10:18  martin
 *  Revision 1.41.1.15  2011/02/02 12:20:42  martin
 *  Revision 1.41.1.14  2011/02/01 17:12:05  martin
 *  Revision 1.41.1.13  2011/02/01 14:49:43  martin
 *  Revision 1.41.1.12  2011/02/01 12:12:19  martin
 *  Revision 1.41.1.11  2011/01/31 17:30:02  martin
 *  Modified resource storage for *BSD.
 *  Revision 1.41.1.10  2011/01/27 13:39:01  martin
 *  Revision 1.41.1.9  2011/01/27 11:04:45  martin
 *  Revision 1.41.1.8  2011/01/27 11:01:49  martin
 *  Support static device list (no malloc) and use it under FreeBSD.
 *  Revision 1.41.1.7  2011/01/26 16:42:07  martin
 *  Fixed build under FreeBSD.
 *  Revision 1.41.1.6  2011/01/25 09:47:27  martin
 *  Fixed build under FreeBSD.
 *  Revision 1.41.1.5  2010/11/23 11:07:57  martin
 *  Support memory mapped access under DOS.
 *  Revision 1.41.1.4  2010/11/11 09:15:39Z  martin
 *  Added definitions to support DCF600USB.
 *  Revision 1.41.1.3  2010/08/20 09:35:12  martin
 *  Added macro _pcps_ddev_features().
 *  Revision 1.41.1.2  2010/07/14 14:52:12  martin
 *  Revision 1.41.1.1  2010/06/30 15:01:52  martin
 *  Support GPS180PEX and TCR180PEX.
 *  Revision 1.41  2010/06/30 13:44:49  martin
 *  Use new preprocessor symbol MBG_ARCH_X86.
 *  Revision 1.40  2010/01/12 14:05:05  daniel
 *  Added macro to check if reading the 
 *  raw IRIG data bits is supported.
 *  Revision 1.39  2009/09/29 07:24:51Z  martin
 *  Use standard feature flag to check if fast HR time is supported.
 *  Revision 1.38  2009/06/19 12:13:05  martin
 *  Added _pcps_ddev_has_irig_time() macro.
 *  Revision 1.37  2009/06/09 10:13:59  daniel
 *  Added macros _pcps_ddev_has_lan_intf( _p ) and 
 *  _pcps_ddev_has_ptp_cfg( _p ).
 *  Cleaned up the low level interface and provided a
 *  possibility to override the macros for special purposes.
 *  Set USB cyclic timeout interval to 1200 ms as default.
 *  Revision 1.36  2009/03/16 16:01:24Z  martin
 *  Support reading IRIG control function bits.
 *  Revision 1.35  2009/03/13 09:23:36  martin
 *  Added _pcps_ddev_has_time_scale( _p ) and _pcps_ddev_has_utc_parm( _p ).
 *  Moved _pcps_get_cycles() and _pcps_get_cycles_frequency() to pcpsdev.h
 *  and replaced/merged them with mbg_get_pc_cycles...() functions.
 *  Under Linux use own inline function to read TSC on x86 architectures.
 *  Normally USB timeouts are short with retries in order to increase
 *  responsiveness. On some systems this may lead to problems, so 
 *  optionally one long timeout can be used now by define.
 *  Revision 1.34  2008/12/16 14:40:47  martin
 *  Account for new devices PTP270PEX, FRC270PEX, TCR170PEX, and WWVB51USB.
 *  Added macros _pcps_ddev_is_ptp(), _pcps_ddev_is_frc(), 
 *  and _pcps_ddev_is_wwvb().
 *  Don't use pragma pack( 1 ) but use native alignment since structures 
 *  defined here are not used across system boundaries.
 *  Added fields to PCPS_DDEV to store the ASIC version, and macros
 *  _pcps_ddev_raw_asic_version() and _pcps_ddev_asic_version().
 *  Moved PC cycles types and macros here, and defined dummy _pcps_get_cycles()
 *  for targets which don't support this.
 *  Use generic spinlock/mutex macros and common device access mutex.
 *  Support getting cycles frequency from device driver.
 *  Use MBG_MEM_ADDR type for memory rather than split high/low types.
 *  Renamed MBG_VIRT_ADDR to MBG_MEM_ADDR.
 *  Additional device port variables for IRQ handling.
 *  Use new MBG_ARCH_I386 symbol.
 *  Added DEBUG_LVL_... symbols.
 *  Use PCPS_IRQ_STAT_INFO type.
 *  Account for signed irq_num.
 *  New PCPS_DDEV field acc_cycles.
 *  Added variable usb_20_mode in PCPS_DDEV.
 *  Added connected flag to PCPS_DDEV structure.
 *  Added macro _pcps_ddev_has_fast_hr_timestamp().
 *  Use macros for unaligned access and endianess conversion.
 *  Support mapped I/O resources.
 *  Use some atomic_t types under Linux.
 *  Conditionally use Linux kthread API.
 *  Updated function prototypes.
 *  Revision 1.33  2008/02/27 10:25:30  martin
 *  Added support for TCR51USB and MSF51USB.
 *  Increased N_PCPS_MEM_RSRC to 2.
 *  Modified PCPS_MEM_RSRC to support memory mapped I/O.
 *  Added PCI_ASIC_FEATURES to PCPS_DDEV.
 *  Added new macros and modified some older macros to support
 *  cyclic reading for USB within WIN32 targets.
 *  New macros _pcps_ddev_is_lwr() (long wave receiver),
 *  _pcps_ddev_is_msf(), _pcps_ddev_has_asic_version(),
 *  _pcps_ddev_has_asic_features().
 *  Moved Linux version-specific stuff to mbg_lx.h.
 *  Don't support MCA under DOS by default.
 *  Updated function prototypes.
 *  Revision 1.32  2008/01/31 09:06:03Z  martin
 *  Don't support MCA under DOS by default.
 *  Revision 1.31  2007/09/26 09:28:03Z  martin
 *  Added support for USB in general and new USB device USB5131.
 *  Renamed ..._USE_PCIMGR symbols to ..._USE_PCI_PNP.
 *  Renamed ..._USE_PCIBIOS symbols to ..._USE_PCI_BIOS.
 *  Added definition _PCPS_USE_PNP.
 *  Added new symbol _USE_ISA_PNP to exclude non-PNP stuff.
 *  from build if ISA devices are also handled by the PNP manager.
 *  Include mbgerror.h for new MBG_... codes.
 *  Added macro _pcps_ddev_status_busy().
 *  Added kernel malloc/free macros and USB I/O macros.
 *  Use PCPS_DDEV as private device data.
 *  Use ms values for USB timeouts also under Linux. This may not be 
 *  appropriate for older kernels.
 *  Limited length of some older RCS log messages.
 *  Revision 1.30  2007/07/25 14:22:23Z  martin
 *  Under Linux include param.h for definition of HZ under 
 *  kernels 2.6.21 and newer.
 *  Revision 1.29  2007/07/17 08:22:48  martin
 *  Added support for TCR511PEX and GPS170PEX.
 *  Revision 1.28  2007/07/16 12:58:00Z  martin
 *  Added  support for PEX511.
 *  Added new structures used for unified resource handling.
 *  Account for renamed library symbols.
 *  Revision 1.27  2007/03/02 09:41:05Z  martin
 *  Use generic port I/O macros.
 *  Added DEVICE_OBJECT to PCPS_DDEV under Windows.
 *  Define init code qualifier.
 *  Added new _pcps_..._timeout_clk() macros.
 *  Preliminary support for *BSD.
 *  Preliminary support for USB.
 *  Revision 1.26  2006/07/07 09:44:23  martin
 *  Fixed definition of control macros for the case where 
 *  _PCPS_USE_PCI_PNP is overridden from the command line.
 *  Revision 1.25  2006/06/19 15:31:09  martin
 *  Added support for TCR511PCI.
 *  Updated function prototypes.
 *  Revision 1.24  2006/03/10 11:01:51  martin
 *  Added support for PCI511.
 *  Revision 1.23  2005/11/03 15:50:45Z  martin
 *  Added support for GPS170PCI.
 *  Revision 1.22  2005/06/02 10:35:09Z  martin
 *  Added macro _pcps_ddev_is_pci_amcc().
 *  Added macro _pcps_ddev_has_generic_io().
 *  Updated function prototypes.
 *  Revision 1.21  2004/12/09 11:03:38Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.20  2004/11/09 13:05:12Z  martin
 *  Fixed syntax bug in macro _pcps_ddev_fw_rev_num().
 *  New macro _pcps_ddev_has_gps_data().
 *  New macro _pcps_ddev_requires_irig_workaround().
 *  Revision 1.19  2004/10/14 15:01:24Z  martin
 *  Added support for TCR167PCI.
 *  Revision 1.18  2004/09/06 15:11:04Z  martin
 *  Support a GPS_DATA interface where sizes are specified 
 *  by 16 instead of the original 8 bit quantities, thus allowing 
 *  to transfer data blocks which exceed 255 bytes.
 *  Revision 1.17  2004/04/14 10:29:45Z  martin
 *  Pack structures 1 byte aligned.
 *  Revision 1.16  2004/04/07 09:47:19Z  martin
 *  New macros _pcps_ddev_has_irig() and
 *  _pcps_ddev_has_irig_tx().
 *  Revision 1.15  2004/03/10 17:32:23Z  martin
 *  Use CLOCKS_PER_SEC for timeout under QNX6 (Neutrino).
 *  Revision 1.14  2003/11/17 16:15:01  martin
 *  Support clock tick timeout for QNX.
 *  Revision 1.13  2003/07/08 15:07:32Z  martin
 *  Simplified definitions of default preprocessor macros.
 *  Compile for plug'n'play for Linux kernels 2.4.0 or newer.
 *  Updated function prototypes.
 *  Revision 1.12  2003/06/19 09:56:29  MARTIN
 *  Renamed macro ..clr_cap_buffer to ..clr_ucap_buffer.
 *  New macro _pcps_ddev_has_ucap().
 *  Changes due to renamed symbols.
 *  Updated function prototypes.
 *  Revision 1.11  2003/05/16 09:31:54  MARTIN
 *  Increased timeout loop count from 0x1000 to 0x7FFFFF.
 *  Rearranged inclusion of headers depending on the target.
 *  Added array for ISA port addresses.
 *  Revision 1.10  2003/04/09 16:30:24  martin
 *  Supports PCI510, GPS169PCI, and TCR510PCI,
 *  and new PCI_ASIC used by those devices.
 *  Renamed macro _pcps_ddev_is_irig() to _pcps_ddev_is_irig_rx().
 *  New macros _pcps_ddev_has_ref_offs(), _pcps_ddev_has_opt_flags().
 *  Preliminary support for PCPS_TZDL.
 *  Revision 1.9  2002/08/09 08:53:53  MARTIN
 *  New macro _pcps_ddev_can_clr_cap_buff().
 *  New macro _pcps_ddev_is_irig().
 *  New macro _pcps_ddev_has_signal().
 *  New macro _pcps_ddev_has_mod().
 *  Revision 1.8  2002/02/26 09:34:03  MARTIN
 *  Removed macro _pcps_read_sernum() which was replaced
 *  by a function pcps_read_sernum() which reads the S/N from 
 *  any clock that supports a S/N.
 *  Updated function prototypes.
 *  Revision 1.7  2002/02/19 09:28:01  MARTIN
 *  Use new header mbg_tgt.h to check the target environment.
 *  Revision 1.6  2002/02/01 12:00:10  MARTIN
 *  Added new definitions for GPS168PCI.
 *  Renamed macro _pcps_ddev_rev_num to _pcps_ddev_fw_rev_num
 *  to follow naming conventions.
 *  Source code cleanup.
 *  Revision 1.5  2001/11/30 09:52:48  martin
 *  Added support for event_time which, however, requires 
 *  a custom GPS firmware.
 *  Revision 1.4  2001/10/16 10:15:44  MARTIN
 *  New Macro _pcps_ddev_has_serial_hs() which determines 
 *  whether DCF77 clock supports baud rate higher than default.
 *  Added some macros and comments  corresponding to 
 *  pcpsdev.h.
 *  Revision 1.3  2001/09/18 06:53:57  MARTIN
 *  Two sets of preprocessor symbols for Win9x/ME and WinNT/2k.
 *  New preprocessor symbol controls usage of clock ticks for timeout.
 *  Changed type of PCPS_RSRC.irq_num from int to ushort.
 *  Updated function prototypes.
 *  Revision 1.2  2001/03/16 14:45:34  MARTIN
 *  New functions and definitions to support PNP drivers.
 *  Revision 1.1  2001/03/01 16:29:22  MARTIN
 *  Initial version for the new library.
 *
 **************************************************************************/

#ifndef _PCPSDRVR_H
#define _PCPSDRVR_H

// Setup default controls to include support for
// special features.

#define DEBUG_LVL_SEM       7
#define DEBUG_LVL_PORTS    10
#define DEBUG_LVL_SERNUM   11
#define DEBUG_LVL_IO       12


#include <mbg_tgt.h>

#if defined( MBG_TGT_NETWARE )
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  1
  #define _DEFAULT_PCPS_USE_ISA         1
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_ISA_PNP     0
  #define _DEFAULT_PCPS_USE_PCI_PNP     0
  #define _DEFAULT_PCPS_USE_USB         0
  #define _DEFAULT_PCPS_USE_RSRCMGR     0
#elif defined( MBG_TGT_OS2 )
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  0
  #define _DEFAULT_PCPS_USE_ISA         1
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_ISA_PNP     0
  #define _DEFAULT_PCPS_USE_PCI_PNP     0
  #define _DEFAULT_PCPS_USE_USB         0
  #define _DEFAULT_PCPS_USE_RSRCMGR     1
#elif defined( MBG_TGT_WIN32_PNP )
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  1
  #define _DEFAULT_PCPS_USE_ISA         1
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_ISA_PNP     1
  #define _DEFAULT_PCPS_USE_PCI_PNP     1
  #define _DEFAULT_PCPS_USE_USB         1
  #define _DEFAULT_PCPS_USE_RSRCMGR     0
#elif defined( MBG_TGT_WIN32 )
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  1
  #define _DEFAULT_PCPS_USE_ISA         1
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_ISA_PNP     0
  #define _DEFAULT_PCPS_USE_PCI_PNP     0
  #define _DEFAULT_PCPS_USE_USB         0
  #define _DEFAULT_PCPS_USE_RSRCMGR     0
#elif defined( MBG_TGT_LINUX )
  #include <mbg_lx.h>
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  1
  #define _DEFAULT_PCPS_USE_ISA         defined( MBG_ARCH_X86 )
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_ISA_PNP     0
  #define _DEFAULT_PCPS_USE_PCI_PNP     _DEFAULT_MBG_TGT_LINUX_USE_PCI_PNP
  #define _DEFAULT_PCPS_USE_USB         _DEFAULT_MBG_TGT_LINUX_USE_USB
  #define _DEFAULT_PCPS_USE_RSRCMGR     1
#elif defined( MBG_TGT_BSD )  //##++
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  1
  #define _DEFAULT_PCPS_USE_ISA         1
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_ISA_PNP     0
  #define _DEFAULT_PCPS_USE_PCI_PNP     1
  #define _DEFAULT_PCPS_USE_USB         0
  #define _DEFAULT_PCPS_USE_RSRCMGR     1
#elif defined( MBG_TGT_QNX )
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  1
  #define _DEFAULT_PCPS_USE_ISA         1
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_ISA_PNP     0
  #define _DEFAULT_PCPS_USE_PCI_PNP     0
  #define _DEFAULT_PCPS_USE_USB         0
  #define _DEFAULT_PCPS_USE_RSRCMGR     0
#else  // DOS ...
  #define _DEFAULT_PCPS_USE_CLOCK_TICK  1
  #define _DEFAULT_PCPS_USE_ISA         1
  #define _DEFAULT_PCPS_USE_MCA         0
  #define _DEFAULT_PCPS_USE_PCI         1
  #define _DEFAULT_PCPS_USE_PCI_PNP     0
  #define _DEFAULT_PCPS_USE_ISA_PNP     0
  #define _DEFAULT_PCPS_USE_USB         0
  #define _DEFAULT_PCPS_USE_RSRCMGR     0
#endif

#ifndef _PCPS_USE_CLOCK_TICK
  #define _PCPS_USE_CLOCK_TICK  _DEFAULT_PCPS_USE_CLOCK_TICK
#endif

#ifndef _PCPS_USE_ISA
  #define _PCPS_USE_ISA         _DEFAULT_PCPS_USE_ISA
#endif

#ifndef _PCPS_USE_MCA
  #define _PCPS_USE_MCA         _DEFAULT_PCPS_USE_MCA
#endif

#ifndef _PCPS_USE_PCI
  #define _PCPS_USE_PCI         _DEFAULT_PCPS_USE_PCI
#endif

#ifndef _PCPS_USE_ISA_PNP
  #define _PCPS_USE_ISA_PNP     _DEFAULT_PCPS_USE_ISA_PNP
#endif

#ifndef _PCPS_USE_PCI_PNP
  #define _PCPS_USE_PCI_PNP     _DEFAULT_PCPS_USE_PCI_PNP
#endif

#ifndef _PCPS_USE_USB
  #define _PCPS_USE_USB         _DEFAULT_PCPS_USE_USB
#endif

#ifndef _PCPS_USE_RSRCMGR
  #define _PCPS_USE_RSRCMGR     _DEFAULT_PCPS_USE_RSRCMGR
#endif


#ifndef _PCPS_USE_PCI_BIOS
  #define _PCPS_USE_PCI_BIOS    ( _PCPS_USE_PCI && !_PCPS_USE_PCI_PNP )
#endif

#define _PCPS_USE_PNP           ( _PCPS_USE_PCI_PNP || _PCPS_USE_ISA_PNP || _PCPS_USE_USB )

#if _PCPS_USE_PCI_PNP && _PCPS_USE_PCI_BIOS
  #error "PCI PNP and non-PNP can't be used at the same time"
#endif


#if !defined( _MBG_INIT_CODE_ATTR )
  // define to empty string by default
  #define _MBG_INIT_CODE_ATTR
#endif



/* Other headers to be included */
#include <pcpsdev.h>
#include <mbgmutex.h>
#include <pci_asic.h>
#include <mbgerror.h>
#include <use_pack.h>
#include <mbggenio.h>

#if defined( MBG_TGT_FREEBSD )
  #include <mbg_bsd.h>
  #include <sys/malloc.h>
  #include <sys/_null.h>
  #include <sys/param.h>
  #include <sys/lock.h>
  #include <machine/bus.h>
#elif defined( MBG_TGT_NETBSD )
  #include <sys/kmem.h>
#else
  #include <stddef.h>
#endif

#if defined( MBG_TGT_DOS )
  #include <string.h>
  #include <time.h>
#endif

#if defined( MBG_TGT_WIN32 )
  #include <mbg_w32.h>
#endif

#if defined( MBG_TGT_LINUX )
  #if _PCPS_USE_USB
    #include <linux/usb.h>
  #endif
#endif

#if defined( MBG_TGT_QNX )
  #include <mbg_qnx.h>
  #include <string.h>
  #include <time.h>
#endif

#if defined( MBG_TGT_NETWARE )
  #include <string.h>
  #include <time.h>
  #include <conio.h>
#endif

#if defined( MBG_TGT_OS2 )
  #ifndef OS2_INCLUDED
    #define INCL_DOSSEMAPHORES
    #include <os2.h>
    #include <rmbase.h>
  #endif

  #include <string.h>
  #include <time.h>
  #include <conio.h>
  #include <xportio.h>
#elif defined( MBG_TGT_DOS )
  #define FAR far
#else
  #define FAR
#endif

#if _PCPS_USE_RSRCMGR
  #include <rsrc.h>
#endif

#ifdef _PCPSDRVR
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

// We use native alignment for structures which are not accessed across system boundaries.

#ifdef __cplusplus
extern "C" {
#endif

// Define some OS-specific primitives to alloc / free memory and handle
// mutexes and spinlocks in kernel space.

#if defined( MBG_TGT_LINUX )

  #define _pcps_kmalloc( _sz )            kmalloc( _sz, GFP_ATOMIC )
  #define _pcps_kfree( _p, _sz )          kfree( _p )

  //##+++++++++++++++++++
  // The special versions of _pcps_sem_inc() and _pcps_sem_dec() below
  // are only required to prevent interference with the IRQ handler
  // under Linux which implements the serial port emulation for the
  // NTP parse driver.
  #define _pcps_sem_inc( _pddev )                          \
  {                                                        \
    ulong flags;                                           \
                                                           \
    if ( _mbg_mutex_acquire( &(_pddev)->dev_mutex ) < 0 )  \
      return -ERESTARTSYS;                                 \
                                                           \
    spin_lock_irqsave( &(_pddev)->irq_lock, flags );       \
    atomic_inc( &(_pddev)->access_in_progress );           \
    spin_unlock_irqrestore( &(_pddev)->irq_lock, flags );  \
  }

  #define _pcps_sem_dec( _pddev )                 \
    atomic_dec( &(_pddev)->access_in_progress );  \
    _mbg_mutex_release( &(_pddev)->dev_mutex )

#elif defined( MBG_TGT_FREEBSD )

  // malloc/free in kernel mode require usage of the
  // MALLOC_DECLARE() / MALLOC_DEFINE() macros.
  // See "man 9 malloc" for details.

  MALLOC_DECLARE( M_MBGCLOCK );
  #define _pcps_kmalloc( _sz )            malloc( _sz, M_MBGCLOCK, M_NOWAIT | M_ZERO )
  #define _pcps_kfree( _p, _sv )          free( _p, M_MBGCLOCK )

#elif defined( MBG_TGT_NETBSD )

  // For older NetBSD versions which do not suppport the calls
  // used below, see 'man 9 malloc'.
  #define _pcps_kmalloc( _sz )            kmem_alloc( _sz, KM_NOSLEEP )
  #define _pcps_kfree( _p, _sz )          kmem_free( _p, _sz )

#elif defined( MBG_TGT_WIN32 )

  #define _pcps_kmalloc( _sz )            ExAllocatePool( NonPagedPool, _sz )
  #define _pcps_kfree( _p, _sz )          ExFreePool( _p )

#elif defined( MBG_TGT_DOS )

  // No multitasking, no device driver,
  // so we don't need this.

  #define _pcps_sem_inc( _pddev ) \
    _nop_macro_fnc()

  #define _pcps_sem_dec( _pddev ) \
    _nop_macro_fnc()

#endif


#if !defined( _PCPS_STATIC_DEV_LIST )
  // On PNP systems buffers for device specific data are by default malloc'ed
  // whenever a device appears. However, a static array of a given maximum number
  // of devices is used on non-PNP systems.
  // This can be overridden for testing to avoid calling malloc in kernel space.
  #define _PCPS_STATIC_DEV_LIST ( !_PCPS_USE_PNP )
#endif



// If the macros below have not yet been defined then define some dummies:

#if !defined( _pcps_sem_inc ) || !defined( _pcps_sem_dec )

  #define _pcps_sem_inc( _pddev ) \
    _mbg_mutex_acquire( &(_pddev)->dev_mutex )

  #define _pcps_sem_dec( _pddev ) \
    _mbg_mutex_release( &(_pddev)->dev_mutex )

#endif



/* ------ definitions used with PCI clocks -------------------------- */

/* Default timeout count accessing the board */

#if _PCPS_USE_CLOCK_TICK
  #if defined( MBG_TGT_NETWARE )
    #define PCPS_TIMEOUT_CNT ( (ulong)( 200 * __get_CLK_TCK() ) / 1000 )
  #elif defined( MBG_TGT_LINUX )
    #define PCPS_TIMEOUT_CNT ( (ulong)( 200 * HZ ) / 1000 )
  #elif defined( MBG_TGT_BSD )
    #define PCPS_TIMEOUT_CNT ( (ulong)( 200 ) )    // [ms]
  #elif defined( MBG_TGT_WIN32 )
    #define PCPS_TIMEOUT_CNT ( (ulong)( 200 * MBG_TICKS_PER_SEC ) / 1000 )
  #elif defined( MBG_TGT_QNX_NTO )
    #define PCPS_TIMEOUT_CNT ( (ulong)( 200 * CLOCKS_PER_SEC ) / 1000 )
  #else
    #define PCPS_TIMEOUT_CNT ( (ulong)( 200 * CLK_TCK ) / 1000 )
  #endif
#else
  #define PCPS_TIMEOUT_CNT   0x7FFFFFUL
#endif


// The structures below are used to provide a consistent
// resource handling across different platforms.
// This is kept completely inside the kernel drivers, so these
// structures can be modified safely to suit our needs.

#if MBG_USE_MM_IO_FOR_PCI

  typedef ulong PCPS_IO_ADDR_RAW;

  #if defined( MBG_TGT_LINUX )

    typedef volatile void __iomem *PCPS_IO_ADDR_MAPPED;

    #define _pcps_ioremap( _base, _num )   ioremap_nocache( (_base), (_num) )

  #else

    #error Not supported for target environment.

  #endif

#else

  typedef PCPS_PORT_ADDR PCPS_IO_ADDR_RAW;
  typedef PCPS_IO_ADDR_RAW PCPS_IO_ADDR_MAPPED;

  #if defined( MBG_TGT_BSD )
    // Under *BSD we use only the offset. The base address
    // is determined by a handle.
    #define _pcps_ioremap( _base, _num )   0
  #else
    #define _pcps_ioremap( _base, _num )   ( _base )
  #endif
#endif



#if defined( MBG_TGT_BSD )

typedef struct
{
#if defined ( MBG_TGT_FREEBSD )
  int rid;                /* resource ID */
  struct resource *res;
  bus_space_tag_t bst;
  bus_space_handle_t bsh;
#elif defined ( MBG_TGT_NETBSD )
  int                reg;	/* BAR */
  int                type;	/* type */
  int                valid;	/* valid flag */
  bus_space_tag_t    bst;	/* bus space tag */
  bus_space_handle_t bsh;	/* bus space handle */
  bus_addr_t         base;	/* base address */
  bus_size_t         size;	/* size */
#endif
} BSD_RSRC_INFO;

#endif



/**
  The structure below describes an I/O port resource
  used by a clock.
*/
typedef struct
{
  #if defined( MBG_TGT_BSD )
    BSD_RSRC_INFO bsd;
  #endif
  PCPS_IO_ADDR_MAPPED base_mapped;
  PCPS_IO_ADDR_RAW base_raw;
  uint16_t num;
} PCPS_IO_RSRC;


// The structure below describes a bus memory resource
// used by a clock.

typedef struct
{
  #if defined( MBG_TGT_BSD )
    BSD_RSRC_INFO bsd;
  #endif
  MBG_MEM_ADDR start;
  ulong len;

} PCPS_MEM_RSRC;



// The structure below describes a bus IRQ resource
// used by a clock.

typedef struct
{
  #if defined( MBG_TGT_BSD )
    BSD_RSRC_INFO bsd;
  #endif
  ushort num;

} PCPS_IRQ_RSRC;



// The max number of bus memory resources used by a device.
#define N_PCPS_MEM_RSRC  2

// The max number of bus memory and I/O resources used by a device.
#define MAX_PCPS_RSRC  ( N_PCPS_MEM_RSRC + N_PCPS_PORT_RSRC )

typedef struct
{
  int num_rsrc_io;
  int num_rsrc_mem;
  int num_rsrc_irq;
  PCPS_IO_RSRC port[N_PCPS_PORT_RSRC];
  PCPS_MEM_RSRC mem[N_PCPS_MEM_RSRC];
  PCPS_IRQ_RSRC irq;
} PCPS_RSRC_INFO;



#if _PCPS_USE_USB

  typedef struct
  {
    uint8_t addr;
    uint16_t max_packet_size;
  } PCPS_USB_EP;


  #if defined( MBG_TGT_LINUX )

    // definitions used to control the cyclic USB read thread

    #if _PCPS_USE_LINUX_KTHREAD

      // use kthread_run() / kthread_stop()
      typedef struct task_struct *PCPS_THREAD_INFO;

    #else

      // use kernel_thread() / daemonize() / kill_proc()
      typedef struct
      {
        pid_t pid;
        char name[17];   // 16 chars as supported by the kernel, plus trailing 0
        struct completion exit;
      } PCPS_THREAD_INFO;

    #endif  // _PCPS_USE_LINUX_KTHREAD

  #endif  // defined( MBG_TGT_LINUX )

#endif  // _PCPS_USE_USB



typedef union
{
  struct
  {
    PCI_ASIC asic;
    PCPS_TIME_STAMP tstamp;
  } pex8311;

  struct
  {
    PCI_ASIC asic;
    uint8_t b[256 - sizeof( PCI_ASIC ) ];
    PCPS_TIME_STAMP ucap[2];
    PCPS_TIME_STAMP tstamp;
  } mbgpex;

} PCPS_MM_LAYOUT;


struct PCPS_DDEV_s;

typedef short (*PCPS_READ_FNC)( struct PCPS_DDEV_s *pddev, uint8_t cmd, void FAR *buffer, uint16_t count );
typedef short (*PCPS_WRITE_FNC)( struct PCPS_DDEV_s *pddev, uint8_t cmd, const void FAR *buffer, uint16_t count );
typedef struct PCPS_DDEV_s *(*PCPS_DDEV_ALLOC_FNC)( void );
typedef void (*PCPS_DDEV_CLEANUP_FNC)( struct PCPS_DDEV_s * );
typedef int (*PCPS_DDEV_REGISTER_FNC)( struct PCPS_DDEV_s * );


typedef struct PCPS_DDEV_s
{
  // the device info data
  PCPS_DEV dev;

  PCPS_READ_FNC read;

  PCPS_IO_ADDR_MAPPED status_port;
  PCPS_IO_ADDR_MAPPED irq_enb_disb_port;
  PCPS_IO_ADDR_MAPPED irq_flag_port;
  PCPS_IO_ADDR_MAPPED irq_ack_port;
  uint32_t irq_enb_mask;
  uint32_t irq_disb_mask;
  uint32_t irq_flag_mask;
  uint32_t irq_ack_mask;

  PCI_ASIC_VERSION raw_asic_version;
  PCI_ASIC_VERSION asic_version;
  PCI_ASIC_FEATURES asic_features;
  PCPS_RSRC_INFO rsrc_info;

  MBG_PC_CYCLES acc_cycles;

  #if defined( _MBG_MUTEX_DEFINED )
    MBG_MUTEX dev_mutex;
  #endif

  PCPS_MM_LAYOUT FAR *mm_addr;
  volatile PCPS_TIME_STAMP FAR *mm_tstamp_addr;

  #if defined( _MBG_SPINLOCK_DEFINED )
    MBG_SPINLOCK mm_lock;
    MBG_SPINLOCK irq_lock;
  #endif

  // The flag below holds IRQ information, e.g. whether the device's
  // IRQ is possibly unsafe, and whether IRQ has been enabled on the device.
  PCPS_IRQ_STAT_INFO irq_stat_info;

  RECEIVER_INFO ri;

  #if _PCPS_USE_USB
    int n_usb_ep;   // number of endpoints supp. by the device
    PCPS_USB_EP ep[MBGUSB_MAX_ENDPOINTS];
    uint8_t usb_20_mode;
  #endif

  #if defined( MBG_TGT_WIN32 )
    _pcps_ddev_data_win
  #endif

  #if defined( MBG_TGT_LINUX )
    atomic_t connected;
    atomic_t access_in_progress;
    atomic_t data_avail;
    unsigned long jiffies_at_irq;
    struct fasync_struct *fasyncptr;
    PCPS_TIME t;

    #if NEW_WAIT_QUEUE
      wait_queue_head_t wait_queue;
    #else
      struct wait_queue *wait_queue;
    #endif

    dev_t lx_dev;
    atomic_t open_count;

    #if _PCPS_USE_LINUX_CHRDEV
      struct cdev cdev;
    #elif _PCPS_USE_LINUX_MISC_DEV
      struct miscdevice mdev;
    #endif

    #if _PCPS_USE_USB
      struct usb_device *udev;
      struct usb_interface *intf;
      PCPS_THREAD_INFO usb_read_thread;
      struct semaphore sem_usb_cyclic;
    #endif
  #endif

  #if defined( MBG_TGT_BSD )
    int connected;
    int open_count;
  #endif

  #if _PCPS_USE_RSRCMGR
    #if defined( MBG_TGT_OS2 )
      PCPS_HDEV hDev;
      RSRC_LIST rsrc;
    #endif
  #endif

} PCPS_DDEV;



/* The PCI vendor ID and device ID numbers are used to detect a
 * PCI clock in a system and query which resources have been
 * assigned by the BIOS.
 * (PCI vendor ID and PCI device IDs are defined in PCPSDEFS.H)
 */

/* the number of address lines decoded by a PCI clock */
#define PCPS_DECODE_WIDTH_PCI   16


/* ------ definitions used with MCA clocks -------------------------- */

/* The MCA adapter ID number is used to detect a MCA clock in a
 * system and query which resources have been assigned by the
 * system's POS (programmable option select).
 */

/* MCA Adapter ID numbers */
#define MCA_ID_PS31        0x6AAC   /* assigned by IBM */
#define MCA_ID_PS31_OLD    0x6303   /* assigned by Meinberg, used with */
                                    /* the first series of PS31 boards */

/* the total number of ports acquired by a MCA clock */
#define PCPS_NUM_PORTS_MCA      16

/* the number of address lines decoded by a MCA clock */
#define PCPS_DECODE_WIDTH_MCA   16


/* ------ definitions used with ISA clocks -------------------------- */

/* A board ID for the newer clocks with ISA bus. The number can
 * be read at port_base+2 (low byte) and port_base+3 (high byte)
 * of ISA clocks. This ID number matches the MCA adapter ID
 * defined above and is not available on PC31 clocks.
 */
#define ISA_ID_PCPS             MCA_ID_PS31

/* The default port base address for ISA clocks.
 * Some programs assume a default port for an ISA clock,
 * others do not but require a cmd line parameter.
 */
#define PCPS_DEFAULT_PORT       0x0300

/* the total number of ports acquired by a ISA clock */
#define PCPS_NUM_PORTS_ISA      4

/* the number of address lines decoded by a ISA clock */
#define PCPS_DECODE_WIDTH_ISA   10


/* ------ common definitions -------------------------- */

#if defined( DEBUG )
  _ext int debug
  #ifdef _DO_INIT
    = DEBUG
  #endif
  ;
#endif


_ext PCPS_DEV_TYPE pcps_dev_type[N_PCPS_DEV_TYPE]
#ifdef _DO_INIT
= {  // attention, the name is limited to PCPS_CLOCK_NAME_SZ, including terminating 0
  { PCPS_TYPE_PC31,      "PC31",      0,                 PCPS_REF_DCF,  PCPS_BUS_ISA },
  { PCPS_TYPE_PS31_OLD,  "PS31",      MCA_ID_PS31_OLD,   PCPS_REF_DCF,  PCPS_BUS_MCA },
  { PCPS_TYPE_PS31,      "PS31",      MCA_ID_PS31,       PCPS_REF_DCF,  PCPS_BUS_MCA },
  { PCPS_TYPE_PC32,      "PC32",      ISA_ID_PCPS,       PCPS_REF_DCF,  PCPS_BUS_ISA },
  { PCPS_TYPE_PCI32,     "PCI32",     PCI_DEV_PCI32,     PCPS_REF_DCF,  PCPS_BUS_PCI_S5933 },
  { PCPS_TYPE_GPS167PC,  "GPS167PC",  0,                 PCPS_REF_GPS,  PCPS_BUS_ISA },
  { PCPS_TYPE_GPS167PCI, "GPS167PCI", PCI_DEV_GPS167PCI, PCPS_REF_GPS,  PCPS_BUS_PCI_S5933 },
  { PCPS_TYPE_PCI509,    "PCI509",    PCI_DEV_PCI509,    PCPS_REF_DCF,  PCPS_BUS_PCI_S5920 },
  { PCPS_TYPE_GPS168PCI, "GPS168PCI", PCI_DEV_GPS168PCI, PCPS_REF_GPS,  PCPS_BUS_PCI_S5920 },
  { PCPS_TYPE_PCI510,    "PCI510",    PCI_DEV_PCI510,    PCPS_REF_DCF,  PCPS_BUS_PCI_ASIC },
  { PCPS_TYPE_GPS169PCI, "GPS169PCI", PCI_DEV_GPS169PCI, PCPS_REF_GPS,  PCPS_BUS_PCI_ASIC },
  { PCPS_TYPE_TCR510PCI, "TCR510PCI", PCI_DEV_TCR510PCI, PCPS_REF_IRIG, PCPS_BUS_PCI_ASIC },
  { PCPS_TYPE_TCR167PCI, "TCR167PCI", PCI_DEV_TCR167PCI, PCPS_REF_IRIG, PCPS_BUS_PCI_ASIC },
  { PCPS_TYPE_GPS170PCI, "GPS170PCI", PCI_DEV_GPS170PCI, PCPS_REF_GPS,  PCPS_BUS_PCI_ASIC },
  { PCPS_TYPE_PCI511,    "PCI511",    PCI_DEV_PCI511,    PCPS_REF_DCF,  PCPS_BUS_PCI_ASIC },
  { PCPS_TYPE_TCR511PCI, "TCR511PCI", PCI_DEV_TCR511PCI, PCPS_REF_IRIG, PCPS_BUS_PCI_ASIC },
  { PCPS_TYPE_PEX511,    "PEX511",    PCI_DEV_PEX511,    PCPS_REF_DCF,  PCPS_BUS_PCI_PEX8311 },
  { PCPS_TYPE_TCR511PEX, "TCR511PEX", PCI_DEV_TCR511PEX, PCPS_REF_IRIG, PCPS_BUS_PCI_PEX8311 },
  { PCPS_TYPE_GPS170PEX, "GPS170PEX", PCI_DEV_GPS170PEX, PCPS_REF_GPS,  PCPS_BUS_PCI_PEX8311 },
  { PCPS_TYPE_USB5131,   "USB5131",   USB_DEV_USB5131,   PCPS_REF_DCF,  PCPS_BUS_USB },
  { PCPS_TYPE_TCR51USB,  "TCR51USB",  USB_DEV_TCR51USB,  PCPS_REF_IRIG, PCPS_BUS_USB },
  { PCPS_TYPE_MSF51USB,  "MSF51USB",  USB_DEV_MSF51USB,  PCPS_REF_MSF,  PCPS_BUS_USB },
  { PCPS_TYPE_PTP270PEX, "PTP270PEX", PCI_DEV_PTP270PEX, PCPS_REF_PTP,  PCPS_BUS_PCI_PEX8311 },
  { PCPS_TYPE_FRC511PEX, "FRC511PEX", PCI_DEV_FRC511PEX, PCPS_REF_FRC,  PCPS_BUS_PCI_PEX8311 },
  { PCPS_TYPE_TCR170PEX, "TCR170PEX", PCI_DEV_TCR170PEX, PCPS_REF_IRIG, PCPS_BUS_PCI_PEX8311 },
  { PCPS_TYPE_WWVB51USB, "WWVB51USB", USB_DEV_WWVB51USB, PCPS_REF_WWVB, PCPS_BUS_USB },
  { PCPS_TYPE_GPS180PEX, "GPS180PEX", PCI_DEV_GPS180PEX, PCPS_REF_GPS,  PCPS_BUS_PCI_MBGPEX },
  { PCPS_TYPE_TCR180PEX, "TCR180PEX", PCI_DEV_TCR180PEX, PCPS_REF_IRIG, PCPS_BUS_PCI_MBGPEX },
  { PCPS_TYPE_DCF600USB, "DCF600USB", USB_DEV_DCF600USB, PCPS_REF_DCF,  PCPS_BUS_USB_V2 },
  { PCPS_TYPE_PZF180PEX, "PZF180PEX", PCI_DEV_PZF180PEX, PCPS_REF_DCF,  PCPS_BUS_PCI_MBGPEX },
  { PCPS_TYPE_TCR600USB, "TCR600USB", USB_DEV_TCR600USB, PCPS_REF_IRIG, PCPS_BUS_USB_V2 },
  { PCPS_TYPE_MSF600USB, "MSF600USB", USB_DEV_MSF600USB, PCPS_REF_MSF,  PCPS_BUS_USB_V2 },
  { PCPS_TYPE_WVB600USB, "WVB600USB", USB_DEV_WVB600USB, PCPS_REF_WWVB, PCPS_BUS_USB_V2 }

  // If a new device is added here, don't forget to add it also
  // to the Windows .inf file of supported PCI an USB devices,
  // and in case of USB to the Linux driver file mbgdrvr.c.
}
#endif
;


#if !defined( PCPS_MAX_DDEVS )
  #define PCPS_MAX_DDEVS   4
#endif

#if !defined( PCPS_MAX_ISA_CARDS )
  #define PCPS_MAX_ISA_CARDS  PCPS_MAX_DDEVS  // the number of ISA cards supported
#endif

_ext int pcps_isa_ports[PCPS_MAX_ISA_CARDS + 1];

#if _PCPS_STATIC_DEV_LIST
  _ext PCPS_DDEV pcps_ddev[PCPS_MAX_DDEVS];
  _ext int n_ddevs;
#endif

#if defined( MBG_TGT_DOS ) || defined( MBG_TGT_NETWARE ) //##++ 
  _ext int curr_ddev_num;
  _ext PCPS_DDEV *curr_ddev
  #ifdef _DO_INIT
   = &pcps_ddev[0]
  #endif
  ;
#endif

/* the first characters of a valid EPROM ID */

_ext const char *fw_id_ref[]
#ifdef _DO_INIT
 = {
     "PC3",      // PC31, PS31, PC32
     "PCI",      // PCI32, PCI509, PCI510, PCI511
     "GPS",      // GPS167PC, GPS167PCI, GPS168PCI, GPS169PCI, GPS170PCI, GPS170PEX, GPS180PEX
     "TCR",      // TCR510PCI, TCR167PCI, TCR511PCI, TCR511PEX, TCR51USB, TCR170PEX, TCR180PEX
     "PEX",      // PEX511
     "USB",      // USB5131
     "MSF",      // MSF51USB, MSF600USB
     "WWVB",     // WWVB51USB, WVB600USB
     "DCF",      // DCF600USB
     "PZF",      // PZF180PEX
     NULL
   }
#endif
;


// The macros below are used to distinguish ISA cards:

#define fw_id_ref_pcps    fw_id_ref[0]
#define fw_id_ref_gps     fw_id_ref[2]



// The macros below accept a (PCPS_DDEV *) for easy access
// to the information stored in PCPS_DDEV structures.

// Access device type information:
#define _pcps_ddev_type_num( _p )        _pcps_type_num( &(_p)->dev )
#define _pcps_ddev_type_name( _p )       _pcps_type_name( &(_p)->dev )
#define _pcps_ddev_dev_id( _p )          _pcps_dev_id( &(_p)->dev )
#define _pcps_ddev_ref_type( _p )        _pcps_ref_type( &(_p)->dev )
#define _pcps_ddev_bus_flags( _p )       _pcps_bus_flags( &(_p)->dev )

// Query device type features:
#define _pcps_ddev_is_gps( _p )          _pcps_is_gps( &(_p)->dev )
#define _pcps_ddev_is_dcf( _p )          _pcps_is_dcf( &(_p)->dev )
#define _pcps_ddev_is_msf( _p )          _pcps_is_msf( &(_p)->dev )
#define _pcps_ddev_is_wwvb( _p )         _pcps_is_wwvb( &(_p)->dev )
#define _pcps_ddev_is_irig_rx( _p )      _pcps_is_irig_rx( &(_p)->dev )
#define _pcps_ddev_is_ptp( _p )          _pcps_is_ptp( &(_p)->dev )
#define _pcps_ddev_is_frc( _p )          _pcps_is_frc( &(_p)->dev )

#define _pcps_ddev_is_lwr( _p )          _pcps_is_lwr( &(_p)->dev )

// Generic bus types:
#define _pcps_ddev_is_isa( _p )          _pcps_is_isa( &(_p)->dev )
#define _pcps_ddev_is_mca( _p )          _pcps_is_mca( &(_p)->dev )
#define _pcps_ddev_is_pci( _p )          _pcps_is_pci( &(_p)->dev )
#define _pcps_ddev_is_usb( _p )          _pcps_is_usb( &(_p)->dev )

// Special bus types:
#define _pcps_ddev_is_usb_v2( _p )       _pcps_is_usb_v2( &(_p)->dev )
#define _pcps_ddev_is_pci_s5933( _p )    _pcps_is_pci_s5933( &(_p)->dev )
#define _pcps_ddev_is_pci_s5920( _p )    _pcps_is_pci_s5920( &(_p)->dev )
#define _pcps_ddev_is_pci_amcc( _p )     _pcps_is_pci_amcc( &(_p)->dev )
#define _pcps_ddev_is_pci_asic( _p )     _pcps_is_pci_asic( &(_p)->dev )
#define _pcps_ddev_is_pci_pex8311( _p )  _pcps_is_pci_pex8311( &(_p)->dev )
#define _pcps_ddev_is_pci_mbgpex( _p )   _pcps_is_pci_mbgpex( &(_p)->dev )


// Access device configuration information:
#define _pcps_ddev_bus_num( _p )         _pcps_bus_num( &(_p)->dev )
#define _pcps_ddev_slot_num( _p )        _pcps_slot_num( &(_p)->dev )

#define _pcps_ddev_port_rsrc( _p, _n )   _pcps_port_rsrc( &(_p)->dev, _n )
#define _pcps_ddev_port_base( _p, _n )   _pcps_port_base( &(_p)->dev, _n )
#define _pcps_ddev_io_rsrc( _p, _n )     ( (_p)->rsrc_info.port[_n] )
#define _pcps_ddev_io_base_mapped( _p, _n ) ( _pcps_ddev_io_rsrc( _p, _n ).base_mapped )
#define _pcps_ddev_irq_num( _p )         _pcps_irq_num( &(_p)->dev )
#define _pcps_ddev_timeout_clk( _p )     _pcps_timeout_clk( &(_p)->dev )

#define _pcps_ddev_fw_rev_num( _p )      _pcps_fw_rev_num( &(_p)->dev )
#define _pcps_ddev_features( _p )        _pcps_features( &(_p)->dev )
#define _pcps_ddev_fw_id( _p )           _pcps_fw_id( &(_p)->dev )
#define _pcps_ddev_sernum( _p )          _pcps_sernum( &(_p)->dev )

#define _pcps_ddev_raw_asic_version( _p )  ( (_p)->raw_asic_version )
#define _pcps_ddev_asic_version( _p )      ( (_p)->asic_version )

// The macros below handle the device's err_flags.
#define _pcps_ddev_chk_err_flags( _p, _msk ) \
        _pcps_chk_err_flags( &(_p)->dev, _msk )

#define _pcps_ddev_set_err_flags( _p, _msk ) \
        _pcps_set_err_flags( &(_p)->dev, _msk )

#define _pcps_ddev_clr_err_flags( _p, _msk ) \
        _pcps_clr_err_flags( &(_p)->dev, _msk )


// Query whether a special feature is supported:
#define _pcps_ddev_has_feature( _p, _f ) _pcps_has_feature( &(_p)->dev, _f )

#define _pcps_ddev_can_set_time( _p )    _pcps_can_set_time( &(_p)->dev )
#define _pcps_ddev_has_serial( _p )      _pcps_has_serial( &(_p)->dev )
#define _pcps_ddev_has_sync_time( _p )   _pcps_has_sync_time( &(_p)->dev )
#define _pcps_ddev_has_ident( _p )       _pcps_has_ident( &(_p)->dev )
#define _pcps_ddev_has_utc_offs( _p )    _pcps_has_utc_offs( &(_p)->dev )
#define _pcps_ddev_has_hr_time( _p )     _pcps_has_hr_time( &(_p)->dev )
#define _pcps_ddev_has_sernum( _p )      _pcps_has_sernum( &(_p)->dev )
#define _pcps_ddev_has_cab_len( _p )     _pcps_has_cab_len( &(_p)->dev )
#define _pcps_ddev_has_tzdl( _p )        _pcps_has_tzdl( &(_p)->dev )
#define _pcps_ddev_has_pcps_tzdl( _p )   _pcps_has_pcps_tzdl( &(_p)->dev )
#define _pcps_ddev_has_tzcode( _p )      _pcps_has_tzcode( &(_p)->dev )
#define _pcps_ddev_has_tz( _p )          _pcps_has_tz( &(_p)->dev )
// The next one is supported only with a certain GPS firmware version:
#define _pcps_ddev_has_event_time( _p )  _pcps_has_event_time( &(_p)->dev )
#define _pcps_ddev_has_receiver_info( _p ) _pcps_has_receiver_info( &(_p)->dev )
#define _pcps_ddev_can_clr_ucap_buff( _p ) _pcps_can_clr_ucap_buff( &(_p)->dev )
#define _pcps_ddev_has_ucap( _p )        _pcps_has_ucap( &(_p)->dev )
#define _pcps_ddev_has_irig_tx( _p )     _pcps_has_irig_tx( &(_p)->dev )

// The macro below determines whether a DCF77 clock
// supports a higher baud rate than standard
#define _pcps_ddev_has_serial_hs( _p ) \
        _pcps_has_serial_hs( &(_p)->dev )


#define _pcps_ddev_has_signal( _p ) \
        _pcps_has_signal( &(_p)->dev )

#define _pcps_ddev_has_mod( _p ) \
        _pcps_has_mod( &(_p)->dev )

#define _pcps_ddev_has_irig( _p ) \
        _pcps_has_irig( &(_p)->dev )

#define _pcps_ddev_has_irig_ctrl_bits( _p ) \
        _pcps_has_irig_ctrl_bits( &(_p)->dev )

#define _pcps_ddev_has_irig_time( _p ) \
        _pcps_has_irig_time( &(_p)->dev )

#define _pcps_ddev_has_raw_irig_data( _p ) \
        _pcps_has_raw_irig_data( &(_p)->dev )

#define _pcps_ddev_has_ref_offs( _p ) \
        _pcps_has_ref_offs( &(_p)->dev )

#define _pcps_ddev_has_opt_flags( _p ) \
        _pcps_has_opt_flags( &(_p)->dev )

#define _pcps_ddev_has_gps_data_16( _p ) \
        _pcps_has_gps_data_16( &(_p)->dev )

#define _pcps_ddev_has_gps_data( _p ) \
        _pcps_has_gps_data( &(_p)->dev )

#define _pcps_ddev_has_synth( _p ) \
        _pcps_has_synth( &(_p)->dev )

#define _pcps_ddev_has_generic_io( _p ) \
        _pcps_has_generic_io( &(_p)->dev )

#define _pcps_ddev_has_time_scale( _p ) \
        _pcps_has_time_scale( &(_p)->dev )

#define _pcps_ddev_has_utc_parm( _p ) \
        _pcps_has_utc_parm( &(_p)->dev )

#define _pcps_ddev_has_asic_version( _p ) \
        _pcps_has_asic_version( &(_p)->dev )

#define _pcps_ddev_has_asic_features( _p ) \
        _pcps_has_asic_features( &(_p)->dev )

#define _pcps_ddev_has_fast_hr_timestamp( _p ) \
        _pcps_has_fast_hr_timestamp( &(_p)->dev )

#define _pcps_ddev_has_lan_intf( _p ) \
        _pcps_has_lan_intf( &(_p)->dev )

#define _pcps_ddev_has_ptp( _p ) \
        _pcps_has_ptp( &(_p)->dev )

#define _pcps_ddev_has_ptp_unicast( _p ) \
        _pcps_has_ri_ptp_unicast( &(_p)->ri )

#define _pcps_ddev_has_pzf( _p ) \
        _pcps_has_pzf( &(_p)->dev )

#define _pcps_ddev_has_corr_info( _p ) \
        _pcps_has_corr_info( &(_p)->dev )

#define _pcps_ddev_has_tr_distance( _p ) \
        _pcps_has_tr_distance( &(_p)->dev )

#define _pcps_ddev_has_evt_log( _p ) \
        _pcps_has_evt_log( &(_p)->dev )

#define _pcps_ddev_has_debug_status( _p ) \
        _pcps_has_debug_status( &(_p)->dev )

#define _pcps_ddev_has_stat_info( _p ) \
        _pcps_has_stat_info( &(_p)->dev )

#define _pcps_ddev_has_stat_info_mode( _p ) \
        _pcps_has_stat_info_mode( &(_p)->dev ) \

#define _pcps_ddev_has_stat_info_svs( _p ) \
        _pcps_has_stat_info_svs( &(_p)->dev ) \

#define _pcps_ddev_incoming_tfom_ignored( _p ) \
        _pcps_incoming_tfom_ignored( &(_p)->dev  )

#define _pcps_ddev_pci_cfg_err( _p ) \
        _pcps_pci_cfg_err( &(_p)->dev  )


// The macros below simplify read/write access to the clocks.

// Call the device's read function to write the command byte _cmd
// and read _n bytes to buffer _s.
#if !defined( _pcps_read )
  #define _pcps_read( _pddev, _cmd, _p, _n )  \
    ( (_pddev)->read( _pddev, (_cmd), (uchar FAR *)(_p), (_n) ) )
#endif

// Write a byte _b to a device. This is typically done by just writing
// the command byte from inside the read function.
#if !defined( _pcps_write_byte )
  #define _pcps_write_byte( _pddev, _b )  \
    _pcps_read( (_pddev), (_b), NULL, 0 )
#endif

// write a command plus the contents of a data buffer to a device.
// This is typically implemented as a function which uses the
// _pcps_write_byte() macro repeatedly.
#if !defined( _pcps_write )
  #define _pcps_write( _pddev, _cmd, _p, _n )  \
    pcps_write( (_pddev), (_cmd), (uchar FAR *)(_p), (_n) )
#endif

// Read data structures which exceed PCPS_FIFO_SIZE bytes.
// This can't be handled in a single read cycle and due to limitations
// of the clock's microprocessor these calls can up to 20 milliseconds.
// Currently these function is only used to read GPS specific data
// from GPS clocks.
#define _pcps_read_gps( _pddev, _cmd, _p, _n )  \
  pcps_read_gps( (_pddev), (_cmd), (uchar FAR *) (_p), (_n) )

// The write function opposite to the read function above.
#define _pcps_write_gps( _pddev, _cmd, _p, _n )  \
  pcps_write_gps( (_pddev), (_cmd), (uchar FAR *) (_p), (_n) )



// The macros below simplify reading/writing typed variables by
// determining the size automatically from the type of the variable.

// Read data from a device to variable _s.
// The number of bytes to read is determined by the size
// of _s. The accepted type of _s depends on the _cmd code.
#define _pcps_read_var( _pddev, _cmd, _s )  \
  _pcps_read( (_pddev), (_cmd), &(_s), sizeof( (_s) ) )

// Write data from variable _s to a device.
// The number of bytes to write is determined by the size
// of _s. The accepted type of _s depends on the _cmd code.
#define _pcps_write_var( _pddev, _cmd, _s )  \
  _pcps_write( (_pddev), (_cmd), &(_s), sizeof( (_s) ) )


// Read data structures which exceed PCPS_FIFO_SIZE bytes.
// This can't be handled in a single read cycle and due to limitations
// of the clock's microprocessor these calls can up to 20 milliseconds.
// Currently these function is only used to read GPS specific data
// from GPS clocks.
#define _pcps_read_gps_var( _pddev, _cmd, _s )  \
  _pcps_read_gps( (_pddev), (_cmd), &(_s), sizeof( (_s) ) )

// The write function opposite to the read function above.
#define _pcps_write_gps_var( _pddev, _cmd, _s )  \
  _pcps_write_gps( (_pddev), (_cmd), &(_s), sizeof( (_s) ) )


// Generate a hardware reset on a device. This macro should be used
// VERY carefully and should be avoided, if possible, since resetting
// a device could lock up the PC.
#define _pcps_force_reset( _pddev ) \
  _pcps_write_byte( (_pddev), PCPS_FORCE_RESET )


// The macro below reads a device's status port which includes
// the BUSY flag and the modulation signal of DCF77 receivers.
// The macro takes a (PCPS_DDEV *) as argument.
#define _pcps_ddev_read_status_port( _d ) \
  _mbg_inp8( (_d), 0, (_d)->status_port )

#define _pcps_ddev_status_busy( _d ) \
  ( _pcps_ddev_read_status_port( pddev ) & PCPS_ST_BUSY )


// The macro below checks whether a workaround is required to get/set
// IRIG cfg from a GPS169PCI with IRIG output and early firmware version
// This is handled in mbgdevio.c for direct access environments, and in
// macioctl.h for kernel device drivers.
#define _pcps_ddev_requires_irig_workaround( _d ) \
  ( ( _pcps_ddev_type_num( _d ) == PCPS_TYPE_GPS169PCI ) && \
    ( _pcps_ddev_fw_rev_num( _d ) < REV_HAS_GPS_DATA_16_GPS169PCI ) )


#if _PCPS_USE_USB

  #if !defined( MBGUSB_TIMEOUT_SEND_MS )
    #define MBGUSB_TIMEOUT_SEND_MS             500   // [ms]
  #endif

  #if !defined( MBGUSB_TIMEOUT_RECEIVE_MS )
    #define MBGUSB_TIMEOUT_RECEIVE_MS          500   // [ms]
  #endif

  #if !defined( MBGUSB_TIMEOUT_RECEIVE_CYCLIC_MS )
    // The USB read function may block until a packet has been received, or a
    // receive timeout has occurred. The cyclic USB read function has an overall
    // timeout of more than 1 second. In order to increase responsiveness we use
    // by default a shorter timeout interval plus some retries, if required.
    //
    // For some target environments it may be preferable to use only one
    // full timeout interval, so this setting can be overridden if required.
    #if !defined( _PCPS_USB_FULL_CYCLIC_INTV )
      #define _PCPS_USB_FULL_CYCLIC_INTV    1
    #endif

    #if _PCPS_USB_FULL_CYCLIC_INTV
      #define MBGUSB_TIMEOUT_RECEIVE_CYCLIC_MS    1200
    #else
      #define MBGUSB_TIMEOUT_RECEIVE_CYCLIC_MS    50
    #endif
  #endif


  #if !defined( _pcps_ms_to_usb_timeout )
    #define _pcps_ms_to_usb_timeout( _ms )     (_ms)
  #endif


  #if !defined( MBGUSB_TIMEOUT_SEND )
    #define MBGUSB_TIMEOUT_SEND            _pcps_ms_to_usb_timeout( MBGUSB_TIMEOUT_SEND_MS )
  #endif

  #if !defined( MBGUSB_TIMEOUT_RECEIVE )
    #define MBGUSB_TIMEOUT_RECEIVE         _pcps_ms_to_usb_timeout( MBGUSB_TIMEOUT_RECEIVE_MS )
  #endif

  #if !defined( MBGUSB_TIMEOUT_RECEIVE_CYCLIC )
    #define MBGUSB_TIMEOUT_RECEIVE_CYCLIC  _pcps_ms_to_usb_timeout( MBGUSB_TIMEOUT_RECEIVE_CYCLIC_MS )
  #endif


  #if defined( MBG_TGT_WIN32_PNP )

    #define _pcps_usb_write_ep_tmo( _d, _p, _sz, _ep_idx, _tmo, _irp ) \
      pcps_usb_transfer( _d, _ep_idx, _p, _sz, 1, _tmo, _irp )

    #define _pcps_usb_read_ep_tmo( _d, _p, _sz, _ep_idx, _tmo, _irp ) \
      pcps_usb_transfer( _d, _ep_idx, _p, _sz, 0, _tmo, _irp )

    #define _pcps_usb_write( _d, _p, _sz ) \
      _pcps_usb_write_ep_tmo( _d, _p, _sz, MBGUSB_EP_IDX_HOST_OUT, MBGUSB_TIMEOUT_SEND, (_d)->irp )

    #define _pcps_usb_read( _d, _p, _sz ) \
      _pcps_usb_read_ep_tmo( _d, _p, _sz, MBGUSB_EP_IDX_HOST_IN, MBGUSB_TIMEOUT_RECEIVE, (_d)->irp )

    #define _pcps_usb_read_cyclic( _d, _p, _sz, _irp ) \
      _pcps_usb_read_ep_tmo( _d, _p, _sz, MBGUSB_EP_IDX_HOST_IN_CYCLIC, MBGUSB_TIMEOUT_RECEIVE_CYCLIC, _irp )

    #define _pcps_usb_read_var_cyclic( _d, _p, _irp ) \
      _pcps_usb_read_cyclic( _d, _p, sizeof( *(_p) ), _irp ) 

  #elif defined( MBG_TGT_LINUX )

    #define _pcps_usb_write_ep_tmo( _d, _p, _sz, _ep_idx, _tmo )            \
      usb_bulk_msg( (_d)->udev,                                             \
                    usb_sndbulkpipe( (_d)->udev, (_d)->ep[_ep_idx].addr ),  \
                    _p, _sz, &actual_count, _tmo )

    #define _pcps_usb_read_ep_tmo( _d, _p, _sz, _ep_idx, _tmo )             \
      usb_bulk_msg( (_d)->udev,                                             \
                    usb_rcvbulkpipe( (_d)->udev, (_d)->ep[_ep_idx].addr ),  \
                    _p, _sz, &actual_count, _tmo )

    #define _pcps_usb_write( _d, _p, _sz ) \
      _pcps_usb_write_ep_tmo( _d, _p, _sz, MBGUSB_EP_IDX_HOST_OUT, MBGUSB_TIMEOUT_SEND )

    #define _pcps_usb_read( _d, _p, _sz ) \
      _pcps_usb_read_ep_tmo( _d, _p, _sz, MBGUSB_EP_IDX_HOST_IN, MBGUSB_TIMEOUT_RECEIVE )

    #define _pcps_usb_read_cyclic( _d, _p, _sz ) \
      _pcps_usb_read_ep_tmo( _d, _p, _sz, MBGUSB_EP_IDX_HOST_IN_CYCLIC, MBGUSB_TIMEOUT_RECEIVE_CYCLIC )

    #define _pcps_usb_read_var_cyclic( _d, _p ) \
      _pcps_usb_read_cyclic( _d, _p, sizeof( *(_p) ) ) 

  #endif  // target specific definitions


  #define _pcps_usb_write_var( _d, _p ) \
    _pcps_usb_write( _d, _p, sizeof( *(_p) ) )

  #define _pcps_usb_read_var( _d, _p ) \
    _pcps_usb_read( _d, _p, sizeof( *(_p) ) )

#endif



/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

/* PCPS_WRITE_FNC */
 short pcps_write( PCPS_DDEV *pddev, uint8_t cmd, const void FAR *buffer, uint16_t count ) ;

 short pcps_generic_io( PCPS_DDEV *pddev, uint8_t type, const void FAR *in_buff, uint8_t in_cnt, void FAR *out_buff, uint8_t out_cnt ) ;
/* PCPS_READ_FNC */
 short pcps_read_gps( PCPS_DDEV *pddev, uint8_t data_type, void FAR *buffer, uint16_t buffer_size ) ;

/* PCPS_WRITE_FNC */
 short pcps_write_gps( PCPS_DDEV *pddev, uint8_t data_type, const void FAR *buffer, uint16_t buffer_size ) ;

 short pcps_get_fw_id( PCPS_DDEV *pddev, PCPS_ID_STR FAR fw_id ) ;
 short pcps_check_id( PCPS_DDEV *pddev, const char FAR *ref ) ;
 short pcps_get_rev_num( char FAR *idstr ) ;
 int pcps_read_sernum( PCPS_DDEV *pddev ) ;
 int pcps_rsrc_claim( PCPS_DDEV *pddev ) ;
 void pcps_rsrc_release( PCPS_DDEV *pddev ) ;
 ushort pcps_port_from_pos( ushort pos ) ;
 uchar pcps_pos_from_port( ushort port ) ;
 PCPS_DEV_TYPE *pcps_get_dev_type( int bus_mask, ushort dev_id ) ;
 PCPS_DDEV *pcps_alloc_ddev( void ) ;
 void pcps_free_ddev( PCPS_DDEV *pddev ) ;
 int pcps_add_rsrc_io( PCPS_DDEV *pddev, ulong base, ulong num ) ;
 int pcps_add_rsrc_mem( PCPS_DDEV *pddev, MBG_MEM_ADDR start, ulong len ) ;
 int pcps_add_rsrc_irq( PCPS_DDEV *pddev, int16_t irq_num ) ;
 int pcps_init_ddev( PCPS_DDEV *pddev, int bus_flags, ushort dev_id ) ;
 int pcps_start_device( PCPS_DDEV *pddev, PCPS_BUS_NUM bus_num, PCPS_SLOT_NUM dev_fnc_num ) ;
 void pcps_cleanup_device( PCPS_DDEV *pddev ) ;
 void pcps_setup_and_start_pci_dev( PCPS_DDEV *pddev, PCPS_BUS_NUM bus_num, PCPS_SLOT_NUM dev_fnc_num ) ;
 void pcps_detect_pci_clocks( PCPS_DDEV_ALLOC_FNC alloc_fnc, void *alloc_arg, PCPS_DDEV_CLEANUP_FNC cleanup_fnc,  ushort vendor_id, PCPS_DEV_TYPE dev_type[],  int n_dev_types ) ;
 void pcps_detect_isa_clocks( PCPS_DDEV_ALLOC_FNC alloc_fnc, PCPS_DDEV_CLEANUP_FNC cleanup_fnc, PCPS_DDEV_REGISTER_FNC register_fnc, int isa_ports[PCPS_MAX_ISA_CARDS], int isa_irqs[PCPS_MAX_ISA_CARDS] ) ;
 void _MBG_INIT_CODE_ATTR pcps_detect_clocks_alloc( PCPS_DDEV_ALLOC_FNC alloc_fnc, void *alloc_arg, PCPS_DDEV_CLEANUP_FNC cleanup_fnc, int isa_ports[PCPS_MAX_ISA_CARDS], int isa_irqs[PCPS_MAX_ISA_CARDS] ) ;
 void _MBG_INIT_CODE_ATTR pcps_detect_clocks( int isa_ports[PCPS_MAX_ISA_CARDS], int isa_irqs[PCPS_MAX_ISA_CARDS] ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif

// We have used native alignment here, so no need to undo alignment at this place.

/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _PCPSDRVR_H */
