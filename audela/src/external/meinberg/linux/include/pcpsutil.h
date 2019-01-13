
/**************************************************************************
 *
 *  $Id: pcpsutil.h 1.14.1.1 2011/06/09 11:05:37 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for pcpsutil.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: pcpsutil.h $
 *  Revision 1.14.1.1  2011/06/09 11:05:37  martin
 *  Revision 1.14  2009/03/09 13:39:45  martin
 *  Made pcps_exp_year() an inline function.
 *  Revision 1.13  2008/12/10 19:59:48  martin
 *  Made frac_sec_from_bin() an inline function.
 *  Revision 1.12  2008/11/25 09:59:01  martin
 *  Moved definitions of PCPS_HRT_FRAC_SCALE and
 *  PCPS_HRT_FRAC_SCALE_FMT to pcpsdefs.h.
 *  Revision 1.11  2006/06/29 10:15:02Z  martin
 *  Updated function prototypes.
 *  Revision 1.10  2005/01/14 10:16:12Z  martin
 *  Updated function prototypes.
 *  Revision 1.9  2004/11/09 14:30:50Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Updated function prototypes.
 *  Revision 1.8  2004/04/14 09:22:09Z  martin
 *  Pack structures 1 byte aligned.
 *  Revision 1.7  2001/11/28 14:41:25Z  MARTIN
 *  Changed PCPS_HRT_FRAC_SCALE and PCPS_HRT_FRAC_SCALE_FMT
 *  to print 7 rather than 6 digits.
 *  Revision 1.6  2001/09/14 11:59:33  MARTIN
 *  Support for PCPS_HR_TIME fraction conversion.
 *  Updated function prototypes.
 *  Revision 1.5  2001/08/14 12:06:44  MARTIN
 *  Defined constants used to draw a signal bar
 *  depending on a DCF77 clock's signal value.
 *  Revision 1.4  2001/03/01 14:03:18  MARTIN
 *  Updated function prototypes.
 *  Revision 1.3  2000/08/31 14:06:05  MARTIN
 *  Updated function prototypes.
 *  Revision 1.2  2000/07/21 13:43:40  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _PCPSUTIL_H
#define _PCPSUTIL_H


/* Other headers to be included */

#include <pcpsdefs.h>
#include <use_pack.h>


#ifdef _PCPSUTIL
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


// The following constants are used to draw a signal bar
// depending on a DCF77 clock's signal value:
#define PCPS_SIG_BIAS 55
#define PCPS_SIG_ERR  1
#define PCPS_SIG_MIN  20
#define PCPS_SIG_MAX  68


// the structure below is used with a DCF77 clock's serial interface
typedef struct
{
  PCPS_SERIAL pack; // this byte is passed to the board as parameter

  uint8_t baud;     // the other bytes can hold the unpacked values
  uint8_t frame;
  uint8_t mode;

} PCPS_SER_PACK;



/*--------------------------------------------------------------
 * Name:         pcps_exp_year()
 *
 * Purpose:      Convert a 2-digit year number to a 4-digit
 *               year number. The resulting year number is in
 *               the range [year_lim ... ( year_lim + 99 )].
 *
 * Input:        year      the 2-digit year number
 *               year_lim  the smallest 4-digit year number
 *                         to be returned
 *
 * Output:       --
 *
 * Ret value:    the calculated 4-digit year num
 *+-------------------------------------------------------------*/

static __mbg_inline
uint16_t pcps_exp_year( uint8_t year, uint16_t year_lim )
{
  uint16_t lyear = (uint16_t) ( (uint16_t) year + year_lim
                              - ( year_lim % 100 ) );

  if ( lyear < year_lim )
    lyear += 100;

  return lyear;

}  // pcps_exp_year



/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 int pcps_time_is_valid( const PCPS_TIME *p ) ;
 void pcps_setup_isa_ports( char *s, int *port_vals, int n_vals ) ;
 void pcps_unpack_serial( PCPS_SER_PACK *p ) ;
 void pcps_pack_serial( PCPS_SER_PACK *p ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


/*--------------------------------------------------------------
 * Name:         frac_sec_from_bin()
 *
 * Purpose:      Convert a fraction of a second from binary
 *               format (as returned in a PCPS_HR_TIME structure
 *               to a decimal fraction, using a specified scale
 *               factor. See also the definitions of
 *               PCPS_HRT_FRAC_SCALE and PCPS_HRT_FRAC_SCALE_FMT
 *               in the header file.
 *
 * Input:        b         the binary fraction
 *               scale     the scale factor
 *
 * Output:       --
 *
 * Ret value:    the calculated number
 *+-------------------------------------------------------------*/

static __mbg_inline
uint32_t frac_sec_from_bin( uint32_t b, uint32_t scale )
{
  return (uint32_t) ( (PCPS_HRT_FRAC_CONVERSION_TYPE) b * scale 
                      / PCPS_HRT_BIN_FRAC_SCALE );

}  // frac_sec_from_bin



#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */

#undef _ext


#endif  /* _PCPSUTIL_H */
