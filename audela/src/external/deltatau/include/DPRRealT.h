/***************************************************************************

        Title:          dprrtdbt.h

        Version:        2.00

        Initially Created:   12/12/1997

        Author(s):      Allen Segall, Ed Lay

        Header file for PMAC Dual Ported RAM Real Time Data Buffer (DPRRTDB)

        Note(s):

----------------------------------------------------------------------------

        Change log:

          Date       Rev      Who                    Description
        ---------    -----   -----   --------------------------------------------
        01/20/98              EBL    Latest Servo Structure
***************************************************************************/
#ifndef _DPRREALT_H
  #define _DPRREALT_H

  #include "windows.h"
///////////////////////////////////////////////////////////////////////////
// TURBO -------------------------------------------------------
///////////////////////////////////////////////////////////////////////////
typedef struct ssTURBO {           // Motor Servo Status ( ?  1st 24 bit word  )
        USHORT rapid_spd_sel  : 1; // B00 - RAPID MOVE SPEED SELECT (IXX90)
        USHORT dac_sign_mag   : 1; // B01 - SIGN/MAGNITUDE SERVO (IXX96)
        USHORT sw_capture     : 1; // B02 - SOFTWARE HOME CAPTURE (IXX97.0)
        USHORT fe_capture     : 1; // B03 - CAPTURE ON FOLLOWING ERROR (IXX97.1)
        USHORT handwheel_ena  : 1; // B04 - HANDWHEEL ENABLE FLAG (IXX06.0)
        USHORT hw_mode        : 1; // B05 - HANDWHEEL MODE FLAG (IXX06.1)
        USHORT phased_motor   : 1; // B06 - PHASED MOTOR ENABLE FLAG (IXX01.0)
        USHORT yenc_phase     : 1; // B07 - Y PHASE ENCODER (IXX01.1)
        USHORT user_servo     : 1; // B08 - USER WRITEN SERVO ENABLE (IXX59.0)
        USHORT user_phase     : 1; // B09 - USER WRITEN PHASE ENABLE (IXX59.1)
        USHORT home_search    : 1; // B10 - HOME IN PROGRESS FLAG
        USHORT block_request  : 1; // B11 - BLOCK REQUEST FLAG
        USHORT limit_stop     : 1; // B12 - Limit Stop Flag
        USHORT desired_vel_0  : 1; // B13 - Desired Velocity = 0
        USHORT data_block_err : 1; // B14 - DATA BLOCK ERROR
        USHORT dwelling       : 1; // B15 - Dwell Mode
        USHORT integrator_ena : 1; // B16 - Ixx34
        USHORT run_program    : 1; // B17 - MOVE TIMER ACTIVE
        USHORT open_loop      : 1; // B18 - OPEN LOOP MODE
        USHORT amp_enabled    : 1; // B19 - AMPLIFIER ENABLED FLAG
        USHORT algo_ena       : 1; // B20 - EXTENDED ALGO ENABLE FLAG (I3300+50*N)
        USHORT pos_limit      : 1; // B21 - POSITIVE POSITION LIMIT
        USHORT neg_limit      : 1; // B22 - NEGATIVE POSITION LIMIT
        USHORT activated      : 1; // B23 - Ixx00
        USHORT pads           : 8; // B24..31 - Not Available
} SERVOSTATUSTURBO;

typedef struct msTURBO {             // Motor Status ( ?  1st 24 bit word  )
        USHORT in_position     : 1;   // B00 - IN POSITION
        USHORT warn_ferr       : 1;   // B01 - SOFT FOLLOWING ERROR
        USHORT fatal_ferr      : 1;   // B02 - FATAL FOLLOWING ERROR
        USHORT amp_fault       : 1;   // B03 - AMP FAULT ERROR
        USHORT backlash_dir    : 1;   // B04 - BACKLASH DIRECTION FLAG
        USHORT amp_i2t_err     : 1;   // B05 - I2T AMP FAULT
        USHORT integral_ferr   : 1;   // B06 - INTEGRATED FOLLOWING ERROR FAULT
        USHORT triger_home_flg : 1;   // B07 - TRIGGER/HOME MOVE FLAG
        USHORT phase_find_err  : 1;   // B08 - PHASE FINDING ERROR FLAG
        USHORT tbd09           : 1;   // B09 - TBD
        USHORT home_complete   : 1;   // B10 - HOME COMPLETE FLAG
        USHORT stopped_on_limit: 1;  // B11 - POS LIMIT STOP FLAG
        USHORT                 : 1;   // B12 - TBD
        USHORT                 : 1;   // B13 - TBD
        USHORT                 : 1;   // B14 - TBD
        USHORT cs_assigned     : 1;   // B15 - TBD
        USHORT cs_def          : 4;   // B16..19 - Coord. Sys. Axis Def
        USHORT coord_sys       : 4;   // B20..23 - MOTOR COORDINATE SYSTEM NUMBER (-1)
        USHORT padm            : 8;   // B24..31 - Not Available
} MOTORSTATUSTURBO;

struct realmTURBO {             // real time buffer motor structure
        long      pepos[2];     // $6001D - Mtr position following err
        long      pdac;         // $6001F - Mtr previous DAC
        struct ssTURBO sstatus; // $60020 - Mtr servo status
        struct msTURBO mstatus; // $60021 - Mtr Status
        long      bpos[2];      // $60022 - Mtr Postion Bias
        long      fvel;         // $60024 - Mtr Filtered/Average Velocity
        long      mspare[2];    // $60025 - Mtr spares [ Total of 20 DPR locations ]
        long      pos[2];       // $60027-28 - Mtr actual position
};

struct realtTURBO {                 // real time buffer structure
        USHORT                : 16; // Y:$6001A
        USHORT                : 8;  // X:$6001A B0-30 spare
        USHORT                : 7;
        USHORT    hostbusy    : 1;  // X:$6001A B31 host busy
        USHORT    servotimer;       // Y:$6001B Servo Timer
        USHORT    servotimerms8:8;  // X:$6001B Servo Timer upper 8 bits
        USHORT    pspare      : 7;
        USHORT    dataready   : 1;  // X:$6001B pmac data ready/busy = 1/0
        long      motor_mask;       // L:$6001C Motor Mask (motors 1-32)

        struct    realmTURBO  motor[32]; // L:$6001D - $60028 1 thru 32 motor structures
};


///////////////////////////////////////////////////////////////////////////
// PMAC -------------------------------------------------------
///////////////////////////////////////////////////////////////////////////
typedef struct ss { // Motor Servo Status ( ?  1st 24 bit word  )
        USHORT internal1        : 8;
        USHORT internal2        : 2;
        USHORT home_search      : 1;
        USHORT block_request    : 1;
        USHORT rffu1            : 1;
        USHORT desired_vel_0    : 1;
        USHORT data_block_err   : 1;
        USHORT dwelling         : 1;
        USHORT integration      : 1;
        USHORT run_program      : 1;
        USHORT open_loop        : 1;
        USHORT phased_motor     : 1;
        USHORT handwheel_ena    : 1;
        USHORT pos_limit        : 1;
        USHORT neg_limit        : 1;
        USHORT activated        : 1;
        USHORT pad              : 8;
} SERVOSTATUS;

typedef struct gs {                  // Global Status
                                     // DWord 1 ( ??? 1st 24/32 bit word )
        USHORT rffu2            : 8; // 0-7
        USHORT internal1        : 3; // 8-10
        USHORT buffer_full      : 1;
        USHORT internal2        : 3; // 12-14
        USHORT dpram_response   : 1;
        USHORT plc_command      : 1;
        USHORT plc_buf_open     : 1;
        USHORT rot_buf_open     : 1; // 18
        USHORT prog_buf_open    : 1; // 19
        USHORT internal3        : 2;
        USHORT host_comm_mode   : 1;
        USHORT internal4        : 1;
        USHORT pad2             : 8;
                                     // DWord 2 ( ??? 2nd 24/32 bit word )
        USHORT rffu1            : 7;
        USHORT end_gather       : 1;
        USHORT rapid_m_flag     : 1;
        USHORT rti_warning      : 1;
        USHORT earom_error      : 1;
        USHORT dpram_error      : 1;
        USHORT prom_checksum    : 1;
        USHORT mem_checksum     : 1;
        USHORT comp_on          : 1;
        USHORT stimulate_on     : 1;
        USHORT stimulus_ent     : 1;
        USHORT prep_trig_gat    : 1;
        USHORT prep_next_serv   : 1;
        USHORT data_gat_on      : 1;
        USHORT servo_err        : 1;
        USHORT servo_active     : 1;
        USHORT intr_reentry     : 1;
        USHORT intr_active      : 1;
        USHORT pad1             : 8;
} GLOBALSTATUS;

struct realm {                     // real time buffer motor structure
                                   // addresses below are for motor 1
        long            dpos[2];   // $D012 - $D013 commanded position
        long            apos[2];   // $D014 - $D015 actual position
        long            hwpos[2];  // $D016 - $D017 hand wheel position
        long            cpos[2];   // $D018 - $D019 compensation position
        unsigned long   pdac;      // $D01A previous DAC
        struct ss       sstatus;   // $D01B servo status
        long            fvel;      // $D01C velocity delta position
        long            movtim;    // $D01D Mtr Move Time remaining / %feedpot
                                   //       valid when I13 = 0
        unsigned long   mspare[3]; // $D01E - $D020 motor spares

};


struct realt { // real time buffer structure

        USHORT          hostbusy:1;     // Y:$D009 B0
        USHORT          rffu1:15;       // Y:$D009 B1-15
        USHORT          servotimer:15;  // X:$D009 B0-14
        USHORT          pmacbusy:1;     // X:$D009 B15
        struct gs       globalstatus;   // $D00A - $D00B
        long            ffdrate[2][2];  // Coord. System feedrate(F) or Time(TM)
        unsigned long   spareglobal[2]; // $D020 - $D011
        struct realm    mtrcrd[8];      // 1 thru 8 motor structures
};

//////////////////////////////////////////////////////////////////////////
// Functions
  #ifdef __cplusplus
extern "C" {
  #endif
  // *************************************************************************
  ///////////////////////////////////////////////////////////////////////////*
  ///////////////////// INITIALIZATION ROUTINES /////////////////////////////*
  ///////////////////////////////////////////////////////////////////////////*
  // *************************************************************************

  BOOL CALLBACK PmacDPRRealTime(DWORD dwDevice,UINT period,int on);
  BOOL CALLBACK PmacDPRRealTimeEx(DWORD dwDevice,long mask,UINT period,int on);
  void CALLBACK PmacDPRRealTimeSetMotor(DWORD dwDevice, long mask);

  // *************************************************************************
  ///////////////////////////////////////////////////////////////////////////*
  ///////////////////// HANDSHAKING ROUTINES ////////////////////////////////*
  ///////////////////////////////////////////////////////////////////////////*
  // *************************************************************************

  BOOL CALLBACK  PmacDPRUpdateRealTime(DWORD dwDevice);

  //------------------- PMAC SPECIFIC --------------------------------------//
  void CALLBACK PmacDPRSetHostBusyBit(DWORD dwDevice,int value);
  int  CALLBACK PmacDPRGetHostBusyBit(DWORD dwDevice);
  int  CALLBACK PmacDPRGetPmacBusyBit(DWORD dwDevice);
  //------------------- TURBO SPECIFIC -------------------------------------//
  void CALLBACK  PmacDPRResetDataReadyBit(DWORD dwDevice);
  long CALLBACK  PmacDPRGetDataReadyBit(DWORD dwDevice);

  // *************************************************************************
  ///////////////////////////////////////////////////////////////////////////*
  ///////////////////// DATA ACCESS ROUTINES ////////////////////////////////*
  ///////////////////////////////////////////////////////////////////////////*
  // *************************************************************************
  int  CALLBACK PmacDPRGetServoTimer(DWORD dwDevice);
  double CALLBACK  PmacDPRGetCommandedPos(DWORD dwDevice,int mtr, double units);
  double CALLBACK PmacDPRPosition(DWORD dwDevice,int mtr,double units);
  double CALLBACK PmacDPRFollowError(DWORD dwDevice,int mtr,double units);
  void CALLBACK PmacDPRGetMasterPos(DWORD dwDevice,int mtr,double units, double *the_double);
  void  CALLBACK PmacDPRGetCompensationPos(DWORD dwDevice,int mtr,double units,double *the_double);
  double CALLBACK PmacDPRGetVel(DWORD dwDevice,int mtr,double units);
  DWORD CALLBACK PmacDPRGetPrevDAC(DWORD dwDevice,int mtr);
  DWORD CALLBACK PmacDPRGetMoveTime(DWORD dwDevice,int mtr);


  // Functions pertaining to individual motors
  BOOL CALLBACK PmacDPRMotorEnabled(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacDPRHandwheelEnabled(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacDPRPhasedMotor(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacDPRDataBlock(DWORD dwDevice,int mtr);
  BOOL CALLBACK PmacDPROnNegativeLimit(DWORD dwDevice,int  mtr);
  BOOL CALLBACK PmacDPROnPositiveLimit(DWORD dwDevice,int  mtr);
  BOOL CALLBACK PmacDPROpenLoop(DWORD dwDevice,int mtr);
  void CALLBACK PmacDPRSetJogReturn(DWORD dwDevice,int mtr);


  //------------------- PMAC SPECIFIC --------------------------------------//
  struct ss CALLBACK PmacDPRMotorServoStatus(DWORD dwDevice,int mtr);


  //------------------- TURBO SPECIFIC -------------------------------------//
  struct ssTURBO CALLBACK PmacDPRMotorServoStatusTurbo(DWORD dwDevice,int mtr);

  #ifdef __cplusplus
}
  #endif

#endif
