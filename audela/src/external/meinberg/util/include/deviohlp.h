
/**************************************************************************
 *
 *  $Id: deviohlp.h 1.1.1.5 2011/09/21 16:00:22 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for deviohlp.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: deviohlp.h $
 *  Revision 1.1.1.5  2011/09/21 16:00:22  martin
 *  Revision 1.1.1.4  2011/09/21 14:44:50  martin
 *  Updated function prototypes.
 *  Revision 1.1.1.3  2011/09/20 15:36:03  marvin
 *  new functions: 
 *    mbg_get_serial_settings
 *    mbg_set_serial_settings
 *  include mbgextio.h
 *  Revision 1.1.1.2  2011/08/05 10:30:28  martin
 *  Revision 1.1.1.1  2011/08/05 09:55:58  martin
 *  Revision 1.1  2011/08/03 15:36:44Z  martin
 *  Initial revision with functions moved here from mbgdevio.
 *
 **************************************************************************/

#ifndef _DEVIOHLP_H
#define _DEVIOHLP_H


/* Other headers to be included */

#include <mbgdevio.h>
#include <cfg_hlp.h>


#ifdef _DEVIOHLP
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#ifdef __cplusplus
extern "C" {
#endif


typedef struct
{
  PTP_CFG_INFO ptp_cfg_info;
  PTP_UC_MASTER_CFG_LIMITS ptp_uc_master_cfg_limits;
  ALL_PTP_UC_MASTER_INFO all_ptp_uc_master_info;

} ALL_PTP_CFG_INFO;



/* function prototypes: */

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 /**
    Read all serial port settings and supported configuration parameters.

    The functions mbg_get_device_info() and mbg_setup_receiver_info()
    must have been called before, and the returned ::PCPS_DEV and
    ::RECEIVER_INFO structures must be passed to this function.

    The complementary function mbg_save_serial_settings() should be used
    to write the modified serial port configuration back to the board.

    @param dh    Valid handle to a Meinberg device.
    @param *pdev Pointer to a ::PCPS_DEV structure.
    @param *pcfg Pointer to a ::RECEIVER_PORT_CFG structure to be filled up.
    @param *p_ri Pointer to a ::RECEIVER_INFO structure.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_device_info()
    @see mbg_setup_receiver_info()
    @see mbg_save_serial_settings()
*/
 int mbg_get_serial_settings( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev, RECEIVER_PORT_CFG *pcfg, const RECEIVER_INFO *p_ri ) ;

 /**
    Write the configuration settings for a single serial port to the board.

    Modifications to the serial port configuration should be made only
    after mbg_get_serial_settings() had been called to read all serial port
    settings and supported configuration parameters.
    This function has finally to be called once for every serial port
    the configuration of which has been modified.

    As also required by mbg_get_serial_settings(), the functions
    mbg_get_device_info() and mbg_setup_receiver_info() must have been
    called before, and the returned ::PCPS_DEV and ::RECEIVER_INFO structures
    must be passed to this function.

    @param dh       Valid handle to a Meinberg device
    @param *pdev    Pointer to a ::PCPS_DEV structure
    @param *pcfg    Pointer to a ::RECEIVER_PORT_CFG structure
    @param port_num Index of the ::serial port to be saved

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_serial_settings()
    @see mbg_get_device_info()
    @see mbg_setup_receiver_info()
*/
 int mbg_save_serial_settings( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev, RECEIVER_PORT_CFG *pcfg, int port_num ) ;

 /**
    Read all serial port settings and supported configuration parameters.

    The functions mbg_get_device_info() and mbg_setup_receiver_info()
    must have been called before, and the returned ::PCPS_DEV and
    ::RECEIVER_INFO structures must be passed to this function.

    The complementary function mbg_save_serial_settings() should be used
    to write the modified serial port configuration back to the board.

    @param dh    Valid handle to a Meinberg device.
    @param *pdev Pointer to a ::PCPS_DEV structure.
    @param *pcfg Pointer to a ::RECEIVER_PORT_CFG structure to be filled up.
    @param *p_ri Pointer to a ::RECEIVER_INFO structure.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbg_get_device_info()
    @see mbg_setup_receiver_info()
    @see mbg_save_serial_settings()
*/
 int mbg_get_all_ptp_cfg_info( MBG_DEV_HANDLE dh, ALL_PTP_CFG_INFO *p ) ;


/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _DEVIOHLP_H */
