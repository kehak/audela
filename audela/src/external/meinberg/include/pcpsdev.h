
/**************************************************************************
 *
 *  $Id: pcpsdev.h,v 1.1 2011-02-23 14:19:10 myrtillelaas Exp $
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
 *  $Log: not supported by cvs2svn $
 *  Revision 1.45  2009/06/19 12:15:18Z  martin
 *  Added has_irig_time feature and associated macros.
 *  Revision 1.44  2009/06/08 19:30:48  daniel
 *  Account for new features PCPS_HAS_LAN_INTF and
 *  PCPS_HAS_PTP.
 *  Revision 1.43  2009/04/08 08:26:20  daniel
 *  Define firmware version at which the TCR511PCI starts
 *  to support Irig control bits.
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

#include <pcpsdefs.h>
#include <gpsdefs.h>
#include <usbdefs.h>
#include <mbg_tgt.h>
#include <use_pack.h>



/* Start of header body */

#if defined( _USE_PACK )   // set byte alignment
  #pragma pack( 1 )
#endif



#if defined( MBG_TGT_WIN32 )

  // used with QueryPerformanceCounter()
  typedef int64_t MBG_PC_CYCLES;
  typedef uint64_t MBG_PC_CYCLES_FREQUENCY;

#elif defined( MBG_TGT_LINUX )

  typedef uint64_t MBG_PC_CYCLES;
  typedef uint64_t MBG_PC_CYCLES_FREQUENCY;

#elif defined( MBG_TGT_OS2 )

  typedef uint32_t MBG_PC_CYCLES;  //##++ should differentiate more
  typedef uint32_t MBG_PC_CYCLES_FREQUENCY;

#elif defined( MBG_TGT_DOS )

  typedef uint32_t MBG_PC_CYCLES;  //##++ should differentiate more
  typedef uint32_t MBG_PC_CYCLES_FREQUENCY;
  #define MBG_MEM_ADDR  uint32_t   // 64 bit not supported, nor required.

#else // other target OSs which access the hardware directly

  typedef uint32_t MBG_PC_CYCLES;  //##++ should differentiate more
  typedef uint32_t MBG_PC_CYCLES_FREQUENCY;

#endif


// MBG_PC_CYCLES and MBG_PC_CYCLES_FREQUENCY are always read in native 
// machine endianess, so no endianess conversion is required.
#define _mbg_swab_mbg_pc_cycles( _p ) \
  _nop_macro_fnc()

#define _mbg_swab_mbg_pc_cycles_frequency( _p ) \
  _nop_macro_fnc()



#if defined( MBG_TGT_LINUX ) && defined( MBG_ARCH_I386 )

  static __mbg_inline unsigned long long int mbg_rdtscll( void )
  {
    // The code below is a hack to get around issues with
    // different versions of gcc.
    //
    // Normally the inline asm code could look similar to:
    //
    //     __asm__ volatile ( "rdtsc" : "=A" (x) )
    //
    // which would copy the output regs edx:eax as a 64 bit
    // number to a variable x.
    //
    // The "=A" expression should implicitely tell the compiler
    // the edx and eax registers have been clobbered. However,
    // this does not seem to work properly at least with gcc 4.1.2
    // shipped with Centos 5.
    //
    // If optimization level 1 or higher is used then function
    // parameters are also passed in registers. If the inline
    // code above is used inside a function then the edx register
    // is clobbered but the gcc 4.1.2 is not aware of this and
    // assumes edx is unchanged, which may yield faulty results
    // or even lead to segmentation faults.
    //
    // A possible workaround could be to mark edx explicitely as
    // being clobbered in the asm inline code, but unfortunately
    // other gcc versions report an error if a register which is
    // implicitely (by "=A") known to be clobbered is also listed
    // explicitely to be clobbered.
    //
    // So the code below is a workaround which tells the compiler
    // implicitely that the eax ("=a") and edx ("=d") registers
    // are being used and thus clobbered.

    union
    {
      struct
      {
        uint32_t lo;
        uint32_t hi;
      } u32;

      uint64_t u64;

    } tsc_val;

    __asm__ __volatile__( "rdtsc" : "=a" (tsc_val.u32.lo), "=d" (tsc_val.u32.hi) );

    return tsc_val.u64;

  }  // mbg_rdtscll

#endif



static __mbg_inline
void mbg_get_pc_cycles( MBG_PC_CYCLES *p )
{
  #if defined( MBG_TGT_WIN32 )

    #if defined( _KDD_ )  // kernel space
      *p = (MBG_PC_CYCLES) KeQueryPerformanceCounter( NULL ).QuadPart;
    #else                 // user space
      QueryPerformanceCounter( (LARGE_INTEGER *) p );
    #endif

  #elif defined( MBG_TGT_LINUX ) && defined( MBG_ARCH_I386 )

    #if 0 && ( defined( CONFIG_X86_TSC ) || defined( CONFIG_M586TSC ) )  //##++++
      #define _pcps_get_cycles( _c ) \
        _c = get_cycles()
    #else
      *p = mbg_rdtscll();
    #endif

  #else

    *p = 0;

  #endif

}  // mbg_get_pc_cycles



static __mbg_inline
void mbg_get_pc_cycles_frequency( MBG_PC_CYCLES_FREQUENCY *p )
{
  #if defined( MBG_TGT_WIN32 )
    LARGE_INTEGER li;

    #if defined( _KDD_ )  // kernel space
      KeQueryPerformanceCounter( &li );
    #else                 // user space
      QueryPerformanceFrequency( &li );
    #endif

    *p = li.QuadPart;

  #elif defined( MBG_TGT_LINUX )

    #if defined( __KERNEL__ ) && defined( MBG_ARCH_I386 )
      *p = ( cpu_khz * 1000 );
    #else
      *p = 0;
    #endif

  #else

    *p = 0;

  #endif

}  // mbg_get_pc_cycles_frequency



static __mbg_inline
MBG_PC_CYCLES mbg_delta_pc_cycles( const MBG_PC_CYCLES *p1, const MBG_PC_CYCLES *p2 )
{
#if defined( MBG_ARCH_SPARC )
  // cycle counts are currently not supported under SPARC, so we always return 0.
  return 0;
#else
  return *p1 - *p2;
#endif

}  // mbg_delta_pc_cycles



#if !defined( MBG_MEM_ADDR )
  // By default a memory address is stored
  // as a 64 bit quantitiy.
  #define MBG_MEM_ADDR  uint64_t
#endif


typedef uint8_t PCPS_STATUS_PORT;  /**< see \ref group_status_port "Bitmask" */
typedef uint8_t MBG_DBG_DATA;
typedef uint16_t MBG_DBG_PORT;


// ------ definitions used when accessing a clock -------------------
//  (also refer to pcpsdefs.h for more common definitions)

/** @defgroup group_status_port Bit masks of PCPS_STATUS_PORT

    These bits are ored with the #PCPS_STATUS_PORT byte.

    The flags #PCPS_ST_SEC and #PCPS_ST_MIN are cleared whenever the clock
    is read, so they are very unreliable in multitasking environments
    and should therefore be ignored.

    <b>NOTE</b>: On the PCI510 card the signal #PCPS_ST_IRQF has unintentionally
    not been wired. Functions which check if a card has triggered an IRQ 
    should check the PCI_ASIC_PCI_IRQF flag provided by the PCI interface.
    The macros used by the mbglib driver library already do so.
 *  @{
 */
 
#define PCPS_ST_BUSY  0x01  /**< the clock is busy filling the output FIFO */
#define PCPS_ST_IRQF  0x02  /**< the clock has generated an IRQ on the PC bus */
#define PCPS_ST_MOD   0x20  /**< the DCF77 modulation */
#define PCPS_ST_SEC   0x40  /**< Seconds have changed since last reading */
#define PCPS_ST_MIN   0x80  /**< Minutes have changed since last reading */

/** @} */

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

// S5920 PCI interface chip.
#define PCPS_BUS_PCI_CHIP_S5920    0x8000

// Meinberg's own PCI interface chip.
#define PCPS_BUS_PCI_CHIP_ASIC     0x4000

// PEX8311 PCI Express interface chip
#define PCPS_BUS_PCI_CHIP_PEX8311  0x2000


// The constant below combines the PCI bus flags.
#define PCPS_BUS_PCI_S5933    ( PCPS_BUS_PCI )
#define PCPS_BUS_PCI_S5920    ( PCPS_BUS_PCI | PCPS_BUS_PCI_CHIP_S5920 )
#define PCPS_BUS_PCI_ASIC     ( PCPS_BUS_PCI | PCPS_BUS_PCI_CHIP_ASIC )
#define PCPS_BUS_PCI_PEX8311  ( PCPS_BUS_PCI | PCPS_BUS_PCI_CHIP_PEX8311 )



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



#if MBG_USE_MM_IO_FOR_PCI
  typedef uint64_t PCPS_PORT_ADDR;
#else
  typedef uint16_t PCPS_PORT_ADDR;
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
  ulong len;
  #if defined( MBG_TGT_LINUX )
    uint32_t pfn_offset;
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
#define PCPS_CAN_SET_TIME       0x00000001UL
#define PCPS_HAS_SERIAL         0x00000002UL
#define PCPS_HAS_SYNC_TIME      0x00000004UL
#define PCPS_HAS_TZDL           0x00000008UL
#define PCPS_HAS_IDENT          0x00000010UL
#define PCPS_HAS_UTC_OFFS       0x00000020UL
#define PCPS_HAS_HR_TIME        0x00000040UL
#define PCPS_HAS_SERNUM         0x00000080UL
#define PCPS_HAS_TZCODE         0x00000100UL
#define PCPS_HAS_CABLE_LEN      0x00000200UL
#define PCPS_HAS_EVENT_TIME     0x00000400UL  // custom GPS firmware only
#define PCPS_HAS_RECEIVER_INFO  0x00000800UL
#define PCPS_CAN_CLR_UCAP_BUFF  0x00001000UL
#define PCPS_HAS_PCPS_TZDL      0x00002000UL
#define PCPS_HAS_UCAP           0x00004000UL
#define PCPS_HAS_IRIG_TX        0x00008000UL
#define PCPS_HAS_GPS_DATA_16    0x00010000UL  // use 16 bit size specifiers
#define PCPS_HAS_SYNTH          0x00020000UL
#define PCPS_HAS_GENERIC_IO     0x00040000UL
#define PCPS_HAS_TIME_SCALE     0x00080000UL
#define PCPS_HAS_UTC_PARM       0x00100000UL
#define PCPS_HAS_IRIG_CTRL_BITS 0x00200000UL
#define PCPS_HAS_LAN_INTF       0x00400000UL
#define PCPS_HAS_PTP            0x00800000UL
#define PCPS_HAS_IRIG_TIME      0x01000000UL
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

// Some features of the API used to access Meinberg plug-in radio clocks
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


/* command PCPS_GIVE_IRIG_TIME: */
#define REV_HAS_IRIG_TIME_TCR511PEX 0x0109
#define REV_HAS_IRIG_TIME_TCR511PCI 0x0109

/* command PCPS_GET_IRIG_CTRL_BITS: */
#define REV_HAS_IRIG_CTRL_BITS_TCR511PEX 0x0107
#define REV_HAS_IRIG_CTRL_BITS_TCR511PCI 0x0107

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

#define _pcps_is_isa( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_ISA )
#define _pcps_is_mca( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_MCA )
#define _pcps_is_pci( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_PCI )
#define _pcps_is_usb( _d )       ( _pcps_bus_flags( _d ) & PCPS_BUS_USB )

#define _pcps_is_pci_s5933( _d )    ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_S5933 )
#define _pcps_is_pci_s5920( _d )    ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_S5920 )
#define _pcps_is_pci_amcc( _d )     ( _pcps_is_pci_s5920( _d ) || _pcps_is_pci_s5933( _d )  )
#define _pcps_is_pci_asic( _d )     ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_ASIC )
#define _pcps_is_pci_pex8311( _d )  ( _pcps_bus_flags( _d ) == PCPS_BUS_PCI_PEX8311 )


// Access device configuration information:
#define _pcps_bus_num( _d )      ( (_d)->cfg.bus_num )
#define _pcps_slot_num( _d )     ( (_d)->cfg.slot_num )

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
#define _pcps_fw_id( _d )              ( (_d)->cfg.fw_id )
#define _pcps_sernum( _d )             ( (_d)->cfg.sernum )


// The macros below handle the clock device's err_flags.
#define _pcps_err_flags( _d )           ( (_d)->cfg.err_flags )
#define _pcps_chk_err_flags( _d, _msk ) ( _pcps_err_flags( _d ) & (_msk) )
#define _pcps_set_err_flags( _d, _msk ) ( _pcps_err_flags( _d ) |= (_msk) )
#define _pcps_clr_err_flags( _d, _msk ) ( _pcps_err_flags( _d ) &= ~(_msk) )


// Query whether a special feature is supported:
#define _pcps_has_feature( _d, _f ) ( ( (_d)->cfg.features & (_f) ) != 0 )
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

#define _pcps_has_lan_intf( _d )  _pcps_has_feature( (_d), PCPS_HAS_LAN_INTF )

#define _pcps_has_ptp( _d )  _pcps_has_feature( (_d), PCPS_HAS_PTP )


#define _pcps_has_asic_version( _d ) ( _pcps_is_pci_asic( _d ) || _pcps_is_pci_pex8311( _d ) )

#define _pcps_has_asic_features( _d ) _pcps_has_asic_version( _d )


/** 
  The structure is used to return info
  on the device driver.*/
typedef struct
{
  uint16_t ver_num;    /**< the device driver's version number */
  uint16_t n_devs;     /**< the number of radio clocks handled by the driver */
  PCPS_ID_STR id_str;  /**< the device driver's ID string */
} PCPS_DRVR_INFO;



/*
 * The definitions and types below are used to collect
 * all configuration parameters of a clock's serial ports
 * that can be handled by this library:
 */

// The maximum number of clocks' serial ports and string types
// that can be handled by the configuration programs:
#define MAX_PARM_PORT        4
#define MAX_PARM_STR_TYPE    20

typedef PORT_INFO_IDX ALL_PORT_INFO[MAX_PARM_PORT];
typedef STR_TYPE_INFO_IDX ALL_STR_TYPE_INFO[MAX_PARM_STR_TYPE];

typedef struct
{
  ALL_PORT_INFO pii;
  ALL_STR_TYPE_INFO stii;
  PORT_PARM tmp_pp;

} RECEIVER_PORT_CFG;



/*
 * The definitions and types below are used to collect
 * all configuration parameters of a clock's programmable
 * pulse outputs that can be handled by this library:
 */

#define MAX_PARM_POUT        4

typedef POUT_INFO_IDX ALL_POUT_INFO[MAX_PARM_POUT];



// The macros below can be used to mark a PCPS_TIME variable
// as unread, i.e. its contents have not been read from the clock,
// and to check if such a variable is marked as unread.
#define _pcps_time_set_unread( _t );      { (_t)->sec = 0xFF; }
#define _pcps_time_is_read( _t )          ( (uchar) (_t)->sec != 0xFF )



/**
 The structure is used to read current time from
 a device, combined with an associated PC cycle counter value
 to compensate program execution time. The cycle counter value
 is usually derived from the PC CPU's TSC and the type is
 redefined to a common type, depending on the operating system.
 The cycle counter clock frequency usually corresponds to the
 PC CPU clock frequency.*/
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
 The structure is used to read current high resolution time from
 a device, combined with an associated PC cycle counter value
 to compensate program execution time. The cycle counter value
 is usually derived from the PC CPU's TSC and the type is
 redefined to a common type, depending on the operating system.
 The cycle counter clock frequency usually corresponds to the
 PC CPU clock frequency.*/
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


#if defined( _USE_PACK )   // set default alignment
  #pragma pack()
#endif

/* End of header body */

#undef _ext

#endif  /* _PCPSDEV_H */

