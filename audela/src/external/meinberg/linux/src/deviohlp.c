
/**************************************************************************
 *
 *  $Id: deviohlp.c 1.1.1.4 2011/09/21 14:45:24 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Device configuration helper functions. This is an extension to
 *    mbgdevio.c providing useful functions to simplify reading/writing
 *    complex device configuration structure sets.
 *
 *  Warning:
 *    These functions should not be implemented in a DLL / shared library
 *    since the parameter sizes might vary with different versions
 *    of the API calls, which which would make different versions of
 *    precompiled libraries incompatible to each other.
 *
 * -----------------------------------------------------------------------
 *  $Log: deviohlp.c $
 *  Revision 1.1.1.4  2011/09/21 14:45:24  martin
 *  Moved mbgextio support functions to new module extiohlp.c.
 *  Revision 1.1.1.3  2011/09/20 15:36:02  marvin
 *  new functions: 
 *    mbg_get_serial_settings
 *    mbg_set_serial_settings
 *  include mbgextio.h
 *  Revision 1.1.1.2  2011/08/05 10:30:28  martin
 *  Revision 1.1.1.1  2011/08/05 09:55:52  martin
 *  Revision 1.1  2011/08/03 15:37:00Z  martin
 *  Initial revision with functions moved here from mbgdevio.
 *
 **************************************************************************/

#define _DEVIOHLP
  #include <deviohlp.h>
#undef _DEVIOHLP

#include <parmpcps.h>
#include <parmgps.h>



/*HDR*/
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
int mbg_get_serial_settings( MBG_DEV_HANDLE dh,
                             const PCPS_DEV *pdev,
                             RECEIVER_PORT_CFG *pcfg,
                             const RECEIVER_INFO *p_ri )
{
  int rc;
  int i;

  memset( pcfg, 0, sizeof( *pcfg ) );

  if ( _pcps_has_receiver_info( pdev ) )
  {
    rc = mbg_get_gps_all_port_info( dh, pcfg->pii, p_ri );
    if ( rc != MBG_SUCCESS )
      goto error;

    rc = mbg_get_gps_all_str_type_info( dh, pcfg->stii, p_ri );
    if ( rc != MBG_SUCCESS )
      goto error;
  }
  else
  {
    if ( _pcps_is_gps( pdev ) )
    {
      rc = mbg_get_gps_port_parm( dh, &pcfg->tmp_pp );
      if ( rc != MBG_SUCCESS )
        goto error;

      for ( i = 0; i < p_ri->n_com_ports; i++ )
      {
        PORT_INFO_IDX *p_pii = &pcfg->pii[i];
        PORT_INFO *p_pi = &p_pii->port_info;

        p_pii->idx = i;
        port_settings_from_port_parm( &p_pi->port_settings,
                                      i, &pcfg->tmp_pp, 1 );

        p_pi->supp_baud_rates = DEFAULT_GPS_BAUD_RATES_C166;
        p_pi->supp_framings = DEFAULT_GPS_FRAMINGS_C166;
        p_pi->supp_str_types = DEFAULT_SUPP_STR_TYPES_GPS;
      }
    }
    else
      if ( _pcps_has_serial ( pdev ) ) // Not all non-GPS clocks have a serial port!
      {
        PCPS_SERIAL ser_code;

        rc = mbg_get_serial( dh, &ser_code );
        if ( rc != MBG_SUCCESS )
          goto error;


        port_info_from_pcps_serial( pcfg->pii, ser_code,
                                    _pcps_has_serial_hs( pdev ) ?
                                      DEFAULT_BAUD_RATES_DCF_HS :
                                      DEFAULT_BAUD_RATES_DCF
                                 );
      }

    for ( i = 0; i < p_ri->n_str_type; i++ )
    {
      STR_TYPE_INFO_IDX *stip = &pcfg->stii[i];
      stip->idx = i;
      stip->str_type_info = default_str_type_info[i];
    }
  }

  return MBG_SUCCESS;


error:
  return rc;

}  // mbg_get_serial_settings



/*HDR*/
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
int mbg_save_serial_settings( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev,
                              RECEIVER_PORT_CFG *pcfg, int port_num )
{
  int rc;

  if ( _pcps_has_receiver_info( pdev ) )
  {
    rc = mbg_set_gps_port_settings( dh, &pcfg->pii[port_num].port_info.port_settings, port_num );
  }
  else
  {
    if ( _pcps_is_gps( pdev ) )
    {
      port_parm_from_port_settings( &pcfg->tmp_pp, port_num,
                          &pcfg->pii[port_num].port_info.port_settings, 1 );

      rc = mbg_set_gps_port_parm( dh, &pcfg->tmp_pp );
    }
    else
    {
      PCPS_SERIAL ser_code;

      pcps_serial_from_port_info( &ser_code, pcfg->pii );

      rc = mbg_set_serial( dh, &ser_code );
    }
  }

  return rc;

}  // mbg_save_serial_settings



/*HDR*/
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
int mbg_get_all_ptp_cfg_info( MBG_DEV_HANDLE dh, ALL_PTP_CFG_INFO *p )
{
  int rc = MBG_SUCCESS;

  memset( p, 0, sizeof( *p ) );

  rc = mbg_get_ptp_cfg_info( dh, &p->ptp_cfg_info );

  if ( rc < 0 )
    return rc;

  if ( p->ptp_cfg_info.supp_flags & PTP_CFG_MSK_SUPPORT_PTP_UNICAST )
  {
    rc = mbg_get_ptp_uc_master_cfg_limits( dh, &p->ptp_uc_master_cfg_limits );

    if ( rc < 0 )
      return rc;

    if ( p->ptp_uc_master_cfg_limits.n_supp_master > MAX_PARM_PTP_UC_MASTER )
    {
      // The number of PTP unicast masters supported by this device
      // exceeds the number of unicast masters supporterd by this driver.
      return MBG_ERR_N_UC_MSTR_EXCEEDS_SUPP;
    }

    rc = mbg_get_all_ptp_uc_master_info( dh, p->all_ptp_uc_master_info,
                                         &p->ptp_uc_master_cfg_limits );
    if ( rc < 0 )
      return rc;
  }

  return MBG_SUCCESS;

}  // mbg_get_all_ptp_cfg_info


