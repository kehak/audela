
/**************************************************************************
 *
 *  $Id: extiohlp.h 1.1 2011/09/21 15:59:59 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for extiohlp.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: extiohlp.h $
 *  Revision 1.1  2011/09/21 15:59:59  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _EXTIOHLP_H
#define _EXTIOHLP_H


/* Other headers to be included */

#include <mbgextio.h>

#include <cfg_hlp.h>


#ifdef _EXTIOHLP
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#ifdef __cplusplus
extern "C" {
#endif





/* function prototypes: */

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 /**
    Read all serial port settings and supported configuration parameters.
    from a non bus level device

    The function mbgextio_get_receiver_info()
    must have been called before, and the returned ::RECEIVER_INFO 
    structures must be passed to this function.

    The complementary function mbgextio_save_serial_settings() should be used
    to write the modified serial port configuration via serial connection back to the board.

    @param dh    Valid handle to a Meinberg device.
    @param *pcfg Pointer to a ::RECEIVER_PORT_CFG structure to be filled up.
    @param *p_ri Pointer to a ::RECEIVER_INFO structure.

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbgextio_get_receiver_info()
    @see mbgextio_save_serial_settings()
*/
 int mbgextio_get_serial_settings( MBG_MSG_CTL *dh, RECEIVER_PORT_CFG *pcfg, const RECEIVER_INFO *p_ri ) ;

 /**
    Write the configuration settings for a single serial port via serial connection to the board.

    Modifications to the serial port configuration should be made only
    after mbgextio_get_serial_settings() had been called to read all serial port
    settings and supported configuration parameters.
    This function has finally to be called once for every serial port
    the configuration of which has been modified.

    As also required by mbgextio_get_serial_settings(), the function
    mbgextio_get_receiver_info() must have been
    called before, and the returned ::RECEIVER_INFO structure
    must be passed to this function.

    @param dh       Valid handle to a Meinberg device via serial connection
    @param *pcfg    Pointer to a ::RECEIVER_PORT_CFG structure
    @param port_num Index of the ::serial port to be saved

    @return ::MBG_SUCCESS or error code returned by device I/O control function.

    @see mbgextio_get_serial_settings()
    @see mbgextio_get_receiver_info()
*/
 int mbgextio_save_serial_settings( MBG_MSG_CTL *dh, RECEIVER_PORT_CFG *pcfg, int port_num ) ;


/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _EXTIOHLP_H */
