
/**************************************************************************
 *
 *  $Id: mbgpccyc.h 1.1.1.6 2011/12/19 16:14:13 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Portable macros to get a machine's current cycle count.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgpccyc.h $
 *  Revision 1.1.1.6  2011/12/19 16:14:13  martin
 *  Revision 1.1.1.5  2011/09/21 14:25:39  martin
 *  Use get_cycles() in Linux kernel mode if no special cycles support
 *  is provided for the given hardware platform.
 *  Revision 1.1.1.4  2011/07/20 15:58:53  martin
 *  Support cycles on IA64 only in kernel space.
 *  Revision 1.1.1.3  2011/07/13 09:44:49  martin
 *  Moved IA64 includes from pcpsdev.h to mbgpccyc.h.
 *  Revision 1.1.1.2  2011/07/06 13:23:36  martin
 *  Revision 1.1.1.1  2011/07/05 12:25:08  martin
 *  Revision 1.1  2011/06/23 15:36:07  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _MBGPCCYC_H
#define _MBGPCCYC_H


/* Other headers to be included */

#include <mbg_tgt.h>
#include <words.h>

#if defined( MBG_TGT_NETBSD )
  #if defined( MBG_TGT_KERNEL )
    #include <machine/cpu.h>
    #include <machine/cpu_counter.h>  /* for cycle counter abstraction */
  #endif
#endif

#if defined( MBG_TGT_FREEBSD )
  #if defined( MBG_TGT_KERNEL )
    #if defined( MBG_ARCH_X86 )
      #include <machine/clock.h>  /* for symbol 'tsc_freq' */
    #endif
  #endif
#endif

#if defined( MBG_TGT_LINUX )
  #if defined( MBG_ARCH_IA64 ) && defined( MBG_TGT_KERNEL )
    #include <asm/ia64regs.h>
  #endif
#endif


#ifdef _MBGPCCYC
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

/**
 * @brief Generic types to hold PC cycle counter values.
 *
 * The cycle counter value is usually derived from the PC CPU's TSC or some other
 * timer hardware on the mainboard.
 */
#if defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_UNIX )

  typedef int64_t MBG_PC_CYCLES;
  typedef uint64_t MBG_PC_CYCLES_FREQUENCY;

#else

  typedef uint32_t MBG_PC_CYCLES;
  typedef uint32_t MBG_PC_CYCLES_FREQUENCY;

#endif


// MBG_PC_CYCLES and MBG_PC_CYCLES_FREQUENCY are always read in native
// machine endianess, so no endianess conversion is required.
#define _mbg_swab_mbg_pc_cycles( _p ) \
  _nop_macro_fnc()

#define _mbg_swab_mbg_pc_cycles_frequency( _p ) \
  _nop_macro_fnc()



#if ( defined( MBG_TGT_LINUX ) || defined( MBG_TGT_BSD ) ) && defined( MBG_ARCH_X86 )

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
#if !defined( OMIT_PC_CYCLES_SUPPORT )

  #if defined( MBG_TGT_WIN32 )

    #if defined( MBG_TGT_KERNEL )  // kernel space
      *p = (MBG_PC_CYCLES) KeQueryPerformanceCounter( NULL ).QuadPart;
    #else                          // user space
      QueryPerformanceCounter( (LARGE_INTEGER *) p );
    #endif

    #define MBG_PC_CYCLES_SUPPORTED  1

  #elif defined( MBG_TGT_LINUX ) && defined( MBG_ARCH_X86 )

    *p = mbg_rdtscll();
    #define MBG_PC_CYCLES_SUPPORTED  1

  #elif defined( MBG_TGT_LINUX ) && defined( MBG_ARCH_IA64 ) && defined( MBG_TGT_KERNEL )

    unsigned long result = ia64_getreg( _IA64_REG_AR_ITC );
    ia64_barrier();

    #ifdef CONFIG_ITANIUM
      while (unlikely((__s32) result == -1)) {
        result = ia64_getreg(_IA64_REG_AR_ITC);
        ia64_barrier();
      }
    #endif

    *p = result;

    #define MBG_PC_CYCLES_SUPPORTED  1

  #elif defined( MBG_TGT_LINUX ) && defined( MBG_TGT_KERNEL )

    *p = get_cycles();
    #define MBG_PC_CYCLES_SUPPORTED  1

  #elif defined( MBG_TGT_FREEBSD ) && defined( MBG_ARCH_X86 )

    *p = mbg_rdtscll();

    #define MBG_PC_CYCLES_SUPPORTED  1

  #elif defined( MBG_TGT_NETBSD ) && defined ( MBG_TGT_KERNEL )

    *p = cpu_counter();  //##++ or cpu_counter_serializing()

    #define MBG_PC_CYCLES_SUPPORTED  1

  #endif

#endif


  #if !defined( MBG_PC_CYCLES_SUPPORTED )

    *p = 0;
    #define MBG_PC_CYCLES_SUPPORTED  0

  #endif

}  // mbg_get_pc_cycles



static __mbg_inline
void mbg_get_pc_cycles_frequency( MBG_PC_CYCLES_FREQUENCY *p )
{
  #if defined( MBG_TGT_WIN32 )
    LARGE_INTEGER li;

    #if defined( MBG_TGT_KERNEL )  // kernel space
      KeQueryPerformanceCounter( &li );
    #else                          // user space
      QueryPerformanceFrequency( &li );
    #endif

    *p = li.QuadPart;

  #elif defined( MBG_TGT_LINUX ) && defined( MBG_ARCH_X86 ) && defined( MBG_TGT_KERNEL )

    *p = ( cpu_khz * 1000 );

  #elif defined( MBG_TGT_LINUX ) && defined( MBG_ARCH_IA64 )

    // we probably can use
    // ia64_sal_freq_base(unsigned long which, unsigned long *ticks_per_second,
    //                    unsigned long *drift_info)
    // However, this is not tested.

    *p = 0;

  #elif defined( MBG_TGT_FREEBSD ) && defined( MBG_ARCH_X86 ) && defined( MBG_TGT_KERNEL )

    *p = tsc_freq;

  #elif defined( MBG_TGT_NETBSD ) && defined( MBG_TGT_KERNEL )

    *p = cpu_frequency( curcpu() );

  #else

    *p = 0;

  #endif

}  // mbg_get_pc_cycles_frequency



static __mbg_inline
MBG_PC_CYCLES mbg_delta_pc_cycles( const MBG_PC_CYCLES *p1, const MBG_PC_CYCLES *p2 )
{
#if 0 && !MBG_PC_CYCLES_SUPPORTED
  // Cycle counts not supported on this target platform.
  // Under SPARC this may even result in bus errors
  // due to alignment of the underlying data structures.
  return 0;
#else
  return *p1 - *p2;
#endif

}  // mbg_delta_pc_cycles



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

/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _MBGPCCYC */
