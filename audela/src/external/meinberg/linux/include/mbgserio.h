
/**************************************************************************
 *
 *  $Id: mbgserio.h 1.6.1.5 2011/12/15 14:20:58 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for mbgserio.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgserio.h $
 *  Revision 1.6.1.5  2011/12/15 14:20:58  martin
 *  Tmp. debug code to test flush under Windows.
 *  Revision 1.6.1.4  2011/12/13 08:36:50Z  martin
 *  Got rid of _mbg_open/clos/read/write() macros.
 *  Revision 1.6.1.3  2011/12/13 08:24:56  martin
 *  Removed most _mbgderio_...() function macros.
 *  Revision 1.6.1.2  2011/12/12 17:20:24  martin
 *  Revision 1.6.1.1  2011/12/12 16:12:25  martin
 *  Started to get rid of _mbgserio_read/write macros.
 *  Use functions instead.
 *  Revision 1.6  2011/08/23 10:15:25Z  martin
 *  Updated function prototypes.
 *  Revision 1.5  2011/08/04 09:48:55  martin
 *  Support flushing output.
 *  Re-ordered some definitions.
 *  Revision 1.4  2009/09/01 10:54:29  martin
 *  Include mbg_tmo.h for the new portable timeout functions.
 *  Added symbols for return codes in case of an error.
 *  Code cleanup.
 *  Revision 1.3  2009/04/01 14:17:31  martin
 *  Cleanup for CVI.
 *  Revision 1.2  2008/09/04 15:11:36Z  martin
 *  Preliminary support for device lists.
 *  Updated function prototypes.
 *  Revision 1.1  2007/11/12 16:48:02  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _MBGSERIO_H
#define _MBGSERIO_H


/* Other headers to be included */

#include <mbg_tmo.h>

#include <stdlib.h>
#include <string.h>

#if defined( MBG_TGT_UNIX )
  #include <termios.h>
#endif

#if _USE_CHK_TSTR
  #include <chk_tstr.h>
#endif

#if !defined( _USE_SELECT_FOR_SERIAL_IO )
  #if defined( MBG_TGT_UNIX )
    #define _USE_SELECT_FOR_SERIAL_IO  1
  #else
    #define _USE_SELECT_FOR_SERIAL_IO  0
  #endif
#endif


#ifdef _MBGSERIO
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#define MBGSERIO_FAIL     -1   // Generic I/O error
#define MBGSERIO_TIMEOUT  -2   // timeout
#define MBGSERIO_INV_CFG  -3   // invalid configuration parameters


#if !defined( DEFAULT_DEV_NAME )
  #if defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_DOS )
    #define DEFAULT_DEV_NAME   "COM1"
  #elif defined( MBG_TGT_LINUX )
    #define DEFAULT_DEV_NAME   "/dev/ttyS0"
  #endif
#endif


/*
 * The following macros control parts of the build process.
 * The default values are suitable for most cases but can be
 * overridden by global definitions, if required.
 */

#if _IS_MBG_FIRMWARE

  // This handle type in not used by the firmware.
  // However, we define it to avoid build errors.
  typedef int MBG_HANDLE;

#else

  #if defined( MBG_TGT_CVI )

    #include <rs232.h>

  #elif defined( MBG_TGT_WIN32 )

    #include <windows.h>
    #include <io.h>

  #elif defined( MBG_TGT_UNIX )

    #include <unistd.h>

  #elif defined( MBG_TGT_DOS )

    #if defined( _USE_V24TOOLS )
      #include <v24tools.h>
    #endif

  #endif

#endif



typedef struct _MBG_STR_LIST
{
  char *s;
  struct _MBG_STR_LIST *next;

} MBG_STR_LIST;



typedef struct
{
  MBG_PORT_HANDLE port_handle;   // the handle that will be used for the device

  #if defined( MBG_TGT_WIN32 )
    DCB old_dcb;
    COMMTIMEOUTS old_commtimeouts;
    COMMPROP comm_prop;
  #endif

  #if defined( MBG_TGT_UNIX )
    struct termios old_tio;
  #endif

} SERIAL_IO_STATUS;



/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 _NO_MBG_API_ATTR int _MBG_API mbgserio_open( SERIAL_IO_STATUS *pst, const char *dev ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgserio_close( SERIAL_IO_STATUS *pst ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgserio_setup_port_str_list( MBG_STR_LIST **list, int max_devs ) ;
 _NO_MBG_API_ATTR void _MBG_API mbgserio_free_str_list( MBG_STR_LIST *list ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgserio_set_parms( SERIAL_IO_STATUS *pst,  uint32_t baud_rate, const char *framing ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgserio_read( MBG_PORT_HANDLE h, void *buffer, unsigned int count ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgserio_write( MBG_PORT_HANDLE h, const void *buffer, unsigned int count ) ;
 _NO_MBG_API_ATTR void _MBG_API mbgserio_flush_tx( MBG_PORT_HANDLE h ) ;
 _NO_MBG_API_ATTR int _MBG_API mbgserio_read_wait( MBG_PORT_HANDLE h, void *buffer, uint count, ulong char_timeout ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif

/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _MBGSERIO_H */
