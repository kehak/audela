/***************************************************************************

        Title:          dprbkg.h

        Version:        1.00

        Date:           01/26/1998

        Author(s):      Ed Lay & Allen Segall

        Header file for PMAC Dual Ported RAM Background functions.

        Note(s):

----------------------------------------------------------------------------

HISTORY:

30Jul98 JET Added DprBackgroundVar() for enable disable of variable background.
26Jan98 EBL Creation

***************************************************************************/
#ifndef _DPRBKG_H
  #define _DPRBKG_H

typedef struct gsTURBO {             // Global Status  ??? Must be on BYTE boundaries
                                     // DWord 1 ( ??? 1st 24/32 bit word )
  USHORT rffu2                  : 8; // 0-7
  USHORT internal1              : 3; // 8-10
  USHORT buffer_full            : 1; // 11
  USHORT internal2              : 4; // 12-16
  USHORT internal3              : 1;
  USHORT plc_buf_open           : 1; // 17
  USHORT rot_buf_open           : 1; // 18
  USHORT prog_buf_open          : 1; // 19
  USHORT bin_rot_buf_open       : 1; // 20
  USHORT internal4              : 3;
  USHORT pad2                   : 8;
                                     // DWord 2 ( ??? 2nd 24/32 bit word )
  USHORT card_adrssed           : 1; // 0
  USHORT all_adrssed            : 1; // 1
  USHORT rffu1                  : 2;
  USHORT ring_error             : 1; // 4
  USHORT ring_io_error          : 1; // 5
  USHORT tws_error              : 1; // 6
  USHORT end_gather             : 1; // 7
  USHORT rapid_m_flag           : 1; // 8
  USHORT rti_warning            : 1; // 9
  USHORT earom_error            : 1; // 10
  USHORT dpram_error            : 1; // 11
  USHORT prom_checksum          : 1; // 12
  USHORT mem_checksum           : 1; // 13
  USHORT comp_on                : 1; // 14
  USHORT wdt1                   : 1; // 15
  USHORT wdt2                   : 1; // 16
  USHORT ext_trig_gat           : 1; // 17
  USHORT prep_trig_gat          : 1; // 18
  USHORT data_gat_on            : 1; // 19
  USHORT servo_err              : 1; // 20
  USHORT servo_active           : 1; // 21
  USHORT intr_reentry           : 1; // 22
  USHORT intr_active            : 1; // 23
  USHORT pad1                   : 8;
} GLOBALSTATUSTURBO;

///////////////////////////////////////////////////////////////////////////
// PMAC Background Buffer ------------------------------------------------------
///////////////////////////////////////////////////////////////////////////
struct ms { // Motor definition word ( ? 2nd 24 bit word )
        USHORT in_position      : 1;
        USHORT warn_ferr        : 1;
        USHORT fatal_ferr       : 1;
        USHORT amp_fault        : 1;
        USHORT backlash_dir     : 1;
        USHORT rffu1            : 3;
        USHORT rffu2            : 2;
        USHORT home_complete    : 1;
        USHORT stopped_on_limit : 1;
        USHORT rffu3            : 2;
        USHORT amp_enabled      : 1;
        USHORT rffu4            : 1;
        USHORT rffu5            : 4;
        USHORT coord_sys        : 3;
        USHORT cs_assigned      : 1;
        USHORT pad              : 8;
};

struct ps { // Program Execution Status ( ?? 2nd 24 bit word )
        USHORT cir_spline_move    : 1;  // #0
        USHORT ccw_move           : 1;
        USHORT cc_on              : 1;
        USHORT cc_left            : 1;
        USHORT pvt_spline_move    : 1;
        USHORT seg_stop_request   : 1;
        USHORT seg_accel          : 1;
        USHORT seg_move           : 1;
        USHORT rapid_move_mode    : 1;
        USHORT cc_buffered        : 1;
        USHORT cc_stop_request    : 1;
        USHORT cc_outside_corner  : 1;
        USHORT dwell_buffered     : 1;
        USHORT sync_m_func        : 1;
        USHORT eob_stop           : 1;
        USHORT delayed_calc       : 1;
        USHORT rot_buff_full      : 1;
        USHORT in_position        : 1;
        USHORT warn_ferr          : 1;
        USHORT fatal_ferr         : 1;
        USHORT amp_fault          : 1;
        USHORT circle_rad_err     : 1;
        USHORT run_time_err       : 1;
        USHORT prog_hold          : 1;  // #23 Look ahead in TURBO
        USHORT pad                : 8;
};

struct cs { // Coord Status
            // word 1 Motor definition word
            //DWORD    motor_def;
         unsigned long motor_def;

         // word 2  Coordinate status ( ?? 1st 24 bit word )
         USHORT prog_running      : 1;
         USHORT single_step_mode  : 1;
         USHORT cont_motion_mode  : 1;
         USHORT tm_mode           : 1;
         USHORT cont_motion_req   : 1;
         USHORT rad_vect_inc_mode : 1;
         USHORT a_axis_inc        : 1;
         USHORT a_axis_infeed     : 1;
         USHORT b_axis_inc        : 1;
         USHORT b_axis_infeed     : 1;
         USHORT c_axis_inc        : 1;
         USHORT c_axis_infeed     : 1;
         USHORT u_axis_inc        : 1;
         USHORT u_axis_infeed     : 1;
         USHORT v_axis_inc        : 1;
         USHORT v_axis_infeed     : 1;
         USHORT w_axis_inc        : 1;
         USHORT w_axis_infeed     : 1;
         USHORT x_axis_inc        : 1;
         USHORT x_axis_infeed     : 1;
         USHORT y_axis_inc        : 1;
         USHORT y_axis_infeed     : 1;
         USHORT z_axis_inc        : 1;
         USHORT z_axis_infeed     : 1;
         USHORT pad2              : 8;
};
struct bkfdptr {
         USHORT fdadr             :16; // Address of current % use to determine
                                       // if in normal or time base mode
         USHORT pad3              : 6;
         USHORT fdhld             : 1; // in feed hold no jog off
         USHORT pad2              : 1;
         USHORT pad1              : 8;
};


struct backm { // background coord/motor axis structure

        // addresses below are for motor/coord 1
        long                    mpos[2];    // $D093 - $D094 motor desired position
        long                    bpos[2];    // $D095 - $D096 position bias
        struct ms               mstatus;    // $D097 motor status
        struct cs               cstatus;    // $D098 - $D099 coord sys status
        long                    cpos[9][2]; // $D09A - $D0AB axis desired position
        struct ps               pstatus;    // $D0AC program execution status
        unsigned long           pr;         // $D0AD program remaining
        unsigned long           timrem;     // $D0AE - time remain in move (I13=0)
        long                    tats;       // $D0AF - time remain in TA/TS (I13=0)
        unsigned long           pe;         // $D0B0 - Program execution line
        long                    fvel;       // $D0B1 - filtered velocity
};

struct backg { // background buffer structure

  USHORT          dataready;   // Y:$D08A PMAC done updating
  USHORT          spare1;      // X:$D08A spare
  unsigned long   cpanelport;  // $D08B control panel port
  unsigned long   thumbwport;  // $D08C thumbwheel port
  unsigned long   machineport; // $D08D machine IO port
  struct bkfdptr  fdptr[2];    // $DO8E - $D08F
  long            fdpot[2];    // $DO90 - $D091
  unsigned long   spare2[1];   // $D08E - $D092 spares
  struct backm    mtrcrd[8];   // motor coord structures
};

struct bkfdptrTURBO {
  unsigned long fdadr      :19; // B0..18 - Address of current % use to determine
                               // if in normal or time base mode
  USHORT pad3              : 2;
  USHORT fdslew            : 1; // B21 = 1 - in feed slew mode
  USHORT fdhld             : 1; // B22 = 1 - in feed hold no jog off
  USHORT pad2              : 1;
  USHORT pad1              : 8;
};

struct csTURBO { // Coord Status
  // word 1 Coordinate status ( ?? 2nd 24 bit word )
  USHORT                          : 8;
  USHORT                          : 8;
  USHORT                          : 2;
  USHORT in_prog_pmatch           : 1;  // #18
  USHORT sync_m_func_buf_ovrflow  : 1;  // #19
  USHORT sync_m_func_in_buf       : 1;  // #20
  USHORT look_ahead_buf_end       : 1;  // #21
  USHORT look_ahead_buf_lbck      : 1;  // #22
  USHORT look_ahead_buf_wrap      : 1;  // #23
  USHORT                          : 8;

  // word 2  Coordinate status ( ?? 1st 24 bit word )
  USHORT prog_running             : 1; 
  USHORT single_step_mode         : 1; 
  USHORT cont_motion_mode         : 1; 
  USHORT tm_mode                  : 1; 
  USHORT cont_motion_req          : 1; 
  USHORT rad_vect_inc_mode        : 1; 
  USHORT a_axis_inc               : 1; 
  USHORT a_axis_infeed            : 1; 
  USHORT b_axis_inc               : 1; 
  USHORT b_axis_infeed            : 1; 
  USHORT c_axis_inc               : 1; 
  USHORT c_axis_infeed            : 1; 
  USHORT u_axis_inc               : 1; 
  USHORT u_axis_infeed            : 1; 
  USHORT v_axis_inc               : 1; 
  USHORT v_axis_infeed            : 1; 
  USHORT w_axis_inc               : 1; 
  USHORT w_axis_infeed            : 1; 
  USHORT x_axis_inc               : 1; 
  USHORT x_axis_infeed            : 1; 
  USHORT y_axis_inc               : 1; 
  USHORT y_axis_infeed            : 1; 
  USHORT z_axis_inc               : 1; 
  USHORT z_axis_infeed            : 1; 
  USHORT pad2                     : 8; 
};



struct backcTURBO {                         // background coord. Sys. axis structure
                                            // Addresses for C.S. #1
        long                    ffdrate[2]; // $602A5 - C.S. Feedrate(F) or Time(TM)
        long                    fdpot;      // $602A7 - C.S. Feedpot
                                            //        struct bkfdptrTURBO     fdptr;          // $602A8 - C.S. Desired Feedpot Ptr.
        struct bkfdptr          fdptr;      // $602A8 - C.S. Desired Feedpot Ptr.
        struct csTURBO          cstatus;    // $602AA - coord sys status X:mem
        long                    cpos[9][2]; // $602AB - $D0AB axis desired position
        struct ps               pstatus;    // $602BD - program execution status
        unsigned long           pr;         // $602BE - program remaining
        unsigned long           timrem;     // $602BF - time remain in move (I13=0)
        long                    tats;       // $602C0 - time remain in TA/TS (I13=0)
        unsigned long           pe;         // $602C1 - Program execution line
        unsigned long           sparec[3];  // $602C2 - $602C4  spares
};

struct bkrdycsTURBO {
         USHORT datardy           : 1; // B0 - 1 = Data Rdy/ 0 = Request Data
         USHORT pad3              : 7;




};

struct backgTURBO {                // background buffer structure
        USHORT    cordsys  : 8;      // Y:$6019D B0..7  - Number of C.S. used to be I59
        USHORT    hyspare  : 8;      // Y:$6019D B8..15 - Spare
        USHORT    hxspare  : 8;      // X:$6019D B0-14  - spare
        USHORT    hzspare  : 7;
        USHORT    hostbusy : 1;      // X:$6019D B15 host busy

        USHORT    servotimer;      // Y:$6019E Servo Timer
        USHORT    servotimerms8:8; // X:$6019E Servo Timer upper 8 bits
        USHORT    pspare:7;
        USHORT    datardy:1;       // X:$6019E pmac data ready/busy = 1/0

        unsigned long   cpanelport;   // $6019F - control panel port
        unsigned long   machineport;  // $601A0 - machine IO port
        unsigned long   thumbwport;   // $601A1 - thumbwheel port
        struct gsTURBO  globalstatus; // $601A2
        unsigned long   sparebg[3];   // $601A4 - $601A6 spares
        struct backcTURBO crdsys[16]; // $601A7 - $603A6 coord sys structures
};

///////////////////////////////////////////////////////////////////////////
// BACK GROUND VARIABLE BUFFER Interface Structure
struct backgvar {
   USHORT       dataready;  // Y:$D1FA PMAC done updating
   USHORT       servotimer; // X:$D1FA servotimer
   USHORT       bufsize;    // Y:$D1FB Size of rotary buffer
   USHORT       bufstart;   // X:$D1FB buffer start / TURBO = offset
};

///////////////////////////////////////////////////////////////////////////
// BACK GROUND VARIABLE WRITE BUFFER
struct backgvarwrite{
        USHORT num_entries; // x:$D1F5  Up to 32 writes
        USHORT buf_start;   // y:$D1F5
};

struct VBGWFormat{
        long type_addr;
        long data1;
        long data2;
};

///////////////////////////////////////////////////////////////////////////
// BACK GROUND VARIABLE BUFFER Status Structure
// Update VBGDB structure
struct backgvarbuf_status{
        USHORT num_entries; // Number of entries in address array
        USHORT num_data;    // Number of PMAC 16 bit words placed in data array
        USHORT addr_offset; // Offset to begginning of user's address array
        USHORT data_offset; // Offset to begginning of user's data array
};

//////////////////////////////////////////////////////////////////////////
// Functions
  #ifdef __cplusplus
extern "C" {
  #endif

  BOOL CALLBACK PmacDPRBackground(DWORD dwDevice,int on);
  BOOL CALLBACK PmacDPRBackgroundEx(DWORD dwDevice,int on, UINT period, UINT crd);
  BOOL CALLBACK PmacDPRBackGroundVar(DWORD dwDevice, BOOL on);
  BOOL CALLBACK PmacDPRUpdateBackground(DWORD dwDevice);

  // Functions pertaining to coord systems
  long CALLBACK PmacDPRPe(DWORD dwDevice,int cs);
  BOOL CALLBACK PmacDPRRotBufFull(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRSysInposition(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRSysWarnFError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRSysFatalFError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRSysRunTimeError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRSysCircleRadError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRSysAmpFaultError(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRProgRunning(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRProgStepping(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRProgContMotion(DWORD dwDevice,int crd);
  BOOL CALLBACK PmacDPRProgContRequest(DWORD dwDevice,int crd);
  int  CALLBACK PmacDPRProgRemaining(DWORD dwDevice,int crd);
  double  CALLBACK PmacDPRCommanded(DWORD dwDevice,int coord,char axchar);
  BOOL CALLBACK PmacDPRLookAheadEnabled(DWORD dwDevice,int crd);

  // For BACKWARD COMPATIBLITY PURPOSES ONLY
  BOOL   CALLBACK PmacDPRSetBackground(DWORD dwDevice);

  #ifdef __cplusplus
}
  #endif


#endif
