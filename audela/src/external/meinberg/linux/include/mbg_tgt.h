
/**************************************************************************
 *
 *  $Id: mbg_tgt.h 1.24 2011/08/23 10:21:23 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Check the build environment and setup control definitions
 *    for the Meinberg library modules.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbg_tgt.h $
 *  Revision 1.24  2011/08/23 10:21:23  martin
 *  New symbol _NO_MBG_API_ATTR which can be used with functions
 *  which are going to be exported by a DLL, but actually aren't, yet.
 *  Revision 1.23  2011/08/19 10:47:00  martin
 *  Don't include stddef.h.
 *  Distinguish between different gcc target platforms.
 *  Initial support for IA64 platform.
 *  Support wchar_t for BSD.
 *  Defined _NO_USE_PACK_INTF for Sparc and IA64.
 *  Fixed typo in comment.
 *  Revision 1.22  2009/10/01 08:20:50  martin
 *  Fixed inline code support with different BC versions.
 *  Revision 1.21  2009/09/01 10:34:23Z  martin
 *  Don't define __mbg_inline for CVI and undefined targets.
 *  Revision 1.20  2009/08/18 15:14:26  martin
 *  Defined default MBG_INVALID_PORT_HANDLE for non-Windows targets.
 *  Revision 1.19  2009/06/09 10:03:58  daniel
 *  Preliminary support for ARM architecture.
 *  Revision 1.18  2009/04/01 14:10:55  martin
 *  Cleanup for CVI.
 *  Revision 1.17  2009/03/19 15:21:07Z  martin
 *  Conditionally define DWORD_PTR type for old MS C compilers.
 *  Revision 1.16  2008/12/08 16:42:30  martin
 *  Defined _GNU_SOURCE for Linux.
 *  Revision 1.15  2008/11/19 15:31:49  martin
 *  Added symbol MBG_ARCH_I386.
 *  Revision 1.14  2008/09/03 15:06:04  martin
 *  Support DOS protected mode target.
 *  Support SUN SPARC architecture.
 *  Specified handle types for common host environments.
 *  Added macro MBG_USE_MM_IO_FOR_PCI.
 *  Added macro _nop_macro_fnc().
 *  Revision 1.13  2008/01/30 15:52:22  martin
 *  Modified checking for availability of wchar_t.
 *  Revision 1.13  2008/01/29 15:18:07Z  martin
 *  Recognize DOS target under Watcom compilers.
 *  Flag Watcom C always supports wchar_t.
 *  Revision 1.12  2008/01/17 09:38:50Z  daniel
 *  Added macros to determine whether C language extensions 
 *  (e.g. C94, C99) are supported by the target environment.
 *  Added macro to check whether wchar_t and friends are 
 *  supported, and some compatibility stuff.
 *  Revision 1.11  2007/10/31 16:58:03  martin
 *  Fixed __mbg_inline for Borland C (DOS).
 *  Revision 1.10  2007/09/25 08:10:27Z  martin
 *  Support CVI target environment.
 *  Added MBG_PORT_HANDLE type for serial ports.
 *  Added macros for unified inline code syntax.
 *  Revision 1.9  2006/12/08 12:45:54Z  martin
 *  Under Windows include ntddk.h rather than windows.h 
 *  if building kernel driver .
 *  Revision 1.8  2006/10/25 12:20:45Z  martin
 *  Initial support for FreeBSD, NetBSD, and OpenBSD.
 *  Added definitions for generic handle types.
 *  Revision 1.7  2006/08/23 13:43:55  martin
 *  Added definition for MBG_TGT_UNIX.
 *  Minor syntax fixes.
 *  Revision 1.6  2006/01/25 14:37:06  martin
 *  Added definitions for 64 bit Windows environments.
 *  Revision 1.5  2003/12/17 16:11:41Z  martin
 *  Split API modifiers into _MBG_API and _MBG_API_ATTR.
 *  Revision 1.4  2003/06/19 08:20:22Z  martin
 *  Added WINAPI attribute for DLL exported functions.
 *  Revision 1.3  2003/04/09 13:37:20Z  martin
 *  Added definition for _MBG_API.
 *  Revision 1.2  2003/02/24 16:08:45Z  martin
 *  Don't setup for Win32 PNP if explicitely configured non-PNP.
 *  Revision 1.1  2002/02/19 13:46:20Z  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _MBG_TGT_H
#define _MBG_TGT_H


/* Other headers to be included */

#ifdef _MBG_TGT
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _CVI ) || defined( _CVI_ )

  #define MBG_TGT_WIN32
  #define MBG_TGT_CVI

#elif defined( _WIN32_WINNT )

  // MS platform SDK
  // WinNT 4.0 and above
  #define MBG_TGT_WIN32

  #if ( _WIN32_WINNT >= 0x0500 )
    // Win2k and above
    #if !defined( MBG_TGT_WIN32_NON_PNP )
      // only if not explicitely disabled
      #define MBG_TGT_WIN32_PNP
    #endif
  #endif

#elif defined( WINVER )

  // MS platform SDK
  // Win95, WinNT 4.0 and above
  #define MBG_TGT_WIN32

  #if ( WINVER >= 0x0500 )
    // Win98, Win2k and above
    // #define ...
  #endif

#elif defined( __WIN32__ )

  // Borland C++ Builder
  #define MBG_TGT_WIN32

#elif defined( _WIN32 )

  // MS Visual C++
  #define MBG_TGT_WIN32

#elif defined( __WINDOWS_386__ )

  // Watcom C/C++ for target Win32
  #define MBG_TGT_WIN32

#elif defined( __NETWARE_386__ )

  // Watcom C/C++ for target NetWare
  #define MBG_TGT_NETWARE

#elif defined( __OS2__ )

  // Watcom C/C++ for target OS/2
  #define MBG_TGT_OS2

#elif defined( __linux )

  // GCC for target Linux
  #define MBG_TGT_LINUX
  #define _GNU_SOURCE    1

  #if defined( __KERNEL__ )
    #define MBG_TGT_KERNEL
  #endif

#elif defined( __FreeBSD__ )

  // GCC for target FreeBSD
  #define MBG_TGT_FREEBSD

#elif defined( __NetBSD__ )

  // GCC for target NetBSD
  #define MBG_TGT_NETBSD

#elif defined( __OpenBSD__ )

  // GCC for target OpenBSD
  #define MBG_TGT_OPENBSD

#elif defined( __QNX__ )

  // any compiler for target QNX
  #define MBG_TGT_QNX

  #if defined( __QNXNTO__ )
    // target QNX Neutrino
    #define MBG_TGT_QNX_NTO
  #endif

#elif defined( __MSDOS__ ) || defined( __DOS__ )

  // any compiler for target DOS
  #define MBG_TGT_DOS

  #if defined( __WATCOMC__ ) && defined( __386__ )

    #define MBG_TGT_DOS_PM  // protected mode DOS

  #endif

#endif

// Some definitions which depend on the type of compiler ...

#if defined( __GNUC__ )

  #define __mbg_inline __inline__

  #define MBG_TGT_HAS_WCHAR_T  1

  #if defined( __i386__ )

    #define MBG_ARCH_I386
    #define MBG_ARCH_X86

  #elif defined( __x86_64__ )

    #define MBG_ARCH_X86_64
    #define MBG_ARCH_X86

  #elif defined( __ia64__ )

    #define MBG_ARCH_IA64

    #define _NO_USE_PACK_INTF

  #elif defined( __sparc__ )

    #define MBG_ARCH_SPARC
    #define MBG_USE_MM_IO_FOR_PCI  1

    #define _NO_USE_PACK_INTF

  #elif defined( __arm__ )

    #define MBG_ARCH_ARM

  #endif

#elif defined( _MSC_VER )

  #define __mbg_inline __forceinline

  #define MBG_TGT_HAS_WCHAR_T  1

#elif defined( _CVI ) || defined( _CVI_ )

  // Inline code is not supported.

  #define MBG_TGT_HAS_WCHAR_T  0

#elif defined( __BORLANDC__ )

  #if defined( __cplusplus )
    #define __mbg_inline inline    // standard C++ syntax
  #elif ( __BORLANDC__ > 0x410 )   // BC3.1 defines 0x410 !
    #define __mbg_inline __inline  // newer BC versions support this for C
  #else
    #define __mbg_inline           // up to BC3.1 not supported for C
  #endif

  #define MBG_TGT_HAS_WCHAR_T  defined( MBG_TGT_WIN32 )

#elif defined( __WATCOMC__ )

  #define __mbg_inline _inline

  #define MBG_TGT_HAS_WCHAR_T  defined( MBG_TGT_WIN32 )

#endif



#if defined( MBG_TGT_FREEBSD ) \
 || defined( MBG_TGT_NETBSD ) \
 || defined( MBG_TGT_OPENBSD )
  #define MBG_TGT_BSD

  #if defined( _KERNEL )
    #define MBG_TGT_KERNEL
  #endif

#endif

#if defined( MBG_TGT_LINUX ) \
 || defined( MBG_TGT_BSD ) \
 || defined( MBG_TGT_QNX_NTO )
  #define MBG_TGT_UNIX
#endif



#if defined( MBG_TGT_WIN32 )

  #if defined( _AMD64_ )
    // This is used for AMD64 architecture and for 
    // Intel XEON CPUs with 64 bit extension.
    #define MBG_TGT_WIN32_PNP_X64
    #define WIN32_FLAVOR "x64"
  #elif defined( _IA64_ )
    #define MBG_TGT_WIN32_PNP_IA64
    #define WIN32_FLAVOR "ia64"
  #endif

  #if defined( _KDD_ )
    #define MBG_TGT_KERNEL
    #include <ntddk.h>
  #else
    // This must not be used for kernel drivers.
    #include <windows.h>
    typedef HANDLE MBG_HANDLE;

    #define MBG_INVALID_HANDLE  INVALID_HANDLE_VALUE

    #if defined( MBG_TGT_CVI )
      // CVI uses an own set of functions to support serial ports
      typedef int MBG_PORT_HANDLE;
      #define MBG_INVALID_PORT_HANDLE -1
    #else
      typedef HANDLE MBG_PORT_HANDLE;
    #endif

    // The DWORD_PTR type is not defined in the headers shipping
    // with VC6. However, if the SDK is installed then the SDK's
    // headers may declare this type. This is at least the case
    // in the Oct 2001 SDK which also defines the symbol _W64.
    #if !defined( _W64 )
      typedef DWORD DWORD_PTR;
    #endif

  #endif

  #define _MBG_API  WINAPI

  #if defined( MBG_LIB_EXPORT )
    #define _MBG_API_ATTR __declspec( dllexport )
  #else
    #define _MBG_API_ATTR __declspec( dllimport )
  #endif

#elif defined( MBG_TGT_UNIX )

  typedef int MBG_HANDLE;
  typedef int MBG_PORT_HANDLE;

  #define MBG_INVALID_HANDLE  -1

#else

  typedef int MBG_HANDLE;
  typedef int MBG_PORT_HANDLE;

  #define MBG_INVALID_HANDLE  -1

#endif


#if !defined( _MBG_API )
  #define _MBG_API
#endif

#if !defined( _MBG_API_ATTR )
  #define _MBG_API_ATTR
#endif

#if !defined( _NO_MBG_API_ATTR )
  #define _NO_MBG_API_ATTR
#endif

#if !defined( MBG_INVALID_PORT_HANDLE )
  #define MBG_INVALID_PORT_HANDLE   MBG_INVALID_HANDLE
#endif

#if !defined( MBG_USE_MM_IO_FOR_PCI )
  #define MBG_USE_MM_IO_FOR_PCI  0
#endif


#if !defined( _nop_macro_fnc )
  #define _nop_macro_fnc()     do {} while (0)
#endif


// The macros below are defined in order to be able to check if
// certain C language extensions are available on the target system:
#if defined( __STDC_VERSION__ ) && ( __STDC_VERSION__ >= 199409L )
  #define MBG_TGT_C94    1
#else
  #define MBG_TGT_C94    0
#endif


#if defined( __STDC_VERSION__ ) && ( __STDC_VERSION__ >= 199901L )
  #define MBG_TGT_C99    1
#else
  #define MBG_TGT_C99    0
#endif

// Check if wchar_t is supported
#if !defined( MBG_TGT_HAS_WCHAR_T )
  #define MBG_TGT_HAS_WCHAR_T  ( MBG_TGT_C94 || defined( WCHAR_MAX ) )
#endif

#if !MBG_TGT_HAS_WCHAR_T
  // Even if wchar_t is not natively supported by the target platform
  // there may already be a compatibility define (e.g. BC3.1)
  // However, some functions may be missing (e.g. snwprintf()).
  #if !defined( _WCHAR_T )          /* BC3.1 */ \
   && !defined( _WCHAR_T_DEFINED_ ) /* WC11 */
    #define _WCHAR_T
    #define wchar_t char
  #endif
#endif



/* End of header body */

#undef _ext


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


#endif  /* _MBG_TGT_H */
