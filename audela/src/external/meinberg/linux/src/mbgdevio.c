
/**************************************************************************
 *
 *  $Id: mbgdevio.c 1.35.1.29 2011/11/25 15:03:19 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Functions called from user space to access Meinberg device drivers.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgdevio.c $
 *  Revision 1.35.1.29  2011/11/25 15:03:19  martin
 *  Support on-board event logs.
 *  Revision 1.35.1.28  2011/11/23 18:18:50  martin
 *  Fixed build under DOS.
 *  Revision 1.35.1.27  2011/11/23 16:41:14Z  martin
 *  New functions mbg_dev_has_debug_status() and
 *  mbg_get_debug_status().
 *  Revision 1.35.1.26  2011/09/26 13:58:54  martin
 *  Added a workaround to make mbgmon (BC) build under Windows.
 *  In mbg_get_serial_settings() return an error if the number of provided
 *  serial ports or supported string types exceeds the numbers supported
 *  by the driver.
 *  Moved mbg_get_serial_settings() and mbg_save_serial_settings()
 *  to an extra file. These functions expect parameters the sizes of
 *  which might change in future API versions, which would make 
 *  functions exported by shared libraries incompatible across versions.
 *  Made functions mbg_get_gps_all_port_info() and
 *  mbg_get_gps_all_str_type_info() non-static so they are now exported
 *  by the shared libraries built from this module.
 *  Include cfg_hlp.h.
 *  Revision 1.35.1.25  2011/07/20 15:50:51Z  martin
 *  Conditionally use older IOCTL request buffer structures.
 *  Moved some macros etc. to the .h file.
 *  Modified some macros.
 *  Revision 1.35.1.24  2011/07/14 14:54:00  martin
 *  Modified generic IOCTL handling such that for calls requiring variable sizes
 *  a fixed request block containing input and output buffer pointers and sizes is
 *  passed down to the kernel driver. This simplifies implementation under *BSD
 *  and also works for other target systems.
 *  Revision 1.35.1.23  2011/07/08 10:11:00  martin
 *  Fixes for DOS.
 *  Revision 1.35.1.22  2011/07/06 11:19:20Z  martin
 *  Support reading CORR_INFO, and reading/writing TR_DISTANCE.
 *  Revision 1.35.1.21  2011/06/29 11:09:55  martin
 *  Added mbg_dev_has_pzf() function.
 *  Revision 1.35.1.20  2011/06/27 13:02:50  martin
 *  Use O_RDWR flag when opening a device.
 *  Revision 1.35.1.19  2011/06/24 11:13:36  martin
 *  Revision 1.35.1.18  2011/06/22 10:05:45  martin
 *  Support PTP unicast configuration.
 *  Account for some IOCTL codes renamed to follow common naming conventions.
 *  Revision 1.35.1.17  2011/04/12 12:56:20  martin
 *  Renamed mutex stuff to critical sections.
 *  Revision 1.35.1.16  2011/03/31 13:18:46  martin
 *  Coding style.
 *  Revision 1.35.1.15  2011/02/16 10:15:13  martin
 *  Revision 1.35.1.14  2011/02/15 14:24:55Z  martin
 *  Revision 1.35.1.13  2011/02/15 11:21:47  daniel
 *  Added API calls to support PTP unicast.
 *  Revision 1.35.1.12  2011/02/09 17:08:28Z  martin
 *  Specify I/O range number when calling port I/O macros
 *  so they can be used for different ranges under BSD.
 *  Revision 1.35.1.11  2011/02/01 15:08:08  martin
 *  Revision 1.35.1.10  2011/01/28 09:33:21  martin
 *  Modifications to support FreeBSD.
 *  Revision 1.35.1.9  2010/12/14 11:23:47  martin
 *  Moved definition of MBG_HW_NAME to the header file.
 *  Revision 1.35.1.8  2010/12/14 10:56:33Z  martin
 *  Revision 1.35.1.7  2010/08/18 13:43:20  martin
 *  Revision 1.35.1.6  2010/08/11 13:48:52  martin
 *  Cleaned up comments.
 *  Revision 1.35.1.5  2010/08/11 12:43:51  martin
 *  Revision 1.35.1.4  2010/05/21 13:10:37  martin
 *  Fixed platforms where cycles are not supported.
 *  Revision 1.35.1.3  2010/04/26 14:46:41  martin
 *  Compute PC cycles frequency under Linux if cpu_tick is not set by the kernel.
 *  Revision 1.35.1.2  2010/02/09 14:05:38  stefan
 *  Fixed a bug that kept the function  mbg_open_device_by_name in a loop under certain conditions.
 *  Revision 1.35.1.1  2010/02/05 11:49:26  martin
 *  Made xhrt leap second check an inline function.
 *  Revision 1.35  2010/01/12 13:40:25  martin
 *  Fixed a typo in mbg_dev_has_raw_irig_data().
 *  Revision 1.34  2009/12/15 15:34:58Z  daniel
 *  Support reading the raw IRIG data bits for firmware versions 
 *  which support this feature.
 *  Revision 1.33  2009/09/29 15:08:40Z  martin
 *  Support retrieving time discipline info.
 *  Revision 1.32  2009/08/17 13:46:29  martin
 *  Moved specific definition of symbol _HAVE_IOCTL_WITH_SIZE
 *  to mbgioctl.h and renamed it to _MBG_SUPP_VAR_ACC_SIZE.
 *  Revision 1.31  2009/08/12 14:28:26  daniel
 *  Included PTP functions in build.
 *  Revision 1.30  2009/06/19 12:19:41Z  martin
 *  Support reading raw IRIG time.
 *  Revision 1.29  2009/06/08 18:23:22  daniel
 *  Added PTP configuration functions and PTP state functions, but 
 *  they are still excluded from build.
 *  Added calls to support simple LAN interface configuration.
 *  Revision 1.28  2009/03/19 15:30:04  martin
 *  Added support for configurable time scales.
 *  Support reading/writing GPS UTC parameters.
 *  Support reading IRIG control function bits.
 *  Support reading MM timestamps without cycles.
 *  Fixed endianess correction in mbg_get_gps_pos().
 *  Endianess correction for ASIC version and ASIC features
 *  is now done by the kernel driver.
 *  Use generic cycles types and functions in mbg_get_default_cycles_frequency().
 *  mbg_tgt.h is now included in mbgdevio.h.
 *  Account for renamed IOCTL codes.
 *  Revision 1.27  2008/12/17 10:37:37  martin
 *  Fixed a bug in mbg_open_device_by_name() with sel. mode MBG_MATCH_ANY.
 *  Support variable read buffer sizes under Linux, so 
 *  mbg_get_all_port_info() and mbg_get_all_str_type_info()
 *  can now be used under Linux.
 *  Support PC cycles under Linux via inline rdtsc call.
 *  Use predefined constants to convert fractions.
 *  New API calls mbg_get_fast_hr_timestamp_cycles(), and 
 *  mbg_get_fast_hr_timestamp_comp() which take memory mapped HR time stamps
 *  in kernel space, and mbg_dev_has_fast_hr_timestamp() to check whether 
 *  this is supported by a device.
 *  Removed mm_*() functions since these are obsolete now.
 *  Support extrapolated HR time (xhrt) for Windows and Linux 
 *  by providing a function mbg_xhrt_poll_thread_create() which 
 *  starts a poll thread for a specific device which to read
 *  HR time plus associated cycles in regular intervals.
 *  Added functions mbg_get_process_affinity(), mbg_set_process_affinity(),
 *  and mbg_set_current_process_affinity_to_cpu(), and mbg_create_thread() 
 *  and mbg_set_thread_affinity() to control the extrapolation feature.
 *  Use new preprocessor symbol MBGDEVIO_HAVE_THREAD_AFFINITY.
 *  Added new functions mbg_get_xhrt_time_as_pcps_hr_time() and
 *  mbg_get_xhrt_time_as_filetime() (Windows only) to retrieve 
 *  fast extrapolated timestamps.
 *  Added function mbg_get_xhrt_cycles_frequency() to retrieve the 
 *  cycles counter frequency computed by the polling thread.
 *  Added function mbg_get_default_cycles_frequency_from_dev(), 
 *  and mbg_get_default_cycles_frequency() (Windows only).
 *  Moved mbg_open_device..() functions upwards.
 *  Made device_info_list common.
 *  New functions mbg_dev_is_msf(), mbg_dev_is_wwvb(), mbg_dev_is_lwr(),
 *  mbg_dev_has_asic_version(), mbg_dev_has_asic_features(),
 *  and mbg_get_irq_stat_info().
 *  Exclude 2 more functions from build if symbol MBGDEVIO_SIMPLE is not 0.
 *  Account for MBG_VIRT_ADDR having beenrenamed to MBG_MEM_ADDR.
 *  Account Linux for device names renamed from /dev/mbgclk to /dev/mbgclock.
 *  Support bigendian target platforms.
 *  Revision 1.26  2008/02/26 16:54:21  martin
 *  New/changed functions for memory mapped access which are 
 *  currently excluded from build.
 *  Changed separator for device names from ' ' to '_'.
 *  Added new type MBG_HW_NAME.
 *  Comment cleanup for doxygen.
 *  Revision 1.25  2008/02/04 13:42:45Z  martin
 *  Account for preprocessor symbol MBG_TGT_SUPP_MMAP.
 *  Revision 1.24  2008/01/31 08:31:40Z  martin
 *  Picked up changes from 1.19.1.2:
 *  Under DOS detect and disable any TSR while searching for devices.
 *  Exclude some complex configuration API calls from build
 *  If MBGDEVIO_SIMPLE is defined != 0.
 *  Revision 1.23  2008/01/30 10:32:35Z  daniel
 *  Renamed mapped memory funtions.
 *  Revision 1.22  2008/01/25 15:27:42Z  daniel
 *  Fixed a bug in mbg_get_hr_time_comp() where an overflow 
 *  of the fractions was handled with wrong sign.
 *  Revision 1.21  2008/01/17 15:49:59Z  daniel
 *  Added functions mbg_find_devices_with_hw_id() and 
 *  mbg_free_devics_list() to work with Linux Win32 OSs.
 *  Added Doxygen compliant comments for API functions.
 *  Support for mapped memory I/O under linux and windows.
 *  Added functions mbg_get_mapped_memory_info(),
 *  mbg_unmap_mapped_memory() and
 *  mbg_get_hr_timestamp_memory_mapped().
 *  Account for PCI_ASIC_FEATURES.
 *  Cleanup for PCI ASIC version.
 *  Revision 1.20  2007/09/27 07:31:12  daniel
 *  Moved declaration of portable inline specifier to mbg_tgt.h.
 *  Support hotplugging of devices as used with USB by Daniel's new
 *  functions mbg_find_devices_with_names(), mbg_free_device_name_list(),
 *  mbg_open_device_by_hw_id(), and mbg_open_device_by_name().
 *  In mbg_get_serial_settings() account for devices which have no
 *  serial port at all.
 *  Register event source if Windows DLL is loaded.
 *  Revision 1.19  2007/05/21 15:00:00Z  martin
 *  Unified naming convention for symbols related to ref_offs.
 *  Revision 1.18  2007/03/02 10:17:41Z  martin
 *  Use generic port I/O macros.
 *  Changes due to modified/renamed macros.
 *  Changes due to renamed library symbols.
 *  Preliminary support for *BSD.
 *  Revision 1.17  2006/05/02 13:15:37  martin
 *  Added mbg_set_gps_port_settings(), mbg_get_gps_all_pout_info(),
 *  mbg_set_gps_pout_settings_idx(), mbg_set_gps_pout_settings().
 *  Revision 1.16  2005/06/02 11:53:12Z  martin
 *  Implemented existing mbg_generic_..() functions.
 *  Added new functions mbg_generic_io() and mbg_dev_has_generic_io().
 *  Added new function mbg_get_synth_state().
 *  Partially use inline function.
 *  Changed order of some functions.
 *  More simplifications using macros.
 *  Unified macros for Win32 and Linux.
 *  Fixed warning under Win32 using type cast.
 *  Revision 1.15  2005/01/31 16:44:21Z  martin
 *  Added function mbg_get_hr_time_comp() which returns HR time stamp 
 *  which has latency compensated.
 *  Revision 1.14  2005/01/14 10:22:23Z  martin
 *  Added functions which query device features.
 *  Revision 1.13  2004/12/09 11:23:59Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.12  2004/11/09 14:11:07Z  martin
 *  Modifications were required in order to be able to configure IRIG 
 *  settings of cards which provide both IRIG input and output.
 *  Renamed functions mbg_get_irig_info() and mbg_set_irig_settings() 
 *  to mbg_get_irig_rx_info() and mbg_set_irig_rx_settings() 
 *  New functions mbg_get_irig_tx_info() and mbg_set_irig_tx_settings().
 *  All API functions now use well defined parameter types instead of
 *  generic types. Some new types have been defined therefore.
 *  Added a workaround for GPS169PCI cards with early firmware versions
 *  which used the same codes to configure the IRIG output as the TCR 
 *  cards use to configure the IRIG input. Those codes are now 
 *  exclusively used to configure the IRIG input. The workaround
 *  has been included in order to let GPS169PCI cards work properly 
 *  after a driver update, without requiring a firmware update.
 *  The macro _pcps_ddev_requires_irig_workaround() is used to check 
 *  if the workaround is required.
 *  Renamed function mbg_get_gps_stat() to mbg_get_gps_bvar_stat().
 *  Revision 1.11  2004/08/17 11:13:45Z  martin
 *  Account for renamed symbols.
 *  Revision 1.10  2004/04/14 09:39:17Z  martin
 *  Allow [g|s]et_irig_info() also for new devices with IRIG output.
 *  Use MBGDEVIO_COMPAT_VERSION to check version.
 *  Revision 1.9  2003/12/22 15:30:52Z  martin
 *  Added functions mbg_get_asic_version(), mbg_get_time_cycles(),
 *  and mbg_get_hr_time_cycles().
 *  Support higher baud rates for TCR510PCI and PCI510.
 *  Support PCPS_HR_TIME for TCR510PCI.
 *  API calls return ioctl results instead of success/-1.
 *  Moved some Win32 specific code to mbgsvctl DLL.
 *  Log Win32 ioctl errors to event log for debugging.
 *  Revision 1.8  2003/06/19 08:42:33Z  martin
 *  Renamed function mbg_clr_cap_buff() to mbg_clr_ucap_buff().
 *  New functions mbg_get_ucap_entries() and mbg_get_ucap_event().
 *  New function mbg_get_hr_ucap().
 *  New functions mbgdevio_get_version() and mbgdevio_check_version().
 *  New functions for generic read/write access.
 *  New functions mbg_get_pcps_tzdl() and mbg_set_pcps_tzdl().
 *  Fixed a bug passing the wrong command code to a 
 *  direct access target in mbg_get_sync_time().
 *  Return driver info for direct access targets.
 *  Include pcpsdrvr.h and pcps_dos.h, if applicable.
 *  For direct access targets, check if a function is supported
 *  before accessing the hardware.
 *  Use const parameter pointers if applicable.
 *  Changes due to renamed symbols/macros.
 *  Source code cleanup.
 *  Revision 1.7  2003/05/16 08:52:46  MARTIN
 *  Swap doubles inside API functions.
 *  Enhanced support for direct access targets.
 *  Removed obsolete code.
 *  Revision 1.6  2003/04/25 10:14:16  martin
 *  Renamed macros.
 *  Extended macro calls for direct access targets.
 *  Updated macros for Linux.
 *  Revision 1.5  2003/04/15 19:35:25Z  martin
 *  New functions mbg_setup_receiver_info(), 
 *  mbg_get_serial_settings(), mbg_save_serial_settings().
 *  Revision 1.4  2003/04/09 16:07:16Z  martin
 *  New API functions mostly complete.
 *  Use renamed IOCTL codes from mbgioctl.h.
 *  Added DllEntry function foe Win32.
 *  Made MBG_Device_count and MBG_Device_Path local.
 *  Revision 1.3  2003/01/24 13:44:40Z  martin
 *  Fixed get_ref_time_from_driver_at_sec_change() to be used 
 *  with old kernel drivers.
 *  Revision 1.2  2002/09/06 11:04:01Z  martin
 *  Some old API functions have been replaced by new ones
 *  for a common PnP/non-PnP API.
 *  New API function which clears capture buffer.
 *  New function get_ref_time_from_driver_at_sec_change().
 *  Revision 1.1  2002/02/19 13:48:20Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _MBGDEVIO
 #include <mbgdevio.h>
#undef _MBGDEVIO

#include <parmpcps.h>
#include <parmgps.h>
#include <gpsutils.h>
#include <mbgerror.h>
#include <cfg_hlp.h>

#if defined( MBG_TGT_DOS_PM )
  #include <mbg_dpmi.h>
#endif

#if !defined( MBG_USE_KERNEL_DRIVER )

  #include <pcpsdrvr.h>
  #include <pci_asic.h>
  #include <stdio.h>

  static PCPS_DRVR_INFO drvr_info = { MBGDEVIO_VERSION, 0, "MBGDEVIO direct" };

#endif



#define MAX_INFO_LEN 260

typedef struct 
{
  MBG_HW_NAME hw_name; 
  char model_name[PCPS_CLOCK_NAME_SZ];
  PCPS_SN_STR serial_number; 
  char hardware_id[MAX_INFO_LEN];    // OS dependent hardware_id to identify and open the device
} MBG_DEVICE_INFO;



// target specific code for different environments

#if defined( MBG_TGT_WIN32 )

  #include <mbgsvctl.h>
  #include <mbgnames.h>
  #include <pci_asic.h>
  #include <mbgutil.h> //##++
  #include <timecnv.h>
  #include <pcpsutil.h>

  #include <tchar.h>
  #include <stdio.h>

#elif defined( MBG_TGT_UNIX )

  #include <unistd.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdio.h>       // sprintf()
  #include <sys/mman.h>

#else // other target OSs which access the hardware directly

  #if defined( MBG_TGT_QNX_NTO )
    #include <stdio.h>
    #include <sys/neutrino.h>
  #endif

  #if MBG_USE_DOS_TSR
    #include <pcps_dos.h>
  #else
    #define pcps_read_safe            _pcps_read
    #define pcps_write_safe           pcps_write
    #define pcps_read_gps_safe        pcps_read_gps
    #define pcps_write_gps_safe       pcps_write_gps

    #define _pcps_write_byte_safe     _pcps_write_byte
    #define _pcps_read_var_safe       _pcps_read_var
    #define _pcps_write_var_safe      _pcps_write_var
    #define _pcps_read_gps_var_safe   _pcps_read_gps_var
    #define _pcps_write_gps_var_safe  _pcps_write_gps_var
  #endif

  #define _mbgdevio_chk_cond( _cond )                   \
  {                                                     \
    if ( !(_cond) )                                     \
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV ); \
  }

#endif  // end of target specific code


#if !defined( _MBG_SUPP_VAR_ACC_SIZE )
  // If this symbol has not yet been defined then mbgioctl.h has probably
  // not yet been included. On target systems where the hardware is accessed
  // directly without a kernel driver variable buffer sizes are supported,
  // so we set the default to 1.
  #define _MBG_SUPP_VAR_ACC_SIZE   1
#endif


#if !defined( _mbgdevio_chk_cond )
  // If the macro has not been defined previously then
  // it may not be required for the target environment and
  // is defined as empty string.
  #define _mbgdevio_chk_cond( _cond ) _nop_macro_fnc()
#endif



#define _mbgdevio_read_chk( _dh, _cmd, _ioctl, _p, _sz, _cond ) \
{                                                               \
  _mbgdevio_chk_cond( _cond );                                  \
  rc = _do_mbgdevio_read( _dh, _cmd, _ioctl, _p, _sz );         \
}

#define _mbgdevio_read_var_chk( _dh, _cmd, _ioctl, _p, _cond ) \
{                                                              \
  _mbgdevio_chk_cond( _cond );                                 \
  rc = _mbgdevio_read_var( _dh, _cmd, _ioctl, _p );            \
}

#define _mbgdevio_write_var_chk( _dh, _cmd, _ioctl, _p, _cond ) \
{                                                               \
  _mbgdevio_chk_cond( _cond );                                  \
  rc = _mbgdevio_write_var( _dh, _cmd, _ioctl, _p );            \
}

#define _mbgdevio_write_cmd_chk( _dh, _cmd, _ioctl, _cond ) \
{                                                           \
  _mbgdevio_chk_cond( _cond );                              \
  rc = _mbgdevio_write_cmd( _dh, _cmd, _ioctl );            \
}

#define _mbgdevio_read_gps_chk( _dh, _cmd, _ioctl, _p, _sz, _cond ) \
{                                                                   \
  _mbgdevio_chk_cond( _cond );                                      \
  rc = _do_mbgdevio_read_gps( _dh, _cmd, _ioctl, _p, _sz );         \
}

#define _mbgdevio_read_gps_var_chk( _dh, _cmd, _ioctl, _p, _cond ) \
{                                                                  \
  _mbgdevio_chk_cond( _cond );                                     \
  rc = _mbgdevio_read_gps_var( _dh, _cmd, _ioctl, _p );            \
}

#define _mbgdevio_write_gps_var_chk( _dh, _cmd, _ioctl, _p, _cond ) \
{                                                                   \
  _mbgdevio_chk_cond( _cond );                                      \
  rc = _mbgdevio_write_gps_var( _dh, _cmd, _ioctl, _p );            \
}



#if defined( _MBGIOCTL_H )
  #define _mbgdevio_query_cond( _dh, _cond, _ioctl, _p ) \
  {                                                      \
    _mbgdevio_vars();                                    \
    rc = _mbgdevio_read_var( _dh, -1, _ioctl, _p );      \
    return _mbgdevio_ret_val;                            \
  }

  #define _mbgdevio_query_ri_cond _mbgdevio_query_cond
#else
  #define _mbgdevio_query_cond( _dh, _cond, _ioctl, _p ) \
  {                                                      \
    *p = _cond( _dh );                                   \
    return MBG_SUCCESS;                                  \
  }

  #define _mbgdevio_query_ri_cond( _dh, _cond, _ioctl, _p ) \
  {                                                         \
    *p = _cond( &(_dh)->ri );                               \
    return MBG_SUCCESS;                                     \
  }
#endif


static MBG_PC_CYCLES_FREQUENCY pc_cycles_frequency;
static MBG_DEVICE_INFO device_info_list[MBG_MAX_DEVICES];



static /*HDR*/  //##++ make this public ?
int mbg_comp_hr_latency( PCPS_TIME_STAMP *ts,
                         const MBG_PC_CYCLES *p_cyc_ts,
                         const MBG_PC_CYCLES *p_cyc_ontime,
                         const MBG_PC_CYCLES_FREQUENCY *p_cyc_freq,
                         int32_t *hns_latency )
{
  #if defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_UNIX )

    int64_t cyc_latency;
    int64_t frac_latency;
    int64_t comp_frac;  //uint??

    // Compute latency in cycles counter units
    cyc_latency = mbg_delta_pc_cycles( p_cyc_ts, p_cyc_ontime );

    #if DEBUG && defined( MBG_TGT_LINUX ) && defined( MBG_ARCH_X86 )
      printf( "comp_lat: %08llX.%08llX %llX - %llX = %lli",
              (unsigned long long) ts->sec,
              (unsigned long long) ts->frac,
              (unsigned long long) *p_cyc_ts,
              (unsigned long long) *p_cyc_ontime,
              (unsigned long long) cyc_latency
            );
    #endif

    // Account for cycles counter overflow. This is
    // supposed to happen once every 2^^63 units of the
    // cycles counter frequency, i.e. about every
    // 97 years on a system with 3 GHz clock.
    if ( cyc_latency < 0 )
    {
      cyc_latency += ( (uint64_t) -1 ) >> 1;

      #if DEBUG && defined( MBG_TGT_LINUX )
        printf( "->%lli (%llX)", 
                (unsigned long long) cyc_latency,
                (unsigned long long) ( ( (uint64_t) -1 ) >> 1 )
              );
      #endif
    }

    // convert latency to binary fractions of seconds,
    // i.e. units of 2^^-32.
    frac_latency = (*p_cyc_freq) ? ( cyc_latency * ( ( (int64_t) 1 ) << 32 ) / *p_cyc_freq ) : 0;

    // compute the compensated fractional part of the HR time stamp
    // and account for borrows from the sec field
    comp_frac = ts->frac - frac_latency;
    ts->frac = (uint32_t) comp_frac;            // yields 32 LSBs
    ts->sec += (uint32_t) ( comp_frac >> 32 );  // yields 32 MSBs

    #if DEBUG && defined( MBG_TGT_LINUX )
      printf( " frac_lat: %llX comp_frac: %08llX.%08llX",
              (unsigned long long) frac_latency,
              (unsigned long long) ts->sec,
              (unsigned long long) ts->frac
            );
    #endif

    if ( hns_latency && *p_cyc_freq )
    {
      int64_t tmp_hns_latency;

      // convert to hectonanoseconds
      tmp_hns_latency = cyc_latency * 10000000 / *p_cyc_freq;

      // check for range overflow
      #define MAX_HNS_LATENCY    0x7FFFFFFF   // int32_t
      #define MIN_HNS_LATENCY    ( -MAX_HNS_LATENCY - 1 )

      if ( tmp_hns_latency > MAX_HNS_LATENCY )
        tmp_hns_latency = MAX_HNS_LATENCY;
      else
        if ( tmp_hns_latency < MIN_HNS_LATENCY )
          tmp_hns_latency = MIN_HNS_LATENCY;

      *hns_latency = (int32_t) tmp_hns_latency;
    }

    #if DEBUG && defined( MBG_TGT_LINUX )
      printf( "\n" );
    #endif

    return MBG_SUCCESS;

  #else

    // This is currently not supported by the target environment.
    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_ON_OS );

  #endif

}  // mbg_comp_hr_latency



/*HDR*/
/**
    Get the version number of the compiled mbgdevio library.
    If the mbgdevio library is built as a DLL/shared object then 
    the version number of the compiled library may differ from
    the version number of the import library and header files
    which have been used to build an application.

    @return The version number

    @see ::MBGDEVIO_VERSION defined in mbgdevio.h.
  */
_MBG_API_ATTR int _MBG_API mbgdevio_get_version( void )
{

  return MBGDEVIO_VERSION;

}  // mbgdevio_get_version



/*HDR*/
/**
    Check if the version of the compiled mbgdevio library is compatible
    with a certain version which is passed as parameter.

    @param header_version Version number to be checked, should be ::MBGDEVIO_VERSION 
                          defined in mbgdevio.h.

    @return ::MBG_SUCCESS if compatible, ::MBG_ERR_LIB_NOT_COMPATIBLE if not.

    @see ::MBGDEVIO_VERSION defined in mbgdevio.h.
  */
_MBG_API_ATTR int _MBG_API mbgdevio_check_version( int header_version )
{
  if ( header_version >= MBGDEVIO_COMPAT_VERSION )
    return MBG_SUCCESS;

  return _mbg_err_to_os( MBG_ERR_LIB_NOT_COMPATIBLE );

}  // mbgdevio_check_version



/*HDR*/
/**
    Open a device by index, starting from 0.
    This function is <b>out of date</b>, mbg_open_device_by_name() 
    should be used instead.

    See the <b>note</b> for mbg_find_device() for details.

    @param device_index Index of the device, use 0 for the first device.
  */
_MBG_API_ATTR MBG_DEV_HANDLE _MBG_API mbg_open_device( unsigned int device_index )
{
#if defined( MBG_TGT_WIN32 )

  const char *device_path;
  HANDLE dh;

  device_path = mbg_svc_get_device_path( device_index );

  if ( device_path == NULL )
    goto fail;


  dh = CreateFile( 
         device_path,                   // file name
         GENERIC_READ | GENERIC_WRITE,  // access mode
         0,                             // share mode
         NULL,                          // security descriptor
         OPEN_EXISTING,                 // how to create
         0,                             // file attributes
         NULL                           // handle to template file
       );

  if ( INVALID_HANDLE_VALUE == dh )
  {
    #if 0 //##++
      printf( "mbg_open_device: CreateFile failed for index %i\n", device_index );
    #endif

    goto fail;
  }

  return dh;

fail:
  return MBG_INVALID_DEV_HANDLE;

#elif defined( MBG_TGT_UNIX )

  MBG_DEV_HANDLE dh;
  char dev_fn[50];

  if ( device_index > MBG_MAX_DEVICES )
    device_index = MBG_MAX_DEVICES;

  sprintf( dev_fn, "/dev/mbgclock%d", device_index );    //##++

  dh = open( dev_fn, O_RDWR );

  return ( dh < 0 ) ? MBG_INVALID_DEV_HANDLE : dh;

#else

  return ( device_index < n_ddevs ) ? &pcps_ddev[device_index] : NULL;

#endif

} // mbg_open_device



static /*HDR*/
/* (Intentionally excluded from Doxygen)
  Return a handle to a device specified by a given hardware_id.
  The format the hardware_id depends on the operating system, so 
  this function is used only internally to detect devices for 
  which a unique name of the format MBG_HW_NAME is generated, 
  which is in turn used with the public API functions.
  */
MBG_DEV_HANDLE _MBG_API mbg_open_device_by_hw_id( const char* hw_id )
{
#if defined( MBG_TGT_WIN32 )

  HANDLE dh;
  int ret = 0;
  BOOL usb = FALSE;

  if ( hw_id == NULL )
    goto fail;

  dh = CreateFile( 
         hw_id,                         // file name
         GENERIC_READ | GENERIC_WRITE,  // access mode
         0,                             // share mode
         NULL,                          // security descriptor
         OPEN_EXISTING,                 // how to create
         strstr(hw_id,"usb") ? FILE_FLAG_OVERLAPPED : 0, // file attributes
         NULL                           // handle to template file
       );

  if ( INVALID_HANDLE_VALUE == dh )
    goto fail;

  return dh;

fail:
  return MBG_INVALID_DEV_HANDLE;

#elif defined ( MBG_TGT_UNIX )

  MBG_DEV_HANDLE dh = -1;

  if ( strlen( hw_id ) > 0 )
    dh = open( hw_id, O_RDWR );

  return ( dh < 0 ) ? MBG_INVALID_DEV_HANDLE : dh;

#else

  return MBG_INVALID_DEV_HANDLE;

#endif

} // mbg_open_device_by_hw_id



/*HDR*/
/**
    Get the number of supported devices installed on the computer. 
    This function is <b>out of date</b>, mbg_find_devices_with_names() 
    should be used instead.

    <b>Note:</b> This function is out of date since it may not work 
    correctly for Meinberg devices which are disconnected and reconnected
    while the system is running (e.g. USB devices). However, the function 
    will be kept for compatibility reasons and works correctly if all 
    Meinberg devices are connected at system boot and are not disconnected 
    and reconnected during operation

    @return The number of devices found.

    @see mbg_find_devices_with_names()
  */
_MBG_API_ATTR int _MBG_API mbg_find_devices( void )
{
  #if defined( _PCPSDRVR_H )

    #if defined( MBG_TGT_QNX_NTO )
      // Since this program accessed the hardware directly
      // I/O privileges must be assigned to the thread.
      if ( ThreadCtl( _NTO_TCTL_IO, NULL ) == -1 )
      {
        perror( "Fatal error" );
        exit( 1 );
      }
    #endif

    #if defined( MBG_TGT_DOS ) && MBG_USE_DOS_TSR
    {
      short prv_busy;

      pcps_detect_any_tsr();
      prv_busy = pcps_tsr_set_busy_flag( 1 );
      pcps_detect_clocks( pcps_isa_ports, NULL );
      pcps_tsr_set_busy_flag( prv_busy );
    }
    #else
      pcps_detect_clocks( pcps_isa_ports, NULL );
    #endif

    return n_ddevs;

  #elif defined( MBG_TGT_WIN32 )

    return mbg_svc_find_devices();

#elif defined ( MBG_TGT_UNIX )

    MBG_DEV_HANDLE dh;
    int i = 0;
    int n = 0;

    while( i < MBG_MAX_DEVICES )
    {
      dh = mbg_open_device( i );

      if ( dh != MBG_INVALID_DEV_HANDLE )
      {
        mbg_close_device( &dh );
        n++;
      }

      i++;
    }

    return n;

  #endif

}  // mbg_find_devices



#if defined( MBG_TGT_WIN32 ) || defined ( MBG_TGT_UNIX )

static /*HDR*/
int mbg_find_devices_with_hw_id( MBG_DEVICE_LIST ** list, int max_devs )
{
  #if defined ( MBG_TGT_WIN32 )

    return mbg_svc_find_devices_with_hw_id( list, max_devs );

  #elif defined ( MBG_TGT_UNIX )

    MBG_DEVICE_LIST *ListBegin;
    int n = 0;
    int i = 0;

    (*list) = (MBG_DEVICE_LIST *) malloc( sizeof( **list ) );
    memset( *list, 0, sizeof( **list ) );

    ListBegin = (*list);

    for (;;)
    {
      char dev_name[100];
      MBG_DEV_HANDLE dh;

      sprintf( dev_name, "/dev/mbgclock%d", i );

      dh = mbg_open_device_by_hw_id( dev_name );

      if ( dh != MBG_INVALID_HANDLE )
      {
        mbg_close_device( &dh );

        (*list)->device_path = (char *) malloc( strlen( dev_name ) + 1 );
        strcpy( (*list)->device_path, dev_name );

        (*list)->next = (MBG_DEVICE_LIST *) malloc( sizeof( **list ) );
        (*list) = (*list)->next;

        memset( *list, 0, sizeof( **list ) );
        n++;
      }

      if ( ++i >= MBG_MAX_DEVICES )
        break;
    }

    if ( n > 0 )
      *list = ListBegin;
    else
    {
      free( *list );
      *list = NULL;
    }

    return n;

  #else

    return 0;

  #endif
}

#endif



#if defined ( MBG_TGT_WIN32 ) || defined ( MBG_TGT_UNIX )

static /*HDR*/
void _MBG_API mbg_free_device_list( MBG_DEVICE_LIST *devices )
{

  #if defined ( MBG_TGT_WIN32 )
    mbg_svc_free_device_list( devices );
  #else
    int i = 0;
    MBG_DEVICE_LIST *Next = NULL;

    while ( i < MBG_MAX_DEVICES)
    {
      if ( devices )
      {
        if ( devices->device_path )
        {
          free( devices->device_path );
          devices->device_path = NULL;
        }

        if ( devices->next )
        {
          Next = devices->next;
          free(devices);
          devices = Next;
        }
        else
        {
          if ( devices )
          {
            free( devices );
            devices = NULL;
          }
          break;
        }
      }
      else
        break;

      i++;
    }

  #endif
}

#endif



#if ( defined( MBG_TGT_WIN32 ) || defined ( MBG_TGT_UNIX ) )

static /*HDR*/
void get_hw_name_from_hw_id( MBG_DEVICE_INFO *dev_info )
{
  MBG_DEV_HANDLE dh;
  PCPS_DEV pdev;

  dh = MBG_INVALID_HANDLE;
  memset( &pdev, 0, sizeof( pdev ) );

  // Default initializers
  strcpy( dev_info->model_name, "N/A" );
  strcpy( dev_info->serial_number, "N/A" );
  strcpy( dev_info->hw_name, "N/A" );

  dh = mbg_open_device_by_hw_id( dev_info->hardware_id );

  if ( dh != MBG_INVALID_HANDLE )
  {
    if ( mbg_get_device_info( dh, &pdev ) == MBG_SUCCESS )
    {
      strcpy( dev_info->model_name, _pcps_type_name( &pdev ) );
      strcpy( dev_info->serial_number, _pcps_sernum( &pdev ) );
      sprintf( dev_info->hw_name, "%s_%s", _pcps_type_name( &pdev ), _pcps_sernum( &pdev ) );
    }

    mbg_close_device( &dh );
  }

}  // get_hw_name_from_hw_id

#endif



/*HDR*/
/**
    Return the number of supported devices installed on the system and 
    set up a list of unique names of those devices.

    This function should be used preferably instead of mbg_find_devices().

    @param device_list Pointer to a linked list of type ::MBG_DEVICENAME_LIST 
                       with device names. The list will be allocated by this 
                       function and has to be freed after usage by calling 
                       mbg_free_device_name_list().
    @param max_devices Maximum number of devices the function should look for 
                       (can not exceed ::MBG_MAX_DEVICES).

    @return Number of present devices

    @see ::MBG_HW_NAME for the format of the unique names
    @see mbg_free_device_name_list()
    @see mbg_find_devices()
  */
_MBG_API_ATTR int _MBG_API mbg_find_devices_with_names( MBG_DEVICENAME_LIST **device_list, 
                                                        int max_devices )
{
#if defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_UNIX )

  MBG_DEVICE_LIST *hardware_list = NULL;
  MBG_DEVICE_LIST *hardware_list_begin = NULL;
  MBG_DEVICENAME_LIST *ListBegin = NULL; 
  MBG_DEVICE_INFO dev_info;

  int n_devices = 0;
  int i = 0;

  n_devices = mbg_find_devices_with_hw_id( &hardware_list, max_devices );

  hardware_list_begin = hardware_list;

  if ( n_devices )
  {
    *device_list = (MBG_DEVICENAME_LIST *) malloc( sizeof( MBG_DEVICENAME_LIST ) );
    (*device_list)->next = NULL;

    // Save begin of the list
    ListBegin = *device_list;

    // Loop through the list of hardware_ids and get their readable names
    for (;;)
    {
      if ( hardware_list->device_path && i++ < MBG_MAX_DEVICES )
      {
        strcpy( dev_info.hardware_id, hardware_list->device_path );

        get_hw_name_from_hw_id( &dev_info );

        strcpy( (*device_list)->device_name, dev_info.hw_name );

        if ( hardware_list->next )
        {
          hardware_list = hardware_list->next;
          (*device_list)->next = (MBG_DEVICENAME_LIST *) malloc( sizeof( MBG_DEVICENAME_LIST ) );
          (*device_list) = (*device_list)->next;
          (*device_list)->next = NULL;
        }
        else
          break;
      }
      else
        break;
    }

    *device_list = ListBegin;
  }

  if ( hardware_list_begin )
    mbg_free_device_list( hardware_list_begin );

  return n_devices;

#else

  return 0;

#endif

}  // mbg_find_devices_with_names



/*HDR*/
/**
    Free the memory of the ::MBG_DEVICENAME_LIST that has been allocated before 
    by mbg_find_devices_with_names().

    @param *list Linked list of type ::MBG_DEVICENAME_LIST

    @see mbg_find_devices_with_names()
  */
_MBG_API_ATTR void _MBG_API mbg_free_device_name_list( MBG_DEVICENAME_LIST *list)
{
#if defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_UNIX )

  MBG_DEVICENAME_LIST *Next = NULL;
  int i = 0;

  // Deallocate members of linked list
  while ( i < MBG_MAX_DEVICES )
  {
    if ( list )
    {
      Next = list->next;

      free( list );
      list = NULL;

      if ( Next )
        list = Next->next;
      else
        break;
    }
    else
      break;

    i++;
  }

#endif

}  // mbg_free_device_list



/*HDR*/
/**
    Return a handle to a device with a certain unique name.
    The names of the devices that are installed on the system can be retrieved by
    the function mbg_find_devices_with_names().

    This function should be used preferably instead of mbg_open_device().

    @param hw_name String with the unique name of the device to be opened
    @param selection_mode One of the enum values of ::MBG_MATCH_MODE

    @return On success, the function returns a handle to the device, otherwise ::MBG_INVALID_DEV_HANDLE

    @see ::MBG_HW_NAME for the format of the unique names.
    @see ::MBG_MATCH_MODE
    @see mbg_find_devices_with_names()
  */
_MBG_API_ATTR MBG_DEV_HANDLE _MBG_API mbg_open_device_by_name( const char* hw_name, int selection_mode )  //##++++
{

#if ( defined( MBG_TGT_WIN32 ) || defined ( MBG_TGT_UNIX ) )

  MBG_DEV_HANDLE dh;

  MBG_DEVICE_LIST *devices = NULL;
  MBG_DEVICE_LIST *ListBegin = NULL;
  char hw_id[MAX_INFO_LEN];
  char tmp_model_name[PCPS_CLOCK_NAME_SZ];
  PCPS_SN_STR tmp_sn;
  int n_devices = 0;
  int i = 0;
  int j = 0;

  hw_id[0] = '\0';

  memset( tmp_model_name, 0, sizeof( tmp_model_name) );
  memset( device_info_list, 0, sizeof( device_info_list ) );
  memset( tmp_sn, 0, sizeof( tmp_sn ) );

  // separate hw_name into clock model and serial number 
  if ( hw_name && ( strlen( hw_name ) > 0 ) )
  {
    // clock model
    for ( i = 0; ( i < PCPS_CLOCK_NAME_SZ ) && ( hw_name[i] != '_' ) && ( (unsigned int) i < strlen( hw_name ) ); i++ )
      tmp_model_name[i] = hw_name[i];

    tmp_model_name[i] = 0;
    i++;

    // serial number
    if ( ( unsigned int ) i < strlen( hw_name ) )
    {
      j = 0;

      while( ( unsigned int ) i < strlen(hw_name) && j < PCPS_SN_SIZE )
      {
        tmp_sn[j] = hw_name[i];
        j++;
        i++;
      }
      tmp_sn[j] = '\0';
    }
  }
  else
    goto fail;

  i = 0;

  // get OS-dependent hardware_id strings for devices that are present on the system
  n_devices = mbg_find_devices_with_hw_id( &devices, MBG_MAX_DEVICES );

  ListBegin = devices;

  if ( n_devices )
  {
    for (;;)
    {
      if ( devices->device_path && i < MBG_MAX_DEVICES )
      {
        strncpy( device_info_list[i].hardware_id, devices->device_path, MAX_INFO_LEN );

        // get readable hw_name for the device
        get_hw_name_from_hw_id( &device_info_list[i] );

        if ( hw_name && device_info_list[i].hw_name && strcmp( device_info_list[i].hw_name, hw_name ) == 0 )  //##+++++
        {
          // The requested device was found
          strcpy( hw_id, device_info_list[i].hardware_id );
          break;
        }
        else if ( devices->next )
          devices = devices->next;
        else
          break;
      }
      else
        break;
      i++;
    }

    // If the requested CLOCK_MODEL/SN combination was not found,
    // decide what to do depending on the selection mode
    if ( ( hw_id[0] == '\0' ) && ( selection_mode != MBG_MATCH_EXACTLY ) )
    {
      for ( j = 0; j <= i; j++ )
      {
        // Search for the same clock model
        if ( ( tmp_model_name[0] != '\0' ) && strcmp( device_info_list[j].model_name, tmp_model_name ) == 0 )
        {
          strcpy( hw_id, device_info_list[j].hardware_id );
          break;
        }
      }

      // Finally select the first device found on the system, if the clock model was not found
      if ( ( selection_mode == MBG_MATCH_ANY ) && ( hw_id[0] == '\0' ) )
        strcpy( hw_id, device_info_list[0].hardware_id );
    }
  }

  mbg_free_device_list( ListBegin );

#endif

#if defined ( MBG_TGT_WIN32 )

  if ( hw_id[0] == '\0' )
    goto fail;

  dh = CreateFile( 
         hw_id,                         // file name
         GENERIC_READ | GENERIC_WRITE,  // access mode
         0,                             // share mode
         NULL,                          // security descriptor
         OPEN_EXISTING,                 // how to create
         strstr(hw_id,"usb") ? FILE_FLAG_OVERLAPPED : 0,          // file attributes
         NULL                           // handle to template file
       );

  if ( INVALID_HANDLE_VALUE == dh )
    goto fail;

  return dh;

fail:
  return MBG_INVALID_DEV_HANDLE;

#elif defined ( MBG_TGT_UNIX )

  if ( hw_id[0] != '\0' )
    dh = open( hw_id, O_RDWR );
  else
    goto fail;

  return ( dh < 0 ) ? MBG_INVALID_DEV_HANDLE : dh;

fail:
  return MBG_INVALID_DEV_HANDLE;

#else

  //return ( device_index < n_ddevs ) ? &pcps_ddev[device_index] : NULL;
  return MBG_INVALID_DEV_HANDLE;

#endif

} // mbg_open_device_by_name



/*HDR*/
/**
    Close a handle to a device and set the handle value to ::MBG_INVALID_DEV_HANDLE.
    If required, unmap mapped memory.

    @param dev_handle Handle to a Meinberg device.
  */
_MBG_API_ATTR void _MBG_API mbg_close_device( MBG_DEV_HANDLE *dev_handle )
{
  if ( *dev_handle != MBG_INVALID_DEV_HANDLE && *dev_handle != 0 )   //##++++ dev_handle NULL/0 ???
  {
    #if defined( MBG_TGT_WIN32 )
      CloseHandle( *dev_handle );
    #elif defined( MBG_TGT_UNIX )
      close( *dev_handle );
    #endif
  }

  *dev_handle = MBG_INVALID_DEV_HANDLE;

}  // mbg_close_device



/*HDR*/
/**
    Return a ::PCPS_DRVR_INFO structure that provides information 
    about the kernel device driver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_DRVR_INFO structure which is filled up.

    @return ::MBG_SUCCESS or error code returned by device I/O control function
  */
_MBG_API_ATTR int _MBG_API mbg_get_drvr_info( MBG_DEV_HANDLE dh, PCPS_DRVR_INFO *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_PCPS_DRVR_INFO, p );
    return _mbgdevio_ret_val;
  #else
    #if defined( __BORLANDC__ )
      dh;   // avoid warnings "never used"
    #endif
    drvr_info.n_devs = n_ddevs;
    *p = drvr_info;
    return MBG_SUCCESS;
  #endif

}  // mbg_get_drvr_info



/*HDR*/
/**
    Return a ::PCPS_DEV structure that provides detailed information about the device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_DEV structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function
  */
_MBG_API_ATTR int _MBG_API mbg_get_device_info( MBG_DEV_HANDLE dh, PCPS_DEV *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_PCPS_DEV, p );
    // Endianess is converted inside the kernel driver, if necessary.
    return _mbgdevio_ret_val;
  #else
    *p = dh->dev;
    return MBG_SUCCESS;
  #endif

}  // mbg_get_device_info



/*HDR*/
/**
    Return the current state of the on-board::PCPS_STATUS_PORT.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_STATUS_PORT value to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function

    @see \ref group_status_port "bitmask"
  */
_MBG_API_ATTR int _MBG_API mbg_get_status_port( MBG_DEV_HANDLE dh, PCPS_STATUS_PORT *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_PCPS_STATUS_PORT, p );
    // No endianess conversion required.
    return _mbgdevio_ret_val;
  #else
    *p = _pcps_ddev_read_status_port( dh );
    // No endianess conversion required.
    return MBG_SUCCESS;
  #endif

}  // mbg_get_status_port



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Generic read function which writes a command code to the device 
    and reads a number of replied data to a generic buffer.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any command code.

    @param dh Valid handle to a Meinberg device
    @param cmd Can be any \ref group_cmd_bytes "command byte" supported by the device
    @param *p Pointer to a buffer to be filled up
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_generic_write()
    @see mbg_generic_read_gps()
    @see mbg_generic_write_gps()
    @see mbg_generic_io()
  */
_MBG_API_ATTR int _MBG_API mbg_generic_read( MBG_DEV_HANDLE dh, int cmd,
                                             void *p, int size )
{
  _mbgdevio_vars();
  rc = _mbgdevio_gen_read( dh, cmd, p, size );
  // No type information available, so endianess must be 
  // converted by the caller, if required.
  return _mbgdevio_ret_val;

}  // mbg_generic_read



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Generic read function which writes a GPS command code to the device 
    and reads a number of replied data to a generic buffer.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any GPS command code.

    @param dh Valid handle to a Meinberg device
    @param cmd Can be any \ref group_cmd_bytes "command byte" supported by the device.
    @param *p Pointer to a buffer to be filled up
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_gps_data()
    @see mbg_generic_write_gps()
    @see mbg_generic_read()
    @see mbg_generic_write()
    @see mbg_generic_io()
  */
_MBG_API_ATTR int _MBG_API mbg_generic_read_gps( MBG_DEV_HANDLE dh, int cmd,
                                                 void *p, int size )
{
  _mbgdevio_vars();
  rc = _mbgdevio_gen_read_gps( dh, cmd, p, size );
  // No type information available, so endianess must be 
  // converted by the caller, if required.
  return _mbgdevio_ret_val;

}  // mbg_generic_read_gps



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Generic write function which writes a command code plus an 
    associated number of data bytes to the device.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any command code.

    @param dh   Valid handle to a Meinberg device
    @param cmd  Can be any \ref group_cmd_bytes "command byte" supported by the device.
    @param *p   Pointer to a buffer to be written
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_generic_read()
    @see mbg_generic_read_gps()
    @see mbg_generic_write_gps()
    @see mbg_generic_io()
  */
_MBG_API_ATTR int _MBG_API mbg_generic_write( MBG_DEV_HANDLE dh, int cmd,
                                              const void *p, int size )
{
  _mbgdevio_vars();
  // No type information available, so endianess must be 
  // converted by the caller, if required.
  rc = _mbgdevio_gen_write( dh, cmd, p, size );
  return _mbgdevio_ret_val;

}  // mbg_generic_write



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Generic write function which writes a GPS command code plus an 
    associated number of data bytes to the device.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any GPS command code.

    @param dh   Valid handle to a Meinberg device
    @param cmd  Can be any \ref group_cmd_bytes "command byte" supported by the device.
    @param *p   Pointer to a buffer to be written
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_gps_data()
    @see mbg_generic_read_gps()
    @see mbg_generic_read()
    @see mbg_generic_write()
    @see mbg_generic_io()
  */
_MBG_API_ATTR int _MBG_API mbg_generic_write_gps( MBG_DEV_HANDLE dh, int cmd,
                                                  const void *p, int size )
{
  _mbgdevio_vars();
  // No type information available, so endianess must be 
  // converted by the caller, if required.
  rc = _mbgdevio_gen_write_gps( dh, cmd, p, size );
  return _mbgdevio_ret_val;

}  // mbg_generic_write_gps



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Write and/or read generic data to/from a device.
    The macro _pcps_has_generic_io() or the API call mbg_dev_has_generic_io()
    check whether this call is supported by a specific card.

    <b>Warning</b>: This call is for debugging purposes and internal use only!

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_generic_io()
    @see mbg_generic_read()
    @see mbg_generic_write()
    @see mbg_generic_read_gps()
    @see mbg_generic_write_gps()
  */
_MBG_API_ATTR int _MBG_API mbg_generic_io( MBG_DEV_HANDLE dh, int type,
                                           const void *in_p, int in_sz,
                                           void *out_p, int out_sz )
{
  _mbgdevio_vars();

  #if !defined( _MBGIOCTL_H )
    // The hardware is accessed directly, so we must check
    // here if this call is supported.
    _mbgdevio_chk_cond( _pcps_ddev_has_generic_io( dh ) );
  #endif

  // No type information available, so endianess must be
  // converted by the caller, if required.
  rc = _mbgdevio_gen_io( dh, type, in_p, in_sz, out_p, out_sz );
  return _mbgdevio_ret_val;

}  // mbg_generic_io



/*HDR*/
/**
    Read a ::PCPS_TIME structure returning the current date/time/status.
    The returned time is local time according to the card's time zone setting, 
    with a resolution of 10 ms (i.e. 10ths of seconds).

    This call is supported by any device manufactured by Meinberg. However,
    for higher accuracy and resolution the mbg_get_hr_time..() group of calls 
    should be used preferably if supported by the specific device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time()
    @see mbg_set_time()
    @see mbg_get_sync_time()
  */
_MBG_API_ATTR int _MBG_API mbg_get_time( MBG_DEV_HANDLE dh, PCPS_TIME *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_var( dh, PCPS_GIVE_TIME, IOCTL_GET_PCPS_TIME, p );
  // No endianess conversion required.
  return _mbgdevio_ret_val;

}  // mbg_get_time



/*HDR*/
/**
    Set a device's on-board clock manually by passing a ::PCPS_STIME structure
    The macro _pcps_can_set_time() checks whether this call 
    is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_STIME structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time()
  */
_MBG_API_ATTR int _MBG_API mbg_set_time( MBG_DEV_HANDLE dh, const PCPS_STIME *p )
{
  _mbgdevio_vars();
  // No endianess conversion required.
  _mbgdevio_write_var_chk( dh, PCPS_SET_TIME, IOCTL_SET_PCPS_TIME, p,
                           _pcps_ddev_can_set_time( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_time



/*HDR*/
/**
    Read a ::PCPS_TIME structure returning the date/time/status reporting 
    when the device was synchronized the last time to its time source, 
    e.g. the DCF77 signal or the GPS satellites.
    The macro _pcps_has_sync_time() or the API call mbg_dev_has_sync_time() 
    check whether this call is supported by a specific card.

    The macro _pcps_has_sync_time() checks whether this call 
    is supported by a specific card.

    <b>Note:</b> If that information is not available on the board then 
    the value of the returned ::PCPS_TIME::sec field is set to 0xFF. 
    The macro _pcps_time_is_read() can be used to check whether the 
    returned information is valid, or not available.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time()
  */
_MBG_API_ATTR int _MBG_API mbg_get_sync_time( MBG_DEV_HANDLE dh, PCPS_TIME *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GIVE_SYNC_TIME, IOCTL_GET_PCPS_SYNC_TIME,
                          p, _pcps_ddev_has_sync_time( dh ) );
  // No endianess conversion required.
  return _mbgdevio_ret_val;

}  // mbg_get_sync_time



/*HDR*/
/**
    Wait until the next second change, then return a ::PCPS_TIME 
    structure similar to mbg_get_time().

    <b>Note:</b> This API call is supported under Windows only. 
    The call blocks until the kernel driver detects a second change 
    reported by the device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time()
  */
_MBG_API_ATTR int _MBG_API mbg_get_time_sec_change( MBG_DEV_HANDLE dh, PCPS_TIME *p )
{
  #if defined( MBG_TGT_WIN32 )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_PCPS_TIME_SEC_CHANGE, p );
    // No endianess conversion required.
    return _mbgdevio_ret_val;
  #else
    #if defined( __BORLANDC__ )
      dh; p;  // avoid warnings "never used"
    #endif
    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_ON_OS );
  #endif

}  // mbg_get_time_sec_change



/*HDR*/
/**
    Read a ::PCPS_HR_TIME (High Resolution time) structure returning 
    the current %UTC time (seconds since 1970), %UTC offset, and status.
    The macro _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() 
    check whether this call is supported by a specific card.

    <b>Note:</b> This API call provides a higher accuracy and resolution 
    than mbg_get_time(). However, it does not account for the latency 
    which is introduced when accessing the board. 
    The mbg_get_hr_time_cycles() and mbg_get_hr_time_comp() calls
    provides mechanisms to account for and/or compensate the latency.

    @param  dh  Valid handle to a Meinberg device
    @param  *p  Pointer to a ::PCPS_HR_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_hr_time()
    @see mbg_get_time()
    @see mbg_get_hr_time_cycles()
    @see mbg_get_hr_time_comp()
  */
_MBG_API_ATTR int _MBG_API mbg_get_hr_time( MBG_DEV_HANDLE dh, PCPS_HR_TIME *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GIVE_HR_TIME, IOCTL_GET_PCPS_HR_TIME,
                          p, _pcps_ddev_has_hr_time( dh ) );
  _mbg_swab_pcps_hr_time( p );
  return _mbgdevio_ret_val;

}  // mbg_get_hr_time



/*HDR*/
/* (Intentionally excluded from Doxygen )
    Write a high resolution time stamp ::PCPS_TIME_STAMP to the clock 
    to configure a %UTC time when the clock shall generate an event.
    The macro _pcps_has_event_time() or the API call mbg_dev_has_event_time() 
    check whether this call is supported by a specific card.

    <b>Note:</b> This is only supported by some special firmware.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_event_time()
  */
_MBG_API_ATTR int _MBG_API mbg_set_event_time( MBG_DEV_HANDLE dh, const PCPS_TIME_STAMP *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    PCPS_TIME_STAMP tmp = *p;
    _mbg_swab_pcps_time_stamp( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_var_chk( dh, PCPS_SET_EVENT_TIME, IOCTL_SET_PCPS_EVENT_TIME,
                           p, _pcps_ddev_has_event_time( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_event_time



/*HDR*/
/**
    Read the configuration of a device's serial port.
    The macro _pcps_has_serial() checks whether this call 
    is supported by a specific card.

    <b>Note:</b> This function is supported only by a certain class 
    of devices, so it should not be called directly. The generic 
    function mbg_get_serial_settings() should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_SERIAL structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see \ref group_cmd_bytes
    @see mbg_get_serial_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_serial( MBG_DEV_HANDLE dh, PCPS_SERIAL *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_var( dh, PCPS_GET_SERIAL, IOCTL_GET_PCPS_SERIAL, p );
  // No endianess conversion required.
  return _mbgdevio_ret_val;

}  // mbg_get_serial



/*HDR*/
/**
    Write the configuration of a device's serial port.
    The macro _pcps_has_serial() checks whether this call 
    is supported by a specific card.

    <b>Note:</b> This function is supported only by a certain class 
    of devices, so it should not be called directly. The generic 
    function mbg_save_serial_settings() should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_SERIAL structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see \ref group_cmd_bytes
    @see mbg_save_serial_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_set_serial( MBG_DEV_HANDLE dh, const PCPS_SERIAL *p )
{
  _mbgdevio_vars();
  // No endianess conversion required.
  rc = _mbgdevio_write_var( dh, PCPS_SET_SERIAL, IOCTL_SET_PCPS_SERIAL, p );
  return _mbgdevio_ret_val;

}  // mbg_set_serial



/*HDR*/
/**
    Read the card's time zone/daylight saving configuration code. 
    That tzcode is supported by some simpler cards and only allows only 
    a very basic configuration. 
    The macro _pcps_has_tzcode() or the API call mbg_dev_has_tzcode() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_get_pcps_tzdl() or mbg_get_gps_tzdl()
    calls instead which allow for a more detailed configuration of the 
    time zone and daylight saving settings.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZCODE structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzcode()
    @see mbg_set_tzcode()
    @see mbg_get_pcps_tzdl()
    @see mbg_get_gps_tzdl()
    @see \ref group_cmd_bytes
  */
_MBG_API_ATTR int _MBG_API mbg_get_tzcode( MBG_DEV_HANDLE dh, PCPS_TZCODE *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_TZCODE, IOCTL_GET_PCPS_TZCODE,
                          p, _pcps_ddev_has_tzcode( dh ) );
  // No endianess conversion required.
  return _mbgdevio_ret_val;

}  // mbg_get_tzcode



/*HDR*/
/**
    Write the card's time zone/daylight saving configuration code. 
    That tzcode is supported by some simpler cards and only allows only 
    a very basic configuration. 
    The macro _pcps_has_tzcode() or the API call mbg_dev_has_tzcode() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_set_pcps_tzdl() or mbg_set_gps_tzdl()
    calls instead which allow for a more detailed configuration of the 
    time zone and daylight saving settings.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZCODE structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzcode()
    @see mbg_get_tzcode()
    @see mbg_set_pcps_tzdl()
    @see mbg_set_gps_tzdl()
    @see \ref group_cmd_bytes
  */
_MBG_API_ATTR int _MBG_API mbg_set_tzcode( MBG_DEV_HANDLE dh, const PCPS_TZCODE *p )
{
  _mbgdevio_vars();
  // No endianess conversion required.
  _mbgdevio_write_var_chk( dh, PCPS_SET_TZCODE, IOCTL_SET_PCPS_TZCODE,
                           p, _pcps_ddev_has_tzcode( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_tzcode



/*HDR*/
/**
    Read the card's time zone/daylight saving parameters using the 
    ::PCPS_TZDL structure. 
    The macro _pcps_has_pcps_tzdl() or the API call mbg_dev_has_pcps_tzdl() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_get_tzcode() or mbg_get_gps_tzdl() 
    calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZDL structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pcps_tzdl()
    @see mbg_set_pcps_tzdl()
    @see mbg_get_tzcode()
    @see mbg_get_gps_tzdl()
    @see \ref group_cmd_bytes
  */
_MBG_API_ATTR int _MBG_API mbg_get_pcps_tzdl( MBG_DEV_HANDLE dh, PCPS_TZDL *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_PCPS_TZDL, IOCTL_GET_PCPS_TZDL,
                          p, _pcps_ddev_has_pcps_tzdl( dh ) );
  _mbg_swab_pcps_tzdl( p );
  return _mbgdevio_ret_val;

}  // mbg_get_pcps_tzdl



/*HDR*/
/**
    Write the card's time zone/daylight saving parameters using the 
    ::PCPS_TZDL structure. 
    The macro _pcps_has_pcps_tzdl() or the API call mbg_dev_has_pcps_tzdl() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_set_tzcode() or mbg_set_gps_tzdl() 
    calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZDL structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pcps_tzdl()
    @see mbg_get_pcps_tzdl()
    @see mbg_set_tzcode()
    @see mbg_set_gps_tzdl()
    @see \ref group_cmd_bytes
  */
_MBG_API_ATTR int _MBG_API mbg_set_pcps_tzdl( MBG_DEV_HANDLE dh, const PCPS_TZDL *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    PCPS_TZDL tmp = *p;
    _mbg_swab_pcps_tzdl( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_var_chk( dh, PCPS_SET_PCPS_TZDL, IOCTL_SET_PCPS_TZDL,
                           p, _pcps_ddev_has_pcps_tzdl( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_pcps_tzdl



/*HDR*/
/**
    Read the reference time offset from %UTC for clocks which can't determine 
    that offset automatically, e.g. from an IRIG input signal. 
    The macro _pcps_has_ref_offs() or the API call mbg_dev_has_ref_offs() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_REF_OFFS value to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ref_offs()
    @see mbg_set_ref_offs()
    @see ::PCPS_GET_REF_OFFS
  */
_MBG_API_ATTR int _MBG_API mbg_get_ref_offs( MBG_DEV_HANDLE dh, MBG_REF_OFFS *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_REF_OFFS, IOCTL_GET_REF_OFFS,
                          p, _pcps_ddev_has_ref_offs( dh ) );
  _mbg_swab_mbg_ref_offs( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ref_offs



/*HDR*/
/**
    Write the reference time offset from %UTC for clocks which can't determine 
    that offset automatically, e.g. from an IRIG input signal. 
    The macro _pcps_has_ref_offs() or the API call mbg_dev_has_ref_offs() 
    check whether this call is supported by a specific card.

    @param  dh  Valid handle to a Meinberg device
    @param  *p  Pointer to a ::MBG_REF_OFFS value to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ref_offs()
    @see mbg_get_ref_offs()
    @see ::PCPS_SET_REF_OFFS
  */
_MBG_API_ATTR int _MBG_API mbg_set_ref_offs( MBG_DEV_HANDLE dh, const MBG_REF_OFFS *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    MBG_REF_OFFS tmp = *p;
    _mbg_swab_mbg_ref_offs( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_var_chk( dh, PCPS_SET_REF_OFFS, IOCTL_SET_REF_OFFS,
                           p, _pcps_ddev_has_ref_offs( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_ref_offs



/*HDR*/
/**
    Read a ::MBG_OPT_INFO structure containing optional settings, controlled by flags.
    The ::MBG_OPT_INFO structure contains a mask of supported flags plus the current 
    settings of those flags.
    The macro _pcps_has_opt_flags() or the API call mbg_dev_has_opt_flags() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_OPT_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_opt_flags()
    @see mbg_set_opt_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_opt_info( MBG_DEV_HANDLE dh, MBG_OPT_INFO *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_OPT_INFO, IOCTL_GET_MBG_OPT_INFO,
                          p, _pcps_ddev_has_opt_flags( dh ) );
  _mbg_swab_mbg_opt_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_opt_info



/*HDR*/
/**
    Write a ::MBG_OPT_SETTINGS structure contains optional settings, controlled by flags.
    The macro _pcps_has_opt_flags() or the API call mbg_dev_has_opt_flags() 
    check whether this call is supported by a specific card.
    The ::MBG_OPT_INFO structure should be read first to check which of the specified 
    flags is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_OPT_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_opt_flags()
    @see mbg_get_opt_info()
  */
_MBG_API_ATTR int _MBG_API mbg_set_opt_settings( MBG_DEV_HANDLE dh, const MBG_OPT_SETTINGS *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    MBG_OPT_SETTINGS tmp = *p;
    _mbg_swab_mbg_opt_settings( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_var_chk( dh, PCPS_SET_OPT_SETTINGS,
                           IOCTL_SET_MBG_OPT_SETTINGS, p,
                           _pcps_ddev_has_opt_flags( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_opt_settings



/*HDR*/
/**
    Read an ::IRIG_INFO structure containing the configuration of an IRIG input
    plus the possible settings supported by that input.
    The macro _pcps_is_irig_rx() or the API call mbg_dev_is_irig_rx() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an ::IRIG_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_irig_rx_settings()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
  */
_MBG_API_ATTR int _MBG_API mbg_get_irig_rx_info( MBG_DEV_HANDLE dh, IRIG_INFO *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_IRIG_RX_INFO, IOCTL_GET_PCPS_IRIG_RX_INFO,
                          p, _pcps_ddev_is_irig_rx( dh ) );
  _mbg_swab_irig_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_irig_rx_info



/*HDR*/
/**
    Write an ::IRIG_SETTINGS structure containing the configuration of an IRIG input.
    The macro _pcps_is_irig_rx() or the API call mbg_dev_is_irig_rx() 
    check whether this call is supported by a specific card.
    The ::IRIG_INFO structure should be read first to determine the possible 
    settings supported by this card's IRIG input.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::IRIG_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_rx_info()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
  */
_MBG_API_ATTR int _MBG_API mbg_set_irig_rx_settings( MBG_DEV_HANDLE dh, const IRIG_SETTINGS *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    IRIG_SETTINGS tmp = *p;
    _mbg_swab_irig_settings( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_var_chk( dh, PCPS_SET_IRIG_RX_SETTINGS,
                           IOCTL_SET_PCPS_IRIG_RX_SETTINGS, p,
                           _pcps_ddev_is_irig_rx( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_irig_rx_settings



/*HDR*/
/**
    Check if a specific device supports the mbg_get_irig_ctrl_bits() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_ctrl_bits()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_irig_ctrl_bits( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_irig_ctrl_bits, IOCTL_DEV_HAS_IRIG_CTRL_BITS, p );

}  // mbg_dev_has_irig_ctrl_bits



/*HDR*/
/**
    Read a ::MBG_IRIG_CTRL_BITS type which contains the control function
    bits of the latest IRIG input frame. Those bits may carry some 
    well-known information, as in the IEEE1344 code, but may also contain 
    some customized information, depending on the IRIG frame type and 
    the configuration of the IRIG generator. So these bits are returned 
    as-is and must be interpreted by the application.
    The macro _pcps_has_irig_ctrl_bits() or the API call mbg_dev_has_irig_ctrl_bits()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_IRIG_CTRL_BITS type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_irig_ctrl_bits()
*/
_MBG_API_ATTR int _MBG_API mbg_get_irig_ctrl_bits( MBG_DEV_HANDLE dh,
                                                   MBG_IRIG_CTRL_BITS *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_var( dh, PCPS_GET_IRIG_CTRL_BITS, IOCTL_GET_IRIG_CTRL_BITS, p );
  _mbg_swab_irig_ctrl_bits( p );
  return _mbgdevio_ret_val;

}  // mbg_get_irig_ctrl_bits



/*HDR*/
/**
    Check if a specific device supports the mbg_get_raw_irig_data() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_raw_irig_data()
    @see mbg_get_raw_irig_data_on_sec_change()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_raw_irig_data( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_raw_irig_data, IOCTL_DEV_HAS_RAW_IRIG_DATA, p );

}  // mbg_dev_has_raw_irig_data



/*HDR*/
/**
    Read a ::MBG_RAW_IRIG_DATA type which contains all data
    bits of the latest IRIG input frame.
    The macro _pcps_has_raw_irig_data() or the API call mbg_dev_has_raw_irig_data()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_RAW_IRIG_DATA type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_raw_irig_data()
    @see mbg_get_raw_irig_data_on_sec_change()
*/
_MBG_API_ATTR int _MBG_API mbg_get_raw_irig_data( MBG_DEV_HANDLE dh,
                                                  MBG_RAW_IRIG_DATA *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_var( dh, PCPS_GET_RAW_IRIG_DATA, IOCTL_GET_RAW_IRIG_DATA, p );
  // No endianess conversion required.
  return _mbgdevio_ret_val;

}  // mbg_get_raw_irig_data



/*HDR*/
/**
    Read a ::MBG_RAW_IRIG_DATA type just after a second change which contains all data
    bits of the latest IRIG input frame.
    The macro _pcps_has_raw_irig_data() or the API call mbg_dev_has_raw_irig_data()
    check whether this call is supported by a specific card.

    <b>Note:</b> The mbg_get_time_sec_change() function called by this function is
    supported under Windows only, so this function can also only be used under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_RAW_IRIG_DATA type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_raw_irig_data()
    @see mbg_get_raw_irig_data()
*/
_MBG_API_ATTR int _MBG_API mbg_get_raw_irig_data_on_sec_change( MBG_DEV_HANDLE dh,
                                                                MBG_RAW_IRIG_DATA *p )
{
  PCPS_TIME t;
  _mbgdevio_vars();

   rc = mbg_get_time_sec_change( dh, &t );

   if ( rc == MBG_SUCCESS )
     rc = mbg_get_raw_irig_data( dh, p );

  return _mbgdevio_ret_val;

}  // mbg_get_raw_irig_data_on_sec_change



/*HDR*/
/**
    Check if a specific device supports the mbg_get_irig_time() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_time()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_irig_time( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_irig_time, IOCTL_DEV_HAS_IRIG_TIME, p );

}  // mbg_dev_has_irig_time



/*HDR*/
/**
    Read a ::PCPS_IRIG_TIME type which returns the raw IRIG day-of-year number
    and time decoded from the latest IRIG input frame. If the configured IRIG code
    also contains the year number then the year number is also returned, otherwise
    the returned year number is 0xFF.
    The macro _pcps_has_irig_time() or the API call mbg_dev_has_irig_time()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_IRIG_TIME type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_irig_time()
*/
_MBG_API_ATTR int _MBG_API mbg_get_irig_time( MBG_DEV_HANDLE dh,
                                              PCPS_IRIG_TIME *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_var( dh, PCPS_GIVE_IRIG_TIME, IOCTL_GET_IRIG_TIME, p );
  _mbg_swab_pcps_irig_time( p );
  return _mbgdevio_ret_val;

}  // mbg_get_irig_time



/*HDR*/
/**
    Clear the card's on-board time capture FIFO buffer.
    The macro _pcps_can_clr_ucap_buff() or the API call mbg_dev_can_clr_ucap_buff() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_can_clr_ucap_buff()
    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
  */
_MBG_API_ATTR int _MBG_API mbg_clr_ucap_buff( MBG_DEV_HANDLE dh )
{
  _mbgdevio_vars();
  _mbgdevio_write_cmd_chk( dh, PCPS_CLR_UCAP_BUFF, IOCTL_PCPS_CLR_UCAP_BUFF,
                           _pcps_ddev_can_clr_ucap_buff( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_clr_ucap_buff



/*HDR*/
/**
    Read a ::PCPS_UCAP_ENTRIES structure to retrieve the number of saved 
    user capture events and the maximum capture buffer size.
    The macro _pcps_has_ucap() or the API call mbg_dev_has_ucap() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_UCAP_ENTRIES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ucap()
    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
  */
_MBG_API_ATTR int _MBG_API mbg_get_ucap_entries( MBG_DEV_HANDLE dh, PCPS_UCAP_ENTRIES *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GIVE_UCAP_ENTRIES,
                          IOCTL_GET_PCPS_UCAP_ENTRIES, p,
                          _pcps_ddev_has_ucap( dh ) );
  _mbg_swab_pcps_ucap_entries( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ucap_entries



/*HDR*/
/**
    Retrieve a single time capture event from the on-board FIFO buffer 
    using a ::PCPS_HR_TIME structure. The oldest entry of the FIFO is retrieved 
    and then removed from the FIFO. 
    If no capture event is available in the FIFO buffer then both the seconds 
    and the fractions of the returned timestamp are 0.
    The macro _pcps_has_ucap() or the API call mbg_dev_has_ucap() 
    check whether this call is supported by a specific card.

    <b>Note:</b> This call is very much faster than the older mbg_get_gps_ucap()
    call which is obsolete but still supported for compatibility with 
    older cards.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_HR_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ucap()
    @see mbg_get_ucap_entries()
    @see mbg_clr_ucap_buff()
  */
_MBG_API_ATTR int _MBG_API mbg_get_ucap_event( MBG_DEV_HANDLE dh, PCPS_HR_TIME *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GIVE_UCAP_EVENT,
                          IOCTL_GET_PCPS_UCAP_EVENT, p,
                          _pcps_ddev_has_ucap( dh ) );
  _mbg_swab_pcps_hr_time( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ucap_event



/*HDR*/
/**
    Read the card's time zone/daylight saving parameters using the ::TZDL
    structure. 
    The macro _pcps_has_tzdl() or the API call mbg_dev_has_tzdl() 
    check whether this call is supported by a specific card.

    <b>Note:</b> In spite of the function name this call may also be 
    supported by non-GPS cards. Other cards may support the mbg_get_tzcode()
    or mbg_get_pcps_tzdl() calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TZDL structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzdl()
    @see mbg_set_gps_tzdl()
    @see mbg_get_tzcode()
    @see mbg_get_pcps_tzdl()
    @see \ref group_tzdl
  */
_MBG_API_ATTR int _MBG_API mbg_get_gps_tzdl( MBG_DEV_HANDLE dh, TZDL *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_TZDL, IOCTL_GET_GPS_TZDL, p );
  _mbg_swab_tzdl( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_tzdl



/*HDR*/
/**
    Write the card's time zone/daylight saving parameters using the ::TZDL
    structure. 
    The macro _pcps_has_tzdl() or the API call mbg_dev_has_tzdl() 
    check whether this call is supported by a specific card.

    <b>Note:</b> In spite of the function name this call may also be 
    supported by non-GPS cards. Other cards may support the mbg_set_tzcode() 
    or mbg_set_pcps_tzdl() calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TZDL structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzdl()
    @see mbg_get_gps_tzdl()
    @see mbg_set_tzcode()
    @see mbg_set_pcps_tzdl()
    @see \ref group_tzdl
  */
_MBG_API_ATTR int _MBG_API mbg_set_gps_tzdl( MBG_DEV_HANDLE dh, const TZDL *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    TZDL tmp = *p;
    _mbg_swab_tzdl( &tmp );
    p = &tmp;
  #endif
  rc = _mbgdevio_write_gps_var( dh, PC_GPS_TZDL, IOCTL_SET_GPS_TZDL, p );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_tzdl



/*HDR*/
/**
    Retrieve the software revision of a GPS receiver.
    This call is obsolete but still supported for compatibility 
    with older GPS cards.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> The function mbg_get_gps_receiver_info() should 
    be used instead, if supported by the card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SW_REV structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_is_gps()
    @see mbg_get_gps_receiver_info()
  */
_MBG_API_ATTR int _MBG_API mbg_get_gps_sw_rev( MBG_DEV_HANDLE dh, SW_REV *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_SW_REV, IOCTL_GET_GPS_SW_REV, p );
  _mbg_swab_sw_rev( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_sw_rev



/*HDR*/
/**
    Retrieve the status of the battery buffered GPS variables.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.
    The GPS receiver stays in cold boot mode until all of the 
    data sets are valid.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::BVAR_STAT structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_bvar_stat( MBG_DEV_HANDLE dh, BVAR_STAT *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_BVAR_STAT, IOCTL_GET_GPS_BVAR_STAT, p );
  _mbg_swab_bvar_stat( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_stat



/*HDR*/
/**
    Read the current board time using a ::TTM structure.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This call is pretty slow, so the mbg_get_hr_time_..() 
    group of calls should be used preferably.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TTM structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_time( MBG_DEV_HANDLE dh, TTM *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_TIME, IOCTL_GET_GPS_TIME, p );
  _mbg_swab_ttm( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_time



/*HDR*/
/**
    Write a ::TTM structure to a GPS receiver in order to set the 
    on-board date and time.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TTM structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_time( MBG_DEV_HANDLE dh, const TTM *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    TTM tmp = *p;
    _mbg_swab_ttm( &tmp );
    p = &tmp;
  #endif
  rc = _mbgdevio_write_gps_var( dh, PC_GPS_TIME, IOCTL_SET_GPS_TIME, p );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_time



/*HDR*/
/**
    Read a ::PORT_PARM structure to retrieve the configuration 
    of the device's serial ports.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This function is obsolete since it is only 
    supported by a certain class of devices and can handle only 
    up to 2 ports. The generic function mbg_get_serial_settings() 
    should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PORT_PARM structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_serial_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_port_parm( MBG_DEV_HANDLE dh, PORT_PARM *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_PORT_PARM, IOCTL_GET_GPS_PORT_PARM, p );
  _mbg_swab_port_parm( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_port_parm



/*HDR*/
/**
    Write a ::PORT_PARM structure to configure the on-board 
    serial ports.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This function is obsolete since it is only 
    supported by a certain class of devices and can handle only 
    up to 2 ports. The generic function mbg_save_serial_settings() 
    should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PORT_PARM structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_save_serial_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_port_parm( MBG_DEV_HANDLE dh, const PORT_PARM *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    PORT_PARM tmp = *p;
    _mbg_swab_port_parm( &tmp );
    p = &tmp;
  #endif
  rc = _mbgdevio_write_gps_var( dh, PC_GPS_PORT_PARM, IOCTL_SET_GPS_PORT_PARM, p );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_port_parm



/*HDR*/
/**
    Read an ::ANT_INFO structure to retrieve status information of the GPS antenna.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> Normally the antenna connection status can also be 
    determined by evaluation of the ::PCPS_TIME::signal or ::PCPS_HR_TIME::signal
    fields.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ANT_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_ant_info( MBG_DEV_HANDLE dh, ANT_INFO *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_ANT_INFO, IOCTL_GET_GPS_ANT_INFO, p );
  _mbg_swab_ant_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_ant_info



/*HDR*/
/**
    Read a time capture event from the on-board FIFO buffer using a ::TTM structure.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This call is pretty slow and has been obsoleted by 
    mbg_get_ucap_event() which should be used preferably, if supported 
    by the card. Anyway, this call is still supported for compatibility 
    with older cards.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TTM structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
    @see mbg_clr_ucap_buff()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_ucap( MBG_DEV_HANDLE dh, TTM *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_UCAP, IOCTL_GET_GPS_UCAP, p );
  _mbg_swab_ttm( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_ucap



/*HDR*/
/**
    Read an ::ENABLE_FLAGS structure reporting whether certain outputs 
    shall be enabled immediately after the card's power-up, or only 
    after the card has synchronized to its input signal.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Note:</b> Not all of the input signals specified for the 
    ::ENABLE_FLAGS structure can be modified individually.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::ENABLE_FLAGS structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ::ENABLE_FLAGS
    @see mbg_set_gps_enable_flags()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_enable_flags( MBG_DEV_HANDLE dh, ENABLE_FLAGS *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_ENABLE_FLAGS,
                          IOCTL_GET_GPS_ENABLE_FLAGS, p );
  _mbg_swab_enable_flags( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_enable_flags



/*HDR*/
/**
    Write an ENABLE_FLAGS structure to configure whether certain outputs 
    shall be enabled immediately after the card's power-up, or only 
    after the card has synchronized to its input signal.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Note:</b> Not all of the input signals specified for the 
    ENABLE_FLAGS structure can be modified individually.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ENABLE_FLAGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ENABLE_FLAGS
    @see mbg_get_gps_enable_flags()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_enable_flags( MBG_DEV_HANDLE dh,
                                       const ENABLE_FLAGS *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    ENABLE_FLAGS tmp = *p;
    _mbg_swab_enable_flags( &tmp );
    p = &tmp;
  #endif
  rc = _mbgdevio_write_gps_var( dh, PC_GPS_ENABLE_FLAGS,
                           IOCTL_SET_GPS_ENABLE_FLAGS, p );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_enable_flags



/*HDR*/
/**
    Read a ::STAT_INFO structure to retrieve the status of the 
    GPS receiver, including mode of operation and numer of 
    visible/usable satellites.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::STAT_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ::STAT_INFO
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_stat_info( MBG_DEV_HANDLE dh, STAT_INFO *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_STAT_INFO, IOCTL_GET_GPS_STAT_INFO, p );
  _mbg_swab_stat_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_stat_info



/*HDR*/
/**
    Sends a ::GPS_CMD to a GPS receiver.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::GPS_CMD

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ::PC_GPS_CMD_BOOT, ::PC_GPS_CMD_INIT_SYS, ::PC_GPS_CMD_INIT_USER, ::PC_GPS_CMD_INIT_DAC
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_cmd( MBG_DEV_HANDLE dh, const GPS_CMD *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    GPS_CMD tmp = *p;
    _mbg_swab_gps_cmd( &tmp );
    p = &tmp;
  #endif
  rc = _mbgdevio_write_gps_var( dh, PC_GPS_CMD, IOCTL_SET_GPS_CMD, p );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_cmd


/*HDR*/
/**
    Read the current GPS receiver position using the ::POS structure 
    which contains different coordinate formats.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::POS structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pos_xyz()
    @see mbg_set_gps_pos_lla()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_pos( MBG_DEV_HANDLE dh, POS *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_gps_var( dh, PC_GPS_POS, IOCTL_GET_GPS_POS, p );
  swap_pos_doubles( p );
  _mbg_swab_pos( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_pos



/*HDR*/
/**
    Preset the GPS receiver position using ::XYZ coordinates 
    (ECEF: WGS84 "Earth Centered, Earth fixed" kartesian coordinates).
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param p Position in ::XYZ format to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pos_lla()
    @see mbg_get_gps_pos()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_pos_xyz( MBG_DEV_HANDLE dh, const XYZ p )
{
  _mbgdevio_vars();
  XYZ xyz;
  int i;

  for ( i = 0; i < N_XYZ; i++ )
  {
    xyz[i] = p[i];
    swap_double( &xyz[i] );
    _mbg_swab_double( &xyz[i] );
  }

  rc = _mbgdevio_write_gps_var( dh, PC_GPS_POS_XYZ, IOCTL_SET_GPS_POS_XYZ, xyz );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_pos_xyz



/*HDR*/
/**
    Preset the GPS receiver position using ::LLA coordinates 
    (longitude, latitude, altitude)
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param p Position in ::LLA format to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pos_xyz()
    @see mbg_get_gps_pos()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_pos_lla( MBG_DEV_HANDLE dh, const LLA p )
{
  _mbgdevio_vars();
  LLA lla;
  int i;

  for ( i = 0; i < N_LLA; i++ )
  {
    lla[i] = p[i];
    swap_double( &lla[i] );
    _mbg_swab_double( &lla[i] );
  }

  rc = _mbgdevio_write_gps_var( dh, PC_GPS_POS_LLA, IOCTL_SET_GPS_POS_LLA, lla );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_pos_lla



/*HDR*/
/**
    Read the configured length of the GPS antenna cable (::ANT_CABLE_LEN).
    The cable delay is internally compensated by 5ns per meter cable.
    The macro _pcps_has_cab_len() or the API call mbg_dev_has_cab_len()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::ANT_CABLE_LEN structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_cab_len()
    @see mbg_set_gps_ant_cable_len()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_ant_cable_len( MBG_DEV_HANDLE dh, ANT_CABLE_LEN *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_ANT_CABLE_LEN,
                              IOCTL_GET_GPS_ANT_CABLE_LEN, p,
                              _pcps_ddev_has_cab_len( dh ) );
  _mbg_swab_ant_cable_len( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_ant_cable_len



/*HDR*/
/**
    Write the length of the GPS antenna cable (::ANT_CABLE_LEN).
    The cable delay is internally compensated by 5ns per meter cable.
    The macro _pcps_has_cab_len() or the API call mbg_dev_has_cab_len()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::ANT_CABLE_LEN structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_cab_len()
    @see mbg_get_gps_ant_cable_len()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_ant_cable_len( MBG_DEV_HANDLE dh,
                                                      const ANT_CABLE_LEN *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    ANT_CABLE_LEN tmp = *p;
    _mbg_swab_ant_cable_len( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_ANT_CABLE_LEN,
                               IOCTL_SET_GPS_ANT_CABLE_LEN, p,
                               _pcps_ddev_has_cab_len( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_ant_cable_len



/*HDR*/
/**
    Read a ::RECEIVER_INFO structure from a card.
    The macro _pcps_has_receiver_info() or the API call mbg_dev_has_receiver_info()
    check whether this call is supported by a specific card.

    <b>Note:</b> Applications should call mbg_setup_receiver_info() 
    preferably, which also sets up a basic ::RECEIVER_INFO structure 
    for card which don't provide that structure by themselves.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::RECEIVER_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_setup_receiver_info()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_receiver_info( MBG_DEV_HANDLE dh, RECEIVER_INFO *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_RECEIVER_INFO,
                              IOCTL_GET_GPS_RECEIVER_INFO, p,
                              _pcps_ddev_has_receiver_info( dh ) );

  _mbg_swab_receiver_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_gps_receiver_info



#if !MBGDEVIO_SIMPLE

/*HDR*/
/**
    Read a ::STR_TYPE_INFO_IDX array of supported string types.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.

    <b>Note:</b> The function mbg_get_serial_settings() should be used preferably
    to get retrieve the current port settings and configuration options.

    @param dh Valid handle to a Meinberg device.
    @param stii Pointer to a an array of string type information to be filled up
    @param *p_ri Pointer to a ::RECEIVER_INFO structure returned by mbg_setup_receiver_info()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_setup_receiver_info()
    @see mbg_get_gps_all_port_info()
    @see mbg_get_serial_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_all_str_type_info( MBG_DEV_HANDLE dh,
                                                          STR_TYPE_INFO_IDX stii[],
                                                          const RECEIVER_INFO *p_ri )
{
  _mbgdevio_vars();

  #if _MBG_SUPP_VAR_ACC_SIZE
    _mbgdevio_read_gps_chk( dh, PC_GPS_ALL_STR_TYPE_INFO,
                            IOCTL_GET_GPS_ALL_STR_TYPE_INFO, stii,
                            p_ri->n_str_type * sizeof( stii[0] ),
                            _pcps_ddev_has_receiver_info( dh ) );
  #else
    // We check the model_code to see whether the receiver info
    // has been read from a device which really supports it, or
    // a dummy structure has been setup.
    if ( p_ri && ( p_ri->model_code != GPS_MODEL_UNKNOWN ) )
      rc = _mbgdevio_gen_read_gps( dh, PC_GPS_ALL_STR_TYPE_INFO, stii,
                                   p_ri->n_str_type * sizeof( stii[0] ) );
    else
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV );
  #endif

  #if defined( MBG_ARCH_BIG_ENDIAN )
    if ( rc == MBG_SUCCESS )
    {
      int i;
      for ( i = 0; i < p_ri->n_str_type; i++ )
      {
        STR_TYPE_INFO_IDX *p = &stii[i];
        _mbg_swab_str_type_info_idx( p );
      }
    }
  #endif

  return _mbgdevio_ret_val;

}  // mbg_get_gps_all_str_type_info



/*HDR*/
/**
    Read a ::PORT_INFO_IDX array of supported serial port configurations.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.

    <b>Note:</b> The function mbg_get_serial_settings() should be used preferably
    to get retrieve the current port settings and configuration options.

    @param dh Valid handle to a Meinberg device.
    @param pii Pointer to a an array of port configuration information to be filled up
    @param *p_ri Pointer to a ::RECEIVER_INFO structure returned by mbg_setup_receiver_info()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_setup_receiver_info()
    @see mbg_get_gps_all_str_type_info()
    @see mbg_get_serial_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_all_port_info( MBG_DEV_HANDLE dh,
                                                      PORT_INFO_IDX pii[],
                                                      const RECEIVER_INFO *p_ri )
{
  _mbgdevio_vars();

  #if _MBG_SUPP_VAR_ACC_SIZE
    _mbgdevio_read_gps_chk( dh, PC_GPS_ALL_PORT_INFO,
                            IOCTL_GET_GPS_ALL_PORT_INFO, pii,
                            p_ri->n_com_ports * sizeof( pii[0] ),
                            _pcps_ddev_has_receiver_info( dh ) );
  #else
    // We check the model_code to see whether the receiver info
    // has been read from a device which really supports it, or
    // a dummy structure has been set up.
    if ( p_ri && ( p_ri->model_code != GPS_MODEL_UNKNOWN ) )
      rc = _mbgdevio_gen_read_gps( dh, PC_GPS_ALL_PORT_INFO, pii,
                                   p_ri->n_com_ports * sizeof( pii[0] ) );
    else
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV );
  #endif

  #if defined( MBG_ARCH_BIG_ENDIAN )
    if ( rc == MBG_SUCCESS )
    {
      int i;
      for ( i = 0; i < p_ri->n_com_ports; i++ )
      {
        PORT_INFO_IDX *p = &pii[i];
        _mbg_swab_port_info_idx( p );
      }
    }
  #endif

  return _mbgdevio_ret_val;

}  // mbg_get_gps_all_port_info



/*HDR*/
/**
    Write the configuration for a single serial port using the ::PORT_SETTINGS_IDX
    structure which contains both the ::PORT_SETTINGS and the port index value.
    Except for the parameter types, this call is equivalent to mbg_set_gps_port_settings().
    The macro _pcps_has_receiver_info() or the API call mbg_dev_has_receiver_info()
    check whether this call is supported by a specific card.

    <b>Note:</b> The function mbg_save_serial_settings() should be used preferably 
    to write new port configuration to the board.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::PORT_SETTINGS_IDX structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_save_serial_settings()
    @see mbg_set_gps_port_settings()
    @see mbg_dev_has_receiver_info()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_port_settings_idx( MBG_DEV_HANDLE dh,
                                                          const PORT_SETTINGS_IDX *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    PORT_SETTINGS_IDX tmp = *p;
    _mbg_swab_port_settings_idx( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_PORT_SETTINGS_IDX,
                               IOCTL_SET_GPS_PORT_SETTINGS_IDX, p,
                               _pcps_ddev_has_receiver_info( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_port_settings_idx



/*HDR*/
/**
    Write the configuration for a single serial port using the ::PORT_SETTINGS 
    structure plus the port index.
    Except for the parameter types, this call is equivalent to mbg_set_gps_port_settings_idx().
    The macro _pcps_has_receiver_info() or the API call mbg_dev_has_receiver_info()
    check whether this call is supported by a specific card.

    <b>Note:</b> The function mbg_save_serial_settings() should be used preferably 
    to write new port configuration to the board.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::PORT_SETTINGS structure to be filled up
    @param idx Index of the serial port to be configured (starting from 0 ).

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_save_serial_settings()
    @see mbg_set_gps_port_settings_idx()
    @see mbg_dev_has_receiver_info()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_port_settings( MBG_DEV_HANDLE dh,
                                                      const PORT_SETTINGS *p, int idx )
{
  PORT_SETTINGS_IDX psi = { 0 };

  psi.idx = idx;
  psi.port_settings = *p;
  _mbg_swab_port_settings_idx( &psi );

  return mbg_set_gps_port_settings_idx( dh, &psi );

}  // mbg_set_gps_port_settings

#endif  // !MBGDEVIO_SIMPLE



/*HDR*/
/**
    Set up a ::RECEIVER_INFO structure for a device.
    If the device supports the ::RECEIVER_INFO structure then the structure
    is read from the device, otherwise a structure is set up using 
    default values depending on the device type.
    The function mbg_get_device_info() must have been called before, 
    and the returned PCPS_DEV structure passed to this function.

    @param dh Valid handle to a Meinberg device.
    @param *pdev Pointer to a ::PCPS_DEV structure returned by mbg_get_device_info()
    @param *p Pointer to a ::RECEIVER_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_device_info()
    @see mbg_dev_has_receiver_info()
*/
_MBG_API_ATTR int _MBG_API mbg_setup_receiver_info( MBG_DEV_HANDLE dh,
                                                    const PCPS_DEV *pdev,
                                                    RECEIVER_INFO *p )
{
  // If the clock supports the receiver_info structure then
  // read it from the clock, otherwise set up some default
  // values depending on the clock type.
  if ( _pcps_has_receiver_info( pdev ) )
  {
    int rc = mbg_get_gps_receiver_info( dh, p );

    if ( rc != MBG_SUCCESS )
      return rc;

    goto check;
  }

  if ( _pcps_is_gps( pdev ) )
    _setup_default_receiver_info_gps( p );
  else
    _setup_default_receiver_info_dcf( p, pdev );

check:
  // Make sure this program supports at least as many ports as
  // the current clock device.
  if ( p->n_com_ports > MAX_PARM_PORT )
    return _mbg_err_to_os( MBG_ERR_N_COM_EXCEEDS_SUPP );

  // Make sure this program supports at least as many string types
  // as the current clock device.
  if ( p->n_str_type > MAX_PARM_STR_TYPE )
    return _mbg_err_to_os( MBG_ERR_N_STR_EXCEEDS_SUPP );


  return MBG_SUCCESS;

}  // mbg_setup_receiver_info



/*HDR*/
/**
    Read the version code of the on-board PCI/PCIe interface ASIC.
    The macro _pcps_has_asic_version() or the API call mbg_dev_has_asic_version()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCI_ASIC_VERSION type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function

    @see mbg_dev_has_asic_version()
*/
_MBG_API_ATTR int _MBG_API mbg_get_asic_version( MBG_DEV_HANDLE dh, PCI_ASIC_VERSION *p )
{

  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_PCI_ASIC_VERSION, p );
    return _mbgdevio_ret_val;
  #else
    if ( !_pcps_ddev_has_asic_version( dh ) )
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV );

    *p = _mbg_inp32_to_cpu( dh, 0, _pcps_ddev_io_base_mapped( dh, 0 )
             + offsetof( PCI_ASIC, raw_version ) );

    return MBG_SUCCESS;
  #endif

}  // mbg_get_asic_version



/*HDR*/
/**
    Read the features of the on-board PCI/PCIe interface ASIC.
    The macro _pcps_has_asic_features() or the API call mbg_dev_has_asic_features()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::PCI_ASIC_FEATURES type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_asic_features()
*/
_MBG_API_ATTR int _MBG_API mbg_get_asic_features( MBG_DEV_HANDLE dh,
                                                  PCI_ASIC_FEATURES *p )
{

  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_PCI_ASIC_FEATURES, p );
    return _mbgdevio_ret_val;
  #else
    if ( !_pcps_ddev_has_asic_features( dh ) )
    {
      *p = 0;
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV );
    }

    *p = _mbg_inp32_to_cpu( dh, 0, _pcps_ddev_io_base_mapped( dh, 0 )
             + offsetof( PCI_ASIC, features ) );

    return MBG_SUCCESS;
  #endif

}  // mbg_get_asic_features



/*HDR*/
/**
    Check if a specific device supports configurable time scales.

    By default the cards return UTC and/or local time. However, some cards 
    can be configured to return pure GPS time or TAI instead.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time_scale_info()
    @see mbg_set_time_scale_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_time_scale( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_time_scale, IOCTL_DEV_HAS_GPS_TIME_SCALE, p );

}  // mbg_dev_has_time_scale



/*HDR*/
/**
    Read a ::MBG_TIME_SCALE_INFO structure from a card telling which time scales
    are supported by a card, and the current settings of the card.

    The macro _pcps_has_time_scale() or the API call mbg_dev_has_time_scale()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_time_scale().

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_SCALE_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_time_scale_settings()
    @see mbg_dev_has_time_scale()
*/
_MBG_API_ATTR int _MBG_API mbg_get_time_scale_info( MBG_DEV_HANDLE dh, MBG_TIME_SCALE_INFO *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_TIME_SCALE,
                              IOCTL_GET_GPS_TIME_SCALE_INFO, p,
                              _pcps_ddev_has_time_scale( dh ) );
  _mbg_swab_mbg_time_scale_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_time_scale_info



/*HDR*/
/**
    Write a ::MBG_TIME_SCALE_SETTINGS structure to a card which determines 
    which time scale shall be represented by time stamps read from the card. 

    The macro _pcps_has_time_scale() or the API call mbg_dev_has_time_scale()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_time_scale().

    The function mbg_get_time_scale_info() should have been called before 
    in order to determine which time scales are supported by the card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_SCALE_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time_scale_info()
    @see mbg_dev_has_time_scale()
*/
_MBG_API_ATTR int _MBG_API mbg_set_time_scale_settings( MBG_DEV_HANDLE dh, MBG_TIME_SCALE_SETTINGS *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    MBG_TIME_SCALE_SETTINGS tmp = *p;
    _mbg_swab_mbg_time_scale_settings( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_TIME_SCALE,
                               IOCTL_SET_GPS_TIME_SCALE_SETTINGS, p,
                               _pcps_ddev_has_time_scale( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_time_scale_settings



/*HDR*/
/**
    Check if a specific device supports reading/writing a GPS UTC parameter
    set via the PC bus (reading/writing these parameters via the serial port
    is supported by all GPS devices).

    The UTC parameters are normally received from the satellites' broadcasts
    and contain the current time offset between GPT time and UTC, plus information
    on a pending leap second.

    It may be useful to overwrite them to do some tests, or for applications 
    where a card is freewheeling.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_utc_parm()
    @see mbg_set_utc_parm()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_utc_parm( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_utc_parm, IOCTL_DEV_HAS_GPS_UTC_PARM, p );

}  // mbg_dev_has_utc_parm



/*HDR*/
/**
    Read a ::UTC structure from a card.

    The macro _pcps_has_utc_parm() or the API call mbg_dev_has_utc_parm()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_utc_parm().

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::UTC structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_utc_parm()
    @see mbg_set_utc_parm()
*/
_MBG_API_ATTR int _MBG_API mbg_get_utc_parm( MBG_DEV_HANDLE dh, UTC *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_UTC,
                              IOCTL_GET_GPS_UTC_PARM, p,
                              _pcps_ddev_has_utc_parm( dh ) );
  _mbg_swab_utc_parm( p );
  swap_double( &p->A0 );
  swap_double( &p->A1 );
  return _mbgdevio_ret_val;

}  // mbg_get_utc_parm



/*HDR*/
/**
    Write a ::UTC structure to a card.

    This should only be done for testing, or if a card is operated in 
    freewheeling mode. If the card receives any satellites the settings 
    written to the board are overwritten by the parameters broadcasted
    by the satellites.

    The macro _pcps_has_utc_parm() or the API call mbg_dev_has_utc_parm()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_utc_parm().

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a valid ::UTC structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_utc_parm()
    @see mbg_get_utc_parm()
*/
_MBG_API_ATTR int _MBG_API mbg_set_utc_parm( MBG_DEV_HANDLE dh, UTC *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    UTC tmp = *p;
    _mbg_swab_utc_parm( &tmp );
    p = &tmp;
  #endif
  swap_double( &p->A0 );
  swap_double( &p->A1 );
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_UTC,
                               IOCTL_SET_GPS_UTC_PARM, p,
                               _pcps_ddev_has_utc_parm( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_utc_parm



/*HDR*/
/**
    Read a ::PCPS_TIME_CYCLES structure that contains a ::PCPS_TIME structure
    and a PC cycle counter value which can be used to compensate the latency
    of the call, i.e. the program execution time until the time stamp has actually
    been read from the board.

    This call is supported for any card, similar to mbg_get_time(). However, 
    the mbg_get_hr_time_cyles() call should be used preferably if supported by 
    the specific card since that call provides much better accuracy than this one.

    The cycle counter value corresponds to a value returned by QueryPerformanceCounter() 
    under Windows, and get_cycles() under Linux. On other operating systems the returned 
    cycles value is always 0.

    Applications should first pick up their own cycle counter value and then call 
    this function. The difference of the cycle counter values corresponds to the 
    latency of the call in units of the cycle counter clock frequency, e.g as reported 
    by QueryPerformanceFrequency() under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_CYCLES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time_cycles()
    @see mbg_get_hr_time_comp()
    @see mbg_get_hr_time()
    @see mbg_get_time()
*/
_MBG_API_ATTR int _MBG_API mbg_get_time_cycles( MBG_DEV_HANDLE dh, PCPS_TIME_CYCLES *p )
{
  _mbgdevio_vars();
  rc = _mbgdevio_read_var( dh, PCPS_GIVE_TIME, IOCTL_GET_PCPS_TIME_CYCLES, p );
  // No endianess conversion required.
  #if !defined( _MBGIOCTL_H )
    // only if not using IOCTLs
    // for PCPS_TIME, read stamp AFTER the call
    p->cycles = 0;  //##++
  #endif
  return _mbgdevio_ret_val;

}  // mbg_get_time_cycles



/*HDR*/
/**
    Read a ::PCPS_HR_TIME_CYCLES structure that contains a ::PCPS_HR_TIME structure
    and a PC cycle counter value which can be used to compensate the latency
    of the call, i.e. the program execution time until the time stamp has actually
    been read from the board.

    The macro _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() 
    check whether this call is supported by a specific card.

    The cycle counter value corresponds to a value returned by QueryPerformanceCounter() 
    under Windows, and get_cycles() under Linux. On other operating systems the returned 
    cycles value is always 0.

    Applications should first pick up their own cycle counter value and then call 
    this function. The difference of the cycle counter values corresponds to the 
    latency of the call in units of the cycle counter clock frequency, e.g as reported 
    by QueryPerformanceFrequency() under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_HR_TIME_CYCLES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time_comp()
    @see mbg_get_hr_time()
    @see mbg_get_time_cycles()
    @see mbg_get_time()
*/
_MBG_API_ATTR int _MBG_API mbg_get_hr_time_cycles( MBG_DEV_HANDLE dh,
                                                   PCPS_HR_TIME_CYCLES *p )
{
  _mbgdevio_vars();
  #if !defined( _MBGIOCTL_H )
    // only if not using IOCTLs
    // for PCPS_HR_TIME, read stamp BEFORE the call
    p->cycles = 0;  //##++
  #endif
  _mbgdevio_read_var_chk( dh, PCPS_GIVE_HR_TIME,
                          IOCTL_GET_PCPS_HR_TIME_CYCLES,
                          p, _pcps_ddev_has_hr_time( dh ) );
  _mbg_swab_pcps_hr_time_cycles( p );
  return _mbgdevio_ret_val;

}  // mbg_get_hr_time_cycles



/*HDR*/
/**
    Read a ::PCPS_HR_TIME structure plus cycle counter value, and correct the 
    time stamp for the latency of the call as described for mbg_get_hr_time_cycles(),
    then return the compensated time stamp and optionally the latency.

    The macro _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() 
    check whether this call is supported by a specific card.

    The cycle counter value corresponds to a value returned by QueryPerformanceCounter() 
    under Windows, and get_cycles() under Linux. On other operating systems the returned 
    cycles value is always 0.

    Applications should first pick up their own cycle counter value and then call 
    this function. The difference of the cycle counter values corresponds to the 
    latency of the call in units of the cycle counter clock frequency, e.g as reported 
    by QueryPerformanceFrequency() under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_HR_TIME structure to be filled up
    @param *hns_latency Optional pointer to an int32_t value to return 
              the latency in 100ns units. Pass NULL if not used.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time_comp()
    @see mbg_get_hr_time()
    @see mbg_get_time_cycles()
    @see mbg_get_time()
*/
_MBG_API_ATTR int _MBG_API mbg_get_hr_time_comp( MBG_DEV_HANDLE dh, PCPS_HR_TIME *p,
                                                 int32_t *hns_latency )
{
  PCPS_HR_TIME_CYCLES htc;
  MBG_PC_CYCLES cyc_now;
  int rc;

  // First get current time stamp counter value, then read
  // a high resolution time stamp from the board, plus the
  // associated time stamp counter value.
  mbg_get_pc_cycles( &cyc_now );

  rc = mbg_get_hr_time_cycles( dh, &htc );

  if ( rc == MBG_SUCCESS )
  {
    mbg_init_pc_cycles_frequency( dh, &pc_cycles_frequency );
    rc = mbg_comp_hr_latency( &htc.t.tstamp, &htc.cycles, &cyc_now, &pc_cycles_frequency, hns_latency );
    *p = htc.t;
  }

  return rc;

}  // mbg_get_hr_time_comp



/*HDR*/
/**
    Read an ::IRIG_INFO structure containing the configuration of an IRIG output
    plus the possible settings supported by that output.
    The macro _pcps_has_irig_tx() or the API call mbg_dev_has_irig_tx() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an ::IRIG_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_irig_tx_settings()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
*/
_MBG_API_ATTR int _MBG_API mbg_get_irig_tx_info( MBG_DEV_HANDLE dh, IRIG_INFO *p )
{
  _mbgdevio_vars();

  #if !defined( _MBGIOCTL_H )
    // This is a workaround for GPS169PCIs with early
    // firmware versions. See RCS log for details.
    uint8_t pcps_cmd = PCPS_GET_IRIG_TX_INFO;

    if ( _pcps_ddev_requires_irig_workaround( dh ) )
      pcps_cmd = PCPS_GET_IRIG_RX_INFO;

    #define _PCPS_CMD   pcps_cmd
  #else
    #define _PCPS_CMD   PCPS_GET_IRIG_TX_INFO
  #endif

  _mbgdevio_read_var_chk( dh, _PCPS_CMD, IOCTL_GET_PCPS_IRIG_TX_INFO,
                          p, _pcps_ddev_has_irig_tx( dh ) );
  #undef _PCPS_CMD

  _mbg_swab_irig_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_irig_tx_info



/*HDR*/
/**
    Write an ::IRIG_SETTINGS structure containing the configuration of an IRIG output.
    The macro _pcps_has_irig_tx() or the API call mbg_dev_has_irig_tx() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an ::IRIG_INFO structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_tx_info()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
*/
_MBG_API_ATTR int _MBG_API mbg_set_irig_tx_settings( MBG_DEV_HANDLE dh, const IRIG_SETTINGS *p )
{
  _mbgdevio_vars();
  #if !defined( _MBGIOCTL_H )
    uint8_t pcps_cmd;
  #endif

  #if defined( MBG_ARCH_BIG_ENDIAN )
    IRIG_SETTINGS tmp = *p;
    _mbg_swab_irig_settings( &tmp );
    p = &tmp;
  #endif

  #if !defined( _MBGIOCTL_H )
    // This is a workaround for GPS169PCIs with early
    // firmware versions. See RCS log for details.
    pcps_cmd = PCPS_SET_IRIG_TX_SETTINGS;

    if ( _pcps_ddev_requires_irig_workaround( dh ) )
      pcps_cmd = PCPS_SET_IRIG_RX_SETTINGS;

    #define _PCPS_CMD   pcps_cmd
  #else
    #define _PCPS_CMD   PCPS_SET_IRIG_TX_SETTINGS
  #endif

  _mbgdevio_write_var_chk( dh, _PCPS_CMD, IOCTL_SET_PCPS_IRIG_TX_SETTINGS,
                           p, _pcps_ddev_has_irig_tx( dh ) );
  #undef _PCPS_CMD

  return _mbgdevio_ret_val;

}  // mbg_set_irig_tx_settings



/*HDR*/
/**
    Read a ::SYNTH structure containing the configuration of an optional 
    on-board programmable frequency synthesizer.
    The macro _pcps_has_synth() or the API call mbg_dev_has_synth() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SYNTH structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_synth()
    @see mbg_set_synth()
    @see mbg_get_synth_state()
    @see \ref group_synth
*/
_MBG_API_ATTR int _MBG_API mbg_get_synth( MBG_DEV_HANDLE dh, SYNTH *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_SYNTH, IOCTL_GET_SYNTH,
                          p, _pcps_ddev_has_synth( dh ) );
  _mbg_swab_synth( p );
  return _mbgdevio_ret_val;

}  // mbg_get_synth



/*HDR*/
/**
    Write a ::SYNTH structure containing the configuration of an optional 
    on-board programmable frequency synthesizer.
    The macro _pcps_has_synth() or the API call mbg_dev_has_synth() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SYNTH structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_synth()
    @see mbg_get_synth()
    @see mbg_get_synth_state()
    @see \ref group_synth
*/
_MBG_API_ATTR int _MBG_API mbg_set_synth( MBG_DEV_HANDLE dh, const SYNTH *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    SYNTH tmp = *p;
    _mbg_swab_synth( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_var_chk( dh, PCPS_SET_SYNTH, IOCTL_SET_SYNTH, 
                           p, _pcps_ddev_has_synth( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_synth



/*HDR*/
/**
    Read a ::SYNTH_STATE structure reporting the current state 
    of an optional on-board programmable frequency synthesizer.
    The macro _pcps_has_synth() or the API call mbg_dev_has_synth() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SYNTH_STATE structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_synth()
    @see mbg_get_synth()
    @see mbg_set_synth()
    @see \ref group_synth
*/
_MBG_API_ATTR int _MBG_API mbg_get_synth_state( MBG_DEV_HANDLE dh, SYNTH_STATE *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_SYNTH_STATE, IOCTL_GET_SYNTH_STATE,
                          p, _pcps_ddev_has_synth( dh ) );
  _mbg_swab_synth_state( p );
  return _mbgdevio_ret_val;

}  // mbg_get_synth_state



/*HDR*/
/**
    Check if a specific device supports the mbg_get_fast_hr_timestamp_...() calls.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_fast_hr_timestamp_cycles()
    @see mbg_get_fast_hr_timestamp_comp()
    @see mbg_get_fast_hr_timestamp()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_fast_hr_timestamp( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_fast_hr_timestamp, IOCTL_DEV_HAS_FAST_HR_TIMESTAMP, p );

}  // mbg_dev_has_fast_hr_timestamp



/*HDR*/
/**
    Read a high resolution ::PCPS_TIME_STAMP_CYCLES structure via memory mapped access.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP_CYCLES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_fast_hr_timestamp_comp()
    @see mbg_get_fast_hr_timestamp()
*/
_MBG_API_ATTR int _MBG_API mbg_get_fast_hr_timestamp_cycles( MBG_DEV_HANDLE dh,
                                                             PCPS_TIME_STAMP_CYCLES *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_FAST_HR_TIMESTAMP_CYCLES, p );
    // native endianess, no need to swap bytes
    return _mbgdevio_ret_val;
  #else
    // This is currently not supported by the target environment.
    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_ON_OS );
  #endif
}  // mbg_get_fast_hr_timestamp_cycles



/*HDR*/
/**
    Read a high resolution ::PCPS_TIME_STAMP via memory mapped access,
    and compensate the latency of the time stamp before it is returned.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP structure to be filled up
    @param *hns_latency Optionally receive the latency in hectonanoseconds

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_fast_hr_timestamp_cycles()
    @see mbg_get_fast_hr_timestamp()
*/
_MBG_API_ATTR int _MBG_API mbg_get_fast_hr_timestamp_comp( MBG_DEV_HANDLE dh,
                                                           PCPS_TIME_STAMP *p,
                                                           int32_t *hns_latency )
{
  PCPS_TIME_STAMP_CYCLES tc;
  MBG_PC_CYCLES cyc_now;
  int rc;

  // First get current time stamp counter value, then read
  // a high resolution time stamp from the board, plus the
  // associated time stamp counter value.
  mbg_get_pc_cycles( &cyc_now );

  rc = mbg_get_fast_hr_timestamp_cycles( dh, &tc );

  if ( rc == MBG_SUCCESS )
  {
    mbg_init_pc_cycles_frequency( dh, &pc_cycles_frequency );
    rc = mbg_comp_hr_latency( &tc.tstamp, &tc.cycles, &cyc_now, &pc_cycles_frequency, hns_latency );
    *p = tc.tstamp;
  }

  return rc;

}  // mbg_get_fast_hr_timestamp_comp



/*HDR*/
/**
    Read a high resolution ::PCPS_TIME_STAMP structure via memory mapped access.

    This function does not return or evaluate a cycles count, so the latency
    of the call can not be determined. However, depending on the timer hardware
    used as cycles counter it may take quite some time to read the cycles count
    on some hardware architectures, so this call can be used to yield lower 
    latencies, under the restriction to be unable to determine the exact latency.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_fast_hr_timestamp_comp()
    @see mbg_get_fast_hr_timestamp_cycles()
*/
_MBG_API_ATTR int _MBG_API mbg_get_fast_hr_timestamp( MBG_DEV_HANDLE dh,
                                                      PCPS_TIME_STAMP *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_FAST_HR_TIMESTAMP, p );
    // native endianess, no need to swap bytes
    return _mbgdevio_ret_val;
  #else
    // This is currently not supported by the target environment.
    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_ON_OS );
  #endif
}  // mbg_get_fast_hr_timestamp



/*HDR*/
/**
    Check if a specific device is a GPS receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_is_gps( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_is_gps, IOCTL_DEV_IS_GPS, p );

}  // mbg_dev_is_gps



/*HDR*/
/**
    Check if a specific device is a DCF77 receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_is_dcf( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_is_dcf, IOCTL_DEV_IS_DCF, p );

}  // mbg_dev_is_dcf



/*HDR*/
/**
    Check if a specific device is a MSF receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_is_msf( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_is_msf, IOCTL_DEV_IS_MSF, p );

}  // mbg_dev_is_msf



/*HDR*/
/**
    Check if a specific device is a WWVB receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_is_wwvb( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_is_wwvb, IOCTL_DEV_IS_WWVB, p );

}  // mbg_dev_is_msf



/*HDR*/
/**
    Check if a specific device is a long wave signal receiver, e.g. DCF77, MSF or WWVB.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_is_lwr( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_is_lwr, IOCTL_DEV_IS_LWR, p );

}  // mbg_dev_is_lwr



/*HDR*/
/**
    Check if a specific device is an IRIG receiver which supports 
    configuration of the IRIG input.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_rx_info()
    @see mbg_set_irig_rx_settings()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_has_irig()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_is_irig_rx( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_is_irig_rx, IOCTL_DEV_IS_IRIG_RX, p );

}  // mbg_dev_is_irig_rx



/*HDR*/
/**
    Check if a specific device supports the HR_TIME functions.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time()
    @see mbg_get_hr_time_cycles()
    @see mbg_get_hr_time_comp()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_hr_time( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_hr_time, IOCTL_DEV_HAS_HR_TIME, p );

}  // mbg_dev_has_hr_time



/*HDR*/
/**
    Check if a specific device supports configuration of antenna cable length.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_ant_cable_len()
    @see mbg_set_gps_ant_cable_len()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_cab_len( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_cab_len, IOCTL_DEV_HAS_CAB_LEN, p );

}  // mbg_dev_has_cab_len



/*HDR*/
/**
    Check if a specific device supports timezone / daylight saving configuration 
    using the ::TZDL structure.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_tzdl()
    @see mbg_set_gps_tzdl()
    @see mbg_dev_has_tz()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_tzdl( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_tzdl, IOCTL_DEV_HAS_TZDL, p );

}  // mbg_dev_has_tzdl



/*HDR*/
/**
    Check if a specific device supports timezone / daylight saving configuration 
    using the ::PCPS_TZDL structure.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_pcps_tzdl()
    @see mbg_set_pcps_tzdl()
    @see mbg_dev_has_tz()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_pcps_tzdl( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_pcps_tzdl, IOCTL_DEV_HAS_PCPS_TZDL, p );

}  // mbg_dev_has_pcps_tzdl



/*HDR*/
/**
    Check if a specific device supports timezone configuration 
    using the ::PCPS_TZCODE type.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_tzcode()
    @see mbg_set_tzcode()
    @see mbg_dev_has_tz()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_tzcode( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_tzcode, IOCTL_DEV_HAS_TZCODE, p );

}  // mbg_dev_has_tzcode



/*HDR*/
/**
    Check if a specific device supports any kind of timezone configuration.
    This can be used e.g. to check if a specifig dialog or menu has to 
    be displayed. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzdl()
    @see mbg_dev_has_pcps_tzdl()
    @see mbg_dev_has_tzcode()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_tz( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_tz, IOCTL_DEV_HAS_TZ, p );

}  // mbg_dev_has_tz



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Check if a specific device supports setting an event time, i.e. 
    configure a %UTC time when the clock shall generate an event.

    <b>Note:</b> This is only supported by some special firmware.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_event_time()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_event_time( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_event_time, IOCTL_DEV_HAS_EVENT_TIME, p );

}  // mbg_dev_has_event_time



/*HDR*/
/**
    Check if a specific device supports the ::RECEIVER_INFO structure and related calls.
    Older GPS devices may not support that structure.

    The mbg_get_gps_receiver_info() call uses this call to decide whether a 
    ::RECEIVER_INFO can be read directly from a device, or whether a default 
    structure has to be set up using default values depending on the device type.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_receiver_info()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_receiver_info( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_receiver_info, IOCTL_DEV_HAS_RECEIVER_INFO, p );

}  // mbg_dev_has_receiver_info



/*HDR*/
/**
    Check if a specific device supports the mbg_clr_ucap_buff() call 
    used to clear a card's on-board time capture FIFO buffer.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_clr_ucap_buff()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_can_clr_ucap_buff( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_can_clr_ucap_buff, IOCTL_DEV_CAN_CLR_UCAP_BUFF, p );

}  // mbg_dev_can_clr_ucap_buff



/*HDR*/
/**
    Check if a specific device supports the mbg_get_ucap_entries() and
    mbg_get_ucap_event() calls. 

    If the card does not but it is a GPS card then the card provides 
    a time capture FIFO buffer and the obsolete mbg_get_gps_ucap()
    call can be used to retrieve entries from the FIFO buffer.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
    @see mbg_clr_ucap_buff()
    @see mbg_get_gps_ucap()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_ucap( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_ucap, IOCTL_DEV_HAS_UCAP, p );

}  // mbg_dev_has_ucap



/*HDR*/
/**
    Check if a specific device provides an IRIG output which can 
    be configured.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_tx_info()
    @see mbg_set_irig_tx_settings()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig()
    @see \ref group_icode

*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_irig_tx( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_irig_tx, IOCTL_DEV_HAS_IRIG_TX, p );

}  // mbg_dev_has_irig_tx



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Check if a specific device provides a serial output supporting 
    higher baud rates than older cards, i.e. ::DEFAULT_BAUD_RATES_DCF_HS
    rather than ::DEFAULT_BAUD_RATES_DCF. 

    The mbg_get_serial_settings() takes care of this, so applications
    which use that call as suggested won't need to use this call directly.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_serial_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_serial_hs( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_serial_hs, IOCTL_DEV_HAS_SERIAL_HS, p );

}  // mbg_dev_has_serial_hs



/*HDR*/
/**
    Check if a specific device provides an input signal level value which
    may be displayed, e.g. DCF77 or IRIG cards.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_signal( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_signal, IOCTL_DEV_HAS_SIGNAL, p );

}  // mbg_dev_has_signal



/*HDR*/
/**
    Check if a specific device provides an modulation signal which may be 
    displayed, e.g. the second marks of a DCF77 AM receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_mod( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_mod, IOCTL_DEV_HAS_MOD, p );

}  // mbg_dev_has_mod



/*HDR*/
/**
    Check if a specific device provides either an IRIG input or output.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig_tx()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_irig( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_irig, IOCTL_DEV_HAS_IRIG, p );

}  // mbg_dev_has_irig



/*HDR*/
/**
    Check if a specific device provides a configurable ref time offset
    required to convert the received time to %UTC.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ref_offs()
    @see mbg_set_ref_offs()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_ref_offs( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_ref_offs, IOCTL_DEV_HAS_REF_OFFS, p );

}  // mbg_dev_has_ref_offs



/*HDR*/
/**
    Check if a specific device supports the ::MBG_OPT_INFO/::MBG_OPT_SETTINGS 
    structures containing optional settings, controlled by flags.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_opt_info()
    @see mbg_set_opt_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_opt_flags( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_opt_flags, IOCTL_DEV_HAS_OPT_FLAGS, p );

}  // mbg_dev_has_opt_flags



/*HDR*/
/**
    Check if a specific device supports large configuration data structures
    as have been introducesde with the GPS receivers. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_gps_data( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_gps_data, IOCTL_DEV_HAS_GPS_DATA, p );

}  // mbg_dev_has_gps_data



/*HDR*/
/**
    Check if a specific device provides a programmable frequency synthesizer.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_synth()
    @see mbg_set_synth()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_synth( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_synth, IOCTL_DEV_HAS_SYNTH, p );

}  // mbg_dev_has_synth



/*HDR*/
/* (Intentionally excluded from Doxygen)
    Check if a specific device supports the mbg_generic_io() call.

    <b>Warning</b>: That call is for debugging purposes and internal use only!

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_generic_io()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_generic_io( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_generic_io, IOCTL_DEV_HAS_GENERIC_IO, p );

}  // mbg_dev_has_generic_io



/*HDR*/
/**
    Check if a specific device supports the mbg_get_asic_version() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_asic_version()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_asic_version( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_asic_version, IOCTL_DEV_HAS_PCI_ASIC_VERSION, p );

}  // mbg_dev_has_asic_version



/*HDR*/
/**
    Check if a specific device supports the mbg_get_asic_features() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_asic_features()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_asic_features( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_asic_features, IOCTL_DEV_HAS_PCI_ASIC_FEATURES, p );

}  // mbg_dev_has_asic_features



/*HDR*/
/**
    Read a ::POUT_INFO_IDX array of current settings and configuration
    options of a card's programmable pulse outputs.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.
    The function should only be called if the ::RECEIVER_INFO::n_prg_out 
    field (i.e. the number of programmable outputs on the board) is not 0.

    The array passed to this function to receive the returned data 
    must be able to hold at least ::RECEIVER_INFO::n_prg_out elements.

    @param dh Valid handle to a Meinberg device.
    @param pii Pointer to a an array of ::POUT_INFO_IDX structures to be filled up
    @param *p_ri Pointer to a ::RECEIVER_INFO structure returned by mbg_setup_receiver_info()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pout_settings_idx()
    @see mbg_set_gps_pout_settings()
    @see mbg_setup_receiver_info()
*/
_MBG_API_ATTR int _MBG_API mbg_get_gps_all_pout_info( MBG_DEV_HANDLE dh,
                                        POUT_INFO_IDX pii[],
                                        const RECEIVER_INFO *p_ri )
{
  _mbgdevio_vars();

  #if _MBG_SUPP_VAR_ACC_SIZE
    _mbgdevio_read_gps_chk( dh, PC_GPS_ALL_POUT_INFO,
                            IOCTL_GET_GPS_ALL_POUT_INFO, pii,
                            p_ri->n_prg_out * sizeof( pii[0] ),
                            _pcps_ddev_has_receiver_info( dh ) );
  #else
    // We check the model_code to see whether the receiver info
    // has been read from a device which really supports it, or
    // a dummy structure has been setup.
    if ( p_ri && ( p_ri->model_code != GPS_MODEL_UNKNOWN ) )
      rc = _mbgdevio_gen_read_gps( dh, PC_GPS_ALL_POUT_INFO, pii, 
                                   p_ri->n_prg_out * sizeof( pii[0] ) );
    else
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV );
  #endif

  #if defined( MBG_ARCH_BIG_ENDIAN )
    if ( rc == MBG_SUCCESS )
    {
      int i;
      for ( i = 0; i < p_ri->n_prg_out; i++ )
      {
        POUT_INFO_IDX *p = &pii[i];
        _mbg_swab_pout_info_idx( p );
      }
    }
  #endif

  return _mbgdevio_ret_val;

}  // mbg_get_gps_all_pout_info



/*HDR*/
/**
    Write the configuration for a single programmable pulse output using 
    the ::POUT_SETTINGS_IDX structure which contains both the ::POUT_SETTINGS 
    and the output index value.
    Except for the parameter types, this call is equivalent to 
    mbg_set_gps_pout_settings().
    The function should only be called if the ::RECEIVER_INFO::n_prg_out field 
    (i.e. the number of programmable outputs on the board) is not 0, and the 
    output index value must be in the range 0..::RECEIVER_INFO::n_prg_out.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::POUT_SETTINGS_IDX structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_all_pout_info()
    @see mbg_set_gps_pout_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_pout_settings_idx( MBG_DEV_HANDLE dh,
                                                          const POUT_SETTINGS_IDX *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    POUT_SETTINGS_IDX tmp = *p;
    _mbg_swab_pout_settings_idx( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_POUT_SETTINGS_IDX,
                               IOCTL_SET_GPS_POUT_SETTINGS_IDX, p,
                               _pcps_ddev_has_receiver_info( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_gps_pout_settings_idx



/*HDR*/
/**
    Write the configuration for a single programmable pulse output using 
    the ::POUT_SETTINGS structure plus the index of the output to be configured.
    Except for the parameter types, this call is equivalent to 
    mbg_set_gps_pout_settings_idx().
    The function should only be called if the ::RECEIVER_INFO::n_prg_out field 
    (i.e. the number of programmable outputs on the board) is not 0, and the 
    output index value must be in the range 0..::RECEIVER_INFO::n_prg_out.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::POUT_SETTINGS structure to be written
    @param idx Index of the programmable pulse output to be configured (starting from 0 ).

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_all_pout_info()
    @see mbg_set_gps_pout_settings_idx()
*/
_MBG_API_ATTR int _MBG_API mbg_set_gps_pout_settings( MBG_DEV_HANDLE dh,
                                                      const POUT_SETTINGS *p, int idx )
{
  POUT_SETTINGS_IDX psi = { 0 };

  psi.idx = idx;
  psi.pout_settings = *p;

  return mbg_set_gps_pout_settings_idx( dh, &psi );

}  // mbg_set_gps_pout_settings



/*HDR*/
/**
    Read a card's IRQ status information which includes flags indicating
    whether IRQs are currently enabled, and whether IRQ support by a card 
    is possibly unsafe due to the firmware and interface chip version.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_IRQ_STAT_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
  */
_MBG_API_ATTR int _MBG_API mbg_get_irq_stat_info( MBG_DEV_HANDLE dh, PCPS_IRQ_STAT_INFO *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_IRQ_STAT_INFO, p );
    // native endianess, no need to swap bytes
    return _mbgdevio_ret_val;
  #else
    *p = dh->irq_stat_info;
    return MBG_SUCCESS;
  #endif

}  // mbg_get_irq_stat_info



/*HDR*/
/**
    Check if a specific device provides simple LAN interface API calls.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_state()
    @see mbg_get_ip4_settings()
    @see mbg_set_ip4_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_lan_intf( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_lan_intf, IOCTL_DEV_HAS_LAN_INTF, p );

}  // mbg_dev_has_lan_intf



/*HDR*/
/**
    Read LAN interface information from a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::LAN_IF_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_ip4_state()
    @see mbg_get_ip4_settings()
    @see mbg_set_ip4_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_lan_if_info( MBG_DEV_HANDLE dh, LAN_IF_INFO *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_LAN_IF_INFO,
                              IOCTL_GET_LAN_IF_INFO, p,
                              _pcps_ddev_has_lan_intf( dh ) );
  _mbg_swab_lan_if_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_lan_if_info



/*HDR*/
/**
    Read LAN IPv4 state from a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::IP4_SETTINGS variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_settings()
    @see mbg_set_ip4_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_ip4_state( MBG_DEV_HANDLE dh, IP4_SETTINGS *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_IP4_STATE,
                              IOCTL_GET_IP4_STATE, p,
                              _pcps_ddev_has_lan_intf( dh ) );
  _mbg_swab_ip4_settings( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ip4_state



/*HDR*/
/**
    Read LAN IPv4 settings from a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::IP4_SETTINGS variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_state()
    @see mbg_set_ip4_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_ip4_settings( MBG_DEV_HANDLE dh, IP4_SETTINGS *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_IP4_SETTINGS,
                              IOCTL_GET_IP4_SETTINGS, p,
                              _pcps_ddev_has_lan_intf( dh ) );
  _mbg_swab_ip4_settings( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ip4_settings



/*HDR*/
/**
    Write LAN IPv4 settings to a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::IP4_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_set_ip4_settings( MBG_DEV_HANDLE dh,
                                                 const IP4_SETTINGS *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    IP4_SETTINGS tmp = *p;
    _mbg_swab_ip4_settings( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_IP4_SETTINGS,
                               IOCTL_SET_IP4_SETTINGS, p,
                               _pcps_ddev_has_lan_intf( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_ip4_settings



/*HDR*/
/**
    Check if a specific device provides PTP configuration/status calls.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ptp_state()
    @see mbg_get_ptp_cfg_info()
    @see mbg_set_ptp_cfg_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_ptp( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_ptp, IOCTL_DEV_HAS_PTP, p );

}  // mbg_dev_has_ptp



/*HDR*/
/**
    Check if a specific device provides PTP Unicast feature/configuration.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ptp_state()
    @see mbg_get_ptp_uc_master_cfg_limits()
    @see mbg_get_all_ptp_uc_master_info()
    @see mbg_set_ptp_unicast_cfg_settings()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_ptp_unicast( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_ri_cond( dh, _pcps_has_ri_ptp_unicast, IOCTL_DEV_HAS_PTP_UNICAST, p );

}  // mbg_dev_has_ptp_unicast



/*HDR*/
/**
    Read PTP/IEEE1588 status from a card which supports this.
    The macro _pcps_has_ptp() or the API call mbg_dev_has_ptp()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PTP_CFG_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp()
    @see mbg_get_ptp_cfg_info()
    @see mbg_set_ptp_cfg_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_ptp_state( MBG_DEV_HANDLE dh, PTP_STATE *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_PTP_STATE,
                              IOCTL_GET_PTP_STATE, p,
                              _pcps_ddev_has_ptp( dh ) );
  _mbg_swab_ptp_state( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ptp_state



/*HDR*/
/**
    Read PTP/IEEE1588 config info and current settings from a card which supports this.
    The macro _pcps_has_ptp() or the API call mbg_dev_has_ptp()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PTP_CFG_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp()
    @see mbg_get_ptp_state()
    @see mbg_set_ptp_cfg_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_ptp_cfg_info( MBG_DEV_HANDLE dh, PTP_CFG_INFO *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_PTP_CFG,
                              IOCTL_GET_PTP_CFG_INFO, p,
                              _pcps_ddev_has_ptp( dh ) );
  _mbg_swab_ptp_cfg_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ptp_cfg_info



/*HDR*/
/**
    Write PTP/IEEE1588 configuration settings to a card which supports this.
    The macro _pcps_has_ptp() or the API call mbg_dev_has_ptp()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::PTP_CFG_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp()
    @see mbg_get_ptp_state()
    @see mbg_get_ptp_cfg_info()
*/
_MBG_API_ATTR int _MBG_API mbg_set_ptp_cfg_settings( MBG_DEV_HANDLE dh,
                                                     const PTP_CFG_SETTINGS *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    PTP_CFG_SETTINGS tmp = *p;
    _mbg_swab_ptp_cfg_settings( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_PTP_CFG,
                               IOCTL_SET_PTP_CFG_SETTINGS, p,
                               _pcps_ddev_has_ptp( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_ptp_cfg_settings



/*HDR*/
/**
    Read PTP/IEEE1588 unicast config info and current settings from a card which supports this.
    The macro _pcps_has_ri_ptp_unicast() or the API call mbg_dev_has_ptp_unicast()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PTP_UNICAST_CFG_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp_unicast()
    @see mbg_set_ptp_unicast_cfg_settings()
  */
_MBG_API_ATTR int _MBG_API mbg_get_ptp_uc_master_cfg_limits( MBG_DEV_HANDLE dh, PTP_UC_MASTER_CFG_LIMITS *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_gps_var_chk( dh, PC_GPS_PTP_UC_MASTER_CFG_LIMITS,
                              IOCTL_PTP_UC_MASTER_CFG_LIMITS, p,
                              _pcps_has_ri_ptp_unicast( &dh->ri ) );
  _mbg_swab_ptp_uc_master_cfg_limits( p );
  return _mbgdevio_ret_val;

}  // mbg_get_ptp_uc_master_cfg_limits



/*HDR*/
/**
    Read a ::IOCTL_SET_PTP_UNICAST_CFG_SETTINGS array of current settings and configuration
    options of a card's programmable pulse outputs.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.
    The function should only be called if the ::RECEIVER_INFO::n_prg_out 
    field (i.e. the number of programmable outputs on the board) is not 0.

    The array passed to this function to receive the returned data 
    must be able to hold at least ::RECEIVER_INFO::n_prg_out elements.

    @param dh Valid handle to a Meinberg device.
    @param pii Pointer to a an array of ::PTP_UC_MASTER_INFO_IDX structures to be filled up
    @param p_umsl Pointer to a ::PTP_UC_MASTER_CFG_LIMITS structure returned by mbg_get_ptp_uc_master_cfg_limits()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see //##++++++++++++++++++++++
    @see 
    @see 
*/
_MBG_API_ATTR int _MBG_API mbg_get_all_ptp_uc_master_info( MBG_DEV_HANDLE dh,
                                        PTP_UC_MASTER_INFO_IDX pii[],
                                        const PTP_UC_MASTER_CFG_LIMITS *p_umsl )
{
  _mbgdevio_vars();

  #if _MBG_SUPP_VAR_ACC_SIZE
    _mbgdevio_read_gps_chk( dh, PC_GPS_ALL_PTP_UC_MASTER_INFO,
                            IOCTL_GET_ALL_PTP_UC_MASTER_INFO, pii,
                            p_umsl->n_supp_master * sizeof( pii[0] ),
                            _pcps_ddev_has_ptp_unicast( dh ) );
  #else
    if ( p_umsl && p_umsl->n_supp_master )
      rc = _mbgdevio_gen_read_gps( dh, PC_GPS_ALL_PTP_UC_MASTER_INFO, pii,
                                             p_umsl->n_supp_master * sizeof( pii[0] ) );
    else
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV );
  #endif

  #if defined( MBG_ARCH_BIG_ENDIAN )
    if ( rc == MBG_SUCCESS )
    {
      int i;
      for ( i = 0; i < p_umsl->n_supp_master; i++ )
      {
        PTP_UC_MASTER_INFO_IDX *p = &pii[i];
        _mbg_swab_ptp_uc_master_info_idx( p );
      }
    }
  #endif

  return _mbgdevio_ret_val;

}  // mbg_get_all_ptp_uc_master_info



/*HDR*/
/**
    Write PTP/IEEE1588 unicast configuration settings to a card which supports this.
    The macro _pcps_has_ri_ptp_unicast() or the API call mbg_dev_has_ptp_unicast()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::PTP_UNICAST_CFG_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp_unicast()
    @see mbg_get_ptp_state()
    @see mbg_get_ptp_cfg_info()
    @see mbg_get_ptp_unicast_cfg_info()
*/
_MBG_API_ATTR int _MBG_API mbg_set_ptp_uc_master_settings_idx( MBG_DEV_HANDLE dh,
                                                     const PTP_UC_MASTER_SETTINGS_IDX *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    PTP_UC_MASTER_SETTINGS_IDX tmp = *p;
    _mbg_swab_ptp_uc_master_settings_idx( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_gps_var_chk( dh, PC_GPS_PTP_UC_MASTER_SETTINGS_IDX,
                               IOCTL_SET_PTP_UC_MASTER_SETTINGS_IDX, p,
                               _pcps_ddev_has_ptp_unicast( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_ptp_uc_master_settings_idx



/*HDR*/
/**
    Read system time and card time from the kernel driver. The kernel
    driver reads the current system time plus a HR time structure from
    a card immediately after each other. The returned info structure also
    contains some cycles counts to be able to determine the execution times
    required to read those time stamps.

    The advantage of this call compared to mbg_get_time_info_tstamp() is
    that this call also returns the card's status. On the other hand, reading
    the HR time from the card may block e.g. if another application accesses
    the board.

    This call makes a mbg_get_hr_time_cycles() call internally so the macro
    _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() can be 
    used to check whether this call is supported with a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_INFO_HRT variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_hr_time()
    @see mbg_get_time_info_tstamp()
  */
_MBG_API_ATTR int _MBG_API mbg_get_time_info_hrt( MBG_DEV_HANDLE dh, MBG_TIME_INFO_HRT *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    _mbgdevio_read_var_chk( dh, -1, IOCTL_GET_TIME_INFO_HRT, p,
                            _pcps_ddev_has_hr_time( dh ) );
    _mbg_swab_mbg_time_info_hrt( p );
    return _mbgdevio_ret_val;
  #else
    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_ON_OS );
  #endif

}  // mbg_get_time_info_hrt



/*HDR*/
/**
    This call is similar to mbg_get_time_info_hrt() except that a
    mbg_get_fast_hr_timestamp_cycles() call is made internally, so the macro
    _pcps_has_fast_hr_timestamp() or the API call mbg_dev_has_fast_hr_timestamp()
    can be used to check whether this call is supported with a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_INFO_TSTAMP variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_time_info_hrt()
  */
_MBG_API_ATTR int _MBG_API mbg_get_time_info_tstamp( MBG_DEV_HANDLE dh, MBG_TIME_INFO_TSTAMP *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    _mbgdevio_read_var_chk( dh, -1, IOCTL_GET_TIME_INFO_TSTAMP, p,
                            _pcps_ddev_has_fast_hr_timestamp( dh ) );
    _mbg_swab_mbg_time_info_tstamp( p );
    return _mbgdevio_ret_val;
  #else
    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_ON_OS );
  #endif

}  // mbg_get_time_info_tstamp



/*HDR*/
/**
    Check if a specific device supports demodulation of the DCF77 PZF code.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_corr_info()
    @see mbg_dev_has_tr_distance()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_pzf( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_pzf, IOCTL_DEV_HAS_PZF, p );

}  // mbg_dev_has_pzf



/*HDR*/
/**
    Check if a specific device supports reading correlation info.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_get_corr_info()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_corr_info( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_corr_info, IOCTL_DEV_HAS_CORR_INFO, p );

}  // mbg_dev_has_corr_info



/*HDR*/
/**
    Check if a specific device supports configurable distance from transmitter
    used to compensate RF propagation delay.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_get_tr_distance()
    @see mbg_set_tr_distance()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_tr_distance( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_tr_distance, IOCTL_DEV_HAS_TR_DISTANCE, p );

}  // mbg_dev_has_tr_distance



/*HDR*/
/**
    Read PZF correlation info from a card which supports this.
    The macro _pcps_has_corr_info() or the API call mbg_dev_has_corr_info()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::CORR_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_dev_has_corr_info()
  */
_MBG_API_ATTR int _MBG_API mbg_get_corr_info( MBG_DEV_HANDLE dh, CORR_INFO *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_CORR_INFO,
                              IOCTL_GET_CORR_INFO, p,
                              _pcps_ddev_has_corr_info( dh ) );
  _mbg_swab_corr_info( p );
  return _mbgdevio_ret_val;

}  // mbg_get_corr_info



/*HDR*/
/**
    Read configurable "distance from transmitter" parameter from a card
    which supports this. The parameter is used to compensate the RF signal
    propagation delay.
    The macro _pcps_has_tr_distance() or the API call mbg_dev_has_tr_distance()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TR_DISTANCE variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_dev_has_tr_distance()
    @see mbg_set_tr_distance()
  */
_MBG_API_ATTR int _MBG_API mbg_get_tr_distance( MBG_DEV_HANDLE dh, TR_DISTANCE *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_TR_DISTANCE,
                              IOCTL_GET_TR_DISTANCE, p,
                              _pcps_ddev_has_tr_distance( dh ) );
  _mbg_swab_tr_distance( p );
  return _mbgdevio_ret_val;

}  // mbg_get_tr_distance



/*HDR*/
/**
    Write configurable "distance from transmitter" parameter to a card
    which supports this. The parameter is used to compensate the RF signal
    propagation delay.
    The macro _pcps_has_tr_distance() or the API call mbg_dev_has_tr_distance()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TR_DISTANCE variable to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_dev_has_tr_distance()
    @see mbg_get_tr_distance()
  */
_MBG_API_ATTR int _MBG_API mbg_set_tr_distance( MBG_DEV_HANDLE dh, const TR_DISTANCE *p )
{
  _mbgdevio_vars();
  #if defined( MBG_ARCH_BIG_ENDIAN )
    TR_DISTANCE tmp = *p;
    _mbg_swab_tr_distance( &tmp );
    p = &tmp;
  #endif
  _mbgdevio_write_var_chk( dh, PCPS_SET_TR_DISTANCE, IOCTL_SET_TR_DISTANCE,
                           p, _pcps_ddev_has_tr_distance( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_set_tr_distance



/*HDR*/
/**
    Check if a specific device provides a debug status word to be read.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_debug_status()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_debug_status( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_debug_status, IOCTL_DEV_HAS_DEBUG_STATUS, p );

}  // mbg_dev_has_debug_status



/*HDR*/
/**
    Read a debug status word from a card. This is mainly supported
    by IRIG timecode receiver cards, and the status word is intended
    to provide more detailed information why a card might not synchronize
    to the incoming timecode signal.

    The macro _pcps_has_debug_status() or the API call mbg_dev_has_debug_status()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_DEBUG_STATUS variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_debug_status()
  */
_MBG_API_ATTR int _MBG_API mbg_get_debug_status( MBG_DEV_HANDLE dh, MBG_DEBUG_STATUS *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_GET_DEBUG_STATUS,
                              IOCTL_GET_DEBUG_STATUS, p,
                              _pcps_ddev_has_debug_status( dh ) );
  _mbg_swab_debug_status( p );
  return _mbgdevio_ret_val;

}  // mbg_get_debug_status



/*HDR*/
/**
    Check if a specific device provides an on-board event log.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_clr_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_first_evt_log_entry()
    @see mbg_get_next_evt_log_entry()
*/
_MBG_API_ATTR int _MBG_API mbg_dev_has_evt_log( MBG_DEV_HANDLE dh, int *p )
{
  _mbgdevio_query_cond( dh, _pcps_ddev_has_evt_log, IOCTL_DEV_HAS_EVT_LOG, p );

}  // mbg_dev_has_evt_log



/*HDR*/
/**
    Clear the card's on-board event log.
    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    @param dh Valid handle to a Meinberg device

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_first_evt_log_entry()
    @see mbg_get_next_evt_log_entry()
  */
_MBG_API_ATTR int _MBG_API mbg_clr_evt_log( MBG_DEV_HANDLE dh )
{
  _mbgdevio_vars();
  _mbgdevio_write_cmd_chk( dh, PCPS_CLR_EVT_LOG, IOCTL_CLR_EVT_LOG,
                           _pcps_ddev_has_evt_log( dh ) );
  return _mbgdevio_ret_val;

}  // mbg_clr_evt_log



/*HDR*/
/**
    Read max number of num event log entries which can
    be saved on the board, and how many entries actually
    have been saved.
    _pcps_has_evt_log() checks whether supported.

    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_NUM_EVT_LOG_ENTRIES variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_clr_evt_log()
    @see mbg_get_first_evt_log_entry()
    @see mbg_get_next_evt_log_entry()
  */
_MBG_API_ATTR int _MBG_API mbg_get_num_evt_log_entries( MBG_DEV_HANDLE dh, MBG_NUM_EVT_LOG_ENTRIES *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_NUM_EVT_LOG_ENTRIES,
                              IOCTL_GET_NUM_EVT_LOG_ENTRIES, p,
                              _pcps_ddev_has_evt_log( dh ) );
  _mbg_swab_mbg_num_evt_log_entries( p );
  return _mbgdevio_ret_val;

}  // mbg_get_num_evt_log_entries



/*HDR*/
/**
    Read the first (oldest) event log entry from a device.

    @note Subsequent reads should be made using mbg_get_next_evt_log_entry().

    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    If no (more) event log entry is available on the device then
    the returned MBG_EVT_LOG_ENTRY::code is MBG_EVT_ID_NONE.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_EVT_LOG_ENTRY variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_clr_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_next_evt_log_entry()
  */
_MBG_API_ATTR int _MBG_API mbg_get_first_evt_log_entry( MBG_DEV_HANDLE dh, MBG_EVT_LOG_ENTRY *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_FIRST_EVT_LOG_ENTRY,
                              IOCTL_GET_FIRST_EVT_LOG_ENTRY, p,
                              _pcps_ddev_has_evt_log( dh ) );
  _mbg_swab_mbg_evt_log_entry( p );
  return _mbgdevio_ret_val;

}  // mbg_get_first_evt_log_entry



/*HDR*/
/**
    Read the next event log entry from a device.

    @note The first read should be made using mbg_get_first_evt_log_entry()
    to set the on-board read index to the oldest entry.

    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    If no (more) event log entry is available on the device then
    the returned MBG_EVT_LOG_ENTRY::code is MBG_EVT_ID_NONE.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_EVT_LOG_ENTRY variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_clr_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_first_evt_log_entry()
  */
_MBG_API_ATTR int _MBG_API mbg_get_next_evt_log_entry( MBG_DEV_HANDLE dh, MBG_EVT_LOG_ENTRY *p )
{
  _mbgdevio_vars();
  _mbgdevio_read_var_chk( dh, PCPS_NEXT_EVT_LOG_ENTRY,
                              IOCTL_GET_NEXT_EVT_LOG_ENTRY, p,
                              _pcps_ddev_has_evt_log( dh ) );
  _mbg_swab_mbg_evt_log_entry( p );
  return _mbgdevio_ret_val;

}  // mbg_get_next_evt_log_entry



/*HDR*/
/**
    Read the CPU affinity of a process, i.e. on which of the available
    CPUs the process can be executed.

    @param pid The process ID.
    @param *p Pointer to a ::MBG_CPU_SET variable which contains a mask of CPUs.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_set_process_affinity()
    @see mbg_set_current_process_affinity_to_cpu()
  */
_MBG_API_ATTR int _MBG_API mbg_get_process_affinity( MBG_PROCESS_ID pid, MBG_CPU_SET *p )
{
  #if defined( MBG_TGT_LINUX )

    return sched_getaffinity( pid, sizeof( *p ), p );

  #elif defined( MBG_TGT_WIN32 )

    MBG_CPU_SET system_affinity_mask = 0;

    return GetProcessAffinityMask( pid, p, &system_affinity_mask ) ? 0 : -1;

  #else

    return -1;

  #endif

}  // mbg_get_process_affinity



/*HDR*/
/**
    Set the CPU affinity of a process, i.e. on which of the available 
    CPUs the process is allowed to be executed.

    @param pid The process ID.
    @param *p Pointer to a ::MBG_CPU_SET variable which contains a mask of CPUs.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_get_process_affinity()
    @see mbg_set_current_process_affinity_to_cpu()
  */
_MBG_API_ATTR int _MBG_API mbg_set_process_affinity( MBG_PROCESS_ID pid, MBG_CPU_SET *p )
{
  #if defined( MBG_TGT_LINUX )

    return sched_setaffinity( pid, sizeof( *p ), p );

  #elif defined( MBG_TGT_WIN32 )

    return SetProcessAffinityMask( pid, *p ) ? 0 : -1;

  #else

    return -1;

  #endif

}  // mbg_set_process_affinity



/*HDR*/
/**
    Set the CPU affinity of a process for a single CPU only, i.e. the process
    may only be executed on that single CPU.

    @param cpu_num The number of the CPU.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_get_process_affinity()
    @see mbg_set_process_affinity()
  */
_MBG_API_ATTR int _MBG_API mbg_set_current_process_affinity_to_cpu( int cpu_num )
{
  MBG_CPU_SET cpu_set;

  _mbg_cpu_clear( &cpu_set );
  _mbg_cpu_set( cpu_num, &cpu_set );

  return mbg_set_process_affinity( _mbg_get_current_process(), &cpu_set );

}  // mbg_set_current_process_affinity_to_cpu



#if MBGDEVIO_USE_THREAD_API

/*HDR*/
/**
    Create a new execution thread for the current process.
    This function is only implemented for targets which support threads.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure to be filled up.
    @param fnc The name of the thread function to be started.
    @param arg A generic argument passed to the thread function.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_thread_stop()
    @see mbg_thread_sleep_interruptible()
    @see mbg_thread_set_affinity()
  */
_MBG_API_ATTR int _MBG_API mbg_thread_create( MBG_THREAD_INFO *p_ti,
                             MBG_THREAD_FNC_RET_VAL (MBG_THREAD_FNC_ATTR *fnc)(void *), void *arg )
{
  #if defined( MBG_TGT_LINUX )

    return pthread_create( &p_ti->thread_id, NULL, fnc, arg );

  #elif defined( MBG_TGT_WIN32 )

    HANDLE h;
    DWORD thread_id = 0;

    p_ti->exit_request = CreateEvent( NULL, FALSE, FALSE, NULL );

    if ( p_ti->exit_request == NULL )
      goto fail;

    h = CreateThread( NULL, 0, fnc, arg, 0, &thread_id );

    if ( h == NULL )
    {
      CloseHandle( p_ti->exit_request );
      goto fail; 
    }

    p_ti->thread_id = h;

    return 0;

fail:
    return GetLastError();

  #else

    return -1;

  #endif

}  // mbg_thread_create



/*HDR*/
/**
    Stop a thread which has been created by mbg_thread_create(). Wait 
    until the thread has finished and release all resources.
    This function is only implemented for targets which support threads.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure associated with the thread.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_thread_create()
    @see mbg_thread_sleep_interruptible()
    @see mbg_thread_set_affinity()
  */
_MBG_API_ATTR int _MBG_API mbg_thread_stop( MBG_THREAD_INFO *p_ti )
{
  #if defined( MBG_TGT_LINUX )

    pthread_cancel( p_ti->thread_id );

    return pthread_join( p_ti->thread_id, NULL );

  #elif defined( MBG_TGT_WIN32 )

    if ( SetEvent( p_ti->exit_request ) &&
         WaitForSingleObject( p_ti->thread_id, 10000L ) == 0 )
    {
      CloseHandle( p_ti->exit_request );
      p_ti->exit_request = NULL;

      CloseHandle( p_ti->thread_id );
      p_ti->thread_id = NULL;

      return 0;
    }

    return GetLastError();

  #else

    return -1;

  #endif

}  // mbg_thread_stop



/*HDR*/
/**
    Let the current thread sleep for a certain interval unless a signal is
    received indicating the thread should terminate.
    This function is only implemented for targets which support threads.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure associated with the thread.
    @param sleep_ms The number of milliseconds to sleep
    @return 0 if the sleep interval has expired normally
            1 if a signal to terminate has been received
            <0 if an error has occurred

    @see mbg_thread_create()
    @see mbg_thread_stop()
    @see mbg_thread_set_affinity()
  */
_MBG_API_ATTR int _MBG_API mbg_thread_sleep_interruptible( MBG_THREAD_INFO *p_ti, ulong sleep_ms )
{
  #if defined( MBG_TGT_LINUX )

    usleep( sleep_ms * 1000 );
    return 0;

  #elif defined( MBG_TGT_WIN32 )

    DWORD dw = WaitForSingleObject( p_ti->exit_request, sleep_ms );

    switch ( dw )
    {
      case WAIT_OBJECT_0: // has been interrupted to terminate
        return 1;

      case WAIT_TIMEOUT:  // sleep interval expired without interruption
        return 0;
    }

    return -1;

  #else

    return -1;

  #endif

}  // mbg_thread_sleep_interruptible



#if MBGDEVIO_HAVE_THREAD_AFFINITY

/*HDR*/
/**
    Set the CPU affinity of a single thread, i.e. on which of the available 
    CPUs the thread is allowed to be executed.
    This function is only implemented for targets which support thread affinity.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure associated with the thread.
    @param *p Pointer to a ::MBG_CPU_SET variable which contains a mask of CPUs.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_thread_create()
    @see mbg_thread_stop()
    @see mbg_thread_sleep_interruptible()
  */
_MBG_API_ATTR int _MBG_API mbg_thread_set_affinity( MBG_THREAD_INFO *p_ti, MBG_CPU_SET *p )
{
  #if defined( MBG_TGT_LINUX )

    return pthread_setaffinity_np( tid, sizeof( *p ), p );

  #elif defined( MBG_TGT_WIN32 )

    MBG_CPU_SET prv_thread_affinity = SetThreadAffinityMask( p_ti->thread_id, *p );

    return prv_thread_affinity ? 0 : -1;

  #else

    return -1;

  #endif

}  // mbg_thread_set_affinity

#endif



static /*HDR*/
/**
    A thread function which implements polling of a device at a regular interval.
    At each polling a high resolution time stamp and an associated cycles count
    are saved which can be used to retrieve extrapolated time stamps using the 
    cycles counter. The thread also computes the frequency of the system's cycles
    counter. 
    On systems where the cycles counter is implemented by a CPU's time stamp 
    counter (TSC) it maybe required to set the thread or process affinity to a 
    single CPU to get reliable cycles counts. In this case also care should be 
    taken that the CPU's clock frequency is not stepped up and down e.g. due 
    to power saving mechanisms (e.g. Intel SpeedStep, or AMD Cool'n'Quiet). 
    Otherwise time interpolation may be messed up.
    This function is only implemented for targets which support threads.

    @param *p_void Pointer to a ::MBG_POLL_THREAD_INFO structure. 

    @return ::MBG_SUCCESS or nothing, depending on the taget system.

    @see mbg_xhrt_poll_thread_create()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_time_as_filetime()
    @see mbg_get_xhrt_cycles_frequency()
  */
MBG_THREAD_FNC_RET_VAL MBG_THREAD_FNC_ATTR mbg_xhrt_poll_thread_fnc( void *p_void )
{
  MBG_XHRT_VARS prv_xhrt_vars;

  MBG_POLL_THREAD_INFO *p_pti = (MBG_POLL_THREAD_INFO *) p_void;
  MBG_XHRT_INFO *p = &p_pti->xhrt_info;

  memset( &prv_xhrt_vars, 0, sizeof( prv_xhrt_vars ) );

  for (;;)
  {
    MBG_XHRT_VARS xhrt_vars;
    MBG_PC_CYCLES_FREQUENCY freq = 0;
    int sleep_ms;

    int rc = mbg_get_hr_time_cycles( p->dh, &xhrt_vars.htc );

    if ( rc == MBG_SUCCESS )
    {
      xhrt_vars.pcps_hr_tstamp64 = pcps_time_stamp_to_uint64( &xhrt_vars.htc.t.tstamp );

      if ( prv_xhrt_vars.pcps_hr_tstamp64 && ( ( xhrt_vars.htc.t.status & PCPS_LS_ENB ) == 0 ) )
        freq = ( mbg_delta_pc_cycles( &xhrt_vars.htc.cycles, &prv_xhrt_vars.htc.cycles ) * PCPS_HRT_BIN_FRAC_SCALE )
                                    / ( xhrt_vars.pcps_hr_tstamp64 - prv_xhrt_vars.pcps_hr_tstamp64 );
    }


    _mbg_crit_sect_enter( &p->crit_sect );

    if ( rc == MBG_SUCCESS )
    {
      p->vars = xhrt_vars;
      p->prv_vars = prv_xhrt_vars;

      if ( freq )
        p->freq_hz = freq;
    }

    p->ioctl_status = rc;

    sleep_ms = p->sleep_ms;

    _mbg_crit_sect_leave( &p->crit_sect  );


    if ( rc == MBG_SUCCESS )
      prv_xhrt_vars = xhrt_vars;

    if ( mbg_thread_sleep_interruptible( &p_pti->ti, sleep_ms ) )
      break;
  }

  _mbg_thread_exit( 0 );

}  // mbg_xhrt_poll_thread_fnc



/*HDR*/
/**
    Set up a ::MBG_POLL_THREAD_INFO structure and start a new thread 
    which runs the mbg_xhrt_poll_thread_fnc() function.
    This function is only implemented for targets which support threads.

    @param *p_pti Pointer to a ::MBG_POLL_THREAD_INFO structure.
    @param dh the handle of the device to be polled.
    @param freq_hz The initial cycles frequency, if known, in Hz.
    @param sleep_ms the sleep interval for the poll thread function in ms. 
           If this parameter is 0 then the default sleep interval is used.

    @return ::MBG_SUCCESS on success,
            ::MBG_ERR_NOT_SUPP_BY_DEV if the device to poll does not support HR time
            else the result of mbg_thread_create() 

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_time_as_filetime()
    @see mbg_get_xhrt_cycles_frequency()
  */
_MBG_API_ATTR int _MBG_API mbg_xhrt_poll_thread_create( MBG_POLL_THREAD_INFO *p_pti, MBG_DEV_HANDLE dh,
                                                        MBG_PC_CYCLES_FREQUENCY freq_hz, int sleep_ms )
{
  int has_hr_time;
  int rc = mbg_dev_has_hr_time( dh, &has_hr_time );

  if ( ( rc != MBG_SUCCESS ) || !has_hr_time )
    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV );

  memset( p_pti, 0, sizeof( *p_pti ) );

  p_pti->xhrt_info.dh = dh;
  p_pti->xhrt_info.freq_hz = freq_hz;
  p_pti->xhrt_info.sleep_ms = sleep_ms ? sleep_ms : 1000;   // sleep 1 second by default
  _mbg_crit_sect_init( &p_pti->xhrt_info.crit_sect );

  rc = mbg_thread_create( &p_pti->ti, mbg_xhrt_poll_thread_fnc, p_pti );

  return rc;

}  // mbg_xhrt_poll_thread_create



/*HDR*/
/**
    Stop a polling thread started by mbg_xhrt_poll_thread_create() 
    and release all associated resources.

    @param *p_pti Pointer to a ::MBG_POLL_THREAD_INFO structure.

    @return the result of mbg_thread_stop() 

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_time_as_filetime()
    @see mbg_get_xhrt_cycles_frequency()
  */
_MBG_API_ATTR int _MBG_API mbg_xhrt_poll_thread_stop( MBG_POLL_THREAD_INFO *p_pti )
{
  int rc = mbg_thread_stop( &p_pti->ti );

  if ( rc == MBG_SUCCESS )
    _mbg_crit_sect_destroy( &p_pti->xhrt_info.crit_sect );

  return rc;

}  // mbg_xhrt_poll_thread_stop



static /*HDR*/
int mbg_get_xhrt_data( MBG_XHRT_INFO *p, uint64_t *tstamp, MBG_XHRT_VARS *vars )
{
  MBG_XHRT_VARS xhrt_vars;
  MBG_PC_CYCLES cyc_now;
  uint64_t t_now = 0;
  MBG_PC_CYCLES_FREQUENCY freq_hz;
  int ioctl_status;

  mbg_get_pc_cycles( &cyc_now );

  _mbg_crit_sect_enter( &p->crit_sect );
  xhrt_vars = p->vars;
  freq_hz = p->freq_hz;
  ioctl_status = p->ioctl_status;
  _mbg_crit_sect_leave( &p->crit_sect );

  if ( freq_hz && xhrt_vars.pcps_hr_tstamp64 )
  {
    t_now = xhrt_vars.pcps_hr_tstamp64 +
      ( mbg_delta_pc_cycles( &cyc_now, &xhrt_vars.htc.cycles ) * PCPS_HRT_BIN_FRAC_SCALE ) / freq_hz;
    mbg_chk_tstamp64_leap_sec( &t_now, &xhrt_vars.htc.t.status );
  }

  if ( tstamp )
    *tstamp = t_now;

  if ( vars )
    *vars = xhrt_vars;

  return ioctl_status;

}  // mbg_get_xhrt_data



/*HDR*/
/**
    Retrieve a time stamp in PCPS_HR_TIME format which is extrapolated
    using the system's current cycles counter value and a time stamp 
    plus associated cycles counter value saved by the polling thread.
    See mbg_xhrt_poll_thread_fnc() for details and limitations.
    This function is only implemented for targets which support threads.

    @param *p Pointer to a ::MBG_XHRT_INFO structure used to retrieve data from the polling thread.
    @param *p_hrt Pointer to a ::PCPS_HR_TIME structure to be filled up.

    @return MBG_SUCCESS or another return value from the polling thread's IOCTL call.

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_filetime()
    @see mbg_get_xhrt_cycles_frequency()
  */
_MBG_API_ATTR int _MBG_API mbg_get_xhrt_time_as_pcps_hr_time( MBG_XHRT_INFO *p, PCPS_HR_TIME *p_hrt )
{
  uint64_t tstamp64;
  MBG_XHRT_VARS xhrt_vars;

  int rc = mbg_get_xhrt_data( p, &tstamp64, &xhrt_vars );

  // Even if an IOCTL error has occurred recently in the polling thread
  // the interpolation may still work correctly. So we just continue
  // normally but pass the return code on to the calling function.

  uint64_to_pcps_time_stamp( &p_hrt->tstamp, tstamp64 );

  // Update status (valid only for the previous second!)
  p_hrt->signal   = xhrt_vars.htc.t.signal;
  p_hrt->status   = xhrt_vars.htc.t.status;
  p_hrt->utc_offs = xhrt_vars.htc.t.utc_offs;

  return rc;

}  // mbg_get_xhrt_time_as_pcps_hr_time



#if defined( MBG_TGT_WIN32 )

/*HDR*/
/**
    Retrieve a time stamp in FILETIME format which is extrapolated
    using the system's current cycles counter value and a time stamp 
    plus associated cycles counter value saved by the polling thread.
    See mbg_xhrt_poll_thread_fnc() for details and limitations.
    Since FILETIME is a Windows specific type this function is only 
    implemented under Windows.

    @param *p Pointer to a ::MBG_XHRT_INFO structure used to retrieve data from the polling thread.
    @param *p_ft Pointer to a ::FILETIME structure to be filled up.

    @return MBG_SUCCESS or another return value from the polling thread's IOCTL call.

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_cycles_frequency()
  */
_MBG_API_ATTR int _MBG_API mbg_get_xhrt_time_as_filetime( MBG_XHRT_INFO *p, FILETIME *p_ft )
{
  uint64_t tstamp64;

  int rc = mbg_get_xhrt_data( p, &tstamp64, NULL );

  // Even if an IOCTL error has occurred recently in the polling thread
  // the interpolation may still work correctly. So we just continue
  // normally but pass the return code on to the calling function.

  mbg_pcps_tstamp64_to_filetime( p_ft, &tstamp64 );

  return rc;

}  // mbg_get_xhrt_time_as_filetime

#endif



/*HDR*/
/**
    Retrieve the frequency of the system's cycles counter as determined
    by the device polling thread.
    See mbg_xhrt_poll_thread_fnc() for details and limitations.
    This function is only implemented for targets which support threads.

    @param *p Pointer to a ::MBG_XHRT_INFO structure used to retrieve data from the polling thread.
    @param *p_freq_hz Pointer to a ::MBG_PC_CYCLES_FREQUENCY variable in which the frequency is returned.
    @return a status code from the polling thread: MBG_SUCCESS or an IOCTL error code.

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_time_as_filetime()
  */
_MBG_API_ATTR int _MBG_API mbg_get_xhrt_cycles_frequency( MBG_XHRT_INFO *p, MBG_PC_CYCLES_FREQUENCY *p_freq_hz )
{
  MBG_PC_CYCLES_FREQUENCY freq_hz;
  int ioctl_status;

  _mbg_crit_sect_enter( &p->crit_sect );
  freq_hz = p->freq_hz;
  ioctl_status = p->ioctl_status;
  _mbg_crit_sect_leave( &p->crit_sect );

  if ( p_freq_hz )
    *p_freq_hz = freq_hz;

  return ioctl_status;

}  // mbg_get_xhrt_cycles_frequency

#endif // defined MBGDEVIO_USE_THREAD_API



/*HDR*/
/**
    Retrieve the default system's cycles counter frequency from the kernel driver. 

    @param dh handle of the device to which the IOCTL call is sent.
    @param *p Pointer of a ::MBG_PC_CYCLES_FREQUENCY variable to be filled up.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_default_cycles_frequency()
  */
_MBG_API_ATTR int _MBG_API mbg_get_default_cycles_frequency_from_dev( MBG_DEV_HANDLE dh, MBG_PC_CYCLES_FREQUENCY *p )
{
  #if defined( _MBGIOCTL_H )
    _mbgdevio_vars();
    rc = _mbgdevio_read_var( dh, -1, IOCTL_GET_CYCLES_FREQUENCY, p );
    // native endianess, no need to swap bytes
    if ( rc != MBG_SUCCESS )
      *p = 0;

    #if defined( MBG_TGT_LINUX )
      if ( *p == 0 )
      {
        int has_hr_time = 0;

        rc = mbg_dev_has_hr_time( dh, &has_hr_time );

        if ( rc != MBG_SUCCESS )
          goto done;

        if ( has_hr_time )
        {
          PCPS_HR_TIME_CYCLES htc1;
          PCPS_HR_TIME_CYCLES htc2;
          double delta_cycles;
          double delta_t;

          rc = mbg_get_hr_time_cycles( dh, &htc1 );

          if ( rc != MBG_SUCCESS )
            goto done;

          sleep( 1 );

          rc = mbg_get_hr_time_cycles( dh, &htc2 );

          if ( rc != MBG_SUCCESS )
            goto done;

          // compute cycles frequency from delta htc
          delta_cycles = mbg_delta_pc_cycles( &htc2.cycles, &htc1.cycles );
          delta_t = pcps_time_stamp_to_uint64( &htc2.t.tstamp ) - pcps_time_stamp_to_uint64( &htc1.t.tstamp );
          *p = ( delta_cycles * PCPS_HRT_BIN_FRAC_SCALE ) / delta_t;
        }
      }
done:
    #endif

    return _mbgdevio_ret_val;

  #else

    *p = 0;

    return _mbg_err_to_os( MBG_ERR_NOT_SUPP_ON_OS );

  #endif

}  // mbg_get_default_cycles_frequency_from_dev



/*HDR*/
/**
  Retrieve the default system's cycles counter frequency.

  @note This may not be supported on all target platforms, in which case the
  returned frequency is 0 and the mbg_get_default_cycles_frequency_from_dev()
  call should be used.

  @return the default cycles counter frequency in Hz, or 0 if the value is not available.

  @see mbg_get_default_cycles_frequency_from_dev()
*/
_MBG_API_ATTR MBG_PC_CYCLES_FREQUENCY _MBG_API mbg_get_default_cycles_frequency( void )
{
  #if defined MBG_TGT_WIN32

    MBG_PC_CYCLES_FREQUENCY pc_cycles_frequency;

    mbg_get_pc_cycles_frequency( &pc_cycles_frequency );

    return pc_cycles_frequency;

  #else

    return 0;

  #endif

}  // mbg_get_default_cycles_frequency



#if defined( MBG_TGT_WIN32 )

#if defined( _USRDLL )

BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved )
{
  if ( ul_reason_for_call == DLL_PROCESS_ATTACH )
    mbg_svc_register_event_source( MBG_APP_EVTLOG_NAME_MBGDEVIO_DLL );

  return TRUE;
}

#endif // defined( _USRDLL )

#endif  // defined( MBG_TGT_WIN32 )

