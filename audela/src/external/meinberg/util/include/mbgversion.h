
/**************************************************************************
 *
 *  $Id: mbgversion.h 1.1 2011/07/08 11:38:32 martin TEST $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Program version definitions for package mbgtools-lx.
 *
 * -----------------------------------------------------------------------
 *  $Log: mbgversion.h $
 *  Revision 1.1  2011/07/08 11:38:32  martin
 *  Initial revision for pre-release.
 *
 **************************************************************************/

#define MBG_CURRENT_COPYRIGHT_YEAR      2011
#define MBG_CURRENT_COPYRIGHT_YEAR_STR  "2011"

#define MBG_MAJOR_VERSION_CODE          3
#define MBG_MINOR_VERSION_CODE          4

#define MBG_MAIN_VERSION_STR            "3.4"

// The codes below should only fe defined in development/pre-release versions
#define MBG_MICRO_VERSION_CODE_DEV      99
#define MBG_MICRO_VERSION_STR_DEV       "99"


#define MBG_MAIN_VERSION_CODE           ( ( MBG_MAJOR_VERSION_CODE << 8 ) | MBG_MINOR_VERSION_CODE )

#define MBG_VERSION_CODE( _micro )      ( (uint16_t) ( ( MBG_MAIN_VERSION_CODE << 8 ) | (_micro) ) )
