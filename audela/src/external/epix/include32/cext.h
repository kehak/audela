/* 
 * 
 *	cext.h		External	06-May-2004 
 * 
 *	Copyright (C)  1988-2004  EPIX, Inc.  All rights reserved. 
 * 
 *	GP: Handy C extensions. 
 *	And compiler & OS identification. 
 *	And mappings for compiler compatibility. 
 *	As required w. external visibility; for distributed .h's 
 * 
 */ 
 
#if !defined(__EPIX_CEXT_DEFINED) 
#define __EPIX_CEXT_DEFINED 
 
/* 
 * Conserve space, time, and fingers. 
 */ 
#if defined(__GNUC__) 
  #if !defined(OS_LINUX_DD) 
    #include <sys/types.h> 
  #endif 
#else 
  typedef unsigned int	  uint; 
  typedef unsigned short  ushort; 
  typedef unsigned long   ulong; 
#endif 
typedef unsigned char	uchar; 
 
/* 
 * Emphasize semantics: object used as signed, not just 
 * as a `default integer whose value won't approach 
 * the signed/unsigned boundary'. 
 */ 
typedef signed char	schar; 
typedef signed int	sint; 
typedef signed short	sshort; 
typedef signed long	slong; 
 
 
/* 
 * MetaWare HighC 32 bit 
 */ 
#if defined(C_HIC32)|defined(__HIGHC__) 
 
    #define _far16p		/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i		/* _far data instances			    */ 
    #define _farphy	_far	/* physical address space pointers	    */ 
    #define _cfunfcc		/* library function calling convention	    */ 
    #define _cfunvcc		/* library func, w. variable arg list	    */ 
    #define _cfunacc		/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  T L X /* decl syntax				    */ 
    #if !defined(C_HIC32) 
	#define C_HIC32 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char     sint8; 
    typedef signed short    sint16; 
    typedef signed int	    sint32; 
    typedef unsigned char   uint8; 
    typedef unsigned short  uint16; 
    typedef unsigned int    uint32; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned int	/* smallest with at least 32 bits   */ 
    #define uintmax	    uint32 
 
/* 
 * Watcom 32 bit 
 */ 
#elif defined(C_WAT32)|(defined(__WATCOMC__)&defined(__386__)) 
 
    #define _far16p		/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i		/* _far data instances			    */ 
    #define _farphy	_far	/* physical address space pointers	    */ 
    #define _cfunfcc		/* library function calling convention	    */ 
    #define _cfunvcc	_cdecl	/* library func, w. variable arg list	    */ 
    #define _cfunacc	_cdecl	/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  T L X /* decl syntax				    */ 
    #if !defined(C_WAT32) 
	#define C_WAT32 0000	/* simplify other .h logic		    */ 
    #endif 
    #if defined(__DOS__) && !defined(__WINDOWS_386__) && !defined(__NT__) && !defined(__WINDOWS__) 
	#if !defined(OS_DOS4GW) 
	    #define OS_DOS4GW	/* no indication of DOS varient, assume ... */ 
	#endif 
    #endif 
    typedef signed char     sint8; 
    typedef signed short    sint16; 
    typedef signed int	    sint32; 
    typedef unsigned char   uint8; 
    typedef unsigned short  uint16; 
    typedef unsigned int    uint32; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned int	/* smallest with at least 32 bits   */ 
    #define uintmax	    uint32 
    #if __WATCOMC__ >= 1100 
	typedef signed __int64	 sint64; 
	typedef unsigned __int64 uint64; 
	#define uint64a 	unsigned _int64 
	#define sint64a 	signed _int64 
	#undef	uintmax 
	#define uintmax 	uint64 
    #endif 
 
/* 
 * Watcom 16 bit 
 */ 
#elif defined(C_WAT16)|(defined(__WATCOMC__)&!defined(__386__)) 
 
    #define _far16p	_far	/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i	_far	/* _far data instances			    */ 
    #define _farphy	_far	/* physical address space pointers	    */ 
    #define _cfunfcc		/* library function calling convention	    */ 
    #define _cfunvcc	_cdecl	/* library func, w. variable arg list	    */ 
    #define _cfunacc	_cdecl	/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  T L X /* decl syntax				    */ 
    #if !defined(C_WAT16) 
	#define C_WAT16 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char     sint8; 
    typedef signed short    sint16; 
    typedef signed long     sint32; 
    typedef unsigned char   uint8; 
    typedef unsigned short  uint16; 
    typedef unsigned long   uint32; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned long	/* smallest with at least 32 bits   */ 
    #define uintmax	    uint32 
 
/* 
 * Microsoft 32 bit 
 */ 
#elif defined(C_MSC32)|(defined(_MSC_VER)&defined(_WIN32)) 
 
    #define _far16p		/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i		/* _far data instances			    */ 
    #define _farphy		/* physical address space pointers	    */ 
    #define _cfunfcc		/* library function calling convention	    */ 
    #define _cfunvcc		/* library func, w. variable arg list	    */ 
    #define _cfunacc	_cdecl	/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  X T L /* decl syntax				    */ 
    #if !defined(C_MSC32) 
	#define C_MSC32 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char     sint8; 
    typedef signed short    sint16; 
    typedef signed int	    sint32; 
    typedef signed _int64   sint64; 
    typedef unsigned char   uint8; 
    typedef unsigned short  uint16; 
    typedef unsigned int    uint32; 
    typedef unsigned _int64 uint64; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned int	/* smallest with at least 32 bits   */ 
    #define uint64a	    unsigned _int64	/* smallest with at least 64 bits   */ 
    #define sint64a	    signed _int64	/* smallest with at least 64 bits   */ 
    #define uintmax	    uint64 
 
/* 
 * Borland 32 bit 
 */ 
#elif defined(C_BOR32)|(defined(__BORLANDC__)&defined(__WIN32__)) 
 
    #define _far16p		/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i		/* _far data instances			    */ 
    #define _farphy		/* physical address space pointers	    */ 
    #define _cfunfcc		/* library function calling convention	    */ 
    #define _cfunvcc		/* library func, w. variable arg list	    */ 
    #define _cfunacc	_cdecl	/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  X T L /* decl syntax				    */ 
    #if !defined(C_BOR32) 
	#define C_BOR32 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char     sint8; 
    typedef signed short    sint16; 
    typedef signed int	    sint32; 
    typedef unsigned char   uint8; 
    typedef unsigned short  uint16; 
    typedef unsigned int    uint32; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned int	/* smallest with at least 32 bits   */ 
    #define uintmax	    uint32 
 
/* 
 * TI TMS320C40 
 */ 
#elif defined(C_TMSC40)|defined(_TMS320C40) 
 
    #define _far16p		/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i		/* _far data instances			    */ 
    #define _farphy		/* physical address space pointers	    */ 
    #define _cfunfcc		/* library function calling convention	    */ 
    #define _cfunvcc		/* library func, w. variable arg list	    */ 
    #define _cfunacc		/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  T L X /* decl syntax				    */ 
    #if !defined(C_TMSC40) 
	#define C_TMSC40 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char     sint32; 
    typedef unsigned char   uint32; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned char	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned char	/* smallest with at least 32 bits   */ 
    #define uintmax	    uint32 
 
 
/* 
 * Microsoft C 16 bit 
 */ 
#elif defined(C_MSC16)|defined(_MSC_VER) 
 
    #define _far16p	_far	/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i	_far	/* _far data instances			    */ 
    #define _farphy	_far	/* physical address space pointers	    */ 
    #define _cfunfcc _fastcall	/* library function calling convention	    */ 
    #define _cfunvcc _cdecl	/* library func, w. variable arg list	    */ 
    #define _cfunacc _cdecl	/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  T L X /* decl syntax				    */ 
    #if !defined(C_MSC16) 
	#define C_MSC16 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char     sint8; 
    typedef signed short    sint16; 
    typedef signed long     sint32; 
    typedef unsigned char   uint8; 
    typedef unsigned short  uint16; 
    typedef unsigned long   uint32; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned long	/* smallest with at least 32 bits   */ 
    #define uintmax	    uint32 
 
/* 
 * Borland C 16 bit 
 */ 
#elif defined(C_BOR16)|defined(__BORLANDC__) 
 
    #define _far16p	_far	/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i	_far	/* _far data instances			    */ 
    #define _farphy	_far	/* physical address space pointers	    */ 
    #define _cfunfcc _fastcall	/* library function calling convention	    */ 
    #define _cfunvcc _cdecl	/* library func, w. variable arg list	    */ 
    #define _cfunacc _cdecl	/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  T L X /* decl syntax				    */ 
    #if !defined(C_BOR16) 
	#define C_BOR16 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char     sint8; 
    typedef signed short    sint16; 
    typedef signed long     sint32; 
    typedef unsigned char   uint8; 
    typedef unsigned short  uint16; 
    typedef unsigned long   uint32; 
    typedef float	    float4; 
    typedef double	    float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned long	/* smallest with at least 32 bits   */ 
    #define uintmax	    uint32 
 
/* 
 * GNU C, assumed 32 bit 
 */ 
#elif defined(__GNUC__) 
 
    #define _far16p		/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i		/* _far data instances			    */ 
    #define _farphy		/* physical address space pointers	    */ 
    #define _cfunfcc		/* library function calling convention	    */ 
    #define _cfunvcc		/* library func, w. variable arg list	    */ 
    #define _cfunacc		/* library func, alternate		    */ 
    #define _cDcl(X,L,T)  X T L /* decl syntax				    */ 
    #if !defined(C_GNU32) 
	#define C_GNU32 0000	/* simplify other .h logic		    */ 
    #endif 
    typedef signed char 	sint8; 
    typedef signed short	sint16; 
    typedef signed int		sint32; 
    typedef signed long long	sint64; 
    typedef unsigned char	uint8; 
    typedef unsigned short	uint16; 
    typedef unsigned int	uint32; 
    typedef unsigned long long	uint64; 
    typedef float		float4; 
    typedef double		float8; 
    #define uint8a	    unsigned char	/* smallest with at least 8 bits    */ 
    #define uint16a	    unsigned short	/* smallest with at least 16 bits   */ 
    #define uint32a	    unsigned int	/* smallest with at least 32 bits   */ 
    #define uint64a	    unsigned long long	/* smallest with at least 64 bits   */ 
    #define sint64a	    signed long long	/* smallest with at least 64 bits   */ 
    #define uintmax	    uint64 
 
 
/* 
 * Unknown compiler 
 */ 
#else 
    #error "Can't identify compiler." 
#endif 
 
 
/* 
 * WinNT/2000/XP 
 */ 
#if  defined(OS_WINNT)|defined(OS_WINNT_DLL)	/* epix's      */ \
    |defined(_WINNT)|defined(WINNT)		/* microsoft's */ 
	#undef	_cfunfcc 
	#undef	_cfunvcc 
	#undef	_cfunacc 
	#define _cfunfcc  __stdcall 
	#define _cfunvcc  __cdecl 
	#define _cfunacc  __cdecl 
	#undef	_farphy 
	#define _farphy 			/* all compilers: disable _far */ 
	#if !defined(OS_WINNT)&!defined(OS_WINNT_DLL)&!defined(OS_WINNT_KMD)&!defined(OS_WINNT_WDM) 
	  #define OS_WINNT			/* simplify other .h logic */ 
	#endif 
 
 
/* 
 * Win95/98/ME 
 */ 
#elif defined(OS_WIN95)|defined(OS_WIN95_DLL)	/* epix's      */ \
    |defined(_WIN32)				/* microsoft's */ \
    |defined(__WINDOWS_386__)			/* watcom's    */ \
    |defined(__WIN32__) 			/* borland's   */ 
	#undef	_cfunfcc 
	#undef	_cfunvcc 
	#undef	_cfunacc 
	#define _cfunfcc  __stdcall 
	#define _cfunvcc  __cdecl 
	#define _cfunacc  __cdecl 
	#undef	_farphy 
	#define _farphy 			/* all compilers: disable _far */ 
	#if !defined(OS_WIN95)&!defined(OS_WIN95_DLL)&!defined(OS_WIN95_VXD) 
	  #define OS_WIN95			/* simplify other .h logic */ 
	#endif 
 
/* 
 * Win3x 
 */ 
#elif defined(OS_WIN3X)|defined(OS_WIN3X_DLL)	/* epix's      */ \
    |defined(_WINDOWS)|defined(_WINDLL) 	/* microsoft's */ \
    |(defined(__WINDOWS__)&defined(__386__))	/* watcom's    */ \
    |defined(_Windows)				/* borland's   */ 
	#undef	_cfunfcc 
	#undef	_cfunvcc 
	#undef	_cfunacc 
	#define _cfunfcc  _pascal 
	#define _cfunvcc  _cdecl 
	#define _cfunacc  _cdecl 
	#if !defined(OS_WIN3X)&!defined(OS_WIN3X_DLL) 
	  #define OS_WIN3X			/* simplify other .h logic */ 
	#endif 
 
/* 
 * Linux 
 */ 
#elif defined(OS_LINUX_GNU)			/* epix's      */ 
 
 
/* 
 * Other 
 */ 
#endif 
 
 
/* 
 * For the _cDcl() macros ... 
 * (NB: Beware CTOBAS when changed !!) 
 */ 
#if !defined(_dllpxobj) 
  #define _dllpxobj 
#endif 
#if !defined(_dllpxlib) 
  #define _dllpxlib 
#endif 
#if !defined(_dllpxipl) 
  #define _dllpxipl 
#endif 
#define _dllxxxxx 
 
 
/* 
 * For customized versions ... 
 */ 
#if defined(CUST_OSI) 
    #undef  _far16p 
    #undef  _far16i 
    #undef  _farphy 
    #define _far16p	_huge	/* _fmalloc'ed pointers, _far data pointers */ 
    #define _far16i	_huge	/* _far data instances			    */ 
    #define _farphy	_huge	/* physical address space pointers	    */ 
#endif 
 
 
 
#endif				/* !defined(__EPIX_CEXT_DEFINED) */ 

