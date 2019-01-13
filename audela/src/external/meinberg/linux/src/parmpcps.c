
/**************************************************************************
 *
 *  $Id: parmpcps.c 1.4 2004/11/09 14:24:15 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Functions to handle/convert parameters used by Meinberg plug-in
 *    radio clocks.
 *
 * -----------------------------------------------------------------------
 *  $Log: parmpcps.c $
 *  Revision 1.4  2004/11/09 14:24:15  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Revision 1.3  2003/04/17 10:43:35Z  martin
 *  Moved some definitions to parmpcps.h.
 *  Removed some functions which are now in mbgdevio.c.
 *  Revision 1.2  2002/03/25 09:03:43Z  MARTIN
 *  Fixed a bug where the wrong framing was configured for DCF77 clocks.
 *  Revision 1.1  2002/02/19 14:00:19  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _PARMPCPS
 #include <parmpcps.h>
#undef _PARMPCPS

#include <parmgps.h>
#include <pcpsutil.h>
#include <myutil.h>

#include <string.h>


static const int pcps_to_mbg_framing_tbl[N_PCPS_FR_DCF] =
{
  MBG_FRAMING_8N1,
  MBG_FRAMING_7E2,
  MBG_FRAMING_8N2,
  MBG_FRAMING_8E1
};



/*HDR*/
void port_info_from_pcps_serial(
  PORT_INFO_IDX *p_pii,
  PCPS_SERIAL pcps_serial,
  uint32_t supp_baud_rates
)
{
  PCPS_SER_PACK ser_pack;
  PORT_INFO *p_pi;
  PORT_SETTINGS *p_ps;

  ser_pack.pack = pcps_serial;
  pcps_unpack_serial( &ser_pack );

  p_pi = &p_pii[0].port_info;
  p_ps = &p_pi->port_settings;

  p_ps->parm.baud_rate = mbg_baud_rate[ser_pack.baud];

  _strncpy_0( p_ps->parm.framing,
              mbg_framing_str[pcps_to_mbg_framing_tbl[ser_pack.frame]] );

  p_ps->parm.handshake = HS_NONE;

  p_ps->str_type = 0;
  p_ps->mode = ser_pack.mode;

  p_pi->supp_baud_rates = supp_baud_rates;
  p_pi->supp_framings = DEFAULT_FRAMINGS_DCF;
  p_pi->supp_str_types = DEFAULT_SUPP_STR_TYPES_DCF;

}  // port_info_from_pcps_serial


/*HDR*/
void pcps_serial_from_port_info(
  PCPS_SERIAL *p,
  const PORT_INFO_IDX *p_pii
)
{
  PCPS_SER_PACK ser_pack;
  const PORT_INFO *p_pi = &p_pii[0].port_info;
  const PORT_SETTINGS *p_ps = &p_pi->port_settings;
  int framing_idx = get_framing_idx( p_ps->parm.framing );
  int i;


  ser_pack.baud = get_baud_rate_idx( p_ps->parm.baud_rate );

  // Translate the common framing index to the corresponding
  // number used with the old PCPS_SERIAL parameter.
  // This should always return a valid result since the
  // framing index is expected to be selected from
  // supported framings.
  for ( i = 0; i < N_PCPS_FR_DCF; i++ )
    if ( pcps_to_mbg_framing_tbl[i] == framing_idx )
      break;

  ser_pack.frame = i;

  ser_pack.mode = p_ps->mode;

  pcps_pack_serial( &ser_pack );

  *p = ser_pack.pack;

}  // pcps_serial_from_port_info


