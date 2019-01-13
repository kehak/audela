
/**************************************************************************
 *
 *  $Id: mbgddmsg.h 1.9.1.2 2011/11/01 09:08:48 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Print or remove debug messages by redefinitions.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgddmsg.h $
 *  Revision 1.9.1.2  2011/11/01 09:08:48  martin
 *  Revision 1.9.1.1  2011/03/29 13:55:19  martin
 *  Also enable debug msgs if MBG_DEBUG is defined.
 *  Revision 1.9  2011/01/26 18:13:49  martin
 *  Support for *BSD.
 *  Revision 1.8  2009/04/22 09:54:55  martin
 *  Include mbg_tgt.h also if building without DEBUG.
 *  Revision 1.7  2009/03/19 15:22:54  martin
 *  Cleaned up debug levels.
 *  Revision 1.6  2008/12/05 13:31:47  martin
 *  Use do {} while (0) syntax to avoid potential syntax problems.
 *  Added _mbgddmsg_7().
 *  Revision 1.5  2006/06/19 15:26:19  martin
 *  Fixed compiler warnings if DEBUG or DBG not defined.
 *  Revision 1.4  2002/06/12 12:25:54  martin
 *  Bug fix: check for target MBG_TGT_WIN32 instead of MBG_TGT_W32.
 *  Revision 1.3  2002/02/19 14:50:48Z  MARTIN
 *  Added support for Win32.
 *  Revision 1.2  2002/02/19 09:28:00  MARTIN
 *  Use new header mbg_tgt.h to check the target environment.
 *  Revision 1.1  2001/03/02 13:51:23  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _MBGDDMSG_H
#define _MBGDDMSG_H


#include <mbg_tgt.h>

#if defined( DEBUG ) || ( defined( DBG ) && DBG ) || defined( MBG_DEBUG )

enum
{
  MBG_DBG_ERR,
  MBG_DBG_WARN,
  MBG_DBG_INFO,
  MBG_DBG_DETAIL,
  MBG_DBG_INIT_DEV,
  MBG_DEBUG_SEM,
  MBG_DBG_IRQ,
  N_MBG_DBG_LVL
};


#define _chk_lvl( _lvl )  ( (_lvl) < debug )

#if defined( MBG_TGT_NETWARE )
  #include <conio.h>
  #define _printf ConsolePrintf
  #define _hd
  #define _tl "\n"
#elif defined( MBG_TGT_OS2 )
  #include <iprintf.h>
  #define _printf iprintf
  #define _hd
  #define _tl "\n"
#elif defined( MBG_TGT_WIN32 )
  #include <ntddk.h>
  #define _printf DbgPrint
  #define _hd
  #define _tl "\n"
#elif defined( MBG_TGT_LINUX )
  // #include <printk.h>
  #define _printf printk
  #define _hd KERN_INFO
  #define _tl "\n"
#elif defined( MBG_TGT_BSD )
  #define _printf printf
  #define _hd
  #define _tl "\n"
#else  // MBG_TGT_QNX, MBG_TGT_DOS, ...
  #include <stdio.h>
  #define _printf printf
  #define _hd
  #define _tl "\n"
#endif


#define _mbgddmsg_0( _lvl, _fmt ) \
do {                              \
  if ( _chk_lvl( _lvl ) )         \
    { _printf( _hd _fmt _tl ); }  \
} while ( 0 )

#define _mbgddmsg_1( _lvl, _fmt, _p1 )  \
do {                                    \
  if ( _chk_lvl( _lvl ) )               \
    { _printf( _hd _fmt _tl, (_p1) ); } \
} while ( 0 )

#define _mbgddmsg_2( _lvl, _fmt, _p1, _p2 )    \
do {                                           \
  if ( _chk_lvl( _lvl ) )                      \
    { _printf( _hd _fmt _tl, (_p1), (_p2) ); } \
} while ( 0 )

#define _mbgddmsg_3( _lvl, _fmt, _p1, _p2, _p3 )      \
do {                                                  \
  if ( _chk_lvl( _lvl ) )                             \
    { _printf( _hd _fmt _tl, (_p1), (_p2), (_p3) ); } \
} while ( 0 )

#define _mbgddmsg_4( _lvl, _fmt, _p1, _p2, _p3, _p4 )        \
do {                                                         \
  if ( _chk_lvl( _lvl ) )                                    \
    { _printf( _hd _fmt _tl, (_p1), (_p2), (_p3), (_p4) ); } \
} while ( 0 )

#define _mbgddmsg_5( _lvl, _fmt, _p1, _p2, _p3, _p4, _p5 )          \
do {                                                                \
  if ( _chk_lvl( _lvl ) )                                           \
    { _printf( _hd _fmt _tl, (_p1), (_p2), (_p3), (_p4), (_p5) ); } \
} while ( 0 )

#define _mbgddmsg_6( _lvl, _fmt, _p1, _p2, _p3, _p4, _p5, _p6 )            \
do {                                                                       \
  if ( _chk_lvl( _lvl ) )                                                  \
    { _printf( _hd _fmt _tl, (_p1), (_p2), (_p3), (_p4), (_p5), (_p6) ); } \
} while ( 0 )

#define _mbgddmsg_7( _lvl, _fmt, _p1, _p2, _p3, _p4, _p5, _p6, _p7 )              \
do {                                                                              \
  if ( _chk_lvl( _lvl ) )                                                         \
    { _printf( _hd _fmt _tl, (_p1), (_p2), (_p3), (_p4), (_p5), (_p6), (_p7) ); } \
} while ( 0 )

#else

  #define _mbgddmsg_0( _lvl, _fmt )                                     _nop_macro_fnc()
  #define _mbgddmsg_1( _lvl, _fmt, _p1 )                                _nop_macro_fnc()
  #define _mbgddmsg_2( _lvl, _fmt, _p1, _p2 )                           _nop_macro_fnc()
  #define _mbgddmsg_3( _lvl, _fmt, _p1, _p2, _p3 )                      _nop_macro_fnc()
  #define _mbgddmsg_4( _lvl, _fmt, _p1, _p2, _p3, _p4 )                 _nop_macro_fnc()
  #define _mbgddmsg_5( _lvl, _fmt, _p1, _p2, _p3, _p4, _p5 )            _nop_macro_fnc()
  #define _mbgddmsg_6( _lvl, _fmt, _p1, _p2, _p3, _p4, _p5, _p6 )       _nop_macro_fnc()
  #define _mbgddmsg_7( _lvl, _fmt, _p1, _p2, _p3, _p4, _p5, _p6, _p7 )  _nop_macro_fnc()

#endif

#endif  /* _MBGDDMSG_H */
