
/**************************************************************************
 *
 *  $Id: pcpsdrvr.c 1.46.2.59 2011/11/25 15:13:01 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Driver functions that detect Meinberg PC plug-in devices and set up
 *    the software environment (port base address, clock features, etc.).
 *
 *    These functions should be used with programs which have direct
 *    access to the hardware (e.g. device drivers).
 *
 *    Programs which access the devices via device drivers should
 *    use the functions provided by the mbgdevio module.
 *
 *    There are several preprocessor symbols defined at the top of
 *    pcpsdrvr.h which control the default support of some features
 *    under the different operating systems. If required, each of
 *    those symbols can be overridden by compiler arguments.
 *
 *    Basically the following devices are supported:
 *      USB v2:          DCF600USB, TCR600USB, MSF600USB, WVB600USB
 *      USB v1:          USB5131, TCR51USB, MSF51USB, WWVB51USB
 *      PCI express:     PEX511, TCR511PEX, GPS170PEX, PTP270PEX,
 *                       FRC511PEX, TCR170PEX, GPS180PEX, TCR180PEX
 *                       PZF180PEX
 *      PCI bus 5V/3.3V: PCI510, PCI511, GPS169PCI, GPS170PCI,
 *                       TCR510PCI, TCR167PCI, TCR511PCI
 *      PCI bus 5V:      PCI32, GPS167PCI, PCI509, GPS168PCI
 *      MCA bus:         PS31
 *      ISA bus:         PC31, PC32, GPS167PC
 *
 *    USB is not supported for some target environments, mainly because
 *    those operating systems don't provide full USB support.
 *
 *    PCI support is possible in two different ways. The preferred
 *    functions are compiled in if one of the symbols _PCPS_USE_PCI_PNP
 *    or _PCPS_USE_PCI_BIOS is defined != 0.
 *
 *    If _PCPS_USE_PCI_PNP is != 0 it is assumed that the operating
 *    system's PCI layer detects a new PCI device and calls a driver's
 *    add_device()/start_device() function to initialize the device.
 *    This new technique is supported with PNP operating systems
 *    (e.g. Win98, Win2K, newer Linux versions).
 *
 *    If _PCPS_USE_PCI_BIOS is != 0 the program scans the PCI bus
 *    during startup to detect and initialize supported PCI devices.
 *    This techique is used with non-PNP operating systems.
 *
 *    The symbol _PCPS_USE_RSRCMGR must be defined != 0 to include
 *    support of resource managers, if necessary.
 *
 *    If the symbol _PCPS_USE_MCA is defined != 0 then Micro Channel
 *    detection (and therefore auto-detection of a MCA clock) is
 *    supported.
 *
 *    MCA clocks are accessed using the same low level functions as
 *    ISA clocks, so if autodetection of MCA clocks is not supported
 *    then a MCA clock's known port number can be passed to
 *    pcps_detect_clocks() to let it be treated like an ISA clock.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsdrvr.c $
 *  Revision 1.46.2.59  2011/11/25 15:13:01  martin
 *  Support on-board event log.
 *  Revision 1.46.2.58  2011/11/23 17:47:33  martin
 *  Conditional code to test MM I/O for new PCI cards.
 *  Added debug messages for generic I/O.
 *  Revision 1.46.2.57  2011/11/18 10:15:33  martin
 *  Revision 1.46.2.56  2011/11/02 14:09:48  martin
 *  Revision 1.46.2.55  2011/11/01 09:10:59Z  martin
 *  Revision 1.46.2.54  2011/10/21 14:07:28  martin
 *  Revision 1.46.2.53  2011/10/06 13:35:06  martin
 *  Revision 1.46.2.52  2011/10/06 13:29:13  martin
 *  Temp. don't  delay for PTP270PEX under FreeBSD.
 *  Revision 1.46.2.51  2011/09/12 12:32:57  martin
 *  Revision 1.46.2.50  2011/09/09 08:28:57  martin
 *  Revision 1.46.2.49  2011/09/08 13:18:32  martin
 *  Always read the serial numbber directly from the device.
 *  Revision 1.46.2.48  2011/07/19 12:48:10  martin
 *  Unified low level functions and use 16 bit types for buffer sizes.
 *  Cleanup.
 *  Revision 1.46.2.47  2011/07/11 12:49:44  martin
 *  Revision 1.46.2.46  2011/07/11 11:00:42Z  martin
 *  Modified some debug code.
 *  Revision 1.46.2.45  2011/07/05 10:44:22  martin
 *  Fixed build errors under Unix.
 *  Revision 1.46.2.44  2011/07/05 10:18:59  martin
 *  Fixed pcps_start_device() for USBv2 devices.
 *  Added warnings in case a device is not handled
 *  by chip setup or device feature check.
 *  Revision 1.46.2.43  2011/06/29 14:02:49Z  martin
 *  Renamed PZF600PEX to PZF180PEX.
 *  Added support for TCR600USB, MSF600USB, and WVB600USB.
 *  Modified low level AMCC read functions for SPARC.
 *  Fixed handling of unaligned access for SPARC.
 *  Modified DEBUG_IO code.
 *  Added some debug messages.
 *  Updated some comments.
 *  Revision 1.46.2.42  2011/06/21 15:20:56  martin
 *  Fixed build under DOS.
 *  Revision 1.46.2.41  2011/06/20 16:53:34Z  martin
 *  account for generic MBG_SYS_TIME with nanosecond resolution.
 *  Revision 1.46.2.40  2011/05/16 17:41:11  martin
 *  Initialize device semaphores only early at device initializition
 *  if required, otherwise later, since early initialization can lead
 *  to a trap e.g. under Windows.
 *  Revision 1.46.2.39  2011/05/06 13:47:39Z  martin
 *  Support PZF600PEX.
 *  Revision 1.46.2.38  2011/04/19 15:06:56  martin
 *  Fixed build error on bigendian target.
 *  Revision 1.46.2.37  2011/04/12 15:28:56  martin
 *  Use common mutex primitives from mbgmutex.h.
 *  Revision 1.46.2.36  2011/04/01 10:38:00  martin
 *  Modified mutex/spinlock initialization, and do deinitializaton.
 *  Fixed compiler warnings.
 *  Revision 1.46.2.35  2011/03/25 11:10:34  martin
 *  Optionally support timespec for sys time (USE_TIMESPEC).
 *  Revision 1.46.2.34  2011/03/22 10:25:57  martin
 *  Modifications to support NetBSD.
 *  Revision 1.46.2.33  2011/03/21 16:26:03  martin
 *  Account for modified _pcps_kfree().
 *  Revision 1.46.2.32  2011/02/16 10:14:37  martin
 *  Set up basic default receiver info for devices which don't
 *  support this structure.
 *  Revision 1.46.2.31  2011/02/15 14:24:57Z  martin
 *  Revision 1.46.2.30  2011/02/10 09:18:07  martin
 *  Revision 1.46.2.29  2011/02/09 17:08:30Z  martin
 *  Specify I/O range number when calling port I/O macros
 *  so they can be used for different ranges under BSD.
 *  Revision 1.46.2.28  2011/02/09 16:42:12  martin
 *  Revision 1.46.2.27  2011/02/09 15:27:49  martin
 *  Revision 1.46.2.26  2011/02/09 14:43:19Z  martin
 *  Revision 1.46.2.25  2011/02/07 15:47:28  martin
 *  Fixed a potential trap in kernel messages.
 *  Revision 1.46.2.24  2011/02/04 14:44:45  martin
 *  Revision 1.46.2.23  2011/02/01 17:12:04  martin
 *  Revision 1.46.2.22  2011/02/01 15:08:34  martin
 *  Revision 1.46.2.21  2011/02/01 12:12:18  martin
 *  Revision 1.46.2.20  2011/01/31 17:30:28  martin
 *  Preliminary virt addr under *BSD.
 *  Revision 1.46.2.19  2011/01/28 10:34:06  martin
 *  Moved MBG_TGT_SUPP_MEM_ACC definition to pcpsdev.h.
 *  Revision 1.46.2.18  2011/01/27 15:13:08  martin
 *  Added some debug messages in pcps_start_device().
 *  Revision 1.46.2.17  2011/01/27 13:39:33  martin
 *  Revision 1.46.2.16  2011/01/27 11:01:48  martin
 *  Support static device list (no malloc) and use it under FreeBSD.
 *  Revision 1.46.2.15  2011/01/26 16:40:14  martin
 *  Fixed build under FreeBSD.
 *  Revision 1.46.2.14  2011/01/26 11:30:29  martin
 *  Fixed PTP270PEX boot delay.
 *  Revision 1.46.2.13  2011/01/07 14:00:58  daniel
 *  Re-enabled wait period for PTP270PEX
 *  Revision 1.46.2.12  2010/11/23 11:07:56Z  martin
 *  Support memory mapped access under DOS.
 *  Revision 1.46.2.11  2010/11/22 14:19:27Z  martin
 *  Support DCF600USB.
 *  Cleanup.
 *  Revision 1.46.2.10  2010/10/06 09:24:02  martin
 *  Revision 1.46.2.9  2010/09/27 13:09:22Z  martin
 *  Revision 1.46.2.8  2010/09/21 13:10:15  daniel
 *  Check for raw IRIG data support in reciver info.
 *  Revision 1.46.2.7  2010/09/02 12:19:24Z  martin
 *  Introduced and use new function check_ri_feature().
 *  Also detect support for raw IRIG data from RECEIVER_INFO.
 *  Added debug code.
 *  Sleeping for PTP270PEX if uptime is too low needs to be fixed.
 *  Revision 1.46.2.6  2010/08/16 15:41:28  martin
 *  Revision 1.46.2.5  2010/08/13 11:56:49  martin
 *  Fixed build on WIN32_NON_PNP.
 *  Revision 1.46.2.4  2010/08/13 11:20:23Z  martin
 *  If required, wait until PTP270PEX has finished booting.
 *  Revision 1.46.2.3  2010/08/11 13:41:47Z  martin
 *  Code cleanup.
 *  Revision 1.46.2.2  2010/07/14 14:51:56  martin
 *  Use direct pointer to memory maopped timestamp.
 *  Revision 1.46.2.1  2010/06/30 15:02:12  martin
 *  Support GPS180PEX and TCR180PEX.
 *  Revision 1.46  2009/12/15 14:45:33  daniel
 *  Account for feature to read the raw IRIG bits.
 *  Revision 1.45  2009/09/29 07:24:50Z  martin
 *  Use standard feature flag to check if fast HR time is supported.
 *  Revision 1.44  2009/06/23 07:10:47  martin
 *  Fixed/modified some debug messages.
 *  Revision 1.43  2009/06/19 12:13:59  martin
 *  Check if TCR cards support raw IRIG time.
 *  Revision 1.42  2009/06/09 10:15:33  daniel
 *  Check if card has LAN interface and supports PTP.
 *  Revision 1.41  2009/04/08 08:33:20  daniel
 *  Check whether the TCR511PCI or devices with
 *  RECEIVER_INFO support IRIG control function bits.
 *  Revision 1.40  2009/03/27 09:55:13Z  martin
 *  Added some debug messages.
 *  Account for renamed library symbols.
 *  Revision 1.39  2009/03/19 12:04:31Z  martin
 *  Adjust endianess of ASIC version and ASIC features after having read.
 *  Revision 1.38  2009/03/17 15:33:53  martin
 *  Support reading IRIG control function bits.
 *  Revision 1.37  2009/03/13 09:17:00Z  martin
 *  Bug fix: Hadn't checked whether TCR170PEX card provides the 
 *  programmable synthesizer.
 *  As a fix moved the code from the body of check_opt_features() 
 *  into pcps_start_device() so that the check is done for every 
 *  type of card.
 *  Swap receiver_info to make this work on non-x86 architectures.
 *  Support configurable time scales, and reading/writing GPS UTC 
 *  parameters via the PC bus.
 *  Use mbg_get_pc_cycles() instead of _pcps_get_cycles().
 *  Revision 1.36  2009/01/13 12:03:57Z  martin
 *  Generate a separate warning message if the firmware could not 
 *  be read from an ISA card.
 *  Care about "long long" in debug msg.
 *  Revision 1.35  2008/12/16 14:38:49Z  martin
 *  Account for new devices PTP270PEX, FRC270PEX, TCR170PEX, and WWVB51USB.
 *  Check the firmware / ASIC version of PEX cards and flag the device
 *  unsafe for IRQs if the versions are older than required.
 *  Check whether PEX511 and PCI511 support HR time.
 *  Moved initialization of common spinlocks and mutexes to pcps_start_device().
 *  Take access cycles count in the low level routines, with interrupts disabled.
 *  Cleanup for pcps_read_usb() which is now possible since access cycles count 
 *  is now taken inside the low evel routines.
 *  Support mapped I/O resources, unaligned access and endianess conversion.
 *  Account for ASIC_FEATURES being coded as flags, and account for 
 *  new symbol PCI_ASIC_HAS_MM_IO.
 *  Account for new MBG_PC_CYCLES type.
 *  Account for signed irq_num.
 *  Renamed MBG_VIRT_ADDR to MBG_MEM_ADDR.
 *  Use MBG_MEM_ADDR type for memory rather than split high/low types.
 *  Distinguish device port variables for IRQ handling.
 *  Preliminarily support USB latency compensation under Win32 PNP targets
 *  and account for USB EHCI microframe timing which requires a different 
 *  latency compensation approach. This is useful if a USB 2.0 hub is connected 
 *  between device and host.
 *  Also read the ASIC version at device initialization.
 *  pcps_alloc_ddev() does not take a parameter anymore.
 *  Cleaned up comments.
 *  Revision 1.34  2008/02/27 10:03:02  martin
 *  Support TCR51USB and MSF51USB.
 *  Preliminary support for mapped memory access under Windows and Linux.
 *  Enabled PCPS_IRQ_1_SEC for USB within WIN32 targets 
 *  in pcps_start_device().
 *  Fixed a bug in pcps_write() where the error code 
 *  that was returned from a USB device was misinterpreted
 *  due to a signed/unsigned mismatch (added typecast).
 *  Removed obsolete function pcps_cleanup_all_devices().
 *  Code cleanup.
 *  Revision 1.33  2008/01/31 08:51:30Z  martin
 *  Picked up changes from 1.31.2.1:
 *  Changed default definition of PCI_DWORD to uint32_t.
 *  Removed erraneous brace from debug code.
 *  Revision 1.32  2007/09/26 11:05:57Z  martin
 *  Added support for USB in general and new USB device USB5131.
 *  Renamed ..._USE_PCIMGR symbols to ..._USE_PCI_PNP.
 *  Renamed ..._USE_PCIBIOS symbols to ..._USE_PCI_BIOS.
 *  Added new symbol _USE_ISA_PNP to exclude non-PNP stuff.
 *  from build if ISA devices are also handled by the PNP manager.
 *  Use new MBG_... codes defined in mbgerror.h.
 *  Unified timeout handling in low level functions by using an inline function.
 *  Renamed pcps_pnp_start_device() to pcps_start_device().
 *  Renamed pcps_setup_pci_dev() to pcps_setup_and_startpci_dev().
 *  Merged code from init_ddev_cfg() and finish_ddev_cfg() into pcps_start_device().
 *  Improved and unified handling of ISA devices.
 *  Removed calling register_pnp_devices() from pcps_detect_clocks(),
 *  this is now called directly.
 *  Added missing IRIG support to pcps_rsrc_register_device().
 *  Revision 1.31  2007/07/17 08:22:47Z  martin
 *  Added support for TCR511PEX and GPS170PEX.
 *  Revision 1.30  2007/07/16 12:56:01Z  martin
 *  Added support for PEX511.
 *  Rewrote common resource handling code in order to simplify
 *  OS specific code.
 *  Revision 1.29  2007/03/02 09:40:33Z  martin
 *  Use generic port I/O macros.
 *  Pass PCPS_DDEV structure to the low level read functions.
 *  Use new _pcps_..._timeout_clk() macros.
 *  Added init code qualifier.
 *  Preliminary support for *BSD.
 *  Preliminary support for USB.
 *  Revision 1.28  2006/07/11 10:24:20  martin
 *  Use _fmemcpy() in pcps_generic_io() to support environments which
 *  require far data pointers.
 *  Revision 1.27  2006/07/07 09:41:15  martin
 *  Renamed pci_..() function calls to _mbg_pci_..() calls which are defined according to the
 *  OS requirements, in order to avoid naming conflicts.
 *  Revision 1.26  2006/06/19 15:28:52  martin
 *  Added support for TCR511PCI.
 *  Modified parameters required to detect ISA cards. 
 *  The array of port addresses does no more require a 0 address
 *  as last value.
 *  Revision 1.25  2006/03/10 11:01:27  martin
 *  Added support for PCI511.
 *  Revision 1.24  2005/11/03 15:50:45Z  martin
 *  Added support for GPS170PCI.
 *  Revision 1.23  2005/09/16 08:21:08Z  martin
 *  Also flag PCI cards which have base_addr set to 0 as uninitialized.
 *  Revision 1.22  2005/06/02 10:32:07Z  martin
 *  Changed more types to C99 fixed size types.
 *  New function pcps_generic_io().
 *  Revision 1.21  2004/12/13 14:19:38Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.20  2004/11/09 13:02:48Z  martin
 *  Redefined fixed width data types using standard C99 types.
 *  Fixed warnings about lvalue casts.
 *  Revision 1.19  2004/10/14 15:01:24  martin
 *  Added support for TCR167PCI.
 *  Revision 1.18  2004/09/06 15:16:57Z  martin
 *  Support a GPS_DATA interface where sizes are specified 
 *  by 16 instead of the original 8 bit quantities, thus allowing 
 *  to transfer data blocks which exceed 255 bytes.
 *  Conditionally skip assertions under Linux.
 *  Revision 1.17  2004/04/22 14:47:54  martin
 *  Fixed conversion of firmware rev. number.
 *  Revision 1.16  2004/04/07 09:45:04Z  martin
 *  Support new feature PCPS_HAS_IRIG_TX for GPS169PCI.
 *  Revision 1.15  2003/12/22 16:15:21Z  martin
 *  Support PCPS_HR_TIME for TCR510PCI.
 *  Revision 1.14  2003/07/30 07:28:23Z  martin
 *  Moved prototype for register_pci_devices() outside to top of file.
 *  Revision 1.13  2003/07/08 15:11:55  martin
 *  Support PCI PNP interface under Linux.
 *  New function pcps_rsrc_release().
 *  Made some functions public.
 *  Renamed some public functions to start with pcps_...
 *  Revision 1.12  2003/06/19 10:08:43  MARTIN
 *  Renamed some functions to follow common naming conventions.
 *  Made a function's parameter pointer const.
 *  Changes due to renamed symbols in pcpsdev.h.
 *  Check devices for _pcps_has_ucap() support.
 *  Revision 1.11  2003/05/16 09:28:06  MARTIN
 *  Moved inclusion of some headers to pcpsdrvr.h.
 *  Revision 1.10  2003/04/09 16:35:57  martin
 *  Supports PCI510, GPS169PCI, and TCR510PCI,
 *  and new PCI_ASIC used by those devices.
 *  Revision 1.9  2003/03/20 11:42:37  martin
 *  Fixed syntax for QNX.
 *  Revision 1.8  2002/08/09 08:25:50  MARTIN
 *  Support feature PCPS_CAN_CLR_CAP_BUFF.
 *  Fixed a bug resulting in an unterminated string
 *  if SERNUM was being read.
 *  Revision 1.7  2002/02/26 09:31:57  MARTIN
 *  New function pcps_read_sernum().
 *  Revision 1.6  2002/02/19 09:46:26  MARTIN
 *  Use new header mbg_tgt.h to check the target environment.
 *  Removed function pcps_sn_str_from_ident(), use new
 *  function mbg_gps_ident_decode() from identdec.c now.
 *  If a PCI clock's interface is not properly configured don't 
 *  enable the device and set the read function to the new 
 *  dummy function pcps_read_null() to prevent driver from 
 *  accessing random ports.
 *  Revision 1.5  2002/02/01 12:06:12  MARTIN
 *  Added support for GPS168PCI.
 *  Removed obsolete code.
 *  Revision 1.4  2001/11/30 09:52:48  martin
 *  Added support for event_time which, however, requires
 *  a custom GPS firmware.
 *  Revision 1.3  2001/09/18 06:59:18  MARTIN
 *  Account for new preprocessor symbols in the header file.
 *  Added some type casts to avoid compiler warnings under Win32.
 *  Added some debug messages to clock detection functions.
 *  Revision 1.2  2001/03/16 14:45:33  MARTIN
 *  New functions and definitions to support PNP drivers.
 *  Revision 1.1  2001/03/01 16:26:41  MARTIN
 *  Initial revision for the new library.
 *
 **************************************************************************/

#define _PCPSDRVR
  #include <pcpsdrvr.h>
#undef _PCPSDRVR

#include <parmpcps.h>
#include <parmgps.h>
#include <identdec.h>
#include <mbgddmsg.h>
#include <plxdefs.h>
#include <pci_asic.h>
#include <amccdefs.h>

#if defined( MBG_TGT_WIN32_PNP )
  #include <usbdrv.h>
  #include <pcpsdefs.h>
  #include <ntddk.h>
  #include <stdio.h>
#elif defined( MBG_TGT_WIN32 )
  #include <pcps_ioc.h>
  #include <stdio.h>
#endif

#if !defined( MBG_TGT_LINUX ) && !defined( MBG_TGT_BSD )
  #include <assert.h>
#endif

#if defined( MBG_TGT_FREEBSD )
  #include <sys/rman.h>
  #include <sys/libkern.h>
#endif

#if _PCPS_USE_MCA
  #include <mca.h>
#endif

#if _PCPS_USE_PCI
  #include <pci.h>
#endif

#if _PCPS_USE_USB
  #define MBGUSB_MIN_ENDPOINTS_REQUIRED  3
#endif


// time required for PTP270PEX to be ready after booting
#define MAX_BOOT_TIME_PTP270PEX    27  // [s]


#if !defined( DEBUG_IO )
  #if defined( MBG_TGT_NETBSD )
    #define DEBUG_IO        ( defined( MBG_DEBUG ) && ( MBG_DEBUG >= DEBUG_LVL_IO ) )
  #else
    #define DEBUG_IO        ( defined( DEBUG ) && ( DEBUG >= DEBUG_LVL_IO ) )
  #endif
#endif

#if !defined( DEBUG_PORTS )
  #define DEBUG_PORTS     ( defined( DEBUG ) && ( DEBUG >= DEBUG_LVL_PORTS ) )
#endif

#if !defined( DEBUG_SERNUM )
  #define DEBUG_SERNUM    ( defined( DEBUG ) && ( DEBUG >= DEBUG_LVL_SERNUM ) )
#endif

#define _PCPS_USE_MM_IO  ( 0 && MBG_TGT_SUPP_MEM_ACC && !MBG_USE_MM_IO_FOR_PCI )


extern const char pcps_driver_name[];


// In some environments special far functions are are neither
// required nor supported, so redefine calls to those functions
// to appropriate standard function calls.
#if defined( MBG_TGT_NETWARE ) || defined( MBG_TGT_WIN32 ) || \
    defined( MBG_TGT_LINUX ) || defined( MBG_TGT_BSD ) || \
    defined( MBG_TGT_QNX )
  #define _fmemcpy( _d, _s, _n )      memcpy( _d, _s, _n )
  #define _fstrlen( _s )              strlen( _s )
  #define _fstrncmp( _s1, _s2, _n )   strncmp( (_s1), (_s2), (_n) )
#elif defined( MBG_TGT_OS2 )
  #define _fstrncmp( _s1, _s2, _n )   _fmemcmp( (_s1), (_s2), (_n) )
#endif

#if defined( MBG_TGT_OS2 )
  // Watcom C Compiler options for the OS/2 device driver result in
  // warnings if automatic stack addresses are passed to functions.
  #define static_wc static
  #define FMT_03X "%X"
  #define FMT_08X "%X"
#else
  #define static_wc
  #define FMT_03X "%03X"
  #define FMT_08X "%08lX"
#endif

#if defined( MBG_TGT_LINUX )
  typedef unsigned int PCI_DWORD;
#else
  typedef uint32_t PCI_DWORD;
#endif


#if defined( MBG_TGT_LINUX )

  #define _pcps_irq_flags \
    unsigned long irq_flags;

  #define _pcps_disb_local_irq_save() \
    local_irq_save( irq_flags )

  #define _pcps_local_irq_restore() \
    local_irq_restore( irq_flags )

#elif defined( MBG_TGT_WIN32 )

  #define _pcps_irq_flags \
    KIRQL old_irq_lvl;

  #define _pcps_disb_local_irq_save() \
     KeRaiseIrql( HIGH_LEVEL, &old_irq_lvl )

  #define _pcps_local_irq_restore() \
     KeLowerIrql( old_irq_lvl )

#else

  // Nothing to define here.

#endif

#if !defined( _pcps_irq_flags ) && \
    !defined( _pcps_disb_local_irq_save ) && \
    !defined( _pcps_local_irq_restore)
  #define _pcps_irq_flags
  #define _pcps_disb_local_irq_save();
  #define _pcps_local_irq_restore();
#endif


#if defined( MBG_TGT_LINUX ) && defined( time_after )
  #define _pcps_time_after( _curr, _tmo ) \
          time_after( (unsigned long) _curr, (unsigned long) _tmo )
#else
  #define _pcps_time_after( _curr, _tmo )   ( _curr >= _tmo )
#endif


#if defined( MBG_TGT_DOS ) || \
    defined( MBG_TGT_QNX )
  #define CHECK_UPTIME    0
#elif defined( MBG_TGT_FREEBSD )
  // Under FreeBSD (at least 8.2) the kernel calls to read uptime always
  // return 1 when this driver is loaded automatically, so the system
  // locks up if we wait util uptime has reached a certain value.
  #define CHECK_UPTIME    0
#else
  #define CHECK_UPTIME    1
#endif





#if CHECK_UPTIME

static /*HDR*/
long mbg_delta_sys_time_ms( const MBG_SYS_TIME *t2, const MBG_SYS_TIME *t1 )
{
  #if USE_GENERIC_SYS_TIME
    long dt = ( t2->sec - t1->sec ) * 1000;
    #if defined ( MBG_TGT_LINUX ) && defined( MBG_TGT_KERNEL )
      int64_t tmp64 = t2->nsec - t1->nsec;
      do_div( tmp64, 1000000 );
      dt += tmp64;
    #else
      dt += ( t2->nsec - t1->nsec ) / 1000000;
    #endif
    return dt;
  #elif defined( MBG_TGT_WIN32 )
    return (long) ( ( t2->QuadPart - t1->QuadPart ) / HNS_PER_MS );
  #else
    return 0;
  #endif

}  // mbg_delta_sys_time_ms



static /*HDR*/
void report_uptime( const MBG_SYS_UPTIME *p_uptime )
{
  #if defined( MBG_TGT_LINUX )
    printk( KERN_INFO "%s: system uptime %llu jiffies -> %llu s, required %u s\n",
            pcps_driver_name, (unsigned long long) ( get_jiffies_64() - INITIAL_JIFFIES ),
            (unsigned long long) *p_uptime, MAX_BOOT_TIME_PTP270PEX );
  #elif defined( MBG_TGT_BSD )
    printf( "%s: system uptime %llu s, required %u s\n",
            pcps_driver_name, (unsigned long long) *p_uptime, MAX_BOOT_TIME_PTP270PEX );
  #elif defined( MBG_TGT_WIN32 )
    WCHAR wcs_msg[120];

    swprintf( wcs_msg, L"system uptime: %I64u s, required %u s",
              (int64_t) *p_uptime, MAX_BOOT_TIME_PTP270PEX );
    _evt_msg( GlbDriverObject, wcs_msg );
  #endif

}  // report_uptime



static /*HDR*/
void check_uptime( void )
{
  MBG_SYS_TIME t1;
  MBG_SYS_TIME t2;
  MBG_SYS_UPTIME uptime;
  int delayed = 0;
  int i = 0;

  mbg_get_sys_time( &t1 );

  for (;;)
  {
    mbg_get_sys_uptime( &uptime );

    #if !defined( DEBUG )
      if ( !delayed )
    #endif
        report_uptime( &uptime );

    if ( uptime == 0 )
      break;  // assume uptime not supported

    if ( uptime >= MAX_BOOT_TIME_PTP270PEX )
      break;

    mbg_sleep_sec( 1 );
    delayed = 1;

    if ( ++i >= MAX_BOOT_TIME_PTP270PEX )
    {
      delayed = 1;
      break;
    }
  }

  if ( delayed )
  {
    long dt;

    mbg_get_sys_time( &t2 );

    dt = mbg_delta_sys_time_ms( &t2, &t1 );

    #if defined( MBG_TGT_LINUX )
      printk( KERN_INFO "PTP270PEX startup delay: %li.%03li s\n",
              dt / 1000, ( ( dt < 0 ) ? -dt : dt ) % 1000 );
    #elif defined( MBG_TGT_BSD )
      printf( "PTP270PEX startup delay: %li.%03li s\n",
              dt / 1000, ( ( dt < 0 ) ? -dt : dt ) % 1000 );
    #elif defined( MBG_TGT_WIN32 )
    {
      WCHAR wcs_msg[128];
      swprintf( wcs_msg, L"PTP270PEX startup delay: %li.%03li s",
                dt / 1000, ( ( dt < 0 ) ? -dt : dt ) % 1000 );
      _evt_msg( GlbDriverObject, wcs_msg );
    }
    #endif
  }

}  // check_uptime

#endif



static /*HDR*/
int pcps_check_pex_irq_unsafe( PCPS_DDEV *pddev, uint16_t req_fw_ver,
                               uint8_t req_asic_ver_major, uint8_t req_asic_ver_minor )
{
  int rc = !_pcps_pex_irq_is_safe( _pcps_ddev_fw_rev_num( pddev ), req_fw_ver,
                                   _pcps_ddev_asic_version( pddev ),
                                   req_asic_ver_major, req_asic_ver_minor );

  if ( rc )
  {
    pddev->irq_stat_info |= PCPS_IRQ_STAT_UNSAFE;

    // Prevent the driver from writing IRQ ACK to the card even if IRQs
    // should be unintentionally enabled.
    pddev->irq_ack_port = 0;
    pddev->irq_ack_mask = 0;
  }

  return rc;

}  // pcps_check_pex_irq_unsafe



#if MBG_TGT_SUPP_MEM_ACC

static __mbg_inline /*HDR*/
int has_mapped_sys_virtual_address( PCPS_DDEV *pddev )
{
  return pddev->mm_addr != NULL;

}  // has_mapped_sys_virtual_address



static __mbg_inline /*HDR*/
int map_sys_virtual_address( PCPS_DDEV *pddev )
{
  pddev->mm_tstamp_addr = NULL;  // unless configured below

  #if defined ( MBG_TGT_WIN32 )
  {
    PHYSICAL_ADDRESS pAD;

    pAD.QuadPart = pddev->rsrc_info.mem[0].start;
    pddev->mm_addr = MmMapIoSpace( pAD, sizeof( *pddev->mm_addr ), MmNonCached );
  }
  #elif defined ( MBG_TGT_LINUX )

    pddev->mm_addr = ioremap( ( (ulong) pddev->rsrc_info.mem[0].start ), sizeof( *pddev->mm_addr ) );

  #elif defined ( MBG_TGT_FREEBSD )

    pddev->mm_addr = rman_get_virtual( pddev->rsrc_info.mem[0].bsd.res );

  #elif defined ( MBG_TGT_NETBSD )

    pddev->mm_addr = bus_space_vaddr( pddev->rsrc_info.mem[0].bsd.bst, pddev->rsrc_info.mem[0].bsd.bsh );

  #else  // DOS, ...

    pddev->mm_addr = (PCPS_MM_LAYOUT FAR *) pddev->rsrc_info.mem[0].start;

  #endif  // target specific code

  if ( pddev->mm_addr == NULL )
    return -1;

  if ( _pcps_ddev_is_pci_mbgpex( pddev ) )
    pddev->mm_tstamp_addr = &pddev->mm_addr->mbgpex.tstamp;
  else
    if ( _pcps_ddev_is_pci_pex8311( pddev ) )
      pddev->mm_tstamp_addr = &pddev->mm_addr->pex8311.tstamp;

  _mbgddmsg_3( MBG_DBG_INIT_DEV, "MM addr: base: 0x%p, tstamp: 0x%p, offs: 0x%02lX",
               pddev->mm_addr, pddev->mm_tstamp_addr,
               (ulong) pddev->mm_tstamp_addr - (ulong) pddev->mm_addr );

  return 0;

}  // map_sys_virtual_address



static __mbg_inline /*HDR*/
void unmap_sys_virtual_address( PCPS_DDEV *pddev )
{

  if ( has_mapped_sys_virtual_address( pddev ) )
  {
    #if defined ( MBG_TGT_WIN32 )
      MmUnmapIoSpace( pddev->mm_addr, sizeof( *pddev->mm_addr ) );
    #elif defined ( MBG_TGT_LINUX )
      iounmap( pddev->mm_addr );
    #else  // DOS, ...
      // nothing to do
    #endif

    pddev->mm_addr = NULL;
    pddev->mm_tstamp_addr = NULL;
  }

}  // unmap_sys_virtual_address

#endif  // MBG_TGT_SUPP_MEM_ACC



#if defined( DEBUG ) && defined( MBG_TGT_LINUX )

#if 0  //##++++
static inline
long _cyc_to_us( long long cyc )
{
  cyc *= 1000;
  do_div( cyc, cpu_khz );

  return (long) cyc;
}
#endif

static inline
long _cyc_to_ns( long long cyc )
{
  cyc *= 1000000;
  do_div( cyc, cpu_khz );

  return (long) cyc;
}

#endif



#if defined( __GNUC__ )
// Avoid "no previous prototype" with some gcc versions.
__mbg_inline
int pcps_wait_busy( PCPS_DDEV *pddev ) __attribute__((always_inline));
#endif

__mbg_inline /*HDR*/
int pcps_wait_busy( PCPS_DDEV *pddev )
{
#if _PCPS_USE_MM_IO

#if 0
#define _pcps_ddev_read_status_port( _d )          \
  ( _pcps_ddev_is_pci_mbgpex( _d ) ?               \
      ( (_d)->mm_addr->mbgpex.asic.status_port ) : \
      _mbg_inp8( (_d), 0, (_d)->status_port ) )
#elif 0
  uint32_t st = _pcps_ddev_is_pci_mbgpex( pddev ) ?
      pddev->mm_addr->mbgpex.asic.status_port :
      _pcps_ddev_read_status_port( pddev );

  if ( st & PCPS_ST_BUSY )
#else
  uint32_t st;
  if ( _pcps_ddev_is_pci_mbgpex( pddev ) )
    st = pddev->mm_addr->mbgpex.asic.status_port.ul;
  else
    st = _pcps_ddev_read_status_port( pddev );

  if ( st & PCPS_ST_BUSY )
#endif

#else
  if ( _pcps_ddev_status_busy( pddev ) )
#endif
  {
    #if defined( MBG_TGT_BSD )
      struct timeval tv_start;

      getmicrouptime( &tv_start );

      while ( _pcps_ddev_status_busy( pddev ) )
      {
        struct timeval tv_now;
        long long delta_ms;

        getmicrouptime( &tv_now );
        delta_ms = ( ( tv_now.tv_sec - tv_start.tv_sec ) * 1000 )
                 + ( ( tv_now.tv_usec - tv_start.tv_usec ) / 1000 );
        if ( delta_ms > _pcps_ddev_timeout_clk( pddev ) )
          return MBG_ERR_TIMEOUT;
      }
    #elif _PCPS_USE_CLOCK_TICK
      clock_t timeout_val = clock() + _pcps_ddev_timeout_clk( pddev );

      while ( _pcps_ddev_status_busy( pddev ) )
        if ( _pcps_time_after( clock(), timeout_val ) )
          return MBG_ERR_TIMEOUT;
    #else
      long cnt = _pcps_ddev_timeout_clk( pddev );

      for ( ; _pcps_ddev_status_busy( pddev ); cnt-- )
        if ( cnt == 0 )
          return MBG_ERR_TIMEOUT;
    #endif
  }

  return 0;

}  // pcps_wait_busy



/*--------------------------------------------------------------
 * Name:         pcps_read_null()
 *               pcps_read_std()
 *               pcps_read_amcc_s5933()
 *               pcps_read_amcc_s5920()
 *               pcps_read_asic()
 *               pcps_read_usb()
 *
 * Purpose:      These functions are used for low level access
 *               to Meinberg plug-in devices. The function
 *               to be used depends on the clock's bus type and
 *               interface chip.
 *
 * Input:        pcfg    pointer to the clock's configuration
 *               cmd     the command code for the board
 *               count   the number of bytes to be read
 *
 * Output:       buffer    the bytes that could be read
 *
 * Ret value:    MBG_SUCCESS      no error
 *               MBG_ERR_TIMEOUT  board is busy for too long
 *-------------------------------------------------------------*/

// The dummy read function below is used if a clock is
// not properly initialized, in order to avoid I/O access
// on unspecified ports.

static /*HDR*/  /* PCPS_READ_FNC */
short pcps_read_null( PCPS_DDEV *pddev, uint8_t cmd,
                      void FAR *buffer, uint16_t count )
{

  return MBG_ERR_TIMEOUT;

}  // pcps_read_null



// The function below must be used to access a clock with
// standard ISA or micro channel bus.

static /*HDR*/  /* PCPS_READ_FNC */
short pcps_read_std( PCPS_DDEV *pddev, uint8_t cmd,
                     void FAR *buffer, uint16_t count )
{
  uint8_t FAR *p = (uint8_t FAR *) buffer;
  PCPS_IO_ADDR_MAPPED port = _pcps_ddev_io_base_mapped( pddev, 0 );
  int i;
  _pcps_irq_flags

  #if DEBUG_IO
    _mbgddmsg_1( MBG_DBG_INIT_DEV, "pcps_read_std: cmd %02X", cmd );
  #endif

  _pcps_disb_local_irq_save();
  mbg_get_pc_cycles( &pddev->acc_cycles );
  // write the command byte
  _mbg_outp8( pddev, 0, port, cmd );
  _pcps_local_irq_restore();

  // wait until BUSY flag goes low or timeout
  if ( pcps_wait_busy( pddev ) < 0 )
    return MBG_ERR_TIMEOUT;


  // no timeout: read bytes from the board's FIFO
  for ( i = 0; i < count; i++ )
  {
    *p = _mbg_inp8( pddev, 0, port );

    #if DEBUG_IO
      _mbgddmsg_1( MBG_DBG_DETAIL, "pcps_read_std: %02X", *p );
    #endif

    p++;
  }

  return MBG_SUCCESS;

} // pcps_read_std



#if _PCPS_USE_PCI

// The function below must be used to access a clock with
// PCI bus and AMCC S5933 interface chip.

static /*HDR*/  /* PCPS_READ_FNC */
short pcps_read_amcc_s5933( PCPS_DDEV *pddev, uint8_t cmd,
                            void FAR *buffer, uint16_t count )
{
  uint8_t FAR *p = (uint8_t FAR *) buffer;
  PCPS_IO_ADDR_MAPPED port = _pcps_ddev_io_base_mapped( pddev, 0 );
  int i;
  _pcps_irq_flags


  #if DEBUG_IO
    _mbgddmsg_1( MBG_DBG_INIT_DEV, "pcps_read_amcc_s5933: cmd %02X", cmd );
  #endif

  // reset inbound mailbox and FIFO status
  _mbg_outp8( pddev, 0, port + AMCC_OP_REG_MCSR + 3, 0x0C );

  // set FIFO
  _mbg_outp8( pddev, 0, port + AMCC_OP_REG_INTCSR + 3, 0x3C );

  _pcps_disb_local_irq_save();
  mbg_get_pc_cycles( &pddev->acc_cycles );
  // write the command byte
  _mbg_outp8( pddev, 0, port + AMCC_OP_REG_OMB1, cmd );
  #if defined( MBG_ARCH_SPARC )
    udelay( 3 );
  #endif
  _pcps_local_irq_restore();

  // wait until BUSY flag goes low or timeout
  if ( pcps_wait_busy( pddev ) < 0 )
    return MBG_ERR_TIMEOUT;


  // no timeout: read bytes from the board's FIFO
  for ( i = 0; i < count; i++ )
  {
    if ( _mbg_inp16_to_cpu( pddev, 0, port + AMCC_OP_REG_MCSR ) & 0x20 )
      return MBG_ERR_FIFO;

    p[i] = _mbg_inp8( pddev, 0, port + AMCC_OP_REG_FIFO + ( i % sizeof( uint32_t) ) );

    #if DEBUG_IO
      if ( ( cmd == PCPS_GIVE_FW_ID_1 ) || ( cmd == PCPS_GIVE_FW_ID_2 ) )
        _mbgddmsg_2( MBG_DBG_DETAIL, "pcps_read_amcc_s5933: %02X '%c'", p[i], p[i] );
      else
        _mbgddmsg_1( MBG_DBG_DETAIL, "pcps_read_amcc_s5933: %02X", p[i] );
    #endif
  }

  return MBG_SUCCESS;

}  /* pcps_read_amcc_s5933 */

#endif  /* _PCPS_USE_PCI */



#if _PCPS_USE_PCI

// The function below must be used to access a clock with
// PCI bus and AMCC S5920 interface chip.

static /*HDR*/  /* PCPS_READ_FNC */
short pcps_read_amcc_s5920( PCPS_DDEV *pddev, uint8_t cmd,
                            void FAR *buffer, uint16_t count )
{
  uint8_t FAR *p = (uint8_t FAR *) buffer;
  PCPS_IO_ADDR_MAPPED data_port = _pcps_ddev_io_base_mapped( pddev, 1 );
  int i;
  int dt_quot;
  int dt_rem;
  _pcps_irq_flags


  #if DEBUG_IO
    _mbgddmsg_5( MBG_DBG_INIT_DEV, "pcps_read_amcc_s5920: cmd %02X, port: %04lX, data_port: %04lX, buffer: %p, count: %u",
                 cmd, (ulong) _pcps_ddev_io_base_mapped( pddev, 0 ) + AMCC_OP_REG_OMB,
                 (ulong) data_port, buffer, count );
  #endif

  _pcps_disb_local_irq_save();
  mbg_get_pc_cycles( &pddev->acc_cycles );
  // write the command byte
  _mbg_outp8( pddev, 0, _pcps_ddev_io_base_mapped( pddev, 0 ) + AMCC_OP_REG_OMB, cmd );
  #if defined( MBG_ARCH_SPARC )
    udelay( 3 );
  #endif
  _pcps_local_irq_restore();

  dt_quot = count / 4;
  dt_rem = count % 4;

  // wait until BUSY flag goes low or timeout
  if ( pcps_wait_busy( pddev ) < 0 )
    return MBG_ERR_TIMEOUT;


  if ( count )
  {
    // do this only if we must read data

    uint32_t ul;

    // first read full 32 bit words
    for ( i = 0; i < dt_quot; i++ )
    {
      ul = _mbg_inp32_to_cpu( pddev, 1, data_port );
      #if DEBUG_IO
        if ( ( cmd == PCPS_GIVE_FW_ID_1 ) || ( cmd == PCPS_GIVE_FW_ID_2 ) )
        {
          _mbgddmsg_5( MBG_DBG_INIT_DEV, "pcps_read_amcc_s5920: %08X  \"%c%c%c%c\"", ul,
                       BYTE_OF( ul, 0 ), BYTE_OF( ul, 1 ), BYTE_OF( ul, 2 ), BYTE_OF( ul, 3 ) );
        }
        else
          _mbgddmsg_1( MBG_DBG_INIT_DEV, "pcps_read_amcc_s5920: %08X", ul );
      #endif
      _mbg_put_unaligned( ul, (uint32_t FAR *) p );
      p += sizeof( ul );
    }

    // then read the remaining bytes, if required
    if ( dt_rem )
    {
      ul = _mbg_inp32_to_cpu( pddev, 1, data_port );

      for ( i = 0; i < dt_rem; i++ )
      {
        #if DEBUG_IO
          _mbgddmsg_1( MBG_DBG_INIT_DEV, "pcps_read_amcc_s5920: %02X", BYTE_OF( ul, i ) );
        #endif

        *p++ = BYTE_OF( ul, i );
      }
    }
  }
  else
    _mbg_inp32( pddev, 1, data_port );  // do a dummy read

  return MBG_SUCCESS;

}  // pcps_read_amcc_s5920

#endif  /* _PCPS_USE_PCI */



#if _PCPS_USE_PCI

// The function below must be used to access a clock with
// PCI bus and Meinberg PCI interface ASIC.

static /*HDR*/  /* PCPS_READ_FNC */
short pcps_read_asic( PCPS_DDEV *pddev, uint8_t cmd,
                      void FAR *buffer, uint16_t count )
{
  uint8_t FAR *p = (uint8_t FAR *) buffer;
  PCPS_IO_ADDR_MAPPED data_port;
  PCI_ASIC_REG ar;
  int i;
  int dt_quot;
  int dt_rem;
  _pcps_irq_flags


  #if DEBUG_IO
    _mbgddmsg_3( MBG_DBG_INIT_DEV, "pcps_read_asic: cmd: 0x%02X (0x%08X), cnt: %u", 
                 cmd, _cpu_to_mbg32( cmd ), count );
  #endif

  _pcps_disb_local_irq_save();
  mbg_get_pc_cycles( &pddev->acc_cycles );
  // write the command byte
  _mbg_outp32( pddev, 0, _pcps_ddev_io_base_mapped( pddev, 0 )
               + offsetof( PCI_ASIC, pci_data ), cmd );
  _pcps_local_irq_restore();

  data_port = _pcps_ddev_io_base_mapped( pddev, 0 )
                + offsetof( PCI_ASIC, addon_data );
  dt_quot = count / 4;
  dt_rem = count % 4;

  // wait until BUSY flag goes low or timeout
  if ( pcps_wait_busy( pddev ) < 0 )
    return MBG_ERR_TIMEOUT;


  // no timeout: read bytes from the board's FIFO

  // first read full 32 bit words
  for ( i = 0; i < dt_quot; i++ )
  {
    ar.ul = _mbg_inp32_to_cpu( pddev, 0, data_port );
    #if DEBUG_IO
      _mbgddmsg_1( MBG_DBG_INIT_DEV, "pcps_read_asic: %08X", ar.ul );
    #endif
    _mbg_put_unaligned( ar.ul, (uint32_t FAR *) p );
    p += sizeof( ar.ul );
    data_port += sizeof( ar.ul );
  }

  // then read the remaining bytes, if required
  if ( dt_rem )
  {
    ar.ul = _mbg_inp32_to_cpu( pddev, 0, data_port );

    for ( i = 0; i < dt_rem; i++ )
    {
      #if DEBUG_IO
        _mbgddmsg_1( MBG_DBG_INIT_DEV, "pcps_read_asic: %02X", ar.b[i] );
      #endif

      *p++ = ar.b[i];
    }
  }

  return MBG_SUCCESS;

}  // pcps_read_asic



#if _PCPS_USE_MM_IO

// The function below must be used to access a clock with
// PCI bus and Meinberg PCI interface ASIC.

static /*HDR*/   /* type: PCPS_READ_FNC */
short pcps_read_asic_mm( PCPS_DDEV *pddev, uint8_t cmd,
                         void FAR *buffer, uint16_t count )
{
  short ret_val = MBG_SUCCESS;
  uint8_t FAR *p = (uint8_t FAR *) buffer;
  volatile uint32_t *p_data_reg;
  PCI_ASIC_REG ar;
  int i;
  int dt_quot;
  int dt_rem;
  _pcps_irq_flags
  #if defined( DEBUG ) && defined( MBG_TGT_LINUX )
    MBG_PC_CYCLES t_after_cmd = 0;
    MBG_PC_CYCLES t_after_busy = 0;
    MBG_PC_CYCLES t_done = 0;
    volatile uint32_t *p_cmd_reg;
  #endif


  #if DEBUG_IO
    _mbgddmsg_3( MBG_DBG_INIT_DEV, "pcps_read_asic_mm: cmd: 0x%02X (0x%08X), cnt: %u", 
                 cmd, _cpu_to_mbg32( cmd ), count );
  #endif

  _pcps_disb_local_irq_save();

  // write the command byte
  #if defined( DEBUG ) && defined( MBG_TGT_LINUX )
    p_cmd_reg = &pddev->mm_addr->mbgpex.asic.pci_data.ul;
    mbg_get_pc_cycles( &pddev->acc_cycles );
    *p_cmd_reg = cmd;
  #else
    mbg_get_pc_cycles( &pddev->acc_cycles );
    pddev->mm_addr->mbgpex.asic.pci_data.ul = cmd;
  #endif

  #if defined( DEBUG ) && defined( MBG_TGT_LINUX )
    mbg_get_pc_cycles( &t_after_cmd );
  #endif

  _pcps_local_irq_restore();

  p_data_reg = &pddev->mm_addr->mbgpex.asic.addon_data.ul[0];
  dt_quot = count / 4;
  dt_rem = count % 4;

  // wait until BUSY flag goes low or timeout
  if ( pcps_wait_busy( pddev ) < 0 )
  {
    ret_val = MBG_ERR_TIMEOUT;
    goto done;
  }


  #if defined( DEBUG ) && defined( MBG_TGT_LINUX )
    mbg_get_pc_cycles( &t_after_busy );
  #endif

  // no timeout: read bytes from the board's FIFO

  // first read full 32 bit words
  for ( i = 0; i < dt_quot; i++ )
  {
    ar.ul = *p_data_reg;
    #if DEBUG_IO
      _mbgddmsg_1( MBG_DBG_INIT_DEV, "pcps_read_asic_mm: %08X", ar.ul );
    #endif
    _mbg_put_unaligned( ar.ul, (uint32_t FAR *) p );
    p += sizeof( ar.ul );
    p_data_reg++;
  }

  // then read the remaining bytes, if required
  if ( dt_rem )
  {
    ar.ul = *p_data_reg;

    for ( i = 0; i < dt_rem; i++ )
    {
      #if DEBUG_IO
      #endif

      *p++ = ar.b[i];
    }
  }

done:
  #if defined( DEBUG ) && defined( MBG_TGT_LINUX )
  {
    long read_time;
    mbg_get_pc_cycles( &t_done );

    read_time = _cyc_to_ns( t_done - t_after_busy );

    printk( KERN_ERR "mm cmd: 0x%02X (%u), write %li ns, busy: %li ns, read: %li/%li ns\n",
            cmd, count,
            _cyc_to_ns( t_after_cmd - pddev->acc_cycles ),
            _cyc_to_ns( t_after_busy - t_after_cmd ),
            read_time,
            count ? ( read_time / count ) : 0
          );
  }
  #endif

  return ret_val;

}  // pcps_read_asic_mm

#endif  // _PCPS_USE_MM_IO

#endif  // _PCPS_USE_PCI



#if _PCPS_USE_USB

// The function below must be used to access a device connected via USB.

static /*HDR*/  /* PCPS_READ_FNC */
short pcps_read_usb( PCPS_DDEV *pddev, uint8_t cmd,
                     void FAR *buffer, uint16_t count )
{
  int actual_count = 0;
  short rc;

  mbg_get_pc_cycles( &pddev->acc_cycles );

  rc = _pcps_usb_write_var( pddev, &cmd );

  if ( ( rc == MBG_SUCCESS ) && ( count && buffer ) )
  {
    #if defined( MBG_TGT_WIN32_PNP )
      int temp_fn1 = frame_number_1;
      int temp_fn2 = frame_number_2;
      LARGE_INTEGER UsbPreCount  = Count1;
      LARGE_INTEGER UsbPostCount = Count2;
    #endif

    rc = _pcps_usb_read( pddev, buffer, count );

    #if defined( MBG_TGT_WIN32_PNP )
      if ( cmd == PCPS_GIVE_HR_TIME && rc == PCPS_SUCCESS )
      {
        ULONGLONG usb_latency_cycles;
        ULONGLONG cycles_diff;
        ULONGLONG time_diff;
        ULONGLONG frame_length_cycles;
        int FrameNumberDiff;

        if ( pddev->usb_20_mode )
        {
          // USB 2.0 microframe timing.
          // Just add an offset to compensate constant latency.
          // This value has been determined experimentally on different hardware platforms
          usb_latency_cycles = ( (ULONGLONG) PerfFreq.QuadPart ) / 20000UL; // represents 50 us
        }
        else
        {
          // USB 1.1 mode with millisecond timing.
          // Compensate latency to millisecond frame boundaries.

          if ( (temp_fn2 - temp_fn1) < 0 )
            FrameNumberDiff = 2;
          else
            FrameNumberDiff = temp_fn2 - temp_fn1;

          cycles_diff = (ULONGLONG) ( UsbPostCount.QuadPart - UsbPreCount.QuadPart );
          frame_length_cycles = (ULONGLONG) ( (ULONGLONG) PerfFreq.QuadPart ) / 1000UL;

          if ( ( temp_fn1 == 0 ) && ( temp_fn2 == 0 ) )
          {
            if ( cycles_diff > frame_length_cycles )
              usb_latency_cycles =  cycles_diff - frame_length_cycles; 
            else
              usb_latency_cycles =  frame_length_cycles - cycles_diff;
          }
          else
            usb_latency_cycles =  cycles_diff - ( ( FrameNumberDiff - 1 ) * frame_length_cycles );

          #if defined( DEBUG )
            swprintf( pddev->wcs_msg, L"FD %d CD %I64u l %I64u fl %I64u", FrameNumberDiff,
                      cycles_diff, usb_latency_cycles, frame_length_cycles );
            _dbg_evt_msg( GlbDriverObject, pddev->wcs_msg );
          #endif
        }

        pddev->acc_cycles += usb_latency_cycles;
      }
    #endif
  }

  return rc;

}  // pcps_read_usb

#endif



/*--------------------------------------------------------------
 * Name:         pcps_write()
 *
 * Purpose:      Write data to a device.
 *
 * Input:        pddev       pointer to the device information
 *               cmd         the address of buffer holding the
 *                           date/time/status information
 *               read_fnc    function to access the board
 *
 * Output:       --
 *
 * Ret value:    MBG_SUCCESS       no error
 *               MBG_ERR_TIMEOUT   board is busy for too long
 *               MBG_ERR_NBYTES    the number of parameter bytes
 *                                 did not match the number of
 *                                 data bytes expected
 *               MBG_ERR_STIME     the date, time or status
 *                                 has been invalid
 *-------------------------------------------------------------*/

/*HDR*/  /* PCPS_WRITE_FNC */
short pcps_write( PCPS_DDEV *pddev, uint8_t cmd,
                  const void FAR *buffer, uint16_t count )
{
  short rc;

#if _PCPS_USE_USB
  if ( _pcps_ddev_is_usb( pddev ) )
  {
    int actual_count = 0;  // required by macro
    int n = sizeof( cmd ) + count;
    uint8_t *p = _pcps_kmalloc( n );

    if ( p == NULL )
      return MBG_ERR_NO_MEM;

    p[0] = cmd;
    memcpy( &p[1], buffer, count );

    rc = _pcps_usb_write( pddev, p, n );

    if ( rc == MBG_SUCCESS )
    {
      rc = _pcps_usb_read( pddev, p, 1 );

      if ( rc == MBG_SUCCESS )
        rc = (int8_t) p[0];  // return the rc from the board
    }

    _pcps_kfree( p, n );
  }
  else
#endif // _PCPS_USE_USB
  {
    const uint8_t FAR *p = (const uint8_t FAR *) buffer;
    int i;
    uint8_t bytes_expected;
    int8_t write_rc;

    // Write the command and read one byte which will contain
    // the number of data bytes that must follow.
    rc = _pcps_read_var( pddev, cmd, bytes_expected );

    #if DEBUG_IO
      _mbgddmsg_4( MBG_DBG_DETAIL, "pcps_write: cmd %02X, %u bytes, expects %u, rc: %i",
                   cmd, count, bytes_expected, rc );
    #endif

    if ( rc < 0 )
      goto done;


    // Check if the number of data bytes to be written is correct.
    if ( bytes_expected != count )
    {
      rc = MBG_ERR_NBYTES;
      goto done;
    }


    // Write all bytes but the last one without reading anything.
    bytes_expected--;

    for ( i = 0; i < bytes_expected; i++ )
    {
      #if DEBUG_IO
        _mbgddmsg_2( MBG_DBG_DETAIL, "pcps_write: byte %i: 0x%02X", i, *p );
      #endif

      rc = _pcps_write_byte( pddev, *p++ );

      if ( rc < 0 )
        goto done;
    }

    // Write the last byte and read the completion code.
    #if DEBUG_IO
      _mbgddmsg_2( MBG_DBG_DETAIL, "pcps_write: last byte %i: 0x%02X", i, *p );
    #endif

    rc = _pcps_read_var( pddev, *p++, write_rc );

    // If an error code has been returned by the I/O function,
    // return that code, otherwise return the completion code
    // read from the board.
    if ( !( rc < 0 ) )
      rc = write_rc;
  }

done:
  #if DEBUG_IO
    _mbgddmsg_1( MBG_DBG_DETAIL, "pcps_write: return %i", rc );
  #endif

  return rc;

}  // pcps_write



/*--------------------------------------------------------------
 * Name:         pcps_generic_io()
 *
 * Purpose:      Write data to and/or read data from a device.
 *
 * Input:        pddev       pointer to the device information
 *               cmd         the address of buffer holding the
 *                           date/time/status information
 *               read_fnc    function to access the board
 *
 * Output:       --
 *
 * Ret value:    MBG_SUCCESS       no error
 *               MBG_ERR_TIMEOUT   board is busy for too long
 *               MBG_ERR_NBYTES    the number of parameter bytes
 *                                 did not match the number of
 *                                 data bytes expected
 *               MBG_ERR_STIME     the date, time or status
 *                                 has been invalid
 *-------------------------------------------------------------*/

/*HDR*/
short pcps_generic_io( PCPS_DDEV *pddev, uint8_t type,
                       const void FAR *in_buff, uint8_t in_cnt,
                       void FAR *out_buff, uint8_t out_cnt )
{
  const uint8_t FAR *p;
  int i;
  short rc;
  uint8_t tmp_byte;
  int8_t data_read[PCPS_FIFO_SIZE];
  uint8_t bytes_to_read;

  #if DEBUG_IO
    #if defined( MBG_TGT_DOS )
      #define FP_FMT  "%Fp"
    #else
      #define FP_FMT  "%p"
    #endif
    _mbgddmsg_5( MBG_DBG_DETAIL, "pcps_generic_io: type 0x%02X, in_buff: " FP_FMT
                 " (%u), out_buf " FP_FMT " (%u)",
                 type, in_buff, in_cnt, out_buff, out_cnt );
  #endif

  // Write the command and read one byte which will contain
  // the number of data bytes that must follow.
  rc = _pcps_read_var( pddev, PCPS_GENERIC_IO, tmp_byte );

  if ( rc < 0 )
    return rc;


  // Check if the number of data bytes to be written is correct.
  if ( tmp_byte != 3 )
    return MBG_ERR_NBYTES;


  #if DEBUG_IO
    _mbgddmsg_3( MBG_DBG_DETAIL, "pcps_generic_io: going to write type 0x%02X, in_sz %u, out_sz %u",
                 type, in_cnt, out_cnt );
  #endif

  // Write the 3 bytes which are expected:
  rc = _pcps_write_byte( pddev, type );

  if ( rc != MBG_SUCCESS )
    goto done;


  rc = _pcps_write_byte( pddev, in_cnt );

  if ( rc != MBG_SUCCESS )
    goto done;


  if ( in_cnt == 0 )
    tmp_byte = out_cnt;
  else
  {
    rc = _pcps_write_byte( pddev, out_cnt );

    if ( rc != MBG_SUCCESS )
      goto done;


    // Write the input parameters
    #if DEBUG_IO
      _mbgddmsg_0( MBG_DBG_DETAIL, "pcps_generic_io: going to write input bytes" );
    #endif

    p = (const uint8_t FAR *) in_buff;
    tmp_byte = in_cnt - 1;

    for ( i = 0; i < tmp_byte; i++ )
    {
      rc = _pcps_write_byte( pddev, *p++ );

      if ( rc < 0 )
        goto done;
    }

    tmp_byte = *p;
  }


  bytes_to_read = 2 + out_cnt;

  if ( bytes_to_read > sizeof( data_read ) )
    bytes_to_read = sizeof( data_read );


  // Write the last byte and read the completion code.
  rc = _pcps_read( pddev, tmp_byte, data_read, bytes_to_read );

  if ( out_cnt )   //##++ should do some more plausibility checks
    if ( rc == MBG_SUCCESS )
    {
      _fmemcpy( out_buff, &data_read[2], out_cnt );
    }

done:
  // If an error code has been returned by the I/O function,
  // return that code, otherwise return the completion code
  // read from the board.
  return ( rc < 0 ) ? rc : data_read[0];

}  // pcps_generic_io



/*--------------------------------------------------------------
 * Name:         pcps_read_gps_block()
 *
 * Purpose:      Get a block of data from GPS clock device.
 *               This is a local function which is called
 *               by pcps_read_gps().
 *
 * Input:        pddev         pointer to the device information
 *               data_type     the code assigned to the data type
 *               buffer_size   the size of the buffer
 *               block_num     the number of the block to read
 *               block_size    the size of the block to read
 *
 * Output:       buffer      filled with data
 *
 * Ret value:    MBG_SUCCESS
 *               MBG_ERR_TIMEOUT
 *               MBG_ERR_NBYTES
 *-------------------------------------------------------------*/

static /*HDR*/
short pcps_read_gps_block( PCPS_DDEV *pddev,
                           uint8_t data_type,
                           void FAR *buffer,
                           uint16_t buffer_size,
                           uint8_t block_num,
                           uint8_t block_size )
{
  short rc;
  uint16_t n_bytes;
  uint8_t size_n_bytes;
  uint8_t uc;


  /* Determine which interface buffer size is supported
     and use the appropriate size specification */
  if ( _pcps_ddev_has_gps_data_16( pddev ) )
    size_n_bytes = 2;
  else
  {
    if ( buffer_size > 255 )
      return MBG_ERR_NBYTES;   // Error ...

    size_n_bytes = 1;
  }

  #if DEBUG_IO
    _mbgddmsg_4( MBG_DBG_DETAIL,
       "pcps_read_gps_block: cmd 0x%02X, block %u (%u), size_n_bytes = %u",
       data_type, block_num, block_size, size_n_bytes );
  #endif

  // Write the command, expect to read one byte.
  rc = _pcps_read_var( pddev, PCPS_READ_GPS_DATA, uc );

  if ( rc != MBG_SUCCESS )   // Error ...
    return rc;

  if ( uc != 1 ) // The board doesn't expect exactly one more byte
  {
    if ( uc == 0 )
    {
      // The board can't respond now. This may occur if a
      // GPS receiver is still initializing after power-up.
      #if DEBUG_IO
        _mbgddmsg_0( MBG_DBG_DETAIL, "pcps_read_gps_block: board not yet initialized" );
      #endif

      return MBG_ERR_NOT_READY;
    }
    else
    {
      #if DEBUG_IO
        _mbgddmsg_1( MBG_DBG_DETAIL, "pcps_read_gps_block: board expects %u bytes rather than 1", uc );
      #endif

      return MBG_ERR_NBYTES;   // Error ...
    }
  }

  // Write the code corresponding to the type of data we
  // want to read, expect to read the expected size.
  n_bytes = 0;
  rc = _pcps_read( pddev, data_type, &n_bytes, size_n_bytes );

  if ( rc != MBG_SUCCESS )   // Error ...
    return rc;

  #if defined( MBG_ARCH_BIG_ENDIAN )
    // Swap n_bytes regardless of whether we have actuall read 1 or 2 bytes.
    // If we have read only 1 byte then the other one is 0.
      n_bytes = _mbg16_to_cpu( n_bytes );
  #endif

  #if DEBUG_IO
    _mbgddmsg_2( MBG_DBG_DETAIL, "pcps_read_gps_block: board expects data size %u, buffer size %u", 
                 n_bytes, buffer_size );
  #endif

  if ( n_bytes == 0 )
    return MBG_ERR_INV_TYPE;

  if ( n_bytes != buffer_size )  // Size of data structure does not match.
    return MBG_ERR_NBYTES;


  // Write the block number and read n bytes of data.
  rc = _pcps_read( pddev, block_num, buffer, block_size );

  return rc;

}  // pcps_read_gps_block



/*--------------------------------------------------------------
 * Name:         pcps_read_gps()
 *
 * Purpose:      Get a data structure from a GPS clock.
 *
 * Input:        pddev         pointer to the device information
 *               data_type     the code assigned to the data type
 *               buffer_size   the size of the buffer
 *
 * Output:       buffer        filled with data
 *
 * Ret value:    MBG_SUCCESS
 *               MBG_ERR_TIMEOUT
 *               MBG_ERR_NBYTES
 *-------------------------------------------------------------*/

/*HDR*/  /* PCPS_READ_FNC */
short pcps_read_gps( PCPS_DDEV *pddev,
                     uint8_t data_type,
                     void FAR *buffer,
                     uint16_t buffer_size )
{
  uint8_t FAR *p = (uint8_t FAR *) buffer;
  short rc = 0;
  int dt_quot;
  int dt_rem;
  int block_num;


  #if DEBUG_IO
    _mbgddmsg_3( MBG_DBG_DETAIL, "Going to read GPS data, type: %02X, addr: %p, size: %u",
                 data_type, buffer, buffer_size );
  #endif

  // Split buffer size to a number of blocks of PCPS_FIFO_SIZE
  // and a number of remaining bytes (less than PCPS_FIFO_SIZE).
  dt_quot = buffer_size / PCPS_FIFO_SIZE;
  dt_rem = buffer_size % PCPS_FIFO_SIZE;

  // Read dt_quot full blocks of data.
  for ( block_num = 0; block_num < dt_quot; block_num++ )
  {
    rc = pcps_read_gps_block( pddev, data_type, p, buffer_size,
                              (uint8_t) block_num, PCPS_FIFO_SIZE );

    if ( rc != MBG_SUCCESS )   // Error ...
      goto done;

    // Move the destination pointer to the next free byte.
    p += PCPS_FIFO_SIZE;
  }


  // Read dt_rem additional bytes of data.
  if ( dt_rem )
    rc = pcps_read_gps_block( pddev, data_type, p, buffer_size,
                              (uint8_t) block_num, (uint8_t) dt_rem );

done:
  #if DEBUG_IO
    _mbgddmsg_1( MBG_DBG_DETAIL, "Done reading GPS data, rc: %i", rc );
  #endif

  return rc;

}  // pcps_read_gps



/*--------------------------------------------------------------
 * Name:         pcps_write_gps()
 *
 * Purpose:      Write a data structure to a GPS clock.
 *
 * Input:        pddev         pointer to the device information
 *               data_type     the code assigned to the data type
 *               buffer        the data to write
 *               buffer_size   the size of the buffer
 *               read_fnc      function to access the board
 *
 * Output:       --
 *
 * Ret value:    MBG_SUCCESS
 *               MBG_ERR_TIMEOUT
 *               MBG_ERR_NBYTES
 *-------------------------------------------------------------*/

/*HDR*/  /* PCPS_WRITE_FNC */
short pcps_write_gps( PCPS_DDEV *pddev,
                      uint8_t data_type,
                      const void FAR *buffer,
                      uint16_t buffer_size )
{
  const uint8_t FAR *p = (const uint8_t FAR *) buffer;
  short rc;
  short i;
  uint16_t n_bytes;
  uint8_t size_n_bytes;
  uint8_t uc;


  /* Determine which interface buffer size is supported
     and use the appropriate size specification */
  if ( _pcps_ddev_has_gps_data_16( pddev ) )
    size_n_bytes = 2;
  else
  {
    if ( buffer_size > 255 )
      return MBG_ERR_NBYTES;   // Error ...

    size_n_bytes = 1;
  }

  #if DEBUG_IO
    _mbgddmsg_1( MBG_DBG_DETAIL, "pcps_write_gps: size_n_bytes = %u", size_n_bytes );
  #endif

  // Write the command, expect to read one byte.
  rc = _pcps_read_var( pddev, PCPS_WRITE_GPS_DATA, uc );

  if ( rc != MBG_SUCCESS )   // Error ...
    return rc;

  if ( uc != 1 ) // The board doesn't expect exactly one more byte
  {
    if ( uc == 0 )
    {
      // The board can't respond now. This may occur if a
      // GPS receiver is still initializing after power-up.
      #if DEBUG_IO
        _mbgddmsg_0( MBG_DBG_DETAIL, "pcps_write_gps: board not yet initialized" );
      #endif

      return MBG_ERR_NOT_READY;
    }
    else
    {
      #if DEBUG_IO
        _mbgddmsg_1( MBG_DBG_DETAIL, "pcps_write_gps: board expects %u bytes rather than 1", uc );
      #endif

      return MBG_ERR_NBYTES;   // Error ...
    }
  }

  // Write the code corresponding to the type of data we
  // want to write, expect to read the expected size.
  n_bytes = 0;
  rc = _pcps_read( pddev, data_type, &n_bytes, size_n_bytes );

  if ( rc != MBG_SUCCESS )   // Error ...
    return rc;

  #if defined( MBG_ARCH_BIG_ENDIAN )
    // Swap n_bytes regardless of whether we have actuall read 1 or 2 bytes.
    // If we have read only 1 byte then the other one is 0.
    n_bytes = _mbg16_to_cpu( n_bytes );
  #endif

  #if DEBUG_IO
    _mbgddmsg_2( MBG_DBG_DETAIL, "pcps_write_gps: board expects data size %u, buffer size %u", 
                 n_bytes, buffer_size );
  #endif

  if ( n_bytes != buffer_size )  // The board doesn't expect the number
    return MBG_ERR_NBYTES;      // of bytes we were going to write.


  // Write all bytes but the last one without reading.
  buffer_size--;

  for ( i = 0; i < buffer_size; i++ )
  {
    rc = _pcps_write_byte( pddev, *p++ );

    if ( rc != MBG_SUCCESS )   // Error ...
      return rc;
  }


  // Write the last byte and read the completion code.
  rc = _pcps_read_var( pddev, *p, n_bytes );

  // If an error code has been returned by read_fnc, return that
  // code, otherwise return the completion code read from the board.
  return rc ? rc : n_bytes;

}  // pcps_write_gps



/*--------------------------------------------------------------
 * Name:         pcps_get_fw_id()
 *
 * Purpose:      This function tries to read the firmware ID
 *               from the board. It should be used to check
 *               if the board is properly installed and can
 *               be accessed without problems.
 *
 * Input:        pddev       pointer to the device information
 *
 * Output:       fw_id       buffer filled with ASCIIZ string
 *
 * Ret value:    MBG_SUCCESS      no error
 *               MBG_ERR_TIMEOUT  the board is busy for too long
 *-------------------------------------------------------------*/

/*HDR*/
short pcps_get_fw_id( PCPS_DDEV *pddev, PCPS_ID_STR FAR fw_id )
{
  short rc;


  // read first part of the firmware ID
  rc = _pcps_read( pddev, PCPS_GIVE_FW_ID_1, &fw_id[0], PCPS_FIFO_SIZE );

  if ( rc != MBG_SUCCESS )
    return rc;   // may be timeout


  // read second part of the firmware ID
  rc = _pcps_read( pddev, PCPS_GIVE_FW_ID_2, &fw_id[PCPS_FIFO_SIZE], PCPS_FIFO_SIZE );

  if ( rc != MBG_SUCCESS )
    return rc;   // may be timeout


  // terminate the string with 0

  fw_id[PCPS_ID_SIZE - 1] = 0;


  return MBG_SUCCESS;

}  // pcps_get_fw_id



/*--------------------------------------------------------------
 * Name:         pcps_check_id()
 *
 * Purpose:      Check an ASCIIZ string for a valid signature.
 *
 * Input:        pddev       pointer to the device information
 *               ref         the reference signature
 *
 * Output:       --
 *
 * Ret value:    MBG_SUCCESS      no error
 *               MBG_ERR_FW_ID    the firmware ID is not valid
 *-------------------------------------------------------------*/

/*HDR*/
short pcps_check_id( PCPS_DDEV *pddev, const char FAR *ref )
{
  // check if the first characters of the string match the reference

  if ( ref )
    if ( _fstrncmp( _pcps_ddev_fw_id( pddev ), ref, _fstrlen( ref ) ) )
      return MBG_ERR_FW_ID;

  return MBG_SUCCESS;

}  // pcps_check_id



/*--------------------------------------------------------------
 * Name:         pcps_get_rev_num()
 *
 * Purpose:      Get a version number from an ID string.
 *
 * Input:        idstr     the ID string
 *
 * Output:       --
 *
 * Ret value:    on success: the version number in hex
 *                           (e.g. 0x0270 for version 2.7)
 *               on error: 0
 *-------------------------------------------------------------*/

/*HDR*/
short pcps_get_rev_num( char FAR *idstr )
{
  int i;
  int len = _fstrlen( idstr ) - 2;
  char c;

  uchar rev_num_hi;
  uchar rev_num_lo;

  for ( i = 0; i < len; i++ )
  {
    if ( idstr[i + 1] == '.' )
    {
      rev_num_hi = idstr[i] & 0x0F;
      rev_num_lo = ( idstr[i + 2] & 0x0F ) << 4;

      c = idstr[i + 3];

      if ( c >= '0' && c <= '9' )
        rev_num_lo |= c & 0x0F;

      return ( rev_num_hi << 8 ) | rev_num_lo;
    }
  }

  return 0;

}  // pcps_get_rev_num



/*--------------------------------------------------------------
 * Name:         pcps_read_sernum()
 *
 * Purpose:      This function tries to read the clock's S/N
 *               from the board, if supported by the clock.
 *
 * Input:        pddev       pointer to the device information
 *
 * Output:       pddev       sernum field filled with ASCIIZ
 *
 * Ret value:    MBG_SUCCESS     no error
 *               other            error
 *-------------------------------------------------------------*/

/*HDR*/
int pcps_read_sernum( PCPS_DDEV *pddev )
{
  char *cp;
  int i;
  int rc = MBG_SUCCESS;


  memset( pddev->dev.cfg.sernum, 0, sizeof( pddev->dev.cfg.sernum ) );

  // There are different ways to read the clock's S/N. Check which
  // way is supported, and read the S/N from the device.
  //
  // Never just return a previous copy of the serial number which
  // has been read earlier since the S/N may just have been set
  // by a configuration API call.

  // Read directly. This is supported by newer devices.
  if ( _pcps_ddev_has_sernum( pddev ) )
  {
    #if DEBUG_SERNUM
      _mbgddmsg_0( MBG_DBG_DETAIL, "getting S/N via PCPS_GIVE_SERNUM cmd" );
    #endif

    rc = _pcps_read( pddev, PCPS_GIVE_SERNUM, pddev->dev.cfg.sernum, PCPS_FIFO_SIZE );

    if ( rc != MBG_SUCCESS )
    {
      _mbgddmsg_2( MBG_DBG_INIT_DEV, "PCPS read SERNUM %X: rc = %i",
                   _pcps_ddev_dev_id( pddev ), rc );
      goto fail;
    }

    goto check;
  }


  // The S/N is part of the RECEIVER_INFO structure,
  // so use that one, if supported.
  if ( _pcps_ddev_has_receiver_info( pddev ) )
  {
    #if DEBUG_SERNUM
      _mbgddmsg_0( MBG_DBG_DETAIL, "getting S/N from receiver info" );
    #endif

    rc = _pcps_read_gps_var( pddev, PC_GPS_RECEIVER_INFO, pddev->ri );

    if ( rc != MBG_SUCCESS )
    {
      _mbgddmsg_2( MBG_DBG_INIT_DEV, "PCPS read GPS receiver info %X: rc = %i",
                   _pcps_ddev_dev_id( pddev ), rc );
      goto fail;
    }

    _mbg_swab_receiver_info( &pddev->ri );

    strncpy( pddev->dev.cfg.sernum, pddev->ri.sernum,
             sizeof( pddev->dev.cfg.sernum ) );
    goto check;
  }


  // Older GPS clocks store the S/N in an IDENT structure
  // which needs to be decoded to get the S/N.
  if ( _pcps_ddev_has_ident( pddev ) )
  {
    static_wc IDENT ident = { { 0 } };

    #if DEBUG_SERNUM
      _mbgddmsg_0( MBG_DBG_DETAIL, "getting S/N from ident" );
    #endif

    rc = _pcps_read_gps_var( pddev, PC_GPS_IDENT, ident );

    #if !defined( MBG_TGT_LINUX ) && !defined( MBG_TGT_BSD )
      assert( sizeof( ident ) < sizeof( pddev->dev.cfg.sernum ) );
    #endif

    if ( rc != MBG_SUCCESS )
    {
      _mbgddmsg_2( MBG_DBG_INIT_DEV, "PCPS read GPS ident %X: rc = %i",
                   _pcps_ddev_dev_id( pddev ), rc );
      goto fail;
    }

    // The ident union must never be swapped due to endianess since we are
    // using it only as an array of characters.

    #if DEBUG_SERNUM
      for ( i = 0; i < sizeof( ident ); i += 4 )
        _mbgddmsg_5( MBG_DBG_DETAIL, "ident[%02i]: %02X %02X %02X %02X",
                     i, ident.c[i], ident.c[i+1], ident.c[i+2], ident.c[i+3] );
    #endif

    mbg_gps_ident_decode( _pcps_ddev_sernum( pddev ), &ident );
    goto check;
  }

  // The clock doesn't support a S/N.
  // Assume the rc is still set to MBG_SUCCESS.
  strcpy( _pcps_ddev_sernum( pddev ), "N/A" );
  goto done;


check:
  // Remove unprintable characters.
  for ( i = 0, cp = pddev->dev.cfg.sernum;
        i < sizeof( pddev->dev.cfg.sernum ); i++, cp++ )
    if ( ( *cp < 0x20 ) || ( *cp >= 0x7F ) )
    {
      #if DEBUG_SERNUM
        *cp = '#';
      #else
        *cp = 0;
      #endif
    }

#if DEBUG_SERNUM

fail:
  goto done;

#else
  // Remove trailing spaces or 'F' characters which may
  // unfortunately be returned by some devices.
  for ( i = strlen( pddev->dev.cfg.sernum ); ; )
  {
    if ( i == 0 )
      break;

    --i;
    cp = &pddev->dev.cfg.sernum[i];
    if ( ( *cp > ' ' ) && ( *cp != 'F' ) )
      break;  // done

    *cp = 0;
  }

  if ( strlen( pddev->dev.cfg.sernum ) )
    goto done;


fail:
  // No valid serial number has been found, though the device
  // should have one. In order to distinguish from devices which 
  // don't even support a serial number we return a number of '?'
  // rather than "N/A".
  memset( pddev->dev.cfg.sernum, '?', 8 );
  pddev->dev.cfg.sernum[8] = 0;
#endif

done:
  // Make sure the S/N is terminated by 0.
  pddev->dev.cfg.sernum[sizeof( pddev->dev.cfg.sernum ) - 1] = 0;

  return rc;

}  // pcps_read_sernum



#if _PCPS_USE_RSRCMGR

/*HDR*/
int pcps_rsrc_claim( PCPS_DDEV *pddev )
{
  ushort decode_width;
  int i;

  if ( _pcps_ddev_is_pci( pddev ) )
    decode_width = PCPS_DECODE_WIDTH_PCI;
  else
    if ( _pcps_ddev_is_mca( pddev ) )
      decode_width = PCPS_DECODE_WIDTH_MCA;
    else
      decode_width = PCPS_DECODE_WIDTH_ISA;

  for ( i = 0; i < pddev->rsrc_info.num_rsrc_io; i++ )
  {
    PCPS_IO_RSRC *p = &_pcps_ddev_io_rsrc( pddev, i );
    ushort rc;

    rc = _rsrc_alloc_ports( &pddev->rsrc, p->base_raw, p->num, decode_width );  //##++

    // If the resource manager was unable to alloc the resources
    // then the selected range of ports is probably in use
    // by another hardware device and/or driver
    if ( rc )
    {
      _pcps_ddev_set_err_flags( pddev, PCPS_EF_IO_RSRC );
      return MBG_ERR_CLAIM_RSRC;
    }
  }

  return 0;

}  // pcps_rsrc_claim



/*HDR*/
void pcps_rsrc_release( PCPS_DDEV *pddev )
{
  int i;

  for ( i = 0; i < N_PCPS_PORT_RSRC; i++ )
  {
    PCPS_PORT_RSRC *p = &_pcps_ddev_port_rsrc( pddev, i );

    if ( _pcps_port_rsrc_unused( p ) )
      continue;

    // clean up if clock not found
    _rsrc_dealloc_ports( &pddev->rsrc.hResource[i], p->base, p->num );
  }

}  // pcps_rsrc_release



#if defined( MBG_TGT_OS2 )

static /*HDR*/
void pcps_rsrc_register_device( PCPS_DDEV *pddev )
{
  #define RSRC_BASE_NAME "RADIOCLK_#  Meinberg Radio Clock "
  static const char rsrc_type_dcf77[] = RSRC_BASE_NAME "(DCF77)";
  static const char rsrc_type_gps[] = RSRC_BASE_NAME "(GPS)";
  static const char rsrc_type_irig[] = RSRC_BASE_NAME "(IRIG)";

  uchar bus_type;
  ushort rc;
  const char *cp;

  #if _PCPS_USE_USB
    #error USB not supported for this target environment!
  #endif

  if ( _pcps_ddev_is_pci( pddev ) )
    bus_type = RSRC_BUS_PCI;
  else
    if ( _pcps_ddev_is_mca( pddev ) )
      bus_type = RSRC_BUS_MCA;
    else
      bus_type = RSRC_BUS_ISA;

  if ( _pcps_ddev_is_irig_rx( pddev ) )
    cp = rsrc_type_irig;
  else
    if ( _pcps_ddev_is_gps( pddev ) )
      cp = rsrc_type_gps;
    else
      cp = rsrc_type_dcf77;

  rc = rsrc_register_device( &pddev->hDev, &pddev->rsrc, n_ddevs - 1, cp, bus_type );

}  // pcps_rsrc_register_device

#endif  // defined( MBG_TGT_OS2 )

#endif  // _PCPS_USE_RSRCMGR



#if _PCPS_USE_MCA

/*--------------------------------------------------------------
 *  PS31 only:
 *
 *  The scheme below shows the way the bits of the POS 103
 *  configuration byte are mapped to the PS31's programmable
 *  address decoder:
 *
 *   MSB            LSB
 *    |      ||      |
 *    0bbbbbb1000bxxxx  <-- 16 bit port base address (binary)
 *     ||||||    |
 *      \\\\\\   |               b:  configurable bit
 *        \\\\\\ |               x:  don't care bit
 *         |||||||
 *        1bbbbbbb      <--  8 bit configuration byte (POS 103)
 *        |
 *        |
 *    decoder enable bit, always 1 if adapter enabled
 *
 *-------------------------------------------------------------*/

/*--------------------------------------------------------------
 * Convert the code read from PS/2 POS to the port base address.
 *-------------------------------------------------------------*/

/*HDR*/
ushort pcps_port_from_pos( ushort pos )
{
  ushort us = ( ( pos & 0x007E ) << 8 ) | 0x0100;

  if ( pos & 0x0001 )
    us |= 0x0010;

  return us;

}  // pcps_port_from_pos



/*--------------------------------------------------------------
 * Convert the port base address to a PS/2 POS code.
 *-------------------------------------------------------------*/

/*HDR*/
uchar pcps_pos_from_port( ushort port )
{
  uchar uc;


  uc = *( ( (uchar *) (&port) ) + 1 ) & 0x7E;

  if ( port & 0x0010 )
    uc |= 1;

  return uc;

}  // pcps_pos_from_port



static /*HDR*/
void pcps_detect_mca_clocks( PCPS_DDEV_ALLOC_FNC alloc_fnc, void *alloc_arg )
{
  short rc;
  ushort type_idx;

  rc = mca_fnc_init();

  if ( rc != MCA_SUCCESS )
    return;


  // MCA is installed, now try to find a MCA clock with
  // known ID.
  for ( type_idx = 0; type_idx < N_PCPS_DEV_TYPE; type_idx++ )
  {
    static_wc MCA_POS_DATA pos_data;
    PCPS_DDEV *pddev;
    PCPS_DEV_TYPE *p = &pcps_dev_type[type_idx];

    static_wc uchar slot_num;   // the slot in which the board is installed


    if ( !( p->bus_flags & PCPS_BUS_MCA ) )
      continue;


    rc = mca_find_adapter( p->dev_id, &slot_num, &pos_data );

    if ( rc != MCA_SUCCESS )
      continue;


    // New device found, try to add to list.
    pddev = alloc_fnc( alloc_arg );

    if ( pddev )  // Setup only if successful.
    {
      pddev->dev.type = *p;
      pcps_add_rsrc_io( pddev, pcps_port_from_pos( pos_data.pos_103 ),
                        PCPS_NUM_PORTS_MCA );

      //##++ Should try to read the interrupt line assigned to the clock.
      // The standard functions, however, don't use any interrupt.

      pcps_start_device( pddev, 0, slot_num );
    }
  }

  mca_fnc_deinit();

}  // pcps_detect_mca_clocks

#endif  /* _PCPS_USE_MCA */



// The function below takes a bus flag and device ID to search
// the table of known devices for a device which matches the
// given criteria.

/*HDR*/
PCPS_DEV_TYPE *pcps_get_dev_type( int bus_mask, ushort dev_id )
{
  int i;

  for ( i = 0; i < N_PCPS_DEV_TYPE; i++ )
  {
    PCPS_DEV_TYPE *p = &pcps_dev_type[i];

    if ( !( p->bus_flags & bus_mask ) )
      continue;

    if ( p->dev_id == dev_id )
      return p;
  }

  return NULL;

}  // pcps_get_dev_type



/*HDR*/
PCPS_DDEV *pcps_alloc_ddev( void )
{
  PCPS_DDEV *pddev;

  #if !_PCPS_STATIC_DEV_LIST
    pddev = _pcps_kmalloc( sizeof( *pddev ) );
  #else
    if ( n_ddevs >= PCPS_MAX_DDEVS )
    {
      _mbgddmsg_0( MBG_DBG_INIT_DEV,
                   "Unable to add new device: max count reached" );

      return NULL;
    }

    pddev = &pcps_ddev[n_ddevs];
    n_ddevs++;
  #endif

  if ( pddev )
  {
    memset( pddev, 0, sizeof( *pddev ) );

    // If mutexes or spinlocks need to be destroyed on the target OS
    // when the driver shuts down then they are initialized now and
    // destroyed in the complementary function pcps_free_ddev().
    // However, there are target OSs where those semaphores don't need
    // to be destroyed, and sometimes even *must not* be initialized
    // at this early point of driver initialization, e.g. under Windows,
    // in which case the semaphores will be initialized later.
    #if defined( _mbg_mutex_destroy )
      _mbg_mutex_init( &pddev->dev_mutex );
    #endif
    #if defined( _mbg_spin_lock_destroy )
      _mbg_spin_lock_init( &pddev->mm_lock );
      _mbg_spin_lock_init( &pddev->irq_lock );
    #endif
  }

  return pddev;

}  // pcps_alloc_ddev



/*HDR*/
void pcps_free_ddev( PCPS_DDEV *pddev )
{
  if ( pddev )
  {
    #if defined( _mbg_mutex_destroy )
      _mbg_mutex_destroy( &pddev->dev_mutex );
    #endif
    #if defined( _mbg_spin_lock_destroy )
      _mbg_spin_lock_destroy( &pddev->mm_lock );
      _mbg_spin_lock_destroy( &pddev->irq_lock );
    #endif

    #if !_PCPS_STATIC_DEV_LIST
      _pcps_kfree( pddev, sizeof( *pddev ) );
    #else
      memset( pddev, 0, sizeof( *pddev ) );

      if ( n_ddevs )
        n_ddevs--;
    #endif
  }

}  // pcps_free_ddev



static /*HDR*/
void rsrc_port_to_cfg_port( PCPS_PORT_RSRC *p_port_rsrc, const PCPS_IO_RSRC *p_io_rsrc )
{
  p_port_rsrc->base = (PCPS_PORT_ADDR) p_io_rsrc->base_raw;
  p_port_rsrc->num = p_io_rsrc->num;

}  // rsrc_port_to_cfg_port



/*HDR*/
int pcps_add_rsrc_io( PCPS_DDEV *pddev, ulong base, ulong num )
{
  PCPS_RSRC_INFO *prsrci = &pddev->rsrc_info;

  if ( prsrci->num_rsrc_io < N_PCPS_PORT_RSRC )
  {
    PCPS_IO_RSRC *p = &prsrci->port[prsrci->num_rsrc_io];

    p->base_mapped = (PCPS_IO_ADDR_MAPPED) _pcps_ioremap( base, num );
    p->base_raw = (PCPS_IO_ADDR_RAW) base;
    p->num = (uint16_t) num;

    prsrci->num_rsrc_io++;

    _mbgddmsg_3( MBG_DBG_INIT_DEV, "Adding I/O rsrc #%i: %03lX(%lu)",
                 prsrci->num_rsrc_io, (ulong) base, (ulong) num );

    return MBG_SUCCESS;
  }

  return MBG_ERR_GENERIC;

}  // pcps_add_rsrc_io



/*HDR*/
int pcps_add_rsrc_mem( PCPS_DDEV *pddev, MBG_MEM_ADDR start, ulong len )
{
  PCPS_RSRC_INFO *prsrci = &pddev->rsrc_info;

  if ( prsrci->num_rsrc_mem < N_PCPS_MEM_RSRC )
  {
    PCPS_MEM_RSRC *p = &prsrci->mem[prsrci->num_rsrc_mem];
    p->start = start;
    p->len = len;
    prsrci->num_rsrc_mem++;

    #if defined( MBG_TGT_UNIX )
      _mbgddmsg_3( MBG_DBG_INIT_DEV, "Adding mem rsrc #%i: %08llX(%lu)",
                   prsrci->num_rsrc_mem, (unsigned long long) start, len );
    #else
      _mbgddmsg_3( MBG_DBG_INIT_DEV, "Adding mem rsrc #%i: %08lX(%lu)",
                   prsrci->num_rsrc_mem, (unsigned long) start, len );
    #endif

    return MBG_SUCCESS;
  }

  return MBG_ERR_GENERIC;

}  // pcps_add_rsrc_mem



/*HDR*/
int pcps_add_rsrc_irq( PCPS_DDEV *pddev, int16_t irq_num )
{
  PCPS_RSRC_INFO *prsrci = &pddev->rsrc_info;

  if ( prsrci->num_rsrc_irq == 0 )
  {
    prsrci->irq.num = irq_num;
    prsrci->num_rsrc_irq++;

    _mbgddmsg_2( MBG_DBG_INIT_DEV, "Adding IRQ rsrc #%i: %i",
                 prsrci->num_rsrc_irq, irq_num );

    return MBG_SUCCESS;
  }

  return MBG_ERR_GENERIC;

}  // pcps_add_rsrc_irq



#if _PCPS_USE_PNP

/*HDR*/
int pcps_init_ddev( PCPS_DDEV *pddev, int bus_flags, ushort dev_id )
{
  // First check if we really support the device to be added.
  PCPS_DEV_TYPE *pdt = pcps_get_dev_type( bus_flags, dev_id );

  if ( pdt == NULL )
  {
    _mbgddmsg_1( MBG_DBG_INIT_DEV, "PCPS add PNP device %X: unknown type",
                 dev_id );

    return MBG_ERR_DEV_NOT_SUPP;
  }


  pddev->dev.type = *pdt;

  _mbgddmsg_2( MBG_DBG_INIT_DEV, "PCPS add PNP device %X: found %s",
               dev_id, pdt->name );

  return MBG_SUCCESS;

}  // pcps_init_ddev

#endif // _PCPS_USE_PNP



#if defined( DEBUG )
static /*HDR*/
const char *get_feature_name( PCPS_FEATURES flag )
{
  static const char *pcps_feature_names[N_PCPS_FEATURE] = PCPS_FEATURE_NAMES;

  int i;

  for ( i = 0; i < N_PCPS_FEATURE; i++ )
    if ( ( 1UL << i ) == flag )
      return pcps_feature_names[i];

  return "unknown";

}  // get_feature_name

#endif



static /*HDR*/
void check_feature( PCPS_DDEV *pddev, ushort req_rev_num,
                    PCPS_FEATURES flag )
{
  int supported = _pcps_ddev_fw_rev_num( pddev ) >= req_rev_num;

  if ( supported )
    pddev->dev.cfg.features |= flag;

  #if defined( DEBUG )
    _mbgddmsg_5( MBG_DBG_INIT_DEV, "%s v%03X: feature 0x%08lX (%s) %ssupported",
                 _pcps_ddev_type_name( pddev ),
                 _pcps_ddev_fw_rev_num( pddev ),
                 (ulong) flag, get_feature_name( flag ),
                 supported ? "" : "not " );
  #endif

}  // check_feature



static /*HDR*/
void check_ri_feature( PCPS_DDEV *pddev, const RECEIVER_INFO *p_ri,
                       RI_FEATURES ri_flag, PCPS_FEATURES flag )
{
  int supported = ( p_ri->features & ri_flag ) != 0;

  if ( supported )
    pddev->dev.cfg.features |= flag;

  #if defined( DEBUG )
    _mbgddmsg_5( MBG_DBG_INIT_DEV, "%s v%03X: feature 0x%08lX (%s) %ssupported according to RECEIVER_INFO",
                 _pcps_ddev_type_name( pddev ),
                 _pcps_ddev_fw_rev_num( pddev ),
                 (ulong) flag, get_feature_name( flag ),
                 supported ? "" : "not " );
  #endif

}  // check_ri_feature



/*HDR*/
int pcps_start_device( PCPS_DDEV *pddev,
                       PCPS_BUS_NUM bus_num,
                       PCPS_SLOT_NUM dev_fnc_num )
{
  ushort port_rsrc_len[N_PCPS_PORT_RSRC] = { 0 };
  int port_ranges_required = 0;
  ushort status_port_offs = 0;
  int i;
  int rc;

  _mbgddmsg_1( MBG_DBG_INIT_DEV, "PCPS start device %X",
               _pcps_ddev_dev_id( pddev ) );

  pddev->read = pcps_read_null;
  pddev->dev.cfg.bus_num = bus_num;
  pddev->dev.cfg.slot_num = dev_fnc_num;

  if ( _pcps_ddev_chk_err_flags( pddev, PCPS_EF_IO_INIT | PCPS_EF_IO_ENB ) )
  {
    _mbgddmsg_1( MBG_DBG_INIT_DEV, "PCPS start device %X: failing due to error flags.",
                 _pcps_ddev_dev_id( pddev ) );
    goto fail;
  }


  // If mutexes or spinlocks need to be destroyed on the target OS
  // when the driver shuts down then they have already been initialized
  // in the device allocation routine and will be destroyed in the
  // complementary device deallocation routine.
  // However, there are target OSs where those semaphores don't need
  // to be destroyed, and sometimes even *must not* be initialized
  // when the device structure is allocated (e.g under Windows),
  // in which case the semaphores need to be initialized now.
  #if !defined( _mbg_mutex_destroy )
    #if defined( _mbg_mutex_init )
      _mbg_mutex_init( &pddev->dev_mutex );
    #endif
  #endif
  #if !defined( _mbg_spin_lock_destroy )
    #if defined( _mbg_spin_lock_init )
      _mbg_spin_lock_init( &pddev->mm_lock );
      _mbg_spin_lock_init( &pddev->irq_lock );
    #endif
  #endif


  switch ( _pcps_ddev_bus_flags( pddev ) )
  {
    #if _PCPS_USE_USB
      case PCPS_BUS_USB:
      case PCPS_BUS_USB_V2:
        // No direct port I/O possible.
        pddev->read = pcps_read_usb;

        // In case of an USB device, do some additional
        // USB initializiation
        #if defined( MBG_TGT_WIN32_PNP )
          rc = pcps_usb_init( pddev );
        #elif defined( MBG_TGT_LINUX )
          rc = usb_set_interface( pddev->udev, 0, 0 );

          if ( rc )
            _mbgddmsg_1( MBG_DBG_INIT_DEV, "usb_set_interface returned %d", rc );
          else
          {
            struct usb_host_interface *iface_desc = pddev->intf->cur_altsetting;
            int i;

            pddev->n_usb_ep = 0;

            for ( i = 0; i < iface_desc->desc.bNumEndpoints; i++ )
            {
              struct usb_endpoint_descriptor *endpoint = &iface_desc->endpoint[i].desc;
              PCPS_USB_EP *pep = &pddev->ep[i];
              pep->addr = endpoint->bEndpointAddress;
              pep->max_packet_size = le16_to_cpu( endpoint->wMaxPacketSize );
              _mbgddmsg_3( MBG_DBG_INIT_DEV, "endpoint %d: addr %02X, size: %d",
                           i, pep->addr, pep->max_packet_size );
              pddev->n_usb_ep++;
            }
          }
        #else
          #error USB endpoint configuration can not be determined for this target.
        #endif

        if ( rc == MBG_SUCCESS )
          if ( pddev->n_usb_ep < MBGUSB_MIN_ENDPOINTS_REQUIRED )
          {
            #if defined( MBG_TGT_LINUX )
              printk( KERN_INFO "device supports only %d endpoints while %d are required\n",
                      pddev->n_usb_ep, MBGUSB_MIN_ENDPOINTS_REQUIRED );
            #elif defined( MBG_TGT_WIN32_PNP )
              swprintf( pddev->wcs_msg, L"device supports only %d endpoints while %d are required",
                        pddev->n_usb_ep, MBGUSB_MIN_ENDPOINTS_REQUIRED );
              _evt_msg( GlbDriverObject, pddev->wcs_msg );
            #else
              //##++ 
            #endif

            rc = MBG_ERR_GENERIC;
          }
          #if defined( MBG_TGT_WIN32_PNP )
            else
            {
              LARGE_INTEGER Count1, Count2, PerfFreq;
              PCPS_HR_TIME t;

              uint8_t irq_cmd = PCPS_IRQ_1_SEC;
              rc = _pcps_usb_write_var( pddev, &irq_cmd );

              // get access time to determine latency compensation mode
              Count1 = KeQueryPerformanceCounter( &PerfFreq );
              rc = _pcps_read_var( pddev, PCPS_GIVE_HR_TIME, t );
              Count2 = KeQueryPerformanceCounter( NULL );

              // If access time is below 1 ms then there might be a V2.0 Hub between device and host.
              // In this case, you can expect that there is the 125 us microframe timing of USB 2.0.
              if ( ( (ULONGLONG) ( Count2.QuadPart - Count1.QuadPart ) ) < ( (ULONGLONG) PerfFreq.QuadPart ) / 1000UL )
                pddev->usb_20_mode = 1;
              else
                pddev->usb_20_mode = 0;
            }
          #endif

        if ( rc != MBG_SUCCESS )
        {
          _pcps_ddev_set_err_flags( pddev, PCPS_EF_IO_INIT );
          goto fail;
        }
        break;
      #endif

    case PCPS_BUS_PCI_PEX8311:
      port_rsrc_len[0] = 0;
      port_rsrc_len[1] = sizeof( PCI_ASIC );  // same as ASIC
      port_ranges_required = 2;  // will be swapped later
      status_port_offs = offsetof( PCI_ASIC, status_port ); // same as ASIC
      pddev->read = pcps_read_asic;
      break;

    case PCPS_BUS_PCI_ASIC:
    case PCPS_BUS_PCI_MBGPEX:
      port_rsrc_len[0] = sizeof( PCI_ASIC );
      port_ranges_required = 1;
      status_port_offs = offsetof( PCI_ASIC, status_port );
      pddev->read = pcps_read_asic;
      break;

    case PCPS_BUS_PCI_S5920:
      port_rsrc_len[0] = AMCC_OP_REG_RANGE_S5920;
      port_rsrc_len[1] = 16;  //##++
      port_ranges_required = 2;
      status_port_offs = AMCC_OP_REG_IMB4 + 3;
      pddev->read = pcps_read_amcc_s5920;
      break;

    case PCPS_BUS_PCI_S5933:
      port_rsrc_len[0] = AMCC_OP_REG_RANGE_S5933;
      port_ranges_required = 1;
      status_port_offs = AMCC_OP_REG_IMB4 + 3;
      pddev->read = pcps_read_amcc_s5933;
      break;

    case PCPS_BUS_MCA:
    case PCPS_BUS_ISA:
      // resource lengths have always been set
      port_ranges_required = 1;
      status_port_offs = 1;
      pddev->read = pcps_read_std;
      break;

    default:
      #if defined( MBG_TGT_LINUX )
        printk( KERN_ERR "%s: unhandled bus flags %04X for device %s\n",
                pcps_driver_name, _pcps_ddev_bus_flags( pddev ), _pcps_ddev_type_name( pddev ) );
      #elif defined( MBG_TGT_BSD )
        printf( "%s: unhandled bus flags %04X for device %s\n",
                pcps_driver_name, _pcps_ddev_bus_flags( pddev ), _pcps_ddev_type_name( pddev ) );
      #elif defined( MBG_TGT_WIN32 )
        swprintf( pddev->wcs_msg, L"unhandled bus flags %04X for device %S",
                  _pcps_ddev_bus_flags( pddev ), _pcps_ddev_type_name( pddev ) );
        _evt_msg( GlbDriverObject, pddev->wcs_msg );
      #endif
      goto fail;

  }  // switch ( _pcps_ddev_bus_flags( pddev ) )

  #if _PCPS_USE_MM_IO
  if ( !_pcps_ddev_is_pci_mbgpex( pddev ) )
  #endif
  {
    // check if all required resources have been assigned
    if ( pddev->rsrc_info.num_rsrc_io < port_ranges_required )
    {
      _mbgddmsg_3( MBG_DBG_INIT_DEV, "PCPS start device %X fails: port ranges (%u) less than required (%u)",
                   _pcps_ddev_dev_id( pddev ), pddev->rsrc_info.num_rsrc_io, port_ranges_required );
      _pcps_ddev_set_err_flags( pddev, PCPS_EF_IO_INIT );
      goto fail;
    }
  }

  if ( _pcps_ddev_is_pci_mbgpex( pddev ) )
  {
    pddev->irq_enb_disb_port = _pcps_ddev_io_base_mapped( pddev, 0 )
                             + offsetof( PCI_ASIC, control_status );
    pddev->irq_flag_port = pddev->irq_enb_disb_port;
    pddev->irq_flag_mask = PCI_ASIC_PCI_IRQF;

    pddev->irq_ack_port = pddev->irq_enb_disb_port;
    pddev->irq_ack_mask = PCI_ASIC_PCI_IRQF;

    #if _PCPS_USE_MM_IO
      _mbgddmsg_1( MBG_DBG_INIT_DEV, "%s: pcps_start_device: interface is MBGPEX",
                   pcps_driver_name );
      if ( map_sys_virtual_address( pddev ) < 0 )
        goto fail_with_cleanup;

      #if 1 && DEBUG_IO && defined( MBG_TGT_LINUX )  //##+++++++++++++++
        printk( KERN_ERR "io_addr: 0x%llX, cmd: 0x%llX\n",
                (unsigned long long) _pcps_ddev_io_base_mapped( pddev, 0 ),
                (unsigned long long) _pcps_ddev_io_base_mapped( pddev, 0 ) + offsetof( PCI_ASIC, pci_data )
              );

        printk( KERN_ERR "mm_addr: %p, cmd: %p, tstamp: %p\n",
                pddev->mm_addr,
                &pddev->mm_addr->mbgpex.asic.pci_data.ul,
                pddev->mm_tstamp_addr
              );
      #endif

      pddev->read = pcps_read_asic_mm;
    #endif  // _PCPS_USE_MM_IO

    goto chip_setup_done;
  }


  // setup additional properties depending on the
  // type of bus interface chip
  if ( _pcps_ddev_is_pci_pex8311( pddev ) )
  {
    // I/O and memory ranges must be swapped for the
    // low level functions because otherwise the first
    // range addressed the chip configuration registers
    // while the second range addressed data registers.

    PCPS_MEM_RSRC tmp_mem_rsrc;
    PCPS_IO_RSRC tmp_io_rsrc;

    tmp_mem_rsrc = pddev->rsrc_info.mem[0];
    pddev->rsrc_info.mem[0] = pddev->rsrc_info.mem[1];
    pddev->rsrc_info.mem[1] = tmp_mem_rsrc;

    #if DEBUG_IO
      _mbgddmsg_4( MBG_DBG_DETAIL, "Ports before swapping: %04lX (%08lX), %04lX (%08lX)",
        (ulong) pddev->rsrc_info.port[0].base_raw, (ulong) pddev->rsrc_info.port[0].base_mapped,
        (ulong) pddev->rsrc_info.port[1].base_raw, (ulong) pddev->rsrc_info.port[1].base_mapped );
    #endif

    tmp_io_rsrc = pddev->rsrc_info.port[0];
    pddev->rsrc_info.port[0] = pddev->rsrc_info.port[1];
    pddev->rsrc_info.port[1] = tmp_io_rsrc;

    #if DEBUG_IO
      _mbgddmsg_4( MBG_DBG_DETAIL, "Ports after swapping: %04lX (%08lX), %04lX (%08lX)",
        (ulong) pddev->rsrc_info.port[0].base_raw, (ulong) pddev->rsrc_info.port[0].base_mapped,
        (ulong) pddev->rsrc_info.port[1].base_raw, (ulong) pddev->rsrc_info.port[1].base_mapped );
    #endif

    // Attention: the interrupt control/status register is located in
    // the PLX configuration space which is addressed by a different
    // port address range than the normal data ports !!
    pddev->irq_enb_disb_port = _pcps_ddev_io_base_mapped( pddev, 1 ) + PLX8311_REG_INTCSR;
    pddev->irq_enb_mask = PLX8311_INT_ENB;
    pddev->irq_disb_mask = PLX8311_INT_ENB;

    pddev->irq_flag_port = _pcps_ddev_io_base_mapped( pddev, 1 ) + PLX8311_REG_INTCSR;
    pddev->irq_flag_mask = PLX8311_INT_FLAG;

    pddev->irq_ack_port = _pcps_ddev_io_base_mapped( pddev, 0 ) + offsetof( PCI_ASIC, control_status );
    pddev->irq_ack_mask = PCI_ASIC_PCI_IRQF;
    goto chip_setup_done;
  }

  if ( _pcps_ddev_is_pci_asic( pddev ) )
  {
    pddev->irq_enb_disb_port = _pcps_ddev_io_base_mapped( pddev, 0 )
                             + offsetof( PCI_ASIC, control_status );
    pddev->irq_flag_port = pddev->irq_enb_disb_port;
    pddev->irq_flag_mask = PCI_ASIC_PCI_IRQF;

    pddev->irq_ack_port = pddev->irq_enb_disb_port;
    pddev->irq_ack_mask = PCI_ASIC_PCI_IRQF;
    goto chip_setup_done;
  }

  if ( _pcps_ddev_is_pci_amcc( pddev ) )
  {
    pddev->irq_enb_disb_port = _pcps_ddev_io_base_mapped( pddev, 0 )
                             + AMCC_OP_REG_INTCSR;
    pddev->irq_enb_mask = AMCC_INT_ENB;
    pddev->irq_disb_mask = AMCC_INT_MASK;

    pddev->irq_flag_port = pddev->irq_enb_disb_port;
    pddev->irq_flag_mask = AMCC_INT_FLAG;

    pddev->irq_ack_port = pddev->irq_enb_disb_port;
    pddev->irq_ack_mask = AMCC_INT_ACK;
    goto chip_setup_done;
  }

chip_setup_done:

  pddev->status_port = _pcps_ddev_io_base_mapped( pddev, 0 ) + status_port_offs;

  // Set up the resource list in pddev->dev.cfg which
  // isn't really required anymore, but just informational:

  for ( i = 0; i < N_PCPS_PORT_RSRC; i++ )
  {
    PCPS_IO_RSRC *prsrc;

    if ( i >= port_ranges_required )
      break;

    prsrc = &pddev->rsrc_info.port[i];

    // if the resource len has not yet been set
    // then use the default resource len
    if ( prsrc->num == 0 )
      prsrc->num = port_rsrc_len[i];

    rsrc_port_to_cfg_port( &pddev->dev.cfg.port[i], &pddev->rsrc_info.port[i] );
  }

  pddev->dev.cfg.irq_num = pddev->rsrc_info.num_rsrc_irq ?
                           pddev->rsrc_info.irq.num : -1;
  pddev->dev.cfg.status_port = _pcps_ddev_port_base( pddev, 0 ) + status_port_offs;

  pddev->dev.cfg.timeout_clk = PCPS_TIMEOUT_CNT;

  #if DEBUG_PORTS
    _mbgddmsg_3( MBG_DBG_DETAIL, "IRQ enb/disb port: %04lX, enb: %08lX, disb: %08lX",
                 (ulong) pddev->irq_enb_disb_port,
                 (ulong) pddev->irq_enb_mask,
                 (ulong) pddev->irq_disb_mask
               );
    _mbgddmsg_2( MBG_DBG_DETAIL, "IRQ flag port: %04lX, mask: %08lX",
                 (ulong) pddev->irq_flag_port,
                 (ulong) pddev->irq_flag_mask
               );
    _mbgddmsg_2( MBG_DBG_DETAIL, "IRQ ack port: %04lX, mask: %08lX",
                 (ulong) pddev->irq_ack_port,
                 (ulong) pddev->irq_ack_mask
               );
    _mbgddmsg_1( MBG_DBG_DETAIL, "status port: %04lX", (ulong) pddev->status_port );
  #endif

  #if _PCPS_USE_RSRCMGR
    rc = pcps_rsrc_claim( pddev );

    if ( rc < 0 )
    {
      _mbgddmsg_1( MBG_DBG_INIT_DEV, "PCPS start device %X: failed to alloc resources",
                   _pcps_ddev_dev_id( pddev ) );

      goto fail_with_cleanup;
    }
  #endif

  // There are some BIOSs out there which don't configure some PEX cards
  // properly, and thus the cards can not be accessed properly.
  // See note near the definition of _pcps_pci_cfg_err() for details.
  if ( _pcps_ddev_pci_cfg_err( pddev ) )
  {
    #if defined( MBG_TGT_LINUX )
      printk( KERN_WARNING "%s: duplicate base address 0x%04lX, device %s will not work properly (BIOS faulty)\n",
              pcps_driver_name, (ulong) _pcps_ddev_port_base( pddev, 0 ), _pcps_ddev_type_name( pddev ) );
    #elif defined( MBG_TGT_BSD )
      printf( "%s: duplicate base address 0x%04lX, device %s will not work properly (BIOS faulty)\n",
              pcps_driver_name, (ulong) _pcps_ddev_port_base( pddev, 0 ), _pcps_ddev_type_name( pddev ) );
    #elif defined( MBG_TGT_WIN32 )
      swprintf( pddev->wcs_msg, L"duplicate base address 0x%04lX, device %s will not work properly (BIOS faulty)",
                (ulong) _pcps_ddev_port_base( pddev, 0 ), _pcps_ddev_type_name( pddev ) );
      _evt_msg( GlbDriverObject, pddev->wcs_msg );
    #endif
  }


  #if 0 && DEBUG //##++++++++++++++
  {
    MBG_SYS_UPTIME uptime;
    mbg_get_sys_uptime( &uptime );
    mbg_sleep_sec( 1 );
    mbg_get_sys_uptime( &uptime );
  }
  #endif

  #if CHECK_UPTIME
    // Make sure a PTP270PEX card has finished booting.
    if ( _pcps_ddev_is_pci( pddev ) && ( _pcps_ddev_dev_id( pddev ) == PCI_DEV_PTP270PEX ) )
      check_uptime();
  #endif


  // try to read firmware ID
  rc = pcps_get_fw_id( pddev, pddev->dev.cfg.fw_id );

  if ( rc < 0 )
  {
    if ( _pcps_ddev_is_isa( pddev ) )
    {
      // ISA devices are detected by trying to read a firmware ID via
      // a given port, so if the firmware ID could not be read then this
      // just means there is no device using the given port address.
      #if defined( MBG_TGT_WIN32 )
        swprintf( pddev->wcs_msg, L"No ISA card found at port %03lXh.", 
                  (ulong) _pcps_ddev_port_base( pddev, 0 ) );
        _evt_msg( GlbDriverObject, pddev->wcs_msg );
      #else
        _mbgddmsg_1( MBG_DBG_INIT_DEV, "No ISA card found at port %03lXh.",
                     (ulong) _pcps_ddev_port_base( pddev, 0 ) );
      #endif
    }
    else
    {
      // Non-ISA devices are detected by some other means, so if the firmware
      // ID could not be read this is a serious error.
      #if defined( MBG_TGT_WIN32 )  //##+++ debug or not debug ... ;-)
        _evt_msg( GlbDriverObject, L"StartDevice: failed to read firmware ID" );
      #else
        _mbgddmsg_1( MBG_DBG_INIT_DEV, "PCPS start device %X: failed to read firmware ID",
                     _pcps_ddev_dev_id( pddev ) );
      #endif
    }

    _pcps_ddev_set_err_flags( pddev, PCPS_EF_TIMEOUT );
    goto fail_with_cleanup;
  }

  if ( _pcps_ddev_bus_flags( pddev ) == PCPS_BUS_ISA )
  {
    ushort dev_type;

    // Still need to find out which type of ISA clock we have found.
    // Check EPROM ID to find out which kind of clock is installed.
    if ( pcps_check_id( pddev, fw_id_ref_gps ) == MBG_SUCCESS )
      dev_type = PCPS_TYPE_GPS167PC;
    else
    {
      if ( pcps_check_id( pddev, fw_id_ref_pcps ) == MBG_SUCCESS )
      {
        // Device is a PC31, or a PC32 if it has signature code.
        // If no support for MCA has been compiled in, it may even
        // be a PS31 which is software compatible with a PC31.
        dev_type =
          ( _mbg_inp16_to_cpu( pddev, 0, _pcps_ddev_io_base_mapped( pddev, 0 ) + 2 )
            == pcps_dev_type[PCPS_TYPE_PC32].dev_id ) ?
         PCPS_TYPE_PC32 : PCPS_TYPE_PC31;
      }
      else
      {
        _pcps_ddev_set_err_flags( pddev, PCPS_EF_INV_EPROM_ID );
        goto fail_with_cleanup;
      }
    }

    pddev->dev.type = pcps_dev_type[dev_type];
  }

  #if defined( MBG_TGT_OS2 )
    pcps_rsrc_register_device( pddev );
  #endif

  // Extract the firmware revision number from the ID string.
  pddev->dev.cfg.fw_rev_num = pcps_get_rev_num( _pcps_ddev_fw_id( pddev ) );

  // If the device has an ASIC or EPLD read the ASIC version number
  if ( _pcps_ddev_has_asic_version( pddev ) )
  {
    #if _PCPS_USE_MM_IO
      if ( _pcps_ddev_bus_flags( pddev ) == PCPS_BUS_PCI_MBGPEX )
      {
        _mbgddmsg_1( MBG_DBG_INIT_DEV, "%s: pcps_start_device: MM reading ASIC version",
                   pcps_driver_name );
        pddev->raw_asic_version = pddev->mm_addr->mbgpex.asic.raw_version;
      }
      else
    #endif  // _PCPS_USE_MM_IO
        pddev->raw_asic_version = _mbg_inp32_to_cpu( pddev, 0, _pcps_ddev_io_base_mapped( pddev, 0 )
                                  + offsetof( PCI_ASIC, raw_version ) );

    _mbg_swab_asic_version( &pddev->raw_asic_version );

    pddev->asic_version = _convert_asic_version_number( pddev->raw_asic_version );
  }

  // Setup some feature flags which depend on the device type 
  // and firmware version.
  switch( _pcps_ddev_type_num( pddev ) )
  {
    case PCPS_TYPE_PC31:
    case PCPS_TYPE_PS31_OLD:
    case PCPS_TYPE_PS31:
      pddev->dev.cfg.features = PCPS_FEAT_PC31PS31;
      check_feature( pddev, REV_CAN_SET_TIME_PC31PS31, PCPS_CAN_SET_TIME );
      check_feature( pddev, REV_HAS_SERIAL_PC31PS31, PCPS_HAS_SERIAL );
      check_feature( pddev, REV_HAS_SYNC_TIME_PC31PS31, PCPS_HAS_SYNC_TIME );
      check_feature( pddev, REV_HAS_UTC_OFFS_PC31PS31, PCPS_HAS_UTC_OFFS );
      break;

    case PCPS_TYPE_PC32:
      pddev->dev.cfg.features = PCPS_FEAT_PC32;
      break;

    case PCPS_TYPE_PCI32:
      pddev->dev.cfg.features = PCPS_FEAT_PCI32;
      break;

    case PCPS_TYPE_GPS167PC:
      pddev->dev.cfg.features = PCPS_FEAT_GPS167PC;
      check_feature( pddev, REV_HAS_HR_TIME_GPS167PC, PCPS_HAS_HR_TIME );
      check_feature( pddev, REV_HAS_CABLE_LEN_GPS167PC, PCPS_HAS_CABLE_LEN );
      break;

    case PCPS_TYPE_GPS167PCI:
      pddev->dev.cfg.features = PCPS_FEAT_GPS167PCI;
      check_feature( pddev, REV_HAS_CABLE_LEN_GPS167PCI, PCPS_HAS_CABLE_LEN );
      check_feature( pddev, REV_CAN_CLR_UCAP_BUFF_GPS167PCI, PCPS_CAN_CLR_UCAP_BUFF );
      check_feature( pddev, REV_HAS_UCAP_GPS167PCI, PCPS_HAS_UCAP );
      break;

    case PCPS_TYPE_PCI509:
      pddev->dev.cfg.features = PCPS_FEAT_PCI509;
      break;

    case PCPS_TYPE_GPS168PCI:
      pddev->dev.cfg.features = PCPS_FEAT_GPS168PCI;
      check_feature( pddev, REV_CAN_CLR_UCAP_BUFF_GPS168PCI, PCPS_CAN_CLR_UCAP_BUFF );
      check_feature( pddev, REV_HAS_UCAP_GPS168PCI, PCPS_HAS_UCAP );
      break;

    case PCPS_TYPE_PCI510:
      pddev->dev.cfg.features = PCPS_FEAT_PCI510;
      break;

    case PCPS_TYPE_GPS169PCI:
      pddev->dev.cfg.features = PCPS_FEAT_GPS169PCI;
      check_feature( pddev, REV_HAS_GPS_DATA_16_GPS169PCI, PCPS_HAS_GPS_DATA_16 );
      break;

    case PCPS_TYPE_TCR510PCI:
      pddev->dev.cfg.features = PCPS_FEAT_TCR510PCI;
      check_feature( pddev, REV_HAS_HR_TIME_TCR510PCI, PCPS_HAS_HR_TIME );
      break;

    case PCPS_TYPE_TCR167PCI:
      pddev->dev.cfg.features = PCPS_FEAT_TCR167PCI;
      break;

    case PCPS_TYPE_GPS170PCI:
      pddev->dev.cfg.features = PCPS_FEAT_GPS170PCI;
      break;

    case PCPS_TYPE_PCI511:
      pddev->dev.cfg.features = PCPS_FEAT_PCI511;
      check_feature( pddev, REV_HAS_HR_TIME_PCI511, PCPS_HAS_HR_TIME );
      break;

    case PCPS_TYPE_TCR511PCI:
      pddev->dev.cfg.features = PCPS_FEAT_TCR511PCI;
      check_feature( pddev, REV_HAS_IRIG_CTRL_BITS_TCR511PCI, PCPS_HAS_IRIG_CTRL_BITS );
      check_feature( pddev, REV_HAS_IRIG_TIME_TCR511PCI, PCPS_HAS_IRIG_TIME );
      check_feature( pddev, REV_HAS_RAW_IRIG_DATA_TCR511PCI, PCPS_HAS_RAW_IRIG_DATA );
      break;

    case PCPS_TYPE_PEX511:
      pddev->dev.cfg.features = PCPS_FEAT_PEX511;
      // HR time support for the PEX511 requires both a certain ASIC 
      // version plus a certain firmware version.
      if ( _pcps_asic_version_greater_equal( _pcps_ddev_asic_version( pddev ),
           PCI_ASIC_MAJOR_PEX511, PCI_ASIC_HR_TIME_MINOR_PEX511 ) )
        check_feature( pddev, REV_HAS_HR_TIME_PEX511, PCPS_HAS_HR_TIME );

      pcps_check_pex_irq_unsafe( pddev, REV_HAS_IRQ_FIX_MINOR_PEX511,
           PCI_ASIC_MAJOR_PEX511, PCI_ASIC_FIX_IRQ_MINOR_PEX511 );
      break;

    case PCPS_TYPE_TCR511PEX:
      pddev->dev.cfg.features = PCPS_FEAT_TCR511PEX;
      check_feature( pddev, REV_HAS_IRIG_CTRL_BITS_TCR511PEX, PCPS_HAS_IRIG_CTRL_BITS );
      check_feature( pddev, REV_HAS_IRIG_TIME_TCR511PEX, PCPS_HAS_IRIG_TIME );
      check_feature( pddev, REV_HAS_RAW_IRIG_DATA_TCR511PEX, PCPS_HAS_RAW_IRIG_DATA );
      pcps_check_pex_irq_unsafe( pddev, REV_HAS_IRQ_FIX_MINOR_TCR511PEX,
           PCI_ASIC_MAJOR_TCR511PEX, PCI_ASIC_FIX_IRQ_MINOR_TCR511PEX );
      break;

    case PCPS_TYPE_GPS170PEX:
      pddev->dev.cfg.features = PCPS_FEAT_GPS170PEX;
      pcps_check_pex_irq_unsafe( pddev, REV_HAS_IRQ_FIX_MINOR_GPS170PEX,
           PCI_ASIC_MAJOR_GPS170PEX, PCI_ASIC_FIX_IRQ_MINOR_GPS170PEX );
      break;

    case PCPS_TYPE_USB5131:
      pddev->dev.cfg.features = PCPS_FEAT_USB5131;
      break;

    case PCPS_TYPE_TCR51USB:
      pddev->dev.cfg.features = PCPS_FEAT_TCR51USB;
      check_feature( pddev, REV_HAS_IRIG_CTRL_BITS_TCR51USB, PCPS_HAS_IRIG_CTRL_BITS );
      check_feature( pddev, REV_HAS_IRIG_TIME_TCR51USB, PCPS_HAS_IRIG_TIME );
      check_feature( pddev, REV_HAS_RAW_IRIG_DATA_TCR51USB, PCPS_HAS_RAW_IRIG_DATA );
      break;

    case PCPS_TYPE_MSF51USB:
      pddev->dev.cfg.features = PCPS_FEAT_MSF51USB;
      break;

    case PCPS_TYPE_PTP270PEX:
      pddev->dev.cfg.features = PCPS_FEAT_PTP270PEX;
      break;

    case PCPS_TYPE_FRC511PEX:
      pddev->dev.cfg.features = PCPS_FEAT_FRC511PEX;
      break;

    case PCPS_TYPE_TCR170PEX:
      pddev->dev.cfg.features = PCPS_FEAT_TCR170PEX;
      break;

    case PCPS_TYPE_WWVB51USB:
      pddev->dev.cfg.features = PCPS_FEAT_WWVB51USB;
      break;

    case PCPS_TYPE_GPS180PEX:
      pddev->dev.cfg.features = PCPS_FEAT_GPS180PEX;
      break;

    case PCPS_TYPE_TCR180PEX:
      pddev->dev.cfg.features = PCPS_FEAT_TCR180PEX;
      break;

    case PCPS_TYPE_DCF600USB:
      pddev->dev.cfg.features = PCPS_FEAT_DCF600USB;
      break;

    case PCPS_TYPE_PZF180PEX:
      pddev->dev.cfg.features = PCPS_FEAT_PZF180PEX;
      break;

    case PCPS_TYPE_TCR600USB:
      pddev->dev.cfg.features = PCPS_FEAT_TCR600USB;
      break;

    case PCPS_TYPE_MSF600USB:
      pddev->dev.cfg.features = PCPS_FEAT_MSF600USB;
      break;

    case PCPS_TYPE_WVB600USB:
      pddev->dev.cfg.features = PCPS_FEAT_WVB600USB;
      break;

    default:
      #if defined( MBG_TGT_LINUX )
        printk( KERN_WARNING "%s: no feature detection for device %s\n",
                pcps_driver_name, _pcps_ddev_type_name( pddev ) );
      #elif defined( MBG_TGT_BSD )
        printf( "%s: no feature detection for device %s\n",
                pcps_driver_name, _pcps_ddev_type_name( pddev ) );
      #elif defined( MBG_TGT_WIN32 )
        swprintf( pddev->wcs_msg, L"no feature detection for device %S",
                  _pcps_ddev_type_name( pddev ) );
        _evt_msg( GlbDriverObject, pddev->wcs_msg );
      #endif
      goto fail_with_cleanup;

  }  // switch


  if ( _pcps_ddev_has_receiver_info( pddev ) )
  {
    rc = _pcps_read_gps_var( pddev, PC_GPS_RECEIVER_INFO, pddev->ri );

    if ( rc == MBG_SUCCESS )
    {
      _mbg_swab_receiver_info( &pddev->ri );
      _mbgddmsg_1( MBG_DBG_INIT_DEV, "Successfully read receiver info from dev %X",
                   _pcps_ddev_dev_id( pddev ) );

      goto check;
    }

    _mbgddmsg_1( MBG_DBG_INIT_DEV, "Failed to read receiver info from dev %X",
                 _pcps_ddev_dev_id( pddev ) );

  }

  _mbgddmsg_1( MBG_DBG_INIT_DEV, "Setting up default receiver info for dev %X",
               _pcps_ddev_dev_id( pddev ) );

  if ( _pcps_ddev_is_gps( pddev ) )
    _setup_default_receiver_info_gps( &pddev->ri );
  else
    _setup_default_receiver_info_dcf( &pddev->ri, &pddev->dev );


check:
  #if DEBUG_IO
    _mbgddmsg_1( MBG_DBG_DETAIL, "ri.sw_rev.code: %04X", pddev->ri.sw_rev.code );
    _mbgddmsg_1( MBG_DBG_DETAIL, "ri.model_code: %04X", pddev->ri.model_code );
    _mbgddmsg_3( MBG_DBG_DETAIL, "ri.model_name: %-*.*s", (int) sizeof( pddev->ri.model_name ),
                 (int) sizeof( pddev->ri.model_name ), pddev->ri.model_name );
  #endif


#if 0 //##+++++++++ check if this is reasonnable

  // Make sure this program supports at least as many ports as
  // the current clock device.
  if ( pddev->ri.n_com_ports > MAX_PARM_PORT )
  {
    _mbgddmsg_3( MBG_DBG_INIT_DEV, "%s provides %i COM ports, but this driver only supports %i",
                 _pcps_ddev_type_name( pddev ), pddev->ri.n_com_ports, MAX_PARM_PORT );
    pddev->ri.n_com_ports = MAX_PARM_PORT;
  }

  // Make sure this program supports at least as many string types
  // as the current clock device.
  if ( pddev->ri.n_str_type > MAX_PARM_STR_TYPE )
  {
    _mbgddmsg_3( MBG_DBG_INIT_DEV, "%s supports %i serial string formats, but this driver only supports %i",
                 _pcps_ddev_type_name( pddev ), pddev->ri.n_str_type, MAX_PARM_STR_TYPE );
    pddev->ri.n_str_type = MAX_PARM_STR_TYPE;
  }
#endif


  // detect the presence of some optional features at run time
  _mbgddmsg_3( MBG_DBG_INIT_DEV, "%s v%03X RECEIVER_INFO features: 0x%08lX",
               _pcps_ddev_type_name( pddev ), _pcps_ddev_fw_rev_num( pddev ),
               (ulong) pddev->ri.features );

  check_ri_feature( pddev, &pddev->ri, GPS_HAS_IRIG_TX, PCPS_HAS_IRIG_TX );
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_IRIG_CTRL_BITS, PCPS_HAS_IRIG_CTRL_BITS );
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_SYNTH, PCPS_HAS_SYNTH );
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_TIME_SCALE, PCPS_HAS_TIME_SCALE );

  // Devices which support a configurable time scale do also
  // support reading/writing the GPS UTC parameters via the PC bus.
  // This is not explicitely coded in the rcvr_info structure
  // since the the rcvr_info structure can also be read via
  // the serial port, and reading/writing the GPS UTC parameters
  // via the serial port is supported by all GPS devices anyway.
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_TIME_SCALE, PCPS_HAS_UTC_PARM );

  // Devices which support reading raw IRIG data via the PC interface also support
  // reading the raw IRIG time. However, there is no receiver info feature flag
  // since this call is not supported via the serial interface, so we use the
  // GPS_HAS_RAW_IRIG_DATA flag to check both features.
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_RAW_IRIG_DATA, PCPS_HAS_IRIG_TIME );
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_RAW_IRIG_DATA, PCPS_HAS_RAW_IRIG_DATA );

  check_ri_feature( pddev, &pddev->ri, GPS_HAS_LAN_IP4, PCPS_HAS_LAN_INTF );
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_PTP, PCPS_HAS_PTP );
  // check_ri_feature( pddev, &pddev->ri, GPS_HAS_PTP_UNICAST, 0 );  // no equivalent in PCPS_DDEV features
  check_ri_feature( pddev, &pddev->ri, GPS_HAS_EVT_LOG, PCPS_HAS_EVT_LOG );

  #if !defined( MBG_TGT_OS2 ) && !defined( MBG_TGT_BSD )
    // Function strstr may not be supported at kernel level,
    // but this is not required, in most cases, either.
    if ( strstr( _pcps_ddev_fw_id( pddev ), "CERN" ) != NULL )
      pddev->dev.cfg.features |= PCPS_HAS_EVENT_TIME;
  #endif

  #if DEBUG_IO && defined( MBG_TGT_LINUX )
  {
    PCPS_TIME t = { 0 };
    printk( KERN_INFO "reading current time as test:\n" );
    rc = _pcps_read( pddev, PCPS_GIVE_TIME, &t, sizeof( t ) );
    printk( KERN_INFO "read time, sz: %lu, returned %i\n", (ulong) sizeof( t ), rc );
    printk( KERN_INFO "  sec100 %02X, sec %02X, min %02X hour %02X\n",
            t.sec100, t.sec, t.min, t.hour );
    printk( KERN_INFO "  mday %02X, wday %02X, month %02X year %02X\n",
            t.mday, t.wday, t.month, t.year );
    printk( KERN_INFO "  status %02X, sig %02X, offs_utc %02X\n",
            t.status, t.signal, t.offs_utc );
  }
  #endif

  if ( _pcps_ddev_has_asic_features( pddev ) )
  {
    pddev->asic_features = _mbg_inp32_to_cpu( pddev, 0, _pcps_ddev_io_base_mapped( pddev, 0 )
       + offsetof( PCI_ASIC, features ) );

    _mbg_swab_asic_features( &pddev->asic_features );

    #if MBG_TGT_SUPP_MEM_ACC
      if ( pddev->asic_features & PCI_ASIC_HAS_MM_IO )
        pddev->dev.cfg.features |= PCPS_HAS_FAST_HR_TSTAMP;
      else
        if ( pddev->dev.cfg.features & PCPS_HAS_FAST_HR_TSTAMP )
        {
          // The device supports memory mapped time stamps by default.
          // However, this is not reflected by the ASIC features.
          _mbgddmsg_0( MBG_DBG_INIT_DEV,
                       "Warning: ASIC features don't reflect memory mapped time stamp support." );
        }

      if ( !has_mapped_sys_virtual_address( pddev ) )
        if ( pddev->dev.cfg.features & PCPS_HAS_FAST_HR_TSTAMP )
          if ( map_sys_virtual_address( pddev ) < 0 )
            goto fail_with_cleanup;
    #endif
  }

  pcps_read_sernum( pddev );

  _mbgddmsg_3( MBG_DBG_INIT_DEV, "%s v%03X actual features: 0x%08lX",
               _pcps_ddev_type_name( pddev ), _pcps_ddev_fw_rev_num( pddev ),
               (ulong) _pcps_ddev_features( pddev ) );

  return MBG_SUCCESS;


fail_with_cleanup:
  pcps_cleanup_device( pddev );

fail:
  return MBG_ERR_GENERIC;

}  // pcps_start_device



/*HDR*/
void pcps_cleanup_device( PCPS_DDEV *pddev )
{
  pddev->read = pcps_read_null;

  #if MBG_TGT_SUPP_MEM_ACC
    unmap_sys_virtual_address( pddev );
  #endif

  #if _PCPS_USE_RSRCMGR
    pcps_rsrc_release( pddev );
  #endif

}  // pcps_cleanup_device



/*--------------------------------------------------------------
 * PCI functions
 *-------------------------------------------------------------*/

#if _PCPS_USE_PCI_BIOS

static /*HDR*/
PCPS_ERR_FLAGS pcps_read_pci_rsrc( PCPS_BUS_NUM bus_num,
                                   PCPS_SLOT_NUM dev_fnc_num,
                                   PCPS_DDEV *pddev,
                                   PCPS_BUS_FLAGS bus_flags )
{
  PCPS_ERR_FLAGS err_flags = 0;
  uchar irq;
  short rc;
  PCI_DWORD dw;
  int i;

  // Clear resources
  memset( &pddev->rsrc_info, 0, sizeof( pddev->rsrc_info ) );

  for ( i = 0; i < MAX_PCPS_RSRC; i++ )
  {
    rc = _mbg_pci_read_cfg_dword( bus_num, dev_fnc_num,
           PCI_CS_BASE_ADDRESS_0 + i * sizeof( uint32_t ), &dw );

    if ( rc != PCI_SUCCESS )
      break;

    if ( dw == 0 )   // base address register not used
      continue;

    if ( dw & 0x0001 )   // is an I/O resource
    {
      if ( dw & 0xFFFF0000UL )
      {
        // The PCI interface chip is not initialized. This
        // should occur ONLY at the first-time installation
        // at the factory.
        err_flags |= PCPS_EF_IO_INIT;
        goto done;
      }

      pcps_add_rsrc_io( pddev, (uint16_t) ( dw & ~0x0001 ), 0 );
    }
    else
      pcps_add_rsrc_mem( pddev, dw, 0 );  //##++ range length?
  }

  // Read the interrupt line assigned to the clock.
  // The standard functions, however, don't use any
  // interrupt.
  rc = _mbg_pci_read_cfg_byte( bus_num, dev_fnc_num,
                               PCI_CS_INTERRUPT_LINE, &irq );

  if ( rc == PCI_SUCCESS )
    pcps_add_rsrc_irq( pddev, irq );

done:
  return err_flags;

}  // pcps_read_pci_rsrc



static /*HDR*/
PCPS_ERR_FLAGS pcps_enable_pci_dev( PCPS_BUS_NUM bus_num,
                                    PCPS_SLOT_NUM dev_fnc_num,
                                    int num_rsrc_mem )
{
  PCPS_ERR_FLAGS err_flags = 0;
  uint16_t pci_command;
  uint16_t new_pci_command;
  int rc;


  // If the option "PNP OS installed" is set to "YES" in the
  // PC's BIOS setup, then I/O access to the board may still
  // be disabled, so check if the clock is enabled and enable
  // access to the board, if nessessary.
  rc = _mbg_pci_read_cfg_word( bus_num, dev_fnc_num,
                               PCI_CS_COMMAND, &pci_command );
  new_pci_command = pci_command | PCI_CMD_ENB_IO_ACC;

  if ( num_rsrc_mem )
    new_pci_command |= PCI_CMD_ENB_MEM_ACC;

  if ( new_pci_command != pci_command )
  {
    rc = _mbg_pci_write_cfg_word( bus_num, dev_fnc_num,
                                  PCI_CS_COMMAND, pci_command );
    if ( rc != PCI_SUCCESS )
    {
      err_flags |= PCPS_EF_IO_ENB;

      _mbgddmsg_1( MBG_DBG_INIT_DEV,
                   "PCI enable device returned %d", rc );
    }
  }

  return err_flags;

}  // pcps_enable_pci_dev



/*HDR*/
void pcps_setup_and_start_pci_dev( PCPS_DDEV *pddev,
            PCPS_BUS_NUM bus_num, PCPS_SLOT_NUM dev_fnc_num )
{
  PCPS_ERR_FLAGS err_flags;

  err_flags = pcps_read_pci_rsrc( bus_num, dev_fnc_num,
                  pddev, _pcps_ddev_bus_flags( pddev ) );
  _pcps_ddev_set_err_flags( pddev, err_flags );

  if ( !( err_flags & PCPS_EF_IO_INIT ) )
  {
    err_flags = pcps_enable_pci_dev( bus_num, dev_fnc_num,
                  pddev->rsrc_info.num_rsrc_mem );
    _pcps_ddev_set_err_flags( pddev, err_flags );
  }

  pcps_start_device( pddev, bus_num, dev_fnc_num );

}  // pcps_setup_and_start_pci_dev



/*HDR*/
void pcps_detect_pci_clocks( PCPS_DDEV_ALLOC_FNC alloc_fnc, void *alloc_arg,
                             PCPS_DDEV_CLEANUP_FNC cleanup_fnc, 
                             ushort vendor_id, PCPS_DEV_TYPE dev_type[], 
                             int n_dev_types )
{
  #if defined( MBG_TGT_QNX )
    #if defined( MBG_TGT_QNX_NTO )
      unsigned int pci_handle;  // specific to QNX Neutrino
    #endif
    unsigned int pci_hardware_mechanism;
    unsigned int pci_last_bus_number;
    unsigned int pci_interface_level_version;
  #elif defined( MBG_TGT_LINUX )
    // not yet supported/used
  #else
    uchar pci_hardware_mechanism;
    uchar pci_last_bus_number;
    ushort pci_interface_level_version;
  #endif
  ushort type_idx;
  int rc;


  #ifdef _mbg_pci_fnc_init
    rc = _mbg_pci_fnc_init();

    if ( rc != PCI_SUCCESS )
      return;
  #endif


  // See if PCI BIOS is installed on the machine.
  rc = _mbg_pci_find_bios( &pci_hardware_mechanism,
                           &pci_interface_level_version,
                           &pci_last_bus_number
                         );

  if ( rc == PCI_SUCCESS )
  {
    // PCI BIOS is installed, now try to find a PCI clock with
    // known ID (the list is terminated with a ID of 0).
    for ( type_idx = 0; type_idx < n_dev_types; type_idx++ )
    {
      ushort dev_idx;
      PCPS_DEV_TYPE *p = &dev_type[type_idx];

      if ( !( p->bus_flags & PCPS_BUS_PCI ) )
        continue;


      for ( dev_idx = 0; ; dev_idx++ )
      {
        PCPS_DDEV *pddev;
        #if defined( MBG_TGT_QNX )
          unsigned bus_num;
          unsigned dev_fnc_num;
        #else
          uchar bus_num;
          uchar dev_fnc_num;
        #endif

        rc = _mbg_pci_find_device( p->dev_id, vendor_id,
                                   dev_idx, &bus_num, &dev_fnc_num );

        if ( rc != PCI_SUCCESS )
          break;  // go to try next device ID


        _mbgddmsg_2( MBG_DBG_INIT_DEV, "Found PCI device %s (0x%04X)",
                     p->name, p->dev_id );

        // New device found, try to add to list.
        pddev = alloc_fnc();

        if ( pddev )  // Setup only if successful.
        {
          #if _PCPS_USE_PCI_PNP  //##++
            // This can be used to test the PNP functions in a
            // non-PNP environment.
            pcps_init_ddev( pddev, PCPS_BUS_PCI, p->dev_id );
          #else
            pddev->dev.type = *p;
          #endif

          pcps_setup_and_start_pci_dev( pddev, bus_num, dev_fnc_num );

          #if !_ACCEPT_UNINITD_CLOCKS
            if ( pddev->dev.cfg.err_flags )
            {
              _mbgddmsg_1( MBG_DBG_INIT_DEV,
                           "Remove PCI device: err_flags " FMT_08X "h",
                           (ulong) pddev->dev.cfg.err_flags );

              if ( cleanup_fnc )
                cleanup_fnc( pddev );
            }
          #endif
        }
      }
    }
  }

  #ifdef _mbg_pci_fnc_deinit
    _mbg_pci_fnc_deinit();
  #endif

}  // pcps_detect_pci_clocks

#endif  // _PCPS_USE_PCI_BIOS



/*--------------------------------------------------------------
 * Try to detect ISA clocks
 *-------------------------------------------------------------*/

#if !_PCPS_USE_ISA_PNP

/*HDR*/
void pcps_detect_isa_clocks( PCPS_DDEV_ALLOC_FNC alloc_fnc,
                             PCPS_DDEV_CLEANUP_FNC cleanup_fnc,
                             PCPS_DDEV_REGISTER_FNC register_fnc,
                             int isa_ports[PCPS_MAX_ISA_CARDS],
                             int isa_irqs[PCPS_MAX_ISA_CARDS] )
{
  int *p_port = isa_ports;
  int *p_irq = isa_irqs;
  PCPS_DDEV *pddev;
  int i;

  if ( p_port == NULL )   // No list has been passed
    return;               // so don't try to detect ISA clocks.


  for( i = 0; i < PCPS_MAX_ISA_CARDS;
       i++, p_port++, p_irq ? ( p_irq++ ) : p_irq )
  {
    int irq_num;

    if ( *p_port == 0 )
      continue;

    irq_num = p_irq ? *p_irq : -1;

    _mbgddmsg_2( MBG_DBG_INIT_DEV,
                 "Check ISA device at port " FMT_03X "h, irq %d",
                 *p_port, irq_num );

    // Assume ISA device is available,
    // but clock type is unknown, yet.
    pddev = alloc_fnc();

    if ( pddev )  // Setup only if successfull.
    {
      pddev->dev.type.bus_flags = PCPS_BUS_ISA;

      // Set up basic cfg for ISA devices.
      pcps_add_rsrc_io( pddev, (uint16_t) *p_port, PCPS_NUM_PORTS_ISA );

      if ( irq_num != -1 )
        pcps_add_rsrc_irq( pddev, (uint16_t) *p_irq );

      // Init the device structure. This includes registration
      // of I/O ports with the OS's resource manager (if supported),
      // and reading the firmware ID.
      pcps_start_device( pddev, 0, 0 );

      // If an error has occurred, then remove the last
      // device from the list and try next.
      if ( pddev->dev.cfg.err_flags )
      {
        _mbgddmsg_1( MBG_DBG_INIT_DEV,
                     "ISA device not found: err_flags " FMT_08X "h",
                     (ulong) pddev->dev.cfg.err_flags );
        if ( cleanup_fnc )
          cleanup_fnc( pddev );

        continue;
      }

      // Register the device with the OS, if required.
      if ( register_fnc )
        register_fnc( pddev );  //##++
    }
  }

}  // pcps_detect_isa_clocks

#endif  //!_PCPS_USE_ISA_PNP



#if !_PCPS_USE_PNP

/*--------------------------------------------------------------
 * Try to detect any plug-in device. If a DOS TSR is
 * installed, be sure it is disabled (BUSY flag set) when
 * this function is called.
 *-------------------------------------------------------------*/

/*HDR*/
void _MBG_INIT_CODE_ATTR pcps_detect_clocks_alloc( PCPS_DDEV_ALLOC_FNC alloc_fnc,
                                                   void *alloc_arg,
                                                   PCPS_DDEV_CLEANUP_FNC cleanup_fnc,
                                                   int isa_ports[PCPS_MAX_ISA_CARDS],
                                                   int isa_irqs[PCPS_MAX_ISA_CARDS] )
{
  #if defined( MBG_TGT_OS2 )
    rsrc_register_driver();  // register driver and init resource manager
  #endif

  #if _PCPS_USE_PCI_BIOS
    pcps_detect_pci_clocks( alloc_fnc, alloc_arg, cleanup_fnc, 
                            PCI_VENDOR_MEINBERG, pcps_dev_type, N_PCPS_DEV_TYPE );
  #endif

  #if _PCPS_USE_MCA
    pcps_detect_mca_clocks( alloc_fnc, alloc_arg );
  #endif

  #if !_PCPS_USE_ISA_PNP
    pcps_detect_isa_clocks( alloc_fnc, cleanup_fnc, NULL, isa_ports, isa_irqs );
  #endif

}  // pcps_detect_clocks_alloc



/*HDR*/
void _MBG_INIT_CODE_ATTR pcps_detect_clocks( int isa_ports[PCPS_MAX_ISA_CARDS],
                                             int isa_irqs[PCPS_MAX_ISA_CARDS] )
{
  pcps_detect_clocks_alloc( pcps_alloc_ddev, NULL, pcps_free_ddev,
                            isa_ports, isa_irqs );

}  // pcps_detect_clocks

#endif  // !_PCPS_USE_PNP


