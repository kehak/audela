
/**************************************************************************
 *
 *  $Id: gpsutils.c 1.4.1.3 2010/07/15 13:33:43 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Utility functions useful with GPS data.
 *
 * -----------------------------------------------------------------------
 *  $Log: gpsutils.c $
 *  Revision 1.4.1.3  2010/07/15 13:33:43  martin
 *  Use DEG character definition from pcpslstr.h.
 *  Revision 1.4.1.2  2004/11/09 14:42:36Z  martin
 *  Use C99 fixed-size types in swap_double().
 *  Revision 1.4.1.1  2003/05/16 08:36:27  MARTIN
 *  Fixed sprint_dms() to work correctly under QNX.
 *  Revision 1.4  2003/01/31 13:45:19  MARTIN
 *  sprint_pos_geo() returns N/A if position not valid.
 *  Revision 1.3  2002/12/12 16:07:04  martin
 *  New functions swap_pos_doubles(), sprint_dms(),
 *  and sprint_pos_geo().
 *  Revision 1.2  2001/02/05 09:39:12Z  MARTIN
 *  New file header.
 *  Change include file name to lower case.
 *  Source code cleanup.
 *
 **************************************************************************/

#define _GPSUTILS
 #include <gpsutils.h>
#undef _GPSUTILS

#include <pcpslstr.h>

#include <stdio.h>
#include <string.h>



#define _eos( _s )  ( &(_s)[strlen( _s )] )


/*HDR*/
void swap_double( double *d )
{
  uint16_t *wp1;
  uint16_t *wp2;
  uint16_t w;
  int i;

  wp1 = (uint16_t *) d;
  wp2 = ( (uint16_t *) d ) + 3;

  for ( i = 0; i < 2; i++ )
  {
    w = *wp1;
    *wp1 = *wp2;
    *wp2 = w;
    wp1++;
    wp2--;
  }

}  /* swap_double */



/*HDR*/
void swap_eph_doubles( EPH *ephp )
{
  swap_double( &ephp->sqrt_A );
  swap_double( &ephp->e );
  swap_double( &ephp->M0 );
  swap_double( &ephp->omega );
  swap_double( &ephp->i0 );
  swap_double( &ephp->OMEGA0 );
  swap_double( &ephp->OMEGADOT );

  swap_double( &ephp->deltan );
  swap_double( &ephp->idot );

  swap_double( &ephp->crc );
  swap_double( &ephp->crs );
  swap_double( &ephp->cuc );
  swap_double( &ephp->cus );
  swap_double( &ephp->cic );
  swap_double( &ephp->cis );

  swap_double( &ephp->af0 );
  swap_double( &ephp->af1 );
  swap_double( &ephp->af2 );

  swap_double( &ephp->tgd );

}  /* swap_eph_doubles */



/*HDR*/
void swap_alm_doubles( ALM *almp )
{
  swap_double( &almp->sqrt_A );
  swap_double( &almp->e );
  swap_double( &almp->deltai );
  swap_double( &almp->OMEGA0 );
  swap_double( &almp->OMEGADOT );
  swap_double( &almp->omega );
  swap_double( &almp->M0 );
  swap_double( &almp->af0 );
  swap_double( &almp->af1 );

}  /* swap_alm_doubles */



/*HDR*/
void swap_utc_doubles( UTC *utcp )
{
  swap_double( &utcp->A0 );
  swap_double( &utcp->A1 );

}  /* swap_utc_doubles */



/*HDR*/
void swap_iono_doubles( IONO *ionop )
{
  swap_double( &ionop->alpha_0 );
  swap_double( &ionop->alpha_1 );
  swap_double( &ionop->alpha_2 );
  swap_double( &ionop->alpha_3 );

  swap_double( &ionop->beta_0 );
  swap_double( &ionop->beta_1 );
  swap_double( &ionop->beta_2 );
  swap_double( &ionop->beta_3 );

}  /* swap_iono_doubles */



/*HDR*/
void swap_pos_doubles( POS *posp )
{
  int i;

  for ( i = 0; i < N_XYZ; i++ )
    swap_double( &posp->xyz[i] );

  for ( i = 0; i < N_LLA; i++ )
    swap_double( &posp->lla[i] );

  swap_double( &posp->longitude.sec );
  swap_double( &posp->latitude.sec );

}  /* swap_pos_doubles */



/*HDR*/
void sprint_dms( char *s, DMS *pdms, int prec )
{
  sprintf( s, "%c %i" DEG "%02i'%02.*f\"",
           pdms->prefix,
           pdms->deg,
           pdms->min,
           prec,
           pdms->sec
         );

}  /* sprint_dms */



/*HDR*/
void sprint_pos_geo( char *s, POS *ppos, const char *sep, int prec )
{
  if ( ppos->lla[LON] && ppos->lla[LAT] && ppos->lla[ALT] )
  {
    sprint_dms( s, &ppos->latitude, prec );
    strcat( s, sep );
    sprint_dms( _eos( s ), &ppos->longitude, prec );
    strcat( s, sep );
    sprintf( _eos( s ), "%.0fm", ppos->lla[ALT] );
  }
  else
    strcpy( s, "N/A" );

}  /* sprint_pos_geo */



