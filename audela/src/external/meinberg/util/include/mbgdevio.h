
/**************************************************************************
 *
 *  $Id: mbgdevio.h 1.39.1.25 2011/11/25 15:03:22 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes used with Meinberg device driver I/O.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgdevio.h $
 *  Revision 1.39.1.25  2011/11/25 15:03:22  martin
 *  Support on-board event logs.
 *  Revision 1.39.1.24  2011/11/23 16:42:03  martin
 *  Updated function prototypes.
 *  Added some comments.
 *  Revision 1.39.1.23.1.4  2011/11/23 16:37:24  martin
 *  Removed tmp. debug code.
 *  Revision 1.39.1.23.1.3  2011/11/23 16:32:53  martin
 *  Modified tmp. debug code.
 *  Revision 1.39.1.23.1.2  2011/11/22 15:13:14  martin
 *  Updated function prototypes.
 *  Revision 1.39.1.23.1.1  2011/11/21 14:16:33  martin
 *  Tmp. debug generic I/O.
 *  Revision 1.39.1.23  2011/11/16 10:09:28  martin
 *  Fixed a bug which caused a crash when generic I/O calls
 *  were used under Windows.
 *  Revision 1.39.1.22  2011/10/21 14:08:28Z  martin
 *  Changes for QNX.
 *  Revision 1.39.1.21  2011/09/26 14:03:21  martin
 *  Workaround to make mbgmon (BC) build under Windows.
 *  See diff for details.
 *  Cleaned up CPU set support under Linux.
 *  Updated function prototypes.
 *  Revision 1.39.1.20  2011/07/20 15:52:22Z  martin
 *  Conditionally use older IOCTL request buffer structures.
 *  Moved some macros here so they can be used by other modules.
 *  Modified some macros and definitions.
 *  Revision 1.39.1.19  2011/07/19 15:46:39  martin
 *  Revision 1.39.1.18  2011/07/06 11:19:24  martin
 *  Support reading CORR_INFO, and reading/writing TR_DISTANCE.
 *  Revision 1.39.1.17  2011/06/29 11:10:19  martin
 *  Updated function prototypes.
 *  Revision 1.39.1.16  2011/06/22 10:16:22  martin
 *  Cleaned up handling of pragma pack().
 *  Cleaned up inclusion of header files.
 *  Updated function prototypes.
 *  Revision 1.39.1.15  2011/04/12 12:57:53  martin
 *  Moved mutex definitions to new mbgmutex.h.
 *  Renamed mutex stuff to critical sections.
 *  Revision 1.39.1.14  2011/03/31 13:20:55  martin
 *  Updated function prototypes.
 *  Revision 1.39.1.13  2011/02/15 14:26:22Z  martin
 *  Revision 1.39.1.12  2011/02/15 11:22:29  daniel
 *  Updated function prototypes to support PTP unicast configuration
 *  Revision 1.39.1.11  2011/02/02 12:21:39Z  martin
 *  Fixed a type.
 *  Revision 1.39.1.10  2011/01/28 09:33:45  martin
 *  Cosmetics.
 *  Revision 1.39.1.9  2010/12/14 11:23:49  martin
 *  Moved definition of MBG_HW_NAME to the header file.
 *  Revision 1.39.1.8  2010/12/14 10:56:35Z  martin
 *  Revision 1.39.1.7  2010/08/11 13:48:53  martin
 *  Cleaned up comments.
 *  Revision 1.39.1.6  2010/08/11 12:43:52  martin
 *  Revision 1.39.1.5  2010/07/15 08:40:57  martin
 *  Revision 1.39.1.4  2010/01/08 15:04:17Z  martin
 *  Revision 1.39.1.3  2010/01/08 11:24:02Z  martin
 *  Compute and check time of day only if any leap second status bit set.
 *  Revision 1.39.1.2  2010/01/08 11:13:57Z  martin
 *  Made xhrt leap second check an inline function.
 *  Revision 1.39.1.1  2010/01/07 15:49:37Z  martin
 *  Fixed macro to avoid compiler warning.
 *  Revision 1.39  2009/12/15 15:34:59Z  daniel
 *  Support reading the raw IRIG data bits for firmware versions 
 *  which support this feature.
 *  Revision 1.38.1.2  2009/12/10 09:58:53Z  daniel
 *  Revision 1.38.1.1  2009/12/10 09:45:29Z  daniel
 *  Revision 1.38  2009/09/29 15:06:26Z  martin
 *  Updated function prototypes.
 *  Revision 1.37  2009/08/12 14:31:51  daniel
 *  New version code 306, compatibility version still 210.
 *  Revision 1.36  2009/06/19 12:20:31Z  martin
 *  Updated function prototypes.
 *  Revision 1.35  2009/06/09 08:57:09  daniel
 *  New version code 305, compatibility version still 210.
 *  Revision 1.34  2009/06/08 18:20:14Z  daniel
 *  Updated function prototypes.
 *  Fixes for ARM target.
 *  Revision 1.33  2009/03/19 15:36:26  martin
 *  New version code 304, compatibility version still 210.
 *  Moved some inline functions dealing with MBG_PC_CYCLES
 *  from mbgdevio.h to pcpsdev.h.
 *  Include mbg_arch.h here.
 *  Removed unused doxygen comment.
 *  Updated function prototypes.
 *  Revision 1.32  2008/12/17 10:43:30Z  martin
 *  New version code 303, compatibility version still 210.
 *  Increased MBG_MAX_DEVICES from 5 to 8.
 *  Added macros to read the time stamp counter (cycles), and
 *  added an inline rdtscll() call for user space Linux.
 *  Added some inline functions to deal with cycles and timestamps.
 *  Generic support for threads and process/thread affinity controlled
 *  by symbol MBGDEVIO_USE_THREAD_API.
 *  New preprocessor symbol MBGDEVIO_HAVE_THREAD_AFFINITY.
 *  Support extrapolated time stamps controlled
 *  by symbol MBGDEVIO_XHRT_API.
 *  Removed definition of MBG_TGT_SUPP_MMAP.
 *  Updated function prototypes and doxygen comments.
 *  Revision 1.31  2008/02/26 16:57:38Z  martin
 *  Updated function prototypes and doxygen comments.
 *  Revision 1.30  2008/02/04 13:33:15Z  martin
 *  New preprocessor symbol MBG_TGT_SUPP_MMAP.
 *  Revision 1.29  2008/01/31 08:55:39Z  daniel
 *  Renamed functions related to mapped memory support
 *  Revision 1.28  2008/01/31 08:36:22Z  martin
 *  Picked up changes from 1.24.1.1:
 *  Added default preprocessor symbol MBGDEVIO_SIMPLE.
 *  Revision 1.27  2008/01/17 15:56:37Z  daniel
 *  New version code 302, compatibility version still 210.
 *  Added structure MBG_MAPPED_MEM_INFO.
 *  Updated function prototypes.
 *  Revision 1.26  2007/10/16 10:11:42Z  daniel
 *  New version code 301, compatibility version still 210.
 *  Revision 1.25  2007/09/26 14:10:34Z  martin
 *  New version code 300, compatibility version still 210.
 *  Added MBG_MAX_DEVICES.
 *  Added enum SELECTION_MODE.
 *  Added structures MBG_DEVICE_LIST and MBG_DEVICE_NAME_LIST.
 *  Updated function prototypes.
 *  Revision 1.24  2007/03/22 10:14:16Z  martin
 *  New version code 219, compatibility version still 210.
 *  Revision 1.23  2007/03/02 10:18:10Z  martin
 *  Updated function prototypes due to renamed data structures.
 *  Use new definitions of generic handle types.
 *  Preliminary support for *BSD.
 *  Revision 1.22  2006/08/09 13:47:29  martin
 *  New version code 218, compatibility version still 210.
 *  Revision 1.21  2006/06/08 12:30:22Z  martin
 *  New version code 217, compatibility version still 210.
 *  Revision 1.20  2006/05/02 13:14:27Z  martin
 *  New version code 216, compatibility version still 210.
 *  Updated function prototypes.
 *  Revision 1.19  2006/01/11 12:14:53Z  martin
 *  New version code 215, compatibility version still 210.
 *  Revision 1.18  2005/12/15 09:38:39Z  martin
 *  New version 214, compatibility version still 210.
 *  Revision 1.17  2005/06/02 11:54:40Z  martin
 *  Updated function prototypes.
 *  Revision 1.16  2005/02/16 15:13:00Z  martin
 *  New MBGDEVIO_VERSION 0x0212.
 *  Updated function prototypes.
 *  Revision 1.15  2005/01/14 10:22:44Z  martin
 *  Updated function prototypes.
 *  Revision 1.14  2004/12/09 11:24:00Z  martin
 *  Support configuration of on-board frequency synthesizer.
 *  Revision 1.13  2004/11/09 14:13:00Z  martin
 *  Updated function prototypes.
 *  Revision 1.12  2004/08/17 11:13:46Z  martin
 *  Account for renamed symbols.
 *  Revision 1.11  2004/04/14 09:34:23Z  martin
 *  New definition MBGDEVIO_COMPAT_VERSION.
 *  Pack structures 1 byte aligned.
 *  Revision 1.10  2003/12/22 15:35:10Z  martin
 *  New revision 2.03.
 *  Moved some definitions to pcpsdev.h.
 *  New structures to read device time together with associated
 *  PC high resolution timer cycles.
 *  Updated function prototypes.
 *  Revision 1.9  2003/06/19 08:50:05Z  martin
 *  Definition of MBGDEVIO_VERSION number to allow DLL 
 *  API version checking.
 *  Replaced some defines by typedefs.
 *  Renamed USE_DOS_TSR to MBG_USE_DOS_TSR.
 *  New preprocessor symbol MBG_USE_KERNEL_DRIVER which 
 *  is defined only for targets which use IOCTLs.
 *  Don't include pcps_dos.h here.
 *  Updated function prototypes.
 *  Revision 1.8  2003/05/16 08:44:26  MARTIN
 *  Cleaned up inclusion of headers.
 *  Removed obsolete definitions.
 *  Changes for direct access targets.
 *  Revision 1.7  2003/04/25 10:16:00  martin
 *  Updated inclusion of headers.
 *  Made prototypes available for all targets.
 *  Revision 1.6  2003/04/15 19:38:05Z  martin
 *  Updated function prototypes.
 *  Revision 1.5  2003/04/09 13:44:53Z  martin
 *  Use new common IOCTL codes from mbgioctl.h.
 *  Updated function prototypes.
 *  Revision 1.4  2002/09/06 11:06:35Z  martin
 *  Updated function prototypes for Win32 API..
 *  Win32 compatibility macros to use old APIs with new functions.
 *  Support targets OS/2 and NetWare.
 *  Revision 1.3  2002/02/28 10:08:54Z  MARTIN
 *  Syntax cleanup for Win32.
 *  Revision 1.2  2002/02/26 14:40:47  MARTIN
 *  Source code cleanup.
 *  Changes for DOS with and without TSR.
 *  Revision 1.1  2002/02/19 13:48:21  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _MBGDEVIO_H
#define _MBGDEVIO_H


/* Other headers to be included */

#include <mbg_tgt.h>
#include <mbg_arch.h>
#include <mbgmutex.h>
#include <mbgerror.h>
#include <mbggeo.h>
#include <pcpsdev.h>
#include <pci_asic.h>
#include <use_pack.h>
#include <time.h>


#define MBGDEVIO_VERSION         0x0307

#define MBGDEVIO_COMPAT_VERSION  0x0210

#define MBG_MAX_DEVICES  8

#if defined( MBG_TGT_WIN32 )

  #if !defined( MBGDEVIO_XHRT_API )
    #define MBGDEVIO_XHRT_API  1
  #endif

  #if !defined( MBGDEVIO_USE_THREAD_API )
    #define MBGDEVIO_USE_THREAD_API  1
  #endif

  #if !defined( MBGDEVIO_HAVE_THREAD_AFFINITY )
    #define MBGDEVIO_HAVE_THREAD_AFFINITY  1
  #endif

  #define MBG_USE_KERNEL_DRIVER  1
  #include <windows.h>

  #define MBGDEVIO_RET_VAL  DWORD
  #define _mbgdevio_cnv_ret_val( _v )  (_v)

#elif defined( MBG_TGT_LINUX )

  #if !defined( MBGDEVIO_XHRT_API )
    #define MBGDEVIO_XHRT_API  1
  #endif

  // Thread support under Linux depends strongly on
  // the versions of some libraries, so the symbols
  // MBGDEVIO_USE_THREAD_API and MBGDEVIO_HAVE_THREAD_AFFINITY
  // should be set in the project's Makefile, depending on the
  // target envionment. Otherwise thread support is disabled
  // as per default.

  #define MBG_USE_KERNEL_DRIVER  1
  #include <sys/ioctl.h>
  #include <fcntl.h>
  #include <sched.h>

  #if MBGDEVIO_USE_THREAD_API
    #include <pthread.h>
  #endif

#elif defined( MBG_TGT_BSD )

  #define MBG_USE_KERNEL_DRIVER  1
  #include <sys/ioctl.h>
  #include <fcntl.h>

#elif defined( MBG_TGT_OS2 )

  #define MBG_USE_KERNEL_DRIVER  1

#elif defined( MBG_TGT_QNX_NTO )

  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>

  #include <pcpsdrvr.h>

#elif defined( MBG_TGT_DOS )

  #if !defined( MBG_USE_DOS_TSR )
    #define MBG_USE_DOS_TSR  1
  #endif

  #include <pcpsdrvr.h>

#else // other target OSs which access the hardware directly

  #include <pcpsdrvr.h>

#endif


#if defined( MBG_USE_KERNEL_DRIVER )

  #include <mbgioctl.h>

  #include <stdlib.h>
  #include <string.h>

#endif


#if !defined( MBGDEVIO_XHRT_API )
  #define MBGDEVIO_XHRT_API  0
#endif

#if !defined( MBGDEVIO_USE_THREAD_API )
  #define MBGDEVIO_USE_THREAD_API  0
#endif

#if !defined( MBGDEVIO_HAVE_THREAD_AFFINITY )
  #define MBGDEVIO_HAVE_THREAD_AFFINITY  0
#endif

#ifdef _MBGDEVIO
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


// If MBGDEVIO_SIMPLE != 0  then some complex configuration
// API calls are excluded from build, which would otherwise
// require some additional mbglib modules to be linked 
// to the application.
#if !defined( MBGDEVIO_SIMPLE )
  #define MBGDEVIO_SIMPLE   0
#endif


#if defined( MBG_USE_KERNEL_DRIVER )

  typedef MBG_HANDLE MBG_DEV_HANDLE;

  #define MBG_INVALID_DEV_HANDLE  MBG_INVALID_HANDLE

#else // other target OSs which access the hardware directly

  typedef PCPS_DDEV *MBG_DEV_HANDLE;

  #define MBG_INVALID_DEV_HANDLE  NULL

#endif


#if !defined( MBGDEVIO_RET_VAL )
  #define MBGDEVIO_RET_VAL   int
#endif


#if !defined( _mbgdevio_cnv_ret_val )
  #define _mbgdevio_cnv_ret_val( _v ) \
    ( ( (_v) < 0 ) ? (_v) : MBG_SUCCESS )
#endif


#define _mbgdevio_vars() \
  MBGDEVIO_RET_VAL rc

#define _mbgdevio_ret_val \
  _mbgdevio_cnv_ret_val( rc )



/**
    The type below is used to store a unique ID for a device which
    is made up of the device model name and its serial number, i.e.:
    Format: [model_name]_[serial_number], e.g. "GPS170PCI_028210040670"
  */
typedef char MBG_HW_NAME[PCPS_CLOCK_NAME_SZ + PCPS_SN_SIZE + 1];



#if defined( MBG_TGT_LINUX )

  #define MBG_PROCESS_ID              pid_t
  #define _mbg_get_current_process()  0

  #if defined( __cpu_set_t_defined )
    #define MBG_CPU_SET               cpu_set_t
    #define MBG_CPU_SET_SIZE          CPU_SETSIZE
    #define _mbg_cpu_clear( _ps )     CPU_ZERO( (_ps) )
    #define _mbg_cpu_set( _i, _ps )   CPU_SET( (_i), (_ps) )
    #define _mbg_cpu_isset( _i, _ps ) CPU_ISSET( (_i), (_ps) )
  #endif

  #if MBGDEVIO_USE_THREAD_API
    #define MBG_THREAD_ID             pthread_t
    #define _mbg_get_current_thread() 0
    #define MBG_THREAD_FNC_ATTR       // empty
    #define MBG_THREAD_FNC_RET_VAL    void *
    #define _mbg_thread_exit( _v )    return (void *) (_v)
  #endif

#elif defined( MBG_TGT_WIN32 )

  #define MBG_PROCESS_ID              HANDLE
  #define _mbg_get_current_process()  GetCurrentProcess()

  #define MBG_CPU_SET                 DWORD_PTR  // Attention: this is not used as pointer!
  #define MBG_CPU_SET_SIZE            ( sizeof( MBG_CPU_SET ) * 8 )

  #define MBG_THREAD_ID               HANDLE
  #define _mbg_get_current_thread()   GetCurrentThread()
  #define MBG_THREAD_FNC_ATTR         WINAPI
  #define MBG_THREAD_FNC_RET_VAL      DWORD
  #define _mbg_thread_exit( _v )      ExitThread( _v ); return (_v)

#endif  // target specific


#if !defined( MBG_TGT_WIN32 )

  #define FILETIME int  // just a dummy to avoid build errors

#endif


#if !defined( MBG_PROCESS_ID )
  #define MBG_PROCESS_ID              int
#endif

#if !defined( _mbg_get_current_process )
  #define _mbg_get_current_process()  0
#endif

#if !defined( MBG_CPU_SET )
  #define MBG_CPU_SET                 int
#endif

#if !defined( MBG_CPU_SET_SIZE )
  #define MBG_CPU_SET_SIZE            ( sizeof( MBG_CPU_SET ) * 8 )
#endif

#if !defined( _mbg_cpu_clear )
  #define _mbg_cpu_clear( _ps )       ( *(_ps) = 0 )
#endif

#if !defined( _mbg_cpu_set )
  #define _mbg_cpu_set( _i, _ps )     ( *(_ps) |= ( 1UL << (_i) ) )
#endif

#if !defined( _mbg_cpu_isset )
  #define _mbg_cpu_isset( _i, _ps )   ( *(_ps) & ( 1UL << (_i) ) )
#endif


#if !defined( MBG_THREAD_ID )
  #define MBG_THREAD_ID               int
#endif

#if !defined( _mbg_get_current_thread )
  #define _mbg_get_current_thread()   0
#endif

#if !defined( MBG_THREAD_FNC_ATTR )
  #define MBG_THREAD_FNC_ATTR         // empty
#endif

#if !defined( MBG_THREAD_FNC_RET_VAL )
  #define MBG_THREAD_FNC_RET_VAL      void
#endif

#if !defined( _mbg_thread_exit )
  #define _mbg_thread_exit( _v )      _nop_macro_fnc()
#endif


typedef struct
{
  MBG_THREAD_ID thread_id;
  #if defined( MBG_TGT_WIN32 )
    HANDLE exit_request;
  #endif
} MBG_THREAD_INFO;



typedef struct
{
  PCPS_HR_TIME_CYCLES htc;
  uint64_t pcps_hr_tstamp64;
} MBG_XHRT_VARS;


typedef struct
{
  MBG_XHRT_VARS vars;
  MBG_XHRT_VARS prv_vars;
  MBG_PC_CYCLES_FREQUENCY freq_hz;
  int ioctl_status;
  int sleep_ms;
  MBG_CRIT_SECT crit_sect;
  MBG_DEV_HANDLE dh;
} MBG_XHRT_INFO;


typedef struct
{
  MBG_XHRT_INFO xhrt_info;
  MBG_THREAD_INFO ti;
} MBG_POLL_THREAD_INFO;



/**
  Match modes to decide how to proceed if a certain 
  model type with certain serial number can not be found
 */
enum MBG_MATCH_MODE
{
  MBG_MATCH_ANY,     /**< open the next available device on the system */
  MBG_MATCH_MODEL,   /**< open the next available device on the system with the same clock type */
  MBG_MATCH_EXACTLY, /**< force opening exactly the requested device otherwise exit with failure */
  N_MBG_MATCH_MODE   /**< number of known modes */
};



typedef struct _MBG_DEVICE_LIST
{
  char   *device_path;        /**< Hardware ID depending on the calling function */
  struct _MBG_DEVICE_LIST *next;

} MBG_DEVICE_LIST;



typedef struct _MBG_DEVICENAME_LIST
{
  char   device_name[40];        /**< readable name */
  struct _MBG_DEVICENAME_LIST *next;

} MBG_DEVICENAME_LIST;



/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 /**
    Get the version number of the compiled mbgdevio library.
    If the mbgdevio library is built as a DLL/shared object then 
    the version number of the compiled library may differ from
    the version number of the import library and header files
    which have been used to build an application.

    @return The version number

    @see ::MBGDEVIO_VERSION defined in mbgdevio.h.
  */
 _MBG_API_ATTR int _MBG_API mbgdevio_get_version( void ) ;

 /**
    Check if the version of the compiled mbgdevio library is compatible
    with a certain version which is passed as parameter.

    @param header_version Version number to be checked, should be ::MBGDEVIO_VERSION 
                          defined in mbgdevio.h.

    @return ::MBG_SUCCESS if compatible, ::MBG_ERR_LIB_NOT_COMPATIBLE if not.

    @see ::MBGDEVIO_VERSION defined in mbgdevio.h.
  */
 _MBG_API_ATTR int _MBG_API mbgdevio_check_version( int header_version ) ;

 /**
    Open a device by index, starting from 0.
    This function is <b>out of date</b>, mbg_open_device_by_name() 
    should be used instead.

    See the <b>note</b> for mbg_find_device() for details.

    @param device_index Index of the device, use 0 for the first device.
  */
 _MBG_API_ATTR MBG_DEV_HANDLE _MBG_API mbg_open_device( unsigned int device_index ) ;

 /**
    Get the number of supported devices installed on the computer. 
    This function is <b>out of date</b>, mbg_find_devices_with_names() 
    should be used instead.

    <b>Note:</b> This function is out of date since it may not work 
    correctly for Meinberg devices which are disconnected and reconnected
    while the system is running (e.g. USB devices). However, the function 
    will be kept for compatibility reasons and works correctly if all 
    Meinberg devices are connected at system boot and are not disconnected 
    and reconnected during operation

    @return The number of devices found.

    @see mbg_find_devices_with_names()
  */
 _MBG_API_ATTR int _MBG_API mbg_find_devices( void ) ;

 /**
    Return the number of supported devices installed on the system and 
    set up a list of unique names of those devices.

    This function should be used preferably instead of mbg_find_devices().

    @param device_list Pointer to a linked list of type ::MBG_DEVICENAME_LIST 
                       with device names. The list will be allocated by this 
                       function and has to be freed after usage by calling 
                       mbg_free_device_name_list().
    @param max_devices Maximum number of devices the function should look for 
                       (can not exceed ::MBG_MAX_DEVICES).

    @return Number of present devices

    @see ::MBG_HW_NAME for the format of the unique names
    @see mbg_free_device_name_list()
    @see mbg_find_devices()
  */
 _MBG_API_ATTR int _MBG_API mbg_find_devices_with_names( MBG_DEVICENAME_LIST **device_list,  int max_devices ) ;

 /**
    Free the memory of the ::MBG_DEVICENAME_LIST that has been allocated before 
    by mbg_find_devices_with_names().

    @param *list Linked list of type ::MBG_DEVICENAME_LIST

    @see mbg_find_devices_with_names()
  */
 _MBG_API_ATTR void _MBG_API mbg_free_device_name_list( MBG_DEVICENAME_LIST *list) ;

 /**
    Return a handle to a device with a certain unique name.
    The names of the devices that are installed on the system can be retrieved by
    the function mbg_find_devices_with_names().

    This function should be used preferably instead of mbg_open_device().

    @param hw_name String with the unique name of the device to be opened
    @param selection_mode One of the enum values of ::MBG_MATCH_MODE

    @return On success, the function returns a handle to the device, otherwise ::MBG_INVALID_DEV_HANDLE

    @see ::MBG_HW_NAME for the format of the unique names.
    @see ::MBG_MATCH_MODE
    @see mbg_find_devices_with_names()
  */
 _MBG_API_ATTR MBG_DEV_HANDLE _MBG_API mbg_open_device_by_name( const char* hw_name, int selection_mode )  //##++++
;

 /**
    Close a handle to a device and set the handle value to ::MBG_INVALID_DEV_HANDLE.
    If required, unmap mapped memory.

    @param dev_handle Handle to a Meinberg device.
  */
 _MBG_API_ATTR void _MBG_API mbg_close_device( MBG_DEV_HANDLE *dev_handle ) ;

 /**
    Return a ::PCPS_DRVR_INFO structure that provides information 
    about the kernel device driver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_DRVR_INFO structure which is filled up.

    @return ::MBG_SUCCESS or error code returned by device I/O control function
  */
 _MBG_API_ATTR int _MBG_API mbg_get_drvr_info( MBG_DEV_HANDLE dh, PCPS_DRVR_INFO *p ) ;

 /**
    Return a ::PCPS_DEV structure that provides detailed information about the device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_DEV structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function
  */
 _MBG_API_ATTR int _MBG_API mbg_get_device_info( MBG_DEV_HANDLE dh, PCPS_DEV *p ) ;

 /**
    Return the current state of the on-board::PCPS_STATUS_PORT.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_STATUS_PORT value to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function

    @see \ref group_status_port "bitmask"
  */
 _MBG_API_ATTR int _MBG_API mbg_get_status_port( MBG_DEV_HANDLE dh, PCPS_STATUS_PORT *p ) ;

 /* (Intentionally excluded from Doxygen)
    Generic read function which writes a command code to the device 
    and reads a number of replied data to a generic buffer.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any command code.

    @param dh Valid handle to a Meinberg device
    @param cmd Can be any \ref group_cmd_bytes "command byte" supported by the device
    @param *p Pointer to a buffer to be filled up
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_generic_write()
    @see mbg_generic_read_gps()
    @see mbg_generic_write_gps()
    @see mbg_generic_io()
  */
 _MBG_API_ATTR int _MBG_API mbg_generic_read( MBG_DEV_HANDLE dh, int cmd, void *p, int size ) ;

 /* (Intentionally excluded from Doxygen)
    Generic read function which writes a GPS command code to the device 
    and reads a number of replied data to a generic buffer.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any GPS command code.

    @param dh Valid handle to a Meinberg device
    @param cmd Can be any \ref group_cmd_bytes "command byte" supported by the device.
    @param *p Pointer to a buffer to be filled up
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_gps_data()
    @see mbg_generic_write_gps()
    @see mbg_generic_read()
    @see mbg_generic_write()
    @see mbg_generic_io()
  */
 _MBG_API_ATTR int _MBG_API mbg_generic_read_gps( MBG_DEV_HANDLE dh, int cmd, void *p, int size ) ;

 /* (Intentionally excluded from Doxygen)
    Generic write function which writes a command code plus an 
    associated number of data bytes to the device.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any command code.

    @param dh   Valid handle to a Meinberg device
    @param cmd  Can be any \ref group_cmd_bytes "command byte" supported by the device.
    @param *p   Pointer to a buffer to be written
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_generic_read()
    @see mbg_generic_read_gps()
    @see mbg_generic_write_gps()
    @see mbg_generic_io()
  */
 _MBG_API_ATTR int _MBG_API mbg_generic_write( MBG_DEV_HANDLE dh, int cmd, const void *p, int size ) ;

 /* (Intentionally excluded from Doxygen)
    Generic write function which writes a GPS command code plus an 
    associated number of data bytes to the device.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Warning</b>: This is for debugging purposes only!
    The specialized API calls should be used preferably.
    A specific device may not support any GPS command code.

    @param dh   Valid handle to a Meinberg device
    @param cmd  Can be any \ref group_cmd_bytes "command byte" supported by the device.
    @param *p   Pointer to a buffer to be written
    @param size Size of the buffer *p

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_gps_data()
    @see mbg_generic_read_gps()
    @see mbg_generic_read()
    @see mbg_generic_write()
    @see mbg_generic_io()
  */
 _MBG_API_ATTR int _MBG_API mbg_generic_write_gps( MBG_DEV_HANDLE dh, int cmd, const void *p, int size ) ;

 /* (Intentionally excluded from Doxygen)
    Write and/or read generic data to/from a device.
    The macro _pcps_has_generic_io() or the API call mbg_dev_has_generic_io()
    check whether this call is supported by a specific card.

    <b>Warning</b>: This call is for debugging purposes and internal use only!

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_generic_io()
    @see mbg_generic_read()
    @see mbg_generic_write()
    @see mbg_generic_read_gps()
    @see mbg_generic_write_gps()
  */
 _MBG_API_ATTR int _MBG_API mbg_generic_io( MBG_DEV_HANDLE dh, int type, const void *in_p, int in_sz, void *out_p, int out_sz ) ;

 /**
    Read a ::PCPS_TIME structure returning the current date/time/status.
    The returned time is local time according to the card's time zone setting, 
    with a resolution of 10 ms (i.e. 10ths of seconds).

    This call is supported by any device manufactured by Meinberg. However,
    for higher accuracy and resolution the mbg_get_hr_time..() group of calls 
    should be used preferably if supported by the specific device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time()
    @see mbg_set_time()
    @see mbg_get_sync_time()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_time( MBG_DEV_HANDLE dh, PCPS_TIME *p ) ;

 /**
    Set a device's on-board clock manually by passing a ::PCPS_STIME structure
    The macro _pcps_can_set_time() checks whether this call 
    is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_STIME structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time()
  */
 _MBG_API_ATTR int _MBG_API mbg_set_time( MBG_DEV_HANDLE dh, const PCPS_STIME *p ) ;

 /**
    Read a ::PCPS_TIME structure returning the date/time/status reporting 
    when the device was synchronized the last time to its time source, 
    e.g. the DCF77 signal or the GPS satellites.
    The macro _pcps_has_sync_time() or the API call mbg_dev_has_sync_time() 
    check whether this call is supported by a specific card.

    The macro _pcps_has_sync_time() checks whether this call 
    is supported by a specific card.

    <b>Note:</b> If that information is not available on the board then 
    the value of the returned ::PCPS_TIME::sec field is set to 0xFF. 
    The macro _pcps_time_is_read() can be used to check whether the 
    returned information is valid, or not available.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_sync_time( MBG_DEV_HANDLE dh, PCPS_TIME *p ) ;

 /**
    Wait until the next second change, then return a ::PCPS_TIME 
    structure similar to mbg_get_time().

    <b>Note:</b> This API call is supported under Windows only. 
    The call blocks until the kernel driver detects a second change 
    reported by the device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_time_sec_change( MBG_DEV_HANDLE dh, PCPS_TIME *p ) ;

 /**
    Read a ::PCPS_HR_TIME (High Resolution time) structure returning 
    the current %UTC time (seconds since 1970), %UTC offset, and status.
    The macro _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() 
    check whether this call is supported by a specific card.

    <b>Note:</b> This API call provides a higher accuracy and resolution 
    than mbg_get_time(). However, it does not account for the latency 
    which is introduced when accessing the board. 
    The mbg_get_hr_time_cycles() and mbg_get_hr_time_comp() calls
    provides mechanisms to account for and/or compensate the latency.

    @param  dh  Valid handle to a Meinberg device
    @param  *p  Pointer to a ::PCPS_HR_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_hr_time()
    @see mbg_get_time()
    @see mbg_get_hr_time_cycles()
    @see mbg_get_hr_time_comp()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_hr_time( MBG_DEV_HANDLE dh, PCPS_HR_TIME *p ) ;

 /* (Intentionally excluded from Doxygen )
    Write a high resolution time stamp ::PCPS_TIME_STAMP to the clock 
    to configure a %UTC time when the clock shall generate an event.
    The macro _pcps_has_event_time() or the API call mbg_dev_has_event_time() 
    check whether this call is supported by a specific card.

    <b>Note:</b> This is only supported by some special firmware.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_event_time()
  */
 _MBG_API_ATTR int _MBG_API mbg_set_event_time( MBG_DEV_HANDLE dh, const PCPS_TIME_STAMP *p ) ;

 /**
    Read the configuration of a device's serial port.
    The macro _pcps_has_serial() checks whether this call 
    is supported by a specific card.

    <b>Note:</b> This function is supported only by a certain class 
    of devices, so it should not be called directly. The generic 
    function mbg_get_serial_settings() should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_SERIAL structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see \ref group_cmd_bytes
    @see mbg_get_serial_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_serial( MBG_DEV_HANDLE dh, PCPS_SERIAL *p ) ;

 /**
    Write the configuration of a device's serial port.
    The macro _pcps_has_serial() checks whether this call 
    is supported by a specific card.

    <b>Note:</b> This function is supported only by a certain class 
    of devices, so it should not be called directly. The generic 
    function mbg_save_serial_settings() should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_SERIAL structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see \ref group_cmd_bytes
    @see mbg_save_serial_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_set_serial( MBG_DEV_HANDLE dh, const PCPS_SERIAL *p ) ;

 /**
    Read the card's time zone/daylight saving configuration code. 
    That tzcode is supported by some simpler cards and only allows only 
    a very basic configuration. 
    The macro _pcps_has_tzcode() or the API call mbg_dev_has_tzcode() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_get_pcps_tzdl() or mbg_get_gps_tzdl()
    calls instead which allow for a more detailed configuration of the 
    time zone and daylight saving settings.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZCODE structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzcode()
    @see mbg_set_tzcode()
    @see mbg_get_pcps_tzdl()
    @see mbg_get_gps_tzdl()
    @see \ref group_cmd_bytes
  */
 _MBG_API_ATTR int _MBG_API mbg_get_tzcode( MBG_DEV_HANDLE dh, PCPS_TZCODE *p ) ;

 /**
    Write the card's time zone/daylight saving configuration code. 
    That tzcode is supported by some simpler cards and only allows only 
    a very basic configuration. 
    The macro _pcps_has_tzcode() or the API call mbg_dev_has_tzcode() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_set_pcps_tzdl() or mbg_set_gps_tzdl()
    calls instead which allow for a more detailed configuration of the 
    time zone and daylight saving settings.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZCODE structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzcode()
    @see mbg_get_tzcode()
    @see mbg_set_pcps_tzdl()
    @see mbg_set_gps_tzdl()
    @see \ref group_cmd_bytes
  */
 _MBG_API_ATTR int _MBG_API mbg_set_tzcode( MBG_DEV_HANDLE dh, const PCPS_TZCODE *p ) ;

 /**
    Read the card's time zone/daylight saving parameters using the 
    ::PCPS_TZDL structure. 
    The macro _pcps_has_pcps_tzdl() or the API call mbg_dev_has_pcps_tzdl() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_get_tzcode() or mbg_get_gps_tzdl() 
    calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZDL structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pcps_tzdl()
    @see mbg_set_pcps_tzdl()
    @see mbg_get_tzcode()
    @see mbg_get_gps_tzdl()
    @see \ref group_cmd_bytes
  */
 _MBG_API_ATTR int _MBG_API mbg_get_pcps_tzdl( MBG_DEV_HANDLE dh, PCPS_TZDL *p ) ;

 /**
    Write the card's time zone/daylight saving parameters using the 
    ::PCPS_TZDL structure. 
    The macro _pcps_has_pcps_tzdl() or the API call mbg_dev_has_pcps_tzdl() 
    check whether this call is supported by a specific card.
    Other cards may support the mbg_set_tzcode() or mbg_set_gps_tzdl() 
    calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TZDL structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pcps_tzdl()
    @see mbg_get_pcps_tzdl()
    @see mbg_set_tzcode()
    @see mbg_set_gps_tzdl()
    @see \ref group_cmd_bytes
  */
 _MBG_API_ATTR int _MBG_API mbg_set_pcps_tzdl( MBG_DEV_HANDLE dh, const PCPS_TZDL *p ) ;

 /**
    Read the reference time offset from %UTC for clocks which can't determine 
    that offset automatically, e.g. from an IRIG input signal. 
    The macro _pcps_has_ref_offs() or the API call mbg_dev_has_ref_offs() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_REF_OFFS value to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ref_offs()
    @see mbg_set_ref_offs()
    @see ::PCPS_GET_REF_OFFS
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ref_offs( MBG_DEV_HANDLE dh, MBG_REF_OFFS *p ) ;

 /**
    Write the reference time offset from %UTC for clocks which can't determine 
    that offset automatically, e.g. from an IRIG input signal. 
    The macro _pcps_has_ref_offs() or the API call mbg_dev_has_ref_offs() 
    check whether this call is supported by a specific card.

    @param  dh  Valid handle to a Meinberg device
    @param  *p  Pointer to a ::MBG_REF_OFFS value to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ref_offs()
    @see mbg_get_ref_offs()
    @see ::PCPS_SET_REF_OFFS
  */
 _MBG_API_ATTR int _MBG_API mbg_set_ref_offs( MBG_DEV_HANDLE dh, const MBG_REF_OFFS *p ) ;

 /**
    Read a ::MBG_OPT_INFO structure containing optional settings, controlled by flags.
    The ::MBG_OPT_INFO structure contains a mask of supported flags plus the current 
    settings of those flags.
    The macro _pcps_has_opt_flags() or the API call mbg_dev_has_opt_flags() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_OPT_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_opt_flags()
    @see mbg_set_opt_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_opt_info( MBG_DEV_HANDLE dh, MBG_OPT_INFO *p ) ;

 /**
    Write a ::MBG_OPT_SETTINGS structure contains optional settings, controlled by flags.
    The macro _pcps_has_opt_flags() or the API call mbg_dev_has_opt_flags() 
    check whether this call is supported by a specific card.
    The ::MBG_OPT_INFO structure should be read first to check which of the specified 
    flags is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_OPT_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_opt_flags()
    @see mbg_get_opt_info()
  */
 _MBG_API_ATTR int _MBG_API mbg_set_opt_settings( MBG_DEV_HANDLE dh, const MBG_OPT_SETTINGS *p ) ;

 /**
    Read an ::IRIG_INFO structure containing the configuration of an IRIG input
    plus the possible settings supported by that input.
    The macro _pcps_is_irig_rx() or the API call mbg_dev_is_irig_rx() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an ::IRIG_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_irig_rx_settings()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
  */
 _MBG_API_ATTR int _MBG_API mbg_get_irig_rx_info( MBG_DEV_HANDLE dh, IRIG_INFO *p ) ;

 /**
    Write an ::IRIG_SETTINGS structure containing the configuration of an IRIG input.
    The macro _pcps_is_irig_rx() or the API call mbg_dev_is_irig_rx() 
    check whether this call is supported by a specific card.
    The ::IRIG_INFO structure should be read first to determine the possible 
    settings supported by this card's IRIG input.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::IRIG_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_rx_info()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
  */
 _MBG_API_ATTR int _MBG_API mbg_set_irig_rx_settings( MBG_DEV_HANDLE dh, const IRIG_SETTINGS *p ) ;

 /**
    Check if a specific device supports the mbg_get_irig_ctrl_bits() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_ctrl_bits()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_irig_ctrl_bits( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a ::MBG_IRIG_CTRL_BITS type which contains the control function
    bits of the latest IRIG input frame. Those bits may carry some 
    well-known information, as in the IEEE1344 code, but may also contain 
    some customized information, depending on the IRIG frame type and 
    the configuration of the IRIG generator. So these bits are returned 
    as-is and must be interpreted by the application.
    The macro _pcps_has_irig_ctrl_bits() or the API call mbg_dev_has_irig_ctrl_bits()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_IRIG_CTRL_BITS type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_irig_ctrl_bits()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_irig_ctrl_bits( MBG_DEV_HANDLE dh, MBG_IRIG_CTRL_BITS *p ) ;

 /**
    Check if a specific device supports the mbg_get_raw_irig_data() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_raw_irig_data()
    @see mbg_get_raw_irig_data_on_sec_change()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_raw_irig_data( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a ::MBG_RAW_IRIG_DATA type which contains all data
    bits of the latest IRIG input frame.
    The macro _pcps_has_raw_irig_data() or the API call mbg_dev_has_raw_irig_data()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_RAW_IRIG_DATA type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_raw_irig_data()
    @see mbg_get_raw_irig_data_on_sec_change()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_raw_irig_data( MBG_DEV_HANDLE dh, MBG_RAW_IRIG_DATA *p ) ;

 /**
    Read a ::MBG_RAW_IRIG_DATA type just after a second change which contains all data
    bits of the latest IRIG input frame.
    The macro _pcps_has_raw_irig_data() or the API call mbg_dev_has_raw_irig_data()
    check whether this call is supported by a specific card.

    <b>Note:</b> The mbg_get_time_sec_change() function called by this function is
    supported under Windows only, so this function can also only be used under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_RAW_IRIG_DATA type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_raw_irig_data()
    @see mbg_get_raw_irig_data()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_raw_irig_data_on_sec_change( MBG_DEV_HANDLE dh, MBG_RAW_IRIG_DATA *p ) ;

 /**
    Check if a specific device supports the mbg_get_irig_time() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_time()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_irig_time( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a ::PCPS_IRIG_TIME type which returns the raw IRIG day-of-year number
    and time decoded from the latest IRIG input frame. If the configured IRIG code
    also contains the year number then the year number is also returned, otherwise
    the returned year number is 0xFF.
    The macro _pcps_has_irig_time() or the API call mbg_dev_has_irig_time()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_IRIG_TIME type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_irig_time()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_irig_time( MBG_DEV_HANDLE dh, PCPS_IRIG_TIME *p ) ;

 /**
    Clear the card's on-board time capture FIFO buffer.
    The macro _pcps_can_clr_ucap_buff() or the API call mbg_dev_can_clr_ucap_buff() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_can_clr_ucap_buff()
    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
  */
 _MBG_API_ATTR int _MBG_API mbg_clr_ucap_buff( MBG_DEV_HANDLE dh ) ;

 /**
    Read a ::PCPS_UCAP_ENTRIES structure to retrieve the number of saved 
    user capture events and the maximum capture buffer size.
    The macro _pcps_has_ucap() or the API call mbg_dev_has_ucap() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_UCAP_ENTRIES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ucap()
    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ucap_entries( MBG_DEV_HANDLE dh, PCPS_UCAP_ENTRIES *p ) ;

 /**
    Retrieve a single time capture event from the on-board FIFO buffer 
    using a ::PCPS_HR_TIME structure. The oldest entry of the FIFO is retrieved 
    and then removed from the FIFO. 
    If no capture event is available in the FIFO buffer then both the seconds 
    and the fractions of the returned timestamp are 0.
    The macro _pcps_has_ucap() or the API call mbg_dev_has_ucap() 
    check whether this call is supported by a specific card.

    <b>Note:</b> This call is very much faster than the older mbg_get_gps_ucap()
    call which is obsolete but still supported for compatibility with 
    older cards.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_HR_TIME structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ucap()
    @see mbg_get_ucap_entries()
    @see mbg_clr_ucap_buff()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ucap_event( MBG_DEV_HANDLE dh, PCPS_HR_TIME *p ) ;

 /**
    Read the card's time zone/daylight saving parameters using the ::TZDL
    structure. 
    The macro _pcps_has_tzdl() or the API call mbg_dev_has_tzdl() 
    check whether this call is supported by a specific card.

    <b>Note:</b> In spite of the function name this call may also be 
    supported by non-GPS cards. Other cards may support the mbg_get_tzcode()
    or mbg_get_pcps_tzdl() calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TZDL structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzdl()
    @see mbg_set_gps_tzdl()
    @see mbg_get_tzcode()
    @see mbg_get_pcps_tzdl()
    @see \ref group_tzdl
  */
 _MBG_API_ATTR int _MBG_API mbg_get_gps_tzdl( MBG_DEV_HANDLE dh, TZDL *p ) ;

 /**
    Write the card's time zone/daylight saving parameters using the ::TZDL
    structure. 
    The macro _pcps_has_tzdl() or the API call mbg_dev_has_tzdl() 
    check whether this call is supported by a specific card.

    <b>Note:</b> In spite of the function name this call may also be 
    supported by non-GPS cards. Other cards may support the mbg_set_tzcode() 
    or mbg_set_pcps_tzdl() calls instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TZDL structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzdl()
    @see mbg_get_gps_tzdl()
    @see mbg_set_tzcode()
    @see mbg_set_pcps_tzdl()
    @see \ref group_tzdl
  */
 _MBG_API_ATTR int _MBG_API mbg_set_gps_tzdl( MBG_DEV_HANDLE dh, const TZDL *p ) ;

 /**
    Retrieve the software revision of a GPS receiver.
    This call is obsolete but still supported for compatibility 
    with older GPS cards.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> The function mbg_get_gps_receiver_info() should 
    be used instead, if supported by the card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SW_REV structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_is_gps()
    @see mbg_get_gps_receiver_info()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_gps_sw_rev( MBG_DEV_HANDLE dh, SW_REV *p ) ;

 /**
    Retrieve the status of the battery buffered GPS variables.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.
    The GPS receiver stays in cold boot mode until all of the 
    data sets are valid.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::BVAR_STAT structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_bvar_stat( MBG_DEV_HANDLE dh, BVAR_STAT *p ) ;

 /**
    Read the current board time using a ::TTM structure.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This call is pretty slow, so the mbg_get_hr_time_..() 
    group of calls should be used preferably.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TTM structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_time( MBG_DEV_HANDLE dh, TTM *p ) ;

 /**
    Write a ::TTM structure to a GPS receiver in order to set the 
    on-board date and time.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TTM structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_time( MBG_DEV_HANDLE dh, const TTM *p ) ;

 /**
    Read a ::PORT_PARM structure to retrieve the configuration 
    of the device's serial ports.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This function is obsolete since it is only 
    supported by a certain class of devices and can handle only 
    up to 2 ports. The generic function mbg_get_serial_settings() 
    should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PORT_PARM structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_serial_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_port_parm( MBG_DEV_HANDLE dh, PORT_PARM *p ) ;

 /**
    Write a ::PORT_PARM structure to configure the on-board 
    serial ports.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This function is obsolete since it is only 
    supported by a certain class of devices and can handle only 
    up to 2 ports. The generic function mbg_save_serial_settings() 
    should be used instead. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PORT_PARM structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_save_serial_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_port_parm( MBG_DEV_HANDLE dh, const PORT_PARM *p ) ;

 /**
    Read an ::ANT_INFO structure to retrieve status information of the GPS antenna.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> Normally the antenna connection status can also be 
    determined by evaluation of the ::PCPS_TIME::signal or ::PCPS_HR_TIME::signal
    fields.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ANT_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_ant_info( MBG_DEV_HANDLE dh, ANT_INFO *p ) ;

 /**
    Read a time capture event from the on-board FIFO buffer using a ::TTM structure.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    <b>Note:</b> This call is pretty slow and has been obsoleted by 
    mbg_get_ucap_event() which should be used preferably, if supported 
    by the card. Anyway, this call is still supported for compatibility 
    with older cards.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TTM structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
    @see mbg_clr_ucap_buff()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_ucap( MBG_DEV_HANDLE dh, TTM *p ) ;

 /**
    Read an ::ENABLE_FLAGS structure reporting whether certain outputs 
    shall be enabled immediately after the card's power-up, or only 
    after the card has synchronized to its input signal.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Note:</b> Not all of the input signals specified for the 
    ::ENABLE_FLAGS structure can be modified individually.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::ENABLE_FLAGS structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ::ENABLE_FLAGS
    @see mbg_set_gps_enable_flags()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_enable_flags( MBG_DEV_HANDLE dh, ENABLE_FLAGS *p ) ;

 /**
    Write an ENABLE_FLAGS structure to configure whether certain outputs 
    shall be enabled immediately after the card's power-up, or only 
    after the card has synchronized to its input signal.
    The macro _pcps_has_gps_data() or the API call mbg_dev_has_gps_data()
    check whether this call is supported by a specific card.

    <b>Note:</b> Not all of the input signals specified for the 
    ENABLE_FLAGS structure can be modified individually.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ENABLE_FLAGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ENABLE_FLAGS
    @see mbg_get_gps_enable_flags()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_enable_flags( MBG_DEV_HANDLE dh, const ENABLE_FLAGS *p ) ;

 /**
    Read a ::STAT_INFO structure to retrieve the status of the 
    GPS receiver, including mode of operation and numer of 
    visible/usable satellites.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::STAT_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ::STAT_INFO
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_stat_info( MBG_DEV_HANDLE dh, STAT_INFO *p ) ;

 /**
    Sends a ::GPS_CMD to a GPS receiver.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::GPS_CMD

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see ::PC_GPS_CMD_BOOT, ::PC_GPS_CMD_INIT_SYS, ::PC_GPS_CMD_INIT_USER, ::PC_GPS_CMD_INIT_DAC
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_cmd( MBG_DEV_HANDLE dh, const GPS_CMD *p ) ;

 /**
    Read the current GPS receiver position using the ::POS structure 
    which contains different coordinate formats.
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::POS structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pos_xyz()
    @see mbg_set_gps_pos_lla()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_pos( MBG_DEV_HANDLE dh, POS *p ) ;

 /**
    Preset the GPS receiver position using ::XYZ coordinates 
    (ECEF: WGS84 "Earth Centered, Earth fixed" kartesian coordinates).
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param p Position in ::XYZ format to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pos_lla()
    @see mbg_get_gps_pos()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_pos_xyz( MBG_DEV_HANDLE dh, const XYZ p ) ;

 /**
    Preset the GPS receiver position using ::LLA coordinates 
    (longitude, latitude, altitude)
    The macro _pcps_is_gps() or the API call mbg_dev_is_gps()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param p Position in ::LLA format to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pos_xyz()
    @see mbg_get_gps_pos()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_pos_lla( MBG_DEV_HANDLE dh, const LLA p ) ;

 /**
    Read the configured length of the GPS antenna cable (::ANT_CABLE_LEN).
    The cable delay is internally compensated by 5ns per meter cable.
    The macro _pcps_has_cab_len() or the API call mbg_dev_has_cab_len()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::ANT_CABLE_LEN structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_cab_len()
    @see mbg_set_gps_ant_cable_len()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_ant_cable_len( MBG_DEV_HANDLE dh, ANT_CABLE_LEN *p ) ;

 /**
    Write the length of the GPS antenna cable (::ANT_CABLE_LEN).
    The cable delay is internally compensated by 5ns per meter cable.
    The macro _pcps_has_cab_len() or the API call mbg_dev_has_cab_len()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::ANT_CABLE_LEN structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_cab_len()
    @see mbg_get_gps_ant_cable_len()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_ant_cable_len( MBG_DEV_HANDLE dh, const ANT_CABLE_LEN *p ) ;

 /**
    Read a ::RECEIVER_INFO structure from a card.
    The macro _pcps_has_receiver_info() or the API call mbg_dev_has_receiver_info()
    check whether this call is supported by a specific card.

    <b>Note:</b> Applications should call mbg_setup_receiver_info() 
    preferably, which also sets up a basic ::RECEIVER_INFO structure 
    for card which don't provide that structure by themselves.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::RECEIVER_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_setup_receiver_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_receiver_info( MBG_DEV_HANDLE dh, RECEIVER_INFO *p ) ;

 /**
    Read a ::STR_TYPE_INFO_IDX array of supported string types.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.

    <b>Note:</b> The function mbg_get_serial_settings() should be used preferably
    to get retrieve the current port settings and configuration options.

    @param dh Valid handle to a Meinberg device.
    @param stii Pointer to a an array of string type information to be filled up
    @param *p_ri Pointer to a ::RECEIVER_INFO structure returned by mbg_setup_receiver_info()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_setup_receiver_info()
    @see mbg_get_gps_all_port_info()
    @see mbg_get_serial_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_all_str_type_info( MBG_DEV_HANDLE dh, STR_TYPE_INFO_IDX stii[], const RECEIVER_INFO *p_ri ) ;

 /**
    Read a ::PORT_INFO_IDX array of supported serial port configurations.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.

    <b>Note:</b> The function mbg_get_serial_settings() should be used preferably
    to get retrieve the current port settings and configuration options.

    @param dh Valid handle to a Meinberg device.
    @param pii Pointer to a an array of port configuration information to be filled up
    @param *p_ri Pointer to a ::RECEIVER_INFO structure returned by mbg_setup_receiver_info()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_setup_receiver_info()
    @see mbg_get_gps_all_str_type_info()
    @see mbg_get_serial_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_all_port_info( MBG_DEV_HANDLE dh, PORT_INFO_IDX pii[], const RECEIVER_INFO *p_ri ) ;

 /**
    Write the configuration for a single serial port using the ::PORT_SETTINGS_IDX
    structure which contains both the ::PORT_SETTINGS and the port index value.
    Except for the parameter types, this call is equivalent to mbg_set_gps_port_settings().
    The macro _pcps_has_receiver_info() or the API call mbg_dev_has_receiver_info()
    check whether this call is supported by a specific card.

    <b>Note:</b> The function mbg_save_serial_settings() should be used preferably 
    to write new port configuration to the board.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::PORT_SETTINGS_IDX structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_save_serial_settings()
    @see mbg_set_gps_port_settings()
    @see mbg_dev_has_receiver_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_port_settings_idx( MBG_DEV_HANDLE dh, const PORT_SETTINGS_IDX *p ) ;

 /**
    Write the configuration for a single serial port using the ::PORT_SETTINGS 
    structure plus the port index.
    Except for the parameter types, this call is equivalent to mbg_set_gps_port_settings_idx().
    The macro _pcps_has_receiver_info() or the API call mbg_dev_has_receiver_info()
    check whether this call is supported by a specific card.

    <b>Note:</b> The function mbg_save_serial_settings() should be used preferably 
    to write new port configuration to the board.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::PORT_SETTINGS structure to be filled up
    @param idx Index of the serial port to be configured (starting from 0 ).

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_save_serial_settings()
    @see mbg_set_gps_port_settings_idx()
    @see mbg_dev_has_receiver_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_port_settings( MBG_DEV_HANDLE dh, const PORT_SETTINGS *p, int idx ) ;

 /**
    Set up a ::RECEIVER_INFO structure for a device.
    If the device supports the ::RECEIVER_INFO structure then the structure
    is read from the device, otherwise a structure is set up using 
    default values depending on the device type.
    The function mbg_get_device_info() must have been called before, 
    and the returned PCPS_DEV structure passed to this function.

    @param dh Valid handle to a Meinberg device.
    @param *pdev Pointer to a ::PCPS_DEV structure returned by mbg_get_device_info()
    @param *p Pointer to a ::RECEIVER_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_device_info()
    @see mbg_dev_has_receiver_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_setup_receiver_info( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev, RECEIVER_INFO *p ) ;

 /**
    Read the version code of the on-board PCI/PCIe interface ASIC.
    The macro _pcps_has_asic_version() or the API call mbg_dev_has_asic_version()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCI_ASIC_VERSION type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function

    @see mbg_dev_has_asic_version()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_asic_version( MBG_DEV_HANDLE dh, PCI_ASIC_VERSION *p ) ;

 /**
    Read the features of the on-board PCI/PCIe interface ASIC.
    The macro _pcps_has_asic_features() or the API call mbg_dev_has_asic_features()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::PCI_ASIC_FEATURES type to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_asic_features()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_asic_features( MBG_DEV_HANDLE dh, PCI_ASIC_FEATURES *p ) ;

 /**
    Check if a specific device supports configurable time scales.

    By default the cards return UTC and/or local time. However, some cards 
    can be configured to return pure GPS time or TAI instead.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time_scale_info()
    @see mbg_set_time_scale_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_time_scale( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a ::MBG_TIME_SCALE_INFO structure from a card telling which time scales
    are supported by a card, and the current settings of the card.

    The macro _pcps_has_time_scale() or the API call mbg_dev_has_time_scale()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_time_scale().

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_SCALE_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_time_scale_settings()
    @see mbg_dev_has_time_scale()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_time_scale_info( MBG_DEV_HANDLE dh, MBG_TIME_SCALE_INFO *p ) ;

 /**
    Write a ::MBG_TIME_SCALE_SETTINGS structure to a card which determines 
    which time scale shall be represented by time stamps read from the card. 

    The macro _pcps_has_time_scale() or the API call mbg_dev_has_time_scale()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_time_scale().

    The function mbg_get_time_scale_info() should have been called before 
    in order to determine which time scales are supported by the card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_SCALE_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_time_scale_info()
    @see mbg_dev_has_time_scale()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_time_scale_settings( MBG_DEV_HANDLE dh, MBG_TIME_SCALE_SETTINGS *p ) ;

 /**
    Check if a specific device supports reading/writing a GPS UTC parameter
    set via the PC bus (reading/writing these parameters via the serial port
    is supported by all GPS devices).

    The UTC parameters are normally received from the satellites' broadcasts
    and contain the current time offset between GPT time and UTC, plus information
    on a pending leap second.

    It may be useful to overwrite them to do some tests, or for applications 
    where a card is freewheeling.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_utc_parm()
    @see mbg_set_utc_parm()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_utc_parm( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a ::UTC structure from a card.

    The macro _pcps_has_utc_parm() or the API call mbg_dev_has_utc_parm()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_utc_parm().

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::UTC structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_utc_parm()
    @see mbg_set_utc_parm()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_utc_parm( MBG_DEV_HANDLE dh, UTC *p ) ;

 /**
    Write a ::UTC structure to a card.

    This should only be done for testing, or if a card is operated in 
    freewheeling mode. If the card receives any satellites the settings 
    written to the board are overwritten by the parameters broadcasted
    by the satellites.

    The macro _pcps_has_utc_parm() or the API call mbg_dev_has_utc_parm()
    check whether this call is supported by a specific card.
    See also the notes for mbg_dev_has_utc_parm().

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a valid ::UTC structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_utc_parm()
    @see mbg_get_utc_parm()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_utc_parm( MBG_DEV_HANDLE dh, UTC *p ) ;

 /**
    Read a ::PCPS_TIME_CYCLES structure that contains a ::PCPS_TIME structure
    and a PC cycle counter value which can be used to compensate the latency
    of the call, i.e. the program execution time until the time stamp has actually
    been read from the board.

    This call is supported for any card, similar to mbg_get_time(). However, 
    the mbg_get_hr_time_cyles() call should be used preferably if supported by 
    the specific card since that call provides much better accuracy than this one.

    The cycle counter value corresponds to a value returned by QueryPerformanceCounter() 
    under Windows, and get_cycles() under Linux. On other operating systems the returned 
    cycles value is always 0.

    Applications should first pick up their own cycle counter value and then call 
    this function. The difference of the cycle counter values corresponds to the 
    latency of the call in units of the cycle counter clock frequency, e.g as reported 
    by QueryPerformanceFrequency() under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_CYCLES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time_cycles()
    @see mbg_get_hr_time_comp()
    @see mbg_get_hr_time()
    @see mbg_get_time()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_time_cycles( MBG_DEV_HANDLE dh, PCPS_TIME_CYCLES *p ) ;

 /**
    Read a ::PCPS_HR_TIME_CYCLES structure that contains a ::PCPS_HR_TIME structure
    and a PC cycle counter value which can be used to compensate the latency
    of the call, i.e. the program execution time until the time stamp has actually
    been read from the board.

    The macro _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() 
    check whether this call is supported by a specific card.

    The cycle counter value corresponds to a value returned by QueryPerformanceCounter() 
    under Windows, and get_cycles() under Linux. On other operating systems the returned 
    cycles value is always 0.

    Applications should first pick up their own cycle counter value and then call 
    this function. The difference of the cycle counter values corresponds to the 
    latency of the call in units of the cycle counter clock frequency, e.g as reported 
    by QueryPerformanceFrequency() under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_HR_TIME_CYCLES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time_comp()
    @see mbg_get_hr_time()
    @see mbg_get_time_cycles()
    @see mbg_get_time()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_hr_time_cycles( MBG_DEV_HANDLE dh, PCPS_HR_TIME_CYCLES *p ) ;

 /**
    Read a ::PCPS_HR_TIME structure plus cycle counter value, and correct the 
    time stamp for the latency of the call as described for mbg_get_hr_time_cycles(),
    then return the compensated time stamp and optionally the latency.

    The macro _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() 
    check whether this call is supported by a specific card.

    The cycle counter value corresponds to a value returned by QueryPerformanceCounter() 
    under Windows, and get_cycles() under Linux. On other operating systems the returned 
    cycles value is always 0.

    Applications should first pick up their own cycle counter value and then call 
    this function. The difference of the cycle counter values corresponds to the 
    latency of the call in units of the cycle counter clock frequency, e.g as reported 
    by QueryPerformanceFrequency() under Windows.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_HR_TIME structure to be filled up
    @param *hns_latency Optional pointer to an int32_t value to return 
              the latency in 100ns units. Pass NULL if not used.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time_comp()
    @see mbg_get_hr_time()
    @see mbg_get_time_cycles()
    @see mbg_get_time()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_hr_time_comp( MBG_DEV_HANDLE dh, PCPS_HR_TIME *p, int32_t *hns_latency ) ;

 /**
    Read an ::IRIG_INFO structure containing the configuration of an IRIG output
    plus the possible settings supported by that output.
    The macro _pcps_has_irig_tx() or the API call mbg_dev_has_irig_tx() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an ::IRIG_INFO structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_irig_tx_settings()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
*/
 _MBG_API_ATTR int _MBG_API mbg_get_irig_tx_info( MBG_DEV_HANDLE dh, IRIG_INFO *p ) ;

 /**
    Write an ::IRIG_SETTINGS structure containing the configuration of an IRIG output.
    The macro _pcps_has_irig_tx() or the API call mbg_dev_has_irig_tx() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an ::IRIG_INFO structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_tx_info()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig()
    @see \ref group_icode
*/
 _MBG_API_ATTR int _MBG_API mbg_set_irig_tx_settings( MBG_DEV_HANDLE dh, const IRIG_SETTINGS *p ) ;

 /**
    Read a ::SYNTH structure containing the configuration of an optional 
    on-board programmable frequency synthesizer.
    The macro _pcps_has_synth() or the API call mbg_dev_has_synth() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SYNTH structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_synth()
    @see mbg_set_synth()
    @see mbg_get_synth_state()
    @see \ref group_synth
*/
 _MBG_API_ATTR int _MBG_API mbg_get_synth( MBG_DEV_HANDLE dh, SYNTH *p ) ;

 /**
    Write a ::SYNTH structure containing the configuration of an optional 
    on-board programmable frequency synthesizer.
    The macro _pcps_has_synth() or the API call mbg_dev_has_synth() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SYNTH structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_synth()
    @see mbg_get_synth()
    @see mbg_get_synth_state()
    @see \ref group_synth
*/
 _MBG_API_ATTR int _MBG_API mbg_set_synth( MBG_DEV_HANDLE dh, const SYNTH *p ) ;

 /**
    Read a ::SYNTH_STATE structure reporting the current state 
    of an optional on-board programmable frequency synthesizer.
    The macro _pcps_has_synth() or the API call mbg_dev_has_synth() 
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::SYNTH_STATE structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_synth()
    @see mbg_get_synth()
    @see mbg_set_synth()
    @see \ref group_synth
*/
 _MBG_API_ATTR int _MBG_API mbg_get_synth_state( MBG_DEV_HANDLE dh, SYNTH_STATE *p ) ;

 /**
    Check if a specific device supports the mbg_get_fast_hr_timestamp_...() calls.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_fast_hr_timestamp_cycles()
    @see mbg_get_fast_hr_timestamp_comp()
    @see mbg_get_fast_hr_timestamp()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_fast_hr_timestamp( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a high resolution ::PCPS_TIME_STAMP_CYCLES structure via memory mapped access.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP_CYCLES structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_fast_hr_timestamp_comp()
    @see mbg_get_fast_hr_timestamp()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_fast_hr_timestamp_cycles( MBG_DEV_HANDLE dh, PCPS_TIME_STAMP_CYCLES *p ) ;

 /**
    Read a high resolution ::PCPS_TIME_STAMP via memory mapped access,
    and compensate the latency of the time stamp before it is returned.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP structure to be filled up
    @param *hns_latency Optionally receive the latency in hectonanoseconds

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_fast_hr_timestamp_cycles()
    @see mbg_get_fast_hr_timestamp()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_fast_hr_timestamp_comp( MBG_DEV_HANDLE dh, PCPS_TIME_STAMP *p, int32_t *hns_latency ) ;

 /**
    Read a high resolution ::PCPS_TIME_STAMP structure via memory mapped access.

    This function does not return or evaluate a cycles count, so the latency
    of the call can not be determined. However, depending on the timer hardware
    used as cycles counter it may take quite some time to read the cycles count
    on some hardware architectures, so this call can be used to yield lower 
    latencies, under the restriction to be unable to determine the exact latency.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_TIME_STAMP structure to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_fast_hr_timestamp_comp()
    @see mbg_get_fast_hr_timestamp_cycles()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_fast_hr_timestamp( MBG_DEV_HANDLE dh, PCPS_TIME_STAMP *p ) ;

 /**
    Check if a specific device is a GPS receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_is_gps( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device is a DCF77 receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_is_dcf( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device is a MSF receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_is_msf( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device is a WWVB receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_is_wwvb( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device is a long wave signal receiver, e.g. DCF77, MSF or WWVB.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_is_lwr( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device is an IRIG receiver which supports 
    configuration of the IRIG input.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_rx_info()
    @see mbg_set_irig_rx_settings()
    @see mbg_dev_has_irig_tx()
    @see mbg_dev_has_irig()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_is_irig_rx( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports the HR_TIME functions.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_hr_time()
    @see mbg_get_hr_time_cycles()
    @see mbg_get_hr_time_comp()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_hr_time( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports configuration of antenna cable length.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_ant_cable_len()
    @see mbg_set_gps_ant_cable_len()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_cab_len( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports timezone / daylight saving configuration 
    using the ::TZDL structure.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_tzdl()
    @see mbg_set_gps_tzdl()
    @see mbg_dev_has_tz()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_tzdl( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports timezone / daylight saving configuration 
    using the ::PCPS_TZDL structure.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_pcps_tzdl()
    @see mbg_set_pcps_tzdl()
    @see mbg_dev_has_tz()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_pcps_tzdl( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports timezone configuration 
    using the ::PCPS_TZCODE type.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_tzcode()
    @see mbg_set_tzcode()
    @see mbg_dev_has_tz()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_tzcode( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports any kind of timezone configuration.
    This can be used e.g. to check if a specifig dialog or menu has to 
    be displayed. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_tzdl()
    @see mbg_dev_has_pcps_tzdl()
    @see mbg_dev_has_tzcode()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_tz( MBG_DEV_HANDLE dh, int *p ) ;

 /* (Intentionally excluded from Doxygen)
    Check if a specific device supports setting an event time, i.e. 
    configure a %UTC time when the clock shall generate an event.

    <b>Note:</b> This is only supported by some special firmware.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_event_time()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_event_time( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports the ::RECEIVER_INFO structure and related calls.
    Older GPS devices may not support that structure.

    The mbg_get_gps_receiver_info() call uses this call to decide whether a 
    ::RECEIVER_INFO can be read directly from a device, or whether a default 
    structure has to be set up using default values depending on the device type.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_receiver_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_receiver_info( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports the mbg_clr_ucap_buff() call 
    used to clear a card's on-board time capture FIFO buffer.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_clr_ucap_buff()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_can_clr_ucap_buff( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports the mbg_get_ucap_entries() and
    mbg_get_ucap_event() calls. 

    If the card does not but it is a GPS card then the card provides 
    a time capture FIFO buffer and the obsolete mbg_get_gps_ucap()
    call can be used to retrieve entries from the FIFO buffer.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ucap_entries()
    @see mbg_get_ucap_event()
    @see mbg_clr_ucap_buff()
    @see mbg_get_gps_ucap()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_ucap( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device provides an IRIG output which can 
    be configured.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_irig_tx_info()
    @see mbg_set_irig_tx_settings()
    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig()
    @see \ref group_icode

*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_irig_tx( MBG_DEV_HANDLE dh, int *p ) ;

 /* (Intentionally excluded from Doxygen)
    Check if a specific device provides a serial output supporting 
    higher baud rates than older cards, i.e. ::DEFAULT_BAUD_RATES_DCF_HS
    rather than ::DEFAULT_BAUD_RATES_DCF. 

    The mbg_get_serial_settings() takes care of this, so applications
    which use that call as suggested won't need to use this call directly.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_serial_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_serial_hs( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device provides an input signal level value which
    may be displayed, e.g. DCF77 or IRIG cards.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_signal( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device provides an modulation signal which may be 
    displayed, e.g. the second marks of a DCF77 AM receiver.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_mod( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device provides either an IRIG input or output.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_is_irig_rx()
    @see mbg_dev_has_irig_tx()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_irig( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device provides a configurable ref time offset
    required to convert the received time to %UTC.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ref_offs()
    @see mbg_set_ref_offs()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_ref_offs( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports the ::MBG_OPT_INFO/::MBG_OPT_SETTINGS 
    structures containing optional settings, controlled by flags.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_opt_info()
    @see mbg_set_opt_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_opt_flags( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports large configuration data structures
    as have been introducesde with the GPS receivers. 

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_gps_data( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device provides a programmable frequency synthesizer.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_synth()
    @see mbg_set_synth()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_synth( MBG_DEV_HANDLE dh, int *p ) ;

 /* (Intentionally excluded from Doxygen)
    Check if a specific device supports the mbg_generic_io() call.

    <b>Warning</b>: That call is for debugging purposes and internal use only!

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_generic_io()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_generic_io( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports the mbg_get_asic_version() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_asic_version()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_asic_version( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports the mbg_get_asic_features() call.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_asic_features()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_asic_features( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a ::POUT_INFO_IDX array of current settings and configuration
    options of a card's programmable pulse outputs.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.
    The function should only be called if the ::RECEIVER_INFO::n_prg_out 
    field (i.e. the number of programmable outputs on the board) is not 0.

    The array passed to this function to receive the returned data 
    must be able to hold at least ::RECEIVER_INFO::n_prg_out elements.

    @param dh Valid handle to a Meinberg device.
    @param pii Pointer to a an array of ::POUT_INFO_IDX structures to be filled up
    @param *p_ri Pointer to a ::RECEIVER_INFO structure returned by mbg_setup_receiver_info()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_set_gps_pout_settings_idx()
    @see mbg_set_gps_pout_settings()
    @see mbg_setup_receiver_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_get_gps_all_pout_info( MBG_DEV_HANDLE dh, POUT_INFO_IDX pii[], const RECEIVER_INFO *p_ri ) ;

 /**
    Write the configuration for a single programmable pulse output using 
    the ::POUT_SETTINGS_IDX structure which contains both the ::POUT_SETTINGS 
    and the output index value.
    Except for the parameter types, this call is equivalent to 
    mbg_set_gps_pout_settings().
    The function should only be called if the ::RECEIVER_INFO::n_prg_out field 
    (i.e. the number of programmable outputs on the board) is not 0, and the 
    output index value must be in the range 0..::RECEIVER_INFO::n_prg_out.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::POUT_SETTINGS_IDX structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_all_pout_info()
    @see mbg_set_gps_pout_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_pout_settings_idx( MBG_DEV_HANDLE dh, const POUT_SETTINGS_IDX *p ) ;

 /**
    Write the configuration for a single programmable pulse output using 
    the ::POUT_SETTINGS structure plus the index of the output to be configured.
    Except for the parameter types, this call is equivalent to 
    mbg_set_gps_pout_settings_idx().
    The function should only be called if the ::RECEIVER_INFO::n_prg_out field 
    (i.e. the number of programmable outputs on the board) is not 0, and the 
    output index value must be in the range 0..::RECEIVER_INFO::n_prg_out.

    @param dh Valid handle to a Meinberg device.
    @param *p Pointer to a ::POUT_SETTINGS structure to be written
    @param idx Index of the programmable pulse output to be configured (starting from 0 ).

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_gps_all_pout_info()
    @see mbg_set_gps_pout_settings_idx()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_gps_pout_settings( MBG_DEV_HANDLE dh, const POUT_SETTINGS *p, int idx ) ;

 /**
    Read a card's IRQ status information which includes flags indicating
    whether IRQs are currently enabled, and whether IRQ support by a card 
    is possibly unsafe due to the firmware and interface chip version.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PCPS_IRQ_STAT_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.
  */
 _MBG_API_ATTR int _MBG_API mbg_get_irq_stat_info( MBG_DEV_HANDLE dh, PCPS_IRQ_STAT_INFO *p ) ;

 /**
    Check if a specific device provides simple LAN interface API calls.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_state()
    @see mbg_get_ip4_settings()
    @see mbg_set_ip4_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_lan_intf( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read LAN interface information from a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::LAN_IF_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_ip4_state()
    @see mbg_get_ip4_settings()
    @see mbg_set_ip4_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_lan_if_info( MBG_DEV_HANDLE dh, LAN_IF_INFO *p ) ;

 /**
    Read LAN IPv4 state from a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::IP4_SETTINGS variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_settings()
    @see mbg_set_ip4_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ip4_state( MBG_DEV_HANDLE dh, IP4_SETTINGS *p ) ;

 /**
    Read LAN IPv4 settings from a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::IP4_SETTINGS variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_state()
    @see mbg_set_ip4_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ip4_settings( MBG_DEV_HANDLE dh, IP4_SETTINGS *p ) ;

 /**
    Write LAN IPv4 settings to a card which supports this.
    The macro _pcps_has_lan_intf() or the API call mbg_dev_has_lan_intf()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::IP4_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_lan_intf()
    @see mbg_get_lan_if_info()
    @see mbg_get_ip4_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_ip4_settings( MBG_DEV_HANDLE dh, const IP4_SETTINGS *p ) ;

 /**
    Check if a specific device provides PTP configuration/status calls.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ptp_state()
    @see mbg_get_ptp_cfg_info()
    @see mbg_set_ptp_cfg_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_ptp( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device provides PTP Unicast feature/configuration.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_ptp_state()
    @see mbg_get_ptp_uc_master_cfg_limits()
    @see mbg_get_all_ptp_uc_master_info()
    @see mbg_set_ptp_unicast_cfg_settings()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_ptp_unicast( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read PTP/IEEE1588 status from a card which supports this.
    The macro _pcps_has_ptp() or the API call mbg_dev_has_ptp()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PTP_CFG_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp()
    @see mbg_get_ptp_cfg_info()
    @see mbg_set_ptp_cfg_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ptp_state( MBG_DEV_HANDLE dh, PTP_STATE *p ) ;

 /**
    Read PTP/IEEE1588 config info and current settings from a card which supports this.
    The macro _pcps_has_ptp() or the API call mbg_dev_has_ptp()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PTP_CFG_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp()
    @see mbg_get_ptp_state()
    @see mbg_set_ptp_cfg_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ptp_cfg_info( MBG_DEV_HANDLE dh, PTP_CFG_INFO *p ) ;

 /**
    Write PTP/IEEE1588 configuration settings to a card which supports this.
    The macro _pcps_has_ptp() or the API call mbg_dev_has_ptp()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::PTP_CFG_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp()
    @see mbg_get_ptp_state()
    @see mbg_get_ptp_cfg_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_ptp_cfg_settings( MBG_DEV_HANDLE dh, const PTP_CFG_SETTINGS *p ) ;

 /**
    Read PTP/IEEE1588 unicast config info and current settings from a card which supports this.
    The macro _pcps_has_ri_ptp_unicast() or the API call mbg_dev_has_ptp_unicast()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::PTP_UNICAST_CFG_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp_unicast()
    @see mbg_set_ptp_unicast_cfg_settings()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_ptp_uc_master_cfg_limits( MBG_DEV_HANDLE dh, PTP_UC_MASTER_CFG_LIMITS *p ) ;

 /**
    Read a ::IOCTL_SET_PTP_UNICAST_CFG_SETTINGS array of current settings and configuration
    options of a card's programmable pulse outputs.
    The function mbg_setup_receiver_info() must have been called before,
    and the returned ::RECEIVER_INFO structure passed to this function.
    The function should only be called if the ::RECEIVER_INFO::n_prg_out 
    field (i.e. the number of programmable outputs on the board) is not 0.

    The array passed to this function to receive the returned data 
    must be able to hold at least ::RECEIVER_INFO::n_prg_out elements.

    @param dh Valid handle to a Meinberg device.
    @param pii Pointer to a an array of ::PTP_UC_MASTER_INFO_IDX structures to be filled up
    @param p_umsl Pointer to a ::PTP_UC_MASTER_CFG_LIMITS structure returned by mbg_get_ptp_uc_master_cfg_limits()

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see //##++++++++++++++++++++++
    @see 
    @see 
*/
 _MBG_API_ATTR int _MBG_API mbg_get_all_ptp_uc_master_info( MBG_DEV_HANDLE dh, PTP_UC_MASTER_INFO_IDX pii[], const PTP_UC_MASTER_CFG_LIMITS *p_umsl ) ;

 /**
    Write PTP/IEEE1588 unicast configuration settings to a card which supports this.
    The macro _pcps_has_ri_ptp_unicast() or the API call mbg_dev_has_ptp_unicast()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device.
    @param *p ::PTP_UNICAST_CFG_SETTINGS structure to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_ptp_unicast()
    @see mbg_get_ptp_state()
    @see mbg_get_ptp_cfg_info()
    @see mbg_get_ptp_unicast_cfg_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_set_ptp_uc_master_settings_idx( MBG_DEV_HANDLE dh, const PTP_UC_MASTER_SETTINGS_IDX *p ) ;

 /**
    Read system time and card time from the kernel driver. The kernel
    driver reads the current system time plus a HR time structure from
    a card immediately after each other. The returned info structure also
    contains some cycles counts to be able to determine the execution times
    required to read those time stamps.

    The advantage of this call compared to mbg_get_time_info_tstamp() is
    that this call also returns the card's status. On the other hand, reading
    the HR time from the card may block e.g. if another application accesses
    the board.

    This call makes a mbg_get_hr_time_cycles() call internally so the macro
    _pcps_has_hr_time() or the API call mbg_dev_has_hr_time() can be 
    used to check whether this call is supported with a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_INFO_HRT variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_hr_time()
    @see mbg_get_time_info_tstamp()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_time_info_hrt( MBG_DEV_HANDLE dh, MBG_TIME_INFO_HRT *p ) ;

 /**
    This call is similar to mbg_get_time_info_hrt() except that a
    mbg_get_fast_hr_timestamp_cycles() call is made internally, so the macro
    _pcps_has_fast_hr_timestamp() or the API call mbg_dev_has_fast_hr_timestamp()
    can be used to check whether this call is supported with a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_TIME_INFO_TSTAMP variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_fast_hr_timestamp()
    @see mbg_get_time_info_hrt()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_time_info_tstamp( MBG_DEV_HANDLE dh, MBG_TIME_INFO_TSTAMP *p ) ;

 /**
    Check if a specific device supports demodulation of the DCF77 PZF code.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_corr_info()
    @see mbg_dev_has_tr_distance()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_pzf( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports reading correlation info.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_get_corr_info()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_corr_info( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Check if a specific device supports configurable distance from transmitter
    used to compensate RF propagation delay.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_get_tr_distance()
    @see mbg_set_tr_distance()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_tr_distance( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read PZF correlation info from a card which supports this.
    The macro _pcps_has_corr_info() or the API call mbg_dev_has_corr_info()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::CORR_INFO variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_dev_has_corr_info()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_corr_info( MBG_DEV_HANDLE dh, CORR_INFO *p ) ;

 /**
    Read configurable "distance from transmitter" parameter from a card
    which supports this. The parameter is used to compensate the RF signal
    propagation delay.
    The macro _pcps_has_tr_distance() or the API call mbg_dev_has_tr_distance()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TR_DISTANCE variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_dev_has_tr_distance()
    @see mbg_set_tr_distance()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_tr_distance( MBG_DEV_HANDLE dh, TR_DISTANCE *p ) ;

 /**
    Write configurable "distance from transmitter" parameter to a card
    which supports this. The parameter is used to compensate the RF signal
    propagation delay.
    The macro _pcps_has_tr_distance() or the API call mbg_dev_has_tr_distance()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::TR_DISTANCE variable to be written

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_pzf()
    @see mbg_dev_has_tr_distance()
    @see mbg_get_tr_distance()
  */
 _MBG_API_ATTR int _MBG_API mbg_set_tr_distance( MBG_DEV_HANDLE dh, const TR_DISTANCE *p ) ;

 /**
    Check if a specific device provides a debug status word to be read.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_debug_status()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_debug_status( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Read a debug status word from a card. This is mainly supported
    by IRIG timecode receiver cards, and the status word is intended
    to provide more detailed information why a card might not synchronize
    to the incoming timecode signal.

    The macro _pcps_has_debug_status() or the API call mbg_dev_has_debug_status()
    check whether this call is supported by a specific card.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_DEBUG_STATUS variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_debug_status()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_debug_status( MBG_DEV_HANDLE dh, MBG_DEBUG_STATUS *p ) ;

 /**
    Check if a specific device provides an on-board event log.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_clr_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_first_evt_log_entry()
    @see mbg_get_next_evt_log_entry()
*/
 _MBG_API_ATTR int _MBG_API mbg_dev_has_evt_log( MBG_DEV_HANDLE dh, int *p ) ;

 /**
    Clear the card's on-board event log.
    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    @param dh Valid handle to a Meinberg device

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_first_evt_log_entry()
    @see mbg_get_next_evt_log_entry()
  */
 _MBG_API_ATTR int _MBG_API mbg_clr_evt_log( MBG_DEV_HANDLE dh ) ;

 /**
    Read max number of num event log entries which can
    be saved on the board, and how many entries actually
    have been saved.
    _pcps_has_evt_log() checks whether supported.

    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_NUM_EVT_LOG_ENTRIES variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_clr_evt_log()
    @see mbg_get_first_evt_log_entry()
    @see mbg_get_next_evt_log_entry()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_num_evt_log_entries( MBG_DEV_HANDLE dh, MBG_NUM_EVT_LOG_ENTRIES *p ) ;

 /**
    Read the first (oldest) event log entry from a device.

    @note Subsequent reads should be made using mbg_get_next_evt_log_entry().

    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    If no (more) event log entry is available on the device then
    the returned MBG_EVT_LOG_ENTRY::code is MBG_EVT_ID_NONE.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_EVT_LOG_ENTRY variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_clr_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_next_evt_log_entry()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_first_evt_log_entry( MBG_DEV_HANDLE dh, MBG_EVT_LOG_ENTRY *p ) ;

 /**
    Read the next event log entry from a device.

    @note The first read should be made using mbg_get_first_evt_log_entry()
    to set the on-board read index to the oldest entry.

    The macro _pcps_has_evt_log() or the API call mbg_dev_has_evt_log()
    check whether this call is supported by a specific device.

    If no (more) event log entry is available on the device then
    the returned MBG_EVT_LOG_ENTRY::code is MBG_EVT_ID_NONE.

    @param dh Valid handle to a Meinberg device
    @param *p Pointer to a ::MBG_EVT_LOG_ENTRY variable to be filled up

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_dev_has_evt_log()
    @see mbg_clr_evt_log()
    @see mbg_get_num_evt_log_entries()
    @see mbg_get_first_evt_log_entry()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_next_evt_log_entry( MBG_DEV_HANDLE dh, MBG_EVT_LOG_ENTRY *p ) ;

 /**
    Read the CPU affinity of a process, i.e. on which of the available
    CPUs the process can be executed.

    @param pid The process ID.
    @param *p Pointer to a ::MBG_CPU_SET variable which contains a mask of CPUs.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_set_process_affinity()
    @see mbg_set_current_process_affinity_to_cpu()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_process_affinity( MBG_PROCESS_ID pid, MBG_CPU_SET *p ) ;

 /**
    Set the CPU affinity of a process, i.e. on which of the available 
    CPUs the process is allowed to be executed.

    @param pid The process ID.
    @param *p Pointer to a ::MBG_CPU_SET variable which contains a mask of CPUs.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_get_process_affinity()
    @see mbg_set_current_process_affinity_to_cpu()
  */
 _MBG_API_ATTR int _MBG_API mbg_set_process_affinity( MBG_PROCESS_ID pid, MBG_CPU_SET *p ) ;

 /**
    Set the CPU affinity of a process for a single CPU only, i.e. the process
    may only be executed on that single CPU.

    @param cpu_num The number of the CPU.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_get_process_affinity()
    @see mbg_set_process_affinity()
  */
 _MBG_API_ATTR int _MBG_API mbg_set_current_process_affinity_to_cpu( int cpu_num ) ;

 /**
    Create a new execution thread for the current process.
    This function is only implemented for targets which support threads.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure to be filled up.
    @param fnc The name of the thread function to be started.
    @param arg A generic argument passed to the thread function.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_thread_stop()
    @see mbg_thread_sleep_interruptible()
    @see mbg_thread_set_affinity()
  */
 _MBG_API_ATTR int _MBG_API mbg_thread_create( MBG_THREAD_INFO *p_ti, MBG_THREAD_FNC_RET_VAL (MBG_THREAD_FNC_ATTR *fnc)(void *), void *arg ) ;

 /**
    Stop a thread which has been created by mbg_thread_create(). Wait 
    until the thread has finished and release all resources.
    This function is only implemented for targets which support threads.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure associated with the thread.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_thread_create()
    @see mbg_thread_sleep_interruptible()
    @see mbg_thread_set_affinity()
  */
 _MBG_API_ATTR int _MBG_API mbg_thread_stop( MBG_THREAD_INFO *p_ti ) ;

 /**
    Let the current thread sleep for a certain interval unless a signal is
    received indicating the thread should terminate.
    This function is only implemented for targets which support threads.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure associated with the thread.
    @param sleep_ms The number of milliseconds to sleep
    @return 0 if the sleep interval has expired normally
            1 if a signal to terminate has been received
            <0 if an error has occurred

    @see mbg_thread_create()
    @see mbg_thread_stop()
    @see mbg_thread_set_affinity()
  */
 _MBG_API_ATTR int _MBG_API mbg_thread_sleep_interruptible( MBG_THREAD_INFO *p_ti, ulong sleep_ms ) ;

 /**
    Set the CPU affinity of a single thread, i.e. on which of the available 
    CPUs the thread is allowed to be executed.
    This function is only implemented for targets which support thread affinity.

    @param p_ti Pointer to a ::MBG_THREAD_INFO structure associated with the thread.
    @param *p Pointer to a ::MBG_CPU_SET variable which contains a mask of CPUs.

    @return ::MBG_SUCCESS or error code returned by the system call.

    @see mbg_thread_create()
    @see mbg_thread_stop()
    @see mbg_thread_sleep_interruptible()
  */
 _MBG_API_ATTR int _MBG_API mbg_thread_set_affinity( MBG_THREAD_INFO *p_ti, MBG_CPU_SET *p ) ;

 /**
    Set up a ::MBG_POLL_THREAD_INFO structure and start a new thread 
    which runs the mbg_xhrt_poll_thread_fnc() function.
    This function is only implemented for targets which support threads.

    @param *p_pti Pointer to a ::MBG_POLL_THREAD_INFO structure.
    @param dh the handle of the device to be polled.
    @param freq_hz The initial cycles frequency, if known, in Hz.
    @param sleep_ms the sleep interval for the poll thread function in ms. 
           If this parameter is 0 then the default sleep interval is used.

    @return ::MBG_SUCCESS on success,
            ::MBG_ERR_NOT_SUPP_BY_DEV if the device to poll does not support HR time
            else the result of mbg_thread_create() 

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_time_as_filetime()
    @see mbg_get_xhrt_cycles_frequency()
  */
 _MBG_API_ATTR int _MBG_API mbg_xhrt_poll_thread_create( MBG_POLL_THREAD_INFO *p_pti, MBG_DEV_HANDLE dh, MBG_PC_CYCLES_FREQUENCY freq_hz, int sleep_ms ) ;

 /**
    Stop a polling thread started by mbg_xhrt_poll_thread_create() 
    and release all associated resources.

    @param *p_pti Pointer to a ::MBG_POLL_THREAD_INFO structure.

    @return the result of mbg_thread_stop() 

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_time_as_filetime()
    @see mbg_get_xhrt_cycles_frequency()
  */
 _MBG_API_ATTR int _MBG_API mbg_xhrt_poll_thread_stop( MBG_POLL_THREAD_INFO *p_pti ) ;

 /**
    Retrieve a time stamp in PCPS_HR_TIME format which is extrapolated
    using the system's current cycles counter value and a time stamp 
    plus associated cycles counter value saved by the polling thread.
    See mbg_xhrt_poll_thread_fnc() for details and limitations.
    This function is only implemented for targets which support threads.

    @param *p Pointer to a ::MBG_XHRT_INFO structure used to retrieve data from the polling thread.
    @param *p_hrt Pointer to a ::PCPS_HR_TIME structure to be filled up.

    @return MBG_SUCCESS or another return value from the polling thread's IOCTL call.

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_filetime()
    @see mbg_get_xhrt_cycles_frequency()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_xhrt_time_as_pcps_hr_time( MBG_XHRT_INFO *p, PCPS_HR_TIME *p_hrt ) ;

 /**
    Retrieve a time stamp in FILETIME format which is extrapolated
    using the system's current cycles counter value and a time stamp 
    plus associated cycles counter value saved by the polling thread.
    See mbg_xhrt_poll_thread_fnc() for details and limitations.
    Since FILETIME is a Windows specific type this function is only 
    implemented under Windows.

    @param *p Pointer to a ::MBG_XHRT_INFO structure used to retrieve data from the polling thread.
    @param *p_ft Pointer to a ::FILETIME structure to be filled up.

    @return MBG_SUCCESS or another return value from the polling thread's IOCTL call.

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_cycles_frequency()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_xhrt_time_as_filetime( MBG_XHRT_INFO *p, FILETIME *p_ft ) ;

 /**
    Retrieve the frequency of the system's cycles counter as determined
    by the device polling thread.
    See mbg_xhrt_poll_thread_fnc() for details and limitations.
    This function is only implemented for targets which support threads.

    @param *p Pointer to a ::MBG_XHRT_INFO structure used to retrieve data from the polling thread.
    @param *p_freq_hz Pointer to a ::MBG_PC_CYCLES_FREQUENCY variable in which the frequency is returned.
    @return a status code from the polling thread: MBG_SUCCESS or an IOCTL error code.

    @see mbg_xhrt_poll_thread_fnc()
    @see mbg_xhrt_poll_thread_create()
    @see mbg_xhrt_poll_thread_stop()
    @see mbg_get_xhrt_time_as_pcps_hr_time()
    @see mbg_get_xhrt_time_as_filetime()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_xhrt_cycles_frequency( MBG_XHRT_INFO *p, MBG_PC_CYCLES_FREQUENCY *p_freq_hz ) ;

 /**
    Retrieve the default system's cycles counter frequency from the kernel driver. 

    @param dh handle of the device to which the IOCTL call is sent.
    @param *p Pointer of a ::MBG_PC_CYCLES_FREQUENCY variable to be filled up.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_default_cycles_frequency()
  */
 _MBG_API_ATTR int _MBG_API mbg_get_default_cycles_frequency_from_dev( MBG_DEV_HANDLE dh, MBG_PC_CYCLES_FREQUENCY *p ) ;

 /**
  Retrieve the default system's cycles counter frequency.

  @note This may not be supported on all target platforms, in which case the
  returned frequency is 0 and the mbg_get_default_cycles_frequency_from_dev()
  call should be used.

  @return the default cycles counter frequency in Hz, or 0 if the value is not available.

  @see mbg_get_default_cycles_frequency_from_dev()
*/
 _MBG_API_ATTR MBG_PC_CYCLES_FREQUENCY _MBG_API mbg_get_default_cycles_frequency( void ) ;


/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


#if defined( MBG_TGT_WIN32 )

static __mbg_inline
MBGDEVIO_RET_VAL do_mbg_ioctl( MBG_DEV_HANDLE dh, int ioctl_code, 
                               const void *in_p, int in_sz, void *out_p, int out_sz )
{
  DWORD ReturnedLength;

  if ( !DeviceIoControl( dh, ioctl_code,
                         (LPVOID) in_p, in_sz, out_p, out_sz,
                         &ReturnedLength,
                         NULL
                       ) )
  {
    DWORD rc = GetLastError();

#if 0  //##++++++++++++++++++++++++
// We can't call mbgsvctl_log_mbgdevio_error() here (for now).
// Is is defined in mbgsvctl.h, and including mbgsvc.h here,
// or copying the prototype here results in DLL import/export
// mismatch errors.

    // do not report a USB device timeout error
    if ( rc != _mbg_err_to_os( MBG_ERR_USB_ACCESS ) )
      mbgsvctl_log_mbgdevio_error( ioctl_code, rc );
#endif

    return rc;
  }

  return MBG_SUCCESS;

}  // do_mbg_ioctl

  #define _do_mbg_ioctl( _dh, _ioctl, _p, _in_sz, _out_sz ) \
    do_mbg_ioctl( _dh, _ioctl, (LPVOID) _p, _in_sz, (LPVOID) _p, _out_sz )

#elif defined( MBG_TGT_UNIX )

  #define _do_mbg_ioctl( _dh, _ioctl, _p, _in_sz, _out_sz ) \
    ioctl( _dh, _ioctl, _p )

#endif



// The code below depends on whether the target device is accessed via
// IOCTLs to a device driver, or the hardware is accessed directly.

#if defined( _MBGIOCTL_H )  // using IOCTL to access device driver

/**
   @brief Send a generic IOCTL command to the driver.

   @param dh    Valid handle to a Meinberg device
   @param info  Additional information for the kernel driver depending on
                the IOCTL code, i.e. the low level function to be called: <br>
                  one of the PCPS_... commands with IOCTL_PCPS_GENERIC_{READ|WRITE}<br>
                  one of the PC_GPS_... commands with IOCTL_PCPS_GENERIC_{READ|WRITE}_GPS<br>
                  one of the PCPS_GEN_IO_... enumeration codes with IOCTL_PCPS_GENERIC_IO
   @param ioctl One of the IOCTL_GENERIC_... codes telling the kernel driver
                which low level function to use, e.g. normal read or write,
                large (GPS) data read or write, or generic I/O.
   @param *p Pointer to an int which is set 0 or != 0 unless the call fails.

   @return ::MBG_SUCCESS or error code returned by device I/O control function.
*/
  static __mbg_inline
  int mbgdevio_do_gen_io( MBG_DEV_HANDLE dh, int info, unsigned int ioctl_code,
                          const void *in_p, int in_sz,
                          void *out_p, int out_sz )
  {
    _mbgdevio_vars();

    // Generic IOCTL calls always need to pass some info beside
    // the I/O buffers down to the driver, which usually is
    // the command code for the device.
    // Thus we must always use one of the control structures
    // IOCTL_GENERIC_REQ or IOCTL_GENERIC_BUFFER, whichever
    // is appropriate for the target OS.

    #if USE_IOCTL_GENERIC_REQ

      IOCTL_GENERIC_REQ req = { 0 };

      req.info = info;
      req.in_p = in_p;
      req.in_sz = in_sz;
      req.out_p = out_p;
      req.out_sz = out_sz;

      rc = _do_mbg_ioctl( dh, ioctl_code, &req, sizeof( req ), 0 );

    #else

      IOCTL_GENERIC_BUFFER *p_buff;
      int buff_size = sizeof( p_buff->ctl )
                    + ( ( in_sz > out_sz ) ? in_sz : out_sz );

      p_buff = (IOCTL_GENERIC_BUFFER *) malloc( buff_size );

      if ( p_buff == NULL )
        return _mbg_err_to_os( MBG_ERR_NO_MEM );

      p_buff->ctl.info = info;
      p_buff->ctl.data_size_in = in_sz;
      p_buff->ctl.data_size_out = out_sz;

      if ( in_p )
        memcpy( p_buff->data, in_p, in_sz );

      rc = _do_mbg_ioctl( dh, ioctl_code, p_buff,
                          sizeof( IOCTL_GENERIC_CTL ) + in_sz,
                          sizeof( IOCTL_GENERIC_CTL ) + out_sz );

      if ( out_p && ( rc == MBG_SUCCESS ) )
        memcpy( out_p, p_buff->data, out_sz );

      free( p_buff );

    #endif

    return _mbgdevio_ret_val;

  }  // mbgdevio_do_gen_io



  #define _do_mbgdevio_read( _dh, _cmd, _ioctl, _p, _sz ) \
    _do_mbg_ioctl( _dh, _ioctl, _p, 0, _sz )

  #define _do_mbgdevio_write( _dh, _cmd, _ioctl, _p, _sz ) \
    _do_mbg_ioctl( _dh, _ioctl, _p, _sz, 0 )

  #define _do_mbgdevio_read_gps      _do_mbgdevio_read

  #define _do_mbgdevio_write_gps     _do_mbgdevio_write



  #define _mbgdevio_read_var( _dh, _cmd, _ioctl, _p ) \
    _do_mbgdevio_read( _dh, _cmd, _ioctl, _p, sizeof( *(_p) ) )

  #define _mbgdevio_write_var( _dh, _cmd, _ioctl, _p ) \
    _do_mbgdevio_write( _dh, _cmd, _ioctl, _p, sizeof( *(_p) ) )

  #define _mbgdevio_write_cmd( _dh, _cmd, _ioctl ) \
    _do_mbgdevio_write( _dh, _cmd, _ioctl, NULL, 0 )

  #define _mbgdevio_read_gps_var    _mbgdevio_read_var

  #define _mbgdevio_write_gps_var   _mbgdevio_write_var


  #define _mbgdevio_gen_read( _dh, _cmd, _p, _sz ) \
    mbgdevio_do_gen_io( _dh, _cmd, IOCTL_PCPS_GENERIC_READ, NULL, 0, _p, _sz )

  #define _mbgdevio_gen_write( _dh, _cmd, _p, _sz ) \
    mbgdevio_do_gen_io( _dh, _cmd, IOCTL_PCPS_GENERIC_WRITE, _p, _sz, NULL, 0 )

  #define _mbgdevio_gen_io( _dh, _type, _in_p, _in_sz, _out_p, _out_sz ) \
    mbgdevio_do_gen_io( _dh, _type, IOCTL_PCPS_GENERIC_IO, _in_p, _in_sz, _out_p, _out_sz )

  #define _mbgdevio_gen_read_gps( _dh, _cmd, _p, _sz ) \
    mbgdevio_do_gen_io( _dh, _cmd, IOCTL_PCPS_GENERIC_READ_GPS, NULL, 0, _p, _sz )

  #define _mbgdevio_gen_write_gps( _dh, _cmd, _p, _sz ) \
    mbgdevio_do_gen_io( _dh, _cmd, IOCTL_PCPS_GENERIC_WRITE_GPS, _p, _sz, NULL, 0 )


#else  // accessing hardware device directly

  #define _mbgdevio_chk_cond( _cond )                   \
  {                                                     \
    if ( !(_cond) )                                     \
      return _mbg_err_to_os( MBG_ERR_NOT_SUPP_BY_DEV ); \
  }

  #define _mbgdevio_read( _dh, _cmd, _ioctl, _p, _sz ) \
    pcps_read_safe( _dh, _cmd, _p, _sz )

  #define _mbgdevio_write( _dh, _cmd, _ioctl, _p, _sz ) \
    pcps_write_safe( _dh, _cmd, _p, _sz )

  #define _do_mbgdevio_read_gps( _dh, _cmd, _ioctl, _p, _sz ) \
    pcps_read_gps_safe( _dh, _cmd, _p, _sz )

  #define _mbgdevio_write_gps( _dh, _cmd, _ioctl, _p, _sz ) \
    pcps_write_gps_safe( _dh, _cmd, _p, _sz )



//##+++++++++++++++++++
  #define _mbgdevio_read_var( _dh, _cmd, _ioctl, _p ) \
    _pcps_read_var_safe( _dh, _cmd, *(_p) )

  #define _mbgdevio_write_var( _dh, _cmd, _ioctl, _p ) \
    _pcps_write_var_safe( _dh, _cmd, *(_p) )

  #define _mbgdevio_write_cmd( _dh, _cmd, _ioctl ) \
    _pcps_write_byte_safe( _dh, _cmd );

  #define _mbgdevio_read_gps_var( _dh, _cmd, _ioctl, _p ) \
    _pcps_read_gps_var_safe( _dh, _cmd, *(_p) )

  #define _mbgdevio_write_gps_var( _dh, _cmd, _ioctl, _p ) \
    _pcps_write_gps_var_safe( _dh, _cmd, *(_p) )


  #define _mbgdevio_gen_read( _dh, _cmd, _p, _sz ) \
    _mbgdevio_read( _dh, _cmd, -1, _p, _sz )

  #define _mbgdevio_gen_write( _dh, _cmd, _p, _sz ) \
    _mbgdevio_write( _dh, _cmd, -1, _p, _sz )

  #define _mbgdevio_gen_io( _dh, _type, _in_p, _in_sz, _out_p, _out_sz ) \
    pcps_generic_io( _dh, _type, _in_p, _in_sz, _out_p, _out_sz );

  #define _mbgdevio_gen_read_gps( _dh, _cmd, _p, _sz ) \
    _do_mbgdevio_read_gps( _dh, _cmd, -1, _p, _sz )

  #define _mbgdevio_gen_write_gps( _dh, _cmd, _p, _sz ) \
    _mbgdevio_write_gps( _dh, _cmd, -1, _p, _sz )

#endif



#define _mbg_generic_read_var( _dh, _cmd, _s )  \
  mbg_generic_read( _dh, _cmd, &(_s), sizeof( (_s) ) )

#define _mbg_generic_write_var( _dh, _cmd, _s )  \
  mbg_generic_write( _dh, _cmd, &(_s), sizeof( (_s) ) )

#define _mbg_generic_read_gps_var( _dh, _cmd, _s )  \
  mbg_generic_read_gps( _dh, _cmd, &(_s), sizeof( (_s) ) )

#define _mbg_generic_write_gps_var( _dh, _cmd, _s )  \
  mbg_generic_write_gps( _dh, _cmd, &(_s), sizeof( (_s) ) )



#define _mbgdevio_gen_read_var( _dh, _cmd, _s ) \
  _mbgdevio_gen_read( _dh, _cmd, &(_s), sizeof( (_s) ) )

#define _mbgdevio_gen_write_var( _dh, _cmd, _s ) \
  _mbgdevio_gen_write( _dh, _cmd, &(_s), sizeof( (_s) ) )

#define _mbgdevio_gen_read_gps_var( _dh, _cmd, _s ) \
  _mbgdevio_gen_read_gps( _dh, _cmd, &(_s), sizeof( (_s) ) )

#define _mbgdevio_gen_write_gps_var( _dh, _cmd, _s ) \
  _mbgdevio_gen_write_gps( _dh, _cmd, &(_s), sizeof( (_s) ) )



#if defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_UNIX )

static __mbg_inline
void mbg_chk_tstamp64_leap_sec( uint64_t *tstamp64, PCPS_TIME_STATUS_X *status )
{
  if ( *status & ( PCPS_LS_ANN | PCPS_LS_ENB ) )
  {
    time_t t  = (uint32_t) ( *tstamp64 >> 32 );
    struct tm tm = *gmtime( &t );

    // Handle leap second and status
    if ( tm.tm_hour == 0 && tm.tm_min == 0 && tm.tm_sec == 0 )
    {
      if ( *status & PCPS_LS_ANN )
      {
        // Set leap second enabled flag on rollover to the leap second and clear announce flag
        *status &= ~PCPS_LS_ANN;
        *status |= PCPS_LS_ENB;

        // Decrement interpolated second to avoid automated overflow during the leap second.
        // Second 59 appears for the second time.
        *tstamp64 -= PCPS_HRT_BIN_FRAC_SCALE;
      }
      else
        if ( *status & PCPS_LS_ENB ) // Clear bits when leap second expires and 0:00:00 UTC is reached
          *status  &= ~( PCPS_LS_ANN | PCPS_LS_ENB );
    }
  }

}  // mbg_chk_tstamp64_leap_sec

#endif  // defined( MBG_TGT_WIN32 ) || defined( MBG_TGT_UNIX )



static __mbg_inline
void mbg_init_pc_cycles_frequency( MBG_DEV_HANDLE dh, MBG_PC_CYCLES_FREQUENCY *p )
{
  if ( *p == 0 )
    mbg_get_default_cycles_frequency_from_dev( dh, p );

}  // mbg_init_pc_cycles_frequency



#if MBG_TGT_HAS_64BIT_TYPES

static __mbg_inline
uint64_t pcps_time_stamp_to_uint64( const PCPS_TIME_STAMP *ts )
{
  return ( ( (uint64_t) ts->sec ) << 32 ) + ts->frac;

}  // pcps_time_stamp_to_uint64



static __mbg_inline
void uint64_to_pcps_time_stamp( PCPS_TIME_STAMP *ts, uint64_t n )
{
  ts->sec = (uint32_t) ( n >> 32 );
  ts->frac = (uint32_t) ( n & 0xFFFFFFFFUL );

}  // uint64_to_pcps_time_stamp

#endif


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */


#undef _ext

#endif  /* _MBGDEVIO_H */

