
/**************************************************************************
 *
 *  $Id: myutil.h 1.14.1.1 2011/06/09 11:04:06 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for myutil.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: myutil.h $
 *  Revision 1.14.1.1  2011/06/09 11:04:06  martin
 *  Revision 1.14  2011/02/16 14:02:35  martin
 *  Added STRINGIFY() macro.
 *  Revision 1.13  2010/12/13 15:59:39  martin
 *  Moved definition of macro _frac() here.
 *  Revision 1.12  2008/01/30 10:28:17Z  martin
 *  Moved some macro definitions to words.h.
 *  Revision 1.11  2004/11/09 14:20:24Z  martin
 *  Redefined some data types using C99 fixed-size definitions.
 *  Removed duplicate definition of macro _mask().
 *  Revision 1.10  2004/04/14 08:57:59Z  martin
 *  Pack structures 1 byte aligned.
 *  Revision 1.9  2003/05/20 10:22:25Z  MARTIN
 *  Corrected endianess of union UL for CC51.
 *  Revision 1.8  2002/09/03 13:40:43  MARTIN
 *  New macros _memfill() and _memclr().
 *  Revision 1.7  2002/03/14 13:45:56  MARTIN
 *  Changed type CSUM from short to ushort.
 *  Revision 1.6  2002/03/05 14:14:21  MARTIN
 *  New macro _isdigit() to avoid inclusion of ctype.h.
 *  Revision 1.5  2002/01/25 10:54:26  MARTIN
 *  Added some useful macros.
 *  Revision 1.4  2001/03/30 09:07:52  Andre
 *  union UL byte order set to Big Endian if SH2 is used
 *  Revision 1.3  2000/08/18 07:22:07Z  MARTIN
 *  Modified the _csum() macro to support far data objects.
 *  Revision 1.2  2000/07/21 13:50:49  MARTIN
 *  Added some definitions and macros.
 *
 **************************************************************************/

#ifndef _MYUTIL_H
#define _MYUTIL_H


/* Other headers to be included */

#include <words.h>
#include <use_pack.h>


// _CS_FAR should be define far if the csum of far data
// structures must be computed
#if !defined( _CSFAR )
  #define _CSFAR
#endif


#ifdef _MYUTIL
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


// The two macros below can be used to define a constant string on the
// compiler's command line, e.g. like -DVERSION_STRING="v1.0 BETA".
// Source code like
//   const char version_string[] = VERSION_STRING;
// may not work for every compiler since the double quotes
// in VERSION_STRING may be removed when the definition is evaluated.
// A proper solution is to use the STRINGIFY() macro below:
//   const char version_string[] = STRINGIFY( VERSION_STRING );
// The XSTRINGIFY() macro is simply a helper macro which should not
// be used alone.
#define STRINGIFY(x) XSTRINGIFY(x)
#define XSTRINGIFY(x) #x



#if MBG_TGT_HAS_64BIT_TYPES
  #define _frac( _x ) ( ( (_x) == 0.0 ) ? 0.0 : ( (_x) - (double) ( (int64_t) (_x) ) ) )
#else
  #define _frac( _x ) ( ( (_x) == 0.0 ) ? 0.0 : ( (_x) - (double) ( (long) (_x) ) ) )
#endif


#define _isdigit( _c )     ( (_c) >= '0' && (_c) <= '9' )

#define _eos( _s )  ( &(_s)[strlen( _s )] )

#define MIN( _x, _y )      ( ( (_x) < (_y) ) ? (_x) : (_y) )
#define MAX( _x, _y )      ( ( (_x) > (_y) ) ? (_x) : (_y) )
#define SWAP( _x, _y )     { temp = (_x); (_x) = (_y); (_y) = temp; }
#define SQR( _x )          ( (_x) * (_x) )

#define DP                 (double *)

#define bcd_from_bin( _x )  ( ( ( (_x) / 10 ) << 4 ) | ( (_x) % 10 ) )
#define bin_from_bcd( _x )  ( ( ( (_x) >> 4 ) * 10 ) + ( (_x) & 0x0F ) )


typedef union
{
  uint32_t ul;

  struct
  {
    #if defined( _CC51 ) || defined( _SH2 )
      uint16_t hi;  // big endian
      uint16_t lo;
    #else
      uint16_t lo;  // little endian
      uint16_t hi;
    #endif
  } us;

} UL;


#ifndef _CSUM_DEFINED
  typedef uint16_t CSUM;
  #define _CSUM_DEFINED
#endif


// compute the csum of a structure
#define _csum( _p )            checksum( (void _CSFAR *)(_p), sizeof( *(_p) ) )

// set a structure's csum
#define _set_csum( _p )        (_p)->csum = _csum( (_p) )

// compare a structure's computed csum with its csum field
#define _valid_csum( _p )      ( (_p)->csum  == _csum( (_p) ) )

// check if a value is in range
#define _inrange( _val, _min, _max ) \
                ( ( (_val) >= (_min) ) && ( (_val) <= (_max) ) )

// Return a bit mask with (_n) LSBs set to 1
#define _mask( _n ) \
  ( ( 1UL << (_n) ) - 1 )

// Return a bit mask with the (_i)th LSB set to 1
#define _idx_bit( _i ) \
  ( 1UL << (_i) )

// Check if the (_i)th bit is set in a mask (_msk)
#define _is_supported( _i, _msk ) \
  ( ( (_msk) & _idx_bit( _i ) ) != 0 )


/*
 * The macro below copies a string, taking care not to
 * write past the end of the destination buffer, and
 * making sure the string is terminated by 0.
 */
#define _strncpy_0( _dst, _src ) \
{                                \
  int n = sizeof( _dst ) - 1;    \
                                 \
  strncpy( _dst, _src, n );      \
  (_dst)[n] = 0;                 \
}


/*
 * The macros below set a memory range used by a variable
 * to a specified value, avoiding the need to type the name
 * twice for base address and size.
 */
#define _memfill( _p, _v ) \
        memset( _p, _v, sizeof( *(_p) ) )

#define _memclr( _p ) \
  _memfill( _p, 0 )



// generate a DOS idle interrupt to release CPU time
#define _dos_idle() geninterrupt( 0x28 )


#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 void spaces_to_zeros( char *s ) ;
 CSUM checksum( const void _CSFAR *vp, int n ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */


#undef _ext


#endif  /* _MYUTIL_H */
