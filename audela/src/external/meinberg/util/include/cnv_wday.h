
/***************************************************************************/
/*                                                                         */
/*   File:         CNV_WDAY.H                    $Revision: 1.1 $          */
/*                                                                         */
/*   Project:      Common C Library                                        */
/*                                                                         */
/*   Compiler:     Borland C++ and others                                  */
/*                                                                         */
/*   Author:       M. Burnicki,  Meinberg Funkuhren                        */
/*                                                                         */
/*                                                                         */
/*   Description:                                                          */
/*     This header provides macros which can be used to convert            */
/*     day-of-week codes from one convention to another.                   */
/*                                                                         */
/*     The conventions supported yet have been named as describrd below:   */
/*                                                                         */
/*     name   range   assignment     used with ...                         */
/*     ----------------------------------------------------------------    */
/*     sun06  0..6    0 = Sunday     RTC72421, DOS1.10+, Novell            */
/*     sun17  1..7    1 = Sunday     RTC146818                             */
/*     mon17  1..7    1 = Monday     DCF77                                 */
/*                                                                         */
/***************************************************************************/


#ifndef _CNV_WDAY_H


/* Other headers to be included */



#ifdef __cplusplus
extern "C" {
#endif

#ifdef _CNV_WDAY
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */


/* use the following macros if sure that the source value is in range */

#define _wday_mon17_to_mon06( d )   ( ( d ) - 1 )
#define _wday_mon06_to_mon17( d )   ( ( d ) + 1 )

#define _wday_mon17_to_sun17( d )   ( ( (d) >= 7 ) ? 1 : ( (d) + 1 ) )
#define _wday_sun17_to_mon17( d )   ( ( (d) < 2 ) ? 7 : ( (d) - 1 ) )

#define _wday_mon17_to_sun06( d )   ( ( (d) >= 7 ) ? 0 : (d) )
#define _wday_sun06_to_mon17( d )   ( ( (d) < 1 ) ? 7 : (d) )

#define _wday_sun17_to_sun06( d )   ( (d) - 1 )
#define _wday_sun06_to_sun17( d )   ( (d) + 1 )


/* use the macros below to check for valid ranges */

#define _inrng( d, what, min, lt, max, gt )  ( ( (d) < (min) ) ? (lt) : ( ( (d) > (max) ) ? (gt) : (what) ) )
  /* _inrng is a local macro which does the boundary check */
  /*   d          the day code to be converted */
  /*   what       the conversion algorithm if in range */
  /*   min, lt    if (d) is below (min), the macro returns (lt) */
  /*   max, gt    if (d) is above (max), the macro returns (gt) */

#define _wday_chk_mon17_to_sun17( d )  _inrng( (d), _wday_mon17_to_sun17( (d) ), 1, 7, 7, 6 )
#define _wday_chk_sun17_to_mon17( d )  _inrng( (d), _wday_sun17_to_mon17( (d) ), 1, 7, 7, 6 )


#define _wday_chk_mon17_to_sun06( d )  _inrng( (d), _wday_mon17_to_sun06( (d) ), 1, 1, 7, 0 )
#define _wday_chk_sun06_to_mon17( d )  _inrng( (d), _wday_sun06_to_mon17( (d) ), 0, 1, 6, 6 )

#define _wday_chk_sun17_to_sun06( d )  _inrng( (d), _wday_sun17_to_sun06( (d) ), 1, 0, 7, 6 )
#define _wday_chk_sun06_to_sun17( d )  _inrng( (d), _wday_sun06_to_sun17( (d) ), 0, 1, 6, 7 )


/* function prototypes: */

/* #include <CNV_WDAY.hdr> not needed yet */

/* End of header body */


#undef _ext

#ifdef __cplusplus
}
#endif

#define _CNV_WDAY_H

#endif  /* _CNV_WDAY_H */

