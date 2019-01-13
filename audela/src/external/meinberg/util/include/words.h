
/**************************************************************************
 *
 *  $Id: words.h 1.27 2011/07/18 10:21:38 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions of commonly used data types.
 *
 * -----------------------------------------------------------------------
 *  $Log: words.h $
 *  Revision 1.27  2011/07/18 10:21:38  martin
 *  Added definition for MBG_CODE_NAME_TABLE_ENTRY which can
 *  be used to define tables assigning strings to numeric codes.
 *  Revision 1.26  2011/04/06 10:23:03  martin
 *  Added FBYTE_OF() and FWORD_OF() macros.
 *  Modifications required for *BSD.
 *  Revision 1.25  2010/11/17 10:23:09  martin
 *  Define _BIT_REDEFINED if bit type is redefined.
 *  Revision 1.24  2010/11/17 08:44:56Z  martin
 *  If supported, use type "bool" to implement "bit".
 *  Revision 1.23  2010/05/27 08:54:30Z  martin
 *  Support fixed size data types with Keil RealView compiler for ARM.
 *  Keil RealView ARM targets are always considered as firmware.
 *  Revision 1.22  2009/10/21 07:53:55  martin
 *  Undid changes introduced in 1.21 since they were not consistent
 *  across glibc and/or Linux kernel header versions.
 *  Revision 1.21  2009/10/01 14:00:17  martin
 *  Conditionally define ulong and friends also for Linux/glibc.
 *  Revision 1.20  2009/07/02 15:38:12  martin
 *  Added new macro _wswap32().
 *  Revision 1.19  2009/04/14 14:45:45Z  martin
 *  Added BYTE_OF_P() and WORD_OF_P() macros.
 *  Revision 1.18  2009/03/27 14:05:18  martin
 *  Cleanup for CVI.
 *  Revision 1.17  2009/03/13 09:06:03Z  martin
 *  Declared bit type for non-firmware environments.
 *  Revision 1.16  2008/12/05 12:05:41Z  martin
 *  Define dummy int64_t/uint64_t types for targets
 *  which don't support 64 bit data types.
 *  Revision 1.15  2008/07/14 14:44:00Z  martin
 *  Use fixed size C99 types which come with GCC and newer Borland compilers.
 *  Revision 1.14  2008/01/30 10:27:50Z  martin
 *  Moved some macro definitions here.
 *  Revision 1.13  2007/03/08 15:00:30Z  martin
 *  Fixed incompatibility of macro _IS_MBG_FIRMWARE.
 *  Added a workaround for _IS_MBG_FIRMWARE under CVI.
 *  Support for BSD.
 *  Revision 1.12  2006/12/15 10:45:46  martin
 *  Added macro _IS_MBG_FIRMWARE.
 *  Cleanup for Linux, QNX, and Watcom C.
 *  Include mbg_tgt.h for non-firmware targets.
 *  Revision 1.11  2004/11/10 10:45:34  martin
 *  Added C99 fixed-type handling for QNX.
 *  Revision 1.10  2004/11/09 13:12:56  martin
 *  Redefined C99 integer types with fixed sizes as standard types
 *  if required, depending on the environment.
 *  Revision 1.9  2003/02/07 11:36:54  MARTIN
 *  New macros _hilo_16() and _hilo_32() for endian conversion.
 *  Revision 1.8  2002/05/28 10:09:54  MARTIN
 *  Added new macros _var_bswap16() and _var_bswap32().
 *  Revision 1.7  2001/03/14 11:30:48  MARTIN
 *  Removed definitions for UINT8, UINT16, UINT32.
 *  Redefined preprocessor control for Win32.
 *  Revision 1.6  2001/02/28 15:43:20  MARTIN
 *  Modified preprocessor syntax.
 *  Revision 1.5  2001/02/05 10:20:53  MARTIN
 *  Include different Linux types for user space and kernel space programs.
 *  Source code cleanup.
 *  Revision 1.4  2000/09/15 08:34:11  MARTIN
 *  Exclude some definitions if compiling under Win NT.
 *  Revision 1.3  2000/08/22 15:04:28  MARTIN
 *  Added new file header.
 *  Added macros to revert endianess of 16 and 32 bit values.
 *
 **************************************************************************/

#ifndef _WORDS_H
#define _WORDS_H


/* Other headers to be included */


#if !defined( _IS_MBG_FIRMWARE )

#if defined( _C166 ) ||    \
    defined( _CC51 ) ||    \
    defined( __ARM ) ||    \
    defined( __ARMCC_VERSION )
  #define _IS_MBG_FIRMWARE 1
#else
  #define _IS_MBG_FIRMWARE 0
#endif


#endif

#if !_IS_MBG_FIRMWARE
  #include <mbg_tgt.h>
#endif


#ifdef _WORDS
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */


// The compilers below support native bit types.

#if defined( _C166 ) || defined( _CC51 ) 
  #define _BIT_DEFINED  1
#endif



// Check whether the target system supports C99 fixed-size types.

#if defined( MBG_TGT_LINUX )  // any Linux target

  #if defined( __KERNEL__ )
    #include <linux/types.h>
  #else
    #include <stdint.h>
    #include <sys/types.h>
  #endif

  #define _C99_BIT_TYPES_DEFINED       1

#elif defined( MBG_TGT_BSD )

  #include <sys/types.h>

  #define _C99_BIT_TYPES_DEFINED       1

  // avoid inclusion of stdbool.h later
  #define bit int
  #define _BIT_DEFINED  1

#elif defined( MBG_TGT_QNX )      // QNX 4.x or QNX 6.x

  #if defined( MBG_TGT_QNX_NTO )  // QNX 6.x (Neutrino) with gcc
    #include <stdint.h>
  #else                           // QNX 4.x with Watcom C 10.6
    #include <sys/types.h>        // 64 bit types not supported
  #endif

  #define _C99_BIT_TYPES_DEFINED       1

#endif



// If it's not yet clear whether fixed-size types are supported,
// check the build environment which may be multi-platform.

#if !defined( _C99_BIT_TYPES_DEFINED )

  #if defined( __WATCOMC__ )
    #if __WATCOMC__ > 1230  // Open Watcom C 1.3 and above
      #include <stdint.h>
      #define _C99_BIT_TYPES_DEFINED     1
    #elif defined( __WATCOM_INT64__ )  // Watcom C 11, non-QNX
      typedef __int64 int64_t;
      typedef unsigned __int64 uint64_t;

      #define _C99_BIT_TYPES_DEFINED     1
    #endif
  #endif

  #if defined( __BORLANDC__ )
    #if ( __BORLANDC__ >= 0x570 )  // at least Borland Developer Studio 2006
      #define _C99_BIT_TYPES_DEFINED     1
    #endif
  #endif

  #if defined( __GNUC__ )
    #include <stdint.h>
    #define _C99_BIT_TYPES_DEFINED     1
  #endif

  #if defined( __ARMCC_VERSION )  // Keil RealView Compiler for ARM
    #include <stdint.h>
    #define _C99_BIT_TYPES_DEFINED     1
  #endif

#endif


// If neither the target system nor the build environment define C99 fixed-size
// types define those types based on standard types with the proper sizes
// commonly used in 16/32 bit environments.

#if defined( _C99_BIT_TYPES_DEFINED )

  #define MBG_TGT_HAS_64BIT_TYPES    1

#else

  typedef char           int8_t;
  typedef unsigned char  uint8_t;

  typedef short          int16_t;
  typedef unsigned short uint16_t;

  typedef long           int32_t;
  typedef unsigned long  uint32_t;


  #if defined( MBG_TGT_WIN32 )

    typedef __int64           int64_t;
    typedef unsigned __int64  uint64_t;

    #define MBG_TGT_HAS_64BIT_TYPES    1

  #else
    // The types below are required to avoid build errors
    // if these types are formally used in function prototypes.
    // We explicitely use abnormal data types to hopefully
    // cause compiler errors in case these types are
    // unexpectedly used to generate real code for a target
    // platform which does not support 64 bit types.
    typedef void *int64_t;
    typedef void *uint64_t;
  #endif

#endif



#if !defined( MBG_TGT_HAS_64BIT_TYPES )

  #define MBG_TGT_HAS_64BIT_TYPES    0

#endif



// Some commonly used types

typedef unsigned char uchar;

#if !defined( MBG_TGT_LINUX ) && !( defined ( MBG_TGT_NETBSD ) && defined ( MBG_TGT_KERNEL ) )
  typedef unsigned short ushort;
  typedef unsigned int uint;
  typedef unsigned long ulong;
#endif

typedef double udouble;

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned long longword;
typedef unsigned long dword;

#if !defined( _BIT_DEFINED )

  #if _C99_BIT_TYPES_DEFINED
    #include <stdbool.h>

    typedef bool bit;
  #else
    typedef int bit;
  #endif

  #define _BIT_REDEFINED  1

#endif


#define HI_BYTE( _x )      ( (_x) >> 8 )
#define LO_BYTE( _x )      ( (_x) & 0xFF )

#define HI_WORD( _x )      ( (_x) >> 16 )
#define LO_WORD( _x )      ( (_x) & 0xFFFF )

// the macros below assume little endianess
// these macros expect the name of a variable
#define BYTE_OF( _v, _n )  *( ( (uint8_t *) &(_v) ) + (_n) )
#define WORD_OF( _v, _n )  *( ( (uint16_t *) &(_v) ) + (_n) )

#define FBYTE_OF( _v, _n )  *( ( (uint8_t far *) &(_v) ) + (_n) )
#define FWORD_OF( _v, _n )  *( ( (uint16_t far *) &(_v) ) + (_n) )

// same as above, but taking pointers
#define BYTE_OF_P( _p, _n )  *( ( (uint8_t *) (_p) ) + (_n) )
#define WORD_OF_P( _p, _n )  *( ( (uint16_t *) (_p) ) + (_n) )


// a macro to swap the byte order of a 16 bit value
#define _bswap16( _x )                        \
(                                             \
  ( ( ( (uint16_t) (_x) ) & 0x00FF ) << 8 ) | \
  ( ( ( (uint16_t) (_x) ) & 0xFF00 ) >> 8 )   \
)

// a macro to swap the byte order of a 32 bit value
#define _bswap32( _x )                               \
(                                                    \
  ( ( ( (uint32_t) (_x) ) & 0x000000FFUL ) << 24 ) | \
  ( ( ( (uint32_t) (_x) ) & 0x0000FF00UL ) << 8 )  | \
  ( ( ( (uint32_t) (_x) ) & 0x00FF0000UL ) >> 8 )  | \
  ( ( ( (uint32_t) (_x) ) & 0xFF000000UL ) >> 24 )   \
)

// a macro to swap the word order of a 32 bit value
#define _wswap32( _x )                               \
(                                                    \
  ( ( ( (uint32_t) (_x) ) & 0x0000FFFFUL ) << 16 ) | \
  ( ( ( (uint32_t) (_x) ) >> 16 ) & 0x0000FFFFUL )   \
)

#define _var_bswap16( _v )   (_v) = _bswap16( _v )
#define _var_bswap32( _v )   (_v) = _bswap32( _v )


// The C51 compiler is big-endian, that means the most
// significant byte of a 16 or 32 bit value is stored in
// the lowest memory location. Most other systems are
// little-endian, so we must use macros to adjust the
// byte order if the C51 is used.

#if defined( _CC51 )
  #define _hilo_16( _x )  _bswap16( _x )
  #define _hilo_32( _x )  _bswap32( _x )
#else
  #define _hilo_16( _x )  (_x)
  #define _hilo_32( _x )  (_x)
#endif


/**
 * @brief A table entry which can be used to map codes to names.
 */
typedef struct
{
  ulong code;
  const char *name;
} MBG_CODE_NAME_TABLE_ENTRY;



/* End of header body */

#undef _ext

#endif  /* _WORDS_H */
