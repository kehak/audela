
/**************************************************************************
 *
 *  $Id: mbgerror.h 1.5.1.1 2011/04/20 16:09:19 martin TEST $
 *  $Name: $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Error codes used with Meinberg devices and drivers.
 *    The codes can be translated into an OS dependent error code.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgerror.h $
 *  Revision 1.5.1.1  2011/04/20 16:09:19  martin
 *  Revision 1.5  2011/03/31 10:56:17  martin
 *  Added MBG_ERR_COPY_TO_USER and MBG_ERR_COPY_FROM_USER.
 *  Revision 1.4  2008/12/05 13:28:50  martin
 *  Added new code MBG_ERR_IRQ_UNSAFE.
 *  Revision 1.3  2008/02/26 14:50:14Z  daniel
 *  Added codes:
 *  MBG_ERR_NOT_SUPP_ON_OS, MBG_ERR_LIB_NOT_COMPATIBLE,
 *  MBG_ERR_N_COM_EXCEEDS_SUPP, MBG_ERR_N_STR_EXCEEDS_SUPP
 *  Added doxygen compatible comments.
 *  Revision 1.2  2007/09/27 07:26:22Z  martin
 *  Define STATUS_SUCCESS for Windows if not in kernel mode.
 *  Revision 1.1  2007/09/26 08:08:54Z  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _MBGERROR_H
#define _MBGERROR_H


/* Other headers to be included */

#include <mbg_tgt.h>

#ifdef _MBGERROR
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

/**
  @defgroup group_error_codes Error codes

  Error codes used with Meinberg devices and drivers.
  The codes will be translated into an OS dependent error code,
  when they are returned to the calling function.

  For Windows, these codes are made positive and or'ed with 0xE0000000 afterwards.

  Example: Code -19 (#MBG_ERR_GENERIC) will be converted to 0xE0000013 under Windows.

  @note Attention:
  These error codes below must match exactly the corresponding codes that are evaluated in user space.
  For Windows, they are located in messages.mc/.h in mbgsvctl.dll

  @{
*/


#define MBG_SUCCESS     PCPS_SUCCESS      /**<  0, no error */

// The codes below are defined in pcpsdefs.h and returned by the firmware:
#define MBG_ERR_STIME   PCPS_ERR_STIME    /**< -1, invalid date/time/status passed */
#define MBG_ERR_CFG     PCPS_ERR_CFG      /**< -2, invalid parms with a PCPS_CFG_GROUP cmd */

// Codes returned by the driver's low level functions:
#define MBG_ERR_GENERIC             -19   /**< Generic error */
#define MBG_ERR_TIMEOUT             -20   /**< Timeout accessing the board */
#define MBG_ERR_FW_ID               -21   /**< Invalid firmware ID */
#define MBG_ERR_NBYTES              -22   /**< The number of parameter bytes 
                                               passed to the board did not match 
                                               the number of bytes expected. */
#define MBG_ERR_INV_TIME            -23   /**< The device's time is not valid */
#define MBG_ERR_FIFO                -24   /**< The device's FIFO is empty, though
                                               it shouldn't be */
#define MBG_ERR_NOT_READY           -25   /**< Board is temporary unable to respond
                                               (during initialization after RESET) */
#define MBG_ERR_INV_TYPE            -26   /**< Board did not recognize data type */


// Codes returned by the driver's high level functions:
#define MBG_ERR_NO_MEM              -27  /**< Failed to allocate memory */
#define MBG_ERR_CLAIM_RSRC          -28  /**< Failed to claim port or mem resource */
#define MBG_ERR_DEV_NOT_SUPP        -29  /**< Specified device type not supported by driver */
#define MBG_ERR_INV_DEV_REQUEST     -30  /**< IOCTL call not supported by driver */
#define MBG_ERR_NOT_SUPP_BY_DEV     -31  /**< Cmd or feature not supported by device */
#define MBG_ERR_USB_ACCESS          -32  /**< USB access failed */
#define MBG_ERR_CYCLIC_TIMEOUT      -33  /**< Cyclic event (IRQ, etc.) didn't occur */
#define MBG_ERR_NOT_SUPP_ON_OS      -34  /**< The function is not supported on this operating system */
#define MBG_ERR_LIB_NOT_COMPATIBLE  -35  /**< The installed version of the DLL/shared object is not 
                                              compatible with version used to build the application */
#define MBG_ERR_N_COM_EXCEEDS_SUPP  -36  /**< The number of COM ports provided by the device 
                                              exceeds the maximum supported by the driver  */
#define MBG_ERR_N_STR_EXCEEDS_SUPP  -37  /**< The number of string formats supported by the device 
                                              exceeds the maximum supported by the driver  */
#define MBG_ERR_IRQ_UNSAFE          -38  /**< The enabled IRQs are unsafe with this firmware/ASIC version  */
#define MBG_ERR_N_POUT_EXCEEDS_SUPP -39  /**< The number of programmable outputs provided by the device 
                                              exceeds the maximum supported by the driver  */

// Legacy codes used with DOS TSRs only:
#define MBG_ERR_INV_INTNO           -40  /**< Invalid interrupt number */
#define MBG_ERR_NO_DRIVER           -41  /**< A driver could not be found */
#define MBG_ERR_DRV_VERSION         -42  /**< The driver is too old */


#define MBG_ERR_COPY_TO_USER        -43  /**< kernel driver failed to copy data from kernel to user space */
#define MBG_ERR_COPY_FROM_USER      -44  /**< kernel driver failed to copy data from use to kernel space */

// More codes returned by the driver's high level functions:

#define MBG_ERR_N_UC_MSTR_EXCEEDS_SUPP -39  /**< The number of PTP unicast masters supported by the device
                                                 exceeds the maximum supported by the driver  */
/** @} group_error_codes */

// Depending on the operating system, the codes above have to be converted before
// they are sent up to user space
#if defined( MBG_TGT_WIN32 )
  #if !defined( STATUS_SUCCESS )  // not in kernel mode
    #define STATUS_SUCCESS  0
  #endif

  #define _mbg_err_to_os( _c ) \
  ( ( _c == MBG_SUCCESS ) ?  STATUS_SUCCESS : ( abs( _c ) | 0xE0000000 ) )
#endif


// If no specific conversion has been defined 
// then use the original codes.
#if !defined( _mbg_err_to_os )
  #define _mbg_err_to_os( _c )   ( _c )
#endif



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


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _MBGERROR_H */
