// mbgdmpst.cpp : Defines the entry point for the application.
//

#include <mbgsvcio.h>
#include <pcpsdefs.h>

#include <stdio.h>




static const char *prog_info = "Meinberg Time Adjustment Status Dumper";
static const char *prog_version = "v1.1";

#define SECTION_INFO   "[Info]"
#define SECTION_OUTPUT "[Output]"
 
#define KEY_SVC_ACTIVE         "SvcTimeAdjustmentActive"
#define KEY_SVC_REF_ACCESSIBLE "SvcRefTimeAccessible"


#define KEY_FREER              "RefTimeNotSynchronized"
#define KEY_DL_ENB             "RefDaylightSavingEnabled"
#define KEY_SYNC_AFTER_RESET   "RefSyncAfterReset"
#define KEY_DL_ANN             "RefDaylightChangeAnnounced"
#define KEY_UTC                "RefIsUtc"
#define KEY_LS_ANN             "RefLeapSecondAnnounced"
#define KEY_SET_MANUALLY       "RefTimeSetManually"
#define KEY_INV_TIME           "RefTimeInvalid"



static /*HDR*/
void dump_status_item( FILE *fp, const char *name, int val, int cond )
{
  fprintf( fp, "%s=", name );

  if ( cond )
    fprintf( fp, "%i", val );

  fprintf( fp, "\n" );

}  // dump_status_item



static /*HDR*/
void dump_status( FILE *fp, int st, int cond )
{
  #define N_STATUS 8

  typedef struct
  {
    int mask;
    const char *key_name;
  } ST_INFO;

  static const ST_INFO st_info[N_STATUS] =
  {
    { PCPS_FREER, KEY_FREER },
    { PCPS_DL_ENB, KEY_DL_ENB },
    { PCPS_SYNCD, KEY_SYNC_AFTER_RESET },
    { PCPS_DL_ANN, KEY_DL_ANN },
    { PCPS_UTC, KEY_UTC },
    { PCPS_LS_ANN, KEY_LS_ANN },
    { PCPS_IFTM, KEY_SET_MANUALLY },
    { PCPS_INVT, KEY_INV_TIME }
  };

  int i;


  for ( i = 0; i < N_STATUS; i++ )
  {
    const ST_INFO *p = &st_info[i];
    int val = ( st & p->mask ) != 0;
    dump_status_item( fp, p->key_name, val, cond );
  } 

}  // dump_status



/*HDR*/
void mbg_dump_time_adjustment_status( FILE *fp )
{
  static const char *key_svc_active     = KEY_SVC_ACTIVE;
  static const char *key_ref_accessible = KEY_SVC_REF_ACCESSIBLE;

  int svc_active;
  int ref_accessible;
  int ref_time_status;

  fprintf( fp,
           "%s\n"
           "About=%s %s\n"
           "\n",
           SECTION_INFO, 
           prog_info,
           prog_version
         );

  fprintf( fp, "%s\n", SECTION_OUTPUT );

  svc_active = mbg_time_adjustment_active();
  dump_status_item( fp, key_svc_active, svc_active, 1 );

  svc_active = svc_active > 0;

  ref_accessible = svc_active && mbg_ref_time_accessible();
  dump_status_item( fp, key_ref_accessible, ref_accessible, svc_active );

  ref_accessible = ref_accessible > 0;

  ref_time_status = mbg_get_ref_time_status();
  dump_status( fp, ref_time_status, ref_accessible );

  fprintf( fp, "\n" ); 

}  // mbg_dump_time_adjustment_status




int main(int argc, char* argv[])
{
#if 1
  if ( argc > 1 )
  {
    FILE *fp = fopen( argv[1], "wt" );

    if ( fp )
    { 
      mbg_dump_time_adjustment_status( fp );
      fclose( fp );
    }
  }
#endif

	return 0;
}



