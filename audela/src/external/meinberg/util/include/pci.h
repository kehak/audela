
/**************************************************************************
 *
 *  $Id: pci.h 1.9 2008/01/30 13:42:29 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions used to access the PC PCI BIOS.
 *
 * -----------------------------------------------------------------------
 *  $Log: pci.h $
 *  Revision 1.9  2008/01/30 13:42:29  martin
 *  Code cleanup to support different build environments properly.
 *  Revision 1.8  2006/07/11 08:59:00Z  martin
 *  Account for PCI functions having been renamed in the library.
 *  Revision 1.7  2003/02/19 16:51:21Z  martin
 *  Include pci_nt.h for Win32 non-pnp.
 *  Revision 1.6  2002/02/19 09:28:00Z  MARTIN
 *  Use new header mbg_tgt.h to check the target environment.
 *  Revision 1.5  2002/01/15 15:47:30  Udo
 *  Don't include pci_nt.h under Win32.
 *  Revision 1.4  2001/03/15 13:01:40Z  MARTIN
 *  Redefined preprocessor control for Win32.
 *  Revision 1.3  2001/03/01 09:23:36  MARTIN
 *  Added QNX support.
 *  Modified preprocessor syntax.
 *  Revision 1.2  2000/07/21 12:18:16  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _PCI_H
#define _PCI_H


/* Other headers to be included */

#include <mbg_tgt.h>

#if defined( MBG_TGT_NETWARE )

  #include <pci_nw.h>      // PCI functions for NetWare

#elif defined( MBG_TGT_OS2 )

  #include <pci_os2.h>     // PCI functions for OS/2

#elif defined( MBG_TGT_WIN32 )

  #if !defined( MBG_TGT_WIN32_PNP )
    #include <pci_nt.h>    // PCI functions for Win32/non-pnp
  #endif

#elif defined( MBG_TGT_LINUX )

  #include <pci_lx.h>      // PCI functions for Linux

#elif defined( MBG_TGT_QNX )

  #include <pci_qnx.h>     // PCI functions for QNX

#elif defined( MBG_TGT_DOS )

  #include <pci_dos.h>     // PCI functions for DOS

#endif



#ifdef _PCI
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

#if !defined( pci_fnc_init )
  #define pci_fnc_init()    0
#endif

#if !defined( pci_fnc_deinit )
  #define pci_fnc_deinit()
#endif


#if !defined( _mbg_pci_find_bios )
  #define _mbg_pci_find_bios       mbg_pci_find_bios
#endif

#if !defined( _mbg_pci_find_device )
  #define _mbg_pci_find_device     mbg_pci_find_device
#endif


#if defined( MBG_PCI_MACROS_MAP_DIRECT )

  #define _mbg_pci_find_device     mbg_pci_find_device
  #define _mbg_pci_read_cfg_byte   mbg_pci_read_cfg_byte
  #define _mbg_pci_read_cfg_word   mbg_pci_read_cfg_word
  #define _mbg_pci_read_cfg_dword  mbg_pci_read_cfg_dword
  #define _mbg_pci_write_cfg_byte  mbg_pci_write_cfg_byte
  #define _mbg_pci_write_cfg_word  mbg_pci_write_cfg_word
  #define _mbg_pci_write_cfg_dword mbg_pci_write_cfg_dword

#endif  // defined( MBG_PCI_MACROS_MAP_DIRECT )


#if defined( MBG_PCI_MACROS_MAP_GENERIC )

  #define _mbg_pci_read_cfg_byte( bus, dev_fnc, reg, addr ) \
          mbg_pci_read_cfg_reg( bus, dev_fnc, reg, sizeof( uint8_t ), addr )

  #define _mbg_pci_read_cfg_word( bus, dev_fnc, reg, addr ) \
          mbg_pci_read_cfg_reg( bus, dev_fnc, reg, sizeof( uint16_t ), addr )

  #define _mbg_pci_read_cfg_dword( bus, dev_fnc, reg, addr ) \
          mbg_pci_read_cfg_reg( bus, dev_fnc, reg, sizeof( uint32_t ), addr )


  #define _mbg_pci_write_cfg_byte( bus, dev_fnc, reg, addr ) \
          mbg_pci_write_cfg_reg( bus, dev_fnc, reg, sizeof( uint8_t ), addr )

  #define _mbg_pci_write_cfg_word( bus, dev_fnc, reg, addr ) \
          mbg_pci_write_cfg_reg( bus, dev_fnc, reg, sizeof( uint16_t ), addr )

  #define _mbg_pci_write_cfg_dword( bus, dev_fnc, reg, addr ) \
          mbg_pci_write_cfg_reg( bus, dev_fnc, reg, sizeof( uint32_t ), addr )

#endif  // defined( MBG_PCI_MACROS_MAP_GENERIC )


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


#endif  /* _PCI_H */


