
/**************************************************************************
 *
 *  $Id: ctry.h 1.12 2011/06/22 07:37:57 martin REL_M $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions and prototypes for ctry.c.
 *
 * -----------------------------------------------------------------------
 *  $Log: ctry.h $
 *  Revision 1.12  2011/06/22 07:37:57  martin
 *  Cleaned up handling of pragma pack().
 *  Revision 1.11  2010/07/15 08:33:41  martin
 *  Added some macros implemented by Stefan.
 *  Updated function prototypes.
 *  Revision 1.10  2007/03/29 12:21:10  martin
 *  Updated function prototypes.
 *  Revision 1.9  2004/10/26 07:38:50Z  martin
 *  Redefined interface data types using C99 fixed-size definitions.
 *  Updated function prototypes.
 *  Revision 1.8  2004/04/14 08:47:28  martin
 *  Pack structures 1 byte aligned.
 *  Revision 1.7  2002/02/19 09:28:00Z  MARTIN
 *  Use new header mbg_tgt.h to check the target environment.
 *  Revision 1.6  2001/09/14 12:04:40  MARTIN
 *  Modified definition for CLSTR.
 *  Updated function prototypes.
 *  Revision 1.5  2001/02/28 15:07:06  MARTIN
 *  Modified preprocessor syntax.
 *  Revision 1.4  2000/11/27 14:13:27  MARTIN
 *  New types CLSTR, PLSTR, and PCLSTR.
 *  New macro _lstr() calls lstr_lng() for the current language.
 *  Definitions associated  with ctry_fmt_dt() and ctry_fmt_times() 
 *  have been moved to a new file ctry_fmt.h.
 *  Updated function prototypes.
 *  Revision 1.3  2000/08/17 15:35:02  MARTIN
 *  No init function by default (previously DOS), 
 *  Revision 1.2  2000/07/21 09:48:34  MARTIN
 *  Initial revision
 *
 **************************************************************************/

#ifndef _CTRY_H
#define _CTRY_H


/* Other headers to be included */

#include <mbg_tgt.h>
#include <words.h>

#if defined( MBG_TGT_NETWARE )
  #include <ctry_nw.h>
#elif defined( MBG_TGT_OS2 )
  #include <ctry_os2.h>
#elif defined( MBG_TGT_WIN32 )
  // #include <ctry_w32.h>
#elif defined( MBG_TGT_LINUX )
  // #include <ctry_lx.h>
#elif defined( MBG_TGT_DOS )
  #include <ctry_dos.h>
#else
  // nothing to include for C166 etc.
#endif

#include <use_pack.h>


#ifdef _CTRY
 #define _ext
#else
 #define _ext extern
#endif


/* Start of header body */

#if defined( _USE_PACK )
  #pragma pack( 1 )      // set byte alignment
  #define _USING_BYTE_ALIGNMENT
#endif


#ifdef __cplusplus
extern "C" {
#endif


// the definitions below are used to support different languages:
typedef uint8_t LANGUAGE;
typedef uint16_t CTRY_CODE;

// codes used with LANGUAGE:
#if !defined LNG_DEFINED
  enum
  {
    LNG_ENGLISH,
    LNG_GERMAN,
    N_LNG
  };

  #define LNG_DEFINED
#endif

// the type below is used to declare string variables
// for several languages
typedef char *LSTR[N_LNG];           // array of strings
typedef char **PLSTR;                // pointer to array

// same as above, but const
typedef const char * const CLSTR[N_LNG];    // array of strings
typedef const char * const *PCLSTR;  // pointer to array


// the definitions below are used to handle date and time
// formats used by different countries:
typedef struct
{
  CTRY_CODE code;

  uint8_t dt_fmt;          // (codes defined below)
  uint8_t tm_fmt;          // (codes defined below)
  char dt_sep;             // (valid chars defined below)
  char tm_sep;             // (valid chars defined below)
} CTRY;


// codes used with CTRY.code:
#define CTRY_US           1
#define CTRY_UK          44
#define CTRY_GERMANY     49


#ifndef CTRY_DEFINED

  #define CTRY_DEFINED

  // codes used with CTRY.dt_fmt:
  enum
  {
    DT_FMT_DDMMYYYY,
    DT_FMT_MMDDYYYY,
    DT_FMT_YYYYMMDD,
    N_DT_FMT
  };

  // codes used with CTRY.tm_fmt:
  enum
  {
    TM_FMT_24H,
    // TM_FMT_12H,  // not yet supported
    N_TM_FMT
  };


  // codes used with CTRY.dt_sep:
  #define DT_SEP_DOT    '.'
  #define DT_SEP_MINUS  '-'
  #define DT_SEP_SLASH  '/'

  // a zero-terminated list of valid dt_sep characters
  #define DT_SEP_LIST   { DT_SEP_DOT, DT_SEP_MINUS, DT_SEP_SLASH, 0 }


  // codes used with CTRY.tm_sep:
  #define TM_SEP_COLON  ':'
  #define TM_SEP_DOT    '.'

  // a zero-terminated list of valid tm_sep characters
  #define TM_SEP_LIST   { TM_SEP_COLON, TM_SEP_DOT, 0 }

#endif // CTRY_DEFINED


extern LANGUAGE language;
extern CTRY ctry;


#define _ctry_init() \
  ctry_setup( ctry_get_code() )


#define _next_language()      \
{                             \
  if ( ++language >= N_LNG )  \
    language = 0;             \
                              \
}  // next_language


// macro to call lstr_lng with the current language
#define _lstr( _s )   lstr_lng( (_s), language )

// macro to call clstr_lng with the current language, and a set of strings
#define _clstr( _s )  clstr_lng( language, _s )

// macros used in wxWidgets projects
#if defined( __WXWINDOWS__ )
  #define _wx_lstr( _s )   wxString::From8BitData( lstr_lng( (_s), language ) )
  #define _wx_clstr( _s )  wxString::From8BitData( clstr_lng( language, _s ) )
#endif


/* ----- function prototypes begin ----- */

/* This section was generated automatically */
/* by MAKEHDR, do not remove the comments. */

 int lstr_idx( CLSTR s, int lng ) ;
 int lstr_array_idx( CLSTR s, int idx, int n_lng, int lng ) ;
 const char *lstr_lng( CLSTR s, int lng ) ;
 void ctry_setup( CTRY_CODE code ) ;
 void ctry_next( void ) ;
 const char *clstr_lng( int index, ... ) ;

/* ----- function prototypes end ----- */

#ifdef __cplusplus
}
#endif


#if defined( _USING_BYTE_ALIGNMENT )
  #pragma pack()      // set default alignment
  #undef _USING_BYTE_ALIGNMENT
#endif

/* End of header body */


#undef _ext

#endif  /* _CTRY_H */

