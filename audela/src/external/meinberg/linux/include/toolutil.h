
/**************************************************************************
 *
 *  $Id: toolutil.h 1.2.1.5 2011/10/05 15:10:08 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for toolutil.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: toolutil.h $
 *  Revision 1.2.1.5  2011/10/05 15:10:08  martin
 *  Updated function prototypes.
 *  Revision 1.2.1.4  2011/09/29 16:30:58  martin
 *  Updated function prototypes.
 *  Revision 1.2.1.3  2011/09/07 15:03:36  martin
 *  Updated function prototypes.
 *  Revision 1.2.1.2  2011/07/05 15:35:56  martin
 *  Modified version handling.
 *  Revision 1.2.1.1  2011/07/05 14:36:42  martin
 *  New way to maintain version information.
 *  Revision 1.2  2009/06/19 12:11:35  martin
 *  Updated function prototypes.
 *  Revision 1.1  2008/12/17 10:45:14  martin
 *  Initial revision.
 *  Revision 1.1  2008/12/15 08:35:08  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _TOOLUTIL_H
#define _TOOLUTIL_H


/* Other headers to be included */

#include <mbgdevio.h>
#include <mbgversion.h>



#ifdef _TOOLUTIL
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#ifdef __cplusplus
extern "C" {
#endif

_ext int must_print_usage;

_ext const char *pzf_corr_state_name[N_PZF_CORR_STATE]
#ifdef _DO_INIT
 = PZF_CORR_STATE_NAMES_ENG
#endif
;


/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 int mbg_program_info_str( char *s, size_t max_len, const char *pname, int micro_version, int first_year, int last_year ) ;
 void mbg_print_program_info( const char *pname, int micro_version, int first_year, int last_year ) ;
 void mbg_print_usage_intro( const char *pname, const char *info ) ;
 void mbg_print_help_options( void ) ;
 void mbg_print_opt_info( const char *opt_name, const char *opt_info ) ;
 void mbg_print_device_options( void ) ;
 void mbg_print_default_usage( const char *pname, const char *prog_info ) ;
 int mbg_ioctl_err( int rc, const char *descr ) ;
 int mbg_get_show_dev_info( MBG_DEV_HANDLE dh, const char *dev_name, PCPS_DEV *p_dev ) ;
 int mbg_check_device( MBG_DEV_HANDLE dh, const char *dev_name,  int (*fnc)( MBG_DEV_HANDLE, const PCPS_DEV *) ) ;
 int mbg_check_devices( int argc, char *argv[], int optind, int (*fnc)( MBG_DEV_HANDLE, const PCPS_DEV *) ) ;
 int mbg_snprint_hr_tstamp( char *s, int len_s, const PCPS_TIME_STAMP *p, int show_raw ) ;
 int mbg_snprint_hr_time( char *s, int len_s, const PCPS_HR_TIME *p, int show_raw ) ;
 void mbg_print_hr_timestamp( PCPS_TIME_STAMP *p_ts, int32_t hns_latency, PCPS_TIME_STAMP *p_prv_ts, int no_latency, int show_raw ) ;
 void mbg_print_hr_time( PCPS_HR_TIME *p_ht, int32_t hns_latency, PCPS_TIME_STAMP *p_prv_ts, int no_latency, int show_raw, int verbose ) ;
 int mbg_show_pzf_corr_info( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev, int show_corr_step ) ;

/* ----- function prototypes end ----- */


#ifdef __cplusplus
}
#endif


/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _TOOLUTIL_H */

