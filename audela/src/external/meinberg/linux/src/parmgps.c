
/**************************************************************************
 *
 *  $Id: parmgps.c 1.5 2008/10/21 10:47:26 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Functions to handle/convert Meinberg GPS specific parameters.
 *
 * -----------------------------------------------------------------------
 *  $Log: parmgps.c $
 *  Revision 1.5  2008/10/21 10:47:26  martin
 *  Renamed check_port_info() to check_valid_port_info()
 *  to avoid naming conflicts.
 *  Revision 1.4  2008/09/15 14:11:25  martin
 *  New function check_port_info() which returns a bit mask indicating
 *  which fields of a PORT_SETTINGS structure are not valid.
 *  This is based on code taken from valid_port_info(), which now calls
 *  check_port_info() and returns a value compatible to the earlier version.
 *  Revision 1.3  2004/11/09 14:21:36  martin
 *  Redefined some data types using C99 fixed-size definitions.
 *  Revision 1.2  2002/02/19 13:30:23Z  MARTIN
 *  Bug fix in port_settings_from_port_parm_mode().
 *  Revision 1.1  2002/01/30 10:30:26  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#define _PARMGPS
 #include <parmgps.h>
#undef _PARMGPS

#include <myutil.h>
#include <string.h>



/*HDR*/
int get_str_idx( const char *search,
                 const char *str_table[],
                 int n_entries )
{
  int i;

  for ( i = 0; i < n_entries; i++ )
    if ( strcmp( search, str_table[i] ) == 0 )
      return i;

  return -1;

}  // get_str_idx



/*HDR*/
int get_baud_rate_idx( BAUD_RATE baud_rate )
{
  int i;

  for ( i = 0; i < N_MBG_BAUD_RATES; i++ )
    if ( baud_rate == mbg_baud_rate[i] )
      return i;

  return -1;

}  // get_baud_rate_idx



/*HDR*/
int get_framing_idx( const char *framing )
{
  return get_str_idx( framing, mbg_framing_str, N_MBG_FRAMINGS );

}  // get_framing_idx



/*HDR*/
void port_settings_from_port_parm_mode(
       PORT_SETTINGS *p_ps,
       uint8_t pp_mode,
       int str_type_cap
     )
{
  if ( pp_mode >= STR_UCAP )
  {
    p_ps->str_type = str_type_cap;
    p_ps->mode = ( pp_mode == STR_UCAP ) ? STR_AUTO : STR_ON_REQ;
  }
  else
  {
    p_ps->str_type = 0;
    p_ps->mode = pp_mode;
  }

}  // port_settings_from_port_parm_mode



/*HDR*/
void port_parm_mode_from_port_settings(
       uint8_t *pp_mode,
       const PORT_SETTINGS *p_ps,
       int str_type_cap
     )
{
  if ( p_ps->str_type == str_type_cap )
    *pp_mode = ( p_ps->mode == STR_ON_REQ ) ? STR_UCAP_REQ : STR_UCAP;
  else
    *pp_mode = p_ps->mode;

}  // port_parm_mode_from_port_settings



/*HDR*/
void port_settings_from_port_parm(
  PORT_SETTINGS *p_ps,
  int port_num,
  const PORT_PARM *p_pp,
  int cap_str_idx
)
{
  p_ps->parm = p_pp->com[port_num];

  port_settings_from_port_parm_mode( p_ps, p_pp->mode[port_num],
                                     cap_str_idx );

}  // port_info_from_port_parm



/*HDR*/
void port_parm_from_port_settings(
  PORT_PARM *p_pp,
  int port_num,
  const PORT_SETTINGS *p_ps,
  int cap_str_idx
)
{
  p_pp->com[port_num] = p_ps->parm;

  port_parm_mode_from_port_settings( &p_pp->mode[port_num],
                                     p_ps, cap_str_idx );

}  // port_parm_from_port_settings



/*HDR*/
int check_valid_port_info( const PORT_INFO *p_pi,
                           const STR_TYPE_INFO_IDX str_type_info_idx[],
                           int n_str_type )

{
  const PORT_SETTINGS *p_ps = &p_pi->port_settings;
  int idx;
  int flags = 0;


  if ( p_pi->supp_baud_rates & ~_mask( N_MBG_BAUD_RATES ) )
    flags |= MBG_PS_MSK_BAUD_RATE_OVR_SW;  // dev. supports more baud rates than driver

  idx = get_baud_rate_idx( p_ps->parm.baud_rate );

  if ( !_inrange( idx, 0, N_MBG_BAUD_RATES ) ||
       !_is_supported( idx, p_pi->supp_baud_rates ) )
    flags |= MBG_PS_MSK_BAUD_RATE;


  if ( p_pi->supp_framings & ~_mask( N_MBG_FRAMINGS ) )
    flags |= MBG_PS_MSK_FRAMING_OVR_SW;    // dev. supports more framings than driver

  idx = get_framing_idx( p_ps->parm.framing );

  if ( !_inrange( idx, 0, N_MBG_FRAMINGS ) ||
       !_is_supported( idx, p_pi->supp_framings ) )
    flags |= MBG_PS_MSK_FRAMING;


  if ( p_ps->parm.handshake >= N_COM_HS )
    flags |= MBG_PS_MSK_HS_OVR_SW;         // handshake index exceeds max.

  if ( p_ps->parm.handshake != HS_NONE )   // currently no device supports any handshake
    flags |= MBG_PS_MSK_HS;                // handshake mode not supp. by dev.


  if ( p_pi->supp_str_types & ~_mask( n_str_type ) )
    flags |= MBG_PS_MSK_STR_TYPE_OVR_SW;   // firmware error: more string types supported than reported

  idx = p_ps->str_type;

  if ( idx >= n_str_type )
    flags |= MBG_PS_MSK_STR_TYPE_OVR_DEV;  // string type index exceeds max.
  else
  {
    if ( !_is_supported( idx, p_pi->supp_str_types ) )
      flags |= MBG_PS_MSK_STR_TYPE;        // string type not supported by this port
    else
    {
      // Use the str_type index to get the supported output mode mask
      // from the string type info table. This is required to check 
      // whether the selected mode is supported by the selected 
      // string type.
      ulong supp_modes = str_type_info_idx[idx].str_type_info.supp_modes;

      if ( supp_modes & ~_mask( N_STR_MODE ) )
        flags |= MBG_PS_MSK_STR_MODE_OVR_SW;  // dev. supports more string modes than driver

      idx = p_ps->mode;

      if ( idx >= N_STR_MODE )                // mode is always >= 0
        flags |= MBG_PS_MSK_STR_MODE_OVR_SW;  // string mode index exceeds max.
      else
        if ( !_is_supported( idx, supp_modes ) )
          flags |= MBG_PS_MSK_STR_MODE;       // string mode not supp. by this string type and port
    }
  }


  if ( p_ps->flags != 0 )            /* currently always 0 */
    flags |= MBG_PS_MSK_FLAGS_OVR_SW | MBG_PS_MSK_FLAGS;


  return flags;

}  // check_valid_port_info



/*HDR*/
int valid_port_info( const PORT_INFO *p_pi,
                     const STR_TYPE_INFO_IDX str_type_info_idx[],
                     int n_str_type )
{
  return check_valid_port_info( p_pi, str_type_info_idx, n_str_type ) == 0;

}  // valid_port_info


