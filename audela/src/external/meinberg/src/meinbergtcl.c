/* meinbergtcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/***************************************************************************/
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers meinberg.cpp.                           */
/***************************************************************************/
/* Le include meinbergtcl.h ne contient des infos concernant Tcl.               */
/***************************************************************************/
#include "meinbergtcl.h"

#include <mbgdevio.h>
#include <mbgtime.h>
#include <pcpslstr.h>
#include <pcpsutil.h>
//#include <toolutil.h>
#include <pcpsmktm.h>


#include <mbgutil.h>

//rajout test linux
//#include <macioctl.h>
//#include <mbgioctl.h>
//#include <pcpsdefs.h>

#define MAX_BUF 583

LANGUAGE language;
CTRY ctry;


//pour gerer la datation par GPS: declaration des variables globales
MBG_DEV_HANDLE dh ;
double date=-1;
double DateGps;
char DateGpst[150];
int channel=0;
        

static const char *ref_name[N_PCPS_REF]= PCPS_REF_NAMES_ENG;
static const char *icode_rx_names[N_ICODE_RX] = DEFAULT_ICODE_RX_NAMES;
static const char *osc_name[N_GPS_OSC] = DEFAULT_GPS_OSC_NAMES;
static int year_limit = 1990;
static unsigned int verbose;
static int max_ref_offs_h = MBG_REF_OFFS_MAX / MINS_PER_HOUR;




















static /*HDR*/
void print_pcps_time( const char *s, const PCPS_TIME *tp, const char *tail )
{
  const char *fmt = "%s";
  char ws[256];

  if ( s ) printf( fmt, s );

  printf( fmt, pcps_date_time_str( ws, tp, year_limit, pcps_tz_name( tp, PCPS_TZ_NAME_FORCE_UTC_OFFS, 0 ) ) );

  if ( tail )
    printf(  fmt, tail );

}  // print_pcps_time

















static /*HDR*/
void print_pcps_time2( char *s, const PCPS_TIME *tp )
{
  char ws[256];
  sprintf( s, "%s ; Date&time: %s", s, pcps_date_time_str( ws, tp, year_limit, pcps_tz_name( tp, PCPS_TZ_NAME_FORCE_UTC_OFFS, 0 ) ) );

}  // print_pcps_time


















static /*HDR*/
void show_ext_stat_info( MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev, const char *tail )
{
  const char *fmt = "%s";
  RECEIVER_INFO ri;
  STAT_INFO si = { 0 };
  char ws[80];
  char *mode_name;

  mbg_setup_receiver_info( dh, p_dev, &ri );


  if ( _pcps_has_stat_info( p_dev ) )
  {
    mbg_get_gps_stat_info( dh, &si );

    if ( _pcps_has_stat_info_mode( p_dev ) )
    {
      switch ( si.mode )
      {
        case AUTO_166: mode_name = "Normal Operation";  break;
        case WARM_166: mode_name = "Warm Boot";         break;
        case COLD_166: mode_name = "Cold Boot";         break;

        default:  // This should never happen!
          sprintf( ws, "Unknown mode of operation: %02Xh", si.mode );
          mode_name = ws;

      }  // switch
    }

    if ( _pcps_has_stat_info_svs( p_dev ) )
      printf( "%s, %i sats in view, %i sats used\n", mode_name, si.svs_in_view, si.good_svs );
  }

  if ( verbose )
  {
    printf( "Osc type: %s", osc_name[( ri.osc_type < N_GPS_OSC ) ? ri.osc_type : GPS_OSC_UNKNOWN] );

    if ( _pcps_has_stat_info( p_dev ) )
    {
      printf( ", DAC cal: %+i, fine: %+i",
              (int) ( si.dac_cal - OSC_DAC_BIAS ),
              (int) ( si.dac_val - OSC_DAC_BIAS ) );
    }

    puts( "" );
  }

  if ( tail )
    printf( fmt, tail );

}  // show_ext_stat_info











static /*HDR*/
void show_ext_stat_info2( char *s, MBG_DEV_HANDLE dh, const PCPS_DEV *p_dev )
{
  RECEIVER_INFO ri;
  STAT_INFO si = { 0 };
  char ws[80];
  char *mode_name;

  mbg_setup_receiver_info( dh, p_dev, &ri );


  if ( _pcps_has_stat_info( p_dev ) )
  {
    mbg_get_gps_stat_info( dh, &si );

    if ( _pcps_has_stat_info_mode( p_dev ) )
    {
      switch ( si.mode )
      {
        case AUTO_166: mode_name = "Normal Operation";  break;
        case WARM_166: mode_name = "Warm Boot";         break;
        case COLD_166: mode_name = "Cold Boot";         break;

        default:  // This should never happen!
          sprintf( ws, "Unknown mode of operation: %02Xh", si.mode );
          mode_name = ws;

      }  // switch
    }

    if ( _pcps_has_stat_info_svs( p_dev ) )
      sprintf(s, "%s ; %s, %i sats in view, %i sats used", s, mode_name, si.svs_in_view, si.good_svs);
  }


}  // show_ext_stat_info












static /*HDR*/
void show_signal( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev, int signal )
{
  int ref_type;
  int rc;

  ref_type = _pcps_ref_type( pdev );

  if ( ref_type >= N_PCPS_REF )
    ref_type = PCPS_REF_NONE;

  printf( "Signal: %u%%  (%s", signal * 100 / PCPS_SIG_MAX, ref_name[ref_type] );

  if ( _pcps_is_irig_rx( pdev ) )
  {
    IRIG_INFO irig_rx_info;
    MBG_REF_OFFS ref_offs;

    rc = mbg_get_irig_rx_info( dh, &irig_rx_info );

    if ( rc == MBG_SUCCESS )
    {
      int idx = irig_rx_info.settings.icode;

      if ( idx < N_ICODE_RX )
      {
        printf( " %s", icode_rx_names[idx] );

        if ( !( MSK_ICODE_RX_HAS_TZI & ( 1UL << idx ) ) )
        {
          if ( _pcps_has_ref_offs( pdev ) )
          {
            rc = mbg_get_ref_offs( dh, &ref_offs );

            if ( rc == MBG_SUCCESS )
            {
              int ref_offs_h = ref_offs / MINS_PER_HOUR;

              if ( abs( ref_offs_h ) > max_ref_offs_h )
                printf( ", ** UTC offs not configured **" );
              else
                printf( ", UTC%+ih", ref_offs_h );
            }
          }
        }
      }
    }
  }
  else
    if ( _pcps_has_pzf( pdev ) )
      printf( "/PZF" );

  printf( ")\n" );

}  // show_signal


















static /*HDR*/
void show_time_and_status( MBG_DEV_HANDLE dh, const PCPS_DEV *pdev, const char *tail )
{
  const char *status_fmt = "Status info: %s%s\n";
  const char *status_err = "*** ";
  const char *status_ok = "";
  PCPS_TIME t;
  PCPS_STATUS_STRS strs;
  int signal;
  int i;
  mbg_get_time( dh, &t );


  print_pcps_time( "Date/time:  ", &t, tail );


  signal = t.signal - PCPS_SIG_BIAS;

  if ( signal < 0 )
    signal = 0;
  else
    if ( signal > PCPS_SIG_MAX )
      signal = PCPS_SIG_MAX;

  if ( _pcps_has_signal( pdev ) )
    show_signal( dh, pdev, signal );


  if ( _pcps_has_irig_time( pdev ) )
  {
    PCPS_IRIG_TIME it;

    mbg_get_irig_time( dh, &it );

  }

  if ( _pcps_is_irig_rx( pdev ) )
  {
    printf( status_fmt,
            ( signal < PCPS_SIG_ERR ) ? status_err : status_ok,
            ( signal < PCPS_SIG_ERR ) ? "NO INPUT SIGNAL"
                                      : "Input signal available" );
  }
  else
  {
    printf( status_fmt,
            ( signal < PCPS_SIG_ERR ) ? status_err : status_ok,
            ( signal < PCPS_SIG_ERR ) ? "ANTENNA IS NOT CONNECTED"
                                      : "Antenna is connected" );
  }

  // Evaluate the status code and setup status messages.
  pcps_status_strs( t.status, _pcps_time_is_read( &t ),
                    _pcps_is_gps( pdev ), &strs );

  // Print the status messages.
  for ( i = 0; i < N_PCPS_STATUS_STR; i++ )
  {
    PCPS_STATUS_STR *pstr = &strs.s[i];
    if ( pstr->cp )
      printf( status_fmt,
              pstr->is_err ? status_err : status_ok,
              pstr->cp );
  }

}  // show_time_and_status








static /*HDR*/
void show_time_and_status2( char *s, MBG_DEV_HANDLE dh, const PCPS_DEV *pdev )
{
  const char *status_err = "*** ";
  const char *status_ok = "";
  PCPS_TIME t;
  PCPS_STATUS_STRS strs;
  int signal;
  int i;

  mbg_get_time( dh, &t );
  print_pcps_time2( s, &t );

  signal = t.signal - PCPS_SIG_BIAS;

  if ( signal < 0 )
    signal = 0;
  else
    if ( signal > PCPS_SIG_MAX )
      signal = PCPS_SIG_MAX;

  if ( _pcps_has_signal( pdev ) )
    show_signal( dh, pdev, signal );


  if ( _pcps_has_irig_time( pdev ) )
  {
    PCPS_IRIG_TIME it;
    mbg_get_irig_time( dh, &it );
  }

  if ( _pcps_is_irig_rx( pdev ) )
  {
    sprintf(s, "%s ; Status info: %s%s", s,
            ( signal < PCPS_SIG_ERR ) ? status_err : status_ok,
            ( signal < PCPS_SIG_ERR ) ? "NO INPUT SIGNAL"
                                      : "Input signal available" );
  }
  else
  {
    sprintf( s, "%s ; Status info: %s%s", s,
            ( signal < PCPS_SIG_ERR ) ? status_err : status_ok,
            ( signal < PCPS_SIG_ERR ) ? "ANTENNA IS NOT CONNECTED"
                                      : "Antenna is connected" );
  }

  // Evaluate the status code and setup status messages.
  pcps_status_strs( t.status, _pcps_time_is_read( &t ),
                    _pcps_is_gps( pdev ), &strs );

  // Print the status messages.
  for ( i = 0; i < N_PCPS_STATUS_STR; i++ )
  {
    PCPS_STATUS_STR *pstr = &strs.s[i];
    if ( pstr->cp )
      sprintf( s, "%s ; Status info: %s%s", s,
              pstr->is_err ? status_err : status_ok,
              pstr->cp );
  }

}  // show_time_and_status2












static /*HDR*/
void show_status2( char *s, MBG_DEV_HANDLE dh, const PCPS_DEV *pdev )
{
  const char *status_err = "*** ";
  const char *status_ok = "";
  PCPS_TIME t;
  PCPS_STATUS_STRS strs;
  int signal;
  int i;

  mbg_get_time( dh, &t );

  signal = t.signal - PCPS_SIG_BIAS;

  if ( signal < 0 )
    signal = 0;
  else
    if ( signal > PCPS_SIG_MAX )
      signal = PCPS_SIG_MAX;

  if ( _pcps_has_signal( pdev ) )
    show_signal( dh, pdev, signal );


  if ( _pcps_has_irig_time( pdev ) )
  {
    PCPS_IRIG_TIME it;
    mbg_get_irig_time( dh, &it );
  }

    sprintf( s, "%s ; Status info: %s%s", s,
            ( signal < PCPS_SIG_ERR ) ? status_err : status_ok,
            ( signal < PCPS_SIG_ERR ) ? "ANTENNA IS NOT CONNECTED"
                                      : "Antenna is connected" );

  // Evaluate the status code and setup status messages.
  pcps_status_strs( t.status, _pcps_time_is_read( &t ),
                    _pcps_is_gps( pdev ), &strs );

  // Print the status messages.
  for ( i = 0; i < N_PCPS_STATUS_STR; i++ )
  {
    PCPS_STATUS_STR *pstr = &strs.s[i];
    if ( pstr->cp )
      sprintf( s, "%s ; Status info: %s%s", s,
              pstr->is_err ? status_err : status_ok,
              pstr->cp );
  }

}  // show_time_and_status2






static /*HDR*/
void show_sync_time( MBG_DEV_HANDLE dh, const char *tail )
{
  PCPS_TIME t;
  mbg_get_sync_time( dh, &t );

  print_pcps_time( "Last sync:  ", &t, tail );

}  // show_sync_time












static /*HDR*/
void show_sync_time2( char *s, MBG_DEV_HANDLE dh )
{
  char ws[256];
  PCPS_TIME t;
  mbg_get_sync_time( dh, &t );
  sprintf( s, "%s ; Last sync: %s", s, pcps_date_time_str( ws, &t, year_limit, pcps_tz_name( &t, PCPS_TZ_NAME_FORCE_UTC_OFFS, 0 ) ) );

}  // show_sync_time2


















static /*HDR*/
void print_dms( const char *s, const DMS *p, const char *tail )
{
  const char *fmt = "%s";

  printf( "%s %c %3i deg %02i min %05.2f sec",
          s,
          p->prefix,
          p->deg,
          p->min,
          p->sec
        );

  if ( tail )
    printf( fmt, tail );

}  // print_dms



static /*HDR*/
void print_position( const char *s, const POS *p, const char *tail )
{
  const char *fmt = "%s";
  double r2d = 180 / PI;


  if ( s )
    printf( fmt, s );

  // LLA latitude and longitude are in radians, convert to degrees
  printf( "  lat: %+.4f lon: %+.4f alt: %.0fm",
          p->lla[LAT] * r2d, p->lla[LON] * r2d, p->lla[ALT] );

  if ( tail )
    printf( fmt, tail );

  print_dms( "  latitude: ", &p->latitude, tail );
  print_dms( "  longitude:", &p->longitude, tail );

}  // print_position



static /*HDR*/
void show_gps_pos( MBG_DEV_HANDLE dh, const char *tail )
{
  POS pos;
  mbg_get_gps_pos( dh, &pos );

  print_position( "Receiver Position:\n", &pos, tail );

}  // show_gps_pos








       
int Cmd_meinbergtcl_gps(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* I/O with GPS cards                                                  */
/****************************************************************************/
/* type of card curently read : meinberg
meinberg_gps open ?-channel?
meinberg_gps reset 
meinberg_gps read 
meinberg_gps close
meinberg_gps fastread
*/
/****************************************************************************/
{

   char s[16384];
   int mode,k,i,devices_found,c,hd;
   static PCPS_DEV dev;
   PCPS_UCAP_ENTRIES ucap_entries;
   PCPS_TIME t;
   char year[5], month[5], day[5], hour[5], minute[5], sec[5], msec[5], usec[5], p[10];
   char ws[200];
   // used in fastread
	 int rc,j;
    char save[150];


   strcpy(s,"");
   
   
   if(argc<2) {
      sprintf(s,"Usage: %s open ?-channel?|reset|read|close|fastread|time", argv[0]);
   } else {
      
      /* --- decodage des arguments ---*/
      mode=0;
      if (strcmp(argv[1],"open")==0) {
         mode=1;
         if ((argc>2) && (strcmp(argv[2],"-channel")==0)) {
            channel=1;
         }
      }
      else if (strcmp(argv[1],"reset")==0) {
         mode=2;
      }
      else if (strcmp(argv[1],"read")==0) {
         mode=3;
      }
      else if (strcmp(argv[1],"close")==0) {
         mode=4;
      }
      else if (strcmp(argv[1],"status")==0) {
         mode=5;
      }
      else if (strcmp(argv[1],"fastread")==0) {
         mode=6;
      }
      else if (strcmp(argv[1],"time")==0) {
         mode=7;
      }
      else if (strcmp(argv[1],"readstack")==0) {
         mode=8;
      }
      else if (strcmp(argv[1],"read2dates")==0) {
         mode=9;
      }
      if (mode==0) {
         sprintf(s,"Usage: %s open|read|close", argv[0]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      

      /* --- OPEN MEINBERG ---*/
      if (mode==1) {
         c = mbgdevio_get_version();
         sprintf(s,"%s version = %d",s,c);
         devices_found = mbg_find_devices();
         if ( devices_found == 0 ) {
            sprintf(s,"%s No GPS meinberg card found Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         i=devices_found-1;
         dh = mbg_open_device( i );
         if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s Can't open GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         // setup ctry (necessary to correctly print date and time)
         ctry_setup( 0 );
         language = LNG_ENGLISH;
         ctry.dt_fmt = DT_FMT_YYYYMMDD;
         ctry.dt_sep = '-';
         // open shell
         printf("OPEN-SHELL\n");
         mbg_get_device_info( dh, &dev);
         show_ext_stat_info( dh, &dev, NULL );
         show_time_and_status( dh, &dev, "\n" );
         show_sync_time( dh, "\n" );
         show_gps_pos( dh, "\n" );
         mbg_get_time(dh,&t);
         print_pcps_time( "Date/time:  ", &t, "\n" );

         printf("OPEN-CONSOLE\n");
         show_ext_stat_info2( s, dh, &dev);
         show_time_and_status2( s, dh, &dev);
         show_sync_time2( s, dh );
         
         sprintf(s,"%s ; Connection with Meinberg is opened",s);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      /* --- reset meinberg ---*/
      /* --- remove every event on the FIFO controler on the GPS board ---*/
      if (mode==2) {
        if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s No GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
        if ( PCPS_SUCCESS == mbg_clr_ucap_buff( dh ) ) {
            sprintf(s,"Capture buffer cleared for meinberg");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_OK;
        } else {
            sprintf(s,"Failed to clear capture buffer for meinberg");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
        }
      }
      /* --- read time meinberg ---*/
      /* dans ce mode on va lire le buffer jusqu'a la derniere date et on renvoit seulement la derniere date */
      if (mode==3) {
        if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s No GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_OK;
         }
         // on veut recuperer le dernier evenement entres si dispo
         if ( _pcps_has_ucap( &dev ) ) {
            PCPS_HR_TIME ucap_event;
            // read all entries from capture buffer
            date=0;
            for (;;) {
               if ( PCPS_SUCCESS != mbg_get_ucap_entries( dh, &ucap_entries )) {
                  sprintf(s,"Failed to read user capture buffer entries for meinberg");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_OK;
                  break;
               }
               if ( PCPS_SUCCESS != mbg_get_ucap_event( dh, &ucap_event )) {
                  sprintf(s,"Failed to read user capture event for meinberg");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_OK;
                  break;
               }

               // If a user capture event has been read
               // then it it removed from the clock's buffer.

               // If no new capture event is available, the ucap.tstamp structure
               // is set to 0.
               // Alternatively, PCPS_UCAP_ENTRIES.used can be checked for the 
               // number of events pending in the buffer.
               if ( ucap_event.tstamp.sec == 0 ) // no new user capture event
                    break;
 
               // Format function taken from mbgutil.h
               mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &ucap_event );
               
               // format iso
               for (k=6;k<=9;k++) { p[k-6]=ws[k];    }; p[k-6]='\0';
               strcpy(year,p); 
               for (k=3;k<=4;k++) { p[k-3]=ws[k]; } ; p[k-3]='\0';
               strcpy(month,p);
               for (k=0;k<=1;k++) { p[k]=ws[k]; } ; p[k]='\0';
               strcpy(day,p);
               for (k=12;k<=13;k++) { p[k-12]=ws[k]; } ; p[k-12]='\0';
               strcpy(hour,p);
               for (k=15;k<=16;k++) { p[k-15]=ws[k]; } ; p[k-15]='\0';
               strcpy(minute,p);
               for (k=18;k<=19;k++) { p[k-18]=ws[k]; } ; p[k-18]='\0';
               strcpy(sec,p);
               for (k=21;k<=23;k++) { p[k-21]=ws[k]; } ; p[k-21]='\0';
               strcpy(msec,p);
               for (k=24;k<=26;k++) { p[k-24]=ws[k]; } ; p[k-24]='\0';
               strcpy(usec,p);
               hd=atoi(hour);
               sprintf(hour,"%2.2d",hd);
               sprintf(DateGpst,"%s-%s-%sT%s:%s:%s.%s%s", year, month, day, hour, minute, sec, msec, usec );
               date=1;
            }
            
            if (date==0) {
               sprintf(s,"No GPS date available");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_OK;
            } else {
               sprintf(s,"%s",DateGpst);
               printf("\n *** Last buf date : %s\n",DateGpst);
               show_status2( s, dh, &dev);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }
      
      /* --- close meinberg ---*/
      if (mode==4) {
        if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s No GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         mbg_close_device( &dh );  
         sprintf(s,"Connection with meinberg is closed");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      /* --- status meinberg ---*/
      if (mode==5) {
         if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s No GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         } 
         c = mbgdevio_get_version();
         sprintf(s,"Status of meinber card:");
         sprintf(s,"%s version = %d",s,c);
         
    
         // affiche info exemple : Normal Operation, 9 sats in view, 8 sats used
         show_ext_stat_info2( s, dh, &dev);
         // affiche info exemple : Date&time: Mo, 2014-02-17  11:35:57.75 UTC+0h ; Status info: Antenna is connected ; Status info: Time is synchronized ; Status info: Receiver position has been verified ; 
         show_time_and_status2( s, dh, &dev);
         // affiche info exemple : Last sync: Mo, 2014-02-17  11:37:00.00 UTC ;
         show_sync_time2( s, dh );

         sprintf(s,"%s; Status of meinberg",s);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
			/* --- fastread ---*/
      if (mode==6) {
        PCPS_HR_TIME ucap_event[MAX_BUF];

        if ( dh == MBG_INVALID_DEV_HANDLE ) {
          sprintf(s,"%s No GPS device Meinberg",s);
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_ERROR;
        }

        // see mbggpscap.c in Meinberg driver
        if ( _pcps_has_ucap( &dev ) ) {
          PCPS_UCAP_ENTRIES ucap_entries;
          if ( mbg_get_ucap_entries( dh, &ucap_entries ) == MBG_SUCCESS ) {
            if ( ucap_entries.max )
              ucap_entries.max--;
            } else {
            sprintf(s,"Unable to get meinberg entries");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
          }

          if ( ucap_entries.used == 0 ) {
            //sprintf(s,"No GPS event");
            show_status2(s,dh,&dev);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_OK;
          }

          for (j=0;j<MAX_BUF;j++) {
            //PCPS_HR_TIME ucap_event;
            rc = mbg_get_ucap_event( dh, &ucap_event[j] );
            if ( mbg_ioctl_err( rc, "mbg_get_ucap_event" ) ) {
              sprintf(s,"Unable to get ucap event");
              Tcl_SetResult(interp,s,TCL_VOLATILE);
              return TCL_ERROR;
            }

            if ( ucap_event[j].tstamp.sec || ucap_event[j].tstamp.frac ) {
              //mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &ucap_event[j] );
              //printf("Event: %s\n",ws);
              if ( ucap_event[j].status & PCPS_UCAP_OVERRUN ) {
                sprintf(s,"Capture overrun: the events have occurred too fast");
                Tcl_SetResult(interp,s,TCL_VOLATILE);
                return TCL_ERROR;
              }
              if ( ucap_event[j].status & PCPS_UCAP_BUFFER_FULL ) {
                sprintf(s,"Buffer overrun: events lost");
                Tcl_SetResult(interp,s,TCL_VOLATILE);
                return TCL_ERROR;
              }
              continue;
            } else {
              //printf("Read %d events\n",read);
              //printf("ucap_event is %u bytes while ws string is %u bytes\n",sizeof(PCPS_HR_TIME),strlen(ws));
              break;
            }

          }

          if ( j >= MAX_BUF ) {
            sprintf(s,"Internal buffer overrun");
            Tcl_SetResult(interp,s,TCL_VOLATILE);
          }
				
          //printf("Read %d events\n",j);

          strcpy(s,"");

          for (i=0; i<j; i++) {
            // Format function taken from mbgutil.h
            mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &ucap_event[i] );
               
            // format iso
            for (k=6;k<=9;k++) { p[k-6]=ws[k];    }; p[k-6]='\0';
            strcpy(year,p); 
            for (k=3;k<=4;k++) { p[k-3]=ws[k]; } ; p[k-3]='\0';
            strcpy(month,p);
            for (k=0;k<=1;k++) { p[k]=ws[k]; } ; p[k]='\0';
            strcpy(day,p);
            for (k=12;k<=13;k++) { p[k-12]=ws[k]; } ; p[k-12]='\0';
            strcpy(hour,p);
            for (k=15;k<=16;k++) { p[k-15]=ws[k]; } ; p[k-15]='\0';
            strcpy(minute,p);
            for (k=18;k<=19;k++) { p[k-18]=ws[k]; } ; p[k-18]='\0';
            strcpy(sec,p);
            for (k=21;k<=23;k++) { p[k-21]=ws[k]; } ; p[k-21]='\0';
            strcpy(msec,p);
            for (k=24;k<=26;k++) { p[k-24]=ws[k]; } ; p[k-24]='\0';
            strcpy(usec,p);
            hd=atoi(hour);
            sprintf(hour,"%2.2d",hd);
            sprintf(s,"%s %s-%s-%sT%s:%s:%s.%s%s", s, year, month, day, hour, minute, sec, msec, usec );
            if (channel==1) {
              sprintf(s,"%sX%i",s,ucap_event[i].signal); 
            }
          }

          //sprintf(s,"%s\nRead %d events",s,j);
					
          show_status2(s,dh,&dev);
          Tcl_SetResult(interp,s,TCL_VOLATILE);
          return TCL_OK;
        }
      }
      /* --- meinberg time---*/
      if (mode==7) {
         if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s No GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }

         PCPS_TIME t;

         mbg_get_time( dh, &t );

         pcps_date_time_str( s, &t, year_limit, pcps_tz_name( &t, PCPS_TZ_NAME_FORCE_UTC_OFFS, 0 ) );
         
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      /* --- readstack time meinberg ---*/
      /* dans ce mode on va lire le buffer jusqu'a la derniere date et on renvoit toute la pile */
      if (mode==8) {
        if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s No GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_OK;
         }
         // on veut recuperer le dernier evenement entres si dispo
         if ( _pcps_has_ucap( &dev ) ) {
            PCPS_HR_TIME ucap_event;
            // read all entries from capture buffer
            date=0;
         
            for (;;) {
               if ( PCPS_SUCCESS != mbg_get_ucap_entries( dh, &ucap_entries )) {
                  sprintf(s,"Failed to read user capture buffer entries for meinberg");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_OK;
                  break;
               }
               if ( PCPS_SUCCESS != mbg_get_ucap_event( dh, &ucap_event )) {
                  sprintf(s,"Failed to read user capture event for meinberg");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_OK;
                  break;
               }

               // If a user capture event has been read
               // then it it removed from the clock's buffer.

               // If no new capture event is available, the ucap.tstamp structure
               // is set to 0.
               // Alternatively, PCPS_UCAP_ENTRIES.used can be checked for the 
               // number of events pending in the buffer.
               if ( ucap_event.tstamp.sec == 0 ) // no new user capture event
                    break;
 
               // Format function taken from mbgutil.h
               mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &ucap_event );
               
               // format iso
               for (k=6;k<=9;k++) { p[k-6]=ws[k];    }; p[k-6]='\0';
               strcpy(year,p); 
               for (k=3;k<=4;k++) { p[k-3]=ws[k]; } ; p[k-3]='\0';
               strcpy(month,p);
               for (k=0;k<=1;k++) { p[k]=ws[k]; } ; p[k]='\0';
               strcpy(day,p);
               for (k=12;k<=13;k++) { p[k-12]=ws[k]; } ; p[k-12]='\0';
               strcpy(hour,p);
               for (k=15;k<=16;k++) { p[k-15]=ws[k]; } ; p[k-15]='\0';
               strcpy(minute,p);
               for (k=18;k<=19;k++) { p[k-18]=ws[k]; } ; p[k-18]='\0';
               strcpy(sec,p);
               for (k=21;k<=23;k++) { p[k-21]=ws[k]; } ; p[k-21]='\0';
               strcpy(msec,p);
               for (k=24;k<=26;k++) { p[k-24]=ws[k]; } ; p[k-24]='\0';
               strcpy(usec,p);
               hd=atoi(hour);
               sprintf(hour,"%2.2d",hd);
               sprintf(DateGpst,"%s-%s-%sT%s:%s:%s.%s%s", year, month, day, hour, minute, sec, msec, usec );
               
               // envoit toutes les dates dans la pile de la carte
               printf("%s\n", DateGpst);
               date=1;
            }
            
            if (date==0) {
               sprintf(s,"No GPS date available");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_OK;
            } else {
               sprintf(s,"%s",DateGpst);
               printf("\n *** Last buf date : %s\n",DateGpst);
               show_status2( s, dh, &dev);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

       /* --- read2dates time meinberg ---*/
      /* dans ce mode on va lire les deux dernières dates dans le buffer */
      if (mode==9) {
        if ( dh == MBG_INVALID_DEV_HANDLE ) {
            sprintf(s,"%s No GPS device Meinberg",s);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_OK;
         }
         // on veut recuperer le dernier evenement entres si dispo
         if ( _pcps_has_ucap( &dev ) ) {
            PCPS_HR_TIME ucap_event;
            // read all entries from capture buffer
            date=0;
            strcpy(DateGpst,"");
            for (;;) {
               if ( PCPS_SUCCESS != mbg_get_ucap_entries( dh, &ucap_entries )) {
                  sprintf(s,"Failed to read user capture buffer entries for meinberg");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_OK;
                  break;
               }
               if ( PCPS_SUCCESS != mbg_get_ucap_event( dh, &ucap_event )) {
                  sprintf(s,"Failed to read user capture event for meinberg");
                  Tcl_SetResult(interp,s,TCL_VOLATILE);
                  return TCL_OK;
                  break;
               }

               // If a user capture event has been read
               // then it it removed from the clock's buffer.

               // If no new capture event is available, the ucap.tstamp structure
               // is set to 0.
               // Alternatively, PCPS_UCAP_ENTRIES.used can be checked for the 
               // number of events pending in the buffer.
               if ( ucap_event.tstamp.sec == 0 ) // no new user capture event
                    break;
 
               // Format function taken from mbgutil.h
               mbg_str_pcps_hr_tstamp_utc( ws, sizeof( ws ), &ucap_event );
               
               // format iso
               for (k=6;k<=9;k++) { p[k-6]=ws[k];    }; p[k-6]='\0';
               strcpy(year,p); 
               for (k=3;k<=4;k++) { p[k-3]=ws[k]; } ; p[k-3]='\0';
               strcpy(month,p);
               for (k=0;k<=1;k++) { p[k]=ws[k]; } ; p[k]='\0';
               strcpy(day,p);
               for (k=12;k<=13;k++) { p[k-12]=ws[k]; } ; p[k-12]='\0';
               strcpy(hour,p);
               for (k=15;k<=16;k++) { p[k-15]=ws[k]; } ; p[k-15]='\0';
               strcpy(minute,p);
               for (k=18;k<=19;k++) { p[k-18]=ws[k]; } ; p[k-18]='\0';
               strcpy(sec,p);
               for (k=21;k<=23;k++) { p[k-21]=ws[k]; } ; p[k-21]='\0';
               strcpy(msec,p);
               for (k=24;k<=26;k++) { p[k-24]=ws[k]; } ; p[k-24]='\0';
               strcpy(usec,p);
               hd=atoi(hour);
               sprintf(hour,"%2.2d",hd);
               strcpy(save,DateGpst);
               sprintf(DateGpst,"%s-%s-%sT%s:%s:%s.%s%s", year, month, day, hour, minute, sec, msec, usec );
               // envoit toutes les dates dans la pile de la carte
               // printf("%s\n", DateGpst);
               date=1;
            }
            
            if (date==0) {
               sprintf(s,"No GPS date available");
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_OK;
            } else {
               sprintf(s,"%s ; %s",DateGpst,save);
               //printf("\n *** Last buf date : %s\n",DateGpst);
               show_status2( s, dh, &dev);
               Tcl_SetResult(interp,s,TCL_VOLATILE);
               return TCL_OK;
            }
         }
      }

      

   }
    
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return TCL_ERROR;
   
}


/*There are 3 functions to deal with the meinberg capture events:

     \li mbg_clr_ucap_buff() clears the on-board FIFO buffer
     \li mbg_get_ucap_entries() returns the maximum number of entries
       and the currently saved number of entries in the buffer
     \li mbg_get_ucap_event() retrieves a capture event from the
       on-board FIFO, or 0000.0000 if the FIFO buffer is empty.
   
     When using the time capture inputs the following hints might be helpful:
   
     \li The corresponding DIP switches on the card must be set to the "ON"
     position in order to wire the input pins to the capture circuitry. See
     the user manual for the correct DIP switches.
     \li Capture events are stored in the on-board FIFO, and entries can be
     retrieved from the FIFO in different ways. Once an entry has been
     retrieved it is removed from the FIFO, so if several ways or
     applications are used at the same time to retrieve capture events from
     the FIFO then capture events may be missed by one application since they
     have already been retrieved by another application.
     \li The card provides 2 physical serial interfaces either of which may
     have been configured to send a serial ASCII string automatically
     whenever a capture event has occurred. Of course this would also remove
     those capture events from the FIFO buffer. So the settings of both
     serial ports should be checked to make sure none of the serial ports
     have been configured to send the capture string automatically. This has
     to be done only once for a card */




