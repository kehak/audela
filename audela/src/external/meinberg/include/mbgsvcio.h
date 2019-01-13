
/**************************************************************************
 *
 *  $Id: mbgsvcio.h,v 1.1 2011-02-23 14:19:10 myrtillelaas Exp $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for mbgsvcio.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: not supported by cvs2svn $
 *  Revision 1.16  2009/08/14 09:28:13Z  daniel
 *  New version code 306, compatibility version code still 200.
 *  Revision 1.15  2009/06/09 08:57:47Z  daniel
 *  Rev No. 305
 *  Revision 1.14  2009/03/19 09:06:40Z  daniel
 *  New version code 304, compatibility version code still 200.
 *  Revision 1.13  2009/01/12 09:40:18Z  daniel
 *  New version code 303, compatibility version code still 200.
 *  Added comments in doxygen format.
 *  Revision 1.12  2008/01/17 10:14:41Z  daniel
 *  New version code 302, compatibility version code still 200.
 *  Revision 1.11  2007/10/16 10:16:27Z  daniel
 *  New version code 301, compatibility version code still 200.
 *  Revision 1.10  2007/09/24 15:28:17Z  martin
 *  New version code 300, compatibility version code still 200.
 *  Revision 1.9  2007/03/22 09:52:18Z  martin
 *  New version code 219, compatibility version code still 200.
 *  Removed obsolete headers.
 *  Revision 1.8  2006/08/09 13:38:02Z  martin
 *  New version code 218, compatibility version still 200.
 *  Revision 1.7  2006/06/08 12:23:54Z  martin
 *  New version code 217, compatibility version still 200.
 *  Revision 1.6  2006/05/02 12:52:17Z  martin
 *  New version code 216, compatibility version still 200.
 *  Revision 1.5  2006/01/11 12:04:32Z  martin
 *  New version code 215, compatibility version still 200.
 *  Revision 1.4  2005/12/15 09:16:38Z  martin
 *  New version code 214, compatibility version still 200.
 *  Revision 1.3  2005/07/20 07:38:39Z  martin
 *  New version code 213.
 *  Revision 1.2  2005/02/16 15:34:40Z  martin
 *  New version 2.12.
 *  Revision 1.1  2004/07/01 10:00:51Z  martin
 *
 **************************************************************************/

#ifndef _MBGSVCIO_H
#define _MBGSVCIO_H


/* Other headers to be included */

#include <mbg_tgt.h>



#ifdef _MBGSVCIO
  #define _ext
#else
  #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )      // set byte alignment
  #pragma pack( 1 )
#endif

#define MBGSVCIO_VERSION         0x0306

#define MBGSVCIO_COMPAT_VERSION  0x0200


#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 /**
    Get the version number of the compiled mbgsvcio library.
    If the mbgsvcio library is built as a DLL then 
    the version number of the compiled library may differ from
    the version number of the import library and header files
    which have been used to build an application.

    @return The version number

    @see ::MBGSVCIO_VERSION defined in mbgsvcio.h.
*/
 _MBG_API_ATTR int _MBG_API mbgsvcio_get_version( void ) ;

 /**
    Check if the version of the compiled mbgsvcio library is compatible
    with a certain version which is passed as parameter.

    @param header_version Version number to be checked, should be ::MBGSVCIO_VERSION 
                          defined in mbgsvcio.h.

    @return ::MBG_SUCCESS if compatible, ::MBG_WINERR_LIB_NOT_COMPATIBLE if not.

    @see ::MBGSVCIO_VERSION defined in mbgsvcio.h.
  */
 _MBG_API_ATTR int _MBG_API mbgsvcio_check_version( int header_version ) ;

 /**
  Query the status of the Meinberg time adjustment service "mbgadjtm.exe"

  @return   1, if the service has the state "SERVICE_RUNNING", otherwise 0.
*/
 _MBG_API_ATTR int _MBG_API mbg_time_adjustment_active( void ) ;

 /**
  Check if the time of the reference clock is accessible.

  @return    1: The reference clock is accessible and delivers a valid time.<br>
             0: The reference time is invalid or inaccessible.<br>
            -1: The shared memory area which provides information from the 
            service is not accessible.<br>
*/
 _MBG_API_ATTR int _MBG_API mbg_ref_time_accessible( void ) ;

 /**
  Return the current state of the reference clock.

  @return   ::PCPS_TIME_STATUS_X.<br><br>
            The status information can be extracted by using the 
            following bit masks:<br>
            <ul><li>::PCPS_FREER</li>
              <li>::PCPS_DL_ENB</li>
              <li>::PCPS_SYNCD</li>
              <li>::PCPS_DL_ANN</li>
              <li>::PCPS_UTC</li>
              <li>::PCPS_LS_ANN</li>
              <li>::PCPS_IFTM</li>
              <li>::PCPS_INVT</li>
              <li>::PCPS_LS_ENB</li>
              <li>::PCPS_ANT_FAIL</li>
              <li>::PCPS_UCAP_OVERRUN</li>
              <li>::PCPS_UCAP_BUFFER_FULL</li>
              <li>::PCPS_IO_BLOCKED</li>
            </ul>
*/
 _MBG_API_ATTR int _MBG_API mbg_get_ref_time_status( void ) ;


/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif

#if defined( _USE_PACK )   // set default alignment
  #pragma pack()
#endif

/* End of header body */

#undef _ext

#endif  // _MBGSVCIO_H

