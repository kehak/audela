
/**************************************************************************
 *
 *  $Id: mbggenio.h 1.5.1.4.1.1 2011/11/16 10:15:12 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions for generic port I/O.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbggenio.h $
 *  Revision 1.5.1.4.1.1  2011/11/16 10:15:12  martin
 *  Tmp. debug code.
 *  Revision 1.5.1.4  2011/10/05 08:57:20  martin
 *  Fixed includes for NetBSD.
 *  Revision 1.5.1.3  2011/02/09 17:08:30  martin
 *  Specify I/O range number when calling port I/O macros
 *  so they can be used for different ranges under BSD.
 *  Revision 1.5.1.2  2011/02/01 12:12:18  martin
 *  Revision 1.5.1.1  2011/01/31 17:29:26  martin
 *  Account for modified resource handling under *BSD.
 *  Revision 1.5  2008/12/05 13:27:33  martin
 *  Generally put macro arguments in brackets for evaluation
 *  to avoid potential side effects.
 *  There has been a problem with an improper written outp() macro
 *  in the Borland C 3.1 library's conio.h file.
 *  Support mapped I/O resources.
 *  Revision 1.4  2008/02/05 13:38:57  martin
 *  Added support for QNX.
 *  Revision 1.3  2007/03/21 14:48:56  martin
 *  Use standard inp(), outp() also under Windows since the generic
 *  Windows functions READ_PORT_UCHA(), etc., are not very
 *  compatible across DDK versions.
 *  Revision 1.2  2007/03/02 10:23:34Z  martin
 *  Renamed generic port I/O macros.
 *  Fully support Linux, *BSD, Windows, NetWare, DOS, and OS/2.
 *  Revision 1.1  2006/09/20 10:47:21  martin
 *
 **************************************************************************/

#ifndef _MBGGENIO_H
#define _MBGGENIO_H


/* Other headers to be included */

#include <mbg_arch.h>


/* Start of header body */

#ifdef __cplusplus
extern "C" {
#endif


#if defined( MBG_TGT_LINUX )

  #define MBG_LOG_PCI_IO   0

  #if MBG_USE_MM_IO_FOR_PCI
    #define _mbg_inp8( _d, _i, _p )        ( readb( (_p) ) )
    #define _mbg_inp16( _d, _i, _p )       ( readw( (_p) ) )
    #define _mbg_inp32( _d, _i, _p )       ( readl( (_p) ) )

    #define _mbg_outp8( _d, _i, _p, _v )   writeb( (_v), (_p) )
    #define _mbg_outp16( _d, _i, _p, _v )  writew( (_v), (_p) )
    #define _mbg_outp32( _d, _i, _p, _v )  writel( (_v), (_p) )
  #elif MBG_LOG_PCI_IO
    static __mbg_inline uint8_t mbg_inp8( int addr ) __attribute__((always_inline));
    static __mbg_inline uint8_t mbg_inp8( int addr )
    {
      uint8_t ret_val = (uint8_t) inb( addr );
//      printk( KERN_INFO "inp8 %04X: %02X\n", addr, ret_val );
      return ret_val;
    }

    static __mbg_inline uint16_t mbg_inp16( int addr ) __attribute__((always_inline));
    static __mbg_inline uint16_t mbg_inp16( int addr )
    {
      uint16_t ret_val = (uint16_t) inw( addr );
//      printk( KERN_INFO "inp16 %04X: %04X\n", addr, ret_val );
      return ret_val;
    }

    static __mbg_inline uint32_t mbg_inp32( int addr ) __attribute__((always_inline));
    static __mbg_inline uint32_t mbg_inp32( int addr )
    {
      uint32_t ret_val = (uint32_t) inl( addr );
//      printk( KERN_INFO "inp32 %04X: %08X\n", addr, ret_val );
      return ret_val;
    }

    static __mbg_inline void mbg_outp8( uint8_t val, int addr ) __attribute__((always_inline));
    static __mbg_inline void mbg_outp8( uint8_t val, int addr )
    {
//      printk( KERN_INFO "outp8 %02X -> %04X\n", val, addr );
      outb( val, addr );
    }

    static __mbg_inline void mbg_outp16( uint16_t val, int addr ) __attribute__((always_inline));
    static __mbg_inline void mbg_outp16( uint16_t val, int addr )
    {
//      printk( KERN_INFO "outp16 %04X -> %04X\n", val, addr );
      outw( val, addr );
    }

    static __mbg_inline void mbg_outp32( uint32_t val, int addr ) __attribute__((always_inline));
    static __mbg_inline void mbg_outp32( uint32_t val, int addr )
    {
//      printk( KERN_INFO "outp32 %08X -> %04X\n", val, addr );
      outl( val, addr );
    }

    #define _mbg_inp8( _d, _i, _p )        mbg_inp8(_p)
    #define _mbg_inp16( _d, _i, _p )       mbg_inp16(_p)
    #define _mbg_inp32( _d, _i, _p )       mbg_inp32(_p)

    #define _mbg_outp8( _d, _i, _p, _v )   mbg_outp8( (_v), (_p) )
    #define _mbg_outp16( _d, _i, _p, _v )  mbg_outp16( (_v), (_p) )
    #define _mbg_outp32( _d, _i, _p, _v )  mbg_outp32( (_v), (_p) )
  #else
    #define _mbg_inp8( _d, _i, _p )        ( (uint8_t) inb( (_p) ) )
    #define _mbg_inp16( _d, _i, _p )       ( (uint16_t) inw( (_p) ) )
    #define _mbg_inp32( _d, _i, _p )       ( (uint32_t) inl( (_p) ) )

    #define _mbg_outp8( _d, _i, _p, _v )   outb( (_v), (_p) )
    #define _mbg_outp16( _d, _i, _p, _v )  outw( (_v), (_p) )
    #define _mbg_outp32( _d, _i, _p, _v )  outl( (_v), (_p) )
  #endif

#elif defined( MBG_TGT_BSD )
  #include <sys/param.h>
  #include <sys/types.h>
  #include <sys/bus.h>
  #if !defined(__NetBSD_Version__) || __NetBSD_Version__ < 599005500
    #include <machine/bus.h>
  #endif

  #define _mbg_inp8( _d, _i, _p )        ( (uint8_t) bus_space_read_1( ( (_d)->rsrc_info.port[_i].bsd.bst ), \
                                           ( (_d)->rsrc_info.port[_i].bsd.bsh ), (_p) ) )
  #define _mbg_inp16( _d, _i, _p )       ( (uint16_t) bus_space_read_2( ( (_d)->rsrc_info.port[_i].bsd.bst ), \
                                           ( (_d)->rsrc_info.port[_i].bsd.bsh ), (_p) ) )
  #define _mbg_inp32( _d, _i, _p )       ( (uint32_t) bus_space_read_4( ( (_d)->rsrc_info.port[_i].bsd.bst), \
                                           ( (_d)->rsrc_info.port[_i].bsd.bsh ), (_p) ) )

  #define _mbg_outp8( _d, _i, _p, _v )   bus_space_write_1( ( (_d)->rsrc_info.port[_i].bsd.bst ), \
                                           ( (_d)->rsrc_info.port[_i].bsd.bsh ), (_p), (_v) )
  #define _mbg_outp16( _d, _i, _p, _v )  bus_space_write_2( ( (_d)->rsrc_info.port[_i].bsd.bst ), \
                                           ( (_d)->rsrc_info.port[_i].bsd.bsh ), (_p), (_v) )
  #define _mbg_outp32( _d, _i, _p, _v )  bus_space_write_4( ( (_d)->rsrc_info.port[_i].bsd.bst ), \
                                           ( (_d)->rsrc_info.port[_i].bsd.bsh ), (_p), (_v) )

#elif defined( MBG_TGT_WIN32 )

  #define _mbg_inp8( _d, _i, _p )        ( (uint8_t) inp( (_p) ) )
  #define _mbg_inp16( _d, _i, _p )       ( (uint16_t) inpw( (_p) ) )
  #define _mbg_inp32( _d, _i, _p )       ( (uint32_t) inpd( (_p) ) )

  #define _mbg_outp8( _d, _i, _p, _v )   outp( (_p), (_v) )
  #define _mbg_outp16( _d, _i, _p, _v )  outpw( (_p), (_v) )
  #define _mbg_outp32( _d, _i, _p, _v )  outpd( (_p), (_v) )

#elif defined( MBG_TGT_DOS ) || defined( MBG_TGT_NETWARE ) || defined( MBG_TGT_OS2 )

  #include <conio.h>

  #if defined( MBG_TGT_DOS ) || defined( MBG_TGT_OS2 )
    #include <xportio.h>
  #endif

  #define _mbg_inp8( _d, _i, _p )        ( (uint8_t) inp( (_p) ) )
  #define _mbg_inp16( _d, _i, _p )       ( (uint16_t) inpw( (_p) ) )
  #define _mbg_inp32( _d, _i, _p )       ( (uint32_t) inpd( (_p) ) )

  #define _mbg_outp8( _d, _i, _p, _v )   outp( (_p), (_v) )
  #define _mbg_outp16( _d, _i, _p, _v )  outpw( (_p), (_v) )
  #define _mbg_outp32( _d, _i, _p, _v )  outpd( (_p), (_v) )

#elif defined( MBG_TGT_QNX )

  #if defined( MBG_TGT_QNX_NTO )   // compiling for QNX Neutrino
    // don't know if we have to distinguish between different compilers
    #include <hw/inout.h>

    // ATTENTION: mmap_device_io() must be called on non-x86 architectures
    // to remap the ports, otherwise a segmentation fault will occur if
    // the port I/O functions are being called.

    #define _mbg_inp8( _d, _i, _p )        ( (uint8_t) in8( (_p) ) )
    #define _mbg_inp16( _d, _i, _p )       ( (uint16_t) in16( (_p) ) )
    #define _mbg_inp32( _d, _i, _p )       ( (uint32_t) in32( (_p) ) )

    #define _mbg_outp8( _d, _i, _p, _v )   out8( (_p), (_v) )
    #define _mbg_outp16( _d, _i, _p, _v )  out16( (_p), (_v) )
    #define _mbg_outp32( _d, _i, _p, _v )  out32( (_p), (_v) )

  #else // compiling for QNX 4

    #if defined( __WATCOMC__ )   // using Watcom C

      // Include prototypes of port I/O functions
      // which should match the calls used in the mbglib functions.
      #include <conio.h>

      #define _mbg_inp8( _d, _i, _p )        ( (uint8_t) inp( (_p) ) )
      #define _mbg_inp16( _d, _i, _p )       ( (uint16_t) inpw( (_p) ) )
      #define _mbg_inp32( _d, _i, _p )       ( (uint32_t) inpd( (_p) ) )

      #define _mbg_outp8( _d, _i, _p, _v )   outp( (_p), (_v) )
      #define _mbg_outp16( _d, _i, _p, _v )  outpw( (_p), (_v) )
      #define _mbg_outp32( _d, _i, _p, _v )  outpd( (_p), (_v) )

    #endif

  #endif

#endif



#define _mbg_inp16_to_cpu( _d, _i, _p )       _mbg16_to_cpu( _mbg_inp16( (_d), (_i), (_p) ) )
#define _mbg_inp32_to_cpu( _d, _i, _p )       _mbg32_to_cpu( _mbg_inp32( (_d), (_i), (_p) ) )

#define _mbg_outp16_to_mbg( _d, _i, _p, _v )  _mbg_outp16( (_d), (_i), (_p), _cpu_to_mbg16( (_v) ) )
#define _mbg_outp32_to_mbg( _d, _i, _p, _v )  _mbg_outp32( (_d), (_i), (_p), _cpu_to_mbg32( (_v) ) )



#ifdef __cplusplus
}
#endif

/* End of header body */

#endif  /* _MBGGENIO_H */
