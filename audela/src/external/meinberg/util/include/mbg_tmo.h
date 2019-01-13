
/**************************************************************************
 *
 *  $Id: mbg_tmo.h 1.5 2011/11/28 15:26:47 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Inline functions for portable timeout handling.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbg_tmo.h $
 *  Revision 1.5  2011/11/28 15:26:47  martin
 *  Enabled mbgserio_msec_to_timeval() for Windows.
 *  Revision 1.4  2011/01/26 16:55:33Z  martin
 *  Fixed compiler warnings with gcc/Linux.
 *  Revision 1.3  2010/06/02 12:29:44  daniel
 *  Excluded mbgserio_msec_to_timeval() from build under WIN32 targets.
 *  Revision 1.2  2009/09/01 10:38:21Z  martin
 *  Cleanup for CVI and other targets which don't support inline code.
 *  Revision 1.1  2009/08/24 13:08:56  martin
 *  Initial revision.
 *
 **************************************************************************/

#ifndef _MBG_TMO_H
#define _MBG_TMO_H


/* Other headers to be included */

#include <mbg_tgt.h>
#include <words.h>

#ifdef _MBG_TMO
 #define _ext
 #define _DO_INIT
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( MBG_TGT_UNIX )

  #include <stdlib.h>
  #include <sys/time.h>

  typedef struct timeval MBG_TMO_TIME;

#elif defined( MBG_TGT_WIN32 )

  typedef union
  {
    FILETIME ft;
    uint64_t u64;

  } MBG_TMO_TIME;

#else  // DOS, ...

  #include <time.h>

  #define MBG_TMO_TIME  clock_t

#endif



#if defined( __mbg_inline )

static __mbg_inline
void mbg_tmo_get_time( MBG_TMO_TIME *t )
{
  #if defined( MBG_TGT_UNIX )

    gettimeofday( t, NULL );

  #elif defined( MBG_TGT_WIN32 )

    GetSystemTimeAsFileTime( &t->ft );

  #else  // DOS, ...

    *t = clock();

  #endif

}  // mbg_tmo_get_time

#elif defined( MBG_TGT_CVI )

  #define mbg_tmo_get_time( _t ) \
    GetSystemTimeAsFileTime( &(_t)->ft )

#else  // DOS, ...

  #define mbg_tmo_get_time( _t ) \
    *(_t) = clock();

#endif


#if defined( __mbg_inline )

static __mbg_inline
int mbg_tmo_time_is_set( const MBG_TMO_TIME *t )
{
  #if defined( MBG_TGT_UNIX )

    return ( t->tv_sec != 0 ) || ( t->tv_usec != 0 );

  #elif defined( MBG_TGT_WIN32 )

    return ( t->u64 != 0 );

  #else  // DOS, ...

    return ( *t != 0 );

  #endif

}  // mbg_tmo_time_is_set

#elif defined( MBG_TGT_CVI )

  #define mbg_tmo_time_is_set( _t ) \
    ( (_t)->u64 != 0 )

#else  // DOS, ...

  #define mbg_tmo_time_is_set( _t ) \
    ( *(_t) != 0 )

#endif


#if defined( __mbg_inline )

static __mbg_inline
void mbg_tmo_set_timeout_ms( MBG_TMO_TIME *t_tmo, ulong msec )
{
  mbg_tmo_get_time( t_tmo );

  #if defined( MBG_TGT_UNIX )

    t_tmo->tv_usec += msec * 1000;

    while ( t_tmo->tv_usec > 1000000L )
    {
      t_tmo->tv_usec -= 1000000L;
      t_tmo->tv_sec++;
    }

  #elif defined( MBG_TGT_WIN32 )

    t_tmo->u64 += ( (uint64_t) msec ) * 10000;

  #else  // DOS, ...

    *t_tmo += (clock_t) ( ( (double) msec * CLOCKS_PER_SEC ) / 1000 );

  #endif

}  // mbg_tmo_set_timeout

#elif defined( MBG_TGT_CVI )

  #define mbg_tmo_set_timeout_ms( _t, _msec )   \
    mbg_tmo_get_time( (_t) );                   \
    (_t)->u64 += ( (uint64_t) (_msec) ) * 10000

#else  // DOS, ...

  #define mbg_tmo_set_timeout_ms( _t, _msec )   \
    mbg_tmo_get_time( (_t) );                   \
    *(_t) += (clock_t) ( ( (double) (_msec) * CLOCKS_PER_SEC ) / 1000 );
#endif


#if defined( __mbg_inline )

static __mbg_inline
long mbg_tmo_time_diff_ms( const MBG_TMO_TIME *t, const MBG_TMO_TIME *t0 )
{
  #if defined( MBG_TGT_UNIX )

    return ( t->tv_sec - t0->tv_sec ) * 1000
         + ( t->tv_usec - t0->tv_usec ) / 1000;

  #elif defined( MBG_TGT_WIN32 )

    return (long) ( ( t->u64 - t0->u64 ) / 10000 );

  #else  // DOS, ...

    return (long) ( (double) ( ( *t - *t0 ) * 1000 ) / CLOCKS_PER_SEC );

  #endif

}  // mbg_tmo_time_diff_ms

#elif defined( MBG_TGT_CVI )

  #define mbg_tmo_time_diff_ms( _t, _t0 ) \
    (long) ( ( (_t)->u64 - (_t0)->u64 ) / 10000 )

#else  // DOS, ...

  #define mbg_tmo_time_diff_ms( _t, _t0 ) \
    (long) ( (double) ( ( *(_t) - *(_t0) ) * 1000 ) / CLOCKS_PER_SEC );

#endif


#if defined( __mbg_inline )

static __mbg_inline
int mbg_tmo_time_is_after( const MBG_TMO_TIME *t_now, const MBG_TMO_TIME *tmo )
{
  #if defined( MBG_TGT_UNIX )

    return ( ( t_now->tv_sec > tmo->tv_sec ) ||
           ( ( t_now->tv_sec == tmo->tv_sec ) && ( t_now->tv_usec > tmo->tv_usec ) ) );

  #elif defined( MBG_TGT_WIN32 )

    return ( t_now->u64 > tmo->u64 );

  #else  // DOS, ...

    return ( *t_now > *tmo );

  #endif

}  // mbg_tmo_time_is_after

#elif defined( MBG_TGT_CVI )

  #define mbg_tmo_time_is_after( _t, _tmo ) \
    ( (_t)->u64 > (_tmo)->u64 )

#else  // DOS, ...

  #define mbg_tmo_time_is_after( _t, _tmo ) \
    ( *(_t) > *(_tmo) )

#endif


#if defined( __mbg_inline )

static __mbg_inline
int mbg_tmo_curr_time_is_after( const MBG_TMO_TIME *tmo )
{
  MBG_TMO_TIME t_now;

  mbg_tmo_get_time( &t_now );

  return mbg_tmo_time_is_after( &t_now, tmo );

}  // mbg_tmo_curr_time_is_after

#else

  // needs to be implemented as non-inline function in mbg_tmo.c
  int mbg_tmo_curr_time_is_after( const MBG_TMO_TIME *tmo );

#endif



// The function below can be used to set up a timeout for select().

// check for CVI first since this is a special case of WIN32
#if defined( MBG_TGT_CVI )

  // needs to be implemented as non-inline function in mbg_tmo.c
  void mbgserio_msec_to_timeval( ulong msec, struct timeval *tv );

#elif defined( MBG_TGT_UNIX ) || defined( MBG_TGT_WIN32 ) 

static __mbg_inline
void mbgserio_msec_to_timeval( ulong msec, struct timeval *tv )
{
  tv->tv_sec = msec / 1000;
  tv->tv_usec = ( msec % 1000 ) * 1000;

}  // mbgserio_msec_to_timeval

#endif  // defined( MBG_TGT_UNIX ) || defined( MBG_TGT_WIN32 )


/* function prototypes: */

#ifdef __cplusplus
extern "C" {
#endif

/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

/* (no header definitions found) */

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif

/* End of header body */

#undef _ext
#undef _DO_INIT

#endif  /* _MBG_TMO_H */
