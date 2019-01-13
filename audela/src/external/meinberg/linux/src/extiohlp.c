
/**************************************************************************
 *
 *  $Id: extiohlp.c 1.1 2011/09/21 15:59:59 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Device configuration helper functions. This is an extension to
 *    mbgextio.c providing useful functions to simplify reading/writing
 *    complex device configuration structure sets.
 *
 *  Warning:
 *    These functions should not be implemented in a DLL / shared library
 *    since the parameter sizes might vary with different versions
 *    of the API calls, which which would make different versions of
 *    precompiled libraries incompatible to each other.
 *
 * -----------------------------------------------------------------------
 *  $Log: extiohlp.c $
 *  Revision 1.1  2011/09/21 15:59:59  martin
 *  Initial revision.
 *
 **************************************************************************/

#define _EXTIOHLP
  #include <extiohlp.h>
#undef _EXTIOHLP

#include <mbgerror.h>   //##++ Do we need this ??

/*HDR*/
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
int mbgextio_get_serial_settings( MBG_MSG_CTL *dh, RECEIVER_PORT_CFG *pcfg, const RECEIVER_INFO *p_ri )
{
  int rc;
  uint16_t i;

  memset( pcfg, 0, sizeof( *pcfg ) );

  for ( i = 0; i < p_ri->n_com_ports; i++ )
  {
    rc = mbgextio_get_port_info_idx( dh, &pcfg->pii[i], i );
    if ( rc < 0 )
      return rc;
  }
  for ( i = 0; i < p_ri->n_str_type; i++ )
  {
    rc = mbgextio_get_str_type_info_idx( dh, &pcfg->stii[i], i );
    if ( rc < 0 )
      return rc;
  }

  return TR_COMPLETE;  // success -> mbgextio -> TR_COMPLETE = 2   //##+++++ marvin
}



/*HDR*/
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
int mbgextio_save_serial_settings( MBG_MSG_CTL *dh, RECEIVER_PORT_CFG *pcfg, int port_num )
{
  int rc;

  rc = mbgextio_set_port_settings_idx( dh, &pcfg->pii[port_num].port_info.port_settings, port_num );

  if ( rc != 0 )     //##++++++++++++++++++
    return !MBG_SUCCESS;

/*  rc = mbgextio_get_str_type_info_idx( dh, &pcfg->stii[i], i );
  if(rc != 0)
    return !MBG_SUCCESS;    
  */

  return 0;  // success

}  //mbgextio_save_serial_settings

