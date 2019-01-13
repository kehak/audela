/***************************************************************************
  (C) Copyright DELTA TAU DATA SYSTEMS Inc., 1992

  Title:    lips.h

  Version:  1.00

  Date:   1/31/1996

  Author(s):  AS

  Header file for Utility functions.

  Note(s):

----------------------------------------------------------------------------

  Change log:

    Date       Rev   Who      Description
  --------- ----- ----- --------------------------------------------
  1/31/96   1.0 AS    Origination

**************************************************************************/
#include <math.h>

/*-------------------- WHY IS MY MOTOR NOT MOVING DEFINES -------------*/
#define WM_JOGPOS_TIME   0x00000001L
#define WM_MOTOR_ENA     0x00000002L
#define WM_UNKN_DACADDR  0x00000004L
#define WM_UNKN_FBKADDR  0x00000008L
#define WM_MSTR_HNDWL_ZO 0x00000010L
#define WM_MSTR_HNDWL_HI 0x00000020L
#define WM_MTR_SCLE_HI   0x00000040L
#define WM_MTR_SCLE_ZO   0x00000080L
#define WM_FFE_LOW       0x00000100L
#define WM_MAX_VEL_LOW   0x00000200L
#define WM_MAX_ACC_ZO    0x00000400L
#define WM_MAX_ACC_LOW   0x00000800L
#define WM_MAX_JGACC_ZO  0x00001000L
#define WM_MAX_JGACC_LOW 0x00002000L
#define WM_JOG_ACCTM_HI  0x00004000L
#define WM_JOG_STM_HI    0x00008000L
#define WM_JGSPD_LOW     0x00010000L
#define WM_PGAIN_LOW     0x00020000L
#define WM_PSERR_LOW     0x00040000L
#define WM_DACLIM_LOW    0x00080000L
#define WM_TMBASE_LOW    0x00100000L
#define WM_POS_HRDLIM    0x00200000L
#define WM_NEG_HRDLIM    0x00400000L
#define WM_MTR_OPNLP     0x00800000L
#define WM_FFE_EXCEDE    0x01000000L
#define WM_INVALID_MOTOR_NUMBER 0x02000000L
#define WM_AMPFAULT      0x04000000L  
#define WM_I2T_AMPFAULT  0x08000000L  
#define WM_IFE_EXCEDE    0x10000000L  
#define WM_LIM_SOFT      0x20000000L  


/*-------------------- WHY IS MY PROGRAM NOT RUNNING DEFINES -------------*/
#define WP_PGM_MVTIME     0x00000001L
#define WP_MV_SEGTIME_LO  0x00000002L
#define WP_MV_SEGTIME_HI  0x00000004L
#define WP_CS_ACCTM_HI    0x00000008L
#define WP_CS_STIME_HI    0x00000010L
#define WP_CS_FDRTE_LO    0x00000020L
#define WP_CS_TME_HI      0x00000040L
#define WP_CS_SLEW_LO     0x00000080L
#define WP_CRCL_LO        0x00000100L
#define WP_FDRATE_LO      0x00000200L
#define WP_POINT_PGM      0x00000400L
#define WP_NOMTRS_CS      0x00000800L
#define WP_INVALID_CS_NUMBER 0x00001000L
#define WP_SVOTIME_LO     0x00002000L
#define WP_PROG_HOLD      0x00004000L
#define WP_ERR_RUNTIME    0x00008000L
#define WP_ERR_CIRRAD     0x00010000L
#define WP_ERR_AMPFAULT   0x00020000L
#define WP_ERR_FFE        0x00040000L
#define WP_ERR_WFE        0x00080000L

#define X_WORD  1
#define Y_WORD  2
#define D_WORD  3
#define L_WORD  4

#ifdef __cplusplus
extern "C"{
#endif

  long   CALLBACK whyMotorNotMoving (DWORD dwDevice,UINT motor);
  long whyMotorNotMovingPMAC(DWORD dwDevice,UINT motor);
  long whyMotorNotMovingTURBO(DWORD dwDevice,UINT motor);

  LPCSTR CALLBACK whyMotorNotMovingString(long err);
  LPCSTR CALLBACK whyMotorNotMovingStringTURBO(long err);

  long   CALLBACK whyCSNotMoving(DWORD dwDevice, UINT CS);
  long   CALLBACK whyCSNotMovingPMAC(DWORD dwDevice, UINT CS);
  long   CALLBACK whyCSNotMovingTURBO(DWORD dwDevice, UINT CS);

  LPCSTR CALLBACK whyCSNotMovingString(long err);
  LPCSTR CALLBACK whyCSNotMovingStringTURBO(long err);

  int iGetCoordSysDef(DWORD dwDevice,int iMotor,char *cStr);

  BOOL CALLBACK InBufferedMode(DWORD dwDevice);

#ifdef __cplusplus
}
#endif


